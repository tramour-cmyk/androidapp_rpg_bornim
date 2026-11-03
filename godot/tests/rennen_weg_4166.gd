extends SceneTree
# 416.6 Staubfilm Lauf 231 (Prüfer: der Held geht in allen Bildern, ein Wölkchen): der Held folgt rennend (laeuft) einem Weg aus
# Kachelmitten (Tippen, staub_bilder). Zählt Bilder, in denen er „Rennen“ spielt, und Bilder, in denen er mitten im Weg nicht vorankommt.
# Lauf 231 nachgestellt (03.11.): ohne 416.4 (Tom, claude/tom-416-4-ruckeln) bremst er an jedem Wegpunkt auf Gehtempo, mit 416.4 nicht.
# Ohne Modell: Held ohne _ready, Bewegungen leer (je 1 s). Braucht godot/daten/karten.json. Massgeblich die Zeile RENNWEG.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var karte := Karte.lade("forest")
	var held := Held.new(karte)
	var ap := AnimationPlayer.new()
	root.add_child(ap)
	var lib := AnimationLibrary.new()
	for n in ["Gehen", "Rennen", "Stehen"]:
		var a := Animation.new()
		a.length = 1.0
		a.loop_mode = Animation.LOOP_LINEAR
		lib.add_animation(n, a)
	ap.add_animation_library("", lib)
	held.anim = ap
	held.gang = 1.08
	held.renn = 4.3
	# Weg: das längste Stück Weg „=“ im Wald, wie staub_bilder (fernstes Wegfeld in höchstens 7 Feldern)
	var von := Vector2i(-1, -1)
	var ziel := von
	var weit := 0.0
	for y in karte.hoehe:
		for x in karte.breite:
			var a := Vector2i(x, y)
			if karte.zeichen(a) != "=" or not karte.begehbar(a): continue
			for y2 in range(y - 7, y + 8):
				for x2 in range(x - 7, x + 8):
					var t := Vector2i(x2, y2)
					if karte.zeichen(t) != "=" or not karte.begehbar(t): continue
					var d := Vector2(t - a).length()
					if d > weit and d <= 7.0 and karte.weg(a, t).size() > 0:
						weit = d; von = a; ziel = t
	pruefe(von.x >= 0, "Weg im Wald %s -> %s (%.1f Felder)" % [von, ziel, weit])
	held.position = karte.kachel_pos(von)
	held.kachel = von
	for t in karte.weg(von, ziel): held.weg.append(karte.kachel_pos(t))
	held.laeuft = true
	ap.play("Stehen")
	var bilder := 0
	var rennen := 0
	var stockt := 0
	var einbruch := 0    # nach dem ersten Rennen-Bild, solange noch mindestens drei Wegpunkte vor ihm liegen: Bilder ohne Rennen
	var rannte := false
	var dt := 1.0 / 60.0
	while held.weg.size() > 0 and bilder < 600:
		var vorher := held.position
		held._process(dt)
		ap.advance(0.0)
		bilder += 1
		if OS.get_environment("SPUR") != "": print("%d %.2f %s weg %d" % [bilder, held.tempo_jetzt, ap.current_animation, held.weg.size()])
		if held.weg.size() > 0:
			if ap.current_animation == "Rennen": rennen += 1; rannte = true
			elif rannte and held.weg.size() >= 3: einbruch += 1
			if (held.position - vorher).length() < 1e-4: stockt += 1
	var unterwegs := maxi(1, bilder - 1)
	print("RENNWEG %d Bilder unterwegs, %d rennend, %d ohne Fortschritt, %d Einbrüche" % [unterwegs, rennen, stockt, einbruch])
	pruefe(stockt == 0, "mitten im Weg kein Bild ohne Fortschritt: %d" % stockt)
	pruefe(rannte and einbruch == 0, "einmal im Rennen, bleibt er es bis vor das Ende: %d Bilder Gehen dazwischen" % einbruch)
	print("RENNWEG %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	held.free()
	quit(1 if fehler > 0 else 0)
