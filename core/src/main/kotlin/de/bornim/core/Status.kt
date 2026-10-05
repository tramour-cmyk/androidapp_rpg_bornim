package de.bornim.core

/** Lasting conditions in battle. Negative ones are cleared by a remedy or at the end of the fight. */
enum class Status(val title: T, val short: T, val color: Long, val desc: T) {
    POISON(T("Vergiftet", "Poisoned"), T("Gift", "Psn"), 0xFF6FB83A, T("Schaden zu Beginn jeder Runde.", "Damage at the start of each round.")),
    BURN(T("Brennend", "Burning"), T("Brand", "Brn"), 0xFFE8701A, T("Starker Schaden zu Beginn jeder Runde.", "Heavy damage at the start of each round.")),
    BLEED(T("Blutend", "Bleeding"), T("Blut", "Bld"), 0xFFC8283A, T("Schaden jede Runde, Heilung nur halb so stark.", "Damage each round, healing is halved.")),
    STUN(T("Betäubt", "Stunned"), T("Betäubt", "Stun"), 0xFFE0B020, T("Setzt die nächste Runde aus.", "Loses the next turn.")),
    SLOW(T("Verlangsamt", "Slowed"), T("Langsam", "Slow"), 0xFF4A90D8, T("−2 auf Angriff und Rüstungsklasse.", "−2 to attack and armor class.")),
    WEAK(T("Geschwächt", "Weakened"), T("Schwach", "Weak"), 0xFF8A58C8, T("−2 auf Angriff und Schaden.", "−2 to attack and damage.")),
    BLIND(T("Geblendet", "Blinded"), T("Blind", "Blind"), 0xFF6A6A7A, T("Angriffe mit Nachteil.", "Attacks with disadvantage.")),
    ;

    val damaging: Boolean get() = this == POISON || this == BURN || this == BLEED

    companion object {
        /** Creatures that cannot suffer a status at all. */
        fun immune(m: MonsterDef, s: Status): Boolean = when (s) {
            POISON -> DamageType.POISON in m.immune
            BLEED -> m.id == "skeleton" || m.id == "ochre_jelly" || m.id == "zombie"
            STUN, BLIND -> m.id == "ochre_jelly"
            else -> false
        }
    }
}
