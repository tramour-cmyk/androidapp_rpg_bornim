# 399.2 (Spielfassung, Perikles 28.10., 12:4x; Chef 12:34 „Ich habe jetzt keinen funktionstüchtigen Kampf“): der Kampfort aus einem
# Aufruf, ohne Probe-Schalter. Die Welt hängt einen Knoten mit diesem Skript ein und ruft starte(): Gegnergruppe (Schlüssel wie
# probe.gd FOES), der Held als Toms Heldwerte (oder ein fertiges MARS-Blatt wie tabellen.json „probe“), Söldner wahlweise, Kampfort,
# Tageszeit, Tränke, wahlweise die Beute (Callable, gibt die Ausrüstung eines Siegs als [{gear, name, rarity}] wie Loot.drops,
# Toms skripte/beute.gd; sie steht im Endfeld und in lohn.gear). Am Ende kommt das Signal ende(ergebnis, tp, lohn): ergebnis WON, LOST, FLED (NONE: ohne LP kein Kampf), tp die
# Trefferpunkte je Kämpfer der Gruppe („hero“, „merc“), lohn wie regeln/lohn.gd nach einem Sieg; danach entfernt sich der Knoten.
extends Node

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Kampfort = preload("res://kampf/kampfort.gd")
const Figur = preload("res://kampf/figur.gd")

signal ende(ergebnis: String, tp: Dictionary, lohn: Dictionary)

var kampf: Node
var tabellen: Dictionary


## Die Gegner einer Gruppe (Aufstellung, Namen und Aussehen wie im Probekampf; probe.gd ruft das auch)
static func gegner(foe: String, monsters: Dictionary, dice) -> Array:
	var foes := []
	var lineup: Array = {
		"WOLVES": [["wolf1", Mars.WOLF, Vector2i(0, 0)], ["wolf2", Mars.WOLF, Vector2i(0, 1)], ["wolf3", Mars.WOLF, Vector2i(1, 0)]],
		"GRAK": [["grak", Mars.GRAK, Vector2i(0, 0)]],
		"SPIDER": [["wolf1", Mars.WOLF, Vector2i(0, 0)], ["spider", Mars.SPIDER, Vector2i(1, 0)]],
		"SCOUT": [["gob1", Mars.CALLED, Vector2i(0, 0)], ["scout", Mars.SCOUT, Vector2i(1, 0)]],
		# 348.9: drei Riesenratten im Aussehen, Regeln noch die des Wolfs (Ratte in MARS fehlt noch)
		"RATS": [["wolf1", Mars.WOLF, Vector2i(0, 0)], ["wolf2", Mars.WOLF, Vector2i(0, 1)], ["wolf3", Mars.WOLF, Vector2i(1, 0)]],
		# 348.7: drei Riesenfledermäuse im Aussehen (fledermaus.py), Regeln noch die des Wolfs (Fledermaus in MARS fehlt noch)
		"BATS": [["wolf1", Mars.WOLF, Vector2i(0, 0)], ["wolf2", Mars.WOLF, Vector2i(0, 1)], ["wolf3", Mars.WOLF, Vector2i(1, 0)]],
		# 348.7: Grimmzahn allein vorn, zwei Wölfe seiner Leibwache (Packs.kt guard) hinten an den Seiten; im Aussehen, Regeln
		# noch die des Wolfs (vorn rechts stand ihm der hintere Wolf auf dem Rücken, hinten verschwand er hinter der Wache: Prüfer Runden 2, 3)
		"GRIMM": [[Figur.GRIMM, Mars.WOLF, Vector2i(0, 0)], ["wolf1", Mars.WOLF, Vector2i(1, 0)], ["wolf2", Mars.WOLF, Vector2i(1, 1)]],
		# 348.7: drei Goblins, je eines der Kits (goblin.py), mit den Regeln des Goblins
		"GOBLINS": [["gob1", Mars.CALLED, Vector2i(0, 0)], ["gob2", Mars.CALLED, Vector2i(0, 1)], ["gob3", Mars.CALLED, Vector2i(1, 0)]],
		# 348.7: drei Goblin-Späher, je eines der Kits (goblin.py ART=goblin_archer), mit den Regeln des Spähers
		"SCOUTS": [["gob1", Mars.SCOUT, Vector2i(0, 0)], ["gob2", Mars.SCOUT, Vector2i(0, 1)], ["gob3", Mars.SCOUT, Vector2i(1, 0)]],
		# 348.7: drei Goblin-Schamanen im Aussehen (goblin.py ART=goblin_shaman), Regeln noch die des Goblins (Schamane in MARS fehlt)
		"SHAMANS": [["gob1", Mars.CALLED, Vector2i(0, 0)], ["gob2", Mars.CALLED, Vector2i(0, 1)], ["gob3", Mars.CALLED, Vector2i(1, 0)]],
		# 348.7: drei Kobolde im Aussehen (goblin.py ART=kobold), Regeln noch die des Goblins (Kobold in MARS fehlt)
		"KOBOLDS": [["gob1", Mars.CALLED, Vector2i(0, 0)], ["gob2", Mars.CALLED, Vector2i(0, 1)], ["gob3", Mars.CALLED, Vector2i(1, 0)]],
	}.get(foe, [])
	Figur.ersatz_art = {"RATS": "giant_rat", "BATS": "giant_bat", "SHAMANS": Figur.SHAMAN, "KOBOLDS": Figur.KOBOLD}.get(foe, "")
	# 348.12f eingebaut (Chef 28.10., 11:50: Kaufwolf abgenommen, Archiv 27.10., 21:51: „eigener entfällt“): Wölfe sind der gekaufte
	# Wolf, sobald er gebaut beiliegt (godot-kampf.yml „Modelle bauen“); ERSATZ geht weiter vor
	if foe in ["WOLVES", "GRIMM", "SPIDER", "RUDEL"] and FileAccess.file_exists("res://kampf/daten/kaufwolf-info.json"):
		Figur.ersatz_art = "kaufwolf"
	if foe == "RUDEL":
		return rudel(monsters, dice)
	for e in lineup:
		var m: Dictionary = monsters[e[1]]
		if e[0] == Figur.GRIMM:     # Name aus den Regeln (Monsters.kt dire_wolf)
			m = m.duplicate()
			m.de = "Grimmzahn, der Leitwolf"
			m.en = "Grimfang the Alpha"
		elif foe == "KOBOLDS":     # Name aus den Regeln (Monsters.kt kobold)
			m = m.duplicate()
			m.de = "Kobold"
			m.en = "Kobold"
		elif foe == "RATS":     # Name aus den Regeln (Monsters.kt giant_rat; Helfer Lauf 126: Ratten hießen „Wolf“)
			m = m.duplicate()
			m.de = "Riesenratte"
			m.en = "Giant Rat"
		elif foe == "BATS":     # Name aus den Regeln (Monsters.kt giant_bat)
			m = m.duplicate()
			m.de = "Riesenfledermaus"
			m.en = "Giant Bat"
		elif foe == "SHAMANS":     # Name aus den Regeln (Monsters.kt goblin_shaman)
			m = m.duplicate()
			m.de = "Goblin-Schamane"
			m.en = "Goblin Shaman"
		foes.append(Mars.monster_fighter(e[0], e[2], m, dice.roll_expr(m.hp)))
	return foes


## 399.2a (Chef 28.10., 14:19, Archiv: „Wolf mit 1 bis 2 Jungwölfen“, der Held allein): der Waldkampf wie im alten Spiel
## (Packs.kt cubs): vorn der Wolf, dazu 1–2 Jungwölfe, halb so groß (scale 0,55), Biss 1W3, Angriff −1; neu, weil MARS
## Trefferpunkte braucht: halb so viele wie ein Wolf; sie folgen dem Wolf und fliehen, wenn er fällt (mars.gd follows);
## Erfahrung wie alt über lohn.gd (Leitwolf, je Jungwolf 0,3 dazu)
const JUNGWOLF := {"de": "Jungwolf", "en": "Young wolf", "scale": 0.55, "atk_shift": -1, "dmg": [1, 3, 0], "hp_share": 0.5, "chance": 0.5,
	"flee": ["Mit eingezogenem Schwanz fliehen die Jungwölfe ins Unterholz!", "Tails tucked, the young wolves flee into the undergrowth!"]}

static func rudel(monsters: Dictionary, dice) -> Array:
	var wolf: Dictionary = monsters[Mars.WOLF]
	var foes := [Mars.monster_fighter("wolf1", Vector2i(0, 0), wolf, dice.roll_expr(wolf.hp))]
	var jung: Dictionary = wolf.duplicate(true)
	jung.de = JUNGWOLF.de
	jung.en = JUNGWOLF.en
	jung.scale = JUNGWOLF.scale
	jung.atk = int(wolf.atk) + int(JUNGWOLF.atk_shift)
	jung.dmg = JUNGWOLF.dmg
	jung.xp = 0     # lohn.gd zählt sie als Rudel des Wolfs (xpShare), nicht einzeln
	jung.flee = JUNGWOLF.flee
	jung.chance = JUNGWOLF.chance     # 399.2b (Chef 28.10., 15:32): beißt wie alt nur zu 50 % je Runde (Packs.kt cubs)
	var n: int = dice.roll_expr([1, 2, 0])
	for i in n:
		var f = Mars.monster_fighter("cub%d" % (i + 1), [Vector2i(0, 1), Vector2i(1, 0)][i], jung, maxi(1, int(dice.roll_expr(wolf.hp) * float(JUNGWOLF.hp_share))))
		f.follows = "wolf1"
		foes.append(f)
	return foes


const RETTUNG := {"FIGHTER": ["STR", "CON"], "WIZARD": ["INT", "WIS"], "ROGUE": ["DEX", "INT"], "CLERIC": ["WIS", "CHA"]}     # Battle.savingThrows


## Ersatzwaffe der anderen Art (zum Nahkampf eine Fernwaffe und umgekehrt), wie Skirmish.secondWeapon ohne Gepäck: die erste
## schlichte, die die Klasse führen darf, als Gear-Wörterbuch; null, wenn keine passt
static func ersatzwaffe(h):
	var fern: bool = h.waffe() == null or not bool(h.grundform(h.waffe()["base"])["fern"])
	var schlicht := ["light_crossbow", "shortbow"] if fern else ["shortsword", "dagger", "mace", "quarterstaff"]
	var erlaubt = h.klassendaten()["waffen"]
	for i in schlicht.size():
		var id: String = schlicht[i]
		if not h.lade()["grundformen"].has(id):
			continue
		var d: Dictionary = h.grundform(id)
		if String(d["art"]) == "WEAPON" and bool(d["fern"]) == fern and (erlaubt == null or id in erlaubt):
			return {"uid": -1 - i, "base": id, "rarity": "COMMON", "ilvl": 1, "plus": 0, "rolls": [], "unique": false}
	return null


## Toms Heldwerte als MARS-Blatt, Feld für Feld wie MarsGoldenTest.sheet (Hero.kt); [zweite]: die Ersatzwaffe (ersatzwaffe)
static func blatt(h, zweite = null) -> Dictionary:
	var schild = h.ding("OFF_HAND")
	if schild != null and String(h.grundform(schild["base"])["art"]) != "SHIELD":
		schild = null
	var rk: int = h.rk()
	var rk_zweite := rk
	if zweite != null and bool(h.grundform(zweite["base"])["zweihaendig"]) and schild != null:
		rk_zweite = rk - int(h.grundform(schild["base"])["ruestung"]) - int(schild["plus"])
	var faehig := []
	for f in h.faehigkeiten():
		faehig.append(String(f))
	return {"name": h.name, "race": h.volk, "cls": h.klasse, "level": h.stufe, "dex": h.mod("DEX"), "wis": h.mod("WIS"),
		"ac": rk, "acDrawn": rk_zweite, "crit": h.krit_ab(), "spellAtk": h.zauberangriff(), "spellDc": h.zauber_sg(),
		"sp": h.zp, "skills": faehig, "main": _waffe(h, h.waffe()), "second": _waffe(h, zweite) if zweite != null else null,
		"off": _waffe(h, h.nebenwaffe(), true) if h.nebenwaffe() != null else null,
		"con": h.mod("CON"), "prof": h.uebung(), "saves": RETTUNG.get(h.klasse, []),
		"tenacity": h.standhaft(),
		"hits": {"POISON": h.bonus("POISON_HIT"), "BLEED": h.bonus("BLEED_HIT"), "STUN": h.bonus("STUN_HIT")}}


static func _waffe(h, w, nebenhand := false) -> Dictionary:
	var d: Dictionary = h.grundform(w["base"]) if w != null else {}
	return {"id": String(w["base"]) if w != null else "", "de": String(d.get("de", "")), "en": String(d.get("en", "")),
		"atk": h.angriff_mit(w), "dmg": h.schaden_mit(w, nebenhand), "ranged": bool(d.get("fern", false)),
		"reach": bool(d.get("reichweite", false)), "two": bool(d.get("zweihaendig", false)), "type": String(d.get("schadensart", "BLUDGEONING"))}


## Kampf beginnen: [gegner] wie probe.gd FOES („WOLVES“ …), [held] Heldwerte oder MARS-Blatt (dann [held_tp] dazu), [soeldner]
## ebenso oder null, [ort] Kampfort (heute nur „wald“), [tageszeit] „tag“, „abend“ oder „nacht“, [traenke] Heiltränke im Gepäck.
## false: kein Kampf (Held ohne LP); ende kommt dann gleich mit „NONE“
## [lage]: wie der Held aus der Welt kommt, {"atemlos": bool, "satt": bool, "eroeffnung": "NORMAL" | "AMBUSHED" | "HERO_FIRST",
## "blende": die schwarze Blende vor dem Kampf, 402} (399.2)
func starte(gegner_: String, held, soeldner = null, ort := "wald", tageszeit := "tag", traenke := 2, held_tp := -1, soeldner_tp := -1, seed := -1, beute := Callable(), lage := {}) -> bool:
	tabellen = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	var dice = Wuerfel.new(null if seed < 0 else seed + 1)
	var skills := {}
	for s in tabellen.skills:
		skills[s.id] = s
	var monsters := {}
	for m in tabellen.monsters:
		monsters[m.id] = m
	var party := [_kaempfer("hero", held, held_tp, Vector2i(Mars.FRONT, 0), skills)]
	if soeldner != null:
		var sb := _als_blatt(soeldner)
		var hinten: bool = sb.main.ranged or sb.cls == "WIZARD" or sb.cls == "CLERIC"
		party.append(_kaempfer("merc", soeldner, soeldner_tp, Vector2i(Mars.BACK, 0) if hinten else Vector2i(Mars.FRONT, 1), skills))
	var foes := gegner(gegner_, monsters, dice)
	kampf = Kampfort.new()
	kampf.tageszeit = tageszeit
	kampf.ort = ort
	# Erfahrung für den Lohn: der Held bringt seine mit, ein Blatt steht am Anfang seiner Stufe (wie die Probe, 296.2)
	var xp: int = int(tabellen.xpForLevel[int(held.level)]) if held is Dictionary else int(held.ep)
	if not kampf.setup(party, foes, tabellen, {"potion": traenke}, _fertig, seed, {"xp": xp, "beute": beute, "atemlos": bool(lage.get("atemlos", false)), "satt": bool(lage.get("satt", false)), "eroeffnung": String(lage.get("eroeffnung", "NORMAL")), "blende": bool(lage.get("blende", false))}):
		kampf.free()
		kampf = null
		_fertig.call_deferred("NONE")
		return false
	if gegner_ == "GRIMM":     # Grimmzahn ohne Nummer, die Wölfe 1 und 2 (die Regeln zählen nach Art)
		for i in foes.size():
			foes[i].nr = i
	get_tree().root.add_child.call_deferred(kampf)
	return true


func _als_blatt(x) -> Dictionary:
	return x if x is Dictionary else blatt(x, ersatzwaffe(x))


func _kaempfer(id: String, x, tp: int, platz: Vector2i, skills: Dictionary):
	var b := _als_blatt(x)
	var max_tp: int = tp if x is Dictionary else int(x.max_tp())
	var f = Mars.hero_fighter(id, "PARTY", platz, b, max_tp, b.second, skills)
	if not (x is Dictionary):
		f.hp = clampi(int(x.tp), 0, max_tp)
	return f


func _fertig(ergebnis: String) -> void:
	var tp := {}
	var lohn := {}
	if kampf != null and kampf.mars != null:
		for f in kampf.mars.fighters():
			if f.side == "PARTY":
				tp[f.id] = f.hp
		lohn = kampf.reward
	ende.emit(ergebnis, tp, lohn)
	queue_free()
