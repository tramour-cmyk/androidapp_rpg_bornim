package de.bornim.game.ui

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import de.bornim.core.Anim
import de.bornim.core.Fx
import de.bornim.core.FxKind
import de.bornim.core.Rarity
import de.bornim.core.Step
import de.bornim.core.audio.Sound
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin
import kotlin.random.Random

/** Effects that fly from the attacker to the target: when they miss, they are drawn going wide. */
val FLYING = setOf(
    FxKind.ARROW, FxKind.FIRE_BOLT, FxKind.MISSILES, FxKind.RAYS, FxKind.FIREBALL, FxKind.SACRED_FLAME,
    FxKind.SPIRIT_WEAPON, FxKind.BOMB_FIRE, FxKind.BOMB_HOLY, FxKind.GUARDIANS, FxKind.TURN, FxKind.DESTROY,
)

private fun kindSound(kind: FxKind, crit: Boolean): Sound = when (kind) {
        FxKind.SLASH -> if (crit) Sound.CRIT else Sound.HIT_SLASH
        FxKind.PIERCE -> if (crit) Sound.CRIT else Sound.HIT_PIERCE
        FxKind.SMASH -> if (crit) Sound.CRIT else Sound.HIT_SMASH
        FxKind.ARROW -> Sound.ARROW
        FxKind.FIRE_BOLT, FxKind.RAYS, FxKind.FIREBALL -> Sound.FIRE
        FxKind.BOMB_FIRE, FxKind.BOMB_HOLY -> Sound.THROW
        FxKind.MISSILES, FxKind.SPIRIT_WEAPON, FxKind.SPIRIT_SUMMON, FxKind.MAGE_ARMOR -> Sound.MAGIC
        FxKind.SACRED_FLAME, FxKind.GUARDIANS, FxKind.TURN, FxKind.DESTROY -> Sound.HOLY
        FxKind.HEAL -> Sound.HEAL
        FxKind.BLESS -> Sound.BUFF
        FxKind.ENEMY_HEAL -> Sound.POTION
        FxKind.BITE -> Sound.BITE
        FxKind.POISON -> Sound.POISON
        FxKind.DODGE -> Sound.MISS
        FxKind.BLOCK -> Sound.BLOCK
        FxKind.DRAIN -> Sound.BITE
        FxKind.ACID -> Sound.POISON
        FxKind.PARALYZE -> Sound.MAGIC
        FxKind.BURN -> Sound.FIRE
        FxKind.BLEED -> Sound.HIT_SLASH
        FxKind.STUN -> Sound.HIT_SMASH
        FxKind.CURSE -> Sound.MAGIC
}

/** How long each effect plays, in ms. */
fun fxDuration(kind: FxKind): Int = BattlePace.ms(baseFxDuration(kind))

private fun baseFxDuration(kind: FxKind): Int = when (kind) {
    FxKind.DESTROY -> 1400
    FxKind.FIREBALL, FxKind.SACRED_FLAME, FxKind.GUARDIANS, FxKind.TURN -> 900
    FxKind.MISSILES, FxKind.FIRE_BOLT, FxKind.ARROW, FxKind.BOMB_FIRE, FxKind.BOMB_HOLY, FxKind.HEAL, FxKind.BLESS -> 750
    else -> 520
}

/** The sound for a battle message. */
fun soundFor(step: Step): Sound? {
    step.fx?.let { fx ->
        // a bolt or arrow that goes wide, or a flame the foe springs out of, still sounds as it is let go
        if (fx.kind == FxKind.DODGE && fx.past != null) return kindSound(fx.past!!, false)
        return kindSound(fx.kind, fx.crit)
    }
    return when (step.anim) {
        Anim.ENEMY_FAINT -> Sound.ENEMY_DOWN
        Anim.HERO_FAINT -> Sound.HERO_DOWN
        Anim.LEVEL_UP -> Sound.LEVEL_UP
        Anim.LOOT -> if ((step.rarity ?: Rarity.COMMON) >= Rarity.EPIC) Sound.LOOT_EPIC else Sound.LOOT
        Anim.COINS -> Sound.COINS
        else -> null
    }
}

/**
 * Draws the effect of the current battle message between attacker and target.
 * [enemy] and [hero] are the sprite centres in pixels, [unit] is roughly one sprite pixel.
 */
@Composable
fun BattleFxLayer(fx: Fx?, key: Int, enemy: Offset, hero: Offset, unit: Float, modifier: Modifier, startDelay: Long = 0L, foeGround: Float? = null, heroGround: Float? = null, foeSource: Offset? = null) {
    if (fx == null) return
    // a miss with something flying: the bolt goes wide past the target, which then dodges
    val wide = fx.past?.takeIf { it in FLYING && (fx.kind == FxKind.DODGE || fx.kind == FxKind.BLOCK) }
    // a spell that falls on the spot, like the sacred flame: it strikes where the foe stood as it springs aside
    val onSpot = fx.past?.takeIf { it !in FLYING && fx.kind == FxKind.DODGE }
    val progress = remember(key) { Animatable(0f) }
    // a spell or shot waits for the frame on which the hero lets it go
    var started by remember(key) { androidx.compose.runtime.mutableStateOf(startDelay <= 0L) }
    LaunchedEffect(key) {
        if (startDelay > 0) { kotlinx.coroutines.delay(startDelay); started = true }
        progress.animateTo(1f, tween(fxDuration(wide ?: onSpot ?: fx.kind), easing = LinearEasing))
    }
    val p = progress.value
    if (!started || p >= 1f) return
    Canvas(modifier) {
        val target = if (fx.onHero) hero else enemy
        val source = if (fx.onHero) foeSource ?: enemy else hero
        val u = unit * (if (fx.crit) 1.35f else 1f)
        // where the foe's feet stand: a flame from above comes down to the ground there
        val ground = (if (fx.onHero) heroGround else foeGround) ?: (target.y + 45 * u)
        // and under the one it comes from
        val back = (if (fx.onHero) foeGround else heroGround) ?: (source.y + 60 * u)
        if (onSpot != null) {
            // the foe hops to one side (see the battle screen's dodge): the flame comes down a little to the other
            val away = if (fx.seed % 2 == 0) -1f else 1f
            drawFx(Fx(onSpot, fx.onHero, false, fx.seed), p, source, Offset(target.x + away * 30 * u, target.y), u, ground, back)
            drawFx(fx, p, source, target, u, ground, back)
            return@Canvas
        }
        if (wide == null) { drawFx(fx, p, source, target, u, ground, back); return@Canvas }
        // past the target and on behind it, to one side; a shield stops it where it is
        val dx = target.x - source.x; val dy = target.y - source.y
        val len = kotlin.math.sqrt(dx * dx + dy * dy).coerceAtLeast(1f)
        val side = if (fx.seed % 2 == 0) 1f else -1f
        val by = if (fx.kind == FxKind.BLOCK) target
            else Offset(target.x + dx / len * 34 * u - dy / len * side * 30 * u, target.y + dy / len * 34 * u + dx / len * side * 30 * u)
        drawFx(Fx(wide, fx.onHero, false, fx.seed), p, source, by, u * 0.8f, ground)
        // the dodge or the block as it arrives
        val q = (p - 0.45f) / 0.55f
        if (q in 0f..1f) drawFx(fx, q, source, target, u, ground, back)
    }
}

private val WHITE = Color.White
private val STEEL = Color(0xFFCFE4FF)
private val FIRE = Color(0xFFFF9A2E)
private val FIRE_HOT = Color(0xFFFFE27A)
private val FIRE_DARK = Color(0xFFD83A1A)
private val ARCANE = Color(0xFFB98CFF)
private val ARCANE_LIGHT = Color(0xFFE6D8FF)
private val HOLY = Color(0xFFFFF2A8)
private val HEAL = Color(0xFF7CF08A)
private val POISON = Color(0xFF9AE04A)
private val BLOOD = Color(0xFFE03A3A)
private val ACID = Color(0xFFC8E040)
private val FROST = Color(0xFFBFE8FF)
private val STAR = Color(0xFFFFE070)
private val CURSE = Color(0xFF8A58C8)
private val SMOKE = Color(0xFF2E2A28)
private val FORCE = Color(0xFF8C6CFF)
private val FORCE_CORE = Color(0xFFEDE6FF)
private val RUNE = Color(0xFFC4D6F0)
private val HEAL_LIGHT = Color(0xFFFFE2A0)
private val GOLD_LIGHT = Color(0xFFFFE6A8)
private val SPIRIT = Color(0xFFCFE0FF)
private val STEAM = Color(0xFFE8ECEE)

private fun lerp(a: Offset, b: Offset, t: Float) = Offset(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t)

/** Point on a curved flight path from [a] to [b]; [bend] lifts the middle sideways. */
private fun arc(a: Offset, b: Offset, t: Float, bend: Float): Offset {
    val base = lerp(a, b, t)
    val dx = b.x - a.x
    val dy = b.y - a.y
    val len = kotlin.math.sqrt(dx * dx + dy * dy).coerceAtLeast(1f)
    val lift = sin(t * PI).toFloat() * bend
    return Offset(base.x - dy / len * lift, base.y + dx / len * lift)
}

/** Fades in quickly and out over the second half. */
private fun fade(p: Float) = if (p < 0.15f) p / 0.15f else if (p > 0.6f) (1 - p) / 0.4f else 1f

private fun DrawScope.square(c: Color, at: Offset, s: Float, alpha: Float = 1f) =
    drawRect(c.copy(alpha = alpha.coerceIn(0f, 1f)), Offset(at.x - s / 2, at.y - s / 2), Size(s, s))

/**
 * Sacred flame: radiance like a flame comes down from above onto the foe. The column narrows and softens as it falls,
 * and where it reaches the ground white-gold tongues of fire lick up around the feet, a glow on the floor beneath:
 * no hard edge anywhere.
 */
private fun DrawScope.sacredFlame(r: Random, p: Float, x: Float, ground: Float, u: Float) {
    val f = fade(p)
    // the light comes down from the top of the scene and reaches the ground at a third of the time
    val down = (p / 0.3f).coerceAtMost(1f)
    val front = ground * (1f - (1f - down) * (1f - down))
    val sway = sin(p * 9f) * 1.5f * u
    fun column(wTop: Float, wLow: Float, c: Color, a: Float) {
        val path = Path().apply {
            moveTo(x - wTop / 2, 0f); lineTo(x + wTop / 2, 0f)
            lineTo(x + sway + wLow / 2, front); lineTo(x + sway - wLow / 2, front); close()
        }
        drawPath(path, Brush.verticalGradient(listOf(c.copy(alpha = 0f), c.copy(alpha = a * 0.5f * f), c.copy(alpha = a * f), c.copy(alpha = 0f)), 0f, front + 6 * u))
    }
    column(46 * u, 26 * u, HOLY, 0.28f)
    column(24 * u, 13 * u, HOLY, 0.6f)
    column(9 * u, 5 * u, WHITE, 0.95f)
    if (down < 1f) return
    // on the ground: a soft glow, then the flames
    val burn = ((p - 0.28f) / 0.2f).coerceIn(0f, 1f) * f
    drawOval(Brush.radialGradient(listOf(HOLY.copy(alpha = 0.55f * burn), HOLY.copy(alpha = 0.18f * burn), Color.Transparent), Offset(x, ground), 40 * u),
        Offset(x - 40 * u, ground - 10 * u), Size(80 * u, 20 * u))
    repeat(11) { i ->
        val bx = x + (i - 5) * 4.2f * u + (r.nextFloat() - 0.5f) * 3 * u
        val edge = 1f - kotlin.math.abs(i - 5) / 6f
        val h = (16 + 30 * edge + r.nextFloat() * 12) * u * burn * (0.75f + 0.25f * sin(p * 38f + i * 1.9f))
        val w = (6 + 4 * edge) * u
        val lean = sin(p * 21f + i) * 3 * u + (i - 5) * 0.8f * u
        fun tongue(scale: Float, c: Color, a: Float) {
            val hh = h * scale; val ww = w * scale
            val path = Path().apply {
                moveTo(bx - ww / 2, ground + 2 * u)
                quadraticBezierTo(bx - ww * 0.6f, ground - hh * 0.45f, bx + lean, ground - hh)
                quadraticBezierTo(bx + ww * 0.6f, ground - hh * 0.45f, bx + ww / 2, ground + 2 * u)
                close()
            }
            drawPath(path, Brush.verticalGradient(listOf(c.copy(alpha = 0f), c.copy(alpha = a), c.copy(alpha = a * 0.6f)), ground - hh, ground + 2 * u))
        }
        tongue(1f, HOLY, 0.75f * burn)
        tongue(0.55f, WHITE, 0.9f * burn)
    }
    // embers rising out of the fire
    repeat(12) {
        val t = ((p - 0.3f) / 0.7f * (0.6f + r.nextFloat() * 0.6f) + r.nextFloat() * 0.2f).coerceIn(0f, 1f)
        val ex = x + (r.nextFloat() - 0.5f) * 40 * u + sin(t * 8f + it) * 3 * u
        square(if (it % 2 == 0) HOLY else WHITE, Offset(ex, ground - t * 70 * u), 2.5f * u, (1f - t) * f)
    }
}

/** One tongue of fire standing on [base], [h] high, leaning by [lean]: soft at the root, bright in the body. */
private fun DrawScope.tongue(base: Offset, h: Float, w: Float, lean: Float, c: Color, a: Float) {
    if (h <= 0.5f || a <= 0.01f) return
    val path = Path().apply {
        moveTo(base.x - w / 2, base.y)
        quadraticBezierTo(base.x - w * 0.6f, base.y - h * 0.45f, base.x + lean, base.y - h)
        quadraticBezierTo(base.x + w * 0.6f, base.y - h * 0.45f, base.x + w / 2, base.y)
        close()
    }
    drawPath(path, Brush.verticalGradient(listOf(c.copy(alpha = 0f), c.copy(alpha = a), c.copy(alpha = a * 0.5f)), base.y - h, base.y))
}

/** Dark smoke: soft grey puffs that swell and thin out as they rise. */
private fun DrawScope.smoke(r: Random, at: Offset, t: Float, u: Float, n: Int, rise: Float, a: Float) {
    if (t <= 0f || t >= 1f) return
    repeat(n) {
        val d = r.nextFloat(); val side = (r.nextFloat() - 0.5f) * 16 * u
        val c = Offset(at.x + side + sin(t * 4f + it) * 3 * u, at.y - rise * u * t * (0.5f + d))
        val rad = (4 + 7 * t + 3 * d) * u
        drawCircle(Brush.radialGradient(listOf(SMOKE.copy(alpha = a * (1 - t)), SMOKE.copy(alpha = 0f)), c, rad), rad, c)
    }
}

/** Flames clinging to what was struck, burning down with [t], with smoke and embers. */
private fun DrawScope.clingingFire(r: Random, at: Offset, t: Float, u: Float, size: Float = 1f) {
    if (t <= 0f || t >= 1f) return
    val f = if (t < 0.15f) t / 0.15f else (1 - t) / 0.85f
    drawCircle(Brush.radialGradient(listOf(FIRE.copy(alpha = 0.45f * f), FIRE_DARK.copy(alpha = 0.15f * f), Color.Transparent), at, 22 * u * size), 22 * u * size, at)
    repeat(6) { i ->
        val bx = at.x + (r.nextFloat() - 0.5f) * 22 * u * size
        val by = at.y + (r.nextFloat() - 0.2f) * 14 * u * size
        val h = (8 + r.nextFloat() * 12) * u * size * f * (0.7f + 0.3f * sin(t * 40f + i * 2.1f))
        val lean = sin(t * 23f + i) * 2.5f * u
        tongue(Offset(bx, by), h, 6 * u * size, lean, FIRE_DARK, 0.8f)
        tongue(Offset(bx, by), h * 0.75f, 4 * u * size, lean, FIRE, 0.85f)
        tongue(Offset(bx, by), h * 0.4f, 2.4f * u * size, lean * 0.5f, FIRE_HOT, 0.9f)
    }
    smoke(r, Offset(at.x, at.y - 8 * u), t, u, 4, 40f, 0.45f)
    repeat(6) {
        val e = (t * (0.7f + r.nextFloat() * 0.6f)).coerceIn(0f, 1f)
        square(if (it % 2 == 0) FIRE_HOT else FIRE, Offset(at.x + (r.nextFloat() - 0.5f) * 26 * u + sin(e * 9f + it) * 3 * u, at.y - e * 46 * u), 1.8f * u, (1 - e) * f)
    }
}

/**
 * Fire bolt: a hissing mote of fire, white-hot at the head, trailing flame and dark smoke, that bursts on the foe
 * and leaves flames clinging to it for a moment.
 */
private fun DrawScope.fireBolt(r: Random, p: Float, from: Offset, to: Offset, u: Float) {
    val travel = 0.42f
    val bend = (r.nextFloat() - 0.5f) * 50 * u
    val t = (p / travel).coerceAtMost(1f)
    // smoke left hanging along the way, thinning out
    for (k in 1..9) {
        val tt = t - k * 0.06f
        if (tt <= 0f) continue
        val age = ((p - tt * travel) / 0.5f).coerceIn(0f, 1f)
        val c = arc(from, to, tt, bend) + Offset(0f, -age * 8 * u)
        val rad = (5 + 9 * age) * u
        drawCircle(Brush.radialGradient(listOf(SMOKE.copy(alpha = 0.5f * (1 - age)), SMOKE.copy(alpha = 0f)), c, rad), rad, c)
    }
    if (p < travel) {
        val head = arc(from, to, t, bend)
        val back = arc(from, to, (t - 0.05f).coerceAtLeast(0f), bend)
        val dir = (head - back).let { val l = it.getDistance().coerceAtLeast(0.01f); Offset(it.x / l, it.y / l) }
        // the trailing flame: overlapping blobs, darker and thinner towards the tail, flickering
        for (k in 11 downTo 0) {
            val d = k * 3.6f * u
            val wob = sin(p * 60f + k * 1.7f) * 1.2f * u
            val c = Offset(head.x - dir.x * d - dir.y * wob, head.y - dir.y * d + dir.x * wob)
            val rad = (8f - k * 0.6f) * u
            val col = when { k == 0 -> FIRE_HOT; k < 4 -> FIRE; else -> FIRE_DARK }
            drawCircle(col.copy(alpha = 1f - k * 0.075f), rad, c)
        }
        drawCircle(Brush.radialGradient(listOf(FIRE.copy(alpha = 0.4f), Color.Transparent), head, 24 * u), 24 * u, head)
        drawCircle(WHITE.copy(alpha = 0.9f), 3.2f * u, head)
        // sparks shed on the way
        repeat(5) {
            val st = (t - r.nextFloat() * 0.3f).coerceAtLeast(0f)
            val sp = arc(from, to, st, bend) + Offset((r.nextFloat() - 0.5f) * 8 * u, (t - st) * 30 * u)
            square(FIRE_HOT, sp, 1.6f * u, 1f - (t - st) * 3f)
        }
    } else {
        val s = (p - travel) / (1 - travel)
        val flash = (1 - s / 0.3f).coerceIn(0f, 1f)
        if (flash > 0f) drawCircle(Brush.radialGradient(listOf(WHITE.copy(alpha = 0.8f * flash), FIRE_HOT.copy(alpha = 0.5f * flash), FIRE.copy(alpha = 0.2f * flash), Color.Transparent), to, 24 * u), 24 * u, to)
        burst(r, to, s / 0.5f, u, listOf(FIRE_HOT, FIRE, FIRE_DARK), 10, 20f)
        clingingFire(r, to, s, u, 1.35f)
    }
}

/**
 * Magic missile: a bolt of pure force, a slim shard of cold violet light that strikes with a sharp crack; three of
 * them, each on its own curve, one after the other.
 */
private fun DrawScope.forceDart(r0: Random, p: Float, i: Int, from: Offset, to0: Offset, u: Float) {
    val r = Random(r0.nextInt() + i * 977)
    val to = Offset(to0.x + (r.nextFloat() - 0.5f) * 16 * u, to0.y + (r.nextFloat() - 0.5f) * 20 * u)
    val delay = i * 0.13f
    val travel = 0.42f
    val t = ((p - delay) / travel).coerceIn(0f, 1f)
    val bend = (if (i % 2 == 0) 1 else -1) * (40 + r.nextFloat() * 50) * u
    if (t > 0f && t < 1f) {
        // a fading ribbon behind it
        var prev = arc(from, to, (t - 0.22f).coerceAtLeast(0f), bend)
        for (k in 1..8) {
            val tt = (t - 0.22f + k * 0.0275f).coerceAtLeast(0f)
            val pt = arc(from, to, tt, bend)
            drawLine(FORCE.copy(alpha = 0.06f * k), prev, pt, (0.6f + 0.35f * k) * u, StrokeCap.Round)
            prev = pt
        }
        val head = arc(from, to, t, bend)
        val back = arc(from, to, (t - 0.07f).coerceAtLeast(0f), bend)
        drawCircle(Brush.radialGradient(listOf(FORCE.copy(alpha = 0.4f), Color.Transparent), head, 12 * u), 12 * u, head)
        drawLine(FORCE, back, head, 3.2f * u, StrokeCap.Round)
        drawLine(FORCE_CORE, lerp(back, head, 0.4f), head, 1.4f * u, StrokeCap.Round)
    }
    val s = (p - delay - travel) / 0.32f
    if (s > 0f && s < 1f) {
        drawCircle(Brush.radialGradient(listOf(FORCE_CORE.copy(alpha = 0.85f * (1 - s)), FORCE.copy(alpha = 0.4f * (1 - s)), Color.Transparent), to, 14 * u), 14 * u, to)
        repeat(6) { k ->
            val a = (k * PI / 3).toFloat() + r.nextFloat() * 0.5f
            val len = (6 + 12 * s) * u
            drawLine(FORCE_CORE.copy(alpha = 1 - s), to + Offset(cos(a) * len * 0.4f, sin(a) * len * 0.4f), to + Offset(cos(a) * len, sin(a) * len), 1.2f * u)
        }
    }
}

/**
 * Scorching ray: a ray of fire from the staff, its edge flickering and wavering in its own heat, dark red outside,
 * white-yellow in the core; where it strikes, the foe smoulders.
 */
private fun DrawScope.scorchingRay(r: Random, p: Float, from0: Offset, to: Offset, u: Float) {
    val from = Offset(from0.x, from0.y + (r.nextFloat() - 0.5f) * 4 * u)
    val reach = (p / 0.22f).coerceAtMost(1f)
    val life = if (p < 0.5f) 1f else ((1 - p) / 0.5f)
    val end = lerp(from, to, reach)
    val dx = end.x - from.x; val dy = end.y - from.y
    val len = kotlin.math.sqrt(dx * dx + dy * dy).coerceAtLeast(1f)
    val nx = -dy / len; val ny = dx / len
    fun wavy(width: Float, c: Color, a: Float, amp: Float, ph: Float) {
        val n = 14
        var prev = from
        for (k in 1..n) {
            val f = k / n.toFloat()
            val w = sin(f * 19f + p * 70f + ph) * amp * u * sin(f * PI.toFloat())
            val pt = Offset(from.x + dx * f + nx * w, from.y + dy * f + ny * w)
            drawLine(c.copy(alpha = a * life), prev, pt, width * u * (0.6f + 0.4f * f), StrokeCap.Round)
            prev = pt
        }
    }
    wavy(11f, FIRE_DARK, 0.25f, 2.5f, 0f)
    wavy(6f, FIRE, 0.65f, 1.6f, 1.3f)
    wavy(2.4f, FIRE_HOT, 0.95f, 0.8f, 2.1f)
    // heat shimmer just above the ray
    wavy(1f, Color(0xFFFFE8C0), 0.18f, 4f, 4f)
    if (reach >= 1f) {
        val s = (p - 0.22f) / 0.78f
        val flash = (1 - s / 0.25f).coerceIn(0f, 1f)
        if (flash > 0f) drawCircle(Brush.radialGradient(listOf(FIRE_HOT.copy(alpha = 0.7f * flash), FIRE.copy(alpha = 0.25f * flash), Color.Transparent), to, 18 * u), 18 * u, to)
        clingingFire(r, to, s, u, 0.7f)
    }
}

/**
 * Mage armor: a veil of pale runes gathers from the air around the hero, settles onto the body, and a cold sheen
 * runs up from the feet to the head and fades into it.
 */
private fun DrawScope.mageArmor(r: Random, p: Float, chest: Offset, ground: Float, u: Float) {
    val top = chest.y - (ground - chest.y) * 0.55f
    val bodyW = (ground - top) * 0.17f
    repeat(14) { i ->
        val born = i * 0.025f
        val t = ((p - born) / 0.5f).coerceIn(0f, 1f)
        if (t <= 0f) return@repeat
        val a0 = r.nextFloat() * 2 * PI.toFloat()
        val far = 1.6f - 1.1f * t * t
        val ty = top + (ground - top) * (0.1f + 0.8f * r.nextFloat())
        val c = Offset(chest.x + cos(a0 + t * 2f) * bodyW * far, ty + sin(a0 + t * 2f) * 10 * u * far)
        val alpha = (if (t < 0.2f) t / 0.2f else 1f) * (1f - ((p - 0.65f) / 0.35f).coerceIn(0f, 1f))
        // a rune: three short strokes in a small box
        val g = 3.6f * u
        repeat(3) { k ->
            val x0 = (r.nextInt(3) - 1) * g; val y0 = (r.nextInt(3) - 1) * g
            val x1 = (r.nextInt(3) - 1) * g; val y1 = (r.nextInt(3) - 1) * g
            drawLine(RUNE.copy(alpha = alpha), c + Offset(x0, y0), c + Offset(x1, y1), 1.4f * u, StrokeCap.Round)
        }
        drawCircle(Brush.radialGradient(listOf(RUNE.copy(alpha = 0.25f * alpha), Color.Transparent), c, 6 * u), 6 * u, c)
    }
    // the sheen running up the body
    val run = ((p - 0.45f) / 0.35f).coerceIn(0f, 1f)
    if (run > 0f && run < 1f) {
        val y = ground - (ground - top) * run
        drawRect(Brush.verticalGradient(listOf(Color.Transparent, RUNE.copy(alpha = 0.4f * (1 - run * 0.5f)), Color.Transparent), y - 16 * u, y + 16 * u),
            Offset(chest.x - bodyW, y - 16 * u), Size(bodyW * 2, 32 * u))
    }
    // and the body keeps a faint cold shimmer for a moment
    val keep = ((p - 0.7f) / 0.3f).coerceIn(0f, 1f)
    if (p > 0.55f) {
        val a = 0.16f * (if (p < 0.7f) (p - 0.55f) / 0.15f else 1f - keep)
        drawOval(Brush.radialGradient(listOf(RUNE.copy(alpha = a), Color.Transparent), Offset(chest.x, (top + ground) / 2), (ground - top) * 0.6f),
            Offset(chest.x - bodyW * 1.3f, top), Size(bodyW * 2.6f, ground - top))
    }
}

/** Warm light gathering into the body: motes drawn in from around it, a glow that swells in the chest and fades. */
private fun DrawScope.mending(r: Random, p: Float, chest: Offset, u: Float, c: Color, core: Color) {
    val f = fade(p)
    val swell = sin((p.coerceIn(0f, 1f)) * PI.toFloat())
    drawCircle(Brush.radialGradient(listOf(core.copy(alpha = 0.55f * swell), c.copy(alpha = 0.3f * swell), Color.Transparent), chest, 46 * u), 46 * u, chest)
    // a soft shimmer along the body
    drawOval(Brush.radialGradient(listOf(c.copy(alpha = 0.22f * swell), Color.Transparent), chest, 60 * u), Offset(chest.x - 26 * u, chest.y - 60 * u), Size(52 * u, 120 * u))
    repeat(24) {
        val a = r.nextFloat() * 2 * PI.toFloat()
        val d0 = (30 + r.nextFloat() * 22) * u
        val t = ((p - r.nextFloat() * 0.35f) / 0.6f).coerceIn(0f, 1f)
        if (t <= 0f || t >= 1f) return@repeat
        val d = d0 * (1 - t * t)
        val pos = Offset(chest.x + cos(a) * d * 0.7f, chest.y + sin(a) * d - t * 6 * u)
        drawCircle(Brush.radialGradient(listOf(core.copy(alpha = 0.95f * f), c.copy(alpha = 0f)), pos, 4.6f * u), 4.6f * u, pos)
    }
}

/** Bless: a soft fall of golden light from above onto the hero, dust drifting in it, and the god's sun sign glowing briefly at the breast. */
private fun DrawScope.blessing(r: Random, p: Float, chest: Offset, ground: Float, u: Float) {
    val f = fade(p)
    val down = (p / 0.3f).coerceAtMost(1f)
    val front = ground * (1f - (1f - down) * (1f - down))
    val x = chest.x
    val path = Path().apply { moveTo(x - 14 * u, 0f); lineTo(x + 14 * u, 0f); lineTo(x + 32 * u, front); lineTo(x - 32 * u, front); close() }
    drawPath(path, Brush.verticalGradient(listOf(GOLD_LIGHT.copy(alpha = 0f), GOLD_LIGHT.copy(alpha = 0.16f * f), GOLD_LIGHT.copy(alpha = 0.3f * f), GOLD_LIGHT.copy(alpha = 0f)), 0f, front + 8 * u))
    repeat(14) {
        val t = (p * (0.7f + r.nextFloat() * 0.5f) + r.nextFloat() * 0.3f) % 1f
        val dx = (r.nextFloat() - 0.5f) * 44 * u + sin(t * 6f + it) * 3 * u
        val y = front * (0.2f + 0.8f * t)
        square(GOLD_LIGHT, Offset(x + dx * (0.5f + 0.5f * t), y), 1.6f * u, f * 0.8f * sin(t * PI.toFloat()))
    }
    val sign = ((p - 0.3f) / 0.25f).coerceIn(0f, 1f) * (1f - ((p - 0.65f) / 0.35f).coerceIn(0f, 1f))
    if (sign > 0f) {
        val c = Offset(x, chest.y + 4 * u)
        drawCircle(Brush.radialGradient(listOf(GOLD_LIGHT.copy(alpha = 0.6f * sign), Color.Transparent), c, 16 * u), 16 * u, c)
        drawCircle(WHITE.copy(alpha = 0.85f * sign), 3.2f * u, c, style = Stroke(1.2f * u))
        repeat(8) { k ->
            val a = (k * PI / 4).toFloat()
            drawLine(GOLD_LIGHT.copy(alpha = 0.85f * sign), c + Offset(cos(a) * 5 * u, sin(a) * 5 * u), c + Offset(cos(a) * (if (k % 2 == 0) 9 else 7) * u, sin(a) * (if (k % 2 == 0) 9 else 7) * u), 1.1f * u)
        }
    }
}

/**
 * Turning the undead: the holy symbol flares at the hero, and a wave of light rolls over the ground to the undead and
 * breaks against it in a pale blaze.
 */
private fun DrawScope.holyWave(r: Random, p: Float, from: Offset, to: Offset, ground: Float, heroGround: Float, u: Float) {
    val flare = (1f - p / 0.3f).coerceIn(0f, 1f)
    if (flare > 0f) drawCircle(Brush.radialGradient(listOf(WHITE.copy(alpha = 0.8f * flare), HOLY.copy(alpha = 0.35f * flare), Color.Transparent), from, 26 * u), 26 * u, from)
    val t = ((p - 0.08f) / 0.55f).coerceIn(0f, 1f)
    // the wave runs over the ground, from under the hero to under the foe
    if (t > 0f && t < 1f) {
        val gx = from.x + (to.x - from.x) * t
        val gy = heroGround + (ground - heroGround) * t
        val w = (26 + 30 * t) * u
        val h = (6 + 6 * t) * u
        // the light it leaves behind on the ground
        for (k in 1..6) {
            val tt = (t - k * 0.06f).coerceAtLeast(0f)
            val bx = from.x + (to.x - from.x) * tt; val by = heroGround + (ground - heroGround) * tt
            drawOval(Brush.radialGradient(listOf(HOLY.copy(alpha = 0.18f * (1 - k / 7f)), Color.Transparent), Offset(bx, by), w), Offset(bx - w, by - h), Size(w * 2, h * 2))
        }
        drawOval(Brush.radialGradient(listOf(WHITE.copy(alpha = 0.7f), HOLY.copy(alpha = 0.45f), Color.Transparent), Offset(gx, gy), w), Offset(gx - w, gy - h * 1.4f), Size(w * 2, h * 2.8f))
        // the crest of the wave: light rising off it
        repeat(10) {
            val ox = (r.nextFloat() - 0.5f) * w * 1.6f
            val rise = r.nextFloat() * 26 * u * (0.4f + t)
            square(if (it % 2 == 0) WHITE else HOLY, Offset(gx + ox, gy - rise), 1.8f * u, 0.8f * (1f - rise / (40 * u)).coerceIn(0f, 1f))
        }
    }
    val b = ((p - 0.6f) / 0.4f).coerceIn(0f, 1f)
    if (b > 0f && b < 1f) {
        val mid = Offset(to.x, (to.y + ground) / 2)
        drawCircle(Brush.radialGradient(listOf(WHITE.copy(alpha = 0.55f * (1 - b)), HOLY.copy(alpha = 0.3f * (1 - b)), Color.Transparent), mid, 54 * u), 54 * u, mid)
        repeat(12) {
            val x = to.x + (r.nextFloat() - 0.5f) * 40 * u
            val y = ground - b * (30 + 50 * r.nextFloat()) * u
            square(HOLY, Offset(x, y), 2f * u, (1 - b))
        }
    }
}

/** The spiritual weapon itself: a great flanged mace of pale light, held at [pivot] and turned by [angle]. */
private fun DrawScope.spectralMace(pivot: Offset, angle: Float, a: Float, u: Float) {
    if (a <= 0.01f) return
    rotate(angle, pivot) {
        val len = 56 * u
        val head = pivot + Offset(0f, len)
        drawCircle(Brush.radialGradient(listOf(SPIRIT.copy(alpha = 0.45f * a), Color.Transparent), head, 24 * u), 24 * u, head)
        // haft with a pommel
        drawLine(SPIRIT.copy(alpha = 0.6f * a), pivot, head, 5f * u, StrokeCap.Round)
        drawLine(WHITE.copy(alpha = 0.55f * a), pivot, head, 1.6f * u, StrokeCap.Round)
        drawCircle(SPIRIT.copy(alpha = 0.7f * a), 3.4f * u, pivot)
        // the flanged head: a heavy core with blades standing out on either side
        drawOval(SPIRIT.copy(alpha = 0.75f * a), Offset(head.x - 7 * u, head.y - 11 * u), Size(14 * u, 22 * u))
        for (side in listOf(-1f, 1f)) for (k in 0..2) {
            val y = head.y - 8 * u + k * 8 * u
            val path = Path().apply {
                moveTo(head.x + side * 5 * u, y - 3.5f * u); lineTo(head.x + side * 13 * u, y)
                lineTo(head.x + side * 5 * u, y + 3.5f * u); close()
            }
            drawPath(path, SPIRIT.copy(alpha = 0.8f * a))
        }
        drawOval(WHITE.copy(alpha = 0.65f * a), Offset(head.x - 3 * u, head.y - 8 * u), Size(6 * u, 16 * u))
    }
}

/**
 * The spiritual weapon called up: motes of pale light gather beside the hero and the mace takes shape among them,
 * hovering upright, slowly turning, waiting to strike; it does not strike yet.
 */
private fun DrawScope.spiritSummon(r: Random, p: Float, hero: Offset, u: Float) {
    val at = Offset(hero.x + 46 * u, hero.y + 10 * u + sin(p * 9f) * 2 * u)
    val gather = (p / 0.45f).coerceIn(0f, 1f)
    repeat(18) {
        val a = r.nextFloat() * 2 * PI.toFloat()
        val d = (40 + r.nextFloat() * 30) * u * (1 - gather)
        val pos = at + Offset(cos(a) * d, sin(a) * d * 0.8f - 28 * u)
        square(if (it % 3 == 0) WHITE else SPIRIT, pos, 1.8f * u, (1 - gather * 0.8f) * fade(p))
    }
    val form = ((p - 0.2f) / 0.4f).coerceIn(0f, 1f) * (1f - ((p - 0.8f) / 0.2f).coerceIn(0f, 1f) * 0.5f)
    drawCircle(Brush.radialGradient(listOf(SPIRIT.copy(alpha = 0.35f * form), Color.Transparent), at + Offset(0f, -28 * u), 40 * u), 40 * u, at + Offset(0f, -28 * u))
    spectralMace(at, 180f + sin(p * 5f) * 8f, form, u)
}

/** Spiritual weapon: a great spectral mace of pale light comes down on the foe, its afterimages trailing it, and strikes in a burst of cold light. */
private fun DrawScope.spiritWeapon(r: Random, p: Float, hit: Offset, u: Float) {
    val pivot = Offset(hit.x + 30 * u, hit.y - 52 * u)
    val swing = ((p - 0.05f) / 0.4f).coerceIn(0f, 1f)
    val ease = swing * swing * (3 - 2 * swing)
    val appear = (p / 0.12f).coerceAtMost(1f)
    val gone = 1f - ((p - 0.55f) / 0.35f).coerceIn(0f, 1f)
    fun mace(angle: Float, a: Float) = spectralMace(pivot, angle, a, u)
    val angle = -120f + 150f * ease
    for (k in 3 downTo 1) mace(angle - k * 16f * (1 - ease * 0.6f), 0.22f * appear * gone * (1f - k * 0.2f) * (if (swing in 0.05f..0.95f) 1f else 0.3f))
    mace(angle, appear * gone)
    val s = (p - 0.45f) / 0.45f
    if (s > 0f && s < 1f) {
        drawCircle(Brush.radialGradient(listOf(WHITE.copy(alpha = 0.7f * (1 - s)), SPIRIT.copy(alpha = 0.35f * (1 - s)), Color.Transparent), hit, 26 * u), 26 * u, hit)
        burst(r, hit, s, u, listOf(SPIRIT, WHITE), 10, 22f)
    }
}

/** Spirit guardians: pale spirits trailing veils of cold light wheel round the one they guard, those behind dimmer. */
private fun DrawScope.guardians(r: Random, p: Float, centre: Offset, u: Float) {
    val f = fade(p)
    val n = 5
    repeat(n) { i ->
        val a = (i * 2 * PI / n + p * 4.2).toFloat()
        val front = (sin(a) + 1f) / 2f
        val rx = 40 * u; val ry = 13 * u
        val pos = Offset(centre.x + cos(a) * rx, centre.y + 12 * u + sin(a) * ry - 6 * u * sin(p * 9f + i))
        val alpha = f * (0.35f + 0.55f * front)
        // the veil trailing behind, along the way it came
        for (k in 1..6) {
            val ab = a - k * 0.13f
            val pb = Offset(centre.x + cos(ab) * rx, centre.y + 12 * u + sin(ab) * ry - 6 * u * sin(p * 9f + i) + k * 2.2f * u)
            drawCircle(SPIRIT.copy(alpha = alpha * 0.28f * (1 - k / 7f)), (5.5f - k * 0.6f) * u, pb)
        }
        // the spirit: a hooded head and a body that thins away
        val body = Path().apply {
            moveTo(pos.x - 5 * u, pos.y - 4 * u)
            quadraticBezierTo(pos.x - 6 * u, pos.y + 8 * u, pos.x + sin(p * 11f + i) * 2 * u, pos.y + 16 * u)
            quadraticBezierTo(pos.x + 6 * u, pos.y + 8 * u, pos.x + 5 * u, pos.y - 4 * u)
            close()
        }
        drawPath(body, Brush.verticalGradient(listOf(SPIRIT.copy(alpha = alpha * 0.8f), SPIRIT.copy(alpha = 0f)), pos.y - 4 * u, pos.y + 16 * u))
        drawCircle(Brush.radialGradient(listOf(WHITE.copy(alpha = alpha), SPIRIT.copy(alpha = alpha * 0.5f), Color.Transparent), pos + Offset(0f, -6 * u), 6 * u), 6 * u, pos + Offset(0f, -6 * u))
    }
}

/**
 * A thrown flask: glass with its liquid catching the light, tumbling through the air; it bursts on the foe in glass
 * shards. Alchemist's fire splashes burning and clings; holy water splashes cold and hisses into steam.
 */
private fun DrawScope.flask(r: Random, p: Float, from: Offset, to: Offset, u: Float, holy: Boolean) {
    val liquid = if (holy) Color(0xFF9CC8E8) else Color(0xFFFF8A2A)
    if (p < 0.5f) {
        val t = p / 0.5f
        val pos = arc(from, to, t, -80 * u)
        rotate(p * 760, pos) {
            drawOval(Color(0xFFDDE6EA).copy(alpha = 0.55f), Offset(pos.x - 7 * u, pos.y - 4.5f * u), Size(14 * u, 14 * u))
            drawOval(liquid.copy(alpha = 0.9f), Offset(pos.x - 5.5f * u, pos.y + 0.5f * u), Size(11 * u, 8 * u))
            drawOval(WHITE.copy(alpha = 0.6f), Offset(pos.x - 4.5f * u, pos.y - 3 * u), Size(3 * u, 4 * u))
            drawRect(Color(0xFFDDE6EA).copy(alpha = 0.7f), Offset(pos.x - 2.2f * u, pos.y - 11 * u), Size(4.4f * u, 7 * u))
            drawRect(Color(0xFF6A4A2A), Offset(pos.x - 2.6f * u, pos.y - 13.5f * u), Size(5.2f * u, 3 * u))
        }
        // a burning rag in the neck of the fire flask
        if (!holy) { tongue(pos + Offset(0f, -13 * u), 7 * u, 3.5f * u, sin(p * 50f) * 1.5f * u, FIRE, 0.9f); tongue(pos + Offset(0f, -13 * u), 4 * u, 2f * u, 0f, FIRE_HOT, 0.9f) }
        return
    }
    val s = (p - 0.5f) / 0.5f
    // glass shards
    repeat(9) {
        val a = r.nextFloat() * 2 * PI.toFloat()
        val d = (10 + r.nextFloat() * 22) * u * s
        val pos = Offset(to.x + cos(a) * d, to.y + sin(a) * d * 0.7f + s * s * 18 * u)
        drawLine(Color(0xFFE8F0F4).copy(alpha = 1 - s), pos, pos + Offset(cos(a + 1f) * 2.5f * u, sin(a + 1f) * 2.5f * u), 1f * u)
    }
    // the splash: drops flung out and falling
    repeat(14) {
        val a = PI.toFloat() + r.nextFloat() * PI.toFloat()
        val d = (12 + r.nextFloat() * 20) * u * s
        val pos = Offset(to.x + cos(a) * d, to.y + sin(a) * d * 0.8f + s * s * 26 * u)
        square(liquid, pos, (2.6f - s) * u, (1 - s) * 0.9f)
    }
    val flash = (1 - s / 0.25f).coerceIn(0f, 1f)
    if (holy) {
        if (flash > 0f) drawCircle(Brush.radialGradient(listOf(WHITE.copy(alpha = 0.6f * flash), liquid.copy(alpha = 0.25f * flash), Color.Transparent), to, 20 * u), 20 * u, to)
        // it hisses into steam on the foe
        repeat(6) {
            val t = (s * (0.7f + r.nextFloat() * 0.5f)).coerceIn(0f, 1f)
            val c = Offset(to.x + (r.nextFloat() - 0.5f) * 24 * u + sin(t * 5f + it) * 3 * u, to.y - t * 34 * u)
            val rad = (4 + 7 * t) * u
            drawCircle(Brush.radialGradient(listOf(STEAM.copy(alpha = 0.4f * (1 - t)), STEAM.copy(alpha = 0f)), c, rad), rad, c)
        }
    } else {
        if (flash > 0f) drawCircle(Brush.radialGradient(listOf(FIRE_HOT.copy(alpha = 0.8f * flash), FIRE.copy(alpha = 0.35f * flash), Color.Transparent), to, 26 * u), 26 * u, to)
        clingingFire(r, to, s, u, 1.5f)
    }
}

/**
 * Fireball: a roiling mass of fire, not a ball, churning as it flies and trailing thick smoke; it bursts into billows
 * of flame that darken to smoke as they swell, the ground beneath catches fire and black smoke climbs away.
 */
private fun DrawScope.fireball(r: Random, p: Float, from: Offset, to: Offset, ground: Float, u: Float) {
    val travel = 0.42f
    val bend = (r.nextFloat() - 0.5f) * 60 * u
    val t = (p / travel).coerceAtMost(1f)
    for (k in 1..10) {
        val tt = t - k * 0.055f
        if (tt <= 0f) continue
        val age = ((p - tt * travel) / 0.55f).coerceIn(0f, 1f)
        val c = arc(from, to, tt, bend) + Offset(0f, -age * 12 * u)
        val rad = (8 + 12 * age) * u
        drawCircle(Brush.radialGradient(listOf(SMOKE.copy(alpha = 0.55f * (1 - age)), SMOKE.copy(alpha = 0f)), c, rad), rad, c)
    }
    if (p < travel) {
        val head = arc(from, to, t, bend)
        drawCircle(Brush.radialGradient(listOf(FIRE.copy(alpha = 0.45f), FIRE_DARK.copy(alpha = 0.15f), Color.Transparent), head, 34 * u), 34 * u, head)
        // the churning mass: blobs rolling round the core, dark at the rim, white-hot within
        repeat(16) { k ->
            val a = r.nextFloat() * 2 * PI.toFloat() + p * (8f + k)
            val d = (4 + r.nextFloat() * 10) * u
            val c = head + Offset(cos(a) * d, sin(a) * d)
            val rad = (6.5f + r.nextFloat() * 6f) * u
            val col = if (k < 7) FIRE_DARK else if (k < 13) FIRE else FIRE_HOT
            drawCircle(Brush.radialGradient(listOf(col, col.copy(alpha = 0f)), c, rad), rad, c)
        }
        drawCircle(Brush.radialGradient(listOf(WHITE.copy(alpha = 0.85f), FIRE_HOT.copy(alpha = 0f)), head, 6 * u), 6 * u, head)
        repeat(6) {
            val st = (t - r.nextFloat() * 0.25f).coerceAtLeast(0f)
            val sp = arc(from, to, st, bend) + Offset((r.nextFloat() - 0.5f) * 12 * u, (t - st) * 40 * u)
            square(if (it % 2 == 0) FIRE_HOT else FIRE, sp, 1.8f * u, 1f - (t - st) * 3f)
        }
        return
    }
    val s = (p - travel) / (1 - travel)
    val flash = (1 - s / 0.18f).coerceIn(0f, 1f)
    if (flash > 0f) drawCircle(Brush.radialGradient(listOf(WHITE.copy(alpha = 0.85f * flash), FIRE_HOT.copy(alpha = 0.6f * flash), FIRE.copy(alpha = 0.25f * flash), Color.Transparent), to, 70 * u), 70 * u, to)
    // the ground below catches fire
    clingingFire(r, Offset(to.x, ground), s, u, 1.9f)
    // billows of flame swelling and darkening into smoke
    val ease = 1f - (1f - s) * (1f - s)
    repeat(30) { k ->
        val a = r.nextFloat() * 2 * PI.toFloat()
        val d = (6 + r.nextFloat() * 50) * u * ease
        val c = to + Offset(cos(a) * d, sin(a) * d * 0.75f - s * 18 * u)
        val rad = (14 + r.nextFloat() * 14) * u * (0.45f + 0.75f * ease)
        val heat = (1f - s * (1.0f + r.nextFloat() * 0.7f) + (1f - d / (56 * u)) * 0.25f).coerceIn(0f, 1f)
        val col = when { heat > 0.7f -> FIRE_HOT; heat > 0.4f -> FIRE; heat > 0.15f -> FIRE_DARK; else -> SMOKE }
        val a0 = if (col == SMOKE) 0.6f * (1 - s) else (1 - s * 0.7f)
        drawCircle(Brush.radialGradient(listOf(col.copy(alpha = a0), col.copy(alpha = a0 * 0.4f), col.copy(alpha = 0f)), c, rad), rad, c)
    }
    // black smoke climbing away
    smoke(r, to + Offset(0f, -10 * u), ((s - 0.25f) / 0.75f), u, 6, 70f, 0.55f)
    burst(r, to, s, u, listOf(FIRE_HOT, FIRE, FIRE_DARK), 16, 50f)
}

/** Sparks flying out of a point. */
private fun DrawScope.burst(r: Random, at: Offset, t: Float, u: Float, colors: List<Color>, n: Int = 10, reach: Float = 18f) {
    if (t <= 0f || t >= 1f) return
    repeat(n) {
        val a = r.nextFloat() * 2 * PI.toFloat()
        val d = (0.4f + r.nextFloat() * 0.8f) * reach * u * t
        val pos = Offset(at.x + cos(a) * d, at.y + sin(a) * d)
        square(colors[it % colors.size], pos, u * (2.5f - 1.5f * t), 1f - t)
    }
}

internal fun DrawScope.drawFx(fx: Fx, p: Float, source: Offset, target: Offset, u: Float, ground: Float = target.y + 45 * u, back: Float = source.y + 60 * u) {
    val r = Random(fx.seed)
    // Small random offset so the impact point is never exactly the same.
    val hit = Offset(target.x + (r.nextFloat() - 0.5f) * 14 * u, target.y + (r.nextFloat() - 0.5f) * 14 * u)
    when (fx.kind) {
        FxKind.SLASH -> {
            val angle = (if (r.nextBoolean()) 1 else -1) * (20f + r.nextFloat() * 40f)
            val lines = if (fx.crit) 3 else 1 + r.nextInt(2)
            rotate(angle, hit) {
                for (i in 0 until lines) {
                    val off = (i - (lines - 1) / 2f) * 6 * u
                    val grow = (p / 0.45f).coerceAtMost(1f)
                    val from = Offset(hit.x - 26 * u, hit.y + off - 10 * u)
                    val to = Offset(hit.x - 26 * u + 52 * u * grow, hit.y + off + 10 * u * grow - 10 * u * (1 - grow))
                    drawLine(STEEL.copy(alpha = fade(p)), from, to, 4 * u, StrokeCap.Round)
                    drawLine(WHITE.copy(alpha = fade(p)), from, to, 1.6f * u, StrokeCap.Round)
                }
            }
            burst(r, hit, (p - 0.3f) / 0.7f, u, listOf(WHITE, if (fx.onHero) BLOOD else STEEL), if (fx.crit) 16 else 8)
        }
        FxKind.PIERCE -> {
            val a = r.nextFloat() * 2 * PI.toFloat()
            val dir = Offset(cos(a), sin(a))
            val t = (p / 0.35f).coerceAtMost(1f)
            val tip = Offset(hit.x - dir.x * 30 * u * (1 - t), hit.y - dir.y * 30 * u * (1 - t))
            val tail = Offset(tip.x - dir.x * 22 * u, tip.y - dir.y * 22 * u)
            if (p < 0.55f) {
                drawLine(STEEL, tail, tip, 3 * u, StrokeCap.Square)
                drawLine(WHITE, lerp(tail, tip, 0.5f), tip, 1.5f * u, StrokeCap.Square)
            }
            if (p > 0.3f) {
                val s = (p - 0.3f) / 0.7f
                for (k in 0 until 4) {
                    val ang = a + k * PI.toFloat() / 2 + PI.toFloat() / 4
                    drawLine(WHITE.copy(alpha = 1 - s), hit, Offset(hit.x + cos(ang) * 14 * u * s, hit.y + sin(ang) * 14 * u * s), 2 * u)
                }
            }
            burst(r, hit, (p - 0.3f) / 0.7f, u, listOf(WHITE, if (fx.onHero) BLOOD else STEEL), 6, 12f)
        }
        FxKind.SMASH -> {
            val s = (p / 0.6f).coerceAtMost(1f)
            drawCircle(WHITE.copy(alpha = 1 - p), 8 * u + 22 * u * s, hit, style = Stroke(3 * u))
            if (fx.crit) drawCircle(FIRE_HOT.copy(alpha = 1 - p), 4 * u + 34 * u * s, hit, style = Stroke(2 * u))
            // impact stars
            repeat(3 + r.nextInt(3)) {
                val a = r.nextFloat() * 2 * PI.toFloat()
                val d = 10 * u + 18 * u * s
                square(FIRE_HOT, Offset(hit.x + cos(a) * d, hit.y + sin(a) * d), 3 * u, 1 - p)
            }
            burst(r, hit, s, u, listOf(Color(0xFFB0A090), WHITE), 8, 22f)
        }
        FxKind.ARROW -> {
            val bend = (r.nextFloat() - 0.5f) * 60 * u
            val t = (p / 0.6f).coerceAtMost(1f)
            if (p < 0.6f) {
                val head = arc(source, hit, t, bend)
                val back = arc(source, hit, (t - 0.16f).coerceAtLeast(0f), bend)
                drawLine(Color(0x55FFFFFF), arc(source, hit, (t - 0.3f).coerceAtLeast(0f), bend), back, 1.5f * u)
                drawLine(Color(0xFF8A5A30), back, head, 3 * u, StrokeCap.Round)
                square(STEEL, head, 7 * u)
                square(WHITE, back, 5 * u)
            }
            burst(r, hit, (p - 0.55f) / 0.45f, u, listOf(WHITE, if (fx.onHero) BLOOD else STEEL), 8, 14f)
        }
        FxKind.FIRE_BOLT -> fireBolt(r, p, source, hit, u)
        FxKind.FIREBALL -> fireball(r, p, source, hit, ground, u)
        FxKind.MISSILES -> repeat(3) { i -> forceDart(r, p, i, source, hit, u) }
        FxKind.RAYS -> scorchingRay(r, p, source, hit, u)
        FxKind.SACRED_FLAME -> sacredFlame(r, p, hit.x, ground, u)
        FxKind.SPIRIT_WEAPON -> spiritWeapon(r, p, hit, u)
        FxKind.SPIRIT_SUMMON -> spiritSummon(r, p, target, u)
        FxKind.GUARDIANS -> guardians(r, p, target, u)
        FxKind.DESTROY -> {
            // the light of the god reaches the undead, which flares up and falls to ash and embers
            holyWave(r, (p / 0.4f).coerceAtMost(1f), source, target, ground, back, u)
            val glow = ((p - 0.3f) / 0.25f).coerceIn(0f, 1f) * (1f - ((p - 0.55f) / 0.45f).coerceIn(0f, 1f))
            if (glow > 0f) drawCircle(Brush.radialGradient(listOf(WHITE.copy(alpha = 0.7f * glow), HOLY.copy(alpha = 0.35f * glow), Color.Transparent), Offset(target.x, (target.y + ground) / 2), 60 * u), 60 * u, Offset(target.x, (target.y + ground) / 2))
            val ash = Color(0xFF8E887E)
            repeat(34) { i ->
                val born = 0.32f + r.nextFloat() * 0.3f
                val t = ((p - born) / (1f - born)).coerceIn(0f, 1f)
                val x0 = target.x + (r.nextFloat() - 0.5f) * 36 * u
                val y0 = ground - r.nextFloat() * (ground - target.y) * 1.7f
                val drift = (r.nextFloat() - 0.3f) * 30 * u
                if (t > 0f && t < 1f) square(if (i % 3 == 0) HOLY else ash, Offset(x0 + drift * t, y0 - 46 * u * t * (0.5f + r.nextFloat())), u * (3f - 2f * t), (1f - t) * 0.95f)
            }
        }
        FxKind.TURN -> holyWave(r, p, source, target, ground, back, u)
        FxKind.BOMB_FIRE, FxKind.BOMB_HOLY -> flask(r, p, source, hit, u, holy = fx.kind == FxKind.BOMB_HOLY)
        FxKind.HEAL -> mending(r, p, target, u, HEAL_LIGHT, WHITE)
        FxKind.ENEMY_HEAL -> mending(r, p, target, u, Color(0xFFC89A50), Color(0xFFE8D0A0))
        FxKind.BLESS -> blessing(r, p, target, ground, u)
        FxKind.MAGE_ARMOR -> mageArmor(r, p, target, ground, u)
        FxKind.BITE -> {
            val close = (p / 0.35f).coerceAtMost(1f)
            val gap = 22 * u * (1 - close)
            val w = 34 * u
            for (side in listOf(-1, 1)) {
                val y = hit.y + side * (6 * u + gap)
                for (k in 0 until 5) {
                    val x = hit.x - w / 2 + k * w / 4
                    val path = Path().apply {
                        moveTo(x - 3.5f * u, y)
                        lineTo(x + 3.5f * u, y)
                        lineTo(x, y - side * 9 * u)
                        close()
                    }
                    drawPath(path, WHITE.copy(alpha = fade(p)))
                }
            }
            if (p > 0.35f) repeat(4) { k ->
                square(BLOOD, Offset(hit.x - 12 * u + k * 8 * u, hit.y + (r.nextFloat() - 0.5f) * 6 * u), 3 * u, 1 - p)
            }
        }
        FxKind.POISON -> repeat(10) {
            val x = target.x + (r.nextFloat() - 0.5f) * 50 * u
            val y = target.y + 20 * u - p * (30 + 30 * r.nextFloat()) * u
            drawCircle(POISON.copy(alpha = fade(p)), (2 + 3 * r.nextFloat()) * u, Offset(x, y), style = Stroke(1.5f * u))
        }
        FxKind.DODGE -> {
            // a swing that cuts through empty air next to the target
            val side = if (r.nextBoolean()) 1 else -1
            repeat(3) { k ->
                val y = target.y - 12 * u + k * 12 * u
                val x0 = target.x + side * 10 * u
                drawLine(WHITE.copy(alpha = 0.7f * fade(p)), Offset(x0, y), Offset(x0 + side * 30 * u * p, y), 2 * u)
            }
        }
        FxKind.DRAIN -> repeat(9) { k ->
            // drops of blood fly from the victim to the drinker
            val tt = (p * 1.4f - k * 0.05f).coerceIn(0f, 1f)
            if (tt <= 0f || tt >= 1f) return@repeat
            val pos = arc(target, source, tt, (r.nextFloat() - 0.5f) * 60 * u)
            drawCircle(BLOOD.copy(alpha = 1f - tt * 0.4f), (2.5f - tt) * u, pos)
        }
        FxKind.ACID -> {
            repeat(12) {
                val a = r.nextFloat() * PI.toFloat() * 2
                val d = (10 + r.nextFloat() * 22) * u * minOf(1f, p * 2.5f)
                val pos = Offset(hit.x + cos(a) * d, hit.y + sin(a) * d * 0.6f + p * p * 30 * u)
                drawCircle(ACID.copy(alpha = fade(p)), (2f + r.nextFloat() * 2.5f) * u, pos)
            }
            drawCircle(ACID.copy(alpha = 0.35f * fade(p)), 20 * u * minOf(1f, p * 3), hit)
        }
        FxKind.PARALYZE -> {
            repeat(3) { k ->
                val pp = (p - k * 0.15f).coerceIn(0f, 1f)
                drawCircle(FROST.copy(alpha = (1 - pp) * 0.9f), (10 + pp * 34) * u, target, style = Stroke(2.5f * u))
            }
            burst(r, target, p, u, listOf(FROST, WHITE), 12, 30f)
        }
        FxKind.BURN -> repeat(14) {
            val x = target.x + (r.nextFloat() - 0.5f) * 44 * u
            val rise = (p + r.nextFloat() * 0.5f) % 1f
            val y = target.y + 26 * u - rise * 50 * u
            val col = listOf(FIRE_HOT, FIRE, FIRE_DARK)[it % 3]
            square(col, Offset(x, y), (4.5f - rise * 3f) * u, fade(p) * (1 - rise * 0.6f))
        }
        FxKind.BLEED -> repeat(10) { k ->
            // drops run down from the wound
            val x = hit.x + (r.nextFloat() - 0.5f) * 30 * u
            val fall = (p * 1.3f - k * 0.04f).coerceIn(0f, 1f)
            val y = hit.y - 6 * u + fall * (18 + r.nextFloat() * 18) * u
            drawCircle(BLOOD.copy(alpha = (1f - fall * 0.7f) * fade(p)), (1.6f + r.nextFloat()) * u, Offset(x, y))
        }
        FxKind.STUN -> {
            // little stars circling above the head
            val head = Offset(target.x, target.y - 30 * u)
            repeat(4) { k ->
                val a = (p * 2f * PI.toFloat() * 1.5f) + k * PI.toFloat() / 2
                val pos = Offset(head.x + cos(a) * 18 * u, head.y + sin(a) * 6 * u)
                val st = 3.2f * u
                drawRect(STAR.copy(alpha = fade(p)), Offset(pos.x - st / 4, pos.y - st), Size(st / 2, st * 2))
                drawRect(STAR.copy(alpha = fade(p)), Offset(pos.x - st, pos.y - st / 4), Size(st * 2, st / 2))
            }
        }
        FxKind.CURSE -> repeat(12) { k ->
            // a dark swirl closing in
            val a = k * PI.toFloat() / 6 + p * 4f
            val d = (1f - p) * 40 * u + 6 * u
            drawCircle(CURSE.copy(alpha = 0.8f * fade(p)), (2.5f + (k % 3)) * u, Offset(target.x + cos(a) * d, target.y + sin(a) * d * 0.7f))
        }
        FxKind.BLOCK -> {
            val s = (p / 0.3f).coerceAtMost(1f)
            val c = Offset(target.x + 18 * u, target.y)
            drawArc(Color(0xFFBFE0FF).copy(alpha = fade(p)), -60f, 120f, false, Offset(c.x - 14 * u * s, c.y - 26 * u), Size(28 * u * s + 1, 52 * u), style = Stroke(4 * u))
            burst(r, Offset(c.x + 8 * u, c.y), (p - 0.1f) / 0.9f, u, listOf(FIRE_HOT, WHITE), 8, 16f)
        }
    }
}

/** A glowing orb with a trail flying to the target, then an explosion. */
private fun DrawScope.projectile(
    r: Random, p: Float, from: Offset, to: Offset, u: Float, colors: List<Color>,
    size: Float, explosion: Float, travel: Float = 0.5f,
) {
    val bend = (r.nextFloat() - 0.5f) * 80 * u
    if (p < travel) {
        val t = p / travel
        for (k in 0 until 7) {
            val tt = (t - k * 0.035f).coerceAtLeast(0f)
            val pos = arc(from, to, tt, bend)
            val jitter = Offset((r.nextFloat() - 0.5f) * 3 * u, (r.nextFloat() - 0.5f) * 3 * u)
            drawCircle(colors[minOf(k / 2, colors.size - 1)].copy(alpha = 1f - k * 0.12f), (size - k * 0.7f) * u, pos + jitter)
        }
    } else {
        val s = (p - travel) / (1 - travel)
        drawCircle(colors[2].copy(alpha = 0.7f * (1 - s)), explosion * u * (0.3f + 0.7f * s), to)
        drawCircle(colors[1].copy(alpha = 0.85f * (1 - s)), explosion * 0.7f * u * (0.3f + 0.7f * s), to)
        drawCircle(colors[0].copy(alpha = 1 - s), explosion * 0.4f * u * (0.3f + 0.7f * s), to)
        burst(r, to, s, u, colors, 14, explosion * 0.9f)
    }
}

/**
 * What a lasting status looks like on a body, drawn as long as it holds: [t] runs on in seconds, [chest] and [ground]
 * place the body, [blood] is the blood setting (0 off). Quiet on purpose; the round's damage flares in its own effect.
 */
/** The pool a bleeding body leaves where it stands: on the ground, it stays put when the body lunges or dodges. */
internal fun DrawScope.drawBloodPool(t: Float, x: Float, ground: Float, u: Float, blood: Int) {
    if (blood <= 0) return
    val pool = (0.6f + 0.4f * ((t / 6f).coerceAtMost(1f))) * (if (blood >= 2) 1f else 0.6f)
    drawOval(BLOOD_DARK.copy(alpha = 0.8f), Offset(x - 14 * u * pool, ground - 3 * u * pool), Size(28 * u * pool, 7 * u * pool))
}

internal fun DrawScope.drawStatus(s: de.bornim.core.Status, t: Float, chest: Offset, ground: Float, u: Float, blood: Int) {
    val h = ground - chest.y
    val top = chest.y - h * 0.8f
    val w = h * 0.36f
    fun cyc(i: Int, speed: Float) = ((t * speed + i * 0.6180339f) % 1f + 1f) % 1f
    fun hash(i: Int, k: Int) = (((i * 73856093) xor (k * 19349663)) and 0xFFFF) / 65535f
    when (s) {
        de.bornim.core.Status.BURN -> {
            // small flames licking up the body and round the feet, embers and thin smoke
            // they cling to the outline and the feet, not pasted over the middle of the body
            repeat(7) { i ->
                val side = if (i % 2 == 0) -1f else 1f
                val bx = chest.x + side * w * (0.42f + 0.22f * hash(i, 1)) * (if (i == 6) 0f else 1f)
                val by = ground - hash(i, 2) * h * (if (i == 6) 0.05f else 1.3f)
                val life = cyc(i, 1.3f)
                val hh = (9 + 13 * hash(i, 3)) * u * sin(life * PI.toFloat()) * (0.8f + 0.2f * sin(t * 17f + i))
                val lean = sin(t * 7f + i) * 2f * u
                tongue(Offset(bx, by), hh, 6.5f * u, lean, FIRE_DARK, 0.8f)
                tongue(Offset(bx, by), hh * 0.7f, 4.4f * u, lean, FIRE, 0.9f)
                tongue(Offset(bx, by), hh * 0.35f, 2f * u, lean * 0.5f, FIRE_HOT, 0.9f)
            }
            repeat(5) { i ->
                val c = cyc(i, 0.5f)
                val p = Offset(chest.x + (hash(i, 4) - 0.5f) * w + sin(c * 6f + i) * 4 * u, chest.y - c * h * 0.9f)
                val rad = (4 + 7 * c) * u
                drawCircle(Brush.radialGradient(listOf(SMOKE.copy(alpha = 0.35f * (1 - c)), SMOKE.copy(alpha = 0f)), p, rad), rad, p)
            }
            repeat(6) { i ->
                val c = cyc(i, 0.9f)
                square(if (i % 2 == 0) FIRE_HOT else FIRE, Offset(chest.x + (hash(i, 5) - 0.5f) * w * 1.2f + sin(c * 9f + i) * 3 * u, ground - h * 0.3f - c * h), 1.6f * u, 1f - c)
            }
        }
        de.bornim.core.Status.POISON -> {
            // a sickly green vapour rising off the body, now and then a drop of bile
            repeat(7) { i ->
                val c = cyc(i, 0.35f)
                val p = Offset(chest.x + (if (i % 2 == 0) -1f else 1f) * w * (0.35f + 0.3f * hash(i, 1)) + sin(c * 5f + i) * 5 * u, ground - h * 0.4f - c * h * 1.3f)
                val rad = (9 + 12 * c) * u
                drawCircle(Brush.radialGradient(listOf(BILE.copy(alpha = 0.3f * sin(c * PI.toFloat())), BILE.copy(alpha = 0f)), p, rad), rad, p)
            }
            repeat(2) { i ->
                val c = cyc(i, 0.45f)
                if (c < 0.6f) {
                    val f = c / 0.6f
                    val x = chest.x + (hash(i, 6) - 0.5f) * w * 0.5f
                    square(BILE, Offset(x, chest.y + 6 * u + f * f * (ground - chest.y - 6 * u)), 3f * u, 0.9f)
                }
            }
        }
        de.bornim.core.Status.BLEED -> {
            if (blood <= 0) return
            // drops falling from the wound (the pool they make lies on the ground: see [drawBloodPool])
            repeat(if (blood >= 2) 3 else 1) { i ->
                val c = cyc(i, 0.8f)
                val x = chest.x + (hash(i, 7) - 0.5f) * w * 0.6f
                val y0 = chest.y + (hash(i, 8) - 0.3f) * h * 0.4f
                square(BLOOD_DARK, Offset(x, y0 + c * c * (ground - y0)), 3f * u, 0.95f)
            }
        }
        de.bornim.core.Status.STUN -> {
            // dazed: a dull haze about the head (the body itself sways, see the battle screen)
            val head = Offset(chest.x, top + h * 0.12f)
            repeat(3) { i ->
                val a = t * 2.2f + i * 2.1f
                val p = head + Offset(cos(a) * 10 * u, sin(a) * 3 * u - 4 * u)
                drawCircle(Brush.radialGradient(listOf(Color(0xFFD8D0B0).copy(alpha = 0.25f), Color.Transparent), p, 8 * u), 8 * u, p)
            }
        }
        de.bornim.core.Status.SLOW -> {
            // cold: a pale breath of frost round the body and rime glinting on it
            repeat(6) { i ->
                val c = cyc(i, 0.25f)
                val p = Offset(chest.x + (hash(i, 1) - 0.5f) * w * 1.4f + sin(c * 4f + i) * 4 * u, ground - c * h * 0.9f)
                val rad = (7 + 8 * c) * u
                drawCircle(Brush.radialGradient(listOf(FROST.copy(alpha = 0.22f * sin(c * PI.toFloat())), FROST.copy(alpha = 0f)), p, rad), rad, p)
            }
            repeat(9) { i ->
                val glint = (sin(t * 3f + i * 1.7f) + 1f) / 2f
                square(FROST, Offset(chest.x + (hash(i, 2) - 0.5f) * w, top + hash(i, 3) * (ground - top)), 1.5f * u, 0.3f + 0.6f * glint * glint)
            }
        }
        de.bornim.core.Status.WEAK -> {
            // a dark violet veil clinging to the body and drifting off it
            val mid = Offset(chest.x, (top + ground) / 2)
            drawOval(Brush.radialGradient(listOf(CURSE.copy(alpha = 0.22f), CURSE.copy(alpha = 0.08f), Color.Transparent), mid, h), Offset(chest.x - w, top), Size(w * 2, ground - top))
            repeat(5) { i ->
                val c = cyc(i, 0.3f)
                val p = Offset(chest.x + (hash(i, 1) - 0.5f) * w * 1.2f + sin(c * 3f + i) * 6 * u, ground - h * 0.2f - c * h * 1.2f)
                val rad = (5 + 7 * c) * u
                drawCircle(Brush.radialGradient(listOf(Color(0xFF3A2050).copy(alpha = 0.35f * (1 - c)), Color.Transparent), p, rad), rad, p)
            }
        }
        de.bornim.core.Status.BLIND -> {
            // a harsh after-glare flickering before the eyes
            val eyes = Offset(chest.x, top + h * 0.13f)
            val flick = 0.6f + 0.4f * sin(t * 13f) * sin(t * 5.3f)
            drawCircle(Brush.radialGradient(listOf(WHITE.copy(alpha = 0.45f * flick), WHITE.copy(alpha = 0.12f * flick), Color.Transparent), eyes, 14 * u), 14 * u, eyes)
            drawLine(WHITE.copy(alpha = 0.35f * flick), eyes + Offset(-14 * u, 0f), eyes + Offset(14 * u, 0f), 1.2f * u)
        }
    }
}

private val BILE = Color(0xFF9AB040)
private val BLOOD_DARK = Color(0xFF7A0E12)

/**
 * The pace of the fight's moves, set in the menu: every animation of a fight (blows, spells, reactions, effects, falls)
 * takes its normal time times [factor]. Calm is slower, fast is quicker.
 */
object BattlePace {
    var factor = 1.0
    fun set(level: Int) { factor = when (level) { 0 -> 1.35; 2 -> 0.7; else -> 1.0 } }
    fun ms(v: Int): Int = (v * factor).toInt()
    fun ms(v: Long): Long = (v * factor).toLong()
}
