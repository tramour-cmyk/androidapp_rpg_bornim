extends SceneTree
# 519 (Chef 03.11., 23:13, Build 249): Ausruestung, das Fenster eines Gegenstands („Göttlicher Ring des Eisernen Richters“)
# ragte rechts hinaus: Name, Spalte „Neu“, Knoepfe abgeschnitten. Wie alt (Dialogs.kt ConfirmDialog, GearUi.kt GearDetails):
# Kasten 16 dp vom Rand (630: ohne Kasten, Spalte 24 dp vom Rand, 549a), Titel bricht um, Knoepfe teilen sich die Breite (PixelButton: zwei Zeilen, sonst kleiner), alles sichtbar.
# Dazu (Zu 519, Sokrates): ein Bonus, den die Obergrenze des Kapitels schluckt, steht als Hinweis da (GearCompare.kt „limit“).
# Ohne Bildbefehl. Aufruf: im Ordner godot mit -s res://tests/fenster_519.gd -> „FENSTER519 n Fehler“

const KH := preload("res://tests/knopf_hilfe.gd")
var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func alle(n: Node, art: String, aus: Array) -> Array:
	if n.is_class(art): aus.append(n)
	for c in n.get_children(): alle(c, art, aus)
	return aus

func text_breite(c: Control, t: String) -> float:
	var f := c.get_theme_font("font"); var g := c.get_theme_font_size("font_size")
	return f.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, g).x

func ring(z: Zustand, saat: int, rolls: Array) -> Dictionary:
	return {"uid": z.neue_uid.call(), "base": "ring", "rarity": "DIVINE", "ilvl": 9, "plus": 0, "rolls": rolls, "unique": null, "name_seed": saat}

func pruefe_fenster(m: Menue, was: String) -> void:
	var schleier: Control = m.get_child(m.get_child_count() - 1)
	var vp := m.get_viewport_rect()
	# 630 (549a): ohne Kasten; die Inhaltsspalte „Fenster“ 24 dp vom Rand (Breite Schirm minus 48 dp), Knoepfe darin
	var kasten: Control = schleier.find_child("Fenster", true, false)
	pruefe(kasten != null, "%s: keine Spalte „Fenster“" % was)
	if kasten == null: return
	var r := kasten.get_global_rect()
	pruefe(r.position.x >= 0 and r.end.x <= vp.size.x + 0.5, "%s: Fenster ragt hinaus: %s, Schirm %s" % [was, r, vp.size])
	pruefe(absf(r.position.x - 24 * AktionsKnopf.DP) < 2 and absf(vp.size.x - r.end.x - 24 * AktionsKnopf.DP) < 2, "%s: Fenster nicht 24 dp vom Rand: %s" % [was, r])
	pruefe(alle(schleier, "PanelContainer", []).all(func(p): return (p as PanelContainer).get_theme_stylebox("panel") is StyleBoxEmpty), "%s: Rahmen im Fenster" % was)
	for l in alle(kasten, "Label", []):
		var lr: Rect2 = l.get_global_rect()
		pruefe(lr.end.x <= r.end.x + 0.5, "%s: Text „%s“ ragt rechts hinaus (%.0f > %.0f)" % [was, l.text, lr.end.x, r.end.x])
		if l.autowrap_mode == TextServer.AUTOWRAP_OFF:
			pruefe(text_breite(l, l.text) <= lr.size.x + 0.5, "%s: Text „%s“ ohne Umbruch zu breit" % [was, l.text])
	for b in KH.alle(kasten):
		var br: Rect2 = b.get_global_rect()
		pruefe(br.end.x <= r.end.x + 0.5, "%s: Knopf „%s“ ragt rechts hinaus" % [was, KH.text(b)])
		var tx := b.find_child("Text", true, false) as Label
		if tx == null: continue
		var g := tx.get_theme_font_size("font_size")
		pruefe(g >= int(round(13 * Stil.SP)), "%s: Knopf „%s“ unter 13 sp" % [was, tx.text])
		# zwei Zeilen hoechstens, kein Wort gebrochen: jedes Wort passt in den Knopf
		for w in tx.text.split(" "): pruefe(text_breite(tx, w) <= br.size.x + 0.5, "%s: Wort „%s“ im Knopf gebrochen" % [was, w])
		pruefe(tx.get_line_count() <= 2, "%s: Knopf „%s“ mehr als zwei Zeilen" % [was, tx.text])

func _lauf() -> void:
	Menue.entwurf = ""   # 557: prüft den Kasten des alten Fensters; B ohne Kasten prüft gruppe_mass_557 (auch 360 dp)
	root.size = Vector2i(1080, 2340)   # Handy hochkant wie das Projekt (ohne Fenster sonst 1152 × 648, gestreckt breit)
	await process_frame
	print("Schirm ", root.get_visible_rect().size)
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	z.name = "Thora"; z.gold = 100
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	# die Saat, die „Göttlicher Ring des Eisernen Richters“ ergibt (Aufnahme des Chefs)
	var saat := -1
	for s in 200:
		if Beute.name(ring(z, s, [])).ends_with("Eisernen Richters"): saat = s; break
	pruefe(saat >= 0, "kein Ring „… des Eisernen Richters“")
	var alt := ring(z, saat + 1, [["DEX", 2], ["STR", 2]])
	hw.anlegen(alt)
	var neu := ring(z, maxi(saat, 0), [["ALL_STATS", 1], ["DEX", 2], ["CHA", 2]])
	z.beutel.append(neu)
	var m := Menue.new(hw, z)
	root.add_child(m)
	await process_frame
	m.frage_stueck(neu)
	for i in 3: await process_frame
	pruefe_fenster(m, Beute.name(neu))
	var texte := PackedStringArray(alle(m.get_child(m.get_child_count() - 1), "Label", []).map(func(l): return (l as Label).text))
	print("Fenster: ", " | ".join(texte))
	# Zu 519: ein Bonus, den der Deckel des Kapitels schluckt, bekommt einen Hinweis wie alt
	var kopie := hw.kopie(); kopie.anlegen(neu)
	var geschluckt := ["STR", "DEX", "CON", "INT", "WIS", "CHA"].filter(func(a):
		return BrsHeld.gesamt(neu, a) + BrsHeld.gesamt(neu, "ALL_STATS") > 0 and kopie.ausruestung_gedeckelt(a) and kopie.wert(a) <= hw.wert(a))
	print("geschluckt: %s" % [geschluckt])
	if not geschluckt.is_empty():
		pruefe(" ".join(texte).contains("Obergrenze für dieses Kapitel"), "Bonus vom Deckel geschluckt (%s), aber kein Hinweis" % [geschluckt])
	# ein Schwert hat drei Knoepfe (Anlegen, Nebenhand, Wegwerfen) und Abbrechen
	var schwert := Beute.erzeuge_mit_uid(KotlinZufall.new(5), z.neue_uid, 9, "DIVINE", "FIGHTER")
	z.beutel.append(schwert)
	m.get_child(m.get_child_count() - 1).free()
	m.frage_stueck(schwert)
	for i in 3: await process_frame
	pruefe_fenster(m, Beute.name(schwert))
	print("FENSTER519 %d Fehler" % fehler)
	quit(1 if fehler else 0)
