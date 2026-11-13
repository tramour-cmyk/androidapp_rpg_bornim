#!/usr/bin/env python3
# 1128.2 (1128 A, Chef 13.11., 13:36; Laufnachweis nach Sokrates 12:11 und Diogenes 12:59): ein Punkt der Prüfliste gilt nur dann als
# „ohne dich“ geprüft, wenn sein Test im Lauf der APK steht, dort rot werden kann und grün war. Dieses Werkzeug prüft die ersten beiden
# Bedingungen am Bauablauf (`.github/workflows/godot.yml` des Build-Zweigs); „war grün“ bestätigt Diogenes am Lauf.
#
# Kann nicht rot werden (Befunde aus 283): Aufruf mit `|| true`, Schritt mit `continue-on-error`, Pipe ohne `pipefail` (dann entscheidet
# grep), Schritt mit `set +e` ohne Falle ERR, Testskript, das nur `quit(0)` kennt. Läuft nicht in jedem Lauf: Schritt mit `if:` auf
# Commit-Nachricht, Eingabe oder Umgebung.
#
# Aufruf: python3 tools/laufnachweis.py [PRUEFLISTE.md] [--ref REF | --yml DATEI [--tests ORDNER]]
#   ohne PRUEFLISTE: die mit der höchsten Nummer in docs/chefsache/ansehen und docs/entwurf (t<n>-….md)
#   ohne --ref/--yml: origin/claude/build-<n> (n aus dem Dateinamen), holt den Zweig, wenn er fehlt
# Liest die Testnamen in Backticks aus der Zeile oder dem Abschnitt „Im Bau geprüft“ bzw. „Ohne dich“ und aus Tabellenzeilen mit einer
# Zelle „ohne dich“. Exit 0: alle tragen; 1: mindestens einer nicht; 2: Aufruf oder Datei fehlt.
import os, re, subprocess, sys

WURZEL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KOPF = re.compile(r'^\s*(?:#+\s*)?\**\s*(im bau geprüft|ohne dich)\b', re.I)


def git(*a, cwd=WURZEL):
    return subprocess.run(['git', *a], capture_output=True, text=True, cwd=cwd)


def neueste_pruefliste():
    beste = None
    for ordner in ('docs/chefsache/ansehen', 'docs/entwurf'):
        p = os.path.join(WURZEL, ordner)
        for f in os.listdir(p) if os.path.isdir(p) else []:
            m = re.match(r't(\d+)-.*\.md$', f)
            if m and (beste is None or int(m.group(1)) > beste[0]):
                beste = (int(m.group(1)), os.path.join(p, f))
    return beste[1] if beste else None


def testname(tok):
    tok = tok.strip()
    tok = re.sub(r'^(res://)?(godot/)?tests/', '', tok)
    tok = re.sub(r'\.gd$', '', tok)
    return tok if re.fullmatch(r'[a-z][a-z0-9_]*_[0-9][0-9a-z_]*', tok) else None


def namen_aus_pruefliste(text):
    """Testnamen in Reihenfolge, je Name einmal."""
    namen, im_abschnitt = [], False
    for z in text.splitlines():
        if re.match(r'^\s*#', z):
            im_abschnitt = bool(KOPF.match(z))
            continue
        nimm = im_abschnitt or KOPF.match(z)
        if not nimm and z.lstrip().startswith('|'):
            nimm = any(c.strip().strip('*').lower() == 'ohne dich' for c in z.split('|'))
        if not nimm:
            continue
        for tok in re.findall(r'`([^`]+)`', z):
            n = testname(tok)
            if n and n not in namen:
                namen.append(n)
    return namen


def schritte(yml):
    """Liste der Schritte: dict(name, zeile, if, coe, run=[(zeilennr, logische Zeile)]). Zeilenweise, ohne YAML-Bibliothek."""
    out, akt, im_run, run_einzug = [], None, False, 0
    zeilen = yml.splitlines()
    i = 0
    while i < len(zeilen):
        z = zeilen[i]
        nr = i + 1
        # Fortsetzungszeilen (\ am Ende) zu einer logischen Zeile
        while z.rstrip().endswith('\\') and i + 1 < len(zeilen):
            i += 1
            z = z.rstrip()[:-1] + ' ' + zeilen[i].strip()
        i += 1
        m = re.match(r'^(\s*)- (?:name|uses|run|id):', z)
        if m and (akt is None or len(m.group(1)) <= akt['einzug']):
            akt = {'name': '', 'zeile': nr, 'if': '', 'coe': False, 'shell': '', 'run': [], 'einzug': len(m.group(1))}
            out.append(akt)
            im_run = False
            z = z.replace('- ', '  ', 1)
        if akt is None:
            continue
        einzug = len(z) - len(z.lstrip())
        if im_run:
            if z.strip() == '' or einzug >= run_einzug:
                akt['run'].append((nr, z.strip()))
                continue
            im_run = False
        s = z.strip()
        if einzug <= akt['einzug'] + 2:
            if s.startswith('name:'):
                akt['name'] = s[5:].strip()
            elif s.startswith('if:'):
                akt['if'] = s[3:].split('#')[0].strip()
            elif s.startswith('continue-on-error:'):
                akt['coe'] = 'true' in s
            elif s.startswith('shell:'):
                akt['shell'] = s[6:].strip()
            elif s.startswith('run:'):
                rest = s[4:].strip()
                if rest in ('|', '|-', '>', '>-', ''):
                    im_run, run_einzug = True, einzug + 2
                else:
                    akt['run'].append((nr, rest))
    return out


def bedingt(cond):
    c = re.sub(r'\$\{\{|\}\}', '', cond).strip()
    c = re.sub(r'(!\s*cancelled|always|success)\(\)\s*(&&)?', '', c).strip()
    return '' if c in ('', '()') else c


def quit_kann_rot(gd):
    args = re.findall(r'\bquit\(([^)]*)\)', gd)
    return any(a.strip() not in ('', '0') for a in args) or bool(re.search(r'\bOS\.exit_code\s*=\s*[^0\s]', gd))


def pruefe(name, steps, gd_text):
    """→ (ok, befund, fundstellen)"""
    pfad = 'res://tests/%s.gd' % name
    treffer = []
    for st in steps:
        pipefail = 'pipefail' in st['shell'] or st['shell'] == 'bash'
        plus_e = False
        falle = False
        for nr, z in st['run']:
            code = z.split(' # ')[0]
            if re.search(r'\bset\s+-o\s+pipefail\b', code) and not code.startswith('nebenher'):
                pipefail = True
            if re.search(r'\bset\s+\+o\s+pipefail\b', code):
                pipefail = False
            if re.search(r'\bset\s+\+e\b', code):
                plus_e = True
            if re.search(r"\btrap\b.*\bERR\b", code):
                falle = True
            if pfad not in code and not re.search(r'tests/%s\.gd\b' % re.escape(name), code):
                continue
            nach = code[code.find('tests/%s.gd' % name):]
            gruende = []
            if re.search(r'\|\|\s*(true|:)\b', nach):
                gruende.append('`|| true`')
            neben = code.startswith('nebenher ')
            if '|' in nach.replace('||', '') and not (pipefail or neben or 'pipefail' in code):
                gruende.append('Pipe ohne pipefail')
            if st['coe']:
                gruende.append('Schritt mit continue-on-error')
            if plus_e and not falle:
                gruende.append('set +e ohne Falle ERR')
            c = bedingt(st['if'])
            treffer.append({'zeile': nr, 'schritt': st['name'] or '(ohne Name)', 'nie_rot': gruende,
                            'bedingt': c})
    if not treffer:
        return False, 'steht nicht im Bauablauf', []
    if gd_text is None:
        return False, 'Testdatei fehlt im Zweig', treffer
    tragend = [t for t in treffer if not t['nie_rot'] and not t['bedingt']]
    if tragend and not quit_kann_rot(gd_text):
        return False, 'Testskript endet nur mit quit(0), wird nie rot', treffer
    if tragend:
        return True, 'trägt (Zeile %s, %s)' % (tragend[0]['zeile'], tragend[0]['schritt']), treffer
    gr = []
    for t in treffer:
        g = list(t['nie_rot']) + (['nur wenn %s' % t['bedingt']] if t['bedingt'] else [])
        gr.append('Zeile %d: %s' % (t['zeile'], ', '.join(g)))
    return False, 'kann nicht rot werden oder läuft nicht immer (' + '; '.join(gr) + ')', treffer


def main(argv):
    ref = yml_datei = tests_ordner = None
    rest = []
    i = 0
    while i < len(argv):
        a = argv[i]
        if a in ('--ref', '--yml', '--tests') and i + 1 < len(argv):
            if a == '--ref':
                ref = argv[i + 1]
            elif a == '--yml':
                yml_datei = argv[i + 1]
            else:
                tests_ordner = argv[i + 1]
            i += 2
            continue
        if a in ('-h', '--help'):
            print(open(__file__).read().split('\nimport ')[0])
            return 0
        rest.append(a)
        i += 1
    liste = rest[0] if rest else neueste_pruefliste()
    if not liste or not os.path.isfile(liste):
        print('laufnachweis: keine Prüfliste gefunden', file=sys.stderr)
        return 2
    text = open(liste, encoding='utf-8').read()
    namen = namen_aus_pruefliste(text)
    if yml_datei:
        yml = open(yml_datei, encoding='utf-8').read()
        quelle = yml_datei
        tests_ordner = tests_ordner or os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(yml_datei)))), 'godot', 'tests')

        def lies_gd(n):
            p = os.path.join(tests_ordner, n + '.gd')
            return open(p, encoding='utf-8').read() if os.path.isfile(p) else None
    else:
        if not ref:
            m = re.match(r't(\d+)-', os.path.basename(liste))
            if not m:
                print('laufnachweis: Build-Nummer nicht im Dateinamen, --ref angeben', file=sys.stderr)
                return 2
            ref = 'origin/claude/build-%s' % m.group(1)
        if git('rev-parse', '--verify', '-q', ref).returncode != 0 and ref.startswith('origin/'):
            zweig = ref[len('origin/'):]
            git('fetch', '-q', 'origin', '%s:refs/remotes/origin/%s' % (zweig, zweig))
        r = git('show', '%s:.github/workflows/godot.yml' % ref)
        if r.returncode != 0:
            print('laufnachweis: %s nicht lesbar (%s)' % (ref, r.stderr.strip()), file=sys.stderr)
            return 2
        yml, quelle = r.stdout, '%s:.github/workflows/godot.yml' % ref

        def lies_gd(n):
            r = git('show', '%s:godot/tests/%s.gd' % (ref, n))
            return r.stdout if r.returncode == 0 else None
    print('Laufnachweis %s gegen %s' % (os.path.relpath(liste, WURZEL) if liste.startswith(WURZEL) else liste, quelle))
    if not namen:
        print('  keine Testnamen unter „Im Bau geprüft“ oder „Ohne dich“')
        return 0
    steps = schritte(yml)
    schlecht = 0
    for n in namen:
        ok, befund, _ = pruefe(n, steps, lies_gd(n))
        schlecht += not ok
        print('  %s %-22s %s' % ('gut ' if ok else 'NEIN', n, befund))
    print('LAUFNACHWEIS %d von %d tragen%s' % (len(namen) - schlecht, len(namen),
          '' if not schlecht else '; die übrigen als Prüffrage am Handy oder Test in den Lauf der APK (1128 A)'))
    print('Grün im Lauf bestätigt Diogenes (1128.3).')
    return 1 if schlecht else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
