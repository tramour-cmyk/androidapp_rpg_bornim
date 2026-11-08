extends SceneTree
# 615 (Chef 07.11., t268: „Kamerabewegungen (Zoom/Drehung) um den Avatar als Fixpunkt. Bisher läuft die Kamera gerne aus dem
# Bild“): die Kamera folgt wie im Spiel (spiel.gd: folge(dt * 5)); waehrend sie um 90 Grad dreht, nah und fern zoomt oder mit zwei
# Fingern kneift, bleibt der Held in jedem Bild nahe der Bildmitte (hoechstens 12 % der Bildbreite daneben). Ohne Bild.
# Aufruf: im Ordner godot mit -s res://tests/kamera_615.gd

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

# wie weit der Held von der Bildmitte liegt, im Verhaeltnis zur Bildbreite (orthogonal: Abstand quer zur Blickachse)
func daneben(k: Kamera, h: Node3D) -> float:
	var d := h.global_position + Vector3(0, 0.9, 0) - k.global_position   # Brust des Helden (1,8 m)
	var quer := d - k.global_basis.z * d.dot(k.global_basis.z)
	return quer.length() / k.size

func lauf(k: Kamera, h: Node3D, sek: float) -> float:
	var am_meisten := 0.0
	var t := 0.0
	while t < sek:
		k.folge(minf(1.0, (1.0 / 60.0) * 5.0))
		am_meisten = maxf(am_meisten, daneben(k, h))
		t += 1.0 / 60.0
	return am_meisten

func _lauf() -> void:
	var welt := Node3D.new()
	root.add_child(welt)
	var held := Node3D.new()
	welt.add_child(held)
	held.position = Vector3(12.0, 0, 20.0)
	var k := Kamera.new()
	welt.add_child(k)
	k.ziel = held
	await process_frame
	k.springe()
	pruefe(daneben(k, held) < 0.1, "steht still: Held in der Mitte (%.3f)" % daneben(k, held))
	k.drehe(90.0)
	var m := lauf(k, held, 2.0)
	pruefe(m < 0.12, "drehen um 90 Grad: Held hoechstens %.0f %% neben der Mitte" % (m * 100))
	k.drehe(-45.0)
	m = lauf(k, held, 2.0)
	pruefe(m < 0.12, "drehen um 45 Grad zurueck: %.0f %%" % (m * 100))
	k.nah_fern()
	m = lauf(k, held, 2.0)
	pruefe(m < 0.12, "nah: %.0f %%" % (m * 100))
	k.nah_fern()
	m = lauf(k, held, 2.0)
	pruefe(m < 0.12, "fern: %.0f %%" % (m * 100))
	k.kneifen(0.6)
	k.drehe(45.0)
	m = lauf(k, held, 2.0)
	pruefe(m < 0.12, "kneifen und drehen zugleich: %.0f %%" % (m * 100))
	# der Held geht weiter, die Kamera folgt weich (das darf nachziehen, aber nicht aus dem Bild)
	var am := 0.0
	for i in 120:
		held.position += Vector3(0.03, 0, 0.0)
		k.folge(5.0 / 60.0)
		am = maxf(am, daneben(k, held))
	pruefe(am < 0.2, "beim Gehen folgt sie: %.0f %%" % (am * 100))
	print("KAMERA615 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
