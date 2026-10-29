class_name Kampfblende
extends Control
# 402 (Chef 28.10., 22:2x: „Kampfbeginn mit Blende wie alt … Hinterhalt, Erstschlag, normal, Boss länger … für Hinterhalt ein
# besseres Herzklopfen“): die schwarze Blende vor dem Kampf wie alt (24.6, InterludeUi.kt FightVeil und FightVeilBox,
# InterludeClock.kt FIGHT, FIGHT_SHORT, AMBUSH, BOSS, Interlude.fightWords; DESIGN-BLENDE.md 5, 7). Oben ein Satz, wie der Kampf
# beginnt (ohne den Namen des Gegners), darunter der Name groß in mattem Gold (beim Boss größer), beim ersten Kampf gegen diese
# Art und beim Boss immer ein Satz des Gegners. Hinterhalt: schlagartig, die Worte gleich da, dazu drei schwere Herzschläge;
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

## Wer vorn steht (der Boss, sonst der erste Gegner), ob ein Rudel, wie er heißt (ohne Nummer)
static func lage(mars) -> Dictionary:
	var feinde: Array = mars.fighters().filter(func(f): return f.side == "FOES")
	if feinde.is_empty(): return {}
	var vorn = feinde[0]
	for f in feinde:
		if bool(f.monster.get("boss", false)): vorn = f
	return {"id": String(vorn.monster.id), "name": String([vorn.monster.de, vorn.monster.en][mars.lang]), "boss": bool(vorn.monster.get("boss", false)),
		"rudel": feinde.size() > 1}

func _init(eroeffnung: String, l: Dictionary, zufall: RandomNumberGenerator) -> void:
	hinterhalt = eroeffnung == "AMBUSHED"
	var boss := bool(l.get("boss", false))
	art_name = art_fuer(eroeffnung, boss, gesehen.has(l.get("id", "")))
	gesehen[l.get("id", "")] = true
	art = daten().get("arten", {}).get(art_name, {"ein_ms": 200, "mind_ms": 650, "aus_ms": 200, "schleier_aus_ms": 350})
	var w := worte_fuer(eroeffnung, bool(l.get("rudel", false)), String(l.get("id", "")), boss, art_name != "FIGHT_SHORT", zufall)
	letzter = w[0]
	if w[1] != null: letzter_gegner = w[1]
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	# derselbe Grund wie zwischen den Orten: Schwarz mit einem Hauch Vignette (FightVeilBox)
	var grund := TextureRect.new()
	grund.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grund.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	grund.stretch_mode = TextureRect.STRETCH_SCALE
	grund.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	g.colors = PackedColorArray([Ortsblende.KERN, Color("0a0807"), Color.BLACK])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.46)
	t.fill_to = Vector2(0.5, 0.46 + 0.62)
	t.width = 64; t.height = 128
	grund.texture = t
	add_child(grund)
	var mitte := CenterContainer.new()
	mitte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mitte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(mitte)
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_theme_constant_override("separation", 0)
	mitte.add_child(v)
	worte = v
	if w[0] != null:
		v.add_child(_zeile(Sprache.t(w[0]), 19, Ortsblende.TEXT, 0.6, 28))
	v.add_child(Erschaffung.luecke(18))
	var r := ColorRect.new()
	r.color = Ortsblende.LINIE
	r.custom_minimum_size = Vector2(44, 1) * DP
	r.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(r)
	v.add_child(Erschaffung.luecke(16))
	v.add_child(_zeile(String(l.get("name", "")).to_upper(), 30 if boss else 24, Ortsblende.NAME, 5.0, 0))
	if w[1] != null:
		v.add_child(Erschaffung.luecke(16))
		v.add_child(_zeile(Sprache.t(w[1]), 16, Color(Ortsblende.TEXT, 0.8), 0.4, 24))
	_stelle()

func _zeile(text: String, sp: float, farbe: Color, sperrung: float, zeile_sp: float) -> Label:
	var l := Stil.zeile(text, sp, farbe, sperrung)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if zeile_sp > 0.0: l.add_theme_constant_override("line_spacing", int((zeile_sp - sp * 1.2) * Stil.SP))
	return l

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

func _gui_input(e: InputEvent) -> void:
	if (e is InputEventMouseButton and e.pressed) or (e is InputEventScreenTouch and e.pressed):
		tippt = true
		accept_event()

## InterludeClock.at, alles gezeichnet: [Schleier, Worte, vorbei]; der Hinterhalt hat die Worte sofort (ein_ms 0)
func bei(t: float) -> Array:
	var ein := float(art["ein_ms"]); var aus := float(art["aus_ms"]); var weg := float(art["schleier_aus_ms"])
	if verlassen < 0.0 and (t >= float(art["mind_ms"]) or tippt): verlassen = t
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
