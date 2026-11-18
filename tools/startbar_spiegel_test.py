#!/usr/bin/env python3
"""1624: beantwortete Spiegelzeile ist nicht startbar (Antwort unter „## Woche TT.MM.“ in LISTE-ROLLENSPIEGEL.md)."""
import os, sys, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startbar

d = tempfile.mkdtemp()
open(os.path.join(d, "LISTE-ROLLENSPIEGEL.md"), "w", encoding="utf-8").write(
    "# Rollenspiegel\n\n## Woche 11.11.\n### Homer (11.11.)\n0. x\n## Woche 18.11.\n### Team Tom (18.11.)\n0. x\n### Diogenes (18.11.)\n0. x\n")
startbar.DOCS = d
t = "von Werkzeug (340.3, Rollenspiegel Woche 18.11.): `tools/rollenspiegel.sh X` zeigt die Fragen"
fall = [("Diogenes", t, True), ("Tom", t, True), ("Homer", t, False), ("Jerry", t, False), ("Tom", "ohne Woche", False)]
fehler = 0
for b, titel, soll in fall:
    ist = startbar.spiegel_beantwortet(dict(nr="Spiegel", titel=titel, besitzer=b))
    print("ok  " if ist == soll else "FEHL", b, titel[:30], ist)
    fehler += ist != soll
z = dict(nr="Spiegel", titel=t, besitzer="Diogenes", wort="startbar", warte=[], stand="startbar", zusatz="", bereich="B Abläufe", kl="M")
if not (startbar.sperre(z) or "").startswith("Spiegel beantwortet"): print("FEHL sperre", startbar.sperre(z)); fehler += 1
sys.exit(1 if fehler else 0)
