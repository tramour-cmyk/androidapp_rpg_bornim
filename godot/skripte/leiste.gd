class_name Leiste
extends PanelContainer
# 399.1 Leiste oben wie im alten Spiel (WorldScreen.kt HudChip mit bar = true; Test 132, Chef 16:09: „4 Stunden später … sehe ich
# nicht, weil es keine Spielzeit gibt … Gold … Trefferpunkte … Taschen … weiß ich alles nicht … es gibt ja kein Menü“): schwarz ueber
# die ganze Breite, unten eine duenne Goldlinie; links TP, ZP (nur Zauberer) und EP mit Stufe als schmale Balken, daneben Sonne
# oder Mond, Tag und Uhrzeit, darunter die Zustaende und freie Attributspunkte; rechts die Tasche, sie oeffnet das Menue. Antippen
# irgendwo auf der Leiste oeffnet es ebenfalls (alt: Row.tap(onMenu)). Schrift Alegreya wie ueberall (292.3).

signal menue

const DP := AktionsKnopf.DP
const HP_GRUEN := Color("48c858")
const HP_GELB := Color("f0c030")
const ROT := Color("e05a3a")       # Colors.accent
const BLAU := Color("4890f0")      # Colors.sp
const GOLD_HELL := Color("f0c040") # Colors.gold, EP
const SPUR := Color("2a251d")      # Bar: warme dunkle Spur

var balken := {}                   # "tp", "zp", "ep" -> [Zeile, Balken, Wert]
var uhr: Label
var zeichen: Zeichen
var chips: HBoxContainer

class Balken extends Control:
	var anteil := 1.0
	var farbe := Color.WHITE
	func _init() -> void: custom_minimum_size = Vector2(56, 5) * DP
	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), SPUR)
		var innen := Rect2(Vector2(DP, DP), size - Vector2(2, 2) * DP)
		innen.size.x *= clampf(anteil, 0.0, 1.0)
		draw_rect(innen, farbe)

# Sonne, Mond (ActionSigns.kt) und Tasche (MenuTabs.kt TabSign.BAG) auf 24 Einheiten
class Zeichen extends Control:
	var art := "sonne"
	func _init(a: String, dp: float) -> void:
		art = a
		custom_minimum_size = Vector2(dp, dp) * DP
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _draw() -> void:
		var u := size.x / 24.0
		var c := Stil.BRIGHT
		var w := 1.6 * u
		match art:
			"sonne":
				draw_arc(Vector2(12, 12) * u, 4.5 * u, 0, TAU, 24, c, w, true)
				for i in 8:
					var a := i * PI / 4
					draw_line(Vector2(12 + 7.5 * cos(a), 12 + 7.5 * sin(a)) * u, Vector2(12 + 10 * cos(a), 12 + 10 * sin(a)) * u, c, w, true)
			"mond":   # Kreis (12|12, r 8) ohne den versetzten Kreis (15,5|9,5, r 6,5): die Sichel zwischen ihren Schnittpunkten
				var m1 := Vector2(12, 12); var r1 := 8.0
				var m2 := Vector2(15.5, 9.5); var r2 := 6.5
				var d := m1.distance_to(m2)
				var x := (d * d + r1 * r1 - r2 * r2) / (2 * d)
				var h := sqrt(r1 * r1 - x * x)
				var e := (m2 - m1) / d
				var s1 := m1 + e * x + Vector2(-e.y, e.x) * h
				var s2 := m1 + e * x - Vector2(-e.y, e.x) * h
				var a1 := (s1 - m1).angle(); var a2 := (s2 - m1).angle()
				var b1 := (s1 - m2).angle(); var b2 := (s2 - m2).angle()
				if a2 < a1: a2 += TAU   # aussen den langen Weg vom ersten zum zweiten Schnittpunkt, weg vom Schnittkreis
				var mitte := (a1 + a2) * 0.5
				if Vector2.from_angle(mitte).dot(e) > 0: a2 -= TAU
				if b1 < b2: b1 += TAU   # innen zurueck den kurzen Weg, durch den Mond hindurch
				var p := PackedVector2Array()
				for i in 33: p.append((m1 + Vector2.from_angle(lerpf(a1, a2, i / 32.0)) * r1) * u)
				var bm := (b2 + b1) * 0.5
				if (m2 + Vector2.from_angle(bm) * r2).distance_to(m1) > r1: b1 -= TAU
				for i in 33: p.append((m2 + Vector2.from_angle(lerpf(b2, b1, i / 32.0)) * r2) * u)
				draw_polyline(p, c, w, true)
			"tasche":
				var ecke := PackedVector2Array()   # Koerper mit runden Ecken (2,5), sonst liest er sich als Briefumschlag (Helfer)
				for m in [[Vector2(17.5, 18.5), 0.0], [Vector2(6.5, 18.5), 0.5], [Vector2(6.5, 11.5), 1.0], [Vector2(17.5, 11.5), 1.5]]:
					for i in 7: ecke.append((m[0] + Vector2.from_angle((m[1] + i / 12.0) * PI) * 2.5) * u)
				ecke.append(ecke[0])
				draw_polyline(ecke, c, w, true)
				draw_polyline(PackedVector2Array([Vector2(4.5, 10) * u, Vector2(12, 15) * u, Vector2(19.5, 10) * u]), c, w, true)
				draw_rect(Rect2(Vector2(11, 14.5) * u, Vector2(2, 2.5) * u), c, false, 1.1 * u)
				draw_arc(Vector2(12, 8.5) * u, 5 * u, PI, TAU, 16, c, 1.1 * u, true)

func _init() -> void:
	name = "Leiste"
	var s := StyleBoxFlat.new()
	s.bg_color = Color.BLACK
	s.border_color = Stil.RIM
	s.border_width_bottom = maxi(1, int(round(DP)))   # duenne Goldlinie unten wie der Rahmen des Textkastens (60, 77.1)
	s.content_margin_left = 10 * DP; s.content_margin_right = 10 * DP
	s.content_margin_top = 3 * DP; s.content_margin_bottom = 3 * DP
	add_theme_stylebox_override("panel", s)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var reihe := HBoxContainer.new()
	reihe.add_theme_constant_override("separation", 0)
	reihe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(reihe)
	var links := VBoxContainer.new()
	links.add_theme_constant_override("separation", 0)
	links.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reihe.add_child(links)
	for k in ["tp", "zp", "ep"]:
		var z := HBoxContainer.new()
		z.add_theme_constant_override("separation", 0)
		z.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var n := wort("", 9, ROT if k == "tp" else (BLAU if k == "zp" else GOLD_HELL))
		n.custom_minimum_size.x = 22 * DP
		z.add_child(n)
		var b := Balken.new()
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		z.add_child(b)
		var abst := Control.new(); abst.custom_minimum_size.x = 4 * DP
		z.add_child(abst)
		var v := wort("", 10, Color("f4f0ff"))
		v.custom_minimum_size.x = 46 * DP
		z.add_child(v)
		links.add_child(z)
		balken[k] = [z, b, v, n]
	var luecke := Control.new(); luecke.custom_minimum_size.x = 6 * DP
	reihe.add_child(luecke)
	var rechts := VBoxContainer.new()
	rechts.add_theme_constant_override("separation", int(DP))
	rechts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rechts.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	reihe.add_child(rechts)
	var zeit := HBoxContainer.new()
	zeit.add_theme_constant_override("separation", int(2 * DP))
	zeit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zeichen = Zeichen.new("sonne", 16)
	zeit.add_child(zeichen)
	uhr = wort("", 11, Color("f4f0ff"))
	zeit.add_child(uhr)
	rechts.add_child(zeit)
	chips = HBoxContainer.new()
	chips.add_theme_constant_override("separation", int(3 * DP))
	chips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rechts.add_child(chips)
	var platz := Control.new()
	platz.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	platz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reihe.add_child(platz)
	var tasche := Zeichen.new("tasche", 28)
	tasche.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	reihe.add_child(tasche)

func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		menue.emit()
		accept_event()

# Txt auf Schwarz wie Erschaffung.txt, aber einzeilig
static func wort(t: String, groesse_sp: float, farbe: Color) -> Label:
	var l := Stil.zeile(t, maxf(groesse_sp, 13.7) * 0.95, farbe, 0.2)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

# HudInfo.of: Werte des Helden, Tag und Uhr, Nacht (Game.isNight: Tageslicht unter 0,35), Zustaende, freie Punkte
func zeige(hw: Heldwerte, z: Zustand, nacht: bool) -> void:
	var de := Sprache.aktiv() == "de"
	var tp: Array = balken["tp"]
	var anteil := float(hw.tp) / maxf(1.0, float(hw.max_tp()))
	tp[3].text = Sprache.u("hp"); tp[1].anteil = anteil
	tp[1].farbe = HP_GRUEN if anteil > 0.5 else (HP_GELB if anteil > 0.2 else ROT)
	tp[2].text = "%d/%d" % [hw.tp, hw.max_tp()]
	var zp: Array = balken["zp"]
	zp[0].visible = hw.max_zp() > 0
	zp[3].text = Sprache.u("sp"); zp[1].anteil = float(hw.zp) / maxf(1.0, float(hw.max_zp())); zp[1].farbe = BLAU
	zp[2].text = "%d/%d" % [hw.zp, hw.max_zp()]
	var ep: Array = balken["ep"]
	var tab: Array = Heldwerte.regel("ep_fuer_stufe")
	var von := int(tab[hw.stufe])
	var bis := int(tab[hw.stufe + 1]) if hw.stufe + 1 < tab.size() and hw.stufe < int(Heldwerte.regel("max_stufe")) else -1
	ep[3].text = Sprache.u("xp"); ep[1].farbe = GOLD_HELL
	ep[1].anteil = 1.0 if bis < 0 else clampf(float(hw.ep - von) / float(bis - von), 0.0, 1.0)
	ep[2].text = ("St. " if de else "Lv ") + str(hw.stufe)
	for k in balken: balken[k][1].queue_redraw()
	zeichen.art = "mond" if nacht else "sonne"
	zeichen.queue_redraw()
	uhr.text = ("Tag %d · " if de else "Day %d · ") % z.tag + "%02d:%02d" % [z.minuten / 60, z.minuten % 60]
	for c in chips.get_children():
		chips.remove_child(c)
		c.queue_free()
	var zd: Dictionary = Heldwerte.lade().get("zustaende", {})
	var welche := []
	for st in zd:   # Reihenfolge wie Status.entries; betrunken gilt bis zur Rast (86.9)
		if int(z.leiden.get(st, 0)) > 0 or (st == "DRUNK" and z.betrunken()): welche.append(st)
	for st in welche:
		var k := PanelContainer.new()
		var s := StyleBoxFlat.new()
		s.bg_color = Color(String(zd[st]["farbe"])); s.set_corner_radius_all(int(3 * DP))
		s.content_margin_left = 3 * DP; s.content_margin_right = 3 * DP
		k.add_theme_stylebox_override("panel", s)
		k.mouse_filter = Control.MOUSE_FILTER_IGNORE
		k.add_child(wort(Sprache.t(zd[st]["kurz"]), 9, Color.WHITE))
		chips.add_child(k)
	if hw.offen > 0: chips.add_child(wort("★ +%d" % hw.offen, 11, GOLD_HELL))
	if welche.is_empty() and hw.offen == 0: chips.add_child(wort(" ", 11, Color.WHITE))   # die Zeile bleibt, die Leiste springt nie
