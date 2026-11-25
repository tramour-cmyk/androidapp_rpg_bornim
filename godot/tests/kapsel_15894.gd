# 1589.4 (Chef 25.11., 09:55): je Art der Kasten der Netze in Ruhe am Boden (figur.footprint) und die Kapsel daraus (figur.umriss_kapsel:
# Halbmesser halbe kurze Seite, Länge lang minus kurz, Achse längs der langen Seite, Mitte des Kastens). Druckt je Art eine Zeile
# KAPSEL <Art> kasten x0 z0 x1 z1 r laenge achse; mit KAPSEL_BILD=<pfad.png> zusätzlich ein Bild von oben (Kasten und Kapsel je Art).
# Aufruf: godot --headless --path godot -s res://tests/kapsel_15894.gd
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const KAEMPFE := ["RATS", "WOLVES", "GRIMM", "SPIDER", "SCOUT", "GOBLINS", "KOBOLDS", "SHAMANS", "BOARS", "CENTIPEDES",
	"LEECHES", "SLUGS", "BATS", "SKELETONS", "WIEDERGAENGER3", "GRABHUNDE", "KROGG", "GRAK"]

var zeilen := []


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	var gesehen := {}
	for k in KAEMPFE:
		var p = Probe.new()
		p.hero_cls = "FIGHTER"
		p.merc_cls = "CLERIC"
		p.foe = k
		root.add_child(p)
		await process_frame
		p._start(7)
		for i in 21:
			await process_frame
		var kf = p.fight
		if kf != null:
			for o in kf.figures.values():
				var art: String = String(o.fighter.monster.get("id", "")) if o.fighter.monster != null else ("held" if o.fighter.id == "hero" else "soeldner")
				if gesehen.has(art):
					continue
				gesehen[art] = true
				var b: AABB = o.footprint()
				var r: float = o.umriss_r()
				var l: float = o.kapsel_laenge()
				var z := [art, b.position.x, b.position.z, b.end.x, b.end.z, r, l, "x" if b.size.x >= b.size.z else "z"]
				zeilen.append(z)
				print("KAPSEL %s kasten %.2f %.2f %.2f %.2f (%.2f x %.2f) Maßstab %.2f r %.2f laenge %.2f achse %s" % [art, z[1], z[2], z[3], z[4], b.size.x, b.size.z, o.scale.x, r, l, z[7]])
			kf.queue_free()
		p.queue_free()
		for i in 3:
			await process_frame
	quit(0)
