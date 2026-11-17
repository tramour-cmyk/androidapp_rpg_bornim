# 1439 (Chef 16.11., 14:15; 1448 A): Bild des Kampfschirms mit Zauberer als Held (Mana-Balken unter dem Lebensbalken).
# Aufruf: BILD=/pfad.png KLASSE=CLERIC godot --path godot --resolution 540x1170 -s res://tests/bild_mana_1439.gd (mit Bild)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	seed(7)
	var p = Probe.new()
	p.hero_cls = OS.get_environment("KLASSE") if OS.get_environment("KLASSE") != "" else "CLERIC"
	p.merc_cls = "FIGHTER"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 4:
		await process_frame
	var kf = p.fight
	while kf.verhuellt:
		await process_frame
	for i in 90:
		await process_frame
	kf.ui.refresh()
	for i in 10:
		await process_frame
	var img: Image = root.get_texture().get_image()
	img.save_png(OS.get_environment("BILD"))
	print("BILD1439 ", OS.get_environment("BILD"), " ", img.get_size())
	quit(0)
