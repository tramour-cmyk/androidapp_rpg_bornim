package de.bornim.core

import kotlin.math.PI
import kotlin.math.sin

/**
 * How hard a blow that strikes home lands, for the halt as it lands (16): hero and foe stand still for [stopMs], then the
 * one struck reels. A plain hit only catches for a moment; a hard one (a third of the struck one's hit points or more)
 * stands for two frames of a blow, a critical one for three, with the scene drawn in a little and jolted once in the
 * blow's direction; the killing blow stands longest and has its own, larger draw-in.
 */
enum class HitWeight(val stopMs: Long) {
    NORMAL(70L), HARD(180L), CRIT(270L), KILL(380L);

    /** The halt at the pace set in the menu (its factor: calm 1.35, normal 1, fast 0.7). */
    fun stopMs(pace: Double): Long = (stopMs * pace).toLong()

    /** How far the scene draws in during the halt, as a part of its size (the killing blow draws in by itself). */
    val zoom: Float get() = if (this == CRIT) 0.06f else 0f

    /** How far the scene jolts in the blow's direction (in dp) and how long out and back takes (ms, normal pace); none for a plain or hard hit. */
    val joltDp: Float get() = when (this) { CRIT -> 4f; KILL -> 7f; else -> 0f }
    val joltMs: Long get() = when (this) { CRIT -> 150L; KILL -> 220L; else -> 0L }

    companion object {
        /** The weight of a blow that did [damage] to one with [maxHp] at most; [kill] for the killing blow. */
        fun of(crit: Boolean, damage: Int, maxHp: Int, kill: Boolean = false): HitWeight = when {
            kill -> KILL
            crit -> CRIT
            maxHp > 0 && damage * 3 >= maxHp -> HARD
            else -> NORMAL
        }

        /** The jolt at [p] (0 as it lands, 1 when done): out in the blow's direction and back once, smoothly, never past the rest. */
        fun jolt(p: Float): Float = if (p <= 0f || p >= 1f) 0f else sin(PI * p).toFloat()
    }
}
