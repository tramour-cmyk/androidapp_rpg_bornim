class_name Herde
extends Node3D
# 490 (Flüsterwald begehbar wie alt): die Monster einer Karte (Game.herd, spawnRoamer, respawnRoamers, updateRoamers, endBattle) und der
# Ueberfall im hohen Gras (Game.afterStep: enc.rate je Schritt, Perks.ambushFactor, nie am Schutzort, drei Schritte Schonzeit).
# spiel.gd haengt sie beim Betreten an, ruft jedes Bild schritt() und nach jedem Feld betreten(); greift ein Monster an oder laeuft
# der Held in eines, kommt das Signal kampf(monster, eroeffnung, streuner) (eroeffnung wie Opening: NORMAL, HERO_FIRST, AMBUSHED).

signal kampf(monster: String, eroeffnung: String, wer: Streuner)
signal gemeldet(text: String)     # Schutzort: Garrick schwenkt die Fackel (SafeZone.notice)

static var bestand := {}          # Karte -> [Daten je Monster] (Game.herds; neues Spiel: leeren)
static var wiederkehr := {}       # Karte -> [Schritte, ab denen eines wiederkommt] (Game.respawns)

var karte: Karte
var spiel                         # spiel.gd: Held, Zustand, BrsHeld, Licht
var enc: Dictionary
var schutz: Array = []
var liste: Array[Streuner] = []
var jetzt := 0                    # ms seit dem Betreten (App-Uhr wie Game.now)
var frieden_bis := 0              # Game.peaceUntil: nach dem Kampf 2,5 s
var schonzeit := 3                # Game.graceSteps
var zufall := RandomNumberGenerator.new()
var aus := false                  # Bilder: Monster lassen den Helden in Ruhe, auch Hineinlaufen kaempft nicht
# 554 (Chef 04.11., 00:27) wie alt Game.monstersIgnoreHero (Testmenue): Monster laufen und stehen wie sonst, jagen und greifen nicht an,
# auch kein Ueberfall im hohen Gras; wer selbst hineinlaeuft, kaempft
static var beachten_nicht := false

func _init(k: Karte, s) -> void:
	karte = k
	spiel = s
	name = "Herde"
	enc = k.daten.get("begegnungen", {})
	schutz = k.daten.get("schutz", [])

func _ready() -> void:
	zufall.randomize()
	if not bestand.has(karte.id):
		bestand[karte.id] = []
		for i in int(enc.get("streuner", 0)):
			var d := neu(bestand[karte.id])
			if not d.is_empty(): bestand[karte.id].append(d)
	for d in bestand[karte.id]: _zeige(d)

static func neues_spiel() -> void:
	bestand.clear()
	wiederkehr.clear()

func _zeige(d: Dictionary) -> Streuner:
	var s := Streuner.aus_daten(d, karte)
	s.naechst_ms = jetzt + 500 + zufall.randi_range(0, 2000)
	add_child(s)
	liste.append(s)
	return s

# ---------------------------------------------------------------- wie spawnRoamer
func nacht() -> bool: return spiel.licht.ist_nacht()   # 539 Game.isNight

## die Tabelle, aus der jetzt gezogen wird (nachts eigene), nur Monster mit Kampfgruppe und Modell (Streuner.da)
func tabelle() -> Array:
	var t: Array = enc.get("nacht", []) if nacht() and enc.has("nacht") else enc.get("tabelle", [])
	return t.filter(func(e): return Streuner.da(String(e[0])))

func ziehe(t: Array) -> String:
	var summe := 0
	for e in t: summe += int(e[1])
	if summe <= 0: return ""
	var w := zufall.randi_range(0, summe - 1)
	for e in t:
		w -= int(e[1])
		if w < 0: return String(e[0])
	return String(t[-1][0])

func sicher(t: Vector2i) -> Dictionary:
	for z in schutz:
		if absi(t.x - int(z["x"])) + absi(t.y - int(z["y"])) <= int(z["radius"]): return z
	return {}

func neu(schon: Array) -> Dictionary:
	var t := tabelle()
	if t.is_empty(): return {}
	var held: Vector2i = spiel.held.kachel if spiel.held else Vector2i(-99, -99)
	var orte: Array[Vector2i] = []
	var kacheln: Array = enc.get("kacheln", [])
	for y in karte.hoehe:
		for x in karte.breite:
			var p := Vector2i(x, y)
			if not karte.zeichen(p) in kacheln or not karte.begehbar(p) or not karte.ausgang(p).is_empty(): continue
			if absi(x - held.x) + absi(y - held.y) < 7: continue
			if schon.any(func(o): return absi(o["kachel"].x - x) + absi(o["kachel"].y - y) < 3): continue
			if not sicher(p).is_empty(): continue
			orte.append(p)
	if orte.is_empty(): return {}
	var p := orte[zufall.randi_range(0, orte.size() - 1)]
	var blicke := [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
	return {"art": ziehe(t), "kachel": p, "heim": p, "blick": blicke[zufall.randi_range(0, 3)], "nr": zufall.randi_range(1, 4)}

# ---------------------------------------------------------------- wie updateRoamers
func frei(p: Vector2i, ohne: Streuner = null) -> bool:
	if not karte.begehbar(p) or not karte.ausgang(p).is_empty() or not sicher(p).is_empty(): return false
	if p == spiel.held.kachel: return false
	for s in liste:
		if s == ohne: continue
		if s.kachel == p: return false
		if s.gang != null and s.gang.naechste(jetzt) == p: return false     # 744: im Gang ist die naechste Kachel belegt
	for l in spiel.leute.get_children():
		if l is Leute and l.kachel == p: return false
	return true

func reichweite() -> int:
	var hw: BrsHeld = spiel.held_werte()
	var r := hw.bemerkt_aus()                                                       # Perks.noticeRange (870.4: Gewandtheit)
	if spiel.im_dunkeln() and spiel.zustand.funke: r += Streuner.SPARK_NOTICE         # Light.noticeExtra
	if spiel.held.laeuft and spiel.held.geht(): r += Streuner.RUN_NOISE               # Stamina.RUN_NOISE
	return r

func schritt(dt: float) -> void:
	jetzt += int(dt * 1000.0)
	if spiel.held == null: return
	var h: Vector2i = spiel.held.kachel
	var hw: BrsHeld = spiel.held_werte()
	var stark: bool = hw.stufe >= int(karte.daten.get("stufe", 1)) + 5
	var am_schutz := sicher(h)
	var hp: Vector3 = spiel.held.position
	for s in liste.duplicate():
		s.zeichne(jetzt, dt)
		# Held laeuft in ein Monster (Game.move: roamerAt): er greift an, von hinten zuerst; ein Lauerer in seinem Versteck auch
		if s.position.distance_to(hp) < 0.8 and (s.gang != null or jetzt >= s.bewegt_ms + s.schritt_ms / 2):
			var hb := _held_blick()
			_los(s, "HERO_FIRST" if s.blick == hb or (s.temper() == "LAUERER" and not s.jagt) else "NORMAL")
			return
		# 744: im Gang die Kachel nachziehen; bemerkt ein Jaeger den Helden (oder meidet ihn), endet der Gang weich auf der naechsten Kachel
		if s.gang != null:
			s.gang_takt(jetzt, _frei_fuer(s))
			if s.gang != null:
				if jetzt >= s.naechst_ms and not s.heimweg:
					s.naechst_ms = jetzt + 250
					var dg := absi(s.kachel.x - h.x) + absi(s.kachel.y - h.y)
					var rg: bool = aus or beachten_nicht or jetzt < s.ruhig_bis or jetzt < frieden_bis
					var sg := am_schutz.is_empty() and dg <= (2 if s.temper() == "LAUERER" else reichweite())
					if not rg and ((stark and dg <= 4 and am_schutz.is_empty()) or (not stark and s.temper() == "JAEGER" and sg)):
						s.gang.kuerze(jetzt)
				continue
			s.naechst_ms = maxi(s.naechst_ms, jetzt)
		if jetzt < s.naechst_ms: continue
		var dist := absi(s.kachel.x - h.x) + absi(s.kachel.y - h.y)
		var vom_heim := absi(s.kachel.x - s.heim.x) + absi(s.kachel.y - s.heim.y)
		var ruhig: bool = aus or beachten_nicht or jetzt < s.ruhig_bis or jetzt < frieden_bis
		var angst := stark                                                   # schwache Monster meiden einen viel staerkeren Helden
		var sieht := am_schutz.is_empty() and dist <= (2 if s.temper() == "LAUERER" else reichweite())
		if not ruhig and angst and dist <= 4 and am_schutz.is_empty():
			s.jagt = false
			s.auf(jetzt)
			_auf(s, h, true, 360)
		elif s.jagt:
			if not am_schutz.is_empty() or ruhig or dist > 7 or vom_heim > 9:
				s.jagt = false
				s.heimweg = true
				if not am_schutz.is_empty() and dist <= 7:
					if am_schutz.has("text"): gemeldet.emit(Sprache.t(am_schutz["text"]))
					s.naechst_ms = jetzt + 1100     # haelt kurz inne, waehrend die Fackel aus dem Feuer kommt, dann weicht es
				else: s.naechst_ms = jetzt + 600
			elif dist == 1:
				# daneben: Angriff; von hinten ist es ein Ueberfall
				var hb := _held_blick()
				var hinten: bool = s.kachel - h == -hb
				s.blick = h - s.kachel
				_los(s, "AMBUSHED" if hinten else "NORMAL")
				return
			else:
				_auf(s, h, false, 560 if s.art == "zombie" else 380)
		elif not ruhig and not angst and s.temper() != "WANDERER" and sieht and not s.heimweg:
			s.jagt = true
			s.auf(jetzt)
			s.blick = _richtung(h - s.kachel)     # 560: bemerkt den Helden und wendet sich ihm zu, bevor es losgeht
			s.alarm_bis = jetzt + 800
			s.naechst_ms = jetzt + 500
			spiel.klang("effekt", ["alert", 0.8 * _gehoert(dist)])
		elif s.heimweg:
			if vom_heim <= 1:
				s.heimweg = false
				s.naechst_ms = jetzt + 800
				s.verweilen_bis = jetzt + Gang.verweile_ms(zufall)     # 744: daheim erst verweilen
			else:
				# 744: heim als Bogen um Hindernisse (karte.weg, schraeg erlaubt), bis zur ersten belegten Kachel; sonst Schritt fuer Schritt
				var w := Gang.bis_belegt(karte.weg(s.kachel, s.heim), _frei_fuer(s), 6)
				if w.size() >= 2:
					s.geh_gang(w, jetzt, _ms_kachel(w, 420))
					s.naechst_ms = jetzt + 250
				else:
					_auf(s, s.heim, false, 420)
					s.naechst_ms = jetzt + 520
		elif s.temper() == "LAUERER":
			if dist <= 4: s.blick = _richtung(h - s.kachel)        # 9i.2: bleibt, dreht sich zum Helden
			s.naechst_ms = jetzt + 1000
		else:
			_streife(s)
		_merke(s)

func _gehoert(dist: int) -> float: return clampf(1.0 - (dist - 2) / 10.0, 0.15, 1.0)   # wie Ambience.heardAt, grob

func _held_blick() -> Vector2i:
	var r: float = spiel.held.rotation.y
	return Vector2i(roundi(sin(r)), roundi(cos(r)))

func _richtung(d: Vector2i) -> Vector2i:
	if d == Vector2i.ZERO: return Vector2i(0, 1)
	return Vector2i(signi(d.x), 0) if absi(d.x) >= absi(d.y) else Vector2i(0, signi(d.y))

## 744 A (Chef 09.11., 11:18): statt alle 0,9–2,5 s ein Schritt oder eine Drehung auf der Stelle (Game.kt wander): ein Gang von 2–5
## Kacheln als Bogen um den Heimplatz (Radius 3 wie alt), danach verweilen (meist 3–12 s) mit Ruhebewegungen der Art (streuner.gd)
func _streife(s: Streuner) -> void:
	s.jagt = false
	s.naechst_ms = jetzt + 300
	if s.gang != null: return
	if jetzt < s.verweilen_bis:
		s.verweile(jetzt, zufall)
		return
	var w := Gang.streife(s.kachel, s.gedreht, s.heim, 3, _frei_fuer(s), zufall)
	if w.size() >= 2:
		s.geh_gang(w, jetzt, _ms_kachel(w, 420))
		s.verweilen_bis = s.gang.ende_ms() + Gang.verweile_ms(zufall)
		s.geste_ab = s.gang.ende_ms() + zufall.randi_range(800, 2500)
	else:
		s.verweilen_bis = jetzt + Gang.verweile_ms(zufall)

## frei fuer den Gang von s: die eigene Kachel zaehlt als frei (schraege Schritte an ihr vorbei)
func _frei_fuer(s: Streuner) -> Callable:
	return func(p: Vector2i) -> bool: return p == s.kachel or frei(p, s)

## Zeit je Kachel fuer einen Gang: Grundtempo wie ein Schritt (ms * PACE), im Mittel des Bodens (Terrain.stepFactor)
func _ms_kachel(w: Array[Vector2i], ms: int) -> float:
	var f := 0.0
	for i in range(1, w.size()): f += karte.schritt(w[i])
	return ms * Streuner.PACE * f / maxf(1.0, w.size() - 1.0)

## ein Schritt zu (oder weg von) ziel entlang der besseren Achse, sonst die andere (stepTowards)
func _auf(s: Streuner, ziel: Vector2i, weg: bool, ms: int) -> void:
	var dx := (ziel.x - s.kachel.x) * (-1 if weg else 1)
	var dy := (ziel.y - s.kachel.y) * (-1 if weg else 1)
	var hz := Vector2i(1 if dx > 0 else -1, 0)
	var vt := Vector2i(0, 1 if dy > 0 else -1)
	var folge: Array = [hz, vt] if absi(dx) >= absi(dy) else [vt, hz]
	folge = folge.filter(func(d): return (dx if d == hz else dy) != 0)
	var rest := [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
	rest.shuffle()
	var ging := false
	for d in folge + rest:
		if _geh(s, d, ms): ging = true; break
	s.naechst_ms = (s.bewegt_ms + s.schritt_ms if ging else jetzt + int(ms * Streuner.PACE)) + 40     # 560: nach der Wende

func _geh(s: Streuner, d: Vector2i, ms: int) -> bool:
	var n := s.kachel + d
	if not frei(n): return false
	s.von = s.kachel
	s.kachel = n
	s.bewegt_ms = jetzt + s.wende_ms(d)     # 560: weite Wende erst auf der Stelle (Roamers.step)
	s.blick = d
	s.schritt_ms = int(ms * Streuner.PACE * karte.schritt(n))
	return true

# 541 Game.roamerAt: das Monster auf Kachel t oder null
func bei(t: Vector2i) -> Streuner:
	for s in liste:
		if s.kachel == t: return s
	return null

# 541 Game.interact -> engage: mit dem Aktionsknopf angreifen; von hinten (gleicher Blick) oder ein Lauerer im Versteck: Held zuerst
func greife_an(s: Streuner) -> void:
	_los(s, "HERO_FIRST" if s.blick == _held_blick() or (s.temper() == "LAUERER" and not s.jagt) else "NORMAL")

func _merke(s: Streuner) -> void:
	var i := liste.find(s)
	if i >= 0 and i < bestand[karte.id].size(): bestand[karte.id][i] = s.als_daten()

func _los(s: Streuner, eroeffnung: String) -> void:
	if aus: return
	_merke(s)
	kampf.emit(s.art, eroeffnung, s)

## Game.endBattle: nach dem Sieg fort, kommt nach 60 Schritten wieder; nach der Flucht geht es heim und laesst den Helden 12 s
func nach_kampf(s: Streuner, ende: String) -> void:
	frieden_bis = jetzt + 2500
	schonzeit = 3
	if s == null or not is_instance_valid(s): return
	var i := liste.find(s)
	if ende == "WON":
		if i >= 0:
			liste.remove_at(i)
			bestand[karte.id].remove_at(i)
		if not wiederkehr.has(karte.id): wiederkehr[karte.id] = []
		wiederkehr[karte.id].append(int(spiel.zustand.schritte) + Streuner.WIEDER_SCHRITTE)
		s.queue_free()
	else:
		s.jagt = false
		s.heimweg = true
		s.ruhig_bis = jetzt + Streuner.FLED_CALM_MS
		s.gang = null     # 744: ein Gang vor dem Kampf geht nicht weiter
		s.von = s.kachel
		s.verweilen_bis = 0
		s.sitzt = false
		_merke(s)

# 555 wie alt Game.cheatBring (Testmenue „neben den Helden holen“): ein Monster der Art auf ein freies Feld neben dem Helden, friedlich
# fuer ms (Rudel: die Kampfgruppe kommt erst im Kampf dazu, wie auf der Karte); false, wenn kein Feld frei ist
func hole(art: String, ms := 120000) -> bool:
	var h: Vector2i = spiel.held.kachel
	for r in [1, 2, 3]:
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if maxi(absi(dx), absi(dy)) != r: continue
				var p := h + Vector2i(dx, dy)
				if not frei(p): continue
				var d := {"art": art, "kachel": p, "heim": p, "blick": h - p if absi(dx) + absi(dy) == 1 else Vector2i(0, 1), "nr": zufall.randi_range(1, 4),
					"ruhig_bis": jetzt + ms}
				bestand[karte.id].append(d)
				_zeige(d)
				return true
	return false

# ---------------------------------------------------------------- nach jedem Feld (afterStep): wiederkommen, Ueberfall im hohen Gras
func betreten(t: Vector2i) -> void:
	var faellig: Array = wiederkehr.get(karte.id, [])
	var bereit := faellig.filter(func(x): return int(x) <= int(spiel.zustand.schritte))
	for x in bereit:
		faellig.erase(x)
		var d := neu(bestand[karte.id])
		if not d.is_empty():
			bestand[karte.id].append(d)
			_zeige(d)
	if schonzeit > 0:
		schonzeit -= 1
		return
	if aus or beachten_nicht or enc.is_empty() or not karte.zeichen(t) in enc.get("kacheln", []) or not sicher(t).is_empty(): return
	var weise: float = spiel.held_werte().hinterhalt_faktor()   # Perks.ambushFactor (870.4: Wahrnehmung)
	if zufall.randf() < float(enc.get("rate", 0.0)) * weise:
		var m := ziehe((enc.get("tabelle", []) as Array).filter(func(e): return Streuner.da(String(e[0]))))   # alt: immer die Tagestabelle
		if m != "": kampf.emit(m, "AMBUSHED", null)
