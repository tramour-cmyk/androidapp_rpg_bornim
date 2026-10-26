package de.bornim.core

/**
 * 84.1/84.5 (Chef 18.10.): what the hero carries for light. In the dark (night outdoors, always in a cave) he sees
 * 4.2 tiles; a spark of light ([GameState.spark]) lifts that to about 5.5, a torch in the off hand to about 6.5. The
 * spark lasts until the next rest ([Resting.ends]) or until it is put out, and it gives the hero away: hunting
 * monsters notice him 2 tiles sooner, sneaking or not. By day neither changes anything.
 */
object Light {
    const val SPARK_ITEM = "spark_potion"
    const val DARK_SIGHT = 4.2
    const val DAY_SIGHT = 5.2
    const val SPARK_SIGHT = 5.5
    const val TORCH_SIGHT = 6.5
    /** Tiles sooner a hunting monster notices a hero under a spark. */
    const val SPARK_NOTICE = 2

    /** Whether the hero carries a torch: one in the off hand. */
    fun torch(s: GameState): Boolean = s.hero.item(GearSlot.OFF_HAND)?.def?.kind == BaseKind.LIGHT

    /**
     * 344.1 (Chef 23.10., 18:27, replaces 255 "out by day"): the torch burns everywhere but in a lit [room] (houses,
     * the inn, the shop, the temple), day and night; there it is held out, without a flame. No laying it down, no message.
     */
    fun burns(s: GameState, room: Boolean): Boolean = !room && torch(s)

    /** How far the hero sees, before wisdom ([Perks.sightBonus]). */
    fun sight(s: GameState, dark: Boolean): Double = when {
        !dark -> DAY_SIGHT
        torch(s) -> TORCH_SIGHT
        s.spark -> SPARK_SIGHT
        else -> DARK_SIGHT
    }

    /** Tiles added to how close a hunting monster must come to notice the hero. */
    fun noticeExtra(s: GameState, dark: Boolean): Int = if (dark && s.spark) SPARK_NOTICE else 0

    /** Puts the spark out; out is out (Chef 17.10.). */
    fun putOut(s: GameState) { s.spark = false }

    // 84.1T: Homer's lines, word for word (STORY-SPIEL.md [84.1.…], [84.5.…])
    /** [84.1.laden] */
    val torchAbout = T("Pech und Werg auf einem Stock. In der Nebenhand, statt eines Schilds. Im Dunkeln siehst du weiter als mit einem Leuchtfunken. Brennt, solange du sie trägst.",
        "Pitch and tow on a stick. Held in the off hand, instead of a shield. In the dark you see further than with a Lightspark. Burns as long as you carry it.")
    /** [84.1.an] */
    val torchLit = T("Du zündest die Fackel an.", "You light the torch.")
    /** [84.1.aus] */
    val torchSnuffed = T("Du drückst die Fackel aus. Das Dunkel rückt heran.", "You snuff out the torch. The dark closes in.")
    /** [84.5.trinken] */
    val sparkDrunk = T("Du trinkst das Fläschchen. Ein Funke steigt auf und bleibt über deinem Kopf stehen.", "You drain the vial. A spark rises and settles above your head.")
    /** [84.5.schon] */
    val sparkAlready = T("Dein Funke leuchtet noch.", "Your spark is still glowing.")
    /** [84.5.taste] */
    val sparkOut = T("Löschen", "Put out")
    /** [84.5.aus] */
    val sparkGone = T("Der Funke verglimmt. Weg ist weg.", "The spark fades. Gone is gone.")
    /** [84.5.rast] after a rest, behind its own line, only when the spark was burning */
    val sparkFaded = T("Dein Funke ist verglommen.", "Your spark has faded.")

    /**
     * [84.1.an]/[84.1.aus]: what to say after the off hand changed, when the hero had a torch lit before ([wasLit]); only in
     * the dark, where the torch changes anything; null when nothing is to be said.
     */
    fun torchChange(s: GameState, dark: Boolean, wasLit: Boolean): T? = when {
        !dark || torch(s) == wasLit -> null
        torch(s) -> torchLit
        else -> torchSnuffed
    }
}
