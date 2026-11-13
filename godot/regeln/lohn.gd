# 870.5 (Umzug BRS Schritt 5): was ein gewonnener Kampf bringt, nach dem BRS (DESIGN-BRS.md 4, Modell D): Erfahrung je Gegner
# (Brs.erfahrung: 10 × Stufe², Boss × 3, Faktor nach Stufenunterschied), Begleiter ohne eigene Art (Jungwolf, Leibwache) mit
# einem Anteil ihres Anführers (werte.json „merkmale“ „rudel“ „erfahrung_anteil“), gutgeschrieben über Brs.gib_erfahrung
# (Erfahrungstopf je Gebiet, weiche Kapitelgrenze, Aufstieg). Gold und Beute wie bisher vom Anführer (Umbau mit 870.6).
# Texte: STORY-BRS-KAMPF.md „Lohn nach dem Kampf“ [870.14.lohn.*].
extends RefCounted

const GAIN_XP := ["{0} erhält {1} EP.", "{0} gains {1} XP."]     # [870.14.lohn.ep]
const GAIN_GOLD := ["Du erbeutest {0} Gold.", "You take {0} gold."]     # [870.14.lohn.gold]
const LOOT := ["Beute: {0}!", "Loot: {0}!"]
const GEAR_LOOT := ["Beute: {0} ({1})!", "Loot: {0} ({1})!"]
const LEVEL_UP := ["{0} erreicht Heldenstufe {1}!", "{0} reaches Hero Level {1}!"]     # [870.14.lohn.stufe]
const GRENZE := ["Die Grenze von Kapitel 1 ist erreicht. Erfahrung gibt es nur noch zu einem Viertel; Beute und Ausrüstung wie bisher.",
	"You have reached the limit of Chapter 1. From now on you gain only a quarter of the experience; loot and gear drop as before."]     # [870.14.lohn.grenze]
const ENDE := ["Weiter trägt dich Kapitel 1 nicht. Erfahrung gibt es keine mehr; Beute und Ausrüstung wie bisher.",
	"Chapter 1 can take you no further. You gain no more experience; loot and gear drop as before."]     # [870.14.lohn.ende]
const TOPF := ["Hier hast du gelernt, was es zu lernen gab. Die Gegner dieser Gegend lehren dich kaum noch etwas.",
	"You have learned what there is to learn here. The foes of these parts teach you little now."]     # [870.14.lohn.topf]
# 1034 (Chef 12.11., 15:04, Siegfenster des Probekampfs: „Probe erhält 1404 EP … erreicht Heldenstufe 4, 5, 6“, obwohl nichts in den
# Spielstand geht): mit dem Testhelden steht das zuerst da (Testmenü, kein Spieltext)
const PROBE := ["Probekampf ohne Folgen: nichts davon geht in den Spielstand.", "Trial fight without consequences: none of this goes into the save."]
# 1096 (Chef 13.11., 07:55: „Siegfenster so kürzen“): mit dem Testhelden statt EP, Gold, Stufen, Grenze und Heilsatz nur grau, was ein
# echter Kampf brächte; die Beute bleibt (Testmenü, kein Spieltext)
const ECHT := ["Ein echter Kampf brächte: {0}", "A real fight would bring: {0}"]
const ECHT_EP := ["{0} EP", "{0} XP"]
const ECHT_GOLD := ["{0} Gold", "{0} gold"]
const RESTORED := ["Leben und Mana von {0} sind wieder voll.", "{0}'s life and mana are full again."]     # [870.14.lohn.voll]


## Erfahrung des Siegs für einen Helden der Heldenstufe [stufe], vor Topf und Grenze: jeder besiegte Gegner mit eigener Art
## nach Brs.erfahrung, jeder Begleiter (monster „rudel“) mit erfahrung_anteil × Erfahrung seines Anführers; Gerufene zählen nicht.
## Zurück {menge, boss}: boss, wenn ein Boss dabei ist (dann nicht aus dem Topf, DESIGN-BRS.md 4).
static func erfahrung_des_siegs(mars, stufe: int) -> Dictionary:
	var menge := 0.0
	var boss := false
	for f in mars.all:
		if f.side != "FOES" or f.monster == null or f.called_in:
			continue
		var m: Dictionary = f.monster
		if m.has("rudel"):
			var r = Brs.lade().get("merkmale", {}).get("rudel", {}).get(String(m.rudel), {})
			var anteil: float = float(r.get("erfahrung_anteil", 0.0)) if r is Dictionary else 0.0
			menge += anteil * Brs.erfahrung(stufe, String(m.get("anfuehrer", "")))
			continue
		var id := String(m.get("id", ""))
		menge += Brs.erfahrung(stufe, id)
		boss = boss or Brs.boss(id)
	return {"menge": menge, "boss": boss}


## Der Lohn des gewonnenen Kampfs [mars] für seinen Helden (der erste der Gruppe): [stand] die Heldenstufe nach BRS
## (Brs.neuer_stand: stufe, ep, ep_fert, toepfe), [gebiet] das Gebiet des Kampfs nach werte.json („Wald“, „Tiefer Wald“,
## „Höhle“; "" ohne Topf). [gear]: Ausrüstung, die die Welt für diesen Sieg gewürfelt hat (skripte/beute.gd), je {gear, name,
## rarity}, nach den Gegenständen genannt. [probe] (1034, Testheld): zuerst die Zeile PROBE, keine Schlüsseldinge (texte.json
## „dinge“ art KEY) als Beute; 1096: dann grau ECHT mit EP und Gold, die Beute, sonst nichts (keine Stufen, Grenze, Heilsatz).
## Zurück {xp, gold, items, gear, level, levels, stand, lines, grau}; grau: Nummern der Zeilen, die grau stehen; [stand] selbst bleibt
## unverändert, der neue Stand steht in „stand“, die Welt schreibt ihn gut. Leerer [stand]: Anfang der Stufe des Kämpfers.
static func reward(mars, stand: Dictionary, dice, gebiet := "", gear := [], probe := false) -> Dictionary:
	assert(mars.outcome == "WON")
	var hero = mars.all[0]
	var h: Dictionary = stand.duplicate(true)
	if h.is_empty():     # ohne Stand (Proben, Tests): am Anfang der Stufe des Kämpfers
		h = Brs.neuer_stand()
		h["stufe"] = clampi(int(hero.level()), 1, Brs.hoechste_stufe())
	if not h.has("toepfe"):
		h["toepfe"] = {}
	var lang: int = mars.lang
	var name: String = hero.name(lang)
	var vorher := int(h["stufe"])
	var kein_lohn := bool(mars.get("kein_lohn"))     # 870.5 Gegenwirkung Wolf: das Rudel floh vor dem Feuer
	var sieg := erfahrung_des_siegs(mars, vorher)
	var roh: float = 0.0 if kein_lohn else float(sieg.menge)
	var rest_vorher: float = float(h["toepfe"].get(gebiet, Brs.topf_voll(gebiet))) if gebiet != "" else 0.0
	var r := Brs.gib_erfahrung(h, roh, "kampf", gebiet, bool(sieg.boss))
	var nachher := int(h["stufe"])
	# Gold und Gegenstände vom Anführer (dem wertvollsten Gegner), wie bisher
	# 841: ein verjagter Späher bringt Erfahrung wie ein Sieg über ihn, aber keine Beute (STORY-K1-FERTIGKEITEN.md)
	var foes: Array = mars.all.filter(func(f): return f.side == "FOES" and f.monster != null and not f.called_in and not f.get("verjagt"))
	var gold := 0
	var items: Array = []
	if not foes.is_empty() and not kein_lohn:
		var leader = foes[0]
		for f in foes:
			if Brs.erfahrung(vorher, String(f.monster.get("id", ""))) > Brs.erfahrung(vorher, String(leader.monster.get("id", ""))):
				leader = f
		var m: Dictionary = leader.monster
		gold = int(dice.roll_expr(m.gold)) if m.has("gold") else 0
		for e in m.get("loot", []):
			if String(e.item) == "spider_silk" and foes.any(func(f): return f.seide_weg):     # 870.6 Gegenwirkung: verbrannt
				continue
			if dice.chance(float(e.chance)) and mars.items.has(e.item) and not (probe and _schluessel(String(e.item))):
				items.append(e.item)
	var earned := roundi(float(r.gegeben))
	var lines: Array = []
	var grau: Array = []
	if probe:
		lines.append(PROBE[lang])
		var was: Array = []
		if earned > 0:
			was.append(_f(ECHT_EP, lang, [earned]))
		if gold > 0:
			was.append(_f(ECHT_GOLD, lang, [gold]))
		if not was.is_empty():
			grau.append(lines.size())
			lines.append(_f(ECHT, lang, [", ".join(was)]))
		for it in items:
			lines.append(_f(LOOT, lang, [[mars.items[it].de, mars.items[it].en][lang]]))
		for g in gear:
			lines.append(_f(GEAR_LOOT, lang, [g.name, g.rarity]))
		return {"xp": earned, "gold": gold, "items": items, "gear": gear.map(func(g): return g.gear), "level": nachher,
			"levels": nachher - vorher, "stand": h, "lines": lines, "grau": grau}
	if earned > 0:
		lines.append(_f(GAIN_XP, lang, [name, earned]))
	if roh > 0.0 and vorher >= Brs.hoechste_stufe():
		lines.append(ENDE[lang])
	if gebiet != "" and rest_vorher > 0.0 and bool(r.topf_leer):
		lines.append(TOPF[lang])
	if gold > 0:
		lines.append(_f(GAIN_GOLD, lang, [gold]))
	for it in items:
		lines.append(_f(LOOT, lang, [[mars.items[it].de, mars.items[it].en][lang]]))
	for g in gear:
		lines.append(_f(GEAR_LOOT, lang, [g.name, g.rarity]))
	for lvl in range(vorher + 1, nachher + 1):
		lines.append(_f(LEVEL_UP, lang, [name, lvl]))
	if vorher < Brs.grenze() and nachher >= Brs.grenze():
		lines.append(GRENZE[lang])
	if vorher < Brs.hoechste_stufe() and nachher >= Brs.hoechste_stufe():
		lines.append(ENDE[lang])
	if nachher > vorher:
		lines.append(_f(RESTORED, lang, [name]))
	return {"xp": earned, "gold": gold, "items": items, "gear": gear.map(func(g): return g.gear), "level": nachher,
		"levels": nachher - vorher, "stand": h, "lines": lines, "grau": grau}


## 1034: Geschichtsgegenstand (Schlüsselding), nie Beute eines Probekampfs mit dem Testhelden
static func _schluessel(id: String) -> bool:
	var d = Sprache.texte.get("dinge", {}).get(id, {})
	return d is Dictionary and String(d.get("art", "")) == "KEY"


static func _f(t: Array, lang: int, args: Array) -> String:
	var s: String = t[lang]
	for i in args.size():
		s = s.replace("{%d}" % i, str(args[i]))
	return s
