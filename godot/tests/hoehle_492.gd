extends SceneTree
# 492 ohne Bild: Blutzahnhoehle begehbar wie alt (Story.kt:735). Aus dem Flüsterwald durch den Hoehlenmund (10, 0) in die Hoehle
# (Grundriss hoehle.py: innen, Raumlicht mit Fackeln, Feuer, Pilzen, Kristallen; Waende hoch und niedrig), beim ersten Mal die Zeile
# „Ein modriger Geruch …“; das Gitter (10/11, 5) verschlossen, mit dem rostigen Schluessel auf (Fluegel schwenken), dann begehbar;
# vor Graks Halle (Zeile 4) spricht Grak und kaempft (GRAK); Lyra (8, 1) angesprochen nach Grak: Ketten, Segen, Weihwasser, dann
# geht sie durch das Gitter bis (10, 7) und ist fort (LYRA_GONE); drei Truhen; Monster der Hoehle; zurueck in den Wald.
# Krogg (16, 9) und sein Kampf brauchen das Modell des Grottenschrats (494, Jerry): ohne Modell nur gemeldet.
# Braucht godot/daten wie im Bau (tools/godot/wald_daten.sh). Massgeblich ist die Zeile HOEHLE492.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

# wie am Handy: jede Zeile antippen, bis die Szene vorbei ist
func durch(spiel) -> void:
	for i in 80:
		if not spiel.ui.spricht() and spiel.szene.is_empty(): return
		spiel.ui.naechste()
		await process_frame

func person(spiel, id: String):
	for l in spiel.leute.get_children():
		if l is Leute and String(l.daten.get("id", "")) == id: return l
	return null

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.betrete("forest", Vector2i(10, 1), "UP")
	for i in 3: await process_frame
	var mund: Dictionary = spiel.karte.ausgang(Vector2i(10, 0))
	pruefe(String(mund.get("ziel", {}).get("karte", "")) == "cave" and spiel.karte.tuer(Vector2i(10, 0)), "Hoehlenmund (10, 0) im Wald fuehrt in die Hoehle")
	await spiel.geh_hinaus(mund)
	for i in 5: await process_frame
	pruefe(spiel.karte.id == "cave" and spiel.held.kachel == Vector2i(10, 18), "in der Hoehle am Eingang (10, 18): %s %s" % [spiel.karte.id, spiel.held.kachel])
	pruefe(spiel.gebiet.raumlicht != null and spiel.licht.innen and spiel.licht.hoehle, "Grundriss mit Raumlicht, Licht der Hoehle")
	pruefe(spiel.ui.spricht(), "beim ersten Betreten spricht die Hoehle")
	await durch(spiel)
	pruefe(spiel.zustand.has("cave_seen"), "beim ersten Betreten: „Ein modriger Geruch …“ (cave_seen)")
	var rl: Raumlicht = spiel.gebiet.raumlicht
	var arten := {}
	for c in rl.get_children():
		if c is OmniLight3D: arten[String(c.get_meta("art", "schein"))] = arten.get(String(c.get_meta("art", "schein")), 0) + 1
	pruefe(arten.get("fackel", 0) == 2 and arten.get("kamin", 0) == 1, "zwei Fackeln, ein Lagerfeuer: %s" % arten)
	pruefe(rl.waende.size() > 20 and rl.waende.all(func(w): return w[0] != null and w[1] != null), "Waende hoch und niedrig je Lauf: %d" % rl.waende.size())
	pruefe(spiel.held.fackel_kraft > 2.0, "Fackel des Helden brennt in der Hoehle auch am Tag: %.2f" % spiel.held.fackel_kraft)
	# Gitter
	var gl := spiel.gebiet.find_child("Gitter_L", true, false) as Node3D
	pruefe(gl != null and absf(gl.rotation.y) < 0.01, "Gitter zu (Gitter_L an der Angel)")
	pruefe(not spiel.karte.begehbar(Vector2i(10, 5)), "Gitter sperrt (10, 5)")
	var zu: Array = Geschichte.gitter(spiel.zustand)
	# seit 504 (main) haengt an jedem Satz mit Varianten ein Befehl „variante“: nur die gesagten Saetze zaehlen
	var gesagt := zu.filter(func(b): return String(b["art"]) == "sagen")
	pruefe(gesagt.size() == 1 and String(gesagt[0]["text"]["de"]).begins_with("Ein schweres Eisengitter") and not spiel.zustand.has(Geschichte.GATE_OPEN), "ohne Schluessel: „Ein schweres Eisengitter. Es ist verschlossen.“")
	spiel.zustand.dazu("rusty_key")
	spiel.held.setze(Vector2i(10, 6), "UP")
	pruefe(spiel.angebot(Vector2i(10, 6))[0] == "UNLOCK", "vor dem Gitter bietet der Knopf „Aufschließen“ (Navigation UNLOCK): %s" % [spiel.angebot(Vector2i(10, 6))])
	spiel._aktion()   # 492: mit dem Knopf, wie alt Game.gate
	await durch(spiel)
	for i in 3: await process_frame
	pruefe(spiel.zustand.has(Geschichte.GATE_OPEN) and spiel.zustand.anzahl("rusty_key") == 0, "mit dem rostigen Schluessel: Gitter offen, Schluessel weg")
	await create_timer(1.6).timeout
	pruefe(gl != null and gl.rotation.y > 1.5, "Fluegel aufgeschwenkt: %.2f" % (gl.rotation.y if gl else 0.0))
	pruefe(spiel.karte.begehbar(Vector2i(10, 5)) and spiel.karte.begehbar(Vector2i(11, 5)), "durch das offene Gitter")
	pruefe(spiel.angebot(Vector2i(10, 6))[0] != "UNLOCK", "offenes Gitter ohne „Aufschließen“")
	# Grak vor seiner Halle
	var vor: Array = Geschichte.ausloeser("cave", Vector2i(10, 4), spiel.zustand)
	var kampf: Array = vor.filter(func(c): return String(c["art"]) == "kampf")
	pruefe(kampf.size() == 1 and String(kampf[0]["monster"]) == "hobgoblin_captain" and Streuner.GRUPPE.get("hobgoblin_captain", "") == "GRAK", "vor der Halle: Grak spricht und kaempft (GRAK)")
	var grak = person(spiel, "grak")
	if Streuner.da("hobgoblin_captain"): pruefe(grak != null and grak.kachel == Vector2i(10, 2), "Grak (10, 2) mit Modell")
	else: print("Hinweis: ohne Modell hobgoblin_captain kein Grak auf der Karte (Jerry, godot-kampf.yml)")
	# Lyra
	var lyra = person(spiel, "lyra_cave")
	pruefe(lyra != null and lyra.kachel == Vector2i(8, 1) and lyra.modell != null, "Lyra (8, 1) als Figur lyra")
	spiel.zustand.setze(Geschichte.GRAK_DEFEATED)
	spiel.zustand.dazu("grak_key")
	var ly: Array = Geschichte.gespraech("lyra_cave", spiel.zustand)
	pruefe(ly.any(func(c): return String(c["art"]) == "geben" or String(c.get("ding", "")) == "holy_water") or ly.size() > 6, "Lyra nach Grak: Ketten, Segen, Weihwasser (%d Befehle)" % ly.size())
	spiel.spiele(ly)
	await durch(spiel)
	pruefe(spiel.zustand.has(Geschichte.LYRA_RESCUED) and spiel.zustand.anzahl("holy_water") >= 2, "Lyra befreit, zwei Weihwasser")
	spiel.held.setze(Vector2i(4, 10), "UP")
	var t0 := Time.get_ticks_msec()
	while not spiel.zustand.has(Geschichte.LYRA_GONE) and Time.get_ticks_msec() - t0 < 30000: await process_frame
	pruefe(spiel.zustand.has(Geschichte.LYRA_GONE) and lyra != null and not lyra.visible, "Lyra geht durch das Gitter bis (10, 7) und ist fort (%d ms)" % (Time.get_ticks_msec() - t0))
	# Krogg
	if Streuner.da("bugbear"): pruefe(person(spiel, "krogg") != null, "Krogg (16, 9) mit Modell")
	else: print("Hinweis: ohne Modell bugbear (494, Jerry) kein Krogg und kein Schluessel")
	# Truhen, Monster
	var kisten := 0
	for t in [Vector2i(3, 8), Vector2i(18, 8), Vector2i(4, 14)]:
		if not spiel.kiste(t).is_empty(): kisten += 1
	pruefe(kisten == 3, "drei Truhen: %d" % kisten)
	var h: Herde = spiel.herde
	pruefe(h != null and h.liste.size() >= 1 and h.liste.size() <= 6, "Monster der Hoehle (alt 6, ohne Modell weniger): %d" % (h.liste.size() if h else -1))
	# zurueck
	var raus: Dictionary = spiel.karte.ausgang(Vector2i(10, 19))
	pruefe(String(raus.get("ziel", {}).get("karte", "")) == "forest", "Ausgang (10, 19) in den Wald")
	await spiel.geh_hinaus(raus)
	for i in 5: await process_frame
	pruefe(spiel.karte.id == "forest" and spiel.held.kachel == Vector2i(10, 1), "zurueck im Flüsterwald (10, 1): %s %s" % [spiel.karte.id, spiel.held.kachel])
	_ende()

func _ende() -> void:
	print("HOEHLE492 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
