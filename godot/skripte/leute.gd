class_name Leute
extends Node3D
# 348.6 Leute: eine Person der Karte (karten.json „leute“, MapExport.kt) als Figur aus tools/blender348/v3 (held3.py FIGUR=<id>,
# rig.py: Gehen/Stehen, Gang je Figur), daten/leute/<id>.bin. Bewegt sich wie Game.updateWalkers ohne Tagesplan (VillageDay folgt):
# „streifen“ n: Schritt fuer Schritt um den eigenen Platz (Manhattan <= n), Pause 1,5–4 s; „runde“: Wache von Punkt zu Punkt,
# dort 2,5–5 s Umschauen, jedes zweite Mal laenger (55.1b). Steht der Held daneben, bleibt sie stehen; durch sie geht er nicht.

const TEMPO := 1.2                     # Gehen etwas flotter als gebacken; jede Figur in ihrem Takt (rig.py „gang“, Chef 17:03)
const LEIB := 0.45                     # Meter: so nah kommt der Held an die Koerpermitte

var karte: Karte
var daten: Dictionary
var held: Node3D
var modell: Node3D
var anim: AnimationPlayer
var gang := 1.08                       # m/s ohne Gleiten (held-info.json der Figur)
var mats: Array = []
var heim := Vector2i.ZERO
var kachel := Vector2i.ZERO
var ziel := Vector2i(-1, -1)           # Kachel, auf die sie gerade geht
var weg: Array[Vector2i] = []          # Runde: Weg zum naechsten Punkt
var bein := 0                          # Runde: Index des Punkts, zu dem sie geht (Walker.leg)
var warte := 0.0
var blick := 0.0
var zufall := RandomNumberGenerator.new()

static func alle(k: Karte, h: Node3D) -> Array:
	var r := []
	for d in k.daten.get("leute", []):
		if not FileAccess.file_exists("res://daten/leute/%s.bin" % d["id"]): continue
		var l := Leute.new(k, d, h)
		r.append(l)
	return r

# 348.6 Tiere zum Anschauen (Chef 25.10., 16:52: „temporaer ins Dorf stellen, muessen nicht kaempfen“): jedes Modell aus
# daten/tiere (Jerry: <name>.bin mit Stehen/Gehen, dazu <name>-info.json) streift um einen freien Platz nahe beim Helden
static func tiere(k: Karte, h: Node3D) -> Array:
	var r := []
	var namen: Array = []
	for f in DirAccess.get_files_at("res://daten/tiere"):
		if f.ends_with(".bin"): namen.append(f.get_basename())
	var mitte := k.pos_kachel(h.position)
	var frei: Array[Vector2i] = []
	for dy in range(-5, 6):
		for dx in range(-5, 6):
			var t := mitte + Vector2i(dx, dy)
			var m := absi(dx) + absi(dy)
			if m >= 3 and m <= 5 and k.begehbar(t) and k.ausgang(t).is_empty(): frei.append(t)
	for i in namen.size():
		if frei.is_empty(): break
		var t: Vector2i = frei.pop_at((i * 7919) % frei.size())
		r.append(Leute.new(k, {"id": namen[i], "x": t.x, "y": t.y, "blick": "DOWN", "streifen": 3, "datei": "res://daten/tiere/%s.bin" % namen[i]}, h))
	return r

func _init(k: Karte, d: Dictionary, h: Node3D) -> void:
	karte = k
	daten = d
	held = h
	name = "Leute_" + String(d["id"])
	heim = Vector2i(int(d["x"]), int(d["y"]))
	kachel = heim
	zufall.seed = hash(String(d["id"]))
	warte = zufall.randf_range(0.5, 3.0)

func _ready() -> void:
	var datei := String(daten.get("datei", "res://daten/leute/%s.bin" % daten["id"]))
	modell = Gebiet.lade_glb(datei)
	add_child(modell)
	Gebiet.male(modell, null, 2, mats)
	var p := datei.get_basename() + "-info.json"
	if FileAccess.file_exists(p):
		var info: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(p))
		gang = float(info.get("gehen_m_je_s", gang))
	anim = Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
	for n in ["Gehen", "Stehen"]:
		if anim and anim.has_animation(n): anim.get_animation(n).loop_mode = Animation.LOOP_LINEAR
	if anim:
		anim.play("Stehen")
		anim.seek(zufall.randf() * 2.0, true)   # nicht alle im selben Atemzug
	position = karte.kachel_pos(kachel)
	blick = {"UP": PI, "DOWN": 0.0, "LEFT": -PI / 2, "RIGHT": PI / 2}.get(String(daten.get("blick", "DOWN")), 0.0)
	rotation.y = blick

func nacht(k: float) -> void:
	for m in mats: (m as ShaderMaterial).set_shader_parameter("fill", 0.42 * (1.0 - k))

# fuer Held.frei: steht hier jemand?
func sperrt(p: Vector3) -> bool:
	return Vector2(p.x - position.x, p.z - position.z).length() < LEIB

func held_kachel() -> Vector2i:
	return karte.pos_kachel(held.position) if held else Vector2i(-99, -99)

func nah_am_held(t: Vector2i) -> bool:
	var h := held_kachel()
	return absi(t.x - h.x) + absi(t.y - h.y) <= 1

func frei_fuer_mich(t: Vector2i) -> bool:
	if not karte.begehbar(t) or not karte.ausgang(t).is_empty(): return false
	if t == held_kachel(): return false
	for l in get_parent().get_children():
		if l is Leute and l != self and (l.kachel == t or l.ziel == t): return false
	return true

func _process(dt: float) -> void:
	if ziel.x >= 0:
		laufe(dt)
		return
	if anim and anim.current_animation != "Stehen":
		anim.play("Stehen", 0.25)
		anim.speed_scale = 1.0
	rotation.y = lerp_angle(rotation.y, blick, minf(1.0, dt * 6.0))
	warte -= dt
	if warte > 0: return
	if nah_am_held(kachel):
		warte = 0.8
		return
	if daten.has("runde"): runde()
	else: streife()

func streife() -> void:
	warte = zufall.randf_range(1.5, 4.0)
	var d := Vector2i(zufall.randi_range(-1, 1), zufall.randi_range(-1, 1))
	if d == Vector2i.ZERO: return
	var n := kachel + d
	if absi(n.x - heim.x) + absi(n.y - heim.y) > int(daten.get("streifen", 0)): return
	if not frei_fuer_mich(n): return
	if d.x != 0 and d.y != 0 and not (karte.begehbar(kachel + Vector2i(d.x, 0)) and karte.begehbar(kachel + Vector2i(0, d.y))): return
	ziel = n

func runde() -> void:
	var r: Array = daten["runde"]
	var p := Vector2i(int(r[bein][0]), int(r[bein][1]))
	if kachel == p:
		# angekommen: umschauen, dann zum naechsten Punkt; jedes zweite Mal laenger (55.1b), zur Strasse oder ins Dorf
		bein = (bein + 1) % r.size()
		var lang := zufall.randf() < 0.5
		blick = [0.0, -PI / 2, PI / 2][zufall.randi_range(0, 2)] if lang else [PI, 0.0, -PI / 2, PI / 2][zufall.randi_range(0, 3)]
		warte = zufall.randf_range(10.0, 16.0) if lang else zufall.randf_range(2.5, 5.0)
		weg.clear()
		return
	if weg.is_empty() or weg[weg.size() - 1] != p:
		weg = karte.weg(kachel, p)
		if not weg.is_empty(): weg.pop_front()
	if weg.is_empty():
		warte = 1.0
		return
	if not frei_fuer_mich(weg[0]):
		warte = 0.5
		return
	ziel = weg.pop_front()

func laufe(dt: float) -> void:
	var zp := karte.kachel_pos(ziel)
	var to := zp - position
	to.y = 0
	var tempo := gang * TEMPO / karte.schritt(ziel)
	var s := tempo * dt
	if to.length() <= s:
		position = Vector3(zp.x, position.y, zp.z)
		kachel = ziel
		ziel = Vector2i(-1, -1)
		blick = rotation.y
		# auf der Runde ohne Halt zur naechsten Kachel
		if daten.has("runde"): warte = 0.0
		return
	position += to.normalized() * s
	rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), minf(1.0, dt * 10.0))
	kachel = karte.pos_kachel(position)
	if anim:
		if anim.current_animation != "Gehen": anim.play("Gehen", 0.18)
		anim.speed_scale = tempo / gang
