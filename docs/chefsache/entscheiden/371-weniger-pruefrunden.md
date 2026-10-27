# 371 · Aussehensfragen direkt an dich statt in blinde Helferrunden?

Sokrates · 27.10., 09:15 · B Betrieb · M

Kurz: In der Nacht liefen 22 Teamsitzungen für 207 $. Tom arbeitete am Feinschliff des Helden, Jerry an der Todprobe. Über das Aussehen urteilten Helferrunden statt dir.

**Frage:** Sollen Geschmacksfragen künftig als Auswahlblatt zu dir gehen statt durch blinde Helferrunden? Soll nachts nur noch Technik gebaut werden? Und soll Ford eine abgelehnte Archivierung einmal wiederholen?

**Votum:** „371 ja“ heißt:
1. **Geschmack entscheidest du:** Bei Glanz, Farbe, Form oder Gesicht baut das Team zwei oder drei Fassungen auf ein Blatt. Ein Helfer prüft es nur auf Fehler (338.2), dann geht es sofort per Telegram an dich. Blinde Helferrunden über Geschmack („Helfer blind 3 von 3“) gibt es nicht mehr.
2. **Nachts Technik, kein Feinschliff am Aussehen:** Zwischen 21 und 7 Uhr bauen die Teams Bewegungen, Fehlerbehebungen und den Einbau. Offene Aussehensfragen sammeln sie auf einem Morgenblatt für dich.
3. **Archivieren:** Lehnt der Auto-Modus-Prüfer `archive_session` ab, versucht Ford es im selben Lauf noch einmal. Erst nach der zweiten Ablehnung meldet er WARNUNG-LAUT an dich, wie bisher.

**Berührt:** 338.2 (Helfer prüft vor jeder Vorlage), 362 (nachts urteilt Sokrates), „Der Chef sieht mit“ (`LISTE-UMZUG-348.md`), `ROLLE-ENTWICKLUNG.md`, 369

## Begründung

Aussehen entscheidet laut `CLAUDE.md` nur der Chef. Die Bekannten Fehler sagen außerdem: „Nie ein Urteil des Chefs … durch ein Helferurteil ersetzen“. Die blinden Helferrunden sind genau dieser Ersatz: Sie kosten Geld und Zeit, und du siehst das Ergebnis trotzdem nicht.

## Sachverhalt

- **Nacht 27.10., 00 bis 09 Uhr:** 15 Tom-Sitzungen für 110 $ und 7 Jerry-Sitzungen für 97 $, zusammen 207 $, also etwa 23 $ je Stunde. Eine Tom-Sitzung lief etwa 30 Minuten und kostete 5 bis 10 $.
- **Woran gearbeitet wurde** (Tom: Commits `claude/tom-348-fundament`; Jerry: Sitzungstitel):
  - Helmglanz 0,45: „Helfer blind 3 von 3“.
  - Kragen mit Lederborte: „Helfer blind“.
  - Iris braun: „blind zwei Runden“.
  - Tusche: „Helfer blind 22 Paare“, ein zweites Mal 12 Paare.
  - Jerry: Todprobe Runden 3, 4, 4c und 4d, vier Sitzungen für 55 $.
- **Kostentreiber:** Jede Sitzung liest bei jedem Schritt ihren ganzen Verlauf von 200.000 bis 250.000 Token neu ein, das ergibt 15 bis 30 Mio. Token je Sitzung. Die Bilder der Helferrunden kommen noch dazu. Ihren Anteil kann ich aus den Sitzungsdaten nicht getrennt messen.
- **Nachtvertretung:** Kein Team hat mir in der Nacht ein Bild oder eine Urteilsbitte geschickt. Geurteilt haben nur die Helfer.
- **Archivieren:** Fords Übergabe von 07:10 meldet, dass der Prüfer ablehnt. In dieser Sitzung gingen von 35 Aufrufen 33 durch, die zwei abgelehnten beim zweiten Versuch. Der Prüfer entscheidet also jeden Aufruf einzeln, nicht grundsätzlich.

## Auswertung

- **Stärkstes Gegenargument:** Mehr Bilder bedeuten mehr Arbeit für dich, und die Helfer haben echte Fehler gefunden („Knopfaugen“, Kettenhemd „wie Fischernetz“). Ohne sie müsstest du diese Fehler selbst finden.
- **Antwort:** Die Fehlerprüfung bleibt, ein Helfer je Blatt. Nur das Urteil über Geschmack wandert zu dir. Ein Blatt mit drei Fassungen kostet dich eine Antwort statt drei Helferrunden.
- **Noch nicht:** Wartezeiten auf dich halten die Teams nicht auf. Die Regel „wartet auf Chef“ hält nicht an (`LISTE-BETRIEB.md` „Fertig“). Die Teams arbeiten am nächsten Vorgang weiter.

## Folgerungen

- **Bei „ja“:** Perikles schreibt die drei Punkte in `ROLLE-ENTWICKLUNG.md` und `LISTE-BETRIEB.md`. Für die Regelbilanz ändert er in den Bekannten Fehlern „beim Aussehen nach drei Runden vorlegen“ (362) auf „nach einer Runde“. Eine eigene Regel für die blinden Helferrunden gibt es nicht. In den Regeldateien steht keine; sie tauchen nur in Toms Commits auf.
- **Messung:** Kosten einer Nacht und Zahl der Bilder an dich, vorher (Basis 207 $ für 9 Stunden) und nachher. Diogenes zählt montags.

Antwort: …
