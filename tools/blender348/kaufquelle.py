"""980 (von Tom, 968, Lauf 43051633587): Quelle eines Kaufmodells wählen, wenn eine Datei im Kaufordner mehrfach liegt.

Die Kaufskripte nahmen sorted(glob(...))[0]. Liegt dieselbe FBX zweimal da (Spinne: „DARKNESS SPIDER RAW FILES“ als ASCII-FBX neben
der Fassung aus dem Unity-Paket), kam die ASCII-Fassung zuerst; Blender liest sie nicht („ASCII FBX files are not supported“), der
Block kampf baute nicht. Hier wie kaufspinne.py quelle() (108dabaa5): von mehreren Treffern nur Binär-FBX (Kopf „Kaydara FBX
Binary“), andere Endungen bleiben, wie sie sind; die Wahl steht im Protokoll. Gibt es nur ASCII-FBX, bleibt die Liste (Blender meldet
dann den Grund) mit einer Warnung. Ohne bpy, damit es am Rechner prüfbar ist (tools/blender348/kaufquelle_test.py).
"""
import glob
import os

KOPF = b'Kaydara FBX Binary'


def binaer(pfad):
    """True, wenn pfad keine FBX ist oder eine Binär-FBX."""
    if not pfad.lower().endswith('.fbx'):
        return True
    try:
        with open(pfad, 'rb') as f:
            return f.read(len(KOPF)) == KOPF
    except OSError:
        return False


def lesbar(treffer, wer=''):
    """Aus sortierten Treffern die, die Blender lesen kann (Binär-FBX); Reihenfolge bleibt. Keiner lesbar: alle, mit Warnung."""
    t = list(treffer)
    if len(t) == 0:
        return t
    b = [p for p in t if binaer(p)]
    if len(t) > 1 or not b:
        name = os.path.basename(t[0])
        if b:
            print('KAUFQUELLE %s %s: %s (von %d, ASCII-FBX übergangen: %d)' % (wer, name, b[0], len(t), len(t) - len(b)), flush=True)
        else:
            print('KAUFQUELLE WARNUNG %s %s: nur ASCII-FBX (Blender liest sie nicht): %s' % (wer, name, ', '.join(t)), flush=True)
    return b or t


def finde(kauf, muster, wer=''):
    """Erste lesbare Datei unter kauf (rekursiv, sortiert) oder None; statt sorted(glob(...))[0]."""
    if not kauf:
        return None
    t = lesbar(sorted(glob.glob(os.path.join(kauf, '**', muster), recursive=True)), wer)
    return t[0] if t else None


def alle(kauf, muster, wer=''):
    """Alle lesbaren Treffer unter kauf (rekursiv, sortiert); statt sorted(glob(...))."""
    if not kauf:
        return []
    return lesbar(sorted(glob.glob(os.path.join(kauf, '**', muster), recursive=True)), wer)
