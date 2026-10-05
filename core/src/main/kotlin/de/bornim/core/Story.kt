package de.bornim.core

/**
 * Chapter 1: "The Bloodfang Tribe". An original story in the spirit of classic
 * starter adventures: goblin raids, a kidnapped priestess, a stolen relic and a
 * shadowy mastermind behind it all.
 */
object Story {
    // Flags
    const val INTRO_DONE = "intro_done"
    const val QUEST_STARTED = "quest_started"
    const val HUNTER_MET = "hunter_met"
    const val KROGG_DEFEATED = "krogg_defeated"
    const val GATE_OPEN = "gate_open"
    const val GRAK_DEFEATED = "grak_defeated"
    const val LYRA_RESCUED = "lyra_rescued"
    const val CHAPTER1_DONE = "chapter1_done"
    const val GRIMFANG_DEFEATED = "grimfang_defeated"
    const val HEDDA_MET = "hedda_met"
    /** Set when chapter 2 begins; until then the hero cannot rise above [CHAPTER1_LEVEL_CAP]. */
    const val CHAPTER2_STARTED = "chapter2_started"
    const val CHAPTER1_LEVEL_CAP = 6

    /** What Hedda sells; she also brews potions from ingredients. */
    private val HEDDA_STOCK = listOf("potion", "greater_potion", "remedy", "holy_water")

    /** The chapter the hero is playing: it sets the level cap, the best loot and the gear limits. */
    fun chapter(s: GameState): Int = if (s.has(CHAPTER2_STARTED)) 2 else 1

    /** Highest level the hero can reach in the current chapter. Experience beyond it is kept. */
    fun levelCap(s: GameState): Int = if (s.has(CHAPTER2_STARTED)) Rules.MAX_LEVEL else CHAPTER1_LEVEL_CAP

    /** Whether the hero stands at the level cap of the chapter and banks further experience. */
    fun capped(s: GameState): Boolean = levelCap(s) < Rules.MAX_LEVEL && s.hero.level >= levelCap(s)

    val START = Place("inn", 7, 2, Facing.DOWN)
    val RESPAWN = Place("temple", 4, 4, Facing.UP)

    // Speakers
    private val berta = T("Berta", "Berta")
    private val borin = T("Borin", "Borin")
    private val aldric = T("Ältester Aldric", "Elder Aldric")
    private val tilda = T("Tilda", "Tilda")
    private val odo = T("Bruder Odo", "Brother Odo")
    private val lyra = T("Lyra", "Lyra")
    private val jorin = T("Wache Jorin", "Guard Jorin")
    private val finn = T("Finn", "Finn")
    private val greta = T("Greta", "Greta")
    private val wilhelm = T("Jäger Wilhelm", "Hunter William")
    private val krogg = T("Krogg", "Krogg")
    private val grak = T("Grak", "Grak")
    private val hedda = T("Kräuterfrau Hedda", "Hedda the Herbalist")

    /** Consumables sold by Tilda; her gear stock is generated (see [Loot.shopGear]). */
    val shopStock = listOf("potion", "greater_potion", "superior_potion", "remedy", "alchemist_fire", "holy_water")

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
    private fun inside(map: String) = Place(map, 4, 6, Facing.UP)
    private fun interiorExit(to: Place) = listOf(Warp(4, 7, to))

    // ------------------------------------------------------------------ village

    val village = MapDef(
        id = "village",
        name = T("Bornim", "Bornim"),
        kind = MapKind.TOWN,
        rows = listOf(
            "TTTTTTTTTTT==TTTTTTTTTTT",
            "T.f........==S.......f.T",
            "T.^^^^^....==...^^^^^..T",
            "T.^^^^^....==...^^^^^..T",
            "T.#W#D#....==...#W#D#..T",
            "T....=S....==...S..=...T",
            "T....===============...T",
            "T.........w==..........T",
            "T.f........==........f.T",
            "T.^^^^^....==...MMMMM..T",
            "T.^^^^^....==...MMMMM..T",
            "T.#W#D#....==...#W#D#..T",
            "T....=.....==......=...T",
            "T....===============...T",
            "T.f..........f.........T",
            "T...~~~~~.........f....T",
            "T...~~~~~..............T",
            "T.f.......f......f.....T",
            "T......................T",
            "TTTTTTTTTTTTTTTTTTTTTTTT",
        ),
        warps = listOf(
            Warp(11, 0, Place("forest", 9, 30, Facing.UP), QUEST_STARTED, jorinStop()),
            Warp(12, 0, Place("forest", 10, 30, Facing.UP), QUEST_STARTED, jorinStop()),
            Warp(5, 4, inside("inn")),
            Warp(19, 4, inside("shop")),
            Warp(5, 11, inside("elder")),
            Warp(19, 11, inside("temple")),
        ),
        signs = mapOf(
            (13 to 1) to T("Norden: Flüsterwald.\nAchtung, Goblins!", "North: Whisperwood.\nBeware of goblins!"),
            (6 to 5) to T("Gasthaus »Zum Schlafenden Greif«", "The Sleeping Griffin Inn"),
            (16 to 5) to T("Tildas Kramladen\nWaffen · Rüstungen · Tränke", "Tilda's General Store\nWeapons · Armor · Potions"),
        ),
        npcs = listOf(
            Npc("jorin", 10, 1, "guard", Facing.RIGHT) { s ->
                if (!s.has(QUEST_STARTED)) script {
                    say(jorin, "Halt! Der Flüsterwald ist zu gefährlich geworden.", "Halt! The Whisperwood has become too dangerous.")
                    say(jorin, "Ohne Erlaubnis des Ältesten lasse ich niemanden hinaus.", "I'm not letting anyone out without the Elder's permission.")
                } else if (!s.has(CHAPTER1_DONE)) script {
                    say(jorin, "Der Älteste hat mir Bescheid gegeben. Viel Glück da draußen, {name}!", "The Elder told me about you. Good luck out there, {name}!")
                    say(jorin, "Tipp: Im hohen Gras lauern Monster. Bleib auf dem Weg, wenn du verletzt bist.", "Tip: monsters lurk in the tall grass. Stay on the path when you're hurt.")
                } else script {
                    say(jorin, "Seit du Grak besiegt hast, schlafe ich wieder ruhig. Danke, {name}!", "Since you beat Grak I'm sleeping soundly again. Thanks, {name}!")
                }
            },
            Npc("finn", 9, 8, "child", Facing.DOWN, wander = 3) { s ->
                if (!s.has(CHAPTER1_DONE)) script {
                    say(finn, "Papa sagt, Goblins haben Angst vor Feuer! Stimmt das?", "Dad says goblins are scared of fire! Is that true?")
                    say(finn, "Tilda verkauft Alchemistenfeuer. Damit kann man sogar zaubern, ohne Magier zu sein!", "Tilda sells alchemist's fire. You can do magic with it without even being a wizard!")
                } else script {
                    say(finn, "Wenn ich groß bin, werde ich auch ein Held! Genau wie du!", "When I grow up I'll be a hero too! Just like you!")
                }
            },
            Npc("greta", 9, 15, "villager", Facing.LEFT, wander = 2) { s ->
                if (!s.has(CHAPTER1_DONE)) script {
                    say(greta, "Früher konnte man nachts in Ruhe fischen. Jetzt heulen die Wölfe bis zum Morgengrauen.", "We used to fish here in peace at night. Now the wolves howl until dawn.")
                } else script {
                    say(greta, "Der Held von Bornim! Ich hab's ja immer gewusst.", "The hero of Bornim! I always knew it.")
                }
            },
        ),
    )

    private fun jorinStop() = script {
        say(jorin, "Halt! Ohne Erlaubnis des Ältesten lasse ich niemanden in den Wald.", "Halt! Nobody enters the woods without the Elder's permission.")
        say(jorin, "Sein Haus ist unten links am Dorfplatz.", "His house is at the bottom left of the village square.")
    }

    // ------------------------------------------------------------------ interiors

    val inn = MapDef(
        id = "inn",
        name = T("Zum Schlafenden Greif", "The Sleeping Griffin"),
        kind = MapKind.INTERIOR,
        rows = listOf(
            "##########",
            "#QQkkkkBB#",
            "#kkkkkkkk#",
            "#KKKkkkkk#",
            "#kkkkkYYk#",
            "#kRRRkkkk#",
            "#kRRRkkkk#",
            "####D#####",
        ),
        warps = interiorExit(toVillage(5, 5)),
        npcs = listOf(
            Npc("berta", 2, 2, "innkeeper", Facing.DOWN) { s ->
                when {
                    !s.has(QUEST_STARTED) -> script {
                        say(berta, "Ältester Aldric wartet auf dich. Sein Haus liegt unten links am Dorfplatz.", "Elder Aldric is waiting for you. His house is at the bottom left of the village square.")
                    }
                    !s.has(CHAPTER1_DONE) -> script {
                        say(berta, "Pass auf dich auf, {name}. Wenn du verletzt bist: Bruder Odo im Tempel heilt jeden, der darum bittet.", "Take care, {name}. If you're hurt, Brother Odo at the temple heals anyone who asks.")
                    }
                    else -> script {
                        say(berta, "Für den Helden von Bornim geht das Bier heute aufs Haus!", "Drinks are on the house for the hero of Bornim tonight!")
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
                say(berta, "Na, endlich wach, {name}? Du hast geschlafen wie ein Stein.", "Well, finally awake, {name}? You slept like a rock.")
                say(berta, "Schlimme Zeiten sind das. Seit Wochen überfallen Goblins die Händler auf der Waldstraße.", "These are dark times. For weeks, goblins have been raiding the merchants on the forest road.")
                say(berta, "Und letzte Nacht haben sie Schwester Lyra aus dem Tempel verschleppt – und das heilige Sonnenamulett gleich mit!", "And last night they dragged Sister Lyra out of the temple, and took the holy Sun Amulet too!")
                say(berta, "Ältester Aldric sucht verzweifelt nach Hilfe. Sein Haus liegt unten links am Dorfplatz. Geh zu ihm!", "Elder Aldric is desperate for help. His house is at the bottom left of the village square. Go and see him!")
                narrate("Tipp: Mit dem Steuerkreuz bewegst du dich, mit A sprichst du und untersuchst Dinge. START öffnet das Menü.", "Tip: use the D-pad to move and A to talk and examine things. START opens the menu.")
                flag(INTRO_DONE)
            }
        },
    )

    val shop = MapDef(
        id = "shop",
        name = T("Tildas Kramladen", "Tilda's General Store"),
        kind = MapKind.INTERIOR,
        rows = listOf(
            "##########",
            "#QQQkkQQQ#",
            "#kkkkkkkk#",
            "#kkKKKKkk#",
            "#kkkkkkkk#",
            "#Pkkkkkkk#",
            "#kkkkkkkP#",
            "####D#####",
        ),
        warps = interiorExit(toVillage(19, 5)),
        npcs = listOf(
            Npc("tilda", 4, 2, "merchant", Facing.DOWN) { _ ->
                script {
                    say(tilda, "Willkommen in Tildas Kramladen! Was darf's sein?", "Welcome to Tilda's General Store! What can I get you?")
                    shop(shopStock)
                    say(tilda, "Komm bald wieder!", "Come again soon!")
                }
            },
        ),
    )

    val elderHouse = MapDef(
        id = "elder",
        name = T("Haus des Ältesten", "Elder's House"),
        kind = MapKind.INTERIOR,
        rows = listOf(
            "##########",
            "#QQkkkkBk#",
            "#kkkkkkkk#",
            "#kkYYkkkk#",
            "#kkkkkkPk#",
            "#kRRRRkkk#",
            "#kRRRRkkk#",
            "####D#####",
        ),
        warps = interiorExit(toVillage(5, 12)),
        npcs = listOf(Npc("aldric", 6, 2, "elder", Facing.DOWN) { s -> elderTalk(s) }),
    )

    private fun elderTalk(s: GameState): List<Cmd> = when {
        !s.has(QUEST_STARTED) -> script {
            say(aldric, "Du bist also {name}. Berta sagt, du verstehst dich aufs Kämpfen.", "So you're {name}. Berta tells me you know how to fight.")
            say(aldric, "Der Blutzahn-Stamm haust in einer Höhle am Nordende des Flüsterwalds. Früher waren diese Goblins feige.", "The Bloodfang tribe lives in a cave at the northern end of the Whisperwood. Those goblins used to be cowards.")
            say(aldric, "Doch nun führt sie ein Hobgoblin namens Grak – grausam und gerissen.", "But now they're led by a hobgoblin called Grak, cruel and cunning.")
            say(aldric, "Sie haben Schwester Lyra entführt und das Sonnenamulett gestohlen. Seit hundert Jahren schützt es Bornim vor der Finsternis.", "They kidnapped Sister Lyra and stole the Sun Amulet. For a hundred years it has protected Bornim from the darkness.")
            say(aldric, "Bring beide zurück, und Bornim wird es dir nie vergessen. Nimm dies für die Reise.", "Bring them both back, and Bornim will never forget it. Take this for the road.")
            give("potion", 2)
            gold(50)
            say(aldric, "Wache Jorin am Nordtor wird dich passieren lassen. Möge das Licht dich leiten.", "Guard Jorin at the north gate will let you pass. May the light guide you.")
            flag(QUEST_STARTED)
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
            flag(CHAPTER1_DONE)
            chapterEnd()
        }
        s.has(GRAK_DEFEATED) -> script {
            say(aldric, "Grak ist besiegt? Wunderbar! Aber … wo ist Lyra? Hast du sie in der Höhle nicht gefunden?", "Grak is defeated? Wonderful! But... where is Lyra? Didn't you find her in the cave?")
        }
        else -> script {
            say(aldric, "Die Blutzahnhöhle liegt am Nordende des Flüsterwalds. Sei vorsichtig, {name}.", "The Bloodfang Cave lies at the northern end of the Whisperwood. Be careful, {name}.")
            say(aldric, "Wenn du verletzt bist, geh zu Bruder Odo in den Tempel. Und Tilda verkauft gute Ausrüstung.", "If you're hurt, go to Brother Odo at the temple. And Tilda sells good equipment.")
        }
    }

    val temple = MapDef(
        id = "temple",
        name = T("Tempel des Morgenlichts", "Temple of the Dawnlight"),
        kind = MapKind.INTERIOR,
        rows = listOf(
            "##########",
            "#kkkAAkkk#",
            "#kkkkkkkk#",
            "#YkkkkkkY#",
            "#kkRRRRkk#",
            "#YkRRRRkY#",
            "#kkRRRRkk#",
            "####D#####",
        ),
        warps = interiorExit(toVillage(19, 12)),
        npcs = listOf(
            Npc("odo", 4, 2, "priest", Facing.DOWN) { s ->
                script {
                    if (!s.has(LYRA_RESCUED)) {
                        say(odo, "Willkommen im Tempel des Morgenlichts. Lass mich deine Wunden versorgen.", "Welcome to the Temple of the Dawnlight. Let me tend to your wounds.")
                    } else {
                        say(odo, "Gesegnet seist du, {name}. Lass mich deine Wunden versorgen.", "Blessings upon you, {name}. Let me tend to your wounds.")
                    }
                    rest()
                    narrate("Ein warmes Licht umhüllt dich. TP und ZP sind vollständig wiederhergestellt.", "A warm light surrounds you. HP and SP are fully restored.")
                    if (!s.has(LYRA_RESCUED)) {
                        say(odo, "Bitte … finde Schwester Lyra. Ohne sie und das Amulett ist dieser Tempel nur ein kalter Steinhaufen.", "Please... find Sister Lyra. Without her and the amulet, this temple is just a cold pile of stones.")
                    }
                }
            },
            Npc("lyra_temple", 6, 2, "lyra", Facing.DOWN, visible = { it.has(LYRA_RESCUED) }) { s ->
                if (!s.has(CHAPTER1_DONE)) script {
                    say(lyra, "Danke, dass du mich gerettet hast, {name}. Bitte bring das Amulett zu Ältestem Aldric!", "Thank you for rescuing me, {name}. Please take the amulet to Elder Aldric!")
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
            "TT,,,,,..=...,,,,,TT",
            "TT,,TT,..=..TT,,,,TT",
            "TT,,TT...=...T,,C,TT",
            "TTTTTT..==...TTTTTTT",
            "TT.f...==.....TTTTTT",
            "TT.r..==..r.....TTTT",
            "TT.f..=........,,,TT",
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
            "TT,,,,...=..,,,,,,TT",
            "TT,,TT...=...TT,,,TT",
            "TT,,TT...=...TT,,,TT",
            "TT.ff....=.....r..TT",
            "TTTTT....=...TTTTTTT",
            "TTC,,,...==..,,,,TTT",
            "TT,,,,....=..,,,,,TT",
            "TT,,,,....=..,,,,,TT",
            "TTTT,,....=...,,TTTT",
            "TTTT.f....=S...f.TTT",
            "TTTTTT...==...TTTTTT",
            "TTTTTTTT.==.TTTTTTTT",
            "TTTTTTTTT==TTTTTTTTT",
        ),
        warps = listOf(
            Warp(9, 31, Place("village", 11, 1, Facing.DOWN)),
            Warp(10, 31, Place("village", 12, 1, Facing.DOWN)),
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
            Npc("wilhelm", 12, 9, "hunter", Facing.LEFT) { s ->
                if (!s.has(HUNTER_MET)) script {
                    say(wilhelm, "Ein Abenteurer? Setz dich ans Feuer. Ich bin Wilhelm, Jäger aus Bornim.", "An adventurer? Sit by the fire. I'm William, a hunter from Bornim.")
                    say(wilhelm, "Im hohen Gras lauern Riesenratten, Wölfe und Goblin-Späher. Auf dem Weg bist du sicherer.", "Giant rats, wolves and goblin scouts lurk in the tall grass. You're safer on the path.")
                    say(wilhelm, "An einem Lagerfeuer kannst du rasten – das heilt dich vollständig. Und hier, nimm das.", "You can rest at a campfire to fully heal. And here, take these.")
                    give("potion", 2)
                    flag(HUNTER_MET)
                } else if (!s.has(KROGG_DEFEATED)) script {
                    say(wilhelm, "Ich habe Goblins belauscht. Ihr Bugbear Krogg trägt den Schlüssel zu Graks Halle.", "I overheard some goblins. Their bugbear Krogg carries the key to Grak's hall.")
                    say(wilhelm, "Er haust im Ostflügel der Höhle. Ruh dich vorher gut aus!", "He lurks in the east wing of the cave. Rest well before you face him!")
                } else script {
                    say(wilhelm, "Du siehst aus, als könntest du eine Rast gebrauchen. Das Feuer brennt noch.", "You look like you could use a rest. The fire's still burning.")
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
            SafeZone(12, 9, 4, T("Jäger Wilhelm schwenkt seine Fackel – die Biester weichen zurück!", "Hunter William waves his torch – the beasts back off!")),
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
            "TTTTTTTTTT,,T,,,,,,.T.=.T..T.TT,,,,,,,,,,TTT",
            "TTTTTTTTTT,,,,=,,,,Tf.=...T.TT,,,,,,,,,,,TTT",
            "TTTTTTTTTT,,,,=T,,,,..=.TTTTTT,,T,,=,,,,,,TT",
            "TTTTTTTTTT,,,,=,,,,TT==TTTTTTT,,,,,=,,,,,,TT",
            "TTTTTTTTTTT,,,=,,,TTT=TTTTTTTT,,,,,=,,,,,TTT",
            "TTTTTTTTTTrTT==,TTTTT=TTTTTTTT,,,,,=,,r,,TTT",
            "TTTTT........=TTTTTTT=TTTTTTTTTT,,,=,,TTTTTT",
            "TT.T.........=TTTTTTT=TTTTTTTT,TT,T=,TTTTTTT",
            "TTT....T....==TTTTT..=ff.TTT,,,,,,T=TTTTTTTT",
            "TT.S........=..TT.fT.=..T.,,,,,,,===TTTTTTTT",
            "=======.....=.T......=....,,,,,,,=,TTTTTTTTT",
            "TT....========.r.....=============,,TTTTTTTT",
            "TTT..f..,,,,,==========T..,====,,,,TTTTTTTTT",
            "TTT....,,,,,,,.==.........,,,,=,,,TTTTTTTTTT",
            "TTT.....,,,,,T==.....F.,.,,,,,=,,,TTTTTTTTTT",
            "TTTTTTT...TTTT=TT.....,,,,,,,,=TTTTTTTTTTTTT",
            "TTTTTTTTTTTTTT=TTTT....,,,,,TT====TTTTTTTTTT",
            "TTTTTTTTTTT,T==TTTT.T..TTTTTTT...=....T.TTTT",
            "TTTTTTTTT,,,==,,TTTTTTTTTTTTT....=......TTTT",
            "TTTTTTTT,,,,=,,,,TTTTTTTTTTT...===......TTTT",
            "TTTTTTT,,,,,=,,,,,,,TTTTTTTT...=....~....TTT",
            "TTTTT,T,,,,,=,,,,,,,TTTTTTT....=..~~~~~...TT",
            "TTTTTT,,,,r,=,,,,,,TTTTTTTTT...=.~~~~~~...TT",
            "TTTTT,,,,,,,,,,,,,,TTTTTTTTT......~~~~~C..TT",
            "TTTTTT,,,C,,,,,,,,,TTTTTTTTTT..f....~...TTTT",
            "TTTTTTTr,,,,,,,,,TTTTTTTTTTTTTTT.......TTTTT",
            "TTTTTTTT,,,,,,,,,TTTTTTTTTTTTTTTT.T..TTTTTTT",
            "TTTTTTTTTTTT,TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
            "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
            "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
        ),
        warps = listOf(
            Warp(0, 18, Place("forest", 18, 10, Facing.LEFT)),
        ),
        signs = mapOf(
            (3 to 17) to T("Tiefer Flüsterwald\nHier endet der Weg der Jäger.\nNur für erfahrene Abenteurer!", "Deep Whisperwood\nThe hunters' trail ends here.\nFor seasoned adventurers only!"),
        ),
        chests = listOf(
            Chest("deep_1", 37, 7, randomGear(Rarity.RARE)),
            Chest("deep_2", 9, 32, "remedy", count = 2),
            Chest("deep_3", 39, 31, gold = 120),
            Chest("deep_4", 27, 4, randomGear(Rarity.VERY_RARE)),
        ),
        npcs = listOf(
            Npc("hedda", 24, 21, "herbalist", Facing.LEFT) { s ->
                if (!s.has(HEDDA_MET)) script {
                    say(hedda, "Na sieh an, jemand wagt sich so tief in den Wald. Ich bin Hedda, ich sammle hier Kräuter.", "Well, well, someone dares to come this deep into the woods. I'm Hedda, I gather herbs here.")
                    say(hedda, "Am Feuer bist du sicher: Der Rauch meiner Kräuter hält die Biester fern.", "You're safe by the fire: the smoke of my herbs keeps the beasts away.")
                    say(hedda, "Im Norden haust Grimmzahn, der Leitwolf. Groß wie ein Pony und doppelt so bösartig. Nimm das hier mit.", "In the north lives Grimfang, the alpha wolf. Big as a pony and twice as vicious. Take this with you.")
                    give("remedy", 1)
                    flag(HEDDA_MET)
                    say(hedda, "Bring mir Kräuter von den Blumenwiesen, dann braue ich dir Tränke für ein paar Münzen. Fledermausflügel und Giftdrüsen nehme ich auch.",
                        "Bring me herbs from the flower meadows and I'll brew you potions for a few coins. I'll take bat wings and venom glands too.")
                    shop(HEDDA_STOCK, brewing = true)
                } else script {
                    say(hedda, if (s.has(GRIMFANG_DEFEATED)) "Ohne Grimmzahn ist der Wald ruhiger geworden. Brauchst du Tränke?" else "Brauchst du Tränke? Für Grimmzahn wirst du sie brauchen.",
                        if (s.has(GRIMFANG_DEFEATED)) "The woods are quieter without Grimfang. Need potions?" else "Need potions? You'll need them for Grimfang.")
                    say(hedda, "Bring mir Kräuter von den Blumenwiesen, dann braue ich dir Tränke für ein paar Münzen. Fledermausflügel und Giftdrüsen nehme ich auch.",
                        "Bring me herbs from the flower meadows and I'll brew you potions for a few coins. I'll take bat wings and venom glands too.")
                    shop(HEDDA_STOCK, brewing = true)
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
            SafeZone(21, 21, 4, T("Der beißende Kräuterrauch aus Heddas Feuer vertreibt die Biester!", "The acrid herb smoke from Hedda's fire drives the beasts away!")),
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
            "XXXXXXt________tXXXXXX",
            "XXXXXX__________XXXXXX",
            "XXXXXX__________XXXXXX",
            "XXXXXXXXXX__XXXXXXXXXX",
            "XXXXXXXXXXLLXXXXXXXXXX",
            "XXXXXXXXXX__XXXXXXXXXX",
            "XX______XX__XX______XX",
            "XX_C____XX__XX____C_XX",
            "XX______XX__XX______XX",
            "XX___r______________XX",
            "XX______XX__XX______XX",
            "XXXXX_XXXX__XXXX_XXXXX",
            "XX______XX__XX______XX",
            "XX__C___XX__XX______XX",
            "XX______XX__XX__F___XX",
            "XX__________________XX",
            "XXXXXXXXXX__XXXXXXXXXX",
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
            Npc("lyra_cave", 8, 1, "lyra", Facing.DOWN, visible = { !it.has(LYRA_RESCUED) }) { s ->
                if (!s.has(GRAK_DEFEATED)) grakTalk(s) else script {
                    say(lyra, "Du hast Grak besiegt! Ich bin Lyra, Priesterin des Morgenlichts.", "You defeated Grak! I'm Lyra, priestess of the Dawnlight.")
                    say(lyra, "Sie wollten mich und das Amulett zu jemandem bringen … zum »Grauen Propheten«.", "They were going to take me and the amulet to someone... to the \"Grey Prophet\".")
                    say(lyra, "Ich kehre sofort zum Tempel zurück. Bitte bring das Amulett zu Ältestem Aldric!", "I'll return to the temple at once. Please take the amulet to Elder Aldric!")
                    say(lyra, "Nimm dieses Weihwasser. Gegen Untote wirkt es Wunder.", "Take this holy water. It works wonders against the undead.")
                    give("holy_water", 2)
                    flag(LYRA_RESCUED)
                    narrate("Lyra eilt dem Ausgang entgegen.", "Lyra hurries towards the exit.")
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
            tiles = setOf(Tile.CAVE_FLOOR),
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
        s.has(QUEST_STARTED) -> T("Durchquere den Flüsterwald nach Norden und finde die Blutzahnhöhle.", "Cross the Whisperwood to the north and find the Bloodfang Cave.")
        else -> T("Sprich mit Ältestem Aldric. Sein Haus liegt unten links am Dorfplatz.", "Talk to Elder Aldric. His house is at the bottom left of the village square.")
    }

    val chapterEndText = T(
        "Bornim feiert bis tief in die Nacht. Das Sonnenamulett leuchtet wieder im Tempel, und Schwester Lyra ist in Sicherheit.\n\nDoch der Brief mit dem grauen Siegel lässt dich nicht los. Wer ist der Graue Prophet? Und was ist der Tag der Asche?\n\nENDE VON KAPITEL 1\n\nDu kannst weiterspielen, Monster jagen und deinen Helden verbessern.",
        "Bornim celebrates deep into the night. The Sun Amulet shines in the temple once more, and Sister Lyra is safe.\n\nBut the letter with the grey seal won't leave your mind. Who is the Grey Prophet? And what is the Day of Ashes?\n\nEND OF CHAPTER 1\n\nYou can keep playing, hunt monsters and improve your hero.",
    )
}
