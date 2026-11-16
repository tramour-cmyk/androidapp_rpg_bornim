extends SceneTree
# 560 (Chef 08.11., 20:47, t270.7: „Grimmzahn dreht auf der Stelle wie ein Zinnsoldat“): wer auf der Karte wendet, tritt dabei (Gehen
# auf der Stelle, Streuner.TRITT_TEMPO). Getragen wird die Kampffigur (kampf/figur.gd) von einem Knoten, der sich selbst dreht und
# bewegt (streuner.gd, leute.gd Grimmzahn); die Figur selbst steht in ihm still. Geprueft wird in echten Takten (Traeger vor Figur, wie
# im Baum), wie schnell „Gehen“ dann wirklich laeuft. Ohne Modell.
# Aufruf: im Ordner godot mit --headless -s res://tests/tritte_560.gd -> „TRITTE560 gut“ oder „n Fehler“
const Figur = preload("res://kampf/figur.gd")

class Traeger:
	extends Node3D
	var fig
	var tempo := 0.6
	func _process(dt: float) -> void:
		rotation.y += 2.5 * dt   # wendet wie Streuner.DREH
		if fig.anim.current_animation != "Gehen": fig.anim.play("Gehen", 0.0)
		fig.anim.speed_scale = tempo

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var t := Traeger.new()
	root.add_child(t)
	var f = Figur.new()
	f.kampfort = Streuner.Stub.new(null)   # auf der Karte wie streuner.gd und leute.gd (Grimmzahn)
	f.model = Node3D.new()
	f.add_child(f.model)
	var ap := AnimationPlayer.new()
	var lib := AnimationLibrary.new()
	for n in ["Gehen", "Stehen"]:
		var a := Animation.new(); a.length = 1.0; a.loop_mode = Animation.LOOP_LINEAR
		lib.add_animation(n, a)
	ap.add_animation_library("", lib)
	f.model.add_child(ap)
	f.anim = ap
	var w := []
	for i in 31: w.append([0.0, 0.04 * i])   # 1,2 m in 1 s Gehen
	f.weg = {"Gehen": w}
	t.fig = f
	t.add_child(f)
	f.set_process(true)
	for i in 5: await process_frame
	var p0: float = ap.current_animation_position
	var t0 := Time.get_ticks_usec()
	for i in 30: await process_frame
	var lief: float = fposmod(ap.current_animation_position - p0, 1.0)
	var zeit := (Time.get_ticks_usec() - t0) / 1e6
	var soll := 0.6 * zeit
	print("Gehen beim Wenden: %.3f s Bewegung in %.3f s (soll etwa %.3f, Tempo %.2f)" % [lief, zeit, soll, ap.speed_scale])
	pruefe(lief >= 0.7 * soll, "Gehen laeuft beim Wenden auf der Stelle mit TRITT_TEMPO, nicht gebremst (Figur steht im Traeger still)")
	print("TRITTE560 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
