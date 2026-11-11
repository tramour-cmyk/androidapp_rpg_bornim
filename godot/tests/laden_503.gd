extends SceneTree
# 503 (Chef 03.11., 07:40, Build 204): Laden, Verkaufen: der Knopf „Gewöhnliche verkaufen“ war 0 breit (clip_text mit SHRINK_BEGIN) und
# zeigte keinen Text. Jetzt: Knopf so breit wie sein Text; die Rueckfrage wie ShopScreen.kt 258–276 (Titel, „n Gegenstände:“ als
# MenuHead, Namen matt, „Verkaufen · Preis“, „Abbrechen“ links und „Verkaufen · Preis“ rechts in einer Reihe wie Dialogs.kt). Dazu die Knoepfe der Karte (kartenreiter.gd) mit demselben Fehler.
# Ohne Bild. Aufruf: im Ordner godot mit -s res://tests/laden_503.gd -> „LADEN503 n Fehler“

const KH := preload("res://tests/knopf_hilfe.gd")
var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func knoepfe(n: Node, aus: Array) -> Array:
	if n is Button: aus.append(n)
	for c in n.get_children(): knoepfe(c, aus)
	return aus

func labels(n: Node, aus: Array) -> Array:
	if n is Label: aus.append(n)
	for c in n.get_children(): labels(c, aus)
	return aus

func breit_genug(b: Button) -> bool:
	var f := b.get_theme_font("font"); var g := b.get_theme_font_size("font_size")
	var w := f.get_string_size(b.text, HORIZONTAL_ALIGNMENT_LEFT, -1, g).x
	return b.size.x >= w and b.get_combined_minimum_size().x >= w

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	z.name = "Thora"; z.gold = 100
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	for i in 3: z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(70 + i), z.neue_uid, 2, "COMMON", ""))
	z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(90), z.neue_uid, 2, "RARE", ""))
	var gew := z.beutel.filter(func(g): return Laden.ausruestung_verkaeuflich(g) and String(g["rarity"]) == "COMMON").size()
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var l := LadenSchirm.new(hw, z, Laden.new(["potion"], false))
	ebene.add_child(l)
	await process_frame
	l.seite = "verkaufen"; l.baue()
	await process_frame
	await process_frame
	var knopf: Button = null
	for b in knoepfe(l.inhalt, []):
		if (b as Button).text == "GEWÖHNLICHE VERKAUFEN": knopf = b
	pruefe(knopf != null, "Knopf „Gewöhnliche verkaufen“ fehlt")
	if knopf:
		pruefe(breit_genug(knopf), "Knopf schmaler als sein Text: %.0f" % knopf.size.x)
		pruefe(not knopf.clip_text, "Knopf schneidet den Text ab")
		knopf.pressed.emit()
		await process_frame
		var t := PackedStringArray(labels(l, []).map(func(x): return (x as Label).text))
		pruefe("ALLE GEWÖHNLICHEN VERKAUFEN?" in t, "Titel der Rueckfrage fehlt: %s" % [t])
		pruefe(Laden.anzahl_gegenstaende(gew, true).to_upper() in t, "Zeile „%d Gegenstände:“ als MenuHead fehlt" % gew)
		pruefe(Laden.anzahl_gegenstaende(1, true) == "1 Gegenstand:" and Laden.anzahl_gegenstaende(2, true) == "2 Gegenstände:", "699: Einzahl bei einem Stück")
		# Dialogs.kt 99–104: eine Reihe, „Abbrechen“ links, „Verkaufen · Preis“ rechts, gleich breit, Text ganz im Knopf und im Bild
		# 630 (549a): ohne Kasten, „‹ ABBRECHEN“ links, „VERKAUFEN · PREIS ›“ rechts in einer Reihe (knopfzeile), je die halbe Breite
		var reihe: HBoxContainer = null
		var vk := KH.finde(l, "VERKAUFEN · ", true)
		if vk and vk.get_parent() is HBoxContainer: reihe = vk.get_parent()
		pruefe(reihe != null, "Knopf „Verkaufen · Preis“ nicht in einer Reihe")
		if reihe:
			await process_frame
			var ks := KH.alle(reihe)
			pruefe(ks.size() == 2 and KH.text(ks[0]) == "ABBRECHEN" and KH.text(ks[1]).begins_with("VERKAUFEN · "),
				"Reihe nicht „Abbrechen | Verkaufen“: %s" % [ks.map(func(b): return KH.text(b))])
			if ks.size() == 2:
				pruefe(absf(ks[0].size.x - ks[1].size.x) < 2.0, "Knoepfe ungleich breit: %.0f / %.0f" % [ks[0].size.x, ks[1].size.x])
				for b in ks:
					var tx := b.find_child("Text", true, false) as Label
					pruefe(tx.get_global_rect().end.x <= b.get_global_rect().end.x + 1.0 and tx.get_global_rect().position.x >= b.get_global_rect().position.x - 1.0, "%s schmaler als sein Text" % KH.text(b))
					pruefe(b.get_global_rect().end.x <= l.get_viewport_rect().size.x, "%s ragt aus dem Bild" % KH.text(b))
					# 549a: Knopfschrift 15 sp, zu lang kleiner, nie unter 13 sp
					var g := tx.get_theme_font_size("font_size")
					pruefe(g >= int(round(13 * Stil.SP)) and g <= int(round(15 * Stil.SP)), "Knopfschrift %d nicht 13–15 sp" % g)
	print("LADEN503 %d Fehler" % fehler)
	quit(1 if fehler else 0)
