#!/usr/bin/env python3
"""Test Namenswächter regelcheck.py --namen (870): liest Godot-Spiel und die Quellen der Kopien nach godot/.

Fall 1 (künstlich): Quelle einer Kopie mit altem Namen wird gefunden; Kommentar und „_“-Feld zählen nicht (870.13);
eine Datei in tools/ ohne Kopierschritt zählt nicht; Zwischennamen aus „(Zwischennamen … entfallen)“ zählen (870-Ü3);
erzeugte Textdateien: Eingabe der Prüfliste (docs/entwurf/t<n>-….md) und Zeichenkette eines Erzeugers in tools/blender348 zählen,
Kommentar im Erzeuger nicht; jeder Schritt nach godot/ steht mit Herkunft in der Liste.
Fall 2 (Fund Fenja 22.11.): frischer Checkout an 2c8ee7a4d ohne Import (ohne godot/daten/werte.json) meldet Zombie und Ghul;
fehlt der Commit (flacher Checkout wie in werkzeuge.yml), holt der Test ihn flach nach (870-Ü3); geht das nicht: falsch.
Aufruf: python3 tools/regelcheck_namen_test.py   (Exit 0 = grün)
"""
import os, subprocess, sys, tempfile

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
RC = os.path.join(ROOT, "tools", "regelcheck.py")
fehler = 0


def pruefe(ok, was):
    global fehler
    print(("OK    " if ok else "FALSCH ") + was)
    fehler += 0 if ok else 1


def schreibe(wurzel, pfad, text):
    p = os.path.join(wurzel, pfad)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    open(p, "w", encoding="utf-8").write(text)


def lauf(wurzel):
    r = subprocess.run([sys.executable, RC, "--namen", wurzel], capture_output=True, text=True)
    return r.returncode, r.stdout + r.stderr


BRS = ("# BRS\n\n## 12. Namen\n\n| Alt | Neu |\n| --- | --- |\n| Zombie, Ghul | Wiedergänger, Grabhund |\n"
       "| Stirge, Ockergallerte | Riesenegel, Säureschnecke (Zwischennamen Blutflügler, Ockerschleim entfallen; 348.12c A) |\n\n## 13. Offen\n")

# Fall 1
with tempfile.TemporaryDirectory() as t:
    schreibe(t, "docs/DESIGN-BRS.md", BRS)
    schreibe(t, "godot/skripte/a.gd", 'var x := 1  # Zombie im Kommentar\nvar s := "# kein Kommentar"\n')
    schreibe(t, "godot/daten/b.json", '{"_quelle": "Zombie", "name": "Wiedergänger"}')
    schreibe(t, "godot/tests/c.gd", 'var z := "Stirge"\n')
    schreibe(t, ".github/workflows/bau.yml", "      - run: |\n          cp tools/w/werte.json godot/daten/   # Kopie\n"
             "          python3 tools/pruefliste.py godot/daten/pruefliste.json\n          D=godot/kampf/daten\n"
             "          cp $OUT/wolf-info.json $D/ && cp $OUT/wolf.glb $D/wolf.bin\n          cp -r \"$s\" godot/addons/\n")
    schreibe(t, "tools/pruefliste.py", "# Prüfliste\n")
    schreibe(t, "docs/entwurf/t5-probe.md", "# Prüfliste Build 5\n| 5.1 | Kampf | Ockerschleim greift an |\n")
    schreibe(t, "tools/blender348/wolf.py", 'n = "Blutflügler"   # Zombie im Kommentar\n')
    schreibe(t, "tools/w/werte.json", '{"_info": "Stirge", "monster": {"Ghul": {"leben": 1}}}')
    schreibe(t, "tools/w/frei.json", '{"Stirge": 1}')
    rc, aus = lauf(t)
    pruefe(rc == 1, "Fall 1: Exit 1 bei altem Namen in der Quelle einer Kopie (%d)" % rc)
    pruefe("Schritt bau.yml:2: tools/w/werte.json -> godot/daten/ [lesbar]" in aus, "Fall 1: Kopierschritt gelistet")
    pruefe("ALT Ghul: tools/w/werte.json" in aus, "Fall 1: Ghul in tools/w/werte.json gefunden")
    pruefe("Zombie" not in aus.replace("tools/w", ""), "Fall 1: Kommentar und „_“-Feld zählen nicht")
    pruefe("ALT Stirge" not in aus, "Fall 1: tests/ und tools/ ohne Kopierschritt zählen nicht")
    pruefe("ALT Ockerschleim: docs/entwurf/t5-probe.md" in aus, "Fall 1: Zwischenname in der Eingabe der Prüfliste gefunden")
    pruefe("ALT Blutflügler: tools/blender348/wolf.py" in aus, "Fall 1: Zwischenname in einer Zeichenkette des Erzeugers gefunden")
    pruefe("Schritt bau.yml:3: tools/pruefliste.py -> godot/daten/pruefliste.json [erzeugt von tools/pruefliste.py" in aus, "Fall 1: Prüfliste als erzeugt gelistet")
    pruefe("Schritt bau.yml:5: $OUT/wolf-info.json -> godot/kampf/daten/ [erzeugt von tools/blender348" in aus, "Fall 1: info.json mit Erzeuger gelistet ($D aufgelöst)")
    pruefe("Schritt bau.yml:5: $OUT/wolf.glb -> godot/kampf/daten/wolf.bin [binär]" in aus, "Fall 1: Modell als binär gelistet")
    pruefe("Schritt bau.yml:6: $s -> godot/addons/ [fremd" in aus, "Fall 1: Kaufrepo als fremd gelistet")
    schreibe(t, "tools/w/werte.json", '{"monster": {"Grabhund": {"leben": 1}}}')
    schreibe(t, "docs/entwurf/t5-probe.md", "# Prüfliste Build 5\n| 5.1 | Kampf | Säureschnecke greift an |\n")
    schreibe(t, "tools/blender348/wolf.py", 'n = "Riesenegel"   # Zombie im Kommentar\n')
    rc, aus = lauf(t)
    pruefe(rc == 0 and "keine alten Namen" in aus, "Fall 1: nach Umbenennung grün (%d)" % rc)

# Fall 2
SHA = "2c8ee7a4dc3b2c101c97bbc64b4ecdb2d1d8b309"
da = lambda: subprocess.run(["git", "-C", ROOT, "cat-file", "-e", SHA + "^{commit}"], capture_output=True).returncode == 0
if not da():   # 870-Ü3: flacher Checkout (werkzeuge.yml): den einen Commit flach nachholen
    subprocess.run(["git", "-C", ROOT, "fetch", "-q", "--no-tags", "--depth=1", "origin", SHA], capture_output=True)
pruefe(da(), "Fall 2: Commit %s da (sonst flach nachgeholt)" % SHA[:9])
if da():
    with tempfile.TemporaryDirectory() as t:
        endungen = (".gd", ".tscn", ".tres", ".json", ".csv", ".txt", ".cfg")
        alle = subprocess.run(["git", "-C", ROOT, "ls-tree", "-r", "--name-only", SHA], capture_output=True, text=True).stdout.splitlines()
        pfade = [p for p in alle if p.startswith(".github/workflows/") or p == "docs/DESIGN-BRS.md" or p.startswith("tools/") and p.endswith(".json")
                 or p.startswith("godot/") and p.endswith(endungen)]
        a = subprocess.run(["git", "-C", ROOT, "archive", SHA, "--"] + pfade, capture_output=True, check=True)
        subprocess.run(["tar", "-x", "-C", t], input=a.stdout, check=True)
        pruefe(not os.path.exists(os.path.join(t, "godot", "daten", "werte.json")), "Fall 2: an %s ohne Import keine Kopie godot/daten/werte.json" % SHA[:9])
        rc, aus = lauf(t)
        pruefe(rc == 1 and "ALT Zombie" in aus and "ALT Ghul" in aus, "Fall 2: an %s ohne Import Zombie und Ghul gemeldet (%d)" % (SHA[:9], rc))

print("regelcheck_namen_test: %s" % ("grün" if not fehler else "%d falsch" % fehler))
sys.exit(1 if fehler else 0)
