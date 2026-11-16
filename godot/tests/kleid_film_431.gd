extends SceneTree
# 431h A (Chef 16.11., 10:08, Archiv: „Film Drehteller alt gegen neu je Tracht Start und ausgezogen“): je Tracht drei Drehteller wie im
# Spiel (Erschaffung, Ausruestung) nebeneinander: links alt (ganze Tracht, wie vor 431h), Mitte neu mit der Startausruestung der Herkunft,
# rechts neu ohne Kleidung (Kopf, Oberkoerper, Arme, Beine, Umhang leer). Eine Seite je Tracht, 3 s (eine halbe Drehung).
# Alt: die Modelle eines Baus mit SCHRANK=0 (held_klassen.py) als daten/held_ALT<TRACHT>_<G>.bin, ihre held-klassen.json als
# daten/held-klassen-alt.json (nur am Rechner, nie im Spiel). Ohne sie bleibt der linke Teller leer.
# Film: xvfb-run godot --path godot --resolution 1080x720 --write-movie <x.avi> --fixed-fps 30 -s res://tests/kleid_film_431.gd [-- --frau]
# Probebild: BILD=<datei.png> ohne --write-movie: nur die erste Seite nach 1 s als Bild
# Nahtpruefung (431h „Naehte an Hals, Handgelenk, Knie, kein Durchstossen im Stehen, Gehen, Hieb“, Standbilder selbst ansehen):
# NAEHTE=<ordner>: je Tracht und Geschlecht ein Bild, Zeilen Start, ohne Oberkoerper, ohne Arme, ohne Beine, ausgezogen; Spalten
# Stehen, Gehen, Rennen, Sitzen (Knie gebeugt) schraeg von vorn und Rennen von hinten

const SEITEN := [["Wachsoldat", "WACHE"], ["Zauberlehrling", "ROBE"], ["Jägerkind", "WALD"], ["Klosterschüler", "KLOSTER"], ["Wanderer", "BAUER"]]
const SEITE_S := 3.0
const FPS := 30.0
const HALTUNGEN := [["Stehen", 0.3, 0.5], ["Gehen", 0.35, 0.5], ["Rennen", 0.3, 0.5], ["Sitzen", 0.9, 0.5], ["Rennen", 0.55, 3.4]]
const FAELLE := [["Start", []], ["ohne Oberkörper", ["CHEST", "CLOAK"]], ["ohne Arme", ["ARMS"]], ["ohne Beine", ["LEGS"]],
	["ausgezogen", ["HEAD", "CHEST", "ARMS", "LEGS", "CLOAK"]]]

var reihe: HBoxContainer
var titel: Label

func _initialize() -> void:
	_lauf.call_deferred()

func teller(w: Dictionary, dreht := true, gross := 1.6) -> Drehteller:
	var dt := Drehteller.new(w, gross, dreht)
	dt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dt.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return dt

func schrift(l: Label, gr: int, farbe: Color) -> void:
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", gr)
	l.add_theme_color_override("font_color", farbe)

func held(h: String, g: String) -> Dictionary:
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", h, z.neue_uid)
	z.aussehen = HeldFigur.vorgabe(h, g)
	return HeldFigur.wahl(hw, z)

func ohne(w: Dictionary, plaetze: Array) -> Dictionary:
	var x := w.duplicate(true)
	for p in plaetze: (x["ausruestung"] as Dictionary).erase(p)
	return x

func _lauf() -> void:
	Sprache.lade()
	var g := "w" if "--frau" in OS.get_cmdline_user_args() else "m"
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.045, 0.04)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	if OS.get_environment("NAEHTE") != "":
		await naehte(OS.get_environment("NAEHTE"))
		quit(0)
		return
	var v := VBoxContainer.new()
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(v)
	titel = Label.new()
	schrift(titel, 34, Color(0.85, 0.7, 0.4))
	v.add_child(titel)
	var kopf := HBoxContainer.new()
	for t in ["alt (ganze Tracht)", "neu: Startausrüstung", "neu: ausgezogen"]:
		var l := Label.new()
		l.text = t
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		schrift(l, 28, Color(0.8, 0.78, 0.72))
		kopf.add_child(l)
	v.add_child(kopf)
	reihe = HBoxContainer.new()
	reihe.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(reihe)
	var alt := {}
	if FileAccess.file_exists("res://daten/held-klassen-alt.json"):
		alt = JSON.parse_string(FileAccess.get_file_as_string("res://daten/held-klassen-alt.json"))
	var bild := OS.get_environment("BILD")
	for s in SEITEN:
		var h := String(s[0])
		var tr := String(s[1])
		if OS.get_environment("SEITE") != "" and OS.get_environment("SEITE") != tr: continue   # Probebild einer Tracht
		for c in reihe.get_children(): c.free()
		var w := held(h, g)
		var mo := "ALT%s_%s" % [tr, g.to_upper()]
		var wa := {}
		if alt.get("trachten", {}).has("%s_%s" % [tr, g.to_upper()]) and FileAccess.file_exists("res://daten/held_%s.bin" % mo):
			HeldFigur.lade_info()
			HeldFigur.info["trachten"][mo] = alt["trachten"]["%s_%s" % [tr, g.to_upper()]]
			var a := HeldFigur.aussehen_voll(w["aussehen"], h)
			var kap := bool(HeldFigur.lade_info().get("herkuenfte", {}).get(HeldFigur.kennung(h), {}).get("kapuze", false))
			if kap: a["frisur"] = ""
			wa = {"modell": mo, "kapuze": kap, "aussehen": a, "volk": "HUMAN", "ausruestung": w["ausruestung"]}
		var leer := Control.new()
		leer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for d in [teller(wa) if not wa.is_empty() else leer, teller(w), teller(ohne(w, HeldFigur.KLEID_PLAETZE))]: reihe.add_child(d)
		titel.text = "431h · %s · %s" % [h, "Frau" if g == "w" else "Mann"]
		print("KLEIDFILM431 Seite %s %s alt %s" % [h, g, "ja" if not wa.is_empty() else "fehlt"])
		if bild != "" and DisplayServer.get_name() != "headless":
			for i in int(FPS * float(OS.get_environment("BILD_S") if OS.get_environment("BILD_S") != "" else "1")): await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(bild)
			break
		for i in int(SEITE_S * FPS): await process_frame
	print("KLEIDFILM431 fertig")
	quit(0)

func naehte(ordner: String) -> void:
	DirAccess.make_dir_recursive_absolute(ordner)
	var gitter := GridContainer.new()
	gitter.columns = HALTUNGEN.size()
	gitter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(gitter)
	for s in SEITEN:
		for g in ["m", "w"]:
			for c in gitter.get_children(): c.free()
			var w := held(String(s[0]), g)
			var teller_ := []
			for f in FAELLE:
				for hz in HALTUNGEN:
					var dt := teller(ohne(w, f[1]), false, 0.45)
					gitter.add_child(dt)
					teller_.append([dt, hz])
			for i in 4: await process_frame
			for e in teller_:
				var dt: Drehteller = e[0]
				var hz: Array = e[1]
				if dt.teller == null or dt.teller.get_child_count() == 0: continue
				dt.teller.rotation.y = float(hz[2])
				var ap := Gebiet.finde(dt.teller.get_child(0), "AnimationPlayer") as AnimationPlayer
				if ap and ap.has_animation(String(hz[0])):
					ap.play(String(hz[0]))
					ap.pause()
					ap.seek(ap.get_animation(String(hz[0])).length * float(hz[1]), true)
				dt._bilder = 0   # Standbild neu zeichnen (Drehteller zeichnet sonst nach 6 Bildern nicht mehr)
				dt._v.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			for i in 4: await process_frame
			await RenderingServer.frame_post_draw
			var p := "%s/%s_%s.png" % [ordner, String(s[1]), g]
			root.get_texture().get_image().save_png(p)
			print("KLEID431 NAEHTE ", p)
