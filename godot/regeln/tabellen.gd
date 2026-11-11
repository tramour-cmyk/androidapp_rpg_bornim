class_name Tabellen
extends RefCounted
# 870.6 (LISTE-UMZUG-BRS.md Schritt 3, Sokrates 20:05: „tabellen.json löschen gehört in 870.6“): was regeln/tabellen.json (SRD, aus
# Monsters.kt) dem Kampf lieferte, jetzt aus dem BRS. Gleiche Form wie bisher, damit MARS, Aufruf, Probe und Tests sie lesen wie
# vorher: {monsters: [...], items: [...], skills: [], probe: {...}}.
# - monsters: je Kennung aus werte.json „kennungen“ (Name nach DESIGN-BRS.md 12), „monster“ (Leben, Boss) und „monsterregeln“
#   (Sonderregel, Schadensart des Angriffs, Gift, immun, Gold, Beute); keine Würfel des SRD mehr: „hp“ ist das Leben nach BRS als
#   fester Ausdruck [0, 0, Leben], „gold“ der gleichverteilte Wurf von min bis max.
# - items: die Dinge mit Namen aus daten/texte.json (Sprache, mit Homers Namen 870.15); Heilung steht in werte.json „welt“ „heilung“;
#   was im Kampf geht, sagt werte.json „kampftasche“ (532, 935: kind, cures, brs).
# - skills: leer; die Kampfhandlungen und Zauber nach BRS legt MARS selbst an (mars.gd _brs_handlungen).
# - probe: Probehelden je alter Klasse (Probekampf des Testmenüs, kampf/probe.gd, Tests) als Held nach BRS der passenden Herkunft
#   (BrsKampf.KLASSE_HERKUNFT), Heldenstufe 3, mit Ausrüstung der Herkunft.

const TYP := {"stich": "PIERCING", "schnitt": "SLASHING", "wucht": "BLUDGEONING"}
const PROBE_STUFE := 3
const PROBE_NAMEN := {"FIGHTER": ["Ansgar", "Brakka"], "WIZARD": ["Elric", "Mira"], "ROGUE": ["Vex", "Tamsin"], "CLERIC": ["Osgar", "Hilde"]}

static var _t := {}

static func lade() -> Dictionary:
	if _t.is_empty():
		_t = {"monsters": monsters(), "items": items(), "skills": [], "probe": {}}
	var r: Dictionary = _t.duplicate(true)
	r["probe"] = probe()
	return r

static func monsters() -> Array:
	var W := Brs.lade()
	var out: Array = []
	var mr: Dictionary = W.get("monsterregeln", {})
	var wb: Dictionary = W.get("wirtschaft", {}).get("beute", {})
	for id in BrsHeld.ohne_info(W.get("kennungen", {})):
		var k := Brs.kennung(String(id))
		var b := Brs.monster(String(id))
		var r: Dictionary = mr.get(id, {})
		var g: Array = wb.get(String(k.get("art", "")), {}).get("gold", r.get("gold", [0, 0]))
		out.append({"id": String(id), "de": String(k.get("de", id)), "en": String(k.get("en", id)), "hp": [0, 0, int(b.get("leben", 1))],
			"boss": bool(b.get("boss", false)), "special": String(r.get("sonder", "NONE")), "type": String(TYP.get(String(r.get("typ", "stich")), "PIERCING")),
			"gift": float(r.get("gift", 1.0)), "immune": (r.get("immun", []) as Array).duplicate(),
			"gold": [1, maxi(1, int(g[1]) - int(g[0]) + 1), int(g[0]) - 1] if int(g[1]) > 0 else [0, 0, 0],
			"loot": (r.get("beute", []) as Array).map(func(e): return {"item": String(e[0]), "chance": float(e[1])})})
	return out

static func items() -> Array:
	Sprache.lade()
	var out: Array = []
	var d: Dictionary = Sprache.texte.get("dinge", {})
	for id in d:
		var n = d[id].get("name", {})
		var it := {"id": String(id), "de": String(n.get("de", id)) if n is Dictionary else String(id), "en": String(n.get("en", id)) if n is Dictionary else String(id)}
		# 532, 935: was man im Kampf trinkt oder wirft (werte.json „kampftasche“): kind POTION, BOMB; cures; brs = Eintrag in „kampftraenke“
		var kt: Dictionary = Brs.lade().get("kampftasche", {})
		if String(id) in kt.get("trinken", []):
			it["kind"] = "POTION"
			it["cures"] = String(id) in kt.get("heilt_zustaende", [])
		elif kt.get("werfen", {}).has(String(id)):
			it["kind"] = "BOMB"
			it["brs"] = String(kt.werfen[String(id)])
		out.append(it)
	return out

## Probehelden je alter Klasse: {"hero": {hp, hero: Blatt}, "merc": {...}} wie früher tabellen.json „probe“
static func probe() -> Dictionary:
	var Aufruf = load("res://kampf/aufruf.gd")
	var KLASSE_HERKUNFT: Dictionary = load("res://regeln/brs_kampf.gd").KLASSE_HERKUNFT
	var out := {}
	for kl in KLASSE_HERKUNFT:
		var paar := {}
		for i in 2:
			var h := BrsHeld.fuer_spiel(String(PROBE_NAMEN[kl][i]), "Mensch", String(KLASSE_HERKUNFT[kl]))
			h.stufe = PROBE_STUFE
			h.voll()
			var blatt: Dictionary = Aufruf.blatt(h, Aufruf.ersatzwaffe(h))
			# wie die Probeblätter vorher: ohne Kampfblatt „brs“, so rechnet BrsKampf.held nach der Herkunft der Klasse mit den Werten
			# der Simulation 444 (brs_kampf_478, handlungen_870); Mana voll, Volk über „race“ (Tests setzen es um)
			blatt.erase("brs")
			blatt["cls"] = kl     # Figur und Tracht der Probeblätter (figur.gd 870.4)
			blatt["sp"] = 0
			blatt["sp_max"] = 0
			paar["hero" if i == 0 else "merc"] = {"id": "hero" if i == 0 else "merc", "hp": h.max_leben(), "hero": blatt}
		out[kl] = paar
	return out
