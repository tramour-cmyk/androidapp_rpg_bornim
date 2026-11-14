extends SceneTree
# 601 (Chef 05.11., Build 266, t266.5: „Goblinspäher Schussanimation nicht vorhanden“): die Schussbewegung (kampf/schuss.gd) auf
# einem Gerüst mit den Knochen des Goblins (UAL-Namen, goblin.py), ohne Modelle. Geprüft je Phase, gemessen nach den Modifikatoren
# (Schritte von Hand, je Schritt die Ruhelage wie der Skeleton3D vor seinen Modifikatoren): im Zielen zeigt der Bogenarm auf das Ziel (höchstens 15° daneben, gestreckt), die Zughand liegt vor dem
# Hals (näher als eine Schulterbreite), die linke Schulter ist dem Ziel zugedreht; vor dem Schuss und danach hängen die Arme wie
# ohne Schicht; „fertig“ kommt einmal; mit verschieben() beginnt das Heben erst nach der Wartezeit. Ohne Bild, Sekunden.
# Aufruf: im Ordner godot mit -s res://tests/schuss_601.gd   (Exit 0 = gut)

const Schuss = preload("res://kampf/schuss.gd")
const KampfUI = preload("res://kampf/kampf_ui.gd")


## Stellvertreter für Figur und Kampfschirm (nur, was der Pfeil fragt)
class Fig extends Node3D:
	var kopf := 1.4
	func head() -> Vector3:
		return position + Vector3.UP * kopf
	func cast_point():
		return position + Vector3(0, 1.0, 0.3)
	func hand_welt(_k: String):
		return position + Vector3(0, 1.1, 0.0)


class UI extends Node:
	func _aim_point(on, dir: Vector3) -> Vector3:
		return on.position + Vector3.UP * 0.77 - dir * 0.3
	func _miss_point(_by, on, _f: bool) -> Vector3:
		return on.position + Vector3(1.0, 0, -0.4)

const KNOCHEN := [
	["pelvis", "", Vector3(0, 1.0, 0)], ["spine_01", "pelvis", Vector3(0, 0.1, 0)], ["spine_02", "spine_01", Vector3(0, 0.15, 0)],
	["spine_03", "spine_02", Vector3(0, 0.15, 0)], ["neck_01", "spine_03", Vector3(0, 0.15, 0)], ["Head", "neck_01", Vector3(0, 0.1, 0)],
	["clavicle_l", "spine_03", Vector3(0.05, 0.1, 0)], ["upperarm_l", "clavicle_l", Vector3(0.15, 0, 0)],
	["lowerarm_l", "upperarm_l", Vector3(0, -0.28, 0)], ["hand_l", "lowerarm_l", Vector3(0, -0.26, 0)],
	["clavicle_r", "spine_03", Vector3(-0.05, 0.1, 0)], ["upperarm_r", "clavicle_r", Vector3(-0.15, 0, 0)],
	["lowerarm_r", "upperarm_r", Vector3(0, -0.28, 0)], ["hand_r", "lowerarm_r", Vector3(0, -0.26, 0)],
]
const ZIEL := Vector3(0.0, 1.3, 6.0)

var sk: Skeleton3D
var sch
var fehler := 0
var messung := {}
var fertig := 0


func _initialize() -> void:
	_run.call_deferred()


func _gerust() -> Skeleton3D:
	var s := Skeleton3D.new()
	for k in KNOCHEN:
		var b := s.add_bone(k[0])
		if k[1] != "":
			s.set_bone_parent(b, s.find_bone(k[1]))
		s.set_bone_rest(b, Transform3D(Basis.IDENTITY, k[2]))
	s.reset_bone_poses()
	return s


func _p(n: String) -> Vector3:
	return sk.get_bone_global_pose(sk.find_bone(n)).origin


func _gemessen() -> void:
	var sl := _p("upperarm_l")
	var sr := _p("upperarm_r")
	messung = {"t": sch.t, "sl": sl, "sr": sr, "ell_l": _p("lowerarm_l"), "hl": _p("hand_l"), "hr": _p("hand_r"), "hals": _p("neck_01")}


func _schritt() -> void:
	sk.reset_bone_poses()
	sch._process_modification_with_delta(1.0 / 30.0)
	_gemessen()


func _warte_bis(x: float) -> void:
	var n := 0
	while (sch.t < x and sch.t >= 0.0) or (sch.an() and sch.t < 0.0):
		_schritt()
		n += 1
		if n > 600:
			break


func _pruef(name: String, gut: bool, wert: String) -> void:
	print("SCHUSS601 %s: %s (%s)" % [name, "gut" if gut else "FEHLER", wert])
	if not gut:
		fehler += 1


func _run() -> void:
	sk = _gerust()
	root.add_child(sk)
	sch = Schuss.new()
	if not sch.einrichten(sk):
		_pruef("Knochen", false, "einrichten() fand die Arme nicht")
		quit(1)
		return
	sch.active = false     # der Test führt die Schritte selbst (sonst rechnete der Skeleton3D zusätzlich)
	sk.add_child(sch)
	sch.fertig.connect(func(): fertig += 1)
	await process_frame
	_schritt()
	var ruhe_hl: Vector3 = messung.hl
	var ruhe_hr: Vector3 = messung.hr
	sch.schiessen(ZIEL)
	_warte_bis(0.6)
	var m := messung
	var breite: float = (m.sl - m.sr).length()
	var soll: Vector3 = (ZIEL - m.sl).normalized()
	var arm: Vector3 = (m.hl - m.sl).normalized()
	var w := rad_to_deg(acos(clampf(arm.dot(soll), -1.0, 1.0)))
	_pruef("Bogenarm auf das Ziel", w <= 15.0, "%.1f° daneben bei t %.2f" % [w, m.t])
	var gestreckt: float = (m.hl - m.sl).length() / ((m.ell_l - m.sl).length() + (m.hl - m.ell_l).length())
	_pruef("Bogenarm gestreckt", gestreckt >= 0.95, "%.2f der Armlänge" % gestreckt)
	var am_hals: float = (m.hr - m.hals).length()
	_pruef("Zughand vor dem Hals", am_hals < breite, "%.2f m, Schulterbreite %.2f" % [am_hals, breite])
	var quer := Vector3(m.sl.x - m.sr.x, 0, m.sl.z - m.sr.z).normalized()
	var zu := Vector3(ZIEL.x, 0, ZIEL.z).normalized()
	var dreh := rad_to_deg(acos(clampf(quer.dot(zu), -1.0, 1.0)))
	_pruef("linke Schulter zum Ziel", dreh <= 90.0 * (1.0 - Schuss.RUMPF) + 10.0, "%.0f° (ohne Drehung 90°)" % dreh)
	_warte_bis(Schuss.LOS - 0.03)
	var hr_los: Vector3 = messung.hr
	_warte_bis(Schuss.NACH_BIS)
	var zurueck: float = -(messung.hr - hr_los).dot(soll)
	_pruef("Zughand schnellt beim Lösen zurück", zurueck > breite * 0.2, "%.2f m" % zurueck)
	_warte_bis(Schuss.DAUER + 0.1)
	for i in 3:
		_schritt()
	var aus: float = maxf((messung.hl - ruhe_hl).length(), (messung.hr - ruhe_hr).length())
	_pruef("danach Arme wie vorher", aus < 0.01, "%.3f m" % aus)
	_pruef("fertig einmal", fertig == 1, "%d" % fertig)
	# verschieben: erst nach 0,3 s heben
	sch.schiessen(ZIEL)
	sch.verschieben(0.3)
	for i in 5:
		_schritt()
	var still: float = (messung.hl - ruhe_hl).length()
	_pruef("verschoben: wartet", still < 0.01 and sch.an(), "%.3f m bewegt" % still)
	await _pfeile()
	print("SCHUSS601 %s" % ("alles gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)


## der Pfeil (kampf_ui.gd Pfeil): Körper Nocke im Ursprung, Spitze vorn; Treffer: Spitze ein Fünftel im Ziel, hängt dann am Ziel;
## daneben: steckt hinter dem Ziel im Boden; nach dem Stecken vergeht er
func _pfeile() -> void:
	for missed in [false, true]:
		var by := Fig.new()
		var on := Fig.new()
		var ui := UI.new()
		root.add_child(ui)
		root.add_child(by)
		root.add_child(on)
		on.position = Vector3(0, 0, 5)
		var p = KampfUI.Pfeil.new()
		p.lang = 0.7
		p.koerper = KampfUI.pfeil_koerper(p.lang)
		p.add_child(p.koerper)
		p.ui = ui
		p.by = by
		p.on = on
		p.missed = missed
		p.auf_s = 0.0
		p.los_s = 0.5
		p.flug_s = 0.45
		root.add_child(p)
		var auf_sehne := false
		var n := 0
		while p.phase != "steckt" and n < 200:
			await process_frame
			n += 1
			auf_sehne = auf_sehne or (p.phase == "sehne" and p.visible)
		var spitze: Vector3 = p.global_position - p.global_transform.basis.z * p.lang
		var name := "daneben" if missed else "Treffer"
		_pruef("Pfeil %s auf der Sehne" % name, auf_sehne, p.koerper.get_meta("quelle"))
		if missed:
			_pruef("Pfeil daneben im Boden", absf(spitze.y) < 0.2 and spitze.distance_to(on.position) > 0.5,
				"Spitze %s" % spitze)
		else:
			var soll: Vector3 = ui._aim_point(on, Vector3.BACK)
			_pruef("Pfeil trifft", spitze.distance_to(soll) < p.lang * 0.35 and p.get_parent() == on, "Spitze %.2f m vom Ziel, hängt an %s" % [spitze.distance_to(soll), p.get_parent().name])
		while is_instance_valid(p) and n < 400:
			await process_frame
			n += 1
		_pruef("Pfeil %s vergeht" % name, not is_instance_valid(p), "%d Bilder" % n)
		by.queue_free()
		on.queue_free()
		ui.queue_free()
	var st = KampfUI.spur_r3()
	print("SCHUSS601 Spur R3: %s" % ("da, gedämpft %s" % str(st.color_ramp.get_color(0)) if st != null else "nicht da (ohne Kaufpaket)"))
