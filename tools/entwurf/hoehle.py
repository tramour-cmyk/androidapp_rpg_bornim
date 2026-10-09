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

FACE = 84                                # height of a wall face in pixels


def ground():
    yy, xx = np.mgrid[0:H, 0:W]
    n1 = fbm(W, H, 128, 1); n2 = fbm(W, H, 32, 2); n3 = fbm(W, H, 8, 3, 2)

    # where the rock stands: the tile walls with a rough, hand-made edge
    wallm = mask(WALLS, soft=24) + (fbm(W, H, 120, 4) - 0.5) * 0.9 + (fbm(W, H, 56, 5) - 0.5) * 0.7 + (fbm(W, H, 14, 6) - 0.5) * 0.22
    wall = wallm > 0.5
    floor = ~wall

    # rock floor: grey-brown stone, painted grainy like the forest floor
    grain = rng.random((H, W))
    g = lerp(col(0x3A342F), col(0x665E54), n2 * 0.85 + n3 * 0.35 - 0.1)
    g = lerp(g, col(0x4A4038), np.clip((n1 - 0.5) * 3, 0, 1) * 0.55)
    g = g * ((0.9 + 0.2 * fbm(W, H, 3, 31, 2)) * (0.94 + 0.12 * grain))[..., None]
    # specks of lighter and darker stone, like the specks of soil in the forest
    sp = rng.random((H, W))
    g[sp > 0.985] = g[sp > 0.985] * 1.35
    g[sp < 0.012] = g[sp < 0.012] * 0.6
    # the rock rises and falls in low, uneven steps: each ledge has a lit and a shaded lip
    hf = fbm(W, H, 150, 30) + (fbm(W, H, 30, 31) - 0.5) * 0.3
    level = np.floor(hf * 6)
    g = g * (0.9 + 0.05 * (level - level.min()))[..., None]
    g = g * bump(nd.gaussian_filter(level, 1.3), 0.07)[..., None]
    g = g * bump(nd.gaussian_filter(fbm(W, H, 12, 32, 2), 1.0), 0.3)[..., None]
    # where people walk: dust and trodden earth over the stone
    walkway = np.zeros((H, W))
    ax, _ = px(10, 0)
    walkway[:, int(ax + 0.4 * S):int(ax + 1.6 * S)] = 1
    walkway[int(px(0, 10)[1] + 0.2 * S):int(px(0, 11)[1] - 0.1 * S), :] = 1
    walkway[int(px(0, 16)[1] + 0.1 * S):int(px(0, 17)[1] - 0.1 * S), :] = 1
    walkway = nd.gaussian_filter(walkway, 14) * (0.55 + 0.45 * fbm(W, H, 20, 33))
    dust = col(0x5A4E40) * (0.88 + 0.24 * grain)[..., None]
    g = lerp(g, dust, np.clip(walkway * 0.7, 0, 0.6))

    # a few long cracks that wander and fork, dark with a lit lip
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(im)

    def crack(x, y, ang, n, wd):
        pts = [(x, y)]
        for k in range(n):
            ang += rng.normal(0, 0.45)
            step = rng.uniform(6, 14)
            x += math.cos(ang) * step; y += math.sin(ang) * step
            pts.append((x, y))
            if wd > 1 and rng.random() < 0.12:
                crack(x, y, ang + rng.choice([-1, 1]) * rng.uniform(0.5, 1.1), int(rng.integers(3, 8)), 1)
        d.line([(p[0] + 1, p[1] + 1) for p in pts], fill=(130, 120, 104, 60), width=1)
        d.line(pts, fill=(16, 14, 12, 200), width=wd)

    for i in range(38):
        crack(float(rng.integers(0, W)), float(rng.integers(0, H)), rng.uniform(0, math.tau), int(rng.integers(8, 22)), 2 if rng.random() < 0.4 else 1)
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

    # near the mouth the forest comes in: dark earth, old leaves, moss; less of it further inside
    ex, ey = px(11, 20)
    outside = np.exp(-np.hypot(xx - ex, (yy - ey) * 0.8) / (2.2 * S))
    g = lerp(g, col(0x3A2E22) * (0.85 + 0.3 * grain)[..., None], np.clip(outside * 1.4 * (0.6 + 0.6 * n2), 0, 0.85))
    mossy = np.clip((fbm(W, H, 16, 34) - 0.48) * 4, 0, 1) * np.clip(outside * 1.6, 0, 1)
    g = lerp(g, col(0x3A4A26) * (0.8 + 0.4 * grain)[..., None], mossy * 0.8)
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    for i in range(2600):
        x = int(rng.integers(0, W)); y = int(rng.integers(0, H))
        if not floor[y, x] or rng.random() > outside[y, x] * 1.3:
            continue
        c = [(106, 74, 38), (138, 90, 42), (74, 58, 34), (120, 100, 52)][int(rng.integers(0, 4))]
        a_ = rng.uniform(0, math.pi); L = rng.uniform(2, 4)
        d.line([(x - math.cos(a_) * L, y - math.sin(a_) * L * 0.6), (x + math.cos(a_) * L, y + math.sin(a_) * L * 0.6)], fill=c + (255,), width=2)
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
    fc = lerp(col(0x6E665C), col(0x3A342F), v * 0.8 + n3 * 0.25)
    fc = fc * (0.9 + 0.2 * grain)[..., None]
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
    tc = lerp(col(0x1E1C1E), col(0x342E2A), n2 * 0.7 + n3 * 0.4)
    tc = tc * (0.9 + 0.2 * grain)[..., None]
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
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    for i in range(900):
        x = int(rng.integers(0, W)); y = int(rng.integers(0, H))
        if not (face[y, x] and below[y, x] > FACE - 10) or rng.random() > outside[y, x] * 2.5:
            continue
        L = rng.uniform(16, 60); pts = [(x + math.sin(k * 0.8 + i) * 2.5, y + k * L / 6) for k in range(7)]
        d.line(pts, fill=(44, 34, 24, 255), width=2)
        d.line([(p[0] - 1, p[1]) for p in pts], fill=(84, 68, 46, 200), width=1)
    t = np.array(im).astype(float); a = t[..., 3:4] / 255
    g = g * (1 - a) + t[..., :3] * a

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


def cone(d, bx, by, rw, hh, tipdx, cut=0.0, base=0x6E665C):
    """A drip-stone cone from its foot, lit from the left; [cut] breaks off the top part."""
    tip = (bx + tipdx, by - hh)
    top_y = by - hh * (1 - cut)
    n = 18
    for i in range(n):
        f0 = i / n; f1 = (i + 1) / n
        c = shade(base, 1.25 - f0 * 0.85)
        def at(f, yy):
            k = (by - yy) / hh
            return bx - rw + 2 * rw * f + (tip[0] - (bx - rw + 2 * rw * f)) * k
        d.polygon([(at(f0, by - 2), by - 2), (at(f1, by - 2), by - 2), (at(f1, top_y), top_y), (at(f0, top_y), top_y)], fill=c)
    for r in range(4, int(hh * (1 - cut)) - 4, 9):
        ww = rw * (1 - r / hh); cx = bx + tipdx * r / hh
        d.line([(cx - ww, by - 2 - r), (cx + ww, by - 1 - r)], fill=(40, 36, 32, 120))
    d.line([(bx - rw * 0.45, by - 6), (bx - rw * 0.45 + (tip[0] - bx + rw * 0.45) * (1 - cut), top_y + 4)], fill=(170, 164, 150, 110), width=1)
    if cut:
        ww = rw * cut
        cx = bx + tipdx * (1 - cut)
        d.ellipse([cx - ww, top_y - ww * 0.4, cx + ww, top_y + ww * 0.4], fill=shade(base, 1.35))
        d.ellipse([cx - ww * 0.5, top_y - ww * 0.2, cx + ww * 0.6, top_y + ww * 0.25], fill=shade(base, 0.8))
    d.ellipse([bx - rw - 2, by - 6, bx + rw + 2, by + 3], fill=shade(0x4A433C, 1.0))


def stalagmite(seed, big=1.0, variant=0):
    w, h = 110, 160
    im, d = canvas(w, h)
    cx, by = w / 2, h - 18
    shadow(d, cx + 6, by + 2, 30 * big, 10 * big)
    if variant == 0:
        # a tall spike with two or three smaller ones at its foot
        for k, (dx, hh, rw) in enumerate([(0, 108, 20), (-17, 46, 9), (15, 62, 10), (9, 28, 6)]):
            if k and rnd(seed, k) < 0.25:
                continue
            cone(d, cx + dx * big, by, rw * big, hh * big * (0.85 + rnd(seed, k, 1) * 0.3), (rnd(seed, k, 2) - 0.5) * 8)
    elif variant == 1:
        # a thick old stump, its top broken off; the piece lies beside it
        cone(d, cx, by, 27 * big, 96 * big, (rnd(seed, 1) - 0.5) * 6, cut=0.42)
        d.polygon([(cx + 26 * big, by + 2), (cx + 50 * big, by - 6), (cx + 54 * big, by - 1), (cx + 30 * big, by + 6)], fill=shade(0x6E665C, 1.1))
        d.line([(cx + 30 * big, by + 6), (cx + 54 * big, by - 1)], fill=shade(0x3A342F, 1.0), width=2)
    else:
        # two columns grown together over a skirt of flowstone
        sk = [(cx + math.cos(a) * 36 * big * (0.9 + rnd(seed, i) * 0.2), by - 4 + math.sin(a) * 11 * big) for i, a in enumerate(np.linspace(0, math.tau, 16)[:-1])]
        d.polygon(sk, fill=shade(0x7A7264, 0.85))
        for i in range(9):
            x = cx - 30 * big + i * 7.5 * big
            d.line([(x, by - 8), (x + 1, by + 2)], fill=shade(0x7A7264, 1.2))
        cone(d, cx - 11 * big, by - 2, 15 * big, 88 * big, 3, base=0x76705F)
        cone(d, cx + 12 * big, by, 13 * big, 64 * big, -2, base=0x6E665C)
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


def bone(d, x, y, a, L, wd=3):
    b = (206, 196, 172, 255); dk = (120, 110, 92, 255)
    x1, y1 = x + math.cos(a) * L, y + math.sin(a) * L * 0.6
    d.line([(x + 1, y + 2), (x1 + 1, y1 + 2)], fill=(10, 9, 8, 110), width=wd)
    d.line([(x, y), (x1, y1)], fill=dk, width=wd)
    d.line([(x, y - 1), (x1, y1 - 1)], fill=b, width=1)
    for (ex, ey) in [(x, y), (x1, y1)]:
        d.ellipse([ex - 2.5, ey - 2.5, ex + 2.5, ey + 1.5], fill=b)


def skull(d, sx, sy, beast=False):
    b = (206, 196, 172, 255); dk = (120, 110, 92, 255)
    d.ellipse([sx - 7 + 2, sy - 6 + 3, sx + 7 + 2, sy + 6 + 3], fill=(10, 9, 8, 110))
    if beast:
        # a long snout with teeth
        d.ellipse([sx - 7, sy - 7, sx + 6, sy + 4], fill=b)
        d.polygon([(sx + 2, sy - 4), (sx + 16, sy - 1), (sx + 16, sy + 3), (sx + 2, sy + 3)], fill=b)
        for k in range(4):
            d.line([(sx + 5 + k * 3, sy + 3), (sx + 6 + k * 3, sy + 5)], fill=dk)
        d.ellipse([sx - 3, sy - 4, sx + 1, sy], fill=(22, 18, 16, 255))
        return
    d.ellipse([sx - 7, sy - 7, sx + 7, sy + 5], fill=b)
    d.rectangle([sx - 4, sy + 2, sx + 4, sy + 7], fill=b)
    d.ellipse([sx - 5, sy - 3, sx - 1, sy + 1], fill=(22, 18, 16, 255))
    d.ellipse([sx + 1, sy - 3, sx + 5, sy + 1], fill=(22, 18, 16, 255))
    d.line([(sx - 3, sy + 6), (sx + 3, sy + 6)], fill=dk)


def bones(seed, variant=0):
    w, h = 120, 90
    im, d = canvas(w, h)
    cx, by = w / 2, h - 20
    b = (206, 196, 172, 255)
    if variant == 0:
        # scattered bones, a ribcage and a skull
        for i in range(3 + int(rnd(seed) * 3)):
            bone(d, cx + (rnd(seed, i) - 0.5) * 70, by - 16 + (rnd(seed, i, 1) - 0.5) * 34, rnd(seed, i, 2) * math.pi, 9 + rnd(seed, i, 3) * 12)
        rx, ry = cx + 14, by - 22
        for k in range(4):
            d.arc([rx - 12, ry - 6 + k * 4, rx + 12, ry + 8 + k * 4], 200, 340, fill=b, width=1)
        skull(d, cx - 18, by - 10)
    elif variant == 1:
        # what is left of a beast: a spine, ribs bent outwards, the long skull
        sx0, sy0 = cx - 34, by - 18
        pts = [(sx0 + k * 6, sy0 + math.sin(k * 0.5) * 3) for k in range(11)]
        d.line([(p[0] + 1, p[1] + 2) for p in pts], fill=(10, 9, 8, 110), width=4)
        for p in pts:
            d.ellipse([p[0] - 2.5, p[1] - 2, p[0] + 2.5, p[1] + 2], fill=b)
        for k in range(2, 8):
            x, y = pts[k]
            d.arc([x - 4, y - 14, x + 8, y], 180, 320, fill=b, width=2)
            d.arc([x - 4, y, x + 8, y + 12], 30, 170, fill=(150, 140, 120, 255), width=2)
        skull(d, pts[-1][0] + 9, pts[-1][1], beast=True)
        bone(d, cx - 30, by + 2, 0.4, 18)
    else:
        # a heap pushed against the wall, skulls on top
        for i in range(14):
            bone(d, cx + (rnd(seed, i) - 0.5) * 50, by - 10 + (rnd(seed, i, 1) - 0.5) * 18, rnd(seed, i, 2) * math.pi, 8 + rnd(seed, i, 3) * 12)
        for k, (dx, dy) in enumerate([(-10, -14), (6, -12), (-2, -24)]):
            skull(d, cx + dx, by + dy)
    return im, cx, by


def crate(seed, stack=False, variant=0):
    w, h = 100, 120
    im, d = canvas(w, h)
    cx, by = w / 2, h - 14
    shadow(d, cx + 8, by, 34, 10)

    def box(x, y, s, wood, smashed=False):
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
        if smashed:
            # a plank kicked in: a dark hole with splinters
            d.polygon([(x - s * 0.5, y - s * 0.4), (x + s * 0.3, y - s * 0.7), (x + s * 0.5, y - s * 1.2), (x - s * 0.2, y - s * 1.3)], fill=(16, 12, 10, 255))
            for k in range(5):
                sx = x - s * 0.4 + k * s * 0.2
                d.line([(sx, y - s * 0.5), (sx + 2, y - s * 0.75)], fill=shade(wood, 1.3))
        for (nx, ny) in [(x - s + 3, y - 3), (x + s - 3, y - 3), (x - s + 3, y - s * 1.55 + 3), (x + s - 3, y - s * 1.55 + 3)]:
            d.point((nx, ny), fill=(30, 30, 34, 255))

    if variant == 0:
        box(cx, by, 22, 0x6A4A30)
        if stack:
            box(cx + 3, by - 36, 17, 0x5E4230)
    elif variant == 1:
        # a barrel with iron hoops, its lid half open
        wood = 0x5E4228
        for i in range(12):
            f = i / 12
            x0 = cx - 20 + 40 * f; x1 = cx - 20 + 40 * (f + 1 / 12)
            l = 1.2 - abs(f - 0.3) * 1.1
            d.rectangle([x0, by - 52, x1, by], fill=shade(wood, l))
        for yy in (by - 46, by - 26, by - 6):
            d.rectangle([cx - 21, yy - 2, cx + 21, yy + 2], fill=shade(0x3E3C40, 1.1))
        d.ellipse([cx - 20, by - 60, cx + 20, by - 46], fill=shade(wood, 0.6))
        d.ellipse([cx - 15, by - 57, cx + 15, by - 49], fill=(14, 12, 10, 255))
        d.polygon([(cx - 6, by - 58), (cx + 24, by - 70), (cx + 28, by - 62), (cx - 2, by - 50)], fill=shade(wood, 1.15))
    else:
        # sacks of stolen grain against a smashed crate
        box(cx + 12, by - 4, 16, 0x5A4030, smashed=True)
        for k, (dx, dy, r) in enumerate([(-22, 0, 15), (-6, 4, 13)]):
            x, y = cx + dx, by + dy
            d.ellipse([x - r + 3, y - 4, x + r + 3, y + 5], fill=(8, 7, 6, 120))
            d.rounded_rectangle([x - r, y - r * 2.2, x + r, y + 2], r * 0.7, fill=shade(0x7A6A4A, 0.8))
            d.rounded_rectangle([x - r * 0.85, y - r * 2.1, x + r * 0.2, y - r * 0.4], r * 0.5, fill=shade(0x7A6A4A, 1.05))
            for k2 in range(3):
                d.line([(x - r * 0.6 + k2 * r * 0.5, y - r * 1.8), (x - r * 0.5 + k2 * r * 0.5, y - 2)], fill=shade(0x7A6A4A, 0.6))
            d.line([(x - 3, y - r * 2.15), (x + 3, y - r * 2.15)], fill=shade(0x3A2A1A, 1.0), width=3)
            d.line([(x, y - r * 2.2), (x + 2, y - r * 2.6)], fill=shade(0x7A6A4A, 0.9), width=3)
    return im, cx, by


def bedroll(seed, variant=0):
    w, h = 120, 80
    im, d = canvas(w, h)
    cx, by = w / 2, h - 18
    shadow(d, cx + 5, by, 46, 10)
    if variant == 0:
        # a pelt flat on the stone, ragged at the edge, and a grubby blanket thrown over half of it
        fur = 0x5A4634
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
    elif variant == 1:
        # old straw, trampled flat, with a torn sack as a cover
        for k in range(420):
            x = cx + (rnd(seed, k) - 0.5) * 84; y = by - 13 + (rnd(seed, k, 1) - 0.5) * 26
            if ((x - cx) / 44) ** 2 + ((y - by + 13) / 15) ** 2 > 1:
                continue
            a = rnd(seed, k, 2) * math.pi
            c = [0x8A7444, 0x6A5630, 0xA48C52][k % 3]
            d.line([(x, y), (x + math.cos(a) * 6, y + math.sin(a) * 3)], fill=shade(c, 0.9), width=1)
        d.polygon([(cx - 10, by - 22), (cx + 20, by - 26), (cx + 26, by - 8), (cx + 6, by - 2), (cx - 8, by - 8)], fill=shade(0x6A5A40, 0.75))
        d.line([(cx + 6, by - 2), (cx + 10, by - 12), (cx + 4, by - 16)], fill=shade(0x2A2018, 1.0))
    else:
        # a bedroll still tied up, a bundle beside it
        d.rounded_rectangle([cx - 30, by - 22, cx + 22, by - 4], 8, fill=shade(0x4A4238, 0.9))
        d.rounded_rectangle([cx - 30, by - 22, cx + 22, by - 15], 6, fill=shade(0x4A4238, 1.2))
        d.ellipse([cx + 14, by - 22, cx + 28, by - 4], fill=shade(0x4A4238, 0.75))
        d.ellipse([cx + 17, by - 18, cx + 25, by - 8], fill=shade(0x4A4238, 0.5))
        for x in (cx - 18, cx + 6):
            d.rectangle([x, by - 23, x + 4, by - 3], fill=shade(0x2E2218, 1.0))
        d.ellipse([cx - 46, by - 20, cx - 30, by - 4], fill=shade(0x5A4A34, 0.9))
        d.line([(cx - 38, by - 20), (cx - 37, by - 26)], fill=shade(0x5A4A34, 0.7), width=2)
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
    """Two old posts at the sides of a 2-tile passage with a sagging beam over it."""
    w, h = 2 * S + 40, 160
    im, d = canvas(w, h)
    by = h - 20
    wood = 0x3E2E22
    lx, rx = 26, w - 26
    tops = []
    for i, x in enumerate((lx, rx)):
        tx = x + (rnd(seed, i, 1) - 0.5) * 9; ty = by - 112
        d.ellipse([x - 12, by - 4, x + 14, by + 6], fill=(6, 5, 6, 120))
        d.polygon([(x - 7, by), (x + 7, by), (tx + 7, ty), (tx - 7, ty)], fill=shade(wood, 0.9))
        d.polygon([(x - 7, by), (x - 3, by), (tx - 3, ty), (tx - 7, ty)], fill=shade(wood, 1.25))
        d.polygon([(x + 3, by), (x + 7, by), (tx + 7, ty), (tx + 3, ty)], fill=shade(wood, 0.55))
        # splits along the grain, and a rotten foot
        for k in range(5):
            y0 = by - 8 - rnd(seed, i, k) * 96; L = 10 + rnd(seed, i, k, 1) * 22
            xx = x + (tx - x) * (by - y0) / 112 + (rnd(seed, i, k, 2) - 0.5) * 8
            d.line([(xx, y0), (xx + (tx - x) * L / 112, y0 - L)], fill=shade(wood, 0.3))
        d.polygon([(x - 7, by), (x + 7, by), (x + 6, by - 8), (x - 4, by - 12)], fill=shade(0x2A2018, 1.0))
        tops.append((tx, ty))
    (ax, ay), (bx, byy) = tops
    sag = 4 + rnd(seed, 3) * 6
    mx, my = (ax + bx) / 2, (ay + byy) / 2 + sag
    beam = [(ax - 14, ay - 14), (mx, my - 14), (bx + 14, byy - 14), (bx + 14, byy + 2), (mx, my + 2), (ax - 14, ay + 2)]
    d.polygon(beam, fill=shade(wood, 0.8))
    d.polygon([(ax - 14, ay - 14), (mx, my - 14), (bx + 14, byy - 14), (bx + 14, byy - 10), (mx, my - 10), (ax - 14, ay - 10)], fill=shade(wood, 1.15))
    d.line([(ax - 14, ay + 2), (mx, my + 2), (bx + 14, byy + 2)], fill=shade(wood, 0.35), width=2)
    d.line([(ax, ay - 5), (mx - 10, my - 6), (mx + 6, my - 4)], fill=shade(wood, 0.35))
    # wedges driven in between the beam and the rock, stones resting on it
    for f in (0.15, 0.5, 0.82):
        x = ax + (bx - ax) * f; y = ay - 14 + (sag if 0.3 < f < 0.7 else sag * 0.5)
        d.polygon([(x - 6, y), (x + 6, y), (x + 2, y - 9), (x - 3, y - 9)], fill=shade(0x5A4632, 1.0))
    for k in range(6):
        x = ax + 8 + rnd(seed, k, 7) * (bx - ax - 16); y = ay - 14 + sag * 0.7
        r = 3 + rnd(seed, k, 8) * 4
        d.polygon([(x - r, y), (x + r, y), (x + r * 0.6, y - r * 1.2), (x - r * 0.7, y - r)], fill=shade(0x5E574F, 0.8 + rnd(seed, k, 9) * 0.4))
    for (x, y) in tops:
        d.rectangle([x - 8, y - 4, x + 8, y + 1], fill=(30, 28, 30, 255))
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

    for k, (x, y) in enumerate(tiles_of("i")):
        im, ax, ay = stalagmite(hsh(x, y), 1.0, k % 3); add(im, ax, ay, x, y)
    for (x, y) in tiles_of("r"):
        im, ax, ay = boulder(hsh(x, y)); add(im, ax, ay, x, y)
    for (x, y) in tiles_of("%"):
        im, ax, ay = rubble(hsh(x, y)); add(im, ax, ay, x, y, oy=0.8)
    for k, (x, y) in enumerate(tiles_of("j")):
        im, ax, ay = bones(hsh(x, y), (k + 1) % 3); add(im, ax, ay, x, y, oy=0.75)
    for k, (x, y) in enumerate(tiles_of("u")):
        im, ax, ay = crate(hsh(x, y), stack=True, variant=(k * 2) % 3); add(im, ax, ay, x, y, oy=0.85)
    for k, (x, y) in enumerate(tiles_of("e")):
        im, ax, ay = bedroll(hsh(x, y), k % 3); add(im, ax, ay, x, y, oy=0.75)
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
            im, ax, ay = stalagmite(hsh(tx, ty, 5), 0.45, hsh(tx, ty) % 3)
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
    lc = np.where(top[..., None], lc * 0.5, lc)
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
        out += np.exp(-(((xx - cx) / 70) ** 2 + ((yy - cy) / 90) ** 2))[..., None] * np.array([40, 34, 22])
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


def sheet():
    """Three looks each of the things that repeat, side by side."""
    cw, ch = 150, 170
    rows = [("Stalagmiten", lambda v: stalagmite(5 + v, 1.0, v)), ("Kisten und Vorräte", lambda v: crate(7 + v, True, v)),
            ("Knochen", lambda v: bones(9 + v, v)), ("Schlafplätze", lambda v: bedroll(3 + v, v))]
    W2, H2 = 3 * cw + 160, len(rows) * ch
    yy, xx = np.mgrid[0:H2, 0:W2]
    bg = lerp(col(0x3A342F), col(0x665E54), fbm(W2, H2, 24, 2) * 0.8 + fbm(W2, H2, 6, 3, 2) * 0.3) * (0.94 + 0.12 * np.random.default_rng(1).random((H2, W2)))[..., None]
    cv = bg * 0.8
    for r, (name, f) in enumerate(rows):
        for v in range(3):
            im, ax, ay = f(v)
            blit_any(cv, im, int(160 + v * cw + cw / 2 - ax), int(r * ch + ch - 22 - ay))
    out = Image.fromarray(np.clip(cv, 0, 255).astype(np.uint8))
    d = ImageDraw.Draw(out)
    for r, (name, _) in enumerate(rows):
        d.text((10, r * ch + ch / 2 - 6), name, fill=(220, 212, 196))
    return out


def blit_any(cv, img, x, y):
    a = np.array(img).astype(float); h, w = a.shape[:2]; Hc, Wc = cv.shape[:2]
    x0, y0, x1, y1 = max(0, x), max(0, y), min(Wc, x + w), min(Hc, y + h)
    sub = a[y0 - y:y1 - y, x0 - x:x1 - x]; al = sub[..., 3:4] / 255
    cv[y0:y1, x0:x1] = cv[y0:y1, x0:x1] * (1 - al) + sub[..., :3] * al


if __name__ == "__main__":
    sheet().save(f"{OUT}/hoehle_varianten.png")
    img, flat = render()
    img.save(f"{OUT}/hoehle_neu.png")
    flat.save(f"{OUT}/hoehle_neu_ohne_licht.png")
    print("ok")
