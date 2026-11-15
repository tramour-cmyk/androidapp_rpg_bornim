extends SceneTree
# 930.7 (DESIGN-GLUT.md 7, 8; Bauplan 10 Stufe 2): Logik hinter Bedienung und Kerbmarken ohne Bild: Kerben je Meldung (kerbe.gd
# marken, bild, mars.gd _say „gl“) durch einen Zug mit Vertiefen und Haltung, Antwort, Verfallen; Vorschau der Schlagfolge
# (kerbe.gd vorschau); Daumenmenü (kampf/kerbbild.gd _symbol, plan): je Tipp wandert eine Kerbe, eine Art der Haltung, ohne Wahl der
# Vorschlag (AUTO). Bild und Tippen durch die Oberfläche zeigt der Film tests/film_kerbe_9307.gd.
# Run: godot --headless --path godot -s res://tests/kerbe_bedienung_9307.gd   (Exit 0 = alle gut)

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Kerbe = preload("res://regeln/kerbe.gd")
const Brs = preload("res://regeln/brs.gd")
const Kerbbild = preload("res://kampf/kerbbild.gd")

var tab: Dictionary
var skills := {}
var monsters := {}
var fehler := 0
var gut := 0
var K0 := {}


func _initialize() -> void:
	tab = Tabellen.lade()
	for s in tab.skills:
		skills[s.id] = s
	for mo in tab.monsters:
		monsters[mo.id] = mo
	K0 = (Brs.lade()["kampf"] as Dictionary).duplicate()
	_marken()
	_verfallen()
	_vorschau()
	_daumen()
	_treffer(-1)
	print("KERBE9307B %s: %d gut, %d falsch" % ["gut" if fehler == 0 else "FALSCH", gut, fehler])
	quit(0 if fehler == 0 else 1)


func ok(was: String, bed: bool, wie: String) -> void:
	if bed:
		gut += 1
		print("gut %s: %s" % [was, wie])
	else:
		fehler += 1
		print("FALSCH %s: %s" % [was, wie])


func _treffer(a: int) -> void:
	var k: Dictionary = Brs.lade()["kampf"]
	k.trefferchance_min = K0.trefferchance_min if a < 0 else (100 if a == 1 else 0)
	k.trefferchance_max = K0.trefferchance_max if a < 0 else (100 if a == 1 else 0)


func _held() -> Mars.Fighter:
	var W := Brs.lade()
	var k := {"stufe": 2, "werte": {"kraft": 5, "gewandtheit": 4, "zaehigkeit": 5, "verstand": 3, "wille": 4, "wahrnehmung": 4},
		"fert": {"Einhänder": 10, "Ausweichen": 10}, "herkunft": "Wachsoldat", "ruestung": {"art": "keine"}, "schild": {},
		"faehigkeiten": [], "waffe": {"gruppe": "Einhänder", "art": W.waffen["Einhänder"].art}, "leben": 500, "mana": 40, "volk": "Mensch"}
	var sheet: Dictionary = (tab.probe.FIGHTER.hero.hero as Dictionary).duplicate(true)
	sheet.main = {"id": "x", "de": "x", "en": "x", "atk": 0, "dmg": [1, 4, 0], "ranged": false, "reach": false, "two": false, "type": "SLASHING"}
	sheet.second = null
	sheet.level = 2
	sheet.skills = []
	sheet.sp = 0
	sheet.sp_max = 0
	sheet.schild = ""
	sheet.brs = k
	return Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 500, null, skills)


func _kampf(h) -> Mars:
	var foes := []
	for i in 2:
		var mo: Dictionary = (monsters["wolf"] as Dictionary).duplicate(true)
		mo.erase("special")
		foes.append(Mars.monster_fighter("g%d" % i, Vector2i(0, i), mo, 1))
	var m := Mars.new([h], foes, tab, Wuerfel.new(7), Wuerfel.new(8), 0, false, "NORMAL")
	m.kerbe = true
	m.gk = Kerbe.new(m)
	m.gk.react = func(_t, _i) -> String: return Mars.NONE
	m.gk._einrichten()
	m.gk.runde = 1
	for f in foes:
		f.max_hp = 999
		f.hp = 999
		f.gl.ab = Kerbe.NAH
		f.gl.plan = {"gross": false, "art": "schlag", "zeigt_gross": false, "ziel": "hero"}
	return m


## Kerben der Meldung mit Stichwort [cue] im Log (die letzte)
func _gl(log: Array, cue: String) -> Array:
	var out := []
	for e in log:
		if e.cue == cue and e.has("gl"):
			out = e.gl.get("hero", {}).get("m", [])
	return out


func _marken() -> void:
	var h := _held()
	var m := _kampf(h)
	ok("Kerben", m.gk.zug_beginnen(h) and h.gl.marken == ["frei", "frei", "frei"], "Zugbeginn: drei glimmen %s" % str(h.gl.marken))
	_treffer(1)
	m.gk.held_zug(h, {"tun": Kerbe.WAFFE, "ziel": "g0", "vertiefen": 1, "haltung": Kerbe.GEGENSCHLAG})
	var log := m._take_log()
	var beim := _gl(log, "KERBE_VERTIEFEN")
	ok("Kerben", beim == ["tun", "tief", "halt"], "beim Vertiefen: Tun, vertieft, Rest schon in der Haltung %s" % str(beim))
	var hb: Dictionary = m.gk.bild().get("hero", {})
	ok("Kerben", hb.get("m", []) == ["geschlagen", "geschlagen", "halt"] and hb.get("h", "") == Kerbe.GEGENSCHLAG,
		"nach dem Zug: zwei verbraucht, eine Gegenschlag %s %s" % [str(hb.get("m")), hb.get("h")])
	var halt_cue := _gl(log, "KERBE_HALTUNG_GEGENSCHLAG")
	ok("Kerben", halt_cue == ["geschlagen", "geschlagen", "halt"], "die Meldung „Haltung“ trägt die Kerben mit %s" % str(halt_cue))
	m.gk._gegenschlag(h, m.find("g0"))
	var gs := _gl(m._take_log(), "KERBE_GEGENSCHLAG")
	ok("Kerben", gs == ["geschlagen", "geschlagen", "geschlagen"] and int(h.gl.bereit) == 0, "Gegenschlag: das Stück erlischt %s" % str(gs))
	# Wehr im Gegnerzug
	m.gk.zug_beginnen(h)
	m._take_log()
	m.gk.held_zug(h, {"tun": Kerbe.WARTEN, "haltung": Kerbe.WEHR})
	ok("Kerben", h.gl.marken == ["halt", "halt", "halt"] and h.gl.haltung == Kerbe.WEHR, "nur Haltung: alle drei in Wehr %s" % str(h.gl.marken))
	_treffer(0)
	m.gk.auf_held(m.find("g0"), h)
	var w := _gl(m._take_log(), "KERBE_WEHR")
	ok("Kerben", w == ["geschlagen", "halt", "halt"], "Wehr nimmt das erste Stück %s" % str(w))
	# Fliehen nimmt alles
	_treffer(-1)


func _verfallen() -> void:
	var h := _held()
	var m := _kampf(h)
	m.gk.zug_beginnen(h)
	m.gk.held_zug(h, {"tun": Kerbe.WARTEN, "haltung": Kerbe.GEGENSCHLAG})
	m._take_log()
	ok("Verfallen", m.gk.zug_beginnen(h), "neuer Zug")
	var log := m._take_log()
	var v := _gl(log, "KERBE_VERFALLEN")
	ok("Verfallen", v == ["geschlagen", "geschlagen", "geschlagen"], "ungenutzte Haltung zerfällt mit der Meldung %s" % str(v))
	ok("Verfallen", h.gl.marken == ["frei", "frei", "frei"] and h.gl.haltung == "", "danach drei neue %s" % str(h.gl.marken))
	h.gl.gold_jetzt = true
	m.gk.zug_beginnen(h)
	ok("Goldkerbe", h.gl.marken.size() == 4 and bool(m.gk.bild().hero.f), "die Goldkerbe ist die vierte %s" % str(h.gl.marken))


func _vorschau() -> void:
	var h := _held()
	var m := _kampf(h)
	m.gk.zug_beginnen(h)
	var v1: Array = m.gk.vorschau(h, {"tun": Kerbe.WAFFE, "ziel": "g0", "vertiefen": 0, "haltung": Kerbe.GEGENSCHLAG})
	ok("Vorschau", v1 == ["hero", "hero", "g0", "hero", "g1"], "Gegenschlag mit zwei Kerben: Held, dann vor jedem Wolf %s" % str(v1))
	var v2: Array = m.gk.vorschau(h, {"tun": Kerbe.WAFFE, "ziel": "g0", "vertiefen": 1, "haltung": Kerbe.GEGENSCHLAG})
	ok("Vorschau", v2 == ["hero", "hero", "g0", "g1"], "eine vertieft: nur vor dem ersten %s" % str(v2))
	var v3: Array = m.gk.vorschau(h, {"tun": Kerbe.WAFFE, "ziel": "g0", "vertiefen": 0, "haltung": Kerbe.WEHR})
	ok("Vorschau", v3 == ["hero", "g0", "g1"], "Wehr: keine Antwort mit eigenem Schlag %s" % str(v3))
	var v4: Array = m.gk.vorschau(h, {"tun": Kerbe.WARTEN, "haltung": Kerbe.GEGENSCHLAG})
	ok("Vorschau", v4 == ["hero", "g0", "hero", "g1"], "nur Haltung, drei Kerben: kein Tun, Gegenschlag vor jedem Wolf %s" % str(v4))
	m.find("g1").gl.plan.art = "lauern"
	var v5: Array = m.gk.vorschau(h, {"tun": Kerbe.WAFFE, "ziel": "g0", "vertiefen": 0, "haltung": Kerbe.WEHR})
	ok("Vorschau", v5 == ["hero", "g0"], "wer lauert, schlägt nicht %s" % str(v5))


func _daumen() -> void:
	var h := _held()
	var m := _kampf(h)
	m.gk.zug_beginnen(h)
	var ui := {"kampfort": {"mars": m}}
	var gb = Kerbbild.new(ui)
	gb.haltung = m.gk.vorschlag_haltung(h)
	ok("Daumen", gb.haltung == Kerbe.GEGENSCHLAG and gb.plan(h, "g0").haltung == Kerbe.AUTO, "Vorschlag Gegenschlag, ohne Wahl spielt AUTO (7.1)")
	var seq := []
	for art in ["tief", "tief", "tief", Kerbe.WEHR, "tief", Kerbe.GEGENSCHLAG, Kerbe.GEGENSCHLAG, Kerbe.WEHR]:
		gb._symbol(h, art)
		seq.append("%s%d" % [gb.haltung.left(2), gb.nach])
	ok("Daumen", seq == ["ge1", "ge2", "ge0", "we0", "we1", "ge1", "ge0", "we0"], "je Tipp wandert eine Kerbe, eine Art der Haltung %s" % str(seq))
	gb._symbol(h, "tief")
	var p: Dictionary = gb.plan(h, "g1")
	ok("Daumen", p.vertiefen == 1 and p.haltung == Kerbe.WEHR and p.ziel == "g1" and p.tun == Kerbe.WAFFE, "Plan nach dem Daumen %s" % str(p))
	ok("Daumen", gb.plan_haltung(h) == {"tun": Kerbe.WARTEN, "haltung": Kerbe.WEHR}, "„Haltung“: alles in die gewählte")
	var gb2 = Kerbbild.new(ui)
	ok("Daumen", gb2.plan_haltung(h).haltung == Kerbe.WEHR, "„Haltung“ ohne Wahl: Wehr wie die alte Abwehr")
