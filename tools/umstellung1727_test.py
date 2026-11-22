#!/usr/bin/env python3
"""1739 (Bauliste 1727 Schritt 1): Umstellung der Vorgangsliste an einer Kopie: Spalten, Kurztitel mit Herkunft, Block, Eilt,
Profile in „wartet auf“, Bezug, Folge, zweiter Lauf ohne Änderung; dazu Lauf an einer Kopie des echten docs (alle Nummern bleiben)."""
import os, re, shutil, subprocess, sys, tempfile
H = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(H, "umstellung1727")); sys.path.insert(0, H)
import umstellen as U
fehler = []
def soll(name, ok):
    if not ok: fehler.append(name)

d = tempfile.mkdtemp()
os.makedirs(os.path.join(d, "chefsache")); os.makedirs(os.path.join(d, "vorgang"))
open(os.path.join(d, "chefsache", "themenbloecke.md"), "w").write(
    "| Nr. | Themenblock | Fachprofil | Kapitel 1 | ruht bis | Bereiche | Vorgänge |\n|---|---|---|---|---|---|---|\n"
    "| 10 | Regeln | Regeln | ja | – | G Balance | 870 |\n| 3 | Figuren | Figur | ja | – | E Figuren | – |\n"
    "| 4 | Kataloge | Kataloge | ja | – | – | 458 |\n| 7 | Firma | Werkzeug | nein | – | B Werkzeuge | – |\n")
K = "| Nr. | Titel | Besitzer | Kl. | Stand | wartet auf | Zweig | Build | Bereich | Kosten |\n|---|---|---|---|---|---|---|---|---|---|\n"
Z = ["| 1700 | Von Tom (1334): Wiederholrot durchstich_1631: 6× rot in 48 h (Läufe 570, 568); Ursache nachstellen | Tom | M | startbar | Diogenes (greift?) | – | – | B Werkzeuge | 2,56 $ |",
     "| 1716 | Von Chef (18.11., 22:29, „jetzt“ 18.11., 22:29): Buildzweig gehört Spike · „jetzt“ 18.11., 22:29 | Spike | M | gebaut, Geprüft an: c315ec551 | 1700 | – | t301 | B Werkzeuge | 6,50 $ |",
     "| 458.3 | Gegenstandskatalog: Netze, Modelle (Chef 01.11., 458) | Spike | M | startbar | – | claude/x | – | E Technik | – |",
     "| 1621 | Von Chef (18.11., 07:37, A): Großaxt 131→110 cm, Zweihänder 128 cm; siehe 1694 | Spike | M | startbar | Tom | – | – | E Figuren | – |",
     "| 1694 | Von Chef (18.11., 17:01): Griff für alle | Spike | K | startbar | – | – | – | E Figuren | – |",
     "| 131 | alter Vorgang | Tom | K | erledigt | – | – | – | E Figuren | – |",
     "| 1755 | Von Sokrates (Chef 20.11., 14:45), Regelfrage Stufe 2 | Jerry | M | startbar | – | – | – | G Regeln | – |"]
open(os.path.join(d, "LISTE-VORGAENGE.md"), "w").write("# Vorgänge\n\nalter Kopf\n\n- **Regel** eins\n\n" + K + "\n".join(Z) + "\n\nNachsatz\n")
open(os.path.join(d, "vorgang", "1694.md"), "w").write("# 1694 · Griff\n\n## Auftrag (21.11., 10:00)\n\nx\n")
B = U.umstellen(d)
t = open(os.path.join(d, "LISTE-VORGAENGE.md")).read()
zeilen = [U.zellen(z) for z in t.splitlines() if re.match(r"\| \d", z)]
soll("Kopf neu", "| " + " | ".join(U.KOPF_NEU) + " |" in t)
soll("alle Zeilen", sorted(z[0] for z in zeilen) == sorted(z.split(" | ")[0][2:] for z in Z))
soll("Nachsatz bleibt", t.rstrip().endswith("Nachsatz"))
soll("Regel bleibt", "- **Regel** eins" in t)
r = {z[0]: dict(zip(U.KOPF_NEU, z)) for z in zeilen}
soll("Eilt aus jetzt", r["1716"]["Kl."] == "Eilt" and B["eilt"] == ["1716"])
soll("Eilt zuerst", zeilen[0][0] == "1716")
soll("erledigt am Ende", zeilen[-1][0] == "131")
soll("Fund des Chefs vor anderen Muss", [z[0] for z in zeilen[1:5]].index("1621") < [z[0] for z in zeilen[1:5]].index("1700"))
soll("Kurztitel ohne Herkunft", r["1700"]["Titel"] == "Wiederholrot durchstich_1631: 6× rot in 48 h (Läufe 570, 568)")
soll("Kurztitel nach Komma", r["1755"]["Titel"] == "Regelfrage Stufe 2")
soll("Block 4 Kataloge über Unternummer", r["458.3"]["Block"] == "4" and r["458.3"]["Bereich"] == "E Kataloge")
soll("G Regeln Block 10", r["1755"]["Block"] == "10")
soll("Block aus Bereich", r["1700"]["Block"] == "7" and r["1621"]["Block"] == "3")
soll("Profil Prüfer", r["1700"]["wartet auf"] == "Prüfer (greift?)")
soll("Rolle in wartet auf → HAND", any("1621 wartet auf Tom" in h for h in B["hand"]))
soll("Bezug ohne Messwert", r["1621"]["Bezug"] == "1694")
soll("Runde aus Vorgangsdatei", r["1694"]["*Runde*"] == "*1*")
v = open(os.path.join(d, "vorgang", "1716.md")).read()
soll("Herkunft wörtlich", "Herkunft: Von Chef (18.11., 22:29, „jetzt“ 18.11., 22:29): Buildzweig gehört Spike · „jetzt“ 18.11., 22:29" in v)
soll("Besitzer und Build in Herkunft", "Besitzer bis 1727: Spike" in v and "Build: t301" in v)
soll("bestehende Datei ergänzt", "## Auftrag" in open(os.path.join(d, "vorgang", "1694.md")).read())
soll("keine Datei für erledigt", not os.path.exists(os.path.join(d, "vorgang", "131.md")))
vorher = t
soll("zweiter Lauf", U.umstellen(d) is None and open(os.path.join(d, "LISTE-VORGAENGE.md")).read() == vorher)
shutil.rmtree(d)

# echte Liste an einer Kopie: jede Nummer bleibt, jede Zeile 12 Zellen, Block bekannt, Bereich gültig
quelle = "/home/user/bornim-main/docs" if os.path.isdir("/home/user/bornim-main/docs") else os.path.join(os.path.dirname(H), "docs")
if os.path.exists(os.path.join(quelle, "LISTE-VORGAENGE.md")):
    import bereiche
    k = tempfile.mkdtemp()
    for f in ("LISTE-VORGAENGE.md", "LISTE-VORGAENGE-ARCHIV.md"):
        if os.path.exists(os.path.join(quelle, f)): shutil.copy(os.path.join(quelle, f), k)
    os.makedirs(os.path.join(k, "chefsache"))
    shutil.copy(os.path.join(quelle, "chefsache", "themenbloecke.md"), os.path.join(k, "chefsache"))
    if os.path.isdir(os.path.join(quelle, "vorgang")): shutil.copytree(os.path.join(quelle, "vorgang"), os.path.join(k, "vorgang"))
    alt = [z.split(" | ")[0][2:] for z in open(os.path.join(k, "LISTE-VORGAENGE.md")) if re.match(r"\| \d", z)]
    if alt and "| Besitzer |" in open(os.path.join(k, "LISTE-VORGAENGE.md")).read():
        B = U.umstellen(k)
        neu = [U.zellen(z) for z in open(os.path.join(k, "LISTE-VORGAENGE.md")).read().splitlines() if re.match(r"\| \d", z)]
        soll("echt: Nummern gleich", sorted(alt) == sorted(z[0] for z in neu))
        soll("echt: 12 Zellen", all(len(z) == 12 for z in neu))
        soll("echt: Bereich gültig", all(bereiche.gueltig(z[3]) or z[8].startswith("*erledigt") for z in neu))
        soll("echt: Titel kurz", all(len(z[1]) <= U.KURZ + 2 or z[8].startswith("*erledigt") for z in neu))
    shutil.rmtree(k)

print("umstellung1727_test:", "grün" if not fehler else "ROT: " + "; ".join(fehler))
sys.exit(1 if fehler else 0)
