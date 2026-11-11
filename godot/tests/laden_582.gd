extends SceneTree
# 582 (Abgleich 512b, Pruefer 05.11., 08:17): Laden wie alt. Prueft ohne Bild: Vorraete ohne Langtext (944: auch ohne die Kurzangabe „heilt 2W4+2“, ShopScreen.kt
# 244) und in der Farbe ihrer Seltenheit (Items.kt); Ausruestung mit Platz in der Unterzeile (Gear.listLine); ▲/▼ als
# eigenes Zeichen gruen/rot, nicht im Namen (GearUi.kt 149); Mengen- und Braukasten mit Seltenheit, ohne Würfel (944) (Dialogs.ItemDetails).
# Aufruf: im Ordner godot mit -s res://tests/laden_582.gd -> „LADEN582 n Fehler“

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
	return PackedStringArray(alle(n, Label, []).map(func(x): return (x as Label).text.replace("\u00a0", " ")))   # 557 Vorlage 2: fest verbundene Wörter

func farbe(l: Label) -> Color: return l.get_theme_color("font_color")

func label(n: Node, t: String) -> Label:
	for x in alle(n, Label, []):
		if (x as Label).text.replace("\u00a0", " ") == t: return x
	return null

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	pruefe(String(Laden.ding("greater_potion").get("seltenheit", "")) == "UNCOMMON", "texte.json: Seltenheit fehlt (core TextExport)")
	var z := Zustand.new()
	z.name = "Thora"; z.gold = 500
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var laden := Laden.new(["potion", "greater_potion", "stamina_potion"], false)
	var l := LadenSchirm.new(hw, z, laden)
	ebene.add_child(l)
	await process_frame
	var t := texte(l.inhalt)
	var wuerfel := RegEx.create_from_string("\\d+[Wd]\\d+")     # 944 (t276.5): nie ein Würfeltext, die Wirkung sagt die Meldung
	pruefe(wuerfel.search(" ".join(t)) == null and not " ".join(t).contains("heilt"), "Würfeltext in der Liste: %s" % [t])
	pruefe(not Sprache.t(Laden.ding("potion")["info"]) in t, "Langtext steht in der Liste")
	var gross := label(l.inhalt, Laden.name("greater_potion"))
	pruefe(gross != null and farbe(gross) == Color(Menue.SELTEN["UNCOMMON"]), "Großer Heiltrank nicht in der Farbe „ungewöhnlich“")

	# Mengenkasten: Seltenheit in ihrer Farbe, Wirkung, Langtext
	l.menge("greater_potion", true, 1)
	await process_frame
	var kasten: Control = l.get_child(l.get_child_count() - 1)
	var kt := texte(kasten)
	var sel := String(Sprache.t(BrsHeld.daten()["seltenheiten"]["UNCOMMON"]["name"]))
	var sl := label(kasten, sel)
	pruefe(sl != null and farbe(sl) == Color(Menue.SELTEN["UNCOMMON"]), "Mengenkasten ohne Seltenheit „%s“: %s" % [sel, kt])
	pruefe(wuerfel.search(" ".join(kt)) == null and not " ".join(kt).contains("heilt"), "Würfeltext im Mengenkasten: %s" % [kt])     # 944
	pruefe(Sprache.t(Laden.ding("greater_potion")["info"]) in kt, "Mengenkasten ohne Langtext")
	kasten.queue_free()

	# Verkaufen: Ausruestung mit Platz, Urteil als eigenes Zeichen
	var w := KotlinZufall.new(582)
	var kappe := Beute.wuerfle(z.neue_uid(), "leather_cap", 1, "UNCOMMON", w)
	z.beutel.append(kappe)
	var dolch := Beute.wuerfle(z.neue_uid(), "dagger", 1, "COMMON", w)   # Pruefer 08:17: „▼ Dolch“ war gruen
	z.beutel.append(dolch)
	l.seite = "verkaufen"; l.baue()
	await process_frame
	var zeile := Beute.listen_zeile(kappe)
	pruefe(zeile in texte(l.inhalt), "Unterzeile ohne Platz: „%s“ fehlt" % zeile)
	pruefe(zeile.contains("Kopf"), "Listenzeile der Lederkappe ohne „Kopf“: %s" % zeile)
	var name_ := label(l.inhalt, Beute.name(kappe))
	pruefe(name_ != null, "Name der Kappe ohne Zeichen davor fehlt: %s" % [texte(l.inhalt)])
	var u = Vergleich.von(hw, dolch).urteil()
	var urteile := alle(l.inhalt, Label, []).filter(func(x): return x.name == "Urteil")
	if u == 1 or u == -1:
		pruefe(urteile.size() == 1, "Urteil fehlt (%s)" % u)
		if urteile.size() == 1:
			pruefe(urteile[0].text == ("▲" if u == 1 else "▼"), "Zeichen falsch: %s" % urteile[0].text)
			pruefe(farbe(urteile[0]) == (LadenSchirm.AUF if u == 1 else Stil.WARN), "Zeichen nicht grün/rot")
	else:
		print("LADEN582 Hinweis: Kappe ohne Urteil (%s), Zeichen nicht geprüft" % u)
	print("LADEN582 %d Fehler" % fehler)
	quit(1 if fehler else 0)
