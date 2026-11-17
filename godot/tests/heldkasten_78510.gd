# 785.10 ohne Bild, Rückläufer (Chef 17.11., 08:44: „Wir haben nur den Lebensbalken und den Mana-Balken. Wofür brauche ich den?“):
# im Kasten des Helden nur Leben und Mana, kein Erfahrungsbalken und keine Stufe („St. n“); der Söldner nur Leben. Massgeblich: HELDKASTEN78510
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
var fehler := 0


func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1


func _initialize() -> void:
	_lauf.call_deferred()


func _texte(n: Node, aus: Array) -> Array:
	if n is Label: aus.append((n as Label).text)
	for c in n.get_children(): _texte(c, aus)
	return aus


func _lauf() -> void:
	seed(7)
	var p = Probe.new()
	p.hero_cls = "CLERIC"
	p.merc_cls = "FIGHTER"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 4:
		await process_frame
	var kf = p.fight
	var warte := 0
	while kf.verhuellt and warte < 600:
		warte += 1
		await process_frame
	kf.ui.refresh()
	for i in 5:
		await process_frame
	var held = kf.mars.all[0]
	var hk: Control = kf.ui._party_box(held)
	var sk: Control = kf.ui._party_box(kf.mars.all.filter(func(f): return f.side == "PARTY")[1])
	var hb := hk.find_children("*", "ProgressBar", true, false)
	var sb := sk.find_children("*", "ProgressBar", true, false)
	var stufe := "St. %d" % held.level()
	pruefe(hb.size() == 2, "Held (Kleriker): nur Leben und Mana: %d Balken" % hb.size())
	pruefe(not _texte(hk, []).has(stufe), "keine Stufe „%s“ im Kasten: %s" % [stufe, _texte(hk, [])])
	pruefe(sb.size() == 1 and not _texte(sk, []).any(func(t): return String(t).begins_with("St. ")), "Söldner ohne Erfahrung: %d Balken" % sb.size())
	hk.free(); sk.free()
	print("HELDKASTEN78510 %d Fehler" % fehler)
	quit(1 if fehler else 0)
