extends SceneTree
# 1140 (Chef 13.11., 14:26: Fackel ausgerüstet, im Menü nicht am Helden): eine Fackel für Welt, Ausrüstung und Kampfort (fackel.gd).
# Ohne Bild. Prüft: Fackel.an baut Stiel, Pechkopf, Flamme (5 Tropfen und Schein) und Licht an die Faust; richte() stellt den Stiel
# zu zwei Dritteln auf und das Licht 25 cm vor die Flamme in Blickrichtung; HeldFigur zeigt die Fackel nur mit „fackel_zeigen“ und
# einer Fackel in der Nebenhand (nicht mit Schild, nicht in der Welt, die ihre eigene baut).
# Aufruf: im Ordner godot mit -s res://tests/fackel_1140.gd -> „FACKEL1140 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var koerper := Node3D.new()
	root.add_child(koerper)
	koerper.rotation.y = 0.7
	var sk := Skeleton3D.new()
	koerper.add_child(sk)
	var bi := sk.add_bone("foL-wrL")
	sk.set_bone_rest(bi, Transform3D(Basis(Vector3.FORWARD, 1.2), Vector3(0.2, 1.0, 0.1)))
	sk.reset_bone_poses()
	var f := Fackel.an(sk, "foL-wrL", Vector3(-0.0187, 0.187, 0.0072), Vector3(-0.358, 0.0, -0.934), koerper)
	pruefe(f.get_parent() is BoneAttachment3D and (f.get_parent() as BoneAttachment3D).bone_name == "foL-wrL", "Fackel nicht an der Faust")
	pruefe(f.name == "Fackel", "Knoten heißt %s" % f.name)
	pruefe(f.flamme != null and f.flamme.get_child_count() == 6, "Flamme ohne 5 Tropfen und Schein")
	pruefe(f.licht != null and f.licht.is_in_group("tuschelicht") and float(f.licht.get_meta("reich", 0.0)) == 4.0, "Licht ohne Tusche nach der Fackel")
	await process_frame
	f.richte()
	pruefe(f.global_basis.y.normalized().y > 0.6, "Stiel nicht aufgerichtet (y %.2f)" % f.global_basis.y.normalized().y)
	var blick := koerper.global_basis.z.normalized()
	pruefe(f.licht.global_position.distance_to(f.flamme.global_position + blick * Fackel.VOR) < 0.001, "Licht nicht vor der Flamme")
	var fl_y := f.flamme.global_basis.y.normalized()
	pruefe(fl_y.y > 0.9, "Flamme nicht aufrecht (y %.2f)" % fl_y.y)
	# Menü: eigener Takt
	f.selbst = true
	var z0 := f.zeit
	await process_frame
	await process_frame
	pruefe(f.zeit > z0, "Fackel im Menü flackert nicht (Zeit steht)")
	# HeldFigur: nur mit fackel_zeigen und Fackel in der Nebenhand
	var fackel := {"uid": 1, "base": "torch", "rarity": "COMMON", "ilvl": 1, "rolls": []}
	var schild := {"uid": 2, "base": "shield", "rarity": "COMMON", "ilvl": 1, "rolls": []}
	pruefe(HeldFigur.fackel_in_hand({"fackel_zeigen": true, "ausruestung": {"OFF_HAND": fackel}}), "Ausrüstung mit Fackel: keine Fackel")
	pruefe(not HeldFigur.fackel_in_hand({"ausruestung": {"OFF_HAND": fackel}}), "Welt (ohne fackel_zeigen): doppelte Fackel")
	pruefe(not HeldFigur.fackel_in_hand({"fackel_zeigen": true, "ausruestung": {"OFF_HAND": schild}}), "Schild als Fackel")
	pruefe(not HeldFigur.fackel_in_hand({"fackel_zeigen": true, "ausruestung": {}}), "Fackel ohne Nebenhand")
	print("FACKEL1140 %d Fehler" % fehler)
	quit(1 if fehler else 0)
