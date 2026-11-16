extends SceneTree
# 999.1 (wie alt 268): Fackel im Kampf in der Nebenhand. Ohne Bild. Prüft: das Kampfblatt (aufruf.gd blatt) trägt „fackel“ nur mit
# einer Fackel in der Nebenhand (nicht mit Schild, nicht leer); die Figur hält sie nur mit einhändiger Waffe oder ohne Waffe, nicht
# mit Zweihänder oder Bogen (beide Hände), und nach dem Wechsel zurück wieder; ohne „fackel“ im Blatt nie.
# Aufruf: im Ordner godot mit -s res://tests/fackel_9991.gd -> „FACKEL9991 n Fehler“

const Aufruf = preload("res://kampf/aufruf.gd")
const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var h := BrsHeld.neu("Mensch", "Wachsoldat")
	h.ausruestung["OFF_HAND"] = Beute.fackel(9991)
	pruefe(bool(Aufruf.blatt(h).get("fackel", false)), "Blatt mit Fackel in der Nebenhand: keine Fackel")
	h.ausruestung["OFF_HAND"] = {"uid": 9992, "base": "shield", "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null}
	pruefe(not bool(Aufruf.blatt(h).get("fackel", true)), "Blatt mit Schild: Fackel")
	h.ausruestung.erase("OFF_HAND")
	pruefe(not bool(Aufruf.blatt(h).get("fackel", true)), "Blatt ohne Nebenhand: Fackel")

	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 4:
		await process_frame
	var fig = p.fight.figures["hero"]
	var hero: Dictionary = fig.fighter.hero
	var einhand = hero.main
	pruefe(not fig.fackel_frei(), "ohne „fackel“ im Blatt: Fackel")
	hero["fackel"] = true
	hero.main = {"id": "longsword", "de": "Langschwert", "en": "Longsword", "ranged": false, "reach": false, "two": false, "type": "SLASHING"}
	pruefe(fig.fackel_frei(), "Langschwert und Fackel: keine Fackel")
	hero.main = {"id": "greataxe", "de": "Zweihandaxt", "en": "Greataxe", "ranged": false, "reach": false, "two": true, "type": "SLASHING"}
	pruefe(not fig.fackel_frei(), "Zweihänder: Fackel bleibt in der Hand")
	hero.main = {"id": "shortbow", "de": "Kurzbogen", "en": "Shortbow", "ranged": true, "reach": false, "two": true, "type": "PIERCING"}
	pruefe(not fig.fackel_frei(), "Bogen: Fackel bleibt in der Hand")
	hero.main = {"id": "", "de": "", "en": "", "ranged": false, "reach": false, "two": false, "type": "BLUDGEONING"}
	pruefe(fig.fackel_frei(), "ohne Waffe: keine Fackel")
	hero.main = einhand
	# Lauf 479: Fackel am Kampfort ohne Toon fiel durch die Signatur (457); Stiel muss Toon tragen
	var sk := Skeleton3D.new()
	sk.add_bone("hand_l")
	root.add_child(sk)
	var fa := Fackel.an(sk, "hand_l", Vector3.ZERO, Vector3.UP, sk)
	fig.fackel_toon(fa)
	var sig := Signatur.pruefen(fa)
	pruefe(not sig.contains("ohne Toon"), "Fackel im Kampfort: " + sig)
	print("FACKEL9991 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
