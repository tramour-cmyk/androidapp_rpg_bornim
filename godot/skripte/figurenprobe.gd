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
	# 385 Protofactor-Zauberer (zauber385.py): Stehen, schneller Stoss nach vorn, beide Haende hoch, mittlerer Zauber
	"Zauberstehen": ["Zauber_IdleWizard"], "Zauber kurz": ["Zauber_CastSpell6Wizard"], "Zauber groß": ["Zauber_CastSpell4Wizard"],
	"Zauber mittel": ["Zauber_CastSpell13Wizard"],
}
const KAMPF := ["Hieb", "Stich", "Ausweichen", "Treffer", "Tod", "Kampfstehen"]
# Raster: [Figur, Bewegung]; "held" = unser Held (Runde 7), sonst Kennung aus quaternius.py
const FELDER := [
	["q_held", "Stehen"], ["q_held", "Gehen"], ["q_held", "Rennen"], ["q_bauer", "Sitzen"], ["q_bauer", "Gesten"],
	["q_held", "Hieb"], ["held", "Hieb"], ["held", "Stich"], ["q_held", "Ausweichen"], ["held", "Ausweichen"],
	["q_held", "Treffer"], ["held", "Treffer"], ["q_held", "Tod"], ["held", "Tod"], ["q_held", "Kampfstehen"],
]
# 385: Film der Zauberbewegungen am Kaufkoerper (Chef 27.10., 21:04; „jetzt“ 28.10., 10:00)
const FELDER_ZAUBER := [["q_held", "Zauberstehen"], ["q_held", "Zauber kurz"], ["q_held", "Zauber mittel"], ["q_held", "Zauber groß"]]
const REIHE := ["held", "q_held", "q_bauer", "q_baeuerin", "q_zwerg", "q_elf", "q_halbling", "q_halbork"]
# Chef 15:23: eine Kauffigur in unserer Kleidung (kauf_kleid.py); 14:44 Koepfe: schmal/rund, ohne/mit Bart
const TRACHT := ["held", "q_tracht", "q_held"]
const KOEPFE := ["q_tracht", "q_tracht_b", "q_tracht_r", "q_tracht_rb"]
const FELDER_TRACHT := [
	["q_tracht", "Stehen"], ["q_tracht", "Gehen"], ["q_tracht", "Rennen"], ["q_tracht", "Gesten"],
	["q_tracht", "Hieb"], ["q_tracht", "Ausweichen"], ["q_tracht", "Treffer"], ["q_tracht", "Tod"],
]

# Helfer 20:2x (Kopf stark gesenkt, Augen halb zu; fremd im Stehen 13-22 Grad, geruest.py hebt unseren Helden auf -3 Grad): den Kopf
# nach der Bewegung hoechstens bis ZIEL heben, solange der Rumpf aufrecht ist (Tod, Ausweichen nicht); Heben nach oben bleibt
class KopfHeben extends SkeletonModifier3D:
	const ZIEL := 0.0         # Pruefer 20:33: bei -3 im Bild noch gesenkt (Kamera von oben)
	const HOECHSTENS := 25.0
	var vorher := 999.0
	var gehoben := 0.0
	var verteilt := false     # 376.1 Halszacken: Heben zu gleichen Teilen auf neck_01, neck_02, Head (Kragen haengt an neck_02)
	func _process_modification() -> void:
		var sk := get_skeleton()
		var h := sk.find_bone("Head")
		var b := sk.find_bone("spine_03")
		if h < 0 or b < 0: return
		var hg := sk.get_bone_global_pose(h)
		var f := hg.basis * (sk.get_bone_global_rest(h).basis.inverse() * Vector3.BACK)
		var auf := sk.get_bone_global_pose(b).basis * (sk.get_bone_global_rest(b).basis.inverse() * Vector3.UP)
		var wieviel := smoothstep(0.5, 0.85, auf.normalized().y)
		var neig := rad_to_deg(asin(clampf(f.normalized().y, -1.0, 1.0)))
		var w := clampf(ZIEL - neig, 0.0, HOECHSTENS) * wieviel
		vorher = neig; gehoben = w
		var achse := f.cross(Vector3.UP)
		if w < 0.1 or achse.length() < 1e-4: return
		if verteilt:
			var kette := ["neck_01", "neck_02", "Head"].map(func(n): return sk.find_bone(n)).filter(func(i): return i >= 0)
			for i in kette:   # je Knochen ein Teil um dieselbe Weltachse; die Kinder erben, der Kopf dreht zusammen um w
				var g := sk.get_bone_global_pose(i)
				var n := Basis(achse.normalized(), deg_to_rad(w / kette.size())) * g.basis.orthonormalized()
				var p := sk.get_bone_global_pose(sk.get_bone_parent(i))
				sk.set_bone_pose_rotation(i, (p.basis.orthonormalized().inverse() * n).get_rotation_quaternion())
			return
		var neu := Basis(achse.normalized(), deg_to_rad(w)) * hg.basis.orthonormalized()
		var pg := sk.get_bone_global_pose(sk.get_bone_parent(h))
		sk.set_bone_pose_rotation(h, (pg.basis.orthonormalized().inverse() * neu).get_rotation_quaternion())

var spiel: Node3D
var aus := ""
var quelle := ""
var ual_pfad := ""
var ual2: PackedStringArray = []         # 385: weitere Bewegungen auf demselben Geruest (zauber385.py), neben die UAL
var teil := ""
var nur: Array[int] = []                   # --nur=6,13: nur diese Felder des Films (Probe einzelner Felder)
var ual_lib: AnimationLibrary
var ual_becken := 1.0                      # Laenge der Ruhelage des Beckens in der UAL (Hoehe)
var figuren := {}                          # kennung -> Node3D
var mats := {}                             # kennung -> Array der Materialien
var protokoll: Array = []
var heber := {}                           # kennung -> KopfHeben

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
		elif a.begins_with("--ual2="): ual2 = a.substr(7).split(",")
		elif a.begins_with("--teil="): teil = a.substr(7)
		elif a.begins_with("--nur="):
			for x in a.substr(6).split(","): nur.append(int(x))

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(aus)
	spiel.ui.visible = false
	if spiel.leute: spiel.leute.visible = false
	lade_ual()
	var ks: Array = REIHE + TRACHT + KOEPFE
	if teil == "koepfe":   # Kopfblatt: alle q_k*.glb der Quelle (koepfe_lauf.sh)
		ks = Array(DirAccess.get_files_at(quelle)).filter(func(f): return f.begins_with("q_k") and f.ends_with(".glb")).map(func(f): return f.get_basename())
		ks.sort()
	for k in ks:
		if k != "held" and k not in figuren: lade_figur(k)
	await get_tree().create_timer(1.0).timeout
	if teil in ["", "reihe"]: await reihe()
	if teil in ["", "film"]: await film(FELDER)
	if teil == "tracht": await tracht()
	if teil == "trachtfilm": await film(FELDER_TRACHT)
	if teil == "koepfe": await koepfe()
	if teil == "zauber":
		freie_wiese()
		film_zoom = 4.2     # 385 Lauf 2: Stab bis 2,8 m ueber dem Boden (Zauber gross, Faeuste oben); 257 statt 318 px je m
		fuss_unten = 200
		await film(FELDER_ZAUBER)
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
	for p in ual2:
		var sc2 := Gebiet.lade_glb(p)
		var ap2 := Gebiet.finde(sc2, "AnimationPlayer") as AnimationPlayer
		for n in ap2.get_animation_list():
			if not ual_lib.has_animation(n): ual_lib.add_animation(n, ap2.get_animation(n).duplicate(true))
		protokoll.append("UAL2 %s: %s" % [p.get_file(), ", ".join(ap2.get_animation_list())])
		sc2.free()

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
	var kh := KopfHeben.new()
	if "--ohneheben" not in OS.get_cmdline_user_args(): sk.add_child(kh)
	heber[k] = kh
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
	for n in ["Idle_Loop", "Walk_Loop", "Jog_Fwd_Loop", "Sitting_Idle_Loop", "Idle_Talking_Loop", "Sword_Idle", "Zauber_IdleWizard"]:
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

# 385 Lauf 2 (Pruefer Lauf 1: Arm im Kaminrauch wie ein leerer Umriss, Haende greifen nichts): der Zauberer haelt in der linken Faust
# seinen Stab (Protofactor SM_WizardStaffProp, Ursprung am Griff, 1,97 m, Kopf oben; daten/waffen/stab.bin). Lage einmal aus dem
# ersten Bild von Zauber_IdleWizard: senkrecht, durch die Mitte zwischen Zeigefinger- und Kleinfingerknoechel (wie das Schwert);
# fest an der Hand, danach folgt er ihr in jeder Bewegung
var stab_t = null
var film_zoom := Kamera.NAH
var fuss_unten := FUSS_UNTEN
func stab(k: String, an: bool) -> void:
	var w: Node3D = spiel.held if k == "held" else figuren[k]
	var sk := Gebiet.finde(w, "Skeleton3D") as Skeleton3D
	for alt in sk.find_children("Stab*", "", true, false): alt.free()
	if not an or sk.find_bone("index_01_l") < 0: return
	if stab_t == null:
		var ap := spieler(k)
		ap.play(ual_name("Zauberstehen"))
		ap.seek(0.0, true)
		var hw := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("hand_l"))
		var g := sk.global_transform * ((sk.get_bone_global_pose(sk.find_bone("index_01_l")).origin + sk.get_bone_global_pose(sk.find_bone("pinky_01_l")).origin) * 0.5)
		var ziel := Transform3D(w.global_basis.orthonormalized(), g)   # Stab +Y senkrecht, Kopf zur Blickrichtung der Figur gedreht
		stab_t = hw.affine_inverse() * ziel
		protokoll.append("STAB griff %s, unten %.2f m" % [g, g.y - w.global_position.y - 1.233])
	haenge(sk, "hand_l", "stab", stab_t, "Stab")

# 385 Lauf 2: ohne Dorf (Kamin und Rauch verdeckten in Lauf 1 die Arme), Wiese als ebene Flaeche im Tageslicht
func freie_wiese() -> void:
	spiel.gebiet.visible = false
	var boden := MeshInstance3D.new()
	var st := SurfaceTool.new()   # 30 m, Gras je 2 m wiederholt (PlaneMesh dehnte das Bild ueber die ganze Flaeche)
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.UP)
	for e in [[-1, -1], [1, -1], [1, 1], [-1, -1], [1, 1], [-1, 1]]:
		st.set_uv(Vector2(e[0], e[1]) * 7.5)
		st.add_vertex(Vector3(e[0] * 15.0, 0.0, e[1] * 15.0))
	boden.mesh = st.commit()
	var bm := ShaderMaterial.new(); bm.shader = load("res://shader/toon.gdshader")
	bm.set_shader_parameter("tex", Gebiet.bild("gras"))
	boden.material_override = bm
	spiel.add_child(boden)
	boden.position = spiel.karte.kachel_pos(FILM_ORT)

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
	zoom(film_zoom)
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
		stab(k, bew.begins_with("Zauber"))
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
			var r := Rect2i(int(fuss.x) - FELD_PX.x / 2, int(fuss.y) - FELD_PX.y + fuss_unten, FELD_PX.x, FELD_PX.y)
			img.get_region(r).save_png(ordner + "/%03d.png" % f)
		bewaffne(k, false)
		stab(k, false)
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

# 376.1 (Chef 19:40: gekauften Kopf anpassen, Form, Bart, Farbe, Haar): je Kopf q_k* ein Bild halb von vorn auf Gesichtshoehe wie in
# der Charaktererstellung (kopf_<k>.png), dazu die Koepfe aus SPIELREIHE nebeneinander in der Spielansicht nah (koepfe_spiel.png)
const SPIELREIHE := ["q_k11", "q_k12", "q_k13", "q_k14", "q_k15"]
func koepfe() -> void:
	var ks: Array = figuren.keys().filter(func(k): return String(k).begins_with("q_k"))
	ks.sort()
	var mitte := platz()
	var z := zielpunkt(mitte)
	var kam: Kamera = spiel.kamera
	kam.ziel = z
	for k in ks: spiel_bew(k, "Stehen")
	kam.nah = false
	kam.zoom = 0.62
	kam.neigung = -8.0
	for k in ks:
		stelle([k], 0.0, mitte)
		figuren[k].rotation.y -= deg_to_rad(20.0)   # Pruefer 21:09: halb seitlich wirkte der Kiefer einseitig (Beule); von vorn
		await get_tree().create_timer(0.5).timeout
		var kopf := knochen_pos(k, "Head") + Vector3(0, 0.08, 0)
		z.position = kopf
		kam.springe()
		await RenderingServer.frame_post_draw
		var img := spiel.get_viewport().get_texture().get_image()
		var sp: Vector2 = kam.unproject_position(kopf)
		img.get_region(Rect2i(int(sp.x) - 400, int(sp.y) - 470, 800, 940)).save_png(aus + "/kopf_%s.png" % k)
		# 376.1 Halszacken: dasselbe Bild mit Rueckseiten magenta (messen) und mit Rueckseiten im Schatten (Abhilfe), Hals als Ausschnitt
		for rs in [1, 2]:
			for x in mats[k]: (x as ShaderMaterial).set_shader_parameter("rueckseite", float(rs))
			await RenderingServer.frame_post_draw
			await RenderingServer.frame_post_draw
			img = spiel.get_viewport().get_texture().get_image()
			img.get_region(Rect2i(int(sp.x) - 400, int(sp.y) - 470, 800, 940)).save_png(aus + "/kopf_%s_r%d.png" % [k, rs])
		for x in mats[k]: (x as ShaderMaterial).set_shader_parameter("rueckseite", 0.0)
		var hals := kam.unproject_position(knochen_pos(k, "neck_01"))
		protokoll.append("HALS kopf_%s %d %d" % [k, int(hals.x - sp.x + 400), int(hals.y - sp.y + 470)])
		await zacken(k, sp, hals)
		protokoll.append("BILD kopf_%s Kopf %s Neigung Bewegung %.1f Grad, gehoben %.1f" % [k, kopf, heber[k].vorher, heber[k].gehoben])
	kam.neigung = -30.0
	var sr := SPIELREIHE.filter(func(k): return k in figuren)
	stelle(sr, 0.6, mitte)   # Pruefer 20:33: Randfiguren bei 0,75 abgeschnitten
	z.position = mitte
	zoom(Kamera.NAH)
	kam.springe()
	await get_tree().create_timer(0.6).timeout
	await RenderingServer.frame_post_draw
	var img := spiel.get_viewport().get_texture().get_image()
	var kp: Vector2 = kam.unproject_position(mitte + Vector3(0, 1.6, 0))
	img.get_region(Rect2i(0, int(kp.y) - 260, img.get_width(), 520)).save_png(aus + "/koepfe_spiel.png")
	protokoll.append("BILD koepfe_spiel")

# 376.1 Halszacken in Godot nachstellen (Helfer 28.10.: graue Zacken vorn am Hals bei k01/03/06-10/13/15, nicht bei schmal, kantig,
# hager; Rueckseiten keine, Lage in Blender gleich): dieselbe Ansicht in Teilfarben (Kette rot), Tusche aus, je Spalte am Hals die
# roten Laeufe (mehr als einer = Zacke oder Insel) und Spitzen der Kragenkante ueber ihrem gleitenden Median (Bildpunkte), ohne Bild.
# Fassungen: Kopfheben wie bisher (nur Head), aus, verteilt (neck_01, neck_02, Head), Schatten aus, Kette 3 mm hinaus.
const ZACKEN_FASSUNGEN := [["heben", 1, true, 0.0], ["ohne", 0, true, 0.0], ["verteilt", 2, true, 0.0], ["schattenlos", 1, false, 0.0], ["kette3", 1, true, 0.003]]
func zacken(k: String, sp: Vector2, hals: Vector2) -> void:
	var kam: Kamera = spiel.kamera
	var sonne: Array = spiel.licht.find_children("*", "DirectionalLight3D", true, false)
	var knick: Array = kam.tusche_mats.map(func(m): return m.get_shader_parameter("knick"))
	var zeile := "ZACKEN kopf_%s" % k
	for fa in ZACKEN_FASSUNGEN:
		heber[k].active = fa[1] > 0
		heber[k].verteilt = fa[1] == 2
		for s in sonne: (s as DirectionalLight3D).shadow_enabled = fa[2]
		for x in mats[k]: (x as ShaderMaterial).set_shader_parameter("kette_aus", fa[3])
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		if fa[0] in ["ohne", "verteilt"]:   # dieselbe Ansicht in Farbe, falls die Fassung die Abhilfe ist
			var bild := spiel.get_viewport().get_texture().get_image()
			bild.get_region(Rect2i(int(sp.x) - 400, int(sp.y) - 470, 800, 940)).save_png(aus + "/kopf_%s_%s.png" % [k, fa[0]])
		for m in kam.tusche_mats: m.set_shader_parameter("knick", 1000.0)
		for x in mats[k]: (x as ShaderMaterial).set_shader_parameter("teil", 1.0)
		var summe := [0, 0, 0]
		for probe in 2:
			await get_tree().create_timer(0.15).timeout
			await RenderingServer.frame_post_draw
			var z := zackenzahl(spiel.get_viewport().get_texture().get_image(), hals)
			for i in 3: summe[i] += z[i]
		for x in mats[k]: (x as ShaderMaterial).set_shader_parameter("teil", 0.0)
		for i in kam.tusche_mats.size(): kam.tusche_mats[i].set_shader_parameter("knick", knick[i])
		zeile += " | %s: Laeufe %d, Spitzen %d, Kette %d" % [fa[0], summe[0], summe[1], summe[2]]
	heber[k].active = true
	heber[k].verteilt = false
	for s in sonne: (s as DirectionalLight3D).shadow_enabled = true
	for x in mats[k]: (x as ShaderMaterial).set_shader_parameter("kette_aus", 0.0)
	protokoll.append(zeile)

func zackenzahl(img: Image, hals: Vector2) -> Array:
	var x0 := clampi(int(hals.x) - 260, 0, img.get_width() - 1)
	var x1 := clampi(int(hals.x) + 260, 0, img.get_width())
	var y0 := clampi(int(hals.y) - 380, 0, img.get_height() - 1)
	var y1 := clampi(int(hals.y) + 60, 0, img.get_height())
	var mehr := 0
	var rot := 0
	var oben: Array[int] = []
	for x in range(x0, x1):
		var drin := false
		var laeufe := 0
		var top := -1
		for y in range(y0, y1):
			var c := img.get_pixel(x, y)
			var r := c.r > 0.35 and c.r > 2.0 * c.g and c.r > 2.0 * c.b
			if r:
				rot += 1
				if top < 0: top = y
				if not drin: laeufe += 1
			drin = r
		if laeufe > 1: mehr += laeufe - 1
		oben.append(top)
	var spitzen := 0
	for i in oben.size():
		if oben[i] < 0: continue
		var nb: Array[int] = []
		for j in range(maxi(0, i - 15), mini(oben.size(), i + 16)):
			if oben[j] >= 0: nb.append(oben[j])
		nb.sort()
		var d := nb[nb.size() / 2] - oben[i]
		if d > 2: spitzen += d
	return [mehr, spitzen, rot]
