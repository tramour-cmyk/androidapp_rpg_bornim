# 296.3 (Todesschrei; alt BattleScreen.kt ENEMY_FAINT: „its death cry once, if no blow struck it down“): ein Gegner, den ein
# Zauber oder ein Zustand tötet, schreit, wenn es ihn trifft (t270.11, Chef 08.11., 21:28: mit FOE_FALLS kam das Geheul 3 s zu
# spät), nicht noch einmal beim Sturz (FOE_FALLS); fällt er ohne eigene Meldung, mit dem Sturz; wen ein Hieb tötet, der schreit mit dem Hieb und beim Sturz
# nicht noch einmal; wer flieht, schreit nicht; ein neuer Kampf fängt von vorn an. Prüfung ohne Grafik und ohne Ton.
# Aufruf: im Ordner godot mit -s res://tests/todesschrei_2963.gd (Exit 0 = richtig)
extends SceneTree

var fehler := 0


class Kl extends "res://klang/klang.gd":
	var rufe: Array = []
	func stimme(id: String, ruf: String, _elite := false, _pegel := 0.8) -> void:
		rufe.append("%s:%s" % [id, ruf])


class F:
	var id := ""
	var side := "FOES"
	var monster = null
	var fled := false
	func _init(p_id: String, p_side: String, art := "") -> void:
		id = p_id
		side = p_side
		monster = {"id": art} if art != "" else null
	func weapon():
		return {"id": "longsword", "type": "SLASHING"}


class M:
	var f := {}
	func find(i):
		return f.get(i)


func _initialize() -> void:
	_lauf.call_deferred()


func _soll(gut: bool, was: String) -> void:
	print(("ok     " if gut else "FEHLER ") + was)
	if not gut:
		fehler += 1


func _kampf() -> M:
	var m := M.new()
	m.f = {"held": F.new("held", "PARTY"), "w1": F.new("w1", "FOES", "wolf"), "w2": F.new("w2", "FOES", "wolf")}
	return m


func _meldung(actor, target, damage: int, hp: Dictionary, spell = null, cue = null, roll = null) -> Dictionary:
	return {"actor": actor, "target": target, "damage": damage, "hp": hp, "spell": spell, "cue": cue, "roll": roll}


func _lauf() -> void:
	var k := Kl.new()
	k.effekte_an = false
	root.add_child(k)
	await process_frame
	var m := _kampf()
	# Zauber tötet w1: der Todesschrei bei der Ankunft (treffer_ms 300), vor der Meldung „bricht zusammen“, einmal
	k.kampf(_meldung("held", "w1", 6, {"w1": 0}, "FIRE"), m, 300)
	await create_timer(0.2).timeout
	_soll(k.rufe.is_empty(), "Zaubertod: vor der Ankunft still (%s)" % [k.rufe])
	await create_timer(0.3).timeout
	_soll(k.rufe == ["wolf:tod"], "Zaubertod: Todesschrei bei der Ankunft (%s)" % [k.rufe])
	k.kampf(_meldung(null, "w1", 0, {"w1": 0}, null, "FOE_FALLS"), m)
	k.kampf(_meldung(null, "w1", 0, {"w1": 0}, null, "FOE_FALLS"), m)
	_soll(k.rufe == ["wolf:tod"], "Zaubertod: beim Sturz kein zweiter (%s)" % [k.rufe])
	# Zustand (Blutung, ohne Würfel) tötet w3: Schrei sofort
	k.rufe.clear()
	m.f["w3"] = F.new("w3", "FOES", "wolf")
	k.kampf(_meldung(null, "w3", 3, {"w3": 0}), m)
	await create_timer(0.2).timeout
	k.kampf(_meldung(null, "w3", 0, {"w3": 0}, null, "FOE_FALLS"), m)
	_soll(k.rufe == ["wolf:tod"], "Zustandstod: ein Schrei mit dem Schaden (%s)" % [k.rufe])
	# Hieb tötet w2: Schrei mit dem Hieb, beim Sturz keiner mehr
	k.rufe.clear()
	k.kampf(_meldung("held", "w2", 7, {"w2": 0}, null, null, ["ATTACK", 15, 0, 0, false]), m)
	await create_timer(0.6).timeout
	k.kampf(_meldung(null, "w2", 0, {"w2": 0}, null, "FOE_FALLS"), m)
	_soll(k.rufe == ["wolf:tod"], "Hiebtod: ein Todesschrei mit dem Hieb, keiner beim Sturz (%s)" % [k.rufe])
	# neuer Kampf, gleiche Namen: wieder ein Schrei; wer flieht, schreit nicht
	k.rufe.clear()
	var m2 := _kampf()
	m2.f["w2"].fled = true
	k.kampf(_meldung(null, "w1", 0, {"w1": 0}, null, "FOE_FALLS"), m2)
	k.kampf(_meldung(null, "w2", 0, {"w2": 0}, null, "FOE_FALLS"), m2)
	_soll(k.rufe == ["wolf:tod"], "neuer Kampf: Schrei wieder da, Fliehender stumm (%s)" % [k.rufe])
	# Held fällt: kein Gegnerschrei
	k.rufe.clear()
	k.kampf(_meldung(null, "held", 0, {"held": 0}, null, "FOE_FALLS"), m2)
	_soll(k.rufe.is_empty(), "ohne Monster kein Schrei (%s)" % [k.rufe])
	print("Todesschrei 296.3: %s" % ("alles richtig" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
