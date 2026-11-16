#!/usr/bin/env python3
"""Test zu 1414: Vorgang ohne Wort dazu (nummer_wort.py)."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import nummer_wort as n

def nrn(t): return [x[1] for x in n.befunde(t)]

FALSCH = {"Rezeptbuch ist reif mit 976.": ["976"], "Stand wie 1351, dann weiter": ["1351"], "wartet auf 1351 und 1044": ["1351", "1044"],
          "Vorgang 1414 erledigt": ["1414"]}
RICHTIG = ["976 (Rezeptbuch) ist reif", "Rezeptbuch (976) reif", "1414: gebaut", "1351 – Rechteprüfung", "Nr. **1402** (Kampfkamera)",
           "37 Commits am 16.11., 12:09 in 2026", "60 KB, 12 %", "[72o.1](cs:72o1) offen", "`1351-x.md` und 1351-rechte.md",
           "Krogg 100 / 72 / 87", "88 bis 100", "Build 290 und Zeile 290.3", "| 291.3 | Spike | 1270.3 |", "# 1414 · Warnung?",
           "Hash 68b53e087 steht", "Segen 100."]
fehler = 0
for t, soll in FALSCH.items():
    if nrn(t) != soll: print("FALSCH nicht erkannt:", t, nrn(t)); fehler += 1
for t in RICHTIG:
    if nrn(t): print("Fehlalarm:", t, nrn(t)); fehler += 1
print("nummer_wort: %d Fehler" % fehler); sys.exit(1 if fehler else 0)
