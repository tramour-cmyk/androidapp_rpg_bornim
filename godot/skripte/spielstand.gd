class_name Spielstand
# 399: ein Spielstand wie GameViewModel.save (alt: beim Kartenwechsel und beim Weg ins Menue): Zustand (GameState), Heldwerte (Hero)
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

static func speichere(z: Zustand, hw: Heldwerte, ort: Dictionary) -> void:
	_umziehen()
	var f := FileAccess.open(datei(platz), FileAccess.WRITE)
	if f == null: return
	f.store_string(JSON.stringify({"version": 1, "zustand": z.als_daten(), "held": hw.als_daten(), "ort": ort,
		"gespeichert": int(Time.get_unix_time_from_system() * 1000.0)}))   # ms wie alt savedAt

# n = 0: der zuletzt gespeicherte; den Platz zum aktiven macht spiel.gd (Spielstand.platz)
static func lade(n: int = 0) -> Dictionary:
	_umziehen()
	if n == 0: n = letzter()
	if n == 0 or not FileAccess.file_exists(datei(n)): return {}
	var d = JSON.parse_string(FileAccess.get_file_as_string(datei(n)))
	if not d is Dictionary: return {}
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
		if not d.is_empty() and int(d.get("gespeichert", 0)) > zeit:
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
