extends SceneTree
# 492 ohne Bild: Einzelstuecke wie Uniques.make (Gear.kt): jedes Stueck aus texte.json (einzelstuecke) wird Ausruestung mit
# Grundform, Seltenheit, Plus, Werten und festem Namen; die Truhe cave_3 (Story.CLASS_WEAPON) gibt jeder Klasse ihre Waffe
# (Story.classWeapon). Braucht daten/texte.json (core exportTexts). Exit 0 oder 1; massgeblich die Zeile EINZEL492.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	Sprache.lade()
	var alle: Dictionary = Sprache.texte.get("einzelstuecke", {})
	pruefe(alle.size() == 9, "Einzelstuecke in texte.json wie Gear.kt (9): %d" % alle.size())
	for id in alle:
		var g := Beute.einzelstueck(String(id), 7, 3)
		pruefe(not g.is_empty() and String(g["unique"]) == String(id) and Beute.grundformen().has(String(g["base"])) and not (g["rolls"] as Array).is_empty(),
			"%s: %s %s +%d %s" % [id, g.get("base"), g.get("rarity"), int(g.get("plus", 0)), JSON.stringify(g.get("rolls"))])
		pruefe(Beute.name(g, "de") == String(alle[id]["name"]["de"]), "%s heisst %s" % [id, Beute.name(g, "de")])
	var axt := Beute.einzelstueck("greataxe_grak", 1, 3)
	pruefe(String(axt["base"]) == "greataxe" and String(axt["rarity"]) == "RARE" and int(axt["plus"]) == 1 and JSON.stringify(axt["rolls"]) == JSON.stringify([["STR", 1], ["DAMAGE", 2]]),
		"Graks Kriegsaxt wie Gear.kt: greataxe, RARE, +1, STR 1, DAMAGE 2")
	pruefe(Beute.einzelstueck("potion", 1, 3).is_empty(), "Heiltrank ist kein Einzelstueck")
	var soll := {"FIGHTER": "longsword_oakford", "WIZARD": "staff_of_embers", "ROGUE": "rapier_whisper", "CLERIC": "mace_of_dawn"}
	for k in soll: pruefe(Beute.klassenwaffe(k) == soll[k], "Truhe cave_3 fuer %s: %s" % [k, Beute.klassenwaffe(k)])
	print("EINZEL492 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
