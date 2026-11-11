# 399.2 (Spielfassung, Perikles 28.10., 12:4x; Chef 12:34 „Ich habe jetzt keinen funktionstüchtigen Kampf“): der Kampfort aus einem
# Aufruf, ohne Probe-Schalter. Die Welt hängt einen Knoten mit diesem Skript ein und ruft starte(): Gegnergruppe (Schlüssel wie
# probe.gd FOES), der Held als Toms BrsHeld (oder ein fertiges MARS-Blatt wie tabellen.json „probe“), Söldner wahlweise, Kampfort,
# Tageszeit, Tränke, wahlweise die Beute (Callable, gibt die Ausrüstung eines Siegs als [{gear, name, rarity}] wie Loot.drops,
# Toms skripte/beute.gd; sie steht im Endfeld und in lohn.gear). Am Ende kommt das Signal ende(ergebnis, tp, lohn): ergebnis WON, LOST, FLED (NONE: ohne LP kein Kampf), tp die
# Trefferpunkte je Kämpfer der Gruppe („hero“, „merc“), lohn wie regeln/lohn.gd nach einem Sieg; danach entfernt sich der Knoten.
extends Node

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Kampfort = preload("res://kampf/kampfort.gd")
const Figur = preload("res://kampf/figur.gd")

signal ende(ergebnis: String, tp: Dictionary, lohn: Dictionary)

var kampf: Node
var tabellen: Dictionary


## 494 (Kauf 348.12c, LISTE-FIGUREN): der Riesenegel ersetzt die Stirge, die Säureschnecke die Ockergallerte
const NAMEN_494 := {"LEECHES": ["Riesenegel", "Giant Leech"], "SLUGS": ["Säureschnecke", "Acid Slug"],
	# 506 (348.12c, LISTE-FIGUREN): der Wiedergänger ersetzt den Zombie, der Grabhund den Ghul (Regeln unter dem alten Namen)
	"WIEDERGAENGER": ["Wiedergänger", "Revenant"], "WIEDERGAENGER3": ["Wiedergänger", "Revenant"],
	"GRABHUND": ["Grabhund", "Grave Hound"], "GRABHUNDE": ["Grabhund", "Grave Hound"]}


## Die Gegner einer Gruppe (Aufstellung, Namen und Aussehen wie im Probekampf; probe.gd ruft das auch)
static func gegner(foe: String, monsters: Dictionary, dice) -> Array:
	var foes := []
	var lineup: Array = {
		"WOLVES": [["wolf1", Mars.WOLF, Vector2i(0, 0)], ["wolf2", Mars.WOLF, Vector2i(0, 1)], ["wolf3", Mars.WOLF, Vector2i(1, 0)]],
		"GRAK": [["grak", Mars.GRAK, Vector2i(0, 0)]],
		"SPIDER": [["wolf1", Mars.WOLF, Vector2i(0, 0)], ["spider", Mars.SPIDER, Vector2i(1, 0)]],
		"SCOUT": [["gob1", Mars.CALLED, Vector2i(0, 0)], ["scout", Mars.SCOUT, Vector2i(1, 0)]],
		# 348.9: drei Riesenratten im Körper des Wolfs; 535: mit eigenen Regeln (ART)
		"RATS": [["wolf1", Mars.WOLF, Vector2i(0, 0)], ["wolf2", Mars.WOLF, Vector2i(0, 1)], ["wolf3", Mars.WOLF, Vector2i(1, 0)]],
		# 348.7: drei Riesenfledermäuse (fledermaus.py) im Körper des Wolfs; 535: mit eigenen Regeln (ART)
		"BATS": [["wolf1", Mars.WOLF, Vector2i(0, 0)], ["wolf2", Mars.WOLF, Vector2i(0, 1)], ["wolf3", Mars.WOLF, Vector2i(1, 0)]],
		# 348.7: Grimmzahn allein vorn, zwei Wölfe seiner Leibwache (Packs.kt guard) hinten an den Seiten; im Aussehen, Regeln
		# noch die des Wolfs (vorn rechts stand ihm der hintere Wolf auf dem Rücken, hinten verschwand er hinter der Wache: Prüfer Runden 2, 3)
		"GRIMM": [[Figur.GRIMM, Mars.WOLF, Vector2i(0, 0)], ["wolf1", Mars.WOLF, Vector2i(1, 0)], ["wolf2", Mars.WOLF, Vector2i(1, 1)]],
		# 348.7: drei Goblins, je eines der Kits (goblin.py), mit den Regeln des Goblins
		"GOBLINS": [["gob1", Mars.CALLED, Vector2i(0, 0)], ["gob2", Mars.CALLED, Vector2i(0, 1)], ["gob3", Mars.CALLED, Vector2i(1, 0)]],
		# 348.7: drei Goblin-Späher, je eines der Kits (goblin.py ART=goblin_archer), mit den Regeln des Spähers
		"SCOUTS": [["gob1", Mars.SCOUT, Vector2i(0, 0)], ["gob2", Mars.SCOUT, Vector2i(0, 1)], ["gob3", Mars.SCOUT, Vector2i(1, 0)]],
		# 348.7: drei Goblin-Schamanen (goblin.py ART=goblin_shaman) im Körper des Goblins; 535: eigene Werte, Ansagen noch die des Goblins
		"SHAMANS": [["gob1", Mars.CALLED, Vector2i(0, 0)], ["gob2", Mars.CALLED, Vector2i(0, 1)], ["gob3", Mars.CALLED, Vector2i(1, 0)]],
		# 348.7: drei Kobolde (goblin.py ART=kobold) im Körper des Goblins; 535: mit eigenen Regeln (ART)
		"KOBOLDS": [["gob1", Mars.CALLED, Vector2i(0, 0)], ["gob2", Mars.CALLED, Vector2i(0, 1)], ["gob3", Mars.CALLED, Vector2i(1, 0)]],
		# 494 (Wochenziel 03.11. Reihe 3): das Wildschwein allein wie im alten Spiel (Roamers.kt, kein Rudel), mit seinen eigenen Regeln
		# (Monsters.kt boar in tabellen.json, MARS allgemein), im Bild der gekaufte Keiler (kauftier.py TIER=keiler)
		"BOARS": [["boar", "boar", Vector2i(0, 0)]],
		# 494: der Riesen-Hundertfüßer allein (Monsters.kt giant_centipede), im Bild der gekaufte (kauftier.py TIER=hundertfuesser)
		"CENTIPEDES": [["centipede", "giant_centipede", Vector2i(0, 0)]],
		# 494 (von Tom, 492: Krogg bewacht in der Höhle den rostigen Schlüssel): Krogg allein wie im alten Spiel (Packs.kt ohne Rudel für
		# bugbear), seine Regeln aus Monsters.kt (tabellen.json, Überraschungsschlag), Morwens Rauch in MARS (lage „rauch“)
		"KROGG": [["krogg", "bugbear", Vector2i(0, 0)]],
		# 494 (Kauf 348.12c): Riesenegel statt der Stirge, Säureschnecke statt der Ockergallerte, je allein wie im alten Spiel (kein Rudel),
		# Regeln aus Monsters.kt (stirge, ochre_jelly), Namen nach LISTE-FIGUREN; im Bild die gekauften (kauftier.py TIER=egel, schnecke)
		"LEECHES": [["leech", "stirge", Vector2i(0, 0)]],
		"SLUGS": [["slug", "ochre_jelly", Vector2i(0, 0)]],
		# 494 (Jerry 03.11., 18:4x): Riesenratte, Riesenfledermaus, Riesenspinne je allein mit ihren eigenen Regeln wie im alten Spiel
		# (Roamers.kt: ein Monster, Packs.kt ohne Rudel für sie; Monsters.kt giant_rat, giant_bat, giant_spider). RATS, BATS, SPIDER
		# bleiben die Probekämpfe von 348.7/348.9 (drei Felle mit Regeln des Wolfs, Spinne neben einem Wolf)
		"RATTE": [["rat", Mars.WOLF, Vector2i(0, 0)]],     # 577: Körper des Wolfs, Kennung und Regeln der eigenen Art (ART)
		"FLEDERMAUS": [["bat", Mars.WOLF, Vector2i(0, 0)]],
		"SPINNE": [["spider", Mars.SPIDER, Vector2i(0, 0)]],
		# 506: drei Skelette wie im alten Spiel (MonsterKit.kt skeleton: Kurzschwert und Helm, Kurzschwert und Schild, Speer und Helm),
		# Regeln aus Monsters.kt skeleton (tabellen.json), im Bild der gekaufte Skelettritter (kaufskelett.py, je Nummer ein Kit)
		"SKELETONS": [["skel1", "skeleton", Vector2i(0, 0)], ["skel2", "skeleton", Vector2i(0, 1)], ["skel3", "skeleton", Vector2i(1, 0)]],
		# 506: auf der Karte je allein wie im alten Spiel (Roamers.kt ein Monster, Packs.kt ohne Rudel für Untote); das Kit bringt das
		# Monster der Karte mit („fell“), im Probekampf je Nummer. Wiedergänger (Regeln Monsters.kt zombie, kaufuntoter.py) und Grabhund
		# (Regeln ghoul, kaufgrabhund.py); WIEDERGAENGER3 und GRABHUNDE zeigen alle drei Kits bzw. Häute nebeneinander (Probe, Testmenü)
		"SKELETT": [["skel1", "skeleton", Vector2i(0, 0)]],
		"WIEDERGAENGER": [["zombie1", "zombie", Vector2i(0, 0)]],
		"GRABHUND": [["hound1", "ghoul", Vector2i(0, 0)]],
		"WIEDERGAENGER3": [["zombie1", "zombie", Vector2i(0, 0)], ["zombie2", "zombie", Vector2i(0, 1)], ["zombie3", "zombie", Vector2i(1, 0)]],
		"GRABHUNDE": [["hound1", "ghoul", Vector2i(0, 0)], ["hound2", "ghoul", Vector2i(0, 1)], ["hound3", "ghoul", Vector2i(1, 0)]],
	}.get(foe, [])
	Figur.ersatz_art = {"RATS": "giant_rat", "BATS": "giant_bat", "SHAMANS": Figur.SHAMAN, "KOBOLDS": Figur.KOBOLD, "BOARS": "kauf_keiler", "CENTIPEDES": "kauf_hundertfuesser", "LEECHES": "kauf_egel", "SLUGS": "kauf_schnecke", "RATTE": "giant_rat", "FLEDERMAUS": "giant_bat"}.get(foe, "")
	# 348.12f eingebaut (Chef 28.10., 11:50: Kaufwolf abgenommen, Archiv 27.10., 21:51: „eigener entfällt“): Wölfe sind der gekaufte
	# Wolf, sobald er gebaut beiliegt (godot-kampf.yml „Modelle bauen“); ERSATZ geht weiter vor
	if foe in ["WOLVES", "GRIMM", "SPIDER", "RUDEL"] and FileAccess.file_exists("res://kampf/daten/kaufwolf-info.json"):
		Figur.ersatz_art = "kaufwolf"
	if foe == "RUDEL":
		return rudel(monsters, dice)
	for e in lineup:
		var m: Dictionary = monsters[e[1]]
		if e[0] == Figur.GRIMM:     # Name aus den Regeln (Monsters.kt dire_wolf)
			# 533 (Abgleich 512, Sokrates; alt Monsters.kt dire_wolf): Grimmzahn mit seinen eigenen Werten (RK 14, 4W10+4 TP,
			# Reißzähne +4, 2W6+1, Boss: keine Flucht, kein Autopilot; 450 EP, 4W10 Gold, großer Heiltrank zu 50 %); Bewegung,
			# Texte und Modell bleiben die des Wolfs (id „wolf“), der Lohn zählt die Leibwache wie alt (pack „dire_wolf“, je 0,25)
			m = (monsters.get("dire_wolf", m) as Dictionary).duplicate(true)
			# 533 (Chef 04.11., 20:30: in der Blende „gelbe Augen“, ein Satz des Wolfs; Sokrates 20:58 „einmal umdrehen“ wie 577):
			# die id bleibt dire_wolf (Blende, Texte, Klang, Lohn), der Körper ist der des Wolfs (Modell, Bewegung), die Regeln des
			# Rudels wie beim Wolf (Mars.wolfig)
			m.koerper = Mars.WOLF
			m.pack = "dire_wolf"
			m.de = "Grimmzahn, der Leitwolf"
			m.en = "Grimfang the Alpha"
		elif foe == "GRIMM":     # 533: seine Leibwache wie alt (Packs.kt guard)
			m = m.duplicate(true)
			var fuehrer: Dictionary = monsters.get("dire_wolf", m)
			m.atk = int(fuehrer.atk) + int(LEIBWACHE.atk_shift)
			m.dmg = LEIBWACHE.dmg
			m.chance = float(Brs.begleiter("Leibwache", "dire_wolf").get("chance", LEIBWACHE.chance))     # 870.3: werte.json
			m.rudel = "Leibwache"     # 870.3: Werte nach BRS aus werte.json „merkmale“ „rudel“ (brs_kampf.gd gegner)
			m.anfuehrer = "dire_wolf"
			m.xp = 0     # lohn.gd zählt sie als Begleiter des Leitwolfs (werte.json „erfahrung_anteil“), nicht einzeln
			m.flee = LEIBWACHE.flee
		elif ART.has(foe) and monsters.has(ART[foe]):
			# 535 (Abgleich 512, Sokrates: „Ratten und Fledermäuse als Wölfe, Schamane ohne Heilen“): Werte, Name, Lohn und Regeln
			# der eigenen Art (Monsters.kt giant_rat, giant_bat, kobold, goblin_shaman); Bewegung und Modell bleiben die des Körpers
			# („koerper“, Mars.koerper_of); 577: die id bleibt die eigene Art (Regeln, Texte, Klang, Lohn); das Rudel zählt nach der Art
			# (Kobolde wie alt Packs.kt kobolds, je 0,4)
			m = (monsters[ART[foe]] as Dictionary).duplicate(true)
			m.koerper = e[1]
			m.pack = ART[foe]
		elif foe in NAMEN_494:     # 494: Name nach LISTE-FIGUREN (Regeln noch unter dem alten Namen)
			m = m.duplicate()
			m.de = NAMEN_494[foe][0]
			m.en = NAMEN_494[foe][1]
		foes.append(Mars.monster_fighter(e[0], e[2], m, dice.roll_expr(m.hp)))
		if foe == "GRIMM" and e[0] != Figur.GRIMM:
			foes[foes.size() - 1].follows = Figur.GRIMM     # 533: fällt Grimmzahn, flieht die Leibwache (mars.gd _pack_flees)
	return foes


## 535: Gruppen, deren Tiere eigene Regeln haben, aber den Körper einer anderen Art tragen (gegner)
const ART := {"RATS": Mars.RAT, "BATS": Mars.BAT, "KOBOLDS": Mars.KOBOLD, "SHAMANS": Mars.SHAMAN, "RATTE": Mars.RAT, "FLEDERMAUS": Mars.BAT}     # 494: je allein wie alt


## 399.2a (Chef 28.10., 14:19, Archiv: „Wolf mit 1 bis 2 Jungwölfen“, der Held allein): der Waldkampf wie im alten Spiel
## (Packs.kt cubs): vorn der Wolf, dazu 1–2 Jungwölfe, halb so groß (scale 0,55), Biss 1W3, Angriff −1; neu, weil MARS
## Trefferpunkte braucht: halb so viele wie ein Wolf; sie folgen dem Wolf und fliehen, wenn er fällt (mars.gd follows);
## Erfahrung nach BRS über lohn.gd (Wolf, je Jungwolf werte.json „erfahrung_anteil“)
const JUNGWOLF := {"de": "Jungwolf", "en": "Young wolf", "scale": 0.55, "atk_shift": -1, "dmg": [1, 3, 0], "hp_share": 0.5, "chance": 0.5,
	"flee": ["Mit eingezogenem Schwanz fliehen die Jungwölfe ins Unterholz!", "Tails tucked, the young wolves flee into the undergrowth!"]}

## 533 (alt Packs.kt guard): Grimmzahns Leibwache, zwei Wölfe; Biss 1W4, Angriff eins unter Grimmzahn, beißt zu 55 % je Runde;
## fällt er, verschwinden sie heulend. Größe (alt 0,78) bleibt, bis der Chef Grimmzahn neu sieht (Chef 04.11., 00:33, 00:39).
const LEIBWACHE := {"atk_shift": -1, "dmg": [1, 4, 0], "chance": 0.55,
	"flee": ["Ihr Leitwolf ist gefallen – die Wölfe verschwinden heulend im Wald!", "Their alpha has fallen – the wolves vanish howling into the forest!"]}

static func rudel(monsters: Dictionary, dice) -> Array:
	var wolf: Dictionary = monsters[Mars.WOLF]
	var foes := [Mars.monster_fighter("wolf1", Vector2i(0, 0), wolf, dice.roll_expr(wolf.hp))]
	var jung: Dictionary = wolf.duplicate(true)
	jung.de = JUNGWOLF.de
	jung.en = JUNGWOLF.en
	jung.scale = JUNGWOLF.scale
	jung.atk = int(wolf.atk) + int(JUNGWOLF.atk_shift)
	jung.dmg = JUNGWOLF.dmg
	jung.xp = 0     # lohn.gd zählt sie als Begleiter des Wolfs (werte.json „erfahrung_anteil“), nicht einzeln
	jung.flee = JUNGWOLF.flee
	jung.chance = float(Brs.begleiter("Jungwolf", "wolf").get("chance", JUNGWOLF.chance))     # 399.2b (Chef 28.10., 15:32): 50 % je Runde (Packs.kt cubs); 870.3: werte.json
	jung.rudel = "Jungwolf"     # 870.3: Werte nach BRS aus werte.json „merkmale“ „rudel“ (brs_kampf.gd gegner)
	jung.anfuehrer = "wolf"
	var n: int = dice.roll_expr([1, 2, 0])
	for i in n:
		var f = Mars.monster_fighter("cub%d" % (i + 1), [Vector2i(0, 1), Vector2i(1, 0)][i], jung, maxi(1, int(dice.roll_expr(wolf.hp) * float(JUNGWOLF.hp_share))))
		f.follows = "wolf1"
		foes.append(f)
	return foes


## Ersatzwaffe der anderen Art (zum Nahkampf eine Fernwaffe und umgekehrt), wie Skirmish.secondWeapon ohne Gepäck: die erste
## schlichte als Gear-Wörterbuch (870.4: jeder darf jede führen); null, wenn keine passt
static func ersatzwaffe(h):
	var fern: bool = h.waffe() == null or not bool(h.grundform(h.waffe()["base"])["fern"])
	var schlicht := ["light_crossbow", "shortbow"] if fern else ["shortsword", "dagger", "mace", "quarterstaff"]
	for i in schlicht.size():
		var id: String = schlicht[i]
		if not BrsHeld.daten()["grundformen"].has(id):
			continue
		var d: Dictionary = h.grundform(id)
		if String(d["art"]) == "WEAPON" and bool(d["fern"]) == fern:
			return {"uid": -1 - i, "base": id, "rarity": "COMMON", "ilvl": 1, "plus": 0, "rolls": [], "unique": false}
	return null


## 870.4: der Held (BrsHeld) als MARS-Blatt: Name, Volk und Herkunft für die Figur, Stufe, Mana, Waffen in der Hand, Schild, dazu
## das Kampfblatt nach BRS („brs“, BrsHeld.kampfblatt, Schritt 2); [zweite]: die Ersatzwaffe (ersatzwaffe)
static func blatt(h, zweite = null) -> Dictionary:
	var schild = h.schild()
	return {"name": h.name, "race": HeldFigur.volk_modell(h.volk), "herkunft": h.herkunft, "level": h.stufe,
		"sp": h.mana, "sp_max": h.max_mana(), "skills": [], "main": _waffe(h, h.waffe()), "second": _waffe(h, zweite) if zweite != null else null,
		"off": _waffe(h, h.nebenwaffe()) if h.nebenwaffe() != null else null,
		"tenacity": mini(h.bonus("TENACITY"), 60), "schild": String(schild["base"]) if schild != null else "",   # 406: Modell in der Hand (figur.gd)
		"hits": {"POISON": h.bonus("POISON_HIT"), "BLEED": h.bonus("BLEED_HIT"), "STUN": h.bonus("STUN_HIT")},
		# 534 (alt Hero.lifeSteal, damageReduction): Lebensraub, Schadensminderung der Ausrüstung für mars.gd
		"lifesteal": mini(h.bonus("LIFESTEAL"), 30), "reduction": h.bonus("RESIST"),
		"brs_ruestung": h.ruestung(), "brs": h.mein_kampfblatt()}


static func _waffe(h, w) -> Dictionary:
	var d: Dictionary = h.grundform(w["base"]) if w != null else {}
	return {"id": String(w["base"]) if w != null else "", "de": String(d.get("de", "")), "en": String(d.get("en", "")),
		"ranged": bool(d.get("fern", false)), "reach": bool(d.get("reichweite", false)), "two": bool(d.get("zweihaendig", false)),
		"type": String(d.get("schadensart", "BLUDGEONING"))}


## Kampf beginnen: [gegner] wie probe.gd FOES („WOLVES“ …), [held] BrsHeld oder MARS-Blatt (dann [held_tp] dazu), [soeldner]
## ebenso oder null, [ort] Kampfort (heute nur „wald“), [tageszeit] „tag“, „abend“ oder „nacht“, [traenke] Heiltränke im Gepäck.
## false: kein Kampf (Held ohne LP); ende kommt dann gleich mit „NONE“
## [lage]: wie der Held aus der Welt kommt, {"atemlos": bool, "satt": bool, "eroeffnung": "NORMAL" | "AMBUSHED" | "HERO_FIRST",
## "blende": die schwarze Blende vor dem Kampf, 402; "rauch": Morwens Rauchbündel im Gepäck, gegen Krogg, 494; übrig danach
## kampf.mars.smoke; "stand": Heldenstufe nach BRS (Brs.neuer_stand), "gebiet": Gebiet für den Erfahrungstopf, 870.5} (399.2)
func starte(gegner_: String, held, soeldner = null, ort := "wald", tageszeit := "tag", traenke := 2, held_tp := -1, soeldner_tp := -1, seed := -1, beute := Callable(), lage := {}) -> bool:
	tabellen = JSON.parse_string(FileAccess.get_file_as_string("res://regeln/tabellen.json"))
	var dice = Wuerfel.new(null if seed < 0 else seed + 1)
	var skills := {}
	for s in tabellen.skills:
		skills[s.id] = s
	var monsters := {}
	for m in tabellen.monsters:
		monsters[m.id] = m
		if Brs.name(String(m.id)) != "":     # 870.3: Anzeigename aus werte.json „kennungen“ ([870.15.namen.monster]), nicht SRD
			m.de = Brs.name(String(m.id))
			m.en = Brs.name(String(m.id), 1)
	var party := [_kaempfer("hero", held, held_tp, Vector2i(Mars.FRONT, 0), skills)]
	party[0].hero["look"] = lage.get("aussehen", {})     # 403: Kopf, Haar, Haut wie im Dorf (Zustand.aussehen, HeldFigur)
	if not (held is Dictionary):
		# 870.4: der Held nach BRS, wie er ist (Stufe, was er trägt), Geübtes aus zustand.fert (471)
		party[0].hero["brs"] = held.kampfblatt(held.stufe, held.getragen(), lage.get("brs_fert", held.geuebt))
	elif not (lage.get("brs", {}) as Dictionary).is_empty():
		# 870.2 (LISTE-UMZUG-BRS.md Schritt 2): ein fertiges Blatt mit dem Helden nach BRS aus dem Spielstand (zustand.brs)
		var hb: Dictionary = party[0].hero
		party[0].hero["brs"] = BrsHeld.aus_daten(lage.brs).kampfblatt(int(hb.level),
			{"waffe": String(hb.main.id), "ruestung": String(hb.get("brs_ruestung", "keine")), "schild": String(hb.get("schild", ""))}, lage.get("brs_fert", {}))
	elif not (lage.get("brs_fert", {}) as Dictionary).is_empty():
		party[0].hero["brs_fert"] = lage.brs_fert     # 471: geuebte Werte ohne Spielstand nach BRS (brs_kampf.gd held „brs_fert“)
	leiden_auf(party[0], lage.get("leiden", {}))     # 532
	if bool(lage.get("betrunken", false)):     # 532 Metrausch wie alt (Battle.drunk): bis zur Rast, im Kampf ohne Ende
		party[0].status["DRUNK"] = Mars.LASTING
	if soeldner != null:
		var sb := _als_blatt(soeldner)
		var hinten: bool = sb.main.ranged or String(sb.get("cls", "")) == "WIZARD" or String(sb.get("cls", "")) == "CLERIC" \
			or (sb.get("brs") is Dictionary and String(sb.brs.get("waffe", {}).get("art", "nah")) == "fern")
		party.append(_kaempfer("merc", soeldner, soeldner_tp, Vector2i(Mars.BACK, 0) if hinten else Vector2i(Mars.FRONT, 1), skills))
	var foes := gegner(gegner_, monsters, dice)
	if int(lage.get("nr", 0)) > 0 and not foes.is_empty():
		foes[0].monster = (foes[0].monster as Dictionary).duplicate()     # nicht die Tabelle selbst ändern
		foes[0].monster["fell"] = int(lage.nr)     # 494: Fell des Monsters der Karte (spiel.gd kampf_im_wald nr), Name ohne Nummer
	kampf = Kampfort.new()
	kampf.tempo = Bedienung.tempo_faktor()     # 527: Tempo aus dem Menue System
	kampf.tempo_knopf = true     # 600: Knopf im Kampfort schaltet es weiter
	kampf.tageszeit = tageszeit
	kampf.ort = ort
	if lage.get("flaggen") is Dictionary: kampf.flaggen = lage.flaggen     # 836: dasselbe Dictionary wie Zustand.flaggen, nicht kopiert
	kampf.platz = String(lage.get("platz", "lichtung"))     # 493: Kampfort im Wald nach der Kachel (Kampfort.platz_fuer)
	# 870.5: Lohn nach BRS (lohn.gd): Heldenstufe aus lage „stand“ (Zustand.stufe_brs, Brs.neuer_stand), ohne ihn am Anfang der
	# Stufe des Helden; Erfahrungstopf nach lage „gebiet“ (werte.json „Wald“, „Tiefer Wald“, „Höhle“; "" ohne Topf)
	var stand: Dictionary = lage.get("stand", {})
	if not kampf.setup(party, foes, tabellen, {"potion": traenke}, _fertig, seed, {"stand": stand, "gebiet": String(lage.get("gebiet", "")), "beute": beute, "atemlos": bool(lage.get("atemlos", false)), "satt": bool(lage.get("satt", false)), "eroeffnung": String(lage.get("eroeffnung", "NORMAL")), "blende": bool(lage.get("blende", false)), "rauch": int(lage.get("rauch", 0))}):
		kampf.free()
		kampf = null
		_fertig.call_deferred("NONE")
		return false
	if gegner_ == "GRIMM":     # Grimmzahn ohne Nummer, die Wölfe 1 und 2 (die Regeln zählen nach Art)
		for i in foes.size():
			foes[i].nr = i
	get_tree().root.add_child.call_deferred(kampf)
	return true


func _als_blatt(x) -> Dictionary:
	return x if x is Dictionary else blatt(x, ersatzwaffe(x))


func _kaempfer(id: String, x, tp: int, platz: Vector2i, skills: Dictionary):
	var b := _als_blatt(x)
	var max_tp: int = tp if x is Dictionary else int(x.max_leben())
	var f = Mars.hero_fighter(id, "PARTY", platz, b, max_tp, b.second, skills)
	if not (x is Dictionary):
		f.hp = clampi(int(x.leben), 0, max_tp)     # 870.4: Leben nach BRS, im Kampf dieselbe Zahl
	return f


## 532 (alt Battle.kt init, GameState.ailments): die Zustände, die der Held aus dem letzten Kampf mitbringt; nur, was MARS kennt
## (Metrausch DRUNK fehlt in MARS, Zu 532)
static func leiden_auf(f, leiden: Dictionary) -> void:
	for st in leiden:
		if Mars.STATUS.has(String(st)) and int(leiden[st]) > 0:
			f.status[String(st)] = int(leiden[st])


## 532 (alt Game.keepAilments): was nach dem Kampf bleibt: Gift, Blutung, Schwäche; ein Fluch (Schwäche) bis zur Heilung, Gift
## und Blutung um den Konstitutionsbonus kürzer (Perks.ailmentShortening); verloren: nichts
static func leiden_nach(f, ergebnis: String, kon_bonus: int) -> Dictionary:
	var bleibt := {}
	if f == null or ergebnis == "LOST":
		return bleibt
	for st in f.status:
		if not String(st) in ["POISON", "BLEED", "WEAK"]:
			continue
		var rest: int = Mars.LASTING if st == "WEAK" else int(f.status[st]) - maxi(0, kon_bonus)
		if rest > 0:
			bleibt[String(st)] = rest
	return bleibt


func _fertig(ergebnis: String) -> void:
	var tp := {}
	var lohn := {}
	if kampf != null and kampf.mars != null:
		for f in kampf.mars.fighters():
			if f.side == "PARTY":
				tp[f.id] = f.hp
				if kampf.mars.brs and f.srd_hp > 0:     # 478: zurück in die Leben der Welt im selben Anteil (870.4: dieselbe Zahl)
					tp[f.id] = clampi(roundi(float(f.hp) * f.srd_hp / maxf(1.0, f.max_hp)), 1 if f.hp > 0 else 0, f.srd_hp)
				f.sp = Mars.sp_nach(f)     # 870.5: Mana zurück in die Welt (870.4: dieselbe Zahl)
		lohn = kampf.reward
	ende.emit(ergebnis, tp, lohn)
	queue_free()
