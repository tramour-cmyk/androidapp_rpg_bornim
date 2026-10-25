# 348.6 · Blick nach Süden zeigt die Rückseiten der Häuser: was geben wir auf?
Tom · 25.10., 13:08 · G Stil · Muss
Kurz: In der neuen Grundansicht liegen alle Türen auf der abgewandten Seite. Wir können nur zwei von drei Wünschen erfüllen.

## Frage

Seit Runde 11 blickt die Kamera nach Süden, und die Sonne steht wie in der Natur. Im Dorf liegen aber alle 9 Türen an der Südseite ihrer Häuser. Die Kamera sieht also die Rückwände. Tür, Ladenfront und Kirchenportal liegen hinter dem eigenen Dach. Der Prüfer schreibt: „Kein Held zu sehen … die Tür des Hauses liegt komplett hinter den Kronen“.

Die Sonne steht mittags im Süden, also fällt der Schatten nach Norden. Darum sind nur zwei der drei Wünsche zugleich möglich:
- Sonne wie in der Natur,
- Schatten fallen zum Betrachter,
- Türen und Fronten sind zu sehen.

Was geben wir auf?
- **a:** Die Grundansicht kommt zurück wie im alten Spiel: Kamera im Südosten, Blick nach Nordwesten. Die Sonne bleibt wie in der Natur. Mittags fallen die kurzen Schatten nach rechts und leicht nach hinten. Morgens fallen sie nach hinten links, abends nach rechts und leicht nach vorn.
- **b:** Der Blick nach Süden bleibt. Die Häuser bekommen ihre Türen auf der Nordseite. Dafür werden 9 Gebäude umgebaut (mit der Kirche), Wege umgelegt und die Grundrisse gespiegelt. Leute, Kisten und Schilder werden neu gesetzt.
- **c:** Die Grundansicht kommt zurück wie im alten Spiel, und die Sonne läuft wie im alten Spiel: mittags im Norden, Schatten zum Betrachter.

## Votum

a.

## Berührt

348.6 (Dorf in Godot); bei b die Karte in `core` (das alte Spiel ruht), die Grundrisse und jede Gebietskarte mit Häusern.

## Begründung

- Bei a ändert sich im Code eine Zeile (`Kamera.NORD` wieder 45). Dazu stelle ich den Helden für die Vergleichsbilder wieder südlich der Häuser auf. Alt und neu bleiben direkt vergleichbar, und das ist die Vorgabe des Umzugs („mindestens so gut wie alt“). Die Fronten stehen im Bild wie im alten Spiel.
- Die Schatten bleiben sichtbar. Weil wir schräg auf das Dorf blicken, liegen sie meist neben den Dingen und nicht hinter ihnen. Morgens und abends sind sie lang, abends fallen sie schräg nach vorn rechts.

## Sachverhalt

- Die Dorfkarte hat 9 Gebäude mit Dach, die Kirche mitgezählt. Die Türen liegen jeweils in der untersten Mauerreihe, also im Süden, und die Wege verlaufen südlich davon. Beispiele (Spalte/Zeile): Laden Haus 26/3, Tür 28/5; Kirche Haus 26/18, Tür 28/20.
- Runde 11 hat für die Bilder den Helden nördlich der Häuser gestellt. Darum zeigen die Bilder Rückwände.
- Fremder Prüfer, Runde 11b: In den Bildern Tür, Laden und Kirche sind Eingang und Front nicht zu sehen. Der Held ist hinter Dach oder Kronen verdeckt. Auf dem Marktplatz stimmen Schatten und Helligkeit („gedämpft, nicht zu freundlich“).

## Auswertung

- Für b: Nur so gelten alle drei Wünsche, die du um 12:25 genannt hast: Blick nach Süden, Sonne wie in der Natur, Schatten zum Betrachter.
- Gegen b: Die Arbeit ist groß, ich schätze 3 bis 5 Sitzungen nur für das Dorf. Alt und neu lassen sich dann nicht mehr Bild für Bild vergleichen, und „Ort fertig“ müsste für das Dorf neu abgenommen werden.
- Eine billigere Form von b wäre, die ganze Dorfkarte von Nord nach Süd zu spiegeln. Dann lägen aber der Fluss im Norden und der Schlagbaum im Süden, gegen die Geschichte („Der Weg nach Süden …“) und die Windrose. Darum verwerfe ich das.
- Für c: c ist so billig wie a, und die Schatten fallen mittags nach vorn. Aber eine Mittagssonne im Norden fällt neben der Windrose auf, und das war der Anlass für 3486-sonne.
- **Stärkstes Gegenargument gegen a:** Du wolltest um 12:25 ausdrücklich, dass die Schatten in der Grundansicht zum Betrachter fallen. Bei a fallen sie mittags nach rechts hinten und morgens nach hinten. Ein Teil verschwindet hinter hohen Häusern. Genau das sollte 89 vermeiden (15.10.: Schatten „mittags kurz nach vorn, nicht nach Norden, sonst versteckt hinter den Häusern“).
- Unabhängig davon: Der Held war in Runde 11b auch hinter Kronen und Dächern verdeckt. Das behebe ich bei jeder Antwort getrennt; die Durchsicht um den Helden reicht noch nicht.

## Folgerungen

- a: Tom stellt die Grundansicht und die Bildstellungen zurück und legt ein Vergleichsblatt alt/neu vor, dazu drei Tageszeiten.
- b: Tom schreibt einen Bauplan für das Dorf (Häuser, Wege, Grundrisse) und legt zuerst einen Entwurf vor.
- c: Wie a, nur dass die Sonne den alten Lauf bekommt (`--sonne=alt` wird Grundeinstellung).

Antwort: …
