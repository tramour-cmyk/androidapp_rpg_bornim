extends SceneTree
# 505c (Chef 04.11., 14:01: „den Zoom … mitsteuern, dass halt dann nicht ewig weit rausgeguckt werden kann, wo nichts ist“; Zu 505 (Rand)
# (3)) ohne Bild und ohne Daten: die Kamera (kamera.gd am_rand) haelt an Karte samt Randwald. Je Karte (Wald, Tiefer Wald, Dorf, Hoehle),
# Blickrichtung (8 Drehungen), Zoom (Grundansicht, Naeher, ganz heraus) und Lage des Helden (Mitte, Raender, Ecken): die vier Bildecken
# treffen den Boden innerhalb von Karte + Randwald, der Held ist im Bild. Dazu: in der Mitte einer grossen Karte bleibt alles wie
# vorher (keine Verschiebung, kein kleinerer Ausschnitt). Massgeblich ist die Zeile RAND505.

var fehler := 0
var proben := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		print("FEHLER " + was)
		fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	root.size = Vector2i(540, 1170)   # Handy hochkant wie im Bau (godot.yml --resolution 540x1170)
	await process_frame
	var k := Kamera.new()
	root.add_child(k)
	var held := Node3D.new()
	root.add_child(held)
	k.ziel = held
	await process_frame
	var weit := 11.0 * Karte.TS   # nebel.gd RAND_SCHWARZ
	var vp := k.get_viewport().get_visible_rect().size
	print("Bild %s" % vp)
	var groesst := 0.0
	for karte in [["forest", 20, 32], ["deep_forest", 44, 38], ["village", 36, 32], ["cave", 22, 20]]:
		var w: float = karte[1] * Karte.TS; var h: float = karte[2] * Karte.TS
		k.rand(Rect2(0, 0, w, h), weit)
		var zeile := ""
		for zoom in [Kamera.FERN, Kamera.FERN * Bedienung.NAEHER, Kamera.FERN * 1.6]:
			var kleinst := 99.0
			for gier in range(0, 360, 45):
				for lage in [Vector2(0.5, 0.5), Vector2(0.02, 0.5), Vector2(0.98, 0.5), Vector2(0.5, 0.02), Vector2(0.5, 0.98),
						Vector2(0.02, 0.02), Vector2(0.98, 0.02), Vector2(0.02, 0.98), Vector2(0.98, 0.98)]:
					held.position = Vector3(lage.x * w, 0, lage.y * h)
					k.zoom = zoom; k.size = zoom
					k.gieren_ziel = Kamera.NORD + gier; k.springe()
					proben += 1
					var wo := "%s Zoom %.1f Drehung %d Held %s" % [karte[0], zoom, gier, lage]
					var aus := 0.0
					for e in [Vector2(0, 0), Vector2(vp.x, 0), Vector2(0, vp.y), Vector2(vp.x, vp.y)]:
						var b = k.boden(e)
						if b == null: pruefe(false, wo + ": Bildecke trifft den Boden nicht"); continue
						var p: Vector3 = b
						aus = maxf(aus, maxf(maxf(-p.x, p.x - w), maxf(-p.z, p.z - h)))
					groesst = maxf(groesst, aus)
					pruefe(aus <= weit + 0.05, wo + ": Bild reicht %.2f m hinter den Rand (Randwald %.2f m)" % [aus, weit])
					var q := k.unproject_position(held.position)
					pruefe(q.x >= 0 and q.y >= 0 and q.x <= vp.x and q.y <= vp.y, wo + ": Held nicht im Bild (%s)" % q)
					kleinst = minf(kleinst, k.size / zoom)
			zeile += "  Zoom %.1f m: kleinster %.1f m (%.0f %%)" % [zoom, kleinst * zoom, kleinst * 100.0]
		print("%s:%s" % [karte[0], zeile])
	# Mitte des Tiefen Walds, Grundansicht: wie vorher
	k.rand(Rect2(0, 0, 44 * Karte.TS, 38 * Karte.TS), weit)
	held.position = Vector3(22 * Karte.TS, 0, 19 * Karte.TS)
	k.zoom = Kamera.FERN; k.size = Kamera.FERN; k.gieren_ziel = Kamera.NORD; k.springe()
	pruefe(not k.rand_klein and is_equal_approx(k.size, Kamera.FERN), "Mitte Tiefer Wald: Ausschnitt verkleinert (%.2f)" % k.size)
	var mitte = k.boden(vp / 2.0)
	pruefe(mitte != null and Vector2(mitte.x, mitte.z).distance_to(Vector2(held.position.x, held.position.z)) < 0.05, "Mitte Tiefer Wald: Bildmitte nicht am Helden")
	# ohne Rand (Grundriss): nichts begrenzt
	k.rand(Rect2(), 0.0)
	held.position = Vector3(0, 0, 0)
	k.springe()
	pruefe(is_equal_approx(k.size, Kamera.FERN), "Grundriss: Ausschnitt veraendert")
	print("weitester Blick hinter den Rand %.2f m (Randwald %.2f m), %d Proben" % [groesst, weit, proben])
	print("RAND505 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
