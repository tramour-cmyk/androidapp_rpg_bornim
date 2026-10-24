# 354 · Kämpfer im klassischen Kampf: echte Wahl statt nur „Angriff“?
Jerry · 24.10., 21:23 · G Balance · M (Chef 24.10. zu Chefsache 26: „einfach die Angriffstaste beim Kämpfer gespammt … allerhöchstens mal ab und zu einen Tatendrang, aber der ging ja dann auch bloß einmal“)
Kurz: Kämpfer klassisch: harte Schläge vorher ansagen, Tatendrang je Kampf? (Empfehlung: a)

**Sag:** „354 a“, „354 b“, „354 a+b“ oder „noch nicht“. Gebaut wird es zusammen mit der Eichung 38.

**Befund (Code, `Battle.kt`, `Rules.kt`):**
- Der Kämpfer hat im klassischen Kampf Angriff, Abwehr, Zweiter Atem (einmal pro Kampf), Tatendrang ab Stufe 2 (einmal pro Rast an Lagerfeuer oder Gasthaus), Gegenstände und Flucht. Die Nebenhand schlägt bei jedem Angriff von selbst mit.
- Abwehr gibt allen Angriffen auf den Helden Nachteil. Verfehlt ein Gegner, hat der nächste eigene Angriff Vorteil (Konter).
- Harte Schläge: Grak führt seine „Lücke in deiner Deckung“ (+2W6 und Blutung) in festem Takt, im 1., 4., 7. … Zug. Das Wildschwein (Ansturm) und Krogg (Überraschungsangriff) schlagen beim ersten Treffer härter zu. Der Spieler erfährt davon jeweils erst nach dem Treffer. Darum weiß er nie, wann Abwehr lohnt, und „Angriff“ ist fast immer richtig.

## a · Harte Schläge vorher ansagen (empfohlen)

Bevor der harte Schlag kommt, steht eine Zeile im Textfeld, und der Gegner hält seine heutige Ausholbewegung länger. Neue Zeichnungen braucht es dafür nicht. Dann hat der Spieler die echte Wahl: abwehren (der Schlag hat Nachteil, verfehlt er, folgt der Konter) oder weiter zuschlagen und den Treffer riskieren. Die Regeln bleiben, wie sie sind. Die Sätze schreibt Homer. Gilt für alle Klassen.
- Grak: Ansage vor jedem harten Schlag. Trinkt er stattdessen einen Trank, entfällt die Ansage.
- Wildschwein und Krogg: Ansage vor jedem Angriff, bis der erste Treffer sitzt. Greifen sie aus dem Hinterhalt oder mit gewonnener Initiative an, bevor du wählen kannst, kommt die Ansage zu spät. Mit Morwens Rauchbündel entfällt Kroggs Überraschungsschlag ohnehin.

## b · Tatendrang einmal pro Kampf statt pro Rast

Deine Klage „ging bloß einmal“: Nach SRD gilt Tatendrang einmal pro kurzer oder langer Rast, und so ist es gebaut. Einmal pro Kampf wäre eine Hausregel und macht den Kämpfer stärker, darum gehört sie zur Eichung 38. Eine echte Wahl bringt sie nicht, man setzt Tatendrang dann einfach in jedem Kampf ein.

**Nicht empfohlen:** Stoßen (SRD: Shove). Nach SRD ersetzt Stoßen einen Angriff, und Aufstehen kostet nur halbe Bewegung. Nutzen bringt es erst mit dem zusätzlichen Angriff ab Stufe 5. Außerdem fehlen im Code Fertigkeiten (Athletik) und Größen. Viel Arbeit für wenig Wahl in Kapitel 1. Ebenfalls nicht empfohlen: die Nebenhand als eigener Knopf, das bringt nur mehr Tippen.

**Stärkstes Gegenargument:** Echte Wahl soll der MARS bringen. Wird er mit dem Schalter (212) zum Standard oder kommt die Engine (348), ist Arbeit am klassischen Kampf zum Teil verloren. Dagegen spricht: a ist klein (Textzeile und längeres Ausholen, keine neuen Regeln, keine Zeichnungen) und hilft sofort in Kapitel 1.

**Berührt:** 38 (Eichung), 212 (Schalter MARS/klassisch), 348 (Engine), 304 (offen, a ändert daran nichts).
