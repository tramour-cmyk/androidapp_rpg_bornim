package de.bornim.core.art

import de.bornim.core.Rarity
import kotlin.math.cos
import kotlin.math.sin

/**
 * The weapons the hero carries in battle, each drawn after the real thing: swords with fuller,
 * crossguard, wrapped grip and pommel; a curved scimitar; a rapier with a swept hilt; bearded axes
 * and a double-bitted great axe; a flanged mace; a war hammer with its back spike; a banded maul;
 * a leaf-bladed spear; a halberd with blade, spike and hook; an iron-shod quarterstaff; an arcane
 * staff holding a crystal; bows and a crossbow. Steel always stays steel; rarity shows as a gem in
 * the pommel, a coloured fuller or glowing runes.
 *
 * Every weapon is laid out along its own axis: u runs from the hand towards the tip, v across.
 */
class WeaponArt(private val s: Sculpt) {
    private fun m(rgb: Int, shine: Double = 0.0, grain: Double = 0.0) = Mat(Ramp.of(rgb), shine, grain)

    private val steelBlade = m(argb(0x98A0AA), shine = 0.95)
    private val steelDark = m(argb(0x5E6670), shine = 0.7)
    private val edge = argb(0xE6EEF6)
    private val spine = argb(0x464E58)
    private val leather = m(argb(0x3A2A20), grain = 0.05)
    private val wrap = argb(0x22180F)
    private val ash = m(argb(0x7A5634), grain = 0.14)
    private val darkWood = m(argb(0x4E3622), grain = 0.12)
    private val brass = m(argb(0xB08A44), shine = 0.75)

    private var hx = 0.0; private var hy = 0.0; private var dx = 1.0; private var dy = 0.0

    /** How much the weapon is shortened by pointing towards or away from us (1 = flat in the picture). */
    private var fs = 1.0

    private fun x(u: Double, v: Double) = hx + dx * u * fs - dy * v
    private fun y(u: Double, v: Double) = hy + dy * u * fs + dx * v

    private fun poly(mat: Mat, vararg uv: Double, tiltX: Double = 0.0, tiltY: Double = 0.0, bevel: Double = 1.2) {
        val pts = DoubleArray(uv.size)
        for (i in uv.indices step 2) { pts[i] = x(uv[i], uv[i + 1]); pts[i + 1] = y(uv[i], uv[i + 1]) }
        s.poly(mat, *pts, tiltX = tiltX, tiltY = tiltY, bevel = bevel)
    }

    private fun line(u0: Double, v0: Double, u1: Double, v1: Double, c: Int) = s.line(x(u0, v0), y(u0, v0), x(u1, v1), y(u1, v1), c)
    private fun limb(u0: Double, v0: Double, u1: Double, v1: Double, r0: Double, r1: Double, mat: Mat) = s.limb(x(u0, v0), y(u0, v0), x(u1, v1), y(u1, v1), r0, r1, mat)
    private fun blob(u: Double, v: Double, rx: Double, ry: Double, mat: Mat) = s.blob(x(u, v), y(u, v), rx, ry, mat)
    private fun dot(u: Double, v: Double, c: Int) = s.dot(x(u, v), y(u, v), c)

    /** The colour of rarity on a weapon, or null for plain pieces. */
    private fun mark(r: Rarity): Int? = if (r >= Rarity.RARE) r.color.toInt() else null

    // ---------------------------------------------------------------- parts

    /** A leather-wrapped grip from -[len] to 0 with a pommel behind it. */
    private fun grip(len: Double, r: Rarity, round: Boolean = true) {
        limb(-len, 0.0, 1.5, 0.0, 1.5, 1.5, leather)
        var u = -len + 1.5
        while (u < 1.0) { line(u, -1.5, u + 1.0, 1.5, wrap); u += 2.2 }
        if (round) blob(-len - 1.8, 0.0, 2.2, 2.2, brass) else poly(brass, -len - 0.5, -2.0, -len - 3.5, -1.2, -len - 4.2, 0.0, -len - 3.5, 1.2, -len - 0.5, 2.0)
        mark(r)?.let { dot(-len - 1.8, 0.0, it); dot(-len - 1.4, -0.6, mix(it, argb(0xFFFFFF), 0.5)) }
    }

    /** A straight crossguard [w] to each side, with small bulbs at the tips. */
    private fun guard(w: Double) {
        limb(2.2, -w, 2.2, w, 1.2, 1.2, steelDark)
        blob(2.2, -w, 1.4, 1.4, steelDark); blob(2.2, w, 1.4, 1.4, steelDark)
    }

    /** A straight double-edged blade from u=[from], [len] long and [hw] half wide, with a fuller. */
    private fun blade(from: Double, len: Double, hw: Double, r: Rarity, taper: Double = 0.8) {
        val tip = from + len
        poly(steelBlade, from, -hw, from + len * 0.82, -hw * taper, tip, 0.0, from + len * 0.82, hw * taper, from, hw, tiltX = 0.2, tiltY = -0.3, bevel = 0.8)
        // the lit edge on top, the shaded one below, the fuller down the middle
        line(from + 0.5, -hw + 0.4, from + len * 0.82, -hw * taper + 0.3, edge)
        line(from + 0.5, hw - 0.4, from + len * 0.82, hw * taper - 0.3, spine)
        line(from + 1.5, 0.0, from + len * 0.62, 0.0, mark(r) ?: spine)
        if (r >= Rarity.EPIC) for (k in 1..3) dot(from + len * 0.15 * k, 0.0, mix(r.color.toInt(), argb(0xFFFFFF), 0.5))
    }

    /** A wooden haft from -[back] to [front], with a leather grip near the hand. */
    private fun haft(back: Double, front: Double, rr: Double = 1.6, wood: Mat = ash) {
        limb(-back, 0.0, front, 0.0, rr, rr * 0.9, wood)
        limb(-3.0, 0.0, 3.0, 0.0, rr + 0.3, rr + 0.3, leather)
    }

    // ---------------------------------------------------------------- weapons

    /**
     * Draws [base] held in a hand at ([handX], [handY]) pointing at [deg] degrees (0 right, -90 up).
     * [glow] brightens a staff's crystal or a wand's gem while casting.
     */
    fun draw(base: String, r: Rarity, handX: Double, handY: Double, deg: Double, glow: Double = 0.0, foreshorten: Double = 1.0) {
        hx = handX; hy = handY; fs = foreshorten
        val a = Math.toRadians(deg)
        dx = cos(a); dy = sin(a)
        when (base) {
            "dagger" -> { grip(5.5, r); guard(3.2); blade(3.2, 14.0, 2.0, r, 0.7) }
            "shortsword" -> { grip(6.5, r); guard(4.5); blade(3.2, 21.0, 2.5, r) }
            "longsword" -> { grip(10.0, r, round = false); guard(7.0); blade(3.2, 33.0, 2.8, r) }
            "greatsword" -> {
                grip(15.0, r, round = false); guard(9.5)
                // the ricasso, an unsharpened stretch to grip for close work, then the long blade
                limb(3.0, 0.0, 8.0, 0.0, 2.2, 2.2, steelDark)
                limb(8.0, -3.6, 8.0, 3.6, 0.9, 0.9, steelDark)
                blade(8.0, 40.0, 3.6, r)
            }
            "scimitar" -> {
                grip(6.5, r); guard(3.6)
                // a single-edged blade curving back, widening towards the tip
                val pts = mutableListOf<Double>()
                val n = 8; val len = 25.0
                fun back(t: Double) = -1.5 - t * t * 4.5
                fun cut(t: Double) = 2.2 + t * 1.2 - t * t * 4.6
                for (i in 0..n) { val t = i / n.toDouble(); pts += 3.2 + t * len; pts += back(t) }
                pts += 3.2 + len + 3.5; pts += back(1.0) + 0.5
                for (i in n downTo 0) { val t = i / n.toDouble(); pts += 3.2 + t * len; pts += cut(t) }
                poly(steelBlade, *pts.toDoubleArray(), tiltX = 0.2, tiltY = -0.3, bevel = 0.8)
                for (i in 0 until n) { val t0 = i / n.toDouble(); val t1 = (i + 1) / n.toDouble(); line(3.2 + t0 * len, cut(t0) - 0.4, 3.2 + t1 * len, cut(t1) - 0.4, edge) }
                mark(r)?.let { line(5.0, -0.5, 18.0, -1.8, it) }
            }
            "rapier" -> {
                grip(7.0, r)
                // the swept hilt: a guard bar, a knuckle bow and a ring around the blade
                guard(5.0)
                limb(2.0, 4.5, -5.0, 4.0, 0.7, 0.7, steelDark); limb(-5.0, 4.0, -7.5, 1.0, 0.7, 0.7, steelDark)
                limb(3.0, -2.6, 6.0, -2.6, 0.6, 0.6, steelDark); limb(6.0, -2.6, 6.0, 2.6, 0.6, 0.6, steelDark)
                poly(steelBlade, 3.0, -1.2, 36.0, -0.5, 38.0, 0.0, 36.0, 0.5, 3.0, 1.2, bevel = 0.4)
                line(3.5, -0.8, 35.5, -0.3, edge)
                mark(r)?.let { line(5.0, 0.0, 20.0, 0.0, it) }
            }
            "handaxe" -> { haft(5.0, 19.0); axeHead(17.0, 1.0, r, beard = true) }
            "battleaxe" -> { haft(8.0, 27.0); axeHead(25.0, 1.3, r, beard = true); limb(23.0, -1.5, 23.0, -5.5, 1.2, 0.4, steelDark) }
            "greataxe" -> {
                haft(14.0, 36.0, 1.8)
                // langets: iron strips that hold the head and protect the haft
                limb(27.0, -1.9, 36.0, -1.9, 0.6, 0.6, steelDark); limb(27.0, 1.9, 36.0, 1.9, 0.6, 0.6, steelDark)
                axeHead(34.0, 1.6, r, beard = false)
                axeHead(34.0, 1.3, r, beard = false, mirror = true)
                blob(37.5, 0.0, 1.6, 1.6, steelDark)
            }
            "mace" -> {
                haft(5.0, 17.0, 1.5, darkWood)
                limb(13.0, 0.0, 19.0, 0.0, 2.4, 2.4, steelDark)
                // flanged head: steel plates standing out around the core
                blob(23.0, 0.0, 4.2, 4.2, steelDark)
                for (k in -2..2) {
                    val v = k * 2.4
                    poly(steelBlade, 18.0, v * 0.6, 21.0, v * 1.3 + (if (k == 0) 0.0 else Math.signum(v) * 3.0), 26.0, v * 1.3 + (if (k == 0) 0.0 else Math.signum(v) * 3.0), 29.0, v * 0.6, bevel = 0.9)
                }
                line(21.0, -7.6, 26.0, -7.6, edge)
                blob(29.5, 0.0, 1.6, 1.6, steelDark)
                mark(r)?.let { dot(21.0, 0.0, it) }
            }
            "warhammer" -> {
                haft(7.0, 25.0, 1.6, darkWood)
                limb(18.0, -1.7, 25.0, -1.7, 0.5, 0.5, steelDark); limb(18.0, 1.7, 25.0, 1.7, 0.5, 0.5, steelDark)
                // a square striking face on one side, the curved spike on the other, a point on top
                poly(steelBlade, 22.0, -2.5, 28.0, -2.5, 28.0, -9.5, 22.0, -9.5, tiltX = -0.3, bevel = 1.4)
                line(22.5, -9.4, 27.5, -9.4, edge)
                poly(steelBlade, 22.0, 2.0, 28.0, 2.0, 27.0, 8.0, 23.5, 13.0, 24.0, 7.0, bevel = 0.8)
                poly(steelBlade, 24.0, -1.5, 31.0, 0.0, 24.0, 1.5, bevel = 0.6)
                mark(r)?.let { dot(25.0, 0.0, it) }
            }
            "maul" -> {
                haft(14.0, 34.0, 1.9, darkWood)
                // a heavy block head bound with iron bands and studs
                poly(steelDark, 30.0, -9.0, 41.0, -9.0, 41.0, 9.0, 30.0, 9.0, tiltX = -0.2, tiltY = -0.2, bevel = 2.0)
                for (v in listOf(-6.0, 0.0, 6.0)) limb(30.5, v, 40.5, v, 0.6, 0.6, steelBlade)
                for (u in listOf(32.0, 39.0)) for (v in listOf(-8.0, 8.0)) dot(u, v, edge)
                line(30.5, -8.6, 40.5, -8.6, edge)
                mark(r)?.let { dot(35.5, 0.0, it) }
            }
            "spear" -> {
                haft(16.0, 38.0, 1.4)
                limb(-16.0, 0.0, -18.5, 0.0, 1.5, 1.2, steelDark)
                limb(36.0, 0.0, 39.5, 0.0, 1.9, 1.6, steelDark)
                // a leaf-shaped head with a midrib
                poly(steelBlade, 39.0, -1.4, 43.0, -3.0, 49.0, -1.6, 52.0, 0.0, 49.0, 1.6, 43.0, 3.0, 39.0, 1.4, bevel = 0.8)
                line(39.5, 0.0, 50.5, 0.0, spine); line(40.0, -1.6, 49.0, -1.4, edge)
            }
            "halberd" -> {
                haft(20.0, 42.0, 1.5)
                limb(34.0, -1.6, 42.0, -1.6, 0.5, 0.5, steelDark); limb(34.0, 1.6, 42.0, 1.6, 0.5, 0.5, steelDark)
                // axe blade with a curved edge, the spike on top, the hook behind
                poly(steelBlade, 37.0, -1.8, 45.0, -1.8, 47.0, -7.0, 45.0, -12.0, 39.0, -11.0, 35.5, -6.0, bevel = 1.0)
                line(45.2, -2.0, 46.8, -7.0, edge); line(46.8, -7.0, 45.0, -11.8, edge)
                poly(steelBlade, 44.0, -1.4, 55.0, 0.0, 44.0, 1.4, bevel = 0.6)
                poly(steelBlade, 39.0, 1.8, 43.0, 1.8, 40.0, 8.0, 38.5, 5.0, bevel = 0.6)
                mark(r)?.let { dot(41.0, -6.0, it) }
            }
            "quarterstaff" -> {
                limb(-20.0, 0.0, 22.0, 0.0, 1.7, 1.7, ash)
                limb(-20.0, 0.0, -17.0, 0.0, 1.9, 1.9, steelDark); limb(19.0, 0.0, 22.0, 0.0, 1.9, 1.9, steelDark)
                limb(-3.0, 0.0, 3.0, 0.0, 2.0, 2.0, leather)
            }
            "staff" -> {
                // a gnarled staff; carved claws hold a crystal that glows when spells are cast
                s.chain(darkWood, x(-22.0, 0.0), y(-22.0, 0.0), 1.8, x(0.0, 0.5), y(0.0, 0.5), 1.9, x(20.0, -0.8), y(20.0, -0.8), 1.9, x(36.0, 0.4), y(36.0, 0.4), 2.2)
                blob(12.0, -0.6, 2.4, 2.2, darkWood)
                for (k in -1..1 step 2) limb(36.0, k * 1.5, 41.5, k * 3.5, 1.0, 0.5, darkWood)
                val g = mix(argb(0x80D8FF), r.color.toInt(), 0.45)
                val rr = 2.8 + glow * 1.6
                s.flat(x(41.0, 0.0), y(41.0, 0.0), rr + 2.5 + glow * 3, rr + 2.5 + glow * 3, alpha(g, (70 + glow * 110).toInt()))
                poly(m(g, shine = 1.0).copy(inline = false), 38.0, 0.0, 41.0, -rr, 45.0, 0.0, 41.0, rr, bevel = 0.8)
            }
            "wand" -> {
                limb(-3.0, 0.0, 14.0, 0.0, 1.2, 0.8, darkWood)
                for (u in listOf(2.0, 6.0, 10.0)) line(u, -1.0, u, 1.0, argb(0x2A1C12))
                limb(13.0, 0.0, 15.0, 0.0, 1.2, 1.2, brass)
                val g = mix(argb(0x90E0FF), r.color.toInt(), 0.5)
                s.flat(x(16.5, 0.0), y(16.5, 0.0), 2.5 + glow * 3, 2.5 + glow * 3, alpha(g, (70 + glow * 110).toInt()))
                blob(16.5, 0.0, 1.6 + glow, 1.6 + glow, m(g, shine = 1.0).copy(inline = false))
            }
            "light_crossbow" -> {
                // the wooden stock, the steel prod across it, the string and a bolt
                limb(-8.0, 0.0, 16.0, 0.0, 1.8, 1.6, ash)
                limb(-8.0, 0.0, -2.0, 0.0, 2.4, 2.0, ash)
                s.chain(steelDark, x(14.0, -10.0), y(14.0, -10.0), 0.8, x(15.5, -5.0), y(15.5, -5.0), 1.2, x(16.0, 0.0), y(16.0, 0.0), 1.4, x(15.5, 5.0), y(15.5, 5.0), 1.2, x(14.0, 10.0), y(14.0, 10.0), 0.8)
                line(14.0, -10.0, 8.0, 0.0, argb(0xD8D0C0)); line(8.0, 0.0, 14.0, 10.0, argb(0xD8D0C0))
                limb(8.0, 0.0, 19.0, 0.0, 0.5, 0.5, darkWood); poly(steelBlade, 19.0, -1.0, 21.5, 0.0, 19.0, 1.0, bevel = 0.4)
            }
            else -> haft(6.0, 18.0)
        }
    }

    /** An axe head at [at] along the haft: [beard] drops the edge below for a wider cut. */
    private fun axeHead(at: Double, size: Double, r: Rarity, beard: Boolean, mirror: Boolean = false) {
        val k = if (mirror) -1.0 else 1.0
        val w = size
        val pts = if (beard) doubleArrayOf(
            at - 2.5, 1.8 * k, at + 2.5, 1.8 * k, at + 3.5 * w, 6.0 * w * k, at + 4.0 * w, 11.0 * w * k, at - 5.0 * w, 13.0 * w * k, at - 3.5 * w, 8.0 * w * k, at - 2.5, 4.0 * k,
        ) else doubleArrayOf(
            at - 2.5, 1.8 * k, at + 2.5, 1.8 * k, at + 6.0 * w, 6.0 * w * k, at + 6.5 * w, 11.0 * w * k, at, 12.5 * w * k, at - 6.5 * w, 11.0 * w * k, at - 6.0 * w, 6.0 * w * k,
        )
        poly(m(argb(0x6E7680), shine = 0.8, grain = 0.06), *pts, tiltX = -0.3 * k, tiltY = -0.2, bevel = 2.0)
        // the ground edge: a bright band along the cut, the forge-dark cheek behind it
        val n = pts.size / 2
        for (i in 2 until n - 2) {
            val ax = pts[i * 2]; val av = pts[i * 2 + 1]; val bx = pts[i * 2 + 2]; val bv = pts[i * 2 + 3]
            line(ax, av, bx, bv, edge)
            line(ax + (at - ax) * 0.12, av * 0.88, bx + (at - bx) * 0.12, bv * 0.88, argb(0xB4BCC6))
        }
        blob(at, 0.0, 2.3, 2.3, steelDark)
        mark(r)?.let { dot(at, 5.0 * w * k, it) }
    }
}
