extends SceneTree
# 1694 (Auftrag 24.11., 19:47; Chef 19:39 „1694 A“): Zeitfolge statt Median. Zieht das gezeichnete Netz der Knochenpose um ein Bild nach,
# springt die Waffe, oder keins von beiden? Je Aufruf von skeleton_updated über BILDER Prozessbilder eine Zeile, ohne Median:
#   Prozess- und Physikbildnummer, Zahl der Aufrufe im selben Bild, Reihenfolge der Modifikatoren (modification_processed),
#   Beugung je Glied (16 Glieder wie griff_weg_1694), Waffe (Griffpunkt cm, Achse) in Handkoordinaten,
#   je eine feste Netzecke an Zeigefinger-Grundglied, Kleinfinger-Grundglied, Handfläche: gebackene Lage (bake) gegen starre Rechnung
#   aus Bindung und Knochenpose dieses Aufrufs (j) und des letzten Aufrufs im vorigen Bild (v), Abstand cm,
#   dazu die gezeichnete Haut am Griff (NetzMess.griff) an Zeigefinger- und Kleinfinger-Grundglied und Handfläche.
# Fehlender Wert: FEHLT.
#   MESS=1694 xvfb-run -a godot --path . --resolution 540x1170 -s res://tests/griff_folge_1694.gd
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
		ap = Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		print("FOLGE1694 Prüfaufbau: Körper %s, Gegenstand %s, Griffart %s, AnimationPlayer %s" % [m.name, id, GriffHand.art_von(id), ap != null])
		if bew != "":
			if ap == null or not ap.has_animation(bew):
				print("FOLGE1694 Prüfaufbau: Bewegung %s FEHLT" % bew); quit(2); return
			ap.play(bew, 0.0)
	print("FOLGE1694 Fall weg=%s fall=%s bew=%s; Skeleton3D modifier_callback_mode_process=%d; Modifikatoren: %s" % [weg, fall,
		bew if bew != "" else "Stehen", sk.modifier_callback_mode_process, ", ".join(_mods(sk).map(func(x): return "%s(%s)" % [x.name, x.get_class()]))])
	for f in 80: await process_frame
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

func _mods(sk: Skeleton3D) -> Array:
	return sk.get_children().filter(func(x): return x is SkeletonModifier3D)

static func _v(v: Vector3, st := 1) -> String: return ("(%." + str(st) + "f,%." + str(st) + "f,%." + str(st) + "f)") % [v.x, v.y, v.z]
static func _z(x) -> String: return "FEHLT" if x == null else "%.2f" % float(x)
static func _spanne(a: float, b: float) -> String: return "FEHLT" if a == INF else "%.2f…%.2f (%.2f)" % [a, b, b - a]
