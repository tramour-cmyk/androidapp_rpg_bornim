#!/usr/bin/env python3
"""Übersicht für „Dein Zug“ (108): schreibt docs/zug/README.md aus den Dateien in entscheiden/ und ansehen/.

Läuft als GitHub Action bei jedem Push nach docs/zug/ (zug-index.yml); keine Sitzung bearbeitet die README von Hand,
darum gibt es dort keine Konflikte (D15.3). Lokal zur Vorschau: python3 tools/zug-index.py (nicht committen).
Je Datei: Zeile 1 „# <Nr.> · <Frage>“, Zeile 2 „<Absender> · <TT.MM.>, …“; optional „Kurz: …“ als Text der Übersicht.
"""
import os, re, sys

ZUG = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "docs", "zug")

KOPF = """# Dein Zug

Was auf den Chef wartet (63, 108). Diese Übersicht schreibt ein Werkzeug (`tools/zug-index.py`) bei jedem Push; nicht von Hand ändern.
"""

REGELN = """## So geht's

- Je Punkt eine Datei: `entscheiden/<nr>-<stichwort>.md` (Nummer ohne Punkt, z. B. `72s1-gefaehrte-kapitel2.md`) oder `ansehen/t<build>-<stichwort>.md`. Erledigt heißt Datei löschen.
- Anzusehen: Zeile 1 `# <Team> · <Version> · <Thema> · <PR>`, Sammelseite je Build `## Build <n> · <Version> · <Thema> · <PR>`; die Übersicht zeigt jeden Build als Zeile, nach Version sortiert (127).
- Zeile 1 `# <Nr.> · <Frage>`, Zeile 2 `<Absender> · <TT.MM.>, <HH:MM> · …`; eine Zeile `Kurz: …` ersetzt in der Übersicht die Frage. Dann Frage, Empfehlung, stärkstes Gegenargument (lange Begründung in `<details>`).
- Bilder in `bilder/`: JPG oder WebP, höchstens 800 px breit und 60 KB, höchstens 3 je Punkt. Größere Bilder und Hörproben nur über Telegram (`meldung.sh --datei`), in der Datei vermerkt: „Großbild: Telegram TT.MM. HH:MM“.
- Telegram-Sprungmarke `[72s.1](dz:72s1)` führt auf die Datei (`tools/meldung.sh`).
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
    return sort, f"| [{nr}]({ordner}/{name}) | {seit} | {was.replace('|', '/')} | {wer} |"

def tafel(ordner, titel):
    pfad = os.path.join(ZUG, ordner)
    namen = sorted(n for n in os.listdir(pfad) if n.endswith(".md")) if os.path.isdir(pfad) else []
    zeilen = [z for _, z in sorted((eintrag(ordner, n) for n in namen), key=lambda t: t[0], reverse=True)]
    if not zeilen: return f"## {titel}\n\nNichts offen.\n"
    return f"## {titel}\n\n| Nr. | Seit | Was | Wer |\n|---|---|---|---|\n" + "\n".join(zeilen) + "\n"

VERSION = re.compile(r"\b0\.1\.(\d+)\b")

def builds(name):
    """Anzusehen (127): eine Zeile je Build, auch aus Sammelseiten („## Build n · 0.1.x · Thema · PR“)."""
    text = open(os.path.join(ZUG, "ansehen", name), encoding="utf-8").read()
    zeilen = [z.strip() for z in text.splitlines() if z.strip()]
    kopf = zeilen[0].lstrip("#").strip() if zeilen else name
    meta = next((z for z in zeilen[1:] if not z.startswith("Kurz:")), "")
    wer = (meta.split(" · ")[0] if " · " in meta else "") or kopf.split(" · ")[0]
    m = re.search(r"\b(\d\d)\.(\d\d)\.", meta)
    seit = m.group(0) if m else ""
    def zeile(teile, standard):
        v = next((VERSION.search(t) for t in teile if VERSION.search(t)), None)
        build = next((t for t in teile if re.match(r"Build \d+$", t)), "")
        was = next((t for t in teile[1:] if not VERSION.search(t) and not t.startswith("[PR") and not re.match(r"Build \d+$", t)), standard)
        return (int(v.group(1)) if v else 10**6, v.group(0) if v else "–", build, was.replace("|", "/"))
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

neu = "\n".join([KOPF, tafel("entscheiden", "Zu entscheiden"), tafel_ansehen(), REGELN])
ziel = os.path.join(ZUG, "README.md")
alt = open(ziel, encoding="utf-8").read() if os.path.exists(ziel) else ""
if neu != alt:
    open(ziel, "w", encoding="utf-8").write(neu)
    print("zug-index: README neu")
else:
    print("zug-index: unverändert")
