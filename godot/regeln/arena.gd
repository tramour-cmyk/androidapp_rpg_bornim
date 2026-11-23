# 1589.2 (DESIGN-GEGNER.md 1–3, 6; 1589.1 A, Chef 17.11., 22:33): Stufe 1 der Arena, unsichtbar. Jede Figur hat einen Punkt in Metern
# (a längs zum Gegner, b quer, wie kampfort.gd _ground), einen Umriss als Kreis und eine Reichweite; Abstand (nah, fern, weit),
# Versperren, Ziel je Denkweise mit Trägheit, Rollenwechsel, Flucht und die Ungunst der Fernwaffe im Nahkampf werden hier
# entschieden, nie im Bild. Bis Stufe 3 (Figuren in der Arena) sind die Punkte die heutigen Stellplätze; Zahlen aus werte.json „arena“.
# Vorbild (1589.2 Systemfrage): Trägheit als Schwelle für den Wechsel wie der „sticky bonus“ (strayspark.studio, „AI threat tables“,
# 31.08.2026) und US-Patent 6443733 (neues Ziel erst 150 Punkte besser); Versperren wie D&D 5e SRD „Movement and Position“: durch
# den Raum eines feindlichen Wesens geht kein Weg, durch Verbündete schon; Schüsse gehen über Wesen hinweg (dort nur Deckung).
extends RefCounted

const Brs = preload("res://regeln/brs.gd")

## Stellplätze wie kampfort.gd _stand (der Test arena_15892 hält beide gleich)
const FRONT_M := 1.4
const BACK_M := 2.9
const HALF_M := 0.9
const FOE_HALF_M := 1.2
const NEAR_M := 1.0
const ALONE_HERO_B := 0.35
const FOE_LEFT_BACK_M := 0.55
const FOE_LEFT_OUT_M := 0.45
const GLEICH := 0.001     # Rechengenauigkeit, keine Spielzahl

const GOBLINS := ["Goblin", "Kobold"]     # Gruppe aus werte.json „kennungen“
const GRAK := "hobgoblin_captain"
const RATTE := "giant_rat"


static func w() -> Dictionary:
	var a = Brs.lade().get("arena", {})
	return a if a is Dictionary else {}


static func _art(f) -> Dictionary:
	return {} if f == null or f.monster == null else Brs.monster(String(f.monster.get("id", "")))


## Denkweise der Art (Instinkt, List, Stur, Plan); Gruppe: ""
static func denkweise(f) -> String:
	return String(_art(f).get("denkweise", ""))


static func rollen(f) -> Array:
	var r = _art(f).get("rolle", [])
	return r if r is Array else []


## Punkt in Metern: gesetzt (mars.arena_punkte, ab Stufe 3 die Wege) oder der Stellplatz seines Platzes
static func punkt(mars, f) -> Vector2:
	var p = mars.arena_punkte.get(f.id, null)
	if p != null:
		return p
	var foe: bool = f.side == "FOES"
	var back: bool = f.place.x == 1
	var allein: bool = mars.all.filter(func(x): return x.side == f.side and x.standing() and x.place.x == f.place.x).size() <= 1
	var row := BACK_M if back else FRONT_M
	if not foe and back and not allein:
		return Vector2(-row - NEAR_M + 0.6, 0.6 + (-0.7 if f.place.y == 0 else 0.7))
	var half := FOE_HALF_M if foe else HALF_M
	var b := (0.0 if foe else ALONE_HERO_B) if allein else (-half if f.place.y == 0 else half)
	if foe and not back and not allein and f.place.y == 0:
		row += FOE_LEFT_BACK_M
		b -= FOE_LEFT_OUT_M
	return Vector2(row, b) if foe else Vector2(-row - NEAR_M, b)


static func umriss(f) -> float:
	if f.monster != null and bool(Brs.kennung(String(f.monster.get("koerper", f.monster.get("id", "")))).get("vierbeiner", false)):
		return float(w().get("umriss_vierbeiner", 0.45))
	return float(w().get("umriss_mensch", 0.3))


## Reichweite des eigenen Nahangriffs vor dem eigenen Rand; Gegner ohne Zahl mit Quelle: 0 (Frage 1589.2)
static func reichweite_nah(f) -> float:
	return float(w().get("reichweite_mensch", 0.75)) if f.side == "PARTY" else 0.0


static func luecke(mars, f, t) -> float:
	return punkt(mars, f).distance_to(punkt(mars, t)) - umriss(f) - umriss(t)


## Abschnitt 1: nah, wer die eigene Reichweite erreicht oder in der des anderen steht; fern bis zur Schussweite; weit darüber.
## [schussweite] < 0: aus werte.json (null: keiner ist weit)
static func abstand(mars, f, t, schussweite := -1.0) -> String:
	var l := luecke(mars, f, t)
	if l <= maxf(reichweite_nah(f), reichweite_nah(t)) + GLEICH:
		return "nah"
	var s = schussweite if schussweite >= 0.0 else w().get("schussweite", null)
	return "weit" if s != null and l > float(s) else "fern"


## Versperren (Abschnitt 3, Strecken-Kreis-Prüfung): der Weg von [f] zu [t] ist frei, wenn kein anderer Stehender auf der Seite von
## [t] mit seinem Umriss näher als beide Umrisse an der Strecke steht
static func frei(mars, f, t) -> bool:
	var a := punkt(mars, f)
	var b := punkt(mars, t)
	for x in mars.all:
		if x == f or x == t or x.side != t.side or not x.standing():
			continue
		var c := punkt(mars, x)
		if c.distance_to(Geometry2D.get_closest_point_to_segment(c, a, b)) < umriss(x) + umriss(f) - GLEICH:
			return false
	return true


## wen [f] erreicht: Schützen alle (Schüsse gehen über Wesen hinweg), sonst wer frei steht; leer nie, solange einer steht
static func erreichbar(mars, f) -> Array:
	var alle: Array = mars.feinde(f)
	if f.ranged():
		return alle
	var r := alle.filter(func(t): return frei(mars, f, t))
	return r if not r.is_empty() else alle


static func _naechster(mars, f, unter: Array):
	var best = null
	for t in unter:
		if best == null or luecke(mars, f, t) < luecke(mars, f, best) - GLEICH:
			best = t
	return best


static func _wunde(t) -> float:
	return float(t.hp) / maxf(float(t.max_hp), 1.0)


## Abschnitt 3: das Ziel von [f] zu Beginn seines Zugs; [vorher] die Kennung des bisherigen Ziels (Trägheit). Plan: null (die
## Reihenfolge des Bosses bleibt bis 1589.5 die heutige Wahl in mars.gd)
static func ziel(mars, f, vorher := ""):
	var dw := denkweise(f)
	if dw == "" or dw == "Plan":
		return null
	var reach := erreichbar(mars, f)
	if reach.is_empty():
		return null
	var neu = null
	match dw:
		"Instinkt":
			# „bei gleichem Abstand“ wörtlich (nur Rechengenauigkeit); eine Spanne für „gleich“ hat keine Quelle (Frage 1589.2)
			var n = _naechster(mars, f, reach)
			var gleich := reach.filter(func(t): return luecke(mars, f, t) < luecke(mars, f, n) + GLEICH)
			neu = n
			for t in gleich:
				if _wunde(t) < _wunde(neu) - GLEICH:
					neu = t
		"List":
			var want = null
			for t in mars.feinde(f):     # der Schwächste; bei gleichem Leben der weiter hinten
				if want == null or t.hp < want.hp or (t.hp == want.hp and luecke(mars, f, t) > luecke(mars, f, want)):
					want = t
			neu = want if want in reach else _naechster(mars, f, reach)
		_:
			neu = _naechster(mars, f, reach)
	var alt = null
	for t in reach:
		if t.id == vorher:
			alt = t
	if alt == null or alt == neu or _deutlich_besser(mars, f, dw, neu, alt):
		return neu
	return alt


static func _deutlich_besser(mars, f, dw: String, neu, alt) -> bool:
	if luecke(mars, f, neu) <= luecke(mars, f, alt) - float(w().get("traegheit_m", 1.0)) + GLEICH:
		return true
	if dw == "List":
		return float(neu.hp) <= float(alt.hp) * (1.0 - float(w().get("traegheit_leben", 0.25))) + GLEICH
	return false


## Abschnitt 4 Rollenwechsel: wer zwei Rollen hat, nimmt die zweite, sobald sein Ziel nah ist oder im Netz hängt; mit „rudel_ab“
## (Riesenratte, Tabelle 9 „Nahkampf, zu dritt Rudel“) nach der Zahl seiner Art, die steht
static func rolle_jetzt(mars, f, t) -> String:
	var r := rollen(f)
	if r.is_empty():
		return ""
	var ab := int(_art(f).get("rudel_ab", 0))
	if ab > 0 and r.size() > 1:
		var id := String(f.monster.get("id", ""))
		var art: Array = mars.all.filter(func(x): return x.side == f.side and x.standing() and x.monster != null and String(x.monster.get("id", "")) == id)
		return String(r[1]) if art.size() >= ab else String(r[0])
	if r.size() > 1 and t != null and (t.held or abstand(mars, f, t) == "nah"):
		return String(r[1])
	return String(r[0])


## 1a: Ungunst (Punkte) für [f], der mit einer Fernwaffe ([fern_waffe]) auf [t] schießt, während ein Gegner nah steht
static func ungunst(mars, f, t, fern_waffe: bool) -> int:
	if not fern_waffe:
		return 0
	for x in mars.feinde(f) + [t]:
		if x.standing() and abstand(mars, f, x) == "nah":
			return int(w().get("fern_nah_ungunst", -25))
	return 0


## Abschnitt 6: warum [f] jetzt flieht („rudel“, „grak“, „allein“, „ratte“) oder ""; Untote, Säureschnecke, Bosse nie
static func flucht_grund(mars, f) -> String:
	if f.side != "FOES" or not f.standing() or f.monster == null or denkweise(f) in ["Stur", "Plan", ""] or f.boss():
		return ""
	var W := w()
	var id := String(f.monster.get("id", ""))
	var gegner: Array = mars.all.filter(func(x): return x.side == "FOES")
	if f.follows != "":
		var leit = mars.find(f.follows)
		if leit != null and leit.hp <= 0:
			var rudel: Array = gegner.filter(func(x): return x == leit or x.follows == f.follows)
			var besiegt := rudel.filter(func(x): return x.hp <= 0).size()
			if float(besiegt) >= float(rudel.size()) * float(W.get("rudel_besiegt", 0.5)) - GLEICH:
				return "rudel"
	var gruppe := String(Brs.kennung(id).get("gruppe", ""))
	if gruppe == "Goblin" and gegner.any(func(x): return x.monster != null and String(x.monster.get("id", "")) == GRAK and x.hp <= 0):
		return "grak"
	var stehen: Array = gegner.filter(func(x): return x.standing())
	if gruppe in GOBLINS and stehen.size() == 1 and float(f.hp) < float(f.max_hp) * float(W.get("allein_leben", 0.25)) - GLEICH:
		return "allein"
	if id == RATTE and f.hp < f.max_hp and not stehen.any(func(x): return x != f and x.monster != null and String(x.monster.get("id", "")) == RATTE):
		return "ratte"
	return ""
