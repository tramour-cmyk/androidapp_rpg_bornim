# 1247: Freigaben im Vorgangsarchiv, die urteil() erkennen muss. Aufruf: python3 tools/probelauf_frei_test.py
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import probelauf

ARCHIV = """# Vorgangsarchiv

- **1242, Lauf frei** (14.11., 10:33, Sokrates nach 621 A, Bitte Tom zu 1091, 1119, 1040.1; Chef 10:28 über Perikles „jetzt“): Ursache nachgestellt → **genau ein Lauf**
- **1300, Läufe frei** (13.11., 09:12, Sokrates, siehe 1301): zwei Läufe
- **1400 A** (12.11., 08:00, Chef): Ergebnis, 1401 und 1402 zwei Läufe frei (Sokrates)
- **1500 A** (11.11., 07:00, Chef): Ergebnis; 1501 Lauf frei (Sokrates)
"""
probelauf.zweig_lesen = lambda name, zweig=None: ("x", ARCHIV)
fehl = 0
def soll(name, ist, erwartet):
    global fehl; ok = ist == erwartet; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ist)

soll("Einzahl „Lauf frei“ im Kopf", probelauf.urteil("1242")[-8:], "10:33:00")
soll("fremde Nummer, „zu 1091“", (probelauf.urteil("1091") or "")[-8:], "10:33:00")
soll("fremde Nummer, Liste „1040.1“", (probelauf.urteil("1040.1") or "")[-8:], "10:33:00")
soll("„1040“ ist nicht „1040.1“", probelauf.urteil("1040"), None)
soll("„siehe 1301“ gibt nichts frei", probelauf.urteil("1301"), None)
soll("Mehrzahl im Kopf", (probelauf.urteil("1300") or "")[-8:], "09:12:00")
soll("„Läufe frei“ im Text (D68.1)", (probelauf.urteil("1402") or "")[-8:], "08:00:00")
soll("Einzahl im Text", (probelauf.urteil("1501") or "")[-8:], "07:00:00")
sys.exit(1 if fehl else 0)
