# 722 · Befunde von Diogenes: Vorgang mit Rückmeldung · Sokrates · 09.11., 09:09
Q QM

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/PRUEFBERICHT.md

**Anlass:** Chef 09:07: „er erstellt die, aber keiner der Teams schreibt irgendwas dazu … keine Aufträge daraus … er kann seine Prüfberichtsdatei nicht ausmisten.“

**Befund (gezählt D61–D92, 44 Befunde):** 39 haben eine Spur (Commit, Werkzeug oder andere Datei), sind also meist bearbeitet; nur 5 ohne jede Spur (D63.7, D76.1, D76.2, D90.1, D90.2). Aber 33 von 44 stehen weder in der Vorgangsliste noch im Archiv noch im CHANGELOG. Ursache: Befunde gehen als Textzeile in den Vorrat des Teams (`ROLLE-PRUEFUNG.md` „Klasse 1“); kein Vorgang, kein Stand, keine Antwort zurück. Diogenes sieht nicht, was erledigt oder verworfen ist, kann nicht ausmisten, seine Verwerfquote ist nicht zählbar. Prüfbericht 116 KB (Grenze etwa 30 KB).

**Frage:** Wie kommt die Antwort zu Diogenes zurück?

- **A (Empfehlung):** jeder Befund der Klasse 1 und 2 als Vorgang beim Besitzer (`vorgang.py neu`, „D92.2“ im Titel); Ford startet ihn wie jeden Vorgang; Stand „erledigt“ oder „verworfen, weil …“. Diogenes liest den Stand aus der Liste und schiebt Erledigtes ins `PRUEFBERICHT-ARCHIV.md`. Gegenargument: mehr Zeilen in der Liste (heute über 1000) und jeder Befund kostet eine Sitzung; dafür sagt Diogenes' Rolle schon „wenige, belegte, wichtige Befunde“.
- **B:** Textzeile bleibt, der Empfänger muss darunter „erledigt <Commit>“ oder „verworfen, weil …“ schreiben; ein Werkzeug sammelt das für Diogenes. Gegenargument: wieder eine Pflicht ohne Auslöser; genau so blieben Wochentermine liegen (719).

Antwort: „722 A“ oder „722 B“.
