#!/usr/bin/env python3
"""1739, 1866, 1922: ladesumme.py, ein Werkzeug, ein Test: Messregel, Codeblöcke je Überschrift, Tabelle der Teile und Sitzungsarten
(Werte wie herausgezogen.md), freie Messung je Datei oder Block ```markdown, Summe nach laden.json, vorher/nachher per Git."""
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
soll("ganze Datei UTF-8 nach Messregel (ohne letztes Zeilenende)", e.get("sockel.md") == 3)
soll("je Block ein Teil mit Zeile darüber", e.get("profil.md#1 (Teil A)") == 3 and e.get("profil.md#2 (Teil B)") == 2)
s = L.summen(e, json.load(open(os.path.join(d, "laden.json"))))
soll("Summe mit Blockteil", s["Fachkraft"] == (5, []))
soll("Summe ganze Datei = alle Blöcke", s["Alles"] == (8, []))
soll("fehlender Teil genannt", s["Lücke"] == (0, ["kern.md"]))
open(os.path.join(d, "sockel.md"), "w").write("Äbcd\n")
t = L.tabelle_neu([d], "HEAD")
soll("vorher/nachher je Teil", "| sockel.md | 5 | 3 | +2 |" in t)
soll("vorher/nachher je Sitzung", "| Fachkraft | 7 (0,0 KB) | 5 | +2 |" in t)
soll("Messregel: ohne Kopf, Leerzeile, bis ##, ohne Zeilenende", L.messregel("# Kopf\n\nZeile ä\n\n## Rest\nx\n") == len("Zeile ä".encode()))
soll("Messregel ohne Kopfzeile", L.messregel("Text\n") == 4)
t = "## 1 Sockel\n\nvor\n```markdown\n# K\nabc\n```\n### 1.1 Unter\n```\nxy\n```\n## 2\n```\nzzz\n```\n"
soll("Codeblöcke je Überschrift, „# “ im Block beendet nicht", L.block(t, "## 1 Sockel") == 7 and L.block(t, "## 1 Sockel", 2) == 2 and L.block(t, "### 1.1 Unter") == 2 and L.block(t, "## 2") == 3)
soll("Block fehlt → None", L.block(t, "## 9") is None and L.block(t, "## 1 Sockel", 3) is None)
# Tabelle an festem Stand a87f37fe1 (Entwürfe wie herausgezogen.md, 22.11.): Messregel (Wache 949, nicht 950); fehlt der Stand (flacher
# Checkout im CI), nur genannt. Spätere Änderungen an den Entwürfen machen den Test nicht rot.
STAND = "a87f37fe1"
L.ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if subprocess.run(["git", "-C", L.ROOT, "cat-file", "-e", STAND + "^{commit}"], capture_output=True).returncode == 0:
    werte = {"Sockel": 1109, "Kern Büro": 680, "Profil Disponent": 3775, "Kern Abnahme": 1567, "Profil Prüfer": 2831, "Routine Wache": 949}
    for n, w in werte.items():
        b = L.teil_byte(n, STAND)[0]
        soll("%s %s Byte am Stand %s (herausgezogen.md %s)" % (n, b, STAND, w), b == w)
    tab = "\n".join(L.tabelle(STAND))
    soll("Summe je Sitzungsart mit vorher (Disponent 5.564, Prüfer 5.507, Wache 2.058)",
         "← 5.564" in tab and "← 5.507" in tab and "← 2.058" in tab)
else:
    print("…    Stand %s fehlt (flacher Checkout): Werte nicht geprüft" % STAND)
# Tabelle mit Grenze an einer eigenen Wurzel
g = tempfile.mkdtemp(); L.ROOT = g
os.makedirs(os.path.join(g, L.M)); open(os.path.join(g, L.G), "w").write("# G\n\n## 1 Sockel\n```markdown\n" + "x" * 1300 + "\n```\n")
open(os.path.join(g, L.M, "routine-wache.md"), "w").write("# W\n\n## Text\n```\nwache\n```\n")
tab = "\n".join(L.tabelle())
soll("Grenze überschritten wird markiert", "| Sockel | 1.300 **über Grenze** | 1.200 |" in tab)
soll("Sitzungsart mit fehlendem Teil „–“, vollständige summiert", "| Leitung | – |" in tab and "| Routine Wache | 1.305 |" in tab)
os.makedirs(os.path.join(g, "docs", "profile")); open(os.path.join(g, "docs", "profile", "Wache.md"), "w").write("# Wache\n\nab\n")
soll("nach der Umstellung zählt docs/profile/<Profil>.md", L.teil_byte("Routine Wache") == (2, "docs/profile/Wache.md"))
soll("main ohne Pfad: Tabelle der Sitzungsarten", L.main([]) == 0)
soll("Rolle in --alt", "| Spike |" in L.tabelle_alt())
print("ladesumme_test:", "grün" if not fehler else "ROT: " + "; ".join(fehler))
sys.exit(1 if fehler else 0)
