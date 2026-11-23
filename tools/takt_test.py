# 1978: Laufsperre und Nachtruhe halten nur START an, lauf.py läuft jeden Takt; Alarm nennt den Disponenten. Ohne Git, ohne Netz.
# Aufruf: python3 tools/takt_test.py
import datetime, os, sys, types
T = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, T); sys.argv = sys.argv[:1]
import guthaben, herzschlag, lauf
SATZ = "lauf.py jeden Takt, nur START-Zeilen ruhen"
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))

# Laufsperre-Zeile von guthaben.py
J = datetime.datetime(2026, 11, 22, 12, 0, tzinfo=guthaben.BERLIN)
A = "- **1900, Laufsperre** (22.11., 10:30, Chef an Sokrates: „weniger laufen“) → **Laufsperre: höchstens zwei Starts, spätestens 18:00** (Umfang Sokrates)\n"
b = guthaben.Bremse(J, "", archiv=A, protokoll=[], rueck=lambda n: False)
z = [l for l in b.zeilen() if l.startswith("LAUFSPERRE")]
soll("LAUFSPERRE-Zeile nennt den Satz", z and SATZ in z[0], z)
# Nachtstopp von lauf.py (1643)
alt = sys.modules.get("nachtstarts")
sys.modules["nachtstarts"] = types.SimpleNamespace(angehalten=lambda r, n: True, grenze=lambda r, n: (None, 2), GRENZE=2)
aus, morgen = [], []
try: lauf.nacht_halt("Tom", "1631", aus, morgen)
finally:
    if alt is None: sys.modules.pop("nachtstarts", None)
    else: sys.modules["nachtstarts"] = alt
soll("Nachtstopp-Zeile nennt den Satz", aus and SATZ in aus[0], aus)
# Alarm von herzschlag.py
rc, a = herzschlag.pruefen("**Stand:** 21.11., 17:40 (lauf.py)", datetime.datetime(2026, 11, 21, 20, 48, tzinfo=herzschlag.BERLIN))
soll("Alarm nennt Disponent, nicht Ford", rc == 2 and "Disponent hängt oder fehlt" in a and "Disponent neu starten" in a and "Ford" not in a, a)
# Warnung „Start nicht angekommen“ und Erklärung GUTHABEN/LAUFSPERRE in lauf.py
q = open(os.path.join(T, "lauf.py"), encoding="utf-8").read()
w = [l for l in q.splitlines() if "nicht angekommen: Startsperre" in l]
soll("Warnung Startsperre nennt Disponent", w and "Disponent: START ausführen" in w[0] and "Ford" not in w[0], w)
e = [l for l in q.splitlines() if l.startswith("  GUTHABEN … / LAUFSPERRE …")]
soll("Erklärung LAUFSPERRE: Satz und Disponent", e and SATZ in e[0] and "Disponent startet nicht" in e[0] and "Ford" not in e[0], e)
# Profil Disponent (Quelle und erzeugte Datei) im Abschnitt Takt
for p in ("docs/entwurf/1727-muster/profil-disponent.md", "docs/profile/Disponent.md"):
    try: t = [l for l in open(os.path.join(T, "..", p), encoding="utf-8").read().splitlines() if l.startswith("**Takt.**")]
    except OSError: t = []
    soll("Profil %s: Takt nennt den Satz" % p, t and SATZ in t[0], t)
print("takt_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
