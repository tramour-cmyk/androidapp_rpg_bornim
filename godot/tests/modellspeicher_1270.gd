# 1270.2: ModellSpeicher baut jedes Modell einmal je Spielstart und gibt danach Kopien. Geprüft: die Kopie gleicht dem neu gebauten
# Modell (Knoten, Knochen, Bewegungen, Schlüssel; auch ohne Kürzen der Spuren wie figur.gd _load_model), Netze sind geteilt,
# Bewegungen je Kopie eigen (Umbau einer Figur ändert keine andere und nicht die Vorlage). Mit Kaufmodellen (kampf/daten/kauf.txt,
# im Lauf der APK) dasselbe je Modell und die Zeit: erster Aufruf gegen jeden weiteren.
# Run: godot --headless --path godot -s res://tests/modellspeicher_1270.gd   (letzte Zeile „MODELL1270 0 Fehler“)
extends SceneTree

var fehler := 0


func _init() -> void:
	var pfade: Array[String] = ["res://tiere/wolf.glb", "res://tiere/ratte.glb", "res://tiere/wildschwein.glb"]
	var kauf := "res://kampf/daten/kauf.txt"
	if FileAccess.file_exists(kauf):
		for z in FileAccess.get_file_as_string(kauf).split("\n", false):
			pfade.append("res://" + z.strip_edges())
	var kalt := 0.0
	var warm := 0.0
	var n := 0
	for p in pfade:
		for kuerzen: bool in [false, true]:
			var t0 := Time.get_ticks_usec()
			var a := ModellSpeicher.kopie(p, kuerzen)
			var t1 := Time.get_ticks_usec()
			var b := ModellSpeicher.kopie(p, kuerzen)
			var t2 := Time.get_ticks_usec()
			if a == null or b == null:
				_f("%s nicht geladen" % p)
				continue
			kalt += (t1 - t0) / 1000.0
			warm += (t2 - t1) / 1000.0
			n += 1
			var neu := ModellSpeicher.lade_neu(p, kuerzen)
			_gleich(p, a, neu)
			_gleich(p, b, neu)
			_geteilt(p, a, b)
			_eigen(p, a, b, kuerzen)
			for x in [a, b, neu]:
				x.free()
	# figur.gd behält unveränderliche Spuren (Runde 15): der Wolf hat ohne Kürzen mehr Spuren als mit
	var lang := ModellSpeicher.kopie("res://tiere/wolf.glb", false)
	var kurz := ModellSpeicher.kopie("res://tiere/wolf.glb", true)
	if _spuren(lang) <= _spuren(kurz):
		_f("Wolf: ohne Kürzen %d Spuren, mit %d (Schlüssel vermischt?)" % [_spuren(lang), _spuren(kurz)])
	lang.free()
	kurz.free()
	var vorher := ModellSpeicher.gebaut
	ModellSpeicher.kopie("res://tiere/wolf.glb", false).free()
	if ModellSpeicher.gebaut != vorher:
		_f("Wolf zweimal gebaut")
	if ModellSpeicher.kopie("res://gibt/es/nicht.bin") != null:
		_f("fehlende Datei gibt ein Modell")
	ModellSpeicher.leeren()
	print("MODELL1270 Modelle %d, erster Aufruf zusammen %.0f ms, zweiter %.0f ms" % [n, kalt, warm])
	print("MODELL1270 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)


func _f(t: String) -> void:
	fehler += 1
	print("FEHLER ", t)


## gleicher Baum, gleiche Knochen, gleiche Bewegungen mit gleichen Schlüsseln
func _gleich(p: String, k: Node, neu: Node) -> void:
	var ka := _baum(k)
	var na := _baum(neu)
	if ka != na:
		_f("%s: Baum der Kopie anders (%d gegen %d Knoten)" % [p, ka.size(), na.size()])
	var ks := k.find_children("*", "Skeleton3D", true, false)
	var ns := neu.find_children("*", "Skeleton3D", true, false)
	for i in mini(ks.size(), ns.size()):
		var s1 := ks[i] as Skeleton3D
		var s2 := ns[i] as Skeleton3D
		if s1.get_bone_count() != s2.get_bone_count():
			_f("%s: Knochen %d gegen %d" % [p, s1.get_bone_count(), s2.get_bone_count()])
			continue
		for bi in s1.get_bone_count():
			if not s1.get_bone_rest(bi).is_equal_approx(s2.get_bone_rest(bi)) or s1.get_bone_parent(bi) != s2.get_bone_parent(bi):
				_f("%s: Knochen %s anders" % [p, s1.get_bone_name(bi)])
				break
	var kp := k.find_children("*", "AnimationPlayer", true, false)
	var np := neu.find_children("*", "AnimationPlayer", true, false)
	if kp.size() != np.size():
		_f("%s: %d gegen %d AnimationPlayer" % [p, kp.size(), np.size()])
		return
	for i in kp.size():
		var a1 := kp[i] as AnimationPlayer
		var a2 := np[i] as AnimationPlayer
		if a1.get_animation_list() != a2.get_animation_list():
			_f("%s: Bewegungen %s gegen %s" % [p, a1.get_animation_list(), a2.get_animation_list()])
			continue
		for an in a1.get_animation_list():
			var x := a1.get_animation(an)
			var y := a2.get_animation(an)
			if x.get_track_count() != y.get_track_count() or not is_equal_approx(x.length, y.length) or x.loop_mode != y.loop_mode:
				_f("%s %s: Spuren oder Länge anders" % [p, an])
				continue
			for t in x.get_track_count():
				if x.track_get_path(t) != y.track_get_path(t) or x.track_get_key_count(t) != y.track_get_key_count(t):
					_f("%s %s: Spur %d anders" % [p, an, t])
					break
				var kn := x.track_get_key_count(t) - 1
				if kn >= 0 and x.track_get_key_value(t, kn) != y.track_get_key_value(t, kn):
					_f("%s %s: letzter Schlüssel der Spur %d anders" % [p, an, t])
					break


func _baum(n: Node) -> Array:
	var r := [String(n.name) + ":" + n.get_class()]
	for c in n.get_children():
		r.append_array(_baum(c))
	return r


## Netze und Bilder geteilt (das spart), Knoten nicht
func _geteilt(p: String, a: Node, b: Node) -> void:
	var ma := a.find_children("*", "MeshInstance3D", true, false)
	var mb := b.find_children("*", "MeshInstance3D", true, false)
	if ma.is_empty():
		_f("%s: kein Netz" % p)
		return
	for i in mini(ma.size(), mb.size()):
		if ma[i] == mb[i]:
			_f("%s: Kopie teilt Knoten" % p)
			return
		if (ma[i] as MeshInstance3D).mesh != (mb[i] as MeshInstance3D).mesh:
			_f("%s: Netz %s nicht geteilt" % [p, ma[i].name])
			return


## Umbau der Bewegungen einer Kopie (wie figur.gd _ohne_atem) lässt die andere und jede neue Kopie, wie sie war
func _eigen(p: String, a: Node, b: Node, kuerzen: bool) -> void:
	var pa := a.find_children("*", "AnimationPlayer", true, false)
	if pa.is_empty():
		return
	var ap := pa[0] as AnimationPlayer
	var bp := b.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	var vorher := _spuren(b)
	for an in ap.get_animation_list():
		var x := ap.get_animation(an)
		if bp.get_animation(an) == x or ap.get_animation_library("") == bp.get_animation_library(""):
			_f("%s %s: Bewegung geteilt" % [p, an])
			return
		for t in x.get_track_count():
			while x.track_get_key_count(t) > 1:
				x.track_remove_key(t, x.track_get_key_count(t) - 1)
		x.loop_mode = Animation.LOOP_PINGPONG
	if _spuren(b) != vorher:
		_f("%s: Umbau der einen Kopie ändert die andere" % p)
	var c := ModellSpeicher.kopie(p, kuerzen)
	if _spuren(c) != vorher:
		_f("%s: Umbau einer Kopie ändert die Vorlage" % p)
	c.free()


## Zahl aller Schlüssel aller Bewegungen
func _spuren(n: Node) -> int:
	var s := 0
	for ap: AnimationPlayer in n.find_children("*", "AnimationPlayer", true, false):
		for an in ap.get_animation_list():
			var x := ap.get_animation(an)
			for t in x.get_track_count():
				s += x.track_get_key_count(t)
	return s
