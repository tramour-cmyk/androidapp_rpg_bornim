extends SceneTree
# 612 (Chef 07.11., t268; 12.11., 08:28): Dorf Sued. Korn schreibt Tiefe und markiert Schablone 1 (sonst malt sich das Gras hinter
# dem Feld ueber das Korn, „Wackelgras“); dorf.py: drei Heuhaufen in drei Ansichten statt Kugel mit Stab, Gartenzaun an der Kante
# zum Beet (MapTownIso.fenceSpot), Beeterde ueber die ganze Kachel. Ohne Bildbefehl.
# Aufruf: im Ordner godot mit -s res://tests/dorf_sued_612.gd -> „DORFSUED612 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	var korn := Gebiet.korn_shader().code
	pruefe(not korn.contains("depth_draw_never") and korn.contains("depth_draw_opaque"), "Korn schreibt keine Tiefe")
	pruefe(korn.contains("stencil_mode write, compare_always, 1;"), "Korn ohne Schablone 1 (Tusche an jedem Halm)")
	var gras := (load("res://shader/halm.gdshader") as Shader).code
	pruefe(gras.contains("depth_draw_never;"), "halm.gdshader geaendert: korn_shader ersetzt depth_draw_never nicht mehr")
	var sp := FileAccess.get_file_as_string("res://skripte/gebiet.gd")
	pruefe(sp.contains("korn_shader() if korn > 0.5"), "halm_netz nimmt fuer das Korn nicht korn_shader")
	# drei Heuhaufen im Sueden: verschiedene Ansichten (dorf.py: Reihenfolge der Heukacheln % 3)
	var k := Karte.lade("village", {})
	var heu: Array[Vector2i] = []
	for y in k.hoehe:
		for x in k.breite:
			if k.zeichen(Vector2i(x, y)) == "y": heu.append(Vector2i(x, y))
	pruefe(heu.size() >= 3, "weniger als drei Heuhaufen im Dorf")
	for i in heu.size() - 1:
		if (heu[i] - heu[i + 1]).length() < 1.5: pruefe(i % 3 != (i + 1) % 3, "zwei gleiche Heuhaufen nebeneinander")
	var py := FileAccess.get_file_as_string("res://../tools/blender348/v3/dorf.py")
	if py != "":
		pruefe(py.contains("HEU_KACHELN.index((c, r)) % 3"), "dorf.py: Heu ohne drei Ansichten")
		pruefe(not py.contains("box(DORF, (p.x - 2, p.y - 2, 60), (p.x + 2, p.y + 2, 140), W1)"), "dorf.py: Stab durch den Heuhaufen wieder da")
		pruefe(py.contains("q = zaun_pos(c, r)"), "dorf.py: Zaun wieder in der Kachelmitte (Grasstreifen vor dem Beet)")
		pruefe(py.contains("box(DORF, (p.x - TS / 2, p.y - TS / 2, 0), (p.x + TS / 2, p.y + TS / 2, 3)"), "dorf.py: Beeterde nicht ueber die ganze Kachel")
	print("DORFSUED612 %d Fehler" % fehler)
	quit(1 if fehler else 0)
