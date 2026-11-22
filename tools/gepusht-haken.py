#!/usr/bin/env python3
"""1739 (1727 Gesamtbild 7, G:909; werkzeuge.md B „Stop-Haken alles gepusht?“): Stop-Haken. Will die Sitzung ihren Zug beenden,
während in der Arbeitskopie (CLAUDE_PROJECT_DIR) oder der Notizkopie (../bornim-main) geänderte, nicht committete Dateien oder
Commits liegen, die auf keinem Zweig von origin stehen, hält er einmal an und nennt sie (CLAUDE.md „am Ende alles committen und
pushen“; Container werden abgeräumt). Beim zweiten Mal lässt er durch (stop_hook_active), also nie eine Schleife; wer begründet
wartet (Push abgewiesen, Chef fragt), beendet einfach noch einmal. Unversionierte Dateien zählen nicht (Probebilder, Zwischenstände).
Jeder Fehler lässt durch. Prüfen von Hand: gepusht-haken.py --test
Muster (erst nachsehen, wie andere es lösen): „git status“-Prompt mit ahead-Zähler (oh-my-zsh, starship) und pre-push/Shell-Exit-
Warnungen; hier dieselbe Zählung am Zugende.
1898 (1727j V2, Vorfall 1776): nur eigene Änderungen drängen zum Pushen. Eigen ist eine Datei, die der Verlauf der Sitzung
(transcript_path) berührt: Edit/Write/NotebookEdit mit ihrem Pfad, ein Bash-Befehl mit Pfad oder Dateinamen, oder ein Werkzeug,
das sie schreibt (SCHREIBER). Jede andere geänderte Datei heißt „fremd, nicht mitpushen“ (etwa veralteter Index der Notizkopie,
der Fremdes zurücksetzen würde); steht ihr Inhalt schon in der Geschichte der Datei, mit „Rückschritt“. Muster: aider committet nur
Dateien, die es selbst bearbeitet hat; die Prüfpunkte von Claude Code verfolgen nur Dateien aus Edit/Write. Ohne lesbaren Verlauf
zählt alles als eigen (wie vorher).
"""
import json, os, re, subprocess, sys

# Werkzeuge, die Notizen schreiben, ohne dass der Befehl den Pfad nennt
SCHREIBER = {"vorgang.py": ("docs/LISTE-VORGAENGE.md", "docs/ARBEIT-BETRIEB.md", "docs/vorgang/"),
             "lauf.py": ("docs/ARBEIT-BETRIEB.md", "docs/ARBEIT-BESETZUNG.md", "docs/LISTE-VORGAENGE.md"),
             "uebergabe.py": ("docs/vorgang/",), "rueckmeldung.py": ("docs/vorgang/", "docs/LISTE-VORGAENGE.md"),
             "regelwerte.py": ("docs/LISTE-REGELWERTE.md",)}
# 1921 (D350.1): meldung.sh schreibt nur über commit-tree auf Refs, nie in die Arbeitskopie, und ist darum kein Schreiber. Lesende Aufrufe
# zählen nicht: vorgang.py ohne Unterbefehl, mit --rolle/--startbar/--hilfe, mit Nummern, pruefen, auftrag ohne --datei oder mit --pruefen;
# Lesebefehle (cat, grep, git show …) ohne Umleitung und ohne -i.
_VORGANG_LESEN = re.compile(r"^(?:--rolle\s+\S+\s*)?(?!--rolle)(?:$|--?\w|hilfe\b|pruefen\b|[\dt][\d.]*\b|auftrag\b(?!.*--datei)|auftrag\b.*--pruefen)")
_LESEN = re.compile(r"^\s*(?:\w+=\S*\s+)*(?:cat|head|tail|less|more|grep|rg|egrep|wc|ls|stat|file|diff|cmp|md5sum|sha\w*sum|du|find|"
                    r"git\s+(?:-C\s+\S+\s+)?(?:show|log|diff|status|blame|grep|ls-files|ls-tree|cat-file|rev-parse)|sed(?!.*\s-i)|awk(?!.*-i\s*inplace)|"
                    r"python3?\s+\S*(?:_test\.py|--test)|echo|printf|test|\[)\b")


def _segmente(befehl):
    return [x for x in re.split(r"&&|\|\||[;\n|]", befehl) if x.strip()]


def _schreibt(seg):
    """True, wenn der Befehlsteil schreiben kann (kein reiner Lesebefehl, Umleitung > zählt als Schreiben)."""
    return bool(re.search(r"(?<![0-9&<>])>(?!&)", seg)) or not _LESEN.match(seg)


def _schreiber_ruf(w, seg):
    """1921: Ruf des Werkzeugs W im Befehlsteil SEG, der schreibt (vorgang.py lesend zählt nicht)."""
    m = re.search(r"(?<![\w-])%s(?![\w-])\s*(.*)" % re.escape(w), seg)
    if not m: return False
    return not (w == "vorgang.py" and _VORGANG_LESEN.match(m.group(1).strip()))


def verlauf(pfad):
    """(Pfade aus Edit/Write/NotebookEdit, Texte der Bash-Befehle) aus dem Verlauf; None, wenn er fehlt oder unlesbar ist."""
    if not pfad or not os.path.isfile(pfad): return None
    dateien, befehle = set(), []
    try:
        for z in open(pfad, encoding="utf-8", errors="replace"):
            if '"tool_use"' not in z: continue
            try: e = json.loads(z)
            except ValueError: continue
            inhalt = (e.get("message") or {}).get("content")
            for b in inhalt if isinstance(inhalt, list) else []:
                if not isinstance(b, dict) or b.get("type") != "tool_use": continue
                i = b.get("input") or {}
                for k in ("file_path", "notebook_path"):
                    if isinstance(i.get(k), str): dateien.add(os.path.realpath(i[k]))
                if isinstance(i.get("command"), str): befehle.append(i["command"])
    except OSError: return None
    return dateien, befehle


def eigen(wo, rel, spur):
    """True, wenn die Datei REL der Arbeitskopie WO laut Verlauf SPUR von der Sitzung berührt ist (ohne Spur immer True)."""
    if spur is None: return True
    dateien, befehle = spur
    if os.path.realpath(os.path.join(wo, rel)) in dateien: return True
    name = os.path.basename(rel)
    for b in befehle:
        for seg in _segmente(b):
            if (rel in seg or re.search(r"(?<![\w.-])%s(?![\w-])" % re.escape(name), seg)) and _schreibt(seg): return True
            for w, ziele in SCHREIBER.items():
                if _schreiber_ruf(w, seg) and any(rel == z or (z.endswith("/") and rel.startswith(z)) for z in ziele): return True
    return False


def rueckschritt(wo, rel):
    """True, wenn der Inhalt der Arbeitskopie schon früher in der Geschichte der Datei stand (Rücksetzen fremder Änderungen)."""
    try:
        blob = _git(wo, "hash-object", "--", rel).strip()
        if blob == _git(wo, "rev-parse", "HEAD:" + rel).strip(): return False
        alt = _git(wo, "log", "-50", "--format=%H", "--", rel).split()
        return any(_git(wo, "rev-parse", "%s:%s" % (h, rel)).strip() == blob for h in alt[1:] if h)
    except Exception:
        return False


def _git(wo, *a):
    p = subprocess.run(["git", "-C", wo] + list(a), capture_output=True, text=True, timeout=8)
    if p.returncode: raise RuntimeError(p.stderr)
    return p.stdout


def offen(wo):
    """(geänderte Dateien, ungepushte Commits) einer Arbeitskopie; None, wenn kein Repo."""
    try: _git(wo, "rev-parse", "--git-dir")
    except Exception: return None
    geaendert = [z[3:] for z in _git(wo, "status", "--porcelain", "--untracked-files=no").splitlines() if z.strip()]
    try: n = int(_git(wo, "rev-list", "--count", "HEAD", "--not", "--remotes=origin").strip() or 0)
    except Exception: n = 0
    return geaendert, n


def orte():
    pd = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
    aus = [pd]
    nm = os.path.join(os.path.dirname(os.path.abspath(pd)), "bornim-main")
    if os.path.isdir(nm) and os.path.realpath(nm) != os.path.realpath(pd): aus.append(nm)
    return aus


def befund(wege, spur=None, art=None):
    """Teile des Befunds; ART (Liste) bekommt je Teil „eigen“, „fremd“, „rueckschritt“ oder „commit“."""
    teile = []
    art = [] if art is None else art
    for wo in wege:
        o = offen(wo)
        if not o: continue
        g, n = o
        mein = [x for x in g if eigen(wo, x, spur)]
        fremd = [x for x in g if x not in mein]
        if mein: art.append("eigen"); teile.append("%s: %d Datei(en) geändert, nicht committet (%s)" % (wo, len(mein), ", ".join(mein[:4]) + (" …" if len(mein) > 4 else "")))
        if fremd:
            rs = [x for x in fremd if rueckschritt(wo, x)]
            art.append("rueckschritt" if rs else "fremd")
            teile.append("%s: %d Datei(en) fremd, nicht mitpushen (%s)%s" % (wo, len(fremd), ", ".join(fremd[:4]) + (" …" if len(fremd) > 4 else ""),
                         ("; Rückschritt auf alten Stand: %s (1776; ansehen, dann `git checkout -- <pfad>`)" % ", ".join(rs[:4])) if rs else ""))
        if n: art.append("commit"); teile.append("%s: %d Commit(s) nicht gepusht" % (wo, n))
    return teile


def main():
    try:
        e = json.load(sys.stdin)
        if e.get("stop_hook_active"): return 0
        art = []
        t = befund(orte(), verlauf(e.get("transcript_path")), art)
        if not t: return 0
        m = meldung(t, art)
        if not m: return 0
        print(m, file=sys.stderr)
        return 2
    except Exception:
        return 0


def meldung(t, art):
    """1921 (D350.1): nur fremde Dateien ohne Rückschritt lassen durch (None); nur fremde mit Rückschritt nennen das, ohne zum Pushen zu
    drängen; sonst wie vorher."""
    if not any(a in ("eigen", "commit") for a in art):
        if "rueckschritt" not in art: return None
        return ("Gepusht? (1739, 1776): %s. Nichts davon committen oder pushen, es ist nicht deins; ansehen, ob es fremde Arbeit "
                "zurücksetzen würde, dann einfach noch einmal beenden." % "; ".join(t))
    return ("Gepusht? (1739, Gesamtbild 7): %s. Vor dem Zugende committen und pushen (Notizen direkt auf main, Code auf den Arbeitszweig); "
              "ist es gewollt (Push abgewiesen, wartet auf Chef), einfach noch einmal beenden." % "; ".join(t))


def test():
    import tempfile
    f = 0
    def ok(b, was):
        nonlocal f
        if not b: f += 1; print("FEHLER", was)
    d = tempfile.mkdtemp(); o = os.path.join(d, "o.git"); a = os.path.join(d, "a")
    run = lambda *x, cwd=None: subprocess.run(list(x), cwd=cwd, check=True, capture_output=True)
    run("git", "init", "-q", "--bare", o); run("git", "clone", "-q", o, a)
    for k, v in (("user.email", "t@t"), ("user.name", "t")): run("git", "config", k, v, cwd=a)
    open(os.path.join(a, "x"), "w").write("1"); run("git", "add", "x", cwd=a); run("git", "commit", "-qm", "1", cwd=a)
    ok(befund([a]) == ["%s: 1 Commit(s) nicht gepusht" % a], "ungepusht")
    run("git", "push", "-q", "origin", "HEAD:main", cwd=a)
    ok(befund([a]) == [], "alles gepusht")
    open(os.path.join(a, "neu.png"), "w").write("p")
    ok(befund([a]) == [], "unversioniert zählt nicht")
    open(os.path.join(a, "x"), "w").write("2")
    ok(len(befund([a])) == 1 and "1 Datei(en) geändert" in befund([a])[0], "geändert")
    ok(befund([d]) == [], "kein Repo")
    # 1898: nur Eigenes drängt zum Pushen
    tr = os.path.join(d, "t.jsonl")
    def spur(*bl):
        open(tr, "w").write("".join(json.dumps({"message": {"content": [{"type": "tool_use", "input": b}]}}) + "\n" for b in bl))
        return verlauf(tr)
    ok(len(befund([a], spur({"file_path": os.path.join(a, "x"), "old_string": "1"}))) == 1 and "geändert, nicht committet (x)" in befund([a], spur({"file_path": os.path.join(a, "x")}))[0], "1898 eigen über Edit")
    ok("geändert, nicht committet (x)" in befund([a], spur({"command": "sed -i s/1/2/ x"}))[0], "1898 eigen über Bash mit Dateinamen")
    b = befund([a], spur({"command": "ls"}))
    ok(len(b) == 1 and "fremd, nicht mitpushen (x)" in b[0] and "Rückschritt" not in b[0], "1898 fremd")
    run("git", "commit", "-qam", "2", cwd=a); run("git", "push", "-q", "origin", "HEAD:main", cwd=a)
    open(os.path.join(a, "x"), "w").write("1")
    b = befund([a], spur({"command": "ls"}))
    ok(len(b) == 1 and "Rückschritt auf alten Stand: x" in b[0], "1898 fremd als Rückschritt")
    os.makedirs(os.path.join(a, "docs")); open(os.path.join(a, "docs", "LISTE-VORGAENGE.md"), "w").write("a")
    run("git", "add", "docs", cwd=a); run("git", "commit", "-qm", "3", cwd=a); run("git", "push", "-q", "origin", "HEAD:main", cwd=a)
    open(os.path.join(a, "docs", "LISTE-VORGAENGE.md"), "w").write("b")
    b = befund([a], spur({"command": "python3 tools/vorgang.py stand 1 gebaut"}))
    ok(any("geändert, nicht committet (docs/LISTE-VORGAENGE.md)" in x for x in b), "1898 eigen über Schreiber vorgang.py")
    ok(any("geändert, nicht committet" in x and "LISTE-VORGAENGE" in x for x in befund([a], None)), "1898 ohne Verlauf alles eigen")
    ok(verlauf(os.path.join(d, "fehlt.jsonl")) is None, "1898 Verlauf fehlt → None")
    # 1921 (D350.1): lesende Aufrufe und meldung.sh machen nichts eigen; nur Fremdes hält nicht an
    run("git", "checkout", "--", "x", cwd=a)
    for c in ('tools/meldung.sh Jerry "1535: Stand"', "python3 tools/vorgang.py --rolle Spike", "python3 tools/vorgang.py --rolle Spike | head -40",
              "python3 tools/vorgang.py 1898", "python3 tools/vorgang.py auftrag 1 --datei a.md --pruefen", "cat docs/LISTE-VORGAENGE.md",
              "grep -n 1898 docs/LISTE-VORGAENGE.md | head", "git diff docs/LISTE-VORGAENGE.md"):
        art = []; b = befund([a], spur({"command": c}), art)
        ok(art == ["fremd"] and meldung(b, art) is None, "1921 lesend/meldung.sh nicht eigen, lässt durch: %s %s" % (c, b))
    for c in ("python3 tools/vorgang.py --rolle Spike stand 1 gebaut", "echo b > docs/LISTE-VORGAENGE.md", "sed -i s/a/b/ docs/LISTE-VORGAENGE.md",
              "cd x && python3 tools/vorgang.py neu T Spike M B"):
        art = []; b = befund([a], spur({"command": c}), art)
        ok(art == ["eigen"] and "committen und pushen" in (meldung(b, art) or ""), "1921 schreibend eigen: %s %s" % (c, b))
    open(os.path.join(a, "docs", "LISTE-VORGAENGE.md"), "w").write("c")
    run("git", "commit", "-qam", "4", cwd=a); run("git", "push", "-q", "origin", "HEAD:main", cwd=a)
    open(os.path.join(a, "docs", "LISTE-VORGAENGE.md"), "w").write("a")
    art = []; b = befund([a], spur({"command": 'tools/meldung.sh Jerry "x"'}), art)
    m = meldung(b, art) or ""
    ok(art == ["rueckschritt"] and "Rückschritt" in m and "committen und pushen" not in m and "nicht deins" in m, "1921 nur fremd mit Rückschritt: Hinweis ohne Pushen %s" % m)
    open(os.path.join(a, "x"), "w").write("1")
    art = []; b = befund([a], spur({"file_path": os.path.join(a, "x")}), art)
    ok("eigen" in art and "fremd" in " ".join(b) and "committen und pushen" in meldung(b, art), "1921 eigen und fremd: drängt nur zum Eigenen")
    print("GEPUSHT1739 %d Fehler" % f)
    return 1 if f else 0


if __name__ == "__main__":
    sys.exit(test() if "--test" in sys.argv else main())
