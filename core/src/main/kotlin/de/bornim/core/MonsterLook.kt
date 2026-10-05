package de.bornim.core

/**
 * How one particular monster looks. Rolled when a fight starts: [seed] picks colors, size and
 * equipment, [shiny] marks the rare shimmering variant, [glow] is the eye and aura color of elites.
 */
data class MonsterLook(val seed: Int = 0, val shiny: Boolean = false, val glow: Int? = null) {
    /** A stable pseudo-random number in 0 until [n] for one feature ([salt]) of this look. */
    fun pick(n: Int, salt: Int): Int {
        var x = seed * 0x9E3779B1.toInt() + salt * 0x85EBCA77.toInt()
        x = (x xor (x ushr 15)) * 0x2C1B3C6D
        x = x xor (x ushr 12)
        return ((x and 0x7fffffff) % n)
    }

    /** A value in -1..1 for one feature of this look. */
    fun range(salt: Int): Double = pick(2001, salt) / 1000.0 - 1.0
}
