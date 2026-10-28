class_name Ruf
extends RefCounted
# 399.1 (Hail.kt, 134.1): wer mit dem Helden schon sprach und Neues hat (ein Gespraech, das er so noch nicht hoerte, oder ein
# Aushang zum Abgeben), zeigt ein goldenes „!“ ueber dem Kopf, sobald der Held ihn bemerkt (Reichweite wie die der Monster:
# Perks.noticeRange), kurz, und nach 3,2 s noch einmal; wieder erst, wenn der Held zwei Kacheln weiter weg war. Was „neu“ ist,
# folgt nur aus dem Spielstand: je Person die Fingerabdruecke der letzten Gespraeche (Zustand.gehoert, GameState.heard).
# Noch nicht wie alt: die Geste dazu (134.2), der Ruf ohne Worte (134.3, Klang), das Stillhalten (306).

const ZEIGT_MS := 1400
const WIEDER_MS := 3200

# was die Saetze sagen, als eine Zahl: deutsch, „{name}“ nicht eingesetzt, so zaehlt die Sprache nicht
static func abdruck(befehle: Array) -> int:
	var t := PackedStringArray()
	for c in befehle:
		if String(c.get("art", "")) == "sagen": t.append(String(c["text"].get("de", "")) if c["text"] is Dictionary else String(c["text"]))
	return "\n".join(t).hash()

static func neu(z: Zustand, id: String) -> bool:
	if not z.has("met_" + id): return false
	if not Auftraege.abgabe(z, id).is_empty(): return true
	if not z.gehoert.has(id): return false
	return abdruck(Geschichte.gespraech(id, z)) not in z.gehoert[id]

# beim Ansprechen (nach false) und wenn das Gespraech vorbei ist (nach true): was sie jetzt sagen wuerde, gilt als gehoert
static func gehoert(z: Zustand, id: String, nach: bool) -> void:
	var a := abdruck(Geschichte.gespraech(id, z))
	if not nach:
		z.gehoert[id] = [a]
		return
	var l: Array = (z.gehoert.get(id, []) as Array).duplicate()
	if a not in l: l.append(a)
	z.gehoert[id] = l.slice(maxi(0, l.size() - 2))

static func zeigt(ms: int) -> bool: return (ms >= 0 and ms < ZEIGT_MS) or (ms >= WIEDER_MS and ms < WIEDER_MS + ZEIGT_MS)

# Perks.noticeRange: 4 Kacheln, je zwei Punkte Geschicklichkeitsbonus eine weniger, mindestens 2
static func reichweite(hw: Heldwerte) -> int: return maxi(2, 4 - int(maxi(0, hw.mod("DEX")) / 2))
