class_name Heldwerte
extends RefCounted
# 390 (Held fuer Laden und Rast): der Held mit seinen Werten wie Hero.kt, Zeile fuer Zeile; Regeln, Voelker, Klassen und
# Grundformen der Ausruestung aus daten/held.json (HeroExport.kt). Ausruestung als Woerterbuch wie Gear:
# {uid, base, rarity, ilvl, plus, rolls: [[Affix, Wert], …], unique}. Gegenprobe: godot/tests/held_golden.gd mit den Proben
# aus dem alten Spiel. Die Namen der Attribute, Affixe, Plaetze und Faehigkeiten sind die Kennungen aus Kotlin (STR, MAIN_HAND …).

const ATTRIBUTE := ["STR", "DEX", "CON", "INT", "WIS", "CHA"]

static var daten := {}

var name := "Alrik"
var volk := "HUMAN"
var klasse := "FIGHTER"
var stufe := 1
var ep := 0
var basis := {}                        # Attribut -> Wert ohne Ausruestung
var start := {}                        # Werte bei der Erschaffung (Hero.start)
var tp := 0
var zp := 0
var offen := 0                         # noch zu verteilende Attributspunkte (unspentPoints)
var ausruestung := {}                  # Platz -> Gear
var kapitel := 1                       # Hero.chapter: begrenzt die Boni der Ausruestung
var verbraucht := {}                   # Faehigkeit -> Anzahl (Hero.spent)

static func lade() -> Dictionary:
	if daten.is_empty() and FileAccess.file_exists("res://daten/held.json"):
		var j = JSON.parse_string(FileAccess.get_file_as_string("res://daten/held.json"))
		if j is Dictionary: daten = j
	return daten

static func regel(k: String): return lade()["regeln"][k]
static func grundform(id: String) -> Dictionary: return lade()["grundformen"][id]
func klassendaten() -> Dictionary: return lade()["klassen"][klasse]

# ---------------------------------------------------------------- Rules.kt
static func mod_von(wert_: int) -> int: return floori((wert_ - 10) / 2.0)
static func uebung_fuer(s: int) -> int: return 2 + (s - 1) / 4
static func zauberpunkte(s: int) -> int: return int(regel("zauberpunkte")[clampi(s, 1, int(regel("max_stufe")))])
static func attributspunkte(s: int) -> int:
	var n := 0
	for a in regel("attributstufen"):
		if int(a) <= s: n += 1
	return 2 * n
static func stufe_fuer_ep(e: int) -> int:
	var tab: Array = regel("ep_fuer_stufe")
	var l := 1
	while l < int(regel("max_stufe")) and e >= int(tab[l + 1]): l += 1
	return l
# Obergrenze eines Affixes im Kapitel, -1 ohne Grenze (Rules.gearCap)
static func deckel(affix: String, kap: int) -> int:
	var d: Dictionary = regel("deckel")
	return kap + int(d[affix]) if d.has(affix) else -1

# ---------------------------------------------------------------- Ausruestung
static func gesamt(g: Dictionary, affix: String) -> int:
	var n := 0
	for r in g.get("rolls", []):
		if String(r[0]) == affix: n += int(r[1])
	return n

func ding(platz: String): return ausruestung.get(platz)
func roh_bonus(affix: String) -> int:
	var n := 0
	for g in ausruestung.values(): n += gesamt(g, affix)
	return n
func bonus(affix: String) -> int:
	var roh := roh_bonus(affix)
	var c := deckel(affix, kapitel)
	return roh if c < 0 else mini(roh, c)
func ausruestungs_bonus(a: String) -> int: return mini(roh_bonus(a) + roh_bonus("ALL_STATS"), deckel(a, kapitel))
func ausruestung_gedeckelt(a: String) -> bool: return roh_bonus(a) + roh_bonus("ALL_STATS") > ausruestungs_bonus(a)

func start_werte() -> Dictionary: return start if not start.is_empty() else Heldwerte.startwerte(volk, klasse)
func verteilte_punkte() -> int:
	var sw := start_werte()
	var n := 0
	for a in ATTRIBUTE: n += maxi(0, int(basis[a]) - int(sw[a]))
	return n

# Punkte an die Stufe anpassen (Hero.fitPoints): zu viel verteilte zurueck, zuerst beim am meisten gesteigerten Attribut
func passe_punkte() -> bool:
	var vorher := [basis.duplicate(), offen]
	var erlaubt := attributspunkte(stufe)
	var zuviel := verteilte_punkte() - erlaubt
	var sw := start_werte()
	while zuviel > 0:
		var best: String = ATTRIBUTE[0]
		for a in ATTRIBUTE:
			if int(basis[a]) - int(sw[a]) > int(basis[best]) - int(sw[best]): best = a
		basis[best] = int(basis[best]) - 1
		zuviel -= 1
	offen = erlaubt - verteilte_punkte()
	begrenze()
	return basis != vorher[0] or offen != vorher[1]

func wert(a: String) -> int: return int(basis[a]) + ausruestungs_bonus(a)
func mod(a: String) -> int: return mod_von(wert(a))
func uebung() -> int: return uebung_fuer(stufe)

func max_tp() -> int:
	var w := int(klassendaten()["trefferwuerfel"])
	var con := mod("CON")
	var je_stufe := maxi(1, w / 2 + 1 + con)
	return maxi(1, w + con + 4) + (stufe - 1) * je_stufe + bonus("HP")

func max_zp() -> int: return zauberpunkte(stufe) + bonus("SP") if bool(klassendaten()["zauberer"]) else 0

func hat(faehigkeit: String) -> bool:
	var f: Dictionary = lade()["faehigkeiten"][faehigkeit]
	return String(f["klasse"]) == klasse and stufe >= int(f["stufe"])

func faehigkeiten() -> Array:
	var r := []
	for f in lade()["faehigkeiten"]:
		if hat(f): r.append(f)
	return r

func rk(magierruestung: bool = false) -> int:
	var ges := mod("DEX")
	var brust = ding("CHEST")
	var getragen: bool = brust != null and int(grundform(brust["base"])["ruestung"]) > 0
	var r := 0
	if not getragen: r = (13 if magierruestung else 10) + ges
	else:
		var b := grundform(brust["base"])
		match String(b["gewicht"]):
			"LIGHT": r = int(b["ruestung"]) + ges
			"MEDIUM": r = int(b["ruestung"]) + mini(ges, 2)
			_: r = int(b["ruestung"])
		r += int(brust["plus"])
		if hat("FIGHTING_STYLE"): r += 1
	var neben = ding("OFF_HAND")
	if neben != null and String(grundform(neben["base"])["art"]) == "SHIELD": r += int(grundform(neben["base"])["ruestung"]) + int(neben["plus"])
	return r + bonus("AC")

func waffe(): return ding("MAIN_HAND")
func ist_waffe(g) -> bool: return g != null and String(grundform(g["base"])["art"]) == "WEAPON"
func nebenwaffe():
	var n = ding("OFF_HAND")
	return n if ist_waffe(n) else null

func waffen_attribut(w) -> String:
	if w == null: return "STR"
	var d := grundform(w["base"])
	if bool(d["fern"]): return "DEX"
	if bool(d["finesse"]) and mod("DEX") > mod("STR"): return "DEX"
	return "STR"

func geuebt(w: Dictionary) -> bool:
	var d := grundform(w["base"])
	var erlaubt = klassendaten()["waffen"]
	return String(d["art"]) != "WEAPON" or erlaubt == null or String(w["base"]) in erlaubt

func angriff() -> int: return angriff_mit(waffe())
func angriff_mit(w) -> int:
	var u := uebung() if w == null or geuebt(w) else 0
	return mod(waffen_attribut(w)) + u + (int(w["plus"]) if w != null else 0) + bonus("ATTACK")

# Schaden eines Treffers [Anzahl, Seiten, Bonus]; die Nebenhand bekommt kein Attribut dazu (nur ein negatives)
func schaden() -> Array: return schaden_mit(waffe())
func schaden_mit(w, nebenhand: bool = false) -> Array:
	var extra := bonus("DAMAGE") + bonus("FIRE") + bonus("RADIANT")
	if w == null: return [1, 1, mod("STR") + extra]
	var d := grundform(w["base"])
	var wuerfel = d["vielseitig"] if not nebenhand and beide_haende_mit(w) and d["vielseitig"] != null else null
	if wuerfel == null: wuerfel = d["schaden"] if d["schaden"] != null else [1, 4, 0]
	var att := mini(0, mod(waffen_attribut(w))) if nebenhand else mod(waffen_attribut(w))
	return [int(wuerfel[0]), int(wuerfel[1]), int(wuerfel[2]) + att + int(w["plus"]) + extra]

# in beiden Haenden: zweihaendig immer, vielseitig, wenn sie die Hauptwaffe ist und die andere Hand leer
func beide_haende() -> bool: return beide_haende_mit(waffe())
func beide_haende_mit(w) -> bool:
	if w == null: return false
	var d := grundform(w["base"])
	if bool(d["fern"]): return false
	var h = waffe()
	return bool(d["zweihaendig"]) or (d["vielseitig"] != null and h != null and int(w["uid"]) == int(h["uid"]) and ding("OFF_HAND") == null)

func zauber_attribut() -> String: return String(klassendaten()["haupt"])
func zauberbonus_ausruestung() -> int:
	var n := 0
	for g in ausruestung.values(): n += int(grundform(g["base"])["fokus"])
	return n + bonus("SPELL")
func zauberangriff() -> int: return mod(zauber_attribut()) + uebung() + zauberbonus_ausruestung()
func zauber_sg() -> int: return 8 + mod(zauber_attribut()) + uebung() + zauberbonus_ausruestung()

func krit_ab() -> int: return maxi(17, 20 - bonus("CRIT") - (1 if hat("IMPROVED_CRITICAL") else 0))
func lebensraub() -> int: return mini(bonus("LIFESTEAL"), 30)
func schadensminderung() -> int: return bonus("RESIST")
func standhaft() -> int: return mini(bonus("TENACITY"), 60)

# Loot.wearable
func kann_tragen(g: Dictionary) -> bool:
	var b := grundform(g["base"])
	var k := klassendaten()
	match String(b["art"]):
		"ARMOR":
			match String(b["gewicht"]):
				"NONE", "CLOTH": return true
				_: return String(b["gewicht"]) in k["ruestung"]
		"SHIELD": return bool(k["schilde"])
	return true

# an den eigenen Platz; zurueck kommt, was dafuer herunter musste (Hero.equip)
func anlegen(g: Dictionary) -> Array:
	var weg := []
	var d := grundform(g["base"])
	var platz := String(d["slot"])
	if ausruestung.has(platz): weg.append(ausruestung[platz])
	ausruestung[platz] = g
	if bool(d["zweihaendig"]) and ausruestung.has("OFF_HAND"):
		weg.append(ausruestung["OFF_HAND"]); ausruestung.erase("OFF_HAND")
	var h = waffe()
	if platz == "OFF_HAND" and h != null and bool(grundform(h["base"])["zweihaendig"]):
		weg.append(h); ausruestung.erase("MAIN_HAND")
	begrenze()
	return weg

# eine einhaendige Waffe in die Nebenhand (Hero.equipOffHand)
func anlegen_nebenhand(g: Dictionary) -> Array:
	var weg := []
	if ausruestung.has("OFF_HAND"): weg.append(ausruestung["OFF_HAND"])
	ausruestung["OFF_HAND"] = g
	var h = waffe()
	if h != null and bool(grundform(h["base"])["zweihaendig"]):
		weg.append(h); ausruestung.erase("MAIN_HAND")
	begrenze()
	return weg

func ablegen(platz: String):
	var g = ausruestung.get(platz)
	ausruestung.erase(platz)
	begrenze()
	return g

func begrenze() -> void:
	tp = clampi(tp, 0, max_tp())
	zp = clampi(zp, 0, max_zp())

func voll() -> void:
	tp = max_tp()
	zp = max_zp()
	verbraucht.clear()

# EP dazu, Stufen bis hoechstens deckel_ (Hero.gainXp); zurueck die gewonnenen Stufen
func ep_dazu(n: int, deckel_: int = -1) -> int:
	var max_s := int(regel("max_stufe"))
	if deckel_ < 0: deckel_ = max_s
	var vorher := stufe
	ep += n
	var ziel := mini(stufe_fuer_ep(ep), deckel_)
	while stufe < ziel:
		stufe += 1
		offen += attributspunkte(stufe) - attributspunkte(stufe - 1)
	if deckel_ < max_s: ep = mini(ep, int(regel("ep_fuer_stufe")[deckel_]))
	if stufe > vorher: voll()
	begrenze()
	return stufe - vorher

func kann_steigern(a: String, geplant: int = 0) -> bool:
	return geplant < offen and int(basis[a]) + geplant < int(regel("max_wert"))

func steigern(a: String) -> bool:
	if offen <= 0 or int(basis[a]) >= int(regel("max_wert")): return false
	var alt := max_tp()
	basis[a] = int(basis[a]) + 1
	offen -= 1
	if max_tp() > alt: tp += max_tp() - alt
	begrenze()
	return true

# ---------------------------------------------------------------- Erschaffung (Hero.companion)
static func startwerte(v: String, k: String) -> Dictionary:
	var r := {}
	var std: Array = regel("standard")
	var reihe: Array = lade()["klassen"][k]["reihenfolge"]
	var bon: Dictionary = lade()["voelker"][v]["bonus"]
	for i in reihe.size(): r[String(reihe[i])] = int(std[i]) + int(bon.get(String(reihe[i]), 0))
	return r

static func vorschlag(k: String) -> Dictionary:
	var reihe: Array = ["WIS", "STR", "CON", "DEX", "CHA", "INT"] if k == "CLERIC" else lade()["klassen"][k]["reihenfolge"]
	var vs: Array = regel("vorschlag")
	var r := {}
	for i in reihe.size(): r[String(reihe[i])] = int(vs[i])
	return r

static func punktkosten(w: int) -> int:
	if w >= int(regel("punktkauf_min")) and w <= 13: return w - int(regel("punktkauf_min"))
	if w == 14: return 7
	if w == 15: return 9
	return 999

static func gueltiger_kauf(werte: Dictionary) -> bool:
	var summe := 0
	for a in ATTRIBUTE:
		var w := int(werte.get(a, 0))
		if w < int(regel("punktkauf_min")) or w > int(regel("punktkauf_max")): return false
		summe += punktkosten(w)
	return summe <= int(regel("punktkauf"))

static func erschaffe(name_: String, v: String, k: String, gekauft: Dictionary = {}, neue_uid: Callable = Callable()) -> Heldwerte:
	var vor := gekauft if not gekauft.is_empty() and gueltiger_kauf(gekauft) else vorschlag(k)
	var bon: Dictionary = lade()["voelker"][v]["bonus"]
	var h := Heldwerte.new()
	h.name = name_; h.volk = v; h.klasse = k
	for a in ATTRIBUTE: h.basis[a] = int(vor[a]) + int(bon.get(a, 0))
	h.start = h.basis.duplicate()
	for id in lade()["klassen"][k]["start"]:
		if lade()["grundformen"].has(id):
			h.anlegen({"uid": neue_uid.call() if neue_uid.is_valid() else 0, "base": String(id), "rarity": "COMMON", "ilvl": 1, "plus": 0, "rolls": [], "unique": null})
	h.voll()
	return h

# aus dem Woerterbuch von HeroExport.input (und spaeter dem Spielstand)
static func aus_daten(d: Dictionary) -> Heldwerte:
	var h := Heldwerte.new()
	h.name = String(d["name"]); h.volk = String(d["volk"]); h.klasse = String(d["klasse"])
	h.stufe = int(d["stufe"]); h.ep = int(d["ep"]); h.tp = int(d["tp"]); h.zp = int(d["zp"]); h.offen = int(d["offen"])
	h.kapitel = int(d.get("kapitel", 1))
	for a in ATTRIBUTE:
		h.basis[a] = int(d["basis"][a])
		if d.has("start"): h.start[a] = int(d["start"][a])
	for p in d.get("ausruestung", {}): h.ausruestung[String(p)] = d["ausruestung"][p]
	return h

func als_daten() -> Dictionary:
	return {"name": name, "volk": volk, "klasse": klasse, "stufe": stufe, "ep": ep, "basis": basis.duplicate(), "start": start.duplicate(),
		"tp": tp, "zp": zp, "offen": offen, "kapitel": kapitel, "ausruestung": ausruestung.duplicate(true)}
