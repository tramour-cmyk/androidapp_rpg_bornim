extends SceneTree
# 785.8 ohne Bild: Lagerfeuer und Ziel eines Aushangs auf der Karte im Menü wie alt (MapMarks.of, MapPeople.services).
# Ein Lagerfeuer erscheint, sobald der Held die Kachel sah; das Ziel eines angenommenen Aushangs (Gwennas Ring in der Truhe
# cave_3, Jorins Fetzen in der Mitte des Steinkreises), sobald er die Stelle sah, verblasst, wenn erledigt. Lagerfeuer unter
# „Dienste“, Ziel unter „Aufträge“. Maßgeblich ist die Zeile KARTENMARKEN7858.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

func sieh(z: Zustand, id: String, kacheln: Array) -> void:
	var k: Dictionary = Kartenreiter._karten()[id]
	var w := int(k["breite"]); var h := int(k["hoehe"])
	var ek := Nebel.lade(z, id, w * h)
	for p in kacheln: ek[p.y * w + p.x] = 1
	var s := ""
	var i := 0
	while i < ek.size():
		var v := 0
		for b in 4:
			if i + b < ek.size() and ek[i + b] == 1: v |= 1 << b
		s += "%x" % v
		i += 4
	z.erkundet[id] = s

func marken(z: Zustand, karte: String) -> Array:
	var r := Kartenreiter.new(z, {"karte": karte, "x": 1, "y": 1}, 600.0, Callable())
	var m := r.zeichen()
	r.free()
	return m

func hat(ms: Array, art: String, x: int, y: int) -> Dictionary:
	for m in ms:
		if m["art"] == art and int(m["x"]) == x and int(m["y"]) == y: return m
	return {}

func _lauf() -> void:
	Sprache.lade()
	pruefe(Kartenreiter.ziel_von("ring") == {"karte": "cave", "x": 4, "y": 14}, "Ziel Ring: Truhe cave_3 bei (4, 14)")
	pruefe(Kartenreiter.ziel_von("stones") == {"karte": "forest", "x": 14, "y": 25}, "Ziel Fetzen: Mitte des Steinkreises (14, 25)")
	pruefe(Kartenreiter.ziel_von("pelts").is_empty(), "Felle ohne festes Ziel")
	pruefe(Kartenreiter.feuer().size() == 3, "drei Lagerfeuer (Wald, Tiefer Wald, Höhle)")
	var z := Zustand.new()
	pruefe(hat(marken(z, "forest"), "FIRE", 11, 9).is_empty(), "Lagerfeuer im Wald ungesehen: kein Zeichen")
	sieh(z, "forest", [Vector2i(11, 9)])
	pruefe(not hat(marken(z, "forest"), "FIRE", 11, 9).is_empty(), "Lagerfeuer im Wald gesehen: Zeichen")
	z.setze("job_stones")
	pruefe(hat(marken(z, "forest"), "GOAL", 14, 25).is_empty(), "Steinkreis ungesehen: kein Ziel")
	sieh(z, "forest", [Vector2i(11, 9), Vector2i(14, 25)])
	var g := hat(marken(z, "forest"), "GOAL", 14, 25)
	pruefe(not g.is_empty() and not g.get("fertig", false), "Aushang angenommen, Steinkreis gesehen: Ziel, nicht verblasst")
	z.setze("job_stones_done")
	g = hat(marken(z, "forest"), "GOAL", 14, 25)
	pruefe(not g.is_empty() and g.get("fertig", false), "Aushang erledigt: Ziel verblasst")
	z.setze("job_ring")
	sieh(z, "cave", [Vector2i(4, 14)])
	pruefe(not hat(marken(z, "cave"), "GOAL", 4, 14).is_empty(), "Ring angenommen, Truhe gesehen: Ziel in der Höhle")
	var z2 := Zustand.new()
	sieh(z2, "cave", [Vector2i(4, 14)])
	pruefe(hat(marken(z2, "cave"), "GOAL", 4, 14).is_empty(), "Ring nicht angenommen: kein Ziel")
	# Schalter: Feuer unter Dienste, Ziel unter Aufträge
	var r := Kartenreiter.new(z, {"karte": "forest", "x": 1, "y": 1}, 600.0, Callable())
	r.schalter["SERVICES"] = false
	pruefe(hat(r.zeichen(), "FIRE", 11, 9).is_empty() and not hat(r.zeichen(), "GOAL", 14, 25).is_empty(), "Dienste aus: kein Feuer, Ziel bleibt")
	r.schalter["SERVICES"] = true; r.schalter["QUESTS"] = false
	pruefe(not hat(r.zeichen(), "FIRE", 11, 9).is_empty() and hat(r.zeichen(), "GOAL", 14, 25).is_empty(), "Aufträge aus: Feuer bleibt, kein Ziel")
	r.free()
	# Zeichnen und Antippen ohne Fehler
	var r2 := Kartenreiter.new(z, {"karte": "forest", "x": 12, "y": 10, "blick": "UP"}, 600.0, Callable())
	r2.size = Vector2(400, 700)
	root.add_child(r2)
	for f in 4: await process_frame
	r2.flaeche.queue_redraw()
	await process_frame
	r2.flaeche.tippe(r2.flaeche.an(11, 9))
	pruefe(r2.tipp_kasten != null, "Antippen des Lagerfeuers nennt es")
	print("KARTENMARKEN7858 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
