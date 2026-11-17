# 548 (Chef 04.11., 00:03, Build 249: „Gegen Ratten gespielt. Die starben ohne mein Zutun alle drei“): Weltkampf gegen
# die Kartenratten wie spiel.gd kampf_im_wald (aufruf.gd, Blende, jede Eröffnung), Held ohne jede Eingabe. Richtig: der Kampf
# wartet auf den Spieler (Hauptauswahl), bevor ein Gegner fällt. Ohne Bild. Aufruf: im Ordner godot mit
# -s res://tests/ratten_548.gd (Exit 0 = richtig)
extends SceneTree

const AufrufS = preload("res://kampf/aufruf.gd")

var fehler := 0


func _initialize() -> void:
	Engine.time_scale = 20.0
	_lauf.call_deferred()


func _lauf() -> void:
	for er in ["NORMAL", "AMBUSHED", "HERO_FIRST"]:
		for k in ["Zauberlehrling", "Wachsoldat"]:   # 870.4: Herkunft statt Klasse
			for seed in [1, 2, 3, 7]:
				var r: String = await _einer(er, k, seed)
				print(("ok     " if r.begins_with("wartet") else "FEHLER ") + "%s %s Wurf %d: %s" % [er, k, seed, r])
				if not r.begins_with("wartet"):
					fehler += 1
	print("548 Fehler: %d" % fehler)
	quit(1 if fehler > 0 else 0)


func _einer(er: String, klasse: String, seed: int) -> String:
	var a = AufrufS.new()
	root.add_child(a)
	var h = BrsHeld.fuer_spiel("Alrik", "Mensch", klasse)
	var lage := {"atemlos": false, "satt": false, "eroeffnung": er, "blende": true, "platz": "lichtung"}
	if not a.starte("RATS", h, null, "wald", "tag", 2, -1, -1, seed, Callable(), lage):
		return "nicht gestartet"
	while a.kampf != null and not a.kampf.is_inside_tree():
		await process_frame
	var k = a.kampf
	var t0 := Time.get_ticks_msec()
	var still := 0
	var r := "hängt"
	while Time.get_ticks_msec() - t0 < 20000:
		await process_frame
		if k.mars.outcome != "ONGOING":
			var tote: int = k.mars.fighters().filter(func(f): return f.side == "FOES" and not f.standing()).size()
			r = "%s ohne Eingabe, %d Ratten tot, Held %d TP" % [k.mars.outcome, tote, k.mars.lead().hp]
			break
		if not k.busy and not k.playing and k.beats.is_empty() and not k.ring_open and k.mars.current().side == "PARTY":
			still += 1
			if still > 30:
				r = "wartet auf den Spieler (Held %d TP)" % k.mars.lead().hp
				break
		else:
			still = 0
	if is_instance_valid(a):
		a.queue_free()
	if is_instance_valid(k):
		k.queue_free()
	await process_frame
	return r
