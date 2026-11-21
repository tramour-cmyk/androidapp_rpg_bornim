#!/usr/bin/env python3
"""Tagesbericht (448, Chef 01.11., 11:09 „448 mach es so“): zählt die zehn Zeilen und schreibt sie in docs/ARBEIT-TAGESBERICHT.md
zwischen <!-- zahlen --> und <!-- /zahlen -->; was nicht zu zählen ist (Schätzung, Risiko, Wer hinkt, Prioritäten), schreibt Perikles
von Hand darunter, Zeilen 3, 8, 9 aus dem Abschnitt „Eingaben“. Ersetzt den Stand zum Marktstart (338.1) und das Dashboard (339).
Aufruf: python3 tools/tagesbericht.py [--probe]   (--probe: nur ausgeben, nichts schreiben); danach Text prüfen, pushen,
Telegram mit Ton: python3 tools/tagesbericht.py --telegram gibt die Meldung aus.
Quellen: PROJEKTPLAN.md (Punkte; „· Stand: in Arbeit|gebaut“ am Zeilenende, [x] = abgenommen), LISTE-VORGAENGE.md und -ARCHIV.md
(Git-Stand vor 24 h und 7 Tagen), startbar.py --stand, chefsache/README.md, Zeile „Guthaben:“ in ARBEIT-BETRIEB.md.
1739 (1727 `routine-tagesbericht.md` „Werkzeug“, `werkzeuge.md` A): Eingabe „Wo stehen wir“ neben „Rest geschätzt“ (Vorlage erst mit
tools/1727-SCHARF), Zeile „Fristen“ (Testbitten über 5 Tage, Fragen an den Chef mit Alter, Vorgänge ohne Auftrag über 1 Tag, Einträge
unter „Unveröffentlicht“, Alter des letzten Release); Halt der Vorratsprüfung (1425) fällt mit tools/1727-SCHARF."""
import collections, datetime, json, os, re, subprocess, sys, zoneinfo

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOCS = os.path.join(ROOT, "docs")
ZIEL = os.path.join(DOCS, "ARBEIT-TAGESBERICHT.md")
JETZT = datetime.datetime.now(zoneinfo.ZoneInfo("Europe/Berlin"))
GH = "https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/"
# Stufen nach 447 (Chef 01.11., „447 ja, mit K2b … neu und vernünftig durch“): Punkt „N.M“ gehört zu Stufe N
STUFEN = {1: "Stufe 1 Kern spielbar", 2: "Stufe 2 Kapitel 1 durchspielbar", 3: "Stufe 3 Alle Systeme angelegt",
          4: "Stufe 4 Kapitel 1 fertig", 5: "Stufe 5 marktreif", 6: "Stufe 6 SRD im Code abgelöst"}
SCHARF = os.path.join(ROOT, "tools", "1727-SCHARF")  # 1739: legt der Umschalt-Commit an; bis dahin alles wie bisher
SPIEL = "EGCD"  # Bereiche des Spiels (124: E Entwicklung, G Gestaltung; C Texte, D Design); Rest Betrieb, Prüfung, Markt

def git(*a):
    return subprocess.run(["git", "-C", ROOT] + list(a), capture_output=True, text=True).stdout

def lesen(p):
    try: return open(os.path.join(DOCS, p), encoding="utf-8").read()
    except OSError: return ""

def punkte(text):
    """Punkt „N.M“ → Stand (offen, in Arbeit, gebaut, abgenommen) aus der Abnahmeliste (447: Stufe.Punkt)."""
    p = {}
    teil = re.split(r"(?m)^## ", text.split("## Abnahmeliste", 1)[-1])[0] if "## Abnahmeliste" in text else ""
    for z in teil.splitlines():
        m = re.match(r"- \[( |x)\] \*\*(\d+\.\d+)\*\*", z)
        if m:
            s = re.search(r"· Stand: (in Arbeit|gebaut)\s*$", z)
            p[m.group(2)] = "abgenommen" if m.group(1) == "x" else (s.group(1) if s else "offen")
    return p

def rev_vor(spec):
    # flache Kopie (frische Sitzung, 02.11.: nur 76 Commits, Zeile 2 zählte 0 / 0): Verlauf von 9 Tagen nachholen
    if git("rev-parse", "--is-shallow-repository").strip() == "true":
        subprocess.run(["git", "-C", ROOT, "fetch", "-q", "--shallow-since=9 days ago", "origin", "main"],
                       capture_output=True, timeout=120)
    return git("rev-list", "-1", "--before=" + spec, "HEAD").strip()

def tafel(rev):
    d = {}
    sys.path.insert(0, os.path.join(ROOT, "tools")); import startbar  # 275.2: Spalten über den Kopf, altes und neues Format
    for f in ("docs/LISTE-VORGAENGE.md", "docs/LISTE-VORGAENGE-ARCHIV.md"):
        for t in startbar.tafel_zeilen(git("show", "%s:%s" % (rev, f))):
            if not t.get("nr") or t["nr"] in startbar.SONDER: continue
            k = sum(float(x.replace(".", "").replace(",", ".")) for x in re.findall(r"(\d[\d.]*,\d\d) ?\$", t.get("kosten", "")))
            d.setdefault(t["nr"], dict(titel=t.get("titel", ""), bereich=t.get("bereich", "")[:1], vorrat=t.get("besitzer", ""), stand=t.get("stand", ""), kosten=k))
    return d

def fertig(s): return re.match(r"(erledigt|abgenommen|verworfen)\b", s.strip(), re.I) is not None

def chefsache():
    t = lesen("chefsache/README.md"); teile = re.split(r"(?m)^## ", t); n, alt = {}, {}
    for tl in teile:
        kopf = tl.split("\n")[0].strip()
        art = {"Zu entscheiden": "entscheiden", "Anzusehen": "ansehen", "Zu tun": "tun", "Zu billigen": "billigen"}.get(kopf)
        if not art: continue
        for z in tl.splitlines():
            if not re.match(r"\| (\d+ \| )?\[", z): continue  # D55.1: Build-Zeilen beginnen mit der Folge „| 1 | [0.348.146]“
            build = "/actions/" in z
            a = "Build" if build else art; n[a] = n.get(a, 0) + 1
            for d in re.findall(r"(\d\d)\.(\d\d)\.(?:, (\d\d:\d\d))?", z)[-1:]:
                w = (d[1], d[0], d[2] or "00:00")
                if a not in alt or w < alt[a][0]: alt[a] = (w, re.sub(r"^\| (\d+ \| )?\[", "", z).split("](")[0])
    return n, alt

def stand_rollen():
    aus = subprocess.run([sys.executable, os.path.join(ROOT, "tools", "startbar.py"), "--stand"], capture_output=True, text=True, cwd=ROOT).stdout
    r, wer = {}, None
    for z in aus.splitlines():
        m = re.match(r"  (\w+): ", z)
        if m: wer = m.group(1); continue
        m = re.match(r"\s+offen (\d+), Muss (\d+), startbar (\d+)", z)
        if m and wer: r[wer] = tuple(int(x) for x in m.groups())
    test = re.search(r"Gemeinsamer Build: Tom (\d+), Jerry (\d+)", aus)
    return r, (int(test.group(1)), int(test.group(2))) if test else (0, 0)

def eingaben():
    t = lesen("ARBEIT-TAGESBERICHT.md"); e = {}
    for z in t.split("## Eingaben", 1)[-1].splitlines() if "## Eingaben" in t else []:
        m = re.match(r"- (Wo stehen wir|Rest geschätzt|Von dir zuerst gefunden|Größtes Risiko): (.*)", z)
        if m: e[m.group(1)] = m.group(2).strip()
    return e

def rechnen():
    jetzt, gestern, woche = tafel("HEAD"), tafel(rev_vor("24 hours ago")), tafel(rev_vor("7 days ago"))
    def erl(alt): return [n for n, v in jetzt.items() if fertig(v["stand"]) and (n not in alt or not fertig(alt[n]["stand"]))]
    e1, e7 = erl(gestern), erl(woche)
    spiel = lambda ns: sum(1 for n in ns if jetzt[n]["bereich"] in SPIEL)
    neu1, neu7 = len([n for n in jetzt if n not in gestern]), len([n for n in jetzt if n not in woche])
    kost = collections.Counter()
    for n, v in jetzt.items():
        d = v["kosten"] - gestern.get(n, {"kosten": 0})["kosten"]
        if d > 0.01: kost["Spiel" if v["bereich"] in SPIEL else "Betrieb"] += d
    p_heute = punkte(lesen("PROJEKTPLAN.md")); p_gestern = punkte(git("show", rev_vor("24 hours ago") + ":docs/PROJEKTPLAN.md"))
    seit = collections.Counter()
    for k, s in p_heute.items():
        a = p_gestern.get(k, "offen")
        if s != a:
            if s in ("abgenommen", "gebaut"): seit[s] += 1
            elif a in ("abgenommen", "gebaut"): seit["zurück"] += 1
    rollen, test = stand_rollen()
    erl_rolle = lambda ns, r: sum(1 for n in ns if r in jetzt[n]["vorrat"])
    return dict(jetzt=jetzt, e1=e1, e7=e7, s1=spiel(e1), s7=spiel(e7), neu1=neu1, neu7=neu7, kost=kost, punkte=p_heute, seit=seit,
                rollen=rollen, test=test, erl_rolle=erl_rolle, chef=chefsache(), ein=eingaben(), rot=rote_laeufe(), lz=laufzeiten_kurz(),
                frist=fristen(jetzt, gestern))

def alter_tage(pfad):
    """Tage seit dem ersten Commit der Datei (Git, Berliner Zeit); unbekannt: None."""
    t = git("log", "--diff-filter=A", "--format=%ct", "--", pfad).split()
    if not t: return None
    return (JETZT - datetime.datetime.fromtimestamp(int(t[-1]), JETZT.tzinfo)).days

def fristen(jetzt, gestern):
    """1739 (1727 `routine-tagesbericht.md` „Werkzeug“; `ablauf.md` A3, A13; `ein-ausgang.md` L-O16): was über seiner Frist liegt.
    Testbitten (Build-Zeilen der Chefsache und `chefsache/ansehen/t<n>.md`) über 5 Tage, Fragen an den Chef (`chefsache/entscheiden/`)
    mit Alter, offene Vorgänge ohne „## Auftrag“ in `docs/vorgang/NR.md`, die es schon vor 24 h gab (A3: 1 Tag; nur mit
    tools/1727-SCHARF, vorher hat kein Vorgang einen Auftrag), Einträge unter „## Unveröffentlicht“ in CHANGELOG.md (Spielcode dort ist
    getestet, `main` erst nach Test; Werkzeuge zählen mit, sie sind nicht zu trennen) und Tage seit dem letzten Release (erste Überschrift „## v…“)."""
    f = {}
    test = []
    for z in lesen("chefsache/README.md").splitlines():
        if "/actions/" not in z or not re.match(r"\| (\d+ \| )?\[", z): continue
        for d in re.findall(r"(\d\d)\.(\d\d)\.", z)[:1]:
            try:
                a = (JETZT.date() - datetime.date(JETZT.year, int(d[1]), int(d[0]))).days
                test.append((a + 365 if a < 0 else a, re.sub(r"^\| (\d+ \| )?\[", "", z).split("](")[0]))
            except ValueError: pass
    for art in ("ansehen", "entscheiden"):
        ordner = os.path.join(DOCS, "chefsache", art)
        for n in sorted(os.listdir(ordner)) if os.path.isdir(ordner) else []:
            if not n.endswith(".md") or n in ("README.md", "MUSTER.md"): continue
            a = alter_tage(os.path.join("docs", "chefsache", art, n))
            if a is None: continue
            if art == "ansehen" and re.match(r"t\d+", n): test.append((a, n[:-3]))
            elif art == "entscheiden": f.setdefault("fragen", []).append((a, n[:-3]))
    f["test"] = sorted(x for x in test if x[0] > 5)
    f["fragen"] = sorted(f.get("fragen", []), reverse=True)
    if os.path.exists(SCHARF):
        ohne = []
        for n, v in jetzt.items():
            if not re.search(r"\d", n) or fertig(v["stand"]) or n not in gestern or v["stand"].split(" ")[0] in ("ruht", "Idee"): continue
            if "## Auftrag" not in lesen(os.path.join("vorgang", n + ".md")): ohne.append(n)
        f["ohne_auftrag"] = sorted(ohne, key=lambda x: [int(t) if t.isdigit() else 0 for t in re.findall(r"\d+", x)])
    log = lesen("../CHANGELOG.md")
    teil = log.split("## Unveröffentlicht", 1)[1] if "## Unveröffentlicht" in log else ""
    f["unveroeff"] = sum(1 for z in re.split(r"(?m)^## ", teil)[0].splitlines() if z.startswith("- "))
    m = re.search(r"(?m)^## (v[\d.]+) – (\d\d)\.(\d\d)\.(\d{4})", log)
    f["release"] = (m.group(1), (JETZT.date() - datetime.date(int(m.group(4)), int(m.group(3)), int(m.group(2)))).days) if m else None
    return f

def fristen_text(f):
    """Eine Zeile „Fristen“; Zahlen fett, je Teil die älteste Fundstelle."""
    if not f: return "unbekannt"
    t = ["Testbitten über 5 Tage **%d**%s" % (len(f["test"]), " (älteste %s, %d Tage)" % (f["test"][-1][1], f["test"][-1][0]) if f["test"] else "")]
    q = f["fragen"]
    t.append("Fragen an dich ohne Antwort **%d**%s" % (len(q), " (älteste %s, %d Tage)" % (q[0][1], q[0][0]) if q else ""))
    if "ohne_auftrag" in f:
        o = f["ohne_auftrag"]
        t.append("Vorgänge ohne Auftrag über 1 Tag **%d**%s" % (len(o), " (%s%s)" % (", ".join(o[:5]), " …" if len(o) > 5 else "") if o else ""))
    r = f["release"]
    t.append("unter „Unveröffentlicht“ **%d** Einträge; letztes Release %s" % (f["unveroeff"], "%s vor **%d Tagen**" % r if r else "unbekannt"))
    return "; ".join(t)

NICHT_BAU = {"zug-index", "release-notes", "webseite", "vorschau"}  # Abläufe ohne Bau (Notizen, Seiten)

def rote_laeufe():
    """749 (D95.2, zu 464): abgeschlossene CI-Läufe der letzten 24 h und 7 Tage (ohne abgebrochene), rot je Team aus dem
    Zweignamen; öffentliche API ohne Anmeldung. Netz weg: None."""
    import urllib.request
    jetzt = datetime.datetime.now(datetime.timezone.utc)
    seit = (jetzt - datetime.timedelta(days=7)).strftime("%Y-%m-%dT%H:%M:%SZ")
    laeufe = []
    basis = "https://api.github.com/repos/tramour-cmyk/androidapp_rpg_bornim/actions/"
    holen = lambda u: json.load(urllib.request.urlopen(urllib.request.Request(basis + u, headers={"Accept": "application/vnd.github+json"}), timeout=10))
    try:
        ablaeufe = [w["path"].rsplit("/", 1)[-1] for w in holen("workflows?per_page=100").get("workflows", [])]
        for datei in ablaeufe:
            if datei.split(".")[0] in NICHT_BAU: continue
            for seite in range(1, 11):
                teil = holen("workflows/%s/runs?status=completed&per_page=100&page=%d&created=%%3E%%3D%s" % (datei, seite, seit)).get("workflow_runs") or []
                laeufe += teil
                if len(teil) < 100: break
    except Exception:
        return None
    grenze = (jetzt - datetime.timedelta(hours=24)).strftime("%Y-%m-%dT%H:%M:%SZ")
    erg = {}
    for name, ls in (("24h", [l for l in laeufe if l.get("created_at", "") >= grenze]), ("7d", laeufe)):
        gezaehlt = [l for l in ls if l.get("conclusion") in ("success", "failure")]
        rot = [l for l in gezaehlt if l["conclusion"] == "failure"]
        dauer = lambda xs: sum(lauf_min(l) for l in xs)  # 1659: Minuten in roten Läufen gegen alle
        team = collections.Counter(next((t for v, t in (("tom", "tom"), ("spike", "spike"), ("jerry", "jerry"), ("tuffy", "jerry"), ("build", "build"))
                                         if (l.get("head_branch") or "").startswith("claude/" + v)), "sonst") for l in rot)  # 777: tuffy → Jerry; 1328: spike eigene Rolle
        erg[name] = (len(rot), len(gezaehlt), team, dauer(rot), dauer(gezaehlt))
    erg["bau"] = bau_zahl([l for l in laeufe if l.get("created_at", "") >= grenze])
    return erg

def bau_zahl(ls):
    """1715 (Chef 18.11., 22:21): Läufe der Buildzweige claude/build-<n> in 24 h: grün, rot, abgebrochen und deren Minuten (verlorene Bauzeit)."""
    b = [l for l in ls if (l.get("head_branch") or "").startswith("claude/build-")]
    k = lambda c: [l for l in b if l.get("conclusion") == c]
    return (len(k("success")), len(k("failure")), len(k("cancelled")), sum(lauf_min(l) for l in k("cancelled")))

def bau_text(z):
    """1715: eine Teilzeile; rot über grün → Systemfrage an Spike (Vorgang anlegen)."""
    if not z or not sum(z[:3]): return "; Buildzweige 24 h: keine Läufe"
    g, r, a, m = z
    return "; Buildzweige 24 h: **%d grün, %d rot, %d abgebrochen** (%d min Bauzeit verloren)%s" % (
        g, r, a, round(m), " → **Systemfrage an Spike** (rot über grün, Vorgang anlegen)" if r > g else "")

def lauf_min(l):
    try:
        z = lambda t: datetime.datetime.fromisoformat(t.replace("Z", "+00:00"))
        return max(0.0, (z(l["updated_at"]) - z(l.get("run_started_at") or l["created_at"])).total_seconds() / 60)
    except Exception:
        return 0.0

def je_vorgang(laeufe, ns, jetzt):
    """1659: Läufe je erledigtem oder abgenommenem Vorgang des Spiels (nur dort baut ein Lauf; verworfene zählen nicht); keiner: „–“."""
    k = sum(1 for n in ns if jetzt[n]["bereich"] in SPIEL and not jetzt[n]["stand"].strip().lower().startswith("verworfen"))
    return ("%.1f" % (laeufe / k)).replace(".", ",") if k else "–"

def wirkung_text(d):
    """1659 (Chef 18.11., 12:10: „wie effektiv ist denn jetzt das mit unseren Runs?“): grüne Läufe in Prozent, Minuten in roten
    Läufen, Läufe je erledigtem Vorgang, je 24 h und 7 Tage; dahinter rot je Team, rote Tests und die APK-Laufzeiten (1548)."""
    r = d.get("rot")
    if not r: return "Läufe unbekannt (Netz)" + ("; " + d["lz"] if d.get("lz") else "")
    def teil(name, ns, fett):
        n, g, _, mr, mg = r[name]
        f = (lambda t: "**%s**" % t) if fett else (lambda t: t)
        return "%s %s (%d von %d), %s (%d %% der Laufzeit), %s" % (
            "24 h" if name == "24h" else "7 Tage", f("%d %% grün" % round(100 * (g - n) / g) if g else "keine Läufe"), g - n, g,
            f("%d min in roten Läufen" % round(mr)), round(100 * mr / mg) if mg else 0, f("%s Läufe je erledigtem Spielvorgang" % je_vorgang(g, ns, d["jetzt"])))
    _, _, t, _, _ = r["24h"]
    name = {"build": "beim Bau eines Test-Builds", "sonst": "sonstige"}
    teams = ", ".join("%s %d" % (name.get(k, k.capitalize()), t[k]) for k in ("tom", "jerry", "spike", "build", "sonst") if t[k])
    return "%s; %s%s%s%s%s" % (teil("24h", d["e1"], True), teil("7d", d["e7"], False), "; rot 24 h nach Team: " + teams if teams else "",
                               bau_text(r.get("bau")), rotbuch_kurz(), "; " + d["lz"] if d.get("lz") else "")

def laufzeiten_kurz():
    """1548 (Chef 17.11., 11:15): Läufe 24 h, Ø, min, max, und ob die vorgerenderten Kaufmodelle griffen (tools/laufzeiten.py)."""
    try:
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import laufzeiten
        return laufzeiten.kurz(24)
    except Exception:
        return "Laufzeiten unbekannt"

def rotbuch_kurz():
    """1334: Zahl je roten Test der letzten 48 h (tools/rotbuch.py --kurz)."""
    try:
        r = subprocess.run([sys.executable, os.path.join(os.path.dirname(os.path.abspath(__file__)), "rotbuch.py"), "--kurz"], capture_output=True, text=True, timeout=120)
        return "; " + r.stdout.strip() if r.stdout.startswith("rote Tests") else ""
    except Exception:
        return ""

def zeile3(ein):
    """1739: „Wo stehen wir“ (Routine Tagesbericht) ersetzt „Rest geschätzt“; steht der neue Satz da oder ist umgeschaltet, gilt er."""
    if ein.get("Wo stehen wir") or (os.path.exists(SCHARF) and not ein.get("Rest geschätzt")):
        return ("Wo stehen wir", ein.get("Wo stehen wir", "–"), "Themenblock oben, seit gestern abgenommen, als Nächstes (Routine Tagesbericht)")
    return ("Rest geschätzt", ein.get("Rest geschätzt", "noch keine Schätzung"), "Sitzungen bis zur nächsten Stufe, Tom und Jerry, montags neu")

def zeilen(d):
    p = d["punkte"]; z = collections.Counter(p.values())
    stufe = ""
    for nr, name in STUFEN.items():
        ks = [k for k in p if k.split(".")[0] == str(nr)]; c = collections.Counter(p[k] for k in ks)
        if ks and c["abgenommen"] < len(ks):
            stufe = "**%s**: %d von %d abgenommen, %d gebaut, %d in Arbeit" % (name, c["abgenommen"], len(ks), c["gebaut"], c["in Arbeit"]); break
    n, alt = d["chef"]
    # 1390: ausgeschrieben statt „2 Build, 1 tun“
    wort = {"entscheiden": "zu entscheiden", "ansehen": "anzusehen", "billigen": "zu billigen", "Build": "%s zum Testen", "tun": "zu tun"}
    warte = ", ".join("**%d %s**" % (n[a], wort[a] % ("Build" if n[a] == 1 else "Builds") if "%" in wort[a] else wort[a])
                      for a in ("entscheiden", "ansehen", "billigen", "Build", "tun") if n.get(a))
    aeltest = min(alt.values())[1] if alt else "–"
    if alt: w = min(alt.values())[0]; aeltest = "%s seit %s.%s., %s" % (min(alt.values())[1], w[1], w[0], w[2])
    gut = re.search(r"\*\*Bild Chef (\d\d\.\d\d\.), (\d\d:\d\d)[^*]*\*\*:? Woche (\d+) %", lesen("ARBEIT-BETRIEB.md"))
    k = d["kost"]; ks = sum(k.values())
    t1, t2 = d["test"]
    ein = d["ein"]
    return [
        ("Stufe", stufe, "%d Punkte in 6 Stufen: %d abgenommen, %d gebaut, %d in Arbeit, %d offen" % (len(p), z["abgenommen"], z["gebaut"], z["in Arbeit"], z["offen"])),
        ("Seit gestern", "abgenommen **%d**, gebaut **%d**, von dir zurück **%d**" % (d["seit"]["abgenommen"], d["seit"]["gebaut"], d["seit"]["zurück"]),
         "Vorgänge erledigt 24 h / 7 Tage: %d / %d, davon Spiel (Entwicklung, Gestaltung, Texte, Design) %d / %d; neu %d / %d" % (len(d["e1"]), len(d["e7"]), d["s1"], d["s7"], d["neu1"], d["neu7"])),
        zeile3(ein),
        ("Wartet auf dich", warte or "nichts", "ältestes: %s; [Chefsache](chefsache/README.md)" % aeltest),
        ("Builds", "Änderungen warten auf deinen Test: **%d** (Tom %d, Jerry %d); wie wirksam die Läufe sind: Zeile 10" % (t1 + t2, t1, t2),
         "bei dir zum Testen: %s; ein Build nimmt alle fertigen Zweige (317)" % (", ".join(re.findall(r"\[(Build \d+)\]", lesen("chefsache/README.md"))) or "kein Build")),
        ("Fehler", fehler(d["jetzt"]), "offene Vorgänge des Spiels mit Fehler oder Befund im Titel, dazu jeder mit Build-Nummer (D55.3)"),
        ("Geld", ("Woche **%s %%** (dein Bild %s, %s)" % (gut.group(3), gut.group(1), gut.group(2)) if gut else "Woche unbekannt") +
         "; gestern %d $ Rechenwert, Spiel %d %%" % (ks, 100 * k["Spiel"] / ks if ks else 0) +
         ("" if gut and gut.group(1) == JETZT.strftime("%d.%m.") else "; **Bitte Bild der Nutzung** (Anteil der Woche in Prozent; solange die Niederlassung ruht, nur vom Account Max)"), "Rechenwert = Listenpreis der Sitzungen, kein echtes Geld (Abo pauschal)"),
        ("Von dir zuerst gefunden", ein.get("Von dir zuerst gefunden", "–"), "Woche, zählt Diogenes montags"),
        ("Größtes Risiko", ein.get("Größtes Risiko", "–"), ""),
        ("Läufe", wirkung_text(d), "alle Bau- und Testläufe ohne abgebrochene; je Spielvorgang = Läufe geteilt durch erledigte oder abgenommene Vorgänge des Spiels, ohne verworfene (1659)"),
        ("Fristen", fristen_text(d.get("frist")), "Testbitte 5 Tage (A13), Vorgang ohne Auftrag 1 Tag (A3, erst nach der Umstellung), Frage an dich ohne Frist (L-O16); Release nur auf dein Wort"),
        ("Ausführlich", "[Abnahmeliste und Stand](PROJEKTPLAN.md)", ""),
    ]

def zahlen_md(d):
    zeilen_ = zeilen(d)
    md = ["**Stand %s, %s** (Werkzeug `tools/tagesbericht.py`)" % (JETZT.strftime("%d.%m."), JETZT.strftime("%H:%M")), "",
          "| # | Kennzahl | heute | Bemerkung |", "|---|---|---|---|"]
    unten = []
    def kurz(i, a, b, c):
        """Pflege 169 (08.11.): Tabellenzeile höchstens 400 Zeichen; lange Eingaben (Zeilen 3, 8, 9) nur mit dem ersten Satz, ganz unter „Eingaben“ und im Telegram.
        1647: andere Zeilen (etwa 5, rote Tests und APK-Läufe) bis zum letzten „; “, das passt, der Rest unter die Tabelle."""
        z = "| %d | %s | %s | %s |" % (i + 1, a, b, c)
        if len(z) <= 400: return z
        if i in (2, 7, 8):
            hinweis = " (ganz unter „Eingaben“)"
            satz = re.split(r"(?<=[a-zäöüß)]\.)\s(?=[A-ZÄÖÜ])", b, maxsplit=1)[0]  # Satzende, nicht „08.11.“
        else:
            hinweis = " (weiter unter der Tabelle)"
            satz, rest_ = b, ""
        platz = 400 - len("| %d | %s |  | %s |" % (i + 1, a, c)) - len(hinweis)
        if i not in (2, 7, 8):
            teile = b.split("; ")
            satz = teile[0]
            for k in range(1, len(teile)):
                if len("; ".join(teile[:k + 1])) > platz: break
                satz = "; ".join(teile[:k + 1])
            unten.append("- Zeile %d (%s), weiter: %s" % (i + 1, a, b[len(satz):].lstrip("; ")))
        if len(satz) > platz: satz = satz[:platz - 2].rsplit(" ", 1)[0] + " …"
        return "| %d | %s | %s%s | %s |" % (i + 1, a, satz, hinweis, c)
    md += [kurz(i, a, b, c) for i, (a, b, c) in enumerate(zeilen_)]
    if unten: md += [""] + unten
    md += ["", "| Rolle | offen | davon Muss | startbar | erledigt 24 h | erledigt 7 Tage |", "|---|---|---|---|---|---|"]
    for r in ("Tom", "Jerry", "Homer", "Sokrates", "Perikles", "Diogenes"):
        o = d["rollen"].get(r, (0, 0, 0))
        md.append("| %s | %d | %d | %d | %d | %d |" % (r, o[0], o[1], o[2], d["erl_rolle"](d["e1"], r), d["erl_rolle"](d["e7"], r)))
    return "\n".join(md)

def fehler(jetzt):
    offen = [(n, v) for n, v in jetzt.items() if (v["bereich"] in SPIEL or re.search(r"Build \d+", v["titel"])) and not fertig(v["stand"]) and v["stand"].split(" ")[0] not in ("ruht", "Idee")
             and re.search(r"Fehler|Befund|Build \d+", v["titel"])]
    alt = 0
    for n, v in offen:
        m = re.search(r"(\d\d)\.(\d\d)\.", v["titel"])
        if m:
            try:
                if (JETZT.date() - datetime.date(JETZT.year, int(m.group(2)), int(m.group(1)))).days > 3: alt += 1
            except ValueError: pass
    return "**%d** offen, davon %d älter als drei Tage" % (len(offen), alt)

def telegram(d):
    """D55.2 (Chef 01.11., 11:09 zu 448: „zehn Zeilen per Telegram, jede mit einer Zahl“): dieselben zehn Zeilen wie der Bericht, ohne Bemerkung."""
    zs = zeilen(d)
    roh = lambda t: re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", t).replace("**", "")
    # 1659: Zeile 10 = Läufe, 11 = Vorrat auf links (wie der Chef sie zählt); Abnahmeliste als Link im Kopf
    return "448: Tagesbericht %s (%sARBEIT-TAGESBERICHT.md, Abnahmeliste %sPROJEKTPLAN.md)\n" % (JETZT.strftime("%d.%m."), GH, GH) + "\n".join(
        "%d. %s: %s" % (i + 1, a, roh(b)) for i, (a, b, c) in enumerate(zs[:10])) + (
        "\n11. Fristen: " + roh(zs[10][1]) if os.path.exists(SCHARF) else vorrat_zeile())  # 1739: Vorratsprüfung fällt mit den Vorräten

def vorrat_satz(erg, f):
    """1660 (Chef 18.11., 12:17: „Punkt 11 … auf links eine Aussage im Bericht“): Klartext statt Kürzel: was der heutige Lauf
    behoben hat, wie viele Funde offen sind (nach Art, ausgeschrieben, und nach Besitzer), was davon den Chef angeht.
    Den Chef geht an: I (Datei in seiner Chefsache ohne offenen Vorgang; er sähe eine Frage, die keiner mehr stellt)."""
    import collections, vorratspruefung as V
    s = "11. Vorrat auf links (1425): "
    s += ("heute geprüft und behoben: " + "; ".join(erg)) if erg else "heute noch nicht geprüft"
    if not f: return s + ". Offen: nichts. Für dich: nichts."
    art = collections.Counter(x[0] for x in f)
    wer = collections.Counter(b.strip() for x in f for b in (x[2] if x[2] not in ("?", "–") else "ohne Besitzer").split(","))
    s += ". Offen: %d %s (%s), bei %s." % (len(f), "Fund" if len(f) == 1 else "Funde",
                                         ", ".join("%d %s" % (n, V.ARTEN.get(a, a)) for a, n in sorted(art.items(), key=lambda x: -x[1])),
                                         ", ".join("%s %d" % (b, n) for b, n in wer.most_common()))
    chef = [x[1] for x in f if x[0] == "I"]
    return s + (" Für dich: %d Datei%s in der Chefsache ohne offenen Vorgang (%s), räumen wir weg; sonst nichts." % (
        len(chef), "" if len(chef) == 1 else "en", ", ".join(chef)) if chef else " Für dich: nichts, alles liegt bei uns.")

def vorrat_zeile():
    """1425 (Chef 17.11., 10:14: „Ergebnis der heutigen Leichenprüfung … keine Telegram-Nachricht“): Ergebnis der Vorratsprüfung des
    Tages aus dem Commit „Vorratsprüfung TT.MM.: …“ und die jetzt noch offenen Funde (ohne J), als Satz (1660)."""
    import subprocess
    try:
        r = subprocess.run(["git", "-C", os.path.dirname(os.path.abspath(__file__)), "log", "--since=%s 00:00" % JETZT.strftime("%Y-%m-%d"),
                            "--format=%s", "--grep=Vorratsprüfung " + JETZT.strftime("%d.%m.")], capture_output=True, text=True, timeout=30)
        erg = [re.sub(r"^.*?Vorratsprüfung \d\d\.\d\d\.:?\s*", "", z) for z in r.stdout.splitlines() if z.strip()]
        import vorratspruefung
        return "\n" + vorrat_satz(erg, [x for x in vorratspruefung.funde() if x[0] != "J"])
    except Exception as e:
        return "\n11. Vorrat auf links (1425): nicht lesbar (%s)" % e

def main():
    if "--telegram" not in sys.argv and "--probe" not in sys.argv and not os.path.exists(SCHARF):  # 1739: Halt fällt mit den Vorräten
        # 1425 (Chef 16.11., 13:44/13:47): vor jedem Tagesbericht den ganzen Vorrat auf Fehler prüfen und sie ausmerzen
        try:
            sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
            import vorratspruefung
            f = [x for x in vorratspruefung.funde() if x[0] != "J"]
            if f and os.environ.get("BORNIM_VORRAT_GEPRUEFT") != "1":
                print("tagesbericht HÄLT AN: Vorratsprüfung (1425) hat %d Funde; erst beheben oder dem Besitzer in den Vorrat, "
                      "`python3 tools/vorratspruefung.py`; danach mit BORNIM_VORRAT_GEPRUEFT=1" % len(f), file=sys.stderr)
                return 1
        except Exception as e:
            print("tagesbericht: Vorratsprüfung übersprungen (%s)" % e, file=sys.stderr)
    d = rechnen()
    if "--telegram" in sys.argv: print(telegram(d)); return 0
    md = zahlen_md(d)
    if "--probe" in sys.argv: print(md); return 0
    alt = lesen("ARBEIT-TAGESBERICHT.md")
    if "<!-- zahlen -->" in alt and "<!-- /zahlen -->" in alt:
        neu = re.sub(r"<!-- zahlen -->.*?<!-- /zahlen -->", lambda m: "<!-- zahlen -->\n" + md + "\n<!-- /zahlen -->", alt, flags=re.S)
    else:
        neu = "# Tagesbericht\n\n<!-- zahlen -->\n" + md + "\n<!-- /zahlen -->\n\n## Eingaben\n\n- %s: \n- Von dir zuerst gefunden: \n- Größtes Risiko: \n" % ("Wo stehen wir" if os.path.exists(SCHARF) else "Rest geschätzt")
    open(ZIEL, "w", encoding="utf-8").write(neu)
    print("tagesbericht: %s geschrieben; Eingaben, Wer hinkt, Prioritäten von Hand prüfen" % os.path.relpath(ZIEL, ROOT))

if __name__ == "__main__":
    sys.exit(main())
