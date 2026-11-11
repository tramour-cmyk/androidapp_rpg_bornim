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

**Stellungnahme Sokrates (11.11., 18:24, zu deinem Wort 18:21: „Ich glaube, es greift zu kurz, kritischen Schaden nur anhand der Gewandtheit zu berechnen … für Zauberer … hängt es wohl nicht daran, wie selbstsicher er den Zauberstab wedeln kann, sondern vielleicht eher an anderen Grundwerten“):**

- **Befund im Code:** Zauber treffen heute **nie** kritisch (`mars.gd` `_brs_zauber` gibt keinen Wert an `schlag`, Vorgabe 0 %); Bogen, Armbrust und Wurfwaffe hängen an der Gewandtheit wie das Schwert. Das Regelwerk sagt zu Zaubern nichts.
- **Kommt das wieder?** Ja: bei jeder neuen Waffengruppe und Schule stellt sich die Frage neu. Darum eine Regel statt einer Ausnahme für Zauberer.
- **Vorschlag C:** Tempo wie A (Grundwert × Fertigkeit / 50), aber der Grundwert hängt an der Angriffsart, und es ist **nie der Grundwert, der schon den Schaden gibt**:

| Angriff | Schaden aus | kritisch aus | Bild |
|---|---|---|---|
| Schwert, Axt, Keule, Stangenwaffe, Zweihänder, Faust | Kraft | Gewandtheit | die Lücke in der Deckung treffen |
| Dolch, Wurfwaffe | Gewandtheit | Wahrnehmung | die Schwachstelle sehen |
| Bogen, Armbrust | Gewandtheit, keiner | Wahrnehmung | genau zielen |
| Schadenszauber (Evokation u. a.) | Wille | Verstand | das Gefüge des Zaubers verstehen, die Lücke im Schutz des Gegners finden |
| Heil- und Schutzmagie | – | kein kritischer Treffer (wie heute) | – |

- **Warum:** Jeder Kampfstil braucht so zwei Grundwerte (Krieger Kraft und Gewandtheit, Schütze Gewandtheit und Wahrnehmung, Magier Wille und Verstand). Die Verteilung der 9 Punkte bei der Erschaffung wird eine echte Wahl (Leitbild), und der Verstand bekommt für Magier einen Platz im Kampf; heute nützt er ihnen dort nichts.
- **Stärkstes Gegenargument:** Magie schöpft im BRS aus dem Willen (Entscheidung 80); „Zauberer = Wille“ wäre einfacher und passt zur Welt. Antwort: Dann gibt der Wille Mana, Zauberschaden, kritisch, Konzentration und Furchtresistenz; der Magier legt alles auf einen Wert, die Erschaffung verliert die Wahl.
- **Zweites Gegenargument:** Die Wahrnehmung wird für Schützen stark (Treffer im Fernkampf und kritisch). Antwort: Den Schaden gibt bei ihnen die Gewandtheit; es bleiben zwei Werte wie beim Krieger. Die Zahlen prüft Jerry mit der Simulation 444.
- **Unsicher:** Magier treffen mit C erstmals kritisch, zu Beginn etwa 0,6 bis 1,6 % (Verstand 3 bis 8, Schule 10). In Kapitel 1 ist das wenig, Rechnung Jerry nach deiner Antwort.
- **Kosten:** in `werte.json` je Waffengruppe und Schule ein Feld „kritisch aus“ neben „grundwert“, Kampf, Heldenseite (kritisch je Waffe und Zauber), Simulation; unter einer Sitzung Jerry, Heldenseite Tom.

**Nachtrag Sokrates (11.11., 20:02, zu deiner Frage 20:00: „der Zauberkundige nicht nur auf den Willen basiert … sondern auch der Verstand als Grundwert da ganz entscheidend ist“):** C gibt dem Verstand nur den kritischen Treffer der Zauber (zu Beginn etwa 1 %), entscheidend ist das nicht. Darum Variante **D**, aus Entscheidung 80 abgeleitet (Umgebungsmagie schöpft die Teilchen aus der Umgebung, Heil- und Schutzmagie aus dem eigenen Willen):

| Schule | Wirkung (Schaden, Heilung) aus | kritisch aus | Mana aus |
|---|---|---|---|
| Evokation, Illusion, Beschwörung | **Verstand** (die Teilchen der Umgebung verstehen und formen) | Wille | Wille |
| Heil- und Schutzmagie | Wille (aus dem eigenen Willen) | kein kritischer Treffer | Wille |

- **Folge:** Der Magier braucht Verstand für seinen Schaden und Wille für Mana, Furcht und Zauberabwehr; der Heiler lebt vom Willen, der Verstand hilft ihm bei Alchemie und Schwächen. Magier und Heiler werden bei der Erschaffung verschiedene Helden, nicht derselbe mit anderem Zauber. Waffen bleiben wie C.
- **Stärkstes Gegenargument:** Ein Held, der beides zaubert (Kriegsmagier, Paladin), braucht beide Werte und dazu Zähigkeit; das ist härter. Antwort: Das ist dieselbe Lage wie beim Krieger (Kraft, Gewandtheit, Zähigkeit) und genau die Wahl, die das Leitbild will. Jerry rechnet je Herkunft nach, ob ein Mischzauberer in Kapitel 1 gegen die Bosse nicht zurückfällt.
- **Kosten:** in `werte.json` je Schule „grundwert“ und „kritisch aus“, `DESIGN-BRS.md` Abschnitt 2 (Tabelle der Grundwerte) und Zeile „Zauber“ in Abschnitt 6, Simulation 444; etwa eine Sitzung Jerry, Heldenseite Tom.

**Empfehlung Sokrates: „952 D“** (A gilt für das Tempo; D ersetzt C nur bei den Zaubern).

Antwort: …
