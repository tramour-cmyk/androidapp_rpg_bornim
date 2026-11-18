#!/usr/bin/env python3
"""1644, 1648: ist eine Zeile der Vorgangsliste ein Fund des Chefs zum Aussehen? Für meldung.sh („behoben/weg/fertig“ nur mit Bild).
Fund des Chefs: Titel beginnt mit „Von Chef“, oder der Titel nennt irgendwo den Chef mit Datum (1658) („Chef 17.11.“, auch
„Von Sokrates (Chef 13.11., …)“, „Rest aus 431h (Chef 17.11., 16:12, …)“, D320.1)."""
import re

BEREICHE = ("E Figuren", "E Welt", "E Oberfläche", "E Kampf", "G Stil")

def vom_chef(titel: str) -> bool:
    # 1658 (D323.1): Chef mit Datum irgendwo im Titel, nicht nur in der ersten Klammer („(Chef 08.11., 21:36, über Sokrates)“, „Urteil Chef 25.10.“)
    return titel.startswith("Von Chef") or bool(re.search(r"\bChef \d\d?\.\d\d?\.", titel))

def ist_fund(spalten) -> bool:
    return len(spalten) > 8 and spalten[8] in BEREICHE and vom_chef(spalten[1])
