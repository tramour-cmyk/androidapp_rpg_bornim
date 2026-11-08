# 653 · Halt für Waffen und Schilde einmal je Modell festlegen · Sokrates · 08.11., 14:3x

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/claude/tom-499-drehteller/godot/kampf/figur.gd

**Anlass (Chef 14:35, zu 499):** „haben wir das wieder getestet bei den zwei [Figuren]? Stundenlang. Was ist denn jetzt, wenn ein Halbling ein Schild ausrüstet? Oder ein anderes Schild … jedes Mal das gleiche … Oder kann man das nicht irgendwie modellmäßig festlegen, wie ein Schild zu sitzen hat? … welche Waffen welcher Charakter verwendet … anhand der Modelle, wo der Anhaltepunkt ist … für alle möglichen Varianten.“

**Befund:** Heute wird Gehaltenes an sechs Stellen im Code getrennt angehängt (`figur.gd`, `held.gd`, `heldfigur.gd` zweimal, `leute.gd`, `figurenprobe.gd`, `voelkerprobe.gd`), jede mit eigenen Zahlen. Die Lage des Schilds steht als Handwerte je Schildnetz im Code (`figur.gd` `SCHILD_LAGE`, auf Zweig 499), gemessen an zwei Figuren. Ein neuer Schild, eine neue Waffe oder ein anderes Volk heißt: wieder messen, wieder Probe.

**Frage:** Halt einmal je Modell festlegen statt je Figur?
1. **Griffpunkt je Gegenstand:** jedes Waffen- und Schildmodell bekommt einmal seinen Haltepunkt und seine Richtung (wo die Hand greift, wo vorn ist), im Gegenstandskatalog (644) als Feld, aus dem Modell abgelesen.
2. **Halterung je Körper:** jeder Körpertyp (je Volk und Körperbau; im Figurenkatalog 649) hat feste Halterungen: rechte Hand, linke Hand, Unterarm für den Schild, Rücken, Hüfte; einmal je Körpertyp gemessen, Größe des Volks gilt mit.
3. **Eine Anlegefunktion** für Held, Leute, Kampf und Proben statt sechs; Lage = Halterung des Körpers + Griffpunkt des Gegenstands, keine Zahlen je Paar.
4. **Prüfbild aller Kombinationen** vom Werkzeug (jeder Körpertyp × jede Waffe und jeder Schild, Stehen und Kampfhaltung), geprüft vom Helfer nach festen Maßen (Hand am Griff, Schild vor dem Unterarm, nichts im Körper); an dich nur Stichproben und Auffälliges.

**Votum Sokrates: ja.**

## Auswertung
- **Stärkstes Gegenargument:** die Kaufmodelle stammen aus verschiedenen Paketen mit verschiedenen Skeletten und Proportionen; ein allgemeiner Griffpunkt passt nicht überall von selbst, manche Paare brauchen doch eine Korrektur. **Antwort:** Korrektur dann je Körpertyp oder je Gegenstand, nie je Paar; das Prüfbild zeigt, wo eine nötig ist. Aus „jede Kombination messen“ wird „jedes Modell einmal“.
- Gegenargument: Umbau über beide Teams (Tom: Held, Leute; Jerry: Kampf). **Antwort:** deshalb deine Entscheidung; Tom führt (Technik der Figuren), Jerry stellt den Kampf um; gehört zu 644 und 649 (Felder dort), wird mit deren Werkzeugen gebaut.
- 499 bleibt, wie du es abgenommen hast (14:19); die Werte aus 499 werden die ersten Halterungen.

## Folgerungen
„653 ja“: Vorgang an Tom (Griffpunkte, Halterungen, eine Anlegefunktion, Prüfbild), Jerry stellt den Kampf darauf um; Felder in 644 und 649 kommen dazu.
