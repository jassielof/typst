#!/usr/bin/env python3
"""Translation tooling for the Typst docs (fork only). Stdlib only, Python 3.11+.

    python3 tools/i18n status    [--lang es-AR]        list new / outdated / orphaned units
    python3 tools/i18n check     [--lang es-AR]        validate that translations preserve structure
    python3 tools/i18n stamp     PATH... [--lang]      mark translated units as up to date
    python3 tools/i18n translate [--lang] [--only SUBSTR] [--limit N] [--dry-run]

Units:
  * files:  docs/content/**/*.typ (except changelog) + EXTRA_FILES. Overlay in
            docs/i18n/<lang>/files/<same path relative to docs/>; source hashes
            live in docs/i18n/<lang>/state.json.
  * docs:   Rust doc comments. Sidecar docs/i18n/<lang>/docs/<rs path>.i18n with
            `@@ key  [src:hash]` entries. Extraction is done by
            `cargo docit i18n-dump`, the same parser the docs build uses.
"""
import argparse, collections, hashlib, json, os, re, subprocess, sys, tomllib, urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DOCS = ROOT / "docs"
EXTRA_FILES = ["components/preface.typ"]
SKIP_DIRS = ("content/changelog",)


def h(text: str) -> str:
    return hashlib.sha256(text.encode()).hexdigest()[:8]


class Lang:
    def __init__(self, code):
        self.code = code
        self.dir = DOCS / "i18n" / code
        self.state_path = self.dir / "state.json"
        self.state = json.loads(self.state_path.read_text()) if self.state_path.exists() else {}
        g = self.dir / "glossary.toml"
        self.glossary = tomllib.loads(g.read_text()) if g.exists() else {}
        r = self.dir / "rules.md"
        self.rules = r.read_text() if r.exists() else ""

    def save(self):
        self.state_path.write_text(json.dumps(self.state, indent=1, sort_keys=True) + "\n")


# --------------------------------------------------------------------------- units

def source_files():
    out = [p for p in (DOCS / "content").rglob("*.typ")
           if not any(str(p.relative_to(DOCS)).startswith(s) for s in SKIP_DIRS)]
    out += [DOCS / f for f in EXTRA_FILES]
    return sorted(p.relative_to(DOCS).as_posix() for p in out)


def rust_docs():
    """{rs path: {key: markup}} via the docs binary."""
    files = subprocess.run(["git", "ls-files", "crates/**/*.rs"], cwd=ROOT, text=True,
                           capture_output=True, check=True).stdout.split()
    res = subprocess.run(["cargo", "docit", "i18n-dump", *files], cwd=ROOT, text=True,
                         capture_output=True)
    if res.returncode != 0:
        sys.exit(res.stderr)
    return json.loads(res.stdout)


def parse_sidecar(text):
    """{key: (hash|None, body)}"""
    out, cur = {}, None
    for line in text.splitlines(keepends=True):
        m = re.match(r"@@ (\S+)(?:\s+\[src:(\w+)\])?\s*$", line)
        if m:
            cur = m.group(1)
            out[cur] = [m.group(2), ""]
        elif cur:
            out[cur][1] += line
    return {k: (v[0], v[1].rstrip("\n") + "\n") for k, v in out.items()}


def write_sidecar(path: Path, entries):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(f"@@ {k}  [src:{hh}]\n{body}" for k, (hh, body) in sorted(entries.items())))


def sidecar_path(lang, rs):
    return lang.dir / "docs" / (rs + ".i18n")


def compute_status(lang, with_docs=True):
    """Returns {'files': {...}, 'docs': {...}} mapping unit -> new|outdated|ok|orphan."""
    files = {}
    for rel in source_files():
        overlay = lang.dir / "files" / rel
        cur = h((DOCS / rel).read_text())
        if not overlay.exists():
            files[rel] = "new"
        elif lang.state.get(rel) != cur:
            files[rel] = "outdated"
        else:
            files[rel] = "ok"
    ov_root = lang.dir / "files"
    if ov_root.exists():
        for p in ov_root.rglob("*"):
            rel = p.relative_to(ov_root).as_posix()
            if p.is_file() and rel not in files:
                files[rel] = "orphan"
    docs = {}
    if with_docs:
        src = rust_docs()
        seen = set()
        for rs, entries in src.items():
            sc_path = sidecar_path(lang, rs)
            sc = parse_sidecar(sc_path.read_text()) if sc_path.exists() else {}
            for key, markup in entries.items():
                unit = f"{rs}::{key}"
                seen.add(unit)
                if key not in sc:
                    docs[unit] = "new"
                elif sc[key][0] != h(markup):
                    docs[unit] = "outdated"
                else:
                    docs[unit] = "ok"
            for key in sc:
                if key not in entries:
                    docs[f"{rs}::{key}"] = "orphan"
        droot = lang.dir / "docs"
        if droot.exists():
            for p in droot.rglob("*.i18n"):
                rs = p.relative_to(droot).as_posix()[: -len(".i18n")]
                if rs not in src:
                    for key in parse_sidecar(p.read_text()):
                        docs[f"{rs}::{key}"] = "orphan"
    return {"files": files, "docs": docs}


def cmd_status(a):
    lang = Lang(a.lang)
    st = compute_status(lang, not a.no_docs)
    for kind, units in st.items():
        c = collections.Counter(units.values())
        print(f"{kind}: " + ", ".join(f"{k}={c[k]}" for k in ("ok", "new", "outdated", "orphan")))
        for state in ("outdated", "orphan") if not a.verbose else ("new", "outdated", "orphan"):
            for u, s in sorted(units.items()):
                if s == state:
                    print(f"  {state:9} {u}")
    return 0


def cmd_stamp(a):
    lang = Lang(a.lang)
    for rel in a.paths:
        lang.state[rel] = h((DOCS / rel).read_text())
    lang.save()
    return 0


# --------------------------------------------------------------------------- check

FENCE = re.compile(r"^(\s*)(`{3,})([^\n`]*)\n(.*?)^\1\2\s*$", re.S | re.M)


def fences(text):
    return [(m.group(3).strip(), m.group(4)) for m in FENCE.finditer(text)]


def prose(text):
    return FENCE.sub("", text)


def strip_strings(code):
    code = re.sub(r'"(?:\\.|[^"\\])*"', '""', code)
    return re.sub(r"//[^\n]*", "", code)


def skeleton(code):
    """Function calls / `#names` / named args of code, ignoring text."""
    code = strip_strings(code)
    return collections.Counter(re.findall(r"#?[A-Za-z_][\w.-]*(?=\()|#[A-Za-z][\w.-]*|[A-Za-z][\w-]*(?=:)", code))


def multiset(rx, text):
    return collections.Counter(re.findall(rx, text))


def diff_ms(name, a, b, out):
    if a != b:
        miss, extra = list((a - b).elements()), list((b - a).elements())
        out.append(f"{name}: missing {miss[:5]} extra {extra[:5]}")


VOSEO_BAD = re.compile(r"\b(tú|puedes|tienes|quieres|escribe tu|recuerda que)\b", re.I)


def check_pair(src, tr, lang, is_tutorial=False):
    """Returns a list of problems."""
    out = []
    fs, ft = fences(src), fences(tr)
    if len(fs) != len(ft):
        out.append(f"code blocks: {len(fs)} vs {len(ft)}")
    else:
        for (ls, cs), (lt, ct) in zip(fs, ft):
            if ls != lt:
                out.append(f"code block language changed {ls!r} -> {lt!r}")
            elif ls == "example":
                if skeleton(cs) != skeleton(ct):
                    out.append(f"example code changed: {list((skeleton(cs) - skeleton(ct)).elements())[:4]}")
                elif not is_tutorial and cs != ct:
                    out.append("example translated outside the tutorial")
            elif cs != ct:
                out.append(f"code block changed: {cs.strip()[:40]!r}")
    ps, pt = prose(src), prose(tr)
    diff_ms("#calls", multiset(r"#[A-Za-z][\w.-]*", ps), multiset(r"#[A-Za-z][\w.-]*", pt), out)
    diff_ms("@refs", multiset(r"@[A-Za-z][\w:.-]*", ps), multiset(r"@[A-Za-z][\w:.-]*", pt), out)
    diff_ms("<labels>", multiset(r"<[A-Za-z][\w:.-]*>", ps), multiset(r"<[A-Za-z][\w:.-]*>", pt), out)
    diff_ms("urls", multiset(r"https?://[^\s)\]\"]+", ps), multiset(r"https?://[^\s)\]\"]+", pt), out)
    diff_ms("`raw`", multiset(r"`[^`\n]+`", ps), multiset(r"`[^`\n]+`", pt), out)
    def words(t):  # visible words only: no raw, refs, calls, urls
        t = re.sub(r"`[^`\n]*`|@[\w:.-]+|#[\w.-]+|https?://\S+|<[\w:.-]+>", " ", t)
        return t.lower()
    wps, wpt = words(ps), words(pt)
    for en, es in lang.glossary.items():
        stem = es.lower()[: max(4, len(es) - 2)]
        if re.search(rf"\b{re.escape(en)}s?\b", wps) and stem not in wpt:
            out.append(f"glossary: '{en}' should be '{es}'")
    if VOSEO_BAD.search(pt):
        out.append(f"voseo: {VOSEO_BAD.search(pt).group(0)!r}")
    return out


def cmd_check(a):
    lang = Lang(a.lang)
    bad = 0
    for rel in source_files():
        overlay = lang.dir / "files" / rel
        if overlay.exists():
            for p in check_pair((DOCS / rel).read_text(), overlay.read_text(), lang, rel.startswith("content/tutorial")):
                print(f"files/{rel}: {p}"); bad += 1
    if not a.no_docs:
        src = rust_docs()
        for rs, entries in src.items():
            sc_path = sidecar_path(lang, rs)
            if not sc_path.exists():
                continue
            for key, (_, body) in parse_sidecar(sc_path.read_text()).items():
                if key in entries:
                    for p in check_pair(entries[key], body, lang):
                        print(f"{rs}::{key}: {p}"); bad += 1
    print(f"{bad} problem(s)")
    return 1 if bad and a.strict else 0


# --------------------------------------------------------------------------- translate

def api(system, user, model, key):
    body = json.dumps({"model": model, "max_tokens": 32000, "temperature": 0.2,
                       "system": system, "messages": [{"role": "user", "content": user}]}).encode()
    req = urllib.request.Request("https://api.anthropic.com/v1/messages", body,
                                 {"x-api-key": key, "anthropic-version": "2023-06-01",
                                  "content-type": "application/json"})
    with urllib.request.urlopen(req, timeout=600) as r:
        return "".join(b["text"] for b in json.load(r)["content"] if b["type"] == "text")


def system_prompt(lang):
    gl = "\n".join(f'- "{k}" -> "{v}"' for k, v in lang.glossary.items())
    return f"{lang.rules}\nGlosario:\n{gl}"


def translate_with_retry(system, user, src, lang, model, key, is_tutorial, single=None):
    feedback = ""
    for _ in range(2):
        text = api(system, user + feedback, model, key)
        if single:
            problems = check_pair(src, text, lang, is_tutorial)
        else:
            problems = []
        if not problems:
            return text
        feedback = "\n\nTu intento anterior tuvo estos problemas, corregilos:\n- " + "\n- ".join(problems)
    return text


def cmd_translate(a):
    key = os.environ.get("ANTHROPIC_API_KEY") or sys.exit("ANTHROPIC_API_KEY is not set")
    model = os.environ.get("I18N_MODEL", "claude-sonnet-5-5")
    lang = Lang(a.lang)
    st = compute_status(lang, not a.no_docs)
    sysmsg = system_prompt(lang)
    done = 0
    for rel, s in sorted(st["files"].items()):
        if s not in ("new", "outdated") or (a.only and a.only not in rel):
            continue
        if a.limit is not None and done >= a.limit:
            break
        print(f"translating {rel} ({s})")
        if a.dry_run:
            done += 1; continue
        src = (DOCS / rel).read_text()
        user = ("Traducí este archivo Typst completo. Devolvelo completo y válido, en el mismo formato, "
                "sin envolverlo en un bloque de código:\n\n" + src)
        prev = lang.dir / "files" / rel
        if s == "outdated" and prev.exists():
            user += "\n\nTraducción anterior (reutilizá lo que no cambió):\n\n" + prev.read_text()
        text = translate_with_retry(sysmsg, user, src, lang, model, key, rel.startswith("content/tutorial"), single=True)
        prev.parent.mkdir(parents=True, exist_ok=True)
        prev.write_text(text if text.endswith("\n") else text + "\n")
        lang.state[rel] = h(src)
        lang.save()
        done += 1
    src_docs = rust_docs() if not a.no_docs else {}
    for rs, entries in sorted(src_docs.items()):
        pending = {k: m for k, m in entries.items()
                   if st["docs"].get(f"{rs}::{k}") in ("new", "outdated")}
        if not pending or (a.only and a.only not in rs):
            continue
        if a.limit is not None and done >= a.limit:
            break
        print(f"translating {rs} ({len(pending)} entries)")
        if a.dry_run:
            done += 1; continue
        user = ("Traducí cada entrada. Formato de entrada y de salida: líneas `@@ clave` seguidas del "
                "marcado. Conservá las claves exactamente.\n\n" +
                "\n".join(f"@@ {k}\n{m}" for k, m in pending.items()))
        text = api(sysmsg, user, model, key)
        got = parse_sidecar(text)
        sc_path = sidecar_path(lang, rs)
        cur = parse_sidecar(sc_path.read_text()) if sc_path.exists() else {}
        for k, m in pending.items():
            if k in got and not check_pair(m, got[k][1], lang):
                cur[k] = (h(m), got[k][1])
            else:
                print(f"  skipped {k} (missing or failed check)")
        write_sidecar(sc_path, cur)
        done += 1
    return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--lang", default="es-AR")
    sub = ap.add_subparsers(dest="cmd", required=True)
    for name, fn in (("status", cmd_status), ("check", cmd_check), ("stamp", cmd_stamp), ("translate", cmd_translate)):
        p = sub.add_parser(name)
        p.set_defaults(fn=fn)
        p.add_argument("--lang", default=argparse.SUPPRESS)
        if name != "stamp":
            p.add_argument("--no-docs", action="store_true", help="skip Rust doc comments (no cargo needed)")
        if name == "status":
            p.add_argument("-v", "--verbose", action="store_true")
        if name == "check":
            p.add_argument("--strict", action="store_true")
        if name == "stamp":
            p.add_argument("paths", nargs="+")
        if name == "translate":
            p.add_argument("--only"); p.add_argument("--limit", type=int); p.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    sys.exit(a.fn(a))


if __name__ == "__main__":
    main()
