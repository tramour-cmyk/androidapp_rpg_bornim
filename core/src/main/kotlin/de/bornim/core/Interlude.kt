package de.bornim.core

import kotlin.random.Random

/**
 * The words on the black screen between two places and before a fight (24, draft in docs/ZWISCHENBILD.md):
 * the screen shows while the pictures of what comes next are drawn, the sentence is the waiting.
 *
 * Places are Tom's, fights are Jerry's: [openings] and [foes] are filled by Jerry, the screen only reads them.
 */
object Interlude {

    /** One sentence; [night] true only at night, false only by day, null always; [needs] / [without] a story flag. */
    data class Line(val text: T, val night: Boolean? = null, val needs: String? = null, val without: String? = null) {
        fun fits(state: GameState, isNight: Boolean) =
            (night == null || night == isNight) && (needs == null || state.has(needs)) && (without == null || !state.has(without))
    }

    /** How a fight begins: the first line on the screen, without the foe's name (which follows large below it). */
    enum class Start { AMBUSH, HERO_FIRST, NORMAL, PACK }

    private fun l(de: String, en: String, night: Boolean? = null, needs: String? = null, without: String? = null) =
        Line(T(de, en), night, needs, without)

    /** The sentences for entering each map, by map id. */
    val places: Map<String, List<Line>> = mapOf(
        "village" to listOf(
            l("Du betrittst Bornim. Rauch hängt über den Dächern.", "You enter Bornim. Smoke hangs over the rooftops."),
            l("Bornim. Für eine Weile bist du hier sicher.", "Bornim. For a while, you are safe here."),
            l("Du kehrst nach Bornim zurück. Niemand fragt, woher das Blut an deinem Mantel stammt.",
                "You return to Bornim. No one asks where the blood on your cloak came from."),
            l("Die Gassen von Bornim riechen nach Herdfeuer und nassem Stroh.", "The lanes of Bornim smell of hearth smoke and wet straw."),
            l("Fensterläden klappern im Wind. Bornim hat dich wieder.", "Shutters rattle in the wind. Bornim has you back."),
            l("Bornim schläft. Nur hinter wenigen Fenstern brennt noch Licht.", "Bornim sleeps. Only a few windows still hold a light.", night = true),
        ),
        "forest" to listOf(
            l("Du betrittst den Flüsterwald. Die Bäume rücken dichter zusammen.", "You enter the Whisperwood. The trees close in."),
            l("Der Flüsterwald. Hier wispert der Wind, oder etwas anderes.", "The Whisperwood. The wind whispers here, or something else does."),
            l("Hinter dir verklingt das Dorf. Vor dir liegt der Flüsterwald.", "The village fades behind you. Ahead lies the Whisperwood."),
            l("Du folgst dem Pfad in den Flüsterwald. Bleib auf dem Weg.", "You follow the path into the Whisperwood. Stay on the path."),
            l("Moos dämpft deine Schritte. Der Flüsterwald hört zu.", "Moss muffles your steps. The Whisperwood is listening."),
        ),
        "deep_forest" to listOf(
            l("Du dringst tiefer in den Wald vor. Das Licht wird grau.", "You push deeper into the woods. The light turns grey."),
            l("Kein Vogel singt mehr.", "No bird sings any more."),
            l("Diesen Pfad hat lange kein Mensch betreten.", "No one has walked this path in a long time."),
            l("Zwischen den Wurzeln liegen abgenagte Knochen.", "Gnawed bones lie among the roots."),
            l("Die Kronen schließen sich über dir. Der Tag bleibt draußen.", "The canopy closes above you. The day stays outside."),
        ),
        "cave" to listOf(
            l("Du betrittst die Blutzahnhöhle. Es riecht nach Rauch und Aas.", "You enter the Bloodfang Cave. It smells of smoke and carrion."),
            l("Kalter Stein, tropfendes Wasser. Die Höhle verschluckt das Licht.", "Cold stone, dripping water. The cave swallows the light."),
            l("Der Eingang der Blutzahnhöhle gähnt wie ein Maul.", "The mouth of the Bloodfang Cave gapes like a maw."),
            l("Irgendwo in der Tiefe schlägt Metall auf Stein.", "Somewhere in the depths, metal strikes stone."),
            l("Hinter dir schrumpft der Himmel zu einem fahlen Fleck.", "Behind you, the sky shrinks to a pale smudge."),
        ),
        "elder" to listOf(
            l("Du suchst Aldric, den Ältesten, auf.", "You call on Aldric, the elder."),
            l("Aldric blickt von seinem Pult auf.", "Aldric looks up from his desk."),
            l("Kerzenwachs und alte Bücher: das Haus des Ältesten.", "Candle wax and old books: the elder's house."),
            l("Aldric stützt sich auf seinen Stock, als du eintrittst.", "Aldric leans on his staff as you step in."),
            l("Du klopfst und trittst ein. Im Herd glimmt noch Glut.", "You knock and step inside. Embers still glow in the hearth."),
        ),
        "shop" to listOf(
            l("Du suchst Thessa in ihrem Kramladen auf.", "You call on Thessa in her store."),
            l("Es riecht nach Leder, Öl und Staub.", "It smells of leather, oil and dust."),
            l("Die Türglocke schlägt an. Thessa sieht von ihrer Ware auf.", "The door bell rings. Thessa looks up from her wares."),
            l("Zwischen Kisten und Regalen wartet Thessa auf Kundschaft.", "Between crates and shelves, Thessa waits for customers."),
            l("Du trittst in Thessas Laden. Hier hat alles seinen Preis.", "You step into Thessa's store. Everything here has its price."),
        ),
        "inn" to listOf(
            l("Du betrittst den Schlafenden Greif. Wärme und Bierdunst schlagen dir entgegen.",
                "You enter the Sleeping Griffin. Warmth and the reek of ale wash over you."),
            l("Die Gespräche verstummen kurz, als du eintrittst.", "Talk falls silent for a moment as you step in."),
            l("Am Herd knackt das Feuer.", "The fire crackles in the hearth."),
            l("Du suchst Zuflucht im Schlafenden Greif.", "You seek shelter in the Sleeping Griffin."),
            l("Es riecht nach Eintopf und nassem Holz.", "It smells of stew and wet wood."),
        ),
        "temple" to listOf(
            l("Du betrittst den Tempel des Morgenlichts. Kerzen flackern vor dem Altar.",
                "You enter the Temple of the Dawnlight. Candles flicker before the altar."),
            l("Stille umfängt dich.", "Silence enfolds you."),
            l("Kühler Stein, warmes Kerzenlicht.", "Cool stone, warm candlelight."),
            // 24: no pillars in this temple (13q.9), the steps echo between the pews
            l("Deine Schritte hallen zwischen den Bänken.", "Your steps echo between the pews."),
            l("Du suchst Trost im Tempel des Morgenlichts.", "You seek comfort in the Temple of the Dawnlight."),
            l("Der Altar wirkt leer, seit das Sonnenamulett fehlt.", "The altar looks bare since the Sun Amulet was taken.",
                needs = Story.QUEST_STARTED, without = Story.LYRA_RESCUED),
        ),
    )

    /** The first line before a fight, by how it begins (Jerry, 24.7). */
    val openings: Map<Start, List<T>> = emptyMap()

    /** The third line before a fight, by monster id (Jerry, 24.7): on a normal start, and always for a boss. */
    val foes: Map<String, List<T>> = emptyMap()

    /** The lines for entering [mapId] that fit now. */
    fun placeLines(mapId: String, state: GameState, isNight: Boolean): List<T> =
        places[mapId].orEmpty().filter { it.fits(state, isNight) }.let { all ->
            // at night the night's own lines come first in the draw, but the others stay possible
            val own = all.filter { it.night == true }
            if (own.isNotEmpty()) own.map { it.text } + own.map { it.text } + all.filter { it.night == null }.map { it.text }
            else all.map { it.text }
        }

    /** One of [lines] chosen at random, never [last] again unless there is nothing else; null when [lines] is empty. */
    fun pick(lines: List<T>, last: T?, random: Random = Random): T? {
        val choice = lines.filter { it != last }.ifEmpty { lines }
        return if (choice.isEmpty()) null else choice[random.nextInt(choice.size)]
    }
}
