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

    fun outfit(hero: Hero) = Outfit.of(hero)

    fun stance(hero: Hero) = HeroFigure.stance(hero)

    /** How the hero blocks this foe: with a shield high or low, or two-handed high or low (see [HeroFigure.sequence]). */
    fun blockVariant(hero: Hero, foeId: String): Int = blockVariants(hero, foeId).first()

    /**
     * The three guards that suit this hero against this foe: with a shield high (or low against beasts and the small),
     * braced or turned; two-handed across high (or low), slanted or hanging.
     */
    fun blockVariants(hero: Hero, foeId: String): List<Int> {
        val low = foeId in LOW_FOES
        return if (outfit(hero).twoHands) listOf(if (low) 1 else 3, 6, 7) else listOf(if (low) 2 else 0, 4, 5)
    }

    /** The blows this hero strikes, taken in turn. */
    fun strikes(hero: Hero): List<Strike> = HeroFigure.strikes(hero)

    fun castVariant(hero: Hero) = HeroFigure.castVariant(hero)

    /**
     * A flask is thrown with the free hand, or with the weapon hand when the other carries a shield or a two-handed grip;
     * a staff stays planted beside the foot, so with a shield it is the shield hand that throws.
     */
    fun throwVariant(hero: Hero): Int = when {
        stance(hero) == HeroFigure.Stance.STAFF && outfit(hero).hasShield -> 0
        outfit(hero).hasShield || outfit(hero).twoHands -> 1
        else -> 0
    }

    fun victoryVariants(hero: Hero) = HeroFigure.victoryPoses(hero)

    /** The variant an act is played in: casts by what is held, blocks by the foe, victories by [pick]. */
    fun variant(hero: Hero, act: Act, foeId: String, pick: Int = 0): Int = when (act) {
        Act.CAST -> castVariant(hero)
        Act.THROW -> throwVariant(hero)
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
    fun lungeAt(hero: Hero, strike: Strike, index: Int): Double = lungeAt(hero, strike, index.toDouble())

    /** The same between two frames ([index] 3.4: four tenths on from frame 3), so the step glides instead of jumping frame by frame. */
    fun lungeAt(hero: Hero, strike: Strike, index: Double): Double {
        if (strike == Strike.SHOOT || strike == Strike.CAST) return 0.0
        val hit = strikeFrame(strike)
        val n = frameCount(hero, Act.ATTACK, strike, 0)
        fun smooth(x: Double) = x.coerceIn(0.0, 1.0).let { it * it * (3 - 2 * it) }
        return if (index <= hit) smooth((index - hit * 0.3) / (hit * 0.7)) else 1 - smooth((index - hit) / (n - 1 - hit).coerceAtLeast(1))
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

    // ---------------------------------------------------------------- where shots and spells leave the hero

    /** Where a spell or a shot leaves the hero, in art pixels of the frame, and the colour of a spell's light. */
    class Launch(val x: Double, val y: Double, val rgb: Int)

    private val launches = HashMap<String, Launch>()

    /**
     * The point a spell or shot starts from at the moment it is let go: the staff's crystal, the wand's tip, the orb or
     * symbol in the hand, the open palm; the arrow on the bow, the bolt at the front of the crossbow.
     */
    fun launch(hero: Hero, act: Act, variant: Int): Launch {
        val strike = if (act == Act.CAST || act == Act.THROW) Strike.CAST else Strike.SHOOT
        val k = "${look(hero)}|$act/$variant"
        synchronized(launches) { launches[k]?.let { return it } }
        val doll = doll(hero); val o = outfit(hero)
        val rig = frames(hero, act, strike, variant)[strikeFrame(strike)]
        val img = doll.render(W, H, ANCHOR_X, GROUND, PX, rig, o)
        val (sk, fitted) = doll.fit(rig, o)
        val dress = fitted?.first ?: Dress(doll, sk, doll.body(sk), o)
        val at = when {
            act == Act.CAST -> dress.glowPoint()
            act == Act.THROW -> sk.hand(if (variant == 0) 0 else 1)
            stance(hero) == HeroFigure.Stance.CROSSBOW -> sk.hand(1) + sk.weapon * (0.31 * doll.height)
            else -> sk.hand(0)
        }
        val (x, y, _) = img.project(at)
        val l = Launch(x, y, if (act == Act.CAST) dress.glowColour() else 0xFFF0D0)
        synchronized(launches) { launches[k] = l }
        return l
    }

    // ---------------------------------------------------------------- the frames, kept

    private fun look(hero: Hero) = "${hero.race}/${hero.sex}/${hero.build}/${hero.skinTone}/${hero.hairTone}/${hero.cls}/" +
        GearSlot.entries.joinToString(",") { s -> hero.item(s)?.let { "${it.base}:${it.rarity}" } ?: "-" }

    /** About 30 MB of frames at most, fewer on small phones. */
    private val capacity: Int = (Runtime.getRuntime().maxMemory() / 8 / (W * H * 4L)).toInt().coerceIn(60, 280)

    private val cache = object : LinkedHashMap<String, PixelImage>(128, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > capacity
    }

    private fun key(hero: Hero, act: Act, strike: Strike, variant: Int, i: Int, wounds: Int) = "${look(hero)}|$act/$strike/$variant/$i/$wounds"

    /** Frame [index] of an act, drawn now if it is not kept yet. Idle and intro loop. */
    fun frame(hero: Hero, act: Act, strike: Strike, variant: Int, index: Int, wounds: Int = 0): PixelImage {
        val seq = frames(hero, act, strike, variant)
        val i = if (act == Act.IDLE || act == Act.INTRO) index.mod(seq.size) else index.coerceIn(0, seq.size - 1)
        val k = key(hero, act, strike, variant, i, wounds)
        synchronized(cache) { cache[k]?.let { return it } }
        // a draught: variants 0 to 2 a healing potion (red), 3 to 5 the remedy (sickly green)
        val o = if (act == Act.DRINK) outfit(hero).withFlask(if (variant >= 3) REMEDY_RGB else POTION_RGB) else outfit(hero)
        // a falling hero lies stretched out: its frames are wider, to the right, the feet staying where they stood
        val img = doll(hero).render(if (act == Act.DIE) W_FALL else W, H, ANCHOR_X, GROUND, PX, seq[i], o, wounds = wounds).img
        synchronized(cache) { cache[k] = img }
        return img
    }

    /** The width of the frames of a fall. */
    const val W_FALL = 250

    const val POTION_RGB = 0x9A1C1C
    const val REMEDY_RGB = 0x5A8A2A

    /** How this hero falls in this fight, and how it drinks: fixed by the fight's [pick], so they can be drawn ahead. */
    fun diePick(pick: Int) = pick.mod(3)
    fun drinkPick(pick: Int) = (pick / 3).mod(3)

    /** The frame if it is drawn already, else null: the battle shows the nearest drawn one meanwhile. */
    fun ready(hero: Hero, act: Act, strike: Strike, variant: Int, index: Int, wounds: Int = 0): PixelImage? {
        val n = frameCount(hero, act, strike, variant)
        val i = if (act == Act.IDLE || act == Act.INTRO) index.mod(n) else index.coerceIn(0, n - 1)
        // a hurt hero is shown as the frame is drawn so far: with fewer wounds, if the new ones are not drawn yet
        for (w in wounds downTo 0) synchronized(cache) { cache[key(hero, act, strike, variant, i, w)] }?.let { return it }
        return null
    }

    /**
     * Draws every frame a fight with [foeId] can need, the first ones first: the start (facing us and turning, or the
     * ambush), the rest, then blows, spells, blocks, being hit and the victory. Call it off the main thread; it stops
     * early when [cancelled] says so.
     */
    fun prepare(hero: Hero, foeId: String, ambushed: Boolean, victoryPick: Int = 0, wounds: Int = 0,
        first: Triple<Act, Strike, Int>? = null, cancelled: () -> Boolean = { false }) {
        val plan = mutableListOf<Triple<Act, Strike, Int>>()
        // what the hero is doing right now (a guard held while struck) is drawn with the new wounds before all else
        first?.let { plan += it }
        if (ambushed) plan += Triple(Act.AMBUSHED, Strike.SLASH, 0)
        else { plan += Triple(Act.INTRO, Strike.SLASH, 0); plan += Triple(Act.TURN, Strike.SLASH, 0) }
        plan += Triple(Act.IDLE, Strike.SLASH, 0)
        // the guard and being hit early: they come with the foe's first blow, and a guard must not drop for want of frames
        for (v in blockVariants(hero, foeId)) plan += Triple(Act.BLOCK, Strike.SLASH, v)
        for (v in 0..2) plan += Triple(Act.HURT, Strike.SLASH, v)
        for (s in strikes(hero)) { plan += Triple(Act.ATTACK, s, 0); if (!cancelled()) tip(hero, s) }
        plan += Triple(Act.CAST, Strike.CAST, castVariant(hero))
        plan += Triple(Act.THROW, Strike.CAST, throwVariant(hero))
        if (!cancelled()) { launch(hero, Act.CAST, castVariant(hero)); launch(hero, Act.THROW, throwVariant(hero)); if (hero.weapon?.def?.ranged == true) launch(hero, Act.ATTACK, 0) }
        plan += Triple(Act.VICTORY, Strike.SLASH, variant(hero, Act.VICTORY, foeId, victoryPick))
        // last: the fall, and a healing draught, in this fight's ways
        plan += Triple(Act.DIE, Strike.SLASH, diePick(victoryPick))
        plan += Triple(Act.DRINK, Strike.SLASH, drinkPick(victoryPick))
        for ((act, strike, v) in plan.distinct()) for (i in 0 until frameCount(hero, act, strike, v)) {
            if (cancelled()) return
            frame(hero, act, strike, v, i, wounds)
        }
    }
}
