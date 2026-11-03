class_name Blutspur
extends Node3D
# 416.6 (Jerry; Chef 03.11., 07:31: „Blutspuren in der Welt bitte mit einplanen“): Blut, wo ein Gegner fiel, wie alt
# (WorldScreen.drawTracks Kind.BLOOD, Game.kt endBattle): eine Lache aus 4–6 sich überlagernden Flecken, länger in eine Richtung,
# rundum 5–8 Spritzer; frisch rot, in den ersten zwei Fünfteln ihres Lebens zu dunklem Braun getrocknet, nach sechs Minuten fort
# (die letzten zwei Fünftel verblassend; Spuren.BLOOD_MS, FADE_FROM). Liegt flach auf dem Boden (y = 0 wie Karte.kachel_pos),
# wirft keinen Schatten. Die Spuren leben nur im Speicher (spuren, über Kartenwechsel hinweg), nie im Spielstand.

const Spuren = preload("res://regeln/spuren.gd")

## alle Spuren des Spiels (Game.tracks), über Kartenwechsel hinweg
static var spuren := Spuren.new()

const FRISCH := Color(0x8E1A12FF)
const TROCKEN := Color(0x5A1C14FF)
## so viele Bildpunkte je Feld im Bild der Lache (alt: ein Feld WorldArt.T = 16 Punkte, Spritzer bis 18 Punkte vom Mittelpunkt)
const PUNKTE := 8
const ALT_T := 16.0
## die Lache reicht mit den Spritzern bis gut ein Feld weit vom Mittelpunkt (18/16), das Bild deckt ±1,25 Felder
const HALB := 1.25
const HOEHE := 0.012

var karte_id := ""
## 416.6 Staub (Chef 03.11., 09:21: „die Staubwölkchen beim Laufen … Schau mal in der Kotlin-Version nach. Hat ja schon Atmosphäre
## gemacht“): der Held und seine Karte (spiel.gd), damit seine Füße Spuren lassen (Tracks.walked); Staub je Doppelschritt beim Rennen
## auf trockenem Weg oder Höhlenboden, drei Wölkchen, die in 0,9 s aufgehen und vergehen (WorldScreen.drawTracks Kind.DUST)
var held: Node3D = null
var karte = null
const STAUB := Color(0xE2D2AEFF)
var _staub := {}     # Mark -> Node3D (drei Wölkchen)
static var _wolke: ImageTexture = null
## Mark -> MeshInstance3D
var _netze := {}
var _uhr := 0.0

func _init(id := "") -> void:
	name = "Blutspur"
	karte_id = id

## Blut, wo ein Gegner fiel: auf [kachel] der Karte (Mitte des Felds), Form aus [seed] (alt: uid des Streuners)
static func blut(id: String, kachel: Vector2i, seed: int, jetzt := -1) -> void:
	spuren.blood(id, kachel.x + 0.5, kachel.y + 0.5, Time.get_ticks_msec() if jetzt < 0 else jetzt, seed)

## Blut ohne Streuner (Kampf auf dem Weg): das Feld vor dem Helden, wie Game.kt nach [blick]
static func vor(kachel: Vector2i, blick: String) -> Vector2i:
	match blick:
		"UP": return kachel + Vector2i(0, -1)
		"LEFT": return kachel + Vector2i(-1, 0)
		"RIGHT": return kachel + Vector2i(1, 0)
	return kachel + Vector2i(0, 1)

func _process(dt: float) -> void:
	var jetzt := Time.get_ticks_msec()
	_fuesse(jetzt)
	staub(jetzt)
	_uhr += dt
	if _uhr < 0.25: return
	_uhr = 0.0
	stelle(jetzt)

## die Füße des Helden: wo er geht oder rennt, auf welchem Boden (Kachelname wie core Tile), draußen oder drinnen
func _fuesse(jetzt: int) -> void:
	if held == null or not is_instance_valid(held) or karte == null:
		return
	var anim = held.get("anim")
	var a: String = anim.current_animation if anim != null else ""
	if not (a.begins_with("Gehen") or a.begins_with("Rennen")):
		return
	var p: Vector3 = held.position
	var boden := String(karte.kacheln.get(karte.zeichen(karte.pos_kachel(p)), {}).get("name", ""))
	var draussen := String(karte.daten.get("art", "")) not in ["INTERIOR", "CAVE"]
	spuren.walked(karte_id, p.x / Karte.TS, p.z / Karte.TS, rad_to_deg(held.rotation.y), boden, draussen, a.begins_with("Rennen"), jetzt)

## 416.6: der Staub dieser Karte zur Zeit [jetzt]: je Spur drei Wölkchen, die auseinandergehen, wachsen, steigen und verblassen
## (alt je Wölkchen Abstand 1,5 + 3·Alter, Halbmesser 2 + 5·Alter Punkte bei 16 Punkten je Feld, Deckung 0,55·(1 − Alter))
func staub(jetzt: int) -> void:
	var da := {}
	if Spuren.draft:
		for m in spuren.on(karte_id, jetzt):
			if m.kind != Spuren.DUST: continue
			da[m] = true
			if not _staub.has(m): _staub[m] = _wolken(m)
			var age: float = m.age(jetzt)
			var n: Node3D = _staub[m]
			for i in n.get_child_count():
				var w := n.get_child(i) as MeshInstance3D
				var ang: float = w.get_meta("ang")
				var d := (1.5 + age * 3.0) / ALT_T * Karte.TS
				var r := (2.0 + age * 5.0 + float(w.get_meta("r"))) / ALT_T * Karte.TS
				w.position = Vector3(cos(ang) * d, 0.08 + r * 0.6 + age * 0.15, sin(ang) * d)
				w.scale = Vector3.ONE * (2.0 * r)
				var f := STAUB
				f.a = 0.55 * (1.0 - age)
				(w.material_override as StandardMaterial3D).albedo_color = f
	for m in _staub.keys():
		if not da.has(m):
			_staub[m].queue_free()
			_staub.erase(m)

func _wolken(m) -> Node3D:
	var n := Node3D.new()
	n.position = Vector3(m.x * Karte.TS, 0.0, m.y * Karte.TS)
	var rnd := RandomNumberGenerator.new()
	rnd.seed = m.seed
	if _wolke == null:
		_wolke = ImageTexture.create_from_image(wolke_bild())
	for i in 3:
		var w := MeshInstance3D.new()
		var q := QuadMesh.new()
		q.size = Vector2.ONE
		w.mesh = q
		w.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		w.set_meta("ang", rnd.randf() * TAU)
		w.set_meta("r", rnd.randf() * 1.5)
		var mat := StandardMaterial3D.new()
		mat.albedo_texture = _wolke
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		mat.roughness = 1.0
		mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
		w.material_override = mat
		n.add_child(w)
	add_child(n)
	return n

## ein weiches Wölkchen: weiß, Deckung zum Rand hin weich abnehmend (Farbe aus dem Stoff)
static func wolke_bild() -> Image:
	var n := 32
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	for y in n:
		for x in n:
			var e := Vector2(x + 0.5 - n * 0.5, y + 0.5 - n * 0.5).length() / (n * 0.5)
			img.set_pixel(x, y, Color(1, 1, 1, clampf(1.0 - e, 0.0, 1.0) ** 1.5))
	img.generate_mipmaps()
	return img

func staub_anzahl() -> int:
	return _staub.size()

## zeigt die Spuren dieser Karte zur Zeit [jetzt] (ms): neue anlegen, Farbe und Deckung nachführen, vergangene entfernen
func stelle(jetzt: int) -> void:
	var da := {}
	if Spuren.draft:
		for m in spuren.on(karte_id, jetzt):
			if m.kind != Spuren.BLOOD: continue
			da[m] = true
			if not _netze.has(m): _netze[m] = _lache(m)
			var a: float = m.alpha(jetzt)
			var trocken := clampf(m.age(jetzt) / 0.4, 0.0, 1.0)
			var f := FRISCH.lerp(TROCKEN, trocken)
			f.a = 0.85 * a
			var mi: MeshInstance3D = _netze[m]
			(mi.material_override as StandardMaterial3D).albedo_color = f
			mi.visible = a > 0.01
	for m in _netze.keys():
		if not da.has(m):
			_netze[m].queue_free()
			_netze.erase(m)

func anzahl() -> int:
	return _netze.size()

func _lache(m) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2.ONE * (2.0 * HALB * Karte.TS)
	mi.mesh = pm
	mi.position = Vector3(m.x * Karte.TS, HOEHE, m.y * Karte.TS)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = ImageTexture.create_from_image(bild(m.seed))
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.roughness = 0.35   # feucht glänzend; Licht und Nacht wie der Boden
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	mi.material_override = mat
	add_child(mi)
	return mi

## das Bild der Lache: weiß, Deckung aus den Flecken (Farbe kommt aus dem Stoff); Mitte = Mittelpunkt des Felds
static func bild(seed: int) -> Image:
	var n := int(2.0 * HALB * PUNKTE * ALT_T / 4.0)   # 4 alte Punkte je Bildpunkt: 80 × 80
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 0))
	var s := float(n) / (2.0 * HALB * ALT_T)   # Bildpunkte je alter Punkt
	var c := Vector2(n, n) * 0.5
	var rnd := RandomNumberGenerator.new()
	rnd.seed = seed
	# die Lache: einige sich überlagernde Flecken, länger in eine Richtung
	var lean := rnd.randf() * TAU
	for i in 4 + rnd.randi_range(0, 2):
		var d := rnd.randf() * 6.0
		var w := 6.0 + rnd.randf() * 6.0
		var o := c + Vector2(cos(lean) * d * (1 if i % 2 == 0 else -1), sin(lean) * d * 0.7) * s
		_oval(img, o, w * s * 0.5, w * (0.55 + rnd.randf() * 0.3) * s * 0.5)
	# die Spritzer rundum
	for i in 5 + rnd.randi_range(0, 3):
		var ang := rnd.randf() * TAU
		var d := 9.0 + rnd.randf() * 9.0
		var r := (1.2 + rnd.randf() * 1.6) * s * 0.5
		_oval(img, c + Vector2(cos(ang), sin(ang)) * d * s, maxf(r, 0.8), maxf(r, 0.8))
	img.generate_mipmaps()
	return img

## gefüllte Ellipse mit weichem Rand (ein Bildpunkt), Deckung addiert sich bis 1
static func _oval(img: Image, m: Vector2, rx: float, ry: float) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for y in range(maxi(0, floori(m.y - ry - 1)), mini(h, ceili(m.y + ry + 2))):
		for x in range(maxi(0, floori(m.x - rx - 1)), mini(w, ceili(m.x + rx + 2))):
			var dx := (x + 0.5 - m.x) / maxf(rx, 0.01)
			var dy := (y + 0.5 - m.y) / maxf(ry, 0.01)
			var e := sqrt(dx * dx + dy * dy)
			var k := clampf((1.0 - e) * minf(rx, ry) + 0.5, 0.0, 1.0)
			if k <= 0.0: continue
			var alt := img.get_pixel(x, y)
			img.set_pixel(x, y, Color(1, 1, 1, minf(1.0, alt.a + k)))
