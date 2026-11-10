# 527 (Abgleich 512): Tempo aus dem Menue System wirkt im Kampf (Engine.time_scale = 1 / Bedienung.tempo_faktor), nach dem Kampf
# wieder 1; Normal lässt die Uhr in Ruhe. Ohne Bild. Aufruf: im Ordner godot mit -s res://tests/tempo_527.gd
extends SceneTree
const Kampfort = preload("res://kampf/kampfort.gd")
func _init() -> void:
	_lauf.call_deferred()
func _lauf() -> void:
	var f := 0
	for i in 3:
		Bedienung.tempo = i
		print("Stufe %d Faktor %.2f" % [i, Bedienung.tempo_faktor()])
	Bedienung.tempo = 1
	var k = Kampfort.new()
	k.tempo = 1.35
	k._tempo_setzen()
	print("time_scale im Kampf %.3f" % Engine.time_scale)
	if absf(Engine.time_scale - 1.0 / 1.35) > 0.001: f += 1
	root.add_child(k)
	for i in 5:
		await process_frame
	print("time_scale danach %.3f, Kampfort weg %s" % [Engine.time_scale, not is_instance_valid(k)])
	if Engine.time_scale != 1.0: f += 1
	var k2 = Kampfort.new()
	k2._tempo_setzen()
	if Engine.time_scale != 1.0 or k2._tempo_an: f += 1
	k2.free()
	print("TEMPO 527 %s" % ("ok" if f == 0 else "FEHLER %d" % f))
	quit(f)
