extends SceneTree
# 431 Nachbesserung (Befund Pruefer 24.11., 18:14: Orkbluetiger Gesicht braun RGB 75,51,31 trotz graugruener Wahl): Gesichtsfarbe im
# Drehteller der Erschaffung (Renderer wie am Handy) gegen den gewaehlten Hautton, je Ton des Volks, Mann und Frau; Mensch zum Vergleich.
# Gemessen: Mittel 7x7 Pixel auf der Wange (Kopfknochen, 8,5 cm vor, 7 cm hoeher, 3,5 cm seitlich). Falsch, wenn der Farbton (Gruen gegen Rot)
# vom gewaehlten abweicht: Gruen/Rot im Bild unter 0,9 * Gruen/Rot des Tons.
# Aufruf im Ordner godot: godot --path . --rendering-method mobile --resolution 540x1170 -s res://tests/orkhaut_431.gd
var fehler := 0

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	if not HeldFigur.da():
		print("ORKHAUT431 ohne Kaufmodelle"); quit(0); return
	var n := 0
	for v in ["Orkblütiger", "Mensch"]:
		var vm := HeldFigur.volk_modell(v)
		var toene := HeldFigur.toene_liste(vm, "haut")
		for g in ["m", "w"]:
			for i in toene.size():
				var b := BrsHeld.neu(v, "Wachsoldat"); b.ausstatten()
				var a := HeldFigur.vorgabe("Wachsoldat", g, vm); a["haut"] = i
				var t := Drehteller.new({"herkunft": "Wachsoldat", "volk": vm, "aussehen": a, "ausruestung": b.ausruestung}, 2.0, false)
				root.add_child(t)
				t.size = Vector2(540, 1170)
				for k in 8: await process_frame
				await RenderingServer.frame_post_draw
				var vp := t.get_child(0) as SubViewport
				var img := vp.get_texture().get_image()
				var held := t.teller.get_child(0) as Node3D
				var sk := Gebiet.finde(held, "Skeleton3D") as Skeleton3D
				var kopf := sk.global_transform * sk.get_bone_global_pose(sk.find_bone("Head"))
				var s := held.scale.x
				var p := kopf.origin + Vector3(0.035, 0.07, 0.085) * s
				var px := vp.get_camera_3d().unproject_position(p)
				var c := Vector3.ZERO
				var z := 0
				for dx in range(-3, 4):
					for dy in range(-3, 4):
						var q := Vector2i(int(px.x) + dx, int(px.y) + dy)
						if q.x < 0 or q.y < 0 or q.x >= img.get_width() or q.y >= img.get_height(): continue
						var f := img.get_pixelv(q)
						c += Vector3(f.r, f.g, f.b); z += 1
				c = c / maxf(z, 1) * 255.0
				var ziel := HeldFigur.ton(vm, "haut", i)
				var gr_ziel := ziel.g / maxf(ziel.r, 0.001)
				var gr := c.y / maxf(c.x, 0.001)
				var ok := gr >= 0.9 * gr_ziel
				if not ok: fehler += 1
				n += 1
				print("%s %s %s Ton %d %s: Ziel %s (G/R %.2f), Gesicht %d,%d,%d (G/R %.2f) bei %d,%d, Modell %s" % ["FALL" if ok else "FALSCH", v, g,
					i, String(toene[i].get("name", {}).get("de", "")), ziel.to_html(false), gr_ziel, c.x, c.y, c.z, gr, px.x, px.y,
					held.get_meta("tracht", "")])
				if OS.get_environment("AUS") != "": img.save_png(OS.get_environment("AUS").path_join("orkhaut_%s_%s_%d.png" % [vm, g, i]))
				t.queue_free()
				await process_frame
	print("ORKHAUT431 %d Faelle, %d falsch" % [n, fehler])
	quit(1 if fehler > 0 else 0)
