extends SceneTree
# 1144 Film (Chef 13.11., 14:49, Lyra in Graks Halle; Prüfart Film): nach Grak Lyra ansprechen; zur Zeile „Die Ketten fallen klirrend
# zu Boden“ der Klang (im Film nicht hörbar, Zeile KLANG aus dem Protokoll), Lyra reibt die Handgelenke, die Arme sinken; dann spricht
# sie (Zeilen weiter wie ein Spieler, je 2,5 s), erst danach geht sie zum Gitter. Nur mit Fenster, Kaufdaten und --write-movie, im
# Ordner godot (godot.yml „Kettenfilm (1144)“ bei „1144 Film“ im Commit).

var spiel: Node
var titel: Label


func warte(s: float) -> void:
	for i in int(s * 30.0): await process_frame


func _lauf() -> void:
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	await warte(0.5)
	var st := Testmodus.station("Lyra", spiel.zustand)
	if st.is_empty():
		print("FILM1144 keine Station Lyra"); quit(1); return
	spiel.zustand.setze(Geschichte.GRAK_DEFEATED)
	if spiel.zustand.anzahl("grak_key") < 1: spiel.zustand.dazu("grak_key")
	spiel.zustand.flaggen.erase(Geschichte.LYRA_RESCUED)
	spiel.zustand.flaggen.erase(Geschichte.LYRA_GONE)
	spiel.betrete(st[0], st[1], st[2])
	await warte(2.0)
	for n in ["mess", "oben", "leiste"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	spiel.ui.sage([])
	if not spiel.kamera.nah: spiel.kamera.nah_fern()
	var lyra: Node3D = null
	for l in spiel.leute.get_children():
		if String(l.daten.get("id", "")) == "lyra_cave": lyra = l
	if lyra == null or not lyra.visible or lyra.modell == null:
		print("FILM1144 keine Lyra in der Halle"); quit(1); return
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
	titel.text = "1144 · Lyra vor dem Schlüssel"
	await warte(1.5)
	spiel.sprich(lyra)
	titel.text = "1144 · Ketten fallen (Klang), Lyra reibt die Handgelenke"
	await warte(3.5)
	var k = root.get_node_or_null("Klang")
	if k: print("KLANG ", ", ".join(PackedStringArray(k.protokoll.map(func(p): return "%s %s" % [p.was, p.grund]))))
	titel.text = "1144 · Lyra spricht"
	var n := 0
	while spiel.ui.spricht() and n < 20:
		spiel.ui.naechste()
		n += 1
		await warte(2.5)
	titel.text = "1144 · Lyra geht"
	await warte(5.0)
	print("FILM1144 fertig, %d Zeilen, frei %s" % [n, spiel.zustand.has(Geschichte.LYRA_RESCUED)])
	quit(0)


func _initialize() -> void:
	_lauf.call_deferred()
