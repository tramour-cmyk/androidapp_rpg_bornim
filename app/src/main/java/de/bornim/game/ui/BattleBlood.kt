package de.bornim.game.ui

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import de.bornim.core.Anim
import de.bornim.core.Fx
import de.bornim.core.FxKind
import kotlin.math.cos
import kotlin.math.sin
import kotlin.random.Random

/** What comes out of a creature that is hit. */
enum class Gore(val main: Color, val light: Color) {
    BLOOD(Color(0xFF6E0C12), Color(0xFFA4161E)),
    ICHOR(Color(0xFF2E2416), Color(0xFF5A4A2A)),
    BONE(Color(0xFFB8AE9C), Color(0xFFE8E0D0)),
    SLIME(Color(0xFF9A7020), Color(0xFFD8A83A)),
}

/** Undead leak ichor or splinter, the jelly splashes slime; everything else bleeds. */
fun goreFor(monsterId: String): Gore = when (monsterId) {
    "skeleton" -> Gore.BONE
    "zombie", "ghoul" -> Gore.ICHOR
    "ochre_jelly" -> Gore.SLIME
    else -> Gore.BLOOD
}

/** Physical hits that draw blood; spells and status effects do not. */
private val WOUNDS = setOf(FxKind.SLASH, FxKind.PIERCE, FxKind.SMASH, FxKind.ARROW, FxKind.BITE, FxKind.BLEED, FxKind.SPIRIT_WEAPON)

/**
 * A short spray of droplets from a hit, away from the attacker, falling to the ground.
 * [level] 1 is subtle (few small drops), 2 shows more and leaves splats on the ground that fade.
 */
@Composable
fun BloodLayer(anim: Anim?, fx: Fx?, key: Int, enemy: Offset, enemyFeet: Float, hero: Offset, heroFeet: Float, level: Int, foe: Gore, unit: Float, modifier: Modifier) {
    if (level <= 0 || fx == null || fx.kind !in WOUNDS) return
    val onHero = when (anim) {
        Anim.HERO_HIT, Anim.HERO_FAINT -> true
        Anim.ENEMY_HIT, Anim.ENEMY_FAINT -> false
        else -> return
    }
    val gore = if (onHero) Gore.BLOOD else foe
    val duration = if (level >= 2) 1300 else 750
    val progress = remember(key) { Animatable(0f) }
    LaunchedEffect(key) { progress.animateTo(1f, tween(duration, easing = LinearEasing)) }
    val p = progress.value
    if (p >= 1f) return
    val rnd = Random(fx.seed * 31 + key)
    val count = (if (level >= 2) 15 else 6) + if (fx.crit) (if (level >= 2) 8 else 3) else 0
    // Drops fly away from the attacker: the hero stands bottom left, the foe top right.
    val baseAngle = if (onHero) 200.0 else -25.0
    data class Drop(val angle: Double, val speed: Float, val size: Float, val delay: Float, val light: Boolean)
    val drops = List(count) {
        Drop(
            Math.toRadians(baseAngle + rnd.nextDouble(-70.0, 55.0)),
            unit * (if (level >= 2) rnd.nextFloat() * 70f + 40f else rnd.nextFloat() * 45f + 25f),
            unit * (if (level >= 2) rnd.nextFloat() * 2.2f + 1.6f else rnd.nextFloat() * 1.4f + 1.1f),
            rnd.nextFloat() * 0.12f,
            rnd.nextInt(3) == 0,
        )
    }
    val origin = if (onHero) hero else enemy
    val ground = if (onHero) heroFeet else enemyFeet
    Canvas(modifier) {
        val flight = if (level >= 2) 0.55f else 1f
        for (d in drops) {
            val t = ((p - d.delay) / flight).coerceIn(0f, 1f)
            if (t <= 0f) continue
            val x = origin.x + cos(d.angle).toFloat() * d.speed * t
            var y = origin.y + sin(d.angle).toFloat() * d.speed * t + 160f * unit * t * t
            val landed = y >= ground
            if (landed) y = ground
            val fade = if (level >= 2) (1f - ((p - 0.55f) / 0.45f).coerceIn(0f, 1f)) else (1f - ((t - 0.6f) / 0.4f).coerceIn(0f, 1f))
            if (fade <= 0f) continue
            val c = if (d.light) gore.light else gore.main
            if (landed && level >= 2) {
                // a small splat on the ground, flattened by the perspective
                drawOval(c.copy(alpha = 0.85f * fade), Offset(x - d.size * 1.6f, y - d.size * 0.4f), Size(d.size * 3.2f, d.size * 0.9f))
            } else if (!landed) {
                // a round drop with a short trail behind it
                drawCircle(c.copy(alpha = fade), d.size * 0.55f, Offset(x, y))
                drawCircle(c.copy(alpha = fade * 0.5f), d.size * 0.35f, Offset(x - cos(d.angle).toFloat() * d.size * 0.9f, y - sin(d.angle).toFloat() * d.size * 0.9f - 2f * unit * t))
            }
        }
    }
}
