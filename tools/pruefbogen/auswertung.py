#!/usr/bin/env python3
"""Auswertung der Prüfbögen (186.2): Tabelle je Frage, Fehler nach Ort und Häufigkeit.

Aufruf: python3 tools/pruefbogen/auswertung.py BOEGEN.csv FEHLER.csv
BOEGEN.csv: eine Zeile je Tester, Spalten wie in boegen-vorlage.csv (Kürzel statt Name).
FEHLER.csv: eine Zeile je Fehler aus Teil D, Spalten wie in fehler-vorlage.csv.
Leere Zelle = nicht beantwortet (zählt nicht, wird als „ohne Antwort“ genannt). Ausgabe: Markdown.
"""
import csv, sys
from collections import Counter, defaultdict
from statistics import mean, median

SKALA = ["A1", "A2", "A3", "A4", "A5", "B1", "B2", "B3", "B4", "B5",
         "M1", "M2", "M3", "M4", "M5", "C1", "C2", "C3", "C4", "C5", "C6", "E1"]
WAHL = {"A7": ["nein", "ja"], "A8": ["nein", "ja"], "A9": ["nein", "ja"], "B6": ["zu kurz", "passend", "zu lang"], "B7": ["nie", "1-2", "3-5", "öfter"],
        "B8": ["Wald", "Höhle", "Boss", "anderer"], "B9": ["nein", "ja"],
        "M6": ["1", "2-3", "mehr"], "M7": ["bisherig", "MARS", "gleich", "weiß nicht"], "C8": ["nein", "ja"],
        "D6": ["immer", "manchmal", "einmalig", "nicht probiert"],
        "E2": ["ja", "vielleicht", "nein"], "E3": ["ja", "vielleicht", "nein"],
        "E4": ["zu leicht", "genau richtig", "zu schwer"],
        "E5": ["zu langsam", "genau richtig", "zu schnell"],
        "E6": ["Ende erreicht", "Fehler", "Langeweile", "keine Zeit", "anderer Grund"],
        "Erfahrung": ["keine", "etwas", "viel"]}
TEXT = ["A6", "B8text", "B9text", "M7text", "M8", "C7", "C8text", "E6ort", "E7", "E8", "E9"]
SCHWERE = ["Absturz", "Spiel hängt", "stört", "Schönheitsfehler"]


def lies(pfad):
    with open(pfad, newline="", encoding="utf-8") as f:
        return [{k: (v or "").strip() for k, v in r.items()} for r in csv.DictReader(f)]


def main(bogen_pfad, fehler_pfad):
    b, fehler = lies(bogen_pfad), lies(fehler_pfad)
    n = len(b)
    print(f"# Auswertung Prüfbögen: {n} Bögen, {len(fehler)} Fehlerzeilen\n")
    print("## Skalenfragen (1 = trifft gar nicht zu, 5 = trifft voll zu)\n")
    print("| Frage | n | Mittel | Median | 1–2 | 5 | ohne Antwort |\n|---|---|---|---|---|---|---|")
    for q in SKALA:
        w = [int(r[q]) for r in b if r.get(q, "").isdigit()]
        if w:
            print(f"| {q} | {len(w)} | {mean(w):.1f} | {median(w):g} | {sum(x <= 2 for x in w)} | {sum(x == 5 for x in w)} | {n - len(w)} |")
        else:
            print(f"| {q} | 0 | – | – | – | – | {n} |")
    print("\n## Wahlfragen (Anzahl je Antwort)\n")
    print("| Frage | Verteilung | andere | ohne Antwort |\n|---|---|---|---|")
    for q, opts in WAHL.items():
        c = Counter(r.get(q, "") for r in b)
        leer = c.pop("", 0)
        verteil = ", ".join(f"{o} {c.pop(o, 0)}" for o in opts)
        print(f"| {q} | {verteil} | {sum(c.values())} | {leer} |")
    if any(r.get("M7") for r in b):
        print("\nM7 nach Erfahrung (Voreinstellung 212): " + "; ".join(
            f"{e} " + "/".join(f"{o} {sum(1 for r in b if r.get('Erfahrung') == e and r.get('M7') == o)}"
                               for o in WAHL["M7"]) for e in WAHL["Erfahrung"]))
    print("\n## Freitexte (wörtlich, nach Frage)\n")
    for q in TEXT:
        zeilen = [(r.get("Kürzel", "?"), r[q]) for r in b if r.get(q)]
        if zeilen:
            print(f"**{q}** ({len(zeilen)})\n")
            for k, t in zeilen:
                print(f"- {k}: {t}")
            print()
    print("## Fehler nach Ort\n")
    ort = defaultdict(list)
    for f in fehler:
        ort[f.get("Ort", "").lower() or "(ohne Ort)"].append(f)
    print("| Ort | Meldungen | Tester | schwerste | davon Absturz/hängt | wiederholbar (immer/manchmal) |\n|---|---|---|---|---|---|")
    rang = {s: i for i, s in enumerate(SCHWERE)}
    for o, fs in sorted(ort.items(), key=lambda x: (-len({f["Tester"] for f in x[1]}), -len(x[1]))):
        testers = {f["Tester"] for f in fs}
        schw = min((f["Schwere"] for f in fs if f["Schwere"] in rang), key=rang.get, default="?")
        hart = sum(f["Schwere"] in SCHWERE[:2] for f in fs)
        wdh = sum(f.get("Wiederholbar") in ("immer", "manchmal") for f in fs)
        print(f"| {o} | {len(fs)} | {len(testers)} | {schw} | {hart} | {wdh} |")
    print("\nFehler ohne Ort oder ohne Schritte sind nicht nachstellbar (Bogen Teil D): "
          f"{sum(not f.get('Ort') or not f.get('Getan') for f in fehler)} von {len(fehler)}.")
    print("\n## Fehler einzeln (nach Schwere)\n")
    print("| Ort | Schwere | Tester | Getan | Passiert | Erwartet |\n|---|---|---|---|---|---|")
    for f in sorted(fehler, key=lambda f: (rang.get(f["Schwere"], 9), f.get("Ort", ""))):
        print(f"| {f.get('Ort','')} | {f['Schwere']} | {f['Tester']} | {f.get('Getan','')} | {f.get('Passiert','')} | {f.get('Erwartet','')} |")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(*sys.argv[1:])
