class_name Sprache
# 390 (Englisch): Sprache wie im alten Spiel (GameViewModel.lang): gespeicherte Wahl, sonst Deutsch nur auf deutschem Geraet.
# Texte kommen als {de, en} aus karten.json (Orte, Schilder, Gespraeche) und texte.json (Oberflaeche, TextExport.kt, Schluessel
# wie die Felder in Ui); Platzhalter {0}, {1} wie T.f.

const DATEI := "user://einstellungen.cfg"
static var lang := ""
static var ui := {}
static var texte := {}

static func aktiv() -> String:
	if lang == "":
		var c := ConfigFile.new()
		if c.load(DATEI) == OK: lang = String(c.get_value("spiel", "sprache", ""))
		if lang != "de" and lang != "en": lang = "de" if OS.get_locale_language() == "de" else "en"
	return lang

static func setze(l: String) -> void:
	lang = l
	var c := ConfigFile.new()
	c.load(DATEI)
	c.set_value("spiel", "sprache", l)
	c.save(DATEI)

static func wechsle() -> void: setze("en" if aktiv() == "de" else "de")

# ein Text {de, en} in der aktiven Sprache; fehlt sie, Deutsch
static func t(text) -> String:
	if text is Dictionary: return String(text.get(aktiv(), text.get("de", "")))
	return String(text) if text != null else ""

# Text der Oberflaeche nach Schluessel (Ui.newGame -> "newGame"), Platzhalter der Reihe nach
static func u(schluessel: String, werte: Array = []) -> String:
	lade()
	var s := t(ui.get(schluessel, schluessel))
	for i in werte.size(): s = s.replace("{%d}" % i, str(werte[i]))
	return s

# 390 (Rast): Text der Rast nach Schluessel (Resting.shortRested -> "shortRested"), Platzhalter wie u
static func r(schluessel: String, werte: Array = []) -> String:
	lade()
	var s := t(texte.get("rast", {}).get(schluessel, schluessel))
	for i in werte.size(): s = s.replace("{%d}" % i, str(werte[i]))
	return s

# 390 (Laden): Morwens Saetze beim Brauen (Game.Msgs brewed, brewedTwo, missing)
static func l(schluessel: String, werte: Array = []) -> String:
	lade()
	var s := t(texte.get("laden", {}).get(schluessel, schluessel))
	for i in werte.size(): s = s.replace("{%d}" % i, str(werte[i]))
	return s

# Name eines Dings fuer "Erhalten: …" wie Game.runQueue (Cmd.Give): Einzelstueck mit Seltenheit, sonst Anzahl und Name
static func ding(id: String, anzahl: int = 1) -> String:
	lade()
	var e: Dictionary = texte.get("einzelstuecke", {})
	if e.has(id): return "%s (%s)" % [t(e[id]["name"]), t(e[id]["seltenheit"])]
	var d: Dictionary = texte.get("dinge", {})
	return ("%d× " % anzahl if anzahl > 1 else "") + (t(d[id]["name"]) if d.has(id) else id)

# 870.4 (Homer 870.15, STORY-BRS-OBERFLAECHE.md „ui“ und „rast“): Woerter nach dem BRS ueber dem Export der alten Fassung, bis
# die Texte mit 870.9 Godot-Quelle sind; Wortlaut von dort
const BRS := {
	"ui": {
		"sp": {"de": "Mana", "en": "Mana"},
		"skills": {"de": "Fertigkeiten", "en": "Skills"},
		"chooseRace": {"de": "Wähle dein Volk", "en": "Choose your people"},
		"alreadyFull": {"de": "Dein Leben ist schon voll.", "en": "Your life is already full."},
	},
	"rast": {
		"short": {"de": "Kurze Erholung · 2 Stunden", "en": "Short Respite · 2 hours"},
		"long": {"de": "Langes Ausruhen · 9 Stunden", "en": "Long Rest · 9 hours"},
		"shortDoes": {"de": "Ausdauer voll, ein Teil des Lebens zurück", "en": "Full stamina, some of your life back"},
		"longDoes": {"de": "Leben, Mana und Ausdauer voll, Zustände geheilt", "en": "Life, mana and stamina full, conditions cured"},
		"longDone": {"de": "Das Lange Ausruhen hattest du heute schon.", "en": "You have already had your Long Rest today."},
		"roomDoes": {"de": "Ein Bett oben unter dem Dach: Langes Ausruhen", "en": "A bed upstairs under the roof: Long Rest"},
		"hourGone": {"de": "Zwei Stunden vergehen.", "en": "Two hours pass."},
		"hoursGone": {"de": "Neun Stunden vergehen.", "en": "Nine hours pass."},
		"shortRested": {"de": "Zwei Stunden Ruhe. Die Ausdauer ist voll, +{0} TP.", "en": "Two hours of rest. Your stamina is full, +{0} HP."},
		"longRested": {"de": "Neun Stunden Schlaf. Leben, Mana und Ausdauer sind voll.", "en": "Nine hours of sleep. Life, mana and stamina are full."},
		"roomRested": {"de": "Du steigst die Treppe hinauf und schläfst neun Stunden. Leben, Mana und Ausdauer sind voll.",
			"en": "You climb the stairs and sleep for nine hours. Life, mana and stamina are full."},
	},
}

static func lade() -> void:
	if texte.is_empty() and FileAccess.file_exists("res://daten/texte.json"):
		var j = JSON.parse_string(FileAccess.get_file_as_string("res://daten/texte.json"))
		if j is Dictionary:
			texte = j
			for teil in BRS:
				if not texte.has(teil): texte[teil] = {}
				for k in BRS[teil]: texte[teil][k] = BRS[teil][k]
			ui = texte.get("ui", {})
	if texte.is_empty(): push_warning("390: daten/texte.json fehlt (eingecheckt seit 870.9)")
