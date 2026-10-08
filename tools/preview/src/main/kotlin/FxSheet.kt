package preview

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.offset
import androidx.compose.ui.ImageComposeScene
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.dp
import de.bornim.core.Fx
import de.bornim.core.FxKind
import de.bornim.game.ui.drawFx
import de.bornim.game.ui.drawStatus
import org.jetbrains.skia.EncodedImageFormat
import java.io.File

/** Contact sheet of every battle effect at three moments, with two different seeds. */
fun renderFxSheet() {
    val kinds = FxKind.entries
    val frames = listOf(0.2f, 0.45f, 0.7f)
    val cell = 120
    val scene = ImageComposeScene(cell * 6, cell * kinds.size, Density(1f)) {
        Column(Modifier.background(Color(0xFF2A3A2A))) {
            kinds.forEach { k ->
                Row {
                    for (seed in listOf(11, 4242)) for (p in frames) {
                        Canvas(Modifier.size(cell.dp).background(if (seed == 11) Color(0xFF3A5A3A) else Color(0xFF34503A))) {
                            val onHero = k in setOf(FxKind.BITE, FxKind.POISON, FxKind.HEAL, FxKind.BLESS, FxKind.MAGE_ARMOR, FxKind.BLOCK, FxKind.GUARDIANS)
                            val enemy = Offset(size.width * 0.72f, size.height * 0.32f)
                            val hero = Offset(size.width * 0.25f, size.height * 0.75f)
                            drawCircle(Color(0x55FFFFFF), 10f, enemy)
                            drawCircle(Color(0x55FFFFFF), 10f, hero)
                            drawFx(Fx(k, onHero, crit = seed == 4242, seed = seed), p, if (onHero) enemy else hero, if (onHero) hero else enemy, 1.2f)
                        }
                    }
                }
            }
        }
    }
    val img = scene.render(0)
    File("build/screens/fx_sheet.png").writeBytes(img.encodeToData(EncodedImageFormat.PNG)!!.bytes)
    scene.close()
    println("wrote fx_sheet")
}

/** Grimfang springing out of a sacred flame (the save made) and caught in one (the save failed), as the battle shows it. */
fun renderFlameDodge() {
    val id = "dire_wolf"
    val look = de.bornim.core.MonsterLook(3)
    val frame = de.bornim.core.art.MonsterArt.battleFrame(id, look, de.bornim.core.art.Act.IDLE, 0, 0)
    val px = 1.6f
    val ts = listOf(0.15f, 0.35f, 0.55f, 0.75f)
    val cw = 330; val ch = 300
    val scene = ImageComposeScene(cw * ts.size, ch * 2, Density(1f)) {
        Column(Modifier.background(Color(0xFF2A3A2A))) {
            for (saved in listOf(true, false)) Row {
                for (t in ts) androidx.compose.foundation.layout.Box(Modifier.size(cw.dp, ch.dp).background(Color(0xFF3A5A3A))) {
                    val feetX = cw * 0.5f; val feetY = ch * 0.85f
                    val seed = 11
                    val side = if (seed % 2 == 0) 1 else -1
                    val hop = if (saved) (kotlin.math.sin(t * Math.PI.toFloat()) * 26 * side) else 0f
                    val fw = frame.width * px; val feet = (de.bornim.core.art.MonsterArt.groundLine(id) * px).toFloat()
                    androidx.compose.foundation.layout.Box(Modifier.offset((feetX - fw / 2 + hop).dp, (feetY - feet).dp)) {
                        de.bornim.game.ui.PixelSprite(frame, px.dp, overflow = true)
                    }
                    Canvas(Modifier.size(cw.dp, ch.dp)) {
                        val enemy = Offset(feetX, feetY - feet * 0.55f)
                        val hero = Offset(20f, ch.toFloat())
                        val u = fw / 90
                        if (saved) {
                            val away = if (seed % 2 == 0) -1f else 1f
                            drawFx(Fx(FxKind.SACRED_FLAME, false, false, seed), t, hero, Offset(enemy.x + away * 30 * u, enemy.y), u)
                            drawFx(Fx(FxKind.DODGE, false, false, seed, FxKind.SACRED_FLAME), t, hero, enemy, u)
                        } else drawFx(Fx(FxKind.SACRED_FLAME, false, false, seed), t, hero, enemy, u)
                    }
                }
            }
        }
    }
    val img = scene.render(0)
    File("build/screens/flame_dodge.png").writeBytes(img.encodeToData(EncodedImageFormat.PNG)!!.bytes)
    scene.close()
    println("wrote flame_dodge")
}

/**
 * Where effects land on the foes built in the round, placed exactly as the battle screen places them: the frame by its
 * feet, the effects on the body's middle, the shimmer band and wounds laid over the frame.
 */
fun renderFxOnFoes() {
    val M = de.bornim.core.art.MonsterArt
    val foes = listOf("wolf" to 3, "dire_wolf" to 0, "goblin" to 0, "skeleton" to 2)
    val kinds = listOf(FxKind.SLASH, FxKind.PIERCE, FxKind.SMASH, FxKind.FIRE_BOLT, FxKind.SACRED_FLAME, FxKind.BITE, FxKind.POISON)
    val px = 1.5f
    val cw = 300; val ch = 300
    val scene = ImageComposeScene(cw * (kinds.size + 1), ch * foes.size, Density(1f)) {
        Column(Modifier.background(Color(0xFF2A3A2A))) {
            for ((id, seed) in foes) Row {
                val look = de.bornim.core.MonsterLook(seed, shiny = true)
                val frame = M.battleFrame(id, look, de.bornim.core.art.Act.IDLE, 0, 0)
                val (bodyW, bodyH) = M.bodySize(id, look, frame.width, frame.height)
                for (c in 0..kinds.size) androidx.compose.foundation.layout.Box(Modifier.size(cw.dp, ch.dp).background(Color(0xFF3A5A3A))) {
                    val feetX = cw * 0.55f; val feetY = ch * 0.8f
                    val anchor = (M.anchorX(id, frame.width) * px).toFloat(); val feet = (M.groundLine(id) * px).toFloat()
                    androidx.compose.foundation.layout.Box(Modifier.offset((feetX - anchor).dp, (feetY - feet).dp)) {
                        de.bornim.game.ui.PixelSprite(frame, px.dp, overflow = true)
                        if (c == kinds.size) {
                            de.bornim.game.ui.PixelSprite(de.bornim.core.art.Glow.sheen(frame, 5, 12), px.dp, alpha = 0.75f, overflow = true)
                            de.bornim.game.ui.PixelSprite(de.bornim.core.art.Glow.wounds(frame, 2, 0x8A1010, seed), px.dp, overflow = true)
                        }
                    }
                    Canvas(Modifier.size(cw.dp, ch.dp)) {
                        // as the battle screen: on the feet's line, at 55 % of the body's height
                        val enemy = Offset(feetX, feetY - (bodyH * px).toFloat() * 0.55f)
                        val hero = Offset(20f, ch.toFloat())
                        val u = (bodyW * px).toFloat() / 90
                        if (c < kinds.size) drawFx(Fx(kinds[c], false, false, 7), 0.62f, hero, enemy, u)
                        drawCircle(Color.Red, 2.5f, enemy)
                    }
                }
            }
        }
    }
    val img = scene.render(0)
    File("build/screens/fx_on_foes.png").writeBytes(img.encodeToData(EncodedImageFormat.PNG)!!.bytes)
    scene.close()
    println("wrote fx on foes")
}

/** Every ability's effect at six moments, on a goblin (foe, right) and the hero's place (left): for a style check. */
fun renderAbilityFx() {
    val M = de.bornim.core.art.MonsterArt
    val all = listOf(
        "Feuerpfeil" to Fx(FxKind.FIRE_BOLT, false, false, 7), "Magisches Geschoss" to Fx(FxKind.MISSILES, false, false, 7),
        "Sengender Strahl" to Fx(FxKind.RAYS, false, false, 7), "Feuerball" to Fx(FxKind.FIREBALL, false, false, 7),
        "Magierrüstung" to Fx(FxKind.MAGE_ARMOR, true, false, 7), "Heilige Flamme" to Fx(FxKind.SACRED_FLAME, false, false, 7),
        "Wunden heilen / Trank" to Fx(FxKind.HEAL, true, false, 7), "Segnen" to Fx(FxKind.BLESS, true, false, 7),
        "Untote vertreiben" to Fx(FxKind.TURN, false, false, 7), "Untote zerstören" to Fx(FxKind.DESTROY, false, false, 7),
        "Spirituelle Waffe" to Fx(FxKind.SPIRIT_WEAPON, false, false, 7), "Geisterwächter" to Fx(FxKind.GUARDIANS, true, false, 7),
        "Alchemistenfeuer" to Fx(FxKind.BOMB_FIRE, false, false, 7), "Weihwasser" to Fx(FxKind.BOMB_HOLY, false, false, 7),
    )
    val only = System.getenv("ABILITYFX")?.split(",")?.filter { it.isNotBlank() && it != "1" }
    val rows = if (only.isNullOrEmpty()) all else all.filter { (n, _) -> only.any { n.startsWith(it) } }
    val ps = if (only.isNullOrEmpty()) listOf(0.1f, 0.25f, 0.4f, 0.55f, 0.7f, 0.85f) else listOf(0.08f, 0.2f, 0.32f, 0.44f, 0.56f, 0.68f, 0.8f, 0.92f)
    val px = 1.5f
    val cw = 300; val ch = 280
    val look = de.bornim.core.MonsterLook(3)
    val frame = M.battleFrame("goblin", look, de.bornim.core.art.Act.IDLE, 0, 0)
    val (bodyW, bodyH) = M.bodySize("goblin", look, frame.width, frame.height)
    val scene = ImageComposeScene(cw * ps.size, ch * rows.size, Density(1f)) {
        Column(Modifier.background(Color(0xFF1E2A20))) {
            for ((name, fx) in rows) Row {
                for (p in ps) androidx.compose.foundation.layout.Box(Modifier.size(cw.dp, ch.dp).background(Color(0xFF34482F))) {
                    val feetX = cw * 0.72f; val feetY = ch * 0.62f
                    val heroX = cw * 0.18f; val heroY = ch * 0.97f
                    val anchor = (M.anchorX("goblin", frame.width) * px).toFloat(); val feet = (M.groundLine("goblin") * px).toFloat()
                    androidx.compose.foundation.layout.Box(Modifier.offset((feetX - anchor).dp, (feetY - feet).dp)) { de.bornim.game.ui.PixelSprite(frame, px.dp, overflow = true) }
                    Canvas(Modifier.size(cw.dp, ch.dp)) {
                        val enemy = Offset(feetX, feetY - (bodyH * px).toFloat() * 0.55f)
                        val hero = Offset(heroX, heroY - 110f)
                        drawRect(Color(0xFF8090A0), Offset(heroX - 14f, heroY - 190f), androidx.compose.ui.geometry.Size(28f, 190f))
                        val u = (bodyW * px).toFloat() / 90
                        val target = if (fx.onHero) hero else enemy
                        val source = if (fx.onHero) enemy else Offset(heroX + 10f, heroY - 150f)
                        drawFx(fx, p, source, target, u, if (fx.onHero) heroY else feetY, if (fx.onHero) feetY else heroY)
                    }
                    androidx.compose.material3.Text(if (p == ps[0]) name else "", color = Color.White, modifier = Modifier.offset(6.dp, 4.dp))
                }
            }
        }
    }
    val img = scene.render(0)
    File("build/screens/ability_fx.png").writeBytes(img.encodeToData(EncodedImageFormat.PNG)!!.bytes)
    scene.close()
    println("wrote ability fx")
}

/** Every lasting status on a goblin (three moments) and on the hero's place (three moments): STATUSFX=1. */
fun renderStatusFx() {
    val M = de.bornim.core.art.MonsterArt
    val px = 1.5f
    val cw = 220; val ch = 260
    val look = de.bornim.core.MonsterLook(3)
    val frame = M.battleFrame("goblin", look, de.bornim.core.art.Act.IDLE, 0, 0)
    val (bodyW, bodyH) = M.bodySize("goblin", look, frame.width, frame.height)
    val ts = listOf(0.4f, 1.3f, 2.2f)
    val scene = ImageComposeScene(cw * 6, ch * de.bornim.core.Status.entries.size, Density(1f)) {
        Column(Modifier.background(Color(0xFF1E2A20))) {
            for (s in de.bornim.core.Status.entries) Row {
                for (c in 0 until 6) androidx.compose.foundation.layout.Box(Modifier.size(cw.dp, ch.dp).background(Color(0xFF34482F))) {
                    val onFoe = c < 3
                    val feetX = cw * 0.5f; val feetY = ch * 0.9f
                    if (onFoe) {
                        val anchor = (M.anchorX("goblin", frame.width) * px).toFloat(); val feet = (M.groundLine("goblin") * px).toFloat()
                        androidx.compose.foundation.layout.Box(Modifier.offset((feetX - anchor).dp, (feetY - feet).dp)) { de.bornim.game.ui.PixelSprite(frame, px.dp, overflow = true) }
                    }
                    Canvas(Modifier.size(cw.dp, ch.dp)) {
                        val u = (bodyW * px).toFloat() / 90
                        if (!onFoe) drawRect(Color(0xFF8090A0), Offset(feetX - 14f, feetY - 190f), androidx.compose.ui.geometry.Size(28f, 190f))
                        val chest = if (onFoe) Offset(feetX, feetY - (bodyH * px).toFloat() * 0.55f) else Offset(feetX, feetY - 110f)
                        drawStatus(s, ts[c % 3], chest, feetY, if (onFoe) u else 1.6f, 2)
                    }
                    androidx.compose.material3.Text(if (c == 0) s.name else "", color = Color.White, modifier = Modifier.offset(6.dp, 4.dp))
                }
            }
        }
    }
    val img = scene.render(0)
    File("build/screens/status_fx.png").writeBytes(img.encodeToData(EncodedImageFormat.PNG)!!.bytes)
    scene.close()
    println("wrote status fx")
}
