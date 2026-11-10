#!/usr/bin/env python3
"""Regelabgleich (167.9): was ein Skript zählen oder vergleichen kann, damit keine Sitzung es tun muss.

Aufruf: python3 tools/regelcheck.py [--kurz] [--anlass SHA] | --rueckmeldung [--um "TT.MM. HH:MM"]   (--rueckmeldung: nur Prüfung 559, ruft lauf.py stündlich; --um: Stand aus Git zu dieser Zeit; --kurz: nur Pflegefehler der Vorräte, Teil 1 und 2; ruft notiz.sh beim Start)    (Ford ruft es im Morgenlauf, Ausgabe in die Zeile „Morgen“ im Protokoll, 783 W7)
Prüft: startbar.py (unlesbare oder ungültige Zeilen der Vorgangsliste, 275.2), Größen (Vorräte 15 KB, CLAUDE.md),
Zeilen über 1 500 Zeichen in Vorräten, Testbuilds am Tag (höchstens 6, 317), tote Verweise auf `Datei.md` / `tools/x` / `docs/…`, alte Dateinamen (notiz.sh), Lizenzhinweis SRD (446: Meldezeile, solange alte Namen im Spiel; Fund, wenn der Hinweis dann fehlt).
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

# 559 (Chef 04.11., 16:18; Anlass 557 zwei Stunden „wartet auf Chef“ nach seiner Rückmeldung): wartet eine Zeile auf den Chef
# (Stand „wartet auf Chef…“ im Vorrat oder „Chef“ in LISTE-VORGAENGE.md) und gibt es eine neuere Rückmeldung (Zeile „Zu <Nr>“ mit
# „Chef TT.MM., HH:MM“, oder Archiveintrag „- **<Nr>…** (TT.MM., HH:MM“) als den letzten Commit der Chefsache-Datei zur Nummer, dann melden.
# Ohne Datei in der Geschichte kein Bezugspunkt, keine Meldung. --rueckmeldung [--um "TT.MM. HH:MM"]: nur diese Prüfung, Zeilen für lauf.py.
def rueckmeldung(um=None):
    import datetime, zoneinfo
    sys.path.insert(0, os.path.join(ROOT, "tools")); import startbar
    tz = zoneinfo.ZoneInfo("Europe/Berlin")
    rev = None
    if um:
        rev = subprocess.run(["git", "-C", ROOT, "rev-list", "-1", "--before=" + um, "HEAD"], capture_output=True, text=True,
                             env=dict(os.environ, TZ="Europe/Berlin")).stdout.strip() or None
    jetzt = datetime.datetime.strptime(um, "%Y-%m-%d %H:%M").replace(tzinfo=tz) if um else datetime.datetime.now(tz)
    def inhalt(name):
        if rev: return subprocess.run(["git", "-C", ROOT, "show", "%s:docs/%s" % (rev, name)], capture_output=True, text=True).stdout
        p = os.path.join(DOCS, name); return lesen(p) if os.path.exists(p) else ""
    def zt(tt, mm, hh, mi):
        try: return datetime.datetime(jetzt.year, int(mm), int(tt), int(hh), int(mi), tzinfo=tz)
        except ValueError: return None
    def k(nr): return re.sub(r"[*.\s]", "", nr).lower()
    wartend = {}  # Schlüssel → (Nr, Rollen, Dateikürzel)
    for d in startbar.vorgangsliste(inhalt("LISTE-VORGAENGE.md")):  # 275.2: „wartet auf Chef[ <Datei>]“ oder Stand „Chef“
        chef = [t for t in d["warte"] if startbar.art(t) == "chef"]
        if not chef and d["wort"] != "Chef": continue
        e = wartend.setdefault(k(d["nr"]), (d["nr"], set(), {k(d["nr"])}))
        e[1].add(d["besitzer"])  # Datei, auf die das Feld zeigt („Chef 503a“), zählt mit (503 wartete auf 503a)
        e[2].update(k(t.split(" ", 1)[1]) for t in chef if " " in t)
    if not wartend: return []
    rueck = {}  # Schlüssel → (jüngste Zeit, Herkunft)
    def neu(key, d, her):
        if d and d <= jetzt and (key not in rueck or d > rueck[key][0]): rueck[key] = (d, her)
    CHEF = re.compile(r"Chef (\d\d)\.(\d\d)\.,? (\d\d):(\d\d)(?:\s*[–-]\s*(\d\d):(\d\d))?")
    for datei, rolle in startbar.ROLLEN + [("ARBEIT-BETRIEB.md", "Ford")]:
        for z in inhalt(datei).splitlines():
            m = re.match(r"^- \*\*Zu ([^:(]*?)(?:, von [^:(]*)?(?: \(|:)", z)
            if not m: continue
            nrn = [k(n) for n in re.findall(r"\d+[a-z]?(?:\.\d+[a-z]?)?", m.group(1))]
            for c in CHEF.finditer(z):
                d = zt(c.group(1), c.group(2), c.group(5) or c.group(3), c.group(6) or c.group(4))
                for n in nrn: neu(n, d, "Zu %s in %s" % (n, datei))
    for z in inhalt("VORGANGSARCHIV.md").splitlines():
        m = re.match(r"^- \*\*([^*]+)\*\* \((\d\d)\.(\d\d)\.,? (\d\d):(\d\d)", z)
        if not m: continue
        for n in re.findall(r"(?<![\w.])\d+[a-z]?(?:\.\d+[a-z]?)?(?![\w.])", m.group(1).split(",")[0]):
            neu(k(n), zt(*m.groups()[1:]), "Vorgangsarchiv")
    aus = []
    for key, (nr, rollen, dateien) in sorted(wartend.items()):
        treffer = [rueck[x] for x in dateien if x in rueck]
        if not treffer: continue
        r = subprocess.run(["git", "-C", ROOT, "log", "-1", "--format=%ct"] + ([rev] if rev else []) + ["--"] + [":(glob)docs/chefsache/*/%s-*.md" % x for x in sorted(dateien)],
                           capture_output=True, text=True).stdout.strip()
        if not r: continue
        datei_zeit = datetime.datetime.fromtimestamp(int(r), tz)
        d, her = max(treffer)
        if d > datei_zeit:
            aus.append((nr, sorted(rollen), d, "%s: Rückmeldung des Chefs da (%s, %s; Chefsache zuletzt %s), Stand nachziehen (559)" % (
                nr, d.strftime("%d.%m., %H:%M"), her, datei_zeit.strftime("%d.%m., %H:%M"))))
    return aus

if "--rueckmeldung" in sys.argv:
    um = sys.argv[sys.argv.index("--um") + 1] if "--um" in sys.argv else None
    if um and re.match(r"^\d\d\.\d\d\. \d\d:\d\d$", um): um = "2026-%s-%s %s" % (um[3:5], um[0:2], um[-5:])
    for nr, rollen, d, text in rueckmeldung(um): print("RÜCKMELDUNG %s | %s | %s | %s" % (nr, ", ".join(rollen), d.strftime("%d.%m. %H:%M"), text))
    sys.exit(0)

# 1. startbar.py
r = subprocess.run([sys.executable, os.path.join(ROOT, "tools", "startbar.py")], capture_output=True, text=True)
for z in r.stdout.splitlines():
    if "UNLESBAR" in z or "PAUSE" in z and "nicht lesbar" in z:
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
# Test ohne Datei (Sokrates 22.10.; 275.2 Automatik B): Zeile „zu testen“ mit Build n nur, solange docs/chefsache/ansehen/tn-*.md liegt;
# ist die Prüfliste weg (getestet), fehlt `vorgang.py build n`
an = os.listdir(os.path.join(DOCS, "chefsache", "ansehen")) if os.path.isdir(os.path.join(DOCS, "chefsache", "ansehen")) else []
sys.path.insert(0, os.path.join(ROOT, "tools")); import startbar
ohne_pl = {}
for d in startbar.zeilen_liste():
    b = d.get("build", "–")
    if d["wort"] in ("zu testen", "gebaut") and re.fullmatch(r"\d+", b or "") and not any(f.startswith("t%s-" % b) for f in an) and \
            re.search(r"(?m)^- \*\*t%s\b" % b, lesen(os.path.join(DOCS, "VORGANGSARCHIV.md"))):
        ohne_pl.setdefault(b, []).append(d["nr"])
for b, nrs in sorted(ohne_pl.items()):
    fund.append("LISTE-VORGAENGE.md: Build %s getestet (Archiv t%s), aber %s noch „zu testen“: `vorgang.py build %s` (Automatik B, 275.2)" % (b, b, ", ".join(nrs[:8]), b))
# Gemeinsamer Build (317): höchstens 6 Testbuilds am Tag für Tom und Jerry zusammen; gezählt: neue Prüflisten tNN in docs/chefsache/ansehen/ heute
heute = subprocess.run(["git", "-C", ROOT, "log", "--since=" + max(time.strftime("%Y-%m-%d 00:00"), "2026-10-22 21:32"), "--diff-filter=A", "--name-only", "--format=", "--", "docs/chefsache/ansehen/"],
                       capture_output=True, text=True, env=dict(os.environ, TZ="Europe/Berlin")).stdout.split()
tb = sorted({m.group(1) for f in heute for m in [re.search(r"/(t\d+)-", f)] if m})
if len(tb) > 6: fund.append("Testbuilds heute: %d (%s), höchstens 6 für Tom und Jerry zusammen (317, LISTE-CHECK-BUILD-TEST.md Punkt 3)" % (len(tb), ", ".join(tb)))
# 347 (H): Start der Entwicklung liest Abschnitte über ihre Überschrift; fehlt ein Anker, lädt der Befehl still alles oder nichts
for datei, anker in (("ARBEIT-TEAM-TOM.md", "## Einzelheiten"), ("ARBEIT-TEAM-JERRY.md", "## Einzelheiten"),
                     ("DESIGN-STIL.md", "## Auf einen Blick"), ("DESIGN-STIL.md", "## Signatur")):
    pf = os.path.join(DOCS, datei)
    if os.path.exists(pf) and not any(z.startswith(anker) for z in lesen(pf).splitlines()):
        fund.append("%s: Überschrift „%s“ fehlt, Startbefehl in ROLLE-ENTWICKLUNG.md liest danach (347)" % (datei, anker))
# Zielvereinbarung Perikles (341): Z1 Tagesbericht (448) höchstens 26 h alt (über einen Sonntag 50 h);
# Z2 jeder rote Block hat binnen 24 h eine Chefsache von Perikles mit „Block (x)“ in der Kurz-Zeile. Rot seit: „rot seit TT.MM., HH:MM“, sonst Zeit des Stands.
def zeitpunkt(tt, mm, hh, mi):
    return time.mktime(time.strptime("2026-%s-%s %s:%s" % (mm, tt, hh, mi), "%Y-%m-%d %H:%M"))
os.environ["TZ"] = "Europe/Berlin"; time.tzset()
ab = lesen(os.path.join(DOCS, "PROJEKTPLAN.md"))
st = re.search(r"\*\*Stand (\d\d)\.(\d\d)\., (\d\d):(\d\d)", lesen(os.path.join(DOCS, "ARBEIT-TAGESBERICHT.md")))  # 448: Tagesbericht statt Stand zum Marktstart
if not st:
    fund.append("ARBEIT-TAGESBERICHT.md: kein „**Stand TT.MM., HH:MM“ (341 Z1, 448; tools/tagesbericht.py, Perikles)")
else:
    t0 = zeitpunkt(*st.groups()); jetzt = time.time()
    grenze = 50 if any(time.localtime(t0 + 3600 * h).tm_wday == 6 for h in range(0, int((jetzt - t0) / 3600) + 1)) else 26
    if jetzt - t0 > grenze * 3600:
        fund.append("ARBEIT-TAGESBERICHT.md: Tagesbericht %d Stunden alt (höchstens %d, 341 Z1, 448): Perikles setzt ihn neu" % ((jetzt - t0) / 3600, grenze))
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
# 275.2: LISTE-VORGAENGE.md hat keine Größengrenze mehr (keiner liest sie ganz, vorgang.py --rolle); Form prüft startbar.py (UNLESBAR)

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
        # 813 (D123.1): Pfad relativ zu docs/ oder docs/chefsache/ (kapitel2/…, chefsache/README.md, tun/…) gilt auch
        if v in bekannt or v.lstrip("./") in bekannt or "docs/" + v.lstrip("./") in bekannt or "docs/chefsache/" + v.lstrip("./") in bekannt or "<" in v or v.startswith("docs/chefsache/") and v.endswith("/"): continue
        if re.search(r"\b(t\d+|[0-9a-f]{7,})\b", v): continue
        tot.setdefault(os.path.basename(p), set()).add(v)
for d, vs in tot.items(): fund.append("%s: Verweis auf fehlende Datei: %s" % (d, ", ".join(sorted(vs)[:6])))

# 4. alte Dateinamen
alt = r"(ARBEIT-TOM|ARBEIT-JERRY|ARBEIT-FORD|AGENTEN-REGELN|PROJEKT-STAND|BERATER-VORRAT)\.md"
for p in quellen:
    if p.endswith("ARBEIT-ARCHIV.md") or not os.path.exists(p): continue
    m = re.search(alt, lesen(p))
    if m: fund.append("%s: alter Dateiname %s" % (os.path.basename(p), m.group(0)))

# 4a. Statusfeld (275): Wortliste, Felder und „wartet auf“ prüft startbar.py (Teil 1, „UNLESBAR“); vorgang.py schreibt nur Gültiges

# 4b. Lizenzhinweis SRD (446; Chef 01.11., 09:41, 413a): alte Namen aus Nachschlagewerk Abschnitt 12 („Alt“) im Godot-Spiel (ohne tests/).
# Solange einer steht: Meldezeile (kein Fund); fehlt dann der Hinweis „SRD 5.1 · CC BY 4.0“ im Hauptmenü oder README: Fund (Lizenz).
# Allgemeine Wörter (Schild, Vorteil, Nachteil) sieht die Suche nicht; Monsterwerte und Zaubertexte auch nicht: die prüft ein Mensch vor dem Wegfall.
nw = os.path.join(DOCS, "DESIGN-BRS.md")
abschnitt = lesen(nw).split("\n## 12. ")[1].split("\n## ")[0] if "\n## 12. " in lesen(nw) else ""
srd = []
for z in abschnitt.splitlines():
    s = [x.strip() for x in z.split("|")]
    if len(s) < 4 or s[1] in ("Alt", "---", ""): continue
    for n in re.split(r"[,/]", re.sub(r"\s*\(.*?\)", "", s[1])):
        n = re.sub(r"^Klassen\s+", "", n.strip())
        if n and n not in ("Schild", "Vorteil", "Nachteil"): srd.append(n)
srd_info = None
if not srd:
    fund.append("DESIGN-BRS.md: Abschnitt „12. Namen“ ohne Tabelle Alt/Neu, Wächter Lizenzhinweis blind (446)")
else:
    muster = re.compile(r"(?<!\w)(%s)(?!\w)" % "|".join(map(re.escape, srd)))
    treffer = {}
    for d, _, fs in os.walk(os.path.join(ROOT, "godot")):
        if "tests" in os.path.relpath(d, ROOT).split(os.sep): continue
        for f in fs:
            if not f.endswith((".gd", ".tscn", ".tres", ".json", ".csv", ".txt", ".cfg")): continue
            for m in muster.finditer(lesen(os.path.join(d, f))): treffer.setdefault(m.group(1), set()).add(f)
    if treffer:
        srd_info = "Lizenzhinweis SRD bleibt (446): %d alte Namen aus Nachschlagewerk 12 im Godot-Spiel, z. B. %s" % (
            len(treffer), ", ".join("%s (%d)" % (n, len(fs)) for n, fs in sorted(treffer.items(), key=lambda x: -len(x[1]))[:6]))
        for p in (os.path.join(ROOT, "godot", "skripte", "hauptmenue.gd"), os.path.join(ROOT, "README.md")):
            if not os.path.exists(p) or "SRD 5.1" not in lesen(p):
                fund.append("%s: Hinweis „SRD 5.1 · CC BY 4.0“ fehlt, aber SRD-Namen stehen noch im Spiel (Lizenz CC BY 4.0, 446)" % os.path.relpath(p, ROOT))
    else:
        srd_info = "Lizenzhinweis SRD (446): keine alten Namen aus Nachschlagewerk 12 mehr im Godot-Spiel; Monsterwerte, Zaubertexte, Schild/Vorteil/Nachteil von Hand prüfen, dann Chefsache: Hinweis darf fallen"

# 5. Anlass
if "--anlass" in sys.argv:
    sha = sys.argv[sys.argv.index("--anlass") + 1]
    o = subprocess.run(["git", "-C", ROOT, "diff", "--name-only", sha, "HEAD", "--", "CLAUDE.md", "docs/ROLLE-*", "docs/LISTE-BETRIEB.md", "docs/VORGANGSARCHIV.md"],
                       capture_output=True, text=True).stdout.split()
    print("Anlass seit %s: %s" % (sha, ", ".join(o) if o else "keine Regeldatei geändert → kein Lauf Diogenes"))

if srd_info: print(srd_info)
print("Regelcheck: %s" % ("%d Fund(e)" % len(fund) if fund else "ohne Fund"))
for z in fund: print("  - " + z)
sys.exit(1 if fund else 0)
