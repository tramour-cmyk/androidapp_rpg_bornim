extends RefCounted
# 478 (Chef 07.11., 16:3x: „Wir packen das BRS auf jeden Fall jetzt auch mit dazu“; 470a C: der Rechenkern des Kampfs zieht vor, die
# Darstellung bleibt bei 2.3): MARS rechnet Treffer, Schaden und Leben nach dem BRS, Modell D (DESIGN-SPIELSYSTEM-2-0-ENTWURF.md
# Abschnitt 7 und Entwurf A), mit denselben Formeln und Zahlen wie die Simulation 444 (tools/sim444/sim.py, daten/werte.json über
# regeln/brs.gd). Hier stehen nur die Brücken: was ein Kämpfer nach dem BRS ist (Grundwerte, Fertigkeiten, Waffe, Rüstung, Schild,
# Stufe) und ein Schlag mit allen Einzelheiten für Bericht, Bild und Zustände.
# Seit 870.5 ohne Schalter: der SRD-Zweig der Angriffe in mars.gd ist weg.
# Annahmen (A), bis 2.3 und die Pfade sie ersetzen: ohne Spielstand nach BRS (Probekampf, Söldner) gilt die Herkunft der alten Klasse
# mit ihren Startfertigkeiten; Waffen und Rüstungen des Helden (BrsHeld) zählen nach ihrer Gruppe; was noch in Würfeln des SRD rechnet
# (Fähigkeiten der Klassen, Zauber mit Rettungswurf, Heilung, Tränke, Zustände), wird mit dem Verhältnis der Leben nach BRS zu SRD
# des Getroffenen umgerechnet (massstab), so bleibt ihr Gewicht im Kampf, wie es war.

const Brs = preload("res://regeln/brs.gd")
const BrsHeldS = preload("res://regeln/brs_held.gd")

## 870.5 (LISTE-UMZUG-BRS.md Schritt 5): gekämpft wird nur nach dem BRS; ohne daten/werte.json kein Kampf
static func an() -> bool:
	return not Brs.lade().is_empty()

## Herkunft für eine alte Klasse (BrsHeld.KLASSE_ALT umgekehrt, je Klasse die erste)
const KLASSE_HERKUNFT := {"FIGHTER": "Wachsoldat", "CLERIC": "Klosterschüler", "ROGUE": "Jägerkind", "WIZARD": "Zauberlehrling"}
## Waffe des Helden (Grundform) -> Waffengruppe: BrsHeld.WAFFE_GRUPPE (870.2)
## Gewicht der Brustrüstung (held.json „gewicht“) -> Rüstung des BRS
const RUESTUNG := {"LIGHT": "Leichte Rüstung", "MEDIUM": "Mittlere Rüstung", "HEAVY": "Schwere Rüstung"}
## alte Zauber -> Zauber des BRS (werte.json „zauber“), Grundschaden im Verhältnis zum Feuerpfeil (1W10)
const ZAUBER_ANGRIFF := ["FIRE_BOLT", "SCORCHING_RAY"]
const FEUERPFEIL_SRD := [1, 10, 0]
## Vorteil und Nachteil des MARS (Reihen, Deckung, Blind …) wie Umreißen: ±25 Prozentpunkte (werte.json „merkmale“)
const NACHTEIL_SONST := -25.0
## 1 Punkt auf den W20 des SRD = 5 % (werte.json „merkmale“ _quelle: 1 Punkt W20 = 10 Punkte Angriff bei 0,5 % je Punkt)
const PROZENT_JE_W20 := 5.0


static func w() -> Dictionary:
	return Brs.lade()


static func nachteil() -> float:
	return float(w().get("merkmale", {}).get("umreissen", {}).get("naechster_angriff_treffer", NACHTEIL_SONST))


static func mittel(expr) -> float:
	if expr == null or not (expr is Array) or expr.size() < 3:
		return 0.0
	return float(expr[0]) * (float(expr[1]) + 1.0) / 2.0 + float(expr[2])


## Was ein Held oder Söldner nach dem BRS ist. [sheet]: MARS-Blatt (aufruf.blatt, tabellen.json „probe“); [daten]: der Held nach BRS
## aus dem Spielstand (BrsHeld.als_daten, zustand.brs) oder leer.
static func held(sheet: Dictionary, daten := {}) -> Dictionary:
	var W := w()
	if sheet.get("brs") is Dictionary and not (sheet.brs as Dictionary).is_empty():
		return aus_blatt(sheet.brs)
	var h: Dictionary = W["held"]
	var herkunft: String = KLASSE_HERKUNFT.get(String(sheet.get("cls", "")), "Wanderer")
	var werte := {}
	var fert := {}
	if not daten.is_empty():
		var bh = BrsHeldS.aus_daten(daten)
		herkunft = bh.herkunft
		werte = bh.werte()
		fert = bh.fertigkeiten()
	else:
		var hk: Dictionary = W["herkuenfte"].get(herkunft, W["herkuenfte"]["Wanderer"])
		for g in Brs.lade()["erschaffung"]["grundwerte"]:
			werte[g] = int(h["grundwert_min"])
		for g in hk["plus"]:
			werte[g] += int(hk["plus"][g])
		for g in hk.get("plus_variante", {}):     # 21 Punkte (Entscheidung 77), wie die Simulation (Spalte „21“)
			werte[g] += int(hk["plus_variante"][g])
		for g in werte:
			werte[g] = mini(int(werte[g]), int(h["grundwert_max"]))
		for f in hk["fertigkeiten"]:
			fert[f] = int(h["startfertigkeit"])
	for f in sheet.get("brs_fert", {}):     # was der Held seither geübt hat (2.3)
		fert[f] = int(sheet.brs_fert[f])
	var hk2: Dictionary = W["herkuenfte"].get(herkunft, {})
	var ruestung: String = String(sheet.get("brs_ruestung", hk2.get("ruestung", "keine")))
	var schild: bool = String(sheet.get("schild", "")) != "" if sheet.has("schild") else int(sheet.get("ac", 0)) > int(sheet.get("acDrawn", 0))
	var zauber: Array = hk2.get("zauber", []).duplicate()
	return {"stufe": int(sheet.get("level", 1)), "werte": werte, "fert": fert, "herkunft": herkunft, "ruestung": ruestung,
		"schild": schild, "zauber": zauber}


## 870.2: der Kämpfer aus BrsHeld.kampfblatt() (Schritt 2 des Umzugs), ohne Umweg über die Klasse
static func aus_blatt(k: Dictionary) -> Dictionary:
	return {"stufe": int(k.get("stufe", 1)), "werte": (k.get("werte", {}) as Dictionary).duplicate(), "fert": (k.get("fert", {}) as Dictionary).duplicate(),
		"herkunft": String(k.get("herkunft", "Wanderer")), "ruestung": String(k.get("ruestung", {}).get("art", "keine")),
		"schild": not (k.get("schild", {}) as Dictionary).is_empty(), "zauber": (k.get("faehigkeiten", []) as Array).filter(func(z): return w()["zauber"].has(z)),
		"waffe": String(k.get("waffe", {}).get("gruppe", "")), "leben": int(k.get("leben", 0)), "volk": String(k.get("volk", ""))}


## 870.2: Waffengruppe, mit der der Held schlägt: die Hauptwaffe aus dem Blatt, eine gezogene Zweitwaffe ([zweite]) nach ihrer Grundform
static func waffe_held(b: Dictionary, wsheet, zweite := false) -> String:
	if not zweite and String(b.get("waffe", "")) != "":
		return String(b.waffe)
	return waffe_von(wsheet)


static func leben_held(b: Dictionary) -> int:
	if int(b.get("leben", 0)) > 0:     # 870.2: aus dem Kampfblatt
		return int(b.leben)
	var h: Dictionary = w()["held"]
	return int(h["leben_basis"]) + int(h["leben_je_stufe"]) * int(b.stufe) + int(h["leben_je_zaehigkeit"]) * int(b.werte.get("zaehigkeit", 0))


static func waffe_von(wsheet) -> String:
	var id: String = String(wsheet.get("id", "")) if wsheet is Dictionary else ""
	return BrsHeldS.WAFFE_GRUPPE.get(id, "Einhänder" if not (wsheet is Dictionary and bool(wsheet.get("ranged", false))) else "Bogen")


## Werte eines Gegners nach dem Bestiarium „Werte 2.0“ (brs.gd monster), einzige Quelle daten/werte.json (870.3). Begleiter eines
## Anführers (Jungwolf, Leibwache; [m] trägt „rudel“ und „anfuehrer“, aufruf.gd) nehmen Stufe, Abwehr und Rüstung ihres Körpers
## (werte.json „merkmale“ „rudel“ „koerper“), den Angriff des Anführers plus Verschiebung, seinen Schaden mal Anteil und die Leben
## ihres Körpers mal Anteil. [art] bleibt für die Aufrufer.
static func gegner(m: Dictionary, art := {}) -> Dictionary:
	if m.has("rudel"):
		return Brs.begleiter(String(m.rudel), String(m.get("anfuehrer", "")))
	var b := Brs.monster(String(m.get("id", ""))).duplicate()
	return b


## Abwehr des Helden gegen einen Angriff der Art [art] („nah“, „fern“, „zauber“): der beste von Ausweichen (+2 je Gewandtheit), Schild
## (nur mit Schild in der Hand) und halber Fertigkeit der Nahkampfwaffe (nur gegen Nahkampf). [drawn]: die zweite Waffe in der Hand.
static func held_abwehr(b: Dictionary, art: String, waffe: String, schild_in_hand: bool) -> Array:
	var k: Dictionary = w()["kampf"]
	var wahl := [["Ausweichen", float(b.fert.get("Ausweichen", 0)) + float(k["ausweichen_je_gewandtheit"]) * float(b.werte.get("gewandtheit", 0))]]
	if b.schild and schild_in_hand:
		wahl.append(["Schild", float(b.fert.get("Schild", 0))])
	var wd: Dictionary = w()["waffen"].get(waffe, {})
	if art == "nah" and String(wd.get("art", "nah")) == "nah":
		wahl.append([waffe, float(b.fert.get(waffe, 0)) * float(k["parieren_anteil_waffenfertigkeit"])])
	var best: Array = wahl[0]
	for x in wahl:
		if float(x[1]) > float(best[1]):
			best = x
	return best


## Abzug des Helden: Rüstung × (1 + Rüstungsfertigkeit/100), dazu der Schild × (1 + Schild/100), wenn er ihn trägt.
static func held_abzug(b: Dictionary, schild_in_hand: bool) -> float:
	var W := w()
	var k: Dictionary = W["kampf"]
	var r: Dictionary = W["ruestungen"].get(b.ruestung, W["ruestungen"]["keine"])
	var je := float(k["ruestungsfertigkeit_im_abzug_je_punkt"])
	var a := float(r["wert"]) * (1.0 + (float(b.fert.get(String(r["fertigkeit"]), 0)) if r["fertigkeit"] != null else 0.0) * je)
	if b.schild and schild_in_hand:
		a += float(W["ruestungen"]["schild_wert"]) * (1.0 + float(b.fert.get("Schild", 0)) * je)
	return a


## Ein Schlag mit den Würfeln aus [rng] in der Reihenfolge der Simulation (Treffer, Glück, kritisch, Streuung) wie Brs.schaden, mit
## allen Einzelheiten: {treffer, wurf (1–100), chance (Prozent), kritisch, glueck, schaden}.
static func schlag(rng: RandomNumberGenerator, fertigkeit: float, abwehr: float, grund: float, d: float, abzug: float, bonus := 0.0, kritisch_prozent := 0.0) -> Dictionary:
	var k: Dictionary = w()["kampf"]
	var chance := Brs.trefferchance(fertigkeit, abwehr, bonus)
	var z := rng.randf()
	var e := {"treffer": z < chance, "wurf": int(floor(z * 100.0)) + 1, "chance": roundi(chance * 100.0), "kritisch": false,
		"glueck": false, "schaden": 0.0}
	if not e.treffer:
		return e
	var zg := rng.randf()
	var zk := rng.randf() if kritisch_prozent > 0.0 else 1.0
	var zs := rng.randf()
	e.glueck = zg < float(k["glueckstreffer_anteil"]) and Brs.stufenfaktor(d) < 1.0
	e.kritisch = kritisch_prozent > 0.0 and zk * 100.0 < kritisch_prozent
	e.schaden = Brs.endschaden(Brs.schaden_roh(grund, fertigkeit, d, zg, zk, zs, kritisch_prozent), abzug)
	return e
