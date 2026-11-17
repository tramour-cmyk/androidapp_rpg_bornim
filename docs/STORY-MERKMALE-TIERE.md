# Merkmale je Exemplar: Tiere (1489)

Homer, 16.11.; Auftrag 1411b A (Chef 16.11., 20:59: „1411b A, aber bitte Elixier in diesem Fall vier Beschreibungen.“, 21:37: „das Wort Elixier ist nicht bestätigt, sondern es hieß lieber 4 oder mehr Vorschläge von Homer.“; 18:41: „ich will nicht 50 Mal alter Wolf lesen oder klappriges Skelett“). Regel und Werte: `DESIGN-BRS.md` „Merkmale je Exemplar“; Bau Jerry 1488. Waffenträger (Untote, Goblinvolk): `STORY-MERKMALE-WAFFEN.md`. Fremd geprüft 16.11., 21:12.

## Regeln für den Bau (gelten für beide Dateien)

- **Anzeige nach Lesestufe:** 0 nichts; 1 nur der Pfeil (kein Text); 2 Name und eine Beschreibung; 3 dazu die Wirkung. Gewöhnliche Exemplare zeigen nichts.
- **Name hinter der Art, mit Komma:** „Wolf, alt“ / „Wolf, old“, „Skelett, rostige Waffe“ / „Skeleton, rusty weapon“. So nie „alter Wolf“, „altes Wildschwein“, und keine Beugung im Code.
- **Beschreibung:** je Art und Merkmal vier, zufällig gezogen, nie dieselbe zweimal hintereinander (gemerkt je Art und Merkmal über die Kämpfe, nicht nur im Kampf). Zwei Exemplare mit demselben Merkmal im selben Kampf bekommen verschiedene.
- **Wirkung** (Lesestufe 3): eine Zeile je Merkmal, ohne Zahlen, `[1489.wirkung.…]`.
- **Ohne Merkmal:** Bosse (Krogg, Grimmzahn, Grak), Säureschnecke und der **Jungwolf** (er ist schon jung; „Jungwolf, alt“ widerspricht sich).
- **Riesenratte, Riesenfledermaus:** nach `DESIGN-BRS.md` nur Lebensmerkmale; welche der vier das sind, legt der Bau fest (Jerry, 1488). Texte stehen für alle vier, es gelten die, die der Bau zieht.
- Marken: `[1489.<art>.<merkmal>.<1–4>]`; Arten `ratte`, `wolf`, `keiler`, `hundertfuesser`, `spinne`, `fledermaus`, `egel`; Merkmale `jung`, `alt`, `kraeftig`, `angeschlagen`.

## Namen (Lesestufe 2)

`[1489.name.tier]` alle Tiere: jung / young · alt / old · kräftig / strong · angeschlagen / wounded. **Ausnahme Wolf:** „jung“ heißt dort unerfahren / green, damit „Wolf, jung“ nicht neben dem Jungwolf steht.

## Wirkung (Lesestufe 3)

- `[1489.wirkung.jung]` Weniger Leben, trifft schlechter, wehrt besser ab. / EN: Less Life, hits less often, defends better.
- `[1489.wirkung.alt]` Weniger Leben, trifft schlechter. / EN: Less Life, hits less often.
- `[1489.wirkung.kraeftig]` Mehr Leben, schlägt härter. / EN: More Life, hits harder.
- `[1489.wirkung.angeschlagen]` Viel weniger Leben. / EN: Much less Life.

## Riesenratte

- `[1489.ratte.jung.1]` Kaum größer als eine Katze, das Fell noch weich. / EN: Barely bigger than a cat, its fur still soft.
- `[1489.ratte.jung.2]` Flinke Sprünge, aber ungeschickte Bisse. / EN: Quick hops, but clumsy bites.
- `[1489.ratte.jung.3]` Rosa Ohren, ein dünner, nackter Schwanz. / EN: Pink ears, a thin, bare tail.
- `[1489.ratte.jung.4]` Quiekt mehr, als sie beißt. / EN: Squeals more than it bites.
- `[1489.ratte.alt.1]` Graues Fell, ein Ohr zerfetzt. / EN: Gray fur, one ear in tatters.
- `[1489.ratte.alt.2]` Die Zähne gelb und abgeschliffen. / EN: Teeth yellow and worn down.
- `[1489.ratte.alt.3]` Langsam und vorsichtig, nach vielen Wintern. / EN: Slow and wary, after many winters.
- `[1489.ratte.alt.4]` Narben über der ganzen Schnauze, die Augen trüb. / EN: Scars all over the snout, eyes clouded.
- `[1489.ratte.kraeftig.1]` Fett vom Korn der Händler, breit wie ein Brotlaib. / EN: Fat on the traders' grain, broad as a loaf.
- `[1489.ratte.kraeftig.2]` Ein dicker Nacken und Zähne wie Meißel. / EN: A thick neck and teeth like chisels.
- `[1489.ratte.kraeftig.3]` Schwer wie ein Hund und ebenso breit. / EN: As heavy as a dog, and as broad.
- `[1489.ratte.kraeftig.4]` Glänzendes Fell, pralle Flanken. / EN: Glossy fur, bulging flanks.
- `[1489.ratte.angeschlagen.1]` Ein Hinterlauf zieht nach, wohl aus einer Falle. / EN: One hind leg drags, likely from a trap.
- `[1489.ratte.angeschlagen.2]` Blut verklebt das Fell an der Flanke. / EN: Blood mats the fur on its flank.
- `[1489.ratte.angeschlagen.3]` Der Schwanz nur noch ein Stummel, die Wunde frisch. / EN: The tail just a stump, the wound fresh.
- `[1489.ratte.angeschlagen.4]` Hechelt schon, bevor es losgeht. / EN: Panting before anything has started.

## Wolf

- `[1489.wolf.jung.1]` Lange Beine, große Pfoten, noch nicht hineingewachsen. / EN: Long legs, big paws it has yet to grow into.
- `[1489.wolf.jung.2]` Springt hin und her und kann nicht stillhalten. / EN: Darts back and forth, unable to keep still.
- `[1489.wolf.jung.3]` Das Fell noch flaumig wie bei einem Welpen. / EN: Its coat still downy, like a pup's.
- `[1489.wolf.jung.4]` Schielt nach den Älteren, bevor er etwas wagt. / EN: Glances at the older ones before it dares anything.
- `[1489.wolf.alt.1]` Die Schnauze weiß, die Lefzen hängen. / EN: Muzzle white, lips sagging.
- `[1489.wolf.alt.2]` Ein Reißzahn fehlt, der andere ist gesplittert. / EN: One fang missing, the other split.
- `[1489.wolf.alt.3]` Steife Hüften; jeder Schritt kostet ihn etwas. / EN: Stiff hips; every step costs it something.
- `[1489.wolf.alt.4]` Das Fell schütter, darunter die Rippen. / EN: The coat thin, the ribs showing beneath.
- `[1489.wolf.kraeftig.1]` Breite Brust, ein Nacken wie ein Stier. / EN: Broad chest, a neck like a bull's.
- `[1489.wolf.kraeftig.2]` Größer als die anderen, und er weiß es. / EN: Bigger than the others, and it knows it.
- `[1489.wolf.kraeftig.3]` Narben am Hals vom Kampf um den Rang. / EN: Scars on its throat from fights for rank.
- `[1489.wolf.kraeftig.4]` Das Knurren kommt tief aus der Brust. / EN: The growl comes from deep in its chest.
- `[1489.wolf.angeschlagen.1]` Eine Vorderpfote setzt er kaum auf. / EN: It barely puts weight on one forepaw.
- `[1489.wolf.angeschlagen.2]` Ein Riss im Ohr, frisches Blut am Hals. / EN: A torn ear, fresh blood on its neck.
- `[1489.wolf.angeschlagen.3]` Ein abgebrochener Pfeil steckt in seiner Schulter. / EN: A broken arrow shaft juts from its shoulder.
- `[1489.wolf.angeschlagen.4]` Läuft ein wenig schief und hält Abstand. / EN: Runs a little crooked and keeps its distance.

## Wildschwein

- `[1489.keiler.jung.1]` Noch Streifen im Fell, die Hauer kurz. / EN: Its coat still striped, its tusks short.
- `[1489.keiler.jung.2]` Mehr Neugier als Zorn in den Augen. / EN: More curiosity than rage in its eyes.
- `[1489.keiler.jung.3]` Leicht genug, dass ein Tritt es zurückwirft. / EN: Light enough that a kick throws it back.
- `[1489.keiler.jung.4]` Grunzt hell und scharrt unsicher. / EN: Grunts shrilly and paws the ground uncertainly.
- `[1489.keiler.alt.1]` Die Borsten grau, die Hauer stumpf gewetzt. / EN: Bristles gray, tusks worn blunt.
- `[1489.keiler.alt.2]` Ein Auge milchig; zum Sehen dreht es den Kopf. / EN: One eye milky; it turns its head to see.
- `[1489.keiler.alt.3]` Schnauft schwer nach den ersten Schritten. / EN: Wheezes after the first few steps.
- `[1489.keiler.alt.4]` Die Schwarte voller alter Narben. / EN: Its hide covered in old scars.
- `[1489.keiler.kraeftig.1]` Ein Keiler wie ein Fass, die Hauer handlang. / EN: A boar like a barrel, tusks a hand long.
- `[1489.keiler.kraeftig.2]` Der Boden bebt, wenn es scharrt. / EN: The ground shakes when it paws.
- `[1489.keiler.kraeftig.3]` Schwer wie zwei Männer, und alles davon Wut. / EN: As heavy as two men, and all of it rage.
- `[1489.keiler.kraeftig.4]` Massiger Nacken, kleine wütende Augen. / EN: Massive neck, small furious eyes.
- `[1489.keiler.angeschlagen.1]` Ein Riss quer über der Schulter, die Wunde blutet. / EN: A gash across its shoulder, the wound bleeding.
- `[1489.keiler.angeschlagen.2]` Hinkt; ein Lauf ist steif. / EN: Limping; one leg is stiff.
- `[1489.keiler.angeschlagen.3]` Blut an der Flanke, wohl von einem Jagdspieß. / EN: Blood on its flank, likely from a hunting spear.
- `[1489.keiler.angeschlagen.4]` Atmet rasselnd, die Seite hebt sich schwer. / EN: Its breath rattles; its side heaves.

## Riesen-Hundertfüßer

- `[1489.hundertfuesser.jung.1]` Der Panzer noch hell und weich. / EN: Its shell still pale and soft.
- `[1489.hundertfuesser.jung.2]` Kaum armlang, die Beine flink und dünn. / EN: Barely an arm long, legs quick and thin.
- `[1489.hundertfuesser.jung.3]` Die Kieferzangen noch klein. / EN: Its pincers still small.
- `[1489.hundertfuesser.jung.4]` Hält nicht still, huscht vor und zurück. / EN: Never still, scurrying back and forth.
- `[1489.hundertfuesser.alt.1]` Die Farbe ausgeblichen wie altes Laub. / EN: Its color faded like old leaves.
- `[1489.hundertfuesser.alt.2]` Der Panzer stumpf und voller Kerben. / EN: Its shell dull and full of nicks.
- `[1489.hundertfuesser.alt.3]` Bewegt sich träge, wie steif vor Kälte. / EN: Sluggish, as if numb with cold.
- `[1489.hundertfuesser.alt.4]` Die Fühler abgewetzt, er tastet sich voran. / EN: Feelers worn short; it gropes its way forward.
- `[1489.hundertfuesser.kraeftig.1]` Lang wie ein Mann, dick wie ein Arm. / EN: As long as a man, as thick as an arm.
- `[1489.hundertfuesser.kraeftig.2]` Ein schwerer Leib, der das Laub niederdrückt. / EN: A heavy body that presses the leaves flat.
- `[1489.hundertfuesser.kraeftig.3]` Die Zangen triefen vor Gift. / EN: Its pincers drip with venom.
- `[1489.hundertfuesser.kraeftig.4]` Hebt den Vorderleib hoch über das Laub. / EN: Rears its front high above the leaves.
- `[1489.hundertfuesser.angeschlagen.1]` Eine Platte des Panzers ist eingedrückt. / EN: One plate of its shell is caved in.
- `[1489.hundertfuesser.angeschlagen.2]` Gelber Saft quillt aus einem Riss. / EN: Yellow ichor oozes from a crack.
- `[1489.hundertfuesser.angeschlagen.3]` Das hintere Drittel schleift nach. / EN: The rear third drags behind.
- `[1489.hundertfuesser.angeschlagen.4]` Rollt sich immer wieder halb ein. / EN: Keeps half curling up.

## Riesenspinne

- `[1489.spinne.jung.1]` Die Beine noch dünn und blass. / EN: Legs still thin and pale.
- `[1489.spinne.jung.2]` Das Netz hinter ihr unordentlich gesponnen. / EN: The web behind it spun untidily.
- `[1489.spinne.jung.3]` Kaum größer als ein Hund. / EN: Barely bigger than a dog.
- `[1489.spinne.jung.4]` Weicht zurück, bevor sie vorschnellt. / EN: Shrinks back before it lunges.
- `[1489.spinne.alt.1]` Graue Borsten an den Beinen, der Leib ausgeblichen. / EN: Gray bristles on its legs, its body faded.
- `[1489.spinne.alt.2]` Die Augen trüb wie Glas im Rauch. / EN: Eyes dull as glass in smoke.
- `[1489.spinne.alt.3]` Das Netz zerrissen und nicht mehr geflickt. / EN: Its web torn and no longer mended.
- `[1489.spinne.alt.4]` Bewegt sich langsam und bedacht. / EN: Moves slowly and with care.
- `[1489.spinne.kraeftig.1]` Der Leib so groß wie ein Fass. / EN: Its body as big as a barrel.
- `[1489.spinne.kraeftig.2]` Giftklauen dick wie Daumen, schwarz und feucht. / EN: Fangs thick as thumbs, black and wet.
- `[1489.spinne.kraeftig.3]` Im Netz hängen die Reste eines Rehs. / EN: The remains of a deer hang in its web.
- `[1489.spinne.kraeftig.4]` Die Beine spannen weiter, als ein Mann groß ist. / EN: Its legs span wider than a man is tall.
- `[1489.spinne.angeschlagen.1]` Zwei Beine fehlen auf einer Seite. / EN: Two legs missing on one side.
- `[1489.spinne.angeschlagen.2]` Aus dem Hinterleib sickert Saft. / EN: Fluid seeps from its abdomen.
- `[1489.spinne.angeschlagen.3]` Ein Bein knickt immer wieder unter ihr weg. / EN: One leg keeps buckling beneath it.
- `[1489.spinne.angeschlagen.4]` Eine frische Brandwunde auf dem Rücken. / EN: A fresh burn on its back.

## Riesenfledermaus

- `[1489.fledermaus.jung.1]` Die Flughaut dünn wie Pergament. / EN: Wing membranes thin as parchment.
- `[1489.fledermaus.jung.2]` Flattert hektisch und findet keinen Takt. / EN: Flutters frantically, finding no rhythm.
- `[1489.fledermaus.jung.3]` Kaum größer als eine Taube. / EN: Barely bigger than a pigeon.
- `[1489.fledermaus.jung.4]` Ihr Schrei bricht immer wieder ab. / EN: Its shriek keeps breaking off.
- `[1489.fledermaus.alt.1]` Löcher in der Flughaut, mit Narben verwachsen. / EN: Holes in its wings, grown over with scars.
- `[1489.fledermaus.alt.2]` Das Fell grau, die Ohren zerfranst. / EN: Fur gray, ears ragged.
- `[1489.fledermaus.alt.3]` Fliegt tief und schwer. / EN: Flies low and heavy.
- `[1489.fledermaus.alt.4]` Gleitet lange, bevor sie wieder schlägt. / EN: Glides a long while before it flaps again.
- `[1489.fledermaus.kraeftig.1]` Spannweite wie ein Mann mit ausgebreiteten Armen. / EN: A wingspan like a man with his arms spread.
- `[1489.fledermaus.kraeftig.2]` Schwere Flügelschläge, man spürt sie im Gesicht. / EN: Heavy wingbeats you feel on your face.
- `[1489.fledermaus.kraeftig.3]` Ein breites Maul voller nadelfeiner Zähne. / EN: A wide mouth full of needle teeth.
- `[1489.fledermaus.kraeftig.4]` Der Leib prall, als hätte sie gerade gefressen. / EN: Its body plump, as if it has just eaten.
- `[1489.fledermaus.angeschlagen.1]` Ein Flügel ist eingerissen, sie fliegt schief. / EN: One wing is torn; it flies lopsided.
- `[1489.fledermaus.angeschlagen.2]` Taumelt in der Luft und fängt sich knapp. / EN: Reels in the air and barely catches itself.
- `[1489.fledermaus.angeschlagen.3]` Blut glänzt am Rand der Flughaut. / EN: Blood glistens at the edge of a wing.
- `[1489.fledermaus.angeschlagen.4]` Landet immer wieder, um Kraft zu sammeln. / EN: Keeps landing to gather strength.

## Riesenegel

- `[1489.egel.jung.1]` Kurz und durchscheinend, man sieht das Wasser in ihm. / EN: Short and translucent; you can see the water inside it.
- `[1489.egel.jung.2]` Das Saugmaul noch klein, kaum so groß wie ein Fingerring. / EN: Its sucker still small, barely the size of a ring.
- `[1489.egel.jung.3]` Rollt sich bei jeder Berührung zusammen. / EN: Curls up at every touch.
- `[1489.egel.jung.4]` Hell wie eine Made. / EN: Pale as a maggot.
- `[1489.egel.alt.1]` Die Haut faltig und von Narben gefurcht. / EN: Its skin wrinkled and furrowed with scars.
- `[1489.egel.alt.2]` Dunkel, fast schwarz, und langsam. / EN: Dark, almost black, and slow.
- `[1489.egel.alt.3]` Ein Rand des Saugmauls ist ausgefranst. / EN: One edge of its sucker is frayed.
- `[1489.egel.alt.4]` Liegt lange still, bevor er sich regt. / EN: Lies still a long time before it stirs.
- `[1489.egel.kraeftig.1]` Dick wie ein Unterarm und voller Blut. / EN: Thick as a forearm and full of blood.
- `[1489.egel.kraeftig.2]` Das Saugmaul groß wie ein Handteller. / EN: Its sucker as big as a palm.
- `[1489.egel.kraeftig.3]` Glänzt prall und schwer. / EN: Glistens, plump and heavy.
- `[1489.egel.kraeftig.4]` Im Maul Ringe scharfer Zähne. / EN: Rings of sharp teeth line its mouth.
- `[1489.egel.angeschlagen.1]` Seitlich eingerissen, er verliert Saft. / EN: Split along one side, leaking.
- `[1489.egel.angeschlagen.2]` Verschrumpelt, als hätte jemand Salz gestreut. / EN: Shriveled, as if someone had thrown salt on it.
- `[1489.egel.angeschlagen.3]` Hinterlässt eine dunkle Spur auf dem Boden. / EN: Leaves a dark trail on the ground.
- `[1489.egel.angeschlagen.4]` Ein Ende ist abgetrennt und verheilt nicht. / EN: One end is cut off and will not heal.
