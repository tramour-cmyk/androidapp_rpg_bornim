# 532 (Abgleich 512, alt Battle.kt init, Game.keepAilments): der Held bringt Verbrauchtes („einmal je Rast“) und Zustände in den
# Kampf mit; danach bleiben Gift, Blutung, Schwäche (Gift und Blutung um den Konstitutionsbonus kürzer), verloren nichts;
# Verbrauchtes übersteht Speichern und Laden. Ohne Bild. Aufruf: im Ordner godot mit -s res://tests/kampfzustand_532.gd
extends SceneTree

const AufrufS = preload("res://kampf/aufruf.gd")
const Mars = preload("res://regeln/mars.gd")

var fehler := 0


func _init() -> void:
	_lauf.call_deferred()


func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)


func _lauf() -> void:
	var tabellen: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	var skills := {}
	for s in tabellen.skills:
		skills[s.id] = s
	var h := Heldwerte.erschaffe("Probe", "HUMAN", "FIGHTER")
	h.stufe = 5
	h.voll()
	var hat_schub: bool = "ACTION_SURGE" in AufrufS.blatt(h).skills
	pruefe(hat_schub, "Kämpfer Stufe 5 ohne ACTION_SURGE: %s" % [AufrufS.blatt(h).skills])
	var a := AufrufS.new()
	var f = a._kaempfer("hero", h, -1, Vector2i(Mars.FRONT, 0), skills)
	pruefe(int(f.uses.get("ACTION_SURGE", -1)) == 1, "ausgeruht: Tatendrang %s statt 1" % f.uses.get("ACTION_SURGE"))
	h.verbraucht["ACTION_SURGE"] = 1
	f = a._kaempfer("hero", h, -1, Vector2i(Mars.FRONT, 0), skills)
	pruefe(int(f.uses.get("ACTION_SURGE", -1)) == 0, "verbraucht: Tatendrang %s statt 0" % f.uses.get("ACTION_SURGE"))
	# Spielstand
	var h2 := Heldwerte.aus_daten(JSON.parse_string(JSON.stringify(h.als_daten())))
	pruefe(int(h2.verbraucht.get("ACTION_SURGE", 0)) == 1, "Verbrauchtes nach Laden: %s" % [h2.verbraucht])
	# Zustände hinein: nur, was MARS kennt
	AufrufS.leiden_auf(f, {"POISON": 3, "DRUNK": 99, "WEAK": 99})
	pruefe(f.status.get("POISON", 0) == 3 and f.status.get("WEAK", 0) == 99 and not f.status.has("DRUNK"), "Zustände hinein: %s" % [f.status])
	# heraus
	f.status["STUN"] = 1
	f.status["BLEED"] = 2
	var nach := AufrufS.leiden_nach(f, "WON", 1)
	pruefe(nach == {"POISON": 2, "WEAK": Mars.LASTING, "BLEED": 1}, "Zustände heraus (Kon +1): %s" % [nach])
	pruefe(AufrufS.leiden_nach(f, "LOST", 0).is_empty(), "verloren: Zustände bleiben")
	pruefe(AufrufS.leiden_nach(null, "WON", 0).is_empty(), "ohne Kampf: Zustände")
	a.free()
	print("KAMPFZUSTAND 532 %s" % ("ok" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
