extends SceneTree
# 1484a ohne Bild: Welt in Zellen (dorf.py ZELLE, gebiet.gd baue_zellen). Je Gebietskarte (Dorf, Wald, Tiefer Wald): das alte
# „Dorf_Netz“ ist ein Knoten mit mehreren Zellen, die Zellen teilen sich die Stoffe, die Durchsicht (next_pass) zeichnen nur Zellen
# nahe der Linie Held–Kamera, die anderen ihren deckenden Zwilling (cut_on 0, ohne next_pass). Held geht ein Stück: die Wahl folgt.
# Braucht godot/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/zellen_1484a.gd; massgeblich ist die Zeile ZELLEN1484A.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

func _zaehle(g: Gebiet) -> Array:
	var nah := 0
	var falsch := 0
	for z in g.zellen:
		var mi: MeshInstance3D = z["mi"]
		for i in mi.mesh.get_surface_count():
			var m := mi.get_surface_override_material(i) as ShaderMaterial
			if m == null: continue
			if z["nah"] and m != z["durch"][i]: falsch += 1
			if not z["nah"] and m.next_pass != null and m in g.laub: falsch += 1
		if z["nah"]: nah += 1
	return [nah, falsch]

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	for ort in [["village", Vector2i(12, 12)], ["forest", Vector2i(9, 12)], ["deep_forest", Vector2i(10, 10)]]:
		spiel.betrete(ort[0], ort[1], "DOWN")
		for i in 10: await process_frame
		var g: Gebiet = spiel.gebiet
		var knoten: Node = g.find_child("Dorf_Netz", true, false)
		pruefe(knoten != null and not (knoten is MeshInstance3D), "%s: Dorf_Netz ist ein Knoten" % ort[0])
		if knoten == null: continue
		var n := knoten.get_child_count()
		pruefe(n >= 4, "%s: %d Zellen" % [ort[0], n])
		var stoffe := {}
		var flaechen := 0
		for c in knoten.get_children():
			var mi := c as MeshInstance3D
			if mi == null: continue
			for i in mi.mesh.get_surface_count():
				flaechen += 1
				var m := mi.get_surface_override_material(i)
				if m: stoffe[m] = true
		pruefe(stoffe.size() < flaechen, "%s: Zellen teilen Stoffe (%d Stoffe auf %d Flächen)" % [ort[0], stoffe.size(), flaechen])
		pruefe(g.zellen.size() > 0, "%s: %d Zellen mit Durchsicht" % [ort[0], g.zellen.size()])
		var r := _zaehle(g)
		pruefe(r[0] >= 1 and r[0] < g.zellen.size(), "%s: Durchsicht nur nah: %d von %d Zellen" % [ort[0], r[0], g.zellen.size()])
		pruefe(r[1] == 0, "%s: Stoffe passen zur Wahl (%d falsch)" % [ort[0], r[1]])
		# Held weit weg: andere Wahl
		var vorher := []
		for z in g.zellen: vorher.append(z["nah"])
		g.nah(true, spiel.held.position + Vector3(30, 0, 30))
		var anders := 0
		for k in g.zellen.size(): if g.zellen[k]["nah"] != vorher[k]: anders += 1
		pruefe(anders > 0, "%s: Wahl folgt dem Helden (%d Zellen umgeschaltet)" % [ort[0], anders])
		pruefe(_zaehle(g)[1] == 0, "%s: nach dem Umschalten passen die Stoffe" % ort[0])
	print("ZELLEN1484A %d Fehler" % fehler)
	quit()
