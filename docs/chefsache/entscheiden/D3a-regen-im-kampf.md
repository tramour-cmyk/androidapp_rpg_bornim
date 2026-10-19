# D3a · Regen im Kampf: weiterrauschen lassen?
Jerry · 19.10., 08:2x · E Klang · Umsetzung Jerry (eine Zeile in `WorldScreen.kt`, mit Absprache Tom)

Kurz: der Regen verstummt im Kampf nur, weil alle Ortsklänge im Kampf und im Menü verstummen; einen eigenen Grund für den Regen gibt es nicht. Empfehlung: im Kampf leiser weiterrauschen lassen.

**Frage** (Chef 16.10., 21:0x, Wortlaut): „Frage ist, warum bei 9.2 erwartet wird, dass wenn es regnet und ein Kampf beginnt, der Regen weg ist? Bitte prüfen.“

**Befund:** Feuer, Fluss, Frösche, Vögel und Regen hängen an derselben Bedingung „ruhig“: nur beim Erkunden, ohne offenes Menü (`WorldScreen.kt`, `calm`). Im Kampf und im Menü klingen sie in etwa 1,5 s aus, damit Kampfmusik und Treffer klar sind (24.8.5). Der Regen ist mit D3.10 einfach in diese Regel gerutscht (`RainSound.target`); den Fall „Regen im Kampf“ hat keiner eigens entschieden. Der Kampfort zeigt heute keinen Regen.

**Empfehlung: ja, Regen rauscht im Kampf weiter, auf halber Lautstärke** (Wetter hört nicht auf, weil ein Wolf kommt; draußen bleibt der Ort hörbar). Feuer, Fluss und Tierleben bleiben im Kampf still; im Menü verstummt auch der Regen. Kosten etwa 0,5 $, mit dem nächsten Build von Jerry.

**Stärkstes Gegenargument:** der Kampfort zeigt keinen Regen; man hört ihn, sieht ihn aber nicht (Licht und Laut aus sichtbaren Quellen, D3.15). Dagegen: der Regen war schon auf der Gebietskarte zu sehen und fällt weiter; Regen im Kampfbild kommt mit dem Kampfort aus der Karte (72u, nach dem Meilenstein). Wer es streng will: „noch nicht“, Regen im Kampf erst mit 72u, Bild und Klang zusammen.

**Berührt:** D3.10 (Regenklang), 24.8.5 (Ausklingen), 72u (Kampfort aus der Karte), D3.15.
