extends SceneTree
# 758 A (Chef 09.11., 20:45: „Ja, so soll ein Vorgang aussehen … wir entscheiden uns für A“): Film von Borin am Tisch der Schenke,
# wie er im Spiel läuft (spiel.tscn, Spielshader, Spielkamera): er sitzt auf dem Hocker, Krug vor sich; der Held kommt heran (Borin
# wendet nur den Kopf), spricht ihn an (wende_zu), geht wieder; Borin blickt wieder zum Tisch, steht nie auf, dreht sich nicht.
# Dazu je 0,1 s eine Zeile „SITZ758 …“ (Bewegung, Lage des Beckens, Kopfwinkel).
# Nur mit Fenster und --write-movie (Probelauf 621 A), im Ordner godot:
#   PROBE=758 xvfb-run -a godot --rendering-driver opengl3 --path . --resolution 540x1170 --write-movie <x.avi> --fixed-fps 30 \
#     -s res://tests/film_sitzen_758.gd -- --sitzfilm

var spiel
var titel: Label
var borin
var t0 := 0


func _initialize() -> void:
	_lauf.call_deferred()


func _process(_dt: float) -> bool:
	if borin != null and is_instance_valid(borin) and Engine.get_process_frames() % 3 == 0:
		var k = borin.kopf_dreher
		print("SITZ758 t=%.1f anim=%s sitzt=%s pos=(%.2f, %.2f, %.2f) blick=%.0f kopf=%s held=%s" % [(Engine.get_process_frames() - t0) / 30.0,
			borin.anim.current_animation if borin.anim else "-", not borin.sitzt.is_empty(), borin.position.x, borin.position.y, borin.position.z,
			rad_to_deg(borin.rotation.y), "%.0f" % rad_to_deg(k.winkel) if k else "-", spiel.held.kachel])
	return false


func warte(s: float) -> void:
	for i in int(s * 30.0):
		await process_frame


func _lauf() -> void:
	spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	var ebene := CanvasLayer.new()
	ebene.layer = 60
	root.add_child(ebene)
	titel = Label.new()
	titel.add_theme_font_size_override("font_size", 28)
	titel.add_theme_color_override("font_color", Color(0.96, 0.93, 0.85))
	titel.add_theme_color_override("font_outline_color", Color.BLACK)
	titel.add_theme_constant_override("outline_size", 8)
	titel.position = Vector2(24, 90)
	ebene.add_child(titel)
	spiel.ui.mess.visible = false
	spiel.ui.oben.visible = false
	spiel.ui.leiste.visible = false
	spiel.licht.ziel = 0.0
	spiel.licht.stelle(0.0)
	spiel.betrete("inn", Vector2i(2, 6), "RIGHT")
	await warte(1.0)
	spiel.ui.sage([])
	spiel.ui.textfeld.visible = false
	for l in spiel.leute_liste():
		if String(l.daten.get("id", "")) == "borin": borin = l
	if borin == null:
		print("SITZ758 kein Borin"); quit(); return
	print("SITZ758 Borin sitzt=%s Bewegungen=%s" % [borin.sitzt, borin.anim.get_animation_list() if borin.anim else []])
	t0 = Engine.get_process_frames()
	titel.text = "758 · Borin am Tisch"
	await warte(3.0)
	titel.text = "758 · der Held kommt heran"
	spiel.held.geh_zu(spiel.karte.kachel_pos(Vector2i(7, 3)))
	await warte(4.0)
	spiel.ui.textfeld.visible = false
	titel.text = "758 · der Held spricht ihn an"
	borin.wende_zu()
	await warte(3.0)
	borin.zugewandt_bis = Time.get_ticks_msec() + 100   # Gespraech vorbei
	titel.text = "758 · der Held geht"
	spiel.held.geh_zu(spiel.karte.kachel_pos(Vector2i(2, 6)))
	await warte(5.0)
	print("SITZ758 Ende")
	quit()
