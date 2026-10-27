class_name FigurenProbe
extends Node
# 376.1 Probeblatt Quaternius-Figuren (Chef kaufte 27.10., 12:20): Figuren aus tools/blender348/v3/quaternius.py mit unserem Look
# (Toon, Tusche, Licht) neben dem heutigen Helden im Dorf, Bewegungen aus der Universal Animation Library auf denselben Knochen.
# Am Rechner: godot --path godot -- --figuren=<ausgabe> --quelle=<ordner mit q_*.glb> --ual=<UAL1*.glb> [--teil=reihe|film]
#   reihe: Standbilder Reihe (Grundansicht, weit, nah, Nacht, Menue) als <ausgabe>/reihe_*.png
#   film:  je Feld (Bewegung x Figur) Bilder <ausgabe>/film/<nn>_<feld>/<bild>.png, 30 je s, Ausschnitt um die Figur
# Nur Probe, nicht im Spiel.

# Helfer Film 15:37: Schwertspitze unter dem Kopfbalken (6), Fuss und Hand am Rand (9, 14): Feld groesser
const FELD_PX := Vector2i(680, 1040)       # Ausschnitt je Feld in der Nahstufe (Bild 1080 breit, 3,4 m: 318 px je m)
const FUSS_UNTEN := 320                     # Bildpunkte unter dem Fuss (Helfer Film 14:58: Tod nach vorn rutschte bei 120 unten hinaus)
const FPS := 30.0
const PLATZ := Vector2i(19, 13)            # Dorfplatz am Brunnen
# Helfer Film 15:37: angeschnittene Bank in jedem Feld, Tod fiel hinein, Sitzen ohne Sitz: Film auf freiem Gras (Probeort „gras“
# in spiel.gd), Sitzen auf der Bank westlich am Platz (dorf.py bench: Sitz 47 cm, Blick zur Platzmitte)
const FILM_ORT := Vector2i(10, 17)
const BANK := Vector2i(14, 16)
const SITZ_HOEHE := 0.47

# Bewegungen der UAL: erste vorhandene gilt (gekauft UAL Pro, frei UAL1_Standard)
const UAL := {
	"Stehen": ["Idle_Loop"], "Gehen": ["Walk_Loop"], "Rennen": ["Jog_Fwd_Loop"],
	"Sitzen": ["Sitting_Idle_Loop"], "Gesten": ["Idle_Talking_Loop"],
	"Hieb": ["Sword_Attack_Standing", "Sword_Attack"], "Stich": [],
	"Ausweichen": ["Dodge_Left", "Roll"], "Treffer": ["Hit_Chest"], "Tod": ["Death02", "Death01"],
	"Kampfstehen": ["Sword_Idle"],
}
const KAMPF := ["Hieb", "Stich", "Ausweichen", "Treffer", "Tod", "Kampfstehen"]
# Raster: [Figur, Bewegung]; "held" = unser Held (Runde 7), sonst Kennung aus quaternius.py
const FELDER := [
	["q_held", "Stehen"], ["q_held", "Gehen"], ["q_held", "Rennen"], ["q_bauer", "Sitzen"], ["q_bauer", "Gesten"],
	["q_held", "Hieb"], ["held", "Hieb"], ["held", "Stich"], ["q_held", "Ausweichen"], ["held", "Ausweichen"],
	["q_held", "Treffer"], ["held", "Treffer"], ["q_held", "Tod"], ["held", "Tod"], ["q_held", "Kampfstehen"],
]
const REIHE := ["held", "q_held", "q_bauer", "q_baeuerin", "q_zwerg", "q_elf", "q_halbling", "q_halbork"]
# Chef 15:23: eine Kauffigur in unserer Kleidung (kauf_kleid.py); 14:44 Koepfe: schmal/rund, ohne/mit Bart
const TRACHT := ["held", "q_tracht", "q_held"]
const KOEPFE := ["q_tracht", "q_tracht_b", "q_tracht_r", "q_tracht_rb"]
const FELDER_TRACHT := [
	["q_tracht", "Stehen"], ["q_tracht", "Gehen"], ["q_tracht", "Rennen"], ["q_tracht", "Gesten"],
	["q_tracht", "Hieb"], ["q_tracht", "Ausweichen"], ["q_tracht", "Treffer"], ["q_tracht", "Tod"],
]

var spiel: Node3D
var aus := ""
var quelle := ""
var ual_pfad := ""
var teil := ""
var nur: Array[int] = []                   # --nur=6,13: nur diese Felder des Films (Probe einzelner Felder)
var ual_lib: AnimationLibrary
var ual_becken := 1.0                      # Laenge der Ruhelage des Beckens in der UAL (Hoehe)
var figuren := {}                          # kennung -> Node3D
var mats := {}                             # kennung -> Array der Materialien
var protokoll: Array = []

static func an() -> bool:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--figuren="): return true
	return false

func _init(s: Node3D) -> void:
	spiel = s
	name = "FigurenProbe"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--figuren="): aus = a.substr(10)
		elif a.begins_with("--quelle="): quelle = a.substr(9)
		elif a.begins_with("--ual="): ual_pfad = a.substr(6)
		elif a.begins_with("--teil="): teil = a.substr(7)
		elif a.begins_with("--nur="):
			for x in a.substr(6).split(","): nur.append(int(x))

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(aus)
	spiel.ui.visible = false
	if spiel.leute: spiel.leute.visible = false
	lade_ual()
	for k in REIHE + TRACHT + KOEPFE:
		if k != "held" and k not in figuren: lade_figur(k)
	await get_tree().create_timer(1.0).timeout
	if teil in ["", "reihe"]: await reihe()
	if teil in ["", "film"]: await film(FELDER)
	if teil == "tracht": await tracht()
	if teil == "trachtfilm": await film(FELDER_TRACHT)
	var f := FileAccess.open(aus + "/probe.txt", FileAccess.WRITE)
	f.store_string("\n".join(protokoll) + "\n")
	get_tree().quit()

func lade_ual() -> void:
	var sc := Gebiet.lade_glb(ual_pfad)
	var ap := Gebiet.finde(sc, "AnimationPlayer") as AnimationPlayer
	var sk := Gebiet.finde(sc, "Skeleton3D") as Skeleton3D
	ual_becken = sk.get_bone_rest(sk.find_bone("pelvis")).origin.length()
	ual_lib = AnimationLibrary.new()
	for n in ap.get_animation_list():
		ual_lib.add_animation(n, ap.get_animation(n).duplicate(true))
	protokoll.append("UAL %s: %d Bewegungen" % [ual_pfad.get_file(), ap.get_animation_list().size()])
	sc.free()

func ual_name(bew: String) -> String:
	for n in UAL.get(bew, []):
		if ual_lib.has_animation(n): return n
	return ""

func lade_figur(k: String) -> void:
	var p := quelle + "/" + k + ".glb"
	if not FileAccess.file_exists(p): protokoll.append("FEHLT " + p); return
	var m := Gebiet.lade_glb(p)
	var w := Node3D.new()
	w.name = k
	w.add_child(m)
	spiel.add_child(w)
	var ms: Array = []
	Gebiet.male(m, null, 2, ms)
	for x in ms: (x as ShaderMaterial).set_shader_parameter("fill", 0.42)
	mats[k] = ms
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	# Bewegungen der UAL auf diese Knochen: nur Drehungen (die Laengen sind die der Figur); das Becken bewegt sich mit,
	# im Verhaeltnis der Beckenhoehe (Halbling, Zwerg)
	var f := sk.get_bone_rest(sk.find_bone("pelvis")).origin.length() / ual_becken
	var lib := AnimationLibrary.new()
	var pfad := String(m.get_path_to(sk))
	for n in ual_lib.get_animation_list():
		var a := ual_lib.get_animation(n).duplicate(true) as Animation
		for t in range(a.get_track_count() - 1, -1, -1):
			var tp := String(a.track_get_path(t))
			var bn := tp.get_slice(":", 1)
			a.track_set_path(t, NodePath("%s:%s" % [pfad, bn]))
			var ty := a.track_get_type(t)
			if ty == Animation.TYPE_SCALE_3D or (ty == Animation.TYPE_POSITION_3D and bn not in ["pelvis", "root"]):
				a.remove_track(t)
			elif ty == Animation.TYPE_POSITION_3D:
				for i in a.track_get_key_count(t): a.track_set_key_value(t, i, a.track_get_key_value(t, i) * f)
		lib.add_animation(n, a)
	var ap := AnimationPlayer.new()
	ap.name = "AnimationPlayer"
	m.add_child(ap)
	ap.root_node = ap.get_path_to(m)
	ap.add_animation_library("", lib)
	for n in ["Idle_Loop", "Walk_Loop", "Jog_Fwd_Loop", "Sitting_Idle_Loop", "Idle_Talking_Loop", "Sword_Idle"]:
		if lib.has_animation(n): lib.get_animation(n).loop_mode = Animation.LOOP_LINEAR
	ap.play("Idle_Loop")
	figuren[k] = w
	var dr := 0
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var me := (mi as MeshInstance3D).mesh
		for s in me.get_surface_count():
			var arr := me.surface_get_arrays(s)
			dr += (arr[Mesh.ARRAY_INDEX].size() if arr[Mesh.ARRAY_INDEX] else arr[Mesh.ARRAY_VERTEX].size()) / 3
	protokoll.append("FIGUR %s %d Dreiecke, Becken x%.2f" % [k, dr, f])

# Schwert in der rechten Faust laengs faust_R (held-info.json, wie kampfblatt.py), Schild am linken Unterarm wie figur.gd
func bewaffne(k: String, an: bool) -> void:
	var w: Node3D = spiel.held if k == "held" else figuren[k]
	var sk := Gebiet.finde(w, "Skeleton3D") as Skeleton3D
	for alt in sk.find_children("Waffe*", "", true, false): alt.queue_free()
	if not an: return
	var info: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/held-info.json"))
	var fr: Dictionary = info["faust_R"]
	var ax := Vector3(fr["achse"][0], fr["achse"][1], fr["achse"][2]).normalized()
	var g := Vector3(fr["griff"][0], fr["griff"][1], fr["griff"][2])
	# Quaternius-Hand (Helfer 16:36: Klinge im Hals, in Ruhe nach hinten): faust_R gilt fuer unsere Hand; hier aus der Ruhelage,
	# Klinge vom Knoechel des kleinen Fingers zum Zeigefinger, Griff zwischen beiden
	if k != "held" and sk.find_bone("index_01_r") >= 0 and sk.find_bone("pinky_01_r") >= 0:
		var hr := sk.get_bone_global_rest(sk.find_bone("hand_r")).affine_inverse()
		var zf := hr * sk.get_bone_global_rest(sk.find_bone("index_01_r")).origin
		var kf := hr * sk.get_bone_global_rest(sk.find_bone("pinky_01_r")).origin
		ax = (zf - kf).normalized()
		g = (zf + kf) * 0.5
		protokoll.append("GRIFF %s achse %s griff %s" % [k, ax, g])
	var edge := (Vector3.UP - ax * ax.y).normalized()
	haenge(sk, "hand_r", "longsword", Transform3D(Basis(edge, ax, edge.cross(ax)), g), "WaffeR")
	# Quaternius: ohne Schild, die UAL hat keine Schildhaltung (Helfer Film: Schild wie ein Tablett, von der Kante wie eine zweite Klinge)
	if k != "held": return
	# Schild: in der Ruhelage der Hand x vorn (+Z der Figur), y oben, z aussen (+X), 0,35 * 15,7 cm am Knochen, 4 cm aussen
	var bi := sk.find_bone("hand_l")
	var rl := sk.get_bone_global_rest(bi)
	var t := Transform3D(Basis(Vector3.BACK, Vector3.UP, Vector3.RIGHT), rl * Vector3(0, 0.157 * 0.35, 0) + Vector3(0.04, 0, 0))
	haenge(sk, "hand_l", "shield", rl.affine_inverse() * t, "WaffeL")

func haenge(sk: Skeleton3D, knochen: String, was: String, t: Transform3D, nm: String) -> void:
	var p := "res://daten/waffen/%s.bin" % was
	if not FileAccess.file_exists(p): protokoll.append("FEHLT " + p); return
	var ba := BoneAttachment3D.new()
	ba.name = nm
	ba.bone_name = knochen
	sk.add_child(ba)
	var d := Gebiet.lade_glb(p)
	d.transform = t
	ba.add_child(d)
	Gebiet.male(d, null, 2, [])

func spieler(k: String) -> AnimationPlayer:
	if k == "held": return spiel.held.anim
	return Gebiet.finde(figuren[k], "AnimationPlayer") as AnimationPlayer

func bew_name(k: String, bew: String) -> String:
	if k == "held": return bew if spiel.held.anim.has_animation(bew) else ""
	return ual_name(bew)

# alle Figuren weg, nur die genannten an ihren Platz (Reihe quer zum Bild, mit Blick halb zur Kamera)
func stelle(ks: Array, abstand: float, mitte: Vector3) -> void:
	var kam: Kamera = spiel.kamera
	var rechts := kam.global_basis.x; rechts.y = 0; rechts = rechts.normalized()
	var zur := kam.global_basis.z; zur.y = 0; zur = zur.normalized()
	var blick := atan2(zur.x, zur.z) + deg_to_rad(20.0)
	spiel.held.visible = "held" in ks
	for k in figuren: figuren[k].visible = k in ks
	for i in ks.size():
		var p := mitte + rechts * (i - (ks.size() - 1) * 0.5) * abstand
		var w: Node3D = spiel.held if ks[i] == "held" else figuren[ks[i]]
		if ks[i] == "held":
			spiel.held.weg.clear()
			spiel.held.position = p
		else: w.position = p
		w.rotation.y = blick

func zielpunkt(p: Vector3) -> Node3D:
	var z := Node3D.new()
	spiel.add_child(z)
	z.position = p
	return z

func zoom(z: float) -> void:
	var kam: Kamera = spiel.kamera
	kam.zoom = z
	kam.nah = z < (Kamera.NAH + Kamera.FERN) * 0.5

func knips(p: String) -> void:
	await RenderingServer.frame_post_draw
	spiel.get_viewport().get_texture().get_image().save_png(p)
	protokoll.append("BILD " + p)

func nacht(an: bool) -> void:
	if (spiel.licht.ziel > 0.5) != an: spiel.licht.umschalten()
	for k in mats:
		for m in mats[k]: (m as ShaderMaterial).set_shader_parameter("fill", 0.0 if an else 0.42)

# Reihe vor dem Brunnen, zur Kamera und nach links versetzt (Helfer 13:45: der Halbork stand rechts im Marktstand)
func platz() -> Vector3:
	var kam: Kamera = spiel.kamera
	var rechts := kam.global_basis.x; rechts.y = 0
	var zur := kam.global_basis.z; zur.y = 0
	return spiel.karte.kachel_pos(PLATZ) + Vector3(0, 0, 1.2) + zur.normalized() * 1.5 - rechts.normalized() * 1.1

func reihe() -> void:
	var mitte := platz()
	var z := zielpunkt(mitte)
	spiel.kamera.ziel = z
	for k in REIHE: spiel_bew(k, "Stehen")
	stelle(REIHE, 0.9, mitte)   # Helfer Runde 2: Laterne verdeckte das Bein der Elfe
	for st in [[Kamera.FERN, "grund"], [Kamera.FERN * 1.6, "weit"]]:
		zoom(st[0])
		spiel.kamera.springe()
		await get_tree().create_timer(0.6).timeout
		await knips(aus + "/reihe_%s.png" % st[1])
	# nah: je drei nebeneinander
	zoom(Kamera.NAH)
	var gruppen := [["held", "q_held", "q_bauer"], ["q_baeuerin", "q_zwerg", "q_elf"], ["q_halbling", "q_halbork", "held"]]
	for i in gruppen.size():
		stelle(gruppen[i], 1.05, mitte)
		spiel.kamera.springe()
		await get_tree().create_timer(0.6).timeout
		await knips(aus + "/reihe_nah_%d.png" % (i + 1))
	stelle(REIHE, 0.9, mitte)
	zoom(Kamera.FERN)
	nacht(true)
	await get_tree().create_timer(3.0).timeout
	spiel.kamera.springe()
	await knips(aus + "/reihe_nacht.png")
	nacht(false)
	await get_tree().create_timer(3.0).timeout
	await menue(mitte)

# Hauptmenue-Licht (DESIGN-STIL: schwarz, warmer Lichtkegel von oben): ohne Dorf, Hintergrund schwarz, ein Kegel von oben
func menue(mitte: Vector3) -> void:
	spiel.gebiet.visible = false
	var env: Environment = spiel.licht.env
	var bg := env.background_color
	var amb := env.ambient_light_energy
	env.background_color = Color.BLACK
	env.ambient_light_energy = 0.02
	var sonne: Array = spiel.licht.find_children("*", "DirectionalLight3D", true, false)
	for s in sonne: s.visible = false
	var kegel := SpotLight3D.new()
	kegel.light_color = Color(1.0, 0.78, 0.5)
	kegel.light_energy = 14.0      # Helfer 13:45: Kegel kaum zu sehen; dazu ein dunkler Boden, auf dem er liegt
	kegel.spot_range = 12.0
	kegel.spot_angle = 22.0
	kegel.spot_attenuation = 0.5
	var boden := MeshInstance3D.new()
	var pm := PlaneMesh.new(); pm.size = Vector2(14, 14)
	boden.mesh = pm
	var bm := ShaderMaterial.new(); bm.shader = load("res://shader/toon.gdshader")
	var dunkel := Image.create(4, 4, false, Image.FORMAT_RGB8)
	dunkel.fill(Color(0.16, 0.13, 0.10))
	bm.set_shader_parameter("tex", ImageTexture.create_from_image(dunkel))
	boden.material_override = bm
	spiel.add_child(boden)
	boden.position = mitte
	kegel.shadow_enabled = false   # Helfer Runde 2: Eigenschatten im Kegel wie Schmutzflecken, Maske ueber dem Mund
	spiel.add_child(kegel)
	kegel.position = mitte + spiel.kamera.global_basis.z * 3.0 + Vector3(0, 5.0, 0)   # schraeg von vorn oben: Gesichter im Licht
	kegel.look_at(mitte, Vector3.FORWARD)
	for m_k in mats:
		for m in mats[m_k]: (m as ShaderMaterial).set_shader_parameter("fill", 0.0)
	zoom(Kamera.NAH)
	var gruppen := [["held", "q_held", "q_bauer"], ["q_baeuerin", "q_elf", "q_halbork"]]
	for i in gruppen.size():
		stelle(gruppen[i], 1.05, mitte)
		spiel.kamera.springe()
		await get_tree().create_timer(0.6).timeout
		await RenderingServer.frame_post_draw
		var img := spiel.get_viewport().get_texture().get_image()   # Helfer Runde 2: Figuren nur im mittleren Viertel: Ausschnitt
		var fuss: Vector2 = spiel.kamera.unproject_position(mitte)
		img.get_region(Rect2i(0, int(fuss.y) - 900, img.get_width(), 1100)).save_png(aus + "/reihe_menue_%d.png" % (i + 1))
	kegel.queue_free()
	boden.queue_free()
	for s in sonne: s.visible = true
	env.background_color = bg
	env.ambient_light_energy = amb
	spiel.gebiet.visible = true
	nacht(false)

func spiel_bew(k: String, bew: String) -> float:
	var ap := spieler(k)
	var n := bew_name(k, bew)
	if ap == null or n == "": return 0.0
	ap.play(n)
	ap.seek(0.0, true)
	return ap.get_animation(n).length

# je Feld eine Figur, Kamera nah, Bewegung Bild fuer Bild gesetzt (seek), Ausschnitt um die Figur. Gehen und Rennen laufen mit
# ihrer Schrittgeschwindigkeit vorwaerts, Kamera folgt (Helfer 15:37: Fussgleiten 15-40 px auf der Stelle)
func film(felder: Array) -> void:
	var ort: Vector3 = spiel.karte.kachel_pos(FILM_ORT)
	var z := zielpunkt(ort)
	spiel.kamera.ziel = z
	zoom(Kamera.NAH)
	spiel.kamera.springe()
	spiel.held.set_process(false)   # sonst waehlt held.gd selbst Stehen oder Gehen
	var liste := []
	for i in felder.size():
		var k: String = felder[i][0]
		var bew: String = felder[i][1]
		if not nur.is_empty() and i + 1 not in nur: continue
		var ordner := aus + "/film/%02d_%s_%s" % [i + 1, k, bew]
		DirAccess.make_dir_recursive_absolute(ordner)
		var n := bew_name(k, bew)
		if n == "":
			liste.append("%02d %s %s: keine Bewegung" % [i + 1, k, bew])
			continue
		stelle([k], 1.0, ort)
		var w: Node3D = spiel.held if k == "held" else figuren[k]
		bewaffne(k, bew in KAMPF)
		var ap := spieler(k)
		ap.play(n)
		var lang := ap.get_animation(n).length
		var schleife := ap.get_animation(n).loop_mode != Animation.LOOP_NONE
		var v := 0.0
		if bew == "Sitzen": setze_auf_bank(k, ap, lang)
		elif bew in ["Gehen", "Rennen"]: v = schritt_tempo(k, ap, lang)
		# Tod (Helfer 16:36: Death02 stuerzt eine Koerperlaenge nach vorn, aufs Dach vor der Figur): von der Seite, die Figur so
		# zurueckgesetzt, dass Anfang und Ende des Sturzes gleich weit von der Bildmitte liegen
		var mitte_vers := Vector3.ZERO
		if bew == "Tod":
			w.rotation.y -= PI * 0.5
			ap.seek(lang, true)
			var ende := knochen_pos(k, "pelvis") - w.position
			ap.seek(0.0, true)
			mitte_vers = Vector3(ende.x, 0, ende.z) * 0.5
			if k == "held": spiel.held.weg.clear()
			w.position -= mitte_vers
		var start := w.position
		var vor := Vector3(sin(w.rotation.y), 0, cos(w.rotation.y))
		# Schleifen ganze Umlaeufe, mindestens 1,5 s (Helfer Film: Ruck an der Naht, Gehen 1,33 s lief 1,5 s)
		var dauer := lang * ceilf(1.5 / lang) if schleife else lang + 0.5
		var bilder := int(ceil(dauer * FPS))
		z.position = Vector3(start.x, 0, start.z) + mitte_vers
		spiel.kamera.springe()
		await get_tree().create_timer(0.3).timeout
		for f in bilder:
			var t := float(f) / FPS
			ap.seek(fmod(t, lang) if schleife else minf(t, lang), true)
			ap.pause()
			if v > 0.0:
				if k == "held": spiel.held.weg.clear()
				w.position = start + vor * v * t
				z.position = Vector3(w.position.x, 0, w.position.z)
				spiel.kamera.springe()
			await RenderingServer.frame_post_draw
			await RenderingServer.frame_post_draw
			var img := spiel.get_viewport().get_texture().get_image()
			var fuss: Vector2 = spiel.kamera.unproject_position(Vector3(w.position.x, 0, w.position.z) + mitte_vers)
			var r := Rect2i(int(fuss.x) - FELD_PX.x / 2, int(fuss.y) - FELD_PX.y + FUSS_UNTEN, FELD_PX.x, FELD_PX.y)
			img.get_region(r).save_png(ordner + "/%03d.png" % f)
		bewaffne(k, false)
		w.position = start + mitte_vers
		liste.append("%02d %s %s: %s, %.2f s, %d Bilder%s" % [i + 1, k, bew, n, lang, bilder, (", %.2f m/s" % v) if v > 0.0 else ""])
	protokoll.append_array(liste)
	var f2 := FileAccess.open(aus + "/film/felder.txt", FileAccess.WRITE)
	f2.store_string("\n".join(liste) + "\n")

func knochen_pos(k: String, nm: String) -> Vector3:
	var w: Node3D = spiel.held if k == "held" else figuren[k]
	var sk := Gebiet.finde(w, "Skeleton3D") as Skeleton3D
	var bi := sk.find_bone(nm)
	if bi < 0: return Vector3.ZERO
	return sk.global_transform * sk.get_bone_global_pose(bi).origin

# Geschwindigkeit aus dem Standfuss: auf der Stelle gleitet der Fuss, der gerade am Boden steht, mit dem Tempo zurueck, mit dem der
# Koerper vorankaeme. Helfer 16:36: Spannweite je Umlauf ergab nur die Haelfte (der Fuss steht nur gut die Haelfte des Umlaufs).
# Gemessen: je Fuss die Rueckwaertsgeschwindigkeit in den Bildern, in denen er hoechstens 2 cm ueber seinem Tiefstand ist; Median.
func schritt_tempo(k: String, ap: AnimationPlayer, lang: float) -> float:
	var w: Node3D = spiel.held if k == "held" else figuren[k]
	var vor := Vector3(sin(w.rotation.y), 0, cos(w.rotation.y))
	var n := 120
	var vs: Array[float] = []
	for fu in ["foot_l", "foot_r"]:
		var d: Array[float] = []; var h: Array[float] = []
		for j in n + 1:
			ap.seek(lang * j / n, true)
			var p := knochen_pos(k, fu) - w.position
			d.append(p.dot(vor)); h.append(p.y)
		var tief: float = h.min()
		for j in n:
			if h[j] < tief + 0.02 and h[j + 1] < tief + 0.02: vs.append((d[j] - d[j + 1]) * n / lang)
	ap.seek(0.0, true)
	if vs.is_empty(): return 0.0
	vs.sort()
	return maxf(vs[vs.size() / 2], 0.0)

# auf die Bank: Blick zur Mitte der Platzkacheln wie dorf.py, Becken ueber der Sitzmitte, Sitzbein auf 47 cm
func setze_auf_bank(k: String, ap: AnimationPlayer, lang: float) -> void:
	var kt: Karte = spiel.karte
	var sx := 0.0; var sy := 0.0; var nn := 0
	for y in kt.hoehe:
		for x in kt.breite:
			if kt.zeichen(Vector2i(x, y)) == "o": sx += x; sy += y; nn += 1
	var w: Node3D = figuren[k]
	w.rotation.y = atan2(sx / nn - BANK.x, sy / nn - BANK.y)
	w.position = kt.kachel_pos(BANK)
	ap.seek(lang * 0.5, true)
	var b := knochen_pos(k, "pelvis")
	var ziel := kt.kachel_pos(BANK) + Vector3(sin(w.rotation.y), 0, cos(w.rotation.y)) * 0.03
	w.position += Vector3(ziel.x - b.x, SITZ_HOEHE + 0.10 - b.y, ziel.z - b.z)
	ap.seek(0.0, true)
	protokoll.append("BANK %s Becken %.2f m, Figur %.2f m hoch gesetzt" % [k, b.y, w.position.y])

# Kauffigur in unserer Kleidung neben dem Helden und der Kauffigur in Kaufkleidung: nah von vorn und hinten, Nacht; Koepfe als Ausschnitt
func tracht() -> void:
	var mitte := platz()
	var z := zielpunkt(mitte)
	spiel.kamera.ziel = z
	var ks := TRACHT.filter(func(k): return k == "held" or k in figuren)
	for k in ks: spiel_bew(k, "Stehen")
	zoom(Kamera.NAH)
	for seite in ["vorn", "hinten"]:
		stelle(ks, 1.05, mitte)
		if seite == "hinten":
			for k in ks: (spiel.held if k == "held" else figuren[k]).rotation.y += PI
		spiel.kamera.springe()
		await get_tree().create_timer(0.6).timeout
		await knips(aus + "/tracht_%s.png" % seite)
	stelle(ks, 1.05, mitte)
	nacht(true)
	await get_tree().create_timer(3.0).timeout
	spiel.kamera.springe()
	await knips(aus + "/tracht_nacht.png")
	nacht(false)
	await get_tree().create_timer(3.0).timeout
	var kk := KOEPFE.filter(func(k): return k in figuren)
	for k in kk: spiel_bew(k, "Stehen")
	stelle(kk, 0.75, mitte)
	spiel.kamera.springe()
	await get_tree().create_timer(0.6).timeout
	await RenderingServer.frame_post_draw
	var img := spiel.get_viewport().get_texture().get_image()
	var kopf: Vector2 = spiel.kamera.unproject_position(mitte + Vector3(0, 1.65, 0))
	img.get_region(Rect2i(0, int(kopf.y) - 220, img.get_width(), 440)).save_png(aus + "/tracht_koepfe.png")
	protokoll.append("BILD tracht_koepfe")
