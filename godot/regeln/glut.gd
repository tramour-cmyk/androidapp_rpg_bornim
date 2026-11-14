extends RefCounted
## 930.6 (DESIGN-GLUT.md 3–5, Bauplan 10 Stufe 1; Chef 14.11., 20:19 „930 A, let's go.“): Regelkern des Glutsystems hinter dem
## Schalter Mars.glut (werte.json „glut“ „an“; aus: der alte Kampf bis zur Abnahme). Rechnet wie tools/sim444/glut2.py (930.5),
## Gegenprobe tests/glut_rechnung_930.gd (Sieg und Runden je Fall ±3), je Regelnummer ein Kerntest in tests/glut_930.gd. Alle
## Zahlen aus werte.json „glut“, keine im Code.
## Abstand je Gegner zur Gruppe (Regel 4): 0 nah, 1 fern, 2 weit. Der Zustand jedes Kämpfers steht in Fighter.gl.
## Noch nicht hier (Bauplan 10): Bedienung und Glutmarken (Stufe 2), Bild der Ansage, Mittel der Langsamen (Regel 18), Texte
## (Stufe 3, 5: Ereignisse ohne Spieltext tragen nur ihr Stichwort „cue“, GLUT_…). Ein Ring kommt über react wie im alten Kampf;
## die Absicht trägt „wehr“ (true: langsamer Ring, Fenster mal „wehr_ring_faktor“).

const Brs = preload("res://regeln/brs.gd")
const BrsKampf = preload("res://regeln/brs_kampf.gd")
const X = preload("res://regeln/mars_texte.gd")

const NAH := 0
const FERN := 1
const WEIT := 2
const GEGENSCHLAG := "gegenschlag"
const WACHSCHUSS := "wachschuss"
const WEHR := "wehr"
## Haltung nach dem Vorschlag der Bedienung (7.1), gewählt nach dem Tun
const AUTO := "auto"
## Tun ohne Handlung: die ganze Glut geht in die Haltung
const WARTEN := "warten"
const WAFFE := "waffe"
const FLIEHEN := "fliehen"
## Ringausgang wie im alten Kampf (Mars.NONE, GOOD, PERFECT) -> Anteil des Schadens
const ANTEIL := {"NONE": 1.0, "GOOD": 0.5, "PERFECT": 0.0}


static func w() -> Dictionary:
	return Brs.lade().get("glut", {})


static func an() -> bool:
	return bool(w().get("an", false))


static func _i(key: String) -> int:
	return int(w()[key])


static func _f(key: String) -> float:
	return float(w()[key])


# ---------------------------------------------------------------- Regeln als Rechnung (je Regel ein Kerntest)

## Regel 1, 12: Glut zu Beginn des eigenen Zugs; [minus] aus Umreißen und Netz (stapeln, nie unter „mindestens“), [funke] +1
static func zug_glut(minus: int, funke := false) -> int:
	return maxi(_i("mindestens"), _i("held") - maxi(0, minus)) + (1 if funke else 0)


## Regel 15: Glut eines Gegners je Zug
static func gegner_glut(boss: bool) -> int:
	return _i("boss") if boss else _i("gegner")


## Regel 2: Tempo des Helden aus Gewandtheit und Rüstung (Last noch nicht)
static func tempo_held(b: Dictionary) -> String:
	var t: Dictionary = w()["held_tempo"]
	var i := 1
	var schwer: bool = String(b.get("ruestung", "keine")) in t["stufe_weniger"]
	if int(b.get("werte", {}).get("gewandtheit", 0)) >= int(t["schnell_ab_gewandtheit"]) and not schwer:
		i = 2
	if schwer:
		i -= 1
	return ["langsam", "normal", "schnell"][maxi(0, i)]


static func tempo_gegner(art: String) -> String:
	return String(w()["tempo_gegner"].get(art, "normal"))


## Regel 2: freie Felder je Zug
static func frei(tempo: String) -> int:
	return int(w()["frei"].get(tempo, 1))


## Regel 6: Glut eines Tuns (Name wie in werte.json „zauber“, „handlungen“); schwere 2
static func tun_kosten(name: String) -> int:
	return _i("tun_schwer") if name in w()["schwer"] else _i("tun")


## Regel 7: Schadensfaktor bei [n] nachgelegter Glut
static func nachlegen_faktor(n: int) -> float:
	return 1.0 + _f("nachlegen") * maxi(0, n)


## Regel 7: Anteil des Schadens einer Antwort (Gegenschlag, Wachschuss) bei Waffenfertigkeit [fert]
static func antwort_faktor(fert: float) -> float:
	return 1.0 if fert >= _f("antwort_voll_ab") else _f("antwort_anteil")


## Abschnitt 5: Lesewert = Wahrnehmung + Spähen/teiler; [1]: Spähen ab Geselle
static func lesewert(b: Dictionary) -> Array:
	var L: Dictionary = w()["lesen"]
	var sp := float(b.get("fert", {}).get("Spähen", 0))
	return [float(b.get("werte", {}).get("wahrnehmung", 0)) + sp / float(L["spaehen_teiler"]), sp >= float(L["geselle"])]


## Abschnitt 5: Lesestufe 0–3 des Helden [b] gegen die Art [art]; Bosse mindestens „mindestens_boss“
static func lesestufe(b: Dictionary, art: String, boss: bool) -> int:
	var L: Dictionary = w()["lesen"]
	var lw := lesewert(b)
	var gw := float(L["gegenwert"].get(art, L["gegenwert_sonst"]))
	var st := int(L["basis"]) + int(floor((float(lw[0]) - gw) / float(L["teiler"]))) + (int(L["geselle_plus"]) if lw[1] else 0)
	st = clampi(st, 0, 3)
	return maxi(int(L["mindestens_boss"]), st) if boss else st


# ---------------------------------------------------------------- Kampf

## der Kampf (mars.gd, Schalter glut an); schwach gehalten, weil der Kampf diesen Kern hält (sonst bliebe beides im Speicher)
var _m: WeakRef
var m:
	get:
		return _m.get_ref()
var react := Callable()
var runde := 0
## Ringe in diesem Gegnerzug (Regel 9)
var ringe := 0
## gezählt wie glut2.py (Rechnung): Züge, Antworten, Wehr, verfallene Glut, nachgelegt, Funke, gekappte Ringe, Täuschungen, Netz, Prankenhieb
var zaehler := {"zuege": 0, "gegenschlag": 0, "wachschuss": 0, "wehr": 0, "verfallen": 0, "nachgelegt": 0, "funke": 0,
	"ringe_gekappt": 0, "getaeuscht": 0, "netz": 0, "prankenhieb": 0}
## höchstens so viele Runden, dann verloren (werte.json „lauf“ „max_runden“, wie die Rechnung)
var max_runden := 60
## wer in dieser Runde noch am Zug ist (Gruppe)
var _wartet: Array = []


func _init(kampf) -> void:
	_m = weakref(kampf)
	max_runden = int(Brs.lade().get("lauf", {}).get("max_runden", 60))


func gruppe() -> Array:
	return m.all.filter(func(f): return f.side == "PARTY" and f.standing())


func gegner() -> Array:
	return m.all.filter(func(f): return f.side == "FOES" and f.standing())


func _held():
	var g := gruppe()
	return g[0] if not g.is_empty() else null


## Art eines Gegners nach werte.json (Kennung -> Art); Begleiter nach ihrem Körper (Jungwolf, Leibwache: Wolf)
static func art_von(f) -> String:
	if f.monster == null:
		return ""
	if f.monster.has("rudel"):
		return String(Brs.lade()["merkmale"]["rudel"].get(String(f.monster.rudel), {}).get("koerper", ""))
	return String(Brs.kennung(String(f.monster.id)).get("art", ""))


func _einrichten() -> void:
	var held = _held()
	var foes: Array = m.all.filter(func(f): return f.side == "FOES")
	var leit = foes[0] if not foes.is_empty() else null
	var ueb_leit: bool = leit != null and bool(leit.b.get("ueberfall", false))
	var start := NAH if ueb_leit or m.opening == "AMBUSHED" else FERN
	for f in m.all:
		if f.side == "PARTY":
			f.gl = {"glut": 0, "frei": 0, "bereit": 0, "haltung": "", "minus": 0, "funke_da": int(f.b.get("stufe", 1)) >= _i("funke_ab_stufe"),
				"funke_jetzt": false, "liegt": false, "betaeubt": 0}
			continue
		var herr = m.find(f.follows) if f.follows != "" else null
		var art := art_von(f)
		var boss: bool = herr == null and bool(f.b.get("boss", false))
		f.gl = {"art": art, "herr": herr, "boss": boss, "glut": gegner_glut(boss), "ab": start, "lauert": 0, "glut_bereit": 0,
			"lauerte": false, "offen": false, "kraft": false, "plan": {}, "taeuscht": false, "erster": true, "tempo": tempo_gegner(art),
			"chance": float(f.b.get("chance", 1.0)), "anfuehrer": herr == null,
			"ueb": herr == null and bool(f.b.get("ueberfall", false)), "umr": herr == null and bool(f.b.get("umreissen", false)),
			"stufe_lesen": lesestufe(held.b, art, boss) if held != null else 2}
		if art == "Goblin-Späher" and f.gl.ab > NAH and bool(w()["plan"].get("spaeher_weit", true)):
			f.gl.ab = WEIT     # bleibt weit
	m.intents.clear()


## Beginn des Kampfs (Mars.start im Glutsystem): Überfall zuerst (Regel 4, werte.json „merkmale“ „ueberfall“), dann Runde 1
func beginnen(r: Callable) -> void:
	react = r
	_einrichten()
	m.started = true
	m._smoke_bundle()
	var foes: Array = m.all.filter(func(f): return f.side == "FOES")
	if not foes.is_empty() and foes[0].gl.ueb and bool(m._ueberfall().get("gegner_zuerst", false)):
		planen()
		gegner_zug()
	_neue_runde()


func _neue_runde() -> void:
	while m.outcome == "ONGOING":
		if runde >= max_runden:
			m.outcome = "LOST"
			return
		runde += 1
		planen()
		_wartet = gruppe()
		if _naechster():
			return
		gegner_zug()


## Der nächste der Gruppe beginnt seinen Zug; false, wenn keiner mehr wählen muss (dann ist der Gegner dran)
func _naechster() -> bool:
	while not _wartet.is_empty() and m.outcome == "ONGOING":
		var f = _wartet[0]
		if not f.standing():
			_wartet.pop_front()
			continue
		if zug_beginnen(f):
			m.turn = m.order.find(f)
			return true
		_wartet.pop_front()
	return false


## Regel 1, 7, 12: Zugbeginn: Haltung verfällt (Glut zählt als verfallen), Glut neu, Funke dazu. false: der Zug fällt aus (betäubt)
func zug_beginnen(f) -> bool:
	zaehler.verfallen += int(f.gl.bereit)
	if int(f.gl.bereit) > 0:
		m._say("", f.id, null, 0, null, false, false, "GLUT_VERGLIMMT")
	f.gl.bereit = 0
	f.gl.haltung = ""
	zaehler.zuege += 1
	if int(f.gl.betaeubt) > 0:
		f.gl.betaeubt -= 1
		m._say(m.fmt(m.ST_STUNNED, m.lang, [f.name(m.lang)]), f.id)
		return false
	f.gl.glut = zug_glut(int(f.gl.minus), bool(f.gl.funke_jetzt))
	if f.gl.funke_jetzt:
		f.gl.funke_jetzt = false
		m._say("", f.id, null, 0, null, false, false, "GLUT_FUNKE")
	f.gl.minus = 0
	f.gl.frei = frei(tempo_held(f.b))
	return true


## Mars.act im Glutsystem: [plan] des Zugs von [f] (vorschlag), dann weiter bis zur nächsten Wahl der Gruppe
func handeln(f, plan: Dictionary) -> void:
	held_zug(f, plan)
	if not _wartet.is_empty() and _wartet[0] == f:
		_wartet.pop_front()
	if m.outcome != "ONGOING":
		return
	if _naechster():
		return
	gegner_zug()
	_neue_runde()


# ---------------------------------------------------------------- Ansage (Regel 15–17, 20, Abschnitt 5)

func planen() -> void:
	var P: Dictionary = w()["plan"]
	var T: Dictionary = w()["taeuschen"]
	var held = _held()
	for g in gegner():
		g.gl.taeuscht = false
		var p := {"gross": false, "art": "schlag"}
		var gl := int(g.gl.glut)
		var art: String = g.gl.art
		if art == "Goblin-Schamane":
			var verl := gegner().filter(func(x): return x != g and x.hp < float(P["schamane_heilen_unter"]) * x.max_hp)
			if not verl.is_empty() and m.dice.randf() < float(P["schamane_heilen"]):
				p.art = "heilen"
			elif gegner().any(func(x): return x != g) and m.dice.randf() < float(P["schamane_kraft"]):
				p.art = "kraft"
				p.gross = true
			else:
				p.art = "stab"
		elif art == "Riesenspinne" and int(g.gl.ab) > NAH:
			p.art = "netz"
			p.gross = true
		elif art == "Kobold" and int(g.gl.ab) > NAH and not g.gl.lauerte:
			p.art = "lauern"
		elif art == "Riesenfledermaus":
			p.art = "sturz"
		elif String(g.b.get("art", "nah")) != "nah":
			p.gross = gl >= _i("gross_kosten") and g.gl.anfuehrer and m.dice.randf() < float(P["gross_fern"])
			p.art = "anlegen" if p.gross else "schuss"
		else:
			p.gross = g.gl.anfuehrer and gl >= _i("gross_kosten") and (g.gl.boss or m.dice.randf() < float(P["gross_nah"])) \
					and m.dice.randf() < float(P["gross_nah_halb"])
			if p.gross and art == "Krogg" and gl >= int(P["prankenhieb_kosten"]) and m.dice.randf() < float(P["prankenhieb"]):
				p.art = "prankenhieb"
		p.zeigt_gross = p.gross
		if art in T["arten"] and g.gl.anfuehrer and p.art in ["schlag", "schuss", "anlegen"] and m.dice.randf() < float(T["anteil"]):
			g.gl.taeuscht = true
			p.zeigt_gross = not p.gross
		p.ziel = held.id if held != null else ""
		g.gl.plan = p
		m.intents[g.id] = [_absicht(p), [p.ziel]]     # Bild der alten Ansage, bis Stufe 3 sie nach der Lesestufe zeichnet


## Die Ansage im Bild des alten Kampfs (kampf_ui.gd _draw_intents), nach dem, was sie zeigt; nie brechbar über Schaden wie im
## alten Kampf (Brechen ist Regel 19)
func _absicht(p: Dictionary) -> Dictionary:
	var a: Dictionary
	match String(p.art):
		"netz":
			a = m.I_WEB
		"lauern":
			a = m.I_GROWL
		"heilen", "kraft":
			a = m.I_GATHER
		"sturz":
			a = m.I_BITE
		_:
			a = m.I_HEAVY if p.zeigt_gross else m.I_SLASH
	a = a.duplicate()
	a.breakable = false
	a.break_any = false
	a.glut = p.duplicate()
	return a


## Abschnitt 5: (groß, Art) so, wie [held] die Ansage von [g] sieht; Art null auf Stufe 0; große Schläge mindestens Stufe 1
func gesehen(g) -> Array:
	var p: Dictionary = g.gl.plan if not (g.gl.plan as Dictionary).is_empty() else {"gross": false, "art": "schlag", "zeigt_gross": false}
	var st := int(g.gl.stufe_lesen)
	var gross: bool = p.gross if st >= 3 else p.zeigt_gross
	if gross:
		st = maxi(st, int(w()["lesen"]["mindestens_gross"]))
	return [gross, p.art if st >= 1 else null]


## Lesestufe dieser Ansage (Bild, Stufe 3)
func stufe_der_ansage(g) -> int:
	var st := int(g.gl.stufe_lesen)
	return maxi(st, int(w()["lesen"]["mindestens_gross"])) if gesehen(g)[0] else st


# ---------------------------------------------------------------- Vorschlag (Bedienung 7.1, Autopilot)

## Tun aus der Ferne: Funkenpfeil, solange Mana reicht, sonst die Fernwaffe; "" ohne
func aktion_fern(f) -> String:
	var z: Dictionary = BrsKampf.w()["zauber"]["Funkenpfeil"]
	if "Z_FUNKEN" in f.zauber and f.sp >= int(z["kosten"]):
		return "Z_FUNKEN"
	return WAFFE if _waffe(f).art == "fern" else ""


func _waffe(f) -> Dictionary:
	var W := BrsKampf.w()
	var gr := String(f.b.get("waffe", ""))
	if gr == "":
		gr = BrsKampf.waffe_held(f.b, f.weapon() if f.weapon() != null else f.hero.main)
	var wd: Dictionary = W["waffen"].get(gr, W["waffen"]["Faustkampf"]).duplicate()
	wd.gruppe = gr
	return wd


## 7.1: Haltung, die die Bedienung vorschlägt: gegen einen gesehenen großen Schlag (nicht Prankenhieb, nicht Kraft sammeln) oder
## gesammelte Kraft Wehr; gegen einen Schützen aus fern oder weit Wehr (930.5); sonst mit Fernkampf Wachschuss (Wehr, wenn alle nah
## sind), mit Nahkampf Gegenschlag
func vorschlag_haltung(f) -> String:
	for g in gegner():
		var s := gesehen(g)
		if (s[0] and s[1] != "prankenhieb" and s[1] != "kraft") or g.gl.kraft:
			return WEHR
	if gegner().any(func(g): return String(g.b.get("art", "nah")) == "fern" and int(g.gl.ab) > NAH):
		return WEHR
	if aktion_fern(f) != "":
		return WACHSCHUSS if gegner().any(func(g): return int(g.gl.ab) > NAH) else WEHR
	return GEGENSCHLAG


## Ziel des Vorschlags: nah zuerst (Anführer, dann wer am wenigsten Leben hat), sonst der Schamane (mit Fernkampf), sonst der nächste
func vorschlag_ziel(f):
	var l := gegner().filter(func(g): return g.angreifbar())
	if l.is_empty():
		return null
	var nah := l.filter(func(g): return int(g.gl.ab) == NAH)
	if not nah.is_empty():
		var bn = nah[0]
		for g in nah:
			if _vor(g.gl.herr != null, g.hp, bn.gl.herr != null, bn.hp):
				bn = g
		return bn
	var sch := l.filter(func(g): return g.gl.art == "Goblin-Schamane")
	if not sch.is_empty() and aktion_fern(f) != "":
		return sch[0]
	var best = l[0]
	for g in l:
		if int(g.gl.ab) < int(best.gl.ab) or (int(g.gl.ab) == int(best.gl.ab) and g.gl.herr == null and best.gl.herr != null):
			best = g
	return best


## Reihenfolge wie Python min(key=(Begleiter, Leben)): zuerst Anführer, dann weniger Leben; bei Gleichstand der erste
static func _vor(a_begl: bool, a_hp: int, b_begl: bool, b_hp: int) -> bool:
	if a_begl != b_begl:
		return not a_begl
	return a_hp < b_hp


## Der Zug, den die Bedienung vorschlägt (ein Tipp auf den Gegner, 7.1) und den der Autopilot spielt; [politik] „N“: alle übrige
## Glut ins Tun (Rechnung). Plan: {tun, ziel, loesen, nachlegen, haltung}
func vorschlag(f, politik := "S") -> Dictionary:
	var z: Dictionary = BrsKampf.w()["zauber"]
	var t = vorschlag_ziel(f)
	var nl := 99 if politik == "N" else 0
	if "Z_BANN" in f.zauber and runde == 1 and f.sp >= int(z["Bannschild"]["kosten"]):
		return {"tun": "Z_BANN", "ziel": f.id, "haltung": AUTO}
	if "Z_WUND" in f.zauber and f.hp < f.max_hp * float(z["Wundsegen"]["heilen_unter"]) and f.sp >= int(z["Wundsegen"]["kosten"]):
		return {"tun": "Z_WUND", "ziel": f.id, "haltung": AUTO}
	if t == null:
		return {"tun": WARTEN, "haltung": AUTO}
	var fa := aktion_fern(f)
	if fa != "":
		var nahe := gegner().filter(func(g): return int(g.gl.ab) == NAH)
		var loesen: bool = not nahe.is_empty() and nahe.all(func(g): return g.gl.tempo == "langsam") and int(f.gl.glut) >= 2 and int(f.gl.frei) >= 1
		return {"tun": fa, "ziel": t.id, "loesen": loesen, "nachlegen": nl, "haltung": AUTO}
	return {"tun": WAFFE, "ziel": t.id, "nachlegen": nl, "haltung": AUTO}


## Was der Held in seinem Zug als Haltung wählen kann (Regel 7: Gegenschlag mit Nahkampfwaffe, Wachschuss mit Fernwaffe oder
## Angriffszauber mit Mana, Wehr immer)
func haltungen(f) -> Array:
	var out := []
	if aktion_fern(f) == "":
		out.append(GEGENSCHLAG)
	else:
		out.append(WACHSCHUSS)
	out.append(WEHR)
	return out


# ---------------------------------------------------------------- Zug des Helden (Regel 1–14)

func _setze_haltung(f, rest: int, h: String) -> void:
	f.gl.bereit = maxi(0, rest)
	f.gl.haltung = vorschlag_haltung(f) if h == AUTO else h
	if f.gl.bereit > 0 and f.gl.haltung != "":
		m._say("", f.id, null, 0, null, false, false, "GLUT_HALTUNG_" + String(f.gl.haltung).to_upper())


## Ein Zug nach [p]: {tun: waffe | Z_… | H_… | warten | fliehen, ziel, loesen, trank, nachlegen, haltung}
func held_zug(f, p: Dictionary) -> void:
	var glut := int(f.gl.glut)
	var frei_ := int(f.gl.frei)
	var tun := String(p.get("tun", WAFFE))
	var h := String(p.get("haltung", AUTO))
	if tun == FLIEHEN:     # Regel 13: alle Glut, Probe wie heute, nie vor einem Boss; ein schneller naher Gegner setzt nach
		assert(m.can_flee(f))
		f.gl.glut = 0
		m._flee(f)
		if m.outcome == "ONGOING":
			_setzt_nach(f, false)
		return
	if bool(p.get("loesen", false)) and glut > _i("loesen"):     # Regel 3
		glut -= _i("loesen")
		var nahe := gegner().filter(func(g): return int(g.gl.ab) == NAH)
		for g in nahe:
			g.gl.ab = FERN
		m._say("", f.id, null, 0, null, false, false, "GLUT_LOESEN")
		_setzt_nach(f, h == WEHR, nahe)
		if m.outcome != "ONGOING":
			return     # kein neuer freier Schritt; ein noch nicht genutzter bleibt
	if p.has("tausch") and frei_ > 0:     # Regel 5: Platztausch in der eigenen Reihe kostet den freien Schritt
		var to: Vector2i = p.tausch
		for x in m.all:
			if x.side == f.side and x.place == to and x != f:
				x.place = f.place
				break
		f.place = to
		frei_ = 0
		f.gl.frei = 0
		m._say(m.fmt(m.pick("MSG72_SWAPS"), m.lang, [f.name(m.lang)]), f.id)
	if String(p.get("trank", "")) != "" and glut >= _i("trank"):     # Regel 10: Trank kostet 1, ist kein Tun
		glut -= _i("trank")
		m._drink(f, String(p.trank), m.by_id(String(p.get("trank_ziel", f.id))))
	if tun == WARTEN:
		_setze_haltung(f, glut, h)
		return
	if tun == "H_KRAFT" or tun == "Z_BANN" or tun == "Z_WUND" or tun == "Z_HAUT" or tun == "Z_BEISTAND":     # Regel 11, Zauber ohne Ziel
		var name := String(m.HANDLUNG.get(tun, m.ZAUBER.get(tun, tun)))
		glut -= (_i("kraft_schoepfen") if tun == "H_KRAFT" else tun_kosten(name))
		m._use_skill(f, tun, m.by_id(String(p.get("ziel", f.id))))
		_setze_haltung(f, glut, h)
		return
	var t = m.by_id(String(p.get("ziel", "")))
	if t == null or not t.standing():
		_setze_haltung(f, glut, h)
		return
	var fern: bool = tun == "Z_FUNKEN" or (tun == WAFFE and _waffe(f).art == "fern")
	if not fern and int(t.gl.ab) > NAH:
		while int(t.gl.ab) > NAH and frei_ > 0:     # Regel 2
			t.gl.ab -= 1
			frei_ -= 1
		while int(t.gl.ab) > NAH and glut > 1:
			t.gl.ab -= 1
			glut -= _i("schritt")
		f.gl.frei = frei_
		if int(t.gl.ab) > NAH:     # nicht heran: der Rest geht in Wehr
			_setze_haltung(f, glut, WEHR)
			return
		if int(t.gl.lauert) > 0 and int(t.gl.glut_bereit) > 0:     # Regel 17: wer heranrückt, läuft in den Schlag
			t.gl.glut_bereit -= 1
			m._say("", t.id, f.id, 0, null, true, false, "GLUT_LAUERN")
			auf_held(t, f)
			if not f.standing() or m.outcome != "ONGOING":
				return
	var kosten := tun_kosten(String(m.ZAUBER.get(tun, m.HANDLUNG.get(tun, ""))))
	var nd := mini(maxi(0, int(p.get("nachlegen", 0))), glut - kosten)     # Regel 7: Nachlegen
	if nd > 0:
		zaehler.nachgelegt += nd
		m._say("", f.id, t.id, 0, null, false, false, "GLUT_NACHLEGEN")
	held_schlag(f, t, tun, 0.0, nachlegen_faktor(nd))
	if m.outcome != "ONGOING":
		return
	_setze_haltung(f, glut - kosten - nd, h)


## Regel 3, 13: ein schneller naher Gegner setzt nach (Schlag mit Ring), außer die Haltung ist Wehr
func _setzt_nach(f, wehr: bool, von := []) -> void:
	if wehr:
		return
	for g in (von if not von.is_empty() else gegner().filter(func(x): return int(x.gl.ab) == NAH)):
		if g.standing() and g.gl.tempo == "schnell" and m.outcome == "ONGOING":
			auf_held(g, f, 1.0, true)


## Schlag des Helden mit [tun] (Waffe oder Funkenpfeil) wie glut2.py held_schlag: Treffer gegen die Abwehr, Schaden mal Schwäche
## und [faktor] (Nachlegen, Antwort), nach der Rüstung; Antworten nie kritisch und ohne Ungunst des Flatterns (Regel 7)
func held_schlag(f, t, tun: String, bonus := 0.0, faktor := 1.0, antwort := false) -> bool:
	var W := BrsKampf.w()
	var k: Dictionary = W["kampf"]
	var fert_name := ""
	var grund := 0.0
	var typ = null
	if tun == "Z_FUNKEN":
		var zb: Dictionary = W["zauber"]["Funkenpfeil"]
		f.sp -= int(zb["kosten"])
		fert_name = String(zb["schule"])
		grund = float(zb["schaden"]) + float(f.b.werte.get(BrsKampf.zauber_grundwert(fert_name), 0))
		typ = zb.get("typ")
		m.casting = m.ZAUBER_FX.get(tun)
		m._say(m.fmt(X.MSG72_CASTS, m.lang, [f.name(m.lang), m.ZAUBER_NAME[tun][m.lang]]), f.id)
	else:
		var wd := _waffe(f)
		fert_name = String(wd.gruppe)
		var gw = wd.get("grundwert")
		grund = float(wd["schaden"]) + (float(f.b.werte.get(gw, 0)) if gw != null else 0.0)
		typ = wd.get("typ")
		if String(wd.get("art", "nah")) == "fern":
			bonus += float(k["fernkampf_treffer_je_wahrnehmung"]) * float(f.b.werte.get("wahrnehmung", 0))
	var fw := float(f.b.fert.get(fert_name, 0))
	if f.gl.liegt:     # Umreißen: nächster Angriff mit Ungunst
		bonus += float(W["merkmale"]["umreissen"]["naechster_angriff_treffer"])
		f.gl.liegt = false
	if not antwort and t.gl.art == "Riesenfledermaus":
		bonus += _f("ungunst")     # flattert
	if not antwort and t.gl.offen:
		bonus -= _f("ungunst")     # nach dem Prankenhieb offen
		t.gl.offen = false
	var chance := Brs.trefferchance(fw, float(t.b.abwehr), bonus)
	var z: float = m.dice.randf()
	var info := ["BRS", int(floor(z * 100.0)) + 1, 0, roundi(chance * 100.0), z < chance, 0, false, false]
	m.casting = null
	if z >= chance:
		m._say(m.fmt(m.wolf(f, "MSG279_WOLFMISSES", "MSG72_MISSES"), m.lang, [f.name(m.lang), t.name(m.lang)]), f.id, t.id, 0, info, antwort)
		return false
	var krit := 0.0 if antwort else BrsKampf.krit_prozent(f.b.werte, fert_name, fw)
	var zg: float = m.dice.randf()
	var zk: float = m.dice.randf() if krit > 0.0 else 1.0
	var zs: float = m.dice.randf()
	info[7] = krit > 0.0 and zk * 100.0 < krit
	var sch := Brs.schaden_roh(grund, fw, float(int(f.b.stufe) - int(t.b.stufe)), zg, zk, zs, krit)
	sch *= float(t.b.get("schwaeche", {}).get(typ, 1.0)) if typ != null else 1.0
	sch *= faktor
	var n := int(Brs.endschaden(sch, float(t.b.ruestung)))
	m._hurt(t, n, f.id, m.fmt(m.wolf(f, "MSG279_WOLFHITS", "MSG72_HITS"), m.lang, [f.name(m.lang), t.name(m.lang), n]), info, true)
	return true


# ---------------------------------------------------------------- Zug der Gegner (Regel 8, 9, 15–17, 20, 21)

func _funke(f, perfekt := false) -> void:
	if f.side == "PARTY" and f.gl.funke_da and (perfekt or f.hp < _f("funke_unter_leben") * f.max_hp):
		f.gl.funke_da = false
		f.gl.funke_jetzt = true
		zaehler.funke += 1


## Ein Schlag von [g] auf [t] wie glut2.py auf_held: Wehr (eine Glut, Ungunst), Kraft des Schamanen, großer Schlag mit Ring (höchstens
## zwei je Gegnerzug, Regel 9), Schaden nach Abzug. null: verfehlt; sonst der Anteil des Rings (1 ohne Ring)
func auf_held(g, t, faktor := 1.0, gross := false, bonus := 0.0, wehr_hilft := true, schaden := true):
	var W := BrsKampf.w()
	var wehr := false
	if wehr_hilft and int(t.gl.bereit) > 0 and t.gl.haltung == WEHR:     # Regel 7: Wehr
		t.gl.bereit -= 1
		zaehler.wehr += 1
		wehr = true
		bonus += _f("wehr_ungunst")
		m._say("", t.id, g.id, 0, null, true, false, "GLUT_WEHR")
	if g.gl.kraft:
		g.gl.kraft = false
		faktor *= _f("gross_faktor")
		gross = true
	var wt = t.weapon()
	var tw := BrsKampf.waffe_held(t.b, wt if wt != null else t.hero.main, wt != null and wt != t.main_weapon())
	var abw: Array = BrsKampf.held_abwehr(t.b, String(g.b.get("art", "nah")), tw, not t.drawn)
	var chance := Brs.trefferchance(float(g.b.angriff), float(abw[1]), bonus)
	var z: float = m.dice.randf()
	var info := ["BRS", int(floor(z * 100.0)) + 1, 0, roundi(chance * 100.0), z < chance, 0, false, false]
	if z >= chance:
		m._say(m.fmt(m.wolf(g, "MSG279_WOLFMISSES", "MSG72_MISSES"), m.lang, [g.name(m.lang), t.name(m.lang)]), g.id, t.id, 0, info)
		return null
	var anteil := 1.0
	if gross:
		if ringe < _i("ringe_je_gegnerzug"):
			ringe += 1
			var intent: Dictionary = (m.intents.get(g.id, [m.I_HEAVY])[0] as Dictionary).duplicate()
			intent.ring = true
			intent.wehr = wehr
			intent.ring_faktor = _f("wehr_ring_faktor") if wehr else 1.0
			var r := String(m._ring(react, t, intent))
			anteil = float(ANTEIL.get(r, 1.0))
			if anteil == 0.0:
				_funke(t, true)
		else:
			zaehler.ringe_gekappt += 1
	if schaden:
		var zg: float = m.dice.randf()
		var zs: float = m.dice.randf()
		var sch := Brs.schaden_roh(float(g.b.schaden), float(g.b.angriff), float(int(g.b.stufe) - int(t.b.stufe)), zg, 1.0, zs) * faktor * anteil
		var n := int(Brs.endschaden(sch, BrsKampf.held_abzug(t.b, not t.drawn) + t.schutz))
		m._hurt(t, n, g.id, m.fmt(m.wolf(g, "MSG279_WOLFHITS", "MSG72_HITS"), m.lang, [g.name(m.lang), t.name(m.lang), n]), info, true)
	_funke(t)
	return anteil


## Wachschuss (Regel 7): rückt [g] ein Feld vor, schießt der Held vorher, eine Glut, halber Schaden bis Geselle, nie kritisch
func _wachschuss(f, g) -> void:
	if int(f.gl.bereit) > 0 and f.gl.haltung == WACHSCHUSS and aktion_fern(f) != "":
		f.gl.bereit -= 1
		zaehler.wachschuss += 1
		m._say("", f.id, g.id, 0, null, true, false, "GLUT_WACHSCHUSS")
		var fa := aktion_fern(f)
		held_schlag(f, g, fa, 0.0, antwort_faktor(float(f.b.fert.get(_fert_von(f, fa), 0))), true)


## Gegenschlag (Regel 7): kommt [g] nah heran oder schlägt er aus nah zu, schlägt der Held vorher
func _gegenschlag(f, g) -> void:
	if int(f.gl.bereit) > 0 and f.gl.haltung == GEGENSCHLAG and aktion_fern(f) == "":
		f.gl.bereit -= 1
		zaehler.gegenschlag += 1
		m._say("", f.id, g.id, 0, null, true, false, "GLUT_GEGENSCHLAG")
		held_schlag(f, g, WAFFE, 0.0, antwort_faktor(float(f.b.fert.get(_fert_von(f, WAFFE), 0))), true)


## Fertigkeit, nach der eine Antwort voll wird (glut2.py: die der Waffe, auch für den Funkenpfeil)
func _fert_von(f, _tun: String) -> String:
	return String(_waffe(f).gruppe)


## Regel 2: [g] rückt heran, freie Felder zuerst, dann Glut (eine bleibt fürs Tun); vor jedem Feld der Wachschuss
func _heran(g, f, glut: int, frei_: int) -> int:
	while int(g.gl.ab) > NAH and frei_ > 0:
		g.gl.ab -= 1
		frei_ -= 1
		_wachschuss(f, g)
		if not g.standing():
			return glut
	while int(g.gl.ab) > NAH and glut > 1:
		g.gl.ab -= 1
		glut -= _i("schritt")
		_wachschuss(f, g)
		if not g.standing():
			return glut
	return glut


func gegner_zug() -> void:
	ringe = 0
	var P: Dictionary = w()["plan"]
	var foes := gegner()
	var leit = m.all.filter(func(x): return x.side == "FOES")[0] if not foes.is_empty() else null
	var hetzt: bool = leit != null and leit.gl.art == "Grimmzahn" and leit.standing()
	for g in foes:
		var f = _held()
		if f == null or m.outcome != "ONGOING":
			return
		if not g.standing():
			continue
		var glut := int(g.gl.glut)
		g.gl.lauert = 0
		g.gl.glut_bereit = 0
		var p: Dictionary = g.gl.plan if not (g.gl.plan as Dictionary).is_empty() else {"gross": false, "art": "schlag"}
		if g.gl.taeuscht:
			zaehler.getaeuscht += 1
		var art: String = g.gl.art
		if art == "Goblin-Schamane":
			if int(g.gl.ab) == NAH and glut >= 2:
				g.gl.ab = FERN
				glut -= _i("schritt")
			var andere := gegner().filter(func(x): return x != g)
			if p.art == "heilen" and not andere.is_empty():
				var a = andere[0]
				for x in andere:
					if float(x.hp) / x.max_hp < float(a.hp) / a.max_hp:
						a = x
				var n := mini(a.max_hp - a.hp, int(P["schamane_heilung"]))
				a.hp += n
				glut -= _i("tun")
				m._say(m.fmt(X.MSG72_HEALS, m.lang, [g.name(m.lang), a.name(m.lang), n]), g.id, a.id, 0, null, false, false, "HEAL")
			elif p.art == "kraft" and not andere.is_empty() and glut >= 2:
				var a = andere[0]
				for x in andere:
					if int(x.gl.ab) < int(a.gl.ab):
						a = x
				a.gl.kraft = true
				glut -= _i("gross_kosten")
				m._say("", g.id, a.id, 0, null, false, false, "GLUT_KRAFT")
			if glut >= 1 and m.dice.randf() < float(g.gl.chance):
				auf_held(g, f)
			continue
		if art == "Riesenspinne" and p.art == "netz" and int(g.gl.ab) > NAH:     # Netz: Ring, Treffer zieht heran und nimmt eine Glut
			zaehler.netz += 1
			var r = auf_held(g, f, 1.0, true, 0.0, true, false)
			if r != null and float(r) > 0.0:
				g.gl.ab -= 1
				f.gl.minus += 1
				m._say("", g.id, f.id, 0, null, false, false, "GLUT_NETZ")
			continue
		if String(g.b.get("art", "nah")) != "nah":     # Schütze: aus nah zurück, dann Schuss
			if int(g.gl.ab) == NAH and glut >= 2:
				g.gl.ab = FERN
				glut -= _i("schritt")
			var gr: bool = p.gross and glut >= _i("gross_kosten")
			if m.dice.randf() < float(g.gl.chance):
				auf_held(g, f, _f("gross_faktor") if gr else 1.0, gr)
			continue
		if p.art == "lauern" and int(g.gl.ab) > NAH:     # Regel 17
			g.gl.lauert = 1
			g.gl.glut_bereit = 1
			g.gl.lauerte = true
			m._say("", g.id, null, 0, null, false, false, "GLUT_LAUERT")
			continue
		g.gl.lauerte = false
		var fr := 99 if (hetzt and g.gl.herr == leit) else frei(String(g.gl.tempo))
		glut = _heran(g, f, glut, fr)
		if not g.standing() or int(g.gl.ab) > NAH:
			continue
		_gegenschlag(f, g)     # Regel 8: die Antwort löst keine Antwort aus; fällt er, ist der Angriff weg
		if not g.standing() or m.outcome != "ONGOING":
			continue
		if p.art == "prankenhieb" and glut >= int(P["prankenhieb_kosten"]):     # Krogg: Ring zum Ausweichen, Wehr hilft nicht
			glut -= int(P["prankenhieb_kosten"])
			zaehler.prankenhieb += 1
			if g.gl.ueb and g.gl.erster:
				g.gl.erster = false
			var r = auf_held(g, f, _f("gross_faktor"), true, 0.0, false)
			if r != null and float(r) > 0.0:
				g.gl.ab = FERN     # schleudert auf fern
			g.gl.offen = true
		elif p.gross and glut >= _i("gross_kosten"):     # Regel 16
			glut -= _i("gross_kosten")
			if g.gl.ueb and g.gl.erster:
				g.gl.erster = false
			auf_held(g, f, _f("gross_faktor"), true)
		else:
			glut -= _i("tun")
			var U: Dictionary = m._ueberfall()
			if g.gl.ueb and g.gl.erster and not m.smoke_thrown:     # Überfall: der erste Treffer mit Wucht und Ring, betäubt
				if auf_held(g, f, float(U["erster_treffer_faktor"]), true) != null:
					g.gl.erster = false
					if m.dice.randf() < float(U["betaeubt_chance"]):
						f.gl.betaeubt = int(U["betaeubt_zuege"])
			elif m.dice.randf() < float(g.gl.chance):
				var UM: Dictionary = BrsKampf.w()["merkmale"]["umreissen"]
				if auf_held(g, f) != null and g.gl.umr and m.dice.randf() < float(UM["chance_bei_treffer"]):
					f.gl.liegt = true
					f.gl.minus += 1
		if art == "Riesenfledermaus" and glut >= 1:     # löst sich
			g.gl.ab = FERN
			glut -= _i("schritt")
		elif glut > 0 and art in w()["lauern_arten"]:     # Regel 17: übrige Glut lauert
			g.gl.lauert = 1
			g.gl.glut_bereit = glut


## Regel 19: Zurückdrängen, Netz verbrennen, Taumeln lassen einen angesagten großen Schlag von [g] ins Leere gehen
func brechen(g) -> bool:
	var p: Dictionary = g.gl.get("plan", {})
	if p.is_empty() or not p.get("gross", false):
		return false
	p.gross = false
	p.zeigt_gross = false
	p.art = "gebrochen"
	m.intents.erase(g.id)
	m._say(m.fmt(m.pick("MSG72_BROKEN"), m.lang, [g.name(m.lang), m.I_HEAVY.name[m.lang]]), null, g.id)
	return true
