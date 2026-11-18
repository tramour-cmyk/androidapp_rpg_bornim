#!/usr/bin/env python3
"""1648: Funde des Chefs auch unter „Von Sokrates (… Chef TT.MM. …)“ und „Rest aus … (Chef …)“; nicht ohne Chef in der ersten Klammer."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from chef_fund import vom_chef, ist_fund
fehler = []
for t, soll in [("Von Chef (16.11., 12:37, Hauptmenü): Schild", True),
                ("Rest aus 431h (Chef 17.11., 16:12/16:16, t297.18, Bild): Umhang", True),
                ("Von Sokrates (Chef 13.11., 18:48): Wiesen", True),
                ("Von Sokrates (Vertretung, 1569 Bild 3): dunkler Keil", False),
                ("Von Spike (1270.5 Rang 6): Kampfort (Chef 18.11.) später", False),
                ("Gegenstandskatalog: Netze (Chef 01.11., 458)", True)]:
    if vom_chef(t) != soll: fehler.append(t[:40])
if ist_fund(["1", "Von Chef (x)", "", "", "", "", "", "", "B Abläufe"]): fehler.append("Bereich B zählt")
# heutige Liste: 1569 (Rest aus 431h) muss erkannt werden
liste = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "docs", "LISTE-VORGAENGE.md")
for z in open(liste, encoding="utf-8"):
    sp = [x.strip() for x in z.strip().strip("|").split("|")]
    if sp and sp[0] == "1569" and not ist_fund(sp): fehler.append("1569 nicht erkannt")
print("chef_fund_test:", "grün" if not fehler else "ROT: " + "; ".join(fehler))
sys.exit(1 if fehler else 0)
