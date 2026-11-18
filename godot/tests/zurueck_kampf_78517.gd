extends SceneTree
# 785.17 (Abgleich alt, SkirmishScreen.kt 364 BackHandler): Android-Zurück im Kampf. Im Hauptmenü des Zugs nimmt der Kampf die Taste
# nicht (785.21); in einer Auswahl (Ziel, Können, Tasche, Wechsel) führt sie wie der Knopf „Zurück“ ins Hauptmenü des Zugs; der
# offene Bericht schließt zuerst (833 A). Ohne Bild, ohne Kaufmodelle. Maßgeblich die Zeile ZURUECKKAMPF78517.
const Aufruf = preload("res://kampf/aufruf.gd")
const LIMIT_MS := 60000

var fehler := 0


func pruefe(ok: bool, was: String) -> void:
	print(("gut    " if ok else "FEHLER ") + was)
	if not ok:
		fehler += 1


func _initialize() -> void:
	_lauf.call_deferred()


func _ruhig(k) -> void:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < LIMIT_MS and (k.busy or k.playing or not k.beats.is_empty() or k.verhuellt):
		await process_frame
	for i in 3:
		await process_frame


func _lauf() -> void:
	Engine.time_scale = 30.0
	var tab = Tabellen.lade()
	var held: Dictionary = tab.probe.FIGHTER.hero
	var a = Aufruf.new()
	root.add_child(a)
	if not a.starte("WOLVES", held.hero, null, "wald", "tag", 2, int(held.hp), -1, 7, Callable(), {"eroeffnung": "HERO_FIRST"}):
		print("ZURUECKKAMPF78517 nicht gestartet")
		quit(1)
		return
	await process_frame
	await process_frame
	var k = a.kampf
	await _ruhig(k)
	var ui = k.ui
	pruefe(ui.pick == "main" and not Zurueck.taste(self), "Hauptmenü des Zugs: der Kampf nimmt die Taste nicht")
	for p in ["target", "skills", "bag", "place"]:
		ui._set_pick(p)
		await process_frame
		var genommen := Zurueck.taste(self)
		await process_frame
		pruefe(genommen and ui.pick == "main", "Auswahl „%s“: die Taste führt ins Hauptmenü des Zugs (pick %s)" % [p, ui.pick])
		pruefe(not Zurueck.taste(self), "… danach nimmt der Kampf sie nicht mehr")
	ui._set_pick("target")
	ui._show_full_log(true)
	await process_frame
	Zurueck.taste(self)
	await process_frame
	pruefe(not ui.full_log.visible and ui.pick == "target", "offener Bericht: die Taste schließt zuerst ihn (Bericht %s, pick %s)" % [ui.full_log.visible, ui.pick])
	print("ZURUECKKAMPF78517 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
