package de.bornim.core.art

import de.bornim.core.GearSlot
import de.bornim.core.Hero
import de.bornim.core.art.HeroFigure.Act
import de.bornim.core.art.HeroFigure.Strike

/**
 * The hero in battle as the doll: which frames to show for what happens, drawn ahead in the background and kept.
 * A frame is [W] × [H] art pixels with the feet at ([ANCHOR_X], [GROUND]); it is placed like that on the scene.
 */
object HeroBattle {
    const val W = 150
    const val H = 190
    const val ANCHOR_X = 70.0
    const val GROUND = 184.0
    /** Art pixels per centimetre. */
    const val PX = 0.75

    /** Foes that come in low, at the legs and belly; the block is taken low against them. */
    private val LOW_FOES = setOf("giant_rat", "wolf", "dire_wolf", "boar", "giant_spider", "giant_centipede", "ochre_jelly", "kobold")

    fun doll(hero: Hero) = Doll(hero.race, hero.sex, hero.build, hero.skinTone, hero.hairTone)

    fun outfit(hero: Hero) = Outfit(hero.cls, GearSlot.entries.mapNotNull { s -> hero.item(s)?.let { s to it } }.toMap())

    fun stance(hero: Hero) = HeroFigure.stance(hero)

    /** How the hero blocks this foe: with a shield high or low, or two-handed high or low (see [HeroFigure.sequence]). */
    fun blockVariant(hero: Hero, foeId: String): Int {
        val low = foeId in LOW_FOES
        return if (outfit(hero).twoHands) (if (low) 1 else 3) else (if (low) 2 else 0)
    }

    /** The blows this hero strikes, taken in turn. */
    fun strikes(hero: Hero): List<Strike> = HeroFigure.strikes(hero)

    fun castVariant(hero: Hero) = HeroFigure.castVariant(hero)

    fun victoryVariants(hero: Hero) = HeroFigure.victoryPoses(hero)

    /** The variant an act is played in: casts by what is held, blocks by the foe, victories by [pick]. */
    fun variant(hero: Hero, act: Act, foeId: String, pick: Int = 0): Int = when (act) {
        Act.CAST -> castVariant(hero)
        Act.BLOCK -> blockVariant(hero, foeId)
        Act.VICTORY -> victoryVariants(hero).let { it[pick.mod(it.size)] }
        else -> 0
    }

    fun frames(hero: Hero, act: Act, strike: Strike, variant: Int) = HeroFigure.sequence(act, strike, variant, stance(hero))

    fun frameCount(hero: Hero, act: Act, strike: Strike = Strike.SLASH, variant: Int = 0) = frames(hero, act, strike, variant).size

    /** The frame of a blow at which it lands. */
    fun strikeFrame(strike: Strike) = HeroFigure.strikeFrame(strike)

    // ---------------------------------------------------------------- the lunge

    /** How much smaller the hero is drawn at the end of the lunge: the foe stands further off. */
    const val LUNGE_SCALE = 0.85

    private val tips = HashMap<String, Pair<Double, Double>>()

    /** Where the weapon's point is in the frame at the moment the blow lands, in art pixels. */
    fun tip(hero: Hero, strike: Strike): Pair<Double, Double> {
        val k = "${look(hero)}|$strike"
        synchronized(tips) { tips[k]?.let { return it } }
        val doll = doll(hero); val o = outfit(hero)
        val rig = frames(hero, Act.ATTACK, strike, 0)[strikeFrame(strike)]
        val img = doll.render(W, H, ANCHOR_X, GROUND, PX, rig, o)
        val sk = doll.fit(rig, o).first
        val base = hero.weapon?.base
        val reach = if (base == null) 0.0 else Dress.reach(base) * (if (base in Dress.ROUND) doll.height / 175.0 * 0.95 else 1.0)
        val (x, y, _) = img.project(sk.hand(1) + sk.weapon * reach)
        val t = Pair(x, y)
        synchronized(tips) { tips[k] = t }
        return t
    }

    /**
     * How far along the lunge of a melee blow the hero is at frame [index]: still at the start of the wind-up, stepping
     * in through it, all the way at the moment the blow lands, and back again through the follow-through. 0 for shots.
     */
    fun lungeAt(hero: Hero, strike: Strike, index: Int): Double {
        if (strike == Strike.SHOOT || strike == Strike.CAST) return 0.0
        val hit = strikeFrame(strike)
        val n = frameCount(hero, Act.ATTACK, strike, 0)
        fun smooth(x: Double) = x.coerceIn(0.0, 1.0).let { it * it * (3 - 2 * it) }
        return if (index <= hit) smooth((index - hit * 0.3) / (hit * 0.7)) else 1 - smooth((index - hit).toDouble() / (n - 1 - hit).coerceAtLeast(1))
    }

    /**
     * Where a blow aims on a foe whose picture is [foeW] wide with its feet at ([feetX], [feetY]) and [height] tall:
     * the near front of it, towards the hero below on the left, so the hero steps in only as far as a real blow would.
     */
    fun aimAt(feetX: Double, feetY: Double, foeW: Double, height: Double): Pair<Double, Double> = Pair(feetX - foeW * 0.28, feetY - height * 0.4)

    /**
     * The step in for a blow, in art pixels: how far the feet move so that, drawn [LUNGE_SCALE] times as large, the
     * weapon's point lands on ([foeX], [foeY]) while the feet stood at ([feetX], [feetY]).
     */
    fun lungeOffset(hero: Hero, strike: Strike, feetX: Double, feetY: Double, foeX: Double, foeY: Double): Pair<Double, Double> {
        val (tx, ty) = tip(hero, strike)
        return Pair(foeX - feetX - (tx - ANCHOR_X) * LUNGE_SCALE, foeY - feetY - (ty - GROUND) * LUNGE_SCALE)
    }

    // ---------------------------------------------------------------- the frames, kept

    private fun look(hero: Hero) = "${hero.race}/${hero.sex}/${hero.build}/${hero.skinTone}/${hero.hairTone}/${hero.cls}/" +
        GearSlot.entries.joinToString(",") { s -> hero.item(s)?.let { "${it.base}:${it.rarity}" } ?: "-" }

    /** About 30 MB of frames at most, fewer on small phones. */
    private val capacity: Int = (Runtime.getRuntime().maxMemory() / 8 / (W * H * 4L)).toInt().coerceIn(60, 280)

    private val cache = object : LinkedHashMap<String, PixelImage>(128, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > capacity
    }

    private fun key(hero: Hero, act: Act, strike: Strike, variant: Int, i: Int) = "${look(hero)}|$act/$strike/$variant/$i"

    /** Frame [index] of an act, drawn now if it is not kept yet. Idle and intro loop. */
    fun frame(hero: Hero, act: Act, strike: Strike, variant: Int, index: Int): PixelImage {
        val seq = frames(hero, act, strike, variant)
        val i = if (act == Act.IDLE || act == Act.INTRO) index.mod(seq.size) else index.coerceIn(0, seq.size - 1)
        val k = key(hero, act, strike, variant, i)
        synchronized(cache) { cache[k]?.let { return it } }
        val img = doll(hero).render(W, H, ANCHOR_X, GROUND, PX, seq[i], outfit(hero)).img
        synchronized(cache) { cache[k] = img }
        return img
    }

    /** The frame if it is drawn already, else null: the battle shows the nearest drawn one meanwhile. */
    fun ready(hero: Hero, act: Act, strike: Strike, variant: Int, index: Int): PixelImage? {
        val n = frameCount(hero, act, strike, variant)
        val i = if (act == Act.IDLE || act == Act.INTRO) index.mod(n) else index.coerceIn(0, n - 1)
        return synchronized(cache) { cache[key(hero, act, strike, variant, i)] }
    }

    /**
     * Draws every frame a fight with [foeId] can need, the first ones first: the start (facing us and turning, or the
     * ambush), the rest, then blows, spells, blocks, being hit and the victory. Call it off the main thread; it stops
     * early when [cancelled] says so.
     */
    fun prepare(hero: Hero, foeId: String, ambushed: Boolean, victoryPick: Int = 0, cancelled: () -> Boolean = { false }) {
        val plan = mutableListOf<Triple<Act, Strike, Int>>()
        if (ambushed) plan += Triple(Act.AMBUSHED, Strike.SLASH, 0)
        else { plan += Triple(Act.INTRO, Strike.SLASH, 0); plan += Triple(Act.TURN, Strike.SLASH, 0) }
        plan += Triple(Act.IDLE, Strike.SLASH, 0)
        for (s in strikes(hero)) { plan += Triple(Act.ATTACK, s, 0); if (!cancelled()) tip(hero, s) }
        plan += Triple(Act.HURT, Strike.SLASH, 0)
        plan += Triple(Act.BLOCK, Strike.SLASH, blockVariant(hero, foeId))
        plan += Triple(Act.CAST, Strike.CAST, castVariant(hero))
        plan += Triple(Act.VICTORY, Strike.SLASH, variant(hero, Act.VICTORY, foeId, victoryPick))
        for ((act, strike, v) in plan) for (i in 0 until frameCount(hero, act, strike, v)) {
            if (cancelled()) return
            frame(hero, act, strike, v, i)
        }
    }
}
