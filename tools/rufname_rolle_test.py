# 1957 (Fund Ford 22.11., 16:23): Rufnamen-Sitzungen gehören der Rolle ihres STARTs, nicht dem Besitzer des Vorgangs im Titel.
# Rufname → Rolle steht in der Startsperre („… (lauf.py, Arbeitsplaner 1727 Anna, …)“), lauf.py liest sie zurück.
# Aufruf: python3 tools/rufname_rolle_test.py
import datetime, os, shutil, sys, tempfile
HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import rufname, kosten, lauf

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))

B = lauf.BERLIN
J = datetime.datetime(2026, 11, 22, 16, 33, tzinfo=B)
lauf.JETZT = J
D = tempfile.mkdtemp()
PROT = ("# Betrieb\n\n## Protokoll\n\nEine Zeile je Lauf.\n\n"
        "- 16:18 22.11.: Startsperre 16:18 Start Arbeitsplaner, Arbeitsplaner, Tagesbericht (lauf.py, Arbeitsplaner 1727 Anna, Arbeitsplaner 1570 Britta, Tagesbericht 448)\n"
        "- 16:20 22.11.: Startsperre 16:20 Start Prüfer (lauf.py, Prüfer 1957 Carla)\n"
        "- 10:00 21.11.: Startsperre 10:00 Start Werkzeug (lauf.py, Werkzeug 1800 Anna)\n"
        "- 10:01 21.11.: Startsperre 10:01 Start Homer (lauf.py, 1900)\n"
        "- 10:00 20.11.: Startsperre 10:00 Start Figur (lauf.py, Figur 1700 Dana)\n")
BETRIEB = os.path.join(D, "ARBEIT-BETRIEB.md")
open(BETRIEB, "w", encoding="utf-8").write(PROT)
rufname.BETRIEB = BETRIEB
lauf.DOCS = D

KURZ = """# has_more: nein
session_A | working | 2026-11-22T15:30:00Z | Anna – Auftrag 1727 (22.11., 16:19) | 1.20 | 2026-11-22T15:19:00Z
session_B | working | 2026-11-22T15:30:00Z | Britta – Auftrag 1570 (22.11., 16:19) | 0.90 | 2026-11-22T15:19:00Z
session_C | working | 2026-11-22T15:30:00Z | Carla – 1957 (22.11., 16:20) | 0.70 | 2026-11-22T15:21:00Z
session_G | idle | 2026-11-21T10:30:00Z | Anna – 1800: gestern (21.11., 10:00) | 2.00 | 2026-11-21T09:00:00Z
session_S | idle | 2026-11-22T10:30:00Z | Spike – 1739: alt (22.11., 10:00) | 1.00 | 2026-11-22T09:00:00Z
"""
ss = {s["id"]: s for s in kosten.kurzzeilen(KURZ)}
def kr(t, c):
    try: return kosten.rolle(t, c)
    except TypeError: return kosten.rolle(t)  # vor 1957 nur der Titel
def r(i): return kr(ss[i]["title"], ss[i]["created_at"])
rr = getattr(rufname, "rolle", lambda t, c: "fehlt")

# Rolle aus der Startsperre
soll("rufname.rolle: Anna → Arbeitsplaner", rr(ss["session_A"]["title"], ss["session_A"]["created_at"]) == "Arbeitsplaner",
     rr(ss["session_A"]["title"], ss["session_A"]["created_at"]))
soll("kosten.rolle: Anna → Arbeitsplaner (nicht Sonstige)", r("session_A") == "Arbeitsplaner", r("session_A"))
soll("kosten.rolle: Britta → Arbeitsplaner", r("session_B") == "Arbeitsplaner", r("session_B"))
soll("kosten.rolle: Carla → Prüfer (nicht Besitzer von 1957)", r("session_C") == "Prüfer", r("session_C"))
soll("kosten.rolle: Anna von gestern → Werkzeug (Tag zählt)", r("session_G") == "Werkzeug", r("session_G"))
soll("kosten.rolle: alter Rollentitel unverändert", r("session_S") == "Spike", r("session_S"))
soll("kosten.rolle: ohne created_at alter Weg", kosten.rolle("Spike – 1739: alt") == "Spike")
soll("rufname.rolle: Rufname ohne Startsperre → None", rr("Elke – 1957: x", "2026-11-22T15:19:00Z") is None)

# angekommen: Startprüfung 837 findet die Rufnamen-Sitzungen
soll("start_angekommen Arbeitsplaner 16:18", lauf.start_angekommen("Arbeitsplaner", J.replace(hour=16, minute=18), ss))
soll("start_angekommen Prüfer 16:20", lauf.start_angekommen("Prüfer", J.replace(hour=16, minute=20), ss))

# belegt: laufende Planer schreiben 1727 und 1570, kein zweiter START dafür
lauf.PLANER = "Arbeitsplaner"
for s in ss.values(): s.setdefault("status_bucket", "")
soll("planer_in_arbeit: 1727, 1570", hasattr(lauf, "planer_in_arbeit") and lauf.planer_in_arbeit(ss.values()) == {"1727", "1570"},
     lauf.planer_in_arbeit(ss.values()) if hasattr(lauf, "planer_in_arbeit") else "fehlt")

# Kosten auf die Nummer im Titel
soll("Kosten: Carla auf 1957", lauf.nummer_aus_titel(ss["session_C"]["title"]) == "1957")
soll("Kosten: Anna auf 1727", lauf.nummer_aus_titel(ss["session_A"]["title"]) == "1727")

# Startsperre: je START Rolle, Nummer, Rufname; zweiter Planer mit eigener Nummer
sperren, sperr_nr = ["Arbeitsplaner"], {"Arbeitsplaner": "1727"}
if hasattr(lauf, "sperr_dazu"):
    lauf.sperr_dazu(sperren, sperr_nr, "Arbeitsplaner", "1570")
else:
    sperren.append("Arbeitsplaner"); sperr_nr.setdefault("Arbeitsplaner", "1570")  # bisheriger Weg (zweiter_planer)
sperren.append("Tagesbericht"); sperr_nr["Tagesbericht"] = "448"
namen = {}
aus = lauf.mit_rufnamen([
    "START Arbeitsplaner | opus | e | r | main | Arbeitsplaner – Auftrag 1727 (22.11., 16:18) | Arbeitsplaner",
    "START Arbeitsplaner | opus | e | r | main | Arbeitsplaner 2 – Auftrag 1570 (22.11., 16:18) | Arbeitsplaner",
    "START Tagesbericht | opus | e | r | main | Tagesbericht – 448 (22.11., 16:18) | x"], [], J, **({"namen": namen} if "namen" in lauf.mit_rufnamen.__code__.co_varnames else {}))
rufname._SPERRE[rufname.DOCS] = set()
try: z = lauf.startsperre_zeile(sperren, sperr_nr, J, rufnamen=namen)
except TypeError: z = lauf.startsperre_zeile(sperren, sperr_nr, J)
soll("Startsperre: zwei Planer, zwei Nummern, Rufnamen",
     z == "- 16:33 22.11.: Startsperre 16:33 Start Arbeitsplaner, Arbeitsplaner, Tagesbericht (lauf.py, Arbeitsplaner 1727 Anna, Arbeitsplaner 1570 Britta, Tagesbericht 448)", z)
soll("Titel bleibt „Rufname statt Rolle“", aus[1].split(" | ")[5] == "Britta – Auftrag 1570 (22.11., 16:18)", aus[1])
soll("Startsperre ohne Rufnamen wie bisher (eine Rolle)", lauf.startsperre_zeile(["Homer"], {"Homer": "1900"}, J) == "- 16:33 22.11.: Startsperre 16:33 Start Homer (lauf.py, 1900)")
soll("Startsperre ohne Rufnamen wie bisher (zwei Rollen)", lauf.startsperre_zeile(["Tom", "Jerry"], {"Tom": "1", "Jerry": "2"}, J).endswith("(lauf.py, Tom 1, Jerry 2)"))
# neue Zeile wird von startsperren() (Rollen) und von rufname.rolle (Namen) gelesen
open(BETRIEB, "a", encoding="utf-8").write(z + "\n")
soll("startsperren liest neue Zeile", ("Arbeitsplaner", J.replace(second=0, microsecond=0)) in lauf.startsperren())

# --aufraeumen behält Startsperren mit Rufnamen von heute und gestern, ältere und gestrige ohne Rufname wie bisher
import vorgang
vorgang.ordnen = lambda: 0
open(os.path.join(D, "LISTE-VORGAENGE.md"), "w").write("# Liste\n")
open(BETRIEB, "w", encoding="utf-8").write(PROT)
lauf.aufraeumen()
t = open(BETRIEB, encoding="utf-8").read()
soll("aufraeumen: Rufnamen-Sperre von gestern bleibt", "Werkzeug 1800 Anna" in t, t)
soll("aufraeumen: Rufnamen-Sperre von heute bleibt", "Prüfer 1957 Carla" in t)
soll("aufraeumen: Sperre von vorgestern fällt", "Figur 1700 Dana" not in t)
soll("aufraeumen: gestrige Sperre ohne Rufname fällt wie bisher", "Start Homer" not in t)

shutil.rmtree(D, ignore_errors=True)
print("rufname_rolle_test: %s" % ("grün" if not fehl else "%d rot" % fehl))
sys.exit(1 if fehl else 0)
