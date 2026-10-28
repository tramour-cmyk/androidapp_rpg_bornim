extends Node
# 399.3 (Chef 28.10., 16:42: Klang in die Spielfassung; 398, Chef 11:38: „dass wir den Ton NICHT neu erfinden … sondern
# wiederverwenden“): Musik und Klang wie im alten Spiel, Zahlen aus Music.kt (MusicDirector), MusicPlayer.kt, SfxPlayer.kt,
# Footsteps.kt, Mix (SoundSettings.kt). Die Aufnahmen kopiert godot.yml aus app/src/main/assets nach daten/klang, dazu
# liste.json (Dateinamen ohne Endung je Ordner). Fehlen sie (Tests am Rechner), bleibt alles still.
# Kampfklang nach MarsSound.kt; was das alte Spiel synthetisiert, rendert KlangExport.kt im Bau als .wav (nicht neu gebaut).
# Noch nicht hier (Folgeschritte 399.3): Ortsklang (Feuer, Fluss, Vögel …), Raumklang (raum/), Bemerkgrenze (Threat), Schwarzblende (Hush).

const ORDNER := "res://daten/klang/"

# Music.kt MusicDirector
const PLACE_FADE_MS := 2000
const FIGHT_FADE_MS := 300
const TITLE_OUT_MS := 6000
const PAUSE_MS := 500
const ENTER_FADE_MS := 800
const STILLE_S := [10.0, 30.0]          # Ortsmusik spielt einmal, dann Ruhe
const HOEHLE_ERST_S := [20.0, 45.0]     # Höhle: erst nur der Teppich
const HOEHLE_RUHE_S := [45.0, 120.0]
const NACH_NIEDERLAGE_S := 10.0
# MusicPlayer.kt
const PEGEL := 0.6
const PEGEL_HOEHLE := 0.45
const PEGEL_TEPPICH := 0.8
const TEPPICH_FADE_MS := 2000
# SfxPlayer.kt
const STROEME := 8
const KLICK := 0.35
# Footsteps.kt
const SCHRITT := 0.42
const SCHRITT_RENNEN := 0.3
const SCHRITT_TEPPICH := 0.6

## Szene -> Vorsilbe der Stücke (MusicLib); BOSS ohne boss_ancient_legend (nur Tempelszene)
const VORSILBE := {"TITLE": "titel_", "VILLAGE": "dorf_", "FOREST": "wald_", "CAVE": "hoehle_", "BATTLE": "kampf_",
	"BOSS": "boss_", "VICTORY": "sieg_", "CHAPTER_END": "ende_", "TEMPLE": "boss_ancient_legend"}
const SCHLEIFE := ["TITLE", "BATTLE", "BOSS"]

var liste := {"music": [], "sfx": []}
var kampftabelle := {}                           # kampfklang.json (KlangExport.kt): Angriff und Stimme je Monster, Klang je Effekt
var szene := ""
var musik_an := true
var effekte_an := true
var schritte_an := true
var lautstaerke := {"all": 100, "music": 100, "fx": 100}

var _spieler: Array[AudioStreamPlayer] = []      # zwei für die Musik (aus, ein), einer für den Teppich
var _teppich: AudioStreamPlayer
var _effekte: Array[AudioStreamPlayer] = []
var _naechster := 0
var _zuletzt := {}                               # Szene -> letztes Stück (nie zweimal hintereinander)
var _lauf := 0                                   # jede neue Szene macht ältere Zeitgeber ungültig
var _zufall := RandomNumberGenerator.new()
var _held: Node3D
var _karte
var _phase := -1.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_zufall.randomize()
	if FileAccess.file_exists(ORDNER + "liste.json"):
		var j = JSON.parse_string(FileAccess.get_file_as_string(ORDNER + "liste.json"))
		if j is Dictionary:
			liste = j
	if FileAccess.file_exists(ORDNER + "kampfklang.json"):
		var t = JSON.parse_string(FileAccess.get_file_as_string(ORDNER + "kampfklang.json"))
		if t is Dictionary:
			kampftabelle = t
	for bus in ["Musik", "Effekte"]:
		if AudioServer.get_bus_index(bus) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
	for i in 3:
		var p := AudioStreamPlayer.new()
		p.bus = "Musik"
		add_child(p)
		_spieler.append(p)
	_teppich = _spieler.pop_back()
	_teppich.bus = "Effekte"     # Mix: der Höhlenteppich folgt dem Effektregler (bedGain)
	for i in STROEME:
		var p := AudioStreamPlayer.new()
		p.bus = "Effekte"
		add_child(p)
		_effekte.append(p)
	_lade_einstellungen()
	get_tree().node_added.connect(_neuer_knoten)


# ---------------------------------------------------------------- Musik (MusicDirector)

## Die Szene des Orts einer Karte (App.kt: TOWN, INTERIOR → VILLAGE, FOREST, CAVE)
static func szene_von(art: String) -> String:
	return {"FOREST": "FOREST", "CAVE": "CAVE"}.get(art, "VILLAGE")


## Ort betreten: Musik des Orts, Schritte nach seinem Boden
func ort(karte, held: Node3D) -> void:
	_karte = karte
	_held = held
	_phase = -1.0
	spiele_szene(szene_von(String(karte.daten.get("art", ""))))


func spiele_szene(neu: String) -> void:
	if neu == szene:
		return
	var alt := szene
	szene = neu
	_lauf += 1
	var lauf := _lauf
	var kampf := neu in ["BATTLE", "BOSS"]
	var aus_ms := FIGHT_FADE_MS if kampf else (TITLE_OUT_MS if alt == "TITLE" else PLACE_FADE_MS)
	for p in _spieler:
		_blende(p, 0.0, aus_ms, true)
	if neu != "CAVE" and not (kampf and alt == "CAVE"):     # ein Kampf in der Höhle behält deren Teppich
		_blende(_teppich, 0.0, TEPPICH_FADE_MS, true)
	await _warte((aus_ms + PAUSE_MS) / 1000.0)
	if lauf != _lauf:
		return
	if neu == "CAVE":
		_teppich_weiter(lauf)
		await _warte(_zufall.randf_range(HOEHLE_ERST_S[0], HOEHLE_ERST_S[1]))
		if lauf != _lauf:
			return
	_stueck(neu, lauf, FIGHT_FADE_MS if kampf else ENTER_FADE_MS)


## Nach dem Kampf: gewonnen das Siegesstück, dann die Ortsmusik; sonst nach 10 s die Ortsmusik
func nach_kampf(gewonnen: bool, karte) -> void:
	var ort_szene := szene_von(String(karte.daten.get("art", ""))) if karte != null else "VILLAGE"
	_lauf += 1
	var lauf := _lauf
	for p in _spieler:
		_blende(p, 0.0, FIGHT_FADE_MS, true)
	szene = ""
	if gewonnen and not _stuecke("VICTORY").is_empty():
		await _warte((FIGHT_FADE_MS + PAUSE_MS) / 1000.0)
		if lauf != _lauf:
			return
		var p := _stueck("VICTORY", lauf, FIGHT_FADE_MS)
		if p != null:
			await p.finished
	else:
		await _warte(NACH_NIEDERLAGE_S)
	if lauf == _lauf:
		spiele_szene(ort_szene)


func _stuecke(sz: String) -> Array:
	var v: String = VORSILBE.get(sz, "")
	if v == "":
		return []
	var l: Array = liste.get("music", []).filter(func(n): return String(n).begins_with(v))
	if sz == "BOSS":
		l.erase("boss_ancient_legend")
	return l


func _waehle(sz: String, l: Array) -> String:
	if l.is_empty():
		return ""
	var frei := l.filter(func(n): return n != _zuletzt.get(sz, ""))
	if frei.is_empty():
		frei = l
	var n: String = frei[_zufall.randi_range(0, frei.size() - 1)]
	_zuletzt[sz] = n
	return n


func _stueck(sz: String, lauf: int, ein_ms: int) -> AudioStreamPlayer:
	if not musik_an:
		return null
	var n := _waehle(sz, _stuecke(sz))
	var s: AudioStream = _strom("music/" + n) if n != "" else null
	if s == null:
		return null
	if s is AudioStreamOggVorbis:
		(s as AudioStreamOggVorbis).loop = sz in SCHLEIFE
	var p: AudioStreamPlayer = _spieler[0] if not _spieler[0].playing else _spieler[1]
	p.stop()
	p.stream = s
	p.volume_db = linear_to_db(0.0001)
	p.play()
	_blende(p, PEGEL_HOEHLE if sz == "CAVE" else PEGEL, ein_ms, false)
	if not sz in SCHLEIFE and sz != "VICTORY":
		p.finished.connect(func(): _danach(sz, lauf), CONNECT_ONE_SHOT)
	return p


## Ortsmusik ist zu Ende: Ruhe, dann das nächste Stück der Szene
func _danach(sz: String, lauf: int) -> void:
	var ruhe: Array = HOEHLE_RUHE_S if sz == "CAVE" else STILLE_S
	await _warte(_zufall.randf_range(ruhe[0], ruhe[1]))
	if lauf == _lauf and szene == sz:
		_stueck(sz, lauf, ENTER_FADE_MS)


func _teppich_weiter(lauf: int) -> void:
	if not musik_an or lauf != _lauf:
		return
	var n := _waehle("grund", liste.get("music", []).filter(func(x): return String(x).begins_with("grund_")))
	var s: AudioStream = _strom("music/" + n) if n != "" else null
	if s == null:
		return
	_teppich.stream = s
	_teppich.volume_db = linear_to_db(0.0001)
	_teppich.play()
	_blende(_teppich, PEGEL_TEPPICH, TEPPICH_FADE_MS, false)
	_teppich.finished.connect(func(): _teppich_weiter(lauf), CONNECT_ONE_SHOT)


func _blende(p: AudioStreamPlayer, ziel: float, ms: int, dann_aus: bool) -> void:
	if not p.playing:
		return
	var von := db_to_linear(p.volume_db)
	var tw := create_tween()
	tw.tween_method(func(x: float): p.volume_db = linear_to_db(maxf(x, 0.0001)), von, ziel, ms / 1000.0)
	if dann_aus:
		tw.tween_callback(p.stop)


func _warte(s: float) -> void:
	await get_tree().create_timer(s, true).timeout


# ---------------------------------------------------------------- Effekte (SfxPlayer)

## Ein Klang [id] (Sound-Name klein, z. B. "click", "door", "coins") mit einer zufälligen seiner Aufnahmen
func effekt(id: String, pegel := 0.8, tempo := 1.0) -> void:
	if not effekte_an:
		return
	var takes: Array = liste.get("sfx", []).filter(func(n): return String(n).begins_with(id + "_") and String(n).substr(id.length() + 1).is_valid_int())
	if takes.is_empty():
		return
	var s := _strom("sfx/" + String(takes[_zufall.randi_range(0, takes.size() - 1)]))
	if s == null:
		return
	var p := _effekte[_naechster]
	_naechster = (_naechster + 1) % STROEME
	p.stop()
	p.stream = s
	p.pitch_scale = tempo
	p.volume_db = linear_to_db(maxf(pegel, 0.0001))
	p.play()


## SfxPlayer.voice: die Stimme des Monsters [id] („angriff“, „schmerz“, „tod“), tiefer für Grimmzahn und Elite (Recorded.voiceOf)
func stimme(id: String, ruf: String, elite := false, pegel := 0.8) -> void:
	var st: Dictionary = kampftabelle.get("stimme", {}).get(id, {})
	if st.is_empty():
		return
	var tempo := float(st.get("tempo", 1.0)) * (float(kampftabelle.get("elite_tempo", 0.9)) if elite else 1.0)
	effekt("%s_%s" % [st.stimme, ruf], pegel, tempo)


# ---------------------------------------------------------------- Kampf (MarsSound.kt, wie im alten MARS)

const LANDS_MS := 170                    # der Hieb landet nach dem halben Ausfall (SWING_IN_MS)
const CRY_MS := LANDS_MS + 90            # der Schrei gleich nach dem Klang des Treffers, nie darüber
const SCHWER := ["mace", "maul", "morningstar", "warhammer"]     # Icon.HAMMER, Icon.MACE

## Die Klänge einer MARS-Meldung [e] (kampfort.gd _play_say) nach MarsSound.of: Hiebe nach Waffe oder Angriff des Gegners,
## kritisch, Zauber nach Art, Heilung, Gift, Fallen; der Schwung der Gruppe vor dem Treffer, die Stimme des Gegners.
## [treffer_ms]: wann der Treffer im Kampfort landet (Anlauf und Biss dauern dort länger als die 170 ms des alten Ausfalls);
## Schwung und Schrei halten den alten Abstand dazu; -1: wie alt
func kampf(e: Dictionary, mars, treffer_ms := -1) -> void:
	var by = mars.find(e.actor) if e.actor != null else null
	var tg = mars.find(e.target) if e.target != null else null
	if e.cue != null:
		match String(e.cue):
			"FOE_STRIKES":
				if by != null and by.monster != null:
					_bald(0, func(): stimme(String(by.monster.id), "angriff", _elite(by)))
			"CIRCLE": _bald(0, func(): effekt("howl"))
			"HEAL", "DRINK": _bald(0, func(): effekt("heal"))
			"GATHER": _bald(0, func(): effekt(_fx_klang("ENEMY_HEAL")))
			"VENOM": _bald(0, func(): effekt("poison"))
			"WEB": _bald(0, func(): effekt("throw"))
			"FOE_FALLS": _bald(0, func(): effekt("enemy_down"))
			"HERO_FALLS", "KNOCKED_OUT": _bald(0, func(): effekt("hero_down"))
			"POUNCED": _bald(0, func(): effekt("hit_smash", 0.6))     # Rückläufer t53: zu Boden geworfen
			"DUCKED": _bald(0, func(): effekt("arrow"))               # Rückläufer t58: der Pfeil zischt vorbei
		return
	var krit: bool = e.roll != null and e.roll[0] == "ATTACK" and e.roll[4] and e.roll[1] == 20
	if e.spell != null:
		if String(e.spell) in ["HEAL", "BLESS"] or (by != null and tg != null and by.side != tg.side):
			_bald(0, func(): effekt(_fx_klang(String(e.spell), krit)))
		return
	if by == null or tg == null or by.side == tg.side or e.roll == null or e.roll[0] != "ATTACK":
		return
	var art := _angriff(by)
	var ausfall := art != "ARROW"
	var landet := (treffer_ms if treffer_ms >= 0 else LANDS_MS) if ausfall else 0
	if by.side == "PARTY" and ausfall:
		var w = by.weapon()
		var schwer: bool = w != null and (bool(w.get("two", false)) or String(w.get("id", "")) in SCHWER)
		_bald(maxi(0, landet - LANDS_MS), func(): effekt("swing_heavy" if schwer else "swing"))
	if e.damage > 0:
		_bald(landet, func(): effekt(_fx_klang(art, krit)))
		if tg.monster != null:
			var stirbt: bool = int(e.hp.get(tg.id, 1)) <= 0
			_bald(landet + CRY_MS - LANDS_MS, func(): stimme(String(tg.monster.id), "tod" if stirbt else "schmerz", _elite(tg)))
	elif art == "ARROW":
		_bald(0, func(): effekt("arrow"))
	else:
		_bald(landet, func(): effekt("miss"))


## MarsSound.music: das Bossstück nur gegen einen Boss
func kampfmusik(mars) -> void:
	spiele_szene("BOSS" if mars.all.any(func(f): return f.side == "FOES" and f.boss()) else "BATTLE")


## Monster.attackFx, sonst Battle.weaponFx
func _angriff(f) -> String:
	if f.monster != null:
		return String(kampftabelle.get("monster_fx", {}).get(String(f.monster.id), "SLASH"))
	var w = f.weapon()
	if w == null:
		return "SMASH"
	if bool(w.get("ranged", false)):
		return "ARROW"
	return {"SLASHING": "SLASH", "PIERCING": "PIERCE"}.get(String(w.get("type", "")), "SMASH")


## FxSound.of
func _fx_klang(art: String, krit := false) -> String:
	if krit and art in ["SLASH", "PIERCE", "SMASH"]:
		return "crit"
	return String(kampftabelle.get("fx_klang", {}).get(art, "hit_smash"))


func _elite(f) -> bool:
	return f.get("elite") == true


func _bald(ms: int, was: Callable) -> void:
	if ms <= 0:
		was.call()
		return
	get_tree().create_timer(ms / 1000.0, true).timeout.connect(was)


## Footsteps.sound: Boden unter dem Helden
static func schritt_klang(art: String, karte_id: String, kachel: String) -> String:
	if art == "CAVE":
		return "step_stone"
	if art == "INTERIOR":
		return "step_cobble" if karte_id == "temple" else "step_wood"
	match kachel:
		"BRIDGE": return "step_wood"
		"COBBLE": return "step_cobble"
		"PATH", "DOOR", "CAVE_ENTRANCE": return "step_earth"
	return "step_grass"


func _process(_dt: float) -> void:
	# Footsteps.Feet: ein Schritt, wenn ein Fuß aufsetzt; Gehen und Rennen beginnen mit dem rechten Fuß vorn (held.gd), also bei
	# 0 und der Hälfte der Runde
	if _held == null or not is_instance_valid(_held) or _karte == null or not schritte_an or not effekte_an:
		return
	var anim: AnimationPlayer = _held.get("anim")
	if anim == null or not (anim.current_animation.begins_with("Gehen") or anim.current_animation.begins_with("Rennen")):
		_phase = -1.0
		return
	var f := anim.current_animation_position / maxf(0.001, anim.current_animation_length)
	var h := floorf(f * 2.0)
	if _phase >= 0.0 and h != floorf(_phase * 2.0):
		var t: Vector2i = _karte.pos_kachel(_held.position)
		var z: String = _karte.zeichen(t)
		var boden := String(_karte.kacheln.get(z, {}).get("name", ""))
		var rennt := anim.current_animation.begins_with("Rennen")
		effekt(schritt_klang(String(_karte.daten.get("art", "")), _karte.id, boden),
			(SCHRITT_RENNEN if rennt else SCHRITT) * (SCHRITT_TEPPICH if boden == "RUG" else 1.0))
	_phase = f


## LocalClick: jeder Knopf klickt leise
func _neuer_knoten(n: Node) -> void:
	if n is BaseButton:
		(n as BaseButton).pressed.connect(func(): effekt("click", KLICK))


# ---------------------------------------------------------------- Einstellungen (SoundSettings.kt, Mix)

func _lade_einstellungen() -> void:
	var c := ConfigFile.new()
	if c.load("user://klang.cfg") == OK:
		for k in lautstaerke:
			lautstaerke[k] = int(c.get_value("klang", "volume_" + k, 100))
		musik_an = bool(c.get_value("klang", "music", true))
		effekte_an = bool(c.get_value("klang", "sfx", true))
		schritte_an = bool(c.get_value("klang", "steps", true))
	_mische()


## Regler 0–100 ("all", "music", "fx"); über 0 schaltet die Art wieder ein
func stelle(regler: String, wert: int) -> void:
	lautstaerke[regler] = clampi(wert, 0, 100)
	if wert > 0 and regler == "music":
		musik_an = true
	if wert > 0 and regler == "fx":
		effekte_an = true
	_mische()
	var c := ConfigFile.new()
	for k in lautstaerke:
		c.set_value("klang", "volume_" + k, lautstaerke[k])
	c.set_value("klang", "music", musik_an)
	c.set_value("klang", "sfx", effekte_an)
	c.set_value("klang", "steps", schritte_an)
	c.save("user://klang.cfg")


## Mix.gain = (all/100 · part/100)²; der Höhlenteppich zählt als Effekt
static func gain(all: int, part: int) -> float:
	var g := all / 100.0 * part / 100.0
	return g * g


func _mische() -> void:
	var m := gain(lautstaerke.all, lautstaerke.music) if musik_an else 0.0
	var e := gain(lautstaerke.all, lautstaerke.fx) if effekte_an else 0.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musik"), linear_to_db(maxf(m, 0.0001)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effekte"), linear_to_db(maxf(e, 0.0001)))


## Aufnahmen als .ogg, die synthetischen Klänge (KlangExport.kt) als .wav
func _strom(pfad: String) -> AudioStream:
	for endung in [".ogg", ".wav"]:
		if ResourceLoader.exists(ORDNER + pfad + endung):
			return load(ORDNER + pfad + endung) as AudioStream
	return null
