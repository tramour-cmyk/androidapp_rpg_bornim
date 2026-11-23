#!/usr/bin/env python3
"""1988 (Chef 23.11., 09:02 „1 bis 3 ja“): (1) jeder Startauftrag der Leitung (START Sokrates) nennt „Aufwand: <Wert>“ wie gestartet;
(3) eine Leitungssitzung ab 300.000 used_tokens (context_usage) ergibt die Zeile NEUSTART-LEITUNG an den Disponenten,
vorn bei den STREICHEN-Zeilen (1688)."""
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

# (1) Aufwand im Startauftrag der Leitung
for z, soll in [("START Sokrates | opus | env | repo | main | Sokrates – 1988: x | Weiter.", "Aufwand: Standard (ohne effort-Feld)"),
                ("START Sokrates | opus | effort high | env | repo | main | Sokrates – 1988: x | Weiter.", "Aufwand: high")]:
    l = lauf.mit_kern(z)
    pruefe(l.endswith("\\n\\n" + soll), "1988: Startauftrag der Leitung ohne %r am Ende: %r" % (soll, l[-80:]))
    pruefe("\n" not in l, "1988: echter Zeilenumbruch")
for z in ("START Tom | opus | env | repo | main | Tom – 1: x | Weiter.", "WEITER s1 | Sokrates | 1763 C | Zeile"):
    pruefe("Aufwand:" not in lauf.mit_kern(z), "1988: Aufwand nur im START der Leitung: %s" % z[:30])

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
print("leitung_test: %s" % ("gut" if not fehler else "%d Fehler" % fehler))
sys.exit(1 if fehler else 0)
