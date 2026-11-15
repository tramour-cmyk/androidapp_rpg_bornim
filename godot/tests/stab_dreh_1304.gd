extends SceneTree
# 1304 (Chef 15.11., 17:13, Reiter Ausrüstung: „der Stab, den er in der Hand hält, der ständig rauf runter zuckt … so 10, 15 cm“):
# Ursache nachgestellt ohne Modell: im Stehen setzt tragen.gd den Stabfuß neu (mit Hub 7 cm), sobald er 5 cm neben der Faust steht;
# der Drehteller dreht die Figur (eine Runde in 6 s), die Faust wandert um die Achse, der Fuß bleibt in der Welt stehen und wird alle
# paar Bilder mit Hub umgesetzt. Mit mitfuehren (Drehteller) folgt der Fuß der Faust am Boden, ohne Hub; im Spiel bleibt das Umsetzen.
# Ausgabe „STABDREH1304 <n> Fehler“.   ~/godot/godot --headless --path . -s res://tests/stab_dreh_1304.gd

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut    " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

# 6 s Drehteller (60 Bilder je Sekunde), Faust 0,3 m neben der Achse in Hüfthöhe; höchster Hub des Fußes über dem Boden, Zahl der Hübe
func dreh(mit: bool) -> Array:
	var modell := Node3D.new()
	root.add_child(modell)
	var t := Tragen.new("stab", null, modell)
	t.mitfuehren = mit
	var hub := 0.0
	var huebe := 0
	var oben := false
	for i in 360:
		var w := TAU * i / 360.0
		var P := Vector3(cos(w), 0, sin(w)) * 0.3 + Vector3(0, 1.0, 0)
		var vorn := Vector3(-sin(w), 0, cos(w))
		var ac := Vector3(cos(w), 0, sin(w))
		t._stab(Transform3D.IDENTITY, P, vorn, ac, false, 1.0 / 60.0)
		var h: float = t.stab_fuss.y - modell.global_position.y
		hub = maxf(hub, h)
		if h > 0.01 and not oben: huebe += 1
		oben = h > 0.01
	modell.free()
	t.free()
	return [hub, huebe]

func _lauf() -> void:
	var ohne := dreh(false)
	print("im Spiel (Umsetzen): Hub höchstens %.0f cm, %d Hübe in einer Runde" % [ohne[0] * 100, ohne[1]])
	pruefe(ohne[1] > 3, "ohne mitfuehren setzt der Fuß beim Drehen um (so sah der Chef das Zucken): %d Hübe" % ohne[1])
	var mit := dreh(true)
	pruefe(mit[0] < 0.001 and mit[1] == 0, "Drehteller (mitfuehren): kein Hub (%.1f cm, %d Hübe)" % [mit[0] * 100, mit[1]])
	print("STABDREH1304 %d Fehler" % fehler)
	quit(1 if fehler else 0)
