# 1603 (Beleg Bild): Ansage alt gegen neu je Art. Echter Kampfort (Probe) gegen GEGNER, der Held greift an, der Ring wird gut getroffen,
# bis ein Gegner die gesuchte Absicht ansagt; dann ein Bild des Gegners mit Ansage (Ausschnitt 270 x 270 um den Kopf).
#   MODUS=alt: wie main vor 1603 (jede dieser Arten „Stich“, absichten.je_art der Art zur Laufzeit auf [["stab", 1]])
#   MODUS=neu: die Tabelle 1603; MODUS=paw: Kroggs Prankenhieb erzwungen (Mars.test_gegnerzug „paw“)
# Nur mit Fenster, im Ordner godot:
#   GEGNER=KROGG MODUS=neu xvfb-run -a godot --path . --resolution 540x1170 --fixed-fps 30 -s res://tests/bild_1603.gd -- --aus=<Ordner>
# Ausgabe: <Ordner>/<GEGNER>-<MODUS>.png, Zeile „BILD1603 <GEGNER> <MODUS> <Absicht> <Name>“; exit 1, wenn die Absicht nicht kam.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const FPS := 30.0
const NEU := {"KROGG": "morningstar", "BOARS": "tusks", "CENTIPEDES": "poison_claws", "LEECHES": "sucker", "SLUGS": "tongue",
	"KOBOLDS": "stab", "SKELETONS": "stab"}
const ART := {"KROGG": "bugbear", "BOARS": "boar", "CENTIPEDES": "giant_centipede", "LEECHES": "stirge", "SLUGS": "ochre_jelly",
	"KOBOLDS": "kobold", "SKELETONS": "skeleton"}


func _initialize() -> void:
	_lauf.call_deferred()


func _env(k: String, d: String) -> String:
	return OS.get_environment(k) if OS.has_environment(k) else d


func _lauf() -> void:
	var aus := "user://bild_1603"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--aus="):
			aus = a.substr(6)
	DirAccess.make_dir_recursive_absolute(aus)
	var g := _env("GEGNER", "KROGG")
	var modus := _env("MODUS", "neu")
	var soll: String = "stab" if modus == "alt" else ("paw" if modus == "paw" else String(NEU.get(g, "")))
	if modus == "alt":     # Stand vor 1603: _sonst = Stich für jede dieser Arten
		Brs.lade()["absichten"]["je_art"][ART[g]] = [["stab", 1]]
	seed(1603)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = g
	root.add_child(p)
	await process_frame
	p._start(1603)
	for i in 4:
		await process_frame
	var kf = p.fight
	kf.mars.find("merc").auto = true
	kf.ui.uhr = func() -> int: return int(Engine.get_process_frames() * 1000.0 / FPS)
	while kf.verhuellt:
		await process_frame
	var ring_seit := -1
	var wer := ""
	var stand := 0
	for n in int(FPS) * 240:
		await process_frame
		if modus == "paw" and Mars.test_gegnerzug == "":
			Mars.test_gegnerzug = "paw"
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
		if kf.shown is Dictionary and kf.shown.has("intents"):
			for id in kf.shown.intents:
				if id != "hero" and id != "merc" and String(kf.shown.intents[id][0].id) == soll and kf.figures.has(id):
					wer = id
		if wer != "":
			stand += 1
			if stand >= 20:     # Ansage steht
				break
			continue
		if kf.ring_open:
			if ring_seit < 0:
				ring_seit = n
			elif n - ring_seit >= int(kf.RING_MS / 1000.0 * FPS):
				kf._answer_ring(Mars.GOOD)
		else:
			ring_seit = -1
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			if kf.mars.pilot_next():
				kf.go_on()
			else:
				var ts: Array = kf.mars.targets(kf.mars.current())
				kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
	if wer == "":
		print("BILD1603 FEHLER %s %s: Absicht %s kam nicht" % [g, modus, soll])
		quit(1)
		return
	var it: Dictionary = kf.shown.intents[wer][0]
	if DisplayServer.get_name() == "headless":     # ohne Fenster kein Bild (frame_post_draw kommt nie)
		print("BILD1603 %s %s %s %s | ohne Bild" % [g, modus, it.id, it.name[0]])
		quit(0)
		return
	await RenderingServer.frame_post_draw
	var bild := root.get_texture().get_image()
	var fig = kf.figures[wer]
	var fuss: Vector2 = kf.ui._foot(fig)
	var kopf := fuss.y - float(kf.ui._tall(fig))
	var gr := 270
	var x := clampi(int(fuss.x) - gr / 2, 0, bild.get_width() - gr)
	var y := clampi(int(kopf) - 150, 0, bild.get_height() - gr)
	var aus_bild := bild.get_region(Rect2i(x, y, gr, gr))
	var f := "%s/%s-%s.png" % [aus, g, modus]
	aus_bild.save_png(f)
	print("BILD1603 %s %s %s %s | %s" % [g, modus, it.id, it.name[0], f])
	quit(0)
