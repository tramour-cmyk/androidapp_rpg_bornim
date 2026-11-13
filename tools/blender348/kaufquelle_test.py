"""980: Prüfung von kaufquelle.py ohne Blender: python3 -I tools/blender348/kaufquelle_test.py (Exit 0 = gut).
Nachgestellt wie Lauf 43051633587 (Spinne): ASCII-FBX unter „…RAW FILES“ sortiert vor der Binär-FBX aus dem Unity-Paket."""
import os
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import kaufquelle  # noqa: E402

fehler = 0


def pruefe(ok, was):
    global fehler
    print(('gut    ' if ok else 'FEHLER ') + was)
    if not ok:
        fehler += 1


def datei(pfad, inhalt):
    os.makedirs(os.path.dirname(pfad), exist_ok=True)
    with open(pfad, 'wb') as f:
        f.write(inhalt)
    return pfad


with tempfile.TemporaryDirectory() as k:
    ascii_ = datei(os.path.join(k, 'DARKNESS SPIDER RAW FILES', 'DARKNESS_SPIDER.FBX'), b'; FBX 7.4.0 project file\n')
    bin_ = datei(os.path.join(k, 'Unity', 'Assets', 'DARKNESS_SPIDER.FBX'), kaufquelle.KOPF + b'\x00\x1a\x00')
    pruefe(sorted([ascii_, bin_])[0] == ascii_, 'Nachstellung: sortiert käme die ASCII-Fassung zuerst')
    pruefe(kaufquelle.finde(k, 'DARKNESS_SPIDER.FBX', 'TEST') == bin_, 'finde nimmt die Binär-FBX')
    pruefe(kaufquelle.alle(k, 'DARKNESS_SPIDER.FBX', 'TEST') == [bin_], 'alle ohne ASCII-FBX')
    nur = datei(os.path.join(k, 'nur', 'NUR_ASCII.fbx'), b'; FBX 7.4.0 project file\n')
    pruefe(kaufquelle.finde(k, 'NUR_ASCII.fbx', 'TEST') == nur, 'nur ASCII: bleibt (mit Warnung), Blender nennt den Grund')
    t1 = datei(os.path.join(k, 'a', 'bild.tga'), b'xx')
    t2 = datei(os.path.join(k, 'b', 'bild.tga'), b'yy')
    pruefe(kaufquelle.alle(k, 'bild.tga') == [t1, t2], 'andere Endungen unverändert, Reihenfolge bleibt')
    pruefe(kaufquelle.finde(k, 'fehlt.fbx') is None and kaufquelle.finde('', 'x.fbx') is None, 'nichts gefunden oder ohne KAUF: None')
    pruefe(kaufquelle.lesbar([]) == [], 'leere Liste bleibt leer')

print('KAUFQUELLE980 %d Fehler' % fehler)
sys.exit(1 if fehler else 0)
