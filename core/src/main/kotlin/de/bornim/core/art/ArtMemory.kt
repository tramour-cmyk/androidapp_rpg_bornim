package de.bornim.core.art

/** 30.2: when memory runs short, the pictures not needed on the map shown now are let go; they are drawn again when wanted. */
object ArtMemory {
    fun trim() {
        MapGround.trim()
        MapSun.trim()
        MapFolk.keepOnly(MapFolk.shown?.let { MapFolk.idsOn(it) } ?: emptySet())
    }

    /**
     * 346 (0.1.1008: out of memory while drawing the deep forest): the system warns only when the phone runs short, not
     * when the app's own heap is nearly full, so the app looks itself every few seconds: over [HIGH] of the heap in use,
     * it lets go as above and [after] lets go of the bitmaps, at most once in [PAUSE_MS] (what a fight needs stays high,
     * and the bitmaps made anew every frame would only make it slow). True when it did.
     */
    fun checkHeap(used: Long = Runtime.getRuntime().let { it.totalMemory() - it.freeMemory() }, max: Long = Runtime.getRuntime().maxMemory(),
        now: Long = System.currentTimeMillis(), after: () -> Unit = {}): Boolean {
        if (used < max * HIGH || (trims > 0 && now - lastTrim < PAUSE_MS)) return false
        trim(); after(); trims++; lastTrim = now
        return true
    }

    const val HIGH = 0.8
    const val PAUSE_MS = 20_000L
    private var lastTrim = 0L

    /** How often [checkHeap] let go since the start, for the test tab. */
    @Volatile var trims = 0
        private set
}
