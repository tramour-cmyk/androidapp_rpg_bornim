# 572: Effektprobe lässt sich übersetzen (ohne Bild; die Pakete fehlen außerhalb des Probeschritts)
extends SceneTree


func _init() -> void:
	var s = load("res://kampf/effektprobe.gd")
	print("effektprobe_572: ", "geladen" if s != null and s.can_instantiate() else "FEHLER")
	quit(0 if s != null and s.can_instantiate() else 1)
