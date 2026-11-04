extends SceneTree
# 531 Film (Chef 04.11., 19:27: „es ist etwas schwer zu beurteilen, wie gut die Animation ist … Ich sehe bloß ein Bild“; Bewegung nur als
# Film, 381): Garrick an seinem Feuer im Flüsterwald mit der Spielkamera nah, Kaufkoerper mit Gesicht (475), Spiellicht.
#   1 Tag: ein Wolf jagt den Helden ans Feuer, Garrick nimmt die Fackel aus dem Feuer, dreht sich zum Tier, schwenkt, Fackel zurueck
#   2 Nacht: dasselbe
#   3-5 Ruhe aus dem Bestand (UAL Pro, held_klassen.py BEWEGUNGEN): am Boden sitzen und aufstehen, einnicken im Sitzen, hocken
# Oben je Abschnitt Nummer und Inhalt. Die Regeln laufen (Herde, Schutzort), nur die Ruhe 3-5 spielt die Bewegung von Hand.
# Aufruf: im Ordner godot: xvfb-run godot --rendering-driver opengl3 --path . --resolution 540x1170 --write-movie <datei>.avi
#   --fixed-fps 30 -s res://tests/garrick_film_531.gd
# Probebild (511): ohne --write-movie mit „-- --probebild=<datei>.png“: Abschnitt 1, Fackel oben (1,3 s der Abwehr), dann Ende

var spiel
var g: Leute
var titel: Label
var probebild := ""

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--probebild="): probebild = a.substr(12)
	_lauf.call_deferred()

func zeige(t: String) -> void:
	titel.text = t
	print("GARRICKFILM ", t)

func warte(s: float) -> void:
	var n := int(s * 30.0)
	for i in n:
		await process_frame
		if spiel.ui.textfeld: spiel.ui.textfeld.visible = false

func _lauf() -> void:
	if not FileAccess.file_exists("res://daten/forest.bin"):
		print("GARRICKFILM ohne daten/forest"); quit(1); return
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 10 * 60
	spiel.betrete("forest", Vector2i(10, 10), "RIGHT")
	for i in 5: await process_frame
	spiel.ui.mess.visible = false
	spiel.ui.oben.visible = false
	for l in spiel.leute.get_children():
		if l is Leute and String(l.daten.get("id", "")) == "garrick": g = l
	if g == null or spiel.herde == null:
		print("GARRICKFILM kein Garrick oder keine Herde"); quit(1); return
	var cl := CanvasLayer.new()
	cl.layer = 100
	root.add_child(cl)
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.72)
	bg.position = Vector2.ZERO
	bg.size = Vector2(540, 118)
	cl.add_child(bg)
	titel = Label.new()
	titel.position = Vector2(14, 10)
	titel.size = Vector2(512, 100)
	titel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titel.add_theme_font_size_override("font_size", 22)
	titel.add_theme_color_override("font_color", Color(0.93, 0.8, 0.45))
	cl.add_child(titel)
	spiel.kamera.ziel = g
	spiel.kamera.nah_fern()
	spiel.kamera.springe()
	var h: Herde = spiel.herde
	h.kampf.disconnect(spiel._kampf_auf_karte)
	h.kampf.connect(func(_m, _e, _w): print("GARRICKFILM FEHLER Kampf am Feuer"))
	zeige("531 · 1 Tag: ein Wolf jagt den Helden an Garricks Feuer. Garrick nimmt die Fackel aus dem Feuer, dreht sich zum Tier, schwenkt sie, steckt sie zurück")
	await warte(2.0)
	await jagd(h)
	await warte(2.0)
	spiel.licht.umschalten()
	spiel.zustand.minuten = 23 * 60
	zeige("531 · 2 Nacht: dasselbe")
	await warte(2.5)
	await jagd(h)
	await warte(2.0)
	spiel.licht.umschalten()
	spiel.zustand.minuten = 10 * 60
	h.aus = true
	g.set_process(false)
	g.set_physics_process(false)
	var a: AnimationPlayer = g.anim
	var fehlt := []
	for n in ["Bodensitz_rein", "Bodensitz", "Bodensitz_raus", "Sitzen_rein", "Nicken", "Sitzen_raus", "Hocken"]:
		if a == null or not a.has_animation(n): fehlt.append(n)
	print("GARRICKFILM Bewegungen fehlen: %s" % [fehlt])
	zeige("531 · 3 Ruhe aus dem Bestand (UAL GroundSit): am Boden hinsetzen, sitzen, aufstehen")
	await warte(1.5)
	await spiele(a, ["Bodensitz_rein", "Bodensitz:4", "Bodensitz_raus", "Stehen:1"])
	zeige("531 · 4 Einnicken (UAL Sitting_Nodding): gemacht für einen Stuhl; am Feuer gibt es keinen Sitz, darum sitzt er in der Luft")
	await warte(1.0)
	await spiele(a, ["Sitzen_rein", "Nicken:7", "Sitzen_raus", "Stehen:1"])
	zeige("531 · 5 Hände wärmen: im Bestand nicht vorhanden. Nächstes im Bestand: Hocken (UAL Crouch_Idle) zum Feuer")
	await warte(1.0)
	await spiele(a, ["Hocken:6", "Stehen:1.5"])
	print("GARRICKFILM fertig")
	quit()

## n: Name, "Name:s" haelt eine Schleife s Sekunden; ohne Zeit bis zum Ende der Bewegung
func spiele(a: AnimationPlayer, folge: Array) -> void:
	for f in folge:
		var n := String(f).get_slice(":", 0)
		var s := float(String(f).get_slice(":", 1)) if ":" in String(f) else -1.0
		if a == null or not a.has_animation(n):
			print("GARRICKFILM fehlt ", n)
			continue
		a.play(n, 0.25)
		await warte(s if s > 0.0 else maxf(a.get_animation(n).length - 0.25, 0.3))

## ein Jaeger der Herde jagt den Helden von Osten an den Schutzort (wie garrick_531.gd)
func jagd(h: Herde) -> void:
	var jaeger: Streuner = null
	for s in h.liste:
		if s.temper() == "JAEGER" and jaeger == null: jaeger = s
		else: s.ruhig_bis = 1 << 40; s.jagt = false
	if jaeger == null:
		print("GARRICKFILM FEHLER kein Jaeger"); return
	var t := Vector2i(14, 10)
	if not spiel.karte.begehbar(t): t = Vector2i(15, 9)
	jaeger.kachel = t; jaeger.von = t; jaeger.heim = t + Vector2i(3, 0); jaeger.jagt = true; jaeger.naechst_ms = 0
	jaeger.ruhig_bis = 0
	jaeger.position = spiel.karte.kachel_pos(t)
	h.frieden_bis = 0
	var sah := false
	for i in 9 * 30:
		await process_frame
		spiel.ui.textfeld.visible = false
		if g.abwehr and g.abwehr.laeuft(): sah = true
		if probebild != "" and sah and g.abwehr.t >= 1.3:
			await RenderingServer.frame_post_draw
			root.get_viewport().get_texture().get_image().save_png(probebild)
			print("GARRICKFILM Probebild ", probebild)
			quit(); return
		if sah and not g.abwehr.laeuft(): break
	print("GARRICKFILM Abwehr %s" % ("gesehen" if sah else "FEHLT"))
