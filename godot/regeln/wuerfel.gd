# 348.7: the dice of the rules (core Dice.kt). Plays from its own random source, or from a tape of numbers
# recorded in the Kotlin core (MarsGoldenTest), so a fight can be replayed number for number.
extends RefCounted

var rng := RandomNumberGenerator.new()
## Recorded numbers, or null for the random source.
var tape = null
var pos := 0
## The first number the tape could not give as asked, for the test's report.
var fault := ""
## 987: auch die BRS-Würfe (randf) vom Band, nicht aus rng
var band_brs := false


func _init(seed_or_tape = null) -> void:
	if seed_or_tape is Array:
		tape = seed_or_tape
	elif seed_or_tape != null:
		rng.seed = int(seed_or_tape)
	else:
		rng.randomize()


## A whole number from [from] up to [until] (excluded), like Kotlin's Random.nextInt(from, until).
func next_int(from: int, until: int) -> int:
	if tape == null:
		return rng.randi_range(from, until - 1)
	if pos >= tape.size():
		if fault == "":
			fault = "tape ends at %d" % pos
		return from
	var v := int(tape[pos])
	pos += 1
	if v < from or v >= until:
		if fault == "":
			fault = "tape %d: %d not in [%d, %d)" % [pos - 1, v, from, until]
		return clampi(v, from, until - 1)
	return v


## 987 (von Spike, Lauf 354: krogg_494 schwankte, „jeder Wurf 20“ galt für die BRS-Schläge nicht): eine Zahl in [0, 1) für die
## BRS-Würfe (BrsKampf.schlag: Treffer, Glück, kritisch, Streuung). Wie bisher aus der eigenen Quelle (Tests setzen deren seed und
## das Band nur für die übrigen Würfe, mars_regeln); nur mit [band_brs] vom Band, ein Wert von 1 bis 20 (20 gut, 1 schlecht) als
## (20 − Wert) / 20: 20 gibt 0 (trifft immer, Glück und kritisch, wo möglich), 1 gibt 0,95.
func randf() -> float:
	if tape == null or not band_brs:
		return rng.randf()
	return (20.0 - float(next_int(1, 21))) / 20.0


func d(sides: int) -> int:
	return next_int(1, sides + 1)


## d20 with advantage (+1), disadvantage (-1) or neither (0).
func d20(mode: int = 0) -> int:
	if mode > 0:
		var a := d(20)
		var b := d(20)
		return maxi(a, b)
	if mode < 0:
		var a := d(20)
		var b := d(20)
		return mini(a, b)
	return d(20)


## True with probability [p] (Dice.chance); from a tape as a number in [0, 1000).
func chance(p: float) -> bool:
	if tape == null:
		return rng.randf() < p
	return next_int(0, 1000) < int(p * 1000)


func roll(count: int, sides: int) -> int:
	var s := 0
	for i in count:
		s += d(sides)
	return s


## A dice expression [count, sides, bonus].
func roll_expr(e: Array) -> int:
	return roll(int(e[0]), int(e[1])) + int(e[2])


func pick(list: Array):
	return list[next_int(0, list.size())]
