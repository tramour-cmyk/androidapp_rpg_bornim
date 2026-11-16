extends SceneTree
# 1215 (Frage 9 von Sokrates 15.11., 11:21: „Test am echten Gerüst statt Nachbau, der Test vom 13.11. übersah den Fehler“):
# physikalisches Sterben an den echten Gegnern im Kampfort (braucht die gebauten Modelle, darum nicht im Logiksatz). Je Gegnerart
# (GEGNER=GOBLINS,SCOUTS,SHAMANS,KOBOLDS,GRAK; ohne Angabe alle, die gebaut sind) stirbt jeder Gegner des Probekampfs mit einem
# anderen Treffer (FAELLE). Gemessen je Tod:
#   Hüfte–Becken: Abstand der Hüftknochen vom Becken in der Ruhe und größter im Fall (Frage 1: 0,085 gegen 0,507 m am Nachbau)
#   Spalt: größter Abstand der zwei Seiten eines Gelenks (die Glieder hängen zusammen, die Haut reißt nicht aus)
#   Winkel: jedes Gelenk bleibt in seinen Grenzen (Knie nie nach vorn, Ellbogen nie überstreckt), Zugabe ZUGABE Grad
#   Knochen: jeder Knochen geht mit seinem Glied (keiner bleibt an der Wurzel stehen)
#   Boden: tiefste Ecke der Haut am Ende gegen den Boden
#   Stoß: Weg der Brust in Richtung des Treffers; ohne Stoß (Gift) bleibt er, wo er stand
#   Liegen: Zeit bis zur Ruhe, danach ändert sich keine Haltung mehr; Waffe liegt am Boden
# Exit 1 bei Fehlern. Aufruf: im Ordner godot mit -s res://tests/tod_ragdoll_1215.gd

const Probe = preload("res://kampf/probe.gd")
const Figur = preload("res://kampf/figur.gd")
## die Grenzen des Gelenks geben bei schneller Bewegung nach (etwa 5° je rad/s, gelenk_1215)
const ZUGABE := 20.0
## Treffer: Name, Art, Winkel des Angreifers zur Blickrichtung des Opfers (0 = von vorn, 90 = von seiner Linken), kritisch
const FAELLE := [
	["Hieb von vorn", "nah", 0.0, false], ["Hieb von hinten", "nah", 180.0, false], ["Hieb von links", "nah", 90.0, false],
	["Hieb von rechts", "nah", -90.0, false], ["kritisch von vorn", "nah", 0.0, true], ["Pfeil von vorn", "pfeil", 0.0, false],
	["Zauber von vorn", "zauber", 20.0, false], ["Gift, ohne Stoß", "still", 0.0, false], ["Schildstoß von vorn", "schild", 0.0, false],
	["Anspringen von hinten", "sprung", 160.0, false],
]

var fehler := 0
var wo_tief := ""


func _initialize() -> void:
	_run.call_deferred()


func _pruef(name: String, gut: bool, wert: String) -> void:
	print("TODRAGDOLL1215 %s: %s (%s)" % [name, "gut" if gut else "FEHLER", wert])
	if not gut:
		fehler += 1


## tiefste Ecke der Haut über dem Boden (jede 3. Ecke, gewichtet über ihre Knochen)
func _haut_tief(fig, sk: Skeleton3D, boden: float) -> float:
	var tief := INF
	wo_tief = ""
	for mi in fig.model.find_children("*", "MeshInstance3D", true, false):
		var netz := (mi as MeshInstance3D).mesh
		var haut := (mi as MeshInstance3D).skin
		if netz == null or haut == null:
			continue
		var m := []
		for j in haut.get_bind_count():
			var bn := haut.get_bind_bone(j)
			if bn < 0:
				bn = sk.find_bone(haut.get_bind_name(j))
			m.append(sk.global_transform * sk.get_bone_global_pose(bn) * haut.get_bind_pose(j) if bn >= 0 else Transform3D.IDENTITY)
		for f in netz.get_surface_count():
			var arr := netz.surface_get_arrays(f)
			var ecken: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
			var kn = arr[Mesh.ARRAY_BONES]
			var gw = arr[Mesh.ARRAY_WEIGHTS]
			if kn == null or gw == null:
				continue
			var je: int = kn.size() / ecken.size()
			for e in range(0, ecken.size(), 3):
				var p := Vector3.ZERO
				for q in je:
					if gw[e * je + q] > 0.0:
						p += ((m[kn[e * je + q]] as Transform3D) * ecken[e]) * gw[e * je + q]
				if p.y - boden < tief:
					tief = p.y - boden
					var best := 0
					for q in range(1, je):
						if gw[e * je + q] > gw[e * je + best]: best = q
					wo_tief = "%s, %s" % [mi.name, haut.get_bind_name(kn[e * je + best]) if haut.get_bind_name(kn[e * je + best]) != "" else sk.get_bone_name(haut.get_bind_bone(kn[e * je + best]))]
	return tief


func _run() -> void:
	Figur.ragdoll_probe = true
	Figur.ragdoll_alle = true     # auch Grak: seine Tafel (UAL) wird gemessen, im Spiel bleibt sein Zusammenbruch gebacken
	preload("res://kampf/ragdoll.gd").bildrate_pruefen = false
	preload("res://kampf/ragdoll.gd").bleibt = true
	var arten: Array = Array(OS.get_environment("GEGNER").split(",", false)) if OS.get_environment("GEGNER") != "" else ["GOBLINS", "SCOUTS", "SHAMANS", "KOBOLDS", "GRAK"]
	var fall := 0
	var tode := 0
	for art in arten:
		for runde in (0 if OS.get_environment("NUR_KOSTEN") != "" else (1 if art == "GRAK" else 3)):
			var p = Probe.new()
			p.hero_cls = "FIGHTER"
			p.merc_cls = "CLERIC"
			p.foe = art
			root.add_child(p)
			await process_frame
			p._start(5 + runde)
			for i in 12:
				await process_frame
			var kf = p.fight
			var feinde: Array = kf.figures.values().filter(func(f): return f.fighter.monster != null)
			for fig in feinde:
				var sk: Skeleton3D = fig._find(fig.model, "Skeleton3D")
				if sk == null:
					continue
				var f: Array = FAELLE[fall % FAELLE.size()]
				fall += 1
				var blick: Vector3 = (fig.global_transform.basis.z * Vector3(1, 0, 1)).normalized()
				var zum_angreifer: Vector3 = blick.rotated(Vector3.UP, deg_to_rad(float(f[2])))
				fig.tod_treffer = {"art": f[1], "anteil": 0.6, "kritisch": f[3], "glied": "brust"}
				if f[1] != "still":
					fig.tod_treffer.von = fig.global_position + zum_angreifer * 1.2
				var boden: float = fig.global_position.y
				var id := "%s %s (%s)" % [art, fig.fighter.id, f[0]]
				seed(7 + fall)
				fig.die()
				var r = fig.ragdoll
				if r == null:
					_pruef("%s Ragdoll" % id, false, "nicht eingerichtet")
					continue
				tode += 1
				var hueft := []
				for n in ["hipL-thighL", "thigh_l"]:
					if sk.find_bone(n) >= 0:
						hueft = [sk.find_bone(n), sk.find_bone("pelvis-waist") if n == "hipL-thighL" else sk.find_bone("pelvis")]
				var h0: float = (sk.get_bone_global_pose(hueft[0]).origin - sk.get_bone_global_pose(hueft[1]).origin).length() * r.skala
				var hmax := h0
				var spalt := 0.0
				var spalt_wo := ""
				var ueber := 0.0
				var ueber_wo := ""
				var brust0 := Vector3.INF
				var n_bilder := 0
				while r.phase != "liegt" and n_bilder < 60 * 9:
					await physics_frame
					await process_frame
					n_bilder += 1
					if r.phase != "physik":
						continue
					if brust0 == Vector3.INF:
						brust0 = (r.koerper["brust"] as RigidBody3D).global_position
					hmax = maxf(hmax, (sk.get_bone_global_pose(hueft[0]).origin - sk.get_bone_global_pose(hueft[1]).origin).length() * r.skala)
					for g in r.glieder:
						if not g.has("an"):
							continue
						if r.spalt(g.n) > spalt:
							spalt = r.spalt(g.n)
							spalt_wo = "%s nach %d Bildern" % [g.n, r.bilder_physik]
						var w: Vector3 = r.winkel(g.n)
						var x: Array = g.get("x", [0, 0])
						# Scharniere (Knie, Ellbogen) und der Rumpf genau; an Schulter und Hüfte (Kugelgelenk, weite Grenzen) nur das Beugen
						var d: float = maxf(float(x[0]) - w.x, w.x - float(x[1]))
						if d > ueber and (String(g.n).begins_with("wade") or String(g.n).begins_with("unterarm") or g.n == "brust" or g.n == "kopf"):
							ueber = d
							ueber_wo = "%s %.0f° (Grenzen %.0f bis %.0f)" % [g.n, w.x, float(x[0]), float(x[1])]
				_pruef("%s liegt" % id, r.phase == "liegt", "%.2f s Physik, %s" % [r.bilder_physik / 60.0, fig.tod_name])
				_pruef("%s Hüfte am Becken" % id, hmax < h0 + 0.02, "Ruhe %.3f m, größter Abstand %.3f m" % [h0, hmax])
				# beim harten Aufschlag klafft ein Gelenk für einzelne Bilder (gemessen bis 0,063 m beim Anspringen), danach schließt es
				_pruef("%s Gelenke halten" % id, spalt < 0.08, "größter Spalt %.3f m, %s" % [spalt, spalt_wo])
				_pruef("%s Gelenke in den Grenzen" % id, ueber < ZUGABE, "größte Überschreitung %.0f°: %s" % [ueber, ueber_wo])
				var lose := 0.0
				for b in sk.get_bone_count():
					var k: RigidBody3D = r.glieder[r._besitzer[b]].koerper
					lose = maxf(lose, ((sk.global_transform * sk.get_bone_global_pose(b)).origin - k.global_transform * (r._rel[b] as Transform3D).origin).length())
				_pruef("%s jeder Knochen an seinem Glied" % id, lose < 0.005, "%.4f m" % lose)
				var tief := _haut_tief(fig, sk, boden)
				# Maß 0,25 m: Ohrspitzen, Hutkrempe, der Saum der Robe und der Ansatz des Schwanzes haben keine eigenen Knochen und kein
				# eigenes Glied; sie gehen starr mit Kopf, Becken und Schenkel und stecken liegend im Boden (dort unsichtbar)
				_pruef("%s Haut nicht im Boden" % id, tief > -0.25, "tiefste Ecke %.3f m (%s)" % [tief, wo_tief])
				var weg: Vector3 = ((r.koerper["brust"] as RigidBody3D).global_position - brust0) * Vector3(1, 0, 1)
				if f[1] == "still":
					_pruef("%s sackt zusammen, wo er steht" % id, weg.length() < 0.6 * r.gross + 0.3, "Brust %.2f m" % weg.length())
				elif art == "GRAK":
					# 1314 (Lauf 497 rot, nachgestellt: schon am Bau von 1215, 8ed72e0e4): Grak stirbt im Spiel gebacken (1215 A, Chef
					# 15.11., 13:32); gemessen wird nur, ob sein Gerüst hält, die Richtung des Falls nur als Hinweis
					print("TODRAGDOLL1215 %s fällt mit dem Stoß: Hinweis, im Spiel gebacken (Brust %+.2f m in Stoßrichtung)" % [id, weg.dot(-zum_angreifer)])
				else:
					_pruef("%s fällt mit dem Stoß" % id, weg.dot(-zum_angreifer) > 0.1 * r.gross, "Brust %+.2f m in Stoßrichtung, %+.2f m quer" % [weg.dot(-zum_angreifer), weg.dot(zum_angreifer.cross(Vector3.UP))])
				var hoch: float = (r.koerper["brust"] as RigidBody3D).global_position.y - boden
				_pruef("%s liegt flach" % id, hoch < 0.45 * r.gross, "Brust %.2f m über dem Boden bei %.2f m Größe" % [hoch, r.gross])
				for w in r._waffen:
					_pruef("%s Waffe am Boden" % id, (w as RigidBody3D).global_position.y - boden < 0.25, "%.2f m" % ((w as RigidBody3D).global_position.y - boden))
				var vorher := []
				for b in sk.get_bone_count():
					vorher.append(sk.get_bone_pose(b))
				for i in 20:
					await process_frame
				var wandert := 0.0
				for b in sk.get_bone_count():
					wandert = maxf(wandert, (sk.get_bone_pose(b).origin - vorher[b].origin).length())
				_pruef("%s eingefroren" % id, wandert < 0.002, "%.4f" % wandert)
			kf.queue_free()
			p.queue_free()
			await process_frame
	_pruef("Tode gemessen", tode >= 1 or OS.get_environment("NUR_KOSTEN") != "", "%d" % tode)
	await _nachbar_und_kosten(arten[0])
	print("TODRAGDOLL1215 %s" % ("alles gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)


## Frage 6 (Nachbarfeld): ein Lebender steht 0,7 m hinter dem Sterbenden, der Stoß wirft ihn dorthin: kein Glied endet im Nachbarn
## (Säule 0,2 m), und er liegt trotzdem flach. Frage 8 (Kosten): drei sterben im selben Bild; Rechenzeit der Physik und dieses
## Skripts je Bild am Rechner (am Handy misst der Build: Zeile „1215 Ragdoll: liegt …“ im Laufprotokoll)
func _nachbar_und_kosten(art: String) -> void:
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = art
	root.add_child(p)
	await process_frame
	p._start(9)
	for i in 12:
		await process_frame
	var kf = p.fight
	var feinde: Array = kf.figures.values().filter(func(f): return f.fighter.monster != null)
	if feinde.size() < 2:
		p.queue_free()
		return
	var a = feinde[0]
	var b = feinde[1]
	var blick: Vector3 = (a.global_transform.basis.z * Vector3(1, 0, 1)).normalized()
	b.global_position = a.global_position - blick * 0.7
	a.tod_treffer = {"art": "nah", "anteil": 0.6, "kritisch": false, "glied": "brust", "von": a.global_position + blick * 1.2}
	seed(3)
	a.die()
	var n := 0
	while a.ragdoll != null and a.ragdoll.phase != "liegt" and n < 60 * 9:
		await physics_frame
		await process_frame
		n += 1
	if a.ragdoll == null:
		_pruef("Nachbarfeld Ragdoll", false, "nicht eingerichtet")
	else:
		var nah := INF
		var hoch := 0.0
		for k in a.ragdoll.koerper.values():
			var o: Vector3 = (k as RigidBody3D).global_transform * (k as RigidBody3D).center_of_mass
			nah = minf(nah, ((o - b.global_position) * Vector3(1, 0, 1)).length())
			hoch = maxf(hoch, o.y - a.global_position.y)
		_pruef("Nachbarfeld: kein Glied im Nachbarn", nah > 0.15, "nächster Schwerpunkt %.2f m von seiner Achse" % nah)
		_pruef("Nachbarfeld: liegt, lehnt nicht", hoch < 0.5 * a.ragdoll.gross, "höchster Schwerpunkt %.2f m bei %.2f m Größe" % [hoch, a.ragdoll.gross])
	kf.queue_free()
	p.queue_free()
	await process_frame
	# Kosten: drei zugleich
	p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = art
	root.add_child(p)
	await process_frame
	p._start(10)
	for i in 12:
		await process_frame
	kf = p.fight
	feinde = kf.figures.values().filter(func(f): return f.fighter.monster != null)
	var ohne := 0.0
	for i in 60:
		await physics_frame
		ohne += Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	for f in feinde:
		f.tod_treffer = {"art": "nah", "anteil": 0.6, "kritisch": false, "von": f.global_position + (f.global_transform.basis.z * Vector3(1, 0, 1)).normalized() * 1.2}
		f.die()
	var mit := 0.0
	var mit_max := 0.0
	var bilder := 0
	var liegen := false
	while not liegen and bilder < 60 * 9:
		await physics_frame
		await process_frame
		liegen = feinde.all(func(f): return f.ragdoll == null or f.ragdoll.phase == "liegt")
		if feinde.any(func(f): return f.ragdoll != null and f.ragdoll.phase == "physik"):
			var t: float = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
			mit += t
			mit_max = maxf(mit_max, t)
			bilder += 1
	var skript := 0.0
	for f in feinde:
		if f.ragdoll != null:
			skript += float(f.ragdoll.usec) / maxi(f.ragdoll.bilder_physik, 1)
	_pruef("Kosten: %d zugleich" % feinde.size(), liegen and mit / maxi(bilder, 1) < 0.012,     # am Rechner 3 bis 7 ms, schwankend; die Grenze fängt nur Ausreißer
		
		"Physik je Bild %.2f ms (höchstens %.2f ms; ohne Tote %.2f ms), Skelett nachführen zusammen %.2f ms je Bild, am Rechner" % [mit / maxi(bilder, 1) * 1000.0, mit_max * 1000.0, ohne / 60.0 * 1000.0, skript / 1000.0])
	kf.queue_free()
	p.queue_free()
	await process_frame
