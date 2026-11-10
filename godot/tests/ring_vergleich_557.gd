extends SceneTree
# 557 Ausbessern (Chef 04.11., 19:54; Pruefer 19:47 an Vorlage 3: im Vergleich fehlt die Zeile Geschicklichkeit, auch Staerke trotz
# „+1 alle Attribute“; Vorlage 4: RK 18 -> 23 passt nicht zu „RK 19“ und „+2 RK, wirkt +1“): ohne Bildbefehl, dieselben Stuecke wie
# spielstaende_bild_557.gd _fenster (Krieger Thora, angelegt Ring +2 GES +2 STAE; neu Ring +1 alle, +2 GES, +2 CHA; Kettenpanzer
# aus Saat 5). Gibt die Zeilen des Vergleichs und die Werte aus und prueft: jede Aenderung eines Attributs hat eine Zeile, die RK
# des Vergleichs ist die nach dem Anlegen gerechnete. Aufruf: im Ordner godot mit -s res://tests/ring_vergleich_557.gd (Exit 0 = gut)

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func _pruef(was: String, gut: bool) -> void:
	print(("gut " if gut else "FALSCH ") + was)
	if not gut: fehler += 1

func _ring(z: Zustand, saat: int, rolls: Array) -> Dictionary:
	return {"uid": z.neue_uid.call(), "base": "ring", "rarity": "DIVINE", "ilvl": 9, "plus": 0, "rolls": rolls, "unique": null, "name_seed": saat}

func _werte(h: Heldwerte) -> Dictionary:
	var r := {}
	for a in ["STR", "DEX", "CON", "INT", "WIS", "CHA"]: r[a] = [h.wert(a), h.roh_bonus(a), h.ausruestungs_bonus(a)]
	return r

func _lauf() -> void:
	var z := Zustand.new()
	var hw := Heldwerte.erschaffe("Thora", "HUMAN", "FIGHTER", {}, z.neue_uid)
	hw.anlegen(_ring(z, 1, [["DEX", 2], ["STR", 2]]))
	var neu := _ring(z, 0, [["ALL_STATS", 1], ["DEX", 2], ["CHA", 2]])
	var vor := _werte(hw)
	print("vorher ", vor, " ALL roh ", hw.roh_bonus("ALL_STATS"))
	var v := Vergleich.von(hw, neu)
	for r in v.zeilen: print("ZEILE ", r)
	var k := Heldwerte.aus_daten(hw.als_daten())
	k.anlegen(neu)
	var nach := _werte(k)
	print("nachher ", nach, " ALL roh ", k.roh_bonus("ALL_STATS"))
	var worte := v.zeilen.map(func(r): return String(r["wort"]))
	var d := Heldwerte.lade()
	# 701 (Chef 08.11., 20:37: wiederholter Hinweis auf die Obergrenze „wirkt überbordend“): ein Mehr, das die Obergrenze schluckt, steht
	# in der Sammelzeile (im Fenster B nur an der Bonuszeile, „doppelt“); jede andere Aenderung hat ihre Zeile
	var sammel: String = " ".join(PackedStringArray(v.zeilen.filter(func(r): return bool(r.get("doppelt", false)) and String(r["wort"]) in ["Attribute", "Abilities"]).map(func(r): return String(r["notiz"]))))
	for a in nach:
		if nach[a][0] != vor[a][0] or nach[a][1] != vor[a][1] or k.roh_bonus("ALL_STATS") != hw.roh_bonus("ALL_STATS"):
			var nm := Sprache.t(d["attribute"][a]["name"])
			var mehr_gedeckelt: bool = nach[a][0] == vor[a][0] and nach[a][1] + k.roh_bonus("ALL_STATS") > vor[a][1] + hw.roh_bonus("ALL_STATS")
			_pruef("%s %d -> %d (Bonus roh %d -> %d) hat %s" % [a, vor[a][0], nach[a][0], vor[a][1], nach[a][1], "die Sammelzeile" if mehr_gedeckelt else "eine Zeile"],
				(sammel.contains(nm) or sammel.begins_with("Alle")) if mehr_gedeckelt else nm in worte)
	_pruef("Sammelzeile Attribute nur für den Deckel (doppelt)", v.zeilen.all(func(r): return not String(r["wort"]) in ["Attribute", "Abilities"] or bool(r.get("doppelt", false))))
	var panzer := Beute.erzeuge_mit_uid(KotlinZufall.new(5), z.neue_uid, 9, "DIVINE", "FIGHTER")
	print("PANZER ", panzer)
	print("RK vorher ", hw.rk())
	var vp := Vergleich.von(hw, panzer)
	for r in vp.zeilen: print("PZEILE ", r)
	var kp := Heldwerte.aus_daten(hw.als_daten())
	kp.anlegen(panzer)
	print("RK nachher ", kp.rk(), " roh AC ", kp.roh_bonus("AC"), " wirkt AC ", kp.bonus("AC"))
	# nachgerechnet: Kettenhemd 16 + plus 3 (= „RK 19“ im Fenster) + Kampfstil Verteidigung 1 + Schild 2 + AC-Bonus wirkt 1 = 23
	var g := Heldwerte.grundform(panzer["base"])
	var soll := int(g["ruestung"]) + int(panzer["plus"]) + (1 if kp.hat("FIGHTING_STYLE") else 0) + kp.bonus("AC")
	var schild = kp.ding("OFF_HAND")
	if schild != null and String(Heldwerte.grundform(schild["base"])["art"]) == "SHIELD": soll += int(Heldwerte.grundform(schild["base"])["ruestung"]) + int(schild["plus"])
	_pruef("RK nach dem Anlegen %d = Panzer %d + plus %d + Kampfstil + Schild + Bonus (%d)" % [kp.rk(), int(g["ruestung"]), int(panzer["plus"]), soll], kp.rk() == soll)
	print("RINGVERGLEICH557 %d Fehler" % fehler)
	quit(1 if fehler else 0)
