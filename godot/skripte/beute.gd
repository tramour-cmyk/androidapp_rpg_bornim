class_name Beute
extends RefCounted
# 390 (Laden, Beute): Loot.kt Zeile fuer Zeile: Seltenheit, Affixe, Grundform, Thessas Ware (Loot.shopGear), was ein Kampf
# bringt (Loot.drops); dazu Gear.name und Gear.price. Ausruestung als Woerterbuch wie in heldwerte.gd:
# {uid, base, rarity, ilvl, plus, rolls: [[Affix, Wert], …], unique, name_seed}. Wuerfel: alles mit next_int, d, chance, pick,
# weighted (KotlinZufall, oder Jerrys regeln/wuerfel.gd plus weighted). Daten aus held.json (HeroExport).
# Gegenprobe: tests/beute_golden.gd gegen Loot.kt (Proben „laden“, „beute“).

const SELTENHEIT := ["COMMON", "UNCOMMON", "RARE", "VERY_RARE", "EPIC", "DIVINE"]
const GEWICHT := [560, 270, 115, 40, 12, 3]           # Loot.baseWeights, je Mille vor Magiefund
const PLAETZE := ["HEAD", "CHEST", "ARMS", "LEGS", "CLOAK", "AMULET", "RING", "MAIN_HAND", "OFF_HAND"]   # GearSlot.entries
const KAPITEL1_UNGEWOEHNLICH := 150                    # Loot.CHAPTER1_UNCOMMON
const WERTE := ["STR", "DEX", "CON", "INT", "WIS", "CHA"]

static func d_() -> Dictionary: return Heldwerte.lade()
static func grundform(id: String) -> Dictionary: return d_()["grundformen"][id]
static func stufe_von(r: String) -> int: return SELTENHEIT.find(r)
static func affixzahl(r: String) -> int: return int(d_()["seltenheiten"][r]["affixe"])

static func grundformen() -> Array:
	var out: Array = []
	for id in d_()["grundform_reihe"]: out.append(String(id))
	return out

static func min_ilvl(r: String) -> int:
	match r:
		"EPIC": return 3
		"DIVINE": return 5
	return 1

# Loot.rollRarity
static func wuerfle_seltenheit(w, ilvl: int, magiefund: int = 0, mindestens: String = "COMMON", hoechstens: String = "DIVINE") -> String:
	var mf := 1.0 + magiefund / 100.0
	var boden := mini(stufe_von(mindestens), stufe_von(hoechstens))
	var eintraege: Array = []
	for i in SELTENHEIT.size():
		if i < boden or i > stufe_von(hoechstens): continue
		if ilvl < min_ilvl(SELTENHEIT[i]) and i != boden: continue
		eintraege.append([SELTENHEIT[i], maxi(1, int(GEWICHT[i] * (1.0 if i == 0 else mf)))])
	return w.weighted(eintraege)

static func max_normal(kap: int) -> String:
	match kap:
		1: return "UNCOMMON"
		2: return "RARE"
		3: return "VERY_RARE"
	return "EPIC"

static func max_besonders(kap: int) -> String:
	match kap:
		1: return "RARE"
		2: return "VERY_RARE"
		3, 4: return "EPIC"
	return "DIVINE"

# Loot.rarityFor: Kapitel des Helden (Story.chapter), Magiefund mit Deckel (Hero.bonus)
static func seltenheit_fuer(hw: Heldwerte, w, ilvl: int, besonders: bool, boden: String = "COMMON") -> String:
	var mf := hw.bonus("MAGIC_FIND")
	if besonders: return wuerfle_seltenheit(w, ilvl, mf, boden, max_besonders(hw.kapitel))
	if hw.kapitel == 1:
		if hw.stufe < 2: return "COMMON"
		var ungew := int(KAPITEL1_UNGEWOEHNLICH * (1.0 + mf / 100.0))
		return "UNCOMMON" if w.d(1000) <= ungew else "COMMON"
	return wuerfle_seltenheit(w, ilvl, mf, boden, max_normal(hw.kapitel))

static func klasse(k: String) -> Dictionary: return d_()["klassen"][k]
static func ist_waffe(b: Dictionary) -> bool: return String(b["art"]) == "WEAPON"

# Loot.wearable
static func tragbar(k: String, b: Dictionary) -> bool:
	var kd := klasse(k)
	match String(b["art"]):
		"ARMOR":
			match String(b["gewicht"]):
				"NONE", "CLOTH": return true
				_: return String(b["gewicht"]) in kd["ruestung"]
		"SHIELD": return bool(kd["schilde"])
	return true

# Loot.proficient
static func geuebt(k: String, id: String) -> bool:
	var waffen = klasse(k)["waffen"]
	return not ist_waffe(grundform(id)) or waffen == null or id in waffen

# Loot.suits: kann [k] die Grundform gut brauchen
static func passt(k: String, id: String) -> bool:
	var b := grundform(id)
	var kd := klasse(k)
	match String(b["art"]):
		"JEWELRY": return true
		"ARMOR":
			if String(b["slot"]) == "CLOAK": return true
			if k == "WIZARD": return String(b["gewicht"]) == "CLOTH"
			return String(b["gewicht"]) != "CLOTH" and tragbar(k, b)
		"SHIELD": return bool(kd["schilde"])
		"FOCUS": return bool(kd["zauberer"])
		"LIGHT": return false
		"WEAPON": return geuebt(k, id) and (int(b["fokus"]) == 0 or bool(kd["zauberer"]))
	return false

# GearBases.affixesFor
static func affixe_fuer(id: String) -> Array:
	var b := grundform(id)
	var slot := String(b["slot"])
	var art := String(b["art"])
	if art == "WEAPON" and int(b["fokus"]) > 0: return ["INT", "WIS", "SPELL", "SP", "ATTACK", "DAMAGE", "FIRE", "CRIT", "STUN_HIT"]
	if art == "WEAPON": return ["STR", "DEX", "ATTACK", "DAMAGE", "CRIT", "FIRE", "RADIANT", "LIFESTEAL", "POISON_HIT", "BLEED_HIT", "STUN_HIT"]
	if art == "SHIELD": return ["AC", "HP", "RESIST", "CON", "STR"]
	if art == "LIGHT": return []
	if art == "FOCUS": return ["SPELL", "SP", "INT", "WIS", "CHA", "HP"]
	match slot:
		"HEAD": return WERTE + ["AC", "HP", "SP", "SPELL", "MAGIC_FIND", "XP"]
		"CHEST": return ["AC", "HP", "RESIST", "STR", "DEX", "CON", "TENACITY"]
		"ARMS": return ["STR", "DEX", "ATTACK", "DAMAGE", "CRIT", "AC", "LIFESTEAL", "BLEED_HIT", "POISON_HIT"]
		"LEGS": return ["DEX", "CON", "AC", "HP", "RESIST", "GOLD_FIND", "TENACITY"]
		"CLOAK": return ["AC", "RESIST", "DEX", "CHA", "HP", "MAGIC_FIND", "TENACITY"]
		"AMULET": return WERTE + ["SPELL", "HP", "SP", "XP", "MAGIC_FIND", "RESIST", "TENACITY"]
	return WERTE + ["ATTACK", "DAMAGE", "CRIT", "SPELL", "GOLD_FIND", "MAGIC_FIND", "LIFESTEAL", "SP"]

# Loot.generate: ein zufaelliges Stueck; fuer eine Klasse nur, was zu ihr passt (sonst alles)
static func erzeuge(w, uid: int, ilvl: int, seltenheit: String, fuer_klasse: String = "", slot: String = "") -> Dictionary:
	var stufe := maxi(ilvl, 1)
	var pool: Array = []
	for id in grundformen():
		var b := grundform(id)
		if String(b["art"]) != "LIGHT" and int(b["ab_stufe"]) <= stufe and (slot == "" or String(b["slot"]) == slot): pool.append(id)
	if fuer_klasse != "":
		var p := pool.filter(func(id): return passt(fuer_klasse, id))
		if not p.is_empty(): pool = p
	var id: String = w.pick(pool)
	return wuerfle(uid, id, stufe, seltenheit, w)

# Loot.roll
static func wuerfle(uid: int, id: String, ilvl: int, seltenheit: String, w) -> Dictionary:
	var b := grundform(id)
	var erlaubt := affixe_fuer(id)
	var rolls: Array = []
	if seltenheit == "DIVINE": rolls.append(["ALL_STATS", 1 + w.d(2) - 1 + ilvl / 8])
	while rolls.size() < affixzahl(seltenheit) and not erlaubt.is_empty():
		var a: String = w.pick(erlaubt)
		erlaubt.erase(a)
		rolls.append([a, wert(a, ilvl, seltenheit, w)])
	var verbesserbar := ist_waffe(b) or String(b["slot"]) == "CHEST" or String(b["art"]) == "SHIELD"
	var plus := 0
	if verbesserbar:
		match seltenheit:
			"RARE": plus = 1
			"VERY_RARE": plus = 1 + w.d(2) - 1
			"EPIC": plus = 2
			"DIVINE": plus = 3
	return {"uid": uid, "base": id, "rarity": seltenheit, "ilvl": ilvl, "plus": plus, "rolls": rolls, "unique": null, "name_seed": w.d(10000)}

# Loot.value: Staerke waechst mit der Gegenstandsstufe, episch und goettlich hoeher
static func wert(a: String, ilvl: int, seltenheit: String, w) -> int:
	var bis := func(n: int) -> int: return 0 if n <= 0 else w.d(n + 1) - 1
	var roh := 0
	match a:
		"STR", "DEX", "CON", "INT", "WIS", "CHA": roh = 1 + bis.call(ilvl / 4)
		"ALL_STATS": roh = 1
		"AC": roh = 1 + bis.call(ilvl / 6)
		"ATTACK": roh = 1 + bis.call(ilvl / 5)
		"DAMAGE": roh = 1 + bis.call(ilvl / 3)
		"SPELL": roh = 1 + bis.call(ilvl / 6)
		"HP": roh = 3 + bis.call(ilvl * 2)
		"SP": roh = 1 + bis.call(1 + ilvl / 2)
		"CRIT": roh = 1
		"FIRE", "RADIANT": roh = 1 + bis.call(1 + ilvl / 2)
		"LIFESTEAL": roh = 3 + bis.call(7)
		"RESIST": roh = 1 + bis.call(ilvl / 5)
		"GOLD_FIND": roh = 10 + bis.call(40)
		"MAGIC_FIND": roh = 5 + bis.call(25)
		"XP": roh = 5 + bis.call(15)
		"POISON_HIT", "BLEED_HIT": roh = 8 + bis.call(12)
		"STUN_HIT": roh = 5 + bis.call(8)
		"TENACITY": roh = 10 + bis.call(20)
	var schub := 1.25 if seltenheit == "EPIC" else (1.5 if seltenheit == "DIVINE" else 1.0)
	if schub == 1.0 or a == "CRIT": return roh
	return maxi(roh + 1, int(roh * schub))

# Loot.drops: was ein besiegtes Monster fallen laesst; [neue_uid] gibt die Kennung (GameState.nextUid)
static func beute(hw: Heldwerte, w, ilvl: int, boss: bool, elite: bool, neue_uid: Callable) -> Array:
	var seltenheiten: Array = []
	if boss:
		seltenheiten.append(seltenheit_fuer(hw, w, ilvl, true, "RARE"))
		for i in w.d(2): seltenheiten.append(seltenheit_fuer(hw, w, ilvl, false))
	elif elite:
		seltenheiten.append(seltenheit_fuer(hw, w, ilvl, true, "UNCOMMON"))
	elif w.chance(0.38):
		seltenheiten.append(seltenheit_fuer(hw, w, ilvl, false))
	# zwei Drittel fuer die Klasse des Helden
	var out: Array = []
	for r in seltenheiten:
		var k := hw.klasse if w.chance(0.67) else ""
		out.append(erzeuge_mit_uid(w, neue_uid, ilvl, r, k))
	return out

# generate zieht die Grundform vor der Kennung
static func erzeuge_mit_uid(w, neue_uid: Callable, ilvl: int, r: String, k: String) -> Dictionary:
	var g := erzeuge(w, 0, ilvl, r, k)
	g["uid"] = neue_uid.call()
	return g

# Loot.torch: eine schlichte Fackel (84.1)
static func fackel(uid: int) -> Dictionary:
	return {"uid": uid, "base": "torch", "rarity": "COMMON", "ilvl": 1, "plus": 0, "rolls": [], "unique": null, "name_seed": 0}

# Loot.shopGear: Thessas Ware; neu alle acht Siege und mit jeder Stufe (59e.3: bleibt sonst)
static func ladenware(hw: Heldwerte, siege: int) -> Array:
	var stufe := hw.stufe
	var w := KotlinZufall.new(KotlinZufall.s32(siege / 8 * 7919 + stufe * 31 + KotlinZufall.hash_code(hw.name)))
	var liste: Array = []
	# das Grundlegende jedes Platzes fuer die Klasse des Helden
	for slot in PLAETZE:
		var pool: Array = []
		for id in grundformen():
			var b := grundform(id)
			if String(b["slot"]) == slot and int(b["ab_stufe"]) <= stufe and passt(hw.klasse, id): pool.append(id)
		if not pool.is_empty(): liste.append(wuerfle(-(liste.size() + 1), w.pick(pool), stufe, "COMMON", w))
	# 84.1: immer eine schlichte Fackel
	liste.append(fackel(-(liste.size() + 1)))
	# eine Handvoll magischer Stuecke, das erste fuer den Helden (59e.1)
	for k in 5:
		var r := wuerfle_seltenheit(w, stufe, 0, "UNCOMMON", max_normal(hw.kapitel))
		var g = fuer_held(hw, w, stufe, r) if k == 0 else null
		if g == null: g = erzeuge(w, 0, stufe, r, hw.klasse)
		g["uid"] = -(liste.size() + 1)
		liste.append(g)
	return liste

# Loot.forHero (59e.1): fuer den Platz, an dem er am schlechtesten ausgeruestet ist (leer zuerst), mit dem Hauptwert seiner Klasse
static func fuer_held(hw: Heldwerte, w, stufe: int, seltenheit: String):
	var haupt := String(klasse(hw.klasse)["haupt"])
	var pool := func(slot: String) -> Array:
		var p: Array = []
		for id in grundformen():
			var b := grundform(id)
			if String(b["art"]) != "LIGHT" and String(b["slot"]) == slot and int(b["ab_stufe"]) <= stufe and passt(hw.klasse, id): p.append(id)
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
	var mit := formen.filter(func(id): return haupt in affixe_fuer(id))
	if not mit.is_empty(): formen = mit
	var g := wuerfle(0, w.pick(formen), stufe, seltenheit, w)
	if not (haupt in affixe_fuer(String(g["base"]))): return g
	for r in g["rolls"]:
		if String(r[0]) == haupt: return g
	var roll := [haupt, wert(haupt, stufe, seltenheit, w)]
	if g["rolls"].is_empty(): g["rolls"].append(roll)
	else: g["rolls"][0] = roll
	return g

# ---------------------------------------------------------------- Gear.kt
# Gear.price
static func preis(g: Dictionary) -> int:
	var mult := 1.0
	match String(g["rarity"]):
		"UNCOMMON": mult = 3.0
		"RARE": mult = 8.0
		"VERY_RARE": mult = 20.0
		"EPIC": mult = 50.0
		"DIVINE": mult = 150.0
	return int((int(grundform(String(g["base"]))["preis"]) + 10) * mult * (1 + int(g["ilvl"]) / 5.0))

# Gear.name in [sprache] (de, en)
static func name(g: Dictionary, sprache: String = "") -> String:
	if sprache == "": sprache = Sprache.aktiv()
	var de := sprache == "de"
	if g.get("unique") != null:
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
	var rolls: Array = g["rolls"]
	var erster = d_()["affixdaten"][String(rolls[0][0])] if rolls.size() > 0 else null
	var zweiter = d_()["affixdaten"][String(rolls[1][0])] if rolls.size() > 1 else null
	var vor = null
	if erster != null: vor = (String(erster["vor_de"]) + endung) if de else String(erster["vor_en"])
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

# DiceExpr.label: „1W8+1“, englisch „1d8+1“
static func wuerfel_text(e: Array, plus: int, de: bool) -> String:
	var bonus := int(e[2]) + plus
	var b := ("+%d" % bonus) if bonus > 0 else (str(bonus) if bonus < 0 else "")
	return "%d%s%d%s" % [int(e[0]), "W" if de else "d", int(e[1]), b]

# Gear.keyValue: die eine Zahl, die am meisten sagt; "" wenn keine
static func kennwert(g: Dictionary, sprache: String = "") -> String:
	if sprache == "": sprache = Sprache.aktiv()
	var de := sprache == "de"
	var b := grundform(String(g["base"]))
	var plus := int(g["plus"])
	if b["schaden"] != null:
		var t := wuerfel_text(b["schaden"], plus, de)
		if b["vielseitig"] != null: t += "/" + wuerfel_text(b["vielseitig"], plus, de)
		return t + " " + String(d_()["schadensarten"][String(b["schadensart"])][sprache])
	if String(b["slot"]) == "CHEST" and int(b["ruestung"]) > 0: return ("RK " if de else "AC ") + str(int(b["ruestung"]) + plus)
	if String(b["art"]) == "SHIELD": return ("RK +" if de else "AC +") + str(int(b["ruestung"]) + plus)
	if int(b["fokus"]) > 0: return ("Zauberkraft +" if de else "Spell power +") + str(int(b["fokus"]))
	return ""

# Gear.listLine: die Zeile unter dem Namen in Tasche und Laden: was es ist (wenn der Name es nicht sagt), wo, die Zahl
static func listen_zeile(g: Dictionary, sprache: String = "") -> String:
	if sprache == "": sprache = Sprache.aktiv()
	var de := sprache == "de"
	var b := grundform(String(g["base"]))
	var art := String(b[sprache])
	var gezeigt := name(g, sprache)
	var plus := int(g["plus"])
	var teile: Array = []
	if not gezeigt.containsn(art): teile.append(art + (" +%d" % plus if plus > 0 else ""))
	var wo := ""
	if ist_waffe(b) and bool(b["fern"]): wo = "Fernwaffe" if de else "Ranged weapon"
	elif ist_waffe(b): wo = "Waffe" if de else "Weapon"
	else: wo = String(d_()["plaetze"][String(b["slot"])][sprache])
	if not gezeigt.containsn(wo) and art.nocasecmp_to(wo) != 0: teile.append(wo)
	var k := kennwert(g, sprache)
	if k != "": teile.append(k)
	return " · ".join(teile)
