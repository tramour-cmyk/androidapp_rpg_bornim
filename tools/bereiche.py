#!/usr/bin/env python3
"""Feste Liste der Bereiche (651, Chef 08.11., 13:29: „Bereiche, Teilbereiche, Kosten, pro Tag, Kosten je Woche“; 124).

Ein Bereich ist „<Hauptthema-Buchstabe> <Teilbereich>“, z. B. „E Kampf“. Nur diese gelten für neue und offene Vorgänge
(`vorgang.py neu`, `setze bereich=`, `pruefen`). Alte Schreibweisen (45 verschiedene bis 08.11.) ordnet `einordnen()` zu,
damit die Kostenauswertung auch das Archiv lesen kann.

Aufruf: python3 tools/bereiche.py            zeigt die Liste
        python3 tools/bereiche.py "C Texte"  zeigt die Zuordnung
"""
import re
import sys

BEREICHE = {
    "E": ("Entwicklung", ["Welt", "Figuren", "Kampf", "Klang", "Oberfläche", "Technik"]),
    "G": ("Gestaltung", ["Story", "Stil", "Balance"]),
    "Q": ("Qualität", ["QS", "QM"]),
    "B": ("Betrieb", ["Steuerung", "Abläufe", "Werkzeuge"]),
    "M": ("Markt", ["Markt", "Veröffentlichung"]),
}
ERKLAERUNG = {
    "E Welt": "Orte, Dorf, Wald, Höhle, Innenräume, Karten", "E Figuren": "Leute, Held, Monster, Tiere, Bewegungen",
    "E Kampf": "MARS, Regeln, Kampfort", "E Klang": "Musik, Geräusche", "E Oberfläche": "Menüs, Fenster, Bedienung, Schrift",
    "E Technik": "Godot, Umzug, Build, Speichern, Werkzeuge der Teams", "G Story": "Handlung, Spieltexte, Englisch",
    "G Stil": "Aussehen, Licht, Farbe, Design", "G Balance": "Werte, Geld, Handel, Spielgefühl",
    "Q QS": "Builds, Prüflisten, Rückläufer, Tests", "Q QM": "Prüfläufe, Kennzahlen, Diogenes",
    "B Steuerung": "Ford, Starts, Guthaben, Kosten", "B Abläufe": "Regeln, Notizen, Vorrang, Chefsache",
    "B Werkzeuge": "Haken und Skripte unter tools/", "M Markt": "Strategie, Geschäftsmodell",
    "M Veröffentlichung": "Release, Store",
}
# alte Teilbereich-Wörter → gültiger Bereich (Buchstabe gilt vor dem Wort, wenn das Wort dort vorkommt)
WORT = {
    "Welt": "E Welt", "Dorf": "E Welt", "Wald": "E Welt", "Höhle": "E Welt", "Innenräume": "E Welt", "Orte": "E Welt",
    "Figuren": "E Figuren", "Leute": "E Figuren", "Monster": "E Figuren",
    "Kampf": "E Kampf", "Regeln": "E Kampf", "Klang": "E Klang",
    "Oberfläche": "E Oberfläche", "Bedienung": "E Oberfläche", "Spiel": "E Oberfläche",
    "Technik": "E Technik", "Umzug": "E Technik", "Entwicklung": "E Technik",
    "Story": "G Story", "Texte": "G Story", "Text": "G Story", "Inhalt": "G Story",
    "Stil": "G Stil", "Aussehen": "G Stil", "Grafik": "G Stil", "Design": "G Stil",
    "Balance": "G Balance", "Geld": "G Balance", "Handel": "G Balance",
    "QS": "Q QS", "Test": "Q QS", "Fehler": "Q QS", "Qualität": "Q QS", "QM": "Q QM",
    "Steuerung": "B Steuerung", "Betrieb": "B Abläufe", "Kosten": "B Steuerung", "Firma": "B Abläufe",
    "Abläufe": "B Abläufe", "Ablauf": "B Abläufe", "Vorrang": "B Abläufe",
    "Werkzeuge": "B Werkzeuge", "Werkzeug": "B Werkzeuge",
    "Markt": "M Markt", "Strategie": "M Markt", "Veröffentlichung": "M Veröffentlichung",
}
# Buchstabe + Wort, wo das Wort allein in einen anderen Bereich führt
PAAR = {("Q", "Ablauf"): "Q QM", ("Q", "Abläufe"): "Q QM", ("Q", "Werkzeug"): "Q QM", ("B", "Technik"): "B Werkzeuge",
        ("A", "Technik"): "B Werkzeuge", ("B", "Umzug"): "E Technik", ("G", "Kampf"): "G Balance", ("G", "Welt"): "G Stil",
        ("G", "Höhle"): "G Stil", ("G", "Bedienung"): "E Oberfläche", ("E", "Story"): "G Story", ("E", "Text"): "G Story",
        ("B", "Strategie"): "M Markt"}


def alle():
    return [f"{b} {t}" for b, (_, teile) in BEREICHE.items() for t in teile]


def gueltig(feld):
    return (feld or "").strip() in alle()


def einordnen(feld):
    """Gültiger Bereich zu einem alten Feld, sonst „? unbekannt“."""
    feld = (feld or "").strip()
    if gueltig(feld):
        return feld
    m = re.match(r"(?:([A-Z])\s+)?(\S+)", feld)
    if not m:
        return "? unbekannt"
    b, w = m.group(1), m.group(2)
    if (b, w) in PAAR:
        return PAAR[(b, w)]
    ziel = WORT.get(w)
    if ziel and b in BEREICHE and w in BEREICHE[b][1]:
        return f"{b} {w}"
    return ziel or "? unbekannt"


def hauptthema(bereich):
    b = bereich[:1]
    return f"{b} {BEREICHE[b][0]}" if b in BEREICHE else "? unbekannt"


def liste_text():
    return "\n".join(f"{b} {name}: " + " · ".join(f"{b} {t} ({ERKLAERUNG.get(f'{b} {t}', '')})" for t in teile)
                     for b, (name, teile) in BEREICHE.items())


if __name__ == "__main__":
    if len(sys.argv) > 1:
        for a in sys.argv[1:]:
            print(f"{a} → {einordnen(a)}")
    else:
        print(liste_text())
