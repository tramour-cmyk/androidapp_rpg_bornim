extends SceneTree
# 785.20 (Abgleich alt, Theme.kt 293: jeder PixelButton klickt leise): auch die Knöpfe im Stil 549a (PanelContainer über
# Spielstaende.tippbar: Spielstände, Erschaffung, Laden, Brett, Rast, Kapitelende, Rückfragen) klicken beim Antippen mit 35 %;
# abgeschaltete nicht, Wischen nicht. Ein Klang-Ersatz unter /root/Klang zählt. Ohne Bild. Maßgeblich ist die Zeile KLICK78520.

class Zaehler extends Node:
	var klicks: Array = []
	func effekt(was: String, laut := 1.0) -> void: klicks.append([was, laut])

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func tipp(p: Control, weg := Vector2.ZERO) -> void:
	var m := p.get_global_rect().get_center()
	for an in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT; e.pressed = an
		e.position = (p.size / 2) + (Vector2.ZERO if an else weg); e.global_position = m + (Vector2.ZERO if an else weg)
		p.gui_input.emit(e)
	await process_frame

func _lauf() -> void:
	Sprache.lade()
	var echt := root.get_node_or_null("Klang")
	if echt: echt.name = "KlangEcht"; echt.process_mode = Node.PROCESS_MODE_DISABLED
	var z := Zaehler.new()
	z.name = "Klang"
	root.add_child(z)
	var getan := [0]
	var k := Spielstaende.knopf("neben", "Probe", func(): getan[0] += 1)
	k.size = Vector2(300, 120)
	root.add_child(k)
	await process_frame
	await tipp(k)
	pruefe(getan[0] == 1 and z.klicks == [["click", 0.35]], "Antippen: Tat und ein Klick zu 35 %% (%s)" % str(z.klicks))
	await tipp(k, Vector2(0, 200))
	pruefe(z.klicks.size() == 1, "Wischen klickt nicht (%d)" % z.klicks.size())
	var aus := Spielstaende.knopf("neben", "Aus", func(): getan[0] += 10, false, false)
	aus.size = Vector2(300, 120)
	root.add_child(aus)
	await process_frame
	await tipp(aus)
	pruefe(z.klicks.size() == 1 and getan[0] == 1, "abgeschalteter Knopf klickt nicht (%d)" % z.klicks.size())
	print("KLICK78520 %d Fehler" % fehler)
	quit(1 if fehler else 0)
