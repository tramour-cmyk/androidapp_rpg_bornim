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
# 1912 (D344.1): Zahl nach „Build“ oder „t“ ist der Build, nicht der Vorgang
for _m in ("Teste Build 312, Vorgang 1990.", "Teste t312 für 1990.", "Teste Build 312 und dann 1990."):
    l = lauf.mit_kern("START Tester | opus | env | repo | main | Tester | %s" % _m)
    pruefe("rueckmeldung 1990 " in l, "1912: Tester meldet unter dem Build statt dem Vorgang (%s): %s" % (_m, l[-120:]))
l = lauf.mit_kern("START Tester | opus | env | repo | main | Tester | Teste Build 312.")
pruefe("rueckmeldung <Nr> " in l, "1912: nur Build genannt: Platzhalter statt Buildnummer: " + l[-120:])
pruefe("Meldung:" not in lauf.mit_kern("START Tom | opus | env | repo | main | Tom – 1484: x | x"), "Meldezeile nur beim Tester")
# 1923 (1727j Startblock): an der neuen Liste Kern, Fachprofil, Querprofile wörtlich, dann „Auftrag:“ mit dem jüngsten Auftrag
import tempfile
d = tempfile.mkdtemp()
os.makedirs(os.path.join(d, "profile")); os.makedirs(os.path.join(d, "vorgang"))
for _n, _t in [("Kern Büro", "KERN-BUERO"), ("Arbeitsplaner", "KERN-PLANER"), ("Kern Abnahme", "KERN-ABNAHME"), ("Prüfer", "PROFIL-PRUEFER"),
               ("Welt", "PROFIL-WELT"), ("Signatur und Leben", "QUER-SIGNATUR"), ("Fremde Inhalte", "QUER-FREMD"), ("Zugang Kaufrepo", "QUER-KAUFREPO"),
               ("Story", "PROFIL-STORY")]:
    open(os.path.join(d, "profile", _n + ".md"), "w", encoding="utf-8").write("# %s\n\n%s\nzweite Zeile\n\n## Gegenprüfung\nNICHT-LADEN\n" % (_n, _t))
open(os.path.join(d, "vorgang", "2001.md"), "w", encoding="utf-8").write(
    "# 2001 · x\n\n## Auftrag (21.11., 09:00)\n\nALTER-AUFTRAG\n\n## Auftrag (22.11., 10:00)\n\n1. **Ziel:** Zwerg am Boden.\n"
    "4. **Beachte:** Querprofil Signatur und Leben; Pfad docs/profile/Welt.md\n7. **Zurück:** an das Büro\n\n## Herkunft\nHERKUNFT\n")
open(os.path.join(d, "vorgang", "2002.md"), "w", encoding="utf-8").write("# 2002 · y\n\n## Auftrag (22.11., 10:00)\n\n1. **Ziel:** Text.\n4. **Beachte:** Querprofil Fremde Inhalte\n")
lauf.NEU_LISTE = True
try:
    del lauf.STARTBLOCK_FEHLT[:]
    l = lauf.mit_kern("START Welt | opus | env | repo | main | Welt – 2001: Zwerg (22.11., 11:30) | Zuerst Start nach deiner Rollendatei. Die Vorgangsdatei lesen.", d)
    msg = l.split(" | ", 6)[6]
    pruefe("\n" not in l, "1923: echter Zeilenumbruch")
    pos = [msg.find(x) for x in ("**Welt**\\nPROFIL-WELT\\nzweite Zeile", "**Signatur und Leben**\\nQUER-SIGNATUR", "**Zugang Kaufrepo**\\nQUER-KAUFREPO",
                                 "\\n\\nAuftrag: 1. **Ziel:** Zwerg am Boden.", "7. **Zurück:** an das Büro", "Die Vorgangsdatei lesen.")]
    pruefe(all(p >= 0 for p in pos) and pos == sorted(pos), "1923: Welt: Reihenfolge Fachprofil, Querprofil, Kaufrepo, Auftrag, Nachricht: %s %s" % (pos, msg[:300]))
    for _x in ("NICHT-LADEN", "ALTER-AUFTRAG", "HERKUNFT", "QUER-FREMD", "KERN-", "PROFIL-STORY", "Rollendatei"):
        pruefe(_x not in msg, "1923: Welt: %r gehört nicht in die Startnachricht" % _x)
    pruefe(msg.startswith("**Welt**"), "1923: Welt beginnt nicht mit dem Fachprofil: " + msg[:60])
    l = lauf.mit_kern("START Arbeitsplaner | opus | env | repo | main | Arbeitsplaner – 2002: y | Auftrag schreiben.", d)
    msg = l.split(" | ", 6)[6]
    pos = [msg.find(x) for x in ("**Kern Büro**\\nKERN-BUERO", "**Arbeitsplaner**\\nKERN-PLANER", "**Fremde Inhalte**\\nQUER-FREMD", "Auftrag: 1. **Ziel:** Text.")]
    pruefe(all(p >= 0 for p in pos) and pos == sorted(pos), "1923: Arbeitsplaner: Kern Büro, Kern Planer, Querprofil, Auftrag: %s" % pos)
    pruefe("QUER-KAUFREPO" not in msg, "1923: Arbeitsplaner braucht kein Kaufrepo")
    l = lauf.mit_kern("START Prüfer | opus | env | repo | main | Prüfer – 2001: Zwerg | Prüfe.", d)
    msg = l.split(" | ", 6)[6]
    pruefe("KERN-ABNAHME" in msg and "PROFIL-PRUEFER" in msg and "QUER-SIGNATUR" in msg and "QUER-KAUFREPO" in msg, "1923: Prüfer bei Bildauftrag: Kern Abnahme, Profil, Signatur, Kaufrepo")
    msg = lauf.mit_kern("START Prüfer | opus | env | repo | main | Prüfer – 2002: y | Prüfe.", d).split(" | ", 6)[6]
    pruefe("QUER-KAUFREPO" not in msg and "QUER-FREMD" in msg, "1923: Prüfer ohne Bildauftrag ohne Kaufrepo, mit Fremde Inhalte")
    msg = lauf.mit_kern("START Story | opus | env | repo | main | Story – 2099: z | Schreibe.", d).split(" | ", 6)[6]
    pruefe(msg == "**Story**\\nPROFIL-STORY\\nzweite Zeile\\n\\nAuftrag: Schreibe.", "1923: ohne Vorgangsdatei nur Profil und Nachricht: " + msg)
    pruefe(not lauf.STARTBLOCK_FEHLT, "1923: Fehlteile gemeldet, obwohl alle Dateien da: %s" % lauf.STARTBLOCK_FEHLT)
    msg = lauf.mit_kern("START Kampf | opus | env | repo | main | Kampf – 2001: x | Bau.", d).split(" | ", 6)[6]
    pruefe(("Kampf", "Kampf") in lauf.STARTBLOCK_FEHLT, "1923: fehlendes Fachprofil nicht gemeldet: %s" % lauf.STARTBLOCK_FEHLT)
    pruefe(msg.startswith("**Signatur und Leben**") and "Auftrag: 1. **Ziel:**" in msg, "1923: ohne Fachprofildatei fehlt nur dieser Teil: " + msg[:80])
    t = "START Sokrates | opus | env | repo | main | Sokrates – 2001: x | Weiter."
    pruefe("QUER-" not in lauf.mit_kern(t, d), "1923: Sokrates ohne Startblock")
finally:
    lauf.NEU_LISTE = False
    del lauf.STARTBLOCK_FEHLT[:]
print("lauf_kern_test: %s" % ("gut" if not fehler else "%d Fehler" % fehler))
sys.exit(1 if fehler else 0)
