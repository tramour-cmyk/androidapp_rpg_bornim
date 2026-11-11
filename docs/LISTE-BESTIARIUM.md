# Bestiarium

Nachschlagen (427, Chef 31.10.2026, 21:3x): je Monsterart, was man für Spiel, Kampf und Texte braucht. **Aussehen** steht nur in [`LISTE-FIGUREN.md`](LISTE-FIGUREN.md) (dort Abnahmelisten und einmalige Monster), hier nur der Verweis. **Werte** folgen dem Rechenmodell von Spielsystem 2.0 (Modell D, Entscheidung 73–75), Startwerte im Abschnitt „Werte 2.0“. **Hintergrund** im Abschnitt unten (Homer, 428). Namen nach [`DESIGN-BRS.md`](DESIGN-BRS.md) Abschnitt 12.

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
| Riesenratte | Tier | Biss | – | Heiltrank, Fleisch | Fleisch, Fell klein | unten | Homer |
| Wolf | Tier, Rudel | Biss | Umreißen (wirft zu Boden) | Heiltrank, Fleisch, Wolfsfell | Fleisch, Wolfsfell, Zähne | unten | Homer |
| Wildschwein | Tier | Hauer | Ansturm | Heiltrank, Fleisch, Hauer | Fleisch, Schwarte, Hauer | unten | Homer |
| Riesen-Hundertfüßer | Kriechtier | Biss | Gift | Heiltrank | Giftdrüse, Panzerplatten | unten | Homer |
| Riesenspinne | Kriechtier | Biss | Gift | großer Heiltrank, Spinnendrüse, Schutzumhang | Giftdrüse, Spinnseide | unten | Homer |
| Riesenfledermaus | Tier | Biss | Ausweichen | Heiltrank, Fledermausflügel | Flügelhaut | unten | Homer |
| Blutflügler (vorher Stirge) | Kriechtier | Rüssel | Blutsaugen | Heiltrank | – | unten | Homer |
| Goblin | Goblinvolk | Krummsäbel | – | Heiltrank, Alchemistenfeuer | – (Goblins werden nicht zerlegt) | unten | Homer |
| Goblin-Späher | Goblinvolk | Kurzbogen | – | Heiltrank, Alchemistenfeuer | – | unten | Homer |
| Goblin-Schamane | Goblinvolk | Stab | Zauber | Heiltrank, großer Heiltrank | – | unten | Homer |
| Kobold | Goblinvolk | Speer | Rudel (stärker in der Gruppe) | Heiltrank, Alchemistenfeuer | – | unten | Homer |
| Skelett | Untote | Kurzschwert | – | Heiltrank, Weihwasser | Knochen | unten | Homer |
| Zombie | Untote | Hieb | Zäher Tod (steht einmal wieder auf) | Heiltrank, Weihwasser | – | unten | Homer |
| Ghul | Untote | Klauen | Lähmung | großer Heiltrank, Weihwasser | – | unten | Homer |
| Ockerschleim (vorher Ockergallerte) | Schleim | Scheinfuß | Säure (greift Ausrüstung an) | großer Heiltrank | Säure als Zutat | unten | Homer |

### Schwäche, Stärke, Gegenwirkung (870a 8 A, Chef 10.11., 15:25; Vorschlag Sokrates)

Schadensarten Schnitt, Stich, Wucht, Feuer, Gift, Säure, Licht (Weihwasser, Gleißstrahl); Alchemistenfeuer ist Feuer. Schwäche +50 %, Stärke −50 %, immun nur wie genannt; Regel `DESIGN-BRS.md` 7. Zahlen Jerry mit 444, Namen und Texte („Der Schleim teilt sich“) Homer; Einzelgegner Jerry mit 444.

| Name | Schwäche | Stärke | Gegenwirkung (falsches Mittel stärkt oder kostet) |
| --- | --- | --- | --- |
| Riesenratte | Feuer | – | – |
| Wolf | Feuer | – | Rudel flieht vor Feuer, sobald sein Leitwolf halb tot ist: Beute und Erfahrung der Wölfe weg (870c 3 A, 915) |
| Wildschwein | Stich | Schnitt (Schwarte) | Feuer macht es rasend: mehr Schaden, bis es fällt |
| Riesen-Hundertfüßer | Wucht (Panzer bricht) | Stich | – |
| Riesenspinne | Feuer | Gift | Feuer verbrennt die Spinnseide (Beute) |
| Riesenfledermaus | Stich | – | – |
| Blutflügler | Feuer | – | blutet der Held, saugt er stärker |
| Goblin, Goblin-Späher, Kobold | – | – | – |
| Goblin-Schamane | Stich | Feuer | – |
| Skelett | Wucht | Stich; immun Gift | – |
| Zombie | Feuer | immun Gift | mit Feuer oder Licht steht er nicht wieder auf (Zäher Tod) |
| Ghul | Licht | immun Gift | – |
| Ockerschleim | Feuer | immun Säure | teilt sich einmal bei Schnitt oder Wucht in zwei kleine |

## Einzelgegner (einmalig)

| Name | Gruppe | Angriff | Merkmal (Vorschlag) | Beute heute | Werte 2.0 | Aussehen |
| --- | --- | --- | --- | --- | --- | --- |
| Krogg der Grobian (Bärenschrat) | Goblinvolk | Morgenstern | Überfall | rostiger Schlüssel, Ogerhandschuhe | unten | `LISTE-FIGUREN.md` „Einmalige Monster“ |
| Grimmzahn, der Leitwolf | Tier | Reißzähne | Umreißen, führt das Rudel | Grimmzahn-Amulett, großer Heiltrank, Wolfsfell, Fleisch | unten | ebenda |
| Hauptmann Grak (Goblin-Hauptmann) | Goblinvolk | Kriegsaxt | Kampfgeschick (stärker neben Verbündeten) | Sonnenamulett, Brief des Propheten, Graks Schlüssel, Graks Kriegsaxt | unten | ebenda |

## Werte 2.0 (427)

**Gilt** (Chef 02.11., 18:54: „427 ja, Herkünfte auch, Grimmzahn und Krogg nachmessen“): Werte gemessen mit Simulation 444 (Messung im Vorgangsarchiv 427, Chefsache in Git). Krogg und Grimmzahn mit Überfall, Leibwache und Umreißen nachgemessen und bestätigt (427.1 A, Chef 02.11., 20:22): Kroggs Werte gelten mit Morwens Rauchbündel (D4.1); der Hinweis darauf kommt spätestens nach der ersten Niederlage gegen Krogg; Krogg wird erst abgenommen, wenn der Rauch im Spiel zu bekommen ist (Tiefer Flüsterwald). Geändert wird nach Messung, nicht nach Gefühl.

- **Stufe:** Kapitel 1 hat die Grenze 6. Flüsterwald 1–3, Tiefer Flüsterwald 1–5, Blutzahnhöhle 1–6 (schwache Arten kommen überall vor, die Stärkeren nur tiefer).
- **Herkunft der Zahlen:** Startwerte (Vorschlag Sokrates 01.11., aus den alten Werten umgerechnet, Rechenweg in Git vor 02.11., 18:5x), dann gewöhnliche Arten Leben × 2,0 / 1,8 / 1,4 / 1,1 / 0,9 (Stufe 1–5) und Schaden × 0,8 (Stufe 1–2) / 0,9 (3) / 0,85 (4–5); Zombie Leben 44, Riesenspinne Angriff 25; Bosse einzeln. **Abwehr** und **Wachsamkeit** wie die Startwerte; der Held schleicht in Kapitel 1 höchstens mit 49 (Geselle).
- **Erfahrung** = 10 × Stufe², Boss × 3, dann Faktor aus Modell D (Nachschlagewerk Abschnitt 4). Schwächen und Widerstände (Skelett gegen Stumpfes, Schleim gegen Klingen) bleiben als Merkmal, Zahl ±50 % Schaden.

| Art | Gebiet | Stufe | Leben | Rüstung | Schaden | Angriff | Abwehr | Wachsamkeit |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Riesenratte | Wald, Höhle | 1 | 20 | 1 | 3 | 10 | 5 | 10 |
| Kobold | Wald, Tiefer Wald | 1 | 24 | 1 | 3 | 10 | 5 | 0 |
| Blutflügler | Wald, Tiefer Wald | 1 | 18 | 2 | 3 | 15 | 9 | 0 |
| Wolf | Wald, Tiefer Wald | 2 | 25 | 1 | 6 | 15 | 12 | 30 |
| Wildschwein | Wald, Tiefer Wald | 2 | 29 | 0 | 3 | 10 | 8 | 10 |
| Riesen-Hundertfüßer | Wald, Tiefer Wald | 2 | 22 | 1 | 3 | 15 | 12 | 0 |
| Goblin | Wald, Tiefer Wald, Höhle | 2 | 18 | 2 | 5 | 15 | 16 | 10 |
| Goblin-Späher | Wald, Tiefer Wald, Höhle | 2 | 22 | 1 | 5 | 15 | 12 | 20 |
| Skelett | beide Wälder (Nacht), Höhle | 2 | 36 | 1 | 5 | 15 | 12 | 10 |
| Zombie | beide Wälder (Nacht), Höhle | 2 | 44 | 0 | 3 | 10 | 2 | 0 |
| Riesenfledermaus | beide Wälder (Nacht), Höhle | 3 | 46 | 1 | 5 | 20 | 17 | 40 |
| Goblin-Schamane | Tiefer Wald, Höhle | 3 | 29 | 1 | 4 | 15 | 15 | 50 |
| Riesenspinne | Tiefer Wald, Höhle | 4 | 43 | 2 | 7 | 25 | 24 | 40 |
| Ghul | Tiefer Wald (Nacht), Höhle | 4 | 37 | 1 | 6 | 25 | 20 | 40 |
| Ockerschleim | Höhle | 5 | 44 | 0 | 5 | 30 | 17 | 10 |
| Krogg (Boss) | Höhle | 4 | 55 | 2 | 7 | 20 | 28 | 60 |
| Grimmzahn (Boss) | Tiefer Wald | 5 | 55 | 2 | 7 | 22 | 29 | 80 |
| Grak (Boss) | Höhle | 6 | 75 | 2 | 7 | 25 | 38 | 90 |

Nachfolger nach der Monsterwahl (348.12c, 26.10.): Wiedergänger statt Zombie, Grabhund statt Ghul, Riesenegel statt Blutflügler, Säureschnecke statt Ockerschleim, je mit derselben Rolle und denselben Werten (die Säureschnecke ohne Klingenwiderstand, Archiv 348.12c Werte, 26.10., 21:33); Modelle gekauft (Chef 03.11., 15:40, 348.12c A), sie gelten ab jetzt.

*Gebiet* aus `Story.kt` gelesen (Begegnungen), Krogg und Grimmzahn aus der Handlung. Was die Simulation noch nicht rechnet (Rudel, Hinterhalt, Merkmale, Tränke), wird im Spiel mit dem Kampflog nachgemessen.

## Hintergrund (428)

Homer, 01.11.; **freigegeben** (Chef 01.11., 09:11, „428 ja, wie Sokrates“) für alle Arten im Spiel, wortgetreu übernehmen; Wiedergänger, Grabhund, Riesenegel, Säureschnecke bleiben Entwurf, bis ihr Kauf entschieden ist. Sokrates gleicht beim Füllen der Werte (427) ab und meldet Widersprüche an Homer. Je Art Herkunft und Wesen, ohne Plot zu verraten: Die Toten im Flüsterwald und Grimmzahns Augen bleiben ungeklärt (Roter Faden, offene Fäden). Marke `[428.…]`. Weil der Kauf noch aussteht (348.12c, „noch nicht“), stehen Zombie, Ghul, Blutflügler, Ockerschleim und ihre Nachfolger Wiedergänger, Grabhund, Riesenegel, Säureschnecke beide da; es gilt, was im Spiel ist.

**Tiere**

`[428.ratte]` **Riesenratte**
Sie kam mit den Kornsäcken der Händler und blieb, wo Abfall liegt: in Kellern, Gräben, im hohen Gras am Waldrand. Allein ist sie feige, zu dritt dreist.
EN: It came with the traders' grain sacks and stayed wherever refuse lies: in cellars, ditches, the tall grass at the forest's edge. Alone it is a coward, in threes it grows bold.

`[428.wolf]` **Wolf**
Die Wölfe des Flüsterwalds jagen im Rudel und folgen dem Stärksten. In harten Wintern kommen sie bis an die Felder von Bornim; Thessa zahlt gut für ihre Felle.
EN: The wolves of the Whisperwood hunt in packs and follow the strongest. In hard winters they come right up to Bornim's fields; Thessa pays well for their pelts.

`[428.keiler]` **Wildschwein**
Es wühlt im Unterholz nach Eicheln und Wurzeln und geht jedem aus dem Weg, der es in Ruhe lässt. Wer ihm zu nahe kommt, lernt, was ein Keiler mit seinen Hauern anrichtet.
EN: It roots through the undergrowth for acorns and roots and keeps out of the way of anyone who leaves it be. Whoever comes too close learns what a boar can do with its tusks.

`[428.hundertfuesser]` **Riesen-Hundertfüßer**
Er lebt unter Laub und morschem Holz und kommt heraus, wenn es regnet. Sein Gift lähmt eine Maus; einem Menschen brennt es tagelang im Blut.
EN: It lives under leaves and rotten wood and comes out when it rains. Its venom stuns a mouse; in a man it burns in the blood for days.

`[428.spinne]` **Riesenspinne**
Sie spannt ihre Netze zwischen den Stämmen des Tiefen Flüsterwalds, wo kaum Licht durchkommt, und wartet. Morwen kauft ihre Giftdrüsen, denn aus Gift macht sie Gegengift.
EN: It spins its webs between the trunks of the Deep Whisperwood, where hardly any light gets through, and waits. Morwen buys its venom glands, for out of poison she makes antidote.

`[428.fledermaus]` **Riesenfledermaus**
Bei Tag hängt sie zu Hunderten unter der Decke der Höhle, bei Nacht jagt sie über dem Wald. Sie sieht kaum etwas, aber sie hört jeden Schritt.
EN: By day they hang by the hundred from the cave's ceiling; by night they hunt above the forest. They can barely see, but they hear every step.

`[428.blutfluegler]` **Blutflügler**
Ein Ding aus Flügeln und Rüssel, nicht größer als eine Krähe. Es setzt sich lautlos auf die Haut und trinkt, bis es zu schwer ist, um wegzufliegen.
EN: A thing of wings and proboscis, no bigger than a crow. It settles on the skin without a sound and drinks until it is too heavy to fly away.

`[428.egel]` **Riesenegel** (Nachfolger des Blutflüglers)
Er lebt in Tümpeln und nassem Gras und wartet auf Wärme. Hat er sich festgesaugt, lässt er erst los, wenn er voll ist oder tot.
EN: It lives in pools and wet grass and waits for warmth. Once it has latched on, it lets go only when it is full, or dead.

**Goblinvolk**

`[428.goblin]` **Goblin**
Die Goblins des Blutzahn-Stamms hausen in der Höhle am Nordende des Flüsterwalds und leben von dem, was sie rauben. Allein laufen sie davon, in der Horde kennen sie keine Furcht; sie gehorchen dem, der am härtesten zuschlägt.
EN: The goblins of the Bloodfang tribe dwell in the cave at the northern end of the Whisperwood and live on what they steal. Alone they run; in a horde they know no fear. They obey whoever hits hardest.

`[428.spaeher]` **Goblin-Späher**
Die Späher liegen im hohen Gras und beobachten die Wege, lange bevor die Horde kommt. Sie schießen aus dem Verborgenen und sind fort, ehe man sie sieht.
EN: The scouts lie in the tall grass and watch the roads long before the horde arrives. They shoot from hiding and are gone before anyone sees them.

`[428.schamane]` **Goblin-Schamane**
Er spricht mit den Knochen an seinem Stab, und der Stamm fürchtet ihn mehr als den Hauptmann. Woher seine Flüche kommen, weiß er selbst nicht genau; er weiß nur, dass sie wirken.
EN: He speaks to the bones on his staff, and the tribe fears him more than its captain. Where his curses come from he does not quite know himself; only that they work.

`[428.kobold]` **Kobold**
Kleine Echsen mit dem Kopf eines Drachen, die in Höhlen nisten und Gänge graben. Allein sind sie feige, im Rudel beißen sie zu; die Goblins dulden sie, weil sie die Drecksarbeit machen.
EN: Small lizards with a dragon's head that nest in caves and dig tunnels. Alone they are cowards, in a pack they bite; the goblins put up with them because they do the dirty work.

**Untote**

`[428.untote]` (vor dem ersten Eintrag der Gruppe)
Warum die Toten im Flüsterwald nicht ruhen, weiß in Bornim niemand. Lyra betet dagegen an, Borin rät zum Hammer.
EN: Why the dead of the Whisperwood will not rest, no one in Bornim knows. Lyra prays against it; Borin recommends a hammer.

`[428.skelett]` **Skelett**
Knochen von Toten, die keine Ruhe fanden. Bei Nacht stehen sie auf und tragen das rostige Eisen, mit dem man sie begraben hat.
EN: The bones of the dead who found no rest. At night they rise, bearing the rusted iron they were buried with.

`[428.zombie]` **Zombie**
Ein Toter, an dem noch Fleisch hängt, langsam und ohne Schmerz. Man muss ihn zweimal fällen, denn das erste Mal glaubt er es nicht.
EN: A corpse with flesh still on its bones, slow and beyond pain. You have to fell it twice, for the first time it does not believe it.

`[428.wiedergaenger]` **Wiedergänger** (Nachfolger des Zombies)
Was einmal ein Mensch war, kriecht aus der Erde und sucht den Weg zurück zu den Lebenden. Man riecht ihn lange, bevor man ihn sieht, und Weihwasser fürchtet er mehr als jede Klinge.
EN: What was once a man crawls out of the earth and seeks its way back to the living. You smell it long before you see it, and it fears holy water more than any blade.

`[428.ghul]` **Ghul**
Er frisst, was andere begraben haben, und seine Klauen lähmen. Wer gelähmt am Boden liegt, ist für ihn schon tot.
EN: It eats what others have buried, and its claws paralyse. Whoever lies paralysed on the ground is already dead to it.

`[428.grabhund]` **Grabhund** (Nachfolger des Ghuls)
Er streicht nachts zwischen alten Gräbern umher und gibt keinen Laut. Die Alten in Bornim sagen, er wache über die Toten, nicht über die Lebenden.
EN: It prowls among old graves at night and makes no sound. The old folk of Bornim say it watches over the dead, not the living.

**Schleim**

`[428.ockerschleim]` **Ockerschleim**
Er kriecht durch die feuchten Gänge der Höhle und frisst, was liegen bleibt, Knochen und Leder eingeschlossen. Wer ihn mit dem Schwert schlägt, sollte danach seine Klinge ansehen.
EN: It creeps through the damp passages of the cave and eats whatever is left lying, bones and leather included. Whoever strikes it with a sword had better look at the blade afterwards.

`[428.saeureschnecke]` **Säureschnecke** (Nachfolger des Ockerschleims)
Lang wie ein Pferd und so langsam, dass man sie für Fels hält, bis sie sich bewegt. Ihre Spur frisst sich in den Stein; was sie umschließt, kommt nicht wieder heraus.
EN: As long as a horse and so slow that you take it for rock until it moves. Its trail eats into the stone; whatever it engulfs does not come out again.

**Einzelgegner**

`[428.krogg]` **Krogg der Grobian**
Ein Bärenschrat, größer als jeder Goblin und trotz seiner Masse fast lautlos. Grak hat ihm den Schlüssel zu seiner Halle gegeben, denn an Krogg kommt keiner vorbei.
EN: Krogg is bigger than any goblin and, for all his bulk, almost silent. Grak gave him the key to his hall, for no one gets past Krogg.

`[428.grimmzahn]` **Grimmzahn, der Leitwolf**
Er führt die Wölfe des Tiefen Flüsterwalds, groß wie ein Pony und älter als jeder Wolf, an den sich Morwen erinnert. Seine Augen glühen rot, und niemand weiß, warum.
EN: He leads the wolves of the Deep Whisperwood, as big as a pony and older than any wolf Morwen remembers. His eyes glow red, and no one knows why.

`[428.grak]` **Hauptmann Grak**
Ein Hobgoblin, der den feigen Blutzahn-Stamm mit der Axt geeint hat; wer ihm widersprach, liegt in seiner Halle. Seit er führt, rauben die Goblins nicht mehr nur, was sie brauchen.
EN: A hobgoblin who united the cowardly Bloodfang tribe with his axe; whoever spoke against him lies in his hall. Since he took command, the goblins no longer steal only what they need.

## Später

- Kaufmodelle mit eigener Art: Keiler (Wildschwein), Riesenratte gekauft, Kaufwolf (348.12f, 387) gehören zu den Arten oben; nur das Modell wechselt.
- Wiedergänger, Grabhund, Riesenegel, Säureschnecke ersetzen in Kapitel 1 Zombie, Ghul, Blutflügler, Ockerschleim; gekauft 03.11. (348.12c; Abschnitt „Werte 2.0“).
- Im Spiel denkbar: ein Bestiarium in der Chronik, das sich füllt, wenn der Held einem Monster begegnet (passt zu S3, Vorschlag).
