extends SceneTree
# 563 (Chef 04.11., 17:02, t257: „die Statuseffekte sind ja gruselig, aber immerhin, es steht was da“; im Bild „Blut 3“ über
# „! Anspringen“, die grüne Lebensleiste läuft durch die Schrift der Ansage): Messung ohne Bild im Probekampf (Kleriker Mira,
# Söldner Kämpfer, Wölfe). Alle Wölfe tragen „Blut 3“ (VIELE=1: einer dazu „Betäubt 1“ und „Schwach 2“), Mira „Gift 2“ (nur gezeigt,
# nicht gerechnet); die Gruppe wehrt nur ab, die Wölfe greifen an. Je Bild: liegt ein Zustandsschild auf einer Ansage, einer Lebensleiste
# oder einem anderen Zustandsschild, oder eine Lebensleiste auf der Ansage eines anderen?
# Aufruf: im Ordner godot --headless -s res://tests/zustaende_563.gd (braucht daten/ und kampf/daten/ wie im Bau);
# ZUSTAND563=A prüft den Vorschlag. Exit 0 = in Ruhe überlappt nichts (in Bewegung gezählt, nur Maß).

const DAUER_MS := 90000
var fehler := 0
var funde := {"Zustand auf Ansage": 0, "Zustand auf Leiste": 0, "Zustand auf Zustand": 0, "Leiste auf fremder Ansage": 0}
var in_ruhe := {}     # dieselben Funde, wenn nichts läuft (wie im Bild des Chefs: die Gruppe am Zug); die übrigen fallen in Bewegungen
var ruhig := false
var ruhe_bilder := 0
var erst := {}
var bilder := 0

func _initialize() -> void:
	_lauf.call_deferred()

## ohne Bild; zustaende_563_bild.gd legt hier das Bild ab
func _bild(_n: String) -> void:
	await process_frame

## VIELE=1: der erste Wolf trägt dazu „Betäubt 1“ und „Schwach 2“ (eine breite Zeile, Härtefall)
var viele := OS.get_environment("VIELE") != ""

func _zustaende(k) -> void:
	var st := {}
	var erster := true
	for f in k.mars.fighters():
		if f.side == "FOES":
			st[f.id] = {"BLEED": 3, "STUN": 1, "WEAK": 2} if erster and viele else {"BLEED": 3}
			erster = false
		elif f.id == "hero":
			st[f.id] = {"POISON": 2}
	k.shown["status"] = st

## was in diesem Bild gezeichnet wurde, gegeneinander
func _messe(k) -> void:
	var ui = k.ui
	var dp: float = ui.dp
	var leisten := []
	for id in ui.balken_of:
		leisten.append([id, Rect2(ui.balken_of[id], Vector2(44 * dp, 4 * dp))])
	var schilder := []
	for id in ui.sign_of:
		schilder.append([id, ui.sign_of[id]])
	var zust: Array = ui.placed_status
	bilder += 1
	for zi in zust.size():
		var z: Rect2 = zust[zi]
		var wer = ui.placed_status_of[zi]
		for s in schilder:
			if z.intersects(s[1]):
				_fund("Zustand auf Ansage", "%s %s auf Ansage %s %s" % [wer, z, s[0], s[1]])
		for l in leisten:
			if z.intersects(l[1]):
				_fund("Zustand auf Leiste", "%s %s auf Leiste %s %s" % [wer, z, l[0], l[1]])
	for i in zust.size():
		for j in range(i + 1, zust.size()):
			if zust[i].intersects(zust[j]):
				_fund("Zustand auf Zustand", "%s auf %s" % [zust[i], zust[j]])
	for l in leisten:
		for s in schilder:
			if s[0] != l[0] and l[1].intersects(s[1]):
				_fund("Leiste auf fremder Ansage", "Leiste %s %s auf Ansage %s %s" % [l[0], l[1], s[0], s[1]])

var log_an := OS.get_environment("MESS_LOG") != ""

func _fund(was: String, wie := "") -> void:
	funde[was] += 1
	if ruhig:
		in_ruhe[was] = in_ruhe.get(was, 0) + 1
	if log_an and funde[was] <= 6:
		print("  Bild %d %s: %s" % [bilder, was, wie])
	if not erst.has(was):
		erst[was] = bilder

func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	var p = load("res://kampf/probe.tscn").instantiate()
	root.add_child(p)
	await process_frame
	p.hero_cls = "CLERIC"
	p.still_name = "Mira"
	p.merc_cls = "FIGHTER"
	p.foe = "WOLVES"
	p._start(7)
	var t0 := Time.get_ticks_msec()
	while p.fight == null and Time.get_ticks_msec() - t0 < 15000:
		await process_frame
	var k = p.fight
	await create_timer(2.5).timeout
	var ui = k.ui
	if ui == null:
		print("FEHLER kein Kampfschirm")
		quit(1)
		return
	Engine.time_scale = 4.0
	var bis := Time.get_ticks_msec() + DAUER_MS
	var bild_gemacht := false
	while Time.get_ticks_msec() < bis and k.mars.outcome == "ONGOING":
		_zustaende(k)
		ui.balken_of.clear()
		await process_frame
		ruhig = not k.busy and not k.playing
		if ruhig:
			ruhe_bilder += 1
		_messe(k)
		var c = k.mars.current()
		if k.ring_open and Time.get_ticks_msec() - k.ring_start > 3000:
			k._answer_ring("NONE")
		# ein Bild, sobald zwei Ansagen stehen und die Gruppe am Zug ist (wie im Bild des Chefs)
		if not bild_gemacht and ruhig and c.side == "PARTY" and ui.sign_of.size() >= 2:
			Engine.time_scale = 1.0
			await create_timer(0.6).timeout
			# derselbe Augenblick heute und mit dem Vorschlag A
			var war: String = ui.zustand_563
			for v in ["", "A"]:
				ui.zustand_563 = v
				_zustaende(k)
				await _bild("563_" + (v if v != "" else "jetzt"))
			ui.zustand_563 = war
			bild_gemacht = true
			Engine.time_scale = 4.0
		# die Gruppe am Zug: 45 Bilder lang stehen lassen (so sieht der Spieler es am längsten), dann abwehren
		if ruhig and c.side == "PARTY":
			Engine.time_scale = 1.0
			for i in 45:
				_zustaende(k)
				ui.balken_of.clear()
				await process_frame
				ruhig = not k.busy and not k.playing
				if ruhig:
					ruhe_bilder += 1
				_messe(k)
			Engine.time_scale = 4.0
			k.order(["wait"])
	Engine.time_scale = 1.0
	var summe := 0
	var ruhe := 0
	for was in funde:
		summe += funde[was]
		ruhe += in_ruhe.get(was, 0)
		print("%s: %d Bilder, davon in Ruhe %d%s" % [was, funde[was], in_ruhe.get(was, 0), (" (erstes Bild %d)" % erst[was]) if erst.has(was) else ""])
	print("ZUSTAND563 %s%s: %d Bilder gemessen (%d in Ruhe), %d Überlappungen, in Ruhe %d, Ausgang %s" % [ui.zustand_563 if ui.zustand_563 != "" else "jetzt",
		" viele" if viele else "", bilder, ruhe_bilder, summe, ruhe, k.mars.outcome])
	# Grenze: in Ruhe nichts; in Bewegung (eine Figur läuft, die Schilder folgen ihr) nur Maß
	quit(1 if ruhe > 0 else 0)
