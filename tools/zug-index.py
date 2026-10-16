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

neu = "\n".join([KOPF, tafel("entscheiden", "Zu entscheiden"), tafel("ansehen", "Anzusehen"), REGELN])
ziel = os.path.join(ZUG, "README.md")
alt = open(ziel, encoding="utf-8").read() if os.path.exists(ziel) else ""
if neu != alt:
    open(ziel, "w", encoding="utf-8").write(neu)
    print("zug-index: README neu")
else:
    print("zug-index: unverändert")
