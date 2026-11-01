# 348.12a · Grak schreitet: dritten Probelauf freigeben?
Jerry · 01.11., 17:4x · E Kampf

**Frage:** Darf ich für 348.12 (Grak schreitet statt zu rennen; dein Wort 29.10., 10:55: „gut, aber Gang schreitend statt kurzer Sprint“) einen dritten Probelauf machen, damit der Film entsteht? Die Grenze ist zwei Läufe je Vorlage (389); beide sind verbraucht, keiner kam bis zum Film.
**Votum Jerry:** ja, ein Lauf; danach Film an dich, egal wie er ausfällt.
**Berührt:** 348.12, Regel 389; nebenbei 453 und 402 (dort lagen die Ursachen).

## Sachverhalt

- Bau: Grak geht beim Platzwechsel, im Anlauf zum Hieb und auf dem Rückweg immer (Walk_Loop), statt ab 1,2 m zu rennen (Jog) und rückwärts im Laufschritt (Jog_Bwd) zurückzukehren; Ausweichen bleibt der kurze Seitenlauf; Wölfe unverändert. Zweig `claude/jerry-348-12-grak-schreitet` (d832791a6), Test `grak_348` prüft „nur Gehen“.
- Lauf 1 (17:11): rot vor dem Grak-Teil, Nullzugriff aus 453 r3 (`figur.gd:892`, Wolfsruhe ohne Modell). Behoben ec2d46bd3.
- Lauf 2 (17:29): rot vor dem Grak-Teil, Test `aufruf_399`: die Kampfblende zeigte nur „WOLF“, weil der Lauf „regeln“ die Sätze aus core (`intro.json`, 402) nie bekam. Am Rechner nachgestellt (`exportIntro` liefert sie), Workflow ergänzt (366a92335, läuft als Lauf von 402, ohne Film).
- Keiner der beiden Fehler stammt aus 348.12; beide lagen in Zweigen, die bisher nur mit „[skip ci]“ gepusht waren.

## Auswertung

- **Stärkstes Gegenargument:** 389 soll verhindern, dass Läufe verbrannt werden; zwei Läufe sind wieder an Fehlern gescheitert, die ein Lauf vorher hätte zeigen können (453 r3 und 402 kamen ohne CI). Entkräftet nur teilweise: beide Ursachen sind im Protokoll nachgewiesen und behoben; ob der laufende Lauf 366a92335 grün wird, steht noch aus, ich starte den dritten erst danach.
- Ohne Freigabe: 348.12 wartet ohne Film; Grak fährt im nächsten Build nur mit dem Test ohne Bild.

**Zu sagen:** „348.12a ja“ oder „348.12a nein“.
