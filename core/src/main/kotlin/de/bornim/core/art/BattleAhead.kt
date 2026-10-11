package de.bornim.core.art

import de.bornim.core.Hero
import de.bornim.core.MonsterLook
import de.bornim.core.Roamer
import de.bornim.core.art.HeroFigure.Act
import de.bornim.core.art.HeroFigure.Strike

/**
 * 24.5: a fight's frames drawn ahead on the map. While a foe stands within [NEAR] fields, one low-priority thread
 * (on that thread alone, not on all cores) draws the hero's battle frames (most of them are the same against every foe), the opening first and the killing
 * blows last, then those of the nearest foe. It waits while the map itself is still being drawn ([consider]'s
 * `busy`), and stops when the map is no longer shown (a fight, the menu): the fight then draws what is missing.
 */
object BattleAhead {
    /** How near a foe must be, in fields walked, for its fight to be drawn ahead. */
    const val NEAR = 8

    /** How long after the last [consider] the map counts as gone (a fight or the menu) and drawing stops. */
    const val STALE_MS = 400L

    /** The nearest foe of [roamers] within [NEAR] fields of ([x], [y]), or null. */
    fun nearest(roamers: List<Roamer>, x: Int, y: Int): Roamer? =
        roamers.map { it to kotlin.math.abs(it.x - x) + kotlin.math.abs(it.y - y) }
            .filter { it.second <= NEAR }.minByOrNull { it.second }?.first

    /** Which victory pose the next fight ends in: chosen ahead, so its frames can be drawn before the fight. */
    @Volatile var victoryPick = kotlin.random.Random.nextInt(8)
        private set

    /** The victory pose of the fight beginning now; the next fight gets a new one. */
    fun takeVictoryPick(): Int = victoryPick.also { victoryPick = kotlin.random.Random.nextInt(8) }

    /** 24.5, measured in the test tab: how long the last fight waited for the hero's opening, all its frames, the foe's. */
    @Volatile var openingMs: Long? = null
    @Volatile var heroMs: Long? = null
    @Volatile var foeMs: Long? = null

    private class Want(val hero: Hero, val heroLook: String, val foe: String, val look: MonsterLook, val pick: Int) {
        fun same(o: Want?) = o != null && o.hero === hero && o.heroLook == heroLook && o.foe == foe && o.look == look && o.pick == pick
    }

    private val lock = Object()
    private var want: Want? = null
    private var done: Want? = null
    @Volatile private var seenAt = 0L
    @Volatile private var busy: () -> Boolean = { false }
    private var worker: Thread? = null

    /** Tests only: how many frames this drew; and whether it is drawing now. */
    @Volatile internal var drawn = 0
    @Volatile internal var working = false

    /**
     * Call every frame while the map shows: [foe] the nearest foe (its kind and look) or null, [busy] true while the map
     * is still drawing what it needs itself. Cheap when nothing changed.
     */
    fun consider(hero: Hero, foe: Pair<String, MonsterLook>?, now: Long = System.currentTimeMillis(), busy: () -> Boolean) {
        seenAt = now
        this.busy = busy
        if (foe == null) return
        val w = Want(hero, HeroBattle.look(hero), foe.first, foe.second, victoryPick)
        synchronized(lock) {
            if (w.same(want) || w.same(done)) return
            want = w
            if (worker == null) worker = Thread(::run, "battle-ahead").apply { isDaemon = true; priority = Thread.MIN_PRIORITY; start() }
            lock.notifyAll()
        }
    }

    private fun stale() = System.currentTimeMillis() - seenAt > STALE_MS

    private fun run() {
        // drawn quietly on this one thread, not on all cores, so walking the map never stutters for it (as 24.15)
        SdfRender.alone.set(true)
        while (true) {
            val w = synchronized(lock) {
                while (want == null) lock.wait()
                want!!
            }
            // the map first, and nothing while a fight or the menu shows
            if (stale() || busy()) { working = false; Thread.sleep(100); continue }
            working = true
            fun stop() = synchronized(lock) { want !== w } || stale() || busy()
            val count = { drawn++; stop() }
            HeroBattle.prepare(w.hero, w.foe, false, w.pick, cancelled = count)
            // the hero struck from behind opens otherwise: drawn too, after all else of the hero
            if (!stop()) HeroBattle.prepareAct(w.hero, Act.AMBUSHED, Strike.SLASH, 0, cancelled = count)
            if (!stop()) MonsterArt.prepare(w.foe, w.look, cancelled = count)
            synchronized(lock) {
                if (want === w && !stale() && !busy()) { done = w; want = null }
            }
            working = false
        }
    }

    /** Tests only: forgets what was drawn ahead. */
    internal fun reset() = synchronized(lock) { want = null; done = null; drawn = 0 }
}
