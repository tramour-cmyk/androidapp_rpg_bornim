package de.bornim.core.art

import de.bornim.core.Hero
import de.bornim.core.MonsterLook
import de.bornim.core.Roamer
import de.bornim.core.art.HeroFigure.Act
import de.bornim.core.art.HeroFigure.Strike
import java.util.concurrent.ForkJoinPool
import java.util.concurrent.ForkJoinWorkerThread

/**
 * 24.5: a fight's frames drawn ahead on the map. While a foe stands within [NEAR] fields, one low-priority thread
 * draws, on [CORES] cores of its own (24.17), first the hero's opening (facing us, turning, standing), then the foe's
 * frames, then the rest of the hero's (most of them are the same against every foe), the killing blows last (24.18).
 * The foe being drawn (or drawn already) is kept while it stays near, though another of its pack comes nearer. It waits while the map
 * itself is still being drawn ([consider]'s `busy`), and stops when the map is no longer shown (a fight, the menu):
 * the fight then draws what is missing.
 * 24.20: the hero's frames are drawn ahead also with no foe near (for the last foe met), and kept on the device
 * ([HeroBattle.keep]), so that after a new start they are read instead of drawn.
 */
object BattleAhead {
    /** How near a foe must be, in fields walked, for its fight to be drawn ahead. */
    const val NEAR = 8

    /** How long after the last [consider] the map counts as gone (a fight or the menu) and drawing stops. */
    const val STALE_MS = 400L

    /** On how many cores at most the frames are drawn ahead (24.17). */
    const val CORES = 2

    /** The foes of [roamers] within [NEAR] fields of ([x], [y]), the nearest first. */
    fun near(roamers: List<Roamer>, x: Int, y: Int): List<Roamer> =
        roamers.map { it to kotlin.math.abs(it.x - x) + kotlin.math.abs(it.y - y) }
            .filter { it.second <= NEAR }.sortedBy { it.second }.map { it.first }

    /** The nearest foe of [roamers] within [NEAR] fields of ([x], [y]), or null. */
    fun nearest(roamers: List<Roamer>, x: Int, y: Int): Roamer? = near(roamers, x, y).firstOrNull()

    /** Which victory pose the next fight ends in: chosen ahead, so its frames can be drawn before the fight. */
    @Volatile var victoryPick = kotlin.random.Random.nextInt(8)
        private set

    /** The victory pose of the fight beginning now; the next fight gets a new one. */
    fun takeVictoryPick(): Int = victoryPick.also { victoryPick = kotlin.random.Random.nextInt(8) }

    /** 24.5, measured in the test tab: how long the last fight waited for the hero's opening, all its frames, the foe's. */
    @Volatile var openingMs: Long? = null
    @Volatile var heroMs: Long? = null
    @Volatile var foeMs: Long? = null

    /**
     * 24.16, shown in the test tab: what the last fight found drawn ahead. [heroReady] of the hero's [heroAll] frames;
     * of its foe [foe] [foeDrawn] frames, all of them if [foeDone]; how long the drawing ahead waited for the map
     * ([waitedMs]) while a foe was near, and how long one was near ([nearMs]).
     */
    class Report(val heroReady: Int, val heroAll: Int, val kept: Boolean, val foe: String, val foeDrawn: Int, val foeDone: Boolean, val waitedMs: Long, val nearMs: Long)
    @Volatile var report: Report? = null

    private data class Foe(val id: String, val look: MonsterLook)

    private class HeroWant(val hero: Hero, val look: String, val pick: Int) {
        fun same(o: HeroWant?) = o != null && o.hero === hero && o.look == look && o.pick == pick
    }

    private val lock = Object()
    private var heroWant: HeroWant? = null
    private var openingDone: HeroWant? = null
    private var restDone: Pair<HeroWant, String>? = null
    private var near: List<Foe> = emptyList()
    private var target: Foe? = null
    /** The last foes drawn in full: the frames kept hold about two of them. */
    private val foesDone = ArrayDeque<Foe>()
    private val foeDrawn = HashMap<Foe, Int>()
    /** The foe whose fight the rest of the hero is drawn for: the last one near, before any, a goblin. */
    private var lastFoe = "goblin"
    /** The look whose frames kept on the device were read already, and whether there were any (shown in the test tab). */
    private var fetched: String? = null
    @Volatile var fromShelf = false
        private set
    private var nearSince = 0L
    private var waited = 0L
    @Volatile private var seenAt = 0L
    @Volatile private var busy: () -> Boolean = { false }
    private var worker: Thread? = null

    /** The cores the frames are drawn on, quietly, so walking the map does not stutter for it. */
    private val pool: ForkJoinPool by lazy {
        ForkJoinPool(CORES.coerceAtMost(Runtime.getRuntime().availableProcessors()), { p ->
            object : ForkJoinWorkerThread(p) {}.apply { isDaemon = true; priority = Thread.MIN_PRIORITY; name = "battle-ahead-$poolIndex" }
        }, null, false)
    }

    /** Tests only: how many frames this drew; and whether it is drawing now. */
    @Volatile internal var drawn = 0
    @Volatile internal var working = false

    /**
     * Call every frame while the map shows: [foes] the foes near (their kind and look), the nearest first, [busy] true
     * while the map is still drawing what it needs itself. Cheap when nothing changed.
     */
    fun consider(hero: Hero, foes: List<Pair<String, MonsterLook>>, now: Long = System.currentTimeMillis(), busy: () -> Boolean) {
        seenAt = now
        this.busy = busy
        synchronized(lock) {
            // 24.20: the hero's frames are drawn ahead also with no foe near, once the map is drawn
            if (foes.isEmpty()) { near = emptyList(); target = null; nearSince = 0L; waited = 0L }
            else if (nearSince == 0L) nearSince = now
            if (foes.size != near.size || foes.indices.any { foes[it].first != near[it].id || foes[it].second != near[it].look })
                near = foes.map { Foe(it.first, it.second) }
            val hw = HeroWant(hero, HeroBattle.look(hero), victoryPick)
            if (!hw.same(heroWant)) heroWant = hw
            // the foe being drawn, or drawn already, stays while it is near: in a pack the nearest changes all the time,
            // and the frames kept hold hardly more than one of them
            val t = target
            if (t == null || t !in near) target = near.firstOrNull { it in foesDone } ?: near.firstOrNull()
            target?.let { lastFoe = it.id }
            if (next() == null) return
            if (worker == null) worker = Thread(::run, "battle-ahead").apply { isDaemon = true; priority = Thread.MIN_PRIORITY; start() }
            lock.notifyAll()
        }
    }

    /** The hero's opening of a fight not struck from behind: facing us, turning to the foe, standing. */
    private val OPENING = listOf(Act.INTRO, Act.TURN, Act.IDLE)

    private fun stale() = System.currentTimeMillis() - seenAt > STALE_MS

    private sealed interface Job
    private class Fetch(val hw: HeroWant) : Job
    private class Opening(val hw: HeroWant, val foe: String) : Job
    private class FoeFrames(val foe: Foe) : Job
    private class Rest(val hw: HeroWant, val foe: String) : Job

    /** What to draw next, under [lock]: the hero's opening, the foe, the rest of the hero; null when all is drawn. */
    private fun next(): Job? {
        val hw = heroWant ?: return null
        // the frames kept on the device first, then what is still missing
        if (fetched != hw.look) return Fetch(hw)
        val foe = target?.id ?: lastFoe
        if (!hw.same(openingDone)) return Opening(hw, foe)
        target?.let { if (it !in foesDone) return FoeFrames(it) }
        val r = restDone
        if (r == null || !hw.same(r.first) || r.second != foe) return Rest(hw, foe)
        return null
    }

    private fun run() {
        SdfRender.pool.set(pool)
        while (true) {
            val job = synchronized(lock) {
                var j = next()
                while (j == null) { lock.wait(); j = next() }
                j
            }
            // the map first, and nothing while a fight or the menu shows
            if (stale() || busy()) {
                working = false
                val t = System.currentTimeMillis()
                Thread.sleep(100)
                if (!stale()) synchronized(lock) { if (near.isNotEmpty()) waited += System.currentTimeMillis() - t }
                continue
            }
            working = true
            fun gone() = stale() || busy()
            // 30: an error here (out of memory too) must not end the app; the job counts as done, nothing more drawn for it
            val ran = de.bornim.core.Guard.run("Kampf vorab") { DrawBusy.during(DrawBusy.Kind.FIGHT) { when (job) {
                is Fetch -> {
                    val got = HeroBattle.fetch(job.hw.hero)
                    synchronized(lock) { fetched = job.hw.look; fromShelf = got }
                }
                is Opening -> {
                    // only the opening's own frames: the whole plan would first work out where every blow lands
                    val stop = { gone() || synchronized(lock) { heroWant !== job.hw } }
                    for (act in OPENING) HeroBattle.prepareAct(job.hw.hero, act, Strike.SLASH, 0) { stop().also { if (!it) drawn++ } }
                    if (!stop() && OPENING.all { HeroBattle.actReady(job.hw.hero, it) }) synchronized(lock) { if (heroWant === job.hw) openingDone = job.hw }
                }
                is FoeFrames -> {
                    var stopped = false
                    MonsterArt.prepare(job.foe.id, job.foe.look) {
                        stopped = gone() || synchronized(lock) { target != job.foe }
                        if (!stopped) { drawn++; synchronized(lock) { foeDrawn[job.foe] = (foeDrawn[job.foe] ?: 0) + 1 } }
                        stopped
                    }
                    if (!stopped) synchronized(lock) {
                        foesDone.remove(job.foe); foesDone.addLast(job.foe)
                        while (foesDone.size > 2) foesDone.removeFirst()
                        if (foeDrawn.size > 8) foeDrawn.keys.retainAll(foesDone.toSet() + listOfNotNull(target))
                    }
                }
                is Rest -> {
                    // a new foe near comes before the rest of the hero
                    fun stop() = gone() || synchronized(lock) { heroWant !== job.hw || target.let { it != null && it !in foesDone } }
                    val count = { stop().also { if (!it) drawn++ } }
                    HeroBattle.prepare(job.hw.hero, job.foe, false, job.hw.pick, cancelled = count)
                    // the hero struck from behind opens otherwise: drawn too, after all else of the hero
                    if (!stop()) HeroBattle.prepareAct(job.hw.hero, Act.AMBUSHED, Strike.SLASH, 0, cancelled = count)
                    if (!stop()) {
                        synchronized(lock) { restDone = job.hw to job.foe }
                        // kept on the device: the next start, or this gear worn again, needs no drawing (24.20)
                        HeroBattle.keep(job.hw.hero)
                    }
                }
            } } }
            if (!ran) synchronized(lock) { skip(job) }
            working = false
        }
    }

    /** 30: after an error, marks [job] as done, so the thread does not try it again and again. Under [lock]. */
    private fun skip(job: Job) {
        when (job) {
            is Fetch -> fetched = job.hw.look
            is Opening -> openingDone = job.hw
            is FoeFrames -> { foesDone.remove(job.foe); foesDone.addLast(job.foe); while (foesDone.size > 2) foesDone.removeFirst() }
            is Rest -> restDone = job.hw to job.foe
        }
    }

    /** 24.16: notes what the fight beginning now finds drawn ahead, for the test tab. Call it before the fight draws. */
    fun noteFight(hero: Hero, foeId: String, look: MonsterLook, ambushed: Boolean, pick: Int) {
        val (ready, all) = HeroBattle.planReady(hero, foeId, ambushed, pick)
        val f = Foe(foeId, look)
        report = synchronized(lock) {
            Report(ready, all, fromShelf, foeId, foeDrawn[f] ?: 0, f in foesDone, waited,
                if (nearSince == 0L) 0L else System.currentTimeMillis() - nearSince)
        }
    }

    /** Tests only: forgets what was drawn ahead. */
    internal fun reset() = synchronized(lock) {
        heroWant = null; openingDone = null; restDone = null; fetched = null; fromShelf = false; lastFoe = "goblin"; near = emptyList(); target = null
        foesDone.clear(); foeDrawn.clear(); nearSince = 0L; waited = 0L; drawn = 0
    }
}
