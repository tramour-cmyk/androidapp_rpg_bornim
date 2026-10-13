package de.bornim.core

import kotlin.math.cos
import kotlin.math.sin

/**
 * Traces that stay a while (idea 7, draft): blood where a foe fell, footprints in the wet ground after rain
 * (and, with mud on the boots, a few faint ones on stone and floors), dust kicked up when running on a dry way.
 * Only kept in memory, never saved; each fades by itself. Positions in tiles, times in ms of the app clock.
 */
class Tracks {
    enum class Kind { BLOOD, PRINT, DUST }

    /**
     * One trace on map [map] at ([x], [y]), made at [at]. [yaw] the way the foot pointed (0 down the map, 90 to the
     * right), [left] which foot, [strength] how clear it is (a print from muddy boots grows fainter), [seed] its shape.
     */
    class Mark(val kind: Kind, val map: String, val x: Double, val y: Double, val at: Long,
               val yaw: Double = 0.0, val left: Boolean = false, val strength: Float = 1f, val seed: Int = 0) {
        val life: Long get() = when (kind) {
            Kind.BLOOD -> BLOOD_MS
            Kind.PRINT -> if (strength >= 1f) PRINT_MS else CARRIED_MS
            Kind.DUST -> DUST_MS
        }
        /** 0 (new) to 1 (gone). */
        fun age(now: Long) = ((now - at).toFloat() / life).coerceIn(0f, 1f)
        /** How strongly it shows: full for most of its life, then fading out. */
        fun alpha(now: Long): Float {
            val a = age(now)
            return strength * (if (a < FADE_FROM) 1f else (1f - (a - FADE_FROM) / (1f - FADE_FROM)))
        }
    }

    private val all = ArrayList<Mark>()
    val marks: List<Mark> get() = all

    /** How wet the ground still is, 0 to 1: as wet as the rain, drying slowly after it stops. */
    var wet = 0f
        private set
    /** Prints the boots can still leave after walking through mud. */
    var mud = 0
        private set

    private var stride = 0.0
    private var leftFoot = false
    private var lastX = Double.NaN
    private var lastY = Double.NaN
    private var lastMap = ""

    /** Advances the drying of the ground by [deltaMs] with rain at [rain] (0 to 1). */
    fun weather(rain: Float, deltaMs: Long) {
        wet = maxOf(rain, wet - deltaMs / DRY_MS)
    }

    /** The ground as wet as the rain at once (previews and tests). */
    fun settle(rain: Float) { wet = rain }

    /** Blood where a foe fell, at ([x], [y]) on [map]. */
    fun blood(map: String, x: Double, y: Double, now: Long, seed: Int) {
        if (!draft) return
        add(Mark(Kind.BLOOD, map, x, y, now, seed = seed))
    }

    /**
     * The hero's feet at ([x], [y]) on [map], walking the way [yaw], on [ground]; [outdoors] whether rain reaches the
     * ground, [running] whether it runs. Leaves a print each step where the ground is wet and soft (or the boots
     * still muddy), and a puff of dust each stride on a dry way when running.
     */
    fun walked(map: String, x: Double, y: Double, yaw: Double, ground: Tile, outdoors: Boolean, running: Boolean, now: Long) {
        if (!draft) return
        if (map != lastMap || lastX.isNaN()) { lastMap = map; lastX = x; lastY = y; stride = 0.0; return }
        stride += kotlin.math.hypot(x - lastX, y - lastY)
        lastX = x; lastY = y
        val step = if (running) RUN_STEP else STEP
        if (stride < step) return
        stride = 0.0
        leftFoot = !leftFoot
        // the foot sets down beside the line walked, left or right of it
        val r = Math.toRadians(yaw)
        val side = (if (leftFoot) -1 else 1) * SIDE
        val fx = x + cos(r) * side; val fy = y - sin(r) * side
        val soft = ground == Tile.GRASS || ground == Tile.PATH || ground == Tile.FLOWERS
        val muddy = outdoors && soft && wet >= WET
        when {
            muddy -> { mud = MUD_STEPS; add(Mark(Kind.PRINT, map, fx, fy, now, yaw, leftFoot, 1f)) }
            mud > 0 && ground != Tile.TALL_GRASS && ground != Tile.WATER -> {
                add(Mark(Kind.PRINT, map, fx, fy, now, yaw, leftFoot, CARRIED * mud / MUD_STEPS))
                mud--
            }
        }
        if (running && wet < DRY && (ground == Tile.PATH || ground == Tile.CAVE_FLOOR) && !leftFoot)
            add(Mark(Kind.DUST, map, x - sin(r) * 0.2, y - cos(r) * 0.2, now, yaw, seed = (now % 997).toInt()))
    }

    /** The traces on [map] still to be seen at [now]. */
    fun on(map: String, now: Long): List<Mark> = all.filter { it.map == map && now - it.at < it.life }

    private fun add(m: Mark) {
        all.removeAll { m.at - it.at >= it.life }
        if (all.size >= MAX) all.removeAt(all.indexOfFirst { it.kind != Kind.BLOOD }.takeIf { it >= 0 } ?: 0)
        all += m
    }

    companion object {
        /** The test switch: traces are made and drawn (draft). */
        @Volatile var draft = true

        const val BLOOD_MS = 6 * 60_000L
        const val PRINT_MS = 2 * 60_000L
        const val CARRIED_MS = 60_000L
        const val DUST_MS = 900L
        const val FADE_FROM = 0.6f
        /** How long the ground takes to dry after the rain, in ms. */
        const val DRY_MS = 4 * 60_000f
        /** From this wetness on soft ground keeps prints; below [DRY] a way is dry enough for dust. */
        const val WET = 0.3f
        const val DRY = 0.05f
        /** How far one foot is set before the other, walking and running, in tiles. */
        const val STEP = 0.42
        const val RUN_STEP = 0.6
        /** How far a foot is set beside the line walked, in tiles. */
        const val SIDE = 0.07
        /** Prints the muddy boots still leave on stone and floors, and how clear the first of them is. */
        const val MUD_STEPS = 8
        const val CARRIED = 0.55f
        const val MAX = 240
    }
}
