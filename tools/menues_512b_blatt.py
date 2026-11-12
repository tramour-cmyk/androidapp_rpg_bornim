# 512b: Vergleichsblaetter der Menueschirme, links alt (Kotlin, tools/preview MENUE512B=1), rechts neu (Godot, godot/tests/menues_512b.gd),
# je Zustand ein Blatt <aus>/<name>.png, hoechstens 1600 px breit, Kopfzeile „alt (Kotlin) · <Zustand>“ / „neu (Godot) · <Zustand>“.
# Fehlt eine Seite, steht dort der Grund. Dazu die Pruefung nur mit Zahlen je Bild: einfarbig?, gleich wie der vorige Zustand derselben
# Seite?, Anteil heller Pixel (Schrift auf Schwarz) – nach <aus>/pruefung.txt und auf den Schirm.
# Aufruf: python3 tools/menues_512b_blatt.py <alt-Ordner> <neu-Ordner> <aus-Ordner>
# alt-Ordner (882.1): einmal gerendert im Zweig „bilder“, holen mit `bash tools/alt_bilder.sh 512b <alt-Ordner>` (ohne Gradle)
import os
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFont, ImageStat

alt, neu, aus = sys.argv[1:4]
os.makedirs(aus, exist_ok=True)

# Schirme, die es nur auf einer Seite gibt (aus dem Code, siehe Bericht 512b)
FEHLT = {
    ("alt", "06_ueber_lizenzen"): "alt: kein Knopf „Lizenzen der Engine“ (App.kt AboutScreen)",
    ("alt", "06b_ueber_lizenzen_ende"): "alt: kein Knopf „Lizenzen der Engine“ (App.kt AboutScreen)",
    ("neu", "76_kapitelende"): "neu: kein Schirm (spiel.gd: „kapitelende“ endet in szene.clear())",
}

B = 1600            # Blattbreite
L = 12              # Luecke zwischen den Seiten
W = (B - L) // 2    # Breite je Seite
KOPF = 52


def schrift(groesse):
    for f in ("DejaVuSans.ttf", "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"):
        try:
            return ImageFont.truetype(f, groesse)
        except OSError:
            pass
    return ImageFont.load_default()


F = schrift(22)
F2 = schrift(30)


def zustand(name):
    teile = name.split("_", 1)
    return teile[1].replace("_", " ") if len(teile) > 1 else name


def pruefe(pfad, vorher):
    im = Image.open(pfad).convert("RGB")
    grau = im.convert("L")
    st = ImageStat.Stat(grau)
    hell = sum(grau.histogram()[140:]) / (grau.width * grau.height)
    gleich = None
    if vorher is not None and vorher.size == im.size:
        gleich = ImageStat.Stat(ImageChops.difference(im, vorher).convert("L")).mean[0]
    return im, st.stddev[0], hell, gleich


namen = sorted({os.path.splitext(f)[0] for d in (alt, neu) if os.path.isdir(d) for f in os.listdir(d) if f.endswith(".png")}
               | {n for (_, n) in FEHLT})
zeilen = []
vorige = {"alt": None, "neu": None}
for n in namen:
    seiten = {}
    for s, d in (("alt", alt), ("neu", neu)):
        p = os.path.join(d, n + ".png")
        if os.path.exists(p):
            im, sd, hell, gleich = pruefe(p, vorige[s])
            befund = []
            if sd < 3:
                befund.append("EINFARBIG")
            if gleich is not None and gleich < 0.3:
                befund.append("GLEICH WIE VORIGER")
            zeilen.append("%-34s %-3s sd=%5.1f hell=%5.2f%% diff_vorher=%s %s" % (n, s, sd, hell * 100, "-" if gleich is None else "%.2f" % gleich, " ".join(befund)))
            vorige[s] = im
            seiten[s] = im
        else:
            zeilen.append("%-34s %-3s FEHLT %s" % (n, s, FEHLT.get((s, n), "(kein Bild)")))
    h = max([int(im.height * W / im.width) for im in seiten.values()] + [int(2340 * W / 1080)])
    blatt = Image.new("RGB", (B, h + KOPF), (18, 16, 20))
    d = ImageDraw.Draw(blatt)
    for i, s in enumerate(("alt", "neu")):
        x = i * (W + L)
        wort = ("alt (Kotlin)" if s == "alt" else "neu (Godot)") + " · " + zustand(n)
        d.text((x + 10, 12), wort, fill=(212, 175, 55), font=F)
        if s in seiten:
            im = seiten[s].resize((W, int(seiten[s].height * W / seiten[s].width)), Image.LANCZOS)
            blatt.paste(im, (x, KOPF))
        else:
            d.rectangle([x, KOPF, x + W - 1, KOPF + h - 1], fill=(40, 36, 44))
            grund = FEHLT.get((s, n), "kein Bild")
            y = KOPF + h // 2 - 40
            for teil in ["fehlt"] + [grund[j:j + 40] for j in range(0, len(grund), 40)]:
                d.text((x + 30, y), teil, fill=(230, 200, 120), font=F2)
                y += 40
    blatt.save(os.path.join(aus, n + ".png"))
with open(os.path.join(aus, "pruefung.txt"), "w") as f:
    f.write("\n".join(zeilen) + "\n")
print("\n".join(zeilen))
print("%d Blaetter nach %s" % (len(namen), aus))
