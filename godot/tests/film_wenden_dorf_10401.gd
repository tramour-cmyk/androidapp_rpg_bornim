extends SceneTree
# 1040.1 (Chef 13.11., 15:58, t283: „Alle Figuren im Dorf haben sich wieder gedrillt wie am Hähnchenspieß … wie auf dem Drehteller.“;
# Chef 13.11., 20:06: „wir haben grundsätzlich ein Drehproblem“): Film wie der Chef es sieht, im Dorf bei Tag. Der Lyra-Film in der
# Höhle (film_wenden_10401.gd, Lauf 467) zeigte die Füße nicht: dunkel, fern, die lange Robe verdeckt die Schritte. Hier Bram (Bauer,
# Hose, Füße frei) am Markt um 12 Uhr; die Kamera steht auf ihm, nah (4,5 m Bildbreite), ohne Oberfläche. Der Held geht gemächlich
# zwei Kacheln vor ihm vorbei, bleibt stehen, geht zurück, dann eine Kachel dicht vorbei: drei Gelegenheiten zu wenden, gut 14 s.
# Bram streift sonst (streifen 1); damit er im Bild bleibt, hält er still (warte), wie im Spiel, sobald er dem Helden nachschaut.
# Im Protokoll je halbe Sekunde: Bewegung, Wende, Rückstand zum Helden, gedrehte Grad außerhalb einer Wende (Drehteller).
# Nur mit Fenster und --write-movie, im Ordner godot (Schritt „Wendefilm (1040.1)“ in godot.yml).

var spiel
var titel: Label
var p = null
var bilder := 0
var gleiten := 0.0
var schritt := 0.0
var r_vorher := 0.0


func _zeile() -> void:
	var d := absf(angle_difference(r_vorher, p.rotation.y))
	r_vorher = p.rotation.y
	if p.wende != "": schritt += d
	else: gleiten += d
	bilder += 1
	if bilder % 15 != 0: return
	var a: AnimationPlayer = p.anim
	var h: Vector3 = spiel.held.global_position - p.global_position
	var zu := rad_to_deg(angle_difference(p.rotation.y, atan2(h.x, h.z)))
	print("FILM10401D %.1f s %s %.2f, Wende %s, %.0f Grad hinter dem Helden; bisher %.0f Grad in Wenden, %.0f ohne" % [bilder / 30.0,
		a.current_animation if a else "-", a.speed_scale if a else 0.0, p.wende if p.wende != "" else "-", zu, rad_to_deg(schritt), rad_to_deg(gleiten)])


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
	spiel.betrete("village", Vector2i(19, 13), "LEFT")
	await create_timer(1.5).timeout   # die Blende nach dem Betreten läuft in Sekunden
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k:
			k.visible = false
	for l in spiel.leute.get_children():
		if String(l.get("daten").get("id", "")) == "bram":
			p = l
	# 1040.1 (Lauf 471: „kein Bram am Markt (unsichtbar auf (14, 15))“): vom Helden auf (19, 13) aus liegt Bram hinter der Sichtlinie;
	# wie im Lyra-Film (879725138) Sichtlinie aus (Testmenü 555), Prüfgegenstand sind seine Schritte
	Testmodus.alles_sichtbar = true
	for i in 30:
		if p == null or p.visible: break
		await process_frame
	if p == null or not p.visible:
		print("FILM10401D kein Bram am Markt (%s)" % ("nicht auf der Karte" if p == null else "unsichtbar auf %s" % str(p.kachel)))
		quit(1)
		return
	# Bram auf seinen Platz des Mittags (Tagesablauf 720: 14, 15), still, Blick nach Süden wie im Spiel nach dem Streifen
	p.ziel = Vector2i(-1, -1)
	p.weg.clear()
	p.kachel = Vector2i(14, 15)
	p.position = spiel.karte.kachel_pos(p.kachel)
	p.warte = 999.0
	p.rotation.y = 0.0
	p.blick = 0.0
	r_vorher = p.rotation.y
	print("FILM10401D Bram auf %s mit Wenden %s, Bewegung %s" % [str(p.kachel), str(p.wende_kurve.keys()), str(p.anim != null)])
	spiel.kamera.ziel = p
	spiel.kamera.zoom = 4.5   # nah: die Füße sind zu sehen
	spiel.kamera.springe()
	titel.text = "1040.1 · Bram, der Held geht vorbei"
	await _warte(1.0)
	await _geh(Vector2i(10, 13))
	titel.text = "1040.1 · Held steht"
	await _warte(1.5)
	titel.text = "1040.1 · zurück"
	await _geh(Vector2i(18, 13))
	titel.text = "1040.1 · dicht vorbei"
	await _geh(Vector2i(18, 14))
	await _geh(Vector2i(10, 14))
	titel.text = "1040.1 · Held steht"
	await _warte(1.5)
	print("FILM10401D fertig: %.0f Grad in Wenden, %.0f Grad ohne (Drehteller)" % [rad_to_deg(schritt), rad_to_deg(gleiten)])
	quit(0)


func _initialize() -> void:
	_lauf.call_deferred()
