extends SceneTree
# 635 (Abgleich 620.2a): jede Person der Karten hat eine Figur, nach Kennung oder Aussehen (Lyra heisst lyra_temple und lyra_cave,
# gebaut wird „lyra“; vorher stand sie nie im Tempel). Ohne Bild, ohne gebaute Leute: legt fuer die Probe eine leere lyra.bin an,
# falls keine da ist, und raeumt sie wieder weg.
# Aufruf: im Ordner godot mit -s res://tests/lyra_635.gd -> „LYRA635 n Fehler“

const LEUTE := "res://daten/leute/"
const GEBAUT := ["village", "inn", "shop", "elder", "temple", "forest", "deep_forest", "cave"]

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FALSCH ", was)
	else:
		print("ok     ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var l: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/blender348/v3/leute.json"))
	var k: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))["karten"]
	for m in GEBAUT:
		if not k.has(m): continue
		for n in k[m].get("leute", []):
			var mo := String(n.get("aussehen", ""))
			if mo.begins_with("monster:"): continue
			pruefe(l.has(String(n["id"])) or l.has(mo), "%s %s: Figur nach Kennung oder Aussehen „%s“ in leute.json" % [m, n["id"], mo])
	var probe := not FileAccess.file_exists(LEUTE + "lyra.bin")
	if probe:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(LEUTE))
		FileAccess.open(LEUTE + "lyra.bin", FileAccess.WRITE).store_8(0)
	pruefe(Leute.datei_von({"id": "lyra_temple", "aussehen": "lyra"}) == LEUTE + "lyra.bin", "lyra_temple nimmt lyra.bin")
	pruefe(Leute.datei_von({"id": "lyra_cave", "aussehen": "lyra"}) == LEUTE + "lyra.bin", "lyra_cave nimmt lyra.bin")
	pruefe(Leute.datei_von({"id": "niemand", "aussehen": "keiner"}) == "", "ohne Modell keine Figur")
	pruefe(Leute.datei_von({"id": "grimfang", "aussehen": "monster:dire_wolf"}) == "", "Monster nicht als Person")
	# t274.13: Station „Tempel“ im Reiter „Test“ stellt den Helden neben Lyra, die dort zu sehen ist
	var z := Zustand.new()
	var ziel := Testmodus.station("Tempel", z)
	pruefe(ziel.size() == 4 and ziel[0] == "temple", "Station Tempel fuehrt in den Tempel")
	pruefe(Geschichte.sichtbar("lyra_temple", z) and z.has(Geschichte.LYRA_GONE) and not z.has(Geschichte.CHAPTER1_DONE), "Station Tempel: Lyra befreit, Kapitel offen")
	for n in k["temple"].get("leute", []):
		if String(n["id"]) == "lyra_temple" and ziel.size() == 4:
			pruefe((ziel[1] - Vector2i(int(n["x"]), int(n["y"]))).length_squared() == 1, "Station Tempel: Held neben Lyra")
	# t277.16 (Chef 11.11., 20:49: „Ich gehe davon aus, das ist die alte“): Lyra kam nach dem Aussehen als alte Figur (lyra.bin, Haende
	# vorn wie gefesselt); sie ist auch als Person „lyra“ auf dem Kaufkoerper gebaut (held_L_lyra_W) und steht dann wie die anderen
	for kn in ["temple", "cave"]:
		var lyra: Leute = null
		for x in Leute.alle(Karte.lade(kn), null):
			if String(x.daten["id"]).begins_with("lyra"): lyra = x
			else: x.free()
		pruefe(lyra != null and String(lyra.daten.get("person", "")) == "lyra", "%s: Lyra als Person „lyra“" % kn)
		if lyra == null: continue
		if HeldFigur.person_modell("lyra") != "":
			root.add_child(lyra)
			await process_frame
			pruefe(lyra.modell != null and lyra.modell.name == "Person_lyra", "%s: Lyra auf dem Kaufkoerper, nicht die alte Figur" % kn)
		else:
			print("ohne Kaufdateien: %s nur die Zuordnung geprueft" % kn)
		lyra.free()
	if probe: DirAccess.remove_absolute(ProjectSettings.globalize_path(LEUTE + "lyra.bin"))
	print("LYRA635 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
