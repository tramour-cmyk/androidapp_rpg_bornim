package de.bornim.core.audio

import de.bornim.core.GameState
import de.bornim.core.MapDef
import de.bornim.core.MapKind
import kotlin.random.Random

/**
 * What a place sounds like (24.8), heard from the moment the black screen comes down, before the picture: wind outside,
 * the still air of the temple hall, wood creaking now and then in the houses, a drop in the cave at once. Only what is
 * there makes a sound (DESIGN-STIL.md, Klang; 24.8.4): no crowd in the inn, but the innkeeper wiping, pouring, setting down a
 * cup, and a guest's chair or cough, one at a time and never in step.
 */
object PlaceSound {
    enum class Kind { OUTSIDE, TAVERN, HALL, ROOM, CAVE }

    fun kindOf(map: MapDef): Kind = when {
        map.kind == MapKind.TOWN || map.kind == MapKind.FOREST -> Kind.OUTSIDE
        map.kind == MapKind.CAVE -> Kind.CAVE
        map.id == "inn" -> Kind.TAVERN
        map.id == "temple" -> Kind.HALL
        else -> Kind.ROOM
    }

    /** The sound that lies under everything at this kind of place, looping, or null for none. */
    fun bed(kind: Kind): Sound? = when (kind) {
        Kind.OUTSIDE -> Sound.WIND
        Kind.HALL -> Sound.HALL
        else -> null
    }

    const val BED_VOLUME = 0.3f
    /** Time for the bed to swell in from silence (it starts under the black screen) or to fade back. */
    const val BED_FADE_MS = 2000.0

    /** Moves the bed's volume [cur] towards [target], at most a full swell per [BED_FADE_MS]: it never jumps. */
    fun approach(cur: Float, target: Float, dtMs: Long): Float {
        val step = (BED_VOLUME * dtMs / BED_FADE_MS).toFloat()
        return if (target > cur) minOf(target, cur + step) else maxOf(target, cur - step)
    }

    /** Leaving a place, its loops (wind, hall, fire) die away in this time instead of breaking off (24.8.5). */
    const val LEAVE_FADE_MS = 600L

    /** The volume of a loop that was at [from] when the place was left, [elapsedMs] later: down to 0 in [LEAVE_FADE_MS]. */
    fun leaving(from: Float, elapsedMs: Long): Float =
        if (elapsedMs >= LEAVE_FADE_MS) 0f else from * (1f - elapsedMs.toFloat() / LEAVE_FADE_MS)

    /** The look of the innkeeper: she wipes, pours and sets down cups; everyone else is a guest. */
    const val HOST = "innkeeper"

    /**
     * The single sounds the place and the people in it make, each with its weight: the innkeeper's work, the guests'
     * cups, chairs and now and then a cough (rare), wood creaking in rooms. Empty where nothing makes a sound.
     */
    fun events(kind: Kind, present: List<String>): List<Pair<Sound, Int>> {
        val out = mutableListOf<Pair<Sound, Int>>()
        if (kind == Kind.TAVERN) {
            if (HOST in present) out += listOf(Sound.WIPE to 4, Sound.POUR to 3, Sound.CUP to 3)
            if (present.any { it != HOST }) out += listOf(Sound.CUP to 5, Sound.CHAIR to 3, Sound.COUGH to 1)
        }
        if (kind == Kind.TAVERN || kind == Kind.ROOM) out += Sound.CREAK to 1
        return out
    }

    /** The looks of the people standing on [map] now. */
    fun present(map: MapDef, state: GameState): List<String> = map.npcs.filter { it.visible(state) }.map { it.look }

    /** Pause before the next single sound: lively in the inn (3–8 s), rare elsewhere (12–30 s). */
    fun gapMs(kind: Kind, rnd: Random): Long =
        if (kind == Kind.TAVERN) 3000L + rnd.nextLong(5000) else 12000L + rnd.nextLong(18000)

    /** The first single sound comes soon after arriving, while the screen is still dark. */
    fun firstMs(kind: Kind, rnd: Random): Long = 600L + rnd.nextLong(if (kind == Kind.TAVERN) 1500 else 4000)

    const val EVENT_VOLUME = 0.35f

    /** One sound from [events] by weight, never the same twice in a row when there is a choice. */
    fun pick(events: List<Pair<Sound, Int>>, last: Sound?, rnd: Random): Sound? {
        val pool = events.filter { it.first != last }.ifEmpty { events }
        val total = pool.sumOf { it.second }
        if (total <= 0) return null
        var r = rnd.nextInt(total)
        for ((s, w) in pool) { if (r < w) return s; r -= w }
        return pool.last().first
    }
}
