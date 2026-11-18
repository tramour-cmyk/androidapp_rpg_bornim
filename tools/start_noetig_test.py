#!/usr/bin/env python3
"""1586: Warnung „Start nicht angekommen“ nur, wenn die Rolle jetzt etwas zu starten hätte."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lauf

st = {"Homer": ([], [("1235", "N", "Texte Kapitel 2", {})], None, []),
      "Tom": ([("297.11", "M", "Bild", {})], [], None, []),
      "Jerry": ([("1561", "M", "rot", {})], [], "23.11.", [])}
fehler = []
def soll(wert, *a, **k):
    if lauf.start_noetig(*a, **k) != wert: fehler.append("%r → %r erwartet" % (a, wert))
soll(False, "Homer", st, {"1235": "Gespräch 1236"})   # Fall 17.11.: einzige Zeile ausgeschlossen
soll(True, "Homer", st, {})                            # Zeile startbar: Warnung bleibt
soll(False, "Homer", st, {}, nur_muss=True)            # nur Muss: Kür zählt nicht
soll(True, "Homer", st, {"1235": "x"}, nf_offen=True)  # offener Nachfolger
soll(False, "Homer", {}, {})                           # Vorrat leer (Fall 16.11., 1489)
soll(True, "Tom", st, {})
soll(False, "Tom", st, {"297.11": "x"})
soll(False, "Jerry", st, {})                           # Pause
soll(False, "Sokrates", {"Sokrates": ([], [("1", "K", "t", {})], None, [])}, {})  # Kür ohne MIT_KUER
if fehler: print("\n".join(fehler)); sys.exit(1)
print("start_noetig_test: 9 Fälle grün")
