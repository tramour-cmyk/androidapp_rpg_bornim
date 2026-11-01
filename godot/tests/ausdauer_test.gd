extends SceneTree
# 399.1 ohne Bild: Atem zum Rennen wie Stamina.kt (Zahlen des alten Spiels). Aufruf: im Ordner godot mit -s res://tests/ausdauer_test.gd

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll:
		fehler += 1
		print("FALSCH ", was, ": ", ist, " statt ", soll)

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	Sprache.lade()
	var z := Zustand.new()
	var hw := Heldwerte.erschaffe("Alrik", "HUMAN", "FIGHTER")
	for a in ["STR", "CON"]: hw.basis[a] = 10
	pruefe("6 s bei KON 10", Ausdauer.reicht_ms(hw), 6000.0)
	pruefe("Trank doppelt", Ausdauer.reicht_ms(hw, true), 12000.0)
	hw.basis["CON"] = 14
	pruefe("KON 14: 10 s", Ausdauer.reicht_ms(hw), 10000.0)
	hw.basis["CON"] = 1
	pruefe("mindestens 2 s", Ausdauer.reicht_ms(hw), 2000.0)
	hw.basis["CON"] = 10
	hw.stufe = 4
	pruefe("Stufe 4: 8 s", Ausdauer.reicht_ms(hw), 8000.0)
	hw.stufe = 1
	hw.ausruestung["CHEST"] = Beute.wuerfle(z.neue_uid(), "chain_mail", 1, "COMMON", KotlinZufall.new(1))
	pruefe("schwer ohne STR 13", [Ausdauer.schwer(hw), Ausdauer.reicht_ms(hw)], [true, 3000.0])
	hw.basis["STR"] = 13
	pruefe("schwer mit STR 13", Ausdauer.schwer(hw), false)
	hw.ausruestung.erase("CHEST")
	# 6 s rennen leeren den Vorrat, dann geht er, bis ein Viertel zurueck ist (10 s gehen)
	var rennt := true
	for i in 60: rennt = Ausdauer.schritt(z, hw, 100.0, true, true)
	pruefe("leer", [z.ausdauer, z.atemlos, rennt], [0.0, true, false])
	for i in 99: Ausdauer.schritt(z, hw, 100.0, true, true)
	pruefe("noch atemlos", z.atemlos, true)
	rennt = Ausdauer.schritt(z, hw, 200.0, true, true)   # wie Stamina.step: in diesem Bild noch gegangen, ab dem naechsten gerannt
	pruefe("wieder Atem", [z.atemlos, rennt, Ausdauer.schritt(z, hw, 100.0, true, true)], [false, false, true])
	# im Stehen in 20 s voll
	z.ausdauer = 0.0; z.atemlos = false
	for i in 200: Ausdauer.schritt(z, hw, 100.0, false, false)
	pruefe("im Stehen voll", is_equal_approx(z.ausdauer, 1.0), true)
	z.met = Rast.BETRUNKEN
	pruefe("betrunken rennt nicht", Ausdauer.schritt(z, hw, 100.0, true, true), false)
	# 399.1 Fackel (Light.torch, torchChange): nur in der Nebenhand; im Dunkeln sagt An- und Ablegen etwas, sonst wie immer
	Sprache.setze("de")
	var zf := Zustand.new()
	var hf := Heldwerte.erschaffe("Mira", "HUMAN", "FIGHTER", {}, zf.neue_uid)
	var m := Menue.new(hf, zf)
	root.add_child(m)
	await process_frame
	var f := Beute.fackel(zf.neue_uid())
	zf.beutel.append(f)
	pruefe("ohne Fackel", Menue.fackel(hf), false)
	m.dunkel = true
	pruefe("angezuendet", m.lege_an(f, true), "Du zündest die Fackel an.")
	pruefe("traegt Fackel", Menue.fackel(hf), true)
	m.lege_ab("OFF_HAND")
	pruefe("ausgedrueckt", [Menue.fackel(hf), m.meldung_.text], [false, "Du drückst die Fackel aus. Das Dunkel rückt heran."])
	m.dunkel = false
	pruefe("am Tag nur angelegt", m.lege_an(f, true).ends_with(": angelegt"), true)
	m.free()
	print("AUSDAUER %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
