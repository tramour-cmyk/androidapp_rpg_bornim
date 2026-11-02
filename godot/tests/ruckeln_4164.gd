extends SceneTree
# 416.4 (Chef 02.11., 14:36, Dorf-Film 4611: Rennen zum angetippten Ziel „ruckelt es wie blöd“, beide Helden): ohne Bild. Der Held
# laeuft (laeuft = true) ueber geh_zu zu einem Ziel 8 Kacheln weiter auf dem Dorfplatz; je Bild Weg, Tempo, bewegt oder nicht.
# Gemessen: Bilder ohne Bewegung mitten im Weg, Spruenge im Tempo (mehr als BESCHL erlaubt), Wechsel der Bewegung (Rennen/Gehen/Stehen).
# Aufruf: im Ordner godot mit -s res://tests/ruckeln_4164.gd -> „RUCKELN n Fehler“

var fehler := 0

func _initialize() -> void:
	_lauf.call_deferred()

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _lauf() -> void:
	var k := Karte.lade("village")
	var h := Held.new(k)
	root.add_child(h)
	for i in 3: await process_frame
	h.set_process(false)   # Bilder von Hand, feste Zeit je Bild wie am Handy (60 Bilder/s)
	var start := Vector2i(12, 13); var ziel := Vector2i(20, 13)
	h.setze(start, "RIGHT")
	h.laeuft = true
	pruefe(h.geh_zu(k.kachel_pos(ziel)), "Weg von %s nach %s" % [start, ziel])
	var dt := 1.0 / 60.0
	var still := 0; var still_mitten := []; var spruenge := []; var vorher := h.position; var v_vorher := 0.0
	var wechsel := []; var bewegung := ""
	for i in 600:
		if not h.geht(): break
		h._process(dt)
		var v := Vector2(h.position.x - vorher.x, h.position.z - vorher.z).length() / dt
		if v < 0.01:
			still += 1
			if h.geht(): still_mitten.append([i, k.pos_kachel(h.position), h.weg.size()])
		if i > 0 and absf(v - v_vorher) > Held.BESCHL * dt * 1.5 + 0.05: spruenge.append([i, snappedf(v_vorher, 0.01), snappedf(v, 0.01)])
		if h.anim and h.anim.current_animation != bewegung:
			bewegung = h.anim.current_animation; wechsel.append([i, bewegung])
		vorher = h.position; v_vorher = v
	print("Weg: angekommen ", k.pos_kachel(h.position), ", Bilder ohne Bewegung mitten im Weg ", still_mitten.size(), ": ", still_mitten.slice(0, 8))
	print("Tempospruenge ", spruenge.size(), ": ", spruenge.slice(0, 12))
	print("Bewegungswechsel ", wechsel.size(), ": ", wechsel.slice(0, 12))
	pruefe(k.pos_kachel(h.position) == ziel, "angekommen")
	pruefe(still_mitten.is_empty(), "kein Bild ohne Bewegung mitten im Weg (%d)" % still_mitten.size())
	var letzt := spruenge.filter(func(x): return x[2] < 1.0 and x[1] <= 1.0)   # der Halt am Ende aus dem Anlauftempo (unter 1 m/s)
	pruefe(spruenge.size() == letzt.size(), "Tempo ohne Spruenge ausser dem Halt (%d, Halt %d)" % [spruenge.size(), letzt.size()])
	print("RUCKELN %d Fehler" % fehler)
	quit(1 if fehler else 0)
