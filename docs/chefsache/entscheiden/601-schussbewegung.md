# 601 · Goblin-Späher: Schussbewegung aus dem Kaufpaket Bow & Arrow · Jerry · 06.11., 07:35

Geprüft an: 21dee4b29 (`claude/jerry-601-spaeher`)

**Frage:** Darf ich für die Schussbewegung des Goblin-Spähers Bildläufe am Bauserver machen (ein Probebild, dann höchstens zwei Läufe mit Bild, kein Film ohne dein „Probebild passt“)?

**Votum Jerry:** ja. Heute gilt „keine Bild- oder Filmläufe ohne Freigabe“ (Guthaben 95 %); ohne Bild sehe ich nicht, ob der Bogen in der Hand bleibt und der Pfeil von der Sehne startet.

**Berührt:** 601, 494 (Gegner von Kapitel 1), 595 (Kampfbewegungen).

## Sachverhalt (deine Fragen aus t266)

- **Schussbewegung:** weder aus der Bibliothek noch selbst gebaut. Der Späher hatte nie eine: der Kampf ruft „Ausholen“, das Goblinmodell kennt nur Stehen, Gehen, Hieb; darum steht er still. Das gekaufte Paket Bow & Arrow (Protofactor, 01.11.) hat „Schießen“ (Anfang, Ende, ganz), auch hockend; damit gehen bei uns schon Gehen und Rennen mit Bogen. Plan: auf das Goblingerüst übertragen wie die Gänge (`waffengang.py`).
- **Pfeil:** selbst gezeichnet wie im alten Spiel (dünner Schaft, Spitze, Federn, im Bogen geworfen). Beim Ducken des Helden flog keiner; das ist behoben (wie alt), fährt im nächsten Build. Was am Pfeil nicht passt, sehe ich erst im Bild.
- **Treffer trotz „In den Schatten“:** regelrecht. Wer im Schatten steht, gibt dem Angreifer Nachteil (zweimal würfeln, der schlechtere zählt), Schutz ist es nicht; so war es auch alt. Die Würfelzeile zeigt dann „(Nachteil)“, außer ein Vorteil hebt ihn auf.

## Stärkstes Gegenargument

Bildläufe kosten Guthaben, und der Späher ist ein Gegner unter vielen. **Entkräftet:** Der Späher kommt in Kapitel 1 als Zufallsgegner im hohen Gras vor (alt `Story.kt`, Anteil 8 von 100 bei Tag); ein Schütze, der ohne Bewegung schießt, fällt in jedem dieser Kämpfe auf. Ein Probebild kostet einen Lauf.
