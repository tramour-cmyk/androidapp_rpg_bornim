extends SceneTree
# 571 (Chef 04.11., 20:13, Build 257): Wischen auf einer Schaltflaeche rollt die Liste; Tippen waehlt; Wischen loest den Knopf nicht aus.
# Erst an einer Probeliste, dann auf den Schirmen, die der Chef nennt: Testmenue (Kampfliste), Erschaffung (alt und BRS), Spielmenue
# (Held, Tasche), Laden, Lizenzen. Finger wie auf dem Geraet (Beruehrung und nachgebildete Maus). Ohne Bild.
# Aufruf im Ordner godot: headless, -s res://tests/wischen_571.gd -> „WISCHEN571 gut“

var fehler := 0
var gedrueckt := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

func warte(n := 3) -> void:
	for i in n: await process_frame

# wie auf dem Geraet (tasten_4161, kampfbericht_test): Finger als Beruehrung und zusaetzlich als Maus (emulate_mouse_from_touch)
func maus(p: Vector2, an: bool) -> void:
	var f := root.get_final_transform()
	if an:   # der Zeiger steht schon dort
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
	var t := InputEventScreenDrag.new()
	t.index = 0; t.position = f * p; t.relative = f.basis_xform(d)
	root.push_input(t)
	var e := InputEventMouseMotion.new()
	e.position = f * p; e.global_position = f * p; e.relative = f.basis_xform(d); e.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(e)

func wische(p: Vector2, schritte: int, dy: float) -> void:
	maus(p, true)
	await process_frame
	for i in schritte:
		p += Vector2(0, dy)
		zug(p, Vector2(0, dy))
		await process_frame
	maus(p, false)
	await warte(5)

func tippe(p: Vector2) -> void:
	maus(p, true); await process_frame; maus(p, false)
	await warte(3)

# die laengste sichtbare Liste des Schirms, die rollen kann
func rolle_von(w: Node) -> ScrollContainer:
	var beste: ScrollContainer = null
	for s in w.find_children("*", "ScrollContainer", true, false):
		var r := s as ScrollContainer
		if not r.is_visible_in_tree(): continue
		var rest := r.get_v_scroll_bar().max_value - r.get_v_scroll_bar().page
		if rest > 200 and (beste == null or r.size.y > beste.size.y): beste = r
	return beste

# ein sichtbarer Knopf (oder eine Tippzeile wie in der Tasche, menue.gd tippbar) mitten in der Liste, unter dem noch Platz zum Wischen ist
func knopf_in(r: ScrollContainer) -> Control:
	var feld := r.get_global_rect()
	feld = Rect2(feld.position + Vector2(0, feld.size.y * 0.35), Vector2(feld.size.x, feld.size.y * 0.6))
	for b in r.find_children("*", "Control", true, false):
		var k := b as Control
		var tippt := (k is BaseButton and not (k as BaseButton).disabled) or not k.get_signal_connection_list("gui_input").is_empty()
		if tippt and k.is_visible_in_tree() and feld.has_point(k.get_global_rect().get_center()): return k
	return null

func schleier(w: Node) -> int:
	# Rueckfrage.schleier (0,82); 557 Stil B: dieselben Schleier deckend schwarz oder 0,86/0,97 (menue.gd, ladenschirm.gd, spielstaende.gd)
	return w.find_children("*", "ColorRect", true, false).filter(func(c): var f := (c as ColorRect).color; return f.r == 0.0 and f.g == 0.0 and f.b == 0.0 and f.a >= 0.8 and (c as ColorRect).mouse_filter == Control.MOUSE_FILTER_STOP).size()

func schirm(name_: String, w: Node) -> void:
	await warte(4)
	var r := rolle_von(w)
	pruefe(r != null, "%s: rollende Liste gefunden" % name_)
	if r == null: return
	var b := knopf_in(r)
	pruefe(b != null, "%s: Knopf in der Liste gefunden" % name_)
	if b == null: return
	var zaehler := [0]
	for k in w.find_children("*", "BaseButton", true, false): (k as BaseButton).pressed.connect(func(): zaehler[0] += 1)
	var vorher := r.scroll_vertical
	var fenster := schleier(w)
	await wische(b.get_global_rect().get_center(), 10, -30.0)
	pruefe(r.scroll_vertical > vorher + 100, "%s: Wischen auf „%s“ rollt (%d -> %d)" % [name_, b.get("text") if b.get("text") else b.get_class(), vorher, r.scroll_vertical])
	pruefe(zaehler[0] == 0 and schleier(w) == fenster, "%s: Wischen loest keinen Knopf aus und oeffnet kein Fenster (%d, %d)" % [name_, zaehler[0], schleier(w) - fenster])

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	pruefe(root.get_node_or_null("Wischen") != null, "Baustein Wischen geladen")
	# Probeliste: Wischen, kleines Zittern, Tippen
	var rolle := ScrollContainer.new()
	rolle.position = Vector2.ZERO; rolle.size = Vector2(1080, 1200)
	root.add_child(rolle)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rolle.add_child(box)
	for i in 40: box.add_child(Stil.knopf("Knopf %d" % i, func(): gedrueckt += 1))
	await warte(5)
	await wische((box.get_child(3) as Control).get_global_rect().get_center(), 10, -30.0)
	pruefe(rolle.scroll_vertical > 100, "Probeliste: Wischen auf einem Knopf rollt (scroll %d)" % rolle.scroll_vertical)
	pruefe(gedrueckt == 0, "Probeliste: Wischen loest den Knopf nicht aus (%d)" % gedrueckt)
	var c: Control = null
	for k in box.get_children():
		if rolle.get_global_rect().grow(-50).has_point((k as Control).get_global_rect().get_center()): c = k; break
	var vor := rolle.scroll_vertical
	await wische(c.get_global_rect().get_center(), 2, -5.0)   # Zittern 10 px (knapp 4 dp): bleibt ein Tippen
	pruefe(gedrueckt == 1, "Probeliste: Tippen mit Zittern loest aus (%d)" % gedrueckt)
	pruefe(rolle.scroll_vertical == vor, "Probeliste: Zittern rollt nicht (%d -> %d)" % [vor, rolle.scroll_vertical])
	await tippe(c.get_global_rect().get_center())
	pruefe(gedrueckt == 2, "Probeliste: Tippen loest aus (%d)" % gedrueckt)
	rolle.queue_free()
	await warte()
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	# Testmenue: Kampfliste (Chef: „unter Kampfbeschwören … wenn ich jetzt auf Fledermäuse klicke“)
	var z := Zustand.new()
	z.name = "Mira"; z.gold = 100
	var hw := BrsHeld.fuer_spiel("Mira", "Mensch", "Wachsoldat", z.neue_uid)
	for i in 30: z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(70 + i), z.neue_uid, 2, "COMMON", ""))
	z.dazu("potion", 3); z.dazu("herbs", 2); z.dazu("wolf_pelt", 2)
	Testmodus.an = true; Testmodus.geladen = true
	var m := Menue.new(hw, z)
	ebene.add_child(m)
	m.reiter = "test"; m.baue()
	await schirm("Testmenü", m)
	m.reiter = "tasche"; m.baue()
	await schirm("Spielmenü Tasche", m)
	var zeile := knopf_in(rolle_von(m))
	var offen := schleier(m)
	await tippe(zeile.get_global_rect().get_center())
	pruefe(schleier(m) == offen + 1, "Spielmenü Tasche: Tippen auf eine Zeile oeffnet ihr Fenster (%d)" % (schleier(m) - offen))
	m.queue_free()
	var eb := ErschaffungBrs.new()
	ebene.add_child(eb)
	await schirm("Erschaffung BRS", eb)
	eb.queue_free()
	var l := LadenSchirm.new(hw, z, Laden.new(["potion", "remedy", "herbs", "torch", "rations", "smoke_bundle", "holy_water"], false))
	ebene.add_child(l)
	await warte()
	l.seite = "verkaufen"; l.baue()
	await schirm("Laden Verkaufen", l)
	l.queue_free()
	Hauptmenue.vorspann_gezeigt = true
	var hm := Hauptmenue.new(null)
	ebene.add_child(hm)
	await warte()
	hm.ueber()
	await warte()
	for b in hm.find_children("*", "Button", true, false):
		if String(b.text).begins_with("LIZENZEN"): (b as Button).pressed.emit(); break
	await schirm("Lizenzen", hm)
	print("WISCHEN571 ", "gut" if fehler == 0 else "FALSCH %d" % fehler)
	quit(1 if fehler else 0)
