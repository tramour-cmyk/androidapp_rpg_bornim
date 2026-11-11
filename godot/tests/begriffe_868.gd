extends SceneTree
# 868 (Chef 10.11., 13:48; wiederholt 11.11., 07:08, t275: „da steht immer noch was von Rüstungsklassen“): im Kampf nur
# BRS-Begriffe. Spielt MARS-Kämpfe nach BRS (jede Klasse der Probe gegen jede Gegnergruppe, deutsch und englisch, Züge wie
# „Held Auto“) und prüft jede Zeile, die der Schirm zeigt (Meldung, Ansage), auf Begriffe und Zahlen des alten Systems:
# Rüstungsklasse/RK/AC, W20/d20, Würfelsummen („12 + 5 = 17“), Würfelangaben („2W6“, „1d8“), ZP/SP, Rettungswurf, SG/DC.
# Dazu die Texte der Erklärungen (marstips.gd) und des Kampfschirms (kampf_ui.gd) als Quelltext ohne Kommentare.
# Aufruf: im Ordner godot mit -s res://tests/begriffe_868.gd (Exit 0 = kein alter Begriff); braucht daten/werte.json.

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Aufruf = preload("res://kampf/aufruf.gd")
const Brs = preload("res://regeln/brs.gd")

const KAEMPFE := 6
const GRUPPEN := ["WOLVES", "GRIMM", "RATS", "RATTE", "BATS", "FLEDERMAUS", "BOARS", "CENTIPEDES", "SPINNE", "KROGG", "GRAK",
		"GOBLINS", "SCOUTS", "KOBOLDS", "SHAMANS", "LEECHES", "SLUGS", "SKELETONS", "WIEDERGAENGER"]
## alter Begriff → Muster (ganzes Wort; Groß- und Kleinschreibung wie im Text)
const ALT := {
	"Rüstungsklasse": "(?i)rüstungsklasse|armou?r class",
	"RK/AC": "\\b(RK|AC)\\b",
	"W20/d20": "(?i)\\b[wd]20\\b",
	"Würfelsumme": "\\d+\\s*[+−-]\\s*\\d+\\s*=\\s*\\d+",
	"Würfelangabe": "\\b\\d+\\s*[Wd]\\d+\\b",
	"ZP/SP": "\\b(ZP|SP)\\b",     # TP/HP bleiben an Zahlen (DESIGN-BRS 13, STORY-BRS-OBERFLAECHE `hp`); Mana statt ZP
	"Rettungswurf": "(?i)rettungswurf|saving throw",
	"SG/DC": "\\b(SG|DC)\\s*\\d",
}

var fehler := 0
var muster := {}
var funde := {}


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	if Brs.lade().is_empty():
		print("BEGRIFFE868 FALSCH daten/werte.json fehlt")
		quit(1)
		return
	for k in ALT:
		var r := RegEx.new()
		r.compile(ALT[k])
		muster[k] = r
	var tables: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	var skills := {}
	for s in tables.skills:
		skills[s.id] = s
	var monsters := {}
	for m in tables.monsters:
		monsters[m.id] = m
	var zeilen := 0
	for lang in 2:
		for cls in tables.probe:
			for foe in GRUPPEN:
				for k in KAEMPFE:
					var dice := Wuerfel.new(8680 + k)
					var foes: Array = Aufruf.gegner(foe, monsters, dice)
					if foes.is_empty():
						continue
					var hs: Dictionary = (tables.probe[cls].hero.hero as Dictionary).duplicate(true)
					hs.level = 1
					var party := [Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), hs, int(tables.probe[cls].hero.hp), hs.second, skills)]
					var mars = Mars.new(party, foes, tables, dice, Wuerfel.new(868 + k))
					mars.lang = lang
					mars.brs_einrichten()
					mars.chosen = true
					var react := func(_t, _i) -> String: return Mars.NONE
					var ev: Array = mars.start(react)
					var zuege := 0
					while mars.outcome == "ONGOING" and zuege < 200:
						zuege += 1
						ev += mars.act(mars._auto_order(mars.current()), react)
					for e in ev:
						zeilen += 1
						_pruefe_text(str(e.get("text", "")), "%s %s %s" % [["de", "en"][lang], cls, foe])
						var it = e.get("intents", {})
						if it is Dictionary:
							for id in it:
								_pruefe_text(str(it[id]), "%s %s %s Ansage" % [["de", "en"][lang], cls, foe])
	_quelle("res://kampf/marstips.gd")
	_quelle("res://kampf/kampf_ui.gd")
	for k in funde:
		fehler += 1
		print("FALSCH %s: %d verschiedene Zeilen: %s" % [k, funde[k].size(), " | ".join(funde[k])])
	print("BEGRIFFE868 %s (%d Zeilen aus Kämpfen, %d Fundarten)" % ["gut" if fehler == 0 else "FEHLER", zeilen, funde.size()])
	quit(1 if fehler > 0 else 0)


func _pruefe_text(s: String, wo: String) -> void:
	if s == "":
		return
	for k in muster:
		if muster[k].search(s) != null:
			if not funde.has(k):
				funde[k] = []
			var kurz := s.left(100)
			if funde[k].size() < 20 and not funde[k].any(func(x): return x.ends_with("„%s“" % kurz)):
				funde[k].append("%s: „%s“" % [wo, kurz])


## Zeichenketten im Quelltext, ohne Kommentare (## und #); Schlüssel wie "AC" in Wörterbüchern zählen nicht (nur Text mit Leerzeichen)
func _quelle(pfad: String) -> void:
	var txt := FileAccess.get_file_as_string(pfad)
	var str_re := RegEx.new()
	str_re.compile("\"((?:[^\"\\\\]|\\\\.)*)\"")
	var n := 0
	for zeile in txt.split("\n"):
		n += 1
		var z := zeile.strip_edges()
		if z.begins_with("#"):
			continue
		for m in str_re.search_all(zeile):
			var s := m.get_string(1)
			if " " in s:
				_pruefe_text(s, "%s:%d" % [pfad.get_file(), n])
