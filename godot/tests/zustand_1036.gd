# 1036 (Chef 12.11., 14:48, Build 280: „da sieht man kein Brennen. Das hatten wir alles schon unter Kotlin, die ganzen Effekte,
# die sichtbaren“): die Zustände an den Figuren im Probekampf (Kämpfer, Söldner Kleriker, Wölfe). Je Zustand trägt ihn der Held
# und ein Wolf PHASE_MS lang (nur gezeigt, nicht gerechnet), dann flackert je Schadenszustand einmal der Schaden der Runde auf.
# Ohne Bild (Test im Bau): je Zustand zeichnet die Tafel etwas (Ecken > 0; Bluten nur mit Blut an), der betäubte Wolf schwankt
# und steht nach dem Ende wieder an seinem Platz, das Aufflackern kommt; Exit = Zahl der Fehler. Mit Bild (Film, kampf=1036 in
# godot.yml): dieselbe Folge, oben der Name des Zustands; 17:04 (Chef: „woher die Effekte?“) je Zustand zuerst der Effekt aus dem
# Paket (Status Effects VFX, sonst Stylized VFX oder Combat VFX Mega; wo keiner passt, steht „Paket: keiner“), dann eigen
# verstärkt (zustandsbild.gd KRAFT), der Chef wählt. Die Pakete liegen nur im Bau unter godot/addons (Lizenz: nie ins Repo).
# Aufruf: im Ordner godot --headless --fixed-fps 30 -s res://tests/zustand_1036.gd (braucht daten/ und kampf/daten/ wie im Bau)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Mars = preload("res://regeln/mars.gd")
const Signatur = preload("res://kampf/signatur.gd")
const ZUST := ["BURN", "POISON", "BLEED", "STUN", "SLOW", "WEAK", "BLIND", "DRUNK"]
const FPS := 30.0
## je Zustand, wo im Paket gesucht wird: [Ordner, Wörter im Dateinamen]; je Eintrag gilt der erste Treffer, gezeigt werden
## höchstens zwei verschiedene nacheinander (Paketnamen: LISTE-EFFEKTE.md „Zustände im Kampf“; Brennend hat Status Effects
## nicht, Betäubt dort Shocked oder Confused, dazu stun_stars aus R7)
const VX := "res://addons/reeboo_vfx/"
const CB := "res://addons/reeboo_combat/"
const PAKET := {
	"BURN": [[VX + "status_effects", ["burn", "fire", "ignite"]], [VX + "effects", ["burning", "burn"]], [CB, ["burn", "aura_fire", "fire_aura"]]],
	"POISON": [[VX + "status_effects", ["poison"]]],
	"BLEED": [[VX + "status_effects", ["bleed"]]],
	"STUN": [[VX + "effects", ["stun"]], [VX + "status_effects", ["stun", "shock", "daze", "confus"]]],
	"SLOW": [[VX + "status_effects", ["chill", "slow", "frost", "frozen"]]],
	"WEAK": [[VX + "status_effects", ["weak"]]],
	"BLIND": [[VX + "status_effects", ["blind", "curse"]]],
	"DRUNK": [[VX + "status_effects", ["drunk", "dizz", "confus"]]],
}

var kf
var fehler := 0
var schild: Label


func _initialize() -> void:
	_lauf.call_deferred()


func _env(n: String, d: String) -> String:
	return OS.get_environment(n) if OS.get_environment(n) != "" else d


func _bilder(n: int) -> void:
	for i in n:
		await process_frame


func _fehler(was: String) -> void:
	fehler += 1
	print("FEHLER ", was)


func _lauf() -> void:
	var film := DisplayServer.get_name() != "headless"
	var phase := int(int(_env("PHASE_MS", "2600" if film else "300")) / 1000.0 * FPS)
	seed(7)
	var p = Probe.new()
	p.hero_cls = _env("KLASSE", "FIGHTER")
	p.merc_cls = _env("SOELDNER", "CLERIC")
	p.foe = _env("GEGNER", "WOLVES")
	root.add_child(p)
	await process_frame
	p._start(7)
	await _bilder(4)
	kf = p.fight
	if film:
		if not Signatur.wache(kf, self, "Zustände 1036"):
			quit(1)
			return
		_schild_anlegen()
	while kf.verhuellt:
		await process_frame
	var n := 0
	while (kf.busy or kf.playing or not kf.beats.is_empty()) and n < int(FPS) * 60:
		await process_frame
		n += 1
	var ui = kf.ui
	var wolf := ""
	for f in kf.mars.fighters():
		if f.side == "FOES" and f.standing() and kf.figures.has(f.id):
			wolf = String(f.id)
			break
	if wolf == "" or not kf.figures.has("hero"):
		_fehler("kein Wolf oder kein Held im Probekampf")
		quit(fehler)
		return
	var fig_w = kf.figures[wolf]
	var platz: Vector3 = fig_w.model.position
	var blut: int = kf.blood_level()
	var max_us := 0
	if film:
		_paket_liste()
	for st in ZUST:
		if film:
			await _paket(st, [kf.figures["hero"], fig_w], phase)
		kf.shown["status"] = {wolf: {st: 3}, "hero": {st: 3}}
		if schild:
			schild.text = String(Mars.STATUS[st][0][0]) + (" · eigen" if film else "")
		var ecken := 0
		var schwankt := 0.0
		for i in phase:
			await process_frame
			if ui.tafel != null:
				ecken = maxi(ecken, int(ui.tafel.verts))
				max_us = maxi(max_us, int(ui.tafel_us))
			schwankt = maxf(schwankt, fig_w.taumel_off.length())
		var soll: bool = not (st == "BLEED" and blut <= 0)
		# 1036 (Chef 20:52): mit Paket hängt sein Effekt an beiden Figuren und die Tafel malt diesen Zustand nicht
		var mit_paket: bool = ui.zustand_szene(st) != null
		var an := 0
		for key in [String(wolf) + "|" + st, "hero|" + st]:
			if ui._paket_fx.has(key) and is_instance_valid(ui._paket_fx[key]) and ui._paket_fx[key].get_parent() != null:
				an += 1
		print("Zustand %s: Ecken %d, Schwanken %.3f m, Paket %s" % [st, ecken, schwankt, ("an %d Figuren" % an) if mit_paket else "nicht da"])
		if mit_paket and an < 2:
			_fehler("%s: Effekt des Pakets hängt nur an %d von 2 Figuren" % [st, an])
		if not mit_paket and soll and ecken == 0:
			_fehler("%s zeichnet nichts" % st)
		if st == "STUN" and schwankt < 0.005:
			_fehler("der betäubte Wolf schwankt nicht (%.3f m)" % schwankt)
	kf.shown["status"] = {}
	if schild:
		schild.text = ""
	await _bilder(int(FPS))
	if not ui._paket_fx.is_empty():
		_fehler("nach dem Ende der Zustände hängen noch %d Effekte des Pakets" % ui._paket_fx.size())
	if fig_w.model.position.distance_to(platz) > 0.001:
		_fehler("der Wolf steht nach dem Betäuben nicht an seinem Platz (%.3f m)" % fig_w.model.position.distance_to(platz))
	# je Schadenszustand einmal das Aufflackern der Runde (mars.gd _tick: ohne Täter, Zeile nach ST_HURTS)
	for st in ["BURN", "POISON", "BLEED"]:
		var f = kf.mars.find(wolf)
		var e: Dictionary = kf.shown.duplicate()
		e["actor"] = null
		e["target"] = wolf
		e["damage"] = 2
		e["text"] = String(Mars.ST_HURTS[st][ui.lang]).format([f.name(ui.lang)])
		e["status"] = {wolf: {st: 2}}
		kf.shown = e
		if schild:
			schild.text = String(Mars.STATUS[st][0][0]) + ": Schaden der Runde"
		await _bilder(2)
		var da := false
		for fl in ui.flares:
			if String(fl.on) == wolf and String(fl.st) == st:
				da = true
		print("Aufflackern %s: %s" % [st, "ja" if da else "nein"])
		if not da:
			_fehler("kein Aufflackern bei %s" % st)
		await _bilder(int(FPS * 1.5) if film else 20)
	print("Tafel höchstens %d µs je Bild" % max_us)
	print("ZUSTAND1036 %d Fehler" % fehler)
	quit(fehler)


## alle Szenen unter dir (rekursiv), Pfade
func _szenen(dir: String) -> Array:
	var aus := []
	var d := DirAccess.open(dir)
	if d == null:
		return aus
	for f in d.get_files():
		var n := f.trim_suffix(".remap")
		if n.ends_with(".tscn"):
			aus.append(dir.path_join(n))
	for sub in d.get_directories():
		if not sub.begins_with("demo"):
			aus.append_array(_szenen(dir.path_join(sub)))
	return aus


func _paket_liste() -> void:
	for dir in [VX + "status_effects", CB]:
		var n := []
		for p in _szenen(dir):
			n.append(p.get_file().get_basename())
		print("Paket %s: %s" % [dir, ", ".join(PackedStringArray(n)) if not n.is_empty() else "nicht da"])


func _paket_pfade(st: String) -> Array:
	var aus := []
	for such in PAKET.get(st, []):
		var alle := _szenen(String(such[0]))
		var treffer := ""
		for wort in such[1]:
			for p in alle:
				if treffer == "" and String(wort) in String(p).get_file().to_lower():
					treffer = String(p)
		if treffer != "" and not treffer in aus and aus.size() < 2:
			aus.append(treffer)
	return aus


## Film: der Effekt aus dem Paket an Held und Wolf, phase Bilder lang; Tiere nach ihrer Größe (das Paket misst für 1,8 m)
func _paket(st: String, figs: Array, phase: int) -> void:
	kf.shown["status"] = {}
	var pfade := _paket_pfade(st)
	print("Zustand %s Paket: %s" % [st, ", ".join(PackedStringArray(pfade)) if not pfade.is_empty() else "keiner"])
	if pfade.is_empty():
		if schild:
			schild.text = String(Mars.STATUS[st][0][0]) + " · Paket: keiner"
		await _bilder(int(FPS * 1.2))
		return
	for pfad in pfade:
		await _paket_zeigen(st, String(pfad), figs, phase)


func _paket_zeigen(st: String, pfad: String, figs: Array, phase: int) -> void:
	if schild:
		schild.text = String(Mars.STATUS[st][0][0]) + " · Paket: " + pfad.get_file().get_basename()
	var r = load(pfad)
	if not (r is PackedScene):
		print("FEHLER Paket %s lädt nicht" % pfad)
		await _bilder(int(FPS * 1.2))
		return
	var fxs := []
	for fig in figs:
		var fx: Node = (r as PackedScene).instantiate()
		if "loop" in fx:
			fx.set("loop", true)
		fig.add_child(fx)
		if fx is Node3D:
			(fx as Node3D).position = Vector3.ZERO
			if fig.fighter.monster != null:
				var box: AABB = kf.ui._koerper_kasten(fig)
				var gr := maxf(box.size.y, maxf(box.size.x, box.size.z) * 0.8)
				(fx as Node3D).scale = Vector3.ONE * clampf(gr / 1.8, 0.7, 2.0)
		fxs.append(fx)
	await _bilder(phase)
	for fx in fxs:
		if is_instance_valid(fx) and fx.has_method("stop"):
			fx.call("stop")
	await _bilder(int(FPS * 0.5))
	for fx in fxs:
		if is_instance_valid(fx):
			fx.queue_free()


func _schild_anlegen() -> void:
	var deck := CanvasLayer.new()
	deck.layer = 100
	schild = Label.new()
	schild.position = Vector2(24, 150)
	schild.add_theme_font_size_override("font_size", 34)
	schild.add_theme_color_override("font_color", Color(1.0, 0.86, 0.45))
	schild.add_theme_color_override("font_outline_color", Color.BLACK)
	schild.add_theme_constant_override("outline_size", 8)
	deck.add_child(schild)
	root.add_child(deck)
