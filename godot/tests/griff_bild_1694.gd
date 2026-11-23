extends SceneTree
# 1694 (23.11., Einzelbild Handbeil: Netzmessung 340° Umschlingung, im Bild liegt der Stiel zwischen gespreizten Fingern, Daumen offen):
# Prüfung nach dem, was die Kamera sieht (Profil Figur „Messen“: das Bild gilt). Held steht im Dorf, angehalten in der Endpose; Kamera
# nah an der Faust aus zwei Richtungen im Rahmen der Hand: innen (Handfläche) und außen (Handrücken). Gezeichnet wird nur das Stück des
# Schafts, das in der Faust liegt (zwischen den Ebenen durch Zeige- und Kleinfingergrundgelenk, quer zum Schaft), in Prüffarbe ohne
# Licht; gezählt werden seine Bildpunkte mit Körper und ohne Körper. „sichtbar“ = mit / ohne: in einer geschlossenen Faust deckt die Hand
# den Schaft von beiden Seiten. Daneben die Netzmessung (NetzMess.griff) im selben Bild, zum Vergleich.
#   NUR=<waffe> [BILDER=<ordner>] xvfb-run -a godot --path . --resolution 600x600 -s res://tests/griff_bild_1694.gd -- --sehen1694   (Exit 1 bei Fehler;
#   ohne Argument nach -- liegt das Hauptmenü vor der Szene)

const FOLGE := ["handaxe", "longsword", "quarterstaff", "greatsword", "greataxe"]
const BLICKE := ["innen", "aussen"]
const SICHTBAR_HOECHST := 0.10    # Anteil des Schafts in der Faust, der höchstens zu sehen sein darf (Schlitz zwischen Kuppen und Ballen)
const PRUEF := Color(1.0, 0.0, 1.0)

const SHADER := """
shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled, fog_disabled;
uniform vec3 a; uniform vec3 d; uniform float t0; uniform float t1;
varying vec3 wp;
void vertex() { wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
	float t = dot(wp - a, d);
	if (t < t0 || t > t1) discard;
	ALBEDO = vec3(1.0, 0.0, 1.0);
}
"""

var fehler_zahl := 0

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 13 * 60
	spiel.licht_nach_uhr(true)
	spiel.betrete("village", Vector2i(17, 5), "UP")
	for i in 5: await process_frame
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	spiel.werte = BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", spiel.zustand.neue_uid)
	var hw = spiel.held_werte()
	hw.ausruestung.erase("OFF_HAND")
	var kam := Camera3D.new()
	root.add_child(kam)
	kam.fov = 30.0
	var sh := Shader.new(); sh.code = SHADER
	var mat := ShaderMaterial.new(); mat.shader = sh
	var ordner := OS.get_environment("BILDER")
	for i in FOLGE.size():
		if OS.get_environment("NUR") != "" and FOLGE[i] != OS.get_environment("NUR"): continue
		hw.ausruestung["MAIN_HAND"] = {"uid": 9700 + i, "base": FOLGE[i], "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
		spiel.held.process_mode = Node.PROCESS_MODE_INHERIT
		spiel.held_figur_neu("")
		spiel.held.richtung = Vector3.ZERO
		var sk := Gebiet.finde(spiel.held.modell, "Skeleton3D") as Skeleton3D
		for f in 40: await process_frame
		var t: Tragen = null
		for n in sk.get_children():
			if n is Tragen: t = n
		if t == null or t.waffe == null:
			print("SEHEN1694 %s: kein Tragen" % FOLGE[i]); continue
		t.merken = true
		# Netzmessung im letzten Bild vor dem Anhalten (dieselbe Pose, die danach gezeichnet wird)
		var netz := {}
		sk.skeleton_updated.connect(func(): netz.merge(NetzMess.griff(sk, "r", t.waffe, t.halt)), CONNECT_ONE_SHOT)   # Lambda: Wert kopiert, darum merge
		await process_frame
		spiel.held.process_mode = Node.PROCESS_MODE_DISABLED
		await process_frame
		var G := sk.global_transform
		var P := func(b: String) -> Vector3: return G * t.posen[sk.find_bone(b + "_r")].origin
		var lang: Vector3 = (P.call("middle_01") - P.call("hand")).normalized()
		var quer: Vector3 = (P.call("index_01") - P.call("pinky_01")).normalized()
		var fl := lang.cross(quer).normalized()
		if fl.dot(P.call("thumb_01") - P.call("hand")) < 0.0: fl = -fl
		# Schaftachse, wie gezeichnet: Griffrahmen des Gegenstands, Mitte des Querschnitts an der Faust
		var hm := t.halt.duplicate() if not t.halt.is_empty() else {"griff": Vector3.ZERO, "achse": Vector3.UP, "vorn": Vector3.RIGHT}
		var W: Transform3D = t.waffe.global_transform * Halt.griff_rahmen(hm)
		var d := W.basis.y.normalized()
		var sch := Griff.schaft(t.waffe, t.halt)
		var faust: Vector3 = (P.call("index_01") + P.call("pinky_01")) * 0.5
		var yq := (W.affine_inverse() * faust).y
		var c := Griff.mitte_bei(sch, yq - 0.02, yq + 0.02)
		var a := W * Vector3(c.x, yq, c.y)
		if OS.get_environment("PUNKTE") != "":
			var Wi := W.affine_inverse()
			print("SCHAFT lo %.3f hi %.3f k %.3f faust %.3f" % [sch.lo, sch.hi, W.basis.y.length(), yq])
			for b in ["index_01", "middle_01", "ring_01", "pinky_01", "pinky_03"]: print("SCHAFT %s y %.3f quer %.3f" % [b, (Wi * P.call(b)).y, Vector2((Wi * P.call(b)).x, (Wi * P.call(b)).z).length()])
		var ti: float = (P.call("index_01") - a).dot(d); var tk: float = (P.call("pinky_01") - a).dot(d)
		mat.set_shader_parameter("a", a); mat.set_shader_parameter("d", d)
		mat.set_shader_parameter("t0", minf(ti, tk)); mat.set_shader_parameter("t1", maxf(ti, tk))
		var waffen_netze := t.waffe.find_children("*", "MeshInstance3D", true, false) + ([t.waffe] if t.waffe is MeshInstance3D else [])
		var koerper := sk.find_children("*", "MeshInstance3D", true, false).filter(func(m): return not m in waffen_netze)
		# Kleidung (Ärmel, Rock) hängt im Blick auf die Handfläche vor der Faust: in dieser Prüfung aus, gezählt wird nur die Hand
		for m in koerper: if String(m.name).begins_with("Kleid_"): (m as MeshInstance3D).visible = false
		if OS.get_environment("NETZE") != "": print("NETZE ", koerper.map(func(m): return String(m.name)))
		var zeile := ""
		var gut := true
		for bl in BLICKE:
			var r: Vector3 = fl if bl == "innen" else -fl
			var mitte := faust + fl * 0.01
			kam.global_position = mitte + r * 0.32 + lang * 0.06
			kam.look_at(mitte, lang)
			kam.near = 0.22   # was näher als 22 cm an der Kamera liegt (Oberschenkel vor der Handfläche), zeichnet sie nicht
			kam.make_current()
			for m in waffen_netze: (m as MeshInstance3D).material_override = mat
			var mit := await _zaehle()
			if OS.get_environment("PUNKTE") != "":
				for b in ["index_03", "middle_03", "ring_03", "pinky_03", "thumb_03", "index_01", "pinky_01"]:
					print("PUNKT %s %s %s" % [bl, b, kam.unproject_position(P.call(b))])
			if ordner != "": root.get_viewport().get_texture().get_image().save_png("%s/%s-%s-maske.png" % [ordner, FOLGE[i], bl])
			var sichtbar_vorher := {}
			for m in koerper:
				sichtbar_vorher[m] = (m as MeshInstance3D).visible; (m as MeshInstance3D).visible = false
			var ohne := await _zaehle()
			for m in koerper: (m as MeshInstance3D).visible = sichtbar_vorher[m]
			for m in waffen_netze: (m as MeshInstance3D).material_override = null
			var anteil := float(mit) / maxf(1.0, float(ohne))
			if ohne < 50: gut = false
			if anteil > SICHTBAR_HOECHST: gut = false
			zeile += " %s sichtbar %d%% (%d von %d)" % [bl, int(round(anteil * 100.0)), mit, ohne]
			if ordner != "":
				await RenderingServer.frame_post_draw
				root.get_viewport().get_texture().get_image().save_png("%s/%s-%s.png" % [ordner, FOLGE[i], bl])
		var netz_gut: bool = not netz.is_empty() and not netz.has("leer") and NetzMess.griff_gut(netz)
		print("SEHEN1694 %-12s%s | Netz: Spalt %.1f cm, Umschlingung %d°, Glieder %.1f cm, Kuppen %.1f cm (%s)%s" % [FOLGE[i], zeile,
			netz.get("kontakt", 0.0), int(netz.get("umschl", 0.0)), netz.get("tief", 0.0), netz.get("kuppe", 0.0), "gut" if netz_gut else "Fehler", "" if gut else "  FEHLER"])
		fehler_zahl += 0 if gut else 1
		spiel.held.process_mode = Node.PROCESS_MODE_INHERIT
	print("SEHEN1694 %d Fehler" % fehler_zahl)
	quit(1 if fehler_zahl > 0 else 0)

# Bildpunkte in Prüffarbe im nächsten gezeichneten Bild
func _zaehle() -> int:
	for f in 2: await process_frame
	await RenderingServer.frame_post_draw
	var img := root.get_viewport().get_texture().get_image()
	var n := 0
	for y in img.get_height():
		for x in img.get_width():
			var p := img.get_pixel(x, y)
			if p.r > 0.8 and p.b > 0.8 and p.g < 0.25: n += 1
	return n
