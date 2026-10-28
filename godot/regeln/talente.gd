# 390 (core Perks.kt): was jedes Attribut für jeden Helden tut, über die Grundlagen der Klasse hinaus (Angriff, Rüstungsklasse,
# Trefferpunkte, Zauber). Kleine Wirkungen, die mit dem Modifikator wachsen: kein Attribut ist tot, keines kippt die Balance.
# Der Held [h] ist jeder mit mod(a), wert(a) und klasse wie Toms Heldwerte (godot/skripte/heldwerte.gd); a = „STR“, „DEX“ …
extends RefCounted


static func _plus(h, a: String) -> int:
	return maxi(0, int(h.mod(a)))


# ---------------------------------------------------------------- Charisma: Handeln und Auftreten

## Preisfaktor beim Kaufen: je Punkt 5 % billiger, höchstens 20 % (teurer mit negativem Modifikator).
static func buy_factor(h) -> float:
	return 1.0 - 0.05 * clampi(int(h.mod("CHA")), -4, 4)


## Preisfaktor beim Verkaufen: je Punkt 5 % mehr, höchstens 20 %.
static func sell_factor(h) -> float:
	return 1.0 + 0.05 * clampi(int(h.mod("CHA")), -4, 4)


static func buy_price(h, base: int) -> int:
	return maxi(1, roundi(base * buy_factor(h)))


static func sell_price(h, base: int) -> int:
	return maxi(1, roundi(base * sell_factor(h)))


## Chance, dass ein gewöhnlicher Gegner eingeschüchtert zögert und seine erste Runde verliert.
static func cow_chance(h) -> float:
	return 0.08 * _plus(h, "CHA")


# ---------------------------------------------------------------- Intelligenz: Wissen

## Ab INT 12 erkennt der Held Schwächen und Resistenzen eines Gegners.
static func knows_weaknesses(h) -> bool:
	return int(h.mod("INT")) >= 1


## Chance je Punkt, dass Morwens Sud einen Trank mehr ergibt.
static func extra_brew_chance(h) -> float:
	return 0.10 * _plus(h, "INT")


## Faktor der Erfahrung: je Punkt 3 % mehr.
static func xp_factor(h) -> float:
	return 1.0 + 0.03 * _plus(h, "INT")


# ---------------------------------------------------------------- Weisheit: Wahrnehmung

## Mehr Sicht im Nebel in Feldern: je Punkt ein halbes Feld.
static func sight_bonus(h) -> float:
	return 0.5 * _plus(h, "WIS")


## Faktor auf die Chance eines Hinterhalts: je Punkt 15 % weniger, bis 40 %.
static func ambush_factor(h) -> float:
	return maxf(0.4, 1.0 - 0.15 * _plus(h, "WIS"))


## Chance je Punkt auf ein Kraut mehr beim Pflücken.
static func extra_herb_chance(h) -> float:
	return 0.15 * _plus(h, "WIS")


# ---------------------------------------------------------------- Stärke: Kraft

## Mehr Schaden geworfener Flaschen (Alchemistenfeuer, Weihwasser).
static func throw_bonus(h) -> int:
	return _plus(h, "STR")


# ---------------------------------------------------------------- Geschicklichkeit: Schleichen

## Wie nah ein jagendes Monster kommen muss, um den Helden zu bemerken: je zwei Punkte ein Feld weniger, mindestens 2.
static func notice_range(h, base := 4) -> int:
	return maxi(2, base - _plus(h, "DEX") / 2)


# ---------------------------------------------------------------- Konstitution: Zähigkeit

## Gift und Blutung aus einem Kampf klingen so viele Runden früher ab.
static func ailment_shortening(h) -> int:
	return _plus(h, "CON")


## Mehr TP aus einer Mahlzeit.
static func meal_bonus(h) -> int:
	return _plus(h, "CON")


# ---------------------------------------------------------------- Erklärungen für den Reiter „Held“

static func signed(n: int) -> String:
	return "+%d" % n if n >= 0 else "%d" % n


static func _pct(x: float) -> String:
	return "%d %%" % roundi(x * 100.0)


static func _num(x: float, de: bool) -> String:
	var s := "%.1f" % x
	return s.replace(".", ",") if de else s


## Was [a] für diesen Helden tut, Zeile für Zeile, mit den heutigen Zahlen; [lang] 0 Deutsch, 1 Englisch (wie mars.gd).
static func describe(a: String, h, lang: int) -> Array:
	var de := lang == 0
	var m: int = int(h.mod(a))
	var p := maxi(0, m)
	var lines := []
	lines.append(("Wert %d, Modifikator " if de else "Score %d, modifier ") % int(h.wert(a)) + signed(m))
	match a:
		"STR":
			lines.append("• Treffer und Schaden mit Nahkampfwaffen (außer Finesse-Waffen, wenn GES höher ist)." if de else "• Attack and damage rolls with melee weapons (except finesse weapons if DEX is higher).")
			lines.append("• Rettungswurf gegen Umwerfen, z. B. durch Wölfe." if de else "• Saving throw against being knocked prone, e.g. by wolves.")
			lines.append(("• Wurfgeschosse (Alchemistenfeuer, Weihwasser): +%d Schaden." if de else "• Thrown flasks (alchemist's fire, holy water): +%d damage.") % p)
		"DEX":
			lines.append("• Rüstungsklasse ohne, mit leichter und (bis +2) mittlerer Rüstung." if de else "• Armor Class without armor, with light and (up to +2) medium armor.")
			lines.append("• Treffer und Schaden mit Fernkampf- und Finesse-Waffen." if de else "• Attack and damage rolls with ranged and finesse weapons.")
			lines.append("• Initiative und Fluchtchance; Rettungswurf gegen Netze." if de else "• Initiative and chance to flee; saving throw against webs.")
			lines.append(("• Schleichen: Jagende Monster bemerken dich erst ab %d Feldern (normal 4)." if de else "• Stealth: hunting monsters only notice you within %d tiles (normally 4).") % notice_range(h))
		"CON":
			lines.append("• Trefferpunkte pro Stufe." if de else "• Hit points per level.")
			lines.append("• Rettungswürfe gegen Gift, Lähmung und ähnliche Zustände." if de else "• Saving throws against poison, paralysis and similar conditions.")
			lines.append(("• Gift und Blutung klingen nach dem Kampf %d Runden schneller ab." if de else "• Poison and bleeding wear off %d rounds sooner after a fight.") % p)
			lines.append(("• Mahlzeiten heilen +%d TP." if de else "• Meals heal +%d HP.") % p)
		"INT":
			if str(h.klasse) == "WIZARD":
				lines.append("• Magier: Zauberangriff und Zauber-Schwierigkeitsgrad." if de else "• Wizard: spell attack and spell save DC.")
			if de:
				lines.append("• Wissen: " + ("Du erkennst Schwächen und Resistenzen deiner Gegner." if knows_weaknesses(h) else "Ab INT 12 erkennst du Schwächen und Resistenzen deiner Gegner."))
			else:
				lines.append("• Knowledge: " + ("You recognize your foes' weaknesses and resistances." if knows_weaknesses(h) else "At INT 12 or higher, you recognize your foes' weaknesses and resistances."))
			lines.append(("• Alchemie: %s Chance auf einen zusätzlichen Trank beim Brauen." if de else "• Alchemy: %s chance of an extra potion when brewing.") % _pct(extra_brew_chance(h)))
			lines.append(("• Lernen: +%s Erfahrung." if de else "• Learning: +%s experience.") % _pct(xp_factor(h) - 1.0))
		"WIS":
			if str(h.klasse) == "CLERIC":
				lines.append("• Kleriker: Zauberangriff, Zauber-SG, Heilung und Spirituelle Waffe." if de else "• Cleric: spell attack, spell save DC, healing and Spiritual Weapon.")
			lines.append("• Rettungswurf gegen Flüche." if de else "• Saving throw against curses.")
			lines.append(("• Wahrnehmung: +%s Felder Sicht im Nebel, %s seltener Hinterhalte." if de else "• Perception: +%s tiles of sight in the fog, %s fewer ambushes.") % [_num(sight_bonus(h), de), _pct(1.0 - ambush_factor(h))])
			lines.append(("• Kräuterkunde: %s Chance auf ein zusätzliches Kraut beim Pflücken." if de else "• Herb lore: %s chance of an extra herb when picking.") % _pct(extra_herb_chance(h)))
		"CHA":
			var buy := roundi((1.0 - buy_factor(h)) * 100.0)
			if de:
				lines.append("• Handeln: " + ("%d %% günstiger einkaufen und %d %% teurer verkaufen." % [buy, buy] if buy >= 0 else "%d %% teurer einkaufen und %d %% billiger verkaufen." % [-buy, -buy]))
			else:
				lines.append("• Trading: " + ("buy for %d%% less and sell for %d%% more." % [buy, buy] if buy >= 0 else "buy for %d%% more and sell for %d%% less." % [-buy, -buy]))
			lines.append(("• Auftreten: %s Chance, dass ein normaler Gegner eingeschüchtert zögert und seine erste Runde verliert." if de else "• Presence: %s chance that an ordinary foe hesitates, cowed, and loses its first round.") % _pct(cow_chance(h)))
	return lines
