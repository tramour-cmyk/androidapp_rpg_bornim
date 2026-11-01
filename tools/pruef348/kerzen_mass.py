# 399.5 Lichtinseln (Pruefer Lauf 6): Anteil des Kerzenlichts am Boden um jede Kerze, ohne Ansehen. Aus dem Lauf mit KERZENPROBE=1
# (<raum>_<tag|nacht>.png und …_ohnekerzen.png) und den Zeilen „KERZE <name> x y bx by reichweite hoehe“ aus godot.log.
# Ausgabe je Kerze: Helligkeit (0-255) am Fusspunkt und in Ringen um ihn (Bildpunkte), mit und ohne Kerzenlicht.
# Aufruf: python3 -I kerzen_mass.py <ordner> <godot.log>
import sys, re
from PIL import Image
d, log = sys.argv[1], sys.argv[2]
namen = {}
for z in open(log, errors='replace'):
    m = re.match(r'KERZE (\S+) (-?\d+) (-?\d+) (-?\d+) (-?\d+) ([\d.]+) ([\d.]+)', z)
    if m: namen.setdefault(m.group(1), []).append(tuple(int(m.group(i)) for i in range(2, 6)) + (float(m.group(6)), float(m.group(7))))
for name, ks in sorted(namen.items()):
    a = Image.open('%s/%s.png' % (d, name)).convert('L'); b = Image.open('%s/%s_ohnekerzen.png' % (d, name)).convert('L')
    W, H = a.size; A = a.load(); B = b.load()
    def ring(x, y, r0, r1):
        s1 = s0 = n = 0
        for yy in range(max(0, y - r1), min(H, y + r1 + 1), 3):
            for xx in range(max(0, x - r1), min(W, x + r1 + 1), 3):
                dd = ((xx - x) ** 2 + (yy - y) ** 2) ** 0.5
                if r0 <= dd < r1: s1 += A[xx, yy]; s0 += B[xx, yy]; n += 1
        return (s1 / n, s0 / n) if n else (0, 0)
    print(name, 'Kerzen', len(ks), 'Mittel mit %.1f ohne %.1f' % (sum(a.getdata()) / (W * H), sum(b.getdata()) / (W * H)))
    for x, y, bx, by, rw, h in ks:
        if not (0 <= bx < W and 0 <= by < H): continue
        z = ' '.join('%d-%d:%.0f/%.0f' % ((r0, r1) + ring(bx, by, r0, r1)) for r0, r1 in ((0, 40), (40, 90), (90, 150), (150, 230), (230, 330)))
        print('  Kerze %d,%d Fuss %d,%d Hoehe %.2f m Reichweite %.2f m, Ring px mit/ohne: %s' % (x, y, bx, by, h, rw, z))
