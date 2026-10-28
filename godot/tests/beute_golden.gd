extends SceneTree
# 390 (Laden, Beute): Gegenprobe skripte/kotlin_zufall.gd und skripte/beute.gd gegen kotlin.random.Random und Loot.kt:
# die ersten Zahlen fuer einige Saaten („zufall“), Thessas Ware fuer 96 Helden („laden“: Klassen, Stufen 1, 3, 6, 9, Namen mit
# Umlauten, Siege 0, 8, 17) die Beute aus 80 Kaempfen („beute“) und 60
# einzelne Stuecke aller Seltenheiten („wuerfe“), je Stueck mit Namen und Zeile in beiden Sprachen und Preis.
# Ohne Bild, Exit 0 oder 1. Vorher wie held_golden.gd (held_proben.json). Aufruf: im Ordner godot mit -s res://tests/beute_golden.gd

const PROBEN := "res://daten/held_proben.json"

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if JSON.stringify(ist) != JSON.stringify(soll):
		fehler += 1
		if fehler <= 12: print("FALSCH ", was, ":\n  ist  ", JSON.stringify(ist), "\n  soll ", JSON.stringify(soll))

# Stueck wie HeroExport.shown, Zahlen als Zahlen (JSON liest float)
func gezeigt(g: Dictionary) -> Dictionary:
	var rolls: Array = []
	for r in g["rolls"]: rolls.append([String(r[0]), int(r[1])])
	return {"uid": int(g["uid"]), "base": String(g["base"]), "rarity": String(g["rarity"]), "ilvl": int(g["ilvl"]), "plus": int(g["plus"]),
		"rolls": rolls, "unique": g.get("unique"), "name_seed": int(g.get("name_seed", 0)), "de": Beute.name(g, "de"), "en": Beute.name(g, "en"),
		"preis": Beute.preis(g), "zeile_de": Beute.listen_zeile(g, "de"), "zeile_en": Beute.listen_zeile(g, "en")}

func liste(a: Array) -> Array:
	var out: Array = []
	for g in a: out.append(gezeigt(g))
	return out

# was Kotlin sagt, ohne es mit dem Port nachzurechnen
func soll_liste(a: Array) -> Array:
	var out: Array = []
	for g in a:
		var x := gezeigt(g)
		x["de"] = String(g["de"]); x["en"] = String(g["en"]); x["preis"] = int(g["preis"])
		x["zeile_de"] = String(g["zeile_de"]); x["zeile_en"] = String(g["zeile_en"])
		out.append(x)
	return out

func _init() -> void:
	var d = JSON.parse_string(FileAccess.get_file_as_string(PROBEN)) if FileAccess.file_exists(PROBEN) else null
	if not d is Dictionary or not d.has("laden"):
		print("BEUTE fehlt: ", PROBEN, " (mit laden, beute, zufall)")
		quit(1)
		return
	Heldwerte.daten = d
	Sprache.lade()
	pruefe("Hash", [KotlinZufall.hash_code("Alrik"), KotlinZufall.hash_code("Jörg Ölschläger"), KotlinZufall.hash_code("")],
		[int(d["zufall"][-1]["seed"]), KotlinZufall.hash_code("Jörg Ölschläger"), 0])
	for z in d["zufall"]:
		var r := KotlinZufall.new(int(z["seed"]))
		var ints: Array = []
		for i in 8: ints.append(r.next_int_raw())
		var bis: Array = []
		for n in [1, 2, 3, 6, 7, 20, 64, 1000, 10000, 0x7FFFFFFF]: bis.append(r.next_below(n))
		var von: Array = []
		for p in [[1, 7], [1, 21], [-5, 5]]: von.append(r.next_int(p[0], p[1]))
		# Kommazahlen: Godot liest JSON nicht immer aufs letzte Bit genau; die Rechnung selbst ist exakt (ganze Zahl / 2^53)
		var dbl: Array = []
		for i in 4: dbl.append(absf(r.next_double() - float(z["double"][i])) < 1e-15)
		pruefe("Zufall %d" % int(z["seed"]), [ints, bis, von, dbl], [z["int"].map(func(x): return int(x)), z["bis"].map(func(x): return int(x)),
			z["von"].map(func(x): return int(x)), [true, true, true, true]])
	var n := 0
	for p in d["laden"]:
		n += 1
		var h := Heldwerte.aus_daten(p["held"])
		pruefe("Laden %s %s Stufe %d, %d Siege" % [h.name, h.klasse, h.stufe, int(p["siege"])], liste(Beute.ladenware(h, int(p["siege"]))),
			soll_liste(p["soll"]))
	for p in d["beute"]:
		n += 1
		var h := Heldwerte.aus_daten(p["held"])
		var w := KotlinZufall.new(int(p["seed"]))
		var uid := [0]
		var neu := func() -> int:
			uid[0] += 1
			return uid[0]
		pruefe("Beute %d" % int(p["seed"]), liste(Beute.beute(h, w, int(p["ilvl"]), bool(p["boss"]), bool(p["elite"]), neu)), soll_liste(p["soll"]))
	for p in d["wuerfe"]:
		n += 1
		var w := KotlinZufall.new(int(p["seed"]))
		pruefe("Wurf %d" % int(p["seed"]), liste([Beute.wuerfle(int(p["seed"]), String(p["base"]), int(p["ilvl"]), String(p["rarity"]), w)]), soll_liste(p["soll"]))
	print("BEUTE %d Proben, %d Fehler" % [n, fehler])
	quit(1 if fehler else 0)
