#!/usr/bin/env python3
"""Logo-Dateien und Geschäftspapiere BornWire TCS erzeugen (251.1).

Zeichen „Leiterbahn“ aus Vorgangsarchiv 251.3 (Quelle `chefsache/bilder/251-logo-zeichen.svg`).
Schrift Inter (SIL Open Font License 1.1, rsms.me/inter), Text als Pfade, damit
das Logo ohne installierte Schrift gleich aussieht.

Braucht: pip install fonttools uharfbuzz cairosvg python-docx; Chromium für PDF.
Aufruf: python3 docs/firma/erzeugen.py
"""
import os
import pathlib
import subprocess

import cairosvg
import uharfbuzz as hb
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

HIER = pathlib.Path(__file__).resolve().parent
LOGO = HIER / "logo"
VORL = HIER / "vorlagen"
SCHRIFT = pathlib.Path("/usr/share/fonts/opentype/inter")

TINTE = "#161a22"
PAPIER = "#f4f1ea"
GOLD = "#f0b429"

# Zeichen im Feld 0..100 (unverändert aus 251.3)
ZEICHEN_PFADE = [
    "M76.5 73.6A36 36 0 1 1 65.0 21.8",
    "M36.6 35.5A20 20 0 1 1 43.0 64.3",
    "M6 62H30L42 50H58L70 38H94",
]


def zeichen(farbe, kern, kern_rand=None):
    pfade = "".join(f'<path d="{d}"/>' for d in ZEICHEN_PFADE)
    rand = (f' stroke="{kern_rand}" stroke-width="4" paint-order="stroke"'
            if kern_rand else "")
    return (f'<g fill="none" stroke="{farbe}" stroke-width="8" stroke-linecap="round" '
            f'stroke-linejoin="round">{pfade}</g>'
            f'<circle cx="50" cy="50" r="9" fill="{kern}"{rand}/>')


_fonts = {}


def text_pfad(text, schnitt, groesse, x, y, sperrung=0.0):
    """Text als SVG-Pfad (harfbuzz für Kerning); gibt (pfad, breite) zurück."""
    if schnitt not in _fonts:
        datei = SCHRIFT / f"Inter-{schnitt}.otf"
        blob = hb.Blob.from_file_path(str(datei))
        _fonts[schnitt] = (TTFont(str(datei)), hb.Font(hb.Face(blob)))
    tt, hbf = _fonts[schnitt]
    upem = tt["head"].unitsPerEm
    buf = hb.Buffer()
    buf.add_str(text)
    buf.guess_segment_properties()
    hb.shape(hbf, buf, {"kern": True, "liga": True})
    gs = tt.getGlyphSet()
    namen = tt.getGlyphOrder()
    s = groesse / upem
    pen = SVGPathPen(gs, lambda v: f"{v:.2f}".rstrip("0").rstrip("."))
    cx = 0.0
    for info, pos in zip(buf.glyph_infos, buf.glyph_positions):
        tp = TransformPen(pen, (s, 0, 0, -s, x + (cx + pos.x_offset) * s, y - pos.y_offset * s))
        gs[namen[info.codepoint]].draw(tp)
        cx += pos.x_advance + sperrung / s
    return pen.getCommands(), cx * s - sperrung


def schriftzug(farbe, mit_tcs=True, tcs_farbe=GOLD):
    """Zeichen links, BornWire, Strich, TCS; Feld 470 x 100 wie 251.3.

    Auf Papier steht TCS in Tinte (Vorgangsarchiv 251.1, C): Gold ist dort zu blass.
    """
    born, b1 = text_pfad("Born", "Bold", 50, 118, 67)
    wire, b2 = text_pfad("Wire", "Regular", 50, 118 + b1, 67)
    teile = [zeichen(farbe, GOLD), f'<path d="{born}" fill="{farbe}"/>',
             f'<path d="{wire}" fill="{farbe}"/>']
    ende = 118 + b1 + b2
    if mit_tcs:
        strich = ende + 18
        tcs, b3 = text_pfad("TCS", "SemiBold", 22, strich + 20, 60, sperrung=7)
        teile += [f'<line x1="{strich:.1f}" y1="34" x2="{strich:.1f}" y2="66" stroke="{GOLD}" stroke-width="2.5"/>',
                  f'<path d="{tcs}" fill="{tcs_farbe}"/>']
        ende = strich + 20 + b3
    return "".join(teile), ende + 6


def schriftzug_hoch(farbe):
    """Zeichen oben, darunter BornWire, darunter TCS; mittig."""
    born, b1 = text_pfad("Born", "Bold", 44, 0, 0)
    wire, b2 = text_pfad("Wire", "Regular", 44, 0, 0)
    tcs, b3 = text_pfad("TCS", "SemiBold", 20, 0, 0, sperrung=9)
    breite = max(b1 + b2, 160) + 40
    mx = breite / 2
    x0 = mx - (b1 + b2) / 2
    born, _ = text_pfad("Born", "Bold", 44, x0, 196)
    wire, _ = text_pfad("Wire", "Regular", 44, x0 + b1, 196)
    tcs, _ = text_pfad("TCS", "SemiBold", 20, mx - b3 / 2, 238, sperrung=9)
    inhalt = (f'<g transform="translate({mx - 70:.1f},10) scale(1.4)">{zeichen(farbe, GOLD)}</g>'
              f'<path d="{born}" fill="{farbe}"/><path d="{wire}" fill="{farbe}"/>'
              f'<line x1="{mx - 40:.1f}" y1="214" x2="{mx + 40:.1f}" y2="214" stroke="{GOLD}" stroke-width="2"/>'
              f'<path d="{tcs}" fill="{GOLD}"/>')
    return inhalt, breite, 252


def svg(inhalt, w, h, grund=None, rund=0):
    hg = ""
    if grund:
        hg = f'<rect width="{w:.0f}" height="{h:.0f}" rx="{rund}" fill="{grund}"/>'
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w:.0f} {h:.0f}" '
            f'width="{w:.0f}" height="{h:.0f}">{hg}{inhalt}</svg>\n')


def schreibe(name, text):
    (LOGO / name).write_text(text)
    return LOGO / name


def png(quelle, ziel, breite):
    cairosvg.svg2png(url=str(quelle), write_to=str(LOGO / ziel), output_width=breite)


def logos():
    LOGO.mkdir(exist_ok=True)
    schreibe("zeichen.svg", svg(zeichen(TINTE, GOLD), 100, 100))
    schreibe("zeichen-dunkel.svg", svg(zeichen(PAPIER, GOLD), 100, 100, TINTE))
    schreibe("zeichen-sw.svg", svg(zeichen("#000", "#000", "#fff"), 100, 100))
    schreibe("zeichen-weiss.svg", svg(zeichen("#fff", "#fff", "#000"), 100, 100))
    app = (f'<g transform="translate(12,12) scale(0.76)">{zeichen(PAPIER, GOLD)}</g>')
    schreibe("app-symbol.svg", svg(app, 100, 100, TINTE, rund=22))
    for endung, farbe, grund in (("", TINTE, None), ("-dunkel", PAPIER, TINTE)):
        inhalt, w = schriftzug(farbe)
        schreibe(f"quer{endung}.svg", svg(inhalt, w, 100, grund))
        inhalt, w = schriftzug(farbe, mit_tcs=False)
        schreibe(f"quer-ohne-tcs{endung}.svg", svg(inhalt, w, 100, grund))
        inhalt, w, h = schriftzug_hoch(farbe)
        schreibe(f"hoch{endung}.svg", svg(inhalt, w, h, grund))
    inhalt, w = schriftzug(TINTE, tcs_farbe=TINTE)
    schreibe("quer-papier.svg", svg(inhalt, w, 100))
    for px in (48, 192, 512):
        png(LOGO / "zeichen.svg", f"zeichen-{px}.png", px)
    png(LOGO / "app-symbol.svg", "app-symbol-512.png", 512)
    png(LOGO / "quer.svg", "quer-1200.png", 1200)
    png(LOGO / "quer-dunkel.svg", "quer-dunkel-1200.png", 1200)
    png(LOGO / "hoch.svg", "hoch-600.png", 600)
    png(LOGO / "quer-papier.svg", "quer-papier-2400.png", 2400)
    # Favicon: Zeichen mit hellem Grund lesbar auf hellen und dunklen Reitern
    from PIL import Image
    png(LOGO / "app-symbol.svg", "_fav.png", 64)
    Image.open(LOGO / "_fav.png").save(LOGO / "favicon.ico", sizes=[(16, 16), (32, 32), (48, 48)])
    os.remove(LOGO / "_fav.png")


# ---------------------------------------------------------------- Vorlagen

KOPF_SVG = None


def kopf():
    inhalt, w = schriftzug(TINTE, tcs_farbe=TINTE)
    return svg(inhalt, w, 100).replace("<svg ", '<svg class="logo" ', 1)


ABSENDER = {
    "name": "BornWire TCS",
    "inhaber": "Inh. «Vorname Nachname»",
    "strasse": "«Straße Hausnummer»",
    "ort": "«PLZ» Potsdam",
    "mail": "«E-Mail»",
    "web": "«Webseite»",
    "tel": "«Telefon»",
    "steuer": "Steuernummer «…»",
    "bank": "«Bank»",
    "iban": "IBAN «DE.. …»",
    "bic": "BIC «…»",
}

STIL = f"""
@page {{ size: A4; margin: 0; }}
* {{ box-sizing: border-box; }}
html, body {{ margin: 0; padding: 0; background: #e9e6df; }}
body {{ font-family: Inter, "Helvetica Neue", Arial, sans-serif; color: {TINTE};
       font-size: 10pt; line-height: 1.45; }}
.seite {{ position: relative; width: 210mm; height: 297mm; background: #fff;
         margin: 0 auto; overflow: hidden; }}
@media print {{ html, body {{ background: #fff; }} }}
@media screen {{ .seite {{ margin: 8mm auto; box-shadow: 0 1mm 4mm rgba(0,0,0,.18); }} }}
.logo {{ position: absolute; top: 14mm; left: 25mm; height: 15mm; width: auto; }}
.goldlinie {{ position: absolute; top: 33mm; left: 25mm; right: 20mm; height: .5mm; background: {GOLD}; }}
.ruecksende {{ position: absolute; top: 45mm; left: 25mm; width: 85mm; font-size: 7pt;
              color: #6b6f78; border-bottom: .2mm solid #b9bcc3; padding-bottom: .6mm; }}
.anschrift {{ position: absolute; top: 50mm; left: 25mm; width: 85mm; height: 40mm; font-size: 10pt; }}
.info {{ position: absolute; top: 50mm; left: 120mm; width: 70mm; font-size: 8.5pt; }}
.info table {{ border-collapse: collapse; }}
.info td {{ padding: 0 3mm .6mm 0; vertical-align: top; white-space: nowrap; }}
.info td:first-child {{ color: #6b6f78; }}
.inhalt {{ position: absolute; top: 103.4mm; left: 25mm; right: 20mm; }}
.betreff {{ font-weight: 700; font-size: 11pt; margin: 0 0 6mm; }}
.inhalt p {{ margin: 0 0 3.5mm; }}
.marke {{ position: absolute; left: 4mm; width: 5mm; height: 0; border-top: .25mm solid #9a9ea6; }}
.fuss {{ position: absolute; bottom: 10mm; left: 25mm; right: 20mm; border-top: .3mm solid {GOLD};
        padding-top: 2.5mm; display: flex; gap: 6mm; font-size: 7pt; line-height: 1.5; color: #4a4f5a; }}
.fuss div {{ flex: 1; }}
.fuss b {{ color: {TINTE}; }}
table.posten {{ width: 100%; border-collapse: collapse; margin: 2mm 0 5mm; font-size: 9.5pt; }}
table.posten th {{ text-align: left; font-weight: 600; border-bottom: .4mm solid {TINTE}; padding: 1.5mm 2mm; }}
table.posten td {{ border-bottom: .2mm solid #d6d8dc; padding: 1.8mm 2mm; vertical-align: top; }}
table.posten .z {{ text-align: right; white-space: nowrap; }}
table.posten tr.summe td {{ border-bottom: none; border-top: .4mm solid {TINTE}; font-weight: 700; }}
.hinweis {{ font-size: 8.5pt; color: #4a4f5a; }}
.feld {{ border-bottom: .25mm solid {TINTE}; height: 9mm; }}
.feldname {{ font-size: 7.5pt; color: #6b6f78; margin-top: 1mm; }}
.zwei {{ display: flex; gap: 12mm; }}
.zwei > div {{ flex: 1; }}
.betrag {{ font-size: 16pt; font-weight: 700; }}
.platz {{ color: #8a5a00; }}
"""


def seite(titel, anschrift, info, inhalt):
    a = ABSENDER
    zeilen = "".join(f"<tr><td>{k}</td><td>{v}</td></tr>" for k, v in info)
    fuss = (f'<div><b>{a["name"]}</b><br>{a["inhaber"]}<br>{a["strasse"]}<br>{a["ort"]}</div>'
            f'<div><b>Kontakt</b><br>{a["tel"]}<br>{a["mail"]}<br>{a["web"]}</div>'
            f'<div><b>Bankverbindung</b><br>{a["bank"]}<br>{a["iban"]}<br>{a["bic"]}</div>'
            f'<div><b>Steuer</b><br>{a["steuer"]}<br>Kleinunternehmer<br>nach § 19 UStG</div>')
    return f"""<!doctype html>
<html lang="de"><head><meta charset="utf-8"><title>{titel} – BornWire TCS</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>{STIL}</style></head><body>
<div class="seite">
{kopf()}<div class="goldlinie"></div>
<div class="marke" style="top:105mm"></div><div class="marke" style="top:148.5mm;width:7mm"></div><div class="marke" style="top:210mm"></div>
<div class="ruecksende">{a["name"]} · {a["strasse"]} · {a["ort"]}</div>
<div class="anschrift">{anschrift}</div>
<div class="info"><table>{zeilen}</table></div>
<div class="inhalt">{inhalt}</div>
<div class="fuss">{fuss}</div>
</div></body></html>
"""


EMPF = "«Firma / Name»<br>«Ansprechpartner»<br>«Straße Hausnummer»<br>«PLZ Ort»"


def vorlagen():
    VORL.mkdir(exist_ok=True)
    seiten = {}
    seiten["briefbogen"] = seite(
        "Briefbogen", EMPF,
        [("Ihr Zeichen", "«…»"), ("Unser Zeichen", "«…»"), ("Datum", "«TT.MM.JJJJ»")],
        '<p class="betreff">«Betreff»</p><p>«Text»</p>')
    seiten["anschreiben"] = seite(
        "Anschreiben", EMPF,
        [("Ihr Zeichen", "«…»"), ("Ihre Nachricht vom", "«…»"), ("Datum", "«TT.MM.JJJJ»")],
        """<p class="betreff">«Betreff, ein Satz»</p>
<p>Guten Tag «Anrede Name»,</p>
<p>«Anlass in einem Satz.»</p>
<p>«Inhalt: was wir anbieten, bitten oder mitteilen. Kurze Absätze, ein Gedanke je Absatz.»</p>
<p>«Nächster Schritt: was wir vom Empfänger brauchen und bis wann.»</p>
<p>Mit freundlichen Grüßen</p>
<p style="margin-top:14mm">«Vorname Nachname»<br>BornWire TCS</p>""")
    seiten["rechnung"] = seite(
        "Rechnung", EMPF,
        [("Rechnungsnummer", "«JJJJ-0001»"), ("Rechnungsdatum", "«TT.MM.JJJJ»"),
         ("Leistungszeitraum", "«TT.MM.–TT.MM.JJJJ»"), ("Kundennummer", "«…»")],
        """<p class="betreff">Rechnung «JJJJ-0001»</p>
<p>Guten Tag «Anrede Name»,<br>für unsere Leistungen berechnen wir:</p>
<table class="posten">
<tr><th style="width:9mm">Pos.</th><th>Leistung</th><th class="z">Menge</th><th class="z">Einzelpreis</th><th class="z">Betrag</th></tr>
<tr><td>1</td><td>«Leistung, eindeutig beschrieben»</td><td class="z">«1 Std.»</td><td class="z">«0,00 €»</td><td class="z">«0,00 €»</td></tr>
<tr><td>2</td><td>«…»</td><td class="z">«…»</td><td class="z">«0,00 €»</td><td class="z">«0,00 €»</td></tr>
<tr class="summe"><td></td><td>Rechnungsbetrag</td><td></td><td></td><td class="z">«0,00 €»</td></tr>
</table>
<p class="hinweis">Gemäß § 19 UStG wird keine Umsatzsteuer berechnet.</p>
<p>Bitte überweisen Sie den Betrag bis zum «TT.MM.JJJJ» unter Angabe der Rechnungsnummer auf das unten genannte Konto.</p>
<p>Vielen Dank für den Auftrag.</p>""")
    seiten["quittung-tester"] = seite(
        "Quittung Tester",
        "«Vorname Nachname des Testers»<br>«Straße Hausnummer»<br>«PLZ Ort»",
        [("Quittung Nr.", "«JJJJ-Q001»"), ("Datum", "«TT.MM.JJJJ»")],
        """<p class="betreff">Quittung über eine Aufwandsentschädigung für Spieltests</p>
<p>Ich bestätige, von BornWire TCS den folgenden Betrag erhalten zu haben:</p>
<p class="betrag">«0,00 €»</p>
<p class="feldname" style="margin-top:-2mm">in Worten: «… Euro»</p>
<table class="posten">
<tr><th>Wofür</th><th class="z">Zeitraum</th><th class="z">Art der Zahlung</th></tr>
<tr><td>Spieltest „Chroniken von Bornim“, «Version / Prüfbogen»</td><td class="z">«TT.MM.–TT.MM.JJJJ»</td><td class="z">«bar / Überweisung»</td></tr>
</table>
<p class="hinweis">Ob und wie der Empfänger die Zahlung versteuert, liegt bei ihm.</p>
<div class="zwei" style="margin-top:16mm">
<div><div class="feld"></div><div class="feldname">Ort, Datum</div></div>
<div><div class="feld"></div><div class="feldname">Unterschrift Empfänger</div></div>
</div>""")
    for name, html in seiten.items():
        (VORL / f"{name}.html").write_text(html)
        subprocess.run(["/opt/pw-browsers/chromium", "--headless", "--no-sandbox", "--disable-gpu",
                        "--no-pdf-header-footer", f"--print-to-pdf={VORL / (name + '.pdf')}",
                        (VORL / f"{name}.html").as_uri()], check=True, capture_output=True)


# ---------------------------------------------------------------- Word (251.1, B)

def word():
    """Dieselben vier Vorlagen als .docx; Schrift Arial, weil Inter selten installiert ist.

    Anschriftfeld und Infoblock wie DIN 5008 Form B, im Textfluss angenähert;
    Falz- und Lochmarken nur in der HTML-Fassung.
    """
    from docx import Document
    from docx.enum.table import WD_TABLE_ALIGNMENT
    from docx.enum.text import WD_ALIGN_PARAGRAPH
    from docx.oxml import OxmlElement
    from docx.oxml.ns import qn
    from docx.shared import Mm, Pt, RGBColor

    tinte = RGBColor.from_string(TINTE[1:])
    grau = RGBColor(0x6B, 0x6F, 0x78)
    a = ABSENDER

    def linie(absatz, wo, farbe, staerke):
        ppr = absatz._p.get_or_add_pPr()
        rand = OxmlElement("w:pBdr")
        el = OxmlElement(f"w:{wo}")
        for k, v in (("val", "single"), ("sz", str(staerke)), ("space", "4"), ("color", farbe[1:])):
            el.set(qn(f"w:{k}"), v)
        rand.append(el)
        ppr.append(rand)

    def ohne_rahmen(tabelle):
        tblpr = tabelle._tbl.tblPr
        r = OxmlElement("w:tblBorders")
        for wo in ("top", "left", "bottom", "right", "insideH", "insideV"):
            el = OxmlElement(f"w:{wo}")
            el.set(qn("w:val"), "nil")
            r.append(el)
        tblpr.append(r)

    def zelle_rand(zelle, wo, farbe, staerke):
        tcpr = zelle._tc.get_or_add_tcPr()
        r = OxmlElement("w:tcBorders")
        el = OxmlElement(f"w:{wo}")
        for k, v in (("val", "single"), ("sz", str(staerke)), ("color", farbe[1:])):
            el.set(qn(f"w:{k}"), v)
        r.append(el)
        tcpr.append(r)

    def lauf(absatz, text, groesse=None, fett=False, farbe=None):
        r = absatz.add_run(text)
        if groesse:
            r.font.size = Pt(groesse)
        r.bold = fett
        if farbe is not None:
            r.font.color.rgb = farbe
        return r

    def absatz(ziel, text="", groesse=None, fett=False, farbe=None, nach=3.5, vor=0):
        p = ziel.add_paragraph()
        p.paragraph_format.space_after = Mm(nach)
        p.paragraph_format.space_before = Mm(vor)
        for i, zeile in enumerate(text.split("\n")):
            if i:
                p.add_run().add_break()
            lauf(p, zeile, groesse, fett, farbe)
        return p

    def breiten(tabelle, mm):
        """Feste Spaltenbreiten; Word liest die Zellen, LibreOffice das Raster."""
        tabelle.autofit = False
        for spalte, b in zip(tabelle._tbl.tblGrid.findall(qn("w:gridCol")), mm):
            spalte.set(qn("w:w"), str(int(b * 56.7)))
        for zeile in tabelle.rows:
            for c, b in zip(zeile.cells, mm):
                c.width = Mm(b)

    def posten(doc, kopf_zeilen, zeilen, summe=None, mm=None):
        t = doc.add_table(rows=1, cols=len(kopf_zeilen))
        ohne_rahmen(t)
        for i, (text, rechts) in enumerate(kopf_zeilen):
            c = t.rows[0].cells[i]
            c.paragraphs[0].text = ""
            lauf(c.paragraphs[0], text, 9.5, True)
            if rechts:
                c.paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.RIGHT
            zelle_rand(c, "bottom", TINTE, 8)
        for z in zeilen + ([summe] if summe else []):
            cells = t.add_row().cells
            for i, text in enumerate(z):
                lauf(cells[i].paragraphs[0], text, 9.5, z is summe)
                if kopf_zeilen[i][1]:
                    cells[i].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.RIGHT
                zelle_rand(cells[i], "top" if z is summe else "bottom", TINTE if z is summe else "#d6d8dc",
                           8 if z is summe else 4)
        breiten(t, mm)
        absatz(doc, nach=2)

    def geruest(info, anschrift):
        doc = Document()
        st = doc.styles["Normal"]
        st.font.name = "Arial"
        st.element.rPr.rFonts.set(qn("w:eastAsia"), "Arial")
        st.font.size = Pt(10)
        st.font.color.rgb = tinte
        st.paragraph_format.space_after = Mm(0)
        st.paragraph_format.line_spacing = 1.15
        sec = doc.sections[0]
        sec.page_width, sec.page_height = Mm(210), Mm(297)
        sec.left_margin, sec.right_margin = Mm(25), Mm(20)
        sec.top_margin, sec.bottom_margin = Mm(45), Mm(32)
        sec.header_distance, sec.footer_distance = Mm(14), Mm(10)
        # Kopf: Logo 15 mm hoch, darunter Goldlinie
        kp = sec.header.paragraphs[0]
        kp.add_run().add_picture(str(LOGO / "quer-papier-2400.png"), height=Mm(15))
        linie(kp, "bottom", GOLD, 12)
        # Fuß: vier Spalten unter Goldlinie
        ft = sec.footer.add_table(rows=1, cols=4, width=Mm(165))
        ohne_rahmen(ft)
        spalten = [
            (a["name"], [a["inhaber"], a["strasse"], a["ort"]]),
            ("Kontakt", [a["tel"], a["mail"], a["web"]]),
            ("Bankverbindung", [a["bank"], a["iban"], a["bic"]]),
            ("Steuer", [a["steuer"], "Kleinunternehmer", "nach § 19 UStG"]),
        ]
        for c, (titel, zeilen) in zip(ft.rows[0].cells, spalten):
            zelle_rand(c, "top", GOLD, 6)
            p = c.paragraphs[0]
            lauf(p, titel, 7, True)
            for z in zeilen:
                p.add_run().add_break()
                lauf(p, z, 7, farbe=RGBColor(0x4A, 0x4F, 0x5A))
        sec.footer.paragraphs[0].paragraph_format.space_after = Mm(0)
        # Rücksendezeile, Anschrift links, Infoblock rechts (oberer Rand 45 mm)
        t = doc.add_table(rows=1, cols=2)
        ohne_rahmen(t)
        t.alignment = WD_TABLE_ALIGNMENT.LEFT
        links, rechts = t.rows[0].cells
        links.width, rechts.width = Mm(95), Mm(70)
        p = links.paragraphs[0]
        lauf(p, f'{a["name"]} · {a["strasse"]} · {a["ort"]}', 7, farbe=grau)
        linie(p, "bottom", "#b9bcc3", 2)
        p.paragraph_format.space_after = Mm(2)
        absatz(links, anschrift, nach=0)
        rechts.paragraphs[0].paragraph_format.space_before = Mm(5)
        it = rechts.add_table(rows=0, cols=2)
        ohne_rahmen(it)
        for k, v in info:
            z = it.add_row().cells
            lauf(z[0].paragraphs[0], k, 8.5, farbe=grau)
            lauf(z[1].paragraphs[0], v, 8.5)
        breiten(it, (31, 37))
        t.rows[0].height = Mm(46)
        absatz(doc, nach=8)
        return doc

    empf = "«Firma / Name»\n«Ansprechpartner»\n«Straße Hausnummer»\n«PLZ Ort»"
    docs = {}

    d = geruest([("Ihr Zeichen", "«…»"), ("Unser Zeichen", "«…»"), ("Datum", "«TT.MM.JJJJ»")], empf)
    absatz(d, "«Betreff»", 11, True, nach=6)
    absatz(d, "«Text»")
    docs["briefbogen"] = d

    d = geruest([("Ihr Zeichen", "«…»"), ("Ihre Nachricht vom", "«…»"), ("Datum", "«TT.MM.JJJJ»")], empf)
    absatz(d, "«Betreff, ein Satz»", 11, True, nach=6)
    for z in ("Guten Tag «Anrede Name»,", "«Anlass in einem Satz.»",
              "«Inhalt: was wir anbieten, bitten oder mitteilen. Kurze Absätze, ein Gedanke je Absatz.»",
              "«Nächster Schritt: was wir vom Empfänger brauchen und bis wann.»", "Mit freundlichen Grüßen"):
        absatz(d, z)
    absatz(d, "«Vorname Nachname»\nBornWire TCS", vor=10)
    docs["anschreiben"] = d

    d = geruest([("Rechnungsnummer", "«JJJJ-0001»"), ("Rechnungsdatum", "«TT.MM.JJJJ»"),
                 ("Leistungszeitraum", "«TT.MM.–TT.MM.JJJJ»"), ("Kundennummer", "«…»")], empf)
    absatz(d, "Rechnung «JJJJ-0001»", 11, True, nach=6)
    absatz(d, "Guten Tag «Anrede Name»,\nfür unsere Leistungen berechnen wir:")
    posten(d, [("Pos.", False), ("Leistung", False), ("Menge", True), ("Einzelpreis", True), ("Betrag", True)],
           [["1", "«Leistung, eindeutig beschrieben»", "«1 Std.»", "«0,00 €»", "«0,00 €»"],
            ["2", "«…»", "«…»", "«0,00 €»", "«0,00 €»"]],
           ["", "Rechnungsbetrag", "", "", "«0,00 €»"], mm=(12, 85, 20, 24, 24))
    absatz(d, "Gemäß § 19 UStG wird keine Umsatzsteuer berechnet.", 8.5, farbe=RGBColor(0x4A, 0x4F, 0x5A))
    absatz(d, "Bitte überweisen Sie den Betrag bis zum «TT.MM.JJJJ» unter Angabe der Rechnungsnummer "
              "auf das unten genannte Konto.")
    absatz(d, "Vielen Dank für den Auftrag.")
    docs["rechnung"] = d

    d = geruest([("Quittung Nr.", "«JJJJ-Q001»"), ("Datum", "«TT.MM.JJJJ»")],
                "«Vorname Nachname des Testers»\n«Straße Hausnummer»\n«PLZ Ort»")
    absatz(d, "Quittung über eine Aufwandsentschädigung für Spieltests", 11, True, nach=6)
    absatz(d, "Ich bestätige, von BornWire TCS den folgenden Betrag erhalten zu haben:")
    absatz(d, "«0,00 €»", 16, True, nach=0)
    absatz(d, "in Worten: «… Euro»", 7.5, farbe=grau)
    posten(d, [("Wofür", False), ("Zeitraum", True), ("Art der Zahlung", True)],
           [["Spieltest „Chroniken von Bornim“, «Version / Prüfbogen»", "«TT.MM.–TT.MM.JJJJ»",
             "«bar / Überweisung»"]], mm=(85, 42, 38))
    absatz(d, "Ob und wie der Empfänger die Zahlung versteuert, liegt bei ihm.", 8.5,
           farbe=RGBColor(0x4A, 0x4F, 0x5A), nach=16)
    u = d.add_table(rows=2, cols=3)
    ohne_rahmen(u)
    for i, text in ((0, "Ort, Datum"), (2, "Unterschrift Empfänger")):
        zelle_rand(u.rows[0].cells[i], "bottom", TINTE, 6)
        u.rows[0].cells[i].paragraphs[0].paragraph_format.space_before = Mm(6)
        lauf(u.rows[1].cells[i].paragraphs[0], text, 7.5, farbe=grau)
    u.rows[0].cells[1].width = Mm(12)
    docs["quittung-tester"] = d

    for name, doc in docs.items():
        doc.core_properties.author = "BornWire TCS"
        doc.core_properties.title = name
        doc.save(VORL / f"{name}.docx")


if __name__ == "__main__":
    logos()
    vorlagen()
    word()
    print("fertig:", LOGO, VORL)
