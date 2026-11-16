# 1362 (Tom, t291.6 und t291.10; Stand claude/build-291): Film durch die echte Oberfläche, Spielkamera, Echtzeit. Probekampf Wölfe,
# Held Klosterschüler mit Kampfstab, Söldner Wachsoldat mit Rundschild (wie wolf_mess_438, Seed 7), beide nach Autopilot, viel Leben
# (nur für den Film). Der ganze Kampf läuft in Echtzeit; das Skript schreibt je Ereignis eine Zeile „FILM1362 <art> <Bild> <s>“:
#   ausweichen  der Held beginnt eine Ausweichbewegung (1321: zurück oder schräg, der Stab bleibt vor dem Wolf)
#   zucken      der Söldner beginnt das Zucken beim Treffer (1363: der Schildarm bleibt in seiner Haltung)
# Die Schnitte je Prüfpunkt (G4: nur der Gegenstand) macht ffmpeg danach aus diesen Zeilen.
# Aufruf (Film, Probelauf nach 621 A): PROBE=1362 xvfb-run godot --path godot --resolution 540x1170 --write-movie <datei>.avi
#   --fixed-fps 30 -s res://tests/film_wolf_1362.gd      MESS=1 mit --headless: nur die Ereigniszeilen; SEKUNDEN=<n> (Vorgabe 150)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")

var mess := OS.get_environment("MESS") != ""


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var seed_n := int(OS.get_environment("SEED")) if OS.get_environment("SEED") != "" else 7
	seed(seed_n)
	var p = Probe.new()
	p.hero_cls = "CLERIC"
	p.merc_cls = "FIGHTER"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(seed_n)
	for i in 12:
		await process_frame
	var kf = p.fight
	if kf == null:
		print("FEHLER 1362: kein Kampfort")
		quit(1)
		return
	if not FileAccess.file_exists("res://kampf/daten/kaufwolf-info.json"):
		print("FEHLER 1362: ohne Kaufwolf zeigt der Film nicht den Stand des Builds")
		quit(1)
		return
	var m = kf.mars
	m.find("merc").auto = true
	m.find("hero").auto = true
	for f in m.all:
		f.max_hp = 999
		f.hp = 999
	if not mess and not Signatur.wache(kf, self, "Film 1362"):
		return
	var held = kf.figures.get("hero")
	var sold = kf.figures.get("merc")
	var vor := {"hero": "", "merc": ""}
	var zahl := {"ausweichen": 0, "zucken": 0}
	var bis := 30 * (int(OS.get_environment("SEKUNDEN")) if OS.get_environment("SEKUNDEN") != "" else 150)
	# STOP_AUSWEICHEN=<k>: 2 s nach dem k-ten Ausweichen Ende (t291.6, ein Lauf, 621 A)
	var stop_k := int(OS.get_environment("STOP_AUSWEICHEN")) if OS.get_environment("STOP_AUSWEICHEN") != "" else 0
	var stop_bei := -1
	var n := 0
	while n < bis and (stop_bei < 0 or n < stop_bei):
		await process_frame
		n += 1
		for paar in [["hero", held], ["merc", sold]]:
			var o = paar[1]
			if o == null or o.anim == null:
				continue
			var a := String(o.anim.current_animation)
			if a != vor[paar[0]]:
				if paar[0] == "hero" and a.begins_with("Ausweichen"):
					zahl.ausweichen += 1
					print("FILM1362 ausweichen %d %.2f %s" % [n, n / 30.0, a])
					if stop_k > 0 and zahl.ausweichen >= stop_k:
						stop_bei = n + 60
				if paar[0] == "merc" and a.begins_with("SS_GetHit"):
					zahl.zucken += 1
					print("FILM1362 zucken %d %.2f %s" % [n, n / 30.0, a])
				vor[paar[0]] = a
		if m.outcome != "ONGOING" and stop_bei < 0:
			break
		if kf.busy or kf.playing or not kf.beats.is_empty():
			continue
		kf.go_on()
	print("FILM1362 fertig %d Bilder, %d ausweichen, %d zucken" % [n, zahl.ausweichen, zahl.zucken])
	quit(0 if zahl.ausweichen > 0 and zahl.zucken > 0 else 1)
