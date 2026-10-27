# 383.1 · Neustart erst bei etwa 400 Tsd. Token statt bei etwa 225 Tsd.
Perikles · 27.10., 19:29 · B Werkzeuge · M (Chef 19:19 „nicht mal 2 Seiten lang“, 19:23 „383.1 ja“)

**Entschieden (Vorentscheid):** Neue Arbeit geht per „Weiter“ in die ruhende Sitzung, solange sie unter **400 Tsd.** Token liegt (vorher 150 Tsd.); der Neustart-Haken erinnert erst nach **300 Tsd.** Zuwachs (vorher 100 Tsd., also bei etwa 225 Tsd.). Dazu wie gebilligt: Warten auf den Chef ist kein Neustartgrund (`CLAUDE.md`, Zusammenarbeit 1).

**Warum:** Die Sitzung, nach der du gefragt hast, wurde nicht wegen Wartens neu aufgemacht, sondern weil sie mit 238 Tsd. über der Weiter-Grenze von 150 Tsd. lag (Platz: 1 Mio.). Die Grenzen stammen aus der Zeit kleinerer Kontexte. Sokrates hat 96 Sitzungen gemessen: Kosten je Arbeit sind von 100 bis 500 Tsd. gleich; jeder Neustart liest dagegen etwa 125 Tsd. Token neu (die kleinste Sitzung kostete 1,25 $).

**Stärkstes Gegenargument:** Jeder Zug in einer vollen Sitzung liest den ganzen Verlauf mit, und die Messung kennt nur den Endstand, keinen Vergleich gleicher Aufgaben. Darum nicht ganz bis 1 Mio., sondern mit Abstand unter 500 Tsd., bis wohin gemessen ist.

**Umgesetzt:** `tools/lauf.py` `WEITER_TOKEN`, `tools/neustart-haken.py` `AB`, `ROLLE-BETRIEB.md` Archivregel (3).

**Rückbau:** zwei Zahlen zurück auf 150000 und 100000.

**Kosten:** keine; Sokrates misst am 31.10. mit 347 nach (Anzahl WEITER gegen START, Kosten je Sitzung).
