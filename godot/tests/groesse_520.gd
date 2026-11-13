extends SceneTree
# 520 (Chef 03.11., 23:19 „Warum ist der Held so klein?“, 23:21 „Größe jetzt“): Spielmenue, Reiter Ausruestung: der Held auf dem
# Drehteller so gross wie PaperDoll alt (GearUi.kt 274, HeroTurntable 1,1 dp × 150 × 230 = 165 × 253 dp), die Faecher links und
# rechts daneben, nichts ragt aus dem Schirm. Ohne Bildbefehl. Aufruf: im Ordner godot mit -s res://tests/groesse_520.gd -> „GROESSE520 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)   # Handy hochkant wie das Projekt
	await process_frame
	Sprache.lade()
	var z := Zustand.new()
	z.name = "Mira"
	var hw := BrsHeld.fuer_spiel("Mira", "Mensch", "Zauberlehrling", z.neue_uid)
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	m.reiter = "ausruestung"; m.baue()
	for i in 3: await process_frame
	var teller: Array = m.find_children("*", "Drehteller", true, false)
	pruefe(teller.size() == 1, "kein Drehteller im Reiter Ausrüstung")
	if teller.size() == 1:
		var t: Control = teller[0]
		var r := t.get_global_rect()
		var soll := Vector2(150, 230) * 1.1 * AktionsKnopf.DP
		print("Drehteller %s, soll %s" % [r.size, soll])
		pruefe(r.size.x >= soll.x - 1 and r.size.y >= soll.y - 1, "Held kleiner als alt: %s statt %s" % [r.size, soll])
		var puppe: Control = t.get_parent()
		var pr := puppe.get_global_rect()
		pruefe(pr.position.x >= 0 and pr.end.x <= m.get_viewport_rect().size.x + 0.5, "Faecher und Held ragen aus dem Schirm: %s" % pr)
		for c in puppe.get_children(): pruefe((c as Control).get_global_rect().end.x <= m.get_viewport_rect().size.x + 0.5, "%s ragt rechts hinaus" % c.name)
	print("GROESSE520 %d Fehler" % fehler)
	quit(1 if fehler else 0)
