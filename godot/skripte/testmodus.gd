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
# Noch nicht wie alt: Wald und Hoehle im Teleport, Regen, Kartenzoom, Monster auf der Karte, Sichtlinie, Bosse (es gibt Wald und Hoehle noch nicht); Varianten
# (MARS kennt noch keine Elite, 390), Kampfhilfen (wirkten alt nur im klassischen Kampf) und Absturzbericht.

const STUFEN_PROBE := [3, 5, 6, 8, 11]          # Skirmish.PROBE_LEVEL und die Stufen aus 259
const NEBENHAND := ["", "shield", "round_shield", "dagger"]   # cheatOffHand
const KLASSEN := ["FIGHTER", "WIZARD", "ROGUE", "CLERIC"]

static var waffen_auf := false
static var eroeffnung := "NORMAL"       # 399.2 (Jerry, TestTab.kt opening): wer zuerst handelt im beschworenen Kampf
static var kampfort := ""               # 493 (Jerry): Kampfort im Wald für den beschworenen Kampf; leer: nach der Kachel wie im Spiel
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

# 425 (Pruefer 01.11.: „Sehr Selten“): nur der erste Buchstabe gross, String.capitalize schreibt jedes Wort gross
static func gross_anfang(w: String) -> String:
	return w.left(1).to_upper() + w.substr(1)

static func name_von(base: String) -> String:
	var g := Beute.grundform(base)
	return String(g["de"] if Sprache.aktiv() == "de" else g["en"])

# 425 (Chef 31.10., 22:5x: „im Testmenü gerne auch sinnvolle Icons“; DESIGN-STIL „Zeichen statt Textwände“): jeder Eintrag ein Zeichen
# wie im Menü „System“ (zeichenknopf.gd): Name, Wert in Gold, Antippen tut es, Gedrückthalten erklärt; Listen (Waffen, Gegner) bleiben
# Knöpfe mit dem Namen, weil der Name dort der Inhalt ist
static func reiter(m: Menue) -> void:
	var de := Sprache.aktiv() == "de"
	var t := func(d: String, e: String) -> String: return d if de else e
	var an_aus := func(b: bool) -> String: return t.call("an", "on") if b else t.call("aus", "off")
	var hw := m.hw
	var z := m.z
	var zk := func(name_: String, wert, satz: String, tut: Callable, zeichen := "", buchstabe := "", an_ := true) -> Zeichenknopf:
		return Zeichenknopf.new(name_, wert, satz, func(): m._tue(tut), m.erklaere_zeichen, an_, zeichen, buchstabe)
	var reihe := func(knoepfe: Array) -> void:
		var r := HBoxContainer.new()
		r.add_theme_constant_override("separation", int(6 * Menue.DP))
		for k in knoepfe:
			var b := Erschaffung.knopf(String(k[0]), k[1])
			b.clip_text = false   # 425 (Pruefer 01.11.: „Wolf mit Jungwölfen“ am Rand abgeschnitten): lange Namen brechen um
			b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			r.add_child(b)
		m.inhalt.add_child(r)
		m.luecke(6)
	m.zeile(t.call("Testmodus", "Test mode"), 18, Stil.BRIGHT)
	m.luecke(8)
	m.gruppe(t.call("Anzeigen", "Displays"))
	# 425 wie alt (TestTab.kt): nur die Messwerte offen, Geraet, System und Grafik erst hinter „Gerät zeigen …“ (DeviceBox)
	var ml := Engine.get_main_loop()
	for r in Messung.zeilen(ml.root if ml is SceneTree else null): m.zeile(String(r), 13, Stil.TEXT)
	m.luecke(8)
	m.zeichenreihe([zk.call(t.call("Bildrate", "Frame rate"), an_aus.call(bildrate), t.call("Zeigt über der Welt die Bilder je Sekunde.", "Shows frames per second over the world."),
			func(): bildrate = not bildrate, "FPS", "", bildrate),
		zk.call(t.call("Standort", "Position"), an_aus.call(standort), t.call("Zeigt über der Welt Karte und Kachel des Helden.", "Shows the hero's map and tile over the world."),
			func(): standort = not standort, "PIN", "", standort)])
	m.geraet_box()
	m.luecke(6)
	m.gruppe(t.call("Held · Stufe %d", "Hero · level %d") % hw.stufe)   # 425 (Pruefer 01.11.): die Stufe einmal, nicht unter „+1“
	var stufe_satz: String = t.call("Stufe des Helden ändern; danach voll geheilt. Hinab mit Stufe, Erfahrung und Punkten wie bei einem, der so weit kam.",
		"Change the hero's level, then fully healed. Down sets level, experience and points as for one who got that far.")
	m.zeichenreihe([-5, -1, 1, 5].map(func(d): return zk.call(t.call("Stufe", "Level"), null, stufe_satz,
		func(): stufe_setzen(hw, z, hw.stufe + d), "", ("+%d" % d) if d > 0 else ("−%d" % -d))))
	m.zeichenreihe([zk.call("Gold", str(z.gold), t.call("Gibt 1000 Gold.", "Gives 1000 gold."), func(): z.gold += 1000, "COIN"),
		zk.call(t.call("Heilen", "Heal"), "%d/%d" % [hw.tp, hw.max_tp()], t.call("Trefferpunkte und Zauberplätze voll.", "Hit points and spell slots full."),
			func(): heile(hw), "HEAL"),
		zk.call(t.call("Vorräte", "Supplies"), "10", t.call("Jeder Vorrat auf mindestens 10, dazu zwei Fackeln und ein Rauchbündel.", "Every supply to at least 10, plus two torches and a smoke bundle."),
			func():
				vorraete(hw, z)
				m.meldung(t.call("Tränke, Flaschen, Essen und Zutaten aufgefüllt, zwei Fackeln und ein Rauchbündel dazu.", "Potions, flasks, food and ingredients refilled; two torches and a smoke bundle added.")), "SUPPLY")])
	var haupt = hw.ding("MAIN_HAND")
	var neben = hw.ding("OFF_HAND")
	var nb := String(neben["base"]) if neben != null else ""
	m.zeichenreihe([zk.call(t.call("Waffe", "Weapon"), name_von(String(haupt["base"])) if haupt != null else t.call("keine", "none"),
			t.call("Öffnet die Liste aller Waffen; was die Hand hielt, kommt in die Tasche.", "Opens the list of all weapons; what the hand held goes into the bag."),
			func(): waffen_auf = not waffen_auf, "SWORD", "", true),
		zk.call(t.call("Andere Hand", "Other hand"), name_von(nb) if nb != "" else t.call("leer", "empty"),
			t.call("Wechselt die andere Hand: leer, Schild, Rundschild, Dolch.", "Cycles the other hand: empty, shield, round shield, dagger."),
			func(): waffe(hw, z, NEBENHAND[(maxi(NEBENHAND.find(nb), 0) + 1) % NEBENHAND.size()] if NEBENHAND.has(nb) else "", true), "SHIELD")])
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
	m.gruppe(t.call("Welt", "World"))
	m.zeichenreihe([zk.call(t.call("Uhrzeit", "Time"), "%02d:%02d" % [z.minuten / 60, z.minuten % 60], t.call("Stellt die Uhr drei Stunden vor.", "Moves the clock three hours on."),
			func():
				var alle_ := z.minuten + 3 * 60   # Game.cheatTime
				z.tag += alle_ / (24 * 60); z.minuten = alle_ % (24 * 60), "CLOCK"),
		zk.call(t.call("Dorf", "Village"), null, t.call("Bringt den Helden auf den Dorfplatz.", "Takes the hero to the village square."),
			func(): m.test.emit("teleport", ["village", 11, 7, "DOWN"]), "HOME"),
		zk.call(t.call("Kapitelende", "Chapter end"), null, t.call("Kapitel 1 bis kurz vor Ende: Höhle geschafft, Lyra frei, Amulett in der Tasche; sprich mit Aldric.",
			"Chapter 1 to just before its end: cave done, Lyra free, amulet in the bag; talk to Aldric."), func(): m.test.emit("kapitelende", []), "FLAG")])
	var fs := feinde()
	if not fs.is_empty():
		m.gruppe(t.call("Kampf beschwören", "Summon a fight"))
		var eroeffnungen := {"NORMAL": t.call("Normal", "Normal"), "AMBUSHED": t.call("Gegner zuerst", "Foe first"), "HERO_FIRST": t.call("Held zuerst", "Hero first")}
		m.zeichenreihe([zk.call(t.call("Eröffnung", "Opening"), String(eroeffnungen[eroeffnung]), t.call("Wer im beschworenen Kampf zuerst handelt: wie im Spiel, Hinterhalt der Gegner, oder der Held.",
			"Who acts first in a summoned fight: as in the game, a foe ambush, or the hero."), func():
				var e: Array = eroeffnungen.keys()
				eroeffnung = String(e[(e.find(eroeffnung) + 1) % e.size()]), "DICE"),
			# 493: welcher Kampfort im Wald (Lichtung, Waldrand, Teich, Baum, Felsen, Steinkreis), sonst nach der Kachel wie im Spiel
			zk.call(t.call("Kampfort", "Battle place"), String(kampforte()[kampfort]), t.call("Wo der beschworene Kampf im Wald stattfindet: wie im Spiel nach dem, was um dich steht, oder einer der sechs Orte.",
				"Where the summoned fight takes place in the woods: as in the game by what stands around you, or one of the six places."), func():
					var o: Array = kampforte().keys()
					kampfort = String(o[(o.find(kampfort) + 1) % o.size()]), "PIN")])
		var ids: Array = fs.keys()
		for i in range(0, ids.size(), 2):
			reihe.call(ids.slice(i, i + 2).map(func(id): return [String(fs[id]), func(): m.test.emit("kampf", [id])]))
		m.luecke(6)
		m.gruppe(t.call("MARS-Probekampf", "MARS trial fight"))
		if not fs.has(probe_gegner): probe_gegner = String(ids[0])
		m.zeichenreihe([zk.call(t.call("Gegner", "Foes"), String(fs[probe_gegner]), t.call("Wechselt die Gegner des Probekampfs.", "Changes the foes of the trial fight."),
				func(): probe_gegner = String(ids[(ids.find(probe_gegner) + 1) % ids.size()]), "SKULL"),
			zk.call(t.call("Stufe", "Level"), null, t.call("Stufe von Held und Söldner im Probekampf; die Zahl im Kreis.", "Level of hero and mercenary in the trial fight; the number in the circle."),
				func(): probe_stufe = STUFEN_PROBE[(STUFEN_PROBE.find(probe_stufe) + 1) % STUFEN_PROBE.size()], "", str(probe_stufe))])
		m.zeile(t.call("Starten als:", "Start as:"), 13, Stil.DIM)
		m.luecke(4)
		reihe.call(KLASSEN.map(func(k): return [Sprache.t(Heldwerte.lade()["klassen"][k]["name"]), func(): m.test.emit("probe", [probe_gegner, k, probe_stufe])]))
	m.gruppe(t.call("Beute erzeugen", "Create loot"))
	var st: Dictionary = Heldwerte.lade()["seltenheiten"]
	var sel: Array = st.keys()
	for i in range(0, sel.size(), 4):
		m.zeichenreihe(sel.slice(i, i + 4).map(func(r): return zk.call(gross_anfang(Sprache.t(st[r]["name"])), null,
			t.call("Erzeugt ein Stück dieser Seltenheit auf der Stufe des Helden, passend zur Klasse.", "Creates an item of this rarity at the hero's level, suited to the class."),
			func():   # Game.cheatLoot
				var g := z.ausruestung_dazu(Beute.erzeuge(KotlinZufall.new(randi()), z.neue_uid(), hw.stufe, String(r), hw.klasse))
				m.meldung(t.call("Erhalten: ", "Received: ") + Beute.name(g)), "GEM")))

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


## 493: die Kampforte im Wald für den Reiter Test, „“ = nach der Kachel wie im Spiel (kampfort.gd platz_fuer)
static func kampforte() -> Dictionary:
	var de := Sprache.aktiv() == "de"
	return {"": "Wie im Spiel" if de else "As in game", "lichtung": "Lichtung" if de else "Clearing", "waldrand": "Waldrand" if de else "Forest edge",
		"teich": "Teich" if de else "Pond", "baum": "Baum" if de else "Fallen tree", "felsen": "Felsen" if de else "Rocks",
		"steinkreis": "Steinkreis" if de else "Stone circle"}
