extends SceneTree
# 814 (Chef 11.11., 16:14: „der Held steht direkt beim Hühnchen. Da passiert halt einfach wieder nichts“): am Rechner nachgestellt
# (huhn_814, ohne Kaufmodelle mit leerem Fell): zwei Wege, auf denen ein Huhn neben dem Helden nicht aufschreckte.
#  1. eingeklemmt: Huhn in der Ecke am Stall (Bäume, Wasser, das zweite Huhn, die Leine), Held auf der offenen Seite: keine
#     Fluchtkachel, fliehe() gab ohne flucht auf (kein Laut, keine Federn, keine Haltung)
#  2. unterwegs: _process prüfte fliehe() nur, wenn kein Ziel gesetzt war; ein Huhn auf seinem langsamen Streifgang floh nicht
# Prüft: in beiden Fällen ist das Huhn nach wenigen Bildern aufgeschreckt (flucht), eingeklemmt steht es wachsam („Stehen“),
# unterwegs läuft es eine Kachel weg vom Helden. Ausgabe „HUHNFLUCHT814 n Fehler“, Ende 1 bei Fehlern.
#   ~/godot/godot --headless --path . -s res://tests/huhnflucht_814.gd

var spiel
var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok: fehler += 1
	print(("ok      " if ok else "FEHLER  ") + was)

func _initialize() -> void:
	_lauf.call_deferred()

func huehner() -> Array:
	return spiel.leute.get_children().filter(func(l): return l is Leute and String(l.daten.get("tier", "")) == "huhn")

func _lauf() -> void:
	var leer := not DirAccess.dir_exists_absolute("res://daten/dorftiere")
	if leer:
		# ohne Kaufmodelle (am Rechner): ein leeres Fell, damit dorftiere() Hühner setzt (Modell fehlt, die Regeln laufen)
		DirAccess.make_dir_recursive_absolute("res://daten/dorftiere")
		FileAccess.open("res://daten/dorftiere/kauf_huhn-test.bin", FileAccess.WRITE).close()
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 10 * 60
	spiel.betrete("village", Vector2i(17, 5), "UP")
	for i in 10: await process_frame
	var k: Karte = spiel.karte
	var alle := huehner()
	pruefe(alle.size() > 0, "Hühner im Dorf: %d" % alle.size())
	# 1. eingeklemmt: ein Huhn und eine Nachbarkachel des Helden, von der aus es keine Fluchtkachel hat
	var fall := []
	for h in alle:
		for d in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)]:
			if fall.is_empty() and k.begehbar(h.kachel + d) and h.ziel.x < 0:
				spiel.held.setze(h.kachel + d, "RIGHT")
				if h.flucht_kachel().x < 0: fall = [h, d]
	pruefe(not fall.is_empty(), "eingeklemmtes Huhn gefunden")
	if not fall.is_empty():
		var h: Leute = fall[0]
		spiel.held.setze(h.kachel + fall[1], "RIGHT")
		for i in 10: await process_frame
		print("HUHNFLUCHT814 eingeklemmt: Huhn %s, Held %s, Abstand %.2f, flucht %s, Fluchtkachel %s, pause %s" % [h.kachel, spiel.held.kachel,
			h.held_abstand(), h.flucht, h.flucht_kachel(), h.pause])
		pruefe(h.flucht, "eingeklemmt: aufgeschreckt (flucht)")
		pruefe(h.ziel.x < 0 or h.flucht_kachel().x >= 0, "eingeklemmt: läuft nicht ohne Fluchtkachel")
		pruefe(h.pause == "Stehen", "eingeklemmt: steht wachsam (Stehen, nicht Fressen)")
		# Held weit weg: wieder ruhig
		spiel.held.setze(Vector2i(17, 5), "UP")
		for i in 10: await process_frame
		pruefe(not h.flucht, "Held weg: nicht mehr auf der Flucht")
	# 2. unterwegs: ein Huhn langsam auf dem Weg zu einer Nachbarkachel, der Held kommt neben es
	var u: Leute = null
	var ziel_k := Vector2i(-1, -1)
	for h in alle:
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			if u == null and h.frei_fuer_mich(h.kachel + d) and k.begehbar(h.kachel - d) and h.kachel - d != h.kachel + d:
				u = h; ziel_k = h.kachel + d
	pruefe(u != null, "Huhn für den Streifgang gefunden")
	if u:
		spiel.held.setze(Vector2i(17, 5), "UP")
		for i in 5: await process_frame
		u.gang = 0.05   # langsam wie ein Huhn mit Kaufmodell, eine Kachel dauert viele Sekunden
		u.flucht = false
		u.ziel = ziel_k
		var start: Vector2i = u.kachel
		var von: Vector2i = start + (start - ziel_k)   # hinter dem Huhn, es geht vom Helden weg; die Flucht muss trotzdem kommen
		spiel.held.setze(von, "RIGHT")
		for i in 10: await process_frame
		print("HUHNFLUCHT814 unterwegs: Huhn %s -> %s, Held %s, Abstand %.2f, flucht %s, ziel %s" % [start, ziel_k, spiel.held.kachel,
			u.held_abstand(), u.flucht, u.ziel])
		pruefe(u.flucht, "unterwegs: aufgeschreckt (flucht)")
	print("HUHNFLUCHT814 %d Fehler" % fehler)
	if leer:
		DirAccess.remove_absolute("res://daten/dorftiere/kauf_huhn-test.bin")
		DirAccess.remove_absolute("res://daten/dorftiere")
	quit(1 if fehler else 0)
