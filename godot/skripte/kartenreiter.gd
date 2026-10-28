class_name Kartenreiter
extends VBoxContainer
# 399.1 Reiter Karte wie alt (MenuScreen.kt MapTab, 62): die gezeichnete Karte des Ortes, auf dem Held (roter Ring mit Keil in
# Blickrichtung) vergroessert geoeffnet (62c); zwei Finger zoomen, einer schiebt; ein bekanntes Haus oder sein Schild oeffnet
# seinen Grundriss, der Knopf oben rechts geht eine Stufe hoeher (62r: Grundriss, Gebietskarte, Landkarte); auf der Landkarte
# oeffnet ein bekannter Ort seine Karte (keine Reise). Zeichen erinnern, fuehren nie (MapMarks): Antippen nennt sie; drei
# Schalter Auftraege, Leute, Dienste (62f). Schilder ueber den Tueren bekannter Haeuser (62n, MapLook.labels 2).
# Die Blaetter zeichnet core im Bau (MapSheetExport.kt, daten/kartenblatt.json, karte-<id>.bild, land-<wald><tiefer>.bild).
# Noch nicht wie alt: Wald und Hoehle als Blatt mit Nebel (62c) samt Lagerfeuern, solange der Held sie in Godot nicht begeht;
# Ziele der Nebenauftraege in Hoehle und Wald (MapMarks.goal); Gewohnheiten der Leute (MapPeople.seenAt).

const DP := AktionsKnopf.DP
const TINTE := Color("4a3622")
const PAPIER := Color("efe4c8")
const PERGAMENT := Color("e6d3a8")
const ROT := Color("b0302a")
const BLAU := Color("4f86c6")

static var _blatt := {}
static var _bretter := {}                # Karte -> [Vector2i] der Anschlagbretter (Tile.NOTICE „!“)
static var _bilder := {}
static var _hand: FontFile

var z: Zustand
var ort: Dictionary                # spiel.gd platz(): karte, x, y, blick
var zur_chronik: Callable
var gezeigt := ""
var uebersicht := false
var schalter := {"QUESTS": true, "PEOPLE": true, "SERVICES": true}
var flaeche: Control
var tipp_kasten: PanelContainer

static func blatt() -> Dictionary:
	if _blatt.is_empty():
		var t := FileAccess.get_file_as_string("res://daten/kartenblatt.json")
		if t != "": _blatt = JSON.parse_string(t)
	return _blatt

static func bild(name: String) -> Texture2D:
	if not _bilder.has(name):
		var img := Image.new()
		var roh := FileAccess.get_file_as_bytes("res://daten/%s.bild" % name)
		_bilder[name] = ImageTexture.create_from_image(img) if not roh.is_empty() and img.load_png_from_buffer(roh) == OK else null
	return _bilder[name]

# 62g: Handschrift der Ortsnamen auf der Landkarte (Fondamento, OFL; im Bau aus app/src/main/res/font kopiert)
static func hand() -> Font:
	if _hand == null:
		var roh := FileAccess.get_file_as_bytes("res://daten/fondamento.ttf")
		if roh.is_empty(): return Stil.schrift()
		_hand = FontFile.new()
		_hand.data = roh
	return _hand

static func wort(k: String) -> String: return Sprache.t(blatt().get("worte", {}).get(k, k))

func _init(z_: Zustand, ort_: Dictionary, hoehe: float, chronik: Callable) -> void:
	z = z_; ort = ort_; zur_chronik = chronik
	custom_minimum_size = Vector2(0, maxf(hoehe, 300 * DP))
	add_theme_constant_override("separation", int(6 * DP))
	var k: Dictionary = blatt().get("karten", {})
	gezeigt = String(ort.get("karte", "village"))
	if not k.has(gezeigt): uebersicht = true

func _ready() -> void: baue()

func karte_daten() -> Dictionary: return blatt().get("karten", {}).get(gezeigt, {})

func baue() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	tipp_kasten = null
	var kopf := HBoxContainer.new()
	kopf.add_theme_constant_override("separation", int(6 * DP))
	add_child(kopf)
	var titel := Stil.zeile(wort("landkarte") if uebersicht else Sprache.t(karte_daten().get("name", gezeigt)), 20, Stil.TEXT)
	titel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titel.clip_text = true
	kopf.add_child(titel)
	if not uebersicht:   # 62r: eine Stufe hoeher, der Knopf nennt wohin; auf der Landkarte keiner
		var oben := String(karte_daten().get("oben", ""))
		var b := Erschaffung.knopf(wort("gebietskarte_hoch" if oben != "" else "landkarte_hoch"), func():
			if oben != "": gezeigt = oben
			else: uebersicht = true
			baue())
		b.size_flags_horizontal = Control.SIZE_SHRINK_END
		b.custom_minimum_size = Vector2(0, 36 * DP)
		kopf.add_child(b)
		var reihe := HBoxContainer.new()
		reihe.add_theme_constant_override("separation", int(6 * DP))
		add_child(reihe)
		for g in [["QUESTS", "auftraege"], ["PEOPLE", "leute"], ["SERVICES", "dienste"]]:
			var gruppe: String = g[0]
			var s := Erschaffung.knopf(wort(g[1]), func(): schalter[gruppe] = not schalter[gruppe]; baue(), schalter[gruppe])
			s.custom_minimum_size = Vector2(0, 34 * DP)
			reihe.add_child(s)
	var rahmen := Control.new()
	rahmen.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rahmen.clip_contents = true
	add_child(rahmen)
	flaeche = Landblatt.new(self) if uebersicht else Kartenblatt.new(self)
	flaeche.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rahmen.add_child(flaeche)

# Kasten unten mit dem Namen eines Zeichens oder Hauses (alt Panel unten mittig); bei Auftraegen „In der Chronik“ (64)
func tipp(text: String, chronik := false) -> void:
	if tipp_kasten: tipp_kasten.queue_free(); tipp_kasten = null
	if text == "": return
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", int(6 * DP))
	spalte.add_child(Erschaffung.txt(text, 15, Stil.BRIGHT))
	if chronik:
		var b := Erschaffung.knopf(wort("chronik"), zur_chronik)
		b.custom_minimum_size = Vector2(0, 32 * DP)
		b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		spalte.add_child(b)
	tipp_kasten = Erschaffung.kasten(spalte)
	tipp_kasten.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	tipp_kasten.grow_vertical = Control.GROW_DIRECTION_BEGIN
	tipp_kasten.offset_left = 8 * DP; tipp_kasten.offset_right = -8 * DP; tipp_kasten.offset_bottom = -8 * DP
	flaeche.get_parent().add_child(tipp_kasten)

# ---------------------------------------------------------------- was die Karte weiss (MapMarks.of, MapPeople)

# 62g/62s: Haeuser mit Namen, sobald der Held drinnen war oder einen Bewohner kennt; Wohnhaeuser, sobald er anklopfte
func haeuser() -> Array:
	var out := []
	for h in blatt().get("haeuser", []):
		if String(h["karte"]) != gezeigt: continue
		var innen := String(h["innen"])
		var kennt := false
		if innen != "": kennt = z.has("besucht:" + innen) or (h["bewohner"] as Array).any(func(b): return z.has("met_" + String(b)))
		else: kennt = z.has("heard_%d_%d" % [int(h["x"]), int(h["y"])])
		if kennt: out.append(h)
	return out

func zeichen() -> Array:
	var de := Sprache.aktiv() == "de"
	var alle := []
	var leute := {}   # wer -> Zeile „Name – was“ (62f: sie tritt unter den Auftrag dessen, der einen gibt)
	for f in blatt().get("leute", []):
		var id := String(f["id"])
		if not z.has("met_" + id): continue
		var zeile := {"de": "%s – %s" % [f["name"]["de"], f["was"]["de"]], "en": "%s – %s" % [f["name"]["en"], f["was"]["en"]]}
		leute[id] = zeile
		alle.append({"karte": f["karte"], "x": f["x"], "y": f["y"], "art": "PERSON", "text": zeile, "wer": id})
		if f.has("innen"): alle.append({"karte": f["innen"], "x": f["innen_x"], "y": f["innen_y"], "art": "PERSON", "text": zeile, "wer": id})
	# 62e: der Hauptauftrag beim Aeltesten, sobald er ihn gab; verblasst, wenn das Kapitel geschafft ist
	if z.has(Geschichte.QUEST_STARTED):
		var ziel := Geschichte.ziel(z)
		var t := {"de": "%s: %s" % [blatt()["worte"]["aeltester"]["de"], ziel["de"]], "en": "%s: %s" % [blatt()["worte"]["aeltester"]["en"], ziel["en"]]}
		if leute.has("aldric"):
			for l in ["de", "en"]: t[l] += "\n– " + String(leute["aldric"][l]).get_slice(" – ", 1)
		for a in blatt().get("aeltester", []):
			alle.append({"karte": a["karte"], "x": a["x"], "y": a["y"], "art": "GIVER", "text": t, "wer": "aldric", "fertig": z.has(Geschichte.CHAPTER1_DONE)})
	# 62e: das Anschlagbrett, sobald gelesen; ein neuer Aushang sagt es (399.1, auftraege.gd)
	if Auftraege.alle().any(func(j): return z.has("job_%s_seen" % j["id"])):
		var neu := Auftraege.frisch(z)
		for b in bretter(gezeigt):
			alle.append({"karte": gezeigt, "x": b.x, "y": b.y, "art": "BOARD",
				"text": {"de": "Anschlagbrett: ein neuer Aushang", "en": "Notice board: a new note"} if neu else {"de": "Anschlagbrett", "en": "Notice board"}})
	# angenommene und erledigte Aushaenge beim Auftraggeber, den der Held kennt (verblasst, wenn erledigt)
	for j in Auftraege.alle():
		var fertig := Auftraege.erledigt(z, j)
		if not (fertig or Auftraege.angenommen(z, j)) or not z.has("met_" + String(j["geber"])): continue
		var t := {"de": "%s: %s" % [j["geber_name"]["de"], j["titel"]["de"]], "en": "%s: %s" % [j["geber_name"]["en"], j["titel"]["en"]]}
		if leute.has(String(j["geber"])):
			for l in ["de", "en"]: t[l] += "\n– " + String(leute[String(j["geber"])][l]).get_slice(" – ", 1)
		for f in blatt().get("leute", []):
			if String(f["id"]) != String(j["geber"]): continue
			alle.append({"karte": f["karte"], "x": f["x"], "y": f["y"], "art": "GIVER", "text": t, "wer": f["id"], "fertig": fertig})
			if f.has("innen"): alle.append({"karte": f["innen"], "x": f["innen_x"], "y": f["innen_y"], "art": "GIVER", "text": t, "wer": f["id"], "fertig": fertig})
	# Schaenke, Laden, Tempel an ihren Tueren: Raeume gelten als bekannt (MapMarks.visited: INTERIOR immer)
	for d in blatt().get("dienste", []):
		alle.append({"karte": d["karte"], "x": d["x"], "y": d["y"], "art": d["art"], "text": d["name"]})
	var gruppe := {"GIVER": "QUESTS", "GOAL": "QUESTS", "BOARD": "SERVICES", "PERSON": "PEOPLE", "INN": "SERVICES", "SHOP": "SERVICES", "TEMPLE": "SERVICES", "FIRE": "SERVICES"}
	var geber := {}
	for m in alle: if m["art"] == "GIVER" and schalter["QUESTS"]: geber[m["wer"]] = true
	# mehrere an einer Stelle werden ein Zeichen (MapPeople.marks, MapMarks.of atDoors)
	var stellen := {}
	var out := []
	for m in alle:
		if String(m["karte"]) != gezeigt or not schalter[gruppe[m["art"]]]: continue
		if m["art"] == "PERSON" and geber.has(m.get("wer", "")): continue
		var k := Vector2i(int(m["x"]), int(m["y"]))
		if stellen.has(k) and stellen[k]["art"] == m["art"]:
			for l in ["de", "en"]: stellen[k]["text"][l] += "\n" + String(m["text"][l])
			continue
		var n: Dictionary = m.duplicate(true)
		stellen[k] = n
		out.append(n)
	return out

static func bretter(id: String) -> Array:
	if not _bretter.has(id):
		var out := []
		var j = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json")) if FileAccess.file_exists("res://daten/karten.json") else null
		if j is Dictionary and j["karten"].has(id):
			var zl: Array = j["karten"][id]["zeilen"]
			for y in zl.size():
				for x in String(zl[y]).length(): if String(zl[y])[x] == "!": out.append(Vector2i(x, y))
		_bretter[id] = out
	return _bretter[id]

# ---------------------------------------------------------------- Zeichnen wie MenuScreen.kt (drawService, drawHouseSign)

static func zeichne_dienst(c: CanvasItem, art: String, p: Vector2, r: float) -> void:
	var dp := DP
	c.draw_circle(p, r * 1.25, PAPIER)
	c.draw_arc(p, r * 1.25, 0, TAU, 32, TINTE, 1.8 * dp, true)
	var w := 1.6 * dp
	match art:
		"PERSON":
			c.draw_circle(p + Vector2(0, -r * 0.32), r * 0.36, TINTE)
			var bogen := PackedVector2Array()
			for i in 13: bogen.append(p + Vector2(0, r * 0.71) + Vector2(cos(PI + i * PI / 12) * r * 0.62, sin(PI + i * PI / 12) * r * 0.55))
			c.draw_colored_polygon(bogen, TINTE)
		"INN":
			c.draw_rect(Rect2(p + Vector2(-r * 0.5, -r * 0.45), Vector2(r * 0.75, r)), TINTE, false, w)
			c.draw_arc(p + Vector2(r * 0.3, r * 0.025), r * 0.26, -PI / 2, PI / 2, 12, TINTE, w, true)
			c.draw_line(p + Vector2(-r * 0.55, -r * 0.6), p + Vector2(r * 0.3, -r * 0.6), TINTE, 2.4 * dp, true)
		"SHOP":
			c.draw_arc(p + Vector2(0, r * 0.15), r * 0.48, 0, TAU, 24, TINTE, w, true)
			c.draw_line(p + Vector2(-r * 0.28, -r * 0.42), p + Vector2(r * 0.28, -r * 0.42), TINTE, w, true)
			c.draw_line(p + Vector2(-r * 0.18, -r * 0.62), p + Vector2(0, -r * 0.42), TINTE, 1.4 * dp, true)
			c.draw_line(p + Vector2(r * 0.18, -r * 0.62), p + Vector2(0, -r * 0.42), TINTE, 1.4 * dp, true)
		"TEMPLE":
			c.draw_circle(p, r * 0.3, TINTE)
			for k in 8:
				var a := k * PI / 4
				c.draw_line(p + Vector2(cos(a), sin(a)) * r * 0.45, p + Vector2(cos(a), sin(a)) * r * 0.78, TINTE, 1.4 * dp, true)

# 62n: ein Schild ueber der Tuer: Ausleger, zwei kurze Ketten, das Brett, darauf, was das Haus ist
static func zeichne_schild(c: CanvasItem, name: String, p: Vector2, r: float) -> void:
	var dp := DP
	var o := func(x: float, y: float) -> Vector2: return p + Vector2(x, y) * r
	var w := 1.6 * dp
	c.draw_line(o.call(-1.3, -1.5), o.call(1.2, -1.5), TINTE, w, true)
	c.draw_line(o.call(-1.3, -1.5), o.call(-0.6, -0.9), TINTE, w * 0.8, true)
	c.draw_line(o.call(-0.75, -1.5), o.call(-0.75, -1.05), TINTE, w * 0.7, true)
	c.draw_line(o.call(0.75, -1.5), o.call(0.75, -1.05), TINTE, w * 0.7, true)
	var brett := StyleBoxFlat.new()
	brett.bg_color = PAPIER; brett.border_color = TINTE
	brett.set_border_width_all(maxi(1, int(round(1.6 * dp)))); brett.set_corner_radius_all(int(round(0.2 * r))); brett.anti_aliasing = true
	c.draw_style_box(brett, Rect2(o.call(-1.05, -1.05), Vector2(2.1, 1.75) * r))
	var m: Vector2 = o.call(0, -0.18)
	var q := func(x: float, y: float) -> Vector2: return m + Vector2(x, y) * r
	var l := 1.4 * dp
	if name.begins_with("Schänke"):
		c.draw_rect(Rect2(q.call(-0.4, -0.4), Vector2(0.6, 0.8) * r), TINTE, false, l)
		c.draw_arc(q.call(0.25, -0.025), 0.22 * r, -PI / 2, PI / 2, 10, TINTE, l, true)
	elif name.begins_with("Kramladen"):
		c.draw_arc(q.call(0, 0.08), 0.38 * r, 0, TAU, 20, TINTE, l, true)
		c.draw_line(q.call(-0.22, -0.38), q.call(0.22, -0.38), TINTE, w, true)
	elif name.begins_with("Tempel"):
		c.draw_circle(m, 0.2 * r, TINTE)
		for k in 8:
			var a := k * PI / 4
			c.draw_line(m + Vector2(cos(a), sin(a)) * 0.3 * r, m + Vector2(cos(a), sin(a)) * 0.5 * r, TINTE, w * 0.7, true)
	elif name.begins_with("Schmied"):
		c.draw_line(q.call(-0.55, -0.15), q.call(0.5, -0.15), TINTE, w * 1.8, true)
		c.draw_line(q.call(-0.1, -0.1), q.call(-0.05, 0.3), TINTE, w * 1.4, true)
		c.draw_line(q.call(-0.35, 0.38), q.call(0.3, 0.38), TINTE, w * 1.4, true)
	elif name.begins_with("Bäcker"):
		var ei := PackedVector2Array()
		for i in 25: ei.append(m + Vector2(cos(i * TAU / 24) * 0.5, -0.025 + sin(i * TAU / 24) * 0.275) * r)
		c.draw_polyline(ei, TINTE, l, true)
	elif name.begins_with("Ältester"):
		c.draw_rect(Rect2(q.call(-0.35, -0.4), Vector2(0.7, 0.8) * r), TINTE, false, l)
		for k in 3: c.draw_line(q.call(-0.2, -0.18 + k * 0.2), q.call(0.2, -0.18 + k * 0.2), TINTE, w * 0.6, true)
	else:
		c.draw_rect(Rect2(q.call(-0.25, -0.35), Vector2(0.5, 0.75) * r), TINTE, false, l)
		c.draw_circle(q.call(0.12, 0.05), 0.05 * r, TINTE)

# der Held: ein roter Ring, ein Punkt und ein kleiner Keil in Blickrichtung
static func zeichne_held(c: CanvasItem, p: Vector2, blick: String) -> void:
	var r := 11 * DP
	c.draw_circle(p, r * 1.6, Color(ROT, 0.33))
	c.draw_arc(p, r, 0, TAU, 32, ROT, 3 * DP, true)
	c.draw_circle(p, r * 0.35, ROT)
	var f: Vector2 = {"UP": Vector2(0, -1), "DOWN": Vector2(0, 1), "LEFT": Vector2(-1, 0), "RIGHT": Vector2(1, 0)}.get(blick, Vector2(0, 1))
	var seite := Vector2(-f.y, f.x) * r * 0.55
	var fuss := p + f * r * 1.15
	c.draw_colored_polygon(PackedVector2Array([p + f * r * 1.9, fuss + seite, fuss - seite]), ROT)

# ---------------------------------------------------------------- Bedienung: ein Finger schiebt, zwei zoomen, Antippen

class Flaeche extends Control:
	var reiter: Kartenreiter
	var tex: Texture2D
	var mass := 1.0
	var versatz := Vector2.ZERO
	var passt := 1.0
	var finger := {}
	var start := Vector2.ZERO
	var bewegt := false
	var abstand := 0.0

	func _init(r: Kartenreiter) -> void:
		reiter = r
		mouse_filter = Control.MOUSE_FILTER_STOP
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

	func klemme() -> void:
		var g := tex.get_size() * mass if tex else Vector2.ZERO
		versatz.x = (size.x - g.x) / 2 if g.x <= size.x else clampf(versatz.x, size.x - g.x, 0)
		versatz.y = (size.y - g.y) / 2 if g.y <= size.y else clampf(versatz.y, size.y - g.y, 0)

	func zoome(mitte: Vector2, k: float) -> void:
		var neu := clampf(mass * k, passt, passt * 6.0)
		versatz = mitte - (mitte - versatz) * (neu / mass)
		mass = neu
		klemme(); queue_redraw()

	func _gui_input(e: InputEvent) -> void:
		if e is InputEventScreenTouch:
			if e.pressed:
				finger[e.index] = e.position
				if finger.size() == 1: start = e.position; bewegt = false
				if finger.size() == 2: abstand = (finger.values()[0] as Vector2).distance_to(finger.values()[1])
			else:
				finger.erase(e.index)
				if finger.is_empty() and not bewegt: tippe(e.position)
			accept_event()
		elif e is InputEventScreenDrag:
			if not finger.has(e.index): return
			if finger.size() >= 2:
				finger[e.index] = e.position
				var a: Vector2 = finger.values()[0]; var b: Vector2 = finger.values()[1]
				var d := a.distance_to(b)
				if abstand > 0: zoome((a + b) / 2, d / abstand)
				abstand = d
				bewegt = true
			else:
				finger[e.index] = e.position
				if e.position.distance_to(start) > 10 * Kartenreiter.DP: bewegt = true
				if bewegt: versatz += e.relative; klemme(); queue_redraw()
			accept_event()
		elif e is InputEventMouseButton and e.pressed and e.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			zoome(e.position, 1.15 if e.button_index == MOUSE_BUTTON_WHEEL_UP else 1 / 1.15)
			accept_event()

	func tippe(_p: Vector2) -> void: pass

class Kartenblatt extends Flaeche:
	var k: Dictionary
	var fein := 1.0
	var hier := false
	var marken: Array
	var haus: Array
	var anfang := true

	func _init(r: Kartenreiter) -> void:
		super(r)
		k = r.karte_daten()
		tex = Kartenreiter.bild("karte-" + r.gezeigt)
		var b: Dictionary = Kartenreiter.blatt()
		if tex: fein = tex.get_width() / float(int(k["breite"]) * int(b["kachel"]) + 2 * int(b["rand"]))
		hier = r.gezeigt == String(r.ort.get("karte", ""))
		marken = r.zeichen()
		haus = r.haeuser()
		resized.connect(_passe)

	func _passe() -> void:
		if tex == null or size.x <= 0: return
		passt = minf(size.x / tex.get_width(), size.y / tex.get_height())
		if anfang:   # oeffnet vergroessert auf dem Helden, mindestens so, dass die Karte den Rahmen fuellt
			anfang = false
			mass = maxf(passt * 2.5, maxf(size.x / tex.get_width(), size.y / tex.get_height())) if hier and String(k["art"]) != "INTERIOR" else passt
			versatz = size / 2 - Vector2(cx(int(reiter.ort["x"])), cy(int(reiter.ort["y"]))) * mass if hier else Vector2.ZERO
		mass = maxf(mass, passt)
		klemme(); queue_redraw()

	func cx(tx: int) -> float:
		var b: Dictionary = Kartenreiter.blatt()
		return (int(b["rand"]) + tx * int(b["kachel"]) + int(b["kachel"]) / 2.0) * fein
	func cy(ty: int) -> float: return cx(ty)
	func an(x: int, y: int) -> Vector2: return versatz + Vector2(cx(x), cy(y)) * mass

	func _draw() -> void:
		if tex == null: return
		draw_texture_rect(tex, Rect2(versatz, tex.get_size() * mass), false)
		for h in haus: Kartenreiter.zeichne_schild(self, String(h["name"]["de"]), an(int(h["x"]), int(h["y"]) - 2), 9 * Kartenreiter.DP)
		for m in marken:
			var c := an(int(m["x"]), int(m["y"]))
			var a := 0.4 if m.get("fertig", false) else 1.0
			var r := 7 * Kartenreiter.DP
			if m["art"] == "GIVER":
				draw_circle(c, r + 2 * Kartenreiter.DP, Color(Kartenreiter.TINTE, a))
				draw_circle(c, r, Color(Kartenreiter.BLAU, a))
			elif m["art"] == "BOARD":   # 62e: ein kleiner angenagelter Zettel
				var dp := Kartenreiter.DP
				var rr := Rect2(c - Vector2(r * 0.85, r), Vector2(r * 1.7, r * 2))
				draw_rect(rr, Color("e8dcc0"))
				draw_rect(rr, Kartenreiter.TINTE, false, 2 * dp)
				for k in range(1, 4): draw_line(rr.position + Vector2(r * 0.35, r * 0.5 * k), rr.position + Vector2(rr.size.x - r * 0.35, r * 0.5 * k), Color(Kartenreiter.TINTE, 0.6), 1.2 * dp)
			else: Kartenreiter.zeichne_dienst(self, String(m["art"]), c, r)
		if hier: Kartenreiter.zeichne_held(self, an(int(reiter.ort["x"]), int(reiter.ort["y"])), String(reiter.ort.get("blick", "DOWN")))

	func nah(p: Vector2, x: int, y: int, r: float) -> bool: return p.distance_to(an(x, y)) < r * Kartenreiter.DP

	func tippe(p: Vector2) -> void:
		# 62n: mit Schildern nennt Antippen das Haus; 62s: ein Haus, in dem der Held war, oeffnet seinen Grundriss
		for h in haus:
			if nah(p, int(h["x"]), int(h["y"]) - 2, 20):
				if String(h["innen"]) != "" and Kartenreiter.blatt()["karten"].has(String(h["innen"])): oeffne(String(h["innen"]))
				else: reiter.tipp(Sprache.t(h["name"]))
				return
		var bester = null
		for m in marken:
			if nah(p, int(m["x"]), int(m["y"]), 28) and (bester == null or p.distance_to(an(int(m["x"]), int(m["y"]))) < p.distance_to(an(int(bester["x"]), int(bester["y"])))): bester = m
		if bester:
			reiter.tipp(Sprache.t(bester["text"]), bester["art"] == "GIVER" or bester["art"] == "GOAL")
			return
		reiter.tipp("")
		# 62s: auch Dach und Waende eines bekannten Hauses oeffnen den Grundriss
		for h in haus:
			var innen := String(h["innen"])
			if innen == "" or not Kartenreiter.blatt()["karten"].has(innen): continue
			for d in 3:
				if nah(p, int(h["x"]), int(h["y"]) - d, 24): oeffne(innen); return

	func oeffne(innen: String) -> void:
		reiter.gezeigt = innen
		reiter.call_deferred("baue")

# 62h: die Landkarte, jeder Ort als kleine Zeichnung, unbekannte unter Nebel, Namen in Handschrift, der Ort des Helden rot;
# ein bekannter Ort oeffnet seine Karte, nie eine Reise
class Landblatt extends Flaeche:
	var land: Dictionary
	var fein := 3.0

	func _init(r: Kartenreiter) -> void:
		super(r)
		land = Kartenreiter.blatt().get("land", {})
		var name := "land-"
		for w in land.get("wild", []): name += "1" if kennt(String(w)) else "0"
		tex = Kartenreiter.bild(name)
		fein = float(land.get("fein", 3))
		resized.connect(func():
			if tex == null: return
			passt = minf(size.x / tex.get_width(), size.y / tex.get_height())
			mass = passt
			klemme(); queue_redraw())

	func kennt(id: String) -> bool:
		return not (id in land.get("wild", [])) or reiter.z.has("besucht:" + id) or id == String(reiter.ort.get("karte", ""))

	func an(x: float, y: float) -> Vector2: return versatz + Vector2(x, y) * fein * mass

	# wo der Held ist: der Ort unter freiem Himmel, auch aus einem Haus (62p: ein Grundriss ist kein Ort der Landkarte)
	func hier() -> String:
		var o := String(reiter.ort.get("karte", ""))
		var k: Dictionary = Kartenreiter.blatt().get("karten", {}).get(o, {})
		if String(k.get("art", "")) == "INTERIOR": return String(k.get("oben", "village"))
		return "forest" if o == "cave" else o

	func _draw() -> void:
		if tex == null: return
		draw_texture_rect(tex, Rect2(versatz, tex.get_size() * mass), false)
		var f := Kartenreiter.hand()
		var gr := int(round(16 * Stil.SP))
		for sp in land.get("orte", []):
			var t := Sprache.t(sp["name"]) if kennt(String(sp["karte"])) else "?"
			var b := f.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, gr).x
			var lx := clampf(an(float(sp["schrift_x"]), 0).x - b / 2, versatz.x + 4 * Kartenreiter.DP, maxf(versatz.x + 4 * Kartenreiter.DP, versatz.x + tex.get_width() * mass - b - 4 * Kartenreiter.DP))
			var ly := an(0, float(sp["schrift_y"])).y + f.get_ascent(gr)
			draw_string_outline(f, Vector2(lx, ly), t, HORIZONTAL_ALIGNMENT_LEFT, -1, gr, int(5 * Kartenreiter.DP), Color(Kartenreiter.PERGAMENT, 0.85))
			draw_string(f, Vector2(lx, ly), t, HORIZONTAL_ALIGNMENT_LEFT, -1, gr, Kartenreiter.TINTE)
			if String(sp["karte"]) == hier():
				var c := an(float(sp["x"]), float(sp["y"]) - float(sp["r"]) * 0.15)
				draw_circle(c, 16 * Kartenreiter.DP, Color(Kartenreiter.ROT, 0.33))
				draw_arc(c, 10 * Kartenreiter.DP, 0, TAU, 32, Kartenreiter.ROT, 3 * Kartenreiter.DP, true)
				draw_circle(c, 3.5 * Kartenreiter.DP, Kartenreiter.ROT)
		# der Weg nach Sueden verlaesst die Zeichnung: wohin er fuehrt
		var gs := int(round(13 * Stil.SP))
		var p := an(108, 278) + Vector2(0, f.get_ascent(gs))
		draw_string_outline(f, p, Kartenreiter.wort("sueden"), HORIZONTAL_ALIGNMENT_LEFT, -1, gs, int(5 * Kartenreiter.DP), Color(Kartenreiter.PERGAMENT, 0.85))
		draw_string(f, p, Kartenreiter.wort("sueden"), HORIZONTAL_ALIGNMENT_LEFT, -1, gs, Color(Kartenreiter.TINTE, 0.8))

	func tippe(p: Vector2) -> void:
		for sp in land.get("orte", []):
			var id := String(sp["karte"])
			if kennt(id) and Kartenreiter.blatt()["karten"].has(id) and p.distance_to(an(float(sp["x"]), float(sp["y"]))) < float(sp["r"]) * fein * mass:
				reiter.gezeigt = id
				reiter.uebersicht = false
				reiter.call_deferred("baue")
				return
