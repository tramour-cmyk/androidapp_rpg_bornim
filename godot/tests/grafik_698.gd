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
	Grafik.probe = false
	quit(1 if fehler else 0)
