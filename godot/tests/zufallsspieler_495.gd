extends SceneTree
# 495 (Wochenziel 03.11. Reihe 4, Abnahme 2.2): ein Zufallsspieler spielt Kapitel 1 in Godot bis „chapter1_done“ und meldet, wo
# er haengenbleibt, bevor der Chef spielt. Ohne Bild. Er bedient das Spiel nur wie ein Mensch: tippt Leute an (spiel.ziel_person),
# geht zu Kacheln (held.geh_zu), stoesst gegen Gitter und Schlagbaum (spiel.ziel_stoss), drueckt den Knopf (spiel._aktion), tippt
# Texte weiter (ui.naechste), schliesst Laden, Rast, Kapitelschirm, ueberspringt Zwischenbilder, waehlt im Kampf zufaellig unter
# den erlaubten Befehlen (kampfort.order). Ziel je Stand der Geschichte wie Geschichte.ziel(); zwischendurch Umwege (Zufallsweg,
# zufaellige Person). Haengt er (kein neues Ziel in HAENGT Spielminuten), meldet er Stand, Ort, offene Fenster und die letzten
# Eingaben. Aufruf im Ordner godot: -s res://tests/zufallsspieler_495.gd [-- --saat=N --klasse=<Herkunft>]
# -> „ZUFALLSSPIELER fertig|haengt …“, Exit 0 nur bei „chapter1_done“

const G = preload("res://skripte/geschichte.gd")
const TEMPO := 8.0              # Engine.time_scale: Gehen, Uhr, Kampf laufen schneller, gleiche Regeln
const HAENGT := 8 * 60          # Spielminuten ohne neues Ziel der Geschichte
const HOECHSTENS := 2 * 24 * 60 # Spielminuten insgesamt

var spiel
var zufall := RandomNumberGenerator.new()
var log_: Array = []
var merker_zahl := 0
var seit_merker := 0.0          # Spielminuten
var minuten := 0.0
var kaempfe := {"WON": 0, "LOST": 0, "FLED": 0, "andere": 0}
var umweg_bis := 0.0
var letzte_kachel := Vector2i(-99, -99)
var steht_seit := 0.0
var karten: Dictionary
var ziel_text := ""

func notiere(s: String) -> void:
	log_.append("%d:%s" % [int(minuten), s])
	if log_.size() > 60: log_.pop_front()

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var saat := 495
	var klasse := ""
	var sekunden := 540             # echte Sekunden, dann Bericht (der Ablauf bricht sonst ohne Bericht ab)
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--saat="): saat = int(a.substr(7))
		if a.begins_with("--klasse="): klasse = a.substr(9)
		if a.begins_with("--sekunden="): sekunden = int(a.substr(11))
	zufall.seed = saat
	seed(saat)
	# 870.4: BRS ohne Klasse; die Saat waehlt die Herkunft (werte.json „herkuenfte“, dazu Wanderer)
	var hks: Array = BrsHeld.herkuenfte()
	if klasse == "": klasse = String(hks[saat % hks.size()])
	karten = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))["karten"]
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()   # Bericht auf Deutsch wie beim Chef
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	# neues Spiel wie aus der Erschaffung, ohne Intro (Schnellstart 1020.1 A; das ueberspringt ein Spieler auch)
	await spiel.starte({"platz": 4, "name": "Zufall", "schnell": true, "brs": BrsHeld.neu("Mensch", klasse).als_daten()})
	for i in 3: await process_frame
	Engine.time_scale = TEMPO
	print("ZUFALLSSPIELER Saat %d, %s" % [saat, klasse])
	var ende := ""
	var t_alt: int = spiel.zustand.minuten
	while ende == "":
		await process_frame
		var z: Zustand = spiel.zustand
		var dm: float = float(z.minuten - t_alt)
		if dm < 0: dm += 24 * 60
		t_alt = z.minuten
		minuten += dm
		seit_merker += dm
		if z.flaggen.size() > merker_zahl: notiere("merker:" + ",".join(PackedStringArray(z.flaggen.keys().slice(merker_zahl))))
		merker_zahl = z.flaggen.size()
		var zt := Sprache.t(G.ziel(z))
		if zt != ziel_text:   # Fortschritt heisst: das Ziel der Geschichte ist ein neues
			print("ZUFALLSSPIELER %d min: %s" % [int(minuten), zt])
			ziel_text = zt
			seit_merker = 0.0
		if z.has(G.CHAPTER1_DONE): ende = "fertig"
		elif seit_merker > HAENGT: ende = "haengt"
		elif minuten > HOECHSTENS: ende = "zu lang"
		elif Time.get_ticks_msec() > sekunden * 1000: ende = "abgebrochen (Zeit)"
		else: await schritt()
	Engine.time_scale = 1.0
	var z: Zustand = spiel.zustand
	var hw: BrsHeld = spiel.held_werte()
	print("ZUFALLSSPIELER %s nach %d Spielminuten (Tag %d): Ziel „%s“; Ort %s %s; Stufe %d, Leben %d/%d, Gold %d; Kaempfe %s" % [ende, int(minuten), z.tag,
		Sprache.t(G.ziel(z)), spiel.karte.id if spiel.karte else "-", spiel.held.kachel if spiel.held else "-", hw.stufe, hw.leben, hw.max_leben(), z.gold, kaempfe])
	print("ZUFALLSSPIELER offen: %s" % offen())
	# Lauf 259: in einer Zeile schnitt der Ablauf (cut -c1-900) die letzten 20 Eingaben ab; je zehn eine Zeile, die Nummer haelt die Folge
	for i in range(0, log_.size(), 10):
		print("ZUFALLSSPIELER Eingaben %02d: %s" % [i / 10 + 1, " ".join(PackedStringArray(log_.slice(i, i + 10)))])
	# Lauf 259 Saat 1: „offen: Kampf“ in der Schenke nach zwei Niederlagen; was vom Kampf noch steht
	if spiel.im_kampf:
		var kf = kampfort()
		print("ZUFALLSSPIELER Kampf: spiel.kampf %s, Kampfort %s, busy %s, Ausgang %s, Aufrufe %d" % [spiel.kampf != null and is_instance_valid(spiel.kampf),
			kf != null, kf.busy if kf else "-", kf.mars.outcome if kf and kf.mars else "-", spiel.find_children("*", "", false, false).filter(func(n): return n.has_signal("ende")).size()])
	quit(0 if ende == "fertig" else 1)

# was gerade offen ist (Text, Laden, Rast, Brett, Kampf, Pause)
func offen() -> String:
	var o: Array = []
	if spiel.ui.spricht(): o.append("Text „%s“" % String(spiel.ui.text.text).left(60))
	if spiel.laden: o.append("Laden")
	if spiel.rast_ort != "": o.append("Rast " + spiel.rast_ort)
	if spiel.brett_offen: o.append("Brett")
	if spiel.im_kampf: o.append("Kampf")
	if paused: o.append("Pause")
	if not spiel.szene.is_empty(): o.append("Szene %d Befehle" % spiel.szene.size())
	return ", ".join(PackedStringArray(o)) if not o.is_empty() else "nichts"

# ein Blick, eine Eingabe
func schritt() -> void:
	# Fenster und Bilder zuerst
	for n in spiel.find_children("*", "", true, false):
		if n is KapitelSchirm:
			notiere("kapitelschirm-weiter"); n.weiter.emit(); return
		if n is Zwischenbild:
			notiere("zwischenbild-weiter"); n.fertig.emit(); return
	var kf = kampfort()
	if kf: kaempfe_zug(kf); return
	if spiel.im_kampf: return   # Blende vor oder nach dem Kampf
	if spiel.ui.spricht():
		if zufall.randf() < 0.3: spiel.ui.naechste()   # liest ein wenig
		return
	if spiel.laden:
		notiere("laden-zu"); spiel.laden_schirm.zu.emit(); return
	if spiel.rast_ort != "":
		var w := "lang" if spiel.held_werte().leben * 2 < spiel.held_werte().max_leben() and zufall.randf() < 0.7 else ""
		notiere("rast:" + (w if w != "" else "weiter")); spiel._rast_wahl(w); return
	if spiel.brett_offen:
		notiere("brett-zu"); spiel._brett_wahl(""); return
	if spiel.held == null or spiel.held.geht() or is_instance_valid(spiel.ziel_person) or spiel.ziel_stoss.x >= 0: return
	if minuten < umweg_bis: return
	# angekommen: Umweg oder das naechste Ziel
	if zufall.randf() < 0.15:
		umweg()
		return
	ziel_zug()

# Lauf 254: der Kampfort haengt nicht unter dem Spiel, sondern an der Wurzel (aufruf.gd starte: root.add_child); unter spiel gesucht,
# fand der Spieler ihn nie und wartete im ersten Kampf ewig („offen: Kampf“, 0 Kaempfe gewertet)
func kampfort():
	var k = spiel.get("kampf")
	if k != null and is_instance_valid(k) and k.has_method("order") and k.get("mars") != null: return k
	for n in spiel.get_tree().root.find_children("*", "", true, false):
		if n.has_method("order") and n.get("mars") != null: return n
	return null

# im Kampf: eine zufaellige erlaubte Tat, wenn der Held waehlen muss; danach den Schirm schliessen
func kaempfe_zug(kf) -> void:
	var m = kf.mars
	if kf.busy: return
	if m.outcome != "ONGOING":
		kaempfe[m.outcome if kaempfe.has(m.outcome) else "andere"] += 1
		notiere("kampf-ende:" + String(m.outcome))
		kf.finish()
		return
	var f = m.current()
	if f == null or f.side != "PARTY" or not f.standing() or m.pilot_next(): return
	var wahl: Array = []
	for t in m.targets(f):
		for i in 3: wahl.append(["attack", t.id])
	for s in m.moves(f):
		if m.blocked(f, s) == null:
			for t in m.aim_at(f, s): wahl.append(["use", s, t.id])
	if f.hp * 3 < f.max_hp:
		for k in m.drinkable():
			for i in 3: wahl.append(["drink", k, f.id])
	if not m.guardable(f).is_empty(): wahl.append(["guard"])
	wahl.append(["wait"])
	var o: Array = wahl[zufall.randi_range(0, wahl.size() - 1)]
	notiere("kampf:" + str(o))
	kf.order(o)

# ein Umweg: eine zufaellige Kachel in der Naehe oder eine zufaellige Person
func umweg() -> void:
	var leute: Array = spiel.leute_liste().filter(func(l): return not l.daten.has("tier"))
	if not leute.is_empty() and zufall.randf() < 0.4:
		var l = leute[zufall.randi_range(0, leute.size() - 1)]
		tippe_person(l)
		return
	var k: Karte = spiel.karte
	for i in 20:
		var t: Vector2i = spiel.held.kachel + Vector2i(zufall.randi_range(-8, 8), zufall.randi_range(-8, 8))
		if k.begehbar(t) and k.ausgang(t).is_empty() and spiel.held.geh_zu(k.kachel_pos(t)):
			notiere("umweg:%d/%d" % [t.x, t.y])
			return

func tippe_person(l) -> void:
	notiere("tippe:" + String(l.daten.get("id", "?")))
	if l == spiel.person_nah():
		spiel.sprich(l)
		return
	spiel.ziel_person = l
	var n: Vector2i = spiel.naechster_nachbar(l.kachel)
	if not spiel.held.geh_zu(spiel.karte.kachel_pos(n) if n.x >= 0 else l.position): umweg_bis = minuten + 2

# was der Stand der Geschichte verlangt (wie Geschichte.ziel): [Karte, Art, was]
func plan() -> Array:
	var z: Zustand = spiel.zustand
	if not z.has(G.QUEST_STARTED): return ["elder", "person", "aldric"]
	if not z.has(G.BARRIER_OPEN): return ["village", "person", "jorin"]
	if not z.has("cave_seen"): return ["cave", "da", null]
	if not z.has(G.KROGG_DEFEATED): return ["cave", "person", "krogg"]
	if not z.has(G.GATE_OPEN): return ["cave", "stoss", "L"]
	if not z.has(G.GRAK_DEFEATED): return ["cave", "kachel", Vector2i(10, 4)]
	if not z.has(G.LYRA_RESCUED): return ["cave", "person", "lyra_cave"]
	return ["elder", "person", "aldric"]

func ziel_zug() -> void:
	var p := plan()
	var k: Karte = spiel.karte
	if k.id != String(p[0]):
		gehe_richtung(String(p[0]))
		return
	match String(p[1]):
		"da": return
		"person":
			for l in spiel.leute_liste():
				if String(l.daten.get("id", "")) == String(p[2]):
					tippe_person(l)
					return
			notiere("fehlt:" + String(p[2]))
			umweg_bis = minuten + 10
		"stoss":
			var t := finde_zeichen(k, String(p[2]))
			if t.x < 0: notiere("kein " + String(p[2])); umweg_bis = minuten + 10; return
			var n: Vector2i = spiel.naechster_nachbar(t)
			if n.x < 0: notiere("kein Platz vor " + String(p[2])); umweg_bis = minuten + 10; return
			notiere("stoss:%d/%d" % [t.x, t.y])
			spiel.ziel_stoss = t
			if not spiel.held.geh_zu(k.kachel_pos(n)): spiel.ziel_stoss = Vector2i(-1, -1); umweg_bis = minuten + 2
		"kachel":
			var t: Vector2i = p[2]
			if spiel.held.kachel == t: umweg(); return
			notiere("geh:%d/%d" % [t.x, t.y])
			if not spiel.held.geh_zu(k.kachel_pos(t)): notiere("kein Weg"); umweg_bis = minuten + 2

func finde_zeichen(k: Karte, c: String) -> Vector2i:
	for y in k.hoehe:
		for x in k.breite:
			if k.zeichen(Vector2i(x, y)) == c: return Vector2i(x, y)
	return Vector2i(-1, -1)

# zur Karte ziel: naechster Ausgang auf dem kuerzesten Weg ueber die Ausgaenge (karten.json); Tuer: davor und Knopf, sonst darauf
func gehe_richtung(ziel: String) -> void:
	var k: Karte = spiel.karte
	var vor := {k.id: ""}
	var schlange := [k.id]
	while not schlange.is_empty() and not vor.has(ziel):
		var m: String = schlange.pop_front()
		for a in karten.get(m, {}).get("ausgaenge", []):
			var n := String(a["ziel"]["karte"])
			if bool(a.get("verschlossen", false)) or vor.has(n) or not karten.has(n): continue
			vor[n] = m
			schlange.append(n)
	if not vor.has(ziel): notiere("kein Weg nach " + ziel); umweg_bis = minuten + 10; return
	var hin := ziel
	while vor[hin] != k.id: hin = vor[hin]
	var h: Vector2i = spiel.held.kachel
	var bester := Vector2i(-1, -1)
	var best_n := 1 << 30
	for t in k.ausgaenge:
		var a: Dictionary = k.ausgang(t)
		if String(a["ziel"]["karte"]) != hin or bool(a.get("verschlossen", false)): continue
		var d: int = absi(t.x - h.x) + absi(t.y - h.y)
		if d < best_n: best_n = d; bester = t
	if bester.x < 0: notiere("kein Ausgang nach " + hin); umweg_bis = minuten + 10; return
	if k.tuer(bester):
		if (bester - h).length_squared() == 1:
			spiel.held.rotation.y = atan2(float(bester.x - h.x), float(bester.y - h.y))
			notiere("tuer:" + hin); spiel._aktion(); umweg_bis = minuten + 1
			return
		var n: Vector2i = spiel.naechster_nachbar(bester)
		notiere("zur-tuer:" + hin)
		if n.x < 0 or not spiel.held.geh_zu(k.kachel_pos(n)): notiere("kein Weg zur Tuer"); umweg_bis = minuten + 2
		return
	if h == bester:
		notiere("ausgang:" + hin); spiel._aktion(); umweg_bis = minuten + 1
		return
	notiere("zum-ausgang:" + hin)
	if not spiel.held.geh_zu(k.kachel_pos(bester)):
		# gesperrt (Schlagbaum, Gitter): dagegen stossen wie ein Spieler
		notiere("versperrt:%d/%d" % [bester.x, bester.y]); umweg_bis = minuten + 5
