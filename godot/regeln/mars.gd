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
## The lines by name, for the ones picked in several wordings.
## 399.2b (Homer [399.2b.knurrt]): die Zeile im Zug, wenn ein Jungwolf nur knurrt; gibt es im alten MARS nicht, darum nicht in mars_texte.gd
## Battle.kt Msg.fed (399.2, satt)
const MSG399_FED := ["{0} ist gut gestärkt: +1 auf Angriffe und Schaden.", "{0} is well fed: +1 to attacks and damage."]
const MSG399_GROWLS := [["{0} knurrt, wagt aber keinen Biss.", "{0} snarls but dares no bite."],
	["{0} duckt sich und fletscht die Zähne, kommt aber nicht heran.", "{0} crouches and bares its teeth, but does not come in."],
	["{0} knurrt und hält Abstand.", "{0} growls and keeps its distance."]]
var TX: Dictionary = load("res://regeln/mars_texte.gd").get_script_constant_map().merged({"MSG399_GROWLS": MSG399_GROWLS, "MSG547_AUF": MSG547_AUF, "MSG547_STOSS": MSG547_STOSS})
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
const MSG534_LIFESTEAL = ["{0} saugt {1} TP ab.", "{0} drains {1} HP."]
const MSG534_RELENTLESS = ["{0} bleibt mit eisernem Willen stehen!", "{0} stays standing through sheer will!"]
const MSG534_COWED = ["{0} zögert, eingeschüchtert von {1}!", "{0} hesitates, cowed by {1}!"]
const COW_PER_CHA := 0.08
const BREAK_SHARE := 5
## 296.2: the lines of the old fight, the same words in MARS (Skirmish.kt Msg296, Zweig claude/build-89).
const MSG296_STILLSURPRISED = ["{0} ist noch überrascht und kann nicht reagieren!", "{0} is still caught off guard!"]
const MSG296_FLED = ["{0} ist entkommen!", "{0} got away safely!"]
const MSG296_CANTFLEE = ["Die Flucht misslingt!", "Couldn't get away!"]
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
	"POISON": ["Schaden zu Beginn jeder Runde.", "Damage at the start of each round."],
	"BURN": ["Starker Schaden zu Beginn jeder Runde.", "Heavy damage at the start of each round."],
	"BLEED": ["Schaden jede Runde, Heilung nur halb so stark.", "Damage each round, healing is halved."],
	"STUN": ["Setzt die nächste Runde aus.", "Loses the next turn."],
	"SLOW": ["−2 auf Angriff und Rüstungsklasse.", "−2 to attack and armor class."],
	"WEAK": ["−2 auf Angriff und Schaden.", "−2 to attack and damage."],
	"BLIND": ["Angriffe mit Nachteil.", "Attacks with disadvantage."],
	"DRUNK": ["Angriffe und Flucht mit Nachteil, bis zur nächsten Rast.", "Attacks and fleeing at a disadvantage, until your next rest."],
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
const ST_DWARF := ["Zwergische Zähigkeit: {0} widersteht dem Gift!", "Dwarven resilience: {0} resists the poison!"]
const ST_SHAKES := ["{0} schüttelt die Betäubung ab!", "{0} shrugs off the stun!"]
const MSG296_DAMAGE := ["{0} Schaden.", "{0} damage."]
## 296.2: the kinds whose specials MARS plays through their own intents, not the old fight's.
const OWN_INTENTS := [GRAK, CALLED, SCOUT, WOLF, DIRE_WOLF, SPIDER]
const CALL_MAX := 2
const GATHER_HEAL := [2, 10, 0]
const PROBE_LEVEL := 3
const EASY_GAP := 4.0
const PRAYER_HEAL := [1, 6, 0]

## Reaction: how well the attacked figure met the ring (72.11), with its share of the damage.
const NONE := "NONE"
const GOOD := "GOOD"
const PERFECT := "PERFECT"
const SHARE := {"NONE": 1.0, "GOOD": 0.5, "PERFECT": 0.0}

## Whom a move is aimed at (72.10a.3).
const AIM := {
	"FIRE_BOLT": "FOE", "MAGIC_MISSILE": "FOE", "SCORCHING_RAY": "FOE", "SACRED_FLAME": "FOE", "FEINT": "FOE", "ACTION_SURGE": "FOE",
	"FIREBALL": "ROW", "BURNING_HANDS": "ROW", "SECOND_WIND": "SELF", "BLESS": "SELF", "CURE_WOUNDS": "ALLY",
}
## 348.7b (Chef 27.10., 19:49): Brennende Hände eigener Effekt (Kegel aus den Händen); im Kotlin-Kern noch FIREBALL (mars_golden.gd)
const FX := {
	"FIRE_BOLT": "FIRE_BOLT", "MAGIC_MISSILE": "MISSILES", "SCORCHING_RAY": "RAYS", "FIREBALL": "FIREBALL", "BURNING_HANDS": "BURNING_HANDS",
	"SACRED_FLAME": "SACRED_FLAME", "CURE_WOUNDS": "HEAL", "SECOND_WIND": "HEAL", "BLESS": "BLESS",
}


static func _intent(id: String, de: String, en: String, kind := "STRIKE", extra = null, strong := false, ring := true,
		breakable := false, effect := "", break_any := false) -> Dictionary:
	return {"id": id, "name": [de, en], "kind": kind, "extra": extra, "strong": strong, "ring": ring,
		"breakable": breakable, "effect": effect, "break_any": break_any}


var I_HEAVY := _intent("heavy", "Schwerer Hieb", "Heavy blow", "STRIKE", [2, 6, 0], true, true, true)
var I_CALL := _intent("call", "Rudel rufen", "Call the pack", "CALL", null, false, false)
var I_GATHER := _intent("gather", "Kraft sammeln", "Gather strength", "GATHER", null, false, false, true)
var I_STAB := _intent("stab", "Stich", "Stab", "STRIKE", null, false, false)
## 348.12 (Chef 27.10., 09:49; Homer [210T.hieb]): Goblin mit Krummsäbel oder Beil sagt „Hieb“ an; gewollte Abweichung vom alten MARS
var I_SLASH := _intent("slash", "Hieb", "Slash", "STRIKE", null, false, false)
## 535 (alt Monsters.kt giant_rat, giant_bat: Angriff „Biss“): Ratte und Fledermaus beißen nur, ohne Sprung und Einkreisen
var I_BITE := _intent("bite", "Biss", "Bite", "STRIKE", null, false, false)
var I_POUNCE := _intent("pounce", "Anspringen", "Pounce", "STRIKE", null, false, false, false, "POUNCE")
## 399.2b: ein Jungwolf knurrt nur, kein Angriff (Homer [210T.growl])
var I_GROWL := _intent("growl", "Knurren", "Growl", "WAIT", null, false, false, false, "GROWL")
var I_CIRCLE := _intent("circle", "Einkreisen", "Circle", "GATHER", null, false, false, false, "CIRCLE", true)
var I_VENOM := _intent("venom", "Gift sammeln", "Gather venom", "STRIKE", [2, 6, 0], true, false, true)
var I_WEB := _intent("web", "Netz werfen", "Cast web", "STRIKE", null, false, true, false, "WEB")
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
	var blessed := false
	var sneaked := false
	var held := false
	var prone := false
	var waited := false
	var hidden := false
	var moved := false
	var nr := 0
	## 296.2: the statuses with the turns they still last, in the order they came; the poison's die; turns after a
	## stun in which no new one takes hold; the statuses have acted this turn; has landed a blow in this fight.
	var status := {}
	var poison_die: Array = [1, 4, 0]
	var stun_guard := 0
	var ticked := false
	var has_hit := false
	## 296.2: came running in the fight (Grak's call): worth nothing at the end, as in the old fight that had none
	var called_in := false
	## 399.2a: the leader this one follows (a young wolf its wolf, Packs.kt); it flees when the leader falls
	var follows := ""
	var fled := false
	## 478: was er nach dem BRS ist (brs_kampf.gd held, gegner); leer, solange der Kampf nach dem SRD rechnet
	var b := {}
	## 478: seine Leben nach dem SRD beim Umrechnen (Maßstab für alles, was noch in Würfeln des SRD rechnet)
	var srd_hp := 0

	func standing() -> bool:
		return hp > 0 and not fled

	func ac() -> int:
		var slow := 2 if status.has("SLOW") else 0
		if hero == null:
			return int(monster.ac) - slow
		return (int(hero.acDrawn) if drawn else int(hero.ac)) - slow

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

	## 89.2 (c): the light weapon in the other hand, while the main one is in hand (SRD: two-weapon fighting).
	func off_hand():
		if hero == null or drawn or hero.get("off") == null or main_weapon() == null:
			return null
		return hero.off

	func ranged() -> bool:
		var w = weapon()
		return (w != null and w.ranged) or (monster != null and (monster.id == "goblin_archer" or monster.id == "giant_spider"))

	func reach() -> bool:
		var w = weapon()
		return w != null and w.reach

	func boss() -> bool:
		return monster != null and monster.boss

	func has(skill: String) -> bool:
		return hero != null and skill in hero.skills

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
## 296.2: what a won fight brings (regeln/lohn.gd): a pack's share per companion by leader, the levels by experience, the cap.
var packs := {}
var xp_for_level: Array = []
var level_cap := 20

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
var surprised := {}
var intents := {}
var autopilot := false
var order: Array = []
var turn := 0
var _log: Array = []
## Hears every message as it is said: func(event: Dictionary).
var listener: Callable
## 89.2 (c): Extra Attack and the other hand as in the SRD; off only to replay the fights of the Kotlin core (MARS golden).
var srd_attacks := true
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
const SMOKE_BUNDLE := ["Rauchbündel", "Smoke Bundle"]     # Items.kt smoke_bundle
const MSG532_CURED := ["{0} ist von allen Leiden befreit!", "{0} is cured of all ailments!"]     # Battle.kt Msg.cured
var aim_spot := {}
var retargeted := {}
var chosen := false
var called := 0
var casting = null


## [party] and [foes] are Fighters; [tables] the monsters, items and skills (godot/regeln/tabellen.json).
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
	packs = tables.get("packs", {})
	xp_for_level = tables.get("xpForLevel", [])
	level_cap = int(tables.get("levelCap", 20))
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
		for f in foes:
			top = maxf(top, cr_value(str(f.monster.cr)))
		var gap: float = float(lv) - top
		if gap >= EASY_GAP:
			easy_gap = gap
	for f in all:
		var dex: int = int(f.hero.dex) if f.hero != null else int(f.monster.dex)
		f.initiative = dice.d20(-1 if winded and f == party[0] else 0) + dex
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
	for f in foes:
		announce(f)
	if BrsKampf.an():
		brs_einrichten()


## 478: ein Angriffswurf, nach dem SRD („ATTACK“, W20) oder dem BRS („BRS“: Wurf 1–100, Chance, kritisch an Stelle 7)
static func ist_angriff(roll) -> bool:
	return roll != null and (roll[0] == "ATTACK" or roll[0] == "BRS")

static func ist_krit(roll) -> bool:
	if roll == null or not roll[4]:
		return false
	if roll[0] == "BRS":
		return roll.size() > 7 and bool(roll[7])
	return roll[0] == "ATTACK" and int(roll[1]) == 20


## 478: der Kampf rechnet nach dem BRS (Modell D, brs_kampf.gd); Leben der Gruppe im selben Anteil wie vorher, Gegner nach dem Bestiarium
var brs := false

func brs_einrichten() -> void:
	brs = true
	for f in all:
		_brs_kaempfer(f)


func _brs_kaempfer(f: Fighter) -> void:
	if f.hero != null:
		f.b = BrsKampf.held(f.hero, f.hero.get("brs_daten", {}))
		var mx := BrsKampf.leben_held(f.b)
		f.srd_hp = f.max_hp
		f.hp = clampi(roundi(float(f.hp) * mx / maxf(1.0, f.max_hp)), 1 if f.hp > 0 else 0, mx)
		f.max_hp = mx
	elif f.monster != null:
		f.b = BrsKampf.gegner(f.monster, monsters.get(String(f.monster.id), {}))
		if f.b.is_empty():
			return
		var mx := int(f.b.leben)
		f.srd_hp = f.max_hp
		f.hp = clampi(roundi(float(f.hp) * mx / maxf(1.0, f.max_hp)), 1 if f.hp > 0 else 0, mx)
		f.max_hp = mx


## 478: Schaden und Heilung, die noch in Würfeln des SRD rechnen, im Verhältnis der Leben des Getroffenen (brs_kampf.gd, Annahme)
func massstab(t: Fighter) -> float:
	return float(t.max_hp) / maxf(1.0, t.srd_hp) if brs and t.srd_hp > 0 else 1.0

func _srd(t: Fighter, n: int) -> int:
	return roundi(n * massstab(t)) if brs else n

func _brs(f: Fighter, t: Fighter) -> bool:
	return brs and not f.b.is_empty() and not t.b.is_empty()


static func cr_value(cr: String) -> float:
	var p := cr.split("/")
	return float(p[0]) / float(p[1]) if p.size() == 2 else float(p[0])


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
	return 1.0 if easy_gap < 7 else (0.5 if easy_gap < 10 else 0.0)


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
	for s in skills.keys():
		if s in f.hero.skills and AIM.has(s):
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
	match AIM.get(s, ""):
		"FOE":
			if (s == "FEINT" or s == "ACTION_SURGE") and not _feints_past(f, s):
				return targets(f)
			return all.filter(func(x): return x.side != f.side and x.standing())
		"ROW":
			return all.filter(func(x): return x.side != f.side and x.standing())
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
	if f.hero == null or f.hero.cls != "FIGHTER" or f.place.x != FRONT or not f.standing():
		return []
	var out := []
	for id in intents:
		if intents[id][1].any(func(a): return a != f.id):
			out.append(id)
	return out


## Was sich trinken lässt (Tränke, Kräutertrank); 532: Wurfgeschosse wirft man (throwable).
func drinkable() -> Array:
	return potions.keys().filter(func(k): return potions[k] > 0 and String(items.get(k, {}).get("kind", "POTION")) == "POTION")


## 532 (alt Battle.useItem BOMB, Durchspielregel 488): Alchemistenfeuer und Weihwasser, die sich jetzt auf jemanden werfen lassen.
func throwable() -> Array:
	return potions.keys().filter(func(k): return potions[k] > 0 and String(items.get(k, {}).get("kind", "")) == "BOMB" \
			and not throw_targets(k).is_empty())


## 532: Tasche im Kampf, alles, was sich gerade benutzen lässt.
func bag() -> Array:
	return drinkable() + throwable()


## 532: wen ein Wurf trifft: jeder stehende Gegner; Weihwasser nur Untote (alt Battle.blockedItem, NOT_UNDEAD).
func throw_targets(item: String) -> Array:
	return all.filter(func(x): return x.side == "FOES" and x.standing() and (item != "holy_water" or bool(x.monster.get("undead", false))))


## 532: ob [item] [t] etwas bringt (alt ALREADY_FULL): TP fehlen, oder der Kräutertrank hat Zustände zu heilen (betrunken bleibt).
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
	if friend != null and "CURE_WOUNDS" in can and blocked(f, "CURE_WOUNDS") == null:
		return ["use", "CURE_WOUNDS", friend.id]
	var cantrip = null
	for c in ["FIRE_BOLT", "SACRED_FLAME"]:
		if c in can:
			cantrip = c
			break
	var foes := all.filter(func(x): return x.side != f.side and x.standing())
	if cantrip != null and not foes.is_empty():
		return ["use", cantrip, _min_hp(foes).id]
	if can_draw(f) and f.place.x == FRONT and f.weapon() != null and f.weapon().ranged and f.spare() != null and not f.spare().ranged:
		return ["draw"]
	var t = _min_hp(targets(f))
	return ["attack", t.id] if t != null else ["wait"]


func _min_hp(list: Array):
	var best = null
	for x in list:
		if best == null or x.hp < best.hp:
			best = x
	return best


## Whom [f] can strike: melee reaches the front row while anyone stands there, ranged reaches all (72.11).
func targets(f: Fighter) -> Array:
	var other := all.filter(func(x): return x.side != f.side and x.standing())
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
		return ["Unter einem Drittel der Lebenspunkte.", "Below a third of life points."]
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
## ["use", skill, target or null], ["drink", item, target], ["throw", item, foe]), then on until a party figure must choose again.
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


func start(react: Callable = Callable()) -> Array:
	# never play a fight without its hero: the foes would wait for a target forever (the old game ran out of memory)
	if not lead().standing():
		started = true
		outcome = "LOST"
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
			_off_hand_attack(f, t)
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
	var l := targets(f) if weapon else all.filter(func(x): return x.side != f.side and x.standing())
	return l[0] if not l.is_empty() else null


func _cantrip_dice(f: Fighter) -> int:
	var n := 1
	for lv in [5, 11, 17]:
		if f.level() >= lv:
			n += 1
	return n


func _use_skill(f: Fighter, s: String, t) -> void:
	var sk: Dictionary = skills[s]
	match sk.cost:
		"SPELL_POINTS":
			f.sp -= int(sk.amount)
		"PER_BATTLE", "PER_REST":
			f.uses[s] = f.uses[s] - 1
	var spell: bool = sk.cost == "SPELL_POINTS" or sk.cost == "NONE"
	_say(fmt(X.MSG72_CASTS if spell else X.MSG72_USES, lang, [f.name(lang), [sk.de, sk.en][lang]]), f.id)
	casting = FX.get(s)
	_cast(f, s, t)
	casting = null


func _cast(f: Fighter, s: String, t) -> void:
	match s:
		"SECOND_WIND":
			_heal(f, f, dice.roll(1, 10) + f.level())
		"ACTION_SURGE":
			# 89.2 (c): two Attack actions, each with Extra Attack, and the other hand once (bonus action, SRD)
			var tt = _again(f, t, true)
			for i in 2:
				if outcome == "ONGOING" and tt != null:
					tt = _attack_action(f, tt)
			_off_hand_attack(f, tt if tt != null else t)
		"FEINT":
			_weapon_attack(f, t, true, not _feints_past(f, s))
		"FIRE_BOLT":
			_spell_attack(f, t, [_cantrip_dice(f), 10, 0])
		"MAGIC_MISSILE":
			var dmg := 0
			for i in 3:
				dmg += dice.roll_expr([1, 4, 1])
			dmg = _srd(t, dmg)     # 478
			_hurt(t, dmg, f.id, fmt(wolf(f, "MSG279_WOLFHITS", "MSG72_HITS"), lang, [f.name(lang), t.name(lang), dmg]))
		"SCORCHING_RAY":
			var tt = t
			for i in 3:
				tt = _again(f, tt, false) if tt != null else null
				if outcome == "ONGOING" and tt != null:
					_spell_attack(f, tt, [2, 6, 0])
		"FIREBALL", "BURNING_HANDS":
			var amount: int = dice.roll_expr([3, 6, 0] if s == "BURNING_HANDS" else [8, 6, 0])
			var row: int = t.place.x
			for g in all.filter(func(x): return x.side == t.side and x.standing() and x.place.x == row):
				if outcome == "ONGOING":
					_save_spell(f, g, amount, true)
		"SACRED_FLAME":
			_save_spell(f, t, dice.roll_expr([_cantrip_dice(f), 8, 0]), false)
		"CURE_WOUNDS":
			_heal(f, t, dice.roll(1 + f.level() / 2, 8) + int(f.hero.wis))
		"BLESS":
			f.blessed = true
			_say(fmt(X.MSG72_BLESSED, lang, [f.name(lang)]), f.id, f.id)


# 72.10a.7, 223, 203, 208: what the rows and stances do to an attack roll.
func _row_mode(f: Fighter, t: Fighter, weapon: bool, extra := 0, cover := true) -> int:
	var dis := 0
	if cover and t.place.x == BACK and all.any(func(x): return x.side == t.side and x.standing() and x.place.x == FRONT):
		dis += 1
	if weapon and f.ranged() and f.place.x == FRONT and t.place.x == FRONT:
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


func _bless(f: Fighter) -> int:
	return dice.roll(1, 4) if f.blessed else 0


## Battle.fedBonus: +1, wenn der Held satt in den Kampf ging (nur der Held, nicht der Söldner)
func _fed(f: Fighter) -> int:
	return 1 if fed and f == lead() else 0


func _spell_attack(f: Fighter, t: Fighter, dmg: Array) -> void:
	if _brs(f, t):
		_brs_zauber(f, t, dmg)
		return
	var mode := _row_mode(f, t, false)
	var r: int = dice.d20(mode)
	var bonus: int = int(f.hero.spellAtk) + _bless(f) + _fed(f)
	var crit := r == 20
	var hit := r != 1 and (crit or r + bonus >= t.ac())
	var info := ["ATTACK", r, bonus, t.ac(), hit, mode, false]
	if not hit:
		_say(fmt(wolf(f, "MSG279_WOLFMISSES", "MSG72_MISSES"), lang, [f.name(lang), t.name(lang)]), f.id, t.id, 0, info)
		return
	var n := maxi(1, dice.roll_expr([dmg[0] * 2, dmg[1], dmg[2]] if crit else dmg) + _fed(f))
	_hurt(t, n, f.id, fmt(wolf(f, "MSG279_WOLFHITS", "MSG72_HITS"), lang, [f.name(lang), t.name(lang), n]), info)


func _save_spell(f: Fighter, t: Fighter, amount: int, half: bool) -> void:
	amount = _srd(t, amount)     # 478
	var dc: int = int(f.hero.spellDc)
	var mod: int = int(t.hero.dex) if t.hero != null else int(t.monster.dex)
	var r: int = dice.d20(1 if t.waited else 0)
	var saved := r + mod >= dc and not (gegner_ohne_rettung and t.side == "FOES")
	var info := ["SAVE", r, mod, dc, saved, 0, false]
	if saved and not half:
		_say(fmt(X.MSG72_DODGES, lang, [t.name(lang)]), f.id, t.id, 0, info)
		return
	var n := maxi(1, amount / 2 if saved else amount)
	_hurt(t, n, f.id, fmt(wolf(f, "MSG279_WOLFHITS", "MSG72_HITS"), lang, [f.name(lang), t.name(lang), n]), info)


func _heal(f: Fighter, t: Fighter, amount: int) -> void:
	var n := maxi(0, mini(t.max_hp - t.hp, _srd(t, amount)))     # 478
	t.hp += n
	if f == t:
		_say(fmt(X.MSG72_HEALSSELF, lang, [f.name(lang), n]), f.id, t.id, 0, null, false, false, "HEAL")
	else:
		_say(fmt(X.MSG72_HEALS, lang, [f.name(lang), t.name(lang), n]), f.id, t.id, 0, null, false, false, "HEAL")


func _draw(f: Fighter) -> void:
	assert(f.spare() != null)
	f.drawn = not f.drawn
	_say(fmt(X.MSG72_DRAWS, lang, [f.name(lang), f.weapon()[["de", "en"][lang]]]), f.id)


## 296.2: the party can try to get away: a hero of the party, no boss among the foes (as in the old fight).
func can_flee(f: Fighter) -> bool:
	return f.side == "PARTY" and f.hero != null and not all.any(func(x): return x.side == "FOES" and x.standing() and x.boss())


## 296.2: the roll of the old fight (Battle flee): d20 + Dexterity (+2 for an elf) against 10 + the quickest standing
## foe's Dexterity save; cunning action always gets away. On success the fight ends as "FLED".
func _flee(f: Fighter) -> void:
	assert(can_flee(f))
	var elf := 2 if str(f.hero.get("race", "")) == "ELF" else 0
	var top := -99
	for x in all:
		if x.side == "FOES" and x.standing():
			top = maxi(top, int(x.monster.dex))
	# 532 (alt Battle.kt 616): betrunken flieht er mit Nachteil
	if f.has("CUNNING_ACTION") or dice.d20(-1 if f.status.has("DRUNK") else 0) + int(f.hero.dex) + elf >= 10 + top:
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
	var n := maxi(0, mini(t.max_hp - t.hp, _srd(t, dice.roll_expr(def.heal)))) if def.has("heal") else 0     # 478
	t.hp += n
	var nm: String = [def.de, def.en][lang]
	if f == t:
		_say(fmt(X.MSG72_DRINKS, lang, [f.name(lang), nm, n]), f.id, t.id, 0, null, false, false, "DRINK")
	else:
		_say(fmt(X.MSG72_GIVES, lang, [f.name(lang), t.name(lang), nm, n]), f.id, t.id, 0, null, false, false, "DRINK")
	if heilt:
		_say(fmt(MSG532_CURED, lang, [t.name(lang)]), f.id, t.id, 0, null, false, false, "STATUS")


## 532 (alt Battle.useItem BOMB): ein Wurfgeschoss trifft immer: Würfel des Dings + Wurfbonus (Perks.throwBonus, Stärke);
## Alchemistenfeuer setzt in Brand (2 Züge). Fliegt sichtbar wie ein Feuerpfeil bzw. Heilige Flamme.
func _throw(f: Fighter, item: String, t: Fighter) -> void:
	assert(potions.get(item, 0) > 0 and t in throw_targets(item))
	potions[item] -= 1
	var def: Dictionary = items[item]
	_say(fmt(THROWS, lang, [f.name(lang), [def.de, def.en][lang]]), f.id, t.id, 0, null, false, false, "THROW")
	var n := maxi(1, _srd(t, dice.roll_expr(def.damage) + int(f.hero.get("throw", 0) if f.hero != null else 0)))     # 478
	casting = "SACRED_FLAME" if item == "holy_water" else "FIRE_BOLT"
	_hurt(t, n, f.id, fmt(wolf(f, "MSG279_WOLFHITS", "MSG72_HITS"), lang, [f.name(lang), t.name(lang), n]))
	casting = null
	if item == "alchemist_fire":
		_inflict(t, "BURN", 2)


## The Attack action: one blow, a second with Extra Attack (Battle.attackAction, 89.2 c). Returns whom to strike next.
func _attack_action(f: Fighter, t: Fighter, advantage := false, cover := true):
	_weapon_attack(f, t, advantage, cover)
	var tt = _again(f, t, true)
	if srd_attacks and f.has("EXTRA_ATTACK") and outcome == "ONGOING" and tt != null:
		_weapon_attack(f, tt)
		tt = _again(f, tt, true)
	return tt


## 89.2 (c): the blow of the other hand after the Attack action, at whom still stands.
func _off_hand_attack(f: Fighter, t: Fighter) -> void:
	var w = f.off_hand() if srd_attacks else null
	var tt = _again(f, t, true) if w != null and outcome == "ONGOING" else null
	if tt != null:
		_weapon_attack(f, tt, false, true, w)


func _weapon_attack(f: Fighter, t: Fighter, advantage := false, cover := true, with_weapon = null) -> void:
	if _brs(f, t):
		_brs_waffe(f, t, advantage, cover, with_weapon)
		return
	var mode := _row_mode(f, t, true, 1 if advantage else 0, cover)
	var r: int = dice.d20(mode)
	var crit := r >= int(f.hero.crit) or (held_immer_krit and r != 1 and f == lead())
	var w = with_weapon if with_weapon != null else f.weapon()
	var wsheet: Dictionary = w if w != null else f.hero.main
	var bonus: int = int(wsheet.atk) + _bless(f) - _penalty(f) + _fed(f)
	var hit := r != 1 and (crit or r + bonus >= t.ac())
	# 535 (alt Battle.weaponAttack, EVASIVE): einem Nahkampfhieb weicht die Fledermaus zu 20 % aus, ein Schuss trifft sie wie sonst
	var flattert: bool = hit and t.monster != null and art_of(t.monster) == BAT and not bool(wsheet.get("ranged", false)) and dice.chance(FLUTTER)
	if flattert:
		hit = false
	var info := ["ATTACK", r, bonus, t.ac(), hit, mode, cover and from_back(f)]
	if flattert:
		_say(fmt(MSG535_FLUTTERS, lang, [t.name(lang)]), f.id, t.id, 0, info)
		return
	if not hit:
		_say(fmt(wolf(f, "MSG279_WOLFMISSES", "MSG72_MISSES"), lang, [f.name(lang), t.name(lang)]), f.id, t.id, 0, info)
		return
	var base: Array = wsheet.dmg
	var dmg: int = dice.roll_expr([int(base[0]) * 2, base[1], base[2]] if crit else base)
	if f.has("SNEAK_ATTACK") and (advantage or not f.sneaked):
		dmg += dice.roll(maxi(1, f.level() / 2), 6)
	f.sneaked = true
	dmg = maxi(1, dmg - _weakness(f) + _fed(f))
	_hurt(t, dmg, f.id, fmt(wolf(f, "MSG279_WOLFHITS", "MSG72_HITS"), lang, [f.name(lang), t.name(lang), dmg]), info, true)
	_life_steal(f, dmg)
	if not statuses or outcome != "ONGOING" or not t.standing():
		return
	# 296.2: critical hits wound as in the old fight, blades make bleed, blunt weapons can stun; and the gear's own
	var type := str(wsheet.get("type", "BLUDGEONING"))
	if crit and type == "SLASHING":
		_inflict(t, "BLEED", 3)
	if crit and type == "BLUDGEONING" and dice.chance(0.5):
		_inflict(t, "STUN", 1)
	var hits: Dictionary = f.hero.get("hits", {})
	for st in ["POISON", "BLEED", "STUN"]:
		var c := int(hits.get(st, 0))
		if c > 0 and outcome == "ONGOING" and t.standing() and not t.status.has(st) and dice.chance(c / 100.0):
			_inflict(t, st, 1 if st == "STUN" else 3)


## 296.2: slowed or weakened, −2 on the attack each (the old fight).
func _penalty(f: Fighter) -> int:
	return (2 if f.status.has("SLOW") else 0) + _weakness(f)


## 534 (alt Battle.weaponAttack, Hero.lifeSteal): wer mit Lebensraub trifft, heilt sich um den Anteil des Schadens (höchstens 30 %)
func _life_steal(f: Fighter, dealt: int) -> void:
	var steal: int = mini(30, int(f.hero.get("lifesteal", 0))) if f.hero != null else 0
	if steal <= 0 or dealt <= 0 or not f.standing() or f.hp >= f.max_hp:
		return
	var n := mini(f.max_hp - f.hp, maxi(1, dealt * steal / 100))
	f.hp += n
	_say(fmt(MSG534_LIFESTEAL, lang, [f.name(lang), n]), f.id, f.id, 0, null, false, false, "HEAL")


## 534 (alt Battle.hitHero, Hero.damageReduction): Schadensminderung der Ausrüstung gegen jeden Treffer eines Gegners
func _reduction(t: Fighter) -> int:
	return maxi(0, int(t.hero.get("reduction", 0))) if t.hero != null else 0


func _weakness(f: Fighter) -> int:
	return 2 if f.status.has("WEAK") else 0


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
		if save != null:
			var ab: String = save[0]
			var prof: int = int(h.get("prof", 0)) if ab in h.get("saves", []) else 0
			if dice.d20() + int(h.get(ab.to_lower(), 0)) + prof >= int(save[1]):
				_say(fmt(ST_SHRUGS, lang, [who]), null, t.id)
				return false
		var ten := int(h.get("tenacity", 0))
		if ten > 0 and dice.chance(ten / 100.0):
			_say(fmt(ST_STEADFAST, lang, [who]), null, t.id)
			return false
		if st == "POISON" and str(h.get("race", "")) == "DWARF" and dice.chance(0.5):
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
		t.poison_die = die
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
	# the hero's level grows the harm of what he put on the foes
	var scale := int(all[0].hero.level) / 3 if f.side == "FOES" and all[0].hero != null else 0
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
		var dmg: int = dice.roll_expr(f.poison_die if st == "POISON" else ([1, 6, 0] if st == "BURN" else [1, 4, 0])) + scale
		if st == "POISON" and f.hero != null and str(f.hero.get("race", "")) == "DWARF":
			dmg = (dmg + 1) / 2
		dmg = maxi(1, _srd(f, dmg))     # 478
		_hurt(f, dmg, "", fmt(ST_HURTS[st], lang, [who]) + " " + fmt(MSG296_DAMAGE, lang, [dmg]))
	if outcome != "ONGOING" or not f.standing():
		return false
	if stunned:
		_say(fmt(ST_STUNNED, lang, [who]), f.id, null, 0, null, false, false, "STATUS")
	for st in ended:
		if st != "STUN":
			_say(fmt(ST_ENDS, lang, [who, STATUS[st][0][lang].to_lower()]), null, f.id)
	return stunned


## 296.2: what a foe's landed blow does besides the damage, as in the old fight: a critical one wounds, and its kind's
## own special (unless MARS gives it intents of its own).
func _foe_wounds(foe: Fighter, t: Fighter, crit: bool) -> void:
	var m: Dictionary = foe.monster
	var first := not foe.has_hit
	foe.has_hit = true
	var type := str(m.get("type", ""))
	if crit and type == "SLASHING":
		_inflict(t, "BLEED", 2)
	if crit and type == "BLUDGEONING":
		_inflict(t, "STUN", 1, ["CON", 12])
	if art_of(m) in OWN_INTENTS:
		return
	match str(m.get("special", "NONE")):
		"POISON":
			_inflict(t, "POISON", 3, ["CON", 11], m.get("poison", [1, 6, 0]))
		"SURPRISE_ATTACK":
			if first:
				_inflict(t, "STUN", 1, ["CON", 12])
		"EVASIVE":
			if dice.chance(0.2):
				_inflict(t, "BLIND", 2, ["CON", 10])
		"BLOOD_DRAIN":
			if dice.chance(0.3):
				_inflict(t, "BLEED", 2)


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
	if intent.effect == "GROWL":     # 399.2b: knurrt nur (Homer [399.2b.knurrt])
		_say(fmt(pick("MSG399_GROWLS"), lang, [foe.name(lang)]), foe.id, null, 0, null, false, false, "GROWLS")
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
				var heal := mini(foe.max_hp - foe.hp, dice.roll_expr(GATHER_HEAL))
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
	var mode := _row_mode(foe, t, true, -1 if retarget else 0, cover)
	var r: int = 0
	var success := false
	var info: Array
	var brs_dmg := -1
	if _brs(foe, t):
		var e := _brs_auf_held(foe, t, intent, mode)
		success = e.treffer
		brs_dmg = int(e.schaden)
		info = ["BRS", e.wurf, 0, e.chance, success, mode, cover and from_back(foe), false]
	else:
		r = dice.d20(mode)
		var atk: int = int(m.atk) - _penalty(foe)
		success = not (r == 1 or (r != 20 and r + atk < t.ac()))
		info = ["ATTACK", r, atk, t.ac(), success, mode, cover and from_back(foe)]
	if str(m.id) == KROGG and smoke_thrown and not smoke_spent:
		# D4.1: der Rauch brennt in den Augen, der erste Schlag geht fehl, mit ihm der Überraschungsschlag (Battle.enemyAttack)
		smoke_spent = true
		foe.has_hit = true
		success = false
		info[4] = false
	if intent.effect == "POUNCE":
		_leap_forward(foe)
	if re == PERFECT:
		_perfect_answer(t, foe, info)
		return
	if not success:
		_say(fmt(wolf(foe, "MSG279_WOLFMISSES", "MSG72_MISSES"), lang, [foe.name(lang), t.name(lang)]), foe.id, t.id, 0, info)
		return
	var md: Array = m.dmg
	var dmg: int = brs_dmg
	if brs_dmg < 0:
		dmg = dice.roll_expr([int(md[0]) * 2, md[1], md[2]] if r == 20 else md)
		if intent.extra != null:
			dmg += dice.roll_expr(intent.extra)
	if re != NONE:
		_say(fmt(pick("MSG72_EVADES" if re == PERFECT else "MSG72_GOOD"), lang, [t.name(lang)]), t.id)
	dmg = int(dmg * SHARE[re])
	if dmg > 0 and brs_dmg >= 0:     # 478: kein Mindestschaden (Modell D: ein Kratzer kann 0 sein)
		dmg = maxi(0, dmg - _srd(t, _weakness(foe)) - _srd(t, _reduction(t)))
	elif dmg > 0:
		dmg = maxi(1, dmg - _weakness(foe) - _reduction(t))
	if intent.id == "venom":
		_say(fmt(pick("MSG130_VENOMHITS"), lang, [foe.name(lang), t.name(lang)]), foe.id, t.id, 0, null, false, false, "VENOM")
	if dmg > 0:
		_hurt(t, dmg, foe.id, fmt(wolf(foe, "MSG279_WOLFHITS", "MSG72_HITS"), lang, [foe.name(lang), t.name(lang), dmg]), info, true)
	if outcome != "ONGOING" or not t.standing():
		return
	if statuses:
		_foe_wounds(foe, t, r == 20)
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


# 72.10a.9, 219.3, 219.4, 336: what a perfect ring gives besides the blow caught, by class.
func _perfect_answer(t: Fighter, foe: Fighter, info: Array) -> void:
	var cls = t.hero.cls if t.hero != null else ""
	var answers := false
	if cls == "FIGHTER" or cls == "ROGUE" or cls == "CLERIC":
		answers = true
	elif cls == "WIZARD":
		answers = "FIRE_BOLT" in moves(t)
	if t.hero == null or not answers:
		_say(fmt(pick("MSG72_EVADES"), lang, [t.name(lang)]), foe.id, t.id, 0, info)
		return
	match cls:
		"FIGHTER":
			_say(fmt(X.MSG72_STRIKESBACK, lang, [t.name(lang), foe.name(lang)]), t.id, foe.id, 0, null, true)
			_weapon_attack(t, foe)
		"ROGUE":
			_say(fmt(X.MSG72_STEPSBEHIND, lang, [t.name(lang), foe.name(lang)]), t.id, foe.id, 0, null, true, false, "BEHIND")
			_weapon_attack(t, foe, true, false)
		"CLERIC":
			_say(fmt(X.MSG72_PRAYS, lang, [t.name(lang)]), t.id, null, 0, null, true)
			_heal(t, t, dice.roll_expr(PRAYER_HEAL))
		"WIZARD":
			_say(fmt(X.MSG72_FLAMESBACK, lang, [t.name(lang), foe.name(lang)]), t.id, foe.id, 0, null, true)
			_spell_attack(t, foe, [_cantrip_dice(t), 10, 0])


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
	if id == RAT or id == BAT:     # 535
		return I_BITE
	if id == SHAMAN:     # 535: Heilen, Fluch, Feuerstoß des Schamanen fehlen noch (Ansagen über Homer); bis dahin kämpft er wie ein Goblin
		id = CALLED
	if id == WOLF or id == DIRE_WOLF:
		var others := all.filter(func(x): return x.side == "FOES" and x.standing() and wolfig(x.monster)).size()
		var circling := intents.values().any(func(p): return p[0].effect == "CIRCLE")
		var can := [I_POUNCE, I_POUNCE]
		if others >= 2 and not circling and chosen:
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
	if brs:
		_brs_kaempfer(g)     # 478
	g.initiative = dice.d20() + int(m.dex)
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


func _hurt(t: Fighter, full: int, by: String, text: String, roll = null, wound := false) -> void:
	var dmg := int(full * quick_harm()) if quick_run and t.side == "PARTY" else full
	var floor_hp := 1 if (not chosen and t.side == "PARTY" and t.hp > 0) or (held_unsterblich and t == lead()) else 0
	# 534 (alt Battle.hitHero, Rasse Orkblütig): einmal je Kampf bleibt er mit 1 TP stehen
	var unerbittlich := floor_hp == 0 and t.side == "PARTY" and t.hero != null and String(t.hero.get("race", "")) == "HALF_ORC" \
			and t.hp > 0 and t.hp <= dmg and not relentless_used.has(t.id)
	if unerbittlich:
		relentless_used[t.id] = true
		floor_hp = 1
	t.hp = maxi(t.hp - dmg, floor_hp)
	_say(text, by if by != "" else null, t.id, dmg, roll, false, wound)
	if unerbittlich:
		_say(fmt(MSG534_RELENTLESS, lang, [t.name(lang)]), t.id)
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
	for f in all.filter(func(x): return x.side == "FOES" and x.standing() and x.follows == leader.id):
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
func _brs_bonus(mode: int, w20: int) -> float:
	return float(mode) * absf(BrsKampf.nachteil()) + BrsKampf.PROZENT_JE_W20 * float(w20)


## Held oder Söldner schlägt mit der Waffe: Fertigkeit der Waffengruppe gegen die Abwehr des Gegners, Schaden (Waffe + Grundwert)
## × (1 + Fertigkeit/100) × Stufenfaktor, kritisch nach Gewandtheit, minus Rüstung (sim.py kampf, Held handelt)
func _brs_waffe(f: Fighter, t: Fighter, advantage: bool, cover: bool, with_weapon) -> void:
	var mode := _row_mode(f, t, true, 1 if advantage else 0, cover)
	var w = with_weapon if with_weapon != null else f.weapon()
	var wsheet: Dictionary = w if w != null else f.hero.main
	var W := BrsKampf.w()
	var k: Dictionary = W["kampf"]
	var gruppe := BrsKampf.waffe_von(wsheet)
	var wd: Dictionary = W["waffen"].get(gruppe, W["waffen"]["Faustkampf"])
	var gw = wd.get("grundwert")
	var grund := float(wd["schaden"]) + (float(f.b.werte.get(gw, 0)) if gw != null else 0.0)
	var bonus := _brs_bonus(mode, _bless(f) - _penalty(f) + _fed(f))
	if String(wd.get("art", "nah")) == "fern":
		bonus += float(k["fernkampf_treffer_je_wahrnehmung"]) * float(f.b.werte.get("wahrnehmung", 0))
	var e := BrsKampf.schlag(dice.rng, float(f.b.fert.get(gruppe, 0)), float(t.b.abwehr), grund, float(int(f.b.stufe) - int(t.b.stufe)),
			float(t.b.ruestung), bonus, float(k["kritisch_prozent_je_gewandtheit"]) * float(f.b.werte.get("gewandtheit", 0)))
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
	var dmg := float(e.schaden) * float(t.b.get("schwaeche", {}).get(String(wd.get("typ", "")), 1.0))
	var n := roundi(dmg)
	if f.has("SNEAK_ATTACK") and (advantage or not f.sneaked):
		n += _srd(t, dice.roll(maxi(1, f.level() / 2), 6))
	f.sneaked = true
	n = maxi(0, n - _srd(t, _weakness(f)) + _srd(t, _fed(f)))
	_hurt(t, n, f.id, fmt(wolf(f, "MSG279_WOLFHITS", "MSG72_HITS"), lang, [f.name(lang), t.name(lang), n]), info, true)
	_life_steal(f, n)
	if not statuses or outcome != "ONGOING" or not t.standing():
		return
	var type := str(wsheet.get("type", "BLUDGEONING"))
	if e.kritisch and type == "SLASHING":
		_inflict(t, "BLEED", 3)
	if e.kritisch and type == "BLUDGEONING" and dice.chance(0.5):
		_inflict(t, "STUN", 1)
	var hits: Dictionary = f.hero.get("hits", {})
	for st in ["POISON", "BLEED", "STUN"]:
		var c := int(hits.get(st, 0))
		if c > 0 and outcome == "ONGOING" and t.standing() and not t.status.has(st) and dice.chance(c / 100.0):
			_inflict(t, st, 1 if st == "STUN" else 3)


## Zauber mit Angriff (Feuerpfeil, Sengender Strahl): Funkenpfeil des BRS, Grundschaden (6 + Wille) im Verhältnis zum alten Würfel,
## Fertigkeit der Schule (Evokation) für Treffer und Schaden
func _brs_zauber(f: Fighter, t: Fighter, dmg: Array) -> void:
	var mode := _row_mode(f, t, false)
	var W := BrsKampf.w()
	var zb: Dictionary = W["zauber"]["Funkenpfeil"]
	var grund := (float(zb["schaden"]) + float(f.b.werte.get("wille", 0))) * BrsKampf.mittel(dmg) / BrsKampf.mittel(BrsKampf.FEUERPFEIL_SRD)
	var e := BrsKampf.schlag(dice.rng, float(f.b.fert.get(String(zb["schule"]), 0)), float(t.b.abwehr), grund,
			float(int(f.b.stufe) - int(t.b.stufe)), float(t.b.ruestung), _brs_bonus(mode, _bless(f) + _fed(f)))
	var info := ["BRS", e.wurf, 0, e.chance, e.treffer, mode, false, false]
	if not e.treffer:
		_say(fmt(wolf(f, "MSG279_WOLFMISSES", "MSG72_MISSES"), lang, [f.name(lang), t.name(lang)]), f.id, t.id, 0, info)
		return
	var n := maxi(0, roundi(float(e.schaden) * float(t.b.get("schwaeche", {}).get(String(zb.get("typ", "")), 1.0))) + _srd(t, _fed(f)))
	_hurt(t, n, f.id, fmt(wolf(f, "MSG279_WOLFHITS", "MSG72_HITS"), lang, [f.name(lang), t.name(lang), n]), info)


## Ein Gegner schlägt den Helden oder Söldner (sim.py auf_held): Angriff gegen die beste Abwehr (Ausweichen, Schild, Parieren), Schaden
## Grundschaden × (1 + Angriff/100) × Stufenfaktor, minus Rüstung und Schild; die Stärke der Ansage (Schwerer Hieb …) im Verhältnis
## ihres Würfels zum Biss der Art
func _brs_auf_held(foe: Fighter, t: Fighter, intent: Dictionary, mode: int) -> Dictionary:
	var m: Dictionary = foe.monster
	var wt = t.weapon()
	var tw := BrsKampf.waffe_von(wt if wt != null else t.hero.main)
	var in_hand := not t.drawn
	var abw: Array = BrsKampf.held_abwehr(t.b, String(foe.b.get("art", "nah")), tw, in_hand)
	var faktor := 1.0
	if intent.extra != null and BrsKampf.mittel(m.dmg) > 0.0:
		faktor += BrsKampf.mittel(intent.extra) / BrsKampf.mittel(m.dmg)
	return BrsKampf.schlag(dice.rng, float(foe.b.angriff), float(abw[1]), float(foe.b.schaden) * faktor,
			float(int(foe.b.stufe) - int(t.b.stufe)), BrsKampf.held_abzug(t.b, in_hand), _brs_bonus(mode, -_penalty(foe)))
