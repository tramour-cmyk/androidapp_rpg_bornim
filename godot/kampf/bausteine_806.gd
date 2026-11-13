class_name Bausteine806
extends Node
# 806 (Fund t277.7, Chef 11.11., 20:27/20:30: im Kampf 13 Bilder/s mit Nebel, 17 ohne; „sehr hoppelig … kein Top-Spielerlebnis“):
# am Rechner ist der Kampf ohne Zeichnen schnell (Spielablauf im Mittel unter 1 ms je Bild), die Zeit geht also ins Zeichnen; was
# davon wie viel kostet, zeigt nur das Handy. Testmenü Welt „Kampf messen“: der nächste Kampf hält vor dem ersten Zug an und schaltet
# je Baustein eine Weile ab (erst ruhig werden, dann messen): Bildzeit, Zeit der Grafik (GPU) und des Zeichnens auf dem Prozessor,
# danach wieder an. Ist die Bildzeit viel länger als beide, liegt es am Spielablauf (Skripte).
# Ergebnis über dem Kampfort und unter „Gerät zeigen“ (zum Kopieren); daraus der Umbau, nicht aus Vermutung.

const RUHE_S := 1.0
const MESS_S := 2.0

static var naechster := false      # Testmenü: der nächste Kampf misst
static var zeilen: Array = []      # Ergebnis des letzten Messlaufs (Messung.zeilen)

var kf                              # Kampfort
var schritte: Array = []            # [Name, an: Callable, aus: Callable]
var i := -1
var t := 0.0
var summe := {"bild": 0.0, "gpu": 0.0, "cpu": 0.0, "n": 0}
var basis := -1.0
var stand := ""


func _init(kampfort) -> void:
	kf = kampfort
	name = "Bausteine806"


func _ready() -> void:
	kf.messpause = true           # keine neue Meldung, bis gemessen ist
	stand = "Kampf messen: wartet, bis der Kampfort steht"


## erst, wenn die Blende weg ist und keine Meldung mehr spielt (Figuren stehen, Kamera ruht)
func _beginne() -> void:
	var vp := get_viewport()
	RenderingServer.viewport_set_measure_render_time(vp.get_viewport_rid(), true)
	var sicht := func(knoten: Array, v: bool) -> void:
		for k in knoten:
			if is_instance_valid(k): k.visible = v
	var nebel: Array = kf.find_children("Bodennebel", "", true, false)
	var schacht: Array = kf.find_children("*Lichtschacht*", "", true, false)
	var kit: Array = kf.kit_gras.duplicate()
	var halme: Array = kf.find_children("*", "MultiMeshInstance3D", true, false).filter(func(m): return not kit.has(m))
	var tusche: Array = kf.cam.get_children().filter(func(c): return c is MeshInstance3D and (c as MeshInstance3D).mesh is QuadMesh)
	var wald: Array = []
	if kf.forest: wald = kf.forest.get_children().filter(func(c): return not (c is MultiMeshInstance3D) and not String(c.name).contains("Lichtschacht"))
	var figuren: Array = kf.figures.values()
	var aa := vp.screen_space_aa
	var aufl := vp.scaling_3d_scale
	schritte.append(["alles an", func(): pass, func(): pass])
	if not nebel.is_empty(): schritte.append(["ohne Bodennebel", sicht.bind(nebel, true), sicht.bind(nebel, false)])
	if not schacht.is_empty(): schritte.append(["ohne Lichtschächte", sicht.bind(schacht, true), sicht.bind(schacht, false)])
	if not kit.is_empty(): schritte.append(["ohne Gras des Kits", sicht.bind(kit, true), sicht.bind(kit, false)])
	if not halme.is_empty(): schritte.append(["ohne unser Gras", sicht.bind(halme, true), sicht.bind(halme, false)])
	if not tusche.is_empty(): schritte.append(["ohne Tusche", sicht.bind(tusche, true), sicht.bind(tusche, false)])
	if kf._sun and kf._sun.shadow_enabled:
		schritte.append(["ohne Schatten", func(): kf._sun.shadow_enabled = true, func(): kf._sun.shadow_enabled = false])
	if aa != Viewport.SCREEN_SPACE_AA_DISABLED:
		schritte.append(["ohne Kantenglättung", func(): vp.screen_space_aa = aa, func(): vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED])
	schritte.append(["3D in 75 % Auflösung", func(): vp.scaling_3d_scale = aufl, func(): vp.scaling_3d_scale = aufl * 0.75])
	if not wald.is_empty(): schritte.append(["ohne Bäume und Boden", sicht.bind(wald, true), sicht.bind(wald, false)])
	schritte.append(["ohne Figuren", sicht.bind(figuren, true), sicht.bind(figuren, false)])
	if kf.ui: schritte.append(["ohne Kampfschirm", func(): kf.ui.visible = true, func(): kf.ui.visible = false])
	var alle_an: Array = schritte.slice(1).map(func(s): return s[1])
	var alle_aus: Array = schritte.slice(1).map(func(s): return s[2])
	schritte.append(["alles aus", func(): for c in alle_an: c.call(), func(): for c in alle_aus: c.call()])
	zeilen = ["Kampf messen (806, %s): Bild / Grafik (GPU) / Zeichnen (CPU) in ms" % Messung.kampf_wo]
	_weiter()


func _weiter() -> void:
	if i >= 0:
		schritte[i][1].call()     # wieder an
	i += 1
	t = 0.0
	summe = {"bild": 0.0, "gpu": 0.0, "cpu": 0.0, "n": 0}
	if i >= schritte.size():
		zeilen.append("fertig")
		stand = "\n".join(PackedStringArray(zeilen))
		kf.messpause = false
		RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(), false)
		set_process(false)
		return
	schritte[i][2].call()         # aus
	stand = "\n".join(PackedStringArray(zeilen)) + "\n… %s" % schritte[i][0]


func _process(dt: float) -> void:
	if i < 0:
		if not kf.verhuellt and not kf.playing:
			_beginne()
		return
	if i >= schritte.size():
		return
	t += dt
	if t < RUHE_S:
		return
	var rid := get_viewport().get_viewport_rid()
	summe.bild += dt * 1000.0
	summe.gpu += RenderingServer.viewport_get_measured_render_time_gpu(rid)
	summe.cpu += RenderingServer.viewport_get_measured_render_time_cpu(rid)
	summe.n += 1
	if t < RUHE_S + MESS_S:
		return
	var n := maxi(1, int(summe.n))
	var bild: float = summe.bild / n
	if i == 0:
		basis = bild
	var spar := "" if i == 0 or basis <= 0.0 else ("  (%+.0f ms)" % (bild - basis))
	zeilen.append("%s: %.0f / %.0f / %.0f%s  · %.0f Bilder/s" % [schritte[i][0], bild, summe.gpu / n, summe.cpu / n, spar, 1000.0 / maxf(bild, 0.1)])
	_weiter()


func _exit_tree() -> void:
	if is_instance_valid(kf): kf.messpause = false
	if i >= 0 and i < schritte.size():     # Kampf vorbei, bevor die Messung durch war: was aus ist, wieder an
		schritte[i][1].call()
		zeilen.append("abgebrochen bei „%s“" % schritte[i][0])
