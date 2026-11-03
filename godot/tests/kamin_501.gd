extends SceneTree
# 501 (Chef 03.11., 07:26, Build 204, Schänke: „das scheint ja irgendwie zu schweben … ganz komisch, wo das anfängt“): ohne Bild.
# Je Grundriss und Kamin: Fuss der sichtbaren Flamme gegen die Oberkante der Scheite darunter (Netz Herd_… aus raum.py, Ecken im
# Umkreis der Flamme). Die Flamme blendet unten weich aus (flamme.gdshader: sichtbar ab h = 0,15); die Zungen zaehlen mit.
# Soll: Fuss hoechstens 3 cm ueber den Scheiten, hoechstens 6 cm darin. Braucht godot/daten wie im Bau.
# Aufruf: im Ordner godot mit -s res://tests/kamin_501.gd -> „KAMIN501 n Fehler“

const SICHTBAR_AB := Raumlicht.SICHTBAR_AB
const UMKREIS := 0.14         # m um die Flamme, waagrecht: dort liegen die Scheite (raum.py: gekreuzt, je etwa 42 cm)
const DARUEBER := 0.03
const DARIN := 0.06

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

# tiefster sichtbarer Punkt einer Flamme (Kern und Zungen, ohne den Schein) in Weltkoordinaten
func fuss(kern: Node3D) -> float:
	var y := INF
	for mi in kern.get_children():
		if not (mi is MeshInstance3D) or not ((mi as MeshInstance3D).mesh is SphereMesh): continue
		var h := ((mi as MeshInstance3D).mesh as SphereMesh).height
		var unten := (mi as Node3D).position.y - h / 2.0 + SICHTBAR_AB * h
		y = minf(y, kern.global_position.y + unten * kern.global_basis.get_scale().y)
	return y

# Oberkante der Scheite: von oben senkrecht auf die Dreiecke der Herd-Netze (raum.py Herd_…: Aschenbett, Feuerboecke, Scheite),
# an 9 Stellen im Umkreis der Flamme; der hoechste Treffer unter der Flamme
func scheite(netz: Node, mitte: Vector3, bis: float) -> float:
	var y := -INF
	var herde: Array = []
	for h in netz.find_children("Herd_*", "", true, false):
		if h is MeshInstance3D: herde.append(h)
		herde.append_array(h.find_children("*", "MeshInstance3D", true, false))
	for mi in herde:
		var t := (mi as Node3D).global_transform
		var f: PackedVector3Array = (mi as MeshInstance3D).mesh.get_faces()
		for dx in [-1, 0, 1]:
			for dz in [-1, 0, 1]:
				var von := Vector3(mitte.x + dx * UMKREIS / 2.0, bis, mitte.z + dz * UMKREIS / 2.0)
				for i in range(0, f.size(), 3):
					var hit = Geometry3D.ray_intersects_triangle(von, Vector3.DOWN, t * f[i], t * f[i + 1], t * f[i + 2])
					if hit != null: y = maxf(y, (hit as Vector3).y)
	return y

func _lauf() -> void:
	var kam := Camera3D.new()
	root.add_child(kam)
	kam.current = true
	for id in ["inn", "shop", "elder", "temple"]:
		var k := Karte.lade(id, {})
		var g := Gebiet.new(k)
		root.add_child(g)
		for i in 3: await process_frame
		var rl: Raumlicht = g.raumlicht
		if rl == null: continue
		var n := 0
		for f in rl.flammen:
			var kern: Node3D = f[0]
			if kern.global_basis.get_scale().y < 1.0: continue   # Kerzen (0,32)
			n += 1
			var fu := fuss(kern)
			var sch := scheite(g, kern.global_position, kern.global_position.y)
			var luecke := fu - sch
			print("%s Kamin %d: Flamme ab %.3f m, Scheite bis %.3f m, Abstand %+.3f m" % [id, n, fu, sch, luecke])
			if sch == -INF: fehler += 1; print("FEHLER %s Kamin %d: keine Scheite unter der Flamme" % [id, n])
			elif luecke > DARUEBER or luecke < -DARIN: fehler += 1; print("FEHLER %s Kamin %d: Flamme %+.0f cm von den Scheiten" % [id, n, luecke * 100])
		g.queue_free()
		await process_frame
	print("KAMIN501 %d Fehler" % fehler)
	quit(1 if fehler else 0)
