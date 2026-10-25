#!/usr/bin/env python3
"""Baut die Webseite bornwire.de (252) aus inhalt/*.html in einen Ausgabeordner.

Aufruf: python3 docs/firma/webseite/bauen.py <ausgabe> [--entwurf]

Name, Anschrift und Telefon kommen nie in Git (docs/firma/README.md), sondern beim Hochladen aus den
GitHub-Secrets BORNWIRE_INHABER, BORNWIRE_ANSCHRIFT (Zeilen mit "|" getrennt) und BORNWIRE_TELEFON (darf fehlen).
Ohne sie bricht das Bauen ab; mit --entwurf stehen Platzhalter in «…» da (Vorschau).
"""
import html, os, shutil, sys
from pathlib import Path

HIER = Path(__file__).resolve().parent
EMAIL = "kontakt@bornwire.de"

# Seite: (Datei im Ausgabeordner, Sprache, Titel, Inhalt, Gegenstück in der anderen Sprache)
SEITEN = [
    ("index.html", "de", "BornWire TCS", "start.de.html", "en/index.html"),
    ("en/index.html", "en", "BornWire TCS", "start.en.html", "index.html"),
    ("impressum.html", "de", "Impressum · BornWire TCS", "impressum.html", "en/index.html"),
    ("datenschutz.html", "de", "Datenschutz · BornWire TCS", "datenschutz.de.html", "en/privacy.html"),
    ("en/privacy.html", "en", "Privacy policy · BornWire TCS", "datenschutz.en.html", "datenschutz.html"),
]
FUSS = {"de": ("Impressum", "Datenschutz", "datenschutz.html"), "en": ("Legal notice", "Privacy policy", "en/privacy.html")}

RAHMEN = """<!doctype html>
<html lang="{lang}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{titel}</title>
<link rel="icon" href="{w}bilder/favicon.ico">
<link rel="apple-touch-icon" href="{w}bilder/zeichen-192.png">
<link rel="alternate" hreflang="{anderslang}" href="https://bornwire.de/{anders}">
<link rel="stylesheet" href="{w}stil.css">
</head>
<body>
<header><div class="wrap">
  <a href="{w}{start}"><img class="logo" src="{w}bilder/quer-dunkel.svg" alt="BornWire TCS"></a>
  <nav><span class="lang">{umschalter}</span></nav>
</div></header>
{inhalt}
<footer><div class="wrap">
  <div class="copy"><img src="{w}bilder/quer-dunkel.svg" alt="BornWire TCS"><small>© 2026</small></div>
  <div class="r"><a href="{w}impressum.html">{impressum}</a><a href="{w}{dsdatei}">{datenschutz}</a></div>
</div></footer>
</body>
</html>
"""


def angaben(entwurf):
    werte = {k: os.environ.get("BORNWIRE_" + k, "").strip() for k in ("INHABER", "ANSCHRIFT", "TELEFON")}
    fehlt = [k for k in ("INHABER", "ANSCHRIFT") if not werte[k]]
    if fehlt and not entwurf:
        sys.exit("Secret fehlt: " + ", ".join("BORNWIRE_" + k for k in fehlt))
    inhaber = html.escape(werte["INHABER"] or "«Vorname Nachname»")
    anschrift = "<br>".join(html.escape(z.strip()) for z in (werte["ANSCHRIFT"] or "«Straße Nr.»|«PLZ Ort»").split("|"))
    tel_de = f"<br>Telefon: {html.escape(werte['TELEFON'])}" if werte["TELEFON"] else ""
    tel_en = f"<br>Phone: {html.escape(werte['TELEFON'])}" if werte["TELEFON"] else ""
    return {"{{INHABER}}": inhaber, "{{ANSCHRIFT}}": anschrift, "{{EMAIL}}": EMAIL,
            "{{TELEFON_DE}}": tel_de, "{{TELEFON_EN}}": tel_en}


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    ziel = Path(sys.argv[1])
    ersetzen = angaben("--entwurf" in sys.argv)
    if ziel.exists():
        shutil.rmtree(ziel)
    for ordner in ("bilder", "schrift"):
        shutil.copytree(HIER / ordner, ziel / ordner)
    shutil.copy(HIER / "stil.css", ziel / "stil.css")
    shutil.copy(HIER / "htaccess", ziel / ".htaccess")
    for datei, lang, titel, quelle, anders in SEITEN:
        w = "../" * datei.count("/")
        inhalt = (HIER / "inhalt" / quelle).read_text(encoding="utf-8").replace("{w}", w)
        for alt, neu in ersetzen.items():
            inhalt = inhalt.replace(alt, neu)
        if "{{" in inhalt:
            sys.exit(f"{quelle}: unbekannter Platzhalter")
        impressum, datenschutz, dsdatei = FUSS[lang]
        if lang == "de":
            umschalter = f'DE <a href="{w}{anders}">| EN</a>'
        else:
            umschalter = f'<a href="{w}{anders}">DE |</a> EN'
        seite = RAHMEN.format(lang=lang, titel=titel, w=w, anderslang="en" if lang == "de" else "de",
                              anders=anders.replace("index.html", ""), start="en/index.html" if lang == "en" else "index.html",
                              umschalter=umschalter, inhalt=inhalt.rstrip(), impressum=impressum,
                              datenschutz=datenschutz, dsdatei=dsdatei)
        (ziel / datei).parent.mkdir(parents=True, exist_ok=True)
        (ziel / datei).write_text(seite, encoding="utf-8")
    print(f"gebaut: {ziel} ({len(SEITEN)} Seiten)")


if __name__ == "__main__":
    main()
