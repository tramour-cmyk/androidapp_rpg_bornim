import sys
from reportlab.lib.pagesizes import A4, landscape
from reportlab.pdfgen import canvas
from reportlab.lib.units import mm

out = sys.argv[1]
W, H = landscape(A4)
c = canvas.Canvas(out, pagesize=(W, H))
c.setTitle("Durchspielen Kapitel 1 - Bogen des Chefs")
M = 14 * mm

def header(page):
    c.setFont("Helvetica-Bold", 15)
    c.drawString(M, H - M, "Chroniken von Bornim · Durchspielen Kapitel 1 · Bogen des Chefs (26)")
    c.setFont("Helvetica", 8)
    c.drawRightString(W - M, H - M, "Stand 23.10. · Seite %d von 2" % page)

header(1)
y = H - M - 9 * mm
c.setFont("Helvetica", 10)
c.drawString(M, y, "Build: ____________    Klasse: ____________________    Neues Spiel:  ja / nein    Datum: __________    Gekämpft wird klassisch.")
y -= 6 * mm
c.setFont("Helvetica", 9)
c.drawString(M, y, "Je Station: S = zu schwer, P = passt, L = zu leicht · bei Kämpfen Versuche und verbrauchte Heiltränke · Fehler in einem Wort (Foto genügt) · Uhrzeit beim Erreichen.")
y -= 7 * mm

cols = [("#", 10), ("Station", 62), ("Worauf achten", 62), ("S / P / L", 30), ("Versuche", 20), ("Tränke", 18), ("Fehler / Bemerkung", 53), ("Uhr", 14)]
rows = [
    ("0", "Intro, Charaktererstellung", "Wirkt es fertig? Figur beim Drehen", False),
    ("1", "Erwachen im Gasthaus", "Weißt du, was zu tun ist?", False),
    ("2", "Auftrag des Ältesten", "Ist das Ziel klar?", False),
    ("3", "Schlagbaum", "Kampf fair?", True),
    ("4", "Garrick am Lagerfeuer (freiwillig)", "Warnung verständlich?", False),
    ("5", "Blutzahnhöhle, Krogg", "Kampf fair? Gefahr vorher lesbar?", True),
    ("6", "Graks Halle", "Bosskampf", True),
    ("7", "Lyras Befreiung", "Weg klar? Kampf fair?", True),
    ("8", "Rückkehr zu Aldric, Tempel, Ende", "Gefühl am Ende", False),
    ("–", "Morwen, Grimmzahn (freiwillig)", "Kampf mit Grimmzahn", True),
    ("–", "Nebenquests vom Anschlagbrett", "Welche gemacht? Lohnend?", True),
]
total = sum(w for _, w in cols) * mm
scale = (W - 2 * M) / total
xs = [M]
for _, w in cols:
    xs.append(xs[-1] + w * mm * scale)
rh = 11.2 * mm
c.setFillGray(0.9)
c.rect(M, y - 7 * mm, W - 2 * M, 7 * mm, stroke=0, fill=1)
c.setFillGray(0)
c.setFont("Helvetica-Bold", 9)
for i, (n, _) in enumerate(cols):
    c.drawString(xs[i] + 1.5 * mm, y - 5 * mm, n)
top = y
y -= 7 * mm
c.setFont("Helvetica", 9)
for r in rows:
    c.drawString(xs[0] + 1.5 * mm, y - 6.5 * mm, r[0])
    c.drawString(xs[1] + 1.5 * mm, y - 6.5 * mm, r[1])
    c.setFont("Helvetica", 8.5)
    c.drawString(xs[2] + 1.5 * mm, y - 6.5 * mm, r[2])
    c.setFont("Helvetica", 9)
    for k, ch in enumerate("SPL"):
        bx = xs[3] + 2 * mm + k * 9 * mm
        c.rect(bx, y - 7.2 * mm, 3 * mm, 3 * mm)
        c.drawString(bx + 3.8 * mm, y - 6.8 * mm, ch)
    if not r[3]:
        c.drawString(xs[4] + 2 * mm, y - 6.5 * mm, "–")
        c.drawString(xs[5] + 2 * mm, y - 6.5 * mm, "–")
    y -= rh
c.setLineWidth(0.6)
for x in xs:
    c.line(x, top, x, y)
yy = top
c.line(M, yy, W - M, yy)
yy -= 7 * mm
while yy >= y - 0.1:
    c.line(M, yy, W - M, yy)
    yy -= rh
c.showPage()

header(2)
y = H - M - 12 * mm
c.setFont("Helvetica-Bold", 12)
c.drawString(M, y, "Am Ende: drei Fragen")
y -= 8 * mm
qs = [
    "1. Uhrzeit am Ende (die genaue Spielzeit lesen wir aus dem Spielstand):  ____________",
    "2. Musstest du an einer Stelle grinden (Stufen sammeln), um weiterzukommen?   nein / ja, wo:",
    "3a. Die drei Dinge, die am meisten gestört haben:",
    "3b. Das eine, das am besten war:",
]
lines = [0, 2, 4, 2]
c.setFont("Helvetica", 10.5)
for q, n in zip(qs, lines):
    c.drawString(M, y, q)
    y -= 7 * mm
    for k in range(n):
        c.line(M + 4 * mm, y, W - M, y)
        y -= 9 * mm
    y -= 3 * mm
c.setFont("Helvetica-Bold", 10)
c.drawString(M, y, "Nicht nötig:")
c.setFont("Helvetica", 10)
c.drawString(M + 24 * mm, y, "Schadenszahlen, Würfe, genaue Lebenspunkte (misst der Zufallsspieler).")
y -= 7 * mm
c.drawString(M, y, "Zurück als Foto, Text oder Sprachnachricht; Perikles macht daraus die Vorgänge.")
c.showPage()
c.save()
