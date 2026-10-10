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
        private set
    var y = 0.0
        private set

    /** The way the hero walks or last walked, as a yaw in the map: 0 down the map, 90 to the right. */
    var yaw = 0.0
        private set

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
        /** Walking pace on open grass, in tiles per second (a step used to take 200 ms × [Terrain.PACE]). */
        val WALK = 1000.0 / (200.0 * Terrain.PACE)
        /** Running pace (110 ms a step). */
        val RUN = 1000.0 / (110.0 * Terrain.PACE)
    }

    /** Puts the hero back on the middle of its tile when the game moved it (a warp, loading, a script). */
    fun sync() {
        val p = game.state.place
        if (p.map != mapId || floor(x).toInt() != p.x || floor(y).toInt() != p.y) {
            mapId = p.map
            x = p.x + 0.5; y = p.y + 0.5
            yaw = yawOf(p.facing)
        }
    }

    private fun yawOf(f: Facing) = when (f) { Facing.DOWN -> 0.0; Facing.RIGHT -> 90.0; Facing.UP -> 180.0; Facing.LEFT -> 270.0 }

    /** The tiles the hero may not stand on (its own tile never counts). */
    private fun blocked(tx: Int, ty: Int): Boolean {
        val p = game.state.place
        if (tx == p.x && ty == p.y) return false
        if (now < refusedUntil && refused == (tx to ty)) return true
        return !game.free(tx, ty)
    }

    /** Whether the hero's circle at ([cx], [cy]) overlaps a blocked tile; returns that tile or null. */
    private fun hit(cx: Double, cy: Double): Pair<Int, Int>? {
        for (ty in floor(cy - RADIUS).toInt()..floor(cy + RADIUS).toInt())
            for (tx in floor(cx - RADIUS).toInt()..floor(cx + RADIUS).toInt()) {
                if (!blocked(tx, ty)) continue
                val nx = cx.coerceIn(tx.toDouble(), tx + 1.0); val ny = cy.coerceIn(ty.toDouble(), ty + 1.0)
                if ((cx - nx) * (cx - nx) + (cy - ny) * (cy - ny) < RADIUS * RADIUS - 1e-9) return tx to ty
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
        val ground = Terrain.stepFactor(game.map.tile(game.state.place.x, game.state.place.y))
        var step = pace / ground * min(dtMs, 100L) / 1000.0
        val sx = x; val sy = y
        // in small pieces, so the hero never jumps across a corner
        var entered = false
        while (step > 1e-9) {
            val s = min(step, 0.12)
            step -= s
            val before = x to y
            // each axis on its own, so a wall met at a slant is slid along
            val nx = x + dx * s
            val hx = hit(nx, y)
            if (hx == null) x = nx else pushed(hx, dx, dy, nowMs)
            val ny = y + dy * s
            val hy = hit(x, ny)
            if (hy == null) y = ny else pushed(hy, dx, dy, nowMs)
            if (!crossed()) { x = before.first; y = before.second; break }
            if (floor(before.first).toInt() != floor(x).toInt() || floor(before.second).toInt() != floor(y).toInt()) entered = true
            if (game.mode != Mode.Explore || mapId != game.state.place.map) break
        }
        val moved = hypot(x - sx, y - sy)
        walked += moved
        moving = moved > 1e-6
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
        val tx = floor(x).toInt(); val ty = floor(y).toInt()
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
        val m = game.map
        val acts = game.roamerAt(tile.first, tile.second) != null || m.tile(tile.first, tile.second) == Tile.BARRIER || m.warpAt(tile.first, tile.second) != null
        if (!acts) return
        bumpCooldown = nowMs + 600
        game.move(if (ox > 0) Facing.RIGHT else if (ox < 0) Facing.LEFT else if (oy > 0) Facing.DOWN else Facing.UP)
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
