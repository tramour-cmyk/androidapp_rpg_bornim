# 348.5: gemalte Texturen fuer Dorf und Held (kachelbar), Farben nach MapGround.kt, MapTownIso.kt, MapTree.kt.
# Licht im Bild von rechts oben (wie MapTree.kt), Fugen und Kanten dunkel wie Tusche.
# Aufruf: OUT=<ordner> python -I tex.py  -> <OUT>/tex/<name>.png (sRGB)
import os, math
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
TD = os.path.join(OUT, 'tex'); os.makedirs(TD, exist_ok=True)

def hx(c): return np.array([(c >> 16) & 255, (c >> 8) & 255, c & 255], np.float32) / 255.0
def lerp(a, b, t): return a + (b - a) * t
def sat(x): return np.clip(x, 0.0, 1.0)
def ss(a, b, x): t = sat((x - a) / (b - a)); return t * t * (3 - 2 * t)

def pnoise(n, cells, seed):
    """kachelbares Wertrauschen n x n mit cells Zellen je Seite, 0..1"""
    r = np.random.default_rng(seed).random((cells, cells)).astype(np.float32)
    u = np.arange(n, dtype=np.float32) * cells / n
    i0 = np.floor(u).astype(int); f = u - i0; f = f * f * (3 - 2 * f)
    i1 = (i0 + 1) % cells; i0 %= cells
    a = r[i0][:, i0] * (1 - f)[None, :] + r[i0][:, i1] * f[None, :]
    b = r[i1][:, i0] * (1 - f)[None, :] + r[i1][:, i1] * f[None, :]
    return a * (1 - f)[:, None] + b * f[:, None]

def pnoise2(n, cu, cv, seed):
    """kachelbar, cu Zellen quer (x), cv Zellen hoch (y)"""
    r = np.random.default_rng(seed).random((cv, cu)).astype(np.float32)
    def ax(c):
        u = np.arange(n, dtype=np.float32) * c / n
        i0 = np.floor(u).astype(int); f = u - i0; f = f * f * (3 - 2 * f)
        return i0 % c, (i0 + 1) % c, f
    x0, x1, fx = ax(cu); y0, y1, fy = ax(cv)
    a = r[y0][:, x0] * (1 - fx)[None, :] + r[y0][:, x1] * fx[None, :]
    b = r[y1][:, x0] * (1 - fx)[None, :] + r[y1][:, x1] * fx[None, :]
    return a * (1 - fy)[:, None] + b * fy[:, None]

def fbm(n, cells, seed, oct=4, gain=0.5):
    s, w, tot = np.zeros((n, n), np.float32), 1.0, 0.0
    for k in range(oct):
        s += w * pnoise(n, cells * 2 ** k, seed + 31 * k); tot += w; w *= gain
    return s / tot

def voronoi(n, cells, seed, jitter=0.8, sy=1.0):
    """kachelbar: Abstand zum naechsten (d1) und zweitnaechsten (d2) Punkt, Zellnummer; in Zellbreiten"""
    rng = np.random.default_rng(seed)
    P = 0.5 + (rng.random((cells, cells, 2)) - 0.5) * jitter
    y, x = np.mgrid[0:n, 0:n].astype(np.float32) * cells / n
    cx, cy = np.floor(x).astype(int), np.floor(y).astype(int)
    d1 = np.full((n, n), 9.0, np.float32); d2 = d1.copy(); idc = np.zeros((n, n), np.int64)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            gx, gy = cx + dx, cy + dy
            p = P[gy % cells, gx % cells]
            ddx = gx + p[..., 0] - x; ddy = (gy + p[..., 1] - y) * sy
            d = np.sqrt(ddx * ddx + ddy * ddy)
            idn = (gy % cells) * cells + (gx % cells)
            m1 = d < d1
            d2 = np.where(m1, d1, np.minimum(d2, d)); idc = np.where(m1, idn, idc); d1 = np.where(m1, d, d1)
    return d1, d2, idc

def cellrand(idc, seed):
    r = np.random.default_rng(seed).random(idc.max() + 1).astype(np.float32)
    return r[idc]

def strokes(n, count, seed, length, width, cols, lean=(-0.3, 0.3), alpha=(0.5, 0.9), vertical=True, mask=None):
    """kurze Pinselstriche (Halme, Strohhalme, Maserung), kachelbar durch Zeichnen mit Versatz"""
    rng = np.random.default_rng(seed)
    img = Image.new('RGBA', (n, n), (0, 0, 0, 0)); d = ImageDraw.Draw(img)
    for _ in range(count):
        x, y = rng.random() * n, rng.random() * n
        if mask is not None and mask[int(y) % n, int(x) % n] < rng.random(): continue
        L = rng.uniform(*length); a = rng.uniform(*lean)
        dx, dy = (math.sin(a) * L, -math.cos(a) * L) if vertical else (math.cos(a) * L, math.sin(a) * L)
        c = cols[rng.integers(len(cols))]; al = int(255 * rng.uniform(*alpha)); w = max(1, int(round(rng.uniform(*width))))
        col = tuple(int(v * 255) for v in c) + (al,)
        for ox in (-n, 0, n):
            for oy in (-n, 0, n):
                if -L - 4 < x + ox < n + L + 4 and -L - 4 < y + oy < n + L + 4:
                    d.line([(x + ox, y + oy), (x + ox + dx, y + oy + dy)], fill=col, width=w)
    a = np.asarray(img).astype(np.float32) / 255.0
    return a[..., :3], a[..., 3:4]

def blots(n, count, seed, r, cols, alpha=(0.7, 1.0), shade=0.0, mask=None):
    """Tupfen (Blueten, Kiesel): Kreise mit dunklem Unterrand (Licht von oben rechts)"""
    rng = np.random.default_rng(seed)
    img = Image.new('RGBA', (n, n), (0, 0, 0, 0)); d = ImageDraw.Draw(img)
    for _ in range(count):
        x, y = rng.random() * n, rng.random() * n
        if mask is not None and mask[int(y) % n, int(x) % n] < rng.random(): continue
        rr = rng.uniform(*r); c = np.array(cols[rng.integers(len(cols))]); al = int(255 * rng.uniform(*alpha))
        for ox in (-n, 0, n):
            for oy in (-n, 0, n):
                X, Y = x + ox, y + oy
                if -rr < X < n + rr and -rr < Y < n + rr:
                    if shade > 0:
                        d.ellipse([X - rr, Y - rr + rr * 0.35, X + rr, Y + rr + rr * 0.35], fill=tuple(int(v * 255 * (1 - shade)) for v in c) + (al,))
                    d.ellipse([X - rr, Y - rr, X + rr, Y + rr], fill=tuple(int(v * 255) for v in c) + (al,))
                    if shade > 0:
                        hr = rr * 0.45
                        d.ellipse([X - hr + rr * 0.25, Y - hr - rr * 0.3, X + hr + rr * 0.25, Y + hr - rr * 0.3], fill=tuple(int(min(1, v * 1.25) * 255) for v in c) + (int(al * 0.6),))
    a = np.asarray(img).astype(np.float32) / 255.0
    return a[..., :3], a[..., 3:4]

def over(base, rgb, a): return base * (1 - a) + rgb * a
def save(name, rgb, alpha=None):
    a = (sat(rgb) * 255 + 0.5).astype(np.uint8)
    if alpha is not None:
        a = np.concatenate([a, (sat(alpha) * 255 + 0.5).astype(np.uint8)[..., None]], 2)
    Image.fromarray(a).save(os.path.join(TD, name + '.png'))
    print('TEX', name, a.shape)

def ramp(t, cols):
    """Farbverlauf ueber mehrere Stuetzfarben, t 0..1"""
    cs = [hx(c) for c in cols]; k = len(cs) - 1
    t = sat(t) * k; i = np.minimum(np.floor(t).astype(int), k - 1); f = (t - i)[..., None]
    A = np.stack(cs)[i]; B = np.stack(cs)[i + 1]
    return A * (1 - f) + B * f

# ------------------------------------------------------------------ Boden (Wiederholung 2 Kacheln = 232 cm, 1024 px)
def gras():
    n = 1024
    t = fbm(n, 6, 1) * 0.55 + pnoise(n, 40, 2) * 0.25 + pnoise(n, 90, 3) * 0.2
    c = lerp(hx(0x2E3E22), hx(0x5E7240), t[..., None])
    clump = ss(0.45, 0.75, fbm(n, 14, 4))                                              # Bueschel: dunkler Grund, helle Spitzen
    c = lerp(c, hx(0x24301A), (0.35 * clump)[..., None])
    c = lerp(c, hx(0x6E5A3A), (0.4 * ss(0.66, 0.82, fbm(n, 4, 40)))[..., None])       # kahle Stellen
    for seed, cnt, cols, L, m in ((5, 11000, [hx(0x1A2214), hx(0x26341A)], (10, 22), None),
                                  (6, 12000, [hx(0x60703E), hx(0x7A8A4A), hx(0x8A9A56)], (8, 18), clump),
                                  (7, 6000, [hx(0x9AA862), hx(0xA8B470)], (6, 12), clump)):
        rgb, a = strokes(n, cnt, seed, L, (1.5, 3.0), cols, lean=(-0.5, 0.5), alpha=(0.5, 0.9), mask=m); c = over(c, rgb, a)
    rgb, a = blots(n, 300, 8, (4, 7), [hx(0x6A8A3E), hx(0x5A7A36)], alpha=(0.6, 0.9)); c = over(c, rgb, a)    # Klee
    rgb, a = blots(n, 90, 9, (6, 9), [hx(0xB8A8C0), hx(0x9A5A50), hx(0xC8B88A), hx(0xE8E0D0), hx(0xD8C050)], shade=0.35); c = over(c, rgb, a)
    save('gras', c)

def erde():
    n = 1024
    t = fbm(n, 5, 11) * 0.7 + pnoise(n, 60, 12) * 0.3
    c = ramp(t, [0x4A3A28, 0x6A5840, 0x8A7456])
    c = lerp(c, hx(0x3A2E22), (0.45 * ss(0.55, 0.75, fbm(n, 8, 13)))[..., None])      # feuchte Flecken
    rgb, a = strokes(n, 900, 14, (10, 30), (1, 2), [hx(0x3A2C1E)], lean=(-1.5, 1.5), alpha=(0.3, 0.6), vertical=False); c = over(c, rgb, a)  # Risse
    rgb, a = blots(n, 260, 15, (5, 11), [hx(0x8A7C6A), hx(0x5A5048), hx(0x9A8E7A), hx(0x6E6256)], shade=0.5); c = over(c, rgb, a)   # Kiesel
    rgb, a = blots(n, 500, 17, (2, 4), [hx(0x7A6C58), hx(0x4A4036)], shade=0.4, alpha=(0.5, 0.8)); c = over(c, rgb, a)
    rgb, a = strokes(n, 600, 16, (8, 18), (1.5, 2.5), [hx(0x4A5A2E), hx(0x3A4A26)], alpha=(0.4, 0.7), mask=ss(0.6, 0.75, fbm(n, 5, 18))); c = over(c, rgb, a)
    save('erde', c)

def pflaster():
    """Feldsteinpflaster in Reihen (11,6 cm), Steine verschieden breit, Ecken gerundet, Licht von rechts oben"""
    n = 1024; rows = 10
    rng = np.random.default_rng(21)
    y, x = np.mgrid[0:n, 0:n].astype(np.float32)
    rowh = n / rows
    yw = y + (pnoise(n, 24, 30) - 0.5) * rowh * 0.5
    k = np.floor(yw / rowh).astype(int) % rows; fv = yw / rowh - np.floor(yw / rowh)
    # Breiten je Reihe: Grenzen in u (0..1) zufaellig
    bounds = []
    for r in range(rows):
        b = [0.0]
        while b[-1] < 1.0: b.append(b[-1] + rng.uniform(0.07, 0.14))
        b = np.array(b) / b[-1]; b = (b + rng.random()) % 1.0; b.sort(); bounds.append(np.concatenate([[b[-1] - 1], b, [b[0] + 1]]))
    u = x / n
    du = np.zeros_like(u); sid = np.zeros(u.shape, np.int64); width = np.zeros_like(u)
    for r in range(rows):
        m = k == r; b = bounds[r]
        j = np.searchsorted(b, u[m], side='right') - 1
        l, h = b[j], b[j + 1]
        du[m] = np.minimum(u[m] - l, h - u[m]) * n / rowh; width[m] = (h - l) * n / rowh
        sid[m] = r * 100 + (j % (len(b) - 2))
    dv = np.minimum(fv, 1 - fv)
    # gerundeter Abstand zum Rand (in Reihenhoehen)
    cr = 0.36
    qx = np.maximum(cr - du, 0); qy = np.maximum(cr - dv, 0)
    inside = cr - np.sqrt(qx * qx + qy * qy)
    edge = np.minimum(inside, np.minimum(du, dv) + 0.0)
    edge = np.where((du < cr) & (dv < cr), inside, np.minimum(du, dv))
    edge += (pnoise(n, 60, 29) - 0.5) * 0.05
    r1 = cellrand(sid, 22); r2 = cellrand(sid, 23); r3 = cellrand(sid, 24)
    base = ramp(r1, [0x4A463E, 0x6A645A, 0x7E766A, 0x8A8070])
    base = np.where((r2 < 0.25)[..., None], lerp(base, hx(0x8A7254), 0.45), np.where((r2 > 0.8)[..., None], lerp(base, hx(0x5E6066), 0.45), base))
    # Woelbung und Licht: Rand rechts oben hell, links unten dunkel
    sx = np.gradient(edge, axis=1); sy = np.gradient(edge, axis=0)
    light = sat(0.5 - (sx * 0.6 - sy * 0.75) * 9.0)
    dome = ss(0.0, 0.25, edge)
    c = base * (0.62 + 0.38 * dome[..., None]) * (0.75 + 0.5 * light[..., None])
    c *= (0.88 + 0.24 * pnoise(n, 110, 25))[..., None]
    c = lerp(c, c * 1.12, ss(0.45, 0.7, fbm(n, 2, 26))[..., None])                     # ausgetretene Spur
    joint = 1 - ss(0.02, 0.06, edge)
    moss = ss(0.55, 0.68, fbm(n, 7, 27))
    jc = lerp(hx(0x3A3024), hx(0x34442A), moss[..., None])
    miss = (r3 < 1 / 37)[..., None]
    c = np.where(miss, lerp(hx(0x4A3E2E), hx(0x4A5A2E), moss[..., None] * 0.8), c)
    c = lerp(c, jc, joint[..., None])
    rgb, a = strokes(n, 2200, 28, (4, 9), (1, 2), [hx(0x3E5228), hx(0x56683A)], alpha=(0.5, 0.9), mask=(joint * moss)); c = over(c, rgb, a)
    save('pflaster', c)

# ------------------------------------------------------------------ Waende (Wiederholung 2 m)
def putz():
    n = 1024
    t = fbm(n, 5, 31) * 0.7 + pnoise(n, 70, 32) * 0.3
    c = lerp(hx(0x7A705E), hx(0x9E9480), t[..., None])
    c *= (0.9 + 0.2 * pnoise(n, 160, 33))[..., None]                                   # Kellenspuren, Koernung
    rs = np.repeat(np.random.default_rng(35).random((1, n)), n, 0)                     # Regenspuren: senkrechte Streifen
    rs = Image.fromarray((rs * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.5)); rs = np.asarray(rs).astype(np.float32) / 255
    c = lerp(c, c * 0.72, (ss(0.6, 0.9, rs) * ss(0.35, 0.7, pnoise2(n, 30, 3, 36)))[..., None])
    c = lerp(c, hx(0x6A604E), (ss(0.58, 0.75, fbm(n, 6, 37)) * 0.55)[..., None])      # Flecken
    f = fbm(n, 5, 38)
    hole = ss(0.68, 0.70, f)                                                           # abgefallener Putz: Flechtwerk
    yy, xx = np.mgrid[0:n, 0:n].astype(np.float32)
    rod = 0.5 + 0.5 * np.sin(yy / n * 2 * math.pi * 40 + np.sin(xx / n * 2 * math.pi * 12) * 1.6)
    stake = ss(0.9, 0.97, 0.5 + 0.5 * np.sin(xx / n * 2 * math.pi * 12))
    wc = lerp(hx(0x2A1E14), hx(0x6A5438), rod[..., None]); wc = lerp(wc, hx(0x3A2C1E), stake[..., None])
    c = lerp(c, wc, hole[..., None])
    rim = sat(ss(0.65, 0.68, f) - hole)
    c = lerp(c, c * 0.55, (rim * 0.9)[..., None])
    rgb, a = strokes(n, 80, 39, (20, 70), (1, 2), [hx(0x4A4236)], lean=(-0.8, 0.8), alpha=(0.5, 0.8)); c = over(c, rgb, a)   # Risse
    save('putz', c)

def faser(n, cols, seed, lines=60):
    """Holzfaser laengs x: gestreckt, mit dunklen Fasern und Rissen"""
    t = 0.45 * pnoise2(n, 3, lines, seed) + 0.3 * pnoise2(n, 8, lines * 3, seed + 1) + 0.25 * pnoise2(n, 2, 12, seed + 2)
    c = ramp(t, cols)
    rgb, a = strokes(n, int(n * 1.6), seed + 3, (n * 0.08, n * 0.3), (1, 2), [hx(cols[0])], lean=(-0.04, 0.04), alpha=(0.3, 0.7), vertical=False); c = over(c, rgb, a)
    rgb, a = strokes(n, int(n * 0.5), seed + 4, (n * 0.05, n * 0.2), (1, 1), [hx(cols[-1])], lean=(-0.04, 0.04), alpha=(0.2, 0.45), vertical=False); c = over(c, rgb, a)
    return c

def holz(name, n, cols, seed, knots=True, cracks=8):
    c = faser(n, cols, seed)
    if knots:
        rng = np.random.default_rng(seed + 5)
        img = Image.new('RGBA', (n, n), (0, 0, 0, 0)); d = ImageDraw.Draw(img)
        for _ in range(5):
            x, y, r = rng.random() * n, rng.random() * n, rng.uniform(5, 10) * n / 512
            for s in range(4):
                rr = r * (1 + s * 0.7); col = tuple(int(255 * v * (0.5 + 0.12 * s)) for v in hx(cols[0])) + (200 - s * 40,)
                d.ellipse([x - rr * 2.2, y - rr, x + rr * 2.2, y + rr], outline=col, width=2)
            d.ellipse([x - r, y - r * 0.6, x + r, y + r * 0.6], fill=tuple(int(255 * v * 0.4) for v in hx(cols[0])) + (230,))
        a = np.asarray(img).astype(np.float32) / 255; c = over(c, a[..., :3], a[..., 3:4])
    rgb, a = strokes(n, cracks, seed + 6, (n * 0.1, n * 0.35), (2, 3), [hx(0x0E0A08)], lean=(-0.02, 0.02), alpha=(0.7, 0.95), vertical=False); c = over(c, rgb, a)
    save(name, c)

def bretter():
    n = 1024; rows = 10                                                              # 2 m / 10 = 20 cm je Brett
    c = faser(n, [0x2A2018, 0x4A3A2C, 0x6A5640], 41, lines=80)
    y, x = np.mgrid[0:n, 0:n].astype(np.float32)
    k = np.floor(y * rows / n).astype(int); f = y * rows / n - k
    rng = np.random.default_rng(42)
    off = rng.random(rows + 1).astype(np.float32)
    seg = (x / n * 2 + off[k]) ; sj = np.floor(seg).astype(int); sf = seg - sj
    r = cellrand(k * 10 + sj % 2, 43)
    c = c * (0.72 + 0.5 * r)[..., None]
    gap = 1 - ss(0.0, 0.05, np.minimum(f, 1 - f))
    joint = 1 - ss(0.0, 0.006, np.minimum(sf, 1 - sf))                                # Stoss
    c = lerp(c, hx(0x100C0A), (np.maximum(gap, joint) * 0.92)[..., None])
    c = lerp(c, c * 1.3, (ss(0.05, 0.1, f) * ss(0.22, 0.1, f) * 0.6)[..., None])
    c = lerp(c, c * 0.6, ss(0.6, 0.95, f)[..., None] * 0.5)
    rgb, a = blots(n, 50, 44, (2.5, 3.5), [hx(0x2A2622)], alpha=(0.8, 1.0)); c = over(c, rgb, a)
    save('bretter', c)

def feldstein():
    """Bruchsteinmauer: flache Steine in Lagen (gestreckte Zellen), helle Moertelfugen"""
    n = 1024; cells = 5                                                              # 2 m / 5 = 40 cm breit
    d1, d2, idc = voronoi(n, cells * 2, 51, 0.55, sy=2.4)
    edge = (d2 - d1)
    r1 = cellrand(idc, 52); r2 = cellrand(idc, 53)
    base = ramp(r1 * 0.75 + 0.25 * r2, [0x4A453C, 0x6E6A60, 0x8A8478, 0x8A7A64])
    gx = np.gradient(edge, axis=1); gy = np.gradient(edge, axis=0)
    light = sat(0.5 - (gx * 0.6 - gy * 0.75) * 25)
    dome = ss(0.0, 0.25, edge)
    c = base * (0.6 + 0.4 * dome[..., None]) * (0.78 + 0.45 * light[..., None])
    c *= (0.86 + 0.28 * pnoise(n, 140, 54))[..., None]
    rgb, a = strokes(n, 260, 56, (8, 24), (1, 2), [hx(0x2E2A24)], lean=(-1.5, 1.5), alpha=(0.4, 0.7), vertical=False); c = over(c, rgb, a)   # Bruchkanten
    lich = ss(0.62, 0.7, pnoise(n, 50, 55)) * (r2 > 0.55)
    c = lerp(c, hx(0x9A9A6A), (lich * 0.55)[..., None])                               # Flechten (klein)
    joint = 1 - ss(0.03, 0.08, edge)
    mortar = lerp(hx(0x4E483E), hx(0x6A6252), pnoise(n, 90, 57)[..., None])
    c = lerp(c, mortar * 0.8, joint[..., None])
    c = lerp(c, hx(0x1E1A16), (1 - ss(0.0, 0.02, edge))[..., None] * 0.8)
    save('feldstein', c)

def roofrows(name, n, rows, cols, seed, moss=None, mossamt=0.35, edge_dark=0.6, slip=0.0, per_k=1.6, round_=False):
    """Dachdeckung: Reihen (v), je Reihe versetzte Platten (u); Unterkante dunkel (Schatten der Platte)"""
    y, x = np.mgrid[0:n, 0:n].astype(np.float32)
    v = y * rows / n; k = np.floor(v).astype(int); fv = v - k
    rng = np.random.default_rng(seed)
    per = int(rows * per_k)
    sh = rng.random(rows + 2).astype(np.float32)
    u = x * per / n + (k % 2) * 0.5 + sh[k % (rows + 2)] * 0.2
    if slip > 0: u = u + (pnoise2(n, per, rows, seed + 7) - 0.5) * slip
    j = np.floor(u).astype(int); fu = u - j
    idc = (k % rows) * 1000 + (j % per)
    r = cellrand(idc, seed + 1)
    c = ramp(r * 0.8 + 0.2 * pnoise(n, 40, seed + 2), cols)
    c *= (0.86 + 0.28 * pnoise2(n, per * 6, rows * 2, seed + 3))[..., None]
    fvv = fv
    if round_:                                                                       # Biberschwanz: Unterkante rund
        fvv = fv + 0.25 * (1 - np.sqrt(sat(1 - (2 * fu - 1) ** 2)))
    c = c * (0.6 + 0.4 * ss(0.0, 0.45, fvv))[..., None]                                # oben ueberdeckt
    bot = ss(0.92, 1.0, fvv) if not round_ else ss(0.98, 1.08, fvv)
    c = lerp(c, c * 0.25, (bot * edge_dark)[..., None])
    side = 1 - ss(0.0, 0.035, np.minimum(fu, 1 - fu))
    c = lerp(c, c * 0.4, (side * 0.85)[..., None])
    hi = ss(0.85, 0.95, fvv) * (1 - bot)
    c = lerp(c, c * 1.25, (hi * 0.5)[..., None])                                       # Licht auf der Plattenkante
    if moss is not None:
        m = ss(0.66, 0.74, fbm(n, 10, seed + 4)) * ss(0.3, 0.9, fv)                     # Moos sitzt am unteren Plattenrand
        rgb, a = blots(n, 500, seed + 5, (2, 5), [hx(moss), hx(moss) * 0.8], alpha=(0.6, 0.9), mask=m); c = over(c, rgb, a * mossamt * 2)
    save(name, c)

def stroh():
    n = 1024; rows = 6                                                               # 2 m / 6 = 33 cm Lagen
    c = lerp(hx(0x4A3E2A), hx(0x7A6C4E), fbm(n, 6, 61)[..., None])
    y, x = np.mgrid[0:n, 0:n].astype(np.float32)
    v = (y + 6 * np.sin(x / 23.0) + 18 * (pnoise(n, 10, 65) - 0.5)) * rows / n
    fv = v - np.floor(v)
    band = ss(0.0, 0.7, fv)
    for seed, cnt, cols, L, al in ((62, 22000, [hx(0x9A8A62), hx(0xA8986C), hx(0x7A6C4E)], (20, 50), (0.4, 0.85)),
                                   (63, 14000, [hx(0x3E3424), hx(0x4E4230)], (16, 40), (0.35, 0.7)),
                                   (64, 7000, [hx(0xC0B080)], (12, 34), (0.4, 0.8))):
        rgb, a = strokes(n, cnt, seed, L, (1.2, 2.4), cols, lean=(-0.08, 0.08), alpha=al); c = over(c, rgb, a)
    c = c * (0.5 + 0.5 * band)[..., None]                                               # Lagenkante: Schatten der oberen Lage
    rgb, a = strokes(n, 3000, 66, (6, 14), (1, 2), [hx(0x2A2218)], lean=(-0.15, 0.15), alpha=(0.6, 0.9), mask=ss(0.97, 0.9, fv) * (fv > 0.85)); c = over(c, rgb, a)
    save('stroh', c)

def rinde():
    """Eichenrinde: senkrechte Furchen (dunkel), Grate dazwischen hell, Licht rechts"""
    n = 512
    d1, d2, idc = voronoi(n, 10, 71, 0.8, sy=0.22)
    edge = d2 - d1
    r = cellrand(idc, 72)
    ridge = ss(0.0, 0.3, edge)
    gx = np.gradient(edge, axis=1)
    light = sat(0.5 + gx * 30)
    t = 0.25 + 0.5 * ridge * (0.6 + 0.4 * r) + 0.25 * (light - 0.5)
    c = ramp(t, [0x120E0C, 0x2E241C, 0x52443A, 0x7C6650])
    c *= (0.85 + 0.3 * pnoise2(n, 30, 6, 73))[..., None]
    m = ss(0.62, 0.72, fbm(n, 4, 74)) * ridge
    c = lerp(c, hx(0x4A5A2E), (m * 0.5)[..., None])
    save('rinde', c)

def laub():
    """Blattbueschel: Blaetter in Gruppen, hell oben rechts, dunkel unten links"""
    n = 1024
    rng = np.random.default_rng(81)
    img = Image.new('RGB', (n, n), (40, 52, 30)); d = ImageDraw.Draw(img)
    for _ in range(1400):
        cx, cy = rng.random() * n, rng.random() * n
        for _ in range(9):
            x, y = cx + rng.normal(0, 14), cy + rng.normal(0, 12)
            r = rng.uniform(9, 17); a = rng.uniform(0, math.pi)
            lit = sat(0.5 + ((x - cx) * 0.6 - (y - cy) * 0.8) / 30 + rng.normal(0, 0.15))
            col = tuple(int(255 * v) for v in ramp(np.array([lit]), [0x1E2818, 0x46522E, 0x7A8A52, 0xA8B47A])[0])
            dx, dy = math.cos(a) * r, math.sin(a) * r
            for ox in (-n, 0, n):
                for oy in (-n, 0, n):
                    X, Y = x + ox, y + oy
                    if -30 < X < n + 30 and -30 < Y < n + 30:
                        d.polygon([(X - dx, Y - dy), (X - dy * 0.4, Y + dx * 0.4), (X + dx, Y + dy), (X + dy * 0.4, Y - dx * 0.4)], fill=col)
    c = np.asarray(img).astype(np.float32) / 255
    c = c / max(1e-3, c.mean()) * 0.45
    save('laub', c)

def stoff():
    """Leinen: feine Kett- und Schussfaeden, Falten, Schmutz; hell (wird gefaerbt)"""
    n = 512
    warp = pnoise2(n, 256, 2, 91); weft = pnoise2(n, 2, 256, 92)
    c = np.full((n, n, 3), 0.86, np.float32) * (0.82 + 0.1 * warp + 0.1 * weft)[..., None]
    c *= (0.8 + 0.3 * pnoise2(n, 3, 8, 93))[..., None]                                  # Falten
    c = lerp(c, c * 0.72, (ss(0.6, 0.78, fbm(n, 4, 94)) * 0.6)[..., None])            # Flecken
    save('stoff', c)

def heu():
    n = 512
    c = lerp(hx(0x7A6038), hx(0xB89C5E), fbm(n, 5, 101)[..., None])
    for seed, cnt, cols in ((102, 7000, [hx(0xD8C07A), hx(0xB09858)]), (103, 6000, [hx(0x5A4628), hx(0x6A5434)]), (104, 2500, [hx(0xE8D490)])):
        rgb, a = strokes(n, cnt, seed, (10, 30), (1, 2), cols, lean=(-1.0, 1.0), alpha=(0.45, 0.9)); c = over(c, rgb, a)
    c *= (0.75 + 0.35 * fbm(n, 6, 105))[..., None]
    save('heu', c)

def halme():
    """Grasbueschel fuer die Wiese: Halme auf Durchsicht (Alpha), unten dunkel, oben weich"""
    n = 512
    img = Image.new('RGBA', (n, n), (0, 0, 0, 0)); d = ImageDraw.Draw(img)
    rng = np.random.default_rng(111)
    for _ in range(90):
        x0 = n * 0.5 + rng.normal(0, 0.14) * n; h = rng.uniform(0.35, 0.97) * n; lean = (x0 - n * 0.5) * 1.2 + rng.uniform(-0.15, 0.15) * n
        t = rng.random()
        top = tuple(int(255 * v) for v in ramp(np.array([t]), [0x3E5228, 0x6A7E44, 0x9AAA62])[0])
        pts = [(x0 + lean * (s / 12) ** 2, n - h * s / 12) for s in range(13)]
        for s in range(12):
            k = s / 12
            col = tuple(int(top[i] * (0.4 + 0.6 * k)) for i in range(3)) + (255,)
            d.line([pts[s], pts[s + 1]], fill=col, width=max(1, int(7 * (1 - k)) + 1))
    img = img.resize((256, 256), Image.LANCZOS)
    a = np.asarray(img).astype(np.float32) / 255
    save('halme', a[..., :3] / np.maximum(a[..., 3:4], 1e-3) * (a[..., 3:4] > 0), a[..., 3])

def weiss():
    save('weiss', np.full((8, 8, 3), 1.0, np.float32))

if __name__ == '__main__':
    for f in (gras, erde, pflaster, putz, bretter, feldstein, stroh, rinde, laub, stoff, heu, halme, weiss): f()
    holz('holz', 512, [0x3A2A1C, 0x5A4430, 0x7A5E40], 121)
    holz('balken', 512, [0x1A120C, 0x3E2E22, 0x5A4632], 122, cracks=14)
    roofrows('schindel', 1024, 16, [0x1E1812, 0x4A3E32, 0x6E6252], 131, moss=0x3A4622)          # 2 m / 16 = 12.5 cm
    roofrows('schiefer', 1024, 12, [0x26282C, 0x3C3E44, 0x52545A], 132, moss=0x6A6A4A, slip=0.25, per_k=1.3)
    roofrows('ziegel', 1024, 14, [0x4A2016, 0x6E3A28, 0x8A5038], 133, moss=0x6A6A4A, round_=True, per_k=2.2)
