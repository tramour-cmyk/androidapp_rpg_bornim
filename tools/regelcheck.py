#!/usr/bin/env python3
"""Regelabgleich (167.9): was ein Skript zählen oder vergleichen kann, damit keine Sitzung es tun muss.

Aufruf: python3 tools/regelcheck.py [--kurz] [--anlass SHA]   (--kurz: nur Pflegefehler der Vorräte, Teil 1 und 2; ruft notiz.sh beim Start)    (Ford ruft es im Morgenlauf, Ausgabe in die Morgenmeldung)
Prüft: startbar.py (erledigte, nicht gestrichene, unlesbare Zeilen), Größen (Vorräte 15 KB, CLAUDE.md, LISTE-VORGAENGE.md),
Zeilen über 1 500 Zeichen in Vorräten, Testbuilds am Tag (höchstens 6, 317), tote Verweise auf `Datei.md` / `tools/x` / `docs/…`, alte Dateinamen (notiz.sh).
--anlass SHA: nennt die Regeldateien (CLAUDE.md, ROLLE-*, LISTE-BETRIEB.md, VORGANGSARCHIV.md), die seit SHA geändert wurden;
nur dann gehört die Zeile „Widersprüche prüfen“ in ARBEIT-PRUEFUNG.md (Anlass-Lauf Diogenes, einmal im Monat voller Lauf).
Inhaltliche Widersprüche sieht das Skript nicht. Exit 1, wenn etwas gefunden wurde.
"""
import os, re, sys, glob, subprocess, time

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
DOCS = os.path.join(ROOT, "docs")
fund = []

def lesen(p):
    return open(p, encoding="utf-8").read()

def gross(pfad, grenze, was):
    n = os.path.getsize(pfad)
    if n > grenze: fund.append("%s: %d Bytes (Grenze %d), %s" % (os.path.relpath(pfad, ROOT), n, grenze, was))

# 1. startbar.py
r = subprocess.run([sys.executable, os.path.join(ROOT, "tools", "startbar.py")], capture_output=True, text=True)
for z in r.stdout.splitlines():
    if "ERLEDIGT, NICHT GESTRICHEN" in z or "UNLESBAR" in z or "PAUSE" in z and "nicht lesbar" in z:
        fund.append("startbar.py: " + z.strip()[:200])

# 2. Größen und lange Zeilen
for p in sorted(glob.glob(os.path.join(DOCS, "ARBEIT-*.md"))):
    if p.endswith("ARBEIT-ARCHIV.md"): continue
    gross(p, 15000, "Erledigtes streichen")
    lang = [i + 1 for i, z in enumerate(lesen(p).splitlines()) if z.startswith("| ") and len(z) > 400]
    if lang: fund.append("%s: Tabellenzeilen über 400 Zeichen (Einzelheiten unter die Tabelle, 169): %s" % (os.path.basename(p), ", ".join(map(str, lang[:8]))))
    uebergabe = [z for z in lesen(p).splitlines() if z.startswith("**Übergabe") and len(z) > 700]
    if uebergabe: fund.append("%s: Übergabe über 700 Zeichen (nur Getanes und Nachfolger, Stand gehört in den Vorrat, 121; 165 Tag 2)" % os.path.basename(p))
# Rückfrage ohne Datei (184): "wartet auf Rückfrage <Nr>" nur, wenn docs/chefsache/entscheiden/<Nr>-*.md liegt
cs = os.listdir(os.path.join(DOCS, "chefsache", "entscheiden")) if os.path.isdir(os.path.join(DOCS, "chefsache", "entscheiden")) else []
for p in sorted(glob.glob(os.path.join(DOCS, "ARBEIT-*.md"))):
    if p.endswith(("ARBEIT-ARCHIV.md", "ARBEIT-BETRIEB.md")): continue
    for m in re.finditer(r"wartet auf (?:die )?Rückfrage (\d+[a-z]?\d*[a-z]?)", lesen(p)):
        if not any(f.startswith(m.group(1) + "-") for f in cs):
            fund.append("%s: wartet auf Rückfrage %s ohne Datei in docs/chefsache/entscheiden/ (gilt als nicht gestellt, 184)" % (os.path.basename(p), m.group(1)))
# Test ohne Datei (Sokrates 22.10.): Tabellenzeile mit „wartet“ und tNN nur, wenn docs/chefsache/ansehen/tNN-*.md liegt
an = os.listdir(os.path.join(DOCS, "chefsache", "ansehen")) if os.path.isdir(os.path.join(DOCS, "chefsache", "ansehen")) else []
for p in sorted(glob.glob(os.path.join(DOCS, "ARBEIT-*.md"))):
    if p.endswith("ARBEIT-ARCHIV.md"): continue
    for z in lesen(p).splitlines():
        if not z.startswith("| "): continue
        if "wartet" not in z: continue
        for m in re.finditer(r"(?<![\w/.-])(t\d+)\b", z):
            if not any(f.startswith(m.group(1) + "-") for f in an):
                fund.append("%s: Zeile %s wartet auf %s, aber keine Datei in docs/chefsache/ansehen/ (getestet? Stand nachziehen)" % (os.path.basename(p), z.split("|")[1].strip(), m.group(1)))
# Gemeinsamer Build (317): höchstens 6 Testbuilds am Tag für Tom und Jerry zusammen; gezählt: neue Prüflisten tNN in docs/chefsache/ansehen/ heute
heute = subprocess.run(["git", "-C", ROOT, "log", "--since=" + max(time.strftime("%Y-%m-%d 00:00"), "2026-10-22 21:32"), "--diff-filter=A", "--name-only", "--format=", "--", "docs/chefsache/ansehen/"],
                       capture_output=True, text=True, env=dict(os.environ, TZ="Europe/Berlin")).stdout.split()
tb = sorted({m.group(1) for f in heute for m in [re.search(r"/(t\d+)-", f)] if m})
if len(tb) > 6: fund.append("Testbuilds heute: %d (%s), höchstens 6 für Tom und Jerry zusammen (317, LISTE-BAUEN-TESTEN.md „Gemeinsamer Build“)" % (len(tb), ", ".join(tb)))
# Zielvereinbarung Perikles (341): Z1 Stand zum Marktstart höchstens 26 h alt (über einen Sonntag 50 h);
# Z2 jeder rote Block hat binnen 24 h eine Chefsache von Perikles mit „Block (x)“ in der Kurz-Zeile. Rot seit: „rot seit TT.MM., HH:MM“, sonst Zeit des Stands.
def zeitpunkt(tt, mm, hh, mi):
    return time.mktime(time.strptime("2026-%s-%s %s:%s" % (mm, tt, hh, mi), "%Y-%m-%d %H:%M"))
os.environ["TZ"] = "Europe/Berlin"; time.tzset()
ab = lesen(os.path.join(DOCS, "LISTE-ABNAHME-KAPITEL1.md"))
st = re.search(r"\*\*Stand (\d\d)\.(\d\d)\., (\d\d):(\d\d)", ab)
if not st:
    fund.append("LISTE-ABNAHME-KAPITEL1.md: kein „**Stand TT.MM., HH:MM“ im Stand zum Marktstart (341 Z1, Perikles)")
else:
    t0 = zeitpunkt(*st.groups()); jetzt = time.time()
    grenze = 50 if any(time.localtime(t0 + 3600 * h).tm_wday == 6 for h in range(0, int((jetzt - t0) / 3600) + 1)) else 26
    if jetzt - t0 > grenze * 3600:
        fund.append("LISTE-ABNAHME-KAPITEL1.md: Stand zum Marktstart %d Stunden alt (höchstens %d, 341 Z1): Perikles setzt ihn neu" % ((jetzt - t0) / 3600, grenze))
    teil = ab.split("**1. Stand gegen den Plan**")[-1].split("**2.")[0]
    for z in teil.splitlines():
        sp = [s.strip() for s in z.split("|")]
        if len(sp) < 4 or not sp[2].startswith("rot"): continue
        b = re.match(r"\(([a-f])\)", sp[1])
        if not b: continue
        seit = re.search(r"seit (\d\d)\.(\d\d)\., (\d\d):(\d\d)", sp[2])
        t1 = zeitpunkt(*seit.groups()) if seit else t0
        da = any(re.search(r"Block \(%s\)" % b.group(1), lesen(os.path.join(DOCS, "chefsache", "entscheiden", f))) and "Perikles" in lesen(os.path.join(DOCS, "chefsache", "entscheiden", f)).splitlines()[1:2][0]
                 for f in cs if f.endswith(".md") and len(lesen(os.path.join(DOCS, "chefsache", "entscheiden", f)).splitlines()) > 1)
        if not da and jetzt - t1 > 24 * 3600:
            fund.append("Block (%s) rot seit über 24 Stunden ohne Chefsache von Perikles mit „Block (%s)“ (341 Z2)" % (b.group(1), b.group(1)))
gross(os.path.join(ROOT, "CLAUDE.md"), 15000, "kürzen")
gross(os.path.join(DOCS, "LISTE-VORGAENGE.md"), 15000, "Erledigtes ins Archiv")

if "--kurz" in sys.argv:
    print("Pflegefehler in den Vorräten (regelcheck --kurz): %s" % ("%d" % len(fund) if fund else "keine"))
    for z in fund: print("  - " + z)
    sys.exit(1 if fund else 0)

# 3. tote Verweise auf Dateien
bekannt = set()
for d, _, fs in os.walk(ROOT):
    if ".git" in d.split(os.sep): continue
    for f in fs: bekannt.add(f); bekannt.add(os.path.relpath(os.path.join(d, f), ROOT))
tot = {}
quellen = [os.path.join(ROOT, "CLAUDE.md")] + sorted(glob.glob(os.path.join(DOCS, "ROLLE-*.md"))) + [os.path.join(DOCS, "LISTE-BETRIEB.md")] + sorted(glob.glob(os.path.join(DOCS, "ARBEIT-*.md")))
for p in quellen:
    if p.endswith("ARBEIT-ARCHIV.md") or not os.path.exists(p): continue
    for m in re.finditer(r"`((?:docs/|tools/)?[A-Za-z0-9_./-]+\.(?:md|py|sh|yml))`", lesen(p)):
        v = m.group(1)
        if v in bekannt or v.lstrip("./") in bekannt or "<" in v or v.startswith("docs/chefsache/") and v.endswith("/"): continue
        if re.search(r"\b(t\d+|[0-9a-f]{7,})\b", v): continue
        tot.setdefault(os.path.basename(p), set()).add(v)
for d, vs in tot.items(): fund.append("%s: Verweis auf fehlende Datei: %s" % (d, ", ".join(sorted(vs)[:6])))

# 4. alte Dateinamen
alt = r"(ARBEIT-TOM|ARBEIT-JERRY|ARBEIT-FORD|AGENTEN-REGELN|PROJEKT-STAND|BERATER-VORRAT)\.md"
for p in quellen:
    if p.endswith("ARBEIT-ARCHIV.md") or not os.path.exists(p): continue
    m = re.search(alt, lesen(p))
    if m: fund.append("%s: alter Dateiname %s" % (os.path.basename(p), m.group(0)))

# 5. Anlass
if "--anlass" in sys.argv:
    sha = sys.argv[sys.argv.index("--anlass") + 1]
    o = subprocess.run(["git", "-C", ROOT, "diff", "--name-only", sha, "HEAD", "--", "CLAUDE.md", "docs/ROLLE-*", "docs/LISTE-BETRIEB.md", "docs/VORGANGSARCHIV.md"],
                       capture_output=True, text=True).stdout.split()
    print("Anlass seit %s: %s" % (sha, ", ".join(o) if o else "keine Regeldatei geändert → kein Lauf Diogenes"))

print("Regelcheck: %s" % ("%d Fund(e)" % len(fund) if fund else "ohne Fund"))
for z in fund: print("  - " + z)
sys.exit(1 if fund else 0)
