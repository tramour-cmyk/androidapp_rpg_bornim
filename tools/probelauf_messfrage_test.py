# 654.2: erster Handlauf ohne Bild je Vorgang und Tag mit „Messfrage:“ ohne Freigabe. Aufruf: python3 tools/probelauf_messfrage_test.py
import os, sys, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import probelauf as p

fehl = 0
def soll(name, ist, erwartet):
    global fehl; ok = ist == erwartet; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ist)

lokal = os.path.join(tempfile.mkdtemp(), "l.tsv")
p.zweig_lesen = lambda *a, **k: (None, "")
p.LOKAL = lokal
p.messfrage_heute.__defaults__ = (p.DATEI, lokal)
p.bild_nein({"bild": "nein"}); p.HAND["nachricht"] = "1043: Wolf\n\nMessfrage: Springt der Wolf vor dem Treffer?\n"
soll("bild=nein mit Messfrage frei", p.messlauf_frei("1043", "hand", False), True)
soll("Push-Lauf nie frei", p.messlauf_frei("1043", "ci", False), False)
soll("mit Film nie frei", p.messlauf_frei("1043", "hand", True), False)
p.bild_nein({"film": "nein"})
soll("nur film=nein nicht frei", p.messlauf_frei("1043", "hand", False), False)
p.bild_nein({"bild": "nein"}); p.HAND["nachricht"] = "1043: Wolf\n\nMessfrage:\n"
soll("leere Messfrage nicht frei", p.messlauf_frei("1043", "hand", False), False)
p.HAND["nachricht"] = "1043: Wolf\n\nMessfrage: Treffer?\n"
p.zaehlen("1043", "Jerry", "hand-messfrage", lokal=lokal)
soll("zweiter am Tag nicht frei", p.messlauf_frei("1043", "hand", False), False)
soll("anderer Vorgang frei", p.messlauf_frei("709.1", "hand", False), True)
open(lokal, "w").write("2026-01-01 10:00:00\t870.4\tTom\thand-messfrage\tabc\n")
soll("gestern zählt nicht", p.messlauf_frei("870.4", "hand", False), True)
n, _ = (lambda: (sum(1 for z in p.zeilen(open(lokal).read()) if z[1] == "870.4" and z[3] != "mess"), None))()
soll("freier Messlauf zählt gegen die Grenze", n, 1)
sys.exit(1 if fehl else 0)
