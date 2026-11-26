#!/usr/bin/env python3
"""2044 (Chef 25.11., 23:00): meldung.sh --bild setzt die Bildzeile in eine Vorlage unter die Absenderzeile, nicht davor; sonst
finden startbar.ueberholt, formfehler und vorlage_pruefen.py (Zeilen 1–2) Absender und Zeit nicht und die beantwortete Vorlage bleibt
stehen (Fall 2034, b038658ec0). Prüft den eingebetteten Python-Teil von meldung.sh selbst. Aufruf: python3 tools/meldung_bild_2044_test.py"""
import os, re, subprocess, sys
HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import startbar

sh = open(os.path.join(HIER, "meldung.sh"), encoding="utf-8").read()
m = re.search(r"PRUEF=\"\$\(case[^\n]*\n?[^']*python3 -c '\n(.*?)' \| git -C \"\$repo\" hash-object", sh, re.S)
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))
soll("Python-Teil in meldung.sh gefunden", bool(m))
if not m: sys.exit(1)
CODE = m.group(1)
Z = "[Bild von 25.11., 20:00](https://github.com/x/blob/bilder/a.webp) (eingetragen von meldung.sh, Sokrates)"
def einsetzen(text, pruef="", punkt=""):
    p = subprocess.run([sys.executable, "-c", CODE], input=text, capture_output=True, text=True,
                       env=dict(os.environ, ZEILE=Z, PUNKT=punkt, PRUEF=pruef))
    return p.stdout

VORLAGE = ("# 2034 · Darf der Bildabzug der Pakete auf graublauem Grund mit Lichthof bleiben?\n"
           "Sokrates · 25.11., 19:59 · B Figur · aus deinem Wort 17:27\n"
           "Kurz: Grund des Abzugs graublau mit Lichthof statt Blauschwarz; A so lassen, B sichtbare Lichtquelle bauen.\n")
neu = einsetzen(VORLAGE)
zl = neu.split("\n")
soll("Vorlage 2034: Absender bleibt Zeile 2", zl[1].startswith("Sokrates · 25.11., 19:59"), zl[:4])
soll("Vorlage 2034: Bildzeile unter dem Absender", Z in neu and neu.index(Z) > neu.index("Sokrates ·"), zl[:5])
soll("Vorlage 2034: nichts verloren", all(l in neu for l in VORLAGE.splitlines()), neu)
antwort = {"2034": ("2034", startbar._zeit(startbar.ZEIT.search("25.11., 20:04")))}
soll("startbar.ueberholt findet die Antwort 20:04 nach dem Bild", startbar.ueberholt("2034-abzug-grund.md", neu, antwort) is not None)
# ansehen-Datei ohne Absenderzeile: Bild wie bisher unter Zeile 1
A = "# 1566 Höhlenwasser\n\nText\n"
soll("ansehen ohne Absender: Bild unter Zeile 1", einsetzen(A).split("\n")[:3] == ["# 1566 Höhlenwasser", "", Z], einsetzen(A))
# Prüfliste: Zeilen 1 und 2 bleiben oben (1199)
P = "# t301 Prüfliste\nAPK: https://x\n\n| Nr | Art | Wo und wie |\n"
soll("Prüfliste: Zeile 2 (APK) bleibt oben", einsetzen(P, pruef="1").split("\n")[:4] == ["# t301 Prüfliste", "APK: https://x", "", Z], einsetzen(P, pruef="1"))
print("MELDUNG2044 %d Fehler" % fehl)
sys.exit(1 if fehl else 0)
