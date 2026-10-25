# 348.6: Vergleichsbild alt/neu: tools/vgl348.py <alt: tools/preview/build/screens> <neu: --bilder-Ordner> <aus>
import sys, os
from PIL import Image, ImageDraw, ImageFont
alt, neu, out = sys.argv[1:4]
os.makedirs(out, exist_ok=True)
PAARE = [("zoom_nah_p_village_19_13", "tag"), ("zoom_nah_p_village_19_13_23", "nacht"), ("zoom_nah_p_village_6_6", "tuer"),
         ("zoom_nah_p_village_17_3", "schlagbaum"), ("zoom_nah_p_village_28_7", "laden"), ("zoom_nah_p_village_31_22", "kirche"),
         ("zoom_nah_p_village_15_24", "fluss")]
try: f = ImageFont.truetype("DejaVuSans.ttf", 26)
except OSError: f = ImageFont.load_default()
for a, n in PAARE:
    pa, pn = os.path.join(alt, a + ".png"), os.path.join(neu, n + ".png")
    if not (os.path.exists(pa) and os.path.exists(pn)): print("fehlt", a, n); continue
    A = Image.open(pa).convert("RGB"); N = Image.open(pn).convert("RGB")
    A = A.resize((540, int(A.height * 540 / A.width)), Image.LANCZOS)
    N = N.resize((540, int(N.height * 540 / N.width)), Image.LANCZOS)
    h = max(A.height, N.height)
    S = Image.new("RGB", (540 * 2 + 12, h + 44), (18, 16, 20)); d = ImageDraw.Draw(S)
    S.paste(A, (0, 44)); S.paste(N, (552, 44))
    d.text((10, 8), "alt (Kotlin)", fill=(212, 175, 55), font=f); d.text((562, 8), "neu (Godot)", fill=(212, 175, 55), font=f)
    S.save(os.path.join(out, "vgl_" + n + ".png")); print("ok", n)
