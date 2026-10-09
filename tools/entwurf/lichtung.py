"""Prototype: the clearing of the Whisperwood in top-down view, drawn the new way.

Made from the real map rows of the forest. Double resolution (64 art pixels per tile instead of 32),
no visible grid, a curved path, trees of several kinds with shadows from the sun, light and line of
sight at night, a few things off the path to discover.
"""
import math
import sys

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as nd

ROWS = [
    "TTTTTTTTXXEXXTTTTTTT",
    "TTT,,,,..=..S.,,,TTT",
    "TT,,,,,..=...,,OO,TT",
    "TT,,TT,..=..TT,,,,TT",
    "TT,,TT...=...T,,C,TT",
    "TTTTTT..==...TTTTTTT",
    "TTfff..==.....TTTTTT",
    "TTfr..==..r.....TTTT",
    "TTff..=........,,,TT",
    "TT,,,.=....F...,,,TT",
    "TT,,,.=......=======",
    "TT,,,.==.......,,,TT",
    "TTTT...=...TTT,,TTTT",
    "TT~~~..=..,,,,,,,,TT",
    "TT~~~~.=..,,,,,,,,TT",
    "TT~~~~.==.,,TT,,C,TT",
    "TT~~~...=.,,TT,,,,TT",
    "TTT.....=....TTTTTTT",
]
X0, Y0, NX, NY = 1, 1, 18, 16          # the part of the map shown
S = 64                                  # art pixels per tile
W, H = NX * S, NY * S
OUT = sys.argv[1] if len(sys.argv) > 1 else "."

rng = np.random.default_rng(7)


def tile(x, y):
    if 0 <= y < len(ROWS) and 0 <= x < len(ROWS[0]):
        return ROWS[y][x]
    return "T"


def hsh(*a):
    n = 0
    for v in a:
        n = (n * 374761393 + int(v) * 668265263 + 1442695041) & 0xFFFFFFFF
        n = ((n ^ (n >> 13)) * 1274126177) & 0xFFFFFFFF
    return (n ^ (n >> 16)) & 0x7FFFFFFF


def rnd(*a):
    return (hsh(*a) % 10000) / 10000.0


# ------------------------------------------------------------------ noise

def value_noise(w, h, cell, seed):
    gw, gh = w // cell + 3, h // cell + 3
    g = np.random.default_rng(seed).random((gh, gw))
    ys = np.arange(h) / cell
    xs = np.arange(w) / cell
    iy = ys.astype(int); ix = xs.astype(int)
    fy = ys - iy; fx = xs - ix
    fy = fy * fy * (3 - 2 * fy); fx = fx * fx * (3 - 2 * fx)
    a = g[iy][:, ix]; b = g[iy][:, ix + 1]; c = g[iy + 1][:, ix]; d = g[iy + 1][:, ix + 1]
    top = a * (1 - fx) + b * fx
    bot = c * (1 - fx) + d * fx
    return top * (1 - fy[:, None]) + bot * fy[:, None]


def fbm(w, h, cell, seed, octaves=4):
    out = np.zeros((h, w)); amp = 1.0; tot = 0
    for o in range(octaves):
        out += value_noise(w, h, max(2, cell >> o), seed + o * 17) * amp
        tot += amp; amp *= 0.5
    return out / tot


def col(hexv):
    return np.array([(hexv >> 16) & 255, (hexv >> 8) & 255, hexv & 255], dtype=float)


def lerp(a, b, t):
    t = np.clip(t, 0, 1)[..., None] if np.ndim(t) else t
    return a + (b - a) * t


# ------------------------------------------------------------------ masks from the tiles

def mask(chars, soft=0.0, wobble=0.0, seed=1):
    m = np.zeros((H, W))
    for ty in range(NY):
        for tx in range(NX):
            if tile(X0 + tx, Y0 + ty) in chars:
                m[ty * S:(ty + 1) * S, tx * S:(tx + 1) * S] = 1
    if soft:
        m = nd.gaussian_filter(m, soft)
    if wobble:
        m = m + (fbm(W, H, 48, seed) - 0.5) * wobble
    return m


# ------------------------------------------------------------------ the path as a curve

def path_points():
    pts = []
    for y in range(len(ROWS)):
        xs = [x for x in range(len(ROWS[0])) if ROWS[y][x] in "=E" and not (y == 10 and x >= 13)]
        if xs:
            pts.append(((sum(xs) / len(xs) - X0 + 0.5) * S, (y - Y0 + 0.5) * S))
    # a gentle average, so the tile staircase becomes a bend
    sm = []
    for i, p in enumerate(pts):
        a = pts[max(i - 1, 0)]; b = pts[min(i + 1, len(pts) - 1)]
        sm.append(((a[0] + 2 * p[0] + b[0]) / 4, p[1]))
    return sm


def catmull(pts, n=12):
    out = []
    for i in range(len(pts) - 1):
        p0 = pts[max(i - 1, 0)]; p1 = pts[i]; p2 = pts[i + 1]; p3 = pts[min(i + 2, len(pts) - 1)]
        for k in range(n):
            t = k / n; t2 = t * t; t3 = t2 * t
            x = 0.5 * ((2 * p1[0]) + (-p0[0] + p2[0]) * t + (2 * p0[0] - 5 * p1[0] + 4 * p2[0] - p3[0]) * t2 + (-p0[0] + 3 * p1[0] - 3 * p2[0] + p3[0]) * t3)
            y = 0.5 * ((2 * p1[1]) + (-p0[1] + p2[1]) * t + (2 * p0[1] - 5 * p1[1] + 4 * p2[1] - p3[1]) * t2 + (-p0[1] + 3 * p1[1] - 3 * p2[1] + p3[1]) * t3)
            out.append((x, y))
    out.append(pts[-1])
    return out


def curve_distance(curves):
    """Distance in pixels from each pixel to the nearest curve, and the side (for ruts)."""
    img = Image.new("L", (W, H), 255)
    d = ImageDraw.Draw(img)
    for c in curves:
        d.line(c, fill=0, width=2)
    return nd.distance_transform_edt(np.array(img) > 0)


# ------------------------------------------------------------------ paint

def paint(night=False):
    yy, xx = np.mgrid[0:H, 0:W]
    # ground: forest floor of moss, old leaves and bare earth
    n1 = fbm(W, H, 96, 1); n2 = fbm(W, H, 24, 2); n3 = fbm(W, H, 6, 3, 2)
    moss_d, moss_l = col(0x2C3A20), col(0x56683A)
    earth_d, earth_l = col(0x3A2E22), col(0x6A5840)
    leaf = col(0x5E4426)
    g = lerp(moss_d, moss_l, n2 * 0.9 + n3 * 0.35 - 0.1)
    earthy = np.clip((n1 - 0.55) * 4, 0, 1)
    g = lerp(g, lerp(earth_d, earth_l, n3), earthy * 0.7)
    litter = (n3 > 0.68) & (n2 > 0.45)
    g[litter] = lerp(g[litter], leaf, 0.55)
    # the clearing is lighter grass, the edge of the wood darker
    trees = mask("T", soft=26)
    g = g * (1 - trees[..., None] * 0.35)

    # tall grass: dense, darker, blades leaning in the wind
    tall = (mask(",OC", soft=26, seed=4) + (fbm(W, H, 40, 4) - 0.5) * 0.9 + (fbm(W, H, 10, 5) - 0.5) * 0.35) > 0.55
    blades = np.zeros((H, W))
    im = Image.new("L", (W, H), 0); d = ImageDraw.Draw(im)
    for i in range(26000):
        x = rng.integers(0, W); y = rng.integers(0, H)
        if not tall[y, x]:
            continue
        L = rng.integers(7, 15); lean = rng.normal(3, 1.5)
        d.line([(x, y), (x + lean, y - L)], fill=int(120 + rng.integers(0, 135)), width=1)
    blades = np.array(im) / 255.0
    tg = lerp(col(0x1E2A16), col(0x6E7A44), blades)
    g = np.where((tall & (blades > 0))[..., None], tg, np.where(tall[..., None], lerp(g, col(0x1A2412), 0.45), g))

    # short grass all over the open ground: tufts in light and dark
    im2 = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d2 = ImageDraw.Draw(im2)
    for i in range(14000):
        x = int(rng.integers(0, W)); y = int(rng.integers(0, H))
        if tall[y, x]:
            continue
        L = int(rng.integers(3, 7)); c = (96, 112, 62, 150) if rng.random() < 0.5 else (26, 34, 20, 150)
        d2.line([(x, y), (x + rng.normal(1, 1), y - L)], fill=c, width=1)
    t2 = np.array(im2).astype(float)
    a2 = t2[..., 3:4] / 255
    g = g * (1 - a2) + t2[..., :3] * a2

    # flowers: few, pale and small
    fl = (mask("f", soft=18, seed=6) + (fbm(W, H, 20, 6) - 0.5) * 0.7) > 0.5
    for i in range(500):
        x = rng.integers(0, W); y = rng.integers(0, H)
        if fl[y, x]:
            c = [col(0xB8A8C0), col(0x9A5A50), col(0xC8B88A)][i % 3]
            g[y:y + 2, x:x + 2] = c

    # the path: trodden earth along a curve, frayed edges, two ruts, stones
    pts = path_points()
    main = catmull(pts)
    side = catmull([(10.5 * S - X0 * S + 1.5 * S, (10 - Y0 + 0.5) * S), (13.2 * S, (10 - Y0 + 0.55) * S), (W + S, (10 - Y0 + 0.4) * S)], 16)
    dist = curve_distance([main, side])
    edge = 17 + (fbm(W, H, 20, 9) - 0.5) * 16
    p = np.clip((edge - dist) / 5, 0, 1)
    pathc = lerp(col(0x4A3A2A), col(0x7A6448), n3 * 0.8 + n2 * 0.3)
    rut = np.abs(np.abs(dist - 7.5)) < 1.6
    pathc[rut] = lerp(pathc[rut], col(0x2E241A), 0.55)
    g = lerp(g, pathc, p)
    # grass creeping in at the edges
    creep = (p > 0.1) & (p < 0.9) & (n3 > 0.55)
    g[creep] = lerp(g[creep], col(0x3A4A26), 0.6)
    for i in range(700):
        x = rng.integers(0, W); y = rng.integers(0, H)
        if p[y, x] > 0.6:
            r = rng.integers(1, 3)
            g[y:y + r + 1, x:x + r + 2] = col(0x8A7C6A) if rng.random() < 0.6 else col(0x5A5048)

    # the pond: dark, deep in the middle, a muddy rim, reeds
    wm = mask("~", soft=14, wobble=0.55, seed=11)
    water = wm > 0.5
    depth = nd.distance_transform_edt(water)
    wc = lerp(col(0x2A3A3C), col(0x0E1A1E), np.clip(depth / 60, 0, 1))
    # long, thin glints of the sky on the water, and the dark mirror of the trees along the bank
    glint = (np.abs(np.sin(yy * 0.35 + fbm(W, H, 30, 12) * 6)) > 0.985) & (fbm(W, H, 16, 13) > 0.55) & water
    wc[glint] = lerp(wc[glint], col(0x7A8E90), 0.45)
    bank = water & (depth < 26)
    wc[bank] = lerp(wc[bank], col(0x0A1210), 0.35 * (1 - depth[bank] / 26)[..., None] if False else 0.25)
    rim = (wm > 0.36) & ~water
    g[rim] = lerp(g[rim], col(0x2A2218), 0.7)
    g = np.where(water[..., None], wc, g)

    return g, water, tall, p


def soft_ellipse(arr, cx, cy, rx, ry, k, blur=0):
    y0, y1 = int(max(0, cy - ry * 2)), int(min(H, cy + ry * 2))
    x0, x1 = int(max(0, cx - rx * 2)), int(min(W, cx + rx * 2))
    if y0 >= y1 or x0 >= x1:
        return
    yy, xx = np.mgrid[y0:y1, x0:x1]
    d = ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2
    arr[y0:y1, x0:x1] = np.maximum(arr[y0:y1, x0:x1], k * np.clip(1.6 - d, 0, 1) ** 1.2)


class Sprite:
    def __init__(self, img, x, y, sort):
        self.img, self.x, self.y, self.sort = img, x, y, sort


def _crown(im, cx, cy, r, ramp, seed, squash=0.85):
    """A leafy crown seen at a slant: a lumpy dome, lit from the upper left, leaf texture."""
    h, w = im.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w]
    nx = (xx - cx) / r; ny = (yy - cy) / (r * squash)
    ang = np.arctan2(ny, nx)
    rr = np.random.default_rng(seed)
    lump = sum(np.cos(ang * k + rr.random() * 6) * (0.09 / (1 + k * 0.25)) for k in range(3, 9))
    leafn = value_noise(w, h, 3, seed) * 0.6 + value_noise(w, h, 7, seed + 1) * 0.4
    dd = np.sqrt(nx * nx + ny * ny) - lump - (leafn - 0.5) * 0.18
    inside = dd < 1
    dome = np.sqrt(np.clip(1 - dd * dd, 0, 1))
    t = 0.42 + dome * 0.32 - (nx * 0.42 + ny * 0.5) + (leafn - 0.5) * 0.65
    # the underside of the crown lies in its own shadow
    t = t - np.clip(ny - 0.2, 0, 1) * 0.55
    idx = np.clip(((1 - np.clip(t, 0, 1)) * (len(ramp) - 0.01)).astype(int), 0, len(ramp) - 1)
    pal = np.array(ramp)[idx]
    im[inside, :3] = pal[inside]; im[inside, 3] = 1
    return im


def _trunk(im, bx, by, top, width, seed, bark=(0x4A3A2E, 0x2A221C, 0x6A5644)):
    h, w = im.shape[:2]
    rr = np.random.default_rng(seed)
    for y in range(int(top), int(by)):
        f = (y - top) / max(1, by - top)
        half = width / 2 * (1 + f * f * 0.9)
        sway = math.sin(f * 2.4 + seed) * 2
        for x in range(int(bx - half + sway), int(bx + half + sway) + 1):
            if 0 <= x < w and 0 <= y < h:
                e = (x - (bx + sway)) / max(1, half)
                c = col(bark[2]) if e < -0.35 else col(bark[1]) if e > 0.35 else col(bark[0])
                if rr.random() < 0.18:
                    c = c * 0.8
                im[y, x, :3] = c; im[y, x, 3] = 1
    # roots spreading at the foot
    for k in range(4):
        a = -0.4 + k * 0.27 * math.pi + rr.random() * 0.3
        for i in range(int(width * 1.3)):
            x = int(bx + math.cos(a) * i * 1.0); y = int(by - 2 + abs(math.sin(a)) * i * 0.25)
            if 0 <= x < w and 0 <= y < h:
                im[y, x, :3] = col(bark[1]); im[y, x, 3] = 1


LEAF = [col(0x66733F), col(0x4A5A33), col(0x37472A), col(0x28361F), col(0x1A2414), col(0x0F160C)]
LEAF_DEEP = [col(0x5E6E40), col(0x445632), col(0x324226), col(0x22301A), col(0x161E10), col(0x0C120A)]


def leafy_tree(seed, r, deep=False):
    """Oak-like: a trunk with roots and a broad crown above it. Anchor: bottom middle."""
    w = int(r * 2.5); h = int(r * 3.5)
    im = np.zeros((h, w, 4))
    base = h - 4
    crown_cy = h - r * 2.15
    _trunk(im, w / 2, base, crown_cy, r * 0.22, seed)
    _crown(im, w / 2, crown_cy, r, LEAF_DEEP if deep else LEAF, seed)
    return im


def pine_tree(seed, r):
    """A spruce in tiers, dark and pointed. Anchor: bottom middle."""
    w = int(r * 2.0); h = int(r * 4.0)
    im = np.zeros((h, w, 4))
    base = h - 4
    _trunk(im, w / 2, base, base - r * 0.7, r * 0.16, seed)
    rr = np.random.default_rng(seed)
    ramp = [col(0x4E6A52), col(0x36503E), col(0x24382C), col(0x16241C), col(0x0C1610)]
    cx = w / 2
    tiers = 5
    for k in range(tiers):
        f = k / (tiers - 1)
        ty = base - r * 0.55 - (1 - f) * 0.0 - k * r * 0.62
        half = r * (0.95 - f * 0.6)
        hh = r * 0.95
        yy, xx = np.mgrid[0:h, 0:w]
        # a drooping tier: wide at the bottom, ragged edge
        rel = (ty - yy) / hh
        edge = half * (1 - rel) * (1 + 0.12 * np.sin(xx * 0.9 + k * 3))
        inside = (rel >= 0) & (rel <= 1) & (np.abs(xx - cx) <= edge)
        t = 0.55 - (xx - cx) / (half * 2.2) + rel * 0.25 - (yy > ty - hh * 0.25) * 0.25 + (value_noise(w, h, 3, seed + k) - 0.5) * 0.5
        idx = np.clip(((1 - np.clip(t, 0, 1)) * 4.99).astype(int), 0, 4)
        pal = np.array(ramp)[idx]
        im[inside, :3] = pal[inside]; im[inside, 3] = 1
    return im


def dead_tree(seed, r):
    """A dead, grey tree with bare branches reaching up. Anchor: bottom middle."""
    w = int(r * 2.6); h = int(r * 3.6)
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rr = np.random.default_rng(seed)

    def branch(x, y, a, L, wd):
        if L < 5 or wd < 1:
            return
        x2 = x + math.cos(a) * L; y2 = y + math.sin(a) * L
        d.line([(x, y), (x2, y2)], fill=(52, 46, 42, 255), width=int(wd))
        d.line([(x - wd * 0.25, y), (x2 - wd * 0.25, y2)], fill=(104, 96, 86, 255), width=max(1, int(wd / 3)))
        for k in range(2):
            branch(x2, y2, a + rr.normal(0, 0.55), L * 0.66, wd * 0.6)
    branch(w / 2, h - 4, -math.pi / 2, r * 1.2, r * 0.24)
    return np.array(img).astype(float) / [1, 1, 1, 255]




def build(night):
    g, water, tall, pathm = paint(night)
    shadow = np.zeros((H, W))
    sprites = []
    sun = (0.55, 0.45) if not night else (0.0, 0.0)    # shadows fall to the lower right in daylight
    occl = np.zeros((NY + 2, NX + 2), bool)               # what blocks sight, per tile

    # trees: one or two per tree tile, jittered, several kinds
    for ty in range(-1, NY + 1):
        for tx in range(-1, NX + 1):
            mx, my = X0 + tx, Y0 + ty
            if tile(mx, my) != "T":
                continue
            occl[ty + 1, tx + 1] = True
            for k in range(1 + (hsh(mx, my, 1) % 3 == 0)):
                kind = hsh(mx, my, k, 2) % 9
                r = S * (0.62 + rnd(mx, my, k, 3) * 0.45)
                px = (tx + 0.5) * S + (rnd(mx, my, k, 4) - 0.5) * S * 0.7
                py = (ty + 0.5) * S + (rnd(mx, my, k, 5) - 0.5) * S * 0.7
                if kind < 2:
                    img = pine_tree(hsh(mx, my, k), r * 0.85)
                elif kind == 2 and rnd(mx, my, 9) < 0.5:
                    img = dead_tree(hsh(mx, my, k), r * 0.8)
                else:
                    img = leafy_tree(hsh(mx, my, k), r)
                py += S * 0.3
                sprites.append(Sprite(img, px - img.shape[1] / 2, py - img.shape[0] + 4, py))
                # the shadow of a crown lies on the ground beside its foot, away from the sun
                soft_ellipse(shadow, px + r * 0.9 * (1 if not night else 0), py - r * 0.1, r * 1.0, r * 0.55, 0.7)
    # rocks and logs
    things = []
    for ty in range(NY):
        for tx in range(NX):
            c = tile(X0 + tx, Y0 + ty)
            px, py = (tx + 0.5) * S, (ty + 0.5) * S
            if c == "r":
                things.append(("rock", px, py))
                soft_ellipse(shadow, px + 12, py + 10, 26, 18, 0.6)
            elif c == "O":
                things.append(("log", px, py, tile(X0 + tx - 1, Y0 + ty) == "O"))
            elif c == "C":
                things.append(("chest", px, py))
            elif c == "S":
                things.append(("sign", px, py))
            elif c == "F":
                things.append(("fire", px, py))
    for ty in range(NY):
        for tx in range(NX):
            mx, my = X0 + tx, Y0 + ty
            c = tile(mx, my)
            if c not in ".,f":
                continue
            if any(tile(mx + 1, my) == "=" or tile(mx - 1, my) == "=" for _ in [0]) and rnd(mx, my, 40) < 0.7:
                continue
            near = sum(tile(mx + dx, my + dy) == "T" for dx in (-1, 0, 1) for dy in (-1, 0, 1))
            for k in range(3):
                if rnd(mx, my, k, 41) > 0.08 + near * 0.07:
                    continue
                px = (tx + rnd(mx, my, k, 42)) * S; py = (ty + rnd(mx, my, k, 43)) * S
                if tile(X0 + int(px // S), Y0 + int(py // S)) in "=F~":
                    continue
                if rnd(mx, my, k, 44) < 0.55:
                    r = S * (0.22 + rnd(mx, my, k, 45) * 0.16)
                    img = np.zeros((int(r * 2.3), int(r * 2.6), 4))
                    _crown(img, img.shape[1] / 2, img.shape[0] - r * 1.05, r, LEAF, hsh(mx, my, k, 46), squash=0.7)
                    sprites.append(Sprite(img, px - img.shape[1] / 2, py - img.shape[0] + 2, py))
                    soft_ellipse(shadow, px + r * 0.6, py - 2, r * 1.0, r * 0.4, 0.6)
                else:
                    things.append(("fern", px, py, hsh(mx, my, k, 47)))
            if rnd(mx, my, 48) < 0.12:
                things.append(("branch", (tx + rnd(mx, my, 49)) * S, (ty + rnd(mx, my, 50)) * S, hsh(mx, my, 51)))
    shadow = nd.gaussian_filter(shadow, 6)
    if not night:
        g = g * (1 - shadow[..., None] * 0.55)
    else:
        g = g * (1 - shadow[..., None] * 0.25)
    return g, sprites, things, occl, water


def blit(canvas, img, x, y):
    h, w = img.shape[:2]
    x, y = int(x), int(y)
    x0, y0 = max(0, x), max(0, y)
    x1, y1 = min(W, x + w), min(H, y + h)
    if x0 >= x1 or y0 >= y1:
        return
    sub = img[y0 - y:y1 - y, x0 - x:x1 - x]
    a = sub[..., 3:4]
    canvas[y0:y1, x0:x1] = canvas[y0:y1, x0:x1] * (1 - a) + sub[..., :3] * a


def draw_things(canvas, things, night):
    im = Image.fromarray(np.clip(canvas, 0, 255).astype(np.uint8))
    d = ImageDraw.Draw(im, "RGBA")
    for t in things:
        kind, px, py = t[0], t[1], t[2]
        if kind == "rock":
            for i, (ox, oy, r) in enumerate([(0, 0, 22), (-14, 8, 13), (15, 6, 11)]):
                d.rounded_rectangle([px + ox - r, py + oy - r * 0.2, px + ox + r, py + oy + r * 0.9], int(r * 0.6), fill=(52, 48, 44))
                d.ellipse([px + ox - r, py + oy - r * 0.8, px + ox + r, py + oy + r * 0.8], fill=(78, 74, 66))
                d.ellipse([px + ox - r * 0.8, py + oy - r * 0.75, px + ox + r * 0.5, py + oy + r * 0.3], fill=(112, 106, 94))
                d.ellipse([px + ox - r * 0.5, py + oy - r * 0.6, px + ox, py + oy - r * 0.1], fill=(140, 132, 116))
                # moss on the north side
                d.chord([px + ox - r, py + oy - r * 0.8, px + ox + r, py + oy + r * 0.8], 200, 330, fill=(62, 80, 40, 200))
        elif kind == "log":
            x0 = px - S * 0.5 if t[3] else px - S * 0.35
            d.rounded_rectangle([x0, py - 11, px + S * 0.5, py + 11], 10, fill=(54, 40, 30))
            d.rounded_rectangle([x0 + 2, py - 10, px + S * 0.5, py - 2], 6, fill=(86, 66, 48))
            for k in range(6):
                mx = x0 + 6 + k * 9
                d.ellipse([mx, py - 12, mx + 9, py - 5], fill=(60, 82, 40, 220))
            if not t[3]:
                d.ellipse([x0 - 4, py - 11, x0 + 14, py + 11], fill=(120, 96, 66))
                d.ellipse([x0 + 1, py - 6, x0 + 9, py + 6], fill=(90, 68, 46))
        elif kind == "fern":
            rr = np.random.default_rng(t[3])
            for k in range(7):
                a = -math.pi * (0.1 + 0.8 * k / 6) + rr.normal(0, 0.1)
                L = 10 + rr.random() * 8
                x2, y2 = px + math.cos(a) * L * 1.3, py + math.sin(a) * L * 0.8
                d.line([(px, py), (x2, y2)], fill=(34, 52, 26), width=3)
                d.line([(px, py - 1), (x2, y2 - 1)], fill=(84, 104, 54), width=1)
        elif kind == "branch":
            rr = np.random.default_rng(t[3]); a = rr.random() * math.pi
            x2, y2 = px + math.cos(a) * 22, py + math.sin(a) * 9
            d.line([(px, py), (x2, y2)], fill=(58, 44, 32), width=3)
            d.line([((px + x2) / 2, (py + y2) / 2), ((px + x2) / 2 + 7, (py + y2) / 2 - 6)], fill=(58, 44, 32), width=2)
        elif kind == "chest":
            d.rectangle([px - 15, py - 9, px + 15, py + 11], fill=(58, 40, 28))
            d.rectangle([px - 15, py - 9, px + 15, py - 3], fill=(84, 60, 40))
            d.rectangle([px - 15, py - 1, px + 15, py + 1], fill=(40, 36, 34))
            d.rectangle([px - 2, py - 3, px + 2, py + 3], fill=(120, 100, 60))
        elif kind == "sign":
            d.rectangle([px - 2, py - 4, px + 2, py + 16], fill=(52, 40, 30))
            d.polygon([(px - 18, py - 14), (px + 16, py - 16), (px + 18, py - 2), (px - 16, py)], fill=(92, 72, 50))
            for k in range(3):
                d.line([(px - 12, py - 11 + k * 4), (px + 10, py - 12 + k * 4)], fill=(40, 26, 22), width=1)
            # a claw mark across the sign
            d.line([(px - 14, py - 15), (px + 6, py - 1)], fill=(30, 20, 16), width=2)
        elif kind == "fire":
            fx, fy = px, py
            for i in range(10):
                a = i * math.pi / 5
                sx, sy = fx + math.cos(a) * 17, fy + math.sin(a) * 14
                d.ellipse([sx - 6, sy - 5, sx + 6, sy + 5], fill=(84, 78, 70))
                d.ellipse([sx - 4, sy - 4, sx + 3, sy + 1], fill=(120, 112, 100))
            d.ellipse([fx - 12, fy - 10, fx + 12, fy + 10], fill=(30, 24, 20))
            d.line([(fx - 12, fy - 6), (fx + 12, fy + 6)], fill=(60, 40, 26), width=5)
            d.line([(fx - 12, fy + 6), (fx + 12, fy - 6)], fill=(56, 36, 24), width=5)
            for r, c in [(10, (200, 70, 24)), (7, (240, 140, 40)), (4, (255, 220, 140))]:
                d.ellipse([fx - r, fy - r * 1.1 - 2, fx + r, fy + r * 0.8 - 2], fill=c)
            # Garrick's camp: bedroll and pack
            d.rounded_rectangle([fx + 28, fy - 26, fx + 46, fy + 18], 7, fill=(70, 52, 40))
            d.rounded_rectangle([fx + 30, fy - 24, fx + 44, fy - 12], 5, fill=(110, 96, 74))
            d.ellipse([fx - 46, fy + 18, fx - 30, fy + 32], fill=(66, 54, 40))
    return np.array(im).astype(float)


def discoveries(canvas, night):
    """Things off the path that tell what happens in this wood."""
    im = Image.fromarray(np.clip(canvas, 0, 255).astype(np.uint8))
    d = ImageDraw.Draw(im, "RGBA")
    # a deer, torn open in the tall grass east of the clearing, crows on it, a drag trail of blood
    cx, cy = (15.2 - X0) * S, (8.6 - Y0) * S
    for k in range(40):
        t = k / 40
        x = cx - 40 - t * 150 + math.sin(t * 7) * 10
        y = cy + 8 + t * 40 + math.cos(t * 5) * 6
        r = 3.5 - t * 2.4
        d.ellipse([x - r, y - r * 0.7, x + r, y + r * 0.7], fill=(80, 16, 14, int(200 - t * 140)))
    d.ellipse([cx - 30, cy - 14, cx + 28, cy + 16], fill=(92, 66, 46))
    d.ellipse([cx - 22, cy - 8, cx + 18, cy + 10], fill=(110, 30, 26))
    for k in range(5):
        d.line([(cx - 14 + k * 7, cy - 6), (cx - 12 + k * 7, cy + 7)], fill=(210, 200, 180), width=2)  # ribs
    d.ellipse([cx + 24, cy - 9, cx + 40, cy + 3], fill=(96, 70, 50))  # head
    d.line([(cx + 34, cy - 8), (cx + 44, cy - 20)], fill=(150, 132, 110), width=2)  # antler
    d.line([(cx + 38, cy - 10), (cx + 50, cy - 16)], fill=(150, 132, 110), width=2)
    for (ox, oy, a) in [(-34, -20, 0.3), (6, -24, -0.5), (30, 18, 1.2)]:
        x, y = cx + ox, cy + oy
        d.polygon([(x - 7, y), (x + 8, y - 3), (x + 9, y + 3)], fill=(18, 16, 20))
        d.line([(x - 3, y - 5), (x + 4, y + 5)], fill=(26, 24, 30), width=3)
    # an old grave by the pond: a mound of stones and a leaning wooden cross
    gx, gy = (5.6 - X0) * S, (12.4 - Y0) * S
    for k in range(9):
        a = k * 0.7; rr = 6 + (k % 3) * 4
        x, y = gx + math.cos(a) * rr * 1.4, gy + math.sin(a) * rr
        d.ellipse([x - 6, y - 5, x + 6, y + 5], fill=(92, 88, 80))
        d.ellipse([x - 4, y - 4, x + 2, y], fill=(122, 116, 104))
    d.line([(gx + 2, gy - 30), (gx - 2, gy - 4)], fill=(60, 46, 34), width=4)
    d.line([(gx - 10, gy - 22), (gx + 12, gy - 24)], fill=(60, 46, 34), width=4)
    # bones near the cave road
    bx, by = (12.5 - X0) * S, (2.3 - Y0) * S
    for (ox, oy, a) in [(0, 0, 0.4), (14, 6, -0.9), (-10, 10, 1.4)]:
        x2, y2 = bx + ox + math.cos(a) * 12, by + oy + math.sin(a) * 12
        d.line([(bx + ox, by + oy), (x2, y2)], fill=(200, 190, 168), width=3)
        d.ellipse([x2 - 3, y2 - 3, x2 + 3, y2 + 3], fill=(200, 190, 168))
    d.ellipse([bx - 22, by - 6, bx - 10, by + 6], fill=(206, 196, 176))  # skull
    d.ellipse([bx - 19, by - 2, bx - 16, by + 1], fill=(30, 24, 20)); d.ellipse([bx - 15, by - 2, bx - 12, by + 1], fill=(30, 24, 20))
    return np.array(im).astype(float)


def figures(canvas):
    """Placeholders seen at a slant: the hero with a lantern, Garrick by the fire. Not the doll yet."""
    im = Image.fromarray(np.clip(canvas, 0, 255).astype(np.uint8))
    d = ImageDraw.Draw(im, "RGBA")

    def person(x, y, cloak, hood, skin=(150, 116, 92), lantern=False, sit=False):
        top = y - (34 if sit else 56)
        d.ellipse([x - 14, y - 5, x + 20, y + 6], fill=(0, 0, 0, 110))                     # shadow
        if not sit:
            d.rectangle([x - 6, y - 16, x - 2, y], fill=(40, 34, 30)); d.rectangle([x + 2, y - 16, x + 6, y], fill=(34, 28, 26))  # legs
        d.polygon([(x - 11, y - (8 if sit else 14)), (x + 11, y - (8 if sit else 14)), (x + 8, top + 14), (x - 8, top + 14)], fill=cloak)  # cloak
        d.polygon([(x - 11, y - (8 if sit else 14)), (x - 4, y - (8 if sit else 14)), (x - 6, top + 15), (x - 8, top + 14)], fill=tuple(min(255, v + 18) for v in cloak))
        d.ellipse([x - 8, top, x + 8, top + 17], fill=hood)                                 # hood
        d.ellipse([x - 4, top + 6, x + 4, top + 15], fill=skin)                              # face in the hood
        d.rectangle([x - 4, top + 8, x + 4, top + 9], fill=(30, 22, 18))                     # shadowed eyes
        if lantern:
            d.line([(x + 10, top + 24), (x + 13, top + 30)], fill=(40, 36, 30), width=2)
            d.rectangle([x + 10, top + 30, x + 17, top + 39], fill=(255, 206, 120))
            d.rectangle([x + 10, top + 30, x + 17, top + 31], fill=(50, 44, 38))
            return (x + 13.5, top + 35)
        return None

    hx, hy = (8.6 - X0) * S, (10.4 - Y0) * S
    lamp = person(hx, hy, (60, 64, 68), (46, 42, 40), lantern=True)
    person((12.55 - X0) * S + 4, (9.7 - Y0) * S + 14, (70, 56, 38), (54, 66, 42), sit=True)
    return np.array(im).astype(float), lamp


def light(canvas, occl, water, lantern, fire, night):
    """Night: a cold, dark ambient; the fire and the lantern light what they can see."""
    yy, xx = np.mgrid[0:H, 0:W]
    if not night:
        return canvas
    amb = np.array([0.16, 0.19, 0.30])
    lightc = np.ones((H, W, 3)) * amb

    def visible(sx, sy):
        # line of sight on the tile grid: trees and rocks stop the light (soft at the edges)
        cs = 8
        gh, gw = H // cs, W // cs
        vis = np.zeros((gh, gw))
        for gy in range(gh):
            for gx in range(gw):
                x, y = gx * cs + cs / 2, gy * cs + cs / 2
                dist = math.hypot(x - sx, y - sy)
                steps = max(1, int(dist / 10))
                ok = 1.0
                for i in range(1, steps):
                    f = i / steps
                    tx = int((sx + (x - sx) * f) // S) + 1; ty = int((sy + (y - sy) * f) // S) + 1
                    stx, sty = int(sx // S) + 1, int(sy // S) + 1
                    if (tx, ty) != (stx, sty) and 0 <= ty < occl.shape[0] and 0 <= tx < occl.shape[1] and occl[ty, tx]:
                        # light still reaches the first trunk it meets, not beyond
                        if math.hypot(x - sx, y - sy) * (1 - f) > S * 0.6:
                            ok = 0.12
                            break
                vis[gy, gx] = ok
        v = np.kron(vis, np.ones((cs, cs)))
        v = np.pad(v, ((0, H - v.shape[0]), (0, W - v.shape[1])), mode="edge")
        return nd.gaussian_filter(v, 6)

    for (sx, sy, c, reach, power) in [(fire[0], fire[1], (1.0, 0.62, 0.32), S * 4.2, 1.6), (lantern[0], lantern[1], (1.0, 0.82, 0.6), S * 2.6, 1.05)]:
        dist2 = ((xx - sx) ** 2 + (yy - sy) ** 2) / (reach * reach)
        k = power * np.exp(-dist2 * 2.2) * visible(sx, sy)
        lightc += k[..., None] * np.array(c)
    out = canvas * lightc
    # what the hero cannot see lies in a soft fog of war, darker still
    vis_h = visible(lantern[0], lantern[1])
    out = out * (0.45 + 0.55 * vis_h[..., None])
    return out


def ground_fog(canvas, water, night):
    f = fbm(W, H, 120, 21)
    near_water = nd.gaussian_filter(water.astype(float), 50)
    k = np.clip((f - 0.45) * 2.4, 0, 1) * np.clip(near_water * 3 + 0.15, 0, 1) * (0.5 if night else 0.28)
    fogc = np.array([60, 70, 86]) if night else np.array([196, 200, 196])
    return canvas * (1 - k[..., None]) + fogc * k[..., None]


def render(night):
    g, sprites, things, occl, water = build(night)
    canvas = draw_things(g, things, night)
    canvas = discoveries(canvas, night)
    canvas, lantern = figures(canvas)
    for sp in sorted(sprites, key=lambda s: s.sort):
        blit(canvas, sp.img, sp.x, sp.y)
    fire = ((11 - X0 + 0.5) * S, (9 - Y0 + 0.5) * S)
    canvas = ground_fog(canvas, water, night)
    canvas = light(canvas, occl, water, lantern, fire, night)
    # the fire itself shines on top
    if night:
        im = Image.fromarray(np.clip(canvas, 0, 255).astype(np.uint8)); d = ImageDraw.Draw(im)
        fx, fy = fire
        for r, c in [(10, (200, 70, 24)), (7, (240, 140, 40)), (4, (255, 220, 140))]:
            d.ellipse([fx - r, fy - r * 1.1 - 2, fx + r, fy + r * 0.8 - 2], fill=c)
        canvas = np.array(im).astype(float)
    return Image.fromarray(np.clip(canvas, 0, 255).astype(np.uint8))


if __name__ == "__main__":
    for night in (False, True):
        img = render(night)
        img.save(f"{OUT}/lichtung_neu_{'nacht' if night else 'tag'}.png")
        print("ok", night)
