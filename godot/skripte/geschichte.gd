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
## 632, 870.4 (STORY-BRS-HELD.md „Die Truhe in der Blutzahnhöhle“): die Truhe cave_3 gibt die Waffe zur stärksten Waffenfertigkeit
## des Helden, eine Magieschule darüber den Glutstab oder Morgenröte; bei Gleichstand gewinnt, was in TRUHE_FOLGE zuerst kommt.
## Gruppen ohne eigenes Stück (870.6: nur noch Wurfwaffen, bis es eine Grundform gibt) geben die nächststärkere mit Stück.
const TRUHE_FOLGE := ["Einhänder", "Zweihänder", "Stangenwaffen", "Stumpfe Waffen", "Dolche", "Bogen", "Armbrust", "Wurfwaffen",
	"Evokation", "Heilmagie", "Schutzmagie", "Illusion", "Beschwörung"]
const TRUHE_STUECK := {"Einhänder": "longsword_oakford", "Dolche": "rapier_whisper", "Stumpfe Waffen": "mace_of_dawn",
	"Zweihänder": "greatsword_nameless", "Stangenwaffen": "spear_wolf", "Bogen": "longbow_blackyew", "Armbrust": "crossbow_nightwatch",   # 870.6
	"Heilmagie": "mace_of_dawn", "Schutzmagie": "mace_of_dawn", "Evokation": "staff_of_embers", "Illusion": "staff_of_embers",
	"Beschwörung": "staff_of_embers"}
static func truhen_waffe(fert: Dictionary) -> String:
	var best := ""
	for f in TRUHE_FOLGE:
		if not TRUHE_STUECK.has(f): continue
		if best == "" or int(fert.get(f, 0)) > int(fert.get(best, 0)): best = f
	return String(TRUHE_STUECK[best])

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
const SHOP_STOCK := ["potion", "greater_potion", "superior_potion", "remedy", "bandage", "stamina_potion", "spark_potion", "alchemist_fire", "holy_water"]   # 842 Verband
const OSRIC_STOCK := ["bandage"]   # 842 (807 A): Verbände bei Osric und Thessa
const HERBALIST_STOCK := ["potion", "greater_potion", "remedy", "stamina_potion", "holy_water"]
const CHAPTER_END_TEXT := {"de": "Bornim feiert bis tief in die Nacht. Das Sonnenamulett ist zurück in Bornim, und Schwester Lyra ist in Sicherheit.\n\nDoch der Brief mit dem grauen Siegel lässt dich nicht los. Wer ist der Graue Prophet? Und was ist der Tag der Asche?\n\nENDE VON KAPITEL 1\n\nDu kannst weiterspielen, Monster jagen und deinen Helden verbessern.", "en": "Bornim celebrates late into the night. The Sun Amulet is back in Bornim, and Sister Lyra is safe.\n\nBut the letter with the gray seal won't leave your mind. Who is the Gray Prophet? And what is the Day of Ashes?\n\nEND OF CHAPTER 1\n\nYou can keep playing, hunt monsters and improve your hero."}

static func gespraech(id: String, s: Zustand) -> Array:
	var k := Skript.new()
	match id:
		"jorin":
			if not s.has(QUEST_STARTED):
				k.variante(s, "504.jorin.vor", jorin, [["Halt! Der Flüsterwald ist zu gefährlich geworden.", "Halt! The Whisperwood has become too dangerous."], ["Ohne Erlaubnis des Ältesten lasse ich niemanden hinaus.", "I'm not letting anyone out without the Elder's permission."]])
			elif not s.has(BARRIER_OPEN):
				k.say(jorin, "Der Älteste hat mir Bescheid gegeben. Dann wollen wir mal.", "The Elder told me about you. Well then, let's go.")
				k.flag(BARRIER_OPEN)
				k.narrate("Jorin löst das Seil, und der Schlagbaum schwingt knarrend nach oben. Der Weg nach Norden ist frei.", "Jorin releases the rope and the barrier swings up with a creak. The road north is open.")
				k.say(jorin, "Viel Glück da draußen, {name}! Tipp: Im hohen Gras lauern Monster. Bleib auf dem Weg, wenn du verletzt bist.", "Good luck out there, {name}! Tip: monsters lurk in the tall grass. Stay on the path when you're hurt.")
			elif not s.has(CHAPTER1_DONE):
				k.variante(s, "504.jorin.offen", jorin, [["Der Älteste hat mir Bescheid gegeben. Viel Glück da draußen, {name}!", "The Elder told me about you. Good luck out there, {name}!"], ["Tipp: Im hohen Gras lauern Monster. Bleib auf dem Weg, wenn du verletzt bist.", "Tip: monsters lurk in the tall grass. Stay on the path when you're hurt."]])
			else:
				k.variante(s, "504.jorin.danach", jorin, [["Seit du Grak besiegt hast, schlafe ich wieder ruhig. Danke, {name}!", "Since you beat Grak, I've been sleeping soundly again. Thanks, {name}!"]])
		"pim":
			if not s.has(CHAPTER1_DONE):
				k.variante(s, "504.pim.vor", pim, [["Papa sagt, Goblins haben Angst vor Feuer! Stimmt das?", "Dad says goblins are scared of fire! Is that true?"], ["Thessa verkauft Alchemistenfeuer. Damit kann man sogar zaubern, ohne Magier zu sein!", "Thessa sells alchemist's fire. You can do magic with it without even being a wizard!"]])
				if pim_fragbar(s): pim_probe(k, s)
			else:
				k.variante(s, "504.pim.danach", pim, [["Wenn ich groß bin, werde ich auch ein Held! Genau wie du!", "When I grow up I'll be a hero too! Just like you!"]])
		"bram":
			if not s.has(CHAPTER1_DONE):
				k.variante(s, "504.bram.vor", bram, [["Das Korn steht gut dieses Jahr. Wenn nur die Wölfe nicht wären – letzte Woche haben sie mir zwei Hühner geholt.", "The grain is doing well this year. If only it weren't for the wolves – last week they took two of my hens."], ["Wenn du im Wald Fleisch erbeutest: Am Lagerfeuer gebraten schmeckt es am besten. Und es macht stark!", "If you get meat in the forest, roast it over a campfire – that's when it tastes best. And it makes you strong!"]])
			else:
				k.variante(s, "504.bram.danach", bram, [["Seit die Goblins fort sind, schlafen sogar meine Hühner wieder ruhig.", "Now that the goblins are gone, even my hens sleep soundly again."]])
		"liska":
			if not s.has(CHAPTER1_DONE):
				k.variante(s, "504.liska.vor", liska, [["Bei dem Wetter trocknet die Wäsche im Nu. Hast du schon Thessas neue Ware gesehen?", "In this weather the laundry dries in no time. Have you seen Thessa's new goods yet?"], ["Auf dem Markt am Brunnen gibt es frisches Obst. Und die Kräuterstände riechen herrlich.", "There's fresh fruit at the market by the well. And the herb stalls smell wonderful."]])
			else:
				k.variante(s, "504.liska.danach", liska, [["Ganz Bornim spricht von dir! Ich habe gehört, du hast Grak mit bloßen Händen besiegt.", "All of Bornim is talking about you! I heard you beat Grak with your bare hands."]])
		"gwenna":
			if not s.has(CHAPTER1_DONE):
				k.variante(s, "504.gwenna.vor", gwenna, [["Früher konnte man nachts in Ruhe fischen. Jetzt heulen die Wölfe bis zum Morgengrauen.", "We used to fish here in peace at night. Now the wolves howl until dawn."]])
			else:
				k.variante(s, "504.gwenna.danach", gwenna, [["Der Held von Bornim! Ich hab's ja immer gewusst.", "The hero of Bornim! I always knew it."]])
		"rowena":
			if not s.has(QUEST_STARTED):
				k.variante(s, "504.rowena.vor", rowena, [["Ältester Aldric wartet auf dich. Sein Haus liegt unten links am Dorfplatz.", "Elder Aldric is waiting for you. His house is at the bottom left of the village square."]])
				counter(k, s)
			elif not s.has(CHAPTER1_DONE):
				k.variante(s, "504.rowena.unterwegs", rowena, [["Pass auf dich auf, {name}. Wenn du verletzt bist: Bruder Osric im Tempel heilt jeden, der darum bittet.", "Take care, {name}. If you're hurt, Brother Osric at the temple heals anyone who asks."]])
				counter(k, s)
			# [68.rowena.lager]
			elif s.has(CAMP_TOLD):
				k.variante(s, "504.rowena.lager", rowena, [["Ein Lager im Süden? Die Fuhrleute meiden die Südstraße seit dem Frühjahr. Jetzt weiß ich vielleicht, warum.", "A camp in the south? The carters have avoided the south road since spring. Now I may know why."]])
				counter(k, s)
			else:
				k.variante(s, "504.rowena.held", rowena, [["Für den Helden von Bornim geht das Bier heute aufs Haus!", "Drinks are on the house for the hero of Bornim tonight!"]])
				counter(k, s)
		"borin":
			k.variante(s, "504.borin", borin, [["Hrmpf. Ein Zwerg weiß so etwas: Skelette hassen Wuchtwaffen!", "Hrmph. A dwarf knows these things: skeletons hate bludgeoning weapons!"], ["Streitkolben, Hammer, sogar ein Stab – das zerschmettert ihre Knochen. Und heiliges Licht verbrennt alles Untote.", "Mace, hammer, even a staff will shatter their bones. And holy light burns all undead."]])
		"thessa":
			k.variante(s, "504.thessa.gruss", thessa, [["Willkommen in Thessas Kramladen! Was darf's sein?", "Welcome to Thessa's General Store! What can I get you?"]])
			k.shop(SHOP_STOCK)
			k.variante(s, "504.thessa.abschied", thessa, [["Komm bald wieder!", "Come again soon!"]])
		"aldric":
			elder_talk(k, s)
		"osric":
			if not s.has(LYRA_RESCUED):
				k.variante(s, "504.osric.gruss", osric, [["Willkommen im Tempel des Morgenlichts. Lass mich deine Wunden versorgen.", "Welcome to the Temple of the Dawnlight. Let me tend to your wounds."]])
			else:
				k.variante(s, "504.osric.gruss.danach", osric, [["Gesegnet seist du, {name}. Lass mich deine Wunden versorgen.", "Blessings upon you, {name}. Let me tend to your wounds."]])
			k.rest()
			k.variante(s, "504.osric.heilung", {}, [["Ein warmes Licht umhüllt dich. Leben und Mana sind wieder voll.", "A warm light surrounds you. Life and mana are full again."]])
			var laden := Skript.new()   # 842: Verbände kaufen, nur auf den Knopf (Heilen bleibt ein Tippen)
			laden.shop_nur(OSRIC_STOCK)
			Sprache.lade()
			k.knopf(Sprache.texte.get("ui", {}).get("buy", {"de": "Kaufen", "en": "Buy"}), laden.befehle)
			if not s.has(LYRA_RESCUED):
				k.variante(s, "504.osric.bitte", osric, [["Bitte … finde Schwester Lyra. Ohne sie und das Amulett ist dieser Tempel nur ein kalter Steinhaufen.", "Please… find Sister Lyra. Without her and the amulet, this temple is just a cold pile of stones."]])
		"lyra_temple":
			if not s.has(CHAPTER1_DONE):
				k.variante(s, "504.lyra.tempel", lyra, [["Danke, dass du mich gerettet hast, {name}. Bitte bring das Amulett zu Ältestem Aldric!", "Thank you for rescuing me, {name}. Please take the amulet to Elder Aldric!"]])
			elif not s.has(CAMP_TOLD):
				# the morning was cut short (the game closed during the scene) or the chapter ended before 68: Lyra tells it now
				camp_lines(k, s)
			else:
				k.variante(s, "504.lyra.tempel.danach", lyra, [["Der Graue Prophet … Ich habe seine Stimme in meinen Träumen gehört. Wir müssen vorbereitet sein.", "The Gray Prophet… I've heard his voice in my dreams. We must be prepared."]])
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
				k.variante(s, "504.garrick.rast", garrick, [["Du siehst aus, als könntest du eine Rast gebrauchen. Das Feuer brennt noch.", "You look like you could use a rest. The fire's still burning."]])
		"morwen":
			if not s.has(HERBALIST_MET):
				k.say(morwen, "Na sieh an, jemand wagt sich so tief in den Wald. Ich bin Morwen, ich sammle hier Kräuter.", "Well, well, someone dares to come this deep into the woods. I'm Morwen, I gather herbs here.")
				k.say(morwen, "Am Feuer bist du sicher: Der Rauch meiner Kräuter hält die Biester fern.", "You're safe by the fire: the smoke of my herbs keeps the beasts away.")
				k.say(morwen, "Im Norden haust Grimmzahn, der Leitwolf. Groß wie ein Pony und doppelt so bösartig. Nimm das hier mit.", "In the north lives Grimfang, the alpha wolf. Big as a pony and twice as vicious. Take this with you.")
				k.give("remedy", 1)
				k.flag(HERBALIST_MET)
				smoke_against_krogg(k, s)
				k.variante(s, "504.morwen.kraeuter", morwen, [[HERBALIST_HERBS["de"], HERBALIST_HERBS["en"]]])
				k.shop(HERBALIST_STOCK, true)
			elif wants_smoke(s):
				smoke_against_krogg(k, s)
				k.variante(s, "504.morwen.kraeuter", morwen, [[HERBALIST_HERBS["de"], HERBALIST_HERBS["en"]]])
				k.shop(HERBALIST_STOCK, true)
			else:
				if s.has(GRIMFANG_DEFEATED): k.variante(s, "504.morwen.wieder.danach", morwen, [["Ohne Grimmzahn ist der Wald ruhiger geworden. Brauchst du Tränke?", "The woods are quieter without Grimfang. Need potions?"]])
				else: k.variante(s, "504.morwen.wieder", morwen, [["Brauchst du Tränke? Für Grimmzahn wirst du sie brauchen.", "Need potions? You'll need them for Grimfang."]])
				k.variante(s, "504.morwen.kraeuter", morwen, [[HERBALIST_HERBS["de"], HERBALIST_HERBS["en"]]])
				k.shop(HERBALIST_STOCK, true)
		"grimfang":
			k.variante(s, "504.grimmzahn", {}, [["Ein gewaltiger Wolf mit narbigem Fell tritt aus dem Schatten. Seine Augen glühen rot.", "A huge wolf with a scarred coat steps out of the shadows. Its eyes glow red."]])
			k.fight("dire_wolf", GRIMFANG_DEFEATED)
			k.narrate("Grimmzahn bricht zusammen. Für einen Moment wird es ganz still im Wald.", "Grimfang collapses. For a moment the forest falls completely silent.")
		"krogg":
			k.variante(s, "504.krogg", krogg, [["WER STÖRT KROGG? Krogg zermalmt dich!", "WHO DISTURBS KROGG? Krogg will crush you!"], ["Schlüssel gehört Krogg! Grak sagt: niemand kommt durch!", "Key belongs to Krogg! Grak says: nobody gets through!"]])
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
	if s.anzahl("raw_meat") > 0: k.variante(s, "504.rowena.fleisch", rowena, [["Frisches Fleisch aus dem Wald? Gib her, daraus wird morgen der Eintopf im Greif.", "Fresh meat from the woods? Hand it over – it'll be tomorrow's stew at the Griffin."]])
	k.tavern()

# wer zu sehen ist (Npc.visible in Story.kt); Lyras Abgang aus der Halle (Leave 10/7 -> LYRA_GONE) folgt mit der Hoehle
# ---------------------------------------------------------------- 842 Pim heimschicken (807 A, STORY-K1-FERTIGKEITEN.md „Überreden“)
# tagsueber im Gespraech nach [504.pim.vor] ein Knopf mit Probe auf Ueberreden, ein Versuch je Tag; gelingt es, geht Pim fuer den Rest
# des Tages heim (Leute.frueh_heim) und die Mutter dankt beim naechsten Klopfen am Tag einmal ([807.pim.dank], Flagge PIM_DANK fuer
# den Ruf je Person, DESIGN-BRS 9, sobald es ihn gibt: 447.4.1)
const PIM_HEIM := "pim_sent_home"          # einmal gelungen
const PIM_DANK := "pim_mother_thanked"     # die Mutter hat gedankt
const PIM_WAHL := {"de": "Schick Pim heim (Überreden)", "en": "Send Pim home (Persuasion)"}   # [807.pim.wahl]
const PIM_JA := [   # [807.pim.ja]
	[["Na gut. Aber nur, weil du es bist.", "Fine. But only because it's you."], ["Pim trottet heim, mit einem letzten Blick zum Schlagbaum.", "Pim trudges home, with one more glance back at the barrier.", true]],
	[["Mama schimpft bestimmt …", "Mom's going to scold me…"], ["Erzählst du mir morgen von den Goblins? Versprochen?", "Will you tell me about the goblins tomorrow? Promise?"]],
	[["Wenn du es sagst, {name}.", "If you say so, {name}."], ["Er rennt los, als wären die Wölfe schon hinter ihm.", "He runs off as if the wolves were already behind him.", true]]]
const PIM_NEIN := [   # [807.pim.nein]
	[["Ich bin doch schon groß! Und Jorin hält eh Wache.", "I'm big already! And Jorin's keeping watch anyway."]],
	[["Nur noch ein bisschen. Ich will sehen, ob ein Goblin kommt.", "Just a little longer. I want to see if a goblin comes."]],
	[["Du klingst wie Mama.", "You sound like Mom."], ["Er verschränkt die Arme und rührt sich nicht.", "He folds his arms and doesn't budge.", true]]]
const PIM_DANK_TEXT := {"de": "„Pim kam heim, ganz zahm. Was du ihm auch gesagt hast: danke, {name}.“", "en": "“Pim came home, meek as a lamb. Whatever you told him: thank you, {name}.”"}   # [807.pim.dank]
const PIMS_TUER := Vector2i(13, 22)

static func pim_heute(s: Zustand) -> String: return "pim_home_%d" % s.tag          # heute heimgeschickt
static func pim_versucht(s: Zustand) -> String: return "pim_tried_%d" % s.tag      # heute vergeblich versucht
static func pim_fragbar(s: Zustand) -> bool:
	return Licht.nacht_um(s.minuten) <= Licht.NACHT_AB and not s.has(pim_heute(s)) and not s.has(pim_versucht(s))

static func pim_probe(k: Skript, s: Zustand) -> void:
	var ja := Skript.new()
	ja.flag(pim_heute(s))
	ja.flag(PIM_HEIM)
	ja.variante(s, "807.pim.ja", pim, PIM_JA[0], PIM_JA.slice(1))
	var nein := Skript.new()
	nein.flag(pim_versucht(s))
	nein.variante(s, "807.pim.nein", pim, PIM_NEIN[0], PIM_NEIN.slice(1))
	k.probe("Überreden", "Pim", PIM_WAHL, ja.befehle, nein.befehle)

## wer heute frueher heimgeht und drinnen bleibt (Leute.plan_jetzt)
static func frueh_heim(id: String, s: Zustand) -> bool: return id == "pim" and s.has(pim_heute(s))

## Chance einer Probe im Gespraech in Prozent (werte.json „proben“ <fert>_basis, _je_punkt, _gegen; begrenzt auf min bis max)
static func probe_chance(fert: String, wert: int, gegen: String) -> int:
	var p: Dictionary = BrsHeld.lade().get("proben", {})
	var n := fert.to_lower().replace("ä", "ae").replace("ö", "oe").replace("ü", "ue").replace("ß", "ss")
	var c := float(p.get(n + "_basis", 0)) + float(p.get(n + "_je_punkt", 0)) * wert - float((p.get(n + "_gegen", {}) as Dictionary).get(gegen, 0))
	return clampi(roundi(c), int(p.get("min", 5)), int(p.get("max", 95)))

static func sichtbar(id: String, s: Zustand) -> bool:
	match id:
		"lyra_temple": return s.has(LYRA_RESCUED)
		"grimfang": return not s.has(GRIMFANG_DEFEATED)
		"krogg": return not s.has(KROGG_DEFEATED)
		"grak": return not s.has(GRAK_DEFEATED)
		"lyra_cave": return not s.has(LYRA_GONE)
	return true

# das Gitter in der Hoehle (Game.gate): mit dem rostigen Schluessel auf, sonst verschlossen
static func gitter(s: Zustand) -> Array:
	var k := Skript.new()
	if s.has(GATE_OPEN): pass
	elif s.anzahl("rusty_key") > 0:
		k.take("rusty_key")
		k.flag(GATE_OPEN)
		k.narrate("Du steckst den rostigen Schlüssel ins Schloss. Mit lautem Quietschen öffnet sich das Gitter.", "You put the rusty key into the lock. With a loud screech, the gate swings open.")
	else: k.variante(s, "504.gitter", {}, [["Ein schweres Eisengitter. Es ist verschlossen.", "A heavy iron gate. It's locked."]])
	return k.befehle

static func wants_smoke(s: Zustand) -> bool: return s.has(HUNTER_MET) and not s.has(KROGG_DEFEATED) and not s.has(SMOKE_GIVEN)

static func kapitel(s: Zustand) -> int: return 2 if s.has(CHAPTER2_STARTED) else 1
# 538 (Story.levelCap): hoechste Stufe im laufenden Kapitel; darueber sammelt der Held keine Erfahrung (Battle.kt, Game.begin)

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

# Gasthaus beim Betreten (Story.inn onEnter): Rowena weckt den Helden; der Tipp zur Steuerung (280; 663: nur Touch)
static func intro(k: Skript, s: Zustand) -> void:
	if s.has(INTRO_DONE): return
	k.say(rowena, "Na, endlich wach, {name}? Du hast geschlafen wie ein Stein.", "Well, finally awake, {name}? You slept like a log.")
	k.say(rowena, "Schlimme Zeiten sind das. Seit Wochen überfallen Goblins die Händler auf der Waldstraße.", "These are dark times. For weeks, goblins have been raiding the merchants on the forest road.")
	k.say(rowena, "Und letzte Nacht haben sie Schwester Lyra aus dem Tempel verschleppt – und das heilige Sonnenamulett gleich mit!", "And last night they dragged Sister Lyra out of the temple, and took the holy Sun Amulet too!")
	k.say(rowena, "Ältester Aldric sucht verzweifelt nach Hilfe. Sein Haus liegt unten links am Dorfplatz. Geh zu ihm!", "Elder Aldric is desperate for help. His house is at the bottom left of the village square. Go and see him!")
	# [280.tipp]
	k.narrate("Tipp: Zieh den Finger über das Bild, um zu laufen, oder tippe dorthin, wo du hinwillst. Tippe auf Leute und Dinge, um mit ihnen zu sprechen oder sie zu untersuchen. Der Beutel oben öffnet das Menü.", "Tip: drag your finger across the screen to walk, or tap where you want to go. Tap people and things to talk to them or examine them. The bag at the top opens the menu.")
	k.flag(INTRO_DONE)

# 540 (Story.southEdge, 67, 68p): was der Held am Suedrand des Dorfs denkt, nach dem Stand der Geschichte; je Abschnitt beim ersten
# Mal der lange Satz, danach der kurze; nach Lyras Lager (CAMP_TOLD) immer derselbe: Kapitel 2 folgt. Gemerkt im Spielstand
static func suedrand(s: Zustand) -> Dictionary:
	var teil: String; var lang: Dictionary; var kurz: Dictionary
	if s.has(CAMP_TOLD):
		teil = "camp"
		lang = {"de": "Der Weg nach Süden ist noch nicht begehbar. Kapitel 2 folgt mit einem späteren Update.", "en": "The road south is not passable yet. Chapter 2 is coming in a later update."}
		kurz = lang
	elif s.has(CHAPTER1_DONE):
		teil = "after"
		lang = {"de": "Der Brief mit dem grauen Siegel lässt dich nicht los. Die Antwort liegt nicht im Süden.", "en": "The letter with the gray seal won't leave your mind. The answer doesn't lie in the south."}
		kurz = {"de": "Die Antwort liegt nicht im Süden.", "en": "The answer doesn't lie in the south."}
	elif s.has(QUEST_STARTED):
		teil = "quest"
		lang = {"de": "Lyra ist irgendwo im Norden. Der Weg nach Süden kann warten.", "en": "Lyra is somewhere in the north. The road south can wait."}
		kurz = {"de": "Der Weg nach Süden kann warten.", "en": "The road south can wait."}
	else:
		teil = "before"
		lang = {"de": "Du bist von Süden gekommen, um hier zu rasten. Weiterziehen kannst du später – erst willst du wissen, was in Bornim geschehen ist.",
			"en": "You came from the south to rest here. You can move on later – first you want to know what happened in Bornim."}
		kurz = {"de": "Erst willst du wissen, was in Bornim geschehen ist.", "en": "First you want to know what happened in Bornim."}
	var gesehen := "south_edge_" + teil
	if s.has(gesehen): return {"text": kurz, "kurz": true}
	s.setze(gesehen)
	return {"text": lang, "kurz": false}

# 540 (Game.barrier): Anstossen am Schlagbaum, vor und nach Aldrics Erlaubnis
const BARRIER_DOWN := {"de": "Der Schlagbaum ist unten. Ohne Erlaubnis des Ältesten kommst du hier nicht durch.", "en": "The barrier is down. You can't pass without the Elder's permission."}
const BARRIER_QUEST := {"de": "Der Schlagbaum ist unten. Sprich mit Wache Jorin, damit er ihn öffnet.", "en": "The barrier is down. Talk to Jorin the guard so he raises it."}
static func schlagbaum(s: Zustand) -> Dictionary: return BARRIER_QUEST if s.has(QUEST_STARTED) else BARRIER_DOWN

# 540 (Story.village lockedDoor, 73b): was hinter einer Tuer gesagt wird, wenn es vom Stand der Geschichte abhaengt; {} = wie in
# karten.json (Stand zu Beginn). Bisher nur 12/5 nach Kapitel 1
# 629.1 (Homer 07.11., [629.sprecher] in STORY-K1-WELT.md; Chef 611: „Beim Klopfen an Türen steht nicht da, wessen Haus es ist oder
# wer spricht“): gesprochene Klopfzeilen haben den Namen der Stimme wie jede Dorfzeile, ohne Anfuehrungszeichen; Erzaehltes (Tag bei
# Gwenna und Dorran) bleibt ohne Namen
const KLOPF_STIMME := {
	Vector2i(12, 5): {"de": "Bäcker Edrik", "en": "Edrik the Baker"},
	Vector2i(23, 5): {"de": "Der alte Kael", "en": "Old Kael"},
	Vector2i(5, 14): {"de": "Gwenna", "en": "Gwenna"},
	Vector2i(30, 13): {"de": "Schmied Dorran", "en": "Dorran the Smith"},
	Vector2i(13, 22): {"de": "Pims Mutter", "en": "Pim's Mother"},
}
static func klopf_sprecher(karte_id: String, t: Vector2i, liste: Array) -> Array:
	var wer = KLOPF_STIMME.get(t) if karte_id == "village" else null
	var r: Array = []
	for z in liste:
		var e: Dictionary = z.duplicate(true)
		var tx = e.get("text")
		if wer != null and tx is Dictionary and String(tx.get("de", "")).begins_with("„"):
			var d := String(tx.get("de", "")); var en := String(tx.get("en", ""))
			e["text"] = {"de": d.trim_prefix("„").trim_suffix("“"), "en": en.trim_prefix("“").trim_suffix("”")}
			e["wer"] = wer
		r.append(e)
	return r

static func klopfen(karte_id: String, t: Vector2i, s: Zustand) -> Dictionary:
	if karte_id == "village" and t == PIMS_TUER and pim_dankt(s): return PIM_DANK_TEXT   # 842 [807.pim.dank] statt [504.tuer.pim]
	if karte_id == "village" and t == Vector2i(12, 5) and s.has(CHAPTER1_DONE):
		return {"de": "„Du hast die Goblins vertrieben? … Morgen vielleicht. Heute nicht.“", "en": "“You drove off the goblins? … Tomorrow, maybe. Not today.”"}
	return {}

## 842: die Mutter dankt beim naechsten Klopfen am Tag nach dem ersten Erfolg, einmal (spiel.gd setzt danach PIM_DANK)
static func pim_dankt(s: Zustand) -> bool:
	return s.has(PIM_HEIM) and not s.has(PIM_DANK) and Licht.nacht_um(s.minuten) <= Licht.NACHT_AB

# 541 (Game.interact): was der Held sieht, wenn er ein Ding der Karte mit dem Knopf untersucht (Navigation.actionAt LOOK); {} = nichts.
# Zeichen wie Tile.ch; t fuer den Marktstand (drei Saetze je Lage), nachts fuer die Laterne, innen fuer die Bank
static func ansehen(zeichen: String, t: Vector2i, s: Zustand, nachts: bool, innen: bool) -> Dictionary:
	match zeichen:
		"w": return {"de": "Ein alter Brunnen. Das Wasser ist klar und kalt.", "en": "An old well. The water is clear and cold."}
		"Q": return {"de": "Regale voller Krimskrams.", "en": "Shelves full of odds and ends."}
		"m": return [{"de": "Ein Marktstand mit rotbackigen Äpfeln und frischem Gemüse.", "en": "A market stall with rosy apples and fresh vegetables."},
			{"de": "Bunte Stoffe und Wollknäuel liegen auf dem Stand aus.", "en": "Colorful cloth and balls of wool are laid out on the stall."},
			{"de": "Der Stand duftet nach Kräutern und getrockneten Pilzen.", "en": "The stall smells of herbs and dried mushrooms."}][posmod(t.x * 7 + t.y * 3, 3)]
		"l": return {"de": "Die Laterne brennt warm und hell.", "en": "The lantern burns warm and bright."} if nachts else {"de": "Eine Laterne. Abends zündet Jorin sie an.", "en": "A lantern. Jorin lights it in the evening."}
		"b": return {"de": "Ein Fass. Es riecht nach Apfelmost.", "en": "A barrel. It smells of cider."}
		"c": return {"de": "Das Korn steht hoch und golden. Bald ist Erntezeit.", "en": "The grain stands tall and golden. Harvest time is near."}
		"v": return {"de": "Kohl und Möhren, sorgfältig in Reihen gepflanzt.", "en": "Cabbages and carrots, carefully planted in rows."}
		"y": return {"de": "Ein Heuballen. Die Hühner scharren drumherum.", "en": "A bale of hay. The chickens scratch around it."}
		"q": return {"de": "Frisch gewaschene Wäsche flattert im Wind.", "en": "Freshly washed laundry flutters in the wind."}
		"Z": return {"de": "Das Feuer knackt im Herd. Über der Glut hängt ein rußiger Kessel.", "en": "The fire crackles in the hearth. A sooty pot hangs over the embers."}
		"n": return {"de": "Eine Bank, blank gesessen. Im Holz sind Namen eingeritzt.", "en": "A bench, worn smooth. Names are carved into the wood."} if innen else {"de": "Eine Bank zum Ausruhen. Von hier hat man den ganzen Dorfplatz im Blick.", "en": "A bench to rest on. From here you can see the whole village square."}
		"A": return {"de": "Das Sonnenamulett strahlt auf dem Altar.", "en": "The Sun Amulet shines on the altar."} if s.has(CHAPTER1_DONE) else {"de": "Auf dem Altar ist eine leere Halterung. Hier lag das Sonnenamulett.", "en": "There's an empty mount on the altar. This is where the Sun Amulet lay."}
	return {}

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
		k.variante(s, "504.aldric.lager", aldric, [["Lyra hat mir vom Lager erzählt. Wenn dort Leute aus der Gegend festsitzen, kann Bornim nicht einfach wegsehen.", "Lyra told me about the camp. If people from these parts are held there, Bornim cannot simply look away."]])
	elif s.has(CHAPTER1_DONE):
		k.variante(s, "504.aldric.ende", aldric, [["Ruh dich aus, {name}. Der Graue Prophet wird nicht lange warten …", "Rest now, {name}. The Gray Prophet won't wait long…"]])
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
		k.variante(s, "504.aldric.ohne.lyra", aldric, [["Grak ist besiegt? Wunderbar! Aber … wo ist Lyra? Hast du sie in der Höhle nicht gefunden?", "Grak is defeated? Wonderful! But… where is Lyra? Didn't you find her in the cave?"]])
	else:
		k.variante(s, "504.aldric.unterwegs", aldric, [["Die Blutzahnhöhle liegt am Nordende des Flüsterwalds. Sei vorsichtig, {name}.", "The Bloodfang Cave lies at the northern end of the Whisperwood. Be careful, {name}."], ["Wenn du verletzt bist, geh zu Bruder Osric in den Tempel. Und Thessa verkauft gute Ausrüstung.", "If you're hurt, go to Brother Osric at the temple. And Thessa sells good equipment."]])

static func grak_talk(k: Skript, s: Zustand) -> void:
	k.variante(s, "504.grak", grak, [["Ein Menschlein? In MEINER Halle?", "A little human? In MY hall?"], ["Der Prophet zahlt in Gold für jede Seele, die ich ihm bringe. Die Priesterin gehört schon ihm.", "The Prophet pays in gold for every soul I bring him. The priestess already belongs to him."], ["Und du wirst die nächste sein!", "And you'll be next!"]])
	k.fight("hobgoblin_captain", GRAK_DEFEATED)
	k.say(grak, "Unmöglich … der Prophet … wird euch … alle …", "Impossible… the Prophet… will… all of you…")
	k.narrate("Grak bricht zusammen. Bei ihm findest du das Sonnenamulett und einen versiegelten Brief.", "Grak collapses. On him you find the Sun Amulet and a sealed letter.")
	k.say(lyra, "Hier drüben! Bitte, hilf mir!", "Over here! Please, help me!")

static func krogg_tip(k: Skript, s: Zustand) -> void:
	# D4.1: the way to Krogg leads past Morwen
	k.variante(s, "504.garrick.krogg", garrick, [["Ich habe Goblins belauscht. Ihr Grottenschrat Krogg trägt den Schlüssel zu Graks Halle.", "I overheard some goblins. Their bugbear Krogg carries the key to Grak's hall."], ["Er haust im Ostflügel der Höhle. Ruh dich vorher gut aus!", "He lurks in the east wing of the cave. Rest well before you face him!"], ["Geh nicht mit leeren Händen zu ihm. Morwen, die Kräuterfrau im Tiefen Flüsterwald, weiß, wie man so einem den ersten Hieb nimmt.", "Don't go to him empty-handed. Morwen, the herbalist in the Deep Whisperwood, knows how to rob one like him of his first strike."]])
	if s.stufe() < KROGG_WARN_BELOW:
		k.variante(s, "504.garrick.warnung", garrick, [["Und ehrlich, {name}: So wie du jetzt aussiehst, legt Krogg dich mit einem Schlag um. Sammel erst ein paar Narben im Tiefen Flüsterwald.", "And honestly, {name}: the way you look now, Krogg will knock you down with a single blow. Gather a few scars in the Deep Whisperwood first."]])
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

