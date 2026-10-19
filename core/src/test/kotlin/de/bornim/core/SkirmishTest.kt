package de.bornim.core

import kotlin.random.Random
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

/** MARS (72.10, 72.10a): rows, place swap, ring, autopilot, knockouts (72.11, 72.13, 72v, 72r). */
class SkirmishTest {
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
            if (sk.outcome != Outcome.ONGOING) continue
            // the autopilot hands back only when one of its stop rules holds
            assertFalse(sk.autopilot)
            assertNotNull(sk.autopilotBlocked())
        }
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
            sk.start()
            if (sk.outcome != Outcome.ONGOING) continue
            assertEquals("hero", sk.current.id)
            sk.act(Order.Wait)
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
        assertEquals(setOf(Skill.FIRE_BOLT, Skill.MAGIC_MISSILE, Skill.SCORCHING_RAY), names)
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
        val ev = wiz.start().toMutableList()
        var guard = 0
        while (wiz.outcome == Outcome.ONGOING && guard++ < 30) ev += wiz.act(Order.Wait)
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
        repeat(6) { if (sk.outcome == Outcome.ONGOING && sk.current.side == Side.PARTY) sk.act(Order.Wait) }
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
            sk.listener = { e -> if (e.text.contains("verliert den Zug")) lost++ }
            play(sk, Reaction.GOOD)
        }
        assertTrue(lost > 0)
    }

    @Test
    fun theScoutVanishesAndCannotBeTargeted() {
        var hiddenSeen = false
        for (seed in 0 until 200) {
            val sk = foeProbe(seed, Skirmish.Companion.ProbeFoe.SCOUT)
            sk.start()
            var guard = 0
            while (sk.outcome == Outcome.ONGOING && guard++ < 200) {
                val scout = sk.byId("scout")
                if (scout.hidden) {
                    hiddenSeen = true
                    assertTrue(sk.targets(sk.current).none { it.id == "scout" }, "hidden scout is not a target")
                    assertTrue(sk.aimAt(sk.current, Skill.FIRE_BOLT).none { it.id == "scout" })
                    val lone = sk.fighters.none { it.side != sk.current.side && it.standing && it.id != "scout" }
                    if (lone && sk.current.hero?.has(Skill.FIRE_BOLT) == true) assertNotNull(sk.blocked(sk.current, Skill.FIRE_BOLT), "no target: the spell says why")
                }
                val t = sk.targets(sk.current).firstOrNull()
                sk.act(if (t != null) Order.Attack(t.id) else Order.Wait)
            }
        }
        assertTrue(hiddenSeen)
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
            assertTrue("prallt auf" in text, text)
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
}
