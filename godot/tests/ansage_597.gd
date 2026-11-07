# 597 (Chef 07.11., t268.21: „Bei Wolf kam nie eine Ansage“; alt Skirmish.kt: der Wolf sagt „Anspringen“ an, ohne Ring): am echten
# Kampfort im Hochformat, Autopilot, je Bild (--fixed-fps 30), Probekampf Wolfsrudel und Wolf mit Jungwölfen. Je Zug eines Wolfs
# (seine Absicht verschwindet aus dem Gezeigten): wie viele Bilder vorher stand seine Ansage im Bild (kampf_ui sign_of, ganz im
# Schirm). Dazu jedes Bild, in dem ein stehender Wolf eine Absicht hat (außer Knurren), aber kein Schild im Schirm.
# Aufruf: im Ordner godot mit --fixed-fps 30 -s res://tests/ansage_597.gd (Exit 0 = jeder Angriff eines Wolfs war vorher mindestens
# MIN_BILDER Bilder angesagt, kein Bild ohne Schild)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const DAUER_BILDER := 30 * 90
const MIN_BILDER := 15

var fehler := 0
var bilder := {}       # id -> Bilder mit sichtbarer Ansage seit der letzten Absicht
var hatte := {}        # id -> Absicht im letzten Bild (Kennung)
var zuege := []        # [Gruppe, id, Absicht, Bilder]
var ohne := 0
var ohne_bsp := []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	for foe in ["WOLVES", "RUDEL"]:
		for s in [3, 7, 11]:
			seed(s)
			var p = Probe.new()
			p.hero_cls = "FIGHTER"
			p.merc_cls = "CLERIC"
			p.foe = foe
			root.add_child(p)
			await process_frame
			p._start(s)
			for i in 4:
				await process_frame
			var kf = p.fight
			if kf == null:
				print("ANSAGE597 kein Kampf")
				quit(1)
				return
			kf.mars.find("merc").auto = true
			kf.mars.set_autopilot(true)
			if not kf.busy:
				kf.go_on()
			bilder.clear(); hatte.clear()
			var n := 0
			while n < DAUER_BILDER:
				await process_frame
				n += 1
				_bild(kf, foe)
				if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
					break
				if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING" and not kf.ring_open:
					if kf.mars.pilot_next() or kf.mars.set_autopilot(true):
						kf.go_on()
			print("ANSAGE597 %s Seed %d: %s nach %d Bildern" % [foe, s, kf.mars.outcome, n])
			kf.queue_free()
			p.queue_free()
			await process_frame
	var kurz := zuege.filter(func(z): return z[3] < MIN_BILDER)
	for z in kurz:
		print("FEHLER %s %s %s: Ansage nur %d Bilder im Bild vor dem Zug" % z)
	if ohne > 0:
		print("FEHLER %d Bilder: Wolf mit Absicht ohne Schild im Schirm, z. B. %s" % [ohne, ohne_bsp])
	fehler = kurz.size() + (1 if ohne > 0 else 0)
	var mittel := 0.0
	for z in zuege:
		mittel += z[3]
	print("ANSAGE597 %d Züge der Wölfe mit Ansage, im Mittel %.0f Bilder angesagt, %d zu kurz, %d Bilder ohne Schild" % [zuege.size(),
			mittel / maxf(1.0, zuege.size()), kurz.size(), ohne])
	print("ANSAGE597 " + ("gut" if fehler == 0 else "FEHLER"))
	quit(1 if fehler > 0 else 0)


func _bild(kf, foe: String) -> void:
	var ui = kf.ui
	var schirm := Rect2(Vector2.ZERO, Vector2(root.size))
	var jetzt := {}
	for id in kf.figures:
		var f = kf.figures[id]
		if f.fighter.side != "FOES" or not kf.mars.wolfig(f.fighter.monster):
			continue
		if kf.shown.get("intents", {}).has(id):
			var a: Dictionary = kf.shown.intents[id][0]
			if a.get("effect", "") == "GROWL":
				continue
			jetzt[id] = String(a.id)
			var steht: bool = f.visible and not f.down and kf.shown.hp.get(id, f.fighter.hp) > 0
			var da: bool = ui.sign_of.has(id) and schirm.encloses(ui.sign_of[id])
			if da:
				bilder[id] = bilder.get(id, 0) + 1
			elif steht and not kf.busy and not kf.playing:
				ohne += 1
				if ohne_bsp.size() < 3:
					ohne_bsp.append("%s %s %s" % [foe, id, a.id])
	for id in hatte:
		if not jetzt.has(id) and kf.mars.find(id) != null and kf.mars.find(id).standing():
			zuege.append([foe, id, hatte[id], bilder.get(id, 0)])
			bilder.erase(id)
	hatte = jetzt
