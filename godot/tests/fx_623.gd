# 623.2 (623 E; 623.8 A, Chef 09.11., 22:23: Szene 2 Wolfskampf): Effekte im Kampf aus werte.json fx (TrefferFx).
# Immer (Logiksatz, ohne Paket): jeder Name, auf den Anlass, Waffengruppe, Zauber, Zustand oder Monster zeigen, steht unter
# „effekte“, jeder Effekt hat art und Pfad unter res://addons/, jede Waffengruppe aus „waffen“ hat eine Zeile, jeder Zustand der
# Paket-Zeilen liegt in mars.gd STATUS; die Dämpfung macht kein Leuchtbunt (glanz höchstens 1, Farben der Spuren unter 0,9).
# Mit Paket und Kaufmodellen (Bau, Rechner nach bau_am_rechner.py): Probekampf Kämpfer (Schwert und Schild) und Söldner Kleriker
# gegen die Wölfe auf Autopilot; je Bild, welcher Effekt neu gezeigt wurde, als Zeile „FX623 <ms> <Name>“; Klingenspur, Blut und
# Luftzug oder Parade müssen vorkommen, Staub beim Sprung, wenn ein Wolf springt. Mit Bild (Film): derselbe Kampf, Kamera wie im
# Spiel; FX_AUS=1 ohne die neuen Effekte (Vergleich).
# Aufruf: godot --headless --path godot --fixed-fps 30 -s res://tests/fx_623.gd   (Exit = Zahl der Fehler)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const DAUER_BILDER := 30 * 120

var fehler := 0


func _initialize() -> void:
	_lauf.call_deferred()


func _fehler(was: String) -> void:
	fehler += 1
	print("FEHLER ", was)


func _daten() -> void:
	var t := TrefferFx.tabelle()
	var eff: Dictionary = t.get("effekte", {})
	if eff.is_empty():
		_fehler("werte.json fx.effekte fehlt")
		return
	for n in eff:
		var e: Dictionary = eff[n]
		if not String(e.get("art", "")) in ["teilchen", "spur", "geschoss"]:
			_fehler("%s: art %s" % [n, e.get("art")])
		var pf := TrefferFx.pfade(n)
		if pf.is_empty() or pf.any(func(p): return not String(p).begins_with("res://addons/")):
			_fehler("%s: Pfad %s" % [n, pf])
		if float(e.get("glanz", 1.0)) > 1.0:
			_fehler("%s: glanz über 1 (Leuchtbunt)" % n)
		var f: Array = e.get("farbe", [])
		if f.size() == 4 and (float(f[0]) > 0.9 or float(f[1]) > 0.9 or float(f[2]) > 0.9):
			_fehler("%s: Spurfarbe zu hell %s" % [n, f])
	var namen := []
	namen.append_array((t.get("anlass", {}) as Dictionary).values())
	for g in t.get("waffengruppe", {}):
		namen.append_array((t.waffengruppe[g] as Dictionary).values())
	namen.append_array((t.get("zauber", {}) as Dictionary).values())
	namen.append_array((t.get("zustand", {}) as Dictionary).values())
	for m in t.get("monster", {}):
		namen.append_array((t.monster[m] as Dictionary).values())
	for n in namen:
		if not eff.has(String(n)):
			_fehler("Verweis auf %s ohne Eintrag in effekte" % n)
	for g in Brs.lade().get("waffen", {}):
		if not String(g).begins_with("_") and not (t.get("waffengruppe", {}) as Dictionary).has(g):
			_fehler("Waffengruppe %s ohne Zeile in fx" % g)
	for st in t.get("zustand", {}):
		if not Mars.STATUS.has(st):
			_fehler("Zustand %s nicht in mars.gd STATUS" % st)
	for m in t.get("monster", {}):
		if not (Brs.lade().get("kennungen", {}) as Dictionary).has(m):
			_fehler("Monster %s nicht in kennungen" % m)
	print("FX623 Daten: %d Effekte, %d Verweise" % [eff.size(), namen.size()])


func _lauf() -> void:
	_daten()
	var paket := TrefferFx.szene("blut") != null and TrefferFx.stil("klingenspur") != null
	if not paket or not FileAccess.file_exists("res://daten/kampf-bewegungen.bin") or not HeldFigur.da():
		print("FX623 ohne Paket oder Kaufmodelle, nur Daten geprüft")
		print("FX623 Fehler: %d" % fehler)
		quit(fehler)
		return
	seed(int(OS.get_environment("SEED")) if OS.get_environment("SEED") != "" else 7)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(int(OS.get_environment("SEED")) if OS.get_environment("SEED") != "" else 7)
	for i in 4:
		await process_frame
	var kf = p.fight
	if kf == null:
		_fehler("kein Kampf")
		quit(fehler)
		return
	kf.mars.find("merc").auto = true
	kf.mars.set_autopilot(true)
	if not kf.busy:
		kf.go_on()
	var vor := {}
	var n := 0
	var sprung := false
	while n < DAUER_BILDER:
		await process_frame
		n += 1
		for k in TrefferFx.gezeigt:
			if int(TrefferFx.gezeigt[k]) > int(vor.get(k, 0)):
				print("FX623 %d %s" % [int(n * 1000.0 / 30.0), k])
				vor[k] = TrefferFx.gezeigt[k]
		for f in kf.figures.values():
			if f.fighter.monster != null and f.letzter_sprung:
				sprung = true
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			if kf.mars.pilot_next() or kf.mars.set_autopilot(true):
				kf.go_on()
			else:
				var c = kf.mars.current()
				var ts: Array = kf.mars.targets(c)
				kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
	print("FX623 gezeigt: %s, Kampf %s nach %d ms" % [TrefferFx.gezeigt, kf.mars.outcome, int(n * 1000.0 / 30.0)])
	if OS.get_environment("FX_AUS") == "":
		for k in ["klingenspur", "blut"]:
			if int(TrefferFx.gezeigt.get(k, 0)) == 0:
				_fehler("%s kam nicht vor" % k)
		if int(TrefferFx.gezeigt.get("luftzug", 0)) + int(TrefferFx.gezeigt.get("parade", 0)) == 0:
			_fehler("weder Luftzug noch Parade")
		if sprung and int(TrefferFx.gezeigt.get("staubschlag", 0)) == 0:
			_fehler("Sprung ohne Staub")
	print("FX623 Fehler: %d" % fehler)
	quit(fehler)
