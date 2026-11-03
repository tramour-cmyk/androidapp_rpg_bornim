class_name VoelkerProbe
extends RefCounted
# 431 Runde 3 (Chef 01.11., 11:42, „431 wie Sokrates“; Hinweis Sokrates 11:4x: Probe wie gebaut, mit Toon-Licht, Tusche nach Licht,
# Schatten wie im Spiel): die Grundkoerper je Volk aus tools/blender348/v3/voelker.py im Spiel (Licht, Kamera, Tusche, Wiese), Ruhe-
# bewegung wie der Held (HeldFigur.bewegungen, Becken im Verhaeltnis), langsam drehend. Zahlen und Titel setzt voelker_film.py dazu.
# Am Rechner: VOELKER=<ordner> godot --path godot --resolution 1080x720 -- --figuren=<ausgabe> --teil=voelker
#   <ausgabe>/voelker/<teil>/<nnnn>.png; Teile: maenner, frauen (12 s, eine Umdrehung), huegel (Mensch, Huegelvolk Mann und Frau,
#   Goblin; 8 s), riss_vorn, riss_seite (Schattenriss der Maenner, je 3 s); <ausgabe>/voelker/lage.json: Bildmitte jeder Figur
const REIHE := ["Mensch", "Elf", "Zwerg", "Hügelvolk", "Orkblütiger"]
const FPS := 30.0
const ABSTAND := 0.85      # m zwischen den Figuren einer Reihe
const BREITE := 4.4        # m Bildbreite (Kamera.zoom), 5 Figuren
const MITTE_Y := 0.1       # Kamera sieht auf diese Hoehe + 0,9 (Kamera nah)

var fp: FigurenProbe
var dir := OS.get_environment("VOELKER")
var daten := {}            # "Volk/mann|frau" -> Eintrag aus voelker.json
var reihen := {}           # Teil -> [Marker, [Figuren]]
var lage := {}

func _init(p: FigurenProbe) -> void: fp = p

func film() -> void:
	var j: Variant = JSON.parse_string(FileAccess.get_file_as_string(dir.path_join("voelker.json")))
	if not j is Dictionary:
		fp.protokoll.append("FEHLT voelker.json unter VOELKER=" + dir)
		return
	for e in j["voelker"]: daten["%s/%s" % [e["volk"], "frau" if e["frau"] else "mann"]] = e
	fp.freie_wiese()
	fp.spiel.held.visible = false
	var ort: Vector3 = fp.spiel.karte.kachel_pos(FigurenProbe.FILM_ORT)
	_reihe("maenner", REIHE.map(func(v): return v + "/mann"), ort + Vector3(-11, 0, 0))
	_reihe("frauen", REIHE.map(func(v): return v + "/frau"), ort + Vector3(-4, 0, 0))
	_reihe("huegel", ["Mensch/mann", "Hügelvolk/mann", "Hügelvolk/frau", "goblin"], ort + Vector3(3, 0, 0))
	_reihe("riss", REIHE.map(func(v): return v + "/mann"), ort + Vector3(10, 0, 0))
	var schwarz := StandardMaterial3D.new()
	schwarz.albedo_color = Color.BLACK
	schwarz.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for f in reihen["riss"][1]:
		for m in (f as Node3D).find_children("*", "MeshInstance3D", true, false):
			(m as MeshInstance3D).material_override = schwarz
	_hintergrund(reihen["riss"][0].position)
	await fp.get_tree().create_timer(1.0).timeout
	await _laufen(["maenner", "frauen"], 12.0, true)
	await _laufen(["huegel"], 8.0, true)
	await _laufen(["riss"], 3.0, false, "riss_vorn")
	for f in reihen["riss"][1]: (f as Node3D).rotation_degrees.y = 90.0
	await _laufen(["riss"], 3.0, false, "riss_seite")
	FileAccess.open(fp.aus + "/voelker/lage.json", FileAccess.WRITE).store_string(JSON.stringify(lage, " "))


func _reihe(teil: String, keys: Array, x0: Vector3) -> void:
	var marker := Node3D.new()
	fp.spiel.add_child(marker)
	marker.position = x0 + Vector3((keys.size() - 1) * ABSTAND / 2.0, MITTE_Y, 0)
	var figs := []
	var eintraege := []
	for i in keys.size():
		var w := Node3D.new()
		fp.spiel.add_child(w)
		w.position = x0 + Vector3(i * ABSTAND, 0, 0)
		var m: Node3D
		var e: Dictionary = daten.get(keys[i], {})
		if keys[i] == "goblin":
			if not FileAccess.file_exists(dir.path_join("goblin.glb")): w.free(); continue
			m = Gebiet.lade_glb(dir.path_join("goblin.glb"))
			Gebiet.male(m, null, 2, [])
			w.add_child(m)
			var gap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
			if gap and not gap.get_animation_list().is_empty(): gap.play(gap.get_animation_list()[0])
			e = {"volk": "Goblin", "datei": "goblin.glb"}
		else:
			if e.is_empty(): w.free(); fp.protokoll.append("FEHLT " + keys[i]); continue
			m = Gebiet.lade_glb(dir.path_join(String(e["datei"])))
			var mats := []
			Gebiet.male(m, null, 2, mats)
			for x in mats: (x as ShaderMaterial).set_shader_parameter("fill", 0.42)   # wie klasse_figur (Held)
			w.add_child(m)
			var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
			sk.add_child(FigurenProbe.KopfHeben.new())
			var f := HeldFigur.bewegungen(m, sk)
			var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
			ap.play("Stehen")
			var soll: float = float(e["ziel"]["h"]) * (0.93 if e["frau"] else 1.0)
			_ziel_linie(w, soll)
			fp.protokoll.append("VOLK %s %s: Becken-Faktor %.3f, Hoehe %.3f m" % [teil, keys[i], f, float(e["groesse_m"])])
		figs.append(w)
		eintraege.append(e)
	reihen[teil] = [marker, figs, eintraege]


# Goldstrich in Homers Groesse hinter der Figur (dreht nicht mit)
func _ziel_linie(w: Node3D, h: float) -> void:
	var m := MeshInstance3D.new()
	m.name = "Ziel"
	var bm := BoxMesh.new()
	bm.size = Vector3(0.5, 0.008, 0.008)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.83, 0.68, 0.36)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bm.material = mat
	m.mesh = bm
	fp.spiel.add_child(m)
	m.position = w.position + Vector3(0, h, -0.45)


# heller Grund hinter dem Schattenriss
func _hintergrund(mitte: Vector3) -> void:
	var m := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(6.0, 4.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.82, 0.78, 0.7)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	q.material = mat
	m.mesh = q
	fp.spiel.add_child(m)
	m.position = Vector3(mitte.x, 1.6, mitte.z - 1.2)


func _kamera(marker: Node3D) -> void:
	var kam := fp.spiel.kamera as Kamera
	kam.ziel = marker
	kam.nah = true
	kam.gieren_ziel = 0.0
	kam.neigung = -6.0
	kam.zoom = BREITE
	kam.springe()


func _laufen(teile: Array, sek: float, drehen: bool, name := "") -> void:
	var n := int(round(sek * FPS))
	for t in teile: DirAccess.make_dir_recursive_absolute(fp.aus + "/voelker/" + (name if name != "" else String(t)))
	for i in n:
		var zeit := i / FPS
		for t in teile:
			for w in reihen[t][1]:
				if drehen: (w as Node3D).rotation.y = TAU * zeit / sek
				var ap := Gebiet.finde(w, "AnimationPlayer") as AnimationPlayer
				if ap and ap.assigned_animation != "":
					var lang := ap.get_animation(ap.assigned_animation).length
					ap.pause()   # erst anhalten, dann springen (tragprobe.gd)
					ap.seek(fmod(zeit, lang), true)
		await fp.get_tree().process_frame
		for t in teile:
			_kamera(reihen[t][0])
			await RenderingServer.frame_post_draw
			await RenderingServer.frame_post_draw
			var ordner: String = name if name != "" else String(t)
			fp.spiel.get_viewport().get_texture().get_image().save_png(fp.aus + "/voelker/%s/%04d.png" % [ordner, i])
			if i == 0:   # Bildmitte jeder Figur fuer die Zahlen (voelker_film.py)
				var cam := fp.spiel.kamera as Camera3D
				var l := []
				for k in reihen[t][1].size():
					var w: Node3D = reihen[t][1][k]
					var e: Dictionary = reihen[t][2][k]
					l.append({"x": cam.unproject_position(w.global_position).x, "boden_y": cam.unproject_position(w.global_position).y,
						"eintrag": e})
				lage[ordner] = l
	fp.protokoll.append("TEIL %s %d Bilder" % [name if name != "" else ", ".join(PackedStringArray(teile)), n])
	print(fp.protokoll[-1])
