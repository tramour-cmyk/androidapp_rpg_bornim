#!/usr/bin/env python3
"""Tagesbericht (448, Chef 01.11., 11:09 „448 mach es so“): zählt die zehn Zeilen und schreibt sie in docs/ARBEIT-TAGESBERICHT.md
zwischen <!-- zahlen --> und <!-- /zahlen -->; was nicht zu zählen ist (Schätzung, Risiko, Wer hinkt, Prioritäten), schreibt Perikles
von Hand darunter, Zeilen 3, 8, 9 aus dem Abschnitt „Eingaben“. Ersetzt den Stand zum Marktstart (338.1) und das Dashboard (339).
Aufruf: python3 tools/tagesbericht.py [--probe]   (--probe: nur ausgeben, nichts schreiben); danach Text prüfen, pushen,
Telegram mit Ton: python3 tools/tagesbericht.py --telegram gibt die Meldung aus.
Quellen: PROJEKTPLAN.md (Punkte; „· Stand: in Arbeit|gebaut“ am Zeilenende, [x] = abgenommen), LISTE-VORGAENGE.md und -ARCHIV.md
(Git-Stand vor 24 h und 7 Tagen), startbar.py --stand, chefsache/README.md, Zeile „Guthaben:“ in ARBEIT-BETRIEB.md."""
import collections, datetime, json, os, re, subprocess, sys, zoneinfo

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOCS = os.path.join(ROOT, "docs")
ZIEL = os.path.join(DOCS, "ARBEIT-TAGESBERICHT.md")
JETZT = datetime.datetime.now(zoneinfo.ZoneInfo("Europe/Berlin"))
GH = "https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/"
# Stufen nach 447 (Chef 01.11., „447 ja, mit K2b … neu und vernünftig durch“): Punkt „N.M“ gehört zu Stufe N
STUFEN = {1: "Stufe 1 Kern spielbar", 2: "Stufe 2 Kapitel 1 durchspielbar", 3: "Stufe 3 Alle Systeme angelegt",
          4: "Stufe 4 Kapitel 1 fertig", 5: "Stufe 5 marktreif", 6: "Stufe 6 SRD im Code abgelöst"}
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
        m = re.match(r"- (Rest geschätzt|Von dir zuerst gefunden|Größtes Risiko): (.*)", z)
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
                rollen=rollen, test=test, erl_rolle=erl_rolle, chef=chefsache(), ein=eingaben(), rot=rote_laeufe())

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
        team = collections.Counter(next((t for v, t in (("tom", "tom"), ("spike", "tom"), ("jerry", "jerry"), ("tuffy", "jerry"), ("build", "build"))
                                         if (l.get("head_branch") or "").startswith("claude/" + v)), "sonst") for l in rot)  # 777: spike → Tom, tuffy → Jerry
        erg[name] = (len(rot), len(gezaehlt), team)
    return erg

def rot_text(r):
    if not r: return "rote Läufe unbekannt (Netz)"
    n, g, t = r["24h"]; n7, g7, _ = r["7d"]
    teams = ", ".join("%s %d" % (k.capitalize(), t[k]) for k in ("tom", "jerry", "build", "sonst") if t[k])
    return "rote Läufe 24 h **%d von %d**%s, 7 Tage %d von %d" % (n, g, " (%s)" % teams if teams else "", n7, g7)

def zeilen(d):
    p = d["punkte"]; z = collections.Counter(p.values())
    stufe = ""
    for nr, name in STUFEN.items():
        ks = [k for k in p if k.split(".")[0] == str(nr)]; c = collections.Counter(p[k] for k in ks)
        if ks and c["abgenommen"] < len(ks):
            stufe = "**%s**: %d von %d abgenommen, %d gebaut, %d in Arbeit" % (name, c["abgenommen"], len(ks), c["gebaut"], c["in Arbeit"]); break
    n, alt = d["chef"]
    warte = ", ".join("**%d %s**" % (n[a], a) for a in ("entscheiden", "ansehen", "billigen", "Build", "tun") if n.get(a))
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
        ("Rest geschätzt", ein.get("Rest geschätzt", "noch keine Schätzung"), "Sitzungen bis zur nächsten Stufe, Tom und Jerry, montags neu"),
        ("Wartet auf dich", warte or "nichts", "ältestes: %s; [Chefsache](chefsache/README.md)" % aeltest),
        ("Builds", "Änderungen warten auf deinen Test: **%d** (Tom %d, Jerry %d); %s" % (t1 + t2, t1, t2, rot_text(d.get("rot"))),
         "bei dir zum Testen: %s; ein Build nimmt alle fertigen Zweige (317)" % (", ".join(re.findall(r"\[(Build \d+)\]", lesen("chefsache/README.md"))) or "kein Build")),
        ("Fehler", fehler(d["jetzt"]), "offene Vorgänge des Spiels mit Fehler oder Befund im Titel, dazu jeder mit Build-Nummer (D55.3)"),
        ("Geld", ("Woche **%s %%** (dein Bild %s, %s)" % (gut.group(3), gut.group(1), gut.group(2)) if gut else "Woche unbekannt") +
         "; gestern %d $ Rechenwert, Spiel %d %%" % (ks, 100 * k["Spiel"] / ks if ks else 0) +
         ("" if gut and gut.group(1) == JETZT.strftime("%d.%m.") else "; **Bitte Bild der Nutzung** (Woche %; ruht die Niederlassung: nur Max; 783 W7)"), "Rechenwert = Listenpreis der Sitzungen, kein echtes Geld (Abo pauschal)"),
        ("Von dir zuerst gefunden", ein.get("Von dir zuerst gefunden", "–"), "Woche, zählt Diogenes montags"),
        ("Größtes Risiko", ein.get("Größtes Risiko", "–"), ""),
        ("Ausführlich", "[Abnahmeliste und Stand](PROJEKTPLAN.md)", ""),
    ]

def zahlen_md(d):
    zeilen_ = zeilen(d)
    md = ["**Stand %s, %s** (Werkzeug `tools/tagesbericht.py`)" % (JETZT.strftime("%d.%m."), JETZT.strftime("%H:%M")), "",
          "| # | Kennzahl | heute | Bemerkung |", "|---|---|---|---|"]
    def kurz(i, a, b, c):
        """Pflege 169 (08.11.): Tabellenzeile höchstens 400 Zeichen; lange Eingaben (Zeilen 3, 8, 9) nur mit dem ersten Satz, ganz unter „Eingaben“ und im Telegram."""
        z = "| %d | %s | %s | %s |" % (i + 1, a, b, c)
        if len(z) <= 400 or i not in (2, 7, 8): return z
        rest = 400 - len("| %d | %s |  | %s |" % (i + 1, a, c)) - len(" (ganz unter „Eingaben“)")
        satz = re.split(r"(?<=[a-zäöüß)]\.)\s(?=[A-ZÄÖÜ])", b, maxsplit=1)[0]  # Satzende, nicht „08.11.“
        if len(satz) > rest: satz = satz[:rest - 1].rsplit(" ", 1)[0] + " …"
        return "| %d | %s | %s (ganz unter „Eingaben“) | %s |" % (i + 1, a, satz, c)
    md += [kurz(i, a, b, c) for i, (a, b, c) in enumerate(zeilen_)]
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
    return "448: Tagesbericht %s (%sARBEIT-TAGESBERICHT.md)\n" % (JETZT.strftime("%d.%m."), GH) + "\n".join(
        "%d. %s: %s" % (i + 1, a, roh(b)) for i, (a, b, c) in enumerate(zs[:9])) + "\n10. Ausführlich: %sPROJEKTPLAN.md" % GH

def main():
    d = rechnen()
    if "--telegram" in sys.argv: print(telegram(d)); return 0
    md = zahlen_md(d)
    if "--probe" in sys.argv: print(md); return 0
    alt = lesen("ARBEIT-TAGESBERICHT.md")
    if "<!-- zahlen -->" in alt and "<!-- /zahlen -->" in alt:
        neu = re.sub(r"<!-- zahlen -->.*?<!-- /zahlen -->", lambda m: "<!-- zahlen -->\n" + md + "\n<!-- /zahlen -->", alt, flags=re.S)
    else:
        neu = "# Tagesbericht\n\n<!-- zahlen -->\n" + md + "\n<!-- /zahlen -->\n\n## Eingaben\n\n- Rest geschätzt: \n- Von dir zuerst gefunden: \n- Größtes Risiko: \n"
    open(ZIEL, "w", encoding="utf-8").write(neu)
    print("tagesbericht: %s geschrieben; Eingaben, Wer hinkt, Prioritäten von Hand prüfen" % os.path.relpath(ZIEL, ROOT))

if __name__ == "__main__":
    sys.exit(main())
