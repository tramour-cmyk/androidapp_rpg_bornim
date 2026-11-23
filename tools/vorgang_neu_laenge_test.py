# 1916 (D346.1): vorgang.py neu prüft die Zeilenlänge mit einer Nummer so lang wie die echte, nicht mit „?“.
# Aufruf: python3 tools/vorgang_neu_laenge_test.py
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import vorgang
s = vorgang.startbar
s.lesen = lambda p: "**Nächste freie Vorgangsnummer: 1914**\n" if p == "ARBEIT-BETRIEB.md" else ""
s.zeilen_liste = lambda *a, **k: []
s.VORG = set()  # echte Nummern ab 1914 gäbe es schon (Test hing am Stand von main)
vorgang.fern_zaehler = lambda: []
vorgang.fern_nummern = lambda: set()
gezogen = []
vorgang.zaehler_pushen = lambda zeile, nr, wer: gezogen.append(nr) or "gültig"
vorgang.schreiben = lambda *a, **k: None
vorgang.text_liste = lambda: "| Nr. |\n"
vorgang.waechter = lambda *a, **k: None
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
# 1919: Stand macht die Zeile erst über 400 → vorgang.py hält an (wie die Commit-Prüfung); war sie schon zu lang, geht es weiter (1492)
def zeile(titel, stand):
    d = dict(nr="1914", titel=titel, besitzer="Spike", kl="M", stand=stand, warte=[], zweig="–", build="–", bereich="B Werkzeuge", kosten="–")
    d["wort"] = s.wort_von(stand); d["zusatz"] = s.zusatz_von(stand); return d
def pruef(neu, alt):
    try: vorgang.fehler_oder(neu, alt); return "durch"
    except SystemExit as e: return str(e)
b2 = len(s.zeile_text(zeile("x", "startbar"))) - 1
t3 = "x" * (398 - b2)
alt3 = zeile(t3, "startbar"); neu3 = zeile(t3, "gebaut, Geprüft an: 1e6b2d697")
soll("Aufbau 1919: vorher höchstens 400, danach über 400", len(s.zeile_text(alt3)) <= 400 < len(s.zeile_text(neu3)))
e = pruef(neu3, alt3)
soll("1919: Stand macht Zeile zu lang → hält an mit Hinweis Titel kürzen", "400" in e and "1919" in e and "setze 1914 titel" in e, e)
t4 = "x" * (410 - b2)
e = pruef(zeile(t4, "gebaut, Geprüft an: 1e6b2d697"), zeile(t4, "startbar"))
soll("1492: Zeile war schon zu lang → Stand geht weiter", e == "durch", e)
sys.exit(1 if fehl else 0)
