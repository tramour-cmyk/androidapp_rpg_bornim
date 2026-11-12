#!/usr/bin/env python3
"""Übersicht für „Chefsache“ (108): schreibt docs/chefsache/README.md aus den Dateien in entscheiden/ und ansehen/.

Läuft als GitHub Action bei jedem Push nach docs/chefsache/ (zug-index.yml); keine Sitzung bearbeitet die README von Hand,
darum gibt es dort keine Konflikte (D15.3). Lokal zur Vorschau: python3 tools/zug-index.py (nicht committen).
Je Datei: Zeile 1 „# <Nr.> · <Frage>“, Zeile 2 „<Absender> · <TT.MM.>, …“; optional „Kurz: …“ als Text der Übersicht.
"""
import os, re, subprocess, sys

ZUG = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "docs", "chefsache")
# 275 (Chef 15:21): „Seit“ mit Uhrzeit, „damit ich sehe, das liegt jetzt schon so und so lange“; 465: auch „20:3x“
SEIT = r"\b(\d\d)\.(\d\d)\.(?:,? (\d\d:\d[\dx]))?"


def seit_text(m, pfad):
    """465 (Chef 01.11., 20:50: „Warum ist eigentlich in der Chefsache zu entscheiden keine Uhrzeit dabei? … Die muss da
    unbedingt rein mit.“): fehlt die Uhrzeit oder steht „x“ darin, gilt die Zeit des Commits, der die Datei angelegt hat
    (Berliner Zeit), sofern er am selben Tag war."""
    if not m:
        return ""
    if m.group(3) and "x" not in m.group(3):
        return m.group(0)
    tag = f"{m.group(1)}.{m.group(2)}."
    vorn = m.group(3)[:4] if m.group(3) else ""  # „20:3x“: Commit-Zeit muss zu 20:3 passen
    try:
        r = subprocess.run(["git", "-C", os.path.dirname(pfad), "log", "--format=%cd", "--date=format-local:%d.%m. %H:%M",
                            *([] if vorn else ["--diff-filter=A"]), "--", os.path.basename(pfad)],
                           capture_output=True, text=True, timeout=10, env={**os.environ, "TZ": "Europe/Berlin"})
        zeiten = [z.split(" ") for z in r.stdout.split("\n") if z.strip()]
    except (OSError, subprocess.SubprocessError):
        return m.group(0)
    for t, uhr in zeiten[::-1]:  # älteste passende zuerst: seit wann es so dasteht
        if t == tag and uhr.startswith(vorn):
            return f"{tag}, {uhr}"
    # 465.1 (D60.1): passt die geschätzte Minute zu keinem Commit, gilt der älteste Commit des Tages (Git vor Schätzung)
    for t, uhr in zeiten[::-1]:
        if t == tag:
            return f"{tag}, {uhr}"
    return m.group(0)
BEREICH = re.compile(r"^[A-Z] [A-ZÄÖÜ]\w+$")  # D77: alle Bereichsbuchstaben der Vorgangsliste (C Kampf, F Firma …)
WER = re.compile(r"^(?:Team )?(?:Tom|Jerry|Spike|Tuffy|Homer|Sokrates|Perikles|Diogenes|Ford)(?:\b.*)?$")


def anlage_zeit(pfad):
    """465 (474a): ohne Datum in der Datei gilt die Zeit des Commits, der sie angelegt hat."""
    try:
        r = subprocess.run(["git", "-C", os.path.dirname(pfad), "log", "--diff-filter=A", "--format=%cd",
                            "--date=format-local:%d.%m., %H:%M", "--", os.path.basename(pfad)],
                           capture_output=True, text=True, timeout=10, env={**os.environ, "TZ": "Europe/Berlin"})
        z = [x for x in r.stdout.split("\n") if x.strip()]
        return z[-1] if z else ""
    except (OSError, subprocess.SubprocessError):
        return ""

def vorgaenge():
    """Bereich und Klasse je Nummer aus LISTE-VORGAENGE.md (124, 126, 136); Spalten über den Kopf (275.2: Liste mit Feldern)."""
    pfad = os.path.join(ZUG, "..", "LISTE-VORGAENGE.md")
    tafel = {}; kopf = None
    for z in (open(pfad, encoding="utf-8").read().splitlines() if os.path.exists(pfad) else []):
        if not z.startswith("|"): kopf = None; continue
        t = [x.strip() for x in z.split("|")][1:-1]
        if kopf is None:
            kopf = t if "Nr." in t and "Bereich" in t and "Kl." in t else []; continue
        if not kopf or set("".join(t)) <= set("-: ") or len(t) < len(kopf): continue
        tafel[t[kopf.index("Nr.")]] = (t[kopf.index("Bereich")], t[kopf.index("Kl.")])
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
- Anzusehen (nur mit Build, Datei `ansehen/t<build>-<stichwort>.md`): Aufbau und Regeln nur in `LISTE-CHECK-BUILD-TEST.md` (657 D).
- Zeile 1 `# <Nr.> · <Frage>`, Zeile 2 `<Absender> · <TT.MM.>, <HH:MM> · <Bereich> · …` (Bereich wie „B Abläufe“, 136); Vorrang = Klasse der Nummer in `LISTE-VORGAENGE.md`; eine Zeile `Kurz: …` ersetzt in der Übersicht die Frage. Dann in dieser Folge (364): **Frage**, **Votum** (was der Chef tun oder sagen soll), **Berührt** (Vorgänge); darunter kurz **Begründung**, **Sachverhalt** (belegt, mit Quelle), **Auswertung** (mit dem stärksten Gegenargument), **Folgerungen** (was danach geschieht, wer); zuletzt `Antwort: …`. Lange Teile in `<details>`. Vorlage zum Kopieren: [MUSTER.md](MUSTER.md) (799); `probelauf.py` hält einen Commit oder Push an, der eine unvollständige Datei in `entscheiden/` oder `billigen/` nach `main` bringt.
- Zu billigen (Vorentscheid, 194.1): `billigen/<nr>-<stichwort>.md`, Aufbau wie bei „entscheiden“, Votum = Entschieden, plus: Umgesetzt (Commit), Rückbau, Kosten; in der Auswertung bei Balance und Spielgefühl die verworfene Möglichkeit. Hält keine Arbeit an; Antwort „gebilligt“ oder „zurück“, Sokrates löscht die Datei und setzt „gebilligt TT.MM.“ oder „zurück TT.MM.“ in die Archivzeile.
- Bilder in `bilder/`: JPG oder WebP, höchstens 800 px breit und 60 KB, höchstens 3 je Punkt. Größere Bilder und Hörproben nur über Telegram (`meldung.sh --datei`), in der Datei vermerkt: „Großbild: Telegram TT.MM. HH:MM“. Ablage im Zweig `bilder` als `bilder:<pfad>` (z. B. `[Film](bilder:pruefung/x.mp4)`); die Übersicht macht daraus Links, Filme spielen im Browser (381.1).
- **Überarbeiten** (275, Chef 27.10., 15:23: „sonst schaue ich es mir am Schluss zweimal an“): wer eine Vorlage überarbeitet, löscht die Datei sofort und legt sie neu an, wenn die neue Fassung fertig ist; nie „folgt“, „kommt nach“ in einer Vorlage (die Übersicht meldet es unter „Lücken“).
- **Beantwortet oder zurück beim Team** (383.3, Chef 27.10., 19:55: „Sachen, die nicht mehr zur Vorlage sind, dann weg … Das ist kein Arbeiten so.“): wer eine Antwort des Chefs zu einer Vorlage einträgt (Vorgangsarchiv oder Vorrat), löscht die Datei im selben Commit, auch die eines anderen, und trägt jeden Auftrag, der aus der Antwort folgt, im selben Commit dem Betroffenen ein (783 W8, Chef 09.11., 20:07: „das darf nicht untergehen“); anlegen darf jeder nur seine, Sokrates auch für andere; bleibt ein Teil offen, legt der Besitzer sie neu an, sobald sie vorlegbar ist. Gilt die Antwort einer anderen Frage derselben Nummer, setzt er die Zeit in Zeile 1 oder 2 neu. Die Commit-Prüfung hält einen Archiveintrag an, dessen Vorlage stehen bleibt; Übersehenes meldet die Übersicht unter „Lücken“.
- Zu tun (275): `tun/<nr>-<stichwort>.md`, Zeile 1 `# <Nr.> · <was der Chef tun soll>`, Zeile 2 `<Absender> · <TT.MM.>, <HH:MM> · <Bereich>`, dann der Satz zum Kopieren als Codeblock oder der Weg in Schritten; erledigt heißt Datei löschen (wer sie angelegt hat). Ein „wartet auf Chef“ ohne Datei hier meldet `startbar.py` als Leiche.
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
    m = re.search(SEIT, meta)
    if not m or not WER.match(wer):  # 465 (Chef 02.11., 14:39, 474a): Wer und Zeit in der Titelzeile statt in Zeile 2
        teile = [t.strip() for t in was.split(" · ")]
        w = next((t for t in teile if WER.match(t)), "")
        z = next((re.search(SEIT, t) for t in teile if re.search(SEIT, t)), None)
        if w or z:
            was = " · ".join(t for t in teile if t != w and not (z and z.group(0) in t)) or was
            wer, m = (w or wer), (m or z)
    if not WER.match(wer):
        wer = ""
    seit = seit_text(m, os.path.join(ZUG, ordner, name)) if m else anlage_zeit(os.path.join(ZUG, ordner, name))
    kurz = next((z[5:].strip() for z in zeilen if z.startswith("Kurz:")), None)
    if kurz: was = kurz
    else:
        e = re.search(r"\*\*Empfehlung:?\s*([^*]{1,40}?)\.?\*\*", text)
        if e and e.group(1).strip(): was += f" (Empfehlung: {e.group(1).strip()})"
    sort = (m.group(2) + m.group(1) + (m.group(3) or "")) if m else "0000"
    bereich, klasse = nachschlagen(nr)
    bereich = next((t.strip() for t in meta.split(" · ")[1:] if BEREICH.match(t.strip())), bereich)
    tb = [x.strip() for x in was.split(" · ")]  # D77.1: Bereich in der Titelzeile („623 · … · C Kampf“) zählt als Bereich, nicht als „Was“
    if len(tb) > 1 and any(BEREICH.match(x) for x in tb[1:]):
        bereich = next(x for x in tb[1:] if BEREICH.match(x)); was = " · ".join(x for x in tb if not BEREICH.match(x))
    vorrang = KLASSE.get(klasse, klasse if klasse not in ("", "–") else "–")
    return (vorrang == "Muss", sort), f"| [{nr}]({ordner}/{name}) | {'**Muss**' if vorrang == 'Muss' else vorrang} | {bereich or '–'} | {seit} | {was.replace('|', '/')} | {wer} |"

def tafel(ordner, titel, kopf=None):
    pfad = os.path.join(ZUG, ordner)
    namen = sorted(n for n in os.listdir(pfad) if n.endswith(".md")) if os.path.isdir(pfad) else []
    zeilen = [z for _, z in sorted((eintrag(ordner, n) for n in namen), key=lambda t: t[0], reverse=True)]
    if not zeilen: return f"## {titel}\n\nNichts offen.\n"
    kopf = kopf or "Muss zuerst, dann neueste oben. Vorrang und Bereich aus `LISTE-VORGAENGE.md` (Klasse, 126; Bereich, 124), Bereich in Zeile 2 der Datei geht vor (136)."
    return f"## {titel}\n\n{kopf}\n\n| Nr. | Vorrang | Bereich | Seit | Was | Wer |\n|---|---|---|---|---|---|\n" + "\n".join(zeilen) + "\n"

VERSION = re.compile(r"\b0\.(\d+)\.(\d+)\b")  # altes Spiel 0.1.<Lauf>, Godot 0.348.<Lauf> (367)

def builds(name):
    """Anzusehen (127): eine Zeile je Build, auch aus Sammelseiten („## Build n · 0.1.x · Thema · PR“)."""
    text = open(os.path.join(ZUG, "ansehen", name), encoding="utf-8").read()
    zeilen = [z.strip() for z in text.splitlines() if z.strip()]
    kopf = zeilen[0].lstrip("#").strip() if zeilen else name
    meta = next((z for z in zeilen[1:] if not z.startswith("Kurz:")), "")
    wer = kopf.split(" · ")[0]
    m = re.search(SEIT, meta)
    seit = seit_text(m, os.path.join(ZUG, "ansehen", name))
    tn = re.match(r"t(\d+)-", name)
    # APK-Link in der Bereichszeile (Lauf oder Pull-Request), sonst der Pull-Request aus Zeile 1: die Spalte „Build“ ist dann anklickbar
    ml = re.search(r"\]\((https://[^)]+)\)", meta)
    pr = re.search(r"PR #(\d+)", kopf + " " + meta)
    apk = ml.group(1) if ml else (f"https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/{pr.group(1)}" if pr else "")
    if not tn:  # Bildvorschau (228, 165): „# <Nr.> · <Thema> · <Team> · <TT.MM.>, <HH:MM>“, kein Build
        teile = kopf.split(" · ")
        team = next((t for t in teile[2:] if re.sub(r" \d+$", "", t) in TEAMS), "")
        d = re.search(SEIT, kopf)
        return [(None, teile[0], "", teile[1] if len(teile) > 1 else kopf, name, team or "–", seit_text(d, os.path.join(ZUG, "ansehen", name)) if d else seit)]  # 367: Wer nie die Nummer
    def zeile(teile, standard):
        v = next((VERSION.search(t) for t in teile if VERSION.search(t)), None)
        build = next((t for t in teile if re.match(r"Build \d+$", t)), f"Build {tn.group(1)}" if tn else "")
        was = next((t for t in teile[1:] if not VERSION.search(t) and not t.startswith("[PR") and not re.match(r"Build \d+$", t)), standard)
        return ((int(v.group(1)), int(v.group(2))) if v else (10**6, 0), v.group(0) if v else "–", f"[{build}]({apk})" if apk and build else build, was.replace("|", "/"))
    abschnitte = [z.lstrip("#").strip().split(" · ") for z in text.splitlines() if re.match(r"## Build \d+ · ", z)]
    if abschnitte:
        return [(*zeile(t, t[0]), name, wer, seit) for t in abschnitte]
    kurz = next((z[5:].strip() for z in zeilen if z.startswith("Kurz:")), kopf)
    return [(*zeile(kopf.split(" · "), kurz), name, wer, seit)]

def tafel_ansehen():
    pfad = os.path.join(ZUG, "ansehen")
    namen = sorted(n for n in os.listdir(pfad) if n.endswith(".md")) if os.path.isdir(pfad) else []
    alle = [b for n in namen for b in builds(n)]
    if not alle: return "## Anzusehen\n\nNichts offen.\n"
    # 367: Bilder (ohne Build) und Builds in getrennten Tafeln, sonst stehen in Version und Build nur Striche
    bilder = [b for b in alle if b[0] is None]
    apks = sorted((b for b in alle if b[0] is not None), key=lambda b: b[0])
    teile = ["## Anzusehen\n"]
    if bilder:
        teile.append("**Bilder** (ansehen und im Gespräch „ja“ oder was anders sein soll):\n\n| Nr. | Was | Wer | Seit |\n|---|---|---|---|\n"
                     + "\n".join(f"| [{nr}](ansehen/{n}) | {w} | {wer} | {seit} |" for _, nr, _, w, n, wer, seit in bilder) + "\n")
    if apks:
        teile.append("**Builds** (installieren und testen; Folge = Version aufsteigend, Android installiert nur höhere Nummern über niedrigere):\n\n| Folge | Version | Build | Was | Wer | Seit |\n|---|---|---|---|---|---|\n"
                     + "\n".join(f"| {i} | [{v}](ansehen/{n}) | {b or '–'} | {w} | {wer} | {seit} |" for i, (_, v, b, w, n, wer, seit) in enumerate(apks, 1)) + "\n")
    return "\n".join(teile)

DOCS = os.path.join(ZUG, "..")
TEAMS = ("Tom", "Jerry", "Spike", "Tuffy", "Homer", "Perikles", "Sokrates", "Diogenes", "Ford")

def formfehler():
    """Testdateien in ansehen/ mit t<Build>-Namen: Team in Zeile 1, Bereichszeile („E Kampf · Team · TT.MM.“) als Zeile 2, Tabelle mit Spalten # | Nr. | Wo und wie | Passt | Falsch (1033; alte Listen „Richtig“)."""
    pfad = os.path.join(ZUG, "ansehen")
    fehler = []
    for o in ("entscheiden", "ansehen", "billigen", "tun"):  # D77.2: ohne Absender bleibt „Wer“ leer, jetzt gemeldet
        d = os.path.join(ZUG, o)
        for n in sorted(os.listdir(d)) if os.path.isdir(d) else []:
            if not n.endswith(".md") or re.match(r"t\d+-", n): continue
            try:
                if eintrag(o, n)[1].split("|")[-2].strip() == "": fehler.append(f"{o}/{n}: kein Absender (Zeile 1 „· <Rolle> ·“ oder Zeile 2)")
            except Exception: pass
    try:  # 799: Aufbau 364 (Muster MUSTER.md) für entscheiden/ und billigen/, auch Altbestand
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import vorlage_pruefen as _vp
        for o in ("entscheiden", "billigen"):
            d = os.path.join(ZUG, o)
            for n in sorted(os.listdir(d)) if os.path.isdir(d) else []:
                if n.endswith(".md") and (f := _vp.luecken(open(os.path.join(d, n), encoding="utf-8").read(), o)):
                    fehler.append(f"{o}/{n}: fehlt {', '.join(f)} (364, [Muster](MUSTER.md))")
    except Exception: pass
    for n in sorted(os.listdir(pfad)) if os.path.isdir(pfad) else []:
        if not re.match(r"t\d+-.*\.md$", n): continue
        text = open(os.path.join(pfad, n), encoding="utf-8").read()
        z = [x.strip() for x in text.splitlines() if x.strip()]
        kopf, meta = (z + ["", ""])[:2]
        if any(re.sub(r" \d+$", "", t.strip()) not in TEAMS for t in re.split(r" und | \+ |/|, ", kopf.lstrip("# ").split(" · ")[0])): fehler.append(f"{n}: Zeile 1 beginnt nicht mit dem Team")
        if not re.match(r"[A-Z] \w+ · ", meta): fehler.append(f"{n}: Zeile 2 ist keine Bereichszeile")
        if not re.search(r"^\|\s*#\s*\|(\s*Team\s*\|)?\s*Nr\.\s*\|\s*Wo und wie\s*\|\s*(?:Passt|Richtig)\s*\|\s*Falsch\s*\|", text, re.M): fehler.append(f"{n}: Tabelle `# | Nr. | Wo und wie | Passt | Falsch` fehlt")
        else:  # 317: gemeinsamer Build bündelt mindestens 3 Vorgänge, keine Obergrenze (Chef 07.11., 20:5x), weniger nur auf „jetzt“ des Chefs
            zeilen = [[c.strip() for c in x.strip("|").split("|")] for x in z if x.startswith("|") and not re.match(r"\|[\s|:-]*$", x)]
            sp = zeilen[0].index("Nr.") if zeilen and "Nr." in zeilen[0] else 1
            nrn = {r[sp] for r in zeilen[1:] if len(r) > sp and r[sp]}
            if len(nrn) < 3 and "jetzt" not in text: fehler.append(f"{n}: nur {len(nrn)} Vorgänge; ein Build bündelt mindestens 3, weniger nur auf „jetzt“ des Chefs (317)")
        kopfzeilen = [kopf] + [x for x in z if re.match(r"## Build \d+ · ", x)]
        if not any(VERSION.search(x) for x in kopfzeilen): fehler.append(f"{n}: Version 0.1.<Laufnummer> (Godot 0.348.<Laufnummer>) fehlt in Zeile 1 (trägt die Action nach, sobald der Lauf zum PR in Zeile 1 begonnen hat, 298; ohne PR selbst nachtragen; ohne Version stimmt die Folge nicht, 286)")
    return fehler
NR = r"[A-Z]?\d+[a-z]*(?:\.\d+[a-z]*)?"

def ohne_link():
    """450 (Chef 01.11., 10:55): jedes Blatt in ansehen/ (außer Builds t<n>-) zeigt ein Bild aus bilder/ oder verlinkt Bild bzw. Film im Zweig bilder."""
    pfad = os.path.join(ZUG, "ansehen"); raus = []
    link = re.compile(r"\]\((?:\.\./bilder/|bilder:|https://github\.com/tramour-cmyk/androidapp_rpg_bornim/blob/bilder/|https://cdn\.jsdelivr\.net/gh/tramour-cmyk/androidapp_rpg_bornim@bilder/)")
    for n in sorted(os.listdir(pfad)) if os.path.isdir(pfad) else []:
        if n.endswith(".md") and not re.match(r"t\d+-", n) and not link.search(open(os.path.join(pfad, n), encoding="utf-8").read()):
            raus.append("ansehen/" + n)
    return raus

def luecken():
    """D21.3: Zeilen der Vorgangsliste, die auf den Chef warten oder „Chefsache <Nr>“ nennen, ohne Datei hier (275.2)."""
    texte = []
    for ordner in ("entscheiden", "ansehen", "billigen", "tun"):
        pfad = os.path.join(ZUG, ordner)
        for n in (sorted(os.listdir(pfad)) if os.path.isdir(pfad) else []):
            if n.endswith(".md"): texte.append(n + "\n" + open(os.path.join(pfad, n), encoding="utf-8").read())
    alles = "\n".join(texte)
    def gestellt(nr):
        return re.search(r"(?<![\w.])" + re.escape(nr) + r"(?![\w])", alles) or re.search(r"(?<![\w])" + re.escape(nr.replace(".", "")) + r"-", alles)
    nicht, ohne = [], []
    try:  # 275.2: Zeilen der einen Liste mit Stand „Chef“ oder „wartet auf Chef[ <Datei>]“
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import startbar as _sb
        _sb.DOCS = DOCS; _sb.neu_laden()
        for d in _sb.zeilen_liste():
            if d["wort"] == "erledigt" or not re.fullmatch(NR, d["nr"]): continue
            chef = [t for t in d["warte"] if _sb.art(t) == "chef"]  # „Chef“ mit Datei, die weg ist, löst Automatik A (kein Lückenfall)
            if d["wort"] == "Chef" and not chef and not gestellt(d["nr"]) and (d["nr"], d["besitzer"]) not in nicht: nicht.append((d["nr"], d["besitzer"]))
            for c in re.findall(r"Chefsache (" + NR + r")\b", d["titel"] + " " + d["stand"]):
                if not gestellt(c) and (c, d["besitzer"]) not in ohne: ohne.append((c, d["besitzer"]))
    except Exception:
        pass
    alt = []  # 275 (Chef 15:23): Vorlage in Überarbeitung bleibt nicht stehen
    for ordner in ("entscheiden", "ansehen", "billigen", "tun"):
        pfad = os.path.join(ZUG, ordner)
        for n in (sorted(os.listdir(pfad)) if os.path.isdir(pfad) else []):
            if n.endswith(".md") and re.search(r"\b(folgen|folgt)\s+(hier|später|bald)\b|\b(folgen|folgt|kommen|kommt)\b[^.\n]{0,30}\bnach der (Fehler)?[Pp]rüfung|in Überarbeitung", open(os.path.join(pfad, n), encoding="utf-8").read()):
                alt.append(f"{ordner}/{n}")
    try:  # 383.3: beantwortete Vorlagen, die noch stehen
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import startbar
        beantw = ["%s (Antwort %s, %s)" % (f, nr, w.strftime("%d.%m., %H:%M")) for f, nr, w in startbar.beantwortet()]
    except Exception:
        beantw = []
    form = formfehler()
    ohne_bild = ohne_link()
    if not nicht and not ohne and not form and not alt and not beantw and not ohne_bild: return ""
    teile = ["## Lücken\n\nVom Werkzeug gefunden (D21.3): steht in der Vorgangsliste, hat hier keine Datei.\n"]
    if form: teile.append("Format (Muster: „So geht's“ unten): " + "; ".join(form) + "\n")
    if nicht: teile.append("Nicht gestellt: " + ", ".join(f"{nr} ({wer})" for nr, wer in nicht) + "\n")
    if beantw: teile.append("Beantwortet, Datei noch da (383.3: der Absender löscht sofort): " + ", ".join(beantw) + "\n")
    if alt: teile.append("In Überarbeitung, aus der Chefsache nehmen, bis die neue Fassung fertig ist: " + ", ".join(alt) + "\n")
    if ohne_bild: teile.append("Ohne Bild oder Film (450: `meldung.sh --bild/--film` trägt den Link selbst ein; sonst `[Film](bilder:<pfad>)` von Hand): " + ", ".join(ohne_bild) + "\n")
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
    """298: Version 0.348.<Laufnummer> des neuesten Godot-Laufs am Zweig des PR (GitHub-API, nur mit GITHUB_TOKEN); 894: vorher Kotlin 0.1.<n>."""
    token, repo = os.environ.get("GITHUB_TOKEN"), os.environ.get("GITHUB_REPOSITORY")
    if not (token and repo): return None
    if pr in _cache: return _cache[pr]
    import json, urllib.request, urllib.parse
    def hole(pfad):
        req = urllib.request.Request(f"https://api.github.com/repos/{repo}/{pfad}", headers={"Authorization": f"Bearer {token}", "Accept": "application/vnd.github+json"})
        with urllib.request.urlopen(req, timeout=20) as r: return json.load(r)
    try:
        zweig = hole(f"pulls/{pr}")["head"]["ref"]
        laeufe = hole(f"actions/workflows/godot.yml/runs?per_page=1&branch={urllib.parse.quote(zweig)}")["workflow_runs"]
        _cache[pr] = f"0.348.{laeufe[0]['run_number']}" if laeufe else None   # wie version/name in godot.yml (Android-Export)
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

BILDER = "https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/bilder/"
FILME = "https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@bilder/"  # GitHub spielt Filme nicht ab, jsDelivr liefert video/mp4 (bis 20 MB)

def bilder_url(pfad):
    return (FILME if re.search(r"\.(mp4|webm|mov)$", pfad, re.I) else BILDER) + pfad

def bilderlinks():
    """381.1 (Chef 27.10., 17:31): „bilder:pfad“ ist auf GitHub kein Link; als Link „](bilder:…)“ oder frei im Text
    (nicht in `…`, ohne *) wird es zur Adresse im Zweig bilder: Bilder auf GitHub, Filme über jsDelivr (spielt im Browser ab)."""
    frei = re.compile(r"(?<![\w/`:])(?<!\]\()bilder:([\w./-]+\.(?:png|jpe?g|gif|webp|mp4|webm|mov))(?![\w`*])", re.I)
    for ordner in ("entscheiden", "ansehen", "billigen", "tun"):
        pfad = os.path.join(ZUG, ordner)
        for n in sorted(os.listdir(pfad)) if os.path.isdir(pfad) else []:
            if not n.endswith(".md"): continue
            datei = os.path.join(pfad, n)
            alt = open(datei, encoding="utf-8").read()
            teile = re.split(r"(`[^`\n]*`)", alt)  # Code-Spannen bleiben, wie sie sind (Muster wie bilder:pruefung/3761-*)
            teile = [x if x.startswith("`") else frei.sub(lambda m: "[%s](%s)" % (m.group(1).split("/")[-1], bilder_url(m.group(1))), re.sub(r"\]\(bilder:([^)\s]+)\)", lambda m: "](%s)" % bilder_url(m.group(1)), x)) for x in teile]
            neu = "".join(teile)
            if neu != alt:
                open(datei, "w", encoding="utf-8").write(neu)
                print(f"zug-index: {n} Links bilder: nachgetragen")

versionen_nachtragen()
bilderlinks()
neu = "\n".join([t for t in [KOPF, tafel("entscheiden", "Zu entscheiden"), tafel("billigen", "Zu billigen", "Schon entschieden und umgesetzt (Vorentscheid, 194.1); hält keine Arbeit an. Antwort „gebilligt“ oder „zurück“ im Gespräch mit Sokrates; „zurück“ legt den Rückbau als Muss in den Vorrat des Besitzers."), tafel_ansehen(), tafel("tun", "Zu tun", "Was nur du tun kannst (Satz in einer Sitzung, Freigabe, Kauf; 275). Erledigt: Datei löschen."), offen_je_rolle(), luecken(), REGELN] if t])
ziel = os.path.join(ZUG, "README.md")
alt = open(ziel, encoding="utf-8").read() if os.path.exists(ziel) else ""
if neu != alt:
    open(ziel, "w", encoding="utf-8").write(neu)
    print("zug-index: README neu")
else:
    print("zug-index: unverändert")
