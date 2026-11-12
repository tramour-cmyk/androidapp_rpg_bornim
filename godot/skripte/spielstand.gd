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
	var f := FileAccess.open(datei(platz), FileAccess.WRITE)
	if f == null: return
	f.store_string(JSON.stringify({"version": VERSION, "zustand": z.als_daten(), "held": hw.spiel_daten(), "ort": ort,
		"gespeichert": int(Time.get_unix_time_from_system() * 1000.0),   # ms wie alt savedAt
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

# 1021 (Chef 12.11., 08:09: „dann fängt es wieder von vorne an das Spiel, weil ich den Fokus weggemacht habe“; 08:14: „manchmal …
# und manchmal nicht“): gespeichert wird beim Pausieren schon (spiel.gd, 399); Android beendet die App aber im Hintergrund, wenn der
# Speicher knapp wird oder das Akkusparen zugreift, und der neue Start lief ueber Vorspann und Hauptmenue. Alt (MainActivity.kt 54)
# liess nur den Vorspann weg, das Hauptmenue blieb. Jetzt: wer das Spiel im Spiel verlaesst, hinterlaesst eine Marke; kommt die App nicht
# zurueck (RESUMED loescht sie), sondern startet neu, geht sie ohne Vorspann und Hauptmenue gleich in diesen Stand. Hat der Spieler sie
# selbst beendet (aus den letzten Apps gewischt, in den Einstellungen gestoppt; Ende laut System, Messung.letztes_ende), wie bisher.
const HINTERGRUND := "user://hintergrund.json"
const NUTZER_ENDE := [10, 11]         # ApplicationExitInfo.REASON_USER_REQUESTED, REASON_USER_STOPPED

static func merke_hintergrund() -> void:
	var f := FileAccess.open(HINTERGRUND, FileAccess.WRITE)
	if f: f.store_string(JSON.stringify({"platz": platz, "zeit": int(Time.get_unix_time_from_system() * 1000.0)}))

static func vergiss_hintergrund() -> void:
	if FileAccess.file_exists(HINTERGRUND): DirAccess.remove_absolute(ProjectSettings.globalize_path(HINTERGRUND))

## Beim Start einmal: der Platz, in den das Spiel gleich weitergeht, sonst 0. Die Marke ist danach weg, so fuehrt ein Absturz beim Laden
## nicht in eine Schleife. ende: Messung.letztes_ende() ({} am Rechner oder vor Android 11: dann gilt die Marke allein)
static func fortsetzen(ende: Dictionary) -> int:
	if not FileAccess.file_exists(HINTERGRUND): return 0
	var h = JSON.parse_string(FileAccess.get_file_as_string(HINTERGRUND))
	vergiss_hintergrund()
	if not h is Dictionary: return 0
	var p := int(h.get("platz", 0))
	if p < 1 or p > PLAETZE or lade(p).is_empty(): return 0
	if not ende.is_empty() and int(ende.get("zeit", 0)) >= int(h.get("zeit", 0)) and int(ende.get("grund", 0)) in NUTZER_ENDE: return 0
	return p
