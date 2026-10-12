package de.bornim.core

/**
 * Odd jobs from the notice board before the inn (29). Each is free to take or leave (33): the player takes one up at
 * the board, sees it in the menu with how far along it is, may give it up again, and hands it in by speaking to the
 * one who asked. All of it lives in flags, so saves need no new field: "job_<id>" taken, "job_<id>_done" finished.
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
        val gift: String? = null,
        /** What the giver says on handing in. */
        val thanks: T,
    )

    /** Gwenna's ring, lying in the cave's chest [RING_CHEST] once the job is taken (map data stays as it is). */
    const val RING = "gwenna_ring"
    const val RING_CHEST = "cave_3"

    val all = listOf(
        Job(
            "pelts", "thessa", T("Thessa", "Thessa"),
            T("Felle für den Winter", "Pelts for the winter"),
            T("Suche fünf Wolfsfelle, dicht und ohne Löcher. Der Winter kommt früh dieses Jahr. Bezahlung bei Thessa im Kramladen.",
                "Wanted: five wolf pelts, thick and whole. Winter comes early this year. Payment from Thessa at the general store."),
            T("60 Gold", "60 gold"),
            "wolf_pelt", 5, gold = 60,
            thanks = T("Fünf. Gut. Die Felle riechen noch nach Blut – das wäscht sich aus. Hier, dein Lohn.",
                "Five. Good. They still smell of blood – that washes out. Here, your pay."),
        ),
        Job(
            "ring", "gwenna", T("Gwenna", "Gwenna"),
            T("Gwennas Ring", "Gwenna's ring"),
            T("Mein Mann trug meinen Ring, als die Goblins ihn in ihre Höhle schleppten. Er kam nicht zurück. Bringt mir wenigstens den Ring. – Gwenna, am Fluss",
                "My husband wore my ring when the goblins dragged him into their cave. He did not come back. Bring me the ring at least. – Gwenna, by the river"),
            T("40 Gold, ein Heiltrank", "40 gold, a healing potion"),
            RING, 1, gold = 40, gift = "potion",
            thanks = T("Das ist er. Er ist kalt … Danke. Mehr kann ich dir nicht geben.",
                "That's it. It's cold … Thank you. It's all I can give you."),
        ),
        Job(
            "tusks", "borin", T("Borin", "Borin"),
            T("Hauer für den Schmied", "Tusks for the smith"),
            T("Brauche drei Keilerhauer für Griffschalen. Keine Splitter. Borin, in der Schänke.",
                "Need three boar tusks for grip plates. No splinters. Borin, at the inn."),
            T("50 Gold", "50 gold"),
            "boar_tusk", 3, gold = 50,
            thanks = T("Hm. Ordentlich gebrochen, nicht geschnitten. Damit lässt sich arbeiten. Nimm.",
                "Hm. Broken clean, not sawn. I can work with these. Take this."),
        ),
    )

    operator fun get(id: String) = all.first { it.id == id }

    private fun taken(id: String) = "job_$id"
    private fun done(id: String) = "job_${id}_done"

    fun isTaken(s: GameState, j: Job) = s.has(taken(j.id)) && !s.has(done(j.id))
    fun isDone(s: GameState, j: Job) = s.has(done(j.id))

    /** The notes on the board: everything not yet finished, taken or not. */
    fun onBoard(s: GameState): List<Job> = all.filter { !isDone(s, it) }

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
            Cmd.Say(j.giverName, j.thanks),
            Cmd.Take(j.item, j.count),
            Cmd.SetFlag(done(j.id)),
            Cmd.GiveGold(j.gold),
        ) + listOfNotNull(j.gift?.let { Cmd.Give(it) })
    }

    /** Whether opening [chest] turns up Gwenna's ring: the job taken, the ring neither in the bag nor handed in. */
    fun ringIn(s: GameState, chest: String): Boolean =
        chest == RING_CHEST && isTaken(s, this["ring"]) && s.count(RING) == 0
}
