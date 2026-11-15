extends RefCounted
## 930.6 (DESIGN-GLUT.md 3–5, Bauplan 10 Stufe 1; Chef 14.11., 20:19 „930 A, let's go.“): Regelkern des Kerbensystems hinter dem
## Schalter Mars.kerbe (werte.json „kerbe“ „an“; aus: der alte Kampf bis zur Abnahme). Rechnet wie tools/sim444/glut2.py (930.5),
## Gegenprobe tests/kerbe_rechnung_930.gd (Sieg und Runden je Fall ±3), je Regelnummer ein Kerntest in tests/kerbe_930.gd. Alle
## Zahlen aus werte.json „kerbe“, keine im Code.
## Abstand je Gegner zur Gruppe (Regel 4): 0 nah, 1 fern, 2 weit. Der Zustand jedes Kämpfers steht in Fighter.gl.
## 930.7 (Stufe 2): für jeden der Gruppe die Kerben für das Bild (marken, bild()), der Vorschlag für das Daumenmenü und die
## Vorschau der Schlagfolge (vorschau()); gezeichnet in kampf/kerbbild.gd.
## Noch nicht hier (Bauplan 10): Bild der Ansage, Mittel der Langsamen (Regel 18), Texte
## (Stufe 3, 5: Ereignisse ohne Spieltext tragen nur ihr Stichwort „cue“, KERBE_…). Ein Ring kommt über react wie im alten Kampf;
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
## Tun ohne Handlung: die ganze Kerbe geht in die Haltung
const WARTEN := "warten"
const WAFFE := "waffe"
const FLIEHEN := "fliehen"
## Ringausgang wie im alten Kampf (Mars.NONE, GOOD, PERFECT) -> Anteil des Schadens
const ANTEIL := {"NONE": 1.0, "GOOD": 0.5, "PERFECT": 0.0}
## 930.7 (DESIGN-GLUT.md 8): Zustand eines Platzes im Bild (1266): frei, fürs Tun, vertieft, Haltung, geschlagen
const M_FREI := "frei"
const M_TUN := "tun"
const M_TIEF := "tief"
const M_HALT := "halt"
const M_GESCHLAGEN := "geschlagen"


static func w() -> Dictionary:
	return Brs.lade().get("kerbe", {})


static func an() -> bool:
	return bool(w().get("an", false))


static func _i(key: String) -> int:
	return int(w()[key])


static func _f(key: String) -> float:
	return float(w()[key])


# ---------------------------------------------------------------- Regeln als Rechnung (je Regel ein Kerntest)

## Regel 1, 12: Kerben zu Beginn des eigenen Zugs; [minus] aus Umreißen und Netz (stapeln, nie unter „mindestens“), [gold] +1
static func zug_kerben(minus: int, gold := false) -> int:
	return maxi(_i("mindestens"), _i("held") - maxi(0, minus)) + (1 if gold else 0)


## Regel 15: Kerben eines Gegners je Zug
static func gegner_kerben(boss: bool) -> int:
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


## Regel 6: Kerben eines Tuns (Name wie in werte.json „zauber“, „handlungen“); schwere 2
static func tun_kosten(name: String) -> int:
	return _i("tun_schwer") if name in w()["schwer"] else _i("tun")


## Regel 7: Schadensfaktor bei [n] vertiefter Kerben
static func vertiefen_faktor(n: int) -> float:
	return 1.0 + _f("vertiefen") * maxi(0, n)


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

## der Kampf (mars.gd, Schalter kerbe an); schwach gehalten, weil der Kampf diesen Kern hält (sonst bliebe beides im Speicher)
var _m: WeakRef
var m:
	get:
		return _m.get_ref()
var react := Callable()
var runde := 0
## Ringe in diesem Gegnerzug (Regel 9)
var ringe := 0
## gezählt wie glut2.py (Rechnung): Züge, Antworten, Wehr, verstrichene Kerben, vertieft, Goldkerbe, gekappte Ringe, Täuschungen, Netz, Prankenhieb
var zaehler := {"zuege": 0, "gegenschlag": 0, "wachschuss": 0, "wehr": 0, "verstrichen": 0, "vertieft": 0, "gold": 0,
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
			f.gl = {"kerben": 0, "frei": 0, "bereit": 0, "haltung": "", "minus": 0, "gold_da": int(f.b.get("stufe", 1)) >= _i("gold_ab_stufe"),
				"gold_jetzt": false, "liegt": false, "betaeubt": 0, "marken": [], "gold_marke": false, "haltung_plan": ""}
			continue
		var herr = m.find(f.follows) if f.follows != "" else null
		var art := art_von(f)
		var boss: bool = herr == null and bool(f.b.get("boss", false))
		f.gl = {"art": art, "herr": herr, "boss": boss, "kerben": gegner_kerben(boss), "ab": start, "lauert": 0, "kerben_bereit": 0,
			"lauerte": false, "offen": false, "kraft": false, "plan": {}, "taeuscht": false, "erster": true, "tempo": tempo_gegner(art),
			"chance": float(f.b.get("chance", 1.0)), "anfuehrer": herr == null,
			"ueb": herr == null and bool(f.b.get("ueberfall", false)), "umr": herr == null and bool(f.b.get("umreissen", false)),
			"stufe_lesen": lesestufe(held.b, art, boss) if held != null else 2}
		if art == "Goblin-Späher" and f.gl.ab > NAH and bool(w()["plan"].get("spaeher_weit", true)):
			f.gl.ab = WEIT     # bleibt weit
	m.intents.clear()


## Beginn des Kampfs (Mars.start im Kerbensystem): Überfall zuerst (Regel 4, werte.json „merkmale“ „ueberfall“), dann Runde 1
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


## Regel 1, 7, 12: Zugbeginn: Haltung verstreicht (ihre Kerben zählen als verstrichen), Kerben neu, Goldkerbe dazu. false: der Zug fällt aus (betäubt)
func zug_beginnen(f) -> bool:
	zaehler.verstrichen += int(f.gl.bereit)
	if int(f.gl.bereit) > 0:
		_marke(f, M_HALT, M_GESCHLAGEN, 99)     # 930.7: die ungeschlagene Haltung verstreicht (Bild: kerbbild.gd beim Stichwort)
		m._say("", f.id, null, 0, null, false, false, "KERBE_VERSTREICHT")
	f.gl.bereit = 0
	f.gl.haltung = ""
	f.gl.haltung_plan = ""
	f.gl.trank_genommen = false
	f.gl.gewechselt = false
	f.moved = false     # 1275: Tausch je Zug neu (der alte Kampf setzte das in _advance)
	zaehler.zuege += 1
	if int(f.gl.betaeubt) > 0:
		f.gl.betaeubt -= 1
		_marke(f, "", M_GESCHLAGEN, 99)
		m._say(m.fmt(m.ST_STUNNED, m.lang, [f.name(m.lang)]), f.id)
		return false
	f.gl.kerben = zug_kerben(int(f.gl.minus), bool(f.gl.gold_jetzt))
	f.gl.marken = []
	for i in int(f.gl.kerben):
		f.gl.marken.append(M_FREI)
	f.gl.gold_marke = bool(f.gl.gold_jetzt)
	if f.gl.gold_jetzt:
		f.gl.gold_jetzt = false
		m._say("", f.id, null, 0, null, false, false, "KERBE_GOLD")
	f.gl.minus = 0
	f.gl.frei = frei(tempo_held(f.b))
	return true


## 930.7: die ersten [n] Kerben der Art [von] ("" jede, die nicht schon Asche ist) werden [zu]
func _marke(f, von: String, zu: String, n: int) -> void:
	var mk: Array = f.gl.get("marken", [])
	for i in mk.size():
		if n <= 0:
			return
		if (von == "" and mk[i] != M_GESCHLAGEN) or mk[i] == von:
			mk[i] = zu
			n -= 1


## 930.7: was der Kampfort von der Kerben zeigt, für jeden der Gruppe (mars.gd _say legt es jeder Meldung bei): Kerben [m],
## Art der Haltung [h], die vierte ist die Goldkerbe [f]
func bild() -> Dictionary:
	var out := {}
	for x in m.all:
		if x.side == "PARTY" and not (x.gl as Dictionary).is_empty():
			var h := String(x.gl.haltung) if String(x.gl.haltung) != "" else String(x.gl.get("haltung_plan", ""))
			out[x.id] = {"m": (x.gl.get("marken", []) as Array).duplicate(), "h": h, "f": bool(x.gl.get("gold_marke", false))}
	return out


## 930.7 (DESIGN-GLUT.md 7.3): Vorschau vor dem Bestätigen: wer in dieser Runde nacheinander zuschlägt, wenn [f] nach [p] spielt
## (Kennungen in Schlagfolge, ohne Würfel): erst der Held, dann je Gegner seine Antwort davor (Gegenschlag gegen jeden, der nah
## heran- oder zuschlägt; Wachschuss gegen jeden, der aus fern vorrückt), dann der Gegner; wer lauert, heilt oder Kraft gibt, schlägt nicht
func vorschau(f, p: Dictionary) -> Array:
	var out := []
	var tun := String(p.get("tun", WAFFE))
	var t = m.by_id(String(p.get("ziel", ""))) if p.has("ziel") else null
	if tun != WARTEN and tun != FLIEHEN and t != null and t.standing():
		out.append(f.id)
	var h := String(p.get("haltung", AUTO))
	if h == AUTO:
		h = vorschlag_haltung(f)
	var k := maxi(0, int(f.gl.kerben) - (0 if tun == WARTEN else _i("tun")) - maxi(0, int(p.get("vertiefen", 0))))
	for g in gegner():
		var gp: Dictionary = g.gl.plan if not (g.gl.plan as Dictionary).is_empty() else {"art": "schlag"}
		if String(gp.get("art", "")) in ["lauern", "heilen", "kraft"]:
			continue
		var nahkampf: bool = String(g.b.get("art", "nah")) == "nah"
		var ab := int(g.gl.ab)
		if g == t and tun != WARTEN and not (m.ZAUBER.has(tun) or _waffe(f).art == "fern"):
			ab = NAH     # der Held geht zu ihm
		if k > 0 and nahkampf and ((h == GEGENSCHLAG) or (h == WACHSCHUSS and ab > NAH)):
			out.append(f.id)
			k -= 1
		out.append(g.id)
	return out


## 930.7 (DESIGN-GLUT.md 7.2): Rest nach dem Tun, den das Daumenmenü verteilt (Vertiefen oder Haltung)
func rest_nach_tun(f) -> int:
	return maxi(0, int(f.gl.kerben) - _i("tun"))


## Mars.act im Kerbensystem: [plan] des Zugs von [f] (vorschlag), dann weiter bis zur nächsten Wahl der Gruppe
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
		var gl := int(g.gl.kerben)
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
	a.kerbe = p.duplicate()
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
## Kerben ins Tun (Rechnung). Plan: {tun, ziel, loesen, vertiefen, haltung}
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
		var loesen: bool = not nahe.is_empty() and nahe.all(func(g): return g.gl.tempo == "langsam") and int(f.gl.kerben) >= 2 and int(f.gl.frei) >= 1
		return {"tun": fa, "ziel": t.id, "loesen": loesen, "vertiefen": nl, "haltung": AUTO}
	return {"tun": WAFFE, "ziel": t.id, "vertiefen": nl, "haltung": AUTO}


## Ein Befehl der Knopfzeile des alten Kampfs als Plan, bis Stufe 2 die Bedienung baut (7.5: Angriff, Können, Tasche bleiben, Abwehr
## wird Wehr, Flucht bleibt): der Rest geht in die vorgeschlagene Haltung
func plan_aus(f, o: Array) -> Dictionary:
	match String(o[0]):
		"attack":
			return {"tun": WAFFE, "ziel": String(o[1]), "haltung": AUTO}
		"use":
			var t = o[2] if o.size() > 2 and o[2] != null else f.id
			return {"tun": String(o[1]), "ziel": String(t), "haltung": AUTO}
		"drink":
			return {"tun": WARTEN, "trank": String(o[1]), "trank_ziel": String(o[2]), "haltung": AUTO}
		"flee":
			return {"tun": FLIEHEN}
		"guard", "wait":
			return {"tun": WARTEN, "haltung": WEHR}
		"swap":
			return {"tun": WARTEN, "tausch": o[1], "haltung": AUTO}
		"draw":     # 1275: über mars.act geht der Wechsel vorweg (waffe_vorweg); hier nur, falls ein Plan ihn trägt
			waffe_vorweg(f)
			return {"tun": WARTEN, "haltung": AUTO}
	return vorschlag(f)


## 1266 (Befund Sokrates 15.11.: Trank über die Tasche beendete den Zug, gegen Regel 10 „Trank, Schlag und eine Haltung gehen in
## einem Zug“): der Trank aus der Tasche wirkt sofort, kostet seine Kerbe, und der Zug geht weiter (Tun und Haltung bleiben wählbar);
## einer je Zug. Alt: Battle.kt useItem (576–595) kostete den ganzen Zug. false: kein Trank möglich
func kann_trinken(f) -> bool:
	return not bool(f.gl.get("trank_genommen", false)) and int(f.gl.kerben) >= _i("trank")


func trank_vorweg(f, item: String, ziel) -> bool:
	if not kann_trinken(f):
		return false
	f.gl.kerben = int(f.gl.kerben) - _i("trank")
	f.gl.trank_genommen = true
	_marke(f, M_FREI, M_GESCHLAGEN, _i("trank"))
	m._drink(f, item, ziel if ziel != null else f)
	return true


## 1275 (Fremdprüfung Homer 15.11., 10:58, Regel 5: „Platztausch in der eigenen Reihe kostet den freien Schritt“): der Tausch über die
## Knopfzeile beendete den Zug (plan_aus „swap“ → warten). Jetzt sofort, kostet den freien Schritt (frei 0), danach Weg, Tun und
## Haltung wie sonst; [mit_waffe] wechselt dabei die Waffe (Regel 10). Alt: Skirmish.kt 519, Tausch und Wechsel setzten nur moved, der Zug ging weiter
func kann_tauschen(f: RefCounted) -> bool:
	return int(f.gl.get("frei", 0)) > 0


func tausch_vorweg(f: RefCounted, to: Vector2i, mit_waffe := false) -> bool:
	if not kann_tauschen(f) or to == f.place:
		return false
	f.gl.frei = 0
	var w := mit_waffe and kann_wechseln(f)
	f.moved = false     # _perform prüft wie im alten Kampf, dass noch nicht getauscht ist; der freie Schritt zählt hier
	m._perform(f, ["swap", to, w])
	f.moved = true
	if w:
		f.gl.gewechselt = true
	return true


## 1275 (Regel 10: „Kleines frei: Waffe wechseln … einmal je Zug“): plan_aus kannte „draw“ nicht, der Wechsel spielte den Vorschlag,
## also einen Angriff. Jetzt frei, einmal je Zug, der Zug geht weiter
func kann_wechseln(f: RefCounted) -> bool:
	return not bool(f.gl.get("gewechselt", false)) and f.spare() != null


func waffe_vorweg(f: RefCounted) -> bool:
	if not kann_wechseln(f):
		return false
	f.gl.gewechselt = true
	m._draw(f)
	return true


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
	var mk: Array = f.gl.get("marken", [])     # 930.7: was nicht in der Haltung wartet, ist verbraucht
	var n := int(f.gl.bereit)
	for i in range(mk.size() - 1, -1, -1):
		if mk[i] == M_GESCHLAGEN:
			continue
		mk[i] = M_HALT if n > 0 else M_GESCHLAGEN
		n -= 1
	if f.gl.bereit > 0 and f.gl.haltung != "":
		m._say("", f.id, null, 0, null, false, false, "KERBE_HALTUNG_" + String(f.gl.haltung).to_upper())


## Ein Zug nach [p]: {tun: waffe | Z_… | H_… | warten | fliehen, ziel, loesen, trank, vertiefen, haltung}
func held_zug(f, p: Dictionary) -> void:
	var kerbe := int(f.gl.kerben)
	var frei_ := int(f.gl.frei)
	var tun := String(p.get("tun", WAFFE))
	var h := String(p.get("haltung", AUTO))
	if tun == FLIEHEN:     # Regel 13: alle Kerben, Probe wie heute, nie vor einem Boss; ein schneller naher Gegner setzt nach
		assert(m.can_flee(f))
		f.gl.kerben = 0
		_marke(f, "", M_GESCHLAGEN, 99)
		m._flee(f)
		if m.outcome == "ONGOING":
			_setzt_nach(f, false)
		return
	if bool(p.get("loesen", false)) and kerbe > _i("loesen"):     # Regel 3
		kerbe -= _i("loesen")
		_marke(f, M_FREI, M_GESCHLAGEN, _i("loesen"))
		var nahe := gegner().filter(func(g): return int(g.gl.ab) == NAH)
		for g in nahe:
			g.gl.ab = FERN
		m._say("", f.id, null, 0, null, false, false, "KERBE_LOESEN")
		# 1275 (Regel 3: „außer die Haltung ist Wehr“): auch die vorgeschlagene Wehr (AUTO) schützt, nicht nur die ausdrücklich gewählte
		_setzt_nach(f, (vorschlag_haltung(f) if h == AUTO else h) == WEHR, nahe)
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
	if String(p.get("trank", "")) != "" and kerbe >= _i("trank") and not bool(f.gl.get("trank_genommen", false)):     # Regel 10: Trank kostet 1, ist kein Tun
		kerbe -= _i("trank")
		_marke(f, M_FREI, M_GESCHLAGEN, _i("trank"))
		m._drink(f, String(p.trank), m.by_id(String(p.get("trank_ziel", f.id))))
	if tun == WARTEN:
		_setze_haltung(f, kerbe, h)
		return
	if tun == "H_KRAFT" or tun == "Z_BANN" or tun == "Z_WUND" or tun == "Z_HAUT" or tun == "Z_BEISTAND":     # Regel 11, Zauber ohne Ziel
		var name := String(m.HANDLUNG.get(tun, m.ZAUBER.get(tun, tun)))
		var kk := (_i("kraft_schoepfen") if tun == "H_KRAFT" else tun_kosten(name))
		kerbe -= kk
		_marke(f, M_FREI, M_TUN, kk)
		m._use_skill(f, tun, m.by_id(String(p.get("ziel", f.id))))
		_setze_haltung(f, kerbe, h)
		return
	var t = m.by_id(String(p.get("ziel", "")))
	if t == null or not t.standing():
		_setze_haltung(f, kerbe, h)
		return
	var fern: bool = m.ZAUBER.has(tun) or _waffe(f).art == "fern"
	if not fern and int(t.gl.ab) > NAH:
		while int(t.gl.ab) > NAH and frei_ > 0:     # Regel 2
			t.gl.ab -= 1
			frei_ -= 1
		while int(t.gl.ab) > NAH and kerbe > 1:
			t.gl.ab -= 1
			kerbe -= _i("schritt")
			_marke(f, M_FREI, M_GESCHLAGEN, _i("schritt"))
		f.gl.frei = frei_
		if int(t.gl.ab) > NAH:     # nicht heran: der Rest geht in Wehr
			_setze_haltung(f, kerbe, WEHR)
			return
		if int(t.gl.lauert) > 0 and int(t.gl.kerben_bereit) > 0:     # Regel 17: wer heranrückt, läuft in den Schlag
			t.gl.kerben_bereit -= 1
			m._say("", t.id, f.id, 0, null, true, false, "KERBE_LAUERN")
			auf_held(t, f)
			if not f.standing() or m.outcome != "ONGOING":
				return
	var kosten := tun_kosten(String(m.ZAUBER.get(tun, m.HANDLUNG.get(tun, ""))))
	if kerbe < kosten:     # zu wenig Kerben für dieses Tun: der Rest geht in die Haltung
		_setze_haltung(f, kerbe, h)
		return
	_marke(f, M_FREI, M_TUN, kosten)
	if tun != WAFFE and tun != "Z_FUNKEN":     # übrige Zauber und Kampfhandlungen rechnet der alte Kampf (Stufe 1: ohne Vertiefen)
		m._use_skill(f, tun, t)
		if m.outcome == "ONGOING":
			_setze_haltung(f, kerbe - kosten, h)
		return
	var nd := mini(maxi(0, int(p.get("vertiefen", 0))), kerbe - kosten)     # Regel 7: Vertiefen
	_marke(f, M_FREI, M_TIEF, nd)
	if kerbe - kosten - nd > 0:     # 930.7: im Bild liegt der Rest schon während des Schlags in der geplanten Haltung
		f.gl.haltung_plan = vorschlag_haltung(f) if h == AUTO else h
		_marke(f, M_FREI, M_HALT, kerbe - kosten - nd)
	if nd > 0:
		zaehler.vertieft += nd
		m._say("", f.id, t.id, 0, null, false, false, "KERBE_VERTIEFEN")
	held_schlag(f, t, tun, 0.0, vertiefen_faktor(nd))
	if m.outcome != "ONGOING":
		return
	_setze_haltung(f, kerbe - kosten - nd, h)


## Regel 3, 13: ein schneller naher Gegner setzt nach (Schlag mit Ring), außer die Haltung ist Wehr
func _setzt_nach(f, wehr: bool, von := []) -> void:
	if wehr:
		return
	for g in (von if not von.is_empty() else gegner().filter(func(x): return int(x.gl.ab) == NAH)):
		if g.standing() and g.gl.tempo == "schnell" and m.outcome == "ONGOING":
			auf_held(g, f, 1.0, true)


## Schlag des Helden mit [tun] (Waffe oder Funkenpfeil) wie glut2.py held_schlag: Treffer gegen die Abwehr, Schaden mal Schwäche
## und [faktor] (Vertiefen, Antwort), nach der Rüstung; Antworten nie kritisch und ohne Ungunst des Flatterns (Regel 7)
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

func _gold(f, perfekt := false) -> void:
	if f.side == "PARTY" and f.gl.gold_da and (perfekt or f.hp < _f("gold_unter_leben") * f.max_hp):
		f.gl.gold_da = false
		f.gl.gold_jetzt = true
		zaehler.gold += 1


## Ein Schlag von [g] auf [t] wie glut2.py auf_held: Wehr (eine Kerbe, Ungunst), Kraft des Schamanen, großer Schlag mit Ring (höchstens
## zwei je Gegnerzug, Regel 9), Schaden nach Abzug. null: verfehlt; sonst der Anteil des Rings (1 ohne Ring)
func auf_held(g, t, faktor := 1.0, gross := false, bonus := 0.0, wehr_hilft := true, schaden := true):
	var W := BrsKampf.w()
	var wehr := false
	if wehr_hilft and int(t.gl.bereit) > 0 and t.gl.haltung == WEHR:     # Regel 7: Wehr
		t.gl.bereit -= 1
		_marke(t, M_HALT, M_GESCHLAGEN, 1)
		zaehler.wehr += 1
		wehr = true
		bonus += _f("wehr_ungunst")
		m._say("", t.id, g.id, 0, null, true, false, "KERBE_WEHR")
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
				_gold(t, true)
		else:
			zaehler.ringe_gekappt += 1
	if schaden:
		var zg: float = m.dice.randf()
		var zs: float = m.dice.randf()
		var sch := Brs.schaden_roh(float(g.b.schaden), float(g.b.angriff), float(int(g.b.stufe) - int(t.b.stufe)), zg, 1.0, zs) * faktor * anteil
		var n := int(Brs.endschaden(sch, BrsKampf.held_abzug(t.b, not t.drawn) + t.schutz))
		m._hurt(t, n, g.id, m.fmt(m.wolf(g, "MSG279_WOLFHITS", "MSG72_HITS"), m.lang, [g.name(m.lang), t.name(m.lang), n]), info, true)
	_gold(t)
	return anteil


## Wachschuss (Regel 7): rückt [g] ein Feld vor, schießt der Held vorher, eine Kerbe, halber Schaden bis Geselle, nie kritisch
func _wachschuss(f, g) -> void:
	if int(f.gl.bereit) > 0 and f.gl.haltung == WACHSCHUSS and aktion_fern(f) != "":
		f.gl.bereit -= 1
		_marke(f, M_HALT, M_GESCHLAGEN, 1)
		zaehler.wachschuss += 1
		m._say("", f.id, g.id, 0, null, true, false, "KERBE_WACHSCHUSS")
		var fa := aktion_fern(f)
		held_schlag(f, g, fa, 0.0, antwort_faktor(float(f.b.fert.get(_fert_von(f, fa), 0))), true)


## Gegenschlag (Regel 7): kommt [g] nah heran oder schlägt er aus nah zu, schlägt der Held vorher
func _gegenschlag(f, g) -> void:
	if int(f.gl.bereit) > 0 and f.gl.haltung == GEGENSCHLAG and aktion_fern(f) == "":
		f.gl.bereit -= 1
		_marke(f, M_HALT, M_GESCHLAGEN, 1)
		zaehler.gegenschlag += 1
		m._say("", f.id, g.id, 0, null, true, false, "KERBE_GEGENSCHLAG")
		held_schlag(f, g, WAFFE, 0.0, antwort_faktor(float(f.b.fert.get(_fert_von(f, WAFFE), 0))), true)


## Fertigkeit, nach der eine Antwort voll wird (glut2.py: die der Waffe, auch für den Funkenpfeil)
func _fert_von(f, _tun: String) -> String:
	return String(_waffe(f).gruppe)


## Regel 2: [g] rückt heran, freie Felder zuerst, dann Kerben (eine bleibt fürs Tun); vor jedem Feld der Wachschuss
func _heran(g, f, kerbe: int, frei_: int) -> int:
	while int(g.gl.ab) > NAH and frei_ > 0:
		g.gl.ab -= 1
		frei_ -= 1
		_wachschuss(f, g)
		if not g.standing():
			return kerbe
	while int(g.gl.ab) > NAH and kerbe > 1:
		g.gl.ab -= 1
		kerbe -= _i("schritt")
		_wachschuss(f, g)
		if not g.standing():
			return kerbe
	return kerbe


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
		var kerbe := int(g.gl.kerben)
		g.gl.lauert = 0
		g.gl.kerben_bereit = 0
		var p: Dictionary = g.gl.plan if not (g.gl.plan as Dictionary).is_empty() else {"gross": false, "art": "schlag"}
		if g.gl.taeuscht:
			zaehler.getaeuscht += 1
		var art: String = g.gl.art
		if art == "Goblin-Schamane":
			if int(g.gl.ab) == NAH and kerbe >= 2:
				g.gl.ab = FERN
				kerbe -= _i("schritt")
			var andere := gegner().filter(func(x): return x != g)
			if p.art == "heilen" and not andere.is_empty():
				var a = andere[0]
				for x in andere:
					if float(x.hp) / x.max_hp < float(a.hp) / a.max_hp:
						a = x
				var n := mini(a.max_hp - a.hp, int(P["schamane_heilung"]))
				a.hp += n
				kerbe -= _i("tun")
				m._say(m.fmt(X.MSG72_HEALS, m.lang, [g.name(m.lang), a.name(m.lang), n]), g.id, a.id, 0, null, false, false, "HEAL")
			elif p.art == "kraft" and not andere.is_empty() and kerbe >= 2:
				var a = andere[0]
				for x in andere:
					if int(x.gl.ab) < int(a.gl.ab):
						a = x
				a.gl.kraft = true
				kerbe -= _i("gross_kosten")
				m._say("", g.id, a.id, 0, null, false, false, "KERBE_KRAFT")
			if kerbe >= 1 and m.dice.randf() < float(g.gl.chance):
				auf_held(g, f)
			continue
		if art == "Riesenspinne" and p.art == "netz" and int(g.gl.ab) > NAH:     # Netz: Ring, Treffer zieht heran und nimmt eine Kerbe
			zaehler.netz += 1
			var r = auf_held(g, f, 1.0, true, 0.0, true, false)
			if r != null and float(r) > 0.0:
				g.gl.ab -= 1
				f.gl.minus += 1
				m._say("", g.id, f.id, 0, null, false, false, "KERBE_NETZ")
			continue
		if String(g.b.get("art", "nah")) != "nah":     # Schütze: aus nah zurück, dann Schuss
			if int(g.gl.ab) == NAH and kerbe >= 2:
				g.gl.ab = FERN
				kerbe -= _i("schritt")
			var gr: bool = p.gross and kerbe >= _i("gross_kosten")
			if m.dice.randf() < float(g.gl.chance):
				auf_held(g, f, _f("gross_faktor") if gr else 1.0, gr)
			continue
		if p.art == "lauern" and int(g.gl.ab) > NAH:     # Regel 17
			g.gl.lauert = 1
			g.gl.kerben_bereit = 1
			g.gl.lauerte = true
			m._say("", g.id, null, 0, null, false, false, "KERBE_LAUERT")
			continue
		g.gl.lauerte = false
		var fr := 99 if (hetzt and g.gl.herr == leit) else frei(String(g.gl.tempo))
		kerbe = _heran(g, f, kerbe, fr)
		if not g.standing() or int(g.gl.ab) > NAH:
			continue
		_gegenschlag(f, g)     # Regel 8: die Antwort löst keine Antwort aus; fällt er, ist der Angriff weg
		if not g.standing() or m.outcome != "ONGOING":
			continue
		if p.art == "prankenhieb" and kerbe >= int(P["prankenhieb_kosten"]):     # Krogg: Ring zum Ausweichen, Wehr hilft nicht
			kerbe -= int(P["prankenhieb_kosten"])
			zaehler.prankenhieb += 1
			if g.gl.ueb and g.gl.erster:
				g.gl.erster = false
			var r = auf_held(g, f, _f("gross_faktor"), true, 0.0, false)
			if r != null and float(r) > 0.0:
				g.gl.ab = FERN     # schleudert auf fern
			g.gl.offen = true
		elif p.gross and kerbe >= _i("gross_kosten"):     # Regel 16
			kerbe -= _i("gross_kosten")
			if g.gl.ueb and g.gl.erster:
				g.gl.erster = false
			auf_held(g, f, _f("gross_faktor"), true)
		else:
			kerbe -= _i("tun")
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
		if art == "Riesenfledermaus" and kerbe >= 1:     # löst sich
			g.gl.ab = FERN
			kerbe -= _i("schritt")
		elif kerbe > 0 and art in w()["lauern_arten"]:     # Regel 17: übrige Kerben lauert
			g.gl.lauert = 1
			g.gl.kerben_bereit = kerbe


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
