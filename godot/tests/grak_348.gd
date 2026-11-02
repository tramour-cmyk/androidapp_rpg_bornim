# 348.12 nachbessern (Chef 28.10., 15:23, Archiv: „warum läuft der dann nicht mit einer Animation, sondern wird wieder über den Platz
# geschoben? … Animation beim Bewegen, beim Ausweichen … Der Axthieb trifft auch nicht … wir brauchen einen Zusammenbruch“): Grak im
# echten Kampfort, ohne Bild, die Regeln angehalten. Geprüft je Bild:
#  - Platzwechsel: solange er sich bewegt, spielt er Gehen oder Rennen, im Tempo des Wurzelwegs (Füße gleiten nicht);
#  - Hieb: beim Aufschlag liegt die Axt im Rand der Heldin (nicht davor, nicht durch sie hindurch), auf Körperhöhe;
#  - Ausweichen zu beiden Seiten mit der Bewegung der Quelle und Ortswechsel, danach wieder daheim;
#  - Tod: er bricht zusammen (Becken unten) und bleibt sichtbar liegen, nichts ausgeblendet.
# Nur mit dem Grak aus grak_gestalt.py (UAL=<Pro>) in kampf/daten aussagekräftig; ohne seinen Weg: übersprungen (exit 0).
# Run: godot --headless --path godot -s res://tests/grak_348.gd   (exit code 0 = alles erfüllt)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const GLEIT := 0.12      # so weit darf das Tempo am Boden vom Tempo des Wurzelwegs abweichen (Anteil)
const RAND_MIN := 0.0     # m: so tief liegt die Axt beim Aufschlag mindestens im Rand der Heldin …
const RAND_MAX := 0.3     # … und höchstens (sonst schlägt sie durch die Heldin hindurch)

var fehler := 0


func _initialize() -> void:
	_all.call_deferred()


func _gut(ok: bool, text: String) -> void:
	print(("gut " if ok else "FEHLER ") + text)
	if not ok:
		fehler += 1


func _all() -> void:
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "WIZARD"
	p.foe = "GRAK"
	root.add_child(p)
	await process_frame
	p._start()
	for i in 4:
		await process_frame
	var k = p.fight
	var grak = null
	for f in k.figures.values():
		if f.fighter.monster != null and f.fighter.monster.id == "hobgoblin_captain":
			grak = f
	var held = p.fig_of("hero")
	if grak == null or not grak.weg.has("Gehen") or grak.hieb.size() < 4:
		print("übersprungen: Grak ohne Wurzelweg oder Hieb (kampf/daten aus grak_gestalt.py mit UAL=<Pro>)")
		quit(0)
		return
	var halt := func() -> void:     # Regeln anhalten wie probe.gd SCHAU=ort
		k.playing = true
		k.beats_lock.lock()
		k.beats.clear()
		k.beats_lock.unlock()
	for i in 30:
		halt.call()
		await process_frame
	for f in k.figures.values():     # die anderen stehen still daheim
		if f != grak and f != held and f.fighter.side == "FOES":
			f.visible = false
	# ---- Platzwechsel hin und zurück: Gehen (kurz) und Rennen (weit)
	var h0: Vector3 = grak.home
	for ziel in [h0 + k.facing(true) * -0.9, h0, h0 + k.facing(true) * -2.4, h0]:
		grak.glide_to(ziel)
		var bilder := 0
		var falsch := 0
		var gleit := 0.0
		var strecke := {}     # je Bewegung: Weg (m) und Zeit (ms der Uhr des Kampforts) über die ganze Fahrt, gegen das Tempo des Wurzelwegs
		var vor: Vector3 = grak.position
		var uhr: float = k.clock_ms
		var t0 := Time.get_ticks_msec()
		while grak.tween and grak.tween.is_running() and Time.get_ticks_msec() - t0 < 10000:
			halt.call()
			await process_frame
			var v: Vector3 = grak.position - vor
			var dt: float = k.clock_ms - uhr
			vor = grak.position
			uhr = k.clock_ms
			v.y = 0.0
			if v.length() < 0.002:
				continue
			bilder += 1
			var nm := String(grak.anim.current_animation)
			if nm not in ["Gehen", "Rennen"]:
				falsch += 1
				continue
			var s: Array = strecke.get(nm, [0.0, 0.0])
			strecke[nm] = [s[0] + v.length(), s[1] + dt]
		for nm in strecke:
			gleit = maxf(gleit, absf(strecke[nm][0] / maxf(strecke[nm][1] / 1000.0, 0.001) / grak._mps(nm) - 1.0))
		_gut(bilder > 3 and falsch == 0, "Platzwechsel %.1f m: %d Bilder unterwegs, %d ohne Gehen oder Rennen" % [ziel.distance_to(h0) if ziel != h0 else 0.0, bilder, falsch])
		_gut(gleit < GLEIT or bilder <= 3, "Platzwechsel: Tempo am Boden weicht höchstens %.0f %% vom Wurzelweg ab" % (gleit * 100.0))
		_gut(grak.position.distance_to(ziel) < 0.05, "Platzwechsel: am Ziel (%.2f m daneben)" % grak.position.distance_to(ziel))
	# ---- Hieb aus zwei Entfernungen: Axt beim Aufschlag im Rand der Heldin
	for weit in [0.0, 1.5]:
		grak.snap_to(h0 + k.facing(true) * -weit)
		grak._face()
		for i in 5:
			halt.call()
			await process_frame
		var ms: int = grak.strike(held, {"spell": null})
		var lands: float = k.clock_ms + ms * 0.42
		var tief := -INF
		var hoch := 0.0
		var anims := {}
		while k.clock_ms < lands + 40.0:
			halt.call()
			await process_frame
			anims[String(grak.anim.current_animation)] = true
			if k.clock_ms >= lands - 25.0:
				var r: Array = _axt_im_rand(grak, held)
				if r[0] > tief:
					tief = r[0]
					hoch = r[1]
		_gut(tief >= RAND_MIN and tief <= RAND_MAX, "Hieb aus %.1f m weiter: Axt beim Aufschlag %.2f m im Rand der Heldin, %.2f m hoch (Bewegungen %s)" % [weit, tief, hoch, ", ".join(anims.keys())])
		_gut(hoch > 0.4 and hoch < 1.7, "Hieb: Aufschlag auf Körperhöhe (%.2f m)" % hoch)
		var t0 := Time.get_ticks_msec()
		while grak.tween and grak.tween.is_running() and Time.get_ticks_msec() - t0 < 10000:
			halt.call()
			await process_frame
		for i in 20:
			halt.call()
			await process_frame
		_gut(grak.position.distance_to(grak.home) < 0.05, "Hieb: danach daheim (%.2f m daneben)" % grak.position.distance_to(grak.home))
	# ---- Ausweichen zu beiden Seiten
	grak.snap_to(h0)
	grak._face()
	for nm in ["Ausweichen", "Ausweichen links"]:
		for i in 5:
			halt.call()
			await process_frame
		grak.dodge(0, nm)
		var weg_max := 0.0
		var gespielt := false
		var t0 := Time.get_ticks_msec()
		await process_frame
		while grak.tween and grak.tween.is_running() and Time.get_ticks_msec() - t0 < 10000:
			halt.call()
			await process_frame
			gespielt = gespielt or String(grak.anim.current_animation) == nm
			weg_max = maxf(weg_max, grak.position.distance_to(h0))
		for i in 20:
			halt.call()
			await process_frame
		_gut(gespielt and weg_max > 1.0, "%s: Bewegung %s, bis %.2f m vom Platz" % [nm, "gespielt" if gespielt else "FEHLT", weg_max])
		_gut(grak.position.distance_to(h0) < 0.05, "%s: danach daheim (%.2f m daneben)" % [nm, grak.position.distance_to(h0)])
	# ---- Tod: Zusammenbruch, liegen bleiben
	grak.hurt(0, true)
	var t1 := Time.get_ticks_msec()
	var sk: Skeleton3D = grak._find(grak.model, "Skeleton3D")
	var becken := INF
	while Time.get_ticks_msec() - t1 < 4500:
		halt.call()
		await process_frame
		var pi := sk.find_bone("pelvis")
		becken = (sk.global_transform * sk.get_bone_global_pose(pi)).origin.y
	var weg_param := 0.0
	for m in grak.mats:
		weg_param = maxf(weg_param, float(m.get_shader_parameter("weg")) if m.get_shader_parameter("weg") != null else 0.0)
	_gut(becken < 0.45, "Tod: Becken liegt %.2f m über dem Boden" % becken)
	_gut(grak.visible and weg_param == 0.0, "Tod: bleibt liegen (sichtbar %s, ausgeblendet %.2f)" % [grak.visible, weg_param])
	print("Grak 348.12: %d Fehler" % fehler)
	k.finish()
	quit(1 if fehler > 0 else 0)


## Wie tief (m) die Axt (Netz „Waffe“) am Boden im Rand der Heldin liegt (> 0: darin) und in welcher Höhe ihr tiefster Punkt dort liegt
func _axt_im_rand(grak, held) -> Array:
	var best := -INF
	var hoch := 0.0
	var r: float = held.body_r()
	for m in grak.model.find_children("*", "MeshInstance3D", true, false):
		if not String(m.name).begins_with("Waffe") or m.mesh == null:
			continue
		var arr: Array = m.mesh.surface_get_arrays(0)
		var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
		var sk: Skeleton3D = m.get_node_or_null(m.skeleton) as Skeleton3D
		for i in range(0, vs.size(), 3):
			var w: Vector3 = m.global_transform * vs[i]
			if sk != null and m.skin != null:
				w = _gehaeutet(m, sk, arr, i)
			var d := r - Vector2(w.x - held.position.x, w.z - held.position.z).length()
			if d > best:
				best = d
				hoch = w.y
	return [best, hoch]


## Ecke [i] eines gehäuteten Netzes in der Welt (Knochen und Gewichte aus den Flächendaten)
func _gehaeutet(m: MeshInstance3D, sk: Skeleton3D, arr: Array, i: int) -> Vector3:
	var bones: PackedInt32Array = arr[Mesh.ARRAY_BONES]
	var ws: PackedFloat32Array = arr[Mesh.ARRAY_WEIGHTS]
	var v: Vector3 = arr[Mesh.ARRAY_VERTEX][i]
	var n := ws.size() / maxi(arr[Mesh.ARRAY_VERTEX].size(), 1)
	var out := Vector3.ZERO
	for j in n:
		var w: float = ws[i * n + j]
		if w <= 0.0:
			continue
		var b: int = bones[i * n + j]
		var bi: int = m.skin.get_bind_bone(b)
		if bi < 0:
			bi = sk.find_bone(m.skin.get_bind_name(b))
		var bind: Transform3D = m.skin.get_bind_pose(b)
		out += (sk.global_transform * sk.get_bone_global_pose(bi) * bind * v) * w
	return out
