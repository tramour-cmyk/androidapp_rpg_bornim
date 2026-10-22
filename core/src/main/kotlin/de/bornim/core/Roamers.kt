package de.bornim.core

/** How a monster behaves on the map. */
enum class Temper {
    /** Strolls around its home and hunts the hero on sight. */
    HUNTER,
    /** Strolls around and ignores the hero unless bumped into. */
    WANDERER,
    /** Sits still in hiding and pounces when the hero comes close. */
    LURKER,
    ;

    companion object {
        fun of(monster: String): Temper = when (monster) {
            "wolf", "goblin", "kobold", "boar", "ghoul", "skeleton", "zombie", "goblin_shaman", "goblin_archer" -> HUNTER
            "giant_spider", "giant_bat", "ochre_jelly" -> LURKER
            else -> WANDERER
        }
    }
}

/** Who strikes first when a fight starts. */
enum class Opening { NORMAL, HERO_FIRST, AMBUSHED }

/** A monster walking around on the map. Positions are tiles; times are milliseconds of the app clock. */
class Roamer(
    val uid: Int,
    val monster: String,
    var x: Int,
    var y: Int,
    val homeX: Int,
    val homeY: Int,
    val trait: EliteTrait?,
    val shiny: Boolean,
    val look: MonsterLook,
) {
    var facing: Facing = Facing.DOWN
    /** Where the last step started and when, for the slide animation. */
    var fromX = x
    var fromY = y
    var movedAt = 0L
    var moveMs = 300L
    var nextMoveAt = 0L
    /** Shows a "!" above the monster until this time. */
    var alertUntil = 0L
    var hunting = false
    /** Walking back to its home after giving up the chase. */
    var returning = false
    /** Ignores the hero until this time (after the hero fled). */
    var calmUntil = 0L
    /** When it is next heard on the map, if it is not hunting (D3.9); 0 until first seen. */
    var nextIdleAt = 0L

    val temper: Temper get() = Temper.of(monster)
}

/** A villager strolling around their spot. */
class Walker(val npc: Npc) {
    var x = npc.x
    var y = npc.y
    var fromX = x
    var fromY = y
    var facing = npc.facing
    var movedAt = 0L
    var moveMs = 520L
    var nextMoveAt = 0L
    /** 330: tiles walked so far, so the stride follows the way (the legs no longer slide); a step across counts √2. */
    var walked = 0.0
    /** 330: whether the last step went across, to a corner neighbour. */
    val across: Boolean get() = x != fromX && y != fromY
    /** 330: how long the last step takes: across is √2 tiles at the same pace. */
    val stepMs: Long get() = if (across) (moveMs * SQRT2).toLong() else moveMs
    /** 330: the way of the last step, 0° down the map, 90° right (as [Facing] in `MapFigure.yawOf`). */
    val stepYaw: Double get() = Math.toDegrees(kotlin.math.atan2((x - fromX).toDouble(), (y - fromY).toDouble())).let { if (it < 0) it + 360 else it }

    /** 330: one step by ([dx], [dy]) (across too), now at [now]. */
    fun step(dx: Int, dy: Int, now: Long) {
        fromX = x; fromY = y
        x += dx; y += dy
        walked += if (across) SQRT2 else 1.0
        movedAt = now
        // facing keeps the larger part of the way (talking, looking): across, the way left or right
        facing = if (dx != 0) (if (dx > 0) Facing.RIGHT else Facing.LEFT) else if (dy > 0) Facing.DOWN else Facing.UP
    }

    companion object {
        const val SQRT2 = 1.4142135623730951
    }
    /** Index of the patrol point this walker heads for. */
    var leg = 0
}
