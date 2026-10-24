package de.bornim.core

import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.floor
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min

/**
 * Free walking (13g, "C"): the world and its rules stay on the tiles, but the hero moves freely in
 * any direction, with a position between the tiles. The hero is a small circle that slides along
 * walls and round corners instead of stopping dead. Crossing into another tile goes through
 * [Game.move] and [Game.afterStep] as before, so doors, warps, triggers, herbs, encounters,
 * monsters and the step counter all work unchanged; pushing against a monster or a barrier acts
 * as walking into it did.
 *
 * Positions are in tiles: (x, y) = (tile.x + 0.5, tile.y + 0.5) is the middle of a tile.
 */
class FreeWalk(private val game: Game) {
    /** Where the hero's feet are, in tiles. */
    var x = 0.0
        internal set
    var y = 0.0
        internal set

    /** The way the hero walks or last walked, as a yaw in the map: 0 down the map, 90 to the right. */
    var yaw = 0.0
        internal set

    /** Distance walked so far, in tiles (for the steps of the walk). */
    var walked = 0.0
        private set

    /** Whether the hero moved in the last call of [walk]. */
    var moving = false
        private set

    private var mapId = ""
    private var bumpCooldown = 0L
    private var now = 0L
    /** A tile whose step was refused (a locked door): kept out of for a moment, so the refusal is not repeated every frame. */
    private var refused: Pair<Int, Int>? = null
    private var refusedUntil = 0L

    companion object {
        /** The hero's size: a circle of this radius, in tiles. */
        const val RADIUS = 0.3
        /**
         * 152: the radius of the round spot someone fills, round the feet as drawn. With the hero's [RADIUS] the hero
         * stops about 0.72 tiles from their middle on every side, just outside their tile at its corners, so walking
         * round them is an even circle (Chef, Build 17: "Ein gleichmäßiges und nahes Umrunden ist nicht möglich").
         */
        // 216 (Chef 19.10.): nearer to people, 0.62 tiles straight on; at the corners of their tile still the 0.71 the
        // hero's middle needs to stay out of it, so walking round them wobbles a little
        private const val NPC = 0.32
        private val FULL = doubleArrayOf(0.0, 0.0, 1.0, 1.0)
        private val PERSON = doubleArrayOf(0.0, 0.0, 0.0, 0.0)
        private val ROUND = setOf(Tile.CAMPFIRE, Tile.WELL, Tile.BARREL, Tile.HAY, Tile.MENHIR)
        /**
         * 216.3 (Chef, Build 48: "Näher komme ich nicht an die Wäschestange"): how far the middle of the hero may go into
         * a tile with a thing on it, past the edge to a free tile, when the thing leaves that part empty. The hero
         * still stands on the free tile ([cell]); with the middle kept out of the tile a washing line held him half a
         * tile from its rope.
         */
        const val DEPTH = 0.25
        /** 131, 131.1: walking pace on open grass, in tiles per second, about 1.8 (340 ms a step; 131 had 400, a bit too slow). */
        val WALK = 1000.0 / (340.0 * Terrain.PACE)
        /** Running pace, twice [WALK] (170 ms a step; 131.1: 110 ran like a hare; 220: 130 still too fast against walking). */
        val RUN = 1000.0 / (170.0 * Terrain.PACE)

        /**
         * 131.1: the pace eases from [current] towards [target] instead of jumping: from walking to running in about
         * 0.6 s, back in about 0.4 s. Starting from standing begins at once at the walking pace or less.
         */
        fun ease(current: Double, target: Double, dtMs: Long): Double {
            if (current <= 0.0 || target <= 0.0) return target.coerceAtMost(WALK)
            val rate = (RUN - WALK) / (if (target > current) 600.0 else 400.0) * dtMs
            return if (target > current) min(target, current + rate) else max(target, current - rate)
        }

        /**
         * 131: how fast this hero goes, as a share of [WALK] and [RUN]: the speed of the folk as in the SRD (dwarves and
         * halflings 25 feet against 30), 10 feet less in heavy armor without the strength for it (not dwarves), and 5 %
         * more or less for each point of the Dexterity bonus.
         */
        fun speed(hero: Hero): Double {
            val feet = (if (hero.race == Race.DWARF || hero.race == Race.HALFLING) 25.0 else 30.0) -
                (if (hero.race != Race.DWARF && Stamina.heavy(hero)) 10.0 else 0.0)
            return feet / 30.0 * (1.0 + 0.05 * hero.mod(Ability.DEX)).coerceAtLeast(0.5)
        }

        /** The pace of this hero walking or running, in tiles per second on open grass. */
        fun pace(hero: Hero, run: Boolean): Double = (if (run) RUN else WALK) * speed(hero)
    }

    /** Puts the hero back on the middle of its tile when the game moved it (a warp, loading, a script). */
    fun sync() {
        val p = game.state.place
        if (p.map != mapId || cell(x, y) != (p.x to p.y)) {
            mapId = p.map
            x = p.x + 0.5; y = p.y + 0.5
            yaw = yawOf(p.facing)
        }
    }

    /**
     * The way the hero looks, for the cone of sight (13e, test 13.10.: walking up the screen the hero looks up the
     * diagonal, but the cone followed the nearest of the four map directions and left the room beyond dark): the yaw
     * while the hero walks freely here, else the facing on the map.
     */
    fun lookYaw(): Double {
        val p = game.state.place
        return if (p.map == mapId && cell(x, y) == (p.x to p.y)) yaw else yawOf(p.facing)
    }

    /**
     * 216: where the hero stands and looks, for the action button: the free position and its yaw while they are current
     * (the facing is the yaw's nearer grid direction), else the middle of the tile and the facing (a step, a turn by tapping).
     */
    fun stand(): Triple<Double, Double, Double> {
        val p = game.state.place
        return if (p.map == mapId && cell(x, y) == (p.x to p.y) && facingOf(yaw) == p.facing) Triple(x, y, yaw)
            else Triple(p.x + 0.5, p.y + 0.5, yawOf(p.facing))
    }

    /** 216: the hero turns to what the action button acts on; returns the facing for it. */
    fun turnTo(tx: Int, ty: Int): Facing {
        val (hx, hy, _) = stand()
        yaw = (Math.toDegrees(kotlin.math.atan2(tx + 0.5 - hx, ty + 0.5 - hy)) + 360.0) % 360.0
        return facingOf(yaw)
    }

    private fun facingOf(yaw: Double) = when (Math.floorMod(kotlin.math.round(yaw / 90.0).toInt(), 4)) { 0 -> Facing.DOWN; 1 -> Facing.RIGHT; 2 -> Facing.UP; else -> Facing.LEFT }

    private fun yawOf(f: Facing) = when (f) { Facing.DOWN -> 0.0; Facing.RIGHT -> 90.0; Facing.UP -> 180.0; Facing.LEFT -> 270.0 }

    /**
     * 216.3: the tile the hero stands on with the middle at ([cx], [cy]): the tile under it, or, where the middle has
     * gone a little into a tile with a thing on it ([edge]), the free tile across the nearest edge.
     */
    internal fun cell(cx: Double, cy: Double): Pair<Int, Int> {
        val mx = floor(cx).toInt(); val my = floor(cy).toInt()
        val p = game.state.place
        if (mx == p.x && my == p.y) return mx to my
        return edge(cx, cy, mx, my) ?: (mx to my)
    }

    /**
     * 216.3: when ([mx], [my]) holds a thing that fills only part of it (not a wall, a person, a shut door) and the middle
     * at ([cx], [cy]) lies at most [DEPTH] inside it from an edge to a free tile, that free tile (the nearest); else null.
     */
    private fun edge(cx: Double, cy: Double, mx: Int, my: Int): Pair<Int, Int>? {
        if (!game.map.inside(mx, my) || !blocked(mx, my) || person(mx, my) != null || shut(mx, my)) return null
        if (footprint(mx, my) === FULL) return null
        val fx = cx - mx; val fy = cy - my
        return listOf(Triple(mx - 1, my, fx), Triple(mx + 1, my, 1 - fx), Triple(mx, my - 1, fy), Triple(mx, my + 1, 1 - fy))
            .filter { it.third <= DEPTH && game.map.inside(it.first, it.second) && !blocked(it.first, it.second) && person(it.first, it.second) == null }
            .minByOrNull { it.third }?.let { it.first to it.second }
    }

    /** The tiles the hero may not stand on (its own tile never counts). */
    private fun blocked(tx: Int, ty: Int): Boolean {
        val p = game.state.place
        if (tx == p.x && ty == p.y) return false
        if (now < refusedUntil && refused == (tx to ty)) return true
        return !game.free(tx, ty) || shut(tx, ty)
    }

    /**
     * A door that stays shut (82, test 14.10.: knocking, the hero walked half into the door, his feet behind the house's
     * wall, and was gone until the words were read): the hero's body stays outside it like a wall's, and walking into
     * it knocks ([pushed]). Not the turning back at the edge of the map, which takes a step of its own (67).
     */
    private fun shut(tx: Int, ty: Int): Boolean {
        val w = game.map.warpAt(tx, ty) ?: return false
        return w.requires != null && !w.turnBack && !game.state.has(w.requires)
    }

    /**
     * The part of a blocked tile that the thing on it fills, (x0, y0, x1, y1) within the tile: in a room the
     * furniture as it is drawn seen diagonally ([de.bornim.core.art.MapRoomIso]), so the hero's body can come
     * up to a shelf against the wall, a barrel or a pot (13p, 4 and 5); outside the things of the village and
     * the woods ([outside]); else the whole tile. The middle of the hero still never enters the tile.
     */
    internal fun footprint(tx: Int, ty: Int): DoubleArray {
        val map = game.map
        // 152: someone standing or walking about fills a round spot ([gap2]); never the whole tile
        if (person(tx, ty) != null) return PERSON
        if (!map.inside(tx, ty)) return FULL
        if (map.kind != MapKind.INTERIOR) return outside(map, tx, ty)
        return when (map.tile(tx, ty)) {
            Tile.SHELF -> doubleArrayOf(0.0, 0.0, 1.0, 0.42)
            Tile.COUNTER -> doubleArrayOf(0.0, 0.38, 1.0, 0.88)
            Tile.TABLE -> doubleArrayOf(0.0, 0.16, 1.0, 0.84)
            Tile.BARREL -> doubleArrayOf(0.22, 0.22, 0.78, 0.78)
            Tile.PLANT -> doubleArrayOf(0.3, 0.3, 0.7, 0.7)
            else -> FULL
        }
    }

    /**
     * 216.3 (Chef 20.10.: "Näher komme ich nicht an die Lampe ran"): a thing under the open sky fills what it is drawn
     * as up to the hero's height ([de.bornim.core.art.MapTownIso], [de.bornim.core.art.MapWoodIso]), not its whole
     * tile, so a lamp post stops the hero half a tile from its middle instead of 0.8. Walls, water, trees, fields and
     * a monster on its tile still fill the whole tile; in the cave the stalagmites and crates their drawn spot,
     * crystals, torches and the rock stay wall.
     */
    private fun outside(map: MapDef, tx: Int, ty: Int): DoubleArray {
        val t = map.tile(tx, ty)
        if (t.walkable) return FULL
        return when (t) {
            Tile.LAMP -> doubleArrayOf(0.4, 0.4, 0.6, 0.6)
            Tile.SIGN -> doubleArrayOf(0.14, 0.5, 0.86, 0.64)
            Tile.NOTICE -> doubleArrayOf(0.06, 0.5, 0.94, 0.64)
            Tile.WELL -> doubleArrayOf(0.14, 0.12, 0.86, 0.88)
            Tile.BENCH -> doubleArrayOf(0.08, 0.34, 0.92, 0.62)
            Tile.BARREL -> doubleArrayOf(0.22, 0.22, 0.78, 0.78)
            Tile.CHEST -> doubleArrayOf(0.2, 0.26, 0.78, 0.7)
            Tile.CAMPFIRE -> doubleArrayOf(0.11, 0.11, 0.89, 0.89)
            Tile.MENHIR -> doubleArrayOf(0.16, 0.16, 0.84, 0.84)
            Tile.STALAGMITE -> de.bornim.core.art.MapCaveIso.stalagmiteSpot(tx, ty)
            Tile.CRATE -> de.bornim.core.art.MapCaveIso.crateSpot(tx, ty)
            Tile.BARRIER -> doubleArrayOf(0.0, 0.36, 1.0, 0.64)
            Tile.WASHLINE -> doubleArrayOf(0.0, 0.44, 1.0, 0.56)
            // a tree drawn as a low bush (Build 51: the one behind the washing line); a tree with its crown stays whole
            Tile.TREE -> de.bornim.core.art.MapFlora.bushSpot(map, tx, ty) ?: FULL
            // the cloth roof hangs out in front, about head high
            Tile.STALL -> doubleArrayOf(if (map.tile(tx - 1, ty) == t) 0.0 else 0.1, 0.26, if (map.tile(tx + 1, ty) == t) 1.0 else 0.9, 0.8)
            Tile.LOG -> doubleArrayOf(if (map.tile(tx - 1, ty) == t) 0.0 else 0.12, 0.3, if (map.tile(tx + 1, ty) == t) 1.0 else 0.88, 0.72)
            Tile.HAY -> de.bornim.core.art.MapWoodIso.hayShape(tx, ty).first.let { r -> doubleArrayOf(0.5 - r, 0.5 - r, 0.5 + r, 0.5 + r) }
            Tile.ROCK -> de.bornim.core.art.MapWoodIso.rockShape(tx, ty).let { st ->
                doubleArrayOf(st.minOf { 1 + it[0] - it[2] }, st.minOf { 1 + it[1] - it[3] }, st.maxOf { 1 + it[0] + it[2] }, st.maxOf { 1 + it[1] + it[3] })
            }
            Tile.YARD -> when (de.bornim.core.art.MapTownIso.yardKind(map, tx, ty)) {
                0 -> doubleArrayOf(0.0, 0.2, 1.0, 0.75)
                1 -> doubleArrayOf(0.2, 0.26, 0.9, 0.74)
                2 -> doubleArrayOf(0.14, 0.2, 0.86, 0.8)
                else -> doubleArrayOf(0.1, 0.42, 0.9, 0.9)
            }
            // a post with its runs out to the fence tiles beside it
            Tile.FENCE -> de.bornim.core.art.MapTownIso.fenceSpot(map, tx, ty).let { (mi, mj) ->
                fun f(x: Int, y: Int) = map.tile(x, y) == Tile.FENCE
                doubleArrayOf(if (f(tx - 1, ty)) 0.0 else 0.95 + mi, if (f(tx, ty - 1)) 0.0 else 0.95 + mj,
                    if (f(tx + 1, ty)) 1.0 else 1.05 + mi, if (f(tx, ty + 1)) 1.0 else 1.05 + mj)
            }
            else -> FULL
        }
    }

    /** 152: the middle of the feet of someone standing or walking about on ([tx], [ty]), as drawn; else null. */
    private fun person(tx: Int, ty: Int): Pair<Double, Double>? {
        val map = game.map
        map.npcAt(tx, ty, game.state)?.let { npc ->
            val (ox, oy) = de.bornim.core.art.MapFolk.nudge(npc, map)
            return tx + 0.5 + ox.toDouble() / de.bornim.core.art.WorldArt.T to ty + 0.5 + oy.toDouble() / de.bornim.core.art.WorldArt.T
        }
        return if (game.walkerAt(tx, ty)) tx + 0.5 to ty + 0.5 else null
    }

    /** The middle of someone or of a round thing on ([tx], [ty]), for sliding round it; else null. */
    private fun middle(tx: Int, ty: Int): Pair<Double, Double>? {
        person(tx, ty)?.let { return it }
        if (!round(tx, ty)) return null
        val f = footprint(tx, ty)
        return tx + (f[0] + f[2]) / 2 to ty + (f[1] + f[3]) / 2
    }

    /** Whether the thing on ([tx], [ty]) is drawn round: fire, well, barrel, hay, standing stone. */
    private fun round(tx: Int, ty: Int): Boolean =
        person(tx, ty) == null && game.map.inside(tx, ty) && (game.map.tile(tx, ty) in ROUND || trunk(tx, ty))

    /**
     * 353 (Chef 24.10.: an Wegen im Tiefen Wald hängen bleiben, „rumeiern“): a tree with its crown in the woods stops the
     * hero round its tile, not at the corners of a square, so at a bend of the way the hero slides round it instead of
     * catching on a corner; between two trees on the slant there is still no gap to squeeze through.
     */
    private fun trunk(tx: Int, ty: Int): Boolean =
        game.map.kind == MapKind.FOREST && game.map.tile(tx, ty) == Tile.TREE && footprint(tx, ty) === FULL

    /** The squared distance from ([cx], [cy]) to what fills the tile ([tx], [ty]). */
    private fun gap2(cx: Double, cy: Double, tx: Int, ty: Int): Double {
        person(tx, ty)?.let { (px, py) -> return max(0.0, hypot(cx - px, cy - py) - NPC).let { it * it } }
        val f = footprint(tx, ty)
        // t45 (Chef 20.10.: "Näher an das Feuer … komme ich aus dieser Richtung nicht ran"): a round thing is round,
        // so coming at it slantwise (to the right on the screen) the hero is not held off by the corners of its box
        if (round(tx, ty)) {
            val d = max(0.0, hypot(cx - tx - (f[0] + f[2]) / 2, cy - ty - (f[1] + f[3]) / 2) - (f[2] - f[0]) / 2)
            return d * d
        }
        val nx = cx.coerceIn(tx + f[0], tx + f[2]); val ny = cy.coerceIn(ty + f[1], ty + f[3])
        return (cx - nx) * (cx - nx) + (cy - ny) * (cy - ny)
    }

    /**
     * Whether the hero's circle at ([cx], [cy]) overlaps a blocked tile; returns that tile or null. A tile
     * that already overlaps the hero where it stands now ([fx], [fy]), because someone stepped onto it close
     * by (5la, test 0.1.650: Bram walking past at the bridge), only stops a move that comes nearer to it, so
     * the hero can always walk away.
     */
    private fun hit(cx: Double, cy: Double, fx: Double = x, fy: Double = y): Pair<Int, Int>? {
        // the middle of the hero goes into a blocked tile only a little from a free tile beside it (216.3), the hero
        // still standing on that one; never deeper, whatever part of it the thing fills
        val mx = floor(cx).toInt(); val my = floor(cy).toInt()
        if (blocked(mx, my) && footprint(mx, my) !== FULL && edge(cx, cy, mx, my) == null) return mx to my
        for (ty in floor(cy - RADIUS).toInt()..floor(cy + RADIUS).toInt())
            for (tx in floor(cx - RADIUS).toInt()..floor(cx + RADIUS).toInt()) {
                if (!blocked(tx, ty)) continue
                val g = gap2(cx, cy, tx, ty)
                if (g >= RADIUS * RADIUS - 1e-9) continue
                val was = gap2(fx, fy, tx, ty)
                if (was < RADIUS * RADIUS - 1e-9 && g >= was) continue
                return tx to ty
            }
        return null
    }

    /**
     * Walks for [dtMs] in direction ([vx], [vy]) (map axes, any length; zero stands still) at
     * [pace] tiles per second on open grass, slowed by the ground as before. [nowMs] paces the
     * bumping into monsters and barriers. Returns true when the hero entered another tile.
     */
    fun walk(vx: Double, vy: Double, dtMs: Long, pace: Double, nowMs: Long): Boolean {
        sync()
        now = nowMs
        moving = false
        if (game.mode != Mode.Explore) return false
        val len = hypot(vx, vy)
        if (len < 1e-6 || dtMs <= 0) return false
        val dx = vx / len; val dy = vy / len
        yaw = Math.toDegrees(atan2(dx, dy)).let { if (it < 0) it + 360 else it }
        val ground = Terrain.stepFactor(game.map, game.state.place.x, game.state.place.y)
        var step = pace / ground * min(dtMs, 100L) / 1000.0
        val sx = x; val sy = y
        // in small pieces, so the hero never jumps across a corner
        var entered = false
        while (step > 1e-9) {
            val s = min(step, 0.12)
            step -= s
            val before = x to y
            val was = cell(x, y)
            // 152: against someone, slide round their round spot (axis by axis the hero stuck on it, test of Build 17);
            // 353: as round a tree of the woods, a fire, a well
            val against = hit(x + dx * s, y + dy * s)
            val round = against?.let { middle(it.first, it.second) }?.let { (px, py) ->
                val d = hypot(x - px, y - py)
                val ux = (x - px) / d; val uy = (y - py) / d
                val dot = dx * ux + dy * uy
                // head on (into a villager who makes room, 92) still pushes as before; a thing is glided round even then
                val folk = person(against.first, against.second) != null
                val tx = dx - dot * ux; val ty = dy - dot * uy
                // round a thing at least at half the pace, so coming at a tree nearly head on is no crawl (353)
                val k = hypot(tx, ty).let { if (folk || it < 0.05) 1.0 else max(it, 0.5) / it }
                if (d < 1e-6 || dot >= 0 || (dot < -0.95 && folk)) null else (x + tx * k * s) to (y + ty * k * s)
            }
            if (round != null && hit(round.first, round.second) == null) {
                x = round.first; y = round.second
            } else {
            // each axis on its own, so a wall met at a slant is slid along
            val nx = x + dx * s
            val hx = hit(nx, y)
            if (hx == null) x = nx else pushed(hx, dx, dy, nowMs)
            val ny = y + dy * s
            val hy = hit(x, ny)
            if (hy == null) y = ny else pushed(hy, dx, dy, nowMs)
            }
            if (!crossed()) { x = before.first; y = before.second; break }
            if (was != cell(x, y)) entered = true
            if (game.mode != Mode.Explore || mapId != game.state.place.map) break
        }
        val moved = hypot(x - sx, y - sy)
        walked += moved
        moving = moved > 1e-6
        if (moving) game.tracks.walked(mapId, x, y, yaw, game.map.tile(game.state.place.x, game.state.place.y),
            game.map.kind == MapKind.FOREST || game.map.kind == MapKind.TOWN, pace > pace(game.state.hero, false) * 1.4, nowMs)
        // the way the hero faces, for what lies ahead (talking, opening, …): the nearer grid direction
        val f = if (abs(dx) > abs(dy)) (if (dx > 0) Facing.RIGHT else Facing.LEFT) else (if (dy > 0) Facing.DOWN else Facing.UP)
        if (game.state.place.facing != f && game.mode == Mode.Explore) game.face(f)
        return entered
    }

    /**
     * When the middle of the hero has come into another tile: the step through [Game.move] and
     * [Game.afterStep]. False if the step was refused (a door that stays shut); the hero then stays.
     */
    private fun crossed(): Boolean {
        val p = game.state.place
        val (tx, ty) = cell(x, y)
        if (tx == p.x && ty == p.y) return true
        // a slanting crossing goes through one side first, then the other
        val steps = buildList {
            if (tx != p.x) add(if (tx > p.x) Facing.RIGHT else Facing.LEFT)
            if (ty != p.y) add(if (ty > p.y) Facing.DOWN else Facing.UP)
        }
        for (d in steps) {
            val r = game.move(d)
            if (r !is Move.Stepped) {
                refused = (game.state.place.x + d.dx) to (game.state.place.y + d.dy)
                refusedUntil = now + 1_500
                return false
            }
            game.afterStep()
            if (game.state.place.map != mapId) { sync(); return true }
            if (game.mode != Mode.Explore) return true
        }
        return true
    }

    /** Pushing against a blocked tile: into a monster or a barrier this acts as a step into it did. */
    private fun pushed(tile: Pair<Int, Int>, dx: Double, dy: Double, nowMs: Long) {
        if (nowMs < bumpCooldown) return
        val p = game.state.place
        val ox = tile.first - p.x; val oy = tile.second - p.y
        if (abs(ox) + abs(oy) != 1) return
        // only when walking mostly towards it
        if (ox * dx + oy * dy < 0.7) return
        val d = if (ox > 0) Facing.RIGHT else if (ox < 0) Facing.LEFT else if (oy > 0) Facing.DOWN else Facing.UP
        // 92 (test 0.1.791): a villager in the way makes room; the hero then walks on by himself
        if (game.yields(tile.first, tile.second)) { bumpCooldown = nowMs + 600; game.face(d); game.nudge(d); return }
        val m = game.map
        val acts = game.roamerAt(tile.first, tile.second) != null || m.tile(tile.first, tile.second) == Tile.BARRIER || (m.warpAt(tile.first, tile.second) != null && !game.door(tile.first, tile.second))
        if (!acts) return
        // knocking again only after a while, when the hero still walks against the door after the words
        bumpCooldown = nowMs + if (shut(tile.first, tile.second)) 1_500 else 600
        game.move(d)
    }

    /** Whether the straight line from the hero to ([tx], [ty]) is clear for the hero's circle (for walking to a tapped place). */
    fun clear(tx: Double, ty: Double): Boolean {
        val d = hypot(tx - x, ty - y)
        val n = max(1, (d / 0.1).toInt())
        for (i in 1..n) {
            val t = i.toDouble() / n
            if (hit(x + (tx - x) * t, y + (ty - y) * t) != null) return false
        }
        return true
    }
}
