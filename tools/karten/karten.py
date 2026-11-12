#!/usr/bin/env python3
# 870.9 (Umzug BRS Schritt 8, 870a 7 B): die Karten sind Godot-Quelle, nicht mehr Export aus core (MapExport.kt). Bearbeitet wird
# godot/daten/karten.json von Hand: „zeilen“ (je Zeile eine Kartenzeile, ein Zeichen je Kachel, Bedeutung unter „kacheln“),
# Ausgänge, Leute, Kisten, Schilder, Häuser, Fassaden, Schutz, Begegnungen. Zwei Felder hängen an den Zeilen und werden nie von
# Hand bearbeitet: „bewuchs“ (niedriger Wuchs statt hoher Krone, wo sie etwas Wichtiges verdecken würde; MapFlora.shades/lowKind)
# und „ring“ (Waldring jenseits des Randes; MapEdge.spot). Nach jeder Änderung an Zeilen, Leuten oder Ausgängen:
#   python3 tools/karten/karten.py ableiten         rechnet bewuchs und ring neu und schreibt die Datei in ihrer Form
#   python3 tools/karten/karten.py pruefen          Exit 1, wenn bewuchs/ring veraltet sind oder eine Datei nicht in Form ist
#   python3 tools/karten/karten.py form DATEI …     schreibt JSON-Dateien in der lesbaren Form (godot/daten/*.json)
#   python3 tools/karten/karten.py kanon DATEI      die kompakte Form (gleich dem alten Export, Kennung in kauf_cache.py)
# Die Regeln, die eine Karte erfüllen muss (Kisten, Schilder, Ausgänge, Wege), prüft godot/tests/karten_regeln.gd.
# Rechnung wie core/src/main/kotlin/de/bornim/core/art/MapEdge.kt und MapFlora.kt (Stand f32a789e6), geprüft gleich dem Export.
import json, os, sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
KARTEN = os.path.join(REPO, 'godot', 'daten', 'karten.json')
BREITE = 100          # eine Zeile der lesbaren Form


# ------------------------------------------------------------------ Form

def kanon(o):
    return json.dumps(o, ensure_ascii=False, separators=(',', ':'))

def form(o, tiefe=0):
    """Lesbar und gut zu vergleichen: kurze Teile auf einer Zeile, Listen kleiner Teile zu Zeilen gepackt, Zeichenketten je eine."""
    k = kanon(o)
    if not isinstance(o, (list, dict)) or len(k) + 2 * tiefe <= BREITE:
        return k
    ein = '  ' * (tiefe + 1)
    if isinstance(o, dict):
        teile = ['%s%s: %s' % (ein, kanon(s), form(w, tiefe + 1)) for s, w in o.items()]
        return '{\n' + ',\n'.join(teile) + '\n' + '  ' * tiefe + '}'
    klein = [kanon(w) for w in o]
    if all(not isinstance(w, str) and len(x) + 2 * (tiefe + 1) <= BREITE // 2 for w, x in zip(o, klein)):
        zeilen, z = [], ''
        for x in klein:
            if z and len(ein) + len(z) + 1 + len(x) + 1 > BREITE:
                zeilen.append(z); z = ''
            z = z + ', ' + x if z else x
        zeilen.append(z)
        return '[\n' + ',\n'.join(ein + z for z in zeilen) + '\n' + '  ' * tiefe + ']'
    return '[\n' + ',\n'.join(ein + form(w, tiefe + 1) for w in o) + '\n' + '  ' * tiefe + ']'

def text_der_form(o):
    return form(o) + '\n'


# ------------------------------------------------------------------ Rechnung (MapFlora, MapEdge)

M32 = 0xFFFFFFFF

def mhash(x, y, s):
    n = (x * 374761393 + y * 668265263 + s * 1442695041) & M32
    n = ((n ^ (n >> 13)) * 1274126177) & M32
    return (n ^ (n >> 16)) & 0x7FFFFFFF

RING = 6              # MapEdge.RING
CLOSE = 5             # MapEdge.CLOSE


class Karte:
    def __init__(self, alle, k):
        self.k = k
        self.id = k['id']
        self.art = k['art']
        self.b, self.h = int(k['breite']), int(k['hoehe'])
        self.zeilen = k['zeilen']
        self.rand = k['rand']
        name = {c: t['name'] for c, t in alle['kacheln'].items()}
        self.name = name
        self.leute = {(int(n['x']), int(n['y'])) for n in k.get('leute', [])}
        self.ausgaenge = {(int(a['x']), int(a['y'])) for a in k.get('ausgaenge', [])}

    def inside(self, x, y):
        return 0 <= x < self.b and 0 <= y < self.h

    def tile(self, x, y):
        return self.name[self.zeilen[y][x] if self.inside(x, y) else self.rand]

    def important(self, x, y):
        t = self.tile(x, y)
        return (t in ('CHEST', 'CAMPFIRE', 'SIGN', 'CAVE_ENTRANCE') or
                (self.art == 'TOWN' and t in ('CROPS', 'VEG_BED', 'HAY', 'FENCE', 'WASHLINE')) or
                (x, y) in self.leute or (x, y) in self.ausgaenge)

    def seen(self, x, y):
        return self.inside(x, y) and (self.tile(x, y) == 'MENHIR' or (self.important(x, y) and self.tile(x, y) != 'CHEST'))

    def shades(self, tx, ty):
        reach = 12 if self.id == 'deep_forest' else 8
        return any(1 <= bx + by <= reach and abs(bx - by) <= 2 and self.seen(tx - bx, ty - by)
                   for bx in range(reach + 1) for by in range(reach + 1))

    def close_behind(self, tx, ty):
        return any(1 <= bx + by <= 3 and ((tx - bx, ty - by) in self.leute or (tx - bx, ty - by) in self.ausgaenge)
                   for bx in range(4) for by in range(4))

    def low_kind(self, tx, ty):
        pick = mhash(tx, ty, 17) % 10
        town = self.art == 'TOWN'
        deep = self.id == 'deep_forest'
        if self.close_behind(tx, ty): return 'busch'
        if not town and not deep: return 'jung2' if pick < 3 else 'jung'
        if pick < (6 if town else 3): return 'busch'
        if pick < (8 if town else 6): return 'jung2'
        return 'jung'

    def spot(self, tx, ty):
        if self.inside(tx, ty): return None
        cx = min(max(tx, 0), self.b - 1); cy = min(max(ty, 0), self.h - 1)
        along_x = ty < 0 or ty >= self.h
        def neben(k):
            return self.tile(min(max(cx + k, 0), self.b - 1), cy) if along_x else self.tile(cx, min(max(cy + k, 0), self.h - 1))
        offen = any(neben(k) != 'TREE' for k in range(-3, 2))
        depth = max(-tx, tx - self.b + 1, -ty, ty - self.h + 1)
        wet = self.tile(cx, cy) in ('WATER', 'BRIDGE')
        if offen and (depth < CLOSE or wet): return None
        if self.art == 'TOWN' and self.shades(tx, ty): return self.low_kind(tx, ty) if depth <= 2 else None
        if offen: return 'baum_offen'
        return 'baum2' if (tx + ty) % 2 == 0 else 'baum'

    def bewuchs(self):
        return [[x, y, self.low_kind(x, y)] for y in range(self.h) for x in range(self.b)
                if self.tile(x, y) == 'TREE' and self.shades(x, y)]

    def ring(self):
        out = []
        for y in range(-RING, self.h + RING):
            for x in range(-RING, self.b + RING):
                a = self.spot(x, y)
                if a: out.append([x, y, a])
        return out

    def hat_ring(self):
        return self.art in ('FOREST', 'TOWN')       # MapEdge.applies ohne Höhle (MapExport: Höhle ohne ring)


def abgeleitet(alle):
    """Je Karte die Felder bewuchs und ring, wie sie aus den Zeilen folgen."""
    neu = {}
    for kid, k in alle['karten'].items():
        m = Karte(alle, k)
        f = {'bewuchs': m.bewuchs()}
        if m.hat_ring(): f['ring'] = m.ring()
        neu[kid] = f
    return neu

def einsetzen(alle):
    for kid, f in abgeleitet(alle).items():
        k = alle['karten'][kid]
        for feld, wert in f.items():
            if feld in k:
                k[feld] = wert
            else:                                   # neue Karte: nach „bewuchs“ bzw. vor „ausgaenge“ wie im alten Export
                teile = list(k.items()); i = next((n for n, (s, _) in enumerate(teile) if s == 'ausgaenge'), len(teile))
                teile.insert(i, (feld, wert)); k.clear(); k.update(teile)
    return alle


# ------------------------------------------------------------------ Aufrufe

def lies(p):
    with open(p, encoding='utf-8') as f:
        return f.read()

def schreib(p, o):
    with open(p, 'w', encoding='utf-8') as f:
        f.write(text_der_form(o))

def pruefen(p):
    roh = lies(p); alle = json.loads(roh); fehler = []
    for kid, f in abgeleitet(alle).items():
        for feld, wert in f.items():
            alt = alle['karten'][kid].get(feld)
            if alt != wert:
                a = {tuple(x) for x in alt or []}; n = {tuple(x) for x in wert}
                fehler.append('%s.%s veraltet: %d zu viel %s, %d fehlen %s' % (kid, feld, len(a - n), sorted(a - n)[:3], len(n - a), sorted(n - a)[:3]))
    if roh != text_der_form(alle):
        fehler.append('%s nicht in Form: python3 tools/karten/karten.py form %s' % (os.path.relpath(p, REPO), os.path.relpath(p, REPO)))
    return fehler

def main(a):
    if not a or a[0] not in ('ableiten', 'pruefen', 'form', 'kanon'):
        print(__doc__ or open(__file__).read().split('import json')[0]); return 2
    if a[0] == 'ableiten':
        p = a[1] if len(a) > 1 else KARTEN
        schreib(p, einsetzen(json.loads(lies(p)))); print('karten.py: bewuchs und ring neu in', os.path.relpath(p, REPO)); return 0
    if a[0] == 'pruefen':
        dateien = a[1:] or [KARTEN]
        fehler = []
        for p in dateien:
            o = json.loads(lies(p))
            if isinstance(o, dict) and 'karten' in o and 'kacheln' in o:
                fehler += pruefen(p)
            elif lies(p) != text_der_form(o):
                fehler.append('%s nicht in Form: python3 tools/karten/karten.py form %s' % (os.path.relpath(p, REPO), os.path.relpath(p, REPO)))
        for f in fehler: print('KARTEN:', f)
        print('KARTEN: %s' % ('ok' if not fehler else '%d Fehler' % len(fehler)))
        return 1 if fehler else 0
    if a[0] == 'form':
        for p in a[1:]: schreib(p, json.loads(lies(p)))
        return 0
    if a[0] == 'kanon':
        sys.stdout.write(kanon(json.loads(lies(a[1])))); return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
