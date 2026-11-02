# 385.2 (Chef 28.10., 19:1x, Archiv 385.1: Feuerpfeil und Feuerball „ohne dass was rauskommt“; Feuer aus dem Stab): der Magier im
# Kampfort zaubert Feuerpfeil (WZ_CastSpell6) und Feuerball (WZ_CastSpell4) mit den Bewegungen aus dem Zauberer-Set (held_kampf.py,
# gespiegelt: Stab rechts), das Feuer geht beim Loslassen von der Stabspitze los (figur.gd los_ms, kampf_ui.gd cast).
# Ohne Bild gemessen, je Zauber: die Bewegung läuft; Loslassen nach Beginn; das Feuer beginnt an der Stabspitze (F6: nicht im Körper,
# Abstand der Spitze zu den Kapseln um die Knochen); der Stab steckt in keinem Bild der Bewegung tiefer als 2 cm in einer Kapsel (E3,
# ohne den rechten Arm, der ihn hält) und nicht im Boden; Stabspitze und Ziel im Bild (G1).
# Run: godot --headless --path godot -s res://tests/stabfeuer_3852.gd   (Ende 0 = alles richtig; ohne Kaufdateien „ohne Kauf“, 0)
# Film (nur Probelauf nach 389): PROBE=3852 FILM=1 xvfb-run godot --path godot --resolution 540x1170 --write-movie <datei>.avi
# --fixed-fps 30 -s res://tests/stabfeuer_3852.gd   ->  je Zauber zweimal in Echtzeit, dazwischen Ruhe
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Figur = preload("res://kampf/figur.gd")
const Signatur = preload("res://kampf/signatur.gd")
const ARTEN := ["FIRE_BOLT", "FIREBALL"]
const TIEF_M := 0.02         # E3: höchstens 2 cm (Kapseln sind grob, Kleidung liegt darüber)
const BODEN_M := -0.02       # der Stab nicht im Boden
const OHNE := [9, 11]        # MENSCH_KAPSELN: rechter Ober- und Unterarm halten den Stab

var fails := 0
var film := OS.get_environment("FILM") != ""


func _initialize() -> void:
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	print(("ok     " if ok else "FEHLER ") + what)
	if not ok:
		fails += 1


func _kapseln(sk: Skeleton3D, ohne: Array) -> Array:
	var out := []
	var g := sk.global_transform
	for i in Figur.MENSCH_KAPSELN.size():
		var c: Array = Figur.MENSCH_KAPSELN[i]
		var i0 := sk.find_bone(c[0])
		var i1 := sk.find_bone(c[1])
		if i0 < 0 or i1 < 0 or i in ohne:
			continue
		var a: Vector3 = g * sk.get_bone_global_pose(i0).origin
		var b: Vector3 = g * sk.get_bone_global_pose(i1).origin
		if c[0] == "Head":
			a += g.basis.y.normalized() * 0.1
			b = a
		out.append([a, b, float(c[2]), c[0] + "-" + c[1]])
	return out


func _ecken(n: Node) -> PackedVector3Array:
	var out := PackedVector3Array()
	for mi in n.find_children("*", "MeshInstance3D", true, false) + ([n] if n is MeshInstance3D else []):
		var me := (mi as MeshInstance3D).mesh
		var t := (mi as MeshInstance3D).global_transform
		for s in me.get_surface_count():
			var vs: PackedVector3Array = me.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]
			for j in range(0, vs.size(), 3):     # jede dritte Ecke reicht für cm
				out.append(t * vs[j])
	return out


## [tiefste m, Kapsel]: wie tief ein Punkt in einer Kapsel liegt (negativ: Abstand davor)
func _tiefe(pts: PackedVector3Array, kap: Array) -> Array:
	var best := [-INF, ""]
	for p in pts:
		for c in kap:
			var q: Vector3 = Geometry3D.get_closest_point_to_segment(p, c[0], c[1])
			var t: float = float(c[2]) - p.distance_to(q)
			if t > best[0]:
				best = [t, c[3]]
	return best


func _run() -> void:
	if not FileAccess.file_exists("res://daten/kampf-bewegungen.bin") or not HeldFigur.da("WIZARD"):
		print("Stabfeuer 385.2: ohne Kauf, nichts zu prüfen")
		quit(0)
		return
	var deck := CanvasLayer.new()
	deck.layer = 128
	var schwarz := ColorRect.new()
	schwarz.color = Color.BLACK
	schwarz.set_anchors_preset(Control.PRESET_FULL_RECT)
	schwarz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	deck.add_child(schwarz)
	root.add_child(deck)
	var p = Probe.new()
	p.hero_cls = "WIZARD"
	p.merc_cls = "FIGHTER"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(int(OS.get_environment("SEED")) if OS.get_environment("SEED") != "" else 7)
	for i in 6:
		await process_frame
	var kf = p.fight
	var fig = kf.figures.get("hero")
	_check(fig != null and fig.kauf, "Magier auf dem Kaufkörper")
	if fig == null or not fig.kauf:
		quit(1)
		return
	if film and not Signatur.wache(kf, self, "Stabfeuer 385.2"):     # 457.2: Toon-Licht, Tusche nach Licht, Schatten wie im Spiel
		quit(1)
		return
	kf.playing = true     # der Kampf spielt währenddessen keine Meldungen ab (wie probe.gd ZAUBER)
	for i in 8:
		await process_frame
	for i in 8:
		await process_frame
		schwarz.color.a = 1.0 - (i + 1) / 8.0
	await _warte(1.0)
	var sk := fig._find(fig.model, "Skeleton3D") as Skeleton3D
	var stab := fig.model.find_child("Waffe", true, false) as Node3D
	_check(stab != null and stab.get_meta("stab", false), "Stab in der rechten Hand")
	var vs: Vector2 = kf.ui.overlay.get_viewport_rect().size
	for kind in ARTEN:
		for mal in (2 if film else 1):
			var foes: Array = kf.mars.fighters().filter(func(x): return x.side == "FOES" and x.standing())
			var on = kf.figures[foes[0].id]
			var t0: float = kf.clock_ms
			fig.strike(on, {"spell": kind, "roll": null})
			var wz := String(fig.anim.current_animation)
			var lang: float = fig.anim.get_animation(wz).length if fig.anim.has_animation(wz) else 0.0
			var los: int = fig.los_ms
			var step: float = kf.ui.cast(kind, "hero", foes[0].id, false, false)
			if mal == 0:
				_check(wz == Figur.WZ_BEW[kind], "%s: Bewegung %s (gespielt %s, %.2f s)" % [kind, Figur.WZ_BEW[kind], wz, lang])
				_check(los > 100 and los < lang * 1000.0, "%s: Loslassen nach %d ms" % [kind, los])
				_check(step >= los - 1.0, "%s: Feuer geht nach %.0f ms los, nicht vor dem Loslassen" % [kind, step])
			# jedes Bild der Bewegung: Stab gegen Körper und Boden; beim Loslassen die Stabspitze
			var tief := [-INF, ""]
			var boden := INF
			var start = null
			var spitze_bild := Vector2.ZERO
			while kf.clock_ms - t0 < lang * 1000.0 + 400.0:
				await process_frame
				if fig.anim.current_animation != wz:
					continue
				var e := _ecken(stab)
				var t: Array = _tiefe(e, _kapseln(sk, OHNE))
				if t[0] > tief[0]:
					tief = t
				for q in e:
					boden = minf(boden, q.y - fig.position.y)
				for sp in kf.ui.spells:
					if sp.by == "hero" and sp.kind == kind and sp.has("from") and start == null:
						start = sp["from"]
						spitze_bild = kf.screen_of(start)
			if mal > 0:
				await _warte(1.2)
				continue
			_check(tief[0] <= TIEF_M, "%s: Stab höchstens %.1f cm im Körper (%s; Grenze 2 cm)" % [kind, tief[0] * 100.0, tief[1]])
			_check(boden >= BODEN_M, "%s: Stab nicht im Boden (tiefster Punkt %.1f cm über dem Boden)" % [kind, boden * 100.0])
			_check(start != null, "%s: Feuer gezeichnet" % kind)
			if start != null:
				var d: Array = _tiefe(PackedVector3Array([start]), _kapseln(sk, []))
				_check(d[0] < 0.0, "%s: Feuer beginnt %.0f cm vor dem Körper (Stabspitze; nächste Kapsel %s)" % [kind, -d[0] * 100.0, d[1]])
				_check(Rect2(Vector2.ZERO, vs).has_point(spitze_bild), "%s: Stabspitze im Bild (%s von %s)" % [kind, spitze_bild, vs])
				print("STABFEUER %s: Loslassen %d ms von %.2f s, Spitze %.2f m über dem Boden" % [kind, los, lang, start.y - fig.position.y])
			await _warte(1.2)
	if film:
		for i in 8:
			await process_frame
			schwarz.color.a = (i + 1) / 8.0
	print("Stabfeuer 385.2: %d Fehler" % fails)
	quit(1 if fails > 0 else 0)


func _warte(s: float) -> void:
	var n := int(s * 30.0)
	for i in n:
		await process_frame
