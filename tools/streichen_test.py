# 1688 (Chef 23.11., 08:38): `vorgang.py fertig NR` meldet jede Zeile „Zu NR, bis erledigt“ in Vorräten, Profilen und CLAUDE.md
# als Übergabe „streichen: Datei, Zeile“ an den Disponenten; lauf.py gibt offene Streichzeilen als erste Zeile aus.
# Echtes Git mit nacktem origin wie uebergabe_test.py. Aufruf: python3 tools/streichen_test.py
import os, subprocess, sys, tempfile
WZ = os.path.join(os.path.dirname(os.path.abspath(__file__)), "streichen.py")
d = tempfile.mkdtemp(); o = os.path.join(d, "origin.git"); A = os.path.join(d, "a")
def g(*a, cwd=None): return subprocess.run(["git"] + list(a), cwd=cwd, check=True, capture_output=True, text=True).stdout
g("init", "-q", "--bare", "-b", "main", o)
g("clone", "-q", o, A); g("config", "user.email", "t@t", cwd=A); g("config", "user.name", "t", cwd=A)
for p in ("docs/profile", "docs/vorgang"): os.makedirs(os.path.join(A, p))
def schreib(p, t): open(os.path.join(A, p), "w", encoding="utf-8").write(t)
schreib("docs/ARBEIT-BETRIEB.md", "# Betrieb\n\n- **Zu 9001, bis erledigt, streicht: Disponent.** Laufsperre\n- Zu 9001.2, bis erledigt, streicht: X\n- Zu 90011, bis erledigt\n")
schreib("docs/profile/Figur.md", "# Figur\nZu 9001, bis erledigt, streicht: Disponent: Umhang zuerst\n")
schreib("CLAUDE.md", "# Regeln\nZu 9002, bis erledigt: anderes\n")
schreib("docs/ARBEIT-BESETZUNG.md", "| Rolle | Sitzung | Vorgang | Zweig | seit |\n|---|---|---|---|---|\n| Disponent | [D](https://claude.ai/code/session_DISP) | – | – | 23.11. |\n")
g("checkout", "-q", "-b", "main", cwd=A); g("add", "-A", cwd=A); g("commit", "-q", "-m", "start", cwd=A); g("push", "-q", "origin", "main", cwd=A)
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))
def lauf(*a):
    env = dict(os.environ, BORNIM_WURZEL=A, BORNIM_SITZUNG="session_T", BORNIM_JETZT="23.11., 09:00", GIT_AUTHOR_NAME="t",
               GIT_AUTHOR_EMAIL="t@t", GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t")
    env.pop("BORNIM_OHNE_PUSH", None)
    p = subprocess.run([sys.executable, WZ] + list(a), env=env, capture_output=True, text=True)
    return p.returncode, p.stdout + p.stderr

rc, t = lauf("funde", "9001")
soll("genau die zwei Zeilen zu 9001 (nicht 9001.2, nicht 90011)", rc == 0 and t.count("streichen:") == 2
     and "docs/ARBEIT-BETRIEB.md, Zeile 3" in t and "docs/profile/Figur.md, Zeile 2" in t and "9001.2" not in t and "90011" not in t, t)
rc, t = lauf("melden", "9001")
v = g("show", "origin/main:docs/vorgang/9001.md", cwd=A)
soll("zwei Übergaben an den Disponenten auf origin/main", rc == 0 and v.count("| Disponent | streichen: ") == 2 and "9001-Ü2" in v, t + v)
soll("Wecker an den Disponenten", "WECKER session_DISP | sieh in 9001" in t, t)
rc, t = lauf("melden", "9001")
v = g("show", "origin/main:docs/vorgang/9001.md", cwd=A)
soll("zweites Melden legt nichts doppelt an", rc == 0 and v.count("| Disponent | streichen: ") == 2 and "9001-Ü3" not in v, t + v)
rc, t = lauf("melden", "9003")
soll("ohne Fund keine Übergabe, keine Datei", rc == 0 and "keine Zeile" in t and not os.path.exists(os.path.join(A, "docs/vorgang/9003.md")), t)
rc, t = lauf("lauf", os.path.join(A, "docs"))
z = t.splitlines()
soll("lauf: offene Streichzeilen als STREICHEN", rc == 0 and len(z) == 2 and all(l.startswith("STREICHEN 9001-Ü") for l in z), t)
rc, t = lauf("annehmen-und-erledigen-test")  # unbekannter Befehl: Hilfe, Exit 2
soll("unbekannter Befehl hält an", rc == 2, t)
sys.path.insert(0, os.path.dirname(WZ)); import streichen
reihe = streichen.zuerst(["START Figur | x", "NICHTS a", "STREICHEN 9001-Ü1 | streichen: y"])
soll("zuerst: STREICHEN vor allen anderen Zeilen", reihe[0].startswith("STREICHEN") and reihe[1].startswith("START"), reihe)
print("%d Fehler" % fehl); sys.exit(1 if fehl else 0)
