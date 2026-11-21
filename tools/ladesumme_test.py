#!/usr/bin/env python3
"""1739: ladesumme.py misst Teile (ganze Datei oder je Block ```markdown), Summe je Sitzung nach laden.json, vorher/nachher per Git."""
import json, os, subprocess, sys, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ladesumme as L

fehler = []
def soll(name, ok):
    print(("ok   " if ok else "ROT  ") + name)
    if not ok: fehler.append(name)

d = tempfile.mkdtemp()
subprocess.run(["git", "init", "-q", d]); L.ROOT = d
open(os.path.join(d, "sockel.md"), "w").write("Äb\n")  # 4 Byte UTF-8
open(os.path.join(d, "profil.md"), "w").write("# Kopf\n\nTeil A\n```markdown\nabc\n```\nTeil B\n```markdown\nde\n```\n")
json.dump({"Sitzungen": {"Fachkraft": ["sockel.md", "profil.md#2"], "Alles": ["sockel.md", "profil.md"], "Lücke": ["kern.md"]}},
          open(os.path.join(d, "laden.json"), "w"))
subprocess.run(["git", "-C", d, "add", "-A"]); subprocess.run(["git", "-C", d, "-c", "user.email=t@t", "-c", "user.name=t", "commit", "-qm", "a"])
e = L.messen([d])
soll("ganze Datei UTF-8", e.get("sockel.md") == 4)
soll("je Block ein Teil mit Zeile darüber", e.get("profil.md#1 (Teil A)") == 4 and e.get("profil.md#2 (Teil B)") == 3)
s = L.summen(e, json.load(open(os.path.join(d, "laden.json"))))
soll("Summe mit Blockteil", s["Fachkraft"] == (7, []))
soll("Summe ganze Datei = alle Blöcke", s["Alles"] == (11, []))
soll("fehlender Teil genannt", s["Lücke"] == (0, ["kern.md"]))
open(os.path.join(d, "sockel.md"), "w").write("Äbcd\n")
t = L.tabelle_neu([d], "HEAD")
soll("vorher/nachher je Teil", "| sockel.md | 6 | 4 | +2 |" in t)
soll("vorher/nachher je Sitzung", "| Fachkraft | 9 (0,0 KB) | 7 | +2 |" in t)
L.ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
soll("Rolle in --alt", "| Spike |" in L.tabelle_alt())
print("ladesumme_test:", "grün" if not fehler else "ROT: " + "; ".join(fehler))
sys.exit(1 if fehler else 0)
