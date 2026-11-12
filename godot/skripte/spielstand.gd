class_name Spielstand
# 399: ein Spielstand wie GameViewModel.save (alt: beim Kartenwechsel und beim Weg ins Menue): Zustand (GameState), Held (870.4: BrsHeld)
# und Ort; Fortsetzen im Hauptmenue laedt ihn.
# 399.1 (Spielstaende wie alt, GameViewModel.SLOTS, SlotsScreen.kt): vier Plaetze user://spielstand_<n>.json, gespeichert wird in den
# aktiven Platz; „Weiter“ laedt den zuletzt gespeicherten. Der eine Spielstand von Build 130–132 (user://spielstand.json) wird Platz 1.

const PLAETZE := 4
const ALT := "user://spielstand.json"
static var platz := 1                 # in diesen Platz speichert das Spiel

static func datei(n: int) -> String: return "user://spielstand_%d.json" % n

static func _umziehen() -> void:
	if FileAccess.file_exists(ALT) and not FileAccess.file_exists(datei(1)):
		DirAccess.rename_absolute(ProjectSettings.globalize_path(ALT), ProjectSettings.globalize_path(datei(1)))

static func gibt_es() -> bool:
	for n in range(1, PLAETZE + 1):
		if FileAccess.file_exists(datei(n)): return true
	return FileAccess.file_exists(ALT)

# 870.4: Version 2 traegt den Helden nach BRS (BrsHeld.spiel_daten)
const VERSION := 2

# 870.8 (870a 1 A, Chef 10.11., 15:08; DESIGN-BRS 11): Spielstaende aus der SRD-Zeit (Version 1, vor Build 130–132 ohne Version) laden
# nicht mehr; die Liste zeigt sie mit Hinweis und Loeschen, „Weiter“ und lade() uebergehen sie
static func alt(d: Dictionary) -> bool: return not d.is_empty() and int(d.get("version", 1)) < VERSION

static func speichere(z: Zustand, hw: BrsHeld, ort: Dictionary) -> void:
	_umziehen()
	# 1009: „Weiter“ nimmt den Platz mit der größten Zeit; zwei Speicherungen in derselben Millisekunde (oder eine zurückgestellte
	# Uhr) gaben den älteren. Darum immer nach allen anderen Plätzen: eine Millisekunde über der größten Zeit, wenn die Uhr nicht vorn ist
	var ms := int(Time.get_unix_time_from_system() * 1000.0)
	for d in liste():
		if not d.is_empty() and int(d["platz"]) != platz: ms = maxi(ms, int(d.get("gespeichert", 0)) + 1)
	var f := FileAccess.open(datei(platz), FileAccess.WRITE)
	if f == null: return
	f.store_string(JSON.stringify({"version": VERSION, "zustand": z.als_daten(), "held": hw.spiel_daten(), "ort": ort,
		"gespeichert": ms,   # ms wie alt savedAt
		# 529: die Ortszeit beim Speichern; die Karte zeigt sie, so stimmt „Gespeichert“ auch nach einer Zeitumstellung
		"gespeichert_ortszeit": Time.get_datetime_dict_from_system(false)}))

# n = 0: der zuletzt gespeicherte; den Platz zum aktiven macht spiel.gd (Spielstand.platz)
static func lade(n: int = 0) -> Dictionary:
	_umziehen()
	if n == 0: n = letzter()
	if n == 0 or not FileAccess.file_exists(datei(n)): return {}
	var d = JSON.parse_string(FileAccess.get_file_as_string(datei(n)))
	if not d is Dictionary or alt(d): return {}   # 870.8
	d["platz"] = n
	return d

# je Platz der Spielstand oder {} (GameViewModel.slots)
static func liste() -> Array:
	_umziehen()
	var r := []
	for n in range(1, PLAETZE + 1):
		var d = JSON.parse_string(FileAccess.get_file_as_string(datei(n))) if FileAccess.file_exists(datei(n)) else null
		if d is Dictionary: d["platz"] = n
		r.append(d if d is Dictionary else {})
	return r

static func letzter() -> int:
	var best := 0
	var zeit := -1
	for d in liste():
		if not d.is_empty() and not alt(d) and int(d.get("gespeichert", 0)) > zeit:   # 870.8
			zeit = int(d.get("gespeichert", 0))
			best = int(d["platz"])
	return best

static func frei() -> int:
	_umziehen()
	for n in range(1, PLAETZE + 1):
		if not FileAccess.file_exists(datei(n)): return n
	return 0

static func loesche(n: int) -> void:
	if FileAccess.file_exists(datei(n)): DirAccess.remove_absolute(ProjectSettings.globalize_path(datei(n)))
