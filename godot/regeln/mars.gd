# 348.7 (Umzug Godot): MARS, the new fight, ported line for line from core Skirmish.kt (main, Build 88).
# Same rules, same order of dice, same lines: godot/tests/mars_golden.gd replays fights recorded in the Kotlin core
# and compares every message. What a figure brings comes as a sheet (the hero's derived numbers, a monster's id);
# working those numbers out of race, class and gear is the hero's part of the port, not the fight's.
# Comments name the Vorgänge as in Skirmish.kt; the reasons stand there.
extends RefCounted

const Wuerfel = preload("res://regeln/wuerfel.gd")
const X = preload("res://regeln/mars_texte.gd")
const Zustaende = preload("res://regeln/zustaende.gd")
const BrsKampf = preload("res://regeln/brs_kampf.gd")
## 555 Testmenue „Kampfhilfen“ wie alt (Battle.heroCritsAlways, foesFailSaves), dazu „unsterblich“: der Held faellt nie unter 1 TP;
## von Hand an, sonst immer aus (die Gegenproben laufen ohne sie)
static var held_immer_krit := false
static var gegner_ohne_rettung := false
static var held_unsterblich := false
## 1020.2 C (Chef 12.11., 08:09; Vorlage 1020 C, nur Reiter Test): der nächste passende Gegnerzug wird erzwungen, dann gilt wieder
## der Zufall: „pounce“ Anspringen (Wölfe), „heavy“ Schwerer Hieb (Grak), „reihe“ ein Gegner der hinteren Reihe tauscht nach vorn,
## „flucht“ alle Gegner fliehen; [test_ausweichen]: der nächste Angriff auf den Helden geht fehl, er weicht aus (mit Schild: Abwehr)
static var test_gegnerzug := ""
static var test_ausweichen := false
static var test_erzwungen: Array = []     # was davon wirklich kam (tests/probekampf_1020.gd)
## The lines by name, for the ones picked in several wordings.
## 399.2b (Homer [399.2b.knurrt]): die Zeile im Zug, wenn ein Jungwolf nur knurrt; gibt es im alten MARS nicht, darum nicht in mars_texte.gd
## Battle.kt Msg.fed (399.2, satt)
const MSG399_FED := ["{0} ist gut gestärkt: trifft leichter und schlägt härter.", "{0} is well fed: lands blows more easily and hits harder."]     # [870.14.satt]
## 870.5 (870a 8 A): Schadensarten und die Zeilen beim ersten Treffer (Homer STORY-BRS-HELD.md [870.14.schwach], [870.14.stark],
## [870.14.immun]; Namen [870.14.namen], englisch im Satz klein)
const SCHADENSART := {"schnitt": ["Schnitt", "slash"], "stich": ["Stich", "pierce"], "wucht": ["Wucht", "crush"], "feuer": ["Feuer", "fire"],
	"gift": ["Gift", "poison"], "saeure": ["Säure", "acid"], "licht": ["Licht", "light"]}
const MSG870_SCHWACH := ["{0} ist verwundbar gegen {1}!", "{0} is vulnerable to {1}!"]
const MSG870_STARK := ["{1} richtet bei {0} wenig aus.", "{1} does little against {0}."]
const MSG870_IMMUN := ["{1} prallt an {0} ab.", "{1} has no effect on {0}."]
## 870.5 (870a 8 A): Gegenwirkungen beim ersten Mal (Homer STORY-BRS-HELD.md [870.14.gegen.*])
const MSG870_GEGEN_WOLF := ["Die Wölfe weichen vor dem Feuer zurück, dann sind sie zwischen den Bäumen fort. Kein Fell, keine Erfahrung.",
	"The wolves shy from the fire, then they are gone among the trees. No pelt, no experience."]
const MSG870_GEGEN_SCHWEIN := ["Das Feuer macht {0} rasend.", "The fire drives {0} into a frenzy."]
const MSG870_GEGEN_SPINNE := ["Die Seide der Spinne verbrennt zu Asche.", "The spider's silk burns to ash."]     # [870.14.gegen.spinne]
const MSG870_GEGEN_FLUEGER := ["{0} wittert dein Blut und saugt gieriger.", "{0} smells your blood and feeds more greedily."]
const MSG870_GEGEN_ZOMBIE := ["{0} zerfällt. Diesmal steht er nicht wieder auf.", "{0} crumbles. This time it does not rise again."]
const MSG870_GEGEN_SCHLEIM := ["Der Schleim teilt sich.", "The slime splits in two."]
## [870.14.kraft.schoepfen]
const MSG870_KRAFT := ["{0} schöpft Kraft: +{1} TP.", "{0} draws strength: +{1} HP."]
## 840 (830 A, Chef 10.11., 11:00; 210 B): Eingebung des Helden beim ersten Auftreten einer Ansage, einmal je Spielstand (gesehen),
## im Kampfbericht direkt nach der Ansage; Wolfssprung [830.sprung]. 986 (Homer, STORY-BRS-KAMPF.md „Eingebungen der Ansagen (986)“):
## heavy, call, shadow im Wortlaut [210T.*.eingebung] (STORY-SPIEL.md), die übrigen [986.*]; bite und claw ohne Eingebung.
## Knurren hat keine Ansage (_say_announce): seine Eingebung steht nach der ersten Zeile MSG399_GROWLS (_foe_turn)
const EINGEBUNG := {"pounce": ["Er will springen. Stehe ich nicht mehr dort, wohin er springt, schnappt er ins Leere. Wechsel, und mir bleibt noch ein halber Zug.",
	"It means to leap. If I no longer stand where it leaps, it snaps at nothing. Switch, and I still have half a turn."],
	"heavy": ["Er holt zu weit aus. Treffe ich ihn jetzt hart, kommt er aus dem Tritt.",     # [210T.heavy.eingebung]
		"He winds up too far. If I hit him hard now, he loses his footing."],
	"call": ["Er ruft Hilfe. Die halte ich nicht auf, aber ihn kann ich treffen, solange er brüllt.",     # [210T.call.eingebung]
		"He calls for help. That I cannot stop, but I can hit him while he roars."],
	"shadow": ["Er sucht das Dunkel. Ein Kratzer jetzt, und er bleibt sichtbar.",     # [210T.shadow.eingebung]
		"He seeks the dark. A scratch now, and he stays in sight."],
	"stab": ["Nur ein Stich. Meist lohnt mein eigener Schlag mehr als die Abwehr.",     # [986.stab]
		"Just a stab. My own blow is usually worth more than a Defend."],
	"slash": ["Nur ein Hieb. Meist lohnt mein eigener Schlag mehr als die Abwehr.",     # [986.hieb]
		"Just a slash. My own blow is usually worth more than a Defend."],
	"flank": ["Er will hintenrum. Ein Kratzer hält ihn auf, ein Wechsel der Reihe auch.",     # [986.flank]
		"He means to go around. A scratch stops him, and so does switching rows."],
	"circle": ["Der da ruft das Rudel zusammen. Den treffen, egal wie leicht.",     # [986.circle]
		"That one calls the pack together. Hit it, however lightly."],
	"growl": ["Der hier hält sich zurück. Erst den Leitwolf treffen.",     # [986.growl]
		"This one holds back. Hit the lead wolf first."],
	"web": ["Das Netz fliegt langsam. Nur wer den Moment genau trifft, bleibt frei.",     # [986.web]
		"The web flies slowly. Only perfect timing keeps you free."],
	"gather": ["Er holt Luft. Jetzt nachsetzen, sonst kommt er wieder zu Kräften.",     # [986.gather]
		"He is catching his breath. Press now, or he regains his strength."],
	"breakthrough": ["Er will durch die Reihe. Tritt der Bedrohte vorher selbst nach vorn, bleibt Grak nur ein einfacher Schlag.",     # [986.breakthrough]
		"He means to break the line. If the threatened one steps forward first, Grak is left with a plain blow."],
	"venom": ["Gegen den Giftbiss hilft kein Ring. Treffe ich sie vorher hart, versiegt das Gift.",     # [986.venom]
		"No ring helps against the venom bite. If I hit her hard first, the venom dries up."],
	"aim": ["Er legt an. Geht der Anvisierte in Abwehr, duckt er sich, und der Pfeil geht vorbei.",     # [986.aim]
		"He takes aim. If the one in his sights Defends, the arrow flies past."]}
const GESEHEN_EINGEBUNG := "eingebung_"     # + Ansage, Flagge im Spielstand (Zustand.flaggen über Kampfort.flaggen, 836)
## 836, 840: Flaggen des Spielstands (dasselbe Dictionary wie Zustand.flaggen; Proben leer, je Kampf neu)
var gesehen := {}
const MSG399_GROWLS := [["{0} knurrt, wagt aber keinen Biss.", "{0} snarls but dares no bite."],
	["{0} duckt sich und fletscht die Zähne, kommt aber nicht heran.", "{0} crouches and bares its teeth, but does not come in."],
	["{0} knurrt und hält Abstand.", "{0} growls and keeps its distance."]]
var TX: Dictionary = load("res://regeln/mars_texte.gd").get_script_constant_map().merged({"MSG399_GROWLS": MSG399_GROWLS, "MSG547_AUF": MSG547_AUF, "MSG547_STOSS": MSG547_STOSS,
	"MSG702_AUF": MSG702_AUF, "MSG702_RISES": MSG702_RISES})
## 547 (Chef 04.11., 00:01; 05.11., 19:2x: „Held geht zu Boden (Text) -> keine entsprechende Animation“): solange der Sturz 438a
## eingefroren ist und das Bild nur zusammenzuckt, Homers Zwischenfassungen [547.auf] und [547.wolf.sprung.stoss] (STORY-SPIEL.md)
## statt „steht wieder auf“ und „geht zu Boden“; danach sturz_zwischentext = false (die alten Zeilen, wie mars_golden)
const MSG547_AUF := [["{0} fängt sich wieder: Zug verloren.", "{0} recovers: turn lost."],
	["{0} atmet durch und steht wieder fest: Zug verloren.", "{0} draws a breath and stands firm again: turn lost."],
	["{0} schüttelt den Stoß ab: Zug verloren.", "{0} shakes off the impact: turn lost."]]
const MSG547_STOSS := [["{0} springt {1} an. {1} wird zurückgestoßen.", "{0} leaps at {1}. {1} is shoved back."],
	["{0} prallt gegen {1}. {1} kommt aus dem Gleichgewicht.", "{0} slams into {1}. {1} is knocked off balance."],
	["{0} wirft sich auf {1}. {1} hält dem Gewicht kaum stand.", "{0} throws itself at {1}. {1} barely withstands the weight."]]
var sturz_zwischentext := true
## 702 C: Aufstehen ohne Zugverlust, Homers Zeilen [702.auf] und [702.auf.sturz] (STORY-SPIEL.md, 712)
const MSG702_AUF := [["{0} fängt sich wieder.", "{0} recovers."],
	["{0} atmet durch und steht wieder fest.", "{0} draws a breath and stands firm again."],
	["{0} schüttelt den Stoß ab, ohne einen Schritt zu weichen.", "{0} shakes off the impact without giving ground."]]
const MSG702_RISES := [["{0} stützt sich ab und kommt wieder hoch.", "{0} pushes up and gets back to their feet."],
	["{0} atmet durch und steht wieder auf.", "{0} draws a breath and gets up again."],
	["{0} rappelt sich auf, an Ort und Stelle.", "{0} scrambles up where they fell."]]

const FRONT := 0
const BACK := 1
const SPOTS := [Vector2i(FRONT, 0), Vector2i(FRONT, 1), Vector2i(BACK, 0), Vector2i(BACK, 1)]

const GRAK := "hobgoblin_captain"
const CALLED := "goblin"
const SCOUT := "goblin_archer"
const WOLF := "wolf"
const DIRE_WOLF := "dire_wolf"     # 533: Grimmzahn, Art eigen, Regeln des Rudels wie der Wolf
const SPIDER := "giant_spider"
## 535 (Abgleich 512, Sokrates): Arten mit eigenen Regeln im Körper einer anderen (aufruf.gd ART): Ratte und Fledermaus bewegen
## sich als Wolf, Kobold und Schamane als Goblin. 577 (Chef 04.11., 21:00: „Wie wär's denn, wenn die Dinger die Kennung kriegen, die
## sie verdienen?“): die id ist die eigene Art (Regeln, Texte, Klang, Lohn), „koerper“ nur Modell und Bewegung (koerper_of)
const RAT := "giant_rat"
const BAT := "giant_bat"
const KOBOLD := "kobold"
const SHAMAN := "goblin_shaman"
## 535 (alt Battle.kt Msg.flutters, EVASIVE): die Riesenfledermaus weicht einem Nahkampfhieb zu 20 % flatternd aus
const MSG535_FLUTTERS = ["{0} flattert davon – daneben!", "{0} flutters away – a miss!"]
const FLUTTER := 0.2
## 534 (Abgleich 512, Sokrates: im alten Weltkampf Battle.kt, in MARS fehlend): Lebensraub und Schadensminderung der
## Ausrüstung, Unerbittlichkeit der Orkblütigen, Einschüchtern zu Kampfbeginn (Perks.cowChance); Wortlaut aus Battle.kt Msg
const MSG534_RELENTLESS = ["Letzter Atemzug: {0} bleibt stehen!", "Last Breath: {0} stays standing!"]     # [870.14.letzter.atemzug]
const MSG534_COWED = ["{0} zögert, eingeschüchtert von {1}!", "{0} hesitates, cowed by {1}!"]
## 506 (alt Battle.kt Msg.fortitude, Msg.elfImmune): Untotenzähigkeit des Wiedergängers (Monsters.kt zombie UNDEAD_FORTITUDE: ein
## tödlicher Schlag ohne Krit, kein gleißender Schaden, W20 + Kon-Rettung ≥ 5 + Schaden, dann bleibt er mit 1 TP stehen) und die
## Lähmung des Grabhunds (ghoul PARALYZE: jeder Treffer betäubt eine Runde, Kon-Rettung 10; Elfen sind immun)
const MSG506_FORTITUDE = ["{0} weigert sich zu fallen!", "{0} refuses to fall!"]
const MSG506_ELF = ["Elfen sind gegen Lähmung immun – {0} bleibt unbeeindruckt.", "Elves are immune to paralysis – {0} is unaffected."]
const COW_PER_CHA := 0.08
const BREAK_SHARE := 5
## 296.2: the lines of the old fight, the same words in MARS (Skirmish.kt Msg296, Zweig claude/build-89).
const MSG296_STILLSURPRISED = ["{0} ist noch überrascht und kann nicht reagieren!", "{0} is still caught off guard!"]
const MSG296_FLED = ["{0} ist entkommen!", "{0} gets away!"]     # [870.14.flucht]
const MSG296_CANTFLEE = ["Die Flucht misslingt!", "The escape fails!"]
## 296.2: the statuses of the old fight (core Status.kt): name, short sign, colour of the sign.
const STATUS := {
	"POISON": [["Vergiftet", "Poisoned"], ["Gift", "Psn"], Color("6FB83A")],
	"BURN": [["Brennend", "Burning"], ["Brand", "Brn"], Color("E8701A")],
	"BLEED": [["Blutend", "Bleeding"], ["Blut", "Bld"], Color("C8283A")],
	"STUN": [["Betäubt", "Stunned"], ["Betäubt", "Stun"], Color("E0B020")],
	"SLOW": [["Verlangsamt", "Slowed"], ["Langsam", "Slow"], Color("4A90D8")],
	"WEAK": [["Geschwächt", "Weakened"], ["Schwach", "Weak"], Color("8A58C8")],
	"BLIND": [["Geblendet", "Blinded"], ["Blind", "Blind"], Color("6A6A7A")],
	# 532 (Metrausch wie alt, Battle.drunk, Status.DRUNK): aus der Welt bis zur Rast (aufruf.gd lage „betrunken“), endet nie im Kampf
	"DRUNK": [["Betrunken", "Drunk"], ["Betrunken", "Drunk"], Color("C89A3A")],
}
## 536: was ein Zustand bewirkt, wortgetreu aus Status.kt desc (der Tipp auf ein Zustandsschild im Kampf)
const STATUS_DESC := {
	"POISON": ["Schaden zu Beginn jeder Runde. Abwehr mit Zähigkeit.", "Damage at the start of each round. Resisted with Toughness."],     # [870.14.zustand.*]
	"BURN": ["Starker Schaden zu Beginn jeder Runde.", "Heavy damage at the start of each round."],
	"BLEED": ["Schaden jede Runde, Heilung nur halb so stark.", "Damage each round; healing is halved."],
	"STUN": ["Setzt die nächste Runde aus.", "Loses the next turn."],
	"SLOW": ["Trifft schlechter und weicht schlechter aus.", "Hits less often and dodges less well."],
	"WEAK": ["Trifft schlechter und macht weniger Schaden.", "Hits less often and deals less damage."],
	"BLIND": ["Angriffe mit Ungunst.", "Attacks at disfavor."],
	"DRUNK": ["Angriffe und Flucht mit Ungunst, bis zur nächsten Rast.", "Attacks and fleeing at disfavor, until your next rest."],
}
## A status that does not wear off by itself (Status.LASTING).
const LASTING := 99
## The lines of the old fight (Battle.kt StatusLines), the same words in MARS.
const ST_GAINED := {
	"POISON": ["{0} ist vergiftet!", "{0} is poisoned!"],
	"BURN": ["{0} fängt Feuer!", "{0} catches fire!"],
	"BLEED": ["{0} blutet!", "{0} is bleeding!"],
	"STUN": ["{0} ist betäubt!", "{0} is stunned!"],
	"SLOW": ["{0} ist verlangsamt!", "{0} is slowed!"],
	"WEAK": ["{0} ist geschwächt!", "{0} is weakened!"],
	"BLIND": ["{0} ist geblendet!", "{0} is blinded!"],
}
const ST_HURTS := {
	"POISON": ["Das Gift zehrt an {0}.", "The poison eats at {0}."],
	"BURN": ["{0} brennt!", "{0} burns!"],
	"BLEED": ["{0} verliert Blut.", "{0} loses blood."],
}
const ST_STUNNED := ["{0} ist betäubt und kann nicht handeln!", "{0} is stunned and can't act!"]
const ST_ENDS := ["{0} ist nicht mehr {1}.", "{0} is no longer {1}."]
const ST_SHRUGS := ["{0} widersteht der Wirkung!", "{0} resists the effect!"]
const ST_STEADFAST := ["{0} bleibt standhaft!", "{0} stands firm!"]
const ST_DWARF := ["Steinblut: {0} widersteht dem Gift!", "Stoneblood: {0} resists the poison!"]     # [870.14.steinblut]
const ST_SHAKES := ["{0} schüttelt die Betäubung ab!", "{0} shrugs off the stun!"]
const MSG296_DAMAGE := ["{0} Schaden.", "{0} damage."]
## 296.2: the kinds whose specials MARS plays through their own intents, not the old fight's.
const OWN_INTENTS := [GRAK, CALLED, SCOUT, WOLF, DIRE_WOLF, SPIDER]
const CALL_MAX := 1     # 870c 1 A: Grak ruft höchstens einen Goblin
const PROBE_LEVEL := 3

## Reaction: how well the attacked figure met the ring (72.11), with its share of the damage.
const NONE := "NONE"
const GOOD := "GOOD"
const PERFECT := "PERFECT"
const SHARE := {"NONE": 1.0, "GOOD": 0.5, "PERFECT": 0.0}

## Whom a move is aimed at (72.10a.3): 870.5 nur noch Zauber (ZAUBER_ZIEL) und Kampfhandlungen (HANDLUNG_ZIEL), ziel_von.

## 870.5 (870a 3 A, DESIGN-BRS.md 7): Kampfhandlungen hängen an Fertigkeiten (werte.json „handlungen“, Zahlen dort, A mit 444 Teil 7);
## frei ab dem Rang in „ab“, Kraft schöpfen für alle; Waffenhandlungen nur mit einer Waffe ihrer Gruppe in der Hand, Schildwall nur
## mit Schild. Kennung -> Name in werte.json; Namen im Spiel Homer [870.14.hand.*] (STORY-BRS-KOENNEN.md). Wehrhaltung ist nicht
## frei (444 Teil 7 ohne Wirkung, Chef entscheidet). Extra-Angriff, Doppelzug (ACTION_SURGE), Zweiwaffenkampf und die übrigen Klassenfähigkeiten
## entfallen.
const HANDLUNG := {
	"H_KRAFT": "Kraft schöpfen", "H_FINTE": "Finte", "H_HINTERHALT": "Stich aus dem Hinterhalt", "H_WUCHT": "Wuchtschlag",
	"H_ABSTAND": "Auf Abstand", "H_SCHAEDEL": "Schädelstoß", "H_GRIFF": "Griff", "H_SCHILDWALL": "Schildwall",
	"H_RUHIG": "Ruhige Hand", "H_DURCH": "Durchschlag", "H_ZWEI": "Zwei auf einmal",
}
const HANDLUNG_NAME := {
	"H_KRAFT": ["Kraft schöpfen", "Draw Strength"], "H_FINTE": ["Finte", "Feint"], "H_HINTERHALT": ["Stich aus dem Hinterhalt", "Ambush Stab"],
	"H_WUCHT": ["Wuchtschlag", "Crushing Swing"], "H_ABSTAND": ["Auf Abstand", "Hold at Bay"], "H_SCHAEDEL": ["Schädelstoß", "Skull Knock"],
	"H_GRIFF": ["Griff", "Grapple"], "H_SCHILDWALL": ["Schildwall", "Shield Wall"], "H_RUHIG": ["Ruhige Hand", "Steady Hand"],
	"H_DURCH": ["Durchschlag", "Punch Through"], "H_ZWEI": ["Zwei auf einmal", "Double Throw"],
}
## 870.5 (DESIGN-BRS.md 4, 12): Zauber nach dem BRS (werte.json „zauber“): Fertigkeit der Schule, Grundwert Wille, Kosten in Mana;
## bekannt sind die des Kampfblatts (Herkunft) und die, deren Schule „ab“ erreicht. Namen Homer [870.14.zauber.*]. Die alten Zauber
## der Klassen entfallen. FX: das Bild des alten Zaubers (zauber.gd), bis es eigene gibt.
const ZAUBER := {
	"Z_FUNKEN": "Funkenpfeil", "Z_ARKAN": "Arkanpfeil", "Z_STRAHLEN": "Glutstrahlen", "Z_FAECHER": "Flammenfächer", "Z_GLUT": "Glutkugel",
	"Z_HAUT": "Arkanhaut", "Z_BANN": "Bannschild", "Z_WUND": "Wundsegen", "Z_GLEISS": "Gleißstrahl", "Z_BEISTAND": "Beistand",
}
const ZAUBER_NAME := {
	"Z_FUNKEN": ["Funkenpfeil", "Spark Bolt"], "Z_ARKAN": ["Arkanpfeil", "Arcane Dart"], "Z_STRAHLEN": ["Glutstrahlen", "Ember Rays"],
	"Z_FAECHER": ["Flammenfächer", "Flame Fan"], "Z_GLUT": ["Glutkugel", "Ember Orb"], "Z_HAUT": ["Arkanhaut", "Arcane Skin"],
	"Z_BANN": ["Bannschild", "Ward"], "Z_WUND": ["Wundsegen", "Woundmend"], "Z_GLEISS": ["Gleißstrahl", "Glare Ray"], "Z_BEISTAND": ["Beistand", "Succor"],
}
const ZAUBER_ZIEL := {
	"Z_FUNKEN": "FOE", "Z_ARKAN": "FOE", "Z_STRAHLEN": "FOE", "Z_FAECHER": "ROW", "Z_GLUT": "ROW", "Z_HAUT": "SELF", "Z_BANN": "SELF",
	"Z_WUND": "ALLY", "Z_GLEISS": "FOE", "Z_BEISTAND": "SELF",
}
const ZAUBER_FX := {
	"Z_FUNKEN": "FIRE_BOLT", "Z_ARKAN": "MISSILES", "Z_STRAHLEN": "RAYS", "Z_FAECHER": "BURNING_HANDS", "Z_GLUT": "FIREBALL",
	"Z_HAUT": "BLESS", "Z_BANN": "BLESS", "Z_WUND": "HEAL", "Z_GLEISS": "SACRED_FLAME", "Z_BEISTAND": "BLESS",
}
const HANDLUNG_ZIEL := {
	"H_KRAFT": "SELF", "H_FINTE": "SELF", "H_RUHIG": "SELF", "H_SCHILDWALL": "SELF", "H_HINTERHALT": "FOE", "H_WUCHT": "FOE",
	"H_ABSTAND": "FOE", "H_SCHAEDEL": "FOE", "H_GRIFF": "FOE", "H_DURCH": "FOE", "H_ZWEI": "FOE",
}


static func _intent(id: String, de: String, en: String, kind := "STRIKE", extra = null, strong := false, ring := true,
		breakable := false, effect := "", break_any := false) -> Dictionary:
	return {"id": id, "name": [de, en], "kind": kind, "extra": extra, "strong": strong, "ring": ring,
		"breakable": breakable, "effect": effect, "break_any": break_any}


var I_HEAVY := _intent("heavy", "Schwerer Hieb", "Heavy blow", "STRIKE", [2, 6, 0], true, true, true)
var I_CALL := _intent("call", "Hilfe rufen", "Call for help", "CALL", null, false, false)     # Homer 899 [870.14.ansage.call]
var I_GATHER := _intent("gather", "Kraft sammeln", "Gather strength", "GATHER", null, false, false, true)
var I_STAB := _intent("stab", "Stich", "Stab", "STRIKE", null, false, false)
## 348.12 (Chef 27.10., 09:49; Homer [210T.hieb]): Goblin mit Krummsäbel oder Beil sagt „Hieb“ an; gewollte Abweichung vom alten MARS
var I_SLASH := _intent("slash", "Hieb", "Slash", "STRIKE", null, false, false)
## 535 (alt Monsters.kt giant_rat, giant_bat: Angriff „Biss“): Ratte und Fledermaus beißen nur, ohne Sprung und Einkreisen
var I_BITE := _intent("bite", "Biss", "Bite", "STRIKE", null, false, false)
## 506 (STORY-BLENDE.md „Wiedergänger“: Angriff Klauen / Claws; „Grabhund“: Biss / Bite)
var I_CLAW := _intent("claw", "Klauen", "Claws", "STRIKE", null, false, false)
var I_POUNCE := _intent("pounce", "Anspringen", "Pounce", "STRIKE", null, false, false, false, "POUNCE")
## 399.2b: ein Jungwolf knurrt nur, kein Angriff (Homer [210T.growl])
var I_GROWL := _intent("growl", "Knurren", "Growl", "WAIT", null, false, false, false, "GROWL")
var I_CIRCLE := _intent("circle", "Einkreisen", "Circle", "GATHER", null, false, false, false, "CIRCLE", true)
var I_VENOM := _intent("venom", "Gift sammeln", "Gather venom", "STRIKE", [2, 6, 0], true, false, true)
var I_WEB := _intent("web", "Netz werfen", "Throw web", "STRIKE", null, false, true, false, "WEB")     # 986 (4): EN wie [870.14.ansage.web]
var I_AIM := _intent("aim", "Anlegen", "Take aim", "STRIKE", [1, 6, 0], false, false, false, "AIM")
var I_SHADOW := _intent("shadow", "In den Schatten", "Into the shadows", "GATHER", null, false, false, false, "SHADOW", true)
var I_BREAKTHROUGH := _intent("breakthrough", "Durchbrechen", "Break through", "STRIKE", [1, 6, 0], false, true, true, "BREAKTHROUGH")
var I_FLANK := _intent("flank", "Flanke", "Flank", "STRIKE", null, false, false, false, "FLANK", true)

const NO_REAIM := ["BREAKTHROUGH", "FLANK", "CIRCLE", "POUNCE"]
const AT_TARGET := ["POUNCE", "AIM", "BREAKTHROUGH", "FLANK"]


## One figure: the hero, a Söldner or a foe. [hero] is the hero's sheet, [monster] the monster's table entry.
class Fighter:
	var id: String
	var side: String
	var place: Vector2i
	var hero = null
	var monster = null
	var max_hp: int
	var hp: int
	var initiative := 0
	var second = null
	var drawn := false
	var cover_from: Array = []
	var auto := false
	var taken_since_announce := 0
	var sp := 0
	var uses := {}
	var sneaked := false
	## 870.5: die freien Kampfhandlungen (Kennungen aus HANDLUNG); Bonus des nächsten Schlags (Finte, Ruhige Hand); Haltungen bis zum
	## eigenen nächsten Zug (Auf Abstand, Schildwall); wer ihn im Griff hält; hat in diesem Kampf schon geschlagen (Hinterhalt)
	var handlungen: Array = []
	## 870.5: Zauber nach dem BRS (Kennungen aus ZAUBER), Mana höchstens (sp ist das Mana im Kampf), Mana der alten Rechnung zum
	## Zurückrechnen nach dem Kampf; Schutz aus Bannschild und Arkanhaut (Abzug), Runden mit Beistand, Bannschild schon gewirkt
	var zauber: Array = []
	var max_sp := 0
	var srd_sp := -1
	var schutz := 0.0
	var beistand := 0
	var bann_genutzt := false
	var naechster := 0.0
	var abstand := false
	var schildwall := false
	var gegriffen_von := ""
	var geschlagen := false
	## 870.5 Gegenwirkungen: rasend (Wildschwein nach Feuer), steht nicht wieder auf (Zombie nach Feuer oder Licht), hat sich geteilt
	var rasend := false
	var kein_zaeh := false
	var geteilt := false
	var seide_weg := false     # 870.6: Gegenwirkung Riesenspinne, Feuer verbrannte die Spinnseide (Beute)
	var held := false
	var prone := false
	var waited := false
	var hidden := false
	var moved := false
	var nr := 0
	## 296.2: the statuses with the turns they still last, in the order they came; the poison's die; turns after a
	## stun in which no new one takes hold; the statuses have acted this turn; has landed a blow in this fight.
	var status := {}
	var gift := 1.0     # 870.6: Stärke des Gifts, das auf ihm wirkt (werte.json „monsterregeln“ „gift“)
	var stun_guard := 0
	var ticked := false
	var has_hit := false
	## 296.2: came running in the fight (Grak's call): worth nothing at the end, as in the old fight that had none
	var called_in := false
	## 399.2a: the leader this one follows (a young wolf its wolf, Packs.kt); it flees when the leader falls
	var follows := ""
	var fled := false
	var verjagt := false     # 841: vor dem Kampf eingeschüchtert und geflohen (lohn.gd: keine Beute von ihm)
	## 478: was er nach dem BRS ist (brs_kampf.gd held, gegner)
	var b := {}
	## 478: seine Leben nach dem SRD beim Umrechnen (Maßstab für alles, was noch in Würfeln des SRD rechnet)

	func standing() -> bool:
		return hp > 0 and not fled

	func main_weapon():
		if hero == null or str(hero.main.id) == "":
			return null
		return hero.main

	func weapon():
		if drawn and second != null:
			return second
		return main_weapon()

	func spare():
		return main_weapon() if drawn else second

	func ranged() -> bool:
		var w = weapon()
		return (w != null and w.ranged) or (monster != null and (monster.id == "goblin_archer" or monster.id == "giant_spider"))

	func reach() -> bool:
		var w = weapon()
		return w != null and w.reach

	func boss() -> bool:
		return monster != null and monster.boss

	## 870.5: Grimmzahns Leibwache steht hinter ihm und ist nicht angreifbar (werte.json „rudel“ „angreifbar“, wie alt Packs.kt guard)
	func angreifbar() -> bool:
		return bool(b.get("angreifbar", true))

	func has(skill: String) -> bool:
		return hero != null and (skill in hero.skills or skill in handlungen)

	func level() -> int:
		return int(hero.level)

	func name(lang: int) -> String:
		if hero != null:
			return str(hero.name)
		return str([monster.de, monster.en][lang]) + (" %d" % nr if nr > 0 else "")


var lang := 0
var dice
var words
var winded := false
## 399.2 (Tom 17:15): satt vom Essen (Zustand.satt, GameState.wellFed): +1 auf Angriffe und Schaden des Helden in diesem Kampf
## (Battle.fedBonus, Items roast_meat „Stärkt für den nächsten Kampf: +1 auf Angriffe und Schaden“; im alten MARS fehlte es)
var fed := false
var monsters := {}
var items := {}
var skills := {}

var all: Array = []
var last_wording := {}
var numbered := {}
var easy_gap = null
var quick_run := false
var started := false
var knockouts := 0
var outcome := "ONGOING"
## 296.2: who strikes first, as on the map: "AMBUSHED" the foes before the party, "HERO_FIRST" the party first and the
## foes lose their first turn, else "NORMAL".
var opening := "NORMAL"
## 534: wer seine Unerbittlichkeit in diesem Kampf schon gebraucht hat (alt Battle.relentlessUsed)
var relentless_used := {}
## 870.5: welche Schwäche oder Stärke (Gegnerart|Schadensart) schon genannt ist
var schwaeche_gesagt := {}
## 870.5 Gegenwirkung Wolf: das Rudel floh vor dem Feuer, der Kampf bringt keine Beute und keine Erfahrung (lohn.gd)
var kein_lohn := false
## 506: der laufende Schlag des Helden ist ein Krit (Untotenzähigkeit hält dann nicht); vor _hurt gesetzt, danach zurück
var krit_jetzt := false
var surprised := {}
var intents := {}
var autopilot := false
var order: Array = []
var turn := 0
var _log: Array = []
## Hears every message as it is said: func(event: Dictionary).
var listener: Callable
## 296.2: the statuses of the old fight (off for the replays of the Kotlin MARS on main, which has none).
var statuses := true
var potions := {}
## D4.1, 494: Morwens Rauchbündel im Gepäck (Kampfort setup „rauch“); wie Battle.smokeBundle fliegt eins, sobald Krogg auftaucht,
## ohne den Zug des Helden, und sein erster Schlag geht fehl (mit ihm der Überraschungsschlag); nach dem Kampf: was übrig ist
var smoke := 0
var smoke_thrown := false
var smoke_spent := false
const KROGG := "bugbear"
const THROWS := ["{0} wirft {1}!", "{0} throws {1}!"]     # Battle.kt Msg.throws
const MSG532_CURED := ["{0} ist von allen Leiden befreit!", "{0} is cured of all ailments!"]     # Battle.kt Msg.cured
const SMOKE_BUNDLE := ["Rauchbündel", "Smoke Bundle"]     # Items.kt smoke_bundle
var aim_spot := {}
var retargeted := {}
var chosen := false
var called := 0
var casting = null


## [party] and [foes] are Fighters; [tables] the monsters, items and skills (870.6: regeln/tabellen.gd Tabellen.lade(), nach BRS).
func _init(party: Array, foes: Array, tables: Dictionary, p_dice, p_words, p_lang := 0, p_winded := false, p_opening := "NORMAL") -> void:
	opening = p_opening
	dice = p_dice
	words = p_words
	lang = p_lang
	winded = p_winded
	for m in tables.monsters:
		monsters[m.id] = m
	for it in tables.items:
		items[it.id] = it
	for s in tables.skills:
		skills[s.id] = s
	all = party + foes
	var kinds := {}
	for f in foes:
		# 399.2a: nach Art und Name, damit Wolf und Jungwölfe (beide „wolf“) je für sich zählen; sonst gleich wie nach Art
		var k = (str(f.monster.id) + "|" + str(f.monster.de)) if f.monster != null else null
		if not kinds.has(k):
			kinds[k] = []
		kinds[k].append(f)
	for kin in kinds.values():
		if kin.size() > 1:
			for i in kin.size():
				kin[i].nr = i + 1
			if kin[0].monster != null:
				numbered[kin[0].monster.id] = kin.size()
	var lv = party[0].hero.level if party[0].hero != null else null
	if lv != null and not foes.is_empty() and not foes.any(func(f): return f.boss()):
		var top := 0.0
		for f in foes:     # 870.6: nach der Stufe des BRS (werte.json „monster“), nicht nach dem Herausforderungsgrad
			top = maxf(top, float(BrsKampf.gegner(f.monster).get("stufe", 1)))
		var gap: float = float(lv) - top
		if gap >= float(BrsKampf.w()["kampf"].get("leicht_ab", 4)):
			easy_gap = gap
	brs_einrichten()     # 870.5: immer; vor der Initiative, die nach dem BRS rechnet
	for f in all:
		f.initiative = _initiative(f, winded and f == party[0])
	var idx := {}
	for i in all.size():
		idx[all[i]] = i
	order = all.duplicate()
	order.sort_custom(func(a, b):
		if a.initiative != b.initiative:
			return a.initiative > b.initiative
		if a.side != b.side:
			return a.side == "PARTY"
		return idx[a] < idx[b])
	if opening == "AMBUSHED":
		order = order.filter(func(x): return x.side == "FOES") + order.filter(func(x): return x.side != "FOES")
	elif opening == "HERO_FIRST":
		order = order.filter(func(x): return x.side == "PARTY") + order.filter(func(x): return x.side != "PARTY")
		for f in foes:
			surprised[f.id] = true
	elif bool(_ueberfall().get("gegner_zuerst", false)):     # 870.5: Überfall (Krogg) schlägt vor dem Helden (werte.json „merkmale“ „ueberfall“, 444)
		order = order.filter(func(x): return x.side == "FOES" and bool(x.b.get("ueberfall", false))) + order.filter(func(x): return not (x.side == "FOES" and bool(x.b.get("ueberfall", false))))
	for f in foes:
		announce(f)


## 478, 870.5: ein Angriffswurf nach dem BRS: ["BRS", Wurf 1–100, 0, Chance, Treffer, Lage, von hinten, kritisch]
static func ist_angriff(roll) -> bool:
	return roll != null and roll[0] == "BRS"

static func ist_krit(roll) -> bool:
	return ist_angriff(roll) and roll[4] and roll.size() > 7 and bool(roll[7])


## 702 C (Chef 09.11., 06:56, Archiv „702 C, Anspringen: aufstehen und handeln“; Messung tests/anspringen_702.gd): wer
## angesprungen am Boden liegt, steht in seinem Zug auf und handelt gleich; das Aufstehen kostet nur den Platzwechsel (kein
## Ausweichen, kein Waffenwechsel in diesem Zug), der Sprung macht weiter Schaden und hält ihn am Platz. "" wie Skirmish.kt
## (Aufstehen kostet den ganzen Zug), nur für mars_golden und die Messung.
var anspringen := "handeln"

## 478, 870.5: der Kampf rechnet nur nach dem BRS (Modell D, brs_kampf.gd); Leben der Gruppe im selben Anteil wie vorher, Gegner nach
## dem Bestiarium (daten/werte.json); true, sobald der Kampf eingerichtet ist (aufruf.gd liest es)
var brs := false

func brs_einrichten() -> void:
	assert(BrsKampf.an(), "870.5: daten/werte.json fehlt (tools/sim444/werte.json)")
	if brs:     # nur einmal umrechnen (start ruft es, manche Tests vorher)
		return
	brs = true
	for f in all:
		_brs_kaempfer(f)


func _brs_kaempfer(f: Fighter) -> void:
	if f.hero != null:
		f.b = BrsKampf.held(f.hero)     # 870.2: mit Kampfblatt „brs“ (aufruf.gd starte)
		var mx := BrsKampf.leben_held(f.b)
		f.hp = clampi(roundi(float(f.hp) * mx / maxf(1.0, f.max_hp)), 1 if f.hp > 0 else 0, mx)
		f.max_hp = mx
		_brs_handlungen(f)
	elif f.monster != null:
		f.b = BrsKampf.gegner(f.monster, monsters.get(String(f.monster.id), {}))
		assert(not f.b.is_empty(), "870.5: kein Gegner %s in werte.json" % String(f.monster.id))
		if f.b.is_empty():
			return
		var mx := int(f.b.leben)
		f.hp = clampi(roundi(float(f.hp) * mx / maxf(1.0, f.max_hp)), 1 if f.hp > 0 else 0, mx)
		f.max_hp = mx


## 870.5: von den Klassenfähigkeiten bleiben nur die Zauber (bis zu ihrem Teil); dazu die Kampfhandlungen, die seine Fertigkeiten
## freigeben (werte.json „handlungen“: „alle“ oder Fertigkeit ab „ab“); Kraft schöpfen „je_kampf“ mal
func _brs_handlungen(f: Fighter) -> void:
	f.hero = (f.hero as Dictionary).duplicate()
	f.hero.skills = []     # 870.5: keine Klassenfähigkeiten und alten Zauber mehr
	f.uses.clear()
	_brs_zauber_kennen(f)
	var H: Dictionary = BrsKampf.w().get("handlungen", {})
	f.handlungen = []
	for id in HANDLUNG:
		var h = H.get(HANDLUNG[id])
		if not (h is Dictionary):
			continue
		var frei: bool = bool(h.get("alle", false)) or (h.get("fertigkeit") != null and int(f.b.fert.get(String(h.fertigkeit), 0)) >= int(h.get("ab", 0)))
		if frei:
			f.handlungen.append(id)
			if h.has("je_kampf"):
				f.uses[id] = int(h.je_kampf)
	for id in ZAUBER:
		if not skills.has(id):
			var zw: Dictionary = BrsKampf.w()["zauber"].get(ZAUBER[id], {})
			skills[id] = {"id": id, "de": ZAUBER_NAME[id][0], "en": ZAUBER_NAME[id][1], "cost": "SPELL_POINTS", "amount": int(zw.get("kosten", 0)),
				"cls": "", "level": 0}
	for id in HANDLUNG:
		if not skills.has(id):
			var cost := "PER_BATTLE" if id == "H_KRAFT" else "HANDLUNG"
			skills[id] = {"id": id, "de": HANDLUNG_NAME[id][0], "en": HANDLUNG_NAME[id][1], "cost": cost, "amount": 1, "cls": "", "level": 0}


## 870.5 (870a 5 A): Grundwert für Proben; Gegner ohne Grundwerte zählen mit „gegner_grundwert“ (werte.json „proben“)
func _proben() -> Dictionary:
	return BrsKampf.w().get("proben", {})


func _grundwert(f: Fighter, name: String) -> float:
	var P := _proben()
	var w = f.b.get("werte", {}) if name != "" else {}
	if w.has(name):
		return float(w[name])
	return float(P.get("gegner_grundwert", 5))


## Chance in Prozent: [f] mit [wert] gegen [g] mit [gegen] (leer: gegner_grundwert), Stufe dazu
func _probe_chance(f: Fighter, wert: String, g: Fighter, gegen: String, bonus := 0.0) -> float:
	var P := _proben()
	var c := float(P.get("basis", 50)) + float(P.get("je_punkt", 5)) * (_grundwert(f, wert) - _grundwert(g, gegen)) \
			+ float(P.get("je_stufe", 5)) * float(int(f.b.get("stufe", 1)) - int(g.b.get("stufe", 1))) + bonus
	return clampf(c, float(P.get("min", 5)), float(P.get("max", 95)))


func _probe(f: Fighter, wert: String, g: Fighter, gegen: String, bonus := 0.0) -> bool:
	return dice.next_int(0, 100) < roundi(_probe_chance(f, wert, g, gegen, bonus))


func _staerkster_gegner(t: Fighter):
	var best = null
	for x in all:
		if x.side != t.side and x.standing() and (best == null or int(x.b.get("stufe", 1)) > int(best.b.get("stufe", 1))):
			best = x
	return best


## Reihenfolge (werte.json „proben“ „_initiative“); Zufall vom Würfel (0 bis Streuung), so spielt ein Band in Tests mit
func _initiative(f: Fighter, atemlos := false) -> int:
	var P := _proben()
	var n := float(P.get("je_punkt", 5)) * _grundwert(f, "gewandtheit") + float(P.get("je_stufe", 5)) * float(int(f.b.get("stufe", 1)))
	n += float(dice.next_int(0, int(P.get("initiative_streuung", 100))))
	if atemlos:
		n -= float(P.get("initiative_atemlos", 25))
	return roundi(n)


## 506 Untotenzähigkeit als Prozent (870.6: nach dem Schaden in Prozent seines vollen Lebens, werte.json „zustaende“ „untot_zaeh“)
func _zaeh_haelt(t: Fighter, dmg: int) -> bool:
	var z: Dictionary = _zw().get("untot_zaeh", {})
	var c := float(z.get("basis", 95)) - float(z.get("je_prozent", 1.1)) * 100.0 * float(dmg) / maxf(1.0, float(t.max_hp))
	return dice.next_int(0, 100) < clampi(roundi(c), 0, 100)


const METALL_RUESTUNG := ["Mittlere Rüstung", "Schwere Rüstung"]     # wie BrsHeld.metall
const METALL_SPERRT := ["Evokation", "Illusion", "Beschwörung"]

## 870.5: welche Zauber [f] kennt (Kampfblatt, sonst Herkunft; dazu jeder mit „ab“, den die Fertigkeit der Schule erreicht) und sein
## Mana (held mana_basis + mana_je_wille × Wille); das Mana der Welt kommt im selben Anteil herein (sp von sp_max), ohne Angabe voll
func _brs_zauber_kennen(f: Fighter) -> void:
	var W := BrsKampf.w()
	f.zauber = []
	# 870.4 (DESIGN-BRS.md 7, Entscheidung 80; [870.14.ding.metall], Fremdprüfung Homer 14:15): in mittlerer und schwerer
	# Rüstung (Metall) gehen Evokation, Illusion und Beschwörung nicht; Heil- und Schutzmagie auch in Metall
	var metall := String(f.b.get("ruestung", "keine")) in METALL_RUESTUNG
	for id in ZAUBER:
		var z: Dictionary = W["zauber"].get(ZAUBER[id], {})
		if z.is_empty():
			continue
		if metall and String(z.get("schule", "")) in METALL_SPERRT:
			continue
		var kennt: bool = ZAUBER[id] in f.b.get("zauber", []) or (z.has("ab") and int(f.b.fert.get(String(z.schule), 0)) >= int(z.ab))
		if kennt:
			f.zauber.append(id)
	var h: Dictionary = W["held"]
	f.max_sp = int(f.b.get("mana", 0)) if int(f.b.get("mana", 0)) > 0 else int(h.get("mana_basis", 10)) + int(h.get("mana_je_wille", 5)) * int(f.b.werte.get("wille", 0))     # 870.6: aus dem Kampfblatt (mit Mana der Ausrüstung)
	var alt_max := int(f.hero.get("sp_max", 0))
	f.srd_sp = f.sp if alt_max > 0 else -1
	f.sp = clampi(roundi(float(f.max_sp) * f.sp / alt_max), 0, f.max_sp) if alt_max > 0 else f.max_sp


## 870.5: das Mana nach dem Kampf in der Rechnung der Welt (870.4: BrsHeld, dieselbe Zahl), im selben Anteil; ohne Angabe unverändert
static func sp_nach(f) -> int:
	var alt_max := int(f.hero.get("sp_max", 0)) if f.hero != null else 0
	if alt_max <= 0 or f.max_sp <= 0:
		return f.srd_sp if f.srd_sp >= 0 else f.sp
	return clampi(roundi(float(alt_max) * f.sp / f.max_sp), 0, alt_max)


## 870.5: das Volk nach dem BRS (Kampfblatt „volk“), sonst aus dem alten Blatt; Merkmale Steinblut, Letzter Atemzug (DESIGN-BRS.md 2)
const VOLK_ALT := {"HUMAN": "Mensch", "ELF": "Elf", "DWARF": "Zwerg", "HALFLING": "Hügelvolk", "HALF_ORC": "Orkblütiger"}

func _volk(f: Fighter) -> String:
	if f.hero == null:
		return ""
	if f.b is Dictionary and String(f.b.get("volk", "")) != "":
		return String(f.b.volk)
	var k = f.hero.get("brs")
	if k is Dictionary and String(k.get("volk", "")) != "":
		return String(k.volk)
	return String(VOLK_ALT.get(String(f.hero.get("race", "")), ""))


static func ziel_von(s: String) -> String:
	return HANDLUNG_ZIEL.get(s, ZAUBER_ZIEL.get(s, ""))


## 870.5: Werte einer Kampfhandlung (werte.json „handlungen“)
func _hw(id: String) -> Dictionary:
	return BrsKampf.w().get("handlungen", {}).get(HANDLUNG.get(id, ""), {})


## 870.5: die Handlung passt zu dem, was [f] in der Hand hat (Waffengruppe, Schild)
func _handlung_passt(f: Fighter, id: String) -> bool:
	var fert = _hw(id).get("fertigkeit")
	if fert == null:
		return true
	if fert == "Schild":
		return bool(f.b.get("schild", false)) and not f.drawn
	var w = f.weapon()
	return BrsKampf.waffe_held(f.b, w if w != null else f.hero.main, w != null and w != f.main_weapon()) == String(fert)


## 870.6: was früher in Würfeln des SRD rechnete (Zustände, Sammeln, Untotenzähigkeit, Schwächung, Sättigung), nach den Regelwerten
## (werte.json „zustaende“, A bis 444); der Maßstab der alten Trefferpunkte entfällt
func _zw() -> Dictionary:
	return BrsKampf.w().get("zustaende", {})


## Anteil [anteil] am vollen Leben von [t], gerundet, mindestens 1
func _anteil(t: Fighter, anteil: float) -> int:
	return maxi(1, roundi(float(t.max_hp) * anteil))


## A figure on a hero sheet; [second] the second weapon's sheet or null.
static func hero_fighter(id: String, side: String, place: Vector2i, sheet: Dictionary, hp: int, second, skill_table: Dictionary) -> Fighter:
	var f := Fighter.new()
	f.id = id
	f.side = side
	f.place = place
	f.hero = sheet
	f.max_hp = hp
	f.hp = hp
	f.second = second
	f.sp = int(sheet.sp)
	for s in skill_table.values():
		if s.id in sheet.skills and (s.cost == "PER_BATTLE" or s.cost == "PER_REST"):
			f.uses[s.id] = int(s.amount)
	return f


static func monster_fighter(id: String, place: Vector2i, m: Dictionary, hp: int) -> Fighter:
	var f := Fighter.new()
	f.id = id
	f.side = "FOES"
	f.place = place
	f.monster = m
	f.max_hp = hp
	f.hp = hp
	return f


func easy() -> bool:
	return easy_gap != null


func quick_harm() -> float:
	if easy_gap == null:
		return 1.0
	var k: Dictionary = BrsKampf.w()["kampf"]
	return 1.0 if easy_gap < float(k.get("leicht_halb_ab", 7)) else (0.5 if easy_gap < float(k.get("leicht_null_ab", 10)) else 0.0)


func fighters() -> Array:
	return all


# 279: a wording of [key] at random, never the one it had last time.
func pick(key: String) -> Array:
	var l: Array = TX[key]
	var i := 0
	if l.size() >= 2:
		var free := []
		for n in l.size():
			if not last_wording.has(key) or n != last_wording[key]:
				free.append(n)
		i = words.pick(free)
	last_wording[key] = i
	return l[i]


## 533: Wolf oder Grimmzahn (beide kämpfen als Rudel: Anspringen, Einkreisen, Wolfszeilen)
static func wolfig(m) -> bool:
	return m != null and String(m.id) in [WOLF, DIRE_WOLF]


## 535, 577: die Art, nach der die Regeln eine Figur behandeln: ihre id
static func art_of(m) -> String:
	return "" if m == null else String(m.id)


## 577: der Körper, dessen Modell und Bewegungen eine Figur trägt (ohne „koerper“ ihre id)
static func koerper_of(m) -> String:
	return "" if m == null else String(m.get("koerper", m.id))


func wolf(f: Fighter, own: String, general: String) -> Array:
	return pick(own if wolfig(f.monster) else general)


static func fmt(t: Array, lang_i: int, args: Array) -> String:
	var s: String = t[lang_i]
	for i in args.size():
		s = s.replace("{%d}" % i, str(args[i]))
	return s


func _next_turn() -> void:
	order[turn].moved = false
	order[turn].ticked = false
	turn = (turn + 1) % order.size()


func standing_of(side: String) -> Array:
	return all.filter(func(f): return f.side == side and f.standing())


# 301: a blow announced on one who stepped out of reach goes to one in reach, with disadvantage.
func reaim() -> Array:
	var out := []
	for id in intents.keys():
		var plan: Array = intents[id]
		var intent: Dictionary = plan[0]
		var aimed: Array = plan[1]
		if intent.kind != "STRIKE" or intent.effect in NO_REAIM:
			continue
		var foe = find(id)
		if foe == null or not foe.standing():
			continue
		var r := targets(foe)
		if r.is_empty() or r.any(func(x): return x.id in aimed):
			continue
		if not aimed.any(func(a): return all.any(func(x): return x.id == a and x.standing())):
			continue
		var now: Fighter = r[0]
		intents[id] = [intent, [now.id]]
		aim_spot[id] = now.place
		retargeted[id] = true
		out.append([foe, now])
	return out


func current() -> Fighter:
	return order[turn]


func find(id: String):
	for f in all:
		if f.id == id:
			return f
	return null


func by_id(id: String) -> Fighter:
	return find(id)


## The standing figures in the order of turns, the one acting now first (72.10a.4).
func queue() -> Array:
	var n := order.size()
	var out := []
	for i in n:
		var f: Fighter = order[(turn + i) % n]
		if f.standing():
			out.append(f.id)
	return out


## The abilities and spells [f] can use in this fight (72.10a.1).
func moves(f: Fighter) -> Array:
	if f.hero == null:
		return []
	var out := []
	out.append_array(f.zauber)     # 870.5
	for s in f.handlungen:
		if _handlung_passt(f, s):
			out.append(s)
	return out


## Why [f] cannot use [s] now ([de, en]), or null.
func blocked(f: Fighter, s: String):
	var sk: Dictionary = skills[s]
	if sk.cost == "SPELL_POINTS" and f.sp < int(sk.amount):
		return X.MSG72_NOSP
	if sk.cost == "PER_BATTLE" and f.uses.get(s, 0) <= 0:
		return X.MSG72_NOBATTLE
	if sk.cost == "PER_REST" and f.uses.get(s, 0) <= 0:
		return X.MSG72_NOREST
	if aim_at(f, s).is_empty():
		return X.MSG72_NOTARGET
	return null


func aim_at(f: Fighter, s: String) -> Array:
	if s == "H_HINTERHALT":     # 870.5: nur der erste eigene Schlag oder gegen einen Überraschten
		return targets(f).filter(func(x): return not f.geschlagen or surprised.has(x.id))
	if HANDLUNG_ZIEL.get(s) == "FOE":
		return targets(f)
	if s == "Z_BANN" and f.bann_genutzt:     # einmal je Kampf
		return []
	if s == "Z_WUND":     # nur, wer nicht voll ist
		return all.filter(func(x): return x.side == f.side and x.standing() and x.hp < x.max_hp)
	match ziel_von(s):
		"FOE":
			if (s == "FEINT" or s == "ACTION_SURGE") and not _feints_past(f, s):
				return targets(f)
			return feinde(f)
		"ROW":
			return feinde(f)
		"SELF":
			return [f]
		"ALLY":
			return all.filter(func(x): return x.side == f.side and x.standing())
	return []


func _feints_past(f: Fighter, s: String) -> bool:
	return s == "FEINT" and _covers(f)


func _covers(f: Fighter) -> bool:
	return f.place.x == BACK and all.any(func(x): return x.side == f.side and x.standing() and x.place.x == FRONT)


## The announced blows [f] can draw onto himself by covering (72.10a.9).
func guardable(f: Fighter) -> Array:
	if f.hero == null or String(f.hero.get("cls", "")) != "FIGHTER" or f.place.x != FRONT or not f.standing():     # 870.4: der Held nach BRS hat keine Klasse
		return []
	var out := []
	for id in intents:
		if intents[id][1].any(func(a): return a != f.id):
			out.append(id)
	return out


## Was sich trinken lässt (Heiltränke, Kräutertrank; tabellen.json „kind“ POTION); 532: Wurfmittel wirft man (935).
func drinkable() -> Array:
	return potions.keys().filter(func(k): return potions[k] > 0 and String(items.get(k, {}).get("kind", "POTION")) == "POTION")


## 532, 935: die Tasche im Kampf, alles, was sich jetzt benutzen lässt (trinken, werfen)
func bag() -> Array:
	return drinkable() + throwable()


## 935 (alt Battle.useItem BOMB): Wurfmittel (tabellen.json „kind“ BOMB), die jetzt ein Ziel haben
func throwable() -> Array:
	return potions.keys().filter(func(k): return potions[k] > 0 and String(items.get(k, {}).get("kind", "")) == "BOMB" \
			and not throw_targets(k).is_empty())


## 935: wen ein Wurf erreicht: jeden stehenden Gegner, Weihwasser nur Untote (alt Battle.blockedItem NOT_UNDEAD; werte.json
## „kampftraenke“ „nur_untote“)
func throw_targets(item: String) -> Array:
	var d: Dictionary = BrsKampf.w().get("kampftraenke", {}).get(String(items.get(item, {}).get("brs", "")), {})
	return all.filter(func(x): return x.side != "PARTY" and x.standing() and x.monster != null \
			and (not bool(d.get("nur_untote", false)) or bool(x.monster.get("undead", false))))


## 532 (alt Battle.blockedItem ALREADY_FULL): ob [item] [t] etwas bringt: Leben fehlt, oder der Kräutertrank hat Zustände zu
## heilen (der Rausch bleibt)
func drink_helps(item: String, t: Fighter) -> bool:
	return t.hp < t.max_hp or (bool(items.get(item, {}).get("cures", false)) and t.status.keys().any(func(k): return k != "DRUNK"))


# 72.13: heal a friend below half, else a cantrip, else the weapon.
func _auto_order(f: Fighter) -> Array:
	var friend = null
	for x in all:
		if x.side == f.side and x.standing() and x.hp * 2 < x.max_hp:
			if friend == null or float(x.hp) / x.max_hp < float(friend.hp) / friend.max_hp:
				friend = x
	var can := moves(f)
	var kraft := _hw("H_KRAFT")
	if "H_KRAFT" in can and blocked(f, "H_KRAFT") == null and f.hp < f.max_hp * float(kraft.get("unter", 0.5)):     # 870.5
		return ["use", "H_KRAFT", f.id]
	if friend != null and "Z_WUND" in can and blocked(f, "Z_WUND") == null and friend in aim_at(f, "Z_WUND"):
		return ["use", "Z_WUND", friend.id]
	var cantrip = null
	for c in ["Z_FUNKEN", "Z_ARKAN", "Z_GLEISS"]:     # 870.5: solange das Mana reicht
		if c in can and blocked(f, c) == null:
			cantrip = c
			break
	var foes := feinde(f)
	if cantrip != null and not foes.is_empty():
		var ziel = _min_hp(foes)
		# 705 (Sokrates 10.11., 23:16, wie 444 Teil 6): ein Zauber nur, wenn er mehr bringt als die Waffe, und das Mana für die Heilung bleibt
		var bleibt: int = int(f.sp) - int(skills[cantrip].amount)
		var heil_vorrat: bool = f.b.is_empty() or not "Z_WUND" in can or bleibt * 2 >= f.max_sp     # die Hälfte bleibt für Wundsegen
		var w_ziel = _min_hp(targets(f))
		if f.b.is_empty() or (heil_vorrat and (w_ziel == null or _erwartet_zauber(f, ziel, cantrip) > _erwartet_waffe(f, w_ziel))):
			return ["use", cantrip, ziel.id]
	if can_draw(f) and f.place.x == FRONT and f.weapon() != null and f.weapon().ranged and f.spare() != null and not f.spare().ranged:
		return ["draw"]
	var t = _min_hp(targets(f))
	return ["attack", t.id] if t != null else ["wait"]


## 705: erwarteter Schaden je Zug nach dem BRS (Trefferchance × Schaden nach Fertigkeit und Schwäche, minus Rüstung), ohne Würfel
func _erwartet_zauber(f: Fighter, t: Fighter, id: String) -> float:
	var z: Dictionary = BrsKampf.w()["zauber"][ZAUBER[id]]
	var fert := float(f.b.fert.get(String(z["schule"]), 0))
	var grund := (float(z["schaden"]) + float(f.b.werte.get(BrsKampf.zauber_grundwert(String(z["schule"])), 0))) * (1.0 + fert / 100.0) * _zauber_faktor(f)     # 952 D
	var schw := float(t.b.get("schwaeche", {}).get(_typ(z), 1.0))
	return BrsKampf.Brs.trefferchance(fert, float(t.b.abwehr)) * maxf(0.0, grund * schw - float(t.b.ruestung))


## 870.6: Zauberschaden der Zusatzeigenschaften (Prozent) als Faktor
func _zauber_faktor(f: Fighter) -> float:
	return 1.0 + float(f.b.get("zusatz", {}).get("zauber", 0)) / 100.0


## 904 (sim444_870, Zauberlehrling gegen Grak und Grimmzahn): Arkanpfeil hat in werte.json „typ“: null (ohne Schadensart);
## String(null) brach _auto_order ab, der Autopilot nahm dann die Waffe
func _typ(d: Dictionary) -> String:
	var x = d.get("typ")
	return "" if x == null else String(x)


func _erwartet_waffe(f: Fighter, t: Fighter) -> float:
	var W := BrsKampf.w()
	var w = f.weapon()
	var gruppe := BrsKampf.waffe_held(f.b, w if w != null else f.hero.main, w != null and w != f.main_weapon())
	var wd: Dictionary = W["waffen"].get(gruppe, W["waffen"]["Faustkampf"])
	var gw = wd.get("grundwert")
	var fert := float(f.b.fert.get(gruppe, 0))
	var grund := (float(wd["schaden"]) + (float(f.b.werte.get(gw, 0)) if gw != null else 0.0)) * (1.0 + fert / 100.0)
	var schw := float(t.b.get("schwaeche", {}).get(_typ(wd), 1.0))
	return BrsKampf.Brs.trefferchance(fert, float(t.b.abwehr)) * maxf(0.0, grund * schw - float(t.b.ruestung))


func _min_hp(list: Array):
	var best = null
	for x in list:
		if best == null or x.hp < best.hp:
			best = x
	return best


## 870.5: wen [f] überhaupt treffen kann: die stehenden Gegner ohne Grimmzahns Leibwache (Fighter.angreifbar)
func feinde(f: Fighter) -> Array:
	return all.filter(func(x): return x.side != f.side and x.standing() and x.angreifbar())


## Whom [f] can strike: melee reaches the front row while anyone stands there, ranged reaches all (72.11).
func targets(f: Fighter) -> Array:
	var other := feinde(f)
	if f.ranged():
		return other
	var front := other.filter(func(x): return x.place.x == FRONT)
	return front if not front.is_empty() else other


func lead() -> Fighter:
	for f in all:
		if f.side == "PARTY":
			return f
	return null


## Why the autopilot cannot run now ([de, en]), or null (72p.1).
func autopilot_blocked(hp = null):
	var l := lead()
	var h: int = l.hp if hp == null else int(hp)
	if all.any(func(x): return x.side == "FOES" and x.boss()):
		return ["Nicht gegen Bosse.", "Not against bosses."]
	if h * 3 < l.max_hp:
		return ["Unter einem Drittel seines Lebens.", "Below a third of its Life."]
	if not easy() and intents.values().any(func(p): return p[0].strong):
		return ["Starke Absicht angekündigt.", "Strong intent announced."]
	return null


func can_swap(f: Fighter) -> bool:
	return not f.moved


func can_draw(f: Fighter) -> bool:
	return not f.moved and f.spare() != null


func _piloted(f: Fighter) -> bool:
	return autopilot and f == lead()


## An automatic party turn is up, so the screen plays on (241.1).
func pilot_next() -> bool:
	var c := current()
	return outcome == "ONGOING" and c.standing() and (_piloted(c) or (c.side == "PARTY" and c.auto))


func set_autopilot(on: bool, hp = null) -> bool:
	autopilot = on and autopilot_blocked(hp) == null
	return autopilot


func _take_log() -> Array:
	var out := _log
	_log = []
	return out


## Plays the party figure's [o] (["attack", id], ["swap", Vector2i, draw], ["draw"], ["wait"], ["guard"],
## ["use", skill, target or null], ["drink", item, target]), then on until a party figure must choose again.
## [react] func(Fighter, intent) -> reaction gives the ring for a party figure hit by an intent.
func act(o: Array, react: Callable = Callable()) -> Array:
	assert(outcome == "ONGOING")
	var f := current()
	assert(f.side == "PARTY" and f.standing())
	chosen = true
	_perform(f, o)
	if o[0] == "swap" or o[0] == "draw":
		f.moved = true
	else:
		_advance(react)
	return _take_log()


func proceed(react: Callable = Callable()) -> Array:
	assert(outcome == "ONGOING")
	_skip_to_choice(react)
	return _take_log()


## 272 (test mode only): ends the fight at once.
func test_end(win: bool) -> Array:
	chosen = true
	if win:
		for f in all.filter(func(x): return x.side == "FOES" and x.standing()):
			f.hp = 0
			intents.erase(f.id)
			_say(fmt(wolf(f, "MSG279_WOLFFALLS", "MSG72_FALLS"), lang, [f.name(lang)]), null, f.id, 0, null, false, false, "FOE_FALLS")
		outcome = "WON"
	else:
		var h: Fighter = all[0]
		h.hp = 0
		_say(fmt(pick("MSG72_HEROFALLS"), lang, [h.name(lang)]), null, h.id, 0, null, false, false, "HERO_FALLS")
		outcome = "LOST"
	return _take_log()


## 296.2 (Test 89.2 b): a hero with no life points left never goes into a fight; the world asks before it starts one.
static func can_fight(party: Array) -> bool:
	return not party.is_empty() and party[0].hp > 0


func start(react: Callable = Callable(), verjagen := false) -> Array:
	# never play a fight without its hero: the foes would wait for a target forever (the old game ran out of memory)
	if not lead().standing():
		started = true
		outcome = "LOST"
		return _take_log()
	if verjagen and spaeher_zum_verjagen() != null:
		_einschuechtern()
		if outcome != "ONGOING":
			started = true
			return _take_log()
	_opening()
	_skip_to_choice(react)
	return _take_log()


func _opening() -> void:
	started = true
	if winded:
		_say(fmt(X.MSG72_WINDED, lang, [lead().name(lang)]))
	if fed:
		_say(fmt(MSG399_FED, lang, [lead().name(lang)]))
	_smoke_bundle()
	_cow()
	for foe in intents.keys():
		_say_announce(by_id(foe))


## D4.1 (Battle.smokeBundle): the hero throws Morwen's smoke bundle as soon as Krogg shows up, by itself, before an ambush too.
func _smoke_bundle() -> void:
	if smoke <= 0 or not foes_of_kind(KROGG):
		return
	smoke -= 1
	smoke_thrown = true
	_say(fmt(THROWS, lang, [lead().name(lang), SMOKE_BUNDLE[lang]]), lead().id, foes_of_kind(KROGG)[0].id, 0, null, false, false, "THROW")


func foes_of_kind(id: String) -> Array:
	return fighters().filter(func(f): return f.side == "FOES" and f.monster != null and str(f.monster.id) == id)


## 841 (807 A, 807a A; STORY-K1-FERTIGKEITEN.md „Einschüchtern: Goblin-Späher“): zu Kampfbeginn steht neben „Kämpfen“ die Wahl,
## den Späher zu verjagen, wenn unter den Gegnern ein Goblin-Späher ist, nie gegen Krogg, Grak. Der erste stehende Späher, sonst null.
func spaeher_zum_verjagen():
	if started or outcome != "ONGOING" or not foes_of_kind(KROGG).is_empty() or not foes_of_kind(GRAK).is_empty():
		return null
	for f in all:
		if f.side == "FOES" and f.standing() and f.monster != null and str(f.monster.id) == SCOUT and not f.called_in:
			return f
	return null


## 841: Chance in Prozent (werte.json „proben“ „_einschuechtern“): einschuechtern_basis + einschuechtern_je_punkt × Einschüchtern
## + je_stufe × (eigene Stufe − Stufe des Spähers), begrenzt auf min bis max
func einschuechtern_chance(h: Fighter, s: Fighter) -> float:
	var P := _proben()
	var c := float(P.get("einschuechtern_basis", 35)) + float(P.get("einschuechtern_je_punkt", 1.0)) * float(h.b.get("fert", {}).get("Einschüchtern", 0)) \
			+ float(P.get("je_stufe", 5)) * float(int(h.b.get("stufe", 1)) - int(s.b.get("stufe", 1)))
	return clampf(c, float(P.get("min", 5)), float(P.get("max", 95)))


## 841: gelingt es, flieht der Späher (Erfahrung wie für einen Sieg über ihn, lohn.gd zählt ihn mit; keine Beute von ihm); war er allein,
## ist der Kampf gewonnen, sonst beginnt er ohne ihn. Misslingt es, beginnt der Kampf mit allen. Der Versuch übt Einschüchtern
## (Kampfuebung hört „INTIMIDATE“), gelungen oder nicht.
const MSG841_JA := [["Der Späher starrt dich an. Dann reißt er aus und ist fort.", "The scout stares at you. Then he bolts and is gone."],     # [807.spaeher.ja]
	["Der Späher weicht zurück, Schritt um Schritt, und rennt.", "The scout backs away, step by step, and runs."],
	["Ein Blick in dein Gesicht genügt. Der Späher lässt den Bogen sinken und flieht.", "One look at your face is enough. The scout lowers his bow and flees."]]
const MSG841_NEIN := [["Der Späher bleckt die Zähne. Er bleibt.", "The scout bares his teeth. He stays."],     # [807.spaeher.nein]
	["Ein kehliges Lachen. Der Goblin legt einen Pfeil auf.", "A throaty laugh. The goblin nocks an arrow."],
	["Er duckt sich, aber er flieht nicht.", "He crouches, but he doesn't run."]]
func _einschuechtern() -> void:
	var h := lead()
	var s = spaeher_zum_verjagen()
	var gelingt: bool = dice.next_int(0, 100) < roundi(einschuechtern_chance(h, s))
	_say("", h.id, s.id, 0, null, false, false, "INTIMIDATE")
	if not gelingt:
		_say(words.pick(MSG841_NEIN)[lang], s.id, h.id)
		return
	s.fled = true
	s.verjagt = true
	intents.erase(s.id)
	_say(words.pick(MSG841_JA)[lang], null, s.id, 0, null, false, false, "FOE_FLEES")
	if not all.any(func(x): return x.side == "FOES" and x.standing()):
		outcome = "WON"


## 534 (alt Battle.init, Perks.cowChance): wer Charisma hat, schüchtert zu Kampfbeginn einen gewöhnlichen Gegner ein (8 % je
## Punkt), der dann seinen ersten Zug verliert; nie im Hinterhalt, nie einen Boss. Alt gab es einen Gegner, hier den ersten im Zug.
func _cow() -> void:
	var h := lead()
	var cow := COW_PER_CHA * maxi(0, int(h.hero.get("cha", 0))) if h.hero != null else 0.0
	if opening == "AMBUSHED" or cow <= 0.0:
		return
	var foe = null
	for f in order:
		if f.side == "FOES" and f.standing() and not f.boss() and not surprised.has(f.id):
			foe = f
			break
	if foe != null and dice.chance(cow):
		surprised[foe.id] = true
		_say(fmt(MSG534_COWED, lang, [foe.name(lang), h.name(lang)]), foe.id, h.id)


## 259: plays a light fight through in one go. Returns {lost, stopped, events}.
func quick() -> Dictionary:
	assert(easy() and outcome == "ONGOING")
	var party := all.filter(func(x): return x.side == "PARTY")
	var before := {}
	var was_auto := {}
	for p in party:
		before[p.id] = p.hp
		was_auto[p.id] = p.auto
	var events := []
	quick_run = true
	if not started:
		_opening()
	chosen = true
	autopilot = autopilot_blocked() == null
	for i in range(1, party.size()):
		party[i].auto = true
	var good := func(_t, _i): return GOOD
	while outcome == "ONGOING" and autopilot:
		_skip_to_choice(good)
		events += _log
		_log = []
	quick_run = false
	for p in party:
		p.auto = was_auto[p.id]
	events += _log
	_log = []
	var stopped := outcome == "ONGOING"
	autopilot = false
	var lost := {}
	for p in party:
		lost[p.id] = before[p.id] - p.hp
	return {"lost": lost, "stopped": stopped, "events": events}


func _advance(react: Callable) -> void:
	_next_turn()
	_skip_to_choice(react)


func _skip_to_choice(react: Callable) -> void:
	while outcome == "ONGOING":
		var f := current()
		if not f.standing():
			_next_turn()
		elif statuses and not f.ticked and (not f.status.is_empty() or f.stun_guard > 0):
			# 296.2: poison, burning and bleeding hurt at the start of the turn, a stun costs it
			f.ticked = true
			if _tick(f):
				_next_turn()
		elif f.held:
			f.held = false
			if f.prone and anspringen == "handeln":
				_say(fmt(pick("MSG702_AUF" if sturz_zwischentext else "MSG702_RISES"), lang, [f.name(lang)]), f.id, null, 0, null, false, false, "RISES")
				f.prone = false
				f.moved = true
				continue
			_say(fmt(pick(("MSG547_AUF" if sturz_zwischentext else "MSG279_RISES") if f.prone else "MSG130_LOSES"), lang, [f.name(lang)]), f.id, null, 0, null, false, false, "RISES" if f.prone else "")
			f.prone = false
			_next_turn()
		elif f.side == "FOES" and surprised.has(f.id):
			surprised.erase(f.id)
			_say(fmt(MSG296_STILLSURPRISED, lang, [f.name(lang)]), f.id)
			_next_turn()
		elif f.side == "FOES":
			_foe_turn(f, react)
			_next_turn()
		elif autopilot and autopilot_blocked() != null:
			autopilot = false
			_say(X.MSG72_AUTOPILOTSTOPS[lang])
			return
		elif (_piloted(f) or f.auto) and not _log.is_empty():
			return
		elif _piloted(f) or f.auto:
			var o := _auto_order(f)
			_perform(f, o)
			if o[0] == "draw" and outcome == "ONGOING":
				f.moved = true
				_perform(f, _auto_order(f))
			_next_turn()
		else:
			return


func _perform(f: Fighter, o: Array) -> void:
	f.waited = o[0] == "wait"
	f.cover_from = []
	# 870.5: Haltungen und Griff halten bis zum eigenen nächsten Zug; Beistand zählt die eigenen Züge
	if f.beistand > 0:
		f.beistand -= 1
	f.abstand = false
	f.schildwall = false
	for x in all:
		if x.gegriffen_von == f.id:
			x.gegriffen_von = ""
	match o[0]:
		"wait":
			_say(fmt(pick("MSG72_WAITS"), lang, [f.name(lang)]), f.id)
		"guard":
			var drawn := guardable(f)
			assert(not drawn.is_empty())
			f.cover_from = drawn.duplicate()
			for id in drawn:
				intents[id] = [intents[id][0], [f.id]]
				aim_spot[id] = f.place
			_say(fmt(X.MSG72_COVERS, lang, [f.name(lang)]), f.id)
		"swap":
			var to: Vector2i = o[1]
			assert(not f.moved and to != f.place)
			for x in all:
				if x.side == f.side and x.place == to and x != f:
					x.place = f.place
					break
			f.place = to
			var aimed_anew := reaim()
			_say(fmt(pick("MSG72_SWAPS"), lang, [f.name(lang)]), f.id)
			for pair in aimed_anew:
				_say(fmt(pick("MSG301_REAIMS"), lang, [pair[0].name(lang), pair[1].name(lang)]), pair[0].id, pair[1].id)
			if o.size() > 2 and o[2]:
				_draw(f)
		"draw":
			assert(can_draw(f))
			_draw(f)
		"attack":
			var t := by_id(o[1])
			assert(t in targets(f))
			_attack_action(f, t)
		"use":
			assert(blocked(f, o[1]) == null)
			var t = by_id(o[2]) if o.size() > 2 and o[2] != null else null
			_use_skill(f, o[1], t)
		"drink":
			_drink(f, o[1], by_id(o[2]))
		"throw":
			_throw(f, o[1], by_id(o[2]))
		"flee":
			_flee(f)


func _again(f: Fighter, t: Fighter, weapon: bool):
	if t.standing():
		return t
	var l := targets(f) if weapon else feinde(f)
	return l[0] if not l.is_empty() else null


func _use_skill(f: Fighter, s: String, t) -> void:
	var sk: Dictionary = skills[s]
	match sk.cost:
		"SPELL_POINTS":
			f.sp -= int(sk.amount)
		"PER_BATTLE", "PER_REST":
			f.uses[s] = f.uses[s] - 1
	var spell: bool = sk.cost == "SPELL_POINTS" or sk.cost == "NONE"     # Kampfhandlungen (870.5): „setzt … ein“ wie Fähigkeiten
	if s != "H_KRAFT":     # [870.14.kraft.schoepfen]: eine Zeile statt zwei
		_say(fmt(X.MSG72_CASTS if spell else X.MSG72_USES, lang, [f.name(lang), [sk.de, sk.en][lang]]), f.id)
	casting = ZAUBER_FX.get(s)
	_cast(f, s, t)
	casting = null


func _cast(f: Fighter, s: String, t) -> void:
	if HANDLUNG.has(s):
		_handlung(f, s, t)
		return
	if ZAUBER.has(s):
		_brs_wirke(f, s, t)
		return

## 870.5: ein Zauber nach dem BRS (werte.json „zauber“, wie tools/sim444/handlungen.py duell und sim.py kampf)
func _brs_wirke(f: Fighter, s: String, t) -> void:
	var W := BrsKampf.w()
	var z: Dictionary = W["zauber"][ZAUBER[s]]
	var k: Dictionary = W["kampf"]
	var fert := float(f.b.fert.get(String(z.schule), 0))
	match s:
		"Z_FUNKEN", "Z_ARKAN", "Z_GLEISS":
			_brs_zauber(f, t, z)
		"Z_STRAHLEN":
			var tt = t
			for i in 3:
				tt = _again(f, tt, false) if tt != null else null
				if outcome == "ONGOING" and tt != null:
					_brs_zauber(f, tt, z)
		"Z_FAECHER", "Z_GLUT":
			var row: int = FRONT if s == "Z_FAECHER" and all.any(func(x): return x.side == t.side and x.standing() and x.place.x == FRONT) else t.place.x
			for g in all.filter(func(x): return x.side == t.side and x.standing() and x.angreifbar() and x.place.x == row):
				if outcome == "ONGOING":
					_brs_zauber(f, g, z)
		"Z_WUND":
			var n := mini(t.max_hp - t.hp, roundi((float(z.heilung) + float(f.b.werte.get("wille", 0))) * (1.0 + fert / 100.0)))
			t.hp += n
			if f == t:
				_say(fmt(X.MSG72_HEALSSELF, lang, [f.name(lang), n]), f.id, t.id, 0, null, false, false, "HEAL")
			else:
				_say(fmt(X.MSG72_HEALS, lang, [f.name(lang), t.name(lang), n]), f.id, t.id, 0, null, false, false, "HEAL")
		"Z_HAUT", "Z_BANN":
			f.schutz += float(z.ruestung) * (1.0 + fert * float(k["ruestungsfertigkeit_im_abzug_je_punkt"]))
			if s == "Z_BANN":
				f.bann_genutzt = true
		"Z_BEISTAND":
			f.beistand = int(z.get("runden", 4))
			_say(fmt(X.MSG72_BLESSED, lang, [f.name(lang)]), f.id, f.id)


## 870.5: eine Kampfhandlung (werte.json „handlungen“, wie tools/sim444/handlungen.py duell)
func _handlung(f: Fighter, s: String, t) -> void:
	var h := _hw(s)
	match s:
		"H_KRAFT":
			var n := mini(f.max_hp - f.hp, roundi(f.max_hp * float(h.get("heilung_anteil", 0.25))))
			f.hp += n
			_say(fmt(MSG870_KRAFT, lang, [f.name(lang), n]), f.id, f.id, 0, null, false, false, "HEAL")
		"H_FINTE", "H_RUHIG":
			f.naechster = float(h.get("naechster_treffer", 0))
		"H_SCHILDWALL":
			f.schildwall = true
		"H_HINTERHALT":
			_weapon_attack(f, t, false, true, null, {"schaden": float(h.get("schaden_faktor", 1.0))})
		"H_WUCHT":
			_weapon_attack(f, t, false, true, null, {"treffer": float(h.get("treffer", 0)), "schaden": float(h.get("schaden_faktor", 1.0))})
		"H_ABSTAND":
			f.abstand = true
			_weapon_attack(f, t, false, true, null, {"treffer": float(h.get("treffer", 0))})
		"H_SCHAEDEL":
			var hp0: int = t.hp
			_weapon_attack(f, t, false, true, null, {"treffer": float(h.get("treffer", 0))})
			if t.hp < hp0 and outcome == "ONGOING" and t.standing() and dice.chance(float(h.get("betaeubt_chance", 0))):
				_inflict(t, "STUN", int(h.get("betaeubt_zuege", 1)))
		"H_GRIFF":
			t.gegriffen_von = f.id
			_weapon_attack(f, t, false, true, null, {"schaden": 0.5})
		"H_DURCH":
			_weapon_attack(f, t, false, true, null, {"ruestung": float(h.get("ruestung_anteil", 1.0))})
		"H_ZWEI":
			var tt = t
			for i in int(h.get("wuerfe", 2)):
				if outcome == "ONGOING" and tt != null:
					_weapon_attack(f, tt, false, true, null, {"schaden": float(h.get("schaden_faktor", 1.0))})
					tt = _again(f, tt, true)


# 72.10a.7, 223, 203, 208: what the rows and stances do to an attack roll.
func _row_mode(f: Fighter, t: Fighter, weapon: bool, extra := 0, cover := true) -> int:
	var dis := 0
	if cover and t.place.x == BACK and all.any(func(x): return x.side == t.side and x.standing() and x.place.x == FRONT):
		dis += 1
	# 870c 2 A: der Schütze der Gruppe schießt allein vorn ohne Nachteil; erst mit einem Gefährten neben ihm gilt die Regel
	if weapon and f.ranged() and f.place.x == FRONT and t.place.x == FRONT \
			and (f.side != "PARTY" or all.any(func(x): return x != f and x.side == f.side and x.standing() and x.place.x == FRONT)):
		dis += 1
	if weapon and cover and from_back(f):
		dis += 1
	if t.waited:
		dis += 1
	if t.hidden:
		dis += 1
	# 296.2: blinded, attacks at a disadvantage (as in the old fight)
	if f.status.has("BLIND"):
		dis += 1
	# 532 (alt Battle.kt 462: Blind und betrunken je eins): betrunken, Angriffe mit Nachteil
	if f.status.has("DRUNK"):
		dis += 1
	return clampi(extra - dis, -1, 1)


func from_back(f: Fighter) -> bool:
	return not f.ranged() and not f.reach() and _covers(f)


## Battle.fedBonus: +1, wenn der Held satt in den Kampf ging (nur der Held, nicht der Söldner)
func _fed(f: Fighter) -> int:
	return 1 if fed and f == lead() else 0


func _draw(f: Fighter) -> void:
	assert(f.spare() != null)
	f.drawn = not f.drawn
	_say(fmt(X.MSG72_DRAWS, lang, [f.name(lang), f.weapon()[["de", "en"][lang]]]), f.id)


## 296.2: the party can try to get away: a hero of the party, no boss among the foes (as in the old fight).
func can_flee(f: Fighter) -> bool:
	return f.side == "PARTY" and f.hero != null and not all.any(func(x): return x.side == "FOES" and x.standing() and x.boss())


## 870.5 (870a 5 A): Flucht als Probe in Prozent, Gewandtheit gegen den schnellsten stehenden Gegner (werte.json „proben“); vorher
## 296.2: the roll of the old fight (Battle flee): d20 + Dexterity (+2 for an elf) against 10 + the quickest standing
## foe's Dexterity save; cunning action always gets away. On success the fight ends as "FLED".
func _flee(f: Fighter) -> void:
	assert(can_flee(f))
	var schnell = null
	for x in all:
		if x.side == "FOES" and x.standing() and (schnell == null or _grundwert(x, "gewandtheit") > _grundwert(schnell, "gewandtheit")):
			schnell = x
	# 532 (alt Battle.kt 616): betrunken flieht er mit Ungunst
	var bonus := -absf(BrsKampf.nachteil()) if f.status.has("DRUNK") else 0.0
	if schnell == null or _probe(f, "gewandtheit", schnell, "gewandtheit", bonus):
		_say(fmt(MSG296_FLED, lang, [f.name(lang)]), f.id)
		outcome = "FLED"
	else:
		_say(fmt(MSG296_CANTFLEE, lang, []), f.id)


func _drink(f: Fighter, item: String, t: Fighter) -> void:
	assert(potions.get(item, 0) > 0 and t.standing() and t.side == f.side)
	potions[item] -= 1
	var def: Dictionary = items[item]
	# 532 (alt Battle.useItem: curable vor dem Heilen): der Kräutertrank nimmt alle Zustände, nur der Rausch bleibt bis zur Rast
	var heilt: bool = bool(def.get("cures", false)) and t.status.keys().any(func(k): return k != "DRUNK")
	if heilt:
		var rausch: bool = t.status.has("DRUNK")
		t.status.clear()
		if rausch:
			t.status["DRUNK"] = LASTING
	var n := maxi(0, mini(t.max_hp - t.hp, _heilung(t, item, def)))     # 478, 870.4
	t.hp += n
	var nm: String = [def.de, def.en][lang]
	if f == t:
		_say(fmt(X.MSG72_DRINKS, lang, [f.name(lang), nm, n]), f.id, t.id, 0, null, false, false, "DRINK")
	else:
		_say(fmt(X.MSG72_GIVES, lang, [f.name(lang), t.name(lang), nm, n]), f.id, t.id, 0, null, false, false, "DRINK")
	if heilt:
		_say(fmt(MSG532_CURED, lang, [t.name(lang)]), f.id, t.id, 0, null, false, false, "STATUS")


## 935 (alt Battle.useItem BOMB; gegenstaende.json: „ein Wurfgeschoss, das immer trifft“): der Wurf trifft immer; Schaden nach dem
## BRS aus werte.json „kampftraenke“ (Grundschaden × Wirkung nach Alchemie des Werfers, Schwäche nach der Schadensart, Rüstung
## ab), Gegenwirkung wie bei Zaubern (Wölfe fliehen vor Feuer, 915); Alchemistenfeuer setzt zwei Züge in Brand. Fliegt sichtbar wie
## Funkenpfeil bzw. Gleißstrahl (vorhandene Effekte, LISTE-EFFEKTE.md); 935 (Chef 11.11., 20:34): seitdem als Flasche im Bogen
func _throw(f: Fighter, item: String, t: Fighter) -> void:
	assert(potions.get(item, 0) > 0 and t in throw_targets(item))
	potions[item] -= 1
	var def: Dictionary = items[item]
	_say(fmt(THROWS, lang, [f.name(lang), [def.de, def.en][lang]]), f.id, t.id, 0, null, false, false, "THROW")
	var kt: Dictionary = BrsKampf.w().get("kampftraenke", {})
	var d: Dictionary = kt.get(String(def.get("brs", "")), {})
	# 935: Wirkung nach Alchemie wie in der Simulation 444 (sim.py wirkung, 857a A, 876); „Kräuterkunde“ gibt es seit 875 nicht mehr,
	# so blieb jeder Wurf bei der halben Wirkung (wirkung_grund 0,5)
	var alch := float(f.b.get("fert", {}).get("Alchemie", 0)) if f.b is Dictionary else 0.0
	var wirkung := clampf(float(kt.get("wirkung_grund", 1.0)) + float(kt.get("wirkung_je_alchemie", 0.0)) * alch, 0.0, float(kt.get("wirkung_max", 2.0)))
	var info := ["BRS", 0, 0, 100.0, true, 0, false, false]
	var typ = d.get("typ")
	var schw := _schwaeche(f, t, typ, info)
	var n := maxi(0, roundi(float(d.get("schaden", 0)) * wirkung * schw) - int(roundf(float(t.b.get("ruestung", 0)))))
	casting = "BOMB_HOLY" if String(typ) == "licht" else "BOMB_FIRE"     # 935: fliegt als Flasche im Bogen (zauber.gd _flask), wie alt
	_vor_treffer(t, typ)
	_hurt(t, n, f.id, fmt(wolf(f, "MSG279_WOLFHITS", "MSG72_HITS"), lang, [f.name(lang), t.name(lang), n]), info)
	casting = null
	_gegenwirkung(f, t, typ)
	if item == "alchemist_fire" and statuses and outcome == "ONGOING" and t.standing():
		_inflict(t, "BURN", 2)


## 870.4: ein Trank heilt fest wie in der Welt (werte.json „welt“ „heilung“, Leben nach BRS); 870.6: für jeden, ohne Würfel
func _heilung(_t: Fighter, item: String, _def: Dictionary) -> int:
	return int(BrsKampf.w().get("welt", {}).get("heilung", {}).get(item, 0))


## The Attack action: one blow (870.5: Extra-Angriff und Zweiwaffenkampf entfallen, 870a 3 A). Returns whom to strike next.
func _attack_action(f: Fighter, t: Fighter, advantage := false, cover := true):
	_weapon_attack(f, t, advantage, cover)
	return _again(f, t, true)


## 870.5: ein Schlag mit der Waffe nur nach dem BRS (_brs_waffe); [mod] einer Kampfhandlung: treffer (Prozentpunkte), schaden
## (Faktor), ruestung (Anteil der Rüstung des Ziels)
func _weapon_attack(f: Fighter, t: Fighter, advantage := false, cover := true, with_weapon = null, mod := {}) -> void:
	_brs_waffe(f, t, advantage, cover, with_weapon, mod)


## 296.2: a status on [t] for [turns] of its turns, as in the old fight: a hero may resist with a save, his tenacity or
## a dwarf's toughness against poison; a foe immune to it takes none, a boss shakes off a stun half the time.
## [save]: [ability, DC] or null.
func _inflict(t: Fighter, st: String, turns: int, save = null, die = null) -> bool:
	if outcome != "ONGOING" or not t.standing():
		return false
	if st == "STUN" and t.stun_guard > 0:
		return false
	var who := t.name(lang)
	var h = t.hero
	if h != null:
		if save != null:     # 870.5: Abwehrprobe in Prozent gegen den stärksten stehenden Gegner (werte.json „proben“)
			var P := _proben()
			var gegen = _staerkster_gegner(t)
			var schwere := (int(save[1]) - int(P.get("abwehr_mitte", 11))) * float(P.get("je_punkt", 5))
			if gegen != null and _probe(t, String(save[0]), gegen, "", -schwere + float(t.b.get("zusatz", {}).get("abwehr", 0))):     # 870.6: Abwehrprobe der Ausrüstung
				_say(fmt(ST_SHRUGS, lang, [who]), null, t.id)
				return false
		var ten := int(t.b.get("zusatz", {}).get("abwehr", 0)) if save == null else 0     # 870.6: Abwehrprobe der Ausrüstung (alt Standhaftigkeit)
		if ten > 0 and dice.chance(ten / 100.0):
			_say(fmt(ST_STEADFAST, lang, [who]), null, t.id)
			return false
		if st == "POISON" and _volk(t) == "Zwerg" and dice.chance(0.5):     # Steinblut (Wirkung wie bisher, bis 444)
			_say(fmt(ST_DWARF, lang, [who]), null, t.id)
			return false
	else:
		if Zustaende.immune(t.monster, st):     # 390: wie Status.immune im alten Kampf (Skelett, Zombie, Ockergallert bluten nicht)
			return false
		if t.boss() and st == "STUN" and dice.chance(0.5):
			_say(fmt(ST_SHAKES, lang, [who]), null, t.id)
			return false
	t.status[st] = maxi(int(t.status.get(st, 0)), turns)
	if st == "POISON" and die != null:
		t.gift = float(die)
	if st == "STUN":
		t.stun_guard = 3
	_say(fmt(ST_GAINED[st], lang, [who]), null, t.id, 0, null, false, false, "STATUS")
	return true


## 296.2: the start of [f]'s turn, as in the old fight: poison, burning and bleeding hurt, then every status counts
## down a turn. True when the turn is lost (stunned).
func _tick(f: Fighter) -> bool:
	if f.stun_guard > 0:
		f.stun_guard -= 1
	var who := f.name(lang)
	# counted down first, so the lines that follow show the turns now left
	var hurting := ["POISON", "BURN", "BLEED"].filter(func(st): return f.status.has(st))
	var stunned := f.status.has("STUN")
	var ended := []
	for st in f.status.keys():
		var left := int(f.status[st])
		if left >= LASTING:
			continue
		if left <= 1:
			f.status.erase(st)
			ended.append(st)
		else:
			f.status[st] = left - 1
	for st in hurting:
		if outcome != "ONGOING" or not f.standing():
			break
		if f.monster != null and Zustaende.immune(f.monster, st):
			continue
		# 870.6: Anteil am vollen Leben (werte.json „zustaende“ „schaden_anteil“), ein schwächeres Gift nach seiner Stärke
		var anteil := float(_zw().get("schaden_anteil", {}).get(st, 0.08))
		if st == "POISON":
			anteil *= f.gift
			if _volk(f) == "Zwerg":
				anteil *= 0.5
		var dmg: int = _anteil(f, anteil)
		_hurt(f, dmg, "", fmt(ST_HURTS[st], lang, [who]) + " " + fmt(MSG296_DAMAGE, lang, [dmg]))
	if outcome != "ONGOING" or not f.standing():
		return false
	if stunned:
		_say(fmt(ST_STUNNED, lang, [who]), f.id, null, 0, null, false, false, "STATUS")
	for st in ended:
		if st != "STUN":
			_say(fmt(ST_ENDS, lang, [who, STATUS[st][0][lang].to_lower()]), null, f.id)
	return stunned


## 296.2: what a foe's landed blow does besides the damage: its kind's own special (unless MARS gives it intents of its own).
## 870.6a 3 A (Chef 11.11., 13:55): Gegner treffen nach dem BRS nie kritisch; Blutung und Betäubung nur über Sonderregeln.
func _foe_wounds(foe: Fighter, t: Fighter) -> void:
	var m: Dictionary = foe.monster
	var first := not foe.has_hit
	foe.has_hit = true
	if art_of(m) in OWN_INTENTS:
		return
	match str(m.get("special", "NONE")):
		"POISON":
			_inflict(t, "POISON", 3, ["zaehigkeit", 11], float(m.get("gift", 1.0)))
		"SURPRISE_ATTACK":
			if first:
				_inflict(t, "STUN", 1, ["zaehigkeit", 12])
		"EVASIVE":
			if dice.chance(0.2):
				_inflict(t, "BLIND", 2, ["zaehigkeit", 10])
		"BLOOD_DRAIN":
			if dice.chance(0.3):
				_inflict(t, "BLEED", 2)
		"PARALYZE":     # 506: Grabhund
			if _volk(t) == "Elf":
				_say(fmt(MSG506_ELF, lang, [t.name(lang)]), t.id)
			else:
				_inflict(t, "STUN", 1, ["zaehigkeit", 10])


func _foe_turn(foe: Fighter, react: Callable) -> void:
	if not intents.has(foe.id):
		announce(foe)
		_say_announce(foe)
		return
	var plan: Array = intents[foe.id]
	intents.erase(foe.id)
	var intent: Dictionary = plan[0]
	var aimed: Array = plan[1]
	foe.hidden = false
	if _test_zug(foe):     # 1020.2 C
		return
	if intent.effect == "GROWL":     # 399.2b: knurrt nur (Homer [399.2b.knurrt])
		_say(fmt(pick("MSG399_GROWLS"), lang, [foe.name(lang)]), foe.id, null, 0, null, false, false, "GROWLS")
		_eingebung("growl")     # 986 (1): Knurren hat keine Ansage im Bericht
		announce(foe)
		_say_announce(foe)
		return
	var cue := ""
	if intent.effect == "CIRCLE":
		cue = "CIRCLE"
	elif intent.kind == "STRIKE":
		cue = "FOE_STRIKES"
	_say(fmt(X.MSG72_FOEUSES, lang, [foe.name(lang), intent.name[lang]]), foe.id, null, 0, null, false, false, cue)
	if intent.effect == "SHADOW":
		foe.hidden = true
		_say(fmt(pick("MSG130_GONE"), lang, [foe.name(lang)]), foe.id)
		announce(foe)
		_say_announce(foe)
		return
	match intent.kind:
		"CALL":
			_summon(foe)
		"GATHER":
			if intent.effect != "CIRCLE":
				var heal := mini(foe.max_hp - foe.hp, _anteil(foe, float(_zw().get("sammeln_anteil", 0.5))))     # 870.6: Anteil seines Lebens
				foe.hp += heal
				_say(fmt(X.MSG72_GATHERS, lang, [foe.name(lang), heal]), foe.id, foe.id, 0, null, false, false, "GATHER")
	var r := targets(foe)
	var first_aimed = null
	for x in r:
		if x.id in aimed:
			first_aimed = x
			break
	if first_aimed == null and not r.is_empty():
		first_aimed = r[0]
	var hit := []
	if intent.kind == "STRIKE" and first_aimed != null:
		hit = [first_aimed]
	if intent.effect == "CIRCLE":
		var t = first_aimed
		if t != null:
			_say(fmt(pick("MSG130_CIRCLECLOSED"), lang, [foe.name(lang)]), foe.id)
			for w in all.filter(func(x): return x.side == "FOES" and x.standing() and wolfig(x.monster)):
				if outcome != "ONGOING" or not t.standing():
					break
				_strike(w, t, I_STAB, NONE)
	if intent.effect == "BREAKTHROUGH" or intent.effect == "FLANK":
		_lineup_attack(foe, intent, aimed, react)
		if outcome != "ONGOING":
			return
		announce(foe)
		_say_announce(foe)
		return
	for t in hit:
		if intent.effect == "POUNCE" and t.place != aim_spot.get(foe.id):
			_say(fmt(pick("MSG130_POUNCEEMPTY"), lang, [foe.name(lang)]), foe.id)
			continue
		if intent.effect == "AIM" and t.waited:
			_say(fmt(pick("MSG130_DUCKS"), lang, [foe.name(lang), t.name(lang)]), foe.id, t.id, 0, null, false, false, "DUCKED")
			continue
		var re := NONE
		if not intent.ring and not (foe.id in t.cover_from):
			re = NONE
		elif _piloted(t) or t.auto:
			re = GOOD
		else:
			re = _ring(react, t, intent)
		_strike(foe, t, intent, re, true, retargeted.has(foe.id))
		if outcome != "ONGOING":
			return
	announce(foe)
	_say_announce(foe)


func _ring(react: Callable, t: Fighter, intent: Dictionary) -> String:
	return GOOD if not react.is_valid() else react.call(t, intent)


func _lineup_attack(foe: Fighter, intent: Dictionary, aimed: Array, react: Callable) -> void:
	var t = find(aimed[0]) if not aimed.is_empty() else null
	if t != null and not t.standing():
		t = null
	if t == null:
		var r := targets(foe)
		if not r.is_empty():
			_strike(foe, r[0], I_STAB, NONE)
		return
	if foe.id in t.cover_from:
		var re := GOOD if _piloted(t) or t.auto else _ring(react, t, intent)
		_strike(foe, t, intent, re, false)
		return
	if intent.effect == "FLANK":
		if t.place != aim_spot.get(foe.id):
			_say(fmt(X.MSG72_FLANKEMPTY, lang, [foe.name(lang), t.name(lang)]), foe.id, t.id)
		else:
			_strike(foe, t, intent, NONE, false)
		return
	if t.place.x == FRONT:
		_say(fmt(X.MSG72_BRACED, lang, [foe.name(lang), t.name(lang)]), foe.id, t.id)
		_strike(foe, t, I_STAB, NONE)
		return
	var front := all.filter(func(x): return x.side == t.side and x.standing() and x.place.x == FRONT)
	var shoved = null
	for x in front:
		if x.place.y == t.place.y:
			shoved = x
			break
	if shoved == null and not front.is_empty():
		shoved = front[0]
	if shoved != null:
		var spot: Vector2i = shoved.place
		shoved.place = t.place
		t.place = spot
		_say(fmt(X.MSG72_BREAKSTHROUGH, lang, [foe.name(lang), shoved.name(lang)]), foe.id, shoved.id)
	var re2 := GOOD if _piloted(t) or t.auto else _ring(react, t, intent)
	_strike(foe, t, intent, re2)


func _strike(foe: Fighter, t: Fighter, intent: Dictionary, re: String, cover := true, retarget := false) -> void:
	var m: Dictionary = foe.monster
	# 870.5 Schildwall: ein Gefährte daneben mit Schildwall fängt den Schlag (einmal, mit seiner Abwehr)
	for x in all:
		if x != t and x.side == t.side and x.standing() and x.schildwall and x.place.x == t.place.x and absi(x.place.y - t.place.y) == 1:
			x.schildwall = false
			t = x
			break
	# 870.5 Auf Abstand: wer ihn im Nahkampf angreift, läuft zuerst in die Spitze
	if t.abstand and t.standing() and t.hero != null and String(foe.b.get("art", "nah")) == "nah":
		_weapon_attack(t, foe, false, false, null, {"schaden": float(_hw("H_ABSTAND").get("gegenstoss_faktor", 0.5))})
		if outcome != "ONGOING" or not foe.standing():
			return
	var mode := _row_mode(foe, t, true, -1 if retarget else 0, cover)
	var e := _brs_auf_held(foe, t, intent, mode)     # 870.5: nur nach dem BRS
	var success: bool = e.treffer
	var info := ["BRS", e.wurf, 0, e.chance, success, mode, cover and from_back(foe), bool(e.kritisch)]
	if test_ausweichen and t.id == "hero":     # 1020.2 C: der Held weicht aus
		test_ausweichen = false
		test_erzwungen.append("ausweichen")
		success = false
		info[4] = false
	if str(m.id) == KROGG and smoke_thrown and not smoke_spent:
		# D4.1: der Rauch brennt in den Augen, der erste Schlag geht fehl, mit ihm der Überraschungsschlag (Battle.enemyAttack)
		smoke_spent = true
		foe.has_hit = true
		success = false
		info[4] = false
	# 863 (Chef 10.11., 13:19, t274.15: „bei den Wölfen … tauscht er mit einem den Platz, der in der vorderen Reihe steht … Machen die
	# Ratten jetzt aber anscheinend nicht“; platztausch_863): jeder Nahkämpfer, der aus der hinteren Reihe angreift, tauscht wie das
	# Anspringen (285) mit dem vorderen, statt nach vorn und wieder ganz zurück zu laufen; Fernkampf und Zauber bleiben hinten
	if intent.effect == "POUNCE" or (foe.side == "FOES" and String(foe.b.get("art", "nah")) == "nah"):
		_leap_forward(foe)
	if re == PERFECT:
		_perfect_answer(t, foe, info)
		return
	if not success:
		_say(fmt(wolf(foe, "MSG279_WOLFMISSES", "MSG72_MISSES"), lang, [foe.name(lang), t.name(lang)]), foe.id, t.id, 0, info)
		return
	var dmg := int(e.schaden)
	var G: Dictionary = BrsKampf.w().get("gegenwirkung", {})
	if foe.rasend:     # 870.5 Gegenwirkung Wildschwein
		dmg = roundi(dmg * float(G.get("rasend_schaden", 1.5)))
	if art_of(m) == "stirge" and t.status.has("BLEED"):     # 870.5 Gegenwirkung Blutflügler
		dmg = roundi(dmg * float(G.get("blut_schaden", 1.5)))
		if not schwaeche_gesagt.has("gegen|stirge"):
			schwaeche_gesagt["gegen|stirge"] = true
			_say(fmt(MSG870_GEGEN_FLUEGER, lang, [foe.name(lang)]), foe.id, t.id)
	if re != NONE:
		_say(fmt(pick("MSG72_EVADES" if re == PERFECT else "MSG72_GOOD"), lang, [t.name(lang)]), t.id)
	dmg = int(dmg * SHARE[re])
	if dmg > 0:     # 478: kein Mindestschaden (Modell D: ein Kratzer kann 0 sein)
		dmg = roundi(dmg * _schaden_faktor(foe))     # 870.6: Schwächung als Faktor
	if intent.id == "venom":
		_say(fmt(pick("MSG130_VENOMHITS"), lang, [foe.name(lang), t.name(lang)]), foe.id, t.id, 0, null, false, false, "VENOM")
	if dmg > 0:
		_hurt(t, dmg, foe.id, fmt(wolf(foe, "MSG279_WOLFHITS", "MSG72_HITS"), lang, [foe.name(lang), t.name(lang), dmg]), info, true)
	if outcome != "ONGOING" or not t.standing():
		return
	if statuses:
		_foe_wounds(foe, t)
		if outcome != "ONGOING" or not t.standing():
			return
	match intent.effect:
		"POUNCE":
			t.held = true
			t.prone = true
			_say(fmt(pick("MSG547_STOSS" if sturz_zwischentext else "MSG130_POUNCEHITS"), lang, [foe.name(lang), t.name(lang)]), foe.id, t.id, 0, null, false, false, "POUNCED")
		"WEB":
			t.held = true
			_say(fmt(pick("MSG130_WEBHOLDS"), lang, [foe.name(lang), t.name(lang)]), foe.id, t.id, 0, null, false, false, "WEB")


# 72.10a.9, 219.3, 219.4, 336: what a perfect ring gives besides the blow caught. 870.5 (870a 3 A, ohne Klassen): nach dem, was
# er kann, in dieser Folge: Zauberer der Evokation ohne Nahkampfwaffe flammt zurück (Funkenpfeil, ohne Mana), mit Dolch tritt er
# hinter den Gegner, wer Wundsegen kennt, betet (Wundsegen ohne Mana), mit Nahkampfwaffe schlägt er zurück; sonst nur ausweichen.
func _perfect_answer(t: Fighter, foe: Fighter, info: Array) -> void:
	var art := ""
	if t.hero != null:
		var w = t.weapon()
		var gruppe := BrsKampf.waffe_held(t.b, w if w != null else t.hero.main, w != null and w != t.main_weapon())
		var nah := String(BrsKampf.w()["waffen"].get(gruppe, {}).get("art", "nah")) == "nah" and gruppe != "Faustkampf"
		if not nah and ("Z_FUNKEN" in t.zauber or "Z_ARKAN" in t.zauber):
			art = "FLAMMEN"
		elif gruppe == "Dolche":
			art = "HINTER"
		elif "Z_WUND" in t.zauber:
			art = "GEBET"
		elif nah:
			art = "SCHLAG"
	match art:
		"SCHLAG":
			_say(fmt(X.MSG72_STRIKESBACK, lang, [t.name(lang), foe.name(lang)]), t.id, foe.id, 0, null, true)
			_weapon_attack(t, foe)
		"HINTER":
			_say(fmt(X.MSG72_STEPSBEHIND, lang, [t.name(lang), foe.name(lang)]), t.id, foe.id, 0, null, true, false, "BEHIND")
			_weapon_attack(t, foe, true, false)
		"GEBET":
			_say(fmt(X.MSG72_PRAYS, lang, [t.name(lang)]), t.id, null, 0, null, true)
			var z: Dictionary = BrsKampf.w()["zauber"]["Wundsegen"]
			var n := mini(t.max_hp - t.hp, roundi((float(z.heilung) + float(t.b.werte.get("wille", 0))) * (1.0 + float(t.b.fert.get(String(z.schule), 0)) / 100.0)))
			t.hp += n
			_say(fmt(X.MSG72_HEALSSELF, lang, [t.name(lang), n]), t.id, t.id, 0, null, false, false, "HEAL")
		"FLAMMEN":
			_say(fmt(X.MSG72_FLAMESBACK, lang, [t.name(lang), foe.name(lang)]), t.id, foe.id, 0, null, true)
			casting = "FIRE_BOLT"
			_brs_zauber(t, foe, BrsKampf.w()["zauber"]["Funkenpfeil"])
			casting = null
		_:
			_say(fmt(pick("MSG72_EVADES"), lang, [t.name(lang)]), foe.id, t.id, 0, info)


## 1020.2 C: erzwungene Gegnerzüge aus dem Reiter Test, die nicht über die Ansage gehen. „reihe“: ein Nahkämpfer der hinteren Reihe
## tauscht vor diesem Zug nach vorn (wie 863 _leap_forward; der Kampfort lässt ihn im Zug der Gegner hinübergehen); „flucht“: alle
## Gegner fliehen wie das Rudel vor dem Feuer (870c 3 A), ohne Lohn. Gibt true zurück, wenn der Zug damit zu Ende ist.
func _test_zug(foe: Fighter) -> bool:
	if test_gegnerzug == "reihe":
		var hinten := all.filter(func(x): return x.side == "FOES" and x.standing() and x.place.x == BACK and x.gegriffen_von == "" and String(x.b.get("art", "nah")) == "nah")
		if not hinten.is_empty() and all.any(func(x): return x.side == "FOES" and x.standing() and x.place.x == FRONT):
			test_gegnerzug = ""
			var vorher: Vector2i = hinten[0].place
			_leap_forward(hinten[0])
			if hinten[0].place != vorher:
				test_erzwungen.append("reihe")
	elif test_gegnerzug == "flucht":
		test_gegnerzug = ""
		var erst := true
		for x in all.filter(func(x): return x.side == "FOES" and x.standing()):
			x.fled = true
			intents.erase(x.id)
			_say(MSG1020_FLIEHEN[lang] if erst else "", null, x.id, 0, null, false, false, "FOE_FLEES")
			erst = false
		kein_lohn = true
		outcome = "WON"
		test_erzwungen.append("flucht")
		return true
	return false

const MSG1020_FLIEHEN := ["Test: alle Gegner fliehen.", "Test: every foe flees."]     # Zeile des Testmodus, kein Spieltext

## The foe picks its next move and its target (72.11).
func announce(foe: Fighter) -> void:
	if not foe.standing() or outcome != "ONGOING":
		return
	# 399.2b (Chef 28.10., 15:32, Archiv: Jungwölfe beißen wie im alten Spiel nur zu 50 % je Runde; Packs.kt chance; Chefsache 3992b
	# „knurrt nur und kündigt keinen Biss an“): wer einem Leittier folgt, sagt nur mit seiner Chance einen Angriff an, sonst Knurren
	if foe.follows != "" and foe.monster.has("chance") and not dice.chance(float(foe.monster.chance)):
		foe.taken_since_announce = 0
		intents[foe.id] = [I_GROWL, []]
		retargeted.erase(foe.id)
		return
	var intent := _pick_intent(foe)
	var r := _covered() if intent.effect == "BREAKTHROUGH" or intent.effect == "FLANK" else targets(foe)
	var aimed := []
	if not ((intent.kind != "STRIKE" and intent.effect != "CIRCLE") or r.is_empty()):
		aimed = [dice.pick(r).id]
	foe.taken_since_announce = 0
	intents[foe.id] = [intent, aimed]
	retargeted.erase(foe.id)
	if not aimed.is_empty():
		aim_spot[foe.id] = by_id(aimed[0]).place


func _covered() -> Array:
	var party := all.filter(func(x): return x.side == "PARTY" and x.standing())
	if not party.any(func(x): return x.place.x == FRONT):
		return []
	return party.filter(func(x): return x.place.x == BACK)


# 285: a pounce from the back row ends in front; the friend leapt over steps back into its place.
func _leap_forward(foe: Fighter) -> void:
	if foe.gegriffen_von != "":     # 870.5 Griff: kommt nicht vom Fleck
		return
	if foe.place.x != BACK:
		return
	var ahead := all.filter(func(x): return x.side == foe.side and x != foe and x.standing() and x.place.x == FRONT)
	var over = null
	for x in ahead:
		if x.place.y == foe.place.y:
			over = x
			break
	if over == null and not ahead.is_empty():
		over = ahead[0]
	var to = null
	if over != null:
		to = over.place
	else:
		var s := Vector2i(FRONT, foe.place.y)
		if not all.any(func(x): return x.side == foe.side and x.place == s and x.standing()):
			to = s
		else:
			for sp in SPOTS:
				if sp.x == FRONT and not all.any(func(x): return x.side == foe.side and x.place == sp and x.standing()):
					to = sp
					break
	if to == null:
		return
	for x in all:
		if x.side == foe.side and x != foe and x != over and x.place == to:
			x.place = foe.place
			break
	if over != null:
		over.place = foe.place
	foe.place = to


func _free_foe_spot(back := false):
	var free := []
	for s in SPOTS:
		if not all.any(func(x): return x.side == "FOES" and x.place == s and x.standing()):
			free.append(s)
	if back:
		for s in free:
			if s.x == BACK:
				return s
	return free[0] if not free.is_empty() else null


func _pick_intent(foe: Fighter) -> Dictionary:
	var id := art_of(foe.monster)
	if id == RAT or id == BAT or id == "ghoul":     # 535; 506 Grabhund
		return I_BITE
	if id == "zombie":     # 506 Wiedergänger
		return I_CLAW
	if id == SHAMAN:     # 535: Heilen, Fluch, Feuerstoß des Schamanen fehlen noch (Ansagen über Homer); bis dahin kämpft er wie ein Goblin
		id = CALLED
	if id == WOLF or id == DIRE_WOLF:
		if test_gegnerzug == "pounce":     # 1020.2 C
			test_gegnerzug = ""
			test_erzwungen.append("pounce")
			return I_POUNCE
		var others := all.filter(func(x): return x.side == "FOES" and x.standing() and wolfig(x.monster)).size()
		var circling := intents.values().any(func(p): return p[0].effect == "CIRCLE")
		var can := [I_POUNCE, I_POUNCE]
		# 986 (3): die Leibwache ist nicht angreifbar, sagt also kein Einkreisen an ([986.circle] „Den treffen“)
		if others >= 2 and not circling and chosen and foe.angreifbar():
			can.append(I_CIRCLE)
		return dice.pick(can)
	if id == SPIDER:
		return dice.pick([I_VENOM, I_WEB])
	if id == SCOUT:
		return I_AIM if foe.hidden else dice.pick([I_AIM, I_AIM, I_SHADOW])
	var lineup := not _covered().is_empty()
	var plain: Dictionary = I_SLASH if id == CALLED else I_STAB
	if id == CALLED:
		var can2 := [plain, plain]
		if lineup:
			can2.append(I_FLANK)
		return dice.pick(can2)
	if id != GRAK:
		return plain
	if test_gegnerzug == "heavy":     # 1020.2 C
		test_gegnerzug = ""
		test_erzwungen.append("heavy")
		return I_HEAVY
	var can3 := [I_HEAVY, I_HEAVY]
	if lineup:
		can3.append(I_BREAKTHROUGH)
	if called < CALL_MAX and _free_foe_spot() != null:
		can3.append(I_CALL)
	if foe.hp * 2 < foe.max_hp:
		can3.append(I_GATHER)
	return dice.pick(can3)


func _say_announce(foe: Fighter) -> void:
	if not intents.has(foe.id):
		return
	var intent: Dictionary = intents[foe.id][0]
	if intent.effect == "GROWL":
		return
	var aimed: Array = intents[foe.id][1]
	var target: String = by_id(aimed[0]).name(lang) if not aimed.is_empty() else ""
	var nm: String = intent.name[lang]
	if intent.effect in AT_TARGET:
		nm = nm + " " + fmt(X.MSG130_AT, lang, [target])
	_say(fmt(X.MSG72_ANNOUNCES, lang, [foe.name(lang), nm]), foe.id)
	var key := "MSG130_SIGN_" + str(intent.id).to_upper()
	if TX.has(key):
		_say(fmt(pick(key), lang, [foe.name(lang), "", target]), foe.id)
	_eingebung(str(intent.id))


## 840, 986: Eingebung des Helden zu einer Ansage, einmal je Spielstand, gleich nach ihrer ersten Zeile im Bericht
func _eingebung(id: String) -> void:
	var nr := GESEHEN_EINGEBUNG + id
	if EINGEBUNG.has(id) and not gesehen.has(nr):
		gesehen[nr] = true
		_say(EINGEBUNG[id][lang], null, null, 0, null, false, false, "EINGEBUNG")


func _summon(by: Fighter) -> void:
	var scout := called >= 1
	var spot = _free_foe_spot(scout)
	if spot == null:
		return
	for gone in all:
		if gone.side == "FOES" and gone.place == spot:
			if order.find(gone) < turn:
				turn -= 1
			all.erase(gone)
			order.erase(gone)
			break
	var m: Dictionary = monsters[SCOUT if scout else CALLED]
	called += 1
	var g := monster_fighter("gob%d" % called, spot, m, dice.roll_expr(m.hp))
	_brs_kaempfer(g)     # 478
	g.initiative = _initiative(g)
	g.called_in = true
	var kin := all.filter(func(x): return x.monster != null and x.monster.id == m.id)
	if not kin.is_empty():
		var top := 0
		for k in kin:
			if k.nr == 0:
				k.nr = 1
		for k in kin:
			top = maxi(top, k.nr)
		g.nr = maxi(numbered.get(m.id, 0), top) + 1
	numbered[m.id] = maxi(numbered.get(m.id, 0), g.nr)
	all.append(g)
	order.insert(order.find(by) + 1, g)
	_say(fmt(X.MSG72_ANSWERS, lang, [[m.de, m.en][lang]]), g.id)
	announce(g)
	_say_announce(g)     # 986 (2): auch der Gerufene sagt im Bericht an (und bringt so seine Eingebung)


func _hurt(t: Fighter, full: int, by: String, text: String, roll = null, wound := false) -> void:
	var dmg := int(full * quick_harm()) if quick_run and t.side == "PARTY" else full
	var floor_hp := 1 if (not chosen and t.side == "PARTY" and t.hp > 0) or (held_unsterblich and t == lead()) else 0
	# 534 (alt Battle.hitHero, Rasse Orkblütig): einmal je Kampf bleibt er mit 1 TP stehen
	var unerbittlich := floor_hp == 0 and t.side == "PARTY" and _volk(t) == "Orkblütiger" \
			and t.hp > 0 and t.hp <= dmg and not relentless_used.has(t.id)
	if unerbittlich:
		relentless_used[t.id] = true
		floor_hp = 1
	# 506 (alt Battle.dealDamage): Untotenzähigkeit des Wiedergängers
	var zaeh: bool = floor_hp == 0 and t.side == "FOES" and t.monster != null and str(t.monster.get("special", "")) == "UNDEAD_FORTITUDE" and not t.kein_zaeh \
			and t.hp > 0 and t.hp <= dmg and by != "" and not krit_jetzt \
			and _zaeh_haelt(t, dmg)
	if zaeh:
		floor_hp = 1
	t.hp = maxi(t.hp - dmg, floor_hp)
	_say(text, by if by != "" else null, t.id, dmg, roll, false, wound)
	if unerbittlich:
		_say(fmt(MSG534_RELENTLESS, lang, [t.name(lang)]), t.id)
	if zaeh:
		_say(fmt(MSG506_FORTITUDE, lang, [t.name(lang)]), t.id)
	if t.standing():
		# 296.2: no one's blow (a status hurting at the turn's start) breaks no intent
		if by == "" or not intents.has(t.id):
			return
		var plan: Array = intents[t.id]
		t.taken_since_announce += dmg
		if (plan[0].breakable and t.taken_since_announce * BREAK_SHARE >= t.max_hp) or (plan[0].break_any and dmg > 0):
			intents.erase(t.id)
			_say(fmt(pick("MSG72_BROKEN"), lang, [t.name(lang), plan[0].name[lang]]), null, t.id)
		return
	if t.side == "FOES":
		intents.erase(t.id)
		_say(fmt(wolf(t, "MSG279_WOLFFALLS", "MSG72_FALLS"), lang, [t.name(lang)]), null, t.id, 0, null, false, false, "FOE_FALLS")
		if t.kein_zaeh:     # 870.5 Gegenwirkung Zombie
			_say(fmt(MSG870_GEGEN_ZOMBIE, lang, [t.name(lang)]), null, t.id)
		_pack_flees(t)
	elif t == all[0]:
		_say(fmt(pick("MSG72_HEROFALLS"), lang, [t.name(lang)]), null, t.id, 0, null, false, false, "HERO_FALLS")
		outcome = "LOST"
		return
	else:
		knockouts += 1
		_say(fmt(pick("MSG72_KNOCKEDOUT"), lang, [t.name(lang)]), null, t.id, 0, null, false, false, "KNOCKED_OUT")
	if not all.any(func(x): return x.side == "FOES" and x.standing()):
		outcome = "WON"


## 399.2a: when [leader] falls, those who follow it run (Packs.kt flee: one line for all, as in the old fight)
func _pack_flees(leader: Fighter) -> void:
	var first := true
	for f in all.filter(func(x): return x.side == "FOES" and x.standing() and x.follows == leader.id and x.gegriffen_von == ""):     # 870.5 Griff
		f.fled = true
		intents.erase(f.id)
		_say(str(f.monster.flee[lang]) if first and f.monster.has("flee") else "", null, f.id, 0, null, false, false, "FOE_FLEES")
		first = false


## One message with the state right after it, for the screen (SkirmishEvent).
func _say(text: String, actor = null, target = null, damage := 0, roll = null, answer := false, wound := false, cue := "") -> void:
	var hp := {}
	var places := {}
	var sp := {}
	for f in all:
		hp[f.id] = f.hp
		places[f.id] = f.place
		sp[f.id] = f.sp
	var e := {
		"text": text, "actor": actor, "target": target, "damage": damage, "hp": hp, "places": places,
		"intents": intents.duplicate(), "roll": roll, "queue": queue(), "sp": sp, "answer": answer, "wound": wound,
		"spell": casting, "cue": cue if cue != "" else null,
		"status": _statuses(), "hidden": _hidden(),
	}
	_log.append(e)
	if not quick_run and listener.is_valid():
		listener.call(e)


## 566: who stands in the shadows now (hidden until its next turn), for the figure seen only dimly.
func _hidden() -> Dictionary:
	var out := {}
	for f in all:
		if f.hidden:
			out[f.id] = true
	return out


## 296.2: the statuses of each figure that has any, with the turns left, for their signs on the screen.
func _statuses() -> Dictionary:
	var out := {}
	for f in all:
		if not f.status.is_empty():
			out[f.id] = f.status.duplicate()
	return out


# ---------------------------------------------------------------- 478: Schläge nach dem BRS (Modell D, brs_kampf.gd)

## Vorteil und Nachteil des MARS (mode −1..1) und Segen, Sättigung, Schwächung (Punkte auf den W20) als Prozentpunkte der Trefferchance
func _brs_bonus(mode: int, prozent: float) -> float:
	return float(mode) * absf(BrsKampf.nachteil()) + prozent


## 870.6: Prozentpunkte auf die Trefferchance aus Verlangsamt, Geschwächt, Sättigung (werte.json „zustaende“ „treffer“)
func _treffer_mod(f: Fighter, nur_satt := false) -> float:
	var t: Dictionary = _zw().get("treffer", {})
	var p := float(t.get("satt", 5)) if _fed(f) > 0 else 0.0
	if not nur_satt:
		for st in ["SLOW", "WEAK"]:
			if f.status.has(st):
				p += float(t.get(st, -10))
	return p


## 870.6: Faktor auf den Schaden aus Geschwächt und Sättigung (werte.json „zustaende“ „schaden_faktor“)
func _schaden_faktor(f: Fighter) -> float:
	var s: Dictionary = _zw().get("schaden_faktor", {})
	var x := 1.0
	if f.status.has("WEAK"):
		x *= float(s.get("WEAK", 0.8))
	if _fed(f) > 0:
		x *= float(s.get("satt", 1.1))
	return x


## Held oder Söldner schlägt mit der Waffe: Fertigkeit der Waffengruppe gegen die Abwehr des Gegners, Schaden (Waffe + Grundwert)
## × (1 + Fertigkeit/100) × Stufenfaktor, kritisch nach zweitem Grundwert und Fertigkeit (952 D), minus Rüstung (sim.py kampf, Held handelt)
func _brs_waffe(f: Fighter, t: Fighter, advantage: bool, cover: bool, with_weapon, mod := {}) -> void:
	var mode := _row_mode(f, t, true, 1 if advantage else 0, cover)
	var w = with_weapon if with_weapon != null else f.weapon()
	var wsheet: Dictionary = w if w != null else f.hero.main
	var W := BrsKampf.w()
	var k: Dictionary = W["kampf"]
	var gruppe := BrsKampf.waffe_held(f.b, wsheet, w != null and w != f.main_weapon())     # 870.2: Haupt- aus dem Kampfblatt
	var wd: Dictionary = W["waffen"].get(gruppe, W["waffen"]["Faustkampf"])
	var gw = wd.get("grundwert")
	var zweite: bool = w != null and w != f.main_weapon()
	var grund := float(wd["schaden"]) * (1.0 if zweite else float(f.b.get("waffe_faktor", 1.0))) + (float(f.b.werte.get(gw, 0)) if gw != null else 0.0)     # 870.6: Güte
	var bonus := _brs_bonus(mode, _treffer_mod(f))
	if String(wd.get("art", "nah")) == "fern":
		bonus += float(k["fernkampf_treffer_je_wahrnehmung"]) * float(f.b.werte.get("wahrnehmung", 0))
	bonus += float(mod.get("treffer", 0.0)) + f.naechster + _beistand(f)     # 870.5: Kampfhandlung, Finte, Ruhige Hand, Beistand
	f.naechster = 0.0
	f.geschlagen = true
	grund *= float(mod.get("schaden", 1.0))
	var e := BrsKampf.schlag(dice.rng, float(f.b.fert.get(gruppe, 0)), float(t.b.abwehr), grund, float(int(f.b.stufe) - int(t.b.stufe)),
			float(t.b.ruestung) * float(mod.get("ruestung", 1.0)), bonus, BrsKampf.krit_prozent(f.b.werte, gruppe, float(f.b.fert.get(gruppe, 0)))
			+ float(f.b.get("zusatz", {}).get("krit", 0)))     # 870.6: kritisch der Zusatzeigenschaften
	if held_immer_krit and f == lead() and e.treffer and not e.kritisch:     # Testmenü „Kritisch“
		e.kritisch = true
		e.schaden = float(BrsKampf.Brs.runde(float(e.schaden) * float(k["kritisch_faktor"])))
	var hit: bool = e.treffer
	var flattert: bool = hit and t.monster != null and art_of(t.monster) == BAT and not bool(wsheet.get("ranged", false)) and dice.chance(FLUTTER)
	if flattert:
		hit = false
	var info := ["BRS", e.wurf, 0, e.chance, hit, mode, cover and from_back(f), e.kritisch]
	if flattert:
		_say(fmt(MSG535_FLUTTERS, lang, [t.name(lang)]), f.id, t.id, 0, info)
		return
	if not hit:
		_say(fmt(wolf(f, "MSG279_WOLFMISSES", "MSG72_MISSES"), lang, [f.name(lang), t.name(lang)]), f.id, t.id, 0, info)
		return
	var schw := _schwaeche(f, t, wd.get("typ"), info)     # 870.5 (870a 8 A)
	var n := roundi(float(e.schaden) * schw)
	n = maxi(0, roundi(n * _schaden_faktor(f)) if schw > 0.0 else n)     # 870.6: Schwächung, Sättigung als Faktor
	_vor_treffer(t, wd.get("typ"))
	_hurt(t, n, f.id, fmt(wolf(f, "MSG279_WOLFHITS", "MSG72_HITS"), lang, [f.name(lang), t.name(lang), n]), info, true)
	_gegenwirkung(f, t, wd.get("typ"))
	if not statuses or outcome != "ONGOING" or not t.standing():
		return
	var type := str(wsheet.get("type", "BLUDGEONING"))
	if e.kritisch and type == "SLASHING":
		_inflict(t, "BLEED", 3)
	if e.kritisch and type == "BLUDGEONING" and dice.chance(0.5):
		_inflict(t, "STUN", 1)


## 870.5: Zauber mit Angriff nach dem BRS: Fertigkeit der Schule gegen die Abwehr des Ziels, Grundschaden des Zaubers + Grundwert
## der Schule (952 D: Evokation Verstand, Heilmagie Wille), kritisch nach Wille und Schule (Heil- und Schutzmagie nie),
## Schwäche nach der Schadensart (ohne Art keine), Beistand und Sättigung dazu (sim.py, handlungen.py schlag)
func _brs_zauber(f: Fighter, t: Fighter, z: Dictionary) -> void:
	var mode := _row_mode(f, t, false)
	var schule := String(z["schule"])
	var fert := float(f.b.fert.get(schule, 0))
	var grund := (float(z["schaden"]) + float(f.b.werte.get(BrsKampf.zauber_grundwert(schule), 0))) * _zauber_faktor(f)     # 870.6: Zauberschaden der Ausrüstung; 952 D
	var e := {}
	for i in 30:     # Testmenü „Rettung nie“: Gegner wehren keinen Zauber ab
		e = BrsKampf.schlag(dice.rng, fert, float(t.b.abwehr), grund,
				float(int(f.b.stufe) - int(t.b.stufe)), float(t.b.ruestung), _brs_bonus(mode, _treffer_mod(f, true)) + _beistand(f),
				BrsKampf.krit_prozent(f.b.werte, schule, fert))     # 952 D
		if e.treffer or not (gegner_ohne_rettung and t.side == "FOES"):
			break
	var info := ["BRS", e.wurf, 0, e.chance, e.treffer, mode, false, bool(e.kritisch)]
	if not e.treffer:
		_say(fmt(wolf(f, "MSG279_WOLFMISSES", "MSG72_MISSES"), lang, [f.name(lang), t.name(lang)]), f.id, t.id, 0, info)
		return
	var schw := _schwaeche(f, t, z.get("typ"), info)     # 870.5 (870a 8 A)
	var n := maxi(0, roundi(float(e.schaden) * schw * (_schaden_faktor(f) if schw > 0.0 else 1.0)))
	_vor_treffer(t, z.get("typ"))
	_hurt(t, n, f.id, fmt(wolf(f, "MSG279_WOLFHITS", "MSG72_HITS"), lang, [f.name(lang), t.name(lang), n]), info)
	_gegenwirkung(f, t, z.get("typ"))


## 870.5 (870a 8 A, LISTE-BESTIARIUM.md): Faktor der Schadensart [typ] gegen [t] (Schwäche 1,5, Stärke 0,5, immun 0, werte.json
## „schwaeche“); beim ersten Treffer dieser Art auf diese Gegnerart eine Zeile (Homer [870.14.schwach] …), im Kasten ein Wort
func _schwaeche(f: Fighter, t: Fighter, typ, info: Array) -> float:
	if typ == null or String(typ) == "":
		return 1.0
	var x := float(t.b.get("schwaeche", {}).get(String(typ), 1.0))
	if x == 1.0:
		return x
	info.append(x)
	var k := art_of(t.monster) + "|" + String(typ)
	if not schwaeche_gesagt.has(k):
		schwaeche_gesagt[k] = true
		var name: Array = SCHADENSART.get(String(typ), [String(typ), String(typ)])
		var satz: Array = MSG870_SCHWACH if x > 1.0 else (MSG870_STARK if x > 0.0 else MSG870_IMMUN)
		_say(fmt(satz, lang, [t.name(lang), name[lang]]), f.id, t.id)
	return x


## 960 (Homer 954.1; 870d gebilligt 11.11., 07:51: ab Verstand 6 sieht der Held Schwäche, Stärke und Gegenwirkung vorher): die Zeile
## des Ziel-Tipps (langes Drücken auf einen Gegner) nach [870.14.wissen], [870.14.wissen.gegen], [870.14.wissen.unbekannt]
## (STORY-BRS-HELD.md); ohne Verstand 6 erst, wenn in diesem Kampf eine Schwäche oder Stärke der Art genannt wurde. Ein Bestiarium über
## Kämpfe hinweg gibt es noch nicht.
const MSG960_WISSEN := ["Verwundbar: %s. Widersteht: %s.", "Vulnerable: %s. Resists: %s."]
const MSG960_GEGEN := ["Vorsicht: %s.", "Beware: %s."]
const MSG960_UNBEKANNT := ["Schwächen: unbekannt.", "Weaknesses: unknown."]
const WISSEN_GEGEN := {
	"wolf": ["Feuer vertreibt das Rudel samt Beute und Erfahrung, sobald sein Leitwolf halb tot ist", "fire drives off the pack, loot, experience and all, once its leader is half dead"],
	"boar": ["Feuer macht es rasend", "fire sends it into a frenzy"],
	"giant_spider": ["Feuer verbrennt die Seide", "fire burns the silk"],
	"stirge": ["Blut lockt ihn", "blood draws it"],
	"zombie": ["Feuer und Licht halten ihn liegen", "fire and light keep it down"],
	"ochre_jelly": ["Schnitt und Wucht teilen ihn", "slash and crush split it"],
}


func kennt_schwaechen() -> bool:
	var h: Fighter = find("hero")
	if h == null or not (h.b.get("werte") is Dictionary):
		return false
	return int(h.b["werte"].get("verstand", 0)) >= int(BrsKampf.w().get("welt", {}).get("wissen_verstand_ab", 6))


func wissen(t: Fighter, sprache: int) -> String:
	if t == null or t.monster == null:
		return ""
	var art := art_of(t.monster)
	var gesehen := schwaeche_gesagt.keys().any(func(k): return String(k).begins_with(art + "|"))
	if not kennt_schwaechen() and not gesehen:
		return MSG960_UNBEKANNT[sprache]
	var schwach := []
	var stark := []
	var sw: Dictionary = t.b.get("schwaeche", {}) if t.b.get("schwaeche") is Dictionary else {}
	for ty in sw:
		var n: String = SCHADENSART.get(String(ty), [String(ty), String(ty)])[sprache]
		if float(sw[ty]) > 1.0:
			schwach.append(n)
		elif float(sw[ty]) < 1.0:
			stark.append(n)
	var s: String = MSG960_WISSEN[sprache] % [", ".join(schwach) if not schwach.is_empty() else "–", ", ".join(stark) if not stark.is_empty() else "–"]
	if WISSEN_GEGEN.has(art):
		s += " " + MSG960_GEGEN[sprache] % WISSEN_GEGEN[art][sprache]
	return s


## 870.5 Gegenwirkung, die vor dem Schaden greift: Zombie nach Feuer oder Licht steht nicht wieder auf
func _vor_treffer(t: Fighter, typ) -> void:
	if t.monster != null and art_of(t.monster) == "zombie" and String(typ) in ["feuer", "licht"]:
		t.kein_zaeh = true


## 870.5 (870a 8 A, LISTE-BESTIARIUM.md): das falsche Mittel stärkt den Gegner oder kostet etwas, nie tödlich, beim ersten Mal sichtbar
## (Zahlen werte.json „gegenwirkung“, A). 870.6: Feuer auf die Riesenspinne verbrennt ihre Spinnseide (lohn.gd lässt sie weg).
func _gegenwirkung(f: Fighter, t: Fighter, typ) -> void:
	if t.monster == null or typ == null or outcome != "ONGOING":
		return
	var art := art_of(t.monster)
	var ty := String(typ)
	if art == WOLF and ty == "feuer":
		# 870c 3 A: Feuer vertreibt das Rudel erst, wenn sein Leitwolf (dem t folgt, sonst t selbst) unter halbem Leben ist
		var leit = by_id(t.follows) if t.follows != "" else t
		if leit != null and leit.standing() and leit.hp * 2 >= leit.max_hp:
			return
		var rudel := all.filter(func(x): return x.side == "FOES" and x.standing() and x.monster != null and art_of(x.monster) == WOLF)
		var erst := true
		for x in rudel:     # eine Zeile für alle, jeder läuft (wie _pack_flees)
			x.fled = true
			intents.erase(x.id)
			_say(MSG870_GEGEN_WOLF[lang] if erst else "", null, x.id, 0, null, false, false, "FOE_FLEES")
			erst = false
		if not all.any(func(x): return x.side == "FOES" and x.standing()):
			kein_lohn = true     # nur, wenn das Rudel allein war (Grimmzahn bleibt und zählt)
			outcome = "WON"
	elif art == "giant_spider" and ty == "feuer" and not t.seide_weg:
		t.seide_weg = true
		_say(MSG870_GEGEN_SPINNE[lang], f.id, t.id)
	elif art == "boar" and ty == "feuer" and t.standing() and not t.rasend:
		t.rasend = true
		_say(fmt(MSG870_GEGEN_SCHWEIN, lang, [t.name(lang)]), f.id, t.id)
	elif art == "ochre_jelly" and ty in ["schnitt", "wucht"] and t.standing() and not t.geteilt and t.hp >= 2:
		var spot = _free_foe_spot()
		if spot == null:
			return
		t.geteilt = true
		for gone in all.duplicate():
			if gone.side == "FOES" and gone.place == spot:
				if order.find(gone) < turn:
					turn -= 1
				all.erase(gone)
				order.erase(gone)
		var g := monster_fighter(t.id + "b", spot, t.monster, 1)
		g.b = t.b
		g.max_hp = t.max_hp
		g.hp = int(t.hp * float(BrsKampf.w().get("gegenwirkung", {}).get("teilen_leben", 0.5)))
		t.hp -= g.hp
		g.geteilt = true
		g.initiative = t.initiative
		var top := 0
		for x in all:
			if x.monster != null and art_of(x.monster) == art:
				top = maxi(top, x.nr)
		if t.nr == 0:
			t.nr = 1
		g.nr = maxi(top, t.nr) + 1
		all.append(g)
		order.insert(order.find(t) + 1, g)
		_say(MSG870_GEGEN_SCHLEIM[lang], t.id, g.id)
		announce(g)
		_say_announce(g)     # 986 (2): auch der abgespaltene Schleim sagt im Bericht an


## 870.5: Beistand: Prozentpunkte auf die eigene Trefferchance, solange er wirkt
func _beistand(f: Fighter) -> float:
	return float(BrsKampf.w()["zauber"].get("Beistand", {}).get("treffer", 0)) if f.beistand > 0 else 0.0


## Ein Gegner schlägt den Helden oder Söldner (sim.py auf_held): Angriff gegen die beste Abwehr (Ausweichen, Schild, Parieren), Schaden
## Grundschaden × (1 + Angriff/100) × Stufenfaktor, minus Rüstung und Schild; die Stärke der Ansage (Schwerer Hieb …) im Verhältnis
## ihres Würfels zum Biss der Art
## 870.5: Merkmal Überfall nach dem BRS (werte.json „merkmale“ „ueberfall“: Gegner zuerst, erster Treffer stärker; betäubt wie bisher
## über die Abwehrprobe in _foe_wounds)
func _ueberfall() -> Dictionary:
	return BrsKampf.w().get("merkmale", {}).get("ueberfall", {})


func _brs_auf_held(foe: Fighter, t: Fighter, intent: Dictionary, mode: int) -> Dictionary:
	var m: Dictionary = foe.monster
	var wt = t.weapon()
	var tw := BrsKampf.waffe_held(t.b, wt if wt != null else t.hero.main, wt != null and wt != t.main_weapon())     # 870.2
	var in_hand := not t.drawn
	var abw: Array = BrsKampf.held_abwehr(t.b, String(foe.b.get("art", "nah")), tw, in_hand)
	var faktor := 1.0
	if intent.extra != null:     # 870.6: Zusatzschaden der Absicht als Anteil am Schaden (werte.json „absicht_zusatz“)
		faktor += float(BrsKampf.w().get("absicht_zusatz", {}).get(String(intent.id), 0.0))
	if bool(foe.b.get("ueberfall", false)) and not foe.has_hit:     # 870.5: der erste Treffer des Überfalls mit Wucht (444 „erster_treffer_faktor“)
		faktor *= float(_ueberfall().get("erster_treffer_faktor", 1.0))
	return BrsKampf.schlag(dice.rng, float(foe.b.angriff), float(abw[1]), float(foe.b.schaden) * faktor,
			float(int(foe.b.stufe) - int(t.b.stufe)), BrsKampf.held_abzug(t.b, in_hand) + t.schutz, _brs_bonus(mode, _treffer_mod(foe)))     # 870.5: Bannschild, Arkanhaut
