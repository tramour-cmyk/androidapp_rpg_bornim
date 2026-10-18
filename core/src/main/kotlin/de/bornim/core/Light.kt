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

    /** Whether the hero carries a lit torch: one in the off hand. */
    fun torch(s: GameState): Boolean = s.hero.item(GearSlot.OFF_HAND)?.def?.kind == BaseKind.LIGHT

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

    // Placeholder lines, plain and factual; the wording goes to Kreativ (41).
    val sparkDrunk = T("{0} trinkt das Fläschchen. Ein kleiner Funke steigt auf und schwebt über dem Kopf, bis zur nächsten Rast.", "{0} drinks the flask. A small spark rises and hovers overhead until the next rest.")
    val sparkAlready = T("Der Leuchtfunke schwebt noch über dir.", "The lightspark still hovers over you.")
    val sparkOut = T("Funke löschen", "Put out spark")
    val sparkGone = T("Der Funke erlischt.", "The spark goes out.")
}
