class_name Gang
extends RefCounted
# 744 A (Chef 09.11., 11:18: „nicht wie auf Schienen laufen … nicht ständig laufen, 2 Sekunden maximal Pause, dann wieder drehen auf der
# Stelle wie so ein Roboter … mal verweilen, eine Ruheanimation haben“; 11:22 „744 A“: ein Bewegungsbaustein für alle Figuren):
# ein Gang über mehrere Kacheln als Bogen statt Gerade-Drehen-Gerade. Die Ecken zwischen zwei Schritten werden gerundet (Kurve von
# Kantenmitte zu Kantenmitte um die Kachelmitte), die Figur dreht im Gehen; sie läuft weich an und bremst länger, als sie anläuft
# (DESIGN-STIL D1). Dazu die Planung eines Streifgangs um den Heimplatz und die Dauer des Verweilens danach.
# Rein rechnerisch (Kachelmaß, ms), ohne Knoten: die Karte (streuner.gd) nutzt ihn, Leute (Tom) und Kampfort können ihn übernehmen.
# Alt: Game.kt 938–950 wander (alle 0,9–2,5 s ein Schritt oder eine Drehung auf der Stelle), Roamers.kt 79–93 Walker.step (Wende im
# Gehen bis 45°, darüber erst auf der Stelle; schräge Schritte bei den Leuten); übernommen: Wende bis 45° im Gehen, schräge Schritte,
# Heimradius 3; besser: Gänge von 2–5 Kacheln als Bogen, Anlauf und Bremsen, Verweilen von meist 3–12 s statt 0,9–2,5 s.

const ANLAUF_MS := 280.0          # weich anlaufen …
const BREMS_MS := 520.0           # … und länger bremsen (D1)
const PROBEN := 12                # Teilstücke je Kurvenstück für die Länge

## die acht Richtungen, im Uhrzeigersinn ab „nach unten“ (+y), Blick wie streuner.gd (atan2(x, y))
const RICHTUNGEN: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1)]

var kacheln: Array[Vector2i] = []
var start_ms := 0
var ms_je_kachel := 670.0
var laenge := 0.0                 # in Kacheln
var dauer_ms := 0.0
var _vmax := 0.0                  # Kacheln je ms
var _ta := ANLAUF_MS
var _td := BREMS_MS
var _stuecke: Array = []          # je Stück [a, c, b, laenge, s0]; eine Gerade hat c in der Mitte
# gekürzt (kuerze): ab _k_ms weich (kubisch) von _k_s mit _k_v zum Stand am neuen Ende
var _k_ms := -1.0
var _k_s := 0.0
var _k_v := 0.0


static func neu(weg: Array[Vector2i], ab_ms: int, ms_kachel: float) -> Gang:
	var g := Gang.new()
	g.kacheln = weg.duplicate()
	g.start_ms = ab_ms
	g.ms_je_kachel = maxf(1.0, ms_kachel)
	g._baue(weg.size())
	return g


func _p(i: int) -> Vector2: return Vector2(kacheln[i])


func _baue(n: int) -> void:
	_stuecke.clear()
	laenge = 0.0
	if n < 2:
		dauer_ms = 0.0
		return
	var m := func(i: int) -> Vector2: return (_p(i) + _p(i + 1)) * 0.5
	_stueck(_p(0), (_p(0) + m.call(0)) * 0.5, m.call(0))
	for i in range(1, n - 1):
		_stueck(m.call(i - 1), _p(i), m.call(i))
	_stueck(m.call(n - 2), (m.call(n - 2) + _p(n - 1)) * 0.5, _p(n - 1))
	var v := 1.0 / ms_je_kachel
	_ta = ANLAUF_MS
	_td = BREMS_MS
	if laenge >= v * (_ta + _td) * 0.5:
		_vmax = v
		dauer_ms = laenge / v + (_ta + _td) * 0.5
	else:
		_vmax = 2.0 * laenge / (_ta + _td)
		dauer_ms = _ta + _td


func _stueck(a: Vector2, c: Vector2, b: Vector2) -> void:
	var l := 0.0
	var vor := a
	for k in range(1, PROBEN + 1):
		var q := _bez(a, c, b, float(k) / PROBEN)
		l += vor.distance_to(q)
		vor = q
	_stuecke.append([a, c, b, l, laenge])
	laenge += l


static func _bez(a: Vector2, c: Vector2, b: Vector2, t: float) -> Vector2:
	var u := 1.0 - t
	return a * u * u + c * 2.0 * u * t + b * t * t


static func _bez_d(a: Vector2, c: Vector2, b: Vector2, t: float) -> Vector2:
	return (c - a) * 2.0 * (1.0 - t) + (b - c) * 2.0 * t


func ende_ms() -> int: return start_ms + int(ceil(dauer_ms))
func laeuft(jetzt: int) -> bool: return jetzt < ende_ms()


## zurückgelegter Weg in Kacheln zur Zeit jetzt
func weg_bei(jetzt: int) -> float:
	var t := clampf(float(jetzt - start_ms), 0.0, dauer_ms)
	if _k_ms >= 0.0 and t >= _k_ms:
		var dk := maxf(dauer_ms - _k_ms, 1.0)
		var u := (t - _k_ms) / dk
		return (2.0 * u * u * u - 3.0 * u * u + 1.0) * _k_s + (u * u * u - 2.0 * u * u + u) * dk * _k_v + (-2.0 * u * u * u + 3.0 * u * u) * laenge
	if t < _ta: return 0.5 * _vmax / _ta * t * t
	if t <= dauer_ms - _td: return 0.5 * _vmax * _ta + _vmax * (t - _ta)
	var r := dauer_ms - t
	return laenge - 0.5 * _vmax / _td * r * r


## Tempo zur Zeit jetzt als Anteil des vollen Gehens (0 … 1)
func tempo_bei(jetzt: int) -> float:
	var t := clampf(float(jetzt - start_ms), 0.0, dauer_ms)
	var v := 0.0
	if _k_ms >= 0.0 and t >= _k_ms:
		var dk := maxf(dauer_ms - _k_ms, 1.0)
		var u := (t - _k_ms) / dk
		v = ((6.0 * u * u - 6.0 * u) * _k_s + (3.0 * u * u - 4.0 * u + 1.0) * dk * _k_v + (-6.0 * u * u + 6.0 * u) * laenge) / dk
	elif t < _ta: v = _vmax * t / _ta
	elif t <= dauer_ms - _td: v = _vmax
	else: v = _vmax * (dauer_ms - t) / _td
	return clampf(v * ms_je_kachel, 0.0, 1.0)


func _stueck_bei(s: float) -> int:
	for i in _stuecke.size():
		if s < float(_stuecke[i][4]) + float(_stuecke[i][3]): return i
	return _stuecke.size() - 1


func _t_in(i: int, s: float) -> float:
	var st: Array = _stuecke[i]
	var ziel := s - float(st[4])
	# Länge entlang des Stücks ungefähr gleichmäßig in t (Teilstücke), fein genug für Bild und Schritt
	var l := 0.0
	var vor: Vector2 = st[0]
	for k in range(1, PROBEN + 1):
		var q := _bez(st[0], st[1], st[2], float(k) / PROBEN)
		var d := vor.distance_to(q)
		if l + d >= ziel: return (float(k - 1) + (ziel - l) / maxf(d, 0.0001)) / PROBEN
		l += d
		vor = q
	return 1.0


## Lage in Kachelmaß (Mitte der Kachel (x, y) = (x, y))
func lage(jetzt: int) -> Vector2:
	if _stuecke.is_empty(): return _p(0) if not kacheln.is_empty() else Vector2.ZERO
	var s := weg_bei(jetzt)
	var i := _stueck_bei(s)
	var st: Array = _stuecke[i]
	return _bez(st[0], st[1], st[2], _t_in(i, s))


## Blickwinkel entlang des Wegs (wie streuner.gd: atan2(x, y))
func blick_bei(jetzt: int) -> float:
	if _stuecke.is_empty(): return 0.0
	var s := minf(weg_bei(jetzt), laenge - 0.0001)
	var i := _stueck_bei(s)
	var st: Array = _stuecke[i]
	var d := _bez_d(st[0], st[1], st[2], _t_in(i, s))
	return atan2(d.x, d.y)


## auf welcher Kachel des Wegs die Figur gerade zählt: Wechsel an der Kantenmitte
func index_bei(jetzt: int) -> int:
	if _stuecke.is_empty(): return 0
	return mini(_stueck_bei(weg_bei(jetzt)), kacheln.size() - 1)


## früher aufhören (ein Jäger bemerkt den Helden): Ende auf der Mitte der nächsten Kachel, ohne Sprung, weich gebremst
func kuerze(jetzt: int) -> void:
	if not laeuft(jetzt) or _stuecke.is_empty(): return
	var s := weg_bei(jetzt)
	var v := tempo_bei(jetzt) / ms_je_kachel
	var i := _stueck_bei(s)
	var neu_n := i + 2
	if neu_n >= kacheln.size(): return
	var t := float(jetzt - start_ms)
	kacheln.resize(neu_n)
	# Stücke bis i bleiben, das letzte wird die Gerade von der Kantenmitte zur Mitte der neuen letzten Kachel
	_stuecke.resize(i + 1)
	laenge = float(_stuecke[i][4]) + float(_stuecke[i][3])
	var m := (_p(neu_n - 2) + _p(neu_n - 1)) * 0.5
	_stueck(m, (m + _p(neu_n - 1)) * 0.5, _p(neu_n - 1))
	_k_ms = t
	_k_s = s
	_k_v = v
	dauer_ms = t + (laenge - s) / maxf(_vmax, 0.0001) + _td * 0.5


## gleich nach dem Betreten einer Kachel: auf ihrer Mitte enden (die nächste ist belegt). Das Stück dieser Kachel wird zur Geraden
## von seiner Kantenmitte zur Mitte; ihr Anfang zeigt in dieselbe Richtung wie der Bogen, darum ohne Sprung und ohne Ruck im Blick.
func kuerze_hier(jetzt: int) -> void:
	if not laeuft(jetzt) or _stuecke.is_empty(): return
	var s := weg_bei(jetzt)
	var v := tempo_bei(jetzt) / ms_je_kachel
	var i := _stueck_bei(s)
	if i + 1 >= kacheln.size(): return
	var t := float(jetzt - start_ms)
	var a: Vector2 = _stuecke[i][0]
	kacheln.resize(i + 1)
	_stuecke.resize(i)
	laenge = float(_stuecke[i - 1][4]) + float(_stuecke[i - 1][3]) if i > 0 else 0.0
	_stueck(a, (a + _p(i)) * 0.5, _p(i))
	s = minf(s, laenge)
	_k_ms = t
	_k_s = s
	_k_v = v
	dauer_ms = t + (laenge - s) / maxf(_vmax, 0.0001) + _td * 0.5


## nächste Kachel, die der Gang betreten wird (für andere belegt), oder (-999, -999)
func naechste(jetzt: int) -> Vector2i:
	var i := index_bei(jetzt) + 1
	return kacheln[i] if laeuft(jetzt) and i < kacheln.size() else Vector2i(-999, -999)


# ---------------------------------------------------------------- Planung

static func richtung_nr(yaw: float) -> int:
	return posmod(roundi(yaw / (PI / 4.0)), 8)


## Streifgang um den Heimplatz: 2–5 Kacheln, meist geradeaus, sonst 45° zur Seite (dreht im Gehen), nie zurück über eigene Kacheln;
## schräg nur, wenn beide Nachbarn frei sind (keine Ecke abschneiden). Nur der erste Schritt darf weiter abweichen (dann wendet die
## Figur vorher auf der Stelle). frei: Callable(Vector2i) -> bool. Ergebnis mit Startkachel; weniger als 2 Kacheln = bleibt.
static func streife(von: Vector2i, yaw: float, heim: Vector2i, radius: int, frei: Callable, zufall: RandomNumberGenerator) -> Array[Vector2i]:
	var weg: Array[Vector2i] = [von]
	var n := zufall.randi_range(2, 5)
	var r := richtung_nr(yaw)
	for k in n:
		var w := zufall.randf()
		var reihe: Array = [0, 1, -1] if w < 0.5 else ([1, 0, -1] if w < 0.75 else [-1, 0, 1])
		if k == 0: reihe.append_array([2, -2, 3, -3, 4] if zufall.randf() < 0.5 else [-2, 2, -3, 3, 4])
		var ging := false
		for dr in reihe:
			var nr := posmod(r + int(dr), 8)
			var d: Vector2i = RICHTUNGEN[nr]
			var cur: Vector2i = weg[-1]
			var nk := cur + d
			if maxi(absi(nk.x - heim.x), absi(nk.y - heim.y)) > radius: continue
			if nk in weg or not frei.call(nk): continue
			if d.x != 0 and d.y != 0 and not (frei.call(cur + Vector2i(d.x, 0)) and frei.call(cur + Vector2i(0, d.y))): continue
			weg.append(nk)
			r = nr
			ging = true
			break
		if not ging: break
	return weg


## Weg heim (schräg erlaubt, um Hindernisse; aus karte.weg) bis zur ersten belegten Kachel, höchstens bis lang Kacheln
static func bis_belegt(weg: Array[Vector2i], frei: Callable, lang: int) -> Array[Vector2i]:
	var r: Array[Vector2i] = []
	for i in weg.size():
		if i > 0 and not frei.call(weg[i]): break
		r.append(weg[i])
		if r.size() > lang: break
	return r


## wie lange die Figur nach einem Gang verweilt (ms): meist 3–7 s, oft länger, selten kurz; nie der Takt von 0,9–2,5 s
static func verweile_ms(zufall: RandomNumberGenerator) -> int:
	var w := zufall.randf()
	if w < 0.55: return zufall.randi_range(3000, 7000)
	if w < 0.9: return zufall.randi_range(7000, 12000)
	return zufall.randi_range(1800, 3000)
