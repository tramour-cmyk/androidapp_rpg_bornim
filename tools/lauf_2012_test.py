#!/usr/bin/env python3
"""2012 (2) (Bauliste Sokrates 23.11., 23:01): lauf.py schließt „Auftrag steht“ und „Nachfolger“ der Nummer erst, wenn die gestartete
Fachkraft angekommen ist (Sitzung mit dem Rufnamen der Startsperre, sonst start_angekommen), nur Zeilen bis zur Startsperre, Teilnummern
exakt, Hinweise nie. Fälle 1603-Ü1 (angenommen) und 1960-Ü8 (offen) wie am 22./24.11. Ohne Netz: schliessen wird mitgeschrieben.
Aufruf: python3 tools/lauf_2012_test.py"""
import datetime, os, sys, tempfile
H = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, H); sys.argv = sys.argv[:1]
import lauf, uebergabe as ue

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else str(zeige)[-1500:]))

lauf.JETZT = datetime.datetime(2026, 11, 24, 8, 30, tzinfo=lauf.BERLIN)
KOPF = "## Übergaben\n\n| Ü | an | was | seit | Zustand |\n|---|---|---|---|---|\n"
def zeile(nr, k, was, seit, zu="offen", an="Disponent"): return "| %s-Ü%d | %s | %s | %s | %s |\n" % (nr, k, an, was, seit, zu)
AS = "Auftrag steht (Rückmeldung %s von Arbeitsplaner): Fachkraft nach Profil des Auftrags starten (1797)"
DATEIEN = {
    "1603": zeile("1603", 1, AS % "22.11., 19:08", "22.11., 19:08", "angenommen session_01Hmoj78swtcWnfPZeEocJxd bis 22.11., 19:40"),
    "1960": zeile("1960", 8, AS % "22.11., 18:17", "22.11., 18:17") + zeile("1960", 9, "Hinweis (Rückmeldung 22.11., 18:20 von Sokrates): wie einen Eingang behandeln (1739)", "22.11., 18:20"),
    "1589": zeile("1589", 3, AS % "23.11., 19:00", "23.11., 19:00"),
    "1589.2": zeile("1589.2", 9, AS % "23.11., 19:02", "23.11., 19:02"),
    "2012": zeile("2012", 3, AS % "24.11., 07:07", "24.11., 07:07") + zeile("2012", 1, "Hinweis (Rückmeldung 23.11., 22:33 von Sokrates): wie einen Eingang behandeln (1739)", "23.11., 22:33"),
    "1694": zeile("1694", 14, AS % "23.11., 23:10", "23.11., 23:10"),
    "513": zeile("513", 2, AS % "23.11., 20:00", "23.11., 20:00"),
}
docs = tempfile.mkdtemp(prefix="lauf-2012-"); os.makedirs(os.path.join(docs, "vorgang"))
for nr, t in DATEIEN.items(): open(os.path.join(docs, "vorgang", nr + ".md"), "w", encoding="utf-8").write("# %s · Test\n\n" % nr + KOPF + t)
BETRIEB = """- 21:01 23.11.: Startsperre 21:01 Start Arbeitsplaner, Kampf, Figur (lauf.py, Arbeitsplaner 513 Zeno, Kampf 1603 Arne, Figur 1675 Clara)
- 00:03 24.11.: Startsperre 00:03 Start Sokrates (lauf.py, 1603)
- 07:02 24.11.: Startsperre 07:02 Start Kampf, Werkzeug, Arbeitsplaner (lauf.py, Kampf 1694 Elke, Werkzeug 1960 Frieda, Arbeitsplaner 2012 Gerda)
- 08:03 24.11.: Startsperre 08:03 Start Kampf (lauf.py, Kampf 1589.2 Karla)
- 08:20 24.11.: Startsperre 08:20 Start Werkzeug (lauf.py, 2012)
"""
# Startsperren lesen: (Zeit, Rolle, Nr, Rufname)
e = lauf.start_eintraege(BETRIEB, 2026)
soll("start_eintraege: je START Rolle, Nr, Rufname; eine Rolle ohne Namen „(lauf.py, 2012)“",
     [(x[0].strftime("%d.%m. %H:%M"), x[1], x[2], x[3]) for x in e] == [
         ("23.11. 21:01", "Arbeitsplaner", "513", "Zeno"), ("23.11. 21:01", "Kampf", "1603", "Arne"), ("23.11. 21:01", "Figur", "1675", "Clara"),
         ("24.11. 00:03", "Sokrates", "1603", None),
         ("24.11. 07:02", "Kampf", "1694", "Elke"), ("24.11. 07:02", "Werkzeug", "1960", "Frieda"), ("24.11. 07:02", "Arbeitsplaner", "2012", "Gerda"),
         ("24.11. 08:03", "Kampf", "1589.2", "Karla"), ("24.11. 08:20", "Werkzeug", "2012", None)], e)

def s(sid, titel, erstellt, status="SESSION_STATUS_IDLE"):
    return {"id": sid, "title": titel, "created_at": erstellt, "updated_at": erstellt, "session_status": status}
# Arne (1603) und Frieda (1960) angekommen; Elke (1694) nie angekommen; Karla (1589.2) angekommen; Zeno (Planer 513) angekommen;
# Werkzeug 2012 ohne Rufname: Werkzeug-Sitzung nach 08:20
ALLE = {x["id"]: x for x in (
    s("session_arne", "Arne – Kampf 1603: Ansagen (23.11., 21:01)", "2026-11-23T20:02:00Z", "SESSION_STATUS_ARCHIVED"),
    s("session_frieda", "Frieda – Werkzeug 1960: Titel (24.11., 07:02)", "2026-11-24T06:03:00Z"),
    s("session_karla", "Karla – Kampf 1589.2: Teil (24.11., 08:03)", "2026-11-24T07:04:00Z"),
    s("session_zeno", "Zeno – Arbeitsplaner 513 (23.11., 21:01)", "2026-11-23T20:02:00Z"),
    s("session_elke_alt", "Elke – Kampf 1694 (23.11., 07:00)", "2026-11-23T06:00:00Z"),
    s("session_wz", "Werkzeug – 2012", "2026-11-24T07:21:00Z"))}
lauf.kosten.rolle = lambda titel, created=None: "Werkzeug" if titel.startswith("Werkzeug") else "?"
aufrufe = []
def schliessen(nr, arten, grund, bis=None):
    aufrufe.append((nr, tuple(arten), bis.strftime("%d.%m., %H:%M"), grund)); return ["%s-Üx" % nr]
aus = lauf.start_zeilen_schliessen(ALLE, BETRIEB, schliessen, docs)
nrn = [a[0] for a in aufrufe]
soll("1603-Ü1 (angenommen) nach Start Arne zu, bis 21:01, nur Start-Arten",
     ("1603", ue.START_ARTEN, "23.11., 21:01") in [a[:3] for a in aufrufe], aufrufe)
soll("1960-Ü8 nach Start Frieda zu", ("1960", ue.START_ARTEN, "24.11., 07:02") in [a[:3] for a in aufrufe], aufrufe)
soll("1589.2 (Karla angekommen) zu, 1589 nicht", "1589.2" in nrn and "1589" not in nrn, aufrufe)
soll("1694: Elke nicht angekommen (alte Sitzung zählt nicht): bleibt", "1694" not in nrn, aufrufe)
soll("nur Fachkraft-Starts: Planer 513 und Sokrates 1603 schließen nichts", "513" not in nrn and nrn.count("1603") == 1, aufrufe)
soll("2012-Ü3 (07:07) nach Start Werkzeug 08:20 ohne Rufname zu (start_angekommen)", ("2012", ue.START_ARTEN, "24.11., 08:20") in [a[:3] for a in aufrufe], aufrufe)
soll("Ausgabe nennt geschlossene Zeilen", any("1603-Üx" in l and "2012" in l for l in aus) and len(aus) == len(aufrufe), aus)
# lokaler Vorabblick: ohne offene Start-Zeile bis zur Sperre kein Aufruf (kein Netz je Lauf)
aufrufe.clear()
open(os.path.join(docs, "vorgang", "1603.md"), "w", encoding="utf-8").write("# 1603\n\n" + KOPF + zeile("1603", 1, AS % "22.11., 19:08", "22.11., 19:08", "erledigt 24.11., 08:30 (x)"))
open(os.path.join(docs, "vorgang", "1960.md"), "w", encoding="utf-8").write("# 1960\n\n" + KOPF + zeile("1960", 8, AS % "24.11., 07:30", "24.11., 07:30"))
lauf.start_zeilen_schliessen(ALLE, BETRIEB, schliessen, docs)
soll("erledigte Zeile: kein Aufruf; Zeile nach der Sperre (07:30 > 07:02): kein Aufruf", not [a for a in aufrufe if a[0] in ("1603", "1960")], aufrufe)
# Fehler beim Schreiben: Warnung, kein Absturz
def kaputt(*a, **k): raise ue.Fehler("origin/main nicht erreichbar")
aus = lauf.start_zeilen_schliessen(ALLE, BETRIEB, kaputt, docs)
soll("Schreibfehler: WARNUNG je Nummer, kein Absturz", aus and all(l.startswith("WARNUNG") for l in aus), aus)

print("lauf_2012_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
