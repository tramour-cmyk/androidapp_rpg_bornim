"""399.5: Blatt je Grundriss, alt neben neu: alt Tag | neu Tag | alt Nacht | neu Nacht | neu gedreht (Ausschnitt um den Raum).
Aufruf: python3 -I raeume_blatt.py <alt-ordner> <neu-ordner> <ziel-stamm>  -> <stamm>-<raum>.jpg (je unter 60 KB, Chefsache) und
<stamm>-alle.jpg (gross, fuer Telegram)."""
import os
import sys
from PIL import Image, ImageDraw, ImageFont

ALT, NEU, ZIEL = sys.argv[1:4]
ALT_NAME = {'inn': 'zoom_nah_p_inn_4_6', 'shop': 'zoom_nah_p_shop_4_4', 'elder': 'zoom_nah_p_elder_4_4', 'temple': 'zoom_nah_p_temple_4_4'}
TITEL = {'inn': 'Schenke', 'shop': 'Laden', 'elder': 'Ältester', 'temple': 'Tempel'}


def schrift(n):
    for f in ('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', '/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf'):
        if os.path.exists(f):
            return ImageFont.truetype(f, n)
    return ImageFont.load_default()


def ausschnitt(p):
    """mittleres Drittel des Hochformats (dort steht der Raum um den Helden), quadratisch"""
    if not os.path.exists(p):
        return Image.new('RGB', (720, 720), (40, 0, 0))
    im = Image.open(p).convert('RGB')
    w, h = im.size
    s = w
    return im.crop((0, (h - s) // 2, w, (h + s) // 2)).resize((720, 720), Image.LANCZOS)


zeilen = []
for r in ('inn', 'shop', 'elder', 'temple'):
    teile = [('alt Tag', os.path.join(ALT, ALT_NAME[r] + '.png')), ('neu Tag', os.path.join(NEU, r + '_tag.png')),
             ('alt Nacht', os.path.join(ALT, ALT_NAME[r] + '_23.png')), ('neu Nacht', os.path.join(NEU, r + '_nacht.png')),
             ('neu gedreht', os.path.join(NEU, r + '_gedreht.png'))]
    bl = Image.new('RGB', (720 * len(teile), 720 + 60), (12, 10, 8))
    d = ImageDraw.Draw(bl)
    for i, (t, p) in enumerate(teile):
        bl.paste(ausschnitt(p), (720 * i, 60))
        d.text((720 * i + 16, 12), '%s · %s' % (TITEL[r], t), fill=(214, 180, 90), font=schrift(34))
    zeilen.append(bl)
    k = bl.resize((bl.width // 3, bl.height // 3), Image.LANCZOS)
    q = 80
    while True:
        k.save('%s-%s.jpg' % (ZIEL, r), quality=q)
        if os.path.getsize('%s-%s.jpg' % (ZIEL, r)) < 60000 or q < 30:
            break
        q -= 8
alle = Image.new('RGB', (zeilen[0].width, sum(z.height for z in zeilen)))
y = 0
for z in zeilen:
    alle.paste(z, (0, y))
    y += z.height
alle = alle.resize((alle.width // 2, alle.height // 2), Image.LANCZOS)
alle.save(ZIEL + '-alle.jpg', quality=82)
print('BLATT', ZIEL, alle.size, os.path.getsize(ZIEL + '-alle.jpg'))
