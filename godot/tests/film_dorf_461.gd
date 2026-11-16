extends SceneTree
# 461.1 Grundstand (Chef 01.11., 20:3x: „auf ein Niveau kriegen, dass wir von da aus alle weiteren Vorlagen machen“): Film des
# Helden im Dorf, wie er im Spiel läuft (spiel.tscn, Spielshader, Spielkamera), gegen LISTE-GRUNDSTAND-461.md (A, B, C, D, E).
# Je Held (Kämpfer Mann, Klerikerin Frau; Kaufkörper aus held_klassen.py, sonst der bisherige Held) drei Teile mit Titel oben:
#   1 Dorfplatz nah: Stehen (Atmen, Ruhebewegungen), Leute dahinter
#   2 Straße im Norden, Grundansicht: Stehen, Gehen, Anlaufen, Rennen, Loslassen (Abbremsen), Stehen (Atmen nach Anstrengung)
#   3 Wiese südlich des Flusses: Gehen an Rind, Ziegen, Hühnern und Bram vorbei (Platzwechsel, kein Durcheinander)
# Dazu je 0,1 s eine Zeile „DORF461 …“ (Bewegung, Tempo, Ort), damit der Prüfer messen kann (C2, D1, D4).
# Nur mit Fenster und --write-movie (Probelauf nach 389), im Ordner godot:
#   PROBE=461.1 xvfb-run -a godot --rendering-driver opengl3 --path . --resolution 540x1170 --write-movie <x.avi> --fixed-fps 30 \
#     -s res://tests/film_dorf_461.gd -- --dorffilm

const HELDEN := [["Wachsoldat", "m", "Wachsoldat"], ["Klosterschüler", "w", "Klosterschülerin"]]   # 870.4: Herkunft statt Klasse

var spiel
var titel: Label
var teil := ""
var t0 := 0


func _initialize() -> void:
	_lauf.call_deferred()


func _process(_dt: float) -> bool:
	if spiel != null and spiel.held != null and teil != "" and Engine.get_process_frames() % 3 == 0:
		var h = spiel.held
		print("DORF461 %s t=%.1f anim=%s tempo=%.2f kachel=%s pos=(%.2f, %.2f) rennt=%s" % [teil, (Engine.get_process_frames() - t0) / 30.0,
			h.anim.current_animation if h.anim else "-", h.tempo_jetzt, h.kachel, h.position.x, h.position.z, h.laeuft])
	return false


func warte(s: float) -> void:
	for i in int(s * 30.0):
		await process_frame


func abschnitt(name_: String, text: String) -> void:
	teil = name_
	t0 = Engine.get_process_frames()
	titel.text = text
	print("DORF461 %s Leute %s" % [name_, spiel.leute.get_children().map(func(l): return "%s %s" % [l.daten.get("id", "?"), l.kachel])])


func _lauf() -> void:
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var ebene := CanvasLayer.new()
	ebene.layer = 60
	root.add_child(ebene)
	titel = Label.new()
	titel.add_theme_font_size_override("font_size", 30)
	titel.add_theme_color_override("font_color", Color(0.96, 0.93, 0.85))
	titel.add_theme_color_override("font_outline_color", Color.BLACK)
	titel.add_theme_constant_override("outline_size", 8)
	titel.position = Vector2(24, 90)
	ebene.add_child(titel)
	for hd in HELDEN:
		var name_held: String = hd[2]
		spiel.zustand.aussehen = {"geschlecht": hd[1]}
		spiel.werte = BrsHeld.fuer_spiel(name_held, "Mensch", hd[0], spiel.zustand.neue_uid)
		spiel.betrete("village", Vector2i(19, 13), "DOWN")
		for i in 5: await process_frame
		spiel.ui.mess.visible = false
		spiel.ui.oben.visible = false
		spiel.ui.leiste.visible = false
		spiel.ui.textfeld.visible = false
		spiel.held.stoesst.connect(func(k): print("DORF461 %s stoesst %s: %s" % [teil, k, spiel.held.leute.filter(func(l): return l.kachel == k).map(func(l): return l.daten.get("id", "?"))]))
		print("DORF461 Held %s %s Modell %s Waffengang '%s' Bewegungen %s" % [hd[0], hd[1], spiel.held.modell.name if spiel.held.modell else "-",
			spiel.held.waffengang, spiel.held.anim.get_animation_list() if spiel.held.anim else []])
		# 1 Dorfplatz nah: Stehen
		spiel.laufen_will = false
		spiel.kamera.nah = false
		spiel.kamera.nah_fern()
		spiel.kamera.springe()
		abschnitt("platz", "461 Grundstand · %s · Stehen, nah" % name_held)
		await warte(6.0)
		# 2 Straße im Norden: Stehen, Gehen, Rennen, Loslassen, Stehen
		spiel.kamera.nah = true
		spiel.kamera.nah_fern()
		spiel.held.setze(Vector2i(5, 8), "RIGHT")
		spiel.kamera.springe()
		abschnitt("strasse", "461 Grundstand · %s · Stehen" % name_held)
		await warte(2.0)
		titel.text = "461 Grundstand · %s · Gehen" % name_held
		spiel.held.richtung = Vector3(1, 0, 0)
		await warte(3.0)
		titel.text = "461 Grundstand · %s · Rennen" % name_held
		spiel.laufen_will = true
		await warte(3.5)
		titel.text = "461 Grundstand · %s · Loslassen, Stehen" % name_held
		spiel.held.richtung = Vector3.ZERO
		spiel.laufen_will = false
		await warte(5.0)
		# 2b wie nach Tippen: Rennen zu einem Ziel, am Ende des Wegs bremst er (Held.bremse)
		spiel.held.setze(Vector2i(4, 10), "RIGHT")
		spiel.kamera.springe()
		abschnitt("tippen", "461 Grundstand · %s · Rennen zum Ziel (Tippen)" % name_held)
		await warte(1.5)
		spiel.laufen_will = true
		print("DORF461 tippen Weg %s" % spiel.held.geh_zu(spiel.karte.kachel_pos(Vector2i(24, 10))))
		await warte(7.0)
		spiel.laufen_will = false
		titel.text = "461 Grundstand · %s · am Ziel, Stehen" % name_held
		await warte(3.0)
		# 3 Wiese: Gehen an Tieren und Leuten vorbei
		spiel.held.setze(Vector2i(21, 28), "RIGHT")
		spiel.kamera.springe()
		abschnitt("wiese", "461 Grundstand · %s · Gehen bei Tieren" % name_held)
		await warte(1.0)
		spiel.held.richtung = Vector3(1, 0, 0)
		await warte(6.0)
		spiel.held.richtung = Vector3.ZERO
		await warte(2.0)
		teil = ""
	print("DORF461 fertig")
	quit(0)
