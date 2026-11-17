extends SceneTree
# 1420 (Chef 16.11., 12:45: im Wald und tiefen Wald kein Fußstaub): der Held geht und rennt auf Erde (Bodenmaske) im Dorf, im Wald
# und im tiefen Wald; je Ort und Gang mindestens ein Fußstaub. Im Wald kleiner als im Dorf (STAUB_WALD). Ohne Pakete „ohne Pakete“.
#   ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/staub_1420.gd  -> „STAUB1420 n Fehler“

var spiel
var fehler := 0

func _initialize() -> void: _lauf.call_deferred()

func warte(n: int) -> void:
	for i in n: await process_frame

func pruefe(ok: bool, was: String) -> void:
	if not ok: fehler += 1; print("FEHLER ", was)
	else: print("gut ", was)

## eine Kachel auf Erde mit drei begehbaren Erdkacheln nach Norden (der Held geht nach Norden)
func erdweg(fx: DorfEffekte) -> Vector2i:
	var k: Karte = spiel.karte
	for y in range(4, k.hoehe - 1):
		for x in range(1, k.breite - 1):
			var ok := true
			for d in 4:
				var t := Vector2i(x, y - d)
				if not k.begehbar(t) or not fx.erde(k.kachel_pos(t)): ok = false; break
			if ok: return Vector2i(x, y)
	return Vector2i(-1, -1)

func _lauf() -> void:
	if not DorfEffekte.da():
		print("STAUB1420 ohne Pakete"); quit(0); return
	DorfEffekte.an = true
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	await warte(5)
	spiel.zustand.minuten = 10 * 60
	var groesse := {}
	for ort in ["village", "forest", "deep_forest"]:
		spiel.betrete(ort, Vector2i(2, 2), "UP")
		await warte(10)
		var fx: DorfEffekte = spiel.gebiet.effekte
		pruefe(fx != null, "%s: Effekte da" % ort)
		if fx == null: continue
		var t := erdweg(fx)
		pruefe(t.x >= 0, "%s: Erdweg gefunden %s" % [ort, t])
		if t.x < 0: continue
		for rennen in [false, true]:
			spiel.held.setze(t, "UP")
			await warte(3)
			spiel.laufen_will = rennen
			var vor := _staub(fx).size()
			spiel.held.richtung = Vector3(0, 0, -1)
			await warte(40)
			spiel.held.richtung = Vector3.ZERO
			spiel.laufen_will = false
			var neu := _staub(fx).slice(vor)
			pruefe(neu.size() > 0, "%s %s: %d Fußstaub" % [ort, "Rennen" if rennen else "Gehen", neu.size()])
			if rennen and not neu.is_empty():
				var gp := (neu[0] as Node).find_children("*", "GPUParticles3D", true, false)
				if not gp.is_empty(): groesse[ort] = ((gp[0] as GPUParticles3D).process_material as ParticleProcessMaterial).scale_max
			await warte(5)
	if groesse.has("village") and groesse.has("forest"):
		pruefe(groesse["forest"] < groesse["village"], "im Wald kleiner (%.2f) als im Dorf (%.2f)" % [groesse["forest"], groesse["village"]])
	print("STAUB1420 %d Fehler" % fehler)
	quit(1 if fehler else 0)

func _staub(fx: DorfEffekte) -> Array:
	return fx.get_children().filter(func(c): return String(c.scene_file_path).ends_with("footstep_dust.tscn"))
