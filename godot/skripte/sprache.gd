class_name Sprache
# 390 (Englisch): Sprache wie im alten Spiel (GameViewModel.lang): gespeicherte Wahl, sonst Deutsch nur auf deutschem Geraet.
# Texte kommen als {de, en} aus karten.json (Orte, Schilder, Gespraeche) und texte.json (Oberflaeche, TextExport.kt, Schluessel
# wie die Felder in Ui); Platzhalter {0}, {1} wie T.f.

const DATEI := "user://einstellungen.cfg"
static var lang := ""
static var ui := {}

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
	if ui.is_empty() and FileAccess.file_exists("res://daten/texte.json"):
		ui = JSON.parse_string(FileAccess.get_file_as_string("res://daten/texte.json")).get("ui", {})
	var s := t(ui.get(schluessel, schluessel))
	for i in werte.size(): s = s.replace("{%d}" % i, str(werte[i]))
	return s
