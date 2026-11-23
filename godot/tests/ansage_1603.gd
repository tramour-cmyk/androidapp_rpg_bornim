# 1603 (Fund Perikles 17.11., 22:39): jede Art des Kapitels 1 (DESIGN-GEGNER.md Tabelle 9, 18 Zeilen) sagt ihren eigenen Schlag
# an statt „Stich“. Je Art: welche Absichten _pick_intent über viele Lagen wählt, Name DE/EN, Langdruck-Text (marstips.gd INTENTS)
# wortgleich aus docs/STORY-BRS-KAMPF.md ([1057.ansage.*], [1069.ansage.prankenhieb]), Eingebung [1069.prankenhieb], Kroggs Los
# Morgenstern 2 : Prankenhieb 1, Prankenhieb stark mit Ring, nicht brechbar; „_sonst“ in werte.json leer.
# Run: godot --headless --path godot -s res://tests/ansage_1603.gd   (Exit 0 = alles wie Soll)
extends SceneTree

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Tips = preload("res://kampf/marstips.gd")

## Tabelle 9 (Art) -> Kennung in werte.json, erwartete Absichten {Kennung: [DE, EN]}
const SOLL := [
	["Riesenratte", "giant_rat", {"bite": ["Biss", "Bite"]}],
	["Wolf", "wolf", {"pounce": ["Anspringen", "Pounce"], "circle": ["Einkreisen", "Circle"]}],
	["Grimmzahn", "dire_wolf", {"pounce": ["Anspringen", "Pounce"], "circle": ["Einkreisen", "Circle"]}],
	["Wildschwein", "boar", {"tusks": ["Hauer", "Tusks"]}],
	["Riesen-Hundertfüßer", "giant_centipede", {"poison_claws": ["Giftklauen", "Poison claws"]}],
	["Riesenspinne", "giant_spider", {"venom": ["Gift sammeln", "Gather venom"], "web": ["Netz werfen", "Throw web"]}],
	["Riesenfledermaus", "giant_bat", {"bite": ["Biss", "Bite"]}],
	["Blutflügler, Riesenegel", "stirge", {"sucker": ["Saugmaul", "Sucker"]}],
	["Goblin", "goblin", {"slash": ["Hieb", "Slash"], "flank": ["Flanke", "Flank"]}],
	["Goblin-Späher", "goblin_archer", {"aim": ["Anlegen", "Take aim"], "shadow": ["In den Schatten", "Into the shadows"]}],
	["Kobold", "kobold", {"stab": ["Stich", "Stab"]}],
	["Goblin-Schamane", "goblin_shaman", {"slash": ["Hieb", "Slash"], "flank": ["Flanke", "Flank"]}],
	["Wiedergänger", "zombie", {"claw": ["Klauen", "Claws"]}],
	["Skelett", "skeleton", {"stab": ["Stich", "Stab"]}],
	["Grabhund", "ghoul", {"bite": ["Biss", "Bite"]}],
	["Säureschnecke", "ochre_jelly", {"tongue": ["Zunge", "Tongue"]}],
	["Krogg", "bugbear", {"morningstar": ["Morgenstern", "Morningstar"], "paw": ["Prankenhieb", "Paw swipe"]}],
	["Hauptmann Grak", "hobgoblin_captain", {"heavy": ["Schwerer Hieb", "Heavy blow"], "breakthrough": ["Durchbrechen", "Break through"],
		"call": ["Hilfe rufen", "Call for help"], "gather": ["Kraft sammeln", "Gather strength"]}],
]
## neue Langdruck-Texte -> Marke in der Quelle
const TEXT := {"morningstar": "1057.ansage.morningstar", "tusks": "1057.ansage.tusks", "poison_claws": "1057.ansage.poison_claws",
	"sucker": "1057.ansage.sucker", "tongue": "1057.ansage.tongue", "paw": "1069.ansage.prankenhieb"}

var tables: Dictionary
var fehler := 0
var quelle := ""


func _initialize() -> void:
	tables = Tabellen.lade()
	quelle = FileAccess.get_file_as_string(ProjectSettings.globalize_path("res://").path_join("../docs/STORY-BRS-KAMPF.md"))
	_soll(quelle != "", "Quelle docs/STORY-BRS-KAMPF.md lesbar")
	var faelle := 0
	for z in SOLL:
		var m := _monster(z[1])
		if m.is_empty():
			_soll(false, "%s (%s) in den Tabellen" % [z[0], z[1]])
			continue
		var gesehen := {}
		for k in 300:
			var x = _fight(m, 2000 + k)
			_lage(x, k)
			var i: Dictionary = x._pick_intent(x.by_id("f0"))
			gesehen[String(i.id)] = i
		var soll: Dictionary = z[2]
		var ok := gesehen.keys().size() == soll.size() and soll.keys().all(func(k): return gesehen.has(k))
		for k in soll:
			if gesehen.has(k):
				ok = ok and gesehen[k].name == soll[k]
		faelle += 1
		_soll(ok, "%s (%s): Soll %s, Ist %s" % [z[0], z[1], _zeig(soll), _zeig_ist(gesehen)])
	# Langdruck und Eingebung wortgleich aus der Quelle
	for k in TEXT:
		var q := _marke(TEXT[k])
		faelle += 1
		_soll(Tips.INTENTS.has(k) and q.size() == 2 and Tips.INTENTS[k] == q, "Langdruck %s = [%s]" % [k, TEXT[k]])
	var e := _marke("1069.prankenhieb")
	faelle += 1
	_soll(e.size() == 2 and Mars.EINGEBUNG.get("paw", []) == e, "Eingebung paw = [1069.prankenhieb]")
	# Prankenhieb wie der Schwere Hieb, aber nicht brechbar (Hauptfassung 1069); Los 2 : 1
	var x0 = _fight(_monster("bugbear"), 1)
	var p = x0.get("I_PAW")
	faelle += 1
	_soll(p != null and p.strong and p.ring and not p.breakable and p.extra == [2, 6, 0] and p.kind == "STRIKE",
		"Prankenhieb stark, Ring, nicht brechbar, Zusatz [2, 6, 0]")
	var T: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/werte.json")).get("absichten", {}).get("je_art", {})
	faelle += 1
	_soll((T.get("bugbear", []) as Array).map(func(x): return [String(x[0]), int(x[1])]) == [["morningstar", 2], ["paw", 1]], "Krogg Los Morgenstern 2 : Prankenhieb 1, Ist %s" % [T.get("bugbear")])
	faelle += 1
	_soll((T.get("_sonst", []) as Array).is_empty(), "_sonst leer, Ist %s" % [T.get("_sonst")])
	print("ANSAGE1603 %d Fälle, %d Fehler" % [faelle, fehler])
	quit(1 if fehler > 0 else 0)


func _soll(ok: bool, was: String) -> void:
	print(("gut " if ok else "FALSCH ") + was)
	if not ok:
		fehler += 1


## [Marke] in der Quelle: Text nach der Klammer bis „ / EN: “, dann Englisch bis Zeilenende
func _marke(marke: String) -> Array:
	for zeile in quelle.split("\n"):
		var a := zeile.find("`[" + marke + "]`")
		if not zeile.begins_with("- ") or a < 0 or a > 3:
			continue
		var rest := zeile.substr(a + marke.length() + 4).strip_edges()
		if rest.begins_with("("):
			rest = rest.substr(rest.find(")") + 1).strip_edges()
		var t := rest.split(" / EN: ")
		return [t[0], t[1]] if t.size() == 2 else []
	return []


func _zeig(d: Dictionary) -> String:
	return ", ".join(d.keys().map(func(k): return "%s %s/%s" % [k, d[k][0], d[k][1]]))


func _zeig_ist(d: Dictionary) -> String:
	return ", ".join(d.keys().map(func(k): return "%s %s/%s" % [k, d[k].name[0], d[k].name[1]]))


func _monster(id: String) -> Dictionary:
	for m in tables.monsters:
		if m.id == id:
			return m
	return {}


## wie absicht_1049: Held, Söldner und drei Gegner der Art
func _fight(m: Dictionary, saat: int):
	var sheet: Dictionary = tables.probe.FIGHTER.hero.hero.duplicate(true)
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var hero := Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, 999, sheet.second, skills)
	var merc := Mars.hero_fighter("merc", "PARTY", Vector2i(Mars.BACK, 1), sheet, 999, sheet.second, skills)
	var foes := []
	for i in 3:
		foes.append(Mars.monster_fighter("f%d" % i, Mars.SPOTS[i], m, 30))
	return Mars.new([hero, merc], foes, tables, Wuerfel.new(saat), Wuerfel.new(7))


func _lage(x, saat: int) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = saat
	var f0 = x.by_id("f0")
	f0.hidden = r.randf() < 0.5
	f0.hp = r.randi_range(1, f0.max_hp)
	x.chosen = r.randf() < 0.6
	x.called = r.randi_range(0, 1)
	if r.randf() < 0.3:
		x.by_id("f2").hp = 0
	if r.randf() < 0.5:
		x.by_id("merc").hp = 0
