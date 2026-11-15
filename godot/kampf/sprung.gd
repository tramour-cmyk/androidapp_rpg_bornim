# 760 (Chef 09.11., 14:00; wiederholt 12.11., 20:09 und 15.11., 12:57: „ich werde angesprungen, aber sehe nichts davon. Also die
# Animation fehlt.“): der Kaufwolf hat keinen Sprung (Quelle: IdleA/B/C, Walk, Run, Attack, Eat, Howl, Die, alle auf der Stelle;
# kaufwolf.py legt „Sprung“ auf Attack), darum biss er bei „Anspringen“ im Stand. Hier entsteht für jedes Tier mit Wurzelweg, das
# keinen Sprungbiss der Quelle hat, die Bewegung „Sprungbiss“ aus dem, was es hat: ducken (Hocke), Absprung, gestreckter Flug (das
# Bild aus „Rennen“, in dem Vorder- und Hinterpfoten am weitesten auseinander sind), Biss so, dass er im Aufkommen zuschnappt, dann
# der Rest des Bisses. Dazu der Wurzelweg „Sprungbiss“ (figur.gd _weg_at dehnt ihn auf den Abstand zum Ziel) und die Flugbahn
# (hoehe, neigung), die figur.gd im Flug auf Ort und Modell legt.
extends RefCounted

## ducken vor dem Absprung (s)
const DUCK_S := 0.26
## Flug (s)
const FLUG_S := 0.5
## Weite (Welt, m), für die der Wurzelweg gebaut ist; figur.gd dehnt bis K_MAX und staucht bis 0,2
const SATZ_M := 2.4
const K_MAX := 1.9
## kleinster Satz (Welt, m, mal Maßstab der Figur): wer näher am Ziel steht, weicht im Ducken bis RUECK_M zurück
const KLEINST_M := 0.9
const RUECK_M := 0.45
## Scheitel der Flugbahn über dem Boden bei SATZ_M (m); wächst mit der Wurzel der Weite
const HOCH_M := 0.45
## so viel der Bahnneigung nimmt der Rumpf an (Schnauze im Steigen hoch, im Fallen aufs Ziel)
const NEIGUNG := 0.75
## Absprung: von der Hocke in die Streckung (s vor und nach dem Abheben)
const AB_VOR := 0.05
const AB_NACH := 0.12
## die Schnauze schnappt im Aufkommen: so lange vorher beginnt der Übergang in den Biss (s), so kurz vorher ist er ganz da
const BISS_VOR := 0.26
const BISS_DA := 0.05


## Baut „Sprungbiss“ in [lib] aus „Biss“, „Rennen“ (sonst „Gehen“) und „Hocke“ (sonst der Anfang des Bisses). [biss_t] Zeitpunkt des
## Zuschnappens in „Biss“ (s), [tempo_biss] Abspieltempo des Bisses, [sk] das Skelett (für das gestreckte Bild), [fps] Bilder je s
## des Wurzelwegs, [skala] Maßstab des Modells. Gibt {"weg": [[x, z] je Bild, Modellmeter], "biss_t": s, "laenge": s} oder {}.
static func bauen(lib: AnimationLibrary, sk: Skeleton3D, biss_t: float, tempo_biss: float, fps: float, skala: float) -> Dictionary:
	if lib == null or not lib.has_animation("Biss"):
		return {}
	var biss := lib.get_animation("Biss")
	var lauf := lib.get_animation("Rennen") if lib.has_animation("Rennen") else (lib.get_animation("Gehen") if lib.has_animation("Gehen") else biss)
	var hocke := lib.get_animation("Hocke") if lib.has_animation("Hocke") else biss
	var tb := maxf(tempo_biss, 0.1)
	biss_t = clampf(biss_t, 0.0, biss.length)
	var t_ab := DUCK_S
	var t_land := DUCK_S + FLUG_S
	var laenge := t_land + (biss.length - biss_t) / tb
	var t_str := _gestreckt(lauf, sk)
	# Spuren: alle aus Biss, dazu die aus Rennen und Hocke, die der Biss nicht hat
	var spur := {}     # Pfad:Art -> [Pfad, Art, Spur in Biss, in Rennen, in Hocke]
	var quellen := [biss, lauf, hocke]
	for q in quellen.size():
		var a: Animation = quellen[q]
		for t in a.get_track_count():
			var ty := a.track_get_type(t)
			if ty != Animation.TYPE_ROTATION_3D and ty != Animation.TYPE_POSITION_3D and ty != Animation.TYPE_SCALE_3D:
				continue
			var key := "%s|%d" % [a.track_get_path(t), ty]
			if not spur.has(key):
				spur[key] = [a.track_get_path(t), ty, -1, -1, -1]
			spur[key][2 + q] = t
	var an := Animation.new()
	an.length = laenge
	an.loop_mode = Animation.LOOP_NONE
	var n := int(ceil(laenge * 30.0))
	for key in spur:
		var e: Array = spur[key]
		var ty: int = e[1]
		var ti := an.add_track(ty)
		an.track_set_path(ti, e[0])
		an.track_set_interpolation_type(ti, Animation.INTERPOLATION_LINEAR)
		for i in n + 1:
			var t := minf(i / 30.0, laenge)
			# Biss: schnappt bei t_land zu; davor läuft er rückwärts gerechnet an, danach weiter bis zu seinem Ende
			var sb := clampf(biss_t - (t_land - t) * tb, 0.0, biss.length)
			var w_str := smoothstep(t_ab - AB_VOR, t_ab + AB_NACH, t)
			var w_biss := smoothstep(t_land - BISS_VOR, t_land - BISS_DA, t)
			# ohne Spur in einer Quelle gilt der Wert des Bisses, ohne Biss der der Quelle selbst
			var vb = _wert(biss, e[2], ty, sb)
			var vh = _wert(hocke, e[4], ty, 0.0)
			var vs = _wert(lauf, e[3], ty, t_str)
			if vb == null:
				vb = vs if vs != null else vh
			if vh == null:
				vh = vb
			if vs == null:
				vs = vb
			var v = _misch(_misch(vh, vs, w_str, ty), vb, w_biss, ty)
			match ty:
				Animation.TYPE_ROTATION_3D: an.rotation_track_insert_key(ti, t, v)
				Animation.TYPE_POSITION_3D: an.position_track_insert_key(ti, t, v)
				Animation.TYPE_SCALE_3D: an.scale_track_insert_key(ti, t, v)
	if lib.has_animation("Sprungbiss"):
		lib.remove_animation("Sprungbiss")
	lib.add_animation("Sprungbiss", an)
	# Wurzelweg: am Ort ducken, im Flug gleichmäßig (Wurf) bis SATZ_M, dann am Ort beißen
	var w := []
	for i in int(round(laenge * fps)) + 1:
		var s := clampf((i / fps - t_ab) / FLUG_S, 0.0, 1.0)
		w.append([0.0, SATZ_M / maxf(skala, 0.01) * s])
	return {"weg": w, "biss_t": t_land, "laenge": laenge}


## Anteil des Flugs (0 bis 1) zur Zeit [t] der Bewegung
static func flug(t: float) -> float:
	return clampf((t - DUCK_S) / FLUG_S, 0.0, 1.0)


## Anteil des Zurückweichens im Ducken (0 bis 1), bleibt danach (der Satz geht von dort aus)
static func zurueck(t: float) -> float:
	return smoothstep(0.0, DUCK_S * 0.85, t)


## Höhe über dem Boden (m) im Flug, [weite] des Satzes in der Welt (m)
static func hoehe(t: float, weite: float) -> float:
	var s := flug(t)
	return _scheitel(weite) * 4.0 * s * (1.0 - s)


## Neigung des Rumpfs um die Querachse (rad, +: Schnauze nach unten) aus der Steigung der Bahn
static func neigung(t: float, weite: float) -> float:
	var s := flug(t)
	if s <= 0.0 or s >= 1.0 or weite < 0.05:
		return 0.0
	# an Absprung und Aufkommen weich auf 0 (die Pfoten stehen dort am Boden)
	var rand := smoothstep(0.0, 0.18, s) * (1.0 - smoothstep(0.85, 1.0, s))
	return -atan2(_scheitel(weite) * 4.0 * (1.0 - 2.0 * s), weite) * NEIGUNG * rand


static func _scheitel(weite: float) -> float:
	return HOCH_M * sqrt(clampf(weite / SATZ_M, 0.15, K_MAX))


static func _wert(a: Animation, spur: int, ty: int, t: float):
	if spur < 0:
		return null
	match ty:
		Animation.TYPE_ROTATION_3D: return a.rotation_track_interpolate(spur, t)
		Animation.TYPE_POSITION_3D: return a.position_track_interpolate(spur, t)
		Animation.TYPE_SCALE_3D: return a.scale_track_interpolate(spur, t)
	return null


static func _misch(a, b, w: float, ty: int):
	if ty == Animation.TYPE_ROTATION_3D:
		return (a as Quaternion).slerp(b, w)
	return (a as Vector3).lerp(b, w)


## Zeit in [lauf] (s), zu der die Vorderpfoten am weitesten vor den Hinterpfoten sind (gestreckt im Galopp); ohne erkennbare Pfoten
## ein Viertel der Schleife
static func _gestreckt(lauf: Animation, sk: Skeleton3D) -> float:
	if sk == null:
		return lauf.length * 0.25
	var pf := []
	for nm in ["vpfoteL", "vpfoteR", "hpfoteL", "hpfoteR"]:
		pf.append(sk.find_bone(nm))
	if pf.has(-1):
		return lauf.length * 0.25
	var dreh := {}
	var ort := {}
	for t in lauf.get_track_count():
		var p := lauf.track_get_path(t)
		if p.get_subname_count() < 1:
			continue
		var b := sk.find_bone(String(p.get_subname(0)))
		if b < 0:
			continue
		if lauf.track_get_type(t) == Animation.TYPE_ROTATION_3D:
			dreh[b] = t
		elif lauf.track_get_type(t) == Animation.TYPE_POSITION_3D:
			ort[b] = t
	var best_t := 0.0
	var best := -INF
	var schritte := maxi(8, int(lauf.length * 30.0))
	for i in schritte:
		var t := lauf.length * i / schritte
		var g := {}
		var o := []
		for b in pf:
			o.append(_global(sk, b, t, lauf, dreh, ort, g).origin)
		var d: float = ((o[0] + o[1]) * 0.5).distance_to((o[2] + o[3]) * 0.5)
		if d > best:
			best = d
			best_t = t
	return best_t


static func _global(sk: Skeleton3D, b: int, t: float, a: Animation, dreh: Dictionary, ort: Dictionary, g: Dictionary) -> Transform3D:
	if g.has(b):
		return g[b]
	var r := sk.get_bone_rest(b)
	var q: Quaternion = a.rotation_track_interpolate(dreh[b], t) if dreh.has(b) else r.basis.get_rotation_quaternion()
	var p: Vector3 = a.position_track_interpolate(ort[b], t) if ort.has(b) else r.origin
	var x := Transform3D(Basis(q).scaled(r.basis.get_scale()), p)
	var e := sk.get_bone_parent(b)
	if e >= 0:
		x = _global(sk, e, t, a, dreh, ort, g) * x
	g[b] = x
	return x
