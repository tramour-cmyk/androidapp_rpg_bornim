class_name GroessenProbe
extends RefCounted
# 455.2 Groessenfilm (Chef 01.11., 11:21; Archiv 455): Hügelvolk und Orkblütiger, Mann und Frau, je in Kette (Wachsoldat), Platte
# (Ritter) und Robe (Zauberlehrling), daneben der Mensch in derselben Tracht; die Kleidung ueber Knochenlaengen mitgewachsen
# (volk_tracht.py). Wie im Spiel gezeichnet (Toon-Licht, Tusche, Wiese), langsam drehend in der Ruhebewegung, Goldlinie = Zielgroesse.
# Wie voelkerprobe.gd (431). Am Rechner: VOELKER=<ordner mit volk_tracht.json> godot --path godot -- --figuren=<ausgabe> --teil=groessen
#   <ausgabe>/groessen/<reihe>/<nnnn>.png, <ausgabe>/groessen/lage.json
const FPS := 30.0
const DAUER := 10.0
const ABSTAND := 1.0
const MITTE_Y := 0.1
const REIHEN := {"kette": "WACHE", "platte": "RITTER", "robe": "ROBE"}
const SPALTEN := [["mensch", "M"], ["huegel", "M"], ["ork", "M"], ["mensch", "W"], ["huegel", "W"], ["ork", "W"]]

var fp: FigurenProbe
var dir := OS.get_environment("VOELKER")
var daten := {}
var reihen := {}
var lage := {}
var _ansicht := Vector2.ZERO   # Lage in Ansichtspunkten; das Bild hat --resolution (455.1 Lauf 41321140618)

func _init(p: FigurenProbe) -> void: fp = p

func film() -> void:
	var j: Variant = JSON.parse_string(FileAccess.get_file_as_string(dir.path_join("volk_tracht.json")))
	if not j is Dictionary:
		fp.protokoll.append("FEHLT volk_tracht.json unter VOELKER=" + dir)
		return
	for e in j["figuren"]: daten["%s/%s/%s" % [e["volk_kurz"], e["tracht"], e["geschlecht"]]] = e
	fp.freie_wiese()
	fp.spiel.held.visible = false
	var ort: Vector3 = fp.spiel.karte.kachel_pos(FigurenProbe.FILM_ORT)
	var x := -9.0
	for r in REIHEN:
		_reihe(r, String(REIHEN[r]), ort + Vector3(x, 0, 0))
		x += 7.5
	await fp.get_tree().create_timer(1.0).timeout
	for r in REIHEN: await _laufen(r)
	FileAccess.open(fp.aus + "/groessen/lage.json", FileAccess.WRITE).store_string(JSON.stringify({"lage": lage, "ansicht": [_ansicht.x, _ansicht.y]}, " "))


func _reihe(r: String, t: String, x0: Vector3) -> void:
	var marker := Node3D.new()
	fp.spiel.add_child(marker)
	marker.position = x0 + Vector3((SPALTEN.size() - 1) * ABSTAND / 2.0, MITTE_Y, 0)
	var figs := []
	var eintraege := []
	for i in SPALTEN.size():
		var key := "%s/%s/%s" % [SPALTEN[i][0], t, SPALTEN[i][1]]
		var e: Dictionary = daten.get(key, {})
		if e.is_empty():
			fp.protokoll.append("FEHLT " + key)
			continue
		var w := Node3D.new()
		fp.spiel.add_child(w)
		w.position = x0 + Vector3(i * ABSTAND, 0, 0)
		var m := Gebiet.lade_glb(dir.path_join(String(e["datei"])))
		var mats := []
		Gebiet.male(m, null, 2, mats)
		for mt in mats:
			(mt as ShaderMaterial).set_shader_parameter("fill", 0.42)    # wie klasse_figur (Held)
			(mt as ShaderMaterial).set_shader_parameter("metall", 1.0)   # wie held.gd
		w.add_child(m)
		var a := HeldFigur.vorgabe("FIGHTER", String(SPALTEN[i][1]).to_lower())
		HeldFigur.toene(m, a, "HUMAN")
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		sk.add_child(FigurenProbe.KopfHeben.new())
		HeldFigur.bewegungen(m, sk)
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		if ap and ap.has_animation("Stehen"): ap.play("Stehen")
		_ziel_linie(w, float(e["ziel_m"]))
		fp.protokoll.append("FIGUR %s %s: %.3f m (Ziel %.3f)" % [r, key, float(e["groesse_m"]), float(e["ziel_m"])])
		figs.append(w)
		eintraege.append(e)
	reihen[r] = [marker, figs, eintraege]


func _ziel_linie(w: Node3D, h: float) -> void:
	var m := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.6, 0.008, 0.008)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.83, 0.68, 0.36)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bm.material = mat
	m.mesh = bm
	fp.spiel.add_child(m)
	m.position = w.position + Vector3(0, h, -0.5)


func _laufen(r: String) -> void:
	var n := int(round(DAUER * FPS))
	DirAccess.make_dir_recursive_absolute(fp.aus + "/groessen/" + r)
	var kam := fp.spiel.kamera as Kamera
	for i in n:
		var zeit := i / FPS
		for w in reihen[r][1]:
			(w as Node3D).rotation.y = TAU * zeit / DAUER
			var ap := Gebiet.finde(w, "AnimationPlayer") as AnimationPlayer
			if ap and ap.assigned_animation != "":
				var lang := ap.get_animation(ap.assigned_animation).length
				ap.pause()
				ap.seek(fmod(zeit, lang), true)
		await fp.get_tree().process_frame
		kam.ziel = reihen[r][0]
		kam.nah = true
		kam.gieren_ziel = 0.0
		kam.neigung = -6.0
		kam.zoom = (SPALTEN.size() - 1) * ABSTAND + 1.3
		kam.springe()
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		fp.spiel.get_viewport().get_texture().get_image().save_png(fp.aus + "/groessen/%s/%04d.png" % [r, i])
		if i == 0:
			_ansicht = fp.spiel.get_viewport().get_visible_rect().size
			var cam := fp.spiel.kamera as Camera3D
			var l := []
			for k in reihen[r][1].size():
				var w: Node3D = reihen[r][1][k]
				l.append({"x": cam.unproject_position(w.global_position).x, "eintrag": reihen[r][2][k]})
			lage[r] = l
	fp.protokoll.append("REIHE %s %d Bilder" % [r, n])
	print(fp.protokoll[-1])
