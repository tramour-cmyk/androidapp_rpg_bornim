package de.bornim.game.ui

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.FilterQuality
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.withTransform
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntSize
import de.bornim.core.Anim
import de.bornim.core.FxKind
import de.bornim.core.Step
import de.bornim.core.art.KillArt
import de.bornim.core.art.KillPlan
import kotlin.math.cos
import kotlin.math.roundToInt
import kotlin.math.sin
import kotlin.random.Random

/** A critical blow with a weapon in hand that ends the foe: the killing blow. */
fun Step.isKillBlow(): Boolean {
    val f = fx ?: return false
    return (anim == Anim.ENEMY_HIT || anim == Anim.ENEMY_FAINT) && !f.onHero && f.crit && enemyHp <= 0 &&
        (f.kind == FxKind.SLASH || f.kind == FxKind.PIERCE || f.kind == FxKind.SMASH)
}

/** How long a killing blow halts as it lands. */
val KILL_STOP_MS: Long get() = BattlePace.ms(380L)
/** How long the hero holds the killing blow wound up at its height before it comes down (at normal pace). */
const val KILL_HOLD_MS = 330L
/** Each frame of the killing blow coming down: faster than a plain blow (at normal pace). */
const val KILL_FRAME_MS = 52L
/** How much slower than its blow the hero comes back out of a killing blow. */
const val KILL_SLOW = 3.2

/** The slow motion of what the killing blow does: half speed for the first [ms] after it lands, then as fast as ever. */
fun killTime(real: Float, ms: Float = 700f): Float = if (real < ms) real * 0.5f else ms * 0.5f + (real - ms)

/**
 * The way the weapon's point goes from frame [from] to [to] of a killing blow (fractional), in art pixels: between frames
 * it swings round the hand, so the trail bends with the blow instead of cutting straight across.
 */
fun killTrailPoints(hero: de.bornim.core.Hero, strike: de.bornim.core.art.HeroFigure.Strike, from: Int, to: Double): List<Offset> {
    val pts = ArrayList<Offset>()
    var f = from.toDouble()
    while (f <= to + 1e-6) {
        val i = kotlin.math.floor(f).toInt(); val k = f - i
        val h0 = de.bornim.core.art.HeroBattle.gripAt(hero, strike, i); val h1 = de.bornim.core.art.HeroBattle.gripAt(hero, strike, i + 1)
        val t0 = de.bornim.core.art.HeroBattle.tipAt(hero, strike, i); val t1 = de.bornim.core.art.HeroBattle.tipAt(hero, strike, i + 1)
        val a0 = kotlin.math.atan2(t0.second - h0.second, t0.first - h0.first)
        var a1 = kotlin.math.atan2(t1.second - h1.second, t1.first - h1.first)
        while (a1 - a0 > Math.PI) a1 -= 2 * Math.PI
        while (a1 - a0 < -Math.PI) a1 += 2 * Math.PI
        val r0 = kotlin.math.hypot(t0.first - h0.first, t0.second - h0.second); val r1 = kotlin.math.hypot(t1.first - h1.first, t1.second - h1.second)
        val hx = h0.first + (h1.first - h0.first) * k; val hy = h0.second + (h1.second - h0.second) * k
        val a = a0 + (a1 - a0) * k; val r = r0 + (r1 - r0) * k
        pts += Offset((hx + r * cos(a)).toFloat(), (hy + r * sin(a)).toFloat())
        f += 0.2
    }
    return pts
}

/** The trail of a killing blow, dark blood red, along [points] of the weapon's point, fading by [fade]: drawn in the hero's own frame at [u] px per art pixel. */
fun DrawScope.drawKillTrail(points: List<Offset>, u: Float, fade: Float) {
    if (points.size < 2 || fade <= 0f) return
    for (i in 1 until points.size) {
        val k = i / (points.size - 1f)
        val a = points[i - 1] * u; val b = points[i] * u
        drawLine(Color(0xFF3A0408).copy(alpha = 0.55f * fade * k), a, b, (1.5f + 4f * k) * u, androidx.compose.ui.graphics.StrokeCap.Round)
        drawLine(Color(0xFF9A141C).copy(alpha = 0.8f * fade * k), a, b, (0.8f + 2f * k) * u, androidx.compose.ui.graphics.StrokeCap.Round)
    }
}

/**
 * The pieces of a foe struck dead by a killing blow, [t] ms after it landed, in the foe's own frame: each at [u] px per
 * art pixel, in the light of the place ([shade]).
 */
fun DrawScope.drawKillPieces(plan: KillPlan, t: Float, u: Float, shade: Color?) {
    val filter = shade?.let { ColorFilter.tint(it, BlendMode.Modulate) }
    for (p in plan.pieces) {
        val pose = KillArt.pose(p, t.toDouble(), plan.ground)
        val pivot = if (p.topple) Offset((p.px * u).toFloat(), (p.py * u).toFloat()) else Offset(((p.cx + pose.dx) * u).toFloat(), ((p.cy + pose.dy) * u).toFloat())
        withTransform({
            translate((pose.dx * u).toFloat(), (pose.dy * u).toFloat())
            rotate(pose.angle.toFloat(), pivot - Offset((pose.dx * u).toFloat(), (pose.dy * u).toFloat()))
        }) {
            drawImage(Bitmaps.of(p.img), IntOffset.Zero, IntSize(p.img.width, p.img.height), IntOffset((p.ox * u).roundToInt(), (p.oy * u).roundToInt()),
                IntSize((p.img.width * u).roundToInt(), (p.img.height * u).roundToInt()), colorFilter = filter, filterQuality = FilterQuality.None)
        }
    }
}

/**
 * What runs out of a foe struck dead: a gush from where the blow struck, landing in splats, and a pool spreading under it
 * that stays; bones only drop dust. [level] is the blood level (1 subtle, 2 full); with the blood off nothing runs.
 * [behind] draws the pool (under the pieces), else the spray (over them).
 */
fun DrawScope.drawKillGore(plan: KillPlan, t: Float, u: Float, level: Int, gore: Gore, anchorX: Float, seed: Int, behind: Boolean) {
    if (level <= 0 && plan.kind != KillArt.Kind.SHATTER) return
    val g = plan.ground.toFloat()
    val bones = gore == Gore.BONE
    if (behind) {
        if (bones || level <= 0) return
        // the pool: spreading for a second and a half, then lying there
        val k = (t / 1500f).coerceIn(0f, 1f).let { 1 - (1 - it) * (1 - it) }
        val w = (if (level >= 2) 66f else 48f) * k
        if (w > 1f) {
            drawOval(gore.main.copy(alpha = 0.9f), Offset((anchorX + 6 - w / 2) * u, (g - w * 0.11f) * u), Size(w * u, w * 0.22f * u))
            drawOval(gore.light.copy(alpha = 0.35f), Offset((anchorX + 2 - w * 0.3f) * u, (g - w * 0.07f) * u), Size(w * 0.45f * u, w * 0.08f * u))
        }
        return
    }
    val r = Random(seed)
    val n = when { bones -> 26; level >= 2 -> 70; else -> 34 }
    for (i in 0 until n) {
        val delay = r.nextFloat() * (if (bones) 120f else 380f)
        val a = Math.toRadians((if (bones) -90.0 else -30.0) + (r.nextDouble() - 0.5) * (if (bones) 160.0 else 110.0))
        val speed = (if (bones) 0.03f else 0.035f) + r.nextFloat() * 0.055f
        val size = if (bones) 0.8f + r.nextFloat() * 1.2f else 1.2f + r.nextFloat() * (if (level >= 2) 2.4f else 1.6f)
        val tt = t - delay
        if (tt <= 0f) continue
        var x = plan.cx.toFloat() + (cos(a) * speed * tt).toFloat()
        var y = plan.cy.toFloat() + (sin(a) * speed * tt).toFloat() + 0.00045f * tt * tt
        val landed = y >= g
        if (landed) y = g - r.nextFloat() * 2f
        val fade = if (bones) (1f - (tt - 500f) / 700f).coerceIn(0f, 1f) else if (landed) (1f - (tt - 1600f) / 900f).coerceIn(0f, 1f) else 1f
        if (fade <= 0f) continue
        val c = if (bones) Color(0xFFD8CFBC) else if (r.nextInt(3) == 0) gore.light else gore.main
        if (landed && !bones) drawOval(c.copy(alpha = 0.85f * fade), Offset((x - size * 1.5f) * u, (y - size * 0.35f) * u), Size(size * 3f * u, size * 0.8f * u))
        else drawCircle(c.copy(alpha = fade), size * 0.55f * u, Offset(x * u, y * u))
    }
}
