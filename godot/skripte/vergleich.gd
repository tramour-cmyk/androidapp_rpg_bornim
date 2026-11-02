class_name Vergleich
extends RefCounted
# 399.1 Vergleich mit dem Getragenen wie alt (GearCompare.kt): was das Anlegen eines Stuecks aendert, Zeile fuer Zeile (RK, Angriff,
# Schaden im Schnitt, TP, bei Zauberern Zauberangriff und ZP, Attribute, die Eigenschaften mit eigener Zeile); daraus das Urteil fuer
# den Pfeil in der Tasche (▲ besser, ▼ schlechter) und der Satz im Kasten. Am Helden aendert es nichts (rechnet an einer Abschrift).
# Noch nicht wie alt: der Hinweis, wenn eine Obergrenze des Kapitels einen Bonus schluckt.

const EIGENE := ["CRIT", "FIRE", "RADIANT", "LIFESTEAL", "RESIST", "POISON_HIT", "BLEED_HIT", "STUN_HIT", "TENACITY", "GOLD_FIND", "MAGIC_FIND", "XP"]

var ersetzt: Array = []
var zeilen: Array = []        # {wort, vorher, nachher, besser (1, -1, 0)}

static func schnitt(e: Array) -> float: return int(e[0]) * (int(e[1]) + 1) / 2.0 + int(e[2])

static func bild(h: Heldwerte) -> Dictionary:
	var b := {"rk": h.rk(), "angriff": h.angriff(), "schaden": h.schaden(), "tp": h.max_tp(), "zauber": h.zauberangriff(), "zp": h.max_zp(), "werte": {}, "eig": {}}
	for a in ["STR", "DEX", "CON", "INT", "WIS", "CHA"]: b["werte"][a] = h.wert(a)
	for a in EIGENE: b["eig"][a] = h.bonus(a)
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
	var zahl := func(wort: String, x: int, y: int, mit_vz := false) -> void:
		if x == y: return
		v.zeilen.append({"wort": wort, "vorher": vz.call(x) if mit_vz else str(x), "nachher": vz.call(y) if mit_vz else str(y), "besser": 1 if y > x else -1})
	zahl.call("Rüstungsklasse" if de else "Armor Class", a["rk"], b["rk"])
	zahl.call(Sprache.u("attack"), a["angriff"], b["angriff"], true)
	if a["schaden"] != b["schaden"]:
		var x := schnitt(a["schaden"]); var y := schnitt(b["schaden"])
		v.zeilen.append({"wort": Sprache.u("damage"), "vorher": Beute.wuerfel_text(a["schaden"], 0, de), "nachher": Beute.wuerfel_text(b["schaden"], 0, de),
			"besser": 0 if x == y else (1 if y > x else -1)})
	zahl.call("Trefferpunkte" if de else "Hit points", a["tp"], b["tp"])
	if bool(hw.klassendaten()["zauberer"]):
		zahl.call("Zauberangriff" if de else "Spell attack", a["zauber"], b["zauber"], true)
		zahl.call("Zauberpunkte" if de else "Spell points", a["zp"], b["zp"])
	var d := Heldwerte.lade()
	for at in a["werte"]: zahl.call(Sprache.t(d["attribute"][at]["name"]), a["werte"][at], b["werte"][at])
	for af in EIGENE:
		var x: int = a["eig"][af]; var y: int = b["eig"][af]
		if x == y: continue
		var f := func(n: int) -> String:
			if n == 0: return "–"
			if af == "CRIT": return ("ab %d" if de else "%d+") % (20 - n)
			return ("%d %%" % n) if bool(d["affixdaten"][af]["prozent"]) else "+%d" % n
		v.zeilen.append({"wort": Sprache.t(d["affixdaten"][af]["name"]), "vorher": f.call(x), "nachher": f.call(y), "besser": 1 if y > x else -1})
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
