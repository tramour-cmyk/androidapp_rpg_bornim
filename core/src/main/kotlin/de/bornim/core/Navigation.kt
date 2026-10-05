package de.bornim.core

/** What the action button would do right now; the app shows a matching icon. */
enum class ActionKind { TALK, OPEN, READ, REST, UNLOCK, LOOK, FIGHT }

/** A walk planned by tapping: steps to take, then optionally turn to [face] and interact. */
data class Route(val steps: List<Facing>, val face: Facing? = null, val interact: Boolean = false, val target: Pair<Int, Int>)

/** The interaction an object on tile ([x], [y]) offers, if any. */
fun Game.actionAt(x: Int, y: Int): ActionKind? {
    val m = map
    if (roamerAt(x, y) != null) return ActionKind.FIGHT
    if (npcAt(x, y) != null) return ActionKind.TALK
    if (m.signs.containsKey(x to y)) return ActionKind.READ
    return when (m.tile(x, y)) {
        Tile.CHEST -> if (m.chestAt(x, y)?.id in state.openedChests) ActionKind.LOOK else ActionKind.OPEN
        Tile.CAMPFIRE -> ActionKind.REST
        Tile.GATE -> if (state.has(Story.GATE_OPEN)) null else ActionKind.UNLOCK
        Tile.BED -> if (isNight) ActionKind.REST else ActionKind.LOOK
        Tile.WELL, Tile.SHELF, Tile.ALTAR, Tile.STALL, Tile.LAMP, Tile.BARREL, Tile.BENCH,
        Tile.CROPS, Tile.VEG_BED, Tile.HAY, Tile.WASHLINE -> ActionKind.LOOK
        else -> null
    }
}

/** The interaction in front of the hero, the same target [Game.interact] would use. */
fun Game.actionAhead(): ActionKind? {
    if (mode != Mode.Explore) return null
    val p = state.place
    var tx = p.x + p.facing.dx
    var ty = p.y + p.facing.dy
    if (map.tile(tx, ty) == Tile.COUNTER) {
        tx += p.facing.dx
        ty += p.facing.dy
    }
    return actionAt(tx, ty)
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
    val interact = actionAt(tx, ty) != null
    if (interact) {
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
