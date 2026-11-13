class_name Varianten
# 504.1 (Chef 03.11., 07:52: „Mindestens 3 … Lebendige Welt, keine monotone Welt“): Wortlaute je Marke aus Homers
# STORY-VARIANTEN-K1.md und -K1-WALD.md, ERZEUGT von tools/varianten504.py; nicht von Hand ändern. „w“: nur Wiederholung
# (Wortlaut 1 nur beim ersten Mal); „v“: Wortlaute ab 2 bzw. W1–W3, je Wortlaut Sprechblasen [de, en].
const V := {
	"504.jorin.vor": {
		"w": false,
		"v": [
			[
				[
					"Zurück mit dir. Seit die Goblins auf der Waldstraße lauern, geht keiner mehr allein hinaus.",
					"Back you go. Since the goblins started lurking on the forest road, nobody goes out alone."
				],
				[
					"Erst wenn der Älteste es sagt, hebe ich den Schlagbaum.",
					"Only when the Elder says so will I raise the barrier."
				]
			],
			[
				[
					"Nein. Nicht ohne das Wort des Ältesten.",
					"No. Not without the Elder's word."
				],
				[
					"Ich habe zu viele in den Flüsterwald gehen sehen, die nicht zurückkamen.",
					"I've seen too many walk into the Whisperwood and never come back."
				]
			]
		]
	},
	"504.jorin.offen": {
		"w": false,
		"v": [
			[
				[
					"Der Weg nach Norden ist offen, {name}. Ich halte hier Wache, bis du zurück bist.",
					"The road north is open, {name}. I'll keep watch here until you're back."
				],
				[
					"Tipp: Im hohen Gras lauern Monster. Wer verletzt ist, bleibt auf dem Weg.",
					"Tip: monsters lurk in the tall grass. If you're hurt, stay on the path."
				]
			],
			[
				[
					"Wieder hinaus? Pass im Flüsterwald auf deinen Rücken auf.",
					"Heading out again? Watch your back in the Whisperwood."
				],
				[
					"Und denk dran: Im hohen Gras lauern Monster. Wenn du verletzt bist, bleib auf dem Weg.",
					"And remember: monsters lurk in the tall grass. If you're hurt, stay on the path."
				]
			]
		]
	},
	"504.jorin.danach": {
		"w": false,
		"v": [
			[
				[
					"Der Nordweg ist ruhig, seit Grak gefallen ist. So ruhig wie lange nicht.",
					"The north road has been quiet since Grak fell. Quieter than it's been in a long time."
				]
			],
			[
				[
					"Wenn noch einmal etwas aus dem Wald kommt, stehe ich hier. Aber ich bin froh, wenn du dann nicht weit bist, {name}.",
					"If anything comes out of those woods again, I'll be standing right here. But I'll be glad if you're not far off, {name}."
				]
			]
		]
	},
	"504.pim.vor": {
		"w": false,
		"v": [
			[
				[
					"Ich war schon mal am Schlagbaum! Jorin hat mich am Kragen zurückgezogen.",
					"I've been to the barrier once! Jorin dragged me back by the collar."
				],
				[
					"Goblins fürchten Feuer, sagt Papa. Thessa verkauft Brandflaschen, damit kann jeder zaubern, auch ohne Magier zu sein!",
					"Goblins fear fire, Dad says. Thessa sells firebottles; anyone can do magic with them, even without being a wizard!"
				]
			],
			[
				[
					"Hast du schon mal einen Goblin gesehen? Ganz echt? Wie riechen die?",
					"Have you ever seen a goblin? A real one? What do they smell like?"
				],
				[
					"Papa sagt, Feuer macht ihnen Angst. Mit Thessas Brandflaschen kämpft jeder wie ein Magier.",
					"Dad says fire scares them. With Thessa's firebottles anyone can fight like a wizard."
				]
			]
		]
	},
	"504.pim.danach": {
		"w": false,
		"v": [
			[
				[
					"Zeig mir, wie man eine Waffe hält! Bitte! Nur einmal!",
					"Show me how to hold a weapon! Please! Just once!"
				]
			],
			[
				[
					"Ich hab Grak aus Holz geschnitzt. Heute Abend werfe ich ihn ins Feuer.",
					"I carved Grak out of wood. Tonight I'm throwing him in the fire."
				]
			]
		]
	},
	"504.bram.vor": {
		"w": false,
		"v": [
			[
				[
					"Die Wölfe kommen jetzt bis an den Zaun. Früher haben sie sich das nicht getraut.",
					"The wolves come right up to the fence now. They never dared before."
				],
				[
					"Erbeutest du im Wald Fleisch, brat es am Lagerfeuer. Nichts macht so stark.",
					"If you take meat in the woods, roast it over a campfire. Nothing makes you stronger."
				]
			],
			[
				[
					"Ich mähe nur noch bei Tag. Nachts gehört der Acker den Wölfen.",
					"I only mow by day now. At night the field belongs to the wolves."
				],
				[
					"Fleisch aus dem Wald brätst du am besten gleich am Lagerfeuer. Dann gibt es dir Kraft.",
					"Meat from the woods is best roasted right there over a campfire. Then it gives you strength."
				]
			]
		]
	},
	"504.bram.danach": {
		"w": false,
		"v": [
			[
				[
					"Die Goblins sind fort, die Wölfe nicht. Aber die kenne ich wenigstens.",
					"The goblins are gone, the wolves aren't. But at least I know those."
				]
			],
			[
				[
					"Ein Held auf meinem Acker. Mein Vater hätte mir das nie geglaubt.",
					"A hero in my field. My father would never have believed it."
				]
			]
		]
	},
	"504.liska.vor": {
		"w": false,
		"v": [
			[
				[
					"Seit die Goblins auf der Waldstraße lauern, wird beim Wäscheaufhängen nur noch geflüstert.",
					"Since the goblins started lurking on the forest road, there's only whispering at the washing lines."
				],
				[
					"Am Brunnen ist Markt. Und Thessa hat neue Ware, sieh sie dir an.",
					"There's a market by the well. And Thessa has new goods, take a look."
				]
			],
			[
				[
					"Die Wäsche flattert, die Leute tratschen. Das Übliche.",
					"The laundry flaps, people gossip. The usual."
				],
				[
					"Wenn du was Frisches brauchst: Obst gibt's am Brunnen. Und Thessa hat neue Ware.",
					"If you need something fresh: there's fruit by the well. And Thessa has new goods."
				]
			]
		]
	},
	"504.liska.danach": {
		"w": false,
		"v": [
			[
				[
					"Erzähl, {name}! Stimmt es, dass Grak zwei Köpfe größer war als du?",
					"Tell me, {name}! Is it true Grak was two heads taller than you?"
				]
			],
			[
				[
					"Die Leute reden nur noch von dir. Und ein paar flüstern, die Goblins kommen wieder.",
					"People talk of nothing but you. And a few whisper that the goblins will come back."
				]
			]
		]
	},
	"504.gwenna.vor": {
		"w": false,
		"v": [
			[
				[
					"Heute wieder nichts gefangen. Die Fische sind so still wie das ganze Dorf.",
					"Caught nothing again today. The fish are as quiet as the whole village."
				]
			],
			[
				[
					"Seit mein Mann fort ist, sitze ich nachts allein am Wasser. Und die Wölfe singen mir was.",
					"Since my husband's been gone, I sit by the water alone at night. And the wolves sing to me."
				]
			]
		]
	},
	"504.gwenna.danach": {
		"w": false,
		"v": [
			[
				[
					"Du warst in der Höhle, {name}. Erzähl mir nicht, was dort unten war.",
					"You've been in the cave, {name}. Don't tell me what was down there."
				]
			],
			[
				[
					"Die Nächte sind stiller geworden. Ich fische wieder.",
					"The nights have grown quieter. I'm fishing again."
				]
			]
		]
	},
	"504.rowena.vor": {
		"w": false,
		"v": [
			[
				[
					"Was stehst du noch hier? Aldric wartet. Sein Haus liegt unten links am Dorfplatz.",
					"What are you still standing around for? Aldric is waiting. His house is at the bottom left of the village square."
				]
			],
			[
				[
					"Der Älteste hat schon nach dir gefragt. Unten links am Dorfplatz, {name}.",
					"The Elder has been asking for you. Bottom left of the village square, {name}."
				]
			]
		]
	},
	"504.rowena.unterwegs": {
		"w": false,
		"v": [
			[
				[
					"Der Wald ist kein Spaziergang, {name}. Wenn dich etwas erwischt, geh zu Bruder Osric in den Tempel. Er heilt jeden, der darum bittet.",
					"The woods are no stroll, {name}. If something gets you, go to Brother Osric at the temple. He heals anyone who asks."
				]
			],
			[
				[
					"Setz dich, iss was. Und wenn die Wunden nicht heilen wollen: Bruder Osric im Tempel weist keinen ab.",
					"Sit down, eat something. And if your wounds won't heal, Brother Osric at the temple turns no one away."
				]
			]
		]
	},
	"504.rowena.lager": {
		"w": false,
		"v": [
			[
				[
					"Ich hab den Fuhrleuten vom Lager erzählt. Seitdem trinkt keiner mehr auf die Südstraße.",
					"I told the carters about the camp. Since then nobody drinks to the south road anymore."
				]
			],
			[
				[
					"Wenn du nach Süden gehst, {name}, dann nicht mit leeren Taschen.",
					"If you go south, {name}, don't go with empty pockets."
				]
			]
		]
	},
	"504.rowena.held": {
		"w": false,
		"v": [
			[
				[
					"Der Held von Bornim! Setz dich, das erste Bier zahle ich.",
					"The hero of Bornim! Sit down, the first beer's on me."
				]
			],
			[
				[
					"Seit du zurück bist, ist der Greif jeden Abend voll. Dein Bier geht aufs Haus, {name}.",
					"Since you came back, the Griffin is full every night. Your beer's on the house, {name}."
				]
			]
		]
	},
	"504.rowena.fleisch": {
		"w": false,
		"v": [
			[
				[
					"Ist das Wild? Her damit, das kommt morgen in den Eintopf.",
					"Is that game? Hand it over, it's going in tomorrow's stew."
				]
			],
			[
				[
					"Rohes Fleisch? Gib's mir, bevor es verdirbt. Im Greif wird ein Eintopf draus.",
					"Raw meat? Give it here before it spoils. The Griffin will make a stew of it."
				]
			]
		]
	},
	"504.borin": {
		"w": false,
		"v": [
			[
				[
					"Gegen Knochen hilft keine Klinge. Nimm eine Wuchtwaffe: Streitkolben, Hammer, zur Not einen Stab.",
					"A blade's no use against bones. Take a bludgeoning weapon: a mace, a hammer, a staff if you must."
				],
				[
					"Und wenn du heiliges Licht hast: Untotes brennt darin wie trockenes Holz.",
					"And if you have holy light: the undead burn in it like dry wood."
				]
			],
			[
				[
					"Hrmpf. Du schon wieder. Merk's dir: Skelette zerschlägt man, man schneidet sie nicht.",
					"Hrmph. You again. Mark my words: skeletons are smashed, not cut."
				],
				[
					"Wuchtwaffen brechen Knochen. Und gegen alles Untote hilft heiliges Licht.",
					"Bludgeoning weapons break bones. And holy light works against all undead."
				]
			]
		]
	},
	"504.thessa.gruss": {
		"w": false,
		"v": [
			[
				[
					"Ah, {name}. Sieh dich um, aber fass nichts an, was du nicht bezahlen willst.",
					"Ah, {name}. Look around, but don't touch what you won't pay for."
				]
			],
			[
				[
					"Frische Ware, faire Preise. Was brauchst du da draußen?",
					"Fresh goods, fair prices. What do you need out there?"
				]
			]
		]
	},
	"504.thessa.abschied": {
		"w": false,
		"v": [
			[
				[
					"Pass auf dich auf. Tote Kunden zahlen schlecht.",
					"Take care. Dead customers pay badly."
				]
			],
			[
				[
					"Bis zum nächsten Mal, {name}.",
					"Until next time, {name}."
				]
			]
		]
	},
	"504.osric.gruss": {
		"w": false,
		"v": [
			[
				[
					"Komm herein, {name}. Setz dich, ich versorge deine Wunden.",
					"Come in, {name}. Sit down, I'll tend to your wounds."
				]
			],
			[
				[
					"Das Morgenlicht weist niemanden ab. Lass mich sehen, was dir fehlt.",
					"The Dawnlight turns no one away. Let me see what ails you."
				]
			]
		]
	},
	"504.osric.gruss.danach": {
		"w": false,
		"v": [
			[
				[
					"Lyras Retter in meinem Tempel. Komm, lass mich deine Wunden versorgen.",
					"Lyra's rescuer in my temple. Come, let me tend to your wounds."
				]
			],
			[
				[
					"Lyra ist zurück, und du hast sie gebracht. Setz dich, {name}.",
					"Lyra is back, and you brought her. Sit down, {name}."
				]
			]
		]
	},
	"504.osric.heilung": {
		"w": false,
		"v": [
			[
				[
					"Osric murmelt ein Gebet, und Wärme fließt in deine Glieder. Leben und Mana sind wieder voll.",
					"Osric murmurs a prayer, and warmth flows into your limbs. Life and mana are full again."
				]
			],
			[
				[
					"Der Schmerz ebbt ab, als Osrics Hände über deine Wunden gleiten. Leben und Mana sind wieder voll.",
					"The pain ebbs as Osric's hands pass over your wounds. Life and mana are full again."
				]
			]
		]
	},
	"504.osric.verband": {
		"w": false,
		"v": [
			[
				[
					"Wenn du draußen blutest, bin ich nicht bei dir. Nimm Verbände mit, für ein paar Münzen.",
					"Out there, if you bleed, I won't be with you. Take some bandages, for a few coins."
				]
			],
			[
				[
					"Saubere Leinen, fest gerollt: Verbände für unterwegs. Der Tempel gibt sie für ein paar Münzen.",
					"Clean linen, tightly rolled: bandages for the road. The temple sells them for a few coins."
				]
			]
		]
	},
	"504.osric.bitte": {
		"w": false,
		"v": [
			[
				[
					"Jeden Morgen bete ich für Lyra. Bring sie zurück, {name}, und das Amulett mit ihr.",
					"Every morning I pray for Lyra. Bring her back, {name}, and the amulet with her."
				]
			],
			[
				[
					"Der Altar ist leer, und der Tempel wird jede Nacht kälter. Finde Lyra.",
					"The altar is empty, and the temple grows colder every night. Find Lyra."
				]
			]
		]
	},
	"504.lyra.tempel": {
		"w": false,
		"v": [
			[
				[
					"Ich bin in Sicherheit, {name}. Aber das Amulett gehört zu Aldric. Bring es ihm.",
					"I'm safe, {name}. But the amulet belongs with Aldric. Take it to him."
				]
			],
			[
				[
					"Geh zum Ältesten, bitte. Solange das Amulett nicht bei ihm ist, finde ich keine Ruhe.",
					"Go to the Elder, please. Until the amulet is with him, I'll find no rest."
				]
			]
		]
	},
	"504.lyra.tempel.danach": {
		"w": false,
		"v": [
			[
				[
					"Ich höre ihn noch, wenn ich die Augen schließe. Eine Stimme wie Asche im Wind.",
					"I still hear him when I close my eyes. A voice like ash on the wind."
				]
			],
			[
				[
					"Das Amulett liegt wieder auf dem Altar. Aber wer es einmal rauben ließ, versucht es wieder.",
					"The amulet is back on the altar. But whoever had it stolen once will try again."
				]
			]
		]
	},
	"504.aldric.unterwegs": {
		"w": false,
		"v": [
			[
				[
					"Grak lebt noch, {name}. Die Blutzahnhöhle liegt am Nordende des Flüsterwalds.",
					"Grak still lives, {name}. The Bloodfang Cave lies at the northern end of the Whisperwood."
				],
				[
					"Bruder Osric heilt deine Wunden, und bei Thessa findest du gute Ausrüstung.",
					"Brother Osric will heal your wounds, and Thessa has good equipment."
				]
			],
			[
				[
					"Jeder Tag, den Lyra in dieser Höhle verbringt, ist einer zu viel.",
					"Every day Lyra spends in that cave is one too many."
				],
				[
					"Lass dich bei Osric im Tempel heilen und rüste dich bei Thessa aus. Dann zur Blutzahnhöhle, am Nordende des Flüsterwalds.",
					"Let Osric heal you at the temple and gear up at Thessa's. Then on to the Bloodfang Cave, at the northern end of the Whisperwood."
				]
			]
		]
	},
	"504.aldric.ohne.lyra": {
		"w": false,
		"v": [
			[
				[
					"Grak ist besiegt, gut. Aber ohne Lyra ist nichts gewonnen. Sie muss noch in der Höhle sein.",
					"Grak is defeated, good. But without Lyra nothing is won. She must still be in the cave."
				]
			],
			[
				[
					"Du kommst ohne Lyra zurück? Geh noch einmal in Graks Halle, {name}. Bitte.",
					"You come back without Lyra? Go back to Grak's hall, {name}. Please."
				]
			]
		]
	},
	"504.aldric.ende": {
		"w": false,
		"v": [
			[
				[
					"Bornim schuldet dir viel, {name}. Aber ich fürchte, der Graue Prophet hat erst begonnen.",
					"Bornim owes you much, {name}. But I fear the Gray Prophet has only just begun."
				]
			],
			[
				[
					"Ich lese den Brief jede Nacht. Der Tag der Asche … was er auch ist, er kommt näher.",
					"I read the letter every night. The Day of Ashes… whatever it is, it's drawing closer."
				]
			]
		]
	},
	"504.aldric.lager": {
		"w": false,
		"v": [
			[
				[
					"Das Lager im Süden geht mir nicht aus dem Kopf. Wer dort festsitzt, hat niemanden außer uns.",
					"The camp in the south won't leave my mind. Whoever is held there has no one but us."
				]
			],
			[
				[
					"Wenn du nach Süden gehst, {name}: Bornim steht hinter dir.",
					"If you go south, {name}: Bornim stands behind you."
				]
			]
		]
	},
	"504.garrick.krogg": {
		"w": false,
		"v": [
			[
				[
					"Krogg trägt den Schlüssel zu Graks Halle. Er haust im Ostflügel der Höhle; ruh dich vorher gut aus.",
					"Krogg carries the key to Grak's hall. He lurks in the east wing of the cave; rest well first."
				],
				[
					"Geh vorher zu Morwen in den Tiefen Flüsterwald. Sie weiß, wie man so einem den ersten Hieb nimmt.",
					"See Morwen in the Deep Whisperwood first. She knows how to rob one like him of his first strike."
				]
			],
			[
				[
					"Krogg lebt noch, hm? Ostflügel der Höhle, den Schlüssel trägt er am Gürtel. Ruh dich vorher aus.",
					"Krogg still alive, eh? East wing of the cave, he carries the key on his belt. Rest first."
				],
				[
					"Und nicht ohne Morwen, die Kräuterfrau im Tiefen Flüsterwald. Sonst trifft dich sein erster Hieb voll.",
					"And not without Morwen, the herbalist in the Deep Whisperwood. Otherwise his first strike hits you full on."
				]
			]
		]
	},
	"504.garrick.warnung": {
		"w": false,
		"v": [
			[
				[
					"Aber nicht so, {name}. So wie du jetzt bist, legt Krogg dich mit einem Schlag um. Werde erst stärker, im Tiefen Flüsterwald.",
					"But not like this, {name}. The way you are now, Krogg will knock you down with one blow. Get stronger first, in the Deep Whisperwood."
				]
			],
			[
				[
					"Ehrlich gesagt: Noch bist du kein Gegner für ihn. Hol dir im Tiefen Flüsterwald erst ein paar Narben.",
					"Honestly: you're no match for him yet. Get yourself a few scars in the Deep Whisperwood first."
				]
			]
		]
	},
	"504.garrick.rast": {
		"w": false,
		"v": [
			[
				[
					"Setz dich ans Feuer, {name}. Hier draußen weiß man nie, wann man wieder Ruhe hat.",
					"Sit by the fire, {name}. Out here you never know when you'll get rest again."
				]
			],
			[
				[
					"Krogg liegt, hab ich gehört. Gute Arbeit. Ruh dich aus, das Feuer brennt.",
					"Krogg's down, I hear. Good work. Rest a while, the fire's burning."
				]
			]
		]
	},
	"504.morwen.wieder": {
		"w": false,
		"v": [
			[
				[
					"Du schon wieder. Grimmzahn lebt noch, ich höre ihn nachts. Nimm Tränke mit.",
					"You again. Grimfang still lives, I hear him at night. Take potions with you."
				]
			],
			[
				[
					"Komm ans Feuer. Wer nach Norden zu Grimmzahn will, geht nicht mit leeren Taschen.",
					"Come to the fire. Whoever goes north to Grimfang doesn't go with empty pockets."
				]
			]
		]
	},
	"504.morwen.wieder.danach": {
		"w": false,
		"v": [
			[
				[
					"Seit Grimmzahn gefallen ist, wagen sich die Rehe wieder an meine Kräuter. Was brauchst du?",
					"Since Grimfang fell, the deer dare to come for my herbs again. What do you need?"
				]
			],
			[
				[
					"Der Wald atmet wieder. Willst du Tränke, oder soll ich dir etwas brauen?",
					"The forest breathes again. Do you want potions, or shall I brew you something?"
				]
			]
		]
	},
	"504.morwen.kraeuter": {
		"w": true,
		"v": [
			[
				[
					"Die hellgrünen Kräuter auf den Blumenwiesen: lauf einfach drüber, am nächsten Tag wachsen sie nach. Bring sie mir, dazu Fledermausflügel und Giftdrüsen, dann braue ich dir Tränke für ein paar Münzen.",
					"The light green herbs in the flower meadows: just walk over them, they grow back the next day. Bring them to me, with bat wings and venom glands, and I'll brew you potions for a few coins."
				]
			],
			[
				[
					"Hast du Kräuter dabei? Die hellgrünen von den Blumenwiesen; du läufst drüber, und morgen sind sie wieder da. Fledermausflügel und Giftdrüsen nehme ich auch. Für ein paar Münzen braue ich dir Tränke daraus.",
					"Got any herbs on you? The light green ones from the flower meadows; you walk over them, and tomorrow they're back. I'll take bat wings and venom glands too. For a few coins I'll brew you potions from them."
				]
			],
			[
				[
					"Pflück, was hellgrün auf den Blumenwiesen wächst; du musst nur drüberlaufen, es wächst über Nacht nach. Aus Kräutern, Fledermausflügeln und Giftdrüsen braue ich dir Tränke, für ein paar Münzen.",
					"Pick whatever grows light green in the flower meadows; you only have to walk over it, it grows back overnight. From herbs, bat wings and venom glands I'll brew you potions, for a few coins."
				]
			]
		]
	},
	"504.grimmzahn": {
		"w": true,
		"v": [
			[
				[
					"Aus dem Unterholz schiebt sich Grimmzahn, das Fell voller Narben. Er hat dich nicht vergessen.",
					"Grimfang pushes out of the undergrowth, its coat full of scars. It hasn't forgotten you."
				]
			],
			[
				[
					"Ein Knurren, tief wie Donner. Grimmzahn steht wieder vor dir, die Augen glühend rot.",
					"A growl, deep as thunder. Grimfang stands before you again, eyes glowing red."
				]
			],
			[
				[
					"Der Wald verstummt. Dann bricht Grimmzahn durchs Gebüsch, schneller, als du denken kannst.",
					"The forest falls silent. Then Grimfang bursts through the bushes, faster than you can think."
				]
			]
		]
	},
	"504.krogg": {
		"w": true,
		"v": [
			[
				[
					"DU WIEDER? Krogg hat noch nicht genug von dir!",
					"YOU AGAIN? Krogg hasn't had enough of you!"
				],
				[
					"Schlüssel bleibt bei Krogg!",
					"Key stays with Krogg!"
				]
			],
			[
				[
					"Kleines Ding kommt zurück. Krogg hat Hunger.",
					"Little thing comes back. Krogg is hungry."
				],
				[
					"Grak sagt: niemand kommt durch!",
					"Grak says: nobody gets through!"
				]
			],
			[
				[
					"Riecht nach Angst! Krogg mag den Geruch.",
					"Smells like fear! Krogg likes that smell."
				],
				[
					"Diesmal entkommt keiner Krogg!",
					"This time nobody gets away from Krogg!"
				]
			]
		]
	},
	"504.grak": {
		"w": true,
		"v": [
			[
				[
					"Du kriechst zurück in MEINE Halle? Mutig. Oder dumm.",
					"You crawl back into MY hall? Brave. Or stupid."
				],
				[
					"Der Prophet zahlt für jede Seele. Für deine zahlt er doppelt.",
					"The Prophet pays for every soul. For yours he'll pay double."
				]
			],
			[
				[
					"Noch einmal? Gut. Diesmal bringe ich dich dem Propheten selbst.",
					"Again? Good. This time I'll take you to the Prophet myself."
				]
			],
			[
				[
					"Die Priesterin betet für dich. Sie sollte für sich selbst beten.",
					"The priestess is praying for you. She should pray for herself."
				]
			]
		]
	},
	"504.gitter": {
		"w": false,
		"v": [
			[
				[
					"Du rüttelst am Gitter. Es gibt keinen Fingerbreit nach.",
					"You rattle the gate. It doesn't give an inch."
				]
			],
			[
				[
					"Das Schloss ist alt, aber fest. Ohne Schlüssel kommst du hier nicht durch.",
					"The lock is old but solid. Without a key you won't get through here."
				]
			]
		]
	},
	"504.tuer.edrik": {
		"w": false,
		"v": [
			[
				[
					"Schon wieder? Ich sagte: Ich mach nicht auf.",
					"Again? I said: I'm not opening."
				]
			],
			[
				[
					"Geh weg von meiner Tür. Wer klopft, will meistens nichts Gutes.",
					"Get away from my door. Whoever knocks usually means no good."
				]
			]
		]
	},
	"504.tuer.edrik.ende": {
		"w": false,
		"v": [
			[
				[
					"Ich hab gehört, was du getan hast. Trotzdem, die Tür bleibt zu.",
					"I heard what you did. Still, the door stays shut."
				]
			],
			[
				[
					"Seit Wochen schlafe ich wieder ruhig. Das soll auch so bleiben. Lass mich.",
					"For the first time in weeks I sleep soundly again. I'd like it to stay that way. Leave me be."
				]
			]
		]
	},
	"504.tuer.kael": {
		"w": false,
		"v": [
			[
				[
					"Klopf, so viel du willst. Was ich weiß, sag ich nicht durch eine Tür.",
					"Knock all you like. What I know, I don't say through a door."
				]
			],
			[
				[
					"Fremde an meiner Tür bringen nie etwas Gutes. Geh weiter.",
					"Strangers at my door never bring anything good. Move along."
				]
			]
		]
	},
	"504.tuer.gwenna": {
		"w": false,
		"v": [
			[
				[
					"Gwennas Haus. Die Tür ist verriegelt, wie jeden Tag, seit ihr Mann nicht zurückkam.",
					"Gwenna's house. The door is bolted, as every day since her husband didn't come back."
				]
			],
			[
				[
					"Niemand öffnet. Seit ihr Mann nicht zurückkam, ist Gwenna tagsüber am Fluss.",
					"No one answers. Since her husband didn't come back, Gwenna spends her days by the river."
				]
			]
		]
	},
	"504.tuer.gwenna.nacht": {
		"w": false,
		"v": [
			[
				[
					"Wer ist da? … Geh. Bitte.",
					"Who's there? … Go. Please."
				]
			],
			[
				[
					"Ich mach nachts nicht mehr auf. Für keinen.",
					"I don't open at night anymore. Not for anyone."
				]
			]
		]
	},
	"504.tuer.dorran": {
		"w": false,
		"v": [
			[
				[
					"Dorrans Haus. Niemand da; er steht sicher an der Esse.",
					"Dorran's house. Nobody home; he's surely at the forge."
				]
			],
			[
				[
					"Keiner öffnet. Um diese Zeit ist Dorran in seiner Werkstatt.",
					"No one answers. At this hour Dorran is in his workshop."
				]
			]
		]
	},
	"504.tuer.dorran.nacht": {
		"w": false,
		"v": [
			[
				[
					"Es ist Nacht. Schmiede schlafen auch.",
					"It's night. Smiths sleep too."
				]
			],
			[
				[
					"Wer will um diese Zeit etwas vom Schmied? Morgen.",
					"Who wants anything from the smith at this hour? Tomorrow."
				]
			]
		]
	},
	"504.tuer.pim": {
		"w": false,
		"v": [
			[
				[
					"Pim? Der ist wieder draußen. Wenn du ihn am Schlagbaum siehst, schick ihn heim.",
					"Pim? He's out again. If you see him at the barrier, send him home."
				]
			],
			[
				[
					"Nein, Pim ist nicht hier. Schleicht bestimmt wieder um den Schlagbaum.",
					"No, Pim's not here. Sneaking round the barrier again, no doubt."
				]
			]
		]
	},
	"504.tuer.pim.nacht": {
		"w": false,
		"v": [
			[
				[
					"Psst! Pim schläft endlich. Klopf morgen wieder.",
					"Shh! Pim's finally asleep. Knock again tomorrow."
				]
			],
			[
				[
					"Um diese Zeit? Geh heim, bevor dich die Wölfe holen.",
					"At this hour? Go home before the wolves get you."
				]
			]
		]
	},
	"504.schlagbaum": {
		"w": false,
		"v": [
			[
				[
					"Der Schlagbaum bleibt unten. Erst muss der Älteste dich schicken.",
					"The barrier stays down. First the Elder has to send you."
				]
			],
			[
				[
					"Das Seil ist fest verknotet. Ohne das Wort des Ältesten öffnet dir hier keiner.",
					"The rope is tied fast. Without the Elder's word nobody opens up for you here."
				]
			]
		]
	},
	"504.schlagbaum.quest": {
		"w": false,
		"v": [
			[
				[
					"Der Schlagbaum ist noch unten. Wache Jorin öffnet ihn dir.",
					"The barrier is still down. Guard Jorin will raise it for you."
				]
			],
			[
				[
					"Solange der Schlagbaum unten ist, kommst du nicht vorbei. Sprich mit Wache Jorin.",
					"As long as the barrier is down, you can't get past. Talk to Guard Jorin."
				]
			]
		]
	},
	"504.rast.hoehle": {
		"w": false,
		"v": [
			[
				[
					"Die Glut der Goblins ist noch warm. Hier zu rasten wäre viel zu gefährlich.",
					"The goblins' embers are still warm. Resting here would be far too dangerous."
				]
			],
			[
				[
					"Ein Feuer mitten in Feindesland. Wer hier rastet, wacht nicht wieder auf.",
					"A fire in the middle of enemy ground. Whoever rests here doesn't wake up."
				]
			]
		]
	},
	"504.rast.bett": {
		"w": false,
		"v": [
			[
				[
					"Ein fremdes Bett. Weich, aber nicht deins.",
					"A stranger's bed. Soft, but not yours."
				]
			],
			[
				[
					"Frisch bezogen und weich. Für jemand anderen.",
					"Freshly made and soft. For someone else."
				]
			]
		]
	},
	"504.erwachen": {
		"w": false,
		"v": [
			[
				[
					"Du kommst zu dir, an einem sicheren Ort. Der Weg hierher hat Stunden gedauert.",
					"You come to, somewhere safe. The way here took hours."
				]
			],
			[
				[
					"Schmerz, dann Stille. Du erwachst an einem sicheren Ort, und der Heimweg hat Stunden gekostet.",
					"Pain, then silence. You wake up somewhere safe, and the way home cost you hours."
				]
			]
		]
	}
}
