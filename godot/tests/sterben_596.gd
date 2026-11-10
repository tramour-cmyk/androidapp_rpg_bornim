extends SceneTree
# 596 (Chef 05.11., t266: Wolf stirbt „immer gleich und auf die gleiche Seite … zumindest an der Achse spiegeln“): Figur.sterbe_spiegeln
# spiegelt quer zur Blickrichtung (Basis −x, y, z), die Größe (scale.x, von figur.gd gelesen) bleibt positiv, zweimal spiegelt nicht
# zurück. Ohne Bild, Sekunden. Aufruf: im Ordner godot mit -s res://tests/sterben_596.gd   (Exit 0 = gut)

const Figur = preload("res://kampf/figur.gd")


func _initialize() -> void:
	var f := 0
	var fig = Figur.new()
	var m := Node3D.new()
	m.scale = Vector3.ONE * 0.8
	fig.model = m
	fig.add_child(m)
	fig.sterbe_spiegeln()
	fig.sterbe_spiegeln()
	var b: Basis = m.transform.basis
	var gut: bool = b.x.is_equal_approx(Vector3(-0.8, 0, 0)) and b.y.is_equal_approx(Vector3(0, 0.8, 0)) and b.z.is_equal_approx(Vector3(0, 0, 0.8))
	print("STERBEN596 %s Basis %s" % ["ok" if gut else "FALSCH", b])
	if not gut: f += 1
	var gross: bool = is_equal_approx(m.scale.x, 0.8)
	print("STERBEN596 %s scale.x %.2f" % ["ok" if gross else "FALSCH", m.scale.x])
	if not gross: f += 1
	if absf(Figur.TOD_BLEND - 0.25) > 0.001: f += 1
	fig.free()
	print("STERBEN596 %s" % ("gut" if f == 0 else "FALSCH %d" % f))
	quit(1 if f else 0)
