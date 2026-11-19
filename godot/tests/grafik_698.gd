extends SceneTree
# 698 (698a A, Chef 16.11., 06:46): Grafikstufen Hoch, Mittel, Niedrig und Automatisch. Prüft die Tabelle (Hoch = Stand vorher aus
# project.godot), das Antippen im Systemmenü, die Schalter je Stufe, die Innenschatten an den Lichtern und Automatisch: zehn Sekunden
# über einem Bild bei 60 Hz senken erst am nächsten Ladepunkt, mit einer Meldung, einmal; herauf nie von selbst.
# Aufruf im Ordner godot: --headless -s res://tests/grafik_698.gd   (Exit 0 = alles richtig)

var fehler := 0

func pruefe(was: String, gut: bool, wie := "") -> void:
	if not gut: fehler += 1; print("FALSCH %s %s" % [was, wie])
	else: print("ok %s" % was)

func _initialize() -> void: _lauf.call_deferred()

func _zeichen(m: Node, w: String) -> Zeichenknopf:
	for n in m.find_children("*", "Zeichenknopf", true, false):
		if (n as Zeichenknopf).wort == w and n.is_inside_tree() and not n.is_queued_for_deletion(): return n
	return null

func _lauf() -> void:
	# Hoch ist der Stand vor 698
	pruefe("Hoch: Sonnenschatten wie project.godot", Grafik.SONNE_PX[Grafik.HOCH] == int(ProjectSettings.get_setting("rendering/lights_and_shadows/directional_shadow/size"))
		and Grafik.SONNE_WEICH[Grafik.HOCH] == int(ProjectSettings.get_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality")))
	pruefe("Schärfe 100/85/70 %", Grafik.SCHAERFE == [0.70, 0.85, 1.0])
	pruefe("ohne Bildschirm fest Hoch", Grafik.fest() == Grafik.HOCH and not Grafik.automatisch())
	Grafik.probe = true
	Grafik.wahl = "auto"; Grafik.auto_stufe = -1
	pruefe("Vorgabe Automatisch, ungemessen", Grafik.automatisch() and Grafik.braucht_messung())

	var n := Node3D.new()
	root.add_child(n)
	var l := OmniLight3D.new()
	l.shadow_enabled = true
	l.add_to_group("grafik_schatten")
	n.add_child(l)
	var frei := OmniLight3D.new()   # ohne Gruppe (Kampfort, Laterne): bleibt
	frei.shadow_enabled = true
	n.add_child(frei)

	Grafik.setze(self, Grafik.NIEDRIG)
	pruefe("Niedrig: 3D 70 %", is_equal_approx(root.scaling_3d_scale, 0.70), str(root.scaling_3d_scale))
	pruefe("Niedrig: ohne Innenschatten, Kits, Tusche nach Lampen", not Grafik.innen_schatten() and not Grafik.kits() and not Grafik.tusche_lampen())
	pruefe("Niedrig: Innenschatten aus, fremdes Licht bleibt", not l.shadow_enabled and frei.shadow_enabled)
	# 1270.4: Glühen nur in Hoch, auch an einer Umgebung der Gruppe „grafik_gluehen“
	var we := WorldEnvironment.new()
	we.environment = Environment.new()
	we.add_to_group("grafik_gluehen")
	n.add_child(we)
	Grafik.setze(self, Grafik.NIEDRIG)
	pruefe("Niedrig: kein Glühen", not Grafik.gluehen() and not we.environment.glow_enabled)
	Grafik.setze(self, Grafik.HOCH)
	pruefe("Hoch: Glühen an, Schwelle 0,9", Grafik.gluehen() and we.environment.glow_enabled and is_equal_approx(we.environment.glow_hdr_threshold, 0.9))
	Grafik.setze(self, Grafik.NIEDRIG)
	pruefe("Niedrig: kein Gras und keine Effekte der Kits", not GrasBausatz.aktiv() and not DorfEffekte.aktiv() and not KampfEffekte.da_nebel())
	Grafik.setze(self, Grafik.MITTEL)
	pruefe("Mittel: 3D 85 %, Innenschatten, Kits", is_equal_approx(root.scaling_3d_scale, 0.85) and l.shadow_enabled and Grafik.kits() and Grafik.tusche_lampen())
	Grafik.setze(self, Grafik.HOCH)
	pruefe("Hoch: 3D voll", is_equal_approx(root.scaling_3d_scale, 1.0))

	# Antippen: Automatisch, Hoch, Mittel, Niedrig, wieder Automatisch
	var folge := []
	for i in 4:
		Grafik.weiter(self)
		folge.append(Grafik.wahl)
	pruefe("Antippen wechselt", folge == ["hoch", "mittel", "niedrig", "auto"], str(folge))
	pruefe("1670a: nach einer Wahl wird der Ort beim Schliessen neu gebaut", Grafik.neu_laden)
	pruefe("1670a: spiel.gd baut beim Schliessen des Menüs neu", FileAccess.get_file_as_string("res://skripte/spiel.gd").contains("if Grafik.neu_laden:"))
	Grafik.neu_laden = false
	Grafik.weiter(self); Grafik.weiter(self)   # Mittel gewählt
	pruefe("Wahl Mittel gilt sofort", Grafik.aktiv == Grafik.MITTEL and is_equal_approx(root.scaling_3d_scale, 0.85))
	for i in 2: Grafik.weiter(self)   # zurück auf Automatisch
	pruefe("wieder Automatisch", Grafik.wahl == "auto")

	# Zeichen „Grafik“ im Systemmenü, Gruppe „Spiel“; Antippen wechselt den Wert
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	Bedienung.lade()
	var z := Zustand.new()
	var m := Menue.new(BrsHeld.fuer_spiel("Mira", "Elf", "Zauberlehrling", z.neue_uid), z)
	root.add_child(m)
	m.reiter = "system"; m.baue()
	for i in 3: await process_frame
	var zk: Zeichenknopf = _zeichen(m, "Grafik")
	pruefe("Zeichen Grafik im Systemmenü, Wert Automatisch", zk != null and String(zk.wert) == "Automatisch", str(zk.wert) if zk else "fehlt")
	var sp: Zeichenknopf = _zeichen(m, "Speichern")
	pruefe("Grafik in der Reihe von Speichern", zk != null and sp != null and absf(zk.get_global_rect().position.y - sp.get_global_rect().position.y) < 1.0)
	if zk: zk.tat.call()
	for i in 2: await process_frame
	zk = _zeichen(m, "Grafik")
	pruefe("Antippen: Hoch", zk != null and String(zk.wert) == "Hoch" and Grafik.wahl == "hoch")
	m.queue_free()
	Grafik.wahl = "auto"

	# Automatisch: Hoch gemessen, dann ruckelt es
	Grafik.wahl = "auto"; Grafik.auto_stufe = Grafik.HOCH
	pruefe("Ladepunkt ohne Senken: keine Meldung", Grafik.ladepunkt(self) == "" and Grafik.aktiv == Grafik.HOCH)
	for i in 9 * 30: Grafik.bild(self, 1.0 / 30.0)   # neun Sekunden zu langsam: noch nicht
	pruefe("neun Sekunden: bleibt", not Grafik.gesenkt and Grafik.aktiv == Grafik.HOCH)
	for i in 240: Grafik.bild(self, 1.0 / 120.0)      # zwei flüssige Sekunden zählen neu
	for i in 2 * 30: Grafik.bild(self, 1.0 / 30.0)
	pruefe("Unterbrechung zählt neu", not Grafik.gesenkt)
	for i in 10 * 30: Grafik.bild(self, 1.0 / 30.0)
	pruefe("zehn Sekunden: gesenkt gemerkt, Szene bleibt", Grafik.gesenkt and Grafik.aktiv == Grafik.HOCH and is_equal_approx(root.scaling_3d_scale, 1.0))
	for i in 20 * 30: Grafik.bild(self, 1.0 / 30.0)
	pruefe("bis zum Ladepunkt nur eine Stufe", Grafik.auto_stufe == Grafik.MITTEL, str(Grafik.auto_stufe))
	var satz := Grafik.ladepunkt(self, true)
	pruefe("Ladepunkt: Mittel mit Meldung", Grafik.aktiv == Grafik.MITTEL and satz == "Grafik: Mittel", satz)
	pruefe("Meldung einmal", Grafik.ladepunkt(self, true) == "")
	for i in 60 * 120: Grafik.bild(self, 1.0 / 120.0)
	Grafik.ladepunkt(self)
	pruefe("herauf nie von selbst", Grafik.aktiv == Grafik.MITTEL)
	for i in 11 * 30: Grafik.bild(self, 1.0 / 30.0)
	Grafik.ladepunkt(self)
	for i in 11 * 30: Grafik.bild(self, 1.0 / 30.0)
	Grafik.ladepunkt(self)
	pruefe("nie unter Niedrig", Grafik.aktiv == Grafik.NIEDRIG and Grafik.auto_stufe == Grafik.NIEDRIG)
	Grafik.wahl = "hoch"
	Grafik.ladepunkt(self)
	for i in 11 * 30: Grafik.bild(self, 1.0 / 30.0)
	pruefe("feste Wahl senkt nie", not Grafik.gesenkt and Grafik.aktiv == Grafik.HOCH)

	# Anfangsmessung: ohne Grafikzeit zählt die Bildzeit; headless schnell, also Hoch
	Grafik.wahl = "auto"; Grafik.auto_stufe = -1
	await Grafik.messen(self)
	pruefe("Anfangsmessung wählt eine Stufe", Grafik.auto_stufe >= Grafik.NIEDRIG and Grafik.aktiv == Grafik.auto_stufe, str(Grafik.auto_stufe))
	pruefe("danach keine Messung mehr", not Grafik.braucht_messung())
	# 1645: Kampfort nimmt höchstens die Karte der Stufe und gibt beim Verlassen die der Stufe zurück, nicht fest 4096
	var kf = load("res://kampf/kampfort.gd")
	var karten := []
	for st in [Grafik.NIEDRIG, Grafik.MITTEL, Grafik.HOCH]:
		Grafik.setze(self, st)
		karten.append([kf.schattenkarte(), Grafik.sonne_px()])
	pruefe("Kampfort-Schattenkarte je Stufe (im Kampf, danach)", karten == [[1024, 1024], [2048, 2048], [2048, 4096]], str(karten))
	var quelle := FileAccess.get_file_as_string("res://kampf/kampfort.gd")
	var ende := quelle.substr(quelle.find("func _exit_tree"), 200)
	pruefe("Kampfort verlässt mit der Karte der Stufe", ende.contains("Grafik.sonne_px()") and not ende.contains("4096)"))
	# 1270.6: mit Takt 30 gilt ein Bild bei 30/s als Ziel; 30 Bilder je Sekunde senken nicht; „3D halb“ setzt 50 %
	Testmodus.takt_setzen(Testmodus.TAKT_SPIEL)
	pruefe("Takt des Spiels 30, Ziel 33,3 ms", Engine.max_fps == 30 and absf(Grafik.ziel_ms() - 1000.0 / 30.0) < 0.01, str(Grafik.ziel_ms()))
	Grafik.wahl = "auto"; Grafik.auto_stufe = Grafik.HOCH; Grafik.gesenkt = false
	Grafik.ladepunkt(self)
	for i in 15 * 30: Grafik.bild(self, 1.0 / 30.0)
	pruefe("Takt 30: 15 Sekunden mit 30 Bildern senken nicht", not Grafik.gesenkt)
	await Grafik.messen(self)
	pruefe("Einmessen stellt den Takt wieder her", Engine.max_fps == 30)
	Testmodus.aufl_umschalten()
	pruefe("3D halb: 50 %", is_equal_approx(root.scaling_3d_scale, 0.5))
	Testmodus.aufl_umschalten()
	pruefe("3D halb aus: wie die Stufe", is_equal_approx(root.scaling_3d_scale, Grafik.SCHAERFE[Grafik.aktiv]))
	Testmodus.takt_setzen(0)
	# 1270.6: gespeicherte Messung ohne Takt (vor 1270.6) gilt nicht, mit Takt 30 schon
	var c := ConfigFile.new()
	c.set_value("grafik", "wahl", "auto"); c.set_value("grafik", "auto", Grafik.NIEDRIG)
	c.save(Grafik.DATEI)
	Grafik.wahl = ""; Grafik.lade()
	pruefe("alte Messung ohne Takt: neu einmessen", Grafik.auto_stufe == -1 and Grafik.braucht_messung())
	c.set_value("grafik", "takt", 30); c.save(Grafik.DATEI)
	Grafik.wahl = ""; Grafik.lade()
	pruefe("Messung mit Takt 30 gilt", Grafik.auto_stufe == Grafik.NIEDRIG)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Grafik.DATEI))
	Grafik.probe = false
	quit(1 if fehler else 0)
