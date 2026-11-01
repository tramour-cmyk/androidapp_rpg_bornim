extends SceneTree
# 416.3 Probe mit Bild am Rechner (nicht im Bau): Laden (Kaufen, Verkaufen, Menge), Morwens Huette (Brauen) und Anschlagbrett
# bildschirmfuellend; Held wie die alte Vorschau HAENDLER=1 (Elfenmagierin Stufe 9, 640 Gold, je drei Traenke, Felle, Hauer, Kraeuter),
# Ware wie Story.shopStock. PNG nach OBERFLAECHE_AUS. Aufruf: im Ordner godot, mit Fenster (xvfb-run), --resolution 1080x2340

func _initialize() -> void:
	_lauf.call_deferred()

func _bild(n: String) -> void:
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	var aus := OS.get_environment("OBERFLAECHE_AUS")
	if aus == "": aus = OS.get_user_data_dir()
	root.get_texture().get_image().save_png(aus + "/" + n + ".png")
	print("BILD ", aus + "/" + n + ".png")

func _lauf() -> void:
	Sprache.lade()
	if Sprache.aktiv() != "de": Sprache.wechsle()
	var z := Zustand.new()
	z.name = "Thora"; z.gold = 640
	for id in ["potion", "remedy", "wolf_pelt", "boar_tusk", "herbs"]: z.dazu(id, 3)
	var hw := Heldwerte.erschaffe("Thora", "ELF", "WIZARD", {}, z.neue_uid)
	hw.ep_dazu(int(Heldwerte.regel("ep_fuer_stufe")[9]))
	for i in 8: z.beutel.append(Beute.erzeuge_mit_uid(KotlinZufall.new(40 + i), z.neue_uid, 9, ["COMMON", "UNCOMMON", "RARE", "VERY_RARE"][i % 4], "WIZARD" if i % 3 else ""))
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var waren := ["potion", "greater_potion", "superior_potion", "remedy", "stamina_potion", "spark_potion", "alchemist_fire", "holy_water"]
	var l := LadenSchirm.new(hw, z, Laden.new(waren, false))
	ebene.add_child(l)
	await _bild("4163_laden_kaufen")
	l.seite = "verkaufen"; l.baue()
	await _bild("4163_laden_verkaufen")
	l.seite = "kaufen"; l.baue()
	l.menge("potion", true, 2)
	await _bild("4163_laden_menge")
	l.queue_free()
	var m := LadenSchirm.new(hw, z, Laden.new(["potion", "remedy"], true))
	ebene.add_child(m)
	m.seite = "brauen"
	await process_frame
	m.baue()
	await _bild("4163_morwen_brauen")
	m.queue_free()
	var b := BrettSchirm.new(z)
	ebene.add_child(b)
	await _bild("4163_brett")
	quit(0)
