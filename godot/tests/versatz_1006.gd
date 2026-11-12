extends SceneTree
# 1006 ohne Bild und ohne Kaufmodell: figur.gd _versatz_frei legt den Anfang der Grundschleife nie näher als VERSATZ_MIN an die Stelle
# eines anderen, der dieselbe Schleife gleich lang spielt (skelett_506 Lauf 361, 365: Skelette bei 0,38 und 0,42 s von 1,03 s).
# Nachgestellt mit den Zahlen des Laufs: zwei spielen Stehen bei 0,42 und 0,67 s, der dritte zöge 0,7889 × 1,03 s (Zufall skel1/Stehen/1).
# Aufruf: im Ordner godot mit -s res://tests/versatz_1006.gd (Exit 0 = gut)

const Figur = preload("res://kampf/figur.gd")
const LANG := 1.03

var fehler := 0


class Ort:
	var figures := {}


func _initialize() -> void:
	_lauf.call_deferred()


func _spieler(stelle: float, lang: float = LANG, nm: String = "Stehen") -> Node:
	var f = Figur.new()
	var ap := AnimationPlayer.new()
	var lib := AnimationLibrary.new()
	var an := Animation.new()
	an.length = lang
	an.loop_mode = Animation.LOOP_LINEAR
	lib.add_animation(nm, an)
	ap.add_animation_library("", lib)
	root.add_child(ap)
	ap.play(nm)
	ap.seek(stelle, true)
	f.anim = ap
	return f


func _abstand(t: float, s: float, lang: float) -> float:
	var u := absf(t - s)
	return minf(u, lang - u)


func _check(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
	print(("ok " if ok else "FEHLER ") + was)


func _lauf() -> void:
	await process_frame
	var ort := Ort.new()
	var ich = Figur.new()
	ich.kampfort = ort
	ort.figures = {"skel1": ich, "skel2": _spieler(0.42), "skel3": _spieler(0.67)}
	# Lauf 365: Zufall 0,7889 × 1,03 = 0,81 s, gegen 0,42 nur dann frei, wenn der Abstand reicht; das Messbild zeigte 0,04 s
	for t0 in [0.40, 0.44, 0.7889 * LANG, 0.66, 0.0]:
		var t: float = ich._versatz_frei("Stehen", LANG, t0)
		var d := minf(_abstand(t, 0.42, LANG), _abstand(t, 0.67, LANG))
		_check(d >= Figur.VERSATZ_MIN * LANG - 0.001, "Versatz %.2f → %.2f s, Abstand zum nächsten %.2f s (mindestens %.2f)" % [t0, t, d, Figur.VERSATZ_MIN * LANG])
		_check(t >= 0.0 and t < LANG, "Versatz %.2f s in der Schleife" % t)
	# frei bleibt frei (kein Eingriff, wo der Zufall schon trennt)
	_check(is_equal_approx(ich._versatz_frei("Stehen", LANG, 0.95), 0.95), "0,95 s bleibt (weit genug von 0,42 und 0,67)")
	# andere Schleife oder andere Länge zählt nicht
	ort.figures = {"skel1": ich, "wolf": _spieler(0.42, 2.0), "hocke": _spieler(0.42, LANG, "Hocke")}
	_check(is_equal_approx(ich._versatz_frei("Stehen", LANG, 0.43), 0.43), "andere Länge oder andere Schleife: 0,43 s bleibt")
	# wer liegt, zählt nicht
	var tot = _spieler(0.42)
	tot.down = true
	ort.figures = {"skel1": ich, "tot": tot}
	_check(is_equal_approx(ich._versatz_frei("Stehen", LANG, 0.43), 0.43), "Liegender zählt nicht: 0,43 s bleibt")
	# ohne Kampfort wie bisher
	var los = Figur.new()
	_check(is_equal_approx(los._versatz_frei("Stehen", LANG, 0.43), 0.43), "ohne Kampfort: 0,43 s bleibt")
	print("VERSATZ1006 %s" % ("0 Fehler" if fehler == 0 else "%d FEHLER" % fehler))
	quit(1 if fehler > 0 else 0)
