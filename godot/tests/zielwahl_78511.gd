extends SceneTree
# 785.11 (Abgleich alt, SkirmishScreen.kt 886–891, 1087, 1556–1561): Zielwahl wie alt. In der Zielliste ab drei Stehenden einer Seite
# die Reihe hinter dem Namen („Wolf 1 · vorn  11/11“); beim Wählen (Angriff, Fähigkeitsziel, Trank, Wurf) leuchten die Wählbaren
# (Ring, Name), die übrigen Figuren sind gedämpft; nach dem Wählen keiner mehr. Ohne Bild, ohne Kaufmodelle.
# Aufruf: im Ordner godot mit -s res://tests/zielwahl_78511.gd; maßgeblich die Zeile ZIELWAHL78511.
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


func _gedaempft(k) -> Array:
	var aus := []
	for id in k.figures:
		if k.figures[id].gedaempft_an:
			aus.append(String(id))
	aus.sort()
	return aus


func _knoepfe(ui) -> Array:
	return ui.orders.find_children("*", "Button", true, false).map(func(b): return String(b.text).to_lower())     # Knöpfe in Großbuchstaben


func _lauf() -> void:
	Engine.time_scale = 30.0
	var tab = Tabellen.lade()
	var held: Dictionary = tab.probe.FIGHTER.hero
	var a = Aufruf.new()
	root.add_child(a)
	if not a.starte("WOLVES", held.hero, null, "wald", "tag", 2, int(held.hp), -1, 7, Callable(), {"eroeffnung": "HERO_FIRST"}):
		print("ZIELWAHL78511 nicht gestartet")
		quit(1)
		return
	await process_frame
	await process_frame
	var k = a.kampf
	await _ruhig(k)
	var ui = k.ui
	var m = k.mars
	var h = m.current()
	pruefe(h != null and h.side == "PARTY", "der Held ist dran (%s)" % (h.id if h else "-"))
	var feinde: Array = m.standing_of("FOES")
	pruefe(_gedaempft(k).is_empty(), "ohne Wahl ist keiner gedämpft (%s)" % str(_gedaempft(k)))
	# Angriff
	ui._set_pick("target")
	for i in 3:
		await process_frame
	var ziele: Array = m.targets(h).map(func(x): return String(x.id))
	var knoepfe := _knoepfe(ui)
	print("Zielliste: ", knoepfe)
	var mit_reihe := knoepfe.filter(func(t): return t.contains(" · vorn") or t.contains(" · hinten") or t.contains(" · front") or t.contains(" · back"))
	pruefe(feinde.size() <= 2 or mit_reihe.size() == ziele.size(), "ab drei Gegnern trägt jedes Ziel seine Reihe (%d Gegner, %d von %d mit Reihe)" % [feinde.size(), mit_reihe.size(), ziele.size()])
	var soll := []
	for id in k.figures:
		if not ziele.has(String(id)):
			soll.append(String(id))
	soll.sort()
	pruefe(_gedaempft(k) == soll, "Angriff: gedämpft sind genau die Nicht-Wählbaren (%s, soll %s)" % [str(_gedaempft(k)), str(soll)])
	for z in ziele:
		pruefe(ui.named.has(z), "Angriff: %s trägt den Namen" % z)
	# Trank: nur die eigene Seite ist wählbar (wem er hilft); zum Prüfen dem Helden Leben nehmen
	var trank := ""
	for id in m.items:
		if String(m.items[id].get("kind", "")) == "POTION" or String(id).contains("heal"):
			trank = String(id)
			break
	if trank != "":
		h.hp = maxi(1, h.hp - 5)
		ui._set_pick("drink_at", trank)
		for i in 3:
			await process_frame
		var dg := _gedaempft(k)
		pruefe(not dg.has(String(h.id)) and feinde.all(func(x): return dg.has(String(x.id))), "Trank: der Held leuchtet, die Gegner gedämpft (%s, Trank %s)" % [str(dg), trank])
	else:
		print("Hinweis: kein Trank in den Daten, Trank nicht geprüft")
	# zurück: keiner mehr gedämpft
	ui._set_pick("main")
	for i in 3:
		await process_frame
	pruefe(_gedaempft(k).is_empty(), "nach dem Wählen ist keiner gedämpft (%s)" % str(_gedaempft(k)))
	print("ZIELWAHL78511 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
