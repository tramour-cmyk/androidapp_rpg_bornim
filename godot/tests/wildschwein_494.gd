extends SceneTree
# 494 ohne Bild: Probekampf „Wildschwein“ (aufruf.gd BOARS): ein Wildschwein mit Name und Hauern, Leben nach BRS aus werte.json
# (922: nicht mehr SRD 2W8+2), MARS spielt es auf Autopilot zu Ende; im Bild ein Vierbeiner (Figur.vier), mit Kaufmodell der Keiler.
# Dazu der Riesen-Hundertfüßer (CENTIPEDES), Riesenegel (LEECHES), Säureschnecke (SLUGS), Riesenratte (RATTE) und Riesenfledermaus
# (FLEDERMAUS), je mit Leben aus werte.json.
# Aufruf: im Ordner godot mit -s res://tests/wildschwein_494.gd

const Probe = preload("res://kampf/probe.gd")
const Figur = preload("res://kampf/figur.gd")
const Brs = preload("res://regeln/brs.gd")

var fehler := 0


func _initialize() -> void:
	Engine.time_scale = 30.0
	_lauf.call_deferred()


func _lauf() -> void:
	for k in ["FIGHTER", "WIZARD"]:
		await _kampf(k, "BOARS", "boar", "Wildschwein")
	await _kampf("FIGHTER", "CENTIPEDES", "giant_centipede", "Riesen-Hundertfüßer")
	# Kauf 348.12c: Riesenegel (Kennung der Stirge) und Säureschnecke (Kennung der Ockergallerte), Namen nach LISTE-FIGUREN
	await _kampf("FIGHTER", "LEECHES", "stirge", "Riesenegel")
	await _kampf("FIGHTER", "SLUGS", "ochre_jelly", "Säureschnecke")
	# Jerry 18:4x: Riesenratte und Riesenfledermaus je allein mit eigenen Regeln wie im alten Spiel
	await _kampf("FIGHTER", "RATTE", "giant_rat", "Riesenratte")
	await _kampf("WIZARD", "FLEDERMAUS", "giant_bat", "Riesenfledermaus")
	print("WILDSCHWEIN 494 %s" % ("gut" if fehler == 0 else "%d FEHLER" % fehler))
	quit(1 if fehler > 0 else 0)


func _kampf(k: String, foe: String, id: String, de: String) -> void:
	var p = Probe.new()
	p.hero_cls = k
	p.merc_cls = "CLERIC"
	p.foe = foe
	root.add_child(p)
	await process_frame
	p._start(3)
	for i in 6:
		await process_frame
	var kf = p.fight
	if kf == null:
		fehler += 1
		print("FEHLER kein Kampfort (%s)" % k)
		return
	var feinde: Array = kf.mars.fighters().filter(func(f): return f.side == "FOES")
	if feinde.size() != 1 or String(feinde[0].monster.id) != id or String(feinde[0].monster.de) != de:
		fehler += 1
		print("FEHLER Gegner: %s" % [feinde.map(func(f): return "%s/%s" % [f.monster.id, f.monster.de])])
	elif feinde[0].max_hp != int(Brs.monster(id).get("leben", -1)):
		# 922 (Lauf 346): Leben nach BRS aus werte.json (Wildschwein 29), nicht mehr die SRD-Spanne (2W8+2 → 4–18)
		fehler += 1
		print("FEHLER Trefferpunkte %d (werte.json %d)" % [feinde[0].max_hp, int(Brs.monster(id).get("leben", -1))])
	var fig = kf.figures.get(String(feinde[0].id)) if not feinde.is_empty() else null
	if fig == null or not Figur.vier(fig.fighter):
		fehler += 1
		print("FEHLER Figur %s kein Vierbeiner" % de)
	if fig != null:
		_bild(fig)
	kf.mars.find("merc").auto = true
	kf.mars.set_autopilot(true)
	if not kf.busy:
		kf.go_on()
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 60000 and kf.mars.outcome == "ONGOING":
		await process_frame
	print("Wildschwein 494 %s gegen %s: %s, %d TP, Modell %s" % [k, de, kf.mars.outcome, feinde[0].max_hp if not feinde.is_empty() else 0,
		fig._model_path() if fig != null else "-"])
	if kf.mars.outcome == "ONGOING":
		fehler += 1
		print("FEHLER Kampf endet nicht (%s)" % k)
	kf.queue_free()
	p.queue_free()
	for i in 3:
		await process_frame


## 494 Prüfung Keiler und Hundertfüßer (Jerry 03.11., 18:2x): mit Kaufmodell jede Kampfbewegung da (der Keiler hatte keinen Treffer,
## im Kampf nur das Zittern), keine im Boden (kauftier.py misst tiefster_punkt_m), Name und Balken über dem Tier statt in Wolfshöhe
## (Hundertfüßer 0,26 m hoch, Balken stand bei 1,12 m)
const KAMPF_BEW := ["Stehen", "Gehen", "Rennen", "Treffer", "Tod"]

func _bild(fig) -> void:
	var a: String = Figur.ersatz()
	var ip := "res://kampf/daten/%s-info.json" % a
	if not FileAccess.file_exists(ip):
		print("Wildschwein 494 %s: ohne Kaufmodell (Platzhalter)" % a)
		return
	if a == "giant_bat":     # fliegt ohne Schritte (kein Gehen am Boden, kein Weg); welches Modell, wählt der Chef in 510
		print("Wildschwein 494 giant_bat: Flieger, Bewegungen %s" % [fig.anim.get_animation_list() if fig.anim else []])
		return
	var j: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ip))
	for fell in j:
		var d: Dictionary = j[fell]
		for nm in KAMPF_BEW + [("Hauer" if d.has("Hauer") else "Biss")]:
			if not d.has(nm):
				fehler += 1
				print("FEHLER %s %s: Bewegung %s fehlt" % [a, fell, nm])
		for nm in d.get("tiefster_punkt_m", {}):
			if nm != "Fressen" and float(d.tiefster_punkt_m[nm]) < -0.01:     # Fressen spielt der Kampf nicht
				fehler += 1
				print("FEHLER %s %s: %s %.3f m im Boden" % [a, fell, nm, d.tiefster_punkt_m[nm]])
		if not d.has("tiefster_punkt_m"):
			print("Hinweis %s %s: ohne tiefster_punkt_m (älterer Bau)" % [a, fell])
	if fig.anim == null or not fig.anim.has_animation("Treffer"):
		fehler += 1
		print("FEHLER %s: Figur ohne Treffer" % a)
	var hoch: float = float(fig.mass.get("hoehe_m", 0.0))
	var kopf: float = fig.head().y - fig.position.y
	if hoch > 0.0 and (kopf < hoch or kopf > hoch + 0.3):
		fehler += 1
		print("FEHLER %s: Balken %.2f m über dem Boden, Tier %.2f m hoch" % [a, kopf, hoch])
	if fig.weg.is_empty():
		fehler += 1
		print("FEHLER %s: ohne Weg (gleitet beim Platzwechsel)" % a)
	print("Wildschwein 494 %s: Bewegungen %s, Weg %s, Balken %.2f m, Tier %.2f m" % [a, fig.anim.get_animation_list() if fig.anim else [], fig.weg.keys(), kopf, hoch])
