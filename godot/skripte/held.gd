class_name Held
extends Node3D
# 348.6: der Held aus tools/blender348/v3 (held.glb in Metern, Skelett, Gehen/Stehen, gebackene Textur) mit Fackel;
# geht einen Weg aus Kachelmitten (Tippen) oder in eine Richtung (Joystick), stoesst nirgends durch (Karte.begehbar).
# Tempo wie im alten Spiel (FreeWalk.WALK/RUN, Terrain.stepFactor); Gehen wird so schnell abgespielt, dass nichts gleitet.

signal steht_auf(kachel: Vector2i)
signal stoesst(kachel: Vector2i)       # will auf eine Kachel, die sperrt (Game.move: Move.Blocked)

const RAND := 0.3                      # Meter: so nah kommt die Koerpermitte an Unbegehbares

var karte: Karte
var modell: Node3D
var anim: AnimationPlayer
var gang := 1.08                       # m/s, mit denen „Gehen“ ohne Gleiten laeuft (held-info.json)
var renn := 0.0                        # m/s, mit denen „Rennen“ ohne Gleiten laeuft (held-info.json; 0: altes Modell ohne Rennen)
var tempo_jetzt := 0.0                 # Chef 25.10., 18:20: „Übergang von Gehen zu Rennen ist zu krass“: das Tempo steigt und faellt weich
const BESCHL := 5.0                    # m/s²: von Gehen (2,1) auf Rennen (4,3) in gut 0,4 s
var weg: Array[Vector3] = []
var richtung := Vector3.ZERO           # Joystick, Laenge 0..1
var laeuft := false
var fackel: OmniLight3D
var flamme: MeshInstance3D
var kachel := Vector2i(-1, -1)
var zeit := 0.0
var ruhe := "Stehen"                  # 397: jetzige Ruhebewegung (Gebiet.ruhe_naechste)
var ruhe_bis := -1.0
var ruhe_zufall := RandomNumberGenerator.new()
var gestossen := Vector2i(-1, -1)
var stoss_zeit := -9.0
var leute: Array = []                  # Leute der Karte (spiel.gd): durch sie geht er nicht

var wahl := {}                         # 376.1 Klasse, Aussehen, Ausruestung (HeldFigur.wahl); leer: der bisherige Held

func _init(k: Karte, w: Dictionary = {}) -> void:
	karte = k
	wahl = w
	name = "Held"

func _ready() -> void:
	# 376.1: je Klasse der Held auf dem Kaufkoerper (heldfigur.gd), sonst der bisherige (held.bin, rig.py)
	modell = HeldFigur.baue(wahl, mats) if not wahl.is_empty() else null
	var kauf := modell != null
	if not kauf:
		modell = Gebiet.lade_glb("res://daten/held.bin")
		Gebiet.male(modell, null, 2, mats)
	add_child(modell)
	for m in mats: (m as ShaderMaterial).set_shader_parameter("metall", 1.0)   # 348.6 Glanz an Kette und Helm (toon.gdshader)
	if "--teilfarbe" in OS.get_cmdline_user_args():   # nur zum Messen: Teile in Falschfarben (toon.gdshader teil, rig.py TEILMASKE)
		for m in mats: (m as ShaderMaterial).set_shader_parameter("teil", 1.0)
	# 348.6 Kette nachts (Helfer: Kette fast weiss, Gesicht darunter schwarz wie eine Maske; gemessen ohne Fackel Kette = Gesicht, mit Fackel
	# Kette 0,29, Gesicht 0,22: das Licht sass 9 cm ueber der Flamme seitlich am Kopf, traf die Brust von oben, das Gesicht streifend):
	# Metall streut Lampenlicht wenig (kette_lampe), nachts weniger Umgebung (kette_umgebung in nacht()); Licht vor der Flamme (richte_fackel)
	for m in mats: (m as ShaderMaterial).set_shader_parameter("kette_lampe", 0.35)
	var info: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/held-info.json")) if not kauf else \
		{"gehen_m_je_s": modell.get_meta("gehen_m_je_s"), "rennen_m_je_s": modell.get_meta("rennen_m_je_s"), "faust_L": modell.get_meta("faust_L")}
	gang = float(info.get("gehen_m_je_s", gang))
	renn = float(info.get("rennen_m_je_s", 0.0))
	# 348.6 CC0-Geruest (348.12): Knochen der Faust und Griff stehen in held-info.json (geruest.py), sonst das alte Skelett
	var fa: Dictionary = info.get("faust_L", {})
	if fa.has("knochen"):
		faust_knochen = String(fa["knochen"])
		faust_griff = fa["griff"] if fa["griff"] is Vector3 else Vector3(fa["griff"][0], fa["griff"][1], fa["griff"][2])
		faust_achse = fa["achse"] if fa["achse"] is Vector3 else Vector3(fa["achse"][0], fa["achse"][1], fa["achse"][2])
	anim = Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
	if anim: Gebiet.bewegungen(anim, ["Gehen", "Stehen", "Rennen", "Gehen_Fackel", "Stehen_Fackel", "Rennen_Fackel", "Stehen_2", "Stehen_3", "Stehen_2_Fackel", "Stehen_3_Fackel"])
	if anim: anim.play("Stehen")
	baue_fackel()

func setze(t: Vector2i, blick := "DOWN") -> void:
	position = karte.kachel_pos(t)
	rotation.y = {"UP": PI, "DOWN": 0.0, "LEFT": -PI / 2, "RIGHT": PI / 2}.get(blick, 0.0)
	weg.clear()
	kachel = t
	steht_auf.emit(t)

# 390 (Rast: Wiederkehrort wie Place.facing): die naechste der vier Richtungen von setze
func blick() -> String:
	var w := wrapf(rotation.y, -PI, PI)
	if absf(w) <= PI / 4: return "DOWN"
	if absf(w) >= 3 * PI / 4: return "UP"
	return "RIGHT" if w > 0 else "LEFT"

func geh_zu(ziel: Vector3) -> bool:
	var b := karte.pos_kachel(ziel)
	var ids := karte.weg(karte.pos_kachel(position), b)
	weg.clear()
	if ids.is_empty(): return false   # 399.1: kein Weg, die Welt ruettelt (WorldScreen route == null)
	for k in range(1, ids.size()): weg.append(karte.kachel_pos(ids[k]))
	if weg.is_empty(): weg.append(karte.kachel_pos(b))
	return true

# 390: stehen bleiben (vor einer angetippten Person)
func halt() -> void: weg.clear()

func sperrer(p: Vector3) -> Leute:
	for l in leute:
		if is_instance_valid(l) and l.sperrt(p): return l
	return null

func frei(p: Vector3) -> bool:
	if not karte.begehbar(karte.pos_kachel(p)): return false
	for l in leute:
		if is_instance_valid(l) and l.sperrt(p): return false
	return true

func _process(dt: float) -> void:
	zeit += dt
	var dir := Vector3.ZERO
	if richtung.length() > 0.15:
		dir = richtung
		weg.clear()
	elif weg.size() > 0:
		var to := weg[0] - position
		to.y = 0
		if to.length() < 0.06:
			position = Vector3(weg[0].x, position.y, weg[0].z)
			weg.pop_front()
		else:
			dir = to.normalized()
	var moving := dir.length() > 0.05
	var vorher := position
	var tempo := 0.0
	if moving:
		var kps := karte.laufen if laeuft else karte.gehen
		tempo = kps * Karte.TS / karte.schritt(karte.pos_kachel(position)) * clampf(dir.length(), 0.5, 1.0)
		# aus dem Stand sofort im Gehtempo, schneller oder langsamer werden weich
		var geh_t := karte.gehen * Karte.TS / karte.schritt(karte.pos_kachel(position))
		tempo_jetzt = minf(tempo, geh_t) if tempo_jetzt <= 0.0 else move_toward(tempo_jetzt, tempo, BESCHL * dt)
		tempo = tempo_jetzt
		# in kleinen Stuecken, damit ein langes Bild (dt gross) nicht ueber Kanten springt oder zu frueh anstoesst
		var d := dir.normalized()
		var rest := tempo * dt
		if weg.size() > 0 and richtung.length() <= 0.15: rest = minf(rest, Vector2(weg[0].x - position.x, weg[0].z - position.z).length())
		while rest > 1e-4:
			var step := d * minf(rest, 0.08)
			rest -= step.length()
			var np := position + step
			var vorn_frei := frei(np) and frei(np + d * RAND)
			# Test 139.7: steht jemand vorn im Weg, ist er gemeint, auch wenn der Held schraeg an ihm entlang gleitet (die Kamera blickt
			# schraeg, der Joystick zeigt selten genau entlang der Kacheln); spiel.gd _schiebt entscheidet, ob er zur Seite tritt
			var gegen := false   # ungefaehr auf die Person zu (bis 60 Grad): er bleibt vor ihr stehen, statt um sie herumzugleiten
			if not vorn_frei:
				var wer := sperrer(np + d * RAND)
				if wer == null: wer = sperrer(np)
				if wer:
					var zu := Vector3(wer.position.x - position.x, 0, wer.position.z - position.z)
					gegen = zu.length() < 0.05 or d.dot(zu.normalized()) > 0.5
					if wer.kachel != gestossen or zeit - stoss_zeit > 2.0:
						gestossen = wer.kachel; stoss_zeit = zeit
						stoesst.emit(wer.kachel)
			if vorn_frei:
				position = np
			elif gegen:
				weg.clear()
				break
			elif absf(step.x) > 1e-5 and frei(position + Vector3(step.x + signf(step.x) * RAND, 0, 0)):
				position.x += step.x
			elif absf(step.z) > 1e-5 and frei(position + Vector3(0, 0, step.z + signf(step.z) * RAND)):
				position.z += step.z
			else:
				weg.clear()
				var vor := karte.pos_kachel(position + d * (RAND + 0.05))
				var wer := sperrer(np + d * RAND)   # vor einer breiten Person (Rind) stand der Held noch auf der eigenen Kachel
				if wer: vor = wer.kachel
				if vor != gestossen or zeit - stoss_zeit > 2.0:
					gestossen = vor; stoss_zeit = zeit
					stoesst.emit(vor)
				break
		rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z), minf(1.0, dt * 12.0))
	if anim:
		# Runde 4 (5): gegen Schlagbaum oder Wand (Text offen) stand der Held in Gehhaltung: nur gehen, wenn er vorankommt
		if moving and (position - vorher).length() < tempo * dt * 0.2: moving = false
		if not moving: tempo_jetzt = 0.0
		var geh_t := karte.gehen * Karte.TS / karte.schritt(karte.pos_kachel(position))
		var rennt := moving and renn > 0.0 and tempo > geh_t * 1.45
		if moving: ruhe = "Stehen"; ruhe_bis = -1.0
		elif ruhe_bis < 0.0: ruhe_bis = zeit + anim.get_animation("Stehen").length * ruhe_zufall.randi_range(2, 4)
		elif zeit >= ruhe_bis:
			var r := Gebiet.ruhe_naechste(anim, ruhe, ruhe_zufall)
			ruhe = r[0]; ruhe_bis = zeit + float(r[1])
		var want := ("Rennen" if rennt else "Gehen") if moving else ruhe
		if fackel and traegt_fackel:
			if anim.has_animation(want + "_Fackel"): want += "_Fackel"
			elif not moving: want = "Stehen_Fackel" if anim.has_animation("Stehen_Fackel") else "Stehen"   # Fackel bleibt in der Hand
		var cur := anim.current_animation
		if cur != want:
			# Gehen <-> Rennen im selben Schritt (beide beginnen mit dem rechten Fuss vorn) und laenger ueberblendet
			var phase := anim.current_animation_position / maxf(0.001, anim.current_animation_length) if cur != "" else 0.0
			var schritt := cur.begins_with("Gehen") or cur.begins_with("Rennen")
			# Runde 5 (Helfer Runde 3: „Haltung springt beim Anlaufen in 0,1 s“): Gehen <-> Rennen 0,6 s (Rumpf neigt sich weich; 0,45: in 1/15 s 9 Grad), aus dem Stehen 0,25 s
			anim.play(want, 0.6 if schritt and moving else (0.5 if cur.begins_with("Stehen") else 0.25))   # 397: Ruhe in Ruhe weich
			if schritt and moving: anim.seek(phase * anim.get_animation(want).length)
		anim.speed_scale = (tempo / (renn if rennt else gang)) if moving else 1.0
	var k := karte.pos_kachel(position)
	if k != kachel:
		kachel = k
		steht_auf.emit(k)
	if fackel: fackel.light_energy = fackel_kraft * (0.88 + 0.12 * sin(zeit * 17.0) * sin(zeit * 7.3))
	if flamme:
		var innen := flamme.get_child(1) as Node3D
		innen.scale = Vector3.ONE * (0.85 + 0.2 * sin(zeit * 17.0 + 1.3))
	if fackel and traegt_fackel: richte_fackel()   # Runde 5b: erst nach dem Schritt (vorher blieb die Fackel ein Bild zurueck)

func geht() -> bool:
	return weg.size() > 0 or richtung.length() > 0.15

# ---------------------------------------------------------------- Fackel (nachts), in der linken Hand
var fackel_kraft := 0.0
var traegt_fackel := false   # 399.1 Light.torch: nur mit einer Fackel in der Nebenhand (vorher nachts immer)
var im_raum := false         # Light.burns (344.1, Chef 23.10.): in Haeusern, Schenke, Laden, Tempel ohne Flamme gehalten
var nacht_k := 0.0

# 344.1: die Fackel brennt ueberall ausser in einem Raum, Tag und Nacht; ihr Licht zaehlt nur im Dunkeln (Staerke nach der Nacht)
func fackel_neu(traegt: bool, raum: bool) -> void:
	traegt_fackel = traegt; im_raum = raum
	nacht(nacht_k)

var mats: Array = []   # Held im Schatten nicht nur Umriss (Probe Build 11), nachts nicht (sonst leuchtet er)

func nacht(k: float) -> void:
	nacht_k = k
	fackel_kraft = 2.2 * k
	for m in mats:
		(m as ShaderMaterial).set_shader_parameter("fill", 0.42 * (1.0 - k))
		(m as ShaderMaterial).set_shader_parameter("kette_umgebung", lerpf(1.0, 0.7, k))
	if fackel:
		(fackel.get_parent() as Node3D).visible = traegt_fackel
		flamme.visible = traegt_fackel and not im_raum
		fackel.visible = traegt_fackel and not im_raum and k > 0.02

func baue_fackel() -> void:
	var sk := Gebiet.finde(modell, "Skeleton3D") as Skeleton3D
	if sk == null: return
	var ba := BoneAttachment3D.new()
	ba.bone_name = faust_knochen
	sk.add_child(ba)
	var t := Node3D.new()
	t.name = "Fackel"
	ba.add_child(t)
	var stiel := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.022; cm.bottom_radius = 0.016; cm.height = 0.42
	stiel.mesh = cm
	var wm := StandardMaterial3D.new()
	wm.albedo_color = Color(0.42, 0.28, 0.16)
	stiel.material_override = wm
	stiel.position = Vector3(0, 0.06, 0)
	stiel.layers = 2                                   # die eigene Flamme beleuchtet den Stiel nicht (sonst gluehte er, Licht vor der Flamme)
	t.add_child(stiel)
	# Runde 5b (Helfer: schwarzer Stummel im Flammenfuss, die Flamme deckt nicht): Pechkopf glimmt am Stielende
	var glut := MeshInstance3D.new()
	var gm := SphereMesh.new()
	gm.radius = 0.03; gm.height = 0.05
	glut.mesh = gm
	var glm := StandardMaterial3D.new()
	glm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glm.albedo_color = Color(0.85, 0.32, 0.08)
	glut.material_override = glm
	glut.position = Vector3(0, 0.27, 0)
	glut.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	t.add_child(glut)
	# Helfer: Flamme „wie Papier“ (ein blassgelber Kegel, flackert kaum): aussen orange, innen hell, beide flackern verschieden
	# Runde 5 (Helfer Runde 3: noch mattes Dreieck mit schwarzer Kontur): additiv leuchtend ohne Tusche (flamme.gdshader), mit Schein
	flamme = MeshInstance3D.new()
	flamme.position = Vector3(0, 0.36, 0)
	t.add_child(flamme)
	var fl: Shader = load("res://shader/flamme.gdshader")
	# Runde 5b (Helfer: glattes Dreieck „wie ein Papierwimpel“): Kern, Mantel und drei Zungen mit eigenem Takt; ueber dem Gras
	# (Gras ist durchsichtig und wurde davor gezeichnet), unter der Tusche
	var form := [[0.055, 0.24, 0.0, 0.0], [0.03, 0.14, 0.0, -0.04], [0.022, 0.15, 0.022, 0.05], [0.02, 0.13, -0.024, 0.04], [0.016, 0.11, 0.0, 0.07]]
	for k in 6:
		var kegel := MeshInstance3D.new()
		var m := ShaderMaterial.new()
		m.shader = fl
		m.render_priority = 100
		if k < 5:
			# Runde 5c (Helfer: „Eistuete“, harte Unterkante, breiteste Stelle unten): Tropfen aus einer Kugel, unten rund, oben spitz
			var fm := SphereMesh.new()
			fm.radius = form[k][0]; fm.height = form[k][1]
			fm.radial_segments = 14; fm.rings = 10
			kegel.mesh = fm
			m.set_shader_parameter("hoehe", fm.height)
			m.set_shader_parameter("saat", 2.3 * k)
			if k == 1: m.set_shader_parameter("aussen", Color(1.0, 0.7, 0.25))
			m.set_shader_parameter("kraft", 0.75 if k < 2 else 0.6)   # Runde 5b (Helfer: fast weiss, ueberbelichtet)
			kegel.position = Vector3(form[k][2], form[k][3], 0.01 * (k - 3) if k >= 2 else 0.0)
		else:
			var qm := QuadMesh.new()
			qm.size = Vector2(0.7, 0.7)
			kegel.mesh = qm
			m.set_shader_parameter("glanz", 1.0)
			kegel.position = Vector3(0, -0.02, 0)
		kegel.material_override = m
		kegel.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		flamme.add_child(kegel)
	fackel = OmniLight3D.new()
	fackel.position = Vector3(0, 0.45, 0)
	fackel.light_color = Color(1.0, 0.72, 0.38)
	fackel.omni_range = 8.0
	fackel.omni_attenuation = 2.0
	fackel.light_cull_mask = 0xFFFFF & ~2
	t.add_child(fackel)
	fackel.set_meta("reich", 4.0)   # 348.13b: Tusche nach der Fackel (am Tag unsichtbar, zaehlt dann nicht)
	fackel.set_meta("kraft", 1.0)
	fackel.add_to_group("tuschelicht")
	nacht(0.0)

func richte_fackel() -> void:
	# Fackel in der linken Faust (Bewegungen _Fackel: Arm vor der Schulter), halb aufgerichtet, folgt der Faust
	var t := find_child("Fackel", true, false) as Node3D
	if t == null: return
	var ba := t.get_parent() as BoneAttachment3D
	var sk := ba.get_parent() as Skeleton3D
	# Runde 5b (Helfer: Stiel hinter dem Unterarm, starr senkrecht, „aufgespiesst“): der Knochen foL-wrL endet am Handgelenk,
	# 7 cm ab seinem Anfang lagen mitten im Unterarm; dazu kam die Haltung vom Bild davor. Jetzt Griff in der Faust (rig.py:
	# Handmitte 6,6 cm hinter dem Handgelenk, zur Handflaeche), Stiel quer durch die Faust, zu zwei Dritteln aufgerichtet
	var pose := sk.global_transform * sk.get_bone_global_pose(sk.find_bone(ba.bone_name))
	var achse := (pose.basis * faust_achse).normalized()
	if achse.y < 0.0: achse = -achse
	var y := achse.lerp(Vector3.UP, 0.65).normalized()
	var x := (global_basis.x - y * global_basis.x.dot(y)).normalized()
	t.global_basis = Basis(x, y, x.cross(y))
	t.global_position = pose * faust_griff
	# Flamme steht unabhaengig vom Stiel aufrecht und weht beim Laufen nach hinten (Runde 5b, gemessen: +X kippt nach vorn)
	var b := Basis(Vector3.UP, rotation.y)
	b = b.rotated(global_basis.x.normalized(), -minf(0.6, tempo_jetzt * 0.12) + 0.1 * sin(zeit * 6.1))
	b = b.rotated(global_basis.z.normalized(), 0.1 * sin(zeit * 8.3))
	# Licht 25 cm vor der Flamme in Blickrichtung (blind 3 von 3 besser: Gesicht lesbar statt Maske; den Stiel beleuchtet es nicht, light_cull_mask)
	fackel.global_position = flamme.global_position + global_basis.z.normalized() * FACKEL_VOR
	flamme.global_basis = b * Basis.from_scale(Vector3(1.0 + 0.12 * sin(zeit * 9.3), 1.0 + 0.3 * sin(zeit * 13.0) * sin(zeit * 5.1), 1.0 + 0.12 * sin(zeit * 7.7)))
const FACKEL_VOR := 0.25
var faust_knochen := "foL-wrL"
var faust_griff := Vector3(-0.0187, 0.187, 0.0072)     # Knochenraum foL-wrL in Ruhelage (aus held3.py hand(): pc + d·3, 2 cm zur Handinnenseite)
var faust_achse := Vector3(-0.358, 0.0, -0.934)        # Breite der Hand (fw) im Knochenraum: der Stiel liegt quer in der Faust
