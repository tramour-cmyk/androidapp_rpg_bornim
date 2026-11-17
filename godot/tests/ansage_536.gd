# 536 t270.10 (Chef 08.11., 20:54, Foto Wolfsrudel: „Klappt wohl nicht so, oder????“; wiederholt): Ansagen „! Anspringen“ hingen
# seitlich mit langer Linie statt dicht über dem Kopf, beim rechten Jungwolf verdeckte die Ansage den Namen. Messung ohne Bild am
# echten Kampfort im Hochformat, Probe Wolf mit Jungwölfen und Wolfsrudel, Autopilot, Namen wie nach langem Drücken an (names_until).
# Je Bild und Ansage: liegt sie seitlich am Kopf (Platz 1, 2), unter den Pfoten (3), auf einem Namen; Abstand der Unterkante zum Kopf.
# Exit 0 = keine Ansage länger als GLEITEN_BILDER Bilder am Stück auf einem Namen (kürzer: sie gleitet gerade an ihren Platz, 438),
# seitlich höchstens SEITLICH_ANTEIL der Bilder.
# Aufruf: im Ordner godot mit --fixed-fps 30 -s res://tests/ansage_536.gd
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const DAUER_BILDER := 30 * 30
const SEITLICH_ANTEIL := 0.05
const GLEITEN_BILDER := 8

var n_ansage := 0
var n_seitlich := 0
var n_pfoten := 0
var n_name := 0
var n_eigener_name := 0
var abstand := []
var beispiel := ""
var am_stueck := {}     # [Ansage, Name] -> Bilder am Stück
var n_lang := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	for foe in ["RUDEL", "WOLVES"]:
		for s in [3, 7]:
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
			kf.mars.find("merc").auto = true
			kf.mars.set_autopilot(true)
			if not kf.busy:
				kf.go_on()
			var n := 0
			while n < DAUER_BILDER and kf.mars.outcome == "ONGOING":
				kf.ui.names_until = Time.get_ticks_msec() + 3000
				await process_frame
				n += 1
				if n > 15:
					_bild(kf, "%s/%d Bild %d" % [foe, s, n])
				if not kf.busy and not kf.playing and kf.beats.is_empty() and not kf.ring_open:
					if kf.mars.pilot_next() or kf.mars.set_autopilot(true):
						kf.go_on()
			kf.queue_free()
			p.queue_free()
			await process_frame
	var sum := 0.0
	var gross := 0.0
	for d in abstand:
		sum += d
		gross = maxf(gross, d)
	var mittel: float = sum / maxf(abstand.size(), 1)
	print("ANSAGE536 %d Ansagen-Bilder: seitlich %d, unter den Pfoten %d, auf fremdem Namen %d, auf eigenem Namen %d (länger als %d Bilder am Stück: %d); über dem Kopf im Mittel %.0f dp, höchstens %.0f dp" % [n_ansage, n_seitlich, n_pfoten, n_name, n_eigener_name, GLEITEN_BILDER, n_lang, mittel, gross])
	if beispiel != "":
		print("  zuerst länger auf einem Namen: " + beispiel)
	var gut: bool = n_ansage > 0 and n_lang == 0 and n_seitlich <= n_ansage * SEITLICH_ANTEIL
	print("ANSAGE536 " + ("richtig" if gut else "FEHLER"))
	quit(0 if gut else 1)


func _namen(ui, k) -> Dictionary:
	var out := {}
	for id in ui.named:
		if not k.figures.has(id):
			continue
		var fig = k.figures[id]
		var f = fig.fighter
		var fs: int = ui.sp(12)
		var w: float = ui.font.get_string_size(f.name(ui.lang), HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 12 * ui.dp
		var foot: Vector2 = ui._foot(fig)
		out[id] = Rect2(foot.x - w / 2, ui._name_top(foot, ui._tall(fig), f.side == "FOES"), w, ui._name_h())
	return out


func _bild(kf, wo: String) -> void:
	var ui = kf.ui
	var k = ui.kampfort
	var namen := _namen(ui, k)
	var jetzt := {}
	for id in ui.sign_of:
		if not k.figures.has(id):
			continue
		var r: Rect2 = ui.sign_of[id]
		n_ansage += 1
		var wahl = ui.sign_wahl.get(id)
		if wahl != null and (wahl[0] == 1 or wahl[0] == 2):
			n_seitlich += 1
		elif wahl != null and wahl[0] == 3:
			n_pfoten += 1
		for nid in namen:
			if r.intersects((namen[nid] as Rect2).grow(-1)):
				if nid == id:
					n_eigener_name += 1
				else:
					n_name += 1
				var key := "%s>%s" % [id, nid]
				jetzt[key] = int(am_stueck.get(key, 0)) + 1
				if jetzt[key] == GLEITEN_BILDER + 1:
					n_lang += 1
				if OS.get_environment("ALLE") != "":
					print("  auf Name: %s: %s %s auf %s %s" % [wo, id, r, nid, namen[nid]])
				if beispiel == "" and jetzt[key] > GLEITEN_BILDER:
					beispiel = "%s: Ansage von %s %s auf Name von %s %s" % [wo, id, r, nid, namen[nid]]
		var fig = k.figures[id]
		var head: float = ui._foot(fig).y - ui._tall(fig)
		if r.end.y < head:
			abstand.append((head - r.end.y) / ui.dp)
	am_stueck = jetzt
