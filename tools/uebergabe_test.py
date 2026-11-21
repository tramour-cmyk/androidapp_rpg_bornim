# 1760: Übergabe mit Quittung und Frist (1727 Gesamtbild 3.3 Fassung 2 Nr. 8): Neustart während offener Übergabe, doppelter Wecker,
# Quittung und danach Tod, zwei Schreiber, Wecker während eines Zugs von 40 Minuten. Echtes Git mit nacktem origin und zwei Kopien.
# Aufruf: python3 tools/uebergabe_test.py
import os, re, subprocess, sys, tempfile
from concurrent.futures import ThreadPoolExecutor
WZ = os.path.join(os.path.dirname(os.path.abspath(__file__)), "uebergabe.py")
d = tempfile.mkdtemp(); o = os.path.join(d, "origin.git"); A = os.path.join(d, "a"); B = os.path.join(d, "b")
def g(*a, cwd=None): return subprocess.run(["git"] + list(a), cwd=cwd, check=True, capture_output=True, text=True).stdout
g("init", "-q", "--bare", "-b", "main", o)
g("clone", "-q", o, A); g("config", "user.email", "t@t", cwd=A); g("config", "user.name", "t", cwd=A)
os.makedirs(os.path.join(A, "docs")); g("checkout", "-q", "-b", "main", cwd=A)
open(os.path.join(A, "docs", "ARBEIT-BESETZUNG.md"), "w").write(
    "| Rolle | Sitzung | Vorgang | Zweig | seit |\n|---|---|---|---|---|\n| Tom | [Tom](https://claude.ai/code/session_TOM1) | 9001 | – | 21.11. |\n")
g("add", "-A", cwd=A); g("commit", "-q", "-m", "start", cwd=A); g("push", "-q", "origin", "main", cwd=A)
g("clone", "-q", o, B); g("config", "user.email", "t@t", cwd=B); g("config", "user.name", "t", cwd=B)
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))
def lauf(kopie, sid, zeit, *a):
    env = dict(os.environ, BORNIM_WURZEL=kopie, BORNIM_SITZUNG=sid, BORNIM_JETZT=zeit, GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t",
               GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t")
    env.pop("BORNIM_OHNE_PUSH", None)
    p = subprocess.run([sys.executable, WZ] + list(a), env=env, capture_output=True, text=True)
    return p.returncode, p.stdout + p.stderr
def datei():
    g("fetch", "-q", "origin", cwd=A); return g("show", "origin/main:docs/vorgang/9001.md", cwd=A)
def sitzungen(**st):
    p = os.path.join(d, "s.txt")
    open(p, "w").write("".join("%s | %s | 2026-11-21T19:00:00Z | x | - |\n" % (k, v) for k, v in st.items()) + "# has_more: nein\n")
    return p

# 1 Neustart während offener Übergabe: Empfänger nimmt nie an, neue Sitzung liest offene Zeilen ihres Bereichs
rc, t = lauf(A, "session_ABS", "21.11., 20:00", "uebergabe", "9001", "Tom", "Auftrag 9001-1 bauen")
soll("Übergabe offen, Wecker an laufende Sitzung aus der Besetzung", rc == 0 and "OFFEN 9001-Ü1" in t and "WECKER session_TOM1 | sieh in 9001 (9001-Ü1)" in t, t)
soll("Zeile steht auf origin/main", "| 9001-Ü1 | Tom | Auftrag 9001-1 bauen | 21.11., 20:00 | offen |" in datei(), datei())
soll("lokale Kopie nachgezogen", os.path.exists(os.path.join(A, "docs/vorgang/9001.md")))
rc, t = lauf(B, "session_NEU", "21.11., 20:10", "offen", "Tom")
soll("neue Sitzung sieht die offene Zeile", "9001-Ü1 | an Tom" in t and "1 Zeile" in t, t)
rc, t = lauf(B, "session_NEU", "21.11., 20:10", "annehmen", "9001-Ü1")
soll("neue Sitzung nimmt an", rc == 0 and t.startswith("ANGENOMMEN 9001-Ü1 (bis 21.11., 20:40)"), t)

# 2 doppelter Wecker: dieselbe Sitzung nimmt zweimal an → nichts neu beginnen; andere Sitzung → BELEGT
rc, t = lauf(A, "session_NEU", "21.11., 20:12", "annehmen", "9001-Ü1")
soll("doppelter Wecker: SCHON DEINE", rc == 0 and t.startswith("SCHON DEINE"), t)
rc, t = lauf(A, "session_TOM1", "21.11., 20:12", "annehmen", "9001-Ü1")
soll("alter Empfänger wacht spät auf: BELEGT, Exit 3", rc == 3 and t.startswith("BELEGT"), t)
soll("genau eine Quittung in der Datei", datei().count("angenommen session_NEU") == 1 and "session_TOM1 bis" not in datei(), datei())
rc, t = lauf(A, "session_TOM1", "21.11., 20:13", "erledigt", "9001-Ü1")
soll("erledigt nur der Halter", "NICHT DEINE" in t and "erledigt" not in datei().split("9001-Ü1")[1].split("\n")[0], t)
rc, t = lauf(B, "session_NEU", "21.11., 20:20", "erledigt", "9001-Ü1")
soll("Halter meldet erledigt", t.startswith("ERLEDIGT") and "erledigt 21.11., 20:20 session_NEU" in datei(), t)
rc, t = lauf(B, "session_NEU", "21.11., 20:21", "erledigt", "9001-Ü1")
soll("zweites erledigt: nichts", t.startswith("SCHON ERLEDIGT"), t)
rc, t = lauf(A, "session_X", "21.11., 20:22", "annehmen", "9001-Ü1")
soll("erledigte Zeile nicht wieder annehmbar", t.startswith("ERLEDIGT"), t)

# 3 Quittung und danach Tod: Frist läuft ab, Halter ruht → Stundenrunde macht die Zeile wieder offen
lauf(A, "session_ABS", "21.11., 20:30", "uebergabe", "9001", "Prüfer", "Auftrag 9001-1 prüfen")
rc, t = lauf(B, "session_TOT", "21.11., 20:31", "annehmen", "9001-Ü2")
rc, t = lauf(A, "session_ERS", "21.11., 21:10", "annehmen", "9001-Ü2")
soll("tote Sitzung: andere nimmt ohne Prüfung nicht an (BELEGT)", rc == 3, t)
rc, t = lauf(A, "session_DISP", "21.11., 21:10", "offen", "--sitzungen", sitzungen(session_TOT="idle"))
soll("Frist abgelaufen, Halter idle → wieder offen", "9001-Ü2" in t and "wieder offen" in t and "| 9001-Ü2 | Prüfer | Auftrag 9001-1 prüfen | 21.11., 20:30 | offen |" in datei(), t)
rc, t = lauf(A, "session_ERS", "21.11., 21:11", "annehmen", "9001-Ü2")
soll("Ersatzsitzung nimmt an", t.startswith("ANGENOMMEN"), t)

# 4 Wecker während eines Zugs von 40 Minuten: Frist abgelaufen, Halter working → es wird gewartet
lauf(A, "session_ABS", "21.11., 21:00", "uebergabe", "9001", "Tom", "Auftrag 9001-2 bauen")
lauf(B, "session_BAU", "21.11., 21:00", "annehmen", "9001-Ü3")
rc, t = lauf(A, "session_DISP", "21.11., 21:40", "offen", "--sitzungen", sitzungen(session_BAU="working"))
soll("Halter working nach 40 Minuten: bleibt angenommen", "arbeitet (warten)" in t and "angenommen session_BAU" in datei(), t)
rc, t = lauf(A, "session_DISP", "21.11., 21:40", "offen")
soll("ohne Sitzungsliste: nicht freigeben, Status unbekannt", "Status unbekannt" in t and "angenommen session_BAU" in datei(), t)
rc, t = lauf(A, "session_WECK", "21.11., 21:40", "annehmen", "9001-Ü3")
soll("zweiter Wecker an andere Sitzung: BELEGT", rc == 3, t)
rc, t = lauf(B, "session_BAU", "21.11., 21:41", "verlaengern", "9001-Ü3", "--frist", "60")
soll("Halter verlängert die Frist", t.startswith("VERLÄNGERT") and "angenommen session_BAU bis 21.11., 22:41" in datei(), t)

# 5 zwei Schreiber: 8 gleichzeitige Übergaben aus zwei Kopien, dann 6 gleichzeitige Quittungen auf dieselbe Zeile
with ThreadPoolExecutor(8) as ex:
    r = list(ex.map(lambda i: lauf(A if i % 2 else B, "session_S%d" % i, "21.11., 22:00", "uebergabe", "9001", "Jerry", "Teil %d" % i), range(8)))
ks = re.findall(r"\| (9001-Ü\d+) \| Jerry \| Teil (\d) ", datei())
soll("8 gleichzeitige Übergaben: alle da, Kennungen eindeutig", all(x[0] == 0 for x in r) and len(ks) == 8 and len({k for k, _ in ks}) == 8 and {n for _, n in ks} == set("01234567"), [x[1] for x in r if x[0]])
ziel = ks[0][0]
with ThreadPoolExecutor(6) as ex:
    r = list(ex.map(lambda i: lauf(A if i % 2 else B, "session_Q%d" % i, "21.11., 22:05", "annehmen", ziel), range(6)))
an = [t for _, t in r if t.startswith("ANGENOMMEN")]
soll("6 gleichzeitige Quittungen: genau eine ANGENOMMEN, Rest BELEGT", len(an) == 1 and sum(1 for c, t in r if c == 3) == 5, [t for _, t in r])

# Nachfolger: freigeben macht eigene Zeilen sofort wieder offen
rc, t = lauf(B, "session_BAU", "21.11., 22:10", "freigeben")
soll("freigeben vor Nachfolger", "FREIGEGEBEN: 1" in t and "| 9001-Ü3 | Tom | Auftrag 9001-2 bauen | 21.11., 21:00 | offen |" in datei(), t)
rc, t = lauf(A, "session_DISP", "21.11., 22:11", "offen")
reihen = [l.split(" | ")[0] for l in t.splitlines() if l.startswith("9001-Ü")]
soll("Büro-Liste nach Eingangszeit", reihen[:2] == ["9001-Ü2", "9001-Ü3"] and "9001-Ü3 | an Tom | Auftrag 9001-2 bauen | seit 21.11., 21:00 | offen" in t, t)
soll("Commits tragen nur die Vorgangsdatei", set(g("log", "--format=", "--name-only", "origin/main", "-n", "25", cwd=A).split()) <= {"docs/vorgang/9001.md", "docs/ARBEIT-BESETZUNG.md"})
print("uebergabe_test: %s" % ("grün" if not fehl else "%d Fehler" % fehl))
sys.exit(fehl)
