#!/usr/bin/env python3
"""1739 (1727 Gesamtbild 7, G:909; werkzeuge.md B „Stop-Haken alles gepusht?“): Stop-Haken. Will die Sitzung ihren Zug beenden,
während in der Arbeitskopie (CLAUDE_PROJECT_DIR) oder der Notizkopie (../bornim-main) geänderte, nicht committete Dateien oder
Commits liegen, die auf keinem Zweig von origin stehen, hält er einmal an und nennt sie (CLAUDE.md „am Ende alles committen und
pushen“; Container werden abgeräumt). Beim zweiten Mal lässt er durch (stop_hook_active), also nie eine Schleife; wer begründet
wartet (Push abgewiesen, Chef fragt), beendet einfach noch einmal. Unversionierte Dateien zählen nicht (Probebilder, Zwischenstände).
Jeder Fehler lässt durch. Prüfen von Hand: gepusht-haken.py --test
Muster (erst nachsehen, wie andere es lösen): „git status“-Prompt mit ahead-Zähler (oh-my-zsh, starship) und pre-push/Shell-Exit-
Warnungen; hier dieselbe Zählung am Zugende.
"""
import json, os, subprocess, sys


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


def befund(wege):
    teile = []
    for wo in wege:
        o = offen(wo)
        if not o: continue
        g, n = o
        if g: teile.append("%s: %d Datei(en) geändert, nicht committet (%s)" % (wo, len(g), ", ".join(g[:4]) + (" …" if len(g) > 4 else "")))
        if n: teile.append("%s: %d Commit(s) nicht gepusht" % (wo, n))
    return teile


def main():
    try:
        e = json.load(sys.stdin)
        if e.get("stop_hook_active"): return 0
        t = befund(orte())
        if not t: return 0
        print("Gepusht? (1739, Gesamtbild 7): %s. Vor dem Zugende committen und pushen (Notizen direkt auf main, Code auf den Arbeitszweig); "
              "ist es gewollt (Push abgewiesen, wartet auf Chef), einfach noch einmal beenden." % "; ".join(t), file=sys.stderr)
        return 2
    except Exception:
        return 0


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
    print("GEPUSHT1739 %d Fehler" % f)
    return 1 if f else 0


if __name__ == "__main__":
    sys.exit(test() if "--test" in sys.argv else main())
