//! Translation support for the docs (fork-only, see `docs/i18n/README.md`).
//!
//! Everything lives in this file so that the hooks in upstream files stay tiny:
//! - a file overlay (`docs/i18n/<lang>/files/**` shadows `docs/**`),
//! - sidecar translations of Rust doc comments (`docs/i18n/<lang>/docs/**`),
//! - UI string translations (`docs/i18n/<lang>/ui.toml`),
//! - an `i18n-dump` developer subcommand used by `tools/i18n`.
//!
//! Anything that is not translated falls back to the original English.

use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::process::ExitCode;
use std::sync::{Mutex, OnceLock};

use ecow::EcoString;
use typst::foundations::{Bytes, Dict, IntoValue, Scope, Value, func};
use typst::syntax::{FileId, RootedPath, VirtualRoot};

use crate::world::DOCS_ROOT;

/// The active translation, if any.
static STATE: OnceLock<Option<State>> = OnceLock::new();

struct State {
    lang: String,
    /// `docs/i18n/<lang>`.
    root: PathBuf,
    ui: HashMap<String, String>,
    /// Parsed sidecar files, keyed by Rust source path.
    sidecars: Mutex<HashMap<String, HashMap<String, String>>>,
}

fn state() -> Option<&'static State> {
    STATE.get().and_then(Option::as_ref)
}

/// Activates a language. Does nothing when `lang` is `None`.
pub fn init(lang: Option<&str>, workspace: &Path) {
    let state = lang.map(|lang| {
        let root = workspace.join("docs/i18n").join(lang);
        let ui = std::fs::read_to_string(root.join("ui.toml"))
            .map(|text| parse_ui(&text))
            .unwrap_or_default();
        State { lang: lang.into(), root, ui, sidecars: Mutex::default() }
    });
    let _ = STATE.set(state);
}

/// Returns the path of the translated replacement for a file of the docs
/// package, if there is one.
pub fn overlay_path(id: FileId) -> Option<PathBuf> {
    let state = state()?;
    let VirtualRoot::Package(spec) = id.root() else { return None };
    if *spec != DOCS_ROOT {
        return None;
    }
    let path = state.root.join("files").join(id.vpath().get_without_slash());
    path.is_file().then_some(path)
}

/// Loads the translated replacement for a file, if there is one.
pub fn overlay(id: FileId) -> Option<Bytes> {
    overlay_path(id).and_then(|path| std::fs::read(path).ok()).map(Bytes::new)
}

/// Defines the translation-related items of the `stdx` module.
pub fn define(scope: &mut Scope) {
    let lang = state().map_or("en", |s| s.lang.as_str());
    let mut text = Dict::new();
    if let Some((lang, region)) = lang.split_once('-') {
        text.insert("lang".into(), lang.to_lowercase().into_value());
        text.insert("region".into(), region.to_uppercase().into_value());
    } else if lang != "en" {
        text.insert("lang".into(), lang.into_value());
    }
    scope.define("lang", lang);
    scope.define("text-lang", text);
    scope.define_func::<i18n_docs>();
    scope.define_func::<ui>();
}

/// Returns the translation of the doc comment with the given key in the given
/// Rust source file, or `none`.
#[func]
fn i18n_docs(path: RootedPath, key: EcoString) -> Value {
    let path = path.vpath().get_without_slash();
    let Some(state) = state() else { return Value::None };
    let mut sidecars = state.sidecars.lock().unwrap();
    let entries = sidecars.entry(path.to_string()).or_insert_with(|| {
        let file = format!("{}.i18n", path.replace("\\", "/"));
        std::fs::read_to_string(state.root.join("docs").join(file))
            .map(|text| parse_sidecar(&text))
            .unwrap_or_default()
    });
    match entries.get(key.as_str()) {
        Some(text) => Value::Str(text.as_str().into()),
        None => Value::None,
    }
}

/// Translates a UI string, falling back to the English text.
#[func]
fn ui(text: EcoString) -> EcoString {
    state()
        .and_then(|s| s.ui.get(text.as_str()))
        .map_or(text, |t| t.as_str().into())
}

/// Parses a sidecar file.
///
/// ```text
/// @@ Array::first  [src:a1b2c3d4]
/// Translated markup...
/// ```
///
/// Keeps entries verbatim (including the trailing newline that the original
/// doc-comment markup has).
pub fn parse_sidecar(text: &str) -> HashMap<String, String> {
    let mut map = HashMap::new();
    let mut current: Option<(String, String)> = None;
    for line in text.split_inclusive('\n') {
        if let Some(header) = line.strip_prefix("@@ ") {
            if let Some((key, body)) = current.take() {
                map.insert(key, body);
            }
            let key = header.split("[src:").next().unwrap_or(header).trim();
            current = Some((key.to_string(), String::new()));
        } else if let Some((_, body)) = &mut current {
            body.push_str(line);
        }
    }
    if let Some((key, body)) = current {
        map.insert(key, body);
    }
    // The blank line before the next header is a separator, not content.
    for body in map.values_mut() {
        let trimmed = body.trim_end_matches('\n');
        *body = format!("{trimmed}\n");
    }
    map
}

/// Parses a minimal TOML subset: `"key" = "value"` lines and `#` comments.
fn parse_ui(text: &str) -> HashMap<String, String> {
    fn string(s: &str) -> Option<(String, &str)> {
        let mut chars = s.strip_prefix('"')?.char_indices();
        let mut out = String::new();
        while let Some((i, c)) = chars.next() {
            match c {
                '"' => return Some((out, &s[i + 2..])),
                '\\' => match chars.next()?.1 {
                    'n' => out.push('\n'),
                    't' => out.push('\t'),
                    other => out.push(other),
                },
                c => out.push(c),
            }
        }
        None
    }

    let mut map = HashMap::new();
    for line in text.lines() {
        let line = line.trim();
        if line.starts_with('#') || line.is_empty() {
            continue;
        }
        if let Some((key, rest)) = string(line)
            && let Some(rest) = rest.trim_start().strip_prefix('=')
            && let Some((value, _)) = string(rest.trim_start())
        {
            map.insert(key, value);
        }
    }
    map
}

/// Handles the `i18n-dump` developer subcommand before regular argument
/// parsing: `cargo docit i18n-dump <rust files relative to the workspace>`.
///
/// Prints a JSON object `{ path: { key: markup } }` using the exact same
/// extraction as the docs themselves, so `tools/i18n` never has to parse Rust.
pub fn subcommand() -> Option<ExitCode> {
    let mut args = std::env::args().skip(1);
    if args.next().as_deref() != Some("i18n-dump") {
        return None;
    }
    let workspace = Path::new(env!("CARGO_MANIFEST_DIR")).join("..");
    let mut out = serde_json::Map::new();
    for path in args {
        let Ok(source) = std::fs::read_to_string(workspace.join(&path)) else { continue };
        let items = crate::live::live_item_data(source.as_str().into());
        let mut entries = serde_json::Map::new();
        for (key, value) in items {
            if let Value::Array(array) = value
                && let Some(Value::Str(docs)) = array.at(1, None).ok()
                && !docs.as_str().trim().is_empty()
            {
                entries.insert(key.to_string(), docs.as_str().into());
            }
        }
        if !entries.is_empty() {
            out.insert(path.replace('\\', "/"), entries.into());
        }
    }
    println!("{}", serde_json::Value::Object(out));
    Some(ExitCode::SUCCESS)
}
