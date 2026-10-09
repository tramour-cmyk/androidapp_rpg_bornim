"""Prototype: the Bloodfang Cave in top-down view, drawn the new way (like tools/entwurf/lichtung.py).

Made from the real map rows of the cave (Story.cave). Double resolution (64 art pixels per tile),
no visible grid: rock floor with cracks, gravel, damp patches and puddles; cave walls with a top and a
lit face, so the room reads; stalagmites, rubble, bones, crates, bedrolls, supports, the gate, a fire,
glowing mushrooms and crystals, a crack of daylight. Light comes only from what shines (the same
sources and strengths as MapLight) and the hero's lantern; walls stop it.

Usage: python3 hoehle.py <out dir>
"""
import math
import sys

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as nd

ROWS = [
    "XXXXXXXXXXXXXXXXXXXXXX",
    "XXXXXXt________tXXXXXX",
    "XXXXXX________j_XXXXXX",
    "XXXXXXi________iXXXXXX",
    "XXXXXXXXXX__XXXXXXXXXX",
    "XXXXXXXXXXLLXXXXXXXXXX",
    "XXXGXXGXXXHHXXXXXXXXXX",
    "XXg_____XX__XX__*__jXX",
    "XX_C___gXX__XX%___C_XX",
    "XXg_____XX__XX_____jXX",
    "XX___r______________XX",
    "XX_g____XX__XXi_____XX",
    "XXXXX_XXXXHHXXXX_XXXXX",
    "XX~~____XX__XXe____uXX",
    "XX~~C___XX__XXe____uXX",
    "XX~g____XX__XX__F_j_XX",
    "XX_%______________%_XX",
    "XXXXXXXXXXHHXXXXXXXXXX",
    "XXXXXXXXXX__XXXXXXXXXX",
    "XXXXXXXXXX++XXXXXXXXXX",
]
X0, Y0, NX, NY = 1, 4, 20, 16           # the part of the map shown
S = 64                                  # art pixels per tile (twice the old 32)
W, H = NX * S, NY * S
OUT = sys.argv[1] if len(sys.argv) > 1 else "."
WALLS = "XGt"
OPAQUE = "XGt"                          # stops light, as in MapLight
HERO = (10.55, 15.2)                    # the hero, in map tiles, on the way in

rng = np.random.default_rng(11)


def tile(x, y):
    if 0 <= y < len(ROWS) and 0 <= x < len(ROWS[0]):
        return ROWS[y][x]
    return "X"


def px(tx, ty):
    """Map tile coordinates to picture pixels (top-left of the tile)."""
    return (tx - X0) * S, (ty - Y0) * S


def hsh(*a):
    n = 0
    for v in a:
        n = (n * 374761393 + int(v) * 668265263 + 1442695041) & 0xFFFFFFFF
        n = ((n ^ (n >> 13)) * 1274126177) & 0xFFFFFFFF
    return (n ^ (n >> 16)) & 0x7FFFFFFF


def rnd(*a):
    return (hsh(*a) % 10000) / 10000.0


# ------------------------------------------------------------------ noise and colour

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


def rgb(hexv, a=255):
    return ((hexv >> 16) & 255, (hexv >> 8) & 255, hexv & 255, a)


def shade(hexv, k, a=255):
    r, g, b, _ = rgb(hexv)
    return (int(min(255, r * k)), int(min(255, g * k)), int(min(255, b * k)), a)


def lerp(a, b, t):
    t = np.clip(t, 0, 1)[..., None] if np.ndim(t) else t
    return a + (b - a) * t


def hsh_arr(a):
    n = (a.astype(np.int64) * 374761393 + 1442695041) & 0xFFFFFFFF
    n = ((n ^ (n >> 13)) * 1274126177) & 0xFFFFFFFF
    return (n ^ (n >> 16)) & 0x7FFFFFFF


def bump(hf, k):
    """Shading of a height field lit from the top left: >1 on slopes facing the light."""
    gy, gx = np.gradient(hf)
    return np.clip(1 + (-gx - gy) * k * 12, 0.55, 1.5)


def mask(chars, soft=0.0, wobble=0.0, seed=1):
    """Pixels on tiles of [chars], with a margin of one tile around the picture."""
    m = np.zeros((H, W))
    for ty in range(-1, NY + 1):
        for tx in range(-1, NX + 1):
            if tile(X0 + tx, Y0 + ty) in chars:
                m[max(0, ty * S):max(0, (ty + 1) * S), max(0, tx * S):max(0, (tx + 1) * S)] = 1
    if soft:
        m = nd.gaussian_filter(m, soft, mode="nearest")
    if wobble:
        m = m + (fbm(W, H, 40, seed) - 0.5) * wobble
    return m


def tiles_of(ch):
    return [(x, y) for y in range(Y0 - 1, Y0 + NY + 1) for x in range(X0 - 1, X0 + NX + 1) if tile(x, y) == ch]


# ------------------------------------------------------------------ ground and walls

FACE = 58                                # height of a wall face in pixels


def ground():
    yy, xx = np.mgrid[0:H, 0:W]
    n1 = fbm(W, H, 128, 1); n2 = fbm(W, H, 32, 2); n3 = fbm(W, H, 8, 3, 2)

    # where the rock stands: the tile walls with a rough, hand-made edge
    wallm = mask(WALLS, soft=24) + (fbm(W, H, 120, 4) - 0.5) * 0.9 + (fbm(W, H, 56, 5) - 0.5) * 0.7 + (fbm(W, H, 14, 6) - 0.5) * 0.22
    wall = wallm > 0.5
    floor = ~wall

    # rock floor: grey-brown stone, worn smoother where people walk (the middle passage)
    g = lerp(col(0x3A342F), col(0x6A6258), n2 * 0.9 + n3 * 0.4 - 0.15)
    g = lerp(g, col(0x4A433C), np.clip((n1 - 0.5) * 3, 0, 1) * 0.6)
    walkway = np.zeros((H, W))
    ax, _ = px(10, 0)
    walkway[:, int(ax + 0.4 * S):int(ax + 1.6 * S)] = 1
    walkway[int(px(0, 10)[1] + 0.2 * S):int(px(0, 11)[1] - 0.1 * S), :] = 1
    walkway[int(px(0, 16)[1] + 0.1 * S):int(px(0, 17)[1] - 0.1 * S), :] = 1
    walkway = nd.gaussian_filter(walkway, 14) * (0.6 + 0.4 * n2)
    g = lerp(g, col(0x5A5249), walkway * 0.35)

    # the floor breaks into flat slabs: a faint seam between them and a little relief, lit from the top left
    seeds = np.ones((H, W), dtype=bool)
    for i in range(420):
        seeds[int(rng.integers(0, H)), int(rng.integers(0, W))] = False
    _, (iy, ix) = nd.distance_transform_edt(seeds, return_indices=True)
    lab = iy * W + ix
    seam = (lab != np.roll(lab, 1, axis=0)) | (lab != np.roll(lab, 1, axis=1))
    slab_tone = (hsh_arr(lab) % 1000) / 1000.0
    g = g * (0.93 + 0.14 * slab_tone)[..., None]
    relief = fbm(W, H, 20, 30, 3) + slab_tone * 0.15
    g = g * bump(nd.gaussian_filter(relief, 1.5), 0.45)[..., None]
    g[seam] = g[seam] * 0.62
    sl = np.roll(seam, 1, axis=0) & ~seam
    g[sl] = g[sl] * 1.12

    # cracks in the floor: dark lines with a lit lip on one side
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    for i in range(170):
        x, y = float(rng.integers(0, W)), float(rng.integers(0, H))
        ang = rng.uniform(0, math.tau)
        pts = [(x, y)]
        for k in range(int(rng.integers(4, 14))):
            ang += rng.normal(0, 0.55)
            step = rng.uniform(5, 13)
            x += math.cos(ang) * step; y += math.sin(ang) * step
            pts.append((x, y))
        d.line([(p[0] + 1, p[1] + 1) for p in pts], fill=(120, 112, 100, 70), width=1)
        d.line(pts, fill=(18, 16, 14, 190), width=1 if rng.random() < 0.7 else 2)
    t = np.array(im).astype(float); a = t[..., 3:4] / 255
    g = g * (1 - a) + t[..., :3] * a

    # damp: darker, slightly green-blue stone, around the pool, under the crack of daylight, by the walls
    wet = np.clip((fbm(W, H, 56, 7) - 0.52) * 3.2, 0, 1)
    pool = mask("~", soft=46); sky = mask("*", soft=50)
    wet = np.clip(wet * 0.7 + pool * 2.2 + sky * 1.6, 0, 1)
    g = lerp(g, g * np.array([0.62, 0.68, 0.7]), wet * 0.85)
    moss = np.clip((fbm(W, H, 18, 8) - 0.45) * 3, 0, 1) * np.clip(pool * 2.4 + sky * 3.0, 0, 1)
    g = lerp(g, col(0x3A4A2C), moss * 0.75)

    # puddles: still, black water that mirrors a faint sheen at the edge
    puddle = (fbm(W, H, 44, 9) * 0.8 + fbm(W, H, 12, 10) * 0.2 + wet * 0.28) > 0.76
    puddle = nd.binary_opening(puddle, iterations=3) & floor & (walkway < 0.5)
    pd = nd.distance_transform_edt(puddle)
    # shallow water: the stone shows through at the edge, the middle mirrors the dark roof
    pc = lerp(g * 0.6, col(0x1E262A), np.clip(pd / 6, 0, 1))
    g = np.where(puddle[..., None], pc, g)
    rimp = nd.binary_dilation(puddle, iterations=3) & ~puddle
    g[rimp] = g[rimp] * 0.7
    sheen = puddle & (pd < 3) & ~np.roll(puddle, -4, axis=0)
    g[sheen] = lerp(g[sheen], col(0x7A8890), 0.55)

    # gravel: small stones, lit from the top left, each with a little shadow
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    for i in range(5200):
        x = int(rng.integers(0, W)); y = int(rng.integers(0, H))
        if not floor[y, x] or puddle[y, x]:
            continue
        if walkway[y, x] > 0.35 and rng.random() < 0.7:
            continue
        r = rng.choice([1, 1, 1, 2, 2, 3])
        c = int(rng.integers(70, 130))
        d.ellipse([x - r + 1, y - r + 2, x + r + 1, y + r + 1], fill=(10, 9, 8, 120))
        d.ellipse([x - r, y - r, x + r, y + r * 0.8], fill=(c, c - 6, c - 12, 255))
        if r > 1:
            d.point((x - 1, y - 1), fill=(c + 40, c + 34, c + 26, 255))
    t = np.array(im).astype(float); a = t[..., 3:4] / 255
    g = g * (1 - a) + t[..., :3] * a

    # the floor grows dark towards the rock (where the light hardly reaches and dirt gathers)
    dw = nd.distance_transform_edt(floor)
    g = g * (0.5 + 0.5 * np.clip(dw / 26, 0, 1))[..., None]

    # ---- the rock: a dark, rough top and, where floor lies in front, a face with layers
    below = np.full((H, W), 999)
    for k in range(FACE, 0, -1):
        sh = np.zeros_like(floor); sh[:-k] = floor[k:]
        below = np.where(wall & sh, k, below)
    face = wall & (below <= FACE + (fbm(W, H, 20, 15) - 0.5) * 14)
    top = wall & ~face
    v = np.clip(below / FACE, 0, 1)            # 0 at the foot of the face, 1 at its top edge
    strata = np.sin(yy * 0.55 + n2 * 9 + xx * 0.04) * 0.5 + 0.5
    cracks = (np.abs(fbm(W, H, 10, 16) - 0.5) < 0.025)
    fc = lerp(col(0x5E574F), col(0x2E2A26), v * 0.85 + n3 * 0.25)
    fc = fc * bump(fbm(W, H, 16, 22, 3), 0.9)[..., None]
    fc = lerp(fc, fc * 0.72, (strata > 0.78).astype(float))
    fc = lerp(fc, fc * 1.18, ((strata > 0.62) & (strata < 0.7)).astype(float))
    fc[cracks] = fc[cracks] * 0.45
    # wet streaks running down
    streak = (value_noise(W, H, 3, 17)[0:1, :] > 0.86).repeat(H, axis=0) & (fbm(W, H, 30, 18) > 0.5)
    fc[streak & face] = lerp(fc[streak & face], col(0x2A3034), 0.5)
    # the foot of the face, where it meets the floor, is darkest
    foot = face & (below <= 3)
    fc[foot] = fc[foot] * 0.4
    tc = lerp(col(0x141216), col(0x24201E), n2 * 0.7 + n3 * 0.4)
    # the rock mass is lumpy: big knuckles of stone, lit from the top left
    lumps = fbm(W, H, 36, 19) * 0.75 + fbm(W, H, 8, 20, 2) * 0.25
    tc = tc * (0.8 + 0.4 * lumps)[..., None] * bump(nd.gaussian_filter(lumps, 2), 1.1)[..., None]
    # a pale lip where the top of the rock breaks off
    dt = nd.distance_transform_edt(top)
    lip = top & (dt < 3.5) & ~nd.binary_erosion(wall, iterations=3)
    tc[lip] = lerp(tc[lip], col(0x6A6258), 0.55)
    edge_to_face = top & nd.binary_dilation(face, iterations=2)
    tc[edge_to_face] = lerp(tc[edge_to_face], col(0x7A7268), 0.5)
    g = np.where(face[..., None], fc, g)
    g = np.where(top[..., None], tc, g)

    # the pool: deep, black water in a stone basin
    wm = mask("~", soft=12, wobble=0.5, seed=21)
    water = (wm > 0.5) & floor
    depth = nd.distance_transform_edt(water)
    wc = lerp(col(0x1E2A2C), col(0x06090A), np.clip(depth / 40, 0, 1))
    ripple = (np.abs(np.sin(np.hypot(xx - px(2, 0)[0] - 70, yy - px(0, 14)[1] - 10) * 0.28)) > 0.995) & (fbm(W, H, 24, 23) > 0.55) & (depth > 6) & (depth < 40)
    wc[ripple] = lerp(wc[ripple], col(0x4A5A5E), 0.35)
    shore = nd.binary_dilation(water, iterations=5) & ~water & floor
    g[shore] = lerp(g[shore], col(0x22201C), 0.65)
    g = np.where(water[..., None], wc, g)

    return g, wall, face, top, floor, water, puddle


# ------------------------------------------------------------------ things

class Sprite:
    def __init__(self, img, x, y, sort, glow=None):
        self.img, self.x, self.y, self.sort, self.glow = img, x, y, sort, glow


def canvas(w, h):
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    return im, ImageDraw.Draw(im)


def shadow(d, cx, cy, rx, ry, a=110):
    for k in range(4):
        f = 1 - k * 0.18
        d.ellipse([cx - rx * f, cy - ry * f, cx + rx * f, cy + ry * f], fill=(6, 5, 6, int(a * 0.3)))


def stalagmite(seed, big=1.0):
    w, h = 90, 150
    im, d = canvas(w, h)
    cx, by = w / 2, h - 18
    shadow(d, cx + 6, by + 2, 26 * big, 9 * big)
    for k, (dx, hh, rw) in enumerate([(0, 108, 20), (-17, 46, 9), (15, 62, 10), (9, 28, 6)]):
        if k and rnd(seed, k) < 0.25:
            continue
        hh *= big * (0.85 + rnd(seed, k, 1) * 0.3); rw *= big
        bx = cx + dx * big
        tip = (bx + (rnd(seed, k, 2) - 0.5) * 8, by - hh)
        n = 18
        for i in range(n):
            # from dark (right) to lit (left), drawn as thin slices of the cone
            f0 = i / n; f1 = (i + 1) / n
            l = 1.25 - f0 * 0.85
            c = shade(0x6E665C, l)
            poly = [(bx - rw + 2 * rw * f0, by - 2), (bx - rw + 2 * rw * f1, by - 2), (tip[0] + (f1 - 0.5) * 2, tip[1]), (tip[0] + (f0 - 0.5) * 2, tip[1])]
            d.polygon(poly, fill=c)
        # rings of old drip-stone and a wet sheen down the lit side
        for r in range(4, int(hh) - 6, 9):
            ff = r / hh
            ww = rw * (1 - ff)
            d.line([(bx - ww + (tip[0] - bx) * ff, by - 2 - r), (bx + ww + (tip[0] - bx) * ff, by - 2 - r + 1)], fill=(40, 36, 32, 120))
        d.line([(bx - rw * 0.45, by - 6), (tip[0] - 1, tip[1] + 6)], fill=(170, 164, 150, 110), width=1)
        d.ellipse([bx - rw - 2, by - 6, bx + rw + 2, by + 3], fill=shade(0x4A433C, 1.0))
    return im, cx, by


def boulder(seed):
    w, h = 110, 90
    im, d = canvas(w, h)
    cx, by = w / 2, h - 16
    shadow(d, cx + 8, by, 40, 12)
    pts = []
    for i in range(14):
        a = i / 14 * math.tau
        r = 30 + rnd(seed, i) * 10
        pts.append((cx + math.cos(a) * r * 1.15, by - 26 + math.sin(a) * r * 0.85))
    d.polygon(pts, fill=shade(0x3A342F, 1.0))
    # lit top left, dark lower right
    for k in range(7):
        f = 1 - k * 0.12
        d.polygon([(cx + (p[0] - cx) * f - k * 1.6, by - 26 + (p[1] - by + 26) * f - k * 1.8) for p in pts], fill=shade(0x4A433C, 0.9 + k * 0.09))
    d.line([(cx - 18, by - 30), (cx + 4, by - 18), (cx + 20, by - 26)], fill=(30, 27, 24, 255), width=2)
    return im, cx, by


def rubble(seed):
    w, h = 120, 100
    im, d = canvas(w, h)
    cx, by = w / 2, h - 20
    stones = sorted([(cx + (rnd(seed, i) - 0.5) * 80, by - 26 + (rnd(seed, i, 1) - 0.5) * 44, 3 + rnd(seed, i, 2) ** 2 * 13) for i in range(26)], key=lambda s: s[1])
    for (x, y, r) in stones:
        d.ellipse([x - r * 1.1 + 3, y - r * 0.6 + 3, x + r * 1.1 + 3, y + r * 0.8 + 3], fill=(8, 7, 7, 120))
    for (x, y, r) in stones:
        base = 0x5A534B if rnd(x, y) < 0.6 else 0x4A433C
        pts = [(x + math.cos(a) * r * (1.1 + rnd(x, a) * 0.3), y + math.sin(a) * r * 0.75) for a in np.linspace(0, math.tau, 7)[:-1] + rnd(y, r)]
        d.polygon(pts, fill=shade(base, 0.85))
        d.polygon([(x + (p[0] - x) * 0.7 - r * 0.2, y + (p[1] - y) * 0.6 - r * 0.25) for p in pts], fill=shade(base, 1.2))
    return im, cx, by


def bones(seed):
    w, h = 110, 80
    im, d = canvas(w, h)
    cx, by = w / 2, h - 18
    bone = (206, 196, 172, 255); dark = (120, 110, 92, 255)
    for i in range(3 + int(rnd(seed) * 3)):
        x = cx + (rnd(seed, i) - 0.5) * 70; y = by - 16 + (rnd(seed, i, 1) - 0.5) * 34
        a = rnd(seed, i, 2) * math.pi; L = 9 + rnd(seed, i, 3) * 12
        x1, y1 = x + math.cos(a) * L, y + math.sin(a) * L * 0.6
        d.line([(x + 1, y + 2), (x1 + 1, y1 + 2)], fill=(10, 9, 8, 110), width=3)
        d.line([(x, y), (x1, y1)], fill=dark, width=3)
        d.line([(x, y - 1), (x1, y1 - 1)], fill=bone, width=1)
        for (ex, ey) in [(x, y), (x1, y1)]:
            d.ellipse([ex - 2.5, ey - 2.5, ex + 2.5, ey + 1.5], fill=bone)
    # ribs and a skull
    rx, ry = cx + 14, by - 22
    for k in range(4):
        d.arc([rx - 12, ry - 6 + k * 4, rx + 12, ry + 8 + k * 4], 200, 340, fill=bone, width=1)
    if rnd(seed, 9) < 0.7:
        sx, sy = cx - 18, by - 10
        d.ellipse([sx - 7 + 2, sy - 6 + 3, sx + 7 + 2, sy + 6 + 3], fill=(10, 9, 8, 110))
        d.ellipse([sx - 7, sy - 7, sx + 7, sy + 5], fill=bone)
        d.rectangle([sx - 4, sy + 2, sx + 4, sy + 7], fill=bone)
        d.ellipse([sx - 5, sy - 3, sx - 1, sy + 1], fill=(22, 18, 16, 255))
        d.ellipse([sx + 1, sy - 3, sx + 5, sy + 1], fill=(22, 18, 16, 255))
        d.line([(sx - 3, sy + 6), (sx + 3, sy + 6)], fill=dark)
    return im, cx, by


def crate(seed, stack=False):
    w, h = 90, 120
    im, d = canvas(w, h)
    cx, by = w / 2, h - 14
    shadow(d, cx + 8, by, 34, 10)

    def box(x, y, s, wood):
        # front and top face of a plank box in the oblique view
        top = [(x - s, y - s * 1.55), (x + s, y - s * 1.55), (x + s * 0.92, y - s * 2.25), (x - s * 0.92, y - s * 2.25)]
        d.rectangle([x - s, y - s * 1.55, x + s, y], fill=shade(wood, 0.78))
        d.polygon(top, fill=shade(wood, 1.12))
        for k in range(1, 4):
            yy = y - s * 1.55 * k / 4
            d.line([(x - s, yy), (x + s, yy)], fill=shade(wood, 0.5))
        d.line([(x - s, y), (x + s, y - s * 1.55)], fill=shade(wood, 0.62), width=3)
        d.rectangle([x - s, y - s * 1.55, x + s, y], outline=shade(wood, 0.4))
        d.polygon(top, outline=shade(wood, 0.55))
        for (nx, ny) in [(x - s + 3, y - 3), (x + s - 3, y - 3), (x - s + 3, y - s * 1.55 + 3), (x + s - 3, y - s * 1.55 + 3)]:
            d.point((nx, ny), fill=(30, 30, 34, 255))

    box(cx, by, 22, 0x6A4A30)
    if stack:
        box(cx + 3, by - 36, 17, 0x5E4230)
    return im, cx, by


def bedroll(seed):
    w, h = 110, 70
    im, d = canvas(w, h)
    cx, by = w / 2, h - 16
    shadow(d, cx + 5, by, 46, 10)
    fur = 0x5A4634 if rnd(seed) < 0.5 else 0x4A4038
    # a pelt flat on the stone, ragged at the edge, and a grubby blanket thrown over half of it
    pts = [(cx + math.cos(a) * (40 + rnd(seed, i) * 6), by - 14 + math.sin(a) * (14 + rnd(seed, i, 1) * 4)) for i, a in enumerate(np.linspace(0, math.tau, 22)[:-1])]
    d.polygon([(p[0] + 2, p[1] + 3) for p in pts], fill=(8, 7, 6, 120))
    d.polygon(pts, fill=shade(fur, 0.85))
    for k in range(160):
        x = cx - 38 + rnd(seed, k) * 76; y = by - 26 + rnd(seed, k, 1) * 24
        d.line([(x, y), (x + 2, y + 3)], fill=shade(fur, 1.3 if k % 2 else 0.55), width=1)
    d.polygon([(cx - 6, by - 26), (cx + 30, by - 24), (cx + 34, by - 4), (cx - 2, by - 2)], fill=shade(0x5A3A2E, 0.8))
    for k in range(4):
        d.line([(cx - 4 + k * 9, by - 25), (cx + k * 9, by - 3)], fill=shade(0x5A3A2E, 0.55))
    d.ellipse([cx - 40, by - 24, cx - 22, by - 8], fill=shade(0x6A5E4A, 0.8))
    return im, cx, by


def chest(seed):
    w, h = 90, 90
    im, d = canvas(w, h)
    cx, by = w / 2, h - 14
    shadow(d, cx + 6, by, 34, 9)
    wood = 0x5E4228; iron = 0x3E3C40
    d.rectangle([cx - 24, by - 26, cx + 24, by], fill=shade(wood, 0.8))
    d.chord([cx - 24, by - 44, cx + 24, by - 14], 180, 360, fill=shade(wood, 1.1))
    d.rectangle([cx - 24, by - 29, cx + 24, by - 25], fill=shade(iron, 1.2))
    for x in (cx - 16, cx + 16):
        d.rectangle([x - 2, by - 40, x + 2, by], fill=shade(iron, 1.1))
    d.rectangle([cx - 4, by - 24, cx + 4, by - 15], fill=(110, 92, 52, 255))
    d.point((cx, by - 19), fill=(20, 16, 12, 255))
    return im, cx, by


def campfire(seed):
    w, h = 110, 100
    im, d = canvas(w, h)
    cx, by = w / 2, h - 30
    # soot on the ground, a ring of stones, charred logs; the flames are added as light
    d.ellipse([cx - 40, by - 18, cx + 40, by + 18], fill=(14, 12, 10, 150))
    for i in range(11):
        a = i / 11 * math.tau
        x, y = cx + math.cos(a) * 26, by + math.sin(a) * 13
        d.ellipse([x - 6, y - 5, x + 6, y + 4], fill=shade(0x5A534B, 0.9 + rnd(seed, i) * 0.3))
    for a in (0.3, 1.9, 3.3):
        d.line([(cx - math.cos(a) * 18, by - math.sin(a) * 7), (cx + math.cos(a) * 18, by + math.sin(a) * 7)], fill=(34, 24, 18, 255), width=6)
    d.ellipse([cx - 12, by - 6, cx + 12, by + 6], fill=(150, 50, 16, 255))
    return im, cx, by


def support_pair(seed):
    """Two posts at the sides of a 2-tile passage with a beam over it."""
    w, h = 2 * S + 30, 150
    im, d = canvas(w, h)
    by = h - 20
    wood = 0x5A3E26
    lx, rx = 15 + 8, w - 15 - 8
    for x in (lx, rx):
        d.ellipse([x - 12, by - 4, x + 14, by + 6], fill=(6, 5, 6, 120))
        d.rectangle([x - 7, by - 112, x + 7, by], fill=shade(wood, 0.95))
        d.rectangle([x - 7, by - 112, x - 3, by], fill=shade(wood, 1.25))
        d.rectangle([x + 3, by - 112, x + 7, by], fill=shade(wood, 0.6))
        for k in range(5):
            y = by - 10 - k * 22 - rnd(seed, x, k) * 8
            d.line([(x - 5, y), (x + 4, y + 3)], fill=shade(wood, 0.5))
    # the beam, with the rock above pressing on it
    d.rectangle([lx - 12, by - 124, rx + 12, by - 108], fill=shade(wood, 0.85))
    d.rectangle([lx - 12, by - 124, rx + 12, by - 120], fill=shade(wood, 1.2))
    d.line([(lx - 12, by - 108), (rx + 12, by - 108)], fill=shade(wood, 0.4), width=2)
    for x in (lx + 20, rx - 26):
        d.line([(x, by - 116), (x + 6, by - 116)], fill=(40, 40, 44, 255), width=2)
    return im, w / 2, by


def gate():
    w, h = 2 * S + 20, 150
    im, d = canvas(w, h)
    by = h - 22
    iron = 0x34322F; rust = 0x6A3E22
    d.rectangle([4, by - 4, w - 4, by + 4], fill=(10, 9, 8, 140))
    for i in range(9):
        x = 10 + i * (w - 20) / 8
        d.line([(x + 2, by), (x + 2, by - 116)], fill=(10, 9, 8, 150), width=4)
        d.line([(x, by), (x, by - 118)], fill=shade(iron, 1.0), width=4)
        d.line([(x - 1, by), (x - 1, by - 118)], fill=shade(iron, 1.7), width=1)
        d.polygon([(x - 4, by - 118), (x + 4, by - 118), (x, by - 128)], fill=shade(iron, 1.2))
        for k in range(3):
            y = by - 20 - rnd(i, k) * 90
            d.line([(x, y), (x, y + 6)], fill=shade(rust, 1.0), width=3)
    for y in (by - 26, by - 88):
        d.rectangle([6, y - 3, w - 6, y + 3], fill=shade(iron, 1.1))
        d.line([(6, y - 3), (w - 6, y - 3)], fill=shade(iron, 1.8))
    d.rectangle([w / 2 - 9, by - 64, w / 2 + 9, by - 48], fill=shade(iron, 1.4))
    d.ellipse([w / 2 - 3, by - 60, w / 2 + 3, by - 53], fill=(12, 10, 8, 255))
    return im, w / 2, by


def mushrooms(seed):
    w, h = 90, 70
    im, d = canvas(w, h)
    gl, gd = canvas(w, h)
    cx, by = w / 2, h - 18
    for i in range(6 + int(rnd(seed) * 5)):
        x = cx + (rnd(seed, i) - 0.5) * 50; y = by - 4 + (rnd(seed, i, 1) - 0.5) * 22
        s = 3 + rnd(seed, i, 2) * 6
        d.line([(x, y), (x + rnd(seed, i, 4) * 2 - 1, y - s * 1.2)], fill=(150, 170, 160, 255), width=2)
        cap = [x - s, y - s * 1.2 - s * 0.6, x + s, y - s * 1.2 + s * 0.35]
        d.ellipse(cap, fill=(54, 150, 146, 255))
        d.ellipse([x - s * 0.6, y - s * 1.2 - s * 0.55, x + s * 0.3, y - s * 1.2], fill=(140, 240, 226, 255))
        gd.ellipse(cap, fill=(96, 232, 216, 255))
    return im, cx, by, gl


def crystals(seed):
    w, h = 100, 120
    im, d = canvas(w, h)
    gl, gd = canvas(w, h)
    cx, by = w / 2, h - 16
    shards = sorted([((rnd(seed, i) - 0.5) * 60, 20 + rnd(seed, i, 1) * 60, (rnd(seed, i, 2) - 0.5) * 0.9, 5 + rnd(seed, i, 3) * 5) for i in range(8)], key=lambda s: -s[1])
    for (dx, L, a, wd) in shards:
        bx, byy = cx + dx, by - 4 - abs(dx) * 0.15
        tx, ty = bx + math.sin(a) * L, byy - math.cos(a) * L
        nx, ny = math.cos(a) * wd, math.sin(a) * wd
        left = [(bx - nx, byy - ny), (tx - nx * 0.5, ty - ny * 0.5 + 6), (tx, ty), (bx, byy)]
        right = [(bx, byy), (tx, ty), (tx + nx * 0.5, ty + ny * 0.5 + 6), (bx + nx, byy + ny)]
        d.polygon(left, fill=(196, 168, 255, 255))
        d.polygon(right, fill=(98, 66, 170, 255))
        d.line([(bx, byy), (tx, ty)], fill=(236, 224, 255, 255))
        gd.polygon(left + right, fill=(176, 136, 255, 255))
    return im, cx, by, gl


def skylight_roots(seed):
    """Roots and moss hanging down where daylight falls through a crack."""
    w, h = 140, 120
    im, d = canvas(w, h)
    for i in range(9):
        x = 20 + rnd(seed, i) * 100
        L = 20 + rnd(seed, i, 1) * 50
        pts = [(x + math.sin(k * 0.7 + i) * 3, 4 + k * L / 6) for k in range(7)]
        d.line(pts, fill=(52, 44, 30, 255), width=2)
        d.line([(p[0] - 1, p[1]) for p in pts], fill=(96, 100, 60, 200), width=1)
    return im, w / 2, 0


def build():
    sprites = []

    def add(img, ax, ay, tx, ty, ox=0.5, oy=0.82, glow=None):
        x, y = px(tx, ty)
        x += ox * S; y += oy * S
        sprites.append(Sprite(img, int(x - ax), int(y - ay), y, glow))

    for (x, y) in tiles_of("i"):
        im, ax, ay = stalagmite(hsh(x, y), 1.0); add(im, ax, ay, x, y)
    for (x, y) in tiles_of("r"):
        im, ax, ay = boulder(hsh(x, y)); add(im, ax, ay, x, y)
    for (x, y) in tiles_of("%"):
        im, ax, ay = rubble(hsh(x, y)); add(im, ax, ay, x, y, oy=0.8)
    for (x, y) in tiles_of("j"):
        im, ax, ay = bones(hsh(x, y)); add(im, ax, ay, x, y, oy=0.75)
    for (x, y) in tiles_of("u"):
        im, ax, ay = crate(hsh(x, y), stack=(y % 2 == 0)); add(im, ax, ay, x, y, oy=0.85)
    for (x, y) in tiles_of("e"):
        im, ax, ay = bedroll(hsh(x, y)); add(im, ax, ay, x, y, oy=0.75)
    for (x, y) in tiles_of("C"):
        im, ax, ay = chest(hsh(x, y)); add(im, ax, ay, x, y, oy=0.82)
    for (x, y) in tiles_of("F"):
        im, ax, ay = campfire(hsh(x, y)); add(im, ax, ay, x, y, oy=0.55)
    for (x, y) in tiles_of("g"):
        im, ax, ay, gl = mushrooms(hsh(x, y)); add(im, ax, ay, x, y, oy=0.7, glow=gl)
    for (x, y) in tiles_of("G"):
        # crystals grow out of the foot of the wall face, into the room below
        im, ax, ay, gl = crystals(hsh(x, y)); add(im, ax, ay, x, y, oy=1.08, glow=gl)
    for (x, y) in tiles_of("*"):
        im, ax, ay = skylight_roots(hsh(x, y)); add(im, ax, ay, x, y, oy=-0.4)
    # supports come in pairs across the passage; the gate spans both tiles
    for (x, y) in tiles_of("H"):
        if tile(x + 1, y) == "H":
            im, ax, ay = support_pair(hsh(x, y)); add(im, ax, ay, x, y, ox=1.0, oy=0.6)
    for (x, y) in tiles_of("L"):
        if tile(x + 1, y) == "L":
            im, ax, ay = gate(); add(im, ax, ay, x, y, ox=1.0, oy=0.62)
    # a few small stalagmites and loose stones by the walls, off the tiles that block
    for i in range(18):
        tx = X0 + int(rng.integers(0, NX)); ty = Y0 + int(rng.integers(0, NY))
        if tile(tx, ty) == "_" and tile(tx, ty - 1) in WALLS and tile(tx, ty + 1) not in "+":
            im, ax, ay = stalagmite(hsh(tx, ty, 5), 0.45)
            add(im, ax, ay, tx, ty, ox=0.2 + rnd(tx, ty) * 0.6, oy=0.3)
    return sprites


def blit(canvas_, img, x, y):
    a = np.array(img).astype(float)
    h, w = a.shape[:2]
    x0, y0 = max(0, x), max(0, y)
    x1, y1 = min(W, x + w), min(H, y + h)
    if x0 >= x1 or y0 >= y1:
        return
    sub = a[y0 - y:y1 - y, x0 - x:x1 - x]
    al = sub[..., 3:4] / 255
    canvas_[y0:y1, x0:x1] = canvas_[y0:y1, x0:x1] * (1 - al) + sub[..., :3] * al


def hero(canvas_):
    """A placeholder figure with a lantern (the real one is the puppet of MapFigure)."""
    im, d = canvas(60, 100)
    cx, by = 30, 86
    d.ellipse([cx - 16, by - 5, cx + 16, by + 5], fill=(6, 5, 6, 130))
    d.rectangle([cx - 7, by - 26, cx - 2, by], fill=(46, 40, 36, 255))
    d.rectangle([cx + 2, by - 26, cx + 7, by], fill=(40, 36, 32, 255))
    d.rounded_rectangle([cx - 11, by - 52, cx + 11, by - 22], 5, fill=(70, 66, 62, 255))
    d.ellipse([cx - 8, by - 68, cx + 8, by - 52], fill=(150, 120, 98, 255))
    d.line([(cx + 11, by - 44), (cx + 16, by - 32)], fill=(70, 66, 62, 255), width=4)
    d.rectangle([cx + 13, by - 32, cx + 20, by - 23], fill=(255, 210, 140, 255))
    hx, hy = px(HERO[0], HERO[1])
    blit(canvas_, im, int(hx - cx), int(hy - by))
    return hx + 16, hy - 28


# ------------------------------------------------------------------ light

def visible(sx, sy, cs=8):
    """Line of sight from a light to every grid cell, on the tile grid (rock stops the light)."""
    gh, gw = H // cs, W // cs
    gy, gx = np.mgrid[0:gh, 0:gw]
    x = gx * cs + cs / 2.0; y = gy * cs + cs / 2.0
    dist = np.hypot(x - sx, y - sy)
    steps = 96
    f = (np.arange(1, steps) / steps)[:, None, None]
    sxs = sx + (x - sx)[None] * f; sys_ = sy + (y - sy)[None] * f
    # the rock as drawn (not the tile grid), so shadows follow the rough walls
    q = 4
    opq = ROCK[::q, ::q]
    ix = np.clip((sxs / q).astype(int), 0, opq.shape[1] - 1); iy = np.clip((sys_ / q).astype(int), 0, opq.shape[0] - 1)
    along = f * dist[None]
    # light still reaches the face of the rock it meets, and leaves the rock a light sits in
    hit = opq[iy, ix] & (dist[None] - along > 16) & (along > 14)
    ok = ~hit.any(axis=0)
    v = np.kron(ok.astype(float), np.ones((cs, cs)))
    return nd.gaussian_filter(v, 5)


def lights(lantern):
    """(x, y, colour, reach, power) in picture pixels, as MapLight places them (T = 32 there)."""
    out = []
    k = S / 32.0
    for (x, y) in tiles_of("F"):
        cx, cy = px(x + 0.5, y + 0.5); out.append((cx, cy, 0xFF9A48, 32 * 4.4 * k, 1.35))
    for (x, y) in tiles_of("g"):
        cx, cy = px(x + 0.5, y + 0.5); out.append((cx, cy, 0x60E8D8, 32 * 2.4 * k, 0.8))
    for (x, y) in tiles_of("G"):
        cx, _ = px(x + 0.5, y); out.append((cx, px(0, y)[1] + 26 * k, 0xB088FF, 32 * 2.6 * k, 0.85))
    for (x, y) in tiles_of("*"):
        cx, cy = px(x + 0.5, y + 0.5); out.append((cx, cy, 0xE8F0FF, 32 * 3.0 * k, 1.15))
    for (x, y) in tiles_of("+"):
        cx, cy = px(x + 0.5, y + 0.5); out.append((cx, cy, 0xFFF4D8, 32 * 3.4 * k, 1.0))
    for (x, y) in tiles_of("t"):
        cx, _ = px(x + 0.5, y); out.append((cx, px(0, y)[1] + 12 * k, 0xFFB060, 32 * 3.6 * k, 1.15))
    out.append((lantern[0], lantern[1], 0xFFD4A8, 32 * 3.4 * k, 0.9))
    return out


def light(canvas_, top, srcs):
    yy, xx = np.mgrid[0:H, 0:W]
    lc = np.ones((H, W, 3)) * np.array([0.13, 0.13, 0.18])
    for (sx, sy, c, reach, power) in srcs:
        dd = ((xx - sx) ** 2 + (yy - sy) ** 2) / (reach * reach)
        k = power * np.exp(-dd * 2.0) * visible(sx, sy)
        lc += k[..., None] * (col(c) / 255)
    # the top of the rock mass gets little light; faces and floor all of it
    lc = np.where(top[..., None], lc * 0.35, lc)
    return canvas_ * np.clip(lc, 0, 1.25)


def glows(canvas_, sprites, srcs):
    """What shines is drawn on top of the light: mushrooms, crystals, the fire, the shaft of daylight."""
    yy, xx = np.mgrid[0:H, 0:W]
    add = np.zeros((H, W, 3))
    for sp in sprites:
        if sp.glow is None:
            continue
        g = np.zeros((H, W, 4))
        a = np.array(sp.glow).astype(float)
        h, w = a.shape[:2]
        x0, y0 = max(0, sp.x), max(0, sp.y); x1, y1 = min(W, sp.x + w), min(H, sp.y + h)
        g[y0:y1, x0:x1] = a[y0 - sp.y:y1 - sp.y, x0 - sp.x:x1 - sp.x]
        core = g[..., :3] * (g[..., 3:4] / 255)
        add += core * 0.55 + nd.gaussian_filter(core, (9, 9, 0)) * 1.3
    out = canvas_ + add
    # the fire: flames and a warm halo
    for (x, y) in tiles_of("F"):
        fx, fy = px(x + 0.5, y + 0.5)
        fy -= 0.05 * S
        im, d = canvas(W, H)
        for r, c in [(16, (200, 64, 20, 255)), (11, (240, 130, 36, 255)), (6, (255, 214, 130, 255))]:
            d.polygon([(fx - r, fy + 4), (fx - r * 0.3, fy - r * 2.0), (fx, fy - r * 1.2), (fx + r * 0.4, fy - r * 2.4), (fx + r, fy + 4)], fill=c)
        a = np.array(im).astype(float)
        al = a[..., 3:4] / 255
        out = out * (1 - al) + a[..., :3] * al
        halo = np.exp(-((xx - fx) ** 2 + (yy - fy) ** 2) / (2 * 26 ** 2))
        out += halo[..., None] * np.array([90, 40, 10])
        for i in range(30):
            ex = fx + rng.normal(0, 8); ey = fy - 20 - rng.uniform(0, 60)
            if 0 <= int(ey) < H and 0 <= int(ex) < W:
                out[int(ey), int(ex)] = (255, 170, 70)
    # the shaft of daylight: a pale beam falling slant, dust in it
    for (x, y) in tiles_of("*"):
        cx, cy = px(x + 0.5, y + 0.55)
        beam = np.zeros((H, W))
        for k in range(0, 260, 2):
            bx, by = cx + k * 0.35, cy - k
            r = 26 + k * 0.08
            m = ((xx - bx) ** 2) / (r * r) + ((yy - by) ** 2) / (6 * 6) < 1
            beam[m] = np.maximum(beam[m], 1 - k / 260)
        beam = nd.gaussian_filter(beam, 6)
        out += beam[..., None] * np.array([46, 52, 60])
        pool = np.exp(-(((xx - cx) / 40) ** 2 + ((yy - cy) / 22) ** 2))
        out += pool[..., None] * np.array([30, 34, 40])
        for i in range(70):
            k = rng.uniform(0, 200)
            dx = cx + k * 0.35 + rng.normal(0, 14); dy = cy - k + rng.normal(0, 4)
            if 0 <= int(dy) < H and 0 <= int(dx) < W:
                out[int(dy), int(dx)] += 60
    # daylight from the mouth of the cave
    for (x, y) in tiles_of("+"):
        cx, cy = px(x + 0.5, y + 1.0)
        out += np.exp(-(((xx - cx) / 60) ** 2 + ((yy - cy) / 70) ** 2))[..., None] * np.array([70, 74, 62])
    return out


ROCK = None


def render():
    global ROCK
    g, wall, face, top, floor, water, puddle = ground()
    ROCK = wall
    sprites = build()
    cv = g.copy()
    for sp in sorted(sprites, key=lambda s: s.sort):
        if sp.sort < px(0, HERO[1])[1] + 0.82 * S:
            blit(cv, sp.img, sp.x, sp.y)
    lantern = hero(cv)
    for sp in sorted(sprites, key=lambda s: s.sort):
        if sp.sort >= px(0, HERO[1])[1] + 0.82 * S:
            blit(cv, sp.img, sp.x, sp.y)
    srcs = lights(lantern)
    lit = light(cv, top, srcs)
    out = glows(lit, sprites, srcs)
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8)), Image.fromarray(np.clip(cv, 0, 255).astype(np.uint8))


if __name__ == "__main__":
    img, flat = render()
    img.save(f"{OUT}/hoehle_neu.png")
    flat.save(f"{OUT}/hoehle_neu_ohne_licht.png")
    print("ok")
