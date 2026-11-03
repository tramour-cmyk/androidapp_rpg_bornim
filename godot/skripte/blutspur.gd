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
	_uhr += dt
	if _uhr < 0.25: return
	_uhr = 0.0
	stelle(Time.get_ticks_msec())

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
