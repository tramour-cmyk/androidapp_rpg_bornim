extends SceneTree
# 870.9 (Umzug BRS Schritt 8): die Kartenregeln der alten Kotlin-Tests, seit die Karten Godot-Quelle sind (daten/karten.json, von Hand
# bearbeitet, tools/karten/karten.py): WorldTest (Dinge passen zu den Kacheln, kein Fels am Feuer, Ausgänge landen frei, Begegnungen
# gültig), VillageTest (jede Tür und jeder Mensch des Dorfs erreichbar, Grundrisse führen vor ihre Tür), VillageRoundTest (609: hinter
# jedem Haus der Nordreihe kommt man vorbei), RoomPlanTest (von der Tür aus jeder zum Reden und der Weg hinaus), MapExportTest
# (Wege aus dem Dorf, Ring vor dem Fluss, Tagesablauf). Ohne Bild, Exit 0 oder 1. Braucht daten/werte.json (godot.yml „Karten und Texte“).
# Aufruf im Ordner godot: godot --headless --path . -s res://tests/karten_regeln.gd

const VIER := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const RAEUME := ["inn", "elder", "shop", "temple"]

var fehler := 0
var alle: Dictionary

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		print("FALSCH " + was)
		fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func xy(o) -> Vector2i: return Vector2i(int(o["x"]), int(o["y"]))

func kachel(k: Karte, t: Vector2i) -> String:
	return String(k.kacheln[k.zeichen(t)]["name"])

func leute(k: Karte) -> Dictionary:
	var l := {}
	for n in k.daten["leute"]: l[xy(n)] = String(n["id"])
	return l

# wie MapDef.walkable: begehbar und niemand steht dort (Karte.begehbar kennt keine Leute)
func frei(k: Karte, t: Vector2i, l: Dictionary) -> bool:
	return k.begehbar(t) and not l.has(t)

# alle Kacheln, die man von a aus erreicht, ohne über bis_zeile hinaus nach Süden zu gehen
func reichweite(k: Karte, a: Vector2i, l: Dictionary, bis_zeile := 1 << 20) -> Dictionary:
	var seen := {a: true}
	var q: Array[Vector2i] = [a]
	while not q.is_empty():
		var p: Vector2i = q.pop_front()
		for d in VIER:
			var n: Vector2i = p + d
			if n.y > bis_zeile or seen.has(n) or not frei(k, n, l): continue
			seen[n] = true
			q.append(n)
	return seen

# eine Tür (in Godot Teil der Wand, man steht davor) ist erreicht, wenn eine Nachbarkachel erreicht ist
func vor(t: Vector2i, erreicht: Dictionary) -> bool:
	for d in VIER:
		if erreicht.has(t + d): return true
	return false

func _lauf() -> void:
	alle = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))
	var karten: Dictionary = alle["karten"]
	var werte = JSON.parse_string(FileAccess.get_file_as_string("res://daten/werte.json")) if FileAccess.file_exists("res://daten/werte.json") else null
	pruefe(werte != null, "daten/werte.json fehlt (godot.yml „Karten und Texte“)")
	var kisten := {}
	for id in karten:
		var k := Karte.lade(id)
		var l := leute(k)
		# WorldTest.mapObjectsMatchTiles
		pruefe(k.zeilen.size() == k.hoehe, "%s: %d Zeilen statt %d" % [id, k.zeilen.size(), k.hoehe])
		for y in k.zeilen.size():
			pruefe(k.zeilen[y].length() == k.breite, "%s Zeile %d: %d Zeichen statt %d" % [id, y, k.zeilen[y].length(), k.breite])
			for c in k.zeilen[y]: pruefe(k.kacheln.has(c), "%s Zeile %d: Zeichen „%s“ unbekannt" % [id, y, c])
		var kiste_an := {}
		for c in k.daten["kisten"]:
			kiste_an[xy(c)] = true
			pruefe(kachel(k, xy(c)) == "CHEST", "%s: Kiste %s auf %s" % [id, c["id"], kachel(k, xy(c))])
			pruefe(not kisten.has(c["id"]), "Kiste %s doppelt" % c["id"])
			kisten[c["id"]] = true
		var schild_an := {}
		for s in k.daten["schilder"]:
			schild_an[xy(s)] = true
			pruefe(kachel(k, xy(s)) == "SIGN", "%s: Schild %s auf %s" % [id, xy(s), kachel(k, xy(s))])
		for y in k.hoehe:
			for x in k.breite:
				var t := Vector2i(x, y)
				match kachel(k, t):
					"CHEST": pruefe(kiste_an.has(t), "%s: Kistenkachel ohne Kiste bei %s" % [id, t])
					"SIGN": pruefe(schild_an.has(t), "%s: Schildkachel ohne Text bei %s" % [id, t])
					"DOOR", "CAVE_ENTRANCE", "CAVE_EXIT": pruefe(k.ausgaenge.has(t), "%s: Ausgang ohne Ziel bei %s" % [id, t])
					# WorldTest.noRockByACampfire (170): kein Fels am Feuer
					"CAMPFIRE":
						for dy in range(-2, 3):
							for dx in range(-2, 3):
								var n := t + Vector2i(dx, dy)
								if n.x >= 0 and n.y >= 0 and n.x < k.breite and n.y < k.hoehe:
									pruefe(kachel(k, n) != "ROCK", "%s: Fels bei %s am Feuer %s" % [id, n, t])
		for n in k.daten["leute"]:
			var t := xy(n)
			pruefe(t.x >= 0 and t.y >= 0 and t.x < k.breite and t.y < k.hoehe, "%s: %s außerhalb" % [id, n["id"]])
			pruefe(bool(k.kacheln[k.zeichen(t)]["begehbar"]), "%s: %s auf %s" % [id, n["id"], kachel(k, t)])
		# WorldTest.warpsLeadToWalkableTiles
		for a in k.daten["ausgaenge"]:
			var z: Dictionary = a["ziel"]
			pruefe(karten.has(z["karte"]), "%s %s: Ziel %s unbekannt" % [id, xy(a), z["karte"]])
			if not karten.has(z["karte"]): continue
			var ziel := Karte.lade(String(z["karte"]))
			var zt := xy(z)
			pruefe(bool(ziel.kacheln[ziel.zeichen(zt)]["begehbar"]), "%s %s: landet in %s %s auf %s" % [id, xy(a), z["karte"], zt, kachel(ziel, zt)])
			pruefe(not ziel.ausgaenge.has(zt), "%s %s: landet in %s %s auf einem Ausgang" % [id, xy(a), z["karte"], zt])
			pruefe(String(z["blick"]) in ["UP", "DOWN", "LEFT", "RIGHT"], "%s %s: Blick %s" % [id, xy(a), z["blick"]])
		# WorldTest.encounterTablesAreValid
		var e: Dictionary = k.daten.get("begegnungen", {})
		for liste in [e.get("tabelle", []), e.get("nacht", [])]:
			for zeile in liste:
				pruefe(float(zeile[1]) > 0, "%s: Gewicht %s für %s" % [id, zeile[1], zeile[0]])
				if werte: pruefe(werte["kennungen"].has(zeile[0]), "%s: Begegnung %s ohne Kennung in werte.json" % [id, zeile[0]])
		# MapExport: Bewuchs auf Bäumen, Ring außerhalb der Karte (die Rechnung prüft tools/karten/karten.py pruefen)
		for b in k.daten["bewuchs"]:
			pruefe(kachel(k, Vector2i(int(b[0]), int(b[1]))) == "TREE" and String(b[2]) in ["busch", "jung", "jung2"], "%s: Bewuchs %s" % [id, b])
		for r in k.daten.get("ring", []):
			var t := Vector2i(int(r[0]), int(r[1]))
			pruefe(not (t.x >= 0 and t.y >= 0 and t.x < k.breite and t.y < k.hoehe), "%s: Ring %s in der Karte" % [id, r])
		fassaden(k)
	var start := Vector2i(int(Rast.START["x"]), int(Rast.START["y"]))
	var sk := Karte.lade(String(Rast.START["karte"]))
	pruefe(frei(sk, start, leute(sk)), "Startplatz %s %s nicht frei" % [Rast.START["karte"], start])
	var tempel := Karte.lade("temple")
	pruefe(frei(tempel, Vector2i(4, 4), leute(tempel)), "Wiederkehrort im Tempel (4, 4) nicht frei")
	dorf()
	nordreihe()
	raeume()
	wege_aus_dem_dorf()
	print("KARTENREGELN %d Karten, %d Fehler" % [karten.size(), fehler])
	quit(1 if fehler else 0)

# Fassaden (MapTownIso.houses, facades): von Hand gepflegt, seit die Karten Quelle sind. Je Haus (Lauf aus Wand, Fenster, Tür mit
# Dach darüber) genau ein Eintrag, Breite und Tiefe passen, vorn ein Zeichen je Kachel (# W D) mit Tür, seitlich 2 oder 3
func fassaden(k: Karte) -> void:
	if not k.daten.has("fassaden"): return
	var wand := ["WALL", "WINDOW", "DOOR"]
	var dach := ["ROOF", "ROOF_BLUE"]
	var haeuser := {}
	for y in k.hoehe:
		var x := 0
		while x < k.breite:
			if not kachel(k, Vector2i(x, y)) in wand or (x > 0 and kachel(k, Vector2i(x - 1, y)) in wand):
				x += 1; continue
			var n := 0
			while x + n < k.breite and kachel(k, Vector2i(x + n, y)) in wand: n += 1
			var reihen := 0
			while reihen < 3 and range(n).all(func(i): return kachel(k, Vector2i(x + i, y - reihen - 1)) in dach): reihen += 1
			haeuser[Vector2i(x, y)] = Vector2i(n, reihen + 1)
			x += n
	var gesehen := {}
	for f in k.daten["fassaden"]:
		var t := xy(f)
		var vorn := String(f["vorn"])
		gesehen[t] = true
		pruefe(haeuser.has(t), "%s: Fassade %s ohne Haus" % [k.id, t])
		if haeuser.has(t): pruefe(haeuser[t] == Vector2i(int(f["n"]), int(f["d"])), "%s: Fassade %s %dx%d, Haus %s" % [k.id, t, int(f["n"]), int(f["d"]), haeuser[t]])
		pruefe(vorn.length() == int(f["n"]) and "D" in vorn and vorn.replace("#", "").replace("W", "").replace("D", "") == "", "%s: Fassade %s vorn „%s“" % [k.id, t, vorn])
		pruefe(String(f["seite"]).length() in [2, 3], "%s: Fassade %s seitlich „%s“" % [k.id, t, f["seite"]])
	for t in haeuser: pruefe(gesehen.has(t), "%s: Haus %s ohne Fassade" % [k.id, t])

# VillageTest.everyDoorAndPersonCanBeReached: vom Dorfplatz (Spiel.START_KACHEL) jede offene Tür, jeder Mensch auf freiem Grund,
# und jeder Grundriss führt vor seine Tür auf freien Grund
func dorf() -> void:
	var k := Karte.lade("village")
	var l := leute(k)
	var erreicht := reichweite(k, Vector2i(19, 13), l)
	for a in k.daten["ausgaenge"]:
		if int(a["y"]) > 0 and not bool(a["verschlossen"]):
			pruefe(vor(xy(a), erreicht), "Dorf: Tür %s nach %s nicht erreichbar" % [xy(a), a["ziel"]["karte"]])
	for n in k.daten["leute"]:
		pruefe(bool(k.kacheln[k.zeichen(xy(n))]["begehbar"]), "Dorf: %s steht nicht auf freiem Grund" % n["id"])
		pruefe(vor(xy(n), erreicht), "Dorf: %s nicht erreichbar" % n["id"])
	for id in RAEUME:
		var r := Karte.lade(id)
		pruefe(r.daten["ausgaenge"].size() == 1, "%s: %d Ausgänge statt 1" % [id, r.daten["ausgaenge"].size()])
		var zurueck := xy(r.daten["ausgaenge"][0]["ziel"])
		pruefe(frei(k, zurueck, l), "%s: hinaus auf %s, nicht frei" % [id, zurueck])
	# 73b: verschlossene Häuser bleiben zu, mindestens fünf (MapExportTest.villageWaysOut)
	var zu := 0
	for a in k.daten["ausgaenge"]:
		if bool(a["verschlossen"]): zu += 1
	pruefe(zu >= 5, "Dorf: nur %d verschlossene Türen" % zu)

# VillageRoundTest (609, Chef 07.11.): hinter jedem Haus der Nordreihe von West nach Ost, ohne südlich der Dächer zu gehen; Leute
# zählen nicht (Jorin steht nur zeitweise hinter dem Haus, Tagesablauf; alt nicht da, solange er nicht im Dorf ist)
func nordreihe() -> void:
	var k := Karte.lade("village")
	var l := {}
	var top := 1 << 20
	for y in 8:
		for x in k.breite:
			if kachel(k, Vector2i(x, y)) == "ROOF": top = mini(top, y)
	var haeuser: Array = []
	for x in k.breite:
		var dach := kachel(k, Vector2i(x, top)) == "ROOF" or kachel(k, Vector2i(x, top + 1)) == "ROOF"
		if dach and (haeuser.is_empty() or haeuser[-1][1] != x - 1): haeuser.append([x, x])
		elif dach: haeuser[-1][1] = x
	pruefe(haeuser.size() >= 4, "Nordreihe: nur %d Häuser %s" % [haeuser.size(), haeuser])
	for h in haeuser:
		var y0 := top
		while y0 >= 1:
			var frei_zeile := true
			for x in range(h[0], h[1] + 1):
				if kachel(k, Vector2i(x, y0)) == "ROOF": frei_zeile = false
			if frei_zeile: break
			y0 -= 1
		var von := Vector2i(-1, -1)
		for x in range(h[0] - 1, -1, -1):
			if frei(k, Vector2i(x, y0), l): von = Vector2i(x, y0); break
		var nach := Vector2i(-1, -1)
		for x in range(h[1] + 1, k.breite):
			if frei(k, Vector2i(x, y0), l): nach = Vector2i(x, y0); break
		if von.x < 0 or nach.x < 0:
			pruefe(false, "Nordreihe: Haus %s ohne freies Feld neben dem Dach in Zeile %d" % [h, y0]); continue
		pruefe(reichweite(k, von, l, y0).has(nach), "Nordreihe: Haus %s, von %s nicht nach %s hinter dem Dach" % [h, von, nach])

# RoomPlanTest: von der Tür aus erreicht man den Weg hinaus (in der Vorderwand) und kann jeden ansprechen, auch über die Theke
func raeume() -> void:
	var dorf_k := Karte.lade("village")
	for id in RAEUME:
		var k := Karte.lade(id)
		var l := leute(k)
		var hinein := Vector2i(-1, -1)
		for a in dorf_k.daten["ausgaenge"]:
			if String(a["ziel"]["karte"]) == id: hinein = xy(a["ziel"])
		pruefe(frei(k, hinein, l), "%s: der Held kommt auf %s herein, nicht frei" % [id, hinein])
		var erreicht := reichweite(k, hinein, l)
		var tuer := xy(k.daten["ausgaenge"][0])
		pruefe(vor(tuer, erreicht), "%s: die Tür %s nicht erreichbar" % [id, tuer])
		pruefe(tuer.y == k.hoehe - 1, "%s: die Tür %s liegt nicht in der Vorderwand" % [id, tuer])
		for n in k.daten["leute"]:
			var p := xy(n)
			var ok := vor(p, erreicht)
			for d in VIER:   # über die Theke: zwei Kacheln weit, die mittlere ist Theke
				if kachel(k, p + d) == "COUNTER" and erreicht.has(p + 2 * d): ok = true
			pruefe(ok, "%s: niemand kann %s bei %s ansprechen" % [id, n["id"], p])

# MapExportTest.villageWaysOut, villageRingKeepsRiverOpen, villageDayForGodot
func wege_aus_dem_dorf() -> void:
	var v: Dictionary = alle["karten"]["village"]
	var schenke := false
	var norden := false
	for a in v["ausgaenge"]:
		if xy(a) == Vector2i(6, 5): schenke = String(a["ziel"]["karte"]) == "inn" and not bool(a["verschlossen"])
		if int(a["y"]) == 0 and not norden:
			norden = true
			pruefe(String(a["ziel"]["karte"]) == "forest" and not a.get("abgewiesen", []).is_empty(), "Dorf: der Weg nach Norden führt nicht in den Wald oder weist nicht ab")
	pruefe(schenke, "Dorf: die Tür der Schenke (6, 5) führt nicht offen in die Schenke")
	pruefe(norden, "Dorf: kein Weg nach Norden")
	var ring_busch := false
	for r in v["ring"]:
		pruefe(not (int(r[0]) >= 36 and int(r[0]) <= 39 and int(r[1]) >= 25 and int(r[1]) <= 27), "Dorf: Ring %s vor dem Fluss am Ostrand" % [r])
		if String(r[2]) == "busch": ring_busch = true
	pruefe(ring_busch and not v["bewuchs"].is_empty(), "Dorf: kein niedriger Bewuchs vor den Feldern")
	var pim: Array = alle["tagesablauf"].get("pim", [])
	pruefe(not pim.is_empty() and int(pim[-1][0]) == 21 * 60 and bool(pim[-1][4]), "Tagesablauf: Pim ist um 21 Uhr nicht drinnen")
	for wer in alle["tagesablauf"]:
		var vorher := -1
		for st in alle["tagesablauf"][wer]:
			pruefe(int(st[0]) > vorher, "Tagesablauf %s: Zeiten nicht aufsteigend bei %s" % [wer, st])
			vorher = int(st[0])
			if not bool(st[4]):
				var k := Karte.lade("village")
				pruefe(bool(k.kacheln[k.zeichen(Vector2i(int(st[1]), int(st[2])))]["begehbar"]), "Tagesablauf %s: um %d auf %s" % [wer, int(st[0]), kachel(k, Vector2i(int(st[1]), int(st[2])))])
