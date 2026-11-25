# 2034 Teil 0: Liste docs/entwurf/2034-abzug.md aus liste.json (tools/blender348/v3/abzug_mh.py) und den Paketdateien packs/*.json.
# F6 aus der Sichtung (LISTE-QUELLEN.md „MakeHuman-Asset-Packs“, Spalte F6): ein Stueck gilt als „✗ Sichtung“ nur, wenn ein dort
# mit ✗ genanntes Wort in Name, Ordner oder Beschreibung (packs/*.json) steht (Suchwoerter unten, je Paket). Sonst gezeichnet.
# Lizenz: Paketseite (Spalte der Sichtung), Kopf der .mhclo/.mhmat, Paketdatei; „NC“ irgendwo: nie zeigen.
# Aufruf: python3 tools/godot/abzug_2034_liste.py <pakete> <liste.json> <ausgabe.md> <commit> [<messung.json>]
import sys, json, glob, os, re

P, L, AUS, C = sys.argv[1:5]
MESS = json.load(open(sys.argv[5])) if len(sys.argv) > 5 else {}
SEITE = {'M1': 'CC0', 'M15': 'CC0', 'M16': 'CC0', 'M17': 'CC0', 'M20': 'CC0', 'M21': 'CC0', 'M26': 'CC0', 'M27': 'CC0', 'M29': 'CC0',
         'M31': 'CC0', 'M34': 'CC0', 'M36': 'CC0'}
STUECK = {'M1': 9, 'M15': 23, 'M16': 13, 'M17': 20, 'M20': 5, 'M21': 13, 'M26': 9, 'M27': 25, 'M29': 6, 'M31': 4, 'M34': 6, 'M36': 21,
          'M41': 4, 'M42': 24, 'M43': 19, 'M47': 19, 'M48': 8, 'M49': 21, 'M50': 14, 'M51': 4, 'M54': 13, 'M57': 12}
# Wort aus der Sichtung (F6 ✗) -> Suchwoerter (englisch in den Paketen)
X = {'M17': [('Alien', 'alien'), ('Tigra', 'tigra'), ('Flagge', 'flag')], 'M21': [('Blumen', 'flower|floral')],
     'M26': [('Superheld', 'hero')], 'M27': [('Pink', 'pink'), ('Anime', 'anime'), ('Bob', r'\bbob|bobcut|_bob')],
     'M29': [('Motorrad', 'motorcycle'), ('M1', r'm1[_ ]?helmet|m1helmet')], 'M31': [('Jeans', 'jeans')], 'M34': [('Mini', 'mini')],
     'M36': [('Superheld', 'hero|spider|superman|batman'), ('Sci-Fi', 'sci-?fi|cyborg|galactic|glactic')],
     'M47': [('Melone', 'bowler|derby'), ('Weihnachten', 'christmas|santa|xmas')], 'M48': [('Fahrrad', 'bike|bicycle|cycling')],
     'M49': [('50er', r"50s|fifties|1950"), ('80er', r"80s|eighties|1980")], 'M50': [('Totenkopf', 'skull'), ('Blau', 'blue')],
     'M51': [('Corona', 'corona|covid'), ('Gas', r'\bgas')], 'M54': [('Hoodie', 'hoodie'), ('Krawatte', r'\btie\b|necktie')],
     'M57': [('Biker', 'biker'), ('Winter', 'winter')]}
liste = json.load(open(L))
zeilen, summe = [], {}
for e in liste:
    pn = e['nummer'].split('-')[0]
    ordner = os.path.basename(os.path.dirname(os.path.join(P, pn, e['datei'])))
    js = {}
    for j in glob.glob(os.path.join(P, pn, 'packs', '*.json')):
        try: js.update(json.load(open(j, errors='ignore')))
        except Exception: pass
    d = js.get(ordner, {}) if isinstance(js.get(ordner), dict) else {}
    text = ' '.join([e['name'], ordner, d.get('description', ''), d.get('name', '')]).lower()
    f6 = [w for w, rx in X.get(pn, []) if re.search(rx, text)]
    seite = SEITE.get(pn, 'CC-BY')
    liz = [seite, e.get('lizenz_kopf', ''), e.get('lizenz_json', '')]
    nc = any('nc' in re.split(r'[^a-z]+', x.lower()) for x in liz)
    if nc: grund = 'nein: NC, nie'
    elif e.get('fehler'): grund = 'nein: ' + e['fehler']
    elif f6: grund = 'nein: ✗ Sichtung (%s)' % ', '.join(f6)
    elif e['art'] == 'Haut': grund = 'ja: Hautbild ohne Körper, Weg H erst 2031'
    else: grund = 'ja'
    e['lizenz'] = seite
    e['zeichnen'] = grund.startswith('ja')
    s = summe.setdefault(pn, [e['paket'], 0, 0, 0])
    s[1] += 1; s[2 if e['zeichnen'] else 3] += 1
    kopf = e.get('lizenz_kopf', '') or '–'
    if kopf.startswith('AGPL3'): kopf = 'AGPL3 (MakeClothes-Vorgabe)'
    if 'AGPLv3' in kopf: kopf = 'AGPLv3 (.mhmat-Vorlage)'
    zeilen.append('| %s | %s | %s | %s | %s; Kopf %s; Paketdatei %s | %s | %s | %s | %s |' % (
        e['nummer'], e['name'], e['paket'], e['art'], seite, kopf[:40], e.get('lizenz_json', '') or '–',
        e['dreiecke'] or '–', e['bild'] or '–', ', '.join(f6) + ' ✗' if f6 else '–', grund))
json.dump(liste, open(L, 'w'), ensure_ascii=False, indent=1)
o = ['# 2034 Teil 0: Abzug der MakeHuman-Stücke (Liste)', '',
     'Vorgang 2034 Teil 0 (Chef 25.11., 17:27; Sokrates 17:29). Erzeugt von `tools/godot/abzug_2034_liste.py` aus `tools/blender348/v3/abzug_mh.py` (Stand %s). '
     'Pakete neu geladen von `files.makehumancommunity.org` (25.11., 18:12–18:21, HTTP 200; fünf CC-BY-Pakete heißen dort `*_cc-by.zip`). '
     'Stücke je Paket: alle `.mhclo` (M1 nur `hair/`), Häute alle `.mhmat` unter `skins/`. Dreiecke: Flächen der `.obj` (n-Eck = n−2), nicht ausgedünnt; Bild: Größe des `diffuseTexture`.' % C, '',
     '**F6 ✗ Sichtung:** nur, wenn ein in der Sichtung mit ✗ genanntes Wort in Name, Ordner oder Paketbeschreibung steht (Suchwörter in `abzug_2034_liste.py`); nicht gezeichnet, der Chef kann nachfordern. Alles andere ist gezeichnet, auch wenn die Sichtung das Paket „meist modern“ nannte.', '',
     '**Lizenz:** Spalte 1 = Paketseite (maßgeblich, LISTE-QUELLEN.md); „AGPL3“ im Kopf der .mhclo ist die MakeClothes-Vorgabe, „AGPLv3“ im Kopf der .mhmat die Materialvorlage (LISTE-QUELLEN.md). NC an irgendeiner Stelle: nie gezeigt.', '',
     '## Summe je Paket gegen die Sichtung', '', '| Nr. | Paket | Sichtung Stück | gefunden | gezeichnet | nicht gezeichnet |', '|---|---|---|---|---|---|']
for pn in sorted(summe, key=lambda s: int(s[1:])):
    p, n, ja, nein = summe[pn]
    o.append('| %s | %s | %d%s | %d | %d | %d |' % (pn, p, STUECK[pn], ' (Haare)' if pn == 'M1' else '', n, ja, nein))
t = [sum(v[i] for v in summe.values()) for i in (1, 2, 3)]
o.append('| **Summe** | | %d | %d | %d | %d |' % (sum(STUECK.values()), t[0], t[1], t[2]))
if MESS:
    o += ['', '## Signatur-Probe (vorn, Spiel-Shader)', '']
    for nr, m in MESS.items(): o.append('- **%s**: %s' % (nr, m['satz']))
o += ['', '## Stücke', '', '| Nummer | Name | Paket | Art | Lizenz (Seite; Kopf; Paketdatei) | Dreiecke | Bild px | F6 Sichtung | gezeichnet |', '|---|---|---|---|---|---|---|---|---|'] + zeilen
open(AUS, 'w').write('\n'.join(o) + '\n')
print('LISTE', AUS, 'Stuecke', t[0], 'gezeichnet', t[1], 'nicht', t[2])
