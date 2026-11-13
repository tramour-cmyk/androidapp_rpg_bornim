extends SceneTree
# 1092 (Sokrates 13.11., 17:20 nach Chef 15:58 „warum muss ich den Rock von der Frau in der APK anschauen … sondern einfach einen
# Film“): Lyras Robe im Tempel nah, Stand wie im Spiel, mit 1092 B (Faltentäler mit Untergrenze): erst im Stehen langsam einmal
# rundum gedreht, dann Gehen auf der Stelle, dann wieder Stehen. Frage an den Chef: dunkle Längsstreifen weg?
# Nur mit Fenster, Kaufdaten und --write-movie, im Ordner godot (godot.yml „Robenfilm (1092)“ bei „1092 Film“ im Commit).

var spiel: Node
var titel: Label


func warte(s: float) -> void:
	for i in int(s * 30.0): await process_frame


func _lauf() -> void:
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	await warte(0.5)
	var st := Testmodus.station("Tempel", spiel.zustand)
	if st.is_empty():
		print("FILM1092 keine Station Tempel"); quit(1); return
	spiel.zustand.minuten = 11 * 60
	spiel.betrete(st[0], st[1], st[2])
	await warte(2.0)
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	spiel.ui.sage([])
	if not spiel.kamera.nah: spiel.kamera.nah_fern()
	var lyra: Node3D = null
	for l in spiel.leute.get_children():
		if String(l.daten.get("id", "")) == "lyra_temple": lyra = l
	if lyra == null or not lyra.visible or lyra.modell == null:
		print("FILM1092 keine Lyra im Tempel"); quit(1); return
	lyra.set_process(false); lyra.set_physics_process(false)
	var ebene := CanvasLayer.new()
	ebene.layer = 60
	root.add_child(ebene)
	titel = Label.new()
	titel.add_theme_font_size_override("font_size", 24)
	titel.add_theme_color_override("font_color", Color(0.96, 0.93, 0.85))
	titel.add_theme_color_override("font_outline_color", Color.BLACK)
	titel.add_theme_constant_override("outline_size", 8)
	titel.position = Vector2(20, 80)
	ebene.add_child(titel)
	spiel.kamera.springe()
	var zk: Vector3 = spiel.kamera.global_position - lyra.global_position
	var vorn := atan2(zk.x, zk.z)
	lyra.rotation.y = vorn
	if lyra.anim and lyra.anim.has_animation("Stehen"): lyra.anim.play("Stehen")
	titel.text = "1092 · Lyras Robe, Stehen, einmal rundum"
	await warte(1.0)
	for i in 240:   # 8 s für eine Drehung
		lyra.rotation.y = vorn + TAU * i / 240.0
		await process_frame
	lyra.rotation.y = vorn
	if lyra.anim and lyra.anim.has_animation(lyra.geh_anim):
		titel.text = "1092 · Gehen auf der Stelle"
		lyra.anim.play(lyra.geh_anim)
		await warte(3.0)
	titel.text = "1092 · Stehen"
	if lyra.anim and lyra.anim.has_animation("Stehen"): lyra.anim.play("Stehen")
	await warte(1.5)
	print("FILM1092 fertig")
	quit(0)


func _initialize() -> void:
	_lauf.call_deferred()
