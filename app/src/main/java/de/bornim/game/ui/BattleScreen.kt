package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Action
import de.bornim.core.Anim
import de.bornim.core.Battle
import de.bornim.core.Facing
import de.bornim.core.Game
import de.bornim.core.ItemKind
import de.bornim.core.Items
import de.bornim.core.Lang
import de.bornim.core.MapKind
import de.bornim.core.MonsterLook
import de.bornim.core.Outcome
import de.bornim.core.Rules
import de.bornim.core.Skill
import de.bornim.core.SkillCost
import de.bornim.core.Step
import de.bornim.core.Ui
import de.bornim.core.art.Act
import de.bornim.core.art.BattleArt
import de.bornim.core.art.BattleScene
import de.bornim.core.art.CharacterArt
import de.bornim.core.art.IconArt
import de.bornim.core.art.HeroArt
import de.bornim.core.art.MonsterArt
import de.bornim.core.art.Pose
import de.bornim.game.GameViewModel
import kotlinx.coroutines.delay
import kotlin.math.sin

private enum class BattleMenu { MAIN, SKILLS, BAG }

/** UI-side state of a battle: plays the log step by step and animates the numbers. */
private class BattleUi(val battle: Battle) {
    val queue = mutableStateListOf<Step>()
    var current by mutableStateOf<Step?>(null)
    var heroHp by mutableIntStateOf(battle.hero.hp)
    var heroSp by mutableIntStateOf(battle.hero.sp)
    var enemyHp by mutableIntStateOf(battle.enemyHp)
    var menu by mutableStateOf(BattleMenu.MAIN)
    var animKey by mutableIntStateOf(0)
    var enemyGone by mutableStateOf(false)
    var heroStatus by mutableStateOf<Map<de.bornim.core.Status, Int>>(emptyMap())
    var foeStatus by mutableStateOf<Map<de.bornim.core.Status, Int>>(emptyMap())
    var pack by mutableIntStateOf(battle.packSize)
    var packBefore by mutableIntStateOf(battle.packSize)
    var heroGone by mutableStateOf(false)
    /** Which attack animation the foe plays for its current attack. */
    var attackVariant by mutableIntStateOf(0)

    init {
        push(battle.start())
    }

    fun push(steps: List<Step>) {
        queue.addAll(steps)
        if (current == null) next()
    }

    fun next() {
        val s = if (queue.isEmpty()) null else queue.removeAt(0)
        current = s
        if (s != null) {
            heroHp = s.heroHp
            heroSp = s.heroSp
            enemyHp = s.enemyHp
            heroStatus = s.heroStatus
            foeStatus = s.foeStatus
            packBefore = pack
            pack = s.pack
            if (s.anim == Anim.ENEMY_FAINT) enemyGone = true
            if (s.anim == Anim.HERO_FAINT) heroGone = true
            if (s.anim == Anim.ENEMY_ACT) attackVariant = kotlin.random.Random.nextInt(MonsterArt.attackVariants(battle.monster.id))
            animKey++
        }
    }
}

@Composable
fun BattleScreen(vm: GameViewModel, game: Game, battle: Battle) {
    vm.tick
    val lang = vm.lang
    val ui = remember(battle) { BattleUi(battle) }
    val step = ui.current
    var revealed by remember(step) { mutableIntStateOf(0) }
    val textDone = step == null || revealed >= step.text.length

    LaunchedEffect(step) {
        if (step == null) return@LaunchedEffect
        while (revealed < step.text.length) {
            delay(16)
            revealed++
        }
    }

    fun advance() {
        if (step != null && !textDone) {
            revealed = step.text.length
            return
        }
        ui.next()
        if (ui.current == null && battle.outcome != Outcome.ONGOING) {
            game.endBattle()
            vm.refresh()
        }
    }

    fun act(action: Action) {
        ui.menu = BattleMenu.MAIN
        ui.push(battle.act(action))
        vm.refresh()
    }

    BackHandler { if (ui.menu != BattleMenu.MAIN) ui.menu = BattleMenu.MAIN }

    // Idle animation: monster and hero breathe in a slow loop of frames.
    var idle by remember { mutableIntStateOf(0) }
    LaunchedEffect(Unit) {
        while (true) {
            delay(230)
            idle++
        }
    }

    // Hit animations
    val shake = remember { Animatable(0f) }
    val intro = remember(battle) { Animatable(1f) }
    LaunchedEffect(battle) { intro.animateTo(0f, tween(600)) }
    LaunchedEffect(ui.animKey) {
        ui.current?.let { st -> soundFor(st)?.let { vm.play(it) } }
        shake.snapTo(0f)
        // Projectiles first have to fly; the target reacts when they arrive.
        val flight = when (ui.current?.fx?.kind) {
            de.bornim.core.FxKind.FIRE_BOLT, de.bornim.core.FxKind.MISSILES, de.bornim.core.FxKind.ARROW,
            de.bornim.core.FxKind.BOMB_FIRE, de.bornim.core.FxKind.BOMB_HOLY -> 0.5f
            de.bornim.core.FxKind.FIREBALL -> 0.45f
            else -> 0f
        }
        if (flight > 0f) kotlinx.coroutines.delay((fxDuration(ui.current!!.fx!!.kind) * flight).toLong())
        val an = ui.current?.anim
        when (an) {
            Anim.ENEMY_HIT, Anim.HERO_HIT, Anim.SPELL, Anim.LEVEL_UP, Anim.ENEMY_FAINT, Anim.HERO_FAINT, Anim.LOOT, Anim.MISS ->
                shake.animateTo(1f, tween(if (an == Anim.ENEMY_FAINT || an == Anim.HERO_FAINT) 700 else 450))
            Anim.HERO_ACT, Anim.ENEMY_ACT -> shake.animateTo(1f, tween(380))
            else -> {}
        }
    }
    val a = step?.anim
    val t = shake.value
    val blink = t in 0.01f..0.99f && ((t * 8).toInt() % 2 == 0)

    Column(Modifier.fillMaxSize().background(Colors.night)) {
        // --- Scene
        BoxWithConstraints(
            Modifier
                .fillMaxWidth()
                .weight(1f)
                .tap { advance() }
        ) {
            val sceneW = maxWidth
            val sceneH = maxHeight
            val fx = step?.fx
            // A dodging target hops aside.
            fun dodge(onHero: Boolean): androidx.compose.ui.unit.Dp {
                if (fx?.kind != de.bornim.core.FxKind.DODGE || fx.onHero != onHero || t !in 0.01f..0.99f) return 0.dp
                val side = if (fx.seed % 2 == 0) 1 else -1
                return (sin(t * Math.PI.toFloat()) * 26 * side).dp
            }
            val light = when {
                game.daylight < 0.35f -> BattleArt.Light.NIGHT
                game.daylight < 0.85f -> BattleArt.Light.DUSK
                else -> BattleArt.Light.DAY
            }
            // Forest fights use the new scenes: ground with depth, places and times of day.
            val forest = game.map.kind == MapKind.FOREST
            val place = game.state.place
            val spot = remember(battle) { BattleScene.spotFor(game.map, place.x, place.y) }
            val sceneSeed = remember(battle) { BattleScene.seedFor(place.x, place.y) }
            val sceneLight = when (light) {
                BattleArt.Light.NIGHT -> BattleScene.Light.NIGHT
                BattleArt.Light.DUSK -> BattleScene.Light.DUSK
                else -> BattleScene.Light.DAY
            }
            val density = androidx.compose.ui.platform.LocalDensity.current
            val sceneScale = with(density) { maxOf(1, kotlin.math.round(sceneW.toPx() / BattleScene.DESIGN_W).toInt()) }
            /** Size of one art pixel of the new scenes, in dp. */
            val artDp = with(density) { sceneScale.toDp() }
            if (forest) ForestBackground(spot, sceneLight, game.map.id == "deep_forest", sceneSeed, sceneScale, Modifier.matchParentSize())
            else BattleBackground(game.map.kind, light, Modifier.matchParentSize())
            val foeX = if (forest) BattleScene.FOE_X else BattleArt.ENEMY_X
            val foeY = if (forest) BattleScene.FOE_Y else BattleArt.ENEMY_Y
            val heroX = if (forest) BattleScene.HERO_X else BattleArt.HERO_X
            val heroY = if (forest) BattleScene.HERO_Y else BattleArt.HERO_Y
            val shade = when {
                game.map.kind == MapKind.CAVE -> null
                light == BattleArt.Light.NIGHT -> Color(0xFF9CA6D4)
                light == BattleArt.Light.DUSK -> Color(0xFFF4D2C4)
                else -> null
            }
            val shakeX = if (a == Anim.HERO_HIT && t < 0.99f) (sin(t * 40) * 8).dp else 0.dp

            val moving = t in 0.01f..0.99f
            val lunge = if (moving) sin(t * Math.PI.toFloat()) else 0f

            // Enemy
            val newStyle = MonsterArt.isNewStyle(battle.monster.id)
            val monsterSize = if (battle.monster.boss) 212.dp else 184.dp
            val enemyAlpha = when {
                a == Anim.ENEMY_FAINT -> 1f - t
                ui.enemyGone -> 0f
                else -> 1f
            }
            val enemyPose = when {
                a == Anim.ENEMY_ACT && moving -> Pose.ATTACK
                a == Anim.HERO_HIT && fx?.onHero == true && t < 0.5f -> Pose.ATTACK
                (a == Anim.ENEMY_HIT || a == Anim.ENEMY_FAINT) && moving -> Pose.HURT
                else -> Pose.IDLE
            }
            // New-style monsters play whole sequences: wind-up while attacking, the rest while the hit shows.
            val id = battle.monster.id
            val variant = ui.attackVariant
            val enemyFrame = if (!newStyle) null else {
                fun seq(act: Act, from: Int, to: Int) = MonsterArt.battleFrame(id, battle.look, act, variant, from + ((to - from + 1) * t).toInt().coerceAtMost(to - from))
                val strike = MonsterArt.strikeFrame(id, variant)
                val n = MonsterArt.frameCount(id, Act.ATTACK, variant)
                when {
                    a == Anim.ENEMY_ACT && moving -> seq(Act.ATTACK, 0, strike)
                    (a == Anim.HERO_HIT || a == Anim.MISS || a == Anim.HERO_FAINT) && fx?.onHero == true && moving -> seq(Act.ATTACK, strike, n - 1)
                    (a == Anim.ENEMY_HIT || a == Anim.ENEMY_FAINT) && moving -> seq(Act.HURT, 0, MonsterArt.frameCount(id, Act.HURT, 0) - 1)
                    a == Anim.PACK_ACT && moving -> seq(Act.HOWL, 0, MonsterArt.frameCount(id, Act.HOWL, 0) - 1)
                    else -> MonsterArt.battleFrame(id, battle.look, Act.IDLE, 0, idle % MonsterArt.frameCount(id, Act.IDLE, 0))
                }
            }
            val enemyDx = when {
                newStyle -> 0.dp
                a == Anim.ENEMY_ACT -> -(lunge * 30).dp
                a == Anim.ENEMY_HIT -> (lunge * 10 * (1 - t)).dp
                else -> 0.dp
            }
            val enemyDy = if (a == Anim.ENEMY_ACT && !newStyle) (lunge * 16).dp else 0.dp
            val foeW = if (enemyFrame != null) artDp * enemyFrame.width else monsterSize
            val foeH = if (enemyFrame != null) artDp * enemyFrame.height else monsterSize
            /** From the top of the picture down to the feet. */
            val foeFeet = if (enemyFrame != null) artDp * MonsterArt.groundLine(id).toFloat() else monsterSize * 0.94f
            // Shadows on the ground instead of platforms
            Canvas(Modifier.matchParentSize()) {
                val gx = (sceneW * foeX).toPx(); val gy = (sceneH * foeY).toPx()
                if (!ui.enemyGone) drawOval(Color.Black.copy(alpha = 0.32f * enemyAlpha), Offset(gx - foeW.toPx() * 0.36f, gy - 7.dp.toPx()), Size(foeW.toPx() * 0.72f, 12.dp.toPx()))
                val hx = (sceneW * heroX).toPx(); val hy = (sceneH * heroY).toPx()
                if (!ui.heroGone) drawOval(Color.Black.copy(alpha = 0.32f), Offset(hx - 70.dp.toPx(), hy - 10.dp.toPx()), Size(140.dp.toPx(), 18.dp.toPx()))
            }
            // Pack mates stand behind the leader, smaller, and jab when it is their turn.
            val fleeing = a == Anim.PACK_FLEE && moving
            val mateCount = if (fleeing) ui.packBefore else ui.pack
            val packDef = battle.pack
            if (packDef != null) for (i in 0 until mateCount) {
                val acting = a == Anim.PACK_ACT && step?.packActor == i && moving
                val mateLook = MonsterLook(battle.look.seed + 101 * (i + 1))
                val mateNew = MonsterArt.isNewStyle(packDef.mate)
                val mateFrame = if (!mateNew) null else if (acting) {
                    val n = MonsterArt.frameCount(packDef.mate, Act.ATTACK, i)
                    MonsterArt.battleFrame(packDef.mate, mateLook, Act.ATTACK, i, (n * t).toInt().coerceAtMost(n - 1))
                } else MonsterArt.battleFrame(packDef.mate, mateLook, Act.IDLE, 0, (idle + 2 * i + 1) % MonsterArt.frameCount(packDef.mate, Act.IDLE, 0))
                val mateSize = monsterSize * packDef.scale
                val mPx = artDp * packDef.scale
                val mateW = if (mateFrame != null) mPx * mateFrame.width else mateSize
                val mateFeet = if (mateFrame != null) mPx * MonsterArt.groundLine(packDef.mate).toFloat() else mateSize * 0.94f
                // A boss is big: its guards stand well to the left and just behind its shoulder,
                // so neither is hidden nor cut off by the screen edge.
                val boss = battle.monster.boss
                // New-style animals are wider, so their pack spreads out more and stands further back.
                val baseX = sceneW * foeX + when {
                    mateNew && i == 0 -> if (boss) (-150).dp else (-128).dp
                    mateNew -> if (boss) 96.dp else 78.dp
                    i == 0 -> if (boss) (-150).dp else (-86).dp
                    else -> if (boss) 24.dp else 56.dp
                }
                val baseY = sceneH * foeY - when {
                    mateNew && i == 0 -> if (boss) 22.dp else 30.dp
                    mateNew -> if (boss) 70.dp else 46.dp
                    i == 0 -> if (boss) 14.dp else 20.dp
                    else -> if (boss) 62.dp else 30.dp
                }
                Box(
                    Modifier.offset(
                        x = baseX - mateW / 2 + (intro.value * 260).dp + (if (acting && !mateNew) -(lunge * 26).dp else 0.dp) + (if (fleeing) (t * 140).dp else 0.dp),
                        y = baseY - mateFeet + (if (acting && !mateNew) (lunge * 12).dp else 0.dp),
                    )
                ) {
                    val mAlpha = (if (fleeing) 1f - t else 1f) * enemyAlphaBase(a, ui.enemyGone, t)
                    if (mateFrame != null) PixelSprite(mateFrame, mPx, alpha = mAlpha, shade = shade)
                    else PixelImageView(
                        MonsterArt.frame(packDef.mate, mateLook, if (acting) Pose.ATTACK else Pose.IDLE, idle + i + 1),
                        mateSize, alpha = mAlpha, shade = shade,
                    )
                }
            }

            val glow = battle.trait?.let { Color(it.color) }
            // Feet on the ground where the foe stands
            Box(
                Modifier.offset(
                    x = sceneW * foeX - foeW / 2 + (intro.value * 260).dp + dodge(false) + enemyDx,
                    y = sceneH * foeY - foeFeet + enemyDy + if (a == Anim.ENEMY_FAINT) (t * 40).dp else 0.dp,
                )
            ) {
                if (glow != null && !ui.enemyGone) {
                    // the aura is round: centre it on the body of the wider new-style sprites
                    if (newStyle) Box(Modifier.offset(y = (foeH - foeW) / 2)) { EliteAura(glow, foeW, enemyAlpha) }
                    else EliteAura(glow, monsterSize, enemyAlpha)
                }
                if (enemyFrame != null) PixelSprite(
                    enemyFrame, artDp, alpha = enemyAlpha,
                    flash = if (a == Anim.ENEMY_HIT && blink) 0.85f else 0f, shade = shade,
                ) else PixelImageView(
                    MonsterArt.frame(battle.monster.id, battle.look, enemyPose, idle),
                    monsterSize, alpha = enemyAlpha,
                    flash = if (a == Anim.ENEMY_HIT && blink) 0.85f else 0f, shade = shade,
                )
                if (battle.shiny && !ui.enemyGone) Sparkles(battle.look.seed, if (newStyle) foeW else monsterSize, enemyAlpha)
            }
            // Hero (seen from behind)
            val heroAlpha = when {
                a == Anim.HERO_FAINT -> 1f - t
                ui.heroGone -> 0f
                else -> 1f
            }
            val heroPose = when {
                (a == Anim.HERO_ACT || a == Anim.SPELL) && moving -> Pose.ATTACK
                a == Anim.ENEMY_HIT && fx?.onHero == false && t < 0.5f -> Pose.ATTACK
                (a == Anim.HERO_HIT || a == Anim.HERO_FAINT) && moving -> Pose.HURT
                else -> Pose.IDLE
            }
            val heroSize = 168.dp
            Box(
                Modifier.offset(
                    x = sceneW * heroX - heroSize / 2 + shakeX - (intro.value * 260).dp + dodge(true) +
                        (if (a == Anim.HERO_ACT) (lunge * 30).dp else 0.dp),
                    y = sceneH * heroY - heroSize * 0.97f - (if (a == Anim.HERO_ACT) (lunge * 16).dp else 0.dp),
                )
            ) {
                PixelImageView(
                    HeroArt.battle(battle.hero, heroPose, idle + 2), heroSize, alpha = heroAlpha,
                    flash = if (a == Anim.HERO_HIT && blink) 0.85f else 0f, shade = shade,
                )
            }

            // Attack and spell effects, and blood
            with(density) {
                val enemyC = Offset((sceneW * foeX).toPx(), (sceneH * foeY - (if (newStyle) foeFeet * 0.55f else monsterSize * 0.45f)).toPx())
                val heroC = Offset((sceneW * heroX).toPx(), (sceneH * heroY - heroSize * 0.5f).toPx())
                val unit = (if (newStyle) foeW / 90 else monsterSize / 64).toPx()
                BattleFxLayer(fx, ui.animKey, enemyC, heroC, unit, Modifier.matchParentSize())
                BloodLayer(a, fx, ui.animKey, enemyC, (sceneH * foeY).toPx(), heroC, (sceneH * heroY).toPx(), vm.bloodLevel, goreFor(id), (monsterSize / 64).toPx(), Modifier.matchParentSize())
            }

            EnemyBox(battle, ui.enemyHp, ui.foeStatus, lang, Modifier.align(Alignment.TopStart).padding(10.dp))
            HeroBox(battle, ui.heroHp, ui.heroSp, ui.heroStatus, lang, Modifier.align(Alignment.BottomEnd).padding(10.dp))

            // Flashes for spells and level ups
            val bigLoot = a == Anim.LOOT && (step?.rarity ?: de.bornim.core.Rarity.COMMON) >= de.bornim.core.Rarity.EPIC
            if ((a == Anim.SPELL || a == Anim.LEVEL_UP || bigLoot) && t in 0.01f..0.99f) {
                val c = if (a == Anim.SPELL) Color.White else Colors.gold
                Box(Modifier.matchParentSize().graphicsLayer { alpha = (1f - t) * 0.6f }.background(c))
            }
        }

        // --- Message / command area
        Box(
            Modifier
                .fillMaxWidth()
                .height(220.dp)
                .padding(8.dp)
        ) {
            if (step != null || battle.outcome != Outcome.ONGOING) {
                Panel(
                    Modifier
                        .fillMaxSize()
                        .tap { advance() }
                ) {
                    Txt(
                        step?.text?.take(revealed) ?: "", size = 20.sp,
                        color = step?.rarity?.let { rarityColor(it) } ?: Colors.text,
                    )
                    if (textDone) Txt("▼", Modifier.align(Alignment.BottomEnd), size = 16.sp, color = Colors.accent)
                }
            } else {
                when (ui.menu) {
                    BattleMenu.MAIN -> MainMenu(battle, lang, onAttack = { act(Action.Attack) }, onSkills = { ui.menu = BattleMenu.SKILLS },
                        onBag = { ui.menu = BattleMenu.BAG }, onFlee = { act(Action.Flee) })
                    BattleMenu.SKILLS -> SkillMenu(battle, lang, onPick = { act(Action.UseSkill(it)) }, onBack = { ui.menu = BattleMenu.MAIN })
                    BattleMenu.BAG -> BagMenu(game, lang, onPick = { act(Action.UseItem(it)) }, onBack = { ui.menu = BattleMenu.MAIN })
                }
            }
        }
    }
}

@Composable
private fun ForestBackground(spot: BattleScene.Spot, light: BattleScene.Light, deep: Boolean, seed: Int, scale: Int, modifier: Modifier) {
    Canvas(modifier) {
        val w = kotlin.math.ceil(size.width / scale).toInt()
        val h = kotlin.math.ceil(size.height / scale).toInt()
        val img = BattleScene.forest(w, h, spot, light, deep, seed)
        drawImage(
            image = Bitmaps.of(img),
            srcOffset = androidx.compose.ui.unit.IntOffset.Zero,
            srcSize = androidx.compose.ui.unit.IntSize(w, h),
            dstOffset = androidx.compose.ui.unit.IntOffset.Zero,
            dstSize = androidx.compose.ui.unit.IntSize(w * scale, h * scale),
            filterQuality = androidx.compose.ui.graphics.FilterQuality.None,
        )
    }
}

@Composable
private fun BattleBackground(kind: MapKind, light: BattleArt.Light, modifier: Modifier) {
    Canvas(modifier) {
        // Whole-number zoom for crisp pixels; the backdrop is generated to fill the scene.
        val scale = maxOf(1, (size.width / 170f).toInt())
        val w = kotlin.math.ceil(size.width / scale).toInt()
        val h = kotlin.math.ceil(size.height / scale).toInt()
        val img = BattleArt.background(kind, w, h, light)
        drawImage(
            image = Bitmaps.of(img),
            srcOffset = androidx.compose.ui.unit.IntOffset.Zero,
            srcSize = androidx.compose.ui.unit.IntSize(w, h),
            dstOffset = androidx.compose.ui.unit.IntOffset.Zero,
            dstSize = androidx.compose.ui.unit.IntSize(w * scale, h * scale),
            filterQuality = androidx.compose.ui.graphics.FilterQuality.None,
        )
    }
}

@Composable
private fun EnemyBox(battle: Battle, hp: Int, status: Map<de.bornim.core.Status, Int>, lang: Lang, modifier: Modifier) {
    val frac by animateFloatAsState(hp.toFloat() / battle.enemyMaxHp, tween(500), label = "enemyHp")
    val name = battle.foeName(lang)
    Panel(modifier.width(232.dp)) {
        Column {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Txt(name, Modifier.weight(1f), size = if (name.length > 17) 15.sp else 17.sp, bold = true, maxLines = if (name.length > 20) 2 else 1,
                    color = when {
                        battle.shiny -> Color(0xFF1E9EC8)
                        battle.trait != null -> Color(battle.trait!!.color).let { Color(it.red * 0.75f, it.green * 0.75f, it.blue * 0.75f) }
                        battle.elite -> rarityColor(de.bornim.core.Rarity.EPIC)
                        else -> Colors.text
                    })
                Txt("Lv.${battle.level}", size = 15.sp, bold = true)
            }
            Txt((if (lang == Lang.DE) "HG " else "CR ") + battle.monster.cr, size = 13.sp, color = Colors.textDim)
            Spacer(Modifier.height(3.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Txt(Ui.hp(lang), size = 12.sp, bold = true, color = Colors.accent)
                Spacer(Modifier.width(4.dp))
                Bar(frac, hpColor(frac), Modifier.fillMaxWidth())
            }
            StatusChips(status, lang)
        }
    }
}

/** Small colored tags for active statuses, with the rounds left. */
@Composable
private fun StatusChips(status: Map<de.bornim.core.Status, Int>, lang: Lang) {
    if (status.isEmpty()) return
    Row(Modifier.padding(top = 4.dp), horizontalArrangement = Arrangement.spacedBy(4.dp)) {
        status.forEach { (st, turns) ->
            Box(
                Modifier
                    .clip(androidx.compose.foundation.shape.RoundedCornerShape(4.dp))
                    .background(Color(st.color))
                    .padding(horizontal = 5.dp, vertical = 1.dp)
            ) { Txt(if (turns >= de.bornim.core.Status.LASTING) st.short(lang) else "${st.short(lang)} $turns", size = 11.sp, color = Color.White, bold = true, maxLines = 1) }
        }
    }
}

@Composable
private fun HeroBox(battle: Battle, hp: Int, sp: Int, status: Map<de.bornim.core.Status, Int>, lang: Lang, modifier: Modifier) {
    val hero = battle.hero
    val frac by animateFloatAsState(hp.toFloat() / hero.maxHp, tween(500), label = "heroHp")
    val shownHp by animateFloatAsState(hp.toFloat(), tween(500), label = "heroHpNum")
    Panel(modifier.width(210.dp)) {
        Column {
            Row {
                Txt(hero.name, Modifier.weight(1f), size = 17.sp, bold = true, maxLines = 1)
                Txt("Lv.${hero.level}", size = 15.sp, bold = true)
            }
            Row(verticalAlignment = Alignment.CenterVertically) {
                Txt(Ui.hp(lang), size = 12.sp, bold = true, color = Colors.accent)
                Spacer(Modifier.width(4.dp))
                Bar(frac, hpColor(frac), Modifier.fillMaxWidth())
            }
            Txt("${shownHp.toInt()} / ${hero.maxHp}", Modifier.align(Alignment.End), size = 14.sp, bold = true)
            if (hero.maxSp > 0) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Txt(Ui.sp(lang), size = 12.sp, bold = true, color = Colors.sp)
                    Spacer(Modifier.width(4.dp))
                    Bar(sp.toFloat() / hero.maxSp, Colors.sp, Modifier.weight(1f), 6.dp)
                    Spacer(Modifier.width(4.dp))
                    Txt("$sp", size = 12.sp)
                }
            }
            val next = Rules.xpToNext(hero.level)
            val prev = Rules.xpForLevel[hero.level]
            val xpFrac = if (next == null || de.bornim.core.Story.capped(battle.state)) 1f else (hero.xp - prev).toFloat() / (next - prev)
            Bar(xpFrac, Colors.xp, Modifier.fillMaxWidth().padding(top = 3.dp), 4.dp)
            val effects = buildList {
                if (battle.blessed) add(Skill.BLESS.title(lang))
                if (battle.mageArmor) add(Skill.MAGE_ARMOR.title(lang))
                if (battle.spiritualWeapon) add(Skill.SPIRITUAL_WEAPON.title(lang))
                if (battle.guardians) add(Skill.SPIRIT_GUARDIANS.title(lang))
            }
            if (effects.isNotEmpty()) Txt(effects.joinToString(" · "), size = 11.sp, color = Colors.sp)
            StatusChips(status, lang)
        }
    }
}

@Composable
private fun MainMenu(battle: Battle, lang: Lang, onAttack: () -> Unit, onSkills: () -> Unit, onBag: () -> Unit, onFlee: () -> Unit) {
    Panel(Modifier.fillMaxSize()) {
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Txt(Ui.whatWillDo.f(lang, battle.hero.name), size = 17.sp)
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                PixelButton(Ui.fight(lang), Modifier.weight(1f).height(60.dp), onClick = onAttack)
                PixelButton(Ui.skills(lang), Modifier.weight(1f).height(60.dp), onClick = onSkills)
            }
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                PixelButton(Ui.bag(lang), Modifier.weight(1f).height(60.dp), onClick = onBag)
                PixelButton(Ui.flee(lang), Modifier.weight(1f).height(60.dp), onClick = onFlee)
            }
        }
    }
}

@Composable
private fun SkillMenu(battle: Battle, lang: Lang, onPick: (Skill) -> Unit, onBack: () -> Unit) {
    val hero = battle.hero
    val skills = hero.cls.skills().filter { !it.passive && hero.has(it) }
    Panel(Modifier.fillMaxSize()) {
        Column {
            Column(
                Modifier
                    .weight(1f)
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(6.dp),
            ) {
                skills.forEach { s ->
                    val cost = when (s.cost) {
                        SkillCost.NONE -> Ui.unlimited(lang)
                        SkillCost.SPELL_POINTS -> "${s.amount} ${Ui.sp(lang)}"
                        SkillCost.PER_BATTLE -> Ui.usesLeft.f(lang, battle.usesLeft(s) ?: 0, s.amount)
                        SkillCost.PASSIVE -> ""
                    }
                    val reason = battle.blocked(s)
                    PixelButton("${s.title(lang)}  ·  $cost", Modifier.fillMaxWidth(), enabled = reason == null, size = 16.sp) { onPick(s) }
                }
                Txt(skills.joinToString("\n") { "${it.title(lang)}: ${it.desc(lang)}" }, size = 13.sp, color = Colors.textDim)
            }
            Spacer(Modifier.height(6.dp))
            BackRow(Ui.back(lang), onBack)
        }
    }
}

@Composable
private fun BagMenu(game: Game, lang: Lang, onPick: (String) -> Unit, onBack: () -> Unit) {
    val usable = game.state.inventory.entries.filter { Items[it.key].kind == ItemKind.POTION || Items[it.key].kind == ItemKind.BOMB }
    Panel(Modifier.fillMaxSize()) {
        Column {
            Column(
                Modifier
                    .weight(1f)
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(6.dp),
            ) {
                if (usable.isEmpty()) Txt(Ui.nothing(lang), color = Colors.textDim)
                usable.forEach { (id, count) ->
                    val def = Items[id]
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        PixelImageView(IconArt.get(def.icon), 32.dp)
                        Spacer(Modifier.width(6.dp))
                        PixelButton("${def.name(lang)} ×$count", Modifier.weight(1f), size = 16.sp) { onPick(id) }
                    }
                }
            }
            Spacer(Modifier.height(6.dp))
            BackRow(Ui.back(lang), onBack)
        }
    }
}

/** Mates stay while the leader fades out on its defeat (they flee with their own animation). */
private fun enemyAlphaBase(a: Anim?, gone: Boolean, t: Float): Float = if (gone && a != Anim.ENEMY_FAINT && a != Anim.PACK_FLEE) 0f else 1f

/** Pulsing glow in the elite's trait color behind the monster. */
@Composable
private fun EliteAura(color: Color, size: androidx.compose.ui.unit.Dp, alpha: Float) {
    val pulse by androidx.compose.animation.core.rememberInfiniteTransition(label = "aura").animateFloat(
        0f, 1f,
        androidx.compose.animation.core.infiniteRepeatable(tween(1100), androidx.compose.animation.core.RepeatMode.Reverse),
        label = "pulse",
    )
    Canvas(Modifier.width(size).height(size)) {
        val c = Offset(this.size.width / 2, this.size.height * 0.58f)
        val r = this.size.width * (0.42f + 0.05f * pulse)
        drawCircle(
            Brush.radialGradient(listOf(color.copy(alpha = (0.55f + 0.25f * pulse) * alpha), color.copy(alpha = 0f)), c, r),
            r, c,
        )
    }
}

/** Twinkling stars around a shimmering monster. */
@Composable
private fun Sparkles(seed: Int, size: androidx.compose.ui.unit.Dp, alpha: Float) {
    val time by androidx.compose.animation.core.rememberInfiniteTransition(label = "sparkle").animateFloat(
        0f, 1f,
        androidx.compose.animation.core.infiniteRepeatable(tween(1800, easing = androidx.compose.animation.core.LinearEasing)),
        label = "time",
    )
    Canvas(Modifier.width(size).height(size)) {
        val r = kotlin.random.Random(seed)
        val u = this.size.width / 64f
        repeat(6) { i ->
            val x = (12 + r.nextFloat() * 40) * u
            val y = (10 + r.nextFloat() * 44) * u
            val p = (time + i / 6f) % 1f
            val s = sin(p * Math.PI.toFloat()) * 2.6f * u
            if (s <= 0.2f) return@repeat
            val c = listOf(Color.White, Color(0xFFFFF2A0), Color(0xFFA0F0FF))[i % 3].copy(alpha = alpha)
            drawRect(c, Offset(x - s / 4, y - s), Size(s / 2, s * 2))
            drawRect(c, Offset(x - s, y - s / 4), Size(s * 2, s / 2))
        }
    }
}
