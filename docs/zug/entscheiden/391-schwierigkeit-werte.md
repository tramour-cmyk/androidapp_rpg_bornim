# 39.1 · Wie stark wirken „Leicht“ und „Schwer“?

Sokrates Kreativ · 16.10., 21:5x · von Team Jerry (16.10., 20:2x), gebaut ohne PR auf `claude/jerry-39-schwierigkeit`. Ziel laut `DESIGN-BALANCE.md`: „Leicht“ 10–15 Punkte Siegquote über „Normal“, „Schwer“ 15–20 darunter. Berührt: 38 (Balance), 59e (Ladenvorrat nach Schwierigkeitsgrad), 62m (Leicht: Questziele gold).

Kurz: Schwierigkeitsgrad: Gegner-TP und -Schaden ×0,8 / ×1 / ×1,2 (Empfehlung A)

**Frage:** Um welchen Faktor ändern „Leicht“ und „Schwer“ Trefferpunkte und Schaden der Gegner?

Gemessen von Jerry (`ChapterSimTest.difficulty`, Mittel der neun Kämpfe, die auf „Normal“ 63–89 % Siegquote haben):

- **A** ×0,8 / ×1,2: **+14 / −18 Punkte**, beides im Ziel.
- **B** ×0,75 / ×1,25: +16 / −23 Punkte, beides knapp über dem Ziel hinaus.
- **C** **Noch nicht:** erst „Normal“ einstellen (38), dann den Grad messen.

**Empfehlung: A.** Beide Werte liegen im Ziel, und die Zahl ist einfach.

<details><summary>Warum, und das stärkste Gegenargument</summary>

**Warum:** Der Faktor wirkt auf den Abstand zu „Normal“, nicht auf „Normal“ selbst. Wird „Normal“ mit 38 nachgestellt, verschiebt sich der Abstand kaum; nachmessen kostet dann nur einen Testlauf, kein neuer Entscheid. Gebaut ist es schon (Schalter im System-Reiter, im Spielstand, alte Stände „Normal“). Mit dem Entscheid kann auch 59e weiter (Ladenvorrat nach Grad).

**Stärkstes Gegenargument:** „Normal“ selbst liegt noch unter dem Ziel (Wolf auf Stufe 1: 75 % statt 85–95 %). Wer jetzt „Schwer“ wählt, bekommt grob 57 % gegen einen gewöhnlichen Wolf, das ist eher ein Bossgefecht. Darum C. Dagegen: Der Grad ist ein Schalter, den jeder zurückdrehen kann, und 38 läuft ohnehin.

**Merkposten, nicht Teil dieser Frage:** Nur Zahlen zu drehen macht „Schwer“ länger, nicht klüger. `DESIGN-KAMPF.md` sieht für höhere Grade eine Finte vor (die Haltung des Gegners lügt) und zwei Absichten zur Wahl. Das kommt mit 72, nicht mit 39.

**Danach:** 39.2 Wortlaut (Name des Schalters, drei Stufen, je ein Satz) schreibe ich als Vorschlag (41); Jerry baut erst nach 39.1 und 39.2.

</details>
