extends SceneTree
# 503 (Chef 03.11., 23:17/23:18, Build 249: „Rückfragen war an, trotzdem keine Rückfrage“ beim Verkaufen der gewöhnlichen Dinge):
# wie im Spiel: Laden auf eigener Ebene (spiel.gd 1055), Knopf „Gewöhnliche verkaufen“ mit echtem Antippen (Maus ab und auf an seiner
# Mitte, wie ein Finger), nicht pressed.emit; danach muss die Rueckfrage zu sehen sein und noch nichts verkauft.
# Ohne Bildbefehl. Aufruf: im Ordner godot mit -s res://tests/rueckfrage_503.gd -> „RUECKFRAGE503 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func knoepfe(n: Node, aus: Array) -> Array:
	if n is Button: aus.append(n)
	for c in n.get_children(): knoepfe(c, aus)
	return aus

func tippe(p: Vector2) -> void:
	for gedrueckt in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT; e.pressed = gedrueckt; e.position = p; e.global_position = p
		root.push_input(e)
		await process_frame

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	await process_frame
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	Bedienung.lade()
	print("Rückfragen ", Bedienung.rueckfragen)
	var z := Zustand.new()
	z.name = "Thora"; z.gold = 100
	var hw := Heldwerte.erschaffe("Thora", "HUMAN", "FIGHTER", {}, z.neue_uid)
	for i in 3: z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(70 + i), z.neue_uid, 2, "COMMON", ""))
	var vorher := z.beutel.size()
	var ebene := CanvasLayer.new(); ebene.layer = 40
	root.add_child(ebene)
	var l := LadenSchirm.new(hw, z, Laden.new(["potion"], false))
	ebene.add_child(l)
	for i in 3: await process_frame
	l.seite = "verkaufen"; l.baue()
	for i in 3: await process_frame
	var knopf: Button = null
	for b in knoepfe(l, []):
		if (b as Button).text == "GEWÖHNLICHE VERKAUFEN": knopf = b
	pruefe(knopf != null, "Knopf fehlt")
	if knopf:
		l.rolle.ensure_control_visible(knopf)
		for i in 3: await process_frame
		var r := knopf.get_global_rect()
		print("Knopf ", r, " sichtbar ", knopf.is_visible_in_tree())
		await tippe(r.get_center())
		for i in 3: await process_frame
		var titel := l.find_children("*", "Label", true, false).filter(func(x): return (x as Label).text.to_upper() == "ALLE GEWÖHNLICHEN VERKAUFEN?" and (x as Label).is_visible_in_tree())
		pruefe(not titel.is_empty(), "keine Rückfrage nach dem Antippen")
		pruefe(z.beutel.size() == vorher, "schon verkauft ohne Rückfrage: %d → %d" % [vorher, z.beutel.size()])
	print("RUECKFRAGE503 %d Fehler" % fehler)
	quit(1 if fehler else 0)
