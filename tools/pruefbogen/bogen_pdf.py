#!/usr/bin/env python3
"""Prüfbogen als ausfüllbares PDF (250): bauen und auslesen.

Bauen:    python3 tools/pruefbogen/bogen_pdf.py bauen [bogen.md] [bogen.pdf]
Auslesen: python3 tools/pruefbogen/bogen_pdf.py lesen A.pdf B.pdf ... [--boegen boegen.csv] [--fehler fehler.csv]

Quelle ist `bogen.md` (Wortlaut). Feldnamen = Spalten in `boegen-vorlage.csv` (A1 …, M8) und
`fehler-vorlage.csv` (D1ort, D1getan … je Zeile 1–5); Stichwörter zu Skalen als `A1s` usw.
`lesen` schreibt die Felder mehrerer Bögen in die beiden CSV-Dateien, die `auswertung.py` liest.
Braucht reportlab (bauen) und pypdf (lesen).
"""
import csv, os, re, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from auswertung import WAHL, SCHWERE, SKALA  # noqa: E402

HIER = os.path.dirname(os.path.abspath(__file__))
GERAET = "Geräteangaben"
KOPF = {"Name (oder Kürzel)": ["Kürzel"],
        "Version und Build (Menü → System, ganz oben)": ["Build"], "Datum": ["Datum"],
        "Gewählte Klasse und Schwierigkeit": ["Klasse", "Schwierigkeit"]}
KOPFSPALTEN = ["Kürzel", "Gerät", "Build", "Datum", "Stunden", "Minuten", "Erfahrung", "Klasse", "Schwierigkeit"]
FEHLERFELDER = [("ort", "Ort"), ("getan", "Getan"), ("passiert", "Passiert"), ("erwartet", "Erwartet")]


def bereinige(s):
    s = s.replace("\\_", "_").replace("**", "")
    return re.sub(r"\s+", " ", s).strip()


def parse(pfad):
    """Liefert eine Liste von Blöcken: ('h1'|'h2'|'p', text), ('kopf'|'skala'|'fehler'|'etab', zeilen),
    ('frage', id, text, optionen, mit_text, nach)."""
    zeilen = open(pfad, encoding="utf-8").read().split("\n")
    out, i = [], 0
    stand = ""
    while i < len(zeilen):
        z = zeilen[i].strip()
        if not z or z == "---":
            i += 1
        elif z.startswith("# "):
            out.append(("h1", z[2:])); i += 1
        elif z.startswith("## "):
            out.append(("h2", z[3:])); i += 1
        elif z.startswith("Stand:"):
            stand = z[6:].strip(); i += 1
        elif z.startswith("|"):
            tab = []
            while i < len(zeilen) and zeilen[i].strip().startswith("|"):
                zellen = [bereinige(c) for c in zeilen[i].strip().strip("|").split("|")]
                if not all(set(c) <= set("-") for c in zellen):
                    tab.append(zellen)
                i += 1
            art = {"Angabe": "kopf", "Aussage": "skala", "Nr.": "fehler", "Frage": "etab"}[tab[0][0]]
            out.append((art, tab[1:]))
        elif re.match(r"\*\*[A-Z]\d+\.\*\*", z):
            m = re.match(r"\*\*([A-Z]\d+)\.\*\* (.*)", z)
            fid, rest = m.group(1), m.group(2)
            j = i + 1
            while j < len(zeilen) and not zeilen[j].strip():
                j += 1
            mit_text = j < len(zeilen) and zeilen[j].strip() == "---"
            text, optionen, nach = frage_teile(rest)
            out.append(("frage", fid, text, optionen, mit_text, nach))
            i += 1
        else:
            out.append(("p", bereinige(z.replace("**", "")))); i += 1
    return out, stand


def frage_teile(rest):
    """Trennt „Text ☐ a ☐ b ☐ c: Zusatz“ in Text, Optionen, Zusatzfrage."""
    teile = rest.split("☐")
    text = bereinige(teile[0])
    optionen, nach = [bereinige(t) for t in teile[1:]], ""
    if optionen:
        letzte = teile[-1]
        m = re.match(r"\s*(.*?)(?::|\\_)\s*(.*)$", letzte.replace("\\_\\_", "\\_"))
        if m and ("\\_" in letzte or ":" in letzte):
            optionen[-1] = bereinige(m.group(1)) or optionen[-1]
            nach = bereinige(m.group(2).replace("\\_", "").replace("_", ""))
    return text, optionen, nach


def werte(fid, optionen):
    """CSV-Wortlaut je Option (Skala = Ziffer, sonst Liste aus auswertung.py)."""
    if fid in SKALA or all(o.isdigit() for o in optionen):
        return [o for o in optionen]
    ws = WAHL[fid]
    assert len(ws) == len(optionen), (fid, ws, optionen)
    return ws


def bauen(md, pdf):
    from reportlab.lib.pagesizes import A4
    from reportlab.pdfgen import canvas
    from reportlab.lib.utils import simpleSplit
    from reportlab.lib.colors import black as SCHWARZ, white as WEISS

    bloecke, stand = parse(md)
    c = canvas.Canvas(pdf, pagesize=A4)
    c.setTitle("Prüfbogen Chroniken von Bornim (Stand %s)" % stand)
    c.setAuthor("BornWire TCS")
    B, H = A4
    R, OBEN, UNTEN = 40, H - 36, 42
    Y = [OBEN]
    seite = [1]
    form = c.acroForm

    def fuss():
        c.setFont("Helvetica", 8)
        c.drawString(R, 28, "Chroniken von Bornim · Prüfbogen · Bogen Stand %s · Seite %d" % (stand, seite[0]))

    def platz(h):
        if Y[0] - h < UNTEN:
            fuss(); c.showPage(); seite[0] += 1; Y[0] = OBEN

    def text(t, groesse=10, fett=False, breite=B - 2 * R, abstand=3, x=R):
        f = "Helvetica-Bold" if fett else "Helvetica"
        c.setFont(f, groesse)
        t = t.replace("→", ">")
        for zl in simpleSplit(t, f, groesse, breite):
            platz(groesse + 2)
            Y[0] -= groesse + 2
            c.drawString(x, Y[0], zl)
        Y[0] -= abstand

    def feld(name, x, y, w, h, mehr=False, wert=""):
        form.textfield(name=name, x=x, y=y, width=w, height=h, value=wert, borderStyle="underlined",
                       borderColor=SCHWARZ, fillColor=WEISS, textColor=SCHWARZ, fontSize=9,
                       fieldFlags="multiline" if mehr else "", forceBorder=True)

    def kreis(name, wert, x, y):
        c.setLineWidth(0.8); c.setStrokeColor(SCHWARZ)
        c.circle(x + 5, y + 5, 5, stroke=1, fill=0)
        form.radio(name=name, value=wert, selected=False, x=x, y=y, size=10, buttonStyle="cross",
                   borderWidth=0, fillColor=None, borderColor=None, textColor=SCHWARZ)

    def radios(name, optionen, x0, y, breite_max):
        """Optionen nebeneinander, bei Platzmangel in die nächste Zeile; Exportwert = Nummer."""
        x = x0
        c.setFont("Helvetica", 9)
        for n, o in enumerate(optionen):
            w = c.stringWidth(o, "Helvetica", 9) + 24
            if x + w > x0 + breite_max and x > x0:
                x = x0; Y[0] -= 15; platz(15); y = Y[0]
            kreis(name, str(n), x, y - 2)
            c.drawString(x + 14, y, o)
            x += w + 6

    form_felder = []
    for b in bloecke:
        art = b[0]
        if art == "h1":
            text(b[1], 16, True, abstand=6)
        elif art == "h2":
            Y[0] -= 6; platz(40); text(b[1], 12, True, abstand=4)
        elif art == "p":
            text(b[1], 9.5, abstand=5)
        elif art == "kopf":
            for z in b[1]:
                gerät = z[0].startswith(GERAET)
                platz(46 if gerät else 24)
                Y[0] -= 6
                if gerät:
                    text(z[0], 9.5, True, 190, 0)
                    feld("Gerät", 235, Y[0] - 6, 300, 38, mehr=True)
                    Y[0] -= 38
                    continue
                text(z[0], 9.5, True, 190, 0)
                y = Y[0] + 3
                if z[0] == "Gespielte Zeit":
                    c.setFont("Helvetica", 9.5)
                    feld("Stunden", 235, y - 3, 40, 14); c.drawString(280, y, "Std.")
                    feld("Minuten", 310, y - 3, 40, 14); c.drawString(355, y, "Min.")
                elif z[0].startswith("Erfahrung"):
                    opt = ["keine", "etwas", "viel"]
                    Y[0] += 0
                    radios("Erfahrung", opt, 235, y, 300)
                    Y[0] -= 11
                    text("z. B. Pen and Paper, Baldur's Gate, Diablo", 8, x=235, abstand=2)
                else:
                    namen = KOPF[z[0]]
                    breite = 300 if len(namen) == 1 else 145
                    for k, nm in enumerate(namen):
                        feld(nm, 235 + k * 155, y - 3, breite, 14)
                        if len(namen) > 1:
                            c.setFont("Helvetica", 7); c.drawString(235 + k * 155, y - 12, nm)
                Y[0] -= 6
        elif art == "skala":
            Y[0] -= 4
            platz(34)
            text_x = R + 205
            c.setFont("Helvetica-Bold", 8)
            for n in range(5):
                c.drawCentredString(text_x + 14 + 22 * n, Y[0] - 8, str(n + 1))
            c.drawString(text_x + 125, Y[0] - 8, "Stichwort")
            Y[0] -= 11
            for z in b[1]:
                fid = z[0].split(".")[0]
                zl = simpleSplit(z[0], "Helvetica", 9, 200)
                h = max(24, 11 * len(zl) + 8)
                platz(h)
                top = Y[0]
                c.setFont("Helvetica", 9)
                for k, s in enumerate(zl):
                    c.drawString(R, top - 10 - 11 * k, s)
                for n in range(5):
                    kreis(fid, str(n + 1), text_x + 9 + 22 * n, top - 14)
                feld(fid + "s", text_x + 125, top - 18, B - R - text_x - 125, 14)
                c.line(R, top - h + 2, B - R, top - h + 2)
                Y[0] -= h
        elif art == "frage":
            _, fid, t, optionen, mit_text, nach = b
            Y[0] -= 4
            platz(24 + (22 if optionen else 0) + (36 if mit_text else 0))
            text("%s. %s" % (fid, t), 9.5, True, abstand=2)
            if optionen:
                platz(32)
                Y[0] -= 11
                radios(fid, optionen, R + 8, Y[0], B - 2 * R - 8)
                Y[0] -= 5
            if mit_text:
                if optionen and nach:
                    text(nach, 8.5, x=R + 8, abstand=0)
                platz(36)
                h = 28 if not optionen else 20
                feld(fid + "text" if optionen else fid, R, Y[0] - h - 2, B - 2 * R, h, mehr=True)
                Y[0] -= h + 6
        elif art == "fehler":
            for n, z in enumerate(b[1], 1):
                platz(92)
                Y[0] -= 4
                text("Fehler %d" % n, 9, True, abstand=1)
                halb = (B - 2 * R - 10) / 2
                for k, (suffix, label) in enumerate(FEHLERFELDER):
                    xx = R + (k % 2) * (halb + 10)
                    if k % 2 == 0 and k:
                        Y[0] -= 31
                    c.setFont("Helvetica", 8)
                    ob = Y[0]
                    c.drawString(xx, ob - 9, {"ort": "Wo im Spiel (Ort, Quest)", "getan": "Was habe ich getan?",
                                              "passiert": "Was ist passiert?", "erwartet": "Was habe ich erwartet?"}[suffix])
                    feld("D%d%s" % (n, suffix), xx, ob - 27, halb, 17, mehr=True)
                Y[0] -= 30
                text("Schwere", 8, abstand=0)
                Y[0] -= 11
                radios("D%dschwere" % n, ["Absturz", "Spiel hängt", "stört", "Schönheitsfehler"], R, Y[0], B - 2 * R)
                Y[0] -= 8
        elif art == "etab":
            for z in b[1]:
                fid = z[0].split(".")[0]
                t = z[0]
                ort = "_" in t
                t = re.sub(r"\s*Ort:\s*_+", "", t) if ort else t
                optionen = [bereinige(o) for o in z[1].split("☐") if o.strip()]
                Y[0] -= 4
                text(t, 9.5, True, abstand=2)
                platz(32)
                Y[0] -= 11
                radios(fid, optionen, R + 8, Y[0], B - 2 * R - 8)
                if ort:
                    Y[0] -= 15
                    c.setFont("Helvetica", 9); c.drawString(R + 8, Y[0], "Ort:")
                    feld(fid + "ort", R + 35, Y[0] - 3, 250, 14)
                Y[0] -= 6
    # Kopffeld für den Bogenstand: unsichtbar, für die Auswertung
    form.textfield(name="Bogenstand", x=B - 100, y=H - 38, width=60, height=12, value=stand, borderStyle="solid",
                   borderWidth=0, fontSize=7, fieldFlags="readOnly", forceBorder=False)
    fuss()
    c.save()
    return seite[0]


def lesen(pdfs, boegen_csv, fehler_csv):
    from pypdf import PdfReader
    md = os.path.join(HIER, "bogen.md")
    bloecke, _ = parse(md)
    optmap = {}
    for b in bloecke:
        if b[0] == "frage" and b[3]:
            optmap[b[1]] = werte(b[1], b[3])
        elif b[0] == "etab":
            for z in b[1]:
                fid = z[0].split(".")[0]
                optmap[fid] = werte(fid, [bereinige(o) for o in z[1].split("☐") if o.strip()])
    optmap["Erfahrung"] = WAHL["Erfahrung"]
    for k in range(1, 6):
        optmap["D%dschwere" % k] = SCHWERE
    spalten = open(os.path.join(HIER, "boegen-vorlage.csv"), encoding="utf-8").readline().strip().split(",")
    spalten += [s + "s" for s in SKALA if s + "s" not in spalten] + ["Bogenstand"]
    zeilen, fehler = [], []
    for p in pdfs:
        f = PdfReader(p).get_fields() or {}

        def wert(n):
            v = f.get(n, {}).get("/V") if n in f else None
            return "" if v in (None, "", "/Off") else str(v)

        def auswahl(n):
            v = wert(n)
            if not v.startswith("/"):
                return v
            return optmap[n][int(v[1:])] if n in optmap else v[1:]
        z = {}
        for s in spalten:
            if s in optmap or s in SKALA:
                z[s] = auswahl(s) if s in optmap else wert(s)
            else:
                z[s] = wert(s)
        for s in SKALA:
            z[s] = wert(s)[1:] if wert(s).startswith("/") else wert(s)
        z["Kürzel"] = z.get("Kürzel") or os.path.basename(p)
        zeilen.append(z)
        for k in range(1, 6):
            r = {n: wert("D%d%s" % (k, s)) for s, n in FEHLERFELDER}
            r["Schwere"] = auswahl("D%dschwere" % k)
            if any(r.values()):
                r.update({"Tester": z["Kürzel"], "Nr": str(k), "Wiederholbar": z.get("D6", "")})
                fehler.append(r)
    with open(boegen_csv, "w", newline="", encoding="utf-8") as fo:
        w = csv.DictWriter(fo, fieldnames=spalten, extrasaction="ignore"); w.writeheader(); w.writerows(zeilen)
    fk = ["Tester", "Nr", "Ort", "Getan", "Passiert", "Erwartet", "Schwere", "Wiederholbar"]
    with open(fehler_csv, "w", newline="", encoding="utf-8") as fo:
        w = csv.DictWriter(fo, fieldnames=fk, extrasaction="ignore"); w.writeheader(); w.writerows(fehler)
    print("%d Bögen, %d Fehlerzeilen → %s, %s" % (len(zeilen), len(fehler), boegen_csv, fehler_csv))


if __name__ == "__main__":
    a = sys.argv[1:]
    if a[:1] == ["bauen"]:
        md = a[1] if len(a) > 1 else os.path.join(HIER, "bogen.md")
        pdf = a[2] if len(a) > 2 else os.path.join(HIER, "pruefbogen.pdf")
        print("%d Seiten: %s" % (bauen(md, pdf), pdf))
    elif a[:1] == ["lesen"]:
        bc, fc = "boegen.csv", "fehler.csv"
        pdfs = []
        i = 1
        while i < len(a):
            if a[i] == "--boegen": bc = a[i + 1]; i += 2
            elif a[i] == "--fehler": fc = a[i + 1]; i += 2
            else: pdfs.append(a[i]); i += 1
        lesen(pdfs, bc, fc)
    else:
        sys.exit(__doc__)
