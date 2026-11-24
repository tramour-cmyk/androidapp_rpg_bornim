extends SceneTree
# 1694 (Auftrag Mirja 24.11., 12:15; Systemfrage wie 1711: Messung meldet passt, Bild zeigt Fehler): Spielweg gegen Prüfaufbau, Glied
# für Glied. Derselbe Körper (WACHE_M), derselbe Gegenstand, einmal wie im Spiel (Held im Dorf, heldfigur.gd baue, tragen.gd), einmal
# wie griff_alle_1694 (rohes held_WACHE_M.bin, Halt.anlegen, GriffHand). Je Glied: Beugung im Gelenk (Grad gegen die Ruhe), Griffpunkt
# und Schaftachse in Handkoordinaten, Haut am Griff intern (Griff.netz_finger, starr am Knochen, so rechnet griff.gd) und gezeichnet
# (bake, NetzMess). Exit 1, wenn ein Glied im Spielweg um mehr als 0,3 cm (Haut) gegen den Prüfaufbau abweicht.
#   MESS=1694 xvfb-run -a godot --path . --resolution 540x1170 -s res://tests/griff_weg_1694.gd
#   FALL=greataxe (Grundform im Spiel), BEW=Gehen_axt (Bewegung im Spielweg, sonst Stehen)
#   Versuch (nur Messung, kein Spielcode): ANGLEICH1694=1 setzt im Spielweg alle Formschlüssel der Netze auf 0 wie im Prüfaufbau,
#   ANGLEICH1694=<name> nur diesen (kantig, unter_CHEST …)
#   NACHBILD1694=1 (griff_folge_1694, 24.11.: bake im Signal skeleton_updated zeigt die Pose des vorigen Aufrufs): das gezeichnete Netz
#   wird mit der Waffenlage des vorigen Aufrufs verglichen (Messung zum passenden Zeitpunkt, nur im Test)

const GLIEDER := ["hand_r", "index_01_r", "index_02_r", "index_03_r", "middle_01_r", "middle_02_r", "middle_03_r",
	"ring_01_r", "ring_02_r", "ring_03_r", "pinky_01_r", "pinky_02_r", "pinky_03_r", "thumb_01_r", "thumb_02_r", "thumb_03_r"]
const GRENZE := 0.3   # cm

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var fall := OS.get_environment("FALL") if OS.get_environment("FALL") != "" else "greataxe"
	var bew := OS.get_environment("BEW")
	# --- Spielweg
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 13 * 60
	spiel.betrete("village", Vector2i(17, 5), "UP")
	for i in 5: await process_frame
	spiel.werte = BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", spiel.zustand.neue_uid)
	var hw = spiel.held_werte()
	hw.ausruestung.erase("OFF_HAND")
	if hw.get("aussehen") is Dictionary: hw.aussehen["geschlecht"] = "m"
	hw.ausruestung["MAIN_HAND"] = {"uid": 9601, "base": fall, "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
	spiel.held.process_mode = Node.PROCESS_MODE_INHERIT
	spiel.held_figur_neu("")
	spiel.held.richtung = Vector3.ZERO
	var mod: Node3D = spiel.held.modell
	var sk1 := Gebiet.finde(mod, "Skeleton3D") as Skeleton3D
	if OS.get_environment("ANGLEICH1694") != "": formschluessel_aus(mod, OS.get_environment("ANGLEICH1694"))
	var t: Tragen = null
	for n in sk1.get_children(): if n is Tragen: t = n
	if t == null or t.waffe == null:
		print("WEG1694 FEHLER Spielweg: kein Tragen"); quit(1); return
	var id := Staffel.datei(HeldFigur._modell(hw.ausruestung["MAIN_HAND"]))
	print("WEG1694 Spielweg: Tracht %s, Gegenstand %s, Tragen art=%s gang=%s, Modellmaßstab %.3f, Formschlüssel an: %s" % [
		mod.get_meta("tracht", "?"), id, t.art, t.gang, mod.global_basis.get_scale().y, ", ".join(an_schluessel(mod))])
	var ap := Gebiet.finde(mod, "AnimationPlayer") as AnimationPlayer
	if bew != "":
		spiel.held.process_mode = Node.PROCESS_MODE_DISABLED
		ap.process_mode = Node.PROCESS_MODE_ALWAYS; sk1.process_mode = Node.PROCESS_MODE_ALWAYS
		for n in sk1.get_children(): n.process_mode = Node.PROCESS_MODE_ALWAYS
		ap.play(bew, 0.0)
	for f in 80: await process_frame
	var a := await reihe(sk1, t.waffe, t.halt, ap if bew != "" else null)
	# --- Prüfaufbau (griff_alle_1694)
	var tracht := String(mod.get_meta("tracht", "WACHE_M"))
	spiel.queue_free()
	await process_frame
	var m := Gebiet.lade_glb("res://daten/held_%s.bin" % tracht)
	root.add_child(m)
	Gebiet.male(m, null, 2, [])
	var sk2 := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var h := Halt.gegenstand(id)
	var d := Halt.anlegen(sk2, "faust_r", id, "Gehalten1694")
	Gebiet.male(d, null, 2, [])
	var g := GriffHand.an(sk2, d, "r", h, GriffHand.art_von(id))
	print("WEG1694 Prüfaufbau: Körper %s, Gegenstand %s, Griffart %s, Formschlüssel an: %s" % [m.name, id, GriffHand.art_von(id), ", ".join(an_schluessel(m))])
	for f in 2: await process_frame
	var b := await reihe(sk2, d, h, null)
	# --- Tabelle
	print("WEG1694 Griffpunkt in Handkoordinaten (cm) Spielweg %s, Prüfaufbau %s; Schaftachse Spielweg %s, Prüfaufbau %s" % [
		_v(a.griff), _v(b.griff), _v(a.achse, 2), _v(b.achse, 2)])
	print("WEG1694 %-12s | %8s %8s | %8s %8s | %8s %8s | %8s %8s" % ["Glied", "Beug.Sp", "Beug.Pr", "int.Sp", "int.Pr", "netz.Sp", "netz.Pr", "n-i Sp", "n-i Pr"])
	var fehler := 0
	for gl in GLIEDER:
		var x: Dictionary = a.glied.get(gl, {}); var y: Dictionary = b.glied.get(gl, {})
		var nx := float(x.get("netz", 99.0)); var ny := float(y.get("netz", 99.0))
		var fehlt := (nx > 90.0) != (ny > 90.0)   # ein Glied ohne Netzwert am freien Griff: fehlend melden, nicht als Abstand
		var ab := 0.0 if nx > 90.0 or ny > 90.0 else absf(nx - ny)
		var schlecht: bool = ab > GRENZE
		fehler += 1 if schlecht else 0
		print("WEG1694 %-12s | %8.1f %8.1f | %8s %8s | %8s %8s | %8s %8s%s" % [gl, x.get("beug", 0.0), y.get("beug", 0.0),
			_z(x.get("intern")), _z(y.get("intern")), _z(x.get("netz")), _z(y.get("netz")),
			_z(_diff(x)), _z(_diff(y)), ("  ABWEICHUNG %.1f cm" % ab if schlecht else ("  FEHLT (Netzwert nur in einem Weg)" if fehlt else ""))])
	print("WEG1694 %d von %d Gliedern weichen über %.1f cm ab" % [fehler, GLIEDER.size(), GRENZE])
	g.free()
	quit(1 if fehler > 0 else 0)

# Median über 12 Aktualisierungen des Skeletts (Endpose nach allen Modifikatoren, NetzMess Regel 1)
func reihe(sk: Skeleton3D, ding: Node3D, halt: Dictionary, ap: AnimationPlayer) -> Dictionary:
	if ap != null:   # Gehen: an einer Stelle angehalten (griff_sicht_1694), sonst wandert die Hand je Bild weiter
		ap.speed_scale = 0.0; ap.seek(ap.get_animation(ap.assigned_animation).length * 0.25, true)
		for f in 6: await process_frame
	var werte := []
	var nach := OS.get_environment("NACHBILD1694") != ""
	var vorig := [null]
	var cb := func():
		var jetzt := ding.global_transform
		if nach and vorig[0] != null: ding.global_transform = vorig[0]
		var w := miss(sk, ding, halt) if (not nach or vorig[0] != null) else {"glied": {}}
		ding.global_transform = jetzt
		vorig[0] = jetzt
		werte.append(w)
	sk.skeleton_updated.connect(cb)
	for f in 14: await process_frame
	sk.skeleton_updated.disconnect(cb)
	werte = werte.filter(func(e): return not e.glied.is_empty())
	if werte.is_empty(): return {"griff": Vector3.ZERO, "achse": Vector3.ZERO, "glied": {}}
	var aus := {"griff": werte[werte.size() / 2].griff, "achse": werte[werte.size() / 2].achse, "glied": {}}
	for gl in GLIEDER:
		var e := {}
		for k in ["beug", "intern", "netz"]:
			var l := []
			for w in werte: if w.glied.has(gl) and w.glied[gl].has(k): l.append(w.glied[gl][k])
			if not l.is_empty(): l.sort(); e[k] = l[l.size() / 2]
		aus.glied[gl] = e
	return aus

func miss(sk: Skeleton3D, ding: Node3D, halt: Dictionary) -> Dictionary:
	var hm := halt.duplicate() if not halt.is_empty() else {"griff": Vector3.ZERO, "achse": Vector3.UP, "vorn": Vector3.RIGHT}
	var W := ding.global_transform * Halt.griff_rahmen(hm)
	var G := sk.global_transform
	var ih := sk.find_bone("hand_r")
	var H := G * sk.get_bone_global_pose(ih)
	var Hi := H.affine_inverse()
	var aus := {"griff": Hi * W.origin * 100.0, "achse": (Hi.basis * W.basis.y).normalized(), "glied": {}}
	# gezeichnet (bake)
	var n := NetzMess.griff(sk, "r", ding, halt)
	if int(n.get("ecken", 0)) == 0 or n.has("leer"): return aus
	var ne := Griff.netz_finger(sk, "r")
	for gl in GLIEDER:
		var bi := sk.find_bone(gl)
		if bi < 0: continue
		var e := {}
		var par := sk.get_bone_parent(bi)
		var lok := sk.get_bone_global_pose(par).basis.inverse() * sk.get_bone_global_pose(bi).basis if par >= 0 else Basis()
		e["beug"] = rad_to_deg(Quaternion(sk.get_bone_rest(bi).basis.orthonormalized()).angle_to(Quaternion(lok.orthonormalized())))
		if gl == "hand_r": e["netz"] = float(n.kontakt)
		elif n.has("g:" + gl): e["netz"] = float(n["g:" + gl])
		if ne.has(bi):
			var best := INF
			var P := G * sk.get_bone_global_pose(bi)
			for p in ne[bi]: best = minf(best, abstand(ding, halt, P * p))
			e["intern"] = 100.0 * minf(best, 0.99)
		aus.glied[gl] = e
	return aus

# Abstand eines Weltpunkts zur gezeichneten Oberfläche des Gegenstands (wie NetzMess.griff), INF außerhalb des freien Griffs
func abstand(ding: Node3D, halt: Dictionary, p: Vector3) -> float:
	var hm := halt.duplicate() if not halt.is_empty() else {"griff": Vector3.ZERO, "achse": Vector3.UP, "vorn": Vector3.RIGHT}
	var W := ding.global_transform * Halt.griff_rahmen(hm)
	var k := W.basis.y.length()
	var sch := Griff.schaft(ding, halt)
	var q := W.affine_inverse() * p
	var sc := int(floor(q.y / Griff.SCHEIBE))
	if not Griff.frei(sch, sc) or q.y < float(sch.lo) or q.y > float(sch.hi): return INF
	var v := Vector2(q.x, q.z) - (sch.mitte[sc] as Vector2)
	var fl := Griff.oberflaeche(sch, sc, v)
	return (v.length() - (fl if fl > 0.0 else float(sch.profil[sc]))) * k

static func formschluessel_aus(m: Node3D, nur := "1") -> void:
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var me := (mi as MeshInstance3D).mesh as ArrayMesh
		if me == null: continue
		for i in me.get_blend_shape_count():
			if nur == "1" or String(me.get_blend_shape_name(i)) == nur: (mi as MeshInstance3D).set_blend_shape_value(i, 0.0)

static func an_schluessel(m: Node3D) -> Array:
	var l := {}
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var me := (mi as MeshInstance3D).mesh as ArrayMesh
		if me == null or not (mi as MeshInstance3D).visible: continue
		for i in me.get_blend_shape_count():
			if (mi as MeshInstance3D).get_blend_shape_value(i) > 0.01: l[String(me.get_blend_shape_name(i))] = true
	return l.keys()

static func _v(v: Vector3, st := 1) -> String: return ("(%." + str(st) + "f, %." + str(st) + "f, %." + str(st) + "f)") % [v.x, v.y, v.z]
static func _z(x) -> String: return "–" if x == null or float(x) > 90.0 else "%.1f" % float(x)
static func _diff(e: Dictionary):
	if not e.has("netz") or not e.has("intern") or float(e.netz) > 90.0 or float(e.intern) > 90.0: return null
	return float(e.netz) - float(e.intern)
