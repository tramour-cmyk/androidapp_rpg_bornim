# 399.2b (Tom 28.10., 15:05: „Rudel allein“ verliert 3 von 4 Klassen): Messung ohne Bild, nur die Regeln (mars.gd) wie im
# Kampfort aus dem Aufruf (aufruf.gd starte, kampfort.gd setup): je Klasse ein neu erschaffener Held (Stufe 1, Toms
# skripte/heldwerte.gd und daten/held.json aus 399.1), ohne Söldner, 2 Heiltränke, auf Autopilot (er wehrt „gut“ ab, mars.gd
# _foe_turn), unter einem Drittel LP greift er den ersten erreichbaren Gegner an (wie aufruf_399); N Würfe gegen den Wolf allein
# und gegen das Rudel (aufruf.gd rudel).
# Run: godot --headless --path godot -s res://tests/rudel_mess.gd   (druckt eine Tabelle, Exit 0; ohne Toms Dateien Exit 0 mit Hinweis)
extends SceneTree

const Aufruf = preload("res://kampf/aufruf.gd")
const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const N := 300


func _initialize() -> void:
	if not (FileAccess.file_exists("res://skripte/heldwerte.gd") and FileAccess.file_exists("res://daten/held.json")):
		print("Heldwerte fehlen (vor 399.1): keine Messung")
		quit(0)
		return
	var HW = load("res://skripte/heldwerte.gd")
	var tab: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	var skills := {}
	for s in tab.skills:
		skills[s.id] = s
	var monsters := {}
	for m in tab.monsters:
		monsters[m.id] = m
	var a = Aufruf.new()
	print("Klasse   Gegner  Siege  LP-Rest bei Sieg")
	for k in ["FIGHTER", "WIZARD", "ROGUE", "CLERIC"]:
		for gegner in ["WOLF", "RUDEL"]:
			var siege := 0
			var rest := 0
			for s in N:
				var foes: Array = Aufruf.rudel(monsters, Wuerfel.new(s * 7 + 1))
				if gegner == "WOLF":
					foes = [foes[0]]
				var hero = a._kaempfer("hero", HW.erschaffe("Alrik", "HUMAN", k), -1, Vector2i(Mars.FRONT, 0), skills)
				var mars = Mars.new([hero], foes, tab, Wuerfel.new(s * 7 + 2), Wuerfel.new(s * 7 + 281), 0, false)
				mars.potions["potion"] = 2
				var react := func(_t, _i): return Mars.NONE
				mars.start(react)
				var z := 0
				while mars.outcome == "ONGOING" and z < 400:
					z += 1
					if mars.pilot_next() or mars.set_autopilot(true):
						mars.proceed(react)
						continue
					var ts: Array = mars.targets(mars.current())
					mars.act(["attack", ts[0].id] if not ts.is_empty() else ["wait"], react)
				if mars.outcome == "WON":
					siege += 1
					rest += hero.hp
			print("%-8s %-7s %4d%%  %5.1f" % [k, gegner, siege * 100 / N, float(rest) / maxi(1, siege)])
	a.free()
	quit(0)
