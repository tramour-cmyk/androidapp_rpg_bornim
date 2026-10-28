extends SceneTree
# 348.6 ohne Bild: Ausweichen wie alt (Game.makeWay, 92; Chef 28.10., 16:12): wer geschoben wird, tritt quer zum Weg zur Seite, sonst
# voran; eine Wache auf ihrer Runde nicht; Rind weg, suedlich des Flusses eine Ziege. Aufruf: im Ordner godot mit
# -s res://tests/ausweichen_test.gd

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var fehler := 0
	var k := Karte.lade("village")
	var held := Node3D.new()
	root.add_child(held)
	held.position = k.kachel_pos(Vector2i(19, 13))   # Dorfplatz, der Held schiebt nach Osten
	var eltern := Node3D.new()   # nicht im Baum: kein _ready, kein Modell noetig
	var l := Leute.new(k, {"id": "probe", "x": 20, "y": 13}, held)
	l.da = true
	eltern.add_child(l)
	if not l.weicht(): fehler += 1; print("FEHLER weicht nicht")
	if not l.weiche(Vector2i(1, 0)): fehler += 1; print("FEHLER kein Platz")
	print("Ausweichen: von ", l.kachel, " nach ", l.ziel, ", wartet ", l.warte)
	if l.ziel not in [Vector2i(20, 12), Vector2i(20, 14), Vector2i(21, 13)]: fehler += 1; print("FEHLER Ziel ", l.ziel)
	if l.ziel == Vector2i(21, 13) and (k.begehbar(Vector2i(20, 12)) or k.begehbar(Vector2i(20, 14))): fehler += 1; print("FEHLER voran statt zur Seite")
	var wache := Leute.new(k, {"id": "wache", "x": 20, "y": 14, "runde": [[20, 14], [22, 14]]}, held)
	wache.da = true
	if wache.weicht(): fehler += 1; print("FEHLER Wache weicht")
	var tiere: Array = Leute.DORFTIERE["village"].map(func(p): return p[0])
	var sued: Array = Leute.DORFTIERE["village"].filter(func(p): return int(p[2]) >= 27)
	if "rind" in tiere or sued.size() > 1: fehler += 1; print("FEHLER Tiere im Süden: ", sued)
	eltern.free(); wache.free()
	print("AUSWEICHEN %d Fehler" % fehler)
	quit(1 if fehler else 0)
