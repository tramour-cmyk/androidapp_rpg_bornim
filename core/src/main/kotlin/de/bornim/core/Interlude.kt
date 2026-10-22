package de.bornim.core

import kotlin.random.Random

/**
 * The words on the black screen between two places and before a fight (24, draft in docs/DESIGN-BLENDE.md):
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
    val openings: Map<Start, List<T>> = mapOf(
        Start.AMBUSH to listOf(
            T("Ein Hinterhalt!", "An ambush!"),
            T("Zu spät hörst du das Rascheln.", "Too late, you hear the rustle."),
            T("Etwas hat auf dich gewartet.", "Something was waiting for you."),
            T("Ein Schatten löst sich aus dem Dunkel.", "A shadow breaks away from the dark."),
            T("Du bist in einen Hinterhalt geraten.", "You have walked into an ambush."),
            // 290 (Homer 21.10., [24.kampf.hinterhalt.6]–.11)
            T("Du spürst den Blick, bevor du ihn siehst.", "You feel the stare before you see it."),
            T("Es war die ganze Zeit hinter dir.", "It was behind you all along."),
            T("Die Stille war eine Falle.", "The silence was a trap."),
            T("Kein Laut. Dann ist es da.", "Not a sound. Then it is there."),
            T("Zu nah, um noch auszuweichen.", "Too close to dodge."),
            T("Ein Geräusch in deinem Rücken. Du drehst dich zu langsam um.", "A sound at your back. You turn too slowly."),
        ),
        Start.HERO_FIRST to listOf(
            T("Es hat dich nicht kommen sehen.", "It never saw you coming."),
            T("Lautlos schließt du auf. Jetzt!", "Silently, you close in. Now!"),
            T("Dein Gegner ahnt nichts.", "Your foe suspects nothing."),
            T("Du greifst an, bevor dein Gegner sich umdreht.", "You strike before your foe can turn."),
            T("Du schlägst zuerst zu.", "You strike first."),
            // 290 ([24.kampf.erstschlag.6]–.11)
            T("Du siehst es zuerst.", "You see it first."),
            T("Es ist abgelenkt. Ein Fehler.", "It is distracted. A mistake."),
            T("Ein Atemzug Vorsprung. Nutze ihn.", "One breath ahead. Use it."),
            T("Es kehrt dir den Rücken zu.", "It turns its back on you."),
            T("Noch hat es dich nicht gehört.", "It has not heard you yet."),
            T("Du bist schneller.", "You are faster."),
        ),
        Start.NORMAL to listOf(
            T("Etwas stellt sich dir in den Weg.", "Something blocks your way."),
            T("Es hat dich bemerkt.", "It has noticed you."),
            T("Kein Ausweg. Zieh die Waffe.", "No way out. Draw your weapon."),
            T("Ihr seht euch an. Dann bricht es los.", "You stare at each other. Then it begins."),
            T("Ein Kampf steht bevor.", "A fight is coming."),
            // 290 ([24.kampf.normal.6]–.11)
            T("Kein Zurück mehr.", "No turning back now."),
            T("Es hebt den Kopf. Es hat dich gesehen.", "It raises its head. It has seen you."),
            T("Jetzt gilt es.", "This is it."),
            T("Dein Herz schlägt schneller.", "Your heart beats faster."),
            T("Der Weg ist versperrt.", "The way is barred."),
            T("Es lässt dich nicht vorbei.", "It will not let you pass."),
        ),
        // the pack's size and kind stay in the battle text, these lines fit wolves and kobolds alike
        Start.PACK to listOf(
            T("Du bist umzingelt.", "You are surrounded."),
            T("Sie kommen von allen Seiten.", "They come from every side."),
            T("Einer allein wäre kein Problem.", "One alone would be no trouble."),
            T("Sie ziehen den Kreis enger.", "They draw the circle tighter."),
            T("Mehr Augen im Dunkel, als dir lieb ist.", "More eyes in the dark than you would like."),
            // 290 ([24.kampf.rudel.6]–.11)
            T("Wo einer ist, sind andere.", "Where there is one, there are others."),
            T("Sie verteilen sich. Keiner will der Erste sein.", "They spread out. None wants to be first."),
            T("Zu viele für einen Fehler.", "Too many for a single mistake."),
            T("Sie warten, bis einer losschlägt.", "They wait for one to strike."),
            T("Sie schneiden dir den Rückweg ab.", "They cut off your way back."),
            T("Ein Ruf, dann antworten andere.", "One call, and others answer."),
        ),
    )

    /** The third line before a fight, by monster id (Jerry, 24.7): on a normal start, and always for a boss. */
    val foes: Map<String, List<T>> = mapOf(
        "goblin" to listOf(
            T("Gelbe Augen, schiefe Zähne, schartiges Eisen.", "Yellow eyes, crooked teeth, notched iron."),
            T("Der Goblin kreischt und stürzt auf dich zu.", "The goblin shrieks and rushes at you."),
            T("Es stinkt nach Rauch und ranzigem Fett.", "It reeks of smoke and rancid fat."),
            T("Er grinst. Ihm fehlt die Hälfte seiner Zähne.", "He grins. Half his teeth are missing."),
            T("Klein, flink und voller Hass.", "Small, quick and full of hate."),
        ),
        "goblin_archer" to listOf(
            T("Ein Pfeil zischt an deinem Ohr vorbei.", "An arrow hisses past your ear."),
            T("Er hat dich schon lange beobachtet.", "He has been watching you for a long time."),
            T("Irgendwo spannt sich eine Bogensehne.", "Somewhere, a bowstring draws taut."),
            T("Leise wie ein Schatten, tödlich aus der Ferne.", "Quiet as a shadow, deadly from afar."),
            T("Er ist allein, oder will dich das glauben lassen.", "He is alone, or wants you to believe so."),
        ),
        "goblin_shaman" to listOf(
            T("Knochen klappern an seinem Stab.", "Bones rattle on his staff."),
            T("Er malt ein Zeichen in die Luft.", "He traces a sign in the air."),
            T("Aus seinen Beuteln kriecht beißender Rauch.", "Acrid smoke creeps from his pouches."),
            T("Er murmelt Worte, die nicht für Menschenohren gemacht sind.", "He mutters words not made for human ears."),
            T("Seine Augen glimmen, als er die Hände hebt.", "His eyes smoulder as he raises his hands."),
        ),
        "wolf" to listOf(
            T("Ein tiefes Knurren aus dem Dunkel.", "A deep growl from the dark."),
            T("Gelbe Augen im Halbdunkel.", "Yellow eyes in the gloom."),
            T("Speichel tropft von seinen Lefzen.", "Drool drips from his jowls."),
            T("Ausgehungert und ohne Furcht.", "Starved and without fear."),
            T("Er hat deine Witterung aufgenommen.", "He has caught your scent."),
        ),
        "giant_rat" to listOf(
            T("Ein Quieken, dann scharrende Krallen.", "A squeal, then scrabbling claws."),
            T("Fett, räudig und so groß wie ein Hund.", "Fat, mangy and as big as a dog."),
            T("Ihr nackter Schwanz peitscht durch den Dreck.", "Its naked tail lashes through the dirt."),
            T("Rote Augen, gelbe Nagezähne.", "Red eyes, yellow gnawing teeth."),
            T("Sie riecht dein Blut, bevor sie dich sieht.", "It smells your blood before it sees you."),
        ),
        "giant_spider" to listOf(
            T("Fäden kleben an deinem Gesicht. Zu spät.", "Threads cling to your face. Too late."),
            T("Acht Augen glänzen über dir.", "Eight eyes glisten above you."),
            T("Ihre Beine tasten nach dir, lautlos und schnell.", "Its legs reach for you, silent and fast."),
            T("In einem Netz, dick wie ein Tau, regt sich etwas.", "In a web as thick as rope, something stirs."),
            T("Gift glänzt an ihren Kieferklauen.", "Venom glistens on its fangs."),
        ),
        "skeleton" to listOf(
            T("Knochen klappern. Etwas Totes erhebt sich.", "Bones rattle. Something dead rises."),
            T("In leeren Augenhöhlen glimmt ein kaltes Licht.", "A cold light glimmers in empty sockets."),
            T("Rostiges Eisen in knöchernen Händen.", "Rusted iron in bony hands."),
            T("Es kennt keinen Schmerz und keine Gnade.", "It knows no pain and no mercy."),
            T("Der Tod hat es nicht behalten wollen.", "Death did not care to keep it."),
        ),
        "zombie" to listOf(
            T("Der Gestank erreicht dich vor ihm.", "The stench reaches you before it does."),
            T("Fauliges Fleisch, schlurfende Schritte.", "Rotting flesh, shuffling steps."),
            T("Es stöhnt. Es hungert.", "It moans. It hungers."),
            T("Was einmal ein Mensch war, kommt auf dich zu.", "What was once a man comes towards you."),
            T("Langsam und unaufhaltsam greifen seine Hände nach dir.", "Slow and relentless, its hands reach for you."),
        ),
        "boar" to listOf(
            T("Borsten gesträubt, die Hauer gesenkt.", "Bristles raised, tusks lowered."),
            T("Es schnaubt und scharrt mit den Hufen.", "It snorts and paws the ground."),
            T("Schwer, wütend und nicht aufzuhalten.", "Heavy, furious and unstoppable."),
            T("Blut klebt an seinen Hauern. Nicht seines.", "Blood clings to its tusks. Not its own."),
            T("Es bricht durchs Unterholz, direkt auf dich zu.", "It crashes through the undergrowth, straight at you."),
        ),
        "stirge" to listOf(
            T("Ein Sirren, dann ein Stich wie von einer glühenden Nadel.", "A whine, then a sting like a red-hot needle."),
            T("Ledrige Flügel, ein Rüssel wie ein Dorn.", "Leathery wings, a proboscis like a thorn."),
            T("Sie hat Blut gerochen. Deins.", "It has smelled blood. Yours."),
            T("Ihr Rüssel ist noch rot vom letzten Opfer.", "Its proboscis is still red from its last victim."),
            T("Klein, flatternd und unersättlich.", "Small, fluttering and insatiable."),
        ),
        "giant_centipede" to listOf(
            T("Zu viele Beine, viel zu schnell.", "Too many legs, far too fast."),
            T("Sein Panzer glänzt wie nasses Öl.", "Its shell gleams like wet oil."),
            T("Er windet sich aus einer Ritze, länger als dein Arm.", "It coils out of a crack, longer than your arm."),
            T("Gift tropft von seinen Kieferzangen.", "Venom drips from its mandibles."),
            T("Ein Rascheln unter dem Laub, dann schnellt er hervor.", "A rustle under the leaves, then it lunges."),
        ),
        "kobold" to listOf(
            T("Schuppen, Zähne und ein Speer, fast so groß wie er selbst.", "Scales, teeth and a spear almost as tall as he is."),
            T("Er zischt etwas in einer Sprache aus Knurren und Klicken.", "He hisses something in a tongue of growls and clicks."),
            T("Wo ein Kobold ist, ist eine Falle nicht weit.", "Where there is a kobold, a trap is never far."),
            T("Klein und feige, doch seine Speerspitze ist scharf.", "Small and cowardly, but his spearhead is sharp."),
            T("Seine Augen glühen rot im Halbdunkel.", "His eyes glow red in the gloom."),
        ),
        "giant_bat" to listOf(
            T("Flügel schlagen dir ins Gesicht.", "Wings beat against your face."),
            T("Ein schriller Schrei, den du mehr spürst als hörst.", "A shrill cry you feel more than hear."),
            T("Sie stürzt aus der Dunkelheit herab.", "It swoops down out of the darkness."),
            T("Flügel so breit wie ein Mann groß, Zähne wie Nadeln.", "Wings as wide as a man is tall, teeth like needles."),
            T("Sie sieht dich nicht. Sie hört dich.", "It does not see you. It hears you."),
        ),
        "ghoul" to listOf(
            T("Graue Haut, lange Krallen, ein Maul voller Grabmoder.", "Grey skin, long claws, a mouth full of grave rot."),
            T("Er hockt über etwas, das einmal ein Mensch war. Jetzt sieht er dich.",
                "He crouches over something that was once a man. Now he sees you."),
            T("Seine Klauen sind schwarz von Leichengift.", "His claws are black with corpse poison."),
            T("Er kichert, ein nasses, gieriges Geräusch.", "He giggles, a wet and greedy sound."),
            T("Der Hunger in seinen Augen ist älter als der Tod.", "The hunger in his eyes is older than death."),
        ),
        "ochre_jelly" to listOf(
            T("Der Boden bewegt sich. Es ist kein Boden.", "The floor moves. It is not the floor."),
            T("Eine gelbe Masse kriecht auf dich zu, der Stein darunter zischt.", "A yellow mass creeps towards you, the stone beneath it hisses."),
            T("Knochen schwimmen in ihrem Inneren.", "Bones float inside it."),
            T("Es riecht nach Säure und verdautem Fleisch.", "It smells of acid and digested flesh."),
            T("Sie hat keine Augen und findet dich trotzdem.", "It has no eyes, and finds you all the same."),
        ),
        "bugbear" to listOf(
            T("Sein Morgenstern ist schwarz von altem Blut.", "His morningstar is black with old blood."),
            T("Der Boden bebt unter seinen Schritten.", "The ground shakes under his steps."),
            T("Krogg lacht. Es klingt wie Steinschlag.", "Krogg laughs. It sounds like a rockfall."),
            T("„Noch einer“, brummt Krogg und hebt den Morgenstern.", "\"Another one,\" Krogg grunts and raises his morningstar."),
            T("Er füllt den ganzen Weg aus.", "He fills the whole path."),
        ),
        // the hall and the priestess: Grak is only met in his hall and only while Lyra is his prisoner
        // (Story: Lyra is freed after he falls; only the test menu brings him back later)
        "hobgoblin_captain" to listOf(
            T("Hauptmann Grak erwartet dich in seiner Halle.", "Captain Grak awaits you in his hall."),
            T("Graks Kriegsaxt fängt das Feuerlicht.", "Grak's war axe catches the firelight."),
            T("Die Goblins weichen zurück, als er vortritt.", "The goblins fall back as he steps forward."),
            T("Aus dieser Halle ist lange niemand lebend hinausgegangen.", "No one has left this hall alive in a long time."),
            T("„Du kommst wegen der Priesterin?“ Grak grinst.", "\"You've come for the priestess?\" Grak grins."),
        ),
        "dire_wolf" to listOf(
            T("Narben ziehen sich über seine Schnauze.", "Scars run across his muzzle."),
            T("Das Rudel verstummt. Grimmzahn tritt vor.", "The pack falls silent. Grimfang steps forward."),
            T("Größer als jeder Wolf, den du je gesehen hast.", "Bigger than any wolf you have ever seen."),
            T("Ein Heulen, dann Stille. Er hat dich gefunden.", "A howl, then silence. He has found you."),
            T("Grimmzahn umkreist dich. Er hat Zeit.", "Grimfang circles you. He has time."),
        ),
    )

    /** The lines for entering [mapId] that fit now. */
    fun placeLines(mapId: String, state: GameState, isNight: Boolean): List<T> =
        places[mapId].orEmpty().filter { it.fits(state, isNight) }.let { all ->
            // at night the night's own lines come first in the draw, but the others stay possible
            val own = all.filter { it.night == true }
            if (own.isNotEmpty()) own.map { it.text } + own.map { it.text } + all.filter { it.night == null }.map { it.text }
            else all.map { it.text }
        }

    /** 24.6: the words before a fight: the first line ([start]), and a line of the foe's own ([foe]) or null. */
    data class FightWords(val start: T, val foe: T?)

    /** How a fight that opens with [opening] begins on the screen: a pack or troop met face to face has its own lines. */
    fun startFor(opening: Opening, pack: Boolean): Start = when (opening) {
        Opening.AMBUSHED -> Start.AMBUSH
        Opening.HERO_FIRST -> Start.HERO_FIRST
        Opening.NORMAL -> if (pack) Start.PACK else Start.NORMAL
    }

    /**
     * 24.6 (docs/DESIGN-BLENDE.md 7): the first line by how the fight begins, never [last] again; the foe's own line on a
     * face-to-face start ([Start.NORMAL], [Start.PACK]) while the screen waits ([full]), against a boss always, never [lastFoe] again.
     */
    fun fightWords(opening: Opening, pack: Boolean, foeId: String, boss: Boolean, full: Boolean,
        last: T? = null, lastFoe: T? = null, random: Random = Random): FightWords {
        val st = startFor(opening, pack)
        val start = pick(openings.getValue(st), last, random)!!
        val own = boss || (full && (st == Start.NORMAL || st == Start.PACK))
        return FightWords(start, if (own) pick(foes[foeId].orEmpty(), lastFoe, random) else null)
    }

    /** 267.1T: a saying on the long black screen, [who] small below it. */
    data class Quote(val id: String, val text: T, val who: T)

    private fun q(id: String, de: String, en: String, whoDe: String, whoEn: String) = Quote(id, T(de, en), T(whoDe, whoEn))

    /** 267.1T (docs/STORY-BLENDE.md `[267.1T.…]`, Chef 21.10.: „267.1T passt“): one on each long screen, Aldric's first. */
    val quotes: List<Quote> = listOf(
        q("aldric", "„Hundert Jahre hat es über uns gewacht. Man vergisst, wie dunkel eine Nacht sein kann.“",
            "“For a hundred years it watched over us. One forgets how dark a night can be.”", "Ältester Aldric", "Elder Aldric"),
        q("rowena", "„Wer bei mir den Krug leert, zahlt. Wer bei mir weint, zahlt nicht.“",
            "“Who empties a mug with me, pays. Who weeps with me, does not.”", "Rowena, Wirtin im Schlafenden Greif", "Rowena, landlady of the Sleeping Griffin"),
        q("garrick", "„Bleib auf dem Weg. Der Wald merkt sich, wer ihn verlässt.“",
            "“Stay on the path. The forest remembers who leaves it.”", "Garrick, Jäger", "Garrick, hunter"),
        q("morwen", "„Jedes Kraut heilt. Die Frage ist nur, wen.“",
            "“Every herb heals. The only question is whom.”", "Morwen, Kräuterfrau", "Morwen, herbwife"),
        q("borin", "„Ein guter Hammer braucht keinen klugen Schmied. Aber es hilft.“",
            "“A good hammer needs no clever smith. But it helps.”", "Borin, Zwerg, am Tisch im Greif", "Borin, dwarf, at a table in the Griffin"),
        q("jorin", "„Der Schlagbaum ist nur ein Balken. Halten tut ihn der, der davorsteht.“",
            "“The barrier is only a beam. What holds it is the one who stands before it.”", "Wache Jorin", "Guard Jorin"),
        q("osric", "„Licht muss man nicht verteidigen. Man muss es nur weitertragen.“",
            "“Light need not be defended. It only needs to be carried on.”", "Bruder Osric, Tempel des Morgenlichts", "Brother Osric, Temple of the Dawnlight"),
        q("lyra", "„Ich habe geträumt, das Licht ginge aus. Ich wünschte, ich hätte es niemandem erzählt.“",
            "“I dreamt the light went out. I wish I had told no one.”", "Schwester Lyra", "Sister Lyra"),
        q("thessa", "„Alles hat seinen Preis. Gute Ware sogar einen gerechten.“",
            "“Everything has its price. Good wares even a fair one.”", "Thessa, Kramladen", "Thessa, General Store"),
        q("pim", "„Wenn ich groß bin, gehe ich durch den ganzen Wald. Bis ans Ende. Und wieder zurück.“",
            "“When I'm grown, I'll walk through the whole forest. To the very end. And back again.”", "Pim", "Pim"),
        q("bram", "„Der Boden lügt nicht. Wer sät, der erntet, wenn man ihn lässt.“",
            "“The soil does not lie. Who sows will reap, if he is let.”", "Bauer Bram", "Farmer Bram"),
        q("liska", "„Ich weiß ja gar nichts. Aber Rowena sagt …“",
            "“I don't know anything, really. But Rowena says …”", "Liska, Magd", "Liska, maid"),
        q("kael", "„Jede Laterne geht einmal aus. Die Frage ist, wer sie wieder anzündet.“",
            "“Every lantern goes out one day. The question is who lights it again.”", "Der alte Kael", "Old Kael"),
        q("edrik", "„Ich mach nicht auf. Für niemanden.“",
            "“I'm not opening. Not for anyone.”", "Bäcker Edrik", "Edrik the Baker"),
        q("grak", "„Feiglinge sind auch Krieger. Man muss sie nur laut genug anbrüllen.“",
            "“Cowards are warriors too. You just have to roar at them loud enough.”", "Hauptmann Grak, Blutzahn-Stamm", "Captain Grak, Bloodfang tribe"),
        q("rudel", "„Das Rudel folgt nicht dem Stärksten. Es folgt dem, der zuerst springt.“",
            "“The pack does not follow the strongest. It follows the one who leaps first.”", "Jägerspruch aus Bornim", "Hunters' saying from Bornim"),
    )

    /** 267.1T: the saying for a long screen: Aldric's when none was ever shown ([last] null), else never [last] again. */
    fun quoteFor(last: String?, random: Random = Random): Quote =
        if (last == null) quotes.first() else quotes.filter { it.id != last }.let { it[random.nextInt(it.size)] }

    /** One of [lines] chosen at random, never [last] again unless there is nothing else; null when [lines] is empty. */
    fun pick(lines: List<T>, last: T?, random: Random = Random): T? {
        val choice = lines.filter { it != last }.ifEmpty { lines }
        return if (choice.isEmpty()) null else choice[random.nextInt(choice.size)]
    }
}
