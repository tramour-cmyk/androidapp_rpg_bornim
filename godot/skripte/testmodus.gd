class_name Testmodus
extends RefCounted
# 399.1 (Test 139, Chef 28.10., 21:3x: „ich brauche mein Testmenü wieder. 7-mal aufs Logo unten drücken, auf dem Hauptmenü … genauso
# wieder, wie wir es hatten in der alten Fassung“): der Testmodus wie alt (GameViewModel.testMode, App.kt secretTaps): siebenmal auf das
# Firmenzeichen oder die Zeile darunter schaltet ihn an oder aus; an, zeigt das Menue den Reiter „Test“ (TestTab.kt, Menue.test).
# Dazu die Schalter des Reiters, die ueber das Menue hinaus gelten (FrameMeter, PlaceMeter). Gespeichert in user://test.cfg.

const DATEI := "user://test.cfg"
const TIPPEN := 7

static var geladen := false
static var an := false                  # prefs KEY_TEST
static var bildrate := false            # FrameMeter.on: Bilder je Sekunde ueber der Welt
static var standort := false            # PlaceMeter.on: Karte und Kachel des Helden ueber der Welt

static func lade() -> void:
	if geladen: return
	geladen = true
	var c := ConfigFile.new()
	if c.load(DATEI) != OK: return
	an = bool(c.get_value("test", "an", false))

static func umschalten() -> void:
	lade()
	an = not an
	var c := ConfigFile.new()
	c.set_value("test", "an", an)
	c.save(DATEI)

static func ist_an() -> bool:
	lade()
	return an

# ---------------------------------------------------------------- Reiter „Test“ (TestTab.kt), soweit die neue Welt es traegt
# Wie alt in Gruppen: Anzeigen und Messwerte, Held, Welt, Teleport, Kampf beschwoeren, MARS-Probekampf, Beute erzeugen. Was in die Welt
# greift (Teleport, Kapitelende, Kampf), sagt das Menue der Welt mit Menue.test; der Rest aendert Held und Zustand gleich.
# Noch nicht wie alt: Regen, Kartenzoom, Monster auf der Karte, Sichtlinie, Bosse (es gibt Wald und Hoehle noch nicht); Varianten,
# Eroeffnung, Kampfhilfen und Absturzbericht (Kampfort, Jerry).

const STUFEN_PROBE := [3, 5, 6, 8, 11]          # Skirmish.PROBE_LEVEL und die Stufen aus 259
const NEBENHAND := ["", "shield", "round_shield", "dagger"]   # cheatOffHand
const KLASSEN := ["FIGHTER", "WIZARD", "ROGUE", "CLERIC"]

static var waffen_auf := false
static var probe_gegner := "GRAK"
static var probe_stufe := 3

static func feinde() -> Dictionary:
	var s = load("res://kampf/probe.gd") if ResourceLoader.exists("res://kampf/probe.gd") else null
	return s.FOES if s else {}

# Held und Soeldner der MARS-Probe: Mensch der Klasse auf der Stufe, Werte wie vorgeschlagen
static func probeheld(klasse: String, stufe: int) -> Heldwerte:
	var h := Heldwerte.erschaffe("Probe", "HUMAN", klasse)
	h.ep_dazu(int(Heldwerte.regel("ep_fuer_stufe")[stufe]))
	h.voll()
	h.zp = h.max_zp()
	return h

# Game.cheatLevel: hinauf mit EP, hinab mit Stufe, EP und Punkten wie bei einem, der so weit kam; danach voll geheilt
static func stufe_setzen(hw: Heldwerte, z: Zustand, ziel: int) -> void:
	var t := clampi(ziel, 1, int(Heldwerte.regel("max_stufe")))
	var tab: Array = Heldwerte.regel("ep_fuer_stufe")
	if t > hw.stufe: hw.ep_dazu(maxi(0, int(tab[t]) - hw.ep))
	elif t < hw.stufe:
		hw.stufe = t
		hw.ep = int(tab[t])
		hw.passe_punkte()
	heile(hw)
	z.stufe_held = hw.stufe

static func heile(hw: Heldwerte) -> void:   # Hero.restoreFully
	hw.voll()
	hw.zp = hw.max_zp()

# Game.cheatSupplies: jeder Vorrat ausser Schluesseldingen auf mindestens n, Fackeln auf zwei, ein Rauchbuendel
static func vorraete(hw: Heldwerte, z: Zustand, n := 10) -> void:
	var dinge: Dictionary = Sprache.texte.get("dinge", {})
	for id in dinge:
		if String(dinge[id].get("art", "")) != "KEY" and z.anzahl(id) < n: z.dazu(id, n - z.anzahl(id))
	var fackeln := z.beutel.filter(func(g): return String(g["base"]) == "torch").size()
	var neben = hw.ding("OFF_HAND")
	if neben != null and String(neben["base"]) == "torch": fackeln += 1
	for i in maxi(0, 2 - fackeln): z.ausruestung_dazu(Beute.fackel(0))
	if z.anzahl(Geschichte.SMOKE_BUNDLE) == 0: z.dazu(Geschichte.SMOKE_BUNDLE, 1)

static func schlicht(z: Zustand, hw: Heldwerte, base: String) -> Dictionary:   # Gear(0, base, COMMON, level)
	return {"uid": z.neue_uid(), "base": base, "rarity": "COMMON", "ilvl": hw.stufe, "plus": 0, "rolls": [], "unique": null, "name_seed": 0}

# Game.cheatWeapon / cheatOffHand: was die Hand hielt, kommt in die Tasche
static func waffe(hw: Heldwerte, z: Zustand, base: String, neben := false) -> void:
	var platz := "OFF_HAND" if neben else "MAIN_HAND"
	var alt = hw.ablegen(platz)
	if alt != null: z.beutel.append(alt)
	if base == "": return
	var g := schlicht(z, hw, base)
	var weg: Array = hw.anlegen_nebenhand(g) if neben and Beute.ist_waffe(Beute.grundform(base)) else hw.anlegen(g)
	for x in weg: z.beutel.append(x)

static func name_von(base: String) -> String:
	var g := Beute.grundform(base)
	return String(g["de"] if Sprache.aktiv() == "de" else g["en"])

static func reiter(m: Menue) -> void:
	var de := Sprache.aktiv() == "de"
	var t := func(d: String, e: String) -> String: return d if de else e
	var an_aus := func(b: bool) -> String: return t.call("an", "on") if b else t.call("aus", "off")
	var hw := m.hw
	var z := m.z
	var reihe := func(knoepfe: Array) -> void:
		var r := HBoxContainer.new()
		r.add_theme_constant_override("separation", int(6 * Menue.DP))
		for k in knoepfe: r.add_child(Erschaffung.knopf(String(k[0]), k[1]))
		m.inhalt.add_child(r)
		m.luecke(6)
	var kopf := func(w: String) -> void:
		m.luecke(6)
		m.zeile(w, 16, Stil.GOLD)
		m.luecke(4)
	m.zeile(t.call("Testmodus", "Test mode"), 18, Stil.BRIGHT)
	kopf.call(t.call("Anzeigen und Messwerte", "Displays and readings"))
	m.zeile(Menue.geraeteangaben(), 11, Stil.DIM)
	m.luecke(6)
	reihe.call([[t.call("Bildrate anzeigen: ", "Show frame rate: ") + an_aus.call(bildrate), func(): bildrate = not bildrate; m.baue()]])
	reihe.call([[t.call("Standort anzeigen: ", "Show position: ") + an_aus.call(standort), func(): standort = not standort; m.baue()]])
	kopf.call(t.call("Held", "Hero"))
	m.zeile(t.call("Stufe", "Level") + ": %d   ·   Gold: %d" % [hw.stufe, z.gold], 16)
	reihe.call([-5, -1, 1, 5].map(func(d): return [("+%d" % d) if d > 0 else ("−%d" % -d), func(): stufe_setzen(hw, z, hw.stufe + d); m.baue()]))
	reihe.call([["+1000 Gold", func(): z.gold += 1000; m.baue()], [t.call("Heilen", "Heal"), func(): heile(hw); m.baue()]])
	reihe.call([[t.call("Alle Vorräte auf mindestens 10", "All supplies to at least 10"), func():
		vorraete(hw, z)
		m.baue()
		m.meldung(t.call("Tränke, Flaschen, Essen und Zutaten aufgefüllt, zwei Fackeln und ein Rauchbündel dazu.", "Potions, flasks, food and ingredients refilled; two torches and a smoke bundle added."))]])
	var haupt = hw.ding("MAIN_HAND")
	reihe.call([[t.call("Waffe des Helden", "Hero's weapon") + ": " + (name_von(String(haupt["base"])) if haupt != null else t.call("keine", "none")) + ("  ▾" if waffen_auf else "  ›"),
		func(): waffen_auf = not waffen_auf; m.baue()]])
	if waffen_auf:
		var alle: Array = [""]
		for id in Beute.grundformen():
			if Beute.ist_waffe(Beute.grundform(id)): alle.append(id)
		for i in range(0, alle.size(), 2):
			var paar := []
			for w in alle.slice(i, i + 2):
				var zwei: bool = w != "" and bool(Beute.grundform(w)["zweihaendig"])
				paar.append([(name_von(w) if w != "" else t.call("Ohne Waffe", "No weapon")) + (" ²" if zwei else ""), func(): waffe(hw, z, w); waffen_auf = false; m.baue()])
			reihe.call(paar)
	var neben = hw.ding("OFF_HAND")
	var nb := String(neben["base"]) if neben != null else ""
	reihe.call([[t.call("Andere Hand", "Other hand") + ": " + (name_von(nb) if nb != "" else t.call("leer", "empty")) + "  ›", func():
		waffe(hw, z, NEBENHAND[(maxi(NEBENHAND.find(nb), 0) + 1) % NEBENHAND.size()] if NEBENHAND.has(nb) else "", true)
		m.baue()]])
	kopf.call(t.call("Welt", "World"))
	reihe.call([[t.call("Uhrzeit +3 h", "Time +3 h") + "  (%02d:%02d)" % [z.minuten / 60, z.minuten % 60], func():
		var alle_ := z.minuten + 3 * 60   # Game.cheatTime
		z.tag += alle_ / (24 * 60); z.minuten = alle_ % (24 * 60)
		m.baue()]])
	kopf.call("Teleport")
	reihe.call([[t.call("Dorf", "Village"), func(): m.test.emit("teleport", ["village", 11, 7, "DOWN"])]])
	m.zeile(t.call("Wald und Höhle folgen, sobald man dort gehen kann.", "Forest and cave follow once they can be walked."), 13, Stil.DIM)
	m.luecke(6)
	reihe.call([[t.call("Kapitel 1 bis kurz vor Ende", "Chapter 1 to just before its end"), func(): m.test.emit("kapitelende", [])]])
	var fs := feinde()
	if not fs.is_empty():
		kopf.call(t.call("Monster/Kampf beschwören", "Summon monster/fight"))
		var ids: Array = fs.keys()
		for i in range(0, ids.size(), 2):
			reihe.call(ids.slice(i, i + 2).map(func(id): return [String(fs[id]), func(): m.test.emit("kampf", [id])]))
		kopf.call(t.call("MARS-Probekampf", "MARS trial fight"))
		if not fs.has(probe_gegner): probe_gegner = String(ids[0])
		m.zeile(t.call("MARS: Held und Söldner gegen ", "MARS: hero and mercenary against ") + String(fs[probe_gegner]), 14)
		m.luecke(4)
		reihe.call([[t.call("Gegner wechseln  ›", "Change foes  ›"), func(): probe_gegner = String(ids[(ids.find(probe_gegner) + 1) % ids.size()]); m.baue()]])
		reihe.call([[t.call("Stufe Held und Söldner: ", "Hero and mercenary level: ") + str(probe_stufe) + "  ›", func():
			probe_stufe = STUFEN_PROBE[(STUFEN_PROBE.find(probe_stufe) + 1) % STUFEN_PROBE.size()]; m.baue()]])
		reihe.call(KLASSEN.map(func(k): return [Sprache.t(Heldwerte.lade()["klassen"][k]["name"]), func(): m.test.emit("probe", [probe_gegner, k, probe_stufe])]))
	kopf.call(t.call("Beute erzeugen", "Create loot"))
	var st: Dictionary = Heldwerte.lade()["seltenheiten"]
	var sel: Array = st.keys()
	for i in range(0, sel.size(), 3):
		reihe.call(sel.slice(i, i + 3).map(func(r): return [Sprache.t(st[r]["name"]).capitalize(), func():   # Game.cheatLoot
			var g := z.ausruestung_dazu(Beute.erzeuge(KotlinZufall.new(randi()), z.neue_uid(), hw.stufe, String(r), hw.klasse))
			m.baue()
			m.meldung(t.call("Erhalten: ", "Received: ") + Beute.name(g))]))

# cheatChapterEnd: ein begehbares Feld neben Aldric im Haus des Aeltesten, mit Blick zu ihm: [Kachel, Blick]; [] ohne Aldric
static func vor_aldric() -> Array:
	var alle = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))
	if not (alle is Dictionary and alle["karten"].has("elder")): return []
	var k := Karte.lade("elder")
	for p in alle["karten"]["elder"].get("leute", []):
		if String(p.get("id", "")) != "aldric": continue
		var a := Vector2i(int(p["x"]), int(p["y"]))
		for v in [[a + Vector2i(0, 1), "UP"], [a + Vector2i(-1, 0), "RIGHT"], [a + Vector2i(1, 0), "LEFT"]]:
			if k.begehbar(v[0]): return v
	return []
