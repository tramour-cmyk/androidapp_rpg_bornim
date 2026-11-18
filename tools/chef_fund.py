#!/usr/bin/env python3
"""1644, 1648: ist eine Zeile der Vorgangsliste ein Fund des Chefs zum Aussehen? Für meldung.sh („behoben/weg/fertig“ nur mit Bild).
Fund des Chefs: Titel beginnt mit „Von Chef“, oder die erste Klammer des Titels nennt den Chef mit Datum („Chef 17.11.“, auch
„Von Sokrates (Chef 13.11., …)“, „Rest aus 431h (Chef 17.11., 16:12, …)“, D320.1)."""
import re

BEREICHE = ("E Figuren", "E Welt", "E Oberfläche", "E Kampf", "G Stil")

def vom_chef(titel: str) -> bool:
    if titel.startswith("Von Chef"): return True
    k = re.match(r"[^(]*\(([^()]*)", titel)
    return bool(k and re.search(r"\bChef \d\d?\.\d\d?\.", k.group(1)))

def ist_fund(spalten) -> bool:
    return len(spalten) > 8 and spalten[8] in BEREICHE and vom_chef(spalten[1])
