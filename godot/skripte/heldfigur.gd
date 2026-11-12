class_name HeldFigur
extends RefCounted
# 376.1 (Chef 28.10., 22:0x: „die vier spielbaren Klassen mal auf das gute Modell mit dem guten Kopf … in der [Charaktererstellung]
# doch auch Einfluss nehmen … die jeweiligen Klassen ihre Standard-Grundausruestung kriegen, sichtbar“): der Held je Klasse auf dem
# Kaufkoerper (tools/blender348/v3/held_klassen.py: daten/held_<KLASSE>.bin, haare.bin, bewegungen.bin, held-klassen.json).
# Aussehen (Erschaffung, Zustand.aussehen): Kopfform als Formschluessel, Haar und Bart am Kopfknochen, Haar- und Hautfarbe getoent;
# die angelegte Waffe und der Schild haengen unterwegs auf dem Ruecken (DESIGN-STIL „Ausruestung unterwegs“).
# Fehlen die Dateien (Bau ohne Kaufmodelle), bleibt der bisherige Held (daten/held.bin).
# 376.1 Tracht je Herkunft (Chef 01.11., 11:19 „wie Sokrates“, Archiv): Modell je Tracht und Geschlecht (daten/held_<TRACHT>_<M|W>.bin),
# welche Herkunft welche Tracht traegt, sagt held-klassen.json (herkuenfte); 870.4: die Wahl traegt die Herkunft nach BRS
# („Wachsoldat“ oder ihre Kennung „WACHSOLDAT“), keine Klasse mehr. Kapuze nur, wenn die Herkunft sie traegt; unter ihr kein Haar (langes Haar verborgen). Geschlecht und Statur wie
# alt (CreateScreen.kt, Appearance.kt Sex, Build): aussehen.geschlecht „m“/„w“, aussehen.statur „schlank“/„normal“/„kraeftig“.

const INFO := "res://daten/held-klassen.json"
# form: Formschluessel (leer: wie gekauft); frisur, bart: Netz in haare.bin (leer: ohne); haut, haarfarbe: Nummer im Volk (held.json
# voelker.<VOLK>.haut/haar, Appearance.kt wie die alte Erschaffung)
const VORGABE := {"form": "", "frisur": "Hair_SimpleParted", "bart": "", "haarfarbe": 0, "haut": 0, "geschlecht": "m", "statur": "normal"}
# Heldin: eigene Frisur je Herkunft, ohne Bart (Gesicht, Haut, Haar wie beim Mann der Herkunft); 870.4: je Herkunft wie bisher
# die der Klasse, zu der sie gehoerte (Wachsoldat, Schmiedelehrling, Wanderer wie der Kaempfer …)
const FRAU_FRISUR := {"WACHSOLDAT": "Hair_Ponytail_2", "SCHMIEDELEHRLING": "Hair_Ponytail_2", "WANDERER": "Hair_Ponytail_2",
	"KLOSTERSCHUELER": "Hair_Buns", "HERUMTREIBER": "Hair_Bob", "JAEGERKIND": "Hair_Bob", "KRAEUTERSAMMLER": "Hair_Bob", "ZAUBERLEHRLING": "Hair_Long"}
const GESCHLECHTER := ["m", "w"]
const STATUREN := ["schlank", "normal", "kraeftig"]
# Chef 28.10., 23:0x („die 6 Beispielköpfe … auf Helden drauf basteln“; Haut „klinisch tot“, „normale Hautfarbe oder eine
# klassentypische“): je Klasse ein fertiger Beispielkopf als Vorgabe, keiner mit „Hell“; in der Erschaffung frei aenderbar.
# 870.4: je Herkunft der Kopf der Klasse, zu der sie bisher gehoerte (dasselbe Bild wie vorher)
const KAEMPFER_KOPF := {"form": "kantig", "frisur": "Hair_Buzzed", "bart": "Hair_Beard", "haarfarbe": 0, "haut": 1}
const SCHURKEN_KOPF := {"form": "schmal", "frisur": "Hair_Ponytail", "bart": "", "haarfarbe": 3, "haut": 1}
const HERKUNFT_VORGABE := {
	"WACHSOLDAT": KAEMPFER_KOPF, "SCHMIEDELEHRLING": KAEMPFER_KOPF, "WANDERER": KAEMPFER_KOPF,
	"KLOSTERSCHUELER": {"form": "rund", "frisur": "Hair_Balding", "bart": "Hair_Beard", "haarfarbe": 2, "haut": 2},
	"HERUMTREIBER": SCHURKEN_KOPF, "JAEGERKIND": SCHURKEN_KOPF, "KRAEUTERSAMMLER": SCHURKEN_KOPF,
	"ZAUBERLEHRLING": {"form": "hager", "frisur": "Hair_SlickBack", "bart": "Hair_Moustache", "haarfarbe": 1, "haut": 3},
}
# 870.4: Volk nach BRS -> Koerper und Farben der Figur (held.json voelker, held_klassen.py; Kennungen der Modelle bleiben)
const VOLK_MODELL := {"Mensch": "HUMAN", "Elf": "ELF", "Zwerg": "DWARF", "Hügelvolk": "HALFLING", "Orkblütiger": "HALF_ORC"}
static func volk_modell(v: String) -> String: return String(VOLK_MODELL.get(v, v if v == v.to_upper() and v != "" else "HUMAN"))
# Haut lebendig (Chef 23:0x „klinisch tot“): Licht, Umgebung und Stimmung (licht.gd) nehmen der Haut Farbe (Lauf 1, haut.txt: Wange
# „Warm“ 166/137/104 statt Feld 212/162/124, „Hell“ grau 180/165/141); je Kanal geeicht auf die Farbe des Felds bei gleicher
# Helligkeit (Eichung 1,66/1,39/1,40 durch ihre Helligkeit; nicht heller: Chef „dunkler“), dazu ein Teil der Farbschwankung des Bildes
# 431 (Chef 02.11., 20:37 „Heldenhaut so“; 431e eine Eichung, Bezug Kampfortlicht): gemessen in Lauf 5 41504744398 (EICHUNG HELD)
const HAUT_EICHUNG := Vector3(0.355, 0.219, 0.270)
const HAUT_FARBE := 0.5
# Bewegungen, die sich wiederholen (wie held.gd Gebiet.bewegungen)
const SCHLEIFEN := ["Stehen", "Gehen", "Rennen", "Stehen_2", "Stehen_3", "Sitzen", "Gesten"]

static var info := {}
static var haare_szenen := {}   # Geschlecht -> haare.bin (m), haare_w.bin
static var bew_lib: AnimationLibrary = null
static var bew_becken := 1.0
static var bew_sk: Skeleton3D = null    # Skelett von bewegungen.bin (Ruhelage fuer rennen_umformen)
static var bew_raum := Transform3D.IDENTITY
static var renn_lib := {}               # Art -> umgeformtes „Rennen“
const TAKT_GEHEN := 1.84 * 1.16          # 416.4: m/s, auf die Gehen und Rennen umgetaktet werden (karte.gd gehen, laufen auf Gras)
const TAKT_RENNEN := 3.68 * 1.16
static var tritt_cache := {}             # 416.4: Bewegung|Art -> Vector2(Zeit rechter, linker Ballen setzt auf)
static var stand_cache := {}             # 417: Bewegung|Art|Tracht|Becken|Bein -> Tempo des Standfusses an dieser Figur (m/s)
# 416.4 (Chef 31.10., Build 143: Rennen wirkt „als würde er Hochsprung machen“; 01.11., 11:28 „neuer Film“ mit heute, A, B):
# Jog_Fwd_Loop der UAL ist ein Sprunglauf. flug = Zeit, in der kein Fuss am Boden ist, so viel kuerzer (der Stand bleibt wie die Quelle,
# darum gleitet nichts, held.gd speed_scale bleibt); hub = Anteil, um den sich das Becken ueber seinen Tiefstand hebt. Werte wie
# Spike am CC0-Helden (geruest.py RENNEN_ARTEN); hier am Kaufkoerper, wie er im Spiel laeuft. Urteil des Chefs: Vorgabe RENNEN.
const RENNEN_ARTEN := {"heute": {}, "A": {"flug": 2.0, "hub": 0.35}, "B": {"flug": 2.5, "hub": 0.25}}
const RENNEN := "A"   # Chef 01.11., 13:1x (Archiv 416.4): „Wir nehmen tatsächlich A“; mit Waffe die Pakete (417)
# 417 (Chef 02.11., 14:50/14:52: im Dorf-Film läuft der Held mit Rennen A und mitgetragener Waffe „vernünftig“): Rennen mit Waffe
# „paket“ = Paketbewegung ganz (Sprint, Oberkoerper aufgerichtet, waffengang.py); „A“ = Beine und Rumpf aus Rennen A, Arme ab dem
# Schluesselbein aus der Paketbewegung, im Tritt (rennen_mischen). Vergleichsfilm beider Fassungen, Urteil des Chefs
const WAFFEN_RENNEN := "A"   # 417a 2 (Chef 02.11., 21:24, Votum Tom): Rennen mit Waffe wie im Dorf-Film, Beine und Rumpf aus Rennen A

# Woerter der Erschaffung (376.1; Homer prueft sie, Vorgang 376.1 bei Homer): Gesicht nach den Formen des Kopfblatts (Chef 27.10.,
# 21:41 „Gefällt mir gut“), Frisur und Bart nach den Netzen des Pakets; Frisuren nach dem Bild (Homer 405, STORY-SPIEL [405.frisur])
const WORTE := {
	"form": ["Gesicht", "Face"], "frisur": ["Frisur", "Hairstyle"], "bart": ["Bart", "Beard"],
	"form:": ["Oval", "Oval"], "form:schmal": ["Schmal", "Narrow"], "form:rund": ["Rund", "Round"], "form:kantig": ["Kantig", "Angular"],
	"form:hager": ["Hager", "Gaunt"],
	"frisur:": ["Kahl", "Bald"], "frisur:Hair_SimpleParted": ["Scheitel", "Parted"], "frisur:Hair_Buzzed": ["Kurz", "Buzzed"],
	"frisur:Hair_SlickBack": ["Zerzaust", "Tousled"], "frisur:Hair_Ponytail": ["Zopf", "Ponytail"], "frisur:Hair_Balding": ["Halbglatze", "Balding"],
	"frisur:Hair_Dreads": ["Locken", "Curls"], "frisur:Hair_Mohawk": ["Schopf", "Forelock"],
	"bart:": ["Ohne", "None"], "bart:Hair_Beard": ["Vollbart", "Full beard"], "bart:Hair_Moustache": ["Schnurrbart", "Moustache"],
	"bart:Hair_MuttonChops": ["Koteletten", "Mutton chops"],
	# Frauenhaar (Archiv 376.1 Frisuren, Chef 29.10., 11:43 „Alle bleiben“; Woerter Homer STORY-SPIEL [409.frisur])
	"frisur:Hair_Long": ["Schulterlang", "Shoulder-length"], "frisur:Hair_LongDreads": ["Mähne", "Mane"],
	"frisur:Hair_Ponytail_2": ["Hoher Zopf", "High ponytail"], "frisur:Hair_Bob": ["Pagenkopf", "Bob"], "frisur:Hair_Buns": ["Zwei Knoten", "Twin buns"],
	# wie alt (Appearance.kt Sex, Build)
	"geschlecht:m": ["Männlich", "Male"], "geschlecht:w": ["Weiblich", "Female"],
	"statur:schlank": ["Schlank", "Slim"], "statur:normal": ["Normal", "Average"], "statur:kraeftig": ["Kräftig", "Sturdy"],
}

static func wort(k: String) -> String:
	var w: Array = WORTE.get(k, [k, k])
	return String(w[0] if Sprache.aktiv() == "de" else w[1])

static func formen() -> Array: return [""] + Array(lade_info().get("formen", []))
static func frisuren(g := "m") -> Array: return Array(geschlecht_info(g).get("haare", [])) + [""]
static func baerte(g := "m") -> Array: return [""] + Array(geschlecht_info(g).get("baerte", []))

# Angaben zum Kopf des Geschlechts (held_klassen.py haare): kopf, haut_bild, haar_bild, haare, baerte; ohne „geschlechter“ wie bisher oben
static func geschlecht_info(g: String) -> Dictionary:
	var gs: Dictionary = lade_info().get("geschlechter", {})
	return gs.get(g.to_upper(), gs.get("M", info))

# Herkunft (Spielsystem 2.0, 870.4) der Wahl als Kennung der Trachten (held-klassen.json herkuenfte): „Jägerkind“ -> „JAEGERKIND“;
# ohne Angabe der Wanderer
static func herkunft(w: Dictionary) -> String:
	var h := String(w.get("herkunft", ""))
	return kennung(h if h != "" else "Wanderer")

static func kennung(h: String) -> String:
	return h.to_upper().replace("Ä", "AE").replace("Ö", "OE").replace("Ü", "UE").replace("ß", "SS")

# Modell der Wahl: Tracht der Herkunft und Geschlecht, z. B. „WACHE_W“; kapuze: ob die Herkunft die Kapuze traegt
static func tracht(w: Dictionary) -> Dictionary:
	if String(w.get("modell", "")) != "":   # 475: eine Person des Dorfs (person)
		return {"modell": String(w["modell"]), "kapuze": bool(w.get("kapuze", false)), "geschlecht": String(w["modell"]).right(1)}
	var h: Dictionary = lade_info().get("herkuenfte", {}).get(herkunft(w), {})
	var g := String((w.get("aussehen", {}) as Dictionary).get("geschlecht", "m")).to_upper()
	return {"modell": "%s_%s" % [String(h.get("tracht", "WACHE")), g], "kapuze": bool(h.get("kapuze", false)), "geschlecht": g}

static func lade_info() -> Dictionary:
	if info.is_empty() and FileAccess.file_exists(INFO):
		var j = JSON.parse_string(FileAccess.get_file_as_string(INFO))
		if j is Dictionary: info = j
	return info

static func da(herkunft_: String = "Wachsoldat", geschlecht := "m") -> bool:
	var t := tracht({"herkunft": herkunft_, "aussehen": {"geschlecht": geschlecht}})
	return lade_info().get("trachten", {}).has(t["modell"]) and FileAccess.file_exists("res://daten/held_%s.bin" % t["modell"]) \
		and FileAccess.file_exists("res://daten/bewegungen.bin")

# Auswahl aus dem Spielstand (870.4: der Held nach BRS)
static func wahl(w: BrsHeld, z: Zustand) -> Dictionary:
	return {"herkunft": w.herkunft if w else "Wanderer", "volk": volk_modell(w.volk) if w else "HUMAN", "aussehen": z.aussehen if z else {},
		"ausruestung": w.ausruestung if w else {}}

static func vorgabe(herkunft_: String, geschlecht := "m") -> Dictionary:
	var v := VORGABE.duplicate()
	var k := kennung(herkunft_)
	v.merge(HERKUNFT_VORGABE.get(k, {}), true)
	v["geschlecht"] = geschlecht
	if geschlecht == "w":
		v["frisur"] = String(FRAU_FRISUR.get(k, "Hair_Long")); v["bart"] = ""
	return v

static func aussehen_voll(a: Dictionary, herkunft_ := "") -> Dictionary:
	var v := vorgabe(herkunft_, String(a.get("geschlecht", "m")))
	for k in a: v[k] = a[k]
	return v

# 416.4: Tempo ohne Gleiten der Bewegung n in der Bewegungsdatei (held-klassen.json; Pakete unter gang.<art>), vor dem Umtakten
static func _eigen(n: String) -> float:
	if n == "Gehen": return float(info.get("gehen_m_je_s", 1.08))
	if n == "Rennen": return float(info.get("rennen_m_je_s", 0.0))
	var g: Dictionary = info.get("gang", {}).get(n.get_slice("_", 1), {})
	return float(g.get(("gehen" if n.begins_with("Gehen") else "rennen") + "_m_je_s", 0.0))

# Zeit der Bewegung mal k (k < 1 schneller); Tritte mit
static func umtakten(an: Animation, k: float) -> void:
	if absf(k - 1.0) < 0.001: return
	for t in an.get_track_count():
		var nk := an.track_get_key_count(t)
		for i in (range(nk - 1, -1, -1) if k > 1.0 else range(nk)): an.track_set_key_time(t, i, an.track_get_key_time(t, i) * k)
	an.length *= k
	if an.has_meta("tritt"): an.set_meta("tritt", (an.get_meta("tritt") as Vector2) * k)
	an.set_meta("takt", k)

# 416.4: Zeit, zu der der rechte und der linke Ballen aufsetzt (erstes Bild unter 2 cm ueber dem Tiefstand nach einem Bild darueber);
# Vector2(-1, -1), wenn ein Fuss nie abhebt
static func tritte(an: Animation, sk: Skeleton3D, raum: Transform3D) -> Vector2:
	var h := renn_hoehen(an, sk, raum)
	var z: Array = h["zeit"]
	var r := Vector2(-1, -1)
	for s in 2:
		var y: Array = h["r" if s == 0 else "l"]
		var tief: float = y.min()
		var n := y.size() - 1   # letztes Bild = erstes (Schleife)
		for i in n:
			if y[i] < tief + 0.02 and y[(i - 1 + n) % n] >= tief + 0.02:
				if s == 0: r.x = z[i]
				else: r.y = z[i]
				break
	return r if r.x >= 0.0 and r.y >= 0.0 else Vector2(-1, -1)

# Die Figur: Wurzel des glb mit AnimationPlayer „AnimationPlayer“ (Stehen, Gehen, Rennen, Stehen_2, Stehen_3, …); mats bekommt die
# Toon-Materialien (held.gd: fill, Nacht). Ergebnis in meta: „gehen_m_je_s“, „rennen_m_je_s“, „faust_L“ (Knochen, Griff, Achse)
# 463 (Chef 01.11., 20:3x „Umhang … durchschimmert“, Robe): Rueckseiten und Aermel in der Tiefe zurueck, Werte nach pruef_flecken RUECK
const RUECK := 0.04   # Laeufe 41427986678, 41449210697: mit Unterlagen weg (kauf_kleid UNTER_WEG) Wache Mann 11404 -> 5831, Frau 14284 -> 4788 Flecken
const NACH := 0.0
static func baue(w: Dictionary, mats: Array) -> Node3D:
	var k := String(w.get("herkunft", ""))   # leer (Leute des Dorfs mit „modell“): ohne Beispielkopf
	var a := aussehen_voll(w.get("aussehen", {}), k)
	var t := tracht({"herkunft": k, "aussehen": a, "modell": w.get("modell", ""), "kapuze": w.get("kapuze", false)})
	if not FileAccess.file_exists("res://daten/held_%s.bin" % t["modell"]) or not FileAccess.file_exists("res://daten/bewegungen.bin"): return null
	var m := Gebiet.lade_glb("res://daten/held_%s.bin" % t["modell"])
	if m == null: return null
	m.name = "Held_" + herkunft(w)
	m.set_meta("tracht", t["modell"])
	kapuze(m, t["kapuze"])
	if t["kapuze"]: a["frisur"] = ""   # langes Haar unter der Kapuze verborgen (Archiv 376.1)
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	if sk == null:   # 680: Datei ohne Skelett (verschluesselt ohne Schluessel, beschaedigt): nichts liegen lassen, alte Figur
		m.free()
		return null
	if "--ohneheben" not in OS.get_cmdline_user_args(): sk.add_child(FigurenProbe.KopfHeben.new())   # UAL senkt den Kopf (Helfer 20:2x)
	Gebiet.male(m, null, 2, mats)
	for x in mats:   # 463: Kleidung geschlossen (Innenseiten und Aermel verlieren in der Tiefe; toon.gdshader rueck, nach)
		(x as ShaderMaterial).set_shader_parameter("rueck", RUECK)
		(x as ShaderMaterial).set_shader_parameter("nach", NACH)
	haare(m, sk, String(t["modell"]), a, mats)
	form(m, String(a["form"]))
	statur(m, String(a.get("statur", "normal")))
	toene(m, a, String(w.get("volk", "HUMAN")))
	var f := bewegungen(m, sk, String(w.get("rennen", RENNEN)), String(w.get("waffen_rennen", WAFFEN_RENNEN)))
	m.set_meta("massstab", f)                 # Figur gegen die Bewegungsdatei (Becken)
	m.set_meta("gehen_m_je_s", TAKT_GEHEN)   # 416.4: umgetaktet (bewegungen)
	m.set_meta("rennen_m_je_s", TAKT_RENNEN if float(info.get("rennen_m_je_s", 0.0)) > 0.01 else 0.0)
	m.set_meta("faust_L", faust(sk, "l"))
	bewaffne(m, sk, w.get("ausruestung", {}))
	# 417 Runde 4: mit Paketbewegung („gang“) Tempo ohne Gleiten aus held-klassen.json gang.<art> (held_klassen.py)
	var g: Dictionary = info.get("gang", {}).get(String(m.get_meta("gang", "")), {})
	if not g.is_empty():
		m.set_meta("gang_gehen_m_je_s", TAKT_GEHEN if float(g.get("gehen_m_je_s", 0.0)) > 0.01 else 0.0)
		m.set_meta("gang_rennen_m_je_s", TAKT_RENNEN if float(g.get("rennen_m_je_s", 0.0)) > 0.01 else 0.0)
	return m

# Transform des Knotens n im Raum der Wurzel m (ohne Baum: Figur noch nicht eingehaengt)
static func im_raum(m: Node, n: Node) -> Transform3D:
	var t := Transform3D.IDENTITY
	var x := n
	while x != null and x != m:
		if x is Node3D: t = (x as Node3D).transform * t
		x = x.get_parent()
	return t

# ---------------------------------------------------------------- Bewegungen (UAL, nur Drehungen; Becken im Verhaeltnis der Beckenhoehe)
static func bewegungen(m: Node3D, sk: Skeleton3D, art := RENNEN, waffen_rennen := WAFFEN_RENNEN) -> float:
	if bew_lib == null:
		var sc := Gebiet.lade_glb("res://daten/bewegungen.bin")
		var ap0 := Gebiet.finde(sc, "AnimationPlayer") as AnimationPlayer
		var sk0 := Gebiet.finde(sc, "Skeleton3D") as Skeleton3D
		bew_becken = maxf(0.01, sk0.get_bone_rest(sk0.find_bone("pelvis")).origin.length())
		bew_lib = AnimationLibrary.new()
		for n in ap0.get_animation_list(): bew_lib.add_animation(n, ap0.get_animation(n).duplicate(true))
		bew_raum = im_raum(sc, sk0)
		sk0.get_parent().remove_child(sk0)
		bew_sk = sk0
		sc.free()
	if not RENNEN_ARTEN.has(art): art = RENNEN
	if art != "heute" and not renn_lib.has(art) and bew_lib.has_animation("Rennen"):
		var o: Dictionary = RENNEN_ARTEN[art]
		renn_lib[art] = rennen_umformen(bew_lib.get_animation("Rennen"), bew_sk, bew_raum, float(o.get("flug", 1.0)), float(o.get("hub", 1.0)))
	var f := sk.get_bone_rest(sk.find_bone("pelvis")).origin.length() / bew_becken
	var lib := AnimationLibrary.new()
	var pfad := String(m.get_path_to(sk)) if sk.is_inside_tree() else str(_pfad(m, sk))
	for n in bew_lib.get_animation_list():
		var mix: bool = waffen_rennen == "A" and n.begins_with("Rennen_") and renn_lib.has(art) and info.get("gang", {}).has(n.get_slice("_", 1))   # 417: Beine und Rumpf aus Rennen A
		var mk := "%s|%s" % [n, art]
		if mix and not renn_lib.has(mk): renn_lib[mk] = rennen_mischen(renn_lib[art], bew_lib.get_animation(n), bew_sk, bew_raum)
		var quelle: Animation = renn_lib[mk] if mix else (renn_lib[art] if n == "Rennen" and renn_lib.has(art) else bew_lib.get_animation(n))
		var an := quelle.duplicate(true) as Animation
		for t in range(an.get_track_count() - 1, -1, -1):
			var bn := String(an.track_get_path(t)).get_slice(":", 1)
			an.track_set_path(t, NodePath("%s:%s" % [pfad, bn]))
			var ty := an.track_get_type(t)
			if ty == Animation.TYPE_SCALE_3D or (ty == Animation.TYPE_POSITION_3D and bn not in ["pelvis", "root"]) or sk.find_bone(bn) < 0:
				an.remove_track(t)
			elif ty == Animation.TYPE_POSITION_3D:
				for i in an.track_get_key_count(t): an.track_set_key_value(t, i, an.track_get_key_value(t, i) * f)
		if n in SCHLEIFEN or n.begins_with("Gehen_") or n.begins_with("Rennen_"): an.loop_mode = Animation.LOOP_LINEAR   # 417 Pakete
		if n == "Gehen" or n == "Rennen" or n.begins_with("Gehen_") or n.begins_with("Rennen_"):   # 416.4: Tritte fuer Held.wechsel
			var key := n + "|" + (art if n == "Rennen" or mix else "") + ("|A" if mix else "")
			if not tritt_cache.has(key): tritt_cache[key] = tritte(quelle, bew_sk, bew_raum)
			if tritt_cache[key].x >= 0.0: an.set_meta("tritt", tritt_cache[key])
			# 416.4 Nachmessung (Lauf 41317137978): ein speed_scale fuer beide Bewegungen der Ueberblendung; Gehen (1,0 m/s) und Rennen
			# (5,5 m/s) lagen 5,5-fach auseinander, im Wechsel lief das Rennen 2,9-fach (Beine 40-67 Grad je Bild). Umgetaktet auf das
			# Spieltempo (TAKT_*), dann laufen beide bei speed_scale 1 ohne Gleiten und liegen nur 2-fach auseinander
			# 417 (Pruefer Film 00:53: „Rennen: Fuss 17-28 % langsamer als der Boden, rutscht (alle vier)“): das Tempo der Quelle (held_klassen.py,
			# am UAL-Geruest, 3 cm Toleranz, Bilder) mal Beckenverhaeltnis f traf den Kaufkoerper nicht; jetzt am Skelett dieser Figur gemessen
			# (stand_tempo: Standfuss am Ballen, 120 Proben je Umlauf), Quelle nur, wenn dort nichts messbar ist. „--takt_alt“: wie vorher
			var v0 := _eigen("Rennen" if mix else n) * f
			var v := v0
			if v0 > 0.01 and "--takt_alt" not in OS.get_cmdline_user_args():
				var tk := "%s|%s|%s|%.4f|%.4f|%s" % [n, art, m.get_meta("tracht", ""), f, _beinlaenge(sk), mix]
				if not stand_cache.has(tk): stand_cache[tk] = stand_tempo(an, sk, im_raum(m, sk))
				if float(stand_cache[tk]) > 0.01: v = float(stand_cache[tk])
			an.set_meta("v_quelle", v0); an.set_meta("v_figur", v)
			var ziel: float = TAKT_RENNEN if n.begins_with("Rennen") else TAKT_GEHEN
			if v > 0.01: umtakten(an, v / ziel)
		lib.add_animation(n, an)
	ruhe_spuren(lib, sk)
	var ap := AnimationPlayer.new()
	ap.name = "AnimationPlayer"
	m.add_child(ap)
	ap.root_node = NodePath("..")
	ap.add_animation_library("", lib)
	return f

# 417 (Pruefer Film 03:39: bei 1,0 s schnellt die Figur aus etwa 40 Grad gebueckt auf; Lauf 41387533240): der AnimationPlayer mischt
# nicht deterministisch, ein Knochen ohne Spur in der laufenden Bewegung behaelt die Pose der vorigen. Die Pakete richten im Gehen und
# Rennen spine_01 auf (waffengang.py AUFRICHTEN), Stehen hat dort keine Spur: nach dem Rennen stand die Brust 29-45 Grad vor, bis das
# Gehen sie setzte (Sprung -19 bis -33 Grad in einem Bild); im Spiel ebenso beim Halt aus dem Rennen. Darum bekommt jede Bewegung jede
# Drehspur, die eine andere hat, mit der Ruhelage dieses Skeletts (so wie ohne die fehlende Spur frisch gezeichnet)
static func ruhe_spuren(lib: AnimationLibrary, sk: Skeleton3D) -> void:
	var alle := {}
	for n in lib.get_animation_list():
		var an := lib.get_animation(n)
		for t in an.get_track_count():
			var ty := an.track_get_type(t)
			if ty == Animation.TYPE_ROTATION_3D: alle[an.track_get_path(t)] = true   # Becken (Lage) setzen Kampf und Rennen selbst
	for n in lib.get_animation_list():
		var an := lib.get_animation(n)
		for k in alle:
			if an.find_track(k, Animation.TYPE_ROTATION_3D) >= 0: continue
			var b := sk.find_bone(String(k).get_slice(":", 1))
			if b < 0: continue
			var t := an.add_track(Animation.TYPE_ROTATION_3D)
			an.track_set_path(t, k)
			an.rotation_track_insert_key(t, 0.0, sk.get_bone_rest(b).basis.get_rotation_quaternion())

static func _pfad(m: Node, n: Node) -> NodePath:
	var teile: PackedStringArray = []
	var x := n
	while x != null and x != m:
		teile.insert(0, String(x.name))
		x = x.get_parent()
	return NodePath("/".join(teile))

# ---------------------------------------------------------------- Kopf: Form, Haar, Bart, Farben
static func form(m: Node3D, f: String) -> void:
	_schluessel(m, formen(), f)

# Statur (376.1): Formschluessel „statur_schlank“, „statur_kraeftig“ an jedem Netz (held_klassen.py statur); „normal“: keiner
static func statur(m: Node3D, s: String) -> void:
	_schluessel(m, STATUREN.map(func(x): return "statur_" + x), "statur_" + s)

# aus der Gruppe namen genau den Schluessel n an, die anderen der Gruppe aus (andere Schluessel bleiben)
static func _schluessel(m: Node3D, namen: Array, n: String) -> void:
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var me := (mi as MeshInstance3D).mesh as ArrayMesh
		if me == null: continue
		for i in me.get_blend_shape_count():
			var bn := String(me.get_blend_shape_name(i))
			if bn in namen: (mi as MeshInstance3D).set_blend_shape_value(i, 1.0 if bn == n else 0.0)

# Kapuze der Waldtracht (Head_Hood) nur, wenn die Herkunft sie traegt (Jaegerkind ja, Herumtreiber nein)
static func kapuze(m: Node3D, an: bool) -> void:
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		if String(mi.name).contains("Head_Hood"): (mi as MeshInstance3D).visible = an

static func haare(m: Node3D, sk: Skeleton3D, k: String, a: Dictionary, mats: Array) -> void:
	var g := String(a.get("geschlecht", "m")).to_lower()
	var datei := "res://daten/haare.bin" if g == "m" else "res://daten/haare_%s.bin" % g
	if not FileAccess.file_exists(datei): return
	if not haare_szenen.has(g): haare_szenen[g] = Gebiet.lade_glb(datei)
	var hs: Node3D = haare_szenen[g]
	var kb := sk.find_bone("Head")
	if hs == null or kb < 0: return
	# Haare liegen in der Ruhelage der Bezugsfigur des Geschlechts (Kopfknochen bei kopf); an diesen Kopf nur verschoben
	var ref: Array = geschlecht_info(g).get("kopf", [0, 0, 0])
	var ich: Array = info.get("trachten", {}).get(k, {}).get("kopf", ref)
	var vers := Vector3(ich[0] - ref[0], ich[1] - ref[1], ich[2] - ref[2])
	var ruhe := im_raum(m, sk) * sk.get_bone_global_rest(kb)
	# 475 Lauf 2: Bart auch als Liste mit Komma (Schnauzer und Kinnbart), weitere Formen aus held_klassen.py baerte_mehr
	for n in [String(a.get("frisur", ""))] + Array(String(a.get("bart", "")).split(",", false)):
		if n == "": continue
		var q := hs.find_child(n, true, false) as MeshInstance3D
		if q == null: continue
		var ba := BoneAttachment3D.new()
		ba.name = "Haar_" + n
		ba.bone_name = "Head"
		sk.add_child(ba)
		var mi := MeshInstance3D.new()
		mi.name = n
		mi.mesh = q.mesh
		mi.transform = ruhe.affine_inverse() * Transform3D(Basis(), vers) * im_raum(hs, q)
		ba.add_child(mi)
		Gebiet.male(mi, null, 2, mats)

# Haut und Haar: die Zeichnung des Bildes im Ton des Volks (Appearance.kt): Farbe = Zielton x Bildhelligkeit / mittlere Helligkeit
# des Bildes an Gesicht bzw. Haar (held_klassen.py: haut_bild, haar_bild). Ein Faktor je Kanal (Lauf 1) gab fahles Gelbgruen: Rot
# des hell-rosigen Bildes lief ueber, Gruen und Blau wurden vervielfacht (Pruefer 22:5x: Wange 193/192/157 statt „Hell“ EACBAE)
static func toene(m: Node3D, a: Dictionary, volk: String) -> void:
	var haut := ton(volk, "haut", int(a.get("haut", 0)))
	var haar := ton(volk, "haar", int(a.get("haarfarbe", 0)))
	if a.has("haut_rgb"): haut = Color.html(String(a["haut_rgb"]))   # 475: Leute mit eigenem Ton (leute.json haut, haar)
	if a.has("haar_rgb"): haar = Color.html(String(a["haar_rgb"]))
	var gi := geschlecht_info(String(a.get("geschlecht", "m")))
	var hb := _hell(gi.get("haut_bild", [1, 1, 1]))
	var hh := _hell(gi.get("haar_bild", [1, 1, 1]))
	var hbild := _lin(gi.get("haut_bild", [1, 1, 1]))
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var me := (mi as MeshInstance3D).mesh
		for i in me.get_surface_count():
			var src := me.surface_get_material(i)
			var rn := String(src.resource_name) if src else ""
			var sm := (mi as MeshInstance3D).get_surface_override_material(i) as ShaderMaterial
			if sm == null: continue
			var z := Color(-1, 0, 0)
			var b := 0.0
			var ist_haut := rn.contains("Regular") or rn.contains("Superhero")
			if ist_haut: z = haut; b = hb
			elif rn.contains("Hair"):
				z = haar; b = hh
				# 475 (Lauf 10.11., 02:06: Brauen bei hellem Haar zu hell, Morwen, Liska, Pim, Lyra): Brauen der Leute dunkler als das Haar
				if a.has("haar_rgb") and String(mi.name).begins_with("Eyebrows"): z = haar.darkened(0.45)
			if z.r < 0.0: continue
			var l := z.srgb_to_linear()
			var t := Vector3(l.r, l.g, l.b)
			if ist_haut:
				t *= haut_eichung()
				sm.set_shader_parameter("toen_bild", hbild)
				sm.set_shader_parameter("toen_farbe", haut_farbe())
			sm.set_shader_parameter("toenung", t)
			sm.set_shader_parameter("toen_hell", b)

# Probe am Rechner (Klassenlauf): --hauteichung=r,g,b und --hautfarbe=x ersetzen die Konstanten
static func haut_eichung() -> Vector3:
	for x in OS.get_cmdline_user_args():
		if x.begins_with("--hauteichung="):
			var p := x.substr(14).split(",")
			return Vector3(float(p[0]), float(p[1]), float(p[2]))
	return HAUT_EICHUNG

static func haut_farbe() -> float:
	for x in OS.get_cmdline_user_args():
		if x.begins_with("--hautfarbe="): return float(x.substr(12))
	return HAUT_FARBE

static func _lin(c: Array) -> Vector3:
	var l := Color(float(c[0]), float(c[1]), float(c[2])).srgb_to_linear()
	return Vector3(l.r, l.g, l.b)

static func _hell(c: Array) -> float:
	var l := Color(float(c[0]), float(c[1]), float(c[2])).srgb_to_linear()
	return maxf(0.01, 0.2126 * l.r + 0.7152 * l.g + 0.0722 * l.b)

static func toene_liste(volk: String, was: String) -> Array:
	var v: Dictionary = BrsHeld.daten().get("voelker", {}).get(volk_modell(volk), {})
	return v.get(was, [])

static func ton(volk: String, was: String, i: int) -> Color:
	var l := toene_liste(volk, was)
	if l.is_empty(): return Color(-1, 0, 0)
	return Color.html(String(l[clampi(i, 0, l.size() - 1)]["rgb"]))

# Faust der Kaufhand: Griff zwischen den Knoecheln von Zeige- und Kleinfinger, Achse dazwischen; 653: aus der Halterung je Koerper
# (Halt.halterung „faust_r“/„faust_l“), eine Quelle fuer Tragen, Prüfbild und Kampf
static func faust(sk: Skeleton3D, s: String) -> Dictionary:
	var h := Halt.halterung(sk, "faust_" + s)
	if h.is_empty(): return {}
	var l: Transform3D = h["lage"]
	return {"knochen": h["knochen"], "griff": l.origin, "achse": l.basis.y.normalized()}

# ---------------------------------------------------------------- Ausruestung unterwegs: Schild und Waffe auf dem Ruecken
static func bewaffne(m: Node3D, sk: Skeleton3D, aus: Dictionary) -> void:
	for alt in sk.find_children("Ruecken*", "", false, false): alt.free()
	var bi := sk.find_bone("spine_03")
	if bi < 0: return
	var brust := im_raum(m, sk) * sk.get_bone_global_rest(bi)
	var pts := haut_punkte(m, sk, false)
	# 522 (Chef 04.11., 11:55: Streitkolben und Dolch angelegt, am Helden nichts): ein Dolch in der Nebenhand ist kein Schild; bis er
	# einen eigenen Platz am Koerper hat, haengt nur ein Schild auf dem Ruecken
	var neben = aus.get("OFF_HAND")
	var schild := _modell(neben) if neben is Dictionary and String(Beute.grundform(String(neben.get("base", ""))).get("art", "")) == "SHIELD" else ""
	var waffe := _modell(aus.get("MAIN_HAND"))
	# Ruhelage: die Figur blickt nach +Z, ihre linke Seite ist +X. Schild auf dem Ruecken (Vorderseite nach hinten), geneigt wie der
	# Ruecken zwischen Schulterblatt und Kreuz (Pruefer Lauf 1: unten 5-7 cm Spalt); die Waffe schraeg, Griff ueber der rechten
	# Schulter, hinter allem, was hinten am weitesten absteht (Lauf 1: Schwert hinter dem Schild verdeckt, Parierstange im Umhang)
	var y := brust.origin.y
	var r := ruecken_aus(pts, y - 0.63, y + 0.1)   # [z oben, z unten, hinterste z]: Ruecken an Ober- und Unterkante des Schilds
	var aussen: float = r[2]
	if schild != "":
		# Pruefer Lauf 2 (Kaempfer: Schild ragt von vorn ueber die Schultern; Schild 0,72 m, Oberkante 1,54 m, Schultern 1,46 m):
		# Mitte 29 cm unter spine_03, Oberkante etwa 1,32 m (376.1 Lauf 1: bei 1,42 m von schraeg oben noch ueber den Schultern)
		var oben := Vector3(0, y - 0.05, float(r[0]) - 0.03)
		var unten := Vector3(0, y - 0.53, float(r[1]) - 0.03)
		var hoch := (oben - unten).normalized()
		var t := Transform3D(Basis(Vector3.LEFT, hoch, Vector3.LEFT.cross(hoch)), (oben + unten) * 0.5)
		# 406 (Jerry): gewölbte Kaufschilde reichen am Rand hinter die Fessel (Drachenschild 3,8 cm, rund 1,7 cm); so weit weiter
		# vom Rücken, wie der Rand hinter ihr liegt (die eigenen aus waffen.py sind am Rand flach: 0), sonst ragten Schulter und
		# Oberarm tiefer hinein als beim alten Schild (gemessen tests/schild_406.gd)
		var weg := rand_hinten(schild)
		t.origin += t.basis.z * weg
		# 499 (Chef 07.11.: „Schild unten zu weit weg“; Lauf 291): in „Stehen“ kippt spine_03 21,8 Grad vor, Becken und spine_01 7-8 Grad
		# zurueck; am Brustwirbel schwang die Unterkante 28-30 cm vom Ruecken (oben 4 cm). Der Schild haengt darum am mittleren Wirbel
		# (spine_02, 2 Grad), der zwischen Ober- und Unterkante liegt, und liegt am Ruecken, wie er in „Stehen“ steht (Drehteller,
		# Erschaffung, Ruhe im Spiel; am Rechner mit spine_02 aus der Ruhe noch 4 bzw. 8 cm unten)
		var mi := sk.find_bone("spine_02")
		if mi < 0: mi = bi
		var anker := im_raum(m, sk) * sk.get_bone_global_rest(mi)
		var lagen := haltung_lagen(m, sk, "Stehen")
		if not lagen.is_empty():
			# Mitte 29 cm unter spine_03 wie oben; die Neigung nach dem ganzen Schild: die Gerade, die hinter allem zwischen Unter- und
			# Oberkante liegt und in der Mitte am naechsten am Ruecken ist (am Rechner Kaempfer unten 3,6 cm, oben 1,9 cm; Kleriker oben
			# 2,6 cm, die Spitze des Drachenschilds 8 cm ueber den Oberschenkeln, das Gesaess steht 5 cm weiter ab)
			var hh := schild_hoehe(schild)
			# 499 (Chef 08.11., 12:41: „früher … eher am Nackenabschluss … jetzt … eher über den Arsch“): Oberkante wie alt (Dress.kt
			# shieldOnBack) 0,045 x Koerperhoehe ueber der Schulterlinie (Schultergelenke 0,022 x Hoehe tiefer), in „Stehen“; vorher Mitte
			# 29 cm unter spine_03 (Oberkante 1,32 m, etwa Brusthoehe)
			var yc := y - 0.29
			var ul := sk.find_bone("upperarm_l"); var ur := sk.find_bone("upperarm_r")
			if ul >= 0 and ur >= 0:
				var ks := im_raum(m, sk)
				var sy := ((ks * (lagen[ul] as Transform3D)).origin.y + (ks * (lagen[ur] as Transform3D)).origin.y) * 0.5
				var hy := Vector2(INF, -INF)
				for p in pts: hy = Vector2(minf(hy.x, p.y), maxf(hy.y, p.y))
				var koerper := hy.y - hy.x if hy.x < hy.y else 1.8
				yc = sy + 0.023 * koerper - hh.y
			var li := ruecken_linie(haut_punkte(m, sk, true, null, lagen), yc + hh.x, yc + hh.y)
			if not li.is_empty():
				var o2 := Vector3(0, yc + hh.y, float(li[0]) + float(li[1]) * (yc + hh.y) - 0.03)
				var u2 := Vector3(0, yc + hh.x, float(li[0]) + float(li[1]) * (yc + hh.x) - 0.03)
				var h2 := (o2 - u2).normalized()
				t = Transform3D(Basis(Vector3.LEFT, h2, Vector3.LEFT.cross(h2)), Vector3(0, yc, float(li[0]) + float(li[1]) * yc - 0.03))
				t.origin += t.basis.z * weg
			anker = im_raum(m, sk) * (lagen[mi] as Transform3D)
		_haenge(m, sk, mi, anker, schild, t, "RueckenSchild")
		aussen = minf(aussen, (oben.z + unten.z) * 0.5) - 0.10 - weg   # Schild mit Buckel (376.1 Lauf 2: bei 7 cm durchdrang der Buckel das Schwert)
	# 417 Runde 6: Godot benennt den zweiten gleichnamigen Knoten „@Getragen@…“ bzw. „@Tragen@…“; „Getragen*“ fand ihn nicht, beim
	# Wechsel der Ausruestung blieb der Schild der Paketbewegung in der Hand (Messung: zweiter Tragen-Knoten nie gefunden)
	for alt in m.get_children():
		if String(alt.name).contains("Getragen"): alt.free()
	for alt in sk.get_children():
		if alt is Tragen: alt.free()
	var art := Tragen.art_von(waffe)
	var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
	var gang := Tragen.gang_von(waffe, schild != "")
	# 417a (Chef 02.11., 21:24 „was gut funktioniert … das Schild darf halt weder da schweben, noch darf, wenn es am Arm ist, der Arm
	# durchschauen“; Votum 1a): Kaempfer wie Kleriker, Schild flach auf dem Ruecken (oben), Schwert in der Hand mit dem Einhandgang;
	# der Schildgang des Pakets hielt den Schild vor dem Bauch und die Klinge quer vor dem Hals (Pruefer Vergleichsfilm 19:1x, E3, E8)
	if gang == "schild": gang = "einhand"
	if gang != "" and ap and ap.has_animation("Gehen_" + gang):   # 417 Runde 4: Paketbewegung fuehrt den Arm, Waffe in der Hand
		var paare := [[waffe, gang, "r"]] + ([[schild, "schildarm", "l"]] if gang == "schild" else [])
		if gang == "bogen": paare[0][2] = "l"
		for p in paare:
			var d := Gebiet.lade_glb("res://daten/waffen/%s.bin" % p[0])
			if d == null: continue
			d.name = "Getragen"
			d.top_level = true
			m.add_child(d)
			Gebiet.male(d, null, 2, [])
			var t := Tragen.new("", d, m, faust(sk, String(p[2])))
			t.halt = Halt.gegenstand(String(p[0]))   # 653: Griff und Schneide je Modell
			t.gang = String(p[1]); t.seite = String(p[2]); t.anim = ap
			sk.add_child(t)
		m.set_meta("gang", gang)
		return
	if art != "":   # 417: Stab, Axt, Bogen unterwegs in der Hand (tragen.gd)
		var d := Gebiet.lade_glb("res://daten/waffen/%s.bin" % waffe)
		if d == null: return
		d.name = "Getragen"
		d.top_level = true
		m.add_child(d)
		Gebiet.male(d, null, 2, [])
		var t := Tragen.new(art, d, m, faust(sk, String(Tragen.LAGE[art]["seite"])))
		t.halt = Halt.gegenstand(waffe)   # 653
		t.anim = Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		sk.add_child(t)
		return
	if waffe != "":
		var lang := waffe in ["quarterstaff", "staff", "spear", "greataxe"]
		var achse := Vector3(0.42, -1.0, 0.0).normalized() if not lang else Vector3(0.62, -1.0, 0.0).normalized()   # Klinge zur linken Huefte
		var griff := Vector3(-0.17, y + 0.22, aussen - 0.03) if not lang else Vector3(-0.05, y + 0.05, aussen - 0.03)
		var quer := Vector3.FORWARD
		var t := Transform3D(Basis(achse.cross(quer).normalized(), achse, quer), griff)
		_haenge(m, sk, bi, brust, waffe, t, "RueckenWaffe")

# hinterste Stelle des Rumpfs (z, Ruhelage) auf Hoehe des Schulterblatts (y1 - 0,15) und des Kreuzes (y0 + 0,1), dazu die hinterste
# zwischen y0 und y1; nur die Mitte (|x| < 0,12), alle Netze mit Haut (Koerper, Kleidung, Umhang)
static func ruecken(m: Node3D, y0: float, y1: float) -> Array: return ruecken_aus(haut_punkte(m, null, false), y0, y1)

static func ruecken_aus(pts: PackedVector3Array, y0: float, y1: float) -> Array:
	var oben := 9.0; var unten := 9.0; var ganz := 9.0
	for p in pts:
		if absf(p.x) > 0.12 or p.y < y0 or p.y > y1: continue
		ganz = minf(ganz, p.z)
		if absf(p.y - (y1 - 0.15)) < 0.04: oben = minf(oben, p.z)
		if absf(p.y - (y0 + 0.1)) < 0.04: unten = minf(unten, p.z)
	if ganz > 8.0: ganz = -0.15
	return [oben if oben < 8.0 else ganz, unten if unten < 8.0 else ganz, ganz]

# 499: Lagen aller Knochen (im Raum des Skeletts) in der Haltung [name] zur Zeit 0, aus dem AnimationPlayer der Figur, von Hand
# vorwaerts gerechnet: ausserhalb des Baums rechnet das Skelett set_bone_pose nicht nach (Lauf 291 und am Rechner: der Versuch mit
# „Stehen“ aenderte nichts). Leer, wenn die Haltung fehlt
static func haltung_lagen(m: Node3D, sk: Skeleton3D, name: String) -> Array:
	var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
	if ap == null or not ap.has_animation(name): return []
	var an := ap.get_animation(name)
	var sp := _spuren(an)
	var lagen := []
	lagen.resize(sk.get_bone_count())
	var fertig := []
	fertig.resize(sk.get_bone_count())
	fertig.fill(false)
	var rechne := func(selbst: Callable, b: int) -> Transform3D:
		if fertig[b]: return lagen[b]
		var rest := sk.get_bone_rest(b)
		var e: Dictionary = sp.get(sk.get_bone_name(b), {})
		var q: Quaternion = an.rotation_track_interpolate(e["rot"], 0.0) if e.has("rot") else rest.basis.get_rotation_quaternion()
		var p: Vector3 = an.position_track_interpolate(e["pos"], 0.0) if e.has("pos") else rest.origin
		var l := Transform3D(Basis(q).scaled(sk.get_bone_pose_scale(b)), p)
		var v := sk.get_bone_parent(b)
		if v >= 0: l = selbst.call(selbst, v) * l
		lagen[b] = l; fertig[b] = true
		return l
	for b in sk.get_bone_count(): rechne.call(rechne, b)
	return lagen

# Ecken aller Netze mit Haut im Raum der Wurzel m (ohne deren eigene Lage): Ruhelage, oder mit [haltung] nach der Lage der Knochen
# (wie die Haut sie zeichnet); [nur]: ein Netz. Mit Haltung nur die Mitte (Ruhe |x| < 0,2), sonst dauert es zu lange
static func haut_punkte(m: Node3D, _sk: Skeleton3D, haltung: bool, nur: MeshInstance3D = null, lagen := [], breite := 0.2) -> PackedVector3Array:
	var aus := PackedVector3Array()
	for mi in ([nur] if nur else m.find_children("*", "MeshInstance3D", true, false)):
		var x := mi as MeshInstance3D
		if not x.skin: continue
		var t := im_raum(m, x)
		var sk := x.get_node_or_null(x.skeleton) as Skeleton3D
		if sk == null: sk = _sk
		var ks := im_raum(m, sk) if sk else Transform3D.IDENTITY
		for s in x.mesh.get_surface_count():
			var arr := x.mesh.surface_get_arrays(s)
			var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
			if not haltung or sk == null:
				for v in vs: aus.append(t * v)
				continue
			var bo = arr[Mesh.ARRAY_BONES]; var we = arr[Mesh.ARRAY_WEIGHTS]
			if bo == null or vs.is_empty(): continue
			var n := int(bo.size() / vs.size())
			for i in vs.size():
				if absf((t * vs[i]).x) > breite: continue   # 653: mit breite = INF auch die Arme (Schild am Unterarm)
				var w := Vector3.ZERO
				for j in n:
					var g: float = we[i * n + j]
					if g <= 0.0: continue
					var bind: int = bo[i * n + j]
					var bone := x.skin.get_bind_bone(bind)
					if bone < 0: bone = sk.find_bone(x.skin.get_bind_name(bind))
					var gl: Transform3D = lagen[bone] if bone < lagen.size() else sk.get_bone_global_pose(bone)
					w += (ks * gl * x.skin.get_bind_pose(bind) * vs[i]) * g
				aus.append(w)
	return aus

## 406: wie weit der Schild außerhalb der Mitte (mehr als 15 cm seitlich der Fessel) hinter die Fessel reicht (glTF: vorn +z), in m
static func rand_hinten(was: String) -> float:
	var d := Gebiet.lade_glb("res://daten/waffen/%s.bin" % was)
	if d == null: return 0.0
	var h := 0.0
	for mi in d.find_children("*", "MeshInstance3D", true, false) + ([d] if d is MeshInstance3D else []):
		var me := (mi as MeshInstance3D).mesh
		var tr := im_raum(d, mi)
		for s in me.get_surface_count():
			for v in me.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				var p: Vector3 = tr * v
				if absf(p.x) > 0.15: h = maxf(h, -p.z)
	d.free()
	return h

## 499: Unter- und Oberkante des Schilds (y im Raum des Modells, Vector2(unten, oben))
static func schild_hoehe(was: String) -> Vector2:
	var d := Gebiet.lade_glb("res://daten/waffen/%s.bin" % was)
	if d == null: return Vector2(-0.24, 0.24)
	var r := Vector2(INF, -INF)
	for mi in d.find_children("*", "MeshInstance3D", true, false) + ([d] if d is MeshInstance3D else []):
		var me := (mi as MeshInstance3D).mesh
		var tr := im_raum(d, mi)
		for s in me.get_surface_count():
			for v in me.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				var y: float = (tr * v).y
				r = Vector2(minf(r.x, y), maxf(r.y, y))
	d.free()
	return r if r.x < r.y else Vector2(-0.24, 0.24)

## 499: Ruecken als Gerade z = a + b * y zwischen y0 und y1 (Mitte |x| < 0,12, Baender zu 3 cm, je die hinterste Stelle): die Gerade
## durch zwei Baender, hinter der kein Band liegt und die in der Mitte am wenigsten Abstand hat; [a, b], leer ohne zwei Baender
static func ruecken_linie(pts: PackedVector3Array, y0: float, y1: float) -> Array:
	var n := maxi(2, int((y1 - y0) / 0.03))
	var z := []
	z.resize(n); z.fill(INF)
	for p in pts:
		if absf(p.x) > 0.12 or p.y < y0 or p.y > y1: continue
		var i := mini(n - 1, int((p.y - y0) / (y1 - y0) * n))
		z[i] = minf(z[i], p.z)
	var bd := []
	for i in n:
		if z[i] < INF: bd.append(Vector2(y0 + (i + 0.5) * (y1 - y0) / n, z[i]))
	if bd.size() < 2: return []
	var ym := (y0 + y1) * 0.5
	var best := []
	var bester := -INF
	for i in bd.size():
		for j in range(i + 1, bd.size()):
			var b: float = (bd[j].y - bd[i].y) / (bd[j].x - bd[i].x)
			var a: float = bd[i].y - b * bd[i].x
			var ok := true
			for q in bd:
				if a + b * q.x > q.y + 0.001: ok = false; break
			if ok and a + b * ym > bester: bester = a + b * ym; best = [a, b]
	return best

static func _modell(g) -> String:
	if not g is Dictionary: return ""
	var b := String(g.get("base", ""))
	return b if FileAccess.file_exists("res://daten/waffen/%s.bin" % b) else ""

static func _haenge(m: Node3D, sk: Skeleton3D, bi: int, brust: Transform3D, was: String, t: Transform3D, nm: String) -> void:
	var ba := BoneAttachment3D.new()
	ba.name = nm
	ba.bone_name = sk.get_bone_name(bi)
	sk.add_child(ba)
	var d := Gebiet.lade_glb("res://daten/waffen/%s.bin" % was)
	if d == null: return
	d.transform = brust.affine_inverse() * t
	ba.add_child(d)
	Gebiet.male(d, null, 2, [])

# ---------------------------------------------------------------- 416.4 Rennen umformen (ohne Baum: Vorwaertskinematik aus den Spuren)
# Spuren je Knochen: {"rot": Spur, "pos": Spur}
static func _spuren(an: Animation) -> Dictionary:
	var sp := {}
	for t in an.get_track_count():
		var bn := String(an.track_get_path(t)).get_slice(":", 1)
		if bn == "": continue
		var ty := an.track_get_type(t)
		if not sp.has(bn): sp[bn] = {}
		var e: Dictionary = sp[bn]
		if ty == Animation.TYPE_ROTATION_3D: e["rot"] = t
		elif ty == Animation.TYPE_POSITION_3D: e["pos"] = t
	return sp

# Lage des Knochens b im Raum der Figur (raum = Skelett in der Figur) zur Zeit t; ab: Ersatz der Lage einzelner Knochen {Name: Vector3}
static func knochen_lage(an: Animation, sp: Dictionary, sk: Skeleton3D, raum: Transform3D, b: int, t: float, ab := {}) -> Transform3D:
	var kette := []
	var i := b
	while i >= 0:
		kette.push_front(i); i = sk.get_bone_parent(i)
	var g := raum
	for k in kette:
		var rest := sk.get_bone_rest(k)
		var n := sk.get_bone_name(k)
		var s: Dictionary = sp.get(n, {})
		var q: Quaternion = an.rotation_track_interpolate(s["rot"], t) if s.has("rot") else rest.basis.get_rotation_quaternion()
		var p: Vector3 = an.position_track_interpolate(s["pos"], t) if s.has("pos") else rest.origin
		if ab.has(n): p = ab[n]
		g = g * Transform3D(Basis(q), p)
	return g

# Zeiten der Bilder: die Schluessel der laengsten Spur (UAL: jedes Bild), dazu das Ende
static func _bilder(an: Animation) -> Array:
	var best := -1
	for t in an.get_track_count():
		if best < 0 or an.track_get_key_count(t) > an.track_get_key_count(best): best = t
	var z := []
	for k in an.track_get_key_count(best): z.append(an.track_get_key_time(best, k))
	if z.is_empty() or z[-1] < an.length - 0.0001: z.append(an.length)
	return z

# 417: Tempo ohne Gleiten an diesem Skelett (wie figurenprobe.gd schritt_tempo): je Ballen die Rueckwaertsgeschwindigkeit (Blick +Z) in den
# Proben hoechstens tol ueber seinem Tiefstand, Median; 0, wenn weniger als vier Proben
static func stand_tempo(an: Animation, sk: Skeleton3D, raum: Transform3D, tol := 0.02, n := 120) -> float:
	var sp := _spuren(an)
	var L := maxf(0.001, an.length)
	var vs := []
	for bn in ["ball_l", "ball_r"]:
		var b := sk.find_bone(bn)
		if b < 0: b = sk.find_bone(bn.replace("ball", "foot"))
		if b < 0: return 0.0
		var d := []; var h := []
		for j in n + 1:
			var o := knochen_lage(an, sp, sk, raum, b, L * j / n).origin
			d.append(o.z); h.append(o.y)
		var tief: float = h.min()
		for j in n:
			if h[j] < tief + tol and h[j + 1] < tief + tol: vs.append((d[j] - d[j + 1]) * n / L)
	if vs.size() < 4: return 0.0
	vs.sort()
	return maxf(float(vs[vs.size() / 2]), 0.0)

static func _beinlaenge(sk: Skeleton3D) -> float:
	var s := 0.0
	for bn in ["calf_l", "foot_l", "ball_l"]:
		var b := sk.find_bone(bn)
		if b >= 0: s += sk.get_bone_rest(b).origin.length()
	return s

# Hoehe beider Fuesse und des Beckens je Bild: {"zeit": [], "l": [], "r": [], "becken": []}; Fuss am Ballen (Spike, rennen_4164:
# im Lauf hebt sich die Ferse im Stand, der Knoechel stieg ueber 2 cm und galt als Flug)
static func renn_hoehen(an: Animation, sk: Skeleton3D, raum: Transform3D) -> Dictionary:
	var sp := _spuren(an)
	var fl := sk.find_bone("ball_l"); var fr := sk.find_bone("ball_r"); var pe := sk.find_bone("pelvis")
	if fl < 0 or fr < 0: fl = sk.find_bone("foot_l"); fr = sk.find_bone("foot_r")
	var h := {"zeit": _bilder(an), "l": [], "r": [], "becken": []}
	for t in h["zeit"]:
		h["l"].append(knochen_lage(an, sp, sk, raum, fl, t).origin.y)
		h["r"].append(knochen_lage(an, sp, sk, raum, fr, t).origin.y)
		h["becken"].append(knochen_lage(an, sp, sk, raum, pe, t).origin.y)
	return h

static func rennen_umformen(an0: Animation, sk: Skeleton3D, raum: Transform3D, flug: float, hub: float) -> Animation:
	var an := an0.duplicate(true) as Animation
	var sp := _spuren(an)
	var h := renn_hoehen(an0, sk, raum)
	var zeit: Array = h["zeit"]
	var tl: float = h["l"].min(); var tr: float = h["r"].min(); var bm: float = h["becken"].min()
	# Becken: Heben ueber den Tiefstand auf hub gedaempft, im Raum der Figur senkrecht, zurueck in den Raum des Elternknochens.
	# Lauf 1 (01.11., 12:4x, rennen_kauf_4164: Ballen bei A 2,2 cm, bei B 3,0 cm unter dem Boden): das Becken senkte sich auch, wenn ein
	# Fuss stand. Gesenkt wird hoechstens so weit, wie der tiefere Ballen ueber seinem Tiefstand ist (das Becken traegt beide Fuesse mit)
	var pe := sk.find_bone("pelvis")
	var bl := sk.find_bone("ball_l"); var br := sk.find_bone("ball_r")
	if bl < 0 or br < 0: bl = sk.find_bone("foot_l"); br = sk.find_bone("foot_r")
	if hub != 1.0 and sp.get("pelvis", {}).has("pos"):
		var st: int = sp["pelvis"]["pos"]
		var eltern := sk.get_bone_parent(pe)
		for k in an.track_get_key_count(st):
			var t := an.track_get_key_time(st, k)
			var y := knochen_lage(an0, sp, sk, raum, pe, t).origin.y
			var b := knochen_lage(an0, sp, sk, raum, eltern, t).basis if eltern >= 0 else raum.basis
			var frei := maxf(0.0, minf(knochen_lage(an0, sp, sk, raum, bl, t).origin.y - tl, knochen_lage(an0, sp, sk, raum, br, t).origin.y - tr))
			var d := b.inverse() * Vector3(0, -minf((1.0 - hub) * (y - bm), frei), 0)
			an.track_set_key_value(st, k, (an.track_get_key_value(st, k) as Vector3) + d)
	# Zeit: Bilder ohne Fuss am Boden (2 cm ueber seinem Tiefstand) laufen flug-mal so schnell
	if flug != 1.0:
		var gew := []
		for i in zeit.size(): gew.append(1.0 if (h["l"][i] < tl + 0.02 or h["r"][i] < tr + 0.02) else 1.0 / flug)
		var neu := [0.0]
		for i in zeit.size() - 1: neu.append(neu[i] + (zeit[i + 1] - zeit[i]) * (gew[i] + gew[i + 1]) / 2.0)
		for t in an.get_track_count():
			for k in an.track_get_key_count(t):
				an.track_set_key_time(t, k, _abbild(an0.track_get_key_time(t, k), zeit, neu))
		an.length = neu[-1]
	return an

# 417 Fassung „A“ (WAFFEN_RENNEN): Rennen A (a0, schon umgeformt) mit den Armen der Paketbewegung p0. Arme = Schluesselbein und alles
# darunter (Hand, Finger; die Waffe sitzt an der Faust, tragen.gd); Beine, Becken, Ruecken, Kopf aus A. Je Bild von A die Pose des Arms
# aus p0 in derselben Schrittphase (0 rechter Ballen setzt auf, 0,5 linker; Held.schritt_phase), damit der Arm gegen das Bein schwingt
static func rennen_mischen(a0: Animation, p0: Animation, sk: Skeleton3D, raum: Transform3D) -> Animation:
	var an := a0.duplicate(true) as Animation
	var arm := {}
	for i in sk.get_bone_count():
		var j := i
		while j >= 0:
			if sk.get_bone_name(j).begins_with("clavicle_"):
				arm[sk.get_bone_name(i)] = true
				break
			j = sk.get_bone_parent(j)
	for t in range(an.get_track_count() - 1, -1, -1):
		if arm.has(String(an.track_get_path(t)).get_slice(":", 1)): an.remove_track(t)
	# Stellvertreter nur fuer die Phase (Laenge und Tritte), die Bibliothek bleibt unberuehrt
	var za := Animation.new(); za.length = a0.length
	var zp := Animation.new(); zp.length = p0.length
	var ta := tritte(a0, sk, raum); var tp := tritte(p0, sk, raum)
	if ta.x >= 0.0 and tp.x >= 0.0:
		za.set_meta("tritt", ta); zp.set_meta("tritt", tp)
	var zeiten := _bilder(a0)
	for t in p0.get_track_count():
		if p0.track_get_type(t) != Animation.TYPE_ROTATION_3D: continue
		if not arm.has(String(p0.track_get_path(t)).get_slice(":", 1)): continue
		var nt := an.add_track(Animation.TYPE_ROTATION_3D)
		an.track_set_path(nt, p0.track_get_path(t))
		for z in zeiten:
			var zt := Held.schritt_zeit(zp, Held.schritt_phase(za, z))
			an.rotation_track_insert_key(nt, z, p0.rotation_track_interpolate(t, zt))
	an.set_meta("gemischt", [ta, tp])
	return an

static func _abbild(t: float, zeit: Array, neu: Array) -> float:
	for i in zeit.size() - 1:
		if t <= zeit[i + 1]:
			var a: float = (t - zeit[i]) / maxf(0.000001, zeit[i + 1] - zeit[i])
			return lerpf(neu[i], neu[i + 1], clampf(a, 0.0, 1.0))
	return neu[-1]

# ---------------------------------------------------------------- 475 Leute auf dem Kaufkoerper
# Chef 03.11., 07:45/07:47 („die NPCs alle noch ganz schrecklich … mit individuellem Gesicht und nicht nur das Standard-Volksgesicht“):
# jede Person des Dorfs als Kaufkoerper in ihrer Kleidung (held_klassen.py LEUTE_KAUF: daten/held_L_<id>_<M|W>.bin, leute-kauf.json)
# mit eigenem Gesicht aus den Wahlen des Kaufkopfs (leute.json „kauf“: form, frisur, bart, statur; Liste Person -> Wahl im Vorrat,
# Zu 475), Haut- und Haarton der Person (leute.json haut, haar), Haltung (gebeugt, kopfhaltung), Kind und Zwerg: Groesse und Kopf.
# Ohne Kaufdateien null: dann bleibt die alte Figur (daten/leute/<id>.bin)
const LEUTE_KAUF := "res://daten/leute-kauf.json"
const LEUTE_LISTE := "res://daten/leute/leute.json"
static var leute_liste := {}
static var leute_kauf := {}

static func person_daten(id: String) -> Dictionary:
	if leute_liste.is_empty() and FileAccess.file_exists(LEUTE_LISTE):
		var j = JSON.parse_string(FileAccess.get_file_as_string(LEUTE_LISTE))
		if j is Dictionary: leute_liste = j
	return leute_liste.get(id, {})

# Modellname der Person (L_<id>_<M|W>), leer ohne Kaufdatei
static func person_modell(id: String) -> String:
	var p := person_daten(id)
	if (p.get("kauf", {}) as Dictionary).is_empty(): return ""
	if leute_kauf.is_empty() and FileAccess.file_exists(LEUTE_KAUF):
		var j = JSON.parse_string(FileAccess.get_file_as_string(LEUTE_KAUF))
		if j is Dictionary: leute_kauf = j
	var mo := "L_%s_%s" % [id, "W" if String(p.get("sex", "m")) == "w" else "M"]
	if not leute_kauf.get("trachten", {}).has(mo): return ""
	if not FileAccess.file_exists("res://daten/held_%s.bin" % mo) or not FileAccess.file_exists("res://daten/bewegungen.bin"): return ""
	return mo

static func person(id: String, mats: Array) -> Node3D:
	var mo := person_modell(id)
	if mo == "": return null
	var p := person_daten(id)
	var ka: Dictionary = p["kauf"]
	lade_info()
	if not info.has("trachten"): info["trachten"] = {}
	info["trachten"][mo] = leute_kauf["trachten"][mo]   # haare(): Lage des Kopfs dieses Modells
	var g := mo.right(1).to_lower()
	var kopf := String(p.get("kopf", "haar"))
	var a := {"form": String(ka.get("form", "")), "frisur": String(ka.get("frisur", "")), "bart": String(ka.get("bart", "")),
		"geschlecht": g, "statur": String(ka.get("statur", "normal")), "haut_rgb": String(p.get("haut", "D4A27C")),
		"haar_rgb": String(p.get("haar", "5E3C26"))}
	if kopf in ["helm", "tuch", "kapuze"]: a["frisur"] = ""   # unter Helm, Kopftuch, Kapuze kein Haar (wie Archiv 376.1)
	var w := {"herkunft": "", "modell": mo, "kapuze": kopf == "kapuze", "aussehen": a, "volk": "HUMAN",
		"ausruestung": {"MAIN_HAND": String(p["traegt"])} if String(p.get("traegt", "")) != "" else {}}
	var m := baue(w, mats)
	if m == null: return null
	gesicht(m, ka.get("gesicht", {}))
	m.name = "Person_" + id
	m.scale = Vector3.ONE * float(ka.get("groesse", p.get("groesse", 1.0)))
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var kh: Array = p.get("kopfhaltung", [0, 0, 0])
	var h := Haltung.new()
	h.name = "Haltung"
	h.gebeugt = float(p.get("gebeugt", 0.0))
	h.kopf = Vector3(float(kh[0]), float(kh[1]), float(kh[2]))
	h.kopf_gross = float(ka.get("kopf", 1.0))
	sk.add_child(h)
	return m

# 475 (Chef 04.11., 13:26: „Borik, Bran und Ostik sehen sich aus, als ob sie eineiige Zwillinge wären … ein Gesicht definiert sich über die
# Form des Gesichts“): Gesicht je Person aus den Reglern des Kopfs (kopf.py REGLER, EINHEIT; held_klassen.py Schluessel „r_<regler>“),
# an Haut, Augen, Brauen, Haar und Bart gleich; g = {regler: Wert} wie kopf.form_aus
const EINHEIT := {"breite": 0.1, "kiefer": 0.1, "laenge": 0.1, "kinn": 0.01, "nase": 0.1, "wangen": 0.01, "brauen": 0.01, "ohren": 0.1, "augen": 0.01,
	"hoecker": 0.01, "nasenbreite": 0.1, "spitze": 0.01, "augen_gross": 0.1, "augen_schmal": 0.1, "augen_tief": 0.01, "bdick": 0.1, "bwinkel": 0.01}   # Lauf 2: Form (kopf.py)
static func gesicht(m: Node3D, g: Dictionary) -> void:
	if g.is_empty(): return
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var me := (mi as MeshInstance3D).mesh as ArrayMesh
		if me == null: continue
		for i in me.get_blend_shape_count():
			var bn := String(me.get_blend_shape_name(i))
			if bn.begins_with("r_") and EINHEIT.has(bn.substr(2)):
				(mi as MeshInstance3D).set_blend_shape_value(i, float(g.get(bn.substr(2), 0.0)) / float(EINHEIT[bn.substr(2)]))

# 475: Haltung der Person nach der Bewegung: gebeugt (Grad, auf spine_01..03 verteilt, nach vorn), Kopf [nicken, drehen, neigen] (Grad,
# auf neck_01 und Head), Kopfgroesse (Kind, Zwerg). Figur blickt nach +Z: nach vorn beugen = um +X
class Haltung extends SkeletonModifier3D:
	var gebeugt := 0.0
	var kopf := Vector3.ZERO
	var kopf_gross := 1.0
	func _drehe(sk: Skeleton3D, i: int, r: Basis) -> void:
		var g := sk.get_bone_global_pose(i)
		var pa := sk.get_bone_parent(i)
		var pg := sk.get_bone_global_pose(pa) if pa >= 0 else Transform3D.IDENTITY
		sk.set_bone_pose_rotation(i, (pg.basis.orthonormalized().inverse() * (r * g.basis.orthonormalized())).get_rotation_quaternion())
	func _process_modification() -> void:
		var sk := get_skeleton()
		if sk == null: return
		if absf(gebeugt) > 0.1:
			for n in ["spine_01", "spine_02", "spine_03"]:
				var i := sk.find_bone(n)
				if i >= 0: _drehe(sk, i, Basis(Vector3.RIGHT, deg_to_rad(gebeugt / 3.0)))
		if kopf.length() > 0.1:
			var r := Basis(Vector3.UP, deg_to_rad(kopf.y)) * Basis(Vector3.RIGHT, deg_to_rad(kopf.x)) * Basis(Vector3.BACK, deg_to_rad(kopf.z))
			var q := r.get_rotation_quaternion()
			for n in ["neck_01", "Head"]:
				var i := sk.find_bone(n)
				if i >= 0: _drehe(sk, i, Basis(Quaternion.IDENTITY.slerp(q, 0.5)))
		var h := sk.find_bone("Head")
		if h >= 0 and absf(kopf_gross - 1.0) > 0.001: sk.set_bone_pose_scale(h, Vector3.ONE * kopf_gross)
