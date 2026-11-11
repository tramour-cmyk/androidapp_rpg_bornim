extends SceneTree
# 870.2 (LISTE-UMZUG-BRS.md Schritt 2): Schnittstelle Held ↔ Kampf. BrsHeld.kampfblatt() liefert alles, was der Kampf vom Helden
# braucht, nach dem BRS (Grundwerte, Fertigkeiten, Heldenstufe, Leben, Mana, Ausdauer, Waffe mit Gruppe, Grundschaden und Güte,
# Rüstung mit Schutzwert, Schild, Fähigkeiten); brs_kampf.gd held() liest es statt der Klasse aus dem SRD-Blatt (aufruf.gd blatt).
# Zahlen nur aus daten/werte.json (= tools/sim444/werte.json).
# Aufruf: im Ordner godot mit -s res://tests/brs_blatt_870.gd (Exit 0 = alles richtig)

const BrsHeldS = preload("res://regeln/brs_held.gd")
const BrsKampf = preload("res://regeln/brs_kampf.gd")
const Brs = preload("res://regeln/brs.gd")

var fehler := 0


func pruefe(was: String, gut: bool, wie := "") -> void:
	if not gut:
		fehler += 1
	print(("ok     " if gut else "FALSCH ") + was + ((" (" + wie + ")") if wie != "" else ""))


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	var W := Brs.lade()
	if W.is_empty():
		print("BRSBLATT FALSCH daten/werte.json fehlt")
		quit(1)
		return
	var hw: Dictionary = W["held"]
	# Wachsoldat (Mensch), Stufe 1, ohne Angaben zur Ausrüstung: die Ausrüstung seiner Herkunft
	var bh = BrsHeldS.neu("Mensch", "Wachsoldat")
	var k: Dictionary = bh.kampfblatt()
	for feld in ["volk", "herkunft", "stufe", "werte", "fert", "leben", "mana", "ausdauer", "waffe", "ruestung", "schild", "faehigkeiten"]:
		pruefe("Feld „%s“" % feld, k.has(feld))
	pruefe("Herkunft und Volk", k.herkunft == "Wachsoldat" and k.volk == "Mensch", "%s %s" % [k.herkunft, k.volk])
	pruefe("Grundwerte wie BrsHeld", k.werte == bh.werte(), str(k.werte))
	pruefe("Startfertigkeiten wie BrsHeld", k.fert == bh.fertigkeiten(), str(k.fert))
	pruefe("Heldenstufe 1", int(k.stufe) == 1)
	var soll_leben: int = int(hw.leben_basis) + int(hw.leben_je_stufe) + int(hw.leben_je_zaehigkeit) * bh.wert("zaehigkeit")
	pruefe("Leben = Basis + je Stufe + je Zähigkeit", int(k.leben) == soll_leben, "%d / %d" % [int(k.leben), soll_leben])
	pruefe("Mana = Basis + je Wille", int(k.mana) == int(hw.mana_basis) + int(hw.mana_je_wille) * bh.wert("wille"), str(k.mana))
	pruefe("Waffe der Herkunft: Einhänder", k.waffe.gruppe == "Einhänder", str(k.waffe))
	pruefe("Grundschaden und Grundwert aus „waffen“", int(k.waffe.grundschaden) == int(W.waffen["Einhänder"].schaden) and k.waffe.grundwert == W.waffen["Einhänder"].grundwert, str(k.waffe))
	pruefe("Güte ohne Angabe 0", int(k.waffe.guete) == 0)
	pruefe("Rüstung der Herkunft: Mittlere Rüstung, Schutzwert aus „ruestungen“", k.ruestung.art == "Mittlere Rüstung" and int(k.ruestung.schutzwert) == int(W.ruestungen["Mittlere Rüstung"].wert), str(k.ruestung))
	pruefe("Schild der Herkunft, Schutzwert schild_wert", not (k.schild as Dictionary).is_empty() and int(k.schild.schutzwert) == int(W.ruestungen.schild_wert), str(k.schild))
	pruefe("Fähigkeiten: Merkmal des Volks", "Wandelbar" in k.faehigkeiten, str(k.faehigkeiten))
	pruefe("ohne Ausdauerangabe null (467 offen)", k.ausdauer == null, str(k.ausdauer))

	# Stufe, getragene Ausrüstung und Geübtes (Tom liefert sie aus dem Spielstand)
	var k3: Dictionary = bh.kampfblatt(3, {"waffe": "greatsword", "ruestung": "Leichte Rüstung", "schild": "", "guete": 2, "ausdauer": 14}, {"Zweihänder": 17, "Einhänder": 12})
	pruefe("Stufe 3: Leben + 2 × je Stufe", int(k3.leben) == soll_leben + 2 * int(hw.leben_je_stufe), str(k3.leben))
	pruefe("Zweihänder aus der Grundform, Güte 2", k3.waffe.gruppe == "Zweihänder" and k3.waffe.id == "greatsword" and int(k3.waffe.guete) == 2, str(k3.waffe))
	pruefe("getragene Rüstung statt der Herkunft", k3.ruestung.art == "Leichte Rüstung", str(k3.ruestung))
	pruefe("ohne Schild leer", (k3.schild as Dictionary).is_empty(), str(k3.schild))
	pruefe("Geübtes überschreibt Startwerte", int(k3.fert["Zweihänder"]) == 17 and int(k3.fert["Einhänder"]) == 12 and int(k3.fert["Schild"]) == 10, str(k3.fert))
	pruefe("Ausdauer wie geliefert", int(k3.ausdauer) == 14)
	pruefe("unbewaffnet: Faustkampf", bh.kampfblatt(1, {"waffe": ""}).waffe.gruppe == "Faustkampf")

	# Zauberlehrling: Zauber der Herkunft als Fähigkeiten
	var kz: Dictionary = BrsHeldS.neu("Elf", "Zauberlehrling").kampfblatt()
	pruefe("Zauberlehrling: Funkenpfeil und Bannschild, Merkmal Wachsame Sinne", "Funkenpfeil" in kz.faehigkeiten and "Bannschild" in kz.faehigkeiten and "Wachsame Sinne" in kz.faehigkeiten, str(kz.faehigkeiten))
	pruefe("Zauberlehrling: Arkanpfeil ab Evokation 10, Glutstrahlen erst ab 25", "Arkanpfeil" in kz.faehigkeiten and not ("Glutstrahlen" in kz.faehigkeiten), str(kz.faehigkeiten))
	pruefe("Kraft schöpfen für alle, Finte erst als Geselle (Einhänder 25)", "Kraft schöpfen" in k.faehigkeiten and not ("Finte" in k.faehigkeiten) and "Finte" in bh.kampfblatt(1, {}, {"Einhänder": 25}).faehigkeiten, str(k.faehigkeiten))
	pruefe("Wuchtschlag mit Zweihänder 17 noch nicht", not ("Wuchtschlag" in k3.faehigkeiten))
	pruefe("Zauberlehrling ohne Rüstung und Schild", kz.ruestung.art == "keine" and (kz.schild as Dictionary).is_empty(), "%s %s" % [kz.ruestung, kz.schild])

	# der Kampf liest das Blatt: brs_kampf.gd held() mit „brs“ im Blatt statt der Klasse
	var b: Dictionary = BrsKampf.held({"cls": "WIZARD", "level": 1, "brs": k3})
	pruefe("Kampf: Herkunft, Stufe, Werte, Fertigkeiten aus dem Blatt (nicht aus der Klasse)", b.herkunft == "Wachsoldat" and int(b.stufe) == 3 and b.werte == k3.werte and b.fert == k3.fert, "%s %s" % [b.herkunft, b.stufe])
	pruefe("Kampf: Rüstung und Schild aus dem Blatt", b.ruestung == "Leichte Rüstung" and not b.schild, "%s %s" % [b.ruestung, b.schild])
	pruefe("Kampf: Leben wie das Blatt", BrsKampf.leben_held(b) == int(k3.leben), "%d / %d" % [BrsKampf.leben_held(b), int(k3.leben)])
	pruefe("Kampf: Hauptwaffe aus dem Blatt", BrsKampf.waffe_held(b, {"id": "dagger"}) == "Zweihänder", BrsKampf.waffe_held(b, {"id": "dagger"}))
	pruefe("Kampf: gezogene Zweitwaffe nach ihrer Grundform", BrsKampf.waffe_held(b, {"id": "dagger"}, true) == "Dolche", BrsKampf.waffe_held(b, {"id": "dagger"}, true))
	var bz: Dictionary = BrsKampf.held({"cls": "FIGHTER", "level": 1, "brs": kz})
	pruefe("Kampf: Zauber aus dem Blatt", "Bannschild" in bz.zauber and "Funkenpfeil" in bz.zauber and "Arkanpfeil" in bz.zauber and not ("Kraft schöpfen" in bz.zauber), str(bz.zauber))
	# ohne Blatt (Söldner, Probekampf bis 870.4) wie bisher aus der Klasse
	pruefe("ohne Blatt: Herkunft aus der Klasse", BrsKampf.held({"cls": "CLERIC", "level": 1}).herkunft == "Klosterschüler")

	print("BRSBLATT %s, %d Fehler" % ["ok" if fehler == 0 else "FALSCH", fehler])
	quit(1 if fehler > 0 else 0)
