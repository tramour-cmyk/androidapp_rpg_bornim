class_name Vergleich
extends RefCounted
# 399.1 Vergleich mit dem Getragenen wie alt (GearCompare.kt): was das Anlegen eines Stuecks aendert, Zeile fuer Zeile; daraus das
# Urteil fuer den Pfeil in der Tasche (▲ besser, ▼ schlechter) und der Satz im Kasten. Am Helden aendert es nichts (rechnet an einer
# Abschrift). 870.4 (LISTE-UMZUG-BRS.md Schritt 4): nach BRS-Werten: Schutzwert, Schaden als Zahl, Leben, Mana, Kritisch in Prozent, die
# Grundwerte, dazu die Eigenschaften mit eigener Zeile; Feinschliff 870.7.

const EIGENE := ["CRIT", "FIRE", "RADIANT", "LIFESTEAL", "RESIST", "POISON_HIT", "BLEED_HIT", "STUN_HIT", "TENACITY", "GOLD_FIND", "MAGIC_FIND", "XP"]

var ersetzt: Array = []
var zeilen: Array = []        # {wort, vorher, nachher, besser (1, -1, 0), notiz (fehlt oder Satz darunter)}

static func bild(h: BrsHeld) -> Dictionary:
	var b := {"schutz": h.schutzwert(), "schaden": h.schaden(), "leben": h.max_leben(), "mana": h.max_mana(), "krit": h.krit_prozent(),
		"werte": h.werte(), "eig": {}, "roh": {}, "wirkt": {}}
	for a in EIGENE: b["eig"][a] = h.bonus(a)
	for a in BrsHeld.daten()["affixdaten"]:
		b["roh"][a] = h.roh_bonus(a)
		b["wirkt"][a] = h.bonus(a)
	return b

# wie GearCompare.of: hw bleibt, wie es ist
static func von(hw: BrsHeld, g: Dictionary, nebenhand := false) -> Vergleich:
	var v := Vergleich.new()
	var kopie := hw.kopie()
	var a := bild(kopie)
	var weg: Array = kopie.anlegen_nebenhand(g) if nebenhand else kopie.anlegen(g)
	var b := bild(kopie)
	v.ersetzt = weg.filter(func(x): return x.get("uid", -1) != g.get("uid", -2))
	var de := Sprache.aktiv() == "de"
	var deckel := "Bonus wirkt nicht: Obergrenze für dieses Kapitel erreicht" if de else "Bonus has no effect: this chapter's limit is reached"
	var zahl := func(wort: String, x: int, y: int, prozent := false) -> void:
		if x == y: return
		var f := func(n: int) -> String: return ("%d %%" % n) if prozent else str(n)
		v.zeilen.append({"wort": wort, "vorher": f.call(x), "nachher": f.call(y), "besser": 1 if y > x else -1})
	zahl.call("Schutzwert" if de else "Protection", a["schutz"], b["schutz"])
	zahl.call(Sprache.u("damage"), a["schaden"], b["schaden"])
	zahl.call("Leben" if de else "Life", a["leben"], b["leben"])
	zahl.call("Mana", a["mana"], b["mana"])
	zahl.call("Kritisch" if de else "Critical", a["krit"], b["krit"], true)
	# 557, 701: jeder Grundwert, dessen Wert sich aendert, hat seine Zeile; ein Mehr, das die Obergrenze des Kapitels schluckt, steht
	# in einer Sammelzeile mit den Namen (im Fenster B faellt sie weg, „doppelt“: dort sagt es die Bonuszeile)
	var mehr: Array = []
	for g_ in BrsHeld.grundwerte():
		var af := String(BrsHeld.AFFIX[g_])
		var r0: int = a["roh"][af] + a["roh"]["ALL_STATS"]
		var r1: int = b["roh"][af] + b["roh"]["ALL_STATS"]
		var name_ := ErschaffungBrs.tx(ErschaffungBrs.GRUNDWERT[g_])
		if int(a["werte"][g_]) == int(b["werte"][g_]) and r1 > r0: mehr.append(name_)
		else: zahl.call(name_, int(a["werte"][g_]), int(b["werte"][g_]))
	if not mehr.is_empty():
		var namen := ("Alle Grundwerte" if de else "All attributes") if mehr.size() == BrsHeld.grundwerte().size() else ", ".join(PackedStringArray(mehr))
		v.zeilen.append({"wort": "Grundwerte" if de else "Attributes", "vorher": "", "nachher": "", "besser": 0, "doppelt": true,
			"notiz": namen + (": Bonus wirkt nicht, Obergrenze für dieses Kapitel erreicht" if de else ": no effect, this chapter's limit is reached")})
	var d := BrsHeld.daten()
	for af in EIGENE:
		var x: int = a["eig"][af]; var y: int = b["eig"][af]
		var geschluckt: bool = b["roh"][af] > a["roh"][af] and x == y
		if x == y and not geschluckt: continue
		var f := func(n: int) -> String:
			if n == 0: return "–"
			return ("%d %%" % n) if bool(d["affixdaten"][af]["prozent"]) or af == "CRIT" else "+%d" % n
		var r := {"wort": Sprache.t(d["affixdaten"][af]["name"]), "vorher": f.call(x), "nachher": f.call(y), "besser": 0 if x == y else (1 if y > x else -1)}
		if geschluckt: r["notiz"] = deckel
		if geschluckt and x == y: r["doppelt"] = true
		v.zeilen.append(r)
	return v

# +1 besser, -1 schlechter, 0 gemischt, null aendert nichts
func urteil():
	var auf := zeilen.any(func(z): return z["besser"] == 1)
	var ab := zeilen.any(func(z): return z["besser"] == -1)
	if auf and ab: return 0
	if auf: return 1
	if ab: return -1
	return null

func satz() -> String:
	var de := Sprache.aktiv() == "de"
	var liste := func(xs: Array) -> String:
		return ", ".join(PackedStringArray(xs.slice(0, 3))) + ((" und mehr" if de else " and more") if xs.size() > 3 else "")
	var plus := zeilen.filter(func(z): return z["besser"] == 1).map(func(z): return z["wort"])
	var minus := zeilen.filter(func(z): return z["besser"] == -1).map(func(z): return z["wort"])
	match urteil():
		1: return ("Besser: " if de else "Better: ") + liste.call(plus) + "."
		-1: return ("Schlechter: " if de else "Worse: ") + liste.call(minus) + "."
		0: return ("Gemischt: mehr " if de else "Mixed: more ") + liste.call(plus) + (", aber weniger " if de else ", but less ") + liste.call(minus) + "."
	return "Bringt nichts, was du nicht schon hast." if de else "Adds nothing you don't already have."

# 557/524.1 (Chef 04.11., 13:32): was jeder Bonus eines Stuecks am Helden wirklich bringt, mit allem anderen, was er traegt: [Bonus, wirkt].
# Gerechnet an zwei Abschriften (mit dem Stueck, ohne es); die Obergrenze des Kapitels kann einen Bonus ganz oder zum Teil schlucken.
# Fuer ALL_STATS gilt das Kleinste ueber alle Grundwerte, „teils“, wenn die Grundwerte verschieden viel bekommen (870.4: nach BRS).
static func wirkung(hw: BrsHeld, g: Dictionary) -> Dictionary:
	var mit := hw.kopie()
	if not mit.ausruestung.values().any(func(x): return x != null and int(x["uid"]) == int(g["uid"])): mit.anlegen(g)
	var ohne := mit.kopie()
	for p in ohne.ausruestung.keys():
		if int(ohne.ausruestung[p]["uid"]) == int(g["uid"]): ohne.ablegen(p); break
	var at_mehr := {}
	for gw in BrsHeld.AFFIX: at_mehr[BrsHeld.AFFIX[gw]] = mit.ausruestungs_bonus(gw) - ohne.ausruestungs_bonus(gw)
	var r := {}
	for roll in g.get("rolls", []):
		var a := String(roll[0]); var w := int(roll[1])
		if at_mehr.has(a):
			r[a] = [w, clampi(at_mehr[a], 0, w)]
			at_mehr[a] = maxi(0, at_mehr[a] - w)   # der eigene Bonus zuerst, der Rest gehoert ALL_STATS
		elif a != "ALL_STATS":
			r[a] = [w, clampi(mit.bonus(a) - ohne.bonus(a), 0, w)]
	for roll in g.get("rolls", []):
		if String(roll[0]) != "ALL_STATS": continue
		var w := int(roll[1])
		var je: Array = at_mehr.values().map(func(x): return clampi(int(x), 0, w))
		r["ALL_STATS"] = [w, je.min(), je.max()]   # wirkt bei jedem Grundwert von … bis
	return r
