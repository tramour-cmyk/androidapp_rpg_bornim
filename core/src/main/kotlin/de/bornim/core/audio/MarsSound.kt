package de.bornim.core.audio

import de.bornim.core.FxKind
import de.bornim.core.RollKind
import de.bornim.core.Side
import de.bornim.core.Skirmish
import de.bornim.core.SkirmishCue
import de.bornim.core.SkirmishEvent
import de.bornim.core.weaponFx

/**
 * 256: the sounds of a MARS message, as in the old fight ([FxSound], `soundFor`): blows by weapon or by the foe's
 * attack, critical, spells by kind (a spell that goes wide still sounds as it is let go), heal, venom, falls; the
 * swish of a blow of the party before it lands, the foe's voice as it winds up, its cry just after the blow. No new sound.
 */
object MarsSound {
    /** When the blow of a lunge lands, from the start of its message: half the lunge (`SWING_IN_MS`). */
    const val LANDS_MS = 170L
    /** The cry just after the sound of the blow, never over it, as in the old fight. */
    const val CRY_MS = LANDS_MS + 90L

    /** One sound [atMs] into the message: a [sound], or the [voice] of the monster [monster]. */
    data class Cue(val atMs: Long, val sound: Sound? = null, val voice: Recorded.Cue? = null, val monster: String? = null, val volume: Float = 0.8f)

    fun of(e: SkirmishEvent, sk: Skirmish): List<Cue> {
        val actor = e.actor?.let { id -> sk.fighters.firstOrNull { it.id == id } }
        val target = e.target?.let { id -> sk.fighters.firstOrNull { it.id == id } }
        val out = mutableListOf<Cue>()
        when (e.cue) {
            SkirmishCue.FOE_STRIKES -> actor?.monster?.let { out += Cue(0, voice = Recorded.Cue.ATTACK, monster = it.id) }
            SkirmishCue.CIRCLE -> out += Cue(0, Sound.HOWL)
            SkirmishCue.HEAL, SkirmishCue.DRINK -> out += Cue(0, Sound.HEAL)
            SkirmishCue.GATHER -> out += Cue(0, FxSound.of(FxKind.ENEMY_HEAL, false))
            SkirmishCue.VENOM -> out += Cue(0, Sound.POISON)
            SkirmishCue.WEB -> out += Cue(0, Sound.THROW)
            SkirmishCue.FOE_FALLS -> out += Cue(0, Sound.ENEMY_DOWN)
            SkirmishCue.HERO_FALLS, SkirmishCue.KNOCKED_OUT -> out += Cue(0, Sound.HERO_DOWN)
            // Rückläufer t53: thrown to the ground, a dull blow as one lands; getting up is quiet
            SkirmishCue.POUNCED -> out += Cue(0, Sound.HIT_SMASH, volume = 0.6f)
            SkirmishCue.RISES, SkirmishCue.BEHIND, SkirmishCue.STATUS -> {}
            // Rückläufer t58: the ducked arrow hisses past, as a missed shot
            SkirmishCue.DUCKED -> out += Cue(0, Sound.ARROW)
            null -> {}
        }
        if (e.cue != null) return out
        // a blessing or a spell that lands
        e.spell?.let { kind ->
            if (kind == FxKind.HEAL || kind == FxKind.BLESS || (actor != null && target != null && actor.side != target.side)) {
                out += Cue(0, FxSound.of(kind, crit(e)))
            }
            return out
        }
        // a blow, a bite or a shot: only between the sides, with its roll
        if (actor == null || target == null || actor.side == target.side || e.roll?.kind != RollKind.ATTACK) return out
        val kind = actor.monster?.attackFx ?: weaponFx(actor.weapon)
        val lunge = kind != FxKind.ARROW
        val lands = if (lunge) LANDS_MS else 0L
        // the swish as the weapon comes down: heavier for great weapons and hammers (the hero's only, as in the old fight)
        if (actor.side == Side.PARTY && lunge) {
            val w = actor.weapon?.def
            val heavy = w != null && (w.twoHanded || w.icon == de.bornim.core.Icon.HAMMER || w.icon == de.bornim.core.Icon.MACE)
            out += Cue(0, if (heavy) Sound.SWING_HEAVY else Sound.SWING)
        }
        if (e.damage > 0) {
            out += Cue(lands, FxSound.of(kind, crit(e)))
            target.monster?.let { m ->
                val dies = (e.hp[target.id] ?: 1) <= 0
                out += Cue(lands + CRY_MS - LANDS_MS, voice = if (dies) Recorded.Cue.DIE else Recorded.Cue.HURT, monster = m.id)
            }
        } else if (kind == FxKind.ARROW) out += Cue(0, Sound.ARROW)
        else out += Cue(lands, Sound.MISS)
        return out
    }

    private fun crit(e: SkirmishEvent) = e.roll?.let { it.kind == RollKind.ATTACK && it.success && it.d20 == 20 } == true

    /** The music of a MARS fight, as in the old one: the boss piece only against a boss. */
    fun music(sk: Skirmish): MusicScene = if (sk.fighters.any { it.side == Side.FOES && it.boss }) MusicScene.BOSS else MusicScene.BATTLE
}
