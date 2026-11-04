# 453.2: Held und Leute atmen unterwegs als eigene Schicht (Gebiet.atem_an, kampf/atem.gd). Ohne Bild, ohne Daten: zwei Figuren mit
# einem Geruest wie die UAL (spine_02, spine_03, clavicle_*, upperarm_*, neck_01, Head) und einer Ruhe „Stehen“, die selbst atmet.
#  - Ruhe: Atemzug 3,5-5 s, die Schulter hebt sich 0,3-2 cm; nie Stillstand: in jeder Sekunde bewegt sich die Schulter
#  - eigener Takt: die Atemzuege beider unterscheiden sich um mindestens 5 %
#  - „Stehen“ hat danach je Spur einen Schluessel (der UAL-Atem ist heraus), „Stehen_2“ bleibt
#  - nach Anstrengung (Rennen) in den ersten 3 s mindestens 1,35-mal so viele Atemzuege, Schulter in den ersten 6 s mindestens 1,8-mal
#    so hoch wie in Ruhe, nach 8 s noch ein Viertel angestrengt, nach 20 s fast Ruhe (Chef 03.11., 23:37)
#  - ohne UAL-Geruest (Dorftier) kein Atem
# Run: godot --headless --path godot --fixed-fps 30 -s res://tests/atem_4532.gd   (Ende 0 = alles richtig)
extends SceneTree

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("ok     " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

const KNOCHEN := [["root", -1, Vector3.ZERO], ["pelvis", 0, Vector3(0, 1.0, 0)], ["spine_01", 1, Vector3(0, 0.1, 0)],
	["spine_02", 2, Vector3(0, 0.12, 0)], ["spine_03", 3, Vector3(0, 0.15, 0)], ["neck_01", 4, Vector3(0, 0.15, 0)],
	["Head", 5, Vector3(0, 0.1, 0)], ["clavicle_l", 4, Vector3(0.04, 0.12, 0)], ["upperarm_l", 7, Vector3(0.14, 0, 0)],
	["clavicle_r", 4, Vector3(-0.04, 0.12, 0)], ["upperarm_r", 9, Vector3(-0.14, 0, 0)]]

func figur(welt: Node3D, x: float, ual := true) -> Array:
	var m := Node3D.new()
	m.position.x = x
	welt.add_child(m)
	var sk := Skeleton3D.new()
	sk.name = "Skeleton3D"
	m.add_child(sk)
	for k in KNOCHEN:
		var n: String = k[0]
		if not ual and n.begins_with("clavicle"): n = n.replace("clavicle", "schulter")
		var b := sk.add_bone(n)
		sk.set_bone_parent(b, k[1])
		sk.set_bone_rest(b, Transform3D(Basis(), k[2]))
	sk.reset_bone_poses()
	var ap := AnimationPlayer.new()
	m.add_child(ap)
	var lib := AnimationLibrary.new()
	for nm in ["Stehen", "Stehen_2"]:
		var a := Animation.new()
		a.length = 1.25
		a.loop_mode = Animation.LOOP_LINEAR
		var t := a.add_track(Animation.TYPE_ROTATION_3D)
		a.track_set_path(t, NodePath("Skeleton3D:spine_03"))
		for i in 6: a.rotation_track_insert_key(t, i * 0.25, Quaternion(Vector3.RIGHT, 0.05 * sin(i * PI / 2.5)))   # „hechelt“ wie Idle_Loop
		lib.add_animation(nm, a)
	ap.add_animation_library("", lib)
	ap.play("Stehen")
	return [m, sk, ap]

class Spur:
	var sk: Skeleton3D
	var y: Array = []
	func nach() -> void:
		y.append((sk.global_transform * sk.get_bone_global_pose(sk.find_bone("upperarm_l"))).origin.y)

func zuege(phasen: Array, von: int, bis: int) -> int:
	var n := 0
	for i in range(maxi(1, von), bis):
		if phasen[i] < phasen[i - 1]: n += 1
	return n

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var welt := Node3D.new()
	root.add_child(welt)
	var a := figur(welt, 0.0); var b := figur(welt, 2.0); var tier := figur(welt, 4.0, false)
	var atem_a = Gebiet.atem_an(a[0], a[2], 4532)
	var atem_b = Gebiet.atem_an(b[0], b[2], hash("aldric") ^ 4532)
	pruefe(atem_a != null and atem_b != null, "Atem an beiden Figuren")
	pruefe(Gebiet.atem_an(tier[0], tier[2], 7) == null, "ohne UAL-Geruest kein Atem")
	if atem_a == null or atem_b == null:
		quit(1); return
	var st: Animation = (a[2] as AnimationPlayer).get_animation("Stehen")
	pruefe(st.track_get_key_count(0) == 1, "Stehen ohne eigenen Atem (%d Schluessel)" % st.track_get_key_count(0))
	pruefe((a[2] as AnimationPlayer).get_animation("Stehen_2").track_get_key_count(0) == 6, "Stehen_2 unveraendert")
	pruefe(absf(atem_a.takt - atem_b.takt) / minf(atem_a.takt, atem_b.takt) >= 0.05, "eigener Takt: %.2f s und %.2f s" % [atem_a.takt, atem_b.takt])
	for t in [atem_a.takt, atem_b.takt]: pruefe(t >= 3.5 and t <= 5.0, "Atemzug %.2f s in 3,5-5 s" % t)
	var sp := Spur.new(); sp.sk = a[1]
	(a[1] as Skeleton3D).skeleton_updated.connect(sp.nach)
	var fps := 30
	var ph: Array = []
	for i in 20 * fps:
		await process_frame
		ph.append(atem_a.phase)
	var y: Array = sp.y.slice(sp.y.size() - 15 * fps)
	var hub: float = (y.max() - y.min()) * 100.0
	pruefe(hub >= 0.3 and hub <= 2.0, "Schulter hebt sich %.2f cm (0,3-2)" % hub)
	var still := 0
	for s in range(0, y.size() - fps, fps):
		var w := y.slice(s, s + fps)
		if w.max() - w.min() < 0.0002: still += 1
	pruefe(still == 0, "kein Stillstand: %d Sekunden ohne Bewegung der Schulter" % still)
	var ruhe_n := zuege(ph, 0, ph.size())
	atem_a.anstrengen(1.0)
	ph.clear()
	var y0 := sp.y.size()
	var stark := []   # Anstrengung je Sekunde
	for i in 20 * fps:
		await process_frame
		ph.append(atem_a.phase)
		if i % fps == 0: stark.append(atem_a.anstrengung)
	var schnell := zuege(ph, 0, 3 * fps) / 3.0
	var ruhe := ruhe_n / 20.0
	pruefe(schnell >= 1.35 * ruhe, "nach Anstrengung %.2f Zuege/s gegen %.2f in Ruhe" % [schnell, ruhe])
	# Chef 03.11., 23:37 (t249 245.2: nach dem Rennen nicht zu sehen): deutlich tiefer und mehrere Atemzuege lang
	var y_r: Array = sp.y.slice(y0, y0 + 6 * fps)
	var hub_r: float = (y_r.max() - y_r.min()) * 100.0
	pruefe(hub_r >= 1.8 * hub, "nach Rennen Schulter %.2f cm, mindestens 1,8-mal Ruhe (%.2f)" % [hub_r, hub])
	pruefe(float(stark[8]) >= 0.25, "nach 8 s noch ein Viertel angestrengt (%.2f)" % float(stark[8]))
	pruefe(atem_a.anstrengung < 0.05, "nach 20 s fast Ruhe (Anstrengung %.3f)" % atem_a.anstrengung)
	print("ATEM ANSTRENGUNG je s ", stark.map(func(x): return snappedf(x, 0.01)))
	print("ATEM 4532 " + ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
