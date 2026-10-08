package preview

import android.app.Application
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.ImageComposeScene
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.input.pointer.PointerEventType
import androidx.compose.ui.unit.Density
import de.bornim.core.*
import de.bornim.game.GameViewModel
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
        film(FilmSpec(w[0], w[1], w[2].toInt(), w[3].toInt(), w[4], w.getOrNull(5)?.split(",")?.map(::parseAction) ?: emptyList(),
            hurt = true, heroFirst = true, auto = true, wait = 1500L), File("build/screens/films/${w[0]}"))
    }
}

@OptIn(ExperimentalComposeUiApi::class)
fun film(f: FilmSpec, outDir: File) {
    val (clsName, foe) = f.spec.split(":")
    val out = outDir.apply { deleteRecursively(); mkdirs() }
    val vm = GameViewModel(Application())
    vm.newGame("Test", Race.HUMAN, CharClass.valueOf(clsName.uppercase()))
    if (f.auto && !vm.battleAuto) vm.toggleBattleAuto()
    val g = vm.game!!
    var guard = 0
    while (g.mode is Mode.Dialog && guard++ < 50) g.advance()
    f.level?.let { g.state.hero.gainXp(Rules.xpForLevel[it]); g.state.hero.restoreFully() }
    g.state.place = Place("forest", 10, 20, Facing.UP); g.state.minutes = 12 * 60
    // the hero starts the fight hurt, with a few potions and flasks of each kind
    if (f.hurt) {
        g.state.hero.hp = maxOf(1, g.state.hero.maxHp / 3)
        listOf("greater_potion", "potion", "remedy", "alchemist_fire", "holy_water").forEach { g.state.add(it, 2) }
    }
    val seed = f.seed
    val battle = Battle(g.state, Monsters[foe], g.lang, Dice(kotlin.random.Random(seed)), 1, false, 1, null, false, MonsterLook(seed),
        if (f.heroFirst) Opening.HERO_FIRST else Opening.NORMAL)
    g.fight(battle)
    vm.refresh()
    val actions = ArrayDeque(f.actions)
    val scene = ImageComposeScene(540, 1170, Density(1.375f)) { BornimApp(vm) }
    var time = 0L
    var n = 0
    fun frames(k: Int, tag: String, save: Boolean) = repeat(k) {
        val img = scene.render(time); time += 80_000_000L
        if (save) File(out, "f_%03d_%s.png".format(n++, tag)).writeBytes(img.encodeToData(EncodedImageFormat.PNG)!!.bytes)
        Thread.sleep(80)
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
    println("filmed ${f.name}: $n frames")
}
