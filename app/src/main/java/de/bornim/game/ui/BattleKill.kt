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
val KILL_STOP_MS: Long get() = BattlePace.ms(260L)

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
