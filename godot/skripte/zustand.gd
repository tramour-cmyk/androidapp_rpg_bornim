class_name Zustand
extends RefCounted
# 390: der Spielstand, soweit Gespraeche und Quests ihn brauchen (GameState.kt: flags, inventory, gold, Stufe des Helden);
# als Woerterbuch speicherbar (Spielstand folgt). Uhr, Rast und Laden (390) sind dabei.

var name := "Alrik"
var aussehen := {}                     # 376.1 Kopfform, Haar, Bart, Haar- und Hautfarbe (HeldFigur.VORGABE)
var brs := {}                          # 470: Held nach BRS (BrsHeld.als_daten: Volk, Herkunft, Grundwerte, Startfertigkeiten)
var fert := {}                         # 471: Fertigkeiten durch Tun (BrsFertigkeit.neuer_stand: Werte, Uebung, Rangdecke, Probe, bekannt)
var brs_stufe := {}                    # 471, 870.4: Heldenstufe und Erfahrung nach BRS (Brs.neuer_stand), einzige Quelle der Stufe
var gold := 0
var taschen := {}                      # Ding -> Anzahl (GameState.inventory)
var flaggen := {}                      # Flagge -> true (GameState.flags)
var minuten := 8 * 60                  # 390: Minute des Tages (GameState.minutes), eine Spielminute je Sekunde (Game.tickClock)
var tag := 1
var uhr_rest := 0.0
# 390 (Rast, Resting.kt): was eine Rast beendet oder fuellt (GameState.stamina, winded, staminaBoost, spark, longRestDay, mead, ailments)
var ausdauer := 1.0
var atemlos := false
var ausdauer_trank := false
var funke := false
var satt := false                     # 399.1: GameState.wellFed, nach dem Essen bis zum naechsten Kampf
var lange_rast_tag := 0
var met := 0
var leiden := {}                       # Zustand -> Runden (GameState.ailments)
var wiederkehr := {"karte": "temple", "x": 4, "y": 4, "blick": "UP"}   # GameState.respawn, anfangs Story.RESPAWN (543: Tempel wie alt)
# 390 (Laden): Ausruestung in der Tasche (GameState.bag, Woerterbuecher wie Gear), Siege (battlesWon), schon gekaufte Ware (shopSold)
var beutel: Array = []
var siege := 0
var schritte := 0                 # 399.1 GameState.steps
var laden_verkauft := {}               # "Satz:uid" -> true
var gehoert := {}                      # 399.1 Person -> Fingerabdruecke der letzten Gespraeche (GameState.heard, Ruf.gd)
var uid_zaehler := 0                   # GameState.uidCounter
var gespielt_ms := 0                   # 529 (GameState.playedMs, PlayClock): gespielte Zeit fuer die Karte des Spielstands
var varianten := {}                    # 504.1 Marke -> [wie oft gehoert, letzte Wahl] (Skript.variante)
var gepflueckt := {}                   # 490 „Karte:x:y“ -> Tag, an dem dort Heilkraut gepflueckt wurde (GameState.picked)

func has(f: String) -> bool: return flaggen.has(f)
func setze(f: String) -> void: flaggen[f] = true
func anzahl(ding: String) -> int: return int(taschen.get(ding, 0))
func stufe() -> int: return int(stufe_brs()["stufe"])   # 870.4: Heldenstufe nach BRS
func betrunken() -> bool: return met >= Rast.BETRUNKEN

func uhr(dt: float) -> void:
	uhr_rest += dt
	while uhr_rest >= 1.0:
		uhr_rest -= 1.0
		minuten += 1
		if minuten >= 24 * 60:
			minuten = 0
			tag += 1

func dazu(ding: String, n: int = 1) -> void: taschen[ding] = anzahl(ding) + n

# wie GameState.remove: nie unter null, leere Eintraege weg
func weg(ding: String, n: int = 1) -> void:
	var rest := anzahl(ding) - n
	if rest > 0: taschen[ding] = rest
	else: taschen.erase(ding)

func neue_uid() -> int:
	uid_zaehler += 1
	return uid_zaehler

# GameState.addGear: ohne eigene Kennung bekommt das Stueck eine neue
func ausruestung_dazu(g: Dictionary) -> Dictionary:
	var eigen := g.duplicate(true)
	if int(eigen.get("uid", 0)) <= 0: eigen["uid"] = neue_uid()
	beutel.append(eigen)
	return eigen

# ein Stueck Ausruestung aus JSON: Zahlen wieder ganz
static func stueck(g: Dictionary) -> Dictionary:
	var rolls: Array = []
	for r in g.get("rolls", []): rolls.append([String(r[0]), int(r[1])])
	return {"uid": int(g.get("uid", 0)), "base": String(g["base"]), "rarity": String(g.get("rarity", "COMMON")), "ilvl": int(g.get("ilvl", 1)),
		"plus": int(g.get("plus", 0)), "rolls": rolls, "unique": g.get("unique"), "name_seed": int(g.get("name_seed", 0))}

func als_daten() -> Dictionary:
	return {"name": name, "stufe": stufe(), "gold": gold, "taschen": taschen.duplicate(), "flaggen": flaggen.keys(), "minuten": minuten, "tag": tag,
		"ausdauer": ausdauer, "atemlos": atemlos, "ausdauer_trank": ausdauer_trank, "funke": funke, "satt": satt, "lange_rast_tag": lange_rast_tag,
		"met": met, "leiden": leiden.duplicate(), "wiederkehr": wiederkehr.duplicate(), "beutel": beutel.duplicate(true), "siege": siege, "schritte": schritte,
		"laden_verkauft": laden_verkauft.keys(), "uid_zaehler": uid_zaehler, "gehoert": gehoert.duplicate(true), "aussehen": aussehen.duplicate(),
		"gepflueckt": gepflueckt.duplicate(), "brs": brs.duplicate(true), "fert": fert.duplicate(true), "brs_stufe": brs_stufe.duplicate(true), "gespielt_ms": gespielt_ms, "varianten": varianten.duplicate(true)}

## 471: Stand der Fertigkeiten nach BRS, beim ersten Mal aus den Startfertigkeiten des Helden (leer ohne BRS-Held)
func fertigkeiten_stand() -> Dictionary:
	if fert.is_empty() and not brs.is_empty(): fert = BrsFertigkeit.neuer_stand(brs.get("fertigkeiten", {}))
	return fert

## 471, 870.4: Stand der Heldenstufe nach BRS (Stufe, Erfahrung, Toepfe); Kampf (lohn.gd) und Uebung schreiben hinein
func stufe_brs() -> Dictionary:
	if brs_stufe.is_empty(): brs_stufe = Brs.neuer_stand()
	return brs_stufe

## 471: eine Taetigkeit ausserhalb des Kampfs (Kraeuter pfluecken, Handeln im Laden) uebt [f] einmal, Ziel der eigenen Stufe; die
## Ereignisse sammeln sich fuer die naechste Notiz (fert_notiz)
var fert_ev: Array = []
func uebe(f: String) -> void:
	var s := fertigkeiten_stand()
	if s.is_empty(): return
	fert_ev.append_array(BrsFertigkeit.uebe(s, stufe_brs(), f, stufe()))
	spiegle()

## 471: die geuebten Werte auch in brs.fertigkeiten (Heldenreiter 762 liest dort), nur Bekanntes
func spiegle() -> void:
	if fert.is_empty() or brs.is_empty(): return
	var w := {}
	for n in fert["bekannt"]: w[String(n)] = BrsFertigkeit.wert(fert, String(n))
	brs["fertigkeiten"] = w

## 471: „Handeln ↑ 3“ fuer alles seit der letzten Notiz, oder leer
func fert_notiz() -> String:
	var t := Kampfuebung.notiz(fert_ev)
	fert_ev.clear()
	return t

static func aus_daten(d: Dictionary) -> Zustand:
	var z := Zustand.new()
	z.aussehen = (d.get("aussehen", {}) as Dictionary).duplicate()
	if d.get("brs") is Dictionary and not (d["brs"] as Dictionary).is_empty(): z.brs = BrsHeld.aus_daten(d["brs"]).als_daten()   # 470: Zahlen wieder ganz
	if d.get("fert") is Dictionary: z.fert = (d["fert"] as Dictionary).duplicate(true)   # 471
	if d.get("brs_stufe") is Dictionary:
		z.brs_stufe = (d["brs_stufe"] as Dictionary).duplicate(true)
		if z.brs_stufe.has("stufe"): z.brs_stufe["stufe"] = int(z.brs_stufe["stufe"])   # 870.4: JSON liefert 1.0
	z.spiegle()
	z.name = String(d.get("name", z.name)); z.gold = int(d.get("gold", 0))
	for k in d.get("taschen", {}): z.taschen[String(k)] = int(d["taschen"][k])
	for f in d.get("flaggen", []): z.flaggen[String(f)] = true
	z.minuten = int(d.get("minuten", z.minuten)); z.tag = int(d.get("tag", 1))
	z.ausdauer = float(d.get("ausdauer", 1.0)); z.atemlos = bool(d.get("atemlos", false)); z.ausdauer_trank = bool(d.get("ausdauer_trank", false))
	z.funke = bool(d.get("funke", false)); z.satt = bool(d.get("satt", false)); z.lange_rast_tag = int(d.get("lange_rast_tag", 0)); z.met = int(d.get("met", 0))
	for k in d.get("leiden", {}): z.leiden[String(k)] = int(d["leiden"][k])
	if d.has("wiederkehr"):
		var w: Dictionary = d["wiederkehr"]
		z.wiederkehr = {"karte": String(w["karte"]), "x": int(w["x"]), "y": int(w["y"]), "blick": String(w.get("blick", "DOWN"))}
	for g in d.get("beutel", []): z.beutel.append(stueck(g))
	z.siege = int(d.get("siege", 0)); z.schritte = int(d.get("schritte", 0)); z.uid_zaehler = int(d.get("uid_zaehler", 0))
	for k in d.get("laden_verkauft", []): z.laden_verkauft[String(k)] = true
	for k in d.get("gehoert", {}): z.gehoert[String(k)] = (d["gehoert"][k] as Array).map(func(x): return int(x))
	for k in d.get("gepflueckt", {}): z.gepflueckt[String(k)] = int(d["gepflueckt"][k])
	z.gespielt_ms = int(d.get("gespielt_ms", 0))
	for k in d.get("varianten", {}): z.varianten[String(k)] = [int(d["varianten"][k][0]), int(d["varianten"][k][1])]   # 504.1
	return z
