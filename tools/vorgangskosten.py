#!/usr/bin/env python3
"""Kosten je Hauptthema und Klasse aus LISTE-VORGAENGE.md und -ARCHIV.md (124, 126; Anteil Muss).

Aufruf: python3 tools/vorgangskosten.py [--gesamt USD]
--gesamt = „gesamt“ aus `kosten.py --ab 17.10.` (alle Sitzungen laut cost_usd): zeigt, wie viel davon in der Liste fehlt (Abgleich, Morgenlauf).
Kostenspalte ist Freitext („8,97 $; Jerry 1,26 $; +1,25 $“): alle Beträge mit „$“ oder Kommazahlen ohne Zeichen werden addiert.
Hauptthema = erster Buchstabe des Bereichs (E, G, Q, B, M). Zeilen ohne Betrag zählen als „ohne Kosten“, nie als 0 $.
"""
import os, re, sys
from collections import defaultdict
DOCS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "docs")
je_bereich = defaultdict(float); je_klasse = defaultdict(float); ohne = 0; zeilen = 0
for dat in ("LISTE-VORGAENGE.md", "LISTE-VORGAENGE-ARCHIV.md"):
    for l in open(os.path.join(DOCS, dat), encoding="utf-8"):
        t = [x.strip() for x in l.split("|")]
        if not (l.startswith("| ") and len(t) > 7 and t[1] not in ("Nr.", "---")): continue
        zeilen += 1
        bereich, kl, kost = t[-6][:1] or "?", t[-5] or "?", t[-4]
        zahlen = [float(z.replace(",", ".")) for z in re.findall(r"(\d+(?:,\d+)?)\s*\$?", kost)]
        if not zahlen: ohne += 1; continue
        s = sum(zahlen); je_bereich[bereich] += s; je_klasse[kl] += s
ges = sum(je_bereich.values()) or 1
print("Zeilen %d, ohne Kosten %d, Summe %.2f $" % (zeilen, ohne, ges))
print("Hauptthema: " + ", ".join("%s %.2f $ (%d %%)" % (k, v, round(100 * v / ges)) for k, v in sorted(je_bereich.items(), key=lambda x: -x[1])))
print("Klasse:     " + ", ".join("%s %.2f $ (%d %%)" % (k, v, round(100 * v / ges)) for k, v in sorted(je_klasse.items(), key=lambda x: -x[1])))
a = sys.argv[1:]
if a[:1] == ["--gesamt"]:
    g = float(a[1].replace(",", "."))
    print("Abgleich: Sitzungen %.2f $, in der Liste %.2f $, nicht zugeordnet %.2f $ (%d %%)" % (g, ges if je_bereich else 0, g - ges, round(100 * (g - ges) / g) if g else 0))
