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
    FxKind.SPIRIT_WEAPON, FxKind.BOMB_FIRE, FxKind.BOMB_HOLY, FxKind.GUARDIANS, FxKind.TURN,
)

private fun kindSound(kind: FxKind, crit: Boolean): Sound = when (kind) {
        FxKind.SLASH -> if (crit) Sound.CRIT else Sound.HIT_SLASH
        FxKind.PIERCE -> if (crit) Sound.CRIT else Sound.HIT_PIERCE
        FxKind.SMASH -> if (crit) Sound.CRIT else Sound.HIT_SMASH
        FxKind.ARROW -> Sound.ARROW
        FxKind.FIRE_BOLT, FxKind.RAYS, FxKind.FIREBALL -> Sound.FIRE
        FxKind.BOMB_FIRE, FxKind.BOMB_HOLY -> Sound.THROW
        FxKind.MISSILES, FxKind.SPIRIT_WEAPON, FxKind.MAGE_ARMOR -> Sound.MAGIC
        FxKind.SACRED_FLAME, FxKind.GUARDIANS, FxKind.TURN -> Sound.HOLY
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
fun BattleFxLayer(fx: Fx?, key: Int, enemy: Offset, hero: Offset, unit: Float, modifier: Modifier, startDelay: Long = 0L) {
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
        if (onSpot != null) {
            // the foe hops to one side (see the battle screen's dodge): the flame comes down a little to the other
            val away = if (fx.seed % 2 == 0) -1f else 1f
            drawFx(Fx(onSpot, fx.onHero, false, fx.seed), p, source, Offset(target.x + away * 30 * u, target.y), u)
            drawFx(fx, p, source, target, u)
            return@Canvas
        }
        if (wide == null) { drawFx(fx, p, source, target, u); return@Canvas }
        // past the target and on behind it, to one side; a shield stops it where it is
        val dx = target.x - source.x; val dy = target.y - source.y
        val len = kotlin.math.sqrt(dx * dx + dy * dy).coerceAtLeast(1f)
        val side = if (fx.seed % 2 == 0) 1f else -1f
        val by = if (fx.kind == FxKind.BLOCK) target
            else Offset(target.x + dx / len * 34 * u - dy / len * side * 30 * u, target.y + dy / len * 34 * u + dx / len * side * 30 * u)
        drawFx(Fx(wide, fx.onHero, false, fx.seed), p, source, by, u * 0.8f)
        // the dodge or the block as it arrives
        val q = (p - 0.45f) / 0.55f
        if (q in 0f..1f) drawFx(fx, q, source, target, u)
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

internal fun DrawScope.drawFx(fx: Fx, p: Float, source: Offset, target: Offset, u: Float) {
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
        FxKind.FIRE_BOLT -> projectile(r, p, source, hit, u, listOf(FIRE_HOT, FIRE, FIRE_DARK), size = 6f, explosion = 26f)
        FxKind.FIREBALL -> projectile(r, p, source, hit, u, listOf(FIRE_HOT, FIRE, FIRE_DARK), size = 9f, explosion = 60f, travel = 0.45f)
        FxKind.MISSILES -> {
            repeat(3) { i ->
                val delay = i * 0.12f + r.nextFloat() * 0.05f
                val t = ((p - delay) / 0.5f).coerceIn(0f, 1f)
                val bend = (r.nextFloat() - 0.5f) * 140 * u
                if (t in 0.001f..0.999f) {
                    for (k in 0 until 5) {
                        val tt = (t - k * 0.04f).coerceAtLeast(0f)
                        square(if (k == 0) ARCANE_LIGHT else ARCANE, arc(source, hit, tt, bend), (5 - k) * u, 1f - k * 0.18f)
                    }
                }
                burst(r, hit, ((p - delay - 0.5f) / 0.3f), u, listOf(ARCANE_LIGHT, ARCANE), 6, 12f)
            }
        }
        FxKind.RAYS -> {
            // from the staff or hand itself, the rays only fanning a little
            val off = (r.nextFloat() - 0.5f) * 4 * u
            val start = Offset(source.x, source.y + off)
            val w = (3 + r.nextFloat() * 3) * u * fade(p)
            val reach = (p / 0.25f).coerceAtMost(1f)
            val end = lerp(start, hit, reach)
            drawLine(FIRE.copy(alpha = fade(p)), start, end, w * 1.8f, StrokeCap.Round)
            drawLine(FIRE_HOT.copy(alpha = fade(p)), start, end, w, StrokeCap.Round)
            burst(r, hit, (p - 0.25f) / 0.75f, u, listOf(FIRE_HOT, FIRE), 8, 16f)
        }
        FxKind.SACRED_FLAME -> {
            val grow = (p / 0.3f).coerceAtMost(1f)
            val w = (16 + 8 * r.nextFloat()) * u * grow
            val top = Offset(hit.x - w / 2, 0f)
            drawRect(
                Brush.verticalGradient(listOf(Color.Transparent, HOLY.copy(alpha = 0.9f * fade(p)), WHITE.copy(alpha = fade(p)))),
                top, Size(w, hit.y + 20 * u),
            )
            repeat(10) {
                val x = hit.x + (r.nextFloat() - 0.5f) * 40 * u
                val y = hit.y + 20 * u - (p * 80 * u * (0.5f + r.nextFloat()))
                square(HOLY, Offset(x, y), 3 * u, fade(p))
            }
        }
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
        FxKind.MAGE_ARMOR -> {
            val s = (p / 0.4f).coerceAtMost(1f)
            val radius = 36 * u * (0.6f + 0.4f * s)
            val path = Path()
            for (k in 0..6) {
                val a = (k * PI / 3 + PI / 6).toFloat()
                val pt = Offset(target.x + cos(a) * radius, target.y + sin(a) * radius)
                if (k == 0) path.moveTo(pt.x, pt.y) else path.lineTo(pt.x, pt.y)
            }
            drawPath(path, Color(0xFF7AB8FF).copy(alpha = 0.25f * fade(p)))
            drawPath(path, Color(0xFFBFE0FF).copy(alpha = fade(p)), style = Stroke(3 * u))
        }
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
