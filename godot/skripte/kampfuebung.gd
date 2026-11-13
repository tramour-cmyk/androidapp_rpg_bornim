class_name Kampfuebung
extends RefCounted
# 471 (Chef 09.11., 20:54: „471 A“): Fertigkeiten steigen durch Tun, im Kampf. Hoert die Meldungen des MARS mit (mars.listener, wie der
# Kampfort) und zaehlt, welche Fertigkeit der Held benutzt hat, wie die Simulation 444 (tools/sim444/sim.py kampf: Treffer mit der
# Waffe uebt die Waffe, Treffer mit einem Zauber dessen Schule, ein Treffer auf den Helden Ruestung und Schild, ein Fehlschlag gegen ihn
# seine Abwehr). Gutgeschrieben wird erst am Kampfende und nur nach einem Sieg (Votum 471 A: Rundenablauf unberuehrt), danach die
# Bewaehrungsprobe (BrsFertigkeit.nach_sieg). Uebung je Schlag sichtbar im Kampf uebernimmt Jerry nach t272.

const BrsKampf = preload("res://regeln/brs_kampf.gd")

## Zauber des MARS (mars.FX) -> Schule des BRS
const SCHULE := {"FIRE_BOLT": "Evokation", "MISSILES": "Evokation", "RAYS": "Evokation", "FIREBALL": "Evokation",
	"BURNING_HANDS": "Evokation", "SACRED_FLAME": "Evokation", "HEAL": "Heilmagie", "BLESS": "Schutzmagie"}

var zaehler := {}     # "Fertigkeit|Gegnerstufe" -> Benutzungen
var gegner_hoechst := 0

## Eine Meldung (mars._say) mit dem, was in dem Augenblick gilt; [mars] fuer Kaempfer und Waffe in der Hand, [daten] der Held nach BRS
func hoere(e: Dictionary, mars, daten := {}) -> void:
	var held = mars.find("hero")
	if held == null: return
	var b: Dictionary = held.b if not (held.b as Dictionary).is_empty() else BrsKampf.held(held.hero, daten)
	for f in mars.all:
		if f.side == "FOES" and f.monster != null: gegner_hoechst = maxi(gegner_hoechst, stufe_von(f))
	var ziel = mars.find(str(e.get("target", ""))) if e.get("target") != null else null
	var wer = mars.find(str(e.get("actor", ""))) if e.get("actor") != null else null
	var wt = held.weapon()
	var lage := {"waffe": BrsKampf.waffe_von(wt if wt != null else held.hero.main), "in_hand": not held.drawn,
		"art": str(wer.b.get("art", "fern" if wer.ranged() else "nah")) if wer != null and wer.monster != null else "nah",
		"heiler": str(held.hero.get("cls", "")) == "CLERIC", "feind": wer != null and wer.side == "FOES"}
	var gs := stufe_von(ziel) if wer == held else (stufe_von(wer) if wer != null else 0)
	for f in benutzt(e, b, lage):
		var k := "%s|%d" % [f, gs]
		zaehler[k] = int(zaehler.get(k, 0)) + 1

static func stufe_von(f) -> int:
	if f == null or f.monster == null: return 0
	var s := Brs.stufe(str(f.monster.id))
	return s if s > 0 else int(f.monster.get("level", 1))

## Welche Fertigkeiten eine Meldung uebt (ohne Kaempfer, fuer den Test): [b] BrsKampf.held, [lage] {waffe, in_hand, art, heiler, feind}
static func benutzt(e: Dictionary, b: Dictionary, lage: Dictionary) -> Array:
	var roll = e.get("roll")
	var wurf: bool = roll is Array and (roll as Array).size() > 4 and str(roll[0]) in ["ATTACK", "BRS"]
	var schaden := int(e.get("damage", 0))
	var spell = e.get("spell")
	if str(e.get("cue")) == "INTIMIDATE":     # 841: den Späher verjagen, gelungen oder nicht (Mars._einschuechtern)
		return ["Einschüchtern"] if e.get("actor") == "hero" else []
	if str(e.get("cue")) == "HEAL":
		return ["Heilmagie"] if e.get("actor") == "hero" and bool(lage.get("heiler", false)) and spell == "HEAL" else []
	if e.get("actor") == "hero" and e.get("target") != null and e.get("target") != "hero":
		if not (schaden > 0 or (wurf and bool(roll[4]))): return []
		if spell != null: return [SCHULE[spell]] if SCHULE.has(spell) else []
		return [str(lage["waffe"])]
	if e.get("target") == "hero" and bool(lage.get("feind", false)):
		if schaden > 0:
			var r := []
			var rs = BrsKampf.w()["ruestungen"].get(str(b.get("ruestung", "keine")), {}).get("fertigkeit")
			if rs != null: r.append(str(rs))
			if bool(b.get("schild", false)) and bool(lage["in_hand"]): r.append("Schild")
			return r
		if wurf:
			return [str(BrsKampf.held_abwehr(b, str(lage["art"]), str(lage["waffe"]), bool(lage["in_hand"]))[0])]
	return []

## Am Kampfende: [ende] „WON“ schreibt die Uebung gut und prueft die Bewaehrung. [s] BrsFertigkeit-Stand, [h] Brs-Stand (Heldenstufe).
## Ereignisse wie BrsFertigkeit.uebe.
func gutschreiben(ende: String, s: Dictionary, h: Dictionary) -> Array:
	var ev := []
	if ende != "WON": return ev
	var namen := []
	var keys := zaehler.keys()
	keys.sort()
	for k in keys:
		var t := str(k).split("|")
		for i in int(zaehler[k]):
			ev.append_array(BrsFertigkeit.uebe(s, h, t[0], int(t[1])))
		if not namen.has(t[0]): namen.append(t[0])
	ev.append_array(BrsFertigkeit.nach_sieg(s, h, namen, gegner_hoechst))
	return ev

## Die kurze Notiz nach dem Kampf: je gestiegene Fertigkeit „Bogen ↑ 12“, in der Reihenfolge des Steigens
static func notiz(ev: Array) -> String:
	var hoch := {}
	var folge := []
	for e in ev:
		if str(e["art"]) != "auf": continue
		var f := str(e["fert"])
		if not folge.has(f): folge.append(f)
		hoch[f] = int(e["wert"])
	return "  ·  ".join(folge.map(func(f): return "%s ↑ %d" % [ErschaffungBrs.fert_name(f), hoch[f]]))
