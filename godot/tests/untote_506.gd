extends SceneTree
# 506 ohne Bild: Wiedergänger (ersetzt den Zombie) und Grabhund (ersetzt den Ghul), LISTE-FIGUREN, Kauf 348.12c.
# Regeln aus tabellen.json (Monsters.kt zombie, ghoul) unter den neuen Namen; Untotenzähigkeit des Wiedergängers und Lähmung des
# Grabhunds wie im alten Battle.kt; beide kommen auf die Karte (Streuner.GRUPPE), sobald ihr Modell im Build liegt.
# Mit Kaufpaketen (kaufuntoter.py, kaufgrabhund.py): drei Kits bzw. Häute, je Nummer eines, Bewegungen, Maße, Haarkarten mit Schnitt.
# Aufruf: im Ordner godot mit -s res://tests/untote_506.gd (Exit 0 = gut)

const Probe = preload("res://kampf/probe.gd")

var fehler := 0

const ZINFO := "res://kampf/daten/zombie-info.json"
const GINFO := "res://kampf/daten/ghoul-info.json"
const ZBEWEGUNGEN := ["Stehen", "Gehen", "Rennen", "Hieb", "Treffer", "Tod", "Ausweichen", "Ausweichen links", "Auferstehen"]
const GBEWEGUNGEN := ["Stehen", "Gehen", "Rennen", "Biss", "Sprungbiss", "Treffer", "Tod", "Ausweichen", "Ausweichen links"]


func _initialize() -> void:
	Engine.time_scale = 30.0
	_lauf.call_deferred()


func _lauf() -> void:
	_karte()
	_zinfo()
	_ginfo()
	await _kampf("WIEDERGAENGER3", "zombie", "Wiedergänger", false)
	await _kampf("GRABHUNDE", "ghoul", "Grabhund", false)
	await _kampf("WIEDERGAENGER", "zombie", "Wiedergänger", true)
	await _kampf("GRABHUND", "ghoul", "Grabhund", true)
	print("UNTOTE506 %s" % ("0 Fehler" if fehler == 0 else "%d FEHLER" % fehler))
	quit(1 if fehler > 0 else 0)


func _fehler(t: String) -> void:
	fehler += 1
	print("FEHLER " + t)


## Story.kt: nachts Skelett und Zombie im Wald, Ghul im tiefen Wald und in der Höhle; jeder hat jetzt eine Kampfgruppe
func _karte() -> void:
	var S = load("res://skripte/streuner.gd")
	for paar in [["skeleton", "SKELETT"], ["zombie", "WIEDERGAENGER"], ["ghoul", "GRABHUND"]]:
		if S.GRUPPE.get(paar[0], "") != paar[1]:
			_fehler("Karte: %s ohne Kampfgruppe %s" % paar)
	var da := {}
	for a in ["skeleton", "zombie", "ghoul"]:
		da[a] = S.da(a)
	if FileAccess.file_exists(ZINFO) and not da.zombie:
		_fehler("Karte: Wiedergänger hat Modell, kommt aber nicht auf die Karte")
	if FileAccess.file_exists(GINFO) and not da.ghoul:
		_fehler("Karte: Grabhund hat Modell, kommt aber nicht auf die Karte")
	print("Untote 506 Karte: auf der Karte %s" % [da])


func _zinfo() -> void:
	if not FileAccess.file_exists(ZINFO):
		print("Untote 506: keine zombie-info.json im Build (ohne Kaufpakete)")
		return
	var j = JSON.parse_string(FileAccess.get_file_as_string(ZINFO))
	if not j is Dictionary or j.keys() != ["lumpen", "hemd", "kette"]:
		_fehler("Wiedergänger Kits: %s" % [j.keys() if j is Dictionary else j])
		return
	for kit in j:
		var d: Dictionary = j[kit]
		if not FileAccess.file_exists("res://kampf/daten/zombie-%s.bin" % kit):
			_fehler("Wiedergänger Modell fehlt: %s" % kit)
		if d.get("aufrecht_cm", 0.0) < 160.0 or d.get("aufrecht_cm", 0.0) > 185.0:
			_fehler("Wiedergänger %s: aufrecht %.0f cm (160–185)" % [kit, d.get("aufrecht_cm", 0.0)])
		if d.get("groesse_cm", 0.0) >= d.get("aufrecht_cm", 0.0):
			_fehler("Wiedergänger %s: steht nicht gebeugt (%.0f von %.0f cm)" % [kit, d.get("groesse_cm", 0.0), d.get("aufrecht_cm", 0.0)])
		if d.get("dreiecke", 99999) > 6000:
			_fehler("Wiedergänger %s: %d Dreiecke (höchstens 6000)" % [kit, d.get("dreiecke", 0)])
		for nm in ZBEWEGUNGEN:
			if not d.get("zeiten", {}).has(nm):
				_fehler("Wiedergänger %s: Bewegung %s fehlt" % [kit, nm])
		for nm in d.get("tiefster_punkt_m", {}):
			if nm != "Auferstehen" and float(d.tiefster_punkt_m[nm]) < -0.01:
				_fehler("Wiedergänger %s: %s %.3f m im Boden" % [kit, nm, d.tiefster_punkt_m[nm]])
		for nm in ["Gehen", "Rennen", "Ausweichen", "Ausweichen links"]:
			if not d.get("weg", {}).has(nm):
				_fehler("Wiedergänger %s: Weg %s fehlt" % [kit, nm])
		if not d.get("hieb") is Array or d.hieb.size() != 4:
			_fehler("Wiedergänger %s: Aufschlag des Hiebs fehlt" % kit)
	print("Untote 506 Wiedergänger: Kits %s, %s cm gebeugt, Dreiecke %s" % [j.keys(), j.values().map(func(d): return d.groesse_cm),
		j.values().map(func(d): return d.dreiecke)])


func _ginfo() -> void:
	if not FileAccess.file_exists(GINFO):
		print("Untote 506: keine ghoul-info.json im Build (ohne Kaufpakete)")
		return
	var j = JSON.parse_string(FileAccess.get_file_as_string(GINFO))
	if not j is Dictionary or j.keys() != ["fahl", "grabgrau", "graublau"]:
		_fehler("Grabhund Häute: %s" % [j.keys() if j is Dictionary else j])
		return
	var maehnen := {}
	for h in j:
		var d: Dictionary = j[h]
		maehnen[d.get("maehne", "")] = true
		if not FileAccess.file_exists("res://kampf/daten/ghoul-%s.bin" % h):
			_fehler("Grabhund Modell fehlt: %s" % h)
		if d.get("schulter_m", 0.0) < 0.895 or d.get("schulter_m", 0.0) > 1.005:
			_fehler("Grabhund %s: Schulter %.2f m (0,90–1,00)" % [h, d.get("schulter_m", 0.0)])
		if d.get("dreiecke", 99999) > 6000:
			_fehler("Grabhund %s: %d Dreiecke (höchstens 6000)" % [h, d.get("dreiecke", 0)])
		for nm in GBEWEGUNGEN:
			if not d.get("zeiten", {}).has(nm):
				_fehler("Grabhund %s: Bewegung %s fehlt" % [h, nm])
		for nm in d.get("tiefster_punkt_m", {}):
			if float(d.tiefster_punkt_m[nm]) < -0.01:
				_fehler("Grabhund %s: %s %.3f m im Boden" % [h, nm, d.tiefster_punkt_m[nm]])
		for nm in ["Gehen", "Rennen", "Sprungbiss", "Ausweichen"]:
			if not d.get("weg", {}).has(nm):
				_fehler("Grabhund %s: Weg %s fehlt" % [h, nm])
		if not d.get("biss") is Array or d.biss.size() != 3:
			_fehler("Grabhund %s: Biss fehlt" % h)
	if maehnen.size() != 3:
		_fehler("Grabhund: Mähnen nicht verschieden (%s)" % [maehnen.keys()])
	print("Untote 506 Grabhund: Häute %s, Schulter %s m, Mähnen %s, Dreiecke %s" % [j.keys(), j.values().map(func(d): return d.schulter_m),
		maehnen.keys(), j.values().map(func(d): return d.dreiecke)])


func _figuren(kf, feinde: Array, art: String) -> void:
	if not FileAccess.file_exists(ZINFO if art == "zombie" else GINFO):
		return
	var pfade := {}
	var schnitt := false
	for f in feinde:
		var fig = kf.figures.get(f.id)
		if fig == null:
			_fehler("keine Figur für %s" % f.id)
			continue
		pfade[fig._model_path().get_file()] = true
		var nm_liste: Array = ZBEWEGUNGEN if art == "zombie" else GBEWEGUNGEN
		for nm in nm_liste:
			if fig.anim == null or not fig.anim.has_animation(nm):
				_fehler("%s: keine Bewegung %s" % [f.id, nm])
		if fig.weg.is_empty():
			_fehler("%s: ohne Weg" % f.id)
		if art == "zombie":
			var sk = fig._find(fig.model, "Skeleton3D")
			if sk == null or sk.find_bone("kopf") < 0 or sk.find_bone("hals") < 0:
				_fehler("%s: Gerüst ohne kopf/hals" % f.id)
			if fig.hieb.size() != 4:
				_fehler("%s: Hieb %s" % [f.id, fig.hieb])
		else:
			for m in fig.mats:
				var sv = m.get_shader_parameter("schnitt")
				if sv != null and float(sv) > 0.0:
					schnitt = true
	if pfade.size() != feinde.size():
		_fehler("%s: Kits nicht verschieden: %s" % [art, pfade.keys()])
	if art == "ghoul" and not schnitt:
		_fehler("Grabhund: Mähne ohne Schnitt (Haarkarten wären Rechtecke)")
	print("Untote 506 Figuren %s: %s" % [art, pfade.keys()])


## Untotenzähigkeit (Battle.kt UNDEAD_FORTITUDE) und Lähmung (PARALYZE) am laufenden Kampf, danach Werte zurück
func _sonder(kf, art: String) -> void:
	var m = kf.mars
	var held = m.find("hero")
	var feind = m.fighters().filter(func(f): return f.side == "FOES")[0]
	if art == "zombie":
		var steht := 0
		var krit_steht := 0
		for i in 200:
			feind.hp = 1
			m._hurt(feind, 1, "hero", "")
			steht += int(feind.hp > 0)
			feind.hp = 1
			m.krit_jetzt = true
			m._hurt(feind, 1, "hero", "")
			m.krit_jetzt = false
			krit_steht += int(feind.hp > 0)
		feind.hp = feind.max_hp
		m.outcome = "ONGOING"
		# 1 Schaden: W20 + 3 ≥ 6 in 85 % der Fälle
		if steht < 140 or steht > 195 or krit_steht > 0:
			_fehler("Untotenzähigkeit: steht %d/200 nach 1 Schaden (erwartet um 170), nach Krit %d (erwartet 0)" % [steht, krit_steht])
		print("Untote 506 Untotenzähigkeit: steht %d/200, nach Krit %d" % [steht, krit_steht])
	else:
		var lahm := 0
		var rasse = held.hero.get("race", "")
		for i in 100:
			held.status.erase("STUN")
			held.stun_guard = 0
			m._foe_wounds(feind, held)
			lahm += int(held.status.has("STUN"))
		held.hero["race"] = "ELF"
		var elf := 0
		for i in 50:
			held.status.erase("STUN")
			held.stun_guard = 0
			m._foe_wounds(feind, held)
			elf += int(held.status.has("STUN"))
		held.hero["race"] = rasse
		held.status.erase("STUN")
		if lahm < 10 or elf > 0:
			_fehler("Lähmung: %d/100 betäubt (erwartet einige), Elf %d/50 (erwartet 0)" % [lahm, elf])
		print("Untote 506 Lähmung: %d/100 betäubt, Elf %d/50" % [lahm, elf])


func _kampf(foe: String, art: String, name: String, bis_ende: bool) -> void:
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = foe
	root.add_child(p)
	await process_frame
	p._start(3)
	for i in 6:
		await process_frame
	var kf = p.fight
	if kf == null:
		_fehler("kein Kampfort (%s)" % foe)
		return
	var feinde: Array = kf.mars.fighters().filter(func(f): return f.side == "FOES")
	var soll := 3 if foe.ends_with("3") or foe == "GRABHUNDE" else 1
	if feinde.size() != soll or feinde.any(func(f): return String(f.monster.id) != art or String(f.monster.de) != name):
		_fehler("Gegner %s: %s" % [foe, feinde.map(func(f): return "%s/%s" % [f.monster.id, f.monster.de])])
	if not bis_ende:
		for i in 30:
			await process_frame
		_figuren(kf, feinde, art)
		_sonder(kf, art)
		print("Untote 506 %s: aufgestellt, TP %s" % [foe, feinde.map(func(f): return f.max_hp)])
	else:
		kf.mars.find("merc").auto = true
		kf.mars.set_autopilot(true)
		if not kf.busy:
			kf.go_on()
		var t0 := Time.get_ticks_msec()
		while Time.get_ticks_msec() - t0 < 90000 and kf.mars.outcome == "ONGOING":
			await process_frame
		print("Untote 506 %s: %s, TP %s" % [foe, kf.mars.outcome, feinde.map(func(f): return f.max_hp)])
		if kf.mars.outcome == "ONGOING":
			var c = kf.mars.current()
			print("  dran %s, Zug %d, busy %s, TP %s" % [c.id if c else "-", kf.mars.turn, kf.busy, kf.mars.fighters().map(func(f): return "%s:%d" % [f.id, f.hp])])
			_fehler("Kampf endet nicht (%s)" % foe)
	kf.queue_free()
	p.queue_free()
	for i in 3:
		await process_frame
