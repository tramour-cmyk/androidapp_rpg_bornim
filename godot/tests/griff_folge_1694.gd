extends SceneTree
# 1694 (Auftrag 24.11., 19:47; Chef 19:39 „1694 A“): Zeitfolge statt Median. Zieht das gezeichnete Netz der Knochenpose um ein Bild nach,
# springt die Waffe, oder keins von beiden? Je Aufruf von skeleton_updated über BILDER Prozessbilder eine Zeile, ohne Median:
#   Prozess- und Physikbildnummer, Zahl der Aufrufe im selben Bild, Reihenfolge der Modifikatoren (modification_processed),
#   Beugung je Glied (16 Glieder wie griff_weg_1694), Waffe (Griffpunkt cm, Achse) in Handkoordinaten,
#   je eine feste Netzecke an Zeigefinger-Grundglied, Kleinfinger-Grundglied, Handfläche: gebackene Lage (bake) gegen starre Rechnung
#   aus Bindung und Knochenpose dieses Aufrufs (j) und des letzten Aufrufs im vorigen Bild (v), Abstand cm,
#   dazu die gezeichnete Haut am Griff (NetzMess.griff) an Zeigefinger- und Kleinfinger-Grundglied und Handfläche.
# Fehlender Wert: FEHLT.
# BILD1694=1 (Auftrag 25.11., 10:02, Profil Figur „Messen“): Messung im gezeigten Bild. Je Prozessbild in RenderingServer.frame_post_draw:
#   Netz backen (bake liest die Knochenlagen, die der RenderingServer zeichnet) und Waffe (global_transform und Lage beim letzten
#   NOTIFICATION_TRANSFORM_CHANGED, so bekommt der RenderingServer sie) im selben Augenblick; je Glied (16) Haut zum Holz cm (+ Luft,
#   − im Holz) gegen griff.gd intern (Griff.netz_finger starr, Pose nach Tragen); je Modifikator nach modification_processed
#   hand_r, index_01_r, pinky_01_r in Waffenkoordinaten (cm). Bild mit Handausschnitt: griff_folge_bild_1694.gd (nur Großaxt Stehen Spielweg, BILDAUS=<pfad.png>).
#   MESS=1694 xvfb-run -a godot --path . --resolution 540x1170 -s res://tests/griff_folge_1694.gd -- --bild1694
#   (ohne Argument hinter „--“ liegt das Hauptmenü über der Welt; die Messung betrifft das nicht, das Bild schon)
#   WEG=spiel|pruef, FALL=greataxe|quarterstaff, BEW=Gehen_axt (sonst Stehen), BILDER=60
# Befund 24.11., 22:07 (bb359430a, 6 Fälle, je 3 Läufe): im Spielweg zeigt bake im Signal in jedem Aufruf die Pose des vorigen Aufrufs
# (Abstand 0,00 cm), gegen die Pose dieses Aufrufs bis 47 cm; Prüfaufbau ruht (nicht unterscheidbar). NetzMess paart so das Netz des vorigen
# Bilds mit der Waffe dieses Bilds.
#   Exit 1, wenn das Netz in einem Aufruf nicht der Pose dieses Aufrufs folgt (über 0,1 cm).

const GLIEDER := ["hand_r", "index_01_r", "index_02_r", "index_03_r", "middle_01_r", "middle_02_r", "middle_03_r",
	"ring_01_r", "ring_02_r", "ring_03_r", "pinky_01_r", "pinky_02_r", "pinky_03_r", "thumb_01_r", "thumb_02_r", "thumb_03_r"]
const ECKEN := ["index_01_r", "pinky_01_r", "hand_r"]
const GRENZE := 0.1   # cm

var zeilen := []
var mod_folge := []        # Modifikatoren im laufenden Bild, in Reihenfolge
var vorig_bild := -1
var vorig_posen := []      # Posen (Skelettraum) des letzten Aufrufs im vorigen Prozessbild
var letzt_posen := []
var letzt_bild := -1
var im_bild := 0
var ecken := []            # [{glied, mi, su, vi, kn:[b…], gw:[…], bind:{k:b}}]

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var weg := OS.get_environment("WEG") if OS.get_environment("WEG") != "" else "spiel"
	var fall := OS.get_environment("FALL") if OS.get_environment("FALL") != "" else "greataxe"
	var bew := OS.get_environment("BEW")
	var bilder := int(OS.get_environment("BILDER")) if OS.get_environment("BILDER") != "" else 60
	var sk: Skeleton3D; var ding: Node3D; var halt := {}; var ap: AnimationPlayer
	var id := ""
	if weg == "spiel":
		var spiel = load("res://spiel.tscn").instantiate()
		root.add_child(spiel)
		for i in 5: await process_frame
		spiel.zustand.minuten = 13 * 60
		spiel.betrete("village", Vector2i(17, 5), "UP")
		for i in 5: await process_frame
		spiel.werte = BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", spiel.zustand.neue_uid)
		var hw = spiel.held_werte()
		hw.ausruestung.erase("OFF_HAND")
		if hw.get("aussehen") is Dictionary: hw.aussehen["geschlecht"] = "m"
		hw.ausruestung["MAIN_HAND"] = {"uid": 9601, "base": fall, "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
		spiel.held.process_mode = Node.PROCESS_MODE_INHERIT
		spiel.held_figur_neu("")
		spiel.held.richtung = Vector3.ZERO
		var mod: Node3D = spiel.held.modell
		sk = Gebiet.finde(mod, "Skeleton3D") as Skeleton3D
		var t: Tragen = null
		for n in sk.get_children(): if n is Tragen: t = n
		if t == null or t.waffe == null:
			print("FOLGE1694 FEHLER Spielweg: kein Tragen"); quit(1); return
		ding = t.waffe; halt = t.halt
		if OS.get_environment("GANZ1694") != "": _ganze_probe(sk, t)
		if OS.get_environment("ZWEI1694") != "":   # Gegenprobe nur im Test: Schaft nicht zur linken Faust drehen (Tragen.zwei_anteil)
			t.zwei_anteil = float(OS.get_environment("ZWEI1694")); print("BILD1694 ZWEI1694: Tragen.zwei_anteil = %.2f" % t.zwei_anteil)
		id = Staffel.datei(HeldFigur._modell(hw.ausruestung["MAIN_HAND"]))
		ap = Gebiet.finde(mod, "AnimationPlayer") as AnimationPlayer
		print("FOLGE1694 Spielweg: Tracht %s, Gegenstand %s, Tragen art=%s gang=%s" % [mod.get_meta("tracht", "?"), id, t.art, t.gang])
		if bew != "":
			spiel.held.process_mode = Node.PROCESS_MODE_DISABLED
			ap.process_mode = Node.PROCESS_MODE_ALWAYS; sk.process_mode = Node.PROCESS_MODE_ALWAYS
			for n in sk.get_children(): n.process_mode = Node.PROCESS_MODE_ALWAYS
			ap.play(bew, 0.0)
	else:
		var m := Gebiet.lade_glb("res://daten/held_WACHE_M.bin")
		root.add_child(m)
		Gebiet.male(m, null, 2, [])
		sk = Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		id = Staffel.datei(HeldFigur._modell({"base": fall, "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 1}))
		halt = Halt.gegenstand(id)
		ding = Halt.anlegen(sk, "faust_r", id, "Gehalten1694")
		Gebiet.male(ding, null, 2, [])
		GriffHand.an(sk, ding, "r", halt, GriffHand.art_von(id))
		if OS.get_environment("GANZ1694") != "": _ganze_probe(sk, null)
		ap = Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		print("FOLGE1694 Prüfaufbau: Körper %s, Gegenstand %s, Griffart %s, AnimationPlayer %s" % [m.name, id, GriffHand.art_von(id), ap != null])
		if bew != "":
			if ap == null or not ap.has_animation(bew):
				print("FOLGE1694 Prüfaufbau: Bewegung %s FEHLT" % bew); quit(2); return
			ap.play(bew, 0.0)
	print("FOLGE1694 Fall weg=%s fall=%s bew=%s; Skeleton3D modifier_callback_mode_process=%d; Modifikatoren: %s" % [weg, fall,
		bew if bew != "" else "Stehen", sk.modifier_callback_mode_process, ", ".join(_mods(sk).map(func(x): return "%s(%s)" % [x.name, x.get_class()]))])
	for f in 80: await process_frame
	if OS.get_environment("BILD1694") != "":
		await _bild_lauf(sk, ding, halt, bilder, "%s %s %s" % [weg, fall, bew if bew != "" else "Stehen"], weg == "spiel" and fall == "greataxe" and bew == "")
		return
	_ecken_waehlen(sk)
	for e in ecken: print("FOLGE1694 Ecke %s: FEHLT" % e.glied if e.has("fehlt") else "FOLGE1694 Ecke %s: Netz %s, Ecke %d, Gewichte %s" % [e.glied, e.mi.name, e.vi, str(e.gwd)])
	for x in _mods(sk): x.modification_processed.connect(func(): mod_folge.append(String(x.name)))
	var cb := func(): _aufruf(sk, ding, halt)
	sk.skeleton_updated.connect(cb)
	var start := Engine.get_process_frames()
	for f in bilder: await process_frame
	sk.skeleton_updated.disconnect(cb)
	# --- Ausgabe
	print("FOLGE1694 Spalten: P=Prozessbild (ab Start) Ph=Physikbild n=Aufruf im Bild | Modifikatoren | Waffe Griffpunkt cm (Hand) Achse |")
	print("FOLGE1694   je Ecke Z(eigefinger) K(leinfinger) H(andfläche): bake-j / bake-v cm (j: Pose dieses Aufrufs, v: letzter Aufruf im vorigen Bild) |")
	print("FOLGE1694   Haut am Griff cm (Netz) Z K H | Beugung Grad 16 Glieder " + " ".join(GLIEDER.map(func(g): return g.substr(0, g.length() - 2))))
	var schlecht := 0; var nach_v := 0; var n := 0; var ohne_v := 0; var ruht := true
	var spr_g := []
	for z in zeilen:
		var ez := ""
		for e in z.ecke: ez += " %s/%s" % [_z(e.j), _z(e.v)]
		print("FOLGE1694 P%3d Ph%4d n%d | %s | %s %s |%s | %s %s %s | %s" % [z.p - start, z.ph, z.n, ">".join(z.mods), _v(z.griff), _v(z.achse, 3), ez,
			_z(z.haut[0]), _z(z.haut[1]), _z(z.haut[2]), " ".join(z.beug.map(func(b): return "%.1f" % b))])
		spr_g.append(z.griff)
		for e in z.ecke:
			if e.j == null: continue
			if e.v == null:   # erster Aufruf: kein voriges Bild, nicht zuzuordnen
				ohne_v += 1; continue
			n += 1
			if absf(float(e.j) - float(e.v)) > 0.01: ruht = false
			if float(e.j) > GRENZE: schlecht += 1
			if e.v != null and float(e.v) <= GRENZE and float(e.j) > GRENZE: nach_v += 1
	# Auswertung
	var gmin := Vector3.INF; var gmax := -Vector3.INF
	for g in spr_g: gmin = gmin.min(g); gmax = gmax.max(g)
	var hmin := [INF, INF, INF]; var hmax := [-INF, -INF, -INF]
	for z in zeilen:
		for i in 3:
			if z.haut[i] != null: hmin[i] = minf(hmin[i], z.haut[i]); hmax[i] = maxf(hmax[i], z.haut[i])
	var jmax := 0.0; var vmax := 0.0
	for z in zeilen:
		for e in z.ecke:
			if e.j != null: jmax = maxf(jmax, e.j)
			if e.v != null: vmax = maxf(vmax, e.v)
	var zuord := "nicht unterscheidbar (Pose ruht, dieses = voriges Bild)" if ruht else ("dieses Bild" if schlecht == 0 else ("voriges Bild" if nach_v == schlecht else "keins"))
	print("FOLGE1694 ERGEBNIS weg=%s fall=%s bew=%s: %d Aufrufe in %d Bildern; Netz folgt: %s (Ecken über %.1f cm zur Pose dieses Aufrufs: %d von %d, davon passend zum vorigen Bild: %d; ohne voriges Bild FEHLT: %d Ecken; größter Abstand j %.2f, v %.2f cm)" % [
		weg, fall, bew if bew != "" else "Stehen", zeilen.size(), bilder, zuord, GRENZE, schlecht, n, nach_v, ohne_v, jmax, vmax])
	print("FOLGE1694 ERGEBNIS Waffe Griffpunkt (Hand, cm) Spanne %s; Haut am Griff Spanne Z %s K %s H %s cm" % [_v(gmax - gmin, 2),
		_spanne(hmin[0], hmax[0]), _spanne(hmin[1], hmax[1]), _spanne(hmin[2], hmax[2])])
	quit(1 if schlecht > 0 else 0)

func _aufruf(sk: Skeleton3D, ding: Node3D, halt: Dictionary) -> void:
	var p := Engine.get_process_frames()
	if p != letzt_bild:
		vorig_posen = letzt_posen; vorig_bild = letzt_bild
		im_bild = 0
	im_bild += 1
	var posen := []
	for b in sk.get_bone_count(): posen.append(sk.get_bone_global_pose(b))
	var z := {"p": p, "ph": Engine.get_physics_frames(), "n": im_bild, "mods": mod_folge.duplicate(), "beug": [], "ecke": [], "haut": [null, null, null]}
	mod_folge.clear()
	for gl in GLIEDER:
		var bi := sk.find_bone(gl)
		var par := sk.get_bone_parent(bi)
		var lok := (posen[par] as Transform3D).basis.inverse() * (posen[bi] as Transform3D).basis if par >= 0 else Basis()
		z.beug.append(rad_to_deg(Quaternion(sk.get_bone_rest(bi).basis.orthonormalized()).angle_to(Quaternion(lok.orthonormalized()))))
	var hm := halt.duplicate() if not halt.is_empty() else {"griff": Vector3.ZERO, "achse": Vector3.UP, "vorn": Vector3.RIGHT}
	var W := ding.global_transform * Halt.griff_rahmen(hm)
	var Hi := (sk.global_transform * (posen[sk.find_bone("hand_r")] as Transform3D)).affine_inverse()
	z["griff"] = Hi * W.origin * 100.0
	z["achse"] = (Hi.basis * W.basis.y).normalized()
	# feste Ecken: gebacken gegen starr
	var gebacken := {}
	for e in ecken:
		if e.has("fehlt"):
			z.ecke.append({"j": null, "v": null}); continue
		if not gebacken.has(e.mi): gebacken[e.mi] = (e.mi as MeshInstance3D).bake_mesh_from_current_skeleton_pose()
		var bm: ArrayMesh = gebacken[e.mi]
		var r := {"j": null, "v": null}
		if bm != null and e.su < bm.get_surface_count():
			var pos = bm.surface_get_arrays(e.su)[Mesh.ARRAY_VERTEX]
			if pos != null and e.vi < pos.size():
				var k: float = (e.mi as MeshInstance3D).global_basis.get_scale().y
				r.j = 100.0 * k * (pos[e.vi] as Vector3).distance_to(_starr(e, posen))
				if not vorig_posen.is_empty(): r.v = 100.0 * k * (pos[e.vi] as Vector3).distance_to(_starr(e, vorig_posen))
		z.ecke.append(r)
	# gezeichnete Haut am Griff (wie griff_weg_1694)
	var nm := NetzMess.griff(sk, "r", ding, halt)
	if int(nm.get("ecken", 0)) > 0 and not nm.has("leer"):
		for i in 3:
			var key: String = "g:" + ECKEN[i] if i < 2 else "kontakt"
			if nm.has(key) and float(nm[key]) < 90.0: z.haut[i] = float(nm[key])
	zeilen.append(z)
	letzt_posen = posen; letzt_bild = p

# lineare Hautbindung wie der Renderer: Σ w · (Pose · Bindung) · Ecke, im Raum des Netzes
func _starr(e: Dictionary, posen: Array) -> Vector3:
	var s := Vector3.ZERO
	for i in e.kn.size():
		var b: int = e.bind.get(e.kn[i], -1)
		if b < 0 or e.gw[i] <= 0.0: continue
		s += e.gw[i] * ((posen[b] as Transform3D) * (e.mi as MeshInstance3D).skin.get_bind_pose(e.kn[i]) * (e.roh as Vector3))
	return s

# je Glied die Ecke mit dem größten Gewicht am Knochen, ohne Formschlüssel-Versatz
func _ecken_waehlen(sk: Skeleton3D) -> void:
	for gl in ECKEN:
		var ziel := sk.find_bone(gl)
		var best := {}; var bw := -1.0
		for mi in sk.find_children("*", "MeshInstance3D", true, false):
			var m3 := mi as MeshInstance3D
			if m3.mesh == null or m3.skin == null or not m3.visible: continue
			var bind := {}
			for k in m3.skin.get_bind_count():
				var nm := m3.skin.get_bind_name(k)
				bind[k] = sk.find_bone(nm) if nm != "" else m3.skin.get_bind_bone(k)
			for su in m3.mesh.get_surface_count():
				var roh := m3.mesh.surface_get_arrays(su)
				var pos = roh[Mesh.ARRAY_VERTEX]; var kn = roh[Mesh.ARRAY_BONES]; var gw = roh[Mesh.ARRAY_WEIGHTS]
				if kn == null or gw == null or pos == null or pos.size() == 0: continue
				var je: int = kn.size() / pos.size()
				var bs := (m3.mesh as ArrayMesh).surface_get_blend_shape_arrays(su) if m3.mesh is ArrayMesh else []
				for vi in pos.size():
					var w := 0.0
					for k in je:
						if bind.get(int(kn[vi * je + k]), -1) == ziel: w += gw[vi * je + k]
					if w <= bw: continue
					var bewegt := false
					for bi in bs.size():
						if m3.get_blend_shape_value(bi) == 0.0: continue
						var bp = bs[bi][Mesh.ARRAY_VERTEX]
						if bp == null or vi >= bp.size(): continue
						var d: Vector3 = bp[vi] if (m3.mesh as ArrayMesh).blend_shape_mode == Mesh.BLEND_SHAPE_MODE_RELATIVE else bp[vi] - pos[vi]
						if d.length() > 1e-5: bewegt = true
					if bewegt: continue
					bw = w
					var kl := []; var wl := []; var gwd := {}
					for k in je:
						kl.append(int(kn[vi * je + k])); wl.append(float(gw[vi * je + k]))
						if gw[vi * je + k] > 0.0: gwd[sk.get_bone_name(bind.get(int(kn[vi * je + k]), -1))] = snappedf(gw[vi * je + k], 0.01)
					best = {"glied": gl, "mi": m3, "su": su, "vi": vi, "roh": pos[vi], "kn": kl, "gw": wl, "bind": bind, "gwd": gwd}
		ecken.append(best if not best.is_empty() else {"glied": gl, "fehlt": true})

# ---------- BILD1694
const DREI := ["hand_r", "index_01_r", "pinky_01_r"]
const SPRUNG := 0.5   # cm
class Fuehler extends Node3D:
	var xf := Transform3D(); var bild := -1
	func _ready() -> void: set_notify_transform(true)
	func _notification(w: int) -> void:
		if w == NOTIFICATION_TRANSFORM_CHANGED: xf = (get_parent() as Node3D).global_transform; bild = Engine.get_process_frames()

func _bild_lauf(sk: Skeleton3D, ding: Node3D, halt: Dictionary, bilder: int, fall: String, mit_bild: bool) -> void:
	var hm := halt.duplicate() if not halt.is_empty() else {"griff": Vector3.ZERO, "achse": Vector3.UP, "vorn": Vector3.RIGHT}
	var R := Halt.griff_rahmen(hm)
	var sch := Griff.schaft(ding, halt)
	var fu := Fuehler.new(); ding.add_child(fu)
	var netze := _hand_netze(sk)
	var probe := _probe_menge(sk, netze)
	print("BILD1694 griff.gd-Probe: Handfläche Säule %d Ecken (r %.2f cm, Haut %.2f cm, Eindruck %.1f cm); Finger %d Ecken aus Griff.netz_finger" % [
		probe.saeule_n, probe.r * 100.0, probe.hm.x * 100.0, Griff.EINDRUCK * 100.0, probe.finger_n])
	var mods := _mods(sk)
	var schritt := []   # je Modifikator im laufenden Bild: [name, {glied: Vector3 cm in Waffe}, Waffe Ursprung Welt]
	var intern := {}   # Inhalt wird ersetzt (Lambda fängt die Variable als Wert)
	for x in mods:
		var xn := String(x.name)
		x.modification_processed.connect(func():
			var W := ding.global_transform * R
			var Wi := W.affine_inverse(); var G := sk.global_transform
			var l := {}
			for g in DREI: l[g] = Wi * (G * sk.get_bone_global_pose(sk.find_bone(g)).origin) * 100.0 * W.basis.y.length()
			var extra := ""
			if x is Tragen:
				var tr := x as Tragen
				var mo = tr.merk.get("o"); var md = tr.merk.get("d")
				extra = " zwei_winkel %.1f° merk.o %s merk.d %s" % [tr.zwei_winkel, "FEHLT" if mo == null else _v((mo as Vector3) * 100.0, 2), "FEHLT" if md == null else _v(md, 3)]
			elif x.get_class() == "SkeletonModifier3D" and x.has_method("get_skeleton"): pass
			schritt.append([xn + extra, l, ding.global_position])
			if x == mods[mods.size() - 1]:
				intern.clear(); intern.merge(_intern(sk, ding, halt, sch, R)))
	var zeilen_b := []
	var bild_n := [0]
	var cb := func():
		var p := Engine.get_process_frames()
		var Wg := ding.global_transform
		var z := {"p": p, "schritt": schritt.duplicate(true), "intern": intern.duplicate(), "fu_bild": fu.bild,
			"wsprung": 100.0 * Wg.origin.distance_to(fu.xf.origin)}
		schritt.clear()
		z["netz"] = _gezeichnet(sk, netze, Wg * R, sch)
		z["netz_rs"] = _gezeichnet(sk, netze, fu.xf * R, sch)
		var zl := _zerlegt(sk, netze, Wg * R, sch, probe)
		z["starr"] = zl[0]; z["lbs"] = zl[1]; z["tief"] = zl[2]; z["probe"] = zl[3]
		# gezeichnete Knochenlage (RenderingServer) von hand_r, index_01_r, pinky_01_r in Waffenkoordinaten
		var Wi := (Wg * R).affine_inverse(); var k := (Wg * R).basis.y.length()
		var dl := {}
		for g in DREI:
			var o = _rs_knochen(sk, netze, g)
			dl[g] = null if o == null else Wi * (o as Vector3) * 100.0 * k
		z["rs"] = dl
		zeilen_b.append(z)
	RenderingServer.frame_post_draw.connect(cb)
	var start := Engine.get_process_frames()
	var bild_bei := 30
	for f in bilder:
		await process_frame
		if mit_bild and f == bild_bei:
			var cam := root.get_viewport().get_camera_3d()
			var hp = _rs_knochen(sk, netze, "hand_r")
			print("BILD1694 Kamera %s, hand_r im Bild %s, Fenster %s" % [cam.get_path() if cam else "FEHLT", cam.unproject_position(hp) if cam and hp != null else "FEHLT", root.get_viewport().get_visible_rect().size])
			await RenderingServer.frame_post_draw
			var img = _nimm_bild()
			if img != null: zeilen_b[zeilen_b.size() - 1]["bild"] = img
	RenderingServer.frame_post_draw.disconnect(cb)
	print("BILD1694 Fall %s, %d Bilder; Spalten je Glied: Netz (gezeichnet, frame_post_draw, Waffe global_transform) / Netz mit Waffe beim RS / griff.gd intern; cm, + Luft, − Holz" % [fall, zeilen_b.size()])
	var sprung_max := 0.0; var wmin := {}; var wmax := {}
	var dif_max := 0.0
	for z in zeilen_b:
		var t := ""
		for gl in GLIEDER:
			t += " %s %s/%s/%s" % [gl.trim_suffix("_r"), _z(z.netz.get(gl)), _z(z.netz_rs.get(gl)), _z(z.intern.get(gl))]
		print("BILD1694 P%3d fuehler@P%d Waffe-RS %.2fcm |%s" % [z.p - start, z.fu_bild - start, z.wsprung, t])
		var st := ""
		for s2 in z.schritt:
			st += " %s:" % s2[0]
			for g in DREI: st += " %s%s" % [g.substr(0, 1), _v(s2[1][g])]
		st += " | gezeichnet(RS):"
		for g in DREI: st += " %s%s" % [g.substr(0, 1), "FEHLT" if z.rs[g] == null else _v(z.rs[g])]
		print("BILD1694 P%3d Schritte%s" % [z.p - start, st])
		var hz := ""
		for gl in GLIEDER: hz += " %s %s/%s/%s" % [gl.trim_suffix("_r"), _z(z.starr.get(gl)), _z(z.lbs.get(gl)), _z(z.netz.get(gl))]
		print("BILD1694 P%3d Haut starr(Hauptknochen, wie griff.gd)/gewichtet(ohne Formschlüssel)/gezeichnet |%s" % [z.p - start, hz])
		var tz := ""
		for gl in ["hand_r", "pinky_01_r", "index_01_r"]:
			var t0 = z.tief.get(gl)
			tz += " %s tiefste Ecke %s %s, in griff.gd-Probe tiefste %s;" % [gl, _z(t0[0]) if t0 != null else "FEHLT", t0[1] if t0 != null else "", _z(z.probe.get(gl))]
		print("BILD1694 P%3d Lage%s" % [z.p - start, tz])
		for g in DREI:
			if z.rs[g] == null: continue
			var v: Vector3 = z.rs[g]
			wmin[g] = v if not wmin.has(g) else (wmin[g] as Vector3).min(v)
			wmax[g] = v if not wmax.has(g) else (wmax[g] as Vector3).max(v)
			if not z.schritt.is_empty(): dif_max = maxf(dif_max, v.distance_to(z.schritt[z.schritt.size() - 1][1][g]))
		sprung_max = maxf(sprung_max, z.wsprung)
		if z.has("bild"): _bild_speichern(z, sk, ding)
	# Zusammenfassung je Glied: Spanne gezeichnet, Spanne intern
	for gl in GLIEDER:
		var a := []; var b := []; var fehlt := 0
		for z in zeilen_b:
			if z.netz.get(gl) == null: fehlt += 1
			else: a.append(z.netz[gl])
			if z.intern.get(gl) != null: b.append(z.intern[gl])
		a.sort(); b.sort()
		var c := []; var e := []
		for z in zeilen_b:
			if z.starr.get(gl) != null: c.append(z.starr[gl])
			if z.lbs.get(gl) != null: e.append(z.lbs[gl])
		c.sort(); e.sort()
		print("BILD1694 ERGEBNIS %-11s Netz %s (FEHLT %d) | intern %s | starr %s | gewichtet %s" % [gl, _sp(a), fehlt, _sp(b), _sp(c), _sp(e)])
	var sp := ""
	for g in DREI: if wmin.has(g): sp += " %s Spanne %s" % [g, _v(wmax[g] - wmin[g], 2)]
	print("BILD1694 ERGEBNIS gezeichnete Knochen in Waffe (cm):%s; größter Abstand gezeichnet gegen nach letztem Modifikator %.2f cm; Waffe global_transform gegen RS-Lage bis %.2f cm" % [sp, dif_max, sprung_max])
	# rot: ein Glied im gezeigten Bild tiefer im Holz als NetzMess erlaubt (Handfläche und Endglieder −1,2, sonst −0,6 cm) oder die Hand
	# springt am Schaft (gezeichnete Knochen in Waffenkoordinaten über SPRUNG cm)
	var rot := []
	for gl in GLIEDER:
		var grenze := -1.2 if gl == "hand_r" or gl.contains("_03_") else NetzMess.GLIED_HOLZ
		var tiefst := INF; var bei := -1
		for z in zeilen_b:
			if z.netz.get(gl) != null and float(z.netz[gl]) < tiefst: tiefst = z.netz[gl]; bei = z.p - start
		if tiefst < grenze: rot.append("%s %.2f cm im Holz (Grenze %.1f, Bild %d)" % [gl, tiefst, grenze, bei])
	for g in DREI:
		if wmin.has(g) and ((wmax[g] as Vector3) - (wmin[g] as Vector3)).length() > SPRUNG:
			rot.append("%s springt %.2f cm am Schaft" % [g, ((wmax[g] as Vector3) - (wmin[g] as Vector3)).length()])
	print("BILD1694 PRÜFUNG %s" % ("grün" if rot.is_empty() else "ROT: " + "; ".join(rot)))
	quit(1 if not rot.is_empty() else 0)

# Netze mit Ecken der rechten Hand (Hauptknochen unter hand_r): {mi, bind{k:b}, su:[{idx:[vi], b:[bone]}]}
func _hand_netze(sk: Skeleton3D) -> Array:
	var nm := NetzMess.new(sk); nm.knochen_unter("hand_r")
	var aus := []
	for mi in sk.find_children("*", "MeshInstance3D", true, false):
		var m3 := mi as MeshInstance3D
		if m3.mesh == null or m3.skin == null or not m3.visible: continue
		var bind := {}
		for k in m3.skin.get_bind_count():
			var nmn := m3.skin.get_bind_name(k)
			bind[k] = sk.find_bone(nmn) if nmn != "" else m3.skin.get_bind_bone(k)
		var sus := []; var n := 0
		for su in m3.mesh.get_surface_count():
			var roh := m3.mesh.surface_get_arrays(su)
			var pos = roh[Mesh.ARRAY_VERTEX]; var kn = roh[Mesh.ARRAY_BONES]; var gw = roh[Mesh.ARRAY_WEIGHTS]
			var e := {"idx": [], "b": []}
			if kn != null and gw != null and pos != null and pos.size() > 0:
				var je: int = kn.size() / pos.size()
				for vi in pos.size():
					var best := -1; var bw := 0.0
					for k in je:
						if gw[vi * je + k] > bw: bw = gw[vi * je + k]; best = int(kn[vi * je + k])
					var b: int = bind.get(best, -1)
					if nm.nur.has(b): e.idx.append(vi); e.b.append(b)
			sus.append(e); n += e.idx.size()
		if n > 0: aus.append({"mi": m3, "bind": bind, "su": sus})
	return aus

# Ursprung des Knochens [g], wie der RenderingServer ihn zeichnet: Bindung k mit bind_bone g, T_k · Bindpose_k⁻¹
func _rs_knochen(sk: Skeleton3D, netze: Array, g: String):
	var b := sk.find_bone(g)
	for n in netze:
		var m3: MeshInstance3D = n.mi
		var sr := m3.get_skin_reference()
		if sr == null: continue
		for k in n.bind:
			if n.bind[k] != b: continue
			var T := RenderingServer.skeleton_bone_get_transform(sr.get_skeleton(), k)
			return m3.global_transform * (T * m3.skin.get_bind_pose(k).affine_inverse()).origin
	return null

# gezeichnetes Netz (bake im frame_post_draw) gegen Holz, je Glied nächste Haut (cm); null: kein Teil am freien Griff = FEHLT
func _gezeichnet(sk: Skeleton3D, netze: Array, W: Transform3D, sch: Dictionary) -> Dictionary:
	var Wi := W.affine_inverse(); var k := W.basis.y.length()
	var aus := {}
	for n in netze:
		var m3: MeshInstance3D = n.mi
		var bm := m3.bake_mesh_from_current_skeleton_pose()
		if bm == null: continue
		for su in mini(bm.get_surface_count(), n.su.size()):
			var e: Dictionary = n.su[su]
			if e.idx.is_empty(): continue
			var pos = bm.surface_get_arrays(su)[Mesh.ARRAY_VERTEX]
			for i in e.idx.size():
				var q: Vector3 = Wi * (m3.global_transform * pos[e.idx[i]])
				var d = _holz(sch, q, k)
				if d == null: continue
				var gl := sk.get_bone_name(e.b[i])
				aus[gl] = minf(aus.get(gl, INF), d)
	return aus

# dieselben Ecken aus den Knochenlagen des RenderingServers (T_k = Pose · Bindpose): starr am Hauptknochen (so rechnet griff.gd,
# Griff.netz_finger) und gewichtet Σ w·T_k (wie der Renderer, ohne Formschlüssel)
func _zerlegt(sk: Skeleton3D, netze: Array, W: Transform3D, sch: Dictionary, probe: Dictionary) -> Array:
	var Wi := W.affine_inverse(); var k := W.basis.y.length()
	var st := {}; var lb := {}; var tief := {}; var pr := {}
	for n in netze:
		var m3: MeshInstance3D = n.mi
		var sr := m3.get_skin_reference()
		if sr == null: continue
		var T := {}
		for kk in m3.skin.get_bind_count(): T[kk] = RenderingServer.skeleton_bone_get_transform(sr.get_skeleton(), kk)
		for su in n.su.size():
			var e: Dictionary = n.su[su]
			if e.idx.is_empty(): continue
			var roh := m3.mesh.surface_get_arrays(su)
			var pos = roh[Mesh.ARRAY_VERTEX]; var kn = roh[Mesh.ARRAY_BONES]; var gw = roh[Mesh.ARRAY_WEIGHTS]
			var je: int = kn.size() / pos.size()
			for i in e.idx.size():
				var vi: int = e.idx[i]
				var best := -1; var bw := 0.0; var sum := Vector3.ZERO
				for kk in je:
					var w: float = gw[vi * je + kk]
					if w <= 0.0: continue
					sum += w * ((T[int(kn[vi * je + kk])] as Transform3D) * (pos[vi] as Vector3))
					if w > bw: bw = w; best = int(kn[vi * je + kk])
				var gl := sk.get_bone_name(e.b[i])
				var d1 = _holz(sch, Wi * (m3.global_transform * ((T[best] as Transform3D) * (pos[vi] as Vector3))), k)
				var d2 = _holz(sch, Wi * (m3.global_transform * sum), k)
				if d1 != null: st[gl] = minf(st.get(gl, INF), d1)
				if d2 != null: lb[gl] = minf(lb.get(gl, INF), d2)
				if d2 != null and (not tief.has(gl) or d2 < tief[gl][0]):
					tief[gl] = [d2, (probe.lage[gl] as Dictionary).get([m3, su, vi], "") if probe.lage.has(gl) else ""]
				if d1 != null and probe.drin.has([m3, su, vi]): pr[gl] = minf(pr.get(gl, INF), d1)
	return [st, lb, tief, pr]

# griff.gd-Probe: welche Ecken griff.gd sieht. Handfläche: Säule aus Griff.hand_mass (Ruhelage, Hauptgewicht hand_r, seitlich unter
# 1,2 cm·u um die Linie durch basis = mp − lang·(r + Grundglied) längs fl); Finger: Punkte aus Griff.netz_finger (Ab einem Viertel der
# Länge, ausgedünnt). lage: je Ecke Beschreibung (Handfläche: seitlicher Abstand zur Säule cm; Finger: Anteil der Gliedlänge)
func _probe_menge(sk: Skeleton3D, netze: Array) -> Dictionary:
	var u := Griff.einheit(sk, "r")
	var r := 0.0; var hm := Vector2.ZERO
	for m in sk.get_meta_list():
		if String(m).begins_with("griff_r_"): r = float(String(m).substr(8)) / 10000.0; hm = sk.get_meta(m)
	var f := Griff.flaeche(sk, "r", true)
	var mp: Vector3 = f[0]; var lang: Vector3 = f[1]; var fl: Vector3 = f[2]
	var basis := mp - lang * (r + hm.y)
	var ih := sk.find_bone("hand_r")
	var ne := Griff.netz_finger(sk, "r")
	var drin := {}; var lage := {}; var sn := 0; var fn := 0
	for n in netze:
		var m3: MeshInstance3D = n.mi
		for su in n.su.size():
			var e: Dictionary = n.su[su]
			if e.idx.is_empty(): continue
			var roh := m3.mesh.surface_get_arrays(su)
			var pos = roh[Mesh.ARRAY_VERTEX]; var kn = roh[Mesh.ARRAY_BONES]; var gw = roh[Mesh.ARRAY_WEIGHTS]
			var je: int = kn.size() / pos.size()
			for i in e.idx.size():
				var vi: int = e.idx[i]; var b: int = e.b[i]
				var best := -1; var bw := 0.0
				for kk in je:
					if gw[vi * je + kk] > bw: bw = gw[vi * je + kk]; best = int(kn[vi * je + kk])
				var lok: Vector3 = m3.skin.get_bind_pose(best) * (pos[vi] as Vector3)
				var gl := sk.get_bone_name(b)
				if not lage.has(gl): lage[gl] = {}
				if b == ih:
					var rel := sk.get_bone_global_rest(ih) * lok - basis
					var t := rel.dot(fl); var seit := (rel - fl * t).length()
					var ja := t > 0.0 and seit < 0.012 * u
					if ja: drin[[m3, su, vi]] = true; sn += 1
					lage[gl][[m3, su, vi]] = "%.1f cm neben der Säule" % (100.0 * maxf(0.0, seit - 0.012 * u)) if not ja else "in der Säule"
				else:
					var ch := sk.get_bone_children(b)
					var ln := sk.get_bone_rest(ch[0]).origin if ch.size() > 0 else Vector3.ZERO
					var anteil := lok.dot(ln) / ln.length_squared() if ln != Vector3.ZERO else -1.0
					var ja := false
					for q in ne.get(b, PackedVector3Array()):
						if q.distance_to(lok) < 1e-6: ja = true; break
					if ja: drin[[m3, su, vi]] = true; fn += 1
					lage[gl][[m3, su, vi]] = "bei %.0f %% der Gliedlänge, %s" % [100.0 * anteil, "in der Probe" if ja else ("vor dem Viertel" if anteil <= 0.25 else "ausgedünnt")]
	return {"drin": drin, "lage": lage, "saeule_n": sn, "finger_n": fn, "r": r, "hm": hm}

func _holz(sch: Dictionary, q: Vector3, k: float):
	var sc := int(floor(q.y / Griff.SCHEIBE))
	if q.y < float(sch.lo) or q.y > float(sch.hi) or not Griff.frei(sch, sc): return null
	var v := Vector2(q.x, q.z) - (sch.mitte[sc] as Vector2)
	if v.length() * k > 0.06: return null
	var fl := Griff.oberflaeche(sch, sc, v)
	return 100.0 * (v.length() - (fl if fl > 0.0 else float(sch.profil[sc]))) * k

# griff.gd intern: starre Hautpunkte (Griff.netz_finger) an der Pose nach dem letzten Modifikator, Waffe in dieser Lage
func _intern(sk: Skeleton3D, ding: Node3D, halt: Dictionary, sch: Dictionary, R: Transform3D) -> Dictionary:
	var W := ding.global_transform * R
	var Wi := W.affine_inverse(); var k := W.basis.y.length(); var G := sk.global_transform
	var ne := Griff.netz_finger(sk, "r")
	var aus := {}
	for gl in GLIEDER:
		var bi := sk.find_bone(gl)
		if not ne.has(bi): continue
		var P := G * sk.get_bone_global_pose(bi)
		for p in ne[bi]:
			var d = _holz(sch, Wi * (P * p), k)
			if d != null: aus[gl] = minf(aus.get(gl, INF), d)
	return aus

# GANZ1694=1 (Gegenprobe nur im Test, kein Spielcode): griff.gd sieht die ganze Haut. Die Zwischenspeicher am Skelett werden ersetzt:
# griff_netz_r (Griff.netz_finger) mit allen Ecken je Fingerglied (ohne Viertel-Regel, ohne Ausdünnen), griff_r_<r> (Griff.hand_mass)
# mit der tiefsten Haut der Handfläche über die ganze Faustbreite (seitlich bis HAND_HALB statt 1,2 cm Säule); danach schließt die Hand neu
func _ganze_probe(sk: Skeleton3D, t) -> void:
	await process_frame
	var u := Griff.einheit(sk, "r")
	var ne := {}
	var finger := {}
	for fi in Griff.FINGER + ["thumb"]:
		for g in ["_01_", "_02_", "_03_"]:
			if sk.find_bone(fi + g + "r") >= 0: finger[sk.find_bone(fi + g + "r")] = true
	var ih := sk.find_bone("hand_r")
	var hand := []
	for mi in sk.find_children("*", "MeshInstance3D", true, false):
		var m3 := mi as MeshInstance3D
		if m3.mesh == null or m3.skin == null or not m3.visible: continue
		var bind := {}
		for k in m3.skin.get_bind_count():
			var nmn := m3.skin.get_bind_name(k)
			bind[k] = sk.find_bone(nmn) if nmn != "" else m3.skin.get_bind_bone(k)
		for su in m3.mesh.get_surface_count():
			var a := m3.mesh.surface_get_arrays(su)
			var pos = a[Mesh.ARRAY_VERTEX]; var kn = a[Mesh.ARRAY_BONES]; var gw = a[Mesh.ARRAY_WEIGHTS]
			if pos == null or kn == null or gw == null or pos.size() == 0: continue
			var je: int = kn.size() / pos.size()
			for vi in pos.size():
				var best := -1; var bw := 0.0
				for k in je:
					if gw[vi * je + k] > bw: bw = gw[vi * je + k]; best = int(kn[vi * je + k])
				var b: int = bind.get(best, -1)
				var lok: Vector3 = m3.skin.get_bind_pose(best) * pos[vi]
				if finger.has(b):
					if not ne.has(b): ne[b] = PackedVector3Array()
					ne[b].append(lok)
				elif b == ih: hand.append(sk.get_bone_global_rest(ih) * lok)
	sk.set_meta("griff_netz_r", ne)
	var f := Griff.flaeche(sk, "r", true)
	var mp: Vector3 = f[0]; var lang: Vector3 = f[1]; var fl: Vector3 = f[2]
	for m in sk.get_meta_list():
		if not String(m).begins_with("griff_r_"): continue
		var r := float(String(m).substr(8)) / 10000.0
		var hm: Vector2 = sk.get_meta(m)
		var basis := mp - lang * (r + hm.y)
		var tief := -INF
		for p in hand:
			var rel: Vector3 = p - basis
			var tt := rel.dot(fl)
			if tt > 0.0 and (rel - fl * tt).length() < Griff.HAND_HALB * u: tief = maxf(tief, tt)
		print("BILD1694 GANZ1694 %s: Haut der Handfläche %.2f → %.2f cm; Fingerglieder %d mit allen Ecken" % [m, hm.x * 100.0, tief * 100.0, ne.size()])
		if tief > 0.0: sk.set_meta(m, Vector2(tief, hm.y))
	if t != null: t.merk.clear(); t.merk2.clear()

# Bild nur in griff_folge_bild_1694.gd (Unterklasse; dieser Test legt kein Bild ab)
func _nimm_bild(): return null
func _bild_speichern(_z: Dictionary, _sk: Skeleton3D, _ding: Node3D) -> void: pass

func _mods(sk: Skeleton3D) -> Array:
	return sk.get_children().filter(func(x): return x is SkeletonModifier3D)

static func _v(v: Vector3, st := 1) -> String: return ("(%." + str(st) + "f,%." + str(st) + "f,%." + str(st) + "f)") % [v.x, v.y, v.z]
static func _z(x) -> String: return "FEHLT" if x == null else "%.2f" % float(x)
static func _sp(a: Array) -> String: return "FEHLT" if a.is_empty() else "%.2f…%.2f" % [a[0], a[-1]]
static func _spanne(a: float, b: float) -> String: return "FEHLT" if a == INF else "%.2f…%.2f (%.2f)" % [a, b, b - a]
