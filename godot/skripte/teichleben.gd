class_name Teichleben
extends Node3D
# 509 (Chef 03.11., 09:21: „Frösche und Libellen im … Flüsterwald [fehlen]“; Orte O6, Welt W22): Leben am Waldteich wie alt
# (PondLife.kt 27.6, Klang PondSound.kt 27j, Zeichnung WorldScreen.drawPondLife). Libellen stehen über dem offenen Wasser in der
# Luft, schießen in einem Bruchteil einer Sekunde an eine neue Stelle und stehen wieder; nur bei Tag. Frösche sitzen am Ufer und
# atmen, blähen ab und zu die Kehle (in der Dämmerung öfter), drehen sich manchmal um; kommt der Held näher als SCHEU, springen
# sie ins Wasser (Ringe), und wenn er weiter als ZURUECK fort ist und einige Sekunden vergangen sind, tauchen die Augen auf, sie
# schwimmen zum Ufer und hüpfen hinaus. Höchstens drei Frösche und zwei Libellen je Karte, die Plätze aus dem Ufer der Bodenmaske
# (Alpha = Wasserfeld wie MapGround.water, dorf.py wfield), also ohne Handarbeit für jeden Teich. Klang: der Ruf, wenn die Kehle
# schwillt, lauter je näher; das Schwirren einer Libelle, die nah vorbeischießt; in der Dämmerung der leise Chor (Klang.teich_chor).
# Maße: alt WorldArt.T = 32 Bildpunkte je Kachel, hier Karte.TS Meter; Abstände und Zeiten wie alt, die Tiere etwas kleiner
# als alt gezeichnet (alt ein Frosch 10 Bildpunkte = 0,36 m), doch groß genug, dass man sie aus der Spielkamera sieht.

const PX := Karte.TS / 32.0           # ein alter Kartenbildpunkt in Metern
const SCHEU := 44.0 * PX              # PondLife.SHY
const ZURUECK := 90.0 * PX            # PondLife.BACK
const SPRUNG_MS := 380                # LEAP
const SCHWIMM_MS := 1800              # SWIM
const RUF_MS := 3100                  # CROAK_MS
const SPIEGEL := -0.10                # Wasserspiegel (dorf.py vh: bei w = 0,5)
const GROESSE := 1.0                  # Frosch: etwa 0,2 m lang (alt gezeichnet 0,36 m); Libelle 0,13 m Leib, 0,2 m Spanne
# PondSound.kt, in Kacheln
const FROSCH_WEIT := 7.0
const FROSCH_NAH := 1.5
const FROSCH_MAX := 0.4
const LIBELLE_WEIT := 2.5
const LIBELLE_MAX := 0.2
const CHOR_WEIT := 8.0
const CHOR_NAH := 2.0
const CHOR_MAX := 0.14

enum { SITZT, SPRINGT, UNTER, AUFTAUCHEN, SCHWIMMT, KLETTERT }

var karte: Karte
var maske: Image
var held: Node3D                      # wer die Frösche scheucht und wer hört (gebiet.held)
var nacht_k := 0.0                    # gebiet.nacht: 0 Tag, 1 Nacht
var froesche: Array = []              # je Frosch ein Dictionary (siehe _frosch)
var libellen: Array = []
var uhr := 0                          # ms seit dem Bau (alt: clock)
var _chor := 0.0
var _hoeren := true                   # Tests: ohne Klang

# ---------------------------------------------------------------- Bau

static func baue(k: Karte, m: Image, h: Node3D) -> Teichleben:
	var t := Teichleben.new()
	t.name = "Teichleben"
	t.karte = k; t.maske = m; t.held = h
	t.finde()
	return t

## Wasserfeld an der Stelle (Meter, x nach Osten, z nach Süden): Alpha der Bodenmaske, 16 Bildpunkte je Kachel, weich dazwischen
func w(x: float, z: float) -> float:
	var u := x / Karte.TS * 16.0 - 0.5; var v := z / Karte.TS * 16.0 - 0.5
	var i := floori(u); var j := floori(v)
	var fu := u - i; var fv := v - j
	var a := _a(i, j) * (1 - fu) + _a(i + 1, j) * fu
	var b := _a(i, j + 1) * (1 - fu) + _a(i + 1, j + 1) * fu
	return a * (1 - fv) + b * fv

func _a(i: int, j: int) -> float:
	return maske.get_pixel(clampi(i, 0, maske.get_width() - 1), clampi(j, 0, maske.get_height() - 1)).a

## Höhe des Bodens (dorf.py vh: Böschung zum Flussbett, -34 cm)
func boden(x: float, z: float) -> float:
	return -0.34 * smoothstep(0.4, 0.66, w(x, z))

## PondLife.find: Ufer in Schritten von 4 alten Bildpunkten um jedes Wasserfeld, Frösche mit Sprungziel 14 Bildpunkte ins Wasser,
## Libellen über tiefem Wasser mit ihrem Stück Wasser (26 Bildpunkte)
func finde() -> void:
	var nah := {}
	for r in karte.hoehe:
		for c in karte.breite:
			if karte.zeichen(Vector2i(c, r)) != "~": continue
			for dr in range(-1, 2):
				for dc in range(-1, 2): nah[Vector2i(c + dc, r + dr)] = true
	if nah.is_empty(): return
	var ufer: Array = []
	var tief: Array[Vector2] = []
	var schritt := 4.0 * PX
	for t: Vector2i in nah:
		for sy in 8:
			for sx in 8:
				var x := t.x * Karte.TS + sx * schritt; var z := t.y * Karte.TS + sy * schritt
				var hier := w(x, z)
				var zch := karte.zeichen(t)
				if hier > 0.68: tief.append(Vector2(x, z))
				if hier >= 0.36 and hier <= 0.47 and zch != "T" and zch != "~":
					var e := 3.0 * PX
					var g := Vector2(w(x + e, z) - w(x - e, z), w(x, z + e) - w(x, z - e))
					if g.length() > 1e-4:
						var ziel := Vector2(x, z) + g.normalized() * 14.0 * PX
						if w(ziel.x, ziel.y) > 0.58:
							ufer.append([Vector2(x, z), ziel, mische(roundi(x / PX), roundi(z / PX), 41)])
	ufer.sort_custom(func(a, b): return int(a[2]) < int(b[2]))
	for f in ufer:
		if froesche.size() >= 3: break
		if froesche.all(func(o): return (o["ufer"] as Vector2).distance_to(f[0]) > 40.0 * PX): froesche.append(_frosch(f[0], f[1], int(f[2])))
	tief.sort_custom(func(a, b): return mische(roundi(a.x / PX), roundi(a.y / PX), 43) < mische(roundi(b.x / PX), roundi(b.y / PX), 43))
	var n := 0
	for p in tief:
		if libellen.size() >= 2: break
		var i := n; n += 1
		if libellen.any(func(o): return (o["c"] as Vector2).distance_to(p) < 44.0 * PX): continue
		var stellen := tief.filter(func(q): return q.distance_to(p) < 26.0 * PX)
		if stellen.size() < 4: continue
		var s := mische(roundi(p.x / PX), roundi(p.y / PX), 44) % 5000
		libellen.append(_libelle(p, s, i % 2 == 1 or libellen.size() == 1, stellen))

## Kotlin-Int wie PondLife.hash (32 Bit mit Überlauf)
static func _i32(n: int) -> int:
	n &= 0xFFFFFFFF
	return n - 0x100000000 if n >= 0x80000000 else n

static func mische(a: int, b: int, c := 0) -> int:
	var n := _i32(a * 374761393 + b * 668265263 + c * 1442695041)
	n = _i32((n ^ ((n & 0xFFFFFFFF) >> 13)) * 1274126177)
	return (n ^ ((n & 0xFFFFFFFF) >> 16)) & 0x7fffffff

# ---------------------------------------------------------------- Gestalt

static var _farben := {}
static func _tex(c: Color) -> ImageTexture:
	var k := c.to_html()
	if not _farben.has(k):
		var img := Image.create(2, 2, false, Image.FORMAT_RGBA8)
		img.fill(c)
		_farben[k] = ImageTexture.create_from_image(img)
	return _farben[k]

## Toon wie die Büsche (gebiet.gd male: Tusche im Zeichner nach dem Licht, Schablone 1 ohne Bildschirmlinie, sonst wird ein
## Frosch von 22 cm zum schwarzen Fleck)
func _toon(c: Color) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = Gebiet.toon_mark(1)
	m.set_shader_parameter("tex", _tex(c))
	m.set_shader_parameter("kontur", 1.0)
	m.set_shader_parameter("licht_dir", Licht.richtung())
	Licht.nach_licht.append(m)
	return m

func _kugel(an: Node3D, r: float, pos: Vector3, mass: Vector3, c: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new(); sm.radius = r * GROESSE; sm.height = 2 * r * GROESSE; sm.radial_segments = 12; sm.rings = 6
	mi.mesh = sm
	mi.material_override = _toon(c)
	mi.position = pos * GROESSE
	mi.scale = mass
	an.add_child(mi)
	return mi

func _ring(an: Node3D) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var tm := TorusMesh.new(); tm.inner_radius = 0.92; tm.outer_radius = 1.0; tm.rings = 24; tm.ring_segments = 3
	mi.mesh = tm
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(0.72, 0.77, 0.74, 0.0)   # alt 0xFFB8C4BC
	m.render_priority = 1
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.visible = false
	an.add_child(mi)
	return mi

## Ein Frosch (Farben wie drawPondLife): Rücken oliv, heller Rückenstreif, Kehle fahl, Schenkel dunkel; Nase nach +z
func _frosch(ufer: Vector2, wasser: Vector2, saat: int) -> Dictionary:
	var rumpf := Color("4c5530"); var oben := Color("65703e"); var bauch := Color("9a9468"); var dunkel := Color("22261a"); var auge := Color("b09a48")
	var n := Node3D.new()
	var k := Node3D.new()                     # Körper: atmet, streckt sich im Sprung
	n.add_child(k)
	var teile := {}
	teile["schenkel_l"] = _kugel(k, 0.035, Vector3(-0.05, 0.025, -0.045), Vector3(0.75, 0.6, 1.3), dunkel)
	teile["schenkel_r"] = _kugel(k, 0.035, Vector3(0.05, 0.025, -0.045), Vector3(0.75, 0.6, 1.3), dunkel)
	teile["leib"] = _kugel(k, 0.06, Vector3(0, 0.035, -0.01), Vector3(1.0, 0.62, 1.3), rumpf)
	teile["streif"] = _kugel(k, 0.04, Vector3(0, 0.058, -0.015), Vector3(0.7, 0.35, 1.25), oben)
	teile["kopf"] = _kugel(k, 0.042, Vector3(0, 0.04, 0.068), Vector3(1.1, 0.68, 1.0), rumpf)
	var kehle := _kugel(k, 0.028, Vector3(0, 0.02, 0.074), Vector3(1.1, 0.6, 0.9), bauch)
	for s in [-1, 1]:
		_kugel(k, 0.015, Vector3(0.024 * s, 0.066, 0.078), Vector3.ONE, auge)
		_kugel(k, 0.008, Vector3(0.033 * s, 0.07, 0.083), Vector3.ONE, dunkel)
		_kugel(k, 0.012, Vector3(0.032 * s, 0.006, 0.058), Vector3(1, 0.5, 1.3), dunkel)
	add_child(n)
	var r1 := _ring(self); var r2 := _ring(self)
	return {"ufer": ufer, "wasser": wasser, "saat": saat, "lage": SITZT, "seit": -1, "n": n, "k": k, "kehle": kehle,
		"teile": teile, "ringe": [r1, r2], "slot": -1}

## Eine Libelle: schlanker Leib, Kopf dunkler, vier schmale Flügel, die mehr flimmern als Form zeigen (drawPondLife)
func _libelle(c: Vector2, saat: int, dunkel: bool, stellen: Array) -> Dictionary:
	var n := Node3D.new()
	var leib := MeshInstance3D.new()
	var cm := CapsuleMesh.new(); cm.radius = 0.009; cm.height = 0.13; cm.radial_segments = 8; cm.rings = 2
	leib.mesh = cm
	leib.rotation_degrees = Vector3(90, 0, 0)
	leib.material_override = _toon(Color("3c5a64") if dunkel else Color("6a5e36"))
	n.add_child(leib)
	var kopf := MeshInstance3D.new()
	var sm := SphereMesh.new(); sm.radius = 0.013; sm.height = 0.026; sm.radial_segments = 8; sm.rings = 4
	kopf.mesh = sm
	kopf.position = Vector3(0, 0, 0.066)
	kopf.material_override = _toon(Color("2a3e46") if dunkel else Color("4a4026"))
	n.add_child(kopf)
	var fm := StandardMaterial3D.new()
	fm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fm.cull_mode = BaseMaterial3D.CULL_DISABLED
	fm.albedo_color = Color(0.85, 0.89, 0.9, 0.35)
	fm.render_priority = 1
	var fluegel: Array = []
	for s in [-1, 1]:
		for paar in [[0.35, 0.085, 0.02], [-0.3, 0.078, 0.0]]:   # vorn nach vorn gefegt, hinten nach hinten; Länge; Ansatz
			var piv := Node3D.new()
			piv.position = Vector3(0, 0.004, float(paar[2]))
			piv.rotation.y = float(paar[0]) * s
			var f := MeshInstance3D.new()
			var qm := QuadMesh.new(); qm.size = Vector2(float(paar[1]), 0.016)
			f.mesh = qm; f.material_override = fm
			f.rotation_degrees = Vector3(-90, 0, 0)
			f.position = Vector3(float(paar[1]) / 2 * s, 0, 0)
			f.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			piv.add_child(f)
			n.add_child(piv)
			fluegel.append([piv, s])
	add_child(n)
	return {"c": c, "saat": saat, "periode": 2600 + saat % 1700, "stellen": stellen, "n": n, "fluegel": fluegel, "fm": fm, "dash": -1}

# ---------------------------------------------------------------- Lauf

func _process(dt: float) -> void:
	schritt(int(dt * 1000.0))

## Ein Schritt der Uhr um [ms]; gibt die Klänge zurück, die jetzt einsetzen ([id, Pegel]), für Tests
func schritt(ms: int) -> Array:
	uhr += ms
	var hp := _held_pos()
	var daemmerung := nacht_k > 0.45          # alt: daylight < 0.55
	var fliegen := nacht_k < 0.6              # alt: daylight > 0.4 und kein Regen (Regen gibt es in Godot noch nicht)
	var klaenge: Array = []
	for f in froesche: _frosch_schritt(f, hp, daemmerung, klaenge)
	for l in libellen: _libelle_schritt(l, hp, fliegen, klaenge)
	_klang(klaenge, hp, daemmerung, ms)
	return klaenge

func _held_pos() -> Vector2:
	if held == null or not is_instance_valid(held): return Vector2(-1e6, -1e6)
	var p := held.global_position if held.is_inside_tree() else held.position
	return Vector2(p.x, p.z)

func ruft(saat: int, slot: int, daemmerung: bool) -> bool:
	return mische(slot, saat, 5) % (2 if daemmerung else 7) == 0

func _frosch_schritt(f: Dictionary, hp: Vector2, daemmerung: bool, klaenge: Array) -> void:
	var ufer: Vector2 = f["ufer"]; var wasser: Vector2 = f["wasser"]; var saat: int = f["saat"]
	if int(f["seit"]) < 0: f["seit"] = uhr
	var nah := hp.distance_to(ufer)
	var lage: int = f["lage"]; var seit: int = f["seit"]
	match lage:
		SITZT:
			if nah < SCHEU:
				lage = SPRINGT; seit = uhr
		SPRINGT:
			if uhr - seit > SPRUNG_MS:
				lage = UNTER; seit += SPRUNG_MS
		UNTER:
			if uhr - seit > 8000 and nah > ZURUECK:
				lage = AUFTAUCHEN; seit = uhr
		AUFTAUCHEN:
			if nah < SCHEU:
				lage = UNTER; seit = uhr
			elif uhr - seit > 2200:
				lage = SCHWIMMT; seit += 2200
		SCHWIMMT:
			if nah < SCHEU:
				lage = UNTER; seit = uhr
			elif uhr - seit > SCHWIMM_MS:
				lage = KLETTERT; seit += SCHWIMM_MS
		KLETTERT:
			if uhr - seit > SPRUNG_MS:
				lage = SITZT; seit += SPRUNG_MS
	f["lage"] = lage; f["seit"] = seit
	var dt := uhr - seit
	var zum_wasser := (wasser - ufer).normalized()
	var dreh_slot := floori((uhr + saat * 211) / 17000.0)
	var blick := -zum_wasser if mische(dreh_slot, saat, 9) % 3 == 0 else zum_wasser
	var n: Node3D = f["n"]; var k: Node3D = f["k"]; var kehle: Node3D = f["kehle"]
	var r1: MeshInstance3D = f["ringe"][0]; var r2: MeshInstance3D = f["ringe"][1]
	r1.visible = false; r2.visible = false
	n.visible = true
	k.scale = Vector3.ONE
	var pos := ufer; var hub := 0.0; var richtung := zum_wasser
	# Ruf: die Kehle schwillt zu Beginn eines Rufs; nur im Sitzen (PondSound.Ear)
	var slot := floori((uhr + saat * 97) / float(RUF_MS))
	var neu_slot: bool = int(f["slot"]) >= 0 and slot != int(f["slot"])
	f["slot"] = slot
	match lage:
		SITZT:
			var atem := 0.5 + 0.5 * sin(uhr / 260.0 + saat)
			var cu := fposmod(uhr + saat * 97, RUF_MS) / float(RUF_MS)
			var schwill := sin(cu / 0.35 * PI) if ruft(saat, slot, daemmerung) and cu < 0.35 else 0.0
			var kv := 0.3 * atem + schwill
			kehle.scale = Vector3(1.1, 0.6 + 0.45 * kv, 0.9 + 0.2 * kv)
			k.scale = Vector3(1.0, 1.0 + 0.03 * atem, 1.0)
			richtung = blick
			if neu_slot and ruft(saat, slot, daemmerung):
				var v := _pegel(hp.distance_to(ufer) / Karte.TS, FROSCH_WEIT, FROSCH_NAH, FROSCH_MAX)
				if v > 0.01: klaenge.append(["frog", v])
		SPRINGT:
			var u := dt / float(SPRUNG_MS)
			pos = ufer.lerp(wasser, u); hub = 7.0 * PX * sin(u * PI)
			k.scale = Vector3(0.9, 0.85, 1.35)
		UNTER:
			n.visible = false
			pos = wasser
			_ringe(r1, r2, wasser, dt / 1600.0, false)
		AUFTAUCHEN, SCHWIMMT:
			richtung = -zum_wasser
			var ziel := ufer + (wasser - ufer) * 0.35
			if lage == SCHWIMMT:
				var u := clampf(dt / float(SCHWIMM_MS), 0, 1); u = u * u * (3 - 2 * u)
				pos = wasser.lerp(ziel, u)
			else: pos = wasser
			_ringe(r1, r2, pos, fmod(dt / 900.0, 1.0), true)
		KLETTERT:
			var u := dt / float(SPRUNG_MS)
			var von := ufer + (wasser - ufer) * 0.35
			pos = von.lerp(ufer, u); hub = 4.0 * PX * sin(u * PI)
			richtung = -zum_wasser
			k.scale = Vector3(0.95, 0.9, 1.2)
	var y := boden(pos.x, pos.y)
	if lage == AUFTAUCHEN or lage == SCHWIMMT: y = SPIEGEL - 0.05 * GROESSE   # nur Augen und Kopfdach über dem Wasser
	else: y = maxf(y, SPIEGEL) if lage != SITZT else y
	n.position = Vector3(pos.x, y + hub, pos.y)
	n.rotation.y = atan2(richtung.x, richtung.y)

## alt: zwei flache Ringe, doppelt so breit wie hoch auf dem Bildschirm, hier waagrecht auf dem Wasser
func _ringe(r1: MeshInstance3D, r2: MeshInstance3D, p: Vector2, ring: float, schwimmt: bool) -> void:
	var paare := [[r1, 2.0 + ring * (5.0 if schwimmt else 9.0), (0.35 if schwimmt else 0.55) * (1.0 - ring)]]
	if not schwimmt: paare.append([r2, 1.0 + ring * 5.0, 0.4 * (1.0 - ring * 1.4)])
	for e in paare:
		var mi: MeshInstance3D = e[0]
		var a := clampf(float(e[2]), 0, 1)
		if a <= 0.01: continue
		var r := float(e[1]) * PX
		mi.visible = true
		mi.position = Vector3(p.x, SPIEGEL + 0.005, p.y)
		mi.scale = Vector3(r, 0.02, r)
		(mi.material_override as StandardMaterial3D).albedo_color.a = a * (1.0 - 0.6 * nacht_k)

func _libelle_schritt(l: Dictionary, hp: Vector2, fliegen: bool, klaenge: Array) -> void:
	var n: Node3D = l["n"]
	n.visible = fliegen
	var saat: int = l["saat"]; var periode: int = l["periode"]
	var c := uhr + saat * 37
	var i := floori(c / float(periode))
	var u := fposmod(c, periode) / float(periode)
	var stellen: Array = l["stellen"]
	var a: Vector2 = stellen[posmod(mische(i - 1, saat), stellen.size())]
	var b: Vector2 = stellen[posmod(mische(i, saat), stellen.size())]
	const SCHUSS := 0.18
	var k := 1.0
	if u < SCHUSS: k = u / SCHUSS; k = k * k * (3 - 2 * k)
	var t := uhr / 1000.0
	var zittern := 0.0 if u < SCHUSS else 0.6 * PX
	var p := a.lerp(b, k) + Vector2(sin(t * 7.3 + saat) * zittern, cos(t * 5.9 + saat) * zittern * 0.6)
	var h := (11.0 + 2.5 * sin(t * 1.3 + saat) + (3.0 * sin(u / SCHUSS * PI) if u < SCHUSS else 0.0)) * PX
	var d := b - a
	if d.length() < PX: d = Vector2(1, 0)
	var dreh := 0.0
	if u > 0.55 and mische(i, saat, 3) % 3 == 0: dreh = 0.8 * clampf((u - 0.55) / 0.45, 0, 1)
	d = d.normalized().rotated(dreh)
	n.position = Vector3(p.x, SPIEGEL + h, p.y)
	n.rotation.y = atan2(d.x, d.y)
	var schlag := floori(uhr / 28.0) % 2 == 1
	(l["fm"] as StandardMaterial3D).albedo_color.a = (0.35 if schlag else 0.2) * (1.0 - 0.5 * nacht_k)
	for f in l["fluegel"]: (f[0] as Node3D).rotation.z = (0.25 if schlag else -0.1) * float(f[1])
	# das Schwirren, wenn sie nah an eine neue Stelle schießt (PondSound.Ear: Lage 300 ms später)
	var war: int = l["dash"]
	l["dash"] = i
	if war >= 0 and i != war and fliegen:
		var j := floori((c + 300) / float(periode))
		var ziel: Vector2 = stellen[posmod(mische(j, saat), stellen.size())]
		var v := _pegel(hp.distance_to(ziel) / Karte.TS, LIBELLE_WEIT, 0.5, LIBELLE_MAX)
		if v > 0.01: klaenge.append(["dragonfly", v])

static func _pegel(kacheln: float, weit: float, nah: float, hoechst: float) -> float:
	if kacheln >= weit: return 0.0
	var t := clampf((weit - kacheln) / (weit - nah), 0.0, 1.0)
	return hoechst * t * t * (3.0 - 2.0 * t)

## PondSound.chorusTarget: in der Dämmerung vom nächsten sitzenden Frosch
func chor_ziel(hp: Vector2, daemmerung: bool) -> float:
	if not daemmerung: return 0.0
	var d := INF
	for f in froesche:
		if int(f["lage"]) == SITZT: d = minf(d, hp.distance_to(f["ufer"]) / Karte.TS)
	return 0.0 if d == INF else _pegel(d, CHOR_WEIT, CHOR_NAH, CHOR_MAX)

func _klang(klaenge: Array, hp: Vector2, daemmerung: bool, ms: int) -> void:
	if not _hoeren or not is_inside_tree(): return
	var kl := get_node_or_null("/root/Klang")
	if kl == null: return
	var ruhig: bool = kl.ruhig()
	if ruhig:
		for e in klaenge: kl.effekt(String(e[0]), float(e[1]))
	kl.teich_chor(chor_ziel(hp, daemmerung) if ruhig else 0.0, CHOR_MAX, float(ms))
