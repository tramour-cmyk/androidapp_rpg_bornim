extends SceneTree
# 1694: Radius des Griffs am Griffpunkt je Gegenstand (Griff.schaft), freier Griff lo..hi; zum Einordnen der Fehler in griff_alle_1694
#   MESS=1694 godot --headless --path . -s res://tests/griff_radius_1694.gd
func _initialize() -> void:
	for f in DirAccess.get_files_at("res://daten/waffen/"):
		if not f.ends_with(".bin") or f.begins_with("quiver") or f.contains("shield"): continue
		var id := f.get_basename()
		var d := Gebiet.lade_glb("res://daten/waffen/" + f)
		if d == null: continue
		var h := Halt.gegenstand(id)
		var sch := Griff.schaft(d, h)
		print("RADIUS1694 %-44s Radius %.1f cm, Durchmesser %.1f cm, freier Griff %.1f bis %.1f cm" % [id, 100.0 * Griff.radius(d, h), 200.0 * Griff.radius(d, h), 100.0 * float(sch.lo), 100.0 * float(sch.hi)])
		d.free()
	quit(0)
