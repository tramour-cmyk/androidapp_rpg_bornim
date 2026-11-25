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

# (2) Wecker an den Disponenten gebündelt: weckte ihn schon eine Zeile seit dem letzten Takt (Stand), kein zweiter Wecker
import io, contextlib, uebergabe as ue
w = tempfile.mkdtemp(); os.makedirs(os.path.join(w, "docs", "vorgang"))
def wurzel(stand, zeilen):
    open(os.path.join(w, "docs", "ARBEIT-BESETZUNG.md"), "w").write("**Stand:** %s (lauf.py)\n\n| Rolle | Sitzung | Vorgang | Zweig | seit |\n|---|---|---|---|---|\n"
        "| Disponent | [Disponent – Büro (25.11., 21:58)](https://claude.ai/code/session_DISP) | Betrieb | – | x |\n" % stand)
    open(os.path.join(w, "docs", "vorgang", "9001.md"), "w").write("## Übergaben\n\n" + ue.KOPF + "".join("| %s | %s | x | %s | %s |\n" % z for z in zeilen))
def weck(k, an):
    o = io.StringIO()
    with contextlib.redirect_stdout(o): ue.wecker("9001", k, an, scharf=True)
    return o.getvalue()
ue.WURZEL = w; ue.jetzt = lambda: datetime.datetime(2026, 11, 25, 22, 40)
wurzel("25.11., 22:30", [("9001-Ü1", "Disponent", "25.11., 22:35", "offen"), ("9001-Ü2", "Disponent", "25.11., 22:40", "offen")])
a = weck("9001-Ü2", "Disponent")
soll("(2) Ü1 nach Stand weckte schon → kein WECKER, Zeile gebündelt", "WECKER" not in a and "gebündelt" in a, a)
wurzel("25.11., 22:36", [("9001-Ü1", "Disponent", "25.11., 22:35", "offen"), ("9001-Ü2", "Disponent", "25.11., 22:40", "offen")])
a = weck("9001-Ü2", "Disponent")
soll("(2) Takt nach Ü1 → WECKER", "WECKER session_DISP" in a, a)
wurzel("25.11., 22:30", [("9001-Ü1", "Werkzeug", "25.11., 22:35", "offen"), ("9001-Ü2", "Werkzeug", "25.11., 22:40", "offen")])
a = weck("9001-Ü2", "Werkzeug")
soll("(2) keine Sitzung Werkzeug, Ü1 weckte schon → gebündelt", "WECKER" not in a and "gebündelt" in a, a)
wurzel("25.11., 22:00", [("9001-Ü1", "Disponent", "25.11., 22:20", "offen"), ("9001-Ü2", "Disponent", "25.11., 22:40", "offen")])
a = weck("9001-Ü2", "Disponent")
soll("(2) frühere Zeile älter als 15 Min. → doch WECKER (kein Dauerschweigen)", "WECKER session_DISP" in a, a)
wurzel("25.11., 22:00", [("9001-Ü1", "Disponent", "25.11., 22:20", "offen"), ("9001-Ü3", "Disponent", "25.11., 22:30", "offen"), ("9001-Ü2", "Disponent", "25.11., 22:40", "offen")])
a = weck("9001-Ü2", "Disponent")
soll("(2) Kette: älteste Zeile seit Takt über 15 Min. → WECKER, auch wenn eine jüngere gebündelt war", "WECKER session_DISP" in a, a)
wurzel("25.11., 22:30", [("9001-Ü1", "Disponent", "25.11., 22:35", "erledigt 25.11., 22:36 x"), ("9001-Ü2", "Disponent", "25.11., 22:40", "offen")])
a = weck("9001-Ü2", "Disponent")
soll("(2) frühere Zeile erledigt → WECKER", "WECKER session_DISP" in a, a)

# (5) Startnachricht (Sokrates 2042-Ü5, 22:37): Auftrag nur in der Vorgangsdatei, in der START-Zeile nur der Verweis
import shutil
dd = tempfile.mkdtemp(); os.makedirs(os.path.join(dd, "vorgang")); shutil.copytree(os.path.join(lauf.DOCS, "profile"), os.path.join(dd, "profile"))
LANG = "GEHEIMER-LANGTEXT " * 300
open(os.path.join(dd, "vorgang", "9002.md"), "w").write("# 9002 · Probe\n\n## Auftrag (25.11., 22:00)\n\n1. **Ziel:** %s\n4. **Beachte:** Profil Werkzeug\n\n## Chefworte\n" % LANG)
st = next((z for z in lauf.start_zeilen("Werkzeug", "9002", "Probe.", [], docs=dd) if z.startswith("START ")), "")
soll("(5) START Werkzeug: Auftrag nicht wörtlich", "GEHEIMER-LANGTEXT" not in st, len(st))
soll("(5) START Werkzeug: Verweis auf docs/vorgang/9002.md", "docs/vorgang/9002.md" in st and "vorgang.py auftrag 9002" in st, st[-400:])
soll("(5) START Werkzeug: Ladetext Werkzeug bleibt", "**Werkzeug**" in st, st[:300])

print("lauf_2042_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
