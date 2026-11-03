class_name Katalog
extends RefCounted
# 458.2: der Gegenstandskatalog (tools/gegenstaende/gegenstaende.json, im Bau nach daten/gegenstaende.json kopiert) ist die
# einzige Quelle fuer Stufe und Preis aller Gegenstaende: Grundformen der Ausruestung (heldwerte.gd legt sie ueber held.json),
# Dinge im Laden (laden.gd) und Einzelstuecke. Preis 0 heisst unverkaeuflich (458.2a). Gegenprobe: tests/katalog_test.gd.

const DATEI := "res://daten/gegenstaende.json"

static var alle := {}                  # Kennung -> Eintrag

static func lade() -> Dictionary:
	if alle.is_empty():
		var j = JSON.parse_string(FileAccess.get_file_as_string(DATEI)) if FileAccess.file_exists(DATEI) else null
		if j is Dictionary:
			for g in j.get("gegenstaende", []): alle[String(g["id"])] = g
		else:
			push_error("458.2: %s fehlt oder ist kaputt" % DATEI)
	return alle

static func hat(id: String) -> bool: return lade().has(id)
static func eintrag(id: String) -> Dictionary: return lade().get(id, {})
# null im Katalog (noch offen) zaehlt wie 0: kein Preis, ab Stufe 1
static func preis(id: String) -> int:
	var p = eintrag(id).get("preis")
	return 0 if p == null else int(p)
static func stufe(id: String) -> int:
	var s = eintrag(id).get("stufe")
	return 1 if s == null else int(s)
static func verkaeuflich(id: String) -> bool: return preis(id) > 0
