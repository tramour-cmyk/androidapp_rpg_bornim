# 348.7 (249 im alten Spiel): wie hart ein Schlag landet, für den Halt beim Aufschlag (core HitWeight.kt). Ein gewöhnlicher
# Treffer hält nur kurz; ein harter (ein Drittel der Lebenspunkte des Getroffenen oder mehr) zwei Bilder eines Schlags, ein
# kritischer drei, dabei rückt die Szene etwas heran und ruckt einmal in Schlagrichtung; der tödliche hält am längsten und
# rückt weiter heran.
extends RefCounted

const NORMAL := "NORMAL"
const HARD := "HARD"
const CRIT := "CRIT"
const KILL := "KILL"
const STOP_MS := {NORMAL: 70, HARD: 180, CRIT: 270, KILL: 380}


## Die Wucht eines Schlags mit [damage] Schaden gegen einen mit höchstens [max_hp]; [kill] für den tödlichen.
static func of(crit: bool, damage: int, max_hp: int, kill := false) -> String:
	if kill:
		return KILL
	if crit:
		return CRIT
	if max_hp > 0 and damage * 3 >= max_hp:
		return HARD
	return NORMAL


## Wie weit die Szene im Halt heranrückt, als Teil ihrer Größe (der tödliche rückt im Kampfort selbst heran).
static func zoom(w: String) -> float:
	return 0.06 if w == CRIT else 0.0


## Wie weit die Szene in Schlagrichtung ruckt (dp) und wie lange hin und zurück dauert (ms); keiner bei gewöhnlich und hart.
static func jolt_dp(w: String) -> float:
	return {CRIT: 4.0, KILL: 7.0}.get(w, 0.0)


static func jolt_ms(w: String) -> int:
	return {CRIT: 150, KILL: 220}.get(w, 0)


## Der Ruck bei [p] (0 beim Aufschlag, 1 am Ende): einmal hin und zurück, weich, nie über die Ruhe hinaus.
static func jolt(p: float) -> float:
	return 0.0 if p <= 0.0 or p >= 1.0 else sin(PI * p)
