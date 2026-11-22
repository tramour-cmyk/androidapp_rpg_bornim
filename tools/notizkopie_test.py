#!/usr/bin/env python3
"""Test 1963: Notizkopie mit veraltetem vorgemerktem Stand räumt sich über notiz.sh selbst auf; Meldungen nennen nie den Chef.
Nachgestellt wie im Vorfall (Doris 22.11., 16:55): `git checkout -q -B main origin/main` in der Arbeitskopie, während die
Notizkopie main hält (git 2.43 lässt -B durch). Aufruf: python3 tools/notizkopie_test.py (Exit 1 bei Fehlern)."""
import importlib.util, os, re, shutil, subprocess, sys, tempfile, time

HIER = os.path.dirname(os.path.abspath(__file__))
f = 0


def ok(b, was):
    global f
    if not b: f += 1; print("FEHLER", was)


def g(wo, *a):
    return subprocess.run(["git", "-C", wo] + list(a), capture_output=True, text=True).stdout


def schreib(p, t):
    os.makedirs(os.path.dirname(p), exist_ok=True)
    open(p, "w").write(t)


def notiz(arbeit, home):
    env = {k: v for k, v in os.environ.items() if not k.startswith("GIT_") and k != "CLAUDE_CODE_ACCOUNT_UUID"}
    env.update(HOME=home, GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t", GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t")
    return subprocess.run(["bash", os.path.join(arbeit, "tools", "notiz.sh"), "--kurz"], capture_output=True, text=True, env=env,
                          timeout=120).stdout


def aufbau(d):
    """origin, Quelle, Arbeitskopie mit Notizkopie daneben; dann main weiter und `checkout -B main` in der Arbeitskopie."""
    o, q, a = (os.path.join(d, x) for x in ("o.git", "q", "arbeit"))
    subprocess.run(["git", "init", "-q", "--bare", "-b", "main", o])
    subprocess.run(["git", "clone", "-q", o, q], capture_output=True)
    for k, v in (("user.name", "t"), ("user.email", "t@t")): g(q, "config", k, v)
    os.makedirs(os.path.join(q, "tools"))
    for n in ("notiz.sh", "notizkopie.py", "kernregeln.txt"):
        if os.path.exists(os.path.join(HIER, n)): shutil.copy(os.path.join(HIER, n), os.path.join(q, "tools", n))
    schreib(os.path.join(q, "docs/a.md"), "alt\n"); schreib(os.path.join(q, "docs/b.md"), "b\n"); schreib(os.path.join(q, "docs/weg.md"), "weg\n")
    g(q, "add", "-A"); g(q, "commit", "-qm", "1"); g(q, "push", "-q", "origin", "main")
    subprocess.run(["git", "clone", "-q", o, a], capture_output=True)
    g(a, "checkout", "-q", "--detach")
    return o, q, a


def weiter(q, a):
    schreib(os.path.join(q, "docs/a.md"), "neu\n"); schreib(os.path.join(q, "docs/neu.md"), "neu\n"); g(q, "rm", "-q", "docs/weg.md")
    g(q, "add", "-A"); g(q, "commit", "-qm", "2"); g(q, "push", "-q", "origin", "main")
    g(a, "fetch", "-q", "origin"); g(a, "checkout", "-q", "-B", "main", "origin/main"); g(a, "checkout", "-q", "--detach")


def kopie_test():
    # Fall 1: nur veralteter Stand → nach notiz.sh sauber, Sicherung vorhanden
    d = tempfile.mkdtemp(); home = os.path.join(d, "h"); os.makedirs(home)
    o, q, a = aufbau(d); wt = os.path.join(d, "bornim-main")
    notiz(a, home)
    ok(os.path.isdir(wt) and g(wt, "status", "--porcelain") == "", "Notizkopie angelegt und sauber")
    weiter(q, a)
    ok(g(wt, "status", "--porcelain").strip() != "", "Vorfall nachgestellt: vorgemerkter Altstand")
    aus = notiz(a, home)
    ok(g(wt, "status", "--porcelain", "--untracked-files=no") == "", "nach notiz.sh sauber: " + g(wt, "status", "--short"))
    b = [x.strip() for x in g(wt, "branch", "--list", "backup-notiz-*").split()]
    ok(len(b) == 1, "Sicherungszweig vorhanden")
    ok(b and g(wt, "show", b[0] + ":docs/a.md") == "alt\n", "Sicherung enthält den alten Stand")
    ok(open(os.path.join(wt, "docs/a.md")).read() == "neu\n" and os.path.exists(os.path.join(wt, "docs/neu.md")), "Kopie auf main")
    ok("backup-notiz-" in aus and "Chef" not in aus, "Ausgabe nennt Sicherung, nie den Chef: " + aus)
    # Fall 2: dazu eine junge eigene Änderung → bleibt erhalten, Altes weg
    d = tempfile.mkdtemp(); home = os.path.join(d, "h"); os.makedirs(home)
    o, q, a = aufbau(d); wt = os.path.join(d, "bornim-main")
    notiz(a, home); weiter(q, a)
    schreib(os.path.join(wt, "docs/b.md"), "meins\n")
    aus = notiz(a, home)
    ok(g(wt, "status", "--porcelain", "--untracked-files=no").strip() == "M docs/b.md", "nur die junge Änderung bleibt: " + g(wt, "status", "--short"))
    ok(open(os.path.join(wt, "docs/b.md")).read() == "meins\n", "junge Änderung erhalten")
    ok("rueckmeldung" in aus and "Chef" not in aus, "Ausgabe zur jungen Änderung: Frage per Rückmeldung: " + aus)
    # Fall 3: alte Datei (älter als 2 h) mit neuem Inhalt gilt als alt
    d = tempfile.mkdtemp(); home = os.path.join(d, "h"); os.makedirs(home)
    o, q, a = aufbau(d); wt = os.path.join(d, "bornim-main"); notiz(a, home)
    p = os.path.join(wt, "docs/b.md"); schreib(p, "liegengeblieben\n"); t = time.time() - 3 * 3600; os.utime(p, (t, t))
    notiz(a, home)
    ok(g(wt, "status", "--porcelain", "--untracked-files=no") == "", "Datei älter als 2 h zurückgesetzt")


def lade(n):
    s = importlib.util.spec_from_file_location(n.replace("-", "_"), os.path.join(HIER, n)); m = importlib.util.module_from_spec(s)
    s.loader.exec_module(m); return m


def meldungen_test():
    """Systemfrage (Auftrag 2): Meldungen der Haken und von notiz.sh, die zu Reset/Stash raten oder Fragen auslösen, nennen nie den
    Chef und weisen auf `vorgang.py rueckmeldung`."""
    gh = lade("gepusht-haken.py")
    for art in (["eigen"], ["rueckschritt"], ["commit"]):
        m = gh.meldung(["x: 1 Datei"], art) or ""
        ok("Chef" not in m and "rueckmeldung" in m, "gepusht-haken %s: %s" % (art, m))
    sp = lade("sperre-haken.py")
    ok("Chef" not in sp.MELDUNG and "rueckmeldung" in sp.MELDUNG, "sperre-haken Meldung")
    for b in ("git checkout -q -B main origin/main", "cd /home/user/androidapp_rpg_bornim && git checkout -B main origin/main",
              "git switch -C main origin/main", "git branch -f main origin/main"):
        ok("1963" in (sp.grund_bash(b, "/home/user/androidapp_rpg_bornim") or ""), "Sperre main umsetzen: " + b)
    for b in ("git -C /home/user/bornim-main checkout -q -B main origin/main", "git checkout -b claude/x origin/main", "git checkout main"):
        ok(sp.grund_bash(b, "/home/user/androidapp_rpg_bornim") is None, "erlaubt: " + b)
    for z in open(os.path.join(HIER, "notiz.sh"), encoding="utf-8"):
        if "echo" in z and re.search(r"reset|stash|rueckmeldung|Chef", z) and not z.lstrip().startswith("#"):
            ok("Chef" not in z, "notiz.sh nennt den Chef: " + z.strip()[:80])
            ok(re.search(r"reset|stash", z) is None or "rueckmeldung" in z or "1701" in z, "notiz.sh rät zu Reset/Stash ohne Rückmeldung: " + z.strip()[:80])


kopie_test()
meldungen_test()
print("NOTIZKOPIE1963 %d Fehler" % f)
sys.exit(1 if f else 0)
