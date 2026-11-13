# 806 (Fund t277.7): „Kampf messen“ (Bausteine806) läuft am echten Kampfort durch, hält solange die Meldungen an, misst jeden
# Baustein und stellt danach alles wieder her (sichtbar, Schatten, Kantenglättung, Auflösung); der Kampf geht danach weiter.
# Dazu: im Kampfort kein Bodennebel mehr (Archiv „806, Lichtung mit Nebel“: sonst ohne Nebel).
# Run: godot --headless --path godot --fixed-fps 30 -s res://tests/bausteine_806.gd   (Exit 0 = gut)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")

var fehler := 0


func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok:
		fehler += 1


func _initialize() -> void:
	_run.call_deferred()


func _sichtbar(kf) -> Dictionary:
	var d := {}
	for n in kf.find_children("*", "VisualInstance3D", true, false):
		d[n.get_path()] = n.visible
	return d


func _run() -> void:
	root.size = Vector2i(1080, 2340)
	await process_frame
	seed(7)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 4:
		await process_frame
	var kf = p.fight
	pruefe(kf != null, "Kampfort steht")
	if kf == null:
		quit(1)
		return
	pruefe(kf.find_children("Bodennebel", "", true, false).is_empty(), "kein Bodennebel im Kampfort")
	var vorher := _sichtbar(kf)
	var sonne: bool = kf._sun.shadow_enabled
	var aa := root.screen_space_aa
	var aufl := root.scaling_3d_scale
	var zuege_vorher: int = kf.zuege
	var bs := Bausteine806.new(kf)
	kf.add_child(bs)
	pruefe(kf.messpause, "Meldungen halten an")
	var n := 0
	var zuege_waehrend := -1
	while n < 30 * 60 and bs.is_processing():
		await process_frame
		n += 1
		if bs.i == 3 and zuege_waehrend < 0:
			zuege_waehrend = kf.zuege
	print("  " + "\n  ".join(PackedStringArray(Bausteine806.zeilen)))
	pruefe(not bs.is_processing(), "Messung fertig nach %.1f s" % (n / 30.0))
	pruefe(Bausteine806.zeilen.size() >= 6 and String(Bausteine806.zeilen[-1]) == "fertig", "Zeilen je Baustein (%d)" % Bausteine806.zeilen.size())
	pruefe(String(Bausteine806.zeilen[1]).begins_with("alles an:"), "erste Zeile „alles an“")
	pruefe(Bausteine806.zeilen.any(func(z): return String(z).begins_with("alles aus:")), "Zeile „alles aus“")
	pruefe(not kf.messpause, "Meldungen laufen wieder")
	var nachher := _sichtbar(kf)
	var anders := 0
	for k in vorher:
		if nachher.has(k) and nachher[k] != vorher[k]:
			anders += 1
			print("  anders: %s" % k)
	pruefe(anders == 0, "alles wieder sichtbar wie vorher")
	pruefe(kf._sun.shadow_enabled == sonne, "Schatten wie vorher")
	pruefe(root.screen_space_aa == aa, "Kantenglättung wie vorher")
	pruefe(absf(root.scaling_3d_scale - aufl) < 0.001, "Auflösung wie vorher")
	pruefe(kf.ui.visible, "Kampfschirm sichtbar")
	pruefe(zuege_waehrend <= zuege_vorher + 1, "während der Messung kein neuer Zug (%d → %d)" % [zuege_vorher, zuege_waehrend])
	print("BAUSTEINE806 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
