extends SceneTree
# 608 (Chef 07.11., t268: „Pims Hütte am Tag, wenn sie transparent wird, weil man dahinter steht, dann geht das Licht im Haus an;
# trifft auch auf Tempel zu“): ein Haus wird durchsichtig (gebiet.gd blende_gruppen: zweiter und dritter Durchgang als Kette); seine
# Fenster leuchten dabei so wie deckend: am Tag nicht, nachts ja, auch wenn es vorher zu einer anderen Tageszeit durchsichtig war.
# Ohne Bild, ohne Modell. Aufruf: im Ordner godot mit -s res://tests/glas_608.gd

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

# der hellste Glanz im sichtbaren Durchgang: deckend der erste, durchsichtig die Kette dahinter
func glanz(m: ShaderMaterial) -> float:
	var g := 0.0
	var x := m.next_pass as ShaderMaterial
	while x:
		g = maxf(g, float(x.get_shader_parameter("glow")))
		x = x.next_pass as ShaderMaterial
	return g if m.next_pass else float(m.get_shader_parameter("glow"))

func durchsichtig(g: Gebiet, an: bool) -> void:
	g.gruppen["Gruppe_Haus"]["ziel"] = Gebiet.DURCH_A if an else 1.0
	for i in 30: g.blende_gruppen(1.0 / 30.0)

func _lauf() -> void:
	if Gebiet.toon == null: Gebiet.toon = load("res://shader/toon.gdshader")   # wie Gebiet.male
	var g := Gebiet.new(Karte.lade("village"))
	var m := ShaderMaterial.new()
	m.shader = load("res://shader/toon.gdshader")
	g.glas.append(m)
	g.gruppen["Gruppe_Haus"] = {"mats": [{"m": m, "eigen": false, "kette": null}], "a": 1.0, "ziel": 1.0}
	g.nacht(1.0)
	durchsichtig(g, true)
	pruefe(glanz(m) > 0.4, "nachts durchsichtig: Fenster leuchten (%.2f)" % glanz(m))
	durchsichtig(g, false)
	g.nacht(0.0)
	pruefe(glanz(m) < 0.01, "am Tag deckend: Fenster dunkel (%.2f)" % glanz(m))
	durchsichtig(g, true)
	pruefe(glanz(m) < 0.01, "am Tag durchsichtig: Fenster dunkel (%.2f)" % glanz(m))
	g.nacht(1.0)
	for i in 3: g.blende_gruppen(1.0 / 30.0)
	pruefe(glanz(m) > 0.4, "Nacht bricht an, waehrend es durchsichtig ist: Fenster leuchten (%.2f)" % glanz(m))
	g.free()
	print("GLAS608 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
