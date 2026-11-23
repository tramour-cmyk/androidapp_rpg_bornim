#!/usr/bin/env python3
"""1988 (Chef 23.11., 09:02 „1 bis 3 ja“): (1) „Aufwand“ im Startauftrag der Leitung gestrichen (Chef 09:07);
(3) eine Leitungssitzung ab 300.000 used_tokens (context_usage) ergibt die Zeile NEUSTART-LEITUNG an den Disponenten,
vorn bei den STREICHEN-Zeilen (1688); Zusatz Chef 09:26: (4) dasselbe für den Disponenten (NEUSTART-DISPONENT; seit 1992 startet er seinen Nachfolger selbst),
(5) dieselbe Warnung höchstens einmal je Stunde."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.argv = [sys.argv[0]]
import lauf

fehler = 0
def pruefe(ok, was):
    global fehler
    if not ok:
        fehler += 1
        print("FEHLER", was)

# (1) gestrichen (Chef 23.11., 09:07): kein Aufwand im Startauftrag der Leitung
for z in ("START Sokrates | opus | effort high | env | repo | main | Sokrates – 1988: x | Weiter.", "START Tom | opus | env | repo | main | Tom – 1: x | Weiter."):
    pruefe("Aufwand:" not in lauf.mit_kern(z), "1988 (09:07): kein Aufwand im Startauftrag: %s" % z[:30])

# (3) Neustart der Leitung ab 300.000 Token (nachgestellter Wert)
def s(i, tok, ext=False):
    d = {"id": i, "_info": ("Sokrates", True, 1, [])}
    if tok is not None:
        d["external_metadata" if ext else "context_usage"] = {"context_usage": {"used_tokens": tok}} if ext else {"used_tokens": tok}
    return d
je = {"Sokrates": [s("session_A", 300001), s("session_B", 299999), s("session_C", 430000, ext=True), s("session_D", None), s("session_E", 500000)],
      "Tom": [s("session_T", 900000)]}
z = lauf.leitung_neustart(je, {"session_E"})
ids = [x.split(" ", 2)[1] for x in z]
pruefe(ids == ["session_A", "session_C"], "1988: Neustart ab 300.000 nur für laufende Leitung, nicht archiviert, nicht ohne Wert: %s" % z)
pruefe(all(x.startswith("NEUSTART-LEITUNG ") and "Leitung neu starten (Übergabe ins Gedächtnis)" in x for x in z), "1988: Wortlaut: %s" % z)
pruefe(lauf.leitung_neustart({"Sokrates": [s("session_X", 300000)]}, set()) != [], "1988: genau 300.000 zählt (ab)")
aus = lauf.vorn(["START Tom | x", "NEUSTART-LEITUNG session_A | Sokrates | 300 Tsd. | y", "STREICHEN 1-Ü1 | z"])
pruefe(aus[0].startswith("STREICHEN ") and aus[1].startswith("NEUSTART-LEITUNG "), "1988: Neustartzeile vorn, nach STREICHEN: %s" % aus)
# (4) Zusatz Chef 09:26: Disponent ab 300.000 Token, Übergabe zuerst; 1992: er startet den Nachfolger selbst
d = {"Disponent": [s("session_P", 300000), s("session_Q", 299999)], "Sokrates": [s("session_A", 310000)]}
z = lauf.leitung_neustart(d, set(), wache="session_W")
pruefe([x.split(" ", 2)[:2] for x in z] == [["NEUSTART-LEITUNG", "session_A"], ["NEUSTART-DISPONENT", "session_P"]], "1988 (4): Disponent ab 300.000: %s" % z)
zd = [x for x in z if x.startswith("NEUSTART-DISPONENT")]
pruefe(zd and "Übergabe zuerst, dann startet der Disponent seinen Nachfolger selbst mit `lauf.py --start Disponent`; der Nachfolger archiviert den Vorgänger" in zd[0]
       and "Wache" not in zd[0] and "send_message" not in zd[0], "1992 (Chef 10:04): Disponent startet Nachfolger selbst, nicht über die Wache: %s" % zd)
aus = lauf.vorn(["START Tom | x", "NEUSTART-DISPONENT session_P | y", "NEUSTART-LEITUNG session_A | y", "STREICHEN 1-Ü1 | z"])
pruefe([a.split(" ")[0] for a in aus[:3]] == ["STREICHEN", "NEUSTART-LEITUNG", "NEUSTART-DISPONENT"], "1988 (4): Disponentzeile vorn: %s" % aus)
import tempfile, datetime, json
_st = os.path.join(tempfile.mkdtemp(), "warn.json")
t0 = datetime.datetime(2026, 11, 23, 9, 0, tzinfo=lauf.BERLIN)
W = ["WARNUNG-LAUT Start Tom nicht angekommen", "NICHTS Tom: x", "WARNUNG Abgleich: 3 Zeilen"]
# (5) Zusatz Chef 09:26: dieselbe Warnung höchstens einmal je Stunde
pruefe(lauf.warnung_einmal_je_stunde(W, _st, t0) == W, "1988 (5): erster Lauf mit allen Warnungen")
r2 = lauf.warnung_einmal_je_stunde(W + ["WARNUNG neu"], _st, t0 + datetime.timedelta(minutes=15))
pruefe(r2 == ["NICHTS Tom: x", "WARNUNG neu"], "1988 (5): zweiter Lauf binnen einer Stunde ohne dieselbe Warnung, neue bleibt: %s" % r2)
r3 = lauf.warnung_einmal_je_stunde(W, _st, t0 + datetime.timedelta(minutes=61))
pruefe(r3 == W, "1988 (5): nach einer Stunde wieder mit: %s" % r3)
r4 = lauf.warnung_einmal_je_stunde(W, os.path.join(_st + ".fehlt", "x", "warn.json"), t0)
pruefe(r4 == W, "1988 (5): Stand nicht schreibbar: Warnungen bleiben (lieber doppelt als verschluckt)")
print("leitung_test: %s" % ("gut" if not fehler else "%d Fehler" % fehler))
sys.exit(1 if fehler else 0)
