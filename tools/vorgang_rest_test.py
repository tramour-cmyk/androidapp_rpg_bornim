# 1240: Prüfung zu rest_offen („Kein Folgevorgang, weil:“ deckt ältere Commits, Zitat nicht, jüngere Reste zählen). Aufruf: python3 tools/vorgang_rest_test.py
import os, subprocess, sys, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import vorgang
d = tempfile.mkdtemp(); g = lambda *a: subprocess.run(["git", "-C", d] + list(a), check=True, capture_output=True)
g("init", "-q"); g("config", "user.email", "t@t"); g("config", "user.name", "t")
n = [0]
def c(datei, msg):
    n[0] += 1; os.makedirs(os.path.join(d, os.path.dirname(datei)), exist_ok=True)
    os.environ["GIT_COMMITTER_DATE"] = "2026-01-01T00:%02d:00" % n[0]
    open(os.path.join(d, datei), "a").write("x\n"); g("add", "-A"); g("commit", "-q", "--date", "2026-01-01T00:%02d:00" % n[0], "-m", msg)
    os.environ["GIT_COMMITTER_DATE"] = "2026-01-01T00:%02d:00" % n[0]
vorgang._repos = lambda: [d]
vorgang.startbar.lesen = lambda p: ""; vorgang.startbar.zeilen_liste = lambda: []
R = lambda: [f[1] for f in vorgang.rest_offen("9001", {"besitzer": "Tom"})]
fehl = 0
def soll(name, ist, erwartet):
    global fehl; ok = bool(ist) == erwartet; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ist)
c("tools/a", "9001: Code, Höhle noch nicht gebaut");           soll("Rest im Code-Commit", R(), True)
c("tools/a", "9001: Code ohne Rest");                          soll("älterer Rest zählt weiter (1237)", R(), True)
c("docs/x", "9001: Zitat „Kein Folgevorgang, weil: …“ im Text"); soll("Zitat hebt nicht auf", R(), True)
c("docs/x", "9001: Kein Folgevorgang, weil: Höhle kommt mit 9002"); soll("Grund im Notizcommit deckt ältere", R(), False)
c("tools/a", "9001: neuer Code\n\nbraucht noch Licht");         soll("jüngerer Rest nach dem Grund zählt", R(), True)
c("tools/a", "9001: nachgezogen\n\nKein Folgevorgang, weil: Licht ist Kür (9003)"); soll("Grund im Rumpf", R(), False)
sys.exit(fehl)
