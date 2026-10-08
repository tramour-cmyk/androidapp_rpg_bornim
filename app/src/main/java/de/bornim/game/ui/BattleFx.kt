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
        FxKind.MISSILES, FxKind.SPIRIT_WEAPON, FxKind.MAGE_ARMOR -> Sound.MAGIC
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
fun fxDuration(kind: FxKind): Int = when (kind) {
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
fun BattleFxLayer(fx: Fx?, key: Int, enemy: Offset, hero: Offset, unit: Float, modifier: Modifier, startDelay: Long = 0L, foeGround: Float? = null, heroGround: Float? = null) {
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
        val source = if (fx.onHero) enemy else hero
        val u = unit * (if (fx.crit) 1.35f else 1f)
        // where the foe's feet stand: a flame from above comes down to the ground there
        val ground = (if (fx.onHero) heroGround else foeGround) ?: (target.y + 45 * u)
        if (onSpot != null) {
            // the foe hops to one side (see the battle screen's dodge): the flame comes down a little to the other
            val away = if (fx.seed % 2 == 0) -1f else 1f
            drawFx(Fx(onSpot, fx.onHero, false, fx.seed), p, source, Offset(target.x + away * 30 * u, target.y), u, ground)
            drawFx(fx, p, source, target, u, ground)
            return@Canvas
        }
        if (wide == null) { drawFx(fx, p, source, target, u, ground); return@Canvas }
        // past the target and on behind it, to one side; a shield stops it where it is
        val dx = target.x - source.x; val dy = target.y - source.y
        val len = kotlin.math.sqrt(dx * dx + dy * dy).coerceAtLeast(1f)
        val side = if (fx.seed % 2 == 0) 1f else -1f
        val by = if (fx.kind == FxKind.BLOCK) target
            else Offset(target.x + dx / len * 34 * u - dy / len * side * 30 * u, target.y + dy / len * 34 * u + dx / len * side * 30 * u)
        drawFx(Fx(wide, fx.onHero, false, fx.seed), p, source, by, u * 0.8f, ground)
        // the dodge or the block as it arrives
        val q = (p - 0.45f) / 0.55f
        if (q in 0f..1f) drawFx(fx, q, source, target, u, ground)
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

internal fun DrawScope.drawFx(fx: Fx, p: Float, source: Offset, target: Offset, u: Float, ground: Float = target.y + 45 * u) {
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
        FxKind.FIREBALL -> projectile(r, p, source, hit, u, listOf(FIRE_HOT, FIRE, FIRE_DARK), size = 9f, explosion = 60f, travel = 0.45f)
        FxKind.MISSILES -> repeat(3) { i -> forceDart(r, p, i, source, hit, u) }
        FxKind.RAYS -> scorchingRay(r, p, source, hit, u)
        FxKind.SACRED_FLAME -> sacredFlame(r, p, hit.x, ground, u)
        FxKind.SPIRIT_WEAPON -> {
            val start = -70f + r.nextFloat() * 20f
            val angle = start + 140f * (p / 0.6f).coerceAtMost(1f)
            rotate(angle, Offset(hit.x, hit.y + 20 * u)) {
                val c = Color(0xFF9FD0FF).copy(alpha = 0.85f * fade(p))
                drawRect(c, Offset(hit.x - 2.5f * u, hit.y - 30 * u), Size(5 * u, 34 * u))
                drawRect(c, Offset(hit.x - 9 * u, hit.y + 4 * u), Size(18 * u, 4 * u))
                drawRect(WHITE.copy(alpha = fade(p)), Offset(hit.x - 1 * u, hit.y - 28 * u), Size(2 * u, 30 * u))
            }
            burst(r, hit, (p - 0.45f) / 0.55f, u, listOf(Color(0xFF9FD0FF), WHITE), 8, 16f)
        }
        FxKind.GUARDIANS -> {
            val n = 5 + r.nextInt(3)
            val radius = 30 * u + 6 * u * sin(p * 6f)
            repeat(n) { i ->
                val a = (i * 2 * PI / n + p * 5).toFloat()
                square(HOLY, Offset(target.x + cos(a) * radius, target.y + sin(a) * radius * 0.6f), 5 * u, fade(p))
                square(WHITE, Offset(target.x + cos(a) * radius, target.y + sin(a) * radius * 0.6f), 2 * u, fade(p))
            }
        }
        FxKind.DESTROY -> {
            // the light of the god reaches the undead, which flares up and falls to ash and embers
            val q = (p / 0.35f).coerceAtMost(1f)
            repeat(3) { i ->
                val t = ((q - i * 0.15f) / 0.7f).coerceIn(0f, 1f)
                if (t > 0f && t < 1f) drawCircle(HOLY.copy(alpha = 1 - t), 10 * u + 70 * u * t, lerp(source, hit, t), style = Stroke(3 * u))
            }
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
        FxKind.TURN -> {
            repeat(3) { i ->
                val t = ((p - i * 0.15f) / 0.7f).coerceIn(0f, 1f)
                if (t > 0f && t < 1f) drawCircle(HOLY.copy(alpha = 1 - t), 10 * u + 70 * u * t, lerp(source, hit, t), style = Stroke(3 * u))
            }
        }
        FxKind.BOMB_FIRE, FxKind.BOMB_HOLY -> {
            val holy = fx.kind == FxKind.BOMB_HOLY
            val t = (p / 0.5f).coerceAtMost(1f)
            if (p < 0.5f) {
                val pos = arc(source, hit, t, -80 * u)
                rotate(p * 900, pos) { drawRect(if (holy) Color(0xFF8FC8FF) else FIRE, Offset(pos.x - 3 * u, pos.y - 4 * u), Size(6 * u, 8 * u)) }
            } else {
                val s = (p - 0.5f) / 0.5f
                if (holy) {
                    repeat(14) {
                        val a = r.nextFloat() * PI.toFloat() + PI.toFloat()
                        val d = 26 * u * s
                        square(Color(0xFFBFE4FF), Offset(hit.x + cos(a) * d, hit.y + sin(a) * d + s * s * 20 * u), 3 * u, 1 - s)
                    }
                    drawCircle(WHITE.copy(alpha = 1 - s), 30 * u * s, hit, style = Stroke(2 * u))
                } else {
                    drawCircle(FIRE.copy(alpha = 0.8f * (1 - s)), 10 * u + 26 * u * s, hit)
                    drawCircle(FIRE_HOT.copy(alpha = 1 - s), 6 * u + 14 * u * s, hit)
                    burst(r, hit, s, u, listOf(FIRE_HOT, FIRE, FIRE_DARK), 12, 30f)
                }
            }
        }
        FxKind.HEAL, FxKind.ENEMY_HEAL -> {
            repeat(9) {
                val x = target.x + (r.nextFloat() - 0.5f) * 50 * u
                val y = target.y + 25 * u - p * (40 + 30 * r.nextFloat()) * u
                val c = if (it % 3 == 0) WHITE else HEAL
                drawRect(c.copy(alpha = fade(p)), Offset(x - u, y - 3 * u), Size(2 * u, 6 * u))
                drawRect(c.copy(alpha = fade(p)), Offset(x - 3 * u, y - u), Size(6 * u, 2 * u))
            }
            drawCircle(HEAL.copy(alpha = 0.25f * fade(p)), 34 * u, target)
        }
        FxKind.BLESS -> {
            drawOval(HOLY.copy(alpha = fade(p)), Offset(target.x - 18 * u, target.y - 40 * u), Size(36 * u, 9 * u), style = Stroke(2.5f * u))
            repeat(12) {
                val x = target.x + (r.nextFloat() - 0.5f) * 56 * u
                val y = target.y - 50 * u + p * (60 + 30 * r.nextFloat()) * u
                square(if (it % 2 == 0) HOLY else WHITE, Offset(x, y), 3 * u, fade(p))
            }
        }
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
