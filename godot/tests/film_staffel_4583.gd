extends SceneTree
# 458.3 (Chef 01.11., 19:5x „Staffel nach Stufe“; 02.11., 11:28 Modelle und Staffel passen): die Staffel im Spiel, im Dorf wie im Spiel
# (spiel.tscn, Spielshader mit Tusche, Spielkamera nah). Der Held geht auf der Straße hin und her; alle REIHE_S Sekunden legt er die
# nächste Waffe an (Ausrüstung des Helden, spiel.held_figur_neu wie nach dem Menü): Form nach Stufe des Gegenstands, Farbe nach Seltenheit.
# REIHE=einhand (Schwert, Streitkolben, Morgenstern) oder zweihand (Großaxt, Hellebarde, Speer), Standard einhand.
# Nur mit Fenster und --write-movie, im Ordner godot:
#   REIHE=einhand xvfb-run -a godot --rendering-driver opengl3 --path . --resolution 540x1170 --write-movie <x.avi> --fixed-fps 30 \
#     -s res://tests/film_staffel_4583.gd

const REIHEN := {
	"einhand": [["longsword", 1, "COMMON"], ["longsword", 5, "UNCOMMON"], ["longsword", 11, "RARE"], ["mace", 1, "COMMON"],
		["mace", 8, "RARE"], ["morningstar", 11, "EPIC"]],
	"zweihand": [["greataxe", 1, "COMMON"], ["greataxe", 5, "UNCOMMON"], ["greataxe", 11, "RARE"], ["halberd", 1, "COMMON"],
		["halberd", 11, "EPIC"], ["spear", 11, "RARE"]],
}
const REIHE_S := 2.4
const SEL_DE := {"COMMON": "gewöhnlich", "UNCOMMON": "ungewöhnlich", "RARE": "selten", "VERY_RARE": "sehr selten", "EPIC": "episch",
	"DIVINE": "göttlich"}

var spiel
var titel: Label
var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var reihe: Array = REIHEN.get(OS.get_environment("REIHE"), REIHEN["einhand"])
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var ebene := CanvasLayer.new()
	ebene.layer = 60
	root.add_child(ebene)
	titel = Label.new()
	titel.add_theme_font_size_override("font_size", 28)
	titel.add_theme_color_override("font_color", Color(0.96, 0.93, 0.85))
	titel.add_theme_color_override("font_outline_color", Color.BLACK)
	titel.add_theme_constant_override("outline_size", 8)
	titel.position = Vector2(24, 90)
	ebene.add_child(titel)
	spiel.zustand.minuten = 15 * 60
	spiel.betrete("village", Vector2i(17, 5), "UP")
	for i in 5: await process_frame
	spiel.licht.ziel = 0.0
	spiel.licht.stelle(0.0)
	for n in ["mess", "oben", "leiste", "textfeld"]:
		var k = spiel.ui.get(n)
		if k: k.visible = false
	spiel.kamera.zoom = spiel.kamera.NAH
	spiel.kamera.springe()
	var hw = spiel.held_werte()
	hw.ausruestung.erase("OFF_HAND")
	for i in reihe.size():
		var e: Array = reihe[i]
		var g := {"uid": 9000 + i, "base": e[0], "rarity": e[2], "ilvl": e[1], "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
		hw.ausruestung["MAIN_HAND"] = g
		spiel.held_figur_neu("")
		var schl := Staffel.schluessel(g)
		var am: bool = spiel.held.modell != null and (not spiel.held.modell.find_children("Getragen*", "", false, false).is_empty() \
			or not spiel.held.modell.find_children("Ruecken*", "", true, false).is_empty())
		print("FILM4583 %s Stufe %d %s: %s %s" % [e[0], e[1], e[2], schl, "am Helden" if am else "FEHLT"])
		if not (am and schl.contains("#")): fehler += 1
		titel.text = "%s · Stufe %d · %s" % [String(Katalog.eintrag(String(e[0])).get("name", {}).get("de", e[0])), e[1], SEL_DE[e[2]]]
		spiel.held.richtung = Vector3(0, 0, -1) if i % 2 == 0 else Vector3(0, 0, 1)
		spiel.kamera.drehe(50.0)
		for f in int(REIHE_S * 30.0): await process_frame
	spiel.held.richtung = Vector3.ZERO
	print("FILM4583 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler else 0)
