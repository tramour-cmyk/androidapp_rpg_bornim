#!/usr/bin/env python3
"""1937: zaehlzeile.zaehlen schreibt lokal (trocken ohne Zweig); commit-pruefung.py und probelauf.py nutzen es, ohne probelauf-Import."""
import os, sys, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ["BORNIM_PROBELAUF_TROCKEN"] = "1"
import zaehlzeile, probelauf
fehler = []
d = tempfile.mkdtemp(); lokal = os.path.join(d, "w.tsv")
zaehlzeile.zaehlen("275", "Spike", "liste-hand", "warnungen-275.tsv", lokal, ("abc", "main"))
probelauf.zaehlen("1043", "Jerry", "hand", lokal=lokal)
z = [l.split("\t") for l in open(lokal).read().splitlines()]
if len(z) != 2: fehler.append("Zeilen %d statt 2" % len(z))
elif z[0][1:4] != ["275", "Spike", "liste-hand"] or z[0][5:] != ["abc", "main"]: fehler.append("Zeile 275: %s" % z[0])
elif z[1][1:4] != ["1043", "Jerry", "hand"]: fehler.append("Zeile probelauf: %s" % z[1])
cp = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "commit-pruefung.py")).read()
if "import probelauf" in cp: fehler.append("commit-pruefung.py importiert noch probelauf")
print("zaehlzeile: " + ("; ".join(fehler) or "ok")); sys.exit(1 if fehler else 0)
