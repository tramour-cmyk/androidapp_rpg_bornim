package de.bornim.core

import de.bornim.core.art.MapFolk
import de.bornim.core.audio.Ambience
import de.bornim.core.audio.Sound

/**
 * 134.1: people the hero has spoken with show a short golden sign when they have something new for him: their
 * talk differs from what he heard last time, or he can hand in their job. What they say depends only on the
 * saved game, so the game tells "new" by itself, without a list to keep for each text.
 */
object Hail {
    /** The sign shows this long when the hero comes near, then once more after [AGAIN]. */
    const val SHOW_MS = 1_400L
    const val AGAIN_MS = 3_200L

    /** What [cmds] say, as one number: the lines as written ("{name}" not filled in), so the language does not count. */
    fun fingerprint(cmds: List<Cmd>): Int = cmds.filterIsInstance<Cmd.Say>().joinToString("\n") { it.text.de }.hashCode()

    /** Whether [npc] has something new for the hero: met before, and a job to hand in or a talk not heard yet. */
    fun news(s: GameState, npc: Npc): Boolean {
        if (npc.look.startsWith("monster:") || !s.has(MapMarks.met(npc.id))) return false
        if (Jobs.handIn(s, npc.id) != null) return true
        // saves from before 134.1 know nothing of what was heard: no sign until the next talk
        val known = s.heard[npc.id] ?: return false
        return fingerprint(npc.talk(s)) !in known
    }

    /**
     * The hero talks to [npc] ([after] false), or the talk is over ([after] true): what they would say now counts
     * as heard. After the talk too, so a line that only follows from the talk itself (the barrier open) is no news.
     */
    fun heard(s: GameState, npc: Npc, after: Boolean) {
        val fp = fingerprint(npc.talk(s))
        s.heard[npc.id] = if (after) ((s.heard[npc.id] ?: emptyList()) + fp).distinct().takeLast(2) else listOf(fp)
    }

    /** Whether the sign shows [ms] after the hero came near: briefly, then once again. */
    fun showing(ms: Long): Boolean = ms in 0 until SHOW_MS || ms in AGAIN_MS until AGAIN_MS + SHOW_MS

    /** 134.3: at least this long between two calls. */
    const val CALL_GAP_MS = 1_800L

    /**
     * 134.3: how [npcId] calls the hero with the sign, without words (DESIGN-STIL.md, Klang): a man, a woman, the child;
     * null for someone whose looks the map does not know.
     */
    fun voice(npcId: String): Sound? = MapFolk.of(npcId)?.doll?.let { d ->
        when {
            d.sizeK < 0.8 -> Sound.HAIL_CHILD
            d.sex == Sex.FEMALE -> Sound.HAIL_WOMAN
            else -> Sound.HAIL_MAN
        }
    }

    /** 134.3: how loud the call is [dist] tiles off: someone near calling, not shouting. */
    fun callVolume(dist: Int): Float = Ambience.heardAt(dist, 0.6f)

    /** 134.2: how far into its gesture someone is [ms] after the hero came near: it plays with the sign, both times. */
    fun gestureMs(ms: Long): Long? = when (ms) {
        in 0 until SHOW_MS -> ms
        in AGAIN_MS until AGAIN_MS + SHOW_MS -> ms - AGAIN_MS
        else -> null
    }
}
