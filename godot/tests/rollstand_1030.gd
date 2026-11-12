extends SceneTree
# 1030 (Chef 12.11., 13:53, Build 280: „wenn ich jetzt Bildrate schalte, dann bin ich wieder ganz oben“): der Reiter „Test“ behält
# nach einem Schalter seine Stelle, auch wenn eine Zeile der Prüfliste aufgeklappt ist; die Prüfliste klappt ein und bleibt zu.
# Schirm wie am Handy 1080 × 2340. Ausgabe „ROLL1030 <n> Fehler“.
#   ~/godot/godot --headless --path . -s res://tests/rollstand_1030.gd

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func _pruefe(name_: String, ok: bool, text: String) -> void:
	print("%s %s: %s" % ["ok     " if ok else "FALSCH ", name_, text])
	if not ok: fehler += 1

func _lauf() -> void:
	root.size = Vector2i(1080, 2340)
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	Testmodus.an = true
	Testmodus.geladen = true
	spiel.oeffne_menue("test")
	await create_timer(0.5).timeout
	var m: Menue = root.find_children("*", "Menue", true, false)[0]
	var hat_liste := not Pruefliste.zeilen().is_empty()
	var faelle := ["ohne offene Zeile"] + (["mit offener Zeile"] if hat_liste else [])
	for fall in faelle:
		Pruefliste.offen = "" if fall == "ohne offene Zeile" else String(Pruefliste.zeilen()[0]["nr"])
		for schalter in ["Bildrate", "Uhrzeit"]:
			m.baue()
			for i in 5: await process_frame
			m.rolle.scroll_vertical = 3000
			await process_frame
			var vor := m.rolle.scroll_vertical
			if schalter == "Bildrate": m._tue(func(): Testmodus.bildrate = not Testmodus.bildrate)
			else: m._tue(func(): m.z.minuten = (m.z.minuten + 60) % (24 * 60))
			var spur := []
			for i in 8:
				await process_frame
				spur.append(m.rolle.scroll_vertical)
			_pruefe("%s, %s" % [schalter, fall], absi(int(spur[-1]) - vor) <= 2 and spur.min() >= vor - 2, "vorher %d, danach %s" % [vor, spur])
	Pruefliste.offen = ""
	if hat_liste:
		# eingeklappt: nur der Kopf der Prüfliste, die Schalter darunter rücken nach oben
		Pruefliste.zu = false
		m.baue()
		for i in 3: await process_frame
		var offen_h := m.inhalt.size.y
		Pruefliste.zu = true
		m.baue()
		for i in 3: await process_frame
		var zu_h := m.inhalt.size.y
		_pruefe("Prüfliste eingeklappt", zu_h < offen_h - 400, "Inhalt offen %.0f, eingeklappt %.0f" % [offen_h, zu_h])
		# gemerkt über einen Neustart (aus user://pruefliste.cfg neu gelesen)
		Pruefliste.zu = false
		Pruefliste.klappe()
		Pruefliste.zu = null
		var gemerkt := Pruefliste.eingeklappt()
		Pruefliste.klappe()
		Pruefliste.zu = null
		_pruefe("Einklappen gemerkt", gemerkt and not Pruefliste.eingeklappt(), "nach Neustart eingeklappt %s, danach %s" % [gemerkt, Pruefliste.eingeklappt()])
		# eine gerade aufgeklappte Zeile weit unten rollt weiter ins Bild
		m.rolle.scroll_vertical = 0
		await process_frame
		m._tue(func(): Pruefliste._oeffne(String(Pruefliste.zeilen()[-1]["nr"])))
		for i in 6: await process_frame
		_pruefe("Neu aufgeklappte Zeile ins Bild", m.rolle.scroll_vertical > 500, "Rollstand %d" % m.rolle.scroll_vertical)
		Pruefliste.offen = ""
	print("ROLL1030 %d Fehler" % fehler)
	quit(1 if fehler else 0)
