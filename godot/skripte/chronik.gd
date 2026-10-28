class_name Chronik
extends RefCounted
# 399.1 Chronik wie alt (Chronicle.kt, 64): „Bisher geschehen“ je Wendepunkt der Geschichte, das Neueste oben, und die Auftraege
# neben dem Hauptauftrag (D4.1). Texte wortgleich aus texte.json (TextExport „chronik“, „chronik_auftraege“); wann ein Eintrag gilt,
# steht hier je Kennung wie in Chronicle.entries. Nebenauftraege vom Anschlagbrett (Jobs) folgen mit dem Brett.

const LUMPEN := "grey_rag"   # Jobs.RAG

static func erreicht(id: String, z: Zustand) -> bool:
	match id:
		"greif": return true
		"auftrag": return z.has(Geschichte.QUEST_STARTED)
		"schlagbaum": return z.has(Geschichte.BARRIER_OPEN)
		"garrick": return z.has(Geschichte.HUNTER_MET)
		"hoehle": return z.has("besucht:cave")   # alt: place.map == "cave" oder explored; spiel.gd setzt die Flagge beim Betreten
		"krogg": return z.has(Geschichte.KROGG_DEFEATED)
		"gitter": return z.has(Geschichte.GATE_OPEN)
		"grak": return z.has(Geschichte.GRAK_DEFEATED)
		"lyra": return z.has(Geschichte.LYRA_RESCUED)
		"brief": return z.has(Geschichte.CHAPTER1_DONE)
		"grimmzahn": return z.has(Geschichte.GRIMFANG_DEFEATED)
		"auge": return z.anzahl(LUMPEN) > 0 or z.has("job_done_stones")   # Jobs.isDone(stones) folgt mit dem Anschlagbrett
	return false

static func gegeben(id: String, z: Zustand) -> bool:
	match id:
		"rauch": return z.has(Geschichte.KROGG_HINT)
		"lager": return z.has(Geschichte.CAMP_TOLD)
	return false

static func erledigt(id: String, z: Zustand) -> bool:
	match id:
		"rauch": return z.has(Geschichte.SMOKE_GIVEN) or z.has(Geschichte.KROGG_DEFEATED)
	return false   # „lager“: erledigt, wenn Kapitel 2 es sagt

static func eintraege() -> Array:
	Sprache.lade()
	return Sprache.texte.get("chronik", [])

static func auftraege() -> Array:
	Sprache.lade()
	return Sprache.texte.get("chronik_auftraege", [])

static func bisher(z: Zustand) -> Array:
	var l := eintraege().filter(func(e): return erreicht(String(e["id"]), z))
	l.reverse()
	return l

static func offen(z: Zustand) -> Array: return auftraege().filter(func(t): return gegeben(String(t["id"]), z) and not erledigt(String(t["id"]), z))
static func fertig(z: Zustand) -> Array: return auftraege().filter(func(t): return gegeben(String(t["id"]), z) and erledigt(String(t["id"]), z))

# Chronicle.fresh: etwas Neues, das der Spieler noch nicht angesehen hat (Stern am Reiter); markRead beim Oeffnen
static func frisch(z: Zustand) -> bool:
	for e in eintraege(): if erreicht(String(e["id"]), z) and not z.has("chron_" + String(e["id"])): return true
	for t in offen(z): if not z.has("chron_task_" + String(t["id"])): return true
	return false

static func gelesen(z: Zustand) -> void:
	for e in eintraege(): if erreicht(String(e["id"]), z): z.setze("chron_" + String(e["id"]))
	for t in offen(z): z.setze("chron_task_" + String(t["id"]))
