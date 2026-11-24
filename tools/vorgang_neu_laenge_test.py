# 2017 (Chef 24.11., 08:28): eine Zeile der Vorgangsliste darf über 400 Zeichen haben; keine Sperre, kein Hinweis.
# Ersetzt die 400-Regel aus 1916 und 1919. Prüft an der echten Zeile 1782 (414 Zeichen, Commit 335c30fbd):
# startbar.pruefen_liste (auch Commit-Prüfung), vorgang.py neu und vorgang.py setze (fehler_oder).
# Aufruf: python3 tools/vorgang_neu_laenge_test.py
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import vorgang
s = vorgang.startbar
ECHT = ("| 1782 | Von Sokrates (1727d, 21:31; 22:30): Wiederwecken: Frist abgelaufen und idle oder abgebrochen → ein Neustart, "
        "zweites Mal „steckt fest“ (L-S2, L-U8); Freigabe („gut“, „passt“, „freigegeben“) oder Ergebnis Checkliste 11/12 aus fremder "
        "Sitzung als Zeile an den Disponenten (L-U15, 3.3 Nr. 7, chefwort.py); mit 1739 | 7 | B Werkzeuge | M | – | 1727d, 1739 | – | "
        "*erledigt, greift Lauf 352* | *–* | *0* | *–* |")
KOPF = "| Nr. | Titel | Block | Bereich | Kl. | wartet auf | Bezug | Zweig | *Stand* | *Sitzung* | *Runde* | *Kosten* |\n|---|---|---|---|---|---|---|---|---|---|---|---|\n"
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, "" if ok else zeige)
offen = ECHT.replace("*erledigt, greift Lauf 352*", "*ruht, bis Lauf 352 greift*")
soll("Aufbau: echte Zeile 1782 über 400 Zeichen", len(ECHT) > 400 and len(offen) > 400, len(offen))
# Liste (Commit-Prüfung ruft pruefen_liste): offene Zeile über 400 ohne Meldung zur Länge
zs = s.vorgangsliste(KOPF + offen + "\n")
soll("Aufbau: Zeile gelesen", len(zs) == 1 and zs[0]["nr"] == "1782", zs)
lang = [f for f in s.pruefen_liste(zs) if "400" in f[1]]
soll("2017: pruefen_liste meldet keine Länge", not lang, lang)
titel = zs[0]["titel"] + " " + "x" * 50
# vorgang.py neu: Titel über 400 Zeichen geht durch, Nummer wird gezogen
s.lesen = lambda p: "**Nächste freie Vorgangsnummer: 1914**\n" if p == "ARBEIT-BETRIEB.md" else ""
s.zeilen_liste = lambda *a, **k: []
s.VORG = set()
vorgang.fern_zaehler = lambda: []
vorgang.fern_nummern = lambda: set()
gezogen = []
vorgang.zaehler_pushen = lambda zeile, nr, wer: gezogen.append(nr) or "gültig"
vorgang.schreiben = lambda *a, **k: None
vorgang.text_liste = lambda: "| Nr. |\n"
vorgang.waechter = lambda *a, **k: None
try:
    nr = vorgang.neu(titel, "B Werkzeuge", "K", "Spike"); ergebnis = "angelegt %s" % nr
except SystemExit as e:
    ergebnis = str(e)
soll("2017: neu mit Titel über 400 Zeichen wird angelegt", ergebnis == "angelegt 1914" and gezogen == ["1914"], (ergebnis, gezogen))
# vorgang.py setze: Titel über 400 (neu gesetzt) und Stand, der die Zeile über 400 bringt, gehen ohne Meldung durch
def zeile(t, stand):
    d = dict(nr="1914", titel=t, besitzer="Spike", kl="M", stand=stand, warte=[], zweig="–", build="–", bereich="B Werkzeuge", kosten="–")
    d["wort"] = s.wort_von(stand); d["zusatz"] = s.zusatz_von(stand); return d
def pruef(neu, alt):
    try: vorgang.fehler_oder(neu, alt); return "durch"
    except SystemExit as e: return str(e)
soll("2017: setze titel=<über 400> geht durch", pruef(zeile(titel, "startbar"), zeile("kurz", "startbar")) == "durch")
b = len(s.zeile_text(zeile("x", "startbar"))) - 1
t3 = "x" * (398 - b)
alt3, neu3 = zeile(t3, "startbar"), zeile(t3, "gebaut, Geprüft an: 1e6b2d697")
soll("Aufbau: Stand bringt Zeile über 400", len(s.zeile_text(alt3)) <= 400 < len(s.zeile_text(neu3)))
e = pruef(neu3, alt3)
soll("2017: Stand macht Zeile über 400 → geht durch, kein Hinweis", e == "durch", e)
sys.exit(1 if fehl else 0)
