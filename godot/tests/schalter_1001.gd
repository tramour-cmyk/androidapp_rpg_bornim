# 1001 (alt 229.1, 260; SkirmishScreen.kt 1330): Raster-, Würfel- und Tempo-Schalter sind weg, solange der Ring auf ein Tippen
# wartet, ein Hinweis oder das Urteil des Rings steht; danach wieder da. Ohne Bild, im MARS-Probekampf.
# Aufruf: im Ordner godot mit -s res://tests/schalter_1001.gd (Exit 0 = richtig)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")

var fehler := 0


func _initialize() -> void:
	_lauf.call_deferred()


func _check(ok: bool, was: String) -> void:
	print(("ok     " if ok else "FEHLER ") + was)
	if not ok:
		fehler += 1


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _da(ui) -> bool:
	return ui.grid_rect.size.x > 0.0 and ui.dice_rect.size.x > 0.0


func _lauf() -> void:
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(3)
	await _frames(3)
	var kf = p.fight
	var ui = kf.ui
	Engine.time_scale = 8.0
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 20000 and (kf.busy or kf.playing or not kf.beats.is_empty() or kf.ring_open or not _da(ui)):
		await process_frame
	Engine.time_scale = 1.0
	await _frames(2)
	_check(_da(ui), "Schalter stehen, wenn nichts wartet")
	ui.ring_open("hero", {})
	await _frames(2)
	_check(not _da(ui) and ui.tempo_rect.size.x <= 0.0, "Ring offen: Raster, Würfel, Tempo weg")
	ui.ring_close()
	await _frames(2)
	_check(_da(ui), "Ring zu: Schalter wieder da")
	ui.ring_verdict("GOOD")
	await _frames(2)
	_check(not _da(ui), "Urteil des Rings steht: Schalter weg")
	ui.verdict.visible = false
	await _frames(2)
	_check(_da(ui), "Urteil weg: Schalter wieder da")
	ui.show_tip("Probe")
	await _frames(2)
	_check(not _da(ui), "Hinweis steht: Schalter weg")
	ui.tip.visible = false
	await _frames(2)
	_check(_da(ui), "Hinweis weg: Schalter wieder da")
	print("Schalter 1001: %s" % ("alles richtig" if fehler == 0 else "%d Fehler" % fehler))
	quit(0 if fehler == 0 else 1)
