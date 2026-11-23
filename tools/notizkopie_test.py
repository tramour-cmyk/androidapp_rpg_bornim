#!/usr/bin/env python3
"""Test 1963: Notizkopie mit veraltetem vorgemerktem Stand räumt sich über notiz.sh selbst auf; Meldungen nennen nie den Chef.
Nachgestellt wie im Vorfall (Doris 22.11., 16:55): `git checkout -q -B main origin/main` in der Arbeitskopie, während die
Notizkopie main hält (git 2.43 lässt -B durch). Aufruf: python3 tools/notizkopie_test.py (Exit 1 bei Fehlern)."""
import importlib.util, json, os, re, shutil, subprocess, sys, tempfile, time

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


def zeile(aus):
    """Zeile von notizkopie.py in der Ausgabe von notiz.sh (Uhr und Kernregeln danach sind fester Text, 347)."""
    return next((z for z in aus.splitlines() if z.startswith("Bornim (1963)")), "")


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
    # Vorfall: `checkout -B main origin/main` in der Arbeitskopie setzte refs/heads/main um (git 2.43); ab 2.44 abgelehnt (1963-Ü12),
    # daher dieselbe Wirkung auf den Zweig mit update-ref (samt Reflog-Eintrag), unabhängig von der git-Version
    g(a, "fetch", "-q", "origin"); g(a, "update-ref", "-m", "checkout: moving from main to main", "refs/heads/main", "origin/main")


def neues_git(d):
    """1963-Ü12: git ab 2.44 (CI-Runner: 2.56.1, Lauf 45126240216) lehnt `checkout -B`/`switch -C` auf einen Zweig ab, den eine
    andere Arbeitskopie hält; lokal (2.43) geht es durch. Nachbildung als git vor dem echten im PATH, damit der Test überall gleich läuft."""
    echt = shutil.which("git"); w = os.path.join(d, "git")
    schreib(w, '''#!%s
import os, subprocess, sys
a, wo, i = sys.argv[1:], ".", 0
while i < len(a) and a[i] == "-C": wo, i = a[i + 1], i + 2
z = a[i + 1:]
for cmd, opt in (("checkout", "-B"), ("switch", "-C")):
    if a[i:i + 1] == [cmd] and opt in z and z.index(opt) + 1 < len(z):
        ich = subprocess.run([%r, "-C", wo, "rev-parse", "--show-toplevel"], capture_output=True, text=True).stdout.strip()
        wl = subprocess.run([%r, "-C", wo, "worktree", "list", "--porcelain"], capture_output=True, text=True).stdout.split("\\n\\n")
        if any("branch refs/heads/" + z[z.index(opt) + 1] in b.split("\\n") and b.split("\\n")[0] != "worktree " + ich for b in wl):
            sys.exit("fatal: Zweig wird von anderer Arbeitskopie benutzt (Nachbildung git >= 2.44)")
os.execv(%r, [%r] + a)
''' % (sys.executable, echt, echt, echt, echt))
    os.chmod(w, 0o755)
    os.environ["PATH"] = d + os.pathsep + os.environ["PATH"]


def kopie_test():
    neues_git(tempfile.mkdtemp())
    # Fall 1: nur veralteter Stand → nach notiz.sh sauber, Sicherung vorhanden
    d = tempfile.mkdtemp(); home = os.path.join(d, "h"); os.makedirs(home)
    o, q, a = aufbau(d); wt = os.path.join(d, "bornim-main")
    notiz(a, home)
    ok(os.path.isdir(wt) and g(wt, "status", "--porcelain") == "", "Notizkopie angelegt und sauber")
    weiter(q, a)
    ok(g(wt, "status", "--porcelain").strip() != "", "Vorfall nachgestellt: vorgemerkter Altstand")
    aus = zeile(notiz(a, home))
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
    aus = zeile(notiz(a, home))
    ok(g(wt, "status", "--porcelain", "--untracked-files=no").strip() == "M docs/b.md", "nur die junge Änderung bleibt: " + g(wt, "status", "--short"))
    ok(open(os.path.join(wt, "docs/b.md")).read() == "meins\n", "junge Änderung erhalten")
    ok("rueckmeldung" in aus and "Chef" not in aus, "Ausgabe zur jungen Änderung: Frage per Rückmeldung: " + aus)
    # Fall 3 (Sokrates 22.11., 20:06, 1963-Ü8): eigene Änderung, älter als 2 h, ohne Altstand des Index bleibt; Meldung, kein Reset
    d = tempfile.mkdtemp(); home = os.path.join(d, "h"); os.makedirs(home)
    o, q, a = aufbau(d); wt = os.path.join(d, "bornim-main"); notiz(a, home)
    p = os.path.join(wt, "docs/b.md"); schreib(p, "liegengeblieben\n"); t = time.time() - 3 * 3600; os.utime(p, (t, t))
    aus = zeile(notiz(a, home))
    ok(open(p).read() == "liegengeblieben\n" and "rueckmeldung" in aus and "Chef" not in aus, "Datei älter als 2 h bleibt: " + aus)
    g(wt, "checkout", "-q", "--", "docs/b.md")
    # Fall 4: Altstand entsteht mitten in der Sitzung → Stop-Haken räumt auf und hält nicht an
    weiter(q, a)
    r = subprocess.run([sys.executable, os.path.join(HIER, "gepusht-haken.py")], input="{}", capture_output=True, text=True,
                       env=dict(os.environ, CLAUDE_PROJECT_DIR=a), timeout=60)
    ok(r.returncode == 0 and g(wt, "status", "--porcelain", "--untracked-files=no") == "", "Stop-Haken räumt auf: %d %s" % (r.returncode, r.stderr))
    # Fall 5 (Pit 19:14, 1963-Ü3): junge eigene Löschung (git rm / rm) bleibt, auch neben veraltetem Stand
    d = tempfile.mkdtemp(); home = os.path.join(d, "h"); os.makedirs(home)
    o, q, a = aufbau(d); wt = os.path.join(d, "bornim-main"); notiz(a, home)
    g(wt, "rm", "-q", "docs/b.md")
    aus = zeile(notiz(a, home))
    ok(g(wt, "status", "--porcelain", "--untracked-files=no").strip() == "D  docs/b.md", "junge Löschung (git rm) bleibt: " + aus)
    g(wt, "reset", "-q", "--hard"); os.remove(os.path.join(wt, "docs/b.md"))
    aus = zeile(notiz(a, home))
    ok(g(wt, "status", "--porcelain", "--untracked-files=no").strip() == "D docs/b.md", "junge Löschung (rm) bleibt: " + aus)
    if os.path.exists(os.path.join(wt, "docs/b.md")): os.remove(os.path.join(wt, "docs/b.md"))
    weiter(q, a)
    aus = zeile(notiz(a, home))
    ok(g(wt, "status", "--porcelain", "--untracked-files=no").strip() == "D docs/b.md" and os.path.exists(os.path.join(wt, "docs/neu.md")),
       "Altstand weg, junge Löschung bleibt: %s | %s" % (g(wt, "status", "--short"), aus))
    # Fall 6 (Pit 19:14, 1963-Ü5): Umbenennung: beide Namen richtig, beide bleiben
    d = tempfile.mkdtemp(); home = os.path.join(d, "h"); os.makedirs(home)
    o, q, a = aufbau(d); wt = os.path.join(d, "bornim-main"); notiz(a, home)
    g(wt, "mv", "docs/b.md", "docs/c.md")
    aus = zeile(notiz(a, home))
    ok("docs/c.md" in aus and "docs/b.md" in aus and "s/b.md" not in aus.replace("docs/b.md", ""), "Umbenennung in der Meldung: " + aus)
    ok(os.path.exists(os.path.join(wt, "docs/c.md")) and not os.path.exists(os.path.join(wt, "docs/b.md")), "Umbenennung bleibt")
    # Fall 7: junge Änderung nur im Index (Datei wieder wie HEAD) bleibt; _blob() las den Index als „::pfad“, also nie
    d = tempfile.mkdtemp(); home = os.path.join(d, "h"); os.makedirs(home)
    o, q, a = aufbau(d); wt = os.path.join(d, "bornim-main"); notiz(a, home)
    schreib(os.path.join(wt, "docs/b.md"), "meins\n"); g(wt, "add", "docs/b.md"); schreib(os.path.join(wt, "docs/b.md"), "b\n")
    aus = zeile(notiz(a, home))
    ok(g(wt, "show", ":docs/b.md") == "meins\n", "junge Änderung im Index bleibt: " + aus)
    # Fall 8 (Ingo 20:00, 1963-Ü8): junge Löschung und Umbenennung einer auf main neuen Datei bleiben (allgemeiner Fall)
    d = tempfile.mkdtemp(); home = os.path.join(d, "h"); os.makedirs(home)
    o, q, a = aufbau(d); wt = os.path.join(d, "bornim-main"); notiz(a, home); weiter(q, a); notiz(a, home)
    ok(g(wt, "status", "--porcelain", "--untracked-files=no") == "", "Kopie sauber auf main mit docs/neu.md")
    g(wt, "rm", "-q", "docs/neu.md")
    aus = zeile(notiz(a, home))
    ok(g(wt, "status", "--porcelain", "--untracked-files=no").strip() == "D  docs/neu.md", "junge Löschung neuer Datei bleibt: " + aus)
    g(wt, "reset", "-q", "--hard"); os.makedirs(os.path.join(wt, "docs/archiv")); g(wt, "mv", "docs/neu.md", "docs/archiv/neu.md")
    aus = zeile(notiz(a, home))
    ok(not os.path.exists(os.path.join(wt, "docs/neu.md")) and os.path.exists(os.path.join(wt, "docs/archiv/neu.md")),
       "junge Umbenennung neuer Datei bleibt, nicht doppelt: %s | %s" % (g(wt, "status", "--short"), aus))
    ok(len(g(wt, "branch", "--list", "backup-notiz-*").split()) == 1, "nur die Sicherung des Altstands, keine für junge Änderungen")


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
    # zug-haken.py 343–345 (Pit 19:14, Prüffrage 5): Chefsache-Meldung ist seit 822 abgeschaltet (chef = None in main(),
    # zweites Beenden kehrt vor zweitstopp() zurück); belegt: Bitte an den Chef löst nie eine Meldung aus
    with tempfile.TemporaryDirectory() as d:
        env = dict(os.environ, BORNIM_REGELTREUE=os.path.join(d, "z.tsv"), BORNIM_HAKEN63=os.path.join(d, "s.json"))
        for aktiv in (False, True, True):
            e = {"session_id": "t", "stop_hook_active": aktiv, "last_assistant_message": "**Greta** [22.11., 19:50] Soll ich die Kopie zurücksetzen? Bitte bestätigen, Chef."}
            r = subprocess.run([sys.executable, os.path.join(HIER, "zug-haken.py")], input=json.dumps(e), capture_output=True, text=True, env=env, timeout=30)
            ok("Chef" not in r.stdout and "block" not in r.stdout, "zug-haken meldet (stop_hook_active=%s): %s" % (aktiv, r.stdout[:120]))


kopie_test()
meldungen_test()
print("NOTIZKOPIE1963 %d Fehler" % f)
sys.exit(1 if f else 0)
