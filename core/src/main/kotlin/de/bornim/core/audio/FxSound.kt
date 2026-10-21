package de.bornim.core.audio

import de.bornim.core.FxKind

/** The sound of a battle effect, the same in the old fight and in MARS (256). */
object FxSound {
    fun of(kind: FxKind, crit: Boolean): Sound = when (kind) {
        FxKind.SLASH -> if (crit) Sound.CRIT else Sound.HIT_SLASH
        FxKind.PIERCE -> if (crit) Sound.CRIT else Sound.HIT_PIERCE
        FxKind.SMASH -> if (crit) Sound.CRIT else Sound.HIT_SMASH
        FxKind.ARROW -> Sound.ARROW
        FxKind.FIRE_BOLT, FxKind.RAYS, FxKind.FIREBALL -> Sound.FIRE
        FxKind.BOMB_FIRE, FxKind.BOMB_HOLY, FxKind.SMOKE -> Sound.THROW
        FxKind.MISSILES, FxKind.SPIRIT_WEAPON, FxKind.SPIRIT_SUMMON, FxKind.MAGE_ARMOR -> Sound.MAGIC
        FxKind.SACRED_FLAME, FxKind.GUARDIANS, FxKind.TURN, FxKind.DESTROY -> Sound.HOLY
        FxKind.HEAL -> Sound.HEAL
        FxKind.BLESS -> Sound.BUFF
        FxKind.ENEMY_HEAL -> Sound.POTION
        FxKind.BITE -> Sound.BITE
        FxKind.POISON -> Sound.POISON
        FxKind.DODGE -> Sound.MISS
        FxKind.BLOCK -> Sound.BLOCK
        FxKind.DRAIN -> Sound.BITE
        FxKind.ACID -> Sound.POISON
        FxKind.PARALYZE -> Sound.MAGIC
        FxKind.BURN -> Sound.FIRE
        FxKind.BLEED -> Sound.HIT_SLASH
        FxKind.STUN -> Sound.HIT_SMASH
        FxKind.CURSE -> Sound.MAGIC
    }
}
