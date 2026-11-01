# 458.2a · Stufe und Preis im Gegenstandskatalog: woher die ersten Zahlen?
Jerry · 01.11., 14:24 · G Balance

**Frage:** Im Gegenstandskatalog (458) sind Stufe und Preis bei allen 88 Gegenständen noch leer; das Spiel kann erst aus dem Katalog lesen, wenn sie stehen. Woher kommen die ersten Zahlen?
1. Die Zahlen der alten Fassung als Startwerte übernehmen (Preis wie heute im Laden, Stufe wie heute); Tränke, Wurfgeschosse, Rohstoffe und Nahrung ab Stufe 1. Geändert wird nach Messung in der Simulation 444, nicht nach Gefühl.
2. Neue Zahlen nach einer Formel für das Bornimer Rollenspielsystem (Preis je Art und Stufe), bevor die Wirtschaft gemessen ist.
3. Leer lassen, bis 444 Gold und Beute rechnet; das Spiel liest so lange weiter die alten Werte.

**Votum Jerry:** 1. Genauso sind die Monster zu ihren Werten 2.0 gekommen (aus den alten umgerechnet, damit die Reihenfolge bleibt; 427). Kapitel 1 bleibt spielbar wie heute, und jede spätere Änderung passiert an einer Stelle.
**Berührt:** `tools/gegenstaende/gegenstaende.json` (Jerry), Laden (Tom, 458.3), Simulation 444 (Jerry, 447.3).

## Sachverhalt (nachgesehen 01.11.)

- Im Nachschlagewerk (`DESIGN-SPIELSYSTEM-2-0-ENTWURF.md`) stehen keine Preise; da steht nur, dass ein guter Ruf die Preise senkt und dass Stufe und Güte bestimmen, ab wann man etwas tragen darf. Die Simulation 444 rechnet bisher kein Gold.
- Die alte Fassung kennt für die 46 Grundformen und die Verbrauchsgüter Preis und Stufe (im Katalog unter „alt“ mitgeführt): zum Beispiel Dolch 2 Gold, Stufe 1; Langschwert 15, Stufe 1; Brustpanzer 400, Stufe 4; Plattenpanzer 1500, Stufe 7 (also erst nach Kapitel 1); Heiltrank 25, großer Heiltrank 75, überragender 200.
- Schon eingetragen (ohne Balance): Beute je Monster wie im Bestiarium „Beute heute“, Abnutzung (Zustand) für Waffen, Schilde, Rüstung und Waffen-Einzelstücke; Tränke, Rohstoffe, Nahrung und Handlungsgegenstände nutzen sich nicht ab.

## Auswertung

- *Stärkstes Gegenargument gegen 1:* Die alten Preise passen zur Goldmenge des alten Systems. Kommt mit Spielsystem 2.0 mehr oder weniger Gold in die Tasche (Beute, Zerlegen, Herstellen, Reparatur kostet Gold), ist der Laden zu billig oder zu teuer. *Entkräftet:* Das gilt für 2 genauso, nur ohne Bezug. Mit 1 misst 444 in Stufe 3 Gold je Kampf gegen diese Preise, und die Zahlen ändern sich danach nur in der einen Datei.
- *Gegen 3:* Das Spiel hängt so lange am alten Export (`Gear.kt`), und der Katalog bleibt eine Liste, die keiner benutzt.
- **Offen bei allen drei:** Einzelstücke (Graks Kriegsaxt, Ogerhandschuhe, Grimmzahn-Amulett …) hatten nie einen Preis; Vorschlag: unverkäuflich lassen, Stufe wie das Gebiet, in dem man sie findet. Ob sich Schmuck, Zauberfokus und Fackel abnutzen, steht nicht im Nachschlagewerk; Vorschlag: Fokus ja, Schmuck und Fackel nein.

## Folgerungen

- Mit 1: ich trage Stufe und Preis ein, danach liest das Spiel die Gegenstände aus dem Katalog (eigener Build, Prüfliste mit Laden und Beute).
- Mit 2: Formelvorschlag als eigene Vorlage mit Tabelle, vor dem Eintragen.
- Mit 3: 458.2 wartet auf 444 Stufe 3.

**Zu sagen:** „1“, „2“ oder „3“; dazu, ob die Vorschläge zu Einzelstücken und Abnutzung so passen.
