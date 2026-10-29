class_name HeldFigur
extends RefCounted
# 376.1 (Chef 28.10., 22:0x: „die vier spielbaren Klassen mal auf das gute Modell mit dem guten Kopf … in der [Charaktererstellung]
# doch auch Einfluss nehmen … die jeweiligen Klassen ihre Standard-Grundausruestung kriegen, sichtbar“): der Held je Klasse auf dem
# Kaufkoerper (tools/blender348/v3/held_klassen.py: daten/held_<KLASSE>.bin, haare.bin, bewegungen.bin, held-klassen.json).
# Aussehen (Erschaffung, Zustand.aussehen): Kopfform als Formschluessel, Haar und Bart am Kopfknochen, Haar- und Hautfarbe getoent;
# die angelegte Waffe und der Schild haengen unterwegs auf dem Ruecken (DESIGN-STIL „Ausruestung unterwegs“).
# Fehlen die Dateien (Bau ohne Kaufmodelle), bleibt der bisherige Held (daten/held.bin).

const INFO := "res://daten/held-klassen.json"
# form: Formschluessel (leer: wie gekauft); frisur, bart: Netz in haare.bin (leer: ohne); haut, haarfarbe: Nummer im Volk (held.json
# voelker.<VOLK>.haut/haar, Appearance.kt wie die alte Erschaffung)
const VORGABE := {"form": "", "frisur": "Hair_SimpleParted", "bart": "", "haarfarbe": 0, "haut": 0}
# Chef 28.10., 23:0x („die 6 Beispielköpfe … auf Helden drauf basteln“; Haut „klinisch tot“, „normale Hautfarbe oder eine
# klassentypische“): je Klasse ein fertiger Beispielkopf als Vorgabe, keiner mit „Hell“; in der Erschaffung frei aenderbar
const KLASSEN_VORGABE := {
	"FIGHTER": {"form": "kantig", "frisur": "Hair_Buzzed", "bart": "Hair_Beard", "haarfarbe": 0, "haut": 1},
	"CLERIC": {"form": "rund", "frisur": "Hair_Balding", "bart": "Hair_Beard", "haarfarbe": 2, "haut": 2},
	"ROGUE": {"form": "schmal", "frisur": "Hair_Ponytail", "bart": "", "haarfarbe": 3, "haut": 1},
	"WIZARD": {"form": "hager", "frisur": "Hair_SlickBack", "bart": "Hair_Moustache", "haarfarbe": 1, "haut": 3},
}
# Haut lebendig (Chef 23:0x „klinisch tot“): Licht, Umgebung und Stimmung (licht.gd) nehmen der Haut Farbe (Lauf 1, haut.txt: Wange
# „Warm“ 166/137/104 statt Feld 212/162/124, „Hell“ grau 180/165/141); je Kanal geeicht auf die Farbe des Felds bei gleicher
# Helligkeit (Eichung 1,66/1,39/1,40 durch ihre Helligkeit; nicht heller: Chef „dunkler“), dazu ein Teil der Farbschwankung des Bildes
const HAUT_EICHUNG := Vector3(1.145, 0.96, 0.97)
const HAUT_FARBE := 0.5
# Bewegungen, die sich wiederholen (wie held.gd Gebiet.bewegungen)
const SCHLEIFEN := ["Stehen", "Gehen", "Rennen", "Stehen_2", "Stehen_3", "Sitzen", "Gesten"]

static var info := {}
static var haare_szene: Node3D = null
static var bew_lib: AnimationLibrary = null
static var bew_becken := 1.0

# Woerter der Erschaffung (376.1; Homer prueft sie, Vorgang 376.1 bei Homer): Gesicht nach den Formen des Kopfblatts (Chef 27.10.,
# 21:41 „Gefällt mir gut“), Frisur und Bart nach den Netzen des Pakets; Frisuren nach dem Bild (Homer 405, STORY-SPIEL [405.frisur])
const WORTE := {
	"form": ["Gesicht", "Face"], "frisur": ["Frisur", "Hairstyle"], "bart": ["Bart", "Beard"],
	"form:": ["Oval", "Oval"], "form:schmal": ["Schmal", "Narrow"], "form:rund": ["Rund", "Round"], "form:kantig": ["Kantig", "Angular"],
	"form:hager": ["Hager", "Gaunt"],
	"frisur:": ["Kahl", "Bald"], "frisur:Hair_SimpleParted": ["Scheitel", "Parted"], "frisur:Hair_Buzzed": ["Kurz", "Buzzed"],
	"frisur:Hair_SlickBack": ["Zerzaust", "Tousled"], "frisur:Hair_Ponytail": ["Zopf", "Ponytail"], "frisur:Hair_Balding": ["Halbglatze", "Balding"],
	"frisur:Hair_Dreads": ["Locken", "Curls"], "frisur:Hair_Mohawk": ["Schopf", "Forelock"],
	"bart:": ["Ohne", "None"], "bart:Hair_Beard": ["Vollbart", "Full beard"], "bart:Hair_Moustache": ["Schnurrbart", "Moustache"],
	"bart:Hair_MuttonChops": ["Koteletten", "Mutton chops"],
}

static func wort(k: String) -> String:
	var w: Array = WORTE.get(k, [k, k])
	return String(w[0] if Sprache.aktiv() == "de" else w[1])

static func formen() -> Array: return [""] + Array(lade_info().get("formen", []))
static func frisuren() -> Array: return Array(lade_info().get("haare", [])) + [""]
static func baerte() -> Array: return [""] + Array(lade_info().get("baerte", []))

static func lade_info() -> Dictionary:
	if info.is_empty() and FileAccess.file_exists(INFO):
		var j = JSON.parse_string(FileAccess.get_file_as_string(INFO))
		if j is Dictionary: info = j
	return info

static func da(klasse: String) -> bool:
	return lade_info().get("klassen", {}).has(klasse) and FileAccess.file_exists("res://daten/held_%s.bin" % klasse) \
		and FileAccess.file_exists("res://daten/bewegungen.bin")

# Auswahl aus dem Spielstand
static func wahl(w: Heldwerte, z: Zustand) -> Dictionary:
	return {"klasse": w.klasse if w else "FIGHTER", "volk": w.volk if w else "HUMAN", "aussehen": z.aussehen if z else {},
		"ausruestung": w.ausruestung if w else {}}

static func vorgabe(klasse: String) -> Dictionary:
	return (KLASSEN_VORGABE.get(klasse, VORGABE) as Dictionary).duplicate()

static func aussehen_voll(a: Dictionary, klasse := "") -> Dictionary:
	var v := vorgabe(klasse)
	for k in a: v[k] = a[k]
	return v

# Die Figur: Wurzel des glb mit AnimationPlayer „AnimationPlayer“ (Stehen, Gehen, Rennen, Stehen_2, Stehen_3, …); mats bekommt die
# Toon-Materialien (held.gd: fill, Nacht). Ergebnis in meta: „gehen_m_je_s“, „rennen_m_je_s“, „faust_L“ (Knochen, Griff, Achse)
static func baue(w: Dictionary, mats: Array) -> Node3D:
	var k := String(w.get("klasse", "FIGHTER"))
	if not da(k): return null
	var a := aussehen_voll(w.get("aussehen", {}), k)
	var m := Gebiet.lade_glb("res://daten/held_%s.bin" % k)
	if m == null: return null
	m.name = "Held_" + k
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	if "--ohneheben" not in OS.get_cmdline_user_args(): sk.add_child(FigurenProbe.KopfHeben.new())   # UAL senkt den Kopf (Helfer 20:2x)
	Gebiet.male(m, null, 2, mats)
	haare(m, sk, k, a, mats)
	form(m, String(a["form"]))
	toene(m, a, String(w.get("volk", "HUMAN")))
	var f := bewegungen(m, sk)
	m.set_meta("gehen_m_je_s", float(info.get("gehen_m_je_s", 1.08)) * f)
	m.set_meta("rennen_m_je_s", float(info.get("rennen_m_je_s", 0.0)) * f)
	m.set_meta("faust_L", faust(sk, "l"))
	bewaffne(m, sk, w.get("ausruestung", {}))
	return m

# Transform des Knotens n im Raum der Wurzel m (ohne Baum: Figur noch nicht eingehaengt)
static func im_raum(m: Node, n: Node) -> Transform3D:
	var t := Transform3D.IDENTITY
	var x := n
	while x != null and x != m:
		if x is Node3D: t = (x as Node3D).transform * t
		x = x.get_parent()
	return t

# ---------------------------------------------------------------- Bewegungen (UAL, nur Drehungen; Becken im Verhaeltnis der Beckenhoehe)
static func bewegungen(m: Node3D, sk: Skeleton3D) -> float:
	if bew_lib == null:
		var sc := Gebiet.lade_glb("res://daten/bewegungen.bin")
		var ap0 := Gebiet.finde(sc, "AnimationPlayer") as AnimationPlayer
		var sk0 := Gebiet.finde(sc, "Skeleton3D") as Skeleton3D
		bew_becken = maxf(0.01, sk0.get_bone_rest(sk0.find_bone("pelvis")).origin.length())
		bew_lib = AnimationLibrary.new()
		for n in ap0.get_animation_list(): bew_lib.add_animation(n, ap0.get_animation(n).duplicate(true))
		sc.free()
	var f := sk.get_bone_rest(sk.find_bone("pelvis")).origin.length() / bew_becken
	var lib := AnimationLibrary.new()
	var pfad := String(m.get_path_to(sk)) if sk.is_inside_tree() else str(_pfad(m, sk))
	for n in bew_lib.get_animation_list():
		var an := bew_lib.get_animation(n).duplicate(true) as Animation
		for t in range(an.get_track_count() - 1, -1, -1):
			var bn := String(an.track_get_path(t)).get_slice(":", 1)
			an.track_set_path(t, NodePath("%s:%s" % [pfad, bn]))
			var ty := an.track_get_type(t)
			if ty == Animation.TYPE_SCALE_3D or (ty == Animation.TYPE_POSITION_3D and bn not in ["pelvis", "root"]) or sk.find_bone(bn) < 0:
				an.remove_track(t)
			elif ty == Animation.TYPE_POSITION_3D:
				for i in an.track_get_key_count(t): an.track_set_key_value(t, i, an.track_get_key_value(t, i) * f)
		if n in SCHLEIFEN: an.loop_mode = Animation.LOOP_LINEAR
		lib.add_animation(n, an)
	var ap := AnimationPlayer.new()
	ap.name = "AnimationPlayer"
	m.add_child(ap)
	ap.root_node = NodePath("..")
	ap.add_animation_library("", lib)
	return f

static func _pfad(m: Node, n: Node) -> NodePath:
	var teile: PackedStringArray = []
	var x := n
	while x != null and x != m:
		teile.insert(0, String(x.name))
		x = x.get_parent()
	return NodePath("/".join(teile))

# ---------------------------------------------------------------- Kopf: Form, Haar, Bart, Farben
static func form(m: Node3D, f: String) -> void:
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var me := (mi as MeshInstance3D).mesh as ArrayMesh
		if me == null: continue
		for i in me.get_blend_shape_count():
			(mi as MeshInstance3D).set_blend_shape_value(i, 1.0 if String(me.get_blend_shape_name(i)) == f else 0.0)

static func haare(m: Node3D, sk: Skeleton3D, k: String, a: Dictionary, mats: Array) -> void:
	if not FileAccess.file_exists("res://daten/haare.bin"): return
	if haare_szene == null: haare_szene = Gebiet.lade_glb("res://daten/haare.bin")
	var kb := sk.find_bone("Head")
	if haare_szene == null or kb < 0: return
	# Haare liegen in der Ruhelage der Bezugsfigur (Kopfknochen bei info.kopf); an diesen Kopf nur verschoben
	var ref: Array = info.get("kopf", [0, 0, 0])
	var ich: Array = info["klassen"][k].get("kopf", ref)
	var vers := Vector3(ich[0] - ref[0], ich[1] - ref[1], ich[2] - ref[2])
	var ruhe := im_raum(m, sk) * sk.get_bone_global_rest(kb)
	for n in [String(a.get("frisur", "")), String(a.get("bart", ""))]:
		if n == "": continue
		var q := haare_szene.find_child(n, true, false) as MeshInstance3D
		if q == null: continue
		var ba := BoneAttachment3D.new()
		ba.name = "Haar_" + n
		ba.bone_name = "Head"
		sk.add_child(ba)
		var mi := MeshInstance3D.new()
		mi.name = n
		mi.mesh = q.mesh
		mi.transform = ruhe.affine_inverse() * Transform3D(Basis(), vers) * im_raum(haare_szene, q)
		ba.add_child(mi)
		Gebiet.male(mi, null, 2, mats)

# Haut und Haar: die Zeichnung des Bildes im Ton des Volks (Appearance.kt): Farbe = Zielton x Bildhelligkeit / mittlere Helligkeit
# des Bildes an Gesicht bzw. Haar (held_klassen.py: haut_bild, haar_bild). Ein Faktor je Kanal (Lauf 1) gab fahles Gelbgruen: Rot
# des hell-rosigen Bildes lief ueber, Gruen und Blau wurden vervielfacht (Pruefer 22:5x: Wange 193/192/157 statt „Hell“ EACBAE)
static func toene(m: Node3D, a: Dictionary, volk: String) -> void:
	var haut := ton(volk, "haut", int(a.get("haut", 0)))
	var haar := ton(volk, "haar", int(a.get("haarfarbe", 0)))
	var hb := _hell(info.get("haut_bild", [1, 1, 1]))
	var hh := _hell(info.get("haar_bild", [1, 1, 1]))
	var hbild := _lin(info.get("haut_bild", [1, 1, 1]))
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var me := (mi as MeshInstance3D).mesh
		for i in me.get_surface_count():
			var src := me.surface_get_material(i)
			var rn := String(src.resource_name) if src else ""
			var sm := (mi as MeshInstance3D).get_surface_override_material(i) as ShaderMaterial
			if sm == null: continue
			var z := Color(-1, 0, 0)
			var b := 0.0
			var ist_haut := rn.contains("Regular") or rn.contains("Superhero")
			if ist_haut: z = haut; b = hb
			elif rn.contains("Hair"): z = haar; b = hh
			if z.r < 0.0: continue
			var l := z.srgb_to_linear()
			var t := Vector3(l.r, l.g, l.b)
			if ist_haut:
				t *= haut_eichung()
				sm.set_shader_parameter("toen_bild", hbild)
				sm.set_shader_parameter("toen_farbe", haut_farbe())
			sm.set_shader_parameter("toenung", t)
			sm.set_shader_parameter("toen_hell", b)

# Probe am Rechner (Klassenlauf): --hauteichung=r,g,b und --hautfarbe=x ersetzen die Konstanten
static func haut_eichung() -> Vector3:
	for x in OS.get_cmdline_user_args():
		if x.begins_with("--hauteichung="):
			var p := x.substr(14).split(",")
			return Vector3(float(p[0]), float(p[1]), float(p[2]))
	return HAUT_EICHUNG

static func haut_farbe() -> float:
	for x in OS.get_cmdline_user_args():
		if x.begins_with("--hautfarbe="): return float(x.substr(12))
	return HAUT_FARBE

static func _lin(c: Array) -> Vector3:
	var l := Color(float(c[0]), float(c[1]), float(c[2])).srgb_to_linear()
	return Vector3(l.r, l.g, l.b)

static func _hell(c: Array) -> float:
	var l := Color(float(c[0]), float(c[1]), float(c[2])).srgb_to_linear()
	return maxf(0.01, 0.2126 * l.r + 0.7152 * l.g + 0.0722 * l.b)

static func toene_liste(volk: String, was: String) -> Array:
	var v: Dictionary = Heldwerte.lade().get("voelker", {}).get(volk, {})
	return v.get(was, [])

static func ton(volk: String, was: String, i: int) -> Color:
	var l := toene_liste(volk, was)
	if l.is_empty(): return Color(-1, 0, 0)
	return Color.html(String(l[clampi(i, 0, l.size() - 1)]["rgb"]))

# Faust der Kaufhand: Griff zwischen den Knoecheln von Zeige- und Kleinfinger, Achse dazwischen (wie figurenprobe.gd bewaffne)
static func faust(sk: Skeleton3D, s: String) -> Dictionary:
	var h := sk.find_bone("hand_" + s)
	var z := sk.find_bone("index_01_" + s)
	var p := sk.find_bone("pinky_01_" + s)
	if h < 0 or z < 0 or p < 0: return {}
	var hr := sk.get_bone_global_rest(h).affine_inverse()
	var zf := hr * sk.get_bone_global_rest(z).origin
	var kf := hr * sk.get_bone_global_rest(p).origin
	return {"knochen": "hand_" + s, "griff": (zf + kf) * 0.5, "achse": (zf - kf).normalized()}

# ---------------------------------------------------------------- Ausruestung unterwegs: Schild und Waffe auf dem Ruecken
static func bewaffne(m: Node3D, sk: Skeleton3D, aus: Dictionary) -> void:
	for alt in sk.find_children("Ruecken*", "", false, false): alt.free()
	var bi := sk.find_bone("spine_03")
	if bi < 0: return
	var brust := im_raum(m, sk) * sk.get_bone_global_rest(bi)
	var schild := _modell(aus.get("OFF_HAND"))
	var waffe := _modell(aus.get("MAIN_HAND"))
	# Ruhelage: die Figur blickt nach +Z, ihre linke Seite ist +X. Schild auf dem Ruecken (Vorderseite nach hinten), geneigt wie der
	# Ruecken zwischen Schulterblatt und Kreuz (Pruefer Lauf 1: unten 5-7 cm Spalt); die Waffe schraeg, Griff ueber der rechten
	# Schulter, hinter allem, was hinten am weitesten absteht (Lauf 1: Schwert hinter dem Schild verdeckt, Parierstange im Umhang)
	var y := brust.origin.y
	var r := ruecken(m, y - 0.63, y + 0.1)   # [z oben, z unten, hinterste z]: Ruecken an Ober- und Unterkante des Schilds
	var aussen: float = r[2]
	if schild != "":
		# Pruefer Lauf 2 (Kaempfer: Schild ragt von vorn ueber die Schultern; Schild 0,72 m, Oberkante 1,54 m, Schultern 1,46 m):
		# Mitte 29 cm unter spine_03, Oberkante etwa 1,32 m (376.1 Lauf 1: bei 1,42 m von schraeg oben noch ueber den Schultern)
		var oben := Vector3(0, y - 0.05, float(r[0]) - 0.03)
		var unten := Vector3(0, y - 0.53, float(r[1]) - 0.03)
		var hoch := (oben - unten).normalized()
		var t := Transform3D(Basis(Vector3.LEFT, hoch, Vector3.LEFT.cross(hoch)), (oben + unten) * 0.5)
		_haenge(m, sk, bi, brust, schild, t, "RueckenSchild")
		aussen = minf(aussen, (oben.z + unten.z) * 0.5) - 0.07   # Schild mit Buckel etwa 6 cm
	if waffe != "":
		var lang := waffe in ["quarterstaff", "staff", "spear", "greataxe"]
		var achse := Vector3(0.42, -1.0, 0.0).normalized() if not lang else Vector3(0.62, -1.0, 0.0).normalized()   # Klinge zur linken Huefte
		var griff := Vector3(-0.17, y + 0.22, aussen - 0.03) if not lang else Vector3(-0.05, y + 0.05, aussen - 0.03)
		var quer := Vector3.FORWARD
		var t := Transform3D(Basis(achse.cross(quer).normalized(), achse, quer), griff)
		_haenge(m, sk, bi, brust, waffe, t, "RueckenWaffe")

# hinterste Stelle des Rumpfs (z, Ruhelage) auf Hoehe des Schulterblatts (y1 - 0,15) und des Kreuzes (y0 + 0,1), dazu die hinterste
# zwischen y0 und y1; nur die Mitte (|x| < 0,12), alle Netze mit Haut (Koerper, Kleidung, Umhang)
static func ruecken(m: Node3D, y0: float, y1: float) -> Array:
	var oben := 9.0; var unten := 9.0; var ganz := 9.0
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		if not (mi as MeshInstance3D).skin: continue
		var t := im_raum(m, mi)
		var me := (mi as MeshInstance3D).mesh
		for s in me.get_surface_count():
			for v in me.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				var p: Vector3 = t * v
				if absf(p.x) > 0.12 or p.y < y0 or p.y > y1: continue
				ganz = minf(ganz, p.z)
				if absf(p.y - (y1 - 0.15)) < 0.04: oben = minf(oben, p.z)
				if absf(p.y - (y0 + 0.1)) < 0.04: unten = minf(unten, p.z)
	if ganz > 8.0: ganz = -0.15
	return [oben if oben < 8.0 else ganz, unten if unten < 8.0 else ganz, ganz]

static func _modell(g) -> String:
	if not g is Dictionary: return ""
	var b := String(g.get("base", ""))
	return b if FileAccess.file_exists("res://daten/waffen/%s.bin" % b) else ""

static func _haenge(m: Node3D, sk: Skeleton3D, bi: int, brust: Transform3D, was: String, t: Transform3D, nm: String) -> void:
	var ba := BoneAttachment3D.new()
	ba.name = nm
	ba.bone_name = sk.get_bone_name(bi)
	sk.add_child(ba)
	var d := Gebiet.lade_glb("res://daten/waffen/%s.bin" % was)
	if d == null: return
	d.transform = brust.affine_inverse() * t
	ba.add_child(d)
	Gebiet.male(d, null, 2, [])
