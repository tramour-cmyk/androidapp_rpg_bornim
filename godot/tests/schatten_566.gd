extends SceneTree
# 566 (Chef 04.11., 17:15, Build 257: „Beim Goblin steht in den Schatten, aber er schaut nicht aus, als würde er im Schatten stehen“):
# am echten Kampfort, ohne Bild: geht ein Goblin-Späher „In den Schatten“ (Mars hidden), steht das in jeder Meldung (hidden), die
# Figur wird blass (Raster weg = IM_SCHATTEN, Bodenschatten ebenso) und an seinem nächsten Zug wieder ganz sichtbar.
# Aufruf: im Ordner godot mit -s res://tests/schatten_566.gd   (Exit 0 = gut)

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Kampfort = preload("res://kampf/kampfort.gd")
const Aufruf = preload("res://kampf/aufruf.gd")
const Figur = preload("res://kampf/figur.gd")

var fehler := 0


func _initialize() -> void:
	_lauf.call_deferred()


func _pruef(was: String, gut: bool, info := "") -> void:
	print(("gut " if gut else "FALSCH ") + was + ("" if info == "" else ": " + info))
	if not gut:
		fehler += 1


func _weg(fig) -> float:
	var w := 0.0
	for m in fig.mats:
		w = maxf(w, float(m.get_shader_parameter("weg")))
	return w


func _lauf() -> void:
	var tables: Dictionary = Tabellen.lade()
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var monsters := {}
	for m in tables.monsters:
		monsters[m.id] = m
	var hs: Dictionary = tables.probe["FIGHTER"].hero
	var party := [Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), hs.hero, int(hs.hp), hs.hero.second, skills)]
	var foes: Array = Aufruf.gegner("SCOUTS", monsters, Wuerfel.new(3))
	var kf = Kampfort.new()
	kf.setup(party, foes, tables, {"potion": 0}, func(_o): pass, 3, {})
	var gemeldet := []
	var vorher: Callable = kf.mars.listener
	kf.mars.listener = func(e):
		gemeldet.append(e)
		vorher.call(e)
	root.add_child(kf)
	await process_frame
	kf.set_process(false)     # die Meldungen des laufenden Kampfs nicht abspielen, nur die der Probe
	var f = foes[0]
	var fig = kf.figures[f.id]
	_pruef("Figur hat Stoffe", fig.mats.size() > 0, "%d" % fig.mats.size())
	f.hidden = true
	kf.mars._say("Probe", f.id)
	var e: Dictionary = gemeldet.back()
	_pruef("Meldung trägt hidden", e.has("hidden") and e.hidden.has(f.id))
	_pruef("Stand trägt hidden", kf._state_now().get("hidden", {}).has(f.id))
	kf._play_say(e)
	await create_timer(0.7).timeout
	_pruef("im Schatten blass", absf(_weg(fig) - Figur.IM_SCHATTEN) < 0.02, "weg %.2f" % _weg(fig))
	var sh := fig.get_node_or_null("Bodenschatten") as MeshInstance3D
	if sh and sh.material_override is ShaderMaterial:
		var d := float((sh.material_override as ShaderMaterial).get_shader_parameter("dichte"))
		_pruef("Bodenschatten blass", d < 0.4, "dichte %.2f" % d)
	f.hidden = false
	kf.mars._say("Probe", f.id)
	kf._play_say(gemeldet.back())
	await create_timer(0.7).timeout
	_pruef("zurück ganz sichtbar", _weg(fig) < 0.02, "weg %.2f" % _weg(fig))
	print("SCHATTEN566 %d Fehler" % fehler)
	quit(1 if fehler else 0)
