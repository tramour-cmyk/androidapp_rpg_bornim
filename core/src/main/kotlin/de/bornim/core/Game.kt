package de.bornim.core

sealed interface Mode {
    data object Explore : Mode
    data class Dialog(val speaker: String?, val text: String) : Mode
    data class Fight(val battle: Battle) : Mode
    data class Shop(val stock: List<String>) : Mode
    data object ChapterEnd : Mode
}

/** Result of a movement attempt, used by the UI to animate. */
sealed interface Move {
    data object Blocked : Move
    data class Stepped(val fromX: Int, val fromY: Int) : Move
}

/**
 * Overworld game logic: movement, interaction, scripts and encounters.
 * Pure Kotlin so it can be unit-tested; the app only renders it.
 */
class Game(var state: GameState, var lang: Lang, private val dice: Dice = Dice()) {
    companion object {
        const val ELITE_CHANCE = 0.12
        const val SHINY_CHANCE = 1.0 / 150
    }

    var mode: Mode = Mode.Explore
        private set

    /** Bumped on every change so the UI knows when to redraw. */
    var revision = 0
        private set

    /** Set when the map changed, so the app can autosave and fade. */
    var mapChanged = false

    private val queue = ArrayDeque<Cmd>()

    /** Sound effects triggered by the last actions; the app plays and clears them. */
    val sounds = ArrayDeque<de.bornim.core.audio.Sound>()
    private var battleFromScript: Cmd.Fight? = null
    private var graceSteps = 3
    private val npcFacing = mutableMapOf<String, Facing>()

    // Monsters walking around on the maps; not saved, they simply appear again after loading.
    private val herds = HashMap<String, MutableList<Roamer>>()
    /** Step counts at which a defeated monster of a map comes back. */
    private val respawns = HashMap<String, MutableList<Int>>()
    private var nextRoamerUid = 1
    private var battleRoamer: Roamer? = null
    /** App clock of the last update, and a short period after battles in which nothing attacks. */
    private var now = 0L
    private var peaceUntil = 0L
    // Movement of monsters is cosmetic randomness and must not shift the game's dice.
    private val roamRandom = kotlin.random.Random(state.steps * 31 + 7)

    val map: MapDef get() = World[state.place.map]
    val hero: Hero get() = state.hero

    fun npcFacing(npc: Npc): Facing = npcFacing[npc.id] ?: npc.facing

    /** Monsters walking around on the current map. */
    val roamers: List<Roamer> get() = herd()

    fun roamerAt(x: Int, y: Int): Roamer? = herd().firstOrNull { it.x == x && it.y == y }

    /** Walkable for the hero and monsters: free of walls, people and monsters. */
    fun free(x: Int, y: Int): Boolean = map.walkable(x, y, state) && roamerAt(x, y) == null

    /** Call once after creating or loading a game. */
    fun begin() {
        runOnEnter()
    }

    // ------------------------------------------------------------ movement

    fun move(dir: Facing): Move {
        if (mode != Mode.Explore) return Move.Blocked
        val p = state.place
        state.place = p.copy(facing = dir)
        val nx = p.x + dir.dx
        val ny = p.y + dir.dy
        val warp = map.warpAt(nx, ny)
        if (warp != null && warp.requires != null && !state.has(warp.requires)) {
            changed()
            enqueue(warp.denied)
            return Move.Blocked
        }
        roamerAt(nx, ny)?.let { r ->
            // Walking into a monster attacks it; from behind the hero strikes first.
            engage(r, if (r.facing == dir || (r.temper == Temper.LURKER && !r.hunting)) Opening.HERO_FIRST else Opening.NORMAL)
            return Move.Blocked
        }
        if (!map.walkable(nx, ny, state)) {
            changed()
            return Move.Blocked
        }
        state.place = Place(p.map, nx, ny, dir)
        state.steps++
        changed()
        return Move.Stepped(p.x, p.y)
    }

    /** Call when the step animation finished: handles warps, triggers and random encounters. */
    fun afterStep() {
        if (mode != Mode.Explore) return
        val p = state.place
        map.warpAt(p.x, p.y)?.let { warp ->
            sounds += de.bornim.core.audio.Sound.DOOR
            state.place = warp.to
            graceSteps = 3
            mapChanged = true
            changed()
            runOnEnter()
            return
        }
        map.triggers.firstOrNull { it.x == p.x && it.y == p.y && it.condition(state) }?.let {
            enqueue(it.script(state))
            return
        }
        respawnRoamers()
        if (graceSteps > 0) {
            graceSteps--
            return
        }
        val enc = map.encounters ?: return
        // Rarely, something hidden in the grass or the dark jumps out.
        if (map.tile(p.x, p.y) in enc.tiles && dice.chance(enc.rate)) {
            startBattle(dice.weighted(enc.table), null, opening = Opening.AMBUSHED)
        }
    }

    // ------------------------------------------------------------ monsters on the map

    private fun herd(): MutableList<Roamer> = herds.getOrPut(state.place.map) {
        val list = mutableListOf<Roamer>()
        repeat(map.encounters?.roamers ?: 0) { spawnRoamer(list)?.let { list += it } }
        list
    }

    /** Places a new monster on a free tile of the area, away from the hero. */
    private fun spawnRoamer(list: List<Roamer>): Roamer? {
        val enc = map.encounters ?: return null
        val p = state.place
        val spots = ArrayList<Pair<Int, Int>>()
        for (y in 0 until map.height) for (x in 0 until map.width) {
            if (map.tile(x, y) !in enc.tiles || !map.walkable(x, y, state) || map.warpAt(x, y) != null) continue
            if (kotlin.math.abs(x - p.x) + kotlin.math.abs(y - p.y) < 7) continue
            if (list.any { kotlin.math.abs(it.x - x) + kotlin.math.abs(it.y - y) < 3 }) continue
            if (map.triggers.any { it.x == x && it.y == y }) continue
            spots += x to y
        }
        if (spots.isEmpty()) return null
        val (x, y) = spots[roamRandom.nextInt(spots.size)]
        val monster = dice.weighted(enc.table)
        val shiny = dice.chance(SHINY_CHANCE)
        val trait = if (!shiny && hero.level >= 2 && dice.chance(ELITE_CHANCE)) dice.pick(EliteTrait.entries) else null
        return Roamer(nextRoamerUid++, monster, x, y, x, y, trait, shiny, MonsterLook(roamRandom.nextInt(), shiny, trait?.color)).also {
            it.facing = Facing.entries[roamRandom.nextInt(4)]
            it.nextMoveAt = now + 500 + roamRandom.nextInt(2000)
        }
    }

    private fun respawnRoamers() {
        val due = respawns[state.place.map] ?: return
        val herd = herd()
        val ready = due.filter { it <= state.steps }
        if (ready.isEmpty()) return
        due.removeAll(ready)
        repeat(ready.size) { spawnRoamer(herd)?.let { herd += it } }
        changed()
    }

    /**
     * Lets the monsters of the current map move; call every frame with the app clock in ms.
     * A hunter that reaches the hero starts a fight, from behind as an ambush.
     */
    fun updateRoamers(nowMs: Long) {
        now = nowMs
        if (mode != Mode.Explore) return
        val herd = herd()
        val p = state.place
        val strongHero = hero.level >= map.areaLevel + 5
        var moved = false
        for (r in herd) {
            if (now < r.nextMoveAt) continue
            val dist = kotlin.math.abs(r.x - p.x) + kotlin.math.abs(r.y - p.y)
            val calm = now < r.calmUntil || now < peaceUntil
            // Weak monsters keep away from a far stronger hero; elites are never afraid.
            val afraid = strongHero && r.trait == null
            when {
                !calm && afraid && dist <= 4 -> {
                    r.hunting = false
                    stepRoamer(r, away = true, ms = 320)
                }
                !calm && !afraid && r.temper != Temper.WANDERER && (r.hunting || dist <= (if (r.temper == Temper.LURKER) 2 else 5)) -> {
                    if (!r.hunting) {
                        r.hunting = true
                        r.alertUntil = now + 800
                        r.nextMoveAt = now + 450
                        sounds += de.bornim.core.audio.Sound.ALERT
                        moved = true
                        continue
                    }
                    if (dist > 9) {
                        r.hunting = false
                    } else if (dist == 1) {
                        // Adjacent: attack. Coming from behind the hero is an ambush.
                        val fromBehind = r.x - p.x == -p.facing.dx && r.y - p.y == -p.facing.dy
                        r.facing = Facing.entries.first { it.dx == p.x - r.x && it.dy == p.y - r.y }
                        engage(r, if (fromBehind) Opening.AMBUSHED else Opening.NORMAL)
                        return
                    } else {
                        stepRoamer(r, away = false, ms = if (r.monster == "zombie" || r.monster == "ochre_jelly") 520 else 300)
                    }
                }
                r.temper == Temper.LURKER && !r.hunting -> r.nextMoveAt = now + 1000
                else -> wander(r)
            }
            moved = true
        }
        if (moved) changed()
    }

    private fun wander(r: Roamer) {
        r.hunting = false
        if (roamRandom.nextInt(10) < 3) {
            r.facing = Facing.entries[roamRandom.nextInt(4)]
        } else {
            val dirs = Facing.entries.shuffled(roamRandom)
            for (d in dirs) {
                val nx = r.x + d.dx; val ny = r.y + d.dy
                if (kotlin.math.abs(nx - r.homeX) + kotlin.math.abs(ny - r.homeY) > 3) continue
                if (moveRoamer(r, d, 420)) break
            }
        }
        r.nextMoveAt = now + 900 + roamRandom.nextInt(1600)
    }

    /** One step towards (or away from) the hero along the better axis, trying the other one if blocked. */
    private fun stepRoamer(r: Roamer, away: Boolean, ms: Long) {
        val p = state.place
        val dx = (p.x - r.x).let { if (away) -it else it }
        val dy = (p.y - r.y).let { if (away) -it else it }
        val h = if (dx > 0) Facing.RIGHT else Facing.LEFT
        val v = if (dy > 0) Facing.DOWN else Facing.UP
        val order = if (kotlin.math.abs(dx) >= kotlin.math.abs(dy)) listOf(h, v) else listOf(v, h)
        val tried = order.filter { (if (it == h) dx else dy) != 0 } + Facing.entries.shuffled(roamRandom)
        for (d in tried) if (moveRoamer(r, d, ms)) break
        r.nextMoveAt = now + ms + 40
    }

    private fun moveRoamer(r: Roamer, d: Facing, ms: Long): Boolean {
        val nx = r.x + d.dx; val ny = r.y + d.dy
        val p = state.place
        if (!free(nx, ny) || map.warpAt(nx, ny) != null || (nx == p.x && ny == p.y)) return false
        if (map.tile(nx, ny) == Tile.DOOR || map.tile(nx, ny) == Tile.GATE) return false
        r.fromX = r.x; r.fromY = r.y
        r.x = nx; r.y = ny
        r.facing = d
        r.movedAt = now
        r.moveMs = ms
        return true
    }

    /** Starts the fight against a monster on the map. */
    private fun engage(r: Roamer, opening: Opening) {
        if (mode != Mode.Explore) return
        battleRoamer = r
        startBattle(r.monster, null, r.trait to r.shiny, opening, r.look)
    }

    private fun runOnEnter() {
        enqueue(map.onEnter(state))
    }

    // ------------------------------------------------------------ interaction

    /** Turns the hero without moving (used after walking to a tapped target). */
    fun face(dir: Facing) {
        if (mode != Mode.Explore) return
        state.place = state.place.copy(facing = dir)
        changed()
    }

    fun interact() {
        if (mode != Mode.Explore) return
        val p = state.place
        var tx = p.x + p.facing.dx
        var ty = p.y + p.facing.dy
        if (map.tile(tx, ty) == Tile.COUNTER) {
            tx += p.facing.dx
            ty += p.facing.dy
        }
        roamerAt(tx, ty)?.let { r ->
            engage(r, if (r.facing == p.facing || (r.temper == Temper.LURKER && !r.hunting)) Opening.HERO_FIRST else Opening.NORMAL)
            return
        }
        map.npcAt(tx, ty, state)?.let { npc ->
            npcFacing[npc.id] = p.facing.opposite
            enqueue(npc.talk(state))
            return
        }
        map.signs[tx to ty]?.let {
            enqueue(listOf(Cmd.Say(null, it)))
            return
        }
        when (map.tile(tx, ty)) {
            Tile.CHEST -> openChest(tx, ty)
            Tile.CAMPFIRE -> enqueue(listOf(Cmd.Rest, Cmd.Say(null, Ui.rested)))
            Tile.GATE -> gate()
            Tile.WELL -> say(T("Ein alter Brunnen. Das Wasser ist klar und kalt.", "An old well. The water is clear and cold."))
            Tile.SHELF -> say(T("Regale voller Krimskrams.", "Shelves full of odds and ends."))
            Tile.BED -> say(T("Ein weiches Bett. Jetzt ist keine Zeit zum Schlafen.", "A soft bed. No time to sleep now."))
            Tile.ALTAR -> say(
                if (state.has(Story.CHAPTER1_DONE)) T("Das Sonnenamulett strahlt auf dem Altar.", "The Sun Amulet shines on the altar.")
                else T("Auf dem Altar ist eine leere Halterung. Hier lag das Sonnenamulett.", "There's an empty holder on the altar. This is where the Sun Amulet lay.")
            )
            else -> {}
        }
    }

    private fun say(t: T) = enqueue(listOf(Cmd.Say(null, t)))

    private fun openChest(x: Int, y: Int) {
        val chest = map.chestAt(x, y) ?: return say(Ui.nothingHere)
        if (chest.id in state.openedChests) return say(Ui.chestEmpty)
        state.openedChests += chest.id
        sounds += de.bornim.core.audio.Sound.CHEST
        val cmds = mutableListOf<Cmd>()
        chest.item?.let { raw ->
            val id = if (raw == Story.CLASS_WEAPON) Story.classWeapon(hero.cls) else raw
            cmds += Cmd.Give(id, chest.count)
        }
        if (chest.gold > 0) cmds += Cmd.GiveGold(chest.gold)
        enqueue(cmds)
    }

    private fun gate() {
        when {
            state.has(Story.GATE_OPEN) -> {}
            state.count("rusty_key") > 0 -> enqueue(script {
                take("rusty_key")
                flag(Story.GATE_OPEN)
                narrate("Du steckst den rostigen Schlüssel ins Schloss. Mit lautem Quietschen öffnet sich das Gitter.", "You put the rusty key into the lock. With a loud screech, the gate swings open.")
            })
            else -> say(T("Ein schweres Eisengitter. Es ist verschlossen.", "A heavy iron gate. It's locked."))
        }
    }

    // ------------------------------------------------------------ scripts

    fun enqueue(cmds: List<Cmd>) {
        queue.addAll(cmds)
        if (mode == Mode.Explore) runQueue()
    }

    /** Continue after the player dismissed a dialog box, closed the shop or the chapter end screen. */
    fun advance() {
        if (mode is Mode.Fight) return
        mode = Mode.Explore
        runQueue()
        changed()
    }

    private fun runQueue() {
        while (queue.isNotEmpty()) {
            when (val c = queue.removeFirst()) {
                is Cmd.Say -> {
                    mode = Mode.Dialog(c.speaker?.invoke(lang), c.text(lang).replace("{name}", hero.name))
                    changed()
                    return
                }
                is Cmd.SetFlag -> state.flags += c.flag
                is Cmd.Give -> {
                    val text = when {
                        c.item.startsWith("@gear:") -> {
                            val min = Rarity.valueOf(c.item.removePrefix("@gear:"))
                            val ilvl = maxOf(map.areaLevel, hero.level)
                            val g = state.addGear(Loot.generate(state, dice, ilvl, Loot.rollRarity(dice, ilvl, hero.bonus(Affix.MAGIC_FIND), min), hero.cls))
                            "${g.name(lang)} (${g.rarity.title(lang)})"
                        }
                        Uniques.exists(c.item) -> {
                            val g = state.addGear(Uniques.make(c.item, 0, maxOf(map.areaLevel, hero.level)))
                            "${g.name(lang)} (${g.rarity.title(lang)})"
                        }
                        else -> {
                            state.add(c.item, c.count)
                            (if (c.count > 1) "${c.count}× " else "") + Items[c.item].name(lang)
                        }
                    }
                    sounds += de.bornim.core.audio.Sound.LOOT
                    mode = Mode.Dialog(null, Ui.found.f(lang, text))
                    changed()
                    return
                }
                is Cmd.Take -> state.remove(c.item, c.count)
                is Cmd.GiveGold -> {
                    sounds += de.bornim.core.audio.Sound.COINS
                    state.gold += c.amount
                    mode = Mode.Dialog(null, Ui.foundGold.f(lang, c.amount))
                    changed()
                    return
                }
                is Cmd.Fight -> {
                    startBattle(c.monster, c)
                    return
                }
                is Cmd.OpenShop -> {
                    mode = Mode.Shop(c.stock)
                    changed()
                    return
                }
                Cmd.Rest -> {
                    sounds += de.bornim.core.audio.Sound.HEAL
                    hero.restoreFully()
                    state.respawn = state.place
                }
                Cmd.ChapterEnd -> {
                    mode = Mode.ChapterEnd
                    changed()
                    return
                }
            }
        }
        mode = Mode.Explore
        changed()
    }

    // ------------------------------------------------------------ battles

    private fun startBattle(
        monster: String, fromScript: Cmd.Fight?, forced: Pair<EliteTrait?, Boolean>? = null,
        opening: Opening = Opening.NORMAL, forcedLook: MonsterLook? = null,
    ) {
        battleFromScript = fromScript
        val def = Monsters[monster]
        // Monsters grow with the hero so grinding stays worthwhile.
        val area = map.areaLevel
        var level = maxOf(area, hero.level - 1 + (if (dice.chance(0.3)) 1 else 0))
        // Story bosses only grow a little, so returning to them later is not a wall.
        if (def.boss) level = minOf(level, area + 2)
        val shiny = forced?.second ?: (!def.boss && dice.chance(SHINY_CHANCE))
        // No elites for brand-new heroes: the first level is for learning the ropes.
        val trait = if (forced != null) forced.first
        else if (!def.boss && !shiny && hero.level >= 2 && dice.chance(ELITE_CHANCE)) dice.pick(EliteTrait.entries) else null
        // The look is purely cosmetic and must not use the game's dice.
        val look = forcedLook ?: MonsterLook(kotlin.random.Random.nextInt(), shiny, trait?.color)
        sounds += if (opening == Opening.AMBUSHED) de.bornim.core.audio.Sound.AMBUSH else de.bornim.core.audio.Sound.ENCOUNTER
        mode = Mode.Fight(Battle(state, def, lang, dice, level, trait != null, area, trait, shiny, look, opening))
        changed()
    }

    // ------------------------------------------------------------ test mode (hidden cheat menu)

    /** Sets the hero's level. Going down removes unspent points; points already spent stay. */
    fun cheatLevel(target: Int) {
        val t = target.coerceIn(1, Rules.MAX_LEVEL)
        val h = hero
        if (t > h.level) {
            h.gainXp(maxOf(0, Rules.xpForLevel[t] - h.xp))
        } else if (t < h.level) {
            h.level = t
            h.xp = Rules.xpForLevel[t]
            // A hero of level t has exactly t - 1 ability points; take back what is too much,
            // starting with the most raised ability, so the hero looks as if it reached t normally.
            val start = Hero.startingScores(h.race, h.cls)
            var excess = h.spentPoints - (t - 1)
            while (excess > 0) {
                val a = Ability.entries.maxBy { h.base.getValue(it) - start.getValue(it) }
                h.base[a] = h.base.getValue(a) - 1
                excess--
            }
            h.unspentPoints = (t - 1) - h.spentPoints
        }
        h.restoreFully()
        changed()
    }

    fun cheatGold(amount: Int) {
        state.gold += amount
        changed()
    }

    fun cheatHeal() {
        hero.restoreFully()
        changed()
    }

    /** Puts Krogg and Grak back on the map. */
    fun cheatRespawnBosses() {
        state.flags -= setOf(Story.KROGG_DEFEATED, Story.GRAK_DEFEATED)
        changed()
    }

    /** Starts a fight against [monster] right here, optionally as elite or shimmering variant. */
    fun cheatFight(monster: String, trait: EliteTrait?, shiny: Boolean) {
        if (mode !is Mode.Explore) return
        startBattle(monster, null, trait to shiny)
    }

    /** Puts a random piece of gear of [rarity] for the hero's level and class into the bag. */
    fun cheatLoot(rarity: Rarity): Gear {
        val g = state.addGear(Loot.generate(state, dice, hero.level, rarity, hero.cls))
        changed()
        return g
    }

    fun cheatWarp(place: Place) {
        if (mode !is Mode.Explore) return
        state.place = place
        changed()
    }

    /** Starts a prepared battle directly (previews and tests). */
    fun fight(battle: Battle) {
        battleFromScript = null
        mode = Mode.Fight(battle)
        changed()
    }

    /** Call after the battle screen showed all messages of a finished battle. */
    fun endBattle() {
        val battle = (mode as? Mode.Fight)?.battle ?: return
        val script = battleFromScript
        battleFromScript = null
        graceSteps = 3
        mode = Mode.Explore
        peaceUntil = now + 2500
        battleRoamer?.let { r ->
            when (battle.outcome) {
                Outcome.WON, Outcome.ENEMY_FLED -> {
                    herds[state.place.map]?.remove(r)
                    // It comes back after a good walk.
                    respawns.getOrPut(state.place.map) { mutableListOf() } += state.steps + 60
                }
                else -> {
                    r.hunting = false
                    r.calmUntil = now + 8000
                }
            }
        }
        battleRoamer = null
        when (battle.outcome) {
            Outcome.WON, Outcome.ENEMY_FLED -> {
                script?.winFlag?.let { state.flags += it }
                runQueue()
            }
            Outcome.LOST -> {
                queue.clear()
                val lost = state.gold / 2
                state.gold -= lost
                hero.restoreFully()
                state.place = state.respawn
                mapChanged = true
                enqueue(listOf(Cmd.Say(null, T(
                    "Du erwachst an einem sicheren Ort … Du hast {0} Gold verloren.",
                    "You wake up somewhere safe... You lost {0} gold.",
                ).let { T(it.de.replace("{0}", "$lost"), it.en.replace("{0}", "$lost")) })))
            }
            Outcome.FLED, Outcome.ONGOING -> queue.clear()
        }
        changed()
    }

    // ------------------------------------------------------------ menu actions

    /** Use a consumable outside of battle. Returns a message to show. */
    fun useItemOutside(id: String): String {
        val def = Items[id]
        if (def.kind != ItemKind.POTION || state.count(id) == 0) return Ui.cannotUseHere(lang)
        if (hero.hp >= hero.maxHp) return Ui.alreadyFull(lang)
        state.remove(id)
        sounds += de.bornim.core.audio.Sound.POTION
        val before = hero.hp
        hero.hp = minOf(hero.maxHp, hero.hp + dice.roll(def.heal!!))
        changed()
        return T("{0} heilt {1} TP.", "{0} recovers {1} HP.").f(lang, hero.name, hero.hp - before)
    }

    fun buy(id: String): String {
        val def = Items[id]
        if (state.gold < def.price) return Ui.notEnoughGold(lang)
        state.gold -= def.price
        state.add(id)
        sounds += de.bornim.core.audio.Sound.COINS
        changed()
        return Ui.bought.f(lang, def.name(lang))
    }

    fun sellPrice(id: String): Int = Items[id].price / 2

    /** Tilda's current gear stock, without the pieces already bought. */
    fun shopGear(): List<Gear> {
        val batch = state.battlesWon / 8
        return Loot.shopGear(state).filter { "$batch:${it.uid}" !in state.shopSold }
    }

    fun buyGear(g: Gear): String {
        if (state.gold < g.price) return Ui.notEnoughGold(lang)
        state.gold -= g.price
        state.shopSold += "${state.battlesWon / 8}:${g.uid}"
        state.addGear(g.copy(uid = 0))
        sounds += de.bornim.core.audio.Sound.COINS
        changed()
        return Ui.bought.f(lang, g.name(lang))
    }

    fun sellPrice(g: Gear): Int = maxOf(1, g.price / 4)

    fun sellGear(g: Gear): String {
        if (!state.bag.remove(g)) return Ui.cannotSell(lang)
        state.gold += sellPrice(g)
        sounds += de.bornim.core.audio.Sound.COINS
        changed()
        return Ui.sold.f(lang, g.name(lang))
    }

    /** Sells every common piece in the bag at once. */
    fun sellAllCommon(): Int {
        val junk = state.bag.filter { it.rarity == Rarity.COMMON }
        junk.forEach { state.bag.remove(it); state.gold += sellPrice(it) }
        changed()
        return junk.size
    }

    fun discard(g: Gear) {
        state.bag.remove(g)
        changed()
    }

    fun sell(id: String): String {
        val def = Items[id]
        if (!def.sellable || !state.remove(id)) return Ui.cannotSell(lang)
        state.gold += sellPrice(id)
        sounds += de.bornim.core.audio.Sound.COINS
        changed()
        return Ui.sold.f(lang, def.name(lang))
    }

    fun changed() {
        revision++
    }
}
