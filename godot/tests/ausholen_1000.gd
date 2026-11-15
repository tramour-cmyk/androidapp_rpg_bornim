# 1000 (Tuffy 620.2c, wie 310 der alten Fassung): Grak hält nach der Ansage „Schwerer Hieb“ die ausholende Haltung bis zum Hieb.
# Echter Kampfort gegen Grak (jede Ansage ein Schwerer Hieb, ZUG=heavy wie der Reiter Test), der Held greift an, der Ring wird gut
# getroffen. Geprüft je Bild, von der Ansage (Meldung mit Absicht „heavy“) bis zu seinem Schlag (Meldung Grak → Ziel mit Wurf):
#  - die Haltung gilt (ausgeholt) und, sobald sie ganz da ist, liegt die rechte Faust über dem Kopf (Axt oben), auch auf dem Weg;
#  - der Hieb beginnt oben (Bewegung „Hieb“ ab OBEN_VON), nicht noch einmal aus Stehen;
#  - nach dem Hieb, beim Tod und ohne Ansage keine Haltung.
# Nur mit Graks Modell (kampf/daten aus grak_gestalt.py) aussagekräftig; ohne seinen Hieb: übersprungen (exit 0).
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/ausholen_1000.gd   (exit 0 = alles erfüllt)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const Aus = preload("res://kampf/ausholen.gd")
const FPS := 30.0
const RUNDEN := 3
## so weit (m, am Griff und 1 m weiter an Stiel und Schneide) darf die Axt in der gehaltenen Lage von ihrer Lage in der Faust abweichen
const AXT_LUFT := 0.08

var fehler := 0


func _initialize() -> void:
	_lauf.call_deferred()


func _gut(ok: bool, text: String) -> void:
	print(("gut " if ok else "FEHLER ") + text)
	if not ok:
		fehler += 1


## Höhe des Knochens [nm] in der Welt, wie er im Bild steht: nach den Schichten (ausholen.gd), gelesen in skeleton_updated
var hoehe := {}

func _hoch(_sk: Skeleton3D, nm: String) -> float:
	return float(hoehe.get(nm, NAN))


## 1000 (Fund t286.5a, Chef 15.11., 12:55: „die Axt … schwebt jetzt vor ihm. Wie Telekinese.“): Lage der Axt (Knochen „axt“) im
## Raum der rechten Faust, im Bild (nach den Schichten); [axt_ab] = Abstand (m) von der Lage aus Stehen vor der ersten Ansage,
## [axt_links] = Abstand (m) der linken Faust von ihrer Stelle am Stiel
var axt_halt = null
var axt_ab := 0.0
var axt_links := 0.0
var axt_links0 = null
var mit_axt := false

func _merke(sk: Skeleton3D) -> void:
	for nm in ["hand_r", "Head"]:
		var b := sk.find_bone(nm)
		if b >= 0:
			hoehe[nm] = (sk.global_transform * sk.get_bone_global_pose(b)).origin.y
	var a := sk.find_bone("axt")
	var h := sk.find_bone("hand_r")
	var l := sk.find_bone("hand_l")
	if a < 0 or h < 0:
		return
	mit_axt = true
	var m: float = sk.global_transform.basis.get_scale().x
	var halt := sk.get_bone_global_pose(h).affine_inverse() * sk.get_bone_global_pose(a)
	var links: Vector3 = sk.get_bone_global_pose(a).affine_inverse() * sk.get_bone_global_pose(l).origin if l >= 0 else Vector3.ZERO
	if axt_halt == null:
		axt_halt = halt
		axt_links0 = links
	# der Griff und ein Punkt 1 m weiter am Stiel: Ort und Richtung der Axt gegen die Faust
	var g: Transform3D = sk.get_bone_global_pose(h)
	axt_ab = 0.0
	for p in [Vector3.ZERO, Vector3(0, 1.0 / m, 0), Vector3(1.0 / m, 0, 0)]:
		axt_ab = maxf(axt_ab, ((g * halt * p) - (g * (axt_halt as Transform3D) * p)).length() * m)
	axt_links = (links - (axt_links0 as Vector3)).length() * m


func _lauf() -> void:
	seed(1000)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "GRAK"
	root.add_child(p)
	await process_frame
	p._start(1000)
	for i in 4:
		await process_frame
	var kf = p.fight
	kf.mars.find("merc").auto = true
	kf.ui.uhr = func() -> int: return int(Engine.get_process_frames() * 1000.0 / FPS)
	var grak = null
	for f in kf.figures.values():
		if f.fighter.monster != null and f.fighter.monster.id == "hobgoblin_captain":
			grak = f
	if grak != null and OS.get_environment("SCHAU_1000") != "":
		print("1000 Grak: Hieb %s, zwei %s, Wege %s, hieb %s" % [grak.anim != null and grak.anim.has_animation("Hieb"), grak._zweibeiner(), grak.weg.keys(), grak.hieb])
	if grak == null or not grak.kann_ausholen():
		print("übersprungen: Grak ohne Wurzelweg oder Hieb (kampf/daten aus grak_gestalt.py)")
		quit(0)
		return
	var sk: Skeleton3D = grak._find(grak.model, "Skeleton3D")
	sk.skeleton_updated.connect(_merke.bind(sk))
	while kf.verhuellt:
		await process_frame
	var n := 0
	var wahlen := 0
	var ring_seit := -1
	var letzte = null
	var angesagt := -1.0       # Zeit der Ansage, bis zum Schlag
	var ansagen := 0
	var schlaege := 0
	var ohne_haltung := 0      # Bilder zwischen Ansage und Schlag ohne Haltung
	var faust_unten := 0       # Bilder mit ganzer Haltung, die Faust nicht über dem Kopf
	var faust_bilder := 0
	var unterwegs := 0         # Bilder auf dem Weg zum Ziel (Gehen) mit ganzer Haltung
	var hieb_von := []         # Stelle in „Hieb“ im ersten Bild jedes Hiebs aus der Haltung
	var nach_hieb := 0         # Bilder nach dem Schlag mit Haltung, ohne neue Ansage
	var war_hieb := false
	var geschlagen := false
	var gehauen := false       # nach dem Schlag: „Hieb“ hat begonnen (davor geht er mit erhobener Axt zum Ziel)
	var kommt := false         # „Schwerer Hieb!“ gefallen, der Schlag folgt
	var vereitelt := 0
	var vereitelt_t := -1.0
	var oben_nach_vereitelt := 0   # Bilder ab 0,6 s nach dem Aus-dem-Tritt-Kommen noch mit Haltung, ohne neue Ansage
	var axt_weg := 0.0             # größter Abstand der Axt von ihrer Lage in der rechten Faust, solange Grak steht (m)
	var axt_weg_bei := ""
	var links_weg := 0.0           # größter Abstand der linken Faust von ihrer Stelle am Stiel bei ganzer Haltung (m)
	Mars.test_gegnerzug = "heavy"
	while n < int(FPS) * 240:
		await process_frame
		n += 1
		if Mars.test_gegnerzug == "":
			Mars.test_gegnerzug = "heavy"
		var t := n / FPS
		if kf.mars.outcome != "ONGOING" and not kf.busy and not kf.playing and kf.beats.is_empty():
			break
		if not is_same(kf.shown, letzte) and kf.shown is Dictionary and kf.shown.has("text"):
			letzte = kf.shown
			var e: Dictionary = kf.shown
			var it = e.intents.get(grak.fighter.id)
			if OS.get_environment("SCHAU_1000") != "":
				print("1000 Meldung %.2f %s %s %s | %s" % [t, e.actor, e.get("cue"), it[0].id if it != null else "-", String(e.text).left(60)])
			if it != null and String(it[0].id) == "heavy" and angesagt < 0.0:
				angesagt = t
				ansagen += 1
				geschlagen = false
				gehauen = false
				vereitelt_t = -1.0
			if e.actor == grak.fighter.id and e.roll != null and angesagt >= 0.0:
				angesagt = -1.0
				schlaege += 1
				geschlagen = true
				kommt = false
			elif e.get("cue") == "FOE_STRIKES" and e.actor == grak.fighter.id and angesagt >= 0.0:
				kommt = true
			elif angesagt >= 0.0 and it == null and not kommt:
				angesagt = -1.0     # aus dem Tritt: die Ansage ist ohne Hieb weg, er senkt die Axt
				vereitelt += 1
				vereitelt_t = t
		var cur := String(grak.anim.current_animation)
		if OS.get_environment("SCHAU_1000") != "":
			var zust := "%s %s %.2f %s" % [cur, grak.ausgeholt(), grak.ausholer.gewicht if grak.ausholer != null else -1.0, grak.schlag_kommt]
			if zust != get_meta("z", ""):
				set_meta("z", zust)
				print("1000 %.2f %s | angesagt %.2f | Faust %.2f Kopf %.2f | %s" % [t, zust, angesagt, _hoch(sk, "hand_r"), _hoch(sk, "Head"), String(kf.shown.get("text", "")).left(50) if kf.shown is Dictionary else ""])
		if cur == "Hieb" and not war_hieb and grak.ausholer != null and geschlagen:
			hieb_von.append(grak.anim.current_animation_position)
		war_hieb = cur == "Hieb"
		# 1000 (t286.5a): die Axt liegt in jedem Bild in der rechten Faust (im Tod lässt er sie fallen)
		# (gemessen, solange die Schicht wirkt: im Hieb selbst führt die Bewegung die Axt, abgenommen; ohne Schicht weicht die Axt beim
		# Überblenden Stehen/Gehen bis 0,11 m ab, das ist der Stand vor 1000)
		if mit_axt and not grak.down and cur != "Tod" and cur != "Hieb" and grak.ausholer != null and grak.ausholer.gewicht > 0.02:
			if axt_ab > axt_weg:
				axt_weg = axt_ab
				axt_weg_bei = "%.2f s %s, Haltung %.2f" % [t, cur, grak.ausholer.gewicht if grak.ausholer != null else 0.0]
			if grak.ausgeholt() and grak.ausholer.gewicht > 0.95:
				links_weg = maxf(links_weg, axt_links)
		if geschlagen and cur == "Hieb":
			gehauen = true
		# Einzelbild für die eigene Prüfung (BILD_1000=<Ordner>, nur mit Bild): daheim ganz ausgeholt, dann unterwegs
		var ordner := OS.get_environment("BILD_1000")
		if ordner != "" and DisplayServer.get_name() != "headless" and grak.ausgeholt() and grak.ausholer.gewicht > 0.98:
			var art := "unterwegs" if cur == "Gehen" and grak.lunging() else ("daheim" if cur == "Stehen" else "")
			if art != "" and not has_meta(art):
				set_meta(art, true)
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png("%s/1000-%s.png" % [ordner, art])
				print("1000 Bild %s bei %.2f s" % [art, t])
		if angesagt >= 0.0 and t - angesagt > 0.1:
			if not grak.ausgeholt():
				ohne_haltung += 1
			elif grak.ausholer.gewicht > 0.95:
				faust_bilder += 1
				if cur == "Gehen" and grak.lunging():
					unterwegs += 1
				if not (_hoch(sk, "hand_r") > _hoch(sk, "Head")):
					faust_unten += 1
		elif angesagt < 0.0 and gehauen and grak.ausgeholt() and cur != "Hieb":
			nach_hieb += 1
			if OS.get_environment("SCHAU_1000") != "" and nach_hieb % 15 == 1:
				print("1000 nach Hieb %.2f %s %.2f" % [t, cur, grak.ausholer.gewicht])
		if angesagt < 0.0 and vereitelt_t >= 0.0 and t - vereitelt_t > 0.6 and grak.ausholer != null and grak.ausholer.gewicht > 0.1:
			oben_nach_vereitelt += 1
		# der Spieler: Angriff auf das erste Ziel, Ring nach RING_MS gut
		if kf.ring_open:
			if ring_seit < 0:
				ring_seit = n
			elif n - ring_seit >= int(kf.RING_MS / 1000.0 * FPS):
				kf._answer_ring(Mars.GOOD)
		else:
			ring_seit = -1
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			if kf.mars.pilot_next():
				kf.go_on()
			else:
				if wahlen >= RUNDEN:
					break
				wahlen += 1
				var ts: Array = kf.mars.targets(kf.mars.current())
				kf.order(["attack", ts[0].id] if not ts.is_empty() else ["wait"])
	_gut(ansagen > 0 and schlaege > 0, "Ansagen %d, Schläge daraus %d" % [ansagen, schlaege])
	_gut(ohne_haltung == 0, "von der Ansage bis zum Schlag immer ausgeholt (%d Bilder ohne)" % ohne_haltung)
	_gut(faust_bilder > 0 and faust_unten == 0, "Axt oben: rechte Faust über dem Kopf in %d von %d Bildern mit ganzer Haltung" % [faust_bilder - faust_unten, faust_bilder])
	if mit_axt:
		_gut(axt_weg_bei != "" and axt_weg <= AXT_LUFT, "Axt in der rechten Faust: höchstens %.3f m von ihrer Lage in der Faust (%s)" % [axt_weg, axt_weg_bei])
		_gut(links_weg <= 0.05, "linke Faust am Stiel bei ganzer Haltung: höchstens %.3f m daneben" % links_weg)
	_gut(unterwegs > 0, "auf dem Weg zum Ziel ausgeholt: %d Bilder" % unterwegs)
	var tief: float = hieb_von.reduce(func(a, b): return minf(a, b), INF) if not hieb_von.is_empty() else -1.0
	_gut(not hieb_von.is_empty() and tief >= Aus.OBEN_VON - 0.05, "Hieb beginnt oben: erste Stelle in „Hieb“ %s" % [hieb_von])
	print("aus dem Tritt (Ansage ohne Hieb weg): %d" % vereitelt)
	_gut(oben_nach_vereitelt == 0, "aus dem Tritt: Axt nach 0,6 s unten (%d Bilder noch oben)" % oben_nach_vereitelt)
	_gut(nach_hieb == 0, "nach dem Schlag ohne neue Ansage keine Haltung (%d Bilder)" % nach_hieb)
	print("AUSHOLEN1000 %s" % ("gut" if fehler == 0 else "FALSCH %d" % fehler))
	quit(1 if fehler else 0)
