# 348.9 (Jerry): Vergleichsblatt Tier oder Monster: oben alt (BEASTDRAFT=1 → entwurf_rat.png, FOEDRAFT=goblin → entwurf_goblin.png),
# unten drei Ausschnitte aus dem Godot-Bild (je Figur aus „Schirm <id>: Fuß …“ im Godot-Log).
# Aufruf: [FIGUR=wolf|gob] [NAMEN="gob1=Krummsäbel, Wams, Fell;…"] python3 vergleichsblatt.py <alt.png> <neu.png> <godot-log> <aus.png>
import sys, re, os
from PIL import Image, ImageDraw
alt, grund, log, out = sys.argv[1:5]
FIG = os.environ.get('FIGUR', 'wolf')
A = Image.open(alt).convert('RGB')
if FIG != 'wolf':   # alt: drei Felder nebeneinander (FOEDRAFT), je Feld auf die Figur zugeschnitten, so breit wie die neuen Ausschnitte
    from PIL import ImageChops
    bg = A.getpixel((2, A.height - 2)); cw = A.width // 3; row = []
    for i in range(3):
        c = A.crop((i * cw, 20, (i + 1) * cw, A.height))
        bb = ImageChops.difference(c, Image.new('RGB', c.size, bg)).getbbox()
        x0, y0, x1, y1 = bb; h = y1 - y0; w = int(h / 1.1 * 1.0); cx = (x0 + x1) // 2
        c = c.crop((cx - w // 2, y0 - int(h * 0.05), cx + w // 2, y1 + int(h * 0.05)))
        row.append(c.resize((356, int(356 * c.height / c.width))))
    A = Image.new('RGB', (1080, max(r.height for r in row) + 22), (20, 20, 20))
    for i, r in enumerate(row): A.paste(r, (i * 362, 22))
    ImageDraw.Draw(A).text((6, 4), 'alt (FoeArt, wie im Kampf): Krummsaebel/Schild/Wams/Fell, Handbeil/Kappe/Wams/Fell, zwei Klingen/Helm', fill=(240, 232, 216))
else:
    A = A.resize((1080, int(A.height * 1080 / A.width)))
G = Image.open(grund).convert('RGB')
pos = [(n, int(x), int(f), int(k)) for n, x, f, x2, k in re.findall(r'Schirm (%s\d): Fuß (\d+),(\d+) Kopf (\d+),(\d+)' % FIG, open(log).read())]
NAMEN = dict(e.split('=', 1) for e in os.environ.get('NAMEN', '').split(';') if '=' in e)
FELL = {781: "braun", 840: "grau, Raeude", 469: "schwarz, Ohr"}
NH = 460 if FIG != 'wolf' else 440
B = Image.new('RGB', (1080, A.height + NH), (20, 20, 20)); B.paste(A, (0, 0))
d = ImageDraw.Draw(B)
d.text((6, A.height + 4), 'neu (Godot, Runde %s)' % os.environ.get('RUNDE', '?'), fill=(240, 232, 216))
for i, (n, x, f, k) in enumerate(sorted(pos, key=lambda p: p[0])):
    d.text((i * 362 + 4, A.height + NH - 16), "neu: " + NAMEN.get(n, FELL.get(x, n)), fill=(240, 232, 216))
    h = (f - k); w = int(h * (1.2 if FIG != 'wolf' else 3.0)); bot = f + int(h * 0.15 if FIG != 'wolf' else h * 0.4); top = bot - int(w * 1.1)
    c = G.crop((x - w // 2, top, x + w // 2, bot)).resize((356, int(356 * (bot - top) / w)))
    if c.height > NH - 40: c = c.crop((0, c.height - (NH - 40), 356, c.height))
    B.paste(c, (i * 362, A.height + 22))
B.save(out); print(B.size, pos)
