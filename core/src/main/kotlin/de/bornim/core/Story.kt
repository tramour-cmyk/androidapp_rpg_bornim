package de.bornim.core

/**
 * Chapter 1: "The Bloodfang Tribe". An original story in the spirit of classic
 * starter adventures: goblin raids, a kidnapped priestess, a stolen relic and a
 * shadowy mastermind behind it all.
 */
object Story {
    /** The player uses the classic D-pad instead of touch controls; set by the app, read by the waking tip (280.1). */
    @Volatile var classicControls = false

    // Flags
    const val INTRO_DONE = "intro_done"
    const val QUEST_STARTED = "quest_started"
    const val HUNTER_MET = "hunter_met"
    const val KROGG_DEFEATED = "krogg_defeated"
    const val GATE_OPEN = "gate_open"
    /** Jorin raised the barrier on the north road. */
    const val BARRIER_OPEN = "barrier_open"
    const val GRAK_DEFEATED = "grak_defeated"
    const val LYRA_RESCUED = "lyra_rescued"
    /** 356.1: freed, Lyra walked out of Grak's hall. */
    const val LYRA_GONE = "lyra_gone"
    const val CHAPTER1_DONE = "chapter1_done"
    /** 68: the temple scene has been shown (the morning after the amulet came back). */
    const val TEMPLE_SEEN = "temple_seen"
    /** 68j/68k: Lyra told the hero of the camp in the south; the chronicle carries it as a task. */
    const val CAMP_TOLD = "camp_told"
    const val GRIMFANG_DEFEATED = "grimfang_defeated"
    const val HERBALIST_MET = "hedda_met"
    /** D4.1: Garrick sent the hero to Morwen for help against Krogg. */
    const val KROGG_HINT = "krogg_hint"
    /** D4.1: Morwen gave the hero her smoke bundle against Krogg's first blow. */
    const val SMOKE_GIVEN = "smoke_given"
    /** D4.1: below this level Garrick warns the hero off Krogg. */
    const val KROGG_WARN_BELOW = 3
    /** Never set: doors that stay locked. */
    const val LOCKED = "locked_forever"
    /** Set when chapter 2 begins; until then the hero cannot rise above [CHAPTER1_LEVEL_CAP]. */
    const val CHAPTER2_STARTED = "chapter2_started"
    const val CHAPTER1_LEVEL_CAP = 6

    /** What Morwen sells; she also brews potions from ingredients. */
    private val HERBALIST_STOCK = listOf("potion", "greater_potion", "remedy", "stamina_potion", "holy_water")
    private val HERBALIST_HERBS = T(
        "Auf den bunten Blumenwiesen im Wald wachsen Heilkräuter – achte auf die hellgrünen Pflanzen und lauf einfach darüber. Was du pflückst, wächst am nächsten Tag nach. Bring sie mir, dann braue ich dir Tränke für ein paar Münzen. Fledermausflügel und Giftdrüsen nehme ich auch.",
        "Healing herbs grow in the colourful flower meadows of the forest – look for the light green plants and just walk over them. What you pick grows back the next day. Bring them to me and I'll brew you potions for a few coins. I'll take bat wings and venom glands too.",
    )

    /** D4.1: Morwen hands over her smoke bundle once, after Garrick was met and while Krogg lives. */
    fun wantsSmoke(s: GameState): Boolean = s.has(HUNTER_MET) && !s.has(KROGG_DEFEATED) && !s.has(SMOKE_GIVEN)

    /** Garrick on Krogg and Morwen (41, D4.1); from the first talk on until Krogg falls. */
    private fun ScriptBuilder.kroggTip(s: GameState) {
        say(garrick, "Ich habe Goblins belauscht. Ihr Grottenschrat Krogg trägt den Schlüssel zu Graks Halle.", "I overheard some goblins. Their bugbear Krogg carries the key to Grak's hall.")
        say(garrick, "Er haust im Ostflügel der Höhle. Ruh dich vorher gut aus!", "He lurks in the east wing of the cave. Rest well before you face him!")
        // D4.1: the way to Krogg leads past Morwen
        say(garrick, "Geh nicht mit leeren Händen zu ihm. Morwen, die Kräuterfrau im Tiefen Flüsterwald, weiß, wie man so einem den ersten Hieb nimmt.",
            "Don't go to him empty-handed. Morwen, the herbwoman in the Deep Whisperwood, knows how to take the first blow out of one like him.")
        if (s.hero.level < KROGG_WARN_BELOW)
            say(garrick, "Und ehrlich, {name}: So wie du jetzt aussiehst, legt Krogg dich mit einem Schlag um. Sammel erst ein paar Narben im Tiefen Flüsterwald.",
                "And honestly, {name}: the way you look now, Krogg will knock you down with a single blow. Gather a few scars in the Deep Whisperwood first.")
        flag(KROGG_HINT)
    }

    private fun ScriptBuilder.smokeAgainstKrogg(s: GameState) {
        if (!wantsSmoke(s)) return
        say(morwen, "Krogg? Grottenschrate schlagen aus dem Dunkel zu, und der erste Hieb ist der schlimmste. Aber ihre Nasen sind fein.",
            "Krogg? Bugbears strike from the dark, and the first blow is the worst. But their noses are keen.")
        say(morwen, "Wirf ihm das hier vor die Füße, sobald er auftaucht. Der Rauch beißt in den Augen, und sein Hieb geht ins Leere.",
            "Throw this at his feet as soon as he shows up. The smoke stings the eyes, and his blow goes astray.")
        give(SMOKE_BUNDLE, 1)
        flag(SMOKE_GIVEN)
    }

    /** D4.1: Morwen's smoke bundle; in the fight it takes Krogg's first blow (Jerry). */
    const val SMOKE_BUNDLE = "smoke_bundle"

    /** The chapter the hero is playing: it sets the level cap, the best loot and the gear limits. */
    fun chapter(s: GameState): Int = if (s.has(CHAPTER2_STARTED)) 2 else 1

    /** Highest level the hero can reach in the current chapter. Experience beyond it is not gathered. */
    fun levelCap(s: GameState): Int = if (s.has(CHAPTER2_STARTED)) Rules.MAX_LEVEL else CHAPTER1_LEVEL_CAP

    /** Whether the hero stands at the level cap of the chapter and gathers no further experience. */
    fun capped(s: GameState): Boolean = levelCap(s) < Rules.MAX_LEVEL && s.hero.level >= levelCap(s)

    val START = Place("inn", 8, 2, Facing.DOWN)
    val RESPAWN = Place("temple", 4, 4, Facing.UP)

    // Speakers
    private val rowena = T("Rowena", "Rowena")
    private val borin = T("Borin", "Borin")
    private val aldric = T("Ältester Aldric", "Elder Aldric")
    private val thessa = T("Thessa", "Thessa")
    private val osric = T("Bruder Osric", "Brother Osric")
    private val lyra = T("Lyra", "Lyra")
    private val jorin = T("Wache Jorin", "Guard Jorin")
    private val pim = T("Pim", "Pim")
    private val gwenna = T("Gwenna", "Gwenna")
    private val bram = T("Bauer Bram", "Farmer Bram")
    private val liska = T("Liska", "Liska")
    private val garrick = T("Jäger Garrick", "Hunter Garrick")
    private val krogg = T("Krogg", "Krogg")
    private val grak = T("Grak", "Grak")
    private val morwen = T("Kräuterfrau Morwen", "Morwen the Herbalist")

    /** Consumables sold by Thessa; her gear stock is generated (see [Loot.shopGear]). */
    val shopStock = listOf("potion", "greater_potion", "superior_potion", "remedy", "stamina_potion", "spark_potion", "alchemist_fire", "holy_water")

    /** Chest item resolved per class, so every hero finds a fitting weapon. */
    const val CLASS_WEAPON = "@class_weapon"

    fun classWeapon(cls: CharClass): String = when (cls) {
        CharClass.FIGHTER -> "longsword_oakford"
        CharClass.WIZARD -> "staff_of_embers"
        CharClass.ROGUE -> "rapier_whisper"
        CharClass.CLERIC -> "mace_of_dawn"
    }

    /** Chest content: a random piece of gear of at least this rarity. */
    fun randomGear(min: Rarity) = "@gear:${min.name}"

    private fun toVillage(x: Int, y: Int) = Place("village", x, y, Facing.DOWN)
    /** Just inside a room's door, which lies in its bottom row at x 4 (rooms of [h] rows; the inn has 8). */
    private fun inside(map: String, h: Int = 8) = Place(map, 4, h - 2, Facing.UP)
    private fun interiorExit(to: Place, h: Int = 8) = listOf(Warp(4, h - 1, to))

    // ------------------------------------------------------------------ village

    val village = MapDef(
        id = "village",
        name = T("Bornim", "Bornim"),
        kind = MapKind.TOWN,
        rows = listOf(
            "TTTTTTTTTTTTTTTTT==TTTTTTTTTTTTTTTTT",
            "TTT.......T.....x==x.....TT......TTT",
            "TT.......T.....lxzzxlS..T.........TT",
            "T..^^^^^^........==.......^^^^^....T",
            "T..^^^^^^..^^^^..==....^^.^^^^^....T",
            "T.p#W#D#Wb.#D#W..==....D#.W#D#Wb...T",
            "T.....=S.b..=....==....=.S..=......T",
            "T...!.=.....=....==....=....=......T",
            "T....==========================....T",
            "T.f..........pf..==...f.......T..f.T",
            "T................==.......T........T",
            "T.......qqqplooooooooool...........T",
            "T..^^^^.....oommoooommoo.....^^^^..T",
            "T..^^^^.....oooooooooooo....p#D#W..T",
            "T..W#D#.....ooooowoooooo========...T",
            "T....=======oooooooooooo...........T",
            "T.f.........oonoooooonoo.........f.T",
            "T...........looooooooool.........T.T",
            "T.T^^^^^^........==.......MMMMMM...T",
            "T..^^^^^^f.......==.......MMMMMM...T",
            "T..W#D#WW........==.....f.W#D#W#...T",
            "T....=.....^^^^..==.........=....f.T",
            "T....=.....W#D#..==.........=......T",
            "T....==========================....T",
            "T..f...p.........==...T....f....T..T",
            "~~~~~~~~~~~......==...~~~~~~~~~~~~~~",
            "~~~~~~~~~~~~~~~~~hh~~~~~~~~~~~~~~~~~",
            "T..........~~~~~~hh~~~p............T",
            "T..xxxxxxx===========............y.T",
            "T..xvvvvvx..f....==S.ccccccccccc.y.T",
            "TT.xvvvvvx.y...f.==.fccccccccccc..TT",
            "TTTTTTTTTTTTTTT..==..TTTTTTTTTTTTTTT",
        ),
        warps = listOf(
            Warp(17, 0, Place("forest", 9, 30, Facing.UP), QUEST_STARTED, jorinStop()),
            Warp(18, 0, Place("forest", 10, 30, Facing.UP), QUEST_STARTED, jorinStop()),
            // the south road (67): the way the hero came, not taken again in chapter 1
            *(15..20).map { Warp(it, 31, Place("village", it, 30, Facing.UP), LOCKED, turnBack = true) }.toTypedArray(),
            Warp(6, 5, inside("inn")),
            Warp(28, 5, inside("shop", 7)),
            Warp(5, 20, inside("elder", 6)),
            Warp(28, 20, inside("temple", 7)),
            // Homes of villagers: locked for now.
            // 73b (Nutzer 13.10., 21:05): someone answers from inside, by the story and the hour (STORY-K1-WELT.md [73b.…])
            lockedDoor(12, 5) { s, _ -> if (s.has(CHAPTER1_DONE)) voice("Du hast die Goblins vertrieben? … Morgen vielleicht. Heute nicht.", "You drove off the goblins? … Tomorrow, maybe. Not today.")
                else voice("Wer ist da? … Ich mach nicht auf. Für niemanden.", "Who's there? … I'm not opening. Not for anyone.") },
            lockedDoor(23, 5) { _, _ -> voice("Geh weiter. Ich hab in meinem Leben genug an fremde Türen klopfen hören.", "Move along. I've heard enough knocking at strange doors in my life.") },
            lockedDoor(5, 14) { _, night -> if (night) voice("Nicht nachts. Nicht mehr.", "Not at night. Not any more.")
                // [41.gwenna.tuer]
                else T("Hier wohnt Gwenna. Seit ihr Mann nicht zurückkam, bleibt die Tür verschlossen.", "Gwenna lives here. Since her husband did not come back, the door stays locked.") },
            lockedDoor(30, 13) { _, night -> if (night) voice("Die Esse ist kalt. Komm morgen.", "The forge is cold. Come back tomorrow.")
                else T("Das Haus von Schmied Dorran. Er ist wohl in seiner Werkstatt.", "Dorran the smith's house. He must be at his workshop.") },
            lockedDoor(13, 22) { _, night -> if (night) voice("Pim schläft. Und du solltest um diese Zeit auch nicht draußen sein.", "Pim is asleep. And you shouldn't be out at this hour either.")
                else voice("Pim ist nicht da. Wenn du ihn am Schlagbaum siehst, schick ihn heim.", "Pim isn't here. If you see him at the barrier, send him home.") },
        ),
        signs = mapOf(
            (21 to 2) to T("Norden: Flüsterwald.\nAchtung, Goblins!", "North: Whisperwood.\nBeware of goblins!"),
            (7 to 6) to T("Gasthaus »Zum Schlafenden Greif«", "The Sleeping Griffin Inn"),
            // 67a [67.schild]: Rabenschanze, below it (smaller on the board) Schilfrode
            (19 to 29) to T("Rabenschanze\nSchilfrode", "Rabenschanze\nSchilfrode"),
            (25 to 6) to T("Thessas Kramladen\nWaffen · Rüstungen · Tränke", "Thessa's General Store\nWeapons · Armor · Potions"),
        ),
        houseStyles = mapOf(
            (3 to 3) to HouseStyle(RoofKind.RED, WallKind.TIMBER, feature = HouseFeature.INN_SIGN),
            (26 to 3) to HouseStyle(RoofKind.SHINGLE, WallKind.PLANKS, mirrored = true, feature = HouseFeature.AWNING),
            (11 to 4) to HouseStyle(RoofKind.STRAW, WallKind.TIMBER),
            (23 to 4) to HouseStyle(RoofKind.STRAW, WallKind.PLANKS, mirrored = true),
            (3 to 12) to HouseStyle(RoofKind.RED, WallKind.STONE, mirrored = true),
            (29 to 12) to HouseStyle(RoofKind.SLATE, WallKind.STONE),
            (3 to 18) to HouseStyle(RoofKind.BLUE, WallKind.STONE),
            (26 to 18) to HouseStyle(RoofKind.SLATE, WallKind.STONE, feature = HouseFeature.BELL_TOWER),
            (11 to 21) to HouseStyle(RoofKind.SHINGLE, WallKind.TIMBER, mirrored = true),
        ),
        npcs = listOf(
            // Jorin walks his round in front of the barrier and stops at the road to look north.
            Npc("jorin", 15, 3, "guard", Facing.RIGHT, patrol = listOf(15 to 3, 17 to 3, 20 to 3, 18 to 3)) { s ->
                if (!s.has(QUEST_STARTED)) script {
                    say(jorin, "Halt! Der Flüsterwald ist zu gefährlich geworden.", "Halt! The Whisperwood has become too dangerous.")
                    say(jorin, "Ohne Erlaubnis des Ältesten lasse ich niemanden hinaus.", "I'm not letting anyone out without the Elder's permission.")
                } else if (!s.has(BARRIER_OPEN)) script {
                    say(jorin, "Der Älteste hat mir Bescheid gegeben. Dann wollen wir mal.", "The Elder told me about you. Well then.")
                    flag(BARRIER_OPEN)
                    narrate("Jorin löst das Seil, und der Schlagbaum schwingt knarrend nach oben. Der Weg nach Norden ist frei.", "Jorin loosens the rope and the barrier swings up with a creak. The road north is open.")
                    say(jorin, "Viel Glück da draußen, {name}! Tipp: Im hohen Gras lauern Monster. Bleib auf dem Weg, wenn du verletzt bist.", "Good luck out there, {name}! Tip: monsters lurk in the tall grass. Stay on the path when you're hurt.")
                } else if (!s.has(CHAPTER1_DONE)) script {
                    say(jorin, "Der Älteste hat mir Bescheid gegeben. Viel Glück da draußen, {name}!", "The Elder told me about you. Good luck out there, {name}!")
                    say(jorin, "Tipp: Im hohen Gras lauern Monster. Bleib auf dem Weg, wenn du verletzt bist.", "Tip: monsters lurk in the tall grass. Stay on the path when you're hurt.")
                } else script {
                    say(jorin, "Seit du Grak besiegt hast, schlafe ich wieder ruhig. Danke, {name}!", "Since you beat Grak I'm sleeping soundly again. Thanks, {name}!")
                }
            },
            Npc("pim", 15, 14, "child", Facing.DOWN, wander = 3) { s ->
                if (!s.has(CHAPTER1_DONE)) script {
                    say(pim, "Papa sagt, Goblins haben Angst vor Feuer! Stimmt das?", "Dad says goblins are scared of fire! Is that true?")
                    say(pim, "Thessa verkauft Alchemistenfeuer. Damit kann man sogar zaubern, ohne Magier zu sein!", "Thessa sells alchemist's fire. You can do magic with it without even being a wizard!")
                } else script {
                    say(pim, "Wenn ich groß bin, werde ich auch ein Held! Genau wie du!", "When I grow up I'll be a hero too! Just like you!")
                }
            },
            Npc("bram", 20, 29, "farmer", Facing.DOWN, wander = 1) { s ->
                if (!s.has(CHAPTER1_DONE)) script {
                    say(bram, "Das Korn steht gut dieses Jahr. Wenn nur die Wölfe nicht wären – letzte Woche haben sie mir zwei Hühner geholt.", "The grain is doing well this year. If only it weren't for the wolves – last week they took two of my hens.")
                    say(bram, "Wenn du im Wald Fleisch erbeutest: Am Lagerfeuer gebraten schmeckt es am besten. Und es macht stark!", "If you get meat in the forest: roasted at a campfire it tastes best. And it makes you strong!")
                } else script {
                    say(bram, "Seit die Goblins fort sind, schlafen sogar meine Hühner wieder ruhig.", "Since the goblins are gone, even my hens sleep soundly again.")
                }
            },
            Npc("liska", 8, 10, "maid", Facing.DOWN, wander = 1) { s ->
                if (!s.has(CHAPTER1_DONE)) script {
                    say(liska, "Bei dem Wetter trocknet die Wäsche im Nu. Hast du schon Thessas neue Ware gesehen?", "In this weather the laundry dries in no time. Have you seen Thessa's new goods yet?")
                    say(liska, "Auf dem Markt am Brunnen gibt es frisches Obst. Und die Kräuterstände riechen herrlich.", "There's fresh fruit at the market by the well. And the herb stalls smell wonderful.")
                } else script {
                    say(liska, "Ganz Bornim spricht von dir! Ich habe gehört, du hast Grak mit bloßen Händen besiegt.", "All of Bornim is talking about you! I heard you beat Grak with your bare hands.")
                }
            },
            Npc("gwenna", 8, 24, "villager", Facing.DOWN, wander = 2) { s ->
                if (!s.has(CHAPTER1_DONE)) script {
                    say(gwenna, "Früher konnte man nachts in Ruhe fischen. Jetzt heulen die Wölfe bis zum Morgengrauen.", "We used to fish here in peace at night. Now the wolves howl until dawn.")
                } else script {
                    say(gwenna, "Der Held von Bornim! Ich hab's ja immer gewusst.", "The hero of Bornim! I always knew it.")
                }
            },
        ),
    )

    /** A villager's front door that stays shut, with a line about who lives there. */
    private fun lockedDoor(x: Int, y: Int, text: (GameState, Boolean) -> T) = Warp(x, y, Place("village", x, y + 1, Facing.DOWN), LOCKED,
        knock = { s, night -> val t = text(s, night); script { narrate(t.de, t.en); flag(MapPeople.heard(x, y)) } })

    /** 73b: words from behind a shut door, in quotes. */
    private fun voice(de: String, en: String) = T("„$de“", "\u201C$en\u201D")

    private fun jorinStop() = script {
        say(jorin, "Halt! Ohne Erlaubnis des Ältesten lasse ich niemanden in den Wald.", "Halt! Nobody enters the woods without the Elder's permission.")
        say(jorin, "Sein Haus ist unten links am Dorfplatz.", "His house is at the bottom left of the village square.")
    }

    /**
     * What the hero thinks at the south edge of the village (67), by how far the story is: the first time
     * in each part a line to read, after that the short one as a passing note. Second is true for the short one.
     * After Lyra spoke of the camp in the south (68l) the edge says plainly that the road comes later (68p), the same
     * line each time, until chapter 2 opens the road.
     */
    fun southEdge(state: GameState): Pair<T, Boolean>? {
        val (part, long, short) = when {
            CAMP_TOLD in state.flags -> T("Der Weg nach Süden ist noch nicht begehbar. Kapitel 2 folgt mit einem späteren Update.",
                "The road south cannot be travelled yet. Chapter 2 follows in a later update.").let { Triple("camp", it, it) }
            CHAPTER1_DONE in state.flags -> Triple("after", T("Der Brief mit dem grauen Siegel lässt dich nicht los. Die Antwort liegt nicht im Süden.",
                "The letter with the grey seal won't let you go. The answer doesn't lie in the south."), T("Die Antwort liegt nicht im Süden.", "The answer doesn't lie in the south."))
            QUEST_STARTED in state.flags -> Triple("quest", T("Lyra ist irgendwo im Norden. Der Weg nach Süden kann warten.",
                "Lyra is somewhere in the north. The road south can wait."), T("Der Weg nach Süden kann warten.", "The road south can wait."))
            else -> Triple("before", T("Du bist von Süden gekommen, um hier zu rasten. Weiterziehen kannst du später – erst willst du wissen, was in Bornim geschehen ist.",
                "You came from the south to rest here. You can move on later – first you want to know what happened in Bornim."), T("Erst willst du wissen, was in Bornim geschehen ist.", "First you want to know what happened in Bornim."))
        }
        val seen = "south_edge_$part"
        if (seen in state.flags) return short to true
        state.flags += seen
        return long to false
    }

    // ------------------------------------------------------------------ interiors

    val inn = MapDef(
        id = "inn",
        name = T("Zum Schlafenden Greif", "The Sleeping Griffin"),
        kind = MapKind.INTERIOR,
        rows = listOf(
            "###ZZ#W###",
            "#QQkkJbBu#",
            "#kkkkkkBk#",
            "#KKKkkkkJW",
            "#kkYJkYYk#",
            "#bkRRRnnJ#",
            "##kRRRkku#",
            "##W#D###W#",
        ),
        warps = interiorExit(toVillage(6, 6)),
        npcs = listOf(
            // 86.9: after her word Rowena's counter: mead and a room
            Npc("rowena", 1, 2, "innkeeper", Facing.DOWN) { s ->
                // [139.rowena.fleisch] before the counter, when the hero carries raw meat
                fun ScriptBuilder.counter() {
                    if (s.count("raw_meat") > 0) say(rowena, "Frisches Fleisch aus dem Wald? Gib her, daraus wird morgen der Eintopf im Greif.",
                        "Fresh meat from the woods? Hand it over, it'll be tomorrow's stew at the Griffin.")
                    tavern()
                }
                when {
                    !s.has(QUEST_STARTED) -> script {
                        say(rowena, "Ältester Aldric wartet auf dich. Sein Haus liegt unten links am Dorfplatz.", "Elder Aldric is waiting for you. His house is at the bottom left of the village square.")
                        counter()
                    }
                    !s.has(CHAPTER1_DONE) -> script {
                        say(rowena, "Pass auf dich auf, {name}. Wenn du verletzt bist: Bruder Osric im Tempel heilt jeden, der darum bittet.", "Take care, {name}. If you're hurt, Brother Osric at the temple heals anyone who asks.")
                        counter()
                    }
                    // [68.rowena.lager]
                    s.has(CAMP_TOLD) -> script {
                        say(rowena, "Ein Lager im Süden? Die Fuhrleute meiden die Südstraße seit dem Frühjahr. Jetzt weiß ich vielleicht, warum.",
                            "A camp in the south? The carters have avoided the south road since spring. Now I may know why.")
                        counter()
                    }
                    else -> script {
                        say(rowena, "Für den Helden von Bornim geht das Bier heute aufs Haus!", "Drinks are on the house for the hero of Bornim tonight!")
                        counter()
                    }
                }
            },
            Npc("borin", 8, 4, "dwarf", Facing.LEFT) { _ ->
                script {
                    say(borin, "Hrmpf. Ein Zwerg weiß so etwas: Skelette hassen Wuchtwaffen!", "Hrmph. A dwarf knows these things: skeletons hate bludgeoning weapons!")
                    say(borin, "Streitkolben, Hammer, sogar ein Stab – das zerschmettert ihre Knochen. Und heiliges Licht verbrennt alles Untote.", "Mace, hammer, even a staff will shatter their bones. And holy light burns all undead.")
                }
            },
        ),
        onEnter = { s ->
            if (s.has(INTRO_DONE)) emptyList() else script {
                say(rowena, "Na, endlich wach, {name}? Du hast geschlafen wie ein Stein.", "Well, finally awake, {name}? You slept like a rock.")
                say(rowena, "Schlimme Zeiten sind das. Seit Wochen überfallen Goblins die Händler auf der Waldstraße.", "These are dark times. For weeks, goblins have been raiding the merchants on the forest road.")
                say(rowena, "Und letzte Nacht haben sie Schwester Lyra aus dem Tempel verschleppt – und das heilige Sonnenamulett gleich mit!", "And last night they dragged Sister Lyra out of the temple, and took the holy Sun Amulet too!")
                say(rowena, "Ältester Aldric sucht verzweifelt nach Hilfe. Sein Haus liegt unten links am Dorfplatz. Geh zu ihm!", "Elder Aldric is desperate for help. His house is at the bottom left of the village square. Go and see him!")
                // [280.tipp]
                if (classicControls) narrate("Tipp: Mit dem Steuerkreuz läufst du, der große Knopf spricht mit Leuten und untersucht Dinge. Der Beutel oben öffnet das Menü.",
                    "Tip: the D-pad moves you; the big button talks to people and examines things. The bag at the top opens the menu.")
                else narrate("Tipp: Zieh den Finger über das Bild, um zu laufen, oder tippe dorthin, wo du hinwillst. Tippe auf Leute und Dinge, um mit ihnen zu sprechen oder sie zu untersuchen. Der Beutel oben öffnet das Menü.",
                    "Tip: drag your finger across the screen to walk, or tap where you want to go. Tap people and things to talk to them or examine them. The bag at the top opens the menu.")
                flag(INTRO_DONE)
            }
        },
    )

    val shop = MapDef(
        id = "shop",
        name = T("Thessas Kramladen", "Thessa's General Store"),
        kind = MapKind.INTERIOR,
        // 13q.8: floor plan A, shelves along the back, the counter across the room, Thessa behind it, a stove in the corner
        rows = listOf(
            "##ZZ#W###",
            "#kkkQQQU#",
            "#bkkkkkk#",
            "#bKKKKkJW",
            "#kkkkkku#",
            "#ukkkkkJ#",
            "#W##D##W#",
        ),
        warps = interiorExit(toVillage(28, 6), 7),
        npcs = listOf(
            Npc("thessa", 4, 2, "merchant", Facing.DOWN) { _ ->
                script {
                    say(thessa, "Willkommen in Thessas Kramladen! Was darf's sein?", "Welcome to Thessa's General Store! What can I get you?")
                    shop(shopStock)
                    say(thessa, "Komm bald wieder!", "Come again soon!")
                }
            },
        ),
    )

    val elderHouse = MapDef(
        id = "elder",
        name = T("Haus des Ältesten", "Elder's House"),
        kind = MapKind.INTERIOR,
        // 13q.6: floor plan A, a study and the bed against the back wall beside the hearth, the sun of Bornim by the desk
        rows = listOf(
            "####ZZ#W#",
            "#BBskkVd#",
            "#BBkkkkaW",
            "#akRRRkk#",
            "#kkRRRkk#",
            "#W##D#WW#",
        ),
        warps = interiorExit(toVillage(5, 21), 6),
        npcs = listOf(Npc("aldric", 7, 3, "elder", Facing.DOWN) { s -> elderTalk(s) }),
    )

    /**
     * 68 (68a, 68e–68g, 68j, 68k): after Aldric's invitation there is no free choice: the night passes (it counts as a rest),
     * the temple scene runs at sunrise, and afterwards the hero stands in the temple in the first row, where Lyra speaks to
     * them of her own accord (`[68.lyra.1–3]`); from then on the chronicle carries the camp in the south as a task (68k, no
     * mark on the map) and Rowena and Aldric speak of it.
     */
    private fun ScriptBuilder.templeMorning() {
        templeScene()
        morning(Place("temple", 4, 3, Facing.UP))
        flag(TEMPLE_SEEN)
        campLines()
    }

    /** `[68.lyra.1–3]`: Lyra thanks the hero and speaks of the camp in the south; the chronicle takes it up as a task. */
    private fun ScriptBuilder.campLines() {
        // [68.lyra.1]
        say(lyra, "Ich verdanke dir mein Leben, {name}. Und Bornim sein Licht.", "I owe you my life, {name}. And Bornim its light.")
        // [68.lyra.2]
        say(lyra, "Graks Leute sprachen von einem Lager im Süden. Dort brachten sie, wen sie nicht selbst behalten wollten.",
            "Grak's men spoke of a camp in the south. That is where they took those they did not want to keep themselves.")
        // [68.lyra.3]
        say(lyra, "Ich weiß nicht, was er von mir will. Aber ich träume seit Wochen von grauer Asche.",
            "I do not know what he wants from me. But for weeks I have dreamt of grey ash.")
        flag(CAMP_TOLD)
    }

    private fun elderTalk(s: GameState): List<Cmd> = when {
        !s.has(QUEST_STARTED) -> script {
            say(aldric, "Du bist also {name}. Rowena sagt, du verstehst dich aufs Kämpfen.", "So you're {name}. Rowena tells me you know how to fight.")
            say(aldric, "Der Blutzahn-Stamm haust in einer Höhle am Nordende des Flüsterwalds. Früher waren diese Goblins feige.", "The Bloodfang tribe lives in a cave at the northern end of the Whisperwood. Those goblins used to be cowards.")
            say(aldric, "Doch nun führt sie ein Hobgoblin namens Grak – grausam und gerissen.", "But now they're led by a hobgoblin called Grak, cruel and cunning.")
            say(aldric, "Sie haben Schwester Lyra entführt und das Sonnenamulett gestohlen. Seit hundert Jahren schützt es Bornim vor der Finsternis.", "They kidnapped Sister Lyra and stole the Sun Amulet. For a hundred years it has protected Bornim from the darkness.")
            say(aldric, "Bring beide zurück, und Bornim wird es dir nie vergessen. Nimm dies für die Reise.", "Bring them both back, and Bornim will never forget it. Take this for the road.")
            give("potion", 2)
            gold(50)
            say(aldric, "Wache Jorin öffnet dir den Schlagbaum am Nordweg. Möge das Licht dich leiten.", "Guard Jorin will raise the barrier on the north road for you. May the light guide you.")
            flag(QUEST_STARTED)
        }
        // [68.aldric.lager]
        s.has(CAMP_TOLD) -> script {
            say(aldric, "Lyra hat mir vom Lager erzählt. Wenn dort Leute aus der Gegend festsitzen, kann Bornim nicht einfach wegsehen.",
                "Lyra told me about the camp. If people from these parts are held there, Bornim cannot simply look away.")
        }
        s.has(CHAPTER1_DONE) -> script {
            say(aldric, "Ruh dich aus, {name}. Der Graue Prophet wird nicht lange warten …", "Rest now, {name}. The Grey Prophet won't wait for long...")
        }
        s.has(GRAK_DEFEATED) && s.has(LYRA_RESCUED) -> script {
            say(aldric, "{name}! Lyra ist zurück, und du bringst das Sonnenamulett! Du hast es tatsächlich geschafft!", "{name}! Lyra is back, and you've brought the Sun Amulet! You actually did it!")
            take("sun_amulet")
            say(aldric, "Und was ist das für ein Brief? … Ein graues Auge als Siegel.", "And what is this letter? ...Sealed with a grey eye.")
            say(aldric, "»Bringt mir das Amulett und die Priesterin. Der Tag der Asche naht. – Der Graue Prophet«", "\"Bring me the amulet and the priestess. The Day of Ashes approaches. – The Grey Prophet\"")
            say(aldric, "Der Graue Prophet … ich dachte, das sei nur eine Geschichte, um Kinder zu erschrecken.", "The Grey Prophet... I thought that was just a tale to frighten children.")
            say(aldric, "Wenn er hinter all dem steckt, war Grak erst der Anfang. Nimm diesen Ring. Er hat schon meinem Vater gute Dienste geleistet.", "If he is behind all this, Grak was only the beginning. Take this ring. It served my father well.")
            give("ring_protection")
            gold(200)
            // [68.aldric]
            say(aldric, "Morgen bei Sonnenaufgang legt Lyra das Amulett zurück auf den Altar. Ganz Bornim wird dort sein, und du gehörst in die erste Reihe.",
                "Tomorrow at sunrise Lyra will lay the amulet back on the altar. All of Bornim will be there, and you belong in the front row.")
            flag(CHAPTER1_DONE)
            chapterEnd()
            templeMorning()
        }
        s.has(GRAK_DEFEATED) -> script {
            say(aldric, "Grak ist besiegt? Wunderbar! Aber … wo ist Lyra? Hast du sie in der Höhle nicht gefunden?", "Grak is defeated? Wonderful! But... where is Lyra? Didn't you find her in the cave?")
        }
        else -> script {
            say(aldric, "Die Blutzahnhöhle liegt am Nordende des Flüsterwalds. Sei vorsichtig, {name}.", "The Bloodfang Cave lies at the northern end of the Whisperwood. Be careful, {name}.")
            say(aldric, "Wenn du verletzt bist, geh zu Bruder Osric in den Tempel. Und Thessa verkauft gute Ausrüstung.", "If you're hurt, go to Brother Osric at the temple. And Thessa sells good equipment.")
        }
    }

    val temple = MapDef(
        id = "temple",
        name = T("Tempel des Morgenlichts", "Temple of the Dawnlight"),
        kind = MapKind.INTERIOR,
        // 13q.9: floor plan A, a broad altar between two candlesticks, two blocks of pews with aisles in the middle and along the walls, the lectern beside the altar
        // 13 (Meldung 12.10., 08:43): the altar stood right before the one window; now two windows flank it
        rows = listOf(
            "#W#####W#",
            "#kNAAANk#",
            "#kkkkdkk#",
            "#knnknnkW",
            "#knnknnk#",
            "#kk&kkkk#",
            "#W##D#W##",
        ),
        warps = interiorExit(toVillage(28, 21), 7),
        npcs = listOf(
            Npc("osric", 4, 2, "priest", Facing.DOWN) { s ->
                script {
                    if (!s.has(LYRA_RESCUED)) {
                        say(osric, "Willkommen im Tempel des Morgenlichts. Lass mich deine Wunden versorgen.", "Welcome to the Temple of the Dawnlight. Let me tend to your wounds.")
                    } else {
                        say(osric, "Gesegnet seist du, {name}. Lass mich deine Wunden versorgen.", "Blessings upon you, {name}. Let me tend to your wounds.")
                    }
                    rest()
                    narrate("Ein warmes Licht umhüllt dich. TP und ZP sind vollständig wiederhergestellt.", "A warm light surrounds you. HP and SP are fully restored.")
                    if (!s.has(LYRA_RESCUED)) {
                        say(osric, "Bitte … finde Schwester Lyra. Ohne sie und das Amulett ist dieser Tempel nur ein kalter Steinhaufen.", "Please... find Sister Lyra. Without her and the amulet, this temple is just a cold pile of stones.")
                    }
                }
            },
            Npc("lyra_temple", 6, 2, "lyra", Facing.DOWN, visible = { it.has(LYRA_RESCUED) }) { s ->
                if (!s.has(CHAPTER1_DONE)) script {
                    say(lyra, "Danke, dass du mich gerettet hast, {name}. Bitte bring das Amulett zu Ältestem Aldric!", "Thank you for rescuing me, {name}. Please take the amulet to Elder Aldric!")
                } else if (!s.has(CAMP_TOLD)) script {
                    // the morning was cut short (the game closed during the scene) or the chapter ended before 68: Lyra tells it now
                    campLines()
                } else script {
                    say(lyra, "Der Graue Prophet … Ich habe seine Stimme in meinen Träumen gehört. Wir müssen vorbereitet sein.", "The Grey Prophet... I've heard his voice in my dreams. We must be prepared.")
                }
            },
        ),
    )

    // ------------------------------------------------------------------ forest

    val forest = MapDef(
        id = "forest",
        name = T("Flüsterwald", "Whisperwood"),
        kind = MapKind.FOREST,
        rows = listOf(
            "TTTTTTTTXXEXXTTTTTTT",
            "TTT,,,,..=..S.,,,TTT",
            "TT,,,,,..=...,,OO,TT",
            "TT,,TT,..=..TT,,,,TT",
            "TT,,TT...=...T,,C,TT",
            "TTTTTT..==...TTTTTTT",
            "TTfff..==.....TTTTTT",
            "TTfr..==........TTTT",
            "TTff..=.......r,,,TT",
            "TT,,,.=....F...,,,TT",
            "TT,,,.=......=======",
            "TT,,,.==.......,,,TT",
            "TTTT...=...TTT,,TTTT",
            "TT~~~..=..,,,,,,,,TT",
            "TT~~~~.=..,,,,,,,,TT",
            "TT~~~~.==.,,TT,,C,TT",
            "TT~~~...=.,,TT,,,,TT",
            "TTT.....=....TTTTTTT",
            "TT,,,,..==..,,,,,,TT",
            "TT,OO,...=..,,,,,,TT",
            "TT,,TT...=...TT,,,TT",
            "TT,,TT...=...TT,,,TT",
            "TTffff...=.....r..TT",
            "TTTTTff..=...TTTTTTT",
            "TTC,,,...==..,,I,TTT",
            "TT,,,,....=..I,,,ITT",
            "TT,,,,....=..,,,,,TT",
            "TTTT,,ff..=...I,TTTT",
            "TTTTfff...=S..fffTTT",
            "TTTTTT...==...TTTTTT",
            "TTTTTTTT.==.TTTTTTTT",
            "TTTTTTTTT==TTTTTTTTT",
        ),
        warps = listOf(
            Warp(9, 31, Place("village", 17, 1, Facing.DOWN)),
            Warp(10, 31, Place("village", 18, 1, Facing.DOWN)),
            Warp(10, 0, Place("cave", 10, 18, Facing.UP)),
            Warp(19, 10, Place("deep_forest", 1, 18, Facing.RIGHT)),
        ),
        signs = mapOf(
            (11 to 28) to T("Flüsterwald\nBleib auf dem Weg, Wanderer!", "Whisperwood\nStay on the path, traveller!"),
            (12 to 1) to T("BLUTZAHN-HÖHLE\nWer weitergeht, wird gefressen!\n– die Goblins", "BLOODFANG CAVE\nKeep out or get eaten!\n– the goblins"),
        ),
        chests = listOf(
            Chest("forest_1", 16, 4, randomGear(Rarity.UNCOMMON)),
            Chest("forest_2", 16, 15, "potion", count = 2),
            Chest("forest_3", 2, 24, gold = 40),
        ),
        npcs = listOf(
            // 3b (Nutzer 13.10., 17:10): left of the fire, so seen diagonally he faces the camera instead of turning his back
            Npc("garrick", 10, 9, "hunter", Facing.RIGHT) { s ->
                if (!s.has(HUNTER_MET)) script {
                    say(garrick, "Ein Abenteurer? Setz dich ans Feuer. Ich bin Garrick, Jäger aus Bornim.", "An adventurer? Sit by the fire. I'm Garrick, a hunter from Bornim.")
                    say(garrick, "Im hohen Gras lauern Riesenratten, Wölfe und Goblin-Späher. Auf dem Weg bist du sicherer.", "Giant rats, wolves and goblin scouts lurk in the tall grass. You're safer on the path.")
                    say(garrick, "An einem Lagerfeuer kannst du rasten; eine lange Rast heilt dich ganz. Und hier, nimm das.", "You can rest at a campfire; a long rest heals you fully. And here, take these.")
                    give("potion", 2)
                    flag(HUNTER_MET)
                    // D23.2 (Homer 17.10.): the Krogg part follows at once, so a single talk is enough
                    if (!s.has(KROGG_DEFEATED)) kroggTip(s)
                } else if (!s.has(KROGG_DEFEATED)) script {
                    kroggTip(s)
                } else script {
                    say(garrick, "Du siehst aus, als könntest du eine Rast gebrauchen. Das Feuer brennt noch.", "You look like you could use a rest. The fire's still burning.")
                }
            },
        ),
        encounters = Encounters(
            rate = 0.004,
            table = listOf(
                "giant_rat" to 22, "wolf" to 20, "goblin" to 17, "goblin_archer" to 8,
                "boar" to 10, "kobold" to 10, "giant_centipede" to 7, "stirge" to 6,
            ),
            tiles = setOf(Tile.TALL_GRASS),
            roamers = 7,
            // At night the dead walk and bats come out.
            night = listOf(
                "wolf" to 24, "skeleton" to 18, "zombie" to 14, "giant_bat" to 14, "goblin" to 10, "kobold" to 10, "stirge" to 10,
            ),
        ),
        areaLevel = 1,
        safeZones = listOf(
            SafeZone(10, 9, 4, T("Jäger Garrick schwenkt seine Fackel – die Biester weichen zurück!", "Hunter Garrick waves his torch – the beasts back off!")),
            SafeZone(10, 30, 3),
            SafeZone(10, 1, 2),
            SafeZone(19, 10, 2),
        ),
    )

    // ------------------------------------------------------------------ deep forest

    val deepForest = MapDef(
        id = "deep_forest",
        name = T("Tiefer Flüsterwald", "Deep Whisperwood"),
        kind = MapKind.FOREST,
        rows = listOf(
            "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
            "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
            "TTTTTTTTTTTTTTTTTT,TT..TTTTTTTTTTTTTTTTTTTTT",
            "TTTTTTTTTTTTTTTT,,,,,.......TTTTTTTTTTTTTTTT",
            "TTTTTTTTTTTTTTT,,,,,,,.....CTTTTTTTTTTTTTTTT",
            "TTTTTTTTTTTTTTT,,,,,,.......TTTTTTTT,TTTTTTT",
            "TTTTTTTTTTT,,,,,,,,,..........T,,,,,,,,TTTTT",
            "TTTTTTTTTT,,,,,,,,,...=......T,,,T,,,C,,TTTT",
            "TTTTTTTTTT,,T,,,,,,.T.=.T..T.TT,,OO,,,,,,TTT",
            "TTTTTTTTTT,,,,=,,,,Tff=...T.TT,,,,,,,,,,,TTT",
            "TTTTTTTTTT,,,,=T,,,,ff=.TTTTTT,,T,,=,,,,,,TT",
            "TTTTTTTTTT,,,,=,,,,TT==TTTTTTT,,,,,=,,,,,,TT",
            "TTTTTTTTTTT,,,=,,,TTT=TTTTTTTT,,,,,=,,,,,TTT",
            "TTTTTTTTTTrTT==,TTTTT=TTTTTTTT,,,,,=,,r,,TTT",
            "TTTTT.I...I..=TTTTTTT=TTTTTTTTTT,,,=,,TTTTTT",
            "TT.T.........=TTTTTTT=TTTTTTTT,TT,T=,TTTTTTT",
            "TTT..I.T...I==TTTTTff=fffTTT,,,,,,T=TTTTTTTT",
            "TT..........=..TTffT.=ffT.,,,,,,,===TTTTTTTT",
            "=======.....=.T......=....,,,,,,,=,TTTTTTTTT",
            "TT.S..========.r.....=============,,TTTTTTTT",
            "TTT.fff.,,,,,==========T..,====,,,,TTTTTTTTT",
            "TTT.ff.,,,,,,,.==.........,,,,=,,,TTTTTTTTTT",
            "TTT.....,,,,,T==.......,.,,,,,=,,,TTTTTTTTTT",
            "TTTTTTT...TTTT=TT.....,,,,,,,,=TTTTTTTTTTTTT",
            "TTTTTTTTTTTTTT=TTTT....,,,,,TT====TTTTTTTTTT",
            "TTTTTTTTTTT,T==TTTT.T=.TTTTTTT...=....T.TTTT",
            "TTTTTTTTT,,,==,,TTTTT=TTTTTTT....=......TTTT",
            "TTTTTTTT,,,,=,,,,TTTT..^^.TTT..===......TTTT",
            "TTTTTTT,,,,,=,,,,TT....##.TTT..=....~....TTT",
            "TTTTT,T,,,OO=,,,,TT.......TTT..=..~~~~~...TT",
            "TTTTTT,,,,r,=,,,,TTT...F..TTT..=.~~~~~~...TT",
            "TTTTT,,,,,,,,,,,,TTT.....TTTT.ff..~~~~~C..TT",
            "TTTTTT,,,C,,,,,,,,,TTTTTTTTTT.fff...~...TTTT",
            "TTTTTTTr,,,,,,,,,TTTTTTTTTTTTTTT.......TTTTT",
            "TTTTTTTT,,,,,,,,,TTTTTTTTTTTTTTTT.T..TTTTTTT",
            "TTTTTTTTTTTT,TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
            "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
            "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
        ),
        warps = listOf(
            Warp(0, 18, Place("forest", 18, 10, Facing.LEFT)),
            // D3.13a: Morwen's hut on its own clearing south of the camp place, its door to the south towards her fire;
            // she is out there, the door stays shut
            Warp(23, 28, Place("deep_forest", 23, 29, Facing.DOWN), LOCKED),
        ),
        houseStyles = mapOf((23 to 27) to HouseStyle(RoofKind.STRAW, WallKind.PLANKS, feature = HouseFeature.HUT)),
        signs = mapOf(
            // 27.6b (draft): south of the way, in the light and before the trees (north of it the sign stood in deep shade)
            (3 to 19) to T("Tiefer Flüsterwald\nHier endet der Weg der Jäger.\nNur für erfahrene Abenteurer!", "Deep Whisperwood\nThe hunters' trail ends here.\nFor seasoned adventurers only!"),
        ),
        chests = listOf(
            Chest("deep_1", 37, 7, randomGear(Rarity.RARE)),
            Chest("deep_2", 9, 32, "remedy", count = 2),
            Chest("deep_3", 39, 31, gold = 120),
            Chest("deep_4", 27, 4, randomGear(Rarity.VERY_RARE)),
        ),
        npcs = listOf(
            Npc("morwen", 25, 30, "herbalist", Facing.LEFT) { s ->
                if (!s.has(HERBALIST_MET)) script {
                    say(morwen, "Na sieh an, jemand wagt sich so tief in den Wald. Ich bin Morwen, ich sammle hier Kräuter.", "Well, well, someone dares to come this deep into the woods. I'm Morwen, I gather herbs here.")
                    say(morwen, "Am Feuer bist du sicher: Der Rauch meiner Kräuter hält die Biester fern.", "You're safe by the fire: the smoke of my herbs keeps the beasts away.")
                    say(morwen, "Im Norden haust Grimmzahn, der Leitwolf. Groß wie ein Pony und doppelt so bösartig. Nimm das hier mit.", "In the north lives Grimfang, the alpha wolf. Big as a pony and twice as vicious. Take this with you.")
                    give("remedy", 1)
                    flag(HERBALIST_MET)
                    smokeAgainstKrogg(s)
                    say(morwen, HERBALIST_HERBS.de, HERBALIST_HERBS.en)
                    shop(HERBALIST_STOCK, brewing = true)
                } else if (wantsSmoke(s)) script {
                    smokeAgainstKrogg(s)
                    say(morwen, HERBALIST_HERBS.de, HERBALIST_HERBS.en)
                    shop(HERBALIST_STOCK, brewing = true)
                } else script {
                    say(morwen, if (s.has(GRIMFANG_DEFEATED)) "Ohne Grimmzahn ist der Wald ruhiger geworden. Brauchst du Tränke?" else "Brauchst du Tränke? Für Grimmzahn wirst du sie brauchen.",
                        if (s.has(GRIMFANG_DEFEATED)) "The woods are quieter without Grimfang. Need potions?" else "Need potions? You'll need them for Grimfang.")
                    say(morwen, HERBALIST_HERBS.de, HERBALIST_HERBS.en)
                    shop(HERBALIST_STOCK, brewing = true)
                }
            },
            Npc("grimfang", 22, 4, "monster:dire_wolf", Facing.DOWN, visible = { !it.has(GRIMFANG_DEFEATED) }) { _ ->
                script {
                    narrate("Ein gewaltiger Wolf mit narbigem Fell tritt aus dem Schatten. Seine Augen glühen rot.", "A huge wolf with a scarred coat steps out of the shadows. Its eyes glow red.")
                    fight("dire_wolf", GRIMFANG_DEFEATED)
                    narrate("Grimmzahn bricht zusammen. Für einen Moment wird es ganz still im Wald.", "Grimfang collapses. For a moment the forest falls completely silent.")
                }
            },
        ),
        encounters = Encounters(
            rate = 0.004,
            table = listOf(
                "wolf" to 22, "boar" to 14, "kobold" to 14, "giant_spider" to 8, "goblin" to 12, "goblin_archer" to 8,
                "giant_centipede" to 8, "stirge" to 8, "goblin_shaman" to 6,
            ),
            tiles = setOf(Tile.TALL_GRASS),
            roamers = 13,
            night = listOf(
                "wolf" to 22, "skeleton" to 16, "zombie" to 12, "giant_bat" to 16, "ghoul" to 6, "kobold" to 10, "giant_spider" to 10, "stirge" to 8,
            ),
        ),
        areaLevel = 2,
        safeZones = listOf(
            SafeZone(21, 21, 4, T("Der beißende Kräuterrauch aus Morwens Feuer vertreibt die Biester!", "The acrid herb smoke from Morwen's fire drives the beasts away!")),
            SafeZone(1, 18, 3),
        ),
    )

    // ------------------------------------------------------------------ cave

    val cave = MapDef(
        id = "cave",
        name = T("Blutzahnhöhle", "Bloodfang Cave"),
        kind = MapKind.CAVE,
        rows = listOf(
            "XXXXXXXXXXXXXXXXXXXXXX",
            "XXXXXXti_______tXXXXXX",
            "XXXXXX________j_XXXXXX",
            "XXXXXXi________iXXXXXX",
            "XXXXXXXXXX__XXXXXXXXXX",
            "XXXXXXXXXXLLXXXXXXXXXX",
            "XXXGXXGXXXHHXXXXXXXXXX",
            "XXg_____XX__XX__*__jXX",
            "XX_C___gXX__XX%___C_XX",
            "XXg_____XX__XX_____jXX",
            "XX___r______________XX",
            "XX_g____XX__XXi_____XX",
            "XXXXX_XXXXHHXXXX_XXXXX",
            "XX~~____XX__XXe____uXX",
            "XX~~C___XX__XXe____uXX",
            "XX~g____XX__XX__F_j_XX",
            "XX_%______________%_XX",
            "XXXXXXXXXXHHXXXXXXXXXX",
            "XXXXXXXXXX__XXXXXXXXXX",
            "XXXXXXXXXX++XXXXXXXXXX",
        ),
        warps = listOf(
            Warp(10, 19, Place("forest", 10, 1, Facing.DOWN)),
            Warp(11, 19, Place("forest", 10, 1, Facing.DOWN)),
        ),
        chests = listOf(
            Chest("cave_1", 3, 8, "greater_potion", count = 2),
            Chest("cave_2", 18, 8, randomGear(Rarity.RARE)),
            Chest("cave_3", 4, 14, CLASS_WEAPON),
        ),
        npcs = listOf(
            Npc("krogg", 16, 9, "monster:bugbear", Facing.DOWN, visible = { !it.has(KROGG_DEFEATED) }) { _ ->
                script {
                    say(krogg, "WER STÖRT KROGG? Krogg zermalmt dich!", "WHO DISTURBS KROGG? Krogg will crush you!")
                    say(krogg, "Schlüssel gehört Krogg! Grak sagt: niemand kommt durch!", "Key belongs to Krogg! Grak says: nobody gets through!")
                    fight("bugbear", KROGG_DEFEATED)
                    narrate("Krogg sinkt zu Boden. Ein rostiger Schlüssel fällt aus seinem Gürtel.", "Krogg crashes to the ground. A rusty key falls from his belt.")
                }
            },
            Npc("grak", 10, 2, "monster:hobgoblin_captain", Facing.DOWN, visible = { !it.has(GRAK_DEFEATED) }) { s -> grakTalk(s) },
            // 356.1: chained to the pillar beside her; Grak's key frees her, she blesses the hero and walks out of the hall, through the gate into the passage
            Npc("lyra_cave", 8, 1, "lyra", Facing.DOWN, visible = { !it.has(LYRA_GONE) },
                leave = Leave(10 to 7, LYRA_GONE) { it.has(LYRA_RESCUED) }) { s ->
                if (s.has(LYRA_RESCUED)) emptyList() else if (!s.has(GRAK_DEFEATED)) grakTalk(s) else script {
                    // [356.ketten]; a game saved between Grak and Lyra has no key: the chains open all the same
                    if (s.count("grak_key") > 0) take("grak_key")
                    narrate("Der Schlüssel dreht sich schwer. Die Ketten fallen klirrend zu Boden.", "The key turns stiffly. The chains fall clattering to the floor.")
                    say(lyra, "Du hast Grak besiegt! Ich bin Lyra, Priesterin des Morgenlichts.", "You defeated Grak! I'm Lyra, priestess of the Dawnlight.")
                    say(lyra, "Sie wollten mich und das Amulett zu jemandem bringen … zum »Grauen Propheten«.", "They were going to take me and the amulet to someone... to the \"Grey Prophet\".")
                    say(lyra, "Ich kehre sofort zum Tempel zurück. Bitte bring das Amulett zu Ältestem Aldric!", "I'll return to the temple at once. Please take the amulet to Elder Aldric!")
                    say(lyra, "Nimm dieses Weihwasser. Gegen Untote wirkt es Wunder.", "Take this holy water. It works wonders against the undead.")
                    give("holy_water", 2)
                    // [356.lyra.segen]: heals fully; then she walks to the hall's way out (the closing line is gone: one sees it)
                    narrate("Lyra legt dir die Hand auf die Stirn. Warmes Licht fließt durch dich.", "Lyra lays her hand on your brow. Warm light flows through you.")
                    say(lyra, "Das Morgenlicht vergisst niemanden, der ihm dient.", "The Dawnlight forgets no one who serves it.")
                    heal()
                    flag(LYRA_RESCUED)
                }
            },
        ),
        triggers = listOf(10, 11).map { x ->
            Trigger(x, 4, condition = { !it.has(GRAK_DEFEATED) }, script = { s -> grakTalk(s) })
        },
        encounters = Encounters(
            rate = 0.004,
            table = listOf(
                "goblin" to 22, "goblin_archer" to 12, "goblin_shaman" to 8, "skeleton" to 14, "zombie" to 9,
                "giant_bat" to 12, "giant_rat" to 6, "ghoul" to 6, "giant_spider" to 5, "ochre_jelly" to 3,
            ),
            tiles = setOf(Tile.CAVE_FLOOR, Tile.RUBBLE, Tile.BONES, Tile.GLOWSHROOM, Tile.SKYLIGHT),
            roamers = 6,
        ),
        areaLevel = 3,
        safeZones = listOf(SafeZone(10, 18, 2)),
        onEnter = { s ->
            if (s.has("cave_seen")) emptyList() else script {
                narrate("Ein modriger Geruch schlägt dir entgegen. Irgendwo in der Tiefe tropft Wasser … und etwas lacht.", "A musty smell hits you. Somewhere in the depths, water drips... and something laughs.")
                flag("cave_seen")
            }
        },
    )

    private fun grakTalk(s: GameState): List<Cmd> = script {
        say(grak, "Ein Menschlein? In MEINER Halle?", "A little human? In MY hall?")
        say(grak, "Der Prophet zahlt in Gold für jede Seele, die ich ihm bringe. Die Priesterin gehört schon ihm.", "The Prophet pays in gold for every soul I bring him. The priestess already belongs to him.")
        say(grak, "Und du wirst die nächste sein!", "And you'll be next!")
        fight("hobgoblin_captain", GRAK_DEFEATED)
        say(grak, "Unmöglich … der Prophet … wird euch … alle …", "Impossible... the Prophet... will... all of you...")
        narrate("Grak bricht zusammen. Bei ihm findest du das Sonnenamulett und einen versiegelten Brief.", "Grak collapses. On him you find the Sun Amulet and a sealed letter.")
        say(lyra, "Hier drüben! Bitte, hilf mir!", "Over here! Please, help me!")
    }

    /** The current objective, shown in the menu. */
    fun objective(s: GameState): T = when {
        s.has(CHAPTER1_DONE) -> T("Kapitel 1 abgeschlossen! Erkunde die Welt und stärke deinen Helden.", "Chapter 1 complete! Explore the world and grow stronger.")
        s.has(GRAK_DEFEATED) && s.has(LYRA_RESCUED) -> T("Bring das Sonnenamulett zu Ältestem Aldric nach Bornim.", "Bring the Sun Amulet to Elder Aldric in Bornim.")
        s.has(GRAK_DEFEATED) -> T("Befreie Schwester Lyra in Graks Halle.", "Free Sister Lyra in Grak's hall.")
        s.has(GATE_OPEN) -> T("Stelle dich Hauptmann Grak hinter dem Gitter.", "Face Captain Grak beyond the gate.")
        s.has(KROGG_DEFEATED) -> T("Öffne das Gitter in der Mitte der Höhle mit dem rostigen Schlüssel.", "Open the gate in the middle of the cave with the rusty key.")
        s.has("cave_seen") -> T("Finde den Schlüssel zu Graks Halle. Vielleicht trägt ihn einer seiner Schergen.", "Find the key to Grak's hall. Perhaps one of his henchmen carries it.")
        s.has(QUEST_STARTED) && !s.has(BARRIER_OPEN) -> T("Lass dir von Wache Jorin den Schlagbaum am Nordweg öffnen.", "Ask Guard Jorin to raise the barrier on the north road.")
        s.has(QUEST_STARTED) -> T("Durchquere den Flüsterwald nach Norden und finde die Blutzahnhöhle.", "Cross the Whisperwood to the north and find the Bloodfang Cave.")
        else -> T("Sprich mit Ältestem Aldric. Sein Haus liegt unten links am Dorfplatz.", "Talk to Elder Aldric. His house is at the bottom left of the village square.")
    }

    val chapterEndText = T(
        "Bornim feiert bis tief in die Nacht. Das Sonnenamulett ist zurück in Bornim, und Schwester Lyra ist in Sicherheit.\n\nDoch der Brief mit dem grauen Siegel lässt dich nicht los. Wer ist der Graue Prophet? Und was ist der Tag der Asche?\n\nENDE VON KAPITEL 1\n\nDu kannst weiterspielen, Monster jagen und deinen Helden verbessern.",
        "Bornim celebrates deep into the night. The Sun Amulet is back in Bornim, and Sister Lyra is safe.\n\nBut the letter with the grey seal won't leave your mind. Who is the Grey Prophet? And what is the Day of Ashes?\n\nEND OF CHAPTER 1\n\nYou can keep playing, hunt monsters and improve your hero.",
    )
}
