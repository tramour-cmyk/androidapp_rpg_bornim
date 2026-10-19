# D3a · Ortsklang im Kampf: alles oder nichts?
Jerry · 19.10., 08:2x · E Klang · Umsetzung Jerry (eine Zeile in `WorldScreen.kt`, mit Absprache Tom)

Kurz: im Kampf verstummt der ganze Ortsklang (Feuer, Fluss, Regen, Tiere); Empfehlung: jetzt so lassen, mit dem Kampfort aus der Karte (72u) alles leiser weiterlaufen lassen.

**Frage** (Chef 16.10., 21:0x, Wortlaut): „Frage ist, warum bei 9.2 erwartet wird, dass wenn es regnet und ein Kampf beginnt, der Regen weg ist? Bitte prüfen.“

**Befund:** Feuer, Fluss, Frösche, Vögel und Regen hängen an derselben Bedingung „ruhig“: nur beim Erkunden, ohne offenes Menü (`WorldScreen.kt`, `calm`). Im Kampf und im Menü klingen sie in etwa 1,5 s aus, damit Kampfmusik und Treffer klar sind (24.8.5). Der Regen ist mit D3.10 einfach in diese Regel gerutscht (`RainSound.target`); den Fall „Regen im Kampf“ hat keiner eigens entschieden. Der Kampfort zeigt heute keinen Regen.

**Nachfrage** (Chef 19.10., 08:33, Wortlaut): „Dann müssten aber alle "Hintergrundgeräusche" (Feuer, Fluss etc.) der Szene laufen und nnicht nur der Regen, oder? Entweder alles oder nichts. Deine Empfehlung dazu?“

**Empfehlung (ersetzt „nur der Regen“): alles oder nichts, ja; jetzt nichts, mit 72u alles.**
1. **Bis zum Meilenstein bleibt es, wie es ist:** im Kampf schweigt der ganze Ortsklang. Der Kampfort zeigt weder Feuer noch Fluss noch Regen; Klang ohne Bild widerspricht „Licht und Laut aus sichtbaren Quellen“ (D3.15). Kein Umbau in der Woche „Fehler ausmerzen“ (179).
2. **Mit dem Kampfort aus der Karte (72u):** dort sieht man den Ort, an dem man kämpft; dann läuft der ganze Ortsklang weiter, leiser unter der Kampfmusik (etwa halb). Eine Ausnahme, weil sie selbst ein Klang des Kampfes ist: Vögel und Frösche verstummen, wenn ein Kampf beginnt (Tiere fliehen vor Lärm), und kommen danach langsam wieder. Kosten mit 72u gering (eine Bedingung in `WorldScreen.kt`).

**Stärkstes Gegenargument:** du hast den fehlenden Regen bemerkt; das Schweigen fällt also heute schon auf, und 72u kommt erst nach dem Meilenstein, die 12 Tester hören es auch. Dagegen: das wäre Ortsklang ohne Ort; ein Kampf, der plötzlich am Fluss rauscht, aber eine Höhlenwand zeigt, fällt mehr auf als Stille unter Musik. Wer es heute will: „jetzt“, dann baue ich Punkt 2 ohne Bild (etwa 0,5 $).

**Berührt:** D3.10, 24.8.5, D3.15, 72u, 179; vorher: D3.10 (Regenklang), 24.8.5 (Ausklingen), 72u (Kampfort aus der Karte), D3.15.
