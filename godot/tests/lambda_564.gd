# 564 (Chef 04.11., 17:06, Build 257, Testreiter „Seit Start, Fehler“: viermal „Lambda capture at index 0 was freed. Passed null
# instead.“, im MARS-Probekampf): ein Befehlsknopf mit Erklärung (536, langes Drücken) startet beim Drücken einen Zeitgeber, der den
# Knopf festhielt; ein kurzer Druck baut die Knöpfe neu (der alte wird freigegeben), bevor der Zeitgeber abläuft. Der Test drückt
# jeden Knopf mit Erklärung kurz, gibt ihn frei und wartet die Zeit des langen Drückens ab; Godot meldet dann die Zeile oder nicht.
# Aufruf: godot --headless --path godot -s res://tests/lambda_564.gd; richtig: Knöpfe > 0 (Exit 0) und keine Zeile „Lambda capture“
extends SceneTree

const Probe = preload("res://kampf/probe.gd")


func _initialize() -> void:
	_alle.call_deferred()


func _alle() -> void:
	var p = Probe.new()
	p.hero_cls = "CLERIC"
	p.merc_cls = "FIGHTER"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(5)
	await process_frame
	var k = p.fight
	var t0 := Time.get_ticks_msec()
	var knoepfe := []
	while Time.get_ticks_msec() - t0 < 30000 and knoepfe.is_empty():
		await process_frame
		for b in k.ui.find_children("*", "Button", true, false):
			if b.visible and not b.button_down.get_connections().is_empty():
				knoepfe.append(b)
	print("564 Knöpfe mit Erklärung: %d" % knoepfe.size())
	for b in knoepfe:
		b.button_down.emit()
		b.free()
	await create_timer(1.5).timeout
	print("564 fertig")
	quit(0 if not knoepfe.is_empty() else 1)
