"""Prototype: things in the cave painted the way the ground and the rock are (sample sheet).

Instead of smooth shapes with flat fills, every thing is painted pixel by pixel: a body grown out of
its outline (height and light from the top left), the grain of its material (drip-stone, wood, bone,
fur, cloth), dirt, soot and wet on top, a broken outline and a soft shadow on the ground.

Usage: python3 hoehle_dinge.py <out dir>      (uses hoehle.py next to it for the old look and the floor)
"""
import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as nd

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import hoehle as old  # noqa: E402

OUT = sys.argv[1] if len(sys.argv) > 1 else "."
LIGHT = np.array([-0.5, -0.62, 0.6]); LIGHT = LIGHT / np.linalg.norm(LIGHT)


def col(h):
    return np.array([(h >> 16) & 255, (h >> 8) & 255, h & 255], dtype=float)


def noise(w, h, cell, seed, octaves=3):
    return old.fbm(w, h, max(2, cell), seed, octaves)


def stretched(w, h, sx, sy, seed):
    """Noise drawn out along one direction (wood grain, fur, flow lines)."""
    big = old.fbm(int(w / sx) + 4, int(h / sy) + 4, 3, seed, 3)
    ys = np.clip((np.arange(h) / sy).astype(int), 0, big.shape[0] - 1)
    xs = np.clip((np.arange(w) / sx).astype(int), 0, big.shape[1] - 1)
    return nd.gaussian_filter(big[ys][:, xs], 0.7)


class Layer:
    """A painted thing: colour, coverage and height per pixel."""

    def __init__(self, w, h):
        self.w, self.h = w, h
        self.c = np.zeros((h, w, 3)); self.a = np.zeros((h, w)); self.z = np.zeros((h, w))

    def put(self, mask, colour, height, alpha=1.0):
        """Paint [colour] where [mask], in front of what is there if [height] is higher (or always)."""
        m = mask & ((height >= self.z) | (self.a < 0.5))
        al = (alpha if np.ndim(alpha) == 0 else alpha[m]) if np.ndim(alpha) else alpha
        self.c[m] = colour[m] if colour.ndim == 3 else colour
        self.a[m] = np.maximum(self.a[m], al)
        self.z[m] = height[m] if np.ndim(height) else height

    def image(self):
        out = np.dstack([np.clip(self.c, 0, 255), np.clip(self.a, 0, 1) * 255]).astype(np.uint8)
        return Image.fromarray(out, "RGBA")


def inflate(mask, radius):
    """Height of a body grown out of its outline: round at the rim, flat-topped further in."""
    d = nd.distance_transform_edt(mask)
    t = np.clip(d / radius, 0, 1)
    return np.sqrt(1 - (1 - t) ** 2) * radius


def lit(height, bump=None, k=1.0, amb=0.32):
    """Light from the top left on a height field, with soft occlusion in hollows."""
    hf = height + (bump if bump is not None else 0)
    gy, gx = np.gradient(nd.gaussian_filter(hf, 0.6))
    n = np.dstack([-gx * k, -gy * k, np.ones_like(hf)])
    n /= np.linalg.norm(n, axis=2, keepdims=True)
    lam = np.clip((n * LIGHT).sum(axis=2), 0, 1)
    ao = np.clip(1 - (nd.gaussian_filter(hf, 5) - hf) * 0.06, 0.55, 1.05)
    return (amb + (1 - amb) * 1.2 * lam) * ao


def broken(mask, seed, amount=1.6):
    """Break up a clean outline: chips and crumbs at the edge."""
    h, w = mask.shape
    d_in = nd.distance_transform_edt(mask); d_out = nd.distance_transform_edt(~mask)
    sd = np.where(mask, d_in, -d_out)
    return sd + (noise(w, h, 4, seed, 2) - 0.5) * amount * 2 > 0


def grain(w, h, seed, k=0.14):
    return 1 - k / 2 + k * np.random.default_rng(seed).random((h, w))


def ground_shadow(w, h, mask, foot_y, spread=1.0):
    """A soft, flat shadow where the thing stands, thrown a little to the lower right."""
    s = np.zeros((h, w))
    rows = np.where(mask.any(axis=1))[0]
    cols = np.where(mask.any(axis=0))[0]
    if len(cols) == 0:
        return s
    cx = (cols[0] + cols[-1]) / 2 + 6; rx = (cols[-1] - cols[0]) / 2 * 0.95 * spread + 6
    yy, xx = np.mgrid[0:h, 0:w]
    e = ((xx - cx) / rx) ** 2 + ((yy - foot_y - 2) / (rx * 0.32)) ** 2
    s = np.clip(1.1 - e, 0, 1) ** 1.5
    return nd.gaussian_filter(s, 3) * 0.75


def finish(L, shadow):
    """Shadow under the thing, then the thing."""
    out = np.zeros((L.h, L.w, 4))
    out[..., 3] = shadow * 200
    out[..., :3] = 8
    a = L.a[..., None]
    out[..., :3] = out[..., :3] * (1 - a) + L.c * a
    out[..., 3] = np.maximum(out[..., 3], L.a * 255)
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGBA")


# ------------------------------------------------------------------ drip-stone

def stalagmite(seed, variant=0):
    w, h = 120, 170
    yy, xx = np.mgrid[0:h, 0:w]
    rng = np.random.default_rng(seed)
    foot = h - 22
    L = Layer(w, h)
    cols = {0: [(0, 92, 21), (-22, 42, 12), (19, 58, 13)],
            1: [(0, 62, 28)],
            2: [(-12, 98, 15), (11, 74, 14), (0, 36, 22)]}[variant]
    body = np.zeros((h, w), bool); top_of = np.zeros((h, w))
    for i, (dx, hh, rw) in enumerate(cols):
        cx = w / 2 + dx
        t = np.clip((foot - yy) / hh, 0, 1.2)
        # the width swells and narrows in rings of sinter, the column leans a little
        lean = (rng.random() - 0.5) * 10 * t
        ring = 1 + 0.07 * np.sin((foot - yy) * 0.42 + i * 2) + (noise(w, h, 14, seed + i) - 0.5) * 0.12
        # narrowing upwards, then a blunt, rounded top (where the drip lands it builds a dome, no spike)
        width = rw * (1 - 0.55 * np.clip(t, 0, 1)) * np.sqrt(np.clip(1 - np.clip(t, 0, 1) ** 6, 0, 1)) * ring
        if variant == 1:
            width = rw * (1 - 0.45 * t) * ring          # a stump: its top broken off
        m = (np.abs(xx - cx - lean) < width) & (yy <= foot + 2) & (yy >= foot - hh)
        body |= m
        top_of = np.maximum(top_of, np.where(m, i + 1, 0))
    # flowstone skirt at the foot, spreading over the floor
    skirt = ((xx - w / 2) / (sum(abs(c[0]) for c in cols) / len(cols) + 30)) ** 2 + ((yy - foot) / 9) ** 2 < 1 + (noise(w, h, 6, seed + 9) - 0.5) * 0.9
    shape = broken(body | skirt, seed + 3, 0.7)
    hgt = inflate(shape, 16) + np.where(skirt & ~body, -6, 0)
    rings = np.sin((foot - yy) * 0.42) * 1.0
    # flow lines running down, wet sheen on the lit side, dirt and soot towards the foot
    flow = stretched(w, h, 1.2, 14, seed + 5)
    alb = col(0x847A68)[None, None] * np.ones((h, w, 1))
    alb = alb * (0.86 + 0.24 * flow)[..., None]
    alb = alb * (0.92 + 0.16 * noise(w, h, 5, seed + 6))[..., None]
    up = np.clip((foot - yy) / 110, 0, 1)
    alb = alb * (0.66 + 0.45 * up)[..., None]
    alb = alb * (1 + 0.08 * np.sin((foot - yy) * 0.42 + 1.2))[..., None]
    dirt = np.clip((noise(w, h, 7, seed + 7) - 0.45) * 3, 0, 1) * (1 - up) ** 2
    alb = alb * (1 - dirt * 0.45)[..., None] + col(0x2A231C) * (dirt * 0.25)[..., None]
    if variant == 1:
        # the broken top: a pale, rough break, with a fresh lighter rim
        topmask = shape & (yy < foot - 62 + 9) & (yy > foot - 62 - 6)
        alb[topmask] = alb[topmask] * 1.25 + 12
    shade_ = lit(hgt, (noise(w, h, 4, seed + 8, 2) - 0.5) * 1.2 + flow * 1.2 + rings, 0.9)
    c = alb * shade_[..., None] * grain(w, h, seed)[..., None]
    sheen = shape & (shade_ > 1.0) & (flow > 0.5) & (up > 0.15)
    c[sheen] = c[sheen] * 0.6 + np.array([150, 150, 140]) * 0.4
    if variant != 1:
        # the wet crown of each column, where the drop falls, with a little dimple
        for i, (dx, hh, rw) in enumerate(cols):
            tx = w / 2 + dx; ty = foot - hh + 4
            wetc = shape & (((xx - tx + 2) / (rw * 0.45)) ** 2 + ((yy - ty) / (rw * 0.22)) ** 2 < 1)
            c[wetc] = c[wetc] * 0.55 + np.array([168, 166, 156]) * 0.45
            dim = ((xx - tx) / 2.2) ** 2 + ((yy - ty + 1) / 1.2) ** 2 < 1
            c[dim & shape] = c[dim & shape] * 0.55
    L.put(shape, c, hgt)
    if variant == 1:
        # the broken-off piece lying beside it, half in the dust
        # a short, thick piece with a jagged break at one end
        pc = (((xx - w / 2 - 36) / 17) ** 2 + ((yy - foot - 1) / 8) ** 2 < 1) & (xx < w / 2 + 50 + (noise(w, h, 3, seed + 13) - 0.5) * 8)
        pc = broken(pc, seed + 11, 0.8)
        ph = inflate(pc, 6)
        pcol = col(0x766E60)[None, None] * (0.75 + 0.4 * stretched(w, h, 10, 1.5, seed + 12))[..., None] * lit(ph, None, 1.2)[..., None]
        L.put(pc, pcol, ph + 50)
    return finish(L, ground_shadow(w, h, shape, foot, 0.9)), w / 2, foot


# ------------------------------------------------------------------ a goblin crate

def crate(seed, variant=0):
    w, h = 110, 120
    yy, xx = np.mgrid[0:h, 0:w]
    rng = np.random.default_rng(seed)
    L = Layer(w, h)
    foot = h - 18

    def box(cx, by, s, tilt, seedb, smashed=False):
        # front face and top face in the oblique view, corner posts, planks of uneven width with gaps
        fx0, fx1 = cx - s, cx + s
        fh = s * 1.3; th = s * 1.05
        sk = (by - yy) * tilt * 0.03                     # the box stands a little crooked
        front = (xx >= fx0 + sk) & (xx <= fx1 + sk) & (yy <= by) & (yy >= by - fh)
        top = (yy < by - fh) & (yy >= by - fh - th) & (xx >= fx0 + sk) & (xx <= fx1 + sk)
        whole = broken(front | top, seedb, 1.0)
        front &= whole; top &= whole
        wood = col(0x5A4836)
        # planks run left to right on the front; on the lid they run front to back (seen as upright stripes)
        edges_f = by - np.cumsum(rng.uniform(6, 11, 10))
        edges_t = fx0 + np.cumsum(rng.uniform(7, 11, 10))
        rowf = np.searchsorted(-edges_f, -yy); colt = np.searchsorted(edges_t, xx - sk)
        gap = np.zeros_like(front)
        for e in edges_f:
            gap |= front & (np.abs(yy - e) < 0.8)
        for e in edges_t:
            gap |= top & (np.abs(xx - sk - e) < 0.7)
        gh = stretched(w, h, 10, 1.1, seedb)
        gv = stretched(w, h, 1.1, 8, seedb + 3)
        tone = 0.8 + 0.36 * (old.hsh_arr(np.where(top, colt + 50, rowf) + seedb) % 100) / 100
        c = wood * (tone * np.where(top, 0.72 + 0.5 * gv, 0.72 + 0.5 * gh))[..., None]
        c = np.where(top[..., None], c * 1.2, c * 0.7)
        c[gap] *= 0.35
        # two battens across the lid, nailed at the ends
        for f in (0.22, 0.78):
            by_ = by - fh - th * f
            batt = top & (np.abs(yy - by_) < 2.6)
            c[batt] = wood * 1.05 * (0.75 + 0.45 * gh[batt])[..., None]
            c[top & (np.abs(yy - by_ - 2.6) < 0.8)] *= 0.55
            for nx in (fx0 + 4, fx1 - 4):
                c[top & ((xx - nx - sk) ** 2 + (yy - by_) ** 2 < 1.8)] = col(0x3A2418)
        # the near edge of the lid catches the light
        lip = top & (yy > by - fh - 2.5)
        c[lip] = c[lip] * 1.35
        # corner posts on the front, nailed
        for bx in (fx0 + 3, fx1 - 3):
            post = front & (np.abs(xx - bx - sk) < 3.5)
            c[post] = wood[None] * 0.8 * (0.8 + 0.4 * stretched(w, h, 1.1, 6, seedb + 1)[post])[..., None]
            for k in range(3):
                ny = by - 4 - k * fh / 2.5
                nail = (xx - bx - sk) ** 2 + (yy - ny) ** 2 < 2.0
                c[nail & front] = col(0x3A2418)
        if smashed:
            # one plank of the front kicked in: a dark gap with splintered ends
            band = front & (yy < by - fh * 0.38) & (yy > by - fh * 0.68) & (np.abs(xx - cx - sk + 3) < s * 0.62 + (noise(w, h, 2, seedb + 4) - 0.5) * 9)
            c[band] = col(0x0E0B09)
            spl = nd.binary_dilation(band, iterations=2) & ~band & front
            c[spl] = c[spl] * 1.4
        # grime: dark at the bottom and in the corners, soot
        low = np.clip((yy - (by - fh)) / fh, 0, 1) * front
        grime = np.clip((noise(w, h, 6, seedb + 5) - 0.4) * 2.5, 0, 1) * (0.3 + 0.7 * low)
        c = c * (1 - 0.45 * grime)[..., None]
        c = c * grain(w, h, seedb, 0.16)[..., None]
        L.put(front | top, c, np.where(top, by + 0.5, by) + 0 * xx)
        return front | top

    if variant == 0:
        m1 = box(w / 2 - 3, foot, 23, 1.0, seed)
        m2 = box(w / 2 + 5, foot - 38, 16, -1.0, seed + 20)
        m = m1 | m2
    else:
        m = box(w / 2 + 6, foot - 2, 18, 0.5, seed, smashed=True)
    return finish(L, ground_shadow(w, h, m, foot, 1.0)), w / 2, foot


# ------------------------------------------------------------------ bones

def bones(seed, variant=0):
    w, h = 130, 100
    yy, xx = np.mgrid[0:h, 0:w]
    rng = np.random.default_rng(seed)
    L = Layer(w, h)
    foot = h - 24
    ivory = col(0x9C8E6E)
    allm = np.zeros((h, w), bool)

    def bone(x0, y0, ang, length, r, z):
        x1, y1 = x0 + math.cos(ang) * length, y0 + math.sin(ang) * length * 0.55
        dx, dy = x1 - x0, y1 - y0
        t = np.clip(((xx - x0) * dx + (yy - y0) * dy) / (dx * dx + dy * dy + 1e-6), 0, 1)
        px_, py_ = x0 + t * dx, y0 + t * dy
        dist = np.hypot(xx - px_, (yy - py_) * 1.2)
        # thin shaft, knobbly ends
        knob = np.exp(-((t - 0) / 0.12) ** 2) + np.exp(-((t - 1) / 0.12) ** 2)
        m = dist < r * (0.75 + 0.75 * knob)
        m = broken(m, int(rng.integers(0, 1e6)), 0.6)
        hgt = inflate(m, r * 1.6) + z
        return m, hgt

    def skull(cx, cy, z, s=1.0, beast=False):
        e = ((xx - cx) / (8 * s)) ** 2 + ((yy - cy) / (7 * s)) ** 2 < 1
        jaw = (np.abs(xx - cx) < 5 * s) & (yy > cy) & (yy < cy + 8 * s)
        if beast:
            jaw = (xx > cx) & (xx < cx + 18 * s) & (np.abs(yy - cy - 1 - (xx - cx) * 0.08) < 4.2 * s)
        m = broken(e | jaw, int(rng.integers(0, 1e6)), 0.6)
        hgt = inflate(m, 6 * s) + z
        hole = np.zeros_like(m)
        for ex in ([-3.2, 3.2] if not beast else [-1.5]):
            hole |= ((xx - cx - ex * s) / (2.6 * s)) ** 2 + ((yy - cy + 0.5 * s) / (2.2 * s)) ** 2 < 1
        if not beast:
            hole |= ((xx - cx) / (1.2 * s)) ** 2 + ((yy - cy - 3.4 * s) / (1.4 * s)) ** 2 < 1
            teeth = (np.abs(yy - cy - 6 * s) < 0.9) & (np.abs(xx - cx) < 4 * s) & ((xx.astype(int) % 2) == 0)
            hole |= teeth
        else:
            teeth = (np.abs(yy - cy - 3.5 * s) < 1.2) & (xx > cx + 4) & (xx < cx + 17 * s) & ((xx.astype(int) % 3) == 0)
            hole |= teeth
        hgt = np.where(hole, hgt - 6, hgt)
        return m, hgt, hole & m

    parts = []
    if variant == 0:
        for i in range(16):
            parts.append(bone(w / 2 + rng.normal(0, 18), foot - 10 + rng.normal(0, 7), rng.uniform(0, math.pi), rng.uniform(10, 24), rng.uniform(1.6, 2.6), rng.uniform(0, 6)) + (None,))
        for (dx, dy, s) in [(-10, -20, 1.0), (8, -18, 0.9), (-1, -30, 1.0)]:
            parts.append(skull(w / 2 + dx, foot + dy, 14 + (-dy) * 0.3, s))
    else:
        # what scavengers left of a beast: a crooked spine pulled apart, ribs broken and scattered,
        # the skull twisted away, a dark old stain under it and tufts of hide
        stm = ((xx - w / 2 + 4) / 44) ** 2 + ((yy - foot + 12) / 13) ** 2 + (noise(w, h, 6, seed + 20) - 0.5) * 1.1 < 1
        L.put(stm, col(0x2A1E16) * (0.8 + 0.4 * noise(w, h, 4, seed + 21))[..., None], np.zeros((h, w)) - 1)
        sx0 = w / 2 - 36
        x, y, a = sx0, foot - 12, -0.15
        spine = []
        for k in range(13):
            a += rng.normal(0, 0.18)
            x += math.cos(a) * (5.2 + (4 if k in (5, 9) else 0)); y += math.sin(a) * 4
            spine.append((x, y))
        for k, (x, y) in enumerate(spine):
            r = 3.2 - k * 0.08
            m = ((xx - x) / r) ** 2 + ((yy - y) / (r * 0.8)) ** 2 < 1
            parts.append((m, inflate(m, 3) + 6, None))
        for k in range(2, 10):
            x, y = spine[k]
            for side in (-1, 1):
                if rng.random() < 0.25:
                    continue                      # torn out
                L_ = rng.uniform(7, 14) * (0.6 if rng.random() < 0.3 else 1)
                bend = rng.uniform(0.6, 1.4)
                pts = [(x + math.sin(u * bend) * L_ * 0.5 + u * 3, y + side * (u * L_ * 0.75)) for u in np.linspace(0, 1, 8)]
                rib = np.zeros((h, w), bool)
                for (px_, py_) in pts:
                    rib |= (xx - px_) ** 2 + (yy - py_) ** 2 < 1.5 ** 2
                parts.append((broken(rib, k * 7 + side, 0.4), inflate(rib, 2) + (8 if side < 0 else 3), None))
        for i in range(3):
            # loose ribs and a leg bone, dragged off
            parts.append(bone(w / 2 + rng.uniform(-40, 30), foot + rng.uniform(-2, 6), rng.uniform(0, math.pi), rng.uniform(9, 20), 1.6 if i else 2.4, 1) + (None,))
        hx, hy = spine[-1]
        parts.append(skull(hx + 10, hy + 5, 10, 0.85, beast=True))
        # tufts of hide still stuck to the bones
        for i in range(5):
            tx, ty = spine[int(rng.integers(1, 10))]
            tuft = ((xx - tx - rng.normal(0, 3)) / 4) ** 2 + ((yy - ty - rng.normal(0, 3)) / 2.5) ** 2 + (np.random.default_rng(i).random((h, w)) - 0.5) * 0.8 < 1
            L.put(tuft, col(0x3E3228) * (0.7 + 0.6 * np.random.default_rng(i + 9).random((h, w)))[..., None], np.zeros((h, w)) + 30)
    stain = col(0x5A4A32)
    for p in parts:
        m, hgt = p[0], p[1]
        allm |= m
        if variant == 1:
            allm |= stm
        a = ivory * (0.8 + 0.35 * noise(w, h, 3, seed + 3))[..., None]
        # yellowed, stained brown in places, pitted
        st = np.clip((noise(w, h, 6, seed + 4) - 0.45) * 3, 0, 1)
        a = a * (1 - st * 0.5)[..., None] + stain * (st * 0.3)[..., None]
        pits = np.random.default_rng(seed + 5).random((h, w)) < 0.04
        a[pits] *= 0.6
        c = a * lit(hgt, None, 1.1, amb=0.4)[..., None]
        if p[2] is not None:
            c[p[2]] = col(0x18120E)
        L.put(m, c, hgt)
    # half in the dust: the lowest bits fade into the floor
    dust = np.clip((yy - foot + 4) / 10, 0, 1) * (0.5 + 0.5 * noise(w, h, 4, seed + 6))
    L.c = L.c * (1 - dust * 0.6)[..., None] + col(0x4A4238) * (dust * 0.6)[..., None]
    return finish(L, ground_shadow(w, h, allm, foot, 0.8)), w / 2, foot


# ------------------------------------------------------------------ a sleeping place

def bedroll(seed, variant=0):
    w, h = 130, 80
    yy, xx = np.mgrid[0:h, 0:w]
    rng = np.random.default_rng(seed)
    L = Layer(w, h)
    foot = h - 16
    cx, cy = w / 2, foot - 16
    if variant == 0:
        # a wolf hide: the head with ears and empty eyes at one end, legs spread, a tail; the fur lies
        # outwards from the dark line of the back, light at the tips, dark at the roots, worn bald in places
        e = ((xx - cx - 2) / 34) ** 2 + ((yy - cy) / 13) ** 2 < 1
        head = ((xx - cx + 40) / 11) ** 2 + ((yy - cy) / 8) ** 2 < 1
        snout = ((xx - cx + 52) / 8) ** 2 + ((yy - cy) / 4.5) ** 2 < 1
        ears = ((xx - cx + 38) / 4) ** 2 + ((yy - cy + 9) / 4) ** 2 < 1
        ears |= ((xx - cx + 38) / 4) ** 2 + ((yy - cy - 9) / 4) ** 2 < 1
        tail = (np.abs(yy - cy - np.sin((xx - cx) * 0.1) * 2) < 4.5 * np.clip(1 - (xx - cx - 34) / 22, 0, 1)) & (xx > cx + 30)
        legs = np.zeros((h, w), bool)
        for (lx, sy) in [(-22, -1), (-22, 1), (22, -1), (22, 1)]:
            for u in np.linspace(0, 1, 9):
                px_ = cx + lx + (8 if lx > 0 else -8) * u * 0.6; py_ = cy + sy * (11 + 9 * u)
                legs |= (xx - px_) ** 2 + (yy - py_) ** 2 < (3.6 - u * 1.4) ** 2
        pelt = broken(e | head | snout | ears | tail | legs, seed, 1.2)
        base = col(0x4A4038)
        under = base * 0.45 * np.ones((h, w, 1))
        img = Image.new("RGBA", (w, h), (0, 0, 0, 0)); d = ImageDraw.Draw(img)
        for i in range(3200):
            x = rng.uniform(0, w); y = rng.uniform(0, h)
            if not pelt[int(y), int(x)]:
                continue
            side = 1 if y > cy else -1
            ang = math.atan2(side * 1.0, 0.55 if x > cx - 30 else -0.4) + rng.normal(0, 0.35)
            if tail[int(y), int(x)]:
                ang = rng.normal(0, 0.3)
            L_ = rng.uniform(3, 6)
            back = abs(y - cy) < 3.5 and not head[int(y), int(x)]
            k = 0.55 if back else rng.uniform(0.75, 1.2)
            root = tuple(int(v) for v in base * 0.55 * k); tip = tuple(int(min(255, v)) for v in base * 1.35 * k + 14)
            x1, y1 = x + math.cos(ang) * L_, y + math.sin(ang) * L_ * 0.6
            d.line([(x, y), ((x + x1) / 2, (y + y1) / 2)], fill=root + (255,), width=1)
            d.line([((x + x1) / 2, (y + y1) / 2), (x1, y1)], fill=tip + (255,), width=1)
        fa = np.array(img).astype(float)
        cover = fa[..., 3] > 0
        bald = (noise(w, h, 7, seed + 3) > 0.68) & pelt & ~head
        c = np.where(cover[..., None], fa[..., :3], under)
        c[bald] = col(0x5E4E40) * (0.75 + 0.3 * noise(w, h, 2, seed + 4)[bald])[..., None]
        m = pelt | (cover & nd.binary_dilation(pelt, iterations=3))
        hgt = inflate(pelt, 5) * 0.7 + cover * 1.0
        c = c * lit(hgt, None, 0.8, amb=0.55)[..., None]
        # empty eye holes and the dark nose of the head
        for ey in (-3.5, 3.5):
            eye = ((xx - cx + 43) / 2.6) ** 2 + ((yy - cy - ey) / 1.4) ** 2 < 1
            c[eye] = col(0x0E0A08)
        c[((xx - cx + 59) / 2.2) ** 2 + ((yy - cy) / 2) ** 2 < 1] = col(0x16100C)
        L.put(m, c, hgt)
    else:
        # old straw, trampled flat; a torn sack laid on it
        e = ((xx - cx) / 46) ** 2 + ((yy - cy) / 16) ** 2 + (noise(w, h, 6, seed) - 0.5) * 0.9 < 1
        straw = broken(e, seed + 1, 3.5)
        img = Image.new("RGBA", (w, h), (0, 0, 0, 0)); d = ImageDraw.Draw(img)
        for i in range(1400):
            x = rng.uniform(0, w); y = rng.uniform(0, h)
            if not straw[int(y), int(x)]:
                continue
            a = rng.uniform(-0.6, 0.6) + (0 if rng.random() < 0.7 else math.pi / 2)
            L_ = rng.uniform(4, 9)
            c = [(118, 100, 62), (92, 76, 44), (138, 118, 74), (70, 58, 36)][int(rng.integers(0, 4))]
            d.line([(x, y), (x + math.cos(a) * L_, y + math.sin(a) * L_ * 0.5)], fill=c + (255,), width=1)
        sa = np.array(img).astype(float)
        under = col(0x3A3022) * np.ones((h, w, 1))
        c = np.where(sa[..., 3:4] > 0, sa[..., :3], under)
        hgt = inflate(straw, 8) * 0.4 + (sa[..., 3] > 0) * 1.5
        L.put(straw, c * lit(hgt, None, 1.0, amb=0.5)[..., None], hgt)
        sack = ((xx - cx + 6) / 20) ** 2 + ((yy - cy) / 9) ** 2 + (noise(w, h, 5, seed + 2) - 0.5) * 0.8 < 1
        sack = broken(sack, seed + 3, 2.0) & straw
        weave = (np.sin(xx * 1.9) + np.sin(yy * 1.9) > 0).astype(float)
        sh = hgt + 3 + np.sin(xx * 0.4 + yy * 0.2) * 1.5
        sc = col(0x6A5A40) * (0.82 + 0.18 * weave)[..., None] * (0.85 + 0.3 * noise(w, h, 4, seed + 4))[..., None]
        L.put(sack, sc * lit(sh, None, 1.0, amb=0.5)[..., None], sh)
        m = straw
    return finish(L, ground_shadow(w, h, m, foot, 0.7)), w / 2, foot


# ------------------------------------------------------------------ sample sheet

KOTLIN = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "preview", "build", "screens", "hoehle_dinge")


def kotlin(name, v):
    """A thing painted in the game with Sculpt (preview HOEHLEDINGE=1), with a soft shadow under it."""
    anchors = {l.split()[0]: (int(l.split()[1]), int(l.split()[2])) for l in open(os.path.join(KOTLIN, "anker.txt")) if l.strip()}
    im = Image.open(os.path.join(KOTLIN, f"{name}_{v}.png")).convert("RGBA")
    ax, ay = anchors[f"{name}_{v}"]
    a = np.array(im).astype(float)
    m = a[..., 3] > 0
    sh = ground_shadow(im.width, im.height, m, ay - 2, 0.85)
    out = np.zeros_like(a); out[..., :3] = 8; out[..., 3] = sh * 190
    al = a[..., 3:4] / 255
    out[..., :3] = out[..., :3] * (1 - al) + a[..., :3] * al
    out[..., 3] = np.maximum(out[..., 3], a[..., 3])
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGBA"), ax, ay

def sheet():
    # plain cave floor without walls as the background (the same painting as in the cave)
    keep = old.ROWS
    old.ROWS = ["_" * len(keep[0])] * len(keep)
    g, *_ = old.ground()
    old.ROWS = keep
    rows = [
        ("Stalagmit", lambda: old.stalagmite(5, 1.0, 0), lambda: kotlin("stalagmit", 0), lambda: kotlin("stalagmit", 1)),
        ("Kisten", lambda: old.crate(7, True, 0), lambda: kotlin("kisten", 0), lambda: kotlin("kisten", 1)),
        ("Knochen", lambda: old.bones(9, 2), lambda: kotlin("knochen", 0), lambda: kotlin("knochen", 1)),
        ("Schlafplatz", lambda: old.bedroll(3, 0), lambda: kotlin("schlafplatz", 0), lambda: kotlin("schlafplatz", 1)),
    ]
    cw, ch = 170, 160
    Wd, Hd = 4 * cw, len(rows) * ch + 34
    bg = np.zeros((Hd, Wd, 3))
    bg[34:] = g[0:Hd - 34, 0:Wd]
    cv = bg.copy()
    for r, (name, *fs) in enumerate(rows):
        for k, f in enumerate(fs):
            im, ax, ay = f()
            col_ = k + 1
            old.blit_any(cv, im, int(col_ * cw + cw / 2 - ax), int(34 + r * ch + ch - 22 - ay))
    # the right half once more in lantern light, as it will look in the game
    out = Image.fromarray(np.clip(cv, 0, 255).astype(np.uint8))
    d = ImageDraw.Draw(out)
    d.rectangle([0, 0, Wd, 30], fill=(18, 16, 16))
    for k, t in enumerate(["", "bisher", "neu (Sculpt)", "neu (Sculpt), Variante 2"]):
        d.text((k * cw + 12, 10), t, fill=(224, 216, 200))
    for r, (name, *_) in enumerate(rows):
        d.text((10, 34 + r * ch + ch / 2 - 6), name, fill=(224, 216, 200))
    big = out.resize((Wd * 2, Hd * 2), Image.NEAREST)
    # in the light of the hero's lantern (cave darkness around), as MapLight would light it
    a = np.array(out).astype(float)
    yy, xx = np.mgrid[0:Hd, 0:Wd]
    lc = np.array([0.13, 0.13, 0.18]) + np.exp(-(((xx - 2.5 * cw) ** 2 + (yy - Hd / 2) ** 2) / (2.4 * cw) ** 2) * 2)[..., None] * (col(0xFFD4A8) / 255) * 0.95
    a[34:] = a[34:] * np.clip(lc[34:], 0, 1.2)
    lamp = Image.fromarray(np.clip(a, 0, 255).astype(np.uint8)).resize((Wd * 2, Hd * 2), Image.NEAREST)
    return big, lamp


if __name__ == "__main__":
    big, lamp = sheet()
    big.save(f"{OUT}/hoehle_dinge_muster.png")
    lamp.save(f"{OUT}/hoehle_dinge_muster_licht.png")
    print("ok")
