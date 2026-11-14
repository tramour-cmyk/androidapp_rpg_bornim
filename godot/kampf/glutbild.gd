extends RefCounted
## 930.7 (DESIGN-GLUT.md 7, 8; Bauplan 10 Stufe 2): Bedienung und Glutmarken des Glutsystems am Kampfort, nur mit dem Schalter
## Mars.glut (sonst ruft kampf_ui.gd nichts hiervon).
## Bild: für jeden der Gruppe seine Glutstücke im Fußring, golden-orange mit leisem Schein, verbraucht grau wie Asche; ins Tun gelegt
## ohne Zeichen, nachgelegt mit Flamme (das Stück zieht zur Waffe, die glimmt nach), in der Haltung mit ihrem Zeichen (Klinge
## Gegenschlag, Pfeilspitze Wachschuss, Schild Wehr). Eine Antwort flammt auf und erlischt; ungenutzte Haltung zerfällt am Zugbeginn
## in aufsteigende Funken; der Funke ist das vierte, hellere Stück.
## Bedienung: ein Tipp auf den Gegner = Weg und Tun, die übrige Glut nach dem Vorschlag (7.1); ein Tipp auf den Helden öffnet am
## Daumen drei Zeichen (Gegenschlag oder Wachschuss, Wehr, Nachlegen), der Vorschlag vorgewählt, je Tipp wandert eine Glut dorthin
## (7.2); solange es offen ist, stehen über den Figuren die Ziffern der Schlagfolge (7.3, glut.gd vorschau). Bestätigt wird mit dem
## Tipp auf den Gegner oder „Angriff“; „Haltung“ (statt „Abwehr“, 7.5) legt alle Glut in die gewählte Haltung.
## Langes Drücken bleibt die Erklärung (536): der Tipp gilt erst beim Loslassen, und nur, wenn er kürzer war.

const Glut = preload("res://regeln/glut.gd")
const Figur = preload("res://kampf/figur.gd")

const KERN := Color(1.0, 0.62, 0.22)            # golden-orange (DESIGN-GLUT.md 8)
const HEISS := Color(1.0, 0.86, 0.55)
const SCHEIN := Color(1.0, 0.5, 0.12, 0.16)
const ASCHE := Color(0.36, 0.34, 0.31, 0.92)
const ZEICHEN := Color("#D9BC82")               # kampf_ui BRIGHT
const ZEICHEN_MATT := Color("#948A78")          # kampf_ui DIM
const RAND := Color(0.710, 0.604, 0.416, 0.67)  # kampf_ui RIM
const ZIFFER := Color("#E6DDCB")                # gebrochenes Weiß (DESIGN-AKTIONSPUNKTE.md „Bild“ 7)
const SPREIZ_GRAD := 17.0                       # Abstand der Glutstücke vor dem Fußring
const VOR_RING_M := 0.22                        # so weit vor dem Fußring (vorn steht das Dreieck der Ansage bis 0,5 m)
const FLAMMEN_MS := 380.0                       # Antwort: aufflammen, erlöschen
const FUNKEN_MS := 900.0                        # Verglimmen
const ZIEHT_MS := 380.0                         # Nachlegen: das Stück zieht zur Waffe
const GLIMMT_MS := 1900.0                       # danach glimmt die Waffe
const NACH := "nach"

var ui
## Plan des Zugs im Daumenmenü: offen, nachgelegt, Haltung; gilt für den Zug [fuer] (Kennung und Runde)
var offen := false
var nach := 0
var haltung := ""
var gewaehlt := false     # der Spieler hat am Daumen etwas geändert (sonst spielt der Vorschlag, 7.1)
var fuer := ""
var symbol_rects := {}    # Zeichen -> Rect2 des Daumenmenüs in diesem Bild
var flammen: Array = []   # [Kennung, Stück, Beginn]
var funken: Array = []    # [Welt, Beginn, Zufall]
var ziehen: Array = []    # [Kennung, Stück, Beginn]
var glimmen: Array = []   # [Figur, Beginn, Stufe, Material]
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
	if not m.glut or m.gk == null or k.busy or k.playing or m.outcome != "ONGOING" or k.ring_open or k.tor != "" or ui.pick != "main":
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


## Der Plan, den ein Tipp auf [ziel_id] spielt (glut.gd held_zug); ohne Änderung am Daumen die Haltung nach dem Vorschlag (AUTO)
func plan(f, ziel_id: String, tun := Glut.WAFFE) -> Dictionary:
	if not gewaehlt:
		return {"tun": tun, "ziel": ziel_id, "nachlegen": 0, "haltung": Glut.AUTO}
	return {"tun": tun, "ziel": ziel_id, "nachlegen": nach, "haltung": haltung}


## „Haltung“ (7.5, statt „Abwehr“): kein Tun, alle Glut in die gewählte Haltung (ohne Wahl: Wehr wie die alte Abwehr)
func plan_haltung(_f) -> Dictionary:
	return {"tun": Glut.WARTEN, "haltung": haltung if gewaehlt else Glut.WEHR}


## Glutstücke, wie sie der Spieler beim Planen sieht: das erste ins Tun, dann nachgelegt, der Rest in der Haltung
func _plan_marken(f) -> Array:
	var out := []
	var n := int(f.gl.glut)
	var rest: int = _m().gk.rest_nach_tun(f)
	var nl := mini(nach, rest)
	for i in n:
		if i < n - rest:
			out.append(Glut.M_TUN)
		elif i < n - rest + nl:
			out.append(Glut.M_NACH)
		else:
			out.append(Glut.M_HALT)
	return out


# ---------------------------------------------------------------- Meldungen (kampfort.gd _play_say)

## Die Meldung [e] wird gespielt; [vor] die Glut der vorigen: Antwort flammt auf, Haltung verglimmt, Nachlegen zieht zur Waffe
func meldung(vor: Dictionary, e: Dictionary) -> void:
	var neu: Dictionary = e.get("gl", {})
	var cue := String(e.get("cue")) if e.get("cue") != null else ""
	var t0 := _jetzt()
	for id in neu:
		var a: Array = (vor.get(id, {}) as Dictionary).get("m", [])
		var b: Array = neu[id].get("m", [])
		var fig = _k().figures.get(id)
		if fig == null:
			continue
		for i in mini(a.size(), b.size()):
			if a[i] == b[i]:
				continue
			if a[i] == Glut.M_HALT and b[i] == Glut.M_ASCHE:
				if cue == "GLUT_VERGLIMMT":
					for j in 7:
						funken.append([_stein(fig, i, a.size()), t0 + j * 40.0, randf()])
				else:
					flammen.append([id, i, t0])
			elif b[i] == Glut.M_NACH:
				ziehen.append([id, i, t0])
		if cue == "GLUT_NACHLEGEN" and String(e.get("actor")) == String(id):
			var n := b.count(Glut.M_NACH)
			_glimmen(fig, t0 + ZIEHT_MS, n)


func _glimmen(fig, ab: float, stufe: int) -> void:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.albedo_color = Color(KERN, 0.0)
	glimmen.append([fig, ab, stufe, mat])


func _waffe_meshes(fig) -> Array:
	if fig == null or not is_instance_valid(fig) or fig.model == null:
		return []
	var w = fig.model.find_child("Waffe", true, false)
	if w == null:
		return []
	return w.find_children("*", "MeshInstance3D", true, false)


# ---------------------------------------------------------------- Bild

## Ort des Glutstücks [i] von [n] am Fußring von [fig]: zur Kamera hin, nebeneinander
func _stein(fig, i: int, n: int) -> Vector3:
	var k = _k()
	var r := (0.75 if Figur.vier(fig.fighter) else 0.55) + VOR_RING_M
	var cam_l: Vector3 = k.to_local(k.cam.global_position) if k.cam != null else fig.position + Vector3(0, 0, 10)
	var d := Vector3(cam_l.x - fig.position.x, 0.0, cam_l.z - fig.position.z)
	d = d.normalized() if d.length() > 0.01 else Vector3(0, 0, 1)
	var a := deg_to_rad(SPREIZ_GRAD) * (float(i) - (n - 1) * 0.5)
	return fig.position + d.rotated(Vector3.UP, a) * r


var _oben: Array = []     # Glutstücke dieses Bilds für zeichnen_oben: [Bildpunkt, Art, Zeichen, Funke, Flamme, Flackern, Form]

## Je Bild aus kampf_ui._draw_overlay vor dem Bau der Ringe: der Schein der Glutstücke am Boden (kampf_ui._scheibe; Beine davor
## verdecken ihn), Funken, ziehende Glut, glimmende Waffe
func zeichnen(sr: Rect2) -> void:
	var k = _k()
	var m = _m()
	_oben.clear()
	if not m.glut or m.gk == null:
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
		for i in mk.size():
			_stein_zeichnen(fig, id, i, mk.size(), String(mk[i]), h, bool(gl[id].get("f", false)) and i == 3, t)
	_glimmen_pflegen(t)


## Danach (über den Dreiecken der Ansage): die Glutstücke selbst als glimmende Kohlen im Bild (am Boden flach gestaucht wären sie
## im Hochformat nur Punkte), ihre Zeichen, Funken, ziehende Glut, Daumenmenü und Vorschau
func zeichnen_oben(sr: Rect2) -> void:
	symbol_rects.clear()
	var m = _m()
	if not m.glut or m.gk == null:
		return
	var t := _jetzt()
	var o: CanvasItem = ui.overlay
	var dp: float = ui.dp
	for e in _oben:
		var s: Vector2 = e[0]
		var art: String = e[1]
		var flamme: float = e[4]
		if flamme >= 0.0:     # Antwort: lodert auf, erlischt
			var a := sin(PI * minf(flamme * 1.4, 1.0))
			o.draw_circle(s, (8.0 + 12.0 * a) * dp, Color(1.0, 0.55, 0.15, 0.35 * a))
			o.draw_circle(s, (4.0 + 2.5 * a) * dp, HEISS.lerp(Color.WHITE, a * 0.6))
			continue
		if art == Glut.M_ASCHE:
			o.draw_colored_polygon(_kohle(s, 3.6 * dp, e[6]), ASCHE)
			continue
		var fl: float = e[5]
		var funke: bool = e[3]
		o.draw_circle(s, 8.5 * dp, Color(1.0, 0.5, 0.12, 0.22 * fl * (1.4 if funke else 1.0)))
		o.draw_colored_polygon(_kohle(s, 4.6 * dp, e[6]), Color(0.18, 0.06, 0.02, 0.9))
		o.draw_colored_polygon(_kohle(s, 3.8 * dp, e[6]), Color(KERN.lerp(HEISS, 0.45 if funke else 0.0) * fl, 1.0))
		o.draw_circle(s + Vector2(-0.6, -0.6) * dp, 1.6 * dp, HEISS.lerp(Color.WHITE, 0.5 if funke else 0.15))
		if String(e[2]) != "":
			_zeichen(String(e[2]), s + Vector2(0, 15 * dp), 7.0 * dp, ZEICHEN, true)     # unter dem Stück: darüber steht das Dreieck
	_funken_zeichnen(t)
	_ziehen_zeichnen(t)
	var wer = waehlender()
	if wer != null:
		_menue(sr, wer)
		if offen:
			_vorschau(wer)


## Umriss eines Glutstücks: unregelmäßig rund, etwas breiter als hoch
func _kohle(c: Vector2, r: float, z: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for j in 9:
		var a := TAU * j / 9.0
		var rr := r * (0.82 + 0.18 * sin(a * 3.0 + z * 11.0))
		out.append(c + Vector2(cos(a) * rr * 1.15, sin(a) * rr * 0.85))
	return out


func _stein_zeichnen(fig, id: String, i: int, n: int, art: String, h: String, funke: bool, t: float) -> void:
	var p := _stein(fig, i, n)
	var flamme := -1.0
	for fl in flammen:
		if fl[0] == id and fl[1] == i and t - float(fl[2]) < FLAMMEN_MS:
			flamme = (t - float(fl[2])) / FLAMMEN_MS
	var zieht := false
	for z in ziehen:
		if z[0] == id and z[1] == i and t - float(z[2]) < ZIEHT_MS:
			zieht = true
	if art == Glut.M_ASCHE or zieht or ((art == Glut.M_NACH or art == Glut.M_TUN) and _k().busy):     # mit dem Befehl ausgegeben
		art = Glut.M_ASCHE
	var fl := 0.82 + 0.18 * sin(t / 1000.0 * 5.3 + i * 2.1) * sin(t / 1000.0 * 2.7 + i)
	if art != Glut.M_ASCHE or flamme >= 0.0:     # leiser Schein am Boden
		var a := sin(PI * minf(flamme * 1.4, 1.0)) if flamme >= 0.0 else 0.0
		ui._scheibe(p, 0.26 + 0.2 * a, Color(SCHEIN, SCHEIN.a * fl * (1.5 if funke else 1.0) + 0.2 * a))
	var zeichen := ""
	if art == Glut.M_HALT:
		zeichen = h
	elif art == Glut.M_NACH:
		zeichen = NACH
	_oben.append([_k().screen_of(p), art, zeichen, funke, flamme, fl, float(i) * 0.37 + float(id.hash() % 7)])


func _funken_zeichnen(t: float) -> void:
	var k = _k()
	var rest := []
	for f in funken:
		var q := (t - float(f[1])) / FUNKEN_MS
		if q >= 1.0:
			continue
		rest.append(f)
		if q < 0.0:
			continue
		var s: Vector2 = k.screen_of(f[0])
		var z: float = f[2]
		var at := s + Vector2((z - 0.5) * 22.0 * ui.dp + sin(q * 9.0 + z * 6.0) * 3.0 * ui.dp, -q * 46.0 * ui.dp)
		var a := (1.0 - q) * 0.9
		ui.overlay.draw_circle(at, 3.2 * ui.dp, Color(KERN, a * 0.25))
		ui.overlay.draw_circle(at, 1.3 * ui.dp, Color(HEISS, a))
	funken = rest


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
		ui.overlay.draw_circle(at, 6.0 * ui.dp, Color(KERN, 0.3))
		ui.overlay.draw_circle(at, 2.6 * ui.dp, HEISS)
	ziehen = rest


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


func _glimmen_pflegen(t: float) -> void:
	var rest := []
	for g in glimmen:
		var fig = g[0]
		var q := (t - float(g[1])) / GLIMMT_MS
		var mat: StandardMaterial3D = g[3]
		var ms := _waffe_meshes(fig)
		if q >= 1.0 or ms.is_empty():
			for mi in ms:
				if (mi as MeshInstance3D).material_overlay == mat:
					(mi as MeshInstance3D).material_overlay = null
			continue
		rest.append(g)
		var stark := 0.28 + 0.12 * float(int(g[2]) - 1)     # je Glut stärker
		var a := 0.0 if q < 0.0 else stark * (minf(q / 0.12, 1.0)) * (1.0 - maxf(0.0, (q - 0.6) / 0.4)) * (0.85 + 0.15 * sin(t / 70.0))
		mat.albedo_color = Color(KERN, a)
		for mi in ms:
			(mi as MeshInstance3D).material_overlay = mat
	glimmen = rest


## Ein Zeichen in der Größe [r] um [c]: Klinge, Pfeilspitze, Schild, Flamme (schwarz umrandet, damit es auf Gras und Stein steht)
func _zeichen(art: String, c: Vector2, r: float, col: Color, rand: bool) -> void:
	var o: CanvasItem = ui.overlay
	var w := maxf(1.0, r * 0.22)
	var pts: Array = []     # [Polylinie oder Fläche, ist Fläche]
	match art:
		Glut.GEGENSCHLAG:     # Klinge mit Parierstange
			pts.append([PackedVector2Array([c + Vector2(0, r), c + Vector2(0, -r)]), false])
			pts.append([PackedVector2Array([c + Vector2(-r * 0.5, r * 0.45), c + Vector2(r * 0.5, r * 0.45)]), false])
		Glut.WACHSCHUSS:     # Pfeilspitze am Schaft
			pts.append([PackedVector2Array([c + Vector2(0, -r), c + Vector2(r * 0.55, -r * 0.15), c + Vector2(-r * 0.55, -r * 0.15)]), true])
			pts.append([PackedVector2Array([c + Vector2(0, -r * 0.15), c + Vector2(0, r)]), false])
		Glut.WEHR:     # Schild
			pts.append([PackedVector2Array([c + Vector2(-r * 0.75, -r * 0.8), c + Vector2(r * 0.75, -r * 0.8), c + Vector2(r * 0.7, 0),
				c + Vector2(0, r), c + Vector2(-r * 0.7, 0)]), true])
		NACH:     # Flamme
			var fl := PackedVector2Array()
			for j in 13:
				var a := TAU * j / 12.0
				var rr := r * (0.62 + 0.38 * maxf(0.0, -sin(a)) * 1.15)
				fl.append(c + Vector2(cos(a) * r * 0.6, sin(a) * rr + r * 0.15) + Vector2(0, -maxf(0.0, -sin(a)) * r * 0.55))
			pts.append([fl, true])
	for pl in pts:
		var line: PackedVector2Array = pl[0]
		if pl[1]:
			if rand:
				var z := line.duplicate()
				z.append(line[0])
				o.draw_polyline(z, Color(0, 0, 0, 0.85), w + 2.0 * ui.dp, true)
			o.draw_colored_polygon(line, col)
		else:
			if rand:
				o.draw_polyline(line, Color(0, 0, 0, 0.85), w + 2.0 * ui.dp, true)
			o.draw_polyline(line, col, w, true)


## 7.2: das Daumenmenü rechts über den Schaltern Würfel und Raster, offen drei Zeichen, je Glut ein glimmender Punkt darunter
func _menue(sr: Rect2, f) -> void:
	var dp: float = ui.dp
	var unten := minf(sr.size.y, ui.overlay.get_viewport_rect().size.y - ui.panel_height())
	var x := sr.size.x - 4 * dp - 24 * dp
	var y := unten - 4 * dp - 44 * dp - 34 * dp
	var rest: int = _m().gk.rest_nach_tun(f)
	var arten: Array = [_m().gk.haltungen(f)[0], Glut.WEHR, NACH]
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
		for q in zahl:     # je Glut ein glimmender Punkt unter dem Zeichen
			var pc := c + Vector2((q - (zahl - 1) * 0.5) * 8 * dp, 14 * dp)
			ui.overlay.draw_circle(pc, 4.0 * dp, Color(KERN, 0.3))
			ui.overlay.draw_circle(pc, 2.2 * dp, KERN)
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
			k.order(["GLUT", plan(f, g.id)])
			return true
	return false


func _trifft(fig, p: Vector2) -> bool:
	var h: float = ui._tall(fig)
	var ft: Vector2 = ui._foot(fig)
	return Rect2(ft.x - h * 0.5, ft.y - h * 1.1, h, h * 1.2).has_point(p)


## 7.2: je Tipp auf ein Zeichen wandert eine Glut dorthin; eine Art der Haltung je Zug (Regel 7): ein Tipp auf die andere Haltung
## nimmt deren Art und eine Glut aus dem Nachlegen dazu; Nachlegen nimmt eine aus der Haltung, ist sie leer, fällt alles zurück
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
