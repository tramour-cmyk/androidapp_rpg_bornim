package preview

import android.app.Application
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.ImageComposeScene
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.input.pointer.PointerEventType
import androidx.compose.ui.unit.Density
import de.bornim.core.*
import de.bornim.game.GameViewModel
import de.bornim.game.ui.BattleClock
import de.bornim.game.ui.BornimApp
import org.jetbrains.skia.EncodedImageFormat
import java.io.File

/**
 * Films a fight through the real UI in real time: a frame every ~80 ms after each tap, for checking that the hero's
 * moves run as meant (FILM=cleric:zombie, FILMWAIT=ms before the first tap, FILMSEED=dice seed).
 */
/** One film: who fights whom, at which level, with which dice, what is done, into which folder. */
class FilmSpec(
    val name: String, val spec: String, val level: Int? = null, val seed: Int = 1, val plan: String = "FASSSS",
    val actions: List<Action> = emptyList(), val hurt: Boolean = false, val heroFirst: Boolean = false,
    val auto: Boolean = false, val wait: Long = 4000L,
    val heroStatus: List<Status> = emptyList(), val foeStatus: List<Status> = emptyList(),
    val failSaves: Boolean = false, val race: Race = Race.HUMAN, val place: String = "forest",
    /** Every weapon blow of the hero that hits is critical; the blood level (0 off, 1 subtle, 2 full); the weapon in hand. */
    val crits: Boolean = false, val blood: Int? = null, val weapon: String? = null,
    /** The killing blow to show (KILL_HIGH, KILL_PIERCE, KILL_RISE, KILL_SPIN), when the weapon has it. */
    val kill: String? = null,
)

/** The env-driven single film (FILM=…), into build/screens/film. */
fun fightFilm(spec: String) = film(FilmSpec(
    "film", spec, System.getenv("FILMLEVEL")?.toInt(), System.getenv("FILMSEED")?.toInt() ?: 1, System.getenv("FILMTAPS") ?: "FASSSS",
    hurt = System.getenv("FILMHURT") != null, heroFirst = System.getenv("FILMFIRST") != null, auto = System.getenv("FILMAUTO") != null,
    wait = System.getenv("FILMWAIT")?.toLong() ?: 4000L,
), File("build/screens/film"))

/** An action named in a batch line: attack, defend, skill=TURN_UNDEAD, item=holy_water. */
fun parseAction(s: String): Action = when {
    s == "attack" -> Action.Attack
    s == "defend" -> Action.Defend
    s.startsWith("skill=") -> Action.UseSkill(Skill.valueOf(s.removePrefix("skill=")))
    s.startsWith("item=") -> Action.UseItem(s.removePrefix("item="))
    else -> error("unknown action $s")
}

/**
 * Many films in one run (FILMBATCH=file): one line each, `name class:foe level seed plan [actions]`, for instance
 * `holy cleric:zombie 5 1 XWW item=holy_water`. The hero strikes first and starts hurt, with potions and flasks, and
 * the fight text runs on by itself;
 * X does the next action straight away, without tapping through the menus. Each film goes into its own folder.
 */
fun fightBatch(file: String) {
    for (line in File(file).readLines().map { it.trim() }.filter { it.isNotEmpty() && !it.startsWith("#") }) {
        val w = line.split(Regex("\\s+"))
        // optional words after the plan: actions (attack,skill=…), hero=POISON+BLEED, foe=BURN
        val extra = w.drop(5)
        fun statuses(k: String) = extra.firstOrNull { it.startsWith("$k=") }?.removePrefix("$k=")?.split("+")?.map { Status.valueOf(it) } ?: emptyList()
        val acts = extra.firstOrNull { !it.startsWith("hero=") && !it.startsWith("foe=") && it != "foefirst" && it != "failsaves" && it != "crits" && !it.startsWith("race=") && !it.startsWith("place=") && !it.startsWith("blood=") && !it.startsWith("weapon=") && !it.startsWith("kill=") }?.split(",")?.map(::parseAction) ?: emptyList()
        film(FilmSpec(w[0], w[1], w[2].toInt(), w[3].toInt(), w[4], acts,
            hurt = true, heroFirst = "foefirst" !in extra, auto = true, failSaves = "failsaves" in extra, wait = 1500L, heroStatus = statuses("hero"), foeStatus = statuses("foe"),
            race = extra.firstOrNull { it.startsWith("race=") }?.let { Race.valueOf(it.removePrefix("race=")) } ?: Race.HUMAN,
            place = extra.firstOrNull { it.startsWith("place=") }?.removePrefix("place=") ?: "forest",
            crits = "crits" in extra, blood = extra.firstOrNull { it.startsWith("blood=") }?.removePrefix("blood=")?.toInt(),
            weapon = extra.firstOrNull { it.startsWith("weapon=") }?.removePrefix("weapon="),
            kill = extra.firstOrNull { it.startsWith("kill=") }?.removePrefix("kill=")), File("build/screens/films/${w[0]}"))
    }
}

@OptIn(ExperimentalComposeUiApi::class)
fun film(f: FilmSpec, outDir: File) {
    val (clsName, foe) = f.spec.split(":")
    val out = outDir.apply { deleteRecursively(); mkdirs() }
    val vm = GameViewModel(Application())
    vm.newGame("Test", f.race, CharClass.valueOf(clsName.uppercase()))
    if (f.auto && !vm.battleAuto) vm.toggleBattleAuto()
    val g = vm.game!!
    var guard = 0
    while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
    f.level?.let { g.state.hero.gainXp(Rules.xpForLevel[it]); g.state.hero.restoreFully() }
    g.state.place = Place(f.place, 10, if (f.place == "forest") 20 else 10, Facing.UP); g.state.minutes = 12 * 60
    // the hero starts the fight hurt, with a few potions and flasks of each kind
    if (f.hurt) {
        g.state.hero.hp = maxOf(1, g.state.hero.maxHp / 3)
        listOf("greater_potion", "potion", "remedy", "alchemist_fire", "holy_water").forEach { g.state.add(it, 2) }
    }
    f.weapon?.let { g.state.hero.equip(Gear(9_999L, it, Rarity.COMMON, 1)) }
    val seed = f.seed
    val battle = Battle(g.state, Monsters[foe], g.lang, Dice(kotlin.random.Random(seed)), 1, false, 1, null, false, MonsterLook(seed),
        if (f.heroFirst) Opening.HERO_FIRST else Opening.NORMAL)
    Battle.foesFailSaves = f.failSaves
    Battle.heroCritsAlways = f.crits
    de.bornim.core.art.HeroBattle.killForTest = f.kill?.let { de.bornim.core.art.HeroFigure.Strike.valueOf(it) }
    f.blood?.let { vm.changeBlood(it) }
    f.heroStatus.forEach { battle.heroStatus[it] = 9 }
    f.foeStatus.forEach { battle.foeStatus[it] = 9 }
    g.fight(battle)
    vm.refresh()
    val actions = ArrayDeque(f.actions)
    // FILMSTEP=ms between frames (80 by default; finer, say 40, to judge how smoothly a move runs). The film runs on
    // its own clock (BattleClock), as fast as the frames can be drawn: every wait of the battle and every animation
    // follows it, and the same seed gives the same pictures. FILMREAL=1 films on the wall clock as before.
    val stepMs = System.getenv("FILMSTEP")?.toLong() ?: 80L
    val real = System.getenv("FILMREAL") != null
    val t0 = System.nanoTime()
    // a clock well away from 0, since the battle reads 0 as "not yet"; set before the scene is made, which
    // already starts the battle's first waits
    var clock = 1_000_000L
    val start = clock
    if (!real) {
        BattleClock.now = { clock }
        BattleClock.random = kotlin.random.Random(f.seed * 7919L + 1)
        Battle.fxRandom = kotlin.random.Random(f.seed * 104_729L + 3)
        if (System.getenv("FILMSERIAL") != null) de.bornim.core.art.SdfRender.PARALLEL = false
    }
    val scene = ImageComposeScene(540, 1170, Density(1.375f)) { BornimApp(vm) }
    var n = 0
    var drawNs = 0L; var waitNs = 0L; var saveNs = 0L
    // FROM=s: save pictures only from this second of the film on (the clock still runs through the start);
    // CROP=x0:y0:x1:y1 saves only that part of the 540×1170 picture
    val fromMs = ((System.getenv("FROM")?.toDouble() ?: 0.0) * 1000).toLong()
    val cut = System.getenv("CROP")?.split(":")?.map { it.toInt() }
    fun crop(img: org.jetbrains.skia.Image): org.jetbrains.skia.Image {
        val c = cut ?: return img
        val bmp = org.jetbrains.skia.Bitmap()
        bmp.allocN32Pixels(c[2] - c[0], c[3] - c[1])
        img.readPixels(bmp, c[0], c[1])
        img.close()
        return org.jetbrains.skia.Image.makeFromBitmap(bmp)
    }
    val encoders = java.util.concurrent.Executors.newFixedThreadPool(maxOf(1, Runtime.getRuntime().availableProcessors() - 1))
    val pending = mutableListOf<java.util.concurrent.Future<*>>()
    fun frames(k: Int, tag: String, save: Boolean) {
        if (real) {
            val until = System.nanoTime() + k * 80L * 1_000_000L
            while (System.nanoTime() < until) {
                val begun = System.nanoTime()
                val img = scene.render(begun - t0)
                if (save) File(out, "f_%03d_%s_%05d.png".format(n++, tag, (begun - t0) / 1_000_000L)).writeBytes(img.encodeToData(EncodedImageFormat.PNG)!!.bytes)
                img.close()
                Thread.sleep(maxOf(0L, stepMs - (System.nanoTime() - begun) / 1_000_000L))
            }
            return
        }
        val until = clock + k * 80L
        while (clock < until) {
            clock += stepMs
            var t = System.nanoTime()
            var img = scene.render((clock - start) * 1_000_000L)
            // background drawing counts as instant on the film's clock: wait for it, then draw the same moment again
            if (BattleClock.busy.get() > 0) {
                drawNs += System.nanoTime() - t; t = System.nanoTime()
                val giveUp = System.nanoTime() + 20_000_000_000L
                while (BattleClock.busy.get() > 0 && System.nanoTime() < giveUp) Thread.sleep(2)
                if (BattleClock.busy.get() > 0) println("  Achtung: Vorzeichnen nach 20 s nicht fertig (bei ${clock - start} ms), weiter ohne")
                waitNs += System.nanoTime() - t; t = System.nanoTime()
                img.close(); img = scene.render((clock - start) * 1_000_000L)
            }
            drawNs += System.nanoTime() - t; t = System.nanoTime()
            if (save && clock - start >= fromMs) {
                val file = File(out, "f_%03d_%s_%05d.png".format(n++, tag, clock - start))
                val pic = crop(img)
                // encoded and written on the other cores while the next frame is drawn
                pending += encoders.submit { file.writeBytes(pic.encodeToData(EncodedImageFormat.PNG)!!.bytes); pic.close() }
            } else img.close()
            saveNs += System.nanoTime() - t
        }
    }
    frames((f.wait / 80).toInt(), "w", false)
    // F: Fight, A: Attack, D: Defend, S: the scene (next message)
    val where = mapOf('F' to Offset(135f, 990f), 'A' to Offset(150f, 940f), 'D' to Offset(390f, 940f), 'S' to Offset(270f, 400f), 'B' to Offset(150f, 1085f), 'I' to Offset(270f, 935f), 'K' to Offset(390f, 990f), 'J' to Offset(270f, 1010f))
    for ((t, c) in f.plan.withIndex()) {
        // X: the next action, taken as soon as the hero may act
        if (c == 'X') {
            vm.testAction = actions.removeFirstOrNull()
            frames(28, "t$t$c", true)
            continue
        }
        // V: scroll a list (the abilities, the bag) one step down
        if (c == 'V') {
            scene.sendPointerEvent(PointerEventType.Scroll, Offset(270f, 990f), scrollDelta = Offset(0f, 5f)); frames(12, "t$t$c", true)
            continue
        }
        // W: no tap, only wait and film
        if (c != 'W') {
            val tap = where.getValue(c)
            scene.sendPointerEvent(PointerEventType.Press, tap); if (System.getenv("FILMQUICK") == null) frames(1, "t$t$c", true)
            scene.sendPointerEvent(PointerEventType.Release, tap)
        }
        frames(28, "t$t$c", true)
    }
    scene.close()
    val tw = System.nanoTime()
    pending.forEach { it.get() }
    encoders.shutdown()
    saveNs += System.nanoTime() - tw
    BattleClock.now = { System.currentTimeMillis() }
    BattleClock.random = kotlin.random.Random
    Battle.fxRandom = kotlin.random.Random
    println("filmed ${f.name}: $n frames" + if (real) "" else
        " (Zeichnen %.1f s, Vorzeichnen abwarten %.1f s, Speichern %.1f s)".format(drawNs / 1e9, waitNs / 1e9, saveNs / 1e9))
}
