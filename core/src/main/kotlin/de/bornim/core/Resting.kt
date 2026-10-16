package de.bornim.core

/**
 * 86.9/86.10 (Beschluss 14.10., 21:4x): a rest costs time. At a campfire the hero is asked "Rasten?": a short rest
 * of 1 hour fills the breath and gives back a quarter of the HP, a long rest of 8 hours fills HP, SP and breath and
 * cures every ailment, once a game day. Afterwards a fade shows the time gone by. In the inn Rowena pours mead
 * (one fills the breath, the fifth makes the hero drunk, poisoned after the SRD, until the next rest) and lets a
 * room for gold, which is a long rest. Every rest ends a stamina draught (86.6) and the mead. Prices to be tuned.
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
        s.mead = 0
    }

    // Placeholder lines, plain and factual; the wording goes to Kreativ (41).
    val ask = T("Rasten?", "Rest?")
    val tavern = T("Schänke", "Inn")
    val room = T("Zimmer", "Room")
    val short = T("Kurze Rast · 1 Stunde", "Short rest · 1 hour")
    val long = T("Lange Rast · 8 Stunden", "Long rest · 8 hours")
    val shortDoes = T("Ausdauer voll, ein Viertel der TP", "Stamina full, a quarter of HP")
    val longDoes = T("TP, ZP und Ausdauer voll, Zustände weg", "HP, SP and stamina full, conditions gone")
    val longDone = T("Heute hast du schon lange gerastet.", "You have already had a long rest today.")
    val meadBuy = T("Met · {0} Gold", "Mead · {0} gold")
    val meadDoes = T("Ausdauer voll; zu viel macht betrunken", "Stamina full; too much makes you drunk")
    val roomBuy = T("Zimmer · {0} Gold", "Room · {0} gold")
    val roomDoes = T("Lange Rast, 8 Stunden", "Long rest, 8 hours")
    val leave = T("Weiter", "Go on")
    val hourGone = T("Eine Stunde vergeht.", "An hour passes.")
    val hoursGone = T("Acht Stunden vergehen.", "Eight hours pass.")
    val shortRested = T("Du hast eine Stunde gerastet. Die Ausdauer ist voll, du erhältst {0} TP zurück.", "You rested for an hour. Your stamina is full, you recover {0} HP.")
    val longRested = T("Du hast acht Stunden gerastet. TP, ZP und Ausdauer sind voll.", "You rested for eight hours. HP, SP and stamina are full.")
    val meadDrunk = T("Du trinkst einen Met. Du bist erholt, die Ausdauer ist voll.", "You drink a mead. You feel refreshed, your stamina is full.")
    val drunkNow = T("Du trinkst einen Met. Du bist betrunken (Vergiftet) bis zur nächsten Rast.", "You drink a mead. You are drunk (poisoned) until your next rest.")
    val noGold = T("Dafür reicht dein Gold nicht.", "You don't have enough gold for that.")
    val staminaDrunk = T("{0} trinkt den Ausdauertrank. Bis zur nächsten Rast reicht der Atem doppelt so lange.", "{0} drinks the stamina draught. Until the next rest, the breath lasts twice as long.")
    val staminaAlready = T("Der Ausdauertrank wirkt noch bis zur nächsten Rast.", "The stamina draught still works until the next rest.")
}
