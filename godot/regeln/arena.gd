# 1589.2 (DESIGN-GEGNER.md 1–3, 6; 1589.1 A, Chef 17.11., 22:33): Stufe 1 der Arena, unsichtbar. Jede Figur hat einen Punkt in Metern
# (a längs zum Gegner, b quer, wie kampfort.gd _ground), einen Umriss als Kreis und eine Reichweite; Abstand (nah, fern, weit),
# Versperren, Ziel je Denkweise mit Trägheit, Rollenwechsel, Flucht und die Ungunst der Fernwaffe im Nahkampf werden hier
# entschieden, nie im Bild. Bis Stufe 3 (Figuren in der Arena) sind die Punkte die heutigen Stellplätze; Zahlen aus werte.json „arena“.
# Vorbild (1589.2 Systemfrage): Trägheit als Schwelle für den Wechsel wie der „sticky bonus“ (strayspark.studio, „AI threat tables“,
# 31.08.2026) und US-Patent 6443733 (neues Ziel erst 150 Punkte besser); Versperren wie D&D 5e SRD „Movement and Position“: durch
# den Raum eines feindlichen Wesens geht kein Weg, durch Verbündete schon; Schüsse gehen über Wesen hinweg (dort nur Deckung).
extends RefCounted

const Brs = preload("res://regeln/brs.gd")
const Mars = preload("res://regeln/mars.gd")

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
	var a: Variant = Brs.lade().get("arena", {})
	return a if a is Dictionary else {}


static func _art(f: Mars.Fighter) -> Dictionary:
	return {} if f == null or f.monster == null else Brs.monster(String(f.monster.get("id", "")))


## Denkweise der Art (Instinkt, List, Stur, Plan); Gruppe: ""
static func denkweise(f: Mars.Fighter) -> String:
	return String(_art(f).get("denkweise", ""))


static func rollen(f: Mars.Fighter) -> Array:
	var r: Variant = _art(f).get("rolle", [])
	return r if r is Array else []


## Punkt in Metern: gesetzt (mars.arena_punkte, ab Stufe 3 die Wege) oder der Stellplatz seines Platzes
static func punkt(mars: Mars, f: Mars.Fighter) -> Vector2:
	var p: Variant = mars.arena_punkte.get(f.id, null)
	if p != null:
		return p
	var foe: bool = f.side == "FOES"
	var back: bool = f.place.x == 1
	var allein: bool = mars.all.filter(func(x: Mars.Fighter) -> bool: return x.side == f.side and x.standing() and x.place.x == f.place.x).size() <= 1
	var row := BACK_M if back else FRONT_M
	if not foe and back and not allein:
		return Vector2(-row - NEAR_M + 0.6, 0.6 + (-0.7 if f.place.y == 0 else 0.7))
	var half := FOE_HALF_M if foe else HALF_M
	var b := (0.0 if foe else ALONE_HERO_B) if allein else (-half if f.place.y == 0 else half)
	if foe and not back and not allein and f.place.y == 0:
		row += FOE_LEFT_BACK_M
		b -= FOE_LEFT_OUT_M
	return Vector2(row, b) if foe else Vector2(-row - NEAR_M, b)


static func umriss(f: Mars.Fighter) -> float:
	if f.monster != null and bool(Brs.kennung(String(f.monster.get("koerper", f.monster.get("id", "")))).get("vierbeiner", false)):
		return float(w().get("umriss_vierbeiner", 0.45))
	return float(w().get("umriss_mensch", 0.3))


## Reichweite des eigenen Nahangriffs vor dem eigenen Rand; Gegner ohne Zahl mit Quelle: 0 (Frage 1589.2)
static func reichweite_nah(f: Mars.Fighter) -> float:
	return float(w().get("reichweite_mensch", 0.75)) if f.side == "PARTY" else 0.0


static func luecke(mars: Mars, f: Mars.Fighter, t: Mars.Fighter) -> float:
	return punkt(mars, f).distance_to(punkt(mars, t)) - umriss(f) - umriss(t)


## Abschnitt 1: nah, wer die eigene Reichweite erreicht oder in der des anderen steht; fern bis zur Schussweite; weit darüber.
## [schussweite] < 0: aus werte.json (null: keiner ist weit)
static func abstand(mars: Mars, f: Mars.Fighter, t: Mars.Fighter, schussweite := -1.0) -> String:
	var l := luecke(mars, f, t)
	if l <= maxf(reichweite_nah(f), reichweite_nah(t)) + GLEICH:
		return "nah"
	var s: Variant = schussweite if schussweite >= 0.0 else w().get("schussweite", null)
	return "weit" if s != null and l > float(s) else "fern"


## Versperren (Abschnitt 3, Strecken-Kreis-Prüfung): der Weg von [f] zu [t] ist frei, wenn kein anderer Stehender auf der Seite von
## [t] mit seinem Umriss näher als beide Umrisse an der Strecke steht
static func frei(mars: Mars, f: Mars.Fighter, t: Mars.Fighter) -> bool:
	var a := punkt(mars, f)
	var b := punkt(mars, t)
	for x: Mars.Fighter in mars.all:
		if x == f or x == t or x.side != t.side or not x.standing():
			continue
		var c := punkt(mars, x)
		if c.distance_to(Geometry2D.get_closest_point_to_segment(c, a, b)) < umriss(x) + umriss(f) - GLEICH:
			return false
	return true


## wen [f] erreicht: Schützen alle (Schüsse gehen über Wesen hinweg), sonst wer frei steht; leer nie, solange einer steht
static func erreichbar(mars: Mars, f: Mars.Fighter) -> Array:
	var alle: Array = mars.feinde(f)
	if f.ranged():
		return alle
	var r := alle.filter(func(t: Mars.Fighter) -> bool: return frei(mars, f, t))
	return r if not r.is_empty() else alle


static func _naechster(mars: Mars, f: Mars.Fighter, unter: Array) -> Mars.Fighter:
	var best: Mars.Fighter = null
	for t: Mars.Fighter in unter:
		if best == null or luecke(mars, f, t) < luecke(mars, f, best) - GLEICH:
			best = t
	return best


static func _wunde(t: Mars.Fighter) -> float:
	return float(t.hp) / maxf(float(t.max_hp), 1.0)


## Abschnitt 3: das Ziel von [f] zu Beginn seines Zugs; [vorher] die Kennung des bisherigen Ziels (Trägheit). Plan: null (die
## Reihenfolge des Bosses bleibt bis 1589.5 die heutige Wahl in mars.gd)
static func ziel(mars: Mars, f: Mars.Fighter, vorher := "") -> Mars.Fighter:
	var dw := denkweise(f)
	if dw == "" or dw == "Plan":
		return null
	var reach := erreichbar(mars, f)
	if reach.is_empty():
		return null
	var neu: Mars.Fighter = null
	match dw:
		"Instinkt":
			# „bei gleichem Abstand“ wörtlich (nur Rechengenauigkeit); eine Spanne für „gleich“ hat keine Quelle (Frage 1589.2)
			var n: Mars.Fighter = _naechster(mars, f, reach)
			var gleich := reach.filter(func(t: Mars.Fighter) -> bool: return luecke(mars, f, t) < luecke(mars, f, n) + GLEICH)
			neu = n
			for t: Mars.Fighter in gleich:
				if _wunde(t) < _wunde(neu) - GLEICH:
					neu = t
		"List":
			var want: Mars.Fighter = null
			for t: Mars.Fighter in mars.feinde(f):     # der Schwächste; bei gleichem Leben der weiter hinten
				if want == null or t.hp < want.hp or (t.hp == want.hp and luecke(mars, f, t) > luecke(mars, f, want)):
					want = t
			neu = want if want in reach else _naechster(mars, f, reach)
		_:
			neu = _naechster(mars, f, reach)
	var alt: Mars.Fighter = null
	for t: Mars.Fighter in reach:
		if t.id == vorher:
			alt = t
	if alt == null or alt == neu or _deutlich_besser(mars, f, dw, neu, alt):
		return neu
	return alt


static func _deutlich_besser(mars: Mars, f: Mars.Fighter, dw: String, neu: Mars.Fighter, alt: Mars.Fighter) -> bool:
	if luecke(mars, f, neu) <= luecke(mars, f, alt) - float(w().get("traegheit_m", 1.0)) + GLEICH:
		return true
	if dw == "List":
		return float(neu.hp) <= float(alt.hp) * (1.0 - float(w().get("traegheit_leben", 0.25))) + GLEICH
	return false


## Abschnitt 4 Rollenwechsel: wer zwei Rollen hat, nimmt die zweite, sobald sein Ziel nah ist oder im Netz hängt; mit „rudel_ab“
## (Riesenratte, Tabelle 9 „Nahkampf, zu dritt Rudel“) nach der Zahl seiner Art, die steht
static func rolle_jetzt(mars: Mars, f: Mars.Fighter, t: Mars.Fighter) -> String:
	var r := rollen(f)
	if r.is_empty():
		return ""
	var ab := int(_art(f).get("rudel_ab", 0))
	if ab > 0 and r.size() > 1:
		var id := String(f.monster.get("id", ""))
		var art: Array = mars.all.filter(func(x: Mars.Fighter) -> bool: return x.side == f.side and x.standing() and x.monster != null and String(x.monster.get("id", "")) == id)
		return String(r[1]) if art.size() >= ab else String(r[0])
	if r.size() > 1 and t != null and (t.held or abstand(mars, f, t) == "nah"):
		return String(r[1])
	return String(r[0])


## 1a: Ungunst (Punkte) für [f], der mit einer Fernwaffe ([fern_waffe]) auf [t] schießt, während ein Gegner nah steht
static func ungunst(mars: Mars, f: Mars.Fighter, t: Mars.Fighter, fern_waffe: bool) -> int:
	if not fern_waffe:
		return 0
	for x: Mars.Fighter in mars.feinde(f) + [t]:
		if x.standing() and abstand(mars, f, x) == "nah":
			return int(w().get("fern_nah_ungunst", -25))
	return 0


## Abschnitt 6: warum [f] jetzt flieht („rudel“, „grak“, „allein“, „ratte“) oder ""; Untote, Säureschnecke, Bosse nie
static func flucht_grund(mars: Mars, f: Mars.Fighter) -> String:
	if f.side != "FOES" or not f.standing() or f.monster == null or denkweise(f) in ["Stur", "Plan", ""] or f.boss():
		return ""
	var W := w()
	var id := String(f.monster.get("id", ""))
	var gegner: Array = mars.all.filter(func(x: Mars.Fighter) -> bool: return x.side == "FOES")
	if f.follows != "":
		var leit: Mars.Fighter = mars.find(f.follows)
		if leit != null and leit.hp <= 0:
			var rudel: Array = gegner.filter(func(x: Mars.Fighter) -> bool: return x == leit or x.follows == f.follows)
			var besiegt := rudel.filter(func(x: Mars.Fighter) -> bool: return x.hp <= 0).size()
			if float(besiegt) >= float(rudel.size()) * float(W.get("rudel_besiegt", 0.5)) - GLEICH:
				return "rudel"
	var gruppe := String(Brs.kennung(id).get("gruppe", ""))
	if gruppe == "Goblin" and gegner.any(func(x: Mars.Fighter) -> bool: return x.monster != null and String(x.monster.get("id", "")) == GRAK and x.hp <= 0):
		return "grak"
	var stehen: Array = gegner.filter(func(x: Mars.Fighter) -> bool: return x.standing())
	if gruppe in GOBLINS and stehen.size() == 1 and float(f.hp) < float(f.max_hp) * float(W.get("allein_leben", 0.25)) - GLEICH:
		return "allein"
	if id == RATTE and f.hp < f.max_hp and not stehen.any(func(x: Mars.Fighter) -> bool: return x != f and x.monster != null and String(x.monster.get("id", "")) == RATTE):
		return "ratte"
	return ""


# ---------------------------------------------------------------------------------------------------------------------------------
# 1589.4 Stufe 3 (DESIGN-GEGNER.md 5, 11.3; Antworten Sokrates 24.11., 19:10, F1–F5): die Wege der Figuren. figur.gd fragt hier
# und spielt nur ab. Rechnet in Metern am Boden (x, z der Welt oder a, b der Arena: beides ist eine Drehung, Abstände bleiben).
# Systemfrage (Entwurf 1589.4-wegregeln.md): gerade Strecke Punkt zu Punkt, geprüft wie Versperren (Strecken-Kreis); ist sie
# versperrt, wird nicht umgangen, sondern gewartet oder der Vordere macht Platz (F1; Reynolds GDC 1999 nur bei Umweg, den es nicht gibt).

const QUER_GRAD := 45.0      # F2: beim Gehen liegen Weg und Blick höchstens so weit auseinander (außer dem einzelnen Seitschritt, F4)
const SCHRAEG_GRAD := 35.0   # F3: schräg rückwärts absetzen (Annahme, Chef am Film)
## Abschnitt 5 Ausnahmen (Homer): Untote (Skelett, Wiedergänger, Grabhund) und Krogg setzen sich nicht ab
const STUR := ["skeleton", "zombie", "ghoul", Mars.KROGG]


## setzt sich die Art [id] nach dem Angriff ab?
static func setzt_ab(id: String) -> bool:
	return not id in STUR


## 1589.4 (Chef 25.11., 09:55: „der Umriss jeder Figur folgt ihrer Form“): Umriss als Kapsel [p, q, r] am Boden: Strecke p–q,
## Halbmesser r; ein Kreis ist eine Kapsel mit p = q. Abstand zweier Kapseln = Abstand Strecke zu Strecke minus beide Halbmesser
## (Ericson, Real-Time Collision Detection, 2005, 4.5 und 5.1.9; Godot CapsuleShape2D). Ein Weg ist eine Kapsel entlang der Strecke.
## Aus dem Kasten am Boden [groesse] (lange und kurze Seite): r = halbe kurze Seite, Länge = lang − kurz, Achse [achse] längs der
## langen Seite
static func kapsel(mitte: Vector2, achse: Vector2, laenge: float, r: float) -> Array:
	var h := achse.normalized() * 0.5 * maxf(laenge, 0.0)
	return [mitte - h, mitte + h, r]


static func strecke_strecke(p1: Vector2, q1: Vector2, p2: Vector2, q2: Vector2) -> float:
	if Geometry2D.segment_intersects_segment(p1, q1, p2, q2) != null:
		return 0.0
	return minf(minf(p1.distance_to(Geometry2D.get_closest_point_to_segment(p1, p2, q2)),
			q1.distance_to(Geometry2D.get_closest_point_to_segment(q1, p2, q2))),
			minf(p2.distance_to(Geometry2D.get_closest_point_to_segment(p2, p1, q1)),
			q2.distance_to(Geometry2D.get_closest_point_to_segment(q2, p1, q1))))


## Abstand der Ränder zweier Kapseln (negativ: sie stecken ineinander)
static func kapsel_abstand(k1: Array, k2: Array) -> float:
	return strecke_strecke(k1[0], k1[1], k2[0], k2[1]) - float(k1[2]) - float(k2[2])


## Abstand des Punkts [c] zur Strecke der Kapsel [k] (liegt c im Umriss: kleiner als k[2])
static func punkt_kapsel(c: Vector2, k: Array) -> float:
	return c.distance_to(Geometry2D.get_closest_point_to_segment(c, k[0], k[1]))


## die Kapsel des Wegs [a] → [b] einer Figur mit [laenge] und [r]: sie geht längs (vorwärts oder rückwärts), ihre Strecke ragt
## an beiden Enden um die halbe Länge hinaus
static func weg_kapsel(a: Vector2, b: Vector2, laenge: float, r: float) -> Array:
	var d := (b - a).normalized() if a.distance_to(b) > GLEICH else Vector2.ZERO
	return [a - d * 0.5 * laenge, b + d * 0.5 * laenge, r]


## F1: ist der Weg [a] → [b] einer Figur mit Kapsel [laenge], [r] frei? [andere]: Kapseln [p, q, r] der anderen Stehenden
## Steckt sie am Start schon in einem anderen, sperrt der nur einen Weg, der ihm noch näher kommt (heraus darf sie immer).
## [ende]: ihre Kapsel am Ziel (oder mehrere: Bisshaltung, dann Ruhe), wie sie dort steht (die Kapsel dreht mit; leer: nicht geprüft); auch sie darf
## keinem näher kommen, als sie ihm am Start steht
static func strecke_frei(a: Vector2, b: Vector2, laenge: float, r: float, andere: Array, ende := []) -> bool:
	var weg := weg_kapsel(a, b, laenge, r)
	var start := weg_kapsel(a, a + (b - a) * GLEICH, laenge, r) if a.distance_to(b) > GLEICH else weg
	for x: Array in andere:
		var vorher := kapsel_abstand(start, x)
		var nah := kapsel_abstand(weg, x)
		if nah < -GLEICH and nah < vorher - GLEICH:
			return false
		for e: Array in kapseln(ende):
			var am_ziel := kapsel_abstand(e, x)
			if am_ziel < -GLEICH and am_ziel < vorher - GLEICH:
				return false
	return true


## eine Kapsel [p, q, r] oder eine Liste von Kapseln als Liste
static func kapseln(x: Array) -> Array:
	return [] if x.is_empty() else ([x] if x[0] is Vector2 else x)


## eine Kapsel [k] um [v] verschoben
static func schieb(k: Array, v: Vector2) -> Array:
	return [(k[0] as Vector2) + v, (k[1] as Vector2) + v, k[2]]


## Abschnitt 5: geht ein Gegner den Weg [weg] rückwärts? Ja, wenn er vom Feind ([zum_feind]) wegführt: dann das Gesicht zum Feind
## (nie der Rücken, F7); sonst auf der Stelle zum Weg drehen und vorwärts
static func rueckwaerts(weg: Vector2, zum_feind: Vector2) -> bool:
	return zum_feind != Vector2.ZERO and weg.dot(zum_feind) < 0.0


## Blick (Einheitsvektor) beim Gehen des Wegs [weg]: vorwärts in Wegrichtung, rückwärts entgegen; so liegt kein Weg quer zum Blick
static func blick_beim_gehen(weg: Vector2, rueck: bool) -> Vector2:
	var d := weg.normalized() if weg.length() > GLEICH else Vector2.ZERO
	return -d if rueck else d


## Abschnitt 5: wohin sich [id] nach dem Angriff absetzt: von [von] bis [weit] Meter gerade rückwärts vom Ziel ([ziel]) weg, sonst
## schräg rückwärts (±SCHRAEG_GRAD), sonst halb so weit; [frei] (Callable(Vector2) -> bool) prüft einen Punkt. Stur: bleibt.
## Kein Platz frei: bleibt stehen ([von])
static func absetzen(von: Vector2, ziel: Vector2, weit: float, id: String, frei: Callable) -> Vector2:
	if not setzt_ab(id) or weit <= GLEICH:
		return von
	var weg := (von - ziel).normalized() if von.distance_to(ziel) > GLEICH else Vector2.DOWN
	for k: float in [1.0, 0.5]:
		for w: float in [0.0, SCHRAEG_GRAD, -SCHRAEG_GRAD]:
			var p := von + weg.rotated(deg_to_rad(w)) * weit * k
			if frei.call(p):
				return p
	return von


## 1526 (Abschnitt 5, Sokrates 24.11., 21:50 (b)): wer vorn für einen hinteren Platz macht, weicht nur so weit, dass der Nachrücker
## vorbeikommt, nicht ganz nach hinten (alt: auf den Platz des Nachrückers, die hintere Reihe 5–7 m zurück, Runde 31 s): er bleibt, wo
## er steht ([steht]); kommt der Nachrücker, tritt er beiseite (beiseite, figur.gd _gasse)
static func platz_machen(steht: Vector2) -> Vector2:
	return steht


## geradewegs heran (Chef 18.11., 14:33, Ratte quer): ein Bissplatz liegt höchstens so weit um das Ziel herum (Grad); Flieger
## ([flieger]) bis FLIEGER_GRAD (Sokrates 25.11., 15:26 zu Ü21: flatternd, „beißt und löst sich“)
const FLIEGER_GRAD := 90.0
## [am_schild]: am Schild vorbei bis BISS_SCHILD_GRAD (F10, Chef 25.11., 17:02: kein Biss daneben; alt 709 bis 60°), der Weg bleibt geradewegs
const BISS_SCHILD_GRAD := 60.0
static func bissplatz_winkel(w: float, flieger := false, am_schild := false) -> bool:
	return absf(w) <= (FLIEGER_GRAD if flieger else (BISS_SCHILD_GRAD if am_schild else QUER_GRAD))


## Abschnitt 5 „der hintere wartet seitlich, bis der Weg frei ist“: Punkt einen Seitschritt quer zum Weg [von] → [nach], so weit,
## dass der Weg des Entgegenkommenden ([nach] → [von]) an ihm vorbeigeht (eigener Halbmesser [r] plus der Halbmesser des Kommenden,
## aus [andere]); links, sonst rechts, wo der Platz frei ist; sonst [von]. [laenge]: eigene Kapsel
static func seitlich(von: Vector2, nach: Vector2, laenge: float, r: float, andere: Array) -> Vector2:
	var w := nach - von
	if w.length() < GLEICH:
		return von
	var r2 := r
	for x: Array in andere:
		if punkt_kapsel(nach, x) < float(x[2]) + r:
			r2 = r + float(x[2])
	var quer := Vector2(-w.y, w.x).normalized()
	var start := kapsel(von, quer, laenge, r)
	for sg: float in [1.0, -1.0]:
		var p := von + quer * sg * r2
		if strecke_frei(von, p, laenge, r, andere.filter(func(x: Array) -> bool: return kapsel_abstand(start, x) >= -GLEICH)):
			return p
	return von


## F1 „der Vordere macht Platz“: wohin ein Stehender mit Kapsel [k] beiseite tritt, damit der Weg [a] → [b] (Kapsel [laenge_w],
## [r_w] des Gehenden) an ihm vorbeigeht: quer zur Strecke auf die Seite, auf der er schon steht, nur so weit, bis der Weg frei ist
## (Sokrates 24.11., 21:08: höchstens bis zum nächsten freien Platz; nie auf die andere Seite); sein eigener Weg frei gegen
## [andere] (strecke_frei, Länge [laenge], Halbmesser k[2]); gibt den Schritt zurück, sonst Null (der Gehende wartet).
## Untote und Krogg treten nicht beiseite ([id], Abschnitt 5: sie weichen nicht)
## [ende_bei] (Callable(Vector2) -> Array): seine Kapsel nach einem Schritt, zum Gegner gedreht (strecke_frei [ende])
static func beiseite(a: Vector2, b: Vector2, laenge_w: float, r_w: float, k: Array, laenge: float, andere: Array, id := "", ende_bei := Callable(), ziel_w := []) -> Vector2:
	var c: Vector2 = ((k[0] as Vector2) + (k[1] as Vector2)) * 0.5
	var w := b - a
	if w.length() < GLEICH or not setzt_ab(id):
		return Vector2.ZERO
	var quer := Vector2(-w.y, w.x).normalized()
	var ab := (c - Geometry2D.get_closest_point_to_segment(c, a, b)).dot(quer)
	var sg := 1.0 if ab >= 0.0 else -1.0
	var weg := weg_kapsel(a, b, laenge_w, r_w)
	# frei nach einem Schritt [x] quer: seine Kapsel (am neuen Platz zum Gegner gedreht, [ende_bei]) gegen den Weg des Gehenden und
	# gegen dessen Kapsel am Ziel ([ziel_w], z. B. in Bisshaltung)
	var frei := func(x: float) -> bool:
		var e: Array = ende_bei.call(quer * sg * x) if ende_bei.is_valid() else schieb(k, quer * sg * x)
		return kapsel_abstand(weg, e) >= 0.0 and kapseln(ziel_w).all(func(z: Array) -> bool: return kapsel_abstand(z, e) >= 0.0)
	# höchstens: der Rand der eigenen Strecke, der dem Weg am nächsten liegt, rückt bis Halbmesser beider vom Weg weg, plus beide Längen
	# (Drehen am neuen Platz, Kapsel am Ziel); nur so weit wie nötig (Halbierung)
	var innen := minf(((k[0] as Vector2) - a).dot(quer) * sg, ((k[1] as Vector2) - a).dot(quer) * sg)
	var hi := maxf(0.0, r_w + float(k[2]) + GLEICH - innen) + laenge_w + laenge
	if not frei.call(hi):
		return Vector2.ZERO
	var lo := 0.0
	for i in 14:
		var m := 0.5 * (lo + hi)
		if frei.call(m):
			hi = m
		else:
			lo = m
	var p := c + quer * sg * (hi + GLEICH)
	if strecke_frei(c, p, laenge, float(k[2]), andere, ende_bei.call(p - c) if ende_bei.is_valid() else []):
		return p - c
	return Vector2.ZERO


## geradewegs heran (Chef 18.11., 14:33): liegt der Weg von [von] zum Angriffsplatz [platz] höchstens QUER_GRAD neben der Richtung
## zum Ziel [ziel], am Anfang wie am Ende? (kurzer Weg unter [kurz] Metern zählt nicht)
## [am_schild]: nur am Anfang des Wegs, zuletzt schräg zum Bissplatz bis BISS_SCHILD_GRAD um das Ziel (Variante a, Alter Ego 25.11.,
## 20:21 in Vertretung, Chef 17:52; F10)
static func geradewegs(von: Vector2, platz: Vector2, ziel: Vector2, kurz := 0.15, am_schild := false) -> bool:
	var w := platz - von
	if w.length() < kurz:
		return true
	# am Anfang und am Ende des Wegs (dazwischen liegt der Winkel zwischen beiden): wer neben dem Ziel ankommt, liefe zuletzt quer
	return absf(rad_to_deg(w.angle_to(ziel - von))) <= QUER_GRAD and \
			(am_schild or platz.distance_to(ziel) < GLEICH or absf(rad_to_deg(w.angle_to(ziel - platz))) <= QUER_GRAD)
