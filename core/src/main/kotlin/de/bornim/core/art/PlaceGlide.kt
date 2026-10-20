package de.bornim.core.art

/**
 * 249 (Chef 20.10., 14:01 „Positionswechsel läuft sehr abgehackt … sehr sprunghaft“): where a figure of a MARS fight
 * stands, gliding to a new place instead of jumping there. Whenever the place a figure belongs on changes (a swap of
 * rows, a row left alone and taken to the middle, a neighbour who falls), it goes there in [ms] milliseconds, starting
 * slow and ending slow; a change while it is still on its way starts from where it is, so it never jumps.
 */
class PlaceGlide(val ms: Long = MS) {
    private class Way(var fromA: Double, var fromB: Double, var toA: Double, var toB: Double, var at: Long)
    private val ways = HashMap<String, Way>()

    /** where [id] stands at [now], on its way to its place [a], [b] */
    fun at(id: String, a: Double, b: Double, now: Long): Pair<Double, Double> {
        val w = ways.getOrPut(id) { Way(a, b, a, b, now - ms) }
        if (w.toA != a || w.toB != b) {
            val (ca, cb) = where(w, now)
            w.fromA = ca; w.fromB = cb; w.toA = a; w.toB = b; w.at = now
        }
        return where(w, now)
    }

    /** whether [id] is on its way at [now] */
    fun moving(id: String, now: Long): Boolean = ways[id]?.let { now - it.at < ms && (it.fromA != it.toA || it.fromB != it.toB) } ?: false

    private fun where(w: Way, now: Long): Pair<Double, Double> {
        val t = ((now - w.at).toDouble() / ms).coerceIn(0.0, 1.0)
        val e = t * t * (3 - 2 * t)
        return Pair(w.fromA + (w.toA - w.fromA) * e, w.fromB + (w.toB - w.fromB) * e)
    }

    companion object {
        const val MS = 350L
    }
}
