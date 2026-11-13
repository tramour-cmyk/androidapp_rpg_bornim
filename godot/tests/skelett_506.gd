extends SceneTree
# 506 ohne Bild: Probekampf „Skelette“ (aufruf.gd SKELETONS): drei Skelette mit Name und Leben nach BRS aus werte.json (922: nicht
# mehr SRD 2W8+4), MARS spielt den Kampf auf Autopilot zu Ende.
# Mit Kaufpaketen (kaufskelett.py): drei Kits in skeleton-info.json, je Nummer eines, Bewegungen, Maße, Glutpunkte, Kopfdrehung.
# Aufruf: im Ordner godot mit -s res://tests/skelett_506.gd (Exit 0 = gut)

const Probe = preload("res://kampf/probe.gd")
const Brs = preload("res://regeln/brs.gd")

var fehler := 0


func _initialize() -> void:
	Engine.time_scale = 30.0
	_lauf.call_deferred()


func _lauf() -> void:
	_info()
	for k in ["FIGHTER", "CLERIC", "WIZARD"]:
		await _kampf(k, k == "FIGHTER")
	print("SKELETT506 %s" % ("0 Fehler" if fehler == 0 else "%d FEHLER" % fehler))
	quit(1 if fehler > 0 else 0)


const INFO := "res://kampf/daten/skeleton-info.json"
const BEWEGUNGEN := ["Stehen", "Gehen", "Rennen", "Hieb", "Treffer", "Tod", "Abwehr", "Ausweichen", "Ausweichen links", "Auferstehen"]


## LISTE-FIGUREN „Skelett“: 1 Größe 160–185 cm, 4 drei Kits; Modellregel 7 unter 6.000 Dreiecke; nichts im Boden (außer Auferstehen)
func _info() -> void:
	if not FileAccess.file_exists(INFO):
		print("Skelett 506: keine skeleton-info.json im Build (ohne Kaufpakete), Platzhalter")
		return
	var j = JSON.parse_string(FileAccess.get_file_as_string(INFO))
	if not j is Dictionary or j.keys() != ["schwert", "schild", "speer"]:
		fehler += 1
		print("FEHLER Kits: %s" % [j.keys() if j is Dictionary else j])
		return
	for kit in j:
		var d: Dictionary = j[kit]
		if not FileAccess.file_exists("res://kampf/daten/skeleton-%s.bin" % kit):
			fehler += 1
			print("FEHLER Modell fehlt: %s" % kit)
		if d.get("groesse_cm", 0.0) < 160.0 or d.get("groesse_cm", 0.0) > 185.0:
			fehler += 1
			print("FEHLER %s: %.0f cm (160–185)" % [kit, d.get("groesse_cm", 0.0)])
		if d.get("dreiecke", 99999) > 6000:
			fehler += 1
			print("FEHLER %s: %d Dreiecke (höchstens 6000)" % [kit, d.get("dreiecke", 0)])
		for nm in BEWEGUNGEN:
			if not d.get("zeiten", {}).has(nm):
				fehler += 1
				print("FEHLER %s: Bewegung %s fehlt" % [kit, nm])
		for nm in d.get("tiefster_punkt_m", {}):
			if nm != "Auferstehen" and float(d.tiefster_punkt_m[nm]) < -0.01:
				fehler += 1
				print("FEHLER %s: %s %.3f m im Boden" % [kit, nm, d.tiefster_punkt_m[nm]])
		for nm in ["Gehen", "Ausweichen", "Ausweichen links"]:
			if not d.get("weg", {}).has(nm):
				fehler += 1
				print("FEHLER %s: Weg %s fehlt" % [kit, nm])
		if not d.get("hieb") is Array or d.hieb.size() != 4:
			fehler += 1
			print("FEHLER %s: Aufschlag des Hiebs fehlt" % kit)
	print("Skelett 506: Kits %s, %s cm, Dreiecke %s" % [j.keys(), j.values().map(func(d): return d.groesse_cm), j.values().map(func(d): return d.dreiecke)])


## Mit Kaufmodell: jede Figur trägt ihr Kit (je Nummer ein anderes), hat Bewegungen, Kopf zum Ziel und Glut in den Augen
func _figuren(kf, feinde: Array) -> void:
	if not FileAccess.file_exists(INFO):
		return
	var pfade := []
	for f in feinde:
		var fig = kf.figures.get(f.id)
		if fig == null:
			fehler += 1
			print("FEHLER keine Figur für %s" % f.id)
			continue
		pfade.append(fig._model_path().get_file())
		var sk = fig._find(fig.model, "Skeleton3D")
		if sk == null or sk.find_bone("kopf") < 0 or sk.find_bone("hals") < 0:
			fehler += 1
			print("FEHLER %s: Gerüst ohne kopf/hals" % f.id)
		for nm in BEWEGUNGEN:
			if fig.anim == null or not fig.anim.has_animation(nm):
				fehler += 1
				print("FEHLER %s: keine Bewegung %s" % [f.id, nm])
		if fig.hieb.size() != 4 or fig.weg.is_empty():
			fehler += 1
			print("FEHLER %s: Hieb %s, Weg %s" % [f.id, fig.hieb, fig.weg.keys()])
		if fig.mats.is_empty() or fig.mats.any(func(m): return float(m.get_shader_parameter("glut")) <= 0.0):
			fehler += 1
			print("FEHLER %s: Augen ohne Glut" % f.id)
		if absf(kf.foe_scale(f) - 1.32) > 0.01:
			fehler += 1
			print("FEHLER %s: %.2f-fach statt 1,32 wie jeder Zweibeiner" % [f.id, kf.foe_scale(f)])
	var verschieden := {}
	for p in pfade:
		verschieden[p] = true
	if verschieden.size() != 3:
		fehler += 1
		print("FEHLER Kits nicht verschieden: %s" % [pfade])
	print("Skelett 506 Figuren: %s" % [pfade])
	_ruhe(kf, feinde)


## t274.14 (Chef 10.11., 13:16: „völlig hyper, die wackeln ständig mit dem Schwert … im Gleichklang und zappeln auf der Stelle“):
## Stelle in der Ruheschleife je Skelett (verschieden?), Ausschlag in „Stehen“ (größter Weg von Hand oder Kopf um seine Mitte, cm) und
## Dauer der Schleife beim gespielten Tempo
const RUHE_HAND_CM := 6.0      # Hand (mit Schwert) höchstens so weit
const RUHE_SCHLEIFE_S := 1.8   # und die Schleife mindestens so lang (Kauf 1,03 s: Zappeln)
func _ruhe(kf, feinde: Array) -> void:
	var stellen := []
	for f in feinde:
		var fig = kf.figures.get(f.id)
		if fig == null or fig.anim == null:
			continue
		stellen.append([String(fig.anim.current_animation), snappedf(fig.anim.current_animation_position, 0.01), fig._schleifen])
		var sk = fig._find(fig.model, "Skeleton3D")
		if not fig.anim.has_animation("Stehen") or sk == null:
			continue
		var an: Animation = fig.anim.get_animation("Stehen")
		var vorher_anim := String(fig.anim.current_animation)
		var vorher_t: float = fig.anim.current_animation_position
		fig.anim.play("Stehen")
		var best := ["", 0.0, 0.0]
		for b in sk.get_bone_count():
			var n := String(sk.get_bone_name(b)).to_lower()
			if not (n.contains("hand") or n.contains("kopf") or n.contains("wrist")):
				continue
			var pts := []
			var mitte := Vector3.ZERO
			var schritte := 48
			for i in schritte:
				fig.anim.seek(an.length * i / schritte, true)
				sk.force_update_all_bone_transforms()
				var q: Vector3 = (sk.global_transform * sk.get_bone_global_pose(b)).origin
				pts.append(q); mitte += q
			mitte /= schritte
			var weit := 0.0
			for q in pts: weit = maxf(weit, (q - mitte).length())
			if weit > best[1]: best = [n, weit, 0.0]
		if vorher_anim != "":
			fig.anim.play(vorher_anim); fig.anim.seek(vorher_t, true)
		var tp := float(fig.tempo.get("Stehen", 1.0))
		best[2] = an.length / tp   # gespielt mit dem Tempo aus skeleton-info.json
		print("RUHE %s: %s %.1f cm, Schleife %.2f s bei Tempo %.2f" % [f.id, best[0], best[1] * 100.0, best[2], tp])
		if best[1] * 100.0 > RUHE_HAND_CM or best[2] < RUHE_SCHLEIFE_S:
			fehler += 1
			print("FEHLER %s: Ruhe zu unruhig (%s %.1f cm, Schleife %.2f s)" % [f.id, best[0], best[1] * 100.0, best[2]])
	var gleich := 0
	for i in stellen.size():
		for j in range(i + 1, stellen.size()):
			if stellen[i][0] == stellen[j][0] and absf(stellen[i][1] - stellen[j][1]) < 0.05: gleich += 1
	print("RUHE Stellen %s" % [stellen])
	if gleich > 0:
		fehler += 1
		print("FEHLER Skelette im Gleichklang: %s" % [stellen])


## [bis_ende]: MARS spielt auf Autopilot zu Ende; unter einem Drittel der Lebenspunkte gibt er den Zug an den Spieler zurück
## (autopilot_blocked), darum nur mit dem Kämpfer, der drei Skelette sicher besiegt; sonst nur Aufstellung und Regeln
func _kampf(k: String, bis_ende: bool) -> void:
	var p = Probe.new()
	p.hero_cls = k
	p.merc_cls = "CLERIC" if k != "CLERIC" else "FIGHTER"
	p.foe = OS.get_environment("FOE") if OS.has_environment("FOE") else "SKELETONS"
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
	if feinde.size() != 3 or feinde.any(func(f): return String(f.monster.id) != "skeleton" or String(f.monster.de) != "Skelett"):
		fehler += 1
		print("FEHLER Gegner: %s" % [feinde.map(func(f): return "%s/%s" % [f.monster.id, f.monster.de])])
	var leben := int(Brs.monster("skeleton").get("leben", -1))     # 922 (Lauf 346): BRS aus werte.json (36), nicht SRD 6–20
	for f in feinde:
		if f.max_hp != leben:
			fehler += 1
			print("FEHLER Trefferpunkte %d (werte.json %d)" % [f.max_hp, leben])
	if k == "FIGHTER":
		for i in 30:
			await process_frame
		_figuren(kf, feinde)
	if not bis_ende:
		print("Skelett 506 %s gegen drei Skelette: aufgestellt, TP %s" % [k, feinde.map(func(f): return f.max_hp)])
		kf.queue_free()
		p.queue_free()
		for i in 3:
			await process_frame
		return
	kf.mars.find("merc").auto = true
	kf.mars.set_autopilot(true)
	if not kf.busy:
		kf.go_on()
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 90000 and kf.mars.outcome == "ONGOING":
		await process_frame
	print("Skelett 506 %s gegen drei Skelette: %s, TP %s" % [k, kf.mars.outcome, feinde.map(func(f): return f.max_hp)])
	if kf.mars.outcome == "ONGOING":
		var c = kf.mars.current()
		print("  dran %s, Zug %d, busy %s, TP %s" % [c.id if c else "-", kf.mars.turn, kf.busy, kf.mars.fighters().map(func(f): return "%s:%d" % [f.id, f.hp])])
		fehler += 1
		print("FEHLER Kampf endet nicht (%s)" % k)
	kf.queue_free()
	p.queue_free()
	for i in 3:
		await process_frame
