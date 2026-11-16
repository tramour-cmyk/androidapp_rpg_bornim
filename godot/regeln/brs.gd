class_name Brs
extends RefCounted
# 473 (Abnahme 1.4): Monsterwerte Kapitel 1 nach dem BRS auf Rechenmodell D (E 73–75, NW 7).
# Einzige Quelle der Zahlen: tools/sim444/werte.json (im Bau nach daten/werte.json kopiert), dieselbe Datei, mit der die
# Rechensimulation 444 rechnet; Werte der Arten aus LISTE-BESTIARIUM.md „Werte 2.0“. Die Regeln hier sind die von
# tools/sim444/sim.py (stufenfaktor, trefferchance, schaden_roh, endschaden, ep_fuer), Gegenprobe: tests/brs_473.gd.
# Der Kampf (mars.gd, klassisch.gd) rechnet noch nach SRD (tabellen.json); er stellt mit 2.3 auf diese Regeln um,
# die Heldenstufe aus Erfahrung kommt mit 472.

const DATEI := "res://daten/werte.json"

# Kennung im Spiel -> Art im Bestiarium, Name, Gruppe: werte.json „kennungen“ (870.3, 649a Schritt 1); Nachfolger nach 348.12c
# erben die Werte dort.
static func kennung(id: String) -> Dictionary:
	var k = lade().get("kennungen", {}).get(id, {})
	return k if k is Dictionary else {}

## Anzeigename einer Kennung (Sprache 0 deutsch, 1 englisch); "" ohne Eintrag
static func name(id: String, sprache := 0) -> String:
	return String(kennung(id).get("en" if sprache == 1 else "de", ""))

static var W := {}

static func lade() -> Dictionary:
	if W.is_empty():
		var j = JSON.parse_string(FileAccess.get_file_as_string(DATEI)) if FileAccess.file_exists(DATEI) else null
		if j is Dictionary:
			W = j
		else:
			push_error("473: %s fehlt oder ist kaputt" % DATEI)
	return W

static func kampf() -> Dictionary: return lade().get("kampf", {})

## Werte einer Art nach Kennung im Spiel (stufe, leben, ruestung, schaden, angriff, abwehr, wachsamkeit, art, gebiet,
## boss, schwaeche); leer, wenn die Kennung keine Art des Bestiariums ist.
static func monster(id: String) -> Dictionary:
	var m = lade().get("monster", {}).get(String(kennung(id).get("art", "")), {})
	return m if m is Dictionary else {}

## 870.3: Werte eines Begleiters [rudel] (werte.json „merkmale“ „rudel“: Jungwolf, Leibwache) hinter dem Anführer [anfuehrer]
## (Kennung im Spiel): Körper (Stufe, Abwehr, Rüstung, Leben × leben_anteil), Angriff des Anführers + angriff_verschiebung, Schaden
## des Anführers × schaden_anteil, chance je Runde; leer, wenn eins fehlt.
static func begleiter(rudel: String, anfuehrer: String) -> Dictionary:
	var r = lade().get("merkmale", {}).get("rudel", {}).get(rudel, {})
	var f := monster(anfuehrer)
	if not (r is Dictionary) or r.is_empty() or f.is_empty():
		return {}
	var k = lade().get("monster", {}).get(String(r.get("koerper", "")), {})
	var b: Dictionary = (k if k is Dictionary and not k.is_empty() else f).duplicate()
	b.erase("boss")
	b.erase("rudel")
	b.erase("umreissen")
	b.angriff = float(f["angriff"]) + float(r.get("angriff_verschiebung", 0))
	b.schaden = float(f["schaden"]) * float(r.get("schaden_anteil", 1.0))
	b.leben = maxi(1, runde(float(b["leben"]) * float(r.get("leben_anteil", 1.0))))
	b.chance = float(r.get("chance", 1.0))
	b.angreifbar = bool(r.get("angreifbar", true))     # 870.5: Leibwache nicht (wie alt Packs.kt guard, 444 „rudel“)
	return b

static func stufe(id: String) -> int: return int(monster(id).get("stufe", 0))
static func boss(id: String) -> bool: return bool(monster(id).get("boss", false))

## Python rundet halbe auf die gerade (Bestiarium „Rundung“: 4,5 -> 4, 5,5 -> 6); GDScript round() nicht.
static func runde(x: float) -> int:
	var f := floorf(x)
	var r := x - f
	if is_equal_approx(r, 0.5):
		return int(f) if int(f) % 2 == 0 else int(f) + 1
	return int(f) + 1 if r > 0.5 else int(f)

## Stufenunterschied d = eigene Stufe − Stufe des Ziels; je Stufe 10 %, nie unter 0.
static func stufenfaktor(d: float) -> float:
	return maxf(0.0, 1.0 + float(kampf()["stufenfaktor_je_stufe"]) * d)

## Trefferchance 0..1 aus Fertigkeit des Angreifers gegen Abwehr des Ziels, begrenzt 5–95 %.
static func trefferchance(angriff: float, abwehr: float, bonus := 0.0) -> float:
	var k := kampf()
	var c: float = float(k["trefferchance_basis"]) + (angriff - abwehr) * float(k["trefferchance_je_punkt"]) + bonus
	return clampf(c, float(k["trefferchance_min"]), float(k["trefferchance_max"])) / 100.0

## (Grundschaden) × (1 + Fertigkeit/100) × Stufenfaktor, Glückstreffer (Stufenfaktor mindestens 1), kritisch, Streuung.
## Die Zufallszahlen 0..1 kommen von außen (z_glueck, z_krit, z_streu), damit Spiel und Simulation gleich rechnen;
## gewuerfelt wird in schaden().
static func schaden_roh(grund: float, fertigkeit: float, d: float, z_glueck: float, z_krit: float, z_streu: float, kritisch_prozent := 0.0) -> float:
	var k := kampf()
	var sf := stufenfaktor(d)
	if z_glueck < float(k["glueckstreffer_anteil"]):
		sf = maxf(sf, 1.0)
	var s := grund * (1.0 + fertigkeit * float(k["fertigkeit_im_schaden_je_punkt"])) * sf
	if kritisch_prozent > 0.0 and z_krit * 100.0 < kritisch_prozent:
		s *= float(k["kritisch_faktor"])
	var st := float(k["streuung"])
	if st > 0.0:
		s *= (1.0 - st) + 2.0 * st * z_streu
	return s

## Abzug der Rüstung, nie unter 0, gerundet wie die Simulation.
static func endschaden(s: float, abzug: float) -> float:
	var r := maxf(0.0, s - abzug)
	return float(runde(r)) if bool(kampf().get("schaden_runden", true)) else r

## Ein Schlag mit Würfeln aus rng in der Reihenfolge der Simulation (Treffer, Glück, kritisch, Streuung); 0 heißt daneben.
## Die Fertigkeit zählt für Treffer und Schaden (Modell D), beim Monster ist es sein Angriff.
static func schaden(rng: RandomNumberGenerator, fertigkeit: float, abwehr: float, grund: float, d: float, abzug: float, bonus := 0.0, kritisch_prozent := 0.0) -> float:
	if rng.randf() >= trefferchance(fertigkeit, abwehr, bonus):
		return 0.0
	var zg := rng.randf()
	var zk := rng.randf() if kritisch_prozent > 0.0 else 1.0
	var zs := rng.randf()
	return endschaden(schaden_roh(grund, fertigkeit, d, zg, zk, zs, kritisch_prozent), abzug)

## Das Monster [id] schlägt den Helden der Stufe [held_stufe] mit [abwehr] und Rüstungsabzug [abzug]; Fertigkeit = Angriff.
static func monsterschlag(rng: RandomNumberGenerator, id: String, held_stufe: int, abwehr: float, abzug: float) -> float:
	var m := monster(id)
	if m.is_empty():
		return 0.0
	return schaden(rng, float(m["angriff"]), abwehr, float(m["schaden"]), float(int(m["stufe"]) - held_stufe), abzug)

## Erfahrung für den Sieg über [id]: 10 × Stufe², Boss × 3, dann Faktor aus Modell D (null ab 9 Stufen darüber,
## höchstens doppelt gegen Stärkere).
static func erfahrung(held_stufe: int, id: String) -> float:
	var m := monster(id)
	if m.is_empty():
		return 0.0
	var e: Dictionary = lade()["erfahrung"]
	var s := int(m["stufe"])
	var basis := float(e["je_gegner_faktor"]) * s * s
	if bool(m.get("boss", false)):
		basis *= float(e["boss_faktor"])
	var d := held_stufe - s
	var f := 1.0
	if d > 0:
		f = 0.0 if d >= int(e["hoeher_null_ab"]) else 1.0 - float(d) / float(e["hoeher_null_ab"])
	elif d < 0:
		f = minf(float(e["tiefer_hoechstens"]), 1.0 - float(d) / float(e["tiefer_teiler"]))
	return basis * f

# ---------------------------------------------------------------- Heldenstufe aus Erfahrung (472, Abnahme 1.3)
# Der Stand des Helden ist ein Dictionary (neuer_stand()): stufe, ep (in der Stufe), ep_fert (davon aus Fertigkeiten),
# toepfe (Gebiet -> Rest). Deckel und Aufstieg wie Held.gib_ep / stufe_auf in sim.py; dazu weiche Grenze (E 18) und
# Erfahrungstopf je Gebiet (E 19, E 21), die die Simulation noch nicht rechnet.

static func neuer_stand() -> Dictionary:
	return {"stufe": 1, "ep": 0.0, "ep_fert": 0.0, "toepfe": {}}

static func grenze() -> int: return int(lade()["held"]["kapitelgrenze"])
static func hoechste_stufe() -> int: return grenze() + int(lade()["erfahrung"]["weich_stufen"])

## Erfahrung von [stufe] bis zur nächsten (100 × Stufe).
static func bedarf(stufe: int) -> float:
	return float(lade()["erfahrung"]["bis_naechste_stufe_je_stufe"]) * stufe

## Voller Topf eines Gebiets: 10 × Stufe² jeder Art, die dort vorkommt, einmal, ohne Bosse.
static func topf_voll(gebiet: String) -> float:
	var e: Dictionary = lade()["erfahrung"]
	var t := 0.0
	for n in lade()["monster"]:
		var m = lade()["monster"][n]
		if n.begins_with("_") or not (m is Dictionary) or bool(m.get("boss", false)): continue
		if gebiet in m.get("gebiet", []):
			t += float(e["je_gegner_faktor"]) * int(m["stufe"]) * int(m["stufe"])
	return t

## Gibt [menge] Erfahrung aus [quelle] ("kampf", "fertigkeit", "probe", "quest") in den Stand [h]. Kampf in [gebiet]
## (ohne Boss) schöpft aus dem Topf, leer nur topf_rest_anteil; ab der Kapitelgrenze ein Viertel; Fertigkeiten höchstens
## 40 % des Bedarfs der Stufe; auf der höchsten Stufe nichts mehr. Steigt selbst auf.
## Zurück: {gegeben, verfallen, deckel (Deckel jetzt erreicht), topf_leer, aufstiege}.
static func gib_erfahrung(h: Dictionary, menge: float, quelle: String, gebiet := "", boss := false) -> Dictionary:
	var e: Dictionary = lade()["erfahrung"]
	var r := {"gegeben": 0.0, "verfallen": 0.0, "deckel": false, "topf_leer": false, "aufstiege": 0}
	if menge <= 0.0:
		return r
	var roh := menge
	if quelle == "kampf" and gebiet != "" and not boss:
		var rest: float = h["toepfe"].get(gebiet, topf_voll(gebiet))
		var aus_topf := minf(menge, rest)
		h["toepfe"][gebiet] = rest - aus_topf
		menge = aus_topf + (menge - aus_topf) * float(e["topf_rest_anteil"])
		r.topf_leer = rest - aus_topf <= 0.0
	if int(h["stufe"]) >= hoechste_stufe():
		r.verfallen = roh
		return r
	if int(h["stufe"]) >= grenze():
		menge *= float(e["weich_faktor"])
	if quelle == "fertigkeit":
		var erl: float = float(e["fertigkeit_deckel"]) * bedarf(int(h["stufe"])) - float(h["ep_fert"])
		if erl <= 0.0:
			r.verfallen = roh
			return r
		if menge >= erl:
			r.deckel = true
			menge = erl
		h["ep_fert"] = float(h["ep_fert"]) + menge
	h["ep"] = float(h["ep"]) + menge
	r.gegeben = menge
	r.verfallen = roh - menge
	while int(h["stufe"]) < hoechste_stufe() and float(h["ep"]) >= bedarf(int(h["stufe"])):
		h["ep"] = float(h["ep"]) - bedarf(int(h["stufe"]))
		h["stufe"] = int(h["stufe"]) + 1
		h["ep_fert"] = 0.0
		r.aufstiege += 1
	return r

## Ist der Deckel der Fertigkeiten in dieser Stufe erreicht? (Anzeige, NW 4)
static func deckel_erreicht(h: Dictionary) -> bool:
	return float(h["ep_fert"]) >= float(lade()["erfahrung"]["fertigkeit_deckel"]) * bedarf(int(h["stufe"])) - 0.0001
