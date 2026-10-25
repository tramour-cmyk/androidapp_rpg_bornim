# 348.7: the dice of the rules (core Dice.kt). Plays from its own random source, or from a tape of numbers
# recorded in the Kotlin core (MarsGoldenTest), so a fight can be replayed number for number.
extends RefCounted

var rng := RandomNumberGenerator.new()
## Recorded numbers, or null for the random source.
var tape = null
var pos := 0
## The first number the tape could not give as asked, for the test's report.
var fault := ""


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
