# 448 · Tagesbericht mit Zahlen statt Ampeln
Sokrates · 01.11., 10:5x · B Abläufe

**Frage:** Soll der tägliche „Stand zum Marktstart“ (Perikles, 338.1) durch den Bericht unten ersetzt werden: zehn Zeilen per Telegram, jede mit einer Zahl, die sich von Tag zu Tag ändern kann?
**Votum Sokrates:** ja, zusammen mit 447 besprechen.
**Berührt:** `ROLLE-PROJEKT.md` (Stand zum Marktstart), `LISTE-BETRIEB.md` Schritt 11, `tools/lauf.py --morgen`, Diogenes (zählt nach).

## Was es heute gibt

- Täglich 7:30 (Sa, So 9:30) setzt Perikles den „Stand zum Marktstart“ in `LISTE-ABNAHME-KAPITEL1.md` und schickt ihn per Telegram (338.1, seit 24.10.). Um 7 Uhr kommt dazu Fords Morgenmeldung in einer Zeile.
- Der letzte Stand ist vom 01.11., 00:15; der davor vom 29.10., 01:05. Am 30. und 31.10. kam keiner (Pflegefehler „70 Stunden alt“).
- Inhalt heute: sieben Blöcke, alle gelb, je ein Absatz Text; 0 von 27 Punkten abgehakt; keine Schätzung, kein Verlauf. Man liest, was passiert ist, aber nicht, ob wir näher kommen.

## Vorschlag: zehn Zeilen, jede eine Zahl

1. **Stufe** (447): K1, K2 … mit „x von y Punkten abgenommen, z gebaut, w in Arbeit“.
2. **Seit gestern:** abgenommen a, gebaut b, von dir zurück c.
3. **Rest geschätzt:** n Sitzungen bis zur nächsten Stufe (Schätzung Tom, Jerry; montags neu), und wie viele Sitzungen die letzte Woche geschafft hat. Keine Tage, es gibt keinen Termin.
4. **Wartet auf dich:** Zahl je Art (entscheiden, ansehen, testen, tun), ältestes seit wann.
5. **Builds:** letzter Build, getestet ja/nein; Änderungen, die auf einen Build warten.
6. **Fehler:** offen aus deinen Tests; davon älter als drei Tage.
7. **Geld:** Wochenguthaben in % (aus deinem letzten Bild, mit Datum), gestern in $, Anteil Spiel in %.
8. **Gefunden von dir zuerst** (Haltung 7): diese Woche n.
9. **Größtes Risiko:** ein Satz mit Gegenmittel und wer.
10. **Link** auf den ausführlichen Stand (bleibt wie heute in der Liste).

Was sich nicht als Zahl zählen lässt, kommt nicht in die zehn Zeilen; Ampeln, Ausgaben im Einzelnen und die ganze Risikoliste bleiben im ausführlichen Stand (Zeile 10).

**Das ändert eine Vorgabe von dir:** Für den Stand gilt dein Wort „keine Testzahlen, kein Build-Verlauf“ (09:06, eingetragen in `ROLLE-PROJEKT.md`); Zeilen 5 und 6 bringen beides in kurzer Form zurück. Willst du das weiter nicht, fallen sie weg. Für Zeile 1 und 2 bekommt die Abnahmeliste je Punkt einen Stand (offen, in Arbeit, gebaut, abgenommen); heute kennt sie nur offen oder abgehakt.

## Auswertung

*Stärkstes Gegenargument:* Zahlen täuschen Fortschritt vor, wenn sie sich zählen lassen, ohne etwas zu bedeuten („gebaut“ heißt nicht „gut“), und wer berichtet, optimiert auf die Zahl. *Wie es zu entkräften ist:* Gezählt wird nur „abgenommen“ als Fortschritt, abgehakt von dem, der in der Zeile als Prüfer steht (bei Aussehen, Klang und Durchspielen du); „gebaut“ steht daneben, nicht darin. Diogenes zählt die Zeilen 1, 2, 6 und 8 einmal die Woche selbst nach und meldet Abweichungen (Wochenzählung). Dass am 30. und 31.10. kein Bericht kam, meldet `regelcheck` erst nach 26 Stunden; neu: fehlt der Bericht um 10 Uhr (Sa, So 12 Uhr), schickt Fords Lauf zu dieser Stunde dir eine Zeile und startet Perikles.

## Folgerung

Mit „448 ja“ baut Perikles den Bericht (Zählung aus der Abnahmeliste, `startbar.py`, `zug-index.py`, `kosten.py`), erster Bericht am Tag nach der Zuordnung 447.

Erledigt: Antwort ins Vorgangsarchiv, Datei löschen (Sokrates).
