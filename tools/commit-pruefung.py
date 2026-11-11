#!/usr/bin/env python3
"""Prüfung beim Commit in der Notizkopie (192.1, Grenzen aus D31.1). Aufruf als pre-commit-Haken (notiz.sh richtet ihn ein).
Hält an (Exit 1): Uhrzeit von heute mehr als 5 Minuten nach jetzt in einer neuen Zeile; gelöschte Chefsache-Datei ohne
Änderung an VORGANGSARCHIV.md (Ausweg: BORNIM_ZURUECK=1 für zurückgezogene Fragen des Absenders); neue Tabellenzeile in einem Vorrat
(275.2: Vorgänge nur in LISTE-VORGAENGE.md); neuer Formfehler der Liste (startbar.pruefen_liste); Archiveintrag „tN“ (Test des Chefs), solange
Zeilen mit Build N „zu testen“ sind (Automatik B: erst vorgang.py build N); Vorrat über 15000 Bytes, den der Commit vergrößert
(Hinweis eines anderen mit „von <Absender>“ in jeder neuen Zeile ausgenommen, 400; ARBEIT-BETRIEB.md ausgenommen: Fords Startsperre muss dorthin, kürzen ist Fords Zeile); neue Antwort im Vorgangsarchiv, deren Vorlage
in entscheiden/, ansehen/ oder billigen/ stehen bleibt (383.3: wer die Antwort einträgt, löscht die Datei im selben Commit; bleibt die
Frage trotz Antwort offen, setzt er die Zeit in Zeile 1 oder 2 der Datei neu). Eine beantwortete Vorlage darf ohne Archivänderung weg.
Neuer Archiveintrag zu einer Nummer aus der Spalte „Woher“ der Kennungen A–G ohne Änderung an DESIGN-STIL/-KAMPF/-ABNAHME (461b; Ausweg
„461 unverändert“ im Eintrag); warnt bei geänderter alter Archivzeile und bei neuer Vorlage ohne berührte Kennung.
Gelöschte Vorlage mit „Was du tust: …“ ohne neue Datei in chefsache/tun/ (890; Ausweg BORNIM_GETAN=1); Datei in ansehen/ (außer t<Build>-…) ohne Bild, Film oder Frage (890).
Vorlage in docs/chefsache/ansehen/ mit „ohne Toon“, „Tusche fehlt“ u. ä. ohne Vergleich „mit Tusche“ (457, D56.1–2; Ausnahme „Chef erlaubt ohne Signatur“). Hält immer an (auch im Code): gekaufte Rohdatei (449: Kaufordner, Endung eines Kaufpakets, Inhalt wie im geklonten Kaufrepo). Hält an: CLAUDE.md oder ROLLE-*.md über der Obergrenze (OBERGRENZE), die der Commit vergrößert (822). Warnt (Exit 0): Modellnamen, Zeilen über 1500 Zeichen. Fasst nur Notizen an; sonst Exit 0. Jeder Fehler im Haken lässt durch."""
import datetime, os, re, subprocess, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

def git(*a):
    return subprocess.run(["git"] + list(a), capture_output=True, text=True).stdout

BESITZER = {"KREATIV": "Homer", "TEAM-TOM": "Tom", "TEAM-JERRY": "Jerry", "PROJEKT": "Perikles", "PRUEFUNG": "Diogenes", "BERATUNG": "Sokrates"}
NAMEN = ("Homer", "Tom", "Jerry", "Perikles", "Diogenes", "Sokrates", "Ford")

def fremd_hinweis(p):
    """400: Hinweis eines anderen in einen vollen Vorrat geht durch, wenn jede neue Zeile einen Absender nennt, der nicht der Besitzer ist;
    kürzen bleibt Sache des Besitzers (regelcheck meldet die Größe weiter). Sonst blieb der Hinweis beim Absender liegen."""
    eig = BESITZER.get(re.match(r"docs/ARBEIT-(.*)\.md$", p).group(1))
    zeilen = [z[1:] for z in git("diff", "--cached", "-U0", "--", p).splitlines() if z.startswith("+") and not z.startswith("+++") and z[1:].strip()]
    andere = "|".join(n for n in NAMEN if n != eig)
    # D80.2: Fund aus dem Test des Chefs, von Automatik B geschrieben („Zu NR, von Chef (Fund tN.k, …)“), ist ebenso ein fremder Hinweis
    return bool(zeilen) and all(re.search(r"\bvon (Team |Chef über )?(%s)\b|\bvon Chef \(Fund t\d+" % andere, z) for z in zeilen)

# 449: Ordner, in die tools/blender348/kauf_laden.sh lädt (Ziel kauf/kaufroh, Anhänge unter anhang/), und Endungen der Kaufpakete
# (Protofactor .rar/.fbx, Janpec .unitypackage, MadeCG .zip/.max/.blend; Quellformate der Werkzeuge). Eigene Modelle kommen als .glb aus Skripten.
KAUF_ORDNER = re.compile(r"(^|/)(kauf|kaufroh|anhang|bornim-kaufmodelle)/", re.I)
KAUF_ENDUNG = (".fbx", ".blend", ".blend1", ".max", ".ma", ".mb", ".3ds", ".dae", ".obj", ".gltf", ".unitypackage", ".uasset", ".umap",
               ".rar", ".zip", ".7z", ".tga", ".psd", ".spp", ".sbsar", ".exr")
# 457: Vorlage ohne Signatur (Chef 01.11., 11:49); „ohne Toon-Licht und Tusche“, „ohne Tusche“, „ohne Toon“
# D56.1: auch „kein Toon-Licht“, „Tusche fehlt“; D56.2: ein Vergleich „ohne … / mit Tusche“ in derselben Zeile geht durch
OHNE_SIGNATUR = re.compile(r"(?:ohne|kein\w*)\s+(Toon|Tusche|Spielshader)[\w-]*|(Toon|Tusche|Spielshader)[\w-]*\s+(?:fehl\w*|aus\b|weg\b)|ungeschattet", re.I)

def ohne_signatur(t):
    """D57.1: frei nur, wenn jedes fehlende Teil in derselben Zeile auch „mit <Teil>“ steht (Vergleich), nicht eine halbe Signatur."""
    for m in OHNE_SIGNATUR.finditer(t):
        teil = m.group(1) or m.group(2)
        if not teil or not re.search(r"\bmit\s+" + teil, t, re.I): return m.group(0)
    return None
LEER = "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391"  # leere Datei, kommt in beiden Repos vor

def kaufdateien(dat):
    """Gründe je Datei: Kaufordner, Endung eines Kaufpakets (BORNIM_EIGEN=1 lässt eine eigene Datei mit solcher Endung durch) oder derselbe
    Inhalt wie eine Datei im geklonten Kaufrepo (BORNIM_KAUF oder bornim-kaufmodelle neben der Kopie bzw. unter /home/user; gilt immer)."""
    raus = [p + " (Kaufordner)" for _, p in dat if KAUF_ORDNER.search(p)]
    if os.environ.get("BORNIM_EIGEN") != "1":
        raus += [p + " (Endung)" for _, p in dat if p.lower().endswith(KAUF_ENDUNG) and not KAUF_ORDNER.search(p)]
    wurzel = git("rev-parse", "--show-toplevel").strip()
    for k in [os.environ.get("BORNIM_KAUF", ""), os.path.join(os.path.dirname(wurzel), "bornim-kaufmodelle"), "/home/user/bornim-kaufmodelle"]:
        if k and os.path.isdir(os.path.join(k, ".git")):
            r = subprocess.run(["git", "-C", k, "ls-tree", "-r", "HEAD"], capture_output=True, text=True).stdout
            gekauft = {z.split()[2] for z in r.splitlines() if len(z.split()) > 2} - {LEER}
            schon = {x.rsplit(" (", 1)[0] for x in raus}
            for z in git("diff", "--cached", "--raw", "--no-renames", "--no-abbrev").splitlines():
                f = z.split("\t"); kopf = f[0].split()
                if len(f) > 1 and len(kopf) > 3 and kopf[3] in gekauft and f[1] not in schon:
                    raus.append(f[1] + " (Inhalt wie im Kaufrepo)")
            break
    return raus

GEPRUEFT = re.compile(r"Geprüft an:?\**\s*(?:\[[^\]]*\]\()?(?:https?://\S+|bilder:\S+|`?[0-9a-f]{7,40}`?|Lauf \d{3,})")
GILT = ("docs/DESIGN-STIL.md", "docs/DESIGN-KAMPF.md", "docs/DESIGN-ABNAHME.md")  # 461d: wo die Kennungen A–G stehen
WOHER_NR = re.compile(r"^\s*(?:Test\s+)?(\d{3}(?:\.\d+)?[a-z]?)(?![.:\d])")

def kennungen():
    """461b: {Vorgangsnummer: {Kennungen}} aus der Spalte „Woher“ der Tabellen A–G (Stand im Index)."""
    tafel = {}
    for p in GILT:
        for z in git("show", ":" + p).splitlines():
            t = [x.strip() for x in z.split("|")]
            if len(t) > 4 and re.fullmatch(r"[A-G]\d", t[1]):
                for teil in re.split(r"[,;]", t[3]):
                    m = WOHER_NR.match(teil)
                    if m: tafel.setdefault(m.group(1), set()).add(t[1])
    return tafel

def gueltig_pruefen(dat, stop, warn):
    """461b (Chef 01.11., 22:26, „461b ja“): neuer Archiveintrag zu einer Nummer, aus der eine Kennung A–G stammt (Spalte „Woher“), oder
    mit „Grundstand X1“/„461 X1“: im selben Commit die Zeile in DESIGN-STIL, -KAMPF oder -ABNAHME ändern; ändert der Entscheid
    nichts daran, steht „461 unverändert“ im Eintrag. Alte Archivzeilen: nur anhängen (z. B. „→ ersetzt durch …“), sonst Warnung."""
    diff = git("diff", "--cached", "-U0", "--", "docs/VORGANGSARCHIV.md").splitlines()
    plus = [z[1:] for z in diff if z.startswith("+") and not z.startswith("+++")]
    minus = [z[1:] for z in diff if z.startswith("-") and not z.startswith("---")]
    tafel = kennungen()
    # D63.2 (a): nur die Kennungen, deren Zeile in DESIGN-STIL/-KAMPF/-ABNAHME im Commit geändert wurde, zählen als berührt
    geaendert = set()
    for p in GILT:
        for z in git("diff", "--cached", "-U0", "--", p).splitlines():
            if z[:1] in "+-" and not z.startswith(("+++", "---")):
                t = [x.strip() for x in z[1:].split("|")]
                if len(t) > 2 and re.fullmatch(r"[A-G]\d", t[1]): geaendert.add(t[1])
    alt_archiv = git("show", "HEAD:docs/VORGANGSARCHIV.md")
    ersetzt = [neu for neu in plus if "ersetzt durch" in neu and any(a.strip() and neu.startswith(a.rstrip()) and neu.count("ersetzt durch") > a.count("ersetzt durch") for a in minus)]  # D65.1
    for alt in minus:  # geänderte alte Zeile: alter Text muss vorn stehen bleiben
        if alt.strip() and not any(neu.startswith(alt.rstrip()) for neu in plus):
            warn.append("VORGANGSARCHIV.md: alte Zeile geändert statt ergänzt („%s …“); am alten Eintrag nur „→ ersetzt durch …“ anhängen (461b)" % alt[:60])
    for neu in plus:
        if neu in minus or not neu.startswith("- **") or any(a.strip() and neu.startswith(a.rstrip()) for a in minus): continue
        if re.search(r"\b461 unverändert\b", neu): continue
        kopf = neu[4:neu.find("**", 4)] if "**" in neu[4:] else neu[4:60]
        nrn = set(re.findall(r"(?<![\d.])(\d{3}(?:\.\d+)?[a-z]?)(?![\d.:])", kopf))
        treffer = sorted({k for n in nrn for k in tafel.get(n, ())} | set(re.findall(r"\b(?:Grundstand|461)\s+([A-G]\d)\b", neu)))
        if treffer and geaendert & set(treffer):
            # D63.2 (b): gibt es schon einen Eintrag zu der Nummer, muss am alten „→ ersetzt durch …“ hängen
            frueher = [z for z in alt_archiv.splitlines() if z.startswith("- **") and any(
                re.search(r"(?<![\d.])" + re.escape(n) + r"(?![\d.:])", z[4:z.find("**", 4)] if "**" in z[4:] else z[4:60]) for n in nrn)]
            if frueher and "ersetzt nichts" not in neu and not any(any(e.startswith(f.rstrip()) for f in frueher) for e in ersetzt):
                stop.append("VORGANGSARCHIV.md: neuer Entscheid zu %s ersetzt einen älteren Eintrag; dort „→ ersetzt durch <Nr., Datum>“ anhängen "
                            "(461b); ergänzt er ihn nur: „ersetzt nichts“ in den Eintrag" % ", ".join(sorted(nrn)))
            continue
        if treffer:
            stop.append("VORGANGSARCHIV.md: neuer Entscheid zu %s berührt %s; im selben Commit die Zeile(n) in DESIGN-STIL/-KAMPF/-ABNAHME "
                        "ändern und am alten Eintrag „→ ersetzt durch …“ anhängen (461b); ändert er nichts daran: „461 unverändert“ in den Eintrag"
                        % (", ".join(sorted(nrn)) or kopf[:20], ", ".join(treffer)))
    for s, p in dat:  # 461b: Vorlage nennt berührte Punkte
        if s == "A" and re.match(r"docs/chefsache/(entscheiden|billigen|ansehen)/", p):
            n = os.path.basename(p).split("-")[0].lower()
            ks = sorted({k for nr, v in tafel.items() if nr.replace(".", "").lower() == n for k in v})
            if ks and not re.search(r"\b[A-G]\d\b|461", git("show", ":" + p)):
                warn.append("%s: Vorlage zu einem Vorgang mit Kennung (%s), nennt aber keinen berührten Punkt A–G (461b)" % (p, ", ".join(ks)))

TEILCHEN = re.compile(r"\b(GPUParticles[23]D|CPUParticles[23]D|ParticleProcessMaterial)\b")

def effekt_ohne_liste(dat):
    """623.3 (Chef 07.11., 623 E): neuer Shader (.gdshader) oder neuer Teilchenknoten in godot/, dessen Dateiname in LISTE-EFFEKTE.md
    nicht vorkommt: Warnung; erst dort und in LISTE-BESTAND.md nachsehen (Bibliothek vor Eigenbau), dann eintragen."""
    liste = ""
    for k in ("/home/user/bornim-main/docs/LISTE-EFFEKTE.md", "docs/LISTE-EFFEKTE.md"):
        if os.path.exists(k): liste = open(k, encoding="utf-8").read(); break
    raus, tipp = [], "vorher dort und in LISTE-BESTAND.md nachsehen, dann Anlass, Effekt, Quelle und den Dateinamen eintragen (623 E)"
    for s, p in dat:
        if s == "D" or not p.startswith("godot/") or re.search(r"(?<![\w.-])" + re.escape(os.path.basename(p)) + r"(?![\w.-])", liste): continue  # D79: ganzer Name
        if s == "A" and p.endswith(".gdshader"):
            raus.append("%s: neuer Shader ohne Zeile in LISTE-EFFEKTE.md; %s" % (p, tipp))
        elif p.endswith((".gd", ".tscn", ".tres")):
            neu = [z for z in git("diff", "--cached", "-U0", "--", p).splitlines() if z.startswith("+") and not z.startswith("+++")]
            if any(TEILCHEN.search(z) for z in neu):
                raus.append("%s: neuer Teilchenknoten ohne Zeile in LISTE-EFFEKTE.md; %s" % (p, tipp))
    return raus

def checkliste():
    """Die nummerierten Punkte aus docs/LISTE-CHECK-BUILD-TEST.md, ganz, ohne Fettdruck."""
    aus = []
    for z in git("show", ":docs/LISTE-CHECK-BUILD-TEST.md").splitlines():
        if z.startswith("## "): aus.append(z[3:])
        m = re.match(r"(\d+)\. (.*)", z)
        if m: aus.append("  %s. %s" % (m.group(1), re.sub(r"\*\*", "", m.group(2))))
    return "\n".join(aus)

# 822 (745 A2 Schritt 4, Chef 09.11., 17:46): Wachstumsstopp; feste Obergrenze in Bytes je Regeldatei, Stand 09.11.
# (nicht darunter; ROLLE-BERATUNG kürzt Sokrates selbst). Wer über der Grenze etwas hinzufügt, streicht im selben Commit
# mindestens ebenso viel (Regelbilanz, Haltung 6). Grenze heben nur mit Vorgang beim Chef.
OBERGRENZE = {"CLAUDE.md": 15000, "docs/ROLLE-BERATUNG.md": 19300, "docs/ROLLE-BETRIEB.md": 8700, "docs/ROLLE-ENTWICKLUNG.md": 13100,
              "docs/ROLLE-KREATIV.md": 6000, "docs/ROLLE-PROJEKT.md": 13200, "docs/ROLLE-PRUEFUNG.md": 6800}

def wachstum(dat):
    """822: Regeldatei über ihrer Obergrenze, die der Commit vergrößert."""
    if git("rev-parse", "-q", "--verify", "MERGE_HEAD").strip(): return []
    aus = []
    for s, p in dat:
        if s == "D" or p not in OBERGRENZE: continue
        neu, alt = len(git("show", ":" + p).encode()), len(git("show", "HEAD:" + p).encode())
        if neu > OBERGRENZE[p] and neu > alt:
            aus.append("%s: %d Bytes, Obergrenze %d, Commit fügt %d hinzu; im selben Commit ebenso viel streichen (Wachstumsstopp 822, Regelbilanz)" % (p, neu, OBERGRENZE[p], neu - alt))
    return aus

def kerntest_warn(dat):
    """192.3: Kerntest-Marke aus tools/t logik (voller Lauf, Exit 0) muss neuer sein als der Code."""
    code = [p for s, p in dat if s != "D" and re.match(r"(core|app|tools/preview)/.*\.(kt|kts)$", p)]
    if not code: return []
    marke = os.path.join(git("rev-parse", "--git-common-dir").strip(), "kerntest-ok")
    try: neuster = max(os.path.getmtime(p) for p in code if os.path.exists(p))
    except ValueError: neuster = 0
    if not os.path.exists(marke) or os.path.getmtime(marke) < neuster:
        return ["Code ohne grünen Kerntest seit der letzten Änderung (tools/t logik, Exit-Code prüfen)"]
    return []


SRD_DAZU = ["RK", "ZP", "Übungsbonus", "Rettungswurf", "Zauberplatz", "W20", "d20", "STR", "DEX", "CON", "INT", "WIS", "CHA",
            "Trefferwürfel", "Hauptattribut",  # 886 (D140.5, Plan Schritt 8); „TP“ nicht: Trefferpunkte bleiben im BRS (DESIGN-BRS 12, STORY-REGELN 3; 896)
            "Armor Class", "Hit Dice", "Hit Die", "saving throw", "Saving Throw", "Proficiency Bonus", "proficiency bonus", "Spell Slot", "spell slot"]


def srd_woerter():
    """870.11: alte Namen aus DESIGN-BRS.md 12 (Spalte „Alt“, wie regelcheck.py 4b) plus SRD_DAZU."""
    p = os.path.join(git("rev-parse", "--show-toplevel").strip(), "docs", "DESIGN-BRS.md")
    if not os.path.exists(p): p = "/home/user/bornim-main/docs/DESIGN-BRS.md"
    t = open(p, encoding="utf-8").read()
    ab = t.split("\n## 12. ")[1].split("\n## ")[0] if "\n## 12. " in t else ""
    w = []
    for z in ab.splitlines():
        s = [x.strip() for x in z.split("|")]
        if len(s) < 4 or s[1] in ("Alt", "---", ""): continue
        for n in re.split(r"[,/]", re.sub(r"\s*\(.*?\)", "", s[1])):
            n = re.sub(r"^Klassen\s+", "", n.strip())
            if n and n not in ("Schild", "Vorteil", "Nachteil"): w.append(n)
    return w + SRD_DAZU


# 978 (870.9): texte.json und held.json, bisher im Bau aus core erzeugt, einmal eingecheckt, sind Bestand, keine neuen Zeilen,
# wenn ihre kompakte Form (tools/karten/karten.py kanon) gleich dem Export von f32a789e6 ist; spätere Änderungen prüft srd_neu
# wie jede Zeile, --srd-bestand findet sie weiter (870.13).
BESTAND_870_9 = {"godot/daten/texte.json": "74d37eb3fb2759194a4b18c1972a5a0dfc8305724df64bd197c1712ca7f76fd7",
                 "godot/daten/held.json": "2e955c9b15d268abee7954ea5e9e8001fb244c055024adbb8f21e0bb0f529d2d"}


def bestand_870_9(p):
    """978: die neu angelegte Datei p ist der unveränderte Export aus core (Stand f32a789e6)."""
    if p not in BESTAND_870_9: return False
    import hashlib, json
    try: k = json.dumps(json.loads(git("show", ":" + p)), ensure_ascii=False, separators=(",", ":"))
    except ValueError: return False
    return hashlib.sha256(k.encode()).hexdigest() == BESTAND_870_9[p]


def srd_neu(dat):
    """870.11 (870, Umzug BRS Schritt 9): neue Zeilen unter godot/ (ohne tests/) mit SRD-Begriffen. Hält an, sobald 870.4 erledigt
    (nicht mehr offen in der Liste), vorher Warnung. (stop, warn)"""
    wege = [p for s, p in dat if s != "D" and p.startswith("godot/") and "/tests/" not in "/" + p
            and p.endswith((".gd", ".tscn", ".tres", ".json", ".csv", ".txt", ".cfg")) and not (s == "A" and bestand_870_9(p))]
    if not wege: return [], []
    muster = re.compile(r"(?<![\wÄÖÜäöüß])(%s)(?![\wÄÖÜäöüß])" % "|".join(map(re.escape, srd_woerter())))
    funde = {}
    datei = ""
    for z in git("diff", "--cached", "-U0", "--no-renames", "--", *wege).splitlines():
        if z.startswith("+++ b/"): datei = z[6:]; continue
        if not z.startswith("+") or z.startswith("+++"): continue
        for m in muster.finditer(z[1:]): funde.setdefault(datei, set()).add(m.group(1))
    if not funde: return [], []
    text = "neue SRD-Begriffe im Godot-Spiel (870.11, Namen nur nach DESIGN-BRS.md 12): " + "; ".join(
        "%s: %s" % (d, ", ".join(sorted(w))) for d, w in sorted(funde.items()))
    import startbar
    offen = any(d["nr"] == "870.4" and d["stand"].split(",")[0].strip() != "erledigt" for d in startbar.zeilen_liste())
    return ([], [text + " (hält an, sobald 870.4 erledigt ist)"]) if offen else ([text], [])


def main():
    ge = git("diff", "--cached", "--name-status", "--no-renames").splitlines()
    dat = [(l.split("\t")[0], l.split("\t")[1]) for l in ge if "\t" in l]
    video = [p for s, p in dat if s != "D" and p.lower().endswith((".mp4", ".webm"))]
    if video:  # 374 (373 b): Videos gehören auf den Zweig „bilder“ (meldung.sh legt sie dort ab), nie auf main
        print("Commit-Prüfung HÄLT AN: Video auf main (%s); auf den Zweig „bilder“ (374)" % ", ".join(video), file=sys.stderr); return 1
    kauf = kaufdateien([(s, p) for s, p in dat if s != "D"])
    if kauf:  # 449: gekaufte Rohdateien nur im privaten Repo bornim-kaufmodelle, nie hier (CLAUDE.md „Fremde Inhalte“, 348.12c a)
        print("Commit-Prüfung HÄLT AN: gekaufte Rohdatei (%s); gehört nur ins private Repo bornim-kaufmodelle (449)" % "; ".join(kauf), file=sys.stderr); return 1
    try:
        for w in effekt_ohne_liste(dat): print("Commit-Prüfung Warnung: " + w, file=sys.stderr)  # 623.3 (623 E): nur Warnung
    except Exception as e: print("Commit-Prüfung: 623.3 übersprungen (%s)" % e, file=sys.stderr)
    # 877 (D134.1): Code-Prüfungen vor dem Ausstieg für Code-Commits, sonst erreichte sie nie ein Commit unter core/, app/, godot/
    try:
        for w in kerntest_warn(dat): print("Commit-Prüfung Warnung: " + w, file=sys.stderr)
        srd_stop, srd_warn = srd_neu(dat)
        for w in srd_warn: print("Commit-Prüfung Warnung: " + w, file=sys.stderr)
        if srd_stop:
            for s in srd_stop: print("Commit-Prüfung HÄLT AN: " + s, file=sys.stderr)
            return 1
    except Exception as e: print("Commit-Prüfung: 870.11/877 übersprungen (%s)" % e, file=sys.stderr)
    if not dat or not all(p.startswith("docs/") or p in ("CLAUDE.md", "CHANGELOG.md") or p.startswith("tools/") for _, p in dat):
        return 0
    stop, warn = [], []
    import zoneinfo
    jetzt = datetime.datetime.now(zoneinfo.ZoneInfo("Europe/Berlin")); heute = jetzt.strftime("%d.%m.")
    arch = any(p == "docs/VORGANGSARCHIV.md" for _, p in dat)
    neu = git("diff", "--cached", "-U0", "--no-renames", "--", "docs", "CLAUDE.md").splitlines()
    datei = ""
    import startbar
    for z in neu:
        if z.startswith("+++ b/"): datei = z[6:]; continue
        if not z.startswith("+") or z.startswith("+++"): continue
        t = z[1:]
        tz = t
        if datei == "docs/LISTE-VORGAENGE.md" and t.startswith("| ") and t.count("|") >= 8:
            # 264.1: Feld „wartet auf“ darf eine spätere Uhrzeit von heute tragen (vorgang.py warte NR "TT.MM. HH:MM", Automatik A)
            zellen = t.split("|"); tz = "|".join(zellen[:6] + zellen[7:])
        for m in re.finditer(r"(?<!\d)" + re.escape(heute).replace(r"\.", r"\.") + r",? (\d\d):(\d\d)(?!\d)", tz):
            if jetzt.replace(hour=int(m.group(1)), minute=int(m.group(2))) > jetzt + datetime.timedelta(minutes=5):
                stop.append("%s: Uhrzeit %s:%s liegt nach jetzt (%s)" % (datei, m.group(1), m.group(2), jetzt.strftime("%H:%M"))); break
        mm = re.match(r"\| ([^|]+?) \| (M\?|M|K|–|-) \|", t)
        if mm and re.match(r"docs/ARBEIT-(KREATIV|TEAM|PROJEKT|PRUEFUNG|BERATUNG)", datei) and not git("rev-parse", "-q", "--verify", "MERGE_HEAD").strip():
            # 275.2 (Chef 07.11., 21:5x): Vorräte haben keine Tabelle mehr, jeder Vorgang steht nur in der Liste
            stop.append("%s: neue Tabellenzeile %s im Vorrat; Vorgänge nur in LISTE-VORGAENGE.md (`vorgang.py neu|stand|warte`, 275.2), Einzelheiten als „Zu %s“" % (datei, mm.group(1), mm.group(1)))
        if re.search(r"\b(opus|sonnet|haiku|fable)\b", t, re.I) and not datei.endswith(("LISTE-BETRIEB.md", "PRUEFBERICHT-ARCHIV.md", "VORGANGSARCHIV.md", "PRUEFBERICHT.md")) and not datei.startswith("tools/"):
            warn.append("%s: Modellname in neuer Zeile" % datei)
        if datei.startswith("docs/chefsache/ansehen/") and ohne_signatur(t) and "Chef erlaubt ohne Signatur" not in t:
            stop.append("%s: Vorlage „%s“: jede Probe mit Toon-Licht und Tusche wie im Spiel (457, Chef 01.11., 11:49: „unsere Signatur muss "
                        "sich wiederfinden“); neu zeichnen, Ausnahme nur mit „Chef erlaubt ohne Signatur“ in der Zeile" % (datei, ohne_signatur(t)))
        if len(t) > 1500 and datei.startswith("docs/ARBEIT-"): warn.append("%s: Zeile über 1500 Zeichen" % datei)
    try: stop += wachstum(dat)
    except Exception as e: warn.append("Wachstumsstopp übersprungen: %s" % e)
    antwort = startbar.antworten(git("show", ":docs/VORGANGSARCHIV.md")) if arch else startbar.antworten()
    if arch:  # 383.3: neue Antwort im Archiv → Vorlage zur Nummer im selben Commit weg (oder Zeit neu, wenn die Frage offen bleibt)
        neu_k = {m.group(1).replace(".", "").lower() for z in git("diff", "--cached", "-U0", "--", "docs/VORGANGSARCHIV.md").splitlines()
                 for m in [re.match(r"\+- \*\*([0-9A-Za-z][0-9A-Za-z.]*?)(?:,|\*\*| )", z)] if m}
        for p in git("ls-files", "--", "docs/chefsache/entscheiden", "docs/chefsache/ansehen", "docs/chefsache/billigen").split():
            n = os.path.basename(p)
            if n.split("-")[0].lower() in neu_k and n.endswith(".md") and os.path.exists(p):
                a = startbar.ueberholt(n, git("show", ":" + p), antwort)
                if a: stop.append("%s: Chef hat %s beantwortet (%s), die Vorlage bleibt stehen; im selben Commit löschen (383.3), "
                                  "bleibt die Frage offen: Zeit in Zeile 1 oder 2 der Datei neu setzen" % (p, a[0], a[1].strftime("%d.%m., %H:%M")))
    if any(p == "docs/LISTE-VORGAENGE.md" and s != "D" for s, p in dat) and not git("rev-parse", "-q", "--verify", "MERGE_HEAD").strip():
        # 275 Stufe 2 (Chef 27.10., 15:20: Schreiben nur über das Werkzeug): Stand, den kein Werkzeug geschrieben hat → Warnung (noch kein Halt)
        h = git("rev-parse", ":docs/LISTE-VORGAENGE.md").strip()
        ok = os.path.join(git("rev-parse", "--git-common-dir").strip(), "bornim-liste-ok")
        if h and h not in (open(ok).read().split() if os.path.exists(ok) else []):
            warn.append("LISTE-VORGAENGE.md von Hand geändert; neue Zeile mit `vorgang.py neu \"Titel\" \"Bereich\" KLASSE \"Besitzer\" [--nr NR]`, "
                        "Stand mit `vorgang.py stand|fertig` (275 Stufe 2; Diogenes zählt die Warnungen, danach hält sie an)")
            try:  # 734 (D92.1): je Warnung eine Zeile in warnungen-275.tsv im Zweig probelaeufe, sonst nicht zählbar
                sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
                import probelauf
                probelauf.zaehlen("275", (git("config", "user.name").strip() or "?")[:20], "liste-hand", datei="warnungen-275.tsv",
                                  lokal=os.path.expanduser("~/.bornim-warnungen-275.tsv"), extra=(h[:10], git("rev-parse", "--abbrev-ref", "HEAD").strip()))
            except Exception:
                pass
    if any(p == "docs/LISTE-VORGAENGE.md" and s != "D" for s, p in dat):  # 275.2: Form der Liste; nur neue Fehler halten an
        try:
            fehler = lambda rev: {"%s: %s" % f for f in startbar.pruefen_liste(startbar.vorgangsliste(git("show", rev + "docs/LISTE-VORGAENGE.md")))}
            alt_f = fehler("HEAD:")
            for f in sorted(fehler(":") - alt_f): stop.append("LISTE-VORGAENGE.md: " + f + " (Form 275.2; vorgang.py schreibt nur Gültiges)")
            if not startbar.vorgangsliste(git("show", ":docs/LISTE-VORGAENGE.md")): stop.append("LISTE-VORGAENGE.md: keine Tabelle mit Kopf " + startbar.KOPF)
        except Exception as e: warn.append("Formprüfung Liste übersprungen: %s" % e)
    if arch:  # 275.2 Automatik B: Testergebnis tN im Archiv nur, wenn vorgang.py build N die Liste abgeschlossen hat
        for z in git("diff", "--cached", "-U0", "--", "docs/VORGANGSARCHIV.md").splitlines():
            m = re.match(r"\+- \*\*t(\d+)\b", z)
            if not m: continue
            offen = [d["nr"] for d in startbar.vorgangsliste(git("show", ":docs/LISTE-VORGAENGE.md")) if d.get("build") == m.group(1) and d["wort"] in ("zu testen", "gebaut")]
            if offen: stop.append("VORGANGSARCHIV.md: Test t%s eingetragen, aber %s noch „zu testen“ mit Build %s; erst `python3 tools/vorgang.py build %s` (Automatik B, 275.2), dann im selben Commit" % (m.group(1), ", ".join(offen[:8]), m.group(1), m.group(1)))
            # 774 (t271: acht Tom-Zeilen in der Prüfliste ohne Build 271, nach dem Test nicht gebucht, Sperre 620.1 B hielt Tom)
            n = m.group(1)
            wege = {x for x in git("ls-tree", "-r", "--name-only", "HEAD", "docs/chefsache/ansehen/").split()} | {p for s, p in dat}
            pl = "".join(git("show", "HEAD:" + x) + git("show", ":" + x) for x in wege if re.match(r"docs/chefsache/ansehen/t%s-[^/]+\.md$" % n, x))
            import vorgang  # 775: dieselbe Lesart wie vorgang.py build (mehrere Nummern, Haken in Spalte 1)
            genannt = {x for nrs, _, _ in vorgang.ergebnisse(n, pl).values() for x in nrs}
            lose = [d["nr"] for d in startbar.vorgangsliste(git("show", ":docs/LISTE-VORGAENGE.md")) if d["nr"] in genannt and d.get("build") != n and d["wort"] in ("zu testen", "gebaut")]
            if lose: stop.append("VORGANGSARCHIV.md: Test t%s eingetragen, aber %s aus der Prüfliste ohne Build %s; erst `vorgang.py build %s --mit %s`, dann `vorgang.py build %s` (774)" % (n, ", ".join(lose[:8]), n, n, ",".join(lose), n))
    try: gueltig_pruefen(dat, stop, warn)
    except Exception as e: warn.append("461b-Prüfung übersprungen: %s" % e)
    for s, p in dat:  # 340.4 (Chef 02.11., 19:44, „340.2 ja“, B): jede Vorlage nennt „Geprüft an: <Link>“, ein Link, kein Wort
        if s in ("A", "M") and re.match(r"docs/chefsache/(entscheiden|ansehen|billigen)/(?!t\d+-)[^/]+\.md$", p) \
                and not GEPRUEFT.search(git("show", ":" + p)):
            stop.append("%s: Zeile „Geprüft an: <Link auf Film, Bild, Lauf oder Commit>“ fehlt (340.4); ein Link, kein Wort" % p)
    for s, p in dat:  # 657 D, fest seit 903 B (Chef 11.11., 07:46): neue Prüfliste zeigt die Checkliste Build und Test, ohne Enddatum;
        # 908 (D154.2): auch beim Entwurf in docs/entwurf/, sonst sieht sie seit 866 nur der Gegenleser, nie das bauende Team
        if s == "A" and re.match(r"docs/(chefsache/ansehen|entwurf)/t\d+-[^/]+\.md$", p):
            print("Checkliste Build und Test (657 D, 903 B), vor der Testbitte jeden Punkt abhaken:\n" + checkliste(), file=sys.stderr)
    for s, p in dat:  # 832 (Chef 10.11., 09:29): Lizenzen sichert der Test im Bau, nie eine Prüfzeile („Im Bau geprüft“)
        if s == "A" and re.match(r"docs/chefsache/ansehen/t\d+-[^/]+\.md$", p):
            for zl in re.findall(r"(?m)^\|\s*\d+\.\d+[a-z]?\s*\|.*$", git("show", ":" + p)):
                rf = " ".join(zl.rstrip().rstrip("|").split("|")[-2:])
                rf = re.sub(r"(?i)Lizenzen der Engine", "", rf)  # 847 (D128.1): Menüeintrag als Bedienelement ist kein Lizenzlesen
                if re.search(r"(?i:Lizenz|Urheber)|\bMIT\b|\bCC0\b|\bCC BY\b", rf):  # 846 (D127.1): nur Richtig/Falsch, der Weg darf über „Lizenzen“ führen
                    stop.append("%s: Prüfzeile verlangt Lizenzlesen (%s); gehört als Test unter „Im Bau geprüft“ (832, LISTE-CHECK-BUILD-TEST.md 9)" % (p, zl.split("|")[1].strip()))
    for s, p in dat:  # 866 (Chef 10.11., 13:34, t274: 7 von 18 Prüfzeilen fehlerhaft): neue Prüfliste nur gegengelesen
        if not (s == "A" and re.match(r"docs/chefsache/ansehen/t\d+-[^/]+\.md$", p)): continue
        inhalt = git("show", ":" + p)
        gl = re.search(r"(?m)^\W*Gegengelesen:?\**\s*(?:von\s+)?(Sokrates|Perikles|Homer|Diogenes|Ford|Tom|Jerry|Spike|Tuffy)\b.*\d\d?:\d\d", inhalt)
        if not gl:
            stop.append("%s: Zeile „Gegengelesen: <Rolle> <TT.MM., HH:MM>“ fehlt; Entwurf zuerst nach docs/entwurf/, eine Sitzung außerhalb des Teams prüft je Punkt "
                        "(aus frischem Spielstand am Gerät erreichbar, Weg genannt, sinnvoll), trägt die Zeile ein und verschiebt (866, 881)" % p)
            continue
        # 881 (D139.1): nie das eigene Team; Team aus Zeile 1 („# <Team oder „Tom und Jerry“> · Build …“), Spike zählt zu Tom, Tuffy zu Jerry
        team = {"Spike": "Tom", "Tuffy": "Jerry"}.get(gl.group(1), gl.group(1))
        kopf = (inhalt.splitlines() or [""])[0].split("·")[0]
        if team in ("Tom", "Jerry") and re.search(r"\b(%s|%s)\b" % (team, {"Tom": "Spike", "Jerry": "Tuffy"}[team]), kopf):
            stop.append("%s: gegengelesen vom eigenen Team (%s, Zeile 1: %s); eine Sitzung außerhalb des Teams liest gegen (881)" % (p, gl.group(1), kopf.strip("# ").strip()))
    for s, p in dat:  # 512.1 (Chef 03.11., 23:28, „Kümmer du dich um 512.“): neue Prüfliste nennt, was alt gegen neu verglichen ist
        if not (s == "A" and re.match(r"docs/chefsache/ansehen/t\d+-[^/]+\.md$", p)):
            continue
        vgl = re.search(r"(?m)^\**Verglichen\b(.*)$", git("show", ":" + p))  # D78.2: ganze Zeile, Uhrzeit-Doppelpunkt schneidet nicht mehr
        if not vgl:
            warn.append("%s: Zeile „Verglichen (alt gegen neu): <Schirme, Fenster, Bedienungen>“ fehlt (512, LISTE-CHECK-BUILD-TEST.md Punkt 8)" % p)
            continue
        zeile = vgl.group(1)  # 512b (Chef 04.11., 19:21): Nachweis mit Helfer und Bild/Film, keine Dateinamen
        if not re.search(r"Helfer", zeile) or re.search(r"\b(?:ohne|kein\w*)\s+(?:\w+\s+)?(?:Bild|Film)", zeile, re.I) \
                or not re.search(r"https?://|\.(png|webp|jpe?g|mp4)\b|Film|Bild", zeile):  # D78.2, D81.1: „ohne Bild“, „kein Film“, „kein neuer Bildabgleich“ sind kein Nachweis
            warn.append("%s: „Verglichen“ ohne Helfer (nicht der Bauende) oder ohne Bild/Film; Nachweis nach 512b "
                        "(LISTE-UMZUG-348 „Abgleich“)" % p)
        if re.search(r"\b\w+\.(kt|gd|py|tscn)\b", zeile):
            warn.append("%s: „Verglichen“ nennt Dateinamen; verlangt sind Schirme und Bedienungen (512b)" % p)
    for s, p in dat:
        if s == "D" and p.startswith("docs/chefsache/entscheiden/") and not arch and os.environ.get("BORNIM_ZURUECK") != "1" \
                and not startbar.ueberholt(os.path.basename(p), git("show", "HEAD:" + p), antwort):
            stop.append("%s gelöscht ohne Eintrag im Vorgangsarchiv (zurückgezogen: BORNIM_ZURUECK=1)" % p)
        if re.match(r"docs/ARBEIT-(KREATIV|TEAM-TOM|TEAM-JERRY|PROJEKT|PRUEFUNG|BERATUNG)\.md$", p) and s != "D":
            neu_b = len(git("show", ":" + p).encode()); alt = git("show", "HEAD:" + p)
            # Zusammenführen (559, 04.11.): gewachsen ist die Datei beim anderen, nicht in diesem Commit; Maß ist die größere Seite
            if git("rev-parse", "-q", "--verify", "MERGE_HEAD").strip(): alt = max(alt, git("show", "MERGE_HEAD:" + p), key=lambda x: len(x.encode()))
            if neu_b > 15000 and neu_b > len(alt.encode()) and not fremd_hinweis(p):
                stop.append("%s hat %d Bytes (über 15000) und wächst; erst kürzen (Hinweis eines anderen: Zeile mit „von <Absender>“ geht durch, 400)" % (p, neu_b))
    for w in tun_und_inhalt(dat): stop.append(w)  # 890
    if any(p in ("tools/gegenstaende/gegenstaende.json", "docs/LISTE-GEGENSTAENDE.md", "tools/gegenstaende.py") for s, p in dat if s != "D"):
        r = subprocess.run([sys.executable, "tools/gegenstaende.py", "--pruefen"], capture_output=True, text=True)
        if r.returncode: stop.append("Gegenstandskatalog (458, D56.4): " + (r.stdout.strip().replace("\n", "; ") or "Prüfung fehlgeschlagen"))
    for w in warn: print("Commit-Prüfung Warnung: " + w, file=sys.stderr)
    for s in stop: print("Commit-Prüfung HÄLT AN: " + s, file=sys.stderr)
    return 1 if stop else 0

WAS_DU_TUST = re.compile(r"(?m)^\W*Was du tust:?\**\s*(.*)$")
INHALT_BILD = re.compile(r"!\[|<img|<video|\.(?:png|webp|jpe?g|gif|mp4|webm)\b|bilder/|\bFilm:|\bBild:", re.I)

def frage_in(text):
    """890: Frage an den Chef: „**Frage**“ oder ein Fragezeichen außerhalb von Links."""
    ohne = re.sub(r"https?://\S+|\([^)\s]*\?[^)\s]*\)", "", text)
    return bool(re.search(r"\*\*Frage|\?", ohne))

def tun_und_inhalt(dat):
    """890 (654, Chef 10.11., 17:15): (1) wird eine Vorlage mit „Was du tust: …“ gelöscht, muss im selben Commit eine Datei in
    docs/chefsache/tun/ dazukommen (854a: Token-Schritt ging mit der Vorlage verloren); Ausweg BORNIM_GETAN=1, wenn der Chef es schon
    getan hat. (2) eine Datei in docs/chefsache/ansehen/ (außer Prüflisten t<Build>-…) ohne Bild, Film oder Frage hält an (663 lag als
    bloßer Stand beim Chef); ein Stand gehört in die Vorgangsliste."""
    stop = []
    tun_neu = any(s == "A" and re.match(r"docs/chefsache/tun/[^/]+\.md$", p) for s, p in dat)
    for s, p in dat:
        if s == "D" and re.match(r"docs/chefsache/(entscheiden|ansehen|billigen)/[^/]+\.md$", p) and not tun_neu \
                and os.environ.get("BORNIM_GETAN") != "1":
            m = WAS_DU_TUST.search(git("show", "HEAD:" + p))
            if m and m.group(1).strip(" .*") and not re.match(r"(?i)(?:–|-)(?!\w)|(?:nichts|nein|entfällt)\b", m.group(1).strip(" *")):
                stop.append("%s gelöscht, „Was du tust“ geht verloren (%s); im selben Commit `docs/chefsache/tun/<nr>-<stichwort>.md` anlegen "
                            "(Aufbau chefsache/README.md „Zu tun“); hat der Chef es schon getan: BORNIM_GETAN=1 (890)" % (p, m.group(1).strip()[:80]))
        if s in ("A", "M") and re.match(r"docs/chefsache/ansehen/(?!t\d+-)[^/]+\.md$", p):
            inhalt = git("show", ":" + p)
            if not INHALT_BILD.search(inhalt) and not frage_in(inhalt):
                stop.append("%s ohne Bild, Film oder Frage; nur Stand gehört in die Vorgangsliste (`vorgang.py stand`), nicht zum Chef (890, Fall 663)" % p)
    return stop

def srd_bestand():
    """886 (D140.5): Lauf über den ganzen Godot-Code (ohne tests/) für die Abnahme 870.13; Exit 1 bei jedem Fund."""
    wurzel = git("rev-parse", "--show-toplevel").strip()
    muster = re.compile(r"(?<![\wÄÖÜäöüß])(%s)(?![\wÄÖÜäöüß])" % "|".join(map(re.escape, srd_woerter())))
    n = 0
    for p in git("ls-files", "godot").split():
        if "/tests/" in "/" + p or not p.endswith((".gd", ".tscn", ".tres", ".json", ".csv", ".txt", ".cfg")): continue
        try: zeilen = open(os.path.join(wurzel, p), encoding="utf-8", errors="replace").read().splitlines()
        except OSError: continue
        for i, z in enumerate(zeilen, 1):
            w = sorted({m.group(1) for m in muster.finditer(z)})
            if w: n += 1; print("%s:%d: %s" % (p, i, ", ".join(w)))
    print("SRD-Bestand (886): %d Zeilen mit alten Begriffen" % n, file=sys.stderr)
    return 1 if n else 0


if __name__ == "__main__":
    if "--srd-bestand" in sys.argv: sys.exit(srd_bestand())
    try: sys.exit(main())
    except Exception as e:
        print("Commit-Prüfung übersprungen: %s" % e, file=sys.stderr); sys.exit(0)
