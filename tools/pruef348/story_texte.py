# 390: steht jeder Satz aus Story.kt (say, narrate, T in objective) wortgleich in godot/skripte/geschichte.gd?
# Ausgenommen, was karten.json schon traegt (jorinStop, Tueren, Suedrand, Schilder, Kartennamen) und der Steuerkreuz-Tipp.
# Aufruf: python3 -I tools/pruef348/story_texte.py  -> fehlende Saetze, Exit 1 wenn welche fehlen
import re, sys
R = sys.argv[1] if len(sys.argv) > 1 else '.'
kt = open(R + '/core/src/main/kotlin/de/bornim/core/Story.kt').read()
gd = open(R + '/godot/skripte/geschichte.gd').read()
STR = r'"((?:[^"\\]|\\.)*)"'
def raus(s, von, bis):
    a = s.index(von); b = s.index(bis, a)
    return s[:a] + s[b:]
kt = raus(kt, 'private fun jorinStop()', 'fun southEdge(')
kt = raus(kt, 'fun southEdge(', '// ------------------------------------------------------------------ interiors')
kt = re.sub(r'lockedDoor\(\d+, \d+\) \{.*?\},\n', '', kt, flags=re.S)
kt = re.sub(r'if \(classicControls\) narrate\(' + STR + r',\s*' + STR + r'\)', '', kt)
saetze = re.findall(r'(?:say\(\w+, |narrate\(|-> T\()' + STR + r',\s*' + STR, kt)
fehlt = [(de, en) for de, en in saetze if '"%s"' % de not in gd or '"%s"' % en not in gd]
print('Saetze %d, fehlen %d' % (len(saetze), len(fehlt)))
for de, en in fehlt: print('  FEHLT', de[:90])
sys.exit(1 if fehlt else 0)
