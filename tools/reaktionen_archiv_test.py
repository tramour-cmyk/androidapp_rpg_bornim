# 1316: Archiveinträge, die eine Reaktion schließen. Aufruf: python3 tools/reaktionen_archiv_test.py
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import reaktionen as r

ARCHIV = """- **1266 A** (15.11., 12:48, Chef): Ergebnis; Nachricht 4201, 4200; `ansehen/1266.md` in Git
- **1215 A** (15.11.): Nachricht 4217, Nachricht 4218
- **930 A**: Nachrichten 4146, 4147 und 4133; Bündel
- **t286, t287 getestet** (15.11., 16:58)
- **t290 getestet, t291 getestet** (15.11.)
- **t300 Prüfliste** (15.11.): t301 getestet nicht fett
"""
fehl = 0
def soll(name, ist, erwartet):
    global fehl; ok = ist == erwartet; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ist)

soll("erste Kennung", r.nachricht_im_archiv("4201", ARCHIV), True)
soll("zweite Kennung ohne Wort", r.nachricht_im_archiv("4200", ARCHIV), True)
soll("„Nachricht a, Nachricht b“", r.nachricht_im_archiv("4218", ARCHIV), True)
soll("Mehrzahl mit „und“", r.nachricht_im_archiv("4133", ARCHIV), True)
soll("Teilzahl gilt nicht", r.nachricht_im_archiv("420", ARCHIV), False)
soll("fehlende Kennung", r.nachricht_im_archiv("4300", ARCHIV), False)
soll("zweiter Build in Liste", r.build_im_archiv("287", ARCHIV), True)
soll("erster Build in Liste", r.build_im_archiv("286", ARCHIV), True)
soll("„t290 getestet, t291 getestet“", r.build_im_archiv("291", ARCHIV), True)
soll("t28 ist nicht t286", r.build_im_archiv("28", ARCHIV), False)
soll("nicht fett gilt nicht", r.build_im_archiv("301", ARCHIV), False)
soll("fett ohne „getestet“ gilt nicht", r.build_im_archiv("300", ARCHIV), False)
sys.exit(1 if fehl else 0)
