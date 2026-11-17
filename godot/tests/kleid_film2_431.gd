extends SceneTree
# 431h Stufe 2 (Chef 17.11., 09:45, „431h A“; Vorlage: „Film: Drehteller je Volk in drei Ruestungen, alt gegen neu“): je Tracht drei
# Drehteller mit derselben fremden Ruestung: links alt (Stufe 1: das Teil der eigenen Tracht steht fuer jedes Stueck, kleide „stufe1“),
# Mitte neu mit Kapitel-1-Stuecken (Kettenhemd bzw. Lederruestung am Wachsoldaten, Kroggs Pranken, Lederstiefel bzw. Hose), rechts neu
# schwer (Topfhelm, Plattenpanzer, Panzerhandschuhe, Beinschienen). Je Seite ein anderes Volk (Hautton), 3 s.
# Film: xvfb-run godot --path godot --write-movie <x.avi> --fixed-fps 30 -s res://tests/kleid_film2_431.gd [-- --frau]
# Nahtpruefung (Vorlage: „je Koerper leichte, mittlere, schwere Ruestung und gemischt … Naehte an Hals, Handgelenk, Knie, kein
# Durchstossen in Stehen, Gehen, Hieb“): NAEHTE=<ordner>: je Tracht und Geschlecht ein Bild, Zeilen die Saetze, Spalten Haltungen

const SEITEN := [["Wachsoldat", "WACHE", "Mensch"], ["Zauberlehrling", "ROBE", "Elf"], ["Jägerkind", "WALD", "Zwerg"],
	["Klosterschüler", "KLOSTER", "Orkblütiger"], ["Wanderer", "BAUER", "Hügelvolk"]]
const SEITE_S := 3.0
const FPS := 30.0
const SCHWER := {"HEAD": "great_helm", "CHEST": "plate", "ARMS": "gauntlets", "LEGS": "greaves"}
const SAETZE := [["leicht", {"CHEST": "leather", "ARMS": "gloves", "LEGS": "leggings"}],
	["mittel", {"HEAD": "hood", "CHEST": "chain_shirt", "ARMS": "gauntlets_ogre", "LEGS": "boots"}],
	["schwer", SCHWER],
	["gemischt 1", {"CHEST": "breastplate", "ARMS": "wraps", "LEGS": "boots"}],
	["gemischt 2", {"CHEST": "chain_shirt", "ARMS": "bracers", "LEGS": "greaves"}]]
const HALTUNGEN := [["Stehen", 0.3, 0.5], ["Gehen", 0.35, 0.5], ["Rennen", 0.3, 0.5], ["Sitzen", 0.9, 0.5], ["Rennen", 0.55, 3.4]]

var reihe: HBoxContainer
var titel: Label

func _initialize() -> void:
	_lauf.call_deferred()

func teller(w: Dictionary, dreht := true, gross := 0.0) -> Drehteller:
	if gross <= 0.0: gross = (root.get_visible_rect().size.x / 3.0 - 12.0) / (150.0 * Drehteller.DP)
	var dt := Drehteller.new(w, gross, dreht)
	dt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return dt

func schrift(l: Label, gr: int, farbe: Color) -> void:
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", gr)
	l.add_theme_color_override("font_color", farbe)

func held(h: String, g: String, volk := "Mensch") -> Dictionary:
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", volk, h, z.neue_uid)
	z.aussehen = HeldFigur.vorgabe(h, g, HeldFigur.volk_modell(volk))
	return HeldFigur.wahl(hw, z)

func mit(w: Dictionary, satz: Dictionary, stufe1 := false) -> Dictionary:
	var x := w.duplicate(true)
	for p in satz: (x["ausruestung"] as Dictionary)[p] = {"base": satz[p]}
	if stufe1: x["stufe1"] = true
	return x

func mittel(tr: String) -> Dictionary:
	return {"CHEST": "leather" if tr == "WACHE" else "chain_shirt", "ARMS": "gauntlets_ogre", "LEGS": "leggings" if tr == "WALD" else "boots"}

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
	var spalten := []
	for t in ["alt: Kapitel 1", "neu: Kapitel 1", "neu: schwer"]:
		var l := Label.new()
		l.text = t
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		schrift(l, 28, Color(0.8, 0.78, 0.72))
		kopf.add_child(l)
	v.add_child(kopf)
	var unten := Label.new()
	schrift(unten, 24, Color(0.7, 0.68, 0.62))
	reihe = HBoxContainer.new()
	reihe.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(reihe)
	v.add_child(unten)
	var bild := OS.get_environment("BILD")
	for s in SEITEN:
		var h := String(s[0])
		var tr := String(s[1])
		if OS.get_environment("SEITE") != "" and OS.get_environment("SEITE") != tr: continue
		for c in reihe.get_children(): c.free()
		var w := held(h, g, String(s[2]))
		var m1 := mittel(tr)
		for d in [teller(mit(w, m1, true)), teller(mit(w, m1)), teller(mit(w, SCHWER))]: reihe.add_child(d)
		titel.text = "431h Stufe 2 · %s · %s · %s" % [h, String(s[2]), "Frau" if g == "w" else "Mann"]
		var namen := []
		for p in ["CHEST", "ARMS", "LEGS"]: namen.append(String(Katalog.eintrag(String(m1[p])).get("name", {}).get("de", m1[p])))
		unten.text = "Kapitel 1: " + ", ".join(namen)
		print("KLEIDFILM2 Seite %s %s" % [h, g])
		if bild != "" and DisplayServer.get_name() != "headless":
			for i in int(FPS * 1.0): await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(bild)
			break
		for i in int(SEITE_S * FPS): await process_frame
	print("KLEIDFILM2 fertig")
	quit(0)

func naehte(ordner: String) -> void:
	DirAccess.make_dir_recursive_absolute(ordner)
	var gitter := GridContainer.new()
	gitter.columns = HALTUNGEN.size()
	gitter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(gitter)
	for s in SEITEN:
		for g in ["m", "w"]:
			if OS.get_environment("SEITE") != "" and OS.get_environment("SEITE") != String(s[1]): continue
			for c in gitter.get_children(): c.free()
			var w := held(String(s[0]), g)
			var teller_ := []
			for f in SAETZE:
				for hz in HALTUNGEN:
					var dt := teller(mit(w, f[1]), false, 0.45)
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
				dt._bilder = 0
				dt._v.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			for i in 4: await process_frame
			await RenderingServer.frame_post_draw
			var p := "%s/%s_%s.png" % [ordner, String(s[1]), g]
			root.get_texture().get_image().save_png(p)
			print("KLEID2 NAEHTE ", p)
