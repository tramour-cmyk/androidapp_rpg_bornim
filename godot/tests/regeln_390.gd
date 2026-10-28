# 390: Pechsträhne, Ausdauer, Talente und Zustände nach GDScript, mit den Testfällen aus core (MissStreakTest, StaminaTest, PerksTest).
# Run: godot --headless --path godot -s res://tests/regeln_390.gd   (exit code 0 = wie im alten Spiel)
extends SceneTree

const Pech = preload("res://regeln/pechstraehne.gd")
const Ausdauer = preload("res://regeln/ausdauer.gd")
const Talente = preload("res://regeln/talente.gd")
const Zustaende = preload("res://regeln/zustaende.gd")

var failed := 0


## Ein Held mit festen Werten, wie Heldwerte (mod, wert, klasse); alle 10 außer [werte].
class Probeheld:
	var klasse := "FIGHTER"
	var werte := {}
	func _init(w := {}, k := "FIGHTER") -> void:
		werte = w
		klasse = k
	func wert(a: String) -> int: return int(werte.get(a, 10))
	func mod(a: String) -> int: return floori((wert(a) - 10) / 2.0)


func _init() -> void:
	_pech()
	_ausdauer()
	_talente()
	_zustaende()
	print("regeln_390: ", "alles gut" if failed == 0 else "%d Fehler" % failed)
	quit(1 if failed > 0 else 0)


func _check(what: String, got, want) -> void:
	var ok: bool = is_equal_approx(got, want) if got is float or want is float else got == want
	if not ok:
		failed += 1
		print("FEHLER ", what, ": ", got, " statt ", want)


func _pech() -> void:
	# bonusStartsAfterThreeMissesAndStopsAtFour
	var s = Pech.new()
	var bonuses := []
	for i in 7:
		s.miss()
		bonuses.append(s.bonus())
	_check("Pechsträhne 1–7", bonuses, [0, 0, 2, 3, 4, 4, 4])
	_check("Pechsträhne längste", s.longest, 7)
	# aHitStartsOver
	s = Pech.new()
	for i in 4:
		s.miss()
	s.hit()
	_check("Treffer setzt zurück", s.bonus(), 0)
	s.miss(); s.miss()
	_check("zwei danach", s.bonus(), 0)
	_check("längste bleibt", s.longest, 4)
	# offOnlyCounts
	s = Pech.new(false)
	for i in 5:
		s.miss()
	_check("aus: kein Bonus", s.bonus(), 0)
	_check("aus: zählt", s.longest, 5)


## Bilder von 20 ms über [ms]; gibt zurück, wie lange der Held wirklich rannte.
func _run(a, lasts: float, ms: int, moving := true, run := true) -> int:
	var ran := 0
	var t := 0
	while t < ms:
		if a.step(20.0, moving, run, lasts):
			ran += 20
		t += 20
	return ran


func _run_empty(a, lasts: float) -> int:
	var ran := 0
	while not a.winded and ran < 120000:
		a.step(20.0, true, true, lasts)
		ran += 20
	return ran


func _ausdauer() -> void:
	# Kämpfer, Mensch: Konstitution des neuen Spiels; hier wie im Kotlin-Test über lasts_ms, nicht über eine feste Zahl
	var lasts: float = Ausdauer.lasts_ms(1, 1)
	_check("Vorrat Kon +1, Stufe 1", lasts, 8000.0)
	_check("Vorrat Kon −4 mindestens 2 s", Ausdauer.lasts_ms(-4, 1), 2000.0)
	_check("Vorrat Stufe 4", Ausdauer.lasts_ms(0, 4), 8000.0)
	_check("Vorrat schwer, Trank", Ausdauer.lasts_ms(0, 1, true, true), 6000.0)
	_check("schwer ohne Stärke", Ausdauer.heavy("HEAVY", 12), true)
	_check("schwer mit Stärke 13", Ausdauer.heavy("HEAVY", 13), false)
	_check("mittel", Ausdauer.heavy("MEDIUM", 8), false)
	# aFullStoreLastsAsLongAsConstitutionSays
	var a = Ausdauer.new()
	var ran := _run_empty(a, lasts)
	_check("rennt so lange wie der Vorrat", absf(ran - lasts) <= 40.0, true)
	_check("danach außer Atem", a.winded, true)
	# outOfBreathTheHeroWalksUntilAQuarterIsBack
	a = Ausdauer.new()
	_run_empty(a, lasts)
	_check("außer Atem geht er", a.step(20.0, true, true, lasts), false)
	_run(a, lasts, 9000, true, false)
	_check("nach 9 s Gehen noch außer Atem", a.winded, true)
	_run(a, lasts, 1100, true, false)
	_check("nach 10,1 s wieder bei Atem", a.winded, false)
	_check("rennt wieder", a.step(20.0, true, true, lasts), true)
	# standingRefillsFasterThanWalking
	var st = Ausdauer.new()
	var ge = Ausdauer.new()
	st.stamina = 0.0; ge.stamina = 0.0
	_run(st, lasts, 10000, false, false)
	_run(ge, lasts, 10000, true, false)
	_check("Stehen 10 s", absf(st.stamina - 0.5) < 0.01, true)
	_check("Gehen 10 s", absf(ge.stamina - 0.25) < 0.01, true)
	# betrunken rennt er nicht (181)
	a = Ausdauer.new()
	_check("betrunken", a.step(20.0, true, true, lasts, true), false)
	# aRestFillsTheStore
	a = Ausdauer.new()
	_run_empty(a, lasts)
	a.refill()
	_check("Rast füllt", a.stamina, 1.0)
	_check("Rast: bei Atem", a.winded, false)
	# theStoreIsSaved
	a = Ausdauer.new()
	a.stamina = 0.4; a.winded = true
	var back = Ausdauer.from_dict(a.to_dict())
	_check("gespeichert Vorrat", back.stamina, 0.4)
	_check("gespeichert außer Atem", back.winded, true)


func _talente() -> void:
	# charismaChangesPrices
	_check("CHA 16 kauft", Talente.buy_price(Probeheld.new({"CHA": 16}), 100), 85)
	_check("CHA 16 verkauft", Talente.sell_price(Probeheld.new({"CHA": 16}), 100), 115)
	_check("CHA 8 kauft", Talente.buy_price(Probeheld.new({"CHA": 8}), 100), 105)
	_check("höchstens 20 %", Talente.buy_price(Probeheld.new({"CHA": 30}), 100), 80)
	_check("mindestens 1", Talente.buy_price(Probeheld.new({"CHA": 30}), 1), 1)
	# intelligenceRevealsWeaknesses (die Zeile im Kampf folgt mit dem klassischen Kampf)
	_check("INT 14 erkennt", Talente.knows_weaknesses(Probeheld.new({"INT": 14})), true)
	_check("INT 10 erkennt nicht", Talente.knows_weaknesses(Probeheld.new({"INT": 10})), false)
	# smallEffectsGrowWithTheModifier
	_check("DEX 12", Talente.notice_range(Probeheld.new({"DEX": 12})), 4)
	_check("DEX 14", Talente.notice_range(Probeheld.new({"DEX": 14})), 3)
	_check("DEX 20", Talente.notice_range(Probeheld.new({"DEX": 20})), 2)
	_check("WIS 14 Sicht", Talente.sight_bonus(Probeheld.new({"WIS": 14})), 1.0)
	_check("WIS 30 Hinterhalt", Talente.ambush_factor(Probeheld.new({"WIS": 30})), 0.4)
	_check("STR 16 Wurf", Talente.throw_bonus(Probeheld.new({"STR": 16})), 3)
	_check("STR 8 Wurf", Talente.throw_bonus(Probeheld.new({"STR": 8})), 0)
	_check("INT 14 Erfahrung", Talente.xp_factor(Probeheld.new({"INT": 14})), 1.06)
	# everyAbilityIsExplained (Kleriker)
	var h := Probeheld.new({"STR": 12, "DEX": 10, "CON": 14, "INT": 8, "WIS": 16, "CHA": 13}, "CLERIC")
	for lang in 2:
		for a in ["STR", "DEX", "CON", "INT", "WIS", "CHA"]:
			var lines: Array = Talente.describe(a, h, lang)
			_check("%s %d: mindestens drei Zeilen" % [a, lang], lines.size() >= 3, true)
	# Wortlaut wie Perks.describe
	_check("Kopfzeile", Talente.describe("WIS", h, 0)[0], "Wert 16, Modifikator +3")
	_check("Kopfzeile negativ", Talente.describe("INT", h, 1)[0], "Score 8, modifier -1")
	_check("Wahrnehmung", Talente.describe("WIS", h, 0)[3], "• Wahrnehmung: +1,5 Felder Sicht im Nebel, 45 % seltener Hinterhalte.")
	_check("Perception", Talente.describe("WIS", h, 1)[3], "• Perception: +1.5 tiles of sight in the fog, 45 % fewer ambushes.")
	_check("Handeln", Talente.describe("CHA", h, 0)[1], "• Handeln: 5 % günstiger einkaufen und 5 % teurer verkaufen.")
	_check("Trading arm", Talente.describe("CHA", Probeheld.new({"CHA": 8}), 1)[1], "• Trading: buy for 5% more and sell for 5% less.")
	_check("Lernen", Talente.describe("INT", Probeheld.new({"INT": 14}), 0)[3], "• Lernen: +6 % Erfahrung.")


func _zustaende() -> void:
	# Status.kt: wer welchen Zustand nicht erleidet, was den Kampf überdauert
	_check("Skelett blutet nicht", Zustaende.immune({"id": "skeleton", "immune": ["POISON"]}, "BLEED"), true)
	_check("Skelett giftfest", Zustaende.immune({"id": "skeleton", "immune": ["POISON"]}, "POISON"), true)
	_check("Wolf blutet", Zustaende.immune({"id": "wolf", "immune": []}, "BLEED"), false)
	_check("Gallert nicht betäubt", Zustaende.immune({"id": "ochre_jelly"}, "STUN"), true)
	_check("Gallert nicht geblendet", Zustaende.immune({"id": "ochre_jelly"}, "BLIND"), true)
	_check("Zombie verlangsamt", Zustaende.immune({"id": "zombie"}, "SLOW"), false)
	_check("Gift bleibt", Zustaende.lingers("POISON"), true)
	_check("Fluch bleibt", Zustaende.lingers("WEAK"), true)
	_check("Brand endet", Zustaende.lingers("BURN"), false)
	_check("Brand schadet", Zustaende.damaging("BURN"), true)
	_check("Betäubt schadet nicht", Zustaende.damaging("STUN"), false)
