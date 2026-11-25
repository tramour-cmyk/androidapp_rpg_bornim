# 2031 (Chef 25.11., 13:39: „MakeHuman nehmen und testen … Kutte/Robe als Alternative … Haut“): Pruefung ueber alle Faelle, ohne Bild.
# Kutte (HeldFigur.mh_probe novice_habit -> MH_KUTTE, tools/blender348/v3/kleid_mh.py) auf 5 Voelkern x Mann/Frau, Klosterschueler,
# in Ruhe (Stehen), Gehen und Hieb-Endbild (letztes Bild von „Hieb“ aus kampf-bewegungen.bin, uebertragen wie kampf/figur.gd _kaufheld):
#  durch: sichtbare Ecken (Kopf, Haende, Beinkleid …) unter dem Hals und ueber dem Knoechel, die vor der Lage liegen, die sie in der
#         Ruhelage deckt (Weg und Helfer wie durchstich_1631.gd, gezeichnete Netze der Endpose) = 0; Kopf unter der Kapuze zaehlt mit
#  kopf:  Ecken des Kopfnetzes vor der Kapuze (wie durch, ohne Hoehengrenze) = 0
#  Lagen der Kutte untereinander (Guertel, Strick, Kragen vor oder hinter dem Hauptstueck): nur genannt, kein Koerper
#  flanke: Stoff am Rumpf (Gewicht ueberwiegend Becken/Ruecken) seitlich weiter als halbe Schulterbreite + FLANKE_PLUS von der Mittellinie = 0
# Haeute (HeldFigur.mh_haut, tools/blender348/v3/haut_mh.py): 3 je Geschlecht x 5 Voelker (Wachsoldat): kein Texel ohne gebackenen Wert,
#  Bildmittel >= 0,15, Flecken < 5 % (wie zopf_431), Hautton am Gesicht nach toene hoechstens 10 % vom heutigen (Abweichung genannt);
#  ganzes Gesicht (Kinn bis Stirn, Pruefer 18:08 „roeter und dunkler“): Saettigung hoechstens 10 % ueber heute, Helligkeit 10 % ab,
#  dunkles Fuenftel hoechstens 15 % dunkler; Flecken (Pruefer 21:53): rote Punkte hoechstens 0,1, dunkle Stirnpunkte 3 Punkte ueber heute.
# Ausgabe: „KH2031 <Fall> …“, am Ende „KH2031 Faelle N, falsch F“ (Ende 1 bei F > 0). Ohne Kaufdateien „ohne Kauf“, 0.
# Run: godot --headless --path godot -s res://tests/kutte_haut_2031.gd [-- --nur=kutte|haut]
extends "res://tests/durchstich_1631.gd"

const VOELKER := ["HUMAN", "ELF", "DWARF", "HALFLING", "HALF_ORC"]
const HALS_UNTER := 0.10      # m unter dem Halsknochen (neck_01) zaehlt als „unter dem Hals“
const KNOECHEL_UEBER := 0.12  # m ueber dem Boden (Knoechel)
const FLANKE_PLUS := 0.10     # Stoffdicke und Falten seitlich ueber der halben Schulterbreite
const RUMPF := ["pelvis", "spine_01", "spine_02", "spine_03"]
const SATT_PLUS := 0.10   # Pruefer 18:08: Saettigung am ganzen Gesicht hoechstens 10 % ueber heute
const HELL_AB := 0.10     # Helligkeit (mittlere Farbe) am ganzen Gesicht hoechstens 10 % ab
const DUNKEL_AB := 0.15   # dunkles Fuenftel hoechstens 15 % dunkler
const ROT_PLUS := 0.001   # Pruefer 21:53: roter Fleck (Gruen/Rot unter 0,6 des Medians) hoechstens 0,1 Punkte mehr als heute
const STIRN_PLUS := 0.03  # Stirn: dunkle Punkte (unter 0,7 des Stirnmedians) hoechstens 3 Punkte mehr als heute

var faelle := 0
var falsch := 0

func _lauf() -> void:
	if not HauptmenueHelden.da():
		print("KH2031 ohne Kauf, 0 Fehler")
		quit(0)
		return
	var nur := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--nur="): nur = a.substr(6)
	if nur in ["", "kutte"]: await _kutten()
	if nur in ["", "haut"]: await _haeute()
	print("KH2031 Faelle %d, falsch %d" % [faelle, falsch])
	quit(1 if falsch else 0)

func _fall(name: String, ok: bool, text: String) -> void:
	faelle += 1
	if not ok: falsch += 1
	print("KH2031 %s %s: %s" % ["ok" if ok else "FALSCH", name, text])

# ---- Kutte ------------------------------------------------------------------------------------------------------------------------

static func hieb_dazu(m: Node3D) -> void:
	var ap := m.get_node_or_null("AnimationPlayer") as AnimationPlayer
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	if ap == null or sk == null or not FileAccess.file_exists("res://daten/kampf-bewegungen.bin"): return
	var sc := Gebiet.lade_glb("res://daten/kampf-bewegungen.bin")
	var ap0 := Gebiet.finde(sc, "AnimationPlayer") as AnimationPlayer
	if ap0 and ap0.has_animation("Hieb"):
		var an := ap0.get_animation("Hieb").duplicate(true) as Animation
		var f := sk.get_bone_rest(sk.find_bone("pelvis")).origin.length() / HeldFigur.bew_becken
		var pfad := str(HeldFigur._pfad(m, sk))
		for t in range(an.get_track_count() - 1, -1, -1):
			var bn := String(an.track_get_path(t)).get_slice(":", 1)
			an.track_set_path(t, NodePath("%s:%s" % [pfad, bn]))
			var ty := an.track_get_type(t)
			if ty == Animation.TYPE_SCALE_3D or (ty == Animation.TYPE_POSITION_3D and bn not in ["pelvis", "root"]) or sk.find_bone(bn) < 0:
				an.remove_track(t)
			elif ty == Animation.TYPE_POSITION_3D:
				for i in an.track_get_key_count(t): an.track_set_key_value(t, i, an.track_get_key_value(t, i) * f)
		an.loop_mode = Animation.LOOP_NONE
		ap.get_animation_library("").add_animation("Hieb", an)
	sc.free()

# Klosterschueler mit Startausruestung, Kutte ueber den Schalter
static func kutte_held(volk: String, g: String, mh: bool) -> Node3D:
	HeldFigur.mh_probe = {"novice_habit": "MH_KUTTE"} if mh else {}
	var hw := BrsHeld.fuer_spiel("Test", "Mensch", "Klosterschüler")
	var m := HeldFigur.baue({"herkunft": "Klosterschüler", "volk": volk, "aussehen": {"geschlecht": g}, "ausruestung": hw.ausruestung.duplicate()}, [])
	HeldFigur.mh_probe = {}
	if m: hieb_dazu(m)
	return m

func _kutten() -> void:
	for volk in VOELKER:
		for g in ["m", "w"]:
			var m := kutte_held(volk, g, true)
			if m == null:
				_fall("Kutte %s %s" % [volk, g], false, "Figur fehlt")
				continue
			root.add_child(m)
			await process_frame
			var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
			var ap := m.get_node_or_null("AnimationPlayer") as AnimationPlayer
			var ku := sk.find_child("Teil_MH_KUTTE", true, false) as MeshInstance3D
			if ku == null:
				_fall("Kutte %s %s" % [volk, g], false, "Teil_MH_KUTTE fehlt (Datei, Schalter)")
				m.queue_free()
				continue
			var netz := _sammle(sk)
			netz_lage = netz["lage"]
			var rest := []
			for i in sk.get_bone_count(): rest.append(sk.get_bone_global_rest(i))
			var lage0 := _haut(netz, rest)
			var V0: PackedVector3Array = lage0[0]; var N0: PackedVector3Array = lage0[1]
			var gitter0 := _gitter(V0, netz["tri"])
			var deckt := {}
			for i in V0.size():
				var h := _strahl(V0, netz, gitter0, V0[i] + N0[i] * 0.001, N0[i], WEIT, netz["lage"][i], false)
				if h[0] >= 0: deckt[i] = h[1]
			var hals := (sk.get_bone_global_rest(sk.find_bone("neck_01"))).origin.y - HALS_UNTER
			var schulter := absf(sk.get_bone_global_rest(sk.find_bone("upperarm_l")).origin.x - sk.get_bone_global_rest(sk.find_bone("upperarm_r")).origin.x) / 2.0
			sk.skeleton_updated.connect(_nach_update.bind(sk))
			var haltung: Node = null
			for c in sk.get_children():
				if c is HeldFigur.Haltung: haltung = c
			ap.speed_scale = 0.0
			for bew in [["Ruhe", "Stehen", 0.0], ["Gehen", "Gehen", 0.5], ["Hieb-Endbild", "Hieb", 0.999]]:
				var name := "Kutte %s %s %s" % [volk, g, bew[0]]
				if not ap.has_animation(bew[1]):
					_fall(name, false, "Bewegung %s fehlt" % bew[1])
					continue
				var an := ap.get_animation(bew[1])
				ap.play(bew[1], 0.0)
				ap.seek(an.length * float(bew[2]), true)
				if haltung:
					haltung.grund_w = -1.0; haltung.arm_w = -1.0; haltung.dame_w = -1.0
				_posen = []
				_warte = true
				await process_frame
				await process_frame
				var lage := _haut(netz, _posen)
				var V: PackedVector3Array = lage[0]; var N: PackedVector3Array = lage[1]
				var gitter := _gitter(V, netz["tri"])
				var rand := _rand_gitter(V, netz["rand"])
				var durch := 0; var kopf := 0; var lagen := 0; var wo := {}
				for i in deckt:
					var l: int = deckt[i]
					var h := _strahl(V, netz, gitter, V[i] - N[i] * 0.001, -N[i], DURCH_WEIT, l, true)
					if h[0] < 0 or h[2] < DURCH_MIN: continue
					if _nah_rand(rand, V, h[3], l): continue
					var ln := String(netz["lname"][netz["lage"][i]])
					if ln.begins_with("Teil_MH_KUTTE"):   # Lagen der Kutte untereinander (Guertel, Strick, Kragen): nur gezaehlt
						lagen += 1
						continue
					if ln.contains("Regular") or ln.contains("Head"): kopf += 1
					elif V0[i].y < hals and V0[i].y > KNOECHEL_UEBER: durch += 1
					else: continue
					var k := "%s>%s %.2f m" % [ln, netz["lname"][l], V[i].y]
					wo[k] = wo.get(k, 0) + 1
				var flanke := _flanke(ku, sk, schulter)
				var oben := wo.keys()
				oben.sort_custom(func(x, y): return wo[x] > wo[y])
				_fall(name, durch == 0 and kopf == 0 and flanke[0] == 0, "durch %d, Kopf vor Kapuze %d, Flanke %d (weiteste %.3f m, Grenze %.3f m); Lagen der Kutte %d  %s" % [
					durch, kopf, flanke[0], flanke[1], schulter + FLANKE_PLUS, lagen, ", ".join(oben.slice(0, 4).map(func(x): return "%s: %d" % [x, wo[x]]))])
			sk.skeleton_updated.disconnect(_nach_update)
			m.queue_free()
			await process_frame

# Stoff am Rumpf (Gewicht der Rumpfknochen >= 0,8) seitlich von der Linie Becken–Hals, im Raum des Beckens; [Anzahl, weiteste]
func _flanke(ku: MeshInstance3D, sk: Skeleton3D, schulter: float) -> Array:
	var a := ku.mesh.surface_get_arrays(0)
	var vs: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
	var bo: PackedInt32Array = a[Mesh.ARRAY_BONES]; var we: PackedFloat32Array = a[Mesh.ARRAY_WEIGHTS]
	var n := bo.size() / vs.size()
	var M := []
	var rumpf := []
	for k in ku.skin.get_bind_count():
		var bi := sk.find_bone(ku.skin.get_bind_name(k))
		M.append(_posen[bi] * ku.skin.get_bind_pose(k))
		rumpf.append(String(ku.skin.get_bind_name(k)) in RUMPF)
	var pb: Transform3D = _posen[sk.find_bone("pelvis")]
	var hals: Vector3 = (_posen[sk.find_bone("neck_01")] as Transform3D).origin
	var achse := (hals - pb.origin).normalized()
	var anz := 0; var weit := 0.0
	for i in vs.size():
		var p := Vector3.ZERO; var wr := 0.0
		for k in n:
			var w := we[i * n + k]
			if w <= 0.0: continue
			p += (M[bo[i * n + k]] as Transform3D) * vs[i] * w
			if rumpf[bo[i * n + k]]: wr += w
		if wr < 0.8: continue
		var d := p - pb.origin
		var u := d.dot(achse)
		if u < 0.0 or u > (hals - pb.origin).length(): continue
		# nur seitlich: Abstand quer zur Blickrichtung des Beckens
		var quer := absf(d.dot(pb.basis.x.normalized()))
		weit = maxf(weit, quer)
		if quer > schulter + FLANKE_PLUS: anz += 1
	return [anz, weit]

# ---- Haeute -----------------------------------------------------------------------------------------------------------------------

func _haeute() -> void:
	for g in ["m", "w"]:
		for kenn in HeldFigur.MH_HAUT_WAHL[g.to_upper()]:
			for volk in VOELKER:
				var alt := _haut_werte(volk, g, "")
				var neu := _haut_werte(volk, g, String(kenn))
				var name := "Haut %s %s %s" % [kenn, volk, g]
				if neu.has("fehler"):
					_fall(name, false, String(neu["fehler"]))
					continue
				var ab := 0.0
				for k in 3: ab = maxf(ab, absf(neu["ton"][k] - alt["ton"][k]) / maxf(alt["ton"][k], 0.001))
				# Pruefer 18:08: ganzes Gesicht nicht roeter (Saettigung) und nicht dunkler (Median, dunkles Fuenftel) als heute
				var sa: float = neu["satt"] / maxf(alt["satt"], 0.001) - 1.0
				var he: float = neu["hell"] / maxf(alt["hell"], 0.001) - 1.0
				var du: float = neu["dunkel"] / maxf(alt["dunkel"], 0.001) - 1.0
				var ok: bool = neu["leer"] == 0 and neu["mittel"] >= 0.15 and neu["flecken"] < 0.05 and ab <= 0.10 \
					and sa <= SATT_PLUS and absf(he) <= HELL_AB and du >= -DUNKEL_AB \
					and neu["rot"] <= alt["rot"] + ROT_PLUS and neu["fleck"] <= alt["fleck"] + STIRN_PLUS
				print("KH2031 FLECK %s rot %.2f %% gegen %.2f %%, Stirn dunkel %.2f %% gegen %.2f %%" % [name, neu["rot"] * 100, alt["rot"] * 100, neu["fleck"] * 100, alt["fleck"] * 100])
				_fall(name, ok, "ohne Wert %d von %d Proben, Bildmittel %.3f, Flecken %.1f %%, Hautton Gesicht %s gegen heute %s (Abweichung %.1f %%); ganzes Gesicht: Saettigung %.3f gegen %.3f (%+.0f %%), Helligkeit %.3f gegen %.3f (%+.0f %%), dunkles Fuenftel %.3f gegen %.3f (%+.0f %%)" % [
					neu["leer"], neu["proben"], neu["mittel"], neu["flecken"] * 100.0, _v(neu["ton"]), _v(alt["ton"]), ab * 100.0,
					neu["satt"], alt["satt"], sa * 100.0, neu["hell"], alt["hell"], he * 100.0, neu["dunkel"], alt["dunkel"], du * 100.0])

func _v(c: Array) -> String: return "%.3f/%.3f/%.3f" % [c[0], c[1], c[2]]

# Wachsoldat des Volkes; je Hautflaeche (Material „Regular“/„Superhero“) das Bild im Spiel-Shader an den Dreiecksmitten (und an den
# Ecken, 10 % zur Mitte): magenta = ohne gebackenen Wert; Bildmittel (Helligkeit sRGB), Flecken wie zopf_431 (Mitte unter 0,4 oder ueber
# 1,6 des Mittels); Hautton am Gesicht (Median an den Ecken des Kopfnetzes im Band unter den Augen, vorn; Bereich wie held_klassen.py haut_bild) nach der Formel des Shaders (toon.gdshader toen_hell)
func _haut_werte(volk: String, g: String, kenn: String) -> Dictionary:
	HeldFigur.mh_haut = kenn
	var hw := BrsHeld.fuer_spiel("Test", "Mensch", "Wachsoldat")
	var m := HeldFigur.baue({"herkunft": "Wachsoldat", "volk": volk, "aussehen": {"geschlecht": g}, "ausruestung": hw.ausruestung.duplicate()}, [])
	HeldFigur.mh_haut = ""
	if m == null: return {"fehler": "Figur fehlt"}
	var leer := 0; var proben := 0; var hell := []; var ton := [[], [], []]; var satt := []; var glanz := []; var stirn := []
	var augen := Vector3.INF
	for x in m.find_children("Eyes*", "MeshInstance3D", true, false):
		augen = (x as MeshInstance3D).mesh.get_aabb().get_center()
	var bilder := {}
	for x in m.find_children("*", "MeshInstance3D", true, false):
		var mi := x as MeshInstance3D
		if mi.mesh == null: continue
		for si in mi.mesh.get_surface_count():
			var src := mi.mesh.surface_get_material(si)
			var rn := String(src.resource_name) if src else ""
			if not (rn.contains("Regular") or rn.contains("Superhero")): continue
			var sm := mi.get_surface_override_material(si) as ShaderMaterial
			if sm == null: continue
			var tex := sm.get_shader_parameter("tex") as Texture2D
			if kenn != "" and HeldFigur.mh_haut_bild_von(kenn, rn).is_empty(): return {"fehler": "%s: kein gebackenes Bild" % rn}
			if tex == null: return {"fehler": "%s ohne Bild" % rn}
			if not bilder.has(tex):
				var im := tex.get_image()
				if im.is_compressed(): im.decompress()
				bilder[tex] = im
			var im: Image = bilder[tex]
			var a := mi.mesh.surface_get_arrays(si)
			var uv: PackedVector2Array = a[Mesh.ARRAY_TEX_UV]
			var vs: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
			var idx: PackedInt32Array = a[Mesh.ARRAY_INDEX] if a[Mesh.ARRAY_INDEX] != null else PackedInt32Array(range(vs.size()))
			var kopf := String(mi.name).contains("Regular") or String(mi.name).contains("Head")
			var t: Vector3 = sm.get_shader_parameter("toenung"); var th: float = sm.get_shader_parameter("toen_hell")
			var tb: Vector3 = sm.get_shader_parameter("toen_bild"); var tf: float = sm.get_shader_parameter("toen_farbe")
			for k in range(0, idx.size(), 3):
				var u0 := uv[idx[k]]; var u1 := uv[idx[k + 1]]; var u2 := uv[idx[k + 2]]
				var mu := (u0 + u1 + u2) / 3.0
				for q in [mu, u0.lerp(mu, 0.1), u1.lerp(mu, 0.1), u2.lerp(mu, 0.1)]:
					var c := im.get_pixel(clampi(int(q.x * im.get_width()), 0, im.get_width() - 1), clampi(int(q.y * im.get_height()), 0, im.get_height() - 1))
					proben += 1
					if c.r > 0.9 and c.g < 0.1 and c.b > 0.9: leer += 1
				var c0 := im.get_pixel(clampi(int(mu.x * im.get_width()), 0, im.get_width() - 1), clampi(int(mu.y * im.get_height()), 0, im.get_height() - 1))
				hell.append(0.2126 * c0.r + 0.7152 * c0.g + 0.0722 * c0.b)
			# Hautton am Gesicht wie held_klassen.py haut_bild: Ecken des Kopfnetzes im Band unter den Augen (9 cm), vordere Haelfte
			if kopf and th > 0.0 and augen != Vector3.INF:
				var mz := 0.0
				for v in vs: mz += v.z
				mz /= vs.size()
				var vorn := signf(augen.z - mz)
				for i in vs.size():
					if vs[i].y > augen.y or vs[i].y < augen.y - 0.09 or (vs[i].z - mz) * vorn < 0.0: continue
					var c1 := im.get_pixel(clampi(int(uv[i].x * im.get_width()), 0, im.get_width() - 1), clampi(int(uv[i].y * im.get_height()), 0, im.get_height() - 1))
					var l := c1.srgb_to_linear()
					var o := _shader_ton(Vector3(l.r, l.g, l.b), t, th, tb, tf)
					for q in 3: ton[q].append(o[q])
				# Pruefer 18:08 (neue Gesichter roeter und dunkler bei gleichem Median an den Ecken): ganzes Gesicht (Kinn bis Stirn, vordere
				# Haelfte), dicht im Bild je Dreieck (6 x 6 Punkte; die Fotohaut hat Poren und Bartschatten zwischen den Ecken), Farbe nach der
				# Formel des Shaders; Saettigung und Helligkeit der mittleren Farbe, dazu das dunkle Fuenftel
				for k in range(0, idx.size(), 3):
					var drin := true
					for j in 3:
						var v := vs[idx[k + j]]
						if v.y > augen.y + 0.10 or v.y < augen.y - 0.17 or (v.z - mz) * vorn < 0.0: drin = false
					if not drin: continue
					for a_ in 6:
						for b_ in 6 - a_:
							var w0 := (a_ + 1.0 / 3.0) / 6.0; var w1 := (b_ + 1.0 / 3.0) / 6.0
							var q2 := uv[idx[k]] * (1.0 - w0 - w1) + uv[idx[k + 1]] * w0 + uv[idx[k + 2]] * w1
							var c2 := im.get_pixel(clampi(int(q2.x * im.get_width()), 0, im.get_width() - 1), clampi(int(q2.y * im.get_height()), 0, im.get_height() - 1)).srgb_to_linear()
							var o2 := _shader_ton(Vector3(c2.r, c2.g, c2.b), t, th, tb, tf)
							satt.append(o2)
							if (vs[idx[k]].y + vs[idx[k + 1]].y + vs[idx[k + 2]].y) / 3.0 > augen.y + 0.03: stirn.append(0.2126 * o2.x + 0.7152 * o2.y + 0.0722 * o2.z)
							glanz.append(0.2126 * o2.x + 0.7152 * o2.y + 0.0722 * o2.z)
	m.free()
	if hell.is_empty() or (ton[0] as Array).is_empty(): return {"fehler": "keine Haut oder kein Gesicht gefunden"}
	for q in 3: (ton[q] as Array).sort()
	var mittel := 0.0
	for h in hell: mittel += h
	mittel /= hell.size()
	var fl := 0
	for h in hell: if h < 0.4 * mittel or h > 1.6 * mittel: fl += 1
	var mf := Vector3.ZERO
	var sl := []
	for o3 in satt:
		mf += o3
		var m3 := maxf(o3.x, maxf(o3.y, o3.z))
		sl.append((m3 - minf(o3.x, minf(o3.y, o3.z))) / maxf(m3, 0.001))
	mf /= maxf(satt.size(), 1)
	var mx := maxf(mf.x, maxf(mf.y, mf.z))
	glanz.sort(); sl.sort()
	var gm: float = glanz[glanz.size() / 2]
	# Pruefer 21:53 (Lauf 860a1dced): roter Fleck unter Lippe und Kinn (Frau), Stirn fleckig dunkler (Mann): Anteil der Punkte, die
	# deutlich roeter (Gruen/Rot unter 0,6 des Medians) oder deutlich dunkler (unter 0,6 der mittleren Helligkeit) sind
	var gr := []
	for o3 in satt: gr.append(o3.y / maxf(o3.x, 0.0001))
	gr.sort()
	var grm: float = gr[gr.size() / 2]
	var rot := 0; var dun := 0
	for o3 in satt:
		if o3.y / maxf(o3.x, 0.0001) < 0.6 * grm: rot += 1
	stirn.sort()
	var sm_: float = stirn[stirn.size() / 2] if not stirn.is_empty() else 1.0
	for h_ in stirn:
		if h_ < 0.7 * sm_: dun += 1
	return {"leer": leer, "proben": proben, "mittel": mittel, "flecken": float(fl) / hell.size(), "ton": [ton[0][ton[0].size() / 2], ton[1][ton[1].size() / 2], ton[2][ton[2].size() / 2]],
		"satt": (mx - minf(mf.x, minf(mf.y, mf.z))) / maxf(mx, 0.001), "hell": 0.2126 * mf.x + 0.7152 * mf.y + 0.0722 * mf.z, "dunkel": glanz[glanz.size() / 5],
		"rot": float(rot) / satt.size(), "fleck": float(dun) / maxf(stirn.size(), 1)}

# Farbe nach toon.gdshader (toen_hell > 0) samt Maske „haut“ (431c B1: weit vom Bezug bleibt das Bild ungetoent), linear
static func _shader_ton(l: Vector3, t: Vector3, th: float, tb: Vector3, tf: float) -> Vector3:
	var hl := maxf(0.2126 * l.x + 0.7152 * l.y + 0.0722 * l.z, 0.001)
	var rel := l / hl / Vector3(maxf(tb.x / th, 0.001), maxf(tb.y / th, 0.001), maxf(tb.z / th, 0.001))
	var haut := 1.0 - smoothstep(0.6, 1.0, (rel - Vector3.ONE).length()) if tf > 0.0 else 1.0
	return l.lerp(t * hl / th * Vector3.ONE.lerp(rel, tf), haut)
