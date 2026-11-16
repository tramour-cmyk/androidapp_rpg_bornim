#!/usr/bin/env python3
"""1364: Abgabe-Zeile im Vorrat des Gebers und Übernahme nach Fach (Exit 1 bei Fehler)."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startbar as s

fehler = 0
def gleich(a, b, was):
    global fehler
    if a != b: print("ROT %s: %r statt %r" % (was, a, b)); fehler += 1

alt = s.lesen
s.lesen = lambda name: "# Vorrat Jerry\n\n**Abgabe:** 1340 Spike, 1323 Tom; nein: 1305, 1072\n" if name == s.VORRAT["Jerry"] else alt(name)
gib, nein = s.abgabe("Jerry")
gleich(gib, {"1340": "Spike", "1323": "Tom"}, "abgegeben")
gleich(nein, {"1305", "1072"}, "behalten")
s.lesen = lambda name: "# Vorrat\n" if name == s.VORRAT["Jerry"] else alt(name)
gleich(s.abgabe("Jerry"), ({}, set()), "ohne Zeile")
s.lesen = alt
for r in s.BAUTEAMS:  # nie eine Zeile mit Zweig, nie eine eigene
    for nr, t, geber, _ in s.uebernahmen(r):
        d = [x for x in s.zeilen_liste() if x["nr"] == nr][0]
        gleich((d["zweig"] or "–") in ("–", "-", ""), True, "Zweig %s" % nr)
        gleich(geber != r, True, "eigene %s" % nr)
sys.exit(1 if fehler else 0)
