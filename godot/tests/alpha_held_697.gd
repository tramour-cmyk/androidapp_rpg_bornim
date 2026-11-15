extends SceneTree
# 697 (Chef 08.11., 15:23, Build 269, Erschaffung: „das Modell ist halbtransparent“): der echte Held im Drehteller wie in der Erschaffung
# (durchsichtiger SubViewport, Renderer wie am Handy). Je Klasse: Bildpunkte im Inneren der Figur (alle Nachbarn belegt), deren Alpha unter
# 0,98 liegt; dazu je Netz einzeln (die anderen ausgeblendet), damit der Schuldige einen Namen hat. Mit ALPHA_AUS ein Bild je Klasse
# vor Weiss (nur zum Ansehen, kein Bild an den Chef). Nur Zahlen: „ALPHAHELD697 n durchsichtig“ (0 = deckend).
# Aufruf: godot.yml „Alpha 697“ (drehteller=697); ohne Modelle (am Rechner) meldet es „kein Held“ und endet mit 0.

const KLASSEN := ["Wachsoldat", "Klosterschüler", "Herumtreiber", "Zauberlehrling"]
var summe := 0

func _initialize() -> void:
	_lauf.call_deferred()

# Anteil durchsichtiger Bildpunkte im Inneren: [innen, durchsichtig, kleinstes Alpha]
func zaehle(img: Image) -> Array:
	var w := img.get_width(); var h := img.get_height()
	var innen := 0; var durch := 0; var amin := 1.0
	for y in range(1, h - 1):
		for x in range(1, w - 1):
			var a := img.get_pixel(x, y).a
			if a <= 0.02: continue
			var rand := false
			for d in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, -1), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1)]:
				if img.get_pixel(x + d.x, y + d.y).a <= 0.02: rand = true; break
			if rand: continue
			innen += 1
			if a < 0.98: durch += 1; amin = minf(amin, a)
	return [innen, durch, amin]

func bild(dt: Drehteller) -> Image:
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	var img := (dt.get_child(0) as SubViewport).get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	return img

func art(m: Material) -> String:
	if m is ShaderMaterial:
		var sh := (m as ShaderMaterial).shader
		if sh == null: return "Shader ohne Code"
		var rm := ""
		for z in sh.code.split("\n"):
			if z.strip_edges().begins_with("render_mode"): rm = z.strip_edges(); break
		return "%s%s" % [rm.substr(0, 90), " ALPHA" if sh.code.contains("ALPHA") else ""]
	if m is BaseMaterial3D: return "Base transparency=%d" % (m as BaseMaterial3D).transparency
	return str(m)

func _lauf() -> void:
	Sprache.lade()
	print("ALPHAHELD697 Zeichner: ", RenderingServer.get_current_rendering_method())
	var aus := OS.get_environment("ALPHA_AUS")
	for k in KLASSEN:
		var z := Zustand.new()
		var w := HeldFigur.wahl(BrsHeld.fuer_spiel("Thora", "Mensch", k, z.neue_uid), z)
		var dt := Drehteller.new(w, 1.6)
		dt.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		root.add_child(dt)
		for i in 20: await process_frame
		var modell: Node3D = dt.teller.get_child(0) if dt.teller and dt.teller.get_child_count() > 0 else null
		if modell == null:
			print("ALPHAHELD697 %s: kein Held (ohne Modelle)" % k)
			dt.queue_free(); await process_frame; continue
		dt.set_process(false)
		var img: Image = await bild(dt)
		var r := zaehle(img)
		summe += r[1]
		print("ALPHAHELD697 %s: innen %d, durchsichtig %d (%.1f %%), kleinstes Alpha %.3f" % [k, r[0], r[1], 100.0 * r[1] / maxf(1, r[0]), r[2]])
		if aus != "":
			var ges := Image.create(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8)
			ges.fill(Color.WHITE)
			ges.blend_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i.ZERO)
			ges.save_png(aus + "/697_%s.png" % k)
		if r[1] == 0: dt.queue_free(); await process_frame; continue
		# je Netz einzeln
		var netze := modell.find_children("*", "MeshInstance3D", true, false)
		var sichtbar := {}
		for mi in netze: sichtbar[mi] = (mi as MeshInstance3D).visible
		for mi in netze:
			if not sichtbar[mi]: continue
			for x in netze: (x as MeshInstance3D).visible = x == mi
			var e := zaehle(await bild(dt))
			if e[1] == 0: continue
			var x3 := mi as MeshInstance3D
			var mats := []
			for s in x3.mesh.get_surface_count():
				var m: Material = x3.material_override if x3.material_override else x3.get_active_material(s)
				mats.append(art(m) if m else "-")
			print("ALPHAHELD697   %s: innen %d, durchsichtig %d, kleinstes Alpha %.3f | %s" % [x3.name, e[0], e[1], e[2], " / ".join(mats)])
		for x in netze: (x as MeshInstance3D).visible = sichtbar[x]
		dt.queue_free()
		await process_frame
	print("ALPHAHELD697 %d durchsichtig" % summe)
	quit(0)
