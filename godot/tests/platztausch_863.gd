# 863 (Chef 10.11., 13:19, t274.15 Ratten: „bei den Wölfen ist es ja auch so, wenn der aus der hinteren Reihe angreift, dann
# tauscht er mit einem den Platz, der in der vorderen Reihe steht … Machen die Ratten jetzt aber anscheinend nicht“; gleiche Regel
# für alle Gegner, auch Wiedergänger 506): je Gruppe ein Nahkämpfer der hinteren Reihe greift mit einem gewöhnlichen Stoß (I_STAB,
# nicht Anspringen) den Helden an; danach steht er vorn und der Freund, der vorn stand, auf seinem Platz hinten. Ein Fernkämpfer
# (Goblin-Späher) bleibt hinten. Regeln am echten Kampfort, ohne Bild.
# Run: godot --headless --path godot --fixed-fps 30 -s res://tests/platztausch_863.gd   (GEGNER=… wählt die Gruppen)
# Exit 0 = gut, 1 sonst.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")

var fehler := 0


func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok:
		fehler += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	await process_frame
	var gegner := (OS.get_environment("GEGNER") if OS.get_environment("GEGNER") != "" else "RATS,GRABHUNDE,WOLVES,BATS,WIEDERGAENGER3,SCOUTS").split(",")
	for g in gegner:
		seed(7)
		var p = Probe.new()
		p.hero_cls = "FIGHTER"
		p.merc_cls = "CLERIC"
		p.foe = g
		root.add_child(p)
		await process_frame
		p._start(7)
		for i in 4:
			await process_frame
		var kf = p.fight
		if kf == null:
			pruefe(false, "%s: kein Kampf" % g)
			p.queue_free()
			continue
		var m = kf.mars
		var hinten = null
		var vorn = null
		for f in m.all:
			if f.side == "FOES" and f.standing() and f.place.x == Mars.BACK and hinten == null:
				hinten = f
		if hinten == null:
			print("     %s: niemand hinten" % g)
		else:
			for f in m.all:
				if f.side == "FOES" and f.standing() and f.place.x == Mars.FRONT and (vorn == null or f.place.y == hinten.place.y):
					vorn = f
			var platz_h: Vector2i = hinten.place
			var platz_v: Vector2i = vorn.place if vorn != null else Vector2i(-1, -1)
			var nah := String(hinten.b.get("art", "nah")) == "nah"
			m._strike(hinten, m.find("hero"), m.I_STAB, Mars.NONE)
			if not hinten.standing():
				print("     %s: %s fiel beim Angriff" % [g, hinten.id])
			elif nah and vorn != null:
				pruefe(hinten.place == platz_v and vorn.place == platz_h,
					"%s: %s griff von hinten an, steht jetzt %s (vorher %s), %s jetzt %s" % [g, hinten.id, str(hinten.place), str(platz_h),
					vorn.id, str(vorn.place)])
			elif not nah:
				pruefe(hinten.place == platz_h, "%s: %s (Fernkampf) bleibt hinten %s" % [g, hinten.id, str(hinten.place)])
			else:
				print("     %s: vorn steht keiner" % g)
		kf.queue_free()
		p.queue_free()
		await process_frame
	print("PLATZTAUSCH863 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
