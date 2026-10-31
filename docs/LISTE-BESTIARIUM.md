# Bestiarium

Nachschlagen (427, Chef 31.10.2026, 21:3x): je Monsterart, was man für Spiel, Kampf und Texte braucht. **Aussehen** steht nur in [`LISTE-FIGUREN.md`](LISTE-FIGUREN.md) (dort Abnahmelisten und einmalige Monster), hier nur der Verweis. **Werte** folgen dem Rechenmodell von Spielsystem 2.0 (Entwurf S1 in Vorgang 422) und werden eingetragen, sobald es entschieden ist. **Hintergrund** schreibt Homer (428). Namen nach dem Glossar in [`DESIGN-SPIELSYSTEM-2-0.md`](DESIGN-SPIELSYSTEM-2-0.md).

Stand der Spalten „Angriff“, „Beute“ und „Merkmal“: aus `core/src/main/kotlin/de/bornim/core/Monsters.kt` gelesen am 31.10.2026 (alte Fassung). Merkmalsnamen sind Vorschlag Sokrates, ohne SRD-Begriffe.

## Felder je Monsterart

| Feld | Inhalt | Wer |
| --- | --- | --- |
| Name | deutscher und englischer Name nach Glossar | Homer |
| Gruppe | Tier, Goblinvolk, Untote, Kriechtier, Schleim … | Sokrates |
| Gebiet und Stufenband | wo es vorkommt, Stufe von–bis | Sokrates mit Perikles (Kapitelgrenzen) |
| Hintergrund | zwei bis drei Sätze Herkunft und Wesen | Homer (428) |
| Verhalten | allein, Rudel, lauert, flieht, Tag oder Nacht | Sokrates |
| Angriffe und Waffen | was es benutzt | Sokrates, Bild bei Jerry |
| Merkmal im Kampf | eine Besonderheit, die man spürt | Sokrates |
| Werte 2.0 | nach Rechenmodell (Stufe, Leben, Rüstung, Angriff, Abwehr, Wachsamkeit gegen Schleichen, Schaden) | nach S1 |
| Beute und Zerlegen | was es fallen lässt; was Jagd beim Zerlegen bringt | Sokrates |
| Aussehen | Verweis auf `LISTE-FIGUREN.md` | – |

## Monsterarten (Kapitel 1)

| Name | Gruppe | Angriff | Merkmal (Vorschlag) | Beute heute | Zerlegen (Vorschlag) | Werte 2.0 | Hintergrund |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Riesenratte | Tier | Biss | – | Heiltrank, Fleisch | Fleisch, Fell klein | nach S1 | Homer |
| Wolf | Tier, Rudel | Biss | Umreißen (wirft zu Boden) | Heiltrank, Fleisch, Wolfsfell | Fleisch, Wolfsfell, Zähne | nach S1 | Homer |
| Wildschwein | Tier | Hauer | Ansturm | Heiltrank, Fleisch, Hauer | Fleisch, Schwarte, Hauer | nach S1 | Homer |
| Riesen-Hundertfüßer | Kriechtier | Biss | Gift | Heiltrank | Giftdrüse, Panzerplatten | nach S1 | Homer |
| Riesenspinne | Kriechtier | Biss | Gift | großer Heiltrank, Spinnendrüse, Schutzumhang | Giftdrüse, Spinnseide | nach S1 | Homer |
| Riesenfledermaus | Tier | Biss | Ausweichen | Heiltrank, Fledermausflügel | Flügelhaut | nach S1 | Homer |
| Blutflügler (vorher Stirge) | Kriechtier | Rüssel | Blutsaugen | Heiltrank | – | nach S1 | Homer |
| Goblin | Goblinvolk | Krummsäbel | – | Heiltrank, Alchemistenfeuer | – (Goblins werden nicht zerlegt) | nach S1 | Homer |
| Goblin-Späher | Goblinvolk | Kurzbogen | – | Heiltrank, Alchemistenfeuer | – | nach S1 | Homer |
| Goblin-Schamane | Goblinvolk | Stab | Zauber | Heiltrank, großer Heiltrank | – | nach S1 | Homer |
| Kobold | Goblinvolk | Speer | Rudel (stärker in der Gruppe) | Heiltrank, Alchemistenfeuer | – | nach S1 | Homer |
| Skelett | Untote | Kurzschwert | – | Heiltrank, Weihwasser | Knochen | nach S1 | Homer |
| Zombie | Untote | Hieb | Zäher Tod (steht einmal wieder auf) | Heiltrank, Weihwasser | – | nach S1 | Homer |
| Ghul | Untote | Klauen | Lähmung | großer Heiltrank, Weihwasser | – | nach S1 | Homer |
| Ockerschleim (vorher Ockergallerte) | Schleim | Scheinfuß | Säure (greift Ausrüstung an) | großer Heiltrank | Säure als Zutat | nach S1 | Homer |

## Einzelgegner (einmalig)

| Name | Gruppe | Angriff | Merkmal (Vorschlag) | Beute heute | Werte 2.0 | Aussehen |
| --- | --- | --- | --- | --- | --- | --- |
| Krogg der Grobian (Bärenschrat) | Goblinvolk | Morgenstern | Überfall | rostiger Schlüssel, Ogerhandschuhe | nach S1 | `LISTE-FIGUREN.md` „Einmalige Monster“ |
| Grimmzahn, der Leitwolf | Tier | Reißzähne | Umreißen, führt das Rudel | Grimmzahn-Amulett, großer Heiltrank, Wolfsfell, Fleisch | nach S1 | ebenda |
| Hauptmann Grak (Goblin-Hauptmann) | Goblinvolk | Kriegsaxt | Kampfgeschick (stärker neben Verbündeten) | Sonnenamulett, Brief des Propheten, Graks Schlüssel, Graks Kriegsaxt | nach S1 | ebenda |

## Später

- Kaufmodelle mit eigener Art: Keiler (Wildschwein), Riesenratte gekauft, Kaufwolf (348.12f, 387) gehören zu den Arten oben; nur das Modell wechselt.
- Kapitel 2: Arten aus `STORY-PLAN-K2.md` (Wiedergänger, Grabhund, Riesenegel, Säureschnecke; 348.12c) kommen mit dem Bau von Kapitel 2.
- Im Spiel denkbar: ein Bestiarium in der Chronik, das sich füllt, wenn der Held einem Monster begegnet (passt zu S3, Vorschlag).
