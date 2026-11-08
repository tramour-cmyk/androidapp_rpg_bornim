extends SceneTree
# 399.1 ohne Bild: das Intro wie alt (Intro.kt Reel.at, IntroSound.loops, IntroLife): Uhr, Saetze, Bilder geladen, Fackelzug,
# Klang am Anfang und unter dem schwarzen Bild, Ueberspringen beendet. Braucht daten/intro.json und daten/intro wie im Bau.
# Aufruf: im Ordner godot mit -s res://tests/zwischenbild_test.gd

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll:
		fehler += 1
		print("FALSCH ", was, ": ", ist, " statt ", soll)

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	Sprache.lade()
	Sprache.setze("de")
	pruefe("Daten", Zwischenbild.da(), true)
	var z := Zwischenbild.new("intro")
	root.add_child(z)
	await process_frame
	pruefe("Saetze", z.saetze.size(), 5)
	pruefe("Satz 1", Sprache.t(z.saetze[0]), "Drei Tage nach Norden. Die Straße ist leer, nur der Mond geht mit.")
	pruefe("schwarz", z.schwarz, 4)
	pruefe("Bilder", [z.bilder.size(), z.bilder.values().all(func(t): return t != null), z.zug != null, z.vorn != null], [4, true, true, true])
	# Reel.at: Bild 2 blendet ueber Bild 1, der Satz erst nach der Blende; am Ende blendet alles aus
	var f := z.bild_bei(7200 + 700)
	pruefe("Ueberblendung", [f["bild"], f["unter"], snappedf(f["mix"], 0.01), f["text"]], [1, 0, 0.5, 0.0])
	f = z.bild_bei(7200 + 1400 + 350)
	pruefe("Satz halb", [f["unter"], snappedf(f["text"], 0.01)], [-1, 0.5])
	f = z.bild_bei(5 * 7200 + 600)
	pruefe("Ende", [f["bild"], snappedf(f["weg"], 0.01), f["vorbei"]], [4, 0.5, false])
	pruefe("vorbei", z.bild_bei(5 * 7200 + 1200)["vorbei"], true)
	# IntroSound.loops: aus der Stille, unter Bild 2 der Fluss, unter dem schwarzen die Glocke
	var m := z.schleifen_bei(0)
	pruefe("Anfang still", [m["wind"], m["river"]], [0.0, 0.0])
	m = z.schleifen_bei(7200 + 3000)
	pruefe("Bild 2", [snappedf(m["wind"], 0.001), snappedf(m["river"], 0.001), m["alarm_bell"]], [0.12, 0.22, 0.0])
	m = z.schleifen_bei(4 * 7200 + 3000)
	pruefe("Glocke", [m["wind"], snappedf(m["alarm_bell"], 0.001)], [0.0, 0.12])
	pruefe("Grillen", z.zirpen.size() > 5 and z.zirpen.all(func(c): return c[0] < 4 * 7200), true)
	var stimmen: Array = z.rufe.filter(func(r): return r[1] == "far_shout").map(func(r): return r[3])
	stimmen.sort()
	pruefe("Rufe", [z.rufe.size(), stimmen], [4, [0, 1, 2]])
	# IntroLife: fuenf Traeger; der erste geht den Weg entlang, spaeter verschwindet er hinter dem Tempel
	var a := z.zug_bei(0)
	var b := z.zug_bei(4000)
	pruefe("Traeger", a.size(), 5)
	pruefe("Zug geht", a[0][0] != b[0][0] or a[0][1] != b[0][1], true)
	pruefe("hinter dem Tempel", z.zug_bei(8600).any(func(p): return p[3] > 0.5), true)
	pruefe("Flamme", Zwischenbild.flamme(100, 100, 4, 12, 1).size(), 17)
	var rand: Array = z.leben["pfuetze"]
	var mx := 0.0
	for p in rand: mx += float(p[0]) / rand.size()
	pruefe("Pfuetze", Zwischenbild._pfuetze_bei(rand, mx).size(), 2)
	# 613 Tempelszene wie alt (TempleLife.kt): leben.txt gelesen, Kerzen in jedem Bild, Staub im Strahl von Bild 4, er treibt
	var tl := Zwischenbild.tempel_leben("# Kommentar\nflamme 1 100.0 200.0 30.5\nflamme 4 500 600 12\nflamme x 1 2 3\nstrahl 4 100 100 400 300 380 340 80 140\nunbekannt 1 2")
	pruefe("Tempel lesen", [tl["flammen"].size(), tl["flammen"][1], tl["strahlen"][4].size()], [2, [[100.0, 200.0, 30.5]], 4])
	var sa := Zwischenbild.staub(tl["strahlen"][4], 1000.0)
	var sb := Zwischenbild.staub(tl["strahlen"][4], 3000.0)
	pruefe("Staub", [sa.size() > 20, sa.all(func(m): return m[3] >= 0.0 and m[3] <= 1.0), sa.slice(0, 10) != sb.slice(0, 10)], [true, true, true])
	pruefe("Hash wie Kotlin", ["%.5f" % Zwischenbild._h(0, 1), "%.5f" % Zwischenbild._h(7, 3)], ["0.30437", "0.49479"])
	var zt := Zwischenbild.new("tempel")
	root.add_child(zt)
	await process_frame
	pruefe("Tempelbilder", [zt.bilder.size(), zt.bilder.values().all(func(t): return t != null)], [5, true])
	var kerzen := true
	for n in range(1, 6): kerzen = kerzen and zt.tempel["flammen"].get(n, []).size() > 0
	pruefe("Kerzen in jedem Bild", kerzen, true)
	pruefe("Strahl Bild 4", zt.tempel["strahlen"].has(4), true)
	zt.ms = 3 * 7200 + 3000
	zt._zeige()
	await process_frame
	await process_frame
	zt.free()
	# 292 Vorspann (Prelude.kt): Firma ein, steht, aus; Pause; Name; Menue
	var h := Hauptmenue.new(null)
	h.vorspann = Zwischenbild.daten()["vorspann"]
	pruefe("Vorspann", [0, 200, 1000, 3000, 3500, 3900, 5500, 6000].map(func(t): return h.vorspann_bei(t).map(func(x): return snappedf(x, 0.01))),
		[[0.0, 0.0, 0.0], [0.5, 0.0, 0.0], [1.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.5, 0.0], [0.0, 1.0, 0.5], [0.0, 1.0, 1.0]])
	pruefe("praesentiert", Sprache.t(h.vorspann["praesentiert"]), "präsentiert")
	var lg := Hauptmenue.logo(631)
	pruefe("Logo scharf", [lg != null, lg.get_width() if lg else 0], [true, 631])
	h.free()
	# 24.1 Ortsblende (InterludeClock.kindFor, at; Interlude.placeLines, pick)
	pruefe("Arten", [Ortsblende.art_fuer("", "inn", false), Ortsblende.art_fuer("village", "inn", true), Ortsblende.art_fuer("village", "inn", false),
		Ortsblende.art_fuer("village", "forest", false)], ["FULL", "FULL", "BLINK", "NAME"])
	var zs := Zustand.new()
	var tag := Ortsblende.saetze("village", zs, false)
	var nacht := Ortsblende.saetze("village", zs, true)
	pruefe("Saetze Dorf", [tag.size(), tag.any(func(l): return l.has("nacht")), nacht.size(), nacht.filter(func(l): return l.has("nacht")).size()], [5, false, 7, 2])
	var zr := RandomNumberGenerator.new()
	var vor = null
	var doppelt := false
	for i in 30:
		var w = Ortsblende.waehle(tag, vor, zr)
		doppelt = doppelt or w == vor
		vor = w
	pruefe("nie zweimal", doppelt, false)
	var ob := Ortsblende.new("FULL", "Bornim", tag[0])
	# 556 (Chef 04.11., 07:52 „zu kurz zum Lesen“): die Worte stehen mindestens 1,9 s und so lange, wie sie zu lesen sind (1 s + 40 ms je Zeichen)
	var L := maxf(1900.0, 1000.0 + 40.0 * ("Bornim".length() + Sprache.t(tag[0]).length()))
	pruefe("Lesezeit", [ob.lesen > 1900.0, snappedf(maxf(1900.0, ob.lesen), 1.0)], [true, snappedf(L, 1.0)])
	pruefe("FULL", [0, 200, L, L + 500, L + 900].map(func(t): return ob.bei(t).map(func(x): return snappedf(x, 0.01) if x is float else x)),
		[[1.0, 0.0, false], [1.0, 0.5, false], [1.0, 1.0, false], [0.5, 0.0, false], [0.0, 0.0, true]])
	pruefe("Schwarz", ob.get_child(0) is ColorRect and (ob.get_child(0) as ColorRect).color == Color.BLACK, true)
	ob.free()
	ob = Ortsblende.new("BLINK", "Bornim", null)
	pruefe("BLINK", [0, 250, 500].map(func(t): return ob.bei(t).map(func(x): return snappedf(x, 0.01) if x is float else x)),
		[[1.0, 0.0, false], [0.5, 0.0, false], [0.0, 0.0, true]])
	ob.free()
	ob = Ortsblende.new("NAME", "Bornim", null)
	ob.tippt = true
	pruefe("Tippen", ob.bei(100)[0] == 1.0 and ob.verlassen == 100.0, true)
	ob.free()
	# Ueberspringen: fragen, dann beenden
	z.frage()
	pruefe("fragt", z.fragt != null, true)
	var ende := [false]
	z.fertig.connect(func(): ende[0] = true)
	z.beende()
	pruefe("beendet", ende[0], true)
	print("ZWISCHENBILD %d Fehler" % fehler)
	quit(1 if fehler else 0)
