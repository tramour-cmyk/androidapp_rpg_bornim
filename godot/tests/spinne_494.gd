extends SceneTree
# 494 Riesenspinne ohne Bild: die gekaufte Spinne (kaufspinne.py) hat drei Häute in giant_spider-info.json; figur.gd nimmt je
# Gegnernummer eine davon (drei Varianten, DESIGN-STIL „Abwechslung“) und ihren Wurzelweg aus derselben Datei. Dazu der Probekampf
# „Spinne“ (aufruf.gd SPIDER) bis zum Ende: er läuft, auch wenn die Modelle fehlen (Platzhalterkörper).
# Aufruf: im Ordner godot mit -s res://tests/spinne_494.gd

const Probe = preload("res://kampf/probe.gd")
const Figur = preload("res://kampf/figur.gd")
const Mars = preload("res://regeln/mars.gd")

var fehler := 0
var webs := 0


func _initialize() -> void:
	Engine.time_scale = 30.0
	_lauf.call_deferred()


func _lauf() -> void:
	_regeln()
	_haeute()
	await _kampf()
	await _kampf("SPINNE")     # 494 (Jerry 18:4x): allein wie im alten Spiel (Roamers.kt), ohne Wolf daneben
	for i in 3:     # Netz werfen wählt sie zur Hälfte (mars.gd _pick_intent); mit Kaufmodell (Netzwurf) muss eines fliegen
		if webs > 0 or not FileAccess.file_exists("res://kampf/daten/giant_spider-info.json"):
			break
		await _kampf("SPINNE", 10 + i)
	if webs == 0 and FileAccess.file_exists("res://kampf/daten/giant_spider-info.json"):
		fehler += 1
		print("FEHLER kein Netz geflogen")
	print("SPINNE 494 %s" % ("gut" if fehler == 0 else "%d FEHLER" % fehler))
	quit(1 if fehler > 0 else 0)


func _regeln() -> void:
	var tab: Dictionary = Tabellen.lade()
	var sp: Array = tab.monsters.filter(func(m): return m.id == "giant_spider")
	if sp.is_empty():
		fehler += 1
		print("FEHLER tabellen.json: giant_spider fehlt")
		return
	if not sp[0].get("ranged", false):
		print("Hinweis: giant_spider ohne ranged (Netzwurf), nur Nahkampf")
	print("Spinne 494 Regeln: %s, %s" % [sp[0].get("de", "?"), sp[0].get("hp", "?")])


## Häute: ohne gebaute Modelle (Bau ohne Kaufpakete) steht nur der Platzhalter; dann prüft der Test nur, dass figur.gd nicht
## auf eine Datei mit Haut verweist, die es nicht gibt.
func _haeute() -> void:
	var ip := "res://kampf/daten/giant_spider-info.json"
	if not FileAccess.file_exists(ip):
		print("Spinne 494: keine giant_spider-info.json im Build (ohne Kaufpakete), Platzhalter")
		return
	var j = JSON.parse_string(FileAccess.get_file_as_string(ip))
	if not (j is Dictionary) or j.is_empty():
		fehler += 1
		print("FEHLER giant_spider-info.json leer")
		return
	if j.size() != 3:
		fehler += 1
		print("FEHLER %d Häute statt drei: %s" % [j.size(), j.keys()])
	for haut in j:
		var p := "res://kampf/daten/giant_spider-%s.bin" % haut
		if not FileAccess.file_exists(p):
			fehler += 1
			print("FEHLER Modell fehlt: %s" % p)
		var d: Dictionary = j[haut]
		for schluessel in ["weg", "fps", "breite_m", "laenge_m", "koerper_hoch_m"]:
			if not d.has(schluessel):
				fehler += 1
				print("FEHLER %s: %s fehlt" % [haut, schluessel])
		# Liste „Riesenspinne“: Beine 1,5–1,7 m, Körper 0,40–0,55 m hoch
		var b := float(d.get("breite_m", 0.0))
		var k := float(d.get("koerper_hoch_m", 0.0))
		if b < 1.5 or b > 1.7:
			fehler += 1
			print("FEHLER %s: Spannweite %.2f m (1,50–1,70)" % [haut, b])
		if k < 0.40 or k > 0.55:
			fehler += 1
			print("FEHLER %s: Körper %.2f m hoch (0,40–0,55)" % [haut, k])
		if int(d.get("dreiecke", 0)) > 6000:
			fehler += 1
			print("FEHLER %s: %d Dreiecke (höchstens 6000)" % [haut, d.get("dreiecke", 0)])
		# kein Teil unter dem Boden in irgendeiner Bewegung (kaufspinne.py misst es beim Bau)
		for nm in d.get("tiefster_punkt_m", {}):
			if float(d.tiefster_punkt_m[nm]) < -0.01:
				fehler += 1
				print("FEHLER %s: %s %.3f m im Boden" % [haut, nm, d.tiefster_punkt_m[nm]])
		for nm in ["Stehen", "Gehen", "Rennen", "Biss", "Treffer", "Tod", "Ausweichen"]:
			if not d.get("zeiten", {}).has(nm):
				fehler += 1
				print("FEHLER %s: Bewegung %s fehlt" % [haut, nm])
	print("Spinne 494 Häute: %s" % [j.keys()])


func _kampf(foe := "SPIDER", seed := 3) -> void:
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = foe
	root.add_child(p)
	await process_frame
	p._start(seed)
	for i in 6:
		await process_frame
	var kf = p.fight
	if kf == null:
		fehler += 1
		print("FEHLER kein Kampfort")
		return
	var spinnen: Array = kf.mars.fighters().filter(func(f): return f.monster != null and String(f.monster.id) == "giant_spider")
	if spinnen.is_empty():
		fehler += 1
		print("FEHLER keine Spinne im Probekampf „Spinne“")
	else:
		var fig = kf.figures.get(String(spinnen[0].id))
		print("Spinne 494 Kampf: %d Spinne(n), %d TP" % [spinnen.size(), spinnen[0].max_hp])
		# Verdacht Jerry 17:4x (bestätigt 18:2x): neben dem Kaufwolf las die Spinne dessen Weg (kaufwolf-info.json) und glitt;
		# dazu stand sie 1,5-fach (Spannweite 2,5 m) und der Balken in Menschenhöhe
		if fig != null and FileAccess.file_exists("res://kampf/daten/giant_spider-info.json"):
			Figur.ersatz_art = "kaufwolf"     # wie aufruf.gd im Spiel-Build mit Kaufwolf
			if fig.art() != "":
				fehler += 1
				print("FEHLER Spinne als Ersatz „%s“" % fig.art())
			if fig._weg().is_empty():
				fehler += 1
				print("FEHLER Spinne ohne Weg neben dem Kaufwolf")
			if absf(kf.foe_scale(fig.fighter) - 1.0) > 0.01:
				fehler += 1
				print("FEHLER Spinne %.2f-fach statt echter Größe" % kf.foe_scale(fig.fighter))
			var kopf: float = fig.head().y - fig.position.y
			if kopf > 1.0:
				fehler += 1
				print("FEHLER Balken der Spinne %.2f m hoch" % kopf)
			print("Spinne 494 neben Kaufwolf: Weg %s, Größe %.2f, Balken %.2f m" % [fig._weg().keys(), kf.foe_scale(fig.fighter), kopf])
	kf.mars.find("merc").auto = true
	var t0 := Time.get_ticks_msec()
	var netz_an := 0
	var vorher = null
	while Time.get_ticks_msec() - t0 < 90000:
		await process_frame
		for sp in spinnen:     # angesagtes „Netz werfen“ (die Ansage steht bis zu ihrem Zug)
			var it = kf.mars.intents.get(sp.id)
			if it != null and it[0].get("effect", "") == "WEB" and not is_same(it, vorher):
				netz_an += 1
				vorher = it
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			if kf.mars.pilot_next():
				kf.go_on()
			else:
				var ts: Array = kf.mars.targets(kf.mars.current())
				kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
	print("Spinne 494 Ausgang: %s, Effekte %s, Netz angesagt %d" % [kf.mars.outcome, kf.fx_zahl, netz_an])
	# 494: die Spinne beißt wie im alten Spiel, nur „Netz werfen“ fliegt (als Netz); vorher flog bei jedem ihrer Angriffe ein Pfeil
	if kf.fx_zahl.has("ARROW"):
		fehler += 1
		print("FEHLER Pfeil im Kampf mit der Spinne")
	webs += int(kf.fx_zahl.get("WEB", 0))
	if kf.mars.outcome == "ONGOING":
		fehler += 1
		print("FEHLER Kampf endet nicht: %s" % [kf.mars.fighters().map(func(f): return "%s %d" % [f.id, f.hp])])
	kf.queue_free()
	p.queue_free()
