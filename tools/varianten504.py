#!/usr/bin/env python3
"""504.1: Gespräche in Varianten aus Homers Dateien (docs/STORY-VARIANTEN-K1.md, -K1-WALD.md auf main) nach godot/skripte/varianten.gd.

Je Marke `[504.…]` die Wortlaute ab 2 (Wortlaut 1 steht unverändert in geschichte.gd, rast.gd, spiel.gd) bzw. W1–W3 („nur
Wiederholung“); „ · “ trennt zwei Marken einer Überschrift, „ / “ zwei Sprechblasen. Aufruf:
  python3 tools/varianten504.py [<ordner mit den STORY-Dateien>]   (Vorgabe ../bornim-main/docs)
Die Datei wird ganz neu geschrieben; Texte nie dort ändern, sondern bei Homer (STORY-…) und neu erzeugen."""
import json, os, re, sys

HIER = os.path.dirname(os.path.abspath(__file__))
DOCS = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HIER, '..', '..', 'bornim-main', 'docs')
ZIEL = os.path.join(HIER, '..', 'godot', 'skripte', 'varianten.gd')
KOPF = re.compile(r'^`\[(504\.[a-z0-9.]+)\]`')
MARKE = re.compile(r'`\[(504\.[a-z0-9.]+)\]`')


def blasen(t):
    return [b.strip() for b in t.split(' / ')]


def lies(datei, alle):
    marken, w = [], False
    for z in open(datei, encoding='utf-8'):
        z = z.rstrip('\n')
        if KOPF.match(z):
            marken = MARKE.findall(z.split(' (')[0] if ' (`[' not in z else z)
            marken = [m for m in MARKE.findall(re.sub(r'\([^()]*\)', '', z)) if m.startswith('504.')]   # 842: Marken in einer Bedingung (Klammer) zaehlen nicht
            w = bool(re.search(r'\(W[;)]', z))
            for m in marken: alle[m] = {'w': w, 'v': []}
            continue
        if not marken: continue
        m = re.match(r'^(?:- W\d+\.|[2-9]\.)\s+(.*)$', z)
        if not m: 
            if z.startswith('#') or (z and not z[0].isdigit() and not z.startswith('- W')): marken = [] if z.startswith('#') else marken
            continue
        de, _, en = m.group(1).partition(' — EN: ')
        if not en: raise SystemExit('ohne EN: %s' % z[:80])
        des, ens = de.split(' · '), en.split(' · ')
        if len(des) != len(marken) or len(ens) != len(marken):
            raise SystemExit('%s: %d Marken, %d/%d Teile: %s' % (marken, len(marken), len(des), len(ens), z[:80]))
        for i, mk in enumerate(marken):
            d, e = blasen(des[i]), blasen(ens[i])
            if len(d) != len(e): raise SystemExit('%s: Blasen DE %d, EN %d' % (mk, len(d), len(e)))
            alle[mk]['v'].append([[a, b] for a, b in zip(d, e)])


alle = {}
for f in ('STORY-VARIANTEN-K1.md', 'STORY-VARIANTEN-K1-WALD.md'):
    lies(os.path.join(DOCS, f), alle)
for m, d in alle.items():
    if len(d['v']) < 2: raise SystemExit('%s: nur %d Wortlaute' % (m, len(d['v'])))
zeilen = ['class_name Varianten',
          '# 504.1 (Chef 03.11., 07:52: „Mindestens 3 … Lebendige Welt, keine monotone Welt“): Wortlaute je Marke aus Homers',
          '# STORY-VARIANTEN-K1.md und -K1-WALD.md, ERZEUGT von tools/varianten504.py; nicht von Hand ändern. „w“: nur Wiederholung',
          '# (Wortlaut 1 nur beim ersten Mal); „v“: Wortlaute ab 2 bzw. W1–W3, je Wortlaut Sprechblasen [de, en].',
          'const V := ' + json.dumps(alle, ensure_ascii=False, indent='\t').replace('\n', '\n')]
open(ZIEL, 'w', encoding='utf-8').write('\n'.join(zeilen) + '\n')
print('VARIANTEN', len(alle), 'Marken,', sum(len(d['v']) for d in alle.values()), 'Wortlaute ->', os.path.relpath(ZIEL))
