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
import os
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


# 1129 A 1 (Chef 13.11., 13:59: „ich nicke 1129 komplett ab“): Torprüfung jeder NEUEN Datei in entscheiden/. Nur diese Gründe
# bleiben beim Chef; sonst entscheidet ein anderer.
GRUENDE = [("Code auf main", r"code\s+auf\s+`?main"), ("Geld", r"\bgeld|\bkauf|\bkosten|\bguthaben"), ("Lizenz", r"lizenz"),
           ("Story", r"\bstory|spieltext|\bplot"), ("Aussehen", r"aussehen|\bbild\b|\bfilm\b"),
           ("neue Richtung im Spielgefühl", r"spielgef[üu]hl"), ("Release", r"release"), ("Rollen und Accounts", r"\brolle|account")]
STATT = ("über die Arbeitsweise entscheidet das Team, über den Vorrang Perikles, über Abläufe Sokrates per Vorentscheid "
         "(1129 A 1; Vorentscheid nach docs/chefsache/README.md)")
# MUSTER.md Checkliste 9: Abkürzungen im Text an den Chef (nur Warnung)
ABKUERZUNGEN = ["NW", "NO", "SW", "SO", "BRS", "K1", "K2", "K3", "K4", "K5", "K6", "K7", "SRD", "NPC", "UI", "ggf.", "bzw.", "evtl.",
                "usw.", "inkl.", "ca.", "z.B.", "u.a."]


def _vorgangsnummern(wurzel):
    """Nummern der Vorgangsliste ohne Punkt → Nummer (MUSTER.md Checkliste 2)."""
    try:
        text = open(os.path.join(wurzel, "docs", "LISTE-VORGAENGE.md"), encoding="utf-8").read()
    except OSError:
        return None
    return {m.group(1).replace(".", ""): m.group(1) for m in re.finditer(r"^\|\s*([A-Za-z]?\d[\w.]*)\s*\|", text, re.M)}


def tor(text, pfad, wurzel="."):
    """Mängel einer NEUEN Vorlage in entscheiden/ (leer = in Ordnung): Zeile „Beim Chef, weil: …“ mit einem Grund aus GRUENDE
    (1129 A 1), Dateiname = Nummer ohne Punkt und Nummer in der Vorgangsliste (Checkliste 2), kein „folgt“ (Checkliste 7)."""
    if ordner_von(pfad) != "entscheiden":
        return []
    fehlt = []
    m = re.search(r"^\s*(?:[-*]\s*)?(?:\*\*)?Beim Chef, weil:(?:\*\*)?\s*(.+)$", text, re.M)
    if not m:
        fehlt.append("Zeile „Beim Chef, weil: …“ (Code auf main, Geld, Lizenz, Story, Aussehen, neue Richtung im Spielgefühl, "
                     "Release, Rollen und Accounts; sonst: " + STATT + ")")
    elif not any(re.search(r, m.group(1), re.I) for _, r in GRUENDE):
        fehlt.append("hinter „Beim Chef, weil:“ ein Grund aus der Liste (" + ", ".join(g for g, _ in GRUENDE) + "); sonst: " + STATT)
    name = os.path.basename(pfad)
    kopf = re.match(r"#\s+([A-Za-z]?\d[\w.]*)\s+·", (text.lstrip().splitlines() or [""])[0])
    stamm = re.match(r"([A-Za-z]?\d[\w]*?)(?:-|\.md$)", name)
    if kopf and stamm and kopf.group(1).replace(".", "") != stamm.group(1):
        fehlt.append(f"Dateiname = Nummer ohne Punkt („{kopf.group(1).replace('.', '')}-….md“ statt „{name}“, Checkliste 2)")
    nummern = _vorgangsnummern(wurzel)
    if kopf and nummern is not None and kopf.group(1) not in nummern.values():
        fehlt.append(f"Nummer {kopf.group(1)} in der Vorgangsliste (erst `vorgang.py neu`, pushen; Checkliste 2)")
    for z in text.splitlines():
        if re.search(r"(?<![Dd]araus )\bfolgt\b(?!\s+(?:aus|daraus))", re.sub(r"`[^`]*`", "", z), re.I):
            fehlt.append("fertiger Text statt „folgt“ (erst fertig anlegen; Checkliste 7)")
            break
    return fehlt


def warnungen(text):
    """Abkürzungen im Text an den Chef (Checkliste 9), ohne Code-Spannen; Liste der gefundenen Wörter."""
    frei = re.sub(r"`[^`]*`|\([^)]*\.(?:md|py|gd|kt)[^)]*\)", "", text)
    return [a for a in ABKUERZUNGEN if re.search(r"(?<![\w.])" + re.escape(a) + r"(?![\w])", frei)]


def ordner_von(pfad):
    m = ORDNER.search(pfad.replace("\\", "/"))
    return m.group(1) if m else None


def meldung(befunde):
    """befunde: [(pfad, [fehlende Teile])] → Text für den Haken."""
    return ("799 (Chef 09.11., 20:46, Aufbau 364, Muster docs/chefsache/MUSTER.md), 1129 A 1 (Torprüfung neuer Vorlagen): "
            "Vorlage unvollständig – " + "; ".join(f"{p}: fehlt {', '.join(f)}" for p, f in befunde)
            + ". Vollständig anlegen (Entwurf außerhalb von entscheiden/ und billigen/), dann committen.")


if __name__ == "__main__":
    schlecht = 0
    for p in sys.argv[1:]:
        f = luecken(open(p, encoding="utf-8").read(), ordner_von(p) or "entscheiden")
        print(f"{p}: " + ("vollständig" if not f else "fehlt " + ", ".join(f)))
        schlecht += bool(f)
    sys.exit(1 if schlecht else 0)
