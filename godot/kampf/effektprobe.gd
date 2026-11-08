# 623.5 (Chef 08.11., 13:14: „bevor ich jetzt was kaufe, dass wir es auf technische Umsetzbarkeit testen … ob … das dann funktioniert
# bei uns auf dem Handy und wie es aussieht“; „jetzt“ 13:48, Archiv „623.5, Proben ohne Sperre“): die Gratisproben von REEBOO Labs im
# Kampfort wie im Spiel (Toon-Licht, Tusche, Schatten, Spielkamera), Kämpfer mit Schwert und Schild und ein Magier gegen das Wolfsrudel.
# Jeder Effekt einmal an seinem Anlass (LISTE-EFFEKTE.md): Hiebe mit Klingenspur, Treffer, Blut, Parade, Bodenstoß, Geschosse aus der
# Stabspitze, Strahl, Kettenblitz, Explosion, Zustände am Körper, Aura, Auflösen. Oben Name, Paket, Bilder je Sekunde (jetzt und Mittel
# je Effekt) und Renderer; „Renderer wechseln“ wie 415 (user://renderer_415.cfg, wirkt nach Neustart), „Zurück“ lädt das Spiel neu.
# Die Pakete verbieten die Weitergabe der Dateien: nur im privaten Repo bornim-kaufmodelle, im Bau nach godot/addons (godot.yml,
# tools/godot/effekte_6235.sh), in .gitignore. Fehlt ein Paket, steht sein Effekt mit „fehlt“ da, der Rest läuft.
# Kein Kampf: MARS bleibt stehen (wie 415), die Figuren schlagen, beißen und zaubern mit ihren Kampfbewegungen (Figur.strike).
# Aufruf im Spiel: Testmenü „Effekte“; als Film: tests/film_6235.gd (film = true: ohne Knöpfe, Bilder je Sekunde nicht angezeigt).
extends Node

const Probe = preload("res://kampf/probe.gd")
const Zauber = preload("res://kampf/zauber.gd")
const RENDERER_CFG := "user://renderer_415.cfg"
const PAUSE_S := 0.7
const C := "res://addons/reeboo_combat/effects/"
const PR := "res://addons/reeboo_projectiles/elements/"
const TR := "res://addons/reeboo_trails/presets/"
const VX := "res://addons/reeboo_vfx/"
const CS := "res://addons/character_shaders/presets/"
const BLOOD := 11     # ReebooCombatFX3D.Element.BLOOD (CUSTOM, FIRE, ICE, LIGHTNING, POISON, HOLY, SHADOW, ARCANE, WATER, WIND, EARTH, BLOOD)
## je Effekt: Schlüssel, Name im Bild, Paket, Datei (zum Prüfen, ob das Paket da ist)
const SCHRITTE := [
	["stahl", "Stahlhieb mit Klingenspur", "Combat VFX Mega · Weapon Trails", C + "slashes/slash_steel_horizontal.tscn"],
	["krit", "Kritischer Treffer, Blut", "Combat VFX Mega (Element Blut)", C + "impacts/hit_critical.tscn"],
	["feuerklinge", "Feuerklinge", "Combat VFX Mega · Weapon Trails", C + "slashes/slash_fire_diagonal.tscn"],
	["parade", "Funken am Schild", "Stylized VFX (Hit Spark)", VX + "effects/hit_spark.tscn"],
	["hiebbogen", "Hiebbogen", "Stylized VFX (Slash)", VX + "effects/slash.tscn"],
	["stoss", "Bodenstoß", "Combat VFX Mega", C + "aoe/slam_ground.tscn"],
	["feuerpfeil", "Feuerpfeil", "Stylized Projectiles", PR + "fire/fire_projectile.tscn"],
	["blitzgeschoss", "Blitzgeschoss", "Stylized Projectiles", PR + "lightning/lightning_projectile.tscn"],
	["feuerball", "Feuerball", "Combat VFX Mega", C + "projectiles/projectile_fireball.tscn"],
	["eis", "Eissplitter", "Combat VFX Mega", C + "projectiles/projectile_ice_shard.tscn"],
	["strahl", "Arkanstrahl", "Combat VFX Mega", C + "beams/beam_arcane.tscn"],
	["kette", "Kettenblitz", "VFX Pack 3", VX + "pack3_effects/chain_lightning.tscn"],
	["blitztreffer", "Blitztreffer", "Combat VFX Mega", C + "impacts/hit_lightning.tscn"],
	["plasma", "Einschlag", "VFX Pack 3 (Plasma Impact)", VX + "pack3_effects/plasma_impact.tscn"],
	["explosion", "Große Feuerexplosion", "Combat VFX Mega", C + "explosions/explosion_fire_large.tscn"],
	["gift", "Vergiftet", "Status Effects", VX + "status_effects/poisoned.tscn"],
	["ruestung", "Rüstung verstärkt", "Status Effects", VX + "status_effects/armor_up.tscn"],
	["staerke", "Gestärkt", "Status Effects", VX + "status_effects/buff_gain.tscn"],
	["aura", "Heilige Aura", "Combat VFX Mega", C + "auras/aura_holy.tscn"],
	["glitzer", "Glitzern beim Aufheben", "Stylized VFX (Pickup Sparkle)", VX + "effects/pickup_sparkle.tscn"],
	["aufloesen", "Auflösen", "Character Shaders (Dissolve)", CS + "dissolve/dissolve_fire.tres"],
]

var film := false
var fertig := false     # alle Effekte einmal durch
var bereit := false     # Einlauf und Aufstellung vorbei, der erste Effekt kommt (Film: Blende auf)
var probe
var kf
var held     # Kämpfer mit Schwert und Schild (Kaufheld)
var magier   # Söldner mit Stab
var lb: Label
var mittel := {}     # Name -> [Summe fps, Bilder]
var jetzt := ""
var paket := ""
var fehlen: Array = []     # Effekte, deren Paket nicht im Build ist
var gespielt: Array = []   # Schlüssel der gezeigten Effekte (Film, Prüfung)
var aufgeloest: Array = []   # [MeshInstance3D, Stoffe vorher] des aufgelösten Wolfs
## 623.5 (Chef 08.11., 17:05, Archiv „623.5, 623.6, Probe-APK statt Film“): je Effekt umschaltbar zwischen dem Paket und unserer
## Fassung am selben Anlass (Kaufkriterium: „sieht es am Handy deutlich besser aus als unsere Fassung“); wirkt ab dem nächsten Effekt
var unsere := OS.get_environment("UNSERE") != ""     # Messprobe am Rechner ohne Pakete
var k_fassung: Button
## unsere Fassung je Effekt: [MARS-Zauber für Kampf-UI.cast oder "" , was bei uns zu sehen ist]; "" und Text: nur Bewegung und Treffer
const UNSERE := {
	"stahl": ["", "Hieb ohne Spur"], "krit": ["", "Hieb, Blut"], "feuerklinge": ["", "Hieb ohne Feuer"],
	"hiebbogen": ["", "Hieb ohne Bogen"], "stoss": ["", "Hieb, kein Bodenstoß"], "parade": ["", "Parade ohne Funken"],
	"feuerpfeil": ["FIRE_BOLT", "Feuerpfeil"], "blitzgeschoss": ["MISSILES", "Magisches Geschoss"],
	"feuerball": ["FIREBALL", "Feuerball"], "eis": ["MISSILES", "Magisches Geschoss (kein Eis)"],
	"strahl": ["RAYS", "Sengender Strahl"], "kette": ["", "kein Kettenblitz"], "blitztreffer": ["", "kein Blitz"],
	"plasma": ["", "kein Einschlag"], "explosion": ["FIREBALL", "Feuerball"], "gift": ["", "nur Zustandsschild"],
	"ruestung": ["", "nur Zustandsschild"], "staerke": ["", "nur Zustandsschild"], "aura": ["BLESS", "Segen"],
	"glitzer": ["", "kein Glitzern"], "aufloesen": ["", "kein Auflösen"],
}


## ist wenigstens ein Paket im Build (Testmenü, Film)
static func da() -> bool:
	for s in SCHRITTE:
		if ResourceLoader.exists(String(s[3])):
			return true
	return false


func _ready() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	probe = Probe.new()
	probe.hero_cls = "FIGHTER"
	probe.merc_cls = "WIZARD"
	probe.foe = "WOLVES"
	add_child(probe)
	await get_tree().process_frame
	probe._start(7)
	for i in 6:
		await get_tree().process_frame
	kf = probe.fight
	_oberflaeche()
	if kf == null:
		lb.text = "Kampfort fehlt"
		return
	if kf.ui != null:
		kf.ui.visible = false
	held = kf.figures.get("hero")
	for id in kf.figures:
		var f = kf.figures[id]
		if f != held and f.fighter.monster == null:
			magier = f
	if not da() and not unsere:
		lb.text = "Effekte fehlen: Pakete nicht im Build (bornim-kaufmodelle, anhang/reeboo)"
		return
	await _bis_still()
	await _kampf_ruht()
	bereit = true
	await _warte(0.5)     # Film: Blende auf, bevor der erste Effekt beginnt
	while true:
		for s in SCHRITTE:
			if not unsere and not ResourceLoader.exists(String(s[3])):
				if not fehlen.has(s[1]):
					fehlen.append(s[1])
				continue
			jetzt = String(s[1])
			paket = String(UNSERE.get(s[0], ["", "–"])[1]) if unsere else String(s[2])
			await _spiele(String(s[0]))
			gespielt.append(s[0])
			jetzt = ""
			await get_tree().create_timer(PAUSE_S).timeout
		if film:
			fertig = true
			return
		await _wiederbeleben()


# ---------------------------------------------------------------- Hilfen

func _spiele(k: String) -> void:
	_ui_fuer(unsere)
	if unsere:
		await _unsere(k)
		return
	match k:
		"stahl": await _stahl()
		"krit": await _krit()
		"feuerklinge": await _feuerklinge()
		"parade": await _parade()
		"hiebbogen": await _hiebbogen()
		"stoss": await _stoss()
		"feuerpfeil": await _projektil("fire")
		"blitzgeschoss": await _projektil("lightning")
		"feuerball": await _mega_geschoss(C + "projectiles/projectile_fireball.tscn")
		"eis": await _mega_geschoss(C + "projectiles/projectile_ice_shard.tscn")
		"strahl": await _strahl()
		"kette": await _kette()
		"blitztreffer": await _blitztreffer()
		"plasma": await _plasma()
		"explosion": await _explosion()
		"gift": await _zustand(VX + "status_effects/poisoned.tscn", _wolf(held), 3.0)
		"ruestung": await _zustand(VX + "status_effects/armor_up.tscn", held, 3.0)
		"staerke": await _zustand(VX + "status_effects/buff_gain.tscn", held, 2.2)
		"aura": await _aura()
		"glitzer": await _glitzer()
		"aufloesen": await _aufloesen()


func _szene(pfad: String) -> Node:
	var r = load(pfad)
	return (r as PackedScene).instantiate() if r is PackedScene else null


## der nächste stehende Wolf zu [von] (ohne [ausser])
func _wolf(von, ausser = null):
	if von == null:
		von = held
	var best = null
	var bd := INF
	for id in kf.figures:
		var f = kf.figures[id]
		if f.fighter.monster == null or f.down or not f.visible or f == ausser:
			continue
		var d: float = f.global_position.distance_to(von.global_position)
		if d < bd:
			bd = d
			best = f
	return best


## Brusthöhe einer Figur (zwischen Boden und Kopf)
func _brust(f) -> Vector3:
	return f.global_position + (f.head() - f.position) * (0.55 if f.fighter.monster != null else 0.62)     # head(): lokal wie position


## ein Treffer, wie ihn MARS meldet: [fig] schlägt oder beißt [ziel]; gibt die Zeit bis zum Aufschlag in s
func _schlag(fig, ziel, trifft := true) -> float:
	var lunge: int = fig.strike(ziel, {"spell": null, "roll": ["ATTACK", 15 if trifft else 4, 0, 0, trifft]})
	return lunge * 0.42 / 1000.0


## ein Zauber: Ausholen zum Ziel (Figur.strike mit Zauber), danach die Stabspitze
func _ausholen(ziel) -> Vector3:
	if magier == null:
		return held.global_position + Vector3(0, 1.4, 0)
	magier.strike(ziel, {"spell": "MAGIC_MISSILE", "roll": null})
	await get_tree().create_timer(0.45).timeout
	var p = magier.cast_point()
	if OS.get_environment("MESS") != "":
		print("MESS Stabspitze %s: %s über dem Boden %.2f m, %.2f m vor dem Magier, Ziel %.2f m entfernt" % [jetzt, p,
			(p.y - magier.global_position.y) if p is Vector3 else -1.0, ((p - magier.global_position) * Vector3(1, 0, 1)).length() if p is Vector3 else -1.0,
			magier.global_position.distance_to(ziel.global_position)])
	return p if p is Vector3 else magier.global_position + Vector3(0, 1.4, 0)


## ein Effekt der Pakete an [pos]; [weg_von]: der Angreifer steht auf der +Z-Seite (Combat VFX Mega, Treffer und Hiebe)
func _setze(pfad: String, pos: Vector3, weg_von = null, eigen := {}) -> Node:
	var fx := _szene(pfad)
	if fx == null:
		return null
	for k in eigen:
		fx.set(k, eigen[k])
	if "autostart" in fx and not eigen.has("autostart"):
		fx.set("autostart", false)
	if "free_when_finished" in fx:
		fx.set("free_when_finished", true)
	kf.add_child(fx)
	(fx as Node3D).global_position = pos
	if OS.get_environment("MESS") != "":
		print("MESS Effekt %s: %s, Höhe %.2f m, Bild %d" % [pfad.get_file(), pos, pos.y - kf.global_position.y, Engine.get_process_frames()])
	if weg_von is Vector3:
		var vom: Vector3 = (weg_von as Vector3) - pos
		vom.y = 0.0
		if vom.length() > 0.01:
			(fx as Node3D).look_at(pos - vom, Vector3.UP)
	if fx.has_method("play") and "autostart" in fx:
		fx.call("play")
	return fx


func _warte(s: float) -> void:
	await get_tree().create_timer(maxf(s, 0.0)).timeout


## wartet, bis [fig] wieder daheim steht (busy_ms), höchstens 6 s
func _frei(fig) -> void:
	var t := 0.0
	while fig.busy_ms > 0 and t < 6.0 and fig.tween != null and fig.tween.is_running():
		await get_tree().process_frame
		t += get_process_delta_time()
	await _warte(0.3)


## Klingenspur an der Waffe des Helden (Weapon Trails, BLADE): Fuß und Spitze aus dem Umriss der Klinge
func _spur(preset: String) -> Node:
	var w = held.model.find_child("Waffe", true, false) if held != null and held.model != null else null
	var sk = load("res://addons/reeboo_trails/trail_3d.gd")
	var st = load(TR + preset)
	if w == null or sk == null or st == null:
		return null
	var bb := AABB()
	var erst := true
	for m in (w as Node).find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		var tf: Transform3D = (w as Node3D).global_transform.affine_inverse() * mi.global_transform
		var b: AABB = tf * mi.get_aabb()
		bb = b if erst else bb.merge(b)
		erst = false
	if erst:
		return null
	var achse := bb.get_longest_axis()
	var a := bb.get_center() - achse * 0.5
	var b2 := bb.get_center() + achse * 0.5
	var tip := a if a.length() > b2.length() else b2     # die Spitze liegt weiter vom Griff (Ursprung der Waffe)
	var fuss := tip.lerp(a if tip == b2 else b2, 0.75)
	if OS.get_environment("MESS") != "":
		print("MESS Spur %s: Fuß %s, Spitze %s, Klinge %.2f m (Waffe skaliert %s)" % [preset, fuss, tip, fuss.distance_to(tip) * (w as Node3D).global_transform.basis.get_scale().x, (w as Node3D).global_transform.basis.get_scale()])
	var t: Node3D = sk.new()
	t.set("style", st)
	t.set("mode", 1)     # Trail3D.Mode.BLADE
	t.set("blade_base", fuss)
	t.set("blade_tip", tip)
	t.set("emitting", false)
	(w as Node).add_child(t)
	return t


## Hieb des Helden auf den nächsten Wolf mit Effekt beim Aufschlag; [spur]: Preset der Klingenspur
func _hieb_mit(pfad: String, spur := "", eigen := {}, am_boden := false) -> void:
	var w = _wolf(held)
	if w == null:
		return
	var t = _spur(spur) if spur != "" else null
	var auf := _schlag(held, w)
	var schwung := 0.35     # die Spur läuft mit dem Schwung, kurz vor dem Aufschlag bis kurz danach
	await _warte(auf - schwung)
	if t != null:
		t.set("emitting", true)
	await _warte(schwung)
	var p := _brust(w)
	if am_boden:     # vor dem Wolf am Boden, auf der Seite des Helden
		p = w.global_position.lerp(held.global_position, 0.25)
		p.y = w.global_position.y
	_setze(pfad, p, held.global_position, eigen)
	w.hurt(0, false, eigen.has("element"), "nah")
	await _warte(0.25)
	if t != null:
		t.set("emitting", false)
	await _frei(held)
	if t != null:
		await _warte(0.4)
		t.queue_free()


# ---------------------------------------------------------------- die Effekte

func _stahl() -> void:
	await _hieb_mit(C + "slashes/slash_steel_horizontal.tscn", "steel_slash.tres")


func _krit() -> void:
	await _hieb_mit(C + "impacts/hit_critical.tscn", "steel_slash.tres", {"element": BLOOD})


func _feuerklinge() -> void:
	await _hieb_mit(C + "slashes/slash_fire_diagonal.tscn", "flame_blade.tres")


func _hiebbogen() -> void:
	await _hieb_mit(VX + "effects/slash.tscn")


func _stoss() -> void:
	await _hieb_mit(C + "aoe/slam_ground.tscn", "", {}, true)


## ein Wolf beißt den Helden, der Schild hält: Funken am Schild beim Aufschlag
func _parade() -> void:
	var w = _wolf(held)
	if w == null:
		return
	var auf := _schlag(w, held, false)
	held.abwehr(int(auf * 1000.0), "nah", w.global_position, true, w.niedrig())
	await _warte(auf)
	var sch = held.model.find_child("Schild", true, false) if held.model != null else null
	var p: Vector3 = (sch as Node3D).global_position if sch is Node3D else _brust(held)
	_setze(VX + "effects/hit_spark.tscn", p.lerp(w.global_position + w.head() - w.position, 0.15), w.global_position)
	await _frei(w)


## Geschoss der Stylized Projectiles: fliegt gerade bis zum Wolf, schlägt dort ein (ohne Körper zum Treffen: Ende der Lebenszeit)
func _projektil(element: String) -> void:
	var w = _wolf(magier)
	if w == null:
		return
	var von: Vector3 = await _ausholen(w)
	var ziel := _brust(w)
	var p := _szene(PR + "%s/%s_projectile.tscn" % [element, element])
	if p == null:
		return
	p.set("fly_on_ready", false)
	p.set("collision_mask", 0)
	p.set("impact_on_expire", true)
	var v: float = p.get("speed") if p.get("speed") != null else 18.0
	p.set("lifetime", von.distance_to(ziel) / maxf(v, 0.1))
	kf.add_child(p)
	p.call("launch", von, ziel - von, -1.0, true)
	await _warte(von.distance_to(ziel) / maxf(v, 0.1))
	w.hurt(0, false, false, "fern")
	await _warte(1.0)
	await _frei(magier)


## Geschoss aus Combat VFX Mega: Mündung, Flug, Einschlag in einer Szene
func _mega_geschoss(pfad: String) -> void:
	var w = _wolf(magier)
	if w == null:
		return
	var von: Vector3 = await _ausholen(w)
	var b := _szene(pfad)
	if b == null:
		return
	b.set("autostart", false)
	kf.add_child(b)
	var getroffen := [false]
	if b.has_signal("hit"):
		b.connect("hit", func(_p): getroffen[0] = true; if is_instance_valid(w): w.hurt(0, false, false, "fern"))
	b.call("launch", von, _brust(w))
	var t := 0.0
	while not getroffen[0] and t < 3.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	await _warte(1.2)
	await _frei(magier)


func _strahl() -> void:
	var w = _wolf(magier)
	if w == null:
		return
	# wie 415: zum Ziel gedreht ausholen und halten, solange der Strahl steht (Figur.strike dreht nach 0,6 s zurück)
	magier.busy_ms = 3200
	magier._face(w.global_position - magier.global_position)
	magier._play("Ausholen")
	await _warte(0.45)
	var cp = magier.cast_point()
	var von: Vector3 = cp if cp is Vector3 else magier.global_position + Vector3(0, 1.4, 0)
	var r := _szene(C + "beams/beam_arcane.tscn")
	if r == null:
		return
	r.set("autostart", false)
	r.set("loop", true)
	kf.add_child(r)
	(r as Node3D).global_position = von
	r.call("aim_at", _brust(w))
	r.call("play")
	w.hurt(300, false, false, "fern")
	await _warte(2.2)
	r.call("stop")
	await _warte(0.8)
	if is_instance_valid(r):
		r.queue_free()
	magier.busy_ms = 0
	magier._face()
	magier._idle()


## Kettenblitz (VFX Pack 3): ein Bogen je Sprung, Stab → Wolf → nächster Wolf
func _kette() -> void:
	var w1 = _wolf(magier)
	if w1 == null:
		return
	var w2 = _wolf(w1, w1)
	var von: Vector3 = await _ausholen(w1)
	var pfad := VX + "pack3_effects/chain_lightning.tscn"
	var a := _szene(pfad)
	if a == null:
		return
	kf.add_child(a)
	(a as Node3D).global_position = von
	a.call("aim_at", _brust(w1))
	w1.hurt(0, false, false, "fern")
	if w2 != null:
		await _warte(0.18)
		var b := _szene(pfad)
		kf.add_child(b)
		(b as Node3D).global_position = _brust(w1)
		b.call("aim_at", _brust(w2))
		w2.hurt(0, false, false, "fern")
	await _warte(1.2)
	await _frei(magier)


func _blitztreffer() -> void:
	var w = _wolf(magier)
	if w == null:
		return
	await _ausholen(w)
	_setze(C + "impacts/hit_lightning.tscn", _brust(w), magier.global_position)
	w.hurt(0, false, false, "fern")
	await _warte(1.2)
	await _frei(magier)


func _plasma() -> void:
	var w = _wolf(magier)
	if w == null:
		return
	await _ausholen(w)
	_setze(VX + "pack3_effects/plasma_impact.tscn", _brust(w))
	w.hurt(0, false, false, "fern")
	await _warte(1.2)
	await _frei(magier)


## mitten zwischen den Wölfen am Boden
func _explosion() -> void:
	var w = _wolf(magier)
	if w == null:
		return
	await _ausholen(w)
	var m := Vector3.ZERO
	var n := 0
	for id in kf.figures:
		var f = kf.figures[id]
		if f.fighter.monster != null and not f.down and f.visible:
			m += f.global_position
			n += 1
	m /= maxf(n, 1)
	_setze(C + "explosions/explosion_fire_large.tscn", m)
	for id in kf.figures:
		var f = kf.figures[id]
		if f.fighter.monster != null and not f.down and f.visible and f.global_position.distance_to(m) < 2.5:
			f.hurt(150, false, true, "fern")
	await _warte(2.0)
	await _frei(magier)


## Zustand am Körper (Status Effects: Füße am Ursprung der Figur), [s] Sekunden, dann stop()
func _zustand(pfad: String, fig, s: float) -> void:
	if fig == null:
		return
	var fx := _szene(pfad)
	if fx == null:
		return
	fig.add_child(fx)
	(fx as Node3D).position = Vector3.ZERO
	if fig.fighter.monster != null:
		(fx as Node3D).scale = Vector3.ONE * clampf(fig.head().y - fig.position.y, 0.6, 2.0) / 1.8
	await _warte(s)
	if is_instance_valid(fx) and fx.has_method("stop"):
		fx.call("stop")
	await _warte(0.6)


func _aura() -> void:
	var a := _szene(C + "auras/aura_holy.tscn")
	if a == null:
		return
	a.set("loop", true)
	held.add_child(a)
	await _warte(3.0)
	if is_instance_valid(a):
		a.call("stop")
	await _warte(0.8)
	if is_instance_valid(a):
		a.queue_free()


func _glitzer() -> void:
	var w = _wolf(held)
	var p: Vector3 = held.global_position.lerp(w.global_position, 0.5) if w != null else held.global_position + Vector3(0, 0, 1)
	_setze(VX + "effects/pickup_sparkle.tscn", Vector3(p.x, held.global_position.y + 0.05, p.z))
	await _warte(2.0)


## Character Shaders: der Wolf verbrennt zu Asche (Dissolve, Feuerkante); die eigene Tusche und das Toon-Licht weichen dafür der
## Oberfläche des Pakets (nur Zusatzschicht laut 623 A: so sieht man, was der Tausch kostet)
func _aufloesen() -> void:
	var w = _wolf(held)
	if w == null or w.model == null:
		return
	var vorlage = load(CS + "dissolve/dissolve_fire.tres")
	if not (vorlage is ShaderMaterial):
		return
	var alle: Array = []
	for m in w.model.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		var vorher: Array = []
		for i in mi.mesh.get_surface_count():
			vorher.append(mi.get_surface_override_material(i))
		aufgeloest.append([mi, vorher])
		for i in mi.mesh.get_surface_count():
			var alt: Material = vorher[i]
			var d := (vorlage as ShaderMaterial).duplicate() as ShaderMaterial
			if alt is ShaderMaterial and (alt as ShaderMaterial).get_shader_parameter("tex") != null:
				d.set_shader_parameter("albedo_texture", (alt as ShaderMaterial).get_shader_parameter("tex"))
			d.set_shader_parameter("dissolve_progress", 0.0)
			mi.set_surface_override_material(i, d)
			alle.append(d)
	var tw := create_tween().set_parallel(true)
	for d in alle:
		tw.tween_property(d, "shader_parameter/dissolve_progress", 1.0, 1.8)
	await _warte(2.2)
	w.visible = false


## nach einer Runde (im Spiel, nicht im Film): der aufgelöste Wolf kommt zurück
func _wiederbeleben() -> void:
	for e in aufgeloest:
		var mi: MeshInstance3D = e[0]
		if not is_instance_valid(mi):
			continue
		for i in (e[1] as Array).size():
			mi.set_surface_override_material(i, e[1][i])
	aufgeloest.clear()
	for id in kf.figures:
		var f = kf.figures[id]
		if f.fighter.monster != null and not f.down:
			f.visible = true


# ---------------------------------------------------------------- Anzeige, Ruhe (wie kampf/strahlprobe.gd)

func _process(_dt: float) -> void:
	if lb == null:
		return
	var fps := Engine.get_frames_per_second()
	if jetzt != "":
		var m: Array = mittel.get(jetzt, [0.0, 0])
		m[0] += fps
		m[1] += 1
		mittel[jetzt] = m
	var kopf := "623.5 Effektprobe · %s" % (jetzt if jetzt != "" else "–")
	if jetzt != "":
		kopf += "\n" + (("unsere Fassung: " + paket) if unsere else paket)
	if film:     # im Film zählen die Bilder je Sekunde des Rechners, nicht des Handys
		lb.text = kopf
		return
	var z := PackedStringArray([kopf, "%d Bilder/s · Renderer %s" % [fps, RenderingServer.get_current_rendering_method()]])
	var tief := 999.0
	var tief_n := ""
	for n in mittel:
		var mw: float = mittel[n][0] / maxf(mittel[n][1], 1)
		if mw < tief:
			tief = mw
			tief_n = n
	if tief_n != "":
		z.append("am langsamsten: %s, Mittel %.0f Bilder/s" % [tief_n, tief])
	if not fehlen.is_empty():
		z.append("fehlt: " + ", ".join(fehlen))
	lb.text = "\n".join(z)


func _oberflaeche() -> void:
	var cl := CanvasLayer.new()
	cl.layer = 100
	add_child(cl)
	var vs := get_viewport().get_visible_rect().size
	lb = Label.new()
	lb.position = Vector2(vs.x * 0.05, vs.y * 0.04)
	lb.size = Vector2(vs.x * 0.9, 0)
	lb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lb.add_theme_font_size_override("font_size", int(vs.x / 412.0 * 14.0))
	lb.add_theme_color_override("font_outline_color", Color.BLACK)
	lb.add_theme_constant_override("outline_size", int(vs.x / 412.0 * 4.0))
	cl.add_child(lb)
	if film:
		return
	var reihe := HBoxContainer.new()
	reihe.position = Vector2(vs.x * 0.05, vs.y * 0.86)
	reihe.add_theme_constant_override("separation", int(vs.x * 0.04))
	cl.add_child(reihe)
	k_fassung = Button.new()
	k_fassung.text = "Fassung: Paket"
	k_fassung.pressed.connect(func():
		unsere = not unsere
		k_fassung.text = "Fassung: unsere" if unsere else "Fassung: Paket")
	var k1 := Button.new()
	k1.text = "Renderer wechseln"
	k1.pressed.connect(_renderer_wechseln)
	reihe.add_child(k1)
	var k2 := Button.new()
	k2.text = "Zurück"
	k2.pressed.connect(func():     # der Kampfort hängt an der Wurzel (Probe._start), nicht unter dieser Szene
		if is_instance_valid(kf):
			kf.queue_free()
		get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene")))
	reihe.add_child(k2)
	var reihe0 := HBoxContainer.new()     # 623.5: Fassung darüber, ganze Breite
	reihe0.position = Vector2(vs.x * 0.05, vs.y * 0.79)
	cl.add_child(reihe0)
	reihe0.add_child(k_fassung)
	for k in [k1, k2]:
		k.add_theme_font_size_override("font_size", int(vs.x / 412.0 * 16.0))
		k.custom_minimum_size = Vector2(vs.x * 0.4, vs.y * 0.06)
	k_fassung.add_theme_font_size_override("font_size", int(vs.x / 412.0 * 16.0))
	k_fassung.custom_minimum_size = Vector2(vs.x * 0.84, vs.y * 0.06)


## Mobile <-> Kompatibilität (OpenGL); wirkt nach Neustart (wie 415)
func _renderer_wechseln() -> void:
	var jetzt_r := RenderingServer.get_current_rendering_method()
	var neu := "gl_compatibility" if jetzt_r != "gl_compatibility" else "mobile"
	var cfg := ConfigFile.new()
	cfg.set_value("rendering", "renderer/rendering_method", neu)
	cfg.set_value("rendering", "renderer/rendering_method.mobile", neu)
	cfg.save(RENDERER_CFG)
	lb.text += "\nNach Neustart der App: %s" % neu


## wartet, bis der Kampf auf einen Zug der Gruppe wartet (höchstens 20 s), und hält ihn dann an (wie 415)
func _kampf_ruht() -> void:
	var t := 0.0
	while t < 20.0:
		if not kf.busy and not kf.playing and kf.beats.is_empty() and (kf.mars.outcome != "ONGOING" or not kf.mars.pilot_next()):
			break
		await get_tree().process_frame
		t += get_process_delta_time()
	kf.busy = true
	await _bis_still()


## wartet, bis keine Figur sich mehr als 2 cm in 1 s bewegt, höchstens 10 s
func _bis_still() -> void:
	var alt := {}
	var t := 0.0
	var ruhig := 0.0
	while t < 10.0 and ruhig < 1.0:
		await get_tree().process_frame
		var dt := get_process_delta_time()
		t += dt
		var weit := 0.0
		for id in kf.figures:
			var p: Vector3 = kf.figures[id].global_position
			if alt.has(id):
				weit = maxf(weit, p.distance_to(alt[id]))
			alt[id] = p
		ruhig = ruhig + dt if weit < 0.02 * dt else 0.0


# ---------------------------------------------------------------- unsere Fassung (623.5, Chef 17:05)

## unsere Zauber und das Blut malt die Kampf-UI auf ihrer Fläche (overlay); für unsere Fassung ist nur diese Fläche an, Kasten,
## Hintergrund und Knöpfe des Kampfs bleiben aus
func _ui_fuer(an: bool) -> void:
	var ui = kf.ui if kf != null else null
	if ui == null:
		return
	ui.visible = an
	ui.nur_effekte = true
	if an and ui.root != null:
		for c in ui.root.get_children():
			c.visible = c == ui.overlay


func _id(fig) -> String:
	for id in kf.figures:
		if kf.figures[id] == fig:
			return String(id)
	return ""


## derselbe Anlass wie beim Paket, mit dem, was das Spiel heute zeigt (UNSERE)
func _unsere(k: String) -> void:
	var art: String = UNSERE.get(k, ["", ""])[0]
	if art != "":
		var nach_held: bool = art == "BLESS"
		var w = _wolf(magier)
		if w == null or magier == null:
			return
		var ziel = held if nach_held else w
		magier.strike(ziel, {"spell": "MAGIC_MISSILE", "roll": null})
		await _warte(0.45)
		kf.ui.cast(art, _id(magier), _id(ziel), false, false)
		await _warte(Zauber.arrives(art) / 1000.0)
		if not nach_held:
			w.hurt(0, false, false, "fern")
		await _warte(maxf(Zauber.duration(art) - Zauber.arrives(art), 0.0) / 1000.0 + 0.6)
		await _frei(magier)
		return
	if k == "parade":
		var w = _wolf(held)
		if w == null:
			return
		var auf := _schlag(w, held, false)
		held.abwehr(int(auf * 1000.0), "nah", w.global_position, true, w.niedrig())
		await _warte(auf)
		await _frei(w)
		return
	if k in ["gift", "ruestung", "staerke", "glitzer", "aufloesen", "kette", "blitztreffer", "plasma"]:
		await _warte(1.5)     # bei uns nichts an diesem Anlass: die Pause zeigt es
		return
	var w = _wolf(held)
	if w == null:
		return
	var auf := _schlag(held, w)
	await _warte(auf)
	w.hurt(0, false, false, "nah")
	if k == "krit":
		kf.ui.bleed(_id(held), _id(w), true, 0.6, "")
	await _warte(0.6)
	await _frei(held)
