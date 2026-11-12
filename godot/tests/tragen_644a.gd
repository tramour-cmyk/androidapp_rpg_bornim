extends SceneTree
# 644a.2 (644a A, D, F; DESIGN-BRS.md 11 „Gegenstandsstufe“), ohne Bild: Mindeststufe zum Anlegen (Getragenes bleibt), gewöhnliche Stücke
# in der Stufe ihrer Grundform, Gaben höchstens Heldenstufe + 1, Einzelstücke mit Stufe aus dem Katalog (Truhe der Blutzahnhöhle 3,
# 644a Vorentscheid), Händler nur Tragbares und in Kapitel 1 ohne Grundwert, Meldung „Kraft ↑ n“ nach dem Üben.
# Aufruf: im Ordner godot mit -s res://tests/tragen_644a.gd -> „TRAGEN644A n Fehler“ (Exit 0 = richtig)

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		print("FALSCH " + was)
		fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func _held(stufe: int, hk := "Wachsoldat") -> BrsHeld:
	var h := BrsHeld.fuer_spiel("Probe", "Mensch", hk)
	h.stufe = stufe
	h.voll()
	return h

func stueck(base: String, ilvl: int, rarity := "UNCOMMON") -> Dictionary:
	return {"uid": 900 + ilvl, "base": base, "rarity": rarity, "ilvl": ilvl, "guete": 0, "rolls": [], "unique": null, "name_seed": 0}

func _lauf() -> void:
	Sprache.lade()
	Sprache.setze("de")
	_mindeststufe()
	_gewoehnlich()
	_laden()
	await _gaben()
	print("TRAGEN644A %d Fehler" % fehler)
	quit(1 if fehler else 0)

func _mindeststufe() -> void:
	var h := _held(3)
	pruefe(h.kann_tragen(stueck("longsword", 3)), "Stufe 3 trägt ein Stück der Stufe 3")
	pruefe(not h.kann_tragen(stueck("longsword", 4)), "Stufe 3 trägt kein Stück der Stufe 4")
	# Getragenes bleibt (Testmenü, alte Spielstände legen ohne Prüfung an)
	var hoch := stueck("longsword", 6)
	h.anlegen(hoch)
	h.voll(); h.begrenze()
	pruefe(h.waffe() != null and int(h.waffe()["uid"]) == int(hoch["uid"]), "angelegtes Stück der Stufe 6 bleibt an")
	var blatt := h.mein_kampfblatt()
	pruefe(not blatt.is_empty(), "Kampfblatt mit zu hohem Stück")
	# im Menü: Anlegen nur, was er tragen kann (menue.gd lege_an)
	var z := Zustand.new()
	var m := Menue.new(h, z)
	z.beutel.append(stueck("dagger", 5))
	pruefe(m.lege_an(z.beutel[0]) == "" and h.waffe() != null and int(h.waffe()["uid"]) == int(hoch["uid"]), "Menü legt Stufe 5 bei Stufe 3 nicht an")
	m.free()

func _gewoehnlich() -> void:
	var w := KotlinZufall.new(644)
	for id in ["longsword", "plate", "chain_shirt", "dagger"]:
		var g := Beute.wuerfle(1, id, 5, "COMMON", w)
		pruefe(int(g["ilvl"]) == Katalog.stufe(id), "gewöhnlich %s: Stufe %d wie die Grundform (%d)" % [id, int(g["ilvl"]), Katalog.stufe(id)])
	var u := Beute.wuerfle(1, "longsword", 5, "UNCOMMON", w)
	pruefe(int(u["ilvl"]) == 5, "ungewöhnlich behält die Fundstufe (%d)" % int(u["ilvl"]))
	pruefe(not _held(6).kann_tragen(Beute.wuerfle(1, "plate", 1, "COMMON", w)), "Plattenpanzer (Stufe %d) erst ab seiner Stufe" % Katalog.stufe("plate"))

func _hat_grundwert(g: Dictionary) -> bool:
	return (g["rolls"] as Array).any(func(r): return Beute.ist_grundwert(String(r[0])))

func _laden() -> void:
	var mit := 0
	var stuecke := 0
	for hk in ["Wachsoldat", "Jägerkind", "Zauberlehrling", "Kräutersammler", "Wanderer"]:
		for s in [1, 3, 6]:
			for siege in [0, 8, 17, 40]:
				var h := _held(s, hk)
				for g in Beute.ladenware(h, siege):
					stuecke += 1
					pruefe(h.kann_tragen(g), "Laden %s Stufe %d: %s Stufe %d nicht tragbar" % [hk, s, Beute.name(g), int(g["ilvl"])])
					pruefe(not _hat_grundwert(g), "Laden Kapitel 1 %s Stufe %d: %s mit Grundwert %s" % [hk, s, Beute.name(g), g["rolls"]])
				h.kapitel = 2
				for g in Beute.ladenware(h, siege):
					if _hat_grundwert(g): mit += 1
	pruefe(stuecke > 100, "Laden geprüft: %d Stücke" % stuecke)
	pruefe(mit > 0, "ab Kapitel 2 wieder Stücke mit Grundwert (%d)" % mit)

func _gaben() -> void:
	pruefe(Beute.gabe_stufe(3, 1) == 2, "Gabe in der Höhle für Stufe 1: 2 (%d)" % Beute.gabe_stufe(3, 1))
	pruefe(Beute.gabe_stufe(1, 4) == 4 and Beute.gabe_stufe(3, 3) == 3 and Beute.gabe_stufe(2, 6) == 6, "Gabe sonst wie Gebiet oder Held")
	for id in ["longsword_oakford", "rapier_whisper", "mace_of_dawn", "greatsword_nameless", "spear_wolf", "longbow_blackyew", "crossbow_nightwatch", "staff_of_embers"]:
		pruefe(Katalog.stufe(id) == 3, "Truhe cave_3: %s Stufe 3 (%d)" % [id, Katalog.stufe(id)])
	var spiel = load("res://skripte/spiel.gd").new()
	var z := Zustand.new()
	var hw := _held(1)
	spiel.zustand = z; spiel.werte = hw; spiel.karte = Karte.lade("cave")
	spiel.gear_gabe("@gear:UNCOMMON:HEAD")
	var g: Dictionary = z.beutel[z.beutel.size() - 1]
	pruefe(int(g["ilvl"]) == 2, "Kopfschutz in der Höhle für Stufe 1: Stufe 2 (%d)" % int(g["ilvl"]))
	spiel.einzel_gabe("ring_protection")
	g = z.beutel[z.beutel.size() - 1]
	pruefe(int(g["ilvl"]) == 6 and String(g["unique"]) == "ring_protection", "Ring des Ältesten Stufe 6 aus dem Katalog (%d)" % int(g["ilvl"]))
	spiel.einzel_gabe("spear_wolf")
	g = z.beutel[z.beutel.size() - 1]
	pruefe(int(g["ilvl"]) == 3 and not hw.kann_tragen(g) and _held(3).kann_tragen(g), "Wolfsspieß Stufe 3: ab Stufe 3 tragbar (%d)" % int(g["ilvl"]))
	# 644a F: Meldung nach dem Üben (spiel.grundwerte_notiz)
	var n := int(BrsHeld.lade()["ueben"]["grundwert_punkte"])
	z.brs = hw.als_daten()
	var s: Dictionary = z.fertigkeiten_stand()
	var vorher: Dictionary = (s["werte"] as Dictionary).duplicate()
	pruefe(spiel.grundwerte_notiz(vorher) == "", "ohne Üben keine Meldung")
	s["werte"]["Einhänder"] = int(vorher.get("Einhänder", 10)) + n
	var t: String = spiel.grundwerte_notiz(vorher)
	pruefe(t == "Kraft ↑ %d" % spiel.held_werte().wert("kraft"), "Meldung „%s“" % t)
	# 644a.2 (Sokrates 12.11., 12:24, 280.5 ohne Weg): Reiter „Test“, „Übung“ bis kurz vor den Grundwert, der nächste Sieg hebt ihn
	var hw2: BrsHeld = spiel.held_werte()
	var grund := Testmodus.vor_grundwert(hw2, z)
	var vor2: Dictionary = (s["werte"] as Dictionary).duplicate()
	pruefe(grund != "" and spiel.grundwerte_notiz(vor2) == "", "Übung: noch kein Anstieg (%s, „%s“)" % [grund, spiel.grundwerte_notiz(vor2)])
	BrsFertigkeit.uebe(s, z.stufe_brs(), hw2.waffengruppe(), hw2.stufe)
	var t2: String = spiel.grundwerte_notiz(vor2)
	pruefe(grund != "" and t2.begins_with(Sprache.t(ErschaffungBrs.GRUNDWERT[grund]) + " ↑"), "Übung: ein Sieg hebt %s („%s“)" % [grund, t2])
	spiel.free()
