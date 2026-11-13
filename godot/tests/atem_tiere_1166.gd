# 1166 (453a B, Chef 02.11.: „gilt für alle Vierbeiner“): atem_tier.gd findet den Rücken auch ohne Wolfsknochen; Wolf unverändert,
# ohne Rückenknochen kein Atem. Ohne Bild: godot --headless --path godot -s res://tests/atem_tiere_1166.gd
extends SceneTree

const Tier = preload("res://kampf/atem_tier.gd")
var fehler := 0


func _skelett(namen: Array) -> Skeleton3D:
	# [Name, Elternname oder ""]
	var sk := Skeleton3D.new()
	for n in namen:
		var b := sk.get_bone_count()
		sk.add_bone(n[0])
		if n[1] != "":
			sk.set_bone_parent(b, sk.find_bone(n[1]))
	return sk


func _soll(was: String, ist, soll) -> void:
	if str(ist) != str(soll):
		fehler += 1
		print("FEHLER %s: %s statt %s" % [was, ist, soll])


func _initialize() -> void:
	var wolf := _skelett([["Wolf_Hips", ""], ["Wolf_Spine_01SHJnt", "Wolf_Hips"], ["Wolf_Spine_02SHJnt", "Wolf_Spine_01SHJnt"],
		["Wolf_Spine_03SHJnt", "Wolf_Spine_02SHJnt"], ["Wolf_Spine_04SHJnt", "Wolf_Spine_03SHJnt"]])
	_soll("Wolf", Tier.knochen_fuer(wolf), [Tier.RIPPEN, Tier.HALTEN, Tier.VON])
	var keiler := _skelett([["pelvis", ""], ["spine_01", "pelvis"], ["spine_02", "spine_01"], ["spine_03", "spine_02"], ["neck", "spine_03"],
		["tail_01", "pelvis"]])
	_soll("Keiler", Tier.knochen_fuer(keiler), [[["spine_02", 1.0]], "spine_03", "spine_01"])
	var hund := _skelett([["Root", ""], ["Hips", "Root"], ["Spine", "Hips"], ["Chest", "Spine"], ["Neck", "Chest"]])
	_soll("Hund", Tier.knochen_fuer(hund), [[["Spine", 1.0]], "Chest", "Hips"])
	var lang := _skelett([["root", ""], ["spine1", "root"], ["spine2", "spine1"], ["spine3", "spine2"], ["spine4", "spine3"], ["spine5", "spine4"]])
	_soll("lang", Tier.knochen_fuer(lang), [[["spine2", 0.8], ["spine3", 0.8], ["spine4", 1.0]], "spine5", "spine1"])
	var fledermaus := _skelett([["root", ""], ["body", "root"], ["wing_l", "body"]])
	_soll("ohne Rücken", Tier.knochen_fuer(fledermaus), [])
	_soll("passt ohne Rücken", Tier.passt(fledermaus), false)
	for sk in [wolf, keiler, hund, lang, fledermaus]:
		sk.free()
	print("ATEMTIERE1166 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
