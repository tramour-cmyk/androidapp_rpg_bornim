# 948 (Chef 11.11., 13:33, Bild aus t276.12): Herumtreiber soll einen Dolch tragen (werte.json herkuenfte), im Kampf war nichts in
# der Hand. Messung ohne Bild: je Herkunft der Probeheld (Testmodus.probeheld, wie der MARS-Probekampf) im Wald gegen Wölfe; nach
# dem Einhängen trägt die rechte Hand die Waffe der Herkunft (BoneAttachment am Handgelenk), sonst Befund.
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/waffe_948.gd   (ohne Kaufmodelle: nichts zu prüfen; NUR=<Herkunft>)
# Exit 0 = kein Befund.
extends SceneTree

const AufrufS = preload("res://kampf/aufruf.gd")


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	if not HeldFigur.da("FIGHTER"):
		print("WAFFE948 ohne Kauf, nichts zu prüfen")
		quit(0)
		return
	var herkuenfte: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/werte.json"))["herkuenfte"]
	var befunde := 0
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
