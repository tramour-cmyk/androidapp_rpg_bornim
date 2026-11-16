extends SceneTree
# 997 (Tuffy 620.2c; alt 233, 288, 333, SkirmishScreen.kt 1315): im Testmodus nennt der Kampf unter der Zugleiste je Figur, die nicht
# ruht, die laufende Bewegung mit ihrer Fassung (Name der Bewegung); in Ruhe nichts; ohne Testmodus zeichnet er nichts.
# Aufruf: im Ordner godot mit -s res://tests/bewegung_997.gd
const Aufruf = preload("res://kampf/aufruf.gd")

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var f := 0
	var tab = Tabellen.lade()     # 870.6: statt regeln/tabellen.json (Build 278)
	var held: Dictionary = tab.probe.FIGHTER.hero
	var a = Aufruf.new()
	root.add_child(a)
	if not a.starte("WOLVES", held.hero, null, "wald", "tag", 2, int(held.hp), -1, 7, Callable(), {"eroeffnung": "HERO_FIRST"}):
		print("FEHLER nicht gestartet"); quit(1); return
	for i in 5: await process_frame
	var k = a.kampf
	var ui = k.ui
	# am Rechner ohne gebaute Modelle hat keine Figur Bewegungen: dem Helden einen Spieler mit Ruhe und zwei Fassungen geben
	var fig = k.figures["hero"]
	if fig.anim == null:
		var ap := AnimationPlayer.new()
		fig.add_child(ap)
		var lib := AnimationLibrary.new()
		for n in ["Stehen", "Hieb_2"]:
			var an := Animation.new(); an.length = 5.0; lib.add_animation(n, an)
		ap.add_animation_library("", lib)
		var lib2 := AnimationLibrary.new()
		var an2 := Animation.new(); an2.length = 5.0; lib2.add_animation("Stich", an2)
		ap.add_animation_library("ual", lib2)
		fig.anim = ap
	# 1018 (Lauf 373): mit Kaufmodellen hat der Held einen Spieler, aber weder „Hieb_2“ noch „ual/Stich“; play() lief ins Leere
	for ln in [["", "Hieb_2"], ["ual", "Stich"]]:
		if not fig.anim.has_animation(ln[0] + ("/" if ln[0] != "" else "") + ln[1]):
			if not fig.anim.has_animation_library(ln[0]):
				fig.anim.add_animation_library(ln[0], AnimationLibrary.new())
			var an3 := Animation.new(); an3.length = 5.0
			fig.anim.get_animation_library(ln[0]).add_animation(ln[1], an3)
	for id in k.figures:
		var g = k.figures[id]
		if g.anim != null and g.anim.has_animation("Stehen"): g.anim.play("Stehen")
	await process_frame
	var ruhe: Array = ui.bewegungen()
	print("in Ruhe: %s" % [ruhe])
	if not ruhe.is_empty(): f += 1
	var nm_held: String = fig.fighter.name(ui.lang)
	for nm in ["Hieb_2", "ual/Stich"]:
		fig.anim.play(nm)
		await process_frame
		var zeilen: Array = ui.bewegungen()
		var soll := "%s: %s" % [nm_held, nm]
		print("mit Bewegung: %s (soll %s)" % [zeilen, soll])
		if zeilen != [soll]: f += 1
	# gezeichnet nur im Testmodus (nur prüfen, dass der Aufruf ohne Fehler läuft)
	Testmodus.geladen = true
	for an in [false, true]:
		Testmodus.an = an
		ui.overlay.queue_redraw()
		await process_frame
	a.kampf.queue_free()
	a.queue_free()
	await process_frame
	print("BEWEGUNG997 %s" % ("ok" if f == 0 else "FEHLER %d" % f))
	quit(f)
