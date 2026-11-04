extends SceneTree
# 513 (Chef 03.11., 15:51 „unten steht's weg“; Probe 3, Lauf 41764123036: Kaempfer-Rundschild unten 5,4 cm, Stab „11 cm neben der Faust“):
# ohne Bild, wie drehteller_499 (dieselbe Messart, Funktionen von dort), aber ueber die ganze Bewegung „Stehen“ im Drehteller: je Zeit
# der Spalt oben und unten zwischen Schildrand und Ruecken, Ecken im Koerper; der Stab quer zur Schaftlinie gemessen (der Schaft laeuft
# durch die Faust, sein Ursprung liegt am Fuss). Soll: Spalt zu jeder Zeit hoechstens SPALT_M, keine Ecke im Koerper, Faust hoechstens
# FAUST_M von der Schaftlinie. Braucht godot/daten wie im Bau (Kaufkoerper). Aufruf: -s res://tests/schild_513.gd -> „SCHILD513 n Fehler“
const KLASSEN := ["FIGHTER", "CLERIC", "ROGUE", "WIZARD"]
# 417a (Archiv 417, 03.11., 06:54 „417 passt“, Stand 3b29ac0cb): Waffe in der Hand, Schild auf dem Ruecken; Schwert mit dem Einhandgang
const GANG := {"FIGHTER": "einhand", "CLERIC": "", "ROGUE": "einhand", "WIZARD": ""}
const SCHILD := {"FIGHTER": true, "CLERIC": true, "ROGUE": false, "WIZARD": false}
const FAUST_M := 0.03
const RUECKEN_M := 0.06
const SPALT_M := 0.04   # 513: Schild oben und unten höchstens 4 cm vom Rücken (Chef 15:51 „unten steht's weg“)

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

# Abstand eines Punkts zur Oberfläche des Körpers: nächste Ecke der Figurennetze (ohne Waffen) nach der Haut
func koerper_abstand(m: Node3D, p: Vector3) -> float:
	var best := INF
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var x := mi as MeshInstance3D
		if x.skin == null: continue
		var sk := x.get_node_or_null(x.skeleton) as Skeleton3D
		if sk == null: continue
		for s in x.mesh.get_surface_count():
			var arr := x.mesh.surface_get_arrays(s)
			var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
			var bo = arr[Mesh.ARRAY_BONES]; var we = arr[Mesh.ARRAY_WEIGHTS]
			if bo == null or vs.is_empty(): continue
			var n := int(bo.size() / vs.size())
			for i in range(0, vs.size(), 3):
				var w := Vector3.ZERO
				for j in n:
					var g: float = we[i * n + j]
					if g <= 0.0: continue
					var bind: int = bo[i * n + j]
					var bone := x.skin.get_bind_bone(bind)
					if bone < 0: bone = sk.find_bone(x.skin.get_bind_name(bind))
					w += (sk.global_transform * sk.get_bone_global_pose(bone) * x.skin.get_bind_pose(bind) * vs[i]) * g
				best = minf(best, w.distance_to(p))
	return best

# 513: Spalt zwischen Schild und Rücken im Raum der Figur (Blick +Z, Rücken -Z), wie der Teller sie zeigt (echte Knochenlage): je Feld
# (3 cm breit, 2 cm hoch) die hinterste Ecke des Körpers; je Schildecke im obersten und untersten Viertel des Schilds der Abstand nach
# vorn bis zum Körper; [kleinster oben, kleinster unten, Ecken des Rands im Körper (mehr als 1 cm hinein)]
# ohne_glieder: Arme, Haende und Beine zaehlen nicht zum Ruecken (Spalt); sie schwingen im Gehen unter und neben dem Schild
# (Messung 04.11., 12:22: das unterste Viertel des Schilds liegt hinter den Oberschenkeln, im Schritt bis 20 cm vor ihm)
func schild_spalt(modell: Node3D, ba: Node3D, ohne_glieder := false) -> Array:
	var inv := modell.global_transform.affine_inverse()
	var feld := {}
	for mi in modell.find_children("*", "MeshInstance3D", true, false):
		var x := mi as MeshInstance3D
		if x.skin == null: continue
		var sk := x.get_node_or_null(x.skeleton) as Skeleton3D
		if sk == null: continue
		var mb := []
		var arm := []   # je Bindung: Knochen eines Glieds (ohne_glieder: zaehlt nicht zum Ruecken)
		for b in x.skin.get_bind_count():
			var bone := x.skin.get_bind_bone(b)
			if bone < 0: bone = sk.find_bone(x.skin.get_bind_name(b))
			mb.append(inv * sk.global_transform * sk.get_bone_global_pose(bone) * x.skin.get_bind_pose(b))
			arm.append(HeldFigur.ist_glied(sk.get_bone_name(bone)))
		for s in x.mesh.get_surface_count():
			var arr := x.mesh.surface_get_arrays(s)
			var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
			var bo = arr[Mesh.ARRAY_BONES]; var we = arr[Mesh.ARRAY_WEIGHTS]
			if bo == null or vs.is_empty(): continue
			var n := int(bo.size() / vs.size())
			for i in vs.size():
				var p := Vector3.ZERO
				var gw := 0.0; var armig := false
				for j in n:
					var g: float = we[i * n + j]
					if g > 0.0: p += (mb[bo[i * n + j]] * vs[i]) * g
					if g > gw: gw = g; armig = arm[bo[i * n + j]]
				if p.z > 0.05: continue
				if ohne_glieder and armig: continue
				var key := Vector2i(floori(p.x / 0.03), floori(p.y / 0.02))
				feld[key] = minf(feld.get(key, 9.0), p.z)
	var ecken := []
	var lo := INF; var hi := -INF
	for mi in ba.find_children("*", "MeshInstance3D", true, false):
		var x := mi as MeshInstance3D
		var t := inv * x.global_transform
		for s in x.mesh.get_surface_count():
			for v in x.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				var p: Vector3 = t * v
				ecken.append(p); lo = minf(lo, p.y); hi = maxf(hi, p.y)
	var oben := 9.0; var unten := 9.0; var drin := 0
	var zeile := {}   # wie heldfigur._schild_neigen: Seitenansicht je Zeile
	var h := hi - lo
	var xl := INF; var xh := -INF
	for p in ecken: xl = minf(xl, p.x); xh = maxf(xh, p.x)
	var mitte := Vector2((xl + xh) * 0.5, (lo + hi) * 0.5); var halb := Vector2(maxf(0.01, (xh - xl) * 0.5), maxf(0.01, h * 0.5))
	for p in ecken:
		if ((Vector2(p.x, p.y) - mitte) / halb).length() <= HeldFigur.SCHILD_RAND: continue   # Fessel hinter der Platte: unsichtbar
		var z: float = feld.get(Vector2i(floori(p.x / 0.03), floori(p.y / 0.02)), 9.0)
		if z > 8.0: continue
		var spalt: float = z - p.z
		if spalt < -0.01: drin += 1
	for p in ecken:
		if ((Vector2(p.x, p.y) - mitte) / halb).length() <= HeldFigur.SCHILD_RAND: continue
		var fy := floori(p.y / 0.02)
		var zl: Array = zeile.get(fy, [-9.0, p.y, floori(p.x / 0.03), floori(p.x / 0.03)])
		if p.z > float(zl[0]): zl[0] = p.z; zl[1] = p.y
		zl[2] = mini(zl[2], floori(p.x / 0.03)); zl[3] = maxi(zl[3], floori(p.x / 0.03))
		zeile[fy] = zl
	for fy in zeile:
		var zl: Array = zeile[fy]
		var koerper := 9.0
		for fx in range(int(zl[2]), int(zl[3]) + 1): koerper = minf(koerper, feld.get(Vector2i(fx, fy), 9.0))
		if koerper > 8.0: continue
		var spalt: float = koerper - float(zl[0])
		if float(zl[1]) > hi - h * 0.25: oben = minf(oben, spalt)
		elif float(zl[1]) < lo + h * 0.25: unten = minf(unten, spalt)
	return [oben, unten, drin]

const ZEITEN := 12

# 513 (Chef 04.11., 10:56, Bild Build 257: Magier in Robe in der Welt mit dem laenglichen Schild aus dem Testmenue, unten weit ab):
# jede Klasse auch mit jedem Schild aus dem Testmenue (testmodus.gd NEBENHAND), dazu ueber „Gehen“ wie unterwegs
const FAELLE := [["FIGHTER", ""], ["CLERIC", ""], ["ROGUE", ""], ["WIZARD", ""],
	["WIZARD", "shield"], ["WIZARD", "round_shield"], ["ROGUE", "shield"], ["FIGHTER", "round_shield"], ["CLERIC", "round_shield"]]
const BEWEGUNGEN := ["Stehen", "Gehen"]

func _lauf() -> void:
	Sprache.lade()
	for fall in FAELLE:
		var k: String = fall[0]
		var z := Zustand.new()
		var hw := Heldwerte.erschaffe("Thora", "HUMAN", k, {}, z.neue_uid)
		if fall[1] != "":
			if k == "WIZARD": Testmodus.waffe(hw, z, "longsword")   # wie im Bild des Chefs: Langschwert und Schild
			Testmodus.waffe(hw, z, fall[1], true)
		var name_: String = k + ("+" + String(fall[1]) if fall[1] != "" else "")
		var mit_schild: bool = SCHILD[k] or fall[1] != ""
		var w := HeldFigur.wahl(hw, z)
		var dt := Drehteller.new(w, 1.6)
		dt.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		root.add_child(dt)
		for i in 20: await process_frame
		var modell: Node3D = dt.teller.get_child(0) if dt.teller and dt.teller.get_child_count() > 0 else null
		if modell == null: fehler += 1; print("FEHLER %s: kein Held im Drehteller" % name_); dt.queue_free(); continue
		var sk := Gebiet.finde(modell, "Skeleton3D") as Skeleton3D
		var ap := Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
		var lage = modell.get_meta("schild_spalt", "-")
		print("%s: berechnet %s, Drehung %s" % [name_, str(lage), str(modell.get_meta("schild_gier", "-"))])
		for t in sk.get_children():
			if not (t is Tragen): continue
			var tr := t as Tragen
			if tr.waffe == null: continue
			var v: Vector3 = tr.faust_welt - tr.waffe.global_position
			var quer: float = (v - tr.schaft_welt * v.dot(tr.schaft_welt)).length() if tr.art == "stab" else v.length()
			print("  in der Hand (%s): %s %.3f m %s" % [tr.art, tr.waffe.name, quer, "quer zur Schaftlinie" if tr.art == "stab" else "von der Faust"])
			pruefe(quer <= FAUST_M, "%s: Waffe %.0f cm neben der Faust" % [name_, quer * 100])
		if mit_schild:
			var ba: Node3D = null
			for b in sk.find_children("RueckenSchild*", "", false, false): ba = b
			if ba == null or ap == null: fehler += 1; print("FEHLER %s: kein Schild auf dem Ruecken" % name_)
			else:
				for bew in BEWEGUNGEN:
					if not ap.has_animation(bew): fehler += 1; print("FEHLER %s: keine Bewegung %s" % [name_, bew]); continue
					ap.play(bew)
					var L := ap.get_animation(bew).length
					var hoch_o := -9.0; var hoch_u := -9.0; var drin := 0
					var rumpf_o := -9.0; var rumpf_u := -9.0
					var zeilen := []
					for i in ZEITEN:
						ap.seek(L * i / float(ZEITEN), true)
						for f in 2: await process_frame
						var sp := schild_spalt(modell, ba)
						var rumpf := schild_spalt(modell, ba, true)   # ohne Arme und Beine (Rumpf mit Kleidung, Umhang, Robe)
						sp.append(rumpf[0]); sp.append(rumpf[1])
						hoch_o = maxf(hoch_o, sp[0]); hoch_u = maxf(hoch_u, sp[1]); drin += int(sp[2])
						if sp[3] < 8.0: rumpf_o = maxf(rumpf_o, sp[3])
						if sp[4] < 8.0: rumpf_u = maxf(rumpf_u, sp[4])
						zeilen.append("%.2f s %.1f/%.1f/%d" % [L * i / float(ZEITEN), sp[0] * 100, sp[1] * 100, sp[2]])
					print("  %s ueber %s (oben/unten cm, Ecken drin): %s" % [name_, bew, ", ".join(PackedStringArray(zeilen))])
					print("  %s %s: hoechstens oben %.1f cm, unten %.1f cm, Ecken im Koerper %d; zum Rumpf oben %.1f, unten %s" % [name_, bew,
						hoch_o * 100, hoch_u * 100, drin, rumpf_o * 100, ("%.1f cm" % (rumpf_u * 100)) if rumpf_u > -8.0 else "kein Rumpf dahinter (Beine)"])
					# Soll im Stehen (Chef 03.11., 15:51 „Seitenansicht … unten steht's weg“): oben und unten anliegend, nirgends hinein. Im Gehen
					# nur gemeldet: das unterste Viertel liegt hinter den Oberschenkeln, die darunter schwingen (Vorgang beim Chef, 513)
					if bew == "Stehen":
						pruefe(hoch_o <= SPALT_M and hoch_u <= SPALT_M, "%s %s: Schild oben bis %.1f cm, unten bis %.1f cm vom Ruecken" % [name_, bew, hoch_o * 100, hoch_u * 100])
						pruefe(drin == 0, "%s %s: %d Ecken des Schilds im Koerper" % [name_, bew, drin])
		dt.queue_free()
		for i in 3: await process_frame
	print("SCHILD513 %d Fehler" % fehler)
	quit(1 if fehler else 0)
