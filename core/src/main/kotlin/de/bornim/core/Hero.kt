package de.bornim.core

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
class Hero(
    var name: String,
    val race: Race,
    val cls: CharClass,
    var level: Int = 1,
    var xp: Int = 0,
    val base: MutableMap<Ability, Int>,
    var hp: Int = 0,
    var sp: Int = 0,
    var unspentPoints: Int = 0,
    /** Equipment of save games from version 1 (item ids); converted on load. */
    @SerialName("equipment") val legacyEquipment: MutableMap<String, String> = mutableMapOf(),
    val gear: MutableMap<GearSlot, Gear> = mutableMapOf(),
) {
    fun item(slot: GearSlot): Gear? = gear[slot]

    /** Sum of an affix over all equipped gear. */
    fun bonus(a: Affix): Int = gear.values.sumOf { it.total(a) }

    private fun statAffix(a: Ability) = when (a) {
        Ability.STR -> Affix.STR
        Ability.DEX -> Affix.DEX
        Ability.CON -> Affix.CON
        Ability.INT -> Affix.INT
        Ability.WIS -> Affix.WIS
        Ability.CHA -> Affix.CHA
    }

    /** Bonus of the equipped gear on an ability. */
    fun gearBonus(a: Ability): Int = bonus(statAffix(a)) + bonus(Affix.ALL_STATS)

    /** Ability points spent so far (one per level after the first). */
    val spentPoints: Int get() = Ability.entries.sumOf { base.getValue(it) - startingScores(race, cls).getValue(it) }.coerceAtLeast(0)

    /** Ability score including gear. Gear can push it past 20. */
    fun score(a: Ability): Int = base.getValue(a) + bonus(statAffix(a)) + bonus(Affix.ALL_STATS)

    fun mod(a: Ability): Int = Rules.mod(score(a))
    val proficiency: Int get() = Rules.proficiency(level)

    val maxHp: Int
        get() {
            val con = mod(Ability.CON)
            val perLevel = maxOf(1, cls.hitDie / 2 + 1 + con)
            // A small heroic bonus keeps level 1 from being too swingy.
            return maxOf(1, cls.hitDie + con + 4) + (level - 1) * perLevel + bonus(Affix.HP)
        }

    val maxSp: Int get() = if (cls.caster) Rules.spellPoints(level) + bonus(Affix.SP) else 0

    fun has(skill: Skill): Boolean = skill.cls == cls && level >= skill.level

    val armorClass: Int get() = armorClass(mageArmor = false)

    fun armorClass(mageArmor: Boolean): Int {
        val dex = mod(Ability.DEX)
        val chest = item(GearSlot.CHEST)
        val worn = chest != null && chest.def.armor > 0
        var ac = when {
            !worn && mageArmor -> 13 + dex
            !worn -> 10 + dex
            chest!!.def.weight == Weight.LIGHT -> chest.def.armor + dex
            chest.def.weight == Weight.MEDIUM -> chest.def.armor + minOf(dex, 2)
            else -> chest.def.armor
        }
        if (worn) ac += chest!!.plus
        if (worn && has(Skill.FIGHTING_STYLE)) ac += 1
        item(GearSlot.OFF_HAND)?.takeIf { it.def.kind == BaseKind.SHIELD }?.let { ac += it.def.armor + it.plus }
        return ac + bonus(Affix.AC)
    }

    val weapon: Gear? get() = item(GearSlot.MAIN_HAND)

    /** A weapon in the off hand gives an extra attack (two-weapon fighting). */
    val offHandWeapon: Gear? get() = item(GearSlot.OFF_HAND)?.takeIf { it.def.isWeapon }

    fun weaponAbility(w: Gear? = weapon): Ability {
        val d = w?.def ?: return Ability.STR
        return when {
            d.ranged -> Ability.DEX
            d.finesse && mod(Ability.DEX) > mod(Ability.STR) -> Ability.DEX
            else -> Ability.STR
        }
    }

    fun proficientWith(w: Gear): Boolean = Loot.proficient(cls, w.def)

    fun attackBonus(w: Gear?): Int {
        val prof = if (w == null || proficientWith(w)) proficiency else 0
        return mod(weaponAbility(w)) + prof + (w?.plus ?: 0) + bonus(Affix.ATTACK)
    }

    val attackBonus: Int get() = attackBonus(weapon)

    /** Damage of a weapon hit. The off-hand weapon adds no ability modifier (SRD two-weapon fighting). */
    fun weaponDamage(w: Gear?, offHand: Boolean = false): DiceExpr {
        val extra = bonus(Affix.DAMAGE) + bonus(Affix.FIRE) + bonus(Affix.RADIANT)
        if (w == null) return dice(1, 1, mod(Ability.STR) + extra)
        val d = w.def.damage ?: dice(1, 4)
        val ability = if (offHand) minOf(0, mod(weaponAbility(w))) else mod(weaponAbility(w))
        return d.copy(bonus = d.bonus + ability + w.plus + extra)
    }

    val weaponDamage: DiceExpr get() = weaponDamage(weapon)

    val spellAbility: Ability get() = cls.primary
    val spellBonusFromItems: Int get() = gear.values.sumOf { it.def.focus } + bonus(Affix.SPELL)
    val spellAttack: Int get() = mod(spellAbility) + proficiency + spellBonusFromItems
    val spellDc: Int get() = 8 + mod(spellAbility) + proficiency + spellBonusFromItems

    /** Lowest d20 roll that is a critical hit. */
    val critFrom: Int get() = (20 - bonus(Affix.CRIT) - if (has(Skill.IMPROVED_CRITICAL)) 1 else 0).coerceAtLeast(17)
    val lifeSteal: Int get() = bonus(Affix.LIFESTEAL).coerceAtMost(30)
    val damageReduction: Int get() = bonus(Affix.RESIST)
    /** Chance in percent to shrug off a negative status. */
    val tenacity: Int get() = bonus(Affix.TENACITY).coerceAtMost(60)

    fun canWear(g: Gear): Boolean = Loot.wearable(cls, g.def)

    /**
     * Equip [g] in its natural slot, returning everything that had to come off. Two-handed weapons
     * take both hands; an off-hand item knocks out a two-handed main weapon.
     */
    fun equip(g: Gear): List<Gear> {
        val removed = mutableListOf<Gear>()
        val d = g.def
        val slot = d.slot
        gear.put(slot, g)?.let { removed += it }
        if (d.twoHanded) gear.remove(GearSlot.OFF_HAND)?.let { removed += it }
        if (slot == GearSlot.OFF_HAND && weapon?.def?.twoHanded == true) gear.remove(GearSlot.MAIN_HAND)?.let { removed += it }
        clamp()
        return removed
    }

    /** Puts a one-handed weapon explicitly into the off hand. */
    fun equipOffHand(g: Gear): List<Gear> {
        require(g.def.isWeapon && !g.def.twoHanded)
        val removed = mutableListOf<Gear>()
        gear.put(GearSlot.OFF_HAND, g)?.let { removed += it }
        if (weapon?.def?.twoHanded == true) gear.remove(GearSlot.MAIN_HAND)?.let { removed += it }
        clamp()
        return removed
    }

    fun unequip(slot: GearSlot): Gear? = gear.remove(slot).also { clamp() }

    fun clamp() {
        hp = hp.coerceIn(0, maxHp)
        sp = sp.coerceIn(0, maxSp)
    }

    fun restoreFully() {
        hp = maxHp
        sp = maxSp
    }

    /** Adds XP and returns the number of levels gained. */
    fun gainXp(amount: Int): Int {
        val before = level
        xp += amount
        val target = Rules.levelForXp(xp)
        while (level < target) {
            level++
            unspentPoints += 1
        }
        // A level up fully restores HP and SP.
        if (level > before) restoreFully()
        clamp()
        return level - before
    }

    /** Whether [a] can take one more point on top of [pending] points already planned for it. */
    fun canRaise(a: Ability, pending: Int = 0): Boolean =
        pending < unspentPoints && base.getValue(a) + pending < Rules.MAX_SCORE

    /** Spends several points at once, e.g. after the player confirmed a distribution. */
    fun applyPoints(alloc: Map<Ability, Int>): Boolean {
        if (alloc.values.any { it < 0 } || alloc.values.sum() > unspentPoints) return false
        if (alloc.any { (a, n) -> base.getValue(a) + n > Rules.MAX_SCORE }) return false
        alloc.forEach { (a, n) -> repeat(n) { raise(a) } }
        return true
    }

    fun raise(a: Ability): Boolean {
        if (unspentPoints <= 0 || base.getValue(a) >= Rules.MAX_SCORE) return false
        val oldMax = maxHp
        base[a] = base.getValue(a) + 1
        unspentPoints--
        if (maxHp > oldMax) hp += maxHp - oldMax
        clamp()
        return true
    }

    data class Comparison(
        val acBefore: Int, val acAfter: Int,
        val attackBefore: Int, val attackAfter: Int,
        val damageBefore: DiceExpr, val damageAfter: DiceExpr,
        val hpBefore: Int, val hpAfter: Int,
    )

    /** How the main numbers would change if [g] were equipped. Leaves the hero untouched. */
    fun compare(g: Gear): Comparison {
        val saved = gear.toMap()
        val savedHp = hp
        val savedSp = sp
        val ac0 = armorClass; val atk0 = attackBonus; val dmg0 = weaponDamage; val hp0 = maxHp
        equip(g)
        val result = Comparison(ac0, armorClass, atk0, attackBonus, dmg0, weaponDamage, hp0, maxHp)
        gear.clear()
        gear.putAll(saved)
        hp = savedHp
        sp = savedSp
        return result
    }

    companion object {
        /** Ability scores of a new hero: the standard array in class order plus the race bonus. */
        fun startingScores(race: Race, cls: CharClass): Map<Ability, Int> {
            val scores = mutableMapOf<Ability, Int>()
            cls.priority.forEachIndexed { i, a -> scores[a] = Rules.standardArray[i] + (race.bonus[a] ?: 0) }
            return scores
        }

        fun create(name: String, race: Race, cls: CharClass, newUid: () -> Long = { 0L }): Hero {
            val hero = Hero(name, race, cls, base = startingScores(race, cls).toMutableMap())
            cls.startItems.filter { GearBases.exists(it) }.forEach { id ->
                hero.equip(Gear(newUid(), id, Rarity.COMMON, 1))
            }
            hero.restoreFully()
            return hero
        }
    }
}
