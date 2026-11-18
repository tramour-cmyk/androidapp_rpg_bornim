extends SceneTree
# 1694 (Chef 18.11., 17:01 „Als Systemlösung“): Messung, ohne Bild. Der Held geht im Dorf wie im Spiel (tragen.gd) mit je einer Waffe;
# je Bild und Hand, die die Waffe hält: Abstand jeder Fingerspitze (Zeige- bis kleiner Finger) zur Oberfläche des Schafts (Abstand zur
# Schaftachse minus Radius des Griffs, aus dem Netz um den Griff gemessen) und Abstand der Handfläche (middle_01) zur Schaftachse.
# Spitze > 1 cm = Finger offen oder neben dem Schaft; < −0,5 cm = im Schaft.
#   xvfb-run -a godot --rendering-driver vulkan --rendering-method mobile --path . -s res://tests/griff_mess_1694.gd -- --mess1694

const FOLGE := ["quarterstaff", "longsword", "handaxe"]
const FINGER := ["index", "middle", "ring", "pinky"]

var spiel
var _posen: Array[Transform3D] = []   # Posen aus dem Knoten Tragen (außerhalb der Änderung fehlt sie in get_bone_global_pose)
var _st := []

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 15 * 60
	spiel.betrete("village", Vector2i(17, 5), "UP")
	for i in 5: await process_frame
	spiel.werte = BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", spiel.zustand.neue_uid)
	var hw = spiel.held_werte()
	hw.ausruestung.erase("OFF_HAND")
	var start: Vector3 = spiel.held.position
	for i in FOLGE.size():
		hw.ausruestung["MAIN_HAND"] = {"uid": 9400 + i, "base": FOLGE[i], "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
		spiel.held_figur_neu("")
		for c in spiel.held.stoesst.get_connections(): spiel.held.stoesst.disconnect(c["callable"])
		for zustand in ["gehend", "stehend"]:
			spiel.held.position = start
			spiel.held.richtung = Vector3(0, 0, 1) if zustand == "gehend" else Vector3.ZERO
			var werte := {}
			for f in 60:
				await process_frame
				if f < 20: continue
				var m := miss(spiel.held.modell)
				for k in m:
					if not werte.has(k): werte[k] = []
					werte[k].append(m[k])
			var zeile := "GRIFF1694 %-12s %-7s" % [FOLGE[i], zustand]
			var keys := werte.keys(); keys.sort()
			for k in keys:
				var a: Array = werte[k]; a.sort()
				zeile += " %s %.1f" % [k, a[a.size() / 2]]
			print(zeile)
	spiel.held.richtung = Vector3.ZERO
	quit(0)

# {"r_index": cm Spitze–Schaftoberfläche, …, "r_flaeche": cm Handfläche–Schaftachse, "radius": cm}
func miss(m: Node3D) -> Dictionary:
	var aus := {}
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var w: Node3D = null
	for n in m.get_children():
		if String(n.name).contains("Getragen"): w = n
	if w == null:
		for n in sk.find_children("*", "Node3D", true, false):
			if String(n.name).contains("Getragen") or String(n.name).contains("Gehalten"): w = n
	var t: Tragen = null
	for n in sk.get_children():
		if n is Tragen: t = n
	if w == null or t == null: return aus
	t.merken = true
	if t.posen.size() != sk.get_bone_count(): return aus
	_posen = t.posen
	var g := w.global_transform * Halt.griff_rahmen(t.halt)
	var ax := g.basis.y.normalized()
	var rad: float = t._radius() if t.has_method("_radius") else _radius(w, g)
	aus["radius"] = 100.0 * rad
	var quer := func(p: Vector3) -> float:
		var v := p - g.origin
		return (v - ax * v.dot(ax)).length()
	for s in ["r", "l"]:
		var mf := sk.find_bone("middle_01_" + s)
		if mf < 0: continue
		var fl := sk.global_transform * _posen[mf].origin
		var v := fl - g.origin
		if absf(v.dot(ax)) > 0.6 * t.halt.get("laenge", 1.0) + 0.1: continue
		var dq: float = quer.call(fl)
		if dq > 0.12: continue   # diese Hand hält nicht
		aus[s + "_flaeche"] = 100.0 * dq
		for f in FINGER:
			var p := _spitze(sk, f + "_03_" + s)
			if p != Vector3.INF: aus["%s_%s" % [s, f]] = 100.0 * (float(quer.call(sk.global_transform * p)) - rad)
	return aus

# Spitze des Endglieds im Skelettraum: Kind des Knochens, sonst Ende in Richtung des Glieds (Länge wie das Mittelglied)
func _spitze(sk: Skeleton3D, name: String) -> Vector3:
	var b := sk.find_bone(name)
	if b < 0: return Vector3.INF
	var ch := sk.get_bone_children(b)
	if ch.size() > 0: return _posen[ch[0]].origin
	var p := sk.get_bone_parent(b)
	var gb := _posen[b].origin
	var gp := _posen[p].origin
	return gb + (gb - gp) * 0.85

# Radius des Schafts am Griff: größter Abstand zur Achse unter 3 cm der Ecken innerhalb ±15 cm längs um den Griffpunkt (die Netze
# haben am Griff nur Ringe an den Enden), sonst 1,5 cm
func _radius(w: Node3D, g: Transform3D) -> float:
	var ax := g.basis.y.normalized()
	var r := 0.0
	for mi in w.find_children("*", "MeshInstance3D", true, false) + ([w] if w is MeshInstance3D else []):
		var me := (mi as MeshInstance3D).mesh
		if me == null: continue
		var tr := (mi as MeshInstance3D).global_transform
		for s in me.get_surface_count():
			for q in me.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				var v: Vector3 = tr * q - g.origin
				if OS.get_environment("RAD") != "": _st.append(v.dot(ax))
				if absf(v.dot(ax)) > 0.15: continue
				var rq := (v - ax * v.dot(ax)).length()
				if rq < 0.03: r = maxf(r, rq)
	if OS.get_environment("RAD") != "" and not _st.is_empty(): _st.sort(); print("LANG %d %.3f %.3f" % [_st.size(), _st[0], _st[-1]]); _st.clear()
	if false: print("RAD n=%d" % w.find_children("*", "MeshInstance3D", true, false).size(), " ", w.name, " ", g.origin, " ", w.global_position)
	return r if r > 0.0 else 0.015
