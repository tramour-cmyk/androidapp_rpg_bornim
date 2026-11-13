class_name BrsFertigkeit
extends RefCounted
# 471 (Abnahme 1.2): Fertigkeiten steigen durch Tun (Nachschlagewerk Abschnitt 3 „Wie Fertigkeiten wachsen“, E 44, E 59, E 67).
# Wert 0 bis 100 in vier Raengen (Anfaenger bis 24, Geselle bis 49, Meister bis 74, Grossmeister bis 100, [423.rang]); jede Benutzung
# gegen ein passendes Ziel bringt Uebung, zu leichte Ziele kaum etwas; je hoeher der Wert, desto mehr Uebung je Punkt. Am Ende des
# Rangs bleibt der Wert stehen, bis die Probe bestanden ist; bis dahin wird Uebung bis zu einem Puffer gemerkt. Kapitel 1 (Takt
# NW 5): Bewaehrungsprobe zum Gesellen, hoechstens Geselle (49). Je 5 Punkte gibt es Erfahrung fuer die Heldenstufe (Brs, 472).
# Einzige Quelle der Zahlen: daten/werte.json = tools/sim444/werte.json (Bloecke „ueben“, „held“, „erfahrung“); die Regeln sind
# die von tools/sim444/sim.py (Held.uebe, _steige, nach_sieg), Gegenprobe: tests/brs_471.gd.
# Der Stand ist ein Dictionary (neuer_stand), damit er wie Brs.neuer_stand im Spielstand liegt. Jede Aenderung meldet Ereignisse
# fuer die Rueckmeldung im Augenblick („Bogen ↑“, „Neue Fertigkeit: Schleichen“):
#   {"art": "neu"|"auf"|"rangende"|"probe"|"rang", "fert": Name, "wert": Wert danach, "erfahrung": an die Heldenstufe gegeben}

const RAENGE := ["Anfänger", "Geselle", "Meister", "Großmeister"]   # [423.rang]; Obergrenzen in raeng_oben()

static func w() -> Dictionary: return BrsHeld.lade()
static func u() -> Dictionary: return w()["ueben"]
static func decken() -> Array: return (w()["held"]["rangdecken_kapitel"] as Array).map(func(x): return int(x))   # JSON liefert 24.0
## Obergrenzen der vier Raenge (NW 3): 24, 49, 74, 100
static func raeng_oben() -> Array: return [24, 49, 74, 100]

## Rang eines Werts: 0 Anfaenger … 3 Grossmeister
static func rang(wert: int) -> int:
	var o := raeng_oben()
	for i in o.size():
		if wert <= int(o[i]): return i
	return o.size() - 1

## 875 (857a A, Chef 10.11., 13:35): umbenannte Fertigkeiten; Spielstände aus Build 276 tragen noch den alten Namen
const UMBENANNT := {"Kräuterkunde": "Kräutersammeln"}
static func neuer_name(f: String) -> String: return String(UMBENANNT.get(f, f))

## den Stand eines älteren Spielstands auf die heutigen Namen bringen (Wert, Übung, Decke, Probe, bekannt)
static func umbenennen(s: Dictionary) -> void:
	for teil in ["werte", "uebung", "decke", "probe"]:
		var d = s.get(teil)
		if not d is Dictionary: continue
		for alt in UMBENANNT:
			if (d as Dictionary).has(alt):
				if not (d as Dictionary).has(UMBENANNT[alt]): d[UMBENANNT[alt]] = d[alt]
				(d as Dictionary).erase(alt)
	if s.get("bekannt") is Array:
		var neu := []
		for f in s["bekannt"]:
			if not neu.has(neuer_name(String(f))): neu.append(neuer_name(String(f)))
		s["bekannt"] = neu

## Neuer Stand mit den Startfertigkeiten (BrsHeld.fertigkeiten(): Name -> Startwert); sie gelten als bekannt
static func neuer_stand(start := {}) -> Dictionary:
	var s := {"werte": {}, "uebung": {}, "decke": {}, "probe": {}, "bekannt": []}
	for f in start:
		s["werte"][String(f)] = int(start[f])
		s["bekannt"].append(String(f))
	return s

static func wert(s: Dictionary, f: String) -> int: return int(s["werte"].get(f, 0))
static func decke(s: Dictionary, f: String) -> int: return int(s["decke"].get(f, decken()[0]))
## steht am Ende des Rangs und wartet auf die Probe (Kapitel 1: nur zum Gesellen)
static func am_rangende(s: Dictionary, f: String) -> bool: return wert(s, f) >= decke(s, f)
static func probe_offen(s: Dictionary, f: String) -> bool: return am_rangende(s, f) and decke(s, f) < int(decken()[-1])

## Uebung fuer +1 Punkt bei [wert] ((Wert + 10) / 5)
static func bedarf(wert_: int) -> float: return (wert_ + float(u()["bedarf_basis"])) / float(u()["bedarf_teiler"])

## Faktor nach Gegnerstufe: 1 + (Gegner - Held) / 5, begrenzt 0,2 bis 1,5 („zu leichte Ziele bringen kaum etwas“)
static func faktor(gegner_stufe: int, held_stufe: int) -> float:
	return clampf(1.0 + (gegner_stufe - held_stufe) / float(u()["leicht_teiler"]), float(u()["leicht_min"]), float(u()["leicht_max"]))

## Eine Benutzung von [f] gegen ein Ziel der Stufe [gegner_stufe]; [h] ist der Stand der Heldenstufe (Brs.neuer_stand).
## menge < 0: die Uebung je Benutzung aus der Datei.
static func uebe(s: Dictionary, h: Dictionary, f: String, gegner_stufe: int, menge := -1.0) -> Array:
	var ev := []
	if not s["bekannt"].has(f):
		s["bekannt"].append(f)
		ev.append({"art": "neu", "fert": f, "wert": wert(s, f), "erfahrung": 0.0})
	if menge < 0.0: menge = float(u()["uebung_je_benutzung"])
	s["uebung"][f] = float(s["uebung"].get(f, 0.0)) + menge * faktor(gegner_stufe, int(h["stufe"]))
	ev.append_array(steige(s, h, f))
	return ev

## Uebung in Punkte umsetzen bis zum Ende des Rangs; je fertigkeit_schritt Punkte Erfahrung (20 x Heldenstufe, Deckel 40 % in Brs)
static func steige(s: Dictionary, h: Dictionary, f: String) -> Array:
	var ev := []
	var e: Dictionary = w()["erfahrung"]
	var wt := wert(s, f)
	var vor := wt
	var d := decke(s, f)
	var ep := 0.0
	while wt < d and float(s["uebung"][f]) >= bedarf(wt):
		s["uebung"][f] = float(s["uebung"][f]) - bedarf(wt)
		wt += 1
		if wt % int(e["fertigkeit_schritt"]) == 0:
			ep += float(Brs.gib_erfahrung(h, float(e["fertigkeit_schritt_erfahrung_je_heldenstufe"]) * int(h["stufe"]), "fertigkeit")["gegeben"])
	s["werte"][f] = wt
	if wt > vor:
		ev.append({"art": "auf", "fert": f, "wert": wt, "erfahrung": ep})
		if rang(wt) > rang(vor): ev.append({"art": "rang", "fert": f, "wert": wt, "erfahrung": 0.0})
	if wt >= d:
		s["uebung"][f] = minf(float(s["uebung"][f]), float(u()["puffer_uebung"]))
		if wt > vor: ev.append({"art": "rangende", "fert": f, "wert": wt, "erfahrung": 0.0})
	return ev

## Nach einem Sieg gegen [gegner_stufe]: Bewaehrungsprobe fuer jede benutzte Fertigkeit am Rangende (Gegner mindestens der eigenen
## Stufe, probe_siege Siege); bestanden oeffnet den naechsten Rang, gibt Erfahrung (25 x Heldenstufe) und setzt den Puffer um
static func nach_sieg(s: Dictionary, h: Dictionary, benutzt: Array, gegner_stufe: int) -> Array:
	var ev := []
	for f in benutzt:
		f = String(f)
		if not probe_offen(s, f) or gegner_stufe < int(h["stufe"]): continue
		s["probe"][f] = int(s["probe"].get(f, 0)) + 1
		if int(s["probe"][f]) >= int(u()["probe_siege"]):
			var i := decken().find(decke(s, f))
			s["decke"][f] = int(decken()[i + 1])
			s["probe"][f] = 0
			var ep := float(Brs.gib_erfahrung(h, float(w()["erfahrung"]["probe_erfahrung_je_heldenstufe"]) * int(h["stufe"]), "probe")["gegeben"])
			ev.append({"art": "probe", "fert": f, "wert": wert(s, f), "erfahrung": ep})
			if not s["uebung"].has(f): s["uebung"][f] = 0.0
			ev.append_array(steige(s, h, f))
	return ev

## Siege, die der Probe noch fehlen (Heldenblatt)
static func probe_rest(s: Dictionary, f: String) -> int: return int(u()["probe_siege"]) - int(s["probe"].get(f, 0))

## Heldenblatt zeigt nur Getanes (NW 3): die bekannten Fertigkeiten in der Reihenfolge der Gruppen des Handbuchs
static func sichtbar(s: Dictionary) -> Array:
	var r := []
	var gruppen: Dictionary = w()["erschaffung"]["fertigkeiten"]
	for g in gruppen:
		if String(g).begins_with("_"): continue
		for f in gruppen[g]:
			if s["bekannt"].has(String(f)): r.append(String(f))
	return r
