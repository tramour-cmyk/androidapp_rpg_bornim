# 1538: Vorgang an der Kostenschwelle hält an, Freigabe „Kosten frei:“ gibt bis zur nächsten Schwelle frei. Aufruf: python3 tools/kostenschwelle_test.py
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import startbar as s

fehl = 0
def soll(name, ist, erwartet):
    global fehl; ok = ist == erwartet; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ist)

vorlage = dict(next(d for d in s.zeilen_liste() if d["wort"] == "startbar"))
def neu(nr, kosten, wort="startbar", titel="Probe"):
    return dict(vorlage, nr=nr, kosten=kosten, wort=wort, stand=wort, warte=[], zusatz="", titel=titel, besitzer="Jerry", kl="M")
frei = s.kosten_frei("x\n**Kosten frei:** 9901 bis 80 $; 9902 bis 160 $ (weiter)\n")
soll("Freigabe gelesen", frei, {"9901": 80.0, "9902": 160.0})
soll("unter 40 $ läuft", s.kostenhalt(neu("9900", "39,99 $"), frei), None)
soll("ab 40 $ hält", s.kostenhalt(neu("9900", "40,00 $"), frei), 40)
soll("125 $ ohne Freigabe: Schwelle 80", s.kostenhalt(neu("9900", "125,77 $"), frei), 80)
soll("frei bis 80 läuft bei 79", s.kostenhalt(neu("9901", "79,98 $"), frei), None)
soll("frei bis 80 hält bei 80", s.kostenhalt(neu("9901", "80,10 $"), frei), 80)
soll("frei bis 160 läuft bei 125", s.kostenhalt(neu("9902", "125,77 $"), frei), None)
soll("„jetzt“ läuft weiter", s.kostenhalt(neu("9900", "50 $", titel="Probe „jetzt“ 17.11., 10:00"), frei), None)
soll("ruht hält nicht", s.kostenhalt(neu("9900", "90 $", wort="ruht"), frei), None)
soll("ohne Kosten läuft", s.kostenhalt(neu("9900", "–"), frei), None)
soll("Nachtrag „–; +2,98 $“", s.kostenhalt(neu("9900", "–; +2,98 $"), frei), None)
soll("nächste Schwelle über 125", s.naechste_schwelle(125.77), 160)
s.kosten_frei = lambda text=None: frei
soll("sperre nennt Schwelle", (s.sperre(neu("9900", "45 $")) or "")[:19], "Kostenschwelle 40 $")
sys.exit(1 if fehl else 0)
