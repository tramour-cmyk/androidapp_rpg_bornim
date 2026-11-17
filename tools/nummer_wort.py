#!/usr/bin/env python3
"""1414 (Chef 16.11., 12:09, über Sokrates): Vorgangsnummer ohne Wort dazu im Text an den Chef (MUSTER.md 9 „Vorgänge mit
Wort dazu“). Keine neue Regel, nur Warnung zur bestehenden; hält nie an.

Falsch „reif mit 976“, richtig „976 (Rezeptbuch)“, „Rezeptbuch (976)“, „976: Rezeptbuch“, „976 – Rezeptbuch“.
Ausgenommen (Fehlalarme gering halten): Nummer am Zeilenanfang (Kopf „1414: …“, „# 1414 · …“, Tabellenzelle), in einer
Klammer (Beleg hinter Text), in Sprungmarken und Links, in `Code`, in Zitaten „…“, in Dateinamen, Uhrzeiten, Daten,
Jahreszahlen, Mengen („37 Commits“, „60 KB“, „12 %“: Wort oder Zeichen direkt dahinter).

Benutzt von commit-pruefung.py (neue Zeilen in docs/chefsache/entscheiden|billigen|ansehen|tun, ohne Prüflisten t<Build>-…,
deren Nummern Prüfpunkte sind) und meldung.sh.
Von Hand: `python3 tools/nummer_wort.py <Datei> …` oder Text auf stdin; Exit 0 immer.
"""
import re
import sys

NUMMER = re.compile(r"(?<![\w.:/#-])(D?\d{3,4}(?:\.\d+)*[a-z]?)(?![\w%€$])(?!\s?/)")
WEG = re.compile(r"`[^`]*`|\[[^\]]*\]\([^)]*\)|https?://\S+|„[^“]*“|\"[^\"]*\"|[\w./-]+\.(?:md|py|sh|gd|json|yml|tsv|png|mp4|webp|jpg|tscn)\b"
                 r"|\b\d\d?\.\d\d?\.(?:\d{2,4})?|\b\d\d?:\d\d\b|\b[0-9a-f]{7,40}\b")
# erklärt: direkt danach „ (Wort“, „: Wort“, „ – Wort“
ERKLAERT = re.compile(r"\**\s*(?:\(\s*[A-Za-zÄÖÜäöüß„]{3}|[:–—]\s*[A-Za-zÄÖÜäöüß„*]{3}|-\s+[A-Za-zÄÖÜäöüß]{3})")
# Menge: direkt danach ein Wort oder Zeichen („37 Commits“, „60 KB“, „12 %“) – keine Vorgangsnummer
MENGE = re.compile(r"\s?(?:%|€|\$|×|x\b|[A-Za-zÄÖÜäöüß]{2,})")


def _klammer_tiefe(z, i):
    return z.count("(", 0, i) - z.count(")", 0, i)


def befunde(text):
    """Liste (Zeilennummer, Nummer, Ausschnitt) für Nummern ohne Wort dazu."""
    aus = []
    for zn, roh in enumerate(text.splitlines(), 1):
        z = WEG.sub(lambda m: " " * len(m.group(0)), roh)
        anfang = re.match(r"\s*(?:[#>*|-]+\s*)*(?:\*\*)?", z).end()
        for m in NUMMER.finditer(z):
            nr, s, e = m.group(1), m.start(1), m.end(1)
            if s <= anfang: continue                                   # Kopf, Aufzählung, Tabellenzelle
            if re.fullmatch(r"(19|20)\d\d", nr): continue              # Jahreszahl
            if int(re.match(r"D?(\d+)", nr).group(1)) < 200 and not nr.startswith("D"): continue  # Werte wie „Segen 100.“; Vorgänge unter 200 sind alt
            if re.search(r"(?:/|→|\d\s?(?:bis|–|-))\s?$", z[:s]) or re.match(r"\s?(?:/|→|(?:bis|–)\s?\d)", z[e:]):
                continue                                               # Wertereihe „100 / 20“, „88 bis 100“, „100 → 31“
            if _klammer_tiefe(z, s) > 0: continue                      # Beleg in Klammer hinter Text
            if z[s - 1:s] == "|" or z[max(0, s - 2):s] == "| ": continue
            if re.search(r"\b(?:Build|Zeile|Zeilen|Punkt|Punkte|Version|Kapitel|Stufe|Nachricht|Seite)\s$", z[:s]): continue  # „Build 290“ sagt, was es ist
            rest = z[e:]
            if ERKLAERT.match(rest): continue
            if MENGE.match(rest) and not re.match(r"\s?(?:und|oder|bis|an|auf|mit|zu|von|ist|sind|steht|wartet|warten|als|erledigt|gebaut|offen|fertig|läuft|ruht|startbar|gilt|bleibt|hat|wird|kommt|geht|liegt|braucht|fehlt|und)\b", rest): continue
            aus.append((zn, nr, roh.strip()[:90]))
    return aus


def melden(text, wo=""):
    """Warnzeilen für einen Text (leer = nichts zu sagen)."""
    b = befunde(text)
    if not b: return []
    nrn = ", ".join(dict.fromkeys(n for _, n, _ in b))
    return ["%sVorgang %s ohne Wort dazu, etwa „976 (Rezeptbuch)“ (MUSTER.md 9, 1414)" % (wo, nrn)]


if __name__ == "__main__":
    if len(sys.argv) > 1:
        for p in sys.argv[1:]:
            for zn, nr, aus in befunde(open(p, encoding="utf-8").read()):
                print("%s:%d: %s  ← %s" % (p, zn, nr, aus))
    else:
        for zn, nr, aus in befunde(sys.stdin.read()):
            print("%d: %s  ← %s" % (zn, nr, aus))
