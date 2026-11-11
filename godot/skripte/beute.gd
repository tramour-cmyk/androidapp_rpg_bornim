class_name Beute
extends RefCounted
# 390 (Laden, Beute): aus Loot.kt Seltenheit, Grundform, Thessas Ware (Loot.shopGear), was ein Kampf bringt (Loot.drops); dazu
# Gear.name und Gear.price. Ausruestung als Woerterbuch wie in brs_held.gd: {uid, base, rarity, ilvl, guete, rolls: [[Kennung, Wert]
# oder [Kennung, Wert, Fertigkeit], …], unique, name_seed}. Wuerfel: alles mit next_int, d, chance, pick, weighted (KotlinZufall).
# 870.6 (LISTE-UMZUG-BRS.md Schritt 6, DESIGN-BRS.md 11, 870a 6 A): nach dem BRS. Kein „plus“ mehr, dafuer die Guete (Normal, Gut,
# Meisterhaft) als eigene Achse; Zusatzeigenschaften nur aus der Liste des Regelwerks (Grundwert, Schutzwert, Leben, Mana, kritisch,
# Zauberschaden, Abwehrprobe, ab episch Fertigkeit); kein Filter nach Klasse, die Beute folgt den Fertigkeiten des Helden; Anzeige
# ohne Wuerfel. Alle Zahlen nur in den Regelwerten (werte.json „gegenstaende“), die Grundformen aus held.json und dem Katalog.

const PLAETZE := ["HEAD", "CHEST", "ARMS", "LEGS", "CLOAK", "AMULET", "RING", "MAIN_HAND", "OFF_HAND"]   # GearSlot.entries
const SELTENHEIT := ["COMMON", "UNCOMMON", "RARE", "VERY_RARE", "EPIC", "DIVINE"]
const GUETE_DE := ["Normal", "Gut", "Meisterhaft"]                 # [870.14.namen] Güte
const GUETE_EN := ["Standard", "Fine", "Masterwork"]
const SCHADENSART := {"schnitt": ["Schnitt", "Slash"], "stich": ["Stich", "Pierce"], "wucht": ["Wucht", "Crush"], "feuer": ["Feuer", "Fire"],
	"gift": ["Gift", "Poison"], "saeure": ["Säure", "Acid"], "licht": ["Licht", "Light"]}     # [870.14.namen], in Listen gross

static func d_() -> Dictionary: return BrsHeld.daten()
static func r_() -> Dictionary: return BrsHeld.lade().get("gegenstaende", {})
static func grundform(id: String) -> Dictionary: return d_()["grundformen"][id]
static func stufe_von(r: String) -> int: return SELTENHEIT.find(r)
static func zusatzzahl(r: String) -> int: return int(r_()["zusatzzahl"].get(r, 0))
static func ist_waffe(b: Dictionary) -> bool: return String(b["art"]) == "WEAPON"

static func grundformen() -> Array:
	var out: Array = []
	for id in d_()["grundform_reihe"]: out.append(String(id))
	return out

static func min_stufe(r: String) -> int: return int(r_()["mindeststufe"].get(r, 1))

static func _decke(was: String, kap: int) -> String:
	var dk: Dictionary = r_()[was]
	return String(dk.get(str(kap), dk["sonst"]))

static func max_normal(kap: int) -> String: return _decke("decke_beute", kap)
static func max_besonders(kap: int) -> String: return _decke("decke_besonders", kap)

# Loot.rollRarity
static func wuerfle_seltenheit(w, stufe: int, magiefund: int = 0, mindestens: String = "COMMON", hoechstens: String = "DIVINE") -> String:
	var mf := 1.0 + magiefund / 100.0
	var boden := mini(stufe_von(mindestens), stufe_von(hoechstens))
	var gew: Dictionary = r_()["gewicht"]
	var eintraege: Array = []
	for i in SELTENHEIT.size():
		if i < boden or i > stufe_von(hoechstens): continue
		if stufe < min_stufe(SELTENHEIT[i]) and i != boden: continue
		eintraege.append([SELTENHEIT[i], maxi(1, int(int(gew[SELTENHEIT[i]]) * (1.0 if i == 0 else mf)))])
	return w.weighted(eintraege)

# Loot.rarityFor: Kapitel des Helden, Magiefund mit Deckel
static func seltenheit_fuer(hw: BrsHeld, w, stufe: int, besonders: bool, boden: String = "COMMON") -> String:
	var mf := hw.bonus("MAGIC_FIND")
	if besonders: return wuerfle_seltenheit(w, stufe, mf, boden, max_besonders(hw.kapitel))
	if hw.kapitel == 1:
		if hw.stufe < int(r_()["kapitel1_ungewoehnlich_ab_stufe"]): return "COMMON"
		var ungew := int(int(r_()["kapitel1_ungewoehnlich_promille"]) * (1.0 + mf / 100.0))
		return "UNCOMMON" if w.d(1000) <= ungew else "COMMON"
	return wuerfle_seltenheit(w, stufe, mf, boden, max_normal(hw.kapitel))

# ---------------------------------------------------------------- Guete (N 11)
static func guete_von(g) -> int: return clampi(int(g.get("guete", 0)), 0, 2) if g is Dictionary else 0
static func guete_faktor(g) -> float: return float(r_()["guete_faktor"][guete_von(g)])
static func guete_name(i: int, sprache: String = "") -> String:
	if sprache == "": sprache = Sprache.aktiv()
	return (GUETE_DE if sprache == "de" else GUETE_EN)[clampi(i, 0, 2)]

## Guete beim Fund: gewoehnliche Beute oder besonderer Fund (Boss, Auftrag); in Kapitel 1 hat gewoehnliche Beute eine Decke
static func wuerfle_guete(w, besonders: bool, kapitel: int) -> int:
	var gw: Array = r_()["guete_gewicht_besonders" if besonders else "guete_gewicht_beute"]
	var hoechst := 2
	if kapitel == 1 and not besonders: hoechst = GUETE_DE.find(String(r_().get("guete_decke_kapitel1", "Meisterhaft")))
	var eintraege: Array = []
	for i in hoechst + 1: eintraege.append([i, int(gw[i])])
	return int(w.weighted(eintraege))

# ---------------------------------------------------------------- Zusatzeigenschaften (N 11, 870a 6 A)
## die erlaubten Kennungen einer Grundform (werte.json „erlaubt“ je Platz; Waffen nach Nah, Fern, Zauberkraft), ab episch dazu SKILL
static func zusatz_fuer(id: String, seltenheit: String = "COMMON") -> Array:
	var b := grundform(id)
	var e: Dictionary = r_()["erlaubt"]
	var art := String(b["art"])
	var l: Array = []
	if art == "LIGHT": return []
	if art == "FOCUS" or (art == "WEAPON" and int(b["fokus"]) > 0): l = e["FOKUS"]
	elif art == "WEAPON": l = e["FERNWAFFE" if bool(b["fern"]) else "WAFFE"]
	elif art == "SHIELD": l = e["SHIELD"]
	else: l = e.get(String(b["slot"]), e["RING"])
	l = l.duplicate()
	if stufe_von(seltenheit) >= stufe_von(String(r_()["zusatz"]["SKILL"]["ab_seltenheit"])): l.append("SKILL")
	return l

## Wert einer Zusatzeigenschaft nach der Gegenstandsstufe (werte.json „zusatz“: „wert“, ab „wert2_ab_stufe“ das Doppelte)
static func zusatz_wert(a: String, stufe: int) -> int:
	var z: Dictionary = r_()["zusatz"].get(a, {})
	var n := int(z.get("wert", 0))
	if z.has("wert2_ab_stufe") and stufe >= int(z["wert2_ab_stufe"]): n *= 2
	return n

static func zusatz_prozent(a: String) -> bool: return bool(r_()["zusatz"].get(a, {}).get("prozent", false))

## Fertigkeit fuer „Fertigkeit +n“: die, die das Stueck selbst braucht, sonst eine der Waffengruppen
static func _skill_fuer(id: String, w) -> String:
	var f := BrsHeld.fertigkeit_von(id)
	if f != "": return f
	var gruppen := BrsHeld.ohne_info(BrsHeld.lade()["waffen"])
	return String(w.pick(gruppen))

## Wortlaut einer Zusatzeigenschaft (STORY-BRS-HELD.md „Gegenstandsfenster“): „+1 Kraft“, „+3 % kritisch“, „+1 Einhänder“
static func zusatz_text(r: Array, sprache: String = "") -> String:
	if sprache == "": sprache = Sprache.aktiv()
	var de := sprache == "de"
	var a := String(r[0]); var n := int(r[1])
	if a == "SKILL": return "+%d %s" % [n, String(r[2]) if r.size() > 2 else ""]
	var namen := {"CRIT": ["kritisch", "critical"], "SPELL": ["Zauberschaden", "spell damage"], "TENACITY": ["Abwehrprobe", "resistance roll"]}
	var nm = d_()["affixdaten"].get(a, {}).get("name", a)
	var wort: String = (namen[a][0 if de else 1]) if namen.has(a) else (String(nm.get(sprache, nm.get("de", a))) if nm is Dictionary else String(nm))     # in der verlangten Sprache
	if zusatz_prozent(a): return ("+%d %% %s" if de else "+%d%% %s") % [n, wort]
	return "+%d %s" % [n, wort]

# ---------------------------------------------------------------- Fund
## Gewicht einer Grundform fuer [held] nach seinen Fertigkeiten (870a 6: kein Filter nach Klasse)
static func gewicht_fuer(held, id: String) -> int:
	var grund := int(r_()["fertigkeit_grund"])
	if not (held is BrsHeld): return grund
	var f := BrsHeld.fertigkeit_von(id)
	return grund + (held.fertigkeit(f) if f != "" else grund)

# Loot.generate: ein zufaelliges Stueck; mit Held nach seinen Fertigkeiten gewichtet, sonst gleich
static func erzeuge(w, uid: int, stufe: int, seltenheit: String, held = null, slot: String = "", besonders := false) -> Dictionary:
	stufe = maxi(stufe, 1)
	var pool: Array = []
	for id in grundformen():
		var b := grundform(id)
		if String(b["art"]) != "LIGHT" and int(b["ab_stufe"]) <= stufe and (slot == "" or String(b["slot"]) == slot):
			pool.append([id, gewicht_fuer(held, id)])
	var id: String = w.weighted(pool)
	var kap: int = held.kapitel if held is BrsHeld else 1
	return wuerfle(uid, id, stufe, seltenheit, w, wuerfle_guete(w, besonders, kap))

# Loot.roll: Zusatzeigenschaften je Platz, jede hoechstens einmal
static func wuerfle(uid: int, id: String, stufe: int, seltenheit: String, w, guete := 0) -> Dictionary:
	var erlaubt := zusatz_fuer(id, seltenheit)
	var rolls: Array = []
	while rolls.size() < zusatzzahl(seltenheit) and not erlaubt.is_empty():
		var a: String = w.pick(erlaubt)
		erlaubt.erase(a)
		if a == "SKILL": rolls.append([a, zusatz_wert(a, stufe), _skill_fuer(id, w)])
		else: rolls.append([a, zusatz_wert(a, stufe)])
	return {"uid": uid, "base": id, "rarity": seltenheit, "ilvl": stufe, "guete": guete, "rolls": rolls, "unique": null, "name_seed": w.d(10000)}

# Loot.drops: was ein besiegtes Monster fallen laesst; [neue_uid] gibt die Kennung (GameState.nextUid)
static func beute(hw: BrsHeld, w, stufe: int, boss: bool, elite: bool, neue_uid: Callable) -> Array:
	var funde: Array = []     # [Seltenheit, besonders]
	if boss:
		funde.append([seltenheit_fuer(hw, w, stufe, true, "RARE"), true])
		for i in w.d(2): funde.append([seltenheit_fuer(hw, w, stufe, false), false])
	elif elite:
		funde.append([seltenheit_fuer(hw, w, stufe, true, "UNCOMMON"), true])
	elif w.chance(float(r_()["beute_chance"])):
		funde.append([seltenheit_fuer(hw, w, stufe, false), false])
	var out: Array = []
	for f in funde:
		var g := erzeuge(w, 0, stufe, String(f[0]), hw, "", bool(f[1]))
		g["uid"] = neue_uid.call()
		out.append(g)
	return out

# generate zieht die Grundform vor der Kennung
static func erzeuge_mit_uid(w, neue_uid: Callable, stufe: int, r: String, held = null) -> Dictionary:
	var g := erzeuge(w, 0, stufe, r, held)
	g["uid"] = neue_uid.call()
	return g

# 870.6: Einzelstuecke nach dem BRS (werte.json „gegenstaende“ „einzelstuecke“): Grundform, Seltenheit, Guete, feste Zusatzeigenschaften
static func einzelstueck(id: String) -> Dictionary: return r_().get("einzelstuecke", {}).get(id, {})
static func einzel(id: String, uid: int, stufe: int) -> Dictionary:
	var e := einzelstueck(id)
	var rolls: Array = []
	for r in e.get("zusatz", []): rolls.append((r as Array).duplicate())
	return {"uid": uid, "base": String(e["grundform"]), "rarity": String(e["seltenheit"]), "ilvl": stufe, "guete": int(e.get("guete", 0)),
		"rolls": rolls, "unique": id, "name_seed": 0}

# Loot.torch: eine schlichte Fackel (84.1)
static func fackel(uid: int) -> Dictionary:
	return {"uid": uid, "base": "torch", "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 0}

# Loot.shopGear: Thessas Ware; neu alle acht Siege und mit jeder Stufe (59e.3: bleibt sonst); Haendler verkaufen Guete Normal
static func ladenware(hw: BrsHeld, siege: int) -> Array:
	var stufe := hw.stufe
	var w := KotlinZufall.new(KotlinZufall.s32(siege / 8 * 7919 + stufe * 31 + KotlinZufall.hash_code(hw.name)))
	var liste: Array = []
	# das Grundlegende jedes Platzes
	for slot in PLAETZE:
		var pool: Array = []
		for id in grundformen():
			var b := grundform(id)
			if String(b["slot"]) == slot and int(b["ab_stufe"]) <= stufe and String(b["art"]) != "LIGHT": pool.append(id)
		if not pool.is_empty(): liste.append(wuerfle(-(liste.size() + 1), w.pick(pool), stufe, "COMMON", w))
	# 84.1: immer eine schlichte Fackel
	liste.append(fackel(-(liste.size() + 1)))
	# eine Handvoll magischer Stuecke, das erste fuer den Helden (59e.1)
	for k in 5:
		var r := wuerfle_seltenheit(w, stufe, 0, "UNCOMMON", max_normal(hw.kapitel))
		var g = fuer_held(hw, w, stufe, r) if k == 0 else null
		if g == null: g = erzeuge(w, 0, stufe, r)
		g["guete"] = 0
		g["uid"] = -(liste.size() + 1)
		liste.append(g)
	return liste

# Loot.forHero (59e.1): fuer den Platz, an dem er am schlechtesten ausgeruestet ist (leer zuerst), mit seinem hoechsten Grundwert
static func hauptwert(hw: BrsHeld) -> String:
	var best := "kraft"
	for g in BrsHeld.grundwerte():
		if hw.wert(g) > hw.wert(best): best = g
	return String(BrsHeld.AFFIX.get(best, BrsHeld.AFFIX["kraft"]))

static func fuer_held(hw: BrsHeld, w, stufe: int, seltenheit: String):
	var haupt := hauptwert(hw)
	var pool := func(slot: String) -> Array:
		var p: Array = []
		for id in grundformen():
			var b := grundform(id)
			if String(b["art"]) != "LIGHT" and String(b["slot"]) == slot and int(b["ab_stufe"]) <= stufe: p.append(id)
		return p
	var bester := ""
	var bestwert := 0
	for s in PLAETZE:
		if pool.call(s).is_empty(): continue
		var g = hw.ausruestung.get(s)
		var n: int = -1 if g == null else stufe_von(String(g["rarity"])) * 1000 + int(g["ilvl"])
		if bester == "" or n < bestwert:
			bester = s
			bestwert = n
	if bester == "": return null
	var formen: Array = pool.call(bester)
	var mit := formen.filter(func(id): return haupt in zusatz_fuer(id, seltenheit))
	if not mit.is_empty(): formen = mit
	var g := wuerfle(0, w.pick(formen), stufe, seltenheit, w)
	if not (haupt in zusatz_fuer(String(g["base"]), seltenheit)): return g
	for r in g["rolls"]:
		if String(r[0]) == haupt: return g
	var roll := [haupt, zusatz_wert(haupt, stufe)]
	if g["rolls"].is_empty(): g["rolls"].append(roll)
	else: g["rolls"][0] = roll
	return g

# ---------------------------------------------------------------- Gear.kt
# Gear.price, mit der Guete
static func preis(g: Dictionary) -> int:
	var r := r_()
	var mult := float(r["preis_faktor"].get(String(g["rarity"]), 1.0)) * float(r["guete_preis"][guete_von(g)])
	return int((int(grundform(String(g["base"]))["preis"]) + int(r["preis_grund_plus"])) * mult * (1 + int(g["ilvl"]) * float(r["preis_je_stufe"])))

# Gear.name in [sprache] (de, en); Einzelstuecke heissen wie im Gegenstandskatalog (870.15: Kroggs Pranken, Wehrmantel)
static func name(g: Dictionary, sprache: String = "") -> String:
	if sprache == "": sprache = Sprache.aktiv()
	var de := sprache == "de"
	if g.get("unique") != null and String(g["unique"]) != "" and String(g["unique"]) != "false":
		var k := Katalog.eintrag(String(g["unique"]))
		if k.has("name"): return String(k["name"][sprache])
		Sprache.lade()
		var e: Dictionary = Sprache.texte.get("einzelstuecke", {}).get(String(g["unique"]), {})
		return String(e["name"][sprache]) if e.has("name") else String(g["unique"])
	var b := grundform(String(g["base"]))
	var grund := String(b["de"] if de else b["en"])
	var endung := String(d_()["endungen"][String(b["geschlecht"])])
	var saat := int(g.get("name_seed", 0))
	var namen: Dictionary = d_()["namen"]
	match String(g["rarity"]):
		"COMMON": return grund
		"EPIC":
			var a: Dictionary = namen["episch1"][posmod(saat, namen["episch1"].size())]
			var z: Dictionary = namen["episch2"][posmod(_ganz_div(saat, 7), namen["episch2"].size())]
			return String(a[sprache]) + String(z[sprache])
		"DIVINE":
			var gott: Dictionary = namen["goetter"][posmod(saat, namen["goetter"].size())]
			return ("Göttlich%s %s %s" % [endung, grund, gott["de"]]) if de else ("Divine %s %s" % [grund, gott["en"]])
	var rolls: Array = (g["rolls"] as Array).filter(func(r): return d_()["affixdaten"].has(String(r[0])))
	var erster = d_()["affixdaten"][String(rolls[0][0])] if rolls.size() > 0 else null
	var zweiter = d_()["affixdaten"][String(rolls[1][0])] if rolls.size() > 1 else null
	var vor = null
	if erster != null:
		var eigen = d_().get("vorsilbe_fuer", {}).get("%s:%s" % [g["base"], rolls[0][0]])   # 399.1 Gear.PREFIX_FOR: „Geweihtes Heiligensymbol“
		vor = (String(eigen["de"] if eigen else erster["vor_de"]) + endung) if de else String(eigen["en"] if eigen else erster["vor_en"])
	var nach_von = zweiter if zweiter != null else (null if String(g["rarity"]) == "UNCOMMON" else erster)
	var nach = null
	if nach_von != null: nach = String(nach_von["nach_de"] if de else nach_von["nach_en"])
	if String(g["rarity"]) == "UNCOMMON" and saat % 2 == 0 and erster != null:
		return "%s %s" % [grund, erster["nach_de"] if de else erster["nach_en"]]
	if nach != null and vor != null and zweiter != null: return "%s %s %s" % [vor, grund, nach]
	if vor != null: return "%s %s" % [vor, grund]
	return grund

# Kotlin teilt ganze Zahlen zur Null hin
static func _ganz_div(a: int, b: int) -> int: return int(a / b) if a >= 0 else -int(-a / b)

# DiceExpr.label: „1W8+1“, englisch „1d8+1“; 944: nie mehr in einem Text des Spiels (nur Tests der alten Werte)
static func wuerfel_text(e: Array, plus: int, de: bool) -> String:
	var bonus := int(e[2]) + plus
	var b := ("+%d" % bonus) if bonus > 0 else (str(bonus) if bonus < 0 else "")
	return "%d%s%d%s" % [int(e[0]), "W" if de else "d", int(e[1]), b]

## Grundschaden einer Waffe nach dem BRS: Grundschaden ihrer Gruppe (werte.json „waffen“) mal Guete, gerundet; 0 ohne Waffe
static func schaden(g: Dictionary) -> int:
	var b := grundform(String(g["base"]))
	if not ist_waffe(b): return 0
	var wd: Dictionary = BrsHeld.lade()["waffen"].get(BrsHeld.fertigkeit_von(String(g["base"])), {})
	return Brs.runde(float(wd.get("schaden", 0)) * guete_faktor(g))

## Schadensart einer Waffe nach dem BRS (werte.json „waffen“ „typ“: schnitt, stich, wucht …), "" ohne
static func schadensart(g: Dictionary) -> String:
	var wd: Dictionary = BrsHeld.lade()["waffen"].get(BrsHeld.fertigkeit_von(String(g["base"])), {})
	return String(wd.get("typ", ""))

## Schutzwert eines Stuecks nach dem BRS mal Guete (Brustruestung, Schild), gerundet; 0 sonst
static func schutzwert(g: Dictionary) -> int:
	return Brs.runde(float(BrsHeld.schutzwert_von(String(g["base"]))) * guete_faktor(g))

# Gear.keyValue: die eine Zahl, die am meisten sagt; "" wenn keine ([870.14.ding.schaden], [870.14.kw.schutz])
static func kennwert(g: Dictionary, sprache: String = "") -> String:
	if sprache == "": sprache = Sprache.aktiv()
	var de := sprache == "de"
	var b := grundform(String(g["base"]))
	if ist_waffe(b):
		var art: Array = SCHADENSART.get(schadensart(g), ["", ""])
		return ("Schaden %d · %s" if de else "Damage %d · %s") % [schaden(g), art[0 if de else 1]]
	if (String(b["slot"]) == "CHEST" and int(b["ruestung"]) > 0) or String(b["art"]) == "SHIELD":
		return ("Schutzwert %d" if de else "Protection %d") % schutzwert(g)
	return ""

# Gear.listLine: die Zeile unter dem Namen in Tasche und Laden: was es ist (wenn der Name es nicht sagt), Guete, wo, die Zahl
static func listen_zeile(g: Dictionary, sprache: String = "") -> String:
	if sprache == "": sprache = Sprache.aktiv()
	var de := sprache == "de"
	var b := grundform(String(g["base"]))
	var art := String(b[sprache])
	var gezeigt := name(g, sprache)
	var teile: Array = []
	if not gezeigt.containsn(art): teile.append(art)
	if guete_von(g) > 0: teile.append(guete_name(guete_von(g), sprache))
	var wo := ""
	if ist_waffe(b) and bool(b["fern"]): wo = "Fernwaffe" if de else "Ranged weapon"
	elif ist_waffe(b): wo = "Waffe" if de else "Weapon"
	else: wo = String(d_()["plaetze"][String(b["slot"])][sprache])
	if not gezeigt.containsn(wo) and art.nocasecmp_to(wo) != 0: teile.append(wo)
	var k := kennwert(g, sprache)
	if k != "": teile.append(k)
	return " · ".join(teile)
