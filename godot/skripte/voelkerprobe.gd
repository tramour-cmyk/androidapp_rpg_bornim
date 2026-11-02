class_name VoelkerProbe
extends RefCounted
# 431 Runde 3 (Chef 01.11., 11:42, „431 wie Sokrates“; Hinweis Sokrates 11:4x: Probe wie gebaut, mit Toon-Licht, Tusche nach Licht,
# Schatten wie im Spiel): die Grundkoerper je Volk aus tools/blender348/v3/voelker.py im Spiel (Licht, Kamera, Tusche, Wiese), Ruhe-
# bewegung wie der Held (HeldFigur.bewegungen, Becken im Verhaeltnis), langsam drehend. Zahlen und Titel setzt voelker_film.py dazu.
# Am Rechner: VOELKER=<ordner> godot --path godot --resolution 1080x720 -- --figuren=<ausgabe> --teil=voelker
#   <ausgabe>/voelker/<teil>/<nnnn>.png; Teile: maenner, frauen (12 s, eine Umdrehung), huegel (Mensch, Huegelvolk Mann und Frau,
#   Goblin; 8 s), riss_vorn, riss_seite (Schattenriss der Maenner, je 3 s); <ausgabe>/voelker/lage.json: Bildmitte jeder Figur
const REIHE := ["Mensch", "Elf", "Zwerg", "Hügelvolk", "Orkblütiger"]
# 431 Runde 4 (Chef 01.11., 20:3x, Archiv 431): Hautfarbe je Volk wie der Held (HeldFigur.toene, Appearance.kt), Haltung (430 Punkt 5),
# Bart und Zoepfe des Zwergs (Haare aus held_klassen.py, an den groesseren Kopf), Familie neben Goblin und Grak (431b, 02.11., 11:17)
const VOLK_ENUM := {"Mensch": "HUMAN", "Elf": "ELF", "Zwerg": "DWARF", "Hügelvolk": "HALFLING", "Orkblütiger": "HALF_ORC"}
const ZAHN := Color(0.80, 0.74, 0.58)   # merkmale.py ZAHN (vergilbter Knochen)
# Haltung je Volk: (Knochen, Achse im Raum der Figur, Grad); die Figur blickt +Z. Seite „±“: Vorzeichen nach der Seite des Knochens
#   Zwerg „breitbeinig, standfest, Gewicht tief“: Oberschenkel 5 Grad hinaus, Fuss zurueck (Sohle flach)
#   Orkbluetiger „Schultern leicht vorgeschoben“: Schluesselbeine 9 Grad vor, Brust 3 Grad vor (der Kopf hebt sich, KopfHeben)
#   Huegelvolk „aufrecht, locker, nie geduckt“, Elf „aufrecht, Kopf hoch“: Brust 3 Grad zurueck
const HALTUNG := {
	"Zwerg": [["thigh_l", Vector3.BACK, 5.0, true], ["thigh_r", Vector3.BACK, 5.0, true], ["foot_l", Vector3.BACK, -5.0, true], ["foot_r", Vector3.BACK, -5.0, true]],
	"Orkblütiger": [["spine_03", Vector3.RIGHT, 3.0, false], ["clavicle_l", Vector3.UP, -9.0, true], ["clavicle_r", Vector3.UP, -9.0, true]],
	"Hügelvolk": [["spine_02", Vector3.RIGHT, -3.0, false]],
	"Elf": [["spine_02", Vector3.RIGHT, -3.0, false]],
}

class Haltung extends SkeletonModifier3D:
	var liste: Array = []
	func _process_modification() -> void:
		var sk := get_skeleton()
		for e in liste:
			var i := sk.find_bone(String(e[0]))
			if i < 0: continue
			var g := sk.get_bone_global_pose(i)
			var grad: float = e[2]
			# Seite: links (+X) und rechts gegengleich, damit beide hinaus bzw. beide vor gehen
			if e[3]: grad *= signf(sk.get_bone_global_rest(i).origin.x) if absf(sk.get_bone_global_rest(i).origin.x) > 0.001 else 1.0
			var neu := Basis(e[1], deg_to_rad(grad)) * g.basis.orthonormalized()
			var pi := sk.get_bone_parent(i)
			var pg := sk.get_bone_global_pose(pi) if pi >= 0 else Transform3D()
			sk.set_bone_pose_rotation(i, (pg.basis.orthonormalized().inverse() * neu).get_rotation_quaternion())
const FPS := 30.0
const ABSTAND := 0.85      # m zwischen den Figuren einer Reihe
const BREITE := 4.4        # m Bildbreite (Kamera.zoom), 5 Figuren
const MITTE_Y := 0.1       # Kamera sieht auf diese Hoehe + 0,9 (Kamera nah)
# Runde 4, Pruefer Lauf 41430558274 (Grak und Goblin beruehren sich, 21 s): die Familie weiter auseinander, Bild entsprechend breiter
const ABSTAND_TEIL := {"familie": 1.0}
# Pruefer Lauf 41430558274 (C3: alle atmen im selben Takt, gleiche Stelle der Schleife): je Figur eine andere Stelle (Anteil der Schleife)
const VERSATZ := [0.0, 0.43, 0.19, 0.71, 0.57, 0.31]

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
	# Goblin neben Huegelvolk, Orkbluetiger neben Grak (431b: Unterschied auf einen Blick)
	_reihe("familie", ["goblin", "Hügelvolk/mann", "Elf/mann", "Orkblütiger/mann", "grak"], ort + Vector3(17, 0, 0))
	var schwarz := StandardMaterial3D.new()
	schwarz.albedo_color = Color.BLACK
	schwarz.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for f in reihen["riss"][1]:
		for m in (f as Node3D).find_children("*", "MeshInstance3D", true, false):
			(m as MeshInstance3D).material_override = schwarz
	_hintergrund(reihen["riss"][0].position)
	await fp.get_tree().create_timer(1.0).timeout
	await _diagnose(ort + Vector3(24, 0, 0))
	if OS.get_environment("VOELKER_NUR_DIAGNOSE") != "": return   # Ablauf mit Eingabe diagnose: nur das Vergleichsbild, kein Film
	await _laufen(["maenner", "frauen"], 12.0, true)
	await _laufen(["huegel"], 8.0, true)
	await _laufen(["familie"], 8.0, true)
	await _laufen(["riss"], 3.0, false, "riss_vorn")
	for f in reihen["riss"][1]: (f as Node3D).rotation_degrees.y = 90.0
	await _laufen(["riss"], 3.0, false, "riss_seite")
	FileAccess.open(fp.aus + "/voelker/lage.json", FileAccess.WRITE).store_string(JSON.stringify(lage, " "))


func _reihe(teil: String, keys: Array, x0: Vector3) -> void:
	var marker := Node3D.new()
	fp.spiel.add_child(marker)
	var ab: float = ABSTAND_TEIL.get(teil, ABSTAND)
	marker.position = x0 + Vector3((keys.size() - 1) * ab / 2.0, MITTE_Y, 0)
	marker.set_meta("zoom", BREITE * ab / ABSTAND)
	var figs := []
	var eintraege := []
	for i in keys.size():
		var w := Node3D.new()
		fp.spiel.add_child(w)
		w.position = x0 + Vector3(i * ab, 0, 0)
		w.set_meta("versatz", VERSATZ[i % VERSATZ.size()])
		w.set_meta("schluessel", String(keys[i]))
		var m: Node3D
		var e: Dictionary = daten.get(keys[i], {})
		if keys[i] in ["goblin", "grak"]:
			if not FileAccess.file_exists(dir.path_join(keys[i] + ".glb")): w.free(); fp.protokoll.append("FEHLT " + keys[i]); continue
			m = Gebiet.lade_glb(dir.path_join(keys[i] + ".glb"))
			Gebiet.male(m, null, 2, [])
			w.add_child(m)
			var gap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
			if gap and not gap.get_animation_list().is_empty():
				var l := gap.get_animation_list()
				gap.play("Stehen" if l.has("Stehen") else l[0])
				_atem(w, m, gap, teil + "/" + String(keys[i]), i)
			e = {"volk": "Goblin" if keys[i] == "goblin" else "Grak", "datei": keys[i] + ".glb"}
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
			_atem(w, m, ap, teil + "/" + String(keys[i]), i)
			var volk := String(e["volk"])
			var g := "w" if e["frau"] else "m"
			HeldFigur.toene(m, {"haut": 0, "haarfarbe": 0, "geschlecht": g}, String(VOLK_ENUM.get(volk, "HUMAN")))
			_zahn(m)
			if HALTUNG.has(volk):
				var hm := Haltung.new()
				hm.liste = HALTUNG[volk]
				sk.add_child(hm)
				sk.move_child(hm, 0)   # vor KopfHeben: der Kopf hebt sich danach auf die neue Brust
			if volk == "Zwerg": _zwerghaar(m, sk, e, g, mats)
			_eigene_haut(m, e, g)
			var soll: float = float(e["ziel"]["h"]) * (0.93 if e["frau"] else 1.0)
			_ziel_linie(w, soll)
			fp.protokoll.append("VOLK %s %s: Becken-Faktor %.3f, Hoehe %.3f m" % [teil, keys[i], f, float(e["groesse_m"])])
		figs.append(w)
		eintraege.append(e)
	reihen[teil] = [marker, figs, eintraege]


# 431c C3 (Pruefer Lauf 41439148830: Zwerg und Huegelvolk atmen fast gleichzeitig; die UAL-Ruhe atmet zweimal je Schleife, 1,3 s je
# Zug, „hecheln“): eigene Atemschicht wie Held und Leute im Dorf (Gebiet.atem_an, 453.2): Stehen bleibt im ersten Bild, nur die Schicht
# atmet, je Figur eigener Takt (atem.gd eigen, 4,3 s ± 15 %) und Startphase im Abstand der Reihe (i / Anzahl, gegeneinander versetzt).
# Der Film laeuft nicht in Echtzeit: die Schicht schreitet selbst nicht fort (takt sehr gross), _laufen setzt die Phase je Filmbild.
func _atem(w: Node3D, m: Node3D, ap: AnimationPlayer, schluessel: String, i: int) -> void:
	var at = Gebiet.atem_an(m, ap, hash(schluessel) ^ 431)
	if at == null:
		fp.protokoll.append("ATEM %s: ohne (kein UAL-Geruest)" % schluessel)
		return
	var takt: float = at.takt
	var start: float = fposmod(float(VERSATZ[i % VERSATZ.size()]) + 0.5 * at.phase, 1.0)
	at.takt = 1.0e9
	at.phase = start
	w.set_meta("atem", at)
	w.set_meta("atem_takt", takt)
	w.set_meta("atem_start", start)
	fp.protokoll.append("ATEM %s: Takt %.2f s, Start %.2f" % [schluessel, takt, start])


# Pruefer Lauf 41430558274 (B1: Haut kreideweiss wie Gips, Ork blass mint; Runde 3 ohne Toenung nicht): HeldFigur.toene nimmt als
# Bezug die Bildfarbe des Heldenkopfs (held-klassen.json haut_bild, OnlyHead), der Shader rechnet Bild / Bezug mal Zielton; die Voelker
# tragen das Bild des FullBody-Koerpers. Darum hier der Bezug aus dem eigenen Bild (voelker.py haut_bild, dieselbe Stelle im Gesicht)
# 431c B1, Ursache (Vergleichsbild Lauf 41476649959, gleiches Licht wie Dorf und Wiese: Sonne 0,455, Umgebung 0,275): ohne Toenung zeigt
# das Gesicht echte Haut (Mensch 180/131/91, Ork 183/134/92), getoent ueberstrahlt es (Mensch 235/234/232, Ork 205/225/210 tuerkis), auch
# der Held mit Hautton 1 (234/232/200 statt Ziel 212/162/124). Die Eichung HeldFigur.HAUT_EICHUNG (1,145/0,96/0,97) setzt die Albedo
# im Gesicht auf etwa den Zielton selbst; dieses Licht hebt sie aber um das 1,4- bis 1,9-fache (gemessen: Albedo des Bildes zu Farbe im
# Bild, Mensch 0,708/0,538/0,602, Ork 0,783/0,559/0,636). Hier darum die Albedo so, dass das Gesicht im Bild den Zielton zeigt: Zielton
# linear mal dem Mittel dieser Messung. Der Held im Spiel bleibt bei seiner Eichung (Aussehen urteilt der Chef, Frage in der Vorlage).
const EICHUNG_LICHT := Vector3(0.745, 0.549, 0.619)

func _eigene_haut(m: Node3D, e: Dictionary, g: String) -> void:
	var held: Array = HeldFigur.geschlecht_info(g).get("haut_bild", [])
	var bild := "ohne"
	var ton := HeldFigur.ton(String(VOLK_ENUM.get(String(e["volk"]), "HUMAN")), "haut", 0)
	var tl := ton.srgb_to_linear()
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var me := (mi as MeshInstance3D).mesh
		for i in me.get_surface_count():
			var src := me.surface_get_material(i)
			var rn := String(src.resource_name) if src else ""
			if not (rn.contains("Regular") or rn.contains("Superhero")): continue
			if src is BaseMaterial3D and (src as BaseMaterial3D).albedo_texture:
				var t := (src as BaseMaterial3D).albedo_texture
				bild = "%dx%d" % [t.get_width(), t.get_height()]
			var sm := (mi as MeshInstance3D).get_surface_override_material(i) as ShaderMaterial
			if sm == null or !(e.get("haut_bild") is Array): continue
			sm.set_shader_parameter("toen_bild", HeldFigur._lin(e["haut_bild"]))
			sm.set_shader_parameter("toen_hell", HeldFigur._hell(e["haut_bild"]))
			if ton.r >= 0.0: sm.set_shader_parameter("toenung", Vector3(tl.r, tl.g, tl.b) * EICHUNG_LICHT)
	fp.protokoll.append("HAUTBILD %s %s: eigen %s, Held %s, Bild %s, Zielton %s, Eichung %s" % [String(e["volk"]), g, str(e.get("haut_bild", "fehlt")),
		str(held), bild, ton.to_html(false), str(EICHUNG_LICHT)])


# Hauer (merkmale.py, Material „Hauer“ ohne Bild): Farbe ueber die Toenung des Toon-Shaders (toen_hell 0: Faktor)
func _zahn(m: Node3D) -> void:
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var me := (mi as MeshInstance3D).mesh
		for i in me.get_surface_count():
			var src := me.surface_get_material(i)
			if src == null or not String(src.resource_name).begins_with("Hauer"): continue
			var sm := (mi as MeshInstance3D).get_surface_override_material(i) as ShaderMaterial
			if sm == null: continue
			var l := ZAHN.srgb_to_linear()
			sm.set_shader_parameter("toenung", Vector3(l.r, l.g, l.b))
			fp.protokoll.append("HAUER %s getoent" % mi.name)


# Zwerg (430 Punkt 3): Mann voller Bart bis aufs Brustbein, Frau zwei Zoepfe. Aus den Haaren des Helden (held_klassen.py, haare.bin,
# haare_w.bin) der laengste Bart bzw. die Frisur mit den tiefsten Strähnen; der Zwergkopf ist groesser (voelker.py kopf_skala gegen
# den Menschen), darum am Kopfknochen um dessen Ursprung vergroessert statt nur verschoben (HeldFigur.haare)
func _zwerghaar(m: Node3D, sk: Skeleton3D, e: Dictionary, g: String, mats: Array) -> void:
	var datei := "res://daten/haare.bin" if g == "m" else "res://daten/haare_w.bin"
	if not FileAccess.file_exists(datei): fp.protokoll.append("FEHLT " + datei); return
	var hs := Gebiet.lade_glb(datei)
	var gi := HeldFigur.geschlecht_info(g)
	var namen: Array = gi.get("baerte", []) if g == "m" else gi.get("haare", [])
	var best := ""
	var tief := 9.0
	var zoepfe := namen.filter(func(n): return String(n).to_lower().contains("braid") or String(n).to_lower().contains("pigtail"))
	for n in (zoepfe if g == "w" and not zoepfe.is_empty() else namen):
		var q := hs.find_child(String(n), true, false) as MeshInstance3D
		if q == null: continue
		var bb := HeldFigur.im_raum(hs, q) * q.mesh.get_aabb()
		if bb.position.y < tief: tief = bb.position.y; best = String(n)
	if best == "": fp.protokoll.append("FEHLT Haar Zwerg " + g); return
	var ref: Array = gi.get("kopf", [0, 0, 0])
	var kb := sk.find_bone("Head")
	var ruhe := HeldFigur.im_raum(m, sk) * sk.get_bone_global_rest(kb)
	var mensch: Dictionary = daten.get("Mensch/" + ("frau" if e["frau"] else "mann"), {})
	var s := float(e.get("kopf_skala", 1.0)) / maxf(float(mensch.get("kopf_skala", 1.0)), 0.01)
	var q := hs.find_child(best, true, false) as MeshInstance3D
	var ba := BoneAttachment3D.new()
	ba.bone_name = "Head"
	sk.add_child(ba)
	var mi := MeshInstance3D.new()
	mi.name = best
	mi.mesh = q.mesh
	var p_ref := Vector3(ref[0], ref[1], ref[2])
	mi.transform = ruhe.affine_inverse() * Transform3D(Basis().scaled(Vector3.ONE * s), ruhe.origin - s * p_ref) * HeldFigur.im_raum(hs, q)
	ba.add_child(mi)
	var hm := []
	Gebiet.male(mi, null, 2, hm)
	for x in hm: (x as ShaderMaterial).set_shader_parameter("fill", 0.42)
	mats.append_array(hm)
	HeldFigur.toene(m, {"haut": 0, "haarfarbe": 0, "geschlecht": g}, "DWARF")
	fp.protokoll.append("ZWERGHAAR %s %s Faktor %.3f, tiefster Punkt %.3f m, Auswahl %s" % [g, best, s, tief, str(zoepfe if g == "w" else namen)])


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
	kam.zoom = float(marker.get_meta("zoom", BREITE))
	kam.springe()


# 431c G1 (Pruefer Lauf 41439148830: Graks Axt ragt 21-26 s oben rechts aus dem Bild): vor dem Film je Reihe pruefen, ob jede Figur
# ganz im Bild bleibt, auch gedreht: um jede Figur ein Zylinder (groesster Abstand einer Netzecke von der Achse, hoechster Punkt, mit
# RAND fuer die Ruhebewegung); ragt ein Punkt hinaus, Ausschnitt in Schritten von 8 % weiter. Messzeile AUSSCHNITT
const RAND := 1.15
func _ausschnitt(t: String) -> void:
	var marker: Node3D = reihen[t][0]
	var cam := fp.spiel.kamera as Camera3D
	var zyl := []
	for w in reihen[t][1]:
		var r := 0.0
		var h := 0.0
		for mi in (w as Node3D).find_children("*", "MeshInstance3D", true, false):
			if mi.name == "Ziel": continue
			var bb: AABB = (w as Node3D).global_transform.affine_inverse() * (mi as MeshInstance3D).global_transform * (mi as MeshInstance3D).get_aabb()
			for k in 8:
				var ecke := bb.get_endpoint(k)
				r = maxf(r, Vector2(ecke.x, ecke.z).length())
				h = maxf(h, ecke.y)
		zyl.append([w, r * RAND, h * RAND])
	var start: float = marker.get_meta("zoom", BREITE)
	for schritt in 12:
		_kamera(marker)
		await fp.get_tree().process_frame
		var raus := ""
		for z in zyl:
			var p: Vector3 = (z[0] as Node3D).global_position
			for k in 16:
				var a := TAU * k / 8.0
				var rr: float = z[1] if k < 8 else minf(z[1], 0.35)   # unten nur die Fuesse (Ring am Boden), oben Arme, Waffe, Kopf
				var q := p + Vector3(cos(a) * rr, z[2] if k < 8 else 0.0, sin(a) * rr)
				# Frustum statt unproject_position (anderer Massstab als das Bild, voelker_film.py)
				if not cam.is_position_in_frustum(q): raus = String(z[0].get_meta("schluessel", "")); break
			if raus != "": break
		if raus == "":
			fp.protokoll.append("AUSSCHNITT %s: Zoom %.2f (vorher %.2f), %d Schritte" % [t, float(marker.get_meta("zoom")), start, schritt])
			return
		marker.set_meta("zoom", float(marker.get_meta("zoom")) * 1.08)
	fp.protokoll.append("AUSSCHNITT %s: nach 12 Schritten noch hinaus, Zoom %.2f" % [t, float(marker.get_meta("zoom"))])


# 431c B1, Ursache nachstellen (Lauf 41439148830: Voelker kreideweiss, Ork tuerkis, Waesche blaugruen): Godot bekommt dieselben Werte wie
# gerechnet (tests/haut_431.gd, Lauf 41474466012: Bild, Format, Toenung), Runde 3 ohne Toenung zeigte Haut. Hier nebeneinander, gleiches
# Licht: der Held (Kaempfer, Hautton 1 wie im Spiel), Mensch und Ork getoent wie im Film und ohne Toenung (Runde 3). Je Figur die
# Gesichtsfarbe im Bild (5 x 5 Punkte vor dem Kopfknochen) und das Licht der Probe als Messzeilen DIAG; das Bild nur ins Artefakt.
func _diagnose(x0: Vector3) -> void:
	_reihe("diagnose", ["Mensch/mann", "Mensch/mann", "Orkblütiger/mann", "Orkblütiger/mann"], x0)
	var figs: Array = reihen["diagnose"][1]
	var namen := ["Mensch getoent", "Mensch ohne Toenung", "Ork getoent", "Ork ohne Toenung"]
	for k in [1, 3]:
		if k >= figs.size(): continue
		for mi in (figs[k] as Node3D).find_children("*", "MeshInstance3D", true, false):
			var me := (mi as MeshInstance3D).mesh
			for i in me.get_surface_count():
				var src := me.surface_get_material(i)
				var rn := String(src.resource_name) if src else ""
				var sm := (mi as MeshInstance3D).get_surface_override_material(i) as ShaderMaterial
				if sm and (rn.contains("Regular") or rn.contains("Superhero")):
					sm.set_shader_parameter("toen_hell", 0.0)
					sm.set_shader_parameter("toenung", Vector3.ONE)
	var hw := Heldwerte.erschaffe("Probe", "HUMAN", "FIGHTER")
	fp.klasse_figur("diag_held", {"klasse": "FIGHTER", "volk": "HUMAN", "aussehen": HeldFigur.vorgabe("FIGHTER"), "ausruestung": hw.ausruestung})
	if fp.figuren.has("diag_held"):
		var h: Node3D = fp.figuren["diag_held"]
		h.position = x0 + Vector3(4 * ABSTAND, 0, 0)
		figs.append(h)
		namen.append("Held Kaempfer Hautton 1")
	var marker: Node3D = reihen["diagnose"][0]
	marker.position = x0 + Vector3(2 * ABSTAND, MITTE_Y, 0)
	for f in figs: (f as Node3D).rotation.y = 0.0
	DirAccess.make_dir_recursive_absolute(fp.aus + "/voelker/diagnose")
	_kamera(marker)
	for n in 3: await fp.get_tree().process_frame
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var img := fp.spiel.get_viewport().get_texture().get_image()
	img.save_png(fp.aus + "/voelker/diagnose/0000.png")
	var cam := fp.spiel.kamera as Camera3D
	var mitte := cam.unproject_position(marker.global_position)
	var sx := img.get_width() / 2.0 / maxf(mitte.x, 1.0)   # Massstab wie voelker_film.py (Reihenmitte = Bildmitte)
	var sy := sx
	for k in figs.size():
		var f: Node3D = figs[k]
		var sk := Gebiet.finde(f, "Skeleton3D") as Skeleton3D
		var kopf := f.global_position + Vector3(0, 1.6, 0)
		if sk and sk.find_bone("Head") >= 0:
			kopf = sk.global_transform * sk.get_bone_global_pose(sk.find_bone("Head")).origin + Vector3(0, 0.06, 0)
		var vorn := kopf + (cam.global_position - kopf).normalized() * 0.12
		var p := cam.unproject_position(vorn) * Vector2(sx, sy)
		var summe := Vector3.ZERO
		var n := 0
		for dy in range(-2, 3):
			for dx in range(-2, 3):
				var q := Vector2i(int(p.x) + dx * 2, int(p.y) + dy * 2)
				if q.x < 0 or q.y < 0 or q.x >= img.get_width() or q.y >= img.get_height(): continue
				var c := img.get_pixelv(q)
				summe += Vector3(c.r, c.g, c.b); n += 1
		var m := summe / maxf(n, 1) * 255.0
		fp.protokoll.append("DIAG %s: Gesicht im Bild %d/%d/%d bei %d,%d" % [namen[k], m.x, m.y, m.z, p.x, p.y])
	var lc: Node = fp.spiel.licht
	fp.protokoll.append("DIAG Licht: Sonne %.3f %s, Umgebung %.3f %s, Stand %s, Bild %dx%d, Ansicht %s" % [lc.sonne.light_energy, lc.sonne.light_color,
		lc.env.ambient_light_energy, lc.env.ambient_light_color, str(lc.stand), img.get_width(), img.get_height(), fp.spiel.get_viewport().get_visible_rect().size])
	for f in figs: (f as Node3D).visible = false


func _laufen(teile: Array, sek: float, drehen: bool, name := "") -> void:
	var n := int(round(sek * FPS))
	for t in teile: await _ausschnitt(t)
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
					ap.seek(fmod(zeit + float(w.get_meta("versatz", 0.0)) * lang, lang), true)
				if w.has_meta("atem"):
					w.get_meta("atem").phase = fposmod(float(w.get_meta("atem_start")) + zeit / float(w.get_meta("atem_takt")), 1.0)
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
