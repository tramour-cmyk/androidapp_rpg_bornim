package de.bornim.core

sealed interface Mode {
    data object Explore : Mode
    data class Dialog(val speaker: String?, val text: String) : Mode
    data class Fight(val battle: Battle) : Mode
    /** A shop; [brewing] adds Morwen's potion brewing and leaves out Thessa's equipment. */
    data class Shop(val stock: List<String>, val brewing: Boolean = false) : Mode
    /** The notice board before the inn (29): its notes, each to take up or leave. */
    data object Board : Mode
    data object ChapterEnd : Mode
    /** 68: a cutscene's pictures fill the screen; [Game.advance] when they are over or skipped. */
    data object TempleScene : Mode
    /** 86.10/86.9: "Rasten?" by a campfire, Rowena's counter, the bed of the inn ([Resting]); [Game.advance] to leave. */
    data class Rest(val spot: Resting.Spot) : Mode
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
        /** 154: hours that pass when the hero is carried home after a lost fight. */
        const val DEATH_HOURS = 4
        /** 198: how long a monster the hero fled from leaves them be, counted from the return to the map. */
        const val FLED_CALM_MS = 12_000L
        /** 55.1b: the shortest of a guard's longer watches at a patrol point. */
        const val LONG_WATCH_MS = 10_000L
        /** 92: how often the hero walks into a villager before they make way. */
        const val PUSH_BUMPS = 2
        const val ELITE_CHANCE = 0.12
        const val SHINY_CHANCE = 1.0 / 150
        /** Poison and bleeding carried out of a fight hurt once every this many steps. */
        const val AILMENT_STEPS = 4
        /** Share of flower tiles that carry a healing herb on a given day. */
        const val HERB_CHANCE = 0.5
        /** 68: when the morning service begins, minutes after midnight. */
        const val SUNRISE_MIN = 6 * 60 + 30
        /** Test switch (9f): monsters go about as ever but never notice or attack the hero; bumping into one still fights. */
        @Volatile var monstersIgnoreHero = false
        /** Test switch (9f.2): no line of sight and no fog: the whole map and every monster on it is in view. */
        @Volatile var seeAll = false
    }

    var mode: Mode = Mode.Explore
        private set

    /** Bumped on every change so the UI knows when to redraw. */
    var revision = 0
        private set

    /** Set when the map changed, so the app can autosave and fade. */
    var mapChanged = false

    private val queue = ArrayDeque<Cmd>()

    /** A step the hero takes back by itself after turning round at the edge of a map (67); the app walks it and clears it. */
    var stepBack: Facing? = null

    /** Short messages for the app to show as a toast. */
    val notices = ArrayDeque<T>()

    /** A beast turned back at a safe place (09.10.): the place, where the beast stood, and when (app clock); the folk there ward it off with a torch. */
    class WardOff(val x: Int, val y: Int, val beastX: Int, val beastY: Int, val atMs: Long)

    /** The latest beast turned back at a safe place, or null. */
    var lastWardOff: WardOff? = null
        private set

    /** Sound effects triggered by the last actions; the app plays and clears them. */
    val sounds = ArrayDeque<de.bornim.core.audio.Sound>()
    /** Sounds from a spot on the map, with how loud they are where the hero stands (D3.9); played and cleared like [sounds]. */
    val placedSounds = ArrayDeque<Pair<de.bornim.core.audio.Sound, Float>>()
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
    /** 198: the map's clock stood still during a fight (the map is not drawn); the calm set at its end counts from the first frame back. */
    private var clockStood = false
    // Movement of monsters is cosmetic randomness and must not shift the game's dice.
    private val roamRandom = kotlin.random.Random(state.steps * 31 + 7)
    /** Its own dice for the monsters' sounds (D3.9), so they never change where monsters go. */
    private val idleRandom = kotlin.random.Random(state.steps * 17 + 3)
    private var nextIdleAnyAt = 0L

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

    /** Whether it is dark round the hero: night outdoors, always in a cave (84.1/84.5, [Light]); rooms are lit, night or day (255). */
    val heroInDark: Boolean get() = (isNight && map.kind != MapKind.INTERIOR) || map.kind == MapKind.CAVE
    /** 255: whether the hero's torch burns ([Light.burns]). */
    val torchBurns: Boolean get() = Light.burns(state, heroInDark)

    /** Whether it rains: by chance, or as the test switch says ([Weather.mode]). */
    val raining: Boolean get() = when (Weather.mode) {
        Weather.Mode.ALWAYS -> true
        Weather.Mode.NEVER -> false
        Weather.Mode.RANDOM -> rainLeft > 0
    }

    /** How heavy the rain is now, 0 (dry) to 1: it sets in and stops over [Weather.FADE_MS]. */
    var rainLevel = 0f
        private set

    /** When the last sheet lightning flashed (app clock in ms), or a long time ago. */
    var flashAt = Long.MIN_VALUE / 2
        private set
    private var thunderAt = 0L

    /** The rain at once as heavy as the weather says (previews and tests). */
    fun settleWeather() { rainLevel = if (raining) 1f else 0f; tracks.settle(rainLevel) }

    /** Traces that stay a while: blood, footprints, dust (idea 7, draft). */
    val tracks = Tracks()

    /** A flash of sheet lightning far off, the thunder following a few seconds later. */
    fun flash() {
        flashAt = now
        thunderAt = now + Weather.THUNDER_DELAY.first + roamRandom.nextLong(Weather.THUNDER_DELAY.last - Weather.THUNDER_DELAY.first)
    }

    private fun tickClock(deltaMs: Long) {
        clockMs += deltaMs
        val target = if (raining) 1f else 0f
        rainLevel = if (rainLevel < target) minOf(target, rainLevel + deltaMs / Weather.FADE_MS) else maxOf(target, rainLevel - deltaMs / Weather.FADE_MS)
        tracks.weather(if (map.kind == MapKind.FOREST || map.kind == MapKind.TOWN) rainLevel else 0f, deltaMs)
        if (thunderAt != 0L && now >= thunderAt) {
            thunderAt = 0L
            if (map.kind == MapKind.FOREST || map.kind == MapKind.TOWN) sounds += de.bornim.core.audio.Sound.THUNDER
        }
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
            // very rarely, in heavy rain out of doors, lightning far off
            if (rainLevel > 0.8f && (map.kind == MapKind.FOREST || map.kind == MapKind.TOWN) && roamRandom.nextDouble() < Weather.FLASH_CHANCE) flash()
        }
    }

    /**
     * 89: the sun's stand for the shadows follows the hour only at a cut (a change of map, a rest, a new or loaded
     * game), so they never wander while one looks; the stand is not saved, a loaded game takes it from its hour.
     */
    fun sunCut() {
        de.bornim.core.art.MapSun.stand = de.bornim.core.art.MapSun.Stand.at(state.minutes)
    }

    init { sunCut() }

    /**
     * 86.10: rests for [kind] at [spot]: the clock moves on, then the rest's lines. A room (86.9) costs gold; a long
     * rest only once a game day. Returns why not, or null when rested; the app fades out and in around it.
     */
    fun rest(kind: Resting.Kind, spot: Resting.Spot): T? {
        if (mode !is Mode.Rest) return null
        if (kind == Resting.Kind.LONG && !Resting.longAllowed(state)) return Resting.longDone
        if (spot != Resting.Spot.FIRE && kind == Resting.Kind.SHORT) return null
        if (spot != Resting.Spot.FIRE && state.gold < Resting.ROOM_PRICE) return Resting.noGold
        if (spot != Resting.Spot.FIRE) { state.gold -= Resting.ROOM_PRICE; sounds += de.bornim.core.audio.Sound.COINS }
        sounds += de.bornim.core.audio.Sound.HEAL
        Resting.pass(state, kind.minutes)
        val sparked = state.spark
        Resting.ends(state)
        val lines = mutableListOf<Cmd>()
        if (kind == Resting.Kind.LONG) {
            hero.restoreFully()
            state.ailments.clear()
            state.longRestDay = state.day
            rainLeft = 0
            lines += Cmd.Say(null, Resting.longRested)
        } else {
            val before = hero.hp
            hero.hp = minOf(hero.maxHp, hero.hp + Resting.shortHeal(hero))
            lines += Cmd.Say(null, Resting.shortRested.let { T(it.de.replace("{0}", "${hero.hp - before}"), it.en.replace("{0}", "${hero.hp - before}")) })
        }
        // [84.5.rast]: behind the rest's own line, only when the spark was burning
        if (sparked) lines += Cmd.Say(null, Light.sparkFaded)
        // 114 (user 16.10.): a room booked at Rowena's counter: the hero wakes beside the bed, not at the counter
        if (spot == Resting.Spot.TAVERN && state.place.map == Story.START.map) state.place = Story.START
        state.respawn = state.place
        if (spot == Resting.Spot.FIRE) {
            val meat = state.count("raw_meat")
            if (meat > 0) {
                // Raw meat goes on the fire while the hero rests.
                state.remove("raw_meat", meat)
                state.add("roast_meat", meat)
                lines += Cmd.Say(null, Msgs.roasted.let { T(it.de.replace("{0}", "$meat"), it.en.replace("{0}", "$meat")) })
            }
        }
        sunCut()
        // the villagers, the shadows and the save follow the new hour, as after a change of map
        walkers.clear()
        mapChanged = true
        queue.addAll(0, lines)
        advance()
        return null
    }

    /** 86.9: a mead at Rowena's counter: the breath is full; the fifth makes the hero drunk until the next rest.
     *  173 (user 18.10.): once drunk, Rowena pours no more and only says [Resting.rowenaEnough]. */
    fun drinkMead(): T {
        if (state.drunk) return Resting.rowenaSays(state, hero.name, false)
        val price = Resting.meadPrice(state)
        if (state.gold < price) return Resting.noGold
        state.gold -= price
        if (price > 0) sounds += de.bornim.core.audio.Sound.COINS
        Stamina.refill(state)
        state.mead++
        changed()
        return if (state.drunk) Resting.drunkNow else Resting.meadDrunk
    }

    /** 139: Rowena buys all the hero's raw meat at the counter, at the price Thessa and Morwen pay. */
    fun sellMeat(): T? {
        val n = state.count("raw_meat")
        if (n < 1) return null
        sell("raw_meat", n)
        return Resting.meatThanks
    }

    // ------------------------------------------------------------ villagers strolling around

    private val walkers = HashMap<String, List<Walker>>()

    private fun walkersHere(): List<Walker> = walkers.getOrPut(state.place.map) {
        map.npcs.filter { it.moves }.map { n ->
            // 5l (draft): coming into the village, everyone is already where their day has taken them
            Walker(n).also { w -> VillageDay.stopAt(n.id, state.minutes)?.let { st -> if (map.walkable(st.x, st.y, state)) { w.x = st.x; w.y = st.y; w.fromX = st.x; w.fromY = st.y } } }
        }
    }

    /** Where a strolling villager is right now, null for people who stand still. */
    fun walkerOf(npc: Npc): Walker? = if (!npc.moves) null else walkersHere().firstOrNull { it.npc === npc }

    /** 5la: a villager who has reached their door for the night has gone in: not drawn, not met, in no one's way. */
    fun indoors(npc: Npc): Boolean {
        if (!npc.moves) return false
        val st = VillageDay.stopAt(npc.id, state.minutes) ?: return false
        val w = walkerOf(npc) ?: return false
        return st.inside && w.x == st.x && w.y == st.y
    }

    private fun shown(w: Walker) = w.npc.visible(state) && !indoors(w.npc)

    /** The person at ([x], [y]), wherever they strolled to. */
    fun npcAt(x: Int, y: Int): Npc? = map.npcAt(x, y, state)
        ?: walkersHere().firstOrNull { it.x == x && it.y == y && shown(it) }?.npc

    private fun updateWalkers() {
        val p = state.place
        for (w in walkersHere()) {
            // 62f: the map remembers where the hero came upon someone at one of their habits
            if (kotlin.math.abs(w.x - p.x) + kotlin.math.abs(w.y - p.y) <= 3 && shown(w))
                MapPeople.habitNow(w.npc.id, state.minutes, isNight, w.x, w.y)?.let { state.flags += MapPeople.seenAt(w.npc.id, it) }
            if (now < w.nextMoveAt || !shown(w)) continue
            if (w.npc.patrol.isNotEmpty()) {
                patrol(w)
                continue
            }
            // 5l (draft): off to the next place of the day, else stroll about there
            val stop = VillageDay.stopAt(w.npc.id, state.minutes)
            if (stop != null && !VillageDay.near(stop, w.x, w.y)) {
                goTowards(w, stop.x, stop.y)
                continue
            }
            w.nextMoveAt = now + 1500 + roamRandom.nextInt(2500)
            // Stay put while the hero stands right next to them.
            if (kotlin.math.abs(w.x - p.x) + kotlin.math.abs(w.y - p.y) <= 1) continue
            val d = Facing.entries[roamRandom.nextInt(4)]
            val nx = w.x + d.dx; val ny = w.y + d.dy
            w.facing = d
            if (kotlin.math.abs(nx - (stop?.x ?: w.npc.x)) + kotlin.math.abs(ny - (stop?.y ?: w.npc.y)) > (stop?.wander ?: w.npc.wander)) continue
            if (!free(nx, ny) || map.warpAt(nx, ny) != null || (nx == p.x && ny == p.y)) continue
            w.fromX = w.x; w.fromY = w.y
            w.x = nx; w.y = ny
            w.movedAt = now
            changed()
        }
    }

    private var bumpedBy: String? = null
    private var bumps = 0

    /** 92: whether a villager who gives way when pushed (not a guard on the round) stands at ([x], [y]). */
    fun yields(x: Int, y: Int): Boolean = yielderAt(x, y) != null

    private fun yielderAt(x: Int, y: Int) = walkersHere().firstOrNull { it.x == x && it.y == y && shown(it) && it.npc.patrol.isEmpty() }

    /**
     * 92: the hero walks into whoever stands next to them in [dir]; a villager makes room when the hero keeps
     * walking into them. Also for free walking, where the hero pushes against them without a step (test 0.1.791).
     */
    fun nudge(dir: Facing) {
        val p = state.place
        yielderAt(p.x + dir.dx, p.y + dir.dy)?.let { w ->
            bumps = if (bumpedBy == w.npc.id) bumps + 1 else 1
            bumpedBy = w.npc.id
            if (bumps >= PUSH_BUMPS) makeWay(w, dir)
        } ?: run { bumpedBy = null; bumps = 0 }
    }

    /**
     * 92: the villager [w] the hero walks into in [dir] steps aside, to the left or right of the way, else on ahead;
     * where there is no room at all the two change places. They then stay a moment before going on with their day.
     */
    private fun makeWay(w: Walker, dir: Facing) {
        val p = state.place
        fun open(x: Int, y: Int) = map.walkable(x, y, state) && map.warpAt(x, y) == null && free(x, y) && !(x == p.x && y == p.y)
        val sides = Facing.entries.filter { it != dir && it != dir.opposite }.let { if (roamRandom.nextBoolean()) it else it.reversed() }
        val to = (sides + dir).map { (w.x + it.dx) to (w.y + it.dy) }.firstOrNull { (x, y) -> open(x, y) } ?: (p.x to p.y)
        w.fromX = w.x; w.fromY = w.y
        w.facing = Facing.entries.first { it.dx == to.first - w.x && it.dy == to.second - w.y }
        w.x = to.first; w.y = to.second
        w.movedAt = now
        w.nextMoveAt = now + 4000
        npcFacing.remove(w.npc.id)
        bumpedBy = null; bumps = 0
    }

    /** One step of a villager on the way to ([tx], [ty]) (5l), along the shortest way round houses and fences, past no door. */
    private fun goTowards(w: Walker, tx: Int, ty: Int) {
        val p = state.place
        w.nextMoveAt = now + 650
        // wait while the hero stands next to them, e.g. to talk
        if (kotlin.math.abs(w.x - p.x) + kotlin.math.abs(w.y - p.y) <= 1) return
        fun open(x: Int, y: Int) = map.walkable(x, y, state) && map.warpAt(x, y) == null
        // round the others where there is room, else straight on and wait for them
        val d = VillageDay.firstStep(w.x, w.y, tx, ty, map.width, map.height) { x, y -> open(x, y) && free(x, y) && !(x == p.x && y == p.y) }
            ?: VillageDay.firstStep(w.x, w.y, tx, ty, map.width, map.height) { x, y -> open(x, y) } ?: return
        val nx = w.x + d.dx; val ny = w.y + d.dy
        w.facing = d
        npcFacing.remove(w.npc.id)
        // someone in the way: wait a moment, they move on
        if (!free(nx, ny) || (nx == p.x && ny == p.y)) { w.nextMoveAt = now + 400 + roamRandom.nextInt(600); return }
        w.fromX = w.x; w.fromY = w.y
        w.x = nx; w.y = ny
        w.movedAt = now
        changed()
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
            // 55.1b: every other stop a longer watch (the guard grounds his spear), turned to the road or the village
            val long = roamRandom.nextBoolean()
            w.facing = if (long) listOf(Facing.DOWN, Facing.LEFT, Facing.RIGHT)[roamRandom.nextInt(3)]
                else if (roamRandom.nextBoolean()) Facing.UP else Facing.entries[roamRandom.nextInt(4)]
            npcFacing.remove(w.npc.id)
            w.nextMoveAt = now + if (long) LONG_WATCH_MS + roamRandom.nextInt(6000) else 2500L + roamRandom.nextInt(2500)
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
        resumeClock(nowMs)
        now = nowMs
        if (mode != Mode.Explore) return
        tickClock(delta)
        talkingTo?.let { npc -> if (queue.isEmpty()) { Hail.heard(state, npc, after = true); talkingTo = null } }
        updateWalkers()
        updateHails()
        walkerTracks()
        updateRoamers(nowMs)
    }

    // ------------------------------------------------------------ 134.1: people with news hail the hero

    /** The person talked to until the talk is over, then what they would say next counts as heard ([Hail.heard]). */
    private var talkingTo: Npc? = null

    /** When each person near the hero came to notice him with news; [Long.MIN_VALUE]: noticed, nothing to show. */
    private val hails = HashMap<String, Long>()
    /** 134.2: who will hail the hero when he comes a little nearer, worked out once on coming within reach. */
    private val soon = HashMap<String, Boolean>()
    private var hailsMap = ""
    /** 134.3: before this no one else calls, so two people with news do not call at once. */
    private var nextCallAt = 0L

    /**
     * People notice the hero by the rules of the monsters: near enough ([Perks.noticeRange]) and in sight, which
     * the night shortens. Whoever notices him with news hails him once on coming near; again only once he has
     * gone off (two tiles beyond that) and comes back.
     */
    private fun updateHails() {
        val p = state.place
        // coming into a place counts as coming near anew
        if (p.map != hailsMap) { hails.clear(); soon.clear(); hailsMap = p.map }
        val range = Perks.noticeRange(hero)
        for (npc in map.npcs) {
            if (npc.look.startsWith("monster:") || !npc.visible(state) || indoors(npc)) { hails.remove(npc.id); soon.remove(npc.id); continue }
            val w = walkerOf(npc)
            val x = w?.x ?: npc.x
            val y = w?.y ?: npc.y
            val dist = kotlin.math.abs(x - p.x) + kotlin.math.abs(y - p.y)
            if (npc.id in hails) {
                if (dist > range + 2) hails.remove(npc.id)
            } else if (dist <= range && inSight(x + 0.5, y + 0.5)) {
                val news = Hail.news(state, npc)
                hails[npc.id] = if (news) now else Long.MIN_VALUE
                // 134.3: with the sign a short call without words, never two at once
                if (news && now >= nextCallAt) Hail.voice(npc.id)?.let { placedSounds += it to Hail.callVolume(dist); nextCallAt = now + Hail.CALL_GAP_MS }
            }
            // 134.2: whoever is about to hail him (two tiles before) has the pictures of the gesture drawn ahead
            if (dist > range + 2 || npc.id in hails) soon.remove(npc.id)
            else if (npc.id !in soon) soon[npc.id] = Hail.news(state, npc)
        }
    }

    /** 134.2: whether [npc] is about to hail the hero, so the gesture can be drawn ahead. */
    fun hailSoon(npc: Npc): Boolean = soon[npc.id] == true

    /** 134.2: how long ago [npc] came to hail the hero with the sign, null if it does not. */
    fun hailAge(npc: Npc): Long? = hails[npc.id]?.takeIf { it != Long.MIN_VALUE }?.let { now - it }

    /** 306: whether [npc] keeps still for its hail now ([Hail.calms]); after that the hero standing still is ignored as by everyone. */
    fun hailCalms(npc: Npc): Boolean = hailAge(npc)?.let(Hail::calms) == true

    /** 134.1: whether [npc] shows the golden sign now. */
    fun hailing(npc: Npc): Boolean {
        val at = hails[npc.id] ?: return false
        return at != Long.MIN_VALUE && Hail.showing(now - at)
    }

    /** 61 (test of 0.1.662): villagers leave prints in the wet like the hero; between tiles where they are drawn. */
    private fun walkerTracks() {
        if (!Tracks.draft) return
        val outdoors = map.kind == MapKind.FOREST || map.kind == MapKind.TOWN
        if (!outdoors) return
        for (w in walkersHere()) {
            if (!shown(w) || w.npc.look.startsWith("monster:")) continue
            val t = ((now - w.movedAt).toDouble() / w.moveMs).coerceIn(0.0, 1.0)
            val x = w.fromX + (w.x - w.fromX) * t + 0.5; val y = w.fromY + (w.y - w.fromY) * t + 0.5
            val yaw = Math.toDegrees(kotlin.math.atan2((w.x - w.fromX).toDouble(), (w.y - w.fromY).toDouble()))
            tracks.walked(map.id, x, y, yaw, map.tile(w.x, w.y), outdoors, false, now, who = w.npc.id)
        }
    }

    private val sight = Sight(state) { freeWalk.lookYaw() }

    /** Wild areas (forest, cave) are covered by fog until the hero has seen them. */
    val fogged: Boolean get() = map.kind == MapKind.FOREST || map.kind == MapKind.CAVE

    /** [view]: for drawing the place (see [Sight.fog]); false for the map in the menu. */
    fun fog(x: Int, y: Int, view: Boolean = true): Fog {
        if (!fogged) return Fog.VISIBLE
        // explored as ever, so switching the test view off again leaves the map as the hero has seen it
        val f = sight.fog(map, x, y, isNight, view)
        return if (seeAll) Fog.VISIBLE else f
    }

    /** Whether the point ([x], [y]), in tiles, is in sight, finer than a tile (see [Sight.inSight]). */
    fun inSight(x: Double, y: Double): Boolean = !fogged || seeAll || sight.inSight(map, x, y, isNight)

    /** Free walking of the hero (13g): a position between the tiles, used by the diagonal view. */
    val freeWalk = FreeWalk(this)

    /** Monsters walking around on the current map. */
    val roamers: List<Roamer> get() = herd()

    /**
     * 120: how close the nearest hunter is, for the music (see [de.bornim.core.audio.Threat]). Monsters that leave the
     * hero be (calm, afraid of a far stronger hero, on the way home) and lurkers in hiding do not count, nor does a hero in
     * a safe place; one that hunts the hero has noticed him. Only reads: no herd is made here.
     */
    fun threat(): de.bornim.core.audio.Threat {
        val none = de.bornim.core.audio.Threat.NONE
        if (mode != Mode.Explore) return none
        val herd = herds[state.place.map] ?: return none
        val p = state.place
        if (map.safeZones.any { it.contains(p.x, p.y) }) return none
        // as in updateRoamers
        val strongHero = hero.level >= map.areaLevel + 5
        val far = de.bornim.core.audio.Threat.FAR_TILES
        val range = Perks.noticeRange(hero) + Light.noticeExtra(state, heroInDark)
        var near = 0f
        var noticed = false
        for (r in herd) {
            if (monstersIgnoreHero || now < r.calmUntil || now < peaceUntil || (strongHero && r.trait == null)) continue
            if (r.hunting) { noticed = true; continue }
            if (r.temper != Temper.HUNTER || r.returning) continue
            val dist = kotlin.math.abs(r.x - p.x) + kotlin.math.abs(r.y - p.y)
            near = maxOf(near, ((far - dist).toFloat() / (far - range)).coerceIn(0f, 1f))
        }
        return de.bornim.core.audio.Threat(near, noticed)
    }

    /** 152: someone of the village walking about stands on ([x], [y]). */
    fun walkerAt(x: Int, y: Int): Boolean = walkersHere().any { it.x == x && it.y == y && shown(it) }

    fun roamerAt(x: Int, y: Int): Roamer? = herd().firstOrNull { it.x == x && it.y == y }

    /** Walkable for the hero and monsters: free of walls, people and monsters. */
    fun free(x: Int, y: Int): Boolean =
        map.walkable(x, y, state) && !door(x, y) && roamerAt(x, y) == null && walkersHere().none { it.x == x && it.y == y && shown(it) }

    /** 215 (Rückläufer Build 38): a house door is a way out the hero never steps onto; it is taken or knocked at from in front with the button. */
    fun door(x: Int, y: Int): Boolean = map.tile(x, y) == Tile.DOOR && map.warpAt(x, y) != null

    /** Call once after creating or loading a game. */
    fun begin() {
        // experience beyond a chapter's level cap is not kept (older saves kept it): cut back to the cap
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
        val warp = map.warpAt(nx, ny)?.takeUnless { door(nx, ny) }
        if (warp != null && warp.requires != null && !state.has(warp.requires)) {
            changed()
            if (warp.turnBack) {
                Story.southEdge(state)?.let { (text, short) -> if (short) notices += text else enqueue(listOf(Cmd.Say(null, text))) }
                stepBack = dir.opposite
            } else enqueue(warp.knock?.invoke(state, isNight) ?: warp.denied)
            return Move.Blocked
        }
        roamerAt(nx, ny)?.let { r ->
            // Walking into a monster attacks it; from behind the hero strikes first.
            engage(r, if (r.facing == dir || (r.temper == Temper.LURKER && !r.hunting)) Opening.HERO_FIRST else Opening.NORMAL)
            return Move.Blocked
        }
        nudge(dir)
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
        // 215 (Chef 19.10.): a way out is no longer taken by stepping onto it, only with the action button ([interact])
        if (map.warpAt(p.x, p.y) != null) return
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
        val day = herbDay()
        if (state.picked["${state.place.map}:$x:$y"] == day) return false
        // Fixed per tile and day, so the plant does not flicker and the map can show it.
        var h = state.place.map.hashCode() * 31 + x * 73_856_093 + y * 19_349_663 + day * 83_492_791
        h = (h xor (h ushr 13)) * 0x5bd1e995
        h = h xor (h ushr 15)
        return Math.floorMod(h, 100) < HERB_CHANCE * 100
    }

    /** 138: herbs grow back at sunrise, not at midnight; before sunrise it is still the day before. */
    private fun herbDay(): Int = if (state.minutes >= SUNRISE_MIN) state.day else state.day - 1

    /** Walking onto a herb picks it; it grows back the next morning. */
    private fun pickHerbs() {
        val p = state.place
        if (!herbAt(p.x, p.y)) return
        state.picked["${p.map}:${p.x}:${p.y}"] = herbDay()
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
        resumeClock(nowMs)
        now = nowMs
        if (mode != Mode.Explore) return
        val herd = herd()
        val p = state.place
        val strongHero = hero.level >= map.areaLevel + 5
        var moved = false
        val heroSafe = map.safeZones.firstOrNull { it.contains(p.x, p.y) }
        for (r in herd) {
            hearIdle(r, kotlin.math.abs(r.x - p.x) + kotlin.math.abs(r.y - p.y))
            if (now < r.nextMoveAt) continue
            val dist = kotlin.math.abs(r.x - p.x) + kotlin.math.abs(r.y - p.y)
            val fromHome = kotlin.math.abs(r.x - r.homeX) + kotlin.math.abs(r.y - r.homeY)
            val calm = monstersIgnoreHero || now < r.calmUntil || now < peaceUntil
            // Weak monsters keep away from a far stronger hero; elites are never afraid.
            val afraid = strongHero && r.trait == null
            // 84.4: running is loud, the hero is heard sooner; a lurker waits in its place and only notices what comes close
            // 84.5: a spark of light gives the hero away 2 tiles sooner, sneaking or not
            val sees = heroSafe == null && dist <= (if (r.temper == Temper.LURKER) 2 else Perks.noticeRange(hero) + Light.noticeExtra(state, heroInDark) + (if (state.running) Stamina.RUN_NOISE else 0))
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
                            // the beast holds a moment while the torch comes out of the fire, then draws back
                            if (heroSafe != null && dist <= 7) {
                                lastWardOff = WardOff(heroSafe.x, heroSafe.y, r.x, r.y, now)
                                r.nextMoveAt = now + 1_100
                            } else r.nextMoveAt = now + 600
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
                    placedSounds += de.bornim.core.audio.Sound.ALERT to de.bornim.core.audio.Ambience.heardAt(dist)
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
                r.temper == Temper.LURKER -> {
                    // 9i.2: it stays in its place, but turns to face the hero coming near (the map eases the turn)
                    if (dist <= 4) faceTowards(r, p.x, p.y)
                    r.nextMoveAt = now + 1000
                }
                else -> wander(r)
            }
            moved = true
        }
        if (moved) changed()
    }

    /**
     * D3.9: a monster that is not hunting is heard now and then, close by only and never two at once. The first time
     * a monster is looked at it only draws its pause, so a herd does not all speak up when the hero arrives.
     */
    private fun hearIdle(r: Roamer, dist: Int) {
        if (r.hunting || now < r.nextIdleAt) return
        val first = r.nextIdleAt == 0L
        r.nextIdleAt = now + (if (first) idleRandom.nextLong(de.bornim.core.audio.MonsterIdle.PAUSE_MIN_MS) else 0L) +
            de.bornim.core.audio.MonsterIdle.pause(idleRandom)
        if (first || now < nextIdleAnyAt) return
        val sound = de.bornim.core.audio.MonsterIdle.of(r.monster) ?: return
        val volume = de.bornim.core.audio.MonsterIdle.volume(dist)
        if (volume <= 0f) return
        nextIdleAnyAt = now + de.bornim.core.audio.MonsterIdle.GAP_MS
        placedSounds += sound to volume
    }

    /** Turns [r] to the one of its four directions nearest to ([x], [y]), without a step. */
    private fun faceTowards(r: Roamer, x: Int, y: Int) {
        val dx = x - r.x; val dy = y - r.y
        if (dx == 0 && dy == 0) return
        r.facing = if (kotlin.math.abs(dx) >= kotlin.math.abs(dy)) (if (dx > 0) Facing.RIGHT else Facing.LEFT)
            else (if (dy > 0) Facing.DOWN else Facing.UP)
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
        var moved = false
        for (d in tried) if (moveRoamer(r, d, ms)) { moved = true; break }
        // the ground slows a monster as it slows the hero
        r.nextMoveAt = now + (if (moved) r.moveMs else (ms * Terrain.PACE).toLong()) + 40
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
        r.moveMs = (ms * Terrain.PACE * Terrain.stepFactor(map, nx, ny)).toLong()
        return true
    }

    /** Starts the fight against a monster on the map. */
    /** 198: moves the calm after a fight on by the time the fight took, so it starts when the hero is back on the map. */
    private fun resumeClock(nowMs: Long) {
        if (!clockStood) return
        clockStood = false
        val gap = nowMs - now
        if (gap <= 0) return
        if (peaceUntil > now) peaceUntil += gap
        for (r in herd()) if (r.calmUntil > now) r.calmUntil += gap
    }

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
        // 216: the nearest thing within reach, not only the tile ahead; the hero turns to it
        val (tx, ty) = actionTarget() ?: return
        if (tx == state.place.x && ty == state.place.y) { map.warpAt(tx, ty)?.let { pass(it) }; return }
        val turn = freeWalk.turnTo(tx, ty)
        if (state.place.facing != turn) face(turn)
        val p = state.place
        // 215 (Rückläufer Build 38): through a door in front, or knocking while it stays shut
        if (door(tx, ty)) {
            val w = map.warpAt(tx, ty)!!
            if (w.requires == null || state.has(w.requires)) pass(w)
            else { sounds += de.bornim.core.audio.Sound.KNOCK; enqueue(w.knock?.invoke(state, isNight) ?: w.denied) }  // 215.1
            return
        }
        roamerAt(tx, ty)?.let { r ->
            engage(r, if (r.facing == p.facing || (r.temper == Temper.LURKER && !r.hunting)) Opening.HERO_FIRST else Opening.NORMAL)
            return
        }
        npcAt(tx, ty)?.let { npc ->
            npcFacing[npc.id] = p.facing.opposite
            state.flags += MapMarks.met(npc.id)
            val cmds = Jobs.handIn(state, npc.id) ?: npc.talk(state)
            Hail.heard(state, npc, after = false)
            hails[npc.id] = Long.MIN_VALUE
            talkingTo = npc
            enqueue(cmds)
            return
        }
        map.signs[tx to ty]?.let {
            enqueue(listOf(Cmd.Say(null, it)))
            return
        }
        Jobs.findAt(state, map.id, map.tile(tx, ty))?.let { return enqueue(it) }
        when (map.tile(tx, ty)) {
            Tile.NOTICE -> { Jobs.read(state); mode = Mode.Board; changed() }
            Tile.CHEST -> openChest(tx, ty)
            // 155: the goblins' fire stays, but nobody rests among the monsters
            Tile.CAMPFIRE -> if (map.kind == MapKind.CAVE) say(T("Das Feuer der Goblins. Es ist viel zu gefährlich, hier in der Höhle zu rasten.", "The goblins' fire. It is far too dangerous to rest here in the cave."))
                else { mode = Mode.Rest(Resting.Spot.FIRE); changed() }
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
            Tile.HEARTH -> say(T("Das Feuer knackt im Herd. Über der Glut hängt ein rußiger Kessel.", "The fire crackles in the hearth. A sooty kettle hangs over the embers."))
            Tile.BENCH -> say(if (map.kind == MapKind.INTERIOR) T("Eine Bank, blank gesessen. Im Holz sind Namen eingeritzt.", "A bench, worn smooth. Names are carved into the wood.")
                else T("Eine Bank zum Ausruhen. Von hier hat man den ganzen Dorfplatz im Blick.", "A bench to rest on. From here you can see the whole village square."))
            // 86.9: in the inn a bed is a room for gold; elsewhere it is someone else's
            Tile.BED -> if (map.id == "inn") { mode = Mode.Rest(Resting.Spot.ROOM); changed() } else say(T("Ein weiches Bett.", "A soft bed."))
            Tile.ALTAR -> say(
                if (state.has(Story.CHAPTER1_DONE)) T("Das Sonnenamulett strahlt auf dem Altar.", "The Sun Amulet shines on the altar.")
                else T("Auf dem Altar ist eine leere Halterung. Hier lag das Sonnenamulett.", "There's an empty holder on the altar. This is where the Sun Amulet lay.")
            )
            else -> {}
        }
    }

    private fun say(t: T) = enqueue(listOf(Cmd.Say(null, t)))

    /** 215: through a way out the hero stands on, into the place it leads to. */
    private fun pass(warp: Warp) {
        // D3.1: only a real door creaks; cave mouths, paths and map edges are passed in silence (the steps go on)
        if (map.tile(warp.x, warp.y) == Tile.DOOR) sounds += de.bornim.core.audio.Sound.DOOR
        state.place = warp.to
        sunCut()
        if (World.maps[warp.to.map]?.kind == MapKind.INTERIOR) state.flags += MapPeople.been(warp.to.map)
        graceSteps = 3
        mapChanged = true
        changed()
        runOnEnter()
    }

    private fun openChest(x: Int, y: Int) {
        val chest = map.chestAt(x, y) ?: return say(Ui.nothingHere)
        // Gwenna's ring (29) lies here once her job is taken, even in a chest emptied before
        if (Jobs.ringIn(state, chest.id)) {
            state.openedChests += chest.id
            sounds += de.bornim.core.audio.Sound.CHEST
            return enqueue(listOf(Cmd.Say(null, T("Unter Lumpen und Knochen am Boden der Truhe: ein schmaler Ring aus angelaufenem Silber.", "Under rags and bones at the bottom of the chest: a slim ring of tarnished silver.")), Cmd.Give(Jobs.RING)))
        }
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

    /** Takes up a job from the notice board (29); the board stays open. */
    fun takeJob(id: String) { Jobs.take(state, Jobs[id]); changed() }

    /** Gives a job up again (29e): it goes back on the board. */
    fun dropJob(id: String) { Jobs.drop(state, Jobs[id]); changed() }

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
                    mode = Mode.Dialog(c.speaker?.invoke(lang)?.replace("{name}", hero.name), c.text(lang).replace("{name}", hero.name))
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
                            // "@gear:RARITY" or "@gear:RARITY:SLOT"
                            val parts = c.item.removePrefix("@gear:").split(":")
                            val min = Rarity.valueOf(parts[0])
                            val slot = parts.getOrNull(1)?.let { GearSlot.valueOf(it) }
                            val ilvl = maxOf(map.areaLevel, hero.level)
                            val g = state.addGear(Loot.generate(state, dice, ilvl, Loot.rarityFor(state, dice, ilvl, special = true, floor = min), hero.cls, slot))
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
                    buyback.clear()
                    mode = Mode.Shop(c.stock, c.brewing)
                    changed()
                    return
                }
                Cmd.Rest -> {
                    sounds += de.bornim.core.audio.Sound.HEAL
                    hero.restoreFully()
                    state.ailments.clear()
                    state.respawn = state.place
                    Stamina.refill(state)
                    sunCut()
                }
                Cmd.ChapterEnd -> {
                    mode = Mode.ChapterEnd
                    changed()
                    return
                }
                Cmd.TempleScene -> {
                    mode = Mode.TempleScene
                    changed()
                    return
                }
                Cmd.Tavern -> {
                    mode = Mode.Rest(Resting.Spot.TAVERN)
                    changed()
                    return
                }
                is Cmd.Morning -> {
                    // the night counts as a rest (68g): healed, the clock at sunrise of the next day, the hero where the morning finds them
                    hero.restoreFully()
                    state.ailments.clear()
                    val sparked = state.spark
                    Resting.ends(state)
                    // [84.5.rast] (84.1T.1): the first line after waking, before anyone speaks, only when the spark was burning
                    if (sparked) queue.addFirst(Cmd.Say(null, Light.sparkFaded))
                    if (state.minutes >= SUNRISE_MIN) state.day++
                    state.minutes = SUNRISE_MIN
                    state.place = c.place
                    state.respawn = c.place
                    if (World.maps[c.place.map]?.kind == MapKind.INTERIOR) state.flags += MapPeople.been(c.place.map)
                    state.longRestDay = state.day
                    mapChanged = true
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
        sunCut()
        changed()
    }

    /** The test switch: chance, always, never (1a). */
    fun cheatRain() {
        Weather.mode = Weather.Mode.entries[(Weather.mode.ordinal + 1) % Weather.Mode.entries.size]
        changed()
    }

    /** Test: a flash of sheet lightning as soon as the map runs again (pressed in the menu, the map's clock stands still; 10.10., 1.4). */
    fun cheatFlash() {
        flashPending = true
        changed()
    }
    private var flashPending = false

    /** Lets a flash asked for in the test tab go off; the map calls this once it is in view again. */
    fun releaseFlash() { if (flashPending && mode == Mode.Explore) { flashPending = false; flash() } }

    fun cheatGold(amount: Int) {
        state.gold += amount
        changed()
    }

    /** Fills every supply (draughts, flasks, food, ingredients; not keys) up to at least [n], torches to at least two (213). */
    fun cheatSupplies(n: Int = 10) {
        for (d in Items.all) if (d.kind != ItemKind.KEY && state.count(d.id) < n) state.add(d.id, n - state.count(d.id))
        val torches = state.bag.count { it.base == "torch" } + (if (state.hero.item(GearSlot.OFF_HAND)?.base == "torch") 1 else 0)
        repeat(2 - torches) { state.addGear(Loot.torch(0)) }
        // D4.1: the smoke bundle is a key item but a supply for the fight against Krogg; one is enough
        if (state.count(Story.SMOKE_BUNDLE) == 0) state.add(Story.SMOKE_BUNDLE, 1)
        changed()
    }

    /**
     * Test (9f): a wolf with its young and a goblin with its scout, three to five steps from the hero on free ground,
     * to watch them go about. Returns how many leaders were placed (the map may have no room).
     */
    fun cheatBringPacks(): Int = cheatBring(listOf("wolf", "goblin"))

    /**
     * Test (9i): [monsters] three to five steps from the hero on free ground, each with its pack. With [calmMs] they
     * leave the hero alone that long, so they can be watched walking and standing about. Returns how many were placed.
     */
    fun cheatBring(monsters: List<String>, calmMs: Long = 0): Int {
        val herd = herd()
        val p = state.place
        val spots = ArrayList<Pair<Int, Int>>()
        for (y in p.y - 5..p.y + 5) for (x in p.x - 5..p.x + 5) {
            val d = kotlin.math.abs(x - p.x) + kotlin.math.abs(y - p.y)
            if (d !in 3..5 || x !in 0 until map.width || y !in 0 until map.height) continue
            if (!map.walkable(x, y, state) || map.tile(x, y) == Tile.TREE || map.warpAt(x, y) != null || map.triggers.any { it.x == x && it.y == y }) continue
            if (herd.any { kotlin.math.abs(it.x - x) + kotlin.math.abs(it.y - y) < 3 }) continue
            if (map.npcs.any { it.x == x && it.y == y }) continue
            spots += x to y
        }
        spots.shuffle(roamRandom)
        var placed = 0
        for (monster in monsters) {
            val spot = spots.firstOrNull { s -> herd.none { kotlin.math.abs(it.x - s.first) + kotlin.math.abs(it.y - s.second) < 3 } } ?: break
            herd += Roamer(nextRoamerUid++, monster, spot.first, spot.second, spot.first, spot.second, null, false, MonsterLook(roamRandom.nextInt())).also {
                it.facing = Facing.entries[roamRandom.nextInt(4)]
                it.nextMoveAt = now + 800
                if (calmMs > 0) it.calmUntil = now + calmMs
            }
            placed++
        }
        changed()
        return placed
    }

    fun cheatHeal() {
        hero.restoreFully()
        changed()
    }

    /** Puts Krogg and Grak back on the map. */
    fun cheatRespawnBosses() {
        state.flags -= setOf(Story.KROGG_DEFEATED, Story.GRAK_DEFEATED, Story.GRIMFANG_DEFEATED, Story.SMOKE_GIVEN)
        changed()
    }

    /** Starts a fight against [monster] right here, optionally as elite or shimmering variant. */
    /**
     * Starts a fight with [monster] for testing: an elite [trait] or [shiny], who strikes first ([opening]), and for foes
     * with several kits which one it carries ([kit], or null for any).
     */
    fun cheatFight(monster: String, trait: EliteTrait?, shiny: Boolean, opening: Opening = Opening.NORMAL, kit: Int? = null) {
        if (mode !is Mode.Explore) return
        val kits = MonsterKits.variants(monster)
        // the kit follows from the look's seed: pick a seed that lands on the one asked for
        val look = if (kit != null && kits > 0) {
            val r = kotlin.random.Random.nextInt(0, 1 shl 20) * kits
            MonsterLook(r + kit.mod(kits), shiny, trait?.color)
        } else null
        startBattle(monster, null, trait to shiny, opening, look)
        (mode as? Mode.Fight)?.battle?.probe = true
    }

    /** Arms the hero for testing: a plain weapon of [base] in the weapon hand, or none; what it held goes into the bag. */
    fun cheatWeapon(base: String?) {
        hero.unequip(GearSlot.MAIN_HAND)?.let { state.bag += it }
        if (base != null) state.addGear(Gear(0, base, Rarity.COMMON, hero.level)).also { g -> state.bag.remove(g); hero.equip(g).forEach { state.bag += it } }
        changed()
    }

    /** Fills the hero's other hand for testing: a shield, a second weapon, or nothing. */
    fun cheatOffHand(base: String?) {
        hero.unequip(GearSlot.OFF_HAND)?.let { state.bag += it }
        if (base != null) state.addGear(Gear(0, base, Rarity.COMMON, hero.level)).also { g ->
            state.bag.remove(g)
            (if (g.def.isWeapon) hero.equipOffHand(g) else hero.equip(g)).forEach { state.bag += it }
        }
        changed()
    }

    /** Puts a random piece of gear of [rarity] for the hero's level and class into the bag. */
    fun cheatLoot(rarity: Rarity): Gear {
        val g = state.addGear(Loot.generate(state, dice, hero.level, rarity, hero.cls))
        changed()
        return g
    }

    /**
     * 100 (user 15.10., 20:5x: the temple scene could not be tested without playing the chapter through): the cave
     * done, Lyra free, the sun amulet in the bag, an evening, the hero before Aldric in his house; talking to him
     * brings the amulet home and the chapter's end follows.
     */
    fun cheatChapterEnd() {
        if (mode !is Mode.Explore) return
        state.flags += listOf(Story.INTRO_DONE, Story.QUEST_STARTED, Story.BARRIER_OPEN, Story.KROGG_DEFEATED, Story.GRAK_DEFEATED, Story.LYRA_RESCUED)
        if (state.count("sun_amulet") == 0) state.add("sun_amulet", 1)
        if (state.minutes < 18 * 60) state.minutes = 20 * 60
        val elder = World["elder"]
        val npc = elder.npcs.first { it.id == "aldric" }
        val (x, y, f) = listOf(Triple(npc.x, npc.y + 1, Facing.UP), Triple(npc.x - 1, npc.y, Facing.RIGHT), Triple(npc.x + 1, npc.y, Facing.LEFT))
            .first { (x, y) -> elder.tile(x, y).walkable }
        state.place = Place("elder", x, y, f)
        sunCut()
        changed()
    }

    fun cheatWarp(place: Place) {
        if (mode !is Mode.Explore) return
        state.place = place
        sunCut()
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
        clockStood = true
        battleRoamer?.let { r ->
            when (battle.outcome) {
                Outcome.WON, Outcome.ENEMY_FLED -> {
                    herds[state.place.map]?.remove(r)
                    // It comes back after a good walk.
                    respawns.getOrPut(state.place.map) { mutableListOf() } += state.steps + 60
                }
                else -> {
                    // 198: the hero got away; it draws back home and lets them be a while
                    r.hunting = false
                    r.returning = true
                    r.calmUntil = now + FLED_CALM_MS
                }
            }
        }
        if (battle.outcome == Outcome.WON) {
            // draft (idea 7): blood where the foe fell, else on the tile before the hero
            val p = state.place
            val (bx, by) = battleRoamer?.let { it.x + 0.5 to it.y + 0.5 } ?: when (p.facing) {
                Facing.UP -> p.x + 0.5 to p.y - 0.5; Facing.DOWN -> p.x + 0.5 to p.y + 1.5
                Facing.LEFT -> p.x - 0.5 to p.y + 0.5; Facing.RIGHT -> p.x + 1.5 to p.y + 0.5
            }
            tracks.blood(p.map, bx, by, now, battleRoamer?.uid ?: state.steps)
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
                // D4.1: Morwen gives the bundle only once; a lost fight must not cost it
                if (battle.smokeThrown) state.add(Story.SMOKE_BUNDLE, 1)
                // 154: no gold lost on normal; the way home costs time instead (a harsher level may take gold later)
                Resting.pass(state, DEATH_HOURS * 60)
                hero.restoreFully()
                state.place = state.respawn
                sunCut()
                mapChanged = true
                enqueue(listOf(Cmd.Say(null, T(
                    "Du erwachst an einem sicheren Ort … Der Heimweg hat Stunden gedauert.",
                    "You wake up somewhere safe... The way home took hours.",
                ))))
            }
            Outcome.FLED, Outcome.ONGOING -> queue.clear()
        }
        changed()
    }

    // ------------------------------------------------------------ menu actions

    /** 84.5: puts the spark of light out; out is out. Returns a message to show. */
    fun putOutSpark(): String {
        if (!state.spark) return ""
        Light.putOut(state)
        changed()
        return Light.sparkGone(lang)
    }

    /** Use a consumable outside of battle. Returns a message to show. */
    fun useItemOutside(id: String): String {
        val def = Items[id]
        if (id == Light.SPARK_ITEM && state.count(id) > 0) {
            // 84.5: a spark rises and hovers over the hero until the next rest
            if (state.spark) return Light.sparkAlready(lang)
            state.remove(id)
            sounds += de.bornim.core.audio.Sound.POTION
            state.spark = true
            changed()
            return Light.sparkDrunk(lang)
        }
        if (def.kind == ItemKind.TONIC && state.count(id) > 0) {
            // 86.6: the stamina draught doubles the breath until the next rest
            if (state.staminaBoost) return Resting.staminaAlready(lang)
            state.remove(id)
            sounds += de.bornim.core.audio.Sound.POTION
            state.staminaBoost = true
            changed()
            return Resting.staminaDrunk.f(lang, hero.name)
        }
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

    fun buy(id: String, n: Int = 1): String {
        val def = Items[id]
        val price = buyPrice(id) * n
        if (n < 1) return Ui.nothing(lang)
        if (state.gold < price) return Ui.notEnoughGold(lang)
        state.gold -= price
        state.add(id, n)
        sounds += de.bornim.core.audio.Sound.COINS
        changed()
        return Ui.bought.f(lang, def.name(lang) + if (n > 1) " ×$n" else "")
    }

    /** 59.5: how many of [id] the hero can buy with the gold in hand. */
    fun canBuy(id: String): Int = state.gold / buyPrice(id)

    /** One thing sold in this visit to the shop (59.4), to be bought back at the price it fetched. */
    class Sold(val gear: Gear?, val item: String?, val count: Int, val price: Int) {
        fun name(lang: Lang) = (gear?.name(lang) ?: Items[item!!].name(lang)) + if (count > 1) " ×$count" else ""
    }

    /** 59.4: the last five sales, newest first, until the shop closes; not saved. */
    val buyback = ArrayDeque<Sold>()

    private fun sold(s: Sold) {
        buyback.addFirst(s)
        while (buyback.size > 5) buyback.removeLast()
    }

    /** 59.4: takes [s] back for what it fetched. */
    fun buyBack(s: Sold): String {
        if (s !in buyback) return Ui.cannotSell(lang)
        if (state.gold < s.price) return Ui.notEnoughGold(lang)
        state.gold -= s.price
        if (s.gear != null) state.bag += s.gear else state.add(s.item!!, s.count)
        buyback.remove(s)
        sounds += de.bornim.core.audio.Sound.COINS
        changed()
        return Ui.bought.f(lang, s.name(lang))
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
        // 180: the plain torch is never sold out, even if an older save marked it so (Build 25)
        return Loot.shopGear(state).filter { it.base == "torch" || "$batch:${it.uid}" !in state.shopSold }
    }

    fun buyGear(g: Gear): String {
        val price = buyPrice(g)
        if (state.gold < price) return Ui.notEnoughGold(lang)
        state.gold -= price
        // 180 (Chef 18.10.): the plain torch stays on offer, so a second one can be bought
        if (g.base != "torch") state.shopSold += "${state.battlesWon / 8}:${g.uid}"
        state.addGear(g.copy(uid = 0))
        sounds += de.bornim.core.audio.Sound.COINS
        changed()
        return Ui.bought.f(lang, g.name(lang))
    }

    fun sellPrice(g: Gear): Int = Perks.sellPrice(hero, maxOf(1, g.price / 4))

    fun sellGear(g: Gear): String {
        if (!state.bag.remove(g)) return Ui.cannotSell(lang)
        state.gold += sellPrice(g)
        sold(Sold(g, null, 1, sellPrice(g)))
        sounds += de.bornim.core.audio.Sound.COINS
        changed()
        return Ui.sold.f(lang, g.name(lang))
    }

    /** Sells every common piece in the bag at once. */
    fun sellAllCommon(): Int {
        val junk = state.bag.filter { it.rarity == Rarity.COMMON }
        junk.forEach { state.bag.remove(it); state.gold += sellPrice(it); sold(Sold(it, null, 1, sellPrice(it))) }
        changed()
        return junk.size
    }

    fun discard(g: Gear) {
        state.bag.remove(g)
        changed()
    }

    fun sell(id: String, n: Int = 1): String {
        val def = Items[id]
        if (n < 1 || !def.sellable || !state.remove(id, n)) return Ui.cannotSell(lang)
        state.gold += sellPrice(id) * n
        sold(Sold(null, id, n, sellPrice(id) * n))
        sounds += de.bornim.core.audio.Sound.COINS
        changed()
        return Ui.sold.f(lang, def.name(lang) + if (n > 1) " ×$n" else "")
    }

    fun changed() {
        revision++
    }
}
