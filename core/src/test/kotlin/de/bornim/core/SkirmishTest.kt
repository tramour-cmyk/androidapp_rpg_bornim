package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/** MARS (72.10, 72.10a): rows, place swap, ring, autopilot, knockouts (72.11, 72.13, 72v, 72r). */
class SkirmishTest {
    /** 241.2: plays the automatic party turns that are up, as the screen does after each hand-back. */
    private fun Skirmish.settle(): List<SkirmishEvent> {
        val ev = mutableListOf<SkirmishEvent>()
        while (pilotNext) ev += proceed()
        return ev
    }

    /** 241.2 (Rückläufer t46): an automatic turn waits until everything before it was shown, so a switch counts at once. */
    @Test
    fun anAutomaticTurnHandsBackFirstSoASwitchCountsAtOnce() {
        for (seed in 0 until 30) {
            val sk = probe(seed)
            val merc = sk.byId("merc")
            merc.auto = true
            sk.start(); sk.settle()
            if (sk.outcome != Outcome.ONGOING) continue
            sk.act(Order.Wait)
            if (sk.outcome != Outcome.ONGOING || sk.current !== merc) continue
            // the screen still plays the hero's lines: the player switches the Söldner to manual
            merc.auto = false
            assertFalse(sk.pilotNext)
            assertEquals("merc", sk.current.id)
            return
        }
        error("no seed had the Söldner next")
    }

    /**
     * 320 (Rückläufer t81.7 „der holt also eigentlich nicht aus“): between Grak's "Schwerer Hieb!" and his blow only the
     * ring's verdict may come, without a roll, a spell or a word on him alone: the screen keeps his axe up behind the head
     * until the blow and lowers it at any of those (`SkirmishScreen`, wind-up).
     */
    @Test
    fun heavyBlowFollowsItsCallWithNothingThatLowersTheAxe() {
        var blows = 0
        for (ring in listOf(Reaction.NONE, Reaction.GOOD)) for (seed in 1..8) {
            val sk = probe(seed, CharClass.ROGUE, CharClass.FIGHTER)
            val grak = sk.fighters.first { it.monster?.id in de.bornim.core.art.FoeArt.WIND_HOLDERS }.id
            var heavy = false
            var called = false
            sk.listener = { e ->
                if (called) {
                    if (e.actor == grak && e.roll != null) { called = false; blows++ }
                    else assertTrue(e.roll == null && e.spell == null && e.actor != null, "seed $seed, $ring: '${e.text}' between call and blow")
                }
                if (heavy && e.actor == grak && e.roll == null && e.intents[grak] == null) called = true
                heavy = e.intents[grak]?.first?.id == Intents.heavy.id
            }
            play(sk, ring)
        }
        assertTrue(blows > 0, "no heavy blow played")
    }

    private fun probe(seed: Int, cls: CharClass = CharClass.FIGHTER, merc: CharClass = CharClass.ROGUE): Skirmish {
        val s = GameState.newGame("T", Race.HUMAN, cls)
        return Skirmish.grakProbe(s, merc, Lang.DE, Dice(Random(seed)))
    }

    /** Plays the probe to its end with plain attacks on Grak and the given ring result. */
    private fun play(sk: Skirmish, ring: Reaction): Outcome {
        sk.start { _, _ -> ring }
        var guard = 0
        while (sk.outcome == Outcome.ONGOING && guard++ < 500) {
            val t = sk.targets(sk.current).firstOrNull()
            sk.act(if (t != null) Order.Attack(t.id) else Order.Wait) { _, _ -> ring }
        }
        return sk.outcome
    }

    /** 249: blows and bites draw blood on the screen, spells do not. */
    @Test
    fun blowsWoundSpellsDoNot() {
        var blows = 0
        for (seed in 0 until 20) {
            val sk = probe(seed, merc = CharClass.FIGHTER)
            val seen = mutableListOf<SkirmishEvent>()
            sk.listener = { seen += it }
            play(sk, Reaction.NONE)
            for (e in seen.filter { it.damage > 0 }) {
                if (e.actor == "grak" || e.actor == "merc") { assertTrue(e.wound, e.text); blows++ }
            }
        }
        assertTrue(blows > 0)
    }

    @Test
    fun meleeReachesOnlyTheFrontRowWhileSomeoneStandsThere() {
        val sk = probe(1, merc = CharClass.FIGHTER)
        val grak = sk.byId("grak")
        sk.byId("merc").place = Spot(Row.BACK, 0)
        assertEquals(listOf("hero"), sk.targets(grak).map { it.id })
        sk.byId("hero").hp = 0
        assertEquals(listOf("merc"), sk.targets(grak).map { it.id })
    }

    @Test
    fun aSwapTradesPlaces() {
        for (seed in 0 until 50) {
            val sk = probe(seed, merc = CharClass.FIGHTER)
            sk.start()
            if (sk.outcome != Outcome.ONGOING) continue
            val f = sk.current
            val other = sk.fighters.first { it.side == Side.PARTY && it !== f }
            val mine = f.place
            val theirs = other.place
            sk.act(Order.Swap(theirs))
            assertEquals(theirs, f.place)
            assertEquals(mine, other.place)
            return
        }
        error("no probe got to a party turn")
    }

    /** The first probe of the seeds that reaches a turn of the hero. */
    private fun heroTurn(merc: CharClass = CharClass.FIGHTER): Skirmish {
        for (seed in 0 until 50) {
            val sk = probe(seed, merc = merc)
            sk.start()
            if (sk.outcome == Outcome.ONGOING && sk.current.id == "hero") return sk
        }
        error("no probe got to the hero's turn")
    }

    @Test
    fun everyFigureCarriesASecondWeaponOfTheOtherKind() {
        val sk = probe(1, merc = CharClass.WIZARD)
        val hero = sk.byId("hero")
        assertEquals(false, hero.weapon!!.def.ranged)
        assertEquals("light_crossbow", hero.second!!.base)
        assertEquals("light_crossbow", sk.byId("merc").second!!.base)
        // a bow in the bag goes before the plain one
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        s.bag += Gear(s.nextUid(), "longbow", Rarity.COMMON, 1, plus = 1)
        assertEquals("longbow", Skirmish.secondWeapon(s.hero, s.bag)!!.base)
        // a bow in hand: the second is for melee, and the class must know it
        val r = Hero.create("R", Race.HUMAN, CharClass.WIZARD)
        r.equip(Gear(-9, "light_crossbow", Rarity.COMMON, 1))
        assertEquals("dagger", Skirmish.secondWeapon(r, emptyList())!!.base)
    }

    @Test
    fun drawingIsHalfATurnAndTheBlowFollowsWithTheOtherWeapon() {
        val sk = heroTurn()
        val hero = sk.current
        assertEquals(hero.hero, hero.looks)
        sk.act(Order.Draw)
        assertEquals(hero, sk.current)
        assertTrue(hero.ranged)
        // drawn with the other weapon in hand, the hero's own gear unchanged (34.7)
        assertEquals(hero.second!!.base, hero.looks!!.weapon!!.base)
        assertFalse(hero.hero!!.weapon!!.def.ranged)
        assertFalse(sk.canDraw(hero))
        assertFalse(sk.canSwap(hero))
        val log = sk.act(Order.Attack(sk.targets(hero).first().id))
        assertTrue(log.any { it.actor == "hero" && it.roll != null })
        assertTrue(hero.ranged, "the weapon stays drawn")
    }

    @Test
    fun aSwapCanTakeUpTheOtherWeaponOnTheWay() {
        val sk = heroTurn()
        val hero = sk.current
        sk.act(Order.Swap(Spot(Row.BACK, 1), draw = true))
        assertEquals(Row.BACK, hero.place.row)
        assertTrue(hero.ranged)
        assertEquals(hero, sk.current)
        assertFalse(sk.canDraw(hero))
    }

    @Test
    fun aSoeldnerOnAutomaticShovedForwardWithABowTakesUpHisBlade() {
        for (seed in 0 until 100) {
            val sk = probe(seed, merc = CharClass.ROGUE)
            val merc = sk.byId("merc")
            merc.drawn = true
            assertTrue(merc.ranged)
            merc.auto = true
            sk.start(); sk.settle()
            var guard = 0
            while (sk.outcome == Outcome.ONGOING && merc.ranged && guard++ < 20) {
                val t = sk.targets(sk.current).firstOrNull()
                sk.act(if (t != null) Order.Attack(t.id) else Order.Wait); sk.settle()
            }
            if (!merc.standing) continue
            assertFalse(merc.ranged, "seed $seed")
            return
        }
        error("no probe let the Söldner act")
    }

    @Test
    fun theRingCutsTheDamage() {
        fun lost(ring: Reaction) = (0 until 300).count { play(probe(it), ring) == Outcome.LOST }
        val none = lost(Reaction.NONE)
        val good = lost(Reaction.GOOD)
        val perfect = lost(Reaction.PERFECT)
        assertTrue(none > good, "no reaction $none, good $good")
        assertTrue(good >= perfect, "good $good, perfect $perfect")
    }

    @Test
    fun aDownedSoeldnerIsCountedNotKilled() {
        var seen = false
        for (seed in 0 until 300) {
            val sk = probe(seed, merc = CharClass.FIGHTER)
            play(sk, Reaction.NONE)
            if (sk.knockouts > 0) {
                seen = true
                assertEquals(0, sk.byId("merc").hp)
            }
        }
        assertTrue(seen)
    }

    @Test
    fun autopilotNeverStartsAgainstABoss() {
        val sk = probe(3)
        assertNotNull(sk.autopilotBlocked())
        assertFalse(sk.setAutopilot(true))
    }

    @Test
    fun autopilotStopsOnAStrongIntentOrLowLife() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val goblin = Monsters["goblin"]
        for (seed in 0 until 100) {
            val sk = Skirmish(
                listOf(
                    Fighter("hero", Side.PARTY, Spot(Row.FRONT, 0), hero = s.hero, hp = s.hero.maxHp),
                    Fighter("merc", Side.PARTY, Spot(Row.FRONT, 1), hero = Hero.create("M", Race.HUMAN, CharClass.FIGHTER), hp = 12),
                ),
                listOf(Fighter("gob", Side.FOES, Spot(Row.FRONT, 0), monster = goblin, hp = 40)),
                Lang.DE, Dice(Random(seed)),
            )
            sk.start()
            if (sk.outcome != Outcome.ONGOING || !sk.setAutopilot(true)) continue
            sk.act(Order.Wait)
            // 241: it hands back after each of its turns; played on, it stops only when one of its stop rules holds
            // 241.1: the Söldner the player steers waits for its order
            while (sk.outcome == Outcome.ONGOING && sk.autopilot) if (sk.pilotNext) sk.proceed() else { assertEquals("merc", sk.current.id); sk.act(Order.Wait) }
            if (sk.outcome != Outcome.ONGOING) continue
            assertFalse(sk.autopilot)
            assertNotNull(sk.autopilotBlocked())
        }
    }

    @Test
    fun autopilotJudgesTheLifePointsShown() {
        // 241.2 (Chef 17:56): the bar showed near half, the fight was already below a third; the tap counts what is shown,
        // the true life points stop it again before the hero's own turn
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val max = s.hero.maxHp
        val sk = Skirmish(
            listOf(Fighter("hero", Side.PARTY, Spot(Row.FRONT, 0), hero = s.hero, hp = max)),
            listOf(Fighter("gob", Side.FOES, Spot(Row.FRONT, 0), monster = Monsters["goblin"], hp = 40)),
            Lang.DE, Dice(Random(1)),
        )
        sk.start()
        sk.fighters.first { it.id == "hero" }.hp = max / 3 - 1
        assertNotNull(sk.autopilotBlocked())
        assertNull(sk.autopilotBlocked(max / 2))
        assertTrue(sk.setAutopilot(true, max / 2))
        if (sk.outcome == Outcome.ONGOING) {
            sk.act(Order.Wait)
            if (sk.outcome == Outcome.ONGOING) { assertFalse(sk.autopilot); assertFalse(sk.pilotNext) }
        }
    }

    @Test
    fun autopilotLeavesASoeldnerThePlayerSteers() {
        // 241.1 (Chef 13:50): Automatik on, Söldner „selbst“: the game plays the hero, the Söldner waits for the player
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        var seen = 0
        for (seed in 0 until 40) {
            val sk = Skirmish(
                listOf(
                    Fighter("hero", Side.PARTY, Spot(Row.FRONT, 0), hero = s.hero, hp = s.hero.maxHp),
                    Fighter("merc", Side.PARTY, Spot(Row.FRONT, 1), hero = Hero.create("M", Race.HUMAN, CharClass.FIGHTER), hp = 12),
                ),
                listOf(Fighter("gob", Side.FOES, Spot(Row.FRONT, 0), monster = Monsters["goblin"], hp = 40)),
                Lang.DE, Dice(Random(seed)),
            )
            sk.start()
            if (sk.outcome != Outcome.ONGOING || !sk.setAutopilot(true)) continue
            var guard = 0
            while (sk.outcome == Outcome.ONGOING && sk.autopilot && guard++ < 60) {
                if (sk.pilotNext) { assertEquals("hero", sk.current.id); sk.proceed() }
                else { assertEquals("merc", sk.current.id); seen++; sk.act(Order.Wait) }
            }
        }
        assertTrue(seen > 0)
    }

    @Test
    fun blowsOnAFigureInAbwehrComeWithDisadvantage() {
        // 203: Abwehr is the SRD Dodge; until its next turn every attack roll on the figure has disadvantage
        var seen = 0
        for (seed in 0 until 40) {
            val sk = probe(seed, merc = CharClass.FIGHTER)
            sk.start()
            var guard = 0
            var dodging = false
            while (sk.outcome == Outcome.ONGOING && guard++ < 60) {
                val f = sk.current
                if (f.id == "hero") dodging = true
                val ev = if (f.id == "hero") sk.act(Order.Wait)
                    else sk.act(sk.targets(f).firstOrNull()?.let { Order.Attack(it.id) } ?: Order.Wait)
                if (dodging) for (e in ev) if (e.target == "hero" && e.actor != "hero" && e.actor != "merc" && e.roll?.kind == RollKind.ATTACK) {
                    assertEquals(-1, e.roll!!.mode, "seed $seed: a blow on the hero in Abwehr")
                    seen++
                }
            }
        }
        assertTrue(seen > 5, "blows on the hero seen: $seen")
    }

    @Test
    fun windedHeroRollsInitiativeWithDisadvantage() {
        fun mean(winded: Boolean) = (0 until 400).map { seed ->
            val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER).also { it.winded = winded }
            Skirmish.grakProbe(s, CharClass.ROGUE, Lang.DE, Dice(Random(seed))).byId("hero").initiative
        }.average()
        assertTrue(mean(true) < mean(false) - 2)
    }

    @Test
    fun grakAnnouncesOnlyHisThreeIntents() {
        val seen = mutableSetOf<String>()
        for (seed in 0 until 200) {
            val sk = probe(seed)
            sk.start { _, _ -> Reaction.GOOD }
            var guard = 0
            while (sk.outcome == Outcome.ONGOING && guard++ < 200) {
                sk.intents["grak"]?.let { seen += it.first.id }
                val t = sk.targets(sk.current).firstOrNull()
                sk.act(if (t != null) Order.Attack(t.id) else Order.Wait) { _, _ -> Reaction.GOOD }
            }
        }
        assertEquals(setOf("heavy", "call", "gather"), seen)
    }

    @Test
    fun calledGoblinsJoinTheFoesAndTheFightStillEnds() {
        var joined = false
        for (seed in 0 until 200) {
            val sk = probe(seed)
            val out = play(sk, Reaction.GOOD)
            assertTrue(out != Outcome.ONGOING, "seed $seed did not end")
            val gobs = sk.fighters.filter { it.monster?.id == Skirmish.CALLED }
            assertTrue(gobs.size <= Skirmish.CALL_MAX)
            assertEquals(sk.fighters.size, sk.fighters.map { it.side to it.place }.toSet().size, "one figure per place")
            if (gobs.isNotEmpty()) joined = true
        }
        assertTrue(joined)
    }

    @Test
    fun aHardHitBreaksAnAnnouncedHeavyBlow() {
        var broke = false
        for (seed in 0 until 300) {
            val sk = probe(seed)
            sk.start()
            var guard = 0
            while (sk.outcome == Outcome.ONGOING && guard++ < 200 && !broke) {
                val before = sk.intents["grak"]?.first
                val t = sk.targets(sk.current).firstOrNull()
                val ev = sk.act(if (t != null) Order.Attack(t.id) else Order.Wait)
                if (before?.breakable == true && ev.any { it.text.contains("vereitelt") }) broke = true
            }
        }
        assertTrue(broke)
    }

    @Test
    fun aSoeldnerOnAutoPlaysItselfEvenAgainstABoss() {
        for (seed in 0 until 50) {
            val sk = probe(seed)
            sk.byId("merc").auto = true
            sk.start(); sk.settle()
            if (sk.outcome != Outcome.ONGOING) continue
            assertEquals("hero", sk.current.id)
            sk.act(Order.Wait); sk.settle()
            if (sk.outcome == Outcome.ONGOING) assertEquals("hero", sk.current.id)
        }
    }

    // ---- 72.10a: abilities, spells, potions, names, level 3

    /** A party of two of [cls] (hero first) against [foes] goblins in the given places, seeded. */
    private fun duel(seed: Int, cls: CharClass, foes: List<Spot> = listOf(Spot(Row.FRONT, 0)), foeHp: Int = 40): Skirmish {
        val s = GameState.newGame("T", Race.HUMAN, cls)
        val hero = s.hero.also { it.level = 3; it.restoreFully() }
        val merc = Hero.create("M", Race.HUMAN, CharClass.FIGHTER).also { it.level = 3; it.restoreFully() }
        return Skirmish(
            listOf(
                Fighter("hero", Side.PARTY, Spot(Row.FRONT, 0), hero = hero, hp = hero.maxHp),
                Fighter("merc", Side.PARTY, Spot(Row.FRONT, 1), hero = merc, hp = merc.maxHp),
            ),
            foes.mapIndexed { i, sp -> Fighter("gob$i", Side.FOES, sp, monster = Monsters["goblin"], hp = foeHp) },
            Lang.DE, Dice(Random(seed)),
        )
    }

    /** Starts [sk] and runs it to the hero's turn, or null if the fight ended first. */
    private fun toHero(sk: Skirmish): Fighter? {
        sk.start()
        var guard = 0
        while (sk.outcome == Outcome.ONGOING && guard++ < 20) {
            if (sk.current.id == "hero") return sk.current
            sk.act(Order.Wait)
        }
        return null
    }

    @Test
    fun theMoveListFollowsTheClassAndLevel() {
        val wiz = duel(1, CharClass.WIZARD)
        val names = wiz.moves(wiz.byId("hero")).toSet()
        assertEquals(setOf(Skill.FIRE_BOLT, Skill.MAGIC_MISSILE, Skill.BURNING_HANDS, Skill.SCORCHING_RAY), names)
        // 207: Burning Hands is MARS only, the old fight and the menus do not list it
        assertFalse(Skill.BURNING_HANDS in CharClass.WIZARD.skills())
        val fig = duel(1, CharClass.FIGHTER)
        assertEquals(setOf(Skill.SECOND_WIND, Skill.ACTION_SURGE), fig.moves(fig.byId("hero")).toSet())
        val clr = duel(1, CharClass.CLERIC)
        assertEquals(setOf(Skill.SACRED_FLAME, Skill.CURE_WOUNDS, Skill.BLESS), clr.moves(clr.byId("hero")).toSet())
    }

    @Test
    fun spellsCostSpellPointsAndTheyRunOut() {
        for (seed in 0 until 40) {
            val sk = duel(seed, CharClass.WIZARD, foeHp = 500)
            val hero = toHero(sk) ?: continue
            val before = hero.sp
            assertTrue(before >= Skill.SCORCHING_RAY.amount)
            sk.act(Order.Use(Skill.SCORCHING_RAY, "gob0"))
            assertEquals(before - Skill.SCORCHING_RAY.amount, hero.sp)
            hero.sp = 1
            assertNotNull(sk.blocked(hero, Skill.MAGIC_MISSILE))
            assertEquals(null, sk.blocked(hero, Skill.FIRE_BOLT), "a cantrip is free")
            return
        }
        error("no seed reached the hero's turn")
    }

    @Test
    fun aRowSpellHitsTheWholeRowAndNothingBehindIt() {
        val wiz = GameState.newGame("T", Race.HUMAN, CharClass.WIZARD).hero.also { it.level = 5; it.restoreFully() }
        for (seed in 0 until 60) {
            val merc = Hero.create("M", Race.HUMAN, CharClass.FIGHTER)
            val sk = Skirmish(
                listOf(Fighter("hero", Side.PARTY, Spot(Row.BACK, 0), hero = wiz, hp = wiz.maxHp), Fighter("merc", Side.PARTY, Spot(Row.FRONT, 0), hero = merc, hp = merc.maxHp)),
                listOf(
                    Fighter("a", Side.FOES, Spot(Row.FRONT, 0), monster = Monsters["goblin"], hp = 500),
                    Fighter("b", Side.FOES, Spot(Row.FRONT, 1), monster = Monsters["goblin"], hp = 500),
                    Fighter("c", Side.FOES, Spot(Row.BACK, 0), monster = Monsters["goblin"], hp = 500),
                ),
                Lang.DE, Dice(Random(seed)),
            )
            val hero = toHero(sk) ?: continue
            hero.sp = 20
            sk.act(Order.Use(Skill.FIREBALL, "a"))
            assertTrue(sk.byId("a").hp < 500 && sk.byId("b").hp < 500, "both front goblins burn")
            assertEquals(500, sk.byId("c").hp, "the back row is spared")
            return
        }
        error("no seed reached the hero's turn")
    }

    @Test
    fun spellsReachTheBackRowButWeaponsDoNot() {
        val sk = duel(1, CharClass.WIZARD, foes = listOf(Spot(Row.FRONT, 0), Spot(Row.BACK, 0)))
        val hero = sk.byId("hero")
        assertEquals(setOf("gob0", "gob1"), sk.aimAt(hero, Skill.FIRE_BOLT).map { it.id }.toSet())
        val fig = duel(1, CharClass.FIGHTER, foes = listOf(Spot(Row.FRONT, 0), Spot(Row.BACK, 0)))
        assertEquals(setOf("gob0"), fig.aimAt(fig.byId("hero"), Skill.FEINT).map { it.id }.toSet())
    }

    /** 249: each message of a spell carries it, for its effect on the screen; it draws no blood. */
    @Test
    fun spellMessagesCarryTheirEffect() {
        for (seed in 0 until 40) {
            val sk = duel(seed, CharClass.CLERIC, foeHp = 500)
            toHero(sk) ?: continue
            val seen = mutableListOf<SkirmishEvent>()
            sk.listener = { seen += it }
            sk.act(Order.Use(Skill.SACRED_FLAME, "gob0"))
            val at = seen.filter { it.target == "gob0" && it.actor == "hero" }
            assertTrue(at.isNotEmpty())
            assertTrue(at.all { it.spell == FxKind.SACRED_FLAME && !it.wound })
            assertTrue(seen.filter { it.actor != "hero" }.all { it.spell == null })
            return
        }
        error("no seed reached the hero's turn")
    }

    @Test
    fun healingNeverRaisesAboveTheMaximumAndPotionsRunOut() {
        for (seed in 0 until 40) {
            val sk = duel(seed, CharClass.CLERIC, foeHp = 500)
            val hero = toHero(sk) ?: continue
            val merc = sk.byId("merc")
            merc.hp = 1
            sk.act(Order.Use(Skill.CURE_WOUNDS, "merc"))
            assertTrue(merc.hp > 1 && merc.hp <= merc.maxHp)
            sk.potions["potion"] = 1
            if (sk.outcome != Outcome.ONGOING) return
            var guard = 0
            while (sk.current.id != "hero" && guard++ < 10) sk.act(Order.Wait)
            hero.hp = hero.maxHp - 3
            sk.act(Order.Drink("potion", "hero"))
            assertTrue(hero.hp <= hero.maxHp)
            assertEquals(0, sk.potions["potion"])
            assertTrue(sk.drinkable().isEmpty())
            return
        }
        error("no seed reached the hero's turn")
    }

    @Test
    fun everyRollShowsItsNumbers() {
        val sk = duel(7, CharClass.FIGHTER, foeHp = 500)
        val events = sk.start().toMutableList()
        var guard = 0
        while (sk.outcome == Outcome.ONGOING && guard++ < 30) events += sk.act(Order.Attack("gob0"))
        val rolled = events.filter { it.roll != null }
        assertTrue(rolled.size >= 10)
        for (e in rolled) {
            val r = e.roll!!
            assertEquals(r.kind, RollKind.ATTACK)
            assertTrue(r.d20 in 1..20)
            if (r.d20 in 2..19) assertEquals(r.d20 + r.bonus >= r.versus, r.success)
        }
    }

    @Test
    fun theLineOfTurnsStartsWithTheOneActing() {
        val sk = duel(3, CharClass.FIGHTER)
        val ev = sk.start()
        val queue = sk.queue()
        assertEquals(sk.current.id, queue.first())
        assertEquals(sk.fighters.size, queue.size)
        assertTrue(ev.all { it.queue.isNotEmpty() })
    }

    @Test
    fun theProbeIsOnLevelThreeWithNamedSoeldnerAndLeavesTheRealHeroAlone() {
        val s = GameState.newGame("Bertram", Race.HUMAN, CharClass.WIZARD)
        assertEquals(1, s.hero.level)
        val sk = Skirmish.grakProbe(s, CharClass.CLERIC, Lang.DE, Dice(Random(1)))
        assertEquals(3, sk.byId("hero").hero!!.level)
        assertEquals(3, sk.byId("merc").hero!!.level)
        assertEquals(1, s.hero.level, "the real hero is a copy")
        assertEquals("Hagen", sk.byId("merc").name(Lang.DE), "never the hero's own name")
        assertEquals("Hagen (Kleriker)", sk.byId("merc").display(Lang.DE))
        assertTrue(sk.byId("merc").sp > 0 && sk.byId("hero").sp > 0)
        assertEquals(Skirmish.PROBE_POTIONS, sk.potions["potion"])
    }

    @Test
    fun aSoeldnerWizardOnAutoCastsCantripsAndAClericHealsAFriend() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        val wiz = Skirmish.grakProbe(s, CharClass.WIZARD, Lang.DE, Dice(Random(2)))
        wiz.byId("merc").auto = true
        val ev = (wiz.start() + wiz.settle()).toMutableList()
        var guard = 0
        while (wiz.outcome == Outcome.ONGOING && guard++ < 30) { ev += wiz.act(Order.Wait); ev += wiz.settle() }
        assertTrue(ev.any { it.text.contains("Feuerpfeil") }, "the wizard casts Fire Bolt on its own")
    }

    @Test
    fun allClassesStillFinishTheProbeOnAutopilotlessPlay() {
        for (cls in CharClass.entries) for (seed in 0 until 40) {
            val sk = probe(seed, cls = cls, merc = cls)
            assertTrue(play(sk, Reaction.GOOD) != Outcome.ONGOING)
        }
    }

    @Test
    fun aBackRowFigureIsCoveredAndPointBlankShotsAreHarder() {
        // hero (wizard) in front, Söldner behind him: a bolt at the covered Söldner rolls with disadvantage
        val sk = duel(3, CharClass.WIZARD)
        sk.byId("merc").place = Spot(Row.BACK, 0)
        val foe = sk.byId("gob0")
        foe.place = Spot(Row.FRONT, 0)
        var covered = 0
        var open = 0
        sk.listener = { e -> e.roll?.let { if (e.target == "merc") { if (it.mode < 0) covered++ } else if (it.mode != 0) open++ } }
        sk.start()
        // the hero strikes rather than waits: a waiting figure is struck at a disadvantage (203), which is not cover
        repeat(6) { if (sk.outcome == Outcome.ONGOING && sk.current.side == Side.PARTY) sk.act(if (sk.current.id == "hero") Order.Attack("gob0") else Order.Wait) }
        assertEquals(0, open, "the front figure is not covered")
        // a front figure's death uncovers the back one
        sk.byId("hero").hp = 0
        val before = covered
        // (attacking, not Abwehr: that brings its own disadvantage, 203)
        repeat(4) { if (sk.outcome == Outcome.ONGOING && sk.current.side == Side.PARTY) sk.act(sk.targets(sk.current).firstOrNull()?.let { Order.Attack(it.id) } ?: Order.Wait) }
        assertEquals(before, covered, "no cover without a friend in front")
    }

    @Test
    fun theSecondCallBringsAScoutToTheBackRow() {
        var seen = false
        for (seed in 0 until 300) {
            val sk = probe(seed)
            play(sk, Reaction.GOOD)
            val scout = sk.fighters.firstOrNull { it.monster?.id == Skirmish.SCOUT } ?: continue
            seen = true
            assertTrue(scout.ranged)
            assertEquals(sk.fighters.size, sk.fighters.map { it.side to it.place }.toSet().size, "one figure per place")
        }
        assertTrue(seen)
    }

    // ---- 130.3: foes with intents that ask for different answers

    private fun foeProbe(seed: Int, foe: Skirmish.Companion.ProbeFoe, merc: CharClass = CharClass.FIGHTER): Skirmish {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        return Skirmish.probe(s, merc, Lang.DE, foe, Dice(Random(seed)))
    }

    /** Every fight ends and the lineups are legal, whatever the foes announce. */
    @Test
    fun everyProbeFoeEnds() {
        for (foe in Skirmish.Companion.ProbeFoe.entries) for (seed in 0 until 60) {
            val sk = foeProbe(seed, foe)
            assertTrue(play(sk, Reaction.GOOD) != Outcome.ONGOING, "$foe seed $seed")
        }
    }

    @Test
    fun wolvesAnnounceBothIntentsAcrossFights() {
        val seen = mutableSetOf<String>()
        for (seed in 0 until 80) {
            val sk = foeProbe(seed, Skirmish.Companion.ProbeFoe.WOLVES)
            sk.listener = { e -> e.intents.values.forEach { seen += it.first.id } }
            play(sk, Reaction.GOOD)
        }
        assertTrue("pounce" in seen && "circle" in seen, "$seen")
    }

    @Test
    fun noFriendFallsAndNoCircleStandsBeforeThePlayerChose() {
        // 231: Bertram fell before Alrik had a turn; until the first choice a hit leaves at least 1 hit point, and no wolf circles
        for (seed in 0 until 2000) {
            val sk = foeProbe(seed, Skirmish.Companion.ProbeFoe.WOLVES)
            var circled = false
            sk.listener = { e -> if (!sk.chosen && e.intents.values.any { it.first.id == "circle" }) circled = true }
            sk.start { _, _ -> Reaction.NONE }
            assertFalse(circled, "seed $seed: a circle at the opening")
            assertTrue(sk.fighters.filter { it.side == Side.PARTY }.all { it.hp > 0 }, "seed $seed: a friend down before the first choice")
        }
    }

    /** Rückläufer t53 („reißt zu Boden wäre gut, wenn Held dann stürzt“): a pounce throws down, the lost turn gets up. */
    /** 279: a wolf's bite in four wordings at random, never the same one twice running. */
    @Test
    fun wolfBitesVaryAndNeverRepeatTheLastWording() {
        val wordings = listOf(" beißt ", "schnappt zu und erwischt", "schlägt die Zähne in", " reißt an ")
        val seen = mutableSetOf<Int>()
        for (seed in 0 until 40) {
            val sk = foeProbe(seed, Skirmish.Companion.ProbeFoe.WOLVES)
            var last = -1
            sk.listener = { e ->
                val w = wordings.indexOfFirst { e.text.contains(it) && e.text.contains("Schaden") }
                if (w >= 0) { assertTrue(w != last, "seed $seed: the same bite twice running: ${e.text}"); last = w; seen += w }
            }
            play(sk, Reaction.GOOD)
        }
        assertEquals(4, seen.size, "all four wordings come up")
    }

    @Test
    fun aPounceThrowsDownAndTheLostTurnGetsUp() {
        var pounced = 0
        for (seed in 0 until 200) {
            val sk = foeProbe(seed, Skirmish.Companion.ProbeFoe.WOLVES)
            val lying = mutableSetOf<String>()
            // 279: three wordings of „zu Boden“
            val down = Regex("geht zu Boden|sinkt nieder|in die Knie")
            sk.listener = { e ->
                when (e.cue) {
                    SkirmishCue.POUNCED -> {
                        assertTrue(down.containsMatchIn(e.text), e.text)
                        assertTrue(sk.byId(e.target!!).prone, "seed $seed: thrown down")
                        lying += e.target!!; pounced++
                    }
                    SkirmishCue.RISES -> assertTrue(lying.remove(e.actor!!), "seed $seed: gets up only after a pounce")
                    else -> if (e.cue == null && down.containsMatchIn(e.text)) error("seed $seed: a pounce without its cue: ${e.text}")
                }
            }
            play(sk, Reaction.NONE)
        }
        assertTrue(pounced > 0, "some pounce lands")
    }

    /** Rückläufer t58 („wenn der Späher aus dem Schatten kommt, sieht man keinen Pfeil“): a ducked arrow is named, so it flies past. */
    @Test
    fun aDuckedArrowCarriesItsCue() {
        var ducked = 0
        for (seed in 0 until 20) {
            val sk = foeProbe(seed, Skirmish.Companion.ProbeFoe.SCOUT)
            sk.listener = { e ->
                if (e.text.contains("duckt sich, der Pfeil")) {
                    assertEquals(SkirmishCue.DUCKED, e.cue, e.text)
                    assertEquals(Side.FOES, sk.byId(e.actor!!).side); assertEquals(Side.PARTY, sk.byId(e.target!!).side)
                    ducked++
                }
            }
            sk.start { _, _ -> Reaction.NONE }
            var guard = 0
            while (sk.outcome == Outcome.ONGOING && guard++ < 60) { sk.act(Order.Wait) { _, _ -> Reaction.NONE }; while (sk.pilotNext) sk.proceed() }
        }
        assertTrue(ducked > 0, "some arrow is ducked")
    }

    /** 285 (Chef 21.10.): a wolf leaping from the back row lands in front, the one leapt over steps back into its place. */
    @Test
    fun aLeapFromTheBackSwapsTheRows() {
        var swapped = 0
        for (seed in 0 until 100) {
            val sk = foeProbe(seed, Skirmish.Companion.ProbeFoe.WOLVES)
            var last = sk.fighters.associate { it.id to it.place }
            sk.listener = { e ->
                for (w in sk.fighters.filter { it.side == Side.FOES }) {
                    val was = last[w.id] ?: continue; val now = e.places.getValue(w.id)
                    if (was.row == Row.BACK && now.row == Row.FRONT) {
                        assertEquals(w.id, e.actor, "seed $seed: only the leaper comes forward")
                        assertEquals(RollKind.ATTACK, e.roll?.kind, "seed $seed: on its leap")
                        val back = sk.fighters.filter { it.side == Side.FOES && it.id != w.id && last[it.id] == now }
                        assertTrue(back.all { e.places[it.id] == was }, "seed $seed: the one leapt over takes its place")
                        swapped++
                    }
                }
                val standing = sk.fighters.filter { it.side == Side.FOES && (e.hp[it.id] ?: 0) > 0 }.map { e.places.getValue(it.id) }
                assertEquals(standing.size, standing.toSet().size, "seed $seed: two on one place")
                last = e.places
            }
            play(sk, Reaction.NONE)
        }
        assertTrue(swapped > 0, "some wolf leaps from the back")
    }

    @Test
    fun aPounceMissesWhoChangedPlaces() {
        var emptied = 0
        var floored = 0
        for (seed in 0 until 200) {
            val sk = foeProbe(seed, Skirmish.Companion.ProbeFoe.WOLVES)
            sk.listener = { e ->
                if (e.text.contains("ins Leere")) emptied++
                if (e.text.contains("zu Boden")) floored++
            }
            sk.start()
            var guard = 0
            while (sk.outcome == Outcome.ONGOING && guard++ < 60) {
                val me = sk.current
                val swapTo = if (me.place.row == Row.FRONT) Spot(Row.BACK, 0) else Spot(Row.FRONT, 0)
                sk.act(Order.Swap(swapTo))
                if (sk.outcome == Outcome.ONGOING && sk.current === me) sk.act(Order.Wait)
            }
        }
        assertTrue(emptied > 0, "a swap dodges the pounce")
        assertTrue(floored >= 0)
    }

    @Test
    fun aHeldFigureLosesItsNextTurn() {
        var lost = 0
        for (seed in 0 until 200) {
            val sk = foeProbe(seed, Skirmish.Companion.ProbeFoe.WOLVES)
            sk.listener = { e -> if (Regex("verliert den Zug|Zug aussetzen|Zug (ist )?verloren").containsMatchIn(e.text)) lost++ }
            play(sk, Reaction.GOOD)
        }
        assertTrue(lost > 0)
    }

    @Test
    fun theScoutInTheShadowsIsStruckAtADisadvantageAndNeverHidesTwice() {
        // 208: in the shadows the scout can still be attacked, with disadvantage; it never goes into them twice running
        var hiddenSeen = 0
        for (seed in 0 until 200) {
            val sk = foeProbe(seed, Skirmish.Companion.ProbeFoe.SCOUT)
            sk.start()
            var guard = 0
            while (sk.outcome == Outcome.ONGOING && guard++ < 200) {
                val scout = sk.byId("scout")
                if (scout.hidden && scout.standing) {
                    assertTrue(sk.intents["scout"]?.first?.effect != Effect.SHADOW, "seed $seed: shadows twice running")
                    if (sk.current.side == Side.PARTY && sk.targets(sk.current).any { it.id == "scout" }) {
                        hiddenSeen++
                        val ev = sk.act(Order.Attack("scout"))
                        ev.firstOrNull { it.target == "scout" && it.roll?.kind == RollKind.ATTACK }?.let { assertEquals(-1, it.roll!!.mode, "seed $seed") }
                        continue
                    }
                }
                val t = sk.targets(sk.current).firstOrNull()
                sk.act(if (t != null) Order.Attack(t.id) else Order.Wait)
            }
        }
        assertTrue(hiddenSeen > 0)
    }

    @Test
    fun theSpiderHoldsWhoMissesTheRing() {
        var held = 0
        for (seed in 0 until 200) {
            val sk = foeProbe(seed, Skirmish.Companion.ProbeFoe.SPIDER)
            sk.listener = { e -> if (e.text.contains("hängt im Netz fest")) held++ }
            play(sk, Reaction.NONE)
        }
        assertTrue(held > 0)
        var perfectHeld = 0
        for (seed in 0 until 200) {
            val sk = foeProbe(seed, Skirmish.Companion.ProbeFoe.SPIDER)
            sk.listener = { e -> if (e.text.contains("hängt im Netz fest")) perfectHeld++ }
            play(sk, Reaction.PERFECT)
        }
        assertEquals(0, perfectHeld, "a perfect ring frees from the web")
    }

    /** 72.10a.8: a swap is half a turn; the same figure acts once more, but cannot swap again. */
    @Test
    fun aSwapIsHalfATurn() {
        for (seed in 0 until 50) {
            val sk = probe(seed, merc = CharClass.FIGHTER)
            sk.start()
            if (sk.outcome != Outcome.ONGOING) continue
            val f = sk.current
            val to = Spot.ALL.first { it.row != f.place.row }
            sk.act(Order.Swap(to))
            assertTrue(sk.current === f, "still its turn")
            assertFalse(sk.canSwap(f))
            assertTrue(runCatching { sk.act(Order.Swap(Spot.ALL.first { it.row != f.place.row })) }.isFailure, "no second swap")
            sk.act(Order.Wait)
            assertTrue(sk.current !== f || sk.outcome != Outcome.ONGOING, "the wait ends the turn")
            assertTrue(sk.canSwap(f), "a new turn, a new swap")
            return
        }
        error("no probe got to a party turn")
    }

    /** Plays waits until Grak has acted once on the given intent. */
    private fun waitForGrak(sk: Skirmish, react: (Fighter, Intent) -> Reaction = { _, _ -> Reaction.GOOD }) {
        var done = false
        val before = sk.listener
        sk.listener = { e -> before?.invoke(e); if (e.actor == "grak" && "Durchbrechen!" in e.text) done = true }
        var guard = 0
        while (sk.outcome == Outcome.ONGOING && !done && guard++ < 10) sk.act(Order.Wait, react)
        // the rest of Grak's turn is said in the same act
        sk.listener = before
    }

    @Test
    fun grakBreaksThroughToTheBackRow() {
        var shoved = 0
        for (seed in 0 until 40) {
            val sk = probe(seed, merc = CharClass.WIZARD)
            sk.start()
            if (sk.outcome != Outcome.ONGOING || sk.byId("merc").place.row != Row.BACK) continue
            sk.intents["grak"] = Intents.breakthrough to listOf("merc")
            var ringFor: String? = null
            var text = ""
            sk.listener = { e -> text += e.text + "\n" }
            waitForGrak(sk) { t, _ -> ringFor = t.id; Reaction.NONE }
            if ("bricht durch" !in text) continue
            assertEquals(Row.FRONT, sk.byId("merc").place.row, "the target is pulled to the front")
            assertEquals(Row.BACK, sk.byId("hero").place.row, "the front figure is shoved back")
            assertEquals("merc", ringFor, "the target meets the ring")
            shoved++
        }
        assertTrue(shoved > 10, "$shoved")
    }

    @Test
    fun steppingForwardBluntsTheBreakthrough() {
        var braced = 0
        for (seed in 0 until 60) {
            val sk = probe(seed, merc = CharClass.WIZARD)
            sk.start()
            if (sk.outcome != Outcome.ONGOING || sk.current.id != "merc" || sk.byId("merc").place.row != Row.BACK) continue
            sk.intents["grak"] = Intents.breakthrough to listOf("merc")
            var text = ""
            sk.listener = { e -> text += e.text + "\n" }
            sk.act(Order.Swap(Spot(Row.FRONT, 1)))
            var ring = false
            waitForGrak(sk) { _, _ -> ring = true; Reaction.NONE }
            if ("Durchbrechen!" !in text) continue
            assertTrue("Kein Durchkommen" in text, text)
            assertFalse(ring, "an ordinary blow, no ring")
            assertEquals(Row.FRONT, sk.byId("hero").place.row, "nobody is shoved")
            braced++
        }
        assertTrue(braced > 0, "$braced")
    }

    @Test
    fun grakAndGoblinsAnnounceTheLineupIntentsOnlyAgainstACoveredBackRow() {
        val seen = mutableSetOf<String>()
        for (seed in 0 until 150) {
            val sk = probe(seed, merc = CharClass.WIZARD)
            sk.listener = { e -> e.intents.forEach { (foe, plan) ->
                if (plan.first.id == "breakthrough" || plan.first.id == "flank") {
                    seen += plan.first.id
                    val t = sk.byId(plan.second.single())
                    assertEquals(Side.PARTY, t.side, foe)
                }
            } }
            play(sk, Reaction.GOOD)
        }
        assertTrue("breakthrough" in seen && "flank" in seen, "$seen")
        for (seed in 0 until 60) {
            val sk = probe(seed, merc = CharClass.FIGHTER)
            sk.listener = { e -> assertTrue(e.intents.values.none { it.first.id == "breakthrough" }, "nobody behind: no breakthrough") }
            play(sk, Reaction.GOOD)
        }
    }

    @Test
    fun aFlankHitsTheBackRowWithoutCoverUnlessTheTargetMoved() {
        var flanked = 0
        var missed = 0
        for (seed in 0 until 300) {
            val sk = foeProbe(seed, Skirmish.Companion.ProbeFoe.SCOUT, merc = CharClass.WIZARD)
            var plan: Pair<Intent, List<String>>? = null
            sk.listener = { e ->
                val p = plan
                if (e.actor == "gob1" && e.roll != null && p?.first?.id == "flank" && e.target == p.second.single() && sk.byId(e.target!!).place.row == Row.BACK) {
                    assertTrue(e.roll!!.mode >= 0, "no cover against a flank")
                    flanked++
                }
                if ("doch" in e.text && "nicht mehr dort" in e.text) missed++
                plan = e.intents["gob1"] ?: plan
            }
            sk.start()
            var guard = 0
            while (sk.outcome == Outcome.ONGOING && guard++ < 200) {
                val me = sk.current
                val flank = sk.intents["gob1"]?.takeIf { it.first.id == "flank" }
                if (flank != null && me.id in flank.second && sk.canSwap(me) && seed % 2 == 0) {
                    sk.act(Order.Swap(Spot(Row.FRONT, 1)))
                    continue
                }
                val t = sk.targets(me).firstOrNull()
                sk.act(if (t != null) Order.Attack(t.id) else Order.Wait)
            }
        }
        assertTrue(flanked > 0, "flank hits")
        assertTrue(missed > 0, "a moved target makes it miss")
    }

    /** Runs [sk] (started) with waits to the turn of [id], or null if the fight ended first. */
    private fun turnOf(sk: Skirmish, id: String): Fighter? {
        var guard = 0
        while (sk.outcome == Outcome.ONGOING && guard++ < 20) {
            if (sk.current.id == id) return sk.current
            sk.act(Order.Wait)
        }
        return null
    }

    @Test
    fun theFighterCoversAndTakesTheBlowsMeantForOthers() {
        var covered = 0
        for (seed in 0 until 40) {
            val sk = probe(seed, cls = CharClass.FIGHTER, merc = CharClass.WIZARD)
            sk.start()
            val hero = turnOf(sk, "hero") ?: continue
            assertTrue(sk.guardable(sk.byId("merc")).isEmpty(), "only the fighter covers")
            // a breakthrough may have shoved him back already
            if (hero.place.row != Row.FRONT) continue
            sk.intents["grak"] = Intents.heavy to listOf("merc")
            assertTrue("grak" in sk.guardable(hero))
            val ringFor = mutableListOf<String>()
            var text = ""
            sk.listener = { e -> text += e.text + "\n" }
            sk.act(Order.Guard) { t, _ -> ringFor += t.id; Reaction.NONE }
            assertTrue("zieht jeden Schlag auf sich" in text, text)
            if ("Schwerer Hieb!" !in text) continue
            assertEquals(listOf("hero"), ringFor, text)
            covered++
        }
        assertTrue(covered > 5, "$covered")
    }

    @Test
    fun aBreakthroughDrawnOntoTheFighterComesWithTheRing() {
        var covered = 0
        for (seed in 0 until 40) {
            val sk = probe(seed, cls = CharClass.FIGHTER, merc = CharClass.WIZARD)
            sk.start()
            val hero = turnOf(sk, "hero") ?: continue
            if (hero.place.row != Row.FRONT || sk.byId("merc").place.row != Row.BACK) continue
            sk.intents["grak"] = Intents.breakthrough to listOf("merc")
            val ringFor = mutableListOf<String>()
            var text = ""
            sk.listener = { e -> text += e.text + "\n" }
            sk.act(Order.Guard) { t, _ -> ringFor += t.id; Reaction.NONE }
            if ("Durchbrechen!" !in text) continue
            assertEquals(listOf("hero"), ringFor, text)
            assertEquals(Row.BACK, sk.byId("merc").place.row, text)
            covered++
        }
        assertTrue(covered > 3, "$covered")
    }

    @Test
    fun aFighterInTheBackRowCannotCover() {
        val sk = probe(3, cls = CharClass.FIGHTER, merc = CharClass.FIGHTER)
        sk.start()
        val hero = turnOf(sk, "hero") ?: return
        sk.act(Order.Swap(Spot(Row.BACK, 0)))
        sk.intents["grak"] = Intents.heavy to listOf("merc")
        assertTrue(sk.guardable(hero).isEmpty())
    }

    /** Lets Grak strike the hero with a heavy blow met perfectly; the text of everything said. */
    private fun perfectOnHero(seed: Int, cls: CharClass): Pair<Skirmish, String>? {
        val sk = probe(seed, cls = cls, merc = CharClass.FIGHTER)
        sk.start()
        turnOf(sk, "hero") ?: return null
        sk.intents["grak"] = Intents.heavy to listOf("hero")
        var text = ""
        sk.listener = { e -> text += e.text + "\n" }
        var met = false
        var guard = 0
        while (sk.outcome == Outcome.ONGOING && !met && guard++ < 6)
            sk.act(Order.Wait) { t, _ -> if (t.id == "hero") { met = true; Reaction.PERFECT } else Reaction.GOOD }
        sk.listener = null
        return if (met) sk to text else null
    }

    /** 219.4: a perfect ring counts every time, also when Grak's roll would have missed, and says the dodge in one line. */
    @Test
    fun aPerfectRingCountsEveryTimeInOneLine() {
        for (cls in listOf(CharClass.FIGHTER, CharClass.ROGUE, CharClass.CLERIC, CharClass.WIZARD)) {
            val met = (0 until 40).mapNotNull { perfectOnHero(it, cls) }
            assertTrue(met.size > 10, "$cls ${met.size}")
            for ((_, text) in met) {
                val lines = text.lines()
                assertEquals(1, lines.count { "weicht" in it }, text)
                assertTrue(lines.none { it.startsWith("Hauptmann Grak verfehlt") || "fängt den Schlag" in it }, text)
            }
        }
    }

    @Test
    fun aPerfectRingAnswersByClass() {
        val fighter = (0 until 60).mapNotNull { perfectOnHero(it, CharClass.FIGHTER) }
        assertTrue(fighter.size > 5 && fighter.all { "schlägt zurück" in it.second }, "${fighter.size}")
        val cleric = (0 until 60).mapNotNull { perfectOnHero(it, CharClass.CLERIC) }
        assertTrue(cleric.size > 5 && cleric.all { "Gebet" in it.second }, "${cleric.size}")
        val wizard = (0 until 60).mapNotNull { perfectOnHero(it, CharClass.WIZARD) }
        assertTrue(wizard.size > 5 && wizard.none { "schlägt zurück" in it.second || "Gebet" in it.second || "Rücken" in it.second })
        val rogue = (0 until 60).mapNotNull { perfectOnHero(it, CharClass.ROGUE) }
        assertTrue(rogue.size > 5, "${rogue.size}")
        for ((_, text) in rogue) {
            assertTrue("in den Rücken" in text, text)
            // 336: the stab follows at once, in the log, with its hit or miss
            val after = text.substringAfter("in den Rücken").lines().drop(1).firstOrNull().orEmpty()
            assertTrue(Regex("\\bT\\b").containsMatchIn(after) && "Grak" in after && "kündigt" !in after, text)
        }
        val rolls = (0 until 60).mapNotNull { seed ->
            val sk = probe(seed, cls = CharClass.ROGUE, merc = CharClass.FIGHTER)
            sk.start()
            turnOf(sk, "hero") ?: return@mapNotNull null
            sk.intents["grak"] = Intents.heavy to listOf("hero")
            var stab: RollInfo? = null
            var dodged = false
            sk.listener = { e -> if (e.answer) dodged = true else if (dodged && stab == null && e.actor == "hero") stab = e.roll }
            var guard = 0
            while (sk.outcome == Outcome.ONGOING && !dodged && guard++ < 6)
                sk.act(Order.Wait) { t, _ -> if (t.id == "hero") Reaction.PERFECT else Reaction.GOOD }
            stab
        }
        assertTrue(rolls.size > 5 && rolls.all { it.mode == 1 && !it.fromBack }, "the stab in the back with advantage, without cover: $rolls")
    }

    @Test
    fun aFeintFromTheBackRowReachesTheBackRowOfTheFoes() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.ROGUE)
        val rogue = s.hero.also { it.level = 3; it.restoreFully() }
        val mate = Hero.create("M", Race.HUMAN, CharClass.FIGHTER).also { it.level = 3; it.restoreFully() }
        val sk = Skirmish(
            listOf(
                Fighter("hero", Side.PARTY, Spot(Row.BACK, 0), hero = rogue, hp = rogue.maxHp),
                Fighter("merc", Side.PARTY, Spot(Row.FRONT, 0), hero = mate, hp = mate.maxHp),
            ),
            listOf(
                Fighter("gob", Side.FOES, Spot(Row.FRONT, 0), monster = Monsters["goblin"], hp = 30),
                Fighter("scout", Side.FOES, Spot(Row.BACK, 0), monster = Monsters["goblin_archer"], hp = 30),
            ),
            Lang.DE, Dice(Random(1)),
        )
        val hero = sk.byId("hero")
        assertEquals(setOf("gob", "scout"), sk.aimAt(hero, Skill.FEINT).map { it.id }.toSet(), "from behind a friend")
        assertEquals(listOf("gob"), sk.targets(hero).map { it.id }, "a plain blow still only reaches the front")
        sk.start()
        val h = turnOf(sk, "hero") ?: return
        sk.act(Order.Swap(Spot(Row.FRONT, 1)))
        assertEquals(listOf("gob"), sk.aimAt(h, Skill.FEINT).map { it.id }, "from the front row like any blow")
    }

    @Test
    fun aMeleeBlowFromTheBackRowHasDisadvantageUnlessTheWeaponHasReach() {
        // 223: hero (fighter, longsword) behind the Söldner; his blows on the goblin roll with disadvantage, marked
        fun rolls(weapon: String?): List<RollInfo> {
            val sk = duel(5, CharClass.FIGHTER, foeHp = 400)
            val h = sk.byId("hero")
            weapon?.let { h.hero!!.gear[GearSlot.MAIN_HAND] = Gear(1, it, Rarity.COMMON, 1) }
            h.place = Spot(Row.BACK, 0)
            val got = mutableListOf<RollInfo>()
            sk.listener = { e -> if (e.actor == "hero") e.roll?.let { got += it } }
            sk.start()
            var guard = 0
            while (got.size < 6 && sk.outcome == Outcome.ONGOING && guard++ < 200) {
                val f = sk.current
                sk.act(sk.targets(f).firstOrNull()?.let { Order.Attack(it.id) } ?: Order.Wait)
            }
            return got
        }
        val sword = rolls(null)
        assertTrue(sword.isNotEmpty() && sword.all { it.mode < 0 && it.fromBack }, "melee from the back row: disadvantage")
        val spear = rolls("spear")
        assertTrue(spear.isNotEmpty() && spear.none { it.mode < 0 || it.fromBack }, "a spear reaches past the friend")
        val bow = rolls("shortbow")
        assertTrue(bow.isNotEmpty() && bow.none { it.mode < 0 || it.fromBack }, "a bow from the back row as before")
    }

    /** 268 (Chef 20.10., Build 49: "Wechsel auf Armbrust, ist aber Zweihänder"): drawing a two-handed weapon puts the torch away. */
    @Test
    fun aTwoHandedSecondWeaponPutsTheTorchAway() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        s.hero.gear[GearSlot.MAIN_HAND] = Gear(1, "longsword", Rarity.COMMON, 1)
        s.hero.gear[GearSlot.OFF_HAND] = Loot.torch(2)
        for ((second, kept) in listOf("light_crossbow" to false, "dagger" to true)) {
            val f = Fighter("hero", Side.PARTY, Spot(Row.FRONT, 0), hero = s.hero, hp = s.hero.maxHp, second = Gear(3, second, Rarity.COMMON, 1))
            assertEquals("torch", f.looks!!.item(GearSlot.OFF_HAND)?.base, "before the draw the torch is in hand")
            f.drawn = true
            assertEquals(second, f.looks!!.weapon?.base)
            assertEquals(kept, f.looks!!.item(GearSlot.OFF_HAND) != null, "$second: the torch ${if (kept) "stays" else "is put away"}")
            assertEquals("torch", s.hero.item(GearSlot.OFF_HAND)?.base, "the hero's own gear stays as it is")
        }
    }

    /** 268 (offen für Jerry): with a two-handed weapon drawn the shield is put away, and its armor no longer counts. */
    @Test
    fun aTwoHandedSecondWeaponTakesTheShieldOffTheArmorClass() {
        val s = GameState.newGame("T", Race.HUMAN, CharClass.FIGHTER)
        s.hero.gear[GearSlot.MAIN_HAND] = Gear(1, "longsword", Rarity.COMMON, 1)
        s.hero.gear[GearSlot.OFF_HAND] = Gear(2, "shield", Rarity.COMMON, 1)
        val withShield = s.hero.armorClass
        for ((second, kept) in listOf("light_crossbow" to false, "dagger" to true)) {
            val f = Fighter("hero", Side.PARTY, Spot(Row.FRONT, 0), hero = s.hero, hp = s.hero.maxHp, second = Gear(3, second, Rarity.COMMON, 1))
            assertEquals(withShield, f.ac)
            f.drawn = true
            assertEquals(if (kept) withShield else withShield - GearBases["shield"].armor, f.ac, second)
        }
    }

    /** 301 (Chef 22.10., 12:37): a blow announced on one who steps back goes to the one in front, the mark moves, with disadvantage. */
    @Test
    fun aBlowWhoseTargetStepsBackGoesToTheOneInFrontWithDisadvantage() {
        var seen = 0
        for (seed in 0 until 200) {
            val sk = probe(seed, merc = CharClass.FIGHTER)
            sk.start(); sk.settle()
            if (sk.outcome != Outcome.ONGOING) continue
            val f = sk.current
            if (f.side != Side.PARTY || f.place.row != Row.FRONT) continue
            val other = sk.fighters.first { it.side == Side.PARTY && it !== f }
            if (other.place.row != Row.FRONT || !other.standing) continue
            val (foeId, plan) = sk.intents.entries.firstOrNull { (_, p) ->
                p.first.kind == IntentKind.STRIKE && p.second == listOf(f.id) &&
                    p.first.effect !in setOf(Effect.BREAKTHROUGH, Effect.FLANK, Effect.CIRCLE, Effect.POUNCE)
            }?.toPair() ?: continue
            val empty = Spot.ALL.first { s -> s.row == Row.BACK && sk.fighters.none { it.side == Side.PARTY && it.place == s } }
            val said = sk.act(Order.Swap(empty))
            assertEquals(listOf(other.id), sk.intents.getValue(foeId).second, "the mark moves to the one in front")
            assertTrue(said.any { it.actor == foeId && it.target == other.id && it.text.contains(other.name(Lang.DE)) }, "the foe says it aims anew")
            assertTrue(foeId in sk.retargeted)
            // play on until the foe strikes: it strikes the one in front, with disadvantage
            val ev = mutableListOf<SkirmishEvent>()
            sk.listener = { ev += it }
            var guard = 0
            while (sk.outcome == Outcome.ONGOING && guard++ < 20 && ev.none { it.actor == foeId && it.roll?.kind == RollKind.ATTACK }) {
                val c = sk.current
                val t = sk.targets(c).firstOrNull()
                sk.act(if (t != null) Order.Attack(t.id) else Order.Wait)
            }
            val blow = ev.firstOrNull { it.actor == foeId && it.roll?.kind == RollKind.ATTACK } ?: continue
            assertEquals(other.id, blow.target)
            assertEquals(-1, blow.roll!!.mode, "disadvantage for the aim adjusted")
            if (plan.first.effect == null) seen++
            if (seen >= 3) return
        }
        assertTrue(seen > 0, "no seed had a blow announced on a figure that could step back")
    }
}
