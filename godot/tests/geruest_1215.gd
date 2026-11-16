extends SceneTree
# 1215 (Fragen 1, 2 von Sokrates 15.11., 11:21): Gerüst jedes Körpers in kampf/daten (jedes Modell mit „Stehen“): Zahl der Knochen,
# Äste an der Wurzel (Knochen ohne Eltern oder direkt an der Wurzel: was dort hängt, hat in der Physik kein Glied über sich),
# Sterbebewegungen mit Länge, und welche Gliedertafel aus ragdoll.gd passt. Ohne Bild, Sekunden; nur Auskunft (Exit 0).
# Aufruf: im Ordner godot mit -s res://tests/geruest_1215.gd   (KNOCHEN=1: alle Knochen mit Eltern)

const Figur = preload("res://kampf/figur.gd")
const Ragdoll = preload("res://kampf/ragdoll.gd")
const DATEN := "res://kampf/daten"


func _initialize() -> void:
	_run.call_deferred()


func _find(n: Node, cls: String) -> Node:
	if n.is_class(cls):
		return n
	for c in n.get_children():
		var r := _find(c, cls)
		if r:
			return r
	return null


func _run() -> void:
	var d := DirAccess.open(DATEN)
	var namen: Array = Array(d.get_files()) if d else []
	namen.sort()
	var gesehen := {}
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
		var sk := _find(sz, "Skeleton3D") as Skeleton3D
		if ap == null or sk == null or not ap.has_animation("Stehen"):
			sz.free()
			continue
		var wurzeln := []
		var aeste := []
		for i in sk.get_bone_count():
			var p := sk.get_bone_parent(i)
			if p < 0:
				wurzeln.append(sk.get_bone_name(i))
			elif sk.get_bone_parent(p) < 0:
				aeste.append(sk.get_bone_name(i))
		var tode := []
		for a in ap.get_animation_list():
			if String(a).begins_with("Tod"):
				tode.append("%s %.2f s" % [a, ap.get_animation(a).length])
		var art := String(n).get_slice("-", 0)
		var kurz := "%d Knochen, Wurzel %s, Äste %s" % [sk.get_bone_count(), wurzeln, aeste]
		if not gesehen.has(art) or gesehen[art] != kurz:
			gesehen[art] = kurz
			root.add_child(sz)
			var r = Ragdoll.new()
			root.add_child(r)
			var tafel := "keine"
			if r.einrichten(sk, ap, 1.0):
				tafel = "%s, %d Glieder" % [r.geruest, r.glieder.size()]
			print("GERUEST1215 %s: %s; Tode %s; Tafel %s" % [n, kurz, tode, tafel])
			if OS.get_environment("KNOCHEN") != "":
				var z := []
				for i in sk.get_bone_count():
					z.append("%s<%s" % [sk.get_bone_name(i), sk.get_bone_name(sk.get_bone_parent(i)) if sk.get_bone_parent(i) >= 0 else "-"])
				print("GERUEST1215 %s Knochen: %s" % [n, " ".join(z)])
			r.free()
			root.remove_child(sz)
		sz.free()
	print("GERUEST1215 fertig, %d Arten" % gesehen.size())
	quit(0)
