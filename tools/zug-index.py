#!/usr/bin/env python3
"""Übersicht für „Chefsache“ (108): schreibt docs/chefsache/README.md aus den Dateien in entscheiden/ und ansehen/.

Läuft als GitHub Action bei jedem Push nach docs/chefsache/ (zug-index.yml); keine Sitzung bearbeitet die README von Hand,
darum gibt es dort keine Konflikte (D15.3). Lokal zur Vorschau: python3 tools/zug-index.py (nicht committen).
Je Datei: Zeile 1 „# <Nr.> · <Frage>“, Zeile 2 „<Absender> · <TT.MM.>, …“; optional „Kurz: …“ als Text der Übersicht.
"""
import os, re, sys

ZUG = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "docs", "chefsache")
BEREICH = re.compile(r"^[EGQBM] [A-ZÄÖÜ]\w+$")

def vorgaenge():
    """Bereich und Klasse je Nummer aus LISTE-VORGAENGE.md (124, 126, 136)."""
    pfad = os.path.join(ZUG, "..", "LISTE-VORGAENGE.md")
    tafel = {}
    for z in (open(pfad, encoding="utf-8").read().splitlines() if os.path.exists(pfad) else []):
        t = [x.strip() for x in z.split("|")]
        if len(t) > 4 and z.startswith("| "): tafel[t[1]] = (t[3], t[4])
    return tafel

VORGAENGE = vorgaenge()
KLASSE = {"M": "Muss", "K": "Kür"}

def nachschlagen(nr):
    """72s.1 → 72s.1, 72s, 72: die nächste Nummer mit Zeile in LISTE-VORGAENGE.md."""
    while nr:
        if nr in VORGAENGE: return VORGAENGE[nr]
        kurz = re.sub(r"(\.\d+[a-z]*|[a-z])$", "", nr)
        if kurz == nr: break
        nr = kurz
    return ("", "")

KOPF = """# Chefsache

Was auf den Chef wartet (63, 108). Diese Übersicht schreibt ein Werkzeug (`tools/zug-index.py`) bei jedem Push; nicht von Hand ändern.
"""

REGELN = """## So geht's

- Je Punkt eine Datei: `entscheiden/<nr>-<stichwort>.md` (Nummer ohne Punkt, z. B. `72s1-gefaehrte-kapitel2.md`) oder `ansehen/t<build>-<stichwort>.md`. Erledigt heißt Datei löschen.
- Anzusehen als Bildvorschau (228, kein Build): `ansehen/<nr>-<stichwort>.md`, Zeile 1 `# <Nr.> · <Thema> · <Team> · <TT.MM.>, <HH:MM>`, dann Bild aus `bilder/` und der Satz, was der Chef sagen soll.
- Anzusehen (nur mit Build, Datei `ansehen/t<build>-<stichwort>.md`): Zeile 1 `# <Team oder „Tom und Jerry“> · Build <n> · <Version> · <Thema> · <PR>` (fehlt die Version, trägt die Action sie aus dem Lauf zum PR nach, 298), Zeile 2 `<Bereich, z. B. E Kampf> · <Team> · <TT.MM.>, <HH:MM> · <APK-Link>`, dann Tabelle `| # | Team | Nr. | Wo und wie | Richtig | Falsch |` (Spalte Team bei gemeinsamem Build) mit 3–6 Vorgängen (317, Ziel 4; weniger nur auf „jetzt“ des Chefs, Wort in der Datei) und konkreten Schritten („Tippe …, erwarte …“); davor ein Satz „Ein Weg: …; über Build <n−1> installieren“, Zeilen in der Reihenfolge dieses Wegs (`LISTE-BAUEN-TESTEN.md` „Gemeinsamer Build“). Sammelseite je Build: `## Build <n> · <Version> · <Thema> · <PR>`. Die Übersicht zeigt jeden Build als Zeile, nach Version sortiert (127); Abweichungen stehen unter „Lücken“.
- Zeile 1 `# <Nr.> · <Frage>`, Zeile 2 `<Absender> · <TT.MM.>, <HH:MM> · <Bereich> · …` (Bereich wie „B Abläufe“, 136); Vorrang = Klasse der Nummer in `LISTE-VORGAENGE.md`; eine Zeile `Kurz: …` ersetzt in der Übersicht die Frage. Dann in dieser Folge (364): **Frage**, **Votum** (was der Chef tun oder sagen soll), **Berührt** (Vorgänge); darunter kurz **Begründung**, **Sachverhalt** (belegt, mit Quelle), **Auswertung** (mit dem stärksten Gegenargument), **Folgerungen** (was danach geschieht, wer); zuletzt `Antwort: …`. Lange Teile in `<details>`.
- Zu billigen (Vorentscheid, 194.1): `billigen/<nr>-<stichwort>.md`, Aufbau wie bei „entscheiden“, Votum = Entschieden, plus: Umgesetzt (Commit), Rückbau, Kosten; in der Auswertung bei Balance und Spielgefühl die verworfene Möglichkeit. Hält keine Arbeit an; Antwort „gebilligt“ oder „zurück“, Sokrates löscht die Datei und setzt „gebilligt TT.MM.“ oder „zurück TT.MM.“ in die Archivzeile.
- Bilder in `bilder/`: JPG oder WebP, höchstens 800 px breit und 60 KB, höchstens 3 je Punkt. Größere Bilder und Hörproben nur über Telegram (`meldung.sh --datei`), in der Datei vermerkt: „Großbild: Telegram TT.MM. HH:MM“.
- Telegram-Sprungmarke `[72s.1](cs:72s1)` führt auf die Datei (`tools/meldung.sh`).
"""

def eintrag(ordner, name):
    text = open(os.path.join(ZUG, ordner, name), encoding="utf-8").read()
    zeilen = [z.strip() for z in text.splitlines() if z.strip()]
    kopf = zeilen[0].lstrip("#").strip() if zeilen else name
    nr, _, was = kopf.partition(" · ")
    if not was: nr, was = name.split("-")[0], kopf
    meta = next((z for z in zeilen[1:] if not z.startswith("Kurz:")), "")
    wer = meta.split(" · ")[0] if " · " in meta else ""
    m = re.search(r"\b(\d\d)\.(\d\d)\.", meta)
    seit = m.group(0) if m else ""
    kurz = next((z[5:].strip() for z in zeilen if z.startswith("Kurz:")), None)
    if kurz: was = kurz
    else:
        e = re.search(r"\*\*Empfehlung:?\s*([^*]{1,40}?)\.?\*\*", text)
        if e and e.group(1).strip(): was += f" (Empfehlung: {e.group(1).strip()})"
    sort = (m.group(2) + m.group(1)) if m else "0000"
    bereich, klasse = nachschlagen(nr)
    bereich = next((t.strip() for t in meta.split(" · ")[1:] if BEREICH.match(t.strip())), bereich)
    vorrang = KLASSE.get(klasse, klasse if klasse not in ("", "–") else "–")
    return (vorrang == "Muss", sort), f"| [{nr}]({ordner}/{name}) | {'**Muss**' if vorrang == 'Muss' else vorrang} | {bereich or '–'} | {seit} | {was.replace('|', '/')} | {wer} |"

def tafel(ordner, titel, kopf=None):
    pfad = os.path.join(ZUG, ordner)
    namen = sorted(n for n in os.listdir(pfad) if n.endswith(".md")) if os.path.isdir(pfad) else []
    zeilen = [z for _, z in sorted((eintrag(ordner, n) for n in namen), key=lambda t: t[0], reverse=True)]
    if not zeilen: return f"## {titel}\n\nNichts offen.\n"
    kopf = kopf or "Muss zuerst, dann neueste oben. Vorrang und Bereich aus `LISTE-VORGAENGE.md` (Klasse, 126; Bereich, 124), Bereich in Zeile 2 der Datei geht vor (136)."
    return f"## {titel}\n\n{kopf}\n\n| Nr. | Vorrang | Bereich | Seit | Was | Wer |\n|---|---|---|---|---|---|\n" + "\n".join(zeilen) + "\n"

VERSION = re.compile(r"\b0\.1\.(\d+)\b")

def builds(name):
    """Anzusehen (127): eine Zeile je Build, auch aus Sammelseiten („## Build n · 0.1.x · Thema · PR“)."""
    text = open(os.path.join(ZUG, "ansehen", name), encoding="utf-8").read()
    zeilen = [z.strip() for z in text.splitlines() if z.strip()]
    kopf = zeilen[0].lstrip("#").strip() if zeilen else name
    meta = next((z for z in zeilen[1:] if not z.startswith("Kurz:")), "")
    wer = kopf.split(" · ")[0]
    m = re.search(r"\b(\d\d)\.(\d\d)\.", meta)
    seit = m.group(0) if m else ""
    tn = re.match(r"t(\d+)-", name)
    # APK-Link in der Bereichszeile (Lauf oder Pull-Request), sonst der Pull-Request aus Zeile 1: die Spalte „Build“ ist dann anklickbar
    ml = re.search(r"\]\((https://[^)]+)\)", meta)
    pr = re.search(r"PR #(\d+)", kopf + " " + meta)
    apk = ml.group(1) if ml else (f"https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/{pr.group(1)}" if pr else "")
    if not tn:  # Bildvorschau (228, 165): „# <Nr.> · <Thema> · <Team> · <TT.MM.>, <HH:MM>“, kein Build
        teile = kopf.split(" · ")
        team = next((t for t in teile[2:] if t in TEAMS), "")
        d = re.search(r"\b(\d\d)\.(\d\d)\.", kopf)
        return [(10**6, "–", "–", teile[1] if len(teile) > 1 else kopf, name, team or wer, d.group(0) if d else seit)]
    def zeile(teile, standard):
        v = next((VERSION.search(t) for t in teile if VERSION.search(t)), None)
        build = next((t for t in teile if re.match(r"Build \d+$", t)), f"Build {tn.group(1)}" if tn else "")
        was = next((t for t in teile[1:] if not VERSION.search(t) and not t.startswith("[PR") and not re.match(r"Build \d+$", t)), standard)
        return (int(v.group(1)) if v else 10**6, v.group(0) if v else "–", f"[{build}]({apk})" if apk and build else build, was.replace("|", "/"))
    abschnitte = [z.lstrip("#").strip().split(" · ") for z in text.splitlines() if re.match(r"## Build \d+ · ", z)]
    if abschnitte:
        return [(*zeile(t, t[0]), name, wer, seit) for t in abschnitte]
    kurz = next((z[5:].strip() for z in zeilen if z.startswith("Kurz:")), kopf)
    return [(*zeile(kopf.split(" · "), kurz), name, wer, seit)]

def tafel_ansehen():
    pfad = os.path.join(ZUG, "ansehen")
    namen = sorted(n for n in os.listdir(pfad) if n.endswith(".md")) if os.path.isdir(pfad) else []
    alle = sorted((b for n in namen for b in builds(n)), key=lambda b: b[0])
    if not alle: return "## Anzusehen\n\nNichts offen.\n"
    kopf = "## Anzusehen\n\nReihenfolge = Version aufsteigend (Android installiert nur höhere Nummern über niedrigere).\n\n| Folge | Version | Build | Was | Wer | Seit |\n|---|---|---|---|---|---|\n"
    return kopf + "\n".join(f"| {i} | [{v}](ansehen/{n}) | {b or '–'} | {w} | {wer} | {seit} |" for i, (_, v, b, w, n, wer, seit) in enumerate(alle, 1)) + "\n"

DOCS = os.path.join(ZUG, "..")
TEAMS = ("Tom", "Jerry", "Homer", "Perikles", "Sokrates", "Diogenes", "Ford")

def formfehler():
    """Testdateien in ansehen/ mit t<Build>-Namen: Team in Zeile 1, Bereichszeile („E Kampf · Team · TT.MM.“) als Zeile 2, Tabelle mit Spalten # | Nr. | Wo und wie | Richtig | Falsch."""
    pfad = os.path.join(ZUG, "ansehen")
    fehler = []
    for n in sorted(os.listdir(pfad)) if os.path.isdir(pfad) else []:
        if not re.match(r"t\d+-.*\.md$", n): continue
        text = open(os.path.join(pfad, n), encoding="utf-8").read()
        z = [x.strip() for x in text.splitlines() if x.strip()]
        kopf, meta = (z + ["", ""])[:2]
        if any(re.sub(r" \d+$", "", t.strip()) not in TEAMS for t in re.split(r" und | \+ |/|, ", kopf.lstrip("# ").split(" · ")[0])): fehler.append(f"{n}: Zeile 1 beginnt nicht mit dem Team")
        if not re.match(r"[A-Z] \w+ · ", meta): fehler.append(f"{n}: Zeile 2 ist keine Bereichszeile")
        if not re.search(r"^\|\s*#\s*\|(\s*Team\s*\|)?\s*Nr\.\s*\|\s*Wo und wie\s*\|\s*Richtig\s*\|\s*Falsch\s*\|", text, re.M): fehler.append(f"{n}: Tabelle `# | Nr. | Wo und wie | Richtig | Falsch` fehlt")
        else:  # 317: gemeinsamer Build bündelt 3–6 Vorgänge (Ziel 4), weniger nur auf „jetzt“ des Chefs
            zeilen = [[c.strip() for c in x.strip("|").split("|")] for x in z if x.startswith("|") and not re.match(r"\|[\s|:-]*$", x)]
            sp = zeilen[0].index("Nr.") if zeilen and "Nr." in zeilen[0] else 1
            nrn = {r[sp] for r in zeilen[1:] if len(r) > sp and r[sp]}
            if len(nrn) > 6: fehler.append(f"{n}: {len(nrn)} Vorgänge, höchstens 6 je Build (317)")
            elif len(nrn) < 3 and "jetzt" not in text: fehler.append(f"{n}: nur {len(nrn)} Vorgänge; ein Build bündelt 3–6, weniger nur auf „jetzt“ des Chefs (317)")
        kopfzeilen = [kopf] + [x for x in z if re.match(r"## Build \d+ · ", x)]
        if not any(VERSION.search(x) for x in kopfzeilen): fehler.append(f"{n}: Version 0.1.<Laufnummer> fehlt in Zeile 1 (trägt die Action nach, sobald der Lauf zum PR in Zeile 1 begonnen hat, 298; ohne PR selbst nachtragen; ohne Version stimmt die Folge nicht, 286)")
    return fehler
NR = r"[A-Z]?\d+[a-z]*(?:\.\d+[a-z]*)?"

def luecken():
    """D21.3: Vorratszeilen, die auf den Chef warten oder „Chefsache <Nr>“ nennen, ohne Datei hier (ARCHIV eingefroren, nicht gelesen)."""
    texte = []
    for ordner in ("entscheiden", "ansehen", "billigen"):
        pfad = os.path.join(ZUG, ordner)
        for n in (sorted(os.listdir(pfad)) if os.path.isdir(pfad) else []):
            if n.endswith(".md"): texte.append(n + "\n" + open(os.path.join(pfad, n), encoding="utf-8").read())
    alles = "\n".join(texte)
    def gestellt(nr):
        return re.search(r"(?<![\w.])" + re.escape(nr) + r"(?![\w])", alles) or re.search(r"(?<![\w])" + re.escape(nr.replace(".", "")) + r"-", alles)
    nicht, ohne = [], []
    for n in sorted(os.listdir(DOCS)):
        if not (n.startswith("ARBEIT-") and n.endswith(".md")) or n == "ARBEIT-ARCHIV.md": continue
        wer = n[7:-3].replace("-", " ").title()
        for z in open(os.path.join(DOCS, n), encoding="utf-8").read().splitlines():
            if not z.startswith("| "): continue
            nr = z.split("|")[1].strip()
            if not re.fullmatch(NR, nr): continue
            if "wartet auf Chef" in z and not gestellt(nr) and (nr, wer) not in nicht: nicht.append((nr, wer))
            for c in re.findall(r"Chefsache (" + NR + r")\b", z):
                if not gestellt(c) and (c, wer) not in ohne: ohne.append((c, wer))
    form = formfehler()
    if not nicht and not ohne and not form: return ""
    teile = ["## Lücken\n\nVom Werkzeug gefunden (D21.3): steht im Vorrat, hat hier keine Datei.\n"]
    if form: teile.append("Format (Muster: „So geht's“ unten): " + "; ".join(form) + "\n")
    if nicht: teile.append("Nicht gestellt: " + ", ".join(f"{nr} ({wer})" for nr, wer in nicht) + "\n")
    if ohne: teile.append("Ohne Datei: " + ", ".join(f"{nr} ({wer})" for nr, wer in ohne) + "\n")
    return "\n".join(teile)

def offen_je_rolle():
    """167.10: Abschnitt aus startbar.py --md; fällt das Werkzeug aus, fehlt nur der Abschnitt."""
    try:
        import subprocess, sys as _s
        r = subprocess.run([_s.executable, os.path.join(os.path.dirname(os.path.abspath(__file__)), "startbar.py"), "--md"], capture_output=True, text=True, timeout=60)
        return r.stdout.strip()
    except Exception:
        return ""

def lauf_version(pr, _cache={}):
    """298: Version 0.1.<Laufnummer> des neuesten „Build APK“-Laufs am Zweig des PR (GitHub-API, nur mit GITHUB_TOKEN)."""
    token, repo = os.environ.get("GITHUB_TOKEN"), os.environ.get("GITHUB_REPOSITORY")
    if not (token and repo): return None
    if pr in _cache: return _cache[pr]
    import json, urllib.request, urllib.parse
    def hole(pfad):
        req = urllib.request.Request(f"https://api.github.com/repos/{repo}/{pfad}", headers={"Authorization": f"Bearer {token}", "Accept": "application/vnd.github+json"})
        with urllib.request.urlopen(req, timeout=20) as r: return json.load(r)
    try:
        zweig = hole(f"pulls/{pr}")["head"]["ref"]
        laeufe = hole(f"actions/workflows/android.yml/runs?per_page=1&branch={urllib.parse.quote(zweig)}")["workflow_runs"]
        _cache[pr] = f"0.1.{laeufe[0]['run_number']}" if laeufe else None
    except Exception as e:
        print(f"zug-index: Version zu PR #{pr} nicht geholt ({e})")
        _cache[pr] = None
    return _cache[pr]

def versionen_nachtragen():
    """298: Kopfzeilen von t<Build>-Dateien ohne Version bekommen sie hinter „Build n“ (Quelle: PR in derselben Zeile)."""
    pfad = os.path.join(ZUG, "ansehen")
    for n in sorted(os.listdir(pfad)) if os.path.isdir(pfad) else []:
        if not re.match(r"t\d+-.*\.md$", n): continue
        datei = os.path.join(pfad, n)
        zeilen = open(datei, encoding="utf-8").read().split("\n")
        geaendert = False
        for i, z in enumerate(zeilen):
            if not (i == 0 and z.startswith("# ") or re.match(r"## Build \d+ · ", z)) or VERSION.search(z): continue
            pr, teile = re.search(r"PR #(\d+)", z), z.split(" · ")
            stelle = next((k for k, t in enumerate(teile) if re.fullmatch(r"(## )?Build \d+", t)), None)
            v = lauf_version(pr.group(1)) if pr and stelle is not None else None
            if not v: continue
            zeilen[i] = " · ".join(teile[:stelle + 1] + [v] + teile[stelle + 1:])
            geaendert = True
            print(f"zug-index: {n} Version {v} nachgetragen")
        if geaendert: open(datei, "w", encoding="utf-8").write("\n".join(zeilen))

versionen_nachtragen()
neu = "\n".join([t for t in [KOPF, tafel("entscheiden", "Zu entscheiden"), tafel("billigen", "Zu billigen", "Schon entschieden und umgesetzt (Vorentscheid, 194.1); hält keine Arbeit an. Antwort „gebilligt“ oder „zurück“ im Gespräch mit Sokrates; „zurück“ legt den Rückbau als Muss in den Vorrat des Besitzers."), tafel_ansehen(), offen_je_rolle(), luecken(), REGELN] if t])
ziel = os.path.join(ZUG, "README.md")
alt = open(ziel, encoding="utf-8").read() if os.path.exists(ziel) else ""
if neu != alt:
    open(ziel, "w", encoding="utf-8").write(neu)
    print("zug-index: README neu")
else:
    print("zug-index: unverändert")
