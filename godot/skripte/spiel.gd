extends Node3D
# 348.6: Chroniken von Bornim in Godot, Fundament: Gebietskarte aus core (karten.json) und Blender, Held, Steuerung,
# Kamera, Licht, Tusche; Ausgaenge wie im alten Spiel: Tuer mit dem Aktionsknopf (215), gesperrte Wege mit ihrem Text.
# Grundrisse folgen nach der Bestandsliste (348.8); bis dahin zeigt eine Tuer den Namen des Grundrisses und fuehrt zurueck.
# Am Rechner: godot --path godot -- --bilder=<ordner> legt Standbilder ab (Vergleich alt/neu) und beendet sich.

const START := "village"
const START_KACHEL := Vector2i(19, 13)          # Dorfplatz am Brunnen (Probe Build 11)

var karte: Karte
# 834 (Spike): Held aus „Erschaffung BRS“ im Testmenue; nach dem Neuladen der Szene beginnt mit ihm ein neues Spiel ohne Hauptmenue
static var neu_brs := {}
var gebiet: Gebiet
var held: Held
var leute: Node3D                                # 348.6 Leute der Karte (leute.gd)
var kamera: Kamera
var licht: Licht
var ui: Steuerung
var blende: ColorRect
var zeiten: Array = []
var ziel_stoss := Vector2i(-1, -1)               # angetippter gesperrter Ausgang: beim Ankommen Text zeigen
var zustand := Zustand.new()                     # 390: Flaggen, Taschen, Gold (GameState)
var szene: Array = []                            # 390: Befehle, die noch laufen (Game.queue)
var ziel_person: Leute                           # 390: angetippte Person: beim Ankommen ansprechen
var angebot_uhr := 0.0                           # 390: Knopf neu, wenn Leute herankommen oder gehen
var werte: BrsHeld                               # 870.4: der Held nach BRS (Leben, Mana, Ausruestung, Stufe), einzige Quelle seiner Werte
var rast_ort := ""                               # 390 (Mode.Rest): Feld offen an "feuer", "schenke" oder "zimmer"
var rast_notiz := ""
var rast_zweites := false
var laden: Laden                                 # 390 (Mode.Shop): offen, bis „Schließen“
var laden_schirm: LadenSchirm                    # 416.3
var laufen_will := false                        # 399.1 Ring oder Renntaste (Stamina.step run)
var brett_offen := false
var brett_schirm: BrettSchirm                    # 416.3
var rufe := {}                                   # 399.1 Ruf: Person -> seit wann (ms) sie ruft, -1 = bemerkt, nichts Neues
var rufe_karte := ""
var naechster_ruf := 0                           # 134.3 Game.nextCallAt: vorher ruft kein anderer
var spricht_mit := ""                            # bis das Gespraech vorbei ist, dann gilt gehoert (Game.talkingTo)                        # 399.1 Anschlagbrett (Mode.Board)
var herde: Herde                                 # 490 Monster auf der Karte (herde.gd, streuner.gd)
var im_kampf := false                            # 490: vom Angriff bis zurueck auf der Karte
var kraut_tag := -1                              # 490 Heilkraeuter: fuer welchen Tag sie stehen (Game.herbDay)

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
	ui.leiste.karte.connect(func(): oeffne_menue("karte"))   # 528 (86.2)
	ui.gelesen.connect(weiter)
	ui.gewaehlt.connect(_rast_wahl)
	licht.nacht_geaendert.connect(_nacht)
	Leute.uhr = func(): return zustand.minuten   # 390 Tagesablauf
	Rand.beim_start = Rand.oben(get_viewport())
	add_child(Rand.band(Rand.beim_start))   # 399.4: schwarz, was die Kamera des Handys verdeckt
	# 399: Hauptmenue und Erschaffung zuerst, ausser bei Probelaeufen am Rechner (--bilder, --figuren …, Tests ohne Fenster)
	if not neu_brs.is_empty():   # 834: neues Spiel mit dem Helden aus „Erschaffung BRS“ (Testmenue), wie aus dem Hauptmenue
		var nw: Dictionary = neu_brs
		neu_brs = {}
		add_child(Helligkeit.schicht())
		starte(nw)
		return
	# 1021 (Chef 12.11., 08:09): hat Android das Spiel im Hintergrund beendet, gleich im Spielstand weiter, ohne Vorspann und Hauptmenue
	var fp := Fortsetzen.offen() if OS.get_cmdline_user_args().is_empty() and DisplayServer.get_name() != "headless" else 0
	if fp > 0:
		Fortsetzen.vergiss()
		add_child(Helligkeit.schicht())
		starte({"platz": fp, "laden": true})
		return
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
	staub_bild()
	pruefliste_bild()
	gang_film()
	leute_blatt()
	held_film()
	gehen_499()
	tusche_blatt()
	probe_blatt()
	haeuser_blatt()
	dorftiere_blatt()
	tusche_nacht()
	wende_film()
	rast_probe()
	raeume_bilder()
	wald_bilder()
	tiefwald_bilder()
	gluehen_bilder()
	robe_bilder()
	if FigurenProbe.an(): add_child(FigurenProbe.new(self))   # 376.1 Probeblatt Quaternius-Figuren (figurenprobe.gd)

# 399: Spielbeginn aus dem Hauptmenue: geladen an den gespeicherten Ort, sonst ein neues Spiel mit frischem Zustand (Test 139: das neue
# Spiel begann dort, wo das vorige stand; seit 3b17961e9 nach der Ankunft im Bett der Schenke). Eigene Funktion fuer tests/neues_spiel_399.gd
func starte(w: Dictionary) -> void:
	Spielstand.platz = maxi(1, int(w.get("platz", 1)))   # 399.1: vier Plaetze wie alt; gespeichert wird in diesen
	var stand := Spielstand.lade(Spielstand.platz) if w.get("laden", false) else {}
	Herde.neues_spiel()   # 490: Game.herds gehoeren zum laufenden Spiel
	if not stand.is_empty():
		zustand = Zustand.aus_daten(stand["zustand"])
		werte = BrsHeld.aus_spiel_daten(stand["held"])   # 870.4
		stufe_abgleichen()
		var o: Dictionary = stand["ort"]
		blende.color.a = 1.0
		klang("verhuelle", [true])
		betrete(String(o["karte"]), Vector2i(int(o["x"]), int(o["y"])), String(o["blick"]))
		ortsworte("", false)   # 24.1 Spielbeginn: Name und Satz
		return
	zustand = Zustand.new()   # nichts vom vorigen Spiel: Flaggen, Gold, Taschen, Ort
	zustand.name = String(w.get("name", zustand.name))
	zustand.aussehen = (w.get("aussehen", {}) as Dictionary).duplicate()   # 376.1
	# 470, 870.4: der Held nach BRS (Erschaffung 1.1) mit der Startausruestung seiner Herkunft (werte.json „welt“ „start“)
	zustand.brs = (w.get("brs", {}) as Dictionary).duplicate(true)
	werte = BrsHeld.aus_daten(zustand.brs) if not zustand.brs.is_empty() else BrsHeld.neu()
	if zustand.brs.is_empty(): zustand.brs = werte.als_daten()
	werte.name = zustand.name
	werte.ausstatten(zustand.neue_uid)
	startvorrat(zustand)
	stufe_abgleichen()
	werte.voll()
	# 399.1 wie alt (69, GameViewModel.newGame): einmal die Ankunft bei Nacht, dann erwacht der Held neben dem Bett der Schenke
	# (Story.START), wo Rowena ihn weckt; vorher begann das neue Spiel am Brunnen
	# 1020.1 A (Chef 12.11., 07:55: „das 50. Mal die Intro-Szene überspringen“): Schnellstart im Testmodus ohne Intro, schon erwacht
	if w.get("schnell", false): zustand.setze(Geschichte.INTRO_DONE)
	else: await zwischenbild("intro")
	blende.color.a = 1.0
	klang("verhuelle", [true])
	betrete(String(Rast.START["karte"]), Vector2i(int(Rast.START["x"]), int(Rast.START["y"])), String(Rast.START["blick"]))
	ortsworte("", true)   # 24.1 Spielbeginn: Name und Satz

## 555 (Chef 04.11., 17:20, t257 D: Testmenue „Zeit auf 1 Uhr nachts … Es ist aber taghell“; 17:22: „da es nie Nacht wird“): das
## Licht folgte nur der Rast und dem Schalter Tag/Nacht, nie der Uhr. Jetzt wie alt (Game.daylight): 7-19 Uhr Tag, 19-21 Uhr
## Daemmerung, 21-5 Uhr Nacht, 5-7 Uhr Morgen; licht.nacht = 1 - Tageslicht. Nur wenn sich der Wert der Uhr aendert (Minute ueber
## die Daemmerung, Uhr vorgestellt, Rast), sonst bleibt, was ein Schalter gesetzt hat; Bildlaeufe (Argumente) stellen ihr Licht selbst
static func tageslicht(m: int) -> float:
	if m >= 7 * 60 and m < 19 * 60: return 1.0
	if m >= 19 * 60 and m < 21 * 60: return 1.0 - (m - 19 * 60) / 120.0
	if m >= 5 * 60 and m < 7 * 60: return (m - 5 * 60) / 120.0
	return 0.0
var uhr_nacht := -1.0
func licht_nach_uhr(sofort := false) -> void:
	if OS.get_cmdline_user_args().size() > 0 or zustand == null: return
	var k := 1.0 - tageslicht(zustand.minuten)
	if absf(k - uhr_nacht) < 0.001 and not sofort: return
	uhr_nacht = k
	licht.ziel = k
	if sofort: licht.stelle(k)

func betrete(id: String, t: Vector2i, blick: String) -> void:
	var t0 := Time.get_ticks_usec()   # 399.1 Gerät: Ladezeit je Ort
	if gebiet: gebiet.queue_free()
	if held: held.queue_free()
	if leute: leute.queue_free()
	if herde: herde.queue_free()
	herde = null
	karte = Karte.lade(id, zustand.flaggen)   # 390: Schlagbaum, Tor, Ausgaenge und Wege lesen den Spielstand
	zustand.setze("besucht:" + id)   # 399.1 Chronik „Die Blutzahnhöhle“ (alt GameState.explored)
	licht.innen = String(karte.daten.get("art", "")) == "INTERIOR"   # 399.1 Grundriss
	for m in kamera.tusche_mats: m.set_shader_parameter("relativ", 1.0 if licht.innen else 0.0)   # 399.5: Tusche nie heller als die Flaeche
	licht.herd = "".join(karte.zeilen).contains("Z")   # 399.5 wie alt hasHearth
	licht.stelle(licht.nacht)
	licht_nach_uhr(true)   # 555: auch nach dem Laden eines Spielstands um Mitternacht gleich Nacht
	gebiet = Gebiet.new(karte)
	add_child(gebiet)
	held = Held.new(karte, HeldFigur.wahl(werte, zustand))   # 376.1 Klasse, Aussehen, Ausruestung
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
	# 490: Monster auf der Karte und Ueberfall im hohen Gras (Encounters), Heilkraeuter auf den Blumenwiesen des Walds
	if karte.daten.has("begegnungen"):
		herde = Herde.new(karte, self)
		add_child(herde)
		herde.kampf.connect(_kampf_auf_karte)
		herde.gemeldet.connect(func(t): ui.kurz(t))
	kraut_tag = -1
	kraeuter_neu()
	sichtbar_neu()
	kamera.ziel = held
	gebiet.held = held
	gebiet.kamera = kamera
	gebiet.gras_neu()   # 804: der Held schiebt das Gras des Kits beiseite
	if gebiet.gluehwuermchen:
		gebiet.gluehwuermchen.zustand = zustand   # 514: nur in manchen Naechten
		var nb = get("nebel")   # 505 (eigener Zweig): ausser Sicht vergehen sie mit dem Nebel
		if nb: gebiet.gluehwuermchen.sicht = nb.zeigt
	kamera.springe()
	ui.ort.text = karte.name()
	klang("ort", [karte, held])   # 399.3 (Jerry): Ortsmusik, Schritte nach dem Boden
	_nacht(licht.nacht)
	_steht_auf(t)
	spiele(Geschichte.betreten(id, zustand))   # 390: MapDef.onEnter
	speichere()   # 399: wie alt beim Kartenwechsel
	Messung.geladen(id, (Time.get_ticks_usec() - t0) / 1000.0)

func speichere() -> void:
	if held and karte and not OS.get_cmdline_user_args().size():
		buche_spielzeit()
		Spielstand.speichere(zustand, held_werte(), platz())

# 529 (PlayClock.book): die Zeit seit dem letzten Buchen zur gespielten Zeit; laeuft, solange die App vorn ist (alt: Screen.PLAYING)
var spiel_seit := -1
func buche_spielzeit() -> void:
	var jetzt := Time.get_ticks_msec()
	if spiel_seit >= 0 and jetzt > spiel_seit: zustand.gespielt_ms += jetzt - spiel_seit
	spiel_seit = jetzt

func _notification(what: int) -> void:   # 399: auch beim Verlassen der App (alt: onPause)
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		speichere()
		spiel_seit = -1   # 529: im Hintergrund zaehlt nichts (alt pausePlayClock)
		# 1021: beendet Android das Spiel im Hintergrund, geht es beim naechsten Start gleich hier weiter (fortsetzen.gd)
		if what == NOTIFICATION_APPLICATION_PAUSED and held and karte and not OS.get_cmdline_user_args().size():
			Fortsetzen.merke(Spielstand.platz)
		elif what == NOTIFICATION_WM_CLOSE_REQUEST:
			Fortsetzen.vergiss()
	if what == NOTIFICATION_APPLICATION_RESUMED:
		Fortsetzen.vergiss()   # 1021: die App lief weiter, nichts fortzusetzen
		if spiel_seit < 0: spiel_seit = Time.get_ticks_msec()
	# 416.1: Android-Zurück schliesst das oberste Fenster (zurueck.gd); ohne Fenster nichts (vorher beendete es das Spiel)
	if what == NOTIFICATION_WM_GO_BACK_REQUEST: Zurueck.taste(get_tree())
	# Build 145 (Tests mit spiel.tscn brachen beim Beenden ab, „corrupted size vs. prev_size“): die statische Uhr der Leute hielt eine
	# Funktion auf dieses Spiel, Godot raeumt statische Variablen erst nach den Knoten ab; beim Verlassen des Baums loesen
	if what == NOTIFICATION_EXIT_TREE: Leute.uhr = Callable()

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
	Testmodus.tiere = da.is_empty()   # 991: Zustand am Zeichen im Testmenue

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
	if not (karte.tuer(b) or not karte.sperrt(b).is_empty() or zeichen_lesbar(b) or brett(b) or karte.zeichen(b) == "z" or kiste(b) != {}):
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
		var tresen := karte.zeichen(n) == "K"
		if tresen: n += d   # 416.7 (Navigation.route): wer hinter dem Tresen steht, wird von davor angesprochen, nicht von hinten
		if not karte.begehbar(n): continue
		var w := karte.weg(held.kachel, n)
		if w.is_empty() and n != held.kachel: continue
		var wn := w.size() - (1000 if tresen else 0)
		if wn < best_n: best_n = wn; best = n
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
	pfluecke(t)   # 490 Game.pickHerbs
	if herde and not im_kampf and not ui.spricht(): herde.betreten(t)   # 490 respawnRoamers, Ueberfall im hohen Gras

# was der Held von t aus mit dem Knopf tun kann: Ausgang unter ihm, Tuer daneben (zuerst die vor ihm), Schild daneben
func vor_ihm(t: Vector2i) -> Vector2i:
	if not karte.ausgang(t).is_empty(): return t
	var vorn := Vector2i(roundi(sin(held.rotation.y)), roundi(cos(held.rotation.y)))
	for d in [vorn] + NACHBARN:
		if karte.tuer(t + d) or zeichen_lesbar(t + d) or brett(t + d) or rast_kachel(t + d) != "" or kiste(t + d) != {} or ansehbar(t + d) or fund(t + d): return t + d
	return Vector2i(-1, -1)

# wie Navigation.actionAt: Ausgang und Tuer (auch verschlossen) ENTER, Schild READ; dazu actionPlace: wohin, wenn offen
func angebot(t: Vector2i) -> Array:
	# 390 (actionTarget): Ausgang unter dem Helden zuerst; dann Person im Faecher vor Ding, Ding vor Person ausserhalb
	if karte.ausgang(t).is_empty() and monster_vorn() != null: return ["FIGHT", ""]   # 541 Navigation.actionAt: roamerAt
	var pv := person_vorn() if karte.ausgang(t).is_empty() else [null, false]
	if pv[0] and pv[1]: return ["TALK", ""]
	var z := vor_ihm(t)
	if z.x < 0: return ["TALK", ""] if pv[0] else ["", ""]
	if zeichen_lesbar(z) or brett(z): return ["READ", ""]
	if kiste(z) != {}: return ["OPEN", ""]   # 490 Tile.CHEST (Navigation: OPEN)
	if fund(z): return ["LOOK", ""]   # 542 Jobs.findAt: Jorins Fetzen am Steinkreis
	var rk := rast_kachel(z)
	if rk != "": return ["REST" if rk in ["feuer", "zimmer"] else "LOOK", ""]
	if ansehbar(z): return ["UNLOCK" if karte.zeichen(z) == "L" else "LOOK", ""]   # 541 Navigation.actionAt
	var a := karte.ausgang(z)
	if bool(a["verschlossen"]): return ["ENTER", ""] if a.has("klopfen") else ["", ""]
	return ["ENTER", Sprache.t(Karte.namen.get(String(a["ziel"]["karte"]), ""))]

func _aktion() -> void:
	var m := monster_vorn() if karte.ausgang(held.kachel).is_empty() else null
	if m != null:   # 541 Game.interact: roamerAt -> engage
		herde.greife_an(m)
		return
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
	if fund(z):
		spiele(Auftraege.fund_bei(zustand, karte.id, karte.zeichen(z)))
		return
	if kiste(z) != {}:
		oeffne_kiste(kiste(z))
		return
	if ansehbar(z):   # 541 Game.interact: Schlagbaum, Gitter, Brunnen, Regal, Altar …
		match karte.zeichen(z):
			"z", "L": _stoesst(z)   # Game.barrier, Game.gate: dasselbe wie beim Anstossen
			_: ui.sage([{"text": Sprache.t(Geschichte.ansehen(karte.zeichen(z), z, zustand, licht.nacht > 0.5, licht.innen))}])
		return
	match rast_kachel(z):
		"feuer", "zimmer": oeffne_rast(rast_kachel(z)); return
		"hoehle": ui.sage(zeilen(variiere([{"text": Rast.FEUER_HOEHLE}]))); return
		"bett": ui.sage(zeilen(variiere([{"text": Rast.FREMDES_BETT}]))); return
	var a := karte.ausgang(z)
	if bool(a["verschlossen"]):
		var nachts := licht.ist_nacht()   # 539 Game.isNight
		if a.has("klopfen"):
			# 611 (Chef 07.11., 268.8: „Klopfen sollte deutlicher sein“): man hoert es klopfen wie alt (Game.kt 1024: Sound.KNOCK, 215.1,
			# drei Aufnahmen knock_1–3); in Godot fehlte der Klang ganz
			klang("effekt", ["knock"])
			var anders := Geschichte.klopfen(karte.id, z, zustand)   # 540: nach Kapitel 1 sagt 12/5 etwas anderes
			var gesagt: Array = [{"text": anders}] if not anders.is_empty() else variiere(a["klopfen"]["nacht" if nachts else "tag"])   # 504.1 Varianten
			ui.sage(zeilen(Geschichte.klopf_sprecher(karte.id, z, gesagt)))   # 629.1 mit dem Namen der Stimme
			zustand.setze("heard_%d_%d" % [z.x, z.y])   # 399.1 Karte: wer hier wohnt (MapPeople.heard)
		return
	if a.has("braucht") and not karte.flaggen.has(a["braucht"]):
		ui.sage(zeilen(a.get("abgewiesen", [])))
		return
	geh_hinaus(a)

func _stoesst(t: Vector2i) -> void:
	if await _schiebt(t): return
	if karte.zeichen(t) == "z" and not karte.flaggen.has("barrier_open"):
		ui.sage(zeilen(variiere([{"text": Geschichte.schlagbaum(zustand)}])))   # 540: nach dem Auftrag „Sprich mit Wache Jorin“; 504.1 Varianten
		return
	if karte.zeichen(t) == "L" and not karte.flaggen.has("gate_open"):   # 390: Game.gate
		spiele(Geschichte.gitter(zustand))
		return
	var a := karte.sperrt(t)
	if a.is_empty(): return
	if bool(a["umkehren"]):   # 540 Story.southEdge: nach dem Stand der Geschichte, gemerkt im Spielstand
		ui.sage([{"text": Sprache.t(Geschichte.suedrand(zustand)["text"])}])
	else:
		ui.sage(zeilen(a.get("abgewiesen", [])))

# 348.6 Ausweichen wie alt (Game.nudge, makeWay; 92): wer vor dem Helden steht und weicht (Leute.weicht), tritt zur Seite. Mit dem
# Steuerkreuz erst, wenn der Held weiter drueckt (alt zwei Stoesse, PUSH_BUMPS 2); auf einem getippten Weg gleich
func _schiebt(t: Vector2i) -> bool:
	var wer: Leute = null
	for l in leute.get_children():
		if l is Leute and l.weicht() and (l.kachel == t or l.ziel == t): wer = l
	if wer == null: return false
	if held.richtung.length() > 0.15:
		# Test 133.7: weiter gedrueckt heisst weiter gegen ihn; abbrechen nur, wenn losgelassen, abgewandt oder vorbei
		# Test 139.7: „gegen ihn“ heisst ungefaehr zu ihm hin (die Kamera blickt schraeg, der Joystick zeigt selten genau entlang
		# der Kacheln, der Held gleitet an ihm entlang); vorher musste der Joystick genau auf seine Kachel zeigen, so wich fast nie jemand
		await (Engine.get_main_loop() as SceneTree).create_timer(0.5).timeout
		if not is_instance_valid(wer) or not drueckt_gegen(wer): return true
	var zu := wo_ist(wer) - Vector2(held.position.x, held.position.z)
	if zu.length() < 0.05: zu = Vector2(held.richtung.x, held.richtung.z)
	var d := Vector2i(int(signf(zu.x)), 0) if absf(zu.x) >= absf(zu.y) else Vector2i(0, int(signf(zu.y)))
	if d == Vector2i.ZERO: return true
	wer.weiche(d)
	return true

# der Held drueckt noch gegen [wer]: Joystick oder Kreuz gehalten, ungefaehr zu ihm hin (bis 60 Grad daneben), und noch an ihm dran
func drueckt_gegen(wer: Leute) -> bool:
	var r := Vector2(held.richtung.x, held.richtung.z)
	var zu := wo_ist(wer) - Vector2(held.position.x, held.position.z)
	if r.length() <= 0.15 or zu.length() > wer.leib + Held.RAND + 0.5: return false
	return zu.length() < 0.05 or r.normalized().dot(zu.normalized()) > 0.5

func wo_ist(l: Leute) -> Vector2:   # ausserhalb des Baums (Proben) die Mitte ihrer Kachel
	var p := l.position if l.is_inside_tree() else held.karte.kachel_pos(l.kachel)
	return Vector2(p.x, p.z)

# 504.1 (Chef 03.11., 07:52, STORY-VARIANTEN-K1-WALD.md „Türen, Schlagbaum, Rast“): Texte, die nicht aus geschichte.gd kommen
# (Klopfen an Türen aus Story.kt, Schlagbaum aus Game.kt, Rast, Erwachen), erkennt man an Wortlaut 1; je Marke wie Skript.variante.
# Gesagtes („…“) bleibt in Anführungszeichen, Erzähltes ohne
const TEXT_MARKE := {
	"„Wer ist da? … Ich mach nicht auf. Für niemanden.“": "504.tuer.edrik",
	"„Du hast die Goblins vertrieben? … Morgen vielleicht. Heute nicht.“": "504.tuer.edrik.ende",
	"„Geh weiter. Ich hab in meinem Leben genug an fremde Türen klopfen hören.“": "504.tuer.kael",
	"Hier wohnt Gwenna. Seit ihr Mann nicht zurückkam, bleibt die Tür verschlossen.": "504.tuer.gwenna",
	"„Nicht nachts. Nicht mehr.“": "504.tuer.gwenna.nacht",
	"Das Haus von Schmied Dorran. Er ist wohl in seiner Werkstatt.": "504.tuer.dorran",
	"„Die Esse ist kalt. Komm morgen.“": "504.tuer.dorran.nacht",
	"„Pim ist nicht da. Wenn du ihn am Schlagbaum siehst, schick ihn heim.“": "504.tuer.pim",
	"„Pim schläft. Und du solltest um diese Zeit auch nicht draußen sein.“": "504.tuer.pim.nacht",
	"Der Schlagbaum ist unten. Ohne Erlaubnis des Ältesten kommst du hier nicht durch.": "504.schlagbaum",
	"Der Schlagbaum ist unten. Sprich mit Wache Jorin, damit er ihn öffnet.": "504.schlagbaum.quest",
	"Das Feuer der Goblins. Es ist viel zu gefährlich, hier in der Höhle zu rasten.": "504.rast.hoehle",
	"Ein weiches Bett.": "504.rast.bett",
	"Du erwachst an einem sicheren Ort … Der Heimweg hat Stunden gedauert.": "504.erwachen",
}
func variiere(liste: Array) -> Array:
	if liste.size() != 1 or not (liste[0].get("text") is Dictionary): return liste
	var de := String(liste[0]["text"].get("de", ""))
	var marke := String(TEXT_MARKE.get(de, ""))
	if marke == "": return liste
	var alle: Array = [[[de, String(liste[0]["text"].get("en", ""))]]] + Array((Varianten.V.get(marke, {}) as Dictionary).get("v", []))
	var i := Skript.wahl(zustand, marke, alle.size())
	var vv: Array = zustand.varianten.get(marke, [0, -1])
	zustand.varianten[marke] = [int(vv[0]) + 1, i]
	var r: Array = []
	for b in alle[i]:
		var d := String(b[0]); var e := String(b[1])
		if i > 0 and de.begins_with("„"): d = "„" + d + "“"; e = "“" + e + "”"
		var z := {"text": {"de": d, "en": e}}
		if liste[0].has("wer"): z["wer"] = liste[0]["wer"]
		r.append(z)
	return r

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
# kommt aus BrsHeld (kampf/aufruf.gd, 399.2 Jerry; 870.4).
const WALD := ["forest", "deep_forest"]
const AufrufS = preload("res://kampf/aufruf.gd")
var kampf: Node
var leiste_uhr := 0.0
var kampf_mess: Label   # 211.14: Bildrate im Kampf (Testmodus „Bildrate“ oder --messen); eigene Ebene, die Steuerung ist dann verborgen

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
## 532, 935: was der Held im Kampf trinken oder werfen kann (alt ItemKind POTION, BOMB; Battle.useItem), in dieser Folge in der
## Tasche des Kampforts
const KAMPF_TASCHE := ["potion", "greater_potion", "superior_potion", "remedy", "alchemist_fire", "holy_water"]

func kampf_im_wald(zurueck: Vector2i, gegner := "RUDEL", probe: Array = [], eroeffnung := "", nr := 0) -> String:
	# 1020.2 B: Held, Söldner, Leben, Tasche und Tageszeit des Probekampfs nach der Wahl im Reiter Test (Testmodus.probe_aufbau)
	var pa: Dictionary = {} if probe.is_empty() else Testmodus.probe_aufbau(String(probe[0]), int(probe[1]))
	var hw: BrsHeld = held_werte() if probe.is_empty() else pa["held"]
	var soeldner = null if probe.is_empty() else pa["soeldner"]
	var mars_s = load("res://regeln/mars.gd")
	mars_s.test_gegnerzug = "" if probe.is_empty() else Testmodus.probe_zug     # 1020.2 C: nur im Probekampf, nie im Spiel
	mars_s.test_ausweichen = false if probe.is_empty() else Testmodus.probe_ausweichen
	var erg := {"ende": "", "tp": {}, "lohn": {}, "rest": {}, "held": null}
	# 532 (Durchspielregel 488): die ganze Tasche in den Kampf; danach wird nur weggenommen, was verbraucht ist
	var tasche := {}
	for id in KAMPF_TASCHE:
		if zustand.anzahl(id) > 0: tasche[id] = zustand.anzahl(id)
	var aufruf := AufrufS.new()
	add_child(aufruf)
	aufruf.ende.connect(func(o, tp, lohn):
		erg["tp"] = tp; erg["lohn"] = lohn
		if aufruf.kampf and aufruf.kampf.mars:
			erg["rest"] = aufruf.kampf.mars.potions.duplicate()
			erg["held"] = aufruf.kampf.mars.find("hero")     # 532: ZP, Verbrauchtes, Zustände nach dem Kampf
			erg["rauch"] = aufruf.kampf.mars.smoke_thrown     # 494: Morwens Rauchbündel geworfen (Battle.smokeBundle nimmt es weg)
		erg["ende"] = String(o))
	held.halt(); held.richtung = Vector3.ZERO
	# die Welt ruht unsichtbar; Kamera und Umgebung des Kampforts gelten (sonst zeichnet unsere Kamera, unsere Umgebung zuerst)
	var umgebung: Array = find_children("*", "WorldEnvironment", true, false)
	var env_alt := umgebung.map(func(we): return we.environment)
	# 399.2a (Chef 14:19 „a“): Wolf mit 1–2 Jungwölfen wie im alten Spiel
	klang("verhuelle", [true])   # 402 (Jerry): unter der Blende vor dem Kampf schweigt alles; sie bringt den Klang des Kampfbeginns
	klang("spiele_szene", ["BATTLE"])   # 399.3 (Jerry): Kampfmusik wie alt (300 ms), nach der Blende
	# 399.2 (Jerry 3b9fb3116): Ausruestung als Beute nach einem Sieg wie Battle.finishWin (Loot.drops, einmal je Kampf). 644a A: in der
	# Stufe des staerksten besiegten Gegners, hoechstens Heldenstufe + 1 (statt der Gebietsstufe, 543); 633: mit Boss Bossbeute und sein
	# Einzelstueck (Beute.kampfbeute). [m]: der MARS des Kampfs (kampfort.gd _done)
	var beute := func(m) -> Array:
		var w := KotlinZufall.new(randi())
		var besiegt: Array = m.all.filter(func(f): return f.side == "FOES" and f.monster != null and not f.called_in).map(func(f): return String(f.monster.get("id", "")))
		var st: Dictionary = BrsHeld.daten()["seltenheiten"]
		return Beute.kampfbeute(hw, w, besiegt, zustand.neue_uid).map(func(g): return {"gear": g, "name": Beute.name(g), "rarity": Sprache.t(st[String(g["rarity"])]["name"])})
	var k0 := Time.get_ticks_msec()
	var lage := {"atemlos": zustand.atemlos, "satt": zustand.satt} if probe.is_empty() else {}   # 399.2 (Jerry): wie der Held kommt
	if Testmodus.ist_an(): lage["eroeffnung"] = Testmodus.eroeffnung   # 399.2 (Jerry): Eröffnung aus dem Reiter Test
	if eroeffnung != "": lage["eroeffnung"] = eroeffnung   # 490: Ueberfall, Held zuerst (Opening) vom Monster auf der Karte
	lage["blende"] = true   # 402 (Jerry): die Blende vor dem Kampf wie alt, auch im Probekampf
	if nr > 0: lage["nr"] = nr   # 494 (Prüfer 512b): im Kampf dasselbe Fell wie das Monster auf der Karte (Streuner.nr)
	if probe.is_empty(): lage["aussehen"] = zustand.aussehen   # 403 (Jerry): der Held im Kampf wie im Dorf (HeldFigur)
	if probe.is_empty(): lage["leiden"] = zustand.leiden.duplicate()   # 532 (Jerry): Zustände aus dem letzten Kampf (GameState.ailments)
	if probe.is_empty(): lage["betrunken"] = zustand.betrunken()   # 532 Metrausch wie alt (Battle.drunk): betrunken aus der Schenke in den Kampf
	if probe.is_empty(): lage["tasche"] = tasche   # 532: die ganze Tasche (aufruf.gd starte)
	else: lage["tasche"] = pa["tasche"]   # 1020.2 B: Tasche nach der Wahl im Reiter
	if probe.is_empty(): lage["rauch"] = zustand.anzahl(Geschichte.SMOKE_BUNDLE)   # 494 (Jerry, D4.1): Morwens Rauchbündel gegen Krogg
	if probe.is_empty(): lage["flaggen"] = zustand.flaggen   # 836: Hinweise einmal je Spielstand (Kampfort.flaggen, nicht kopiert)
	if probe.is_empty(): lage["brs"] = zustand.brs   # 478 (Jerry): der Held nach BRS, wenn der Kampf nach BRS rechnet (brs_kampf.gd)
	if probe.is_empty() and not zustand.fert.is_empty(): lage["brs_fert"] = zustand.fert["werte"]   # 471: was er seither geuebt hat
	# 870.5 (Jerry, lohn.gd): Lohn nach BRS aus dem Stand der Heldenstufe und dem Erfahrungstopf des Gebiets (werte.json „welt“ „gebiet“)
	if probe.is_empty(): lage["stand"] = zustand.stufe_brs()
	if probe.is_empty(): lage["gebiet"] = String(BrsHeld.welt().get("gebiet", {}).get(karte.id, ""))
	# 493 (Jerry): Kampfort im Wald nach dem, was um den Helden steht (wie alt BattleScene.spotFor); im Testmodus wählbar
	lage["platz"] = Testmodus.kampfort if Testmodus.ist_an() and Testmodus.kampfort != "" else load("res://kampf/kampfort.gd").platz_fuer(karte, held.kachel)
	var zeit := tageszeit() if probe.is_empty() or String(pa["zeit"]) == "" else String(pa["zeit"])   # 1020.2 B: Tageszeit nach Wahl
	var gestartet: bool = aufruf.starte(gegner, hw, soeldner, "wald", zeit, zustand.anzahl("potion") if probe.is_empty() else 2, -1, -1, -1, beute, lage)
	# 1020.2 B: nach dem Probekampf „Nochmal“ mit derselben Wahl (Kampfort.again_fn, wie kampf/probe.gd) und „Zurück zum Testmenü“
	if gestartet and not probe.is_empty() and aufruf.kampf != null:
		aufruf.kampf.again_fn = func(): aufruf._fertig("AGAIN")
		aufruf.kampf.zurueck_text = ["Zurück zum Testmenü", "Back to test menu"]
	if probe.is_empty(): zustand.satt = false   # 399.1: Battle.wellFed endet mit dem Kampfbeginn (der Kampfort gibt +1, 399.2)
	# 471: welche Fertigkeiten der Held im Kampf benutzt, hoert Kampfuebung mit (wie der Kampfort); gutgeschrieben am Kampfende
	var uebung: Kampfuebung = null
	if gestartet and probe.is_empty() and not zustand.fertigkeiten_stand().is_empty() and aufruf.kampf != null and aufruf.kampf.mars != null:
		uebung = Kampfuebung.new()
		var m = aufruf.kampf.mars
		var vorher: Callable = m.listener
		var daten := zustand.brs
		m.listener = func(e):
			uebung.hoere(e, m, daten)
			if vorher.is_valid(): vorher.call(e)
	if gestartet:
		for we in umgebung: we.environment = null
		visible = false; ui.visible = false
		while aufruf.kampf != null and not aufruf.kampf.is_inside_tree() and erg["ende"] == "": await get_tree().process_frame
		kampf = aufruf.kampf
		Messung.kampf_ms = Time.get_ticks_msec() - k0
		Messung.kampf_beginn("%s, %s" % [gegner, String(lage["platz"])])   # 211.14: Leistung je Kampf am Gerät
		if kampf and Bausteine806.naechster:   # 806: Testmenü „Kampf messen“, nur dieser Kampf
			Bausteine806.naechster = false
			kampf.add_child(Bausteine806.new(kampf))
		if kampf and kampf.cam: kampf.cam.make_current()
	while erg["ende"] == "": await get_tree().process_frame
	kampf = null
	if kampf_mess: kampf_mess.get_parent().visible = false
	for k in umgebung.size(): umgebung[k].environment = env_alt[k]
	kamera.make_current()
	visible = true; ui.visible = true
	if probe.is_empty():
		for id in tasche:   # 532, 935: getrunken oder geworfen (fehlt ein Ding in der Tasche des Kampfs, ist nichts verbraucht)
			var rest := int((erg["rest"] as Dictionary).get(id, tasche[id]))
			if rest < int(tasche[id]): zustand.weg(id, int(tasche[id]) - rest)
	if probe.is_empty() and bool(erg.get("rauch", false)) and zustand.anzahl(Geschichte.SMOKE_BUNDLE) > 0: zustand.weg(Geschichte.SMOKE_BUNDLE, 1)   # 494: geworfen
	var lohn: Dictionary = erg["lohn"]
	var ende := [String(erg["ende"])]
	if ende[0] == "AGAIN": return ende[0]   # 1020.2 B: die Blende bleibt schwarz, test_tat startet denselben Probekampf neu
	klang("nach_kampf", [ende[0] == "WON", karte])   # 399.3 (Jerry): Sieg mit sieg_, sonst Ortsmusik nach 10 s
	if ende[0] == "NONE" or not probe.is_empty():
		held.setze(zurueck, "DOWN"); kamera.springe(); await abblenden(0.0)
		return ende[0]
	var tp_nach := int(erg["tp"].get("hero", hw.leben))
	# 532 (Jerry, Abgleich 512; alt Battle.kt 487–489, Game.keepAilments): Mana verbraucht, Zustände bleiben; 870.4: kürzer je Zähigkeit
	var hf = erg["held"]
	if hf != null:
		hw.mana = clampi(int(hf.sp), 0, hw.max_mana())
	zustand.leiden = AufrufS.leiden_nach(hf, ende[0], maxi(0, hw.wert("zaehigkeit") - int(BrsHeld.welt().get("leiden_zaehigkeit_ab", 5))))
	if ende[0] == "LOST":
		Rast.vergeht(zustand, 4 * 60)   # Game.DEATH_HOURS
		hw.voll()   # 532: Hero.restoreFully (Leben, Mana)
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
		ui.sage(zeilen(variiere([{"text": {"de": "Du erwachst an einem sicheren Ort … Der Heimweg hat Stunden gedauert.", "en": "You wake up somewhere safe… The way home took hours."}}])))
		return ende[0]
	hw.leben = clampi(tp_nach, 1, hw.max_leben())
	if ende[0] == "WON": zustand.siege += 1   # 399.1: GameState.battlesWon (System „Siege“, Thessas Ware); zaehlte bisher nie
	grundwert_gestiegen = false   # 644a F (Homer 1026): ein Kampf ohne Uebung spielt den Aufstiegsklang des vorigen nicht noch einmal
	var gestiegen := fertigkeiten_nach_kampf(uebung, ende[0]) if uebung != null else ""   # 471
	if not lohn.is_empty():
		zustand.gold += int(lohn.get("gold", 0))
		for d in lohn.get("items", []): zustand.dazu(String(d))   # Beute (Felle, Zaehne)
		for g in lohn.get("gear", []): zustand.ausruestung_dazu(g)   # 399.2 Ausruestung aus dem Kampflohn
		# 870.5 (Jerry, lohn.gd): neuer Stand der Heldenstufe nach BRS (Grenze und weiche Grenze rechnet Brs.gib_erfahrung); Stufe hoeher heilt ganz
		if lohn.get("stand") is Dictionary and not (lohn["stand"] as Dictionary).is_empty(): zustand.brs_stufe = (lohn["stand"] as Dictionary).duplicate(true)
		stufe_abgleichen()
	held.setze(zurueck, blick_nach)
	kamera.springe()
	await abblenden(0.0)
	if gestiegen != "": ui.kurz(gestiegen)   # 471: „Bogen ↑ 12“, wenn die Welt wieder zu sehen ist
	if grundwert_gestiegen: klang("effekt", ["level_up"])   # 644a F: ein Grundwert gestiegen, gemeldet wie ein Aufstieg
	return ende[0]

# 471: Uebung aus dem Kampf gutschreiben (nur nach einem Sieg), Bewaehrungsprobe; die Erfahrung der Fertigkeiten geht in die Heldenstufe
# nach BRS (zustand.brs_stufe, Stufe wie der Held, bis 472 ihn fuehrt). Gibt die Notiz „Bogen ↑ 12“ zurueck oder leer.
# 644a F: ist dabei ein Grundwert durchs Ueben gestiegen (BrsHeld.uebungs_plus), steht er dahinter wie eine Fertigkeit
# („Gewandtheit ↑ 6“, Wert wie im Heldenreiter) und grundwert_gestiegen ist wahr (Klang wie ein Aufstieg)
var grundwert_gestiegen := false
func fertigkeiten_nach_kampf(u: Kampfuebung, ende: String) -> String:
	grundwert_gestiegen = false
	var s := zustand.fertigkeiten_stand()
	if s.is_empty(): return ""
	var vorher: Dictionary = (s.get("werte", {}) as Dictionary).duplicate()
	var ev := u.gutschreiben(ende, s, zustand.stufe_brs())
	zustand.spiegle()
	stufe_abgleichen()   # 870.4: die Erfahrung der Fertigkeiten kann die Heldenstufe heben
	var t := Kampfuebung.notiz(ev)
	var gw := grundwerte_notiz(vorher)
	grundwert_gestiegen = gw != ""
	return gw if t == "" else (t if gw == "" else t + "  ·  " + gw)

## 644a F: „Kraft ↑ 5“ je Grundwert, der seit [vorher] (Geuebtes vor dem Kampf) durchs Ueben gestiegen ist, sonst leer
func grundwerte_notiz(vorher: Dictionary) -> String:
	var hw := held_werte()
	return "  ·  ".join(hw.grundwerte_gestiegen(vorher).map(func(g): return "%s ↑ %d" % [Sprache.t(ErschaffungBrs.GRUNDWERT[String(g)]), hw.wert(String(g))]))

# ---------------------------------------------------------------- 490 Kampf mit einem Monster der Karte (Game.engage, startBattle, endBattle)
# Die Welt ruht im Kampf; danach steht der Held, wo er stand, mit seinem Blick; das Monster ist nach dem Sieg fort (herde.gd)
func _kampf_auf_karte(monster: String, eroeffnung: String, wer: Streuner) -> void:
	if im_kampf or not Streuner.GRUPPE.has(monster): return
	im_kampf = true
	held.halt(); held.richtung = Vector3.ZERO
	ziel_person = null; ziel_stoss = Vector2i(-1, -1)
	var hier := karte.id
	blick_nach = held.blick()
	var ende := await kampf_im_wald(held.kachel, String(Streuner.GRUPPE[monster]), [], eroeffnung, wer.nr if wer != null else 0)
	blick_nach = "DOWN"
	if herde and karte.id == hier: herde.nach_kampf(wer, ende)
	im_kampf = false

var blick_nach := "DOWN"   # 490: Blick nach dem Kampf (Monster der Karte: wie vorher)

# 491 Kampf aus der Geschichte (Grimmzahn: fight("dire_wolf", GRIMFANG_DEFEATED)): Gruppe wie die Monster der Karte (Streuner.GRUPPE,
# Grimmzahn mit seiner Leibwache), danach steht der Held, wo er stand; gewonnen: Flagge, wer besiegt ist, verschwindet, die Szene
# geht weiter (Grimmzahn bricht zusammen …); verloren oder geflohen: die Szene endet (Game.endBattle)
func _szenenkampf(monster: String, flagge: String) -> void:
	im_kampf = true
	held.halt(); held.richtung = Vector3.ZERO
	blick_nach = held.blick()
	var ende := await kampf_im_wald(held.kachel, String(Streuner.GRUPPE[monster]))
	blick_nach = "DOWN"
	im_kampf = false
	if ende != "WON":
		szene.clear()
		return
	if flagge != "":
		zustand.setze(flagge)
		flaggen_neu()
	sichtbar_neu()
	weiter()

# ---------------------------------------------------------------- 490 Truhen (Tile.CHEST, Game.openChest): einmal je Truhe, Inhalt aus der Karte
func kiste(t: Vector2i) -> Dictionary:
	if karte.zeichen(t) != "C": return {}
	for k in karte.daten.get("kisten", []):
		if int(k["x"]) == t.x and int(k["y"]) == t.y: return k
	return {}

# 541 Navigation.actionAt LOOK/UNLOCK: Dinge, die man untersuchen kann, der Schlagbaum, solange er zu ist, das Gitter, solange zu
func ansehbar(t: Vector2i) -> bool:
	var z := karte.zeichen(t)
	if z == "z": return not karte.flaggen.has("barrier_open")
	if z == "L": return not karte.flaggen.has("gate_open")
	return not Geschichte.ansehen(z, t, zustand, false, licht.innen).is_empty()

# 541 Game.roamerAt vor dem Helden: auf der Kachel vor ihm, sonst auf einer Nachbarkachel (wie vor_ihm)
func monster_vorn() -> Streuner:
	if herde == null or held == null: return null
	var vorn := Vector2i(roundi(sin(held.rotation.y)), roundi(cos(held.rotation.y)))
	for d in [vorn] + NACHBARN:
		var s := herde.bei(held.kachel + d)
		if s != null: return s
	return null

# 542 Jobs.findAt: am Stein t liegt etwas fuer einen angenommenen Auftrag
func fund(t: Vector2i) -> bool:
	return not Auftraege.fund_bei(zustand, karte.id, karte.zeichen(t)).is_empty()
func oeffne_kiste(k: Dictionary) -> void:
	var id := "kiste:" + String(k["id"])   # GameState.openedChests
	if Auftraege.ring_in(zustand, String(k["id"])):   # 542 Jobs.ringIn: Gwennas Ring, auch in einer schon leeren Truhe
		zustand.setze(id)
		klang("effekt", ["chest"])
		spiele([{"art": "sagen", "text": Auftraege.RING_FUND}, {"art": "geben", "ding": Auftraege.RING, "anzahl": 1}])
		return
	if zustand.has(id):
		ui.sage([{"text": Sprache.u("chestEmpty")}])
		return
	zustand.setze(id)
	klang("effekt", ["chest"])
	var bef: Array = []
	if k.has("ding"):
		var ding := String(k["ding"])
		if ding == Geschichte.CLASS_WEAPON: ding = Geschichte.truhen_waffe(held_werte().fertigkeiten_jetzt())   # 632, 870.4: nach der stärksten Fertigkeit
		bef.append({"art": "geben", "ding": ding, "anzahl": int(k.get("anzahl", 1))})
	if int(k.get("gold", 0)) > 0: bef.append({"art": "gold", "anzahl": int(k["gold"])})
	if bef.is_empty(): ui.sage([{"text": Sprache.u("chestEmpty")}])
	spiele(bef)

# ---------------------------------------------------------------- 490 Heilkraeuter (Game.herbAt, pickHerbs): auf Blumenwiesen der Wildnis,
# auf der Haelfte der Blumenkacheln, je Tag andere; wer darueber geht, pflueckt sie; sie wachsen bei Sonnenaufgang (6:30) nach
const SONNENAUFGANG := 6 * 60 + 30   # Game.SUNRISE_MIN

func kraut_heute() -> int: return zustand.tag if zustand.minuten >= SONNENAUFGANG else zustand.tag - 1

static func _i32(x: int) -> int:   # wie Kotlin Int: auf 32 Bit mit Vorzeichen
	x = x & 0xFFFFFFFF
	return x - 0x100000000 if x >= 0x80000000 else x

static func _hash_text(t: String) -> int:   # String.hashCode
	var h := 0
	for i in t.length(): h = _i32(31 * h + t.unicode_at(i))
	return h

func kraut_da(t: Vector2i) -> bool:
	if String(karte.daten.get("art", "")) != "FOREST" or karte.zeichen(t) != "f": return false
	var tag := kraut_heute()
	if int(zustand.gepflueckt.get("%s:%d:%d" % [karte.id, t.x, t.y], -999)) == tag: return false
	var h := _i32(_i32(_i32(_i32(_hash_text(karte.id) * 31) + _i32(t.x * 73856093)) + _i32(t.y * 19349663)) + _i32(tag * 83492791))
	h = _i32(h ^ ((h & 0xFFFFFFFF) >> 13)) * 0x5bd1e995
	h = _i32(h)
	h = _i32(h ^ ((h & 0xFFFFFFFF) >> 15))
	return posmod(h, 100) < 50   # Game.HERB_CHANCE

func kraeuter_neu() -> void:
	kraut_tag = kraut_heute()
	if gebiet == null: return
	var da: Array[Vector2i] = []
	if String(karte.daten.get("art", "")) == "FOREST":
		for y in karte.hoehe:
			for x in karte.breite:
				if kraut_da(Vector2i(x, y)): da.append(Vector2i(x, y))
	gebiet.zeige_kraeuter(da)

func pfluecke(t: Vector2i) -> void:
	if not kraut_da(t): return
	zustand.gepflueckt["%s:%d:%d" % [karte.id, t.x, t.y]] = kraut_heute()
	var weise := Laden.kraut_chance(held_werte())   # 870.4: Kräutersammeln (875) und Wahrnehmung (alt Perks.extraHerbChance)
	var n := 1 + (1 if randf() < 0.3 else 0) + (1 if randf() < weise else 0)
	zustand.dazu("herbs", n)
	klang("effekt", ["loot"])
	zustand.uebe("Kräutersammeln")   # 471: Pfluecken uebt Kraeutersammeln (875, 857a A)
	var auf := zustand.fert_notiz()
	ui.kurz(Sprache.t({"de": "Du pflückst Heilkräuter (+%d)." % n, "en": "You pick healing herbs (+%d)." % n}) + ("\n" + auf if auf != "" else ""))
	kraeuter_neu()

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
		if n > REICHWEITE:
			# 416.7 (Chef 31.10.: am Tresen in Schenke und Laden ging der Knopf nicht): wie actionTarget ueber den Tresen, gerade
			# hinueber; die Reichweite zaehlt bis zur Mitte der Tresenkachel
			var k := tresen_kachel(held.kachel, l.kachel)
			if k.x < 0: continue
			var kp := karte.kachel_pos(k)
			d = Vector2(kp.x - held.position.x, kp.z - held.position.z) / Karte.TS
			n = d.length()
		if n > REICHWEITE or not spricht_was(l): continue
		var f := n < 0.01 or d.normalized().dot(vorn) >= 0.5
		var w := n + (0.0 if f else 10.0)
		if w < best_w: best_w = w; best = l; best_f = f
	return [best, best_f]

func person_nah() -> Leute: return person_vorn()[0]

# 416.7: die Tresenkachel zwischen a und b, wenn b gerade zwei Kacheln hinter einem Tresen (Tile.COUNTER) liegt; sonst (-1, -1)
func tresen_kachel(a: Vector2i, b: Vector2i) -> Vector2i:
	for o in NACHBARN:
		if b - a == o * 2 and karte.zeichen(a + o) == "K": return a + o
	return Vector2i(-1, -1)

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
	l.wende_zu()   # 416.8
	ui.biete_an("")
	zustand.setze("met_" + String(l.daten["id"]))   # 399.1 Karte: wen der Held kennt (MapMarks.met, Game.talk)
	Ruf.gehoert(zustand, String(l.daten["id"]), false)   # 399.1 Hail.heard vor dem Gespraech
	spricht_mit = String(l.daten["id"])
	rufe.erase(spricht_mit)
	stufe_abgleichen()   # 538: auch nach dem Testmenue (Stufe) sprechen die Leute zur wahren Stufe
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
				if String(c["flagge"]) == Geschichte.BARRIER_OPEN: klang("effekt", ["door"])   # 636 Game.kt SetFlag: Schlagbaum auf mit Türgeräusch
				flaggen_neu()
			"variante":   # 504.1: Wortlaut gehoert (Skript.variante)
				var vm := String(c["marke"])
				var vv: Array = zustand.varianten.get(vm, [0, -1])
				zustand.varianten[vm] = [int(vv[0]) + 1, int(c["wahl"])]
			"geben":
				if String(c["ding"]).begins_with("@gear:"):   # 399.1 Game.kt Cmd.Give „@gear:RARITY:SLOT“ (Jorins Kopfschutz)
					zeige({"text": Sprache.u("found", [gear_gabe(String(c["ding"]))])})
					return
				if einzelstueck(String(c["ding"])):   # 542 Uniques.exists: Aldrics Ring als Ausruestung, nicht als Ding
					zeige({"text": Sprache.u("found", [einzel_gabe(String(c["ding"]))])})
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
			"kampf":   # 491 Cmd.Fight (Game.startBattle aus der Szene): Sieg setzt die Flagge, die Szene geht weiter; sonst endet sie
				if Streuner.GRUPPE.has(String(c["monster"])) and ResourceLoader.exists("res://kampf/kampfort.gd"):
					_szenenkampf(String(c["monster"]), String(c.get("flagge", "")))
					return
				szene.clear()
			"schenke":   # Cmd.Tavern: Rowenas Theke; die Szene geht weiter, wenn das Feld zu ist (Game.advance)
				oeffne_rast("schenke")
				return
			"kapitelende":   # 537 Cmd.ChapterEnd: der Schirm bleibt, bis „Weiter“
				kapitelende()
				return
			"tempelszene":   # 537 Cmd.TempleScene: die Bilder der Morgenandacht, bis vorbei oder uebersprungen
				tempelszene()
				return
			"morgen":   # 537 Cmd.Morning: die Nacht ist vorbei, der Held erwacht am Ort des Morgens
				morgen(c["ort"])
				return
			_:
				# Kampf (Jerry 348.7): in Kotlin wartet die Szene dort; bis er
				# gebaut ist, endet sie hier, damit nichts danach (Flaggen, Saetze) ohne das Ereignis geschieht (Pruefer)
				szene.clear()
	if spricht_mit != "" and not ui.spricht():   # Hail.heard nach dem Gespraech
		Ruf.gehoert(zustand, spricht_mit, true)
		spricht_mit = ""
	if held: _steht_auf(held.kachel)

# 542 Uniques.make: das Einzelstueck, Stufe aus dem Gegenstandskatalog (644a A, DESIGN-BRS.md 11 „Funde“; vorher maxOf(areaLevel,
# hero.level)); zurueck „Name (Seltenheit)“. 870.6: Grundform,
# Seltenheit, Guete und Zusatzeigenschaften nach dem BRS aus den Regelwerten (werte.json „gegenstaende“ „einzelstuecke“), Name aus dem
# Gegenstandskatalog (Beute.name)
static func einzelstueck(id: String) -> bool: return Beute.einzelstueck(id).has("grundform")

func einzel_gabe(id: String) -> String:
	var g := Beute.einzel(id, zustand.neue_uid(), Katalog.stufe(id))
	zustand.ausruestung_dazu(g)
	return "%s (%s)" % [Beute.name(g), Sprache.t(BrsHeld.daten()["seltenheiten"][String(g["rarity"])]["name"])]

# Loot.generate mit Mindestseltenheit (rarityFor special, floor) und Platz, Stufe wie maxOf(areaLevel, hero.level), hoechstens
# Heldenstufe + 1 (644a A, Beute.gabe_stufe)
func gear_gabe(was: String) -> String:
	var t := was.trim_prefix("@gear:").split(":")
	var hw := held_werte()
	var w := KotlinZufall.new(randi())
	var ilvl := Beute.gabe_stufe(int(karte.daten.get("stufe", 1)), hw.stufe)
	var g := Beute.erzeuge(w, zustand.neue_uid(), ilvl, Beute.seltenheit_fuer(hw, w, ilvl, true, t[0]), hw, t[1] if t.size() > 1 else "", true)   # 870.6: nach seinen Fertigkeiten, besonderer Fund
	zustand.ausruestung_dazu(g)
	return "%s (%s)" % [Beute.name(g), Sprache.t(BrsHeld.daten()["seltenheiten"][String(g["rarity"])]["name"])]

# ---------------------------------------------------------------- Anschlagbrett (399.1, BoardScreen.kt): was haengt, mit Aushang
# und Lohn, je einer „Annehmen“ (angenommen: grau); nichts: verblichene Naegel; „Zurück“ schliesst (Game.advance)
# 416.3: bildschirmfuellend wie alt (brettschirm.gd)
func oeffne_brett() -> void:
	Auftraege.lies(zustand)
	brett_offen = true
	held.halt()
	held.richtung = Vector3.ZERO
	var ebene := CanvasLayer.new()
	ebene.layer = 40
	add_child(ebene)
	brett_schirm = BrettSchirm.new(zustand)
	ebene.add_child(brett_schirm)
	brett_schirm.wahl.connect(_brett_wahl)

func _brett_wahl(id: String) -> void:
	if not brett_offen: return
	if id.begins_with("nimm:"):
		Auftraege.nimm(zustand, Auftraege.von(id.trim_prefix("nimm:")))
		speichere()
		brett_schirm.baue()
		return
	brett_offen = false
	brett_schirm.get_parent().queue_free()
	brett_schirm = null
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
				if st == "": st = Ruf.stimme(String(l.daten.get("aussehen", "")))   # 635: lyra_temple ruft wie „lyra“
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
# reiter: „karte“ vom Kartenzeichen der Leiste (528): die Karte gleich offen; der Reiter Karte noch einmal fuehrt zurueck ins Spiel
func oeffne_menue(reiter := "") -> void:
	if ui.spricht() or rast_ort != "" or laden != null or kampf != null or get_tree().paused: return
	held.halt(); held.richtung = Vector3.ZERO
	var ebene := CanvasLayer.new()
	ebene.layer = 40
	ebene.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ebene)
	var m := Menue.new(held_werte(), zustand)
	var figur_vorher := JSON.stringify(HeldFigur.wahl(held_werte(), zustand))   # 522: Ausruestung vorher
	m.ort = platz()
	m.dunkel = im_dunkeln()
	if reiter != "":
		m.reiter = reiter
		m.karte_direkt = reiter == "karte"
	ebene.add_child(m)
	m.speichern.connect(speichere)
	m.ankunft.connect(func():   # 399.1 Chronik „Die Ankunft ansehen“ (69d, vm.watchIntro)
		m.zu.emit()
		get_tree().paused = true
		await zwischenbild("intro")
		get_tree().paused = false
		klang("ort", [karte, held]))
	m.andacht.connect(func():   # 537 Chronik „Die Morgenandacht ansehen“ (68, vm.watchTemple): danach zurueck ins Spiel
		m.zu.emit()
		klang("spiele_szene", ["TEMPLE"])
		get_tree().paused = true
		await zwischenbild("tempel")
		get_tree().paused = false
		klang("ort", [karte, held]))
	m.sprache.connect(sprache_wechseln)
	m.test.connect(func(was: String, mit: Array):   # 399.1 Reiter „Test“: erst das Menue zu, dann in der Welt
		# 555 (Chef 11:52: „Wenn ich auf Kartenzoom klicke, dann bin ich sofort aus dem Testmenü draußen“): Schalter bleiben wie alt im
		# Menue, die Wirkung steht als kurze Meldung; nur Orts-, Kampf- und Schirmwechsel schliessen
		if was in ["zoom", "nacht", "tiere", "gras", "kampfeffekte", "kampfmessen"]:
			test_tat(was, [])
			var de := Sprache.aktiv() == "de"
			match was:
				"zoom": m.meldung(String(mit[0]) if mit.size() > 0 else ("Kartenzoom gestellt" if de else "Map zoom set"))
				"nacht": m.meldung(("Nacht, 23:00 Uhr" if de else "Night, 11 pm") if licht.ziel > 0.5 else ("Tag, 12:00 Uhr" if de else "Day, noon"))
				"tiere": m.meldung("Tiere umgeschaltet" if de else "Animals toggled")
				"gras": m.meldung(("Gras: Grass & Wind" if de else "Grass: Grass & Wind") if GrasBausatz.an else ("Gras: unser altes" if de else "Grass: our old one"))
				"kampfeffekte": m.meldung(("Lichtschächte an" if de else "Light shafts on") if KampfEffekte.an else ("Lichtschächte aus" if de else "Light shafts off"))
				"kampfmessen": m.meldung(("Der nächste Kampf misst jeden Baustein (etwa 40 s)" if de else "The next battle measures each part (about 40 s)") if Bausteine806.naechster else ("Kampf messen aus" if de else "Battle measuring off"))
			return
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
		held_figur_neu(figur_vorher)
		fackel_neu()
		kamera.fern_neu()
		ui.leiste.zeige(held_werte(), zustand, licht.nacht > 0.65))

# 399.1 Reiter „Test“ (Testmodus.gd) wie alt: cheatWarp, cheatChapterEnd, cheatFight, startProbe
func test_tat(was: String, mit: Array) -> void:
	match was:
		"nacht", "tiere": _knopf(was)   # 500: aus dem Testmenue statt der Probeknoepfe
		"gras":   # 804: Gras des Kits gegen unser altes, zum Vergleich und fuer die Bilder/s vorher und nachher
			GrasBausatz.an = not GrasBausatz.an
			if gebiet: gebiet.gras_neu()
		"kampfeffekte":   # 806: Lichtschächte im Kampfort, ab dem nächsten Kampf (Bodennebel seit Test 277 aus)
			KampfEffekte.an = not KampfEffekte.an
		"kampfmessen":   # 806: der nächste Kampf misst Bild-, Grafik- und Zeichenzeit je Baustein (Bausteine806)
			Bausteine806.naechster = not Bausteine806.naechster
		"lage_merken":   # 1020.1 A: die Lage jetzt in den Lageplatz (Testmodus.LAGEPLATZ), der eigene Platz bleibt
			var eigen := Spielstand.platz
			buche_spielzeit()
			Spielstand.platz = Testmodus.LAGEPLATZ
			Spielstand.speichere(zustand, held_werte(), platz())
			Spielstand.platz = eigen
			ui.kurz(Sprache.t({"de": "Lage gemerkt.", "en": "Situation saved."}))
		"lage_zurueck":   # 1020.1 A: zurück in die gemerkte Lage; gespeichert wird weiter in den eigenen Platz
			var eigen2 := Spielstand.platz
			var stand := Spielstand.lade(Testmodus.LAGEPLATZ)
			if stand.is_empty():
				ui.kurz(Sprache.t({"de": "Noch keine Lage gemerkt.", "en": "No situation saved yet."}))
				return
			await abblenden(1.0)
			var von2 := karte.id
			zustand = Zustand.aus_daten(stand["zustand"])
			werte = BrsHeld.aus_spiel_daten(stand["held"])
			stufe_abgleichen()
			var o: Dictionary = stand["ort"]
			betrete(String(o["karte"]), Vector2i(int(o["x"]), int(o["y"])), String(o["blick"]))
			Spielstand.platz = eigen2
			await ortsworte(von2, false)
			ui.kurz(Sprache.t({"de": "Gemerkte Lage.", "en": "Saved situation."}))
		"einmaliges":   # 1020.1 A: Eingebungen, Kampfhinweise und Ortssätze wie beim ersten Mal
			for f in zustand.flaggen.keys():
				if String(f).begins_with("eingebung_") or String(f).begins_with("kampf_hinweis_"): zustand.flaggen.erase(f)
			Ortsblende.besuche.clear()
			Ortsblende.letzter.clear()
			ui.kurz(Sprache.t({"de": "Eingebungen, Kampfhinweise und Ortssätze wie beim ersten Mal.", "en": "Insights, fight hints and place lines as the first time."}))
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
		"station":   # 555: an eine Station von Kapitel 1 mit dem Stand, den ein Spieler dort hat (Testmodus.STATIONEN)
			var ziel := Testmodus.station(String(mit[0]), zustand)
			if ziel.is_empty(): return
			await abblenden(1.0)
			var von := karte.id
			betrete(String(ziel[0]), ziel[1], String(ziel[2]))
			await ortsworte(von, false)
			ui.kurz(String(ziel[3]))
		"ort_neu":   # 555: Merker, Bosse, Truhen, Kraeuter geaendert: der Ort neu aus dem Stand, der Held bleibt, wo er steht
			await abblenden(1.0)
			betrete(karte.id, held.kachel, held.blick())
			await ortsworte(karte.id, false)
			if mit.size() > 0: ui.kurz(String(mit[0]))
		"holen":   # 555 wie alt cheatBring: ein Monster neben den Helden, 2 Minuten friedlich; auch wo sonst keine streifen
			if herde == null:
				herde = Herde.new(karte, self)
				add_child(herde)
				herde.kampf.connect(_kampf_auf_karte)
				herde.gemeldet.connect(func(t): ui.kurz(t))
			var de := Sprache.aktiv() == "de"
			ui.kurz(("In der Nähe, 2 Minuten friedlich." if de else "Nearby, peaceful for 2 minutes.") if herde.hole(String(mit[0])) else ("Hier ist kein Platz." if de else "No room here."))
		"zoom":   # 555 Kartenzoom wie alt: gleich sichtbar, auch nach Kneifen
			kamera.fern_neu()
			kamera.nah = false
			kamera.zoom = kamera.fern
			if mit.size() > 0: ui.kurz(String(mit[0]))
		"strahlen":   # 415 (Jerry): Strahlenprobe im Kampfort (kampf/strahlprobe.gd); dort lädt „Zurück“ das Spiel neu
			speichere()
			var s = load("res://kampf/strahlprobe.gd").new()
			get_tree().root.add_child(s)
			get_tree().current_scene.queue_free()
			get_tree().current_scene = s
		"erschaffung_brs":   # 470a B; 834 (Spike, Chef 10.11., 10:21): „Abenteuer beginnen“ speichert das laufende Spiel und beginnt ein neues
			# mit dem Helden nach BRS (zustand.brs) im freien oder gewaehlten Platz
			var ebene := CanvasLayer.new()
			ebene.layer = 40
			ebene.process_mode = Node.PROCESS_MODE_ALWAYS
			add_child(ebene)
			var e := ErschaffungBrs.new()
			e.ziel = 0   # 834: erster freier Platz, sind alle belegt, die Platzwahl (795)
			ebene.add_child(e)
			get_tree().paused = true
			var weg := func():
				ebene.queue_free()
				get_tree().paused = false
			e.zurueck.connect(weg)
			e.fertig.connect(func(w):
				weg.call()
				speichere()
				neu_brs = w
				get_tree().reload_current_scene())
		"kampf", "probe":
			if not ResourceLoader.exists("res://kampf/kampfort.gd"): return
			await abblenden(1.0)
			var ende := await kampf_im_wald(held.kachel, String(mit[0]), [] if was == "kampf" else [String(mit[1]), int(mit[2])])
			while ende == "AGAIN" and was == "probe":   # 1020.2 B: „Nochmal“ mit derselben Wahl
				ende = await kampf_im_wald(held.kachel, String(mit[0]), [String(mit[1]), int(mit[2])])
			# 1020.2 B: aus dem Reiter gestartet, führt „Zurück zum Testmenü“ dorthin (Tests rufen ohne das vierte Feld)
			if was == "probe" and mit.size() > 3 and bool(mit[3]) and ende != "NONE": oeffne_menue("test")

# 399.1 Schwarzblende mit Worten wie alt (Ortsblende, 24.1): auf der stehenden Blende Name und Satz, dann steigt der Ort auf;
# [von] leer beim Spielbeginn, [erster] beim ersten Besuch. Ohne daten/intro.json wie bisher nur die Blende
func ortsworte(von: String, erster: bool) -> void:
	if not Zwischenbild.da():
		await abblenden(0.0)
		return
	var a := Ortsblende.art_fuer(von, karte.id, erster)
	Ortsblende.merke(karte.id)
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
# ---------------------------------------------------------------- Kapitelende (537, Game.kt Cmd.ChapterEnd, TempleScene, Morning)

# Mode.ChapterEnd (ChapterEndScreen): schwarz bis „Weiter“, dann speichern (vm.save) und weiter (Game.advance); Musik CHAPTER_END
# (App.kt). Die Welt dahinter wird schon schwarz, damit nach Schirm und Tempelszene der Morgen aus dem Schwarz aufsteigt.
func kapitelende() -> void:
	held.halt(); held.richtung = Vector3.ZERO
	blende.color.a = 1.0
	klang("spiele_szene", ["CHAPTER_END"])
	var ebene := CanvasLayer.new()
	ebene.layer = 40
	ebene.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ebene)
	var s := KapitelSchirm.new(held_werte(), Geschichte.CHAPTER_END_TEXT)
	ebene.add_child(s)
	get_tree().paused = true
	await s.weiter
	get_tree().paused = false
	ebene.queue_free()
	speichere()
	weiter()

# Mode.TempleScene (TempleSceneScreen, 68): die Bilder der Morgenandacht ueber dieselbe Uhr wie das Intro, Musik TEMPLE (App.kt);
# vorbei oder uebersprungen: weiter (vm.endTemple)
func tempelszene() -> void:
	klang("spiele_szene", ["TEMPLE"])
	get_tree().paused = true
	await zwischenbild("tempel")
	get_tree().paused = false
	weiter()

# Cmd.Morning: die Nacht zaehlt als Rast (68g): ganz geheilt, Rast vorbei, die Uhr bei Sonnenaufgang des naechsten Tages, der Held
# dort, wo ihn der Morgen findet (auch Wiederkehrort), lange Rast fuer heute verbraucht; brannte der Funke, ist die erste Zeile
# nach dem Erwachen, dass er erloschen ist (84.5). Was die Szene danach sagt (Lyra), kommt erst, wenn der Ort aufgeblendet ist.
func morgen(ort: Dictionary) -> void:
	Rast.heilen(zustand, held_werte())
	var funkte := zustand.funke
	Rast.endet(zustand)
	if zustand.minuten >= SONNENAUFGANG: zustand.tag += 1
	zustand.minuten = SONNENAUFGANG
	zustand.wiederkehr = ort.duplicate()
	zustand.lange_rast_tag = zustand.tag
	var rest := szene.duplicate()
	szene.clear()
	if funkte: rest.push_front({"art": "sagen", "text": Sprache.r("sparkFaded")})
	klang("verhuelle", [true])
	blende.color.a = 1.0
	var nachts := zustand.minuten >= 21 * 60 or zustand.minuten < 5 * 60   # Licht zur neuen Stunde wie raste()
	if (licht.ziel > 0.5) != nachts: licht.umschalten()
	betrete(String(ort["karte"]), Vector2i(int(ort["x"]), int(ort["y"])), String(ort.get("blick", "DOWN")))
	await abblenden(0.0)
	spiele(rest)

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
	return (licht.ist_nacht() and art != "INTERIOR") or art == "CAVE"   # 539 Game.isNight

# 522 (Chef 03.11., 23:33): Schild, Waffe, Kleidung aus Testmenue oder Ausruestungsschirm gleich am Helden, nicht erst nach Kartenwechsel
func held_figur_neu(vorher: String) -> void:
	var w := HeldFigur.wahl(held_werte(), zustand)
	if held == null or JSON.stringify(w) == vorher: return
	held.neu_figur(w)

func fackel_neu() -> void:
	if held: held.fackel_neu(Menue.fackel(held_werte()), String(karte.daten.get("art", "")) == "INTERIOR")

# 538, 870.4: die Heldenstufe steht im Stand nach BRS (zustand.brs_stufe, Kampf und Uebung schreiben hinein); der Held spiegelt sie,
# eine Stufe hoeher heilt ganz (Jerry 870.5: Leben und Mana voll)
func stufe_abgleichen() -> void:
	var h := held_werte()
	var neu := zustand.stufe()
	if neu > h.stufe:
		h.stufe = neu
		h.voll()
	else:
		h.stufe = neu
		h.begrenze()

# 543, 870.4: Startgold und Heiltraenke fuer jede Herkunft gleich (werte.json „wirtschaft“ startgold, start_heiltraenke)
static func startvorrat(z: Zustand) -> void:
	var wi: Dictionary = BrsHeld.lade().get("wirtschaft", {})
	z.gold = int(wi.get("startgold", 20))
	z.dazu("potion", int(wi.get("start_heiltraenke", 2)))

func held_werte() -> BrsHeld:
	if werte == null:
		werte = BrsHeld.aus_daten(zustand.brs) if not zustand.brs.is_empty() else BrsHeld.neu()
		werte.name = zustand.name
		werte.voll()
	if not zustand.fert.is_empty(): werte.geuebt = zustand.fert["werte"]   # 471: was er seither geuebt hat
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

# RestBody: Feuer kurz und lang; Theke Met, Fleisch (525, solange der Held welches traegt) und Zimmer; Bett Zimmer
func zeige_rast() -> void:
	var z := zustand
	var lang_ok := Rast.lange_erlaubt(z)
	var titel := Sprache.r({"feuer": "ask", "schenke": "tavern", "zimmer": "room"}[rast_ort])
	var zeilen_: Array = []
	if rast_ort != "feuer": zeilen_.append("%d %s" % [z.gold, Sprache.u("gold")])   # 557 (Chef 19:54): „23 Gold“
	if rast_ort == "schenke": zeilen_.append(Rast.rowena_sagt(z, held_werte().name, rast_zweites))
	var k: Array = []
	if rast_ort == "feuer":
		k.append({"text": Sprache.r("short"), "info": Sprache.r("shortDoes"), "id": "kurz"})
		k.append({"text": Sprache.r("long"), "info": Sprache.r("longDoes" if lang_ok else "longDone"), "an": lang_ok, "id": "lang"})
	else:
		if rast_ort == "schenke" and not z.betrunken():
			var preis := Rast.met_preis(z)
			k.append({"text": Sprache.r("meadBuy", [preis]), "info": Sprache.r("meadDoes"), "an": z.gold >= preis, "id": "met"})
		if rast_ort == "schenke" and z.anzahl("raw_meat") > 0:   # 525 (RestScreen.kt 113–122): Rowena kauft rohes Fleisch
			k.append({"text": Sprache.r("meatSell", [Rast.fleisch_preis(z, held_werte())]), "info": "%d× %s" % [z.anzahl("raw_meat"), Laden.name("raw_meat")], "id": "fleisch"})
		k.append({"text": Sprache.r("roomBuy", [Rast.ZIMMER_PREIS]), "info": Sprache.r("roomDoes" if lang_ok else "longDone"),
			"an": lang_ok and z.gold >= Rast.ZIMMER_PREIS, "id": "lang"})
	if Spielstaende.entwurf == "B":
		zeige_rastfeld(titel, zeilen_, k)
		return
	ui.zeige_wahl(titel, zeilen_, k, Sprache.r("leave"), rast_notiz)

# 549 in 557 (Archiv 05.11., 08:18: „557 wie gebaut“): die Rast im Stil B (rastfeld.gd) statt der allgemeinen Wahl; je Wahl Name und
# Dauer oder Preis aus dem Text („Kurze Rast · 1 Stunde“), was sie bringt, und ein Zeichen wie in den Bildern 557 (Uhr, Mond, Krug,
# Keule, Bett); Gold als kleine Angabe unter dem Titel, Rowenas Satz darunter, an der Theke das Wirtshausschild
const RAST_ZEICHEN := {"kurz": "CLOCK", "lang": "MOON", "met": "MUG", "fleisch": "MEAT"}
var rast_feld: Rastfeld

func zeige_rastfeld(titel: String, zeilen_: Array, k: Array) -> void:
	rast_feld_zu()
	var wahlen: Array = []
	for e in k:
		var t := String(e["text"]).split(" · ")
		var id := String(e["id"])
		wahlen.append({"id": id, "name": t[0], "dauer": t[1] if t.size() > 1 else "", "tut": String(e.get("info", "")), "an": bool(e.get("an", true)),
			"zeichen": "BED" if id == "lang" and rast_ort != "feuer" else String(RAST_ZEICHEN.get(id, "CLOCK"))})
	var unter := String(zeilen_[0]) if rast_ort != "feuer" and not zeilen_.is_empty() else ""
	var rest: Array = zeilen_.slice(1) if unter != "" else zeilen_
	rast_feld = Rastfeld.neu("B", titel, unter, wahlen, Sprache.r("leave"), rast_notiz, rest, "SCHENKE" if rast_ort == "schenke" else "REST")
	rast_feld.gewaehlt.connect(_rast_wahl)
	Zurueck.melde(rast_feld, func(): _rast_wahl(""))   # 416.1: die Android-Taste wie „‹ Zurück“
	ui.add_child(rast_feld)

func rast_feld_zu() -> void:
	if rast_feld and is_instance_valid(rast_feld): rast_feld.queue_free()
	rast_feld = null

func _rast_wahl(id: String) -> void:
	if rast_ort == "": return
	match id:
		"":
			rast_ort = ""
			rast_feld_zu()
			ui.schliesse_wahl()
			weiter()
			_steht_auf(held.kachel)
		"met":
			rast_notiz = Rast.met_trinken(zustand, held_werte().name)
			speichere()   # 525: wie alt vm.save() nach dem Met
			zeige_rast()
		"fleisch":
			rast_notiz = Rast.fleisch_verkaufen(zustand, held_werte())
			speichere()
			zeige_rast()
		"kurz", "lang":
			await raste(id)

## 753: Name der Rast ueber dem Satz der Blende, aus dem Text der Wahl („Lange Rast · 8 Stunden“, „Zimmer · 5 Gold“)
static func rast_name(art: String, ort: String) -> String:
	var schluessel := "short" if art == "kurz" else ("long" if ort == "feuer" or ort == "" else "roomBuy")
	return Sprache.r(schluessel).split(" · ")[0]

# die Welt wird schwarz, die Zeit vergeht (Satz in Gold), dann die Welt zur neuen Stunde mit dem Satz der Rast
func raste(art: String) -> void:
	var ort := rast_ort
	rast_feld_zu()
	ui.schliesse_wahl()
	await abblenden(1.0)
	# 753 (Chef 09.11., 14:09: „klein und futzelig … nicht wie unser neues Design“): wie die Ortsblende (556) die Rast klein und
	# gesperrt, Goldstrich, der Satz in Alegreya; die Worte kommen, stehen, gehen wie alt (RestScreen.kt: 500, 1300, 400 ms)
	var mitte := CenterContainer.new()
	mitte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mitte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var worte := Ortsblende.worte_spalte(rast_name(art, ort), Sprache.r("hourGone" if art == "kurz" else "hoursGone"))
	worte.custom_minimum_size.x = get_viewport().get_visible_rect().size.x - 2 * 36 * AktionsKnopf.DP
	worte.modulate.a = 0.0
	mitte.add_child(worte)
	blende.add_child(mitte)
	var tw := create_tween()
	tw.tween_property(worte, "modulate:a", 1.0, 0.5)
	tw.tween_interval(1.3)
	tw.tween_property(worte, "modulate:a", 0.0, 0.4)
	await tw.finished
	mitte.queue_free()
	var r := Rast.rasten(zustand, held_werte(), art, ort, platz())
	if r.has("nein"):
		rast_notiz = String(r["nein"])
		await abblenden(0.0)
		zeige_rast()
		return
	rast_ort = ""
	var neu: Dictionary = r.get("ort", {})
	if not neu.is_empty() and String(neu["karte"]) == karte.id: held.setze(Vector2i(int(neu["x"]), int(neu["y"])), String(neu["blick"]))
	licht_nach_uhr(true)   # Licht zur neuen Stunde (555, 539: die Uhr fuehrt das Licht)
	kamera.springe()
	await abblenden(0.0)
	var zeilen_: Array = []
	for t in r["zeilen"]: zeilen_.append({"text": t})
	zeige_zeilen(zeilen_)

# ---------------------------------------------------------------- Laden (390, ShopScreen.kt): Dinge kaufen (Menge waehlen, 59.5),
# Verkaeufliches aus der Tasche verkaufen, die letzten fuenf Verkaeufe zurueckkaufen, bei Morwen brauen; Ausruestung bei Thessa
# kaufen (Tragbares zuerst, 59.2), ueberall verkaufen (Seltenes zuerst), Gewoehnliches auf einmal.
# 416.3 (Chef 31.10.): bildschirmfuellend wie alt (ladenschirm.gd, ShopScreen.kt); zu: die Szene geht weiter (Game.advance)
func oeffne_laden(waren: Array, brauen: bool) -> void:
	laden = Laden.new(waren, brauen)
	held.halt()
	held.richtung = Vector3.ZERO
	var ebene := CanvasLayer.new()
	ebene.layer = 40
	add_child(ebene)
	laden_schirm = LadenSchirm.new(held_werte(), zustand, laden)
	ebene.add_child(laden_schirm)
	laden_schirm.zu.connect(func():
		ebene.queue_free()
		laden = null
		laden_schirm = null
		weiter()
		var auf := zustand.fert_notiz()   # 471: „Handeln ↑ 3“ nach dem Laden
		if auf != "": ui.kurz(auf)
		_steht_auf(held.kachel))

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
	if gebiet: gebiet.schlagbaum(karte.flaggen.has("barrier_open"))   # 530
	sichtbar_neu()

func sichtbar_neu() -> void:
	if leute == null: return
	for l in leute.get_children():
		if l is Leute: l.zeige(Geschichte.sichtbar(String(l.daten.get("id", "")), zustand))

# ---------------------------------------------------------------- Lauf
func _process(dt: float) -> void:
	if held == null: return
	Messung.bild(dt, ("Kampf " + Messung.kampf_wo) if kampf != null else "%s %d/%d" % [karte.id, held.kachel.x, held.kachel.y])   # 399.1 Gerät: Messwerte wie alt
	if kampf != null:
		Messung.kampf_bild(dt)
		_kampf_messe()
	held.laeuft = Ausdauer.schritt(zustand, held_werte(), dt * 1000.0, held.geht(), laufen_will)   # 399.1 Stamina.step
	held.atemlos_neu(zustand.atemlos and kampf == null)   # 592: leer kurz stehen, Haende auf den Knien
	if held.funke_an != zustand.funke: held.funke_neu(zustand.funke)   # 677: getrunken, geloescht, nach der Rast verglommen
	ui.ausdauer_balken.z = zustand
	# 399.3 (Jerry): atemlos keucht er (Panting.kt); 1003: die Heldin mit Frauenstimme (alt Panting.kt hero.sex, Erschaffung „geschlecht“)
	klang("atme", [zustand.atemlos and kampf == null, zustand.ausdauer, String(zustand.aussehen.get("geschlecht", "m")) == "w"])
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
			if karte.tuer(s) or zeichen_lesbar(s) or rast_kachel(s) != "" or kiste(s) != {}: ui.biete_an.callv(angebot(held.kachel))
			else: _stoesst(s)
	if rast_ort == "" and laden == null: zustand.uhr(dt)   # 390: in Rast und Laden steht die Uhr; die Rast stellt sie selbst weiter
	licht_nach_uhr()
	# 490: Monster ziehen, solange der Held frei unterwegs ist (Mode.Explore); Kraeuter wachsen bei Sonnenaufgang nach
	if herde and not im_kampf and not ui.spricht() and rast_ort == "" and laden == null and not brett_offen and not get_tree().paused: herde.schritt(dt)
	if kraut_tag != kraut_heute(): kraeuter_neu()
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

# 211.14 (Rest 211.13, Sokrates 20.10.: „Leistung am A56 messen“): im Kampf ist die Steuerung mit ihrer Bildrate verborgen; dieselbe
# Anzeige auf eigener Ebene unter dem Rand (Rand.EBENE - 1), links in der Mitte über dem Kampfort, wo weder Zugleiste noch Knöpfe sind
func _kampf_messe() -> void:
	var bs = kampf.get_node_or_null("Bausteine806") if kampf else null   # 806: Messlauf „Kampf messen“ zeigt sich immer
	var an: bool = "--messen" in OS.get_cmdline_user_args() or Testmodus.bildrate or bs != null
	if kampf_mess == null:
		if not an: return
		var e := CanvasLayer.new()
		e.layer = Rand.EBENE - 1
		e.name = "KampfMessung"
		add_child(e)
		kampf_mess = Label.new()
		kampf_mess.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var vs := get_viewport().get_visible_rect().size
		kampf_mess.position = Vector2(24, vs.y * 0.30)
		kampf_mess.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART   # wie die Steuerung (624): bricht innerhalb des Schirms um
		kampf_mess.custom_minimum_size.x = vs.x - 48
		kampf_mess.add_theme_font_size_override("font_size", int(round(14 * Stil.SP)))
		kampf_mess.add_theme_color_override("font_color", Color(0.86, 0.68, 0.32))   # wie Steuerung.GOLD
		kampf_mess.add_theme_color_override("font_outline_color", Color.BLACK)
		kampf_mess.add_theme_constant_override("outline_size", 8)
		e.add_child(kampf_mess)
	kampf_mess.get_parent().visible = an
	if an and Engine.get_process_frames() % 15 == 0: kampf_mess.text = bs.stand if bs != null else Messung.kampf_zeile()
	# 1024 (Chef 12.11., 09:04: Ansage über der Bildrate-Zeile): der Kampfschirm hält die Zeile frei
	if kampf and kampf.get("ui") != null: kampf.ui.frei_halten = [kampf_mess.get_global_rect()] if an and kampf_mess.text != "" else []

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
	# 870.4 (LISTE-UMZUG-BRS.md Schritt 4 Pruefung): der Heldenreiter nach BRS als Bild vor B1, Spielgroesse, Held wie im Spiel
	kamera.nah_fern()
	ui.leiste.visible = true
	oeffne_menue("held")
	await get_tree().create_timer(2.0).timeout
	await knips(dir + "/heldenreiter.png")
	get_tree().quit()

# 814 (Fund t278.2, dritter: Chef sieht den Fussstaub nicht): --staubbild=<ordner> laesst den Helden um 10 Uhr auf dem Erdweg vor dem
# Schlagbaum nach Norden gehen und rennen, je 0,15 s ein Bild, und schreibt, wie viele Staubwoelkchen leben und wo (Ursache nachstellen)
func staub_bild() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--staubbild="): dir = a.substr(12)
	if dir == "": return
	DirAccess.make_dir_recursive_absolute(dir)
	zustand.minuten = 10 * 60
	licht_nach_uhr(true)
	ui.mess.visible = false
	held.setze(Vector2i(17, 9), "UP")
	if OS.get_environment("STAUB_NAH") != "": kamera.nah_fern()
	await get_tree().create_timer(1.5).timeout
	var fx = gebiet.effekte
	print("STAUB erde am Helden ", fx.erde(held.global_position) if fx else "ohne Effekte", " Paket ", fx.szene("effects/footstep_dust.tscn") != null if fx else false)
	if fx and OS.get_environment("STAUB_STILL") != "":   # eine Wolke neben dem stehenden Helden, in Zeitlupe, Bilder in festen Abstaenden
		var at: Vector3 = held.global_position + Vector3(0.5, 0.02, -0.5)
		fx.fussstaub(at, false)
		var t0 := Time.get_ticks_msec()
		print("STAUB Wolke am Bild ", kamera.get_viewport().get_camera_3d().unproject_position(at))
		for i in 6:
			await get_tree().create_timer(0.06).timeout
			await knips(dir + "/still_%d.png" % i)
			print("STAUB still %d nach %d ms" % [i, Time.get_ticks_msec() - t0])
		get_tree().quit()
		return
	held.geh_zu(held.position + Vector3(0, 0, -2.0 * Karte.TS))
	for i in 8:
		await get_tree().create_timer(0.15).timeout
		var wolken: Array = fx.get_children().filter(func(c): return String(c.scene_file_path).ends_with("footstep_dust.tscn")) if fx else []
		print("STAUB Bild %d: %d Woelkchen, Held %s, Anim %s, Tempo %.2f" % [i, wolken.size(), held.global_position.snapped(Vector3.ONE * 0.01),
			held.anim.current_animation if held.anim else "-", held.tempo_jetzt])
		if i == 2 and not wolken.is_empty():
			for gp in (wolken[-1] as Node).find_children("*", "GPUParticles3D", true, false):
				var p := gp as GPUParticles3D
				var pm := p.process_material as ParticleProcessMaterial
				var mesh = p.draw_pass_1
				var mat = mesh.surface_get_material(0) if mesh else null
				print("STAUB Teil %s: an %s, einmal %s, Menge %d, Leben %.2f, Groesse %s, global %s, Mesh %s, Mat %s, Skala %.2f-%.2f, Farbe %s, sichtbar %s" % [p.name,
					p.emitting, p.one_shot, p.amount, p.lifetime, (mesh.get_aabb().size if mesh else Vector3.ZERO), p.global_transform.basis.get_scale(),
					mesh.get_class() if mesh else "-", (mat.get_class() + " " + str(mat.resource_path)) if mat else "-",
					pm.scale_min if pm else 0.0, pm.scale_max if pm else 0.0,
					(pm.color_ramp.gradient.colors if pm and pm.color_ramp else "-"), p.is_visible_in_tree()])
		await knips(dir + "/staub_%d.png" % i)
	# gross und ohne Daempfen: wird die Vorlage hier ueberhaupt gezeichnet? Dazu Kaminrauch zum Vergleich
	if fx:
		for k in [4.0, 5.0]:
			var g = fx.setze("effects/footstep_dust.tscn", held.global_position + Vector3(0.6, 0.02, 0), 4.0)
			if k == 5.0:   # dieselbe Wolke mit ausdruecklich gesetzten Vorgaben des Shaders (in der Vorlage „null“)
				for gi in g.find_children("*", "GeometryInstance3D", true, false):
					var sm = (gi as GeometryInstance3D).material_override
					if sm is ShaderMaterial:
						sm.set_shader_parameter("alpha_scale", 1.0); sm.set_shader_parameter("noise_scale", 1.0)
						sm.set_shader_parameter("erosion_edge", 0.06); sm.set_shader_parameter("proximity_fade", 0.0); sm.set_shader_parameter("alpha_scale", 1.0)
			await get_tree().create_timer(0.12).timeout
			await knips(dir + "/gross_%d.png" % int(k))
		print("STAUB Kaminrauch ", fx.kamine.size(), " Teile ", fx.get_children().filter(func(c): return String(c.scene_file_path).contains("chimney")).size())
	get_tree().quit()

# 1020.1: --pruefbild=<ordner> zeigt den Reiter „Test“ mit der Prüfliste des Builds: zwei Zeilen beantwortet (passt, falsch mit
# Wort), die dritte aufgeklappt; ein Bild zugeklappt (oben), eines aufgeklappt (Zeile offen). Nur am Rechner (eigene Ablage user://)
func pruefliste_bild() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--pruefbild="): dir = a.substr(12)
	if dir == "": return
	DirAccess.make_dir_recursive_absolute(dir)
	Testmodus.an = true
	Testmodus.geladen = true
	Sprache.setze("de")
	var zl := Pruefliste.zeilen()
	if zl.size() >= 3:
		Pruefliste.setze(String(zl[0]["nr"]), "✓")
		Pruefliste.setze(String(zl[1]["nr"]), "✗ kein Staub")
		Pruefliste.setze(String(zl[2]["nr"]), "")
	await get_tree().create_timer(1.0).timeout
	oeffne_menue("test")
	await get_tree().create_timer(1.5).timeout
	await knips(dir + "/pruefliste.png")
	if zl.size() >= 3:
		Pruefliste.offen = String(zl[1]["nr"])
		var m = get_tree().root.find_children("*", "Menue", true, false)
		if not m.is_empty(): m[0].baue()
		await get_tree().create_timer(1.0).timeout
		await knips(dir + "/pruefliste_offen.png")
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
	if "--gesichter" in OS.get_cmdline_user_args():   # 475: zuerst alle Gesichter nebeneinander
		if "--gesichtervergleich" in OS.get_cmdline_user_args():   # Lauf 2: wie Lauf 1 (Nahebene) und doppelt so weit (Zoom), zum Vergleich
			await gesichter(dir, true, "leute_gesichter_nah.png")
			await gesichter(dir, false, "leute_gesichter_weit.png", 2.0)
		if "--gesichterspiel" in OS.get_cmdline_user_args():   # Spur (c): Spielgroesse (Chef 04.11., 20:49), Tusche wie im Spiel
			await gesichter(dir, false, "leute_gesichter_spiel.png", Kamera.NAH / GESICHT_BREITE, true)
		await gesichter(dir)
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

# 475 (Chef 03.11., 07:47: „mit individuellem Gesicht … damit die alle wieder gleich ausschauen“): je Person ein Bild des Kopfs mit der
# Spielkamera (Tusche, Licht wie im Spiel), schmal und flacher wie das Kopfblatt (figurenprobe.gd), die anderen ausgeblendet; zusammen
# in leute_gesichter.png (4 Spalten, Name darunter). Zeilen GESICHT: Person, Kaufkoerper oder alt
const GESICHT_BREITE := 0.55          # m Bildbreite der Kamera
const GESICHT_KACHEL := 420           # Punkte je Bild (Quadrat um den Kopf)
const GESICHT_NAME := 50              # Punkte fuer den Namen unter dem Quadrat (Lauf 2, Pruefer 22:24: Aldrics Bart lag in der Schrift)
# 475 Lauf 2 (Pruefer 20:39: „Im ganzen Blatt fehlt die Tuschelinie“): nah = wie Lauf 1 (Nahebene kurz vor die Person); sonst bleibt die
# Nahebene, und statt dessen sind Dorf und Held ausgeblendet (was vor dem Kopf stand, waren Haeuser); Licht und Kamera wie im Spiel
# 475 Spur (c) (Tom 04.11., 22:3x): bei 0,55 m Bildbreite traf tusche.gdshader „knick“ (0,06 m Tiefenkruemmung ueber 1–2 Bildpunkte) kaum
# eine Kante, nur der Umriss blieb; ausschnitt = Spielgroesse: Kamera auf weit × 0,55 m (NAH 3,4 m), aus dem Bild nur die 0,55 m um den Kopf,
# ohne Glaetten vergroessert (so gross wie am Handy, jeder Bildpunkt sichtbar)
func gesichter(dir: String, nah := false, datei := "leute_gesichter.png", weit := 1.0, ausschnitt := false) -> void:
	var alle: Array = leute.get_children().filter(func(x): return x is Leute and not x.is_queued_for_deletion())
	var mk := Node3D.new()
	leute.add_child(mk)
	var neig_vorher: float = kamera.neigung
	var zoom_vorher: float = kamera.zoom
	kamera.neigung = -12.0
	kamera.zoom = GESICHT_BREITE * weit
	# Lauf 258 (Pruefer 05:16: fuenf von zwoelf Bildern zeigten nur Dachziegel): die Kamera steht 40 m zurueck (kamera.gd folge), Haeuser
	# davor verdeckten den Kopf; die Nahebene kurz vor die Person, was davor steht, faellt weg
	var near_vorher: float = kamera.near
	if nah: kamera.near = 40.0 - 1.5
	var welt_sichtbar: Array = []
	if not nah:
		for n in [gebiet, held]:
			if n is Node3D: welt_sichtbar.append([n, (n as Node3D).visible]); (n as Node3D).visible = false
	var name_l := Label.new()
	name_l.add_theme_font_override("font", Stil.schrift())
	name_l.add_theme_font_size_override("font_size", 30)
	name_l.add_theme_color_override("font_color", Color("f0c850"))
	name_l.add_theme_color_override("font_outline_color", Color("201408"))
	name_l.add_theme_constant_override("outline_size", 8)
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var grund := StyleBoxFlat.new()   # der Streifen unter dem Quadrat zeigt sonst den Rumpf hinter dem Namen
	grund.bg_color = Color("0e0b08")
	name_l.add_theme_stylebox_override("normal", grund)
	var ebene := CanvasLayer.new()
	ebene.layer = 50
	add_child(ebene)
	ebene.add_child(name_l)
	var vp := get_viewport().get_visible_rect().size
	name_l.size = Vector2(GESICHT_KACHEL, 40)
	name_l.size = Vector2(vp.x, 90)
	name_l.add_theme_font_size_override("font_size", 64)   # das Quadrat wird von der Bildbreite auf 420 Punkte verkleinert
	name_l.position = Vector2(0, vp.y * 0.5 + vp.x * 0.5 + 10)   # unter dem Quadrat, nie ueber Bart oder Kinn
	var kacheln: Array[Image] = []
	for l in alle:
		if l == mk: continue
		for x in alle: x.visible = x == l
		var kopf: Vector3 = l.global_position + Vector3.UP * (l.kopfhoehe() - 0.13)
		var sk := Gebiet.finde(l.modell, "Skeleton3D") as Skeleton3D
		if sk and sk.find_bone("Head") >= 0:
			kopf = sk.global_transform * sk.get_bone_global_pose(sk.find_bone("Head")).origin + Vector3.UP * 0.09
		mk.position = leute.to_local(kopf)
		# zur Kamera gewandt (Lauf 258: Gesichter nicht zu sehen); die Kamera sitzt auf ihrer +Z-Seite, die Person blickt nach +Z (leute.gd)
		var blick_vorher: float = l.blick
		l.blick = deg_to_rad(kamera.gieren_ziel); l.rotation.y = l.blick
		kamera.ziel = mk
		kamera.springe()
		name_l.text = String(l.daten["id"]).capitalize()
		await get_tree().create_timer(0.6).timeout
		await RenderingServer.frame_post_draw
		var im := get_viewport().get_texture().get_image()
		# Lauf 258 (Pruefer 05:16: je Bild nur das Viertel oben links, Rest schwarz): vp ist die Flaeche der Oberflaeche (1080 x 2340,
		# canvas_items), das Bild hat die Fenstergroesse (--resolution 540x1170); Ausschnitt in Bildpunkten des Bilds
		# und das Quadrat ueber die ganze Bildbreite (GESICHT_BREITE 0,55 m), 420 von 1080 Punkten waren nur 0,21 m, enger als ein Kopf
		var kk := im.get_width()
		if ausschnitt: kk = int(round(im.get_width() / weit))
		var c := Vector2i(im.get_width() / 2 - kk / 2, im.get_height() / 2 - kk / 2)
		var stueck := im.get_region(Rect2i(c, Vector2i(kk, kk)))
		if kk != GESICHT_KACHEL: stueck.resize(GESICHT_KACHEL, GESICHT_KACHEL, Image.INTERPOLATE_NEAREST if ausschnitt else Image.INTERPOLATE_LANCZOS)
		# der Name steht unter dem Quadrat: als eigener Streifen unter die Kachel
		var sc := im.get_width() / vp.x
		var ny := clampi(int(name_l.position.y * sc) + 1, 0, im.get_height() - 1)
		var streifen := im.get_region(Rect2i(0, ny, im.get_width(), mini(int(88.0 * sc), im.get_height() - ny)))
		streifen.resize(GESICHT_KACHEL, GESICHT_NAME, Image.INTERPOLATE_LANCZOS)
		var kachel := Image.create(GESICHT_KACHEL, GESICHT_KACHEL + GESICHT_NAME, false, stueck.get_format())
		kachel.blit_rect(stueck, Rect2i(Vector2i.ZERO, stueck.get_size()), Vector2i.ZERO)
		kachel.blit_rect(streifen, Rect2i(Vector2i.ZERO, streifen.get_size()), Vector2i(0, GESICHT_KACHEL))
		stueck = kachel
		kacheln.append(stueck)
		l.blick = blick_vorher; l.rotation.y = blick_vorher
		print("GESICHT ", l.daten["id"], " ", "Kaufkoerper" if String(l.modell.name).begins_with("Person_") else "alt", " Kopf ", kopf)
	var sp := 4
	var zeilen := ceili(kacheln.size() / float(sp))
	var blatt := Image.create(sp * GESICHT_KACHEL, zeilen * (GESICHT_KACHEL + GESICHT_NAME), false, kacheln[0].get_format() if kacheln.size() > 0 else Image.FORMAT_RGBA8)
	blatt.fill(Color("0e0b08"))
	for i in kacheln.size():
		blatt.blit_rect(kacheln[i], Rect2i(Vector2i.ZERO, kacheln[i].get_size()), Vector2i((i % sp) * GESICHT_KACHEL, (i / sp) * (GESICHT_KACHEL + GESICHT_NAME)))
	blatt.save_png(dir + "/" + datei)
	print("GESICHTER ", kacheln.size(), " ", dir + "/" + datei, " nah" if nah else " ohne Dorf")
	for w in welt_sichtbar: (w[0] as Node3D).visible = w[1]
	ebene.queue_free()
	mk.queue_free()
	kamera.near = near_vorher
	for x in alle: x.visible = true
	kamera.neigung = neig_vorher
	kamera.zoom = zoom_vorher

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

# 499 (Chef 08.11., 12:41: „Und wie bewegen die sich dann mit beim Gehen?“; 646: Bewegung als Film): Kaempfer und Kleriker mit der
# Grundausruestung gehen im Dorf die Strasse im Norden (6/8) 4 s nach Osten und 4 s zurueck, Spielkamera nah (Tusche, Signatur wie im
# Spiel), die Kamera kreist dabei einmal um den Helden; ohne Leute. --gehen499=<ordner>: Probebild, je Held ein Streifen (nach 1, 3,
# 5, 7 s); mit --write-movie derselbe Ablauf als Film (dann ohne Bilder)
func gehen_499() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--gehen499="): dir = a.substr(11)
	if dir == "": return
	var film := OS.get_cmdline_args().has("--write-movie") or "--gehen499film" in OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute(dir)
	ui.mess.visible = false
	ui.oben.visible = false
	ui.leiste.visible = false
	zustand.minuten = 11 * 60
	for k in ["Wachsoldat", "Klosterschüler"]:
		werte = BrsHeld.fuer_spiel("Thora", "Mensch", k, zustand.neue_uid)
		betrete("village", Vector2i(6, 8), "RIGHT")
		for l in leute.get_children(): l.free()
		held.leute = []
		if not kamera.nah: kamera.nah_fern()
		kamera.nach_norden()
		kamera.springe()
		laufen_will = false
		await get_tree().create_timer(1.5).timeout
		ui.textfeld.visible = false
		var reihe: Array[Image] = []
		var zeiten := [1.0, 3.0, 5.0, 7.0]
		var t := 0.0
		var dt := 1.0 / 30.0
		while t < 8.0:
			held.richtung = Vector3(1, 0, 0) if t < 4.0 else Vector3(-1, 0, 0)
			kamera.drehe(45.0 * dt)
			await get_tree().process_frame
			t += dt
			if not film and not zeiten.is_empty() and t >= zeiten[0]:
				zeiten.pop_front()
				await RenderingServer.frame_post_draw
				var b := get_viewport().get_texture().get_image(); b.convert(Image.FORMAT_RGBA8)
				reihe.append(b)
		held.richtung = Vector3.ZERO
		print("GEHEN499 %s: Held bei %s, Kamera %.0f Grad" % [k, held.kachel, kamera.gieren])
		if not reihe.is_empty():
			var bb := reihe[0].get_width(); var hh := reihe[0].get_height()
			var ges := Image.create(bb * reihe.size(), hh, false, Image.FORMAT_RGBA8)
			for i in reihe.size(): ges.blit_rect(reihe[i], Rect2i(0, 0, bb, hh), Vector2i(bb * i, 0))
			ges.save_png("%s/499_gehen_%s.png" % [dir, k])
			print("BILD %s/499_gehen_%s.png" % [dir, k])
		await get_tree().create_timer(0.5).timeout
	print("GEHEN499 fertig")
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

# 416.8 (Chef 03.11., 07:44: „… auf der Stelle drehen, wie als ob sie auf Eis wären … Wie eine Schachfigur“): --wendefilm (mit
# --write-movie) zeigt eine Person in Hosen (Bram, sonst Pim), vom Helden abgewandt; der Held spricht sie an (ohne Text, nur
# wende_zu): sie wendet sich mit Schritten um (180 Grad), der Held geht eine Kachel zur Seite, ihr Blick folgt; danach wendet sie
# sich wieder ab. --wendebild=<png> ist das Probebild (511) aus derselben Szene, mitten in der ersten Wende
func wende_film() -> void:
	var film := false
	var bild := ""
	for a in OS.get_cmdline_user_args():
		if a == "--wendefilm": film = true
		if a.begins_with("--wendebild="): bild = a.substr(12)
	if not film and bild == "": return
	ui.mess.visible = false
	ui.oben.visible = false
	ui.leiste.visible = false
	betrete("village", Vector2i(11, 7), "DOWN")
	await get_tree().create_timer(0.5).timeout
	var wer: Leute = null
	for id in ["bram", "pim"]:
		for l in leute_liste():
			if wer == null and String(l.daten.get("id", "")) == id: wer = l
	if wer == null:
		print("WENDE keine Person"); get_tree().quit(); return
	wer.warte = 999.0
	wer.ziel = Vector2i(-1, -1)
	wer.weg.clear()
	wer.position = karte.kachel_pos(wer.kachel)
	var stand := Vector2i(-1, -1)
	var seite := Vector2i.ZERO
	for d in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)]:
		var q := Vector2i(d.y, d.x)
		for sq in [q, -q]:
			if stand.x < 0 and karte.begehbar(wer.kachel + d) and karte.begehbar(wer.kachel + d + sq): stand = wer.kachel + d; seite = sq
	if stand.x < 0:
		print("WENDE kein Platz neben ", wer.daten["id"]); get_tree().quit(); return
	var weg_vom := atan2(float(wer.kachel.x - stand.x), float(wer.kachel.y - stand.y))
	wer.blick = weg_vom
	wer.rotation.y = weg_vom
	held.setze(stand, "UP")
	held.rotation.y = atan2(wer.position.x - held.position.x, wer.position.z - held.position.z)
	kamera.zoom = Kamera.NAH
	kamera.nah = true
	kamera.springe()
	print("WENDE %s auf %s, Held %s, Seite %s, Wenden %s" % [wer.daten["id"], wer.kachel, stand, seite, wer.wende_kurve.keys()])
	await get_tree().create_timer(1.5).timeout
	wer.wende_zu()
	if bild != "":
		await get_tree().create_timer(0.55).timeout
		print("WENDE Bild bei %s, %.0f Grad gedreht" % [wer.wende, rad_to_deg(absf(angle_difference(wer.rotation.y, weg_vom)))])
		await knips(bild)
		get_tree().quit()
		return
	await get_tree().create_timer(2.5).timeout
	held.geh_zu(karte.kachel_pos(stand + seite))
	await get_tree().create_timer(2.5).timeout
	held.rotation.y = atan2(wer.position.x - held.position.x, wer.position.z - held.position.z)
	await get_tree().create_timer(1.0).timeout
	wer.zugewandt_bis = Time.get_ticks_msec() + 100   # Gespraech vorbei (sonst nach ZUGEWANDT s): wieder wie vorher
	await get_tree().create_timer(3.5).timeout
	print("WENDE Ende, %.0f Grad vom Anfang" % rad_to_deg(absf(angle_difference(wer.rotation.y, weg_vom))))
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

# 490 Flüsterwald am Rechner: --wald=<ordner> knipst aus Sicht des Helden: Ankunft vom Dorf, Garrick am Feuer, Teich, Blumenwiese
# mit Kraeutern, ein Wolf bemerkt den Helden („!“), Hoehlenmund, Kartenrand im Osten; Feuer und Ankunft auch nachts
func wald_bilder() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--wald="): dir = a.substr(7)
	if dir == "": return
	DirAccess.make_dir_recursive_absolute(dir)
	ui.mess.visible = false
	ui.oben.visible = false
	zustand.minuten = 10 * 60
	betrete("forest", Vector2i(9, 30), "UP")
	if herde: herde.aus = true   # Bilder ohne Angriff
	await get_tree().create_timer(1.5).timeout
	var orte := [["ankunft", Vector2i(9, 29), "UP"], ["feuer", Vector2i(9, 10), "RIGHT"], ["teich", Vector2i(6, 15), "LEFT"],
		["kraeuter", Vector2i(5, 7), "LEFT"], ["hoehle", Vector2i(9, 2), "UP"], ["rand", Vector2i(17, 18), "RIGHT"]]
	for o in orte:
		held.setze(o[1], o[2]); kamera.springe()
		await get_tree().create_timer(1.0).timeout
		ui.textfeld.visible = false   # Tipps beim Betreten nicht ueber dem Ort
		await knips("%s/%s.png" % [dir, o[0]])
	if herde and not herde.liste.is_empty():   # ein Jaeger zwei Kacheln vor dem Helden, gerade aufmerksam geworden
		var s: Streuner = herde.liste[0]
		for x in herde.liste:
			if x.art == "wolf": s = x
		held.setze(Vector2i(17, 19), "LEFT"); kamera.springe()   # (14, 20) war ein Baum; Zeile 19 ist hohes Gras
		s.kachel = Vector2i(15, 19); s.von = s.kachel; s.blick = Vector2i(1, 0); s.alarm_bis = herde.jetzt + 5000
		await get_tree().create_timer(1.0).timeout
		ui.textfeld.visible = false   # Tipps beim Betreten nicht ueber dem Ort
		await knips("%s/monster.png" % dir)
	licht.umschalten()
	zustand.minuten = 23 * 60   # wie der Knopf „nacht“ (390): Leute und Monster nach der Uhr
	await get_tree().create_timer(2.5).timeout
	for o in [["nacht_feuer", Vector2i(9, 10), "RIGHT"], ["nacht_ankunft", Vector2i(9, 29), "UP"]]:
		held.setze(o[1], o[2]); kamera.springe()
		await get_tree().create_timer(1.0).timeout
		ui.textfeld.visible = false   # Tipps beim Betreten nicht ueber dem Ort
		await knips("%s/%s.png" % [dir, o[0]])
	print("WALDBILDER fertig")
	get_tree().quit()

# 491 Tiefer Flüsterwald am Rechner: --tiefwald=<ordner> knipst aus Sicht des Helden: Ankunft vom Flüsterwald, Weg zwischen den
# Baeumen (Sicht 353a: Held ganz zu sehen, Weg voraus erkennbar), Morwen an ihrem Feuer mit der Huette, Grimmzahn vor seinem Platz;
# Morwen und Grimmzahn auch nachts
func tiefwald_bilder() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--tiefwald="): dir = a.substr(11)
	if dir == "": return
	DirAccess.make_dir_recursive_absolute(dir)
	ui.mess.visible = false
	ui.oben.visible = false
	zustand.minuten = 10 * 60
	betrete("deep_forest", Vector2i(1, 18), "RIGHT")
	if herde: herde.aus = true   # Bilder ohne Angriff
	await get_tree().create_timer(1.5).timeout
	var orte := [["ankunft", Vector2i(1, 18), "RIGHT"], ["weg", Vector2i(21, 14), "UP"], ["morwen", Vector2i(24, 31), "UP"],
		["grimmzahn", Vector2i(22, 7), "UP"]]
	for o in orte:
		held.setze(o[1], o[2]); kamera.springe()
		await get_tree().create_timer(1.0).timeout
		ui.textfeld.visible = false
		await knips("%s/%s.png" % [dir, o[0]])
	licht.umschalten()
	zustand.minuten = 23 * 60
	await get_tree().create_timer(2.5).timeout
	for o in [["nacht_morwen", Vector2i(24, 31), "UP"], ["nacht_grimmzahn", Vector2i(22, 7), "UP"]]:
		held.setze(o[1], o[2]); kamera.springe()
		await get_tree().create_timer(1.0).timeout
		ui.textfeld.visible = false
		await knips("%s/%s.png" % [dir, o[0]])
	print("TIEFWALDBILDER fertig")
	get_tree().quit()

# 514 Gluehwuermchen am Rechner: --gluehen=<ordner> knipst nachts (23 Uhr, eine Nacht mit Gluehwuermchen) je Gebietskarte den
# groessten Schwarm aus Sicht des Helden, zwei Kacheln suedlich davon; im Augenblick, in dem die meisten dieses Schwarms leuchten
# (fester Augenblick), dazu derselbe Ort 0,8 s spaeter (Takt, Nachbar antwortet). Wald nur, wenn seine Daten im Bau sind (490).
func gluehen_bilder() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--gluehen="): dir = a.substr(10)
	if dir == "": return
	DirAccess.make_dir_recursive_absolute(dir)
	ui.mess.visible = false
	ui.oben.visible = false
	zustand.tag = 1
	while not Gluehwuermchen.heute(zustand.tag, 23 * 60): zustand.tag += 1
	for id in ["village", "forest"]:
		if not FileAccess.file_exists("res://daten/" + Gebiet.datei(id) + ".bin"): continue
		var k := Karte.lade(id)
		var fl := Gluehwuermchen.schwaerme(k)
		var zahl := {}
		for f in fl: zahl[f["mitte"]] = int(zahl.get(f["mitte"], 0)) + 1
		var best := Vector2i(-1, -1)
		for m in zahl:
			var st: Vector2i = m + Vector2i(0, 2)
			if k.begehbar(st) and (best.x < 0 or zahl[m] > zahl[best]): best = m
		if best.x < 0: continue
		var uhr := 0; var meist := -1.0
		for ms in range(0, 60000, 100):
			var s := 0.0
			for f in fl: if f["mitte"] == best: s += Gluehwuermchen.glanz(f, ms)
			if s > meist: meist = s; uhr = ms
		print("GLUEHEN %s Schwarm %s mit %d, Augenblick %d ms" % [id, best, zahl[best], uhr])
		zustand.minuten = 23 * 60
		betrete(id, best + Vector2i(0, 2), "UP")
		var hd = get("herde")   # 490 (eigener Zweig): Monster ruhig
		if hd: hd.aus = true
		licht.ziel = 1.0
		licht.stelle(1.0)
		for t in [[uhr, "a"], [uhr + 800, "b"]]:
			Gluehwuermchen.uhr_fest = t[0]
			await get_tree().create_timer(1.5).timeout
			ui.textfeld.visible = false
			await knips("%s/%s_%s.png" % [dir, id, t[1]])
	Gluehwuermchen.uhr_fest = -1
	print("GLUEHBILDER fertig")
	get_tree().quit()

# 558 Robe am Rechner (Chef 04.11., 11:31, Bild Build 257 im Tiefen Fluesterwald): --robe558=<ordner> knipst den Magier wie im Spiel,
# zur Kamera gewandt: Tiefer Fluesterwald am Weg Tag und Nacht (wie das Bild des Chefs), Dorfplatz Tag, Nahstufe; der Ablauf
# tom-probe-558.yml ruft es einmal mit der Robe von jetzt und einmal mit der neuen (held3.py STOFF) und setzt beide nebeneinander
func robe_bilder() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--robe558="): dir = a.substr(10)
	if dir == "": return
	DirAccess.make_dir_recursive_absolute(dir)
	ui.mess.visible = false
	ui.oben.visible = false
	ui.leiste.visible = false
	werte = BrsHeld.fuer_spiel(zustand.name, "Mensch", "Zauberlehrling")
	var orte := [["wald_tag", "deep_forest", Vector2i(21, 14), 10 * 60, false], ["wald_nacht", "deep_forest", Vector2i(21, 14), 22 * 60 + 25, true],
		["dorf_tag", "village", Vector2i(6, 8), 11 * 60, false], ["dorf_nah", "village", Vector2i(6, 8), 11 * 60, false]]
	var nacht := false
	for o in orte:
		zustand.minuten = int(o[3])
		if karte == null or karte.id != String(o[1]): betrete(String(o[1]), o[2], "DOWN")
		if herde: herde.aus = true   # Bilder ohne Angriff
		if bool(o[4]) != nacht:
			licht.umschalten(); nacht = bool(o[4])
		held.neu_figur(HeldFigur.wahl(werte, zustand))
		held.setze(o[2], "DOWN")
		if String(o[0]) == "dorf_nah": kamera.nah_fern()
		kamera.springe()
		var zu: Vector3 = kamera.global_basis.z   # zur Kamera gewandt (wie --bilder nah)
		held.rotation.y = atan2(zu.x, zu.z)
		await get_tree().create_timer(2.5).timeout
		ui.textfeld.visible = false
		await knips("%s/%s.png" % [dir, o[0]])
	print("ROBE558 fertig")
	get_tree().quit()

# 399.5 Grundrisse am Rechner: --raeume=<ordner> knipst je Grundriss aus der Grundansicht wie die alten Vergleichsbilder (Held wie
# HELDORT inn:4:6, sonst 4:4, Blick nach oben) Tag und Nacht, dazu um 180 Grad gedreht (die Waende vor dem Raum werden zur Bruestung)
func raeume_bilder() -> void:
	var dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--raeume="): dir = a.substr(9)
	if dir == "": return
	var stufen: PackedStringArray = []
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--nachtstufen="): stufen = a.substr(14).split(",")
	DirAccess.make_dir_recursive_absolute(dir)
	ui.mess.visible = false
	ui.oben.visible = false
	ui.leiste.visible = false
	for r in [["inn", Vector2i(4, 6)], ["shop", Vector2i(4, 4)], ["elder", Vector2i(4, 4)], ["temple", Vector2i(4, 4)]]:
		licht.ziel = 0.0
		licht.stelle(0.0)
		betrete(r[0], r[1], "UP")
		await get_tree().create_timer(1.5).timeout
		ui.sage([])
		ui.textfeld.visible = false   # Gruss beim Eintreten und Tipps: nicht ueber dem Raum
		ui.textfeld.visible = false   # Lauf 1: der Gruss kam nach dem Ausblenden wieder (Textkasten unten im Bild)
		await knips(dir + "/%s_tag.png" % r[0])
		kamin_lage(r[0] + "_tag")
		if "--kerzenprobe" in OS.get_cmdline_user_args(): await kerzen_probe(dir, r[0] + "_tag")
		licht.ziel = 1.0
		licht.stelle(1.0)
		await get_tree().create_timer(1.0).timeout
		ui.textfeld.visible = false
		await knips(dir + "/%s_nacht.png" % r[0])
		kamin_lage(r[0] + "_nacht")
		if "--kerzenprobe" in OS.get_cmdline_user_args(): await kerzen_probe(dir, r[0] + "_nacht")
		for v in stufen:   # Probe: Umgebung nachts in Stufen „Umgebung[:Kontrast[:Mondfaktor]]“, ein Lauf fuer mehrere Messungen
			var t := String(v).split(":")
			licht.env.ambient_light_energy = float(t[0])
			if t.size() > 1: licht.env.adjustment_contrast = float(t[1])
			if t.size() > 2 and gebiet.raumlicht:
				for f in gebiet.raumlicht.fenster: (f[0] as SpotLight3D).light_energy = f[1] * float(t[2])
			await get_tree().create_timer(0.3).timeout
			await knips(dir + "/%s_nacht_%s.png" % [r[0], v])
		licht.stelle(1.0)
		licht.ziel = 0.0
		licht.stelle(0.0)
		kamera.drehe(180.0)
		await get_tree().create_timer(2.5).timeout
		ui.textfeld.visible = false
		await knips(dir + "/%s_gedreht.png" % r[0])
		kamera.nach_norden()
		await get_tree().create_timer(2.5).timeout
	get_tree().quit()

# 501: wo im Bild der Kamin brennt (Fuss der Flamme), damit das Bild fuer den Chef darum ausgeschnitten wird (ohne Ansehen)
func kamin_lage(name: String) -> void:
	var cam := kamera.get_viewport().get_camera_3d()
	for f in gebiet.raumlicht.flammen:
		var kern: Node3D = f[0]
		if kern.global_basis.get_scale().y < 1.0 or not kern.is_visible_in_tree(): continue
		var q := cam.unproject_position(kern.global_position)
		print("KAMIN %s %d %d" % [name, q.x, q.y])

# 399.5 Lichtinseln (Pruefer Lauf 6: keine um die Tischkerzen): dasselbe Bild ohne Kerzenlicht und die Kerzen am Schirm, damit
# raeume_blatt.py den Anteil der Kerzen am Boden misst (ohne Ansehen)
func kerzen_probe(dir: String, name: String) -> void:
	var aus: Array = []
	for f in gebiet.raumlicht.feuer:
		var o: OmniLight3D = f[0]
		if o.get_meta("art", "") == "kerze" and o.visible:
			var q := kamera.get_viewport().get_camera_3d().unproject_position(o.global_position)
			var b := kamera.get_viewport().get_camera_3d().unproject_position(o.global_position - Vector3(0, o.global_position.y, 0))
			print("KERZE %s %d %d %d %d %.2f %.2f" % [name, q.x, q.y, b.x, b.y, o.omni_range, o.global_position.y])
			o.visible = false
			aus.append(o)
	await get_tree().create_timer(0.3).timeout
	await knips(dir + "/%s_ohnekerzen.png" % name)
	for o in aus: (o as OmniLight3D).visible = true
	await get_tree().create_timer(0.3).timeout

# 390 (Rast) am Rechner: --rastprobe oeffnet das Feuer und die Theke, waehlt und schreibt den Stand je Schritt (ohne Bild);
# Ende mit quit. Gegenprobe der Regeln: tests/rast_test.gd
func rast_probe() -> void:
	if not "--rastprobe" in OS.get_cmdline_user_args(): return
	await get_tree().create_timer(0.5).timeout
	var h := held_werte()
	var log := func(was: String) -> void:
		var knoepfe := ui.wahl_box.get_children().filter(func(c): return c is Button).map(func(b): return "%s%s" % [b.text, "" if not b.disabled else " (aus)"])
		print("RASTPROBE %s | Feld %s %s | Text %s '%s' | Tag %d %02d:%02d | TP %d/%d | Gold %d | Met %d | Nacht %s | %s" % [was, ui.waehlt(), knoepfe,
			ui.spricht(), ui.text.text, zustand.tag, zustand.minuten / 60, zustand.minuten % 60, h.leben, h.max_leben(), zustand.gold, zustand.met, licht.ziel > 0.5,
			zustand.taschen])
	h.leben = 1
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
	# Laden: tests/laden_test.gd (Regeln) und tests/bedienung_test.gd (ladenschirm.gd, 416.3)
	get_tree().quit()
