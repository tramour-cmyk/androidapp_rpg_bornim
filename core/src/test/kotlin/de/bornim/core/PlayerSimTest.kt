package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertTrue

/**
 * A player who taps around at random, without the screen: walks, talks, fights (attack, defend, skills,
 * items), buys and moves on, with a fixed seed so every run is the same. After every input it checks what a
 * human tester would notice: no crash, no stuck dialog, hit points, gold and items in range, the hero on
 * the map, and a save that loads back to the same game. On a failure it names class, seed and the last
 * inputs, so the run can be repeated. More inputs on demand: PLAYSIM=20000.
 */
class PlayerSimTest {
    private val steps = System.getenv("PLAYSIM")?.toInt() ?: 1500

    private class Run(val cls: CharClass, val seed: Int) {
        val rnd = Random(seed)
        val game = Game(GameState.newGame("Sim", Race.entries[seed % Race.entries.size], cls), Lang.DE, Dice(Random(seed * 7 + 1)))
        val log = ArrayDeque<String>()
        var clock = 0L
        val seen = HashSet<String>()
        var fights = 0
        var route: Route? = null
        var routeIdx = 0

        fun note(s: String) { log.addLast(s); if (log.size > 25) log.removeFirst() }
        fun where() = "${cls.name} seed $seed, last inputs: ${log.joinToString(" ")}"
    }

    private fun input(r: Run) {
        val g = r.game
        when (val m = g.mode) {
            is Mode.Dialog -> { r.note("weiter"); g.advance() }
            is Mode.Shop -> {
                val id = m.stock.randomOrNull(r.rnd)
                if (id != null && r.rnd.nextInt(3) == 0 && g.state.gold >= g.buyPrice(id)) { r.note("kauf:$id"); g.buy(id) }
                else { r.note("laden-zu"); g.advance() }
            }
            is Mode.Fight -> {
                val b = m.battle
                if (b.outcome != Outcome.ONGOING) { r.note("kampf-ende:${b.outcome}"); g.endBattle(); return }
                val skills = g.hero.cls.skills().filter { it.level <= g.hero.level && b.blocked(it) == null }
                val items = listOf("potion", "remedy", "alchemist_fire", "holy_water").filter { g.state.count(it) > 0 }
                val a = when (r.rnd.nextInt(6)) {
                    0 -> Action.Defend
                    1, 2 -> skills.randomOrNull(r.rnd)?.let { Action.UseSkill(it) } ?: Action.Attack
                    3 -> items.randomOrNull(r.rnd)?.let { Action.UseItem(it) } ?: Action.Attack
                    else -> Action.Attack
                }
                r.note("kampf:$a"); b.act(a)
            }
            Mode.ChapterEnd -> { r.note("kapitelende") }
            Mode.Explore -> {
                // as the map screen does: the clock runs (monsters roam), the hero walks a route a tap away
                r.clock += 200; g.update(r.clock)
                if (g.mode != Mode.Explore) { if (g.mode is Mode.Fight) r.fights++; return }
                val rt = r.route
                if (rt == null || r.routeIdx >= rt.steps.size) {
                    if (rt != null) { rt.face?.let { g.face(it) }; if (rt.interact) { r.note("sprechen"); g.interact() } }
                    r.route = target(r)?.let { (x, y) -> g.route(x, y) }; r.routeIdx = 0
                    if (r.route == null) { val d = Facing.entries[r.rnd.nextInt(4)]; r.note(d.name.take(1)); step(r, d) }
                } else {
                    val d = rt.steps[r.routeIdx]
                    r.note(d.name.take(1))
                    if (step(r, d)) r.routeIdx++ else r.route = null
                }
                if (g.mode is Mode.Fight) r.fights++
            }
        }
    }

    private fun step(r: Run, d: Facing): Boolean {
        val stepped = r.game.move(d) is Move.Stepped
        if (stepped) r.game.afterStep()
        return stepped
    }

    /** Where the player taps next: a monster in sight, a door or path out, someone to talk to, or anywhere. */
    private fun target(r: Run): Pair<Int, Int>? {
        val m = r.game.map
        if (r.rnd.nextInt(2) == 0) r.game.roamers.randomOrNull(r.rnd)?.let { return it.x to it.y }
        return when (r.rnd.nextInt(10)) {
            in 0..4 -> m.warps.randomOrNull(r.rnd)?.let { it.x to it.y }
            in 5..7 -> m.npcs.randomOrNull(r.rnd)?.let { it.x to it.y }
            else -> r.rnd.nextInt(m.width) to r.rnd.nextInt(m.height)
        }
    }

    private fun check(r: Run): String? {
        val g = r.game; val h = g.hero; val p = g.state.place
        if (h.hp !in 0..h.maxHp) return "TP ${h.hp} außerhalb 0..${h.maxHp}"
        if (g.mode !is Mode.Fight && h.hp <= 0) return "Held mit ${h.hp} TP außerhalb des Kampfes"
        if (g.state.gold < 0) return "Gold ${g.state.gold}"
        val m = World[p.map]
        if (p.x !in 0 until m.width || p.y !in 0 until m.height) return "Held außerhalb der Karte ${p.map} (${p.x}, ${p.y})"
        return null
    }

    /** [start]: begin there instead of the first scene, with the way through the story open and at [level]. */
    private fun play(cls: CharClass, seed: Int, start: Place? = null, level: Int = 1): String? {
        val r = Run(cls, seed)
        if (start != null) {
            var guard = 0
            while (r.game.mode is Mode.Dialog && guard++ < 50) r.game.advance()
            r.game.state.flags += Story.QUEST_STARTED
            r.game.state.flags += Story.BARRIER_OPEN
            r.game.hero.gainXp(Rules.xpForLevel[level]); r.game.hero.restoreFully()
            listOf("potion", "remedy", "alchemist_fire", "holy_water").forEach { r.game.state.add(it, 3) }
            r.game.state.place = start
        }
        r.game.begin()
        var sameMode = 0
        var lastMode = ""
        for (i in 0 until steps) {
            try { input(r) } catch (e: Throwable) { return "Absturz bei Eingabe $i: $e\n   ${r.where()}" }
            check(r)?.let { return "$it\n   ${r.where()}" }
            val mode = r.game.mode.let { if (it is Mode.Dialog) "Dialog:${it.text.take(40)}" else it::class.simpleName ?: "" }
            r.seen += r.game.mode::class.simpleName ?: ""
            r.seen += "Karte:" + r.game.state.place.map
            sameMode = if (mode == lastMode && r.game.mode is Mode.Dialog) sameMode + 1 else 0
            lastMode = mode
            if (sameMode > 20) return "Dialog hängt: $mode\n   ${r.where()}"
            if (r.game.mode == Mode.ChapterEnd) break
            if (i % 250 == 0) {
                val a = r.game.state.toJson()
                val b = runCatching { GameState.fromJson(a).toJson() }.getOrElse { return "Laden scheitert: $it\n   ${r.where()}" }
                if (a != b) return "Speichern und Laden ergeben verschiedene Stände\n   ${r.where()}"
            }
        }
        println("PlayerSim ${cls.name} seed $seed ${start?.map ?: ""}: ${r.fights} Kämpfe, gesehen: ${r.seen.sorted().joinToString(", ")}")
        return null
    }

    @Test
    fun aRandomPlayerFindsNothingBroken() {
        val odd = mutableListOf<String>()
        for (cls in CharClass.entries) for (seed in 0 until 3) play(cls, seed)?.let { odd += it }
        assertTrue(odd.isEmpty(), "Zufallsspieler fand:\n" + odd.joinToString("\n"))
    }

    /** The same player dropped into every area with encounters (where it enters from a neighbouring map). */
    @Test
    fun aRandomPlayerInTheWilds() {
        val odd = mutableListOf<String>()
        val entries = World.maps.values.flatMap { it.warps }.map { it.to }.filter { World[it.map].encounters != null }
            .groupBy { it.map }.mapValues { it.value.first() }
        assertTrue(entries.isNotEmpty(), "no area with encounters found")
        for ((i, place) in entries.values.withIndex()) for (cls in CharClass.entries)
            play(cls, i * 10 + cls.ordinal, place, if (cls.ordinal % 2 == 0) 2 else 5)?.let { odd += it }
        assertTrue(odd.isEmpty(), "Zufallsspieler in der Wildnis fand:\n" + odd.joinToString("\n"))
    }
}
