class_name Streuner
extends Node3D
# 490 (Flüsterwald begehbar wie alt): Monster auf der Karte wie Game.herd, spawnRoamer, updateRoamers (Roamers.kt Temper):
# so viele wie „streuner“ der Karte (karten.json „begegnungen“, MapExport.kt), auf hohem Gras, weg vom Helden und von Schutzorten;
# Jaeger bemerken den Helden in ihrer Reichweite (Perks.noticeRange, Fackelfunke, Rennen), zeigen „!“ und jagen ihn, Lauerer warten
# und drehen sich zu ihm, Wanderer streifen um ihren Platz. Ein Jaeger neben dem Helden greift an (von hinten: Ueberfall), wer in ein
# Monster laeuft, greift es an (von hinten zuerst). Am Schutzort (Garricks Feuer) geben sie auf und gehen heim. Nach dem Sieg ist es
# fort und kommt nach 60 Schritten wieder (endBattle), nach der Flucht laesst es den Helden 12 s in Ruhe.
# Bild: das Modell des Kampforts (kampf/figur.gd, Jerry), Gehen und Stehen; Kampfgruppe je Monster in GRUPPE (494 Jerry: jeder Gegner
# aufrufbar). Ein Monster ohne Gruppe oder ohne Modell kommt nicht auf die Karte.

const Figur = preload("res://kampf/figur.gd")
const Kampfort = preload("res://kampf/kampfort.gd")
const AufrufS = preload("res://kampf/aufruf.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")

const JAEGER := ["wolf", "goblin", "kobold", "boar", "ghoul", "skeleton", "zombie", "goblin_shaman", "goblin_archer"]
const LAUERER := ["giant_spider", "giant_bat", "ochre_jelly"]
## Kampfgruppe (kampf/aufruf.gd gegner) je Monster der Karte; Jerry ergaenzt mit 494
## 494 (Jerry): Ratte, Fledermaus, Spinne je allein wie alt (Roamers.kt ein Monster, Packs.kt ohne Rudel für sie; drei Ratten gaben
## 75 EP statt 25), Wildschwein, Hundertfüßer, Riesenegel (stirge), Säureschnecke (ochre_jelly) allein; Krogg und Grak aus der
## Geschichte (geschichte.gd fight, spiel.gd „kampf“ fragt GRUPPE)
static var GRUPPE := {"wolf": "RUDEL", "giant_rat": "RATTE", "goblin": "GOBLINS", "goblin_archer": "SCOUTS", "kobold": "KOBOLDS",
	"goblin_shaman": "SHAMANS", "giant_bat": "FLEDERMAUS", "giant_spider": "SPINNE", "dire_wolf": "GRIMM",   # 491: Grimmzahn mit Leibwache (Packs.guard)
	"boar": "BOARS", "giant_centipede": "CENTIPEDES", "stirge": "LEECHES", "ochre_jelly": "SLUGS", "bugbear": "KROGG", "hobgoblin_captain": "GRAK",
	# 506: die Untoten der Nacht und der Höhle (Story.kt night, Höhle), je allein; Wiedergänger statt Zombie, Grabhund statt Ghul
	"skeleton": "SKELETT", "zombie": "WIEDERGAENGER", "ghoul": "GRABHUND"}
const PACE := 1.6                 # Terrain.PACE
const FLED_CALM_MS := 12000       # Game.FLED_CALM_MS
const WIEDER_SCHRITTE := 60       # endBattle: kommt nach einem guten Weg wieder
const RUN_NOISE := 2              # Stamina.RUN_NOISE
const SPARK_NOTICE := 2           # Light.SPARK_NOTICE
## 560 (Chef 04.11., 16:22: „wenn sich die Monster … alles zum Held drehen … nicht wieder so auf der Scheibe drehen, sondern gerne mit
## Bewegung drehen“): Wenden mit fester Rate wie die Leute (leute.gd DREH_ZU, 416.8), nicht weich in einem Augenblick; wer im Stehen
## wendet, tritt dabei (Gehen auf der Stelle, langsamer); eine weite Wende kommt vor dem Schritt (alt Roamers.step TURN_FREE)
const DREH := 2.5                 # rad/s, 180 Grad in 1,3 s (leute.gd DREH_ZU)
const DREH_JAGD := 5.0            # rad/s, wer jagt oder flieht, kommt schneller herum (leute.gd: rennend doppelt)
const DREH_FREI := PI / 4.0       # Roamers.TURN_FREE 45 Grad: so weit wendet es im Gehen, darueber erst auf der Stelle
const DREH_TRITT := 0.12          # rad: ab dieser Abweichung tritt es beim Wenden
const TRITT_TEMPO := 0.6          # Gehen beim Wenden auf der Stelle, Anteil des Tempos
const DREH_GANG := 4.0            # rad/s: im Bogen folgt der Blick dem Weg (der Bogen selbst dreht 45° auf etwa einer Kachel)
## 744: Ruhebewegungen beim Verweilen auf der Karte, je Art nur ruhige (keine Drohung); Bestand aus den Bauskripten (kaufwolf.py
## 430–496, kaufratte.py 51–53, fledermaus.py 366–368, kaufspinne.py 47–50, kauftier.py 31/90–100, kaufuntoter.py 57–59,
## kaufgrabhund.py 53–55). Goblins, Kobold, Skelett, Krogg, Grak haben keine eigene Ruhebewegung (nur Stehen): sie sehen sich um.
const RUHE_KARTE := {"wolf": ["Lefzen", "UmsehenL", "UmsehenR", "Scharren", "Hecheln", "Knurren"],
	"dire_wolf": ["Lefzen", "UmsehenL", "UmsehenR", "Scharren", "Hecheln", "Knurren"], "giant_rat": ["Lefzen"], "giant_bat": ["Lefzen"],
	"giant_spider": ["Lefzen"], "boar": ["Fressen"], "stirge": ["Umsehen"], "ochre_jelly": ["Umsehen"], "zombie": ["Lauern"],
	"ghoul": ["Lefzen", "Umsehen"]}
## sitzend (Hocke) beim langen Verweilen, mit den Gesten der Hocke
const SITZ_KARTE := {"wolf": ["HockeUmsehenL", "HockeUmsehenR", "HockeHecheln", "HockeKnurren"],
	"dire_wolf": ["HockeUmsehenL", "HockeUmsehenR", "HockeHecheln", "HockeKnurren"]}
const GESTE_BLENDE := 0.4
const GESTE_ABSTAND_MS := 900     # C3 kein Gleichtakt: zwei Monster beginnen nie zugleich eine Ruhebewegung
static var geste_zuletzt_ms := -100000
## 1040 (Chef 12.11., 15:12, Grimmzahn: „wenn ich um den rumlaufe, dann dreht er sich … wie als ob er ein Playmobil-Männchen wäre“):
## wer dem gehenden Helden mit dem Blick folgt, holt ihn je Bild ein, der Rest blieb unter 1 Grad und nie über DREH_TRITT, es drehte
## ohne Tritt wie auf dem Drehteller; jetzt tritt es, sobald es sich merklich dreht (über TRITT_RATE), und noch TRITT_NACH_MS danach
const TRITT_RATE := 0.15          # rad/s, gut 8 Grad je Sekunde
const TRITT_NACH_MS := 400        # ein halber Schritt, damit die Pfoten nicht mitten im Tritt stehen bleiben
static func tritt_bis(bis: int, gedreht: float, dt: float, jetzt: int) -> int:
	return jetzt + TRITT_NACH_MS if absf(gedreht) > TRITT_RATE * dt else bis

# ---------------------------------------------------------------- Daten eines Monsters (bleiben je Karte, solange das Spiel laeuft)
var art := ""
var kachel := Vector2i.ZERO
var heim := Vector2i.ZERO
var von := Vector2i.ZERO          # Beginn des letzten Schritts (gleiten)
var blick := Vector2i(0, 1)
var nr := 1
var bewegt_ms := 0
var schritt_ms := 300
var naechst_ms := 0
var alarm_bis := 0
var jagt := false
var heimweg := false
var ruhig_bis := 0

var figur: Node3D
var ausruf: Label3D
var karte: Karte
var gedreht := 0.0
# 744 A (Bewegungsbaustein gang.gd): Gang über mehrere Kacheln als Bogen, danach verweilen mit Ruhebewegungen der Art
var gang: Gang = null
var gang_i := 0                   # Kachel des Gangs, auf der es gerade zählt
var verweilen_bis := 0
var geste_ab := 0
var geste_vor := ""
var sitzt := false                # Wölfe setzen sich beim langen Verweilen (Hocke)

static var helfer: Node3D         # Kampfort ohne Baum: nur foe_scale fuer die Groesse der Figur

func temper() -> String:
	if art in JAEGER: return "JAEGER"
	if art in LAUERER: return "LAUERER"
	return "WANDERER"

func als_daten() -> Dictionary:
	return {"art": art, "kachel": kachel, "heim": heim, "blick": blick, "nr": nr, "jagt": jagt, "heimweg": heimweg, "ruhig_bis": ruhig_bis}

static func aus_daten(d: Dictionary, k: Karte) -> Streuner:
	var s := Streuner.new()
	s.art = String(d["art"]); s.kachel = d["kachel"]; s.heim = d["heim"]; s.von = s.kachel; s.blick = d["blick"]; s.nr = int(d["nr"])
	s.jagt = bool(d.get("jagt", false)); s.heimweg = bool(d.get("heimweg", false)); s.ruhig_bis = int(d.get("ruhig_bis", 0))
	s.karte = k
	return s

## Kampffigur dieses Monsters (wie aufruf.gd gegner die erste), oder null, wenn es keine Gruppe oder kein Modell gibt
static func kaempfer(monster: String, nummer: int):
	if not GRUPPE.has(monster): return null
	var tab: Dictionary = Tabellen.lade()
	var monsters := {}
	for m in tab.monsters: monsters[m.id] = m
	var fs: Array = AufrufS.gegner(String(GRUPPE[monster]), monsters, Wuerfel.new(null))
	if fs.is_empty(): return null
	var f = fs[0]
	f.nr = nummer
	return f

## Gibt es dieses Monster auf der Karte (Gruppe und Modell)?
static var gibt := {}
static func da(monster: String) -> bool:
	if gibt.has(monster): return gibt[monster]
	var f = kaempfer(monster, 1)
	var ja := false
	if f != null:
		var fig = Figur.new()
		fig.fighter = f
		ja = FileAccess.file_exists(String(fig._model_path()))
		fig.free()
	gibt[monster] = ja
	return ja

func _ready() -> void:
	name = "Streuner_" + art
	position = karte.kachel_pos(kachel)
	var f = kaempfer(art, nr)
	if f != null:
		if helfer == null: helfer = Kampfort.new()
		figur = Figur.new()
		figur.fighter = f
		figur.kampfort = Stub.new(helfer)
		add_child(figur)
		figur.setup(f, figur.kampfort)
		figur.rotation.y = 0.0     # die Figur blickt nach +z; gedreht wird dieser Knoten
		figur.set_process(true)
	ausruf = Label3D.new()
	ausruf.text = "!"
	ausruf.font_size = 96
	ausruf.outline_size = 18
	ausruf.modulate = Color(0.85, 0.12, 0.08)       # Gegner rot (DESIGN-STIL Oberflaeche)
	ausruf.outline_modulate = Color(0, 0, 0)
	ausruf.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	ausruf.no_depth_test = true
	ausruf.position = Vector3(0, 1.9, 0)
	ausruf.visible = false
	add_child(ausruf)
	gedreht = atan2(float(blick.x), float(blick.y))
	rotation.y = gedreht

# Kampfort-Ersatz fuer figur.gd ausserhalb des Kampfs: Groesse wie im Kampf, kein Zittern
# 1007 (Tom 977): die Uhr blieb bei 0, figur._ruhebewegung wartete ewig, kein Monster der Karte zeigte im Stehen eine Ruhegeste.
# Jetzt laeuft sie mit der Spielzeit, fuer jeden Nutzer des Ersatzes (Streuner, Leute). Ruhelaut wie alt (Game.hearIdle,
# MonsterIdle.volume): nur nah, voll bis NAH Kacheln, bei FERN still; ohne Hoerer voll
class Stub:
	extends RefCounted
	const NAH := 2                 # MonsterIdle.NEAR
	const FERN := 7                # MonsterIdle.FAR
	var clock_ms: float:
		get: return float(Time.get_ticks_msec())
	var hoerer := Vector3.INF      # wo der Held steht (herde.gd je Bild), INF: keiner
	# 1012 (Lauf 373, wald_490 „Invalid access 'figures' on Stub“): figur._versatz_frei (1006) zählt die anderen Figuren des Kampforts;
	# seit 1007 die Uhr läuft, endet eine Ruhegeste der Karte in _idle und fragt danach. Außerhalb des Kampfs keine anderen
	var figures := {}
	var k
	func _init(kf) -> void: k = kf
	## Anteil des Ruhelauts an der Stelle wo (figur.gd _ruhebewegung): Kacheln wie alt quer und laengs gezaehlt
	func ruhe_pegel(wo: Vector3) -> float:
		if not hoerer.is_finite(): return 1.0
		var d := roundi((absf(wo.x - hoerer.x) + absf(wo.z - hoerer.z)) / Karte.TS)
		return clampf(float(FERN - maxi(d, NAH)) / float(FERN - NAH), 0.0, 1.0)
	func foe_scale(f) -> float: return k.foe_scale(f)
	func facing(_foe: bool) -> Vector3: return Vector3(0, 0, 1)
	func m_per_dp(_q: Vector3) -> float: return 0.0

## 560: wie lange es vor einem Schritt in Richtung d erst auf der Stelle wendet (ms; Roamers.step: Wende ueber TURN_FREE)
func wende_ms(d: Vector2i) -> int:
	var w := absf(angle_difference(gedreht, atan2(float(d.x), float(d.y))))
	return int((w - DREH_FREI) / (DREH_JAGD if jagt else DREH) * 1000.0) if w > DREH_FREI else 0

## 744: einen Gang beginnen (weg mit Startkachel); weite Wende vor dem ersten Schritt erst auf der Stelle (560), aus dem Sitzen erst
## aufstehen
func geh_gang(weg: Array[Vector2i], jetzt: int, ms_kachel: float) -> void:
	var ab := jetzt + wende_ms(weg[1] - weg[0]) + (450 if sitzt else 0)
	sitzt = false
	gang = Gang.neu(weg, ab, ms_kachel)
	gang_i = 0
	von = kachel
	bewegt_ms = ab
	schritt_ms = int(ms_kachel)

## 744: die Kachel nachziehen, auf der es im Gang zählt; ist die übernächste belegt (frei: Callable), endet es auf dieser.
## Am Ende steht es auf der letzten Kachel, Blick in Richtung des letzten Schritts.
func gang_takt(jetzt: int, frei: Callable) -> void:
	if gang == null: return
	var i := gang.index_bei(jetzt)
	while gang_i < i and gang_i + 1 < gang.kacheln.size():
		gang_i += 1
		von = kachel
		kachel = gang.kacheln[gang_i]
		if gang_i + 1 < gang.kacheln.size() and not frei.call(gang.kacheln[gang_i + 1]):
			gang.kuerze_hier(jetzt)
	if not gang.laeuft(jetzt):
		var n := gang.kacheln.size()
		if n >= 2: blick = gang.kacheln[n - 1] - gang.kacheln[n - 2]
		kachel = gang.kacheln[n - 1]
		von = kachel
		bewegt_ms = jetzt - schritt_ms - 1
		gang = null

## 744: hört auf zu verweilen (Jagd, Flucht, Heimweg); ein laufender Gang endet weich auf der nächsten Kachel
func auf(jetzt: int) -> void:
	verweilen_bis = 0
	sitzt = false
	if gang != null: gang.kuerze(jetzt)

func _grund() -> String:
	return "Hocke" if sitzt and figur and figur.anim and figur.anim.has_animation("Hocke") else "Stehen"

func _gesten() -> Array:
	var l: Array = SITZ_KARTE.get(art, []) if sitzt else RUHE_KARTE.get(art, [])
	return l.filter(func(g): return figur.anim.has_animation(g))

## 744: beim Verweilen (herde.gd ruft es etwa alle 0,3 s): eine Ruhebewegung der Art, nie zweimal dieselbe hintereinander und nie zwei
## Monster zugleich; oder es sieht sich um (wendet 45–90° mit Tritten); beim langen Verweilen setzt sich ein Wolf
func verweile(jetzt: int, zufall: RandomNumberGenerator) -> void:
	if jetzt < geste_ab or gang != null: return
	if figur == null or figur.anim == null:
		geste_ab = jetzt + 1000
		return
	var gr := _grund()
	if figur.anim.current_animation != gr and figur.anim.current_animation != "Gehen":
		geste_ab = jetzt + 400        # eine Geste läuft noch
		return
	if jetzt - geste_zuletzt_ms < GESTE_ABSTAND_MS:
		geste_ab = jetzt + zufall.randi_range(500, 1400)
		return
	var rest := verweilen_bis - jetzt
	var liste := _gesten()
	if liste.size() > 1: liste = liste.filter(func(g): return g != geste_vor)
	var w := zufall.randf()
	if not sitzt and SITZ_KARTE.has(art) and rest > 6000 and w < 0.3 and figur.anim.has_animation("Hocke"):
		sitzt = true
		geste_ab = jetzt + zufall.randi_range(2500, 4500)
		return
	if not sitzt and rest > 1500 and (w < 0.6 or liste.is_empty()):
		var dr: int = [-2, -1, 1, 2][zufall.randi_range(0, 3)]
		blick = Gang.RICHTUNGEN[posmod(Gang.richtung_nr(gedreht) + dr, 8)]
		geste_ab = jetzt + zufall.randi_range(2000, 4500)
		return
	if liste.is_empty():
		geste_ab = jetzt + zufall.randi_range(1500, 3000)
		return
	var g: String = liste[zufall.randi_range(0, liste.size() - 1)]
	geste_vor = g
	if g == "Scharren" and figur.anim.has_animation("ScharrenR") and zufall.randf() < 0.5: g = "ScharrenR"
	geste_zuletzt_ms = jetzt
	figur._play(g, GESTE_BLENDE)
	figur.anim.set_blend_time(g, gr, GESTE_BLENDE)
	figur.anim.queue(gr)
	geste_ab = jetzt + zufall.randi_range(2500, 5500)

## Lage zwischen von und kachel (gleitet in schritt_ms); Blick mit fester Rate, im Stehen mit Tritten (560)
func zeichne(jetzt: int, dt: float, held_pos := Vector3.INF) -> void:
	if figur and figur.kampfort is Stub: figur.kampfort.hoerer = held_pos
	if gang != null:
		_zeichne_gang(jetzt, dt)
		return
	var t := clampf(float(jetzt - bewegt_ms) / maxf(1.0, float(schritt_ms)), 0.0, 1.0)
	position = karte.kachel_pos(von).lerp(karte.kachel_pos(kachel), t)
	var ziel := atan2(float(blick.x), float(blick.y))
	var rest := absf(angle_difference(gedreht, ziel))
	gedreht = Leute.drehe(gedreht, ziel, (DREH_JAGD if jagt else DREH) * dt)
	rotation.y = gedreht
	ausruf.visible = jetzt < alarm_bis
	if figur and figur.anim:
		# auf der Stelle: steht (t = 1) oder wendet vor dem Schritt (bewegt_ms liegt noch vorn)
		var tritt := (t >= 1.0 or jetzt < bewegt_ms) and rest > DREH_TRITT
		if tritt and figur.weg.has("Gehen"):
			if figur.anim.current_animation != "Gehen": figur._play("Gehen", 0.2)
			figur.anim.speed_scale = TRITT_TEMPO
			return
		var gr := _grund()
		var soll := "Gehen" if t < 1.0 else gr
		var ruht: bool = figur.anim.current_animation in RUHE_KARTE.get(art, []) + SITZ_KARTE.get(art, []) + ["Lefzen", "Scharren", "ScharrenR"] + Figur.RUHE_GESTEN   # 1007: auch Knurren, Hecheln
		if figur.anim.current_animation != soll and not (soll == gr and ruht):
			figur._play(soll, GESTE_BLENDE if soll == "Hocke" or figur.anim.current_animation == "Hocke" else 0.2)
		# Gehen so schnell abgespielt, wie es geht (sonst gleiten die Pfoten): Kachel je Schritt durch die Schrittzeit
		if soll == "Gehen" and figur.weg.has("Gehen"):
			var mps: float = figur._mps("Gehen")
			if mps > 0.05: figur.anim.speed_scale = clampf(Karte.TS / (schritt_ms / 1000.0) / mps, 0.5, 2.5)
		else: figur.anim.speed_scale = 1.0

## 744: im Gang folgt die Lage dem Bogen, der Blick dem Weg; Gehen im Takt des Tempos (Anlaufen, Bremsen), vor dem Losgehen wendet es
## auf der Stelle mit Tritten (560)
func _zeichne_gang(jetzt: int, dt: float) -> void:
	var p := gang.lage(jetzt)
	position = Vector3((p.x + 0.5) * Karte.TS, 0.0, (p.y + 0.5) * Karte.TS)
	var vor := jetzt < gang.start_ms
	var ziel := gang.blick_bei(gang.start_ms if vor else jetzt)
	var rest := absf(angle_difference(gedreht, ziel))
	gedreht = Leute.drehe(gedreht, ziel, (DREH if vor else DREH_GANG) * dt)
	rotation.y = gedreht
	ausruf.visible = jetzt < alarm_bis
	if figur == null or figur.anim == null: return
	if vor:
		if rest > DREH_TRITT and figur.weg.has("Gehen"):
			if figur.anim.current_animation != "Gehen": figur._play("Gehen", 0.2)
			figur.anim.speed_scale = TRITT_TEMPO
		elif figur.anim.current_animation != "Stehen":
			figur._play("Stehen", GESTE_BLENDE)
			figur.anim.speed_scale = 1.0
		return
	if figur.anim.current_animation != "Gehen": figur._play("Gehen", 0.3)
	if figur.weg.has("Gehen"):
		var mps: float = figur._mps("Gehen")
		var v := gang.tempo_bei(jetzt) * Karte.TS / (gang.ms_je_kachel / 1000.0)
		if mps > 0.05: figur.anim.speed_scale = clampf(v / mps, 0.15, 2.5)
