package de.bornim.core

/**
 * Odd jobs from the notice board before the inn (29). Each is free to take or leave (33): the player takes one up at
 * the board, sees it in the menu with how far along it is, may give it up again, and hands it in by speaking to the
 * one who asked. All of it lives in flags, so saves need no new field: "job_<id>" taken, "job_<id>_done" finished,
 * "job_<id>_seen" read on the board. New notes come in waves along the story (29g): a job with [Job.after] is nailed
 * up once that flag is set; nothing runs out and nothing comes twice. A note not yet read shows on the board as a
 * fresh, pale one ([freshNote]), the only hint (33: the player is never pushed).
 */
object Jobs {
    data class Job(
        val id: String,
        /** The npc who asked for it and takes it back. */
        val giver: String,
        val giverName: T,
        val title: T,
        /** What the note on the board says. */
        val note: T,
        val reward: T,
        /** What to bring and how many. */
        val item: String,
        val count: Int,
        val gold: Int,
        /** Things given besides the gold, and how many of each ("@gear:RARITY:SLOT" for a piece of gear). */
        val gifts: List<Pair<String, Int>> = emptyList(),
        /** What the hero says first on handing in (29.4), so the giver's answer does not come out of nowhere. */
        val bring: T,
        /** What the giver says on handing in. */
        val thanks: T,
        /** The story flag after which the note is nailed up, or null for the first notes. */
        val after: String? = null,
    )

    /** Gwenna's ring, lying in the cave's chest [RING_CHEST] once the job is taken (map data stays as it is). */
    const val RING = "gwenna_ring"
    const val RING_CHEST = "cave_3"

    /** The grey rag Jorin wants (29.3), found among the standing stones of the Whisperwood once his job is taken. */
    const val RAG = "grey_rag"
    const val RAG_MAP = "forest"

    val all = listOf(
        Job(
            "pelts", "thessa", T("Thessa", "Thessa"),
            T("Felle für den Winter", "Pelts for the winter"),
            T("Suche fünf Wolfsfelle, dicht und ohne Löcher. Der Winter kommt früh dieses Jahr. Bezahlung bei Thessa im Kramladen.",
                "Wanted: five wolf pelts, thick and whole. Winter is coming early this year. Payment from Thessa at the general store."),
            T("60 Gold", "60 gold"),
            "wolf_pelt", 5, gold = 60,
            bring = T("Fünf Wolfsfelle, wie am Brett verlangt. Dicht und ohne Löcher.", "Five wolf pelts, as the board asked. Thick and whole."),
            thanks = T("Fünf. Gut. Die Felle riechen noch nach Blut – das wäscht sich aus. Hier, dein Lohn.",
                "Five. Good. They still smell of blood – that washes out. Here, your pay."),
        ),
        Job(
            "ring", "gwenna", T("Gwenna", "Gwenna"),
            T("Gwennas Ring", "Gwenna's ring"),
            T("Mein Mann trug meinen Ring, als die Goblins ihn in ihre Höhle schleppten. Er kam nicht zurück. Bringt mir wenigstens den Ring. – Gwenna, am Fluss",
                "My husband wore my ring when the goblins dragged him into their cave. He did not come back. At least bring me the ring. – Gwenna, by the river"),
            T("40 Gold, ein Heiltrank", "40 gold, a Potion of Healing"),
            RING, 1, gold = 40, gifts = listOf("potion" to 1),
            bring = T("Gwenna? Ich war in der Höhle. Ich habe deinen Ring gefunden.", "Gwenna? I've been in the cave. I found your ring."),
            thanks = T("Das ist er. Er ist kalt … Danke. Mehr kann ich dir nicht geben.",
                "That's the one. It's cold… Thank you. It's all I can give you."),
        ),
        Job(
            "tusks", "borin", T("Borin", "Borin"),
            T("Hauer für den Schmied", "Tusks for the smith"),
            T("Brauche drei Keilerhauer für Griffschalen. Keine Splitter. Borin, in der Schänke.",
                "Need three boar tusks for handle scales. No splinters. Borin, at the inn."),
            T("50 Gold", "50 gold"),
            "boar_tusk", 3, gold = 50,
            bring = T("Drei Keilerhauer, für deine Griffschalen.", "Three boar tusks, for your handle scales."),
            thanks = T("Hm. Ordentlich gebrochen, nicht geschnitten. Damit lässt sich arbeiten. Nimm.",
                "Hm. Broken clean, not sawn. I can work with these. Take this."),
        ),
        // the second wave (29.3): once Krogg is dead the road to the woods is open and folk dare to ask for more
        Job(
            "glands", "morwen", T("Morwen", "Morwen"),
            T("Gift gegen Gift", "Venom for venom"),
            T("Drei Giftdrüsen von Riesenspinnen, ganz, nicht zerquetscht. Ich zahle in Gold und Tränken. Wer mich sucht, findet mich tief im Wald am Feuer. – Morwen",
                "Three venom glands from giant spiders, whole, not crushed. I pay in gold and potions. Whoever looks for me finds me deep in the woods by the fire. – Morwen"),
            T("50 Gold, zwei Kräutertränke", "50 gold, two herbal remedies"),
            "spider_gland", 3, gold = 50, gifts = listOf("remedy" to 2),
            bring = T("Deine Giftdrüsen, Morwen. Drei Stück, ganz.", "Your venom glands, Morwen. Three, whole."),
            thanks = T("Drei, und keine geplatzt. Du hast ruhige Hände. Hier – und trink nicht alles auf einmal.",
                "Three, and none burst. You have steady hands. Here – and don't drink it all at once."),
            after = Story.KROGG_DEFEATED,
        ),
        Job(
            "stones", "jorin", T("Wache Jorin", "Guard Jorin"),
            T("Feuer am Steinkreis", "Fire at the standing stones"),
            T("Nachts brennt ein Feuer am Steinkreis im Süden des Flüsterwaldes. Goblins sind es nicht, die meiden die Steine. Sieh nach und bring mir, was du findest. Ich darf den Schlagbaum nicht verlassen. – Jorin, Wache",
                "At night a fire burns at the standing stones in the south of the Whisperwood. It isn't goblins; they shun the stones. Go and look, and bring me what you find. I'm not allowed to leave the barrier. – Jorin, guard"),
            T("ein Kopfschutz aus der Wachstube", "headgear from the guardroom"),
            RAG, 1, gold = 0, gifts = listOf("@gear:UNCOMMON:HEAD" to 1),
            bring = T("Am Steinkreis war niemand mehr. Nur kalte Asche, Spuren nach Norden – und das hier.", "There was no one left at the standing stones. Only cold ash, tracks heading north – and this."),
            thanks = T("Ein offenes Auge … So ein Zeichen habe ich noch nie gesehen. Das geht an den Ältesten. Nimm das aus der Wachstube, auf deinem Kopf nützt es mehr als im Regal.",
                "An open eye… I've never seen a sign like that. This goes to the Elder. Take this from the guardroom; it's more use on your head than on the shelf."),
            after = Story.KROGG_DEFEATED,
        ),
    )

    /** The hero as speaker: the name is put in when the line is shown. */
    val HERO = T("{name}", "{name}")

    operator fun get(id: String) = all.first { it.id == id }

    private fun taken(id: String) = "job_$id"
    private fun done(id: String) = "job_${id}_done"
    private fun seen(id: String) = "job_${id}_seen"

    fun isTaken(s: GameState, j: Job) = s.has(taken(j.id)) && !s.has(done(j.id))
    fun isDone(s: GameState, j: Job) = s.has(done(j.id))

    /** Whether the note is up yet: its wave has come. */
    fun isUp(s: GameState, j: Job) = j.after == null || s.has(j.after)

    /** The notes on the board: everything up and not yet finished, taken or not. */
    fun onBoard(s: GameState): List<Job> = all.filter { isUp(s, it) && !isDone(s, it) }

    /** Whether a note hangs on the board that the hero has not read yet: the board then shows a fresh one. */
    fun freshNote(s: GameState): Boolean = onBoard(s).any { !s.has(seen(it.id)) }

    /** The hero reads the board: every note up is now known. */
    fun read(s: GameState) { for (j in onBoard(s)) s.flags += seen(j.id) }

    /** The jobs the hero carries, for the menu. */
    fun carried(s: GameState): List<Job> = all.filter { isTaken(s, it) }

    /** How many of the wanted things the hero has (at most the count wanted). */
    fun progress(s: GameState, j: Job): Int = minOf(s.count(j.item), j.count)

    fun take(s: GameState, j: Job) { if (!isDone(s, j)) s.flags += taken(j.id) }

    /** Gives a job up: it goes back on the board, a ring found stays in the bag. */
    fun drop(s: GameState, j: Job) { s.flags -= taken(j.id) }

    /** What [npc] says when the hero brings what a taken job of theirs asks for, or null to talk as ever. */
    fun handIn(s: GameState, npc: String): List<Cmd>? {
        val j = all.firstOrNull { it.giver == npc && isTaken(s, it) && s.count(it.item) >= it.count } ?: return null
        return listOf(
            Cmd.Say(HERO, j.bring),
            Cmd.Say(j.giverName, j.thanks),
            Cmd.Take(j.item, j.count),
            Cmd.SetFlag(done(j.id)),
        ) + listOfNotNull(if (j.gold > 0) Cmd.GiveGold(j.gold) else null) + j.gifts.map { (id, n) -> Cmd.Give(id, n) }
    }

    /** Whether opening [chest] turns up Gwenna's ring: the job taken, the ring neither in the bag nor handed in. */
    fun ringIn(s: GameState, chest: String): Boolean =
        chest == RING_CHEST && isTaken(s, this["ring"]) && s.count(RING) == 0

    /** What the hero finds when looking at [tile] on [map] while Jorin's job is taken (29.3), or null for nothing. */
    fun findAt(s: GameState, map: String, tile: Tile): List<Cmd>? {
        if (map != RAG_MAP || tile != Tile.MENHIR || !isTaken(s, this["stones"]) || s.count(RAG) > 0) return null
        return listOf(
            Cmd.Say(null, T("Zwischen den Steinen: kalte Asche, Stiefelspuren, die nach Norden führen. Am Fuß eines Steins hängt ein Fetzen grauen Tuchs, ein offenes Auge ist hineingestickt.",
                "Between the stones: cold ashes, boot prints leading north. At the foot of a stone hangs a scrap of gray cloth, an open eye stitched into it.")),
            Cmd.Give(RAG),
        )
    }
}
