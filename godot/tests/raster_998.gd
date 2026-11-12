extends SceneTree
# 998 (Tuffy 620.2c; 229.3, Chef 20.10. „Raster schwer erkennbar“; alt SkirmishScreen.kt 1882): das Kampfraster mit dunklem Grund
# (Schwarz 0,18) unter einer kräftigen Goldlinie (0,9, 2 dp) und dunklem Saum; aus, ohne Raster nichts davon.
# Aufruf: im Ordner godot mit -s res://tests/raster_998.gd
const Aufruf = preload("res://kampf/aufruf.gd")

func _initialize() -> void: _lauf.call_deferred()

## Farben der Ringe im letzten Bild, auf zwei Stellen gerundet
func _farben(ui) -> Dictionary:
	var out := {}
	var mesh: ImmediateMesh = ui._ring_mesh
	if mesh == null: return out
	for i in mesh.get_surface_count():
		var arr := mesh.surface_get_arrays(i)
		for c in arr[Mesh.ARRAY_COLOR]:
			out["%.2f %.2f %.2f %.2f" % [c.r, c.g, c.b, c.a]] = true
	return out

func _lauf() -> void:
	var f := 0
	var tab = Tabellen.lade()     # 870.6: statt regeln/tabellen.json (Build 278)
	var held: Dictionary = tab.probe.FIGHTER.hero
	var a = Aufruf.new()
	root.add_child(a)
	if not a.starte("WOLVES", held.hero, null, "wald", "tag", 2, int(held.hp), -1, 7, Callable(), {"eroeffnung": "HERO_FIRST"}):
		print("FEHLER nicht gestartet"); quit(1); return
	for i in 5: await process_frame
	var ui = a.kampf.ui
	var gold: Color = Color(ui.GOLD, 0.9)
	var g := "%.2f %.2f %.2f %.2f" % [gold.r, gold.g, gold.b, gold.a]
	var grund := "0.00 0.00 0.00 0.18"
	for an in [true, false]:
		ui.grid_on = an
		ui.overlay.queue_redraw()
		await process_frame
		await process_frame
		var c := _farben(ui)
		var gut: bool = (c.has(g) and c.has(grund)) if an else not c.has(grund)
		print("Raster %s: Gold 0,9 %s, Grund 0,18 %s %s" % ["an" if an else "aus", c.has(g), c.has(grund), "gut" if gut else "FALSCH"])
		if not gut: f += 1
	a.kampf.queue_free()
	a.queue_free()
	await process_frame
	print("RASTER998 %s" % ("ok" if f == 0 else "FEHLER %d" % f))
	quit(f)
