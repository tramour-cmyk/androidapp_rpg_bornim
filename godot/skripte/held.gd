class_name Held
extends Node3D
# 348.6: der Held aus tools/blender348/v3 (held.glb in Metern, Skelett, Gehen/Stehen, gebackene Textur) mit Fackel;
# geht einen Weg aus Kachelmitten (Tippen) oder in eine Richtung (Joystick), stoesst nirgends durch (Karte.begehbar).
# Tempo wie im alten Spiel (FreeWalk.WALK/RUN, Terrain.stepFactor); Gehen wird so schnell abgespielt, dass nichts gleitet.

signal steht_auf(kachel: Vector2i)
signal stoesst(kachel: Vector2i)       # will auf eine Kachel, die sperrt (Game.move: Move.Blocked)

const RAND := 0.3                      # Meter: so nah kommt die Koerpermitte an Unbegehbares

var karte: Karte
var modell: Node3D
var anim: AnimationPlayer
var gang := 1.08                       # m/s, mit denen „Gehen“ ohne Gleiten laeuft (held-info.json)
var renn := 0.0                        # m/s, mit denen „Rennen“ ohne Gleiten laeuft (held-info.json; 0: altes Modell ohne Rennen)
var waffengang := ""                   # 417 Runde 4: Gehen_<gang>, Rennen_<gang> aus den Paketen (heldfigur.gd bewaffne), leer: ohne
var gang_w := 0.0                      # m/s ohne Gleiten der Paketbewegungen
var renn_w := 0.0
static var schnell := 1.0              # 555 Testmenue „Schnell“: Gehen und Laufen dreifach, damit das Durchspielen flott geht
var tempo_jetzt := 0.0                 # Chef 25.10., 18:20: „Übergang von Gehen zu Rennen ist zu krass“: das Tempo steigt und faellt weich
const BESCHL := 5.0                    # m/s²: von Gehen (2,1) auf Rennen (4,3) in gut 0,4 s
var weg: Array[Vector3] = []
var richtung := Vector3.ZERO           # Joystick, Laenge 0..1
var laeuft := false
var fackel: OmniLight3D
var flamme: MeshInstance3D
var kachel := Vector2i(-1, -1)
var zeit := 0.0
var ruhe := "Stehen"                  # 397: jetzige Ruhebewegung (Gebiet.ruhe_naechste)
var ruhe_bis := -1.0
var ruhe_zufall := RandomNumberGenerator.new()
# 592 (Chef 05.11., 19:3x und 22:0x „592 so“): geht ihm die Ausdauer aus, bleibt er etwa 1 s stehen, die Haende auf den Knien
# (Stehen_3, Idle_Tired), und atmet schwer (Keuchen: klang.gd atme); danach geht er steuerbar weiter, bis ein Viertel zurueck ist
# (Ausdauer.WIEDER). Steht er atemlos, bleibt er so gebeugt; das Stehen erholt doppelt so schnell wie das Gehen (Ausdauer)
const ATEM_HALT := 1.0                 # s
const MUEDE := "Stehen_3"
var atemlos := false
var atem_halt_bis := -1.0              # zeit

# jedes Bild aus spiel.gd mit Zustand.atemlos
func atemlos_neu(an: bool) -> void:
	if an and not atemlos and anim and anim.has_animation(MUEDE): atem_halt_bis = zeit + ATEM_HALT
	atemlos = an
var gestossen := Vector2i(-1, -1)
var stoss_zeit := -9.0
var leute: Array = []                  # Leute der Karte (spiel.gd): durch sie geht er nicht
var atem = null                        # 453.2: kampf/atem.gd (null ohne UAL-Geruest)
var renn_s := 0.0                      # 453.2: so lange rennt er schon (s); danach atmet er schneller und beruhigt sich
# 453.2 (Chef 13:0x: „nach Rennen schneller und abklingend“): nach RENN_VOLL s Rennen volle Anstrengung, nach Gehen etwas
const RENN_VOLL := 6.0
const GEH_ANSTRENGUNG := 0.15

var abbremsen := false                # 416.4: wird langsamer ohne Halt (ABBREMS, auslaufen)
var soll_jetzt := 0.0                  # 416.4: Zieltempo dieses Bilds
var faellt := false                    # 416.4: tempo_jetzt sinkt in diesem Bild

var wahl := {}                         # 376.1 Klasse, Aussehen, Ausruestung (HeldFigur.wahl); leer: der bisherige Held

func _init(k: Karte, w: Dictionary = {}) -> void:
	karte = k
	wahl = w
	name = "Held"

func _ready() -> void:
	baue_figur()

# 522 (Chef 03.11., 23:33, Build 249: „Ausrüstung geändert (Schild gegeben), aber im Spiel kein Schild“): die Figur wurde nur beim
# Betreten einer Karte gebaut; nach einer Aenderung der Ausruestung (Testmenue, Ausruestungsschirm) baut spiel.gd sie hier neu,
# Ort, Blick, Weg und Fackel bleiben, die Bewegung laeuft weiter
func neu_figur(w: Dictionary) -> void:
	var war: String = String(anim.current_animation) if anim else ""
	if modell:
		remove_child(modell)
		modell.queue_free()
	modell = null; anim = null; atem = null; fackel = null; flamme = null
	mats.clear()
	waffengang = ""; gang_w = 0.0; renn_w = 0.0
	wahl = w
	baue_figur()
	nacht(nacht_k)
	if anim and war != "" and anim.has_animation(war): anim.play(war, 0.0)

func baue_figur() -> void:
	# 376.1: je Klasse der Held auf dem Kaufkoerper (heldfigur.gd), sonst der bisherige (held.bin, rig.py)
	modell = HeldFigur.baue(wahl, mats) if not wahl.is_empty() else null
	var kauf := modell != null
	if not kauf:
		modell = Gebiet.lade_glb("res://daten/held.bin")
		Gebiet.male(modell, null, 2, mats)
	add_child(modell)
	for m in mats: (m as ShaderMaterial).set_shader_parameter("metall", 1.0)   # 348.6 Glanz an Kette und Helm (toon.gdshader)
	if "--teilfarbe" in OS.get_cmdline_user_args():   # nur zum Messen: Teile in Falschfarben (toon.gdshader teil, rig.py TEILMASKE)
		for m in mats: (m as ShaderMaterial).set_shader_parameter("teil", 1.0)
	# 348.6 Kette nachts (Helfer: Kette fast weiss, Gesicht darunter schwarz wie eine Maske; gemessen ohne Fackel Kette = Gesicht, mit Fackel
	# Kette 0,29, Gesicht 0,22: das Licht sass 9 cm ueber der Flamme seitlich am Kopf, traf die Brust von oben, das Gesicht streifend):
	# Metall streut Lampenlicht wenig (kette_lampe), nachts weniger Umgebung (kette_umgebung in nacht()); Licht vor der Flamme (richte_fackel)
	for m in mats: (m as ShaderMaterial).set_shader_parameter("kette_lampe", 0.35)
	var info: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/held-info.json")) if not kauf else \
		{"gehen_m_je_s": modell.get_meta("gehen_m_je_s"), "rennen_m_je_s": modell.get_meta("rennen_m_je_s"), "faust_L": modell.get_meta("faust_L")}
	gang = float(info.get("gehen_m_je_s", gang))
	renn = float(info.get("rennen_m_je_s", 0.0))
	if kauf and modell.has_meta("gang_gehen_m_je_s"):
		waffengang = String(modell.get_meta("gang", "")); gang_w = float(modell.get_meta("gang_gehen_m_je_s")); renn_w = float(modell.get_meta("gang_rennen_m_je_s"))
	# 348.6 CC0-Geruest (348.12): Knochen der Faust und Griff stehen in held-info.json (geruest.py), sonst das alte Skelett
	var fa: Dictionary = info.get("faust_L", {})
	if fa.has("knochen"):
		faust_knochen = String(fa["knochen"])
		faust_griff = fa["griff"] if fa["griff"] is Vector3 else Vector3(fa["griff"][0], fa["griff"][1], fa["griff"][2])
		faust_achse = fa["achse"] if fa["achse"] is Vector3 else Vector3(fa["achse"][0], fa["achse"][1], fa["achse"][2])
	anim = Gebiet.finde(modell, "AnimationPlayer") as AnimationPlayer
	if anim: Gebiet.bewegungen(anim, ["Gehen", "Stehen", "Rennen", "Gehen_Fackel", "Stehen_Fackel", "Rennen_Fackel", "Stehen_2", "Stehen_3", "Stehen_2_Fackel", "Stehen_3_Fackel"])
	if anim: baue_aus(anim)   # 416.4: RennenAus… fuer das Auslaufen
	if anim: anim.play("Stehen")
	atem = Gebiet.atem_an(modell, anim, 4532)   # 453.2: eigene Atemschicht (gebiet.gd atem_an)
	baue_fackel()

func setze(t: Vector2i, blick := "DOWN") -> void:
	position = karte.kachel_pos(t)
	rotation.y = {"UP": PI, "DOWN": 0.0, "LEFT": -PI / 2, "RIGHT": PI / 2}.get(blick, 0.0)
	weg.clear()
	kachel = t
	steht_auf.emit(t)

# 390 (Rast: Wiederkehrort wie Place.facing): die naechste der vier Richtungen von setze
func blick() -> String:
	var w := wrapf(rotation.y, -PI, PI)
	if absf(w) <= PI / 4: return "DOWN"
	if absf(w) >= 3 * PI / 4: return "UP"
	return "RIGHT" if w > 0 else "LEFT"

func geh_zu(ziel: Vector3) -> bool:
	var b := karte.pos_kachel(ziel)
	var ids := karte.weg(karte.pos_kachel(position), b)
	weg.clear()
	if ids.is_empty(): return false   # 399.1: kein Weg, die Welt ruettelt (WorldScreen route == null)
	for k in range(1, ids.size()): weg.append(karte.kachel_pos(ids[k]))
	if weg.is_empty(): weg.append(karte.kachel_pos(b))
	return true

# 390: stehen bleiben (vor einer angetippten Person)
func halt() -> void: weg.clear()

func sperrer(p: Vector3) -> Leute:
	for l in leute:
		if is_instance_valid(l) and l.sperrt(p): return l
	return null

func frei(p: Vector3) -> bool:
	if not karte.begehbar(karte.pos_kachel(p)): return false
	for l in leute:
		if is_instance_valid(l) and l.sperrt(p): return false
	return true

# Tempo und Ueberblendung fuer Held, Leute, Tiere und den Film der Tragprobe (tragprobe.gd, 417). 416.4 (Chef 01.11., 13:1x: „von
# Stehen zu Gehen oder Laufen muss weich sein. Egal, wer sich bewegt“): aus dem Stand mit ANLAUF des Gehtempos los (bisher sofort
# voll), dann mit BESCHL schneller oder langsamer; am Ende des Wegs bremst bremse() auf ANLAUF herunter (bisher voller Schritt bis
# zum Halt); ohne Weg (Steuerkreuz losgelassen) haelt er sofort
const ANLAUF := 0.35                   # Anteil des Gehtempos im ersten Bild aus dem Stand und beim letzten Schritt
const BREMS := 3.5                     # m/s²: vor dem Ziel langsamer werden (aus dem Rennen etwa 2,5 m vorher)
# 416.4 (Chef 01.11., 20:3x: „anlaufen, das passt … der Übergang wieder von laufen zu gehen … völlig abrupt … Von Sprint langsam über
# langsamer über in den Gang gehen“; Stehenbleiben aus dem Sprint geht): langsamer werden, ohne anzuhalten, mit ABBREMS statt BESCHL
# (Rennen 4,3 -> Gehen 2,1 m/s in gut 1 s statt 0,4 s; schneller werden bleibt BESCHL); vor dem Halt weiter bremse() wie bisher
const ABBREMS := 2.0
static func tempo_schritt(jetzt: float, soll: float, geh_t: float, dt: float, ab := BESCHL) -> float:
	if soll <= 0.0: return 0.0
	return minf(soll, geh_t) * ANLAUF if jetzt <= 0.0 else move_toward(jetzt, soll, (BESCHL if soll >= jetzt else ab) * dt)

static func bremse(tempo: float, rest: float, geh_t: float) -> float:   # rest: m bis zum Halt
	return minf(tempo, maxf(geh_t * ANLAUF, sqrt(2.0 * BREMS * maxf(0.0, rest))))

# Runde 5 (Helfer Runde 3: „Haltung springt beim Anlaufen in 0,1 s“): Gehen <-> Rennen 0,6 s (Rumpf neigt sich weich; 0,45: in 1/15 s
# 9 Grad), aus dem Stehen 0,5 s (397: Ruhe in Ruhe weich); 416.4: aus Gehen oder Rennen in den Stand 0,45 s statt 0,25 s
static func ueberblendung(cur: String, moving: bool) -> float:
	var schritt := cur.begins_with("Gehen") or cur.begins_with("Rennen")
	if schritt: return 0.6 if moving else 0.45
	return 0.5 if cur.begins_with("Stehen") else 0.25

# 416.4 (Pruefer 15:1x: „Rennen → Gehen springt in einem Bild in die aufrechte Haltung“; Messung rennen_wechsel_4164, Lauf 41316403849):
# Godot zaehlt die Ueberblendung in Zeit der Bewegung, also mal speed_scale. Gleich nach dem Wechsel ins Gehen ist das Tempo noch
# 2,9 m/s, das Gehen (1,0 m/s) laeuft 2,9-fach, die 0,6 s waren 0,2 s (Neigung 25 -> 15 Grad in 4 Bildern); ins Rennen (0,57-fach)
# gut 1 s, das blieb (Chef: „Rennen und Übergang passen“). Dazu der selbe Schritt nach den Tritten (heldfigur.gd Meta „tritt“: Zeit,
# zu der der rechte und der linke Ballen aufsetzt) statt nach dem Anteil der Zeit: Rennen A laeuft in der Luft doppelt so schnell, der
# Anteil traf das Gehen im falschen Schritt (Wade 69 Grad in einem Bild). sp: speed_scale der neuen Bewegung
# sanft (held.gd, rennen_film_4164; Pruefer Film 03:55, Messung Lauf 41381478168: Fuesse gleiten beim Anlaufen 1 m, beim Halt 0,35 m,
# in beiden Fassungen): aus dem Stehen in den Schritt (gut 0,6 s) traegt das Gehen mit kleinem Anteil die Fuesse nur zum Teil mit, der
# Koerper laeuft schon, die Sohlen schleiften; jetzt gleitet das Tempo ohne Gleiten dabei von ANLAUF_V des Gehens herauf (takt): erst
# kleine schnelle Schritte, der Standfuss steht. In den Stand lief das Gehen 0,45 s in vollem Takt weiter, obwohl er stand: jetzt mit HALT_TAKT (stand_takt)
const ANLAUF_V := 0.15
const ANLAUF_BLENDE := 0.8             # in Zeit der Bewegung: aus dem Stand wie bisher 0,6–0,7 s (Chef 20:3x: „anlaufen, das passt“)
const HALT_TAKT := 0.12
static func wechsel(ap: AnimationPlayer, want: String, moving: bool, sp: float, sanft := false) -> void:
	var cur := ap.current_animation
	var schritt := moving and (cur.begins_with("Gehen") or cur.begins_with("Rennen"))
	var bl := ueberblendung(cur, moving)
	var ph := 0.0
	if schritt:
		ph = schritt_phase(ap.get_animation(cur), ap.current_animation_position)
		# 417 (Lauf 41372776505 FILMNACH: Gehen nach dem Rennen Standfuss +0,9 bis +1,5 m/s, Pruefer Film 02:2x „Auslaufen Fuesse gleiten
		# deutlich“): seit dem Umtakten (TAKT_*) beginnt die Ueberblendung mit dem speed_scale der alten Bewegung (takt: v gleitet von der
		# alten), nicht mit sp = Tempo / v der neuen; Rennen -> Gehen war sp 2, die 0,6 s wurden 1,2 s Bewegungszeit, real etwa 1,6 s halb
		# Rennen, halb Gehen. Jetzt mit dem speed_scale, der gerade laeuft (ohne takt wie vorher sp)
		var sp0 := ap.speed_scale if ap.has_meta("v") else sp
		if ap.has_meta("v"): ap.set_meta("blende", [0.0, bl, float(ap.get_meta("v"))])   # takt: Tempo gleitend
		bl *= maxf(1.0, sp0)
	elif sanft and moving and cur.begins_with("Stehen"):
		bl = ANLAUF_BLENDE
		ap.set_meta("blende", [0.0, bl, -ANLAUF_V, true])   # Tempo ohne Gleiten von ANLAUF_V mal dem des Gehens herauf
	elif sanft and not moving and (cur.begins_with("Gehen") or cur.begins_with("Rennen")):
		if ap.has_meta("blende"): ap.remove_meta("blende")
		ap.set_meta("halt", [0.0, bl])
		bl *= HALT_TAKT
	ap.play(want, bl)
	if schritt: ap.seek(schritt_zeit(ap.get_animation(want), ph))

# speed_scale im Stand: nach dem Halt (wechsel sanft) so lange HALT_TAKT, bis die Ueberblendung in den Stand vorbei ist
static func stand_takt(ap: AnimationPlayer, dt: float) -> float:
	if not ap.has_meta("halt"): return 1.0
	var h: Array = ap.get_meta("halt")
	h[0] = float(h[0]) + dt
	if float(h[0]) >= float(h[1]):
		ap.remove_meta("halt")
		return 1.0
	return HALT_TAKT

# speed_scale fuer Tempo und Tempo ohne Gleiten v der laufenden Bewegung; waehrend der Ueberblendung Gehen <-> Rennen gleitet v von
# der alten zur neuen (Nachmessung 416.4: ein speed_scale fuer beide, sonst laeuft die alte im Tempo der neuen)
# (auslaufen: Zeit der Ueberblendung in Zeit der Bewegung wie Godot, b[3] wahr)
static func takt(ap: AnimationPlayer, tempo: float, v: float, dt: float) -> float:
	ap.set_meta("v", v)
	if ap.has_meta("blende"):
		var b: Array = ap.get_meta("blende")
		var echt := b.size() < 4 or not bool(b[3])
		if echt: b[0] = float(b[0]) + dt
		var w := clampf(float(b[0]) / maxf(0.01, float(b[1])), 0.0, 1.0)
		if w >= 1.0: ap.remove_meta("blende")
		else: v = lerpf(float(b[2]) if float(b[2]) >= 0.0 else -float(b[2]) * v, v, w)
		if not echt: b[0] = float(b[0]) + dt * tempo / maxf(0.01, v)
	return tempo / maxf(0.01, v)

# 416.4 Auslaufen (Chef 20:3x: „Von Sprint langsam über langsamer über in den Gang“): beim Langsamerwerden aus dem Rennen blendet die
# Haltung ueber die ganze Bremszeit (ABBREMS) ins Gehen, Schritt kuerzer und langsamer zugleich, Fuesse im Tempo des Bodens (takt). Damit
# beide Bewegungen der Ueberblendung im selben Schritt bleiben, laeuft das Rennen dabei als „RennenAus…“, umgetaktet auf die Laenge des
# Gehens (ein speed_scale fuer beide; bei verschiedener Laenge liefen sie in 1 s um einen halben Schritt auseinander)
static func aus_name(n: String) -> String:
	return "RennenAus" + n.substr(6) if n.begins_with("Rennen") and not n.begins_with("RennenAus") else ""

static func baue_aus(ap: AnimationPlayer) -> void:
	for n in ap.get_animation_list():
		var aus := aus_name(n)
		var g := "Gehen" + String(n).substr(6)
		if aus == "" or ap.has_animation(aus) or not ap.has_animation(g): continue
		var r := ap.get_animation(n)
		var lg := ap.get_animation(g).length
		if r.length < 0.05 or lg < 0.05: continue
		var a := r.duplicate(true) as Animation
		if r.has_meta("tritt"): a.set_meta("tritt", r.get_meta("tritt"))
		HeldFigur.umtakten(a, lg / r.length)
		a.set_meta("aus_k", lg / r.length)
		ap.get_animation_library(ap.find_animation_library(r)).add_animation(aus, a)

# ob er rennt (Tempo ueber 1,45 Gehtempo): wird er langsamer (faellt), geht es aus dem Gehen nie zurueck ins Rennen, auch nicht, wenn vor
# dem Ziel bremse() uebernimmt; ohne Halt (abbremsen) blendet das Rennen ueber die ganze Bremszeit ins Gehen (auslaufen). Fuer held.gd
# und die Filme (rennen_film_4164, rennen_auslauf_4164); v_r, v_g Tempo ohne Gleiten der laufenden Bewegung und ihres Gehens
static func rennt_jetzt(ap: AnimationPlayer, kann: bool, tempo: float, soll: float, geh_t: float, faellt: bool, abbremsen: bool,
		v_r: float, v_g: float) -> bool:
	var rennt := kann and tempo > geh_t * 1.45
	if kann and faellt:
		var cur := ap.current_animation
		if not cur.begins_with("Rennen") or cur.begins_with("RennenAus"): return false
		if rennt and abbremsen and auslaufen(ap, "Gehen" + cur.substr(6), tempo, soll, v_r, v_g): return false
	return rennt

# aus dem Rennen (laufende Bewegung) ins Gehen want: tempo jetzt, soll Ziel, v_r und v_g Tempo ohne Gleiten bei speed_scale 1; falsch,
# wenn es kein RennenAus gibt (dann wie bisher wechsel)
static func auslaufen(ap: AnimationPlayer, want: String, tempo: float, soll: float, v_r: float, v_g: float) -> bool:
	var cur := ap.current_animation
	var aus := aus_name(cur)
	if aus == "" or not ap.has_animation(aus) or not ap.has_animation(want): return false
	var v_a := v_r / float(ap.get_animation(aus).get_meta("aus_k", 1.0))
	var ph := schritt_phase(ap.get_animation(cur), ap.current_animation_position)
	ap.play(aus, 0.0)
	ap.seek(schritt_zeit(ap.get_animation(aus), ph), true)
	var bl := maxf(0.3, (tempo - soll) / ABBREMS) * 0.5 * (tempo / maxf(0.01, v_a) + soll / maxf(0.01, v_g))
	ap.play(want, bl)
	ap.seek(schritt_zeit(ap.get_animation(want), ph))
	ap.set_meta("blende", [0.0, bl, v_a, true])
	return true

# Schrittphase 0 bis 1: 0 rechter Ballen setzt auf, 0,5 linker; ohne Meta „tritt“ der Anteil der Zeit
static func schritt_phase(a: Animation, t: float) -> float:
	var L := maxf(0.001, a.length)
	if not a.has_meta("tritt"): return fposmod(t, L) / L
	var tr: Vector2 = a.get_meta("tritt")
	var d := fposmod(tr.y - tr.x, L)
	if d < 0.01 or d > L - 0.01: return fposmod(t, L) / L
	var u := fposmod(t - tr.x, L)
	return 0.5 * u / d if u < d else 0.5 + 0.5 * (u - d) / (L - d)

static func schritt_zeit(a: Animation, ph: float) -> float:
	var L := maxf(0.001, a.length)
	if not a.has_meta("tritt"): return fposmod(ph, 1.0) * L
	var tr: Vector2 = a.get_meta("tritt")
	var d := fposmod(tr.y - tr.x, L)
	if d < 0.01 or d > L - 0.01: return fposmod(ph, 1.0) * L
	ph = fposmod(ph, 1.0)
	var u := ph * 2.0 * d if ph < 0.5 else d + (ph - 0.5) * 2.0 * (L - d)
	return fposmod(tr.x + u, L)

func _process(dt: float) -> void:
	zeit += dt
	var dir := Vector3.ZERO
	if richtung.length() > 0.15:
		dir = richtung
		weg.clear()
	else:
		# 416.4 (Pruefer Film 4611: „Rennen zum angetippten Ziel stockt je Kachel“; nachgerechnet: an jedem Wegpunkt ein Bild ohne Schritt,
		# das setzte tempo_jetzt auf 0, er lief je Kachel neu an und kam nie ueber 3,4 m/s): erreichte Wegpunkte im selben Bild abhaken
		while weg.size() > 0:
			var to := weg[0] - position
			to.y = 0
			if to.length() >= 0.06:
				dir = to.normalized()
				break
			position = Vector3(weg[0].x, position.y, weg[0].z)
			weg.pop_front()
	if zeit < atem_halt_bis: dir = Vector3.ZERO   # 592: kurz stehen und schnaufen; ein angetippter Weg geht danach weiter
	var moving := dir.length() > 0.05
	var vorher := position
	var tempo := 0.0
	if moving:
		var kps := karte.laufen if laeuft else karte.gehen
		tempo = kps * Karte.TS / karte.schritt(karte.pos_kachel(position)) * clampf(dir.length(), 0.5, 1.0) * schnell
		# aus dem Stand mit ANLAUF los (416.4), schneller oder langsamer werden weich
		var geh_t := karte.gehen * Karte.TS / karte.schritt(karte.pos_kachel(position)) * schnell
		var ab := ABBREMS   # 416.4: langsamer werden ohne Halt (Rennen -> Gehen) gut 1 s
		if richtung.length() <= 0.15 and weg.size() > 0:   # 416.4: vor dem Ende des Wegs langsamer
			var bis := Vector2(weg[0].x - position.x, weg[0].z - position.z).length()
			for i in range(1, weg.size()): bis += Vector2(weg[i].x - weg[i - 1].x, weg[i].z - weg[i - 1].z).length()
			var b := bremse(tempo, bis, geh_t)
			if b < tempo - 0.001: ab = BESCHL   # vor dem Halt wie bisher („Stehenbleiben aus dem Sprint geht“)
			tempo = b
		abbremsen = ab == ABBREMS and tempo_jetzt > tempo + 0.05 and tempo <= geh_t * 1.45   # (auslaufen)
		soll_jetzt = tempo
		var tempo_vor := tempo_jetzt
		tempo_jetzt = tempo_schritt(tempo_jetzt, tempo, geh_t, dt, ab)
		faellt = tempo_jetzt < tempo_vor - 1e-5
		tempo = tempo_jetzt
		# in kleinen Stuecken, damit ein langes Bild (dt gross) nicht ueber Kanten springt oder zu frueh anstoesst; auf dem Weg ueber
		# Wegpunkte hinweg weiter (416.4: bisher endete das Stueck am Wegpunkt, das naechste Bild stand)
		var d := dir.normalized()
		var rest := tempo * dt
		var am_weg := weg.size() > 0 and richtung.length() <= 0.15
		while rest > 1e-4:
			var lang := 0.08
			if am_weg:
				var bis_p := Vector2(weg[0].x - position.x, weg[0].z - position.z).length()
				if bis_p < 1e-4:
					if weg.size() == 1: break   # am Ziel: oben im naechsten Bild abgehakt, dann steht er
					position = Vector3(weg[0].x, position.y, weg[0].z)
					weg.pop_front()
					var nach := weg[0] - position
					nach.y = 0
					if nach.length() > 1e-4:
						d = nach.normalized()
						dir = d
					continue
				lang = minf(lang, bis_p)
			var step := d * minf(rest, lang)
			rest -= step.length()
			var np := position + step
			var vorn_frei := frei(np) and frei(np + d * RAND)
			# Test 139.7: steht jemand vorn im Weg, ist er gemeint, auch wenn der Held schraeg an ihm entlang gleitet (die Kamera blickt
			# schraeg, der Joystick zeigt selten genau entlang der Kacheln); spiel.gd _schiebt entscheidet, ob er zur Seite tritt
			var gegen := false   # ungefaehr auf die Person zu (bis 60 Grad): er bleibt vor ihr stehen, statt um sie herumzugleiten
			if not vorn_frei:
				var wer := sperrer(np + d * RAND)
				if wer == null: wer = sperrer(np)
				if wer:
					var zu := Vector3(wer.position.x - position.x, 0, wer.position.z - position.z)
					gegen = zu.length() < 0.05 or d.dot(zu.normalized()) > 0.5
					if wer.kachel != gestossen or zeit - stoss_zeit > 2.0:
						gestossen = wer.kachel; stoss_zeit = zeit
						stoesst.emit(wer.kachel)
			# 540 (t274.12, Chef 10.11.: am Südrand kein Text): schräg gegen einen gesperrten Ausgang glitt der Held an ihm entlang und
			# stieß nie an (suedrand_540: gerade ja, schräg nie; die Spielkamera blickt schräg, der Joystick zeigt selten genau entlang
			# der Kacheln). Ein gesperrter Ausgang vorn meldet sich darum auch beim Entlanggleiten, alle 2 s höchstens einmal
			if not vorn_frei and not gegen:
				var aus := karte.pos_kachel(np + d * RAND)
				if not karte.sperrt(aus).is_empty() and zeit - stoss_zeit > 2.0:   # je Rand einmal, nicht je Kachel
					gestossen = aus; stoss_zeit = zeit
					stoesst.emit(aus)
			if vorn_frei:
				position = np
			elif gegen:
				weg.clear()
				break
			elif absf(step.x) > 1e-5 and frei(position + Vector3(step.x + signf(step.x) * RAND, 0, 0)):
				position.x += step.x
			elif absf(step.z) > 1e-5 and frei(position + Vector3(0, 0, step.z + signf(step.z) * RAND)):
				position.z += step.z
			else:
				weg.clear()
				var vor := karte.pos_kachel(position + d * (RAND + 0.05))
				var wer := sperrer(np + d * RAND)   # vor einer breiten Person (Rind) stand der Held noch auf der eigenen Kachel
				if wer: vor = wer.kachel
				var rand := not karte.sperrt(vor).is_empty()   # 540: an einem gesperrten Ausgang zählt nur die Zeit
				if (vor != gestossen and not rand) or zeit - stoss_zeit > 2.0:
					gestossen = vor; stoss_zeit = zeit
					stoesst.emit(vor)
				break
		rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z), minf(1.0, dt * 12.0))
	if anim:
		# Runde 4 (5): gegen Schlagbaum oder Wand (Text offen) stand der Held in Gehhaltung: nur gehen, wenn er vorankommt
		if moving and (position - vorher).length() < tempo * dt * 0.2: moving = false
		if not moving: tempo_jetzt = 0.0
		var geh_t := karte.gehen * Karte.TS / karte.schritt(karte.pos_kachel(position))
		var cur := anim.current_animation
		var paket := waffengang != "" and (cur.begins_with("Rennen_" + waffengang) or cur.begins_with("Gehen_" + waffengang))
		var rennt := rennt_jetzt(anim, moving and renn > 0.0, tempo, soll_jetzt, geh_t, faellt, abbremsen, renn_w if paket else renn,
			gang_w if paket else gang)
		renn_s = renn_s + dt if rennt else 0.0
		if atem != null:
			if rennt: atem.anstrengen(minf(1.0, renn_s / RENN_VOLL))
			elif moving: atem.anstrengen(GEH_ANSTRENGUNG)
		if moving: ruhe = "Stehen"; ruhe_bis = -1.0
		elif ruhe_bis < 0.0: ruhe_bis = zeit + anim.get_animation("Stehen").length * ruhe_zufall.randi_range(2, 4)
		elif zeit >= ruhe_bis:
			var r := Gebiet.ruhe_naechste(anim, ruhe, ruhe_zufall)
			ruhe = r[0]; ruhe_bis = zeit + float(r[1])
		var want := ("Rennen" if rennt else "Gehen") if moving else (MUEDE if atemlos and anim.has_animation(MUEDE) else ruhe)   # 592
		var mit := moving and waffengang != "" and anim.has_animation(want + "_" + waffengang) and (gang_w if not rennt else renn_w) > 0.01
		if mit: want += "_" + waffengang
		if fackel and traegt_fackel:
			if anim.has_animation(want + "_Fackel"): want += "_Fackel"
			elif not moving: want = "Stehen_Fackel" if anim.has_animation("Stehen_Fackel") else "Stehen"   # Fackel bleibt in der Hand
		var v := ((renn_w if rennt else gang_w) if mit else (renn if rennt else gang))
		# Gehen <-> Rennen im selben Schritt, Ueberblendung in echter Zeit, Tempo gleitend (416.4, wechsel, takt)
		if anim.current_animation != want: wechsel(anim, want, moving, tempo / maxf(0.01, v) if moving else 1.0, true)
		if moving and anim.has_meta("halt"): anim.remove_meta("halt")
		anim.speed_scale = takt(anim, tempo, v, dt) if moving else stand_takt(anim, dt)
	var k := karte.pos_kachel(position)
	if k != kachel:
		kachel = k
		steht_auf.emit(k)
	if fackel: fackel.light_energy = fackel_kraft * (0.88 + 0.12 * sin(zeit * 17.0) * sin(zeit * 7.3))
	if flamme:
		var innen := flamme.get_child(1) as Node3D
		innen.scale = Vector3.ONE * (0.85 + 0.2 * sin(zeit * 17.0 + 1.3))
	if fackel and traegt_fackel: richte_fackel()   # Runde 5b: erst nach dem Schritt (vorher blieb die Fackel ein Bild zurueck)
	richte_funke(dt)   # 677

# ---------------------------------------------------------------- Leuchtfunke (84.5)
# 677 (Chef 08.11., 15:54, t269.15: „Benutzen aus der Tasche tut nichts“): wie alt (WorldScreen.kt 1443–1458, MapLight SPARK): der
# Funke schwebt ueber dem Kopf, treibt langsam im Kreis und wippt, kuehles Weiss mit Hof; im Raum sinkt er klein und matt auf
# Schulterhoehe, draussen steigt er wieder (SparkRise); sein Licht kuehl, schwaecher und kuerzer als die Fackel (5,2 statt 6,2 Kacheln,
# 1,05 statt 1,35), zaehlt nur im Dunkeln. Haengt nicht am Koerper: dreht sich nicht mit dem Helden
const FUNKE_FARBE := Color(0.863, 0.91, 1.0)    # 0xDCE8FF wie alt
var funke_an := false
var funke: Node3D
var funke_licht: OmniLight3D
var funke_kern: MeshInstance3D
var funke_hof: MeshInstance3D
var funke_hoch := 1.0                             # 0 im Raum (Schulter), 1 draussen (ueber dem Kopf); gleitet

func funke_neu(an: bool) -> void:
	funke_an = an
	if an and funke == null: baue_funke()
	if funke: funke.visible = an

func baue_funke() -> void:
	funke = Node3D.new()
	funke.name = "Funke"
	funke.top_level = true
	add_child(funke)
	funke_kern = MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.035; sm.height = 0.07; sm.radial_segments = 12; sm.rings = 6
	funke_kern.mesh = sm
	var km := StandardMaterial3D.new()
	km.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	km.albedo_color = Color(0.957, 0.973, 1.0)   # 0xF4F8FF
	funke_kern.material_override = km
	funke_kern.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	funke.add_child(funke_kern)
	# Hof: weiche Scheibe zur Kamera, innen hell, aussen durchsichtig (wie radialGradient alt)
	funke_hof = MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(0.42, 0.42)
	funke_hof.mesh = qm
	var hs := Shader.new()
	hs.code = """shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;
uniform vec4 farbe : source_color = vec4(0.863, 0.91, 1.0, 1.0);
uniform float staerke = 0.5;
void vertex() { MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]); }
void fragment() {
	float r = length(UV - vec2(0.5)) * 2.0;
	float a = clamp(1.0 - r, 0.0, 1.0);
	ALBEDO = farbe.rgb * a * a * staerke;
}"""
	var hm := ShaderMaterial.new()
	hm.shader = hs
	funke_hof.material_override = hm
	funke_hof.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	funke.add_child(funke_hof)
	funke_licht = OmniLight3D.new()
	funke_licht.light_color = FUNKE_FARBE
	funke_licht.omni_range = 8.0 * 5.2 / 6.2
	funke_licht.omni_attenuation = 2.0
	funke.add_child(funke_licht)
	funke_licht.set_meta("reich", 4.0 * 5.2 / 6.2)   # Tusche nach dem Licht wie die Fackel (348.13b)
	funke_licht.set_meta("kraft", 1.05 / 1.35)
	funke_licht.add_to_group("tuschelicht")

func richte_funke(dt: float) -> void:
	if funke == null or not funke.visible: return
	funke_hoch = move_toward(funke_hoch, 0.0 if im_raum else 1.0, dt / 1.2)
	var up := funke_hoch
	var drift := 0.35 + 0.65 * up
	var t := zeit
	var seite := (0.10 * sin(t / 0.9) + 0.035 * sin(t / 0.37)) * drift + (1.0 - up) * 0.09
	var tiefe := 0.10 * cos(t / 0.9) * drift
	var h := lerpf(1.42, 2.15, up) + 0.04 * drift * sin(t / 0.62)
	funke.global_position = global_position + Vector3(seite, h, tiefe)
	var glanz := (0.85 + 0.15 * sin(t / 0.16)) * (0.55 + 0.45 * up)
	funke_kern.scale = Vector3.ONE * (0.6 + 0.4 * up)
	(funke_hof.material_override as ShaderMaterial).set_shader_parameter("staerke", glanz * (0.25 + 0.35 * nacht_k) * (0.4 + 0.6 * up) * 2.0)
	funke_hof.scale = Vector3.ONE * (0.55 + 0.45 * up)
	funke_licht.light_energy = 2.2 * nacht_k * (1.05 / 1.35) * glanz
	funke_licht.visible = nacht_k > 0.02

func geht() -> bool:
	return weg.size() > 0 or richtung.length() > 0.15

# ---------------------------------------------------------------- Fackel (nachts), in der linken Hand
var fackel_kraft := 0.0
var traegt_fackel := false   # 399.1 Light.torch: nur mit einer Fackel in der Nebenhand (vorher nachts immer)
var im_raum := false         # Light.burns (344.1, Chef 23.10.): in Haeusern, Schenke, Laden, Tempel ohne Flamme gehalten
var nacht_k := 0.0

# 344.1: die Fackel brennt ueberall ausser in einem Raum, Tag und Nacht; ihr Licht zaehlt nur im Dunkeln (Staerke nach der Nacht)
var in_hoehle := false   # 492: alt MapLight „dark = if (map.kind == CAVE) 1.0“: die Fackel brennt dort wie nachts
func fackel_neu(traegt: bool, raum: bool, hoehle := false) -> void:
	traegt_fackel = traegt; im_raum = raum; in_hoehle = hoehle
	nacht(nacht_k)

var mats: Array = []   # Held im Schatten nicht nur Umriss (Probe Build 11), nachts nicht (sonst leuchtet er)

func nacht(k: float) -> void:
	nacht_k = k
	fackel_kraft = 2.2 * (1.0 if in_hoehle else k)
	for m in mats:
		(m as ShaderMaterial).set_shader_parameter("fill", 0.42 * (1.0 - k))
		(m as ShaderMaterial).set_shader_parameter("kette_umgebung", lerpf(1.0, 0.7, k))
	if fackel:
		(fackel.get_parent() as Node3D).visible = traegt_fackel
		flamme.visible = traegt_fackel and not im_raum
		fackel.visible = traegt_fackel and not im_raum and (k > 0.02 or in_hoehle)

func baue_fackel() -> void:
	var sk := Gebiet.finde(modell, "Skeleton3D") as Skeleton3D
	if sk == null: return
	var ba := BoneAttachment3D.new()
	ba.bone_name = faust_knochen
	sk.add_child(ba)
	var t := Node3D.new()
	t.name = "Fackel"
	ba.add_child(t)
	var stiel := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.022; cm.bottom_radius = 0.016; cm.height = 0.42
	stiel.mesh = cm
	var wm := StandardMaterial3D.new()
	wm.albedo_color = Color(0.42, 0.28, 0.16)
	stiel.material_override = wm
	stiel.position = Vector3(0, 0.06, 0)
	stiel.layers = 2                                   # die eigene Flamme beleuchtet den Stiel nicht (sonst gluehte er, Licht vor der Flamme)
	t.add_child(stiel)
	# Runde 5b (Helfer: schwarzer Stummel im Flammenfuss, die Flamme deckt nicht): Pechkopf glimmt am Stielende
	var glut := MeshInstance3D.new()
	var gm := SphereMesh.new()
	gm.radius = 0.03; gm.height = 0.05
	glut.mesh = gm
	var glm := StandardMaterial3D.new()
	glm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glm.albedo_color = Color(0.85, 0.32, 0.08)
	glut.material_override = glm
	glut.position = Vector3(0, 0.27, 0)
	glut.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	t.add_child(glut)
	# Helfer: Flamme „wie Papier“ (ein blassgelber Kegel, flackert kaum): aussen orange, innen hell, beide flackern verschieden
	# Runde 5 (Helfer Runde 3: noch mattes Dreieck mit schwarzer Kontur): additiv leuchtend ohne Tusche (flamme.gdshader), mit Schein
	flamme = MeshInstance3D.new()
	flamme.position = Vector3(0, 0.36, 0)
	t.add_child(flamme)
	var fl: Shader = load("res://shader/flamme.gdshader")
	# Runde 5b (Helfer: glattes Dreieck „wie ein Papierwimpel“): Kern, Mantel und drei Zungen mit eigenem Takt; ueber dem Gras
	# (Gras ist durchsichtig und wurde davor gezeichnet), unter der Tusche
	var form := [[0.055, 0.24, 0.0, 0.0], [0.03, 0.14, 0.0, -0.04], [0.022, 0.15, 0.022, 0.05], [0.02, 0.13, -0.024, 0.04], [0.016, 0.11, 0.0, 0.07]]
	for k in 6:
		var kegel := MeshInstance3D.new()
		var m := ShaderMaterial.new()
		m.shader = fl
		m.render_priority = 100
		if k < 5:
			# Runde 5c (Helfer: „Eistuete“, harte Unterkante, breiteste Stelle unten): Tropfen aus einer Kugel, unten rund, oben spitz
			var fm := SphereMesh.new()
			fm.radius = form[k][0]; fm.height = form[k][1]
			fm.radial_segments = 14; fm.rings = 10
			kegel.mesh = fm
			m.set_shader_parameter("hoehe", fm.height)
			m.set_shader_parameter("saat", 2.3 * k)
			if k == 1: m.set_shader_parameter("aussen", Color(1.0, 0.7, 0.25))
			m.set_shader_parameter("kraft", 0.75 if k < 2 else 0.6)   # Runde 5b (Helfer: fast weiss, ueberbelichtet)
			kegel.position = Vector3(form[k][2], form[k][3], 0.01 * (k - 3) if k >= 2 else 0.0)
		else:
			var qm := QuadMesh.new()
			qm.size = Vector2(0.7, 0.7)
			kegel.mesh = qm
			m.set_shader_parameter("glanz", 1.0)
			kegel.position = Vector3(0, -0.02, 0)
		kegel.material_override = m
		kegel.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		flamme.add_child(kegel)
	fackel = OmniLight3D.new()
	fackel.position = Vector3(0, 0.45, 0)
	fackel.light_color = Color(1.0, 0.72, 0.38)
	fackel.omni_range = 8.0
	fackel.omni_attenuation = 2.0
	fackel.light_cull_mask = 0xFFFFF & ~2
	t.add_child(fackel)
	fackel.set_meta("reich", 4.0)   # 348.13b: Tusche nach der Fackel (am Tag unsichtbar, zaehlt dann nicht)
	fackel.set_meta("kraft", 1.0)
	fackel.add_to_group("tuschelicht")
	nacht(0.0)

func richte_fackel() -> void:
	# Fackel in der linken Faust (Bewegungen _Fackel: Arm vor der Schulter), halb aufgerichtet, folgt der Faust
	var t := find_child("Fackel", true, false) as Node3D
	if t == null: return
	var ba := t.get_parent() as BoneAttachment3D
	var sk := ba.get_parent() as Skeleton3D
	# Runde 5b (Helfer: Stiel hinter dem Unterarm, starr senkrecht, „aufgespiesst“): der Knochen foL-wrL endet am Handgelenk,
	# 7 cm ab seinem Anfang lagen mitten im Unterarm; dazu kam die Haltung vom Bild davor. Jetzt Griff in der Faust (rig.py:
	# Handmitte 6,6 cm hinter dem Handgelenk, zur Handflaeche), Stiel quer durch die Faust, zu zwei Dritteln aufgerichtet
	var pose := sk.global_transform * sk.get_bone_global_pose(sk.find_bone(ba.bone_name))
	var achse := (pose.basis * faust_achse).normalized()
	if achse.y < 0.0: achse = -achse
	var y := achse.lerp(Vector3.UP, 0.65).normalized()
	var x := (global_basis.x - y * global_basis.x.dot(y)).normalized()
	t.global_basis = Basis(x, y, x.cross(y))
	t.global_position = pose * faust_griff
	# Flamme steht unabhaengig vom Stiel aufrecht und weht beim Laufen nach hinten (Runde 5b, gemessen: +X kippt nach vorn)
	var b := Basis(Vector3.UP, rotation.y)
	b = b.rotated(global_basis.x.normalized(), -minf(0.6, tempo_jetzt * 0.12) + 0.1 * sin(zeit * 6.1))
	b = b.rotated(global_basis.z.normalized(), 0.1 * sin(zeit * 8.3))
	# Licht 25 cm vor der Flamme in Blickrichtung (blind 3 von 3 besser: Gesicht lesbar statt Maske; den Stiel beleuchtet es nicht, light_cull_mask)
	fackel.global_position = flamme.global_position + global_basis.z.normalized() * FACKEL_VOR
	flamme.global_basis = b * Basis.from_scale(Vector3(1.0 + 0.12 * sin(zeit * 9.3), 1.0 + 0.3 * sin(zeit * 13.0) * sin(zeit * 5.1), 1.0 + 0.12 * sin(zeit * 7.7)))
const FACKEL_VOR := 0.25
var faust_knochen := "foL-wrL"
var faust_griff := Vector3(-0.0187, 0.187, 0.0072)     # Knochenraum foL-wrL in Ruhelage (aus held3.py hand(): pc + d·3, 2 cm zur Handinnenseite)
var faust_achse := Vector3(-0.358, 0.0, -0.934)        # Breite der Hand (fw) im Knochenraum: der Stiel liegt quer in der Faust
