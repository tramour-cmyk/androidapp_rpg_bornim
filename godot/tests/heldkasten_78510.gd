# 785.10 ohne Bild: im Kasten des Helden steht unter Leben und Mana die Erfahrung als goldener Balken, dahinter die Stufe („St. n“)
# wie alt (BattleScreen.kt 1708, 1725–1729), im Probekampf ohne Stand voll; der Söldner hat keinen. Massgeblich: HELDKASTEN78510
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
	pruefe(hb.size() == 3, "Held (Kleriker): Leben, Mana, Erfahrung: %d Balken" % hb.size())
	pruefe(_texte(hk, []).has(stufe), "hinter dem Erfahrungsbalken „%s“: %s" % [stufe, _texte(hk, [])])
	pruefe(hb.size() == 3 and is_equal_approx((hb[2] as ProgressBar).value, (hb[2] as ProgressBar).max_value), "Probekampf ohne Stand: Balken voll")
	pruefe(sb.size() == 1 and not _texte(sk, []).any(func(t): return String(t).begins_with("St. ")), "Söldner ohne Erfahrung: %d Balken" % sb.size())
	hk.free(); sk.free()
	print("HELDKASTEN78510 %d Fehler" % fehler)
	quit(1 if fehler else 0)
