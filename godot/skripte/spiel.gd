extends Node3D
# 348.6: Chroniken von Bornim in Godot, Fundament: Gebietskarte aus core (karten.json) und Blender, Held, Steuerung,
# Kamera, Licht, Tusche; Ausgaenge wie im alten Spiel: Tuer mit dem Aktionsknopf (215), gesperrte Wege mit ihrem Text.
# Grundrisse folgen nach der Bestandsliste (348.8); bis dahin zeigt eine Tuer den Namen des Grundrisses und fuehrt zurueck.
# Am Rechner: godot --path godot -- --bilder=<ordner> legt Standbilder ab (Vergleich alt/neu) und beendet sich.

const START := "village"
const START_KACHEL := Vector2i(19, 13)          # Dorfplatz am Brunnen (Probe Build 11)

var karte: Karte
var gebiet: Gebiet
var held: Held
var leute: Node3D                                # 348.6 Leute der Karte (leute.gd)
var kamera: Kamera
var licht: Licht
var ui: Steuerung
var blende: ColorRect
var gedacht := {}                                # Rand (67): erster Gedanke lang, danach kurz
var zeiten: Array = []
var ziel_stoss := Vector2i(-1, -1)               # angetippter gesperrter Ausgang: beim Ankommen Text zeigen
var zustand := Zustand.new()                     # 390: Flaggen, Taschen, Gold (GameState)
var szene: Array = []                            # 390: Befehle, die noch laufen (Game.queue)
var ziel_person: Leute                           # 390: angetippte Person: beim Ankommen ansprechen
var angebot_uhr := 0.0                           # 390: Knopf neu, wenn Leute herankommen oder gehen
var werte: Heldwerte                             # 390 (Rast): TP und ZP des Helden (Hero), bis die Erschaffung ihn uebergibt
var rast_ort := ""                               # 390 (Mode.Rest): Feld offen an "feuer", "schenke" oder "zimmer"
var rast_notiz := ""
var rast_zweites := false
var laden: Laden                                 # 390 (Mode.Shop): offen, bis „Schließen“
var laden_notiz := ""
var laden_menge := {}                            # 390 (59.5): ein Ding mit Menge {id, kaufen, n}; leer = Liste
var laufen_will := false                        # 399.1 Ring oder Renntaste (Stamina.step run)
var brett_offen := false
var rufe := {}                                   # 399.1 Ruf: Person -> seit wann (ms) sie ruft, -1 = bemerkt, nichts Neues
var rufe_karte := ""
var naechster_ruf := 0                           # 134.3 Game.nextCallAt: vorher ruft kein anderer
var spricht_mit := ""                            # bis das Gespraech vorbei ist, dann gilt gehoert (Game.talkingTo)                        # 399.1 Anschlagbrett (Mode.Board)
var laden_stueck := ""                           # 399.1 (gearDialog): das Stueck Ausruestung im Kasten vor Kauf oder Verkauf
var laden_frage := ""                            # 399.1 (59e, Rückfragen): die Wahl, die noch einmal fragt; "" = keine

func _ready() -> void:
	licht = Licht.new()
	add_child(licht)
	kamera = Kamera.new()
	add_child(kamera)
	ui = Steuerung.new()
	add_child(ui)
	blende = ColorRect.new()
	blende.color = Color(0, 0, 0, 0)
	blende.set_anchors_preset(Control.PRESET_FULL_RECT)
	blende.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(blende)
	ui.tippen.connect(_tippen)
	ui.joystick.connect(func(v): if held: held.richtung = kamera.richtung(v))
	ui.kneifen.connect(func(f, w): kamera.kneifen(f); kamera.drehe(w))
	ui.laufen.connect(func(an): laufen_will = an)   # 399.1 ob er rennt, entscheidet der Atem (Ausdauer.schritt)
	ui.aktion.connect(_aktion)
	ui.knopf.connect(_knopf)
	ui.windrose.zurueck.connect(kamera.nach_norden)
	ui.leiste.menue.connect(oeffne_menue)
	ui.gelesen.connect(weiter)
	ui.gewaehlt.connect(_rast_wahl)
	ui.gewaehlt.connect(_laden_wahl)
	ui.gewaehlt.connect(_brett_wahl)
	licht.nacht_geaendert.connect(_nacht)
	Leute.uhr = func(): return zustand.minuten   # 390 Tagesablauf
	add_child(Rand.band(Rand.oben(get_viewport())))   # 399.4: schwarz, was die Kamera des Handys verdeckt
	# 399: Hauptmenue und Erschaffung zuerst, ausser bei Probelaeufen am Rechner (--bilder, --figuren …, Tests ohne Fenster)
	if OS.get_cmdline_user_args().is_empty() and DisplayServer.get_name() != "headless":
		var ebene := CanvasLayer.new()   # 399.1 (Test 130: Probeknoepfe und Windrose lagen ueber dem Menue): eigene Ebene ueber allem
		ebene.layer = 50
		add_child(ebene)
		var menue := Hauptmenue.new(ui)
		ebene.add_child(menue)
		# 399.3 (Jerry): die Titelmusik startet das Hauptmenue, beim Kaltstart erst nach dem Vorspann (292)
		var w: Dictionary = await menue.fertig
		ebene.queue_free()
		add_child(Helligkeit.schicht())   # 399.1: Helligkeit ueber dem ganzen Spiel, nicht im Hauptmenue (App.kt liftBlack)
		starte(w)
		return
	betrete(START, START_KACHEL, "DOWN")
	bilder()
	gang_film()
	leute_blatt()
	held_film()
	tusche_blatt()
	probe_blatt()
	haeuser_blatt()
	dorftiere_blatt()
	tusche_nacht()
	rast_probe()

# 399: Spielbeginn aus dem Hauptmenue: geladen an den gespeicherten Ort, sonst ein neues Spiel mit frischem Zustand (Test 139: das neue
# Spiel begann dort, wo das vorige stand; seit 3b17961e9 nach der Ankunft im Bett der Schenke). Eigene Funktion fuer tests/neues_spiel_399.gd
func starte(w: Dictionary) -> void:
	Spielstand.platz = maxi(1, int(w.get("platz", 1)))   # 399.1: vier Plaetze wie alt; gespeichert wird in diesen
	var stand := Spielstand.lade(Spielstand.platz) if w.get("laden", false) else {}
	if not stand.is_empty():
		zustand = Zustand.aus_daten(stand["zustand"])
		werte = Heldwerte.aus_daten(stand["held"])
		var o: Dictionary = stand["ort"]
		blende.color.a = 1.0
		klang("verhuelle", [true])
		betrete(String(o["karte"]), Vector2i(int(o["x"]), int(o["y"])), String(o["blick"]))
		ortsworte("", false)   # 24.1 Spielbeginn: Name und Satz
		return
	zustand = Zustand.new()   # nichts vom vorigen Spiel: Flaggen, Gold, Taschen, Ort
	zustand.name = String(w.get("name", zustand.name))
	werte = Heldwerte.erschaffe(zustand.name, String(w.get("volk", "HUMAN")), String(w.get("klasse", "FIGHTER")), w.get("werte", {}), zustand.neue_uid)   # 399.1 Punktekauf
	# 399.1 wie alt (69, GameViewModel.newGame): einmal die Ankunft bei Nacht, dann erwacht der Held neben dem Bett der Schenke
	# (Story.START), wo Rowena ihn weckt; vorher begann das neue Spiel am Brunnen
	await zwischenbild("intro")
	blende.color.a = 1.0
	klang("verhuelle", [true])
	betrete(String(Rast.START["karte"]), Vector2i(int(Rast.START["x"]), int(Rast.START["y"])), String(Rast.START["blick"]))
	ortsworte("", true)   # 24.1 Spielbeginn: Name und Satz

func betrete(id: String, t: Vector2i, blick: String) -> void:
	var t0 := Time.get_ticks_usec()   # 399.1 Gerät: Ladezeit je Ort
	if gebiet: gebiet.queue_free()
	if held: held.queue_free()
	if leute: leute.queue_free()
	karte = Karte.lade(id, zustand.flaggen)   # 390: Schlagbaum, Tor, Ausgaenge und Wege lesen den Spielstand
	zustand.setze("besucht:" + id)   # 399.1 Chronik „Die Blutzahnhöhle“ (alt GameState.explored)
	licht.innen = String(karte.daten.get("art", "")) == "INTERIOR"   # 399.1 Grundriss
	licht.stelle(licht.nacht)
	gebiet = Gebiet.new(karte)
	add_child(gebiet)
	held = Held.new(karte)
	add_child(held)
	held.setze(t, blick)
	fackel_neu()   # 399.1 Light.burns
	held.steht_auf.connect(_betritt)
	held.stoesst.connect(_stoesst)
	leute = Node3D.new()
	leute.name = "Leute"
	add_child(leute)
	for l in Leute.alle(karte, held): leute.add_child(l)
	for l in Leute.dorftiere(karte, held): leute.add_child(l)   # 348.6 Dorftiere (Chefrunde 28.10., 08:09)
	held.leute = leute.get_children()
	sichtbar_neu()
	kamera.ziel = held
	gebiet.held = held
	gebiet.kamera = kamera
	kamera.springe()
	ui.ort.text = karte.name()
	klang("ort", [karte, held])   # 399.3 (Jerry): Ortsmusik, Schritte nach dem Boden
	_nacht(licht.nacht)
	_steht_auf(t)
	spiele(Geschichte.betreten(id, zustand))   # 390: MapDef.onEnter
	speichere()   # 399: wie alt beim Kartenwechsel
	Messung.geladen(id, (Time.get_ticks_usec() - t0) / 1000.0)

func speichere() -> void:
	if held and karte and not OS.get_cmdline_user_args().size(): Spielstand.speichere(zustand, held_werte(), platz())

func _notification(what: int) -> void:   # 399: auch beim Verlassen der App (alt: onPause)
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST: speichere()

func _nacht(k: float) -> void:
	kamera.nacht = k   # 348.13b: Tusche nach Laterne, Fenster, Fackel
	if gebiet: gebiet.nacht(k)
	if held: held.nacht(k)
	if leute:
		for l in leute.get_children(): l.nacht(k)

func _knopf(was: String) -> void:
	match was:
		"nacht":
			licht.umschalten()
			zustand.minuten = 23 * 60 if licht.ziel > 0.5 else 12 * 60   # 390: die Leute folgen der Uhr (Tag mittags, Nacht 23 Uhr)
		"nah": kamera.nah_fern()
		"links": kamera.drehe(-45.0)
		"rechts": kamera.drehe(45.0)
		"tiere": tiere_an_aus()
		"sprache": sprache_wechseln()

# 390: Sprache umschalten; Ortsname und Schild am Knopf gleich neu, Gesagtes ab der naechsten Zeile
func sprache_wechseln() -> void:
	Sprache.wechsle()
	ui.sprache_neu()
	ui.ort.text = karte.name()
	_steht_auf(held.kachel)

# 348.6: Tiere zum Anschauen (Chef 16:52), nur im Test-APK; gehen wie die Leute, der Held geht nicht durch sie
func tiere_an_aus() -> void:
	var da := leute.get_children().filter(func(l): return String(l.daten.get("datei", "")).begins_with("res://daten/tiere/"))
	if da.is_empty():
		for t in Leute.tiere(karte, held):
			leute.add_child(t)
			t.nacht(licht.nacht)
	else:
		for t in da: t.queue_free()
	held.leute = leute.get_children().filter(func(l): return not l.is_queued_for_deletion())

# ---------------------------------------------------------------- Tippen, Ausgaenge, Schilder
const NACHBARN := [Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0)]

func _tippen(sp: Vector2) -> void:
	if held == null: return
	ziel_stoss = Vector2i(-1, -1)
	ziel_person = null
	# 390 (Ui.touchHint: "Tippe auf Personen …, um sie direkt anzusprechen"): hin, neben sie, und ansprechen
	var wer := person_bei(sp)
	if wer:
		if wer == person_nah(): sprich(wer)
		else:
			ziel_person = wer
			var n := naechster_nachbar(wer.kachel)
			held.geh_zu(karte.kachel_pos(n) if n.x >= 0 else wer.position)
		return
	var p = kamera.boden(sp)
	if p == null: return
	var b := karte.pos_kachel(p)
	if karte.begehbar(b):
		if not held.geh_zu(p): Bedienung.ruettle()   # 399.1 Ruetteln: kein Weg dorthin (WorldScreen route == null)
		return
	# Tuer, gesperrter Ausgang, Schild, Schlagbaum: davor stellen, dann Knopf oder Text
	if not (karte.tuer(b) or not karte.sperrt(b).is_empty() or zeichen_lesbar(b) or brett(b) or karte.zeichen(b) == "z"):
		Bedienung.ruettle()
		return
	var ziel := naechster_nachbar(b)
	if ziel.x < 0: Bedienung.ruettle(); return
	ziel_stoss = b
	held.geh_zu(karte.kachel_pos(ziel))

func naechster_nachbar(b: Vector2i) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_n := 1 << 30
	for d in NACHBARN:
		var n: Vector2i = b + d
		if not karte.begehbar(n): continue
		var w := karte.weg(held.kachel, n)
		if w.is_empty() and n != held.kachel: continue
		if w.size() < best_n: best_n = w.size(); best = n
	return best

func zeichen_lesbar(t: Vector2i) -> bool:
	return karte.zeichen(t) == "S" and schild(t) != ""

func brett(t: Vector2i) -> bool: return karte.zeichen(t) == "!"   # 399.1 Tile.NOTICE (Navigation: READ)

func schild(t: Vector2i) -> String:
	for s in karte.daten["schilder"]:
		if int(s["x"]) == t.x and int(s["y"]) == t.y: return Sprache.t(s["text"])
	return ""

func _steht_auf(t: Vector2i) -> void:
	ui.biete_an.callv(angebot(t))

# 390: der Held tritt auf eine Kachel (Trigger der Karte)
func _betritt(t: Vector2i) -> void:
	zustand.schritte += 1   # 399.1: GameState.steps, je betretene Kachel (System „Schritte“)
	_steht_auf(t)
	if not ui.spricht(): spiele(Geschichte.ausloeser(karte.id, t, zustand))

# was der Held von t aus mit dem Knopf tun kann: Ausgang unter ihm, Tuer daneben (zuerst die vor ihm), Schild daneben
func vor_ihm(t: Vector2i) -> Vector2i:
	if not karte.ausgang(t).is_empty(): return t
	var vorn := Vector2i(roundi(sin(held.rotation.y)), roundi(cos(held.rotation.y)))
	for d in [vorn] + NACHBARN:
		if karte.tuer(t + d) or zeichen_lesbar(t + d) or brett(t + d) or rast_kachel(t + d) != "": return t + d
	return Vector2i(-1, -1)

# wie Navigation.actionAt: Ausgang und Tuer (auch verschlossen) ENTER, Schild READ; dazu actionPlace: wohin, wenn offen
func angebot(t: Vector2i) -> Array:
	# 390 (actionTarget): Ausgang unter dem Helden zuerst; dann Person im Faecher vor Ding, Ding vor Person ausserhalb
	var pv := person_vorn() if karte.ausgang(t).is_empty() else [null, false]
	if pv[0] and pv[1]: return ["TALK", ""]
	var z := vor_ihm(t)
	if z.x < 0: return ["TALK", ""] if pv[0] else ["", ""]
	if zeichen_lesbar(z) or brett(z): return ["READ", ""]
	var rk := rast_kachel(z)
	if rk != "": return ["REST" if rk in ["feuer", "zimmer"] else "LOOK", ""]
	var a := karte.ausgang(z)
	if bool(a["verschlossen"]): return ["ENTER", ""] if a.has("klopfen") else ["", ""]
	return ["ENTER", Sprache.t(Karte.namen.get(String(a["ziel"]["karte"]), ""))]

func _aktion() -> void:
	var pv := person_vorn() if karte.ausgang(held.kachel).is_empty() else [null, false]
	var z := vor_ihm(held.kachel)
	if pv[0] and (pv[1] or z.x < 0):
		sprich(pv[0])
		return
	if z.x < 0: return
	if z != held.kachel: held.rotation.y = atan2(float(z.x - held.kachel.x), float(z.y - held.kachel.y))
	if zeichen_lesbar(z):
		ui.sage([{"text": schild(z)}])
		return
	if brett(z):
		oeffne_brett()
		return
	match rast_kachel(z):
		"feuer", "zimmer": oeffne_rast(rast_kachel(z)); return
		"hoehle": ui.sage([{"text": Sprache.t(Rast.FEUER_HOEHLE)}]); return
		"bett": ui.sage([{"text": Sprache.t(Rast.FREMDES_BETT)}]); return
	var a := karte.ausgang(z)
	if bool(a["verschlossen"]):
		var nachts := licht.nacht > 0.5
		if a.has("klopfen"):
			ui.sage(zeilen(a["klopfen"]["nacht" if nachts else "tag"]))
			zustand.setze("heard_%d_%d" % [z.x, z.y])   # 399.1 Karte: wer hier wohnt (MapPeople.heard)
		return
	if a.has("braucht") and not karte.flaggen.has(a["braucht"]):
		ui.sage(zeilen(a.get("abgewiesen", [])))
		return
	geh_hinaus(a)

func _stoesst(t: Vector2i) -> void:
	if await _schiebt(t): return
	if karte.zeichen(t) == "z" and not karte.flaggen.has("barrier_open"):
		ui.sage([{"text": Sprache.t(karte.schlagbaum)}])
		return
	if karte.zeichen(t) == "L" and not karte.flaggen.has("gate_open"):   # 390: Game.gate
		spiele(Geschichte.gitter(zustand))
		return
	var a := karte.sperrt(t)
	if a.is_empty(): return
	if bool(a["umkehren"]):
		var k := "gedanke_kurz" if gedacht.has(karte.id) else "gedanke"
		gedacht[karte.id] = true
		if a.has(k): ui.sage([{"text": Sprache.t(a[k])}])
	else:
		ui.sage(zeilen(a.get("abgewiesen", [])))

# 348.6 Ausweichen wie alt (Game.nudge, makeWay; 92): wer vor dem Helden steht und weicht (Leute.weicht), tritt zur Seite. Mit dem
# Steuerkreuz erst, wenn der Held weiter drueckt (alt zwei Stoesse, PUSH_BUMPS 2); auf einem getippten Weg gleich
func _schiebt(t: Vector2i) -> bool:
	var wer: Leute = null
	for l in leute.get_children():
		if l is Leute and l.weicht() and (l.kachel == t or l.ziel == t): wer = l
	if wer == null: return false
	var d := t - held.kachel
	d = Vector2i(signi(d.x), 0) if absi(d.x) >= absi(d.y) else Vector2i(0, signi(d.y))
	if d == Vector2i.ZERO: return true
	if held.richtung.length() > 0.15:
		# Test 133.7: weiter gedrueckt heisst weiter gegen ihn; abbrechen nur, wenn losgelassen, abgewandt oder weitergegangen
		# (vorher held.geht(), das ist beim Druecken immer wahr, so wich nie jemand)
		var von := held.kachel
		await (Engine.get_main_loop() as SceneTree).create_timer(0.5).timeout
		if not is_instance_valid(wer) or held.kachel != von or held.richtung.length() <= 0.15: return true
		var r := held.richtung
		if (Vector2i(int(signf(r.x)), 0) if absf(r.x) >= absf(r.z) else Vector2i(0, int(signf(r.z)))) != d: return true
	wer.weiche(d)
	return true

func zeilen(liste: Array) -> Array:
	var r: Array = []
	for z in liste:
		var e := {"text": Sprache.t(z["text"])}
		if z.has("wer"): e["wer"] = Sprache.t(z["wer"])
		r.append(e)
	return r

# Ziel gebaut: hinein; sonst Name des Grundrisses zeigen und vor der Tuer wieder herauskommen
func geh_hinaus(a: Dictionary) -> void:
	var z: Dictionary = a["ziel"]
	var id := String(z["karte"])
	ui.biete_an("")
	klang("effekt", ["door"])   # 399.3 (Jerry): Game.kt DOOR
	await abblenden(1.0)
	if FileAccess.file_exists("res://daten/" + Gebiet.datei(id) + ".bin") and id != karte.id:
		var von := karte.id
		var erster := not zustand.has("besucht:" + id)
		betrete(id, Vector2i(int(z["x"]), int(z["y"])), String(z["blick"]))
		await ortsworte(von, erster)
		return
	var alle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))
	var name := Sprache.t(alle["karten"][id]["name"]) if alle["karten"].has(id) else id
	var zurueck := vor_tuer(alle, id, a)
	# 399.1: Wald noch nicht gebaut, dort wartet der Kampf. Test 130 (Chef 14:31, „Grundriss folgt“ statt Kampf): FileAccess.file_exists
	# auf ein .gd ist im APK falsch (Skripte liegen dort uebersetzt), ResourceLoader.exists findet sie
	if id in WALD and ResourceLoader.exists("res://kampf/kampfort.gd"):
		await kampf_im_wald(zurueck)
		return
	held.setze(zurueck, "DOWN")
	kamera.springe()
	await abblenden(0.0)
	ui.sage([{"text": "%s: Grundriss folgt im Umzug (348)." % name}])

# das Feld vor dem Ausgang a dieser Karte nach id (wie der Rueckweg aus id)
func vor_tuer(alle: Dictionary, id: String, a: Dictionary) -> Vector2i:
	var zurueck := Vector2i(int(a["x"]), int(a["y"]) + 1)
	for r in alle["karten"].get(id, {}).get("ausgaenge", []):
		if String(r["ziel"]["karte"]) == karte.id: zurueck = Vector2i(int(r["ziel"]["x"]), int(r["ziel"]["y"]))
	return zurueck

# ---------------------------------------------------------------- Kampf (399.1, Chef 28.10., 12:34: im Dorf herumlaufen, in einen Kampf kommen)
# Der Weg in den Wald fuehrt in den Kampfort von Jerry (kampf/kampfort.gd, MARS) gegen ein Wolfsrudel, bis Wald und tiefer Wald als
# Gebietskarten stehen; danach zurueck vor den Ausgang, die Trefferpunkte bleiben. Verloren: wie Game.kt (154) vier Stunden vergehen,
# der Held erwacht ganz geheilt im Wiederkehrort (steht dieser Grundriss noch nicht, vor dessen Tuer im Dorf). Das Kampfblatt
# kommt aus den Heldwerten (kampf/aufruf.gd, 399.2 Jerry).
const WALD := ["forest", "deep_forest"]
const AufrufS = preload("res://kampf/aufruf.gd")
var kampf: Node
var leiste_uhr := 0.0

# 399.3 (Jerry): Musik und Klang ueber den Autoload Klang; ueber den Knoten statt den Namen, denn mit -s (skripte_pruefen,
# Lauf 135) gibt es den Autoload noch nicht und spiel.gd liesse sich nicht laden
func klang(was: String, mit := []) -> void:
	var k := get_node_or_null("/root/Klang")
	if k: k.callv(was, mit)

func tageszeit() -> String:   # Kampfort.tageszeit: tag, abend, nacht
	var m := zustand.minuten
	return "nacht" if m < 6 * 60 or m >= 21 * 60 else ("abend" if m >= 18 * 60 else "tag")

# gegner wie kampf/probe.gd FOES; [probe] (Test „MARS-Probekampf“, Skirmish.probe): Held und Soeldner [klasse, stufe] statt des eigenen
# Helden, danach bleibt er, wie er war (kein Lohn, keine TP, kein Tod)
func kampf_im_wald(zurueck: Vector2i, gegner := "RUDEL", probe: Array = []) -> void:
	var hw := held_werte() if probe.is_empty() else Testmodus.probeheld(String(probe[0]), int(probe[1]))
	var soeldner = null if probe.is_empty() else Testmodus.probeheld(String(probe[0]), int(probe[1]))
	var erg := {"ende": "", "tp": {}, "lohn": {}, "rest": zustand.anzahl("potion")}
	var aufruf := AufrufS.new()
	add_child(aufruf)
	aufruf.ende.connect(func(o, tp, lohn):
		erg["tp"] = tp; erg["lohn"] = lohn
		if aufruf.kampf and aufruf.kampf.mars: erg["rest"] = int(aufruf.kampf.mars.potions.get("potion", 0))
		erg["ende"] = String(o))
	held.halt(); held.richtung = Vector3.ZERO
	# die Welt ruht unsichtbar; Kamera und Umgebung des Kampforts gelten (sonst zeichnet unsere Kamera, unsere Umgebung zuerst)
	var umgebung: Array = find_children("*", "WorldEnvironment", true, false)
	var env_alt := umgebung.map(func(we): return we.environment)
	# 399.2a (Chef 14:19 „a“): Wolf mit 1–2 Jungwölfen wie im alten Spiel
	klang("spiele_szene", ["BATTLE"])   # 399.3 (Jerry): Kampfmusik wie alt (300 ms)
	klang("effekt", ["encounter"])   # 399.3 (Jerry): Game.kt Kampfbeginn
	# 399.2 (Jerry 3b9fb3116): Ausruestung als Beute nach einem Sieg wie Battle.finishWin (Loot.drops, einmal je Kampf, Gebietsstufe)
	var beute := func() -> Array:
		var w := KotlinZufall.new(randi())
		var ilvl := int(Karte.lade("forest").daten.get("stufe", 1))
		var st: Dictionary = Heldwerte.lade()["seltenheiten"]
		return Beute.beute(hw, w, ilvl, false, false, zustand.neue_uid).map(func(g): return {"gear": g, "name": Beute.name(g), "rarity": Sprache.t(st[String(g["rarity"])]["name"])})
	var k0 := Time.get_ticks_msec()
	var lage := {"atemlos": zustand.atemlos, "satt": zustand.satt} if probe.is_empty() else {}   # 399.2 (Jerry): wie der Held kommt
	var gestartet: bool = aufruf.starte(gegner, hw, soeldner, "wald", tageszeit(), zustand.anzahl("potion") if probe.is_empty() else 2, -1, -1, -1, beute, lage)
	if probe.is_empty(): zustand.satt = false   # 399.1: Battle.wellFed endet mit dem Kampfbeginn (der Kampfort gibt +1, 399.2)
	if gestartet:
		for we in umgebung: we.environment = null
		visible = false; ui.visible = false
		while aufruf.kampf != null and not aufruf.kampf.is_inside_tree() and erg["ende"] == "": await get_tree().process_frame
		kampf = aufruf.kampf
		Messung.kampf_ms = Time.get_ticks_msec() - k0
		if kampf and kampf.cam: kampf.cam.make_current()
	while erg["ende"] == "": await get_tree().process_frame
	kampf = null
	for k in umgebung.size(): umgebung[k].environment = env_alt[k]
	kamera.make_current()
	visible = true; ui.visible = true
	if probe.is_empty() and int(erg["rest"]) < zustand.anzahl("potion"): zustand.weg("potion", zustand.anzahl("potion") - int(erg["rest"]))   # getrunken
	var lohn: Dictionary = erg["lohn"]
	var ende := [String(erg["ende"])]
	klang("nach_kampf", [ende[0] == "WON", karte])   # 399.3 (Jerry): Sieg mit sieg_, sonst Ortsmusik nach 10 s
	if ende[0] == "NONE" or not probe.is_empty():
		held.setze(zurueck, "DOWN"); kamera.springe(); await abblenden(0.0)
		return
	var tp_nach := int(erg["tp"].get("hero", hw.tp))
	if ende[0] == "LOST":
		Rast.vergeht(zustand, 4 * 60)   # Game.DEATH_HOURS
		hw.tp = hw.max_tp()
		var wk: Dictionary = zustand.wiederkehr
		var alle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))
		# Test 132 (Chef 16:09: „Bei Heilung bin ich nicht vor der Schenke, sondern vor dem Tempel“): wie Game.kt state.place =
		# state.respawn im Wiederkehrort selbst (Schenke neben dem Bett, Tempel nach der Heilung des Priesters), seit die Grundrisse stehen
		if String(wk["karte"]) == karte.id: held.setze(Vector2i(int(wk["x"]), int(wk["y"])), String(wk["blick"]))
		elif FileAccess.file_exists("res://daten/" + Gebiet.datei(String(wk["karte"])) + ".bin"):
			betrete(String(wk["karte"]), Vector2i(int(wk["x"]), int(wk["y"])), String(wk["blick"]))
		else:
			var tuer := zurueck
			for a in alle["karten"][karte.id].get("ausgaenge", []):
				if String(a["ziel"]["karte"]) == String(wk["karte"]): tuer = vor_tuer(alle, String(wk["karte"]), a)
			held.setze(tuer, "DOWN")
		kamera.springe(); await abblenden(0.0)
		ui.sage([{"text": Sprache.t({"de": "Du erwachst an einem sicheren Ort … Der Heimweg hat Stunden gedauert.", "en": "You wake up somewhere safe… The way home took hours."})}])
		return
	hw.tp = clampi(tp_nach, 1, hw.max_tp())
	if ende[0] == "WON": zustand.siege += 1   # 399.1: GameState.battlesWon (System „Siege“, Thessas Ware); zaehlte bisher nie
	if not lohn.is_empty():
		zustand.gold += int(lohn.get("gold", 0))
		for d in lohn.get("items", []): zustand.dazu(String(d))   # Beute (Felle, Zaehne)
		for g in lohn.get("gear", []): zustand.ausruestung_dazu(g)   # 399.2 Ausruestung aus dem Kampflohn
		hw.ep_dazu(int(lohn.get("xp", 0)))   # Hero.gainXp: Stufe hoeher heilt ganz
	held.setze(zurueck, "DOWN")
	kamera.springe()
	await abblenden(0.0)

func abblenden(ziel: float) -> void:
	klang("verhuelle", [ziel > 0.5])   # 399.3 (Jerry): in der Schwarzblende schweigen die Effekte, Musik erst danach (Hush.kt)
	if ziel > 0.5: Messung.blende(true)
	var tw := create_tween()
	tw.tween_property(blende, "color:a", ziel, 0.35)
	await tw.finished
	if ziel <= 0.5: Messung.blende(false)

# ---------------------------------------------------------------- Gespraeche (390)
const REICHWEITE := 1.3                          # Kacheln vom Helden zur Person (Navigation.ACTION_REACH)
const TIPP_DP := 26.0                            # so nah (dp, etwa eine Fingerkuppe) am Bild der Person, Fuesse bis Kopf, trifft ein Tippen sie

func spricht_was(l: Leute) -> bool:
	return l.visible and not Geschichte.gespraech(String(l.daten.get("id", "")), zustand).is_empty()

func leute_liste() -> Array:
	if leute == null: return []
	return leute.get_children().filter(func(l): return l is Leute and not l.is_queued_for_deletion() and l.visible)

# wie Navigation.actionTarget: Personen in Reichweite; [Person, im Faecher von 120 Grad vor dem Helden], die im Faecher zuerst,
# dann die naehere; [null, false] ohne
func person_vorn() -> Array:
	if held == null: return [null, false]
	var vorn := Vector2(sin(held.rotation.y), cos(held.rotation.y))
	var best: Leute = null
	var best_w := INF
	var best_f := false
	for l in leute_liste():
		var d := Vector2(l.position.x - held.position.x, l.position.z - held.position.z) / Karte.TS
		var n := d.length()
		if n > REICHWEITE or not spricht_was(l): continue
		var f := n < 0.01 or d.normalized().dot(vorn) >= 0.5
		var w := n + (0.0 if f else 10.0)
		if w < best_w: best_w = w; best = l; best_f = f
	return [best, best_f]

func person_nah() -> Leute: return person_vorn()[0]

# angetippt: wessen Bild (Fuesse bis Kopf, 0–1,8 m) dem Finger am naechsten ist (Pruefer: ein Tippen auf den Kopf traf den
# Boden 1–1,5 m hinter der Figur)
func person_bei(sp: Vector2) -> Leute:
	var cam := get_viewport().get_camera_3d()
	if cam == null: return null
	var best: Leute = null
	var best_d := TIPP_DP * AktionsKnopf.DP
	for l in leute_liste():
		if cam.is_position_behind(l.position): continue
		var a := cam.unproject_position(l.position)
		var b := cam.unproject_position(l.position + Vector3(0, 1.8, 0))
		var d := Geometry2D.get_closest_point_to_segment(sp, a, b).distance_to(sp)
		if d < best_d and spricht_was(l): best_d = d; best = l
	return best

func sprich(l: Leute) -> void:
	held.rotation.y = atan2(l.position.x - held.position.x, l.position.z - held.position.z)
	ui.biete_an("")
	zustand.setze("met_" + String(l.daten["id"]))   # 399.1 Karte: wen der Held kennt (MapMarks.met, Game.talk)
	Ruf.gehoert(zustand, String(l.daten["id"]), false)   # 399.1 Hail.heard vor dem Gespraech
	spricht_mit = String(l.daten["id"])
	rufe.erase(spricht_mit)
	var abgabe := Auftraege.abgabe(zustand, String(l.daten["id"]))   # 399.1 Game.talk: Jobs.handIn vor dem Gespraech
	spiele(abgabe if not abgabe.is_empty() else Geschichte.gespraech(String(l.daten["id"]), zustand))

# wie Game.enqueue: neue Befehle hinten an; laufen nur, wenn gerade kein Text offen ist (Mode.Explore)
func spiele(befehle: Array) -> void:
	szene.append_array(befehle)
	if not ui.spricht(): weiter()

# wie Game.runQueue: Befehle der Reihe nach, bis einer auf den Spieler wartet (Text); der Rest nach dem Tippen
func weiter() -> void:
	while not szene.is_empty():
		var c: Dictionary = szene.pop_front()
		match String(c["art"]):
			"sagen":
				var e := {"text": Sprache.t(c["text"]).replace("{name}", zustand.name)}
				if c.has("wer"): e["wer"] = Sprache.t(c["wer"]).replace("{name}", zustand.name)
				zeige(e)
				return
			"flagge":
				zustand.setze(String(c["flagge"]))
				flaggen_neu()
			"geben":
				if String(c["ding"]).begins_with("@gear:"):   # 399.1 Game.kt Cmd.Give „@gear:RARITY:SLOT“ (Jorins Kopfschutz)
					zeige({"text": Sprache.u("found", [gear_gabe(String(c["ding"]))])})
					return
				zustand.dazu(String(c["ding"]), int(c["anzahl"]))
				zeige({"text": Sprache.u("found", [Sprache.ding(String(c["ding"]), int(c["anzahl"]))])})
				return
			"nehmen": zustand.weg(String(c["ding"]), int(c["anzahl"]))
			"gold":
				zustand.gold += int(c["anzahl"])
				zeige({"text": Sprache.u("foundGold", [int(c["anzahl"])])})
				return
			"rast": Rast.heilen(zustand, held_werte(), platz())   # Cmd.Rest (Tempel): dazu der Wiederkehrort
			"heilen": Rast.heilen(zustand, held_werte())
			"laden":   # Cmd.OpenShop: Thessa oder Morwen; die Szene geht weiter, wenn der Laden zu ist
				oeffne_laden(c["waren"], bool(c.get("brauen", false)))
				return
			"schenke":   # Cmd.Tavern: Rowenas Theke; die Szene geht weiter, wenn das Feld zu ist (Game.advance)
				oeffne_rast("schenke")
				return
			_:
				# Kampf (Jerry 348.7), Laden, Schenke, Kapitelende, Tempelszene, Morgen: in Kotlin wartet die Szene dort; bis sie
				# gebaut sind, endet sie hier, damit nichts danach (Flaggen, Saetze) ohne das Ereignis geschieht (Pruefer)
				szene.clear()
	if spricht_mit != "" and not ui.spricht():   # Hail.heard nach dem Gespraech
		Ruf.gehoert(zustand, spricht_mit, true)
		spricht_mit = ""
	if held: _steht_auf(held.kachel)

# Loot.generate mit Mindestseltenheit (rarityFor special, floor) und Platz, Stufe wie maxOf(areaLevel, hero.level)
func gear_gabe(was: String) -> String:
	var t := was.trim_prefix("@gear:").split(":")
	var hw := held_werte()
	var w := KotlinZufall.new(randi())
	var ilvl := maxi(int(karte.daten.get("stufe", 1)), hw.stufe)
	var g := Beute.erzeuge(w, zustand.neue_uid(), ilvl, Beute.seltenheit_fuer(hw, w, ilvl, true, t[0]), hw.klasse, t[1] if t.size() > 1 else "")
	zustand.ausruestung_dazu(g)
	return "%s (%s)" % [Beute.name(g), Sprache.t(Heldwerte.lade()["seltenheiten"][String(g["rarity"])]["name"])]

# ---------------------------------------------------------------- Anschlagbrett (399.1, BoardScreen.kt): was haengt, mit Aushang
# und Lohn, je einer „Annehmen“ (angenommen: grau); nichts: verblichene Naegel; „Zurück“ schliesst (Game.advance)
func oeffne_brett() -> void:
	Auftraege.lies(zustand)
	brett_offen = true
	held.halt()
	held.richtung = Vector3.ZERO
	zeige_brett()

func zeige_brett() -> void:
	var de := Sprache.aktiv() == "de"
	var k: Array = []
	for j in Auftraege.am_brett(zustand):
		var an := Auftraege.angenommen(zustand, j)
		k.append({"kopf": Sprache.t(j["titel"])})
		k.append({"zeile": Sprache.t(j["aushang"])})
		k.append({"zeile": ("Lohn: " if de else "Reward: ") + Sprache.t(j["lohn"]), "matt": true})
		k.append({"text": ("Angenommen" if de else "Accepted") if an else ("Annehmen" if de else "Accept"), "an": not an, "id": "nimm:" + String(j["id"])})
	var leer := ["Nur verblichene Nägel und Papierfetzen. Kein Aushang." if de else "Only faded nails and scraps of paper. No notices."] if k.is_empty() else []
	ui.zeige_wahl("Anschlagbrett" if de else "Notice board", leer, k, "Zurück" if de else "Back")

func _brett_wahl(id: String) -> void:
	if not brett_offen: return
	if id.begins_with("nimm:"):
		Auftraege.nimm(zustand, Auftraege.von(id.trim_prefix("nimm:")))
		speichere()
		zeige_brett()
		return
	brett_offen = false
	ui.schliesse_wahl()
	weiter()

# 399.1 Game.updateHails: wer den Helden bemerkt (Reichweite, sichtbar), ruft einmal, wenn er Neues hat; wieder erst, wenn der Held
# zwei Kacheln weiter weg war; ein neuer Ort zaehlt als neu herankommen
func rufe_neu() -> void:
	if karte.id != rufe_karte:
		rufe.clear(); rufe_karte = karte.id
	var jetzt := Time.get_ticks_msec()
	var r := Ruf.reichweite(held_werte())
	for l in leute_liste():
		var id := String(l.daten.get("id", ""))
		var d := absi(l.kachel.x - held.kachel.x) + absi(l.kachel.y - held.kachel.y)
		if rufe.has(id):
			if d > r + 2: rufe.erase(id)
		elif d <= r and id != spricht_mit:
			rufe[id] = jetzt if Ruf.neu(zustand, id) else -1
			if int(rufe[id]) >= 0:
				l.ruft_bis = jetzt + Ruf.WIEDER_MS + Ruf.ZEIGT_MS   # 306 Hail.calms
				var st := Ruf.stimme(id)                             # 134.3 mit dem Zeichen ein Ruf ohne Worte, nie zwei zugleich
				if st != "" and jetzt >= naechster_ruf:
					klang("effekt", [st, Ruf.pegel(d)])
					naechster_ruf = jetzt + Ruf.RUF_ABSTAND_MS
		l.rufe(rufe.has(id) and int(rufe[id]) >= 0 and Ruf.zeigt(jetzt - int(rufe[id])) and not ui.spricht())

# ---------------------------------------------------------------- Rast (390, RestScreen.kt, Game.rest)
# was an Kachel t zu tun ist: Lagerfeuer (in der Hoehle nur ansehen), Bett der Schenke (anderswo fremd), sonst ""
func rast_kachel(t: Vector2i) -> String:
	match karte.zeichen(t):
		"F": return "hoehle" if String(karte.daten.get("art", "")) == "CAVE" else "feuer"
		"B": return "zimmer" if karte.id == "inn" else "bett"
	return ""

# 399.1 Menue wie alt (menue.gd): die Leiste oeffnet es, nur beim Erkunden (alt: game.mode == Mode.Explore); das Spiel steht so lange
func oeffne_menue() -> void:
	if ui.spricht() or rast_ort != "" or laden != null or kampf != null or get_tree().paused: return
	held.halt(); held.richtung = Vector3.ZERO
	var ebene := CanvasLayer.new()
	ebene.layer = 40
	ebene.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ebene)
	var m := Menue.new(held_werte(), zustand)
	m.ort = platz()
	m.dunkel = im_dunkeln()
	ebene.add_child(m)
	m.speichern.connect(speichere)
	m.ankunft.connect(func():   # 399.1 Chronik „Die Ankunft ansehen“ (69d, vm.watchIntro)
		m.zu.emit()
		get_tree().paused = true
		await zwischenbild("intro")
		get_tree().paused = false
		klang("ort", [karte, held]))
	m.sprache.connect(sprache_wechseln)
	m.test.connect(func(was: String, mit: Array):   # 399.1 Reiter „Test“: erst das Menue zu, dann in der Welt
		m.zu.emit()
		test_tat(was, mit))
	m.ueber.connect(func():   # 399.1 System „Über“ wie alt: vm.toMenu, dann Screen.ABOUT
		Hauptmenue.ueber_zuerst = true
		m.hauptmenue.emit())
	m.hauptmenue.connect(func():   # 399.1: wie alt vm.toMenu: speichern, dann von vorn mit dem Hauptmenue
		speichere()
		get_tree().paused = false
		get_tree().reload_current_scene())
	get_tree().paused = true
	m.zu.connect(func():
		get_tree().paused = false
		ebene.queue_free()
		speichere()
		ui.richte_ein()      # 399.1 Bedienung aus dem Menue System
		fackel_neu()
		kamera.fern_neu()
		ui.leiste.zeige(held_werte(), zustand, licht.nacht > 0.65))

# 399.1 Reiter „Test“ (Testmodus.gd) wie alt: cheatWarp, cheatChapterEnd, cheatFight, startProbe
func test_tat(was: String, mit: Array) -> void:
	match was:
		"teleport":
			await abblenden(1.0)
			var von := karte.id
			betrete(String(mit[0]), Vector2i(int(mit[1]), int(mit[2])), String(mit[3]))
			await ortsworte(von, false)
		"kapitelende":   # Hoehle geschafft, Lyra frei, das Amulett in der Tasche, Abend, vor Aldric in seinem Haus
			for f in [Geschichte.INTRO_DONE, Geschichte.QUEST_STARTED, Geschichte.BARRIER_OPEN, Geschichte.KROGG_DEFEATED, Geschichte.GRAK_DEFEATED,
					Geschichte.LYRA_RESCUED, Geschichte.LYRA_GONE]:
				zustand.setze(f)
			if zustand.anzahl("sun_amulet") == 0: zustand.dazu("sun_amulet")
			if zustand.minuten < 18 * 60: zustand.minuten = 20 * 60
			var ziel := Testmodus.vor_aldric()
			if ziel.is_empty(): return
			await abblenden(1.0)
			var von := karte.id
			betrete("elder", ziel[0], ziel[1])
			await ortsworte(von, false)
			ui.sage([{"text": Sprache.t({"de": "Höhle geschafft, Lyra frei, Amulett in der Tasche: sprich mit Aldric.", "en": "Cave cleared, Lyra free, the amulet in your bag: talk to Aldric."})}])
		"kampf", "probe":
			if not ResourceLoader.exists("res://kampf/kampfort.gd"): return
			await abblenden(1.0)
			await kampf_im_wald(held.kachel, String(mit[0]), [] if was == "kampf" else [String(mit[1]), int(mit[2])])

# 399.1 Schwarzblende mit Worten wie alt (Ortsblende, 24.1): auf der stehenden Blende Name und Satz, dann steigt der Ort auf;
# [von] leer beim Spielbeginn, [erster] beim ersten Besuch. Ohne daten/intro.json wie bisher nur die Blende
func ortsworte(von: String, erster: bool) -> void:
	if not Zwischenbild.da():
		await abblenden(0.0)
		return
	var a := Ortsblende.art_fuer(von, karte.id, erster)
	var satz = null
	if a == "FULL":
		var z := RandomNumberGenerator.new()
		z.randomize()
		satz = Ortsblende.waehle(Ortsblende.saetze(karte.id, zustand, tageszeit() == "nacht"), Ortsblende.letzter.get("satz"), z)
		if satz != null: Ortsblende.letzter["satz"] = satz
	var o := Ortsblende.new(a, karte.name(), satz)
	ui.add_child(o)
	blende.color.a = 0.0   # das Schwarz traegt jetzt die Ortsblende
	await o.fertig
	o.queue_free()
	Messung.blende(false)
	klang("verhuelle", [false])   # 319: Effekte und Musik erst, wenn der Ort da ist

# 399.1 Zwischensequenz (Zwischenbild, 69): ueber allem, laeuft auch, wenn das Spiel steht; ohne daten/intro.json gleich vorbei
func zwischenbild(art: String) -> void:
	if not Zwischenbild.da(): return
	var ebene := CanvasLayer.new()
	ebene.layer = 60
	ebene.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ebene)
	var z := Zwischenbild.new(art, get_node_or_null("/root/Klang"))
	ebene.add_child(z)
	await z.fertig
	ebene.queue_free()

# 399.1 Game.heroInDark: nachts draussen, in der Hoehle immer
func im_dunkeln() -> bool:
	var art := String(karte.daten.get("art", ""))
	return (licht.nacht > 0.5 and art != "INTERIOR") or art == "CAVE"

func fackel_neu() -> void:
	if held: held.fackel_neu(Menue.fackel(held_werte()), String(karte.daten.get("art", "")) == "INTERIOR")

func held_werte() -> Heldwerte:
	if werte == null: werte = Heldwerte.erschaffe(zustand.name, "HUMAN", "FIGHTER")
	return werte

func platz() -> Dictionary:
	return {"karte": karte.id, "x": held.kachel.x, "y": held.kachel.y, "blick": held.blick()}

func oeffne_rast(ort: String) -> void:
	rast_ort = ort
	rast_notiz = ""
	rast_zweites = randf() < 0.5   # Rowena sagt das eine oder das andere
	held.halt()
	held.richtung = Vector3.ZERO
	zeige_rast()

# RestBody: Feuer kurz und lang; Theke Met und Zimmer; Bett Zimmer. Fleisch an Rowena verkaufen kommt mit dem Laden (Preis)
func zeige_rast() -> void:
	var z := zustand
	var lang_ok := Rast.lange_erlaubt(z)
	var titel := Sprache.r({"feuer": "ask", "schenke": "tavern", "zimmer": "room"}[rast_ort])
	var zeilen_: Array = []
	if rast_ort != "feuer": zeilen_.append("%s: %d" % [Sprache.u("gold"), z.gold])
	if rast_ort == "schenke": zeilen_.append(Rast.rowena_sagt(z, held_werte().name, rast_zweites))
	var k: Array = []
	if rast_ort == "feuer":
		k.append({"text": Sprache.r("short"), "info": Sprache.r("shortDoes"), "id": "kurz"})
		k.append({"text": Sprache.r("long"), "info": Sprache.r("longDoes" if lang_ok else "longDone"), "an": lang_ok, "id": "lang"})
	else:
		if rast_ort == "schenke" and not z.betrunken():
			var preis := Rast.met_preis(z)
			k.append({"text": Sprache.r("meadBuy", [preis]), "info": Sprache.r("meadDoes"), "an": z.gold >= preis, "id": "met"})
		k.append({"text": Sprache.r("roomBuy", [Rast.ZIMMER_PREIS]), "info": Sprache.r("roomDoes" if lang_ok else "longDone"),
			"an": lang_ok and z.gold >= Rast.ZIMMER_PREIS, "id": "lang"})
	ui.zeige_wahl(titel, zeilen_, k, Sprache.r("leave"), rast_notiz)

func _rast_wahl(id: String) -> void:
	if rast_ort == "": return
	match id:
		"":
			rast_ort = ""
			ui.schliesse_wahl()
			weiter()
			_steht_auf(held.kachel)
		"met":
			rast_notiz = Rast.met_trinken(zustand, held_werte().name)
			zeige_rast()
		"kurz", "lang":
			await raste(id)

# die Welt wird schwarz, die Zeit vergeht (Satz in Gold), dann die Welt zur neuen Stunde mit dem Satz der Rast
func raste(art: String) -> void:
	var ort := rast_ort
	ui.schliesse_wahl()
	await abblenden(1.0)
	var satz := Label.new()
	satz.text = Sprache.r("hourGone" if art == "kurz" else "hoursGone")
	satz.add_theme_font_size_override("font_size", 40)
	satz.add_theme_color_override("font_color", Steuerung.GOLD)
	satz.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	satz.grow_horizontal = Control.GROW_DIRECTION_BOTH; satz.grow_vertical = Control.GROW_DIRECTION_BOTH
	blende.add_child(satz)
	await get_tree().create_timer(1.3).timeout
	satz.queue_free()
	var r := Rast.rasten(zustand, held_werte(), art, ort, platz())
	if r.has("nein"):
		rast_notiz = String(r["nein"])
		await abblenden(0.0)
		zeige_rast()
		return
	rast_ort = ""
	var neu: Dictionary = r.get("ort", {})
	if not neu.is_empty() and String(neu["karte"]) == karte.id: held.setze(Vector2i(int(neu["x"]), int(neu["y"])), String(neu["blick"]))
	# Licht zur neuen Stunde (bis die Uhr das Licht fuehrt: Nacht 21-5 wie LISTE-UMZUG-348 „Stimmung“)
	var nachts := zustand.minuten >= 21 * 60 or zustand.minuten < 5 * 60
	if (licht.ziel > 0.5) != nachts: licht.umschalten()
	kamera.springe()
	await abblenden(0.0)
	var zeilen_: Array = []
	for t in r["zeilen"]: zeilen_.append({"text": t})
	zeige_zeilen(zeilen_)

# ---------------------------------------------------------------- Laden (390, ShopScreen.kt): Dinge kaufen (Menge waehlen, 59.5),
# Verkaeufliches aus der Tasche verkaufen, die letzten fuenf Verkaeufe zurueckkaufen, bei Morwen brauen; Ausruestung bei Thessa
# kaufen (Tragbares zuerst, 59.2), ueberall verkaufen (Seltenes zuerst), Gewoehnliches auf einmal.
func oeffne_laden(waren: Array, brauen: bool) -> void:
	laden = Laden.new(waren, brauen)
	laden_notiz = ""
	laden_menge = {}
	laden_frage = ""
	laden_stueck = ""
	held.halt()
	held.richtung = Vector3.ZERO
	zeige_laden()

func zeige_laden() -> void:
	if not laden_menge.is_empty():
		zeige_menge()
		return
	var h := held_werte()
	var z := zustand
	var k: Array = [{"kopf": Sprache.t(Laden.VORRAETE)}]
	for id in laden.waren:
		var p := Laden.kaufpreis(h, String(id))
		k.append({"text": "%s · %s" % [Laden.name(String(id)), Sprache.u("price", [p])], "info": Sprache.t(Laden.ding(String(id)).get("info", "")),
			"an": z.gold >= p, "id": "kauf:" + String(id), "bild": "ding-" + String(id)})
	if laden.brauen:
		k.append({"kopf": Sprache.t(Laden.REZEPTE)})
		var rz := Laden.rezepte()
		for i in rz.size():
			k.append({"text": Laden.name(String(rz[i]["ergebnis"])), "info": Laden.kosten(rz[i]), "an": Laden.bezahlbar(z, rz[i]), "id": "brau:%d" % i})
	if not laden.brauen:   # Morwen handelt nur mit Kraeutern und Traenken
		var ware := Laden.ware(z, h)
		k.append({"kopf": "%s (%d)" % [Sprache.t(Laden.AUSRUESTUNG), ware.size()]})
		var nicht := ware.filter(func(g): return not h.kann_tragen(g))
		for g in ware.filter(func(g): return h.kann_tragen(g)): k.append(_ware_zeile(h, g, true))
		if not nicht.is_empty(): k.append({"kopf": "%s (%d)" % [Sprache.t(Laden.NICHT_TRAGBAR), nicht.size()]})
		for g in nicht: k.append(_ware_zeile(h, g, true))
	var verk := z.taschen.keys().filter(func(id): return Laden.verkaeuflich(String(id)))
	if not verk.is_empty(): k.append({"kopf": Sprache.u("sell")})
	for id in verk:   # Tippen waehlt die Menge (59.5); in Klammern, wie viele er hat
		k.append({"text": "%s (%d) · %s" % [Laden.name(String(id)), z.anzahl(String(id)), Sprache.u("price", [Laden.verkaufspreis(h, String(id))])],
			"id": "verk:" + String(id), "bild": "ding-" + String(id)})
	if not z.beutel.is_empty():
		k.append({"kopf": "%s: %s (%d)" % [Sprache.u("sell"), Sprache.t(Laden.AUSRUESTUNG), z.beutel.size()]})
		if z.beutel.any(func(g): return String(g["rarity"]) == "COMMON"): k.append({"text": Sprache.t(Laden.GEWOEHNLICHE), "id": "alle"})
		# Seltenes zuerst, dann nach Platz (ShopScreen: rarity absteigend, slot)
		var reihe := range(z.beutel.size())
		reihe.sort_custom(func(a, b):
			var ga: Dictionary = z.beutel[a]
			var gb: Dictionary = z.beutel[b]
			var ra := Beute.stufe_von(String(ga["rarity"]))
			var rb := Beute.stufe_von(String(gb["rarity"]))
			if ra != rb: return ra > rb
			var sa := Beute.PLAETZE.find(String(Beute.grundform(String(ga["base"]))["slot"]))
			var sb := Beute.PLAETZE.find(String(Beute.grundform(String(gb["base"]))["slot"]))
			return sa < sb if sa != sb else a < b)
		for i in reihe: k.append(_ware_zeile(h, z.beutel[i], false, i))
	if not laden.rueckkauf.is_empty(): k.append({"kopf": Sprache.t(Laden.ZURUECK)})
	for i in laden.rueckkauf.size():
		var r: Dictionary = laden.rueckkauf[i]
		k.append({"text": "%s · %s" % [Laden.verkauft_name(r), Sprache.u("price", [int(r["preis"])])],
			"an": z.gold >= int(r["preis"]), "id": "zur:%d" % i})
	var kopf := Sprache.t(Laden.HUETTE) if laden.brauen else Sprache.u("shop")
	var zeilen_: Array = ["%s: %d" % [Sprache.u("gold"), z.gold]]
	if laden.brauen: zeilen_.append(Sprache.t(Laden.KRAEUTER))
	if not laden.brauen: zeilen_.append(Sprache.t(Laden.NEUE_WARE))
	ui.zeige_wahl(kopf, zeilen_, k, Sprache.u("close"), laden_notiz)

# 59.5, 349 (supplyDialog): ein Ding kaufen oder verkaufen, eins weniger, eins mehr, ×1, ×5, beim Verkauf auch alle; der Preis folgt
func zeige_menge() -> void:
	var h := held_werte()
	var z := zustand
	var id := String(laden_menge["id"])
	var kaufen := bool(laden_menge["kaufen"])
	var stueck := Laden.kaufpreis(h, id) if kaufen else Laden.verkaufspreis(h, id)
	var most := Laden.kann_kaufen(z, h, id) if kaufen else z.anzahl(id)
	var n := clampi(int(laden_menge["n"]), 1, maxi(1, most))
	laden_menge["n"] = n
	var preis := stueck * n
	var zeilen_: Array = [Sprache.t(Laden.ding(id).get("info", "")), "%s: %d" % [Sprache.t(Laden.MENGE), n],
		Sprache.t(Laden.BESITZ) + "%d → %d" % [z.anzahl(id), z.anzahl(id) + (n if kaufen else -n)],
		"%s: %d → %d" % [Sprache.u("gold"), z.gold, z.gold - preis if kaufen else z.gold + preis]]
	if most < 1: zeilen_.append(Sprache.u("notEnoughGold") if kaufen else Sprache.u("nothing"))
	var k: Array = [{"text": "−", "an": n > 1, "id": "m:-"}, {"text": "+", "an": n < most, "id": "m:+"},
		{"text": "×1", "an": most >= 1, "id": "m:1"}, {"text": "×5", "an": most >= 5, "id": "m:5"}]
	if not kaufen: k.append({"text": Sprache.t(Laden.ALLE), "an": most >= 1, "id": "m:alle"})
	k.append({"text": "%s%s · %s" % [Sprache.u("buy") if kaufen else Sprache.u("sell"), " ×%d" % n if n > 1 else "", Sprache.u("price", [preis])],
		"an": most >= 1, "id": "m:ok"})
	ui.zeige_wahl(Laden.name(id), zeilen_, k, Sprache.u("back"), laden_notiz)

# 399.1 gearDialog (ShopScreen): Name, GearDetails, Gold vorher → nachher, „Kaufen · Preis“ (ohne Gold matt) oder „Verkaufen · Preis“
func zeige_stueck(id: String, g: Dictionary, kaufen: bool) -> void:
	var h := held_werte()
	var p := Laden.kaufpreis_von(h, g) if kaufen else Laden.verkaufspreis_von(h, g)
	laden_stueck = id
	var zeilen_: Array = Menue.stueck_zeilen_von(h, g)
	zeilen_.append("%s: %d → %d" % [Sprache.u("gold"), zustand.gold, zustand.gold - p if kaufen else zustand.gold + p])
	if kaufen and zustand.gold < p: zeilen_.append(Sprache.u("notEnoughGold"))
	ui.zeige_wahl(Beute.name(g), zeilen_, [{"text": "%s · %s" % [Sprache.u("buy") if kaufen else Sprache.u("sell"), Sprache.u("price", [p])],
		"an": not kaufen or zustand.gold >= p, "id": "ok"}], "Abbrechen" if _de() else "Cancel")

# 399.1 (59e, ShopScreen): noch einmal fragen, mit Titel, Zeilen und dem Knopf, der es tut; „Abbrechen“ zurueck
func _frage(id: String, titel: String, zeilen_: Array, knopf: String) -> void:
	laden_frage = id
	ui.zeige_wahl(titel, zeilen_, [{"text": knopf, "id": "ja"}], "Abbrechen" if _de() else "Cancel")

func _de() -> bool: return Sprache.aktiv() == "de"

# 59e: alles von einem Ding verkaufen (mit „Alle“ gewaehlt, mindestens zwei) fragt noch einmal
func _frage_menge(id: String, was: String) -> bool:
	if was != "ok" or bool(laden_menge["kaufen"]) or not bool(laden_menge.get("alle", false)) or not Bedienung.rueckfragen: return false
	var ding := String(laden_menge["id"])
	var n := mini(int(laden_menge["n"]), zustand.anzahl(ding))
	if n < 2: return false
	_frage(id, "Alle verkaufen?" if _de() else "Sell all?", ["%s ×%d" % [Laden.name(ding), n]],
		"%s ×%d · %s" % [Sprache.u("sell"), n, Sprache.u("price", [Laden.verkaufspreis(held_werte(), ding) * n])])
	return true

func _menge_wahl(was: String) -> void:
	var h := held_werte()
	var id := String(laden_menge["id"])
	var kaufen := bool(laden_menge["kaufen"])
	var most := Laden.kann_kaufen(zustand, h, id) if kaufen else zustand.anzahl(id)
	laden_menge["alle"] = was == "alle" or (was == "ok" and bool(laden_menge.get("alle", false)))   # alt amount == Int.MAX_VALUE
	match was:
		"-": laden_menge["n"] = int(laden_menge["n"]) - 1
		"+": laden_menge["n"] = int(laden_menge["n"]) + 1
		"1", "5": laden_menge["n"] = int(was)
		"alle": laden_menge["n"] = most
		"ok":
			var n := clampi(int(laden_menge["n"]), 1, maxi(1, most))
			laden_notiz = laden.kaufe(zustand, h, id, n) if kaufen else laden.verkaufe(zustand, h, id, n)
			laden_menge = {}

# ein Stueck Ausruestung: Name · Preis, darunter Seltenheit und Gear.listLine; [i] Platz in der Tasche beim Verkauf
func _ware_zeile(h: Heldwerte, g: Dictionary, kaufen: bool, i: int = -1) -> Dictionary:
	var p := Laden.kaufpreis_von(h, g) if kaufen else Laden.verkaufspreis_von(h, g)
	var selten := Sprache.t(Beute.d_()["seltenheiten"][String(g["rarity"])]["name"])
	var zeile := Beute.listen_zeile(g)
	return {"text": "%s · %s" % [Beute.name(g), Sprache.u("price", [p])], "info": selten.left(1).to_upper() + selten.substr(1) + (" · " + zeile if zeile != "" else ""),
		"an": zustand.gold >= p if kaufen else true, "id": ("ag:%d" % int(g["uid"])) if kaufen else ("vg:%d" % i), "bild": "stueck-%s-%s" % [g["base"], g["rarity"]]}

func _laden_wahl(id: String, ja := false, gesehen := false) -> void:
	if laden == null: return
	if laden_frage != "":   # „Verkaufen“ fuehrt die Wahl aus, „Abbrechen“ zurueck in die Liste
		var war := laden_frage
		laden_frage = ""
		if id == "ja": _laden_wahl(war, true, true)
		else: zeige_laden()
		return
	if laden_stueck != "":   # „Kaufen“/„Verkaufen“ im Kasten fuehrt aus (Seltenes fragt dann noch einmal), „Abbrechen“ zurueck
		var st := laden_stueck
		laden_stueck = ""
		if id == "ok": _laden_wahl(st, false, true)
		else: zeige_laden()
		return
	var h := held_werte()
	if id == "" and not laden_menge.is_empty():   # „Zurück“ aus der Menge in die Liste
		laden_menge = {}
		zeige_laden()
		return
	if id == "":
		laden = null
		ui.schliesse_wahl()
		weiter()
		_steht_auf(held.kachel)
		return
	var teil := id.split(":")
	match teil[0]:
		"kauf": laden_menge = {"id": teil[1], "kaufen": true, "n": 1}
		"verk": laden_menge = {"id": teil[1], "kaufen": false, "n": 1}
		"m":
			if not ja and _frage_menge(id, teil[1]): return
			_menge_wahl(teil[1])
		"zur": laden_notiz = laden.zurueck(zustand, int(teil[1]))
		"ag":
			for g in Laden.ware(zustand, h):
				if int(g["uid"]) != int(teil[1]): continue
				if not gesehen: zeige_stueck(id, g, true); return
				laden_notiz = laden.kaufe_ausruestung(zustand, h, g); break
		"vg":
			var g: Dictionary = zustand.beutel[int(teil[1])]
			if not gesehen: zeige_stueck(id, g, false); return
			if not ja and Bedienung.rueckfragen and Beute.stufe_von(String(g["rarity"])) >= Beute.stufe_von("RARE"):
				var p := Laden.verkaufspreis_von(h, g)
				_frage(id, "Wirklich verkaufen?" if _de() else "Really sell?", ["%s (%s)" % [Beute.name(g), Sprache.t(Beute.d_()["seltenheiten"][String(g["rarity"])]["name"])]],
					"%s · %s" % [Sprache.u("sell"), Sprache.u("price", [p])])
				return
			laden_notiz = laden.verkaufe_ausruestung(zustand, h, int(teil[1]))
		"alle":
			if not ja and Bedienung.rueckfragen:
				var gew := zustand.beutel.filter(func(g): return String(g["rarity"]) == "COMMON")
				var summe := 0
				for g in gew: summe += Laden.verkaufspreis_von(h, g)
				_frage(id, "Alle gewöhnlichen verkaufen?" if _de() else "Sell all common items?",
					[("%d Gegenstände:" if _de() else "%d items:") % gew.size(), ", ".join(PackedStringArray(gew.map(func(g): return Beute.name(g))))],
					("Verkaufen · " if _de() else "Sell · ") + Sprache.u("price", [summe]))
				return
			laden_notiz = Sprache.t(Laden.GEWOEHNLICHE_WEG) % laden.verkaufe_gewoehnliches(zustand, h)
		"brau": laden_notiz = laden.braue(zustand, h, Laden.rezepte()[int(teil[1])])
	zeige_laden()

func zeige_zeilen(z: Array) -> void:
	held.halt()
	held.richtung = Vector3.ZERO
	ui.sage(z)

# eine Zeile zeigen; der Held bleibt stehen wie in Mode.Dialog (Pruefer: lief mit dem Joystick weiter)
func zeige(e: Dictionary) -> void:
	held.halt()
	held.richtung = Vector3.ZERO
	ui.sage([e])

# nach einer neuen Flagge: Wege (Schlagbaum, Tor) und wer zu sehen ist (Story.kt visible)
func flaggen_neu() -> void:
	karte.baue_wege()
	sichtbar_neu()

func sichtbar_neu() -> void:
	if leute == null: return
	for l in leute.get_children():
		if l is Leute: l.zeige(Geschichte.sichtbar(String(l.daten.get("id", "")), zustand))

# ---------------------------------------------------------------- Lauf
func _process(dt: float) -> void:
	if held == null: return
	Messung.bild(dt, "%s %d/%d" % [karte.id, held.kachel.x, held.kachel.y])   # 399.1 Gerät: Messwerte wie alt
	held.laeuft = Ausdauer.schritt(zustand, held_werte(), dt * 1000.0, held.geht(), laufen_will)   # 399.1 Stamina.step
	ui.ausdauer_balken.z = zustand
	klang("atme", [zustand.atemlos and kampf == null, zustand.ausdauer])   # 399.3 (Jerry): atemlos keucht er (Panting.kt)
	rufe_neu()
	Leute.still = ui.spricht()   # 390: wer spricht, bleibt stehen (Mode.Dialog)
	if is_instance_valid(ziel_person) and not ui.spricht():
		var nah := person_nah()
		if nah == ziel_person or not held.geht():
			var wer := ziel_person
			ziel_person = null
			if nah == wer:
				held.halt()
				sprich(wer)
	angebot_uhr -= dt
	if angebot_uhr <= 0.0 and not ui.spricht():
		angebot_uhr = 0.25
		_steht_auf(held.kachel)
	if ziel_stoss.x >= 0 and not held.geht():
		var s := ziel_stoss
		ziel_stoss = Vector2i(-1, -1)
		if (s - held.kachel).length_squared() == 1:
			held.rotation.y = atan2(float(s.x - held.kachel.x), float(s.y - held.kachel.y))
			if karte.tuer(s) or zeichen_lesbar(s) or rast_kachel(s) != "": ui.biete_an.callv(angebot(held.kachel))
			else: _stoesst(s)
	if rast_ort == "" and laden == null: zustand.uhr(dt)   # 390: in Rast und Laden steht die Uhr; die Rast stellt sie selbst weiter
	leiste_uhr -= dt
	if leiste_uhr <= 0.0:   # 399.1 Leiste: viermal je Sekunde reicht fuer Uhr und Werte
		leiste_uhr = 0.25
		ui.leiste.zeige(held_werte(), zustand, licht.nacht > 0.65)
	kamera.folge(minf(1.0, dt * 5.0))
	ui.windrose.richte(kamera.nord_winkel())
	gebiet.nah(kamera.nah, held.position)
	zeiten.append(dt)
	if zeiten.size() > 240: zeiten.pop_front()
	if Testmodus.standort: ui.standort = "%s %d/%d" % [karte.id, held.kachel.x, held.kachel.y]
	ui.messe(zeiten)

# ---------------------------------------------------------------- Standbilder am Rechner (Vergleich alt/neu)
func bilder() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--bilder="): dir = a.substr(9)
	if dir == "": return
	held.fackel_neu(true, false)   # 399.1: Probe wie bisher mit Fackel (im Spiel nur in der Nebenhand)
	DirAccess.make_dir_recursive_absolute(dir)
	ui.mess.visible = false
	ui.oben.visible = false   # 348.6 (Befund 7): Probeknoepfe standen vor der Turmspitze
	ui.leiste.visible = false   # 399.1: Vergleichsbilder ohne Leiste
	await get_tree().create_timer(1.0).timeout
	await knips(dir + "/tag.png")
	held.geh_zu(held.position + Vector3(3.0, 0, -2.0))
	await get_tree().create_timer(0.8).timeout
	await knips(dir + "/gehen.png")
	kamera.drehe(90.0)                              # Windrose dreht mit, Tippen auf sie zurueck nach Norden
	await get_tree().create_timer(2.0).timeout
	await knips(dir + "/drehen.png")
	kamera.nach_norden()
	await get_tree().create_timer(2.0).timeout
	licht.umschalten()
	await get_tree().create_timer(2.5).timeout
	await knips(dir + "/nacht.png")
	licht.umschalten()
	held.setze(Vector2i(6, 6), "UP")                # vor dem Gasthaus: Aktionsknopf an der Tuer
	held.geh_zu(karte.kachel_pos(Vector2i(6, 5)))
	await get_tree().create_timer(2.5).timeout
	await knips(dir + "/tuer.png")
	held.setze(Vector2i(17, 3), "UP")               # Schlagbaum: unten, Text aus Game.barrier
	held.richtung = Vector3(0, 0, -1)
	await get_tree().create_timer(1.0).timeout
	held.richtung = Vector3.ZERO
	await knips(dir + "/schlagbaum.png")
	ui.sage([])
	held.setze(Vector2i(28, 7), "UP")               # Laden (Haus 26/3, Tuer 28/5): Markise vor der Front; Grundansicht wie alt (3486 a)
	await get_tree().create_timer(1.0).timeout
	await knips(dir + "/laden.png")
	held.setze(Vector2i(27, 2), "UP")               # hinter dem Laden: das Haus verdeckt ihn und wird als Ganzes halb durchsichtig (Durchsicht)
	await get_tree().create_timer(1.0).timeout
	await knips(dir + "/hinter.png")
	held.setze(Vector2i(31, 22), "UP")              # Kirche (Haus 26/18, Tuer 28/20, Glockenturm am Ostende) von Suedosten
	await get_tree().create_timer(1.0).timeout
	await knips(dir + "/kirche.png")
	held.setze(Vector2i(15, 24), "UP")              # Fluss mit Bruecke (17-18/25-27) und Brueckenlaterne 19/27, Schilf am Nordufer
	await get_tree().create_timer(1.0).timeout
	await knips(dir + "/fluss.png")
	licht.umschalten()
	await get_tree().create_timer(2.5).timeout
	await knips(dir + "/fluss_nacht.png")
	licht.umschalten()
	for st in [[Licht.Stand.MORGEN, "morgen"], [Licht.Stand.ABEND, "abend"]]:   # Runde 11: drei Sonnenstaende wie MapSun.Stand
		licht.setze_stand(st[0])
		for o in [[Vector2i(31, 22), "kirche"], [Vector2i(19, 13), "markt"]]:
			held.setze(o[0], "UP")
			await get_tree().create_timer(1.0).timeout
			await knips(dir + "/%s_%s.png" % [o[1], st[1]])
	licht.ziel = 0.5                                # 348.9: Abenddaemmerung wie alt um 20 Uhr (Tageslicht halb)
	licht.stelle(0.5)
	for o in [[Vector2i(31, 22), "kirche"], [Vector2i(19, 13), "markt"]]:
		held.setze(o[0], "UP")
		await get_tree().create_timer(1.0).timeout
		await knips(dir + "/%s_daemmerung.png" % o[1])
	licht.ziel = 0.0
	licht.stelle(0.0)
	licht.setze_stand(Licht.Stand.MITTAG)
	held.setze(Vector2i(19, 13), "UP")
	await get_tree().create_timer(1.0).timeout
	await knips(dir + "/markt.png")
	held.setze(Vector2i(16, 17), "UP")              # 348.6 Leute: Pim streift um seinen Platz (15/14), Jorin auf der Runde
	await get_tree().create_timer(6.0).timeout
	await knips(dir + "/leute.png")
	held.setze(Vector2i(31, 22), "DOWN")            # Nahstufe zur Kamera gewandt (von hinten sah man kein Gesicht)
	kamera.nah_fern()                               # Nahstufe: Gesicht, Haende, Linie am Helden
	var zu: Vector3 = kamera.global_basis.z   # zur Kamera (Blick ist -z); Runde 2b: DOWN zeigte das Gesicht halb seitlich, ein Auge hinter der Nase
	held.rotation.y = atan2(zu.x, zu.z)
	await get_tree().create_timer(2.0).timeout
	await knips(dir + "/nah.png")
	get_tree().quit()

# 348.6 Leute: --gang=<ordner> stellt die Leute nebeneinander auf den Platz, seitlich zur Kamera, und legt je 0,1 s
# ein Bild eines Doppelschritts ab (Gang je Figur pruefen, Chef 17:03); die Figuren gehen auf der Stelle
func gang_film() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--gang="): dir = a.substr(7)
	if dir == "": return
	DirAccess.make_dir_recursive_absolute(dir)
	ui.mess.visible = false
	ui.oben.visible = false
	ui.leiste.visible = false   # 399.1: Vergleichsbilder ohne Leiste
	held.setze(Vector2i(25, 9), "DOWN")
	for l in leute.get_children():   # nur die Leute
		if l.daten.has("tier"): l.free()
	held.leute = leute.get_children()
	var quer: Vector3 = kamera.global_basis.x
	quer.y = 0
	quer = quer.normalized()
	var mitte := karte.kachel_pos(Vector2i(19, 15))
	var n := leute.get_child_count()
	for i in n:
		var l: Leute = leute.get_child(i)
		l.set_process(false)
		l.position = mitte + quer * (float(i) - (n - 1) / 2.0) * 0.7
		l.rotation.y = atan2(quer.x, quer.z)
		l.anim.play("Gehen")
		l.anim.speed_scale = Leute.TEMPO
	kamera.ziel = leute.get_child(n / 2)
	kamera.nah_fern()
	kamera.springe()
	await get_tree().create_timer(1.5).timeout
	for f in 14:
		await knips(dir + "/gang_%02d.png" % f)
		await get_tree().create_timer(0.1).timeout
	get_tree().quit()

# 348.6 Leute (Diogenes: naechstes Blatt im Spiel-Licht): --leute=<ordner> stellt alle Figuren aus daten/leute in zwei Reihen
# auf den Dorfplatz, in Ruhehaltung zur Kamera; Bilder in der Grundansicht und nah, je vorn und hinten, Mittag und Nacht
func leute_blatt() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--leute="): dir = a.substr(8)
	if dir == "": return
	DirAccess.make_dir_recursive_absolute(dir)
	ui.mess.visible = false
	ui.oben.visible = false
	ui.leiste.visible = false   # 399.1: Vergleichsbilder ohne Leiste
	for l in leute.get_children(): l.free()
	var ids: Array = []
	for f in DirAccess.get_files_at("res://daten/leute"):
		if f.ends_with(".bin"): ids.append(f.get_basename())
	ids.sort()
	held.setze(Vector2i(25, 9), "DOWN")
	var quer: Vector3 = kamera.global_basis.x
	quer.y = 0
	quer = quer.normalized()
	var tief := Vector3(-quer.z, 0, quer.x)          # von der Kamera weg (zweite Reihe dahinter)
	var zu: Vector3 = kamera.global_basis.z
	var mitte := karte.kachel_pos(Vector2i(19, 15))
	var reihe := ceili(ids.size() / 2.0)
	var mitte_n: Node3D
	for i in ids.size():
		var l := Leute.new(karte, {"id": ids[i], "x": 19, "y": 15}, held)
		leute.add_child(l)
		l.set_process(false)
		var r := i / reihe
		var k := i % reihe
		l.position = mitte + quer * (float(k) - (reihe - 1) / 2.0) * 1.0 + tief * float(r) * 1.6
		l.rotation.y = atan2(zu.x, zu.z)
		if l.anim:
			l.anim.play("Stehen")
			l.anim.seek(0.0, true)
			l.anim.pause()
		if r == 0 and k == reihe / 2: mitte_n = l
	held.leute = leute.get_children()
	print("LEUTE BLATT ", ids)
	kamera.ziel = mitte_n
	kamera.springe()
	await get_tree().create_timer(1.5).timeout
	for seite in ["vorn", "hinten"]:
		await knips(dir + "/leute_%s.png" % seite)
		kamera.nah_fern()
		kamera.springe()
		await get_tree().create_timer(1.0).timeout
		await knips(dir + "/leute_%s_nah.png" % seite)
		kamera.nah_fern()
		kamera.springe()
		for l in leute.get_children(): l.rotation.y += PI
		await (Engine.get_main_loop() as SceneTree).create_timer(0.5).timeout
	# Leute Runde 4 (Helfer: Bein durch den Rock im Gang): alle gehen auf der Stelle, seitlich zur Kamera, vier Bilder nah
	for l in leute.get_children():
		l.rotation.y = atan2(zu.x, zu.z) + PI / 2
		if l.anim: l.anim.play("Gehen")
	kamera.nah_fern()
	var vorn_reihe: Array = leute.get_children().slice(0, reihe)
	for t in 3:   # links, Mitte, rechts: die Nahstufe zeigt je drei Figuren einer Reihe
		kamera.ziel = vorn_reihe[clampi(1 + t * 2, 0, reihe - 1)]
		kamera.springe()
		await get_tree().create_timer(0.8).timeout
		for f in 2:
			await knips(dir + "/leute_gang_%d%d.png" % [t, f])
			await get_tree().create_timer(0.27).timeout
	kamera.ziel = mitte_n
	kamera.nah_fern()
	kamera.springe()
	for l in leute.get_children():
		l.rotation.y = atan2(zu.x, zu.z)
		if l.anim:
			l.anim.play("Stehen")
			l.anim.seek(0.0, true)
			l.anim.pause()
	licht.umschalten()
	await get_tree().create_timer(2.5).timeout
	await knips(dir + "/leute_nacht.png")
	get_tree().quit()

# 348.6 Held (Chef 18:06/18:20 zur Dorf-APK): --held=<ordner> Brunnen und Marktstand, Gehen in Rennen (Bild je 1/15 s),
# Rennen seitlich nah, nachts Stehen, Gehen, Rennen mit der Fackel
func held_film() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--held="): dir = a.substr(7)
	if dir == "": return
	held.fackel_neu(true, false)   # 399.1: Probe wie bisher mit Fackel (im Spiel nur in der Nebenhand)
	DirAccess.make_dir_recursive_absolute(dir)
	ui.mess.visible = false
	ui.oben.visible = false
	ui.leiste.visible = false   # 399.1: Vergleichsbilder ohne Leiste
	for l in leute.get_children(): l.free()
	held.leute = []
	held.setze(Vector2i(18, 18), "UP")              # Brunnen 16/16 (348.6, vorher 17/14) und Staende 14-15/12, 20-21/12
	await get_tree().create_timer(1.5).timeout
	await knips(dir + "/brunnen.png")
	kamera.nah_fern()
	kamera.springe()
	await get_tree().create_timer(1.0).timeout
	await knips(dir + "/brunnen_nah.png")
	kamera.drehe(180.0)
	await get_tree().create_timer(2.0).timeout
	await knips(dir + "/brunnen_nah_gegen.png")
	kamera.nach_norden()
	held.setze(Vector2i(21, 14), "UP")
	await get_tree().create_timer(2.0).timeout
	await knips(dir + "/stand_nah.png")
	kamera.nah_fern()
	for nacht in [false, true]:
		if nacht:
			licht.umschalten()
			await get_tree().create_timer(2.5).timeout
		var tag := "nacht" if nacht else "tag"
		held.setze(Vector2i(6, 8), "RIGHT")            # Strasse im Norden: frei, nichts wird durchsichtig
		laufen_will = false
		kamera.springe()
		await get_tree().create_timer(1.0).timeout
		await knips(dir + "/%s_stehen.png" % tag)
		held.richtung = Vector3(1, 0, 0)
		await get_tree().create_timer(1.0).timeout
		await knips(dir + "/%s_gehen.png" % tag)
		laufen_will = true
		for f in (20 if not nacht else 0):
			await knips(dir + "/wechsel_%02d.png" % f)
			await get_tree().create_timer(1.0 / 15.0).timeout
		await get_tree().create_timer(0.8 if nacht else 0.1).timeout
		await knips(dir + "/%s_rennen.png" % tag)
		held.richtung = Vector3.ZERO
	kamera.nah_fern()                               # nah, nachts: Fackel im Stehen, dann Rennen (ein Doppelschritt)
	held.setze(Vector2i(6, 8), "RIGHT")
	laufen_will = false
	kamera.springe()
	await get_tree().create_timer(1.0).timeout
	await knips(dir + "/nacht_nah_stehen.png")
	for nacht in [true, false]:
		if not nacht:
			licht.umschalten()
			await get_tree().create_timer(2.5).timeout
		held.setze(Vector2i(6, 8), "RIGHT")
		held.richtung = Vector3(1, 0, 0)
		laufen_will = true
		await get_tree().create_timer(1.5).timeout
		for f in 10:
			await knips(dir + "/rennen_nah_%s_%02d.png" % ["nacht" if nacht else "tag", f])
			await get_tree().create_timer(1.0 / 30.0).timeout
		held.richtung = Vector3.ZERO
	get_tree().quit()

# 348.13 Zoom-Blatt (Chef 20:24: „nicht vergessen, dass wir zoomen koennen“): --tusche=<ordner> legt je Ort und Sonnenstand
# ein Bild in der Nahstufe, der Grundansicht und ganz herausgezoomt ab (Kamera.kneifen: FERN * 1,6)
func tusche_blatt() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--tusche="): dir = a.substr(9)
	if dir == "": return
	DirAccess.make_dir_recursive_absolute(dir)
	ui.mess.visible = false
	ui.oben.visible = false
	ui.leiste.visible = false   # 399.1: Vergleichsbilder ohne Leiste
	if "--ohneheld" in OS.get_cmdline_user_args(): held.visible = false   # Maske des Helden: Bild mit minus ohne
	for st in [[Licht.Stand.MORGEN, "morgen"], [Licht.Stand.MITTAG, "mittag"], [Licht.Stand.ABEND, "abend"]]:
		licht.setze_stand(st[0])
		for o in [[Vector2i(31, 22), "kirche"], [Vector2i(19, 13), "markt"], [Vector2i(10, 17), "gras"]]:
			held.setze(o[0], "DOWN")
			for z in [[Kamera.NAH, "nah"], [Kamera.FERN, "grund"], [Kamera.FERN * 1.6, "weit"]]:
				kamera.zoom = z[0]
				kamera.nah = z[0] < (Kamera.NAH + Kamera.FERN) * 0.5
				kamera.springe()
				await get_tree().create_timer(0.6).timeout
				await knips(dir + "/%s_%s_%s.png" % [o[1], st[1], z[1]])
	get_tree().quit()

# 376 Probehaus (dorf.py PROBEHAUS=3,12): --probe=<ordner> legt das Haus 3/12 und das Nachbarhaus 3/18 in der Grundansicht
# bei Mittag, Abend und Nacht ab, dazu herausgezoomt und nah vor der Tuer (Vergleich mit einem Lauf ohne PROBEHAUS)
func probe_blatt() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--probe="): dir = a.substr(8)
	if dir == "": return
	DirAccess.make_dir_recursive_absolute(dir)
	ui.mess.visible = false
	ui.oben.visible = false
	ui.leiste.visible = false   # 399.1: Vergleichsbilder ohne Leiste
	held.setze(Vector2i(7, 16), "UP")
	for st in [[Licht.Stand.MITTAG, "mittag"], [Licht.Stand.ABEND, "abend"]]:
		licht.setze_stand(st[0])
		for z in [[Kamera.FERN, "grund"], [Kamera.FERN * 1.6, "weit"]]:
			kamera.zoom = z[0]
			kamera.nah = false
			kamera.springe()
			await get_tree().create_timer(1.0).timeout
			await knips(dir + "/%s_%s.png" % [st[1], z[1]])
	licht.setze_stand(Licht.Stand.MITTAG)
	kamera.zoom = Kamera.FERN
	kamera.springe()
	licht.umschalten()
	await get_tree().create_timer(2.5).timeout
	await knips(dir + "/nacht_grund.png")
	licht.umschalten()
	await get_tree().create_timer(2.5).timeout
	for dk in [[90, Vector2i(7, 11)], [180, Vector2i(3, 11)], [270, Vector2i(3, 15)]]:   # Chef 27.10., 19:38: Seiten und Rueckseite (Fenster), gedreht; Held auf der Kameraseite, sonst wird das Haus durchsichtig
		var d: int = dk[0]
		held.setze(dk[1], "DOWN")
		kamera.gieren_ziel = Kamera.NORD + d
		kamera.springe()
		await get_tree().create_timer(1.0).timeout
		await knips(dir + "/mittag_dreh%d.png" % d)
	kamera.nach_norden()
	held.setze(Vector2i(5, 15), "DOWN")
	kamera.zoom = Kamera.NAH
	kamera.nah = true
	kamera.springe()
	await get_tree().create_timer(1.0).timeout
	await knips(dir + "/mittag_nah.png")
	get_tree().quit()

# 348.6 Haeuser mit Innenraum (dorf.py KITHAUS): --haeuser=<ordner>:<name>,c0,r0,c1,r1,tuer;... legt je Haus die Grundansicht
# bei Mittag, Abend und Nacht ab, gedreht 90/180/270 (Held auf der Kameraseite) und nah vor der Tuer
func haeuser_blatt() -> void:
	var arg := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--haeuser="): arg = a.substr(10)
	if arg == "": return
	var dir := arg.get_slice(":", 0)
	DirAccess.make_dir_recursive_absolute(dir)
	ui.mess.visible = false
	ui.oben.visible = false
	ui.leiste.visible = false   # 399.1: Vergleichsbilder ohne Leiste
	for hs in arg.get_slice(":", 1).split(";"):
		var f := hs.split(",")
		var n := f[0]
		var c0 := int(f[1]); var r0 := int(f[2]); var c1 := int(f[3]); var r1 := int(f[4]); var tuer := int(f[5])
		kamera.nach_norden()
		kamera.zoom = Kamera.FERN
		kamera.nah = false
		held.setze(Vector2i(c1 + 1, r1 + 2), "UP")
		for st in [[Licht.Stand.MITTAG, "mittag"], [Licht.Stand.ABEND, "abend"]]:
			licht.setze_stand(st[0])
			kamera.springe()
			await get_tree().create_timer(1.0).timeout
			await knips(dir + "/%s_%s_grund.png" % [n, st[1]])
		licht.setze_stand(Licht.Stand.MITTAG)
		licht.umschalten()
		await get_tree().create_timer(2.5).timeout
		await knips(dir + "/%s_nacht_grund.png" % n)
		licht.umschalten()
		await get_tree().create_timer(2.5).timeout
		for dk in [[90, Vector2i(c1 + 1, r0 - 1)], [180, Vector2i(c0, r0 - 1)], [270, Vector2i(c0, r1 + 1)]]:
			var d: int = dk[0]
			held.setze(dk[1], "DOWN")
			kamera.gieren_ziel = Kamera.NORD + d
			kamera.springe()
			await get_tree().create_timer(1.0).timeout
			await knips(dir + "/%s_mittag_dreh%d.png" % [n, d])
		kamera.nach_norden()
		held.setze(Vector2i(tuer, r1 + 1), "DOWN")
		kamera.zoom = Kamera.NAH
		kamera.nah = true
		kamera.springe()
		await get_tree().create_timer(1.0).timeout
		await knips(dir + "/%s_mittag_nah.png" % n)
	get_tree().quit()

# 348.6 Dorftiere (Chefrunde 28.10., 08:09): --dorftiere=<ordner> legt die Grundansicht an jedem Ort der Tiere ab (Wiese suedlich
# des Flusses mit Rind, Ziegen, Huehnern; Heuballen im Westen; Kaninchen am Waldrand), nah bei den Huehnern, nachts;
# --dorftierfilm (mit --write-movie) zeigt sie in Bewegung: Wiese, Huehner nah, Westen, je einige Sekunden
# Pruefung 09:04: der Held stand fuer „huehner_nah“ auf dem Platz eines Huhns (Huhn im Stiefel)
const TIERORTE := [[Vector2i(29, 28), "wiese", false], [Vector2i(31, 28), "huehner_nah", true], [Vector2i(13, 28), "west", false],
	[Vector2i(29, 23), "kaninchen_ufer", false], [Vector2i(4, 24), "kaninchen_west", false]]

func dorftiere_blatt() -> void:
	var dir := ""
	var film := false
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--dorftiere="): dir = a.substr(12)
		if a == "--dorftierfilm": film = true
	if dir == "" and not film: return
	if dir != "": DirAccess.make_dir_recursive_absolute(dir)
	ui.mess.visible = false
	ui.oben.visible = false
	ui.leiste.visible = false   # 399.1: Vergleichsbilder ohne Leiste
	for l in leute.get_children():
		if l.daten.has("tier"):
			print("DORFTIERE %s %s %s Fell %s Gang %.2f m/s Leib %.2f m Bewegungen %s" % [l.daten["id"], l.kachel, l.daten["tier"], l.daten["fell"], l.gang, l.leib, l.anim.get_animation_list() if l.anim else []])
	var orte: Array = TIERORTE if not film else [TIERORTE[0], TIERORTE[1], TIERORTE[2]]
	for o in orte:
		held.setze(o[0], "UP")
		kamera.zoom = Kamera.NAH if o[2] else Kamera.FERN
		kamera.nah = o[2]
		kamera.springe()
		await get_tree().create_timer(6.0 if film else 3.0).timeout
		if not film: await knips(dir + "/%s.png" % o[1])
	if not film:
		held.setze(TIERORTE[0][0], "UP")
		kamera.zoom = Kamera.FERN
		kamera.nah = false
		kamera.springe()
		licht.umschalten()
		await get_tree().create_timer(2.5).timeout
		await knips(dir + "/wiese_nacht.png")
	get_tree().quit()

# 348.13b (Chef 28.10., 08:09: Tusche nach Fackel, Feuer, Fenster; Dorf zuerst, Kosten messen): --tuschenacht=<ordner> legt nachts
# an Laterne, Gasthausfenster und auf freier Wiese (nur die Fackel) je ein Bild mit und ohne Lichter in der Tusche ab, im selben
# Augenblick (Welt angehalten), und misst die Zeit der Grafik je Bild (Mittel ueber 90 Bilder, an und aus abwechselnd)
func tusche_nacht() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--tuschenacht="): dir = a.substr(14)
	if dir == "": return
	held.fackel_neu(true, false)   # 399.1: Probe wie bisher mit Fackel (im Spiel nur in der Nebenhand)
	DirAccess.make_dir_recursive_absolute(dir)
	ui.mess.visible = false
	ui.oben.visible = false
	ui.leiste.visible = false   # 399.1: Vergleichsbilder ohne Leiste
	licht.umschalten()
	await get_tree().create_timer(2.5).timeout
	var vp := get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
	var orte := [[Vector2i(6, 7), "gasthaus"], [Vector2i(10, 17), "wiese"]]
	for o in gebiet.lampen.slice(0, 2):   # Laternen: Held eine Kachel suedoestlich
		orte.append([karte.pos_kachel(o.global_position) + Vector2i(1, 1), "laterne%d" % orte.size()])
	for o in orte:
		held.setze(o[0], "UP")
		kamera.springe()
		await get_tree().create_timer(1.5).timeout
		var zeit := {true: [], false: []}
		for i in 240:   # je 60 Bilder an, aus, an, aus; die ersten 5 je Block zaehlen nicht (Messung haengt ein Bild nach)
			kamera.lampen_an = (i / 60) % 2 == 0
			await RenderingServer.frame_post_draw
			if i % 60 >= 5: zeit[kamera.lampen_an].append(RenderingServer.viewport_get_measured_render_time_gpu(vp) + RenderingServer.viewport_get_measured_render_time_cpu(vp))
		get_tree().paused = true
		for an in [true, false]:
			kamera.lampen_an = an
			kamera.tusche_lampen()
			await knips(dir + "/%s_%s.png" % [o[1], "an" if an else "aus"])
		get_tree().paused = false
		kamera.lampen_an = true
		var mittel := func(l: Array) -> float: return l.reduce(func(s, x): return s + x, 0.0) / maxf(l.size(), 1)
		print("KOSTEN %s an %.2f ms aus %.2f ms Lichter %d" % [o[1], mittel.call(zeit[true]), mittel.call(zeit[false]),
			get_tree().get_nodes_in_group("tuschelicht").filter(func(n): return n.is_visible_in_tree()).size()])
	get_tree().quit()

func knips(p: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(p)
	print("ZEICHNEN ", RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME), " Aufrufe ", RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME), " Dreiecke")
	if leute: print("LEUTE ", leute.get_children().map(func(l): return "%s %s %s" % [l.daten["id"], l.kachel, l.anim.current_animation if l.anim else "-"]))
	print("BILD ", p, " Held ", held.kachel, " ", held.position, " Kamera ", kamera.position, " Text ", ui.textfeld.visible, " '", ui.text.text, "' Knopf ", ui.aktion_knopf.visible, " ", ui.aktion_knopf.zeichen, " '", ui.ort_schild.text, "' durchsichtig ", gebiet.gruppen.keys().filter(func(k): return gebiet.gruppen[k]["a"] < 1.0))

# 390 (Rast) am Rechner: --rastprobe oeffnet das Feuer und die Theke, waehlt und schreibt den Stand je Schritt (ohne Bild);
# Ende mit quit. Gegenprobe der Regeln: tests/rast_test.gd
func rast_probe() -> void:
	if not "--rastprobe" in OS.get_cmdline_user_args(): return
	await get_tree().create_timer(0.5).timeout
	var h := held_werte()
	var log := func(was: String) -> void:
		var knoepfe := ui.wahl_box.get_children().filter(func(c): return c is Button).map(func(b): return "%s%s" % [b.text, "" if not b.disabled else " (aus)"])
		print("RASTPROBE %s | Feld %s %s | Text %s '%s' | Tag %d %02d:%02d | TP %d/%d | Gold %d | Met %d | Nacht %s | Laden '%s' %s" % [was, ui.waehlt(), knoepfe,
			ui.spricht(), ui.text.text, zustand.tag, zustand.minuten / 60, zustand.minuten % 60, h.tp, h.max_tp(), zustand.gold, zustand.met, licht.ziel > 0.5,
			laden_notiz, zustand.taschen])
	h.tp = 1
	zustand.minuten = 20 * 60
	oeffne_rast("feuer")
	log.call("Feuer offen")
	ui.gewaehlt.emit("kurz")
	await get_tree().create_timer(3.0).timeout
	log.call("nach kurz")
	ui.naechste()
	log.call("Zeile weg")
	oeffne_rast("feuer")
	ui.gewaehlt.emit("lang")
	await get_tree().create_timer(3.0).timeout
	log.call("nach lang")
	ui.naechste()
	oeffne_rast("feuer")
	log.call("Feuer wieder")
	ui.gewaehlt.emit("")
	log.call("Weiter")
	zustand.gold = 12
	spiele([{"art": "schenke"}, {"art": "sagen", "text": {"de": "Nach der Theke.", "en": "After the counter."}}])
	log.call("Theke")
	for i in 5: ui.gewaehlt.emit("met")
	log.call("fuenf Met")
	ui.gewaehlt.emit("lang")
	await get_tree().create_timer(3.0).timeout
	log.call("Zimmer heute")
	ui.gewaehlt.emit("")
	log.call("Theke zu")
	ui.naechste()
	zustand.gold = 60
	zustand.dazu("herbs", 3)
	spiele([{"art": "laden", "waren": ["potion", "remedy"], "brauen": true}, {"art": "sagen", "text": {"de": "Nach dem Laden.", "en": "After the shop."}}])
	log.call("Laden")
	ui.gewaehlt.emit("kauf:potion")
	log.call("Menge Heiltrank")
	ui.gewaehlt.emit("m:+")
	ui.gewaehlt.emit("m:ok")
	log.call("zwei Heiltraenke gekauft")
	ui.gewaehlt.emit("verk:herbs")
	ui.gewaehlt.emit("m:ok")
	log.call("Kraut verkauft")
	ui.gewaehlt.emit("zur:0")
	log.call("zurueck")
	ui.gewaehlt.emit("brau:0")
	log.call("gebraut")
	ui.gewaehlt.emit("")
	log.call("Laden zu")
	ui.naechste()
	zustand.gold = 200
	spiele([{"art": "laden", "waren": ["potion"]}])
	log.call("Thessa")
	ui.gewaehlt.emit("ag:-1")
	log.call("Ausruestung gekauft")
	ui.gewaehlt.emit("vg:0")
	log.call("Ausruestung verkauft")
	ui.gewaehlt.emit("")
	log.call("Thessa zu")
	get_tree().quit()
