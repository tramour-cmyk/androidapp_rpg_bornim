# 952 · Soll der kritische Treffer mit der Waffenfertigkeit wachsen, und wie schnell?
Jerry · 11.11., 17:27 · E Kampf · aus deinem Wort 13:53 bei der Erschaffung (Mensch): kritisch 7 % schon als Anfänger, „krass“
Kurz: Kritisch hängt heute nur an der Gewandtheit (7 Gewandtheit = 7 %); Vorschlag: Gewandtheit × Waffenfertigkeit / 50, zu Beginn rund 1 %.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/28add7301 (Simulation, Rechnung je 3 Fassungen gleich gesät)

**Frage:** Wie oft trifft der Held kritisch (anderthalbfacher Schaden)? Heute ist es die Gewandtheit in Prozent, schon beim ersten Kampf. Das Regelwerk sagt „kritische Treffer hängen an Gewandtheit und Fertigkeit“, das Spiel rechnet die Fertigkeit aber nicht mit.

**Votum:** „952 A“: kritisch = Gewandtheit × Waffenfertigkeit / 50 Prozent.

**Berührt:** Kampf (Jerry), Heldenseite „kritisch“ (`brs_held.gd`, Tom), Simulation; Spieltexte bleiben unverändert.

**Begründung:** Dein Wort 13:53: kritisch 7 % schon als Anfänger ist „krass“. Wer die Waffe kaum kann, soll selten glänzen; wer sie meistert, öfter.

**Sachverhalt:**
- Heute: kritisch = Gewandtheit in Prozent (`werte.json` „kritisch_prozent_je_gewandtheit“ 1; Kampf `mars.gd` Zeile 2087, Heldenseite `brs_held.gd` Zeile 233).
- Regelwerk Abschnitt „Zufall nur als Würze“: „kritische Treffer und Ausweichen hängen an Gewandtheit und Fertigkeit“.
- Start: Waffenfertigkeit 10, wenn die Herkunft die Waffe kann, sonst 0; Gewandtheit 3 bis 8. Mit Stufe 6 liegt die Waffenfertigkeit bei etwa 20, die Decke in Kapitel 1 bei 24.

| Gewandtheit 7, Waffenfertigkeit | 0 | 10 (Start) | 20 (Stufe 6) | 25 (Geselle) | 50 (Meister) | 100 |
|---|---|---|---|---|---|---|
| heute | 7 % | 7 % | 7 % | 7 % | 7 % | 7 % |
| A: Gewandtheit × Fertigkeit / 50 | 0 % | 1,4 % | 2,8 % | 3,5 % | 7 % | 14 % |
| B: Gewandtheit × Fertigkeit / 25 | 0 % | 2,8 % | 5,6 % | 7 % | 14 % | 28 % |

- Simulation, je Herkunft heute / A / B: die Zahl der Kämpfe bis Stufe 6 bleibt in allen drei Fassungen gleich (18 bis 25 je Herkunft). Die Siegquote gegen die Bosse auf ihrer Stufe sinkt mit A um 0 bis 5 Prozentpunkte, mit B um 0 bis 4 (zum Beispiel Herumtreiber gegen Krogg 20 / 16 / 18 %, Wanderer gegen Grimmzahn 60 / 56 / 56 %, Klosterschüler gegen Grimmzahn 71 / 66 / 67 %). Die Wahl ändert vor allem das Spielgefühl; die Bosse werden nur wenig schwerer.

**Auswertung:**
- **A (Empfehlung):** zu Beginn fast nie kritisch (Gewandtheit 7, Waffenfertigkeit 10: 1 von 70 Treffern; kann die Herkunft die Waffe nicht: nie), am Ende von Kapitel 1 etwa jeder 30., der heutige Wert erst als Meister; Großmeister 14 %. Kosten: eine Zahl in `werte.json`, Kampf und Heldenseite rechnen sie mit, Test; unter einer Sitzung.
- **B:** doppelt so schnell; der heutige Wert schon als Geselle, Großmeister 28 % (mehr als jeder vierte Treffer).
- **Stärkstes Gegenargument gegen A:** In Kapitel 1 sieht der Spieler kaum einen kritischen Treffer (höchstens rund 3 %), der Kampf verliert einen Höhepunkt. Antwort: der kritische Treffer bleibt sichtbar, wenn er kommt, und wird mit der Fertigkeit zum spürbaren Lohn fürs Üben („du wirst, was du tust“).

**Folgerungen:** Nach „952 A“ oder „952 B“ baut Jerry die Zahl ein (Kampf, Simulation), Tom die Heldenseite; Testbitte im nächsten gemeinsamen Build.

Antwort: …
