#!/usr/bin/env python3
"""Aufbau einer Vorlage nach 364 (799, Chef 09.11., 20:46: „Können wir dafür mal einen sinnvollen Haken machen, dass die
Vorlagen so ausschauen?“). Muster: docs/chefsache/MUSTER.md.

Gilt für docs/chefsache/entscheiden/ und billigen/: Zeile 1 `# <Nr.> · <Frage>?`, dann die Teile Frage, Votum (bei
billigen: Entschieden), Berührt, Begründung, Sachverhalt, Auswertung (mit „Gegenargument“), Folgerungen, `Antwort:`;
bei billigen dazu Umgesetzt, Rückbau, Kosten.

Benutzt von probelauf.py (hält `git commit`/`git push` an, der eine solche Datei unvollständig nach main bringt, und
push_files/create_or_update_file) und zug-index.py (Übersicht „Lücken“ für Altbestand).
Von Hand: `python3 tools/vorlage_pruefen.py <Datei> …` (Exit 1 bei Lücken).
"""
import re
import sys

ORDNER = re.compile(r"(?:^|/)docs/chefsache/(entscheiden|billigen)/[^/]+\.md$")
TEILE = ["Frage", "Votum", "Berührt", "Begründung", "Sachverhalt", "Auswertung", "Folgerungen"]
BILLIGEN = ["Umgesetzt", "Rückbau", "Kosten"]


def _teil(text, name):
    """Teil als fette Marke („**Frage:**“) oder Überschrift („## Frage“)."""
    return re.search(r"^\s*(?:[-*]\s*)?(?:\*\*" + name + r"\b[^*\n]{0,40}\*\*|#{2,4}\s*" + name + r"\b)", text, re.M)


def luecken(text, ordner="entscheiden"):
    """Liste der fehlenden Teile (leer = vollständig)."""
    fehlt = []
    zeilen = [z for z in text.splitlines() if z.strip()]
    kopf = zeilen[0].strip() if zeilen else ""
    if not re.match(r"#\s+[A-Z]?\d[\w.]*\s+·\s+", kopf):
        fehlt.append("Zeile 1 „# <Nr.> · <Frage>?“")
    elif not kopf.rstrip().endswith("?"):
        fehlt.append("Zeile 1 als Frage mit „?“ am Ende")
    for t in TEILE:
        if t == "Votum" and ordner == "billigen" and (_teil(text, "Entschieden") or _teil(text, "Votum")):
            continue
        if not _teil(text, t):
            fehlt.append("Entschieden" if t == "Votum" and ordner == "billigen" else t)
    m = _teil(text, "Auswertung")
    if m and not re.search(r"Gegenargument", text[m.start():], re.I):
        fehlt.append("Gegenargument in der Auswertung")
    if ordner == "billigen":
        fehlt += [t for t in BILLIGEN if not _teil(text, t)]
    if not re.search(r"^\s*(?:\*\*)?Antwort:", text, re.M):
        fehlt.append("„Antwort: …“ am Schluss")
    return fehlt


def ordner_von(pfad):
    m = ORDNER.search(pfad.replace("\\", "/"))
    return m.group(1) if m else None


def meldung(befunde):
    """befunde: [(pfad, [fehlende Teile])] → Text für den Haken."""
    return ("799 (Chef 09.11., 20:46, Aufbau 364, Muster docs/chefsache/MUSTER.md): Vorlage unvollständig – "
            + "; ".join(f"{p}: fehlt {', '.join(f)}" for p, f in befunde)
            + ". Vollständig anlegen (Entwurf außerhalb von entscheiden/ und billigen/), dann committen.")


if __name__ == "__main__":
    schlecht = 0
    for p in sys.argv[1:]:
        f = luecken(open(p, encoding="utf-8").read(), ordner_von(p) or "entscheiden")
        print(f"{p}: " + ("vollständig" if not f else "fehlt " + ", ".join(f)))
        schlecht += bool(f)
    sys.exit(1 if schlecht else 0)
