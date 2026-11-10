extends SceneTree
# 583 (Abgleich 512b, Pruefer 05.11., 08:17: „Sammel▼“, erzaehlter Text nicht schraeg, i-Punkte fehlen): ohne Bild. Das ▼ steht im
# unteren Rand des Textkastens und ueberdeckt keine Zeile, auch bei vollem Kasten; der schraege Schnitt kippt wie Italic
# (x_axis.y geht als FreeType xy an die Umrisse: x' = x + 0,2 · y), Gesprochenes bleibt gerade.
# Aufruf: im Ordner godot mit -s res://tests/textkasten_583.gd -> „TEXTKASTEN583 n Fehler“

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
	var lang := "Nach dem Sammeln der Kräuter am Waldrand bleibt Thora stehen und lauscht; irgendwo hinter den Bäumen bricht ein Ast, dann ist es still."
	for z in [{"text": lang}, {"wer": "Morwen", "text": "Sammel mir drei Bündel, dann reden wir weiter."}]:
		ui.zeilen = [z]
		ui.naechste()
		for i in 3: await process_frame
		var t: Label = ui.text
		var w: Label = ui.weiter_zeichen
		var tr := t.get_global_rect()
		var zeilen_h := t.get_line_count() * t.get_line_height()
		var text_unten := tr.position.y + (tr.size.y - zeilen_h if t.vertical_alignment == VERTICAL_ALIGNMENT_BOTTOM else 0.0) + zeilen_h
		var wr := w.get_global_rect()
		var kr: Rect2 = ui.textfeld.get_global_rect()
		print("TEXTKASTEN583 %s: Zeilen %d, Text bis y %.0f, ▼ %s, Kasten %s" % ["Erzählt" if not z.has("wer") else "Gesprochen", t.get_line_count(), text_unten, wr, kr])
		pruefe(wr.position.y >= text_unten - 1.0, "▼ liegt in der letzten Zeile (▼ oben %.0f, Text unten %.0f)" % [wr.position.y, text_unten])
		# das Zeichen selbst (oben im Label, hoechstens Schriftgroesse hoch) innerhalb des Rahmens; der Zeilenabstand darunter zaehlt nicht
		var zeichen := Rect2(wr.position, Vector2(wr.size.x, w.get_theme_font_size("font_size")))
		pruefe(kr.grow(-1.0).encloses(zeichen), "▼ ragt aus dem Kasten: %s in %s" % [zeichen, kr])
		var f := t.get_theme_font("font") as FontVariation
		var schraeg: bool = not z.has("wer")
		pruefe(f != null, "Textschrift ohne Variante")
		if f:
			var soll := Transform2D(Vector2(1.0, 0.2), Vector2(0.0, 1.0), Vector2.ZERO) if schraeg else Transform2D()
			pruefe(f.variation_transform.is_equal_approx(soll), "%s: Neigung %s statt %s" % ["Erzählt" if schraeg else "Gesprochen", f.variation_transform, soll])
	print("TEXTKASTEN583 %d Fehler" % fehler)
	quit(1 if fehler else 0)
