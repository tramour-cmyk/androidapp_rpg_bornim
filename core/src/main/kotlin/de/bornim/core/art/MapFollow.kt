package de.bornim.core.art

/**
 * The mates of a pack and the guards of a boss on the map (9g): each has a place of its own near its leader and walks
 * there at its own pace, slowing as it arrives, turning the way it goes and, standing, the way its leader looks. So
 * when the leader turns, the mates come round in an arc instead of swinging round it like a rigid frame. Positions
 * are map pixels; times ms of the app clock.
 */
object MapFollow {
    /** Degrees a follower turns per ms, as the folk and the monsters do (half a turn in a quarter of a second). */
    const val TURN_PER_MS = 0.75

    class F {
        var x = 0.0; var y = 0.0
        var last = 0L
        /** How far it has walked, for the steps of its walk. */
        var dist = 0.0
        var moving = false
        /** Where it looks, in degrees as the dolls' yaw. */
        var yaw = 0.0
        private var turnedAt = 0L

        /** Turns towards [target] by the shortest way, at most [TURN_PER_MS]. */
        fun turn(target: Double, now: Long) {
            val dt = if (turnedAt == 0L) 1000L else (now - turnedAt).coerceIn(0L, 200L)
            turnedAt = now
            val d = ((target - yaw) % 360.0 + 540.0) % 360.0 - 180.0
            val maxStep = dt * TURN_PER_MS
            yaw = if (kotlin.math.abs(d) <= maxStep) target else yaw + kotlin.math.sign(d) * maxStep
            yaw = (yaw % 360.0 + 360.0) % 360.0
        }
    }
    private val all = HashMap<String, F>()

    /** The place behind ([back]) and to one [side] (±1, [aside] pixels) of a leader at ([x], [y]) facing [yaw]. */
    fun place(x: Int, y: Int, yaw: Double, back: Double, aside: Double, side: Int): Pair<Double, Double> {
        val yr = Math.toRadians(yaw)
        val fx = kotlin.math.sin(yr); val fy = kotlin.math.cos(yr)
        // the map is seen at a slant: depth on the screen is shorter
        return (x + (-fx * back + fy * aside * side)) to (y + (-fy * back - fx * aside * side) * 0.75)
    }

    /** Moves the follower [key] towards ([tx], [ty]) at most [speed] pixels per ms, easing in as it nears. */
    fun update(key: String, tx: Double, ty: Double, speed: Double, now: Long, leaderYaw: Double): F {
        val f = all.getOrPut(key) { F().also { it.x = tx; it.y = ty; it.last = now; it.yaw = leaderYaw } }
        val dt = (now - f.last).coerceIn(0L, 200L).toDouble()
        f.last = now
        val dx = tx - f.x; val dy = ty - f.y
        val d = kotlin.math.hypot(dx, dy)
        if (d > WorldArt.T * 4) {
            // a new map or a long jump: just be there
            f.x = tx; f.y = ty; f.moving = false
        } else if (d > 0.01 && dt > 0) {
            // eased: fast while far, slowing in the last few pixels, never faster than [speed]
            val s = minOf(d, speed * dt, d * (1 - kotlin.math.exp(-dt / 140.0)))
            f.x += dx / d * s; f.y += dy / d * s
            f.dist += s
            f.moving = s / dt > speed * 0.2
            if (f.moving) f.turn(Math.toDegrees(kotlin.math.atan2(dx, dy)), now)
        } else f.moving = false
        if (!f.moving) f.turn(leaderYaw, now)
        return f
    }

    /** Forgets every follower (tests). */
    fun reset() = all.clear()
}
