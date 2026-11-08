extends SceneTree
## 507 (Jerry, Prüfer Lauf 287: fast schwarze Flächen; Messlauf 242: Szene p50 0 bei Licht 3): wie hell kommt die Eckfarbe der
## Höhle in Godot an? toon.gdshader rechnet Albedo = Textur mal Eckfarbe (COLOR); die Eckfarbe soll eine Tönung um 1 sein, die
## Farbe malt die Textur (tex.py). Je Ort und Stoff das Mittel der Eckfarbe, ohne Bild: liest nur die Netze
## (HOEHLE_GLB=<ordner mit kampfort-hoehle-<ort>.glb>, sonst res://kampf/daten/kampfort-hoehle-<ort>.bin).
## FALSCH, wenn Fels oder Boden im Mittel dunkler als 0,3 getönt sind: dann bleibt die Höhle im Umgebungslicht schwarz
## (vorher 0,07–0,12: Textur 0,09 mal 0,1 = 1 % Helligkeit).
func _init() -> void:
	var fehler := 0
	for o in ["eingang", "gang", "halle", "teich", "lager"]:
		var d := OS.get_environment("HOEHLE_GLB")
		var doc := GLTFDocument.new()
		var st := GLTFState.new()
		var err: int
		if d != "":
			err = doc.append_from_file(d + "/kampfort-hoehle-%s.glb" % o, st)
		else:
			var p := "res://kampf/daten/kampfort-hoehle-%s.bin" % o
			if not FileAccess.file_exists(p):
				print("HOEHLEFARBE %s fehlt" % o)
				continue
			err = doc.append_from_buffer(FileAccess.get_file_as_bytes(p), "", st)
		if err != OK:
			print("HOEHLEFARBE %s nicht lesbar" % o)
			fehler += 1
			continue
		var n := doc.generate_scene(st)
		for mi in n.find_children("*", "MeshInstance3D", true, false):
			var m: Mesh = (mi as MeshInstance3D).mesh
			for i in m.get_surface_count():
				var a := m.surface_get_arrays(i)
				var c = a[Mesh.ARRAY_COLOR]
				var mat := m.surface_get_material(i)
				var name: String = mat.resource_name if mat else "-"
				var ec := Vector3.ONE
				if c != null and c.size() > 0:
					ec = Vector3.ZERO
					var k := 0
					var z := 0
					while k < c.size():
						ec += Vector3(c[k].r, c[k].g, c[k].b)
						k += 5
						z += 1
					ec /= float(z)
				var hell := ec.x * 0.2126 + ec.y * 0.7152 + ec.z * 0.0722
				var bild := mat is BaseMaterial3D and (mat as BaseMaterial3D).albedo_texture != null
				print("HOEHLEFARBE %s %s: Ecken %d, Eckfarbe %.3f %.3f %.3f (hell %.3f), Textur %s" % [o, name,
					0 if c == null else c.size(), ec.x, ec.y, ec.z, hell, "ja" if bild else "nein"])
				if name in ["feldstein", "erde"] and hell < 0.3:
					print("FALSCH 507: %s %s Tönung %.3f unter 0,3" % [o, name, hell])
					fehler += 1
	print("HOEHLEFARBE fertig, Fehler %d" % fehler)
	quit(1 if fehler else 0)
