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

print("lauf_2042_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
