# 999 (alt 72.10a.11, 268; Skirmish.looks): nach „Waffe wechseln“ hält der Held im Kampfort die andere Waffe; eine zweihändige
# nimmt den Schild weg, zurück kommt er mit der ersten; ein Bogen steht in der linken Faust; eine Waffe ohne Modell (Armbrust) lässt
# die Hand leer statt der alten Waffe. Ohne Bild, mit dem Helden, den der Bau hat (Kaufheld oder held.bin).
# Run: godot --headless --path godot -s res://tests/waffenwechsel_999.gd   (exit code 0 = alles richtig)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const BOGEN := {"id": "shortbow", "de": "Kurzbogen", "en": "Shortbow", "atk": 3, "dmg": [1, 6, 1], "ranged": true, "reach": false,
	"two": true, "type": "PIERCING"}

var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	print(("ok     " if ok else "FEHLER ") + what)
	if not ok:
		fails += 1


## was an den Knochen der Figur hängt: [[was, Knochen, Knotenname] …]
func _teile(fig) -> Array:
	var out := []
	for at in fig.model.find_children("*", "BoneAttachment3D", true, false):
		if at.has_meta("was"):
			var n: Node = at.get_child(0) if at.get_child_count() > 0 else null
			out.append([String(at.get_meta("was")), String(at.bone_name), String(n.name) if n else ""])
	return out


func _was(fig) -> Array:
	return _teile(fig).map(func(t): return t[0])


func _run() -> void:
	if not FileAccess.file_exists("res://kampf/daten/longsword.bin") or not FileAccess.file_exists("res://kampf/daten/shortbow.bin"):
		print("Waffenwechsel 999: ohne Waffenmodelle (godot/kampf/daten), nichts zu prüfen")
		quit(0)
		return
	Engine.time_scale = 20.0
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "FIGHTER"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 4:
		await process_frame
	var kf = p.fight
	var fig = kf.figures.get("hero")
	_check(fig != null, "Held im Kampfort")
	if fig == null:
		quit(1)
		return
	print("Held: %s, Schild %s" % ["Kaufheld" if fig.kauf else "held.bin", fig._schild()])
	var schild: String = fig._schild()
	_check("longsword" in _was(fig) and (schild == "" or schild in _was(fig)), "Anfang: Langschwert und Schild (%s)" % [_was(fig)])
	var anfang: int = _teile(fig).size()

	# die Armbrust der Probe hat kein Modell: Schwert und Schild weg, die Hand leer
	fig.waffe_ziehen(true)
	await process_frame
	_check(_teile(fig).is_empty(), "Armbrust (zweihändig, ohne Modell): nichts in den Händen (%s)" % [_was(fig)])
	if fig.schild_faust != null:
		_check(not fig.schild_faust.active, "Armbrust: Schildfaust aus")
	fig.waffe_ziehen(false)
	await process_frame
	_check(_was(fig).count("longsword") == 1 and _teile(fig).size() == anfang, "zurück: Langschwert und Schild wieder da, nichts doppelt (%s)" % [_was(fig)])

	# ein Bogen als zweite Waffe: links, als Waffe, ohne Schild
	fig.fighter.second = BOGEN
	fig.waffe_ziehen(true)
	await process_frame
	var t: Array = _teile(fig)
	_check(t.size() == 1 and t[0][0] == "shortbow", "Bogen in der Hand, sonst nichts (%s)" % [_was(fig)])
	if t.size() == 1:
		_check(t[0][1].to_lower().ends_with("l"), "Bogen links (Knochen %s)" % t[0][1])
		_check(t[0][2] == "Waffe", "Bogen heißt Waffe (Pfeil vom Bogen, cast_point): %s" % t[0][2])
		var bogen := fig.model.find_child("Waffe", true, false) as Node3D
		var oben: float = bogen.global_transform.basis.y.normalized().dot(Vector3.UP) if bogen else 0.0
		_check(oben > 0.7, "Bogen aufrecht (%.2f)" % oben)
	fig.waffe_ziehen(false)
	await process_frame
	_check(_was(fig).count("longsword") == 1 and _teile(fig).size() == anfang, "zurück vom Bogen: Langschwert und Schild (%s)" % [_was(fig)])

	# über die Regeln: „Waffe wechseln“, wenn der Held dran ist; die Meldung bringt den Wechsel ins Bild
	kf.mars.find("merc").auto = true     # der Söldner kämpft selbst, bis der Held dran ist
	var t0 := Time.get_ticks_msec()
	var bereit := func() -> bool:
		return not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.current().id == "hero" and kf.mars.can_draw(kf.mars.current())
	while Time.get_ticks_msec() - t0 < 60000 and kf.mars.outcome == "ONGOING" and not bereit.call():
		if not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.current().id == "hero":
			kf.order(["wait"])     # aufgestanden (halber Zug weg): diesen Zug abwehren, im nächsten wechseln
		elif kf.ring_open:
			kf.tap()     # der Ring eines Gegners wartet auf ein Tippen
		elif not kf.busy and not kf.playing and kf.beats.is_empty() and kf.mars.outcome == "ONGOING":
			kf.go_on()
		await process_frame
	_check(kf.mars.current().id == "hero" and kf.mars.can_draw(kf.mars.current()), "Held am Zug und kann wechseln (am Zug: %s, %s, moved %s, spare %s, busy %s, %d ms)" % [kf.mars.current().id,
		kf.mars.outcome, kf.mars.current().moved, kf.mars.current().spare() != null, kf.busy, Time.get_ticks_msec() - t0])
	if kf.mars.current().id == "hero":
		kf.order(["draw"])
		t0 = Time.get_ticks_msec()
		while Time.get_ticks_msec() - t0 < 20000 and (kf.busy or kf.playing or not kf.beats.is_empty()) and not kf.ring_open:
			await process_frame
		_check(kf.mars.find("hero").drawn and fig.gezogen, "nach „Waffe wechseln“ führt die Figur den Bogen (Regel %s, Bild %s)" % [kf.mars.find("hero").drawn, fig.gezogen])
		_check(_was(fig) == ["shortbow"], "im Bild nur der Bogen (%s)" % [_was(fig)])
	print("Waffenwechsel 999: %s" % ("alles richtig" if fails == 0 else "%d Fehler" % fails))
	quit(0 if fails == 0 else 1)
