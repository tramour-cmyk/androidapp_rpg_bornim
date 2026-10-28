class_name Leute
extends Node3D
# 348.6 Leute: eine Person der Karte (karten.json „leute“, MapExport.kt) als Figur aus tools/blender348/v3 (held3.py FIGUR=<id>,
# rig.py: Gehen/Stehen, Gang je Figur), daten/leute/<id>.bin. Bewegt sich wie Game.updateWalkers; 390 mit Tagesplan (VillageDay,
# karten.json „tagesablauf“): zur vollen Stunde zum naechsten Ort ihres Tages, dort streifen; nachts an der eigenen Tuer hinein.
# „streifen“ n: Schritt fuer Schritt um den eigenen Platz (Manhattan <= n), Pause 1,5–4 s; „runde“: Wache von Punkt zu Punkt,
# dort 2,5–5 s Umschauen, jedes zweite Mal laenger (55.1b). Steht der Held daneben, bleibt sie stehen; durch sie geht er nicht.

const TEMPO := 1.2                     # Gehen etwas flotter als gebacken; jede Figur in ihrem Takt (rig.py „gang“, Chef 17:03)
const LEIB := 0.45                     # Meter: so nah kommt der Held an die Koerpermitte
# Chef Lauf 75 (26.10., 11:41: Leute wenden um 180 Grad „sehr flott … wirkt jetzt nicht sehr natuerlich“): gewendet wird mit
# fester Drehrate im Bogen ueber Schritte; waehrend der Drehung geht sie langsamer in Blickrichtung weiter, der Gang laeuft im Takt
# des echten Tempos (kein Gleiten). 180 Grad in gut 1,2 s, etwa zwei Schritte; im Stehen (Umschauen) gemaechlicher
const DREH := 2.5                      # rad/s im Gehen
const DREH_STEH := 1.4                 # rad/s im Stehen
const BOGEN := 0.45                    # rad: ab dieser Abweichung geht sie in Blickrichtung statt aufs Ziel
const BOGEN_TEMPO := 0.4               # Anteil des Tempos bei 180 Grad Abweichung (bei 0 Grad 1)

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
var leib := LEIB
var pause := "Stehen"                  # Dorftiere: Stehen oder Fressen in der Pause
var zufall := RandomNumberGenerator.new()
var streifen_n := 0                    # Kacheln um heim (alt wander; mit Tagesplan der des Orts)
var drinnen := false                   # 390 (5la): an der Tuer fuer die Nacht hineingegangen: nicht zu sehen, nicht im Weg
static var uhr := Callable()           # 390: Minute des Tages (spiel.gd, Zustand.minuten)

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

# 348.6 Dorftiere (Chefrunde 28.10., 08:09: „lieber ein paar Tiere zuerst ‚Platzieren‘“): die gekauften Tiere aus 387 (Jerrys
# kauftier.py, daten/dorftiere/kauf_<tier>-<fell>.bin, kauf_<tier>-info.json je Fell). Huehner wie alt zwei an jedem Heuballen auf
# der freien Seite (MapHen.find: westlich, noerdlich, nordwestlich, oestlich nur, wenn sonst nichts frei ist); neu Rind und Ziegen
# auf der Wiese suedlich des Flusses beim Kornfeld, Kaninchen am Westrand und am Nordufer, frei vor Kronen und Daechern (Pruefung
# 09:04: unter Krone und Dach nicht zu sehen). Tiere bleiben auf Wiese und Blumen (TIERBODEN); grosse Tiere (Ziege, Rind) nicht
# neben Feld, Garten, Zaun, Heu, ihr Koerper ragte sonst hinein (Pruefung: Ziege halb im Korn)
const DORFTIERE := {"village": [["rind", 27, 27], ["ziege", 25, 27], ["ziege", 30, 27], ["ziege", 14, 29], ["kaninchen", 2, 23], ["kaninchen", 27, 24]]}
const HUHN_PLATZ := [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(-1, -1), Vector2i(1, 0), Vector2i(0, 1)]
const TIERBODEN := ".f,"
# Pause zwischen zwei Schritten (s) und Anteil Fressen statt Stehen: Huehner picken oft, das Rind grast lange
const TIERPAUSE := {"huhn": [1.0, 3.5, 0.6], "rind": [5.0, 12.0, 0.7], "ziege": [3.0, 8.0, 0.6], "kaninchen": [2.0, 6.0, 0.5]}

static func dorftiere(k: Karte, h: Node3D) -> Array:
	var r := []
	if not DirAccess.dir_exists_absolute("res://daten/dorftiere"): return r
	var felle := {}                    # Tier -> Felle, nach Namen sortiert
	for f in DirAccess.get_files_at("res://daten/dorftiere"):
		if not f.ends_with(".bin"): continue
		var n := f.get_basename()
		var t := n.get_slice("-", 0).trim_prefix("kauf_")
		if not felle.has(t): felle[t] = []
		felle[t].append(n.get_slice("-", 1))
	for t in felle: felle[t].sort()
	var plaetze := []                  # [Tier, Kachel]
	var belegt := {}
	if felle.has("huhn"):
		for y in k.hoehe:
			for x in k.breite:
				if k.zeichen(Vector2i(x, y)) != "y": continue
				var frei := HUHN_PLATZ.filter(func(d): return Leute.tierboden(k, Vector2i(x, y) + d) and not belegt.has(Vector2i(x, y) + d))
				var offen := frei.filter(func(d): return d != Vector2i(1, 0))
				if offen.is_empty(): offen = frei
				for d in offen.slice(0, 2):
					belegt[Vector2i(x, y) + d] = true
					plaetze.append(["huhn", Vector2i(x, y) + d])
	for p in DORFTIERE.get(k.id, []):
		var t := Vector2i(int(p[1]), int(p[2]))
		var boden_ok := Leute.tierboden_gross(k, t) if p[0] in ["rind", "ziege"] else Leute.tierboden(k, t)
		if felle.has(p[0]) and boden_ok and not belegt.has(t):
			belegt[t] = true
			plaetze.append([p[0], t])
	var zahl := {}
	for p in plaetze:
		var tier: String = p[0]
		var i: int = zahl.get(tier, 0)
		zahl[tier] = i + 1
		var fell: String = felle[tier][i % felle[tier].size()]
		var blicke := ["DOWN", "LEFT", "UP", "RIGHT"]
		r.append(Leute.new(k, {"id": "%s%d" % [tier, i + 1], "x": p[1].x, "y": p[1].y, "blick": blicke[(i + p[1].x) % 4], "streifen": 2,
			"tier": tier, "fell": fell, "datei": "res://daten/dorftiere/kauf_%s-%s.bin" % [tier, fell],
			"info": "res://daten/dorftiere/kauf_%s-info.json" % tier}, h))
	return r

static func tierboden(k: Karte, t: Vector2i) -> bool:
	return k.begehbar(t) and k.ausgang(t).is_empty() and TIERBODEN.contains(k.zeichen(t))

const FELDRAND := "cvxy"
static func tierboden_gross(k: Karte, t: Vector2i) -> bool:
	if not tierboden(k, t): return false
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if FELDRAND.contains(k.zeichen(t + Vector2i(dx, dy))): return false
	return true

func _init(k: Karte, d: Dictionary, h: Node3D) -> void:
	karte = k
	daten = d
	held = h
	name = "Leute_" + String(d["id"])
	heim = Vector2i(int(d["x"]), int(d["y"]))
	streifen_n = int(d.get("streifen", 0))
	# 5l: beim Betreten der Karte steht jeder schon dort, wohin sein Tag ihn gefuehrt hat (Game.walkersHere)
	var st := plan_jetzt()
	if not st.is_empty() and k.begehbar(Vector2i(int(st[1]), int(st[2]))): heim = Vector2i(int(st[1]), int(st[2]))
	kachel = heim
	zufall.seed = hash(String(d["id"]))
	warte = zufall.randf_range(0.5, 3.0)

# der Ort des Tages jetzt: [ab, x, y, streifen, drinnen] wie VillageDay.stopAt, [] ohne Tagesplan
func plan_jetzt() -> Array:
	var p: Array = Karte.tagesablauf.get(String(daten["id"]), [])
	if p.is_empty() or not uhr.is_valid(): return []
	var m := int(uhr.call())
	var st: Array = p[p.size() - 1]
	for e in p:
		if int(e[0]) <= m: st = e
	return st

func _ready() -> void:
	var datei := String(daten.get("datei", "res://daten/leute/%s.bin" % daten["id"]))
	modell = Gebiet.lade_glb(datei)
	add_child(modell)
	Gebiet.male(modell, null, 2, mats)
	var p := datei.get_basename() + "-info.json"
	if daten.has("info") and FileAccess.file_exists(String(daten["info"])):
		# Dorftiere (kauftier.py): je Fell ein Eintrag; Tempo ohne Gleiten aus dem Wurzelweg des Gehens (Weg fuer Tempo 1)
		var alle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(String(daten["info"])))
		var info: Dictionary = alle.get(String(daten["fell"]), {})
		var w: Array = info.get("weg", {}).get("Gehen", [])
		if w.size() > 1 and float(info.get("Gehen", 0.0)) > 0.0: gang = float(w[w.size() - 1][1]) / float(info["Gehen"])
		# Pruefung 09:04: Rind (2,5 m) hielt 1 m Abstand, der Kopf reicht 1,25 m vor die Mitte: halbe Laenge plus eine Handbreit
		leib = clampf(float(info.get("laenge_m", 1.0)) * 0.5 + 0.15, 0.3, 1.5)
	elif FileAccess.file_exists(p):
		var info: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(p))
		gang = float(info.get("gehen_m_je_s", gang))
		baue_ding(info)
	anim = Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
	if anim: Gebiet.bewegungen(anim, ["Gehen", "Stehen", "Fressen"])
	if anim:
		anim.play("Stehen")
		anim.seek(zufall.randf() * 2.0, true)   # nicht alle im selben Atemzug
	position = karte.kachel_pos(kachel)
	blick = {"UP": PI, "DOWN": 0.0, "LEFT": -PI / 2, "RIGHT": PI / 2}.get(String(daten.get("blick", "DOWN")), 0.0)
	rotation.y = blick

# 348.6 Leute Runde 4b (Chef 25.10., 21:33: „Wieso tragen die … NPC nicht Objekte“): Stab, Speer, Hammer als eigene .glb aus
# Jerrys waffen.py (Modellregel 4, daten/waffen/<kennung>.bin, Griff = Ursprung, Schaft nach +Y) in der rechten Faust; die Haltung
# (Faust vor der Brust) backt rig.py. Der Schaft steht aufrecht, oben etwas nach hinten an die Schulter gelehnt, und folgt der Faust.
var ding: Node3D
var ding_griff := Vector3.ZERO
# CC0 Runde 4 (Fremdpruefung Runde 3: Aldrics Stab schwebt): reicht das Ding weit unter den Ursprung (Stab: Mitte, 0,85 m nach
# unten), steht es mit dem unteren Ende auf dem Boden und gleitet durch die Faust; ding_unten = Laenge unter dem Ursprung
var ding_unten := 0.0
func baue_ding(info: Dictionary) -> void:
	var k := String(info.get("traegt", ""))
	if k == "" or not FileAccess.file_exists("res://daten/waffen/%s.bin" % k): return
	var sk := Gebiet.finde(modell, "Skeleton3D") as Skeleton3D
	var kn := String(info.get("knochen_R", "foR-wrR"))     # 348.6 CC0-Geruest: hand_r (geruest.py)
	if sk == null or sk.find_bone(kn) < 0: return
	var g: Array = info.get("griff_R", [0.0, 0.2, 0.0])
	ding_griff = Vector3(float(g[0]), float(g[1]), float(g[2]))
	var ba := BoneAttachment3D.new()
	ba.bone_name = kn
	sk.add_child(ba)
	ding = Gebiet.lade_glb("res://daten/waffen/%s.bin" % k)
	ding.name = "Ding"
	ba.add_child(ding)
	for m in ding.find_children("*", "MeshInstance3D", true, false):
		ding_unten = maxf(ding_unten, -(m as MeshInstance3D).get_aabb().position.y)
	Gebiet.male(ding, null, 2, mats)
	var am := Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
	if am: am.mixer_applied.connect(richte_ding)   # nach jedem Schritt der Bewegung (die Fackel des Helden hing ein Bild nach, Runde 5b)

# auch ohne laufende Bewegung (Ansicht --leute haelt die Figuren an und dreht sie danach; der Stab lag dort quer durch den Hals)
func _physics_process(_dt: float) -> void:
	if ding: richte_ding()

# CC0 Feinschliff (Fremdpruefung 4c: Aldrics Stab lief dicht hinter Hals und Kopf, die Spitze wanderte im Gehen nicht mit, der Fuss
# glitt ueber den Boden): ein langer Stab steht vorn neben dem rechten Fuss und laeuft oben durch die Faust (aussen vor der Schulter, rig.py); im Gehen bleibt
# der Fuss stehen, bis die Faust STAB_VOR ueber ihn hinaus ist, dann setzt sie ihn in STAB_SETZ s vor sich neu auf
# Feinschliff 2: das Ziel geht beim Umsetzen mit der Faust (landet immer STAB_SETZ_VOR vor ihr). Fast senkrecht (5 cm vor der Faust)
# war beim Helfer schlechter: die Spitze stand im Gehen genau ueber dem Kopf und ragte aus dem Schaedel; zurueckgeneigt liegt sie dahinter
# Feinschliff 3 (Helfer: auch zurueckgeneigt kreuzte die Spitze den Kopf, auf Kopfhoehe lag der Stab 13-17 cm neben der Kopfmitte):
# Wanderstab, die Faust vorn vor der Brust (rig.py „stab“), der Schaft fast senkrecht vor dem Gesicht, umgesetzt etwa jeden Schritt
const STAB_VOR := 0.14                 # m: so weit geht die Faust ueber den stehenden Stab hinaus
const STAB_SETZ := 0.22                # s: Umsetzen
const STAB_SETZ_VOR := 0.14            # m: so weit vor der Faust setzt er auf (wie das Pruefblatt)
const STAB_AB := Vector2(0.03, 0.03)   # m: Fuss des Stabs in Ruhe aussen und vorn von der Faust (fast senkrecht)
var stab_fuss := Vector3.INF           # unteres Ende (Welt); INF: noch nicht gesetzt
var stab_von := Vector3.ZERO
var stab_nach := Vector3.ZERO
var stab_t := 1.0                      # Umsetzen 0..1
var stab_geht := false
var stab_uhr := 0

func richte_ding() -> void:
	var ba := ding.get_parent() as BoneAttachment3D
	var sk := ba.get_parent() as Skeleton3D
	var pose := sk.global_transform * sk.get_bone_global_pose(sk.find_bone(ba.bone_name))
	var p := pose * ding_griff
	var y := (Vector3.UP - global_basis.z.normalized() * 0.18 - global_basis.x.normalized() * 0.08).normalized()
	if ding_unten > 0.3:
		var jetzt := Time.get_ticks_usec()
		var dt := clampf((jetzt - stab_uhr) / 1e6, 0.0, 0.1) if stab_uhr > 0 else 0.0
		stab_uhr = jetzt
		var vorn := global_basis.z.normalized()
		var aussen := -global_basis.x.normalized()      # die Figur blickt nach +Z, ihre Rechte ist -X
		var ruhe := Vector3(p.x, global_position.y, p.z) + aussen * STAB_AB.x + vorn * STAB_AB.y
		if stab_fuss == Vector3.INF:
			stab_fuss = ruhe
			stab_nach = ruhe
		if stab_t >= 1.0:
			var geht := anim != null and anim.current_animation == "Gehen" and anim.is_playing()
			var neu := Vector3.INF
			if geht and (p - stab_fuss).dot(vorn) > STAB_VOR: neu = ruhe + vorn * (STAB_SETZ_VOR - STAB_AB.y)
			elif not geht and stab_fuss.distance_to(ruhe) > 0.04: neu = ruhe
			if neu != Vector3.INF:
				stab_von = stab_fuss
				stab_nach = neu
				stab_t = 0.0
				stab_geht = geht
		if stab_t < 1.0:
			if stab_geht: stab_nach = ruhe + vorn * (STAB_SETZ_VOR - STAB_AB.y)   # das Ziel geht mit der Faust
			stab_t = minf(1.0, stab_t + dt / STAB_SETZ)
			stab_fuss = stab_von.lerp(stab_nach, smoothstep(0.0, 1.0, stab_t)) + Vector3.UP * 0.06 * sin(PI * stab_t)
		y = p - stab_fuss
		y.y = maxf(y.y, 0.5)
		y = y.normalized()
	var x := (global_basis.x - y * global_basis.x.dot(y)).normalized()
	ding.global_basis = Basis(x, y, x.cross(y))
	if ding_unten > 0.3:
		p = stab_fuss + y * ding_unten   # der Schaft laeuft durch den Griff, das untere Ende steht auf stab_fuss
	ding.global_position = p

func nacht(k: float) -> void:
	for m in mats: (m as ShaderMaterial).set_shader_parameter("fill", 0.42 * (1.0 - k))

# fuer Held.frei: steht hier jemand?
func sperrt(p: Vector3) -> bool:
	if drinnen: return false
	return Vector2(p.x - position.x, p.z - position.z).length() < leib

func held_kachel() -> Vector2i:
	return karte.pos_kachel(held.position) if held else Vector2i(-99, -99)

func nah_am_held(t: Vector2i) -> bool:
	var h := held_kachel()
	return absi(t.x - h.x) + absi(t.y - h.y) <= 1

func frei_fuer_mich(t: Vector2i) -> bool:
	if not karte.begehbar(t) or not karte.ausgang(t).is_empty(): return false
	if daten.has("tier") and not (Leute.tierboden_gross(karte, t) if leib > 0.7 else Leute.tierboden(karte, t)): return false
	if t == held_kachel(): return false
	for l in get_parent().get_children():
		if l is Leute and l != self and not l.drinnen and (l.kachel == t or l.ziel == t): return false
	return true

func _process(dt: float) -> void:
	if ziel.x >= 0:
		laufe(dt)
		return
	if anim and anim.current_animation != pause:
		anim.play(pause, 0.25)
		anim.speed_scale = 1.0
	rotation.y = drehe(rotation.y, blick, DREH_STEH * dt)
	warte -= dt
	if warte > 0: return
	if tagesplan(): return
	if nah_am_held(kachel):
		warte = 0.8
		return
	if daten.has("runde"): runde()
	else: streife()

func streife() -> void:
	warte = zufall.randf_range(1.5, 4.0)
	if daten.has("tier"):
		var tp: Array = TIERPAUSE.get(String(daten["tier"]), [1.5, 4.0, 0.5])
		warte = zufall.randf_range(tp[0], tp[1])
		pause = "Fressen" if anim and anim.has_animation("Fressen") and zufall.randf() < tp[2] else "Stehen"
	var d := Vector2i(zufall.randi_range(-1, 1), zufall.randi_range(-1, 1))
	if d == Vector2i.ZERO: return
	var n := kachel + d
	if absi(n.x - heim.x) + absi(n.y - heim.y) > streifen_n: return
	if not frei_fuer_mich(n): return
	if d.x != 0 and d.y != 0 and not (karte.begehbar(kachel + Vector2i(d.x, 0)) and karte.begehbar(kachel + Vector2i(0, d.y))): return
	ziel = n

# 390 (Game.updateWalkers 5l): weit vom Ort des Tages: dorthin, dort erst eine Weile stehen (330); an der Tuer fuer die Nacht
# hinein. true: die Person ist unterwegs oder drinnen, das Streifen faellt aus
func tagesplan() -> bool:
	var st := plan_jetzt()
	if st.is_empty(): return false
	var ort := Vector2i(int(st[1]), int(st[2]))
	heim = ort
	streifen_n = int(st[3])
	drinnen = bool(st[4]) and kachel == ort
	visible = not drinnen
	if drinnen:
		warte = 5.0
		return true
	if absi(kachel.x - ort.x) + absi(kachel.y - ort.y) <= streifen_n: return false
	gehe_nach(ort)
	if absi(ziel.x - ort.x) + absi(ziel.y - ort.y) <= streifen_n and ziel.x >= 0: warte = zufall.randf_range(5.0, 10.0)
	return true

# ein Schritt auf dem Weg nach p (Wegsuche der Karte); wartet, wenn jemand im Weg steht
func gehe_nach(p: Vector2i) -> void:
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
	gehe_nach(p)

func laufe(dt: float) -> void:
	var zp := karte.kachel_pos(ziel)
	var to := zp - position
	to.y = 0
	var tempo := gang * TEMPO / karte.schritt(ziel)
	var soll := atan2(to.x, to.z)
	rotation.y = drehe(rotation.y, soll, DREH * dt)
	var ab := absf(angle_difference(rotation.y, soll))
	tempo *= lerpf(BOGEN_TEMPO, 1.0, (cos(ab) + 1.0) * 0.5)
	var s := tempo * dt
	if ab < BOGEN and to.length() <= s:
		position = Vector3(zp.x, position.y, zp.z)
		kachel = ziel
		ziel = Vector2i(-1, -1)
		blick = rotation.y
		# auf der Runde ohne Halt zur naechsten Kachel
		if daten.has("runde"): warte = 0.0
		return
	var vor := to.normalized() if ab < BOGEN else Vector3(sin(rotation.y), 0.0, cos(rotation.y))
	var neu := position + vor * s
	if karte.begehbar(karte.pos_kachel(neu)): position = neu   # der Bogen fuehrt nie auf eine gesperrte Kachel
	kachel = karte.pos_kachel(position)
	if anim:
		if anim.current_animation != "Gehen":   # CC0-Geruest Runde 2 (Fremdpruefung: Gleichschritt): jede mit eigenem Schritt
			anim.play("Gehen", 0.18)
			anim.seek(zufall.randf() * anim.current_animation_length)
		anim.speed_scale = tempo / gang

# dreht a hoechstens um schritt auf b zu (feste Rate statt lerp: grosse Wenden dauern laenger, kleine bleiben weich)
static func drehe(a: float, b: float, schritt: float) -> float:
	var d := angle_difference(a, b)
	return b if absf(d) <= schritt else a + signf(d) * schritt
