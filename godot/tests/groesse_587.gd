# 587 A (Chef 05.11.: alle Gegner im Kampfort 1,3-fach, Bosse 1,5-fach; Gegenargument Jerry: größere Tiere stehen ineinander) ohne
# Bild: je Gegnergruppe des Probekampfs (probe.gd FOES) die Aufstellung in Ruhe, Maßstab jedes Gegners und wie tief sich die Umrisse
# am Boden (figur.gd footprint, im Raum) zweier Figuren überdecken, Gegner unter sich und Gegner gegen Helden.
# Aufruf: im Ordner godot mit --fixed-fps 30 -s res://tests/groesse_587.gd (Exit 0 = keine Überdeckung über GRENZE_M)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const GRENZE_M := 0.05

var fehler := 0


func _initialize() -> void:
	_run.call_deferred()


func _boden(f) -> Rect2:
	var bb: AABB = f.global_transform * f.footprint()
	return Rect2(bb.position.x, bb.position.z, bb.size.x, bb.size.z)


func _tief(a: Rect2, b: Rect2) -> float:
	var x := minf(a.end.x, b.end.x) - maxf(a.position.x, b.position.x)
	var z := minf(a.end.y, b.end.y) - maxf(a.position.y, b.position.y)
	return minf(x, z) if x > 0.0 and z > 0.0 else 0.0


func _run() -> void:
	for foe in Probe.FOES:
		seed(3)
		var p = Probe.new()
		p.hero_cls = "FIGHTER"
		p.merc_cls = "CLERIC"
		p.foe = foe
		root.add_child(p)
		await process_frame
		p._start(3)
		for i in 45:
			await process_frame
		var kf = p.fight
		if kf == null:
			print("GROESSE587 %s kein Kampf" % foe)
			fehler += 1
			continue
		var figs: Array = kf.figures.values().filter(func(f): return f.visible and not f.down)
		var masse := []
		for f in figs:
			if f.fighter.monster != null:
				masse.append("%s %.2f" % [f.fighter.id, kf.foe_scale(f.fighter)])
		var schlimm := 0.0
		var wer := ""
		for i in figs.size():
			for j in range(i + 1, figs.size()):
				var a = figs[i]
				var b = figs[j]
				if a.fighter.monster == null and b.fighter.monster == null:
					continue
				var t := _tief(_boden(a), _boden(b))
				if t > schlimm:
					schlimm = t
					wer = "%s/%s" % [a.fighter.id, b.fighter.id]
		var gut := schlimm <= GRENZE_M
		if not gut:
			fehler += 1
		print("GROESSE587 %s %s (%s): Maßstab %s; tiefste Überdeckung %.2f m %s" % ["ok    " if gut else "FEHLER", foe, Probe.FOES[foe],
				", ".join(masse), schlimm, wer])
		kf.queue_free()
		p.queue_free()
		await process_frame
	print("GROESSE587 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
