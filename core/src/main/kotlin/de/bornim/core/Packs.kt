package de.bornim.core

/**
 * Companions that come along with a monster: they stand behind the leader, attack now and then
 * and flee when the leader falls. [mate] is the monster drawn for them, [scale] their size
 * relative to the leader.
 */
class PackDef(
    val mate: String,
    val scale: Float,
    /** Smallest and largest number of companions. */
    val min: Int,
    val max: Int,
    /** Chance that a companion attacks in a round. */
    val chance: Double,
    /** Attack bonus relative to the leader. */
    val attackShift: Int,
    val damage: DiceExpr,
    val fx: FxKind,
    /** Extra experience per companion, as a share of the leader's. */
    val xpShare: Double,
    /** "{0} more …" when the fight starts. */
    val intro: T,
    val attack: T,
    /** Subject for "… misses". */
    val one: T,
    val flee: T,
    val burned: T,
)

object Packs {
    private val kobolds = PackDef(
        "kobold", 0.66f, 1, 2, 0.7, 0, dice(1, 4), FxKind.PIERCE, 0.4,
        T("Ein Kobold-Rudel! {0} weitere Kobolde stechen aus dem Hintergrund zu.", "A kobold pack! {0} more kobolds jab from behind."),
        T("Ein Kobold aus dem Rudel sticht zu!", "A kobold from the pack jabs!"),
        T("Der Rudel-Kobold", "The pack kobold"),
        T("Ohne ihren Anführer fliehen die übrigen Kobolde!", "Without their leader, the other kobolds flee!"),
        T("Der Feuerball erfasst auch das Rudel – die Kobolde fliehen kreischend!", "The fireball catches the pack too – the kobolds flee screeching!"),
    )

    private val cubs = PackDef(
        "wolf", 0.55f, 1, 2, 0.5, -1, dice(1, 3), FxKind.BITE, 0.3,
        T("Ein Wolfsrudel! {0} Jungwölfe schnappen von der Seite zu.", "A wolf pack! {0} young wolves snap from the side."),
        T("Ein Jungwolf schnappt zu!", "A young wolf snaps!"),
        T("Der Jungwolf", "The young wolf"),
        T("Mit eingezogenem Schwanz fliehen die Jungwölfe ins Unterholz!", "Tails tucked, the young wolves flee into the undergrowth!"),
        T("Der Feuerball versengt die Jungwölfe – jaulend laufen sie davon!", "The fireball singes the young wolves – they run off yelping!"),
    )

    private val scout = PackDef(
        "goblin_archer", 0.7f, 1, 1, 0.6, 0, dice(1, 4), FxKind.ARROW, 0.4,
        T("Ein Goblin-Späher schießt aus dem Hintergrund.", "A goblin scout shoots from behind."),
        T("Der Späher schießt einen Pfeil!", "The scout looses an arrow!"),
        T("Der Späher", "The scout"),
        T("Ohne seinen Anführer ergreift der Späher die Flucht!", "Without its leader, the scout takes flight!"),
        T("Der Feuerball erfasst auch den Späher – er rennt kreischend davon!", "The fireball catches the scout too – it runs off screeching!"),
    )

    private val guard = PackDef(
        "wolf", 0.78f, 2, 2, 0.55, -1, dice(1, 4), FxKind.BITE, 0.25,
        T("Grimmzahns Leibwache! {0} Wölfe umkreisen dich knurrend.", "Grimfang's bodyguard! {0} wolves circle you, snarling."),
        T("Ein Wolf der Leibwache beißt zu!", "A wolf of the bodyguard bites!"),
        T("Der Wolf", "The wolf"),
        T("Ihr Leitwolf ist gefallen – die Wölfe verschwinden heulend im Wald!", "Their alpha has fallen – the wolves vanish howling into the forest!"),
        T("Der Feuerball treibt die Leibwache auseinander!", "The fireball scatters the bodyguard!"),
    )

    private val byLeader = mapOf("kobold" to kobolds, "wolf" to cubs, "goblin" to scout, "dire_wolf" to guard)

    operator fun get(monster: String): PackDef? = byLeader[monster]

    /** Number of companions; fixed per look, so map and battle agree. */
    fun size(monster: String, look: MonsterLook): Int {
        val p = byLeader[monster] ?: return 0
        return p.min + look.pick(p.max - p.min + 1, 50)
    }
}
