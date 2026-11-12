class_name HauptmenueHelden
extends Control
# 867 (Chef 10.11., 13:48: „die 4 Figuren, die ich da sehe, sind ja noch aus Kotlin. Gehört überarbeitet. Da müssen aktuell die
# Helden hin, die wir haben“): die vier Helden des Hauptmenues aus den Figuren des Spiels (HeldFigur.baue wie Erschaffung und Drehteller)
# statt des alten Bilds (assets/menu/hauptmenue.jpg). Aufstellung wie dort: Kaempferin, Magier, Zwerg, Klerikerin, jetzt nach BRS als
# Herkunft mit ihrer Startausruestung; in wahrer Groesse (B7) nebeneinander, die aeusseren zur Mitte gewandt, im warmen Lichtkegel auf
# Schwarz. Ein Standbild: nach wenigen Bildern zeichnet der Teller nicht mehr (wie Drehteller dreht=false). Ohne Modelle (am Rechner) leer.

const DP := AktionsKnopf.DP
# 867 (Chef 12.11., 21:55 „867 Haltungen A“; 21:40 „pro Char eine andere Haltung, in der Waffe und Schild gesehen werden“): je Held eine
# eigene ruhige Stehhaltung mit der Waffe in der Hand (haltung: Datei daten/menue-<haltung>.bin aus den Protofactor-Saetzen, godot.yml
# „Hauptmenübild (867)“; leer: „Stehen“ der UAL mit dem Wanderstab aufgestuetzt, tragen.gd stab), die aeusseren 30 Grad zur Mitte, die
# inneren 10, der Kopf zum Spieler (kopf: Anteil der Drehung, den Hals und Kopf zurueckdrehen)
const HELDEN := [
	# Sokrates 23:13 (Vorlage 3 „nicht so“): Klosterschuelerin stand fast frontal -> aussen 35 Grad, der Kopf dreht weniger zurueck;
	# Zauberlehrling hielt den Stab am ausgestreckten Arm -> Arm 22 Grad an den Koerper (arm)
	{"herkunft": "Wachsoldat", "volk": "Mensch", "geschlecht": "w", "x": -1.32, "dreh": 35.0, "haltung": "schildwache", "kopf": 0.4},
	{"herkunft": "Zauberlehrling", "volk": "Mensch", "geschlecht": "m", "x": -0.44, "dreh": 12.0, "haltung": "zauberer", "kopf": 0.5, "arm": 22.0},
	{"herkunft": "Jägerkind", "volk": "Zwerg", "geschlecht": "m", "x": 0.44, "dreh": -12.0, "haltung": "bogen", "kopf": 0.5},
	{"herkunft": "Klosterschüler", "volk": "Elf", "geschlecht": "w", "x": 1.32, "dreh": -35.0, "haltung": "", "kopf": 0.4},
]
# Schein: Mitte (0,5/0,86) im Bild, Halbachsen waagrecht 0,5, nach oben 0,86, nach unten 0,14; warm in der Mitte, aussen schwarz
const SCHEIN := """shader_type canvas_item;
uniform vec3 farbe : source_color = vec3(0.30, 0.20, 0.10);
void fragment() {
	vec2 d = UV - vec2(0.5, 0.86);
	d.x /= 0.5;
	d.y /= (d.y < 0.0) ? 0.86 : 0.14;
	float r = length(d);
	COLOR = vec4(farbe * (1.0 - smoothstep(0.0, 1.0, r)), 1.0);
}
"""
const BILD_HOEHE := 2.3        # Meter, die das Bild hoch zeigt (Stab, Hut), Fuesse unten mit Rand
var _v: SubViewport
var _bilder := 0
var figuren: Array[Node3D] = []

func _init(breite_dp := 330.0) -> void:
	custom_minimum_size = Vector2(breite_dp, breite_dp * 0.625) * DP   # Seitenverhaeltnis des alten Bilds (600 x 375)
	# 867 (Chef 12.11., 20:01: „mit einem vernünftigen Licht“; Vorlage 18:00: der Schein endete unten und seitlich mit harter Kante):
	# Schein als Ellipse um die Fuesse, nach allen Seiten weich ins Schwarz (kein Rand des Bilds sichtbar)
	var licht := ColorRect.new()
	var sh := Shader.new()
	sh.code = SCHEIN
	var sm := ShaderMaterial.new()
	sm.shader = sh
	licht.material = sm
	licht.color = Color(0, 0, 0)
	licht.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	licht.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(licht)
	var c := SubViewportContainer.new()
	c.stretch = true
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(c)
	var v := SubViewport.new()
	v.own_world_3d = true
	v.transparent_bg = true
	v.msaa_3d = Viewport.MSAA_4X
	c.add_child(v)
	_v = v
	var welt := WorldEnvironment.new()
	welt.environment = Environment.new()
	welt.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	welt.environment.ambient_light_color = Color(0.5, 0.44, 0.38)
	v.add_child(welt)
	var sonne := DirectionalLight3D.new()   # warm von vorn oben wie der Lichtkegel
	sonne.light_color = Color(1.0, 0.9, 0.76)
	sonne.rotation_degrees = Vector3(-38, -18, 0)
	v.add_child(sonne)
	# 867 (Chef 20:01; 292.3 „Gesichter erkennbar“): Lampe vorn oben, wie der Lichtkegel von oben, hellt die Gesichter auf; das dunkle
	# Gesicht des Zauberlehrlings lag in der ersten Vorlage fast ganz im Schatten
	var lampe := OmniLight3D.new()
	lampe.light_color = Color(1.0, 0.86, 0.66)
	lampe.light_energy = 1.6
	lampe.omni_range = 6.0
	lampe.omni_attenuation = 1.2
	lampe.position = Vector3(0, 2.5, 2.2)
	v.add_child(lampe)
	var kam := Camera3D.new()
	kam.fov = 26.0
	kam.position = Vector3(0, BILD_HOEHE / 2.0 - 0.08, BILD_HOEHE / 2.0 / tan(deg_to_rad(kam.fov) / 2.0))
	v.add_child(kam)
	for h in HELDEN:
		var w := wahl(h)
		var mats := []
		var m: Node3D = HeldFigur.baue(w, mats)
		if m == null: continue
		var trg := Node3D.new()
		trg.position = Vector3(float(h["x"]), 0, 0)
		trg.rotation.y = deg_to_rad(float(h["dreh"]))
		v.add_child(trg)
		trg.add_child(m)
		for mt in mats:
			(mt as ShaderMaterial).set_shader_parameter("metall", 1.0)
			(mt as ShaderMaterial).set_shader_parameter("licht_dir", Basis.from_euler(sonne.rotation).z)
		var anim := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		var hl := haltung(m, w, String(h["haltung"]), float(h.get("arm", 0.0))) if anim else ""
		if anim and hl == "":
			Gebiet.bewegungen(anim, ["Stehen"])
			hl = "Stehen" if anim.has_animation("Stehen") else ""
		if hl != "":
			anim.play(hl)
			anim.seek(anim.get_animation(hl).length * (0.15 + 0.2 * figuren.size()), true)   # nicht im Gleichtakt (C3)
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		if sk and float(h.get("kopf", 0.0)) > 0.0:
			var kd := KopfDrehen.new()
			kd.grad = -float(h["dreh"]) * float(h["kopf"])
			sk.add_child(kd)
		trg.set_meta("haltung", hl)
		figuren.append(trg)

## 867: die Haltung n aus daten/menue-<n>.bin (Protofactor-Satz auf dem Geruest der UAL, zauber385.py) auf die Figur m wie
## HeldFigur.bewegungen (nur Drehungen, Becken im Verhaeltnis der Beckenhoehe); die Waffe in die Faust wie die Paketbewegungen
## (tragen.gd _paket), der Schild an den linken Arm (schildarm); ohne Datei leer (dann „Stehen“)
static func haltung(m: Node3D, w: Dictionary, n: String, arm := 0.0) -> String:
	var datei := "res://daten/menue-%s.bin" % n
	if n == "" or not FileAccess.file_exists(datei): return ""
	var sc := Gebiet.lade_glb(datei)
	if sc == null: return ""
	var ap0 := Gebiet.finde(sc, "AnimationPlayer") as AnimationPlayer
	var sk0 := Gebiet.finde(sc, "Skeleton3D") as Skeleton3D
	var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	if ap0 == null or sk0 == null or ap == null or sk == null or ap0.get_animation_list().is_empty():
		sc.free(); return ""
	var f := sk.get_bone_rest(sk.find_bone("pelvis")).origin.length() / maxf(0.01, sk0.get_bone_rest(sk0.find_bone("pelvis")).origin.length())
	var namen := Array(ap0.get_animation_list()).filter(func(x): return String(x) != "RESET")
	var wahl_ := namen.filter(func(x): return String(x).contains("Menue_"))
	if namen.is_empty():
		sc.free(); return ""
	var an := ap0.get_animation(wahl_[0] if not wahl_.is_empty() else namen[0]).duplicate(true) as Animation
	sc.free()
	var pfad := String(m.get_path_to(sk)) if sk.is_inside_tree() else str(HeldFigur._pfad(m, sk))
	for t in range(an.get_track_count() - 1, -1, -1):
		var bn := String(an.track_get_path(t)).get_slice(":", 1)
		an.track_set_path(t, NodePath("%s:%s" % [pfad, bn]))
		var ty := an.track_get_type(t)
		if ty == Animation.TYPE_SCALE_3D or (ty == Animation.TYPE_POSITION_3D and bn not in ["pelvis", "root"]) or sk.find_bone(bn) < 0:
			an.remove_track(t)
		elif ty == Animation.TYPE_POSITION_3D:
			for i in an.track_get_key_count(t): an.track_set_key_value(t, i, an.track_get_key_value(t, i) * f)
	an.loop_mode = Animation.LOOP_LINEAR
	var lib := AnimationLibrary.new()
	lib.add_animation(n, an)
	ap.add_animation_library("menue", lib)
	var name_ := "menue/" + n
	if arm > 0.0:   # vor die Waffen: die Waffe folgt der angezogenen Faust
		var an_ := ArmAnziehen.new()
		an_.grad = arm
		an_.seite = hoehere_hand(sk, ap, name_)
		sk.add_child(an_)
	waffen_in_die_hand(m, sk, ap, w.get("ausruestung", {}), name_)
	return name_

## 867: Waffe und Schild wie in der Haltung gehalten: was bewaffne() auf den Ruecken oder als Wanderstab gestellt hat, weg; die Waffe in
## die Hand, die in der Haltung hoeher steht (Stab des Zauberers), der Bogen links, der Schild an den linken Arm
static func waffen_in_die_hand(m: Node3D, sk: Skeleton3D, ap: AnimationPlayer, aus: Dictionary, bew: String) -> void:
	var neben = aus.get("OFF_HAND")
	var schild := HeldFigur._modell(neben) if neben is Dictionary and String(Beute.grundform(String(neben.get("base", ""))).get("art", "")) == "SHIELD" else ""
	var waffe := HeldFigur._modell(aus.get("MAIN_HAND"))
	for alt in sk.find_children("Ruecken*", "", false, false): alt.free()
	for alt in m.get_children():
		if String(alt.name).contains("Getragen"): alt.free()
	for alt in sk.get_children():
		if alt is Tragen: alt.free()
	var bogen := waffe in Tragen.GANG_BOGEN
	var seite := "l" if bogen else hoehere_hand(sk, ap, bew)
	var paare := []
	if waffe != "": paare.append([waffe, "bogen" if bogen else "einhand", seite])
	if schild != "": paare.append([schild, "schildarm", "l"])
	for p in paare:
		var d := Gebiet.lade_glb("res://daten/waffen/%s.bin" % p[0])
		if d == null: continue
		d.name = "Getragen"
		d.top_level = true
		m.add_child(d)
		Gebiet.male(d, null, 2, [])
		var t := Tragen.new("", d, m, HeldFigur.faust(sk, String(p[2])))
		t.halt = Halt.gegenstand(String(p[0]))
		t.gang = String(p[1]); t.seite = String(p[2]); t.anim = ap
		t.schild_abspreiz = 0.0; t.schwert_abspreiz = 0.0   # die Haltung fuehrt den Arm
		sk.add_child(t)
	print("MENU867 Haltung %s: Waffe %s in %s, Schild %s" % [bew, waffe, seite, schild])

## die Hand, die in der Haltung (Mitte der Bewegung) hoeher steht: r oder l
static func hoehere_hand(sk: Skeleton3D, ap: AnimationPlayer, bew: String) -> String:
	var an := ap.get_animation(bew)
	var y := {"l": 0.0, "r": 0.0}
	for s_ in y:
		var i := sk.find_bone("hand_" + s_)
		if i < 0: continue
		# Weltlage aus den Spuren der Kette bis zur Wurzel, Bild in der Mitte
		var t := Transform3D.IDENTITY
		var b := i
		var kette := []
		while b >= 0:
			kette.push_front(b); b = sk.get_bone_parent(b)
		for k in kette:
			var r := sk.get_bone_rest(k)
			var tr := an.find_track(NodePath("%s:%s" % [String(an.track_get_path(0)).get_slice(":", 0), sk.get_bone_name(k)]), Animation.TYPE_ROTATION_3D)
			if tr >= 0: r.basis = Basis(an.rotation_track_interpolate(tr, an.length * 0.5))
			t = t * r
		y[s_] = t.origin.y
	return "r" if y["r"] >= y["l"] else "l"

## 867 (Sokrates 23:13: Stab am ausgestreckten Arm wirkt steif): Oberarm der Seite um grad zum Koerper hin, um die Vorwaertsachse
## der Figur (vor den Waffen gestellt, die Waffe folgt der Faust)
class ArmAnziehen extends SkeletonModifier3D:
	var grad := 0.0
	var seite := "l"
	func _process_modification() -> void:
		var sk := get_skeleton()
		if sk == null: return
		var i := sk.find_bone("upperarm_" + seite)
		if i < 0: return
		var vorn := (sk.global_basis.inverse() * (sk.get_parent_node_3d().global_basis * Vector3.BACK)).normalized() if sk.is_inside_tree() and sk.get_parent_node_3d() else Vector3.BACK
		# linke Seite der Figur ist +X: der linke Arm kommt mit negativer Drehung um vorn (+Z) herunter, der rechte mit positiver
		var w := deg_to_rad(grad) * (-1.0 if seite == "l" else 1.0)
		var g := sk.get_bone_global_pose(i)
		var n := Basis(vorn, w) * g.basis.orthonormalized()
		var p := sk.get_bone_global_pose(sk.get_bone_parent(i))
		sk.set_bone_pose_rotation(i, (p.basis.orthonormalized().inverse() * n).get_rotation_quaternion())

## 867: Hals und Kopf um die Hochachse der Figur zum Spieler (grad, zu gleichen Teilen auf neck_01, neck_02, Head)
class KopfDrehen extends SkeletonModifier3D:
	var grad := 0.0
	func _process_modification() -> void:
		var sk := get_skeleton()
		if sk == null or absf(grad) < 0.1: return
		var kette := ["neck_01", "neck_02", "Head"].map(func(n): return sk.find_bone(n)).filter(func(i): return i >= 0)
		if kette.is_empty(): return
		var oben := (sk.global_basis.inverse() * Vector3.UP).normalized() if sk.is_inside_tree() else Vector3.UP   # Hochachse der Welt im Skelettraum
		for i in kette:
			var g := sk.get_bone_global_pose(i)
			var n := Basis(oben, deg_to_rad(grad / kette.size())) * g.basis.orthonormalized()
			var p := sk.get_bone_global_pose(sk.get_bone_parent(i))
			sk.set_bone_pose_rotation(i, (p.basis.orthonormalized().inverse() * n).get_rotation_quaternion())

## die Wahl eines Helden wie in der Erschaffung (erschaffung_brs.gd wahl_jetzt): Herkunft, Volk, Aussehen, Startausruestung
static func wahl(h: Dictionary) -> Dictionary:
	var b := BrsHeld.neu(String(h["volk"]), String(h["herkunft"]))
	b.ausstatten()
	var g := String(h["geschlecht"])   # Haarfarbe der Herkunft nach dem Volk (HeldFigur.vorgabe, baue mit volk)
	var a := {"geschlecht": g}
	# Frisur, Bart, Haar- und Hautfarbe der Herkunft wie in der Erschaffung (HeldFigur.vorgabe); 867 Chef 18:23: mit derselben ersten
	# Frisur fuer alle Maenner sahen Zauberlehrling und Jaegerkind aus „wie Brüder“
	var bt := HeldFigur.baerte(g)
	if g == "m" and String(h["volk"]) == "Zwerg" and bt.size() > 1: a["bart"] = bt[1]
	return {"herkunft": String(h["herkunft"]), "volk": HeldFigur.volk_modell(String(h["volk"])), "aussehen": a, "ausruestung": b.ausruestung}

func _process(_dt: float) -> void:
	if _v and _bilder < 8:   # Standbild: erst zeichnen, wenn Groesse und Haltung stehen, dann aus
		_bilder += 1
		if _bilder == 8: _v.render_target_update_mode = SubViewport.UPDATE_DISABLED
