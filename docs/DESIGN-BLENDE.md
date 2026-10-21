# Zwischenbildschirm (Thema 24): Design

Die Texte stehen in `STORY-BLENDE.md` (Marken `[24.…]`).

## Designideen

Ein schwarzer Bildschirm mit einem Satz in der Mitte passt besser zum düsteren Stil als jeder Ladebalken. Grundidee des Nutzers, an diesen Stellen geschärft:

1. **Hören vor Sehen.** Während der Bildschirm schwarz ist, läuft schon der Klang des Ziels: Wind im Flüsterwald, Tropfen in der Höhle, Stimmengewirr im Greif. Klang ist Jerrys Bereich (Thema 18).
2. **Kein harter Schnitt in die Karte.** Der Text verblasst, dann taucht die Karte aus dem Schwarz auf, etwa 0,5 s (passt zur Vorgabe aus 24: Übergang Blende → Karte weich).
3. **Zeiten.**
   - Einblenden 0,4 s.
   - Mindestens 1,5 s stehen lassen, damit der Satz lesbar ist, auch wenn alles schon fertig ist.
   - Ausblenden 0,6 s.
   - Wartet, bis Held, Boden ringsum und Leute gezeichnet sind (267.1, Chef 21.10.: „lieber … ein bisschen länger warten, aber dafür läuft's“; vorher höchstens 4 s).
   - Antippen überspringt, sobald das Nötige gezeichnet ist.
   - Kein Kreisel; Ladebalken nur bei absehbar langer Wartezeit (Held neu zu zeichnen, oder über 3 s), zählt Bilder, schätzt keine Zeit (267.1).
4. **Schrift.** Serifenschrift in gebrochenem Weiß, leicht gesperrt. Darüber der Ortsname klein in Kapitälchen als Anker, darunter der Satz. Ein Hauch Vignette, damit das Schwarz nicht wie ein Absturz wirkt.
5. **Kampf fühlt sich anders an als Ortswechsel.**
   - Hinterhalt: kein sanftes Einblenden. Schlagartig schwarz, Text sofort da, dazu ein Herzschlag oder ein scharfer Klang.
   - Erstschlag des Helden: ruhig, leise, fast geflüstert.
   - Bossgegner: länger stehen lassen, der Name groß.
6. **Gegen Eintönigkeit.**
   - Nie zweimal hintereinander derselbe Satz.
   - Erster Besuch eines Orts: ganzer Satz. Häufige Wechsel (etwa zum fünften Mal in Thessas Laden): nur der Ortsname, etwa 1 s.
   - Eigene Sätze für Nacht; später Sätze je Spielstand (Tempel vor und nach der Rettung von Lyra).
7. **Grammatik umgehen statt lösen.** „Ein Kampf mit {Gegner}“ scheitert an Fall und Artikel (dem Goblin, der Riesenspinne, Krogg ohne Artikel, ein Rudel Wölfe). Darum:
   - Zeile 1: Satz zur Eröffnung ohne Gegnernamen.
   - Zeile 2: Gegnername groß, als Titel.
   - Zeile 3 (normaler Kampfbeginn, Bossgegner immer): Satz je Gegner, voll ausgeschrieben, ohne Platzhalter.
8. **Abgleich mit dem Kampftext.** Heute steht dort „Hinterhalt! {0} springt aus dem Versteck!“ bzw. „{0} überrascht {1} von hinten – Erstschlag!“. Der Zwischenbildschirm erzählt die Stimmung, der Kampftext hält nur noch knapp die Mechanik fest:
   - „Hinterhalt – Goblin hat den ersten Zug.“
   - „Erstschlag – Goblin ist überrascht.“
   - „Kampf gegen Goblin.“
   - Elite, schimmernde Variante, Rudelgröße und „gut gestärkt“ bleiben im Kampftext, nicht auf dem Bildschirm.
9. **Englisch.** Alle Texte im Spiel haben eine deutsche und eine englische Fassung; die Sätze in `STORY-BLENDE.md` brauchen noch die englische Übersetzung.

## Prüfpunkte und Aufteilung

Vor dem Einbau gegen Geschichte und Karten prüfen:

- Grak Nr. 5 passt nur, solange Lyra noch gefangen ist (als Bedingung bei `[24.gegner.grak.5]`).
- Die Ortssätze dürfen nichts erwähnen, was es dort nicht gibt.

Aufteilung:

| Teil | Wer | Thema |
| --- | --- | --- |
| Ortswechsel, Ortstexte | Tom | 24.1 |
| Kampfbildschirm, Kampftext | Jerry | 24.6 |
| Klang während der Blende | Jerry | 18 |
