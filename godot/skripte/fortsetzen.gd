class_name Fortsetzen
extends RefCounted
# 1021 (Chef 12.11., 08:09: „dann fängt es wieder von vorne an das Spiel, weil ich den Fokus weggemacht habe“): wechselt man am Handy
# in eine andere App, darf Android das Spiel im Hintergrund beenden (viel Speicher); beim Zurückkehren begann es dann mit Vorspann und
# Hauptmenü. Beim Pausieren speichert spiel.gd ohnehin (399); jetzt merkt es sich dazu Platz und Uhrzeit. Kommt die App zurück, ohne
# beendet worden zu sein, wird die Marke gelöscht; wurde sie beendet und startet binnen FRIST_S neu, geht es ohne Vorspann und
# Hauptmenü gleich im Spielstand weiter. Die Zeile „FORTSETZEN …“ steht im Protokoll (Absturzbericht im Reiter „Test“).

const DATEI := "user://fortsetzen.cfg"
const FRIST_S := 1800          # eine halbe Stunde; danach wie ein gewöhnlicher Start

static func merke(platz: int) -> void:
	var c := ConfigFile.new()
	c.set_value("pause", "platz", platz)
	c.set_value("pause", "zeit", int(Time.get_unix_time_from_system()))
	c.save(DATEI)

static func vergiss() -> void:
	if FileAccess.file_exists(DATEI): DirAccess.remove_absolute(ProjectSettings.globalize_path(DATEI))

## Platz, in dem es nach einem Ende im Hintergrund weitergeht, sonst 0. [jetzt] Unix-Sekunden (Tests), -1: die Uhr
static func offen(jetzt := -1) -> int:
	var c := ConfigFile.new()
	if c.load(DATEI) != OK: return 0
	var p := int(c.get_value("pause", "platz", 0))
	var vor := (int(Time.get_unix_time_from_system()) if jetzt < 0 else jetzt) - int(c.get_value("pause", "zeit", 0))
	if p < 1 or vor < 0 or vor > FRIST_S or not FileAccess.file_exists(Spielstand.datei(p)):
		print("FORTSETZEN nein: Platz %d, Pause vor %d s" % [p, vor])
		return 0
	print("FORTSETZEN Platz %d nach Pause vor %d s (Android hatte das Spiel im Hintergrund beendet)" % [p, vor])
	return p
