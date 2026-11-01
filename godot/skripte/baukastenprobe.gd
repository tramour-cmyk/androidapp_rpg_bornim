class_name BaukastenProbe
extends RefCounted
# 455.1 Probeblatt Baukasten (Chef 01.11., 11:24; Archiv 455): je ein vorhandenes Netz (Robe, Umhang, Beine mit Stiefeln, Arme) in drei
# Materialien x zwei Zeichen, Mann und Frau, wie im Spiel gezeichnet (HeldFigur.baue: Toon-Licht, Tusche nach Licht, Schatten, Wiese).
# Das Netz bleibt, Godot tauscht nur das Farbbild (baukasten455.py) und liest die Art aus dessen Alpha (toon.gdshader bild_code).
# Je Netz und Geschlecht ein Streifen mit sechs Figuren, stehend; Titel und Namen setzt baukasten_blatt.py dazu.
# Am Rechner: godot --path godot --resolution 1440x960 -- --figuren=<ausgabe> --teil=baukasten --baukasten=<ordner mit baukasten.json>
#   <ausgabe>/baukasten/<netz>_<g>.png, <ausgabe>/baukasten/lage.json
const ABSTAND := 0.85      # m zwischen den Figuren
const RAND := 0.4          # m links und rechts
const MITTE_Y := 0.95
const HERKUNFT := {"ROBE": "ZAUBERLEHRLING", "WACHE": "WACHSOLDAT", "WALD": "HERUMTREIBER"}
const KLASSE := {"ZAUBERLEHRLING": "WIZARD", "WACHSOLDAT": "FIGHTER", "HERUMTREIBER": "ROGUE"}
const DREHUNG := {"vorn": 0.35, "hinten": PI - 0.35}   # Ansicht schraeg von vorn, Umhang schraeg von hinten

var fp: FigurenProbe
var quelle := ""
var lage := {}

func _init(p: FigurenProbe) -> void:
	fp = p
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--baukasten="): quelle = a.substr(12)


func blatt() -> void:
	var info = JSON.parse_string(FileAccess.get_file_as_string(quelle + "/baukasten.json")) if quelle != "" else null
	if info == null:
		fp.protokoll.append("FEHLT baukasten.json in " + quelle)
		return
	if HeldFigur.lade_info().get("herkuenfte", {}).is_empty():
		fp.protokoll.append("FEHLT held-klassen.json mit herkuenfte (held_klassen.py)")
		return
	fp.freie_wiese()
	fp.spiel.held.visible = false
	DirAccess.make_dir_recursive_absolute(fp.aus + "/baukasten")
	var ort: Vector3 = fp.spiel.karte.kachel_pos(FigurenProbe.FILM_ORT)
	for netz in info["netze"]:
		for g in ["M", "W"]:
			var liste: Array = (netz["bilder"] as Dictionary).get(g, [])
			if liste.is_empty():
				fp.protokoll.append("FEHLT %s %s" % [netz["netz"], g])
				continue
			await _streifen(netz, g, liste, ort)
	FileAccess.open(fp.aus + "/baukasten/lage.json", FileAccess.WRITE).store_string(JSON.stringify({"lage": lage, "info": info}, " "))


# Spalten: je Material und Zeichen (Reihenfolge wie baukasten.json); ein Eintrag je bemaltes Teil (Netz, Material im glb, Bild)
func _spalten(netz: Dictionary, liste: Array) -> Array:
	var sp := []
	for mat in netz["mats"]:
		for z in ["borte", "runen"]:
			var teile := []
			for e in liste:
				if e["mat"] == mat and e["zeichen"] == z: teile.append(e)
			sp.append({"mat": mat, "zeichen": z, "teile": teile})
	return sp


func _streifen(netz: Dictionary, g: String, liste: Array, ort: Vector3) -> void:
	var name := "%s_%s" % [netz["netz"], g]
	var h := String(HERKUNFT.get(netz["tracht"], "WACHSOLDAT"))
	var k := String(KLASSE[h])
	var sp := _spalten(netz, liste)
	var n := sp.size()
	var marker := Node3D.new()
	fp.spiel.add_child(marker)
	marker.position = ort + Vector3(0, MITTE_Y, 0)
	var figs := []
	for i in n:
		var a := HeldFigur.vorgabe(k, g.to_lower())
		if g == "W": a["frisur"] = "Hair_Long"
		a["statur"] = "normal"
		var mats := []
		var m := HeldFigur.baue({"klasse": k, "herkunft": h, "volk": "HUMAN", "aussehen": a, "ausruestung": {}}, mats)
		if m == null:
			fp.protokoll.append("FEHLT Figur %s %s" % [h, g])
			continue
		for mt in mats:
			(mt as ShaderMaterial).set_shader_parameter("fill", 0.42)     # wie klasse_figur (Held)
			(mt as ShaderMaterial).set_shader_parameter("metall", 1.0)    # wie held.gd: Glanz an Kette und Metall
		var getauscht := _tausche(m, sp[i]["teile"])
		fp.protokoll.append("FIGUR %s %s %s %s: %d Flaechen getauscht (%s)" % [netz["netz"], g, sp[i]["mat"], sp[i]["zeichen"], getauscht,
			String(m.get_meta("tracht", ""))])
		if getauscht == 0: fp.protokoll.append("FEHLT Tausch %s %s %s %s" % [netz["netz"], g, sp[i]["mat"], sp[i]["zeichen"]])
		var w := Node3D.new()
		fp.spiel.add_child(w)
		w.position = ort + Vector3((i - (n - 1) / 2.0) * ABSTAND, 0, 0)
		w.rotation.y = float(DREHUNG.get(netz.get("ansicht", "vorn"), 0.35))
		w.add_child(m)
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		if ap and ap.has_animation("Stehen"):
			ap.play("Stehen")
			ap.pause()   # erst anhalten, dann springen (tragprobe.gd)
			ap.seek(0.6, true)
		figs.append(w)
	await fp.get_tree().process_frame
	var kam := fp.spiel.kamera as Kamera
	kam.ziel = marker
	kam.nah = true
	kam.gieren_ziel = 0.0
	kam.neigung = -6.0
	kam.zoom = (n - 1) * ABSTAND + 2 * RAND + 0.6
	kam.springe()
	for _j in 4: await RenderingServer.frame_post_draw
	fp.spiel.get_viewport().get_texture().get_image().save_png(fp.aus + "/baukasten/%s.png" % name)
	var cam := fp.spiel.kamera as Camera3D
	var l := []
	for i in figs.size():
		var w: Node3D = figs[i]
		l.append({"x": cam.unproject_position(w.global_position).x, "boden_y": cam.unproject_position(w.global_position).y,
			"kopf_y": cam.unproject_position(w.global_position + Vector3(0, 1.9, 0)).y, "mat": sp[i]["mat"], "zeichen": sp[i]["zeichen"]})
	lage[name] = l
	fp.protokoll.append("STREIFEN %s %d Figuren" % [name, figs.size()])
	print(fp.protokoll[-1])
	for w in figs: (w as Node3D).queue_free()
	marker.queue_free()
	await fp.get_tree().process_frame


# Bild der bemalten Teile tauschen: Netz nach Namen, Flaeche nach dem Material im glb; bild_code liest die Art aus dem Alpha
func _tausche(m: Node, teile: Array) -> int:
	var n := 0
	if m is MeshInstance3D:
		var mi := m as MeshInstance3D
		for e in teile:
			if not String(mi.name).begins_with(String(e["netz"])): continue
			for i in mi.mesh.get_surface_count():
				var src := mi.mesh.surface_get_material(i)
				var rn := String(src.resource_name) if src else ""
				if rn != String(e["material"]) and mi.mesh.get_surface_count() > 1: continue
				var sm := mi.get_surface_override_material(i) as ShaderMaterial
				if sm == null: continue
				sm.set_shader_parameter("tex", _bild(String(e["bild"])))
				sm.set_shader_parameter("bild_code", 1.0)
				n += 1
	for c in m.get_children(): n += _tausche(c, teile)
	return n


var _bilder := {}
func _bild(datei: String) -> Texture2D:
	if _bilder.has(datei): return _bilder[datei]
	var img := Image.new()
	if img.load_png_from_buffer(FileAccess.get_file_as_bytes(quelle + "/" + datei)) != OK:
		fp.protokoll.append("FEHLT Bild " + datei)
		return null
	img.generate_mipmaps()
	var t := ImageTexture.create_from_image(img)
	_bilder[datei] = t
	return t
