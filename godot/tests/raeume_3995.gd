extends SceneTree
# 399.5 ohne Bild: jeder Grundriss (raum.py) laedt, jedes Wandstueck hat seine hohe und tiefe Fassung, die Lichter stehen (Kamin mit
# Schatten, Kerzen mit Flammen, Tageslicht je Fenster und Tuer), und gedreht wechseln die Waende: in der Grundansicht (Blick nach
# Nordwesten) Nord und West hoch, Sued und Ost tief; um 180 Grad gedreht umgekehrt. Braucht godot/daten wie im Bau.
# Aufruf: im Ordner godot mit -s res://tests/raeume_3995.gd

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var fehler := 0
	var kam := Camera3D.new()
	root.add_child(kam)
	kam.current = true
	for id in ["inn", "shop", "elder", "temple"]:
		var k := Karte.lade(id, {})
		var g := Gebiet.new(k)
		root.add_child(g)
		for i in 3: await process_frame
		var rl: Raumlicht = g.raumlicht
		if rl == null: print("FEHLER %s ohne Raumlicht" % id); fehler += 1; continue
		var leer := rl.waende.filter(func(w): return w[0] == null or w[1] == null)
		var kamin := rl.feuer.filter(func(f): return (f[0] as OmniLight3D).shadow_enabled).size()
		print("%s: Waende %d (ohne Fassung %d), Feuer %d (Kamin %d), Flammen %d, Fenster und Tuer %d" % [id, rl.waende.size(), leer.size(), rl.feuer.size(), kamin, rl.flammen.size(), rl.fenster.size()])
		if leer.size() > 0 or rl.feuer.is_empty() or rl.flammen.is_empty() or rl.fenster.is_empty(): fehler += 1; print("FEHLER Teile %s" % id)
		for dreh in [45.0, 225.0]:
			kam.rotation_degrees = Vector3(-30, dreh, 0)
			await process_frame
			await process_frame
			var falsch := 0
			for w in rl.waende:
				var n: Vector3 = w[3]
				var hinten: bool = n.dot(-kam.global_basis.z * Vector3(1, 0, 1)) < 0.0
				if (w[0] as Node3D).visible != hinten and absf(n.dot((-kam.global_basis.z * Vector3(1, 0, 1)).normalized())) > 0.4: falsch += 1
			print("  gedreht %d: hoch %d, falsch %d" % [dreh, rl.waende.filter(func(w): return (w[0] as Node3D).visible).size(), falsch])
			if falsch: fehler += 1
		rl.nacht(1.0)
		var tag_aus := rl.fenster.all(func(f): return (f[0] as SpotLight3D).light_energy < 0.8 * f[1] * 5.0)
		if not tag_aus: fehler += 1; print("FEHLER nachts Tageslicht %s" % id)
		g.queue_free()
		await process_frame
	print("RAEUME %d Fehler" % fehler)
	quit(1 if fehler else 0)
