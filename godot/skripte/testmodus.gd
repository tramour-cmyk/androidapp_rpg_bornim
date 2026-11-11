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
static var klang := false               # 636 A (Chef 09.11., 06:55): die letzten Effekte ueber der Welt (klang.gd protokoll_zeilen)

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
# 555 (Chef 04.11., 00:30: „Fehlt vielleicht noch mehr im Testmenü??? Wäre zum Testen noch etwas sinnvoll, damit es flott geht???“): was alt
# da war, wieder (Absturzbericht, Blende „bereit nach“, Teleport Wald und Hoehle, Kartenzoom, Monster beachten mich nicht, Bosse
# zuruecksetzen, Kampfhilfen, Monster neben den Helden holen), dazu fuers Durchspielen: Stationen von Kapitel 1 mit passendem Stand,
# Held unsterblich, Gehen dreifach, Truhen und Kraeuter zuruecksetzen, Merker der Geschichte. Noch nicht wie alt: Regen (Godot hat keinen),
# Sichtlinie (erst mit dem Nebel 505), Varianten Elite und Schimmernd (MARS kennt sie noch nicht, 390), „Letztes Ende der App“ (Android).

const STUFEN_PROBE := [3, 5, 6, 8, 11]          # Skirmish.PROBE_LEVEL und die Stufen aus 259
const NEBENHAND := ["", "shield", "round_shield", "dagger"]   # cheatOffHand
const HERKUENFTE := ["Wachsoldat", "Zauberlehrling", "Herumtreiber", "Klosterschüler"]   # 870.4: Probehelden nach Herkunft statt Klasse

static var waffen_auf := false
static var eroeffnung := "NORMAL"       # 399.2 (Jerry, TestTab.kt opening): wer zuerst handelt im beschworenen Kampf
static var kampfort := ""               # 493 (Jerry): Kampfort im Wald für den beschworenen Kampf; leer: nach der Kachel wie im Spiel
static var probe_gegner := "GRAK"
static var probe_stufe := 3
static var merker_auf := false
static var bericht_auf := false
static var alles_sichtbar := false      # 555 wie alt Game.seeAll; wirkt mit dem Nebel (505, nebel.gd)
const ZOOM_KACHELN := [0.0, 5.6, 6.75, 8.4, 10.5]   # 555 wie alt MapZoom.levels (Kacheln quer); 0 = wie unter Bedienung „Karte“

# 555 Merker der Geschichte in der Folge von Kapitel 1 (Geschichte.gd), mit kurzem Namen zum Ansehen und Setzen
const MERKER := [["intro_done", "Erwacht", "Woke up"], ["quest_started", "Auftrag Aldrics", "Aldric's task"], ["barrier_open", "Schlagbaum offen", "Barrier open"],
	["hunter_met", "Garrick getroffen", "Met Garrick"], ["krogg_hint", "Hinweis Krogg", "Krogg hint"], ["hedda_met", "Morwen getroffen", "Met Morwen"],
	["smoke_given", "Rauchbündel", "Smoke bundle"], ["grimfang_defeated", "Grimmzahn besiegt", "Grimfang beaten"], ["cave_seen", "Höhle betreten", "Cave entered"],
	["krogg_defeated", "Krogg besiegt", "Krogg beaten"], ["gate_open", "Gitter offen", "Gate open"], ["grak_defeated", "Grak besiegt", "Grak beaten"],
	["lyra_rescued", "Lyra befreit", "Lyra freed"], ["lyra_gone", "Lyra fort", "Lyra gone"], ["chapter1_done", "Kapitel 1 fertig", "Chapter 1 done"],
	["temple_seen", "Tempel gesehen", "Temple seen"], ["camp_told", "Lager erzählt", "Camp told"], ["chapter2_started", "Kapitel 2", "Chapter 2"]]

# 555 Stationen von Kapitel 1: Name, Karte, Person (oder Kachel und Blick), Merker bis dahin (Index in MERKER, ausschliesslich)
const STATIONEN := [["Garrick", "forest", "garrick", 3], ["Morwen", "deep_forest", "morwen", 5], ["Grimmzahn", "deep_forest", "grimfang", 7],
	["Höhle", "forest", [Vector2i(10, 1), "UP"], 8], ["Krogg", "cave", "krogg", 9], ["Grak", "cave", [Vector2i(10, 7), "UP"], 11],
	["Lyra", "cave", "lyra_cave", 12], ["Tempel", "temple", "lyra_temple", 14]]
# 635 (Chef, t274.13: „Lyra steht erst nach der Befreiung im Tempel; Sprung im Reiter ‚Test‘ nötig“): Station „Tempel“ = Lyra befreit
# und fort aus der Höhle, Amulett in der Tasche, vor Aldric; der Held steht neben Lyra im Tempel

## 555 (Chef 04.11., 11:52, t257 251.1: „wenn ich auf eine Spinne klicke, dann kommt die nicht“): die Spinne hat noch kein Modell
## (Streuner.da), der Kampf zeigte statt ihrer einen zweiten Wolf; ebenso Fledermaeuse. Nur Gruppen, deren Monster ein Modell haben;
## die anderen nennt ohne_modell() als Zeile
static func feinde(alle := false) -> Dictionary:
	var s = load("res://kampf/probe.gd") if ResourceLoader.exists("res://kampf/probe.gd") else null
	if s == null: return {}
	var r := {}
	for g in s.FOES:
		if alle or gruppe_da(String(g)): r[g] = s.FOES[g]
	return r
# 555 (Chef 04.11., 11:52: „wenn ich auf eine Spinne klicke, dann kommt die nicht“): jede Figur der Aufstellung braucht ihr Modell. Vorher
# zaehlten nur Gruppen, die ein Monster der Karte traegt; „Riesenspinne und Wolf“ (SPIDER) traegt keines und galt immer als da
static var _gruppe_da := {}
static func gruppe_da(g: String) -> bool:
	if _gruppe_da.has(g): return _gruppe_da[g]
	var tab: Dictionary = Tabellen.lade()
	var monsters := {}
	for m in tab.monsters: monsters[m.id] = m
	var ja := true
	for f in Streuner.AufrufS.gegner(g, monsters, Streuner.Wuerfel.new(null)):
		var fig = Streuner.Figur.new()
		fig.fighter = f
		if not FileAccess.file_exists(String(fig._model_path())): ja = false
		fig.free()
		if not ja: break
	_gruppe_da[g] = ja
	return ja
static func ohne_modell() -> Array:
	var alle := feinde(true)
	return alle.keys().filter(func(g): return not gruppe_da(String(g))).map(func(g): return String(alle[g]))

# Held und Soeldner der MARS-Probe: Mensch der Herkunft (870.4) auf der Stufe, Punkte wie die Herkunft sie verteilt, ihre Ausruestung
static func probeheld(herkunft: String, stufe: int) -> BrsHeld:
	var h := BrsHeld.fuer_spiel("Probe", "Mensch", herkunft)
	h.stufe = clampi(stufe, 1, Brs.hoechste_stufe())
	h.voll()
	return h

# Game.cheatLevel, 870.4: Heldenstufe nach BRS setzen (Stand in zustand.brs_stufe, Erfahrung am Anfang der Stufe); danach voll geheilt
static func stufe_setzen(hw: BrsHeld, z: Zustand, ziel: int) -> void:
	var t := clampi(ziel, 1, Brs.hoechste_stufe())
	var st := z.stufe_brs()
	st["stufe"] = t
	st["ep"] = 0.0
	st["ep_fert"] = 0.0
	hw.stufe = t
	heile(hw)

static func heile(hw: BrsHeld) -> void:   # Hero.restoreFully
	hw.voll()

# Game.cheatSupplies: jeder Vorrat ausser Schluesseldingen auf mindestens n, Fackeln auf zwei, ein Rauchbuendel
static func vorraete(hw: BrsHeld, z: Zustand, n := 10) -> void:
	var dinge: Dictionary = Sprache.texte.get("dinge", {})
	for id in dinge:
		if String(dinge[id].get("art", "")) != "KEY" and z.anzahl(id) < n: z.dazu(id, n - z.anzahl(id))
	var fackeln := z.beutel.filter(func(g): return String(g["base"]) == "torch").size()
	var neben = hw.ding("OFF_HAND")
	if neben != null and String(neben["base"]) == "torch": fackeln += 1
	for i in maxi(0, 2 - fackeln): z.ausruestung_dazu(Beute.fackel(0))
	if z.anzahl(Geschichte.SMOKE_BUNDLE) == 0: z.dazu(Geschichte.SMOKE_BUNDLE, 1)

static func schlicht(z: Zustand, hw: BrsHeld, base: String) -> Dictionary:   # Gear(0, base, COMMON, level)
	return {"uid": z.neue_uid(), "base": base, "rarity": "COMMON", "ilvl": hw.stufe, "guete": 0, "rolls": [], "unique": null, "name_seed": 0}

# Game.cheatWeapon / cheatOffHand: was die Hand hielt, kommt in die Tasche
static func waffe(hw: BrsHeld, z: Zustand, base: String, neben := false) -> void:
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
			var b := Stil.knopf(String(k[0]), k[1])
			b.clip_text = false   # 425 (Pruefer 01.11.: „Wolf mit Jungwölfen“ am Rand abgeschnitten): lange Namen brechen um
			b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			r.add_child(b)
		m.inhalt.add_child(r)
		m.luecke(6)
	m.zeile(t.call("Testmodus", "Test mode").to_upper(), 14, Stil.GOLD).add_theme_font_override("font", Stil.variante(3.0))   # 584: Kopf wie alt (TestTab.kt 50, MenuHead)
	m.luecke(8)
	absturz(m, t)
	m.gruppe(t.call("Anzeigen", "Displays"))
	# 425 wie alt (TestTab.kt): nur die Messwerte offen, Geraet, System und Grafik erst hinter „Gerät zeigen …“ (DeviceBox)
	var ml := Engine.get_main_loop()
	for r in Messung.zeilen(ml.root if ml is SceneTree else null): m.zeile(String(r), 15, Stil.TEXT)   # 624: lesbar (vorher 13 sp)
	m.luecke(8)
	m.zeichenreihe([zk.call(t.call("Bildrate", "Frame rate"), an_aus.call(bildrate), t.call("Zeigt über der Welt die Bilder je Sekunde.", "Shows frames per second over the world."),
			func(): bildrate = not bildrate, "FPS", "", bildrate),
		zk.call(t.call("Standort", "Position"), an_aus.call(standort), t.call("Zeigt über der Welt Karte und Kachel des Helden.", "Shows the hero's map and tile over the world."),
			func(): standort = not standort, "PIN", "", standort),
		zk.call(t.call("Klang", "Sound"), an_aus.call(klang), t.call("Zeigt über der Welt die letzten Geräusche: spielt, verklungen, abgebrochen oder nicht gestartet.", "Shows the latest sounds over the world: playing, finished, cut off or not started."),
			func(): klang = not klang, "SOUND", "", klang)])
	m.geraet_box()
	m.luecke(6)
	m.gruppe(t.call("Held · Stufe %d", "Hero · level %d") % hw.stufe)   # 425 (Pruefer 01.11.): die Stufe einmal, nicht unter „+1“
	var stufe_satz: String = t.call("Heldenstufe ändern; die Erfahrung beginnt am Anfang der Stufe, danach voll geheilt.",
		"Change the hero level; experience starts at the beginning of the level, then fully healed.")
	m.zeichenreihe([-5, -1, 1, 5].map(func(d): return zk.call(t.call("Stufe", "Level"), null, stufe_satz,
		func(): stufe_setzen(hw, z, hw.stufe + d), "", ("+%d" % d) if d > 0 else ("−%d" % -d))))
	m.zeichenreihe([zk.call("Gold", str(z.gold), t.call("Gibt 1000 Gold.", "Gives 1000 gold."), func(): z.gold += 1000, "COIN"),
		zk.call(t.call("Heilen", "Heal"), "%d/%d" % [hw.leben, hw.max_leben()], t.call("Leben und Mana voll.", "Life and mana full."),
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
	var Mars = load("res://regeln/mars.gd")
	m.zeichenreihe([zk.call(t.call("Unsterblich", "Immortal"), an_aus.call(Mars.held_unsterblich), t.call("Im Kampf fällt der Held nie unter 1 Trefferpunkt; zum Durchspielen.",
			"In a fight the hero never drops below 1 hit point; for playing through."), func(): Mars.held_unsterblich = not Mars.held_unsterblich, "", "∞", Mars.held_unsterblich),
		zk.call(t.call("Schnell", "Fast"), an_aus.call(Held.schnell > 1.0), t.call("Gehen und Laufen dreimal so schnell, damit der Weg durch Kapitel 1 flott geht.",
			"Walking and running three times as fast, to cross chapter 1 quickly."), func(): Held.schnell = 1.0 if Held.schnell > 1.0 else 3.0, "RUN", "", Held.schnell > 1.0)])
	# 470a B: die Seite „Neues Spiel“ nach BRS 1.1 bis 2.3 nur hier; 834: „Abenteuer beginnen“ beginnt ein neues Spiel mit diesem Helden, „Zurück“ fuehrt in die Welt zurueck
	m.zeichenreihe([zk.call(t.call("Erschaffung BRS", "Creation BRS"), null, t.call("Neue Seite „Neues Spiel“ nach BRS 1.1. „Abenteuer beginnen“ speichert dieses Spiel und beginnt ein neues mit dem Helden nach BRS (Fertigkeiten, Übung); gekämpft wird bis 2.3 wie bisher.",
		"New “New game” page after BRS 1.1. “Begin adventure” saves this game and starts a new one with the BRS hero (skills, practice); combat stays as before until 2.3."), func(): m.test.emit("erschaffung_brs", []), "RULES")])
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
		zk.call(t.call("Kartenzoom", "Map zoom"), zoom_name(t), t.call("Wie viele Kacheln die Karte quer zeigt, in vier Stufen wie alt; „Bedienung“ heißt wie unter System, Bedienung.",
			"How many tiles the map shows across, in four steps as before; “Controls” means as set under System, Controls."), func():
				Kamera.test_kacheln = ZOOM_KACHELN[(ZOOM_KACHELN.find(Kamera.test_kacheln) + 1) % ZOOM_KACHELN.size()]
				m.test.emit("zoom", [t.call("Karte: ", "Map: ") + zoom_name(t)]), "MAP")])
	var welt3 := [zk.call(t.call("Monster", "Monsters"), t.call("beachten nicht", "ignore") if Herde.beachten_nicht else t.call("wie im Spiel", "as in game"),
		t.call("Monster beachten mich nicht: sie laufen und stehen wie sonst, jagen und greifen nicht an, auch kein Überfall im hohen Gras. Wer selbst hineinläuft, kämpft.",
			"Monsters ignore me: they go about as ever but never hunt or attack, no ambush in tall grass either. Walk into one to fight."),
		func():
			Herde.beachten_nicht = not Herde.beachten_nicht
			m.meldung(t.call("Monster laufen und stehen wie sonst, greifen aber nicht an. Wer selbst hineinläuft, kämpft.", "Monsters go about as ever but never attack. Walk into one to fight.")
				if Herde.beachten_nicht else t.call("Monster jagen dich wieder.", "Monsters hunt you again.")), "HAND", "", Herde.beachten_nicht)]
	if ResourceLoader.exists("res://skripte/nebel.gd"):
		welt3.append(zk.call(t.call("Sichtlinie", "Line of sight"), an_aus.call(not alles_sichtbar), t.call("Aus: kein Nebel, keine Sichtlinie, alle Monster der Karte sind zu sehen. Erkundet wird wie sonst.",
			"Off: no fog, no line of sight, every monster on the map is visible. Exploration works as usual."), func(): alles_sichtbar = not alles_sichtbar, "", "◎", not alles_sichtbar))
	welt3.append(zk.call(t.call("Bosse", "Bosses"), null, t.call("Bosse zurücksetzen: Grimmzahn, Krogg und Grak sind wieder da, Morwen gibt das Rauchbündel noch einmal.",
		"Respawn bosses: Grimfang, Krogg and Grak are back, Morwen gives the smoke bundle again."), func():
			for f in [Geschichte.GRIMFANG_DEFEATED, Geschichte.KROGG_DEFEATED, Geschichte.GRAK_DEFEATED, Geschichte.SMOKE_GIVEN]: z.flaggen.erase(f)
			m.test.emit("ort_neu", [t.call("Grimmzahn, Krogg und Grak sind zurück.", "Grimfang, Krogg and Grak are back.")]), "SKULL"))
	m.zeichenreihe(welt3)
	var welt4 := [zk.call(t.call("Truhen", "Chests"), null, t.call("Alle Truhen wieder voll und alle Heilkräuter wieder da.", "Every chest full again and every healing herb back."), func():
			for f in z.flaggen.keys():
				if String(f).begins_with("kiste:"): z.flaggen.erase(f)
			z.gepflueckt.clear()
			m.test.emit("ort_neu", [t.call("Truhen und Kräuter zurückgesetzt.", "Chests and herbs reset.")]), "GEM")]
	# 555 (Chef 04.11., 20:11: „warum heißt das Ding Merker?“; Vorschlag Sokrates): „Geschichte“, Stand der Geschichte von Kapitel 1
	welt4.append(zk.call(t.call("Geschichte", "Story"), "%d" % MERKER.filter(func(f): return z.has(String(f[0]))).size(),
		t.call("Stand der Geschichte von Kapitel 1: was schon geschehen ist. Antippen setzt oder löscht einen Schritt, „Ort neu“ zeigt den Ort danach.",
			"Story so far in chapter 1. A tap sets or clears a step; “Reload place” shows the place afterwards."), func(): merker_auf = not merker_auf, "FLAG", "", merker_auf))
	m.zeichenreihe(welt4)
	if merker_auf:
		for i in range(0, MERKER.size(), 2):
			reihe.call(MERKER.slice(i, i + 2).map(func(f): return [String(f[1] if de else f[2]) + ": " + an_aus.call(z.has(String(f[0]))), func():
				if z.has(String(f[0])): z.flaggen.erase(String(f[0]))
				else: z.setze(String(f[0]))
				m.baue()]))
		reihe.call([[t.call("Ort neu", "Reload place"), func(): m.test.emit("ort_neu", [])]])
	# 500 (Chef 03.11., 07:24): was nur die Probeknoepfe rechts in der Welt schalteten, hier
	var welt2 := [zk.call(t.call("Tag / Nacht", "Day / night"), null, t.call("Schaltet zwischen Mittag und 23 Uhr; die Leute folgen der Uhr.", "Switches between noon and 11 pm; the people follow the clock."),
		func(): m.test.emit("nacht", []), "", "☾")]
	if DirAccess.dir_exists_absolute("res://daten/tiere"):
		welt2.append(zk.call(t.call("Tiere", "Animals"), null, t.call("Stellt alle Tiermodelle zum Anschauen um den Helden; noch einmal: weg.", "Puts every animal model around the hero to look at; again: gone."),
			func(): m.test.emit("tiere", []), "STEPS"))
	if GrasBausatz.da():   # 804: Gras des Kits oder unser altes, gleich am Ort; Bilder/s vorher und nachher unter „Messen“
		welt2.append(zk.call(t.call("Gras", "Grass"), null, t.call("Gras und Blumen aus Grass & Wind oder unser altes Gras, gleich hier am Ort.",
			"Grass and flowers from Grass & Wind or our old grass, right here."), func(): m.test.emit("gras", []), "", "G"))
	if KampfEffekte.da():   # 806: Lichtschächte im Kampfort an oder aus, gilt ab dem nächsten Kampf (Bilder/s vorher und nachher; Bodennebel seit Test 277 aus)
		welt2.append(zk.call(t.call("Lichtschächte", "Light shafts"), null, t.call("Lichtschächte im Kampfort an oder aus; gilt ab dem nächsten Kampf.",
			"Light shafts at the battle place on or off; from the next battle on."), func(): m.test.emit("kampfeffekte", []), "", "N"))
	# 806 (Fund t277.7): der nächste Kampf hält vor dem ersten Zug an und misst je Baustein Bild-, Grafik- und Zeichenzeit
	welt2.append(zk.call(t.call("Kampf messen", "Measure battle"), null, t.call("Der nächste Kampf misst etwa 40 s lang, was jeder Baustein (Gras, Tusche, Schatten …) an Zeit kostet; Ergebnis über dem Kampfort und unter „Gerät zeigen“.",
		"The next battle measures for about 40 s what each part (grass, ink, shadows …) costs; result above the battle place and under “Show device”."), func(): m.test.emit("kampfmessen", []), "", "M"))
	m.zeichenreihe(welt2)
	m.gruppe("Teleport")
	var orte := [[t.call("Dorf", "Village"), "village", 11, 7, "DOWN", "HOME", ""], [t.call("Wald", "Forest"), "forest", 10, 20, "UP", "", "W"],
		[t.call("Tiefer Wald", "Deep forest"), "deep_forest", 1, 18, "RIGHT", "", "T"], [t.call("Höhle", "Cave"), "cave", 10, 18, "UP", "", "H"]]
	m.zeichenreihe(orte.filter(func(o): return da(String(o[1]))).map(func(o): return zk.call(String(o[0]), null,
		t.call("Bringt den Helden dorthin; der Stand der Geschichte bleibt.", "Takes the hero there; the story stays as it is."),
		func(): m.test.emit("teleport", [o[1], o[2], o[3], o[4]]), String(o[5]), String(o[6]))))
	m.zeile(t.call("Stationen von Kapitel 1, mit dem Stand, den ein Spieler dort hat:", "Stations of chapter 1, with the story as a player has it there:"), 13, Stil.DIM)
	m.luecke(4)
	var st_: Array = []
	for i in STATIONEN.size():
		var s_: Array = STATIONEN[i]
		if not da(String(s_[1])): continue
		st_.append(zk.call(String(s_[0]), null, station_satz(i, de), func(): m.test.emit("station", [String(s_[0])]), "", str(i + 1)))
	st_.append(zk.call(t.call("Kapitelende", "Chapter end"), null, t.call("Kapitel 1 bis kurz vor Ende: Höhle geschafft, Lyra frei, Amulett in der Tasche; sprich mit Aldric.",
		"Chapter 1 to just before its end: cave done, Lyra free, amulet in the bag; talk to Aldric."), func(): m.test.emit("kapitelende", []), "", str(STATIONEN.size() + 1)))
	for i in range(0, st_.size(), 4): m.zeichenreihe(st_.slice(i, i + 4))
	m.gruppe(t.call("Kampfhilfen", "Fight aids"))
	m.zeichenreihe([zk.call(t.call("Kritisch", "Critical"), an_aus.call(Mars.held_immer_krit), t.call("Held trifft immer kritisch: jeder Waffentreffer des Helden ist kritisch, so lässt sich der Killerschlag testen.",
			"Hero always crits: every weapon hit of the hero is critical, to test the killing blow."), func(): Mars.held_immer_krit = not Mars.held_immer_krit, "BLOOD", "", Mars.held_immer_krit),
		zk.call(t.call("Rettung", "Saves"), t.call("nie", "never") if Mars.gegner_ohne_rettung else t.call("wie im Spiel", "as in game"),
			t.call("Gegner bestehen keine Rettungswürfe: Zauber, denen man ausweichen kann, treffen immer voll.", "Foes fail every save: spells one can dodge always hit in full."),
			func(): Mars.gegner_ohne_rettung = not Mars.gegner_ohne_rettung, "", "✗", Mars.gegner_ohne_rettung)])     # 870.5: Schalter BRS/SRD weg, BRS immer
	# 415 (Jerry, Chef „415 jetzt“ 02.11., 10:55): Handyprobe der Beams-Probe im Kampfort (kampf/strahlprobe.gd)
	m.zeichenreihe([zk.call(t.call("Strahlen", "Beams"), null, t.call("415: drei Strahlen der Beams-Probe im Kampfort, mit Bildern je Sekunde; Renderer umschaltbar.",
		"415: three beams of the Beams sample in the battle place, with frames per second; renderer switchable."), func(): m.test.emit("strahlen", []), "FPS")])
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
		var ohne := ohne_modell()
		if not ohne.is_empty(): m.zeile(t.call("Noch ohne Modell: ", "No model yet: ") + ", ".join(ohne), 13, Stil.DIM)
		m.luecke(6)
		# 555 wie alt („Antippen: neben den Helden holen“): ein Monster der Karte neben den Helden, 2 Minuten friedlich, um ihm zuzusehen
		var holbar := monster_namen()
		if not holbar.is_empty():
			m.zeile(t.call("Neben den Helden holen, 2 Minuten friedlich:", "Bring beside the hero, peaceful for 2 minutes:"), 13, Stil.DIM)
			m.luecke(4)
			var arten: Array = holbar.keys()
			for i in range(0, arten.size(), 2):
				reihe.call(arten.slice(i, i + 2).map(func(a): return [String(holbar[a]), func(): m.test.emit("holen", [a])]))
			m.luecke(6)
		m.gruppe(t.call("MARS-Probekampf", "MARS trial fight"))
		if not fs.has(probe_gegner): probe_gegner = String(ids[0])
		m.zeichenreihe([zk.call(t.call("Gegner", "Foes"), String(fs[probe_gegner]), t.call("Wechselt die Gegner des Probekampfs.", "Changes the foes of the trial fight."),
				func(): probe_gegner = String(ids[(ids.find(probe_gegner) + 1) % ids.size()]), "SKULL"),
			zk.call(t.call("Stufe", "Level"), null, t.call("Stufe von Held und Söldner im Probekampf; die Zahl im Kreis.", "Level of hero and mercenary in the trial fight; the number in the circle."),
				func(): probe_stufe = STUFEN_PROBE[(STUFEN_PROBE.find(probe_stufe) + 1) % STUFEN_PROBE.size()], "", str(probe_stufe))])
		m.zeile(t.call("Starten als:", "Start as:"), 13, Stil.DIM)
		m.luecke(4)
		for i in range(0, HERKUENFTE.size(), 2):   # 870.4: zwei je Reihe, „Klosterschüler“ passt nicht in ein Viertel (testmenue_mass_425)
			reihe.call(HERKUENFTE.slice(i, i + 2).map(func(k): return [ErschaffungBrs.herkunft_name(k), func(): m.test.emit("probe", [probe_gegner, k, probe_stufe])]))
	m.gruppe(t.call("Beute erzeugen", "Create loot"))
	var st: Dictionary = BrsHeld.daten()["seltenheiten"]
	var sel: Array = st.keys()
	for i in range(0, sel.size(), 4):
		m.zeichenreihe(sel.slice(i, i + 4).map(func(r): return zk.call(gross_anfang(Sprache.t(st[r]["name"])), null,
			t.call("Erzeugt ein Stück dieser Seltenheit auf der Stufe des Helden.", "Creates an item of this rarity at the hero's level."),
			func():   # Game.cheatLoot
				var g := z.ausruestung_dazu(Beute.erzeuge(KotlinZufall.new(randi()), z.neue_uid(), hw.stufe, String(r), hw))   # 870.6: nach seinen Fertigkeiten
				m.meldung(t.call("Erhalten: ", "Received: ") + Beute.name(g)), "GEM")))

# cheatChapterEnd: ein begehbares Feld neben Aldric im Haus des Aeltesten, mit Blick zu ihm: [Kachel, Blick]; [] ohne Aldric
static func vor_aldric() -> Array: return vor_person("elder", "aldric")

# ein begehbares Feld neben der Person, mit Blick zu ihr: [Kachel, Blick]; [] ohne sie
static func vor_person(karte_id: String, person: String) -> Array:
	var alle = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))
	if not (alle is Dictionary and alle["karten"].has(karte_id)): return []
	var k := Karte.lade(karte_id)
	for p in alle["karten"][karte_id].get("leute", []):
		if String(p.get("id", "")) != person: continue
		var a := Vector2i(int(p["x"]), int(p["y"]))
		for v in [[a + Vector2i(0, 1), "UP"], [a + Vector2i(-1, 0), "RIGHT"], [a + Vector2i(1, 0), "LEFT"], [a + Vector2i(0, -1), "DOWN"]]:
			if k.begehbar(v[0]): return v
	return []

# 555: gibt es die Karte im Spiel (Modell aus dem Bau)?
static func da(karte_id: String) -> bool:
	return karte_id == "village" or FileAccess.file_exists("res://daten/%s.bin" % Gebiet.datei(karte_id))

static func zoom_name(t: Callable) -> String:
	if Kamera.test_kacheln <= 0.0: return t.call("Bedienung", "Controls")
	return ("%.2f" % Kamera.test_kacheln).trim_suffix("0").trim_suffix("0").trim_suffix(".").replace(".", "," if Sprache.aktiv() == "de" else ".")

static func station_satz(i: int, de: bool) -> String:
	var s_: Array = STATIONEN[i]
	var bis: Array = MERKER.slice(0, int(s_[3])).map(func(f): return String(f[1] if de else f[2]))
	return ("Bringt den Helden zu %s. Merker wie bei einem Spieler, der so weit kam: %s; alle späteren gelöscht." if de
		else "Takes the hero to %s. Flags as for a player who got that far: %s; all later ones cleared.") % [String(s_[0]), ", ".join(PackedStringArray(bis))]

# 555: setzt den Stand der Station [name] (Merker bis dahin, spaetere geloescht, Schluesseldinge passend) und gibt
# [Karte, Kachel, Blick, Satz] zurueck; [] ohne die Station oder ihre Karte
static func station(name_: String, z: Zustand) -> Array:
	for s_ in STATIONEN:
		if String(s_[0]) != name_: continue
		var ziel: Array = s_[2] if s_[2] is Array else vor_person(String(s_[1]), String(s_[2]))
		if ziel.is_empty(): return []
		for i in MERKER.size():
			if i < int(s_[3]): z.setze(String(MERKER[i][0]))
			else: z.flaggen.erase(String(MERKER[i][0]))
		var dinge := {Geschichte.SMOKE_BUNDLE: 1 if z.has(Geschichte.SMOKE_GIVEN) and not z.has(Geschichte.KROGG_DEFEATED) else 0,
			"rusty_key": 0, "grak_key": 1 if z.has(Geschichte.GRAK_DEFEATED) and not z.has(Geschichte.LYRA_RESCUED) else 0,
			"sun_amulet": 1 if z.has(Geschichte.GRAK_DEFEATED) else 0}
		for d in dinge:
			if z.anzahl(d) < int(dinge[d]): z.dazu(d, int(dinge[d]) - z.anzahl(d))
			elif z.anzahl(d) > int(dinge[d]): z.weg(d, z.anzahl(d) - int(dinge[d]))
		var de := Sprache.aktiv() == "de"
		return [String(s_[1]), ziel[0], String(ziel[1]), ("Station %s: Stand wie bei einem Spieler, der so weit kam." if de else "Station %s: the story as for a player who got this far.") % name_]
	return []

# 555: die Monster der Karte, die es im Spiel gibt (Streuner.da), mit Namen aus den Regeln
static func monster_namen() -> Dictionary:
	var tab = Tabellen.lade()     # 870.6: nach BRS (regeln/tabellen.gd)
	if not tab is Dictionary: return {}
	var namen := {}
	for mo in tab["monsters"]: namen[String(mo["id"])] = String(mo["de"] if Sprache.aktiv() == "de" else mo["en"])
	# 494 (Prüfer 512b): Riesenegel und Säureschnecke heißen nach LISTE-FIGUREN wie im Kampf (aufruf.gd NAMEN_494), nicht Stirge, Ockergallerte
	var neu: Dictionary = load("res://kampf/aufruf.gd").NAMEN_494
	for paar in [["stirge", "LEECHES"], ["ochre_jelly", "SLUGS"], ["zombie", "WIEDERGAENGER"], ["ghoul", "GRABHUND"]]:     # 506
		if namen.has(paar[0]) and neu.has(paar[1]): namen[paar[0]] = String(neu[paar[1]][0 if Sprache.aktiv() == "de" else 1])
	var r := {}
	for a in Streuner.GRUPPE:
		if namen.has(a) and Streuner.da(String(a)): r[a] = namen[a]
	return r

# 555 wie alt CrashBox: das Protokoll des vorigen Laufs (Messung.voriges_protokoll) mit seinen Fehlern; zeigen, kopieren
static func absturz(m: Menue, t: Callable) -> void:
	var b := Messung.bericht(Messung.voriges_protokoll())
	var jetzt := Messung.fehler(1000)
	m.zeile(t.call("Letzter Lauf: ", "Last run: ") + (String(b["datei"]).trim_prefix("godot").trim_suffix(".log").replace("T", " ") + t.call(", Fehler: ", ", errors: ") + str(b["fehler"].size()) if not b.is_empty() else "–")
		+ t.call("  ·  seit Start: ", "  ·  since start: ") + str(jetzt.size()), 13, Stil.TEXT)
	if b.is_empty() and jetzt.is_empty(): return
	var text: String = t.call("Voriger Lauf (%s), Fehler:\n", "Previous run (%s), errors:\n") % (b.get("datei", "–")) + "\n".join(PackedStringArray(b.get("fehler", [])))
	text += t.call("\n\nVoriger Lauf, Ende:\n", "\n\nPrevious run, end:\n") + String(b.get("ende", "–"))
	text += t.call("\n\nSeit Start, Fehler:\n", "\n\nSince start, errors:\n") + "\n".join(PackedStringArray(jetzt))
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(6 * Menue.DP))
	r.add_child(Stil.knopf(t.call("Absturzbericht schließen", "Hide crash report") if bericht_auf else t.call("Absturzbericht zeigen …", "Show crash report…"), func(): bericht_auf = not bericht_auf; m.baue()))
	if bericht_auf:
		var k := Stil.knopf(t.call("Kopieren", "Copy"), func(): DisplayServer.clipboard_set(text); m.meldung(t.call("Absturzbericht kopiert.", "Crash report copied.")))
		k.size_flags_stretch_ratio = 0.5
		r.add_child(k)
	m.inhalt.add_child(r)
	m.luecke(6)
	if bericht_auf: m.zeile(text.left(3000) + ("\n…" if text.length() > 3000 else ""), 10, Stil.TEXT)


## 493: die Kampforte im Wald für den Reiter Test, „“ = nach der Kachel wie im Spiel (kampfort.gd platz_fuer)
static func kampforte() -> Dictionary:
	var de := Sprache.aktiv() == "de"
	return {"": "Wie im Spiel" if de else "As in game", "lichtung": "Lichtung" if de else "Clearing", "waldrand": "Waldrand" if de else "Forest edge",
		"teich": "Teich" if de else "Pond", "baum": "Baum" if de else "Fallen tree", "felsen": "Felsen" if de else "Rocks",
		"steinkreis": "Steinkreis" if de else "Stone circle"}
