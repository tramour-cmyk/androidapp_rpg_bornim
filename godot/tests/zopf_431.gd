extends SceneTree
# 431 Nachbesserung (Pruefer 25.11., 09:58, Nein-Punkt 2): Haar der Zwergin orange-schwarz gefleckt wie ein Fell. Gemessen wird das Bild
# des Zopfs (godot/figuren/zopf_zwergin.glb) dort, wo das Netz es zeigt: Helligkeit in der Mitte jedes Dreiecks, geteilt durch das
# Mittel aller Dreiecke. Fleck = unter 0,4 oder ueber 1,6 des Mittels (die Toenung multipliziert, also wird ein Fleck im Bild ein Fleck
# im Haar). Fall FALSCH, wenn mehr als 5 % der Dreiecke Flecken sind. Kein Kaufmodell noetig.
# Aufruf im Ordner godot: godot --headless -s res://tests/zopf_431.gd
const GRENZE := 0.05

func _initialize() -> void:
	var ps := load(HeldFigur.ZOPF) as PackedScene
	if ps == null:
		print("FALSCH ZOPF431 %s nicht geladen (Import?)" % HeldFigur.ZOPF); quit(1); return
	var s := ps.instantiate() as Node3D
	var mi := s.find_child("Zopf_Zwergin", true, false) as MeshInstance3D
	var mat := mi.mesh.surface_get_material(0) as BaseMaterial3D
	var img := mat.albedo_texture.get_image()
	if img.is_compressed(): img.decompress()
	var a := mi.mesh.surface_get_arrays(0)
	var uv: PackedVector2Array = a[Mesh.ARRAY_TEX_UV]
	var ix: PackedInt32Array = a[Mesh.ARRAY_INDEX]
	var w := img.get_width(); var h := img.get_height()
	var l := PackedFloat32Array()
	for i in range(0, ix.size(), 3):
		var c := (uv[ix[i]] + uv[ix[i + 1]] + uv[ix[i + 2]]) / 3.0
		var px := img.get_pixel(clampi(int(fposmod(c.x, 1.0) * w), 0, w - 1), clampi(int(fposmod(c.y, 1.0) * h), 0, h - 1))
		l.append(px.get_luminance())
	var mittel := 0.0
	for x in l: mittel += x
	mittel /= maxf(1.0, l.size())
	var dunkel := 0; var hell := 0
	for x in l:
		if x < 0.4 * mittel: dunkel += 1
		elif x > 1.6 * mittel: hell += 1
	var anteil := float(dunkel + hell) / maxf(1.0, l.size())
	var ok := anteil <= GRENZE
	print("%s ZOPF431 Haarbild: %d Dreiecke, Mittel %.3f, dunkel %d, hell %d, Flecken %.1f %% (hoechstens %.0f %%)" % [
		"FALL" if ok else "FALSCH", l.size(), mittel, dunkel, hell, anteil * 100.0, GRENZE * 100.0])
	s.free()
	print("ZOPF431 1 Fall, %d falsch" % (0 if ok else 1))
	quit(0 if ok else 1)
