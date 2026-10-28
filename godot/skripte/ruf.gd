class_name Ruf
extends RefCounted
# 399.1 (Hail.kt, 134.1): wer mit dem Helden schon sprach und Neues hat (ein Gespraech, das er so noch nicht hoerte, oder ein
# Aushang zum Abgeben), zeigt ein goldenes „!“ ueber dem Kopf, sobald der Held ihn bemerkt (Reichweite wie die der Monster:
# Perks.noticeRange), kurz, und nach 3,2 s noch einmal; wieder erst, wenn der Held zwei Kacheln weiter weg war. Was „neu“ ist,
# folgt nur aus dem Spielstand: je Person die Fingerabdruecke der letzten Gespraeche (Zustand.gehoert, GameState.heard).
# Wer ruft, haelt still, bis das zweite Zeichen vorbei ist (306, leute.gd ruft_bis).
# Mit dem Zeichen ein kurzer Ruf ohne Worte (134.3): Mann, Frau, Kind nach leute.json, nie zwei zugleich.
# Noch nicht wie alt: die Geste dazu (134.2).

const ZEIGT_MS := 1400
const WIEDER_MS := 3200
const RUF_ABSTAND_MS := 1800   # 134.3 Hail.CALL_GAP_MS
const LEUTE := "res://daten/leute/leute.json"
static var _leute = null

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

# 134.3 Hail.voice: wie [id] ruft, ohne Worte: Kind (klein), Frau, Mann; "" fuer wen leute.json nicht kennt
static func stimme(id: String) -> String:
	if _leute == null:
		_leute = JSON.parse_string(FileAccess.get_file_as_string(LEUTE)) if FileAccess.file_exists(LEUTE) else {}
		if not _leute is Dictionary: _leute = {}
	var p = _leute.get(id)
	if not p is Dictionary: return ""
	if p.get("kind", false) or float(p.get("groesse", 1.0)) < 0.8: return "hail_child"
	return "hail_woman" if String(p.get("sex", "m")) == "w" else "hail_man"

# 134.3 Hail.callVolume (Ambience.heardAt mit 0,6): jemand in der Naehe ruft, schreit nicht
static func pegel(abstand: int) -> float: return maxf(0.3, 0.6 - 0.15 * maxi(0, abstand - 2))
