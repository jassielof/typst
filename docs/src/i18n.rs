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
use std::process::{Command, ExitCode};
use std::sync::{Mutex, OnceLock};
use std::time::{SystemTime, UNIX_EPOCH};

use ecow::EcoString;
use typst::foundations::{Bytes, Dict, FromValue, IntoValue, Scope, Styles, Value, func};
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
    /// Where and when the docs were built from (see `revision`).
    revision: Dict,
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
            revision: revision(workspace),
            sidecars: Mutex::default(),
        }
    });
    let _ = STATE.set(state);
}

/// Runs `git` in the workspace and returns its trimmed output, if it succeeded.
fn git(workspace: &Path, args: &[&str]) -> Option<String> {
    let out = Command::new("git")
        .arg("-C")
        .arg(workspace)
        .args(args)
        .output()
        .ok()?;
    let text = String::from_utf8(out.stdout).ok()?;
    let text = text.trim();
    (out.status.success() && !text.is_empty()).then(|| text.to_string())
}

/// Describes the revision of the (forked) repository the docs are built from:
/// the Typst version of the manifest, the nearest tag (if any), the commit and
/// its date, the build date and the base URL of the sources on GitHub. Missing
/// pieces are `none`, except `source-base`, which always works.
fn revision(workspace: &Path) -> Dict {
    let commit = git(workspace, &["rev-parse", "HEAD"]);
    let repo = git(workspace, &["remote", "get-url", "origin"])
        .and_then(|url| {
            let url = url.trim_end_matches(".git");
            let path = url
                .split_once("github.com/")
                .or_else(|| url.split_once("github.com:"))?
                .1;
            let mut parts = path.splitn(2, '/');
            Some(format!("https://github.com/{}/{}", parts.next()?, parts.next()?))
        })
        .unwrap_or_else(|| "https://github.com/typst/typst".into());
    let source_base = match &commit {
        Some(commit) => format!("{repo}/blob/{commit}"),
        None => format!(
            "https://github.com/typst/typst/blob/{}",
            typst_utils::version().commit().unwrap_or("main")
        ),
    };
    let opt = |value: Option<String>| value.map_or(Value::None, IntoValue::into_value);
    let date = git(workspace, &["show", "-s", "--format=%cs", "HEAD"]);
    let mut dict = Dict::new();
    dict.insert("version".into(), typst_utils::version().raw().into_value());
    dict.insert("tag".into(), opt(git(workspace, &["describe", "--tags", "--abbrev=0"])));
    dict.insert(
        "short".into(),
        opt(commit.as_ref().map(|c| c.chars().take(7).collect())),
    );
    dict.insert("commit".into(), opt(commit));
    let built = build_date();
    dict.insert("date-long".into(), opt(date.as_deref().and_then(long_date)));
    dict.insert("built-long".into(), opt(long_date(&built)));
    dict.insert("date".into(), opt(date));
    dict.insert("built".into(), built.into_value());
    dict.insert("repo".into(), repo.into_value());
    dict.insert("source-base".into(), source_base.into_value());
    dict
}

/// Formats `YYYY-MM-DD` as e.g. `10 de octubre de 2026` (Spanish only).
fn long_date(iso: &str) -> Option<String> {
    const MONTHS: [&str; 12] = [
        "enero",
        "febrero",
        "marzo",
        "abril",
        "mayo",
        "junio",
        "julio",
        "agosto",
        "septiembre",
        "octubre",
        "noviembre",
        "diciembre",
    ];
    let mut parts = iso.split('-');
    let year: u32 = parts.next()?.parse().ok()?;
    let month: usize = parts.next()?.parse().ok()?;
    let day: u32 = parts.next()?.parse().ok()?;
    Some(format!("{day} de {} de {year}", MONTHS.get(month.checked_sub(1)?)?))
}

/// Today's date (UTC) as `YYYY-MM-DD`.
fn build_date() -> String {
    let days = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_or(0, |d| d.as_secs() / 86_400) as i64;
    // Civil-from-days (Howard Hinnant).
    let z = days + 719_468;
    let era = z.div_euclid(146_097);
    let doe = z.rem_euclid(146_097);
    let yoe = (doe - doe / 1_460 + doe / 36_524 - doe / 146_096) / 365;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let day = doy - (153 * mp + 2) / 5 + 1;
    let month = if mp < 10 { mp + 3 } else { mp - 9 };
    let year = yoe + era * 400 + i64::from(month <= 2);
    format!("{year:04}-{month:02}-{day:02}")
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
    let dir = state.root.join("fonts");
    let mut paths = Vec::new();
    collect_fonts(&dir, &mut paths);
    // `fonts/skip.txt`: one case-insensitive substring of a file path per line.
    let skip: Vec<String> = std::fs::read_to_string(dir.join("skip.txt"))
        .unwrap_or_default()
        .lines()
        .map(|line| line.trim().to_lowercase())
        .filter(|line| !line.is_empty() && !line.starts_with('#'))
        .collect();
    paths.retain(|path| {
        let path = path.to_string_lossy().to_lowercase();
        !skip.iter().any(|pattern| path.contains(pattern.as_str()))
    });
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
    scope.define("revision", state().map(|s| s.revision.clone()).unwrap_or_default());
    scope.define("text-lang", text);
    // Attributes of the `<html>` element (none for the original).
    let mut html_attrs = Dict::new();
    if lang != "en" {
        html_attrs.insert("lang".into(), lang.into_value());
    }
    scope.define("html-attrs", html_attrs);
    scope.define_func::<i18n_docs>();
    scope.define_func::<i18n_docs_or>();
    scope.define_func::<i18n_description>();
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

/// Like `i18n-docs`, but takes the `docs` and `def-site` of a reflected item
/// and returns the translation or the original `docs`.
#[func]
fn i18n_docs_or(docs: Value, def_site: Value) -> Value {
    if let Value::Dict(site) = &def_site
        && let (Ok(path), Ok(key)) = (site.get("path"), site.get("key"))
        && let (Ok(path), Ok(key)) =
            (RootedPath::from_value(path.clone()), EcoString::from_value(key.clone()))
    {
        let tr = i18n_docs(path, key);
        if !matches!(tr, Value::None) {
            return tr;
        }
    }
    docs
}

/// Builds a plain-text `<meta name="description">` for a definition page:
/// what it is, its name, and the (translated) first sentence(s) of its docs,
/// without markup and cut at a word boundary.
#[func]
fn i18n_description(
    kind: EcoString,
    name: EcoString,
    docs: Value,
    def_site: Value,
) -> EcoString {
    let docs = i18n_docs_or(docs, def_site);
    let text = match &docs {
        Value::Str(s) => s.as_str().to_string(),
        _ => String::new(),
    };
    let first = text.split("\n\n").next().unwrap_or("").replace('\n', " ");
    let mut plain = String::new();
    let mut chars = first.chars().peekable();
    while let Some(c) = chars.next() {
        match c {
            '`' | '*' | '_' | '#' | '$' | '\\' => {}
            '@' => {
                // Skip reference labels like `@figure` (keep the text of `@x[text]`).
                while chars
                    .peek()
                    .is_some_and(|c| c.is_alphanumeric() || matches!(c, ':' | '-'))
                {
                    chars.next();
                }
            }
            '[' | ']' => {}
            c => plain.push(c),
        }
    }
    let plain = plain.split_whitespace().collect::<Vec<_>>().join(" ");
    let mut out = format!("Documentación de {kind} {name} de Typst.");
    if !plain.is_empty() {
        out.push(' ');
        let budget = 155_usize.saturating_sub(out.chars().count());
        if plain.chars().count() <= budget {
            out.push_str(&plain);
        } else {
            let cut: String = plain.chars().take(budget.saturating_sub(1)).collect();
            let cut = cut.rsplit_once(' ').map_or(cut.as_str(), |(head, _)| head);
            out.push_str(cut.trim_end_matches(&[',', ';', ':', '.'][..]));
            out.push('…');
        }
    }
    out.into()
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
