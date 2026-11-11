# 532 (Abgleich 512, alt Battle.kt init, Game.keepAilments): der Held bringt Zustände in den Kampf mit; danach bleiben Gift,
# Blutung, Schwäche (Gift und Blutung um den Bonus kürzer, 870.4: nach Zähigkeit), verloren nichts. 870.4: Verbrauchtes „einmal je
# Rast“ entfällt mit den Klassenfähigkeiten. Ohne Bild. Aufruf: im Ordner godot mit -s res://tests/kampfzustand_532.gd
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
	var tabellen: Dictionary = Tabellen.lade()
	var skills := {}
	for s in tabellen.skills:
		skills[s.id] = s
	var h := BrsHeld.fuer_spiel("Probe", "Mensch", "Wachsoldat")
	h.stufe = 5
	h.voll()
	# 870.4: keine Klassenfaehigkeiten „einmal je Rast“ mehr (870a 3); der Held kommt mit seinem Leben nach BRS in den Kampf
	var a := AufrufS.new()
	h.leben = 7
	var f = a._kaempfer("hero", h, -1, Vector2i(Mars.FRONT, 0), skills)
	pruefe(int(f.hp) == 7 and int(f.max_hp) == h.max_leben(), "Leben im Kampf %d/%d statt 7/%d" % [f.hp, f.max_hp, h.max_leben()])
	pruefe(AufrufS.blatt(h).skills.is_empty(), "Blatt ohne Klassenfaehigkeiten: %s" % [AufrufS.blatt(h).skills])
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
