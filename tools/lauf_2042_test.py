#!/usr/bin/env python3
"""2042 (Chef 25.11., 22:03 „A mit Eilt“, 22:04 „Disponent immer Sonnet“): Disponent klein halten. Ohne Netz.
(3) jede START-Zeile eines Disponenten mit Modell sonnet; (4) TITEL-Zeile für laufende Einzelrollen mit altem Titel.
Aufruf: python3 tools/lauf_2042_test.py"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.argv = [sys.argv[0]]
import lauf

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))

# (3) Modell: Handstart, Nachfolger, Wache-Neustart nutzen alle start_zeilen/modell
for nr in ("Betrieb", "2042"):
    zs = lauf.start_zeilen("Disponent", nr, "Nachfolger.", [])
    st = next((z for z in zs if z.startswith("START ")), "")
    soll("(3) START Disponent %s: Modell sonnet" % nr, st.split(" | ")[1:2] == ["sonnet"], st[:120])
soll("(3) modell('Disponent') sonnet, auch ohne Nummer", lauf.modell("Disponent", None)[0] == "sonnet")
soll("(3) andere Rollen unverändert (Werkzeug opus)", lauf.modell("Werkzeug", None)[0] == "opus")

# (4) TITEL für Einzelrollen (FESTER_TITEL) mit abweichendem Titel
leb = [{"id": "session_KARL", "title": "Karl – Disponent – Betrieb (25.11., 21:58)", "created_at": "2026-11-25T20:58:00Z", "session_status": "SESSION_STATUS_RUNNING"},
       {"id": "session_NEU", "title": "Disponent – Büro (25.11., 22:30)", "created_at": "2026-11-25T21:30:00Z", "session_status": "SESSION_STATUS_IDLE"},
       {"id": "session_WALT", "title": "Wache – Disponent (24.11., 07:01)", "created_at": "2026-11-24T06:01:00Z", "session_status": "SESSION_STATUS_IDLE"},
       {"id": "session_WNEU", "title": "Wache – Betrieb (25.11., 07:02)", "created_at": "2026-11-25T06:02:00Z", "session_status": "SESSION_STATUS_IDLE"},
       {"id": "session_ARCH", "title": "Otto – Disponent – Betrieb (25.11., 20:27)", "created_at": "2026-11-25T19:27:00Z", "session_status": "SESSION_STATUS_ARCHIVED"},
       {"id": "session_RALF", "title": "Ralf – 2041: Prüfer (25.11., 21:55)", "created_at": "2026-11-25T20:55:00Z", "session_status": "SESSION_STATUS_IDLE"}]
tz = lauf.titel_zeilen(leb)
soll("(4) Karls alter Titel → TITEL session_KARL Disponent – Büro (25.11., 21:58)",
     "TITEL session_KARL Disponent – Büro (25.11., 21:58)" in tz, tz)
soll("(4) alte Wache → TITEL session_WALT Wache – Betrieb (24.11., 07:01)", "TITEL session_WALT Wache – Betrieb (24.11., 07:01)" in tz, tz)
soll("(4) richtige Titel, archivierte und Fachkräfte: keine Zeile", len(tz) == 2, tz)

# (1) list_sessions nur bis Zeitgrenze: Kurzform-Endzeile „# bis: <created_at der letzten Zeile>“ statt „# has_more: nein“
import datetime, tempfile
B = lauf.BERLIN
j1 = datetime.datetime(2026, 11, 25, 22, 34, tzinfo=B); j2 = datetime.datetime(2026, 11, 26, 1, 0, tzinfo=B)
soll("(1) Grenze 22:34 → heute 00:00", lauf.zeitgrenze(j1) == datetime.datetime(2026, 11, 25, 0, 0, tzinfo=B), lauf.zeitgrenze(j1))
soll("(1) Grenze 01:00 → jetzt − 3 h", lauf.zeitgrenze(j2) == datetime.datetime(2026, 11, 25, 22, 0, tzinfo=B), lauf.zeitgrenze(j2))
d = tempfile.mkdtemp()
def kurz(name, ende):
    p = os.path.join(d, name)
    open(p, "w").write("session_A | working | 2026-11-25T21:00:00Z | Karl – Disponent – Betrieb | - | 2026-11-25T20:00:00Z | 90000\n" + ende + "\n"); return p
alt, jung, voll, ohne = kurz("alt", "# bis: 2026-11-24T22:50:00Z"), kurz("jung", "# bis: 2026-11-25T12:00:00Z"), kurz("voll", "# has_more: nein"), kurz("ohne", "")
for name, p, soll_offen in (("bis vor Grenze", alt, False), ("bis nach Grenze", jung, True), ("has_more nein", voll, False), ("ohne Endzeile", ohne, True)):
    offen = []; lauf.kosten.sitzungen(p, offen)
    rest, bis = lauf.grenze_offen(offen, j1)
    soll("(1) %s: abgeschnitten=%s" % (name, soll_offen), bool(rest) == soll_offen, (rest, bis))
besetz = "| Disponent | [Karl](https://claude.ai/code/session_A) | Betrieb | – | x |\n| Wache | [Wache – Betrieb](https://claude.ai/code/session_W) | Betrieb | – | x |\n"
soll("(1) Besetzung ohne Seite → fehlt session_W", lauf.besetzung_fehlt(besetz, {"session_A"}) == ["session_W"], lauf.besetzung_fehlt(besetz, {"session_A"}))
soll("(1) Besetzung vollständig → nichts", lauf.besetzung_fehlt(besetz, {"session_A", "session_W"}) == [])

print("lauf_2042_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
