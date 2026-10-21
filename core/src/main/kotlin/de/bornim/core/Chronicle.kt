package de.bornim.core

/**
 * 64d: "So far" in the chronicle, told by a chronicler: one entry per turning point of the story, the newest on top.
 * The texts are the ones agreed by the user and Homer (`docs/STORY-K1-WELT.md`, marks `[64d.…]`), word for word.
 */
object Chronicle {
    class Entry(val id: String, val side: Boolean, val title: T, val text: T, val reached: (GameState) -> Boolean)

    val entries = listOf(
        Entry("greif", false, T("Ein Fremder im Greif", "A Stranger at the Griffin"),
            T("In der Nacht, in der {name} im Gasthaus »Zum Schlafenden Greif« schlief, kamen die Goblins bis in den Tempel. Sie verschleppten Schwester Lyra und raubten das Sonnenamulett, das Bornim seit hundert Jahren vor der Finsternis schützt. Am Morgen schickte die Wirtin Rowena den Fremden zum Ältesten.",
                "On the night {name} slept at the Sleeping Griffin inn, the goblins came as far as the temple. They carried off Sister Lyra and stole the Sun Amulet, which has shielded Bornim from the darkness for a hundred years. In the morning Rowena, the innkeeper, sent the stranger to the Elder.")) { true },
        Entry("auftrag", false, T("Der Auftrag", "The Task"),
            T("Ältester Aldric erzählte vom Blutzahn-Stamm in der Höhle am Nordende des Flüsterwalds. Früher waren diese Goblins feige, nun führt sie ein Hobgoblin namens Grak an. Aldric bat {name}, Lyra und das Amulett zurückzubringen, und gab Tränke und Gold mit auf den Weg.",
                "Elder Aldric told of the Bloodfang tribe in the cave at the north end of the Whisperwood. These goblins used to be cowards; now a hobgoblin named Grak leads them. Aldric asked {name} to bring back Lyra and the amulet, and gave potions and gold for the road.")) { it.has(Story.QUEST_STARTED) },
        Entry("schlagbaum", false, T("Der Schlagbaum hebt sich", "The Barrier Lifts"),
            T("Auf Weisung des Ältesten löste Wache Jorin das Seil, und der Schlagbaum am Nordweg schwang nach oben. Seit dem Überfall hatte er niemanden mehr nach Norden gelassen.",
                "At the Elder's word, Jorin the guard untied the rope, and the barrier on the north road swung up. Since the raid he had let no one go north.")) { it.has(Story.BARRIER_OPEN) },
        Entry("garrick", false, T("Am Feuer des Jägers", "At the Hunter's Fire"),
            T("Im Flüsterwald traf {name} auf Garrick, einen Jäger aus Bornim, der an seinem Feuer die Biester mit der Fackel fernhält. Er riet, auf dem Weg zu bleiben, und erzählte von Graks Schergen.",
                "In the Whisperwood {name} met Garrick, a hunter from Bornim who keeps the beasts away from his fire with a torch. He advised staying on the path and told of Grak's henchmen.")) { it.has(Story.HUNTER_MET) },
        Entry("hoehle", false, T("Die Blutzahnhöhle", "The Bloodfang Cave"),
            T("Am Nordende des Waldes warnte ein Schild der Goblins jeden, der weitergeht. {name} ging weiter. Aus der Tiefe kamen Moder, tropfendes Wasser und ein Lachen.",
                "At the north end of the woods a goblin sign warned anyone who went on. {name} went on. From the depths came rot, dripping water and laughter.")) { it.place.map == "cave" || it.explored.containsKey("cave") },
        Entry("krogg", false, T("Kroggs Schlüssel", "Krogg's Key"),
            T("Im Ostflügel der Höhle bewachte der Grottenschrat Krogg den Schlüssel zu Graks Halle. {name} besiegte ihn und nahm den rostigen Schlüssel von seinem Gürtel.",
                "In the east wing of the cave the bugbear Krogg guarded the key to Grak's hall. {name} defeated him and took the rusty key from his belt.")) { it.has(Story.KROGG_DEFEATED) },
        Entry("gitter", false, T("Das Gitter", "The Gate"),
            T("Mit Kroggs Schlüssel öffnete {name} das Gitter in der Mitte der Höhle. Dahinter lag der Gang zu Graks Halle.",
                "With Krogg's key {name} opened the gate in the middle of the cave. Behind it lay the passage to Grak's hall.")) { it.has(Story.GATE_OPEN) },
        Entry("grak", false, T("Graks Fall", "Grak's Fall"),
            T("Grak prahlte, ein Prophet zahle ihm Gold für jede Seele, und die Priesterin gehöre schon ihm. {name} besiegte den Hobgoblin. Bei ihm lagen das Sonnenamulett und ein versiegelter Brief.",
                "Grak boasted that a prophet paid him gold for every soul, and that the priestess was already his. {name} defeated the hobgoblin. Beside him lay the Sun Amulet and a sealed letter.")) { it.has(Story.GRAK_DEFEATED) },
        Entry("lyra", false, T("Lyra ist frei", "Lyra Is Free"),
            T("In Graks Halle fand {name} Schwester Lyra, Priesterin des Morgenlichts. Sie sollte mit dem Amulett zu einem »Grauen Propheten« gebracht werden. Lyra kehrte sofort in den Tempel zurück.",
                "In Grak's hall {name} found Sister Lyra, priestess of the Morning Light. She was to be taken to a \"Grey Prophet\" along with the amulet. Lyra went straight back to the temple.")) { it.has(Story.LYRA_RESCUED) },
        Entry("brief", false, T("Der Brief mit dem grauen Auge", "The Letter with the Grey Eye"),
            T("{name} brachte das Amulett zu Aldric. Der Brief trug ein graues Auge als Siegel und forderte Amulett und Priesterin, denn der Tag der Asche nahe. Aldric hielt den Grauen Propheten bisher für ein Märchen, um Kinder zu erschrecken; nun gab er {name} den Ring seines Vaters.",
                "{name} brought the amulet to Aldric. The letter bore a grey eye as its seal and demanded the amulet and the priestess, for the Day of Ash was near. Until then Aldric had taken the Grey Prophet for a tale to frighten children; now he gave {name} his father's ring.")) { it.has(Story.CHAPTER1_DONE) },
        Entry("grimmzahn", true, T("Grimmzahn", "Grimfang"),
            T("Tief im Flüsterwald warnte die Kräuterfrau Morwen vor Grimmzahn, einem Leitwolf, groß wie ein Pony. {name} stellte ihn im Norden des Tiefen Waldes. Seitdem ist es dort ruhiger.",
                "Deep in the Whisperwood, Morwen the herbwoman warned of Grimfang, a pack leader as big as a pony. {name} tracked him down in the north of the deep woods. It has been quieter there since.")) { it.has(Story.GRIMFANG_DEFEATED) },
        Entry("auge", true, T("Das offene Auge", "The Open Eye"),
            T("Jorin hatte nachts ein Feuer am Steinkreis gesehen, den selbst Goblins meiden. {name} fand nur kalte Asche, Stiefelspuren nach Norden und einen grauen Fetzen Tuch mit einem eingestickten offenen Auge. Jorin wollte es dem Ältesten bringen.",
                "At night Jorin had seen a fire at the standing stones, which even goblins avoid. {name} found only cold ash, boot prints heading north and a grey scrap of cloth with an open eye stitched into it. Jorin meant to take it to the Elder.")) { it.count(Jobs.RAG) > 0 || Jobs.isDone(it, Jobs["stones"]) },
    )

    /** A task of the story beside the main one (D4.1): shown under "Aufträge" from [given] until [done]. */
    class Task(val id: String, val title: T, val text: T, val given: (GameState) -> Boolean, val done: (GameState) -> Boolean)

    val tasks = listOf(
        Task("rauch", T("Rauch gegen Krogg", "Smoke against Krogg"),
            T("Garrick riet {name}, vor dem Kampf gegen Krogg die Kräuterfrau Morwen im Tiefen Flüsterwald aufzusuchen. Sie kenne ein Mittel gegen den ersten Hieb eines Grottenschrats.",
                "Garrick advised {name} to seek out Morwen the herbwoman in the Deep Whisperwood before fighting Krogg. He said she knew a means against a bugbear's first blow."),
            given = { it.has(Story.KROGG_HINT) },
            done = { it.has(Story.SMOKE_GIVEN) || it.has(Story.KROGG_DEFEATED) }),
        // [68.chronik.lager] (68k: no mark on the map); done when chapter 2 says so
        Task("lager", T("Das Lager im Süden", "The Camp in the South"),
            T("Lyra erinnerte sich, dass Graks Leute von einem Lager im Süden sprachen, in das sie Gefangene brachten. Wer dort festgehalten wird und wer das Lager führt, weiß niemand in Bornim.",
                "Lyra remembered that Grak's men spoke of a camp in the south where they took prisoners. Who is held there and who runs the camp, no one in Bornim knows."),
            given = { it.has(Story.CAMP_TOLD) },
            done = { false }),
    )

    /** Story tasks the hero carries now. */
    fun openTasks(s: GameState): List<Task> = tasks.filter { it.given(s) && !it.done(s) }

    /** Story tasks once given and now done. */
    fun doneTasks(s: GameState): List<Task> = tasks.filter { it.given(s) && it.done(s) }

    private fun read(id: String) = "chron_$id"

    /** 64: something in the chronicle the player has not looked at yet (a new entry, a job taken): a dot at the tab. */
    fun fresh(s: GameState): Boolean =
        entries.any { it.reached(s) && !s.has(read(it.id)) } || Jobs.carried(s).any { !s.has(read("job_" + it.id)) } ||
            openTasks(s).any { !s.has(read("task_" + it.id)) }

    /** Called when the chronicle is opened: everything in it counts as seen. */
    fun markRead(s: GameState) {
        for (e in entries) if (e.reached(s)) s.flags += read(e.id)
        for (j in Jobs.carried(s)) s.flags += read("job_" + j.id)
        for (t in openTasks(s)) s.flags += read("task_" + t.id)
    }

    /** What has happened so far, the newest first. */
    fun sofar(s: GameState): List<Entry> = entries.filter { it.reached(s) }.reversed()
}
