class_name Umhang
extends RefCounted
# 431 Stufe 1 (Chef 15.11., 12:43 „431g A“): der Umhang aus dem Kleiderschrank (tools/blender348/v3/kleiderschrank.py) haengt an einer
# eigenen Knochenkette am Ruecken (umhang_<l2|l1|m|r1|r2>_<1..n> unter spine_03), nicht mehr an Armen und Beinen (861). Hier federt
# die Kette (SpringBoneSimulator3D, Godot 4.7) und weicht Rumpf, Becken, Beinen, Schild und Rueckenwaffe aus (Kapseln, aus dem Koerper
# gemessen: je Knochen der Abstand der Haut von der Knochenachse).
# Aufruf: Umhang.an(figur, skelett) nach dem Laden; gibt den Simulator zurueck (null ohne Kette). Umhang.ruecken(sim, sk, knoten) nimmt
# Schild oder Rueckenwaffe (Knoten unter einem BoneAttachment3D) als weitere Kapsel auf.

const SPALTEN := ["l2", "l1", "m", "r1", "r2"]
const RUMPF := ["pelvis", "spine_01", "spine_02", "spine_03", "thigh_l", "thigh_r", "calf_l", "calf_r"]
# Federwerte (Godot-Einheiten): steif genug, dass der Umhang im Stehen haengt wie gebaut, weich genug, dass er beim Gehen nachschwingt
static var STEIF := float(OS.get_environment("UMHANG_STEIF")) if OS.get_environment("UMHANG_STEIF") != "" else 4.0
static var ZUG := float(OS.get_environment("UMHANG_ZUG")) if OS.get_environment("UMHANG_ZUG") != "" else 0.45
static var SCHWERE := float(OS.get_environment("UMHANG_SCHWERE")) if OS.get_environment("UMHANG_SCHWERE") != "" else 0.3
const GLIED_RADIUS := 0.035

static func ketten(sk: Skeleton3D) -> Array:
	var aus := []
	for s in SPALTEN:
		var a := sk.find_bone("umhang_%s_1" % s)
		if a < 0: continue
		var n := 1
		while sk.find_bone("umhang_%s_%d" % [s, n + 1]) >= 0: n += 1
		aus.append([s, n])
	return aus


static func an(m: Node3D, sk: Skeleton3D) -> SpringBoneSimulator3D:
	var k := ketten(sk)
	if k.is_empty(): return null
	var sim := SpringBoneSimulator3D.new()
	sim.name = "UmhangFeder"
	sk.add_child(sim)
	sim.setting_count = k.size()
	for i in k.size():
		var s: String = k[i][0]
		var n: int = k[i][1]
		sim.set_root_bone_name(i, "umhang_%s_1" % s)
		sim.set_end_bone_name(i, "umhang_%s_%d" % [s, n])
		sim.set_extend_end_bone(i, true)
		sim.set_end_bone_direction(i, SpringBoneSimulator3D.BONE_DIRECTION_FROM_PARENT)
		var e := sk.find_bone("umhang_%s_%d" % [s, n])
		sim.set_end_bone_length(i, sk.get_bone_rest(e).origin.length())
		sim.set_stiffness(i, STEIF)
		sim.set_drag(i, ZUG)
		sim.set_gravity(i, SCHWERE)
		sim.set_gravity_direction(i, Vector3.DOWN)
		sim.set_radius(i, GLIED_RADIUS)
		sim.set_center_from(i, SpringBoneSimulator3D.CENTER_FROM_WORLD_ORIGIN)
		sim.set_enable_all_child_collisions(i, true)
	var glieder := PackedVector3Array()   # Gelenke der Kette in der Ruhelage (Raum des Skeletts), dazu die Enden
	for e in k:
		for j in range(1, int(e[1]) + 1):
			var t := sk.get_bone_global_rest(sk.find_bone("umhang_%s_%d" % [e[0], j]))
			glieder.append(t.origin)
			if j == int(e[1]): glieder.append(t * Vector3(0, sk.get_bone_rest(sk.find_bone("umhang_%s_%d" % [e[0], j])).origin.length(), 0))
	for b in ([] if OS.get_environment("UMHANG_OHNE_KAPSEL") != "" else frei(kapseln(m, sk), sk, glieder)):
		var c := SpringBoneCollisionCapsule3D.new()
		c.name = "Kapsel_" + String(b["knochen"])
		sim.add_child(c)
		c.bone_name = String(b["knochen"])
		c.radius = float(b["radius"])
		c.height = float(b["hoehe"])
		c.position_offset = b["mitte"]
	return sim


## je Rumpf- und Beinknochen eine Kapsel laengs der Knochenachse: Radius = 85 % der Ecken der Haut (staerkstes Gewicht an diesem
## Knochen) liegen naeher an der Achse; Hoehe = Laenge des Bereichs der Ecken laengs der Achse
static func kapseln(m: Node3D, sk: Skeleton3D) -> Array:
	var pts := {}     # Knochen -> [Vector3] (im Raum des Knochens, Ruhelage; Array, weil Packed-Felder als Wert kopiert werden)
	for n in RUMPF: pts[n] = []
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var me := (mi as MeshInstance3D).mesh
		var skin := (mi as MeshInstance3D).skin
		if me == null or skin == null: continue
		var zu := {}   # Bindung -> [Knochen, Bindungsmatrix]
		for b in skin.get_bind_count():
			var bn := String(skin.get_bind_name(b))
			if bn == "": bn = sk.get_bone_name(skin.get_bind_bone(b))
			if bn in RUMPF: zu[b] = [bn, skin.get_bind_pose(b)]
		if zu.is_empty(): continue
		for si in me.get_surface_count():
			var mat := me.surface_get_material(si)
			var rn := String(mat.resource_name) if mat else ""
			if not (rn.contains("Regular") or rn.contains("Superhero")): continue   # nur die Haut des Kaufkoerpers
			var ar := me.surface_get_arrays(si)
			var v: PackedVector3Array = ar[Mesh.ARRAY_VERTEX]
			var bo: PackedInt32Array = ar[Mesh.ARRAY_BONES]
			var we: PackedFloat32Array = ar[Mesh.ARRAY_WEIGHTS]
			if bo.is_empty(): continue
			var je := bo.size() / v.size()
			for i in v.size():
				var best := -1; var bw := 0.0
				for j in je:
					if we[i * je + j] > bw: bw = we[i * je + j]; best = bo[i * je + j]
				if zu.has(best):
					var e: Array = zu[best]
					(pts[e[0]] as Array).append((e[1] as Transform3D) * v[i])
	var aus := []
	for n in RUMPF:
		var p: Array = pts[n]
		if p.size() < 12 or sk.find_bone(n) < 0: continue
		var r := []
		var y0 := INF; var y1 := -INF
		for q in p:
			r.append(Vector2(q.x, q.z).length())
			y0 = minf(y0, q.y); y1 = maxf(y1, q.y)
		r.sort()
		var rad: float = r[int(r.size() * 0.85)]
		aus.append({"knochen": n, "radius": rad, "hoehe": maxf(y1 - y0 + 2.0 * rad, 2.0 * rad + 0.01), "mitte": Vector3(0, (y0 + y1) * 0.5, 0)})
	return aus


## Kapseln so schmal, dass die Kette in der Ruhelage frei liegt (sonst drueckt die Federung den Umhang gleich vom Koerper weg):
## Radius hoechstens Abstand des naechsten Glieds zur Achse minus Gliedradius und 5 mm
static func frei(liste: Array, sk: Skeleton3D, glieder: PackedVector3Array) -> Array:
	for b in liste:
		var t := sk.get_bone_global_rest(sk.find_bone(String(b["knochen"])))
		var r: float = b["radius"]
		var h: float = b["hoehe"]
		var c: Vector3 = t * (b["mitte"] as Vector3)
		var ax := t.basis.y.normalized() * maxf(h * 0.5 - r, 0.0)
		var naechst := INF
		for g in glieder:
			naechst = minf(naechst, g.distance_to(Geometry3D.get_closest_point_to_segment(g, c - ax, c + ax)))
		var rmax := naechst - GLIED_RADIUS - 0.005
		if r > rmax:
			b["radius"] = maxf(rmax, 0.02)
			b["hoehe"] = maxf(h - 2.0 * (r - float(b["radius"])), 2.0 * float(b["radius"]) + 0.01)
	return liste


## Schild oder Rueckenwaffe (Knoten unter einem BoneAttachment3D des Skeletts) als Kapsel um seine Begrenzung
static func ruecken(sim: SpringBoneSimulator3D, sk: Skeleton3D, knoten: Node3D) -> void:
	if sim == null or knoten == null: return
	var ba := knoten.get_parent() as BoneAttachment3D
	if ba == null: return
	var box := AABB()
	var erst := true
	for mi in knoten.find_children("*", "MeshInstance3D", true, false):
		var t := ba.global_transform.affine_inverse() * (mi as MeshInstance3D).global_transform   # Raum des Knochens
		var a := t * (mi as MeshInstance3D).get_aabb()
		box = a if erst else box.merge(a)
		erst = false
	if erst: return
	var c := SpringBoneCollisionCapsule3D.new()
	c.name = "Kapsel_" + String(knoten.name)
	sim.add_child(c)
	c.bone_name = ba.bone_name
	var s := box.size
	c.radius = maxf(minf(s.x, s.z) * 0.5, 0.03)
	c.height = maxf(s.y, 2.0 * c.radius + 0.01)
	c.position_offset = box.get_center()
