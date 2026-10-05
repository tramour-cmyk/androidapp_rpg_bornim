package de.bornim.core

enum class Anim { NONE, HERO_ACT, ENEMY_ACT, ENEMY_HIT, HERO_HIT, HERO_HEAL, ENEMY_HEAL, MISS, SPELL, ENEMY_FAINT, HERO_FAINT, LEVEL_UP, LOOT, COINS }

/** Visual effect kinds for the battle screen. */
enum class FxKind {
    SLASH, PIERCE, SMASH, ARROW,
    FIRE_BOLT, MISSILES, RAYS, FIREBALL, SACRED_FLAME, SPIRIT_WEAPON, GUARDIANS, TURN,
    BOMB_FIRE, BOMB_HOLY, HEAL, BLESS, MAGE_ARMOR, ENEMY_HEAL,
    BITE, POISON, DODGE, BLOCK,
    DRAIN, ACID, PARALYZE, BURN,
}

/** An effect to play with a battle message. [seed] varies angles and particles so repeats look different. */
data class Fx(val kind: FxKind, val onHero: Boolean, val crit: Boolean = false, val seed: Int = 0)

/** One message of the battle log, with a snapshot of the numbers after it happened. */
data class Step(
    val text: String,
    val heroHp: Int,
    val enemyHp: Int,
    val heroSp: Int,
    val anim: Anim = Anim.NONE,
    /** Set for loot messages so the UI can color them. */
    val rarity: Rarity? = null,
    val fx: Fx? = null,
)

enum class Outcome { ONGOING, WON, LOST, FLED, ENEMY_FLED }

sealed interface Action {
    data object Attack : Action
    data class UseSkill(val skill: Skill) : Action
    data class UseItem(val item: String) : Action
    data object Flee : Action
}

data class Rewards(val xp: Int, val gold: Int, val items: List<String>, val gear: List<Gear>, val levelsGained: Int)

class Battle(
    val state: GameState,
    val monster: MonsterDef,
    var lang: Lang,
    private val dice: Dice = Dice(),
    /** Monster level; above the monster's home level it gets tougher and drops better loot. */
    val level: Int = 1,
    /** Elite monsters are stronger and always drop something. */
    val elite: Boolean = false,
    /** Level of the area, the baseline for scaling. */
    private val areaLevel: Int = level,
    /** The special power of an elite monster. */
    val trait: EliteTrait? = null,
    /** The rare shimmering variant: tougher, but with much better rewards. */
    val shiny: Boolean = false,
    /** Cosmetic variation of the sprite. */
    val look: MonsterLook = MonsterLook(),
) {
    val hero: Hero get() = state.hero
    private val over = (level - areaLevel).coerceAtLeast(0)
    /** Elites grow into their full strength over the first levels, so the start stays fair. */
    private val eliteTier: Int = if (!elite) 0 else if (level >= 4) 2 else 1
    val enemyAc: Int = monster.ac + over / 2 + (if (trait == EliteTrait.SWIFT) eliteTier else 0)
    private val enemyAttack: Int = monster.attackBonus + over * 2 / 3 + eliteTier + (if (shiny) 1 else 0)
    private val enemyDamageBonus: Int = over + eliteTier + (if (trait == EliteTrait.SAVAGE) eliteTier else 0)
    val enemyMaxHp: Int = maxOf(
        1,
        (dice.roll(monster.hp) * (1 + 0.35 * over) * (if (eliteTier == 2) 1.8 else if (elite) 1.5 else 1.0) *
            (if (trait == EliteTrait.ANCIENT) 1.3 else 1.0) * (if (shiny) 1.3 else 1.0)).toInt(),
    )
    /** Extra damage of venomous and burning elites. */
    private val traitDie: Int = if (eliteTier == 2) 6 else 4
    var enemyHp: Int = enemyMaxHp
        private set
    var outcome: Outcome = Outcome.ONGOING
        private set
    var rewards: Rewards? = null
        private set

    private val usesLeft = mutableMapOf<Skill, Int>()
    var mageArmor = false; private set
    var blessed = false; private set
    var spiritualWeapon = false; private set
    var guardians = false; private set
    private var heroProne = false
    private var heroHasHit = false
    private var dodgeUsed = false
    private var relentlessUsed = false
    private var enemyTurns = 0
    private var enemyPotions = monster.potions
    private var enemyHasHit = false
    private var acid = 0
    private var foeRelentlessUsed = false
    private var shamanHeals = 2

    private val steps = mutableListOf<Step>()

    init {
        hero.cls.skills().filter { it.cost == SkillCost.PER_BATTLE }.forEach { usesLeft[it] = it.amount }
    }

    val heroAc: Int get() = hero.armorClass(mageArmor) - acid

    // Cosmetic randomness has its own generator so it never changes the outcome of a fight.
    private fun fx(kind: FxKind, onHero: Boolean, crit: Boolean = false) = Fx(kind, onHero, crit, kotlin.random.Random.nextInt(1_000_000))

    private fun weaponFx(w: Gear?): FxKind = when {
        w == null -> FxKind.SMASH
        w.def.ranged -> FxKind.ARROW
        w.def.damageType == DamageType.SLASHING -> FxKind.SLASH
        w.def.damageType == DamageType.PIERCING -> FxKind.PIERCE
        else -> FxKind.SMASH
    }

    /** SRD cantrip scaling: one more die at levels 5, 11 and 17. */
    private val cantripDice: Int get() = 1 + listOf(5, 11, 17).count { hero.level >= it }
    private val name: String get() = hero.name
    /** Display name; elites and shimmering monsters carry an adjective ("Giftiger Wolf"). */
    fun foeName(l: Lang): String = when {
        shiny -> EliteTrait.shiny(l, monster.gender) + " " + monster.name(l)
        trait != null -> trait.adjective(l, monster.gender) + " " + monster.name(l)
        elite -> Msg.elite.f(l, monster.name(l))
        else -> monster.name(l)
    }
    private val foe: String get() = foeName(lang)

    // ---------------------------------------------------------------- public API

    fun start(): List<Step> {
        say(if (monster.boss) Msg.bossAppears.f(lang, foe) else Msg.appears.f(lang, foe))
        if (shiny) say(Msg.shiny(lang))
        trait?.let { say(Msg.eliteTrait.f(lang, it.desc(lang))) }
        if (monster.special == MonsterSpecial.PACK_TACTICS) say(Msg.pack(lang))
        val elf = if (hero.race == Race.ELF) 2 else 0
        val heroInit = dice.d20() + hero.mod(Ability.DEX) + elf
        val foeInit = dice.d20() + monster.dexSave
        if (foeInit > heroInit || (trait == EliteTrait.SWIFT && eliteTier == 2)) {
            say(Msg.foeFaster.f(lang, foe))
            enemyTurn()
        }
        return flush()
    }

    fun usesLeft(skill: Skill): Int? = usesLeft[skill]

    /** Null if usable, otherwise the reason why not. */
    fun blocked(skill: Skill): T? = when {
        !hero.has(skill) || skill.passive -> Msg.cannot
        skill.cost == SkillCost.PER_BATTLE && (usesLeft[skill] ?: 0) <= 0 -> Msg.noUses
        skill.cost == SkillCost.SPELL_POINTS && hero.sp < skill.amount -> Msg.noSp
        skill == Skill.MAGE_ARMOR && (mageArmor || (hero.item(GearSlot.CHEST)?.def?.armor ?: 0) > 0) -> Msg.noEffect
        skill == Skill.BLESS && blessed -> Msg.noEffect
        skill == Skill.SPIRITUAL_WEAPON && spiritualWeapon -> Msg.noEffect
        skill == Skill.SPIRIT_GUARDIANS && guardians -> Msg.noEffect
        skill == Skill.TURN_UNDEAD && !monster.undead -> Msg.notUndead
        else -> null
    }

    fun act(action: Action): List<Step> {
        check(outcome == Outcome.ONGOING) { "Battle is over" }
        val tookTurn = when (action) {
            Action.Attack -> { attackAction(advantage = 0); true }
            is Action.UseSkill -> useSkill(action.skill)
            is Action.UseItem -> useItem(action.item)
            Action.Flee -> flee()
        }
        if (tookTurn && outcome == Outcome.ONGOING) bonusEffects()
        if (tookTurn && outcome == Outcome.ONGOING) enemyTurn()
        return flush()
    }

    // ---------------------------------------------------------------- hero actions

    private fun attackAction(advantage: Int) {
        weaponAttack(advantage, hero.weapon, offHand = false)
        if (hero.has(Skill.EXTRA_ATTACK) && outcome == Outcome.ONGOING) weaponAttack(advantage, hero.weapon, offHand = false)
        hero.offHandWeapon?.let { if (outcome == Outcome.ONGOING) weaponAttack(advantage, it, offHand = true) }
    }

    private fun weaponAttack(advantage: Int, w: Gear?, offHand: Boolean) {
        say(Msg.attacksWith.f(lang, name, w?.name(lang) ?: Msg.fists(lang)), Anim.HERO_ACT)
        if (monster.special == MonsterSpecial.EVASIVE && w?.def?.ranged != true && dice.chance(0.2)) {
            say(Msg.flutters.f(lang, foe), Anim.MISS, fx = fx(FxKind.DODGE, onHero = false))
            return
        }
        var mode = advantage
        if (heroProne) {
            mode -= 1
            heroProne = false
        }
        val roll = heroD20(mode.coerceIn(-1, 1))
        val crit = roll >= hero.critFrom
        val total = roll + hero.attackBonus(w) + blessBonus()
        if (roll == 1 || (!crit && total < enemyAc)) {
            say(Msg.miss(lang), Anim.MISS, fx = fx(FxKind.DODGE, onHero = false))
            return
        }
        val base = hero.weaponDamage(w, offHand)
        var dmg = dice.roll(if (crit) base.copy(count = base.count * 2) else base)
        val sneakable = w == null || w.def.finesse || w.def.ranged
        if (hero.has(Skill.SNEAK_ATTACK) && sneakable && (!heroHasHit || mode > 0)) {
            val n = (hero.level + 1) / 2
            dmg += dice.roll(if (crit) n * 2 else n, 6)
            say(Msg.sneak(lang))
        }
        heroHasHit = true
        if (crit) say(Msg.crit(lang))
        val dealt = hitEnemy(maxOf(1, dmg), w?.def?.damageType ?: DamageType.BLUDGEONING, crit, fx(weaponFx(w), false, crit))
        if (hero.lifeSteal > 0 && dealt > 0 && hero.hp > 0 && hero.hp < hero.maxHp) {
            val heal = maxOf(1, dealt * hero.lifeSteal / 100)
            hero.hp = minOf(hero.maxHp, hero.hp + heal)
            say(Msg.lifesteal.f(lang, name, heal), Anim.HERO_HEAL, fx = fx(FxKind.HEAL, true))
        }
    }

    private fun spellAttack(dmg: DiceExpr, type: DamageType, kind: FxKind): Boolean {
        val roll = heroD20(0)
        val crit = roll == 20
        if (roll == 1 || (!crit && roll + hero.spellAttack + blessBonus() < enemyAc)) {
            say(Msg.miss(lang), Anim.MISS, fx = fx(FxKind.DODGE, onHero = false))
            return false
        }
        if (crit) say(Msg.crit(lang))
        hitEnemy(dice.roll(if (crit) dmg.copy(count = dmg.count * 2) else dmg), type, crit, fx(kind, false, crit))
        return true
    }

    private fun useSkill(skill: Skill): Boolean {
        blocked(skill)?.let {
            say(it(lang))
            return false
        }
        when (skill.cost) {
            SkillCost.PER_BATTLE -> usesLeft[skill] = usesLeft.getValue(skill) - 1
            SkillCost.SPELL_POINTS -> hero.sp -= skill.amount
            else -> {}
        }
        say(Msg.uses.f(lang, name, skill.title(lang)), Anim.SPELL)
        when (skill) {
            Skill.SECOND_WIND -> healHero(dice.roll(1, 10) + hero.level)
            Skill.ACTION_SURGE -> {
                attackAction(0)
                if (outcome == Outcome.ONGOING) attackAction(0)
            }
            Skill.FIRE_BOLT -> spellAttack(dice(cantripDice, 10), DamageType.FIRE, FxKind.FIRE_BOLT)
            Skill.MAGIC_MISSILE -> hitEnemy((1..3).sumOf { dice.roll(dice(1, 4, 1)) }, DamageType.FORCE, false, fx(FxKind.MISSILES, false))
            Skill.MAGE_ARMOR -> {
                mageArmor = true
                say(Msg.acNow.f(lang, name, heroAc), fx = fx(FxKind.MAGE_ARMOR, true))
            }
            Skill.SCORCHING_RAY -> repeat(3) { if (outcome == Outcome.ONGOING) spellAttack(dice(2, 6), DamageType.FIRE, FxKind.RAYS) }
            Skill.FIREBALL -> saveSpell(dice(8, 6), DamageType.FIRE, monster.dexSave, half = true, FxKind.FIREBALL)
            Skill.FEINT -> attackAction(advantage = 1)
            Skill.SACRED_FLAME -> saveSpell(dice(cantripDice, 8), DamageType.RADIANT, monster.dexSave, half = false, FxKind.SACRED_FLAME)
            Skill.CURE_WOUNDS -> healHero(dice.roll(1 + hero.level / 2, 8) + hero.mod(Ability.WIS))
            Skill.BLESS -> {
                blessed = true
                say(Msg.blessed.f(lang, name), fx = fx(FxKind.BLESS, true))
            }
            Skill.TURN_UNDEAD -> {
                if (dice.d20() + monster.wisSave >= hero.spellDc) {
                    say(Msg.resists.f(lang, foe))
                } else {
                    say(Msg.turned.f(lang, foe), Anim.ENEMY_FAINT, fx = fx(FxKind.TURN, false))
                    finishWin(fled = true)
                }
            }
            Skill.SPIRITUAL_WEAPON -> {
                spiritualWeapon = true
                say(Msg.weaponAppears(lang), fx = fx(FxKind.SPIRIT_WEAPON, false))
            }
            Skill.SPIRIT_GUARDIANS -> {
                guardians = true
                say(Msg.guardiansAppear(lang), fx = fx(FxKind.GUARDIANS, true))
            }
            else -> {}
        }
        return true
    }

    private fun saveSpell(dmg: DiceExpr, type: DamageType, saveMod: Int, half: Boolean, kind: FxKind) {
        val amount = dice.roll(dmg)
        if (dice.d20() + saveMod >= hero.spellDc) {
            if (half) {
                say(Msg.partlyDodges.f(lang, foe))
                hitEnemy(maxOf(1, amount / 2), type, false, fx(kind, false))
            } else {
                say(Msg.dodges.f(lang, foe), Anim.MISS, fx = fx(FxKind.DODGE, onHero = false))
            }
        } else {
            hitEnemy(amount, type, false, fx(kind, false))
        }
    }

    private fun useItem(id: String): Boolean {
        val def = Items[id]
        if (state.count(id) <= 0) return false
        when (def.kind) {
            ItemKind.POTION -> {
                if (hero.hp >= hero.maxHp) {
                    say(Ui.alreadyFull(lang))
                    return false
                }
                state.remove(id)
                say(Msg.drinks.f(lang, name, def.name(lang)))
                healHero(dice.roll(def.heal!!))
            }
            ItemKind.BOMB -> {
                state.remove(id)
                say(Msg.throws.f(lang, name, def.name(lang)))
                val d = def.damage!!
                val dmg = if (id == "holy_water" && monster.undead) d.copy(count = d.count * 2) else d
                hitEnemy(dice.roll(dmg), def.damageType, false, fx(if (id == "holy_water") FxKind.BOMB_HOLY else FxKind.BOMB_FIRE, false))
            }
            else -> {
                say(Ui.cannotUseHere(lang))
                return false
            }
        }
        return true
    }

    private fun flee(): Boolean {
        if (monster.boss) {
            say(Msg.noEscape(lang))
            return false
        }
        val elf = if (hero.race == Race.ELF) 2 else 0
        val ok = hero.has(Skill.CUNNING_ACTION) || dice.d20() + hero.mod(Ability.DEX) + elf >= 10 + monster.dexSave
        if (ok) {
            say(Msg.fled.f(lang, name))
            outcome = Outcome.FLED
        } else {
            say(Msg.cantFlee(lang))
        }
        return true
    }

    /** Ongoing effects that act after the hero's action. */
    private fun bonusEffects() {
        if (spiritualWeapon) {
            say(Msg.weaponStrikes(lang))
            val roll = dice.d20()
            if (roll != 1 && (roll == 20 || roll + hero.spellAttack >= enemyAc)) {
                hitEnemy(dice.roll(1, 8) + hero.mod(Ability.WIS), DamageType.FORCE, roll == 20, fx(FxKind.SPIRIT_WEAPON, false, roll == 20))
            } else {
                say(Msg.miss(lang), Anim.MISS)
            }
        }
        if (guardians && outcome == Outcome.ONGOING) {
            say(Msg.guardiansStrike(lang))
            saveSpell(dice(3, 8), DamageType.RADIANT, monster.wisSave, half = true, FxKind.GUARDIANS)
        }
    }

    // ---------------------------------------------------------------- enemy

    private fun enemyTurn() {
        if (outcome != Outcome.ONGOING) return
        enemyTurns++
        if (enemyPotions > 0 && enemyHp < enemyMaxHp / 2) {
            enemyPotions--
            val heal = dice.roll(dice(4, 4, 4))
            enemyHp = minOf(enemyMaxHp, enemyHp + heal)
            say(Msg.foeDrinks.f(lang, foe, heal), Anim.ENEMY_HEAL, fx = fx(FxKind.ENEMY_HEAL, false))
            return
        }
        if (monster.special == MonsterSpecial.SHAMAN) {
            if (shamanHeals > 0 && enemyHp < enemyMaxHp / 2) {
                shamanHeals--
                val heal = dice.roll(dice(2, 4, 2 + over))
                enemyHp = minOf(enemyMaxHp, enemyHp + heal)
                say(Msg.shamanHeals.f(lang, foe, heal), Anim.ENEMY_HEAL, fx = fx(FxKind.ENEMY_HEAL, false))
                return
            }
            if (enemyTurns % 2 == 1) {
                say(Msg.shamanBolt.f(lang, foe), Anim.ENEMY_ACT)
                val roll = dice.d20()
                if (roll == 1 || (roll != 20 && roll + enemyAttack + 1 < heroAc)) {
                    say(Msg.foeMisses.f(lang, foe), Anim.MISS, fx = fx(FxKind.DODGE, onHero = true))
                } else {
                    val d = dice(if (roll == 20) 4 else 2, 6, enemyDamageBonus)
                    hitHero(dice.roll(d), fx(FxKind.FIRE_BOLT, true, roll == 20))
                }
                return
            }
        }
        enemyAttack(allowParalyze = true)
    }

    private fun enemyAttack(allowParalyze: Boolean) {
        say(Msg.foeAttacks.f(lang, foe, monster.attackName(lang)), Anim.ENEMY_ACT)
        val roll = dice.d20(if (monster.special == MonsterSpecial.PACK_TACTICS) 1 else 0)
        val crit = roll == 20
        if (roll == 1 || (!crit && roll + enemyAttack < heroAc)) {
            val shield = hero.item(GearSlot.OFF_HAND)?.def?.kind == BaseKind.SHIELD
            say(Msg.foeMisses.f(lang, foe), Anim.MISS, fx = fx(if (shield && dice.chance(0.6)) FxKind.BLOCK else FxKind.DODGE, onHero = true))
            return
        }
        val d = monster.damage.let { it.copy(bonus = it.bonus + enemyDamageBonus) }
        var dmg = dice.roll(if (crit) d.copy(count = d.count * 2) else d)
        if (crit) say(Msg.crit(lang))
        when (monster.special) {
            MonsterSpecial.SURPRISE_ATTACK -> if (!enemyHasHit) {
                dmg += dice.roll(2, 6)
                say(Msg.brutal(lang))
            }
            MonsterSpecial.CHARGE -> if (!enemyHasHit) {
                dmg += dice.roll(1, 6)
                say(Msg.charge.f(lang, foe))
            }
            MonsterSpecial.MARTIAL_ADVANTAGE -> if (enemyTurns % 3 == 1) {
                dmg += dice.roll(2, 6)
                say(Msg.martial.f(lang, foe))
            }
            else -> {}
        }
        enemyHasHit = true
        if (hero.has(Skill.UNCANNY_DODGE) && !dodgeUsed) {
            dodgeUsed = true
            dmg = maxOf(1, dmg / 2)
            say(Msg.uncanny.f(lang, name))
        }
        val dealt = hitHero(dmg, fx(monster.attackFx, true, crit))
        if (outcome != Outcome.ONGOING) return

        when (monster.special) {
            MonsterSpecial.POISON -> {
                var poison = dice.roll(monster.poison)
                if (heroSave(Ability.CON, 11)) {
                    poison /= 2
                    say(Msg.resistPoison.f(lang, name))
                }
                if (hero.race == Race.DWARF) poison /= 2
                if (poison > 0) {
                    say(Msg.poisoned.f(lang, name, poison))
                    hitHero(poison, fx(FxKind.POISON, true))
                }
            }
            MonsterSpecial.KNOCKDOWN -> if (!heroSave(Ability.STR, 11)) {
                heroProne = true
                say(Msg.prone.f(lang, name))
            }
            MonsterSpecial.BLOOD_DRAIN -> {
                val drain = dice.roll(1, 4)
                say(Msg.drain.f(lang, foe))
                val taken = hitHero(drain, fx(FxKind.DRAIN, true))
                enemyHp = minOf(enemyMaxHp, enemyHp + taken)
            }
            MonsterSpecial.ACID -> {
                say(Msg.acid(lang))
                hitHero(dice.roll(1, 4), fx(FxKind.ACID, true))
                if (outcome == Outcome.ONGOING && acid < 2) {
                    acid++
                    say(Msg.corrode.f(lang, name, heroAc))
                }
            }
            MonsterSpecial.PARALYZE -> if (allowParalyze && hero.race != Race.ELF && !heroSave(Ability.CON, 10)) {
                say(Msg.paralyzed.f(lang, name), fx = fx(FxKind.PARALYZE, true))
                enemyAttack(allowParalyze = false)
                return
            }
            else -> {}
        }
        if (outcome != Outcome.ONGOING) return
        when (trait) {
            EliteTrait.VENOMOUS -> {
                var poison = dice.roll(1, traitDie)
                if (hero.race == Race.DWARF) poison = (poison + 1) / 2
                say(Msg.poisoned.f(lang, name, poison))
                hitHero(poison, fx(FxKind.POISON, true))
            }
            EliteTrait.BURNING -> {
                val burn = dice.roll(1, traitDie)
                say(Msg.burns.f(lang, name, burn))
                hitHero(burn, fx(FxKind.BURN, true))
            }
            EliteTrait.VAMPIRIC -> if (enemyHp < enemyMaxHp) {
                val heal = maxOf(1, dealt / 2)
                enemyHp = minOf(enemyMaxHp, enemyHp + heal)
                say(Msg.lifesteal.f(lang, foe, heal), Anim.ENEMY_HEAL, fx = fx(FxKind.DRAIN, false))
            }
            else -> {}
        }
    }

    // ---------------------------------------------------------------- helpers

    private fun heroD20(mode: Int): Int {
        var roll = dice.d20(mode)
        if (roll == 1 && hero.race == Race.HALFLING) {
            say(Msg.lucky(lang))
            roll = dice.d20()
        }
        return roll
    }

    private fun blessBonus(): Int = if (blessed) dice.d(4) else 0

    private fun heroSave(a: Ability, dc: Int): Boolean {
        val prof = if (a in savingThrows.getValue(hero.cls)) hero.proficiency else 0
        return dice.d20() + hero.mod(a) + prof >= dc
    }

    private fun hitEnemy(raw: Int, type: DamageType, crit: Boolean, effect: Fx? = null): Int {
        var dmg = raw
        var note: T? = null
        when (type) {
            in monster.immune -> {
                dmg = 0
                note = Msg.immune
            }
            in monster.resistant -> {
                dmg /= 2
                note = Msg.notEffective
            }
            in monster.vulnerable -> {
                dmg *= 2
                note = Msg.superEffective
            }
            else -> {}
        }
        if (monster.undead && type == DamageType.RADIANT && note == null) {
            dmg += dmg / 2
            note = Msg.superEffective
        }
        enemyHp = maxOf(0, enemyHp - dmg)
        if (enemyHp == 0 && monster.special == MonsterSpecial.CHARGE && !foeRelentlessUsed && dmg <= 7 + over) {
            foeRelentlessUsed = true
            enemyHp = 1
            say(Msg.damageTo.f(lang, foe, dmg), Anim.ENEMY_HIT, fx = effect)
            say(Msg.relentless.f(lang, foe))
            return dmg
        }
        if (enemyHp == 0 && monster.special == MonsterSpecial.UNDEAD_FORTITUDE && !crit &&
            type != DamageType.RADIANT && dice.d20() + monster.conSave >= 5 + dmg
        ) {
            enemyHp = 1
            say(Msg.damageTo.f(lang, foe, dmg), Anim.ENEMY_HIT, fx = effect)
            say(Msg.fortitude.f(lang, foe))
            return dmg
        }
        say(Msg.damageTo.f(lang, foe, dmg), Anim.ENEMY_HIT, fx = effect)
        note?.let { say(it(lang)) }
        if (enemyHp == 0) {
            say(Msg.defeated.f(lang, foe), Anim.ENEMY_FAINT)
            finishWin(fled = false)
        }
        return dmg
    }

    /** Returns the damage actually taken. */
    private fun hitHero(raw: Int, effect: Fx? = null): Int {
        val dmg = maxOf(1, raw - hero.damageReduction)
        hero.hp = maxOf(0, hero.hp - dmg)
        if (hero.hp == 0 && hero.race == Race.HALF_ORC && !relentlessUsed) {
            relentlessUsed = true
            hero.hp = 1
            say(Msg.damageTo.f(lang, name, dmg), Anim.HERO_HIT, fx = effect)
            say(Msg.relentless.f(lang, name))
            return dmg
        }
        say(Msg.damageTo.f(lang, name, dmg), Anim.HERO_HIT, fx = effect)
        if (hero.hp == 0) {
            say(Msg.heroFalls.f(lang, name), Anim.HERO_FAINT)
            outcome = Outcome.LOST
        }
        return dmg
    }

    private fun healHero(amount: Int) {
        val before = hero.hp
        hero.hp = minOf(hero.maxHp, hero.hp + amount)
        say(Msg.heals.f(lang, name, hero.hp - before), Anim.HERO_HEAL, fx = fx(FxKind.HEAL, true))
    }

    private fun finishWin(fled: Boolean) {
        outcome = if (fled) Outcome.ENEMY_FLED else Outcome.WON
        // Higher monster levels are worth a lot more experience.
        val scale = 1 + 0.35 * over + 0.05 * over * over
        val xp = (monster.xp * scale * (if (elite) 2.5 else 1.0) * (if (shiny) 2.0 else 1.0) * (1 + hero.bonus(Affix.XP) / 100.0)).toInt()
        val gold = if (fled) 0 else (dice.roll(monster.gold) * (1 + over * 0.3) * (if (elite) 2.0 else 1.0) * (if (shiny) 3.0 else 1.0) *
            (1 + hero.bonus(Affix.GOLD_FIND) / 100.0)).toInt()
        val fixed = if (fled) emptyList() else monster.loot.filter { dice.chance(it.chance) }.map { it.item }
        val items = fixed.filter { Items.exists(it) }
        val gear = if (fled) mutableListOf() else fixed.filter { Uniques.exists(it) }.map { Uniques.make(it, 0, level) }.toMutableList()
        if (!fled) gear += Loot.drops(state, dice, level, monster.boss, elite)
        if (!fled && shiny) gear += Loot.generate(state, dice, level, Loot.rollRarity(dice, level, hero.bonus(Affix.MAGIC_FIND), Rarity.RARE), hero.cls)
        state.gold += gold
        items.forEach { state.add(it) }
        val owned = gear.map { state.addGear(it) }
        state.battlesWon++
        val oldLevel = hero.level
        val gained = hero.gainXp(xp)
        rewards = Rewards(xp, gold, items, owned, gained)

        say(Msg.gainXp.f(lang, name, xp))
        if (gold > 0) say(Msg.gainGold.f(lang, gold), Anim.COINS)
        items.forEach { say(Msg.loot.f(lang, Items[it].name(lang)), Anim.LOOT) }
        owned.sortedByDescending { it.rarity }.forEach {
            say(Msg.gearLoot.f(lang, it.name(lang), it.rarity.title(lang)), Anim.LOOT, it.rarity)
        }
        for (lvl in oldLevel + 1..hero.level) {
            say(Msg.levelUp.f(lang, name, lvl), Anim.LEVEL_UP)
            hero.cls.skills().filter { it.level == lvl }.forEach { say(Msg.newSkill.f(lang, it.title(lang))) }
        }
        if (gained > 0) {
            say(Msg.restored.f(lang, name), Anim.HERO_HEAL)
            say(Msg.points.f(lang, gained))
        }
    }

    private fun say(text: String, anim: Anim = Anim.NONE, rarity: Rarity? = null, fx: Fx? = null) {
        steps += Step(text, hero.hp, enemyHp, hero.sp, anim, rarity, fx)
    }

    private fun flush(): List<Step> = steps.toList().also { steps.clear() }

    companion object {
        val savingThrows = mapOf(
            CharClass.FIGHTER to setOf(Ability.STR, Ability.CON),
            CharClass.WIZARD to setOf(Ability.INT, Ability.WIS),
            CharClass.ROGUE to setOf(Ability.DEX, Ability.INT),
            CharClass.CLERIC to setOf(Ability.WIS, Ability.CHA),
        )
    }
}

private object Msg {
    val appears = T("Achtung! {0} taucht auf!", "A wild {0} appears!")
    val bossAppears = T("{0} stellt sich dir in den Weg!", "{0} blocks your way!")
    val foeFaster = T("{0} ist schneller!", "{0} is faster!")
    val attacksWith = T("{0} greift mit {1} an!", "{0} attacks with {1}!")
    val fists = T("bloßen Fäusten", "bare fists")
    val miss = T("Daneben!", "It missed!")
    val crit = T("Ein kritischer Treffer!", "A critical hit!")
    val sneak = T("Hinterhältiger Angriff!", "Sneak Attack!")
    val uses = T("{0} setzt {1} ein!", "{0} uses {1}!")
    val acNow = T("Die RK von {0} beträgt jetzt {1}.", "{0}'s AC is now {1}.")
    val blessed = T("{0} fühlt sich gesegnet.", "{0} feels blessed.")
    val resists = T("{0} widersteht!", "{0} resists!")
    val turned = T("{0} flieht in panischer Angst!", "{0} flees in terror!")
    val weaponAppears = T("Eine leuchtende Waffe erscheint!", "A glowing weapon appears!")
    val weaponStrikes = T("Die spirituelle Waffe schlägt zu!", "The spiritual weapon strikes!")
    val guardiansAppear = T("Schützende Geister umkreisen dich!", "Protective spirits circle you!")
    val guardiansStrike = T("Die Geisterwächter greifen an!", "The spirit guardians attack!")
    val partlyDodges = T("{0} weicht teilweise aus!", "{0} partly dodges!")
    val dodges = T("{0} weicht aus!", "{0} dodges!")
    val drinks = T("{0} trinkt {1}.", "{0} drinks {1}.")
    val throws = T("{0} wirft {1}!", "{0} throws {1}!")
    val noEscape = T("Vor diesem Gegner gibt es kein Entkommen!", "There is no escape from this foe!")
    val fled = T("{0} ist entkommen!", "{0} got away safely!")
    val cantFlee = T("Die Flucht misslingt!", "Couldn't get away!")
    val foeDrinks = T("{0} trinkt einen Heiltrank und heilt {1} TP!", "{0} drinks a potion and heals {1} HP!")
    val foeAttacks = T("{0} greift an: {1}!", "{0} attacks: {1}!")
    val foeMisses = T("{0} verfehlt!", "{0} misses!")
    val brutal = T("Ein brutaler Überraschungsschlag!", "A brutal surprise blow!")
    val martial = T("{0} nutzt eine Lücke in deiner Deckung!", "{0} exploits a gap in your guard!")
    val uncanny = T("{0} weicht geschickt aus und halbiert den Schaden!", "{0} deftly dodges and halves the damage!")
    val resistPoison = T("{0} widersteht dem Gift teilweise.", "{0} partly resists the poison.")
    val poisoned = T("Das Gift brennt! {0} erleidet {1} Giftschaden.", "The poison burns! {0} takes {1} poison damage.")
    val prone = T("{0} wird umgeworfen! Der nächste Angriff ist erschwert.", "{0} is knocked prone! The next attack has disadvantage.")
    val lucky = T("Glück gehabt! Neuer Wurf!", "Lucky! Reroll!")
    val immune = T("Es hat keine Wirkung …", "It has no effect...")
    val notEffective = T("Das ist nicht sehr effektiv …", "It's not very effective...")
    val superEffective = T("Das ist sehr effektiv!", "It's super effective!")
    val damageTo = T("{0} erleidet {1} Schaden.", "{0} takes {1} damage.")
    val fortitude = T("{0} weigert sich zu fallen!", "{0} refuses to fall!")
    val defeated = T("{0} wurde besiegt!", "{0} was defeated!")
    val relentless = T("{0} bleibt mit eisernem Willen stehen!", "{0} stays standing through sheer will!")
    val heroFalls = T("{0} bricht zusammen …", "{0} collapses...")
    val heals = T("{0} heilt {1} TP.", "{0} recovers {1} HP.")
    val gainXp = T("{0} erhält {1} EP.", "{0} gained {1} XP.")
    val gainGold = T("Du erbeutest {0} Gold.", "You got {0} gold.")
    val loot = T("Beute: {0}!", "Loot: {0}!")
    val gearLoot = T("Beute: {0} ({1})!", "Loot: {0} ({1})!")
    val elite = T("Elite-{0}", "Elite {0}")
    val eliteTrait = T("Ein Elite-Gegner! {0}", "An elite foe! {0}")
    val shiny = T("Er schimmert in seltsamen Farben … eine seltene Erscheinung!", "It shimmers in strange colors... a rare sight!")
    val pack = T("Im Gebüsch rascheln weitere Kobolde – sie greifen im Rudel an!", "More kobolds rustle in the brush – they fight as a pack!")
    val flutters = T("{0} flattert davon – daneben!", "{0} flutters away – a miss!")
    val shamanHeals = T("{0} murmelt einen Heilzauber und heilt {1} TP!", "{0} mutters a healing spell and recovers {1} HP!")
    val shamanBolt = T("{0} schleudert einen Feuerpfeil!", "{0} hurls a fire bolt!")
    val charge = T("{0} stürmt heran!", "{0} charges!")
    val drain = T("{0} saugt Blut!", "{0} drinks blood!")
    val acid = T("Ätzende Säure spritzt!", "Corrosive acid splashes!")
    val corrode = T("Die Säure zerfrisst die Rüstung! RK von {0}: {1}.", "The acid eats into the armor! {0}'s AC: {1}.")
    val paralyzed = T("{0} ist vor Kälte gelähmt!", "{0} is paralyzed with cold!")
    val burns = T("Glühende Hitze! {0} erleidet {1} Feuerschaden.", "Searing heat! {0} takes {1} fire damage.")
    val lifesteal = T("{0} saugt {1} TP ab.", "{0} drains {1} HP.")
    val levelUp = T("{0} erreicht Stufe {1}!", "{0} grew to level {1}!")
    val newSkill = T("Neue Fähigkeit: {0}!", "New ability: {0}!")
    val restored = T("TP und ZP von {0} sind vollständig aufgefüllt!", "{0}'s HP and SP are fully restored!")
    val points = T("+{0} Attributspunkt(e) – verteile sie im Menü.", "+{0} ability point(s) – spend them in the menu.")
    val cannot = T("Das geht nicht.", "You can't do that.")
    val noUses = T("Diese Fähigkeit ist in diesem Kampf erschöpft.", "That ability is spent for this battle.")
    val noSp = T("Nicht genug Zauberpunkte!", "Not enough spell points!")
    val noEffect = T("Das hätte keine Wirkung.", "That would have no effect.")
    val notUndead = T("Das wirkt nur gegen Untote.", "That only works against undead.")
}
