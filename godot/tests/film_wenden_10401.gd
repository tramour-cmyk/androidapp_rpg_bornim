extends SceneTree
# 1040.1 (Tuffy aus 1040; Chef 12.11., 15:13, Lyra: „die Lyra dreht sich ja genauso bescheuert, ohne Schritte. Ja, auch wie auf dem
# Drehteller.“): Film wie im Spiel (spiel.tscn, Spielkamera): Höhle, der Held geht gemächlich an Lyra vorbei (zwei Kacheln vor ihr),
# bleibt stehen, geht zurück, dann dichter an ihr vorbei (eine Kachel). Lyra schaut ihm nach und wendet mit Schritten (leute.gd
# drehe_stehend, WENDE_FOLGE). Im Protokoll je halbe Sekunde: Bewegung von Lyra, ob sie wendet, wie weit sie hinter ihm ist.
# Nur mit Fenster und --write-movie, im Ordner godot (Schritt dorf=10401 in godot.yml).

var spiel
var titel: Label
var lyra = null
var bilder := 0


func _zeile() -> void:
	bilder += 1
	if bilder % 15 != 0: return
	var a: AnimationPlayer = lyra.anim
	var h: Vector3 = spiel.held.global_position - lyra.global_position
	var zu := rad_to_deg(angle_difference(lyra.rotation.y, atan2(h.x, h.z)))
	print("FILM10401 %.1f s %s %.2f, Wende %s, %.0f Grad hinter dem Helden" % [bilder / 30.0, a.current_animation if a else "-",
		a.speed_scale if a else 0.0, lyra.wende if lyra.wende != "" else "-", zu])


func _geh(ziel: Vector2i) -> void:
	var z: Vector3 = spiel.karte.kachel_pos(ziel)
	for i in 30 * 12:
		var d: Vector3 = z - spiel.held.position
		d.y = 0.0
		if d.length() < 0.12: break
		spiel.held.richtung = d.normalized() * 0.6     # gemächlich gehen
		await process_frame
		_zeile()
	spiel.held.richtung = Vector3.ZERO


func _warte(s: float) -> void:
	for i in int(s * 30.0):
		await process_frame
		_zeile()


func _lauf() -> void:
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5:
		await process_frame
	var ebene := CanvasLayer.new()
	ebene.layer = 60
	root.add_child(ebene)
	titel = Label.new()
	titel.add_theme_font_size_override("font_size", 28)
	titel.add_theme_color_override("font_color", Color(0.96, 0.93, 0.85))
	titel.add_theme_color_override("font_outline_color", Color.BLACK)
	titel.add_theme_constant_override("outline_size", 8)
	titel.position = Vector2(24, 90)
	ebene.add_child(titel)
	spiel.zustand.minuten = 12 * 60
	spiel.betrete("cave", Vector2i(12, 3), "LEFT")
	for i in 10:
		await process_frame
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k:
			k.visible = false
	for l in spiel.leute.get_children():
		if String(l.get("daten").get("id", "")) == "lyra_cave":
			lyra = l
	if lyra == null and OS.get_environment("OHNE_MODELL") == "1":
		lyra = _probe()     # am Rechner ohne Kaufmodelle: nur der Weg und die Zeiten, ohne Bild
	if lyra == null or not lyra.visible:
		print("FILM10401 keine Lyra in der Höhle")
		quit(1)
		return
	print("FILM10401 Lyra mit Wenden %s, Bewegung %s" % [str(lyra.wende_kurve.keys()), str(lyra.anim != null)])
	spiel.kamera.springe()
	titel.text = "1040.1 · Lyra, der Held geht vorbei"
	await _warte(1.5)
	await _geh(Vector2i(7, 3))
	titel.text = "1040.1 · Held steht"
	await _warte(2.0)
	titel.text = "1040.1 · zurück"
	await _geh(Vector2i(11, 3))
	await _warte(1.0)
	titel.text = "1040.1 · dichter vorbei"
	await _geh(Vector2i(11, 2))
	await _geh(Vector2i(6, 2))
	titel.text = "1040.1 · Held steht"
	await _warte(2.0)
	print("FILM10401 fertig")
	quit(0)


# Platzhalter wie wendeschritt_10401: Stehen, Drehen_L/R je 1 s, 90 Grad langsam an und aus
func _probe() -> Leute:
	var p := Leute.new(spiel.karte, {"id": "lyra_cave", "x": 8, "y": 1, "streifen": 0}, spiel.held)
	spiel.leute.add_child(p)
	p.warte = 999.0
	var ap := AnimationPlayer.new()
	var lib := AnimationLibrary.new()
	for name in ["Stehen", "Drehen_L", "Drehen_R"]:
		var a := Animation.new()
		a.length = 1.0
		if name == "Stehen": a.loop_mode = Animation.LOOP_LINEAR
		lib.add_animation(name, a)
	ap.add_animation_library("", lib)
	p.add_child(ap)
	p.anim = ap
	ap.play("Stehen")
	for s in [1.0, -1.0]:
		var k := PackedFloat32Array()
		for f in 31: k.append(s * deg_to_rad(90.0) * smoothstep(0.0, 1.0, f / 30.0))
		p.wende_kurve["Drehen_L" if s > 0.0 else "Drehen_R"] = k
	return p


func _initialize() -> void:
	_lauf.call_deferred()
