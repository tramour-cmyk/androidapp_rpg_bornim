# 662 (Chef t270.9, 08.11., 20:50: „Ich erkenne keinen Unterschied, von welcher Seite der Angriff kommt“): Seite der gelungenen
# Parade aus der Aufstellung des Kampforts (kampfort._stand, _ground, facing), ohne Kaufmodelle. Je Lage Held gegen Gegner vorn:
# Winkel aus der Blickrichtung des Helden (+ = links) und gewählte Parade. Hält an, wenn im Rudel beide äußeren Wölfe zur Mitte gehen
# oder der Einzelne zur Seite.
# Run: godot --headless --path godot -s res://tests/parade_seite_662.gd
extends SceneTree

const Kampfort = preload("res://kampf/kampfort.gd")
const Figur = preload("res://kampf/figur.gd")


func _seite(w: float) -> String:
	return "links" if w > Figur.PARADE_SEITE else ("rechts" if w < -Figur.PARADE_SEITE else "Mitte")


func _initialize() -> void:
	var k = Kampfort.new()
	var blick: Vector3 = k.facing(false)
	var fehler := 0
	# [Held allein, Gegner allein]: allein gegen einen Wolf, allein gegen das Rudel (Kleriker gegen Wölfe), mit Söldner gegen das Rudel
	for lage in [[true, true], [true, false], [false, false]]:
		var alone: bool = lage[1]
		var held_ab: Vector2 = k._stand(false, false, 0, lage[0])
		var held: Vector3 = k._ground(held_ab.x, held_ab.y)
		var seiten := []
		var lagen := [[0, true]] if alone else [[0, false], [1, false]]
		for l in lagen:
			var ab: Vector2 = k._stand(true, false, l[0], l[1])
			var w := Figur.parade_winkel(blick, k._ground(ab.x, ab.y) - held)
			seiten.append(_seite(w))
			print("PARADE662 %s, Gegner vorn %d: %.1f° → %s" % ["Held allein" if lage[0] else "Held mit Söldner", l[0], w, _seite(w)])
		if alone and seiten[0] != "Mitte":
			fehler += 1
			print("FEHLER einzelner Gegner von vorn geht zur Seite")
		if not alone and not ("links" in seiten and "rechts" in seiten):
			fehler += 1
			print("FEHLER Rudel: nicht beide Seiten (%s)" % [seiten])
	# Vorzeichen wie das Modell (links = +X): ein Angreifer quer links vom Blick
	var quer := Figur.parade_winkel(Vector3(0, 0, 1), Vector3(1, 0, 0))
	if absf(quer - 90.0) > 0.1:
		fehler += 1
		print("FEHLER Vorzeichen: +X ergibt %.1f° statt 90°" % quer)
	k.free()
	print("PARADE662 %s" % ("ok" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
