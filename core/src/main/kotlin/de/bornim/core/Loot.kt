package de.bornim.core

/** Randomized item generation with rarities and affixes. */
object Loot {
    /** Base chance per mille of each rarity before magic find. */
    private val baseWeights = mapOf(
        Rarity.COMMON to 560,
        Rarity.UNCOMMON to 270,
        Rarity.RARE to 115,
        Rarity.VERY_RARE to 40,
        Rarity.EPIC to 12,
        Rarity.DIVINE to 3,
    )

    /** Item level needed before a rarity can drop at all. */
    private fun minIlvl(r: Rarity) = when (r) {
        Rarity.EPIC -> 3
        Rarity.DIVINE -> 5
        else -> 1
    }

    /**
     * Rolls a rarity. [magicFind] in percent boosts everything above common;
     * [atLeast] guarantees a floor (elites, bosses, chests).
     */
    fun rollRarity(dice: Dice, ilvl: Int, magicFind: Int = 0, atLeast: Rarity = Rarity.COMMON): Rarity {
        val mf = 1.0 + magicFind / 100.0
        val entries = Rarity.entries
            .filter { it >= atLeast && ilvl >= minIlvl(it) }
            .map { r -> r to (baseWeights.getValue(r) * (if (r == Rarity.COMMON) 1.0 else mf)).toInt().coerceAtLeast(1) }
        return dice.weighted(entries)
    }

    /** Can [cls] make good use of this base? Used to bias drops towards the player's class. */
    fun suits(cls: CharClass, b: GearBase): Boolean = when (b.kind) {
        BaseKind.JEWELRY -> true
        BaseKind.ARMOR -> when {
            b.slot == GearSlot.CLOAK -> true
            cls == CharClass.WIZARD -> b.weight == Weight.CLOTH
            else -> b.weight != Weight.CLOTH && wearable(cls, b)
        }
        BaseKind.SHIELD -> cls.shields
        BaseKind.FOCUS -> cls.caster
        BaseKind.WEAPON -> proficient(cls, b) && (b.focus == 0 || cls.caster)
    }

    fun wearable(cls: CharClass, b: GearBase): Boolean = when (b.kind) {
        BaseKind.ARMOR -> when (b.weight) {
            Weight.NONE, Weight.CLOTH -> true
            Weight.LIGHT -> ArmorCategory.LIGHT in cls.armor
            Weight.MEDIUM -> ArmorCategory.MEDIUM in cls.armor
            Weight.HEAVY -> ArmorCategory.HEAVY in cls.armor
        }
        BaseKind.SHIELD -> cls.shields
        else -> true
    }

    fun proficient(cls: CharClass, b: GearBase): Boolean = !b.isWeapon || cls.weapons == null || b.id in cls.weapons

    /** Generates one random piece of gear. */
    fun generate(state: GameState, dice: Dice, ilvl: Int, rarity: Rarity, forClass: CharClass? = null, slot: GearSlot? = null): Gear {
        val level = ilvl.coerceAtLeast(1)
        var pool = GearBases.all.filter { it.minLevel <= level && (slot == null || it.slot == slot) }
        if (forClass != null) pool = pool.filter { suits(forClass, it) }.ifEmpty { pool }
        val base = dice.pick(pool)
        return roll(state.nextUid(), base, level, rarity, dice)
    }

    fun roll(uid: Long, base: GearBase, ilvl: Int, rarity: Rarity, dice: Dice): Gear {
        val allowed = GearBases.affixesFor(base).toMutableList()
        val rolls = mutableListOf<Roll>()
        if (rarity == Rarity.DIVINE) rolls += Roll(Affix.ALL_STATS, 1 + dice.d(2) - 1 + ilvl / 8)
        while (rolls.size < rarity.affixes && allowed.isNotEmpty()) {
            val a = dice.pick(allowed)
            allowed.remove(a)
            rolls += Roll(a, value(a, ilvl, rarity, dice))
        }
        val enhanceable = base.isWeapon || base.slot == GearSlot.CHEST || base.kind == BaseKind.SHIELD
        val plus = if (!enhanceable) 0 else when (rarity) {
            Rarity.COMMON, Rarity.UNCOMMON -> 0
            Rarity.RARE -> 1
            Rarity.VERY_RARE -> 1 + dice.d(2) - 1
            Rarity.EPIC -> 2
            Rarity.DIVINE -> 3
        }
        return Gear(uid, base.id, rarity, ilvl, plus, rolls, dice.d(10_000))
    }

    /** Affix strength grows with item level; epic and divine items roll higher. */
    fun value(a: Affix, ilvl: Int, rarity: Rarity, dice: Dice): Int {
        fun upTo(n: Int) = if (n <= 0) 0 else dice.d(n + 1) - 1
        val raw = when (a) {
            Affix.STR, Affix.DEX, Affix.CON, Affix.INT, Affix.WIS, Affix.CHA -> 1 + upTo(ilvl / 4)
            Affix.ALL_STATS -> 1
            Affix.AC -> 1 + upTo(ilvl / 6)
            Affix.ATTACK -> 1 + upTo(ilvl / 5)
            Affix.DAMAGE -> 1 + upTo(ilvl / 3)
            Affix.SPELL -> 1 + upTo(ilvl / 6)
            Affix.HP -> 3 + upTo(ilvl * 2)
            Affix.SP -> 1 + upTo(1 + ilvl / 2)
            Affix.CRIT -> 1
            Affix.FIRE, Affix.RADIANT -> 1 + upTo(1 + ilvl / 2)
            Affix.LIFESTEAL -> 3 + upTo(7)
            Affix.RESIST -> 1 + upTo(ilvl / 5)
            Affix.GOLD_FIND -> 10 + upTo(40)
            Affix.MAGIC_FIND -> 5 + upTo(25)
            Affix.XP -> 5 + upTo(15)
        }
        val boost = when (rarity) {
            Rarity.EPIC -> 1.25
            Rarity.DIVINE -> 1.5
            else -> 1.0
        }
        return if (boost == 1.0 || a == Affix.CRIT) raw else maxOf(raw + 1, (raw * boost).toInt())
    }

    /** Gear dropped by a defeated monster. */
    fun drops(state: GameState, dice: Dice, ilvl: Int, boss: Boolean, elite: Boolean): List<Gear> {
        val mf = state.hero.bonus(Affix.MAGIC_FIND)
        val (count, floor) = when {
            boss -> 2 + dice.d(2) to Rarity.RARE
            elite -> 1 + dice.d(2) - 1 to Rarity.UNCOMMON
            dice.chance(0.38) -> 1 to Rarity.COMMON
            else -> 0 to Rarity.COMMON
        }
        return List(count) {
            val r = rollRarity(dice, ilvl, mf, floor)
            // Two thirds of the drops are tailored to the hero's class.
            generate(state, dice, ilvl, r, if (dice.chance(0.67)) state.hero.cls else null)
        }
    }

    /** Stock of the general store: refreshed every few victories. */
    fun shopGear(state: GameState): List<Gear> {
        val level = state.hero.level
        val dice = Dice(kotlin.random.Random(state.battlesWon / 8 * 7919 + level * 31 + state.hero.name.hashCode()))
        val list = mutableListOf<Gear>()
        // the basics of each slot for the hero's class
        for (slot in GearSlot.entries) {
            val pool = GearBases.all.filter { it.slot == slot && it.minLevel <= level && suits(state.hero.cls, it) }
            if (pool.isNotEmpty()) list += roll(-(list.size + 1L), dice.pick(pool), level, Rarity.COMMON, dice)
        }
        // a handful of magic items
        repeat(5) {
            val r = rollRarity(dice, level, 0, Rarity.UNCOMMON).coerceAtMost(Rarity.VERY_RARE)
            list += generate(state, dice, level, r, state.hero.cls).copy(uid = -(list.size + 1L))
        }
        return list
    }
}

private fun Rarity.coerceAtMost(max: Rarity) = if (this > max) max else this
