package de.bornim.core

/**
 * 344.2 (Vorgangsarchiv 344, Chef 23.10., 18:27): fighting with the burning torch in the off hand, in both systems. A
 * thrust without proficiency (d20 + Strength) does 1 fire damage (SRD torch); a foe that shies from fire then makes a
 * Wisdom save against [DC] and, failing it, is frightened until its next turn: it backs off and its next blow has
 * disadvantage (SRD frightened). Placeholder words and list, final with Homer (344.2, `[344.2.…]`).
 */
object TorchFight {
    const val DC = 10
    const val DAMAGE = 1

    /** Who shies from fire: beasts, not people nor the dead (Jerry's proposal, final with Homer). */
    val SHY = setOf("giant_rat", "wolf", "dire_wolf", "giant_spider", "boar", "stirge", "giant_centipede", "giant_bat")

    fun shy(m: MonsterDef): Boolean = m.id in SHY

    val name = T("Fackel", "Torch")
    val about = T("Stößt mit der brennenden Fackel zu: 1 Feuerschaden. Tiere scheuen das Feuer und weichen vielleicht zurück.",
        "Thrust the burning torch: 1 fire damage. Beasts shy from the fire and may back off.")
    val thrusts = T("{0} stößt mit der Fackel zu.", "{0} thrusts the torch.")
    val backsOff = T("{0} scheut das Feuer und weicht zurück.", "{0} shies from the fire and backs off.")
    val holds = T("{0} hält dem Feuer stand.", "{0} stands up to the fire.")
}
