# 595 (Chef 05.11., 19:2x, Build 266: „Säureschnecke – … Ruheanimationen?, Atmen?“): Ruhebewegungen der Kaufgegner ohne „Lefzen“
# im Kampf. Ohne Bild und ohne Kaufmodell: eine Figur mit den Bewegungsnamen der Quelle (kauftier.py „namen“), die Uhr des Kampforts
# läuft in Schritten von 0,1 s über 120 s, nach jeder Geste steht die Figur wieder in der Grundschleife (sonst spielt das die Bewegung).
# Prüft: Egel (Stehen, Umsehen, Drohen) wechselt zwischen beiden Gesten, nie zweimal dieselbe; Schnecke (Stehen, Umsehen) blickt immer
# wieder um, nicht nur einmal; ein Wolf ohne „Umsehen“ spielt nur seine bisherigen; wer Ziel eines Hiebs ist (bedroht), beginnt keine.
# Run: godot --headless --path godot -s res://tests/ruhe_kauf_595.gd   (Exit 0 = alles gehalten, 1 sonst)
extends SceneTree

const Figur = preload("res://kampf/figur.gd")
var fehler := 0


func _initialize() -> void:
	_run.call_deferred()


func _figur(art: String, koerper: String, namen: Array) -> Array:
	var f = Figur.new()
	f.fighter = {"id": "%s_1" % art, "monster": {"id": koerper}}
	f._art_fest = art
	f._art_da = true
	f.process_mode = Node.PROCESS_MODE_DISABLED     # nur _ruhebewegung, ohne Modell
	root.add_child(f)     # scharren_name fragt die Kamera des Viewports
	var ap := AnimationPlayer.new()
	var lib := AnimationLibrary.new()
	for n in namen:
		var a := Animation.new()
		a.length = 1.0
		lib.add_animation(n, a)
	ap.add_animation_library("", lib)
	root.add_child(ap)
	f.anim = ap
	var gs := GDScript.new()
	gs.source_code = "extends Node\nvar clock_ms := 0\n"
	gs.reload()
	var k := Node.new()
	k.set_script(gs)
	root.add_child(k)
	f.kampfort = k
	ap.play("Stehen")
	return [f, k]


func _lauf(f, k, bedroht := false) -> Array:
	var gesten := []
	for t in range(0, 120000, 100):
		k.clock_ms = t
		if bedroht:
			f.bedroht_bis = t + 1000
		f.anim.play("Stehen")
		f._ruhebewegung()
		var jetzt := String(f.anim.current_animation)
		if jetzt != "Stehen":
			gesten.append(jetzt)
	return gesten


func _pruef(ok: bool, text: String) -> void:
	print(("ok   " if ok else "FEHLER ") + text)
	if not ok:
		fehler += 1


func _run() -> void:
	await process_frame
	var e := _figur("kauf_egel", "stirge", ["Stehen", "Umsehen", "Drohen", "Gehen", "Biss", "Treffer", "Tod"])
	var g: Array = _lauf(e[0], e[1])
	var doppelt := 0
	for i in range(1, g.size()):
		if g[i] == g[i - 1]:
			doppelt += 1
	_pruef(g.count("Umsehen") >= 3 and g.count("Drohen") >= 3 and doppelt == 0,
		"Egel: %d Gesten in 120 s, Umsehen %d, Drohen %d, zweimal dieselbe %d" % [g.size(), g.count("Umsehen"), g.count("Drohen"), doppelt])
	var s := _figur("kauf_schnecke", "ochre_jelly", ["Stehen", "Umsehen", "Gehen", "Biss", "Spucken", "Treffer", "Tod"])
	g = _lauf(s[0], s[1])
	_pruef(g.count("Umsehen") >= 6 and g.size() == g.count("Umsehen"), "Schnecke: %d Gesten in 120 s, Umsehen %d" % [g.size(), g.count("Umsehen")])
	var w := _figur("kaufwolf", "wolf", ["Stehen", "Lefzen", "Scharren", "Knurren", "Hocke", "Drohen", "Heulen"])
	g = _lauf(w[0], w[1])
	var fremd: Array = g.filter(func(x): return not x in ["Lefzen", "Scharren", "Knurren"])
	_pruef(g.size() >= 6 and fremd.is_empty(), "Wolf: %d Gesten, nur Lefzen, Scharren, Knurren (fremd: %s)" % [g.size(), fremd])
	var b := _figur("kauf_egel", "stirge", ["Stehen", "Umsehen", "Drohen"])
	g = _lauf(b[0], b[1], true)
	_pruef(g.is_empty(), "Egel als Ziel eines Hiebs: %d Gesten" % g.size())
	print("RUHE595 %s" % ("ok" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler else 0)
