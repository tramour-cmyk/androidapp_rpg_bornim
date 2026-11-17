# 560 (Chef 04.11., 16:22: Monster drehen sich zum Helden „nicht wieder so auf der Scheibe … sondern gerne mit Bewegung“) ohne Bild:
# ein Wolf der Karte (streuner.gd) wendet um 180 Grad mit fester Rate (nicht in einem Augenblick), tritt dabei (Gehen auf der Stelle)
# und bleibt stehen; vor einem Schritt zurück wendet er erst auf der Stelle (wende_ms), dann geht er.
# Aufruf: im Ordner godot -s res://tests/wenden_560.gd (Exit 0 = alles gut)
extends SceneTree

const DT := 1.0 / 30.0

var fehler := 0


func _initialize() -> void:
	_run.call_deferred()


func _pruefe(gut: bool, was: String) -> void:
	print("WENDEN560 %s %s" % ["gut   " if gut else "FEHLER", was])
	if not gut:
		fehler += 1


func _run() -> void:
	var s := Streuner.new()
	s.art = "wolf"
	s.karte = Karte.new()
	s.kachel = Vector2i(5, 5)
	s.von = s.kachel
	s.blick = Vector2i(0, 1)
	root.add_child(s)
	await process_frame
	# am Rechner ohne gebaute Modelle (kampf/daten/*.bin kommen vom Bauserver): Wende und Platz ja, Tritte erst dort
	var mit_bild: bool = s.figur != null and s.figur.anim != null
	if not mit_bild:
		print("WENDEN560 ohne Modell (%s fehlt): Tritte nicht geprüft" % (String(s.figur._model_path()) if s.figur else "Figur"))
	var jetzt := 10000
	for i in 10:
		s.zeichne(jetzt, DT)
		jetzt += int(DT * 1000)
	var ort := s.position
	# 1. Wende im Stehen um 180 Grad (Lauerer dreht sich zum Helden)
	s.blick = Vector2i(0, -1)
	var ziel := atan2(0.0, -1.0)
	var dauer := 0.0
	var tritte := 0
	var bilder := 0
	var halbe := 0.0
	while absf(angle_difference(s.gedreht, ziel)) > 0.001 and dauer < 5.0:
		s.zeichne(jetzt, DT)
		jetzt += int(DT * 1000)
		dauer += DT
		bilder += 1
		if mit_bild and s.figur.anim.current_animation == "Gehen":
			tritte += 1
		if halbe == 0.0 and absf(angle_difference(s.gedreht, ziel)) <= PI / 2.0:
			halbe = dauer
	_pruefe(dauer >= 1.0 and dauer <= 1.6, "180 Grad in %.2f s (soll 1,0–1,6; vorher weich, nach 0,3 s zu 90 %%)" % dauer)
	_pruefe(halbe >= 0.5, "halb herum nach %.2f s (feste Rate, nicht weich)" % halbe)
	if mit_bild:
		_pruefe(tritte >= bilder * 0.8, "tritt beim Wenden: %d von %d Bildern Gehen" % [tritte, bilder])
	_pruefe(s.position.distance_to(ort) < 0.001, "bleibt beim Wenden am Platz")
	for i in 10:
		s.zeichne(jetzt, DT)
		jetzt += int(DT * 1000)
	if mit_bild:
		_pruefe(s.figur.anim.current_animation != "Gehen", "steht nach der Wende wieder (%s)" % s.figur.anim.current_animation)
	# 2. Schritt zurück (wie herde.gd _geh): erst wenden, dann gehen
	var d := Vector2i(0, 1)
	var w := s.wende_ms(d)
	_pruefe(w >= 800 and w <= 1100, "vor dem Schritt zurück %d ms Wende (soll etwa 940)" % w)
	_pruefe(s.wende_ms(Vector2i(1, 0)) <= 350, "Viertelwende vor dem Schritt %d ms (soll höchstens 350)" % s.wende_ms(Vector2i(1, 0)))
	s.von = s.kachel
	s.kachel = s.kachel + d
	s.bewegt_ms = jetzt + w
	s.schritt_ms = 600
	s.blick = d
	var am_platz := true
	var ende := jetzt + w
	while jetzt < ende - 40:
		s.zeichne(jetzt, DT)
		jetzt += int(DT * 1000)
		if s.position.distance_to(ort) > 0.001:
			am_platz = false
	_pruefe(am_platz, "geht erst nach der Wende los")
	for i in 30:
		s.zeichne(jetzt, DT)
		jetzt += int(DT * 1000)
	_pruefe(s.position.distance_to(s.karte.kachel_pos(s.kachel)) < 0.01, "steht danach auf der neuen Kachel")
	print("WENDEN560 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
