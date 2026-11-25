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

print("lauf_2042_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
