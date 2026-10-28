class_name Spielstand
# 399: ein Spielstand wie GameViewModel.save (alt: beim Kartenwechsel und beim Weg ins Menue): Zustand (GameState), Heldwerte (Hero)
# und Ort in user://spielstand.json; Fortsetzen im Hauptmenue laedt ihn.

const DATEI := "user://spielstand.json"

static func gibt_es() -> bool: return FileAccess.file_exists(DATEI)

static func speichere(z: Zustand, hw: Heldwerte, ort: Dictionary) -> void:
	var f := FileAccess.open(DATEI, FileAccess.WRITE)
	if f == null: return
	f.store_string(JSON.stringify({"version": 1, "zustand": z.als_daten(), "held": hw.als_daten(), "ort": ort}))

static func lade() -> Dictionary:
	if not gibt_es(): return {}
	var d = JSON.parse_string(FileAccess.get_file_as_string(DATEI))
	return d if d is Dictionary else {}
