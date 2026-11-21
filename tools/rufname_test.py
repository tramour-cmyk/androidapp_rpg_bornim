# 1739 Rufnamen: Vergabe A, B, C je Berliner Tag, nie doppelt, Sperrliste (alte Rollen, Spielfiguren), Titelform, Bereich
# über den Besitzer des Vorgangs im Titel. Aufruf: python3 tools/rufname_test.py
import datetime, os, sys, tempfile
HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import rufname as rn

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))

leer = tempfile.mkdtemp()  # Docs ohne Figuren: nur alte Rollen gesperrt
J = datetime.datetime(2026, 11, 21, 21, 30, tzinfo=rn.BERLIN)

soll("erster des Tages: A", rn.naechster([], leer) == "Anna", rn.naechster([], leer))
soll("zweiter: B", rn.naechster(["Anna"], leer) == "Britta")
soll("dritter: C", rn.naechster(["Anna", "Britta"], leer) == "Carla")
soll("nach Z wieder A, zweiter Name", rn.naechster(["Anna", "Britta"] + ["X%d" % i for i in range(21)], leer) == "Arne",
     rn.naechster(["Anna", "Britta"] + ["X%d" % i for i in range(21)], leer))
alle = [n for ns in rn.NAMEN.values() for n in ns]
soll("Liste voll: None", rn.naechster(alle, leer) is None)
soll("keine alte Rolle in der Liste", not (rn.ALLE & rn.ALTE_ROLLEN))

fig = tempfile.mkdtemp()
open(os.path.join(fig, "LISTE-FIGUREN.md"), "w").write("| Anna die Müllerin | … |\n")
open(os.path.join(fig, "STORY-K9.md"), "w").write("„Arne kommt nicht.“ Annabell bleibt.\n")
soll("Spielfigur gesperrt (LISTE-FIGUREN, STORY-*)", rn.sperrliste(fig) == {"Anna", "Arne"}, rn.sperrliste(fig))
soll("gesperrter Name übersprungen", rn.naechster([], fig) == "Alma")
soll("Teilwort sperrt nicht (Annabell)", "Alma" not in rn.sperrliste(fig))

soll("aus_titel Rufname", rn.aus_titel("Anna – 1739: Werkzeuge (21.11., 21:30)") == "Anna")
soll("aus_titel alte Rolle: None", rn.aus_titel("Spike – 1739: Werkzeuge") is None)
soll("aus_titel Sokrates: None", rn.aus_titel("Sokrates – 1763 C: offene Zeilen") is None)
soll("aus_titel Teilwort: None", rn.aus_titel("Annabell – 1") is None)
soll("Titelform", rn.titel("Anna", "1739", "Werkzeuge", J) == "Anna – 1739: Werkzeuge (21.11., 21:30)", rn.titel("Anna", "1739", "Werkzeuge", J))

S = [("Anna – 1: a", "2026-11-21T06:00:00Z"), ("Spike – 2: b", "2026-11-21T07:00:00Z"),
     ("Britta – 3: c", "2026-11-21T22:59:00Z"),   # 23:59 Berlin, noch heute
     ("Carla – 4: d", "2026-11-21T23:01:00Z"),    # 00:01 Berlin am 22.11.
     ("Dana – 5: e", "2026-11-20T22:30:00Z")]     # 23:30 Berlin am 20.11.
soll("heute nach Berliner Tag, Startfolge", rn.heute_vergeben(S, J) == ["Anna", "Britta"], rn.heute_vergeben(S, J))
soll("nächster nach Anna, Britta: C", rn.naechster(rn.heute_vergeben(S, J), leer) == "Carla")

Z = [{"nr": "1739", "besitzer": "Spike"}, {"nr": "1694", "besitzer": "Tom"}]
soll("Bereich = Besitzer des Vorgangs", rn.bereich("Anna – 1739: Werkzeuge (21.11., 21:30)", Z) == "Spike")
soll("Bereich ohne Rufname: None", rn.bereich("Tom – 1694: Griff", Z) is None)
soll("Bereich unbekannter Vorgang: None", rn.bereich("Anna – 9999: x", Z) is None)

zeile = "session_01A | idle | 2026-11-21T08:00:00Z | Anna – 1: a | 0.5 | 2026-11-21T06:00:00Z | 1000\n"
soll("lauf.py-Eingabe lesen", rn.lies_sitzungen(zeile) == [("Anna – 1: a", "2026-11-21T06:00:00Z")])
soll("echte Docs: jeder Buchstabe hat freien Namen", rn.main(["--pruefen"]) == 0)

# lauf.py: START-Zeilen bekommen Rufnamen (außer Sokrates), Rolle bleibt im ersten Feld
import lauf
rn._SPERRE[rn.DOCS] = set()
aus = lauf.mit_rufnamen([
    "START Spike | opus | env | repo | main | Spike – 1739: Werkzeuge (21.11., 21:30) | Spike\\n\\nAuftrag: x",
    "START Sokrates | opus | env | repo | main | Sokrates – 1763 C: offene Zeilen (21.11., 21:30) | Sokrates",
    "WEITER session_X | Tom | 1694 | y",
    "START Tom | opus | env | repo | main | Tom – 1694: Griff (21.11., 21:30) | Tom"],
    [{"title": "Anna – 1: a", "created_at": "2026-11-21T06:00:00Z"}], J)
soll("lauf: erster START bekommt B", aus[0].split(" | ")[5] == "Britta – 1739: Werkzeuge (21.11., 21:30)", aus[0])
soll("lauf: Rolle bleibt im ersten Feld", aus[0].startswith("START Spike | "))
soll("lauf: Nachricht nennt Rufnamen", aus[0].split(" | ")[6].startswith("Dein Rufname: Britta"))
soll("lauf: Sokrates unverändert", "Sokrates – 1763 C" in aus[1] and "Rufname" not in aus[1])
soll("lauf: WEITER unverändert", aus[2] == "WEITER session_X | Tom | 1694 | y")
soll("lauf: zweiter START bekommt C", aus[3].split(" | ")[5].startswith("Carla – 1694"), aus[3])

# kosten.rolle: alter Titel wie bisher, Rufname über den Vorgang
import kosten
rn._ZEILEN["liste"] = Z
soll("kosten: alter Titel", kosten.rolle("Spike – 1739: x") == "Spike")
soll("kosten: Rufname → Besitzer", kosten.rolle("Anna – 1694: Griff") == "Tom", kosten.rolle("Anna – 1694: Griff"))
soll("kosten: fremd bleibt Sonstige", kosten.rolle("irgendwas") == "Sonstige")

# startsperre-haken.py: Rufnamen-Start wird der Rolle zugeordnet (sonst ungeprüft durch)
import importlib.util
sp = importlib.util.spec_from_file_location("sperrhaken", os.path.join(HIER, "startsperre-haken.py"))
sh = importlib.util.module_from_spec(sp); sp.loader.exec_module(sh)
soll("Haken: Rolle aus der Nachricht", sh.rolle_aus({"title": aus[0].split(" | ")[5], "prompt": aus[0].split(" | ")[6]}) == "Spike")
soll("Haken: Rolle über den Vorgang", sh.rolle_aus({"title": "Anna – 1694: Griff", "prompt": "x"}) == "Tom")
soll("Haken: alter Titel wie bisher", sh.rolle_aus({"title": "Perikles – 775: x", "prompt": ""}) == "Perikles")

# chefwort.py: Kopf „**Anna** [“ und die Startnachricht sind nicht vom Chef
import chefwort
soll("Chefwort: Rufnamen-Kopf nicht vom Chef", not chefwort.vom_chef("**Anna** [21.11., 21:40] fertig"))
soll("Chefwort: Startnachricht nicht vom Chef", not chefwort.vom_chef(aus[0].split(" | ")[6].replace("\\n", "\n")))
soll("Chefwort: Chef bleibt Chef", chefwort.vom_chef("Mach das bitte so"))

# neustart-haken.py: Rolle aus der ersten Nachricht einer Rufnamen-Sitzung
import json as _j
nh_spec = importlib.util.spec_from_file_location("neustarthaken", os.path.join(HIER, "neustart-haken.py"))
nh = importlib.util.module_from_spec(nh_spec); nh_spec.loader.exec_module(nh)
prot = os.path.join(tempfile.mkdtemp(), "p.jsonl")
open(prot, "w").write(_j.dumps({"type": "user", "message": {"content": "Dein Rufname: Britta (Rolle Spike; Titel)\n\nAuftrag: x"}}) + "\n")
sid = "rufname-test-%d" % os.getpid()
soll("Neustart-Haken: Rolle aus Rufnamen-Start", nh.name(prot, sid) == "Spike", nh.name(prot, sid))
try: os.remove("/tmp/bornim-name-%s" % sid)
except OSError: pass

# uebergabe.py: Empfänger als Rufname oder Bereich findet die Sitzung in der Besetzung
import uebergabe as ue
w = tempfile.mkdtemp(); os.makedirs(os.path.join(w, "docs"))
open(os.path.join(w, "docs", "ARBEIT-BESETZUNG.md"), "w").write(
    "| Rolle | Sitzung | Vorgang | Zweig | seit |\n|---|---|---|---|---|\n"
    "| Spike | [Anna – 1739: Werkzeuge (21.11., 21:30)](https://claude.ai/code/session_01AAA) | 1739 | – | 21.11., 21:30 |\n")
alt = ue.WURZEL; ue.WURZEL = w
soll("Übergabe: an Rufname", ue.besetzung("Anna") == ["session_01AAA"], ue.besetzung("Anna"))
soll("Übergabe: an Bereich", ue.besetzung("Spike") == ["session_01AAA"])
soll("Übergabe: anderer Name leer", ue.besetzung("Britta") == [])
ue.WURZEL = alt

print("rufname_test: %s" % ("grün" if not fehl else "%d rot" % fehl))
sys.exit(1 if fehl else 0)
