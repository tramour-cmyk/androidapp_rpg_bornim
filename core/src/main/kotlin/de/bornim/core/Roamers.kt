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
    /** Index of the patrol point this walker heads for. */
    var leg = 0
}
