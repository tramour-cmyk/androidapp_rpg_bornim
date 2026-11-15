#!/usr/bin/env python3
"""1233 (Chef 13.11., 21:27: „Wie viele Vorgänge sind da noch offen? … dann kann ich mal eine Priorität vielleicht festlegen“):
Zahlen für den Kopf von PROJEKTPLAN.md, je Meilenstein und je Teilprojekt (= Bereich der Vorgangsliste).

  tools/projektplan.py            Tafel als Markdown (Perikles übernimmt sie montags mit dem Wochenziel per Edit; das Werkzeug schreibt nichts)

Zuordnung ohne Raten: Meilenstein „Marktstart“ = Bereich M Veröffentlichung und M Markt; „nach dem Meilenstein“ (Kl. N oder Stand)
zählt zum Marktstart; alles andere Offene zu „Kapitel 1 fertig“ (Oberste Direktive: Kapitel 1 geht jedem Neuen vor).
Schätzung = offene Vorgänge × Median der Kosten erledigter Vorgänge desselben Bereichs (Archiv, nur Zeilen mit Kosten); grob.
"""
import os, re, statistics, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startbar

MARKT = ("M Veröffentlichung", "M Markt")


def kosten(zelle):
    s = 0.0
    for b in re.findall(r"(\d+(?:,\d+)?)\s*\$", zelle or ""):
        s += float(b.replace(",", "."))
    return s


def archiv_kosten():
    """Bereich → Liste der Kosten erledigter Vorgänge (Archiv: | Nr. | Vorgang | Bereich | Kl. | Kosten | Vorrat | Stand |)."""
    aus = {}
    for z in startbar.lesen("LISTE-VORGAENGE-ARCHIV.md").splitlines():
        t = [x.strip() for x in z.strip().strip("|").split("|")]
        if len(t) < 7 or not re.match(r"D?\d", t[0]): continue
        k = kosten(t[4])
        if k > 0: aus.setdefault(t[2], []).append(k)
    return aus


def teilprojekte(offen):
    """Abschnitt „### Teilprojekte“ in PROJEKTPLAN.md: je Zeile „N. **Name** …“ die genannten Nummern (Vorgänge, keine Stufenpunkte
    x.y, keine Daten); offen zählt die Nummer selbst und ihre Unternummern (709 → 709.1)."""
    t = startbar.lesen("PROJEKTPLAN.md")
    m = re.search(r"(?ms)^### Teilprojekte[^\n]*\n(.*?)(?=^#)", t)
    if not m: return []
    aus = []
    for z in m.group(1).splitlines():
        k = re.match(r"\d+\. \*\*([^*]+)\*\*(.*)", z)
        if not k: continue
        rest = k.group(2).split(" · Stand:")[0]  # nur die genannten Vorgänge, nicht der Stand-Text
        rest = re.sub(r"\(Stufe[^)]*\)|\d{1,2}\.\d{1,2}\.(?:,? \d{1,2}:\d\d)?|\b\d\.\d{1,2}\b(?!\d)", " ", rest)
        nrs = re.findall(r"(?<![\w.])(\d{2,4}(?:\.\d+)?[a-z]?)(?![\w.%$])", rest)
        ds = [d for d in offen if any(d["nr"] == n or d["nr"].startswith(n + ".") for n in nrs)]
        weg = [n for n in nrs if not any(d["nr"] == n or d["nr"].startswith(n + ".") for d in offen)]
        aus.append((k.group(1).strip(), ds, weg))
    return aus


def main():
    offen = [d for d in startbar.zeilen_liste() if d["wort"] not in ("erledigt", None) and d["nr"] not in startbar.SONDER]
    med = {b: statistics.median(v) for b, v in archiv_kosten().items() if len(v) >= 5}

    def ms(d):
        if d.get("bereich") in MARKT or d.get("kl") == "N" or d["wort"] == "nach Meilenstein": return "Marktstart"
        return "Kapitel 1 fertig"

    def zeile(name, ds):
        m = sum(1 for d in ds if d["kl"] == "M")
        test = sum(1 for d in ds if d["wort"] in ("gebaut", "zu testen"))
        sb = sum(1 for d in ds if d["wort"] in ("startbar", "in Arbeit"))
        ruht = sum(1 for d in ds if d["wort"] in ("ruht", "Idee", "Dauer"))
        sch = sum(med.get(d.get("bereich"), 0) for d in ds if d["wort"] not in ("gebaut", "zu testen", "ruht", "Idee", "Dauer"))
        return "| %s | %d | %d | %d | %d | %d | %s |" % (name, len(ds), m, sb, test, ruht, ("~%d $" % round(sch, -1)) if sch else "–")

    kopf = "| %s | offen | Muss | startbar oder in Arbeit | gebaut oder zu testen | ruht | Schätzung |\n|---|---|---|---|---|---|---|"
    print("Stand %s (`python3 tools/projektplan.py`)\n" % startbar.JETZT.strftime("%d.%m., %H:%M"))
    print(kopf % "Meilenstein")
    for name in ("Kapitel 1 fertig", "Marktstart"):
        print(zeile(name, [d for d in offen if ms(d) == name]))
    tp = teilprojekte(offen)
    if tp:
        print("\n| Teilprojekt | genannte Vorgänge offen | davon Muss | gebaut oder zu testen | ruht | erledigt oder unbekannt |\n|---|---|---|---|---|---|")
        for name, ds, weg in tp:
            print("| %s | %d | %d | %d | %d | %s |" % (name, len(ds), sum(1 for d in ds if d["kl"] == "M"), sum(1 for d in ds if d["wort"] in ("gebaut", "zu testen")),
                                                   sum(1 for d in ds if d["wort"] in ("ruht", "Idee", "Dauer")), ", ".join(weg) or "–"))
    print("\n" + kopf % "Teilprojekt (Bereich) für Kapitel 1")
    k1 = [d for d in offen if ms(d) == "Kapitel 1 fertig"]
    for b in sorted({d.get("bereich") for d in k1}, key=lambda b: (-sum(1 for d in k1 if d.get("bereich") == b and d["kl"] == "M"), -sum(1 for d in k1 if d.get("bereich") == b))):
        print(zeile(b, [d for d in k1 if d.get("bereich") == b]))


if __name__ == "__main__":
    main()
