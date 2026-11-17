# 1461: Mittwochsrunde nach dem Tagesbericht, alle sieben Rollen. Aufruf: python3 tools/lauf_spiegel_test.py
import os, sys, shutil, tempfile, datetime, io, contextlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import lauf
fehl = 0
def soll(name, ist, erwartet):
    global fehl; ok = ist == erwartet; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ist)
d = tempfile.mkdtemp(); lauf.DOCS = d
lauf.JETZT = datetime.datetime(2026, 11, 18, 8, 0, tzinfo=lauf.BERLIN)
open(os.path.join(d, "ARBEIT-TAGESBERICHT.md"), "w").write("# Tagesbericht\n")
soll("kein Bericht", lauf.bericht_heute(), False)
open(os.path.join(d, "ARBEIT-TAGESBERICHT.md"), "w").write("# Tagesbericht\n\n**Stand 18.11., 07:40**\n")
soll("Bericht da", lauf.bericht_heute(), True)
open(os.path.join(d, "LISTE-ROLLENSPIEGEL.md"), "w").write("# Rollenspiegel\n\n## Woche 13.11.\n\n### Homer (13.11.)\n\nx\n\n## Woche 18.11.\n\n### Ford (18.11., 07:50)\n\n0. a\n\n### Team Tom (18.11., 07:55)\n\n0. b\n\n### Perikles, nachgeholt (x)\n")
soll("offen", lauf.spiegel_offen(), ["Sokrates", "Homer", "Diogenes", "Jerry"])
lauf.JETZT = datetime.datetime(2026, 11, 25, 8, 0, tzinfo=lauf.BERLIN)
soll("neue Woche alle offen", len(lauf.spiegel_offen()), 7)
shutil.rmtree(d)
sys.exit(1 if fehl else 0)
