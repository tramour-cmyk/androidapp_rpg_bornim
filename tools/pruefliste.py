#!/usr/bin/env python3
# 1020.1 (Chef 12.11., 08:09, „jetzt“; Vorlage 1020 D Stufe 1): die laufende Prüfliste kommt beim Bau ins Spiel, der Reiter „Test“
# zeigt sie Zeile für Zeile (testmodus.gd, pruefliste.gd). Liest eine Prüfliste `t<n>-….md` (Aufbau LISTE-CHECK-BUILD-TEST.md 10) und
# schreibt sie als JSON: Build, Kopfzeile, Sätze vor der ersten Tabelle, Abschnitte mit Zeilen (Nummer, Team, Vorgang, Wo und wie,
# Richtig, Falsch).
# Aufruf: python3 tools/pruefliste.py AUS.json [DATEI.md]
#   ohne DATEI: die Prüfliste mit der höchsten Nummer auf origin/main (docs/chefsache/ansehen, sonst docs/entwurf); holt main
#   flach, wenn es fehlt. Keine Prüfliste: JSON mit leeren Abschnitten, das Spiel zeigt dann „keine Prüfliste im Bau“.
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


def schlicht(s):
    s = re.sub(r'\[([^\]]*)\]\([^)]*\)', r'\1', s)   # Links: nur der Text
    s = s.replace('**', '').replace('`', '')
    return s.strip()


def zellen(z):
    z = z.strip()
    if z.startswith('|'): z = z[1:]
    if z.endswith('|'): z = z[:-1]
    return [schlicht(c) for c in z.split('|')]


def lies(text, quelle=''):
    zeilen = text.splitlines()
    titel = schlicht(zeilen[0].lstrip('# ')) if zeilen else ''
    m = re.search(r'Build (\d+)', titel)
    aus = {'build': int(m.group(1)) if m else 0, 'titel': titel, 'quelle': quelle, 'kopf': [], 'abschnitte': []}
    abschnitt = None
    spalten = None
    for z in zeilen[1:]:
        if z.startswith('## Ergebnis'):
            break
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
            if not re.fullmatch(r'\d+\.\d+', nr):
                continue
            if abschnitt is None:
                abschnitt = {'titel': '', 'zeilen': []}
                aus['abschnitte'].append(abschnitt)
            abschnitt['zeilen'].append({'nr': nr, 'team': d.get('team', ''), 'vorgang': d.get('nr.', d.get('nr', '')),
                                        'wo': d.get('wo und wie', ''), 'richtig': d.get('passt', d.get('richtig', '')), 'falsch': d.get('falsch', '')})
            continue
        # im Spiel nur, was beim Prüfen hilft: der Weg und was bekannt ist (nicht Teamliste, „Verglichen“, „Im Bau geprüft“)
        if not aus['abschnitte'] and re.match(r'(Rot|Bekannt|Ein Weg|Dazu bekannt)', z.strip()):
            aus['kopf'].append(schlicht(z))
    return aus


def main():
    if len(sys.argv) < 2:
        sys.exit('Aufruf: pruefliste.py AUS.json [DATEI.md]')
    if len(sys.argv) > 2:
        quelle = sys.argv[2]
        text = open(quelle, encoding='utf-8').read()
    else:
        quelle, text = neueste_von_main()
    aus = lies(text, quelle or '') if text else {'build': 0, 'titel': '', 'quelle': '', 'kopf': [], 'abschnitte': []}
    with open(sys.argv[1], 'w', encoding='utf-8') as f:
        json.dump(aus, f, ensure_ascii=False, indent=1)
    n = sum(len(a['zeilen']) for a in aus['abschnitte'])
    print('Prüfliste: %s, Build %d, %d Zeilen in %d Abschnitten' % (quelle or 'keine', aus['build'], n, len(aus['abschnitte'])))


if __name__ == '__main__':
    main()
