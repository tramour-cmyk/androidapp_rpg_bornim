extends SceneTree
# 831 (Chef 11.11., 16:19 „831 wie Sokrates“): Bausatz-Baeume (Abgestorben 3 und 5, Kiefer 5) im Flüsterwald, eingebaut in
# dorf.py (kit_baum); Standbilder im echten Spiel zum Selbstpruefen der Signatur (Licht aus der Quelle, Schatten, Tusche nach
# Licht): drei Stellen am Weg, je Tag, Abend, Nacht. Braucht godot/daten (tools/godot/wald_daten.sh).
# Aufruf: xvfb-run … godot --path . -s res://tests/baeume_831.gd -- --baeume831=<ordner>

const STELLEN := [Vector2i(7, 3), Vector2i(15, 20), Vector2i(12, 23)]
const ZEITEN := {"tag": 10 * 60, "abend": 19 * 60 + 30, "nacht": 23 * 60}

var spiel
var dir := ""

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--baeume831="): dir = a.substr(12)
	DirAccess.make_dir_recursive_absolute(dir)
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 10 * 60
	spiel.betrete("forest", STELLEN[0], "DOWN")
	if spiel.herde: spiel.herde.aus = true   # Bilder ohne Angriff
	await create_timer(1.5).timeout
	for z in ZEITEN:
		spiel.zustand.minuten = ZEITEN[z]
		var k: float = 1.0 - spiel.tageslicht(ZEITEN[z])   # licht_nach_uhr laeuft im Test nicht (Aufrufargumente)
		spiel.licht.ziel = k
		spiel.licht.stelle(k)
		await create_timer(2.5).timeout
		for i in STELLEN.size():
			spiel.held.setze(STELLEN[i], "DOWN")
			spiel.kamera.springe()
			await create_timer(1.2).timeout
			spiel.ui.textfeld.visible = false
			await spiel.knips("%s/%s_%d.png" % [dir, z, i])
	print("BAEUME831 fertig")
	quit()
