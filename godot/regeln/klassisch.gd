# 390 (Umzug Godot): der klassische Kampf, Zeile für Zeile aus core Battle.kt (Held gegen einen Gegner und sein Rudel).
# Gleiche Regeln, gleiche Reihenfolge der Würfel, gleiche Zeilen: godot/tests/klassisch_golden.gd spielt die Kämpfe aus
# core ClassicGoldenTest nach und vergleicht jeden Schritt. Der Held kommt als Bogen (seine abgeleiteten Zahlen, wie
# ClassicGoldenTest.hero), der Spielstand als Wörterbuch (Leiden, Tasche, Stärkung, Rausch, Atem); was ein Sieg an
# Ausrüstung bringt, gibt der Aufrufer ([gear_drops]), bis Toms Beute (Loot.kt) portiert ist. Elite- und schimmernde
# Gegner: [elite], [elite_trait] ({id, de, en, desc}, Adjektiv schon mit Endung), [shiny]. Die Kommentare nennen die Vorgänge
# wie in Battle.kt; die Gründe stehen dort.
extends RefCounted

const Wuerfel = preload("res://regeln/wuerfel.gd")
const Pech = preload("res://regeln/pechstraehne.gd")

const HP_PER_LEVEL := 0.6
const BOSS_HP_PER_LEVEL := 0.35
const UNCANNY_EVERY_ROUND := 5
const DESTROY_UNDEAD_LEVEL := 5
const LEVEL_ONE_EASE := 2
const LASTING := 99
const OPENERS := ["HERO_ACT", "ENEMY_ACT", "PACK_ACT", "SPELL", "THROW", "DRINK"]
const RARITIES := ["COMMON", "UNCOMMON", "RARE", "VERY_RARE", "EPIC", "DIVINE"]

# Battle.kt Msg, Ui
const APPEARS := ["Achtung! {0} taucht auf!", "Look out! {0} appears!"]
const BOSS_APPEARS := ["{0} stellt sich dir in den Weg!", "{0} blocks your way!"]
const FOE_FASTER := ["{0} ist schneller!", "{0} is faster!"]
const ATTACKS_WITH := ["{0} greift mit {1} an!", "{0} attacks with {1}!"]
const FISTS := ["bloßen Fäusten", "bare fists"]
const MISS := ["Daneben!", "Miss!"]
const CRIT := ["Ein kritischer Treffer!", "A critical hit!"]
const SNEAK := ["Hinterhältiger Angriff!", "Sneak Attack!"]
const USES := ["{0} setzt {1} ein!", "{0} uses {1}!"]
const AC_NOW := ["Die RK von {0} beträgt jetzt {1}.", "{0}'s AC is now {1}."]
const BLESSED := ["{0} fühlt sich gesegnet.", "{0} feels blessed."]
const RESISTS := ["{0} widersteht!", "{0} resists!"]
const TURNED := ["{0} flieht in panischer Angst!", "{0} flees in terror!"]
const DESTROYED := ["{0} zerfällt im heiligen Licht zu Staub!", "{0} crumbles to dust in the holy light!"]
const WEAPON_APPEARS := ["Eine leuchtende Waffe erscheint!", "A glowing weapon appears!"]
const WEAPON_STRIKES := ["Die spirituelle Waffe schlägt zu!", "The spiritual weapon strikes!"]
const GUARDIANS_APPEAR := ["Schützende Geister umkreisen dich!", "Protective spirits circle you!"]
const GUARDIANS_STRIKE := ["Die Geisterwächter greifen an!", "The spirit guardians attack!"]
const PARTLY_DODGES := ["{0} weicht teilweise aus!", "{0} partly dodges!"]
const DODGES := ["{0} weicht aus!", "{0} dodges!"]
const DRINKS := ["{0} trinkt {1}.", "{0} drinks {1}."]
const THROWS := ["{0} wirft {1}!", "{0} throws {1}!"]
const NO_ESCAPE := ["Vor diesem Gegner gibt es kein Entkommen!", "There is no escape from this foe!"]
const FLED := ["{0} ist entkommen!", "{0} escaped!"]
const CANT_FLEE := ["Die Flucht misslingt!", "The escape fails!"]
const FOE_DRINKS := ["{0} trinkt einen Heiltrank und heilt {1} TP!", "{0} drinks a potion and heals {1} HP!"]
const FOE_ATTACKS := ["{0} greift an: {1}!", "{0} attacks: {1}!"]
const FOE_MISSES := ["{0} verfehlt!", "{0} misses!"]
const ENDS_TURN := ["{0} wartet ab.", "{0} waits."]
const DEFENDS := ["{0} geht in Abwehrhaltung.", "{0} takes a defensive stance."]
const OPENING := ["Abgewehrt – {0} sieht eine Lücke für einen Konter!", "Fended off – {0} sees an opening to strike back!"]
const COUNTER_STRIKE := ["{0} nutzt die Lücke!", "{0} strikes into the opening!"]
const BRUTAL := ["Ein brutaler Überraschungsschlag!", "A brutal surprise blow!"]
const MARTIAL := ["{0} nutzt eine Lücke in deiner Deckung!", "{0} exploits a gap in your guard!"]
# 354: Warnungen vor einem harten Schlag (STORY-SPIEL.md [354.grak], [354.wildschwein], [354.krogg])
const WARN_MARTIAL := ["{0} mustert deine Deckung und wartet auf die Lücke.", "{0} studies your guard, waiting for an opening."]
const WARN_CHARGE := ["{0} scharrt mit den Hufen und senkt die Hauer.", "{0} paws the ground and lowers its tusks."]
const WARN_BRUTAL := ["{0} holt mit dem Morgenstern weit aus.", "{0} swings the morningstar far back."]
const UNCANNY := ["{0} weicht geschickt aus und halbiert den Schaden!", "{0} deftly dodges and halves the damage!"]
# [303.knie]
const PRONE := ["{0} wird in die Knie gezwungen und muss sich schwer auf die Waffe stützen.", "{0} is driven to one knee and has to lean hard on their weapon."]
const LUCKY := ["Glück gehabt! Neuer Wurf!", "Lucky! Reroll!"]
const IMMUNE := ["Es hat keine Wirkung …", "It has no effect…"]
const NOT_EFFECTIVE := ["Das richtet kaum etwas aus …", "That barely leaves a mark…"]
const SUPER_EFFECTIVE := ["Das trifft eine Schwachstelle!", "That hits a weak spot!"]
const DAMAGE_TO := ["{0} erleidet {1} Schaden.", "{0} takes {1} damage."]
const FORTITUDE := ["{0} weigert sich zu fallen!", "{0} refuses to fall!"]
const DEFEATED := ["{0} wurde besiegt!", "{0} was defeated!"]
const RELENTLESS := ["{0} bleibt mit eisernem Willen stehen!", "{0} stays standing through sheer will!"]
const HERO_FALLS := ["{0} bricht zusammen …", "{0} collapses…"]
const HEALS := ["{0} heilt {1} TP.", "{0} recovers {1} HP."]
const GAIN_XP := ["{0} erhält {1} EP.", "{0} gains {1} XP."]
const KNOWS := ["{0} erkennt: {1}.", "{0} recognizes: {1}."]
const COWED := ["{0} zögert, eingeschüchtert von {1}!", "{0} hesitates, cowed by {1}!"]
const MAGE_ARMOR_HOLDS := ["Die Magierrüstung von {0} hält noch: RK {1}.", "{0}'s Mage Armor still holds: AC {1}."]
const FED := ["{0} ist gut gestärkt: +1 auf Angriffe und Schaden.", "{0} is well fed: +1 to attacks and damage."]
const CAPPED := ["Höchststufe für Kapitel 1 erreicht – keine weiteren EP in diesem Kapitel. Beute und Ausrüstung gibt es weiterhin.", "Level cap for Chapter 1 reached – no further XP in this chapter. Loot and gear still drop."]
const GAIN_GOLD := ["Du erbeutest {0} Gold.", "You loot {0} gold."]
const LOOT := ["Beute: {0}!", "Loot: {0}!"]
const GEAR_LOOT := ["Beute: {0} ({1})!", "Loot: {0} ({1})!"]
const AMBUSH := ["Hinterhalt! {0} springt aus dem Versteck!", "Ambush! {0} leaps out of hiding!"]
const FIRST_STRIKE := ["{0} überrascht {1} von hinten – Erstschlag!", "{0} catches {1} from behind – first strike!"]
const ELITE := ["Elite-{0}", "Elite {0}"]
const ELITE_TRAIT := ["Ein Elite-Gegner! {0}", "An elite foe! {0}"]
const SHINY := ["Er schimmert in seltsamen Farben … eine seltene Erscheinung!", "It shimmers in strange colors… a rare sight!"]
const STILL_SURPRISED := ["{0} ist noch überrascht und kann nicht reagieren!", "{0} is still caught off guard and can't react!"]
const GAINED := {
	"POISON": ["{0} ist vergiftet!", "{0} is poisoned!"],
	"BURN": ["{0} fängt Feuer!", "{0} catches fire!"],
	"BLEED": ["{0} blutet!", "{0} is bleeding!"],
	"STUN": ["{0} ist betäubt!", "{0} is stunned!"],
	"SLOW": ["{0} ist verlangsamt!", "{0} is slowed!"],
	"WEAK": ["{0} ist geschwächt!", "{0} is weakened!"],
	"BLIND": ["{0} ist geblendet!", "{0} is blinded!"],
}
const HURTS := {
	"POISON": ["Das Gift zehrt an {0}.", "The poison eats at {0}."],
	"BURN": ["{0} brennt!", "{0} burns!"],
	"BLEED": ["{0} verliert Blut.", "{0} loses blood."],
}
const STUNNED := ["{0} ist betäubt und kann nicht handeln!", "{0} is stunned and can't act!"]
const STATUS_ENDS := ["{0} ist nicht mehr {1}.", "{0} is no longer {1}."]
const SHRUGS := ["{0} widersteht der Wirkung!", "{0} resists the effect!"]
const STEADFAST := ["{0} bleibt standhaft!", "{0} stands firm!"]
const DWARF_POISON := ["Zwergische Zähigkeit: {0} widersteht dem Gift!", "Dwarven Resilience: {0} resists the poison!"]
const SHAKES_OFF := ["{0} schüttelt die Betäubung ab!", "{0} shrugs off the stun!"]
const CURED := ["{0} ist von allen Leiden befreit!", "{0} is cured of all ailments!"]
const SHAMAN_CURSE := ["{0} spricht einen Fluch!", "{0} casts a curse!"]
const WEB := ["{0} spinnt ein klebriges Netz!", "{0} spins a sticky web!"]
const SCREECH := ["{0} flattert dir ins Gesicht!", "{0} flaps right into your face!"]
const ELF_IMMUNE := ["Elfen sind gegen Lähmung immun – {0} bleibt unbeeindruckt.", "Elves are immune to paralysis – {0} is unaffected."]
const FLUTTERS := ["{0} flattert davon – daneben!", "{0} flutters away – a miss!"]
const SHAMAN_HEALS := ["{0} murmelt einen Heilzauber und heilt {1} TP!", "{0} mutters a healing spell and recovers {1} HP!"]
const SHAMAN_BOLT := ["{0} schleudert einen Feuerpfeil!", "{0} hurls a fire bolt!"]
const CHARGE := ["{0} stürmt heran!", "{0} charges!"]
const DRAIN := ["{0} saugt Blut!", "{0} drinks blood!"]
const ACID := ["Ätzende Säure spritzt!", "Corrosive acid splashes!"]
const CORRODE := ["Die Säure zerfrisst die Rüstung! RK von {0}: {1}.", "The acid eats into the armor! {0}'s AC: {1}."]
const LIFESTEAL := ["{0} saugt {1} TP ab.", "{0} drains {1} HP."]
const LEVEL_UP := ["{0} erreicht Stufe {1}!", "{0} reaches level {1}!"]
const NEW_SKILL := ["Neue Fähigkeit: {0}!", "New ability: {0}!"]
const RESTORED := ["TP und ZP von {0} sind vollständig aufgefüllt!", "{0}'s HP and SP are fully restored!"]
const POINTS := ["+{0} Attributspunkt(e) – verteile sie im Menü.", "+{0} ability point(s) – spend them in the menu."]
const CANNOT := ["Das geht nicht.", "You can't do that."]
const NO_USES := ["Diese Fähigkeit ist in diesem Kampf erschöpft.", "That ability is spent for this battle."]
const NO_SP := ["Nicht genug Zauberpunkte!", "Not enough spell points!"]
const NO_EFFECT := ["Das hätte keine Wirkung.", "That would have no effect."]
const NOT_UNDEAD := ["Das wirkt nur gegen Untote.", "That only works against undead."]
const CANNOT_USE_HERE := ["Das kannst du hier nicht benutzen.", "You can't use that here."]
const ALREADY_FULL := ["Deine TP sind bereits voll.", "Your HP is already full."]

var lang := 0
var dice
var tables: Dictionary
## der Held als Bogen (ClassicGoldenTest.hero); hp, sp, xp, level, spent ändern sich im Kampf
var hero: Dictionary
## Spielstand: ailments, drunk, wellFed, winded, mageArmorOn, inventory, levelCap, gold, battlesWon
var state: Dictionary
var monster: Dictionary
var pack = null
var pack_size := 0
var kit_attack = null
var level := 1
var area_level := 1
var opening := "NORMAL"
var elite := false
## {id, de, en, desc: {de, en}} oder null
var elite_trait = null
var shiny := false
var elite_tier := 0
## was ein Sieg an Ausrüstung bringt: Callable(), das [{de, en, rarity, rarDe, rarEn}] gibt, oder die Liste selbst
var gear_drops = []
## Höchstwerte nach einem Stufenaufstieg (Hero.restoreFully), bis Toms Held die Stufe rechnet: Callable(stufe) -> [maxHp, maxSp]
var max_after: Callable

var over := 0
var base_enemy_ac := 0
var first_level_ease := 0
var enemy_attack := 0
var enemy_damage_bonus := 0
var enemy_max_hp := 1
var enemy_hp := 1
var outcome := "ONGOING"
var rewards = null

var uses_left := {}
var mage_armor := false
var blessed := false
var well_fed := false
var drunk := false
var spiritual_weapon := false
var guardians := false
var hero_prone := false
var hero_has_hit := false
var miss_streak = Pech.new()
var dodge_used := false
var relentless_used := false
var enemy_turns := 0
var enemy_potions := 0
var enemy_has_hit := false
var smoke_thrown := false
var smoke_spent := false
var acid := 0
var foe_relentless_used := false
var shaman_heals := 2
var pack_left := 0
var pack_actor := -1
var foe_surprised := 0
var hero_status := {}
var foe_status := {}
var hero_stun_guard := 0
var foe_stun_guard := 0
var fireball_used := false
var defending := false
var counter := false
var counter_named := false
var pending_roll = null
var line_start = null
var steps: Array = []


## [h] Held, [s] Spielstand, [m] Monster wie ClassicGoldenTest; [d] Würfel (wuerfel.gd); [lvl] Stufe des Gegners, [area] des Orts.
func setup(h: Dictionary, s: Dictionary, m: Dictionary, d, lvl := 1, area := -1, open := "NORMAL", p = null, p_size := 0, kit = null, t := {},
		is_elite := false, tr = null, is_shiny := false) -> void:
	hero = h
	state = s
	monster = m
	dice = d
	level = lvl
	area_level = lvl if area < 0 else area
	opening = open
	pack = p
	pack_size = p_size if p != null else 0
	kit_attack = kit
	tables = t
	elite = is_elite
	elite_trait = tr
	shiny = is_shiny
	over = maxi(level - area_level, 0)
	# Elite wachsen über die ersten Stufen in ihre volle Stärke
	elite_tier = 0 if not elite else (2 if level >= 4 else 1)
	base_enemy_ac = int(m.ac) + over / 2 + (elite_tier if _trait_is("SWIFT") else 0)
	first_level_ease = LEVEL_ONE_EASE if int(hero.level) == 1 else 0
	enemy_attack = int(m.atk) + over * 2 / 3 + elite_tier + (1 if shiny else 0) - first_level_ease
	enemy_damage_bonus = over + elite_tier + (elite_tier if _trait_is("SAVAGE") else 0)
	var per := BOSS_HP_PER_LEVEL if bool(m.boss) else HP_PER_LEVEL
	enemy_max_hp = maxi(1, int(dice.roll_expr(m.hp) * (1 + per * over) * (1.8 if elite_tier == 2 else (1.5 if elite else 1.0)) *
		(1.3 if _trait_is("ANCIENT") else 1.0) * (1.3 if shiny else 1.0)))
	enemy_hp = enemy_max_hp
	mage_armor = bool(s.get("mageArmorOn", false))
	well_fed = bool(s.get("wellFed", false))
	s["wellFed"] = false
	drunk = bool(s.get("drunk", false))
	enemy_potions = int(m.get("potions", 0))
	pack_left = pack_size
	foe_surprised = 1 if opening == "HERO_FIRST" else 0
	for nm in s.get("ailments", {}):
		if int(s.ailments[nm]) > 0 and GAINED.has(nm):
			hero_status[nm] = int(s.ailments[nm])
	if drunk:
		hero_status["DRUNK"] = LASTING
	for sk in _class_skills():
		if sk.cost == "PER_BATTLE":
			uses_left[sk.id] = int(sk.amount)
		elif sk.cost == "PER_REST":
			uses_left[sk.id] = maxi(int(sk.amount) - int(hero.get("spent", {}).get(sk.id, 0)), 0)


func _class_skills() -> Array:
	return tables.get("skills", []).filter(func(sk): return sk.cls == hero.cls)


func _skill(id: String) -> Dictionary:
	for sk in tables.get("skills", []):
		if sk.id == id:
			return sk
	return {}


func _item(id: String) -> Dictionary:
	for it in tables.get("items", []):
		if it.id == id:
			return it
	return {}


static func fmt(t: Array, lang_i: int, args := []) -> String:
	var s: String = t[lang_i]
	for i in args.size():
		s = s.replace("{%d}" % i, str(args[i]))
	return s


func _t(x: Dictionary) -> String:
	return str(x.en if lang == 1 else x.de)


func _chance(p: float) -> bool:
	return dice.next_int(0, 1000) / 1000.0 < p     # wie Dice.chance mit dem Band aus ClassicGoldenTest


func _mod(a: String) -> int:
	return int(hero.mods[a])


func _has(skill: String) -> bool:
	return skill in hero.get("skills", [])


func _ongoing() -> bool:
	return outcome == "ONGOING"


func hero_ac() -> int:
	return int(hero.acMage if mage_armor else hero.ac) - acid - (2 if hero_status.has("SLOW") else 0)


func enemy_ac() -> int:
	return base_enemy_ac - (2 if foe_status.has("SLOW") else 0)


func _attack_penalty(on_hero: bool) -> int:
	var m := hero_status if on_hero else foe_status
	return (2 if m.has("WEAK") else 0) + (2 if m.has("SLOW") else 0)


func _damage_penalty(on_hero: bool) -> int:
	return 2 if (hero_status if on_hero else foe_status).has("WEAK") else 0


func _fx(kind: String, on_hero: bool, crit := false, past = null) -> Dictionary:
	return {"kind": kind, "on_hero": on_hero, "crit": crit, "past": past}


func _cantrip_dice() -> int:
	return 1 + [5, 11, 17].filter(func(l): return int(hero.level) >= l).size()


func _name() -> String:
	return str(hero.name)


func _trait_is(id: String) -> bool:
	return elite_trait != null and elite_trait.id == id


## Elite und schimmernde tragen ein Adjektiv („Giftiger Wolf“).
func foe_name() -> String:
	var nm := str(monster.en if lang == 1 else monster.de)
	if shiny:
		return ("Shimmering" if lang == 1 else "Schimmernd" + str(monster.get("ending", "er"))) + " " + nm
	if elite_trait != null:
		return _t(elite_trait) + " " + nm
	if elite:
		return fmt(ELITE, lang, [nm])
	return nm


func _weapon_null(w) -> bool:
	return w == null or str(w.id) == ""


func _weapon_name(w) -> String:
	return FISTS[lang] if _weapon_null(w) else str(w.en if lang == 1 else w.de)


func _weapon_fx(w) -> String:
	if _weapon_null(w):
		return "SMASH"
	if bool(w.ranged):
		return "ARROW"
	if w.type == "SLASHING":
		return "SLASH"
	if w.type == "PIERCING":
		return "PIERCE"
	return "SMASH"


# ---------------------------------------------------------------- public API

func start() -> Array:
	match opening:
		"AMBUSHED":
			_say(fmt(AMBUSH, lang, [foe_name()]), "ENEMY_ACT")
		"HERO_FIRST":
			_say(fmt(FIRST_STRIKE, lang, [_name(), foe_name()]))
		_:
			_say(fmt(BOSS_APPEARS if bool(monster.boss) else APPEARS, lang, [foe_name()]))
	if shiny:
		_say(SHINY[lang])
	_smoke_bundle()
	if elite_trait != null:
		_say(fmt(ELITE_TRAIT, lang, [_t(elite_trait.desc)]))
	if pack != null and pack_size > 0:
		_say(fmt([pack.intro.de, pack.intro.en], lang, [pack_size]))
	if well_fed:
		_say(fmt(FED, lang, [_name()]))
	if mage_armor and int(hero.get("chestArmor", 0)) == 0:
		_say(fmt(MAGE_ARMOR_HOLDS, lang, [_name(), hero_ac()]))
	if _mod("INT") >= 1:     # Perks.knowsWeaknesses
		var w = _weaknesses()
		if w != null:
			_say(fmt(KNOWS, lang, [_name(), w]))
	var cow := 0.08 * maxi(0, _mod("CHA"))     # Perks.cowChance
	if opening != "AMBUSHED" and not bool(monster.boss) and cow > 0 and foe_surprised == 0 and _chance(cow):
		foe_surprised = 1
		_say(fmt(COWED, lang, [foe_name(), _name()]))
	if opening == "AMBUSHED":
		_enemy_turn()
		_hero_turn_start()
		return _warned_flush()
	if opening == "HERO_FIRST":
		return _warned_flush()
	var elf := 2 if hero.race == "ELF" else 0
	# 86.3/72.11: außer Atem würfelt der Held die Initiative mit Nachteil
	var hero_init: int = dice.d20(-1 if bool(state.get("winded", false)) else 0) + _mod("DEX") + elf
	var foe_init: int = dice.d20() + int(monster.dex)
	if foe_init > hero_init or (_trait_is("SWIFT") and elite_tier == 2):
		_say(fmt(FOE_FASTER, lang, [foe_name()]))
		_enemy_turn()
		_hero_turn_start()
	return _warned_flush()


func uses_left_of(skill: String):
	return uses_left.get(skill)


## D4.1: Morwens Rauchbündel fliegt, sobald Krogg auftaucht, ohne den Zug des Helden.
func _smoke_bundle() -> void:
	var inv: Dictionary = state.get("inventory", {})
	if monster.id != "bugbear" or int(inv.get("smoke_bundle", 0)) <= 0:
		return
	_remove("smoke_bundle")
	smoke_thrown = true
	_say(fmt(THROWS, lang, [_name(), _t(_item("smoke_bundle")) if not _item("smoke_bundle").is_empty() else "smoke_bundle"]), "THROW", null, _fx("SMOKE", false))


func _remove(id: String) -> void:
	var inv: Dictionary = state.get("inventory", {})
	inv[id] = int(inv.get(id, 0)) - 1
	if int(inv[id]) <= 0:
		inv.erase(id)


func _count(id: String) -> int:
	return int(state.get("inventory", {}).get(id, 0))


## leer, wenn nutzbar, sonst der Grund [de, en].
func blocked(skill: String) -> Array:
	var sk := _skill(skill)
	if not _has(skill) or sk.get("cost", "") == "PASSIVE":
		return CANNOT
	if skill == "FIREBALL" and fireball_used:
		return NO_USES
	if (sk.cost == "PER_BATTLE" or sk.cost == "PER_REST") and int(uses_left.get(skill, 0)) <= 0:
		return NO_USES
	if sk.cost == "SPELL_POINTS" and int(hero.sp) < int(sk.amount):
		return NO_SP
	if skill == "MAGE_ARMOR" and (mage_armor or int(hero.get("chestArmor", 0)) > 0):
		return NO_EFFECT
	if skill == "BLESS" and blessed:
		return NO_EFFECT
	if skill == "SPIRITUAL_WEAPON" and spiritual_weapon:
		return NO_EFFECT
	if skill == "SPIRIT_GUARDIANS" and guardians:
		return NO_EFFECT
	if skill == "TURN_UNDEAD" and not bool(monster.undead):
		return NOT_UNDEAD
	return []


## Weihwasser schadet nur Untoten (SRD).
func blocked_item(id: String) -> Array:
	if id == "holy_water" and not bool(monster.undead):
		return NOT_UNDEAD
	return []


## [action] ["attack"], ["defend"], ["wait"], ["flee"], ["skill", id], ["item", id]
func act(action: Array) -> Array:
	assert(_ongoing(), "Battle is over")
	defending = false
	counter_named = false
	var took := false
	match action[0]:
		"defend":
			defending = true
			_say(fmt(DEFENDS, lang, [_name()]), "DEFEND")
			took = true
		"attack":
			_attack_action(0)
			took = true
		"skill":
			took = _use_skill(action[1])
		"item":
			took = _use_item(action[1])
		"flee":
			took = _flee()
		"wait":
			_say(fmt(ENDS_TURN, lang, [_name()]))
			took = true
	if took and _ongoing():
		_bonus_effects()
	if took and _ongoing():
		_enemy_turn()
	if took and _ongoing():
		_hero_turn_start()
	return _warned_flush() if took else _flush()


## 354: ob der nächste Zug des Gegners einen harten Schlag bringt (Grak, Wildschwein, Krogg).
func hard_blow_next() -> bool:
	if not _ongoing() or foe_surprised > 0:
		return false
	if enemy_potions > 0 and enemy_hp < enemy_max_hp / 2:
		return false
	match monster.special:
		"MARTIAL_ADVANTAGE":
			return (enemy_turns + 1) % 3 == 1
		"CHARGE":
			return not enemy_has_hit
		"SURPRISE_ATTACK":
			return not enemy_has_hit and not (smoke_thrown and not smoke_spent)
	return false


func _hard_blow_now() -> bool:
	match monster.special:
		"MARTIAL_ADVANTAGE":
			return enemy_turns % 3 == 1
		"CHARGE":
			return not enemy_has_hit
		"SURPRISE_ATTACK":
			return not enemy_has_hit and not (smoke_thrown and not smoke_spent)
	return false


func _warned_flush() -> Array:
	if hard_blow_next():
		match monster.special:
			"MARTIAL_ADVANTAGE":
				_say(fmt(WARN_MARTIAL, lang, [foe_name()]))
			"CHARGE":
				_say(fmt(WARN_CHARGE, lang, [foe_name()]))
			"SURPRISE_ATTACK":
				_say(fmt(WARN_BRUTAL, lang, [foe_name()]))
	return _flush()


## 272 (nur Prüfmodus): beendet den Kampf sofort auf dem üblichen Weg.
func test_end(win: bool) -> Array:
	assert(_ongoing(), "Battle is over")
	if win:
		enemy_hp = 0
		_say(fmt(DEFEATED, lang, [foe_name()]), "ENEMY_FAINT")
		_finish_win(false)
	else:
		hero.hp = 0
		_say(fmt(HERO_FALLS, lang, [_name()]), "HERO_FAINT")
		outcome = "LOST"
	return _flush()


# ---------------------------------------------------------------- hero actions

func _attack_action(advantage: int) -> void:
	_weapon_attack(advantage, hero.main, false)
	if _has("EXTRA_ATTACK") and _ongoing():
		_weapon_attack(advantage, hero.main, false)
	if hero.get("off") != null and _ongoing():
		_weapon_attack(advantage, hero.off, true)


func _weapon_attack(advantage: int, w, _off_hand: bool) -> void:
	var counter_mode := _take_counter()
	_say(fmt(ATTACKS_WITH, lang, [_name(), _weapon_name(w)]), "HERO_ACT")
	var ranged: bool = not _weapon_null(w) and bool(w.ranged)
	if monster.special == "EVASIVE" and not ranged and _chance(0.2):
		_say(fmt(FLUTTERS, lang, [foe_name()]), "MISS", null, _fx("DODGE", false))
		return
	var mode := advantage + counter_mode
	if hero_prone:
		mode -= 1
		hero_prone = false
	if hero_status.has("BLIND"):
		mode -= 1
	if drunk:
		mode -= 1
	var roll := _hero_d20(clampi(mode, -1, 1))
	var crit := roll >= int(hero.crit)
	var total: int = roll + int(w.atk) + _bless_bonus() + _fed_bonus() + miss_streak.bonus() - _attack_penalty(true)
	var hit := roll != 1 and (crit or total >= enemy_ac())
	pending_roll = [roll, total - roll, enemy_ac(), hit, clampi(mode, -1, 1)]
	if not hit:
		miss_streak.miss()
		_say(MISS[lang], "MISS", null, _fx("DODGE", false, false, "ARROW" if ranged else null))
		return
	miss_streak.hit()
	var base: Array = w.dmg
	var dmg: int = dice.roll_expr([int(base[0]) * 2, base[1], base[2]] if crit else base) - _damage_penalty(true) + _fed_bonus()
	var sneakable: bool = _weapon_null(w) or bool(w.finesse) or ranged
	if _has("SNEAK_ATTACK") and sneakable and (not hero_has_hit or mode > 0):
		var n := (int(hero.level) + 1) / 2
		dmg += dice.roll(n * 2 if crit else n, 6)
		_say(SNEAK[lang])
	hero_has_hit = true
	if crit:
		_say(CRIT[lang])
	var type: String = "BLUDGEONING" if _weapon_null(w) else str(w.type)
	var dealt := _hit_enemy(maxi(1, dmg), type, crit, _fx(_weapon_fx(w), false, crit))
	var ls := int(hero.get("lifeSteal", 0))
	if ls > 0 and dealt > 0 and int(hero.hp) > 0 and int(hero.hp) < int(hero.maxHp):
		var heal := maxi(1, dealt * ls / 100)
		hero.hp = mini(int(hero.maxHp), int(hero.hp) + heal)
		_say(fmt(LIFESTEAL, lang, [_name(), heal]), "HERO_HEAL", null, _fx("HEAL", true))
	if not _ongoing():
		return
	# kritische Treffer verwunden: Klingen lassen bluten, Wuchtwaffen können betäuben
	if crit and type == "SLASHING":
		_inflict(false, "BLEED", 3)
	if crit and type == "BLUDGEONING" and _chance(0.5):
		_inflict(false, "STUN", 1)
	for pr in [["POISON_HIT", "POISON"], ["BLEED_HIT", "BLEED"], ["STUN_HIT", "STUN"]]:
		var ch := int(hero.get("bonus", {}).get(pr[0], 0))
		if ch > 0 and _ongoing() and not foe_status.has(pr[1]) and _chance(ch / 100.0):
			_inflict(false, pr[1], 1 if pr[1] == "STUN" else 3)


func _take_counter() -> int:
	if counter_named:
		counter_named = false
		return 1
	if not counter:
		return 0
	counter = false
	_say(fmt(COUNTER_STRIKE, lang, [_name()]))
	return 1


func _name_counter() -> void:
	if not counter:
		return
	counter = false
	counter_named = true
	_say(fmt(COUNTER_STRIKE, lang, [_name()]))


func _foe_mode(base: int) -> int:
	return clampi(base - (1 if defending else 0), -1, 1)


func _foe_roll(roll: int, bonus: int, mode: int) -> void:
	pending_roll = [roll, bonus, hero_ac(), roll != 1 and (roll == 20 or roll + bonus >= hero_ac()), mode]


func _opened_up() -> void:
	if defending and not counter:
		counter = true
		_say(fmt(OPENING, lang, [_name()]))


func _spell_attack(dmg: Array, type: String, kind: String) -> bool:
	var mode := clampi((-1 if hero_status.has("BLIND") else 0) - (1 if drunk else 0) + _take_counter(), -1, 1)
	var roll := _hero_d20(mode)
	var crit := roll == 20
	var total: int = roll + int(hero.spellAtk) + _bless_bonus() + _fed_bonus() + miss_streak.bonus() - _attack_penalty(true)
	pending_roll = [roll, total - roll, enemy_ac(), roll != 1 and (crit or total >= enemy_ac()), mode]
	if roll == 1 or (not crit and total < enemy_ac()):
		miss_streak.miss()
		_say(MISS[lang], "MISS", null, _fx("DODGE", false, false, kind))
		return false
	miss_streak.hit()
	if crit:
		_say(CRIT[lang])
	_hit_enemy(dice.roll_expr([int(dmg[0]) * 2, dmg[1], dmg[2]] if crit else dmg), type, crit, _fx(kind, false, crit))
	return true


func _use_skill(skill: String) -> bool:
	var why := blocked(skill)
	if not why.is_empty():
		_say(why[lang])
		return false
	var sk := _skill(skill)
	match sk.cost:
		"PER_BATTLE":
			uses_left[skill] = int(uses_left[skill]) - 1
		"PER_REST":
			uses_left[skill] = int(uses_left[skill]) - 1
			var sp_: Dictionary = hero.get("spent", {})
			sp_[skill] = int(sp_.get(skill, 0)) + 1
			hero["spent"] = sp_
		"SPELL_POINTS":
			hero.sp = int(hero.sp) - int(sk.amount)
	if skill == "FIREBALL":
		fireball_used = true
	if skill == "FIRE_BOLT" or skill == "SCORCHING_RAY":
		_name_counter()
	_say(fmt(USES, lang, [_name(), _t(sk)]), "SPELL")
	match skill:
		"SECOND_WIND":
			_heal_hero(dice.roll(1, 10) + int(hero.level))
		"ACTION_SURGE":
			_attack_action(0)
			if _ongoing():
				_attack_action(0)
		"FIRE_BOLT":
			if _spell_attack([_cantrip_dice(), 10, 0], "FIRE", "FIRE_BOLT") and _chance(0.25):
				_inflict(false, "BURN", 2)
		"MAGIC_MISSILE":
			var s := 0
			for i in 3:
				s += dice.roll_expr([1, 4, 1])
			_hit_enemy(s, "FORCE", false, _fx("MISSILES", false))
		"MAGE_ARMOR":
			mage_armor = true
			state["mageArmorOn"] = true     # Kotlin: mageArmorUntil = clock + 8 h (26.1)
			_say(fmt(AC_NOW, lang, [_name(), hero_ac()]), "NONE", null, _fx("MAGE_ARMOR", true))
		"SCORCHING_RAY":
			for i in 3:
				if _ongoing() and _spell_attack([2, 6, 0], "FIRE", "RAYS") and _chance(0.15):
					_inflict(false, "BURN", 2)
		"FIREBALL":
			if _save_spell([8, 6, 0], "FIRE", int(monster.dex), true, "FIREBALL") and _chance(0.5):
				_inflict(false, "BURN", 2)
			# die Explosion erfasst auch das Rudel im Hintergrund; es flieht, wenn es nicht ausweicht
			if pack != null and pack_left > 0 and _ongoing() and not _foe_saves(int(monster.dex)):
				pack_left = 0
				_say(_t(pack.burned), "PACK_FLEE")
		"FEINT":
			_attack_action(1)
		"SACRED_FLAME":
			if _save_spell([_cantrip_dice(), 8, 0], "RADIANT", int(monster.dex), false, "SACRED_FLAME") and _chance(0.3):
				_inflict(false, "BLIND", 2)
		"CURE_WOUNDS":
			_heal_hero(dice.roll(1 + int(hero.level) / 2, 8) + _mod("WIS"))
		"BLESS":
			blessed = true
			_say(fmt(BLESSED, lang, [_name()]), "NONE", null, _fx("BLESS", true))
		"TURN_UNDEAD":
			if _foe_saves(int(monster.wis)):
				_say(fmt(RESISTS, lang, [foe_name()]))
			elif int(hero.level) >= DESTROY_UNDEAD_LEVEL and _cr_value(str(monster.cr)) <= 0.5:
				# Untote zerstören (SRD): ab Stufe 5 zerfällt ein schwacher Untoter, der scheitert
				enemy_hp = 0
				_say(fmt(DESTROYED, lang, [foe_name()]), "ENEMY_FAINT", null, _fx("DESTROY", false))
				_finish_win(false)
			else:
				_say(fmt(TURNED, lang, [foe_name()]), "ENEMY_FAINT", null, _fx("TURN", false))
				_finish_win(true)
		"SPIRITUAL_WEAPON":
			spiritual_weapon = true
			_say(WEAPON_APPEARS[lang], "NONE", null, _fx("SPIRIT_SUMMON", true))
		"SPIRIT_GUARDIANS":
			guardians = true
			_say(GUARDIANS_APPEAR[lang], "NONE", null, _fx("GUARDIANS", true))
	return true


## true, wenn der Gegner den Rettungswurf verfehlt und die volle Wirkung abbekam.
func _save_spell(dmg: Array, type: String, save_mod: int, half: bool, kind: String) -> bool:
	var amount: int = dice.roll_expr(dmg)
	if _foe_saves(save_mod):
		if half:
			_say(fmt(PARTLY_DODGES, lang, [foe_name()]))
			_hit_enemy(maxi(1, amount / 2), type, false, _fx(kind, false))
		else:
			_say(fmt(DODGES, lang, [foe_name()]), "MISS", null, _fx("DODGE", false, false, kind))
		return false
	_hit_enemy(amount, type, false, _fx(kind, false))
	return _ongoing()


func _use_item(id: String) -> bool:
	var def := _item(id)
	if _count(id) <= 0:
		return false
	var why := blocked_item(id)
	if not why.is_empty():
		_say(why[lang])
		return false
	match def.get("kind", ""):
		"POTION":
			var curable: bool = bool(def.get("cures", false)) and hero_status.keys().any(func(k): return k != "DRUNK")
			if int(hero.hp) >= int(hero.maxHp) and not curable:
				_say(ALREADY_FULL[lang])
				return false
			_remove(id)
			_say(fmt(DRINKS, lang, [_name(), _t(def)]), "DRINK", null, null, id)
			if curable:
				hero_status.clear()
				if drunk:
					hero_status["DRUNK"] = LASTING
				_say(fmt(CURED, lang, [_name()]), "NONE", null, _fx("HEAL", true))
			if int(hero.hp) < int(hero.maxHp):
				_heal_hero(dice.roll_expr(def.heal))
		"BOMB":
			_remove(id)
			_say(fmt(THROWS, lang, [_name(), _t(def)]), "THROW")
			_hit_enemy(dice.roll_expr(def.damage) + maxi(0, _mod("STR")), str(def.type), false, _fx("BOMB_HOLY" if id == "holy_water" else "BOMB_FIRE", false))
			if id == "alchemist_fire":
				_inflict(false, "BURN", 2)
		_:
			_say(CANNOT_USE_HERE[lang])
			return false
	return true


func _flee() -> bool:
	if bool(monster.boss):
		_say(NO_ESCAPE[lang])
		return false
	var elf := 2 if hero.race == "ELF" else 0
	var ok: bool = _has("CUNNING_ACTION") or dice.d20(-1 if drunk else 0) + _mod("DEX") + elf >= 10 + int(monster.dex)
	if ok:
		_say(fmt(FLED, lang, [_name()]))
		outcome = "FLED"
	else:
		_say(CANT_FLEE[lang])
	return true


## Was nach der Handlung des Helden weiterwirkt.
func _bonus_effects() -> void:
	if spiritual_weapon:
		line_start = WEAPON_STRIKES[lang]
		var roll: int = dice.d20()
		if roll != 1 and (roll == 20 or roll + int(hero.spellAtk) >= enemy_ac()):
			_hit_enemy(dice.roll(1, 8) + _mod("WIS"), "FORCE", roll == 20, _fx("SPIRIT_WEAPON", false, roll == 20))
		else:
			_say(MISS[lang], "MISS", null, _fx("DODGE", false, false, "SPIRIT_WEAPON"))
	if guardians and _ongoing():
		_say(GUARDIANS_STRIKE[lang])
		_save_spell([3, 8, 0], "RADIANT", int(monster.wis), true, "GUARDIANS")


# ---------------------------------------------------------------- enemy

func _enemy_turn() -> void:
	if not _ongoing():
		return
	if int(hero.level) >= UNCANNY_EVERY_ROUND:
		dodge_used = false
	if not _tick(false):
		return
	if foe_surprised > 0:
		foe_surprised -= 1
		_say(fmt(STILL_SURPRISED, lang, [foe_name()]))
		return
	enemy_turns += 1
	if enemy_potions > 0 and enemy_hp < enemy_max_hp / 2:
		enemy_potions -= 1
		var heal := _heal_foe(dice.roll_expr([4, 4, 4]))
		_say(fmt(FOE_DRINKS, lang, [foe_name(), heal]), "ENEMY_HEAL", null, _fx("ENEMY_HEAL", false))
		return
	if monster.special == "SHAMAN":
		if shaman_heals > 0 and enemy_hp < enemy_max_hp / 2:
			shaman_heals -= 1
			var heal := _heal_foe(dice.roll_expr([2, 4, 2 + over]))
			_say(fmt(SHAMAN_HEALS, lang, [foe_name(), heal]), "ENEMY_HEAL", null, _fx("ENEMY_HEAL", false))
			return
		if enemy_turns % 3 == 2 and not hero_status.has("WEAK"):
			_say(fmt(SHAMAN_CURSE, lang, [foe_name()]), "ENEMY_ACT")
			_inflict(true, "WEAK", 3, ["WIS", 11], true)
			return
		if enemy_turns % 2 == 1:
			_say(fmt(SHAMAN_BOLT, lang, [foe_name()]), "ENEMY_ACT")
			var blind := -1 if foe_status.has("BLIND") else 0
			var roll: int = dice.d20(_foe_mode(blind))
			_foe_roll(roll, enemy_attack + 1 - _attack_penalty(false), _foe_mode(blind))
			if roll == 1 or (roll != 20 and roll + enemy_attack + 1 - _attack_penalty(false) < hero_ac()):
				_say(fmt(FOE_MISSES, lang, [foe_name()]), "MISS", null, _fx(_defence_fx(), true, false, "FIRE_BOLT"))
				_opened_up()
			else:
				var d := [4 if roll == 20 else 2, 6, enemy_damage_bonus - _damage_penalty(false)]
				_hit_hero(dice.roll_expr(d), _fx("FIRE_BOLT", true, roll == 20))
				if _chance(0.3):
					_inflict(true, "BURN", 2)
			return
	_enemy_attack()
	_pack_jabs()


## Jeder Begleiter darf angreifen: schwächer als der Anführer, aber es summiert sich.
func _pack_jabs() -> void:
	if pack == null:
		return
	var p: Dictionary = pack
	for i in pack_left:
		if not _ongoing() or not _chance(float(p.chance)):
			continue
		pack_actor = i
		_say(_t(p.attack), "PACK_ACT")
		var roll: int = dice.d20(_foe_mode(0))
		var bonus: int = int(monster.atk) + int(p.shift) + over / 2 - first_level_ease
		_foe_roll(roll, bonus, _foe_mode(0))
		if roll == 1 or (roll != 20 and roll + bonus < hero_ac()):
			_say(fmt(FOE_MISSES, lang, [_t(p.one)]), "MISS", null, _fx(_defence_fx(), true, false, p.fx))
			_opened_up()
		else:
			var d: Array = p.dmg
			_hit_hero(dice.roll_expr([int(d[0]) * 2 if roll == 20 else int(d[0]), d[1], int(d[2]) + over / 2]), _fx(p.fx, true, roll == 20))
		pack_actor = -1


func _enemy_attack() -> void:
	# ein Gegner mit einer anderen Waffe als seine Art nennt diese (das Handbeil eines Goblins)
	var attack_name: String = _t(kit_attack) if kit_attack != null else _t(monster.attack)
	_say(fmt(FOE_ATTACKS, lang, [foe_name(), attack_name]), "ENEMY_ACT")
	if _hard_blow_now():
		steps[steps.size() - 1]["heavy"] = true
	if smoke_thrown and not smoke_spent:
		# der Rauch brennt in den Augen: der erste Schlag geht fehl, mit ihm der brutale erste Treffer und seine Betäubung
		smoke_spent = true
		enemy_has_hit = true
		_say(fmt(FOE_MISSES, lang, [foe_name()]), "MISS", null, _fx(_defence_fx() if defending else "DODGE", true, false, monster.fx))
		_opened_up()
		return
	var mode := _foe_mode(-1 if foe_status.has("BLIND") else 0)
	var roll: int = dice.d20(mode)
	var crit := roll == 20
	_foe_roll(roll, enemy_attack - _attack_penalty(false), mode)
	if roll == 1 or (not crit and roll + enemy_attack - _attack_penalty(false) < hero_ac()):
		var shield := bool(hero.get("shield", false))
		var kind := _defence_fx() if defending else ("BLOCK" if shield and _chance(0.6) else "DODGE")
		_say(fmt(FOE_MISSES, lang, [foe_name()]), "MISS", null, _fx(kind, true, false, monster.fx))
		_opened_up()
		return
	var md: Array = monster.dmg
	var d := [int(md[0]), int(md[1]), int(md[2]) + enemy_damage_bonus - _damage_penalty(false)]
	var dmg: int = dice.roll_expr([d[0] * 2, d[1], d[2]] if crit else d)
	if crit:
		_say(CRIT[lang])
	match monster.special:
		"SURPRISE_ATTACK":
			if not enemy_has_hit:
				dmg += dice.roll(2, 6)
				_say(BRUTAL[lang])
		"CHARGE":
			if not enemy_has_hit:
				dmg += dice.roll(1, 6)
				_say(fmt(CHARGE, lang, [foe_name()]))
		"MARTIAL_ADVANTAGE":
			if enemy_turns % 3 == 1:
				dmg += dice.roll(2, 6)
				_say(fmt(MARTIAL, lang, [foe_name()]))
	if _has("UNCANNY_DODGE") and not dodge_used:
		dodge_used = true
		dmg = maxi(1, dmg / 2)
		_say(fmt(UNCANNY, lang, [_name()]))
	var first_hit := not enemy_has_hit
	enemy_has_hit = true
	var dealt := _hit_hero(dmg, _fx(monster.fx, true, crit))
	if not _ongoing():
		return
	# auch kritische Treffer der Monster verwunden
	if crit and monster.type == "SLASHING":
		_inflict(true, "BLEED", 2)
	if crit and monster.type == "BLUDGEONING":
		_inflict(true, "STUN", 1, ["CON", 12])
	if not _ongoing():
		return
	match monster.special:
		"POISON":
			_inflict(true, "POISON", 3, ["CON", 11])
			# die Riesenspinne spinnt auch Netze
			if monster.id == "giant_spider" and _chance(0.25):
				_say(fmt(WEB, lang, [foe_name()]))
				_inflict(true, "SLOW", 2, ["DEX", 11])
		"SURPRISE_ATTACK":
			if first_hit:
				_inflict(true, "STUN", 1, ["CON", 12])
		"MARTIAL_ADVANTAGE":
			if enemy_turns % 3 == 1:
				_inflict(true, "BLEED", 2)
		"EVASIVE":
			if _chance(0.2):
				_say(fmt(SCREECH, lang, [foe_name()]))
				_inflict(true, "BLIND", 2, ["CON", 10])
		"KNOCKDOWN":
			if not _hero_save("STR", 11):
				hero_prone = true
				_say(fmt(PRONE, lang, [_name()]), "HERO_PRONE")
		"BLOOD_DRAIN":
			var drain: int = dice.roll(1, 4)
			_say(fmt(DRAIN, lang, [foe_name()]))
			var taken := _hit_hero(drain, _fx("DRAIN", true))
			enemy_hp = mini(enemy_max_hp, enemy_hp + taken)
			if _chance(0.3):
				_inflict(true, "BLEED", 2)
		"ACID":
			_say(ACID[lang])
			_hit_hero(dice.roll(1, 4), _fx("ACID", true))
			if _ongoing() and acid < 2:
				acid += 1
				_say(fmt(CORRODE, lang, [_name(), hero_ac()]))
		"PARALYZE":
			if hero.race == "ELF":
				_say(fmt(ELF_IMMUNE, lang, [_name()]))
			else:
				_inflict(true, "STUN", 1, ["CON", 10])
	if not _ongoing() or elite_trait == null:
		return
	# etwa jeder zweite Treffer; der Zustand tut den Rest
	match elite_trait.id:
		"VENOMOUS":
			if _chance(0.5):
				_inflict(true, "POISON", 2)
		"BURNING":
			if _chance(0.5):
				_inflict(true, "BURN", 2)
		"VAMPIRIC":
			if enemy_hp < enemy_max_hp:
				var heal := _heal_foe(maxi(1, dealt / 2))
				_say(fmt(LIFESTEAL, lang, [foe_name(), heal]), "ENEMY_HEAL", null, _fx("DRAIN", false))


# ---------------------------------------------------------------- statuses

static func _status_fx(st: String) -> String:
	return st if st in ["POISON", "BURN", "BLEED", "STUN"] else "CURSE"


## Legt [st] für [turns] Runden auf den Helden oder den Gegner; der Held widersteht mit Rettungswurf ([save]: [Attribut, SG])
## oder Zähigkeit. [cast]: der Zauber des Gegners selbst; widersteht der Held, sieht man ihn ausweichen.
func _inflict(on_hero: bool, st: String, turns: int, save = null, cast := false) -> bool:
	if not _ongoing():
		return false
	var m := hero_status if on_hero else foe_status
	var who := _name() if on_hero else foe_name()
	if st == "STUN" and (hero_stun_guard if on_hero else foe_stun_guard) > 0:
		return false
	if on_hero:
		if save != null and _hero_save(save[0], save[1]):
			_say(fmt(SHRUGS, lang, [who]), "NONE", null, _fx("DODGE", true) if cast else null)
			return false
		var ten := int(hero.get("tenacity", 0))
		if ten > 0 and _chance(ten / 100.0):
			_say(fmt(STEADFAST, lang, [who]), "NONE", null, _fx("DODGE", true) if cast else null)
			return false
		if st == "POISON" and hero.race == "DWARF" and _chance(0.5):
			_say(fmt(DWARF_POISON, lang, [who]))
			return false
	else:
		if st in monster.get("statusImmune", []):
			return false
		if bool(monster.boss) and st == "STUN" and _chance(0.5):
			_say(fmt(SHAKES_OFF, lang, [who]))
			return false
	m[st] = maxi(int(m.get(st, 0)), turns)
	if st == "STUN":
		if on_hero:
			hero_stun_guard = 3
		else:
			foe_stun_guard = 3
	_say(fmt(GAINED[st], lang, [who]), "NONE", null, _fx(_status_fx(st), on_hero))
	return true


func _status_damage(st: String, on_hero: bool) -> int:
	var scale := over / 2 if on_hero else int(hero.level) / 3
	var die := [1, 4, 0]
	if st == "POISON" and on_hero and monster.special == "POISON":
		die = monster.poison
	elif st == "BURN":
		die = [1, 6, 0]
	var dmg: int = dice.roll_expr(die) + scale
	if on_hero and st == "POISON" and hero.race == "DWARF":
		dmg = (dmg + 1) / 2
	return maxi(1, dmg)


## Beginn eines Zugs: Schaden über Zeit, dann der Countdown. false, wenn diese Seite nicht handeln kann.
func _tick(on_hero: bool) -> bool:
	var m := hero_status if on_hero else foe_status
	if on_hero and hero_stun_guard > 0:
		hero_stun_guard -= 1
	if not on_hero and foe_stun_guard > 0:
		foe_stun_guard -= 1
	if m.is_empty():
		return true
	var who := _name() if on_hero else foe_name()
	for st in ["POISON", "BURN", "BLEED"]:
		if not m.has(st) or not _ongoing():
			continue
		_say(fmt(HURTS[st], lang, [who]))
		var dmg := _status_damage(st, on_hero)
		if on_hero:
			_hit_hero(dmg, _fx(_status_fx(st), true), true)
		else:
			_hit_enemy(dmg, {"POISON": "POISON", "BURN": "FIRE"}.get(st, "FORCE"), false, _fx(_status_fx(st), false), true)
	if not _ongoing():
		return false
	var stunned := m.has("STUN")
	if stunned:
		_say(fmt(STUNNED, lang, [who]), "NONE", null, _fx("STUN", on_hero))
	for st in m.keys():
		if int(m[st]) >= LASTING:
			continue
		var left := int(m[st]) - 1
		if left <= 0:
			m.erase(st)
			if st != "STUN":
				_say(fmt(STATUS_ENDS, lang, [who, _status_title(st).to_lower()]))
		else:
			m[st] = left
	return not stunned


func _status_title(st: String) -> String:
	var t: Dictionary = tables.get("statusTitles", {}).get(st, {"de": st, "en": st})
	return _t(t)


## Bevor der Held handeln darf: Zustände ticken, ein betäubter Held gibt dem Gegner einen weiteren Zug.
func _hero_turn_start() -> void:
	var guard := 0
	while _ongoing() and guard < 4:
		guard += 1
		if _tick(true):
			return
		_enemy_turn()


func _heal_foe(amount: int) -> int:
	var heal := maxi(1, amount / 2) if foe_status.has("BLEED") else amount
	var before := enemy_hp
	enemy_hp = mini(enemy_max_hp, enemy_hp + heal)
	return enemy_hp - before


# ---------------------------------------------------------------- helpers

func _hero_d20(mode: int) -> int:
	var roll: int = dice.d20(mode)
	if roll == 1 and hero.race == "HALFLING":
		_say(LUCKY[lang])
		roll = dice.d20()
	return roll


func _bless_bonus() -> int:
	return dice.d(4) if blessed else 0


func _fed_bonus() -> int:
	return 1 if well_fed else 0


## „verwundbar gegen Wucht; immun gegen Gift“, null ohne Besonderes.
func _weaknesses():
	var de := lang == 0
	var parts := []
	for pr in [[["verwundbar gegen", "vulnerable to"], "vulnerable"], [["resistent gegen", "resistant to"], "resistant"], [["immun gegen", "immune to"], "immune"]]:
		var types: Array = monster.get(pr[1], [])
		if not types.is_empty():
			parts.append(str(pr[0][0 if de else 1]) + " " + ", ".join(types.map(func(ty): return _t(tables.get("damageTypes", {}).get(ty, {"de": ty, "en": ty})))))
	return null if parts.is_empty() else "; ".join(parts)


func _hero_save(a: String, dc: int) -> bool:
	var prof: int = int(hero.prof) if a in hero.get("saves", []) else 0
	# in der Abwehrhaltung haben Rettungswürfe auf Geschicklichkeit Vorteil (SRD Ausweichen)
	return dice.d20(1 if defending and a == "DEX" else 0) + _mod(a) + prof >= dc


func _defence_fx() -> String:
	var w = hero.get("main")
	return "BLOCK" if bool(hero.get("shield", false)) or (not _weapon_null(w) and not bool(w.ranged)) else "DODGE"


func _hit_enemy(raw: int, type: String, crit: bool, effect = null, quiet := false) -> int:
	var dmg := raw
	var note = null
	if type in monster.get("immune", []):
		dmg = 0
		note = IMMUNE
	elif type in monster.get("resistant", []):
		dmg /= 2
		note = NOT_EFFECTIVE
	elif type in monster.get("vulnerable", []):
		dmg *= 2
		note = SUPER_EFFECTIVE
	if bool(monster.undead) and type == "RADIANT" and note == null:
		dmg += dmg / 2
		note = SUPER_EFFECTIVE
	enemy_hp = maxi(0, enemy_hp - dmg)
	if enemy_hp == 0 and monster.special == "CHARGE" and not foe_relentless_used and dmg <= 7 + over:
		foe_relentless_used = true
		enemy_hp = 1
		_say(fmt(DAMAGE_TO, lang, [foe_name(), dmg]), "ENEMY_HIT", null, effect)
		_say(fmt(RELENTLESS, lang, [foe_name()]))
		return dmg
	if enemy_hp == 0 and monster.special == "UNDEAD_FORTITUDE" and not crit and type != "RADIANT" and dice.d20() + int(monster.con) >= 5 + dmg:
		enemy_hp = 1
		_say(fmt(DAMAGE_TO, lang, [foe_name(), dmg]), "ENEMY_HIT", null, effect)
		_say(fmt(FORTITUDE, lang, [foe_name()]))
		return dmg
	# wie gut es saß, gehört in die Zeile des Schlags: ein tödlicher läuft ohne Zwischenzeile in den Fall
	var how: String = (" " + note[lang]) if not quiet and note != null else ""
	_say(fmt(DAMAGE_TO, lang, [foe_name(), dmg]) + how, "ENEMY_HIT", null, effect)
	if enemy_hp == 0:
		_say(fmt(DEFEATED, lang, [foe_name()]), "ENEMY_FAINT")
		_finish_win(false)
	return dmg


## Gibt den wirklich genommenen Schaden zurück.
func _hit_hero(raw: int, effect = null, ignore_reduction := false) -> int:
	var dmg := maxi(1, raw - (0 if ignore_reduction else int(hero.get("reduction", 0))))
	hero.hp = maxi(0, int(hero.hp) - dmg)
	if int(hero.hp) == 0 and hero.race == "HALF_ORC" and not relentless_used:
		relentless_used = true
		hero.hp = 1
		_say(fmt(DAMAGE_TO, lang, [_name(), dmg]), "HERO_HIT", null, effect)
		_say(fmt(RELENTLESS, lang, [_name()]))
		return dmg
	_say(fmt(DAMAGE_TO, lang, [_name(), dmg]), "HERO_HIT", null, effect)
	if int(hero.hp) == 0:
		_say(fmt(HERO_FALLS, lang, [_name()]), "HERO_FAINT")
		outcome = "LOST"
	return dmg


func _heal_hero(amount: int) -> void:
	var before := int(hero.hp)
	var heal := maxi(1, amount / 2) if hero_status.has("BLEED") else amount
	hero.hp = mini(int(hero.maxHp), int(hero.hp) + heal)
	_say(fmt(HEALS, lang, [_name(), int(hero.hp) - before]), "HERO_HEAL", null, _fx("HEAL", true))


func _xp_for_level() -> Array:
	return tables.get("xpForLevel", [])


func _level_for_xp(xp: int) -> int:
	var tab := _xp_for_level()
	var mx := int(tables.get("maxLevel", 20))
	var l := 1
	while l < mx and xp >= int(tab[l + 1]):
		l += 1
	return l


func _ability_points(lvl: int) -> int:
	return 2 * tables.get("abilityLevels", []).filter(func(x): return int(x) <= lvl).size()


func _finish_win(fled: bool) -> void:
	outcome = "ENEMY_FLED" if fled else "WON"
	if pack != null and pack_left > 0:
		pack_left = 0
		_say(_t(pack.flee), "PACK_FLEE")
	# höhere Stufen sind viel mehr Erfahrung wert, jeder Begleiter etwas
	var scale := 1 + 0.35 * over + 0.05 * over * over
	var share: float = float(pack.xpShare) if pack != null else 0.0
	var b: Dictionary = hero.get("bonus", {})
	var xp := int(int(monster.xp) * scale * (1 + share * pack_size) * (2.5 if elite else 1.0) * (2.0 if shiny else 1.0) * (1 + int(b.get("XP", 0)) / 100.0) * (1.0 + 0.03 * maxi(0, _mod("INT"))))
	var gold := 0 if fled else int(dice.roll_expr(monster.gold) * (1 + over * 0.3) * (2.0 if elite else 1.0) * (3.0 if shiny else 1.0) * (1 + int(b.get("GOLD_FIND", 0)) / 100.0))
	var fixed := []
	if not fled:
		for e in monster.get("loot", []):
			if _chance(float(e.chance)):
				fixed.append(e)
	var items := fixed.filter(func(e): return bool(e.get("exists", true))).map(func(e): return str(e.item))
	var gear: Array = []
	if not fled:
		gear = gear_drops.call() if gear_drops is Callable else gear_drops
	state["gold"] = int(state.get("gold", 0)) + gold
	var inv: Dictionary = state.get("inventory", {})
	for it in items:
		inv[it] = int(inv.get(it, 0)) + 1
	state["inventory"] = inv
	state["battlesWon"] = int(state.get("battlesWon", 0)) + 1
	var old_level := int(hero.level)
	var xp_before := int(hero.xp)
	var gained := _gain_xp(xp, int(state.get("levelCap", 20)))
	var earned := int(hero.xp) - xp_before
	rewards = {"xp": earned, "gold": gold, "items": items, "gear": gear, "levels": gained}
	if earned > 0:
		_say(fmt(GAIN_XP, lang, [_name(), earned]))
	var mx := int(tables.get("maxLevel", 20))
	var cap := int(state.get("levelCap", mx))
	if earned < xp and cap < mx and int(hero.level) >= cap:     # Story.capped
		_say(CAPPED[lang])
	if gold > 0:
		_say(fmt(GAIN_GOLD, lang, [gold]), "COINS")
	for it in items:
		_say(fmt(LOOT, lang, [_t(_item(it)) if not _item(it).is_empty() else it]), "LOOT")
	var sorted := gear.duplicate()
	# stabil wie sortedByDescending
	var idx := range(sorted.size())
	idx.sort_custom(func(a, c): return RARITIES.find(sorted[a].rarity) > RARITIES.find(sorted[c].rarity) or (sorted[a].rarity == sorted[c].rarity and a < c))
	for i in idx:
		var g: Dictionary = sorted[i]
		_say(fmt(GEAR_LOOT, lang, [g.en if lang == 1 else g.de, g.rarEn if lang == 1 else g.rarDe]), "LOOT", g.rarity)
	for lvl in range(old_level + 1, int(hero.level) + 1):
		_say(fmt(LEVEL_UP, lang, [_name(), lvl]), "LEVEL_UP")
		for sk in _class_skills():
			if int(sk.level) == lvl:
				_say(fmt(NEW_SKILL, lang, [_t(sk)]))
	if gained > 0:
		_say(fmt(RESTORED, lang, [_name()]), "HERO_HEAL")
		# Attributspunkte nur auf bestimmten Stufen (SRD)
		var points := _ability_points(int(hero.level)) - _ability_points(old_level)
		if points > 0:
			_say(fmt(POINTS, lang, [points]))


## Hero.gainXp: Erfahrung, Stufen bis zur Höchststufe des Kapitels; ein Aufstieg füllt TP und ZP.
func _gain_xp(amount: int, cap: int) -> int:
	var before := int(hero.level)
	var mx := int(tables.get("maxLevel", 20))
	hero.xp = int(hero.xp) + amount
	var target := mini(_level_for_xp(int(hero.xp)), cap)
	while int(hero.level) < target:
		hero.level = int(hero.level) + 1
	if cap < mx:
		hero.xp = mini(int(hero.xp), int(_xp_for_level()[cap]))
	if int(hero.level) > before and max_after.is_valid():
		var m: Array = max_after.call(int(hero.level))
		hero.maxHp = m[0]
		hero.maxSp = m[1]
		hero.hp = m[0]
		hero.sp = m[1]
	return int(hero.level) - before


## Rettungswurf des Gegners gegen den Zauber-SG des Helden.
func _foe_saves(mod: int) -> bool:
	return dice.d20() + mod >= int(hero.spellDc)


static func _cr_value(cr: String) -> float:
	var p := cr.split("/")
	return float(p[0]) / float(p[1]) if p.size() == 2 else float(p[0])


func _say(text0: String, anim := "NONE", rarity = null, fx = null, item = null) -> void:
	var text: String = (str(line_start) + " " + text0) if line_start != null else text0
	line_start = null
	var roll = pending_roll if anim in ["MISS", "HERO_HIT", "ENEMY_HIT"] else null
	# jedes andere Bild (der Beginn des nächsten Schlags) beendet einen Wurf ohne Treffer oder Fehlschlag
	if anim != "NONE":
		pending_roll = null
	steps.append({"t": text, "hh": int(hero.hp), "eh": enemy_hp, "sp": int(hero.sp), "a": anim, "rar": rarity, "fx": fx, "item": item,
		"roll": roll, "sh": hero_status.duplicate(), "sf": foe_status.duplicate(), "p": pack_left, "pa": pack_actor, "lead": false, "heavy": false})


func _flush() -> Array:
	var out := merged(steps.duplicate())
	steps.clear()
	return out


static func _resolves(open: Dictionary, s: Dictionary) -> bool:
	var on_hero = s.fx.on_hero if s.fx != null else null
	match open.a:
		"ENEMY_ACT":
			return s.a in ["HERO_HIT", "HERO_FAINT", "MISS", "NONE"] and on_hero == true
		"PACK_ACT":
			return s.a in ["HERO_HIT", "HERO_FAINT", "MISS"] and on_hero == true
		"HERO_ACT":
			return s.a in ["ENEMY_HIT", "ENEMY_FAINT", "MISS"] and on_hero == false
	return s.fx != null or s.a != "NONE"


## Jede Handlung als ein Stück: ihre Anfangsworte, schlichte Worte dazwischen und die Worte ihres Endes werden ein Text am
## Schritt, der sie beendet; der Anfang bleibt ohne eigene Worte als „lead“ stehen (Battle.merged).
static func merged(list: Array) -> Array:
	var out := list
	var i := 0
	while i < out.size():
		var open: Dictionary = out[i]
		if open.a in OPENERS and not open.lead:
			var j := i + 1
			while j < out.size() and out[j].a == "NONE" and out[j].fx == null and not _resolves(open, out[j]):
				j += 1
			if j < out.size() and _resolves(open, out[j]):
				var words := []
				for k in range(i, j):
					words.append(out[k].t)
				words.append(out[j].t)
				var end: Dictionary = out[j].duplicate()
				end.t = " ".join(words)
				out[j] = end
				for k in range(j - 1, i, -1):
					out.remove_at(k)
				var o2: Dictionary = open.duplicate()
				o2.lead = true
				out[i] = o2
		i += 1
	return out
