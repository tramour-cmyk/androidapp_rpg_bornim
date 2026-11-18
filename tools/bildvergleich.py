#!/usr/bin/env python3
"""1710 (Chef 18.11., 22:08, über Sokrates): Bildvergleich-Wächter. Ein Bild „alt gegen neu“ (eine Datei, beide Hälften
nebeneinander oder übereinander, 1128 A) ohne messbaren Unterschied hält meldung.sh an: der Chef soll nie zwei gleiche
Hälften vergleichen müssen (1694: Bild 20:43 zeigte den neuen Griff wirkungslos, die Messung hatte „passt“ gemeldet).

Wie andere es lösen (Bildvergleich in Prüfabläufen, etwa pixelmatch, reg-suit, Percy): Anteil der Pixel, die sich um mehr als
eine Schwelle je Farbkanal unterscheiden, nach leichtem Weichzeichnen gegen Kantenflimmern; hier umgekehrt: zu wenig Unterschied
ist der Fehler. Die Lage der Hälften kennt das Werkzeug nicht: verglichen werden links/rechts und oben/unten, es gilt die
ähnlichere Teilung (die andere vergleicht Verschiedenes). Optional ein Ausschnitt in jeder Hälfte (x,y,b,h als Anteile 0–1),
etwa nur die Hand.

  python3 tools/bildvergleich.py <bild> [--ausschnitt x,y,b,h]   Exit 1 und Grund, wenn kein Unterschied
  python3 tools/bildvergleich.py --test
"""
import sys

SCHWELLE = 24          # je Kanal (0–255): darunter gilt ein Pixel als gleich
ANTEIL_MIN = 0.002     # mindestens 0,2 % der Pixel der Hälfte (bzw. des Ausschnitts) verschieden


def unterschied(pfad, ausschnitt=None):
    """(Anteil verschiedener Pixel der ähnlicheren Teilung, Teilung)"""
    from PIL import Image, ImageFilter
    import numpy as np
    im = Image.open(pfad).convert("RGB").filter(ImageFilter.GaussianBlur(1))
    a = np.asarray(im).astype(np.int16)
    h, b = a.shape[:2]
    ergebnis = []
    for name, x, y in (("links/rechts", a[:, : b // 2], a[:, b - b // 2:]), ("oben/unten", a[: h // 2], a[h - h // 2:])):
        if ausschnitt:
            hh, bb = x.shape[:2]
            x0, y0, x1, y1 = (int(ausschnitt[0] * bb), int(ausschnitt[1] * hh),
                              int((ausschnitt[0] + ausschnitt[2]) * bb), int((ausschnitt[1] + ausschnitt[3]) * hh))
            x, y = x[y0:y1, x0:x1], y[y0:y1, x0:x1]
        if x.size == 0:
            continue
        ergebnis.append((float((np.abs(x - y).max(axis=2) > SCHWELLE).mean()), name))
    return min(ergebnis)


def pruefen(pfad, ausschnitt=None):
    """Grund zum Anhalten oder None."""
    anteil, teilung = unterschied(pfad, ausschnitt)
    if anteil < ANTEIL_MIN:
        return ("Bild alt gegen neu ohne messbaren Unterschied (%s, %.2f %% der Pixel verschieden, Grenze %.1f %%%s); "
                "erst die Ursache finden (Messung gegen Bild, 1711), nicht senden. Übersteuern nur mit Begründung im Text: "
                "„Ohne Unterschied, weil: …“ (1710)" % (teilung, 100 * anteil, 100 * ANTEIL_MIN,
                                                       ", Ausschnitt" if ausschnitt else ""))
    return None


def test():
    from PIL import Image, ImageDraw
    import os, tempfile
    d = tempfile.mkdtemp()
    f = 0

    def bild(name, links_kreis, rechts_kreis, quer=True):
        im = Image.new("RGB", (400, 200) if quer else (200, 400), (40, 30, 20))
        dr = ImageDraw.Draw(im)
        for i, (cx, cy, r) in enumerate((links_kreis, rechts_kreis)):
            ox, oy = (200 * i, 0) if quer else (0, 200 * i)
            dr.ellipse((ox + cx - r, oy + cy - r, ox + cx + r, oy + cy + r), fill=(200, 160, 120))
        p = os.path.join(d, name); im.save(p); return p

    def ok(b, was):
        nonlocal f
        if not b:
            f += 1; print("FEHLER", was)
    ok(pruefen(bild("gleich.png", (100, 100, 40), (100, 100, 40))) is not None, "gleiche Hälften halten an")
    ok(pruefen(bild("anders.png", (100, 100, 40), (110, 100, 40))) is None, "Kreis 10 px verschoben geht durch")
    ok(pruefen(bild("gleich_hoch.png", (100, 100, 40), (100, 100, 40), quer=False)) is not None, "übereinander gleich hält an")
    ok(pruefen(bild("anders_hoch.png", (100, 100, 40), (100, 100, 30), quer=False)) is None, "übereinander anders geht durch")
    ok(pruefen(bild("aussen.png", (30, 30, 20), (30, 40, 20)), (0.5, 0.5, 0.5, 0.5)) is not None, "Unterschied außerhalb des Ausschnitts hält an")
    print("BILDVERGLEICH1710 %d Fehler" % f)
    return 1 if f else 0


if __name__ == "__main__":
    if "--test" in sys.argv:
        sys.exit(test())
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    aus = None
    if "--ausschnitt" in sys.argv:
        aus = [float(v) for v in sys.argv[sys.argv.index("--ausschnitt") + 1].split(",")]
        args = [a for a in args if a != sys.argv[sys.argv.index("--ausschnitt") + 1]]
    if not args:
        sys.exit(__doc__)
    try:
        g = pruefen(args[0], aus)
    except Exception as e:   # eigener Fehler (Datei, Bibliothek): durchlassen
        print("bildvergleich: übersprungen (%s)" % e, file=sys.stderr); sys.exit(0)
    if g:
        print(g); sys.exit(1)
