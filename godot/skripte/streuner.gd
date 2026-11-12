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
class Stub:
	extends RefCounted
	var clock_ms := 0.0
	var k
	func _init(kf) -> void: k = kf
	func foe_scale(f) -> float: return k.foe_scale(f)
	func facing(_foe: bool) -> Vector3: return Vector3(0, 0, 1)
	func m_per_dp(_q: Vector3) -> float: return 0.0

## 560: wie lange es vor einem Schritt in Richtung d erst auf der Stelle wendet (ms; Roamers.step: Wende ueber TURN_FREE)
func wende_ms(d: Vector2i) -> int:
	var w := absf(angle_difference(gedreht, atan2(float(d.x), float(d.y))))
	return int((w - DREH_FREI) / (DREH_JAGD if jagt else DREH) * 1000.0) if w > DREH_FREI else 0

## Lage zwischen von und kachel (gleitet in schritt_ms); Blick mit fester Rate, im Stehen mit Tritten (560)
func zeichne(jetzt: int, dt: float) -> void:
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
		var soll := "Gehen" if t < 1.0 else "Stehen"
		if figur.anim.current_animation != soll and not (soll == "Stehen" and figur.anim.current_animation in ["Lefzen", "Scharren", "ScharrenR"]):
			figur._play(soll, 0.2)
		# Gehen so schnell abgespielt, wie es geht (sonst gleiten die Pfoten): Kachel je Schritt durch die Schrittzeit
		if soll == "Gehen" and figur.weg.has("Gehen"):
			var mps: float = figur._mps("Gehen")
			if mps > 0.05: figur.anim.speed_scale = clampf(Karte.TS / (schritt_ms / 1000.0) / mps, 0.5, 2.5)
		else: figur.anim.speed_scale = 1.0
