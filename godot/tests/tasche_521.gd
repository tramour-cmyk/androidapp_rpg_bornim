extends SceneTree
# 521, 523 (Chef 03.11., 23:23: „Leider kann man da die Items null unterscheiden … Zweihänder? … Sind gesperrte Gegenstände darunter?“;
# Abgleich 512): ohne Bild. Ein Magier mit Langschwert, Zweihänder, Lederkappe, Ring in der Tasche; gemessen in Tasche und Wechselschirm:
# jede Zeile mit Bild, Name, Zeile darunter (Art, Platz, Kennwert), „zweihändig“, „nicht tragbar“ und der Grund im Wechselschirm,
# ▲/▼ nur an Tragbarem; Reihenfolge Seltenheit, dann Platz wie alt; der Funke mit „Löschen“, danach aus.
# Aufruf: im Ordner godot mit -s res://tests/tasche_521.gd -> „TASCHE521 n Fehler“

func _initialize() -> void: _lauf.call_deferred()

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func ding(z: Zustand, base: String, rar := "COMMON") -> Dictionary:
	return z.ausruestung_dazu({"uid": 0, "base": base, "rarity": rar, "ilvl": 1, "plus": 0, "rolls": [], "unique": null, "name_seed": 0})

func texte(n: Node) -> Array:
	return n.find_children("*", "Label", true, false).filter(func(l): return not l.is_queued_for_deletion()).map(func(l): return String(l.text).replace("\u00a0", " "))   # 557: fest verbundene Wörter

func zeilen(m: Node) -> Array:
	return m.find_children("*", "HBoxContainer", true, false).filter(func(h): return h.has_meta("tragbar") and not h.is_queued_for_deletion())

func _lauf() -> void:
	Sprache.lade()
	Sprache.setze("de")
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Probe", "Mensch", "Zauberlehrling", z.neue_uid)
	var schwert := ding(z, "longsword")
	var gross := ding(z, "greatsword")
	var kappe := ding(z, "leather_cap", "UNCOMMON")
	ding(z, "ring", "UNCOMMON")
	z.funke = true
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	m.reiter = "tasche"
	m.baue()
	await process_frame
	var r := zeilen(m)
	pruefe(r.size() == z.beutel.size(), "Tasche: eine Ausrüstungszeile je Stück (%d von %d)" % [r.size(), z.beutel.size()])
	for h in r:
		var t := texte(h)
		pruefe(t.size() >= 2 and t[t.size() - 1] != "", "Zeile mit Name und Angabe darunter: %s" % [t])
		pruefe(h.find_children("*", "TextureRect", true, false).size() > 0 or h.get_child(0) is Control, "Zeile mit Bild")
	var alle := " | ".join(texte(m))
	print("Tasche: ", alle)
	pruefe(alle.contains("zweihändig") or alle.containsn("zweih"), "Zweihänder als zweihändig erkennbar")
	pruefe(not alle.contains("nicht tragbar"), "870.4: jeder darf alles tragen, kein „nicht tragbar“")
	for h in r:
		if not bool(h.get_meta("tragbar")): pruefe(int(h.get_meta("pfeil")) == 0, "kein ▲/▼ an nicht Tragbarem")
	# Reihenfolge: Seltenheit, dann Platz (Kopf vor Ring, beide ungewoehnlich)
	var namen := r.map(func(h): return texte(h)[0])
	pruefe(namen[0] == Beute.name(kappe), "ungewöhnliche Kappe (Kopf) zuerst: %s" % [namen])
	# Funke
	var loesch: Button = null
	for b in m.find_children("*", "Button", true, false):
		if String(b.text) == "LÖSCHEN" or String(b.text) == "PUT OUT": loesch = b
	pruefe(loesch != null, "Funke mit Knopf Löschen")
	if loesch:
		loesch.pressed.emit()
		await process_frame
		pruefe(not z.funke, "nach Löschen ist der Funke aus")
	# Wechselschirm: Haupthand zeigt beide Waffen als Zeilen; Kopf: 870.4 die Kappe darf jeder tragen
	m.reiter = "ausruestung"
	m.baue()
	await process_frame
	m.waehle("MAIN_HAND")
	await process_frame
	var w := " | ".join(texte(m))
	pruefe(w.contains(Beute.name(schwert)) and w.contains(Beute.name(gross)) and w.contains("Schnitt"), "Wechselschirm Haupthand: beide Waffen mit Angabe")
	m.waehle("HEAD")
	await process_frame
	w = " | ".join(texte(m))
	pruefe(not w.contains("kannst du das nicht tragen"), "Wechselschirm Kopf ohne Sperre nach Klasse: %s" % w.right(160))
	print("TASCHE521 %d Fehler" % fehler)
	quit(1 if fehler else 0)
