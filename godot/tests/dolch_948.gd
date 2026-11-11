# 948 (Fund t276.12, Chef-Bild 11.11., 13:33): „Herumtreiber soll Dolch tragen … im Kampf nichts in der Hand zu sehen“. Messung
# ohne Bild, der Weg wie im Spiel (Testmodus „Starten als“: spiel.gd kampf_im_wald, Testmodus.probeheld, Aufruf.starte): je
# Herkunft der Kaufheld und der Söldner, was in der rechten Hand hängt, wo es im Faustloch sitzt, wie groß es am Schirm ist und
# wie viel davon die Kamera sieht (Punkte entlang der Waffe: vor dem Rumpf oder außerhalb seines Umrisses am Schirm).
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/dolch_948.gd   (HERKUNFT=Herumtreiber,Wanderer …)
# Exit 0 = kein Befund.
extends SceneTree

const Aufruf = preload("res://kampf/aufruf.gd")
const HERKUENFTE := ["Herumtreiber", "Kräutersammler", "Wanderer", "Wachsoldat", "Zauberlehrling"]
const SICHTBAR_MIN := 0.5      # so viel der Waffe muss die Kamera sehen
const PIXEL_MIN := 40.0        # so lang muss sie am Schirm sein (1080 x 2340)

var befunde := 0


func _initialize() -> void:
	_lauf.call_deferred()


func _befund(ok: bool, was: String) -> void:
	print(("ok     " if ok else "FEHLER ") + was)
	if not ok:
		befunde += 1


func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	if not FileAccess.file_exists("res://daten/kampf-bewegungen.bin"):
		print("DOLCH948 ohne Kauf, nichts zu prüfen")
		quit(0)
		return
	var liste: Array = OS.get_environment("HERKUNFT").split(",", false) if OS.get_environment("HERKUNFT") != "" else HERKUENFTE
	for k in liste:
		var a = Aufruf.new()
		root.add_child(a)
		await process_frame
		if not a.starte("WOLVES", Testmodus.probeheld(k, 3), Testmodus.probeheld(k, 3), "wald", "tag", 2, -1, -1, 1):
			_befund(false, "%s: kein Kampf" % k)
			continue
		for i in 20:
			await process_frame
		var kf = a.kampf
		for id in ["hero", "merc"]:
			var fig = kf.figures.get(id)
			if fig == null:
				_befund(false, "%s %s: keine Figur" % [k, id])
				continue
			await _miss(k, id, fig, kf.cam)
		kf.queue_free()
		a.queue_free()
		await process_frame
	print("DOLCH948 %d Befunde" % befunde)
	quit(1 if befunde > 0 else 0)


func _miss(k: String, id: String, fig, cam: Camera3D) -> void:
	var main: String = String(fig.fighter.hero.main.id) if fig.fighter.hero.has("main") else ""
	var w := fig.model.find_child("Waffe", true, false) as Node3D
	print("%s %s: kauf=%s Tracht=%s Hauptwaffe=%s Knoten=%s" % [k, id, fig.kauf, fig._tracht(), main, "da" if w else "fehlt"])
	if main == "" or bool(fig.fighter.hero.main.ranged):
		return
	_befund(w != null, "%s %s: %s in der Hand" % [k, id, main])
	if w == null:
		return
	var sk := fig._find(fig.model, "Skeleton3D") as Skeleton3D
	var punkte := _laengs(w)
	var schirm := []
	for p in punkte:
		schirm.append(cam.unproject_position(p))
	var lang := (schirm[0] as Vector2).distance_to(schirm[schirm.size() - 1])
	# Rumpf am Schirm: zwischen den Schultern, vom Kopf bis zu den Füßen; dahinter heißt weiter von der Kamera als die Wirbelsäule
	var g := func(n: String) -> Vector3: return sk.global_transform * sk.get_bone_global_pose(sk.find_bone(n)).origin
	var sl: Vector2 = cam.unproject_position(g.call("upperarm_l"))
	var sr: Vector2 = cam.unproject_position(g.call("upperarm_r"))
	var kopf: Vector2 = cam.unproject_position(g.call("head"))
	var fuss: Vector2 = cam.unproject_position(g.call("foot_l"))
	var x0 := minf(sl.x, sr.x) - 6.0
	var x1 := maxf(sl.x, sr.x) + 6.0
	var y0 := minf(kopf.y, fuss.y)
	var y1 := maxf(kopf.y, fuss.y)
	var rumpf: float = cam.global_position.distance_to(g.call("spine_03"))
	var frei := 0
	for i in punkte.size():
		var s: Vector2 = schirm[i]
		var aussen := s.x < x0 or s.x > x1 or s.y < y0 or s.y > y1
		var vorn: bool = cam.global_position.distance_to(punkte[i]) < rumpf - 0.05
		if aussen or vorn:
			frei += 1
	var anteil := float(frei) / punkte.size()
	var hand: Vector3 = g.call("hand_r")
	var seite := "vorn" if cam.global_position.distance_to(hand) < rumpf else "hinter dem Rumpf"
	print("  %s %s: am Schirm %.0f px lang, sichtbar %.0f %%, Hand %s (%.2f m näher als die Wirbelsäule)" % [k, id, lang, anteil * 100.0,
		seite, rumpf - cam.global_position.distance_to(hand)])
	_befund(lang >= PIXEL_MIN, "%s %s: %s am Schirm mindestens %.0f px (%.0f)" % [k, id, main, PIXEL_MIN, lang])
	_befund(anteil >= SICHTBAR_MIN, "%s %s: %s zu mindestens %.0f %% sichtbar (%.0f %%)" % [k, id, main, SICHTBAR_MIN * 100.0, anteil * 100.0])


## zwölf Punkte entlang der längsten Achse der Waffe (Welt), vom Griff zur Spitze
func _laengs(w: Node3D) -> Array:
	var bb := AABB()
	var erst := true
	var inv := w.global_transform.affine_inverse()
	for m in w.find_children("*", "MeshInstance3D", true, false):
		var mb: AABB = (m as MeshInstance3D).get_aabb()
		for i in 8:
			var q: Vector3 = inv * ((m as MeshInstance3D).global_transform * mb.get_endpoint(i))
			if erst:
				bb = AABB(q, Vector3.ZERO); erst = false
			else:
				bb = bb.expand(q)
	var ax := bb.get_longest_axis_index()
	var out := []
	for i in 12:
		var p := bb.get_center()
		p[ax] = bb.position[ax] + bb.size[ax] * float(i) / 11.0
		out.append(w.global_transform * p)
	return out
