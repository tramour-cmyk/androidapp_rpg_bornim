# 385.2 (Chef 28.10., 19:1x, Zauberer-Set: aus dem Stab soll sichtbar Zauber kommen): Film durch die echte Oberfläche, Spielkamera,
# Echtzeit. Probekampf Wölfe, der Held ist Zauberlehrling und wirkt zweimal den Funkenpfeil über „Können“ auf den nächsten Wolf:
# Feuer an der Stabspitze beim Loslassen, Geschoss aus R2 (fire) zum Wolf, Einschlag. Der Söldner kämpft selbst. Nach dem zweiten
# Funkenpfeil noch 2 s, dann Ende. Das Protokoll nennt je Funkenpfeil das Bild („Film 3852: Funkenpfeil … Bild n“, zum Schneiden).
# Aufruf (Bild, Probelauf nach 621 A): PROBE=385.2 xvfb-run godot --path godot --resolution 540x1170 --write-movie <datei>.avi
#   --fixed-fps 30 -s res://tests/film_feuer_3852.gd       MESS=1 ohne Bild: nur der Ablauf (zwei Funkenpfeile, mit Paket aus R2)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")
const BLENDE_BILDER := 8
const WIRKEN := 2

var mess := OS.get_environment("MESS") != ""
var schwarz: ColorRect
var fehler := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if not mess:
		var deck := CanvasLayer.new()
		deck.layer = 128
		schwarz = ColorRect.new()
		schwarz.color = Color.BLACK
		schwarz.set_anchors_preset(Control.PRESET_FULL_RECT)
		schwarz.mouse_filter = Control.MOUSE_FILTER_IGNORE
		deck.add_child(schwarz)
		root.add_child(deck)
	seed(7)
	var p = Probe.new()
	p.hero_cls = "WIZARD"
	p.merc_cls = "FIGHTER"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(5)
	if p.fight != null:
		p.fight.messpause = true
	for i in 12:
		await process_frame
	var kf = p.fight
	if kf == null:
		print("FEHLER 385.2: kein Kampfort")
		quit(1)
		return
	var m = kf.mars
	m.find("merc").auto = true
	if not mess and not Signatur.wache(kf, self, "Film 3852"):
		return
	var r2: bool = kf.ui.geschoss_r2("FIRE_BOLT") != null
	print("Film 3852: Paket R2 fire %s" % ("da" if r2 else "nicht da"))
	await _blende(0.0)
	await create_timer(0.4).timeout
	kf.messpause = false
	var gewirkt := 0
	var ende := -1
	var n := 0
	var fluege0: int = kf.ui.arkan_fluege.size()
	var gesehen := {}     # ohne Paket: gemalte Funkenpfeile je Seed (ui.spells leert sich nach dem Flug)
	while n < 30 * 60:
		await process_frame
		n += 1
		for sp in kf.ui.spells:
			if String(sp.kind) == "FIRE_BOLT":
				gesehen[sp.seed] = true
		var fl: int = kf.ui.arkan_fluege.slice(fluege0).filter(func(x): return x.size() > 4 and x[4] == "FIRE_BOLT").size() if r2 \
			else gesehen.size()
		if fl > gewirkt:
			gewirkt = fl
			print("Film 3852: Funkenpfeil %d fliegt, Bild %d (%.1f s)" % [gewirkt, n, n / 30.0])
			# 385.2 (Chef 17.11., 21:40: „Zauber beginnt nicht am Stab sondern am /hinterm Kopf“): Start gegen Kopf und Stab messen
			var hf = kf.figures.get("hero")
			var flug: Array = kf.ui.arkan_fluege.back() if r2 else []
			if hf != null and flug.size() > 2:
				var w: Node3D = hf.model.find_child("Waffe", true, false) as Node3D if hf.model != null else null
				var stab: bool = w != null and w.get_meta("stab", false) and not w.find_children("*", "MeshInstance3D", true, false).is_empty()
				var kopf: Vector3 = hf.head()
				var richtung: Vector3 = Vector3(flug[2].x - kopf.x, 0, flug[2].z - kopf.z).normalized()
				var vor: float = (flug[1] - kopf).dot(richtung)
				if OS.get_environment("STANDBILD") != "":     # Einzelbild beim Loslassen, nur zum eigenen Ansehen
					root.get_texture().get_image().save_png(OS.get_environment("STANDBILD").replace(".png", "-%d.png" % gewirkt))
				print("Film 3852: Start %.2f m über dem Kopf, %.2f m vor dem Kopf zum Ziel, Stab mit Modell: %s" % [flug[1].y - kopf.y, vor, stab])
				if not stab or vor < 0.0:
					print("FEHLER 385.2: Funkenpfeil beginnt nicht an der Stabspitze vor dem Helden")
					fehler += 1
			if gewirkt >= WIRKEN:
				ende = n + 60
		if ende > 0 and n >= ende:
			break
		if m.outcome != "ONGOING":
			break
		if kf.busy or kf.playing or not kf.beats.is_empty():
			continue
		var f = m.current()
		if OS.get_environment("ZUG") != "" and f != null:
			print("  Zug %s, Bild %d" % [f.id, n])
		if f != null and f.id == "hero" and f.standing():
			var ziele: Array = m.aim_at(f, "Z_FUNKEN")
			if not ziele.is_empty() and m.blocked(f, "Z_FUNKEN") == null:
				kf.order(["use", "Z_FUNKEN", ziele[0].id])
				continue
		kf.go_on()
	if gewirkt < WIRKEN:
		print("FEHLER 385.2: nur %d Funkenpfeile" % gewirkt)
		fehler += 1
	print("Film 3852 %s nach %.1f s" % ["Messung: %d Befunde" % fehler if mess else "fertig", n / 30.0])
	await _blende(1.0)
	quit(1 if fehler > 0 else 0)


func _blende(ziel: float) -> void:
	if schwarz == null:
		return
	var von := schwarz.color.a
	for i in BLENDE_BILDER:
		await process_frame
		schwarz.color.a = lerpf(von, ziel, float(i + 1) / BLENDE_BILDER)
