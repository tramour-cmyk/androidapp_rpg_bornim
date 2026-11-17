extends SceneTree
# 526 (Abgleich Build 249; alt Dialogs.kt ConfirmDialog .tap(onDismiss), SlotsScreen und AboutScreen BackHandler): ohne Bild;
# Rueckfragen schliessen bei einem Tippen daneben, nicht bei einem Tippen in den Kasten; Android-Zurueck schliesst erst das
# Fenster, das Menue darunter bleibt. Geprueft: Menue-Rueckfrage, „Spielstand löschen?“, „Überspringen?“ der Zwischensequenz,
# „Über das Spiel“. Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/rueckfrage_526.gd -> „RUECKFRAGE n Fehler“

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll: fehler += 1; print("FEHLER %s: %s statt %s" % [was, ist, soll])
	else: print("gut %s" % was)

func tippe(p: Vector2) -> void:
	for an in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT; e.pressed = an; e.position = p; e.global_position = p
		root.push_input(e)
		await process_frame
	await process_frame

func offen(n) -> bool: return is_instance_valid(n) and n.is_inside_tree() and not n.is_queued_for_deletion()

func schleier_von(n: Node) -> ColorRect:
	var s: ColorRect = null
	for c in n.get_children():
		if c is ColorRect and c.is_in_group(Zurueck.GRUPPE) and offen(c): s = c
	return s

func kasten_in(s: Node) -> Control:
	# 557 Stil B: Rueckfragen ohne Kasten; was Rueckfrage.halte haelt, ist der Kasten (sonst traefe der erste Knopf)
	for c in s.find_children("*", "Control", true, false): if c.has_meta("haelt"): return c
	for c in s.find_children("*", "PanelContainer", true, false): return c
	return null

# Tippen in den Kasten (neben die Knoepfe), dann daneben; danach Zurueck auf einer frischen Kopie
func pruefe_fenster(name_: String, oeffne: Callable, eltern: Node) -> void:
	oeffne.call()
	await process_frame; await process_frame
	var s := schleier_von(eltern)
	pruefe(name_ + ": Schleier da", s != null, true)
	if s == null: return
	var k := kasten_in(s)
	var r := k.get_global_rect()
	await tippe(r.position + Vector2(r.size.x * 0.5, 6))   # oberer Rand des Kastens, ueber dem Titel
	pruefe(name_ + ": Tippen in den Kasten laesst offen", offen(s), true)
	await tippe(Vector2(r.position.x + r.size.x * 0.5, r.end.y + (root.size.y - r.end.y) * 0.5))   # unter dem Kasten
	pruefe(name_ + ": Tippen daneben schliesst", offen(s), false)
	oeffne.call()
	await process_frame
	s = schleier_von(eltern)
	pruefe(name_ + ": Zurück nimmt das Fenster", Zurueck.taste(self), true)
	await process_frame
	pruefe(name_ + ": Zurück schliesst es", offen(s), false)

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	root.size = Vector2i(1080, 2340)
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Mira", "Mensch", "Wachsoldat", z.neue_uid)
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	var zu := [0]
	m.zu.connect(func(): zu[0] += 1)
	await pruefe_fenster("Menü-Rückfrage", func(): m.dialog("Probe", Stil.GOLD, [Stil.txt("Zeile", 15)], [["OK", func(): pass]]), m)
	pruefe("Menü bleibt offen", [offen(m), zu[0]], [true, 0])
	m.queue_free()
	await process_frame
	var st := Spielstaende.new()
	root.add_child(st)
	await process_frame
	await pruefe_fenster("Spielstand löschen?", func(): st.frage_loeschen({"held": {"name": "Mira", "stufe": 2}}), st)
	st.queue_free()
	var hm := Hauptmenue.new(null)
	Hauptmenue.vorspann_gezeigt = true
	root.add_child(hm)
	await process_frame
	hm.ueber()
	await process_frame
	var seite: Node = hm.get_child(hm.get_child_count() - 1)
	pruefe("Über das Spiel: Zurück nimmt die Seite", Zurueck.taste(self), true)
	await process_frame
	pruefe("Über das Spiel: Zurück schliesst sie", offen(seite), false)
	pruefe("Hauptmenü bleibt", offen(hm), true)
	hm.queue_free()
	if Zwischenbild.da():
		var zb := Zwischenbild.new("tempel")
		root.add_child(zb)
		await process_frame
		zb.frage()
		await process_frame
		var f = zb.fragt
		var r := kasten_in(f).get_global_rect()
		await tippe(r.position + Vector2(r.size.x * 0.5, 6))
		pruefe("Überspringen?: Tippen in den Kasten laesst offen", [offen(f), zb.vorbei], [true, false])
		await tippe(Vector2(r.position.x + r.size.x * 0.5, r.end.y + (root.size.y - r.end.y) * 0.5))
		pruefe("Überspringen?: Tippen daneben heisst weiter ansehen", [offen(f), zb.fragt == null, zb.vorbei], [false, true, false])
		zb.frage()
		await process_frame
		pruefe("Überspringen?: Zurück", [Zurueck.taste(self), zb.vorbei], [true, false])
		await process_frame
		pruefe("Überspringen?: Zurück heisst weiter ansehen", zb.fragt == null, true)
		zb.queue_free()
	print("RUECKFRAGE %d Fehler" % fehler)
	quit(1 if fehler else 0)
