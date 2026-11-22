#!/usr/bin/env python3
"""1683 (Chef 18.11., 16:54 „Kern über lauf.py, genauso“): die START-Zeile von Spike und Sokrates beginnt in der ersten Nachricht mit dem
Kern der Rollendatei (Sokrates dazu Schwerpunkt A), darunter „Auftrag:“ und die alte Nachricht; Rollen ohne „## Kern“ bleiben gleich."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.argv = [sys.argv[0]]
import lauf

fehler = 0
def pruefe(ok, was):
    global fehler
    if not ok:
        fehler += 1
        print("FEHLER", was)

for rolle, anfang, extra in [("Spike", "Du bist **Spike**", "Prüfstelle jeder APK"), ("Sokrates", "Du bist **Sokrates**", "### A ")]:
    l = lauf.mit_kern("START %s | opus | env | repo | main | Titel | Weiter mit 1667." % rolle)
    msg = l.split(" | ", 6)[6]
    pruefe(msg.startswith(anfang), "%s: Nachricht beginnt nicht mit dem Kern" % rolle)
    pruefe(extra in msg, "%s: %r fehlt" % (rolle, extra))
    pruefe(msg.endswith("\\n\\nAuftrag: Weiter mit 1667."), "%s: Auftrag fehlt am Ende" % rolle)
    pruefe("\n" not in l, "%s: echter Zeilenumbruch in der START-Zeile" % rolle)
    pruefe("## Nachschlagen" not in msg and "## Schwerpunkte" not in msg, "%s: Kern zu lang" % rolle)
t = "START Tom | opus | env | repo | main | Titel | Weiter mit 1."
pruefe(lauf.mit_kern(t) == t, "Tom ohne Kern verändert")
pruefe(lauf.mit_kern("WEITER s | Spike | 1 | x") == "WEITER s | Spike | 1 | x", "WEITER verändert")
# 1795: der Tester meldet mit Absender „Tester“ unter der Nummer aus dem Titel, sonst aus der Nachricht
l = lauf.mit_kern("START Tester | opus | env | repo | main | Tester – 1484: Dorf bis Wolfskampf (22.11., 10:00) | Teste Build 312.")
pruefe(l.endswith('Meldung: `vorgang.py rueckmeldung 1484 "Befunde: n …" --sitzung Tester` (1795).'), "Tester: Meldezeile mit Nummer aus dem Titel fehlt: " + l[-120:])
pruefe("\n" not in l, "Tester: echter Zeilenumbruch")
l = lauf.mit_kern("START Tester | opus | env | repo | main | Tester | Durchspielen 22.11., 10:00, Vorgang 1990.")
pruefe("rueckmeldung 1990 " in l, "Tester: Nummer aus der Nachricht (nicht Datum, Uhrzeit): " + l[-120:])
pruefe("Meldung:" not in lauf.mit_kern("START Tom | opus | env | repo | main | Tom – 1484: x | x"), "Meldezeile nur beim Tester")
print("lauf_kern_test: %s" % ("gut" if not fehler else "%d Fehler" % fehler))
sys.exit(1 if fehler else 0)
