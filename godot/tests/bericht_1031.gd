extends SceneTree
# 1031 (Chef 12.11., 14:08, Build 280: im ganzen Bericht „ist alles nur weiß“): der ganze Bericht trägt dieselben Farben wie die Zeilen
# über dem Kampfort: Eingebung in Gold, „n Schaden“ hervorgehoben, übrige Zeilen in Text. Kampf mit Wölfen, drei Zeilen dazu,
# Bericht öffnen, im RichTextLabel die Farben lesen. Aufruf: im Ordner godot mit -s res://tests/bericht_1031.gd
const Aufruf = preload("res://kampf/aufruf.gd")
const Ui = preload("res://kampf/kampf_ui.gd")

func _initialize() -> void: _lauf.call_deferred()

func _rtl(n: Node) -> RichTextLabel:
	if n is RichTextLabel: return n
	for c in n.get_children():
		var r := _rtl(c)
		if r: return r
	return null

func _lauf() -> void:
	var f := 0
	var tab = Tabellen.lade()
	var held: Dictionary = tab.probe.FIGHTER.hero
	var a = Aufruf.new()
	root.add_child(a)
	if not a.starte("WOLVES", held.hero, null, "wald", "tag", 2, int(held.hp), -1, 7, Callable(), {"eroeffnung": "HERO_FIRST"}):
		print("FEHLER nicht gestartet"); quit(1); return
	for i in 3:
		await process_frame
	var ui = a.kampf.ui
	ui.log_line("Ein Gedanke [zu] dir: der Wolf springt.", true)
	ui.log_line("Alrik trifft Wolf 1: 7 Schaden.")
	ui.log_line("Wolf 2 knurrt.")
	ui._show_full_log(true)
	await process_frame
	var r := _rtl(ui.full_log)
	if r == null:
		print("FEHLER kein Text im Bericht"); quit(1); return
	var bb: String = r.text
	var gold: String = "[color=#%s]" % Ui.EINGEBUNG_FARBE.to_html(false)
	var hell: String = "[color=#%s]" % Ui.BRIGHT.to_html(false)
	var text: String = "[color=#%s]" % Ui.TEXT.to_html(false)
	var zeilen := bb.split("\n")
	var z_eing := ""
	var z_schaden := ""
	var z_knurr := ""
	for z in zeilen:
		if z.contains("Gedanke"): z_eing = z
		if z.contains("trifft Wolf 1"): z_schaden = z
		if z.contains("knurrt"): z_knurr = z
	print("bbcode an: %s, Zeilen %d / %d" % [r.bbcode_enabled, zeilen.size(), ui.lines.size()])
	print("Eingebung: %s" % z_eing)
	print("Schaden:   %s" % z_schaden)
	print("Knurren:   %s" % z_knurr)
	print("sichtbar:  %s" % r.get_parsed_text().split("\n")[0].left(80))
	if not r.bbcode_enabled or zeilen.size() != ui.lines.size(): f += 1
	if not z_eing.begins_with(gold) or z_eing.contains(text) or not r.get_parsed_text().contains("Ein Gedanke [zu] dir"): f += 1
	if not z_schaden.begins_with(text) or not z_schaden.contains(hell + "7 Schaden."): f += 1
	if not z_knurr.begins_with(text) or z_knurr.contains(hell): f += 1
	# Lesbarkeit: keine Zeile im ganzen Bericht gedimmt (wie alt LogLine(l, true))
	if bb.contains("[color=#%s]" % Ui.DIM.to_html(false)): f += 1
	a.kampf.queue_free()
	a.queue_free()
	await process_frame
	print("BERICHT1031 %s" % ("ok" if f == 0 else "FEHLER %d" % f))
	quit(f)
