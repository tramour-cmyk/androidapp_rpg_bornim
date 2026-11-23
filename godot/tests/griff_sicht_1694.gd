extends SceneTree
# 1694/1711 (Sokrates 22:13: „Messung meldet passt, Bild zeigt Fehler“): Messung am sichtbaren Gitter statt an Knochen und halt.json.
# Der Held steht im Dorf wie im Bild (bild_griff_1694, Spielkamera-Pose); gemessen wird nach dem Zeichnen:
#  - Schaft echt: Mitte der Ecken des Waffennetzes in Scheiben längs der Achse um die Faust, gegen die Achse aus halt.json (cm)
#  - Hand echt: Körpernetz mit bake_mesh_from_current_skeleton_pose (so, wie es gezeichnet wird), Ecken mit Hauptgewicht an Hand
#    oder Finger der Waffenseite; um die echte Schaftachse: Umschlingung (Winkel in 10°-Feldern mit Haut näher als Radius + 2,5 cm),
#    Spalt Handfläche (nächste Ecke der Hand selbst, ohne Finger) und Eindringen (kleinster Abstand minus Radius)
#   MESS=1694 xvfb-run -a godot --path . --resolution 540x1170 -s res://tests/griff_sicht_1694.gd   (Exit 1 bei Fehler; ohne Bildschirm ist das Netz leer)

const FOLGE := ["quarterstaff", "handaxe", "longsword", "greatsword", "greataxe"]   # 1694: dazu Zweihänder, beide Hände
var fehler_zahl := 0
var reihe := []   # je Aktualisierung des Skeletts ein Satz Werte (cm, Grad)

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var spiel = load("res://spiel.tscn").instantiate()
	root.add_child(spiel)
	for i in 5: await process_frame
	spiel.zustand.minuten = 13 * 60
	spiel.betrete("village", Vector2i(17, 5), "UP")
	for i in 5: await process_frame
	spiel.werte = BrsHeld.fuer_spiel("Thora", "Mensch", "Wachsoldat", spiel.zustand.neue_uid)
	var hw = spiel.held_werte()
	hw.ausruestung.erase("OFF_HAND")
	# je Waffe im Stehen (eine Hand), Zweihänder und Stab auch im Gehen (die Bewegung führt beide Hände an den Schaft)
	var laeufe := []
	for b in FOLGE:
		if OS.get_environment("NUR") != "" and b != OS.get_environment("NUR"): continue
		laeufe.append([b, ""])
		if b in Tragen.GANG_ZWEI: laeufe.append([b, "Gehen_axt"])
		if Tragen.art_von(b) == "stab": laeufe.append([b, "Gehen"])
	for i in laeufe.size():
		var name: String = laeufe[i][0] + ("" if laeufe[i][1] == "" else "/" + laeufe[i][1])
		hw.ausruestung["MAIN_HAND"] = {"uid": 9600 + i, "base": laeufe[i][0], "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null, "name_seed": 1}
		spiel.held.process_mode = Node.PROCESS_MODE_INHERIT
		spiel.held_figur_neu("")
		spiel.held.richtung = Vector3.ZERO
		var sk := Gebiet.finde(spiel.held.modell, "Skeleton3D") as Skeleton3D
		if laeufe[i][1] != "": geh(spiel, sk, laeufe[i][1])
		for f in 80: await process_frame   # Übergang nach dem Anlegen abwarten (bis 4 Bilder mit hohler Faust)
		# außerhalb der Änderung gibt get_bone_global_pose die Pose ohne Modifikatoren (auch bake): gemessen wird in skeleton_updated
		var mod: Node3D = spiel.held.modell
		var seiten := ["r", "l"] if laeufe[i][1] == "Gehen_axt" else ["r"]
		# im Gehen je Stelle der Bewegung angehalten (die Hand wandert sonst zwischen Netz und Waffe je Bild weiter, unter xvfb bis 12 cm):
		# sechs Stellen über den Schritt, jede muss bestehen
		var stellen := [-1.0]
		var ap := Gebiet.finde(mod, "AnimationPlayer") as AnimationPlayer
		if laeufe[i][1] != "":
			stellen = []
			for k in 6: stellen.append(ap.get_animation(laeufe[i][1]).length * k / 6.0)
		for st in stellen:
			var name_st := name + ("" if st < 0.0 else " @%.2fs" % st)
			if st >= 0.0:
				ap.speed_scale = 0.0; ap.seek(st, true)
				for f in 6: await process_frame
			var reihen := {}
			for s in seiten: reihen[s] = []
			var cb := func():
				for s in seiten:
					reihe = reihen[s]
					var z := miss(mod, s)
					if reihe.is_empty(): print("SICHT1694 %s %s: %s" % [name_st, s, z])
			sk.skeleton_updated.connect(cb)
			for f in (12 if st >= 0.0 else 30): await process_frame   # die Ruhebewegung bewegt die Hand: Median über die Bilder
			sk.skeleton_updated.disconnect(cb)
			for s in seiten:
				var gueltig := (reihen[s] as Array).filter(func(e): return e.ecken > 0)   # bake liefert im ersten Bild teils kein Netz
				if gueltig.size() < 8:
					print("SICHT1694 FEHLER %s %s: nur %d Bilder mit Netz (ohne Bildschirm gestartet? bake braucht xvfb)" % [name_st, s, gueltig.size()]); fehler_zahl += 1; continue
				if gueltig[0].get("leer", false):
					print("SICHT1694 %-12s %s: kein Schaft an der Faust (getragen, nicht gehalten)" % [name_st, s]); continue
				if OS.get_environment("REIHE") != "":
					for e in gueltig: print("  R k=%.1f u=%d t=%.1f" % [e.kontakt, int(e.umschl), e.tief])
				var med := NetzMess.median(gueltig)
				var gut: bool = NetzMess.griff_gut(med)
				print("SICHT1694 %-12s %s Spalt Handfläche %.1f cm, Umschlingung %d°, Glieder im Griff %.1f cm (Kuppen %.1f), Radius %.1f cm (Median %d Bilder)%s%s" % [
					name_st, s, med.kontakt, int(med.umschl), med.tief, med.kuppe, med.radius, gueltig.size(),
					("; Glieder: " + ", ".join(NetzMess.glieder_fehler(med))) if not NetzMess.glieder_fehler(med).is_empty() else "", "" if gut else "  FEHLER"])
				fehler_zahl += 0 if gut else 1
	print("SICHT1694 %d Fehler" % fehler_zahl)
	quit(1 if fehler_zahl > 0 else 0)

# Bewegung auf der Stelle: der Held steht still (sein Skript wählt sonst „Stehen“), Bewegung und Skelett laufen weiter
static func geh(spiel, sk: Skeleton3D, bew: String) -> void:
	var ap := Gebiet.finde(spiel.held.modell, "AnimationPlayer") as AnimationPlayer
	spiel.held.process_mode = Node.PROCESS_MODE_DISABLED
	ap.process_mode = Node.PROCESS_MODE_ALWAYS; sk.process_mode = Node.PROCESS_MODE_ALWAYS
	for n in sk.get_children(): n.process_mode = Node.PROCESS_MODE_ALWAYS
	ap.play(bew, 0.0)

func miss(m: Node3D, s := "r") -> String:
	var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
	var t: Tragen = null
	for n in sk.get_children():
		if n is Tragen: t = n
	if t == null or t.waffe == null: return "kein Tragen"
	var w := NetzMess.griff(sk, s, t.waffe, t.halt)
	reihe.append(w)
	return str(w)
