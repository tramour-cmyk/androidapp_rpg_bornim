#!/usr/bin/env python3
"""Regelabgleich (167.9): was ein Skript zählen oder vergleichen kann, damit keine Sitzung es tun muss.

Aufruf: python3 tools/regelcheck.py [--kurz] [--anlass SHA] | --rueckmeldung [--um "TT.MM. HH:MM"]   (--rueckmeldung: nur Prüfung 559, ruft lauf.py stündlich; --um: Stand aus Git zu dieser Zeit; --kurz: nur Pflegefehler der Vorräte, Teil 1 und 2; ruft notiz.sh beim Start)    (Ford ruft es im Morgenlauf, Ausgabe in die Zeile „Morgen“ im Protokoll, 783 W7)
Prüft: startbar.py (unlesbare oder ungültige Zeilen der Vorgangsliste, 275.2), Größen (Vorräte 30 KB, 1129 A 7; CLAUDE.md 15 KB),
Zeilen über 1 500 Zeichen in Vorräten, Testbuilds am Tag (höchstens 6, 317), tote Verweise auf `Datei.md` / `tools/x` / `docs/…`, alte Dateinamen (notiz.sh), Lizenzhinweis SRD (446: Meldezeile, solange alte Namen im Spiel; Fund, wenn der Hinweis dann fehlt).
--namen [ROOT]: nur der Namenswächter (870): Godot-Spiel, Quellen der Kopien nach godot/ und Erzeuger dort erzeugter Textdateien samt Eingaben (Arbeitsabläufe); listet jeden Schritt nach godot/, auch relativ nach cd godot; Exit 1 bei alten Namen oder unbekanntem Schritt.
--anlass SHA: nennt die Regeldateien (CLAUDE.md, ROLLE-*, LISTE-BETRIEB.md, VORGANGSARCHIV.md), die seit SHA geändert wurden;
nur dann gehört die Zeile „Widersprüche prüfen“ in ARBEIT-PRUEFUNG.md (Anlass-Lauf Diogenes, einmal im Monat voller Lauf).
Inhaltliche Widersprüche sieht das Skript nicht. Exit 1, wenn etwas gefunden wurde.
"""
import os, re, sys, glob, json, subprocess, time

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
    # 1893: nach dem Umzug 1727 stehen die „Zu <Nr>“ in docs/vorgang/<Nr>.md (Abschnitt „Aus dem Vorrat“), Vorräte bleiben bis zum Streichen
    for datei in [d for d, _ in startbar.ROLLEN] + ["ARBEIT-BETRIEB.md"] + ["vorgang/%s.md" % nr for nr, _, _ in wartend.values()]:
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

def ohne_kommentar_gd(text):
    """GDScript ohne Kommentare: ab „#“ ausserhalb einer Zeichenkette bis Zeilenende (870.13)."""
    aus = []
    for z in text.split("\n"):
        q, i = None, 0
        while i < len(z):
            c = z[i]
            if q:
                if c == "\\": i += 1
                elif c == q: q = None
            elif c in "\"'": q = c
            elif c == "#": z = z[:i]; break
            i += 1
        aus.append(z)
    return "\n".join(aus)

def ohne_kommentar_py(text):
    """Python ohne Kommentare (Zeichenketten bleiben); unlesbar: unverändert (870-Ü3)."""
    import io, tokenize
    try: return "\n".join(t.string for t in tokenize.generate_tokens(io.StringIO(text).readline) if t.type == tokenize.STRING)
    except (tokenize.TokenError, SyntaxError, IndentationError): return text

def ohne_info_json(text):
    """JSON ohne Felder, deren Schlüssel mit „_“ beginnt (870.13); unlesbar: unverändert."""
    try: d = json.loads(text)
    except ValueError: return text
    weg = lambda x: {k: weg(v) for k, v in x.items() if not str(k).startswith("_")} if isinstance(x, dict) else [weg(v) for v in x] if isinstance(x, list) else x
    return json.dumps(weg(d), ensure_ascii=False)

# 870 (Fund Fenja 22.11.; Nachbesserung 870-Ü3, Prüferin Petra 22.11., 19:21): der Bau schreibt Dateien nach godot/, die im Checkout
# fehlen (godot/.gitignore). Der Wächter listet darum jeden Schritt der Arbeitsabläufe, der nach godot/ schreibt (cp, -Pout=, Umleitung,
# pruefliste.py), mit Herkunft: „lesbar“ (Datei im Repo, er liest sie), „erzeugt“ (Textdatei aus einem Erzeuger im Repo: er liest den
# Erzeuger ohne Kommentare und dessen Eingaben, ERZEUGER), „binär“ (Modell, Bild, Schrift: kein lesbarer Text) oder „fremd“ (Kaufrepo,
# Bauserver, core: nicht lesbar). Kopien innerhalb godot/ liest er schon unter godot/.
ENDUNGEN = (".gd", ".tscn", ".tres", ".json", ".csv", ".txt", ".cfg")
BINAER = (".glb", ".bin", ".png", ".jpg", ".bild", ".ttf", ".svg")
# Ziel (Muster auf den Dateinamen) -> (Erzeuger, Eingaben); Erzeuger nach Aufruf im Arbeitsablauf (bl/bin/python -I tools/blender348/…)
ERZEUGER = [
    (r"pruefliste\.json$", ["tools/pruefliste.py"], ["docs/chefsache/ansehen/t*.md", "docs/entwurf/t*.md"]),   # godot.yml:111, Reiter „Test“
    (r"(-info|held-klassen|leute-kauf|kampf-bewegungen)\.json$", ["tools/blender348/**/*.py"], ["tools/blender348/**/*.json"]),
]

def _ziele(z, ing=False):
    """Schritte einer Zeile: [(Quelle oder Erzeuger-Aufruf, Ziel unter godot/)]; ing: Arbeitsordner godot/ (870-Ü7, relative Pfade)."""
    def g(p):   # Pfad unter godot/ oder None; „@/“ = $GITHUB_WORKSPACE/ in godot/
        if p.startswith("@/"): return p[2:] if p[2:].startswith("godot/") else None
        if p.startswith("godot/"): return p
        if ing and p and not p.startswith(("/", "$", "~", "&", "..", "-")): return "godot/" + (p[2:] if p.startswith("./") else p)
    aus, z = [], re.sub(r"\$\([^()]*\)", "$(…)", z)   # 870-Ü7: $(basename …) ist ein Wort
    for m in re.finditer(r"\bcp\s+((?:-\w+\s+)*)(.+?)(?=\s*(?:;|&&|\|\||\||\bdone\b|$))", z):
        t = [x.strip("\"'") for x in re.sub(r"\d?>>?\s*\S+", "", m.group(2)).split()]   # 870-Ü7: ohne 2>/dev/null
        if len(t) >= 2 and g(t[-1]): aus += [(g(q) or (q[3:] if ing and q.startswith("../") else q.replace("@/", "")), g(t[-1])) for q in t[:-1]]
    aus += [("gradle " + m.group(1), m.group(2)) for m in re.finditer(r"gradlew -p (\w+) \S+ -Pout=(godot/[^\s;]*)", z)]
    def woher(m):
        v = z[:m.start()]
        gs = re.search(r"git show (\S+:\S+)\s*$", v)
        return "git show " + gs.group(1) if gs else "echo" if re.search(r"\becho\b[^>]*$", v) else "Umleitung"
    aus += [(woher(m), g(m.group(1))) for m in re.finditer(r"(?<![=!<])>>?\s*([A-Za-z_.$@~/][\w./${}*@~-]*)(?=[\s;)|&]|$)", z) if g(m.group(1))]
    aus += [("tee", g(m.group(1))) for m in re.finditer(r"\btee\s+(?:-a\s+)?([^\s;)|&]+)", z) if g(m.group(1))]   # 870-Ü7
    aus += [(m.group(1), m.group(2)) for m in re.finditer(r"python3 (tools/\S+\.py) (godot/\S+)", z)]
    return aus

def _teile(z, ing):
    """Zeile in Stücke mit Arbeitsordner: [(Text, in godot/)]; „(cd godot && …)“ läuft in godot/ (870-Ü7)."""
    i = z.find("(cd godot")
    if i < 0: return [(z, ing)]
    tiefe, j = 0, len(z)
    for j in range(i, len(z)):
        tiefe += {"(": 1, ")": -1}.get(z[j], 0)
        if tiefe == 0: break
    return [(z[:i], ing), (z[i + 1:j], True)] + _teile(z[j + 1:], ing)

# 870-Ü7: Schreibschritt, den der Wächter nicht einordnen kann (meldet ihn als „unbekannt“, Exit 1, statt ihn zu übergehen)
# (cp, Umleitung und tee liest _ziele; ein Ziel mit unbekannter Variable oder ~ gilt als außerhalb von godot/). Ziel je Befehl:
SCHREIBT = [("mv", r"\bmv\s+[^;|&]*?(\S+)\s*(?=$|[;|&}])"), ("rsync", r"\brsync\s+[^;|&]*?(\S+)\s*(?=$|[;|&}])"),
            ("ln", r"\bln\s+[^;|&]*?(\S+)\s*(?=$|[;|&}])"), ("unzip", r"\bunzip\b[^;|&]*\s-d\s+(\S+)"), ("tar", r"\btar\b[^;|&]*\s-C\s+(\S+)"),
            ("curl", r"\bcurl\b[^;|&]*\s-o\s+(\S+)"), ("wget", r"\bwget\b[^;|&]*\s-O\s+(\S+)"), ("dd", r"\bdd\b[^;|&]*\sof=(\S+)")]

def kopierschritte(root):
    """Schritte nach godot/ in .github/workflows/*.yml: [(Datei:Zeile, Quelle, Ziel, Herkunft, zu lesen)]; zu lesen: Dateien im Repo."""
    aus = []
    for wf in sorted(glob.glob(os.path.join(root, ".github", "workflows", "*.yml"))):
        var, ing = {}, False
        for i, z in enumerate(lesen(wf).splitlines(), 1):
            z = re.sub(r"\s#\s.*$", "", z)
            if z.lstrip().startswith("#"): continue
            if re.match(r"\s*(-\s|run:)", z): ing, var = False, {}            # 870-Ü7: neuer Schritt beginnt im Repo, ohne Variablen
            if re.match(r"\s*cd godot\s*($|&&|;)", z): ing = True              # 870-Ü7: danach relative Pfade unter godot/
            elif re.match(r"\s*cd (\.\.|\$GITHUB_WORKSPACE)\s*$", z): ing = False
            for m in re.finditer(r"\b([A-Za-z])=([^\s;]+)", z):
                var[m.group(1)] = "godot/" + m.group(2) if ing and not m.group(2).startswith(("/", "$", "~", ".", "godot/")) else m.group(2)
            for k, v in var.items():
                if v.startswith("godot/"): z = re.sub(r"\$\{?%s\}?(?=/|\s|\.|$)" % k, v, z)
            schritte = []
            for t, wo_g in _teile(z, ing):
                t = t.replace("$GITHUB_WORKSPACE/", "@/" if wo_g else "")
                schritte += _ziele(t, wo_g)
                ohne = re.sub(r"\$\([^()]*\)", "$(…)", re.sub(r"'[^']*'", "''", t))
                for name, muster in SCHREIBT:   # 870-Ü7: Befehl, dessen Quelle der Wächter nicht einordnet
                    for m in re.finditer(muster, ohne):
                        ziel = m.group(1).strip("\"'")
                        if ziel.startswith("@/"): ziel = ziel[2:] if ziel[2:].startswith("godot/") else ""
                        elif wo_g and ziel and not ziel.startswith(("/", "$", "~", "..", "-", "godot/")): ziel = "godot/" + ziel
                        if ziel.startswith("godot/"): schritte.append(("?" + name, ziel))
            for q, ziel in schritte:
                if "export_templates" in ziel: continue
                if q.startswith("?"):
                    aus.append(("%s:%d" % (os.path.basename(wf), i), q[1:], ziel, "unbekannt (Schreibschritt nicht eingeordnet; Wächter nachbessern)", []))
                    continue
                wo, lies = "%s:%d" % (os.path.basename(wf), i), []
                erz = [e for e in ERZEUGER if re.search(e[0], ziel) or re.search(e[0], q) or q in e[1]]
                if q.startswith("git show "):   # 870-Ü7: Datei aus einem anderen Commit; der Wächter liest dieselbe Datei im Checkout
                    pf = q.split(":", 1)[1]
                    her, lies = "aus Git (%s; Datei im Checkout gelesen)" % q, [pf] if os.path.exists(os.path.join(root, pf)) and pf.endswith(ENDUNGEN) else []
                elif q.startswith("godot/"): her = "lesbar (unter godot/)" if not q.endswith(BINAER) else "binär (unter godot/)"
                elif erz:
                    e = erz[0]
                    her = "erzeugt von %s aus %s" % (", ".join(e[1]), ", ".join(e[2]))
                    for g in e[1] + e[2]: lies += [os.path.relpath(p, root) for p in glob.glob(os.path.join(root, g), recursive=True)]
                elif ziel.endswith("kauf.txt"): her = "erzeugt im Arbeitsablauf (Dateiliste der Kaufmodelle, nur Pfade)"
                elif not q.startswith(("$", "/", "~", "gradle", "echo")) and glob.glob(os.path.join(root, q)):
                    her = "binär" if q.endswith(BINAER) or "*" in q and ".jpg" in q else "lesbar"
                    lies = [os.path.relpath(p, root) for p in glob.glob(os.path.join(root, q)) if p.endswith(ENDUNGEN)]
                elif ziel.endswith(ENDUNGEN) or ziel.endswith("/") and not q.endswith(BINAER):
                    her = "fremd (%s)" % ("core fehlt im Repo" if q.startswith("gradle") else "Kaufrepo oder Bauserver")
                elif q.startswith("gradle"): her = "fremd (core fehlt im Repo)"
                elif ziel.endswith(".log"): her = "Protokoll (kein Spieltext; nicht im Export, include_filter in godot/export_presets.cfg)"
                elif (q + " " + ziel).endswith(BINAER) or re.search(r"\.(glb|bin|png|jpg|bild)\b", q + " " + ziel): her = "binär"
                else: her = "unbekannt (Schreibschritt nicht eingeordnet; Wächter nachbessern)"   # 870-Ü7
                aus.append((wo, q, ziel, her, lies))
    return aus

def kopierquellen(root):
    """Dateien im Repo, die der Bau nach godot/ bringt oder aus denen er Textdateien dort erzeugt (870)."""
    return list(dict.fromkeys(p for s in kopierschritte(root) for p in s[4]))

def srd_namen(root):
    """Alte Namen aus DESIGN-BRS.md Abschnitt 12 („Alt“), ohne Schild/Vorteil/Nachteil und eigene Entwürfe."""
    nw = os.path.join(root, "docs", "DESIGN-BRS.md")
    text = lesen(nw) if os.path.exists(nw) else ""
    abschnitt = text.split("\n## 12. ")[1].split("\n## ")[0] if "\n## 12. " in text else ""
    srd = []
    for z in abschnitt.splitlines():
        s = [x.strip() for x in z.split("|")]
        if len(s) < 4 or s[1] in ("Alt", "---", ""): continue
        if "Entwurf" in s[1]: continue   # 870.13: Umbenennung eigener Entwürfe (Glut), nichts aus dem SRD
        for m in re.finditer(r"Zwischennamen ([^;)]+?) entfallen", s[2]): srd += [n.strip() for n in m.group(1).split(",")]   # 870-Ü3
        for n in re.split(r"[,/]", re.sub(r"\s*\(.*?\)", "", s[1])):
            n = re.sub(r"^Klassen\s+", "", n.strip())
            if n and n not in ("Schild", "Vorteil", "Nachteil"): srd.append(n)
    return srd

def alte_namen(root, srd):
    """Treffer {Name: {Datei}} im Godot-Spiel (ohne tests/) und in den Quellen der Kopien nach godot/ (870)."""
    muster = re.compile(r"(?<!\w)(%s)(?!\w)" % "|".join(map(re.escape, srd)))
    dateien = []
    for d, _, fs in os.walk(os.path.join(root, "godot")):
        if "tests" in os.path.relpath(d, root).split(os.sep): continue
        dateien += [os.path.join(d, f) for f in fs if f.endswith(ENDUNGEN)]
    dateien += [os.path.join(root, q) for q in kopierquellen(root)]
    treffer = {}
    for p in dict.fromkeys(dateien):
        text = lesen(p)
        if p.endswith(".gd"): text = ohne_kommentar_gd(text)   # 870.13: Kommentare sieht kein Spieler (Export als Bytecode ohne sie)
        if p.endswith(".json"): text = ohne_info_json(text)     # 870.13: Felder „_…“ sind Quellenangaben, kein Spieltext
        if p.endswith(".py"): text = ohne_kommentar_py(text)    # 870-Ü3: Erzeuger schreiben nur, was in ihren Zeichenketten steht
        for m in muster.finditer(text): treffer.setdefault(m.group(1), set()).add(os.path.relpath(p, root))
    return treffer

# --namen [ROOT] (870): nur der Namenswächter; listet Kopierschritte und Treffer; Exit 1 bei alten Namen
if "--namen" in sys.argv:
    i = sys.argv.index("--namen")
    wurzel = os.path.abspath(sys.argv[i + 1]) if len(sys.argv) > i + 1 else ROOT
    srd = srd_namen(wurzel)
    if not srd: print("DESIGN-BRS.md: Abschnitt „12. Namen“ ohne Tabelle Alt/Neu"); sys.exit(2)
    ks = kopierschritte(wurzel)
    for wo, q, z, her, _ in ks: print("Schritt %s: %s -> %s [%s]" % (wo, q, z, her))
    print("Schritte nach godot/: %d (lesbar %d, erzeugt %d, aus Git %d, binär %d, Protokoll %d, fremd %d, unbekannt %d); gelesen: %d Dateien unter godot/ und %d Quellen und Erzeuger" % (
        len(ks), *[sum(1 for s in ks if s[3].startswith(h)) for h in ("lesbar", "erzeugt", "aus Git", "binär", "Protokoll", "fremd", "unbekannt")],
        sum(1 for d, _, fs in os.walk(os.path.join(wurzel, "godot")) if "tests" not in os.path.relpath(d, wurzel).split(os.sep) for f in fs if f.endswith(ENDUNGEN)),
        len(kopierquellen(wurzel))))
    tr = alte_namen(wurzel, srd)
    for n, fs in sorted(tr.items()): print("ALT %s: %s" % (n, ", ".join(sorted(fs))))
    unb = [s for s in ks if s[3].startswith("unbekannt")]   # 870-Ü7: nicht eingeordnet heißt nicht geprüft
    print("Namenswächter: %s%s" % ("%d alte Namen" % len(tr) if tr else "keine alten Namen", "; %d Schritte unbekannt" % len(unb) if unb else ""))
    sys.exit(1 if tr or unb else 0)

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
    gross(p, 30000, "Erledigtes streichen")  # 1129 A 7 (Probe bis 20.11.), vorher 15000
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
srd = srd_namen(ROOT)
srd_info = None
if not srd:
    fund.append("DESIGN-BRS.md: Abschnitt „12. Namen“ ohne Tabelle Alt/Neu, Wächter Lizenzhinweis blind (446)")
else:
    treffer = alte_namen(ROOT, srd)
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
