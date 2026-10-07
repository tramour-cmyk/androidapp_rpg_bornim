package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import de.bornim.core.audio.Sound
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
import androidx.compose.ui.layout.onSizeChanged
import de.bornim.core.art.Act
import de.bornim.core.art.BattleArt
import de.bornim.core.art.BattleScene
import de.bornim.core.art.CaveScene
import de.bornim.core.art.Glow
import de.bornim.core.art.CharacterArt
import de.bornim.core.art.IconArt
import de.bornim.core.art.HeroBattle
import de.bornim.core.art.HeroFigure
import de.bornim.core.art.MonsterArt
import de.bornim.core.art.Pose
import de.bornim.game.GameViewModel
import kotlinx.coroutines.delay
import kotlin.math.sin

private enum class BattleMenu { MAIN, FIGHT, SKILLS, BAG }

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
    /** A foe built in the round is falling: the next message waits until it lies on the ground. */
    var falling by mutableStateOf(false)
    var heroStatus by mutableStateOf<Map<de.bornim.core.Status, Int>>(emptyMap())
    var foeStatus by mutableStateOf<Map<de.bornim.core.Status, Int>>(emptyMap())
    var pack by mutableIntStateOf(battle.packSize)
    var packBefore by mutableIntStateOf(battle.packSize)
    var heroGone by mutableStateOf(false)
    /** Which attack animation the foe plays for its current attack. */
    var attackVariant by mutableIntStateOf(0)
    /** Counts the leader's howls; [howlStart] is when the latest began, [howlSound] which voice it uses. */
    var howlKey by mutableIntStateOf(0)
    var howlStart = 0L
    var howlSound = Sound.HOWL_1
    private val howls = MonsterArt.isNewStyle(battle.monster.id) && battle.monster.id.contains("wolf")

    /**
     * What the hero's doll is playing: frames [from]..[to] of an act over [ms] from [start], then back to rest unless it
     * [hold]s. A [lead] is played before it starts: the way down out of a held guard. From frame [slowFrom] on each
     * frame takes [slowK] times as long: a blow struck fast, the step back after it taken at ease.
     */
    class HeroMotion(val act: HeroFigure.Act, val strike: HeroFigure.Strike, val variant: Int, val from: Int, val to: Int, val start: Long, val ms: Long, val hold: Boolean = false, val lead: HeroMotion? = null,
        val slowFrom: Int = Int.MAX_VALUE, val slowK: Double = 1.0) {
        /** The frame shown [now]. */
        fun index(now: Long): Int {
            val el = (now - start).toDouble()
            if (el <= 0) return from
            val fast = (minOf(slowFrom, to + 1) - from).coerceAtLeast(0)
            val slow = (to + 1 - maxOf(slowFrom, from)).coerceAtLeast(0)
            val per = ms / (fast + slow * slowK)
            val i = if (el < fast * per) from + (el / per).toInt() else maxOf(slowFrom, from) + ((el - fast * per) / (per * slowK)).toInt()
            return i.coerceIn(from, to)
        }
    }
    var motion by mutableStateOf<HeroMotion?>(null)
    private var blows = 0
    /** Which victory pose this fight ends in. */
    val victoryPick = kotlin.random.Random.nextInt(8)
    /** The swing to sound with a blow, after [swingDelay] ms; set when a blow starts. */
    var swingKey by mutableIntStateOf(0)
    var swingDelay = 0L
    /** A spell or shot let go with this message: from which act it leaves the hero, and how long until it does. */
    var release by mutableStateOf<Pair<HeroFigure.Act, Int>?>(null)
    var fxDelay = 0L
    /** Counts spells let go, for the flash of light at the staff or hand. */
    var flashKey by mutableIntStateOf(0)

    /** The last frame before a blow lands: a blade still coming down, an arrow still on the string. */
    private fun windUpEnd(strike: HeroFigure.Strike) = HeroBattle.strikeFrame(strike) - (if (strike == HeroFigure.Strike.SHOOT) 1 else 2)

    private fun play(act: HeroFigure.Act, strike: HeroFigure.Strike = HeroFigure.Strike.SLASH, variant: Int = 0, from: Int = 0, to: Int = -1, perFrame: Long = 60, delayMs: Long = 0, hold: Boolean = false,
        slowFrom: Int = Int.MAX_VALUE, slowK: Double = 1.0) {
        val n = HeroBattle.frameCount(battle.hero, act, strike, variant)
        val end = if (to < 0) n - 1 else to.coerceAtMost(n - 1)
        val now = System.currentTimeMillis()
        // out of a held guard the shield or weapon first comes down smoothly to the rest, then the next move begins;
        // being struck breaks the guard faster
        val m = motion
        val lead = if (m != null && m.hold && m.act == HeroFigure.Act.BLOCK && act != HeroFigure.Act.BLOCK) {
            val last = HeroBattle.frameCount(battle.hero, m.act, m.strike, m.variant) - 1
            val per = if (act == HeroFigure.Act.HURT) 28L else 45L
            HeroMotion(m.act, m.strike, m.variant, m.to, last, now, (last - m.to + 1) * per)
        } else null
        val start = maxOf(now + delayMs, (lead?.let { it.start + it.ms } ?: 0L))
        val slowN = (end + 1 - maxOf(slowFrom, from)).coerceAtLeast(0)
        val ms = ((end - from + 1 - slowN) * perFrame + slowN * perFrame * slowK).toLong()
        motion = HeroMotion(act, strike, variant, from, end, start, ms, hold, lead, slowFrom, slowK)
    }

    /** Sets the doll going for a new message: blows, spells, hits, blocks, the start of the fight and the victory. */
    private fun moveHero(s: Step) {
        val hero = battle.hero
        val m = motion
        val fx = s.fx
        // a spell with several bolts (the three scorching rays): each further one leaves the same staff or hand,
        // with a short thrust of the spell again
        val again = release?.takeIf { (act, _) -> act == HeroFigure.Act.CAST && fx != null && !fx.onHero && s.anim != Anim.SPELL && s.anim != Anim.HERO_ACT &&
            (fx.kind in FLYING || fx.past in FLYING) }
        release = null
        fxDelay = 0L
        if (again != null) {
            val hit = HeroBattle.strikeFrame(HeroFigure.Strike.CAST)
            play(HeroFigure.Act.CAST, HeroFigure.Strike.CAST, again.second, hit - 1, hit + 1, perFrame = 50)
            release = again
            fxDelay = 50L
            flashKey++
            return
        }
        // still waiting for a blow that never came: the hero's own move starts from the rest
        if (m != null && m.act == HeroFigure.Act.AMBUSHED && m.hold && s.anim in HERO_MOVES) motion = null
        when {
            // ambushed: still facing us, the hero is caught from behind by the foe's first blow, staggers and only then
            // turns to it; struck down by it, the hero stays down in the stagger
            s.anim == Anim.HERO_FAINT && m != null && m.act == HeroFigure.Act.AMBUSHED ->
                play(HeroFigure.Act.AMBUSHED, to = AMBUSH_DOWN, perFrame = 130, hold = true)
            m != null && m.act == HeroFigure.Act.AMBUSHED && m.hold &&
                (s.anim == Anim.HERO_HIT || (s.anim == Anim.MISS && fx?.onHero == true)) ->
                play(HeroFigure.Act.AMBUSHED, perFrame = 120)
            s.anim == Anim.HERO_ACT -> {
                val list = HeroBattle.strikes(hero)
                val strike = list[blows++ % list.size]
                // while the attack is named, only the wind-up: the blow comes with the hit or the miss
                play(HeroFigure.Act.ATTACK, strike, 0, 0, windUpEnd(strike), perFrame = 55, hold = true)
            }
            (s.anim == Anim.ENEMY_HIT || s.anim == Anim.ENEMY_FAINT || s.anim == Anim.MISS) && fx?.onHero == false &&
                m != null && m.act == HeroFigure.Act.ATTACK && m.hold -> {
                play(HeroFigure.Act.ATTACK, m.strike, 0, m.to, -1, perFrame = 55, slowFrom = HeroBattle.strikeFrame(m.strike) + 1, slowK = MOVE_SLOW)
                if (m.strike != HeroFigure.Strike.SHOOT) { swingDelay = 0L; swingKey++ }
                // the arrow or bolt leaves the bow on the frame the string is let go
                else { release = HeroFigure.Act.ATTACK to 0; fxDelay = (HeroBattle.strikeFrame(m.strike) - m.to) * 55L }
            }
            // a flask: drawn back while it is named, thrown with the next message
            s.anim == Anim.THROW -> play(HeroFigure.Act.THROW, HeroFigure.Strike.CAST, HeroBattle.throwVariant(hero), 0, HeroBattle.strikeFrame(HeroFigure.Strike.CAST) - 1, perFrame = 50, hold = true)
            m != null && m.act == HeroFigure.Act.THROW && m.hold && (fx != null || s.anim != Anim.NONE) -> {
                play(HeroFigure.Act.THROW, HeroFigure.Strike.CAST, m.variant, m.to, -1, perFrame = 50)
                release = HeroFigure.Act.THROW to m.variant
                fxDelay = (HeroBattle.strikeFrame(HeroFigure.Strike.CAST) - m.to) * 50L
            }
            // while the spell is named, it gathers and glows; it is let go with its effect on the next message
            s.anim == Anim.SPELL -> play(HeroFigure.Act.CAST, HeroFigure.Strike.CAST, HeroBattle.castVariant(hero), 0, HeroBattle.strikeFrame(HeroFigure.Strike.CAST) - 1, perFrame = 50, hold = true)
            m != null && m.act == HeroFigure.Act.CAST && m.hold && (fx != null || s.anim != Anim.NONE) -> {
                play(HeroFigure.Act.CAST, HeroFigure.Strike.CAST, m.variant, m.to, -1, perFrame = 50)
                // the spell leaves the staff, wand or hand on the frame it is let go, in a flash of light
                release = HeroFigure.Act.CAST to m.variant
                fxDelay = (HeroBattle.strikeFrame(HeroFigure.Strike.CAST) - m.to) * 50L
                flashKey++
            }
            // struck through the guard: the guard holds until the hero's next turn, as the defence does; the blow shows
            // in the flash of the hit
            s.anim == Anim.HERO_HIT && m != null && m.act == HeroFigure.Act.BLOCK && m.hold -> {}
            s.anim == Anim.HERO_HIT -> play(HeroFigure.Act.HURT, perFrame = 95)
            s.anim == Anim.HERO_FAINT -> play(HeroFigure.Act.HURT, to = 3, perFrame = 130, hold = true)
            // the defensive stance: up into the guard, held until the hero's next turn
            // a draught drunk on guard: the guard comes down first
            s.anim == Anim.HERO_HEAL && m != null && m.act == HeroFigure.Act.BLOCK && m.hold -> play(HeroFigure.Act.IDLE, from = 0, to = 0)
            // already on guard: it simply stays up
            s.anim == Anim.DEFEND && m != null && m.act == HeroFigure.Act.BLOCK && m.hold -> {}
            s.anim == Anim.DEFEND -> play(HeroFigure.Act.BLOCK, variant = HeroBattle.blockVariant(hero, battle.monster.id), from = 0, to = 7, perFrame = 70, hold = true)
            // fended off from the guard: the guard stays up
            s.anim == Anim.MISS && fx?.onHero == true && m != null && m.act == HeroFigure.Act.BLOCK && m.hold -> {}
            s.anim == Anim.MISS && fx?.onHero == true &&
                (fx.kind == de.bornim.core.FxKind.BLOCK || HeroBattle.outfit(hero).twoHands) ->
                play(HeroFigure.Act.BLOCK, variant = HeroBattle.blockVariant(hero, battle.monster.id), perFrame = 70)
            enemyGone && s.anim != Anim.ENEMY_FAINT && m?.act != HeroFigure.Act.VICTORY ->
                play(HeroFigure.Act.VICTORY, variant = HeroBattle.variant(hero, HeroFigure.Act.VICTORY, battle.monster.id, victoryPick), perFrame = 70, delayMs = 250, hold = true)
        }
    }

    init {
        // the fight begins with the hero facing us and turning to the foe; in an ambush the hero stays facing us,
        // unaware, until the foe's blow lands from behind
        if (battle.opening == de.bornim.core.Opening.AMBUSHED) play(HeroFigure.Act.AMBUSHED, from = 0, to = 0, hold = true)
        else play(HeroFigure.Act.TURN, perFrame = 90, delayMs = 700)
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
            moveHero(s)
            if (s.anim == Anim.ENEMY_ACT) attackVariant = kotlin.random.Random.nextInt(MonsterArt.attackVariants(battle.monster.id))
            // Wolves howl now and then, not every time: when they appear, and when a pack mate falls or flees.
            val chance = when {
                animKey == 0 -> 0.5
                s.anim == Anim.PACK_FLEE -> 0.6
                else -> 0.0
            }
            if (howls && !enemyGone && kotlin.random.Random.nextDouble() < chance) {
                howlStart = System.currentTimeMillis()
                howlSound = listOf(Sound.HOWL_1, Sound.HOWL_2, Sound.HOWL_3).random()
                howlKey++
            }
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
        // a fall is not cut short: it plays out before the next message
        if (ui.falling) return
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
    LaunchedEffect(ui.howlKey) {
        if (ui.howlKey == 0) return@LaunchedEffect
        // the sound starts once the head is raised
        delay(HOWL_RAISE_MS)
        vm.play(ui.howlSound)
    }
    // the swish of a blow, as the weapon comes down: heavier for great weapons and hammers
    LaunchedEffect(ui.swingKey) {
        if (ui.swingKey == 0) return@LaunchedEffect
        delay(ui.swingDelay)
        val w = battle.hero.item(de.bornim.core.GearSlot.MAIN_HAND)?.def
        val heavy = w != null && (w.twoHanded || w.icon == de.bornim.core.Icon.HAMMER || w.icon == de.bornim.core.Icon.MACE)
        vm.play(if (heavy) Sound.SWING_HEAVY else Sound.SWING)
    }
    LaunchedEffect(ui.animKey) {
        ui.current?.let { st -> soundFor(st)?.let { vm.play(it) } }
        shake.snapTo(0f)
        // Projectiles first have to fly; the target reacts when they arrive.
        val flight = when (ui.current?.fx?.let { f -> f.past?.takeIf { it in FLYING && (f.kind == de.bornim.core.FxKind.DODGE || f.kind == de.bornim.core.FxKind.BLOCK) } ?: f.kind }) {
            de.bornim.core.FxKind.FIRE_BOLT, de.bornim.core.FxKind.MISSILES, de.bornim.core.FxKind.ARROW,
            de.bornim.core.FxKind.BOMB_FIRE, de.bornim.core.FxKind.BOMB_HOLY -> 0.5f
            de.bornim.core.FxKind.FIREBALL -> 0.45f
            else -> 0f
        }
        if (ui.fxDelay > 0) kotlinx.coroutines.delay(ui.fxDelay)
        if (flight > 0f) kotlinx.coroutines.delay((fxDuration(ui.current!!.fx!!.kind) * flight).toLong())
        // a foe built in the round falls only once its fall is drawn: the killing blow waits for the first frames of it,
        // the defeat for all of them (drawn now if the background has not got to them yet), so it never just stands and fades
        val foeId = battle.monster.id
        val cur = ui.current
        val fall = cur != null && cur.anim == Anim.ENEMY_FAINT && MonsterArt.isSolid(foeId)
        if (fall) ui.falling = true
        try {
            if (cur != null && MonsterArt.isSolid(foeId) && (cur.anim == Anim.ENEMY_FAINT || (cur.anim == Anim.ENEMY_HIT && cur.enemyHp <= 0))) {
                val dieV = MonsterArt.dieVariant(foeId, battle.look)
                val n = MonsterArt.frameCount(foeId, battle.look, Act.DIE, dieV)
                val upTo = if (cur.anim == Anim.ENEMY_FAINT) n - 1 else DIE_REEL.coerceAtMost(n - 1)
                kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Default) {
                    for (i in 0..upTo) MonsterArt.battleFrame(foeId, battle.look, Act.DIE, dieV, i)
                }
            }
            val an = ui.current?.anim
            when (an) {
                Anim.ENEMY_HIT, Anim.HERO_HIT, Anim.SPELL, Anim.LEVEL_UP, Anim.ENEMY_FAINT, Anim.HERO_FAINT, Anim.LOOT, Anim.MISS ->
                    // a foe on the doll takes its time to fall before it fades
                    shake.animateTo(1f, tween(when {
                        an == Anim.ENEMY_FAINT && MonsterArt.isSolid(battle.monster.id) -> 1400
                        an == Anim.ENEMY_FAINT || an == Anim.HERO_FAINT -> 700
                        // being struck, ducking aside and the step back after a blow are taken at ease
                        an == Anim.ENEMY_HIT || an == Anim.HERO_HIT || an == Anim.MISS -> REACT_MS
                        else -> 450
                    }))
                Anim.HERO_ACT, Anim.ENEMY_ACT -> shake.animateTo(1f, tween(380))
                else -> {}
            }
        } finally {
            if (fall) ui.falling = false
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
            // Forest and cave fights use the new scenes: ground with depth, places, times of day or lights.
            val forest = game.map.kind == MapKind.FOREST
            val cave = game.map.kind == MapKind.CAVE
            val newScene = forest || cave
            val place = game.state.place
            val caveSpot = remember(battle) { if (cave) CaveScene.spotFor(game.map, place.x, place.y) else CaveScene.Spot.HALL }
            val caveLight = remember(battle) { if (cave) CaveScene.lightFor(game.map, place.x, place.y, caveSpot) else CaveScene.Light.TORCH }
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
            else if (cave) CaveBackground(caveSpot, caveLight, sceneSeed, light == BattleArt.Light.NIGHT, sceneScale, Modifier.matchParentSize())
            else BattleBackground(game.map.kind, light, Modifier.matchParentSize())
            val foeX = if (newScene) BattleScene.FOE_X else BattleArt.ENEMY_X
            val foeY = if (newScene) BattleScene.FOE_Y else BattleArt.ENEMY_Y
            val heroX = if (newScene) BattleScene.HERO_X else BattleArt.HERO_X
            val heroY = if (newScene) BattleScene.HERO_Y else BattleArt.HERO_Y
            // Monsters and hero stand in the light of the place.
            val shade = when {
                cave -> Color(CaveScene.tint(caveSpot, caveLight, light == BattleArt.Light.NIGHT))
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
            // foes built in the round (on the doll, or wolves) fall in their own way first, then fade; the others fade as they sink
            val dollFoe = MonsterArt.isSolid(battle.monster.id)
            val enemyAlpha = when {
                a == Anim.ENEMY_FAINT -> if (dollFoe) 1f - ((t - 0.75f) / 0.25f).coerceIn(0f, 1f) else 1f - t
                ui.enemyGone -> 0f
                else -> 1f
            }
            // the foe's own blow landing on the hero, or missing: the second half of its attack
            val foeLanding = (a == Anim.HERO_HIT || a == Anim.MISS || a == Anim.HERO_FAINT) && fx?.onHero == true && (step?.packActor ?: -1) < 0
            // old-style foes, like the hero: while the attack is named they leap in and stay poised, then strike and
            // spring back with the hit or the miss
            val leap = if (t >= 0.99f) 1f else (t * t * (3 - 2 * t))
            val foeIn = when {
                a == Anim.ENEMY_ACT -> leap
                foeLanding -> 1f - leap
                else -> 0f
            }
            val enemyPose = when {
                a == Anim.ENEMY_ACT -> Pose.ATTACK
                foeLanding && t < 0.5f -> Pose.ATTACK
                (a == Anim.ENEMY_HIT || a == Anim.ENEMY_FAINT) && moving -> Pose.HURT
                else -> Pose.IDLE
            }
            // New-style monsters play whole sequences: wind-up while attacking, the rest while the hit shows.
            val id = battle.monster.id
            val variant = ui.attackVariant
            // How badly the foe is hurt: 1 below half its hit points, 2 below a quarter.
            val foeWound = when {
                ui.enemyHp * 4 <= battle.enemyMaxHp -> 2
                ui.enemyHp * 2 <= battle.enemyMaxHp -> 1
                else -> 0
            }
            // How much of it shows, for foe and hero alike: nothing with blood off, a few stains when subtle, all of them in full
            val woundCap = vm.bloodLevel.coerceIn(0, 2)
            val foeStains = minOf(foeWound, woundCap)
            // Overlays (wounds, glow, sheen) stay while the foe sinks down and fade with it.
            val foeShown = !ui.enemyGone || a == Anim.ENEMY_FAINT
            // Hurt monsters breathe faster. New-style monsters have many more idle frames, shown faster.
            val clockMs = pulseClock()
            val idleIdx = (clockMs / ((if (newStyle) 86 else 230) / (1 + 0.6 * foeWound))).toInt()
            // Draw all frames ahead in the background: at the start, and again once the foe is badly hurt.
            LaunchedEffect(battle, foeWound) {
                kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Default) {
                    MonsterArt.prepare(id, battle.look, foeWound)
                    battle.trait?.let { tr ->
                        if (newStyle) for (act in Act.entries) for (v in 0 until (if (act == Act.ATTACK) MonsterArt.attackVariants(id) else if (act == Act.IDLE || act == Act.HOWL) 1 else MonsterArt.reactVariants(id)))
                            for (i in 0 until MonsterArt.frameCount(id, battle.look, act, v)) {
                                val f = MonsterArt.battleFrame(id, battle.look, act, v, i, foeWound)
                                Glow.halo(f, tr.color and 0xFFFFFF); Glow.rim(f, tr.color and 0xFFFFFF)
                            }
                    }
                    battle.pack?.let { pk -> for (i in 0 until battle.packSize) MonsterArt.prepare(pk.mate, MonsterLook(battle.look.seed + 101 * (i + 1))) }
                }
            }
            val howling = ui.howlKey > 0 && !ui.enemyGone && System.currentTimeMillis() - ui.howlStart < HOWL_MS
            // the leader's own blow: wound up while it is named, then struck with the hit or the miss. A foe on the doll
            // holds its wind-up two frames short of the blow, so the blow itself comes with the result, as the hero's does.
            val foeStrike = if (newStyle) MonsterArt.strikeFrame(id, battle.look, variant) else 0
            val foeN = if (newStyle) MonsterArt.frameCount(id, battle.look, Act.ATTACK, variant) else 0
            val windEnd = if (dollFoe) (foeStrike - 2).coerceAtLeast(0) else foeStrike
            fun span(from: Int, to: Int) = from + ((to - from + 1) * t).toInt().coerceAtMost(to - from)
            val foeAttackIdx: Int? = when {
                !newStyle -> null
                a == Anim.ENEMY_ACT -> span(0, windEnd)
                foeLanding && moving -> {
                    // the blow lands as fast as ever; only the way back takes the longer time
                    val q = ((foeStrike - windEnd + 1).toFloat() / (foeN - windEnd)) * 450f / REACT_MS
                    if (t < q) windEnd + ((foeStrike - windEnd + 1) * t / q).toInt().coerceAtMost(foeStrike - windEnd)
                    else foeStrike + ((foeN - foeStrike) * (t - q) / (1 - q)).toInt().coerceIn(0, foeN - 1 - foeStrike)
                }
                // the blow not begun yet (an arrow still in flight): still poised in the wind-up, not back at rest
                foeLanding && t < 0.01f -> windEnd
                else -> null
            }
            val enemyFrame = if (!newStyle) null else {
                fun seq(act: Act, from: Int, to: Int, v: Int = variant) = MonsterArt.shownFrame(id, battle.look, act, v, from + ((to - from + 1) * t).toInt().coerceAtMost(to - from), foeWound)
                val strike = foeStrike
                val n = foeN
                // being hit, dodging and falling come in variants too, taken in turn
                val react = ui.animKey.mod(MonsterArt.reactVariants(id))
                fun whole(act: Act) = seq(act, 0, MonsterArt.frameCount(id, battle.look, act, react) - 1, react)
                // one fall for this foe, begun with the killing blow (it reels) and ended with its defeat (it goes down)
                val dieV = MonsterArt.dieVariant(id, battle.look)
                val dieLast = MonsterArt.frameCount(id, battle.look, Act.DIE, dieV) - 1
                val reel = DIE_REEL.coerceAtMost(dieLast)
                when {
                    // the wind-up, held poised until the blow lands with the next message; then the blow
                    foeAttackIdx != null -> MonsterArt.shownFrame(id, battle.look, Act.ATTACK, variant, foeAttackIdx, foeWound)
                    // struck down: it reels with the blow and stays reeling through any further word, never getting up again
                    // (each message's motion starts at 0 and may wait, for a spell to be let go: until it starts, the picture
                    // stays where the last one left it, so nothing jumps ahead to the end and back)
                    dollFoe && ui.enemyHp <= 0 && a != Anim.ENEMY_FAINT && !ui.enemyGone -> when {
                        a != Anim.ENEMY_HIT || t >= 0.99f -> seq(Act.DIE, reel, reel, dieV)
                        t < 0.01f -> seq(Act.DIE, 0, 0, dieV)
                        else -> seq(Act.DIE, 0, reel, dieV)
                    }
                    // falling: from the reel on to the ground (from the start if nothing struck it down first), then held while it fades
                    a == Anim.ENEMY_FAINT && dollFoe -> {
                        val from = if (fx?.kind == de.bornim.core.FxKind.TURN) 0 else reel
                        when {
                            t >= 0.99f -> seq(Act.DIE, dieLast, dieLast, dieV)
                            t < 0.01f -> seq(Act.DIE, from, from, dieV)
                            else -> seq(Act.DIE, from, dieLast, dieV)
                        }
                    }
                    // a blow or a spell turned aside: the foe ducks, steps back or springs aside, or takes it on its shield
                    a == Anim.MISS && fx?.onHero == false && dollFoe && moving -> whole(Act.DODGE)
                    (a == Anim.ENEMY_HIT || a == Anim.ENEMY_FAINT) && moving -> if (dollFoe) whole(Act.HURT) else seq(Act.HURT, 0, MonsterArt.frameCount(id, Act.HURT, 0) - 1)
                    howling -> {
                        val n = MonsterArt.frameCount(id, Act.HOWL, 0)
                        val since = System.currentTimeMillis() - ui.howlStart
                        // raise the head, hold the howl, lower it again
                        val i = when {
                            since < HOWL_RAISE_MS -> (since * 4 / HOWL_RAISE_MS).toInt()
                            since < HOWL_MS - 150 -> 4 + ((since - HOWL_RAISE_MS) * 6 / (HOWL_MS - 150 - HOWL_RAISE_MS)).toInt()
                            else -> n - 1
                        }
                        MonsterArt.shownFrame(id, battle.look, Act.HOWL, 0, i.coerceIn(0, n - 1), foeWound)
                    }
                    else -> MonsterArt.shownFrame(id, battle.look, Act.IDLE, 0, idleIdx % MonsterArt.frameCount(id, battle.look, Act.IDLE, 0), foeWound)
                }
            }
            val enemyDx = when {
                newStyle -> 0.dp
                a == Anim.ENEMY_HIT -> (lunge * 10 * (1 - t)).dp
                else -> -(foeIn * 30).dp
            }
            val enemyDy = if (!newStyle) (foeIn * 16).dp else 0.dp
            /** How wide the foe's body is (a doll's picture is far wider than the doll), for its shadow, effects and the lunge. */
            val body = enemyFrame?.let { MonsterArt.bodySize(id, battle.look, it.width, it.height) }
            val foeW = if (body != null) artDp * body.first.toFloat() else monsterSize
            val foeH = if (enemyFrame != null) artDp * enemyFrame.height else monsterSize
            /** From the top of the picture down to the feet. */
            val foeFeet = if (enemyFrame != null) artDp * MonsterArt.groundLine(id).toFloat() else monsterSize * 0.94f
            /** How tall the foe stands above its feet. */
            val foeTall = if (body != null) artDp * body.second.toFloat() else foeFeet
            /** From the picture's left edge to the feet. */
            val foeAnchor = if (enemyFrame != null) artDp * MonsterArt.anchorX(id, enemyFrame.width).toFloat() else monsterSize / 2
            // Shadows on the ground instead of platforms
            Canvas(Modifier.matchParentSize()) {
                val gx = (sceneW * foeX).toPx(); val gy = (sceneH * foeY).toPx()
                if (foeShown) drawOval(Color.Black.copy(alpha = 0.32f * enemyAlpha), Offset(gx - foeW.toPx() * 0.36f, gy - 7.dp.toPx()), Size(foeW.toPx() * 0.72f, 12.dp.toPx()))
                val hx = (sceneW * heroX).toPx(); val hy = (sceneH * heroY).toPx()
                if (!ui.heroGone) drawOval(Color.Black.copy(alpha = 0.32f), Offset(hx - 70.dp.toPx(), hy - 10.dp.toPx()), Size(140.dp.toPx(), 18.dp.toPx()))
            }
            // Pack mates stand behind the leader, smaller, and jab when it is their turn.
            val fleeing = a == Anim.PACK_FLEE && moving
            val mateCount = if (fleeing) ui.packBefore else ui.pack
            val packDef = battle.pack
            if (packDef != null) for (i in 0 until mateCount) {
                val acting = a == Anim.PACK_ACT && step?.packActor == i
                // the mate's own hit or miss right after its attack: the strike and the way back
                val landing = (a == Anim.HERO_HIT || a == Anim.MISS || a == Anim.HERO_FAINT) && step?.packActor == i && moving
                val mateIn = when { acting -> leap; landing -> 1f - leap; else -> 0f }
                val mateLook = MonsterLook(battle.look.seed + 101 * (i + 1))
                val mateNew = MonsterArt.isNewStyle(packDef.mate)
                val mateFrame = if (!mateNew) null else if (acting || landing) {
                    val n = MonsterArt.frameCount(packDef.mate, mateLook, Act.ATTACK, i)
                    val strike = MonsterArt.strikeFrame(packDef.mate, mateLook, i)
                    val (from, to) = if (acting) 0 to strike else strike to n - 1
                    MonsterArt.shownFrame(packDef.mate, mateLook, Act.ATTACK, i, from + ((to - from + 1) * t).toInt().coerceAtMost(to - from))
                } else MonsterArt.shownFrame(packDef.mate, mateLook, Act.IDLE, 0, (clockMs / 86 + 5 * i + 3).toInt() % MonsterArt.frameCount(packDef.mate, mateLook, Act.IDLE, 0))
                val mateSize = monsterSize * packDef.scale
                val mPx = artDp * packDef.scale
                val mateW = if (mateFrame != null) mPx * mateFrame.width else mateSize
                val mateAnchor = if (mateFrame != null) mPx * MonsterArt.anchorX(packDef.mate, mateFrame.width).toFloat() else mateSize / 2
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
                        // old-style mates leap in while their attack is named and spring back with the hit or the miss
                        x = baseX - mateAnchor + (intro.value * 260).dp + (if (!mateNew) -(mateIn * 26).dp else 0.dp) + (if (fleeing) (t * 140).dp else 0.dp),
                        y = baseY - mateFeet + (if (!mateNew) (mateIn * 12).dp else 0.dp),
                    )
                ) {
                    val mAlpha = (if (fleeing) 1f - t else 1f) * enemyAlphaBase(a, ui.enemyGone, t)
                    if (mateFrame != null) PixelSprite(mateFrame, mPx, alpha = mAlpha, shade = shade, overflow = true)
                    else PixelImageView(
                        MonsterArt.frame(packDef.mate, mateLook, if (acting || landing && t < 0.5f) Pose.ATTACK else Pose.IDLE, idle + i + 1),
                        mateSize, alpha = mAlpha, shade = shade,
                    )
                }
            }

            val glow = battle.trait?.let { Color(it.color) }
            // a foe on the doll steps in at the hero with its blow, so the weapon lands on the hero, and back again;
            // drawn larger as it comes nearer
            val foeLungeF = if (dollFoe && foeAttackIdx != null) {
                // while it is named it only starts the step; the rest comes with the blow
                MonsterArt.lungeAt(id, battle.look, variant, foeAttackIdx).toFloat() * (if (a == Anim.ENEMY_ACT) FOE_WIND_STEP else 1f)
            } else 0f
            val foeLunge = if (foeLungeF <= 0f || enemyFrame == null) androidx.compose.ui.unit.DpOffset.Zero else {
                val (ox, oy) = MonsterArt.lungeOffset(id, battle.look, variant, (sceneW * foeX / artDp).toDouble(), (sceneH * foeY / artDp).toDouble(),
                    (sceneW * heroX / artDp).toDouble() + 8.0, (sceneH * heroY / artDp).toDouble() - 82.0)
                androidx.compose.ui.unit.DpOffset(artDp * (ox * foeLungeF).toFloat(), artDp * (oy * foeLungeF).toFloat())
            }
            val foeScale = 1f + (MonsterArt.LUNGE_SCALE.toFloat() - 1f) * foeLungeF
            // Feet on the ground where the foe stands
            Box(
                Modifier.offset(
                    // a foe on the doll steps aside in its own frames rather than hopping
                    x = sceneW * foeX - foeAnchor + (intro.value * 260).dp + (if (dollFoe) 0.dp else dodge(false)) + enemyDx + foeLunge.x,
                    // old-style sprites sag a little when badly hurt; new ones change their posture
                    y = sceneH * foeY - foeFeet + enemyDy + (if (a == Anim.ENEMY_FAINT && !dollFoe) (t * 40).dp else 0.dp) + (if (newStyle) 0.dp else (foeWound * 3).dp) + foeLunge.y,
                ).graphicsLayer {
                    if (foeScale != 1f && enemyFrame != null) {
                        scaleX = foeScale; scaleY = foeScale
                        transformOrigin = androidx.compose.ui.graphics.TransformOrigin((MonsterArt.anchorX(id, enemyFrame.width) / enemyFrame.width).toFloat(), (MonsterArt.groundLine(id) / enemyFrame.height).toFloat())
                    }
                }
            ) {
                val pulse = rememberPulse()
                // New-style elites shimmer along their outline; the old sprites keep the round aura.
                if (glow != null && foeShown && enemyFrame != null) Box(Modifier.offset(x = -artDp * Glow.PAD, y = -artDp * Glow.PAD)) {
                    PixelSprite(Glow.halo(enemyFrame, battle.trait!!.color and 0xFFFFFF), artDp, alpha = enemyAlpha * (0.55f + 0.4f * pulse), overflow = true)
                } else if (glow != null && foeShown) EliteAura(glow, monsterSize, enemyAlpha)
                if (enemyFrame != null) {
                    PixelSprite(
                        enemyFrame, artDp, alpha = enemyAlpha,
                        flash = if (a == Anim.ENEMY_HIT && blink) 0.85f else 0f, shade = shade, overflow = true,
                    )
                    if (glow != null && foeShown) PixelSprite(Glow.rim(enemyFrame, battle.trait!!.color and 0xFFFFFF), artDp, alpha = enemyAlpha * (0.22f + 0.18f * pulse), overflow = true)
                    if (foeStains > 0 && foeShown) PixelSprite(woundsOf(enemyFrame, foeStains, id, battle.look.seed), artDp, alpha = enemyAlpha, shade = shade, overflow = true)
                    // a band of light wanders over a shimmering coat every few seconds
                    if (battle.shiny && foeShown) {
                        val steps = 12
                        val phase = ((pulseClock() / 120) % 30).toInt()
                        if (phase < steps) PixelSprite(Glow.sheen(enemyFrame, phase, steps), artDp, alpha = enemyAlpha * 0.75f, overflow = true)
                    }
                } else {
                    val img = MonsterArt.frame(battle.monster.id, battle.look, enemyPose, if (foeWound > 0) idleIdx else idle)
                    PixelImageView(img, monsterSize, alpha = enemyAlpha, flash = if (a == Anim.ENEMY_HIT && blink) 0.85f else 0f, shade = shade)
                    if (foeStains > 0 && foeShown) PixelImageView(woundsOf(img, foeStains, id, battle.look.seed), monsterSize, alpha = enemyAlpha, shade = shade)
                }
                if (battle.shiny && foeShown) {
                    // sparkles around the body: centre their square on the wide new-style sprite
                    // foes built in the round stand off-centre in a wide frame: the sparkles go round the body, about its feet
                    if (dollFoe) Box(Modifier.offset(x = foeAnchor - foeW * (if (MonsterArt.isBeast(id)) 0.58f else 0.5f), y = foeFeet - foeTall / 2 - foeW / 2)) { Sparkles(battle.look.seed, foeW, enemyAlpha) }
                    else if (newStyle) Box(Modifier.offset(y = (foeH - foeW) / 2 - foeH * 0.22f)) { Sparkles(battle.look.seed, foeW, enemyAlpha) }
                    else Sparkles(battle.look.seed, monsterSize, enemyAlpha)
                }
            }
            // Hero (seen from behind)
            val heroAlpha = when {
                a == Anim.HERO_FAINT -> 1f - t
                ui.heroGone -> 0f
                else -> 1f
            }
            // The hero is the doll, seen from behind over the shoulder, its frames drawn ahead in the background.
            // the hero bleeds like the foe: a few stains below half health, more below a quarter, as far as the blood setting shows
            val heroWound = minOf(woundCap, when {
                ui.heroHp * 4 <= battle.hero.maxHp -> 2
                ui.heroHp * 2 <= battle.hero.maxHp -> 1
                else -> 0
            })
            LaunchedEffect(battle, heroWound) {
                kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Default) {
                    val job = coroutineContext[kotlinx.coroutines.Job]
                    HeroBattle.prepare(battle.hero, battle.monster.id, battle.opening == de.bornim.core.Opening.AMBUSHED, ui.victoryPick, heroWound,
                        ui.motion?.takeIf { it.hold }?.let { Triple(it.act, it.strike, it.variant) }) { job?.isActive == false }
                }
            }
            val doll = heroDollFrame(ui, clockMs, heroWound)
            val dollFrame = doll.first
            // a melee blow steps in towards the foe, so the weapon lands on it, and back again
            val lungeF = doll.second.toFloat()
            val lungeOff = if (lungeF <= 0f || ui.motion == null) androidx.compose.ui.unit.DpOffset.Zero
            // the old village and house scenes have their foe far off up the field: only a short step forward there
            else if (!newScene) androidx.compose.ui.unit.DpOffset((lungeF * 30).dp, -(lungeF * 16).dp)
            else {
                val aim = HeroBattle.aimAt((sceneW * foeX / artDp).toDouble(), (sceneH * foeY / artDp).toDouble(), (foeW / artDp).toDouble(), (foeTall / artDp).toDouble())
                val (ox, oy) = HeroBattle.lungeOffset(battle.hero, ui.motion!!.strike, (sceneW * heroX / artDp).toDouble(), (sceneH * heroY / artDp).toDouble(), aim.first, aim.second)
                androidx.compose.ui.unit.DpOffset(artDp * (ox * lungeF).toFloat(), artDp * (oy * lungeF).toFloat())
            }
            val lungeScale = if (newScene) 1f - (1f - HeroBattle.LUNGE_SCALE.toFloat()) * lungeF else 1f
            Box(
                Modifier
                    .offset(
                        x = sceneW * heroX - artDp * HeroBattle.ANCHOR_X.toFloat() + shakeX - (intro.value * 260).dp + dodge(true) + lungeOff.x,
                        y = sceneH * heroY - artDp * HeroBattle.GROUND.toFloat() + lungeOff.y,
                    )
                    .graphicsLayer {
                        scaleX = lungeScale; scaleY = lungeScale
                        transformOrigin = androidx.compose.ui.graphics.TransformOrigin((HeroBattle.ANCHOR_X / HeroBattle.W).toFloat(), (HeroBattle.GROUND / HeroBattle.H).toFloat())
                    }
            ) {
                PixelSprite(dollFrame, artDp, alpha = heroAlpha, flash = if (a == Anim.HERO_HIT && blink) 0.85f else 0f, shade = shade)
            }
            // Attack and spell effects, and blood
            with(density) {
                val enemyC = Offset((sceneW * foeX).toPx(), (sceneH * foeY - (if (newStyle) foeTall * 0.55f else monsterSize * 0.45f)).toPx())
                // the doll stands about 130 art pixels tall: spells and blows start from its chest
                val heroC = Offset((sceneW * heroX).toPx(), (sceneH * heroY - artDp * 78f).toPx())
                val unit = (if (newStyle) foeW / 90 else monsterSize / 64).toPx()
                // a spell or shot starts where it leaves the hero: the staff's crystal, the wand, the hand, the bow
                val launch = ui.release?.let { (act, v) -> HeroBattle.launch(battle.hero, act, v) }
                val launchC = launch?.let {
                    Offset((sceneW * heroX + artDp * (it.x - HeroBattle.ANCHOR_X).toFloat()).toPx(), (sceneH * heroY + artDp * (it.y - HeroBattle.GROUND).toFloat()).toPx())
                }
                val source = if (launchC != null && fx?.onHero == false) launchC else heroC
                BattleFxLayer(fx, ui.animKey, enemyC, source, unit, Modifier.matchParentSize(), startDelay = ui.fxDelay)
                if (launchC != null && ui.release?.first == HeroFigure.Act.CAST) CastFlash(ui.flashKey, launchC, Color(0xFF000000 or launch.rgb.toLong()), artDp.toPx(), ui.fxDelay, Modifier.matchParentSize())
                BloodLayer(
                    a, fx, ui.animKey, enemyC, (sceneH * foeY).toPx(), heroC, (sceneH * heroY).toPx(), vm.bloodLevel, goreFor(id), (monsterSize / 64).toPx(),
                    foeHurt = 1f - ui.enemyHp.toFloat() / battle.enemyMaxHp, heroHurt = 1f - ui.heroHp.toFloat() / battle.hero.maxHp, modifier = Modifier.matchParentSize(),
                )
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
                    BattleMenu.MAIN -> MainMenu(battle, lang, onAttack = { ui.menu = BattleMenu.FIGHT }, onSkills = { ui.menu = BattleMenu.SKILLS },
                        onBag = { ui.menu = BattleMenu.BAG }, onFlee = { act(Action.Flee) })
                    BattleMenu.FIGHT -> FightMenu(battle, lang, onAttack = { act(Action.Attack) }, onDefend = { act(Action.Defend) }, onBack = { ui.menu = BattleMenu.MAIN })
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

/** The cave is lit pixel by pixel, which takes a moment: it is drawn in the background and fades in. */
@Composable
private fun CaveBackground(spot: CaveScene.Spot, light: CaveScene.Light, seed: Int, night: Boolean, scale: Int, modifier: Modifier) {
    var dims by remember { mutableStateOf(androidx.compose.ui.unit.IntSize.Zero) }
    var img by remember { mutableStateOf<de.bornim.core.art.PixelImage?>(null) }
    LaunchedEffect(dims, spot, light, seed, night) {
        if (dims.width > 0) img = kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Default) { CaveScene.cave(dims.width, dims.height, spot, light, seed, night) }
    }
    Canvas(modifier.onSizeChanged { dims = androidx.compose.ui.unit.IntSize(kotlin.math.ceil(it.width / scale.toFloat()).toInt(), kotlin.math.ceil(it.height / scale.toFloat()).toInt()) }) {
        drawRect(Color(0xFF07080C))
        val pic = img ?: return@Canvas
        drawImage(
            image = Bitmaps.of(pic),
            srcOffset = androidx.compose.ui.unit.IntOffset.Zero,
            srcSize = androidx.compose.ui.unit.IntSize(pic.width, pic.height),
            dstOffset = androidx.compose.ui.unit.IntOffset.Zero,
            dstSize = androidx.compose.ui.unit.IntSize(pic.width * scale, pic.height * scale),
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

/** Fighting: strike, or take a defensive stance until the next turn (the foe attacks at a disadvantage; a miss opens a counter). */
@Composable
private fun FightMenu(battle: Battle, lang: Lang, onAttack: () -> Unit, onDefend: () -> Unit, onBack: () -> Unit) {
    val de = lang == Lang.DE
    Panel(Modifier.fillMaxSize()) {
        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                PixelButton(if (de) "Angreifen" else "Attack", Modifier.weight(1f).height(56.dp), onClick = onAttack)
                PixelButton(if (de) "Abwehr" else "Defend", Modifier.weight(1f).height(56.dp), onClick = onDefend)
            }
            Txt(
                if (battle.counter) (if (de) "Konter bereit: der nächste Angriff hat Vorteil." else "Counter ready: the next attack has advantage.")
                else if (de) "Abwehr: Bis zum nächsten Zug greift der Gegner mit Nachteil an. Verfehlt er, bietet sich ein Konter: der nächste Angriff hat Vorteil."
                else "Defend: until your next turn the foe attacks at a disadvantage. If it misses, you may counter: your next attack has advantage.",
                size = 13.sp, color = if (battle.counter) Colors.accent else Colors.textDim,
            )
            PixelButton(if (de) "Zurück" else "Back", Modifier.fillMaxWidth().height(40.dp), size = 14.sp, onClick = onBack)
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
                        SupplyPicture(def.id, 32.dp)
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
/** Stains on a hurt monster in the color of what it bleeds; skeletons crack instead. */
private fun woundsOf(img: de.bornim.core.art.PixelImage, wound: Int, id: String, seed: Int): de.bornim.core.art.PixelImage {
    val gore = goreFor(id)
    val c = (gore.main.red * 255).toInt() shl 16 or ((gore.main.green * 255).toInt() shl 8) or (gore.main.blue * 255).toInt()
    return Glow.wounds(img, wound, c, seed, cracks = gore == Gore.BONE)
}

/** 0..1 and back, slowly, for glowing things. */
@Composable
private fun rememberPulse(): Float {
    val p by androidx.compose.animation.core.rememberInfiniteTransition(label = "glow").animateFloat(
        0f, 1f,
        androidx.compose.animation.core.infiniteRepeatable(tween(1100), androidx.compose.animation.core.RepeatMode.Reverse),
        label = "pulse",
    )
    return p
}

/** The frame of a fall at which the foe has taken the killing blow and reels, before it goes down. */
private const val DIE_REEL = 4
/** The ambushed hero's last frame of the stagger, before the turn to the foe begins. */
private const val AMBUSH_DOWN = 7
/** How long being struck, ducking aside and the step back after a blow take, in ms (the blows themselves keep their pace). */
private const val REACT_MS = 750
/** How much slower than the blow the hero steps back after it. */
private const val MOVE_SLOW = 1.6
/** What the hero does on the hero's own turn. */
private val HERO_MOVES = setOf(Anim.HERO_ACT, Anim.SPELL, Anim.THROW, Anim.DEFEND, Anim.HERO_HEAL)

/** How far into its step a foe on the doll goes while its attack is named: the rest of the step comes with the blow. */
private const val FOE_WIND_STEP = 0.45f

/** How long the leader's howl animation runs, and how long it takes to raise its head. */
private const val HOWL_MS = 1900L
private const val HOWL_RAISE_MS = 330L

/** Milliseconds that keep counting, to drive slow effects. */
@Composable
private fun pulseClock(): Long {
    var now by remember { androidx.compose.runtime.mutableLongStateOf(0L) }
    LaunchedEffect(Unit) {
        val start = System.currentTimeMillis()
        while (true) {
            delay(33)
            now = System.currentTimeMillis() - start
        }
    }
    return now
}

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


/**
 * The doll's frame for this moment: the act it is playing, or its rest. A frame not drawn yet is stood in for by the
 * nearest earlier one of the same act, then by the rest, which is drawn at once if need be.
 */
private fun heroDollFrame(ui: BattleUi, clockMs: Long, wounds: Int): Pair<de.bornim.core.art.PixelImage, Double> {
    val hero = ui.battle.hero
    val now = System.currentTimeMillis()
    val m = ui.motion
    // the way down out of a guard, before the next move starts
    m?.lead?.takeIf { now < m.start }?.let { l ->
        val i = (l.from + ((l.to - l.from + 1) * ((now - l.start).toDouble() / l.ms)).toInt()).coerceIn(l.from, l.to)
        for (k in i downTo l.from) HeroBattle.ready(hero, l.act, l.strike, l.variant, k, wounds)?.let { return it to 0.0 }
    }
    if (m != null) {
        val p = (now - m.start).toDouble() / m.ms
        if (p < 1.0 || m.hold) {
            val i = m.index(now)
            // how far the blow has stepped in, by the frame it has reached
            val lunge = if (m.act == HeroFigure.Act.ATTACK) HeroBattle.lungeAt(hero, m.strike, i) else 0.0
            for (k in i downTo m.from) HeroBattle.ready(hero, m.act, m.strike, m.variant, k, wounds)?.let { return it to lunge }
            // a held pose (a guard, a wind-up) never falls back to the rest: drawn now if no frame of it is kept
            if (m.hold && now >= m.start) return HeroBattle.frame(hero, m.act, m.strike, m.variant, i, wounds) to lunge
        }
    }
    val idle = (clockMs / 110).toInt()
    val img = HeroBattle.ready(hero, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, idle, wounds)
        ?: HeroBattle.ready(hero, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, 0, wounds)
        ?: HeroBattle.frame(hero, HeroFigure.Act.IDLE, HeroFigure.Strike.SLASH, 0, 0)
    return img to 0.0
}


/** A burst of light where a spell leaves the hero: bright at once, then fading and widening. */
@Composable
private fun CastFlash(key: Int, at: Offset, colour: Color, px: Float, delayMs: Long, modifier: Modifier) {
    val p = remember(key) { Animatable(0f) }
    LaunchedEffect(key) {
        delay(delayMs)
        p.animateTo(1f, tween(260, easing = androidx.compose.animation.core.LinearEasing))
    }
    val t = p.value
    if (t <= 0f || t >= 1f) return
    Canvas(modifier) {
        val fade = 1f - t
        drawCircle(colour.copy(alpha = 0.35f * fade), radius = px * (10f + 16f * t), center = at)
        drawCircle(colour.copy(alpha = 0.7f * fade), radius = px * (5f + 6f * t), center = at)
        drawCircle(Color.White.copy(alpha = 0.9f * fade), radius = px * (2.5f + 2f * t), center = at)
    }
}
