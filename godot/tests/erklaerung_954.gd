extends SceneTree
# 954 (Chef 11.11., 13:55 „1 ja“): Gedrueckthalten in der Erschaffung erklaert jeden Grundwert, jedes Volk, jede Herkunft und jede
# waehlbare Fertigkeit in einem Satz ([954.1.…], STORY-BRS-ERSCHAFFUNG.md); wo es in Kapitel 1 noch nicht wirkt, folgt [954.1.spaeter].
# Am Schirm: Halten oeffnet das Fenster und waehlt nicht; kurzes Tippen waehlt und oeffnet nichts; Wischen oeffnet nichts; Antippen des
# Fensters schliesst es. Finger wie auf dem Geraet (wischen_571). Ohne Bild.
# Aufruf im Ordner godot: headless, -s res://tests/erklaerung_954.gd -> „ERKLAERUNG954 0 Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FALSCH ", was)

func _initialize() -> void: _lauf.call_deferred()

func warte(n := 3) -> void:
	for i in n: await process_frame

func sekunden(s: float) -> void:
	await create_timer(s).timeout
	await process_frame

func maus(p: Vector2, an: bool) -> void:
	var f := root.get_final_transform()
	if an:
		var h := InputEventMouseMotion.new(); h.position = f * p; h.global_position = f * p
		root.push_input(h)
	var t := InputEventScreenTouch.new()
	t.index = 0; t.position = f * p; t.pressed = an
	root.push_input(t)
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT; e.pressed = an; e.position = f * p; e.global_position = f * p
	e.button_mask = MOUSE_BUTTON_MASK_LEFT if an else 0
	root.push_input(e)

func zug(p: Vector2, d: Vector2) -> void:
	var f := root.get_final_transform()
	var e := InputEventMouseMotion.new()
	e.position = f * p; e.global_position = f * p; e.relative = f.basis_xform(d); e.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(e)

# das Wahlfeld mit dem Text [t] (Versalien wie Stil.wahlfeld)
func feld(w: Node, t: String) -> Control:
	for l in w.find_children("Text", "Label", true, false):
		if (l as Label).text == t.to_upper().replace("ß", "SS"): return l.get_parent() as Control
	return null

func mitte(c: Control) -> Vector2: return c.get_global_rect().get_center()

func offen(w: ErschaffungBrs) -> bool: return is_instance_valid(w.erklaer_fenster)

func kopf(w: ErschaffungBrs) -> String:
	var l := w.erklaer_fenster.find_children("*", "Label", true, false)
	return (l[0] as Label).text if not l.is_empty() else ""

func _lauf() -> void:
	if BrsHeld.lade().is_empty():
		print("FALSCH daten/werte.json fehlt"); quit(1); return
	# 1. Saetze: jeder Eintrag hat einen, in beiden Sprachen; ohne Wirkung mit [954.1.spaeter]
	var fehlt := []
	for g in BrsHeld.grundwerte(): if ErschaffungBrs.erklaerung("wert", g) == "": fehlt.append(g)
	for v in BrsHeld.voelker(): if ErschaffungBrs.erklaerung("volk", v) == "": fehlt.append(v)
	for h in BrsHeld.herkuenfte(): if ErschaffungBrs.erklaerung("herkunft", h) == "" and h != "Zauberlehrling": fehlt.append(h)   # Zauberlehrling: 954.2 (Homer)
	var wb := BrsHeld.waehlbar()
	var alle_fert := []
	for gr in wb:
		for f in wb[gr]:
			alle_fert.append(String(f))
			if ErschaffungBrs.erklaerung("fert", String(f)) == "": fehlt.append(f)
	pruefe(fehlt.is_empty(), "ohne Satz: %s" % [fehlt])
	for k in ErschaffungBrs.ERKLAER:
		for x in ErschaffungBrs.ERKLAER[k]:
			var d: Dictionary = ErschaffungBrs.ERKLAER[k][x]
			pruefe(String(d.get("de", "")) != "" and String(d.get("en", "")) != "", "%s %s: beide Sprachen" % [k, x])
	for x in ErschaffungBrs.OHNE_WIRKUNG:
		var art := "wert" if BrsHeld.grundwerte().has(x) else ("volk" if BrsHeld.voelker().has(x) else "fert")
		var s := ErschaffungBrs.erklaerung(art, x)
		pruefe(s.ends_with(Sprache.t(ErschaffungBrs.SPAETER)), "%s ohne Wirkung endet mit [954.1.spaeter]: %s" % [x, s])
	pruefe(not ErschaffungBrs.erklaerung("fert", "Einhänder").contains(Sprache.t(ErschaffungBrs.SPAETER)), "Einhänder wirkt, ohne [954.1.spaeter]")
	# 2. am Schirm
	root.size = Vector2i(720, 1520)
	var w := ErschaffungBrs.new()
	root.add_child(w)
	await warte(6)
	# Volk Elf halten: Fenster mit „ELF“, Volk bleibt Mensch
	var elf := feld(w, ErschaffungBrs.volk_name("Elf"))
	pruefe(elf != null, "Wahlfeld Elf da")
	if elf != null:
		maus(mitte(elf), true)
		await sekunden(Zeichenknopf.HALTEN + 0.2)
		pruefe(offen(w), "Halten auf Elf öffnet das Fenster")
		maus(mitte(elf), false)
		await warte(3)
		pruefe(w.b.volk == "Mensch", "Halten wählt nicht (Volk %s)" % w.b.volk)
		pruefe(offen(w) and kopf(w) == ErschaffungBrs.volk_name("Elf").to_upper(), "Kopf ELF (%s)" % (kopf(w) if offen(w) else "—"))
		# Antippen des Fensters schliesst es
		var innen: Control = w.erklaer_fenster.find_children("*", "PanelContainer", true, false).back()
		maus(mitte(innen), true); await process_frame; maus(mitte(innen), false)
		await warte(3)
		pruefe(not offen(w), "Antippen schließt das Fenster")
	# kurz tippen: waehlt, kein Fenster
	elf = feld(w, ErschaffungBrs.volk_name("Elf"))
	if elf != null:
		maus(mitte(elf), true); await process_frame; maus(mitte(elf), false)
		await sekunden(Zeichenknopf.HALTEN + 0.2)
		pruefe(w.b.volk == "Elf", "Tippen wählt Elf (%s)" % w.b.volk)
		pruefe(not offen(w), "Tippen öffnet kein Fenster")
	# wischen: kein Fenster
	var zw := feld(w, ErschaffungBrs.volk_name("Zwerg"))
	if zw != null:
		var p := mitte(zw)
		maus(p, true); await process_frame
		for i in 6:
			p += Vector2(0, -8); zug(p, Vector2(0, -8)); await process_frame
		await sekunden(Zeichenknopf.HALTEN + 0.2)
		maus(p, false); await warte(3)
		pruefe(not offen(w), "Wischen öffnet kein Fenster")
	# Herkunft und Grundwert halten
	var hk := feld(w, ErschaffungBrs.herkunft_name("Jägerkind"))
	pruefe(hk != null, "Wahlfeld Jägerkind da")
	if hk != null:
		w.rolle.ensure_control_visible(hk); await warte(3)
		maus(mitte(hk), true); await sekunden(Zeichenknopf.HALTEN + 0.2); maus(mitte(hk), false); await warte(3)
		pruefe(offen(w) and w.b.herkunft != "Jägerkind", "Halten auf Jägerkind erklärt, wählt nicht")
		w.schliesse_erklaerung()
	var kraft: Control = null
	for l in w.inhalt.find_children("*", "Label", true, false):
		if (l as Label).text == Sprache.t(ErschaffungBrs.GRUNDWERT["kraft"]): kraft = l
	pruefe(kraft != null, "Name Kraft da")
	if kraft != null:
		w.rolle.ensure_control_visible(kraft); await warte(3)
		maus(mitte(kraft), true); await sekunden(Zeichenknopf.HALTEN + 0.2); maus(mitte(kraft), false); await warte(3)
		pruefe(offen(w) and kopf(w) == Sprache.t(ErschaffungBrs.GRUNDWERT["kraft"]).to_upper(), "Halten auf Kraft erklärt")
		w.schliesse_erklaerung()
	# Fertigkeit (Mensch hat eine Wahl): halten waehlt nicht
	w.volk_waehlen("Mensch"); await warte(3)
	var sp := feld(w, ErschaffungBrs.fert_name("Spähen"))
	pruefe(sp != null, "Wahlfeld Spähen da")
	if sp != null:
		w.rolle.ensure_control_visible(sp); await warte(3)
		maus(mitte(sp), true); await sekunden(Zeichenknopf.HALTEN + 0.2); maus(mitte(sp), false); await warte(3)
		pruefe(offen(w) and not w.b.wahl.has("Spähen"), "Halten auf Spähen erklärt, wählt nicht (%s)" % [w.b.wahl])
		w.schliesse_erklaerung()
	print("ERKLAERUNG954 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
