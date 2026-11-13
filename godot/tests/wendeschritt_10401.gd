extends SceneTree
# 1040.1 (Tuffy aus 1040; Chef 12.11., 15:13, Lyra: „die Lyra dreht sich ja genauso bescheuert, ohne Schritte. Ja, auch wie auf dem
# Drehteller.“): ohne Bild. Eine Person ohne Modell (AnimationPlayer mit Stehen, Drehen_L/R je 1 s, Kurven wie wende_4168) schaut dem
# Helden nach, der in 2,5 Kacheln Abstand gemaechlich um sie herumgeht (1,4 m/s), dann stehen bleibt, dann zurueckgeht.
# Geprueft: sie dreht fast nur in Wenden mit Schritten (Knoten nach der Kurve), nicht stetig wie auf dem Drehteller; sie bleibt
# hoechstens WENDE_AB hinter dem Helden; steht er, steht sie am Ende zu ihm gewandt still; ein ruhendes Ziel unter WENDE_AB dreht
# weiter ohne Schritte (wende_4168, 3). Aufruf im Ordner godot: --fixed-fps 30 -s res://tests/wendeschritt_10401.gd
# -> „WENDESCHRITT n Fehler“

func _initialize() -> void:
	_lauf.call_deferred()

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func kurve90(seite: float) -> PackedFloat32Array:
	var k := PackedFloat32Array()
	for f in 31: k.append(seite * deg_to_rad(90.0) * smoothstep(0.0, 1.0, f / 30.0))
	return k

func spieler(n: Node3D) -> AnimationPlayer:
	var ap := AnimationPlayer.new()
	var lib := AnimationLibrary.new()
	for name in ["Stehen", "Drehen_L", "Drehen_R"]:
		var a := Animation.new()
		a.length = 1.0
		if name == "Stehen": a.loop_mode = Animation.LOOP_LINEAR
		lib.add_animation(name, a)
	ap.add_animation_library("", lib)
	n.add_child(ap)
	return ap

var p: Leute
var hin: Node3D
var gleiten := 0.0        # rad, die sie ausserhalb einer Wende gedreht hat
var schritt := 0.0        # rad in Wenden
var hinten := 0.0         # rad, groesster Rueckstand zum Helden
var wenden := 0

func zum_helden() -> float:
	return atan2(hin.global_position.x - p.global_position.x, hin.global_position.z - p.global_position.z)

# ein Bild: messen, wie sie sich gedreht hat (in einer Wende oder gleitend)
func bild() -> void:
	var vorher := p.rotation.y
	var w_vorher := p.wende
	await process_frame
	var d := absf(angle_difference(vorher, p.rotation.y))
	if p.wende != "" or w_vorher != "": schritt += d
	else: gleiten += d
	if p.wende != "" and w_vorher == "": wenden += 1
	hinten = maxf(hinten, absf(angle_difference(p.rotation.y, zum_helden())))

func bogen(s: float, seite: float) -> void:
	var r := 2.5 * Karte.TS
	var w := 1.4 / r / 30.0 * seite     # rad je Bild bei 1,4 m/s
	for i in int(s * 30.0):
		var a := atan2(hin.global_position.x - p.global_position.x, hin.global_position.z - p.global_position.z) + w
		hin.global_position = p.global_position + Vector3(sin(a), 0.0, cos(a)) * r
		await bild()

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.betrete("village", Vector2i(11, 7), "DOWN")
	for i in 5: await process_frame
	var k: Karte = spiel.karte
	for l in spiel.leute_liste(): l.visible = false
	p = Leute.new(k, {"id": "probe_10401", "x": 11, "y": 11, "streifen": 0}, spiel.held)
	spiel.add_child(p)
	await process_frame
	p.warte = 999.0
	p.anim = spieler(p)
	p.anim.play("Stehen")
	p.wende_kurve = {"Drehen_L": kurve90(1.0), "Drehen_R": kurve90(-1.0)}
	hin = Node3D.new()
	spiel.add_child(hin)
	hin.global_position = p.global_position + Vector3(0.0, 0.0, 2.5 * Karte.TS)
	p.rotation.y = 0.0
	p.held = hin
	for i in 30: await bild()          # sie wendet sich ihm zu (steht vor ihr)
	gleiten = 0.0; schritt = 0.0; hinten = 0.0; wenden = 0
	# 1) er geht 6 s um sie herum (gut 120 Grad)
	await bogen(6.0, 1.0)
	var anteil := gleiten / maxf(0.001, gleiten + schritt)
	print("WENDESCHRITT links: %.0f Grad gedreht, %.0f in %d Wenden, %.0f gleitend; hoechstens %.0f Grad hinter ihm" % [
		rad_to_deg(gleiten + schritt), rad_to_deg(schritt), wenden, rad_to_deg(gleiten), rad_to_deg(hinten)])
	pruefe(wenden >= 3, "mit Schritten: %d Wenden" % wenden)
	pruefe(anteil < 0.15, "kaum gleitend wie auf dem Drehteller (%.0f %% ohne Schritte)" % (anteil * 100.0))
	pruefe(hinten <= Leute.WENDE_AB + deg_to_rad(8.0), "bleibt dicht am Helden (hoechstens %.0f Grad hinter ihm)" % rad_to_deg(hinten))
	# 2) er bleibt stehen: sie kommt zur Ruhe, zu ihm gewandt
	for i in 60: await bild()
	pruefe(p.wende == "" and p.anim.current_animation == "Stehen", "er steht: sie steht (%s)" % p.anim.current_animation)
	pruefe(absf(angle_difference(p.rotation.y, zum_helden())) < deg_to_rad(3.0), "zu ihm gewandt (%.1f Grad daneben)" % rad_to_deg(angle_difference(p.rotation.y, zum_helden())))
	# 3) zurueck nach rechts
	gleiten = 0.0; schritt = 0.0; hinten = 0.0; wenden = 0
	await bogen(6.0, -1.0)
	anteil = gleiten / maxf(0.001, gleiten + schritt)
	print("WENDESCHRITT rechts: %.0f Grad gedreht, %.0f in %d Wenden, %.0f gleitend; hoechstens %.0f Grad hinter ihm" % [
		rad_to_deg(gleiten + schritt), rad_to_deg(schritt), wenden, rad_to_deg(gleiten), rad_to_deg(hinten)])
	pruefe(wenden >= 3 and anteil < 0.15, "zurueck ebenso mit Schritten (%d Wenden, %.0f %% gleitend)" % [wenden, anteil * 100.0])
	# 4) ruhendes Ziel 15 Grad (wie wende_4168, 3): ohne Schritte, gleich am Ziel
	p.held = null
	p.schaut = false
	for i in 60: await bild()
	p.blick = p.rotation.y + deg_to_rad(15.0)
	await bild()
	pruefe(p.wende == "", "ruhendes Ziel 15 Grad ohne Schritte (%s)" % p.wende)
	hin.queue_free()
	p.queue_free()
	print("WENDESCHRITT %d Fehler" % fehler)
	quit(1 if fehler else 0)
