package de.bornim.core

sealed interface Mode {
    data object Explore : Mode
    data class Dialog(val speaker: String?, val text: String) : Mode
    data class Fight(val battle: Battle) : Mode
    /** A shop; [brewing] adds Morwen's potion brewing and leaves out Thessa's equipment. */
    data class Shop(val stock: List<String>, val brewing: Boolean = false) : Mode
    data object ChapterEnd : Mode
}

/** Result of a movement attempt, used by the UI to animate. */
sealed interface Move {
    data object Blocked : Move
    data class Stepped(val fromX: Int, val fromY: Int) : Move
}

/**
 * Overworld game logic: movement, interaction, scripts and encounters.
 * Pure Kotlin so it can be unit-tested; the app only renders it.
 */
class Game(var state: GameState, var lang: Lang, private val dice: Dice = Dice()) {
    companion object {
        const val ELITE_CHANCE = 0.12
        const val SHINY_CHANCE = 1.0 / 150
        /** Poison and bleeding carried out of a fight hurt once every this many steps. */
        const val AILMENT_STEPS = 4
        /** Share of flower tiles that carry a healing herb on a given day. */
        const val HERB_CHANCE = 0.5
    }

    var mode: Mode = Mode.Explore
        private set

    /** Bumped on every change so the UI knows when to redraw. */
    var revision = 0
        private set

    /** Set when the map changed, so the app can autosave and fade. */
    var mapChanged = false

    private val queue = ArrayDeque<Cmd>()

    /** Short messages for the app to show as a toast. */
    val notices = ArrayDeque<T>()

    /** Sound effects triggered by the last actions; the app plays and clears them. */
    val sounds = ArrayDeque<de.bornim.core.audio.Sound>()
    private var battleFromScript: Cmd.Fight? = null
    private var graceSteps = 3
    private val npcFacing = mutableMapOf<String, Facing>()

    // Monsters walking around on the maps; not saved, they simply appear again after loading.
    private val herds = HashMap<String, MutableList<Roamer>>()
    /** Step counts at which a defeated monster of a map comes back. */
    private val respawns = HashMap<String, MutableList<Int>>()
    private var nextRoamerUid = 1
    private var battleRoamer: Roamer? = null
    /** App clock of the last update, and a short period after battles in which nothing attacks. */
    private var now = 0L
    private var peaceUntil = 0L
    // Movement of monsters is cosmetic randomness and must not shift the game's dice.
    private val roamRandom = kotlin.random.Random(state.steps * 31 + 7)

    val map: MapDef get() = World[state.place.map]
    val hero: Hero get() = state.hero

    fun npcFacing(npc: Npc): Facing = npcFacing[npc.id] ?: walkerOf(npc)?.facing ?: npc.facing

    // ------------------------------------------------------------ time of day and weather

    private var clockMs = 0L
    private var lastUpdate = 0L
    private var rainLeft = 0

    /** 1 in full daylight, 0 at night, in between at dawn and dusk. */
    val daylight: Float
        get() {
            val m = state.minutes
            return when {
                m in 7 * 60 until 19 * 60 -> 1f
                m in 19 * 60 until 21 * 60 -> 1f - (m - 19 * 60) / 120f
                m in 5 * 60 until 7 * 60 -> (m - 5 * 60) / 120f
                else -> 0f
            }
        }

    val isNight: Boolean get() = daylight < 0.35f
    val raining: Boolean get() = rainLeft > 0

    private fun tickClock(deltaMs: Long) {
        clockMs += deltaMs
        while (clockMs >= 1000) {
            clockMs -= 1000
            state.minutes++
            if (rainLeft > 0) rainLeft--
            if (state.minutes >= 24 * 60) {
                state.minutes = 0
                state.day++
            }
            // Now and then it starts to rain for an hour or two.
            if (state.minutes % 60 == 0 && rainLeft == 0 && roamRandom.nextInt(9) == 0) rainLeft = 60 + roamRandom.nextInt(120)
        }
    }

    /** Sleep until morning (beds in the inn). */
    private fun sleep() {
        state.minutes = 7 * 60
        state.day++
        rainLeft = 0
        enqueue(listOf(Cmd.Rest, Cmd.Say(null, T("Du schläfst tief und fest. Ein neuer Morgen bricht an – TP und ZP sind voll.", "You sleep soundly. A new morning dawns – HP and SP are full."))))
    }

    // ------------------------------------------------------------ villagers strolling around

    private val walkers = HashMap<String, List<Walker>>()

    private fun walkersHere(): List<Walker> = walkers.getOrPut(state.place.map) { map.npcs.filter { it.moves }.map { Walker(it) } }

    /** Where a strolling villager is right now, null for people who stand still. */
    fun walkerOf(npc: Npc): Walker? = if (!npc.moves) null else walkersHere().firstOrNull { it.npc === npc }

    /** The person at ([x], [y]), wherever they strolled to. */
    fun npcAt(x: Int, y: Int): Npc? = map.npcAt(x, y, state)
        ?: walkersHere().firstOrNull { it.x == x && it.y == y && it.npc.visible(state) }?.npc

    private fun updateWalkers() {
        val p = state.place
        for (w in walkersHere()) {
            if (now < w.nextMoveAt || !w.npc.visible(state)) continue
            if (w.npc.patrol.isNotEmpty()) {
                patrol(w)
                continue
            }
            w.nextMoveAt = now + 1500 + roamRandom.nextInt(2500)
            // Stay put while the hero stands right next to them.
            if (kotlin.math.abs(w.x - p.x) + kotlin.math.abs(w.y - p.y) <= 1) continue
            val d = Facing.entries[roamRandom.nextInt(4)]
            val nx = w.x + d.dx; val ny = w.y + d.dy
            w.facing = d
            if (kotlin.math.abs(nx - w.npc.x) + kotlin.math.abs(ny - w.npc.y) > w.npc.wander) continue
            if (!free(nx, ny) || map.warpAt(nx, ny) != null || (nx == p.x && ny == p.y)) continue
            w.fromX = w.x; w.fromY = w.y
            w.x = nx; w.y = ny
            w.movedAt = now
            changed()
        }
    }

    /** One step of a guard's round: walk to the next patrol point, look around there, go on. */
    private fun patrol(w: Walker) {
        val p = state.place
        // Wait while the hero stands next to them, e.g. to talk.
        if (kotlin.math.abs(w.x - p.x) + kotlin.math.abs(w.y - p.y) <= 1) {
            w.nextMoveAt = now + 800
            return
        }
        val (tx, ty) = w.npc.patrol[w.leg]
        if (w.x == tx && w.y == ty) {
            // Arrived: look around for a while, then head for the next point.
            w.leg = (w.leg + 1) % w.npc.patrol.size
            w.facing = if (roamRandom.nextBoolean()) Facing.UP else Facing.entries[roamRandom.nextInt(4)]
            npcFacing.remove(w.npc.id)
            w.nextMoveAt = now + 2500 + roamRandom.nextInt(2500)
            changed()
            return
        }
        val d = when {
            tx != w.x -> if (tx > w.x) Facing.RIGHT else Facing.LEFT
            else -> if (ty > w.y) Facing.DOWN else Facing.UP
        }
        val nx = w.x + d.dx; val ny = w.y + d.dy
        w.nextMoveAt = now + 650
        if (!free(nx, ny) || (nx == p.x && ny == p.y)) return
        w.facing = d
        npcFacing.remove(w.npc.id)
        w.fromX = w.x; w.fromY = w.y
        w.x = nx; w.y = ny
        w.movedAt = now
        changed()
    }

    /** Advances the clock, villagers and monsters; call every frame with the app clock in ms. */
    fun update(nowMs: Long) {
        val delta = if (lastUpdate == 0L) 0L else (nowMs - lastUpdate).coerceIn(0, 250)
        lastUpdate = nowMs
        now = nowMs
        if (mode != Mode.Explore) return
        tickClock(delta)
        updateWalkers()
        updateRoamers(nowMs)
    }

    private val sight = Sight(state)

    /** Wild areas (forest, cave) are covered by fog until the hero has seen them. */
    val fogged: Boolean get() = map.kind == MapKind.FOREST || map.kind == MapKind.CAVE

    fun fog(x: Int, y: Int): Fog = if (!fogged) Fog.VISIBLE else sight.fog(map, x, y, isNight)

    /** Monsters walking around on the current map. */
    val roamers: List<Roamer> get() = herd()

    fun roamerAt(x: Int, y: Int): Roamer? = herd().firstOrNull { it.x == x && it.y == y }

    /** Walkable for the hero and monsters: free of walls, people and monsters. */
    fun free(x: Int, y: Int): Boolean =
        map.walkable(x, y, state) && roamerAt(x, y) == null && walkersHere().none { it.x == x && it.y == y && it.npc.visible(state) }

    /** Call once after creating or loading a game. */
    fun begin() {
        // Experience banked at a chapter's level cap counts once the cap is lifted.
        hero.gainXp(0, Story.levelCap(state))
        unstick()
        if (state.flags.remove(GameState.POINTS_REFIT)) {
            enqueue(listOf(Cmd.Say(null, T(
                "Neue Regeln: Attributspunkte gibt es jetzt auf Stufe 4, 8, 12, 16 und 19 (je zwei). Deine Punkte wurden neu berechnet – verteile sie im Heldenmenü.",
                "New rules: ability points now come at levels 4, 8, 12, 16 and 19 (two each). Your points were recalculated – spend them in the hero menu.",
            ))))
        }
        runOnEnter()
    }

    /**
     * Moves the hero to the nearest free tile if a save game put them somewhere that is no longer
     * walkable, e.g. after a map was rebuilt.
     */
    private fun unstick() {
        val p = state.place
        if (map.walkable(p.x, p.y, state)) return
        val seen = HashSet<Pair<Int, Int>>()
        val queue = ArrayDeque(listOf(p.x to p.y))
        seen += p.x to p.y
        while (queue.isNotEmpty()) {
            val (x, y) = queue.removeFirst()
            if (map.walkable(x, y, state) && map.warpAt(x, y) == null) {
                state.place = p.copy(x = x, y = y)
                return
            }
            for (d in Facing.entries) {
                val n = x + d.dx to y + d.dy
                if (map.inside(n.first, n.second) && seen.add(n)) queue += n
            }
        }
    }

    // ------------------------------------------------------------ movement

    fun move(dir: Facing): Move {
        if (mode != Mode.Explore) return Move.Blocked
        val p = state.place
        state.place = p.copy(facing = dir)
        val nx = p.x + dir.dx
        val ny = p.y + dir.dy
        val warp = map.warpAt(nx, ny)
        if (warp != null && warp.requires != null && !state.has(warp.requires)) {
            changed()
            enqueue(warp.denied)
            return Move.Blocked
        }
        roamerAt(nx, ny)?.let { r ->
            // Walking into a monster attacks it; from behind the hero strikes first.
            engage(r, if (r.facing == dir || (r.temper == Temper.LURKER && !r.hunting)) Opening.HERO_FIRST else Opening.NORMAL)
            return Move.Blocked
        }
        if (!free(nx, ny)) {
            changed()
            if (map.tile(nx, ny) == Tile.BARRIER && !state.has(Story.BARRIER_OPEN)) barrier()
            return Move.Blocked
        }
        state.place = Place(p.map, nx, ny, dir)
        state.steps++
        changed()
        return Move.Stepped(p.x, p.y)
    }

    /** Call when the step animation finished: handles warps, triggers and random encounters. */
    fun afterStep() {
        if (mode != Mode.Explore) return
        val p = state.place
        map.warpAt(p.x, p.y)?.let { warp ->
            sounds += de.bornim.core.audio.Sound.DOOR
            state.place = warp.to
            graceSteps = 3
            mapChanged = true
            changed()
            runOnEnter()
            return
        }
        map.triggers.firstOrNull { it.x == p.x && it.y == p.y && it.condition(state) }?.let {
            enqueue(it.script(state))
            return
        }
        if (fogged) fog(p.x, p.y) // explore what comes into view, also without a screen
        tickAilments()
        pickHerbs()
        respawnRoamers()
        if (graceSteps > 0) {
            graceSteps--
            return
        }
        val enc = map.encounters ?: return
        // Rarely, something hidden in the grass or the dark jumps out.
        if (map.tile(p.x, p.y) in enc.tiles && !map.safe(p.x, p.y) && dice.chance(enc.rate * Perks.ambushFactor(hero))) {
            startBattle(dice.weighted(enc.table), null, opening = Opening.AMBUSHED)
        }
    }

    /** Poison and bleeding from the last fight hurt every few steps, but never knock the hero out. */
    private fun tickAilments() {
        if (state.steps % AILMENT_STEPS != 0) return
        for (st in listOf(Status.POISON, Status.BLEED)) {
            val left = state.ailment(st)
            if (left <= 0) continue
            val before = hero.hp
            hero.hp = maxOf(1, hero.hp - dice.roll(if (st == Status.POISON) dice(1, 3) else dice(1, 2)))
            if (left <= 1) {
                state.ailments.remove(st.name)
                notices += Msgs.ailmentEnds.getValue(st)
            } else {
                state.ailments[st.name] = left - 1
                if (before > hero.hp) notices += Msgs.ailmentHurts.getValue(st).let { T(it.de.replace("{0}", "${before - hero.hp}"), it.en.replace("{0}", "${before - hero.hp}")) }
            }
            changed()
        }
    }

    /**
     * Whether a healing herb grows at ([x], [y]) right now: on some flower tiles of the wild, a
     * different set each day, until it is picked. Visible on the map as a light green plant.
     */
    fun herbAt(x: Int, y: Int): Boolean {
        if (map.kind != MapKind.FOREST || map.tile(x, y) != Tile.FLOWERS) return false
        if (state.picked["${state.place.map}:$x:$y"] == state.day) return false
        // Fixed per tile and day, so the plant does not flicker and the map can show it.
        var h = state.place.map.hashCode() * 31 + x * 73_856_093 + y * 19_349_663 + state.day * 83_492_791
        h = (h xor (h ushr 13)) * 0x5bd1e995
        h = h xor (h ushr 15)
        return Math.floorMod(h, 100) < HERB_CHANCE * 100
    }

    /** Walking onto a herb picks it; it grows back the next day. */
    private fun pickHerbs() {
        val p = state.place
        if (!herbAt(p.x, p.y)) return
        state.picked["${p.map}:${p.x}:${p.y}"] = state.day
        val n = 1 + (if (dice.chance(0.3)) 1 else 0) + (if (dice.chance(Perks.extraHerbChance(hero))) 1 else 0)
        state.add("herbs", n)
        sounds += de.bornim.core.audio.Sound.LOOT
        notices += T("Du pflückst Heilkräuter (+$n).", "You pick healing herbs (+$n).")
        changed()
    }

    /** Takes over the statuses that outlast a fight. */
    private fun keepAilments(battle: Battle) {
        state.ailments.clear()
        for ((st, turns) in battle.heroStatus) {
            if (!st.lingers) continue
            // A curse that is still on at the end of the fight stays until it is cured;
            // a tough hero shakes off poison and bleeding sooner.
            val left = if (st == Status.WEAK) Status.LASTING else turns - Perks.ailmentShortening(hero)
            if (left > 0) state.ailments[st.name] = left
        }
    }

    private object Msgs {
        val ailmentHurts = mapOf(
            Status.POISON to T("Das Gift brennt in den Adern (−{0} TP).", "The poison burns in your veins (−{0} HP)."),
            Status.BLEED to T("Die Wunde blutet weiter (−{0} TP).", "The wound keeps bleeding (−{0} HP)."),
        )
        val ailmentEnds = mapOf(
            Status.POISON to T("Das Gift hat nachgelassen.", "The poison has worn off."),
            Status.BLEED to T("Die Blutung hat aufgehört.", "The bleeding has stopped."),
        )
        val cured = T("{0} fühlt sich wieder gesund.", "{0} feels healthy again.")
        val roasted = T("Du brätst {0}× Fleisch über dem Feuer. Es duftet herrlich!", "You roast {0}× meat over the fire. It smells wonderful!")
        val ate = T("{0} isst {1}, heilt {2} TP und fühlt sich gestärkt für den nächsten Kampf.", "{0} eats {1}, recovers {2} HP and feels fortified for the next fight.")
        val alreadyFed = T("{0} ist noch satt von der letzten Mahlzeit.", "{0} is still full from the last meal.")
        val brewed = T("Morwen braut dir: {0}.", "Morwen brews for you: {0}.")
        val brewedTwo = T("Mit deinem Wissen holt ihr zwei Tränke heraus: 2× {0}.", "With your know-how you get two potions out of it: 2× {0}.")
        val missing = T("Dafür fehlen dir Zutaten oder Gold.", "You lack ingredients or gold for that.")
    }

    // ------------------------------------------------------------ monsters on the map

    private fun herd(): MutableList<Roamer> = herds.getOrPut(state.place.map) {
        val list = mutableListOf<Roamer>()
        repeat(map.encounters?.roamers ?: 0) { spawnRoamer(list)?.let { list += it } }
        list
    }

    /** Places a new monster on a free tile of the area, away from the hero. */
    private fun spawnRoamer(list: List<Roamer>): Roamer? {
        val enc = map.encounters ?: return null
        val p = state.place
        val spots = ArrayList<Pair<Int, Int>>()
        for (y in 0 until map.height) for (x in 0 until map.width) {
            if (map.tile(x, y) !in enc.tiles || !map.walkable(x, y, state) || map.warpAt(x, y) != null) continue
            if (kotlin.math.abs(x - p.x) + kotlin.math.abs(y - p.y) < 7) continue
            if (list.any { kotlin.math.abs(it.x - x) + kotlin.math.abs(it.y - y) < 3 }) continue
            if (map.triggers.any { it.x == x && it.y == y } || map.safe(x, y)) continue
            spots += x to y
        }
        if (spots.isEmpty()) return null
        val (x, y) = spots[roamRandom.nextInt(spots.size)]
        val monster = dice.weighted(if (isNight && enc.night != null) enc.night else enc.table)
        val shiny = dice.chance(SHINY_CHANCE)
        val trait = if (!shiny && hero.level >= 2 && dice.chance(ELITE_CHANCE)) dice.pick(EliteTrait.entries) else null
        return Roamer(nextRoamerUid++, monster, x, y, x, y, trait, shiny, MonsterLook(roamRandom.nextInt(), shiny, trait?.color)).also {
            it.facing = Facing.entries[roamRandom.nextInt(4)]
            it.nextMoveAt = now + 500 + roamRandom.nextInt(2000)
        }
    }

    private fun respawnRoamers() {
        val due = respawns[state.place.map] ?: return
        val herd = herd()
        val ready = due.filter { it <= state.steps }
        if (ready.isEmpty()) return
        due.removeAll(ready)
        repeat(ready.size) { spawnRoamer(herd)?.let { herd += it } }
        changed()
    }

    /**
     * Lets the monsters of the current map move; call every frame with the app clock in ms.
     * A hunter that reaches the hero starts a fight, from behind as an ambush.
     */
    fun updateRoamers(nowMs: Long) {
        now = nowMs
        if (mode != Mode.Explore) return
        val herd = herd()
        val p = state.place
        val strongHero = hero.level >= map.areaLevel + 5
        var moved = false
        val heroSafe = map.safeZones.firstOrNull { it.contains(p.x, p.y) }
        for (r in herd) {
            if (now < r.nextMoveAt) continue
            val dist = kotlin.math.abs(r.x - p.x) + kotlin.math.abs(r.y - p.y)
            val fromHome = kotlin.math.abs(r.x - r.homeX) + kotlin.math.abs(r.y - r.homeY)
            val calm = now < r.calmUntil || now < peaceUntil
            // Weak monsters keep away from a far stronger hero; elites are never afraid.
            val afraid = strongHero && r.trait == null
            val sees = heroSafe == null && dist <= (if (r.temper == Temper.LURKER) 2 else Perks.noticeRange(hero))
            when {
                !calm && afraid && dist <= 4 && heroSafe == null -> {
                    r.hunting = false
                    stepRoamer(r, away = true, ms = 360)
                }
                r.hunting -> {
                    when {
                        // The hero reached a safe place, got away, or lured it too far from home.
                        heroSafe != null || calm || dist > 7 || fromHome > 9 -> {
                            r.hunting = false
                            r.returning = true
                            if (heroSafe?.notice != null && dist <= 7) notices += heroSafe.notice
                            r.nextMoveAt = now + 600
                        }
                        dist == 1 -> {
                            // Adjacent: attack. Coming from behind the hero is an ambush.
                            val fromBehind = r.x - p.x == -p.facing.dx && r.y - p.y == -p.facing.dy
                            r.facing = Facing.entries.first { it.dx == p.x - r.x && it.dy == p.y - r.y }
                            engage(r, if (fromBehind) Opening.AMBUSHED else Opening.NORMAL)
                            return
                        }
                        else -> stepTowards(r, p.x, p.y, away = false, ms = if (r.monster == "zombie" || r.monster == "ochre_jelly") 560 else 380)
                    }
                }
                !calm && !afraid && r.temper != Temper.WANDERER && sees && !r.returning -> {
                    r.hunting = true
                    r.alertUntil = now + 800
                    r.nextMoveAt = now + 500
                    sounds += de.bornim.core.audio.Sound.ALERT
                }
                r.returning -> {
                    if (fromHome <= 1) {
                        r.returning = false
                        r.nextMoveAt = now + 800
                    } else {
                        stepTowards(r, r.homeX, r.homeY, away = false, ms = 420)
                        r.nextMoveAt = now + 520
                    }
                }
                r.temper == Temper.LURKER -> r.nextMoveAt = now + 1000
                else -> wander(r)
            }
            moved = true
        }
        if (moved) changed()
    }

    private fun wander(r: Roamer) {
        r.hunting = false
        if (roamRandom.nextInt(10) < 3) {
            r.facing = Facing.entries[roamRandom.nextInt(4)]
        } else {
            val dirs = Facing.entries.shuffled(roamRandom)
            for (d in dirs) {
                val nx = r.x + d.dx; val ny = r.y + d.dy
                if (kotlin.math.abs(nx - r.homeX) + kotlin.math.abs(ny - r.homeY) > 3) continue
                if (moveRoamer(r, d, 420)) break
            }
        }
        r.nextMoveAt = now + 900 + roamRandom.nextInt(1600)
    }

    private fun stepRoamer(r: Roamer, away: Boolean, ms: Long) = stepTowards(r, state.place.x, state.place.y, away, ms)

    /** One step towards (or away from) a tile along the better axis, trying the other one if blocked. */
    private fun stepTowards(r: Roamer, tx: Int, ty: Int, away: Boolean, ms: Long) {
        val dx = (tx - r.x).let { if (away) -it else it }
        val dy = (ty - r.y).let { if (away) -it else it }
        val h = if (dx > 0) Facing.RIGHT else Facing.LEFT
        val v = if (dy > 0) Facing.DOWN else Facing.UP
        val order = if (kotlin.math.abs(dx) >= kotlin.math.abs(dy)) listOf(h, v) else listOf(v, h)
        val tried = order.filter { (if (it == h) dx else dy) != 0 } + Facing.entries.shuffled(roamRandom)
        for (d in tried) if (moveRoamer(r, d, ms)) break
        r.nextMoveAt = now + ms + 40
    }

    private fun moveRoamer(r: Roamer, d: Facing, ms: Long): Boolean {
        val nx = r.x + d.dx; val ny = r.y + d.dy
        val p = state.place
        if (!free(nx, ny) || map.warpAt(nx, ny) != null || (nx == p.x && ny == p.y) || map.safe(nx, ny)) return false
        if (map.tile(nx, ny) == Tile.DOOR || map.tile(nx, ny) == Tile.GATE) return false
        r.fromX = r.x; r.fromY = r.y
        r.x = nx; r.y = ny
        r.facing = d
        r.movedAt = now
        r.moveMs = ms
        return true
    }

    /** Starts the fight against a monster on the map. */
    private fun engage(r: Roamer, opening: Opening) {
        if (mode != Mode.Explore) return
        battleRoamer = r
        startBattle(r.monster, null, r.trait to r.shiny, opening, r.look)
    }

    private fun runOnEnter() {
        enqueue(map.onEnter(state))
    }

    // ------------------------------------------------------------ interaction

    /** Turns the hero without moving (used after walking to a tapped target). */
    fun face(dir: Facing) {
        if (mode != Mode.Explore) return
        state.place = state.place.copy(facing = dir)
        changed()
    }

    fun interact() {
        if (mode != Mode.Explore) return
        val p = state.place
        var tx = p.x + p.facing.dx
        var ty = p.y + p.facing.dy
        if (map.tile(tx, ty) == Tile.COUNTER) {
            tx += p.facing.dx
            ty += p.facing.dy
        }
        roamerAt(tx, ty)?.let { r ->
            engage(r, if (r.facing == p.facing || (r.temper == Temper.LURKER && !r.hunting)) Opening.HERO_FIRST else Opening.NORMAL)
            return
        }
        npcAt(tx, ty)?.let { npc ->
            npcFacing[npc.id] = p.facing.opposite
            enqueue(npc.talk(state))
            return
        }
        map.signs[tx to ty]?.let {
            enqueue(listOf(Cmd.Say(null, it)))
            return
        }
        when (map.tile(tx, ty)) {
            Tile.CHEST -> openChest(tx, ty)
            Tile.CAMPFIRE -> {
                val meat = state.count("raw_meat")
                val roast = if (meat == 0) emptyList() else {
                    // Raw meat goes on the fire while the hero rests.
                    state.remove("raw_meat", meat)
                    state.add("roast_meat", meat)
                    listOf(Cmd.Say(null, Msgs.roasted.let { T(it.de.replace("{0}", "$meat"), it.en.replace("{0}", "$meat")) }))
                }
                enqueue(listOf(Cmd.Rest, Cmd.Say(null, Ui.rested)) + roast)
            }
            Tile.GATE -> gate()
            Tile.BARRIER -> if (!state.has(Story.BARRIER_OPEN)) barrier()
            Tile.WELL -> say(T("Ein alter Brunnen. Das Wasser ist klar und kalt.", "An old well. The water is clear and cold."))
            Tile.SHELF -> say(T("Regale voller Krimskrams.", "Shelves full of odds and ends."))
            Tile.STALL -> say(listOf(
                T("Ein Marktstand mit rotbackigen Äpfeln und frischem Gemüse.", "A market stall with rosy apples and fresh vegetables."),
                T("Bunte Stoffe und Wollknäuel liegen auf dem Stand aus.", "Colourful cloth and balls of wool are laid out on the stall."),
                T("Der Stand duftet nach Kräutern und getrockneten Pilzen.", "The stall smells of herbs and dried mushrooms."),
            )[Math.floorMod(tx * 7 + ty * 3, 3)])
            Tile.LAMP -> say(T(if (isNight) "Die Laterne brennt warm und hell." else "Eine Laterne. Abends zündet Jorin sie an.", if (isNight) "The lantern burns warm and bright." else "A lantern. Jorin lights it in the evening."))
            Tile.BARREL -> say(T("Ein Fass. Es riecht nach Apfelmost.", "A barrel. It smells of cider."))
            Tile.CROPS -> say(T("Das Korn steht hoch und golden. Bald ist Erntezeit.", "The grain stands tall and golden. Harvest time is near."))
            Tile.VEG_BED -> say(T("Kohl und Möhren, sorgfältig in Reihen gepflanzt.", "Cabbages and carrots, carefully planted in rows."))
            Tile.HAY -> say(T("Ein Heuballen. Die Hühner scharren drumherum.", "A bale of hay. The chickens scratch around it."))
            Tile.WASHLINE -> say(T("Frisch gewaschene Wäsche flattert im Wind.", "Freshly washed laundry flutters in the wind."))
            Tile.BENCH -> say(T("Eine Bank zum Ausruhen. Von hier hat man den ganzen Dorfplatz im Blick.", "A bench to rest on. From here you can see the whole village square."))
            Tile.BED -> if (isNight) sleep() else say(T("Ein weiches Bett. Schlafen kannst du, wenn es Nacht ist.", "A soft bed. You can sleep here once night falls."))
            Tile.ALTAR -> say(
                if (state.has(Story.CHAPTER1_DONE)) T("Das Sonnenamulett strahlt auf dem Altar.", "The Sun Amulet shines on the altar.")
                else T("Auf dem Altar ist eine leere Halterung. Hier lag das Sonnenamulett.", "There's an empty holder on the altar. This is where the Sun Amulet lay.")
            )
            else -> {}
        }
    }

    private fun say(t: T) = enqueue(listOf(Cmd.Say(null, t)))

    private fun openChest(x: Int, y: Int) {
        val chest = map.chestAt(x, y) ?: return say(Ui.nothingHere)
        if (chest.id in state.openedChests) return say(Ui.chestEmpty)
        state.openedChests += chest.id
        sounds += de.bornim.core.audio.Sound.CHEST
        val cmds = mutableListOf<Cmd>()
        chest.item?.let { raw ->
            val id = if (raw == Story.CLASS_WEAPON) Story.classWeapon(hero.cls) else raw
            cmds += Cmd.Give(id, chest.count)
        }
        if (chest.gold > 0) cmds += Cmd.GiveGold(chest.gold)
        enqueue(cmds)
    }

    /** The closed barrier on the north road: what it takes to get through. */
    private fun barrier() = say(
        if (state.has(Story.QUEST_STARTED)) T("Der Schlagbaum ist unten. Sprich mit Wache Jorin, damit er ihn öffnet.", "The barrier is down. Talk to Guard Jorin so he raises it.")
        else T("Der Schlagbaum ist unten. Ohne Erlaubnis des Ältesten kommst du hier nicht durch.", "The barrier is down. You can't pass without the Elder's permission."),
    )

    private fun gate() {
        when {
            state.has(Story.GATE_OPEN) -> {}
            state.count("rusty_key") > 0 -> enqueue(script {
                take("rusty_key")
                flag(Story.GATE_OPEN)
                narrate("Du steckst den rostigen Schlüssel ins Schloss. Mit lautem Quietschen öffnet sich das Gitter.", "You put the rusty key into the lock. With a loud screech, the gate swings open.")
            })
            else -> say(T("Ein schweres Eisengitter. Es ist verschlossen.", "A heavy iron gate. It's locked."))
        }
    }

    // ------------------------------------------------------------ scripts

    fun enqueue(cmds: List<Cmd>) {
        queue.addAll(cmds)
        if (mode == Mode.Explore) runQueue()
    }

    /** Continue after the player dismissed a dialog box, closed the shop or the chapter end screen. */
    fun advance() {
        if (mode is Mode.Fight) return
        mode = Mode.Explore
        runQueue()
        changed()
    }

    private fun runQueue() {
        while (queue.isNotEmpty()) {
            when (val c = queue.removeFirst()) {
                is Cmd.Say -> {
                    mode = Mode.Dialog(c.speaker?.invoke(lang), c.text(lang).replace("{name}", hero.name))
                    changed()
                    return
                }
                is Cmd.SetFlag -> {
                    state.flags += c.flag
                    hero.chapter = Story.chapter(state)
                    if (c.flag == Story.BARRIER_OPEN) sounds += de.bornim.core.audio.Sound.DOOR
                }
                is Cmd.Give -> {
                    val text = when {
                        c.item.startsWith("@gear:") -> {
                            val min = Rarity.valueOf(c.item.removePrefix("@gear:"))
                            val ilvl = maxOf(map.areaLevel, hero.level)
                            val g = state.addGear(Loot.generate(state, dice, ilvl, Loot.rarityFor(state, dice, ilvl, special = true, floor = min), hero.cls))
                            "${g.name(lang)} (${g.rarity.title(lang)})"
                        }
                        Uniques.exists(c.item) -> {
                            val g = state.addGear(Uniques.make(c.item, 0, maxOf(map.areaLevel, hero.level)))
                            "${g.name(lang)} (${g.rarity.title(lang)})"
                        }
                        else -> {
                            state.add(c.item, c.count)
                            (if (c.count > 1) "${c.count}× " else "") + Items[c.item].name(lang)
                        }
                    }
                    sounds += de.bornim.core.audio.Sound.LOOT
                    mode = Mode.Dialog(null, Ui.found.f(lang, text))
                    changed()
                    return
                }
                is Cmd.Take -> state.remove(c.item, c.count)
                is Cmd.GiveGold -> {
                    sounds += de.bornim.core.audio.Sound.COINS
                    state.gold += c.amount
                    mode = Mode.Dialog(null, Ui.foundGold.f(lang, c.amount))
                    changed()
                    return
                }
                is Cmd.Fight -> {
                    startBattle(c.monster, c)
                    return
                }
                is Cmd.OpenShop -> {
                    mode = Mode.Shop(c.stock, c.brewing)
                    changed()
                    return
                }
                Cmd.Rest -> {
                    sounds += de.bornim.core.audio.Sound.HEAL
                    hero.restoreFully()
                    state.ailments.clear()
                    state.respawn = state.place
                }
                Cmd.ChapterEnd -> {
                    mode = Mode.ChapterEnd
                    changed()
                    return
                }
            }
        }
        mode = Mode.Explore
        changed()
    }

    // ------------------------------------------------------------ battles

    private fun startBattle(
        monster: String, fromScript: Cmd.Fight?, forced: Pair<EliteTrait?, Boolean>? = null,
        opening: Opening = Opening.NORMAL, forcedLook: MonsterLook? = null,
    ) {
        battleFromScript = fromScript
        val def = Monsters[monster]
        // Monsters grow with the hero so grinding stays worthwhile.
        val area = map.areaLevel
        var level = maxOf(area, hero.level - 1 + (if (dice.chance(0.3)) 1 else 0))
        // Story bosses only grow a little, so returning to them later is not a wall.
        if (def.boss) level = minOf(level, area + 2)
        val shiny = forced?.second ?: (!def.boss && dice.chance(SHINY_CHANCE))
        // No elites for brand-new heroes: the first level is for learning the ropes.
        val trait = if (forced != null) forced.first
        else if (!def.boss && !shiny && hero.level >= 2 && dice.chance(ELITE_CHANCE)) dice.pick(EliteTrait.entries) else null
        // The look is purely cosmetic and must not use the game's dice.
        val look = forcedLook ?: MonsterLook(kotlin.random.Random.nextInt(), shiny, trait?.color)
        sounds += if (opening == Opening.AMBUSHED) de.bornim.core.audio.Sound.AMBUSH else de.bornim.core.audio.Sound.ENCOUNTER
        mode = Mode.Fight(Battle(state, def, lang, dice, level, trait != null, area, trait, shiny, look, opening))
        changed()
    }

    // ------------------------------------------------------------ test mode (hidden cheat menu)

    /** Sets the hero's level. Going down removes unspent points; points already spent stay. */
    fun cheatLevel(target: Int) {
        val t = target.coerceIn(1, Rules.MAX_LEVEL)
        val h = hero
        if (t > h.level) {
            h.gainXp(maxOf(0, Rules.xpForLevel[t] - h.xp))
        } else if (t < h.level) {
            h.level = t
            h.xp = Rules.xpForLevel[t]
            // Take back what a hero of level t cannot have, so it looks as if it reached t normally.
            h.fitPoints()
        }
        h.restoreFully()
        changed()
    }

    /** Moves the clock forward by [hours]. */
    fun cheatTime(hours: Int) {
        val total = state.minutes + hours * 60
        state.day += total / (24 * 60)
        state.minutes = total % (24 * 60)
        changed()
    }

    fun cheatRain() {
        rainLeft = if (rainLeft > 0) 0 else 120
        changed()
    }

    fun cheatGold(amount: Int) {
        state.gold += amount
        changed()
    }

    fun cheatHeal() {
        hero.restoreFully()
        changed()
    }

    /** Puts Krogg and Grak back on the map. */
    fun cheatRespawnBosses() {
        state.flags -= setOf(Story.KROGG_DEFEATED, Story.GRAK_DEFEATED, Story.GRIMFANG_DEFEATED)
        changed()
    }

    /** Starts a fight against [monster] right here, optionally as elite or shimmering variant. */
    fun cheatFight(monster: String, trait: EliteTrait?, shiny: Boolean) {
        if (mode !is Mode.Explore) return
        startBattle(monster, null, trait to shiny)
    }

    /** Puts a random piece of gear of [rarity] for the hero's level and class into the bag. */
    fun cheatLoot(rarity: Rarity): Gear {
        val g = state.addGear(Loot.generate(state, dice, hero.level, rarity, hero.cls))
        changed()
        return g
    }

    fun cheatWarp(place: Place) {
        if (mode !is Mode.Explore) return
        state.place = place
        changed()
    }

    /** Starts a prepared battle directly (previews and tests). */
    fun fight(battle: Battle) {
        battleFromScript = null
        mode = Mode.Fight(battle)
        changed()
    }

    /** Call after the battle screen showed all messages of a finished battle. */
    fun endBattle() {
        val battle = (mode as? Mode.Fight)?.battle ?: return
        val script = battleFromScript
        battleFromScript = null
        graceSteps = 3
        mode = Mode.Explore
        peaceUntil = now + 2500
        battleRoamer?.let { r ->
            when (battle.outcome) {
                Outcome.WON, Outcome.ENEMY_FLED -> {
                    herds[state.place.map]?.remove(r)
                    // It comes back after a good walk.
                    respawns.getOrPut(state.place.map) { mutableListOf() } += state.steps + 60
                }
                else -> {
                    r.hunting = false
                    r.calmUntil = now + 8000
                }
            }
        }
        battleRoamer = null
        if (battle.outcome == Outcome.LOST) state.ailments.clear() else keepAilments(battle)
        when (battle.outcome) {
            Outcome.WON, Outcome.ENEMY_FLED -> {
                script?.winFlag?.let { state.flags += it }
                runQueue()
            }
            Outcome.LOST -> {
                queue.clear()
                val lost = state.gold / 2
                state.gold -= lost
                hero.restoreFully()
                state.place = state.respawn
                mapChanged = true
                enqueue(listOf(Cmd.Say(null, T(
                    "Du erwachst an einem sicheren Ort … Du hast {0} Gold verloren.",
                    "You wake up somewhere safe... You lost {0} gold.",
                ).let { T(it.de.replace("{0}", "$lost"), it.en.replace("{0}", "$lost")) })))
            }
            Outcome.FLED, Outcome.ONGOING -> queue.clear()
        }
        changed()
    }

    // ------------------------------------------------------------ menu actions

    /** Use a consumable outside of battle. Returns a message to show. */
    fun useItemOutside(id: String): String {
        val def = Items[id]
        if (def.kind == ItemKind.FOOD && state.count(id) > 0) {
            if (state.wellFed && hero.hp >= hero.maxHp) return Msgs.alreadyFed.f(lang, hero.name)
            state.remove(id)
            sounds += de.bornim.core.audio.Sound.HEAL
            val before = hero.hp
            hero.hp = minOf(hero.maxHp, hero.hp + dice.roll(def.heal!!) + Perks.mealBonus(hero))
            state.wellFed = true
            changed()
            return Msgs.ate.f(lang, hero.name, def.name(lang), hero.hp - before)
        }
        if (def.kind != ItemKind.POTION || state.count(id) == 0) return Ui.cannotUseHere(lang)
        val cures = def.cures && state.ailments.isNotEmpty()
        if (hero.hp >= hero.maxHp && !cures) return Ui.alreadyFull(lang)
        state.remove(id)
        sounds += de.bornim.core.audio.Sound.POTION
        val before = hero.hp
        hero.hp = minOf(hero.maxHp, hero.hp + dice.roll(def.heal!!))
        if (cures) state.ailments.clear()
        changed()
        val healed = T("{0} heilt {1} TP.", "{0} recovers {1} HP.").f(lang, hero.name, hero.hp - before)
        return if (cures) Msgs.cured.f(lang, hero.name) + " " + healed else healed
    }

    /** What the hero pays for [id]; charisma makes it cheaper. */
    fun buyPrice(id: String): Int = Perks.buyPrice(hero, Items[id].price)

    fun buyPrice(g: Gear): Int = Perks.buyPrice(hero, g.price)

    fun buy(id: String): String {
        val def = Items[id]
        val price = buyPrice(id)
        if (state.gold < price) return Ui.notEnoughGold(lang)
        state.gold -= price
        state.add(id)
        sounds += de.bornim.core.audio.Sound.COINS
        changed()
        return Ui.bought.f(lang, def.name(lang))
    }

    fun sellPrice(id: String): Int = Perks.sellPrice(hero, Items[id].price / 2)

    /** Morwen brews [r] from the hero's ingredients and a little gold. */
    fun brew(r: Recipe): String {
        if (!r.affordable(state)) return Msgs.missing(lang)
        r.ingredients.forEach { (id, n) -> state.remove(id, n) }
        state.gold -= r.gold
        state.add(r.output)
        // A clever alchemist sometimes gets a second potion out of the same brew.
        if (dice.chance(Perks.extraBrewChance(hero))) {
            state.add(r.output)
            sounds += de.bornim.core.audio.Sound.POTION
            changed()
            return Msgs.brewedTwo.f(lang, Items[r.output].name(lang))
        }
        sounds += de.bornim.core.audio.Sound.POTION
        changed()
        return Msgs.brewed.f(lang, Items[r.output].name(lang))
    }

    /** Thessa's current gear stock, without the pieces already bought. */
    fun shopGear(): List<Gear> {
        val batch = state.battlesWon / 8
        return Loot.shopGear(state).filter { "$batch:${it.uid}" !in state.shopSold }
    }

    fun buyGear(g: Gear): String {
        val price = buyPrice(g)
        if (state.gold < price) return Ui.notEnoughGold(lang)
        state.gold -= price
        state.shopSold += "${state.battlesWon / 8}:${g.uid}"
        state.addGear(g.copy(uid = 0))
        sounds += de.bornim.core.audio.Sound.COINS
        changed()
        return Ui.bought.f(lang, g.name(lang))
    }

    fun sellPrice(g: Gear): Int = Perks.sellPrice(hero, maxOf(1, g.price / 4))

    fun sellGear(g: Gear): String {
        if (!state.bag.remove(g)) return Ui.cannotSell(lang)
        state.gold += sellPrice(g)
        sounds += de.bornim.core.audio.Sound.COINS
        changed()
        return Ui.sold.f(lang, g.name(lang))
    }

    /** Sells every common piece in the bag at once. */
    fun sellAllCommon(): Int {
        val junk = state.bag.filter { it.rarity == Rarity.COMMON }
        junk.forEach { state.bag.remove(it); state.gold += sellPrice(it) }
        changed()
        return junk.size
    }

    fun discard(g: Gear) {
        state.bag.remove(g)
        changed()
    }

    fun sell(id: String): String {
        val def = Items[id]
        if (!def.sellable || !state.remove(id)) return Ui.cannotSell(lang)
        state.gold += sellPrice(id)
        sounds += de.bornim.core.audio.Sound.COINS
        changed()
        return Ui.sold.f(lang, def.name(lang))
    }

    fun changed() {
        revision++
    }
}
