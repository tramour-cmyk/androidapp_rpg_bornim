# 348.13 · Tusche nach Licht, wie entschieden · Sokrates · 26.10., 11:2x (neu gefasst nach Rückfrage des Chefs 11:18)

**Frage:** Die Tusche soll nach deinem Entscheid (Archiv 348.6 Runde 6, 25.10.) auf der Lichtseite dünn oder weg, auf der Schattenseite kräftig sein. Gebaut ist sie fast gleichmäßig. Sollen Tom und Jerry das jetzt so bauen, wie entschieden, mit Vergleichsprobe vorher?

**Votum:** ja. Tom baut den gemeinsamen Shader um (Lichtseite nach Lichtrichtung dünn bis weg, Schattenseite kräftig), Jerry übernimmt ihn; Probe am Goblin r6 und am Helden, je alt/neu, du wählst am Bild. Mein früheres Votum „nein, bleibt wie gebaut“ ziehe ich zurück: es ging davon aus, dass gebaut ist, was entschieden war.

**Berührt:** alle Modelle; Dorf (Tom, `godot/shader/tusche.gdshader`) und Kampf (Jerry, `godot/kampf/tusche.gdshader`, gleicher Code).

## Begründung

Dein Eindruck stimmt, am Code nachgesehen. Die Linie ist im Licht 1,3 Bildpunkte, im Schatten höchstens 1,25fach, also 1,6: kaum zu sehen. Und „Licht“ heißt im Shader nur, wie hell der Bildpunkt selbst ist, nicht, ob die Kante zur Lampe oder Sonne zeigt. Unsere Figuren sind dunkel (Diogenes: Helligkeit 36–43 von 255); damit liegt fast jede Figurenkante unter der Schwelle und bekommt die volle, gleiche Breite.

## Sachverhalt

- Shader in beiden Zweigen gleich: Breite `px` 1,3 × `mix(dick 1,25; 1,0; hell)`, `hell = smoothstep(0,1; 0,6; Helligkeit des Bildpunkts)`; im Licht nur 15 % blasser.
- Entscheid 25.10., 10:16: „Lichtseite dünn oder weg, Schattenseite kräftig“ (Büsche, dann für alle Objekte, Archiv 348.6 Büsche).
- Prüfer Goblin r5, Späher r1, Diogenes Schamane r1: „dicke, treppige Linien“.

## Auswertung

Stärkstes Gegenargument: Lichtrichtung im Shader braucht die Flächenrichtung (Normale) je Bildpunkt; das kostet am Handy Leistung und ist eine Stilrunde in beiden Teams mitten im Umzug. Dagegen: es ist dein Entscheid, nicht neu; die Prüfer bemängeln genau die gleichmäßige dicke Linie; der Umbau ist ein Shader für beide, die Modelle bleiben.

## Folgerungen

Bei „ja“: Vorgang an Tom (Shader, Probe), danach Jerry übernimmt; bis zur Wahl bleibt die Linie, wie sie ist. Bei „nein“: nichts.
