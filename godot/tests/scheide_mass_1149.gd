extends SceneTree
# 1149 (Chef 14.11., 10:12: „Also muss doch das mal allgemein berechnet werden, oder?“): die Scheide wird aus der Klinge des Modells
# gerechnet. Ohne Kaufmodelle und ohne Bild: Dolche aus Querschnitten wie waffen.py (sword: Griff Leder, Parierstange Messing, Klinge
# Stahl), der Dolch des Helden (25 cm, Wurzel ±3/±1 cm), ein größerer, ein kleinerer, ein dickerer; jede Ecke der Klinge liegt in der
# Scheide, die Scheide nirgends mehr als 1 cm breiter als die Klinge. Massgeblich ist die Zeile SCHEIDE1149.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

# Dolch wie waffen.py sword(): Griff bis gz, Parierstange gz..gz+grad, Klinge ab gz+grad; je Querschnitt eine Raute (Schneide ±x, Fläche ±z)
static func dolch(gz: float, ghalf: float, grad: float, lang: float, w0: float, w1: float, t0: float, spitze: float) -> MeshInstance3D:
	var leder := Color(0.30, 0.20, 0.14); var messing := Color(0.75, 0.60, 0.25); var stahl := Color(0.62, 0.66, 0.70)
	var vs := PackedVector3Array(); var cs := PackedColorArray()
	var raute := func(y: float, hx: float, hz: float, c: Color) -> void:
		for p in [Vector3(hx, y, 0), Vector3(0, y, hz), Vector3(-hx, y, 0), Vector3(0, y, -hz)]:
			vs.append(p); cs.append(c)
	for y in [-0.045, 0.0, gz]: raute.call(y, 0.0135, 0.0135, leder)
	raute.call(gz, ghalf, 0.008, messing); raute.call(gz + grad, ghalf, 0.008, messing)
	var b0 := gz + grad
	raute.call(b0, w0, t0, stahl)
	raute.call(b0 + lang - spitze, w1, t0 * 0.7, stahl)
	vs.append(Vector3(0, b0 + lang, 0)); cs.append(stahl)
	var arr := []; arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = vs; arr[Mesh.ARRAY_COLOR] = cs
	var me := ArrayMesh.new()
	me.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, arr)
	var mi := MeshInstance3D.new(); mi.mesh = me
	return mi

func _lauf() -> void:
	for f in [["Held", 0.048, 0.055, 0.008, 0.25, 0.030, 0.018, 0.010, 0.08], ["groesser", 0.05, 0.065, 0.009, 0.32, 0.036, 0.022, 0.012, 0.10],
			["kleiner", 0.04, 0.045, 0.007, 0.18, 0.022, 0.013, 0.008, 0.06], ["dicker", 0.048, 0.055, 0.008, 0.25, 0.030, 0.018, 0.016, 0.08]]:
		var d := dolch(f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8])
		var sc := HeldFigur.scheide(d)
		pruefe(sc != null and HeldFigur.scheide_ringe.size() >= 6, "%s: Scheide gebaut (%d Ringe)" % [f[0], HeldFigur.scheide_ringe.size()])
		if sc == null: continue
		var km := HeldFigur.klinge_mass(d)
		var drau := 0; var weit := 0.0
		var arr := (d.mesh as ArrayMesh).surface_get_arrays(0)
		for i in (arr[Mesh.ARRAY_VERTEX] as PackedVector3Array).size():
			var p: Vector3 = arr[Mesh.ARRAY_VERTEX][i]
			if (arr[Mesh.ARRAY_COLOR][i] as Color).b < 0.6: continue   # nur die Klinge (Stahl), nicht die Parierstange
			var w := HeldFigur.scheide_quer(p.y)
			if w == Vector2.ZERO or pow(p.x / w.x, 2) + pow(p.z / w.y, 2) > 1.0001: drau += 1
		for y in range(0, 41):
			var yy := lerpf(float(km["wurzel"]), float(km["spitze"]), y / 40.0)
			var k := HeldFigur.klinge_quer(km, yy); var s := HeldFigur.scheide_quer(yy)
			if s != Vector2.ZERO: weit = maxf(weit, s.x - k.x)
		var r0: Array = HeldFigur.scheide_ringe[0]
		pruefe(drau == 0, "%s: Klinge außerhalb der Scheide %d Ecken (soll 0)" % [f[0], drau])
		pruefe(weit <= 0.0101, "%s: Scheide höchstens 1 cm breiter als die Klinge (%.4f m)" % [f[0], weit])
		pruefe(absf(float(HeldFigur.scheide_ringe[HeldFigur.scheide_ringe.size() - 1][0]) - float(km["spitze"]) - 0.016) < 0.001,
			"%s: Spitze der Scheide 1,6 cm über der Klinge" % f[0])
		print("1149 %s: Mund y %.3f ±%.4f/±%.4f, Ende y %.3f" % [f[0], r0[0], r0[1], r0[2], HeldFigur.scheide_ringe[HeldFigur.scheide_ringe.size() - 1][0]])
		if f[0] == "Held":
			pruefe(absf(float(r0[1]) - 0.038) < 0.001 and absf(float(r0[2]) - 0.016) < 0.001, "Held: Mund wie Lauf 468 (±3,8/±1,6 cm)")
		sc.free(); d.free()
	print("SCHEIDE1149 " + ("gut" if fehler == 0 else "FEHLER %d" % fehler))
	quit(1 if fehler else 0)
