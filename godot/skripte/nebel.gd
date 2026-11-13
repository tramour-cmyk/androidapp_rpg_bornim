class_name Nebel
extends Node
# 505 (Archiv 502, Chef 03.11., 07:30: „den Nebel brauchen wir auf jeden Fall“): Nebel des Krieges und Sicht des Helden wie alt
# (Fog.kt Sight, Game.fogged, WorldScreen.drawFog und FogFade). In der Wildnis (Wald, Hoehle) schwarz, was nie gesehen wurde,
# gedaempft, was gerade nicht in Sicht ist; Sicht = Kegel in Gehrichtung plus kleiner Kreis, Baeume, Felsen, Waende sperren
# (Bresenham wie lineOfSight); Gesehenes bleibt (Zustand.erkundet, gespeichert); Leute und Monster ausser Sicht unsichtbar.
# Draussen ist ein Baum nie schwarz (t732), jenseits des Rands nie dunkler als gesehen. Je Kachel 4 x 4 Teile (SUB), die
# Kegelkante darum rund (13e); jeder Wechsel blendet in etwa 150 ms (FADE_MS 450 / 3).
# Form des Sichtfelds (Chef 07:30: „ob wir das Sichtfeld doch ein bisschen anders machen“): FORMEN, alt = "kegel"; vor dem Bau
# als Vorlage an den Chef; entschieden C rundum (Chef 10:08, Archiv 505 C).

const SUB := 4
const UNDURCHSICHTIG := ["TREE", "ROCK", "WALL", "CAVE_WALL", "ROOF", "ROOF_BLUE", "WINDOW", "TORCH", "SHELF", "CRYSTAL"]
const HOEHLENFELS := ["CAVE_WALL", "CRYSTAL", "TORCH"]
## 505 Lauf 2 (Chef 16:12, Zu 505, zweiter Durchgang: „Dorf mit Nebel zeigen“; 505c (1) gilt fuer Wald, Dorf und Hoehle): im Dorf
## ist ein Haus ganz bekannt, sobald ein Teil davon gesehen ist, und ganz in Sicht, wenn ein Teil in Sicht ist (sonst blieben die
## Daecher hinter der Vorderwand fuer immer schwarz, die Sicht endet an der ersten Wand)
const HAUS := ["ROOF", "ROOF_BLUE", "WALL", "WINDOW"]
const DARK_SIGHT := 4.2            # Light.kt
const DAY_SIGHT := 5.2
const SPARK_SIGHT := 5.5
const TORCH_SIGHT := 6.5
const FADE_MS := 450.0
## 505c (Chef 04.11., 14:06, Zu 505 (Rand) (1): „erkundet“ deutlich dunkler als „in Sicht“, aber erkennbar; alt 0,5, gemessen 57
## gegen 65 zu hell): Wert der Nebelkarte fuer gesehen, ausser Sicht (Deckung im Shader 0,92 davon), Wald und Hoehle gleich
const GESEHEN := 0.72
## 505c (2): jenseits des Kartenrands kein Nebel; der Randwald laeuft nach aussen ins Dunkel wie alt (MapEdge.fade, 27m): so viele
## Kacheln bleibt sein Licht, bis RAND_SCHWARZ ist er schwarz (randwald in dorf.py RING_WEIT, die Kamera haelt davor, kamera.gd)
const RAND_HELL := 1.0              # 505 Lauf 2 (Chef 16:12 (2): „nach außen dunkler“): ab einer Kachel hinter dem Rand (vorher 2)
const RAND_SCHWARZ := 11.0
const RAND_NEBEL := 1.0            # Kacheln, in denen der Nebel der Randkachel ausklingt (sonst harte Kante am Kartenrand)
## Formen zur Wahl: Kegel (cos der halben Oeffnung) und Kreis ringsum (Kacheln); alt: 160° plus 2 Kacheln
const FORMEN := {"kegel": [0.17, 2.0], "kreis": [-1.0, 0.0], "breit": [-0.5, 2.0]}
static var form := "kreis"     # Chef 03.11., 10:08 „505 C“ (Archiv): rundum gleich weit; FORMEN bleiben für den Bildlauf
## Baeume ausser Sicht (Chef 03.11., 16:13: „… ich sehe trotzdem die Baeume dahinter … da müsste … halt auch das dunkel sein,
## wenn ich es nicht sehe“): "alt" wie Fog.kt (t732: draussen nie schwarz, immer gedaempft); "boden": ein Baum zeigt, was der
## Held vom naechsten freien Boden weiss (im tiefen Wald vom naechsten in jeder Entfernung, sonst blieben dort Inseln fuer immer
## schwarz, der Grund fuer t732); jenseits des Rands so wie der Rand. Zur Wahl im Bildlauf (fassung), bis der Chef entscheidet.
## Entschieden B (Chef 04.11., 14:06, „Vorgang 505c“, Zu 505 (Rand) (1)); "alt" bleibt fuer den Vergleich im Test.
static var baeume := "boden"

var spiel                          # spiel.gd
var karte: Karte
var an := false
var rand_an := false               # 505c: Rand ins Dunkel (auch ohne Nebel, Dorf)
var breite := 0
var hoehe := 0
var sichtbar := PackedByteArray()  # Kachel jetzt in Sicht
var frei := PackedByteArray()      # Kachel nah genug, nichts dazwischen (fuer in_sicht)
var reich := 0.0
var blick := Vector2(0, 1)
var schluessel := ""
var erkundet := PackedByteArray()
var ist := PackedFloat32Array()    # je Teil: wie dunkel jetzt
var soll := PackedFloat32Array()   # je Teil: wohin es blendet
var aktiv := {}                    # Teile, die noch blenden
var bild: Image
var tex: ImageTexture
var flaeche: MeshInstance3D
var mat: ShaderMaterial
var neu := true
var naechster := {}                # "boden": Baumkachel -> Kacheln des naechsten freien Bodens
var dorf := false
var haus_von := PackedInt32Array()  # Dorf: je Kachel das Haus (-1 keins)
var haeuser: Array = []             # je Haus seine Kacheln
var haus_wert := PackedInt32Array() # je Haus: hoechste Stufe seiner Kacheln (nach jedem neu_sehen)
var dinge: Array = []               # [Node3D, Kachel]: Lichter, Rauch, Flammen, Staub, Lichtstrahl der Karte

func _init(s, k: Karte) -> void:
	spiel = s
	karte = k
	var art := String(k.daten.get("art", ""))
	an = art == "FOREST" or art == "CAVE" or art == "TOWN"   # Game.fogged; 505 Lauf 2 auch das Dorf
	# 505c: Randdunkel im Nebelbild; auf den Gebietskarten dunkelt seit 1022 jedes Netz selbst ab (rand_licht, gebiet.gd rand_karte,
	# vom Chef abgenommen), beides zusammen waere doppelt dunkel. Der Grundriss der Hoehle hat keinen rand_karte und behaelt es
	rand_an = art == "CAVE"
	breite = k.breite; hoehe = k.hoehe
	name = "Nebel"

func _ready() -> void:
	if not an and not rand_an: return
	if an:
		sichtbar.resize(breite * hoehe); frei.resize(breite * hoehe)
		erkundet = lade(spiel.zustand, karte.id, breite * hoehe)
		ist.resize(breite * hoehe * SUB * SUB); ist.fill(1.0)
		soll.resize(ist.size()); soll.fill(1.0)
		bild = Image.create(breite * SUB, hoehe * SUB, false, Image.FORMAT_L8)
		bild.fill(Color(1, 1, 1))
	else:   # Dorf: nur der Rand, die Nebelkarte bleibt klar
		bild = Image.create(1, 1, false, Image.FORMAT_L8)
		bild.fill(Color(0, 0, 0))
	tex = ImageTexture.create_from_image(bild)
	flaeche = MeshInstance3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(2, 2)
	flaeche.mesh = qm
	flaeche.extra_cull_margin = 16384.0
	flaeche.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mat = ShaderMaterial.new()
	mat.shader = load("res://shader/nebel.gdshader")
	mat.render_priority = 127      # nach allem, auch nach der Tusche (kamera.gd): naeher an der Kamera, darum spaeter gezeichnet
	mat.set_shader_parameter("nebel", tex)
	mat.set_shader_parameter("groesse", Vector2(breite, hoehe) * Karte.TS)
	mat.set_shader_parameter("teile", Vector2(breite, hoehe))
	mat.set_shader_parameter("rand_hoechstens", rand())
	mat.set_shader_parameter("rand_nebel", RAND_NEBEL * Karte.TS)
	mat.set_shader_parameter("rand_hell", RAND_HELL * Karte.TS)
	mat.set_shader_parameter("rand_schwarz", RAND_SCHWARZ * Karte.TS if rand_an else 1.0e6)
	mat.set_shader_parameter("hoehle", 1.0 if String(karte.daten.get("art", "")) == "CAVE" else 0.0)
	mat.set_shader_parameter("licht_gang", hoehlen_ausgang())
	flaeche.material_override = mat
	flaeche.position = Vector3(0, 0, -0.9)
	spiel.kamera.add_child(flaeche)
	dorf = String(karte.daten.get("art", "")) == "TOWN"
	if dorf: haeuser_suchen()
	if String(karte.daten.get("art", "")) in ["FOREST", "TOWN"]: boden_suchen()
	haeuser_werten()
	dinge_sammeln()

## 505 Lauf 2 (Pruefer 16:01: „Lichtscheine … auch Rauch und Glut eines Feuers“ im Unbekannten, „rötlicher und türkiser Schein“
## der Nachbarraeume; Chef 16:12 (1): nichts scheint durch): Rauch steigt ueber Gesehenes, ein Licht leuchtet ueber die Wand in
## den Nachbarraum; darum gibt es Lichter, Teilchen und Lichtstrahlen auf nie gesehenen Kacheln nicht, bis der Held dort war
func dinge_sammeln() -> void:
	dinge.clear()
	var g = spiel.get("gebiet")
	if g == null or not an: return
	var liste: Array = g.find_children("*", "Light3D", true, false) + g.find_children("*", "CPUParticles3D", true, false) \
		+ g.find_children("*", "GPUParticles3D", true, false)
	for m in g.find_children("Strahl*", "MeshInstance3D", true, false): liste.append(m)
	for n in liste:
		if n is Node3D and (n as Node3D).is_inside_tree(): dinge.append([n, karte.pos_kachel((n as Node3D).global_position)])
	dinge_zeigen()

func dinge_zeigen() -> void:
	for d in dinge:
		if not is_instance_valid(d[0]): continue
		var t: Vector2i = d[1]
		(d[0] as Node3D).visible = Testmodus.alles_sichtbar or not innen(t.x, t.y) or nebel(t.x, t.y) > 0

## jenseits des Kartenrands hoechstens so dunkel: 505c (2) kein Nebel ueber dem Randwald (klingt in RAND_NEBEL aus); alt (Vergleich)
## nie dunkler als gesehen (t732)
## 505 Lauf 2 (Pruefer 16:01: „dunkles Nebelband mit harter Kante, wie ein See vor einem leuchtenden Wald“; Chef 16:12 (2): gleiches
## Schwarz, keine harte Kante): der Randwald traegt den Nebel der naechsten Randkachel (der Shader greift am Rand ab), hinter
## Unbekanntem also schwarz, hinter Gesehenem gedaempft; nach aussen laeuft er dazu ins Dunkel
func rand() -> float:
	return 0.5 if baeume == "alt" else 1.0

## 505c (4), alt MapEdge.fade (13e.5, D1.6): der Gang aus der Hoehle bleibt hell, das Tageslicht kommt von dort; Mitte und halbe
## Breite der Ausgangskacheln am Rand in Metern (x, z, halbe Breite, 1 = Suedrand), sonst 0
func hoehlen_ausgang() -> Vector4:
	if String(karte.daten.get("art", "")) != "CAVE": return Vector4.ZERO
	var xs: Array = []
	for t in karte.ausgaenge:
		if (t as Vector2i).y == hoehe - 1: xs.append((t as Vector2i).x)
	if xs.is_empty(): return Vector4.ZERO
	var a: float = float(xs.min()) * Karte.TS; var b: float = float(xs.max() + 1) * Karte.TS
	return Vector4((a + b) / 2.0, hoehe * Karte.TS, (b - a) / 2.0, 1.0)

## Dorf: zusammenhaengende Hauskacheln (Dach, Wand, Fenster) je Haus
func haeuser_suchen() -> void:
	haus_von.resize(breite * hoehe); haus_von.fill(-1)
	haeuser.clear()
	for i in breite * hoehe:
		if haus_von[i] >= 0 or not zeichen_name(i % breite, i / breite) in HAUS: continue
		var teile := PackedInt32Array()
		var offen := [i]
		haus_von[i] = haeuser.size()
		while not offen.is_empty():
			var j: int = offen.pop_back()
			teile.append(j)
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var x: int = j % breite + d.x; var y: int = j / breite + d.y
				if not innen(x, y): continue
				var k := y * breite + x
				if haus_von[k] < 0 and zeichen_name(x, y) in HAUS:
					haus_von[k] = haeuser.size(); offen.append(k)
		haeuser.append(teile)
	haus_wert.resize(haeuser.size())

func haeuser_werten() -> void:
	if not dorf or sichtbar.is_empty(): return
	for h in haeuser.size():
		var b := 0
		for j in haeuser[h]: b = maxi(b, roh(j))
		haus_wert[h] = b

## "boden": je Baum die freien Kacheln im kleinsten Abstand (Schachbrett), alle gleich nahen
func boden_suchen() -> void:
	naechster.clear()
	for ty in hoehe:
		for tx in breite:
			if zeichen_name(tx, ty) != "TREE": continue
			var r := 1
			var hier := PackedInt32Array()
			while hier.is_empty() and r <= maxi(breite, hoehe):
				for dy in range(-r, r + 1):
					for dx in range(-r, r + 1):
						if maxi(absi(dx), absi(dy)) != r: continue
						var x := tx + dx; var y := ty + dy
						if innen(x, y) and zeichen_name(x, y) != "TREE": hier.append(y * breite + x)
				r += 1
			naechster[ty * breite + tx] = hier

## Bildlauf: Fassung der Baeume wechseln und alles sofort neu zeichnen (ohne Blenden)
func fassung(b: String) -> void:
	baeume = b
	if mat: mat.set_shader_parameter("rand_hoechstens", rand())
	schluessel = ""
	neu = true

func _exit_tree() -> void:
	if is_instance_valid(flaeche): flaeche.queue_free()

# ---------------------------------------------------------------- gespeichert wie GameState.explored: je Karte hex, 4 Kacheln je Ziffer
static func lade(z, id: String, n: int) -> PackedByteArray:
	var b := PackedByteArray(); b.resize(n)
	var hex: String = String(z.erkundet.get(id, ""))
	for i in n:
		var c := i / 4
		if c < hex.length() and (hex[c].hex_to_int() >> (i % 4)) & 1 == 1: b[i] = 1
	return b

func speichere() -> void:
	var s := ""
	var i := 0
	while i < erkundet.size():
		var v := 0
		for b in 4:
			if i + b < erkundet.size() and erkundet[i + b] == 1: v |= 1 << b
		s += "%x" % v
		i += 4
	spiel.zustand.erkundet[karte.id] = s

# ---------------------------------------------------------------- Sicht (Sight.update)
func zeichen_name(x: int, y: int) -> String:
	return String(karte.kacheln.get(karte.zeichen(Vector2i(x, y)), {}).get("name", ""))

func innen(x: int, y: int) -> bool: return x >= 0 and y >= 0 and x < breite and y < hoehe

func weite() -> float:
	var dunkel: bool = spiel.im_dunkeln()
	var s := DAY_SIGHT
	if dunkel:
		if Menue.fackel(spiel.held_werte()): s = TORCH_SIGHT
		elif spiel.zustand.funke: s = SPARK_SIGHT
		else: s = DARK_SIGHT
	# Perks.sightBonus (alt 0,5 je Mod der Weisheit über 0); nach BRS halb so viel je Punkt Wahrnehmung über „sinne_ab“,
	# umgerechnet wie der Hinterhalt (werte.json welt „_sinne“: alt 15 % je Mod, BRS 7,5 % je Punkt)
	var w := BrsHeld.welt()
	return s + 0.25 * maxi(0, spiel.held_werte().wert("wahrnehmung") - int(w.get("sinne_ab", 3)))

func neu_sehen(h: Vector2i, gier: float) -> bool:
	var grad := roundf(rad_to_deg(gier) / 5.0) * 5.0   # in Schritten von 5°, sonst rechnet jede kleine Drehung neu
	var r_ := weite()
	var k := "%d/%d/%s/%s/%s" % [h.x, h.y, grad, r_, form]
	if k == schluessel: return false
	schluessel = k
	blick = Vector2(sin(deg_to_rad(grad)), cos(deg_to_rad(grad)))
	sichtbar.fill(0); frei.fill(0)
	reich = r_
	var kegel: float = FORMEN[form][0]
	var r := int(r_) + 2
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			var x := h.x + dx; var y := h.y + dy
			if not innen(x, y): continue
			var d := sqrt(float(dx * dx + dy * dy))
			var nah := d <= 1.5
			var los := nah or sicht_frei(h.x, h.y, x, y)
			if d <= r_ + 1 and los: frei[y * breite + x] = 1
			if not nah:
				if d > r_: continue
				if (dx * blick.x + dy * blick.y) / d < kegel: continue
				if not los: continue
			sichtbar[y * breite + x] = 1
	var geaendert := false
	for i in sichtbar.size():
		if sichtbar[i] == 1 and erkundet[i] == 0:
			erkundet[i] = 1; geaendert = true
	if geaendert: speichere()
	haeuser_werten()
	return true

## nichts Undurchsichtiges zwischen den Kacheln (die letzte darf ein Baum sein); Hoehle: niedrige Waende spaeter (492, MapCaveIso.low)
func sicht_frei(x0: int, y0: int, x1: int, y1: int) -> bool:
	var x := x0; var y := y0
	var dx := absi(x1 - x0); var dy := -absi(y1 - y0)
	var sx := 1 if x0 < x1 else -1
	var sy := 1 if y0 < y1 else -1
	var err := dx + dy
	while true:
		if x == x1 and y == y1: return true
		if (x != x0 or y != y0) and zeichen_name(x, y) in UNDURCHSICHTIG: return false
		var e2 := 2 * err
		if e2 >= dy: err += dy; x += sx
		if e2 <= dx: err += dx; y += sy
	return true

func roh(i: int) -> int:   # 0 verborgen, 1 gesehen, 2 in Sicht (Fog)
	if sichtbar[i] == 1: return 2
	return 1 if erkundet[i] == 1 else 0

func fest(x: int, y: int) -> bool:
	var n := zeichen_name(x, y)
	if dorf and n in HAUS: return true
	return n in HOEHLENFELS if String(karte.daten.get("art", "")) == "CAVE" else n == "TREE"

## Sight.fog(view = true): 0 verborgen, 1 gesehen, 2 in Sicht
func nebel(x: int, y: int) -> int:
	if not innen(x, y): return 0
	var eigen := roh(y * breite + x)
	var hoehle := String(karte.daten.get("art", "")) == "CAVE"
	if not fest(x, y): return eigen
	if dorf and haus_von.size() > 0 and haus_von[y * breite + x] >= 0: return haus_wert[haus_von[y * breite + x]]
	if not hoehle:
		if eigen == 2 or baeume != "boden": return eigen if eigen == 2 else 1   # alt: draussen ist ein Baum nie schwarz (t732)
		var bb := eigen
		for i in naechster.get(y * breite + x, PackedInt32Array()): bb = maxi(bb, roh(i))
		return bb
	var best := eigen
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			var nx := x + dx; var ny := y + dy
			if not innen(nx, ny) or fest(nx, ny): continue
			best = maxi(best, roh(ny * breite + nx))
	return best

## Sight.inSight: Punkt in Kacheln, feiner als eine Kachel (Kegelkante als Linie, 13e)
func in_sicht_punkt(px: float, py: float) -> bool:
	if not an: return true
	var tx := floori(px); var ty := floori(py)
	if not innen(tx, ty): return false
	if String(karte.daten.get("art", "")) == "CAVE" and zeichen_name(tx, ty) in HOEHLENFELS: return nebel(tx, ty) == 2
	if dorf and haus_von[ty * breite + tx] >= 0: return nebel(tx, ty) == 2
	if frei[ty * breite + tx] == 0: return false
	var h: Vector2i = spiel.held.kachel
	var dx := px - (h.x + 0.5); var dy := py - (h.y + 0.5)
	var d := sqrt(dx * dx + dy * dy)
	var f: Array = FORMEN[form]
	if d <= maxf(2.0, float(f[1])) and float(f[1]) > 0.0: return true
	if d > reich: return false
	if d < 0.001: return true
	return (dx * blick.x + dy * blick.y) / d >= float(f[0])

## bilinear zwischen den Kachelmitten (ausserhalb der Karte: 1)
func weich(kw: PackedFloat32Array, x: float, y: float) -> float:
	var ix := floori(x); var iy := floori(y)
	var fx := x - ix; var fy := y - iy
	return (kw_bei(kw, ix, iy) * (1.0 - fx) + kw_bei(kw, ix + 1, iy) * fx) * (1.0 - fy) + (kw_bei(kw, ix, iy + 1) * (1.0 - fx) + kw_bei(kw, ix + 1, iy + 1) * fx) * fy

func kw_bei(kw: PackedFloat32Array, tx: int, ty: int) -> float:
	return kw[ty * breite + tx] if tx >= 0 and ty >= 0 and tx < breite and ty < hoehe else 1.0

## fuer den Bildlauf (--nebel): alles vergessen, wie beim ersten Betreten
func vergiss() -> void:
	erkundet.fill(0)
	haeuser_werten()
	schluessel = ""
	neu = true

## Leute und Monster: gezeichnet nur auf einer Kachel in Sicht (WorldScreen: fog(npc) != VISIBLE → nicht gezeichnet)
func zeigt(t: Vector2i) -> bool:
	return not an or Testmodus.alles_sichtbar or nebel(t.x, t.y) == 2

# ---------------------------------------------------------------- je Bild: Ziele neu, wenn der Held geht oder sich dreht, dann blenden
func schritt(dt: float) -> void:
	if not an or spiel.held == null: return
	# 555 Testmenue „Sichtlinie aus“ (alt Game.seeAll): kein Nebel auf der Karte, erkundet wird wie sonst
	if mat: mat.set_shader_parameter("ohne", 1.0 if Testmodus.alles_sichtbar else 0.0)
	if neu_sehen(spiel.held.kachel, spiel.held.rotation.y) or neu:
		# je Kachel 1 nie gesehen, sonst 0,5; die Teile dazwischen weich aus den vier naechsten Kachelmitten (drawFog: weiche Kanten,
		# Lauf 1 zeigte harte Rautenkanten), in Sicht 0 mit der Kegelkante als Linie (13e)
		var kw := PackedFloat32Array(); kw.resize(breite * hoehe)
		for ty in hoehe:
			for tx in breite: kw[ty * breite + tx] = 1.0 if nebel(tx, ty) == 0 else GESEHEN
		var sw := breite * SUB
		# nur um den Helden aendert sich etwas (Sicht bis reich, die weiche Kante eine Kachel weiter); beim Betreten alles
		var r := int(reich) + 4
		var h: Vector2i = spiel.held.kachel
		for ty in range(0 if neu else maxi(0, h.y - r), hoehe if neu else mini(hoehe, h.y + r + 1)):
			for tx in range(0 if neu else maxi(0, h.x - r), breite if neu else mini(breite, h.x + r + 1)):
				var f := nebel(tx, ty)
				var mitte: Vector2i = Vector2i(tx, ty) - h
				var nahe := absi(mitte.x) <= int(reich) + 2 and absi(mitte.y) <= int(reich) + 2
				for v in SUB:
					for u in SUB:
						var j := (ty * SUB + v) * sw + tx * SUB + u
						var px := tx + (u + 0.5) / SUB
						var py := ty + (v + 0.5) / SUB
						var g := 0.0
						if not ((f == 2 or nahe) and in_sicht_punkt(px, py)):
							g = weich(kw, px - 0.5, py - 0.5)
						if soll[j] != g:
							soll[j] = g
							aktiv[j] = true
		dinge_zeigen()
		if neu:   # beim Betreten sofort, ohne Blenden
			neu = false
			for j in aktiv: ist[j] = soll[j]
	if aktiv.is_empty(): return
	var schr := minf(1.0, clampf(dt * 1000.0, 0.0, 100.0) / FADE_MS * 3.0)
	var fertig: Array = []
	var w := breite * SUB
	for j in aktiv:
		var n := ist[j] + (soll[j] - ist[j]) * schr
		if absf(soll[j] - n) < 0.01:
			n = soll[j]; fertig.append(j)
		ist[j] = n
		bild.set_pixel(j % w, j / w, Color(n, n, n))
	for j in fertig: aktiv.erase(j)
	tex.update(bild)
