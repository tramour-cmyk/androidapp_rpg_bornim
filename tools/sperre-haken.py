#!/usr/bin/env python3
"""1739 (1727 Gesamtbild 7, G:908; werkzeuge.md B „Sperre Keystore, Zugangsdaten, Force-Push, main“): PreToolUse-Sperre für Bash
und die GitHub-Schreibwerkzeuge. Hält an (Exit 2):
  1. Force-Push in jeder Form: --force, -f (auch in -uf), --force-with-lease, --force-if-includes, --mirror, +Refspec
     (`git push origin +main`); die Regeln `deny` in .claude/settings.json fangen nur das Präfix `git push --force…`,
     `git push origin main --force` ging durch (werkzeuge.md „Abgleich mit Bauliste 7.1“).
  2. Löschen eines Zweigs auf GitHub: --delete, -d, --prune, `:zweig` (CLAUDE.md „Keine Verlaufsänderung, kein Force-Push“).
  4. Umgehen der git-Haken (1937): `git push --no-verify`, `git commit --no-verify` oder `-n` (pre-commit commit-pruefung.py,
     pre-push vorpush.py mit den Prüfungen aus probelauf.py).
  5. main außerhalb der Notizkopie umsetzen (1963, Ursache wie 1776): `git checkout -B main`, `git switch -C main`, `git branch -f main`
     setzen bei git 2.43 den Zweig um, den die Notizkopie hält; deren Index zeigt dann den alten Stand als vorgemerkt.
  3. Keystore und Zugangsdaten ins Repo (CLAUDE.md „Nie committen: Keystore, Signatur-Passwort, local.properties, SDK-Pfad“):
     `git add` mit so einem Pfad, `git commit` mit so einer Datei im Index (bei -a auch geänderte), GitHub-Schreibwerkzeug mit
     so einem Pfad. Muster in GEHEIM.
`main` selbst: Spielcode auf main hält schon commit-pruefung.py an (1765), hier nicht doppelt.
Erkennung wie buildzweig-haken.py (Heredoc und Zeichenketten zählen nicht, Shell-Vorsätze schon). Nur gegen Versehen; jeder
Fehler im Haken lässt durch. Prüfen von Hand: sperre-haken.py --test
Muster (erst nachsehen, wie andere es lösen): GitHub „Branch protection: block force pushes / deletions“ (stellt der Chef ein,
werkzeuge.md B „GitHub-Regel“) und Secret-Scanner als pre-commit (gitleaks, detect-secrets); hier dieselbe Prüfung vor dem Befehl.
"""
import importlib.util, json, os, re, subprocess, sys

HIER = os.path.dirname(os.path.abspath(__file__))
_s = importlib.util.spec_from_file_location("buildzweig_haken", os.path.join(HIER, "buildzweig-haken.py"))
bz = importlib.util.module_from_spec(_s); _s.loader.exec_module(bz)

GEHEIM = re.compile(r"(?:^|/)(?:[^/]*\.(?:jks|keystore|p12|pfx)|local\.properties|keystore\.properties|signing\.properties"
                    r"|\.env(?:\.[\w-]+)?|credentials\.json|id_(?:rsa|ed25519|ecdsa)(?:\.pub)?|google-services\.json)$", re.I)
LANG_FORCE = ("--force", "--force-with-lease", "--force-if-includes", "--mirror")
LANG_LOESCH = ("--delete", "--prune")
GIT = re.compile(r"(?:^|[;&|(`\n])\s*" + bz.VORSATZ + r"git\b((?:\s+-C\s+\S+|\s+-c\s+\S+)*)\s+(add|commit)\b([^;&|`)\n]*)")
MCP_SCHREIBEN = ("push_files", "create_or_update_file", "delete_file")
MAIN_UM = re.compile(r"(?:^|[;&|(`\n])\s*" + bz.VORSATZ + r"git\b((?:\s+-C\s+\S+|\s+-c\s+\S+)*)\s+(?:checkout\s+(?:-q\s+)?-B|switch\s+(?:-q\s+)?-C|branch\s+(?:-q\s+)?-f)\s+main\b")
NOTIZKOPIE = "bornim-main"
MELDUNG = ("Sperre (1739, Gesamtbild 7; CLAUDE.md „Technik und Sicherheit“): %s ist verboten. Keine Verlaufsänderung, kein Force-Push, "
           "kein Löschen von Zweigen, kein Umgehen der git-Haken (Grund beheben, den der Haken nennt); Keystore, Signatur-Passwort, local.properties nie ins Repo (nur GitHub-Secrets). Anders lösen; "
           "geht es nicht ohne: Frage per `vorgang.py rueckmeldung <Nr> \"Frage …\"`.")


def push_grund(args):
    """Grund für Anhalten bei den Argumenten eines git push, sonst None."""
    teile = args.split()
    for t in teile:
        lang = t.split("=", 1)[0]
        if lang in LANG_FORCE: return "Force-Push (%s)" % t
        if lang in LANG_LOESCH: return "Zweig löschen (%s)" % t
        if lang == "--no-verify": return "Push ohne git-Haken (%s)" % t
        if re.fullmatch(r"-[A-Za-z]+", t):
            if "f" in t[1:]: return "Force-Push (%s)" % t
            if "d" in t[1:]: return "Zweig löschen (%s)" % t
    ref = [t for t in teile if not t.startswith("-")][1:]
    for r in ref:
        if r.startswith("+"): return "Force-Push (Refspec %s)" % r
        if r.startswith(":") and len(r) > 1: return "Zweig löschen (Refspec %s)" % r
    return None


def _git(wo, *a):
    try: return subprocess.run(["git", "-C", wo] + list(a), capture_output=True, text=True, timeout=5).stdout.split("\n")
    except Exception: return []


def _wo(roh, m, cwd, gruppe):
    cds = re.findall(r"(?:^|[;&|(\n])\s*cd\s+([^\s;&|]+)", roh[:m.start()])
    c = re.search(r"-C\s+(\S+)", gruppe or "")
    return c.group(1) if c else (os.path.join(cwd or ".", os.path.expanduser(cds[-1])) if cds else (cwd or "."))


def geheim_bash(roh, cwd):
    for m in GIT.finditer(roh):
        wo = _wo(roh, m, cwd, m.group(1))
        args = m.group(3).split()
        if m.group(2) == "commit" and any(a == "--no-verify" or re.fullmatch(r"-[A-Za-z]*n[A-Za-z]*", a) for a in args):
            return "--no-verify"
        if m.group(2) == "add":
            for p in (a for a in args if not a.startswith("-")):
                if GEHEIM.search(p.rstrip("/")): return p
        else:
            namen = _git(wo, "diff", "--cached", "--name-only")
            if any(a == "--all" or re.fullmatch(r"-[A-Za-z]*a[A-Za-z]*", a) for a in args):
                namen += _git(wo, "diff", "--name-only")
            for p in namen:
                if p and GEHEIM.search(p): return p
    return None


def grund_bash(befehl, cwd):
    roh = bz.ohne_text(befehl)
    for m in bz.PUSH.finditer(roh):
        g = push_grund(m.group(2))
        if g: return g
    for m in MAIN_UM.finditer(roh):
        if os.path.basename(os.path.normpath(_wo(roh, m, cwd, m.group(1)))) != NOTIZKOPIE:
            return ("main in der Arbeitskopie umsetzen (1963: verdirbt den Index der Notizkopie; Notizen in ../bornim-main, "
                    "Code auf einen claude/-Zweig: git switch -c claude/<name> origin/main)")
    p = geheim_bash(roh, cwd)
    if p == "--no-verify": return "Commit ohne git-Haken (--no-verify, -n)"
    return "Keystore oder Zugangsdaten ins Repo (%s)" % p if p else None


def grund(e):
    name = e.get("tool_name", "")
    t = e.get("tool_input") or {}
    if name == "Bash": return grund_bash(t.get("command", ""), e.get("cwd"))
    if name.startswith("mcp__github__") and name.split("__")[-1] in MCP_SCHREIBEN:
        pfade = [str(t.get("path", ""))] + [str(f.get("path", "")) for f in (t.get("files") or []) if isinstance(f, dict)]
        p = next((x for x in pfade if x and GEHEIM.search(x)), None)
        return "Keystore oder Zugangsdaten ins Repo (%s)" % p if p else None
    return None


def main():
    try:
        g = grund(json.load(sys.stdin))
        if not g: return 0
        print(MELDUNG % g, file=sys.stderr)
        return 2
    except Exception:
        return 0


def test():
    import tempfile
    f = 0
    def ok(b, was):
        nonlocal f
        if not b: f += 1; print("FEHLER", was)
    for b in ("git push --force origin main", "git push -f origin x", "git push origin main --force", "git push -uf origin x",
              "git push origin +main", "git push origin +HEAD:claude/x", "git push --force-with-lease origin x",
              "git push --force-with-lease=x:abc origin x", "cd a && git push origin main --force", "timeout 60 git push -f origin x",
              "for i in 1 2; do git push origin +x && break; done", "git -C /tmp push --mirror origin"):
        ok((grund_bash(b, ".") or "").startswith("Force-Push"), "Force: " + b)
    for b in ("git push origin --delete claude/x", "git push -d origin x", "git push origin :claude/x", "git push --prune origin"):
        ok((grund_bash(b, ".") or "").startswith("Zweig löschen"), "Löschen: " + b)
    for b in ("git push -u origin claude/x", "git push -q origin main", "git push origin HEAD:claude/build-3", "git push",
              "echo 'git push --force'", 'git commit -m "kein git push -f hier" && git push origin x', "git push -n origin x",
              "git log --format=%h -n 3", "git push -v origin a:b", "python3 - <<'EOF'\nprint('git push origin +main')\nEOF"):
        ok(grund_bash(b, ".") is None, "erlaubt: " + b)
    for b in ("git add app/release.jks", "git add -f local.properties", "git add android/keystore.properties", "cd x && git add .env"):
        ok((grund_bash(b, ".") or "").startswith("Keystore"), "add: " + b)
    ok(grund_bash("git add godot/skripte/held.gd docs/x.md", ".") is None, "add harmlos")
    for b in ("git push --no-verify origin x", "git commit --no-verify -m x", "git commit -nm x", "cd a && git commit -an -m x"):
        ok("git-Haken" in (grund_bash(b, ".") or ""), "Haken umgehen: " + b)
    ok(grund_bash("git commit -m 'kein --no-verify'", ".") is None, "no-verify nur im Text")
    d = tempfile.mkdtemp()
    subprocess.run(["git", "init", "-q", d]); open(os.path.join(d, "a.txt"), "w").write("a")
    subprocess.run(["git", "-C", d, "add", "a.txt"])
    ok(grund_bash("git commit -q -m x", d) is None, "commit harmlos")
    open(os.path.join(d, "upload.keystore"), "w").write("k"); subprocess.run(["git", "-C", d, "add", "upload.keystore"])
    ok((grund_bash("git commit -q -m x", d) or "").startswith("Keystore"), "commit mit Keystore im Index")
    ok((grund_bash("git -C %s commit -m x" % d, "/") or "").startswith("Keystore"), "commit -C")
    ok(grund({"tool_name": "mcp__github__push_files", "tool_input": {"files": [{"path": "a/b.jks"}]}}), "MCP push_files")
    ok(grund({"tool_name": "mcp__github__create_or_update_file", "tool_input": {"path": "godot/x.gd"}}) is None, "MCP harmlos")
    print("SPERRE1739 %d Fehler" % f)
    return 1 if f else 0


if __name__ == "__main__":
    sys.exit(test() if "--test" in sys.argv else main())
