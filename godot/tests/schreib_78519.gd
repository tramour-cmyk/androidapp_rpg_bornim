extends SceneTree
# 785.19 (alt WorldScreen.kt 123-130, 382-388): Gesprächstext erscheint Zeichen für Zeichen (18 ms je Zeichen), ▼ erst am Ende; ein
# Tippen, solange er läuft, zeigt ihn ganz und geht nicht weiter; das nächste Tippen geht weiter. Ohne Bild.
# Aufruf: im Ordner godot mit -s res://tests/schreib_78519.gd -> „SCHREIB78519 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	Sprache.lade()
	var ui := Steuerung.new()
	root.add_child(ui)
	await process_frame
	var satz := "Sammel mir drei Bündel, dann reden wir weiter."
	ui.zeilen = [{"wer": "Morwen", "text": satz}, {"text": "Zweite Zeile."}]
	ui.naechste()
	await process_frame
	var n0: int = ui.text.visible_characters
	pruefe(n0 >= 0 and n0 < satz.length(), "am Anfang nur ein Teil sichtbar (%d von %d)" % [n0, satz.length()])
	pruefe(not ui.weiter_zeichen.visible, "▼ während des Schreibens verborgen")
	ui.weiter()
	pruefe(ui.text.visible_characters == -1 and ui.text.text == satz, "Tippen zeigt die Zeile ganz und bleibt auf ihr")
	await process_frame
	pruefe(ui.weiter_zeichen.visible, "▼ sichtbar, sobald der Text steht")
	ui.weiter()
	pruefe(ui.text.text == "Zweite Zeile.", "nächstes Tippen geht weiter (%s)" % ui.text.text)
	var t0 := Time.get_ticks_msec()
	while ui.schreibt() and Time.get_ticks_msec() - t0 < 3000:
		await process_frame
	var dauer := Time.get_ticks_msec() - t0
	pruefe(not ui.schreibt() and dauer < 13 * 18 + 400, "schreibt sich von selbst zu Ende (%d ms für 13 Zeichen)" % dauer)
	print("SCHREIB78519 %d Fehler" % fehler)
	quit(1 if fehler else 0)
