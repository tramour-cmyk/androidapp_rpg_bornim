#!/usr/bin/env python3
"""1622: „<Nr> main“ im Feld „wartet auf“ löst erst mit „erledigt“ oder „auf main“, die blanke Nummer weiter mit „gebaut“ (190.1)."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startbar as S

S.zeilen_liste = lambda: [{"nr": "900", "wort": "gebaut"}, {"nr": "901", "wort": "erledigt"}]
fehler = 0
for t, soll in [("900", True), ("900 main", False), ("901 main", True)]:
    ist = S.erfuellt(t, "999")
    if ist != soll: fehler += 1; print("FEHLER", t, ist, "statt", soll)
if S.art("900 main") != "nr": fehler += 1; print("FEHLER art")
print("STARTBAR-MAIN", "gut" if not fehler else "%d Fehler" % fehler)
sys.exit(1 if fehler else 0)
