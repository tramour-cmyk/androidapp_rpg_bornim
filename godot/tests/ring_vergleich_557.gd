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

func _werte(h: BrsHeld) -> Dictionary:
	var r := {}
	for g in BrsHeld.grundwerte(): r[g] = [h.wert(g), h.roh_bonus(BrsHeld.AFFIX[g]), h.ausruestungs_bonus(g)]
	return r

func _lauf() -> void:
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	hw.anlegen(_ring(z, 1, [["DEX", 2], ["STR", 2]]))
	var neu := _ring(z, 0, [["ALL_STATS", 1], ["DEX", 2], ["CHA", 2]])
	var vor := _werte(hw)
	print("vorher ", vor, " ALL roh ", hw.roh_bonus("ALL_STATS"))
	var v := Vergleich.von(hw, neu)
	for r in v.zeilen: print("ZEILE ", r)
	var k := hw.kopie()
	k.anlegen(neu)
	var nach := _werte(k)
	print("nachher ", nach, " ALL roh ", k.roh_bonus("ALL_STATS"))
	var worte := v.zeilen.map(func(r): return String(r["wort"]))
	# 870.4: nach BRS hat jeder Grundwert, dessen Wert sich aendert, seine Zeile (ein Mehr, das die Obergrenze schluckt, aendert nichts)
	for g in nach:
		if nach[g][0] != vor[g][0]:
			var nm := ErschaffungBrs.tx(ErschaffungBrs.GRUNDWERT[g])
			_pruef("%s %d -> %d hat eine Zeile" % [g, vor[g][0], nach[g][0]], nm in worte)
	var panzer := Beute.erzeuge_mit_uid(KotlinZufall.new(5), z.neue_uid, 9, "DIVINE", "")
	print("PANZER ", panzer)
	print("Schutzwert vorher ", hw.schutzwert())
	var vp := Vergleich.von(hw, panzer)
	for r in vp.zeilen: print("PZEILE ", r)
	var kp := hw.kopie()
	kp.anlegen(panzer)
	var zs := vp.zeilen.filter(func(r): return String(r["wort"]) in ["Schutzwert", "Protection"])
	if kp.schutzwert() != hw.schutzwert():
		_pruef("Schutzwert im Vergleich %s = nach dem Anlegen %d" % [zs, kp.schutzwert()], not zs.is_empty() and String(zs[0]["nachher"]) == str(kp.schutzwert()))
	else:
		_pruef("Schutzwert gleich, keine Zeile", zs.is_empty())
	print("RINGVERGLEICH557 %d Fehler" % fehler)
	quit(1 if fehler else 0)
