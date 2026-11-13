extends SceneTree
# 677 (Chef 08.11., 15:54, t269.15: „Benutzen aus der Tasche tut nichts“): der Leuchtfunke wie alt (WorldScreen.kt 1443–1458):
# Benutzen aus der Tasche setzt den Funken, er schwebt ueber dem Kopf (draussen etwa 2,15 m, im Raum auf Schulterhoehe), treibt und
# wippt, dreht sich nicht mit dem Helden; sein Licht nur im Dunkeln, kuehl und schwaecher als die Fackel; „Löschen“ und Rast nehmen ihn.
# Ohne Bildbefehl. Aufruf: im Ordner godot mit -s res://tests/funke_677.gd -> „FUNKE677 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	Sprache.lade()
	var z := Zustand.new()
	z.dazu("spark_potion", 1)
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", z.neue_uid)
	var satz := Menue.benutze(z, hw, "spark_potion", func(a, b): return 1)
	pruefe(z.funke, "Benutzen setzt den Funken nicht (%s)" % satz)
	pruefe(z.anzahl("spark_potion") == 0, "Fläschchen nicht verbraucht")
	var k := Karte.lade("village")
	var h := Held.new(k)
	root.add_child(h)
	h.setze(Vector2i(19, 13), "RIGHT")
	h.funke_neu(z.funke)
	pruefe(h.funke != null and h.funke.visible, "kein Funke am Helden")
	h.nacht(1.0)
	var hoehen := []
	for i in 90:
		h._process(1.0 / 30.0)
		hoehen.append(h.funke.global_position.y - h.global_position.y)
	var hmax: float = hoehen.max(); var hmin: float = hoehen.min()
	pruefe(hmin > 1.95 and hmax < 2.35, "draussen nicht über dem Kopf: %.2f–%.2f m" % [hmin, hmax])
	pruefe(hmax - hmin > 0.01, "wippt nicht")
	pruefe(h.funke_licht.visible and h.funke_licht.light_energy > 0.5, "nachts kein Licht: %.2f" % h.funke_licht.light_energy)
	pruefe(h.funke_licht.light_energy < 2.2 * 1.0, "heller als die Fackel")
	pruefe(h.funke_licht.light_color.b > h.funke_licht.light_color.r, "Licht nicht kühl")
	# dreht sich der Held, bleibt der Funke, wo er ist (top_level)
	var p0 := h.funke.global_position
	h.rotation.y += PI / 2
	pruefe(h.funke.global_position.distance_to(p0) < 0.001, "Funke dreht sich mit dem Helden")
	# am Tag kein Licht
	h.nacht(0.0)
	h._process(1.0 / 30.0)
	pruefe(not h.funke_licht.visible, "am Tag Licht an")
	# im Raum sinkt er auf die Schulter
	h.fackel_neu(false, true)
	for i in 60: h._process(1.0 / 30.0)
	var hr := h.funke.global_position.y - h.global_position.y
	pruefe(hr > 1.3 and hr < 1.6, "im Raum nicht auf Schulterhöhe: %.2f m" % hr)
	# Löschen und Rast nehmen ihn
	z.funke = false
	h.funke_neu(z.funke)
	pruefe(not h.funke.visible, "gelöscht noch sichtbar")
	print("Funke 677: draussen %.2f–%.2f m, im Raum %.2f m" % [hmin, hmax, hr])
	print("FUNKE677 %d Fehler" % fehler)
	quit(0)
