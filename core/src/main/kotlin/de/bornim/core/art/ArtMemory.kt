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
     * it lets go as above and [after] lets go of the bitmaps, at most once in [PAUSE_MS]. True when it did.
     *
     * 358 (Build 85, Chef 24.10., 21:12: Ruckeln ab dem ersten Kampf im Wald, „geräumt 6×“): letting go frees some 40 MB
     * of near 300 (the frames of the fight and of the place shown stay needed), so the heap stayed high and every 20 s
     * all bitmaps were made anew and the foe's frames thrown away in the fight and drawn again. Now it lets go again only
     * once the heap has grown by [STEP] of its size since it last did, and the frames of [keepFoes] (the foe fought or
     * near) always stay.
     */
    fun checkHeap(used: Long = Runtime.getRuntime().let { it.totalMemory() - it.freeMemory() }, max: Long = Runtime.getRuntime().maxMemory(),
        now: Long = System.currentTimeMillis(), keepFoes: () -> Set<String> = { emptySet() }, after: () -> Unit = {}): Boolean {
        if (used < max * HIGH) { trimmedAt = 0L; return false }
        if (trims > 0 && (now - lastTrim < PAUSE_MS || (trimmedAt > 0 && used < trimmedAt + max * STEP))) return false
        trim(); after(); trims++; lastTrim = now; trimmedAt = used; lastUsedMb = (used shr 20).toInt()
        // second crash (20:11, forest): drawing a foe ahead and the folk's breathing ran out together; over [HIGHEST] the
        // frames of the foes not near go too, drawn again when a fight needs them
        if (used >= max * HIGHEST) keepFoes().let { k -> FoeArt.forgetBut(k); BeastArt.forgetBut(k); VerminArt.forgetBut(k) }
        return true
    }

    const val HIGH = 0.8
    const val HIGHEST = 0.9
    const val STEP = 0.1
    const val PAUSE_MS = 20_000L
    private var lastTrim = 0L
    /** The heap in use when it last let go; 0 once it fell below [HIGH] again. */
    private var trimmedAt = 0L

    /** The heap in use, in MB, when [checkHeap] last let go, for the test tab. */
    @Volatile var lastUsedMb = 0
        private set

    /** How often [checkHeap] let go since the start, for the test tab. */
    @Volatile var trims = 0
        private set
}
