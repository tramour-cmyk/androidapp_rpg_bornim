extends RefCounted
## 930.7 (DESIGN-GLUT.md 7, 8; Bauplan 10 Stufe 2): Bedienung und Kerbmarken des Kerbensystems am Kampfort, nur mit dem Schalter
## Mars.kerbe (sonst ruft kampf_ui.gd nichts hiervon).
## 1266 (1260 D, Chef 15.11., 10:07: die Punkte heißen Kerbe; DESIGN-GLUT.md 8): Bild wie am Kerbholz, kein Feuer. Für jeden der
## Gruppe drei leere Plätze im Fußring an einer feinen Goldlinie (dem Holz); jede Tat schlägt eine Kerbe: schwarzer Schnitt mit
## Goldrand (Tuschelinie, Gold als einziger Glanz), dazu ein trockener Schnitt in Holz. Vertiefen: die Kerbe wird tiefer, das Gold
## zieht zur Waffe, die kurz golden aufscheint. Haltung: die Kerbe bleibt offen mit ihrem Zeichen (Klinge Gegenschlag, Pfeilspitze
## Wachschuss, Schild Wehr). Antwort: der Goldrand blitzt im Augenblick des Schlags. Ungeschlagene Kerben verfallen am Zugbeginn:
## der Platz verblasst und sinkt (Wort dafür offen, 1265). Goldkerbe: ein goldener Punkt sinkt vom Kopf in den Fußring und wird die
## vierte, ganz goldene Kerbe. Gegner zeigen ihre Kerben erst mit Stufe 3 (Bild der Ansage, nach dem Gespräch).
## Bedienung: ein Tipp auf den Gegner = Weg und Tun, die übrigen Kerben nach dem Vorschlag (7.1); ein Tipp auf den Helden öffnet am
## Daumen drei Zeichen (Gegenschlag oder Wachschuss, Wehr, Vertiefen), der Vorschlag vorgewählt, je Tipp wandert eine Kerbe dorthin
## (7.2); solange es offen ist, stehen über den Figuren die Ziffern der Schlagfolge (7.3, kerbe.gd vorschau). Bestätigt wird mit dem
## Tipp auf den Gegner oder „Angriff“; „Haltung“ (statt „Abwehr“, 7.5) legt alle Kerben in die gewählte Haltung.
## Langes Drücken bleibt die Erklärung (536): der Tipp gilt erst beim Loslassen, und nur, wenn er kürzer war.

const Kerbe = preload("res://regeln/kerbe.gd")
const Figur = preload("res://kampf/figur.gd")

const GOLD := Color("#B59A6A")                  # kampf_ui GOLD: Rand einer geschlagenen Kerbe
const ZEICHEN := Color("#D9BC82")               # kampf_ui BRIGHT: geplant, offen, Goldkerbe
const ZEICHEN_MATT := Color("#948A78")          # kampf_ui DIM
const RAND := Color(0.710, 0.604, 0.416, 0.67)  # kampf_ui RIM: das Holz, leere Plätze
const HELL := Color(1.0, 0.95, 0.82)            # Blitz der Antwort, frischer Schnitt
const SCHNITT := Color(0.035, 0.03, 0.025, 0.96)     # das Schwarz im Schnitt
const TUSCHE := Color(0, 0, 0, 0.85)            # Umrandung, damit es auf Gras und Stein steht
const VERBLASST := Color(0.36, 0.34, 0.31)      # verfallend
const ZIFFER := Color("#E6DDCB")                # gebrochenes Weiß (DESIGN-AKTIONSPUNKTE.md „Bild“ 7)
const SPREIZ_GRAD := 17.0                       # Abstand der Kerben vor dem Fußring
const VOR_RING_M := 0.22                        # so weit vor dem Fußring (vorn steht das Dreieck der Ansage bis 0,5 m)
const BLITZ_MS := 380.0                         # Antwort: der Goldrand blitzt
const SCHNITT_MS := 220.0                       # frischer Schnitt: Rand hell, die Kerbe setzt sich
const SCHNITT_FOLGE_MS := 110.0                 # mehrere Kerben eines Zugs nacheinander geschlagen (tak, tak, tak)
const VERFALL_MS := 900.0                       # ungeschlagene Kerben verfallen
const ZIEHT_MS := 380.0                         # Vertiefen: das Gold zieht zur Waffe
const GLANZ_MS := 1200.0                        # danach scheint die Waffe golden auf
const SINKT_MS := 700.0                         # Goldkerbe: vom Kopf in den Fußring
const NACH := "tief"                            # Zeichen Vertiefen am Daumen
const PEGEL := {"kerbe": 0.7, "kerbe_tief": 0.75, "kerbe_antwort": 0.75, "kerbe_verfall": 0.5, "kerbe_gold": 0.7,
	"haltung_klinge": 0.7, "haltung_sehne": 0.7, "haltung_schild": 0.7}
const HALTUNG_KLANG := {"GEGENSCHLAG": "haltung_klinge", "WACHSCHUSS": "haltung_sehne", "WEHR": "haltung_schild"}

var ui
## Plan des Zugs im Daumenmenü: offen, vertieft, Haltung; gilt für den Zug [fuer] (Kennung und Runde)
var offen := false
var nach := 0
var haltung := ""
var gewaehlt := false     # der Spieler hat am Daumen etwas geändert (sonst spielt der Vorschlag, 7.1)
var fuer := ""
var symbol_rects := {}    # Zeichen -> Rect2 des Daumenmenüs in diesem Bild
var blitze: Array = []    # [Kennung, Platz, Beginn]: Antwort
var verfall: Array = []   # [Kennung, Platz, Beginn, Zahl der Plätze]
var ziehen: Array = []    # [Kennung, Platz, Beginn]
var glanz: Array = []     # [Figur, Beginn, Stufe, Material]
var sinken: Array = []    # [Kennung, Beginn]: Goldkerbe
var schnitte := {}        # „Kennung:Platz“ -> [Beginn, tief, gespielt]: frisch geschlagen
var _stand := {}          # „Kennung:Platz“ -> geschlagen im letzten Bild (der erste Blick schlägt nichts)
var druck_t0 := 0
var druck_p := Vector2.INF


func _init(kampf_ui) -> void:
	ui = kampf_ui


func _k():
	return ui.kampfort


func _m():
	return ui.kampfort.mars


func _jetzt() -> float:
	return float(ui.uhr.call())


## Wählt der Spieler gerade (kein Zug spielt, kein Ring, Hauptauswahl)? Dann der, der am Zug ist, sonst null
func waehlender():
	var k = _k()
	var m = _m()
	if not m.kerbe or m.gk == null or k.busy or k.playing or m.outcome != "ONGOING" or k.ring_open or k.tor != "" or ui.pick != "main":
		return null
	var f = m.current()
	if f == null or f.side != "PARTY" or not f.standing() or m.pilot_next():
		return null
	var key := "%s:%d" % [f.id, int(m.gk.runde)]
	if key != fuer:     # neuer Zug: der Vorschlag (7.1), Daumenmenü zu
		fuer = key
		offen = false
		gewaehlt = false
		nach = 0
		haltung = m.gk.vorschlag_haltung(f)
	return f


## Der Plan, den ein Tipp auf [ziel_id] spielt (kerbe.gd held_zug); ohne Änderung am Daumen die Haltung nach dem Vorschlag (AUTO)
func plan(f, ziel_id: String, tun := Kerbe.WAFFE) -> Dictionary:
	if not gewaehlt:
		return {"tun": tun, "ziel": ziel_id, "vertiefen": 0, "haltung": Kerbe.AUTO}
	return {"tun": tun, "ziel": ziel_id, "vertiefen": nach, "haltung": haltung}


## „Haltung“ (7.5, statt „Abwehr“): kein Tun, alle Kerben in die gewählte Haltung (ohne Wahl: Wehr wie die alte Abwehr)
func plan_haltung(_f) -> Dictionary:
	return {"tun": Kerbe.WARTEN, "haltung": haltung if gewaehlt else Kerbe.WEHR}


## Kerben, wie sie der Spieler beim Planen sieht: das erste ins Tun, dann vertieft, der Rest in der Haltung
func _plan_marken(f) -> Array:
	var out := []
	var n := int(f.gl.kerben)
	var rest: int = _m().gk.rest_nach_tun(f)
	var nl := mini(nach, rest)
	for i in n:
		if i < n - rest:
			out.append(Kerbe.M_TUN)
		elif i < n - rest + nl:
			out.append(Kerbe.M_TIEF)
		else:
			out.append(Kerbe.M_HALT)
	return out


# ---------------------------------------------------------------- Meldungen (kampfort.gd _play_say)

## Die Meldung [e] wird gespielt; [vor] die Kerben der vorigen: Antwort blitzt, ungeschlagene verfallen, Vertiefen zieht zur Waffe,
## Haltung gesetzt und Goldkerbe klingen
func meldung(vor: Dictionary, e: Dictionary) -> void:
	var neu: Dictionary = e.get("gl", {})
	var cue := String(e.get("cue")) if e.get("cue") != null else ""
	var t0 := _jetzt()
	var antwort := false
	var verfallen := false
	for id in neu:
		var a: Array = (vor.get(id, {}) as Dictionary).get("m", [])
		var b: Array = neu[id].get("m", [])
		var fig = _k().figures.get(id)
		if fig == null:
			continue
		for i in mini(a.size(), b.size()):
			if a[i] == b[i]:
				continue
			var key := "%s:%d" % [id, i]
			if a[i] == Kerbe.M_HALT and b[i] == Kerbe.M_GESCHLAGEN:
				_stand[key] = true     # kein Schnitt: die Haltung antwortet oder verfällt
				if cue == "KERBE_VERFALLEN":
					verfall.append([id, i, t0, a.size()])
					verfallen = true
				else:
					blitze.append([id, i, t0])
					antwort = true
			elif b[i] == Kerbe.M_TIEF:
				ziehen.append([id, i, t0])
		if cue == "KERBE_VERTIEFEN" and String(e.get("actor")) == String(id):
			_glanz(fig, t0 + ZIEHT_MS, b.count(Kerbe.M_TIEF))
	if antwort:
		_klang("kerbe_antwort")
	if verfallen:
		_klang("kerbe_verfall")
	if cue.begins_with("KERBE_HALTUNG_"):
		_klang(String(HALTUNG_KLANG.get(cue.trim_prefix("KERBE_HALTUNG_"), "")))
	elif cue == "KERBE_GOLD" and e.get("actor") != null:
		sinken.append([String(e.get("actor")), t0])
		_klang("kerbe_gold")


func _klang(id: String) -> void:
	if id == "":
		return
	if OS.get_environment("DBG9307") != "":
		print("KLANG %s bei %.2f s" % [id, _jetzt() / 1000.0])
	var klang = Engine.get_main_loop().root.get_node_or_null("Klang") if Engine.get_main_loop() is SceneTree else null
	if klang != null:
		klang.effekt(id, float(PEGEL.get(id, 0.7)))


func _glanz(fig, ab: float, stufe: int) -> void:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.albedo_color = Color(ZEICHEN, 0.0)
	glanz.append([fig, ab, stufe, mat])


func _waffe_meshes(fig) -> Array:
	if fig == null or not is_instance_valid(fig) or fig.model == null:
		return []
	var w = fig.model.find_child("Waffe", true, false)
	if w == null:
		return []
	return w.find_children("*", "MeshInstance3D", true, false)


# ---------------------------------------------------------------- Bild

## Ort des Platzes [i] von [n] am Fußring von [fig]: zur Kamera hin, nebeneinander
func _stein(fig, i: int, n: int) -> Vector3:
	var k = _k()
	var r := (0.75 if Figur.vier(fig.fighter) else 0.55) + VOR_RING_M
	var cam_l: Vector3 = k.to_local(k.cam.global_position) if k.cam != null else fig.position + Vector3(0, 0, 10)
	var d := Vector3(cam_l.x - fig.position.x, 0.0, cam_l.z - fig.position.z)
	d = d.normalized() if d.length() > 0.01 else Vector3(0, 0, 1)
	var a := deg_to_rad(SPREIZ_GRAD) * (float(i) - (n - 1) * 0.5)
	return fig.position + d.rotated(Vector3.UP, a) * r


var _oben: Array = []     # Plätze dieses Bilds für zeichnen_oben: [Bildpunkt, Art, Zeichen, Goldkerbe, Blitz, tief, Schnitt, Verfall]
var _holz: Array = []     # je Figur die Bildpunkte ihrer Plätze (die Goldlinie des Kerbholzes)

## Je Bild aus kampf_ui._draw_overlay vor dem Bau der Ringe: Stand der Plätze, frische Schnitte (mit Klang), Glanz der Waffe
func zeichnen(sr: Rect2) -> void:
	var k = _k()
	var m = _m()
	_oben.clear()
	_holz.clear()
	if not m.kerbe or m.gk == null:
		return
	var t := _jetzt()
	var wer = waehlender()
	var gl: Dictionary = m.gk.bild() if not k.busy else k.shown.get("gl", {})
	for id in gl:
		var fig = k.figures.get(id)
		if fig == null or not fig.visible or fig.down or k.shown.hp.get(id, fig.fighter.hp) <= 0:
			continue
		var mk: Array = gl[id].get("m", [])
		var h := String(gl[id].get("h", ""))
		if wer != null and wer.id == id:
			mk = _plan_marken(wer)
			h = haltung
		var folge := 0     # frische Schnitte dieses Bilds an dieser Figur, nacheinander
		var punkte := PackedVector2Array()
		for i in mk.size():
			folge = _stein_zeichnen(fig, id, i, mk.size(), String(mk[i]), h, bool(gl[id].get("f", false)) and i == 3, t, folge)
			punkte.append(_oben[-1][0])
		_holz.append(punkte)
	_glanz_pflegen(t)


## Danach (über den Dreiecken der Ansage): Kerbholz und Kerben im Bild (am Boden flach gestaucht wären sie im Hochformat nur
## Striche), ihre Zeichen, ziehendes Gold, sinkende Goldkerbe, Daumenmenü und Vorschau
func zeichnen_oben(sr: Rect2) -> void:
	symbol_rects.clear()
	var m = _m()
	if not m.kerbe or m.gk == null:
		return
	var t := _jetzt()
	var o: CanvasItem = ui.overlay
	var dp: float = ui.dp
	for punkte in _holz:     # das Holz: eine feine Goldlinie über den Plätzen, über den Rand hinaus
		if punkte.size() == 0:
			continue
		var linie := PackedVector2Array()
		var oben := Vector2(0, -_tiefe(false) * 0.5 * dp)
		var dx: Vector2 = (punkte[-1] - punkte[0]).normalized() if punkte.size() > 1 else Vector2.RIGHT
		linie.append(punkte[0] + oben - dx * 7.0 * dp)
		for p in punkte:
			linie.append(p + oben)
		linie.append(punkte[-1] + oben + dx * 7.0 * dp)
		o.draw_polyline(linie, TUSCHE, 3.2 * dp, true)
		o.draw_polyline(linie, RAND, 1.2 * dp, true)
	for e in _oben:
		_kerbe_zeichnen(o, dp, e)
	_ziehen_zeichnen(t)
	_sinken_zeichnen(t)
	var wer = waehlender()
	if wer != null:
		_menue(sr, wer)
		if offen:
			_vorschau(wer)


## Tiefe einer Kerbe in dp (Vertiefen: tiefer)
func _tiefe(tief: bool) -> float:
	return 14.0 if tief else 9.0


## Umriss einer Kerbe um [c]: oben offen an der Linie, unten spitz, leicht schräg wie ein Messerschnitt; [s] Maß (1 = normal)
func _form(c: Vector2, tief: bool, s: float, dp: float) -> PackedVector2Array:
	var w := (12.0 if tief else 10.0) * s * dp
	var d := _tiefe(tief) * s * dp
	var o := c + Vector2(0, -_tiefe(false) * 0.5 * dp)     # alle hängen an derselben Linie
	return PackedVector2Array([o + Vector2(-w * 0.5, 0), o + Vector2(w * 0.5, 0), o + Vector2(w * 0.12, d)])


## e: [Bildpunkt, Art, Zeichen, Goldkerbe, Blitz q oder -1, tief, Schnitt q oder -1, Verfall q oder -1]
func _kerbe_zeichnen(o: CanvasItem, dp: float, e: Array) -> void:
	var s: Vector2 = e[0]
	var art: String = e[1]
	var gold: bool = e[3]
	var blitz: float = e[4]
	var tief: bool = e[5]
	var schnitt: float = e[6]
	var vf: float = e[7]
	if vf >= 0.0:     # verfällt: verblasst, wird kleiner, sinkt
		var f := _form(s + Vector2(0, vf * 5.0 * dp), false, 1.0 - 0.4 * vf, dp)
		var c := (ZEICHEN if gold else RAND).lerp(VERBLASST, minf(1.0, vf * 1.6))
		_seiten(o, f, Color(c, 1.0 - vf), 1.1 * dp, dp)
		return
	var f := _form(s, tief, 1.0 + (0.25 * (1.0 - schnitt) if schnitt >= 0.0 else 0.0), dp)
	match art:
		Kerbe.M_GESCHLAGEN:
			var rand := GOLD
			var breite := 1.3
			if blitz >= 0.0:     # Antwort: der Goldrand blitzt
				var a := sin(PI * minf(blitz * 1.3, 1.0))
				rand = GOLD.lerp(HELL, a)
				breite += 1.4 * a
				o.draw_circle(s, (7.0 + 7.0 * a) * dp, Color(ZEICHEN, 0.22 * a))
			elif schnitt >= 0.0:     # frisch geschlagen
				rand = HELL.lerp(GOLD, schnitt)
				breite += 0.8 * (1.0 - schnitt)
			if gold:     # Goldkerbe: ganz golden, ein schwarzer Strich im Grund
				o.draw_colored_polygon(f, ZEICHEN)
				o.draw_polyline(PackedVector2Array([f[0].lerp(f[2], 0.35), f[2]]), SCHNITT, 1.0 * dp, true)
				_seiten(o, f, rand.lerp(HELL, 0.3), breite * dp, dp)
			else:
				o.draw_colored_polygon(f, SCHNITT)
				_seiten(o, f, rand, breite * dp, dp)
		Kerbe.M_TUN, Kerbe.M_TIEF:     # beim Planen: wird geschlagen (hell umrissen, noch kein Schwarz)
			_seiten(o, f, ZEICHEN, 1.7 * dp, dp)
			if art == Kerbe.M_TIEF:
				_zeichen(NACH, s + Vector2(0, 16 * dp), 6.0 * dp, ZEICHEN, true)
		Kerbe.M_HALT:     # offen, mit dem Zeichen der Haltung
			if gold:
				o.draw_colored_polygon(f, Color(ZEICHEN, 0.35))
			_seiten(o, f, ZEICHEN, 1.6 * dp, dp)
			if String(e[2]) != "":
				_zeichen(String(e[2]), s + Vector2(0, 17 * dp), 7.0 * dp, ZEICHEN, true)     # unter der Kerbe: darüber steht das Dreieck
		_:     # frei: ein leerer Platz am Holz
			if gold:
				o.draw_colored_polygon(f, Color(ZEICHEN, 0.45))
				_seiten(o, f, ZEICHEN, 1.4 * dp, dp)
			else:
				_seiten(o, f, Color(RAND, 0.55), 1.0 * dp, dp)


## Die beiden Schnittkanten einer Kerbe (oben bleibt sie offen an der Linie), schwarz unterlegt
func _seiten(o: CanvasItem, f: PackedVector2Array, c: Color, w: float, dp: float) -> void:
	var l := PackedVector2Array([f[0], f[2], f[1]])
	o.draw_polyline(l, Color(TUSCHE, TUSCHE.a * c.a), w + 2.0 * dp, true)
	o.draw_polyline(l, c, w, true)


## Ein Platz: wie er im Bild steht; ein frisch geschlagener klingt (mehrere eines Zugs nacheinander, [folge] zählt sie). Gibt [folge]
func _stein_zeichnen(fig, id: String, i: int, n: int, art: String, h: String, gold: bool, t: float, folge: int) -> int:
	var p := _stein(fig, i, n)
	var key := "%s:%d" % [id, i]
	var blitz := -1.0
	for b in blitze:
		if b[0] == id and b[1] == i and t - float(b[2]) < BLITZ_MS:
			blitz = (t - float(b[2])) / BLITZ_MS
	var vf := -1.0
	for v in verfall:
		if v[0] == id and v[1] == i and t - float(v[2]) < VERFALL_MS:
			vf = (t - float(v[2])) / VERFALL_MS
	for s in sinken:     # die Goldkerbe ist erst golden, wenn der Punkt vom Kopf angekommen ist
		if s[0] == id and t - float(s[1]) < SINKT_MS:
			gold = false
	var tief := art == Kerbe.M_TIEF
	var zieht := false
	for z in ziehen:
		if z[0] == id and z[1] == i and t - float(z[2]) < ZIEHT_MS:
			zieht = true
			tief = true
	if zieht or ((art == Kerbe.M_TIEF or art == Kerbe.M_TUN) and _k().busy):     # mit dem Befehl geschlagen
		art = Kerbe.M_GESCHLAGEN
	var geschlagen := art == Kerbe.M_GESCHLAGEN
	if geschlagen and _stand.has(key) and not _stand[key] and not schnitte.has(key):     # eben geschlagen: tak
		schnitte[key] = [t + folge * SCHNITT_FOLGE_MS, tief, false]
		folge += 1
	if not geschlagen:
		schnitte.erase(key)
	_stand[key] = geschlagen
	var sq := -1.0
	if schnitte.has(key):
		var sch: Array = schnitte[key]
		tief = tief or bool(sch[1])
		if t < float(sch[0]):     # noch nicht dran: steht wie geplant
			art = Kerbe.M_TIEF if tief else Kerbe.M_TUN
		else:
			if not sch[2]:
				sch[2] = true
				_klang("kerbe_tief" if tief else "kerbe")
			sq = (t - float(sch[0])) / SCHNITT_MS
			if sq >= 1.0:
				sq = -1.0
	var zeichen := h if art == Kerbe.M_HALT else ""
	_oben.append([_k().screen_of(p), art, zeichen, gold, blitz, tief, sq, vf])
	return folge


func _ziehen_zeichnen(t: float) -> void:
	var k = _k()
	var rest := []
	for z in ziehen:
		var q := (t - float(z[2])) / ZIEHT_MS
		if q >= 1.0:
			continue
		rest.append(z)
		var fig = k.figures.get(z[0])
		if fig == null:
			continue
		var gl: Dictionary = k.shown.get("gl", {}).get(z[0], {})
		var von: Vector2 = k.screen_of(_stein(fig, int(z[1]), (gl.get("m", [0, 0, 0]) as Array).size()))
		var nach_p := _waffe_bild(fig)
		var at := von.lerp(nach_p, q * q * (3.0 - 2.0 * q)) + Vector2(0, -sin(PI * q) * 16.0 * ui.dp)
		ui.overlay.draw_circle(at, 5.0 * ui.dp, Color(ZEICHEN, 0.25))
		ui.overlay.draw_circle(at, 2.2 * ui.dp, HELL)
	ziehen = rest


## Goldkerbe: ein goldener Punkt sinkt vom Kopf in den vierten Platz
func _sinken_zeichnen(t: float) -> void:
	var k = _k()
	var rest := []
	for s in sinken:
		var q := (t - float(s[1])) / SINKT_MS
		if q >= 1.0:
			continue
		rest.append(s)
		var fig = k.figures.get(s[0])
		if fig == null or not fig.visible:
			continue
		var gl: Dictionary = (k.shown.get("gl", {}) as Dictionary).get(s[0], {})
		var n := maxi(4, (gl.get("m", []) as Array).size())
		var von: Vector2 = k.screen_of(fig.head() + Vector3(0, 0.25, 0))
		var nach_p: Vector2 = k.screen_of(_stein(fig, mini(3, n - 1), n))
		var e := q * q * (3.0 - 2.0 * q)
		var at := von.lerp(nach_p, e)
		for j in 4:     # kurze Spur nach oben
			var sp := von.lerp(nach_p, maxf(0.0, e - 0.05 * (j + 1)))
			ui.overlay.draw_circle(sp, (2.0 - 0.4 * j) * ui.dp, Color(ZEICHEN, 0.4 - 0.09 * j))
		ui.overlay.draw_circle(at, 6.0 * ui.dp, Color(ZEICHEN, 0.25))
		ui.overlay.draw_circle(at, 2.6 * ui.dp, HELL)
	sinken = rest


## Bildpunkt der Waffe (Mitte ihrer Meshes), sonst die Brust
func _waffe_bild(fig) -> Vector2:
	var k = _k()
	var ms := _waffe_meshes(fig)
	if ms.is_empty():
		return k.screen_of(fig.position + Vector3(0, 1.0, 0))
	var c := Vector3.ZERO
	for mi in ms:
		c += (mi as MeshInstance3D).global_transform * (mi as MeshInstance3D).get_aabb().get_center()
	return k.screen_of(k.to_local(c / ms.size()))


## Vertiefen: die Waffe scheint golden auf und klingt ab (je Kerbe stärker), kein Glühen
func _glanz_pflegen(t: float) -> void:
	var rest := []
	for g in glanz:
		var fig = g[0]
		var q := (t - float(g[1])) / GLANZ_MS
		var mat: StandardMaterial3D = g[3]
		var ms := _waffe_meshes(fig)
		if q >= 1.0 or ms.is_empty():
			for mi in ms:
				if (mi as MeshInstance3D).material_overlay == mat:
					(mi as MeshInstance3D).material_overlay = null
			continue
		rest.append(g)
		var stark := 0.22 + 0.1 * float(int(g[2]) - 1)
		var a := 0.0 if q < 0.0 else stark * minf(q / 0.1, 1.0) * (1.0 - maxf(0.0, (q - 0.35) / 0.65))
		mat.albedo_color = Color(ZEICHEN, a)
		for mi in ms:
			(mi as MeshInstance3D).material_overlay = mat
	glanz = rest


## Ein Zeichen in der Größe [r] um [c]: Klinge, Pfeilspitze, Schild, Vertiefen (schwarz umrandet, damit es auf Gras und Stein steht)
func _zeichen(art: String, c: Vector2, r: float, col: Color, rand: bool) -> void:
	var o: CanvasItem = ui.overlay
	var w := maxf(1.0, r * 0.22)
	var pts: Array = []     # [Polylinie oder Fläche, ist Fläche]
	match art:
		Kerbe.GEGENSCHLAG:     # Klinge mit Parierstange
			pts.append([PackedVector2Array([c + Vector2(0, r), c + Vector2(0, -r)]), false])
			pts.append([PackedVector2Array([c + Vector2(-r * 0.5, r * 0.45), c + Vector2(r * 0.5, r * 0.45)]), false])
		Kerbe.WACHSCHUSS:     # Pfeilspitze am Schaft
			pts.append([PackedVector2Array([c + Vector2(0, -r), c + Vector2(r * 0.55, -r * 0.15), c + Vector2(-r * 0.55, -r * 0.15)]), true])
			pts.append([PackedVector2Array([c + Vector2(0, -r * 0.15), c + Vector2(0, r)]), false])
		Kerbe.WEHR:     # Schild
			pts.append([PackedVector2Array([c + Vector2(-r * 0.75, -r * 0.8), c + Vector2(r * 0.75, -r * 0.8), c + Vector2(r * 0.7, 0),
				c + Vector2(0, r), c + Vector2(-r * 0.7, 0)]), true])
		NACH:     # Vertiefen: eine tiefe Kerbe unter der Linie, darunter ein Pfeil in die Tiefe
			pts.append([PackedVector2Array([c + Vector2(-r * 0.9, -r), c + Vector2(r * 0.9, -r)]), false])
			pts.append([PackedVector2Array([c + Vector2(-r * 0.55, -r), c + Vector2(r * 0.08, r * 0.35), c + Vector2(r * 0.55, -r)]), true])
			pts.append([PackedVector2Array([c + Vector2(-r * 0.4, r * 0.6), c + Vector2(0, r), c + Vector2(r * 0.4, r * 0.6)]), false])
	for pl in pts:
		var line: PackedVector2Array = pl[0]
		if pl[1]:
			if rand:
				var z := line.duplicate()
				z.append(line[0])
				o.draw_polyline(z, TUSCHE, w + 2.0 * ui.dp, true)
			o.draw_colored_polygon(line, col)
		else:
			if rand:
				o.draw_polyline(line, TUSCHE, w + 2.0 * ui.dp, true)
			o.draw_polyline(line, col, w, true)

## 7.2: das Daumenmenü rechts über den Schaltern Würfel und Raster, offen drei Zeichen, je Kerbe eine kleine Kerbe darunter
func _menue(sr: Rect2, f) -> void:
	var dp: float = ui.dp
	var unten := minf(sr.size.y, ui.overlay.get_viewport_rect().size.y - ui.panel_height())
	var x := sr.size.x - 4 * dp - 24 * dp
	var y := unten - 4 * dp - 44 * dp - 34 * dp
	var rest: int = _m().gk.rest_nach_tun(f)
	var arten: Array = [_m().gk.haltungen(f)[0], Kerbe.WEHR, NACH]
	if not offen:
		return
	for j in arten.size():
		var art: String = arten[j]
		var c := Vector2(x, y - (arten.size() - 1 - j) * 58 * dp)
		var zahl := mini(nach, rest) if art == NACH else (rest - mini(nach, rest) if art == haltung else 0)
		var an := zahl > 0
		ui.overlay.draw_circle(c, 24 * dp, Color(0, 0, 0, 0.78))
		ui.overlay.draw_arc(c, 24 * dp, 0, TAU, 48, ZEICHEN if an else RAND, (2.0 if an else 1.2) * dp, true)
		_zeichen(art, c - Vector2(0, 3 * dp), 9.5 * dp, ZEICHEN if an else ZEICHEN_MATT, false)
		for q in zahl:     # je Kerbe eine kleine goldene Kerbe unter dem Zeichen
			var pc := c + Vector2((q - (zahl - 1) * 0.5) * 8 * dp, 15 * dp)
			var kf := _form(pc, false, 0.6, dp)
			ui.overlay.draw_colored_polygon(kf, SCHNITT)
			_seiten(ui.overlay, kf, ZEICHEN, 1.1 * dp, dp)
		symbol_rects[art] = Rect2(c - Vector2(26, 26) * dp, Vector2(52, 52) * dp)


## 7.3: Ziffern der Schlagfolge über den Figuren
func _vorschau(f) -> void:
	var k = _k()
	var m = _m()
	var ziel = m.gk.vorschlag_ziel(f)
	var folge: Array = m.gk.vorschau(f, plan(f, ziel.id if ziel != null else ""))
	var je := {}
	for i in folge.size():
		if not je.has(folge[i]):
			je[folge[i]] = []
		je[folge[i]].append(str(i + 1))
	for id in je:
		var fig = k.figures.get(id)
		if fig == null or not fig.visible:
			continue
		var text := " ".join(je[id])
		var fs: int = ui.sp(13)
		var w: float = ui.font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var kopf: Vector2 = k.screen_of(fig.head())
		var at := Vector2(kopf.x + ui._tall(fig) * 0.32, kopf.y + 4 * ui.dp)
		if OS.get_environment("DBG9307") != "":
			print("VORSCHAU %s %s kopf %s fuss %s pos %s" % [id, text, kopf, ui._foot(fig), fig.position])
		ui.overlay.draw_rect(Rect2(at.x - 4 * ui.dp, at.y - fs * 0.85, w + 8 * ui.dp, fs * 1.1), Color(0, 0, 0, 0.55))
		ui.overlay.draw_string(ui.font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ZIFFER)


# ---------------------------------------------------------------- Tippen (kampf_ui._scene_input)

func gedrueckt(p: Vector2) -> void:
	druck_t0 = int(ui.uhr.call())     # Uhr des Kampforts: im Film die Bildzeit (ein langsam gerechnetes Bild ist kein langes Drücken)
	druck_p = p


## Losgelassen an [p]: war es ein kurzer Tipp (kein langes Drücken, 536), wirkt er; true, wenn er etwas tat
func losgelassen(p: Vector2) -> bool:
	var kurz: bool = druck_t0 > 0 and int(ui.uhr.call()) - druck_t0 < int(ui.LANG_S * 1000.0) and p.distance_to(druck_p) < 24 * ui.dp
	druck_t0 = 0
	return kurz and tippen(p)


## Ein Tipp an [p] während der Wahl: Zeichen am Daumen, der Held (Menü auf, zu), ein Gegner (Weg und Tun)
func tippen(p: Vector2) -> bool:
	var f = waehlender()
	if f == null:
		return false
	var k = _k()
	var m = _m()
	if offen:
		for art in symbol_rects:
			if (symbol_rects[art] as Rect2).has_point(p):
				_symbol(f, String(art))
				ui.refresh()
				return true
	var held = k.figures.get(f.id)
	if held != null and _trifft(held, p):
		offen = not offen
		ui.refresh()
		return true
	for g in m.targets(f):
		var fig = k.figures.get(g.id)
		if fig != null and fig.visible and not fig.down and _trifft(fig, p):
			offen = false
			k.order(["KERBE", plan(f, g.id)])
			return true
	return false


func _trifft(fig, p: Vector2) -> bool:
	var h: float = ui._tall(fig)
	var ft: Vector2 = ui._foot(fig)
	return Rect2(ft.x - h * 0.5, ft.y - h * 1.1, h, h * 1.2).has_point(p)


## 7.2: je Tipp auf ein Zeichen wandert eine Kerbe dorthin; eine Art der Haltung je Zug (Regel 7): ein Tipp auf die andere Haltung
## nimmt deren Art und eine Kerbe aus dem Vertiefen dazu; Vertiefen nimmt eine aus der Haltung, ist sie leer, fällt alles zurück
func _symbol(f, art: String) -> void:
	var rest: int = _m().gk.rest_nach_tun(f)
	gewaehlt = true
	nach = mini(nach, rest)
	if art == NACH:
		nach = nach + 1 if nach < rest else 0
	elif art != haltung:
		haltung = art
		if nach >= rest and nach > 0:
			nach -= 1
	elif nach > 0:
		nach -= 1
