extends SceneTree
# 416.6 ohne Bild: Blutspur (skripte/blutspur.gd) wie alt (Tracks.blood, WorldScreen.drawTracks): eine Lache je gefallenem Gegner auf
# seinem Feld, nur auf ihrer Karte, frisch rot, nach zwei Fünfteln ihres Lebens braun, danach verblassend, nach sechs Minuten fort;
# das Bild der Lache ist je Form gleich und deckt in der Mitte, am Rand nicht; ohne Prüfschalter (draft) keine.
# Braucht keine godot/daten. Aufruf: im Ordner godot mit -s res://tests/blut_4166.gd; massgeblich ist die Zeile BLUT4166.

const Spuren = preload("res://regeln/spuren.gd")
var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	Blutspur.spuren = Spuren.new()
	var b := Blutspur.new("forest")
	root.add_child(b)
	b.set_process(false)
	Blutspur.blut("forest", Vector2i(10, 7), 42, 1000)
	Blutspur.blut("village", Vector2i(3, 3), 7, 1000)
	b.stelle(1000)
	pruefe(b.anzahl() == 1, "eine Lache im Wald, keine aus dem Dorf: %d" % b.anzahl())
	var mi: MeshInstance3D = b.get_child(0)
	var soll := Vector3(10.5 * Karte.TS, Blutspur.HOEHE, 7.5 * Karte.TS)
	pruefe(mi.position.distance_to(soll) < 0.001, "auf der Mitte des Felds (10, 7), flach am Boden: %s" % mi.position)
	pruefe(mi.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "wirft keinen Schatten")
	var mat := mi.material_override as StandardMaterial3D
	var f := mat.albedo_color
	pruefe(f.r > 0.5 and f.g < 0.15 and absf(f.a - 0.85) < 0.01, "frisch rot, Deckung 0,85: %s" % f)
	# zwei Fünftel des Lebens (2,4 min): trocken braun, noch voll deckend
	b.stelle(1000 + int(Spuren.BLOOD_MS * 0.4))
	f = mat.albedo_color
	pruefe(f.is_equal_approx(Color(Blutspur.TROCKEN, 0.85)), "nach 2,4 min dunkelbraun: %s" % f)
	# vier Fünftel: halb verblasst
	b.stelle(1000 + int(Spuren.BLOOD_MS * 0.8))
	pruefe(absf(mat.albedo_color.a - 0.425) < 0.01, "nach 4,8 min halb verblasst: %.3f" % mat.albedo_color.a)
	# nach sechs Minuten fort
	b.stelle(1000 + Spuren.BLOOD_MS + 1)
	await process_frame
	pruefe(b.anzahl() == 0 and b.get_child_count() == 0, "nach 6 min fort: %d" % b.get_child_count())
	# Bild der Lache: Mitte deckt, Ecken leer, gleiche Form gleiches Bild, andere Form anderes
	var i1 := Blutspur.bild(42)
	var i2 := Blutspur.bild(42)
	var i3 := Blutspur.bild(43)
	var n := i1.get_width()
	pruefe(n == 80 and i1.get_height() == 80, "Bild 80 × 80: %d" % n)
	pruefe(i1.get_pixel(n / 2, n / 2).a > 0.9, "Mitte deckt: %.2f" % i1.get_pixel(n / 2, n / 2).a)
	var rand := 0.0
	for k in n:
		rand = maxf(rand, maxf(maxf(i1.get_pixel(k, 0).a, i1.get_pixel(k, n - 1).a), maxf(i1.get_pixel(0, k).a, i1.get_pixel(n - 1, k).a)))
	pruefe(rand == 0.0, "Rand des Bilds leer (nichts abgeschnitten): %.2f" % rand)
	pruefe(i1.get_data() == i2.get_data(), "gleiche Form, gleiches Bild")
	pruefe(i1.get_data() != i3.get_data(), "andere Form, anderes Bild")
	var deckt := 0
	for y in n:
		for x in n:
			if i1.get_pixel(x, y).a > 0.5: deckt += 1
	pruefe(deckt > 150 and deckt < 2400, "Lache deckt einen Teil des Felds: %d Bildpunkte" % deckt)
	# Feld vor dem Helden (Kampf ohne Streuner)
	pruefe(Blutspur.vor(Vector2i(5, 5), "UP") == Vector2i(5, 4) and Blutspur.vor(Vector2i(5, 5), "DOWN") == Vector2i(5, 6)
		and Blutspur.vor(Vector2i(5, 5), "LEFT") == Vector2i(4, 5) and Blutspur.vor(Vector2i(5, 5), "RIGHT") == Vector2i(6, 5), "Feld vor dem Helden je Blick")
	# Staub (Chef 09:21, Tracks.walked): rennend auf trockenem Weg je Doppelschritt eine Wolke aus drei Wölkchen, gehend oder auf Gras
	# keine; sie gehen in 0,9 s auf und vergehen
	var sp: Spuren = Blutspur.spuren
	for i in 12:     # 12 × 0,3 Felder rennend auf dem Weg: Schritte bei 0,6 Feldern, jeder zweite mit Staub
		sp.walked("forest", 2.0, 2.0 + i * 0.3, 0.0, "PATH", true, true, 20000 + i * 80)
	b.staub(20000 + 11 * 80)
	var wolken := b.staub_anzahl()
	pruefe(wolken >= 2 and wolken <= 4, "rennend auf dem Weg Staub je Doppelschritt: %d Wolken" % wolken)
	var w0: Node3D = null
	for c in b.get_children():
		if c.get_child_count() == 3: w0 = c
	pruefe(w0 != null, "eine Wolke aus drei Wölkchen")
	if w0 != null:
		var a0: float = (w0.get_child(0).material_override as StandardMaterial3D).albedo_color.a
		var s0: float = w0.get_child(0).scale.x
		b.staub(20000 + 11 * 80 + 500)
		var a1: float = (w0.get_child(0).material_override as StandardMaterial3D).albedo_color.a
		pruefe(a1 < a0 and w0.get_child(0).scale.x > s0, "Wölkchen wächst und verblasst: Deckung %.2f → %.2f" % [a0, a1])
	b.staub(20000 + 11 * 80 + Spuren.DUST_MS + 200)
	await process_frame
	pruefe(b.staub_anzahl() == 0, "nach 0,9 s fort: %d" % b.staub_anzahl())
	for i in 12:
		sp.walked("forest", 6.0, 2.0 + i * 0.3, 0.0, "PATH", true, false, 30000 + i * 80)
		sp.walked("forest", 9.0, 2.0 + i * 0.3, 0.0, "GRASS", true, true, 30000 + i * 80)
	b.staub(30000 + 11 * 80)
	pruefe(b.staub_anzahl() == 0, "gehend auf dem Weg und rennend auf Gras kein Staub: %d" % b.staub_anzahl())
	# ohne Prüfschalter keine
	Spuren.draft = false
	Blutspur.blut("forest", Vector2i(1, 1), 5, 5000)
	b.stelle(5000)
	pruefe(b.anzahl() == 0, "ohne Prüfschalter keine Lache")
	Spuren.draft = true
	print("BLUT4166 %s, %d Fehler" % ["gut" if fehler == 0 else "FEHLER", fehler])
	quit(1 if fehler else 0)
