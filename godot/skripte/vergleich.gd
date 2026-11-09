class_name Vergleich
extends RefCounted
# 399.1 Vergleich mit dem Getragenen wie alt (GearCompare.kt): was das Anlegen eines Stuecks aendert, Zeile fuer Zeile (RK, Angriff,
# Schaden im Schnitt, TP, bei Zauberern Zauberangriff und ZP, Attribute, die Eigenschaften mit eigener Zeile); daraus das Urteil fuer
# den Pfeil in der Tasche (▲ besser, ▼ schlechter) und der Satz im Kasten. Am Helden aendert es nichts (rechnet an einer Abschrift).
# 519 (Zu 519, Sokrates: Ring „+1 alle Attribute, +2 Geschicklichkeit“, im Vergleich fehlte Geschicklichkeit): wie alt ein Hinweis
# („notiz“), wenn eine Obergrenze des Kapitels einen Bonus schluckt, und beim Schaden der Schnitt (GearCompare.kt 79–122).

const EIGENE := ["CRIT", "FIRE", "RADIANT", "LIFESTEAL", "RESIST", "POISON_HIT", "BLEED_HIT", "STUN_HIT", "TENACITY", "GOLD_FIND", "MAGIC_FIND", "XP"]

var ersetzt: Array = []
var zeilen: Array = []        # {wort, vorher, nachher, besser (1, -1, 0), notiz (fehlt oder Satz darunter)}

static func schnitt(e: Array) -> float: return int(e[0]) * (int(e[1]) + 1) / 2.0 + int(e[2])

static func bild(h: Heldwerte) -> Dictionary:
	var b := {"rk": h.rk(), "angriff": h.angriff(), "schaden": h.schaden(), "tp": h.max_tp(), "zauber": h.zauberangriff(), "zp": h.max_zp(),
		"werte": {}, "eig": {}, "roh": {}, "wirkt": {}, "ausr": {}}
	for a in ["STR", "DEX", "CON", "INT", "WIS", "CHA"]:
		b["werte"][a] = h.wert(a)
		b["ausr"][a] = h.ausruestungs_bonus(a)
	for a in EIGENE: b["eig"][a] = h.bonus(a)
	for a in Heldwerte.lade()["affixdaten"]:
		b["roh"][a] = h.roh_bonus(a)
		b["wirkt"][a] = h.bonus(a)
	return b

# wie GearCompare.of: hw bleibt, wie es ist
static func von(hw: Heldwerte, g: Dictionary, nebenhand := false) -> Vergleich:
	var v := Vergleich.new()
	var kopie := Heldwerte.aus_daten(hw.als_daten())
	var a := bild(kopie)
	var weg: Array = kopie.anlegen_nebenhand(g) if nebenhand else kopie.anlegen(g)
	var b := bild(kopie)
	v.ersetzt = weg.filter(func(x): return x.get("uid", -1) != g.get("uid", -2))
	var de := Sprache.aktiv() == "de"
	var vz := func(n: int) -> String: return ("+%d" % n) if n >= 0 else str(n)
	# GearCompare.capped: ein Bonus steigt roh, wirkt aber nicht mehr
	var gedeckelt := func(afs: Array) -> bool: return afs.any(func(af): return b["roh"][af] > a["roh"][af] and b["wirkt"][af] == a["wirkt"][af])
	var deckel := "Bonus wirkt nicht: Obergrenze für dieses Kapitel erreicht" if de else "Bonus has no effect: this chapter's limit is reached"
	var zahl := func(wort: String, x: int, y: int, mit_vz := false, notiz := "") -> void:
		if x == y and notiz == "": return
		var r := {"wort": wort, "vorher": vz.call(x) if mit_vz else str(x), "nachher": vz.call(y) if mit_vz else str(y), "besser": 0 if x == y else (1 if y > x else -1)}
		if notiz != "": r["notiz"] = notiz
		v.zeilen.append(r)
	var falls := func(gleich: bool, afs: Array) -> String: return deckel if gleich and gedeckelt.call(afs) else ""
	zahl.call("Rüstungsklasse" if de else "Armor Class", a["rk"], b["rk"], false, falls.call(a["rk"] == b["rk"], ["AC"]))
	zahl.call(Sprache.u("attack"), a["angriff"], b["angriff"], true, falls.call(a["angriff"] == b["angriff"], ["ATTACK"]))
	if a["schaden"] != b["schaden"]:
		var x := schnitt(a["schaden"]); var y := schnitt(b["schaden"])
		var eins := func(n: float) -> String:
			var t := str(int(n)) if is_equal_approx(n, roundf(n)) else "%.1f" % n
			return t.replace(".", ",") if de else t
		v.zeilen.append({"wort": Sprache.u("damage"), "vorher": Beute.wuerfel_text(a["schaden"], 0, de), "nachher": Beute.wuerfel_text(b["schaden"], 0, de),
			"besser": 0 if x == y else (1 if y > x else -1), "notiz": ("im Schnitt %s statt %s" if de else "on average %s instead of %s") % [eins.call(y), eins.call(x)]})
	elif gedeckelt.call(["DAMAGE", "FIRE", "RADIANT"]):
		v.zeilen.append({"wort": Sprache.u("damage"), "vorher": Beute.wuerfel_text(a["schaden"], 0, de), "nachher": Beute.wuerfel_text(b["schaden"], 0, de), "besser": 0, "notiz": deckel})
	zahl.call("Trefferpunkte" if de else "Hit points", a["tp"], b["tp"], false, falls.call(a["tp"] == b["tp"], ["HP"]))
	if bool(hw.klassendaten()["zauberer"]):
		zahl.call("Zauberangriff" if de else "Spell attack", a["zauber"], b["zauber"], true, falls.call(a["zauber"] == b["zauber"], ["SPELL"]))
		zahl.call("Zauberpunkte" if de else "Spell points", a["zp"], b["zp"])
	var d := Heldwerte.lade()
	# Attribute: was aus den Werten wird. 557 (Chef 04.11., 19:54; Pruefer 19:47: Ring „+1 alle, +2 GES“ gegen angelegt „+2 GES, +2 STAE“,
	# im Vergleich fehlten Geschicklichkeit und Staerke): jedes Attribut, dessen Bonus sich aendert, hat seine eigene Zeile, auch wenn die
	# Obergrenze des Kapitels den Wert haelt (vorher eine Sammelzeile „Attribute“ nur fuer gestiegene); darunter warum er gleich bleibt
	var gleich_mehr := "mehr Bonus, wirkt nicht: Obergrenze für dieses Kapitel erreicht" if de else "more bonus, no effect: this chapter's limit is reached"
	var gleich_weniger := "weniger Bonus, Wert bleibt: Obergrenze für dieses Kapitel" if de else "less bonus, same value: this chapter's limit"
	for at in a["werte"]:
		var r0: int = a["roh"][at] + a["roh"]["ALL_STATS"]
		var r1: int = b["roh"][at] + b["roh"]["ALL_STATS"]
		var notiz := ""
		if a["werte"][at] == b["werte"][at] and r1 != r0: notiz = gleich_mehr if r1 > r0 else gleich_weniger
		zahl.call(Sprache.t(d["attribute"][at]["name"]), a["werte"][at], b["werte"][at], false, notiz)
	for af in EIGENE:
		var x: int = a["eig"][af]; var y: int = b["eig"][af]
		var geschluckt: bool = b["roh"][af] > a["roh"][af] and x == y
		if x == y and not geschluckt: continue
		var f := func(n: int) -> String:
			if n == 0: return "–"
			if af == "CRIT": return ("ab %d" if de else "%d+") % (20 - n)
			return ("%d %%" % n) if bool(d["affixdaten"][af]["prozent"]) else "+%d" % n
		var r := {"wort": Sprache.t(d["affixdaten"][af]["name"]), "vorher": f.call(x), "nachher": f.call(y), "besser": 0 if x == y else (1 if y > x else -1)}
		if geschluckt: r["notiz"] = deckel
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
# Fuer ALL_STATS gilt das Kleinste ueber alle Attribute, „teils“ (-1), wenn die Attribute verschieden viel bekommen.
static func wirkung(hw: Heldwerte, g: Dictionary) -> Dictionary:
	var mit := Heldwerte.aus_daten(hw.als_daten())
	if not mit.ausruestung.values().any(func(x): return x != null and int(x["uid"]) == int(g["uid"])): mit.anlegen(g)
	var ohne := Heldwerte.aus_daten(mit.als_daten())
	for p in ohne.ausruestung.keys():
		if int(ohne.ausruestung[p]["uid"]) == int(g["uid"]): ohne.ablegen(p); break
	var at_mehr := {}
	for at in Heldwerte.ATTRIBUTE: at_mehr[at] = mit.ausruestungs_bonus(at) - ohne.ausruestungs_bonus(at)
	var r := {}
	for roll in g.get("rolls", []):
		var a := String(roll[0]); var w := int(roll[1])
		if a in Heldwerte.ATTRIBUTE:
			r[a] = [w, clampi(at_mehr[a], 0, w)]
			at_mehr[a] = maxi(0, at_mehr[a] - w)   # der eigene Bonus zuerst, der Rest gehoert ALL_STATS
		elif a != "ALL_STATS":
			r[a] = [w, clampi(mit.bonus(a) - ohne.bonus(a), 0, w)]
	for roll in g.get("rolls", []):
		if String(roll[0]) != "ALL_STATS": continue
		var w := int(roll[1])
		var je := Heldwerte.ATTRIBUTE.map(func(at): return clampi(at_mehr[at], 0, w))
		r["ALL_STATS"] = [w, je.min(), je.max()]   # wirkt bei jedem Attribut von … bis
	return r
