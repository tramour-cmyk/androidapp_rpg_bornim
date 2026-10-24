package de.bornim.core.art

/**
 * 346 (Chef 23.10., 19:51, 0.1.1008: out of memory in the deep forest): the pictures last used, kept up to [budget] bytes
 * in all instead of a count. With a count of 400, the light image made anew at every few steps filled it with 400 big
 * pictures nobody showed again, and each kept its pixels on the heap and its bitmap besides.
 */
class SizedCache<K, V>(val budget: Long, private val bytes: (K) -> Long) {
    private val map = LinkedHashMap<K, V>(64, 0.75f, true)
    var held = 0L
        private set
    val size get() = map.size

    fun getOrPut(key: K, make: () -> V): V {
        map[key]?.let { return it }
        val v = make()
        map[key] = v
        held += bytes(key)
        // the newest stays even when it alone is over the budget
        val it = map.entries.iterator()
        while (held > budget && map.size > 1) {
            val e = it.next()
            held -= bytes(e.key)
            it.remove()
        }
        return v
    }

    fun clear() { map.clear(); held = 0 }

    companion object {
        /**
         * A sixteenth of the heap, between 16 and 64 MB (32 MB on the A56): room for what one screen shows at once (the
         * ground in chunks of 256 KB, the light image up to 250 KB, a battle frame up to 250 KB) several times over.
         */
        fun pictureBudget(maxMemory: Long = Runtime.getRuntime().maxMemory()): Long = (maxMemory / 16).coerceIn(16L shl 20, 64L shl 20)

        /** The bytes a [PixelImage] holds. */
        fun bytesOf(p: PixelImage): Long = p.pixels.size * 4L
    }
}
