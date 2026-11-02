#!/usr/bin/env python3
"""Gegenstandskatalog (458): prueft tools/gegenstaende/gegenstaende.json und erzeugt docs/LISTE-GEGENSTAENDE.md.

    python3 tools/gegenstaende.py            # pruefen und Uebersicht neu schreiben
    python3 tools/gegenstaende.py --pruefen  # nur pruefen (Exit 1 bei Fehlern oder veralteter Uebersicht)

Die Datendatei ist die einzige Quelle: das Spiel liest sie (458.2 kopiert sie im Bau nach godot/daten/),
die Uebersicht wird nie von Hand geschrieben. Wer fuellt: Jerry Stufe, Preis, Zustand, Beute (458.2, aus 444);
Tom Netz, Material, Zeichen, Modell, Laeden (458.3, aus 455.2); Homer Name und Text (458.4).
"""
import json
import sys
from pathlib import Path

WURZEL = Path(__file__).resolve().parent.parent
DATEI = WURZEL / "tools/gegenstaende/gegenstaende.json"
LISTE = WURZEL / "docs/LISTE-GEGENSTAENDE.md"

# Spalten: Name -> (Pflicht, Erklaerung). null heisst: noch nicht festgelegt (zaehlt als offen).
AUFBAU = {
    "id": (True, "feste Kennung, klein mit Unterstrich, nie aendern (Spielstaende)"),
    "name": (True, "{de, en}"),
    "art": (True, "eine aus ARTEN"),
    "platz": (False, "eine aus PLAETZE oder null (nicht anlegbar)"),
    "stufe": (False, "Heldenstufe ab der erhaeltlich (BRS); null = offen"),
    "preis": (False, "Grundpreis in Gold (BRS, vor Ruf); 0 = unverkaeuflich; null = offen"),
    "netz": (False, "Modellnetz (455), z. B. Datei im Kaufrepo"),
    "material": (False, "Material des Netzes (455)"),
    "zeichen": (False, "Zeichnung/Tusche des Netzes (455)"),
    "modell": (False, "Quelle und Lizenz des Modells (LISTE-BESTAND.md)"),
    "bezug": (True, "Liste von {weg, wo?, rezept?, gold?}; weg aus WEGE; gold = Lohn des Herstellers"),
    "zustand": (False, "true = nutzt sich ab (Abnutzung, Reparatur); null = offen"),
    "text": (False, "{de, en}, ein Satz (Homer)"),
    "grundform": (False, "bei Einzelstuecken: id der Grundform"),
    "formen": (False, "Waffen (458.3): Liste {ab, netz}, Form ab Heldenstufe ab, netz = Kennung paket_datei (waffen_staffel.py); "
                      "erste ab 1, aufsteigend, 2-4 Formen (1, wo der Bestand nicht mehr hat: Langbogen); Material und Zeichen je Seltenheit im Block seltenheit"),
    "alt": (False, "Werte der alten Fassung (SRD), gelten nicht; Hilfe beim Uebertragen, faellt mit Stufe 6"),
}
ARTEN = {
    "waffe": "Waffen", "schild": "Schilde", "ruestung": "Rüstung", "schmuck": "Schmuck", "fokus": "Zauberfokus",
    "licht": "Licht", "einzelstueck": "Einzelstücke", "trank": "Tränke", "wurf": "Wurfgeschosse",
    "nahrung": "Nahrung", "rohstoff": "Rohstoffe", "werkzeug": "Werkzeug", "handlung": "Handlungsgegenstände",
}
PLAETZE = {"kopf", "oberkoerper", "arme", "beine", "umhang", "hals", "finger", "haupthand", "nebenhand", "beide_haende"}
WEGE = {
    "laden": "Laden", "beute": "Beute", "herstellen": "Herstellen", "sammeln": "Sammeln",
    "fund": "Fund", "handlung": "Handlung",
}


def lade():
    return json.loads(DATEI.read_text(encoding="utf-8"))["gegenstaende"]


def pruefe(gg):
    fehler, ids = [], set()
    for i, g in enumerate(gg):
        wo = g.get("id", f"Zeile {i}")
        for k in g:
            if k not in AUFBAU:
                fehler.append(f"{wo}: unbekannte Spalte {k}")
        for k, (pflicht, _) in AUFBAU.items():
            if pflicht and not g.get(k) and k != "bezug":
                fehler.append(f"{wo}: {k} fehlt")
        if g.get("id") in ids:
            fehler.append(f"{wo}: doppelt")
        ids.add(g.get("id"))
        if g.get("art") not in ARTEN:
            fehler.append(f"{wo}: Art {g.get('art')} unbekannt")
        if g.get("platz") not in PLAETZE | {None}:
            fehler.append(f"{wo}: Platz {g.get('platz')} unbekannt")
        n = g.get("name") or {}
        if not (n.get("de") and n.get("en")):
            fehler.append(f"{wo}: Name DE/EN unvollständig")
        if not isinstance(g.get("bezug"), list):
            fehler.append(f"{wo}: bezug ist keine Liste")
        for b in g.get("bezug") or []:
            if b.get("weg") not in WEGE:
                fehler.append(f"{wo}: Bezugsweg {b.get('weg')} unbekannt")
            for z in (b.get("rezept") or {}):
                if z not in {x.get("id") for x in gg}:
                    fehler.append(f"{wo}: Zutat {z} nicht im Katalog")
        fo = g.get("formen")
        if fo is not None:
            ab = [f.get("ab") for f in fo]
            if not (1 <= len(fo) <= 4) or ab[0] != 1 or ab != sorted(set(ab)) or not all(f.get("netz") for f in fo):
                fehler.append(f"{wo}: formen: 1-4 Formen, erste ab 1, aufsteigend, je mit netz")
        if g.get("grundform") and g["grundform"] not in {x.get("id") for x in gg}:
            fehler.append(f"{wo}: Grundform {g['grundform']} nicht im Katalog")
    return fehler


def zelle(v):
    return "–" if v in (None, "", []) else str(v).replace("|", "/")


def bezug_text(b, namen=None):
    t = WEGE[b["weg"]]
    if b.get("wo"):
        t += f" {b['wo']}"
    if b.get("rezept"):
        t += " (" + ", ".join(f"{n}× {(namen or {}).get(z, z)}" for z, n in b["rezept"].items()) + (f", {b['gold']} Gold" if b.get("gold") else "") + ")"
    return t


def offen(g):
    return [k for k in ("stufe", "preis", "netz", "modell", "zustand", "text") if g.get(k) is None
            and not (k in ("netz", "modell") and g["art"] in ("trank", "wurf", "nahrung", "rohstoff", "handlung"))
            and not (k == "zustand" and g["art"] not in ("waffe", "schild", "ruestung", "werkzeug", "einzelstueck"))]


def erzeuge(gg):
    z = ["# Gegenstände (erzeugt, nicht von Hand ändern)", "",
         "Aus `tools/gegenstaende/gegenstaende.json` mit `python3 tools/gegenstaende.py` (458). Ändern nur in der "
         "Datendatei, dann das Werkzeug laufen lassen und beides committen. Werte „alt“ stammen aus der alten "
         "Fassung (SRD) und gelten nicht für das Bornimer Rollenspielsystem; „–“ heißt noch offen. Wer füllt: Jerry "
         "Stufe, Preis, Zustand, Beute (458.2); Tom Netz, Modell, Läden (458.3); Homer Namen und Texte (458.4).", ""]
    namen = {g["id"]: g["name"]["de"] for g in gg}
    fertig = sum(1 for g in gg if not offen(g))
    z += [f"**Stand:** {len(gg)} Gegenstände, davon {fertig} vollständig; "
          + ", ".join(f"{ARTEN[a]} {sum(1 for g in gg if g['art'] == a)}" for a in ARTEN if any(g['art'] == a for g in gg))
          + ".", "", "## Nach Art", ""]
    for a, titel in ARTEN.items():
        teil = [g for g in gg if g["art"] == a]
        if not teil:
            continue
        z += [f"### {titel} ({len(teil)})", "",
              "| Kennung | Name | Platz | Stufe | Preis | Modell | Bezug | offen |", "|---|---|---|---|---|---|---|---|"]
        for g in teil:
            alt = g.get("alt") or {}
            stufe = zelle(g.get("stufe")) if g.get("stufe") is not None else f"– (alt {zelle(alt.get('stufe'))})"
            preis = zelle(g.get("preis")) if g.get("preis") is not None else f"– (alt {zelle(alt.get('preis'))})"
            name = g["name"]["de"] + (f" ({g['grundform']})" if g.get("grundform") else "")
            z.append(f"| `{g['id']}` | {name} | {zelle(g.get('platz'))} | {stufe} | {preis} | {zelle(g.get('modell'))} | "
                     f"{zelle('; '.join(bezug_text(b, namen) for b in g['bezug']))} | {zelle(', '.join(offen(g)))} |")
        z.append("")
    z += ["## Nach Bezugsweg", ""]
    for w, titel in WEGE.items():
        orte = {}
        for g in gg:
            for b in g["bezug"]:
                if b["weg"] == w:
                    orte.setdefault(b.get("wo") or "–", []).append(g["name"]["de"])
        if not orte:
            continue
        z += [f"### {titel}", ""]
        for wo, namen in orte.items():
            z.append(f"- **{wo}:** {', '.join(namen)}" if wo != "–" else f"- {', '.join(namen)}")
        z.append("")
    z += ["## Spalten der Datendatei", "", "| Spalte | Pflicht | Bedeutung |", "|---|---|---|"]
    z += [f"| `{k}` | {'ja' if p else 'nein'} | {e} |" for k, (p, e) in AUFBAU.items()]
    z += ["", f"Arten: {', '.join(ARTEN)}. Plätze: {', '.join(sorted(PLAETZE))}. Bezugswege: {', '.join(WEGE)}.", ""]
    return "\n".join(z)


def main():
    gg = lade()
    fehler = pruefe(gg)
    for f in fehler:
        print("Fehler:", f)
    text = erzeuge(gg)
    if "--pruefen" in sys.argv:
        alt = LISTE.read_text(encoding="utf-8") if LISTE.exists() else ""
        if alt != text:
            print("Übersicht veraltet: python3 tools/gegenstaende.py")
            return 1
        return 1 if fehler else 0
    if fehler:
        return 1
    LISTE.write_text(text, encoding="utf-8")
    print(f"{LISTE.relative_to(WURZEL)}: {len(gg)} Gegenstände")
    return 0


if __name__ == "__main__":
    sys.exit(main())
