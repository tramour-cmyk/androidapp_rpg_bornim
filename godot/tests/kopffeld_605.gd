extends SceneTree
# 605 (Chef 08.11., 15:57, t269.16: aus leerem Kopffeld die göttliche Kapuze gewaehlt: nur „Wegwerfen“, kein „Anlegen“, kein Zurueck):
# leeres Kopffeld, ein goettliches Stueck mit vielen Boni waehlen; Abbrechen, Anlegen und Wegwerfen muessen ganz im Bild liegen.
# Ohne Bild. Aufruf im Ordner godot: headless, -s res://tests/kopffeld_605.gd

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func warte(n := 3) -> void:
	for i in n: await process_frame

func tippe(p: Vector2) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT; e.pressed = true; e.position = p; e.global_position = p
	e.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(e); await process_frame
	e = e.duplicate(); e.pressed = false; e.button_mask = 0
	root.push_input(e); await warte(4)

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	# wie beim Chef (Bild t268-kopffeld): ein anderes Stueck fuellt die Obergrenze schon, jedes Attribut bekommt im Vergleich eine Notiz
	# in zwei Zeilen, das Fenster wird hoeher als der Schirm
	for klasse in ["Wachsoldat", "Herumtreiber", "Zauberlehrling", "Klosterschüler"]:
		for id in Beute.grundformen():
			if String(Beute.grundform(id)["slot"]) != "HEAD": continue
			var z := Zustand.new()
			var hw := BrsHeld.fuer_spiel("Thora", "Mensch", klasse, z.neue_uid)
			hw.anlegen({"uid": z.neue_uid.call(), "base": "amulet", "rarity": "RARE", "ilvl": 1, "plus": 0, "rolls": [["ALL_STATS", 1]], "unique": null, "name_seed": 0})
			var g := Beute.wuerfle(z.neue_uid.call(), id, 8, "DIVINE", KotlinZufall.new(5))
			z.beutel.append(g)
			var m := Menue.new(hw, z)
			root.add_child(m)
			m.reiter = "ausruestung"; m.baue()
			await warte(4)
			m.waehle("HEAD"); await warte(4)
			var schirm := m.get_child(m.get_child_count() - 1)
			var zeile: Control = null
			for k in schirm.find_children("*", "PanelContainer", true, false):
				if not k.has_meta("knopf") and k.mouse_filter != Control.MOUSE_FILTER_IGNORE and k.get_child_count() > 0 and k.get_child(0) is MarginContainer: zeile = k; break
			if zeile == null:
				pruefe(false, "%s %s: keine Zeile in der Wechselliste" % [klasse, id]); m.queue_free(); await warte(); continue
			await tippe(zeile.get_global_rect().get_center())
			var fen := m.get_child(m.get_child_count() - 1)
			await warte(3)
			var vp := Rect2(Vector2.ZERO, Vector2(root.size))
			var haupt: Control = null
			for art in ["haupt", "neben", "gefahr"]:
				var kn: Control = null
				for k in fen.find_children("*", "PanelContainer", true, false):
					if String(k.get_meta("knopf", "")) == art: kn = k
				var r := kn.get_global_rect() if kn else Rect2()
				if art == "haupt": haupt = kn
				pruefe(kn != null and vp.encloses(r), "%s %s „%s“ (%d Boni, tragbar %s): Knopf %s im Bild %s" % [klasse, id, Beute.name(g), g["rolls"].size(), hw.kann_tragen(g), art, r])
			var rolle := fen.find_child("Rolle", true, false) as ScrollContainer
			pruefe(rolle != null, "%s %s: Inhalt in einer Rolle" % [klasse, id])
			# 701: ohne die sechs Hinweise auf die Obergrenze passt das Fenster meist ganz; sonst rollt es, das Ende ist erreichbar
			if rolle and hw.kann_tragen(g):
				pruefe(rolle.get_v_scroll_bar().max_value <= rolle.size.y + 1 or rolle.vertical_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED,
					"%s %s: der Inhalt passt oder rollt (%d von %d px sichtbar)" % [klasse, id, rolle.size.y, rolle.get_v_scroll_bar().max_value])
			if haupt and hw.kann_tragen(g):
				await tippe(haupt.get_global_rect().get_center())
				pruefe(hw.ding("HEAD") != null and int(hw.ding("HEAD")["uid"]) == int(g["uid"]), "%s %s: ein Tipp auf Anlegen legt an" % [klasse, id])
			m.queue_free(); await warte()
	print("KOPFFELD605 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
