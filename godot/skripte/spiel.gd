extends Node3D
# 348.6: Chroniken von Bornim in Godot, Fundament: Gebietskarte aus core (karten.json) und Blender, Held, Steuerung,
# Kamera, Licht, Tusche; Ausgaenge wie im alten Spiel: Tuer mit dem Aktionsknopf (215), gesperrte Wege mit ihrem Text.
# Grundrisse folgen nach der Bestandsliste (348.8); bis dahin zeigt eine Tuer den Namen des Grundrisses und fuehrt zurueck.
# Am Rechner: godot --path godot -- --bilder=<ordner> legt Standbilder ab (Vergleich alt/neu) und beendet sich.

const START := "village"
const START_KACHEL := Vector2i(19, 13)          # Dorfplatz am Brunnen (Probe Build 11)

var karte: Karte
var gebiet: Gebiet
var held: Held
var kamera: Kamera
var licht: Licht
var ui: Steuerung
var blende: ColorRect
var gedacht := {}                                # Rand (67): erster Gedanke lang, danach kurz
var zeiten: Array = []
var ziel_stoss := Vector2i(-1, -1)               # angetippter gesperrter Ausgang: beim Ankommen Text zeigen

func _ready() -> void:
	licht = Licht.new()
	add_child(licht)
	kamera = Kamera.new()
	add_child(kamera)
	ui = Steuerung.new()
	add_child(ui)
	blende = ColorRect.new()
	blende.color = Color(0, 0, 0, 0)
	blende.set_anchors_preset(Control.PRESET_FULL_RECT)
	blende.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(blende)
	ui.tippen.connect(_tippen)
	ui.joystick.connect(func(v): if held: held.richtung = kamera.richtung(v))
	ui.kneifen.connect(func(f, w): kamera.kneifen(f); kamera.drehe(w))
	ui.laufen.connect(func(an): if held: held.laeuft = an)
	ui.aktion.connect(_aktion)
	ui.knopf.connect(_knopf)
	licht.nacht_geaendert.connect(_nacht)
	betrete(START, START_KACHEL, "DOWN")
	bilder()

func betrete(id: String, t: Vector2i, blick: String) -> void:
	if gebiet: gebiet.queue_free()
	if held: held.queue_free()
	karte = Karte.lade(id)
	gebiet = Gebiet.new(karte)
	add_child(gebiet)
	held = Held.new(karte)
	add_child(held)
	held.setze(t, blick)
	held.steht_auf.connect(_steht_auf)
	held.stoesst.connect(_stoesst)
	kamera.ziel = held
	kamera.springe()
	ui.ort.text = karte.name_de()
	_nacht(licht.nacht)
	_steht_auf(t)

func _nacht(k: float) -> void:
	if gebiet: gebiet.nacht(k)
	if held: held.nacht(k)

func _knopf(was: String) -> void:
	match was:
		"nacht": licht.umschalten()
		"nah": kamera.nah_fern()
		"links": kamera.drehe(-45.0)
		"rechts": kamera.drehe(45.0)

# ---------------------------------------------------------------- Tippen, Ausgaenge, Schilder
func _tippen(sp: Vector2) -> void:
	var p = kamera.boden(sp)
	if p == null or held == null: return
	var b := karte.pos_kachel(p)
	ziel_stoss = Vector2i(-1, -1)
	var ziel := b
	if not karte.sperrt(b).is_empty() or zeichen_lesbar(b) or (karte.zeichen(b) == "z" and not karte.begehbar(b)):
		ziel = naechster_nachbar(b)                  # gesperrter Ausgang oder Schild: davor stellen
		if ziel.x < 0: return
		ziel_stoss = b
	held.geh_zu(karte.kachel_pos(ziel) if ziel != b else p)

func naechster_nachbar(b: Vector2i) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_n := 1 << 30
	for d in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
		var n: Vector2i = b + d
		if not karte.begehbar(n): continue
		var w := karte.weg(held.kachel, n)
		if w.is_empty() and n != held.kachel: continue
		if w.size() < best_n: best_n = w.size(); best = n
	return best

func zeichen_lesbar(t: Vector2i) -> bool:
	return karte.zeichen(t) == "S" and schild(t) != ""

func schild(t: Vector2i) -> String:
	for s in karte.daten["schilder"]:
		if int(s["x"]) == t.x and int(s["y"]) == t.y: return String(s["text"]["de"])
	return ""

func _steht_auf(t: Vector2i) -> void:
	ui.biete_an(angebot(t))

func angebot(t: Vector2i) -> String:
	var a := karte.ausgang(t)
	if not a.is_empty():
		if bool(a["verschlossen"]): return "Klopfen" if a.has("klopfen") else ""
		return "Eintreten" if karte.zeichen(t) in ["D", "E"] else "Weiter"
	for d in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
		if zeichen_lesbar(t + d): return "Lesen"
	return ""

func _aktion() -> void:
	var t := held.kachel
	var a := karte.ausgang(t)
	if a.is_empty():
		for d in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
			if zeichen_lesbar(t + d):
				ui.sage([{"text": schild(t + d)}])
				return
		return
	if bool(a["verschlossen"]):
		var nachts := licht.nacht > 0.5
		if a.has("klopfen"): ui.sage(zeilen(a["klopfen"]["nacht" if nachts else "tag"]))
		return
	if a.has("braucht") and not karte.flaggen.has(a["braucht"]):
		ui.sage(zeilen(a.get("abgewiesen", [])))
		return
	geh_hinaus(a)

func _stoesst(t: Vector2i) -> void:
	if karte.zeichen(t) == "z" and not karte.flaggen.has("barrier_open"):
		ui.sage([{"text": karte.schlagbaum}])
		return
	var a := karte.sperrt(t)
	if a.is_empty(): return
	if bool(a["umkehren"]):
		var k := "gedanke_kurz" if gedacht.has(karte.id) else "gedanke"
		gedacht[karte.id] = true
		if a.has(k): ui.sage([{"text": String(a[k]["de"])}])
	else:
		ui.sage(zeilen(a.get("abgewiesen", [])))

func zeilen(liste: Array) -> Array:
	var r: Array = []
	for z in liste:
		var e := {"text": String(z["text"]["de"])}
		if z.has("wer"): e["wer"] = String(z["wer"]["de"])
		r.append(e)
	return r

# Ziel gebaut: hinein; sonst Name des Grundrisses zeigen und vor der Tuer wieder herauskommen
func geh_hinaus(a: Dictionary) -> void:
	var z: Dictionary = a["ziel"]
	var id := String(z["karte"])
	ui.biete_an("")
	await abblenden(1.0)
	if FileAccess.file_exists("res://daten/" + Gebiet.datei(id) + ".bin") and id != karte.id:
		betrete(id, Vector2i(int(z["x"]), int(z["y"])), String(z["blick"]))
		await abblenden(0.0)
		return
	var alle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))
	var name := String(alle["karten"][id]["name"]["de"]) if alle["karten"].has(id) else id
	var zurueck := Vector2i(int(a["x"]), int(a["y"]) + 1)
	for r in alle["karten"].get(id, {}).get("ausgaenge", []):
		if String(r["ziel"]["karte"]) == karte.id: zurueck = Vector2i(int(r["ziel"]["x"]), int(r["ziel"]["y"]))
	held.setze(zurueck, "DOWN")
	kamera.springe()
	await abblenden(0.0)
	ui.sage([{"text": "%s: Grundriss folgt im Umzug (348)." % name}])

func abblenden(ziel: float) -> void:
	var tw := create_tween()
	tw.tween_property(blende, "color:a", ziel, 0.35)
	await tw.finished

# ---------------------------------------------------------------- Lauf
func _process(dt: float) -> void:
	if held == null: return
	if ziel_stoss.x >= 0 and not held.geht():
		var s := ziel_stoss
		ziel_stoss = Vector2i(-1, -1)
		if (s - held.kachel).length_squared() == 1:
			held.rotation.y = atan2(float(s.x - held.kachel.x), float(s.y - held.kachel.y))
			if zeichen_lesbar(s): ui.sage([{"text": schild(s)}])
			elif karte.zeichen(s) == "z": _stoesst(s)
			else: _stoesst(s)
	kamera.folge(minf(1.0, dt * 5.0))
	gebiet.nah(kamera.nah, held.position)
	zeiten.append(dt)
	if zeiten.size() > 240: zeiten.pop_front()
	ui.messe(zeiten)

# ---------------------------------------------------------------- Standbilder am Rechner (Vergleich alt/neu)
func bilder() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--bilder="): dir = a.substr(9)
	if dir == "": return
	ui.mess.visible = false
	await get_tree().create_timer(1.0).timeout
	await knips(dir + "/tag.png")
	held.geh_zu(held.position + Vector3(3.0, 0, -2.0))
	await get_tree().create_timer(0.8).timeout
	await knips(dir + "/gehen.png")
	licht.umschalten()
	await get_tree().create_timer(2.5).timeout
	await knips(dir + "/nacht.png")
	licht.umschalten()
	held.setze(Vector2i(6, 6), "UP")                # vor dem Gasthaus: Aktionsknopf an der Tuer
	held.geh_zu(karte.kachel_pos(Vector2i(6, 5)))
	await get_tree().create_timer(2.5).timeout
	await knips(dir + "/tuer.png")
	held.setze(Vector2i(17, 3), "UP")               # Schlagbaum: unten, Text aus Game.barrier
	held.richtung = Vector3(0, 0, -1)
	await get_tree().create_timer(1.0).timeout
	held.richtung = Vector3.ZERO
	await knips(dir + "/schlagbaum.png")
	get_tree().quit()

func knips(p: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(p)
	print("BILD ", p)
