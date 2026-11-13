extends SceneTree
# 1141 (Chef 13.11., 14:36: Goblins, Schamane fallen „wie Playmobil-Figuren … alle auf die gleiche Seite“; 596 galt nur für Modelle
# mit „Tod“, die Goblins hatten keinen und kippten steif um 80°): jeder Körper im Kampf (jedes Modell in kampf/daten mit „Stehen“)
# hat eine Sterbebewegung „Tod“; die Goblins (goblin.py, alle vier Arten, je Kit) haben drei (Tod, Tod2, Tod3), die am Ende liegen
# (Wurzel um mehr als 70° gekippt) und verschieden enden (vornüber, rücklings, seitlich: je zwei mehr als 60° auseinander). Ohne Bild, Sekunden.
# Aufruf: im Ordner godot mit -s res://tests/tod_1141.gd   (Exit 0 = gut; ohne gebaute Modelle FALSCH, damit der Bau nicht still grün ist)

const Figur = preload("res://kampf/figur.gd")
const DATEN := "res://kampf/daten"
const GOBLINS := ["goblin-", "goblin_archer-", "goblin_shaman-", "kobold-"]
const MINDESTENS := 12     # Körper im Bau (Goblins je 3 Kits, Wölfe, Ratten, Fledermäuse …); weniger heißt: Daten fehlen


func _initialize() -> void:
	_pruefe.call_deferred()


func _pruefe() -> void:
	var f := 0
	var koerper := 0
	var d := DirAccess.open(DATEN)
	var namen: Array = Array(d.get_files()) if d else []
	namen.sort()
	for n in namen:
		if not String(n).ends_with(".bin"):
			continue
		var doc := GLTFDocument.new()
		var st := GLTFState.new()
		var b := Figur.lade_bin("%s/%s" % [DATEN, n])
		if b.is_empty() or doc.append_from_buffer(b, "", st) != OK:
			continue
		var sz := doc.generate_scene(st, 30.0, false, false) as Node3D
		if sz == null:
			continue
		var ap := _find(sz, "AnimationPlayer") as AnimationPlayer
		if ap == null or not ap.has_animation("Stehen"):
			sz.free()
			continue
		koerper += 1
		var goblin := GOBLINS.any(func(g): return String(n).begins_with(g))
		var soll: Array = ["Tod", "Tod2", "Tod3"] if goblin else ["Tod"]
		var enden := []
		for t in soll:
			if not ap.has_animation(t):
				print("TOD1141 FALSCH %s: ohne %s" % [n, t])
				f += 1
				continue
			if not goblin:
				print("TOD1141 ok %s %s: %.2f s" % [n, t, ap.get_animation(t).length])
				continue
			var q := _wurzel(sk_of(sz), ap.get_animation(t))
			enden.append(q)
			var grad := rad_to_deg(q.get_angle())
			var gut: bool = grad > 70.0 and ap.get_animation(t).length >= 1.0
			print("TOD1141 %s %s %s: %.2f s, am Ende um %.0f° gekippt" % ["ok" if gut else "FALSCH", n, t, ap.get_animation(t).length, grad])
			if not gut:
				f += 1
		# drei verschiedene Lagen (vornüber, rücklings, seitlich): je zwei liegen um mehr als 60° auseinander
		if goblin and enden.size() == 3:
			for i in 3:
				var w := rad_to_deg((enden[i] as Quaternion).angle_to(enden[(i + 1) % 3]))
				if w < 60.0:
					print("TOD1141 FALSCH %s: %s und %s enden fast gleich (%.0f°)" % [n, soll[i], soll[(i + 1) % 3], w])
					f += 1
		sz.free()
	if koerper < MINDESTENS:
		print("TOD1141 FALSCH nur %d Körper in %s (gebaut?)" % [koerper, DATEN])
		f += 1
	print("TOD1141 %s (%d Körper)" % ["gut" if f == 0 else "FALSCH %d" % f, koerper])
	quit(1 if f else 0)


func sk_of(sz: Node) -> Skeleton3D:
	return _find(sz, "Skeleton3D") as Skeleton3D


## Drehung der Wurzel (Knochen „root“, steht im Stehen aufrecht) im letzten Bild der Bewegung [a]: liegend um etwa 90° gekippt
func _wurzel(sk: Skeleton3D, a: Animation) -> Quaternion:
	if sk == null:
		return Quaternion.IDENTITY
	for i in a.get_track_count():
		if a.track_get_type(i) == Animation.TYPE_ROTATION_3D and String(a.track_get_path(i).get_concatenated_subnames()) == "root":
			return a.rotation_track_interpolate(i, a.length).normalized()
	return Quaternion.IDENTITY


func _find(n: Node, cls: String) -> Node:
	if n.is_class(cls):
		return n
	for c in n.get_children():
		var r := _find(c, cls)
		if r:
			return r
	return null
