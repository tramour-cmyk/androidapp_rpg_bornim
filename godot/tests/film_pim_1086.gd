extends SceneTree
# 1086 (Chef 13.11., 15:47, t283.5: „Text sagt, er rennt heim, steht aber neben mir, passiert nichts … gab eh keinen Dank“): Film wie
# im Spiel (spiel.tscn, Spielkamera, Gesprächsfeld sichtbar). 10 Uhr am Schlagbaum: der Held spricht Pim an, wählt „Gib Pim 5 Gold“,
# liest zu Ende und bleibt stehen; Pim rennt heim. Der Held geht ihm nach zu seiner Hütte und klopft an Pims Tür: die Mutter dankt
# ([1085.pim.dank]). Im Protokoll je Sekunde Pims Kachel und ob er rennt. Nur mit Fenster und --write-movie, im Ordner godot
# (Schritt dorf=1086 in godot.yml).

var spiel
var titel: Label
var pim: Leute = null
var bilder := 0


func _zeile() -> void:
	bilder += 1
	if bilder % 30 != 0: return
	print("FILM1086 %.0f s Pim %s, rennt %s, Held %s" % [bilder / 30.0, pim.kachel, pim.eilt, spiel.held.kachel])


func _warte(s: float) -> void:
	for i in int(s * 30.0):
		await process_frame
		_zeile()


func _geh(ziel: Vector2i) -> void:
	var z: Vector3 = spiel.karte.kachel_pos(ziel)
	for i in 30 * 15:
		var d: Vector3 = z - spiel.held.position
		d.y = 0.0
		if d.length() < 0.12: break
		spiel.held.richtung = d.normalized()
		await process_frame
		_zeile()
	spiel.held.richtung = Vector3.ZERO


func _lies() -> void:   # jede Zeile gut eine Sekunde stehen lassen
	var n := 0
	while spiel.ui.spricht() and not spiel.ui.knopf_bereit() and n < 20:
		await _warte(1.6)
		spiel.ui.weiter()
		await process_frame
		if spiel.ui.spricht() and not spiel.ui.knopf_bereit(): spiel.ui.weiter()
		n += 1


func _lauf() -> void:
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
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
	var sz: Zustand = spiel.zustand
	sz.minuten = 10 * 60
	sz.gold = 12
	for f in ["intro_done", "quest_started"]: sz.setze(f)
	spiel.betrete("village", Vector2i(15, 16), "UP")
	for i in 10: await process_frame
	for n in ["mess", "oben"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	for l in spiel.leute.get_children():
		if l is Leute and String(l.daten.get("id", "")) == "pim": pim = l
	if pim == null and OS.get_environment("OHNE_MODELL") == "1":   # am Rechner ohne gebaute Leute: nur Weg und Zeiten
		for d in spiel.karte.daten.get("leute", []):
			if String(d["id"]) == "pim": pim = Leute.new(spiel.karte, d, spiel.held); spiel.leute.add_child(pim)
		for i in 3: await process_frame
	if pim == null or not pim.visible:
		print("FILM1086 kein Pim im Dorf")
		quit(1)
		return
	pim.kachel = Vector2i(15, 14)
	pim.position = spiel.karte.kachel_pos(pim.kachel)
	pim.weg.clear()
	pim.warte = 999.0
	spiel.kamera.springe()
	titel.text = "1086 · zu Pim am Schlagbaum"
	await _geh(Vector2i(15, 15))
	await _warte(0.5)
	spiel.sprich(pim)
	await _lies()
	titel.text = "1086 · Gib Pim 5 Gold"
	await _warte(1.5)
	spiel.ui.knopf_im_text.emit(1)
	await process_frame
	await _lies()
	await _warte(1.6)
	while spiel.ui.spricht():
		spiel.ui.weiter()
		await _warte(0.3)
	titel.text = "1086 · Held steht, Pim rennt heim"
	await _warte(4.0)
	titel.text = "1086 · zu Pims Hütte"
	await _geh(Vector2i(15, 20))
	await _geh(Vector2i(14, 23))
	await _warte(2.0)
	titel.text = "1086 · an Pims Tür klopfen"
	await _geh(Vector2i(13, 23))
	spiel.held.setze(Vector2i(13, 23), "UP")
	await _warte(0.5)
	spiel._aktion()
	await _warte(0.5)
	var n := 0
	while spiel.ui.spricht() and n < 6:
		await _warte(2.5)
		spiel.ui.weiter()
		await process_frame
		if spiel.ui.spricht(): spiel.ui.weiter()
		n += 1
	await _warte(1.0)
	print("FILM1086 fertig, Mutter gedankt %s" % sz.has(Geschichte.PIM_GOLD_DANK))
	quit(0)


func _initialize() -> void:
	_lauf.call_deferred()
