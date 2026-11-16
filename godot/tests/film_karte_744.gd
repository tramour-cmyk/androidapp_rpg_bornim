extends SceneTree
# 744 A (Chef 09.11., 11:18: „nicht wie auf Schienen laufen … mal verweilen, eine Ruheanimation haben“): Film der Monster auf der
# Gebietskarte, wie sie im Spiel laufen (spiel.tscn, Spielkamera, Spielshader). Flüsterwald am Tag, vier Monster verschiedener Art
# (Wolf zuerst) streifen um ihre Heimplätze nahe beieinander, friedlich (sie bemerken den Helden nicht), 45 s lang. Dieselbe Datei
# läuft im Bauserver zweimal: einmal mit herde.gd/streuner.gd vor 744 („vorher“), einmal mit dem Zweig („nachher“); der Titel kommt
# aus dem Argument. Dazu je 0,5 s eine Zeile „KARTE744 …“ je Monster (Kachel, Lage, Bewegung, Gang), damit man messen kann.
# Nur mit Fenster und --write-movie (Probelauf 621 A), im Ordner godot:
#   PROBE=744 xvfb-run -a godot --rendering-driver opengl3 --path . --resolution 540x1170 --write-movie <x.avi> --fixed-fps 30 \
#     -s res://tests/film_karte_744.gd -- --kartefilm744=nachher

const DAUER := 45.0
const ZAHL := 4

var spiel
var titel: Label
var fassung := "nachher"
var gefilmt: Array = []
var t0 := 0
var laeuft := false


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--kartefilm744="): fassung = a.substr(15)
	_lauf.call_deferred()


func _process(_dt: float) -> bool:
	if laeuft and (Engine.get_process_frames() - t0) % 15 == 0:
		var t := (Engine.get_process_frames() - t0) / 30.0
		for s in gefilmt:
			if not is_instance_valid(s): continue
			var a: String = s.figur.anim.current_animation if s.figur and s.figur.anim else "-"
			print("KARTE744 %s t=%.1f %s kachel=%s pos=(%.2f, %.2f) dreh=%.0f anim=%s gang=%s" % [fassung, t, s.art, s.kachel,
				s.position.x, s.position.z, rad_to_deg(s.rotation.y), a, s.get("gang") != null])
	return false


func warte(s: float) -> void:
	for i in int(s * 30.0):
		await process_frame


func _frei(h: Herde, p: Vector2i, belegt: Array) -> bool:
	if not spiel.karte.begehbar(p) or not spiel.karte.ausgang(p).is_empty() or not h.sicher(p).is_empty(): return false
	if p == spiel.held.kachel or belegt.has(p): return false
	for l in spiel.leute.get_children():
		if l is Leute and l.kachel == p: return false
	return true


func _lauf() -> void:
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var weg: Dictionary = {}
	for a in spiel.karte.daten.get("ausgaenge", []):
		if String(a["ziel"]["karte"]) == "forest": weg = a; break
	if weg.is_empty():
		print("KARTE744 FEHLER kein Weg in den Wald"); quit(1); return
	await spiel.geh_hinaus(weg)
	for i in 10: await process_frame
	var h: Herde = spiel.herde
	if spiel.karte.id != "forest" or h == null or h.liste.is_empty():
		print("KARTE744 FEHLER nicht im Wald oder keine Monster: %s" % spiel.karte.id); quit(1); return
	spiel.ui.mess.visible = false
	spiel.ui.oben.visible = false
	spiel.ui.leiste.visible = false
	spiel.ui.textfeld.visible = false
	print("KARTE744 %s Monster: %s" % [fassung, ", ".join(h.liste.map(func(s): return "%s %s %s" % [s.art, s.temper(), s.kachel]))])
	# vier verschiedener Art, die streifen (ein Lauerer bleibt im Versteck), Wolf zuerst
	var wahl: Array = []
	var arten: Array = []
	var reihe: Array = h.liste.filter(func(s): return s.temper() != "LAUERER" and (s.figur != null or DisplayServer.get_name() == "headless"))
	reihe.sort_custom(func(a, b): return (0 if a.art == "wolf" else 1) < (0 if b.art == "wolf" else 1))
	for s in reihe:
		if wahl.size() < ZAHL and not arten.has(s.art): wahl.append(s); arten.append(s.art)
	for s in reihe:
		if wahl.size() < ZAHL and not wahl.has(s): wahl.append(s)
	if wahl.is_empty():
		print("KARTE744 FEHLER keine streifenden Monster"); quit(1); return
	# Heimplätze nahe beieinander um den Heimplatz des ersten, 3 Kacheln Abstand, damit alle im Bild bleiben (streifen 3 um ihr Heim)
	var mitte: Vector2i = wahl[0].heim
	var heime: Array = [mitte]
	for d in [Vector2i(3, 0), Vector2i(-3, 0), Vector2i(0, 3), Vector2i(0, -3), Vector2i(2, 2), Vector2i(-2, -2), Vector2i(2, -2), Vector2i(-2, 2)]:
		if heime.size() >= wahl.size(): break
		if _frei(h, mitte + d, heime): heime.append(mitte + d)
	while wahl.size() > heime.size(): wahl.pop_back()
	for s in h.liste:   # friedlich: keiner jagt, keiner flieht
		s.ruhig_bis = 1 << 40
		s.jagt = false
		s.heimweg = false
	for i in wahl.size():
		var s = wahl[i]
		s.heim = heime[i]
		s.kachel = heime[i]
		s.von = heime[i]
		s.naechst_ms = h.jetzt + 400 * i
	gefilmt = wahl
	# Held abseits, außerhalb des Bildes; die Kamera folgt der Mitte der Heimplätze
	var fern: Vector2i = spiel.held.kachel
	spiel.laufen_will = false
	var mittelpunkt := Node3D.new()
	spiel.add_child(mittelpunkt)
	var summe := Vector3.ZERO
	for p in heime: summe += spiel.karte.kachel_pos(p)
	mittelpunkt.position = summe / heime.size()
	spiel.kamera.ziel = mittelpunkt
	spiel.kamera.kneifen(1.25)
	spiel.kamera.springe()
	print("KARTE744 %s gefilmt: %s, Heim %s, Held %s" % [fassung, ", ".join(wahl.map(func(s): return "%s %s" % [s.art, s.temper()])), heime, fern])
	var ebene := CanvasLayer.new()
	ebene.layer = 60
	root.add_child(ebene)
	titel = Label.new()
	titel.add_theme_font_size_override("font_size", 30)
	titel.add_theme_color_override("font_color", Color(0.96, 0.93, 0.85))
	titel.add_theme_color_override("font_outline_color", Color.BLACK)
	titel.add_theme_constant_override("outline_size", 8)
	titel.position = Vector2(24, 90)
	titel.text = "744 %s · %s" % [fassung, "bisher" if fassung == "vorher" else "Bogen, Verweilen"]
	ebene.add_child(titel)
	await warte(1.0)
	t0 = Engine.get_process_frames()
	print("KARTE744 %s start bild=%d" % [fassung, t0 - 30])     # Film ab hier (eine Sekunde davor schon im Wald), der Weg dorthin wird abgeschnitten
	laeuft = true
	await warte(DAUER)
	laeuft = false
	print("KARTE744 %s fertig" % fassung)
	quit(0)
