#!/usr/bin/env python3
"""1997 A (Chef 23.11., 13:56): jeder vollständige Lauf von `lauf.py`, auch ohne Schalter, erneuert die Zeitmarke in
ARBEIT-BESETZUNG.md und pusht sie selbst. Test: Kopie von tools/ und docs/ in ein Wegwerf-Repo mit eigenem origin (nackt, lokal),
Zeitmarke 3 h alt, `lauf.py --ohne-pull SEITE` ohne Schalter; danach `herzschlag.py` auf dem Stand von origin/main: ok, nicht ALARM.
Ohne Netz; nichts geht an das echte origin. Aufruf: python3 tools/lauf_herzschlag_test.py"""
import datetime, glob, os, re, shutil, subprocess, sys, tempfile
from zoneinfo import ZoneInfo

H = os.path.dirname(os.path.abspath(__file__)); W = os.path.dirname(H)
BERLIN = ZoneInfo("Europe/Berlin")
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else str(zeige)[-1500:]))

d = tempfile.mkdtemp(prefix="lauf-herzschlag-")
A = os.path.join(d, "A"); O = os.path.join(d, "origin.git")
ENV = dict(os.environ, GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t", GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t",
           BORNIM_WARN_STAND=os.path.join(d, "warn.json"), BORNIM_MELDUNGEN=os.path.join(d, "meldungen.tsv"),
           BORNIM_SITZUNG="session_test1997")
for k in ("BORNIM_WURZEL", "BORNIM_OHNE_PUSH", "BORNIM_JETZT", "GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE"): ENV.pop(k, None)
def g(*a, cwd=A):
    return subprocess.run(["git"] + list(a), cwd=cwd, env=ENV, capture_output=True, text=True)
try:
    open(ENV["BORNIM_MELDUNGEN"], "w").close()
    os.makedirs(os.path.join(A, "tools"))
    shutil.copytree(os.path.join(W, "docs"), os.path.join(A, "docs"))
    for p in glob.glob(os.path.join(H, "*")):
        if os.path.isfile(p): shutil.copy2(p, os.path.join(A, "tools"))
    jetzt = datetime.datetime.now(BERLIN); alt = jetzt - datetime.timedelta(hours=3)
    b = os.path.join(A, "docs", "ARBEIT-BESETZUNG.md")
    t = open(b, encoding="utf-8").read()
    t = re.sub(r"\*\*Stand:\*\*[^\n]*", "**Stand:** %s (lauf.py)" % alt.strftime("%d.%m., %H:%M"), t, count=1)
    open(b, "w", encoding="utf-8").write(t)
    g("init", "-q", "--bare", "-b", "main", O, cwd=d)
    g("init", "-q", "-b", "main"); g("add", "-A"); g("commit", "-q", "-m", "Stand"); g("remote", "add", "origin", O); g("push", "-q", "origin", "main")
    g("branch", "-q", "-u", "origin/main")
    seite = os.path.join(d, "seite.txt"); open(seite, "w", encoding="utf-8").write("# has_more: nein\n")
    vorher = subprocess.run([sys.executable, os.path.join(A, "tools", "herzschlag.py"), "--datei", b], capture_output=True, text=True, env=ENV)
    soll("vorher: Marke 3 h alt gibt ALARM", vorher.returncode == 2 and "ALARM" in vorher.stdout, vorher.stdout)
    r = subprocess.run([sys.executable, os.path.join(A, "tools", "lauf.py"), "--ohne-pull", seite], cwd=A, env=ENV, capture_output=True, text=True, timeout=600)
    soll("lauf.py ohne Schalter endet ohne Absturz", r.returncode == 0 and "Traceback" not in r.stderr, r.stderr or r.stdout)
    o = g("show", "main:docs/ARBEIT-BESETZUNG.md", cwd=O).stdout
    f = os.path.join(d, "besetzung-origin.md"); open(f, "w", encoding="utf-8").write(o)
    h = subprocess.run([sys.executable, os.path.join(A, "tools", "herzschlag.py"), "--datei", f], capture_output=True, text=True, env=ENV)
    soll("nachher: herzschlag.py auf origin/main ok (nicht ALARM)", h.returncode == 0 and "HERZSCHLAG ok" in h.stdout, h.stdout + "\n" + r.stdout[-800:])
    soll("lauf.py meldet den Push der Zeitmarke", "HERZSCHLAG gepusht" in r.stdout, r.stdout[-800:])
    # --besetzung bleibt erlaubt, ohne eigene Wirkung: zweiter Lauf mit Schalter endet ebenso
    r2 = subprocess.run([sys.executable, os.path.join(A, "tools", "lauf.py"), "--ohne-pull", "--besetzung", seite], cwd=A, env=ENV, capture_output=True, text=True, timeout=600)
    soll("lauf.py --besetzung bleibt erlaubt", r2.returncode == 0 and "Traceback" not in r2.stderr, r2.stderr)
finally:
    shutil.rmtree(d, ignore_errors=True)
print("lauf_herzschlag_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
