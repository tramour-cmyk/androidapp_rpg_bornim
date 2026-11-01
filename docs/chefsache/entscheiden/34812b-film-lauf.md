# 348.12b · Grak schreitet: noch ein Lauf für den Film?
Jerry · 01.11., 20:3x · E Kampf

**Frage:** Darf ich für 348.12 noch einen Lauf machen, nur damit der Grak-Film entsteht? Der freigegebene Lauf (348.12a, 19:40) hat den Grak-Teil erreicht, aber der Film kam nicht: ein Prüfschritt davor war rot, und der Workflow überspringt danach den Film.
**Votum Jerry:** ja, ein Lauf; der Film geht danach an dich, egal wie er ausfällt.
**Berührt:** 348.12, Regel 389.

## Sachverhalt

- Lauf 175 (c6a3bb68d): Regeln grün, Modellbau grün (Reparatur Goblin-Bau trägt), Grak-Test mit 2 von 26 Prüfungen rot.
- Grün, und das ist dein Wunsch vom 29.10.: Grak bewegt sich beim Platzwechsel nur noch im Gehen, geht zum Hieb und kehrt im Gehen zurück („kein Lauf“, beide Entfernungen), Axt trifft den Rand des Helden, Ausweichen und Tod wie vorher.
- Rot: „Gleiten“ beim kurzen Platzwechsel (0,9 m: 26 %, lang 11 %). Ursache nachgerechnet, nicht vermutet: seit 438 fährt der Körper 0,35 s an und bremst ebenso; die Schritte werden dabei mitverlangsamt (`_schritt_sync`). Der Test verglich mit dem vollen Tempo und zählte die Rampe als Gleiten; die Rampe erklärt beide Werte (0,35 / (Weg/Tempo + 0,35)). Test berichtigt (52c184d2b, ohne Lauf): misst jetzt gegen die tatsächlich gespielten Schritte.
- Der Fehler stammt aus 438, nicht aus 348.12; er wäre auch mit Rennen beim kurzen Weg aufgetreten (dort ging Grak schon immer).

## Auswertung

- **Stärkstes Gegenargument:** du hast genau einen Lauf freigegeben, und auch dieser zeigte wieder einen Fehler, den ein früherer Lauf hätte zeigen können. Und: die Berichtigung des Tests ist nur gerechnet, nicht im Lauf bestätigt; bleibt der Prüfschritt rot, fehlt der Film erneut. Darum würde ich den Film-Schritt im selben Zug unabhängig vom Test laufen lassen (Workflow: Film auch bei rotem Test), damit dieser Lauf den Film sicher liefert.
- Ohne Lauf: Graks Gang ist im Test bestätigt, aber du siehst ihn erst im nächsten gemeinsamen Build.

**Zu sagen:** „348.12b ja“ oder „348.12b nein“.
