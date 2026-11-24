#!/usr/bin/env python3
"""1603: Ansage alt gegen neu je Art als zwei Bilder in Handygröße (540 x 1170), je Zeile Art, links alt, rechts neu, beschriftet
mit Art und Commit. Eingabe: Ordner mit <GEGNER>-<MODUS>.png aus godot/tests/bild_1603.gd (270 x 270 je Ausschnitt).
   python3 tools/kampf/bild_1603.py <Ordner> <Commit>"""
import os, sys
from PIL import Image, ImageDraw, ImageFont

D, C = sys.argv[1], sys.argv[2]
ZEILEN = [("KROGG", "Krogg", "neu"), ("KROGG", "Krogg (großer Schlag)", "paw"), ("BOARS", "Wildschwein", "neu"),
          ("CENTIPEDES", "Hundertfüßer", "neu"), ("LEECHES", "Riesenegel", "neu"), ("SLUGS", "Säureschnecke", "neu"),
          ("KOBOLDS", "Kobold", "neu"), ("SKELETONS", "Skelett", "neu")]
F = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
gross, klein = ImageFont.truetype(F, 18), ImageFont.truetype(F, 14)
for teil in (0, 1):
    b = Image.new("RGB", (540, 1170), (12, 12, 16))
    d = ImageDraw.Draw(b)
    d.text((8, 6), f"1603 Ansage je Art · Commit {C}", font=gross, fill=(230, 200, 120))
    d.text((8, 30), "links alt (wie main: Stich) · rechts neu", font=klein, fill=(220, 220, 220))
    y = 54
    for g, name, m in ZEILEN[teil * 4:teil * 4 + 4]:
        d.text((8, y), name, font=gross, fill=(255, 255, 255))
        y += 24
        for x, mod in ((0, "alt"), (270, m)):
            p = os.path.join(D, f"{g}-{mod}.png")
            if os.path.exists(p):
                b.paste(Image.open(p).convert("RGB").resize((268, 244)), (x + 1, y))
            else:
                d.text((x + 10, y + 100), "fehlt", font=gross, fill=(255, 80, 80))
        y += 252
    b.save(os.path.join(D, f"1603-ansage-{teil + 1}.png"))
    print("BILD1603 Montage", os.path.join(D, f"1603-ansage-{teil + 1}.png"))
