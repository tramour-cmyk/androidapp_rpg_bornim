# 1036.1 (Chef 12.11., 20:52 an Sokrates: „mehr vorlegen bezüglich, welche Zustände wir haben. Und was wir da alles für Effekte
# … noch haben“): je Zustand des Kampfes, der noch keinen festen Effekt hat, alle passenden Effekte aus den gekauften Paketen
# nacheinander an Held und Wolf, dazu Brennen in drei Größen. Festgelegt sind schon Brennend, Vergiftet, Blutend, Betäubt,
# Verlangsamt (kampf_ui.gd ZUSTAND_PAKET); hier die übrigen aus mars.gd (Geschwächt, Geblendet, Betrunken) und die Lagen, die
# mars.gd an der Figur führt (prone: niedergeworfen; held/gegriffen_von: festgehalten; beistand: Beistand; schutz: Arkanhaut
# und Bannschild; hidden: im Schatten; rasend: Wildschwein nach Feuer). Zu 1039 (Film nur mit dem Zustand, mehrmals) und 1076:
# je Zustand ein Abschnitt bis 14 s, oben steht, was man sieht; der Lauf schneidet je Abschnitt einen Film (Zeile SCHNITT).
# Ohne Pakete (am Rechner): nur die eigenen Abschnitte und „fehlt“; Exit = Zahl der Fehler.
# Aufruf: im Ordner godot --fixed-fps 30 -s res://tests/zustand_10361.gd (Film: --write-movie, kampf=10361 in godot.yml)
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Signatur = preload("res://kampf/signatur.gd")
const FPS := 30.0
const VX := "res://addons/reeboo_vfx/"
const ORDNER := {"Z": VX + "status_effects", "E": VX + "effects", "E3": VX + "pack3_effects", "K": "res://addons/reeboo_combat/"}
## nie gezeigt, auch wenn ein Wort passt: Strahlen, Geschosse, Spuren, Science-Fiction (LISTE-BESTAND „unbrauchbar“), Kaminrauch
const AUSSER := ["beam", "projectile", "trail", "laser", "muzzle", "bullet", "rocket", "coin", "confetti", "firework", "plasma",
	"emp_", "black_hole", "checkpoint", "chimney"]
const PAKETNAME := {"Z": "Paket Zustände", "E": "Paket Effekte", "E3": "Paket Effekte 3", "K": "Paket Kampf"}
## je Abschnitt: Name im Film, Zustand für die eigene Zeichnung (zustandsbild.gd) oder "", Einträge in Reihenfolge:
## ["Z", "name"] genau diese Szene, ["E", ["wort", …]] die erste Szene, deren Name ein Wort enthält und die noch nicht vorkam,
## ["eigen"] wie heute im Spiel; höchstens 5 Einträge je Abschnitt (14 s)
const ABSCHNITTE := [
	["geschwaecht", "Geschwächt (auch Fluch)", "WEAK", [["Z", "debuff_gain"], ["Z", "cursed"], ["K", "aura_shadow"],
		["E", ["weak", "wither", "drain", "curse", "hex"]], ["eigen"]]],
	["geblendet", "Geblendet", "BLIND", [["K", "explosion_smoke_bomb"], ["E", ["blind", "smoke", "dark"]], ["Z", "cursed"], ["eigen"]]],
	["betrunken", "Betrunken", "DRUNK", [["Z", "confused"], ["E", ["dizz", "drunk", "bubble", "confus"]], ["E3", ["dizz", "drunk", "bubble", "confus"]], ["eigen"]]],
	["niedergeworfen", "Niedergeworfen", "", [["E", ["dust_impact"]], ["K", "slam_ground"], ["K", "stomp_shockwave"], ["E3", ["crack", "fissure", "quake"]]]],
	["festgehalten", "Festgehalten (Netz, Griff)", "", [["E", ["root", "vine", "web", "chain", "bind", "entangle", "snare", "thorn"]],
		["E3", ["root", "vine", "web", "chain", "bind", "entangle", "snare", "thorn", "crystal"]], ["Z", "marked_target"], ["Z", "frozen"]]],
	["beistand", "Beistand (gesegnet)", "", [["Z", "blessed"], ["Z", "buff_gain"], ["Z", "regen_aura"], ["K", "aura_holy"], ["E", ["holy_light", "bless", "halo"]]]],
	["geschuetzt", "Arkanhaut, Bannschild", "", [["Z", "armor_up"], ["Z", "status_resist"], ["Z", "invincible"], ["K", "aura_arcane"], ["Z", "arcane_surge"]]],
	["schatten", "Im Schatten", "SCHATTEN", [["E", ["shadow_burst"]], ["K", "aura_shadow"], ["E3", ["shadow", "smoke"]], ["eigen"]]],
	["rasend", "Rasend (Wildschwein nach Feuer)", "", [["Z", "taunted"], ["Z", "haste_aura"], ["E", ["rage", "anger", "fury"]], ["E3", ["rage", "anger", "fury"]]]],
	["brennend-groesse", "Brennend: Größe", "", [["E", "burning", 0.7], ["E", "burning", 1.0], ["E", "burning", 1.4]]],
]

var kf
var fehler := 0
var schild: Label
var f0 := 0
var gezeigt := {}


func _initialize() -> void:
	f0 = Engine.get_process_frames()
	_lauf.call_deferred()


func _bilder(n: int) -> void:
	for i in n:
		await process_frame


func _zeit() -> float:
	return float(Engine.get_process_frames() - f0) / FPS


func _fehler(was: String) -> void:
	fehler += 1
	print("FEHLER ", was)


func _lauf() -> void:
	var film := DisplayServer.get_name() != "headless"
	seed(7)
	var p = Probe.new()
	p.hero_cls = "FIGHTER"
	p.merc_cls = "CLERIC"
	p.foe = "WOLVES"
	root.add_child(p)
	await process_frame
	p._start(7)
	await _bilder(4)
	kf = p.fight
	if film and not Signatur.wache(kf, self, "Zustände 1036.1"):
		quit(1)
		return
	_schild_anlegen()
	while kf.verhuellt:
		await process_frame
	var n := 0
	while (kf.busy or kf.playing or not kf.beats.is_empty()) and n < int(FPS) * 60:
		await process_frame
		n += 1
	var wolf := ""
	for f in kf.mars.fighters():
		if f.side == "FOES" and f.standing() and kf.figures.has(f.id):
			wolf = String(f.id)
			break
	if wolf == "" or not kf.figures.has("hero"):
		_fehler("kein Wolf oder kein Held im Probekampf")
		quit(fehler)
		return
	var figs := [kf.figures["hero"], kf.figures[wolf]]
	for k in ORDNER:
		var namen := []
		for s in _szenen(String(ORDNER[k])):
			namen.append(s.get_file().get_basename())
		print("Paket %s (%s): %s" % [k, ORDNER[k], ", ".join(PackedStringArray(namen)) if not namen.is_empty() else "nicht da"])
	await _bilder(int(FPS * 0.5))
	var halt := int(FPS * (2.4 if film else 0.3))
	for ab in ABSCHNITTE:
		var eintraege := _aufloesen(ab[3])
		if eintraege.is_empty():
			print("Abschnitt %s: nichts da" % ab[0])
			continue
		var t0 := _zeit()
		var i := 0
		for e in eintraege:
			i += 1
			if schild:
				schild.text = "%s   %d/%d\n%s" % [ab[1], i, eintraege.size(), e["text"]]
			if e["pfad"] == "":
				await _eigen(String(ab[2]), wolf, figs, halt)
			else:
				await _paket(String(e["pfad"]), float(e["k"]), figs, halt)
		var t1 := _zeit()
		print("SCHNITT %s %.2f %.2f" % [ab[0], maxf(0.0, t0 - 0.1), t1])
		if t1 - t0 > 15.0:
			_fehler("%s dauert %.1f s (höchstens 15)" % [ab[0], t1 - t0])
	if schild:
		schild.text = ""
	await _bilder(int(FPS * 0.5))
	print("ZUSTAND10361 %d Fehler" % fehler)
	quit(fehler)


## die Einträge eines Abschnitts als [{pfad, k, text}]; was im Paket fehlt, fällt weg (Zeile „fehlt“)
func _aufloesen(liste: Array) -> Array:
	var aus := []
	for e in liste:
		if String(e[0]) == "eigen":
			aus.append({"pfad": "", "k": 1.0, "text": "eigen (heute im Spiel)"})
			continue
		var alle := _szenen(String(ORDNER[e[0]]))
		var treffer := ""
		if e[1] is String:
			for s in alle:
				if treffer == "" and s.get_file().get_basename() == String(e[1]):
					treffer = s
		else:
			for wort in e[1]:
				for s in alle:
					var bn: String = String(s).get_file().get_basename().to_lower()
					if treffer == "" and not gezeigt.has(s) and String(wort) in bn and not AUSSER.any(func(x): return x in bn):
						treffer = s
		if treffer == "":
			print("fehlt %s %s" % [e[0], str(e[1])])
			continue
		var k: float = float(e[2]) if e.size() > 2 else 1.0
		gezeigt[treffer] = true
		var text := "%s · %s" % [treffer.get_file().get_basename(), PAKETNAME[e[0]]]
		if e.size() > 2:
			text += "  ×%s" % str(k).replace(".", ",")
		aus.append({"pfad": treffer, "k": k, "text": text})
		print("Eintrag %s" % treffer)
	return aus


## der Effekt an Held und Wolf, halt Bilder lang; ohne „loop“ (einmaliger Effekt) alle 1,2 s neu, damit man ihn mehrmals sieht
func _paket(pfad: String, k: float, figs: Array, halt: int) -> void:
	var r = load(pfad)
	if not (r is PackedScene):
		_fehler("Paket %s lädt nicht" % pfad)
		return
	var fxs := []
	var schleife := true
	var takt := int(FPS * 1.2)
	for b in halt:
		if b == 0 or (not schleife and b % takt == 0):
			for fig in figs:
				var fx: Node = (r as PackedScene).instantiate()
				if b == 0:
					schleife = "loop" in fx
				if "loop" in fx:
					fx.set("loop", true)
				fig.add_child(fx)
				if fx is Node3D:
					(fx as Node3D).position = Vector3.ZERO
					(fx as Node3D).scale = Vector3.ONE * _groesse(fig) * k
				fxs.append(fx)
		await process_frame
	for fx in fxs:
		if is_instance_valid(fx) and fx.has_method("stop"):
			fx.call("stop")
	await _bilder(int(FPS * 0.4))
	for fx in fxs:
		if is_instance_valid(fx):
			fx.queue_free()
	await process_frame


## wie kampf_ui.gd _paket_an: Menschen wie geliefert, Tiere nach ihrem Körper (das Paket misst für 1,8 m)
func _groesse(fig) -> float:
	if fig.fighter.monster == null:
		return 1.0
	var box: AABB = kf.ui._koerper_kasten(fig)
	return clampf(maxf(box.size.y, maxf(box.size.x, box.size.z) * 0.8) / 1.8, 0.7, 2.0)


## heute im Spiel: die Zeichnung von zustandsbild.gd, im Schatten blass (figur.gd im_schatten)
func _eigen(st: String, wolf: String, figs: Array, halt: int) -> void:
	if st == "SCHATTEN":
		for fig in figs:
			fig.im_schatten(true)
		await _bilder(halt)
		for fig in figs:
			fig.im_schatten(false)
	else:
		kf.shown["status"] = {wolf: {st: 3}, "hero": {st: 3}}
		var ecken := 0
		for b in halt:
			await process_frame
			if kf.ui.tafel != null:
				ecken = maxi(ecken, int(kf.ui.tafel.verts))
		kf.shown["status"] = {}
		if ecken == 0:
			_fehler("%s eigen zeichnet nichts" % st)
	await _bilder(int(FPS * 0.4))


## alle Szenen unter dir (rekursiv), ohne Vorführung
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


func _schild_anlegen() -> void:
	var deck := CanvasLayer.new()
	deck.layer = 100
	schild = Label.new()
	schild.position = Vector2(20, 150)
	schild.size = Vector2(500, 90)
	schild.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	schild.add_theme_font_size_override("font_size", 28)
	schild.add_theme_color_override("font_color", Color(1.0, 0.86, 0.45))
	schild.add_theme_color_override("font_outline_color", Color.BLACK)
	schild.add_theme_constant_override("outline_size", 8)
	deck.add_child(schild)
	root.add_child(deck)
