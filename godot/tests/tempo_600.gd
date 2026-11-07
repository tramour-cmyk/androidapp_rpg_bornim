# 600 (Chef 05.11., t266: „Beschleunigungsknopf einbauen (analog Würfelergebnis oder Raster)“): der Knopf im Kampfort schaltet das
# Tempo aus dem Menü weiter (Ruhig, Normal, Schnell, wieder Ruhig), die Uhr folgt sofort (Engine.time_scale = 1 / Faktor), während der
# Blende erst, wenn sie geht. Ohne Bild. Aufruf: im Ordner godot mit -s res://tests/tempo_600.gd   (Exit 0 = gut)
extends SceneTree
const Kampfort = preload("res://kampf/kampfort.gd")
func _init() -> void:
	_lauf.call_deferred()
func _lauf() -> void:
	var f := 0
	Bedienung.lade()
	var vorher := Bedienung.tempo
	Bedienung.tempo = 1
	var k = Kampfort.new()
	for soll in [2, 0, 1]:
		k.tempo_wechseln()
		var uhr := 1.0 / Bedienung.tempo_faktor()
		var gut: bool = Bedienung.tempo == soll and absf(Engine.time_scale - uhr) < 0.001 and is_equal_approx(k.tempo, Bedienung.tempo_faktor())
		print("TEMPO600 %s Stufe %d, Uhr %.3f" % ["ok" if gut else "FALSCH", Bedienung.tempo, Engine.time_scale])
		if not gut: f += 1
	Engine.time_scale = 1.0
	k.verhuellt = true
	k.tempo_wechseln()
	var blende_gut := is_equal_approx(Engine.time_scale, 1.0)
	print("TEMPO600 %s während der Blende Uhr %.3f" % ["ok" if blende_gut else "FALSCH", Engine.time_scale])
	if not blende_gut: f += 1
	k.free()
	Engine.time_scale = 1.0
	Bedienung.tempo = vorher
	Bedienung.speichere()
	print("TEMPO600 %s" % ("gut" if f == 0 else "FALSCH %d" % f))
	quit(1 if f else 0)
