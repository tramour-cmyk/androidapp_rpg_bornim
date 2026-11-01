class_name Zwischenbild
extends Control
# 399.1 Intro wie alt (69, IntroScreen.kt ReelScreen, Intro.kt Reel, DESIGN-STIL.md „Zwischensequenzen“): Standbilder mit weichen
# Ueberblendungen, je ein Satz im Kasten darunter, das letzte Bild schwarz; ein Tippen fragt nur, ob uebersprungen wird (104),
# die Szene laeuft derweil weiter. Ueber Bild 3 der Fackelzug (IntroLife.kt, IntroScreen.kt squareLife), darunter Wind, Fluss,
# Grillen, unter dem schwarzen Bild Glocke und Rufe (IntroSoundUi.kt, IntroSound.kt); die Titelmusik leise, mit dem schwarzen
# Bild voll (Music.kt INTRO_LEVEL). Zeiten, Saetze und der Zug aus core: daten/intro.json (IntroExport.kt), die Bilder aus
# app/src/main/assets/intro als .bild (godot.yml). Die Tempelszene (68) laeuft spaeter ueber dieselbe Uhr („tempel“).

signal fertig

const DATEN := "res://daten/intro.json"
const BILDER := "res://daten/intro/"
const DP := AktionsKnopf.DP
const WARM := Color("ffc060")
const WARM_TIEF := Color("e07a28")
const BERNSTEIN := Color("b07a40")
const FLAMME := [Color("e06a20"), Color("ffb040"), Color("fff0b0")]
const WELLE := Color(0x0a / 255.0, 0x0e / 255.0, 0x18 / 255.0, 0x99 / 255.0)
const SCHLEIFEN := ["wind", "river", "alarm_bell"]   # IntroSoundUi: Wind, Fluss, Glocke
const AUS_MS := 600.0                                # SfxPlayer.fadeOut: die Schleifen klingen aus, statt abzubrechen

static var _daten := {}

var art := "intro"
var klang: Node                                      # Autoload Klang oder null (Tests)
var uhr: Dictionary
var saetze: Array
var schwarz := -1
var ms := 0.0
var vorbei := false
var fragt: Control
var bilder := {}                                     # Nummer -> Texture2D
var zug: Texture2D
var vorn: Texture2D
var leben: Dictionary
var unter_bild: TextureRect
var ober_bild: TextureRect
var unter_leben: Control
var ober_leben: Control
var satz: Label
var satz_kasten: PanelContainer
var inhalt: VBoxContainer
var zirpen: Array = []
var rufe: Array = []
var pegel := {}                                      # Schleife -> zuletzt gestellt

static func daten() -> Dictionary:
	if _daten.is_empty() and FileAccess.file_exists(DATEN):
		var j = JSON.parse_string(FileAccess.get_file_as_string(DATEN))
		if j is Dictionary: _daten = j
	return _daten

static func da() -> bool: return not daten().is_empty()

func _init(art_ := "intro", klang_: Node = null) -> void:
	art = art_
	klang = klang_

func _ready() -> void:
	var d := daten()
	uhr = d.get("uhr", {})
	saetze = d.get(art, {}).get("saetze", [])
	schwarz = int(d.get(art, {}).get("schwarz", -1))
	if art == "intro": leben = d.get("leben", {})
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var grund := ColorRect.new()
	grund.color = Color.BLACK
	grund.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grund.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(grund)
	var mitte := CenterContainer.new()
	mitte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mitte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(mitte)
	inhalt = VBoxContainer.new()
	inhalt.add_theme_constant_override("separation", 0)
	inhalt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mitte.add_child(inhalt)
	var breite := get_viewport_rect().size.x
	# das Bild: 1080 x 1200, so breit, wie der Schirm erlaubt
	var rahmen := Control.new()
	rahmen.custom_minimum_size = Vector2(breite, breite / 0.9)
	rahmen.clip_contents = true
	rahmen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inhalt.add_child(rahmen)
	unter_bild = _bildflaeche(rahmen)
	unter_leben = _lebensflaeche(rahmen)
	ober_bild = _bildflaeche(rahmen)
	ober_leben = _lebensflaeche(rahmen)
	inhalt.add_child(Erschaffung.luecke(14))
	# der Satz im Kasten: schwarz, duenner Goldrand, die Serife der schwarzen Schirme (19 sp, Zeile 27 sp, Sperrung 0,4 sp)
	var rand := MarginContainer.new()
	rand.add_theme_constant_override("margin_left", int(16 * DP))
	rand.add_theme_constant_override("margin_right", int(16 * DP))
	rand.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inhalt.add_child(rand)
	satz_kasten = PanelContainer.new()
	var s := Stil.kasten(Color.BLACK, Stil.RIM, 1.0)
	s.content_margin_left = 18 * DP; s.content_margin_right = 18 * DP
	s.content_margin_top = 14 * DP; s.content_margin_bottom = 14 * DP
	satz_kasten.add_theme_stylebox_override("panel", s)
	satz_kasten.custom_minimum_size.y = 124 * DP
	satz_kasten.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rand.add_child(satz_kasten)
	satz = Stil.zeile("", 19, Stil.TEXT, 0.4)
	satz.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	satz.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	satz.add_theme_constant_override("line_spacing", int((27 - 19 * 1.2) * Stil.SP))
	satz_kasten.add_child(satz)
	_lade_bilder()
	if art == "intro": _plane_klang()
	_klang("spiele_szene", ["TITLE"])
	_musik(float(daten().get("klang", {}).get("musik", 0.4)))
	_zeige()

func _bildflaeche(rahmen: Control) -> TextureRect:
	var t := TextureRect.new()
	t.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rahmen.add_child(t)
	return t

func _lebensflaeche(rahmen: Control) -> Control:
	var c := Control.new()
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# das Licht der Fackeln auf der Strasse kommt zum gemalten Boden hinzu (BlendMode.Plus), alles andere liegt darueber
	var licht := Control.new()
	licht.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	licht.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	licht.material = m
	licht.name = "Licht"
	c.add_child(licht)
	var rest := Control.new()
	rest.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rest.name = "Rest"
	c.add_child(rest)
	licht.draw.connect(func(): _male_licht(licht, int(c.get_meta("bild", -1))))
	rest.draw.connect(func(): _male_zug(rest, int(c.get_meta("bild", -1))))
	return c

static func _lade(pfad: String) -> Texture2D:
	if not FileAccess.file_exists(pfad): return null
	var img := Image.new()
	var b := FileAccess.get_file_as_bytes(pfad)
	var ok := img.load_png_from_buffer(b) if b.size() > 4 and b[0] == 0x89 and b[1] == 0x50 else img.load_jpg_from_buffer(b)   # PNG oder JPEG
	return ImageTexture.create_from_image(img) if ok == OK else null

func _lade_bilder() -> void:
	var vors := "intro_" if art == "intro" else "tempel_"
	for i in saetze.size():
		if i != schwarz: bilder[i] = _lade(BILDER + "%s%d.bild" % [vors, i + 1])
	if art == "intro" and not leben.is_empty():
		var n := int(leben.get("bild", 2)) + 1
		zug = _lade(BILDER + "intro_%d_zug.bild" % n)
		vorn = _lade(BILDER + "intro_%d_vorn.bild" % n)

# ---------------------------------------------------------------- Uhr (Reel.at)

# was der Schirm [t] ms nach dem Start zeigt: Bild, darunter das vorige (oder -1), Mischung, Satz, ausgeblendet, vorbei
func bild_bei(t: float) -> Dictionary:
	var step := float(uhr.get("schritt_ms", 7200)); var fade := float(uhr.get("blende_ms", 1400))
	var ende := float(uhr.get("ende_ms", 1200))
	var n := saetze.size()
	var last := n - 1
	t = maxf(t, 0.0)
	if t >= n * step + ende: return {"bild": last, "unter": -1, "mix": 1.0, "text": 0.0, "weg": 1.0, "vorbei": true}
	if t >= n * step: return {"bild": last, "unter": -1, "mix": 1.0, "text": 0.0, "weg": clampf((t - n * step) / ende, 0.0, 1.0), "vorbei": false}
	var i := int(t / step)
	var u := t - i * step
	var mix := clampf(u / fade, 0.0, 1.0)
	mix = mix * mix * (3.0 - 2.0 * mix)
	var ein := clampf((u - fade) / float(uhr.get("text_ein_ms", 700)), 0.0, 1.0)
	var aus := clampf((step - u) / float(uhr.get("text_aus_ms", 500)), 0.0, 1.0)
	return {"bild": i, "unter": i - 1 if i > 0 and mix < 1.0 else -1, "mix": mix, "text": minf(ein, aus), "weg": 0.0, "vorbei": false}

func _process(dt: float) -> void:
	if vorbei: return
	ms += dt * 1000.0
	_zeige()
	if art == "intro": _klang_schritt()
	if bild_bei(ms)["vorbei"]: beende()

func _zeige() -> void:
	var f := bild_bei(ms)
	inhalt.modulate.a = 1.0 - float(f["weg"])
	_stelle(unter_bild, unter_leben, int(f["unter"]), 1.0)
	_stelle(ober_bild, ober_leben, int(f["bild"]), float(f["mix"]))
	satz.text = Sprache.t(saetze[int(f["bild"])]) if not saetze.is_empty() else ""
	satz_kasten.modulate.a = float(f["text"])

func _stelle(flaeche: TextureRect, l: Control, i: int, a: float) -> void:
	flaeche.visible = i >= 0
	l.visible = i >= 0
	if i < 0: return
	flaeche.texture = bilder.get(i) if i != schwarz else _dunkel()
	flaeche.modulate.a = a
	l.modulate.a = a
	l.set_meta("bild", i)
	for c in l.get_children(): c.queue_redraw()

# das schwarze Bild: eine weiche dunkle Vignette, damit es nicht wie ein leerer Schirm aussieht
static var _vignette: Texture2D
static func _dunkel() -> Texture2D:
	if _vignette == null:
		var g := Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
		g.colors = PackedColorArray([Color("0c0a09"), Color("050404"), Color.BLACK])
		var t := GradientTexture2D.new()
		t.gradient = g
		t.fill = GradientTexture2D.FILL_RADIAL
		t.fill_from = Vector2(0.5, 0.5)
		t.fill_to = Vector2(0.5, 1.1)   # Radius 0,6 der Hoehe (die groessere Seite)
		t.width = 108; t.height = 120
		_vignette = t
	return _vignette

# ---------------------------------------------------------------- Fackelzug ueber Bild 3 (IntroScreen.kt squareLife)

# IntroLife.flicker: der Atem einer Flamme, etwa 0,8 bis 1,2, nie im Takt einer anderen
static func flackern(seed: int, t_ms: float) -> float:
	var t := t_ms / 1000.0
	return 1.0 + 0.12 * sin(t * 9.3 + seed * 1.7) + 0.06 * sin(t * 17.9 + seed * 4.1) + 0.03 * sin(t * 31.3 + seed * 2.3)

# die Traeger [u] ms in das Bild: je Traeger die Werte aus intro.json, zwischen zwei Takten gemischt
func zug_bei(u: float) -> Array:
	var bahn: Array = leben.get("bahn", [])
	if bahn.is_empty(): return []
	var takt := float(leben.get("takt_ms", 40))
	var k := clampf(u / takt, 0.0, bahn.size() - 1.0)
	var a: Array = bahn[int(k)]
	var b: Array = bahn[mini(int(k) + 1, bahn.size() - 1)]
	var f := k - int(k)
	var aus := []
	for i in a.size():
		var w := []
		for j in a[i].size(): w.append(lerpf(float(a[i][j]), float(b[i][j]), f) if j != 3 else float(a[i][j]))
		aus.append(w)
	return aus

func _massstab(c: Control) -> float: return c.size.x / float(leben.get("w", 1080))

func _male_licht(c: Control, i: int) -> void:
	if art != "intro" or i != int(leben.get("bild", 2)) or leben.is_empty(): return
	var u := ms - i * float(uhr.get("schritt_ms", 7200))
	var fackel: Array = leben.get("fackel", [])
	var zg := zug_bei(u)
	var s := _massstab(c)
	for j in zg.size():
		var p: Array = zg[j]
		if not fackel[j] or p[3] > 0.5: continue
		var a := 0.3 * flackern(j, ms)
		var r: float = p[9]
		c.draw_set_transform(Vector2(p[7], p[8]) * s, 0.0, Vector2(s, s * 0.3))
		c.draw_texture_rect(_schein(0.45, 0.4), Rect2(-r, -r, 2 * r, 2 * r), false, Color(BERNSTEIN, a))
	c.draw_set_transform(Vector2.ZERO)

func _male_zug(c: Control, i: int) -> void:
	if art != "intro" or i != int(leben.get("bild", 2)) or leben.is_empty(): return
	var u := ms - i * float(uhr.get("schritt_ms", 7200))
	var fackel: Array = leben.get("fackel", [])
	var zg := zug_bei(u)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * _massstab(c))
	# die Fackeln in der Pfuetze als warme, zitternde Streifen, von Wellen gebrochen
	var y0 := float(leben.get("pfuetze_y0", 0)); var y1 := float(leben.get("pfuetze_y1", 0))
	var rand: Array = leben.get("pfuetze", [])
	for j in zg.size():
		var p: Array = zg[j]
		if not fackel[j] or p[3] > 0.5: continue
		var x: float = p[10] + 1.5 * sin(ms / 1000.0 * 5.0 + j)
		var spanne := _pfuetze_bei(rand, x)
		if spanne.is_empty(): continue
		var fl := flackern(j, ms)
		var oben := maxf(y0, spanne[0]); var unten := minf(y1, spanne[1])
		if unten > oben:
			var cols := PackedColorArray(); var pts := PackedVector2Array()
			var a0 := Color(WARM, minf(0.7 * fl, 1.0)); var a1 := Color(WARM_TIEF, 0.0)
			var t0 := (oben - y0) / (y1 - y0); var t1 := (unten - y0) / (y1 - y0)
			pts = PackedVector2Array([Vector2(x - 3, oben), Vector2(x + 3, oben), Vector2(x + 3, unten), Vector2(x - 3, unten)])
			cols = PackedColorArray([a0.lerp(a1, t0), a0.lerp(a1, t0), a0.lerp(a1, t1), a0.lerp(a1, t1)])
			c.draw_polygon(pts, cols)
		_glimmen(c, x, y0 + 6, 16.0, WARM_TIEF, 0.3 * fl)
		for q in range(1, 6):
			var yy := y0 + (y1 - y0) * q / 6.0
			if yy > spanne[0] and yy < spanne[1]: c.draw_line(Vector2(x - 5, yy), Vector2(x + 5, yy + 1), WELLE, 1.2, true)
	# die Traeger, ferne zuerst: jeder sein Ausschnitt vom Blatt, nach der Tiefe skaliert, die Fuesse auf seinem Platz am Weg
	var box: Array = leben.get("box", [-80, -120, 80, 40])
	var slot_x: Array = leben.get("slot_x", [])
	var slot_y := float(leben.get("slot_y", 0))
	if zug != null:
		var folge := range(zg.size())
		folge.sort_custom(func(a, b): return zg[a][2] < zg[b][2])   # kleinerer Massstab = weiter weg
		for j in folge:
			var p: Array = zg[j]
			var k: float = p[2]
			var src := Rect2(float(slot_x[j]) + box[0], slot_y + box[1], box[2] - box[0], box[3] - box[1])
			var dst := Rect2(p[0] + box[0] * k, p[1] + box[1] * k, (box[2] - box[0]) * k, (box[3] - box[1]) * k)
			c.draw_texture_rect_region(zug, dst, src)
	# die Flammen auf den Fackelschaeften
	for j in zg.size():
		if not fackel[j]: continue
		var p: Array = zg[j]
		var fx: float = p[4]; var fy: float = p[5]; var sz: float = p[6]
		var fl := flackern(j, ms)
		_glimmen(c, fx, fy, sz * 4.5, WARM_TIEF, 0.3 * fl)
		_glimmen(c, fx, fy, sz * 1.3, WARM, 0.6 * fl)
		for q in 3:
			var w := sz * (0.12 - q * 0.03)
			var h := sz * (0.32 - q * 0.07) * (0.85 + 0.3 * ((j * 7 + q * 3) % 5) / 4.0) * flackern(j * 3 + q + 7, ms)
			var lean := (0.2 + 0.5 * sin(ms / 1000.0 * 6.1 + j * 1.3 + q)) * w
			c.draw_colored_polygon(flamme(fx, fy, w, h, lean), FLAMME[q])
	# der Tempel vor allem, was hinter ihm geht
	if vorn != null: c.draw_texture(vorn, Vector2.ZERO)
	c.draw_set_transform(Vector2.ZERO)

# die Flamme wie der Pfad im alten Spiel: zwei quadratische Boegen von links unten ueber die Spitze nach rechts unten
static func flamme(fx: float, fy: float, w: float, h: float, lean: float) -> PackedVector2Array:
	var pts := [Vector2(fx - w, fy)]
	for bogen in [[Vector2(fx - w, fy), Vector2(fx - w * 0.8, fy - h * 0.6), Vector2(fx + lean, fy - h)],
			[Vector2(fx + lean, fy - h), Vector2(fx + w * 0.8, fy - h * 0.5), Vector2(fx + w, fy)]]:
		for n in 8:
			var t := (n + 1) / 8.0
			pts.append((bogen[0] as Vector2).lerp(bogen[1], t).lerp((bogen[1] as Vector2).lerp(bogen[2], t), t))
	return PackedVector2Array(pts)

# wo die senkrechte Linie x die Pfuetze schneidet: [oben, unten] oder leer
static func _pfuetze_bei(rand: Array, x: float) -> Array:
	var ys := []
	for n in rand.size():
		var a: Array = rand[n]; var b: Array = rand[(n + 1) % rand.size()]
		if (float(a[0]) - x) * (float(b[0]) - x) <= 0.0 and a[0] != b[0]:
			ys.append(lerpf(float(a[1]), float(b[1]), (x - float(a[0])) / (float(b[0]) - float(a[0]))))
	if ys.size() < 2: return []
	return [ys.min(), ys.max()]

# ein weiches rundes Licht wie glow im alten Maler: [a] in der Mitte, ein Drittel davon bei einem Drittel von [r], am Rand nichts
func _glimmen(c: Control, x: float, y: float, r: float, farbe: Color, a: float) -> void:
	if r < 1.0 or a <= 0.0: return
	c.draw_texture_rect(_schein(0.35, 0.35), Rect2(x - r, y - r, 2 * r, 2 * r), false, Color(farbe, minf(a, 1.0)))

static var _scheine := {}
static func _schein(mitte: float, anteil: float) -> Texture2D:
	var k := "%.2f/%.2f" % [mitte, anteil]
	if not _scheine.has(k):
		var g := Gradient.new()
		g.offsets = PackedFloat32Array([0.0, mitte, 1.0])
		g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, anteil), Color(1, 1, 1, 0)])
		var t := GradientTexture2D.new()
		t.gradient = g
		t.fill = GradientTexture2D.FILL_RADIAL
		t.fill_from = Vector2(0.5, 0.5)
		t.fill_to = Vector2(1.0, 0.5)
		t.width = 128; t.height = 128
		_scheine[k] = t
	return _scheine[k]

# ---------------------------------------------------------------- Klang (IntroSound.kt, IntroSoundUi.kt)

func _klang(was: String, mit := []) -> void:
	if klang != null and klang.has_method(was): klang.callv(was, mit)

func _musik(k: float) -> void: _klang("musik_stufe", [k])

func _plane_klang() -> void:
	var z := RandomNumberGenerator.new()
	z.randomize()
	var k: Dictionary = daten().get("klang", {})
	var b: Array = k.get("bilder", [])
	var gesamt := saetze.size() * float(uhr.get("schritt_ms", 7200)) + float(uhr.get("ende_ms", 1200))
	# IntroSound.chirps: ungleich verteilt nach dem Bild, leicht verschieden laut, keine unter dem schwarzen Bild
	var t := 600.0 + z.randi_range(0, 1199)
	while t < gesamt and not b.is_empty():
		var p: Dictionary = b[clampi(int(bild_bei(t)["bild"]), 0, b.size() - 1)]
		if float(p.get("grille", 0)) <= 0.0: break
		zirpen.append([t, float(p["grille"]) * (0.8 + 0.4 * z.randf())])
		t += z.randi_range(int(p["zirp_von"]), int(p["zirp_bis"]))
	# IntroSound.night: drei Rufe, jeder eine andere Stimme, dann ein ferner Schrei; je ±300 ms verschoben
	var stimmen := [0, 1, 2]
	stimmen.shuffle()
	var start := schwarz * float(uhr.get("schritt_ms", 7200))
	var n := 0
	for c in k.get("nacht", []):
		var nr: int = stimmen[n] if String(c["klang"]) == "far_shout" and n < 3 else z.randi_range(0, 2)
		if String(c["klang"]) == "far_shout": n += 1
		rufe.append([start + float(c["ms"]) + z.randi_range(-300, 300), String(c["klang"]), float(c["pegel"]), nr])

# IntroSound.loops: das Gemisch des Bilds, mit dem vorigen ueber die Ueberblendung gemischt, am Anfang aus der Stille
func schleifen_bei(t: float) -> Dictionary:
	var k: Dictionary = daten().get("klang", {})
	var b: Array = k.get("bilder", [])
	if b.is_empty(): return {"wind": 0.0, "river": 0.0, "alarm_bell": 0.0}
	var f := bild_bei(t)
	var jetzt: Dictionary = b[clampi(int(f["bild"]), 0, b.size() - 1)]
	var vor = b[int(f["unter"])] if int(f["unter"]) >= 0 else null
	var ein := clampf(t / float(k.get("start_ms", 1500)), 0.0, 1.0)
	var weg := 1.0 - float(f["weg"])
	var mische := func(feld: String) -> float:
		var a := float(jetzt[feld])
		return (a if vor == null else float(vor[feld]) + (a - float(vor[feld])) * float(f["mix"])) * weg * ein
	# die Glocke nur unter dem schwarzen Bild, langsam einsetzend, mit dem Ende verklingend
	var glocke := 0.0
	if int(f["bild"]) == schwarz and not f["vorbei"]:
		var g := clampf((t - schwarz * float(uhr.get("schritt_ms", 7200))) / float(k.get("glocke_ein_ms", 2500)), 0.0, 1.0)
		glocke = float(k.get("glocke", 0.12)) * g * g * (3.0 - 2.0 * g) * weg
	return {"wind": mische.call("wind"), "river": mische.call("fluss"), "alarm_bell": glocke}

var _schwarz_gehoert := false
func _klang_schritt() -> void:
	var m := schleifen_bei(ms)
	for s in SCHLEIFEN: _schleife(s, float(m[s]))
	while not zirpen.is_empty() and float(zirpen[0][0]) <= ms:
		_klang("effekt", ["cricket", float(zirpen.pop_front()[1])])
	while not rufe.is_empty() and float(rufe[0][0]) <= ms:
		var r: Array = rufe.pop_front()
		_klang("effekt", [String(r[1]), float(r[2]), 1.0, int(r[3])])
	# Music.kt: unter den Bildern leise, mit dem schwarzen voll
	if not _schwarz_gehoert and int(bild_bei(ms)["bild"]) >= schwarz and schwarz >= 0:
		_schwarz_gehoert = true
		_musik(1.0)

func _schleife(s: String, v: float) -> void:
	pegel[s] = v
	_klang("schleife_stellen", ["intro_" + s, s, v])

# ---------------------------------------------------------------- Ende, Ueberspringen (104)

func _gui_input(e: InputEvent) -> void:
	if vorbei or fragt != null: return
	if (e is InputEventMouseButton and e.pressed) or (e is InputEventScreenTouch and e.pressed):
		accept_event()
		frage()

func frage() -> void:
	var de := Sprache.aktiv() == "de"
	fragt = ColorRect.new()
	(fragt as ColorRect).color = Color(0, 0, 0, 0.82)
	fragt.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fragt)
	var mitte := CenterContainer.new()
	mitte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fragt.add_child(mitte)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(8 * DP))
	v.custom_minimum_size.x = get_viewport_rect().size.x - 48 * DP
	mitte.add_child(Erschaffung.kasten(v))
	v.add_child(Stil.zeile(("Überspringen?" if de else "Skip?").to_upper(), 14, Stil.TEXT, 3.0))
	v.add_child(Erschaffung.txt("Die Zwischensequenz endet, du kannst sie in der Chronik wieder ansehen." if de else "This ends the cutscene; you can watch it again in the Chronicle.", 16))
	v.add_child(Erschaffung.knopf("Überspringen" if de else "Skip", func(): beende()))
	v.add_child(Erschaffung.knopf("Weiter ansehen" if de else "Keep watching", func(): fragt.queue_free(); fragt = null))

func beende() -> void:
	if vorbei: return
	vorbei = true
	if fragt != null: fragt.queue_free(); fragt = null
	# die Schleifen klingen aus, statt abzubrechen (IntroSoundUi onDispose: fadeOut)
	if art == "intro" and klang != null:
		var tw := klang.create_tween()
		var von := pegel.duplicate()
		var kl := klang
		tw.tween_method(func(k: float):
			for s in SCHLEIFEN: kl.call("schleife_stellen", "intro_" + s, s, float(von.get(s, 0.0)) * k), 1.0, 0.0, AUS_MS / 1000.0)
	_musik(1.0)
	fertig.emit()
