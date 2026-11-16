extends SceneTree
# 531 (Chef 16.11., 12:26: „wie ist der Langbogen befestigt?“): Köchergurt und Schlaufe an Garrick (heldfigur.gd ruecken_gurt). Ohne Bild:
# der Gurt ist da, und in den Bewegungen, die Garrick spielt (Stehen, Ruhen, Gehen), liegt jeder Punkt seiner Mittellinie über
# Körper und Kleidung (Abstand nach außen, gemessen wie die Haut gezeichnet wird; was mehr als 4 cm weiter außen liegt, etwa der Arm
# vor dem Gurt, zählt nicht). Braucht die Kaufdaten (held_L_garrick_M):
#   im Ordner godot: godot --headless --path . -s res://tests/gurt_531.gd  -> „GURT531 n Fehler“ (ohne Kaufdaten „GURT531 ohne Kauf“)

# Garrick rennt nie (nur Pim rennt heim, leute.gd 1086): beim Rennen stößt der Oberschenkel vorn rechts bis 4 cm durch den Gurt
const BEWEGUNGEN := ["Ruhelage", "Stehen", "Stehen_2", "Ruhe_Greifen", "Ruhe_Trinken", "Gehen"]
const ZEITEN := [0.0, 0.5]   # Anteil der Länge
const MIN_ABSTAND := 0.002

func _initialize() -> void: _lauf.call_deferred()

func lagen_zu(ap: AnimationPlayer, sk: Skeleton3D, name: String, anteil: float) -> Array:
	var an := ap.get_animation(name)
	var zeit := an.length * anteil
	var sp := {}
	for t in an.get_track_count():
		var bn := String(an.track_get_path(t)).get_slice(":", 1)
		if bn == "": continue
		if not sp.has(bn): sp[bn] = {}
		if an.track_get_type(t) == Animation.TYPE_ROTATION_3D: sp[bn]["rot"] = t
		elif an.track_get_type(t) == Animation.TYPE_POSITION_3D: sp[bn]["pos"] = t
	var lagen := []
	lagen.resize(sk.get_bone_count())
	for b in sk.get_bone_count():   # Eltern stehen im Skelett vor den Kindern
		var rest := sk.get_bone_rest(b)
		var e: Dictionary = sp.get(sk.get_bone_name(b), {})
		var q: Quaternion = an.rotation_track_interpolate(e["rot"], zeit) if e.has("rot") else rest.basis.get_rotation_quaternion()
		var p: Vector3 = an.position_track_interpolate(e["pos"], zeit) if e.has("pos") else rest.origin
		var l := Transform3D(Basis(q).scaled(sk.get_bone_pose_scale(b)), p)
		var v := sk.get_bone_parent(b)
		lagen[b] = lagen[v] * l if v >= 0 else l
	return lagen

func ruhe_lagen(sk: Skeleton3D) -> Array:
	var l := []
	for b in sk.get_bone_count(): l.append(sk.get_bone_global_rest(b))
	return l

func _lauf() -> void:
	if not FileAccess.file_exists("res://daten/held_L_garrick_M.bin"):
		print("GURT531 ohne Kauf"); quit(0); return
	var g := HeldFigur.person("garrick", [])
	root.add_child(g)
	var sk := Gebiet.finde(g, "Skeleton3D") as Skeleton3D
	var ap := Gebiet.finde(g, "AnimationPlayer") as AnimationPlayer
	var fehler := 0
	var gurt := g.find_child("Gurt", true, false) as MeshInstance3D
	if gurt == null:
		print("FEHLER kein Gurt an Garrick"); print("GURT531 1 Fehler"); quit(1); return
	var bi := sk.find_bone("spine_03")
	var ks := HeldFigur.im_raum(g, sk)
	var brust := ks * sk.get_bone_global_rest(bi)
	var y := brust.origin.y
	var hals_y := (ks * sk.get_bone_global_rest(sk.find_bone("neck_01"))).origin.y
	var ruhe := HeldFigur.haut_punkte(g, sk, false)
	var r := HeldFigur.ruecken_aus(ruhe, y - 0.63, y + 0.1)
	var gp := HeldFigur.gurt_punkte(ruhe, hals_y, y - HeldFigur.GURT_UNTEN)
	var linie := []
	for p in gp[0]: if p.z >= r[2] + 0.05: linie.append(p)   # wie ruecken_gurt: hinten liegt der Köcher
	print("GURT531 Mittellinie %d Punkte, Gurt %d Ecken" % [linie.size(), gurt.mesh.surface_get_array_len(0)])
	for bw in BEWEGUNGEN:
		if bw != "Ruhelage" and not ap.has_animation(bw): print("GURT531 ohne Bewegung ", bw); continue
		var schlecht := INF; var wo := Vector3.ZERO
		for a in ZEITEN:
			var lagen := lagen_zu(ap, sk, bw, a) if bw != "Ruhelage" else ruhe_lagen(sk)
			var koerper := PackedVector3Array()
			for mi in g.find_children("*", "MeshInstance3D", true, false):
				if not (mi as MeshInstance3D).skin or mi == gurt: continue
				for k in HeldFigur.haut_punkte(g, sk, true, mi, lagen, 0.21):   # Ruhelage T: |x| > 0,21 sind die Arme
					if k.y > y - 0.7 and k.y < hals_y + 0.12: koerper.append(k)
			var gp_ := HeldFigur.haut_punkte(g, sk, true, gurt, lagen, INF)
			var mp := Vector3.ZERO
			for q in gp_: mp += q
			mp /= maxf(1.0, gp_.size())
			for qi in range(0, gp_.size(), 6):
				var q: Vector3 = gp_[qi]
				var d: Vector3 = (q - mp).normalized()
				var lq: float = (q - mp).length()
				var rb := -INF
				for k in koerper:
					var v: Vector3 = k - mp
					var t: float = v.dot(d)
					if t > 0.0 and t < lq + 0.04 and (v - d * t).length() < 0.015: rb = maxf(rb, t)   # weiter draußen: Arm vor dem Gurt, kein Durchstoßen
				if rb == -INF: continue
				var ab: float = lq - rb
				if ab < schlecht: schlecht = ab; wo = q
		var gut := schlecht >= MIN_ABSTAND
		if not gut: fehler += 1
		print("%s %s: kleinster Abstand über dem Körper %.1f mm (bei %s)" % ["gut" if gut else "FEHLER", bw, schlecht * 1000, wo])
	print("GURT531 %d Fehler" % fehler)
	quit(1 if fehler else 0)
