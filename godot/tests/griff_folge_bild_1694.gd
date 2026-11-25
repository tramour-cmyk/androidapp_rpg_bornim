extends "res://tests/griff_folge_1694.gd"
# 1694 (Auftrag 25.11., 10:02): Bildgegenprobe zu griff_folge_1694 BILD1694=1. Im gemessenen Prozessbild (frame_post_draw, Bild 30) den
# Viewport (Spielkamera, Handygröße) ablegen, dazu den Ausschnitt um die gezeichnete Hand, beschriftet über die Ausgabe.
#   BILD1694=1 BILDAUS=<pfad.png> PROBE=1694 xvfb-run -a godot --path . --resolution 540x1170 -s res://tests/griff_folge_bild_1694.gd -- --bild1694

func _nimm_bild(): return root.get_viewport().get_texture().get_image()

func _bild_speichern(z: Dictionary, sk: Skeleton3D, ding: Node3D) -> void:
	var img: Image = z.bild
	var cam := root.get_viewport().get_camera_3d()
	var hp = _rs_knochen(sk, _hand_netze(sk), "hand_r")
	# unproject_position rechnet im Raum des Inhalts (1080x2340), das Bild hat die Fenstergröße (540x1170)
	var mitte := cam.unproject_position(hp) * Vector2(img.get_size()) / root.get_viewport().get_visible_rect().size if hp != null and cam != null else Vector2(img.get_width(), img.get_height()) * 0.5
	var r := 70
	var ra := Rect2i(Vector2i(mitte) - Vector2i(r, r), Vector2i(2 * r, 2 * r)).intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	var aus := img.get_region(ra); aus.resize(ra.size.x * 4, ra.size.y * 4, Image.INTERPOLATE_NEAREST)
	var pfad := OS.get_environment("BILDAUS")
	aus.save_png(pfad); img.save_png(pfad.replace(".png", "_ganz.png"))
	print("BILD1694 BILD %s: Prozessbild %d, Ausschnitt %s um hand_r %s; Handfläche (hand_r) %s, Kleinfinger-Grundglied %s cm" % [pfad, z.p, ra, mitte, _z(z.netz.get("hand_r")), _z(z.netz.get("pinky_01_r"))])

