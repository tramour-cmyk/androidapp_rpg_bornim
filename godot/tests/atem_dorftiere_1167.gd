# 1167 (453.1 Chef 01.11.; 453a B 02.11.: „gilt für alle Vierbeiner“): die Dorftiere (kauftier.py, daten/dorftiere) atmen als Schicht
# wie die Tiere im Kampf (Gebiet.tier_atem_an, kampf/atem_tier.gd). Je Tier zwei gleiche Modelle in „Stehen“, eines mit Atem:
#  - Atem hängt am Skelett, Rücken gefunden
#  - Rücken (letzter Rippenknochen) weicht vom Zwilling ohne Atem um 2–40 mm ab (sichtbar, nicht grotesk), Atemzug 2–3 s
#  - Pfoten und Kopf bleiben (unter 1 mm gegen den Zwilling)
# Ohne Daten (Kauf fehlt) „aus“. Run: godot --headless --path godot --fixed-fps 30 -s res://tests/atem_dorftiere_1167.gd
extends SceneTree

const D := "res://daten/dorftiere"
var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("ok     " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

func _modell(welt: Node3D, datei: String, x: float) -> Array:
	var m := Gebiet.lade_glb(datei)
	m.position.x = x
	welt.add_child(m)
	var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
	if ap:
		Gebiet.bewegungen(ap, ["Stehen"])
		ap.play("Stehen")
		ap.seek(0.0, true)
	return [m, Gebiet.finde(m, "Skeleton3D") as Skeleton3D, ap]

func _lage(sk: Skeleton3D, b: int) -> Vector3:
	return sk.global_transform.affine_inverse() * (sk.global_transform * sk.get_bone_global_pose(b).origin) if b >= 0 else Vector3.ZERO

func _lauf() -> void:
	if not DirAccess.dir_exists_absolute(D):
		print("ATEMDORF1167 aus (ohne daten/dorftiere)")
		quit(0); return
	var welt := Node3D.new()
	root.add_child(welt)
	var dateien := []
	for f in DirAccess.get_files_at(D):
		if f.ends_with(".bin"): dateien.append(f)
	dateien.sort()
	var gesehen := {}
	for f in dateien:
		var tier: String = String(f).trim_prefix("kauf_").get_slice("-", 0)
		if gesehen.has(tier): continue     # je Tier ein Fell genügt (gleiches Gerüst)
		gesehen[tier] = true
		var a := _modell(welt, D + "/" + f, 0.0)
		var b := _modell(welt, D + "/" + f, 0.0)
		var sk: Skeleton3D = a[1]
		var sk0: Skeleton3D = b[1]
		var atem = Gebiet.tier_atem_an(a[0], hash(tier) ^ 1167)
		pruefe(atem != null, "%s: Atem am Skelett" % tier)
		if atem == null:
			a[0].queue_free(); b[0].queue_free()
			continue
		pruefe(atem.takt >= 2.0 and atem.takt <= 3.0, "%s: Atemzug %.2f s in 2–3 s" % [tier, atem.takt])
		var ruecken := sk.find_bone(String(atem.rippen_def[atem.rippen_def.size() - 1][0]))
		var still := []
		for i in sk.get_bone_count():
			var n := sk.get_bone_name(i).to_lower()
			if n.contains("pfote") or n.contains("head") or n.contains("kopf"): still.append(i)
		var mx := [0.0, 0.0]     # Rücken, Pfoten/Kopf; gemessen gleich nach der Schicht (wie atem_ruecken_453)
		var m := sk.global_basis.get_scale().y
		var messe := func():
			mx[0] = maxf(mx[0], (_lage(sk, ruecken) - _lage(sk0, ruecken)).length() * m)
			for s in still:
				mx[1] = maxf(mx[1], (_lage(sk, s) - _lage(sk0, s)).length() * m)
		atem.modification_processed.connect(messe)
		for i in 120:     # 4 s bei 30 Bildern
			await process_frame
		atem.modification_processed.disconnect(messe)
		var r_max: float = mx[0]
		var s_max: float = mx[1]
		print("1167 %s: Rippen %s, halten %s, von %s, Größe %.2f, Rücken %.1f mm, Pfoten/Kopf %.2f mm (%d Knochen)" % [tier,
			atem.rippen_def, atem.halten_name, atem.von_name, atem.groesse, r_max * 1000.0, s_max * 1000.0, still.size()])
		pruefe(r_max >= 0.002 and r_max <= 0.04, "%s: Rücken hebt sich %.1f mm (2–40)" % [tier, r_max * 1000.0])
		pruefe(s_max < 0.001, "%s: Pfoten und Kopf still (%.2f mm)" % [tier, s_max * 1000.0])
		a[0].queue_free(); b[0].queue_free()
	pruefe(gesehen.size() >= 2, "Dorftiere gefunden: %s" % ", ".join(gesehen.keys()))
	print("ATEMDORF1167 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
