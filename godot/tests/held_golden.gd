extends SceneTree
# 390: Gegenprobe Heldwerte (skripte/heldwerte.gd) gegen Hero.kt: jede Probe aus HeroExport (320 Helden, alle Voelker und
# Klassen, Stufen 1, 3, 7, 20, vier Ausruestungen) mit den Zahlen des alten Spiels. Ohne Bild, endet mit Exit 0 oder 1.
# Vorher: ./gradlew -p core exportHero -Pout=$PWD/godot/daten/held.json -Pproben=$PWD/godot/daten/held_proben.json
# Aufruf (zaehlt als Probelauf, 389, bis 390a entschieden ist): Godot unsichtbar im Ordner godot mit -s res://tests/held_golden.gd

const PROBEN := "res://daten/held_proben.json"

func _init() -> void:
	var d = JSON.parse_string(FileAccess.get_file_as_string(PROBEN)) if FileAccess.file_exists(PROBEN) else null
	if not d is Dictionary:
		print("HELD fehlt: ", PROBEN)
		quit(1)
		return
	Heldwerte.daten = d
	var fehler := 0
	var n := 0
	for p in d["proben"]:
		n += 1
		var h := Heldwerte.aus_daten(p["held"])
		var soll: Dictionary = p["soll"]
		var ist := {
			"max_tp": h.max_tp(), "max_zp": h.max_zp(), "uebung": h.uebung(), "rk": h.rk(), "rk_magier": h.rk(true),
			"angriff": h.angriff(), "schaden": h.schaden(), "beide_haende": h.beide_haende(), "zauberangriff": h.zauberangriff(),
			"zauber_sg": h.zauber_sg(), "krit_ab": h.krit_ab(), "lebensraub": h.lebensraub(), "schadensminderung": h.schadensminderung(),
			"standhaft": h.standhaft(), "faehigkeiten": h.faehigkeiten(),
			"neben_schaden": h.schaden_mit(h.nebenwaffe(), true) if h.nebenwaffe() != null else null,
		}
		var werte := {}
		var mods := {}
		for a in Heldwerte.ATTRIBUTE:
			werte[a] = h.wert(a); mods[a] = h.mod(a)
		ist["werte"] = werte; ist["mods"] = mods
		var boni := {}
		for a in d["affixe"]: boni[a] = h.bonus(a)
		ist["boni"] = boni
		for k in soll:
			if not ist.has(k): continue
			if JSON.stringify(normal(ist[k])) != JSON.stringify(normal(soll[k])):
				fehler += 1
				if fehler <= 20: print("HELD Probe %d (%s %s Stufe %d) %s: ist %s, soll %s" % [n, h.volk, h.klasse, h.stufe, k, JSON.stringify(ist[k]), JSON.stringify(soll[k])])
	print("HELD %d Proben, %d Abweichungen" % [n, fehler])
	quit(1 if fehler > 0 else 0)

# Zahlen aus JSON sind float: fuer den Vergleich alle ganzen Zahlen als int, Woerterbuecher sortiert
func normal(v):
	if v is float and v == floorf(v): return int(v)
	if v is Array: return v.map(func(x): return normal(x))
	if v is Dictionary:
		var r := {}
		var ks: Array = v.keys()
		ks.sort()
		for k in ks: r[String(k)] = normal(v[k])
		return r
	return v
