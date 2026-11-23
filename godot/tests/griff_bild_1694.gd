extends SceneTree
# 1694 (23.11., Einzelbild Handbeil: Netzmessung 340° Umschlingung, im Bild liegt der Stiel zwischen gespreizten Fingern, Daumen offen):
# Prüfung nach dem, was die Kamera sieht (Profil Figur „Messen“: das Bild gilt), am Held im Dorf, angehalten in der Endpose. Die Prüfung
# selbst ist NetzMess.sicht (gleich in griff_alle_1694): Kamera nah an der Faust, innen (Handfläche) und außen (Handrücken), gezählt wird
# das Stück des Schafts in der Faust, das zu sehen ist (ohne schmale Schlitze zwischen den Fingern). Daneben die Netzmessung im selben Bild.
#   NUR=<waffe> [BILDER=<ordner>] xvfb-run -a godot --path . --resolution 540x1170 -s res://tests/griff_bild_1694.gd -- --sehen1694
#   (Exit 1 bei Fehler; ohne Argument nach -- liegt das Hauptmenü vor der Szene)

const FOLGE := ["handaxe", "longsword", "quarterstaff", "greatsword", "greataxe"]

var fehler_zahl := 0

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 13 * 60
	spiel.licht_nach_uhr(true)
	spiel.betrete("village", Vector2i(17, 5), "UP")
	for i in 5: await process_frame
	spiel.werte = BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", spiel.zustand.neue_uid)
	var hw = spiel.held_werte()
	hw.ausruestung.erase("OFF_HAND")
	var sv := SubViewport.new()
	sv.size = Vector2i(200, 200); sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(sv)
	var kam := Camera3D.new(); kam.fov = 30.0; sv.add_child(kam); kam.make_current()
	var ordner := OS.get_environment("BILDER")
	for i in FOLGE.size():
		if OS.get_environment("NUR") != "" and FOLGE[i] != OS.get_environment("NUR"): continue
		hw.ausruestung["MAIN_HAND"] = {"uid": 9700 + i, "base": FOLGE[i], "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
		spiel.held.process_mode = Node.PROCESS_MODE_INHERIT
		spiel.held_figur_neu("")
		spiel.held.richtung = Vector3.ZERO
		var sk := Gebiet.finde(spiel.held.modell, "Skeleton3D") as Skeleton3D
		for f in 40: await process_frame
		var t: Tragen = null
		for n in sk.get_children():
			if n is Tragen: t = n
		if t == null or t.waffe == null:
			print("SEHEN1694 %s: kein Tragen" % FOLGE[i]); continue
		# Netz und Hand im letzten Bild vor dem Anhalten (dieselbe Pose, die danach gezeichnet wird); Lambda: Werte kopiert, darum merge
		var netz := {}; var pk := {}
		sk.skeleton_updated.connect(func():
			netz.merge(NetzMess.griff(sk, "r", t.waffe, t.halt))
			pk.merge(NetzMess.hand_punkte(sk, "r")), CONNECT_ONE_SHOT)
		await process_frame
		spiel.held.process_mode = Node.PROCESS_MODE_DISABLED
		await process_frame
		var waffen_netze := t.waffe.find_children("*", "MeshInstance3D", true, false) + ([t.waffe] if t.waffe is MeshInstance3D else [])
		var koerper := sk.find_children("*", "MeshInstance3D", true, false).filter(func(m): return not m in waffen_netze)
		# Kleidung (Ärmel, Rock) hängt im Blick auf die Handfläche vor der Faust: in dieser Prüfung aus, gezählt wird nur die Hand
		var kleid := koerper.filter(func(m): return String(m.name).begins_with("Kleid_") and (m as MeshInstance3D).visible)
		for m in kleid: (m as MeshInstance3D).visible = false
		var si := await NetzMess.sicht(pk, t.waffe, t.halt, sv, kam, koerper, ("%s/%s" % [ordner, FOLGE[i]]) if ordner != "" else "")
		for m in kleid: (m as MeshInstance3D).visible = true
		var gut := NetzMess.sicht_gut(si)
		var netz_gut: bool = not netz.is_empty() and not netz.has("leer") and NetzMess.griff_gut(netz)
		print("SEHEN1694 %-12s innen sichtbar %d%%, außen %d%% | Netz: Spalt %.1f cm, Umschlingung %d°, Glieder %.1f cm, Kuppen %.1f cm (%s)%s" % [FOLGE[i],
			int(round(100.0 * float(si.innen))), int(round(100.0 * float(si.aussen))),
			netz.get("kontakt", 0.0), int(netz.get("umschl", 0.0)), netz.get("tief", 0.0), netz.get("kuppe", 0.0), "gut" if netz_gut else "Fehler", "" if gut else "  FEHLER"])
		fehler_zahl += 0 if gut else 1
		spiel.held.process_mode = Node.PROCESS_MODE_INHERIT
	print("SEHEN1694 %d Fehler" % fehler_zahl)
	quit(1 if fehler_zahl > 0 else 0)
