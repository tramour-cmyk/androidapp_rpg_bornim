#!/usr/bin/env python3
# 1020.1 (Chef 12.11., 08:09, „jetzt“; Vorlage 1020 D Stufe 1): die laufende Prüfliste kommt beim Bau ins Spiel, der Reiter „Test“
# zeigt sie Zeile für Zeile (testmodus.gd, pruefliste.gd). Liest eine Prüfliste `t<n>-….md` (Aufbau LISTE-CHECK-BUILD-TEST.md 10) und
# schreibt sie als JSON: Build, Kopfzeile, Sätze vor der ersten Tabelle, Abschnitte mit Zeilen (Nummer, Team, Vorgang, Wo und wie,
# Art (ab 284, 1128 A), Richtig, Falsch). Mit Spalte „Art“ nur Zeilen „Handy“ (1217); die übrigen zählt „ohne_handy“.
# Aufruf: python3 tools/pruefliste.py AUS.json [DATEI.md]
#   ohne DATEI: die Prüfliste mit der höchsten Nummer auf origin/main (docs/chefsache/ansehen, sonst docs/entwurf); holt main
#   flach, wenn es fehlt. Keine Prüfliste: JSON mit leeren Abschnitten, das Spiel zeigt dann „keine Prüfliste im Bau“.
# 1178 (Chef 13.11., 15:49, Test 283: im Spiel stand der alte Entwurf t283-leute, nicht die gegengelesene t283-dorf): auf
#   claude/build-<n> (GITHUB_REF_NAME, GITHUB_HEAD_REF oder --build N) nur t<n>-….md von origin/main, ansehen/ oder ein Entwurf mit
#   „Gegengelesen:“ (1199), nie ein ungelesener Entwurf und nie eine andere Nummer; fehlt sie, JSON mit „fehlt“ und leeren Abschnitten, Ende 0 (der Bau läuft weiter);
#   `pruefliste.py --pruefe JSON` endet dann 1 (Zeile im Prüfschritt, der Bau wird rot, die APK entsteht trotzdem, 918).
# 1156 (Vorlage 1020 D Stufe 2): ein Abschnitt „## Lagen“ (nach der Tabelle, vor „## Ergebnis“) gibt je Zeile die Lage, die der Knopf
# „Lage herstellen“ im Reiter „Test“ herstellt: „- 284.3: station=Garrick uhr=20:30 probe=WOLF_PACK“. Schlüssel (LAGE_SCHLUESSEL):
#   station=<Station aus Testmodus.STATIONEN oder Kapitelende>  ort=<karte>:<x>:<y>[:<blick>]  uhr=HH:MM  merker=+flag,-flag
#   stufe=<n>  vorraete  einmaliges  probe=<Gegner>  held=test|spiel  herkunft=  volk=  pstufe=  waffe=  neben=  ruestung=  soeldner=
#   tasche=zwei|keine|voll  leben=voll|halb|knapp  zeit=tag|abend|nacht  zug=pounce|heavy|reihe|flucht  ausweichen
#   eroeffnung=NORMAL|AMBUSHED|HERO_FIRST  kampfort=<Ort>
# Reihenfolge im Spiel: Geschichte und Held, dann Ort (Station oder ort), dann Probekampf. Ob Station, Gegner und Werte stimmen, prüft
# der Bau (tests/lage_1156.gd mit der Liste des Baus); hier nur unbekannte Schlüssel als Warnung.
import json, os, re, subprocess, sys


def _git(*a):
    return subprocess.run(['git', *a], capture_output=True, text=True)


def neueste_von_main():
    if _git('rev-parse', '--verify', '-q', 'origin/main').returncode != 0:
        _git('fetch', '-q', '--depth=1', 'origin', 'main:refs/remotes/origin/main')
    beste = None
    for ordner, vorrang in (('docs/chefsache/ansehen/', 1), ('docs/entwurf/', 0)):
        r = _git('ls-tree', '--name-only', 'origin/main', ordner)
        for p in r.stdout.split():
            m = re.match(r't(\d+)-.*\.md$', os.path.basename(p))
            if m:
                k = (int(m.group(1)), vorrang)
                if beste is None or k > beste[0]:
                    beste = (k, p)
    if beste is None:
        return None, ''
    return beste[1], _git('show', 'origin/main:' + beste[1]).stdout


def eigene_nummer():
    """1178: Buildnummer aus --build N oder dem Zweig claude/build-<n> des Laufs, sonst None (Teamzweig, von Hand)."""
    if '--build' in sys.argv:
        return int(sys.argv[sys.argv.index('--build') + 1])
    for v in ('GITHUB_HEAD_REF', 'GITHUB_REF_NAME'):
        m = re.fullmatch(r'claude/build-(\d+)', os.environ.get(v, ''))
        if m:
            return int(m.group(1))
    return None


GEGENGELESEN = re.compile(r'^Gegengelesen:\s*\S', re.M)


def eigene_von_main(n):
    """1178: t<n>-….md auf origin/main (frisch geholt), nie eine andere Nummer; zwei Dateien derselben Nummer: die zuletzt geänderte.
    1199 (Chef 13.11., 18:30: „Wenn etwas zu tun ist durch mich, dann bitte den Eintrag, aber doch nicht vorher“): die Liste liegt
    bis zur Testbitte gegengelesen in docs/entwurf/ (Zeile „Gegengelesen:“ Pflicht, sonst zählt der Entwurf nicht, 1178), nach
    docs/chefsache/ansehen/ erst mit APK und gesendeten Bildern; liegt sie schon dort, gilt sie vor dem Entwurf."""
    # flach nur in einem flachen Klon (Bauserver); ein voller Klon bliebe sonst ab origin/main flach (am Rechner 13.11., 15:52)
    flach = _git('rev-parse', '--is-shallow-repository').stdout.strip() == 'true'
    _git('fetch', '-q', *(['--depth=1'] if flach else []), 'origin', 'main:refs/remotes/origin/main')
    for ordner, nur_gegengelesen in (('docs/chefsache/ansehen/', False), ('docs/entwurf/', True)):
        r = _git('ls-tree', '--name-only', 'origin/main', ordner)
        wege = [p for p in r.stdout.split() if re.match(r't%d-.*\.md$' % n, os.path.basename(p))]
        texte = {p: _git('show', 'origin/main:' + p).stdout for p in wege}
        if nur_gegengelesen:
            wege = [p for p in wege if GEGENGELESEN.search(texte[p])]
        if wege:
            wege.sort(key=lambda p: int(_git('log', '-1', '--format=%ct', 'origin/main', '--', p).stdout.strip() or 0))
            return wege[-1], texte[wege[-1]]
    return None, ''


def schlicht(s):
    s = re.sub(r'\[([^\]]*)\]\([^)]*\)', r'\1', s)   # Links: nur der Text
    s = s.replace('**', '').replace('`', '')
    return s.strip()


def zellen(z):
    z = z.strip()
    if z.startswith('|'): z = z[1:]
    if z.endswith('|'): z = z[:-1]
    return [schlicht(c) for c in z.split('|')]


LAGE_SCHLUESSEL = {'station', 'ort', 'uhr', 'merker', 'stufe', 'vorraete', 'einmaliges', 'probe', 'held', 'herkunft', 'volk', 'pstufe',
                   'waffe', 'neben', 'ruestung', 'soeldner', 'tasche', 'leben', 'zeit', 'zug', 'ausweichen', 'eroeffnung', 'kampfort',
                   'ruhig'}   # 542: ruhig = Monster beachten nicht; station= mit ort= stellt den Helden an den Ort (nicht Kapitelende)


def lage(text):
    """„station=Garrick uhr=20:30 vorraete“ -> {'station': 'Garrick', 'uhr': '20:30', 'vorraete': ''}; Werte ohne Leerzeichen"""
    aus = {}
    for w in schlicht(text).split():
        k, _, v = w.partition('=')
        if k not in LAGE_SCHLUESSEL:
            print('WARNUNG Prüfliste, Lage: Schlüssel „%s“ unbekannt (%s)' % (k, ', '.join(sorted(LAGE_SCHLUESSEL))), file=sys.stderr)
            continue
        aus[k] = v
    return aus


def lies(text, quelle=''):
    zeilen = text.splitlines()
    titel = schlicht(zeilen[0].lstrip('# ')) if zeilen else ''
    m = re.search(r'Build (\d+)', titel)
    aus = {'build': int(m.group(1)) if m else 0, 'titel': titel, 'quelle': quelle, 'kopf': [], 'abschnitte': []}
    abschnitt = None
    spalten = None
    lagen = {}
    in_lagen = False
    for z in zeilen[1:]:
        if z.startswith('## Ergebnis'):
            break
        if z.startswith('## Lagen'):   # 1156: nicht als Abschnitt, sondern je Zeile „lage“
            in_lagen = True
            continue
        if in_lagen:
            m = re.match(r'\s*[-*]\s*(\d+\.\d+[a-z]?)\s*:?\s+(.*)$', z)   # wie die Tabelle (1178): auch 284.3b
            if m:
                lagen[m.group(1)] = lage(m.group(2))
                continue
            if not z.startswith('## '):
                continue
            in_lagen = False
        if z.startswith('## '):
            abschnitt = {'titel': schlicht(z[3:]), 'zeilen': []}
            aus['abschnitte'].append(abschnitt)
            spalten = None
            continue
        if z.startswith('|'):
            c = zellen(z)
            if spalten is None:
                spalten = [x.lower() for x in c]
                continue
            if all(re.fullmatch(r':?-+:?', x or '-') for x in c):
                continue
            d = dict(zip(spalten, c))
            nr = d.get('#', c[0])
            if not re.fullmatch(r'\d+\.\d+[a-z]?', nr):   # 1178: auch 284.2a (fehlten im Reiter „Test“)
                continue
            # 1217 (Chef 13.11., 20:01: „in die APK … nur Fragen rein, die ich in APK klären muss. Und die anderen als Einzelvorlagen“):
            # mit Spalte „Art“ nur Zeilen „Handy“; Bild, Film, Gespräch, ohne dich, Kleinkram (1171) gehen einzeln auf Telegram, 👍/👎
            if 'art' in d and not d['art'].strip().lower().startswith('handy'):
                aus['ohne_handy'] = aus.get('ohne_handy', 0) + 1
                continue
            if abschnitt is None:
                abschnitt = {'titel': '', 'zeilen': []}
                aus['abschnitte'].append(abschnitt)
            abschnitt['zeilen'].append({'nr': nr, 'team': d.get('team', ''), 'vorgang': d.get('nr.', d.get('nr', '')), 'art': d.get('art', ''),
                                        'wo': d.get('wo und wie', ''), 'richtig': d.get('passt', d.get('richtig', '')), 'falsch': d.get('falsch', '')})
            continue
        # im Spiel nur, was beim Prüfen hilft: der Weg und was bekannt ist (nicht Teamliste, „Verglichen“, „Im Bau geprüft“)
        if not aus['abschnitte'] and re.match(r'(Rot|Bekannt|Ein Weg|Dazu bekannt)', z.strip()):
            aus['kopf'].append(schlicht(z))
    alle = {}
    for a in aus['abschnitte']:
        for zeile in a['zeilen']:
            alle[zeile['nr']] = zeile
            if zeile['nr'] in lagen:
                zeile['lage'] = lagen[zeile['nr']]
    for nr in lagen:
        if nr not in alle:
            print('WARNUNG Prüfliste, Lage: %s steht nicht in der Tabelle' % nr, file=sys.stderr)
    return aus


def ohne_lage(d):
    """1185 (Perikles, 1183): Nummern der Handyzeilen ohne Lage, deren Weg nicht mit „Weiter“ beginnt"""
    return [z['nr'] for a in d.get('abschnitte', []) for z in a.get('zeilen', [])
            if z.get('art', '').strip().lower().startswith('handy') and not z.get('lage')
            and not schlicht(z.get('wo', '')).lstrip('„"').lower().startswith('weiter')]


def main():
    if '--pruefe' in sys.argv:   # 1178: Zeile im Prüfschritt; rot, wenn der Bau ohne seine gegengelesene Prüfliste gebaut ist
        d = json.load(open(sys.argv[sys.argv.index('--pruefe') + 1], encoding='utf-8'))
        if d.get('fehlt'):
            print('PRUEFLISTE fehlt: %s (1178)' % d['fehlt']); sys.exit(1)
        for nr in ohne_lage(d):   # 1185 (1183): nur Warnung, der Bau bleibt grün
            print('WARNUNG Prüfliste %s: Handyzeile ohne Eintrag in „## Lagen“, Weg beginnt nicht mit „Weiter“ (LISTE-CHECK-BUILD-TEST 10, 1183)' % nr)
        print('PRUEFLISTE Build %d aus %s' % (d.get('build', 0), d.get('quelle') or 'keiner Datei')); return
    args = [a for i, a in enumerate(sys.argv[1:], 1) if a != '--build' and sys.argv[i - 1] != '--build']
    if not args:
        sys.exit('Aufruf: pruefliste.py AUS.json [DATEI.md] [--build N] | --pruefe AUS.json')
    n = eigene_nummer()
    fehlt = ''
    if len(args) > 1:
        quelle = args[1]
        text = open(quelle, encoding='utf-8').read()
    elif n is not None:
        quelle, text = eigene_von_main(n)
        if not text:
            fehlt = ('Build %d ohne gegengelesene Prüfliste t%d-….md auf main (docs/entwurf/ mit Zeile „Gegengelesen:“); erst '
                     'gegenlesen, dann bauen (1199)' % (n, n))
    else:
        quelle, text = neueste_von_main()
    aus = lies(text, quelle or '') if text else {'build': n or 0, 'titel': '', 'quelle': '', 'kopf': [], 'abschnitte': []}
    if fehlt:
        aus['fehlt'] = fehlt
    aus['abschnitte'] = [a for a in aus['abschnitte'] if a['zeilen']]   # 1217: Ort nur mit Bildern und Filmen fällt im Reiter weg
    sys.argv[1] = args[0]
    with open(sys.argv[1], 'w', encoding='utf-8') as f:
        json.dump(aus, f, ensure_ascii=False, indent=1)
    n = sum(len(a['zeilen']) for a in aus['abschnitte'])
    nl = sum(1 for a in aus['abschnitte'] for z in a['zeilen'] if z.get('lage'))
    print('Prüfliste: %s, Build %d, %d Zeilen in %d Abschnitten, %d mit Lage%s' % (quelle or 'keine', aus['build'], n, len(aus['abschnitte']), nl,
          ', %d ohne Handy (Telegram, 1217)' % aus['ohne_handy'] if aus.get('ohne_handy') else ''))


if __name__ == '__main__':
    main()
