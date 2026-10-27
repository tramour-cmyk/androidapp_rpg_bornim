package de.bornim.core

/**
 * 86.9/86.10 (Beschluss 14.10., 21:4x): a rest costs time. At a campfire the hero is asked "Rasten?": a short rest
 * of 1 hour fills the breath and gives back a quarter of the HP, a long rest of 8 hours fills HP, SP and breath and
 * cures every ailment, once a game day. Afterwards a fade shows the time gone by. In the inn Rowena pours mead
 * (one fills the breath, the fifth makes the hero drunk, poisoned after the SRD, until the next rest) and lets a
 * room for gold, which is a long rest. Every rest ends a stamina draught (86.6), the spark of light (84.5) and the mead. Prices to be tuned.
 */
object Resting {
    const val SHORT_MIN = 60
    const val LONG_MIN = 8 * 60
    /** The fifth mead makes the hero drunk. */
    const val DRUNK = 5
    const val MEAD_PRICE = 2
    const val ROOM_PRICE = 5

    enum class Kind(val minutes: Int) { SHORT(SHORT_MIN), LONG(LONG_MIN) }

    /** Where the hero is asked: by a campfire, at Rowena's counter, at the bed of the inn. */
    enum class Spot { FIRE, TAVERN, ROOM }

    /** What a mead costs: nothing while Rowena says the drinks are on the house for the hero of Bornim (after chapter 1). */
    fun meadPrice(s: GameState): Int = if (s.has(Story.CHAPTER1_DONE) && !s.has(Story.CAMP_TOLD)) 0 else MEAD_PRICE

    /** One long rest a game day: not again on the day the last one ended. */
    fun longAllowed(s: GameState): Boolean = s.longRestDay != s.day

    /** HP a short rest gives back: a quarter, rounded up. */
    fun shortHeal(hero: Hero): Int = (hero.maxHp + 3) / 4

    /** Moves the clock on by [minutes], day by day. */
    fun pass(s: GameState, minutes: Int) {
        var m = s.minutes + minutes
        while (m >= 24 * 60) { m -= 24 * 60; s.day++ }
        s.minutes = m
    }

    /** What every rest ends: the draught, the mead, the breath is full. */
    fun ends(s: GameState) {
        Stamina.refill(s)
        s.staminaBoost = false
        s.spark = false
        s.mead = 0
    }

    // Placeholder lines, plain and factual; the wording goes to Kreativ (41).
    val ask = T("Rasten?", "Rest?")
    val tavern = T("Schänke", "Inn")
    val room = T("Zimmer", "Room")
    val short = T("Kurze Rast · 1 Stunde", "Short rest · 1 hour")
    val long = T("Lange Rast · 8 Stunden", "Long rest · 8 hours")
    // [86.kurzwirkt]
    val shortDoes = T("Ausdauer voll, ein Viertel der TP zurück", "Full stamina, regain a quarter of your HP")
    // [86.langwirkt]
    val longDoes = T("TP, ZP und Ausdauer voll, Zustände geheilt", "HP, SP and stamina full, conditions cured")
    val longDone = T("Heute hast du schon lange gerastet.", "You have already had a long rest today.")
    val meadBuy = T("Met · {0} Gold", "Mead · {0} gold")
    val meadDoes = T("Ausdauer voll; zu viel macht betrunken", "Stamina full; too much makes you drunk")
    val roomBuy = T("Zimmer · {0} Gold", "Room · {0} gold")
    // [86.zimmerwirkt]
    val roomDoes = T("Ein Bett für die Nacht: lange Rast", "A bed for the night: long rest")
    val leave = T("Weiter", "Continue")
    val hourGone = T("Eine Stunde vergeht.", "An hour passes.")
    val hoursGone = T("Acht Stunden vergehen.", "Eight hours pass.")
    // [86.kurzfertig]
    val shortRested = T("Eine Stunde Ruhe. Die Ausdauer ist voll, +{0} TP.", "An hour of rest. Your stamina is full, +{0} HP.")
    // [86.langfertig]
    val longRested = T("Acht Stunden Schlaf. TP, ZP und Ausdauer sind voll.", "Eight hours of sleep. HP, SP and stamina are full.")
    // [86.met]
    val meadDrunk = T("Der Met wärmt. Die Ausdauer ist voll.", "The mead warms you. Your stamina is full.")
    // [86.metzuviel]
    val drunkNow = T("Ein Met zu viel. Du bist betrunken bis zur nächsten Rast.", "One mead too many. You are drunk until your next rest.")
    // [86.rowena.met], [86.rowena.zimmer]: Rowena when the inn's panel opens, one or the other; [86.rowena.genug] while the hero is drunk
    val rowenaMead = T("Rowena: „Ein Met wärmt die Beine. Nach dem vierten findest du die Tür aber nicht mehr.“", "Rowena: “A mead warms the legs. After the fourth, though, you won't find the door.”")
    val rowenaRoom = T("Rowena: „Oben ist ein Zimmer frei. Frische Laken, und keiner schnarcht durch die Wand. Meistens.“", "Rowena: “There's a room free upstairs. Fresh sheets, and nobody snores through the wall. Mostly.”")
    val rowenaEnough = T("Rowena: „Genug für heute, {name}. Geh schlafen, die Treppe ist links.“", "Rowena: “Enough for today, {name}. Go to bed, the stairs are on the left.”")

    /** 86: what Rowena says as the panel opens; [second] picks the room over the mead. */
    fun rowenaSays(s: GameState, name: String, second: Boolean): T {
        val t = if (s.drunk) rowenaEnough else if (second) rowenaRoom else rowenaMead
        return T(t.de.replace("{name}", name), t.en.replace("{name}", name))
    }
    /** 139: Rowena buys the hero's raw meat at the counter, at the shop's price. */
    val meatSell = T("Fleisch verkaufen · {0} Gold", "Sell meat · {0} gold")
    // [139.rowena.danke]
    val meatThanks = T("Rowena: „Ehrlicher Preis für ehrliche Ware. Komm wieder, wenn du mehr erlegst.“", "Rowena: “An honest price for honest goods. Come back when you've hunted more.”")
    val noGold = T("Dafür reicht dein Gold nicht.", "You don't have enough gold for that.")
    val staminaDrunk = T("{0} trinkt den Ausdauertrank. Bis zur nächsten Rast reicht der Atem doppelt so lange.", "{0} drinks the stamina draught. Until the next rest, your stamina lasts twice as long.")
    val staminaAlready = T("Der Ausdauertrank wirkt noch bis zur nächsten Rast.", "The stamina draught lasts until your next rest.")
}
