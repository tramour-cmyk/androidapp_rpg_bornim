extends SceneTree
# 581 (Abgleich 512b, Pruefer 05.11., 08:17): Reiter Ausruestung war breiter als der Schirm (Rand 11 statt 27 px), die Reiter
# sprangen beim Wechsel. Ohne Bild gemessen: in jedem Reiter liegt der Inhalt ganz im Kasten, der Rand bleibt 10 dp und die
# Reiterzeichen stehen in jedem Reiter an derselben Stelle. Braucht godot/daten wie im Bau. Aufruf: im Ordner godot,
# --headless -s res://tests/menue_breite_581.gd

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(was: String, gut: bool, wie := "") -> void:
	if not gut: fehler += 1; print("FEHLER %s %s" % [was, wie])

const PLAETZE := ["HEAD", "CLOAK", "CHEST", "ARMS", "LEGS", "AMULET", "RING", "MAIN_HAND", "OFF_HAND"]

# je Platz das Stueck mit dem laengsten Namen goettlich anlegen, je Platz drei weitere in den Beutel
func voll(hw: BrsHeld, z: Zustand) -> void:
	for platz in PLAETZE:
		var best := {}
		for id in Beute.grundformen():
			if String(Beute.grundform(id)["slot"]) != platz: continue
			for s in 4:
				var g := Beute.wuerfle(z.neue_uid.call(), id, 8, "DIVINE", KotlinZufall.new(s))
				if not hw.kann_tragen(g): z.beutel.append(g); continue
				if best.is_empty() or Beute.name(g).length() > Beute.name(best).length(): best = g
				if z.beutel.size() < 120: z.beutel.append(g)
		if not best.is_empty() and not (platz == "OFF_HAND" and hw.waffe() != null and bool(Beute.grundform(String(hw.waffe()["base"]))["zweihaendig"])):
			z.beutel.erase(best); hw.anlegen(best)

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	# 581 (zurueck t269): auch voll ausgeruestet wie beim Chef (goettliche Stuecke mit langen Namen an jedem Platz, Beutel voll)
	for held in [["Thora", "Zwerg", "Wachsoldat", false], ["Mira", "Elf", "Zauberlehrling", false], ["Voll", "Mensch", "Wachsoldat", true], ["Vollmagier", "Elf", "Zauberlehrling", true]]:
		var hw := BrsHeld.fuer_spiel(held[0], held[1], held[2], z.neue_uid)
		if held[3]: voll(hw, z)
		var m := Menue.new(hw, z)
		root.add_child(m)
		var lage := []
		for r in ["held", "tasche", "ausruestung", "chronik", "system"]:
			m.reiter = r; m.baue()
			for i in 6: await process_frame
			var rand := 24 * Menue.DP   # 630 (549a „Schirm“): Seitenrand 24 dp, ohne Kasten
			var kasten: Rect2 = m.rolle.get_global_rect()
			pruefe("Rand links", absf(kasten.position.x - rand) <= 1.0, "%s %s: %.0f statt %.0f px" % [held[0], r, kasten.position.x, rand])
			pruefe("Rand rechts", absf(1080.0 - kasten.end.x - rand) <= 1.0, "%s %s: %.0f statt %.0f px" % [held[0], r, 1080.0 - kasten.end.x, rand])
			var ri: Rect2 = m.inhalt.get_global_rect()
			var rr: Rect2 = m.rolle.get_global_rect()
			pruefe("Inhalt im Kasten", ri.position.x >= rr.position.x - 0.5 and ri.end.x <= rr.end.x + 0.5, "%s %s: Inhalt %.0f–%.0f, Kasten %.0f–%.0f" % [held[0], r, ri.position.x, ri.end.x, rr.position.x, rr.end.x])
			lage.append(m.leiste.get_children().map(func(k): return int(round(k.get_global_rect().position.x))))
		for i in range(1, lage.size()):
			pruefe("Reiter springen", lage[i] == lage[0], "%s: %s gegen %s" % [held[0], str(lage[i]), str(lage[0])])
		if held[3]:
			m.reiter = "ausruestung"; m.baue()
			for i in 6: await process_frame
			for platz in PLAETZE:
				m.waehle(platz)
				for i in 6: await process_frame
				var schirm: Control = m.get_child(m.get_child_count() - 1)
				for k in schirm.find_children("*", "Control", true, false):
					if not k.is_visible_in_tree(): continue
					var r: Rect2 = k.get_global_rect()
					if r.position.x < -0.5 or r.end.x > 1080.5:
						pruefe("Wechselschirm breiter als der Schirm", false, "%s %s: %s %.0f–%.0f px" % [held[0], platz, k.get_class(), r.position.x, r.end.x]); break
				schirm.queue_free()
				for i in 2: await process_frame
		m.queue_free()
		await process_frame
	print("MENUEBREITE581 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
