# 167.2 · `lauf.py` jetzt bauen statt am 26.10.?
Perikles · 18.10., 12:10 · B Abläufe · baut Perikles, ein Vormittag

Kurz: Ein Werkzeug entscheidet, wen Ford startet und was er archiviert; Ford führt nur noch aus. Vorziehen von 26.10. auf jetzt?

**Frage** (Chef 18.10., 12:0x, Wortlaut): „Wir hatten doch heute schon überlegt, ob wir nicht dafür ein Tool bauen. Dass das erledigt. Und eben nicht mehr Ford das macht. … Wenn ich als Chef ständig nachkontrollieren muss, ob irgendwer was macht, dann brauche ich euch alle nicht. … Gibt es denn da keine Lösung?“

**Befund heute:** Ford (Sonnet) soll aus rund 50 Zeilen Regeln (`LISTE-BETRIEB.md`) bei jedem Lauf entscheiden, wen er startet. Das ist Rechnen, kein Urteilen, und es gelingt nur teilweise: Tom stand mit startbarer Kür von 11:22 bis 12:06 ohne Sitzung (Lauf 12:03 holte es nach); Fords Protokoll nennt 12:06 und 12:07, die echte Zeit war 12:05. `startbar.py` rechnet schon das Meiste; fehlt der Rest (laufende Sitzungen, Startsperre, Nachfolger, Archivieren).

**Empfehlung: ja, jetzt.** `tools/lauf.py` liest `startbar.py`, `ARBEIT-BESETZUNG.md` und die gespeicherte `list_sessions`-Seite (wie bei `kosten.py`) und gibt eine feste Liste aus: `START <Rolle> <Zeile> <Titel> <erste Nachricht>`, `ARCHIVIERE <Sitzung>`, `NICHTS: <Grund je Rolle>`. Ford führt nur noch aus (`create_session`, `archive_session`, pushen, Protokollzeile aus der Ausgabe) und beurteilt nichts mehr. Die Besetzung schreibt das Werkzeug. Danach friert der Ablauf ein (Regelstopp 167.3 gilt weiter).

**Stärkstes Gegenargument:** Du hattest am 18.10. „noch nicht“ gesagt (Leitlinie: kein zweites Skript, bevor das erste eine Woche ohne Falschmeldung lief), und `startbar.py` hatte heute noch drei Falschmeldungen (D28.4, behoben). Zweitens: `lauf.py` kann `list_sessions` nicht selbst rufen, eine Sitzung (Ford) muss die Seiten holen und speichern; ein Rest Abhängigkeit bleibt. Gewogen: die Falschmeldungen waren Grenzfälle in Datumstexten, die Fehlstarts heute kommen aus Fords Lesen; ohne das Werkzeug zahlst du weiter mit deiner Zeit.

**Wenn nein:** Wiedervorlage 26.10. bleibt, du fragst weiter selbst nach.

**Berührt:** 167.2, 167.3, 166 (`startbar.py`), `LISTE-BETRIEB.md` (schrumpft), `ROLLE-BETRIEB.md`.
