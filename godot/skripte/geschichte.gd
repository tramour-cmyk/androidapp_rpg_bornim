class_name Geschichte
# 390 (Gespraeche und Quests): Kapitel 1 wie Story.kt, Texte wortgleich (Entwurf maschinell aus Story.kt, dann von Hand;
# Pruefung tools/pruef348/story_texte.py: jeder Text aus Story.kt steht hier). Was jemand sagt, haengt nur am Zustand
# (Flaggen, Taschen, Stufe); die Befehle fuehrt spiel.gd aus wie Game.runQueue.

const INTRO_DONE := "intro_done"
const QUEST_STARTED := "quest_started"
const HUNTER_MET := "hunter_met"
const KROGG_DEFEATED := "krogg_defeated"
const GATE_OPEN := "gate_open"
const BARRIER_OPEN := "barrier_open"
const GRAK_DEFEATED := "grak_defeated"
const LYRA_RESCUED := "lyra_rescued"
const LYRA_GONE := "lyra_gone"
const CHAPTER1_DONE := "chapter1_done"
const TEMPLE_SEEN := "temple_seen"
const CAMP_TOLD := "camp_told"
const GRIMFANG_DEFEATED := "grimfang_defeated"
const HERBALIST_MET := "hedda_met"
const KROGG_HINT := "krogg_hint"
const SMOKE_GIVEN := "smoke_given"
const KROGG_WARN_BELOW := 3
const LOCKED := "locked_forever"
const CHAPTER2_STARTED := "chapter2_started"
const CHAPTER1_LEVEL_CAP := 6
const SMOKE_BUNDLE := "smoke_bundle"
const CLASS_WEAPON := "@class_weapon"

const rowena := {"de": "Rowena", "en": "Rowena"}
const borin := {"de": "Borin", "en": "Borin"}
const aldric := {"de": "Ältester Aldric", "en": "Elder Aldric"}
const thessa := {"de": "Thessa", "en": "Thessa"}
const osric := {"de": "Bruder Osric", "en": "Brother Osric"}
const lyra := {"de": "Lyra", "en": "Lyra"}
const jorin := {"de": "Wache Jorin", "en": "Guard Jorin"}
const pim := {"de": "Pim", "en": "Pim"}
const gwenna := {"de": "Gwenna", "en": "Gwenna"}
const bram := {"de": "Bauer Bram", "en": "Farmer Bram"}
const liska := {"de": "Liska", "en": "Liska"}
const garrick := {"de": "Jäger Garrick", "en": "Hunter Garrick"}
const krogg := {"de": "Krogg", "en": "Krogg"}
const grak := {"de": "Grak", "en": "Grak"}
const morwen := {"de": "Kräuterfrau Morwen", "en": "Morwen the Herbalist"}
const HERBALIST_HERBS := {"de": "Auf den bunten Blumenwiesen im Wald wachsen Heilkräuter – achte auf die hellgrünen Pflanzen und lauf einfach darüber. Was du pflückst, wächst am nächsten Tag nach. Bring sie mir, dann braue ich dir Tränke für ein paar Münzen. Fledermausflügel und Giftdrüsen nehme ich auch.", "en": "Healing herbs grow in the colorful flower meadows of the forest – look for the light green plants and just walk over them. What you pick grows back the next day. Bring them to me and I'll brew you potions for a few coins. I'll take bat wings and venom glands too."}
const SHOP_STOCK := ["potion", "greater_potion", "superior_potion", "remedy", "stamina_potion", "spark_potion", "alchemist_fire", "holy_water"]
const HERBALIST_STOCK := ["potion", "greater_potion", "remedy", "stamina_potion", "holy_water"]
const CHAPTER_END_TEXT := {"de": "Bornim feiert bis tief in die Nacht. Das Sonnenamulett ist zurück in Bornim, und Schwester Lyra ist in Sicherheit.\n\nDoch der Brief mit dem grauen Siegel lässt dich nicht los. Wer ist der Graue Prophet? Und was ist der Tag der Asche?\n\nENDE VON KAPITEL 1\n\nDu kannst weiterspielen, Monster jagen und deinen Helden verbessern.", "en": "Bornim celebrates late into the night. The Sun Amulet is back in Bornim, and Sister Lyra is safe.\n\nBut the letter with the gray seal won't leave your mind. Who is the Gray Prophet? And what is the Day of Ashes?\n\nEND OF CHAPTER 1\n\nYou can keep playing, hunt monsters and improve your hero."}

static func gespraech(id: String, s: Zustand) -> Array:
	var k := Skript.new()
	match id:
		"jorin":
			if not s.has(QUEST_STARTED):
				k.say(jorin, "Halt! Der Flüsterwald ist zu gefährlich geworden.", "Halt! The Whisperwood has become too dangerous.")
				k.say(jorin, "Ohne Erlaubnis des Ältesten lasse ich niemanden hinaus.", "I'm not letting anyone out without the Elder's permission.")
			elif not s.has(BARRIER_OPEN):
				k.say(jorin, "Der Älteste hat mir Bescheid gegeben. Dann wollen wir mal.", "The Elder told me about you. Well then, let's go.")
				k.flag(BARRIER_OPEN)
				k.narrate("Jorin löst das Seil, und der Schlagbaum schwingt knarrend nach oben. Der Weg nach Norden ist frei.", "Jorin releases the rope and the barrier swings up with a creak. The road north is open.")
				k.say(jorin, "Viel Glück da draußen, {name}! Tipp: Im hohen Gras lauern Monster. Bleib auf dem Weg, wenn du verletzt bist.", "Good luck out there, {name}! Tip: monsters lurk in the tall grass. Stay on the path when you're hurt.")
			elif not s.has(CHAPTER1_DONE):
				k.say(jorin, "Der Älteste hat mir Bescheid gegeben. Viel Glück da draußen, {name}!", "The Elder told me about you. Good luck out there, {name}!")
				k.say(jorin, "Tipp: Im hohen Gras lauern Monster. Bleib auf dem Weg, wenn du verletzt bist.", "Tip: monsters lurk in the tall grass. Stay on the path when you're hurt.")
			else:
				k.say(jorin, "Seit du Grak besiegt hast, schlafe ich wieder ruhig. Danke, {name}!", "Since you beat Grak, I've been sleeping soundly again. Thanks, {name}!")
		"pim":
			if not s.has(CHAPTER1_DONE):
				k.say(pim, "Papa sagt, Goblins haben Angst vor Feuer! Stimmt das?", "Dad says goblins are scared of fire! Is that true?")
				k.say(pim, "Thessa verkauft Alchemistenfeuer. Damit kann man sogar zaubern, ohne Magier zu sein!", "Thessa sells alchemist's fire. You can do magic with it without even being a wizard!")
			else:
				k.say(pim, "Wenn ich groß bin, werde ich auch ein Held! Genau wie du!", "When I grow up I'll be a hero too! Just like you!")
		"bram":
			if not s.has(CHAPTER1_DONE):
				k.say(bram, "Das Korn steht gut dieses Jahr. Wenn nur die Wölfe nicht wären – letzte Woche haben sie mir zwei Hühner geholt.", "The grain is doing well this year. If only it weren't for the wolves – last week they took two of my hens.")
				k.say(bram, "Wenn du im Wald Fleisch erbeutest: Am Lagerfeuer gebraten schmeckt es am besten. Und es macht stark!", "If you get meat in the forest, roast it over a campfire – that's when it tastes best. And it makes you strong!")
			else:
				k.say(bram, "Seit die Goblins fort sind, schlafen sogar meine Hühner wieder ruhig.", "Now that the goblins are gone, even my hens sleep soundly again.")
		"liska":
			if not s.has(CHAPTER1_DONE):
				k.say(liska, "Bei dem Wetter trocknet die Wäsche im Nu. Hast du schon Thessas neue Ware gesehen?", "In this weather the laundry dries in no time. Have you seen Thessa's new goods yet?")
				k.say(liska, "Auf dem Markt am Brunnen gibt es frisches Obst. Und die Kräuterstände riechen herrlich.", "There's fresh fruit at the market by the well. And the herb stalls smell wonderful.")
			else:
				k.say(liska, "Ganz Bornim spricht von dir! Ich habe gehört, du hast Grak mit bloßen Händen besiegt.", "All of Bornim is talking about you! I heard you beat Grak with your bare hands.")
		"gwenna":
			if not s.has(CHAPTER1_DONE):
				k.say(gwenna, "Früher konnte man nachts in Ruhe fischen. Jetzt heulen die Wölfe bis zum Morgengrauen.", "We used to fish here in peace at night. Now the wolves howl until dawn.")
			else:
				k.say(gwenna, "Der Held von Bornim! Ich hab's ja immer gewusst.", "The hero of Bornim! I always knew it.")
		"rowena":
			if not s.has(QUEST_STARTED):
				k.say(rowena, "Ältester Aldric wartet auf dich. Sein Haus liegt unten links am Dorfplatz.", "Elder Aldric is waiting for you. His house is at the bottom left of the village square.")
				counter(k, s)
			elif not s.has(CHAPTER1_DONE):
				k.say(rowena, "Pass auf dich auf, {name}. Wenn du verletzt bist: Bruder Osric im Tempel heilt jeden, der darum bittet.", "Take care, {name}. If you're hurt, Brother Osric at the temple heals anyone who asks.")
				counter(k, s)
			# [68.rowena.lager]
			elif s.has(CAMP_TOLD):
				k.say(rowena, "Ein Lager im Süden? Die Fuhrleute meiden die Südstraße seit dem Frühjahr. Jetzt weiß ich vielleicht, warum.", "A camp in the south? The carters have avoided the south road since spring. Now I may know why.")
				counter(k, s)
			else:
				k.say(rowena, "Für den Helden von Bornim geht das Bier heute aufs Haus!", "Drinks are on the house for the hero of Bornim tonight!")
				counter(k, s)
		"borin":
			k.say(borin, "Hrmpf. Ein Zwerg weiß so etwas: Skelette hassen Wuchtwaffen!", "Hrmph. A dwarf knows these things: skeletons hate bludgeoning weapons!")
			k.say(borin, "Streitkolben, Hammer, sogar ein Stab – das zerschmettert ihre Knochen. Und heiliges Licht verbrennt alles Untote.", "Mace, hammer, even a staff will shatter their bones. And holy light burns all undead.")
		"thessa":
			k.say(thessa, "Willkommen in Thessas Kramladen! Was darf's sein?", "Welcome to Thessa's General Store! What can I get you?")
			k.shop(SHOP_STOCK)
			k.say(thessa, "Komm bald wieder!", "Come again soon!")
		"aldric":
			elder_talk(k, s)
		"osric":
			if not s.has(LYRA_RESCUED):
				k.say(osric, "Willkommen im Tempel des Morgenlichts. Lass mich deine Wunden versorgen.", "Welcome to the Temple of the Dawnlight. Let me tend to your wounds.")
			else:
				k.say(osric, "Gesegnet seist du, {name}. Lass mich deine Wunden versorgen.", "Blessings upon you, {name}. Let me tend to your wounds.")
			k.rest()
			k.narrate("Ein warmes Licht umhüllt dich. TP und ZP sind vollständig wiederhergestellt.", "A warm light surrounds you. HP and SP are fully restored.")
			if not s.has(LYRA_RESCUED):
				k.say(osric, "Bitte … finde Schwester Lyra. Ohne sie und das Amulett ist dieser Tempel nur ein kalter Steinhaufen.", "Please… find Sister Lyra. Without her and the amulet, this temple is just a cold pile of stones.")
		"lyra_temple":
			if not s.has(CHAPTER1_DONE):
				k.say(lyra, "Danke, dass du mich gerettet hast, {name}. Bitte bring das Amulett zu Ältestem Aldric!", "Thank you for rescuing me, {name}. Please take the amulet to Elder Aldric!")
			elif not s.has(CAMP_TOLD):
				# the morning was cut short (the game closed during the scene) or the chapter ended before 68: Lyra tells it now
				camp_lines(k, s)
			else:
				k.say(lyra, "Der Graue Prophet … Ich habe seine Stimme in meinen Träumen gehört. Wir müssen vorbereitet sein.", "The Gray Prophet… I've heard his voice in my dreams. We must be prepared.")
		"garrick":
			if not s.has(HUNTER_MET):
				k.say(garrick, "Ein Abenteurer? Setz dich ans Feuer. Ich bin Garrick, Jäger aus Bornim.", "An adventurer? Sit by the fire. I'm Garrick, a hunter from Bornim.")
				k.say(garrick, "Im hohen Gras lauern Riesenratten, Wölfe und Goblin-Späher. Auf dem Weg bist du sicherer.", "Giant rats, wolves and goblin scouts lurk in the tall grass. You're safer on the path.")
				k.say(garrick, "An einem Lagerfeuer kannst du rasten; eine lange Rast heilt dich ganz. Und hier, nimm das.", "You can rest at a campfire; a long rest heals you fully. And here, take these.")
				k.give("potion", 2)
				k.flag(HUNTER_MET)
				# D23.2 (Homer 17.10.): the Krogg part follows at once, so a single talk is enough
				if not s.has(KROGG_DEFEATED): krogg_tip(k, s)
			elif not s.has(KROGG_DEFEATED):
				krogg_tip(k, s)
			else:
				k.say(garrick, "Du siehst aus, als könntest du eine Rast gebrauchen. Das Feuer brennt noch.", "You look like you could use a rest. The fire's still burning.")
		"morwen":
			if not s.has(HERBALIST_MET):
				k.say(morwen, "Na sieh an, jemand wagt sich so tief in den Wald. Ich bin Morwen, ich sammle hier Kräuter.", "Well, well, someone dares to come this deep into the woods. I'm Morwen, I gather herbs here.")
				k.say(morwen, "Am Feuer bist du sicher: Der Rauch meiner Kräuter hält die Biester fern.", "You're safe by the fire: the smoke of my herbs keeps the beasts away.")
				k.say(morwen, "Im Norden haust Grimmzahn, der Leitwolf. Groß wie ein Pony und doppelt so bösartig. Nimm das hier mit.", "In the north lives Grimfang, the alpha wolf. Big as a pony and twice as vicious. Take this with you.")
				k.give("remedy", 1)
				k.flag(HERBALIST_MET)
				smoke_against_krogg(k, s)
				k.say_t(morwen, HERBALIST_HERBS)
				k.shop(HERBALIST_STOCK, true)
			elif wants_smoke(s):
				smoke_against_krogg(k, s)
				k.say_t(morwen, HERBALIST_HERBS)
				k.shop(HERBALIST_STOCK, true)
			else:
				if s.has(GRIMFANG_DEFEATED): k.say(morwen, "Ohne Grimmzahn ist der Wald ruhiger geworden. Brauchst du Tränke?", "The woods are quieter without Grimfang. Need potions?")
				else: k.say(morwen, "Brauchst du Tränke? Für Grimmzahn wirst du sie brauchen.", "Need potions? You'll need them for Grimfang.")
				k.say_t(morwen, HERBALIST_HERBS)
				k.shop(HERBALIST_STOCK, true)
		"grimfang":
			k.narrate("Ein gewaltiger Wolf mit narbigem Fell tritt aus dem Schatten. Seine Augen glühen rot.", "A huge wolf with a scarred coat steps out of the shadows. Its eyes glow red.")
			k.fight("dire_wolf", GRIMFANG_DEFEATED)
			k.narrate("Grimmzahn bricht zusammen. Für einen Moment wird es ganz still im Wald.", "Grimfang collapses. For a moment the forest falls completely silent.")
		"krogg":
			k.say(krogg, "WER STÖRT KROGG? Krogg zermalmt dich!", "WHO DISTURBS KROGG? Krogg will crush you!")
			k.say(krogg, "Schlüssel gehört Krogg! Grak sagt: niemand kommt durch!", "Key belongs to Krogg! Grak says: nobody gets through!")
			k.fight("bugbear", KROGG_DEFEATED)
			k.narrate("Krogg sinkt zu Boden. Ein rostiger Schlüssel fällt aus seinem Gürtel.", "Krogg sinks to the ground. A rusty key falls from his belt.")
		"grak":
			grak_talk(k, s)
		"lyra_cave":
			if s.has(LYRA_RESCUED): pass
			elif not s.has(GRAK_DEFEATED): grak_talk(k, s)
			else:
				# [356.ketten]; a game saved between Grak and Lyra has no key: the chains open all the same
				if s.anzahl("grak_key") > 0: k.take("grak_key")
				k.narrate("Der Schlüssel dreht sich schwer. Die Ketten fallen klirrend zu Boden.", "The key turns stiffly. The chains fall clattering to the floor.")
				k.say(lyra, "Du hast Grak besiegt! Ich bin Lyra, Priesterin des Morgenlichts.", "You defeated Grak! I'm Lyra, priestess of the Dawnlight.")
				k.say(lyra, "Sie wollten mich und das Amulett zu jemandem bringen … zum »Grauen Propheten«.", "They were going to take me and the amulet to someone… to the “Gray Prophet”.")
				k.say(lyra, "Ich kehre sofort zum Tempel zurück. Bitte bring das Amulett zu Ältestem Aldric!", "I'll return to the temple at once. Please take the amulet to Elder Aldric!")
				k.say(lyra, "Nimm dieses Weihwasser. Gegen Untote wirkt es Wunder.", "Take this holy water. It works wonders against the undead.")
				k.give("holy_water", 2)
				# [356.lyra.segen]: heals fully; then she walks to the hall's way out (the closing line is gone: one sees it)
				k.narrate("Lyra legt dir die Hand auf die Stirn. Warmes Licht fließt durch dich.", "Lyra lays her hand on your brow. Warm light flows through you.")
				k.say(lyra, "Das Morgenlicht vergisst niemanden, der ihm dient.", "The Dawnlight forgets no one who serves it.")
				k.heal()
				k.flag(LYRA_RESCUED)
	return k.befehle

# [139.rowena.fleisch] vor der Theke, wenn der Held rohes Fleisch traegt
static func counter(k: Skript, s: Zustand) -> void:
	if s.anzahl("raw_meat") > 0: k.say(rowena, "Frisches Fleisch aus dem Wald? Gib her, daraus wird morgen der Eintopf im Greif.", "Fresh meat from the woods? Hand it over – it'll be tomorrow's stew at the Griffin.")
	k.tavern()

static func wants_smoke(s: Zustand) -> bool: return s.has(HUNTER_MET) and not s.has(KROGG_DEFEATED) and not s.has(SMOKE_GIVEN)

static func kapitel(s: Zustand) -> int: return 2 if s.has(CHAPTER2_STARTED) else 1

# beim Betreten einer Karte (MapDef.onEnter)
static func betreten(karte_id: String, s: Zustand) -> Array:
	var k := Skript.new()
	match karte_id:
		"inn": intro(k, s)
		"cave":
			if not s.has("cave_seen"):
				k.narrate("Ein modriger Geruch schlägt dir entgegen. Irgendwo in der Tiefe tropft Wasser … und etwas lacht.", "A musty smell hits you. Somewhere in the depths, water drips… and something laughs.")
				k.flag("cave_seen")
	return k.befehle

# auf einer Kachel (MapDef.triggers): vor Graks Halle spricht Grak, solange er lebt
static func ausloeser(karte_id: String, t: Vector2i, s: Zustand) -> Array:
	var k := Skript.new()
	if karte_id == "cave" and t.y == 4 and t.x in [10, 11] and not s.has(GRAK_DEFEATED): grak_talk(k, s)
	return k.befehle

# Gasthaus beim Betreten (Story.inn onEnter): Rowena weckt den Helden; Tipp nur fuer Touch (Godot hat kein Steuerkreuz, 280)
static func intro(k: Skript, s: Zustand) -> void:
	if s.has(INTRO_DONE): return
	k.say(rowena, "Na, endlich wach, {name}? Du hast geschlafen wie ein Stein.", "Well, finally awake, {name}? You slept like a log.")
	k.say(rowena, "Schlimme Zeiten sind das. Seit Wochen überfallen Goblins die Händler auf der Waldstraße.", "These are dark times. For weeks, goblins have been raiding the merchants on the forest road.")
	k.say(rowena, "Und letzte Nacht haben sie Schwester Lyra aus dem Tempel verschleppt – und das heilige Sonnenamulett gleich mit!", "And last night they dragged Sister Lyra out of the temple, and took the holy Sun Amulet too!")
	k.say(rowena, "Ältester Aldric sucht verzweifelt nach Hilfe. Sein Haus liegt unten links am Dorfplatz. Geh zu ihm!", "Elder Aldric is desperate for help. His house is at the bottom left of the village square. Go and see him!")
	# [280.tipp]
	k.narrate("Tipp: Zieh den Finger über das Bild, um zu laufen, oder tippe dorthin, wo du hinwillst. Tippe auf Leute und Dinge, um mit ihnen zu sprechen oder sie zu untersuchen. Der Beutel oben öffnet das Menü.", "Tip: drag your finger across the screen to walk, or tap where you want to go. Tap people and things to talk to them or examine them. The bag at the top opens the menu.")
	k.flag(INTRO_DONE)

static func ziel(s: Zustand) -> Dictionary:
	if s.has(CHAPTER1_DONE): return {"de": "Kapitel 1 abgeschlossen! Erkunde die Welt und stärke deinen Helden.", "en": "Chapter 1 complete! Explore the world and strengthen your hero."}
	if s.has(GRAK_DEFEATED) and s.has(LYRA_RESCUED): return {"de": "Bring das Sonnenamulett zu Ältestem Aldric nach Bornim.", "en": "Bring the Sun Amulet to Elder Aldric in Bornim."}
	if s.has(GRAK_DEFEATED): return {"de": "Befreie Schwester Lyra in Graks Halle.", "en": "Free Sister Lyra in Grak's hall."}
	if s.has(GATE_OPEN): return {"de": "Stelle dich Hauptmann Grak hinter dem Gitter.", "en": "Face Captain Grak beyond the gate."}
	if s.has(KROGG_DEFEATED): return {"de": "Öffne das Gitter in der Mitte der Höhle mit dem rostigen Schlüssel.", "en": "Open the gate in the middle of the cave with the rusty key."}
	if s.has("cave_seen"): return {"de": "Finde den Schlüssel zu Graks Halle. Vielleicht trägt ihn einer seiner Schergen.", "en": "Find the key to Grak's hall. Perhaps one of his henchmen carries it."}
	if s.has(QUEST_STARTED) and not s.has(BARRIER_OPEN): return {"de": "Lass dir von Wache Jorin den Schlagbaum am Nordweg öffnen.", "en": "Ask Guard Jorin to raise the barrier on the north road."}
	if s.has(QUEST_STARTED): return {"de": "Durchquere den Flüsterwald nach Norden und finde die Blutzahnhöhle.", "en": "Cross the Whisperwood to the north and find the Bloodfang Cave."}
	return {"de": "Sprich mit Ältestem Aldric. Sein Haus liegt unten links am Dorfplatz.", "en": "Talk to Elder Aldric. His house is at the bottom left of the village square."}

static func elder_talk(k: Skript, s: Zustand) -> void:
	if not s.has(QUEST_STARTED):
		k.say(aldric, "Du bist also {name}. Rowena sagt, du verstehst dich aufs Kämpfen.", "So you're {name}. Rowena tells me you know how to fight.")
		k.say(aldric, "Der Blutzahn-Stamm haust in einer Höhle am Nordende des Flüsterwalds. Früher waren diese Goblins feige.", "The Bloodfang tribe lives in a cave at the northern end of the Whisperwood. Those goblins used to be cowards.")
		k.say(aldric, "Doch nun führt sie ein Hobgoblin namens Grak – grausam und gerissen.", "But now they're led by a hobgoblin called Grak, cruel and cunning.")
		k.say(aldric, "Sie haben Schwester Lyra entführt und das Sonnenamulett gestohlen. Seit hundert Jahren schützt es Bornim vor der Finsternis.", "They kidnapped Sister Lyra and stole the Sun Amulet. For a hundred years it has protected Bornim from the darkness.")
		k.say(aldric, "Bring beide zurück, und Bornim wird es dir nie vergessen. Nimm dies für die Reise.", "Bring them both back, and Bornim will never forget it. Take this for the road.")
		k.give("potion", 2)
		k.gold(50)
		k.say(aldric, "Wache Jorin öffnet dir den Schlagbaum am Nordweg. Möge das Licht dich leiten.", "Guard Jorin will raise the barrier on the north road for you. May the light guide you.")
		k.flag(QUEST_STARTED)
	# [68.aldric.lager]
	elif s.has(CAMP_TOLD):
		k.say(aldric, "Lyra hat mir vom Lager erzählt. Wenn dort Leute aus der Gegend festsitzen, kann Bornim nicht einfach wegsehen.", "Lyra told me about the camp. If people from these parts are held there, Bornim cannot simply look away.")
	elif s.has(CHAPTER1_DONE):
		k.say(aldric, "Ruh dich aus, {name}. Der Graue Prophet wird nicht lange warten …", "Rest now, {name}. The Gray Prophet won't wait long…")
	elif s.has(GRAK_DEFEATED) and s.has(LYRA_RESCUED):
		k.say(aldric, "{name}! Lyra ist zurück, und du bringst das Sonnenamulett! Du hast es tatsächlich geschafft!", "{name}! Lyra is back, and you've brought the Sun Amulet! You actually did it!")
		k.take("sun_amulet")
		k.say(aldric, "Und was ist das für ein Brief? … Ein graues Auge als Siegel.", "And what is this letter? …Sealed with a gray eye.")
		k.say(aldric, "»Bringt mir das Amulett und die Priesterin. Der Tag der Asche naht. – Der Graue Prophet«", "“Bring me the amulet and the priestess. The Day of Ashes approaches. – The Gray Prophet”")
		k.say(aldric, "Der Graue Prophet … ich dachte, das sei nur eine Geschichte, um Kinder zu erschrecken.", "The Gray Prophet… I thought that was just a tale to frighten children.")
		k.say(aldric, "Wenn er hinter all dem steckt, war Grak erst der Anfang. Nimm diesen Ring. Er hat schon meinem Vater gute Dienste geleistet.", "If he is behind all this, Grak was only the beginning. Take this ring. It served my father well.")
		k.give("ring_protection")
		k.gold(200)
		# [68.aldric]
		k.say(aldric, "Morgen bei Sonnenaufgang legt Lyra das Amulett zurück auf den Altar. Ganz Bornim wird dort sein, und du gehörst in die erste Reihe.", "Tomorrow at sunrise Lyra will lay the amulet back on the altar. All of Bornim will be there, and you belong in the front row.")
		k.flag(CHAPTER1_DONE)
		k.chapter_end()
		temple_morning(k, s)
	elif s.has(GRAK_DEFEATED):
		k.say(aldric, "Grak ist besiegt? Wunderbar! Aber … wo ist Lyra? Hast du sie in der Höhle nicht gefunden?", "Grak is defeated? Wonderful! But… where is Lyra? Didn't you find her in the cave?")
	else:
		k.say(aldric, "Die Blutzahnhöhle liegt am Nordende des Flüsterwalds. Sei vorsichtig, {name}.", "The Bloodfang Cave lies at the northern end of the Whisperwood. Be careful, {name}.")
		k.say(aldric, "Wenn du verletzt bist, geh zu Bruder Osric in den Tempel. Und Thessa verkauft gute Ausrüstung.", "If you're hurt, go to Brother Osric at the temple. And Thessa sells good equipment.")

static func grak_talk(k: Skript, s: Zustand) -> void:
	k.say(grak, "Ein Menschlein? In MEINER Halle?", "A little human? In MY hall?")
	k.say(grak, "Der Prophet zahlt in Gold für jede Seele, die ich ihm bringe. Die Priesterin gehört schon ihm.", "The Prophet pays in gold for every soul I bring him. The priestess already belongs to him.")
	k.say(grak, "Und du wirst die nächste sein!", "And you'll be next!")
	k.fight("hobgoblin_captain", GRAK_DEFEATED)
	k.say(grak, "Unmöglich … der Prophet … wird euch … alle …", "Impossible… the Prophet… will… all of you…")
	k.narrate("Grak bricht zusammen. Bei ihm findest du das Sonnenamulett und einen versiegelten Brief.", "Grak collapses. On him you find the Sun Amulet and a sealed letter.")
	k.say(lyra, "Hier drüben! Bitte, hilf mir!", "Over here! Please, help me!")

static func krogg_tip(k: Skript, s: Zustand) -> void:
	k.say(garrick, "Ich habe Goblins belauscht. Ihr Grottenschrat Krogg trägt den Schlüssel zu Graks Halle.", "I overheard some goblins. Their bugbear Krogg carries the key to Grak's hall.")
	k.say(garrick, "Er haust im Ostflügel der Höhle. Ruh dich vorher gut aus!", "He lurks in the east wing of the cave. Rest well before you face him!")
	# D4.1: the way to Krogg leads past Morwen
	k.say(garrick, "Geh nicht mit leeren Händen zu ihm. Morwen, die Kräuterfrau im Tiefen Flüsterwald, weiß, wie man so einem den ersten Hieb nimmt.", "Don't go to him empty-handed. Morwen, the herbalist in the Deep Whisperwood, knows how to rob one like him of his first strike.")
	if s.stufe() < KROGG_WARN_BELOW:
		k.say(garrick, "Und ehrlich, {name}: So wie du jetzt aussiehst, legt Krogg dich mit einem Schlag um. Sammel erst ein paar Narben im Tiefen Flüsterwald.", "And honestly, {name}: the way you look now, Krogg will knock you down with a single blow. Gather a few scars in the Deep Whisperwood first.")
	k.flag(KROGG_HINT)

static func smoke_against_krogg(k: Skript, s: Zustand) -> void:
	if not wants_smoke(s): return
	k.say(morwen, "Krogg? Grottenschrate schlagen aus dem Dunkel zu, und der erste Hieb ist der schlimmste. Aber ihre Nasen sind fein.", "Krogg? Bugbears strike from the dark, and the first blow is the worst. But their noses are keen.")
	k.say(morwen, "Wirf ihm das hier vor die Füße, sobald er auftaucht. Der Rauch beißt in den Augen, und sein Hieb geht ins Leere.", "Throw this at his feet as soon as he shows up. The smoke stings the eyes, and his blow goes astray.")
	k.give(SMOKE_BUNDLE, 1)
	k.flag(SMOKE_GIVEN)

static func camp_lines(k: Skript, s: Zustand) -> void:
	# [68.lyra.1]
	k.say(lyra, "Ich verdanke dir mein Leben, {name}. Und Bornim sein Licht.", "I owe you my life, {name}. And Bornim its light.")
	# [68.lyra.2]
	k.say(lyra, "Graks Leute sprachen von einem Lager im Süden. Dort brachten sie, wen sie nicht selbst behalten wollten.", "Grak's men spoke of a camp in the south. That is where they took those they did not want to keep themselves.")
	# [68.lyra.3]
	k.say(lyra, "Ich weiß nicht, was er von mir will. Aber ich träume seit Wochen von grauer Asche.", "I do not know what he wants from me. But for weeks I have dreamed of gray ash.")
	k.flag(CAMP_TOLD)

static func temple_morning(k: Skript, s: Zustand) -> void:
	k.temple_scene()
	k.morning({"karte": "temple", "x": 4, "y": 3, "blick": "UP"})
	k.flag(TEMPLE_SEEN)
	camp_lines(k, s)

