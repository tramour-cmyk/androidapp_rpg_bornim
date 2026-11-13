# 993 (Chef 11.11., 20:47, Test 277, Probekampf Zauberlehrling: Arkanpfeil „sieht überhaupt nicht gut aus“): der Arkanpfeil fliegt
# als ein Pfeil aus R2 Stylized Projectiles (kampf_ui.gd ARKAN_R2). Messung ohne Bild: Zauberlehrling (Magier hinter dem Wachsoldaten)
# wirkt auf den ersten Wolf, einmal treffend, einmal daneben.
#   mit Paket: ein Geschoss im Kampfort, keine gemalten Splitter; Start an der Stabspitze; es kommt zur Ankunftszeit (Zauber.arrives)
#     bis auf 0,5 m an die Brust des Ziels; daneben endet die Bahn am Boden mindestens 0,3 m neben dem Ziel; der Kampfort spielt
#     weiter (kein Fehler im Paket).
#   ohne Paket (Rechner, Tests ohne Kaufrepo): wie bisher gemalt (ein Eintrag in ui.spells); mit ARKAN_R2=1 (godot.yml, Paket gefunden)
#     ist das ein Befund.
# Aufruf: im Ordner godot mit --headless --fixed-fps 30 -s res://tests/arkan_993.gd     Exit 0 = kein Befund.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Zauber = preload("res://kampf/zauber.gd")
const KampfUi = preload("res://kampf/kampf_ui.gd")


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	DisplayServer.window_set_size(Vector2i(1080, 2340))
	root.size = Vector2i(1080, 2340)
	var befunde := 0
	var paket: bool = KampfUi.arkan_r2() != null
	print("Arkan 993: Paket R2 %s" % ("da" if paket else "nicht da"))
	if not paket and OS.get_environment("ARKAN_R2") != "":
		print("FEHLER: R2 im Bau gefunden, aber %s lädt nicht" % KampfUi.ARKAN_R2)
		befunde += 1
	seed(3)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "WIZARD"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(3)
	for i in 4:
		await process_frame
	var kf = p.fight
	var ui = kf.ui
	var party: Array = kf.mars.fighters().filter(func(x): return x.side == "PARTY" and x.standing() and x.hero != null and x.hero.cls == "WIZARD")
	var foes: Array = kf.mars.fighters().filter(func(x): return x.side == "FOES" and x.standing())
	if party.is_empty() or foes.is_empty():
		print("FEHLER: kein Magier oder kein Gegner im Probekampf")
		quit(1)
		return
	var by = kf.figures[party[0].id]
	var on = kf.figures[foes[0].id]
	for daneben in [false, true]:
		var vorher: int = ui.spells.size()
		var n0: int = ui.arkan_fluege.size()
		var t0: float = kf.clock_ms     # Uhr des Kampforts (Spielzeit wie die Zeitgeber), nicht die Wanduhr
		var step: float = ui.cast("MISSILES", party[0].id, foes[0].id, false, daneben)
		var art := "daneben" if daneben else "Treffer"
		if not paket:
			var gemalt: int = ui.spells.size() - vorher
			print("  %s: ohne Paket gemalt %d (soll 1)" % [art, gemalt])
			if gemalt != 1:
				befunde += 1
			for i in 40:
				await process_frame
			continue
		if ui.spells.size() != vorher:
			print("FEHLER %s: mit Paket trotzdem gemalt" % art)
			befunde += 1
		# bis zur Ankunft warten (Seitenschritt + Flug), dabei die kleinste Entfernung zum Ziel messen
		var bis := t0 + step + Zauber.arrives("MISSILES") + 250.0
		var flug = null
		var naechst := INF
		var start_fehler := INF
		# 1018 (Lauf 373, am Rechner mit Kaufheld und Paket nachgestellt: Treffer 0,14 m): das Geschoss startet zwischen zwei Bildern
		# an der Stabspitze, der Stab schwingt im Zauber weiter; gemessen wird der Abstand zum Weg der Spitze vom Bild davor bis danach
		var vor_hand = by.cast_point()
		while kf.clock_ms < bis:
			await process_frame
			if flug == null and ui.arkan_fluege.size() > n0:
				flug = ui.arkan_fluege[n0]
				var hand = by.cast_point()
				if hand != null:
					var a: Vector3 = vor_hand if vor_hand != null else hand
					var ab: Vector3 = (hand as Vector3) - a
					var u: float = clampf((flug[1] - a).dot(ab) / ab.length_squared(), 0.0, 1.0) if ab.length_squared() > 1e-8 else 0.0
					start_fehler = (a + ab * u).distance_to(flug[1])
			elif flug == null:
				vor_hand = by.cast_point()
			if flug != null and is_instance_valid(flug[0]) and flug[0] is Node3D:
				naechst = minf(naechst, (flug[0] as Node3D).global_position.distance_to(flug[2]))
		if flug == null:
			print("FEHLER %s: kein Geschoss gestartet" % art)
			befunde += 1
			continue
		var ziel: Vector3 = flug[2]
		var brust: Vector3 = on.position + Vector3.UP * (on.head().y - on.position.y) * 0.55
		var neben: float = Vector2(ziel.x - on.position.x, ziel.z - on.position.z).length()
		var ok_start: bool = start_fehler < 0.05 or start_fehler == INF
		var ok_weg: bool = naechst <= 0.5 or naechst == INF     # INF: das Paket gab den Knoten vor der ersten Messung frei (Einschlag)
		var ok_ziel: bool = (ziel.y < 0.15 and neben >= 0.3) if daneben else ziel.distance_to(brust) < 0.6
		print("  %s: Start an der Stabspitze %s (%.2f m), Bahn bis %.2f m ans Ziel, Ziel %s (Höhe %.2f m, %.2f m neben dem Gegner), Schritt %.0f ms" % [
			art, ok_start, start_fehler if start_fehler != INF else -1.0, naechst if naechst != INF else -1.0, ok_ziel, ziel.y, neben, step])
		if not (ok_start and ok_weg and ok_ziel):
			befunde += 1
	print("ARKAN993 %d" % befunde)
	p.queue_free()
	for i in 5:
		await process_frame
	quit(1 if befunde > 0 else 0)
