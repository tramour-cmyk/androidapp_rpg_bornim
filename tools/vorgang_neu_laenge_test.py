# 1916 (D346.1): vorgang.py neu prüft die Zeilenlänge mit einer Nummer so lang wie die echte, nicht mit „?“.
# Aufruf: python3 tools/vorgang_neu_laenge_test.py
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import vorgang
s = vorgang.startbar
s.lesen = lambda p: "**Nächste freie Vorgangsnummer: 1914**\n" if p == "ARBEIT-BETRIEB.md" else ""
s.zeilen_liste = lambda *a, **k: []
vorgang.fern_zaehler = lambda: []
vorgang.fern_nummern = lambda: set()
gezogen = []
vorgang.zaehler_pushen = lambda zeile, nr, wer: gezogen.append(nr) or "gültig"
vorgang.schreiben = lambda *a, **k: None
vorgang.text_liste = lambda: "| Nr. |\n"
vorgang.waechter = lambda *a, **k: None
vorgang.leere_entwickler = lambda r: []
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, "" if ok else zeige)
def laenge(titel, nr):
    d = dict(nr=nr, titel=titel, besitzer="Spike", kl="K", stand="startbar", warte=[], zweig="–", build="–", bereich="B Werkzeuge", kosten="–")
    return len(s.zeile_text(d))
basis = laenge("x", "?") - 1
t = "x" * (399 - basis)  # mit „?“ 399 Zeichen, mit 1914 402
soll("Aufbau: mit „?“ unter, mit 1914 über 400", laenge(t, "?") <= 400 < laenge(t, "1914"), (laenge(t, "?"), laenge(t, "1914")))
try:
    vorgang.neu(t, "B Werkzeuge", "K", "Spike"); ergebnis = "angelegt"
except SystemExit as e:
    ergebnis = str(e)
soll("1916: Zeile mit echter Nummer über 400 hält an, bevor die Nummer gezogen ist", "400" in ergebnis and not gezogen, (ergebnis, gezogen))
t2 = "x" * (395 - basis)
try:
    nr = vorgang.neu(t2, "B Werkzeuge", "K", "Spike"); ergebnis = "angelegt %s" % nr
except SystemExit as e:
    ergebnis = str(e)
soll("1916: kurze Zeile wird angelegt (Nummer 1914)", ergebnis == "angelegt 1914" and gezogen == ["1914"], (ergebnis, gezogen))
sys.exit(1 if fehl else 0)
