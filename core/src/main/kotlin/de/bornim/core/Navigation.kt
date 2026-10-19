package de.bornim.core

/** What the action button would do right now; the app shows a matching icon. */
enum class ActionKind { TALK, OPEN, READ, REST, UNLOCK, LOOK, FIGHT, ENTER }

/** A walk planned by tapping: steps to take, then optionally turn to [face] and interact. */
data class Route(val steps: List<Facing>, val face: Facing? = null, val interact: Boolean = false, val target: Pair<Int, Int>)

/** The interaction an object on tile ([x], [y]) offers, if any. */
fun Game.actionAt(x: Int, y: Int): ActionKind? {
    val m = map
    // 215: a way out (door, cave mouth, path, edge of the map) is taken with the button, standing on it
    if (x == state.place.x && y == state.place.y) return if (m.warpAt(x, y) != null) ActionKind.ENTER else null
    if (roamerAt(x, y) != null) return ActionKind.FIGHT
    if (npcAt(x, y) != null) return ActionKind.TALK
    if (m.signs.containsKey(x to y)) return ActionKind.READ
    // Jorin's job (29.3): the standing stones only while there is something to find
    if (Jobs.findAt(state, m.id, m.tile(x, y)) != null) return ActionKind.LOOK
    return when (m.tile(x, y)) {
        Tile.NOTICE -> ActionKind.READ
        Tile.CHEST -> if (m.chestAt(x, y)?.id in state.openedChests) ActionKind.LOOK else ActionKind.OPEN
        Tile.CAMPFIRE -> if (m.kind == MapKind.CAVE) ActionKind.LOOK else ActionKind.REST
        Tile.GATE -> if (state.has(Story.GATE_OPEN)) null else ActionKind.UNLOCK
        Tile.BARRIER -> if (state.has(Story.BARRIER_OPEN)) null else ActionKind.LOOK
        Tile.BED -> if (m.id == "inn") ActionKind.REST else ActionKind.LOOK
        Tile.WELL, Tile.SHELF, Tile.ALTAR, Tile.STALL, Tile.LAMP, Tile.BARREL, Tile.BENCH,
        Tile.CROPS, Tile.VEG_BED, Tile.HAY, Tile.WASHLINE, Tile.HEARTH -> ActionKind.LOOK
        else -> null
    }
}

/** 215: where the way out the hero stands on leads, for the words beside the action button; null if none. */
fun Game.actionPlace(): T? = map.warpAt(state.place.x, state.place.y)?.let { World.maps[it.to.map]?.name }

/** The interaction the action button offers, the same target [Game.interact] would use. */
fun Game.actionAhead(): ActionKind? = actionTarget()?.let { (x, y) -> actionAt(x, y) }

/** 216: how far the action button reaches, in tiles from where the hero really stands to the middle of the thing. */
const val ACTION_REACH = 1.3

/**
 * 216 (Chef 19.10.: "teilweise muss man ziemlich rumeiern, um ein Gespräch zu beginnen"): the tile the action button acts
 * on. Not only the tile straight ahead: the nearest thing within [ACTION_REACH] of where the hero stands while walking freely,
 * those in a fan of 120° round the way the hero looks first, then people and monsters before things, then the nearer.
 * A shopkeeper is reached across the counter, straight across as before. Never round a corner of two walls.
 */
fun Game.actionTarget(): Pair<Int, Int>? {
    if (mode != Mode.Explore) return null
    val p = state.place
    // 215: standing on a way out, the button takes it, whoever stands beside it
    if (map.warpAt(p.x, p.y) != null) return p.x to p.y
    val (hx, hy, yaw) = freeWalk.stand()
    val ax = kotlin.math.sin(Math.toRadians(yaw)); val ay = kotlin.math.cos(Math.toRadians(yaw))
    data class Pick(val x: Int, val y: Int, val fan: Boolean, val who: Boolean, val d: Double)
    val picks = ArrayList<Pick>()
    for (oy in -1..1) for (ox in -1..1) {
        if (ox == 0 && oy == 0) continue
        if (ox != 0 && oy != 0 && !free(p.x + ox, p.y) && !free(p.x, p.y + oy)) continue
        var tx = p.x + ox; var ty = p.y + oy
        val d = kotlin.math.hypot(tx + 0.5 - hx, ty + 0.5 - hy)
        if (d > ACTION_REACH) continue
        if (map.tile(tx, ty) == Tile.COUNTER) { if (ox != 0 && oy != 0) continue; tx += ox; ty += oy }
        val kind = actionAt(tx, ty) ?: continue
        val fan = ((p.x + ox + 0.5 - hx) * ax + (p.y + oy + 0.5 - hy) * ay) / d >= 0.5
        picks += Pick(tx, ty, fan, kind == ActionKind.TALK || kind == ActionKind.FIGHT, d)
    }
    return picks.minWithOrNull(compareBy<Pick>({ !it.fan }, { !it.who }, { it.d }))?.let { it.x to it.y }
}

/**
 * Plans a walk to the tapped tile ([tx], [ty]). Tapping something the hero can interact with
 * (a person, chest, sign, campfire …) walks next to it, turns towards it and interacts.
 * Returns null if there is no way there.
 */
fun Game.route(tx: Int, ty: Int): Route? {
    if (mode != Mode.Explore) return null
    val m = map
    val p = state.place
    if (tx == p.x && ty == p.y) return null
    // Only places the hero has already seen can be walked to by tapping.
    if (fog(tx, ty) == Fog.HIDDEN) return null
    val target = tx to ty

    // Tiles to stand on, with the direction to face from there.
    val goals = HashMap<Pair<Int, Int>, Facing?>()
    // 215: tapping a way out walks onto it and takes it, as the button would there
    val way = m.warpAt(tx, ty)?.let { it.requires == null || state.has(it.requires) } == true
    val interact = way || actionAt(tx, ty) != null
    if (way) {
        goals[target] = null
    } else if (interact) {
        for (d in Facing.entries) {
            goals[(tx - d.dx) to (ty - d.dy)] = d
            // Shopkeepers stand behind a counter.
            if (m.tile(tx - d.dx, ty - d.dy) == Tile.COUNTER) goals[(tx - 2 * d.dx) to (ty - 2 * d.dy)] = d
        }
    } else if (free(tx, ty)) {
        goals[target] = null
    } else {
        return null
    }

    fun passable(x: Int, y: Int): Boolean {
        if (!free(x, y) || fog(x, y) == Fog.HIDDEN) return false
        val warp = m.warpAt(x, y) ?: return true
        // Doors and exits change the map, so they are only used as the destination.
        return (x to y) == target && (warp.requires == null || state.has(warp.requires))
    }

    val start = p.x to p.y
    goals[start]?.let { return Route(emptyList(), it, interact, target) }
    val cameFrom = HashMap<Pair<Int, Int>, Pair<Pair<Int, Int>, Facing>>()
    val queue = ArrayDeque<Pair<Int, Int>>()
    queue += start
    val seen = hashSetOf(start)
    while (queue.isNotEmpty()) {
        val cur = queue.removeFirst()
        for (d in Facing.entries) {
            val next = (cur.first + d.dx) to (cur.second + d.dy)
            if (next in seen || !passable(next.first, next.second)) continue
            seen += next
            cameFrom[next] = cur to d
            if (next in goals) {
                val steps = ArrayList<Facing>()
                var at = next
                while (at != start) {
                    val (prev, dir) = cameFrom.getValue(at)
                    steps += dir
                    at = prev
                }
                steps.reverse()
                return Route(steps, goals[next], interact, target)
            }
            queue += next
        }
    }
    return null
}
