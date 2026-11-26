extends SceneTree
# 1973 (Fund Figur Dana 22.11., 18:49 zu 1570: „kein Zweihändermodell in daten/waffen“, Gang mit Zweihänder ohne Waffe): jede Waffe,
# jeder Schild und jedes Einzelstück in der Hand aus dem Katalog (tools/gegenstaende/gegenstaende.json) hat ein Modell, so wie der
# Held es lädt: Schlüssel HeldFigur._modell({base, ilvl}) (Einzelstück: base = grundform, wie Beute), dann Halt.datei nicht leer.
# Geprüft in der Stufe des Katalogs. Nennt jede Kennung ohne Modell. Ohne Bild; braucht den Bau mit Kaufmodellen (daten/waffen).
# Aufruf: im Ordner godot mit -s res://tests/waffenmodelle_1973.gd -> „WAFFENMODELLE1973 gut (n)“ oder „… n Fehler von m: …“
const HAND := ["haupthand", "nebenhand", "beide_haende"]

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var ohne: Array = []
	var n := 0
	for id in Katalog.lade():
		var e: Dictionary = Katalog.eintrag(id)
		var art := String(e.get("art", ""))
		if not (art in ["waffe", "schild"] or (art == "einzelstueck" and String(e.get("platz", "")) in HAND)): continue
		n += 1
		var base := String(e.get("grundform", id)) if art == "einzelstueck" else String(id)
		var schl := HeldFigur._modell({"base": base, "ilvl": Katalog.stufe(id), "rarity": "COMMON"})
		var f := Halt.datei(schl) if schl != "" else ""
		print(("gut  " if f != "" else "FALSCH ") + "%s (%s, %s): %s" % [id, art, base, f if f != "" else "kein Modell"])
		if f == "": ohne.append(id)
	if ohne.is_empty(): print("WAFFENMODELLE1973 gut (%d)" % n)
	else: print("WAFFENMODELLE1973 %d Fehler von %d: %s" % [ohne.size(), n, ", ".join(ohne)])
	quit(0 if ohne.is_empty() and n > 0 else 1)
