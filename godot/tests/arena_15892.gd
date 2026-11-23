# 1589.2 (DESIGN-GEGNER.md 1–3, 6; 1589.1 A, Chef 17.11., 22:33): Stufe 1 der Arena, unsichtbar (regeln/arena.gd). Geprüft:
# Denkweise und Rolle je Art (alle 18 aus Tabelle 9 in werte.json), Abstand nah/fern/weit abgeleitet aus Punkt, Umriss, Reichweite,
# Ziel je Denkweise, Trägheit, Versperren (List nur durch eine Lücke), Rollenwechsel der Riesenspinne, Flucht nach Abschnitt 6 mit
# Ansage einen Zug vorher und Lohn A, Ungunst der Fernwaffe im Nahkampf (1a, Vorschlag −25), announce wählt über die Arena.
# Run: godot --headless --path godot -s res://tests/arena_15892.gd   (Exit 0 = alles gut)
extends SceneTree

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Brs = preload("res://regeln/brs.gd")
const Lohn = preload("res://regeln/lohn.gd")
const Kampfort = preload("res://kampf/kampfort.gd")

## Tabelle 9 (DESIGN-GEGNER.md), Kennung im Spiel → [Denkweise, Rolle(n)]
const TABELLE9 := {
	"giant_rat": ["Instinkt", ["nah", "rudel"]], "wolf": ["Instinkt", ["rudel"]], "dire_wolf": ["Plan", ["boss"]],
	"boar": ["Instinkt", ["nah"]], "giant_centipede": ["Instinkt", ["nah"]], "giant_spider": ["Instinkt", ["fern", "nah"]],
	"giant_bat": ["Instinkt", ["nah"]], "stirge": ["Instinkt", ["nah"]], "goblin": ["List", ["nah"]],
	"goblin_archer": ["List", ["fern"]], "kobold": ["List", ["rudel"]], "goblin_shaman": ["List", ["zauber"]],
	"zombie": ["Stur", ["nah"]], "skeleton": ["Stur", ["nah"]], "ghoul": ["Stur", ["nah"]], "ochre_jelly": ["Stur", ["nah"]],
	"bugbear": ["Plan", ["boss"]], "hobgoblin_captain": ["Plan", ["boss"]]}

var tables: Dictionary
var A = null
var fehler := 0
var faelle := 0


func _initialize() -> void:
	tables = Tabellen.lade()
	if not ResourceLoader.exists("res://regeln/arena.gd"):
		print("FALSCH regeln/arena.gd fehlt")
		print("ARENA15892 0 Fälle, 1 falsch")
		quit(1)
		return
	A = load("res://regeln/arena.gd")
	_arten()
	_stellplaetze()
	_abstand()
	_ziel_je_art()
	_versperren()
	_traegheit()
	_spinne()
	_flucht_regeln()
	_flucht_ablauf()
	_ungunst()
	_announce()
	print("ARENA15892 %d Fälle, %d falsch" % [faelle, fehler])
	quit(1 if fehler > 0 else 0)


func _ok(bed: bool, was: String) -> void:
	faelle += 1
	if not bed:
		fehler += 1
		print("FALSCH " + was)


func _monster(id: String) -> Dictionary:
	for m in tables.monsters:
		if m.id == id:
			return m
	return {}


func _held(id: String, platz: Vector2i):
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	return Mars.hero_fighter(id, "PARTY", platz, sheet, 999, sheet.second, skills)


## Held vorn links, Söldner vorn rechts, Magier hinten; Gegner nach [arten] auf den Plätzen in Reihenfolge
func _kampf(arten: Array, saat := 5, mit_hinten := true):
	var party := [_held("hero", Vector2i(Mars.FRONT, 0)), _held("merc", Vector2i(Mars.FRONT, 1))]
	if mit_hinten:
		party.append(_held("mage", Vector2i(Mars.BACK, 0)))
	var foes := []
	for i in arten.size():
		foes.append(Mars.monster_fighter("f%d" % i, Mars.SPOTS[i], _monster(arten[i]), 30))
	return Mars.new(party, foes, tables, Wuerfel.new(saat), Wuerfel.new(7))


# --- Denkweise und Rolle je Art ------------------------------------------------------------------------------------------
func _arten() -> void:
	var gesehen := {}
	for id in TABELLE9:
		var w := Brs.monster(id)
		_ok(not w.is_empty(), "%s: keine Zeile in werte.json" % id)
		_ok(String(w.get("denkweise", "")) == TABELLE9[id][0], "%s: Denkweise %s statt %s" % [id, w.get("denkweise"), TABELLE9[id][0]])
		_ok(w.get("rolle", []) == TABELLE9[id][1], "%s: Rolle %s statt %s" % [id, w.get("rolle"), TABELLE9[id][1]])
		gesehen[String(w.get("denkweise", ""))] = true
		var m := _monster(id)
		_ok(not m.is_empty(), "%s fehlt in den Tabellen" % id)
		if not m.is_empty():
			var f = Mars.monster_fighter("x", Mars.SPOTS[0], m, 10)
			_ok(A.denkweise(f) == TABELLE9[id][0], "%s: arena.denkweise %s" % [id, A.denkweise(f)])
	_ok(gesehen.size() == 4, "vier Denkweisen: %s" % [gesehen.keys()])


# --- Punkte aus den heutigen Stellplätzen (kampfort.gd _stand) ------------------------------------------------------------
func _stellplaetze() -> void:
	var ka: Dictionary = (Kampfort as Script).get_script_constant_map()
	var ar: Dictionary = (A as Script).get_script_constant_map()
	for k in ["FRONT_M", "BACK_M", "HALF_M", "FOE_HALF_M", "NEAR_M", "ALONE_HERO_B", "FOE_LEFT_BACK_M", "FOE_LEFT_OUT_M"]:
		_ok(ar.has(k) and is_equal_approx(float(ar[k]), float(ka[k])), "Konstante %s wie kampfort.gd" % k)
	var m = _kampf(["wolf", "wolf"])
	_ok(A.punkt(m, m.by_id("hero")).is_equal_approx(Vector2(-2.4, -0.9)), "Held vorn links %s" % A.punkt(m, m.by_id("hero")))
	_ok(A.punkt(m, m.by_id("f1")).is_equal_approx(Vector2(1.4, 1.2)), "Wolf vorn rechts %s" % A.punkt(m, m.by_id("f1")))
	_ok(A.punkt(m, m.by_id("f0")).is_equal_approx(Vector2(1.95, -1.65)), "Wolf vorn links %s" % A.punkt(m, m.by_id("f0")))
	_ok(A.punkt(m, m.by_id("mage")).is_equal_approx(Vector2(-3.9, 0.35)), "Magier allein hinten %s" % A.punkt(m, m.by_id("mage")))
	# Befund: auf den Stellplätzen steht keiner nah (Weg und Schlag gehen erst mit Stufe 3 in die Arena)
	_ok(A.abstand(m, m.by_id("f1"), m.by_id("merc")) == "fern", "Stellplatz vorn gegen vorn ist fern")


# --- Abstand abgeleitet -------------------------------------------------------------------------------------------------
func _abstand() -> void:
	var m = _kampf(["wolf", "goblin_archer"], 5, false)
	var held = m.by_id("hero")
	var wolf = m.by_id("f0")
	var umr: float = A.umriss(held) + A.umriss(wolf)
	_ok(is_equal_approx(A.umriss(held), 0.3), "Umriss Mensch 0,3 m")
	_ok(is_equal_approx(A.umriss(wolf), 0.45), "Umriss Vierbeiner 0,45 m")
	_ok(is_equal_approx(A.reichweite_nah(held), 0.75), "Reichweite Held 0,75 m")
	for z in [[0.5, "nah"], [0.75, "nah"], [0.8, "fern"], [6.0, "fern"], [30.0, "weit"]]:
		m.arena_punkte = {"hero": Vector2(0, 0), "f0": Vector2(umr + float(z[0]), 0)}
		_ok(A.abstand(m, wolf, held, 20.0) == z[1], "Lücke %.2f m: %s statt %s" % [z[0], A.abstand(m, wolf, held, 20.0), z[1]])
		_ok(A.abstand(m, held, wolf, 20.0) == z[1], "Lücke %.2f m andersherum" % z[0])
	m.arena_punkte = {"hero": Vector2(0, 0), "f0": Vector2(umr + 30.0, 0)}
	_ok(A.abstand(m, wolf, held) == "fern", "ohne Schussweite in werte.json kein weit")


# --- Ziel je Denkweise, alle 18 Arten -------------------------------------------------------------------------------------
func _ziel_je_art() -> void:
	for id in TABELLE9:
		var m = _kampf(["goblin", id])     # Art auf vorn rechts (1,4 | 1,2)
		var f = m.by_id("f1")
		m.by_id("mage").hp = 3
		var z = A.ziel(m, f, "")
		match TABELLE9[id][0]:
			"Instinkt", "Stur":
				_ok(z != null and z.id == "merc", "%s: der Nächste (merc) statt %s" % [id, z.id if z else null])
			"List":
				# der Schwächste (Magier hinten, 3 Leben): vom rechten Platz versperrt der Söldner den Weg, also der Nächste
				var erwartet := "mage" if f.ranged() else "merc"
				_ok(z != null and z.id == erwartet, "%s: %s statt %s" % [id, z.id if z else null, erwartet])
				var m2 = _kampf([id])     # vorn links (1,95 | −1,65): zwischen Held und Söldner ist die Lücke frei
				m2.by_id("mage").hp = 3
				var z2 = A.ziel(m2, m2.by_id("f0"), "")
				_ok(z2 != null and z2.id == "mage", "%s: durch die Lücke zum Schwächsten, nicht %s" % [id, z2.id if z2 else null])
			"Plan":
				_ok(z == null, "%s: Plan wählt wie bisher (Reihenfolge des Bosses bis 1589.5)" % id)
	# Instinkt: bei gleichem Abstand der Verwundete; „gleich“ heißt gleich (Toleranz ohne Quelle: Frage 1589.2), nicht traegheit_m
	var m = _kampf(["wolf"], 5, false)
	m.arena_punkte = {"f0": Vector2(3, 0), "hero": Vector2(0, -0.3), "merc": Vector2(0, 0.3)}
	m.by_id("merc").hp -= 5
	_ok(A.ziel(m, m.by_id("f0"), "").id == "merc", "Instinkt: bei gleichem Abstand der Verwundete")
	m.arena_punkte["merc"] = Vector2(0, 1.83)     # 0,5 m weiter (3,51 gegen 3,01 m), Weg frei: nicht gleich
	_ok(A.ziel(m, m.by_id("f0"), "").id == "hero", "Instinkt: 0,5 m weiter ist nicht gleich, der Nächste trotz Wunde des anderen")
	m.arena_punkte["merc"] = Vector2(-0.05, 0.3)
	_ok(A.ziel(m, m.by_id("f0"), "").id == "hero", "Instinkt: 5 cm weiter ist nicht gleich")


# --- Versperren: Vordere decken Hintere, List nur durch eine Lücke ------------------------------------------------------
func _versperren() -> void:
	var m = _kampf(["goblin"])
	var g = m.by_id("f0")
	m.by_id("mage").hp = 2
	m.arena_punkte = {"f0": Vector2(4, 0), "hero": Vector2(0, -1), "merc": Vector2(0, 1), "mage": Vector2(-2, 0)}
	_ok(A.frei(m, g, m.by_id("mage")), "Lücke 2 m zwischen Held und Söldner ist frei")
	_ok(A.ziel(m, g, "").id == "mage", "List geht durch die Lücke zum Schwächsten")
	m.arena_punkte["merc"] = Vector2(0, 0.4)
	_ok(not A.frei(m, g, m.by_id("mage")), "Söldner rückt in die Lücke: versperrt")
	_ok(A.ziel(m, g, "").id == "merc", "versperrt: List nimmt den Nächsten")
	_ok(not (m.by_id("mage") in A.erreichbar(m, g)), "Magier nicht erreichbar")
	m.by_id("merc").hp = 0
	_ok(A.frei(m, g, m.by_id("mage")), "wer liegt, versperrt nicht")
	var s = _kampf(["goblin_archer"])
	s.arena_punkte = {"f0": Vector2(4, 0), "hero": Vector2(0, -0.3), "merc": Vector2(0, 0.3), "mage": Vector2(-2, 0)}
	s.by_id("mage").hp = 2
	_ok(s.by_id("mage") in A.erreichbar(s, s.by_id("f0")), "Schütze erreicht auch Versperrte")


# --- Trägheit: das Ziel springt nicht --------------------------------------------------------------------------------------
func _traegheit() -> void:
	var m = _kampf(["wolf"], 5, false)
	var w = m.by_id("f0")
	m.arena_punkte = {"f0": Vector2(3, 0), "hero": Vector2(0, -1.5), "merc": Vector2(0.6, 1.5)}
	var ohne = A.ziel(m, w, "")
	_ok(ohne.id == "merc", "ohne Vorgänger der Nächste (merc)")
	_ok(A.ziel(m, w, "hero").id == "hero", "merc nur 0,6 m näher: bleibt beim Helden")
	m.arena_punkte["merc"] = Vector2(1.6, 0.8)
	_ok(A.ziel(m, w, "hero").id == "merc", "merc deutlich näher (über 1 m): wechselt")
	var g = _kampf(["goblin"], 5, false)
	g.arena_punkte = {"f0": Vector2(3, 0), "hero": Vector2(0, -0.5), "merc": Vector2(0, 0.5)}
	g.by_id("hero").hp = 10
	g.by_id("merc").hp = 8
	_ok(A.ziel(g, g.by_id("f0"), "hero").id == "hero", "List: 8 statt 10 Leben ist nicht deutlich schwächer")
	g.by_id("merc").hp = 7
	_ok(A.ziel(g, g.by_id("f0"), "hero").id == "merc", "List: 7 statt 10 Leben (ein Viertel weniger): wechselt")
	g.by_id("hero").hp = 0
	_ok(A.ziel(g, g.by_id("f0"), "hero").id == "merc", "gefallenes Ziel: neu gewählt")


# --- Rollenwechsel Riesenspinne: Netz, dann Biss ------------------------------------------------------------------------
func _spinne() -> void:
	var m = _kampf(["giant_spider"], 5, false)
	var s = m.by_id("f0")
	var h = m.by_id("hero")
	_ok(A.rolle_jetzt(m, s, h) == "fern", "Spinne auf dem Stellplatz: Fernkampf (Netz)")
	m.arena_ziel[s.id] = "hero"
	_ok(m._absicht_gilt(s, "netz"), "Netz erlaubt, solange das Ziel fern und frei ist")
	h.held = true
	_ok(A.rolle_jetzt(m, s, h) == "nah", "Ziel im Netz: Nahkampf")
	_ok(not m._absicht_gilt(s, "netz"), "Ziel im Netz: kein zweites Netz")
	for k in 20:
		_ok(m._pick_intent(s).id != "web", "Ziel im Netz: Biss statt Netz (Wurf %d)" % k)
	h.held = false
	m.arena_punkte = {"f0": Vector2(A.umriss(s) + A.umriss(h) + 0.5, 0), "hero": Vector2(0, 0)}
	_ok(A.rolle_jetzt(m, s, h) == "nah", "Ziel nah: Nahkampf")
	var w = _kampf(["wolf"], 5, false)
	_ok(A.rolle_jetzt(w, w.by_id("f0"), w.by_id("hero")) == "rudel", "eine Rolle: bleibt")
	# Riesenratte (Tabelle 9 „Nahkampf, zu dritt Rudel“, [428.ratte] „zu dritt dreist“): Rolle nach der Zahl, nicht nach dem Abstand
	var r2 = _kampf(["giant_rat", "giant_rat"], 5, false)
	var rh = r2.by_id("hero")
	_ok(A.rolle_jetzt(r2, r2.by_id("f0"), rh) == "nah", "zwei Ratten: Nahkampf")
	r2.arena_punkte = {"f0": Vector2(A.umriss(r2.by_id("f0")) + A.umriss(rh) + 0.3, 0), "hero": Vector2(0, 0)}
	_ok(A.rolle_jetzt(r2, r2.by_id("f0"), rh) == "nah", "zwei Ratten, Ziel nah: Nahkampf (kein Wechsel wie die Spinne)")
	var r3 = _kampf(["giant_rat", "giant_rat", "giant_rat"], 5, false)
	_ok(A.rolle_jetzt(r3, r3.by_id("f0"), r3.by_id("hero")) == "rudel", "drei Ratten: Rudel")
	r3.by_id("f2").hp = 0
	_ok(A.rolle_jetzt(r3, r3.by_id("f0"), r3.by_id("hero")) == "nah", "eine von drei fällt: wieder Nahkampf")


# --- Flucht nach Abschnitt 6 --------------------------------------------------------------------------------------------
func _flucht_regeln() -> void:
	# Rudel: Anführer gefallen und die Hälfte besiegt
	var r = _rudel(2)
	r.by_id("wolf1").hp = 0
	_ok(A.flucht_grund(r, r.by_id("cub1")) == "", "Leitwolf fällt, 1 von 3 besiegt: bleibt")
	r.by_id("cub2").hp = 0
	_ok(A.flucht_grund(r, r.by_id("cub1")) == "rudel", "Leitwolf und ein Jungwolf fallen: Rudel flieht")
	var r1 = _rudel(1)
	_ok(A.flucht_grund(r1, r1.by_id("cub1")) == "", "Leitwolf steht: keine Flucht")
	r1.by_id("wolf1").hp = 0
	_ok(A.flucht_grund(r1, r1.by_id("cub1")) == "rudel", "Leitwolf fällt, 1 von 2: Rudel flieht")
	# Grak fällt: die Goblins fliehen
	var g = _kampf(["hobgoblin_captain", "goblin", "goblin_archer"])
	_ok(A.flucht_grund(g, g.by_id("f1")) == "", "Grak steht: keine Flucht")
	g.by_id("f0").hp = 0
	_ok(A.flucht_grund(g, g.by_id("f1")) == "grak", "Grak fällt: Goblin flieht")
	_ok(A.flucht_grund(g, g.by_id("f2")) == "grak", "Grak fällt: Späher flieht")
	# Goblin oder Kobold allein und unter einem Viertel
	for id in ["goblin", "kobold", "goblin_archer", "goblin_shaman"]:
		var e = _kampf([id, "goblin"])
		var x = e.by_id("f0")
		x.max_hp = 40
		x.hp = 9
		_ok(A.flucht_grund(e, x) == "", "%s nicht allein: bleibt" % id)
		e.by_id("f1").hp = 0
		_ok(A.flucht_grund(e, x) == "allein", "%s allein unter einem Viertel: flieht" % id)
		x.hp = 10
		_ok(A.flucht_grund(e, x) == "", "%s allein mit einem Viertel: bleibt" % id)
	# die letzte Riesenratte flieht, sobald sie verwundet ist
	var ra = _kampf(["giant_rat", "giant_rat"])
	ra.by_id("f0").hp -= 1
	_ok(A.flucht_grund(ra, ra.by_id("f0")) == "", "zwei Ratten: die verwundete bleibt")
	ra.by_id("f1").hp = 0
	_ok(A.flucht_grund(ra, ra.by_id("f0")) == "ratte", "letzte Ratte verwundet: flieht")
	ra.by_id("f0").hp = ra.by_id("f0").max_hp
	_ok(A.flucht_grund(ra, ra.by_id("f0")) == "", "letzte Ratte unverwundet: bleibt")
	# nie: Untote, Säureschnecke, Bosse; allein mit einem Leben
	for id in TABELLE9:
		var n = _kampf([id])
		var x = n.by_id("f0")
		x.hp = 1
		var nie: bool = TABELLE9[id][0] in ["Stur", "Plan"]
		if nie:
			_ok(A.flucht_grund(n, x) == "", "%s flieht nie" % id)
		else:
			faelle += 1     # gezählt: Art geprüft; ob sie flieht, hängt von Abschnitt 6 ab (oben)


func _rudel(jung: int):
	var hero = _held("hero", Vector2i(Mars.FRONT, 0))
	var wolf := _monster("wolf")
	var foes := [Mars.monster_fighter("wolf1", Vector2i(0, 0), wolf, 25)]
	for i in jung:
		var j := wolf.duplicate(true)
		j.rudel = "Jungwolf"
		j.anfuehrer = "wolf"
		var c = Mars.monster_fighter("cub%d" % (i + 1), [Vector2i(0, 1), Vector2i(1, 0)][i], j, 12)
		c.follows = "wolf1"
		foes.append(c)
	return Mars.new([hero], foes, tables, Wuerfel.new(3), Wuerfel.new(7))


func _flucht_ablauf() -> void:
	# Rudel: Leitwolf fällt (1 von 2): Ansage sofort, fort erst nach dem nächsten Zug des Jungwolfs, eine Zeile [1601.flucht.rudel]
	var r = _rudel(1)
	var c = r.by_id("cub1")
	_schlag(r, "wolf1")
	_ok(c.standing() and not c.fled, "Ansage: Jungwolf noch da")
	_ok(r.intents.has("cub1") and r.intents["cub1"][0].id == "flee", "Jungwolf hat Flucht angesagt")
	_ok(String(r.I_FLEE.name[0]) == "Flucht" and String(r.I_FLEE.name[1]) == "Flee", "[1601.ansage.flee] wortgleich")
	_ok(r.outcome == "ONGOING", "Kampf läuft bis zur Flucht")
	r._foe_turn(c, Callable())
	_ok(c.standing() and not c.fled, "Zug des Jungwolfs vor dem Zug der Gruppe: noch da")
	_ok(r.intents.has("cub1") and r.intents["cub1"][0].id == "flee", "Ansage bleibt, bis die Gruppe gehandelt hat")
	_zug(r, "hero")
	r._foe_turn(c, Callable())
	_ok(c.fled and c.von_selbst, "nach dem Zug der Gruppe und seinem Zug fort, von selbst")
	_ok(r.outcome == "WON", "Kampf gewonnen")
	var txt := _texte(r)
	_ok("Das Rudel zerstreut sich zwischen den Bäumen." in txt, "[1601.flucht.rudel] im Bericht")
	# einzeln: Goblin allein unter einem Viertel sagt an [1601.flucht.ansage], dann [1601.flucht.fort]
	var e = _kampf(["goblin", "goblin"], 5, false)
	var x = e.by_id("f0")
	x.hp = 2
	_schlag(e, "f1")
	_ok(e.intents.has("f0") and e.intents["f0"][0].id == "flee", "Goblin allein sagt Flucht an")
	_ok(x.standing(), "noch da nach der Ansage")
	_ok(_texte(e).any(func(t): return t == x.name(0) + " weicht zurück und sucht einen Ausweg."), "[1601.flucht.ansage] wortgleich")
	e.announce(x)
	_ok(e.intents["f0"][0].id == "flee", "Ansage bleibt bis zum Zug")
	_zug(e, "hero")
	e._foe_turn(x, Callable())
	_ok(x.standing(), "Söldner hat noch nicht gehandelt: Goblin noch da")
	_zug(e, "merc")
	e._foe_turn(x, Callable())
	_ok(x.fled and x.von_selbst and e.outcome == "WON", "Goblin fort")
	_ok(_texte(e).any(func(t): return t == x.name(0) + " ist fort."), "[1601.flucht.fort] wortgleich")
	# Lohn A: volle Erfahrung, halbe Beute, Zeile [1601.lohn.geflohen]
	var tot = _kampf(["goblin", "goblin"], 5, false)
	tot._hurt(tot.by_id("f1"), 999, "hero", "")
	tot._hurt(tot.by_id("f0"), 999, "hero", "")
	var l_tot: Dictionary = Lohn.reward(tot, {}, Wuerfel.new(11))
	var l_weg: Dictionary = Lohn.reward(e, {}, Wuerfel.new(11))
	_ok(l_weg.xp == l_tot.xp and l_weg.xp > 0, "Lohn A: volle Erfahrung (%d gegen %d)" % [l_weg.xp, l_tot.xp])
	_ok(l_weg.gold == int(l_tot.gold / 2), "Lohn A: halbes Gold (%d gegen %d)" % [l_weg.gold, l_tot.gold])
	_ok("Von selbst geflohen: halbe Beute, volle Erfahrung." in l_weg.lines, "[1601.lohn.geflohen] im Lohn")
	_ok(not ("Von selbst geflohen: halbe Beute, volle Erfahrung." in l_tot.lines), "ohne Flucht keine Lohnzeile")
	# Grak fällt: [1601.flucht.grak]
	var g = _kampf(["hobgoblin_captain", "goblin", "goblin"], 5, false)
	_schlag(g, "f0")
	_ok(g.intents["f1"][0].id == "flee" and g.intents["f2"][0].id == "flee", "Grak fällt: beide sagen Flucht an")
	g._foe_turn(g.by_id("f1"), Callable())
	_ok(g.by_id("f1").standing() and g.by_id("f2").standing(), "Grak fällt: ohne Zug der Gruppe läuft keiner")
	_zug(g, "hero")
	_zug(g, "merc")
	g._foe_turn(g.by_id("f1"), Callable())
	_ok(g.by_id("f1").fled and g.by_id("f2").fled, "die Goblins laufen zugleich")
	_ok("Die Goblins sehen ihren Hauptmann fallen und laufen." in _texte(g), "[1601.flucht.grak] im Bericht")
	# Ansage mitten im Zug des Helden: dieser Zug zählt nicht, erst sein nächster
	var h = _rudel(1)
	h.turn = h.order.find(h.by_id("hero"))
	h._hurt(h.by_id("wolf1"), 999, "hero", "")
	h._next_turn()
	h._foe_turn(h.by_id("cub1"), Callable())
	_ok(h.by_id("cub1").standing(), "Ansage im Zug des Helden: dieser Zug zählt nicht")
	_zug(h, "hero")
	h._foe_turn(h.by_id("cub1"), Callable())
	_ok(h.by_id("cub1").fled, "nach dem nächsten Zug des Helden fort")
	_lohn_nur_geflohener()
	_flucht_echter_ablauf()
	# Untote fliehen nie, auch allein
	var z = _kampf(["zombie", "zombie"], 5, false)
	z.by_id("f0").hp = 1
	z._hurt(z.by_id("f1"), 999, "hero", "")
	_ok(not (z.intents.has("f0") and z.intents["f0"][0].id == "flee"), "Wiedergänger flieht nie")


## der Held schlägt [ziel] in seinem Zug nieder, der Zug endet (dieser Zug zählt für eine Flucht, die er auslöst, nicht)
func _schlag(m, ziel: String) -> void:
	m.turn = m.order.find(m.by_id("hero"))
	m._hurt(m.by_id(ziel), 999, "hero", "")
	m._next_turn()


## der Zug von [id] geht zu Ende (wie _skip_to_choice nach seiner Handlung)
func _zug(m, id: String) -> void:
	m.turn = m.order.find(m.by_id(id))
	m._next_turn()


## Lohn A halbiert nur, was der Fliehende bringt (Abschnitt 6): die Beute kommt vom stärksten Gegner (lohn.gd)
func _lohn_nur_geflohener() -> void:
	var weg = _rudel(1)
	_schlag(weg, "wolf1")
	_zug(weg, "hero")
	weg._foe_turn(weg.by_id("cub1"), Callable())
	_ok(weg.by_id("cub1").von_selbst, "Lohn: Jungwolf von selbst geflohen")
	var tot = _rudel(1)
	tot._hurt(tot.by_id("wolf1"), 999, "hero", "")
	tot._hurt(tot.by_id("cub1"), 999, "hero", "")
	for saat in [11, 12, 13, 14]:
		var lw: Dictionary = Lohn.reward(weg, {}, Wuerfel.new(saat))
		var lt: Dictionary = Lohn.reward(tot, {}, Wuerfel.new(saat))
		_ok(lw.gold == lt.gold, "Leitwolf fällt, Jungwolf flieht: volles Gold des Leitwolfs (%d gegen %d, Saat %d)" % [lw.gold, lt.gold, saat])
		_ok(lw.get("items", []) == lt.get("items", []), "Leitwolf fällt, Jungwolf flieht: volle Fundchance (Saat %d)" % saat)
		_ok(lw.xp == lt.xp, "volle Erfahrung (Saat %d)" % saat)
		_ok(not ("Von selbst geflohen: halbe Beute, volle Erfahrung." in lw.lines), "keine Lohnzeile, wenn nichts halbiert wird (Saat %d)" % saat)


## im echten Ablauf (Gruppe auf Selbstlauf, Reihenfolge nach Initiative): zwischen Ansage und Fortsein handelt jeder der Gruppe
func _flucht_echter_ablauf() -> void:
	var gesehen := 0
	for saat in 12:
		var hero = _held("hero", Vector2i(Mars.FRONT, 0))
		var merc = _held("merc", Vector2i(Mars.FRONT, 1))
		var mage = _held("mage", Vector2i(Mars.BACK, 0))
		var wolf := _monster("wolf")
		var foes := [Mars.monster_fighter("wolf1", Vector2i(0, 0), wolf, 1)]
		var j := wolf.duplicate(true)
		j.rudel = "Jungwolf"
		j.anfuehrer = "wolf"
		var c = Mars.monster_fighter("cub1", Vector2i(0, 1), j, 500)
		c.follows = "wolf1"
		foes.append(c)
		var m = Mars.new([hero, merc, mage], foes, tables, Wuerfel.new(100 + saat), Wuerfel.new(7))
		m.by_id("wolf1").hp = 1     # nach dem Einrichten (brs_einrichten setzt das Leben nach werte.json)
		c.max_hp = 500
		c.hp = 500
		for p in [hero, merc, mage]:
			p.auto = true
		m.chosen = true
		var log: Array = m.start()
		var n := 0
		while m.outcome == "ONGOING" and n < 300:
			log += m.proceed()
			n += 1
		var an := -1
		var fort := -1
		for i in log.size():
			var e: Dictionary = log[i]
			if an < 0 and e.intents.has("cub1") and String(e.intents["cub1"][0].id) == "flee":
				an = i
			if fort < 0 and e.cue == "FOE_FLEES" and e.target == "cub1":
				fort = i
		if an < 0 or fort < 0:
			continue
		gesehen += 1
		var dazwischen := {}
		for i in range(an + 1, fort):
			if log[i].actor in ["hero", "merc", "mage"]:
				dazwischen[log[i].actor] = true
		_ok(dazwischen.size() == 3, "Saat %d: zwischen Ansage und Fortsein handeln %s, nicht alle drei" % [saat, dazwischen.keys()])
	_ok(gesehen >= 6, "echter Ablauf: Flucht in %d von 12 Saaten gesehen" % gesehen)


func _texte(m) -> Array:
	var out := []
	for e in m._log:
		out.append(String(e.text))
	return out


# --- Ungunst der Fernwaffe im Nahkampf (1a; Vorschlag −25, Endwert 1589.6) ---------------------------------------------
func _ungunst() -> void:
	var m = _kampf(["goblin_archer"], 5, false)
	var s = m.by_id("f0")
	var h = m.by_id("hero")
	m.arena_punkte = {"hero": Vector2(0, 0), "f0": Vector2(A.umriss(s) + A.umriss(h) + 0.5, 0)}
	_ok(A.ungunst(m, s, h, true) == -25, "Schuss nah: Ungunst −25")
	_ok(A.ungunst(m, s, h, false) == 0, "Nahwaffe nah: keine Ungunst")
	m.arena_punkte["f0"] = Vector2(5, 0)
	_ok(A.ungunst(m, s, h, true) == 0, "Schuss fern: keine Ungunst")
	_ok(A.ungunst(m, h, s, true) == 0, "Held schießt fern: keine Ungunst")


# --- announce wählt über die Arena ---------------------------------------------------------------------------------------
func _announce() -> void:
	for id in TABELLE9:
		for saat in 6:
			var m = _kampf(["goblin", id], 20 + saat)
			m.by_id("mage").hp = 3
			var f = m.by_id("f1")
			m.intents.erase(f.id)
			m.arena_ziel.erase(f.id)
			m.announce(f)
			if not m.intents.has(f.id):
				_ok(false, "%s: keine Ansage" % id)
				continue
			var p: Array = m.intents[f.id]
			if p[1].is_empty() or p[0].effect in ["BREAKTHROUGH", "FLANK"]:
				faelle += 1
				continue
			var z = A.ziel(m, f, "")
			if TABELLE9[id][0] == "Plan":
				_ok(z == null, "%s: Plan ohne Arena" % id)
			else:
				_ok(p[1][0] == z.id, "%s Saat %d: Ansage auf %s, Arena %s" % [id, saat, p[1][0], z.id])
