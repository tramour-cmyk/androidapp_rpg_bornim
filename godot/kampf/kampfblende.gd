class_name Kampfblende
extends Control
# 402 (Chef 28.10., 22:2x: „Kampfbeginn mit Blende wie alt … Hinterhalt, Erstschlag, normal, Boss länger … für Hinterhalt ein
# besseres Herzklopfen“): die schwarze Blende vor dem Kampf wie alt (24.6, InterludeUi.kt FightVeil und FightVeilBox,
# InterludeClock.kt FIGHT, FIGHT_SHORT, AMBUSH, BOSS, Interlude.fightWords; DESIGN-BLENDE.md 5, 7). Oben ein Satz, wie der Kampf
# beginnt (ohne den Namen des Gegners), darunter der Name groß in mattem Gold (beim Boss größer), beim ersten Kampf gegen diese
# Art und beim Boss immer ein Satz des Gegners; seit 661 im Aufbau der Ortsblende (Name, Zierleiste, Satz, Satz des Gegners). Hinterhalt: schlagartig, die Worte gleich da, dazu drei schwere Herzschläge;
# Erstschlag leise; Boss steht länger. Solange sie steht, warten Worte und Züge des Kampfs, Musik und Klänge (Hush.fight, 319);
# geht sie, kommt der Klang des Kampfbeginns (Game.kt: Hinterhalt „ambush“, sonst „encounter“). Zeiten und Sätze aus core:
# intro.json „kampfblende“ (IntroExport.kt).

signal geht      # das Schwarz beginnt zu weichen: der Kampf darf sich zeigen
signal fertig

const DP := AktionsKnopf.DP
const HERZ := 1.0                         # 402: der Herzschlag so laut wie ein Effekt sein kann (Ambience HEARTBEAT war 0,35)

static var letzter = null                 # FightVeilMemory.last, lastFoe: nie zweimal hintereinander derselbe Satz
static var letzter_gegner = null
static var gesehen := {}                  # Arten, gegen die schon gekämpft wurde: danach kurz (FIGHT_SHORT, „viele Kämpfe bleiben flott“)

var art: Dictionary
var art_name := ""
var hinterhalt := false
var ms := 0.0
var verlassen := -1.0
var lesen := 0.0                          # t63.1, 556: Lesezeit aller Worte (InterludeClock.readMs), Tippen beendet frueher
var tippt := false
var gegangen := false
var worte: Control
var herz: AudioStreamPlayer

static func daten() -> Dictionary: return Zwischenbild.daten().get("kampfblende", {})

## InterludeClock.fightKind; „bereit“ heißt in Godot: gegen diese Art schon einmal gekämpft (alt: die Bilder lagen schon bereit)
static func art_fuer(eroeffnung: String, boss: bool, bereit: bool) -> String:
	if boss: return "BOSS"
	if eroeffnung == "AMBUSHED": return "AMBUSH"
	return "FIGHT_SHORT" if bereit else "FIGHT"

## Interlude.startFor
static func start_fuer(eroeffnung: String, rudel: bool) -> String:
	match eroeffnung:
		"AMBUSHED": return "AMBUSH"
		"HERO_FIRST": return "HERO_FIRST"
	return "PACK" if rudel else "NORMAL"

## Interlude.fightWords: [erster Satz, Satz des Gegners oder null]
static func worte_fuer(eroeffnung: String, rudel: bool, gegner_id: String, boss: bool, voll: bool, zufall: RandomNumberGenerator) -> Array:
	var st := start_fuer(eroeffnung, rudel)
	var start = Ortsblende.waehle(daten().get("eroeffnungen", {}).get(st, []), letzter, zufall)
	var eigen = null
	if boss or (voll and st in ["NORMAL", "PACK"]):
		eigen = Ortsblende.waehle(daten().get("gegner", {}).get(gegner_id, []), letzter_gegner, zufall)
	return [start, eigen]

## Wer vorn steht, ob ein Rudel, wie er heißt (ohne Nummer). 594 (Chef 05.11., Build 266: im Probekampf „Spinne“ Wolfstext in der
## Blende): wie alt SkirmishScreen der Boss, sonst der mit den meisten EP (bei Gleichstand der erste); Rudel nur, wenn mehr als einer
## dieser Art kämpft (Riesenspinne mit Wolf: Spinnensatz, einzeln)
static func lage(mars) -> Dictionary:
	var feinde: Array = mars.fighters().filter(func(f): return f.side == "FOES")
	if feinde.is_empty(): return {}
	var vorn = feinde[0]
	var wert := -1
	for f in feinde:
		var w := (1000000 if bool(f.monster.get("boss", false)) else 0) + int(f.monster.get("xp", 0))
		if w > wert: vorn = f; wert = w
	var gleich := feinde.filter(func(f): return String(f.monster.id) == String(vorn.monster.id)).size()
	return {"id": String(vorn.monster.id), "name": String([vorn.monster.de, vorn.monster.en][mars.lang]), "boss": bool(vorn.monster.get("boss", false)),
		"rudel": gleich > 1}

func _init(eroeffnung: String, l: Dictionary, zufall: RandomNumberGenerator) -> void:
	hinterhalt = eroeffnung == "AMBUSHED"
	var boss := bool(l.get("boss", false))
	art_name = art_fuer(eroeffnung, boss, gesehen.has(l.get("id", "")))
	gesehen[l.get("id", "")] = true
	art = daten().get("arten", {}).get(art_name, {"ein_ms": 200, "mind_ms": 650, "aus_ms": 200, "schleier_aus_ms": 350})
	var w := worte_fuer(eroeffnung, bool(l.get("rudel", false)), String(l.get("id", "")), boss, art_name != "FIGHT_SHORT", zufall)
	letzter = w[0]
	if w[1] != null: letzter_gegner = w[1]
	# FightVeil: Zeichen des ersten Satzes, des Namens und des Satzes des Gegners (InterludeUi.kt 394)
	lesen = Ortsblende.lese_ms((Sprache.t(w[0]).length() if w[0] != null else 0) + String(l.get("name", "")).length() \
		+ (Sprache.t(w[1]).length() if w[1] != null else 0), daten())
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	# derselbe Grund wie zwischen den Orten: reines Schwarz (556, Chef 04.11., 07:52 „Bitte klassische schwarz“)
	add_child(Ortsblende.schwarz())
	var mitte := CenterContainer.new()
	mitte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mitte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(mitte)
	# 661: derselbe Aufbau wie zwischen den Orten (Ortsblende.worte_spalte): Name des Gegners gesperrt, Zierleiste, Satz zur
	# Eroeffnung, darunter der Satz des Gegners; der Hinterhalt mit gebrochener Zierleiste, der Boss gleich gross (nur laenger)
	worte = Ortsblende.worte_spalte(String(l.get("name", "")), Sprache.t(w[0]) if w[0] != null else "",
		Sprache.t(w[1]) if w[1] != null else "", hinterhalt)
	mitte.add_child(worte)
	_stelle()

func _ready() -> void:
	worte.custom_minimum_size.x = get_viewport_rect().size.x - 2 * 36 * DP
	var k := get_node_or_null("/root/Klang")
	if k != null:
		k.verhuelle(true)   # Hush.fight: Musik und Klänge warten, bis sie gegangen ist
		if hinterhalt and k.effekte_an:   # 402: der Herzschlag geht durch die Blende, die anderen Klänge nicht
			var takes: Array = k.liste.get("sfx", []).filter(func(n): return String(n).begins_with("heartbeat_strong_"))
			if not takes.is_empty():
				herz = AudioStreamPlayer.new()
				herz.bus = "Effekte"
				herz.stream = k._strom("sfx/" + String(takes[randi() % takes.size()]))
				herz.volume_db = linear_to_db(HERZ)
				add_child(herz)
				herz.play()
	_stelle()

# 619 (Chef 07.11., 268.18: „Aktionsknopf drückt die Blende gleich mit weg“): wie alt (InterludeUi detectTapGestures) zaehlt nur ein
# ganzer Tipp auf der Blende, Druck und Loslassen; ein Finger, der schon unten war, als sie kam, beendet sie nicht
var unten := false

func _gui_input(e: InputEvent) -> void:
	if not (e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT) and not e is InputEventScreenTouch: return
	if e.pressed: unten = true
	elif unten: tippt = true
	accept_event()

## InterludeClock.at, alles gezeichnet: [Schleier, Worte, vorbei]; der Hinterhalt hat die Worte sofort (ein_ms 0)
func bei(t: float) -> Array:
	var ein := float(art["ein_ms"]); var aus := float(art["aus_ms"]); var weg := float(art["schleier_aus_ms"])
	if verlassen < 0.0 and (t >= maxf(float(art["mind_ms"]), lesen) or tippt): verlassen = t
	var geht := 1.0 - clampf((t - verlassen) / maxf(1.0, aus), 0.0, 1.0) if verlassen >= 0.0 else 1.0
	var w := Ortsblende.glatt(minf(1.0 if ein == 0.0 else clampf(t / ein, 0.0, 1.0), geht))
	var s := 1.0 - Ortsblende.glatt(clampf((t - verlassen - aus * 2.0 / 3.0) / weg, 0.0, 1.0)) if verlassen >= 0.0 else 1.0
	return [s, w, s <= 0.0]

func _process(dt: float) -> void:
	ms += dt * 1000.0
	if _stelle():
		set_process(false)
		fertig.emit()
		queue_free()

func _stelle() -> bool:
	var b := bei(ms)
	modulate.a = b[0]
	worte.modulate.a = b[1]
	# der Kampf zeigt sich, während das Schwarz weicht; dann kommen Musik und der Klang des Kampfbeginns
	if b[0] < 1.0 and not gegangen and is_inside_tree():
		gegangen = true
		var k := get_node_or_null("/root/Klang")
		if k != null:
			k.verhuelle(false)
			k.effekt("ambush" if hinterhalt else "encounter")
		geht.emit()
	if b[0] < 0.5: mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b[2]
