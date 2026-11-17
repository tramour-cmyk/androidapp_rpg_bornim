# 1520 · Sollen wir an den Läufen so sparen: Neustart-Haken auch in langen Zügen mit Sperre ab 300 Tsd. (A) und Halt je Vorgang bei 40 $ ohne dein 👍 (B)?
Sokrates · 17.11., 08:05 · B Steuerung · aus deinem Wort 06:18
Kurz: Lange Sitzungen und teure Vorgänge sind die zwei großen Löcher; A schließt das erste per Haken, B legt dir das zweite einmal je Vorgang vor.
Beim Chef, weil: Geld

Geprüft an: 195084a02 (`tools/neustart-haken.py`, `.claude/settings.json`, Kostenspalte `LISTE-VORGAENGE.md`)

**Frage:** Du hast gefragt: „wie kann ich an den Läufen sparen?“ Zwei Hebel, getrennt zu entscheiden. A: Sitzungen werden zu lang, weil der Neustart-Haken nur bei einer Nachricht an die Sitzung misst; arbeitet eine Sitzung nachts stundenlang in einem Zug, kommt keine Erinnerung. B: Ein Teil der Vorgänge wird sehr teuer, ohne dass jemand fragt, ob er das wert ist.

**Votum:** „1520 A“: A und B einführen. Willst du keine zusätzlichen Zeilen auf Telegram: „1520 nur A“.

**Berührt:** Spike (Haken), Perikles (Regel B, `startbar.py`), alle bauenden Rollen; 865 (kein Neustart, solange du testest) und 818 (Kaufrepo, doppelte Schwelle) bleiben.

**Begründung:** Jeder Schritt einer Sitzung liest das ganze Gespräch noch einmal; eine Sitzung bei 500 Tsd. kostet je Schritt etwa das Fünffache einer bei 100 Tsd. Ein Neustart kostet einmal den Start (Rollendatei, Vorrat, Zeilen).

**Sachverhalt:**
- Neustart-Haken (`tools/neustart-haken.py`, 383 A): erinnert ab 200 Tsd. (mit Kaufrepo 400 Tsd.), aber nur über `UserPromptSubmit`, also bei einer Nachricht an die Sitzung. In langen Zügen ohne Nachricht misst niemand. Der Weiter-Haken zwingt erst nach der zweiten Erinnerung zum Neustart; die kommt so nie.
- Heute Nacht: Tom 430 Tsd., Jerry 572 Tsd. (Messung Sokrates 06:2x).
- Alle offenen Vorgänge zusammen: 1.636 $; die 13 über 40 $ tragen 1.031 $ (63 %): 494 (Gegner Kapitel 1, 135 $, ruht), 431 (Völker als Modelle, 126 $), 348.13 (Tusche nach Licht, 89 $, ruht), 870 (Umstellung auf BRS, 89 $), 709.1 (Biss auf den Schild, 83 $), 620 (Stärken und Schwächen, 80 $), 507 (Kampforte Höhle, 75 $, ruht), 709 (Treffer sichtbar, 64 $), 1137 (Vollzugsmeldung, 62 $), 654 (Mitdenken vor dem Bauen, 61 $), 531 (Garrick, 45 $), 930 (Handgemenge, 41 $), dazu Fords Betrieb (80 $).
- Fünf der 13 sind meine (870, 620, 1137, 654, 930; zusammen 352 $).

**Auswertung:**
- **A (Empfehlung):** Spike hängt den Neustart-Haken zusätzlich an jeden Werkzeugaufruf: ab 200 Tsd. Erinnerung wie heute, ab 300 Tsd. sperrt er alles außer Übergabe, Push und Neustart-Nachricht an Ford (mit Kaufrepo 400 und 500 Tsd.; nie, solange du einen Build der Sitzung testest, 865). Kosten: etwa ein Bauschritt Spike.
- **B:** Erreicht ein Vorgang 40 $ ohne dein 👍 auf eine Meldung dazu, setzt `startbar.py` ihn auf „Chef“ und Telegram bringt dir eine Zeile: weiter, vereinfachen oder streichen. Ein 👍 gilt bis zur nächsten Schwelle (80 $). Kosten: etwa ein Bauschritt Perikles; für dich etwa ein bis drei Zeilen am Tag.
- **Nichts ändern:** Laut deinem Wort 16.11., 21:30 („50 Prozent Wochenverbrauch. Wir machen weiter ohne Einschränkungen“) reicht das Guthaben; dann bleibt nur, dass wir teurer arbeiten als nötig.
- **Stärkstes Gegenargument gegen A:** Ein Neustart mitten in einer Arbeit verliert, was nicht in der Übergabe steht, und der Nachfolger liest neu ein. Antwort: Sperre erst bei 300 Tsd., nach zwei Erinnerungen ab 200 Tsd.; die Übergabe ist der Ablauf, der heute schon gilt, nur greift er nun auch nachts.
- **Stärkstes Gegenargument gegen B:** Du wirst zum Engpass, ein Muss steht, bis du antwortest. Antwort: nur einmal je Schwelle, und Muss mit „jetzt“ laufen weiter (Zeile kommt trotzdem).

**Folgerungen:** Auf „1520 A“: Vorgang an Spike (Haken), Vorgang an Perikles (Regel und `startbar.py`), Prüfung am 24.11. (Länge der Sitzungen, Kosten je Tag gegen diese Woche). Unabhängig davon schlage ich am 23.11. vor, 620 (Stärken und Schwächen) und 1137 (Vollzugsmeldung) zu schließen.

Antwort: …
