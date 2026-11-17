extends SceneTree
# 525 (Abgleich 512, Chef 04.11., 00:31 „Kann kenntlich gemacht werden, was für einen Trank fehlt …“): Laden, Morwen, Rast wie alt
# und besser. Prueft ohne Bild: Brauen je Zutat „hat/braucht“ (Fehlendes in Warnfarbe), „Fehlt: …“, „Reicht für n×“, Bestand,
# Kraeuterhinweis; Braukasten mit Bild, Menge und „Alle“; mehrmals brauen; Einzahl „1 gewöhnlicher Gegenstand verkauft.“;
# Zurueckkaufen in der Farbe der Seltenheit; „Alle“ im Mengenkasten markiert; Rowena kauft rohes Fleisch an der Theke.
# Aufruf: im Ordner godot mit -s res://tests/laden_525.gd -> „LADEN525 n Fehler“

const KH := preload("res://tests/knopf_hilfe.gd")
var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

func alle(n: Node, art, aus: Array) -> Array:
	if is_instance_of(n, art): aus.append(n)
	for c in n.get_children(): alle(c, art, aus)
	return aus

func texte(n: Node) -> PackedStringArray:
	return PackedStringArray(alle(n, Label, []).map(func(x): return (x as Label).text.replace("\u00a0", " ")))

# Stil.knopf(…, gewaehlt): Schrift Veil.bright
func gewaehlt(b: Button) -> bool: return b.get_theme_color("font_color") == Stil.BRIGHT

func farbe(l: Label) -> Color: return l.get_theme_color("font_color")

func rezept(id: String) -> Dictionary:
	for r in Laden.rezepte():
		if String(r["ergebnis"]) == id: return r
	return {}

func _lauf() -> void:
	LadenSchirm.entwurf_b = ""   # 557: dieser Test prüft die Brauenliste im alten Aussehen; B prüft gruppe_mass_557
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	z.name = "Thora"; z.gold = 12
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	z.dazu("herbs", 5)
	z.dazu("potion", 2)
	var heil := rezept("potion")
	var gross := rezept("greater_potion")
	pruefe(not heil.is_empty() and not gross.is_empty(), "Rezepte fehlen")

	# Regeln: wie oft, was fehlt, mehrmals brauen
	pruefe(Laden.wie_oft(z, heil) == 2, "Heiltrank: 5 Kraeuter, 12 Gold reicht 2×, nicht %d" % Laden.wie_oft(z, heil))
	pruefe(Laden.wie_oft(z, gross) == 0, "Grosser Heiltrank ohne Fledermausfluegel reicht 0×")
	var f := Laden.fehlt(z, gross)
	pruefe(f.contains("1× ") and f.contains("3 Gold"), "Fehlt beim grossen Heiltrank: „%s“" % f)
	pruefe(Laden.gewoehnliche_text(1) == "1 gewöhnlicher Gegenstand verkauft.", "Einzahl: %s" % Laden.gewoehnliche_text(1))
	pruefe(Laden.gewoehnliche_text(3) == "3 gewöhnliche Gegenstände verkauft.", "Mehrzahl: %s" % Laden.gewoehnliche_text(3))

	# Schirm: Seite Brauen
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var laden := Laden.new(["herbs", "potion"], true)
	var l := LadenSchirm.new(hw, z, laden)
	ebene.add_child(l)
	await process_frame
	l.seite = "brauen"; l.baue()
	await process_frame
	var t := texte(l.inhalt)
	pruefe(Sprache.t(Laden.KRAEUTER) in t, "Kraeuterhinweis fehlt")
	pruefe("Reicht für 2×" in t, "„Reicht für 2×“ fehlt: %s" % [t])
	pruefe("Im Besitz: 2" in t, "Bestand des Heiltranks fehlt")
	var reihen := alle(l.inhalt, HBoxContainer, []).filter(func(h): return h.has_meta("rezept"))
	pruefe(reihen.size() == Laden.rezepte().size(), "je Rezept eine Zeile: %d" % reihen.size())
	for h in reihen:
		var r := rezept(String(h.get_meta("rezept")))
		var zt := alle(h, Label, []).filter(func(x): return x.has_meta("zutat"))
		pruefe(zt.size() == r["zutaten"].size() + (1 if int(r["gold"]) > 0 else 0), "%s: Zutaten und Gold nicht je ein Feld" % r["ergebnis"])
		pruefe(alle(h, TextureRect, []).size() >= 1 + r["zutaten"].size(), "%s: Bild je Zutat fehlt" % r["ergebnis"])
		for x in zt:
			var id := String(x.get_meta("zutat"))
			var genug := z.gold >= int(r["gold"]) if id == "gold" else z.anzahl(id) >= int(r["zutaten"][id])
			pruefe((farbe(x) == Spielstaende.mangel()) == (not genug), "%s/%s: Farbe passt nicht zu hat/braucht (%s)" % [r["ergebnis"], id, x.text])
		var ok := Laden.wie_oft(z, r) > 0
		var fehlt_da := Array(texte(h)).any(func(s): return s.begins_with("Fehlt: "))
		pruefe(fehlt_da == (not ok), "%s: „Fehlt:“ nur, wenn nicht brauar" % r["ergebnis"])
		pruefe((h.get_child(0) as CanvasItem).modulate.a < 1.0 if not ok else (h.get_child(0) as CanvasItem).modulate.a == 1.0, "%s: matt nur, wenn nicht brauar" % r["ergebnis"])

	# Braukasten: Bild, Menge, „Alle“ markiert, Brauen ×2
	l.braukasten(heil, 1)
	await process_frame
	var kasten: Control = l.get_child(l.get_child_count() - 1)
	pruefe(kasten.find_child("DingBild", true, false) != null, "Braukasten ohne Bild")
	var alle_b := KH.finde(kasten, "ALLE")   # 630: Woerter und Knoepfe ohne Kasten (549a)
	pruefe(alle_b != null, "Braukasten ohne „Alle“")
	if alle_b:
		KH.tippe(alle_b)
		await process_frame
		kasten = l.get_child(l.get_child_count() - 1)
		var brau := KH.finde(kasten, "BRAUEN", true)
		pruefe(KH.gewaehlt(KH.finde(kasten, "ALLE")), "„Alle“ nicht markiert")
		pruefe(not KH.gewaehlt(KH.finde(kasten, "×1")), "„×1“ markiert neben „Alle“")
		pruefe(brau != null and KH.text(brau) == "BRAUEN ×2", "Knopf nach „Alle“: %s" % (KH.text(brau) if brau else "fehlt"))
		pruefe("Im Besitz: 2 → 4" in texte(kasten), "Bestand vorher → nachher fehlt")
		pruefe("12 Gold → 2 Gold" in texte(kasten), "Gold vorher → nachher fehlt: %s" % [texte(kasten)])
	var vorher := z.anzahl("potion")
	var satz := laden.braue_mehr(z, hw, heil, 2, func(): return 1.0)
	pruefe(z.anzahl("potion") == vorher + 2 and z.anzahl("herbs") == 1 and z.gold == 2, "zweimal brauen: Trank %d, Kraeuter %d, Gold %d" % [z.anzahl("potion"), z.anzahl("herbs"), z.gold])
	pruefe(satz.contains("×2"), "Meldung nennt die Zahl nicht: %s" % satz)
	pruefe(laden.braue_mehr(z, hw, heil, 1) == Sprache.l("missing"), "ohne Zutaten brauen geht")

	# Zurueckkaufen in der Farbe der Seltenheit; Mengenkasten „Alle“ markiert
	z.gold = 100
	laden.verkaufe(z, hw, "potion", 1)
	l.seite = "verkaufen"; l.baue()
	await process_frame
	var name_ := Laden.name("potion")
	var rk := alle(l.inhalt, Label, []).filter(func(x): return x.text == name_)
	pruefe(not rk.is_empty() and farbe(rk[0]) == l.farbe_ding("potion"), "Zurueckkaufen nicht in der Farbe der Seltenheit")
	l.menge("potion", false, 3, true)
	await process_frame
	kasten = l.get_child(l.get_child_count() - 1)
	for w in ["ALLE", "×1"]:
		var b := KH.finde(kasten, w)
		pruefe(b != null and KH.gewaehlt(b) == (w == "ALLE"), "Markierung im Mengenkasten: %s" % w)

	# Rast an der Theke: Rowena kauft rohes Fleisch
	z.dazu("raw_meat", 3)
	var gold := z.gold
	var p := Rast.fleisch_preis(z, hw)
	pruefe(p == 3 * Laden.verkaufspreis(hw, "raw_meat") and p > 0, "Fleischpreis %d" % p)
	pruefe(Rast.fleisch_verkaufen(z, hw) == Sprache.r("meatThanks"), "Rowenas Dank fehlt")
	pruefe(z.anzahl("raw_meat") == 0 and z.gold == gold + p, "Fleisch nicht verkauft: %d, Gold %d" % [z.anzahl("raw_meat"), z.gold])
	pruefe(Rast.fleisch_verkaufen(z, hw) == "", "ohne Fleisch verkauft")
	print("LADEN525 %d Fehler" % fehler)
	quit(1 if fehler else 0)
