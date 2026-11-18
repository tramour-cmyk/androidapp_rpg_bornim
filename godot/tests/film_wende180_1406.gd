extends SceneTree
# 1406 (Prüfliste t300, Punkt 300.10): Film wie der Chef es sieht, im Dorf am Schlagbaum bei Tag. Wache Jorin geht seine Runde bis
# zum Ende (20, 3), wendet dort mit einer halben Drehung (Drehen180, Turn180 der UAL2) und geht zurück bis (18, 3), wendet wieder
# zur anderen Seite. Wie im Spiel nach der Ankunft (runde: Blick zurück), nur ohne Zufall und ohne die langen Pausen; gut 12 s.
# Kamera nah auf Jorin (4,5 m Bildbreite), ohne Oberfläche; der Held steht fern, damit Jorin ihm nicht nachschaut.
# Im Protokoll je halbe Sekunde: Bewegung, Wende, gedrehte Grad in und außerhalb einer Wende.
# Nur mit Fenster und --write-movie, im Ordner godot.

var spiel
var titel: Label
var p = null
var bilder := 0
var gleiten := 0.0
var schritt := 0.0
var r_vorher := 0.0
var wenden := {}


func _zeile() -> void:
	var d := absf(angle_difference(r_vorher, p.rotation.y))
	r_vorher = p.rotation.y
	if p.wende != "":
		schritt += d
		wenden[p.wende] = true
	elif p.ziel.x < 0:
		gleiten += d
	bilder += 1
	if bilder % 15 != 0: return
	var a: AnimationPlayer = p.anim
	print("FILM1406 %.1f s %s, Wende %s, auf %s; bisher %.0f Grad in Wenden, %.0f im Stehen ohne" % [bilder / 30.0,
		a.current_animation if a else "-", p.wende if p.wende != "" else "-", str(p.kachel), rad_to_deg(schritt), rad_to_deg(gleiten)])


func _warte(s: float) -> void:
	for i in int(s * 30.0):
		await process_frame
		_zeile()


func _geh(ziel: Vector2i) -> void:
	p.fort_nach = ziel
	p.warte = 0.0
	for i in 30 * 10:
		await process_frame
		_zeile()
		if p.kachel == ziel and p.ziel.x < 0: break
	p.fort_nach = Vector2i(-1, -1)
	p.warte = 999.0


func _wende(grad: float) -> void:
	p.blick = p.rotation.y + deg_to_rad(grad)
	p.warte = 999.0
	await _warte(2.3)


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
	spiel.betrete("village", Vector2i(19, 13), "LEFT")
	await create_timer(1.5).timeout   # die Blende nach dem Betreten läuft in Sekunden
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k:
			k.visible = false
	for l in spiel.leute.get_children():
		if String(l.get("daten").get("id", "")) == "jorin":
			p = l
	Testmodus.alles_sichtbar = true   # wie im Bram-Film: Prüfgegenstand sind die Schritte, nicht die Sichtlinie
	for i in 30:
		if p == null or p.visible: break
		await process_frame
	if p == null or not p.visible:
		print("FILM1406 kein Jorin am Schlagbaum (%s)" % ("nicht auf der Karte" if p == null else "unsichtbar auf %s" % str(p.kachel)))
		quit(1)
		return
	p.ziel = Vector2i(-1, -1)
	p.weg.clear()
	p.kachel = Vector2i(18, 3)
	p.position = spiel.karte.kachel_pos(p.kachel)
	p.rotation.y = PI / 2   # Blick nach Osten, zum Ende seines Wegs
	p.blick = p.rotation.y
	p.warte = 999.0
	r_vorher = p.rotation.y
	print("FILM1406 Jorin auf %s mit Wenden %s, Bewegung %s" % [str(p.kachel), str(p.wende_kurve.keys()), str(p.anim != null)])
	spiel.kamera.ziel = p
	spiel.kamera.zoom = 4.5
	spiel.kamera.springe()
	titel.text = "1406 · Jorin geht zum Ende seines Wegs"
	await _warte(0.8)
	await _geh(Vector2i(20, 3))
	titel.text = "1406 · Wende nach links"
	await _wende(177.0)
	titel.text = "1406 · zurück"
	await _geh(Vector2i(18, 3))
	titel.text = "1406 · Wende nach rechts"
	await _wende(-177.0)
	print("FILM1406 fertig: Wenden %s, %.0f Grad in Wenden, %.0f im Stehen ohne (Drehteller)" % [str(wenden.keys()), rad_to_deg(schritt), rad_to_deg(gleiten)])
	quit(0)


func _initialize() -> void:
	_lauf.call_deferred()
