# 785.10 ohne Bild: „Schnell“ im leichten Kampf (259, alt SkirmishScreen.kt quick). Ratten gegen den Helden: ist der Kampf leicht
# (mars.easy), wartet er auf „Kämpfen“ oder „Schnell“ (Kampfort.tor „leicht“, zwei Knöpfe); „Schnell“ spielt ihn in einem Rutsch,
# am Ende liegt jeder Gegner, der Siegschirm nennt den Verlust je Gefährte ab Kampfbeginn, ohne „−0“ ([259T.tafel], 1567). Ist er nicht leicht, wird der Abstand
# gesetzt wie bei einem Helden weit über den Ratten (die Regel selbst prüft mars_regeln). Massgeblich: SCHNELL78510
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
var fehler := 0


func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1


func _initialize() -> void:
	_lauf.call_deferred()


func _texte(n: Node, aus: Array) -> Array:
	if n is Label: aus.append((n as Label).text)
	if n is Button: aus.append((n as Button).text)
	for c in n.get_children(): _texte(c, aus)
	return aus


func _lauf() -> void:
	seed(7)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.ohne_soeldner = true
	p.foe = "RATS"
	root.add_child(p)
	await process_frame
	# wie probe.gd _start, der Held aber auf Stufe 14 (Ratten Stufe 1: leicht ab 4 Stufen, halber Schaden ab 7, keiner ab 10)
	var skills := {}
	for s_ in p.tables.skills: skills[s_.id] = s_
	var monsters := {}
	for m_ in p.tables.monsters: monsters[m_.id] = m_
	var hs: Dictionary = p.tables.probe["FIGHTER"].hero
	var sheet: Dictionary = hs.hero.duplicate(true)
	sheet["level"] = 14
	var party := [Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, int(hs.hp), sheet.second, skills)]
	var foes: Array = load("res://kampf/aufruf.gd").gegner("RATS", monsters, Wuerfel.new(8))
	var kf = load("res://kampf/kampfort.gd").new()
	pruefe(kf.setup(party, foes, p.tables, {"potion": 2}, func(_o): pass, 7, {}), "Kampf aufgebaut")
	root.add_child(kf)
	for i in 4:
		await process_frame
	var n := 0
	while kf.verhuellt and n < 600:
		n += 1
		await process_frame
	print("leicht von selbst: %s, tor „%s“" % [kf.mars.easy(), kf.tor])
	if not kf.mars.easy():     # Held weit über den Ratten, bevor der Kampf beginnt
		while kf.busy and n < 1200:
			n += 1
			await process_frame
		if not kf.mars.started:
			kf.mars.easy_gap = 12.0
			kf.tor = "leicht"
	kf.ui.refresh()
	await process_frame
	if kf.tor != "leicht":
		pruefe(false, "kein leichter Kampf herstellbar (Kampf schon begonnen: %s)" % kf.mars.started)
		print("SCHNELL78510 %d Fehler" % fehler)
		quit(1)
		return
	var t: Array = _texte(kf.ui.orders, [])
	pruefe(t.has("KÄMPFEN") and t.has("SCHNELL"), "leichter Kampf wartet auf „Kämpfen“ oder „Schnell“: %s" % [t])
	pruefe(t.any(func(x): return String(x).begins_with("Ein leichter Kampf: dein Held Stufe 14, der stärkste Gegner Stufe ")), "darüber [259T.frage]: %s" % [t])
	pruefe(not kf.ui.schnell_knopf.visible, "vor der Wahl kein Eckknopf „Schnell ›“")
	kf.tor_wahl(false)     # erst „Kämpfen“, dann am Zug der Gruppe der Eckknopf
	n = 0
	while (kf.busy or kf.ring_open) and kf.mars.outcome == "ONGOING" and n < 1800:
		n += 1
		if kf.ring_open: kf.tap()
		await process_frame
	kf.ui.refresh()
	await process_frame
	pruefe(kf.mars.outcome != "ONGOING" or kf.ui.schnell_knopf.visible, "am Zug der Gruppe steht unten links „Schnell ›“ (Kampf: %s, sichtbar %s)" % [kf.mars.outcome, kf.ui.schnell_knopf.visible])
	# 1567 (Chef 17.11., 14:54, „Alrik –0 Leben“ bei Leiste 97/109): was vor „Schnell ›“ verloren ging, zählt mit (wie ein Biss vor dem Knopf)
	var held0 = kf.mars.all[0]
	var vorher_verlust: int = int(kf.mars.hp_start.get(held0.id, held0.hp)) - held0.hp
	if kf.mars.outcome == "ONGOING":
		held0.hp -= 5
		vorher_verlust += 5
		kf.ui.schnell_knopf.pressed.emit()
	n = 0
	while (kf.busy or kf.mars.outcome == "ONGOING") and n < 1800:
		n += 1
		await process_frame
	pruefe(kf.mars.outcome == "WON", "Schnell spielt den Kampf durch: %s" % kf.mars.outcome)
	pruefe(kf.mars.all.filter(func(f): return f.side == "FOES").all(func(f): return f.hp <= 0), "jeder Gegner liegt")
	pruefe(not kf.schnell_verlust.is_empty(), "Verlust je Gefährte gemerkt: %s" % [kf.schnell_verlust])
	for i in 30:
		await process_frame
	kf.ui.refresh()
	await process_frame
	var e: Array = _texte(kf.ui.orders, [])
	var held = kf.mars.all[0]
	pruefe(int(kf.schnell_verlust.get(held.id, 0)) >= vorher_verlust, "Verlust ab Kampfbeginn, auch vor dem Knopf: %s (davor %d)" % [kf.schnell_verlust, vorher_verlust])
	var soll := "%s −%d Leben" % [held.name(0), int(kf.schnell_verlust.get(held.id, 0))]
	pruefe(e.any(func(x): return String(x).begins_with(soll)), "Siegschirm nennt „%s“: %s" % [soll, e])
	pruefe(not e.any(func(x): return String(x).contains(" −0 ")), "kein „−0 Leben“ (1567): %s" % [e])
	# 1567: wer nichts verlor, steht nicht da (Zeile fällt weg, wenn keiner etwas verlor)
	kf.schnell_verlust[held.id] = 0
	kf.ui.refresh()
	await process_frame
	e = _texte(kf.ui.orders, [])
	pruefe(not e.any(func(x): return String(x).begins_with("%s −" % held.name(0))), "ohne Verlust keine Zeile „%s −0 Leben“: %s" % [held.name(0), e])
	print("SCHNELL78510 %d Fehler" % fehler)
	quit(1 if fehler else 0)
