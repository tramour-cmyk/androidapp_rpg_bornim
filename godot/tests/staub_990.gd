extends SceneTree
# 990 (Chef 11.11., 20:19, t277, Thessas Kramladen: „Die Partikel gehen über den Raum hinaus“; 20:51 Schenke: Partikel an der Tür,
# keine an den Fenstern): ohne Bild und ohne Effektpaket. Je Fenster von Schenke und Laden (W in der Randzeile der Karte) legt der Test
# Lichtquelle und Lichtfleck wie raum.py an (Quelle 1,6 m vor der Wand, 2,6 m hoch; Fleck 1,4 Kacheln innen am Boden) und prueft:
# alte Lage (1,9 m von der Quelle zur Raummitte) war kaum innen; der neue Schwarm (DorfEffekte.staub_kasten) liegt samt Weg der Flocken
# ganz innerhalb der Innenwaende und im Lichtkegel vor seinem Fenster.
# Braucht daten/karten.json. Aufruf im Ordner godot: headless, -s res://tests/staub_990.gd -> „STAUB990 …“

const WEG := 0.3   # angenommener Weg einer Flocke (m); im Spiel aus der Vorlage (staub_weg)

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var j: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json"))
	var TS := Karte.TS
	var ka = j["karten"]
	for m in (ka.values() if ka is Dictionary else ka):
		if not String(m["id"]) in ["inn", "shop"]: continue
		var zeilen: Array = m["zeilen"]
		var h := zeilen.size()
		var b := String(zeilen[0]).length()
		var innen_lo := Vector2(TS, TS)
		var innen_hi := Vector2((b - 1) * TS, (h - 1) * TS)
		for r in h:
			for c in b:
				if String(zeilen[r])[c] != "W": continue
				var n := Vector3.ZERO   # in den Raum
				if r == 0: n = Vector3(0, 0, 1)
				elif r == h - 1: n = Vector3(0, 0, -1)
				elif c == 0: n = Vector3(1, 0, 0)
				elif c == b - 1: n = Vector3(-1, 0, 0)
				else: continue
				var wand := Vector3((c + 0.5) * TS, 0, (r + 0.5) * TS)
				var quelle := wand - n * 1.6 + Vector3(0, 2.6, 0)
				var ziel := wand + n * 1.4 * TS
				# alte Lage (Build 277): von der Quelle 1,6 Kacheln zur Raummitte
				var mitte_raum := Vector3(b * TS / 2, 0, h * TS / 2)
				var d := Vector3(mitte_raum.x - quelle.x, 0, mitte_raum.z - quelle.z)
				var alt := Vector3(quelle.x, 0.2, quelle.z) + d.normalized() * minf(d.length(), 1.6 * TS)
				var alt_innen := (alt - wand).dot(n) - TS / 2   # Abstand zur Innenseite der Wand
				var k: Dictionary = DorfEffekte.staub_kasten(quelle, ziel, b, h, WEG)
				var mi: Vector3 = k["mitte"]
				var ha: Vector3 = k["halb"]
				var lo := mi - ha - Vector3.ONE * WEG
				var hi := mi + ha + Vector3.ONE * WEG
				var drin := lo.x >= innen_lo.x and lo.z >= innen_lo.y and hi.x <= innen_hi.x and hi.z <= innen_hi.y and lo.y >= 0.0 and hi.y <= 2.6
				var vor := (mi - wand).dot(n) - TS / 2
				var seit := absf((mi - wand).dot(Vector3(n.z, 0, -n.x)))
				print("%s Fenster (%d,%d): alt %.2f m innen, neu Mitte %.2f m vor der Wand, %.2f seitlich, Kasten %s" % [m["id"], c, r, alt_innen, vor, seit, ha])
				pruefe(drin, "%s (%d,%d) Flocken samt Weg innerhalb der Innenwaende (%s bis %s)" % [m["id"], c, r, lo, hi])
				pruefe(vor > 0.3 and vor < 1.4 and seit < 0.45, "%s (%d,%d) Schwarm im Licht vor seinem Fenster" % [m["id"], c, r])
	print("STAUB990 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
