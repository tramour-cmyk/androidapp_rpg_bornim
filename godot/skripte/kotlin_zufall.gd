class_name KotlinZufall
extends RefCounted
# 390 (Laden): Zufall wie kotlin.random.Random(seed) (XorWowRandom), Zahl fuer Zahl, damit Thessas Ware wie im alten Spiel
# aus Siegen, Stufe und Namen folgt (Loot.shopGear: bleibt, bis acht Siege oder eine Stufe dazukommen). Dieselben Aufrufe
# wie Jerrys regeln/wuerfel.gd (next_int, d, chance, pick) und Dice.weighted. Gegenprobe: tests/beute_golden.gd (Proben „zufall“).
# Die Zustandswoerter liegen ohne Vorzeichen in 0 .. 2^32-1; Int von Kotlin sind 32 Bit mit Ueberlauf.

const M := 0xFFFFFFFF

var x := 0
var y := 0
var z := 0
var w := 0
var v := 0
var addend := 0

# Random(seed: Int) = XorWowRandom(seed, seed shr 31)
func _init(seed: int = 0) -> void:
	var s1 := seed & M
	var s2 := M if s32(seed) < 0 else 0
	x = s1; y = s2; z = 0; w = 0; v = (~s1) & M
	addend = ((s1 << 10) & M) ^ (s2 >> 4)
	for i in 64: next_raw()

static func s32(u: int) -> int:
	u &= M
	return u - 0x100000000 if u >= 0x80000000 else u

# String.hashCode wie Java: s[0]*31^(n-1) + … ueber UTF-16, 32 Bit
static func hash_code(s: String) -> int:
	var h := 0
	for i in s.length():
		var c := s.unicode_at(i)
		if c > 0xFFFF:
			c -= 0x10000
			h = (h * 31 + (0xD800 + (c >> 10))) & M
			h = (h * 31 + (0xDC00 + (c & 0x3FF))) & M
		else:
			h = (h * 31 + c) & M
	return s32(h)

# XorWowRandom.nextInt(), ohne Vorzeichen
func next_raw() -> int:
	var t := x
	t = t ^ (t >> 2)
	x = y; y = z; z = w
	var v0 := v
	w = v0
	t = (t ^ ((t << 1) & M)) ^ v0 ^ ((v0 << 4) & M)
	v = t
	addend = (addend + 362437) & M
	return (t + addend) & M

func next_int_raw() -> int: return s32(next_raw())

# nextBits: die oberen [n] Bits; auch bei null Bits wird eine Zahl verbraucht (Random.nextInt(1))
func next_bits(n: int) -> int:
	var r := next_raw()
	if n <= 0: return 0
	return s32(r >> (32 - n))

# Random.nextInt(from, until)
func next_int(from: int, until: int) -> int:
	var n := until - from
	if n <= 0 or n > 0x7FFFFFFF:
		push_error("KotlinZufall: Bereich %d..%d" % [from, until])
		return from
	if (n & -n) == n:
		var bits := 0
		while (1 << (bits + 1)) <= n: bits += 1
		return from + next_bits(bits)
	while true:
		var b := next_raw() >> 1
		var r := b % n
		if b - r + (n - 1) <= 0x7FFFFFFF: return from + r
	return from

func next_below(until: int) -> int: return next_int(0, until)

# Random.nextDouble = doubleFromParts(nextBits(26), nextBits(27))
func next_double() -> float:
	var hi := next_bits(26)
	var lo := next_bits(27)
	return float((hi << 27) + lo) / float(1 << 53)

# ---------------------------------------------------------------- Dice.kt
func d(sides: int) -> int: return next_int(1, sides + 1)
func chance(p: float) -> bool: return next_double() < p
func pick(list: Array): return list[next_int(0, list.size())]

# Dice.weighted: [[Wert, Gewicht], …]
func weighted(eintraege: Array):
	var summe := 0
	for e in eintraege: summe += int(e[1])
	var r := next_int(0, summe)
	for e in eintraege:
		if r < int(e[1]): return e[0]
		r -= int(e[1])
	return eintraege[-1][0]
