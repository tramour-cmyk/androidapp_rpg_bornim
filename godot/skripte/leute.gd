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
const DREH_ZU := 2.5                   # rad/s zum Helden hin (416.8, Chef 02.11., 10:52, Build 146: „zombie-mäßig“, „ein Ticken schneller“), 180 Grad in 1,3 s
const BOGEN := 0.45                    # rad: ab dieser Abweichung geht sie in Blickrichtung statt aufs Ziel
const BOGEN_TEMPO := 0.4               # Anteil des Tempos bei 180 Grad Abweichung (bei 0 Grad 1)

var karte: Karte
var daten: Dictionary
var held: Node3D
var modell: Node3D
var anim: AnimationPlayer
var gang := 1.08                       # m/s ohne Gleiten (held-info.json der Figur)
# 475 Kaufkoerper: die Bewegung laeuft ohne Gleiten mit gang (umgetaktet, heldfigur.gd TAKT_GEHEN); gehen ist das Tempo der Person
# (wie die alte Figur, etwas flotter), geh_anim „Gehen“ oder mit getragenem Ding „Gehen_<gang>“ (417, heldfigur.gd bewaffne)
var gehen := -1.0
var geh_anim := "Gehen"
const KAUF_GEHEN := 0.62               # Anteil von TAKT_GEHEN: die Leute gehen gemaechlicher als der Held
var mats: Array = []
var heim := Vector2i.ZERO
var kachel := Vector2i.ZERO
var ziel := Vector2i(-1, -1)           # Kachel, auf die sie gerade geht
var weg: Array[Vector2i] = []          # Runde: Weg zum naechsten Punkt
var bein := 0                          # Runde: Index des Punkts, zu dem sie geht (Walker.leg)
var warte := 0.0
var tempo_jetzt := 0.0                 # 416.4: m/s, steigt beim Anlaufen und faellt vor dem Halt (Held.tempo_schritt)
const DURCH_MS := 1800                  # 416.2: so lange nach einem Platzwechsel sperrt sie den Helden nicht (ein Schritt etwa 1 s)
var durch_bis := 0                      # Time.get_ticks_msec() bis dahin
var blick := 0.0
var leib := LEIB
var pause := "Stehen"                  # Dorftiere: Stehen oder Fressen in der Pause
var zufall := RandomNumberGenerator.new()
var ruhe_bis := -1.0                   # 397: Wechsel der Ruhebewegung (Gebiet.ruhe_naechste), nur bei pause Stehen
var streifen_n := 0                    # Kacheln um heim (alt wander; mit Tagesplan der des Orts)
var drinnen := false                   # 390 (5la): an der Tuer fuer die Nacht hineingegangen: nicht zu sehen, nicht im Weg
static var uhr := Callable()           # 390: Minute des Tages (spiel.gd, Zustand.minuten)
static var still := false              # 390: waehrend eines Gespraechs bleiben alle stehen (Mode.Dialog)
# 416.8 (Chef 31.10., 20:5x: „NPC dreht sich bei Interaktion zum Helden, nach etwa 10 s ignoriert er ihn wieder und spielt Leerlauf“;
# alt Game.talk npcFacing): angesprochen wendet sich die Person dem Helden zu und folgt ihm mit dem Blick; ZUGEWANDT s nach dem
# Gespraech dreht sie sich zurueck und macht weiter, was sie tat (Ruhebewegung, Streifen, Runde)
const ZUGEWANDT := 10.0
var zugewandt_bis := 0                  # ms (Time.get_ticks_msec); 0: niemandem zugewandt
var blick_vorher := 0.0
# 416.8 (Chef 03.11., 07:44: „völlig ohne irgendeine Form der Bewegung … auf der Stelle drehen … wie eine Schachfigur“): im Stehen
# wendet die Person mit Schritten (Drehen_L/R aus Turn90 der UAL Pro, geruest.py ohne die Drehung des Beckens gebacken); der Knoten
# dreht nach der gemessenen Kurve der Bewegung (held-info.json gier), so bleibt der Standfuss stehen; Tempo wie bisher (rate)
const WENDE_AB := 0.44                  # rad (25 Grad): kleinere Wenden ohne Schritte
const WENDE_BLEND := 0.2                # s Uebergang aus dem Stehen in die Wende
var wende_kurve := {}                   # Name -> PackedFloat32Array, Drehung in rad je Bild (30 Bilder/s) seit Beginn
var wende := ""                         # laufende Wende
var wende_start := 0.0                  # rotation.y beim Beginn der Wende
var monster := false                   # 560 (Jerry): ein Monster der Geschichte (Grimmzahn, aussehen „monster:…“)
const MONSTER_SIEHT := 4               # 560: Kacheln, ab denen es sich dem Helden zuwendet (herde.gd Lauerer 9i.2)
var da := true                         # 390: nach der Geschichte zu sehen (Story.kt visible: besiegt, befreit)

## 635: Figurdatei einer Person der Karte: nach Kennung, sonst nach Aussehen; "" ohne Modell
static func datei_von(d: Dictionary) -> String:
	for n in [String(d.get("id", "")), String(d.get("aussehen", ""))]:
		if n != "" and not n.begins_with("monster:") and FileAccess.file_exists("res://daten/leute/%s.bin" % n):
			return "res://daten/leute/%s.bin" % n
	return ""

static func alle(k: Karte, h: Node3D) -> Array:
	var r := []
	for d in k.daten.get("leute", []):
		var mo := String(d.get("aussehen", ""))
		if mo.begins_with("monster:"):   # 491: Grimmzahn (Npc „monster:dire_wolf“) als Modell des Kampforts, wie die Monster der Karte
			if Streuner.da(mo.trim_prefix("monster:")): r.append(Leute.new(k, d, h))
			continue
		# 635 (Abgleich 620.2a): Lyra heisst auf den Karten lyra_temple und lyra_cave, gebaut ist sie als ihr Aussehen „lyra“
		# (Story.kt Npc(id, x, y, look)); ohne Datei der Kennung gilt die des Aussehens
		var datei := datei_von(d)
		if datei == "": continue
		var dd: Dictionary = d
		if datei != "res://daten/leute/%s.bin" % d["id"]:
			dd = d.duplicate()
			dd["datei"] = datei
		var l := Leute.new(k, dd, h)
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
# Chef 28.10., 16:12 („südlich des Flusses Hühner, Ziegen und Kühe und der Bauer … Das ist zu viel … die Kuh muss da unten weg …
# auch die Ziegen zum Teil … unter Umständen auch die Durchgang da blockiert“): Rind vorerst ganz weg, suedlich des Flusses eine Ziege
# statt drei, abseits von Bruecke und Weg
const DORFTIERE := {"village": [["ziege", 30, 27], ["kaninchen", 2, 23], ["kaninchen", 27, 24]]}
const HUHN_PLATZ := [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(-1, -1), Vector2i(1, 0), Vector2i(0, 1)]
const TIERBODEN := ".f,"
# Pause zwischen zwei Schritten (s) und Anteil Fressen statt Stehen: Huehner picken oft, das Rind grast lange
const TIERPAUSE := {"huhn": [1.0, 3.5, 0.6], "rind": [5.0, 12.0, 0.7], "ziege": [3.0, 8.0, 0.6], "kaninchen": [2.0, 6.0, 0.5]}
# 591 (Chef 05.11., Build 266: „Hühner und Kaninchen sollten grundsätzlich weglaufen (wie Hühner in der Kotlin-Fassung)“): MapHen
# FLEE/WARY: kommt der Held näher als SHY (46 px = 1,44 Kacheln), rennt das Tier geradewegs von ihm weg, seitlich ausweichend, wo der
# Weg zu ist, bis SAFE (90 px = 2,8 Kacheln); dann steht es 2,5 s wachsam, danach wieder wie sonst und streift heim; höchstens
# LEASH (120 px = 3,75 Kacheln) von daheim
const FLIEHEN := ["huhn", "kaninchen"]
const FLUCHT_NAH := 1.45               # Kacheln (MapHen.SHY)
const FLUCHT_SICHER := 2.8             # Kacheln (MapHen.SAFE)
const FLUCHT_LEINE := 4                # Kacheln um heim (MapHen.LEASH)
const WACHSAM := 2.5                   # s (MapHen: WARY 2500 ms)
const FLUCHT_TEMPO := 1.3              # Rennen etwas schneller als gebacken
var flucht := false                    # rennt gerade vor dem Helden weg (klang.gd: Gackern, Flügel)
var renn := 0.0                        # m/s der Bewegung Rennen bei Tempo 1 (0: keine, dann Gehen doppelt)
var renn_soll := 0.0                   # m/s, wie kauftier.py es meint (Weg mal Tempo)

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

# 390: nach der Geschichte da oder nicht (Geschichte.sichtbar)
# 399.1 Ruf (134.1): ein goldenes „!“ mit dunklem Rand ueber dem Kopf, durch alles sichtbar, immer zur Kamera
var ruf_zeichen: Label3D
var ruft_bis := 0                       # ms (Hail.calms)

func rufe(an: bool) -> void:
	if not an and ruf_zeichen == null: return
	if ruf_zeichen == null:
		ruf_zeichen = Label3D.new()
		ruf_zeichen.text = "!"
		ruf_zeichen.font = Stil.schrift()
		ruf_zeichen.font_size = 96
		ruf_zeichen.outline_size = 18
		ruf_zeichen.modulate = Color("f0c850")
		ruf_zeichen.outline_modulate = Color("201408b0")
		ruf_zeichen.pixel_size = 0.004
		ruf_zeichen.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		ruf_zeichen.no_depth_test = true
		ruf_zeichen.shaded = false
		ruf_zeichen.position = Vector3(0, kopfhoehe() + 0.35, 0)
		add_child(ruf_zeichen)
	ruf_zeichen.visible = an

# Scheitel ueber den Fuessen: aus den Netzen der Figur, sonst 1,75 m
func kopfhoehe() -> float:
	var oben := 0.0
	if modell:
		for m in modell.find_children("*", "MeshInstance3D", true, false):
			var bb: AABB = (m as MeshInstance3D).get_aabb()
			var t: Transform3D = global_transform.affine_inverse() * (m as MeshInstance3D).global_transform if m.is_inside_tree() and is_inside_tree() else Transform3D()
			oben = maxf(oben, (t * bb).end.y)
	return oben if oben > 0.5 else 1.75

# 492 (Story.kt Leave, Game.leave): geht auf dem kuerzesten Weg zu fort_nach, dort ist sie fort (fertig wird gerufen)
var fort_nach := Vector2i(-1, -1)
var fort_fertig := Callable()
func geht_fort(nach: Vector2i, fertig: Callable) -> void:
	if fort_nach == nach: return
	fort_nach = nach; fort_fertig = fertig
	zugewandt_bis = 0; weg.clear(); warte = 0.4

func zeige(ja: bool) -> void:
	da = ja
	visible = da and not drinnen

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
	var aus := "res://daten/leute/%s.bin" % String(daten.get("aussehen", ""))   # 492: Lyra (lyra_cave, lyra_temple) als Figur „lyra“
	if not daten.has("datei") and not FileAccess.file_exists(datei) and FileAccess.file_exists(aus): datei = aus
	var p := datei.get_basename() + "-info.json"
	var mo := String(daten.get("aussehen", ""))
	if mo.begins_with("monster:"):
		# 491: ein Monster der Geschichte (Grimmzahn) steht als Figur des Kampforts (kampf/figur.gd, Jerry) wie die Monster der Karte
		# (streuner.gd): dasselbe Modell, Fell und dieselbe Groesse wie im Kampf; streift nicht, spricht nicht, angesprochen greift es an
		var f = Streuner.kaempfer(mo.trim_prefix("monster:"), 1)
		if Streuner.helfer == null: Streuner.helfer = Streuner.Kampfort.new()
		var fig = Streuner.Figur.new()
		fig.fighter = f
		fig.kampfort = Streuner.Stub.new(Streuner.helfer)
		add_child(fig)
		fig.setup(f, fig.kampfort)
		fig.rotation.y = 0.0
		fig.set_process(true)
		modell = fig
		anim = fig.anim
		monster = true
		gang = 1.0
		leib = 0.8
		position = karte.kachel_pos(kachel)
		blick = {"UP": PI, "DOWN": 0.0, "LEFT": -PI / 2, "RIGHT": PI / 2}.get(String(daten.get("blick", "DOWN")), 0.0)
		rotation.y = blick
		if anim and anim.has_animation("Stehen"): anim.play("Stehen")
		return
	if not daten.has("datei") and baue_kauf(p): return
	modell = Gebiet.lade_glb(datei)
	add_child(modell)
	Gebiet.male(modell, null, 2, mats)
	if daten.has("info") and FileAccess.file_exists(String(daten["info"])):
		# Dorftiere (kauftier.py): je Fell ein Eintrag; Tempo ohne Gleiten aus dem Wurzelweg des Gehens (Weg fuer Tempo 1)
		var alle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(String(daten["info"])))
		var info: Dictionary = alle.get(String(daten["fell"]), {})
		var w: Array = info.get("weg", {}).get("Gehen", [])
		if w.size() > 1 and float(info.get("Gehen", 0.0)) > 0.0: gang = float(w[w.size() - 1][1]) / float(info["Gehen"])
		var wr: Array = info.get("weg", {}).get("Rennen", [])
		if wr.size() > 1 and float(info.get("Rennen", 0.0)) > 0.0:
			renn = float(wr[wr.size() - 1][1]) / float(info["Rennen"])
			renn_soll = renn * float(info.get("tempo", {}).get("Rennen", 1.0))
		# Pruefung 09:04: Rind (2,5 m) hielt 1 m Abstand, der Kopf reicht 1,25 m vor die Mitte: halbe Laenge plus eine Handbreit
		leib = clampf(float(info.get("laenge_m", 1.0)) * 0.5 + 0.15, 0.3, 1.5)
	elif FileAccess.file_exists(p):
		var info: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(p))
		gang = float(info.get("gehen_m_je_s", gang))
		baue_ding(info)
		for n in ["Drehen_L", "Drehen_R"]:   # 416.8
			var g: Array = info.get("bewegungen", {}).get(n, {}).get("gier", [])
			if g.size() > 1 and absf(float(g[g.size() - 1])) > 30.0:
				wende_kurve[n] = PackedFloat32Array(g.map(func(x): return deg_to_rad(float(x))))
	anim = Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
	if anim: Gebiet.bewegungen(anim, ["Gehen", "Rennen", "Stehen", "Fressen", "Stehen_2", "Stehen_3"])   # 591: Rennen der Flucht
	if anim:
		anim.play("Stehen")
		anim.seek(zufall.randf() * 2.0, true)   # nicht alle im selben Atemzug
	Gebiet.atem_an(modell, anim, hash(String(daten.get("id", ""))) ^ 4532)   # 453.2: eigener Takt je Person (gebiet.gd)
	position = karte.kachel_pos(kachel)
	blick = {"UP": PI, "DOWN": 0.0, "LEFT": -PI / 2, "RIGHT": PI / 2}.get(String(daten.get("blick", "DOWN")), 0.0)
	rotation.y = blick

# 475: die Person auf dem Kaufkoerper mit eigenem Gesicht (heldfigur.gd person); false ohne Kaufdateien
func baue_kauf(info_datei: String) -> bool:
	var m := HeldFigur.person(String(daten["id"]), mats)
	if m == null: return false
	modell = m
	add_child(modell)
	anim = modell.get_node_or_null("AnimationPlayer") as AnimationPlayer
	gang = float(modell.get_meta("gehen_m_je_s", HeldFigur.TAKT_GEHEN))
	var alt := 1.08
	if FileAccess.file_exists(info_datei):
		var info: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(info_datei))
		alt = float(info.get("gehen_m_je_s", alt))
	gehen = HeldFigur.TAKT_GEHEN * KAUF_GEHEN * clampf(alt / 1.08, 0.8, 1.2)
	var wg := String(modell.get_meta("gang", ""))
	if wg != "" and anim and anim.has_animation("Gehen_" + wg) and float(modell.get_meta("gang_gehen_m_je_s", 0.0)) > 0.01:
		geh_anim = "Gehen_" + wg
		gang = float(modell.get_meta("gang_gehen_m_je_s"))
	if anim:
		anim.play("Stehen")
		anim.seek(zufall.randf() * 2.0, true)
	Gebiet.atem_an(modell, anim, hash(String(daten.get("id", ""))) ^ 4532)
	position = karte.kachel_pos(kachel)
	blick = {"UP": PI, "DOWN": 0.0, "LEFT": -PI / 2, "RIGHT": PI / 2}.get(String(daten.get("blick", "DOWN")), 0.0)
	rotation.y = blick
	return true

func tempo_soll() -> float: return gehen if gehen > 0.0 else gang

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
	if drinnen or not da or Time.get_ticks_msec() < durch_bis: return false
	return Vector2(p.x - position.x, p.z - position.z).length() < leib

# 348.6 Ausweichen wie alt (Game.makeWay, 92; Chef 16:12: „man kann ja auch noch keine NPCs oder Tiere … schieben“): wer vom Helden
# geschoben wird, tritt zur Seite (links oder rechts des Wegs, sonst voran) und bleibt dort einen Moment (alt 4 s), bevor der Tag
# weitergeht; Wachen auf ihrer Runde nicht (alt: patrol). Tiere auch.
func weicht() -> bool: return da and not drinnen and not daten.has("runde")

func weiche(d: Vector2i) -> bool:
	# 416.2 (Chef 31.10.: „Platzwechsel statt nur Schieben“; 02.11., 10:52, Build 146: „Ziege wird geschoben, kein Platztausch“):
	# zuerst tauscht, wer geschoben wird, mit dem Helden den Platz; solange gehen beide durcheinander hindurch. Nur wo das nicht
	# geht (Held nicht daneben, sein Platz nicht fuer sie, etwa ein Tier auf dem Weg), tritt sie zur Seite, sonst voran (alt makeWay)
	var h := held_kachel()
	var u := h - kachel
	var nachbar := absi(u.x) + absi(u.y) == 1 or (absi(u.x) == 1 and absi(u.y) == 1 and karte.begehbar(kachel + Vector2i(u.x, 0)) and karte.begehbar(kachel + Vector2i(0, u.y)))
	if nachbar and frei_fuer_mich(h, true):
		ziel = h
		warte = 4.0
		durch_bis = Time.get_ticks_msec() + DURCH_MS
		return true
	var seiten := [Vector2i(d.y, d.x), Vector2i(-d.y, -d.x)]   # quer zum Weg, in zufaelliger Folge
	if zufall.randf() < 0.5: seiten.reverse()
	for s in seiten + [d]:
		var n: Vector2i = kachel + s
		if frei_fuer_mich(n):
			ziel = n
			warte = 4.0
			return true
	return false

func held_kachel() -> Vector2i:
	return karte.pos_kachel(held.position) if held else Vector2i(-99, -99)

func nah_am_held(t: Vector2i) -> bool:
	var h := held_kachel()
	return absi(t.x - h.x) + absi(t.y - h.y) <= 1

func frei_fuer_mich(t: Vector2i, held_da := false) -> bool:
	if not karte.begehbar(t) or not karte.ausgang(t).is_empty(): return false
	# beim Platzwechsel (held_da) darf ein Tier kurz auf den Weg des Helden; zurueck auf seinen Boden streift es von selbst
	if daten.has("tier") and not held_da and not (Leute.tierboden_gross(karte, t) if leib > 0.7 else Leute.tierboden(karte, t)): return false
	if t == held_kachel() and not held_da: return false
	for l in get_parent().get_children():
		if l is Leute and l != self and l.visible and (l.kachel == t or l.ziel == t): return false
	return true

# 416.4 (Chef 01.11., 13:1x: „von Stehen zu Gehen oder Laufen muss weich sein. Egal, wer sich bewegt“): wer auf der Runde von Kachel
# zu Kachel weitergeht, stand bisher ein Bild lang (Stehen 0,25 s angespielt, dann Gehen 0,18 s an zufaelliger Stelle: Sprung je
# Kachel). Jetzt entscheidet sie erst, ob sie weitergeht; nur wer stehen bleibt, blendet in die Pause
func _process(dt: float) -> void:
	if ziel.x >= 0:
		laufe(dt)
		return
	if fliehe():   # 591: ohne ein Bild Stehen zwischen zwei Kacheln der Flucht
		laufe(dt)
		return
	if anim and pause.begins_with("Stehen"):   # 397
		if ruhe_bis < 0.0: ruhe_bis = anim.get_animation("Stehen").length * zufall.randi_range(2, 4)
		ruhe_bis -= dt
		if ruhe_bis <= 0.0:
			var r := Gebiet.ruhe_naechste(anim, pause, zufall)
			pause = r[0]; ruhe_bis = float(r[1])
	stehen(dt)
	if ziel.x >= 0: return
	tempo_jetzt = 0.0
	if monster and anim and anim.has_animation("Gehen") and absf(angle_difference(rotation.y, blick)) > Streuner.DREH_TRITT:
		if anim.current_animation != "Gehen": anim.play("Gehen", 0.2)     # 560: wendet mit Tritten
		anim.speed_scale = Streuner.TRITT_TEMPO
		return
	if anim and anim.current_animation != pause and wende == "":
		anim.play(pause, Held.ueberblendung(anim.current_animation, false))
		anim.speed_scale = 1.0

func stehen(dt: float) -> void:
	if fort_nach.x >= 0 and not still: zugewandt_bis = 0   # 492: wer fortgeht, geht gleich nach dem Gespraech (Game.leave)
	var s := schaut_her(dt) and fort_nach.x < 0   # zaehlt den Stillstand des Helden auch waehrend des Gespraechs und danach; wer fortgeht (492), schaut nicht her
	if zugewandt_bis > 0:
		if still: zugewandt_bis = Time.get_ticks_msec() + int(ZUGEWANDT * 1000)   # waehrend des Gespraechs zaehlt die Zeit nicht
		if Time.get_ticks_msec() < zugewandt_bis and held:
			blick = atan2(held.global_position.x - global_position.x, held.global_position.z - global_position.z)
		else:
			zugewandt_bis = 0
			schaut = false
			blick = blick_vorher
			ruhe_bis = -1.0   # die Ruhebewegung beginnt neu
	else:
		if s:
			if not schaut: blick_vorher = blick
			schaut = true
			blick = atan2(held.global_position.x - global_position.x, held.global_position.z - global_position.z)
		elif schaut:
			schaut = false
			blick = blick_vorher
			ruhe_bis = -1.0
	# 560 (Chef 04.11., 16:22, Grimmzahn: „wenn sich die Monster … alles zum Held drehen … mit Bewegung drehen“): ein Monster der
	# Geschichte wendet sich dem nahen Helden zu, mit fester Rate und Tritten (_process), wie die Monster der Karte (streuner.gd)
	if monster and held and zugewandt_bis == 0 and held_abstand() <= MONSTER_SIEHT:
		blick = atan2(held.global_position.x - global_position.x, held.global_position.z - global_position.z)
	if monster:
		rotation.y = drehe(rotation.y, blick, Streuner.DREH * dt)
	else:
		drehe_stehend(dt, DREH_ZU if zugewandt_bis > 0 or schaut else DREH_STEH)     # 416.8 (Tom): Wende mit Schritten
	if still or not da: return
	if zugewandt_bis > 0 or schaut: return
	if Time.get_ticks_msec() < ruft_bis: return   # 399.1 (306): wer ruft, haelt still, bis das zweite Zeichen vorbei ist
	warte -= dt
	if warte > 0: return
	if fort_nach.x >= 0:
		if kachel == fort_nach:
			fort_nach = Vector2i(-1, -1)
			if fort_fertig.is_valid(): fort_fertig.call()
			return
		gehe_nach(fort_nach)
		return
	if tagesplan(): return
	if nah_am_held(kachel):
		warte = 0.8
		return
	if daten.has("runde"): runde()
	else: streife()

# 591: Abstand zum Helden in Kacheln (MapHen: hypot zum Helden)
func held_abstand() -> float:
	if held == null: return 99.0
	return Vector2(held.position.x - position.x, held.position.z - position.z).length() / Karte.TS

# 591 (MapHen.at FLEE): true, wenn das Tier jetzt eine Kachel weiter vom Helden weg rennt (ziel gesetzt)
func fliehe() -> bool:
	if not daten.has("tier") or not String(daten["tier"]) in FLIEHEN or still or not da or drinnen:
		return false
	var a := held_abstand()
	if not flucht and a >= FLUCHT_NAH: return false
	if flucht and a > FLUCHT_SICHER:
		# MapHen WARY: steht wachsam, dann wie sonst
		flucht = false
		warte = WACHSAM
		pause = "Stehen"
		ruhe_bis = -1.0
		return false
	var n := flucht_kachel()
	if n.x < 0:
		# eingeklemmt (MapHen stuck: „alert“): bleibt stehen, bis der Weg frei ist oder der Held geht
		if flucht: warte = 0.3
		return false
	if not flucht:
		flucht = true
		tempo_jetzt = maxf(tempo_jetzt, flucht_tempo() * 0.6)   # aufgeschreckt: gleich mit Schwung
	ziel = n
	weg.clear()
	return true

# geradewegs weg vom Helden, sonst bis 110 Grad zur Seite (MapHen: 0, ±35, ±70, ±110), nicht weiter als die Leine von daheim
func flucht_kachel() -> Vector2i:
	var weg_v := Vector2(position.x - held.position.x, position.z - held.position.z)
	if weg_v.length() < 0.01: weg_v = Vector2(sin(rotation.y), cos(rotation.y))
	weg_v = weg_v.normalized()
	var best := Vector2i(-1, -1)
	var best_w := -2.0
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			var d := Vector2i(dx, dy)
			if d == Vector2i.ZERO: continue
			var n := kachel + d
			if absi(n.x - heim.x) + absi(n.y - heim.y) > FLUCHT_LEINE: continue
			if not frei_fuer_mich(n): continue
			if dx != 0 and dy != 0 and not (karte.begehbar(kachel + Vector2i(dx, 0)) and karte.begehbar(kachel + Vector2i(0, dy))): continue
			var w := Vector2(dx, dy).normalized().dot(weg_v)
			if w < cos(deg_to_rad(110.0)): continue
			if w > best_w:
				best_w = w
				best = n
	return best

# m/s im Rennen (Weg mal Tempo aus kauftier.py), ohne Rennen das Gehen doppelt
func flucht_tempo() -> float:
	return (renn_soll if renn > 0.0 else gang * 2.0) * FLUCHT_TEMPO

func streife() -> void:
	warte = zufall.randf_range(1.5, 4.0)
	if daten.has("tier"):
		var tp: Array = TIERPAUSE.get(String(daten["tier"]), [1.5, 4.0, 0.5])
		warte = zufall.randf_range(tp[0], tp[1])
		pause = "Fressen" if anim and anim.has_animation("Fressen") and zufall.randf() < tp[2] else "Stehen"
		ruhe_bis = -1.0
	# 591: nach der Flucht weiter weg als sonst: Schritt fuer Schritt heim (MapHen IDLE: „far from home it goes back first“)
	if absi(kachel.x - heim.x) + absi(kachel.y - heim.y) > streifen_n:
		var h := Vector2i(signi(heim.x - kachel.x), signi(heim.y - kachel.y))
		for d in [h, Vector2i(h.x, 0), Vector2i(0, h.y)]:
			if d == Vector2i.ZERO or not frei_fuer_mich(kachel + d): continue
			if d.x != 0 and d.y != 0 and not (karte.begehbar(kachel + Vector2i(d.x, 0)) and karte.begehbar(kachel + Vector2i(0, d.y))): continue
			ziel = kachel + d
			return
		return
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
	# 607 (Chef 07.11.: Pim „läuft um 0300 Uhr immer noch rum“, nachgestellt in nacht_607): wer klopft, steht auf genau der Kachel, auf
	# der die Person fuer die Nacht hineingeht; ist sie besetzt, geht sie von der Nachbarkachel aus hinein, statt davor zu warten
	var vor_tuer := absi(kachel.x - ort.x) + absi(kachel.y - ort.y) == 1 and not frei_fuer_mich(ort)
	drinnen = bool(st[4]) and (kachel == ort or vor_tuer)
	visible = da and not drinnen
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
	wende = ""
	var zp := karte.kachel_pos(ziel)
	var to := zp - position
	to.y = 0
	var tempo := (flucht_tempo() if flucht else tempo_soll() * TEMPO) / karte.schritt(ziel)
	var soll := atan2(to.x, to.z)
	rotation.y = drehe(rotation.y, soll, DREH * (2.0 if flucht else 1.0) * dt)   # 591: rennend schnell herum (MapHen.TURN_RUN)
	var ab := absf(angle_difference(rotation.y, soll))
	tempo *= lerpf(BOGEN_TEMPO, 1.0, (cos(ab) + 1.0) * 0.5)
	# 416.4: anlaufen und vor dem letzten Schritt langsamer werden wie der Held (Held.tempo_schritt, Held.bremse)
	if weg.is_empty() and not flucht: tempo = Held.bremse(tempo, to.length(), tempo_soll() * TEMPO)   # letzte Kachel des Wegs (Runde, Tagesplan) oder Streifen
	tempo_jetzt = Held.tempo_schritt(tempo_jetzt, tempo, flucht_tempo() if flucht else tempo_soll() * TEMPO, dt)
	tempo = tempo_jetzt
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
		# 591: auf der Flucht das Rennen (Huhn, Kaninchen aus kauftier.py), sonst Gehen (mit getragenem Ding geh_anim, 417)
		var gangart := "Rennen" if flucht and renn > 0.0 and anim.has_animation("Rennen") else geh_anim
		if anim.current_animation != gangart:   # CC0-Geruest Runde 2 (Fremdpruefung: Gleichschritt): jede mit eigenem Schritt
			# 416.4: aus dem Stand weich (Held.ueberblendung, 0,5 s statt 0,18 s); der Schritt beginnt an zufaelliger Stelle, nur
			# beim Anlaufen (die Pause steht noch voll im Bild, der Sprung im Gang faellt nicht auf)
			anim.play(gangart, 0.15 if flucht else Held.ueberblendung(anim.current_animation, true))
			anim.seek(zufall.randf() * anim.current_animation_length)
		anim.speed_scale = tempo / (renn if gangart == "Rennen" else gang)

# 416.8: im Stehen zu blick drehen; ab WENDE_AB mit Schritten (Drehen_L/R), der Knoten folgt der Kurve der Bewegung; Ziel erreicht
# oder Bewegung zu Ende: zurueck ins Stehen, ist noch viel uebrig, gleich die naechste Wende (180 Grad = zwei)
func drehe_stehend(dt: float, rate: float) -> void:
	if wende != "":
		var k: PackedFloat32Array = wende_kurve[wende]
		var spielt := anim != null and anim.current_animation == wende
		var t := anim.current_animation_position if spielt else INF
		var soll := wende_start + kurve(k, t)
		var vorbei := signf(angle_difference(soll, blick)) != signf(k[k.size() - 1])   # Ziel erreicht oder ueberholt
		if not vorbei: rotation.y = soll   # ueberholt: stehen lassen, den Rest dreht drehe (der Held kann auch die Seite gewechselt haben)
		if spielt and not vorbei and t < anim.current_animation_length - 0.02: return
		wende = ""
		if absf(angle_difference(rotation.y, blick)) <= WENDE_AB:
			anim.play(pause, 0.3)
			anim.speed_scale = 1.0
			return
	var rest := angle_difference(rotation.y, blick)
	if absf(rest) > WENDE_AB and anim and not drinnen and visible:
		for n in wende_kurve:
			var k: PackedFloat32Array = wende_kurve[n]
			if signf(k[k.size() - 1]) != signf(rest) or not anim.has_animation(n): continue
			var gleich: bool = anim.current_animation == n   # zweite Wende derselben Seite: play liefe nur weiter
			wende = n
			wende_start = rotation.y
			anim.play(n, WENDE_BLEND)
			if gleich: anim.seek(0.0, true)
			anim.speed_scale = clampf(rate * anim.get_animation(n).length / absf(k[k.size() - 1]), 0.7, 2.0)
			return
	rotation.y = drehe(rotation.y, blick, rate * dt)

# Drehung der Kurve k (je Bild, 30 Bilder/s) nach t Sekunden, zwischen den Bildern linear; nach dem Ende der letzte Wert
static func kurve(k: PackedFloat32Array, t: float) -> float:
	var f := t * 30.0
	if f >= k.size() - 1: return k[k.size() - 1]
	var i := int(f)
	return lerpf(k[i], k[i + 1], f - i)

# 416.8 (Chef 08.11., 15:43, t269.11: „beim Annähern richtet sich keiner zum Helden aus“; DESIGN-STIL „Lebendige Welt“: bis 3 Felder
# anschauen, nach etwa 10 s Stillstand das Interesse verlieren, 5la.3). Wie alt (MapFolk.kt 853–871 WATCH_TILES, BORED_MS, watches,
# Stillness): steht der Held hoechstens 3 Kacheln je Richtung entfernt und steht er noch keine 10 s auf derselben Kachel, wendet sich
# die Person ihm zu (mit Schritten wie beim Ansprechen, drehe_stehend) und haelt in ihrem Tun inne; danach blickt sie wie vorher und
# macht weiter. Tiere nicht (alt nur die Leute). Besser als alt: die Zeit laeuft mit dem Spiel (dt), steht still, solange es ruht
const SCHAUT_KACHELN := 3
const LANGWEILIG := 10.0               # s
var schaut := false
var held_still := 0.0                  # s, die der Held schon auf held_still_kachel steht
var held_still_kachel := Vector2i(-99, -99)

func schaut_her(dt: float) -> bool:
	if held == null or daten.has("tier") or drinnen or not visible or not da: return false
	var h := held_kachel()
	if h != held_still_kachel:
		held_still_kachel = h
		held_still = 0.0
	else: held_still += dt
	var d := h - kachel
	return d != Vector2i.ZERO and absi(d.x) <= SCHAUT_KACHELN and absi(d.y) <= SCHAUT_KACHELN and held_still < LANGWEILIG

# 416.8: dem Helden zuwenden (spiel.gd sprich)
func wende_zu() -> void:
	if zugewandt_bis == 0 and not schaut: blick_vorher = blick
	zugewandt_bis = Time.get_ticks_msec() + int(ZUGEWANDT * 1000)

# dreht a hoechstens um schritt auf b zu (feste Rate statt lerp: grosse Wenden dauern laenger, kleine bleiben weich)
static func drehe(a: float, b: float, schritt: float) -> float:
	var d := angle_difference(a, b)
	return b if absf(d) <= schritt else a + signf(d) * schritt
