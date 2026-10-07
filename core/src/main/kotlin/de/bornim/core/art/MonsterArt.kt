package de.bornim.core.art

import kotlin.math.roundToInt

import de.bornim.core.MonsterLook
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

/** Which picture of a monster to draw: one of the idle frames, the attack or the flinch. */
enum class Pose { IDLE, ATTACK, HURT }

/** Actions of monsters drawn in the new battle style, each a sequence of frames. */
enum class Act { IDLE, ATTACK, HURT, HOWL, DODGE, DIE }

/**
 * 64×64 battle sprites. Every monster is built from lit shapes (see [Sculpt]) as a function of
 * its pose, so idle loops, attacks and hits are separate frames, and of a [MonsterLook], so no two
 * goblins look quite alike. All monsters face left, towards the hero.
 */
object MonsterArt {
    const val SIZE = 64
    const val IDLE_FRAMES = 4

    private val cache = object : LinkedHashMap<String, PixelImage>(64, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > 160
    }

    /**
     * A half-size version for monsters walking around on the map (32×32): every 2×2 block of the
     * battle sprite becomes one pixel, then it gets a fresh outline.
     */
    /** The monster shrunk for the map: half the battle size, times [scale] (smaller pack mates). */
    fun mapSprite(id: String, look: MonsterLook, idleFrame: Int, mirrored: Boolean, scale: Float = 1f): PixelImage {
        val f = idleFrame.mod(IDLE_FRAMES)
        val n = (SIZE / 2 * scale).roundToInt().coerceIn(8, SIZE / 2)
        val key = "map/$id/${look.seed}/${look.shiny}/${look.glow}/$f/$mirrored/$n"
        synchronized(cache) { cache[key]?.let { return it } }
        if (isNewStyle(id) && !isDoll(id)) {
            // New-style monsters are wider than tall: shrink to the map size, feet on the bottom row.
            val src = legacy(id, look, Act.IDLE, 0, f * WolfArt.IDLE_FRAMES / IDLE_FRAMES)
            val small = shrink(src, (n * (if (id == "dire_wolf") 1.25 else 1.0)).roundToInt())
            Pen(small).outline(Pal.OUTLINE)
            val img = if (mirrored) small.mirrored() else small
            synchronized(cache) { cache[key] = img }
            return img
        }
        val big = frame(id, look, Pose.IDLE, f)
        val out = PixelImage(n, n)
        for (y in 0 until n) for (x in 0 until n) {
            // Average the opaque pixels of the source box that maps onto this pixel.
            val x0 = x * SIZE / n; val x1 = maxOf(x0 + 1, (x + 1) * SIZE / n)
            val y0 = y * SIZE / n; val y1 = maxOf(y0 + 1, (y + 1) * SIZE / n)
            var c = 0; var r = 0; var g = 0; var b = 0
            for (sy in y0 until y1) for (sx in x0 until x1) {
                val p = big[sx, sy]
                if ((p ushr 24) < 200) continue
                c++; r += (p shr 16) and 0xFF; g += (p shr 8) and 0xFF; b += p and 0xFF
            }
            if (c * 2 >= (x1 - x0) * (y1 - y0)) out.set(x, y, argb(((r / c) shl 16) or ((g / c) shl 8) or (b / c)))
        }
        Pen(out).outline(Pal.OUTLINE)
        val img = if (mirrored) out.mirrored() else out
        synchronized(cache) { cache[key] = img }
        return img
    }

    /** The default look in its first idle frame, e.g. for bosses standing on the map. */
    fun get(id: String): PixelImage =
        if (isNewStyle(id) && !isDoll(id)) synchronized(cache) { cache.getOrPut("get/$id") { shrink(legacy(id, MonsterLook(), Act.IDLE, 0, 0), SIZE).also { Pen(it).outline(Pal.OUTLINE) } } }
        else frame(id, MonsterLook(), Pose.IDLE, 0)

    // ---------------------------------------------------------------- monsters in the new battle style

    /** Monsters already drawn in the new, larger battle style with frame sequences. */
    private val NEW_STYLE = setOf("wolf", "dire_wolf") + FoeArt.KINDS

    fun isNewStyle(id: String) = id in NEW_STYLE

    /** Foes on the hero's doll ([FoeArt]); on the map they keep their small figures for now. */
    fun isDoll(id: String) = id in FoeArt.KINDS

    /** Animals built in the round ([BeastArt]); on the map they keep their drawn figures for now. */
    fun isBeast(id: String) = id in BeastArt.KINDS

    /** Foes built in the round, on the doll or as animals: they step in to strike, dodge and fall in their own frames. */
    fun isSolid(id: String) = isDoll(id) || isBeast(id)

    /** The drawn wolf, still used for the small figures on the map. */
    private fun legacy(id: String, look: MonsterLook, act: Act, variant: Int, index: Int) = WolfArt.frame(look, id == "dire_wolf", act, variant, index)

    /** Number of different attack animations of a monster. */
    fun attackVariants(id: String): Int = if (isSolid(id)) 3 else if (isNewStyle(id)) 2 else 1

    /** The one way a foe built in the round falls, fixed by its look. */
    fun dieVariant(id: String, look: MonsterLook): Int = if (isBeast(id)) BeastArt.dieVariant(look) else FoeArt.dieVariant(look)

    /** Number of variants of being hit, dodging and falling. */
    fun reactVariants(id: String): Int = if (isSolid(id)) 3 else 1

    fun frameCount(id: String, act: Act, variant: Int): Int =
        if (isDoll(id)) FoeArt.sequence(id, MonsterLook(), act, variant).rigs.size
        else if (isBeast(id)) BeastArt.sequence(act, variant).rigs.size else WolfArt.sequence(act, variant).size

    /** The frame count of one foe, whose kit (one blade, a spear, a bow) shapes its moves. */
    fun frameCount(id: String, look: MonsterLook, act: Act, variant: Int): Int =
        if (isDoll(id)) FoeArt.sequence(id, look, act, variant).rigs.size else frameCount(id, act, variant)

    /** The frame in which an attack lands; frames before it play while the monster attacks, the rest while the hit shows. */
    fun strikeFrame(id: String, variant: Int): Int = if (isBeast(id)) BeastArt.sequence(Act.ATTACK, variant).strike else WolfArt.strikeFrame(variant)

    fun strikeFrame(id: String, look: MonsterLook, variant: Int): Int =
        if (isDoll(id)) FoeArt.sequence(id, look, Act.ATTACK, variant).strike else strikeFrame(id, variant)

    /** [wound] 0 healthy, 1 below half its hit points, 2 below a quarter: changes posture. */
    fun battleFrame(id: String, look: MonsterLook, act: Act, variant: Int, index: Int, wound: Int = 0): PixelImage =
        if (isDoll(id)) FoeArt.frame(id, look, act, variant, index)
        else if (isBeast(id)) BeastArt.frame(id, look, act, variant, index, wound)
        else WolfArt.frame(look, id == "dire_wolf", act, variant, index, wound)

    /** The frame to show now: for foes on the doll the nearest one drawn so far, never waiting; see [FoeArt.shown]. */
    fun shownFrame(id: String, look: MonsterLook, act: Act, variant: Int, index: Int, wound: Int = 0): PixelImage =
        if (isDoll(id)) FoeArt.shown(id, look, act, variant, index)
        else if (isBeast(id)) BeastArt.shown(id, look, act, variant, index, wound) else battleFrame(id, look, act, variant, index, wound)

    /**
     * Draws every frame of a new-style monster ahead of time (call off the main thread at the
     * start of a fight), so the first attack does not stutter while its frames are made.
     */
    fun prepare(id: String, look: MonsterLook, wound: Int = 0) {
        if (isDoll(id)) { FoeArt.prepare(id, look); return }
        if (isBeast(id)) { BeastArt.prepare(id, look, wound); return }
        if (!isNewStyle(id)) return
        for (act in Act.entries) {
            val variants = if (act == Act.ATTACK) attackVariants(id) else 1
            for (v in 0 until variants) for (i in 0 until frameCount(id, act, v)) battleFrame(id, look, act, v, i, wound)
        }
    }

    /** Where the feet are across a new-style frame, in sprite pixels from the left: foes on the doll stand off-centre. */
    fun anchorX(id: String, width: Int): Double = if (isDoll(id)) FoeArt.ANCHOR_X else if (isBeast(id)) BeastArt.ANCHOR_X else width / 2.0

    /** How tall and how wide the body itself stands in a new-style frame, in sprite pixels (the frame may be far larger). */
    fun bodySize(id: String, look: MonsterLook, frameW: Int, frameH: Int): Pair<Double, Double> =
        if (isDoll(id)) { val h = FoeArt.doll(id, look).height * FoeArt.PX; Pair(h * 0.75, h) }
        else if (isBeast(id)) BeastArt.bodySize(id, look)
        else Pair(frameW.toDouble(), groundLine(id))

    /** Feet position of a new-style frame, in sprite pixels from the top. */
    fun groundLine(id: String): Double = if (isDoll(id)) FoeArt.ground(id) else if (isBeast(id)) BeastArt.GROUND else WolfArt.GROUND * (if (id == "dire_wolf") 1.22 else 1.0)

    // ---------------------------------------------------------------- the lunge of foes built in the round

    /** How much larger a foe is drawn at the end of its lunge, coming nearer. */
    const val LUNGE_SCALE = 1.18

    /** How far along its lunge the foe is at frame [index] of an attack, 0 to 1. */
    fun lungeAt(id: String, look: MonsterLook, variant: Int, index: Int): Double =
        if (isDoll(id)) FoeArt.lungeAt(id, look, variant, index) else if (isBeast(id)) BeastArt.lungeAt(variant, index) else 0.0

    /** The step for a blow or a bite, in art pixels, so that it lands on ([toX], [toY]). */
    fun lungeOffset(id: String, look: MonsterLook, variant: Int, feetX: Double, feetY: Double, toX: Double, toY: Double): Pair<Double, Double> =
        if (isBeast(id)) BeastArt.lungeOffset(id, look, variant, feetX, feetY, toX, toY) else FoeArt.lungeOffset(id, look, variant, feetX, feetY, toX, toY)

    /** Shrinks [src] to [width] pixels by averaging, keeping the feet on the bottom row of a square image. */
    private fun shrink(src: PixelImage, width: Int): PixelImage {
        val f = src.width.toDouble() / width
        val h = (src.height / f).roundToInt()
        val out = PixelImage(width, maxOf(width * 3 / 4, h))
        val oy = out.height - h
        for (y in 0 until h) for (x in 0 until width) {
            val x0 = (x * f).toInt(); val x1 = maxOf(x0 + 1, ((x + 1) * f).toInt())
            val y0 = (y * f).toInt(); val y1 = maxOf(y0 + 1, ((y + 1) * f).toInt())
            var c = 0; var r = 0; var g = 0; var b = 0
            for (sy in y0 until y1) for (sx in x0 until x1) {
                val p = src[sx, sy]
                if ((p ushr 24) < 200) continue
                c++; r += (p shr 16) and 0xFF; g += (p shr 8) and 0xFF; b += p and 0xFF
            }
            if (c * 2 >= (x1 - x0) * (y1 - y0)) out.set(x, oy + y, argb(((r / c) shl 16) or ((g / c) shl 8) or (b / c)))
        }
        return out
    }

    fun frame(id: String, look: MonsterLook, pose: Pose, idleFrame: Int = 0): PixelImage {
        if (isNewStyle(id) && !isDoll(id)) return when (pose) {
            Pose.IDLE -> legacy(id, look, Act.IDLE, 0, idleFrame.mod(WolfArt.IDLE_FRAMES))
            Pose.ATTACK -> legacy(id, look, Act.ATTACK, 0, WolfArt.strikeFrame(0))
            Pose.HURT -> legacy(id, look, Act.HURT, 0, 2)
        }
        val f = if (pose == Pose.IDLE) idleFrame.mod(IDLE_FRAMES) else 0
        val key = "$id/${look.seed}/${look.shiny}/${look.glow}/$pose/$f"
        synchronized(cache) { cache[key]?.let { return it } }
        val s = Sculpt(SIZE, SIZE, look.seed)
        val boss = id in BOSSES
        val rig = Rig(s, look, pose, f, SHINY_HUE[id] ?: 150.0, boss, if (id == "dire_wolf") 1.14 else 1.0)
        with(rig) {
            when (id) {
                "giant_rat" -> rat()
                "wolf" -> wolf()
                "dire_wolf" -> wolf(alpha = true)
                "goblin" -> goblin(GoblinKind.WARRIOR)
                "goblin_archer" -> goblin(GoblinKind.ARCHER)
                "goblin_shaman" -> goblin(GoblinKind.SHAMAN)
                "skeleton" -> skeleton()
                "zombie" -> zombie()
                "giant_spider" -> spider()
                "bugbear" -> bugbear()
                "hobgoblin_captain" -> hobgoblin()
                "boar" -> boar()
                "stirge" -> stirge()
                "giant_centipede" -> centipede()
                "kobold" -> kobold()
                "ghoul" -> ghoul()
                "giant_bat" -> bat()
                "ochre_jelly" -> jelly()
                else -> goblin(GoblinKind.WARRIOR)
            }
        }
        s.transform()
        s.rim()
        s.outline()
        if (id in FLYERS) rig.groundShadow()
        val img = s.img
        synchronized(cache) { cache[key] = img }
        return img
    }

    private val BOSSES = setOf("bugbear", "hobgoblin_captain", "dire_wolf")
    private val FLYERS = setOf("stirge", "giant_bat")

    /** How far the shimmering variant rotates the colors. */
    private val SHINY_HUE = mapOf(
        "giant_rat" to 200.0, "wolf" to 190.0, "goblin" to 160.0, "goblin_archer" to 160.0, "goblin_shaman" to 200.0,
        "skeleton" to 40.0, "zombie" to 220.0, "giant_spider" to 120.0, "boar" to 180.0, "stirge" to 120.0,
        "giant_centipede" to 140.0, "kobold" to 170.0, "ghoul" to 120.0, "giant_bat" to 150.0, "ochre_jelly" to 160.0,
    )

    private enum class GoblinKind { WARRIOR, ARCHER, SHAMAN }

    private fun Mat.far() = copy(bias = bias - 0.2)
    private fun Mat.soft() = copy(inline = false)

    private class Rig(val s: Sculpt, val look: MonsterLook, val pose: Pose, frame: Int, shinyHue: Double, val boss: Boolean, boost: Double = 1.0) {
        val ph = frame / IDLE_FRAMES.toDouble() * 2 * PI
        /** Idle breathing, -1..1. */
        val b = if (pose == Pose.IDLE) sin(ph) else 0.0
        val c = if (pose == Pose.IDLE) cos(ph) else 0.0
        val atk = pose == Pose.ATTACK
        val hurt = pose == Pose.HURT
        val hue = (if (boss) 0.0 else look.range(1) * 12) + if (look.shiny) shinyHue else 0.0
        val size = (if (boss) 1.0 else 1 + look.range(2) * 0.05) * boost
        val shiny = look.shiny

        fun pick(n: Int, salt: Int) = look.pick(n, salt)

        /** A material that follows the monster's color variation. */
        fun skin(rgb: Int, grain: Double = 0.0, shine: Double = 0.0, sat: Double = 1.0, value: Double = 1.0) =
            Mat(Ramp.of(argb(rgb), hue, sat, value), shine, grain)

        /** A material with a fixed color (metal, wood, bone). */
        fun fixed(rgb: Int, shine: Double = 0.0, grain: Double = 0.0) = Mat(Ramp.of(argb(rgb)), shine, grain)

        fun eye(default: Int) = look.glow ?: argb(default)

        /** Positions the whole body: [x] leans, [y] bobs; idle breathing stretches it a little. */
        fun body(x: Double = 0.0, y: Double = 0.0, stretch: Double = 0.015) =
            s.transform(x, y, size, size * (1 + b * stretch))

        val steel get() = fixed(0xA8B2C0, shine = 0.8)
        val rust get() = fixed(0x9A7A62, shine = 0.3, grain = 0.15)
        val wood get() = fixed(0x8A5A30, grain = 0.1)
        val leather get() = fixed(0x6E4428, grain = 0.05)
        val bone get() = fixed(0xE8DEC6, grain = 0.05)
        val dark = argb(0x1C1620)
        val mouth = argb(0x5A1A22)

        /** A blade from the hand at ([hx], [hy]) pointing at [deg] (0 = right, -90 = up). */
        fun blade(hx: Double, hy: Double, deg: Double, len: Double, wid: Double, curve: Double, m: Mat) {
            val a = Math.toRadians(deg)
            val dx = cos(a); val dy = sin(a); val px = -dy; val py = dx
            val n = 6
            val l = ArrayList<Double>(); val r = ArrayList<Double>()
            for (i in 0..n) {
                val t = i / n.toDouble()
                val cx = hx + dx * len * t + px * curve * t * t
                val cy = hy + dy * len * t + py * curve * t * t
                val hw = wid * (1 - t * 0.7) * (if (i == n) 0.15 else 1.0)
                l += cx + px * hw; l += cy + py * hw
                r += cx - px * hw; r += cy - py * hw
            }
            val pts = DoubleArray(l.size + r.size)
            for (i in l.indices) pts[i] = l[i]
            for (i in 0 until r.size / 2) {
                val j = r.size / 2 - 1 - i
                pts[l.size + i * 2] = r[j * 2]; pts[l.size + i * 2 + 1] = r[j * 2 + 1]
            }
            s.poly(m, *pts, tiltX = -0.3, tiltY = -0.35, bevel = 1.2)
        }

        /** Handle and cross guard behind a blade held at ([hx], [hy]). */
        fun hilt(hx: Double, hy: Double, deg: Double, guard: Mat, grip: Mat = leather) {
            val a = Math.toRadians(deg)
            val dx = cos(a); val dy = sin(a)
            s.limb(hx - dx * 4, hy - dy * 4, hx + dx * 1, hy + dy * 1, 1.1, 1.1, grip)
            s.limb(hx + dy * 3, hy - dx * 3, hx - dy * 3, hy + dx * 3, 0.9, 0.9, guard)
        }

        fun groundShadow() {
            val img = s.img
            for (y in 56..62) for (x in 14..50) {
                val ux = (x + 0.5 - 32) / 15.0; val uy = (y + 0.5 - 59.5) / 3.0
                if (ux * ux + uy * uy <= 1 && !img.opaque(x, y)) img.set(x, y, alpha(argb(0x101018), 70))
            }
        }

        // ============================================================ beasts

        fun rat() {
            val tone = pick(3, 10)
            val fur = skin(listOf(0x8A7868, 0x6E6460, 0x9A7A58)[tone], grain = 0.14)
            val belly = skin(0xC8B8A4, grain = 0.08).soft()
            val pink = skin(0xE89AA8, sat = 0.9)
            body(if (atk) -3.0 else if (hurt) 3.0 else 0.0, 0.0)
            val sway = c * 2.5
            s.chain(pink.far(), 46.0, 52.0, 2.0, 53.0, 55.0, 1.7, 59.0, 52.0 + sway * 0.3, 1.3, 61.5, 45.0 + sway, 1.0, 59.0, 39.0 + sway, 0.7)
            s.limb(26.0, 52.0, 25.0, 59.0, 2.0, 1.6, fur.far())
            s.limb(42.0, 52.0, 45.0, 59.0, 2.6, 1.8, fur.far())
            s.blob(36.0, 47.0 - b * 0.4, 14.0, 9.5 + b * 0.3, fur)
            s.blob(44.0, 47.0, 8.5, 8.0, fur)
            s.blob(32.0, 53.0, 9.0, 3.5, belly)
            // head
            val hx = if (atk) 14.0 else 17.0
            val hy = (if (atk) 46.0 else if (hurt) 41.0 else 44.0) + c * 0.6
            s.blob(hx + 5, hy - 7.5, 3.6, 4.2, fur)
            s.blob(hx + 5, hy - 7.0, 2.0, 2.6, pink.soft())
            s.blob(hx + 4, hy - 1, 8.0, 6.8, fur)
            s.limb(hx + 1, hy, hx - 7, hy + 2.5, 4.8, 2.2, fur)
            s.blob(hx - 8, hy + 2.2, 1.6, 1.3, pink)
            if (atk) {
                s.flat(hx - 4, hy + 4.5, 3.0, 1.5, mouth)
                s.dot(hx - 6, hy + 4, Pal.WHITE); s.dot(hx - 5, hy + 4, Pal.WHITE)
            } else {
                s.dot(hx - 5, hy + 4, Pal.WHITE); s.dot(hx - 5, hy + 5, Pal.WHITE)
            }
            if (hurt) s.line(hx - 2.5, hy - 2, hx + 0.5, hy - 1.5, dark) else s.eye(hx - 1, hy - 2, 1.6, eye(0xE03030))
            if (pick(4, 11) == 0) s.line(hx + 1.0, hy - 5, hx - 2.0, hy + 1, argb(0xD8A0A0))
            s.limb(22.0, 51.0, 20.0, 59.0, 2.2, 1.6, fur)
            s.limb(38.0, 52.0, 37.0, 59.0, 3.0, 1.8, fur)
            s.blob(19.5, 59.5, 2.4, 1.2, pink); s.blob(36.0, 59.5, 2.6, 1.2, pink)
            val wc = argb(0xE8E0D8)
            s.line(hx - 6, hy + 1, hx - 12, hy - 1, wc); s.line(hx - 6, hy + 2, hx - 12, hy + 3, wc)
        }

        fun wolf(alpha: Boolean = false) {
            val tone = if (alpha) 2 else pick(4, 10)
            val furC = if (alpha) 0x3E3C48 else listOf(0x8A92A2, 0x8A6E52, 0x4E4E5C, 0xC8C8C8)[tone]
            val fur = skin(furC, grain = 0.16)
            val pale = skin(if (tone == 2) 0x8A8A98 else 0xD8D8D8, grain = 0.1).soft()
            body(if (atk) -4.0 else if (hurt) 4.0 else 0.0, 0.0)
            s.chain(fur, 50.0, 37.0, 3.6, 56.0, 34.0 + b, 3.2, 61.0, 39.0 + b * 1.6, 1.8)
            s.limb(28.0, 45.0, 30.0, 58.0, 2.8, 2.2, fur.far())
            s.limb(49.0, 44.0, 52.0, 51.0, 3.6, 2.6, fur.far())
            s.limb(52.0, 51.0, 49.0, 59.0, 2.4, 2.0, fur.far())
            s.blob(38.0, 41.0 - b * 0.4, 15.0, 9.0, fur)
            s.blob(36.0, 47.0, 10.0, 3.6, pale)
            s.blob(24.0, 40.0, 9.5, 11.0, fur)
            s.blob(22.0, 44.0, 6.0, 6.0, pale)
            // head
            val hx = if (atk) 11.0 else if (hurt) 17.0 else 14.0
            val hy = (if (atk) 33.0 else if (hurt) 25.0 else 28.0) + b * 0.6
            s.blob(19.0, 33.0, 7.5, 8.5, fur)
            s.poly(fur.far(), hx - 1, hy - 3, hx, hy - 12, hx + 4, hy - 4)
            s.blob(hx + 2, hy, 7.5, 6.5, fur)
            s.poly(fur, hx + 3, hy - 4, hx + 6, hy - 13, hx + 9, hy - 3, tiltX = -0.3)
            s.poly(skin(0xD89AA0).soft(), hx + 4.6, hy - 5, hx + 6, hy - 10, hx + 7.4, hy - 4.5)
            if (atk) s.limb(hx - 1, hy + 5, hx - 8, hy + 9, 2.6, 1.6, fur)
            s.limb(hx - 1, hy + 2, hx - 9, hy + (if (atk) 2.0 else 4.0), 4.2, 2.6, fur)
            if (atk) {
                s.flat(hx - 4, hy + 6, 4.0, 1.4, mouth)
                for (i in 0..3) s.dot(hx - 8 + i * 2, hy + 5, Pal.WHITE)
            }
            s.blob(hx - 9.5, hy + (if (atk) 1.5 else 3.5), 1.5, 1.3, fixed(0x202028, shine = 1.0))
            if (hurt) s.line(hx - 2.5, hy - 1, hx + 0.5, hy - 0.5, dark) else s.eye(hx - 1.5, hy - 0.8, 1.5, eye(if (alpha) 0xF03030 else 0xF0C030))
            // the alpha wolf carries an old scar across the eye
            if (alpha) s.line(hx - 3.5, hy - 4.0, hx + 1.0, hy + 2.5, argb(0xC89090))
            s.limb(22.0, 47.0, 20.0, 59.0, 3.2, 2.4, fur)
            s.blob(19.0, 59.5, 3.2, 1.6, fur)
            s.limb(45.0, 44.0, 47.0, 52.0, 4.0, 3.0, fur)
            s.limb(47.0, 52.0, 43.0, 59.0, 2.7, 2.2, fur)
            s.blob(42.0, 59.5, 3.0, 1.5, fur)
        }

        fun boar() {
            val fur = skin(listOf(0x6A4A34, 0x5A4A44, 0x7A5634)[pick(3, 10)], grain = 0.2)
            val bristle = skin(0x3A2A22, grain = 0.1)
            val snout = skin(0xC88878, sat = 0.8)
            val tusk = fixed(0xF0E6C8, shine = 0.5)
            body(if (atk) -4.0 else if (hurt) 4.0 else 0.0, 0.0, stretch = 0.02)
            s.limb(30.0, 46.0, 30.0, 58.0, 3.2, 2.6, fur.far())
            s.limb(47.0, 46.0, 48.0, 58.0, 3.6, 2.6, fur.far())
            s.blob(40.0, 43.0, 16.0, 11.5, fur)
            s.blob(27.0, 38.0 - b * 0.4, 12.0, 13.0, fur)
            // bristle ridge along the back
            for (i in 0..7) {
                val x = 20.0 + i * 4.0
                val y = 26.0 + i * 0.9 + (if (i > 3) i - 3.0 else 0.0)
                s.poly(bristle, x - 2.5, y + 3, x + 0.5, y - 4 - (i % 2), x + 2.5, y + 3, bevel = 0.8)
            }
            s.poly(fur, 56.0, 38.0, 61.0, 34.0 + c, 58.0, 42.0)
            val hx = if (atk) 12.0 else 15.0
            val hy = (if (atk) 46.0 else if (hurt) 38.0 else 42.0) + c * 0.5
            s.poly(fur.far(), hx + 6, hy - 6, hx + 11, hy - 14, hx + 12, hy - 5)
            s.blob(hx + 4, hy, 8.5, 8.0, fur, rot = 0.3)
            s.limb(hx, hy + 2, hx - 7, hy + 4, 5.0, 4.2, fur)
            s.blob(hx - 8.5, hy + 4.2, 1.8, 3.6, snout)
            s.dot(hx - 9, hy + 3, dark); s.dot(hx - 9, hy + 5.5, dark)
            s.limb(hx - 4, hy + 7, hx - 7, hy + 1, 1.3, 0.6, tusk)
            if (pick(3, 12) == 0) s.limb(hx - 1, hy + 7, hx - 2, hy + 2, 1.0, 0.5, tusk)
            s.poly(fur, hx + 2, hy - 6, hx + 4, hy - 14, hx + 8, hy - 6, tiltX = -0.3)
            if (hurt) s.line(hx - 1.5, hy - 2, hx + 1.5, hy - 1.5, dark) else s.eye(hx, hy - 2, 1.3, eye(0xE04020))
            s.limb(22.0, 46.0, 21.0, 58.0, 3.6, 2.8, fur)
            s.limb(42.0, 48.0, 41.0, 58.0, 3.6, 2.8, fur)
            val hoof = fixed(0x2A2028, shine = 0.4)
            s.blob(21.0, 59.5, 3.0, 1.6, hoof); s.blob(41.0, 59.5, 3.0, 1.6, hoof)
        }

        fun spider() {
            val tone = pick(3, 10)
            val chitin = skin(listOf(0x3A3044, 0x4A3A2A, 0x2A3A3A)[tone], grain = 0.12, shine = 0.35)
            val markC = listOf(0xD03030, 0xE0B030, 0xE8E8E8)[pick(3, 11)]
            val legLift = { i: Int -> if (pose == Pose.IDLE) sin(ph + i * 1.3) * 1.2 else 0.0 }
            body(if (atk) -3.0 else if (hurt) 3.0 else 0.0, 0.0)
            fun leg(i: Int, near: Boolean) {
                val m = if (near) chitin else chitin.far()
                val bx = 22.0 + i * 3.5
                val by = 43.0
                val spread = if (near) -1.0 else 1.0
                val kx = bx + (i - 1.5) * 9 + spread * 2
                val ky = (if (near) 29.0 else 26.0) + i * 1.2 + legLift(i + if (near) 0 else 4) + if (atk && i == 0) -4.0 else 0.0
                val fx = bx + (i - 1.5) * 15 + spread * 3 + (if (atk && i == 0) -6.0 else 0.0)
                val fy = if (near) 60.0 else 57.0
                s.limb(bx, by, kx, ky, 2.0, 1.6, m)
                s.limb(kx, ky, fx, fy, 1.6, 0.8, m)
            }
            for (i in 0..3) leg(i, near = false)
            s.blob(44.0, 38.0 - b * 0.5, 15.0, 12.5 + b * 0.4, chitin)
            when (pick(3, 12)) {
                0 -> { s.tint(46.0, 35.0, 3.0, 5.0, argb(markC), 0.75); s.tint(46.0, 42.0, 2.0, 2.0, argb(markC), 0.75) }
                1 -> for (i in 0..2) s.tint(38.0 + i * 6, 34.0 + i, 1.2, 5.0, argb(markC), 0.6)
                else -> for (i in 0..3) s.tint(40.0 + (i % 2) * 7, 32.0 + i * 3, 1.5, 1.5, argb(markC), 0.7)
            }
            s.blob(25.0, 43.0, 9.0, 7.5, chitin)
            val hy = if (atk) 47.0 else if (hurt) 40.0 else 45.0
            s.blob(16.0, hy, 6.5, 5.5, chitin)
            val fang = fixed(0xD8C8B0, shine = 0.6)
            s.limb(12.0, hy + 4, if (atk) 9.0 else 11.0, hy + 9, 1.4, 0.6, fang)
            s.limb(16.0, hy + 4, if (atk) 15.0 else 16.0, hy + 9, 1.4, 0.6, fang)
            val e = eye(0xF03030)
            if (!hurt) {
                s.eye(12.5, hy - 1.5, 1.4, e, pupil = false); s.eye(16.5, hy - 2, 1.4, e, pupil = false)
                s.dot(11.0, hy - 3.5, e); s.dot(14.5, hy - 4.5, e); s.dot(18.5, hy - 4.0, e); s.dot(19.5, hy - 1.5, e)
            } else {
                s.line(11.0, hy - 1.5, 18.0, hy - 2.0, e)
            }
            for (i in 0..3) leg(i, near = true)
        }

        fun centipede() {
            val shell = skin(listOf(0xA04A28, 0x7A3A50, 0x5A6A2A)[pick(3, 10)], shine = 0.4, grain = 0.06)
            val plate = shell.copy(bias = 0.12)
            val legC = skin(0xE0B070).far()
            body(if (atk) -2.0 else if (hurt) 3.0 else 0.0, 0.0, stretch = 0.0)
            val n = 15
            val xs = DoubleArray(n); val ys = DoubleArray(n)
            for (i in 0 until n) {
                val t = i / (n - 1.0)
                // the tail lies on the ground, the front half rears up
                val rise = if (t < 0.5) (0.5 - t) * 2 else 0.0
                xs[i] = 17.0 + t * 42 - rise * 4 + (if (atk) -rise * 6 else 0.0)
                ys[i] = 56.0 - rise * rise * 30 - (if (hurt) -rise * 4 else 0.0) + sin(ph + i * 0.8) * (if (t > 0.4) 1.0 else 0.6)
            }
            for (i in n - 1 downTo 1) {
                val r = 5.4 - i * 0.12
                val ground = ys[i] > 50
                val ex = if (ground) 0.0 else 3.0
                s.limb(xs[i], ys[i] + r * 0.5, xs[i] - 3.0 - ex, if (ground) 60.5 else ys[i] + r + 3.5, 0.9, 0.6, legC)
                s.limb(xs[i], ys[i] + r * 0.5, xs[i] + 2.5 + ex, if (ground) 59.5 else ys[i] + r + 2.5, 0.9, 0.6, legC)
            }
            for (i in n - 1 downTo 0) {
                val r = 5.4 - i * 0.12
                s.blob(xs[i], ys[i], r + 0.6, r, if (i % 2 == 0) shell else plate)
            }
            val hx = xs[0] - 3; val hy = ys[0] - 1
            val ant = skin(0xE0B070)
            s.limb(hx, hy - 3, hx - 7 + c, hy - 13, 0.8, 0.5, ant)
            s.limb(hx + 2, hy - 3, hx + 3 + c, hy - 14, 0.8, 0.5, ant.far())
            s.blob(hx, hy, 5.0, 4.4, shell)
            val pincer = fixed(0x2A1A1A, shine = 0.6)
            val open = if (atk) 3.0 else 0.0
            s.limb(hx - 2, hy + 3, hx - 6, hy + 6 + open, 1.3, 0.6, pincer)
            s.limb(hx + 1, hy + 3, hx - 3, hy + 8 + open, 1.3, 0.6, pincer)
            if (!hurt) { s.eye(hx - 2, hy - 1, 1.1, eye(0xF0E040), pupil = false); s.dot(hx + 1.5, hy - 1.5, eye(0xF0E040)) }
        }

        fun stirge() {
            val fur = skin(listOf(0x8A3A3A, 0x6A4A3A, 0x7A3A5A)[pick(3, 10)], grain = 0.15)
            val wing = skin(0x6A3A4A, sat = 0.8).copy(bias = -0.05)
            val flap = if (pose == Pose.IDLE) b * 8 else if (atk) -8.0 else 6.0
            body(if (atk) -5.0 else if (hurt) 3.0 else 0.0, -14.0 + b * 2.5, stretch = 0.0)
            s.poly(wing.far(), 38.0, 30.0, 52.0, 14.0 + flap, 61.0, 21.0 + flap, 56.0, 25.0 + flap * 0.7, 54.0, 31.0 + flap * 0.4, 49.0, 30.0 + flap * 0.2, 45.0, 35.0)
            for (k in 0..2) s.limb(28.0 + k * 2, 42.0, 24.0 + k * 3, 52.0, 0.7, 0.4, fixed(0x3A2A2A))
            s.blob(34.0, 36.0, 9.0, 7.5, fur)
            s.blob(23.0, 34.0 + (if (atk) 2.0 else 0.0), 5.0, 4.6, fur)
            val prob = fixed(0xC8A890, shine = 0.4)
            val px = if (atk) 3.0 else 8.0
            s.limb(19.0, 36.0, px, if (atk) 44.0 else 42.0, 1.4, 0.4, prob)
            if (!hurt) s.eye(21.5, 32.5, 1.3, eye(0xF0D040)) else s.line(20.0, 32.5, 23.0, 32.5, dark)
            s.poly(wing, 30.0, 32.0, 18.0, 14.0 + flap, 9.0, 21.0 + flap, 14.0, 25.0 + flap * 0.7, 16.0, 31.0 + flap * 0.4, 21.0, 30.0 + flap * 0.2, 25.0, 36.0, bevel = 1.0)
            s.line(30.0, 32.0, 18.0, 14.0 + flap, argb(0x3A1A24))
        }

        fun bat() {
            val fur = skin(listOf(0x5A4038, 0x3A3438, 0x6A5034)[pick(3, 10)], grain = 0.16)
            val wing = skin(0x4A3440, sat = 0.9).copy(bias = -0.05)
            val bone = skin(0x2E2228)
            val up = if (pose == Pose.IDLE) b * 9 else if (atk) 4.0 else -6.0
            body(if (atk) -4.0 else if (hurt) 3.0 else 0.0, -10.0 + b * 3, stretch = 0.0)
            fun wingSide(dir: Double) {
                val cx = 32.0
                val sx = cx + dir * 5
                val tipY = 14.0 - up
                val pts = doubleArrayOf(
                    sx, 28.0,
                    cx + dir * 18, tipY + 4,
                    cx + dir * 30, tipY + 10,
                    cx + dir * 26, 34.0 - up * 0.3,
                    cx + dir * 21, 30.0 - up * 0.3,
                    cx + dir * 16, 38.0 - up * 0.2,
                    cx + dir * 10, 34.0,
                    sx, 40.0,
                )
                s.poly(if (dir > 0) wing.far() else wing, *pts, bevel = 1.0)
                s.limb(sx, 28.0, cx + dir * 18, tipY + 4, 1.2, 0.8, bone)
                s.limb(cx + dir * 18, tipY + 4, cx + dir * 30, tipY + 10, 0.8, 0.5, bone)
                s.line(cx + dir * 18, tipY + 4, cx + dir * 21, 30.0 - up * 0.3, argb(0x2E2228))
                s.line(cx + dir * 18, tipY + 4, cx + dir * 26, 34.0 - up * 0.3, argb(0x2E2228))
            }
            wingSide(1.0); wingSide(-1.0)
            s.blob(32.0, 34.0, 7.0, 8.5, fur)
            val hy = if (atk) 26.0 else 24.0
            s.poly(fur, 26.0, hy - 2, 25.0, hy - 12, 30.0, hy - 4)
            s.poly(fur.far(), 34.0, hy - 4, 39.0, hy - 12, 38.0, hy - 2)
            s.blob(32.0, hy, 6.5, 5.5, fur)
            s.blob(32.0, hy + 2.5, 3.0, 2.0, skin(0x8A6058))
            if (hurt) {
                s.line(28.0, hy - 1, 30.0, hy - 1, dark); s.line(34.0, hy - 1, 36.0, hy - 1, dark)
            } else {
                s.eye(29.0, hy - 1, 1.3, eye(0xE03030), pupil = false); s.eye(35.0, hy - 1, 1.3, eye(0xE03030), pupil = false)
            }
            if (atk) s.flat(32.0, hy + 4.5, 2.5, 1.6, mouth)
            s.dot(30.5, hy + 4.0, Pal.WHITE); s.dot(33.5, hy + 4.0, Pal.WHITE)
            s.dot(30.5, hy + 5.0, Pal.WHITE); s.dot(33.5, hy + 5.0, Pal.WHITE)
        }

        fun jelly() {
            val goo = skin(listOf(0xD0962A, 0xC8B030, 0xC07028)[pick(3, 10)], shine = 1.0)
            val w = if (pose == Pose.IDLE) b * 0.06 else if (hurt) -0.1 else 0.0
            s.transform(if (atk) -2.0 else 0.0, 0.0, size * (1 + w), size * (1 - w))
            s.blob(32.0, 50.0, 23.0, 11.0, goo.copy(inline = false), depth = 0.7)
            s.blob(28.0, 40.0, 14.0, 10.0, goo.soft(), depth = 0.8)
            s.blob(42.0, 44.0, 8.0, 6.5, goo.soft())
            s.blob(36.0, 32.0 + b, 7.0, 5.5, goo.soft())
            if (atk) s.limb(20.0, 44.0, 4.0, 40.0, 5.0, 3.0, goo.soft()) else s.blob(14.0, 54.0, 5.0, 3.5, goo.soft())
            val bubble = alpha(argb(0xFFF0B0), 255)
            for (i in 0..5) {
                val bx = 18.0 + look.pick(28, 20 + i)
                val by = 38.0 + look.pick(16, 30 + i) - (if (pose == Pose.IDLE) (ph * 2 + i).mod(4.0) else 0.0)
                s.flat(bx, by, 1.0, 1.0, mix(goo.ramp.light, bubble, 0.5))
                s.dot(bx - 0.5, by - 0.5, Pal.WHITE)
            }
            // something half digested inside
            if (pick(3, 13) == 0) s.tint(36.0, 48.0, 3.0, 3.5, argb(0xF0E8D0), 0.45)
            s.tint(32.0, 59.0, 22.0, 2.0, goo.ramp.dark, 0.5)
        }

        // ============================================================ humanoids

        fun goblin(kind: GoblinKind) {
            val gskin = skin(if (shiny) 0x6CB048 else listOf(0x6CB048, 0x88A040, 0x5A9A5A)[pick(3, 10)], grain = 0.04)
            val cloth = when (kind) {
                GoblinKind.SHAMAN -> fixed(listOf(0x5A4A6A, 0x4A5A3A, 0x6A3A3A)[pick(3, 11)], grain = 0.1)
                else -> fixed(listOf(0x8A3A2A, 0x6A5434, 0x3A5A6A, 0x5A5A3A)[pick(4, 11)], grain = 0.08)
            }
            body(if (atk) -2.0 else if (hurt) 2.0 else 0.0, if (hurt) 1.0 else 0.0)
            val shield = kind == GoblinKind.WARRIOR && pick(3, 12) == 0
            // far leg and arm
            s.limb(36.0, 47.0, 37.0, 58.0, 3.0, 2.5, cloth.far())
            s.blob(36.0, 59.5, 3.6, 2.0, leather.far())
            if (kind == GoblinKind.ARCHER) {
                s.limb(40.0, 26.0, 46.0, 44.0, 2.6, 2.2, leather)
                for (i in 0..2) s.limb(41.0 + i, 26.0, 43.0 + i * 1.6, 19.0, 0.6, 0.6, fixed(listOf(0xE0E0E0, 0xD04040, 0xE0E0E0)[i]))
            }
            if (!shield) s.limb(39.0, 35.0, 42.0, 44.0, 2.2, 2.0, gskin.far())
            // torso
            if (kind == GoblinKind.SHAMAN) s.poly(cloth, 24.0, 34.0, 40.0, 34.0, 44.0, 54.0, 20.0, 54.0, tiltX = -0.2)
            s.blob(32.0, 41.0 + b * 0.3, 9.0, 9.5, cloth)
            s.limb(23.5, 45.0, 40.5, 45.0, 1.2, 1.2, leather)
            s.blob(29.0, 45.0, 1.4, 1.2, fixed(0xD0A040, shine = 0.8))
            if (kind == GoblinKind.SHAMAN) for (i in 0..4) s.blob(25.0 + i * 3, 33.5 + (if (i == 2) 1.5 else if (i % 2 == 1) 1.0 else 0.0), 1.2, 1.4, bone)
            if (shield) {
                s.blob(42.0, 40.0, 7.0, 8.0, wood, depth = 0.5)
                s.blob(42.0, 40.0, 2.0, 2.2, steel)
                s.tint(42.0, 40.0, 7.0, 0.6, argb(0x4A3020), 0.5)
            }
            s.limb(28.0, 48.0, 26.0, 58.0, 3.2, 2.7, cloth)
            s.blob(25.0, 59.5, 4.0, 2.2, leather)
            // head
            val hx = 30.0 + if (atk) -2.0 else 0.0
            val hy = 24.0 + b * 0.5 + if (hurt) 1.5 else 0.0
            // ears sit behind the head
            s.poly(gskin.far(), hx + 6, hy - 4, hx + 21, hy - 11 - c, hx + 8, hy + 2, tiltX = 0.2)
            s.poly(gskin, hx - 6, hy - 4, hx - 21, hy - 10 + c, hx - 8, hy + 2, tiltX = -0.4, bevel = 2.0)
            s.poly(gskin.copy(bias = -0.3).soft(), hx - 9, hy - 3, hx - 17, hy - 8 + c, hx - 9, hy)
            s.blob(hx, hy, 10.5, 9.5, gskin)
            s.limb(hx - 6, hy + 1, hx - 10, hy + 4, 2.4, 1.6, gskin)
            if (pick(3, 14) == 0) {
                s.tint(hx - 2, hy - 1, 7.0, 1.0, argb(0xC02020), 0.55)
                s.tint(hx - 2, hy + 3, 6.0, 0.8, argb(0xC02020), 0.55)
            }
            if (hurt) {
                s.line(hx - 7, hy - 3, hx - 3, hy - 2, dark); s.line(hx + 0.5, hy - 2, hx + 4, hy - 3, dark)
            } else {
                s.eye(hx - 5, hy - 2, 1.8, eye(0xF0D030)); s.eye(hx + 2, hy - 2, 1.8, eye(0xF0D030))
                s.line(hx - 7.5, hy - 5.5, hx - 3, hy - 4.2, argb(0x2A3A20)); s.line(hx + 0.5, hy - 4.2, hx + 4.5, hy - 5.5, argb(0x2A3A20))
            }
            if (atk || hurt) {
                s.flat(hx - 3, hy + 6, 4.0, 2.0, mouth)
                s.dot(hx - 5, hy + 5, Pal.WHITE); s.dot(hx - 1, hy + 5, Pal.WHITE)
            } else {
                s.line(hx - 7, hy + 5.5, hx + 1, hy + 6.5, argb(0x2A2A20))
                s.dot(hx - 5, hy + 6.5, Pal.WHITE); s.dot(hx - 1, hy + 7.5, Pal.WHITE)
            }
            // headgear
            when {
                kind == GoblinKind.SHAMAN -> {
                    val fc = listOf(0xD04030, 0x3080D0, 0xE0C030)
                    for (i in 0..4) {
                        val a = -150.0 + i * 25
                        s.limb(hx, hy - 6, Sculpt.polarX(hx, 14.0, a), Sculpt.polarY(hy - 6, 14.0, a), 1.6, 0.6, fixed(fc[(i + pick(3, 15)) % 3]))
                    }
                    s.limb(hx - 9, hy - 6, hx + 9, hy - 6, 1.3, 1.3, fixed(0x8A3A2A))
                    s.blob(hx, hy - 10, 4.5, 4.0, bone)
                    s.blob(hx, hy - 6.5, 2.8, 1.6, bone)
                    s.flat(hx - 1.7, hy - 10, 1.1, 1.2, dark); s.flat(hx + 1.7, hy - 10, 1.1, 1.2, dark)
                }
                kind == GoblinKind.ARCHER && pick(2, 16) == 0 -> s.poly(cloth, hx - 10, hy - 2, hx, hy - 14, hx + 10, hy - 2, hx + 8, hy + 2, hx - 8, hy - 1)
                kind == GoblinKind.WARRIOR && pick(3, 16) == 0 -> {
                    s.blob(hx, hy - 5.5, 10.5, 5.5, rust)
                    s.limb(hx - 10, hy - 3, hx + 10, hy - 3, 1.0, 1.0, rust)
                }
                else -> {}
            }
            // weapon arm
            when (kind) {
                GoblinKind.ARCHER -> {
                    val bx = if (atk) 12.0 else 15.0
                    val by = 38.0
                    val bow = fixed(0x7A4A28, grain = 0.05)
                    s.chain(bow, bx + 3, by - 13, 1.0, bx, by - 6, 1.4, bx - 1, by, 1.6, bx, by + 6, 1.4, bx + 3, by + 13, 1.0)
                    val pull = if (atk) 8.0 else 3.0
                    s.line(bx + 3, by - 13, bx + 3 + pull, by, argb(0xE8E0D0)); s.line(bx + 3 + pull, by, bx + 3, by + 13, argb(0xE8E0D0))
                    if (atk) {
                        s.limb(bx - 6, by, bx + 3 + pull, by, 0.5, 0.5, wood)
                        s.poly(steel, bx - 9, by, bx - 5, by - 2, bx - 5, by + 2)
                    }
                    s.limb(25.0, 35.0, bx, by, 2.2, 1.8, gskin)
                    s.blob(bx, by, 2.2, 2.2, gskin)
                }
                GoblinKind.SHAMAN -> {
                    val sx = if (atk) 14.0 else 17.0
                    val top = if (atk) 12.0 else 16.0
                    s.limb(sx + 2, 59.0, sx, top, 1.3, 1.3, wood)
                    s.blob(sx, top - 2, 3.6, 3.2, bone)
                    s.flat(sx - 1.2, top - 2.5, 0.8, 0.9, dark); s.flat(sx + 1.2, top - 2.5, 0.8, 0.9, dark)
                    val orb = look.glow ?: argb(if (shiny) 0xF060E0 else 0x60E0A0)
                    val r = if (atk) 3.4 else 2.4 + b * 0.3
                    s.flat(sx, top - 8, r + 1.5, r + 1.5, alpha(orb, 110))
                    s.flat(sx, top - 8, r, r, orb)
                    s.dot(sx - 1, top - 9, Pal.WHITE)
                    s.limb(25.0, 35.0, sx + 1, 40.0, 2.2, 1.8, gskin)
                    s.blob(sx + 1, 40.0, 2.2, 2.2, gskin)
                }
                GoblinKind.WARRIOR -> {
                    val (hxp, hyp, deg) = when (pose) {
                        Pose.ATTACK -> Triple(13.0, 40.0, 160.0)
                        Pose.HURT -> Triple(21.0, 44.0, -70.0)
                        Pose.IDLE -> Triple(19.0, 42.0 + b * 0.5, -115.0 + c * 3)
                    }
                    when (pick(3, 17)) {
                        0 -> {
                            hilt(hxp, hyp, deg, fixed(0x8A6A30, shine = 0.6))
                            blade(hxp, hyp, deg, 15.0, 2.2, -3.0, steel)
                        }
                        1 -> {
                            val a = Math.toRadians(deg)
                            s.limb(hxp - cos(a) * 6, hyp - sin(a) * 6, hxp + cos(a) * 14, hyp + sin(a) * 14, 1.0, 1.0, wood)
                            blade(hxp + cos(a) * 13, hyp + sin(a) * 13, deg, 6.0, 2.0, 0.0, steel)
                        }
                        else -> {
                            val a = Math.toRadians(deg)
                            s.limb(hxp - cos(a) * 3, hyp - sin(a) * 3, hxp + cos(a) * 12, hyp + sin(a) * 12, 1.4, 3.0, wood)
                            s.dot(hxp + cos(a) * 10, hyp + sin(a) * 10 - 1, Pal.IRON_LIGHT)
                            s.dot(hxp + cos(a) * 12 + 1, hyp + sin(a) * 12, Pal.IRON_LIGHT)
                        }
                    }
                    s.limb(25.0, 35.0, hxp, hyp, 2.2, 1.8, gskin)
                    s.blob(hxp, hyp, 2.3, 2.3, gskin)
                }
            }
        }

        fun kobold() {
            val scales = skin(listOf(0xB0583A, 0x8A5A3A, 0x5A6A8A)[pick(3, 10)], grain = 0.12, shine = 0.2)
            val belly = skin(0xD8B880).soft()
            val rag = fixed(listOf(0x6A5A40, 0x7A3A3A, 0x4A5A4A)[pick(3, 11)], grain = 0.1)
            body(if (atk) -3.0 else if (hurt) 3.0 else 0.0, 0.0)
            s.chain(scales, 36.0, 50.0, 3.0, 44.0, 56.0, 2.4, 52.0, 58.0 + c * 0.5, 1.8, 59.0, 54.0 + c, 1.0)
            s.limb(34.0, 50.0, 36.0, 55.0, 2.6, 2.0, scales.far())
            s.limb(36.0, 55.0, 34.0, 59.0, 1.8, 1.6, scales.far())
            s.limb(36.0, 38.0, 39.0, 46.0, 1.8, 1.6, scales.far())
            s.blob(31.0, 45.0 + b * 0.3, 6.5, 7.5, scales)
            s.blob(29.0, 47.0, 3.5, 5.0, belly)
            s.poly(rag, 24.0, 45.0, 38.0, 45.0, 37.0, 52.0, 33.0, 50.0, 30.0, 53.0, 25.0, 50.0)
            s.limb(28.0, 50.0, 27.0, 55.0, 2.8, 2.0, scales)
            s.limb(27.0, 55.0, 29.0, 59.0, 1.9, 1.6, scales)
            s.blob(27.0, 59.8, 3.0, 1.3, scales)
            // head
            val hx = if (atk) 25.0 else 28.0
            val hy = (if (hurt) 31.0 else 32.0) + b * 0.4
            val horn = fixed(0xE8DCC0)
            s.limb(hx + 4, hy - 4, hx + 10, hy - 9, 1.6, 0.5, horn.far())
            s.blob(hx, hy, 6.5, 5.5, scales)
            s.limb(hx - 3, hy + 1, hx - 12, hy + (if (atk) 2.0 else 3.0), 3.8, 2.2, scales)
            if (atk) {
                s.limb(hx - 3, hy + 4, hx - 10, hy + 7, 1.8, 1.1, scales)
                s.flat(hx - 7, hy + 4.5, 3.0, 1.0, mouth)
            }
            for (i in 0..2) s.dot(hx - 10 + i * 2.5, hy + 4.0, Pal.WHITE)
            s.limb(hx + 2, hy - 4, hx + 7, hy - 9, 1.5, 0.5, horn)
            if (hurt) s.line(hx - 4, hy - 1.5, hx - 1, hy - 1.5, dark) else {
                s.eye(hx - 2.5, hy - 1.5, 1.5, eye(0xF0C020), pupil = false)
                s.line(hx - 2.5, hy - 2.5, hx - 2.5, hy - 0.5, dark)
            }
            s.dot(hx - 11, hy + 1, dark)
            // spear
            val deg = if (atk) 175.0 else if (hurt) -60.0 else -100.0 + c * 2
            val gx = if (atk) 16.0 else 21.0
            val gy = 43.0
            val a = Math.toRadians(deg)
            s.limb(gx - cos(a) * 12, gy - sin(a) * 12, gx + cos(a) * 14, gy + sin(a) * 14, 0.9, 0.9, wood)
            blade(gx + cos(a) * 14, gy + sin(a) * 14, deg, 6.0, 1.8, 0.0, rust)
            s.limb(28.0, 40.0, gx, gy, 1.8, 1.5, scales)
            s.blob(gx, gy, 1.9, 1.9, scales)
        }

        fun skeleton() {
            val bone = Mat(Ramp.of(argb(0xE6DCC4), if (shiny) 40.0 else 0.0, if (shiny) 2.5 else 1.0), grain = 0.05)
            val socket = argb(0x1A1420)
            val glow = eye(if (shiny) 0xF060F0 else 0x60D8FF)
            body(if (atk) -2.0 else if (hurt) 2.0 else 0.0, 0.0, stretch = 0.01)
            val shield = pick(3, 12) == 0
            // far leg & arm
            s.limb(35.0, 44.0, 36.0, 52.0, 1.6, 1.4, bone.far())
            s.limb(36.0, 52.0, 37.0, 59.0, 1.4, 1.2, bone.far())
            s.blob(36.0, 59.8, 3.0, 1.2, bone.far())
            s.limb(37.0, 29.0, 40.0, 37.0, 1.3, 1.1, bone.far())
            s.limb(40.0, 37.0, 38.0 + (if (shield) 2.0 else 0.0), 44.0, 1.1, 1.0, bone.far())
            // spine, ribs, pelvis
            s.blob(31.0, 33.0, 6.5, 6.0, Mat(Ramp.of(socket)).soft())
            s.chain(bone, 32.0, 44.0, 1.5, 32.0, 37.0, 1.6, 31.0, 29.0, 1.7)
            for (i in 0..3) {
                val y = 29.5 + i * 2.6 + b * 0.2
                val wdt = 6.5 - i * 0.6
                s.chain(bone, 31.0 + wdt, y - 0.5, 0.9, 31.0, y + 1.0, 1.0, 31.0 - wdt, y - 0.5, 0.9)
            }
            s.blob(32.0, 45.0, 5.5, 3.0, bone)
            if (pick(2, 13) == 0) s.poly(fixed(0x5A4A3A, grain = 0.2), 26.0, 44.0, 38.0, 44.0, 37.0, 50.0, 34.0, 48.0, 31.0, 51.0, 27.0, 49.0)
            s.limb(24.0, 28.0, 38.0, 28.0, 1.5, 1.5, bone)
            // near leg
            s.limb(29.0, 46.0, 27.0, 52.0, 1.7, 1.4, bone)
            s.limb(27.0, 52.0, 27.0, 59.0, 1.5, 1.2, bone)
            s.blob(25.5, 59.8, 3.2, 1.2, bone)
            if (shield) {
                s.blob(42.0, 40.0, 6.5, 7.5, rust, depth = 0.5)
                s.tint(42.0, 40.0, 6.5, 0.8, argb(0x6A2A2A), 0.6)
            }
            // skull
            val hx = 30.0 + if (atk) -1.0 else 0.0
            val hy = 18.0 + b * 0.4 + if (hurt) 1.0 else 0.0
            val tilt = if (hurt) 0.25 else c * 0.05
            s.blob(hx + 0.5, hy + 7.5, 4.8, 2.8, bone, rot = tilt)
            s.blob(hx, hy, 7.5, 7.8, bone, rot = tilt)
            s.flat(hx - 3.2, hy + 0.5, 2.3, 2.6, socket); s.flat(hx + 2.8, hy + 0.5, 2.3, 2.6, socket)
            if (!hurt) { s.dot(hx - 3.0, hy + 0.5, glow); s.dot(hx + 3.0, hy + 0.5, glow) }
            s.poly(Mat(Ramp.of(socket)).soft(), hx - 0.8, hy + 3.2, hx + 0.8, hy + 3.2, hx, hy + 5.0)
            for (i in 0..3) s.dot(hx - 2.5 + i * 1.6, hy + 6.8, socket)
            if (atk) s.flat(hx, hy + 9.5, 2.5, 0.9, socket)
            when (pick(3, 14)) {
                0 -> { s.blob(hx, hy - 4, 8.0, 4.5, rust); s.limb(hx, hy - 9, hx, hy - 3, 0.8, 0.8, rust) }
                1 -> if (!shiny) s.line(hx + 2.0, hy - 7, hx + 4.0, hy - 2, argb(0x6A5A4A))
                else -> {}
            }
            // sword arm
            val (hxp, hyp, deg) = when (pose) {
                Pose.ATTACK -> Triple(13.0, 36.0, 170.0)
                Pose.HURT -> Triple(21.0, 42.0, -60.0)
                Pose.IDLE -> Triple(19.0, 40.0 + b * 0.5, -120.0 + c * 3)
            }
            s.limb(24.0, 29.0, 21.0, 36.0, 1.3, 1.1, bone)
            s.limb(21.0, 36.0, hxp, hyp, 1.1, 1.0, bone)
            hilt(hxp, hyp, deg, rust)
            blade(hxp, hyp, deg, 14.0, 1.8, 0.0, if (pick(2, 15) == 0) rust else steel)
            s.blob(hxp, hyp, 1.6, 1.6, bone)
        }

        fun zombie() {
            val flesh = skin(listOf(0x8AA078, 0x9A9A80, 0x7A9890)[pick(3, 10)], grain = 0.08)
            val cloth = fixed(listOf(0x5A6A8A, 0x7A5A3A, 0x6A3A3A, 0x6A6A5A)[pick(4, 11)], grain = 0.12)
            val wound = argb(0x6A1A1A)
            val sway = if (pose == Pose.IDLE) b * 1.5 else 0.0
            body((if (atk) -4.0 else if (hurt) 3.0 else 0.0) + sway, 0.0, stretch = 0.01)
            s.limb(37.0, 45.0, 39.0, 58.0, 3.2, 2.8, cloth.far())
            s.blob(39.0, 59.5, 3.8, 2.0, fixed(0x3A3030).far())
            val reach = if (atk) -6.0 else 0.0
            s.limb(38.0, 28.0, 30.0 + reach, 34.0, 2.6, 2.2, flesh.far())
            s.limb(30.0 + reach, 34.0, 18.0 + reach, 33.0, 2.2, 2.0, flesh.far())
            // torn shirt
            s.blob(33.0, 37.0 + b * 0.3, 10.0, 11.0, cloth, rot = -0.2)
            s.poly(cloth, 24.0, 42.0, 42.0, 42.0, 41.0, 49.0, 37.0, 46.0, 33.0, 50.0, 29.0, 46.0, 25.0, 49.0)
            s.tint(36.0, 34.0, 3.0, 4.0, flesh.ramp.mid, 0.9)
            s.tint(36.0, 35.0, 1.0, 2.0, wound, 0.7)
            s.limb(29.0, 46.0, 27.0, 58.0, 3.3, 2.8, cloth)
            s.blob(26.0, 59.5, 4.0, 2.0, fixed(0x3A3030))
            // head, tilted
            val hx = 25.0 + (if (atk) -2.0 else 0.0)
            val hy = 21.0 + if (hurt) 2.0 else 0.0
            val tilt = if (hurt) 0.5 else 0.25 + c * 0.05
            s.blob(hx + 1, hy, 7.5, 8.0, flesh, rot = tilt)
            s.tint(hx + 3, hy - 5, 4.5, 2.0, argb(0x3A3028), 0.6)
            s.flat(hx - 2.5, hy - 0.5, 2.0, 2.0, dark)
            if (!hurt) s.dot(hx - 2.5, hy - 0.5, eye(0xE8F070))
            s.flat(hx + 3.0, hy + 0.5, 1.8, 1.6, argb(0xD8D8C8))
            if (atk) s.flat(hx - 0.5, hy + 5.5, 3.2, 2.2, mouth) else s.line(hx - 2.0, hy + 5.0, hx + 2.0, hy + 5.8, dark)
            s.tint(hx + 5.0, hy + 2.0, 1.2, 1.5, wound, 0.6)
            // near arm reaching out
            s.limb(28.0, 29.0, 20.0 + reach, 36.0, 2.8, 2.3, flesh)
            s.limb(20.0 + reach, 36.0, 9.0 + reach, 35.0, 2.3, 2.0, flesh)
            s.blob(8.0 + reach, 35.0, 2.6, 2.2, flesh)
            for (i in 0..2) s.limb(7.0 + reach, 34.0 + i * 1.2, 4.0 + reach, 35.5 + i * 1.6, 0.6, 0.5, flesh)
            s.tint(20.0 + reach, 36.0, 2.0, 2.0, wound, 0.4)
        }

        fun ghoul() {
            val flesh = skin(listOf(0x8A8A9A, 0x9A8A7A, 0x7A8A8A)[pick(3, 10)], grain = 0.08)
            val claw = fixed(0x2A2028, shine = 0.6)
            val rag = fixed(0x4A4038, grain = 0.2)
            body(if (atk) -5.0 else if (hurt) 3.0 else 0.0, 0.0, stretch = 0.02)
            // crouched far limbs
            s.limb(38.0, 46.0, 46.0, 52.0, 3.0, 2.4, flesh.far())
            s.limb(46.0, 52.0, 42.0, 59.0, 2.4, 1.8, flesh.far())
            val reach = if (atk) -7.0 else 0.0
            s.limb(36.0, 32.0, 30.0 + reach * 0.5, 44.0, 2.2, 1.8, flesh.far())
            s.limb(30.0 + reach * 0.5, 44.0, 22.0 + reach, 48.0, 1.8, 1.6, flesh.far())
            for (i in 0..2) s.limb(22.0 + reach, 48.0, 17.0 + reach + i, 50.0 + i * 1.5, 0.7, 0.4, claw.far())
            // hunched torso
            s.blob(34.0, 38.0 + b * 0.4, 11.0, 9.0, flesh, rot = -0.5)
            for (i in 0..2) s.line(29.0 + i * 3.0, 38.0 + i, 31.0 + i * 3.0, 44.0 + i, flesh.ramp.dark)
            s.poly(rag, 34.0, 44.0, 46.0, 42.0, 46.0, 50.0, 42.0, 48.0, 38.0, 51.0, 35.0, 48.0)
            s.limb(36.0, 46.0, 30.0, 53.0, 3.2, 2.5, flesh)
            s.limb(30.0, 53.0, 33.0, 59.0, 2.4, 1.8, flesh)
            s.blob(32.0, 59.8, 3.4, 1.3, flesh)
            // head, low and forward
            val hx = 22.0 + (if (atk) -3.0 else 0.0)
            val hy = 31.0 + (if (hurt) -3.0 else 0.0) + b * 0.6
            s.poly(flesh.far(), hx + 4, hy - 4, hx + 12, hy - 9, hx + 7, hy)
            s.blob(hx, hy, 7.0, 6.0, flesh)
            s.poly(flesh, hx - 4, hy - 3, hx - 13, hy - 8, hx - 5, hy + 2, tiltX = -0.3)
            s.flat(hx - 3.0, hy - 1.0, 2.2, 1.8, dark); s.flat(hx + 2.0, hy - 1.0, 2.0, 1.8, dark)
            if (!hurt) { s.flat(hx - 3.0, hy - 1.0, 1.0, 1.0, eye(0xF0E040)); s.flat(hx + 2.0, hy - 1.0, 0.9, 0.9, eye(0xF0E040)) }
            val open = if (atk) 3.0 else 1.2
            s.flat(hx - 1, hy + 3.5, 4.0, open, mouth)
            for (i in 0..4) { s.dot(hx - 4.5 + i * 1.8, hy + 3.5 - open + 0.5, Pal.WHITE); s.dot(hx - 4.0 + i * 1.8, hy + 3.5 + open - 1, Pal.WHITE) }
            if (atk) s.limb(hx - 2, hy + 5, hx - 6, hy + 10, 1.2, 0.8, skin(0xC05060))
            // near arm with long claws
            s.limb(30.0, 33.0, 22.0 + reach * 0.5, 42.0, 2.4, 2.0, flesh)
            s.limb(22.0 + reach * 0.5, 42.0, 13.0 + reach, 46.0, 2.0, 1.7, flesh)
            for (i in 0..2) s.limb(13.0 + reach, 46.0, 7.0 + reach + i, 49.0 + i * 2, 0.8, 0.4, claw)
        }

        // ============================================================ bosses

        fun bugbear() {
            val fur = fixed(0x8A5A30, grain = 0.2)
            val face = fixed(0xC08850, grain = 0.05)
            val strap = leather
            body(if (atk) -3.0 else if (hurt) 3.0 else 0.0, 0.0, stretch = 0.012)
            s.limb(40.0, 46.0, 42.0, 58.0, 4.5, 3.6, fur.far())
            s.blob(42.0, 59.5, 5.0, 2.2, fixed(0x3A2A20).far())
            s.limb(46.0, 24.0, 52.0, 36.0, 4.4, 3.6, fur.far())
            s.limb(52.0, 36.0, 50.0, 46.0, 3.6, 3.2, fur.far())
            s.blob(50.0, 47.0, 3.6, 3.4, face.far())
            s.blob(34.0, 34.0 + b * 0.4, 15.0, 15.0, fur)
            s.blob(33.0, 39.0, 9.0, 8.0, fixed(0xA87848, grain = 0.15).soft())
            s.limb(22.0, 24.0, 44.0, 44.0, 1.6, 1.6, strap)
            s.limb(20.0, 44.0, 48.0, 44.0, 2.2, 2.2, strap)
            s.blob(34.0, 44.0, 2.4, 2.2, fixed(0xC8A040, shine = 0.8))
            s.limb(28.0, 46.0, 25.0, 58.0, 4.8, 3.8, fur)
            s.blob(23.0, 59.5, 5.5, 2.3, fixed(0x3A2A20))
            // spiked pauldron
            s.blob(42.0, 22.0, 7.0, 5.0, rust)
            for (i in 0..2) s.poly(steel, 38.0 + i * 4, 18.0, 40.0 + i * 4, 11.0, 42.0 + i * 4, 18.0, bevel = 0.8)
            // head
            val hx = 28.0 + (if (atk) -2.0 else 0.0)
            val hy = 13.0 + b * 0.5 + if (hurt) 2.0 else 0.0
            s.poly(fur.far(), hx + 6, hy - 3, hx + 13, hy - 9, hx + 8, hy + 1)
            s.blob(hx, hy, 9.0, 8.0, fur)
            s.poly(fur, hx - 6, hy - 3, hx - 13, hy - 9, hx - 7, hy + 1, tiltX = -0.3)
            s.blob(hx - 4, hy + 3.5, 5.5, 4.0, face)
            s.blob(hx - 8, hy + 2.5, 1.7, 1.4, fixed(0x202020, shine = 1.0))
            if (hurt) {
                s.line(hx - 6, hy - 2, hx - 3, hy - 1, dark); s.line(hx, hy - 1, hx + 3, hy - 2, dark)
            } else {
                s.eye(hx - 4.5, hy - 1.5, 1.6, eye(0xF0B020)); s.eye(hx + 1.5, hy - 1.5, 1.6, eye(0xF0B020))
                s.line(hx - 7, hy - 4, hx - 2, hy - 2.5, dark); s.line(hx, hy - 2.5, hx + 4, hy - 4, dark)
            }
            if (atk) s.flat(hx - 4, hy + 6, 3.0, 1.6, mouth)
            s.limb(hx - 6, hy + 6, hx - 7, hy + 3.5, 0.9, 0.5, bone)
            s.limb(hx - 1, hy + 6, hx - 1, hy + 3.5, 0.9, 0.5, bone)
            // morningstar
            val (gx, gy, deg) = when (pose) {
                Pose.ATTACK -> Triple(10.0, 30.0, 200.0)
                Pose.HURT -> Triple(18.0, 40.0, -60.0)
                Pose.IDLE -> Triple(15.0, 38.0 + b * 0.6, -105.0 + c * 3)
            }
            val a = Math.toRadians(deg)
            val ex = gx + cos(a) * 15; val ey = gy + sin(a) * 15
            s.limb(gx - cos(a) * 4, gy - sin(a) * 4, ex, ey, 1.5, 1.6, wood)
            for (k in 0 until 8) {
                val sa = k * 45.0
                s.poly(steel, ex + cos(Math.toRadians(sa - 18)) * 4, ey + sin(Math.toRadians(sa - 18)) * 4,
                    Sculpt.polarX(ex, 8.0, sa), Sculpt.polarY(ey, 8.0, sa),
                    ex + cos(Math.toRadians(sa + 18)) * 4, ey + sin(Math.toRadians(sa + 18)) * 4, bevel = 0.6)
            }
            s.blob(ex, ey, 5.0, 5.0, fixed(0x6A6A78, shine = 0.7))
            s.limb(24.0, 22.0, 18.0, 32.0, 4.6, 3.8, fur)
            s.limb(18.0, 32.0, gx, gy, 3.8, 3.2, fur)
            s.blob(gx, gy, 3.6, 3.4, face)
        }

        fun hobgoblin() {
            val hskin = fixed(0xC8603A, grain = 0.04)
            val plate = fixed(0x6A7484, shine = 0.7)
            val gold = fixed(0xD8A830, shine = 0.8)
            val cape = fixed(0x9A2028, grain = 0.04)
            body(if (atk) -3.0 else if (hurt) 3.0 else 0.0, 0.0, stretch = 0.012)
            val wave = c * 1.5
            s.poly(cape, 26.0, 20.0, 46.0, 20.0, 56.0 + wave, 58.0, 46.0, 56.0 - wave, 36.0, 59.0, 30.0, 54.0)
            s.limb(38.0, 46.0, 40.0, 58.0, 4.2, 3.4, plate.far())
            s.blob(40.0, 59.5, 4.8, 2.2, fixed(0x2A2A30).far())
            s.limb(44.0, 24.0, 48.0, 36.0, 3.6, 3.0, plate.far())
            s.limb(48.0, 36.0, 46.0, 44.0, 3.0, 2.8, hskin.far())
            // armored torso
            s.blob(34.0, 34.0 + b * 0.4, 12.5, 13.0, plate)
            s.poly(gold, 26.0, 26.0, 42.0, 26.0, 34.0, 36.0, bevel = 1.0)
            s.poly(plate, 27.0, 27.5, 41.0, 27.5, 34.0, 34.5, bevel = 1.2)
            s.limb(22.0, 44.0, 46.0, 44.0, 2.2, 2.2, leather)
            s.blob(34.0, 44.0, 2.6, 2.4, gold)
            s.poly(plate, 22.0, 45.0, 46.0, 45.0, 48.0, 52.0, 20.0, 52.0, tiltY = -0.2)
            s.limb(28.0, 50.0, 25.0, 58.0, 4.4, 3.6, plate)
            s.blob(23.0, 59.5, 5.0, 2.3, fixed(0x2A2A30))
            s.blob(43.0, 23.0, 7.0, 5.0, plate)
            s.blob(43.0, 23.0, 7.0, 1.0, gold.soft())
            // head with crested helm
            val hx = 29.0 + (if (atk) -2.0 else 0.0)
            val hy = 13.5 + b * 0.5 + if (hurt) 2.0 else 0.0
            s.blob(hx, hy + 1, 7.5, 7.5, hskin)
            s.poly(hskin, hx - 5, hy - 1, hx - 12, hy - 5, hx - 6, hy + 3)
            s.blob(hx, hy - 3, 8.5, 6.0, plate)
            s.limb(hx - 8, hy, hx + 8, hy, 1.2, 1.2, gold)
            for (i in 0..5) s.limb(hx - 4 + i * 2.0, hy - 8 - (if (i in 1..4) 2.0 else 0.0), hx - 1 + i * 2.2, hy - 15 + c * 0.5 - (if (i in 1..4) 2.0 else 0.0), 1.4, 0.8, cape)
            if (hurt) s.line(hx - 6, hy + 2, hx - 2, hy + 2.5, dark) else {
                s.eye(hx - 4.5, hy + 2.0, 1.5, eye(0xF0E040), pupil = false); s.eye(hx + 1.0, hy + 2.0, 1.5, eye(0xF0E040), pupil = false)
            }
            s.line(hx - 6, hy + 7, hx, hy + 7.5, dark)
            if (atk) s.flat(hx - 3, hy + 7.5, 2.6, 1.2, mouth)
            // war axe
            val (gx, gy, deg) = when (pose) {
                Pose.ATTACK -> Triple(9.0, 32.0, 195.0)
                Pose.HURT -> Triple(18.0, 40.0, -55.0)
                Pose.IDLE -> Triple(15.0, 40.0 + b * 0.6, -100.0 + c * 3)
            }
            val a = Math.toRadians(deg)
            val ex = gx + cos(a) * 16; val ey = gy + sin(a) * 16
            s.limb(gx - cos(a) * 8, gy - sin(a) * 8, ex + cos(a) * 3, ey + sin(a) * 3, 1.4, 1.4, wood)
            val px = -sin(a); val py = cos(a)
            // crescent blade on one side
            s.poly(steel,
                ex - cos(a) * 3, ey - sin(a) * 3,
                ex + px * 4 - cos(a) * 6, ey + py * 4 - sin(a) * 6,
                ex + px * 9 - cos(a) * 5, ey + py * 9 - sin(a) * 5,
                ex + px * 10, ey + py * 10,
                ex + px * 9 + cos(a) * 5, ey + py * 9 + sin(a) * 5,
                ex + px * 4 + cos(a) * 5, ey + py * 4 + sin(a) * 5,
                ex + cos(a) * 3, ey + sin(a) * 3, bevel = 1.6)
            s.blob(ex, ey, 2.0, 2.0, gold)
            s.limb(24.0, 22.0, 19.0, 32.0, 3.8, 3.2, plate)
            s.limb(19.0, 32.0, gx, gy, 3.0, 2.6, hskin)
            s.blob(gx, gy, 3.0, 3.0, fixed(0x4A3A30))
        }
    }
}
