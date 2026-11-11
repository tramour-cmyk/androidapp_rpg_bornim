# 948 (Chef 11.11., 13:33, Bild aus t276.12): Herumtreiber soll einen Dolch tragen (werte.json herkuenfte), im Kampf war nichts in
# der Hand. Messung ohne Bild: je Herkunft der Probeheld (Testmodus.probeheld, wie der MARS-Probekampf) im Wald gegen Wölfe; nach
# dem Einhängen trägt die rechte Hand die Waffe der Herkunft (BoneAttachment am Handgelenk), sonst Befund.
# 948 B für alle Klingen (Chef 11.11., 15:03: „Das gilt für alles, wie du es empfohlen hattest.“): zuerst misst der Test jede Klinge
# aus waffen.py im gebauten Modell (daten/waffen, kampf/daten): an der Wurzel nicht unter 3 cm, 1 cm dick (Maße wie in waffen.py
# von der Mitte zur Schneide bzw. zur Fläche; die Wurzel ist der unterste Rautenquerschnitt der Klinge), ohne Kaufmodelle.
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/waffe_948.gd   (Hand nur mit Kaufmodellen; NUR=<Herkunft>)
# Exit 0 = kein Befund.
extends SceneTree

const AufrufS = preload("res://kampf/aufruf.gd")


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	var befunde := klingen()
	if not HeldFigur.da("FIGHTER"):
		print("WAFFE948 %d (ohne Kauf: Hand nicht geprüft)" % befunde)
		quit(1 if befunde > 0 else 0)
		return
	var herkuenfte: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/werte.json"))["herkuenfte"]
	for hk in herkuenfte:
		if String(hk).begins_with("_"):     # _quelle
			continue
		if OS.get_environment("NUR") != "" and String(hk) != OS.get_environment("NUR"):
			continue
		var held := Testmodus.probeheld(String(hk), 1)
		var p = AufrufS.new()
		root.add_child(p)
		await process_frame
		if not p.starte("WOLVES", held, null, "wald", "tag", 2, -1, -1, 3):
			print("  %s: kein Kampf" % hk)
			befunde += 1
			p.queue_free()
			continue
		var w := 0
		while (p.kampf == null or not p.kampf.is_inside_tree()) and w < 60:
			await process_frame
			w += 1
		for i in 45:
			await process_frame
		var kf = p.kampf
		var fig = kf.figures.get("hero")
		var main: String = String(fig.fighter.hero.main.id) if fig != null and fig.fighter.hero.has("main") else ""
		var fern: bool = fig != null and fig.fighter.hero.has("main") and bool(fig.fighter.hero.main.ranged)
		var rechts := []
		if fig != null:
			for at in fig.find_children("*", "BoneAttachment3D", true, false):
				var b: String = String(at.bone_name)
				if b.ends_with("R") or b.ends_with("_r"):
					rechts.append(b)
		var gut: bool = main == "" or fern or not rechts.is_empty()
		if not gut:
			befunde += 1
		# Einzelbild nur zur Ursache (PROBEBILD=948 BILD=<png>, mit Grafik): Held und Hand im Kampfort
		if OS.get_environment("BILD") != "":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OS.get_environment("BILD"))
		print("  %-16s Waffe %-14s %s rechte Hand: %s%s" % [hk, main if main != "" else "–", "(Fernwaffe)" if fern else "", str(rechts), "" if gut else "  FEHLT"])
		p.queue_free()
		for i in 5:
			await process_frame
	print("WAFFE948 %d" % befunde)
	quit(1 if befunde > 0 else 0)


# jede Klinge aus waffen.py (KINDS mit blade()); fehlt ein Modell, obwohl Waffen gebaut sind, ist das ein Befund
const KLINGEN := ["dagger", "shortsword", "longsword", "scimitar", "dagger-rost", "dagger-kobold", "scimitar-rost", "spear-rost"]
const WURZEL := 0.030
const DICKE := 0.010


func klingen() -> int:
	var befunde := 0
	var gebaut := false
	for d in ["res://daten/waffen", "res://kampf/daten"]:
		gebaut = gebaut or FileAccess.file_exists(d + "/dagger.bin")
	if not gebaut:
		print("  Klingen: keine Modelle gebaut, nichts zu messen")
		return 0
	for k in KLINGEN:
		var gefunden := false
		for d in ["res://daten/waffen", "res://kampf/daten"]:
			var p: String = "%s/%s.bin" % [d, k]
			if not FileAccess.file_exists(p):
				continue
			gefunden = true
			var m := wurzel(p)
			var gut: bool = m.x >= WURZEL - 0.0001 and m.y >= DICKE - 0.0001
			if not gut:
				befunde += 1
			print("  Klinge %-14s %-18s Wurzel %.2f cm, dick %.2f cm%s" % [k, d.trim_prefix("res://"), m.x * 100.0, m.y * 100.0,
					"" if gut else "  ZU SCHMAL (3,0 und 1,0)"])
		if not gefunden and k in ["dagger", "shortsword", "longsword", "scimitar"]:
			print("  Klinge %-14s FEHLT" % k)
			befunde += 1
	return befunde


# Wurzel der Klinge im Modell (glTF: Klinge nach +Y, Schneide ±X, Fläche ±Z): je Höhe die Punkte; ein Rautenquerschnitt hat zwei
# Punkte auf der Schneide (z = 0) und zwei auf dem Rücken (x = Mitte), alle übrigen Punkte der Höhe liegen außerhalb in x
# (Parierstange); Ringe von Griff und Schaft haben Punkte dazwischen. Der unterste solche Querschnitt ist die Wurzel.
func wurzel(p: String) -> Vector2:
	var n := Gebiet.lade_glb(p)
	var hoehen := {}
	for mi in n.find_children("*", "MeshInstance3D", true, false):
		var mesh: Mesh = (mi as MeshInstance3D).mesh
		for s in mesh.get_surface_count():
			for v in mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				var w: Vector3 = (mi as MeshInstance3D).transform * v
				var h := int(round(w.y * 10000.0))
				if not hoehen.has(h):
					hoehen[h] = {}
				hoehen[h][Vector2i(int(round(w.x * 100000.0)), int(round(w.z * 100000.0)))] = Vector2(w.x, w.z)
	n.free()
	var ys := hoehen.keys()
	ys.sort()
	for h in ys:
		var pts: Array = hoehen[h].values()
		var kante := pts.filter(func(q): return absf(q.y) < 0.0001)
		if kante.size() != 2:
			continue
		var cx: float = (kante[0].x + kante[1].x) / 2.0
		var halb: float = absf(kante[0].x - kante[1].x) / 2.0
		var ruecken := pts.filter(func(q): return absf(q.x - cx) < 0.0001 and absf(q.y) >= 0.0001)
		var sonst := pts.filter(func(q): return absf(q.y) >= 0.0001 and absf(q.x - cx) >= 0.0001)
		if ruecken.size() != 2 or sonst.any(func(q): return absf(q.x - cx) <= halb):
			continue
		return Vector2(halb, absf(ruecken[0].y - ruecken[1].y) / 2.0)
	return Vector2.ZERO
