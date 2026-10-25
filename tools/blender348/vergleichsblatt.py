# 348.9 (Jerry): Vergleichsblatt Ratte/Vierbeiner: oben alt (BEASTDRAFT=1 → entwurf_rat.png), unten drei Ausschnitte aus dem Godot-Bild.
# Aufruf: python3 vergleichsblatt.py <alt.png> <neu.png> <godot-log mit „Schirm wolfN“> <aus.png>
import sys, re
from PIL import Image, ImageDraw
alt, grund, log, out = sys.argv[1:5]
A = Image.open(alt).convert('RGB'); A = A.resize((1080, int(A.height * 1080 / A.width)))
G = Image.open(grund).convert('RGB')
pos = [(int(x), int(f), int(k)) for n, x, f, x2, k in re.findall(r'Schirm (wolf\d): Fuß (\d+),(\d+) Kopf (\d+),(\d+)', open(log).read())]
B = Image.new('RGB', (1080, A.height + 440), (20, 20, 20)); B.paste(A, (0, 0))
d = ImageDraw.Draw(B)
d.text((6, A.height + 4), 'neu (Godot, Runde 5): braun, grau/Raeude, schwarz/Ohr', fill=(240, 232, 216))
FELL = {781: "braun", 840: "grau, Raeude", 469: "schwarz, Ohr"}
for i, (x, f, k) in enumerate(sorted(pos)):
    d.text((i * 362 + 4, A.height + 424), "neu: " + FELL.get(x, "?"), fill=(240, 232, 216))
    h = (f - k); w = int(h * 3.0); bot = f + int(h * 0.4); top = bot - int(w * 1.1)
    c = G.crop((x - w // 2, top, x + w // 2, bot)).resize((356, int(356 * (bot - top) / w)))
    B.paste(c, (i * 362, A.height + 22))
B.save(out); print(B.size, pos)
