#!/usr/bin/env python3
"""2042 (5), Eilt (b) (Alter Ego 09:25, Dirk 09:53, 2042-Ü36): Planer- und Handstart-Titel „Name – Status – Nr – Betreff“
über rufname.titel; Betreff aus dem Vorgangstitel statt „Handstart“ (Fälle R67 Handstart Arbeitsplaner, R69 Paula, Prüfer).
Ohne Netz und ohne Schreiben. Aufruf: python3 tools/titel_2042_test.py"""
import os, sys
HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import rufname as rn, lauf

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))

rn._ZEILEN["liste"] = [{"nr": "2042", "besitzer": "Werkzeug", "titel": "Disponenten groß: Token je Takt messen"},
                       {"nr": "1589.4", "besitzer": "Kampf", "titel": "Wolf beißt: Treffer sichtbar"}]
B42, B15 = rn.betreff("2042"), rn.betreff("1589.4")
def titel(rolle, t):
    l = "START %s | opus | env | repo | main | %s | Nachricht" % (rolle, t)
    aus = lauf.mit_rufnamen([l], [], namen={})
    return aus[0].split(" | ")[5]

soll("Betreff aus der Liste", B42 and B15, (B42, B15))
for rolle, t, nr, b in [("Arbeitsplaner", "Arbeitsplaner – Auftrag 2042: %s (26.11., 10:00)" % B42, "2042", B42),
                        ("Arbeitsplaner", "Arbeitsplaner – 2042: Handstart (26.11., 10:00)", "2042", B42),  # R67 Handstart Planer
                        ("Kampf", "Kampf – 1589.4: Handstart (26.11., 10:00)", "1589.4", B15),  # R69 Paula, Handstart Kampf
                        ("Werkzeug", "Werkzeug – 2042: Handstart (26.11., 10:00)", "2042", B42)]:
    x = titel(rolle, t)
    p = rn.teile(x)
    soll("%s %r → Name – in Arbeit – Nr – Betreff" % (rolle, t[:40]), p and p["status"] == "in Arbeit" and p["nr"] == nr and p["betreff"] == b
         and "Handstart" not in x, x)
x = titel("Prüfer", "Prüfer – 2042: Handstart (26.11., 10:00)")
soll("Prüfer-Handstart → Name – Prüfer – in Arbeit – Nr – Betreff", x.endswith(" – Prüfer – in Arbeit – 2042 – " + B42), x)
soll("Leser: auftrag_aus_titel liest den neuen Planer-Titel", lauf.auftrag_aus_titel(titel("Arbeitsplaner", "Arbeitsplaner – Auftrag 2042: x (26.11., 10:00)")) == "2042")
# zweiter_planer liest die Nr aus den START-Zeilen des Planers (Feld Titel), nicht aus der ganzen Zeile
l = lauf.mit_rufnamen(["START Arbeitsplaner | opus | env | repo | main | Arbeitsplaner – Auftrag 2042: x (26.11., 10:00) | Auftrag schreiben für 1589.4"], [], namen={})[0]
soll("Leser: auftrag_aus_titel liest die START-Zeile des Planers (zweiter_planer)", lauf.auftrag_aus_titel(l) == "2042", (lauf.auftrag_aus_titel(l), l[:120]))
print("titel_2042_test: %s" % ("grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
