extends SceneTree
# 831 (Chef 10.11., 09:10, ueber Sokrates): Bildtafel Baeume aus dem freien Stylized Nature MegaKit (CommonTree, DeadTree, Pine,
# TwistedTree, je drei Varianten) im echten Spiel: Fluesterwald, Spielkamera (Grundansicht, Bildbreite wie im Spiel), Spielshader
# (toon mit Tusche nach Licht wie unsere Laubkronen, Durchsicht), Held daneben fuer die Groesse. Links im Bild unsere Baeume (Gruppe
# 4–5/3–5), rechts der Bausatzbaum auf 7/2. Farben gedaempft (tools/godot/baeume_831.py), Groesse auf unsere Baeume verkleinert.
# Dazu je Baum die Kosten: Dreiecke und Bildzeit je Baum (40 Stueck im Bild gegen keinen, am Rechner, also nur im Verhaeltnis).
# Nur Bilder, nichts ins Spiel (Zu 831). Braucht godot/daten (tools/godot/wald_daten.sh) und die getoenten Baeume.
# Aufruf (Bildlauf, PROBE=831): xvfb-run … godot --path . -s res://tests/baeume_831.gd -- --baeume831=<ordner> [--quelle=<baeume>] [--nur=<n>]

const PLATZ := Vector2(7.5, 2.5)          # Bausatzbaum (Kachelkoordinaten), 3,3 m rechts neben unserer Baumgruppe 4–5/3–5
const HELD := Vector2i(8, 5)             # Held davor auf dem Weg, Kamera auf ihm (Bildmitte zwischen beiden)
# verkleinert auf die Hoehe unserer Baeume (Eiche bis 4,5 m, Fichte 3–3,5 m); die Varianten bleiben verschieden gross
const MASS := {"CommonTree": 0.6, "DeadTree": 0.4, "Pine": 0.6, "TwistedTree": 0.34}

var spiel
var dir := ""
var quelle := "/home/user/r831/baeume"
var nur := -1

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--baeume831="): dir = a.substr(12)
		if a.begins_with("--quelle="): quelle = a.substr(9)
		if a.begins_with("--nur="): nur = int(a.substr(6))
	DirAccess.make_dir_recursive_absolute(dir)
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.ui.mess.visible = false
	spiel.ui.oben.visible = false
	spiel.ui.leiste.visible = false
	spiel.ui.windrose.visible = false   # Tafel ohne Schild und Windrose
	spiel.ui.ort_schild.visible = false
	spiel.zustand.minuten = 10 * 60
	spiel.betrete("forest", HELD, "DOWN")
	if spiel.herde: spiel.herde.aus = true   # Bilder ohne Angriff
	await create_timer(1.5).timeout
	var liste: Array = JSON.parse_string(FileAccess.get_file_as_string(quelle + "/baeume.json"))
	var baeume: Array[Node3D] = []
	for e in liste:
		var b := lade(e)
		b.visible = false
		baeume.append(b)
	var k: Karte = spiel.karte
	var ort := Vector3(PLATZ.x * Karte.TS, 0.0, PLATZ.y * Karte.TS)
	var info := []
	# Tag: unsere Gruppe allein, dann jeder Bausatzbaum daneben
	await knips_ort("tag_unser")
	for i in baeume.size():
		if nur >= 0 and i != nur: continue
		baeume[i].position = ort
		baeume[i].visible = true
		await knips_ort("tag_%s_%d" % [liste[i]["art"], int(liste[i]["variante"])])
		baeume[i].visible = false
		if nur >= 0: quit(); return
	# Nacht: je Art die erste Variante
	spiel.licht.umschalten()
	spiel.zustand.minuten = 23 * 60
	await create_timer(2.5).timeout
	await knips_ort("nacht_unser")
	for i in range(0, baeume.size(), 3):
		baeume[i].position = ort
		baeume[i].visible = true
		await knips_ort("nacht_%s_%d" % [liste[i]["art"], int(liste[i]["variante"])])
		baeume[i].visible = false
	spiel.licht.umschalten()
	spiel.zustand.minuten = 10 * 60
	await create_timer(2.5).timeout
	# Kosten: 40 Stueck je Baum im Bild (Raster vor der Kamera), Bildzeit gegen das Bild ohne sie
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var leer := await bildzeit()
	var cam: Camera3D = spiel.kamera
	for i in baeume.size():
		var kopien: Array[Node3D] = []
		for n in 40:
			var c := baeume[i].duplicate() as Node3D
			var r := cam.global_basis.x; r.y = 0; r = r.normalized()
			var f := -cam.global_basis.z; f.y = 0; f = f.normalized()
			c.position = spiel.held.position + r * (float(n % 5) - 2.0) * 1.8 + f * (float(n / 5) * 1.6 + 1.0)
			c.visible = true
			spiel.gebiet.add_child(c)
			kopien.append(c)
		var t := await bildzeit()
		var dreiecke := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		for c in kopien: c.queue_free()
		await process_frame
		var e: Dictionary = liste[i]
		info.append({"datei": e["datei"], "dreiecke": e["dreiecke"], "flaechen": e["flaechen"], "ms_je_baum": (t - leer) / 40.0,
			"ms_leer": leer, "dreiecke_bild": dreiecke, "hoehe_m": float(e["hoehe"]) * float(MASS[e["art"]])})
		print("KOSTEN ", JSON.stringify(info[-1]))
	var fa := FileAccess.open(dir + "/kosten.json", FileAccess.WRITE)
	fa.store_string(JSON.stringify(info, " "))
	fa.close()
	print("BAEUME831 fertig")
	quit()

# glTF laden, Bilder und Stoffe wie die Baeume im Spiel: Blattkronen „laub“ (Tusche nach Licht, Durchsicht), Nadeln „laub_nadel“
# (feinere Linie wie unsere Fichte), Rinde „rinde“; dann Gebiet.male wie fuer jedes Netz der Karte
func lade(e: Dictionary) -> Node3D:
	var doc := GLTFDocument.new()
	var st := GLTFState.new()
	var err := doc.append_from_file(quelle + "/" + String(e["datei"]), st)
	if err != OK: push_error("831 glTF %s: %d" % [e["datei"], err])
	var n := doc.generate_scene(st) as Node3D
	for mi in n.find_children("*", "MeshInstance3D", true, false):
		var m := (mi as MeshInstance3D).mesh
		for s in m.get_surface_count():
			var mat := m.surface_get_material(s)
			if mat == null: continue
			var rn := String(mat.resource_name)
			if rn.begins_with("Leaves_Pine"): mat.resource_name = "laub_nadel_831"
			elif rn.begins_with("Leaves"): mat.resource_name = "laub_831"
			else: mat.resource_name = "rinde_831"
	Gebiet.male(n, spiel.gebiet)
	n.scale = Vector3.ONE * float(MASS[e["art"]])
	spiel.gebiet.add_child(n)
	return n

func knips_ort(name: String) -> void:
	spiel.held.setze(HELD, "DOWN")
	spiel.kamera.springe()
	var zu: Vector3 = spiel.kamera.global_basis.z   # zur Kamera gewandt
	spiel.held.rotation.y = atan2(zu.x, zu.z)
	await create_timer(1.2).timeout
	spiel.ui.textfeld.visible = false
	await spiel.knips("%s/%s.png" % [dir, name])

func bildzeit() -> float:
	for i in 10: await process_frame
	var t0 := Time.get_ticks_usec()
	for i in 30: await process_frame
	return float(Time.get_ticks_usec() - t0) / 30000.0
