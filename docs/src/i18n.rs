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
use typst::foundations::{Bytes, Dict, IntoValue, Scope, Styles, Value, func};
use typst::syntax::{FileId, RootedPath, VirtualRoot};
use typst::text::{Font, Lang, Region, TextElem};

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
        State {
            lang: lang.into(),
            root,
            ui,
            sidecars: Mutex::default(),
        }
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

/// Loads the translated replacement for a file, if there is one: either a full
/// copy in `files/` or a line patch in `patches/`.
pub fn overlay(id: FileId) -> Option<Bytes> {
    match overlay_path(id) {
        Some(path) => std::fs::read(path).ok().map(Bytes::new),
        None => patched(id),
    }
}

/// Applies `patches/<path>.toml` (`"original line" = "translated line"`, compared
/// ignoring indentation) to the upstream file. Lines without an entry, e.g.
/// because upstream added or changed them, stay in English.
fn patched(id: FileId) -> Option<Bytes> {
    let state = state()?;
    let VirtualRoot::Package(spec) = id.root() else { return None };
    if *spec != DOCS_ROOT {
        return None;
    }
    let rel = id.vpath().get_without_slash();
    let patch =
        std::fs::read_to_string(state.root.join("patches").join(format!("{rel}.toml")))
            .ok()?;
    let rules = parse_ui(&patch);
    let docs = state.root.parent()?.parent()?;
    let source = std::fs::read_to_string(docs.join(rel)).ok()?;
    let mut out = String::with_capacity(source.len());
    for line in source.split_inclusive('\n') {
        let body = line.trim_end_matches(['\n', '\r']);
        let trimmed = body.trim_start();
        match rules.get(trimmed.trim_end()) {
            Some(new) => {
                out.push_str(&body[..body.len() - trimmed.len()]);
                out.push_str(new);
                out.push_str(&line[body.len()..]);
            }
            None => out.push_str(line),
        }
    }
    Some(Bytes::new(out.into_bytes()))
}

/// Makes the code examples that the docs compile use the translated language
/// (e.g. for heading supplements and bibliography titles).
pub fn example_styles(styles: &mut Styles) {
    let Some(state) = state() else { return };
    let (lang, region) = match state.lang.split_once('-') {
        Some((lang, region)) => (lang, Some(region)),
        None => (state.lang.as_str(), None),
    };
    if let Ok(lang) = lang.to_lowercase().parse::<Lang>() {
        styles.set(TextElem::lang, lang);
    }
    if let Some(region) = region.and_then(|r| r.to_uppercase().parse::<Region>().ok()) {
        styles.set(TextElem::region, Some(region));
    }
}

/// Adds the fonts shipped with the translation (`docs/i18n/<lang>/fonts`) to
/// the ones that are available to the docs.
pub fn add_fonts(fonts: &mut Vec<Font>) {
    let Some(state) = state() else { return };
    let mut paths = Vec::new();
    collect_fonts(&state.root.join("fonts"), &mut paths);
    paths.sort();
    for path in paths {
        if let Ok(data) = std::fs::read(path) {
            fonts.extend(Font::iter(Bytes::new(data)));
        }
    }
}

/// Collects the `.ttf` and `.otf` files below a directory. Web and duplicate
/// flavors that usually ship in the same download (web fonts, `*VariableFont*`
/// `.ttf` copies next to `.otf`, variable fonts when static instances ship
/// too) are skipped.
fn collect_fonts(dir: &Path, out: &mut Vec<PathBuf>) {
    let Ok(entries) = std::fs::read_dir(dir) else { return };
    for path in entries.flatten().map(|entry| entry.path()) {
        let name = path.file_name().and_then(|n| n.to_str()).unwrap_or("").to_lowercase();
        if path.is_dir() {
            let skip = name.contains("webfont")
                || matches!(
                    name.as_str(),
                    "ttf" | "woff" | "woff2" | "css" | "scss" | "__macosx"
                );
            if !skip {
                collect_fonts(&path, out);
            }
        } else if !name.starts_with("._")
            && !name.contains("variablefont")
            && matches!(path.extension().and_then(|e| e.to_str()), Some("ttf" | "otf"))
        {
            out.push(path);
        }
    }
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
    // Attributes of the `<html>` element (none for the original).
    let mut html_attrs = Dict::new();
    if lang != "en" {
        html_attrs.insert("lang".into(), lang.into_value());
    }
    scope.define("html-attrs", html_attrs);
    scope.define_func::<i18n_docs>();
    scope.define_func::<ui>();
    scope.define_func::<font>();
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
    let Some(state) = state() else { return text };
    match state.ui.get(text.as_str()) {
        Some(t) => t.as_str().into(),
        None => {
            // Developer aid: `I18N_MISSING=1` lists the strings without a translation.
            if std::env::var_os("I18N_MISSING").is_some() {
                eprintln!("I18N_MISSING {}", serde_json::Value::from(text.as_str()));
            }
            text
        }
    }
}

/// Like `ui`, but for font families: returns the translated family only if
/// that font is actually available, and `default` otherwise.
#[func]
fn font(key: EcoString, default: EcoString) -> EcoString {
    let Some(family) = state().and_then(|s| s.ui.get(key.as_str())) else {
        return default;
    };
    let available = crate::world::FONTS
        .1
        .iter()
        .any(|font| font.info().family.eq_ignore_ascii_case(family));
    if available { family.as_str().into() } else { default }
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
                map.insert(key, finish(body));
            }
            let key = header.split("[src:").next().unwrap_or(header).trim();
            current = Some((key.to_string(), String::new()));
        } else if let Some((_, body)) = &mut current {
            body.push_str(line);
        }
    }
    if let Some((key, body)) = current {
        map.insert(key, finish(body));
    }
    map
}

/// The blank line before the next header is a separator, not content.
fn finish(body: String) -> String {
    format!("{}\n", body.trim_end_matches('\n'))
}

/// The default PDF output path, which is language-specific for translated builds.
pub fn pdf_path(workspace: &Path, default: &str, lang: Option<&str>) -> PathBuf {
    match lang {
        Some(lang) => workspace.join(format!("docs/dist/docs-{lang}.pdf")),
        None => workspace.join(default),
    }
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
