package de.bornim.core.art

import de.bornim.core.Facing
import de.bornim.core.GearSlot
import de.bornim.core.Hero

/**
 * The hero on the map as the same doll as in battle (09.10.): seen at a slant from above, at true
 * size, walking about with the weapon lowered and the shield slung on the back, the hands free.
 *
 * Drawn in [YAWS] directions so the hero can turn smoothly instead of snapping between the four
 * ways, each with [STEPS] pictures of a walk. Pictures are [W] × [H] art pixels at density 2 (two
 * art pixels per map pixel), the feet at ([ANCHOR_X], [GROUND]). They are drawn ahead in the
 * background ([prepare]); until a picture is ready the map shows the former figure.
 */
object MapFigure {
    const val W = 96
    const val H = 132
    const val ANCHOR_X = 48
    const val GROUND = 124
    const val DENSITY = 2

    /** Directions drawn, evenly round. */
    const val YAWS = 16

    /** Pictures of a walk: rest, right foot forward, rest, left foot forward. */
    const val STEPS = 4

    /** Art pixels per centimetre: a man of 1.80 m stands about 1½ tiles tall. */
    private const val PX = 0.55

    /** How steeply the map is seen from above, in degrees. */
    private const val PITCH = 38.0

    /** The doll's yaw for looking down, right, up, left on the screen. */
    fun yawOf(f: Facing): Double = when (f) {
        Facing.DOWN -> 0.0
        Facing.RIGHT -> 90.0
        Facing.UP -> 180.0
        Facing.LEFT -> 270.0
    }

    /** The drawn direction nearest to [yaw]. */
    fun slot(yaw: Double): Int = Math.floorMod(Math.round(yaw / (360.0 / YAWS)).toInt(), YAWS)

    /** Long weapons (two-handed, spears, staves, bows) go on the shoulder; short ones are carried low. */
    private val LONG = setOf("spear", "quarterstaff", "staff", "halberd")

    private fun shouldered(hero: Hero): Boolean {
        val d = hero.weapon?.def ?: return false
        return d.twoHanded || d.ranged || d.id in LONG || hero.bothHands()
    }

    /** What the hands are doing while walking about. */
    enum class Carry { LOW, SHOULDER, FREE }

    /**
     * Walking about: the left arm swings a little with the step, the shield is on the back. A long
     * weapon rests on the right shoulder, pointing up and back; a short one (sword, mace, axe,
     * dagger) is carried low in the right hand, its point forward and down, clear of the ground and
     * of the head from every side. With nothing in hand ([Carry.FREE], folk with the bow slung) both
     * arms hang and swing with the step.
     */
    fun rig(yaw: Double, step: Int, carry: Carry): HeroFigure.Rig {
        val st = listOf(0.0, 11.0, 0.0, -11.0)[Math.floorMod(step, STEPS)]
        return Doll.REST.copy(
            yaw = yaw, stride = st, spread = 5.0,
            rh = when (carry) {
                Carry.SHOULDER -> HeroFigure.V(19.0, 78.0, 8.0)
                Carry.LOW -> HeroFigure.V(18.0, 64.0, 10.0 - st * 0.3)
                Carry.FREE -> HeroFigure.V(17.0, 52.0, 3.0 - st * 0.6)
            },
            lh = HeroFigure.V(-17.0, if (carry == Carry.FREE) 52.0 else 54.0, 3.0 + st * 0.6),
            weapon = when (carry) {
                Carry.SHOULDER -> HeroFigure.V(0.2, 0.96, -0.2)
                Carry.LOW -> HeroFigure.V(0.12, -0.6, 0.79)
                Carry.FREE -> HeroFigure.V(0.0, -1.0, 0.0)
            },
            aim = 1.0,
            shieldFace = HeroFigure.V(-1.0, 0.0, 0.25),
            bodyY = if (step % 2 == 1) 1.0 else 0.0,
        )
    }

    /** Draws [doll] in [outfit] in [rig] as a map picture. */
    fun render(doll: Doll, outfit: Outfit, rig: HeroFigure.Rig): PixelImage =
        doll.render(W, H, ANCHOR_X.toDouble(), GROUND.toDouble(), PX, rig, outfit, pitch = PITCH).img

    private fun look(hero: Hero) = "${hero.race}/${hero.sex}/${hero.build}/${hero.skinTone}/${hero.hairTone}/${hero.cls}/${hero.bothHands()}/" +
        GearSlot.entries.joinToString(",") { s -> hero.item(s)?.let { "${it.base}:${it.rarity}" } ?: "-" }

    private val cache = HashMap<String, PixelImage>()
    private var preparing: String? = null

    /** Draws one picture now. */
    fun draw(hero: Hero, slot: Int, step: Int): PixelImage =
        render(HeroBattle.doll(hero), HeroBattle.outfit(hero).withShieldOnBack(), rig(slot * 360.0 / YAWS, step, if (shouldered(hero)) Carry.SHOULDER else Carry.LOW))

    /** The picture of [hero] turned to direction [slot] at [step] of a walk, or null while it is not drawn yet. */
    fun frame(hero: Hero, slot: Int, step: Int): PixelImage? = synchronized(cache) { cache["${look(hero)}|$slot|${Math.floorMod(step, STEPS)}"] }

    /**
     * Draws every picture of [hero] in the background, the directions nearest to [nearYaw] first.
     * Pictures of an earlier look (other gear) are dropped.
     */
    fun prepare(hero: Hero, nearYaw: Double = 0.0) {
        val l = look(hero)
        synchronized(cache) {
            if (preparing == l) return
            preparing = l
            cache.keys.removeAll { !it.startsWith("$l|") }
        }
        val first = slot(nearYaw)
        val order = (0 until YAWS).sortedBy { minOf(Math.floorMod(it - first, YAWS), Math.floorMod(first - it, YAWS)) }
        val t = Thread {
            for (s in order) for (st in 0 until STEPS) {
                if (synchronized(cache) { preparing != l }) return@Thread
                val k = "$l|$s|$st"
                if (synchronized(cache) { k in cache }) continue
                val img = draw(hero, s, st)
                synchronized(cache) { if (preparing == l) cache[k] = img }
            }
        }
        t.isDaemon = true
        t.priority = Thread.MIN_PRIORITY + 1
        t.start()
    }

    /** Draws every picture right away (previews and tests). */
    fun prepareNow(hero: Hero) {
        val l = look(hero)
        synchronized(cache) { preparing = l }
        for (s in 0 until YAWS) for (st in 0 until STEPS) {
            val k = "$l|$s|$st"
            if (synchronized(cache) { k in cache }) continue
            val img = draw(hero, s, st)
            synchronized(cache) { cache[k] = img }
        }
    }
}
