extends Node
# 399.3 (Chef 28.10., 16:42: Klang in die Spielfassung; 398, Chef 11:38: „dass wir den Ton NICHT neu erfinden … sondern
# wiederverwenden“): Musik und Klang wie im alten Spiel, Zahlen aus Music.kt (MusicDirector), MusicPlayer.kt, SfxPlayer.kt,
# Footsteps.kt, Mix (SoundSettings.kt). Die Aufnahmen kopiert godot.yml aus app/src/main/assets nach daten/klang, dazu
# liste.json (Dateinamen ohne Endung je Ordner). Fehlen sie (Tests am Rechner), bleibt alles still.
# Kampfklang nach MarsSound.kt; was das alte Spiel synthetisiert, rendert KlangExport.kt im Bau als .wav (nicht neu gebaut).
# Ortsklang wie PlaceSound.kt, Ambience.kt, RiverSound.kt (WorldScreen.kt: Wind, Halle, Feuer, Fluss, Tropfen, Knarren, Husten);
# Raumklang wie Room.kt: die Fassungen aus app/src/main/assets/raum (Vorschau RAUMKLANG=spiel), die synthetischen aus KlangExport.kt.
# Kleines Leben und ferne Laute wie WildSound.kt (517): Vögel am Tag, Grillen und Eule nachts, im Tiefen Wald fernes Wolfsheulen,
# in der Höhle Grollen im Berg.
# Noch nicht hier (Folgeschritte 399.3): Leute (Tassen, Stühle, D1.10), Teich, Hühner, pickende Vögel, Regen (gibt es in Godot noch nicht),
# Bemerkgrenze (Threat).
# Schwarzblende wie Hush.kt und VeilGate (Music.kt): solange sie steht, schweigen die Effekte (außer Klick und Tür), danach
# kommen sie in 400 ms wieder; neue Musik und der Höhlenteppich erst nach der Blende und 500 ms Ruhe.

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
var schleier := false                            # Hush.veiled: die Schwarzblende steht
var _schleier_ende := -100000                    # Time.get_ticks_msec(), als sie zuletzt ging
const AUFTAUCHEN_MS := 400                       # VeilGate.EFFECTS_RISE_MS
const DURCH := ["click", "door"]                # VeilGate.THROUGH
# Ortsklang (PlaceSound.Kind): OUTSIDE, TAVERN, HALL, ROOM, CAVE; Raum = Ordner der Raumfassungen (leer draußen)
var ortsart := ""
var raum := ""
var _schleifen := {}                             # Schlüssel -> {"p": AudioStreamPlayer, "v": Pegel}
var _ort_ms := 0.0                               # Uhr des Orts, seit er betreten wurde
var _ort_takt := 0.0
var _ereignis_ms := 0.0
var _tropfen_ms := 0.0
var _letztes := ""
var _feuer_bei := Vector2i(-99999, -99999)       # Kachel, für die _feuer_weit gilt (neu nur, wenn der Held weitergeht)
var _feuer_weit = null
var _fluss_bei := Vector2i(-99999, -99999)
var _fluss_weit = null
var _fluss := {}                                 # Karte -> fließendes Wasser (RiverSound.running)
var _leben_ms := 0.0                             # 517: nächstes kleines Leben (WildSound.life)
var _fern_ms := 0.0                              # 517: nächster ferner Laut (WildSound.far)
var _fern: AudioStreamPlayer                     # 517: von einer Seite, über den Bus „Fern“ mit Panner


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
	# 517: ferne Laute von einer Seite (WildSound.side, speakers): eigener Bus unter den Effekten mit Panner
	if AudioServer.get_bus_index("Fern") < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Fern")
		AudioServer.set_bus_send(AudioServer.bus_count - 1, "Effekte")
		AudioServer.add_bus_effect(AudioServer.bus_count - 1, AudioEffectPanner.new())
	_fern = AudioStreamPlayer.new()
	_fern.bus = "Fern"
	add_child(_fern)
	_lade_einstellungen()
	get_tree().node_added.connect(_neuer_knoten)


# ---------------------------------------------------------------- Musik (MusicDirector)

## Die Szene des Orts einer Karte (App.kt: TOWN, INTERIOR → VILLAGE, FOREST, CAVE)
static func szene_von(art: String) -> String:
	return {"FOREST": "FOREST", "CAVE": "CAVE"}.get(art, "VILLAGE")


## Ort betreten: Musik des Orts, Schritte nach seinem Boden
func ort(karte, held: Node3D) -> void:
	var neu: bool = _karte == null or _karte.id != karte.id
	_karte = karte
	_held = held
	_phase = -1.0
	if neu:
		_ort_betreten()
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
	if not (neu == "TITLE" and alt == ""):   # 399.1 Music.kt enter: die Titelmusik nach dem Vorspann sofort, ohne Pause
		await _warte((aus_ms + PAUSE_MS) / 1000.0)
	if not await _nach_schleier(lauf):
		return
	if neu == "CAVE":
		_teppich_weiter(lauf)
		await _warte(_zufall.randf_range(HOEHLE_ERST_S[0], HOEHLE_ERST_S[1]))
		if lauf != _lauf:
			return
	_stueck(neu, lauf, FIGHT_FADE_MS if kampf else ENTER_FADE_MS)


## 399.1 Intro (Tom; Music.kt INTRO_LEVEL): die laufende Musik auf [k] ihres Pegels, in [ms]
func musik_stufe(k: float, ms := PLACE_FADE_MS) -> void:
	for p in _spieler:
		if p.playing:
			_blende(p, PEGEL * k, ms, false)


## 399.1 Intro (Tom; IntroSoundUi.kt): eine Schleife [klang] unter [schluessel] sofort auf [pegel], 0 beendet sie
func schleife_stellen(schluessel: String, klang: String, pegel: float) -> void:
	_schleife(schluessel, klang, pegel, 1.0, 1.0, 1.0)


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


## Hush: die Schwarzblende steht ([an]) oder geht
func verhuelle(an: bool) -> void:
	if schleier and not an:
		_schleier_ende = Time.get_ticks_msec()
	schleier = an


## VeilGate.effects: 0 in der Blende, danach in 400 ms wieder ganz
func schleier_pegel() -> float:
	if schleier:
		return 0.0
	return clampf((Time.get_ticks_msec() - _schleier_ende) / float(AUFTAUCHEN_MS), 0.0, 1.0)


## VeilGate.musicMay: warten, bis die Blende fort ist und 500 ms danach; false, wenn inzwischen eine neue Szene kam
func _nach_schleier(lauf: int) -> bool:
	while lauf == _lauf and (schleier or Time.get_ticks_msec() - _schleier_ende < PAUSE_MS):
		await get_tree().process_frame
	return lauf == _lauf


func _warte(s: float) -> void:
	await get_tree().create_timer(s, true).timeout


# ---------------------------------------------------------------- Effekte (SfxPlayer)

## Ein Klang [id] (Sound-Name klein, z. B. "click", "door", "coins") mit einer zufälligen seiner Aufnahmen
func effekt(id: String, pegel := 0.8, tempo := 1.0, nr := -1) -> void:
	if not effekte_an:
		_merke(id, pegel, null, "Effekte aus")
		return
	if not id in DURCH:
		pegel *= schleier_pegel()
		if pegel <= 0.0:
			_merke(id, pegel, null, "Blende")
			return
	var takes: Array = liste.get("sfx", []).filter(func(n): return String(n).begins_with(id + "_") and String(n).substr(id.length() + 1).is_valid_int())
	if takes.is_empty():
		_merke(id, pegel, null, "keine Aufnahme")
		return
	var take := String(takes[_zufall.randi_range(0, takes.size() - 1)])
	if nr >= 0 and takes.has("%s_%d" % [id, nr + 1]):     # 399.1 Intro: eine bestimmte Aufnahme (IntroSound.Cue.take)
		take = "%s_%d" % [id, nr + 1]
	# Room.kt: im Raum die Fassung mit seinem Hall, wo es eine gibt (Umgebung, Schritte, Systemklänge haben keine, Room.affects)
	var s: AudioStream = _strom("raum/%s/%s" % [raum, take]) if raum != "" and liste.get("raum", {}).get(raum, []).has(take) else null
	if s == null:
		s = _strom("sfx/" + take)
	if s == null:
		_merke(take, pegel, null, "nicht geladen")
		return
	var p := _effekte[_naechster]
	_naechster = (_naechster + 1) % STROEME
	_abgebrochen(p)
	p.stop()
	p.stream = s
	p.pitch_scale = tempo
	p.volume_db = linear_to_db(maxf(pegel, 0.0001))
	p.play()
	_merke(take, pegel, p, "")


# 636 A (Chef 09.11., 06:55: Satz am Schlagbaum kam, trotzdem kein Geräusch; am Rechner spielt door_n ganz): die letzten Effekte für
# den Testmodus „Klang“ über der Welt, damit das Gerät zeigt, ob ein Klang gespielt, abgebrochen oder gar nicht erst gestartet wurde
const PROTOKOLL_MAX := 10
var protokoll: Array = []                        # {"was", "pegel", "p" (Spieler oder null), "grund", "t" (ticks), "ende_ms" (-1: offen)}


func _merke(was: String, pegel: float, p: AudioStreamPlayer, grund: String) -> void:
	protokoll.append({"was": was, "pegel": pegel, "p": p, "grund": grund, "t": Time.get_ticks_msec(), "ende_ms": -1})
	if protokoll.size() > PROTOKOLL_MAX:
		protokoll.pop_front()


## Der Spieler [p] wird für einen neuen Klang gebraucht: spielt seiner noch, ist er abgebrochen (alle STROEME belegt)
func _abgebrochen(p: AudioStreamPlayer) -> void:
	for e in protokoll:
		if e.p == p:
			if p.playing and e.ende_ms < 0:
				e.ende_ms = Time.get_ticks_msec() - int(e.t)
				e.grund = "abgebrochen"
			e.p = null


## Zeilen für die Anzeige: neueste oben, je Klang Name, Pegel, Lage (spielt, verklungen, abgebrochen, nicht gestartet) und Alter;
## dazu die Regler, weil ein Klang auch an ihnen still sein kann
func protokoll_zeilen() -> Array:
	var r: Array = ["Klang: alle %d %%, Effekte %d %%%s, %d Spieler" % [lautstaerke.all, lautstaerke.fx, "" if effekte_an else " (aus)", STROEME]]
	var jetzt := Time.get_ticks_msec()
	for i in range(protokoll.size() - 1, -1, -1):
		var e: Dictionary = protokoll[i]
		var lage := String(e.grund)
		if lage == "abgebrochen":
			lage = "abgebrochen nach %.1f s" % (e.ende_ms / 1000.0)
		elif lage == "":
			var p = e.p
			if p != null and is_instance_valid(p) and p.playing:
				lage = "spielt %.1f s" % p.get_playback_position()
			else:
				lage = "verklungen"
		r.append("%s  %.2f  %s  (vor %.1f s)" % [e.was, e.pegel, lage, (jetzt - int(e.t)) / 1000.0])
	return r


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
var _tod_kampf = null                    # 296.3: der Kampf (MARS), für den _tod_gerufen gilt
var _tod_gerufen := {}                   # 296.3: Gegner (id), deren Todesschrei schon kam

## Die Klänge einer MARS-Meldung [e] (kampfort.gd _play_say) nach MarsSound.of: Hiebe nach Waffe oder Angriff des Gegners,
## kritisch, Zauber nach Art, Heilung, Gift, Fallen; der Schwung der Gruppe vor dem Treffer, die Stimme des Gegners.
## [treffer_ms]: wann der Treffer im Kampfort landet (Anlauf und Biss dauern dort länger als die 170 ms des alten Ausfalls);
## Schwung und Schrei halten den alten Abstand dazu; -1: wie alt
func kampf(e: Dictionary, mars, treffer_ms := -1) -> void:
	var by = mars.find(e.actor) if e.actor != null else null
	var tg = mars.find(e.target) if e.target != null else null
	if _tod_kampf != mars:
		_tod_kampf = mars
		_tod_gerufen.clear()
	if e.cue != null:
		match String(e.cue):
			"FOE_STRIKES":
				if by != null and by.monster != null:
					_bald(0, func(): stimme(art_von(by.monster), "angriff", _elite(by)))
			"CIRCLE": _bald(0, func(): effekt("howl"))
			"HEAL", "DRINK": _bald(0, func(): effekt("heal"))
			"GATHER": _bald(0, func(): effekt(_fx_klang("ENEMY_HEAL")))
			"VENOM": _bald(0, func(): effekt("poison"))
			"WEB": _bald(0, func(): effekt("throw"))
			"FOE_FALLS":
				_bald(0, func(): effekt("enemy_down"))
				# 296.3 (Todesschrei; alt BattleScreen ENEMY_FAINT „its death cry once, if no blow struck it down“): fiel er durch
				# einen Zauber oder einen Zustand, schreit er mit dem Sturz, einmal; wer flieht, schreit nicht
				if tg != null and tg.monster != null and not tg.fled and not _tod_gerufen.has(tg.id):
					_tod_gerufen[tg.id] = true
					_bald(0, func(): stimme(art_von(tg.monster), "tod", _elite(tg)))
			"HERO_FALLS", "KNOCKED_OUT": _bald(0, func(): effekt("hero_down"))
			"POUNCED": _bald(0, func(): effekt("hit_smash", 0.6))     # Rückläufer t53: zu Boden geworfen
			"DUCKED": _bald(0, func(): effekt("arrow"))               # Rückläufer t58: der Pfeil zischt vorbei
		return
	var krit: bool = e.roll != null and e.roll[4] and ((e.roll[0] == "ATTACK" and e.roll[1] == 20) or (e.roll[0] == "BRS" and e.roll.size() > 7 and e.roll[7]))     # 478: auch nach dem BRS
	# 296.3 (Chef 08.11., 21:28, t270.11: „Feuerpfeil auf den Jungwolf. 0 Lebenspunkte, fällt tot um. Und dann irgendwann kommt ein
	# Geheul … definitiv so 3 Sekunden zu spät“): wer durch einen Zauber oder einen Zustand fällt, schrie erst mit der Meldung
	# „bricht zusammen“ (FOE_FALLS), und die spielt der Kampfort erst nach Sturz und Liegen; jetzt schreit er, wenn es ihn trifft
	# (Zauber: bei der Ankunft, treffer_ms), einmal
	var stirbt_jetzt: bool = e.damage > 0 and tg != null and tg.monster != null and not tg.fled and int(e.hp.get(tg.id, 1)) <= 0 \
			and not _tod_gerufen.has(tg.id) and (by == null or by.side != tg.side)
	var schlag: bool = e.spell == null and by != null and e.roll != null and e.roll[0] in ["ATTACK", "BRS"]     # der Hieb schreit unten
	if stirbt_jetzt and not schlag:
		_tod_gerufen[tg.id] = true
		_bald(maxi(0, treffer_ms) + CRY_MS - LANDS_MS, func(): stimme(art_von(tg.monster), "tod", _elite(tg)))
	if e.spell != null:
		if String(e.spell) in ["HEAL", "BLESS"] or (by != null and tg != null and by.side != tg.side):
			_bald(0, func(): effekt(_fx_klang(String(e.spell), krit)))
		return
	if by == null or tg == null or by.side == tg.side or e.roll == null or not (e.roll[0] in ["ATTACK", "BRS"]):     # 478: auch nach dem BRS
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
			if stirbt:
				_tod_gerufen[tg.id] = true     # 296.3: der Todesschrei kam mit dem Hieb, nicht noch einmal beim Sturz
			_bald(landet + CRY_MS - LANDS_MS, func(): stimme(art_von(tg.monster), "tod" if stirbt else "schmerz", _elite(tg)))
	elif art == "ARROW":
		_bald(0, func(): effekt("arrow"))
	else:
		_bald(landet, func(): effekt("miss"))


## 575 (Chef 04.11., 20:42: Riesenratten knurrten wie Wölfe): Stimme und Angriffsklang nach der Art, nie nach dem Körper; Ratten,
## Fledermäuse, Kobolde, Schamanen tragen den Körper einer anderen Art (577: id die eigene Art, „koerper“ nur für Modell und Bewegung)
static func art_von(m) -> String:
	return "" if m == null else String(m.id)


## MarsSound.music: das Bossstück nur gegen einen Boss
func kampfmusik(mars) -> void:
	spiele_szene("BOSS" if mars.all.any(func(f): return f.side == "FOES" and f.boss()) else "BATTLE")


## Monster.attackFx, sonst Battle.weaponFx
func _angriff(f) -> String:
	if f.monster != null:
		return String(kampftabelle.get("monster_fx", {}).get(art_von(f.monster), "SLASH"))
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


func _process(dt: float) -> void:
	_ort_takt += dt
	if _ort_takt >= ORT_TAKT_S:     # WorldScreen.kt: alle 100 ms
		_ortsklang(_ort_takt * 1000.0)
		_ort_takt = 0.0
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


# ---------------------------------------------------------------- Keuchen (Panting.kt, 95; Chef 28.10., Test 139.8)

const ATEM_LAUT := 0.6                   # Panting.LOUD: gleich nach dem Leerlaufen
const ATEM_LEISE := 0.3                  # Panting.QUIET: kurz bevor der Atem zurück ist
const ATEM_PAUSE_MS := 1400.0            # Panting.PAUSE_MS: Pause nach einem Atemzug, wenn der Atem fast zurück ist
const ATEM_WIEDER := 0.25                # Stamina.AGAIN (Ausdauer.WIEDER)
var _atem_naechst := 0.0

## Panting.breathMs: so lange dauert ein Atemzug (tools/klang/atem.py)
static func atem_ms(weiblich: bool) -> float:
	return 1600.0 if weiblich else 1420.0


## Panting.Breath.due: zur Zeit [jetzt] ms der Pegel eines Atemzugs, der jetzt kommt, sonst -1; erst Zug auf Zug, dann mit
## wachsender Pause und leiser, bis der Held wieder rennen darf
func atem_pegel(atemlos: bool, ausdauer: float, jetzt: float, weiblich := false) -> float:
	if not atemlos:
		_atem_naechst = 0.0
		return -1.0
	if jetzt < _atem_naechst:
		return -1.0
	var zurueck := clampf(ausdauer / ATEM_WIEDER, 0.0, 1.0)
	_atem_naechst = jetzt + atem_ms(weiblich) + ATEM_PAUSE_MS * zurueck
	return ATEM_LAUT + (ATEM_LEISE - ATEM_LAUT) * zurueck


## Jedes Bild aus spiel.gd: atemlos keucht der Held (WorldScreen.kt); bis der Held ein Geschlecht hat (erschaffung.gd), der Mann
func atme(atemlos: bool, ausdauer: float, weiblich := false) -> void:
	var p := atem_pegel(atemlos, ausdauer, float(Time.get_ticks_msec()), weiblich)
	if p > 0.0:
		effekt("pant_woman" if weiblich else "pant_man", p)


# ---------------------------------------------------------------- Ortsklang (PlaceSound, Ambience, RiverSound; WorldScreen.kt)

const ORT_TAKT_S := 0.1
# PlaceSound.kt
const BETT := 0.3                        # BED_VOLUME
const BETT_FADE_MS := 2000.0
const VERLASSEN_MS := 600                # LEAVE_FADE_MS: die Schleifen klingen aus, statt abzubrechen
const EREIGNIS := 0.35                   # EVENT_VOLUME
const WIRT := "innkeeper"                # HOST: wer Gast ist, hustet
# Ambience.kt
const FEUER_WEIT := 6.0
const FEUER_NAH := 1.0
const DRINNEN_TRAGEN := 1.5              # INDOOR_CARRY: drinnen füllt der Herd den Raum
const FEUER_MAX := 0.5
const FADE_MS := 1000.0
const TROPFEN_MS := [4000.0, 6000.0]     # DRIP_MIN_MS, DRIP_SPAN_MS
const TROPFEN := 0.45
const WAENDE := ["WALL", "CAVE_WALL", "CRYSTAL", "TORCH", "WINDOW", "ROOF", "ROOF_BLUE"]
# RiverSound.kt
const FLUSS_WEIT := 8.0
const FLUSS_NAH := 1.0
const FLUSS_MAX := 0.25


## PlaceSound.kindOf
static func ortsart_von(art: String, karte_id: String) -> String:
	if art in ["TOWN", "FOREST"]:
		return "OUTSIDE"
	if art == "CAVE":
		return "CAVE"
	return {"inn": "TAVERN", "temple": "HALL"}.get(karte_id, "ROOM")


## Room.file: die Raumfassungen je Ort (raum/cave, hall, tavern, room), draußen keine
static func raum_von(ortsart_: String) -> String:
	return "" if ortsart_ == "OUTSIDE" else ortsart_.to_lower()


## Ambience.fireTarget, RiverSound.target: still in der Ferne, sanft lauter zum Feuer, zum Ufer hin
static func ziel(weit, fern: float, nah: float, hoechst: float) -> float:
	if weit == null or float(weit) >= fern:
		return 0.0
	var t := clampf((fern - float(weit)) / (fern - nah), 0.0, 1.0)
	return hoechst * t * t * (3.0 - 2.0 * t)


## approach: höchstens ein ganzes An- oder Abschwellen je [fade_ms], nie ein Sprung
static func naeher(jetzt: float, soll: float, hoechst: float, dt_ms: float, fade_ms: float) -> float:
	var schritt := hoechst * dt_ms / fade_ms
	return minf(soll, jetzt + schritt) if soll > jetzt else maxf(soll, jetzt - schritt)


## Ambience.dripVolume: Tropfen etwas leiser, je lauter das Feuer
static func tropfen_pegel(feuer: float) -> float:
	return TROPFEN * (1.0 - 0.6 * feuer / FEUER_MAX)


## Neuer Ort: die Schleifen des alten klingen aus (600 ms), der erste Einzelklang bald, noch unter der Blende (firstMs)
func _ort_betreten() -> void:
	for k in _schleifen.keys():
		var p: AudioStreamPlayer = _schleifen[k].p
		_blende(p, 0.0, VERLASSEN_MS, true)
		get_tree().create_timer(VERLASSEN_MS / 1000.0 + 0.1, true).timeout.connect(p.queue_free)
	_schleifen.clear()
	ortsart = ortsart_von(String(_karte.daten.get("art", "")), String(_karte.id))
	raum = raum_von(ortsart)
	_ort_ms = 0.0
	_ereignis_ms = 600.0 + _zufall.randf_range(0.0, 1500.0 if ortsart == "TAVERN" else 4000.0)
	_tropfen_ms = 300.0 + _zufall.randf_range(0.0, 500.0)
	_letztes = ""
	_feuer_bei = Vector2i(-99999, -99999)
	_fluss_bei = Vector2i(-99999, -99999)
	wild = wild_art(String(_karte.daten.get("art", "")), String(_karte.id))
	_leben_ms = LEBEN_MS[0] + _zufall.randf_range(0.0, LEBEN_MS[1])
	_fern_ms = FERN_ERST_MS[0] + _zufall.randf_range(0.0, FERN_ERST_MS[1])


## Ruhig: auf der Karte, nicht im Kampf, kein Menü (WorldScreen.kt calm: Mode.Explore und kein Menü)
func _ruhig() -> bool:
	return _karte != null and _held != null and is_instance_valid(_held) and _held.is_visible_in_tree() \
		and not szene in ["BATTLE", "BOSS"] and not get_tree().paused


func _ortsklang(dt_ms: float) -> void:
	if _karte == null or ortsart == "":
		return
	_ort_ms += dt_ms
	var ruhig := _ruhig()
	var t: Vector2i = _karte.pos_kachel(_held.position) if ruhig else _feuer_bei
	# was unter allem liegt: Wind draußen, die Halle im Tempel (PlaceSound.bed)
	var bett: String = {"OUTSIDE": "wind", "HALL": "hall"}.get(ortsart, "")
	if bett != "":
		_schleife("bett", bett, BETT if ruhig else 0.0, BETT, dt_ms, BETT_FADE_MS)
	# das Knistern von Lagerfeuer und Herd, lauter zum Feuer hin, um Wände herum (Ambience.nearestFire)
	if ruhig and t != _feuer_bei:
		_feuer_bei = t
		_feuer_weit = feuer_weit(_karte, t)
	var feuer := _schleife("feuer", "crackle", ziel(_feuer_weit, FEUER_WEIT, FEUER_NAH, FEUER_MAX) if ruhig else 0.0, FEUER_MAX, dt_ms, FADE_MS)
	# fließendes Wasser rauscht, am lautesten am Ufer und auf der Brücke (RiverSound)
	if ortsart == "OUTSIDE":
		if ruhig and t != _fluss_bei:
			_fluss_bei = t
			_fluss_weit = fluss_weit(_karte, t)
		_schleife("fluss", "river", ziel(_fluss_weit, FLUSS_WEIT, FLUSS_NAH, FLUSS_MAX) if ruhig else 0.0, FLUSS_MAX, dt_ms, FADE_MS)
	# Tropfen in der Höhle, von selbst, der erste gleich
	if ortsart == "CAVE" and _ort_ms >= _tropfen_ms:
		if ruhig:
			effekt("drip", tropfen_pegel(feuer))
		_tropfen_ms = _ort_ms + TROPFEN_MS[0] + _zufall.randf_range(0.0, TROPFEN_MS[1])
	if ortsart == "OUTSIDE" and ruhig:
		_tierlaute(dt_ms)
	_wildlaute(ruhig)
	# Einzelklänge: Knarren im Holz der Häuser, ein Gast hustet (PlaceSound.events, gapMs 12–30 s)
	if _ort_ms >= _ereignis_ms:
		if ruhig:
			var e := waehle_ereignis(ereignisse(ortsart, _anwesend()), _letztes, _zufall)
			if e != "":
				effekt(e, EREIGNIS)
				_letztes = e
		_ereignis_ms = _ort_ms + 12000.0 + _zufall.randf_range(0.0, 18000.0)


# ---------------------------------------------------------------- Kleines Leben, ferne Laute (WildSound.kt; 84, D3.15; 517)

# 517 (von Team Tom, Abgleich 512): was an einem Ort lebt, aber nicht zu sehen ist: ab und zu leise Vögel am Tag, nachts Grillen und
# im Wald die Eule; im Tiefen Wald keine Vögel (D3.2), nachts Grillen, und selten, fern von einer Seite, ein Wolf (sie heulen nach
# Grimmzahns Tod weiter, auf der Suche nach einem neuen Leitwolf); in der Höhle grollt der Berg. Zahlen aus WildSound.kt.
const LEBEN_MS := [5000.0, 8000.0]       # LIFE_MIN_MS, LIFE_SPAN_MS
const LEBEN := 0.3                       # LIFE_VOLUME
const FERN_ERST_MS := [20000.0, 40000.0] # firstFarMs: nie das Erste, was man hört
const NACHT_AB := 0.65                   # Game.isNight: daylight < 0,35 (licht.gd nacht 0..1)
var wild := "NONE"                       # WildSound.Kind des Orts


## WildSound.kindOf
static func wild_art(art: String, karte_id: String) -> String:
	if karte_id == "deep_forest":
		return "DEEP_WOOD"
	return {"FOREST": "WOOD", "TOWN": "VILLAGE", "CAVE": "CAVE"}.get(art, "NONE")


## WildSound.life: das kleine Leben, das jetzt zu hören ist, oder keins
static func leben(art: String, nachts: bool, regen: bool, z: RandomNumberGenerator) -> String:
	if regen:
		return ""
	if art in ["VILLAGE", "WOOD"]:
		if nachts:
			return "owl" if art == "WOOD" and z.randi_range(0, 2) == 0 else "cricket"
		return "bird"
	if art == "DEEP_WOOD" and nachts:     # unter den alten Eichen keine Vögel, keine Eule; nachts Grillen
		return "cricket"
	return ""


## WildSound.far
static func fern(art: String) -> String:
	return {"DEEP_WOOD": "wolf_far", "CAVE": "rumble"}.get(art, "")


## WildSound.farGapMs: selten, der Wolf nachts alle 1–2½ Minuten, am Tag halb so oft; der Berg alle 1–3 Minuten
static func fern_pause_ms(art: String, nachts: bool, z: RandomNumberGenerator) -> float:
	if art == "DEEP_WOOD":
		return 60000.0 + z.randf_range(0.0, 90000.0) if nachts else 120000.0 + z.randf_range(0.0, 180000.0)
	return 60000.0 + z.randf_range(0.0, 120000.0)


## WildSound.farVolume: leise, jedes Mal ein wenig anders
static func fern_pegel(id: String, z: RandomNumberGenerator) -> float:
	return (0.22 if id == "wolf_far" else 0.3) + z.randf() * 0.1


## WildSound.side: woher, −1 links bis 1 rechts, nie geradeaus
static func seite(z: RandomNumberGenerator) -> float:
	return (0.35 + z.randf() * 0.5) * (1.0 if z.randf() < 0.5 else -1.0)


## WildSound.speakers: die abgewandte Seite leiser (1 − 0,8·Seite), nie stumm; der Panner in Godot nimmt links 1 − pan: pan = 0,8·Seite
static func panner(s: float) -> float:
	return 0.8 * clampf(s, -1.0, 1.0)


func _nachts() -> bool:
	var l = _held.get_parent().get("licht") if _held != null and is_instance_valid(_held) and _held.get_parent() != null else null
	return l != null and float(l.get("nacht")) > NACHT_AB


func _wildlaute(ruhig: bool) -> void:
	if wild == "NONE":
		return
	var nachts := _nachts() if ruhig else false
	if _ort_ms >= _leben_ms:
		if ruhig:
			var id := leben(wild, nachts, false, _zufall)     # Regen gibt es in Godot noch nicht
			if id != "":
				effekt(id, LEBEN)
		_leben_ms = _ort_ms + LEBEN_MS[0] + _zufall.randf_range(0.0, LEBEN_MS[1])
	if _ort_ms >= _fern_ms:
		var id := fern(wild)
		if ruhig and id != "":
			fern_effekt(id, fern_pegel(id, _zufall), seite(_zufall))
		_fern_ms = _ort_ms + fern_pause_ms(wild, nachts, _zufall)


## GameViewModel.playFrom: ein Laut von einer Seite
func fern_effekt(id: String, pegel: float, s: float) -> void:
	if not effekte_an or _fern == null:
		return
	pegel *= schleier_pegel()
	var takes: Array = liste.get("sfx", []).filter(func(n): return String(n).begins_with(id + "_") and String(n).substr(id.length() + 1).is_valid_int())
	if pegel <= 0.0 or takes.is_empty():
		return
	var st: AudioStream = _strom("sfx/" + String(takes[_zufall.randi_range(0, takes.size() - 1)]))
	if st == null:
		return
	var b := AudioServer.get_bus_index("Fern")
	if b >= 0 and AudioServer.get_bus_effect_count(b) > 0:
		(AudioServer.get_bus_effect(b, 0) as AudioEffectPanner).pan = panner(s)
	_fern.stop()
	_fern.stream = st
	_fern.volume_db = linear_to_db(maxf(pegel, 0.0001))
	_fern.play()


# ---------------------------------------------------------------- Dorftiere (HenSound.kt, 83c; 401)

# 401 (Chef 28.10., 22:0x: „die Geräusche für alle Tiere, die jetzt hier rumstehen, auch mindestens 3“): man hört nur, was ein Tier
# gerade tut, und nur in seiner Nähe (HenSound: bis 6 Kacheln, ab 1,5 am lautesten); jedes Tier für sich, nie im Takt.
# Beginnt es zu fressen: das Huhn gluckst oft und scharrt dabei, die Ziege rupft Gras, das Kaninchen knabbert. Von selbst ab und
# zu: die Ziege meckert, das Huhn gluckst. Kommt der Held heran: das Huhn gackert mit Flügelschlag, die Ziege meckert (das Klopfen
# des Kaninchens ist raus, Chef 29.10., 10:52: „nicht tauglich“). Laute aus tools/klang/huehner.py und dorftiere.py.
const TIER_WEIT := 6.0                   # HenSound.FAR (Kacheln)
const TIER_NAH := 1.5                    # HenSound.NEAR
## je Tier und Anlass: [Klang, Pegel ganz nah]; „fressen“ mit dem Abstand der Wiederholung (ms), „ruf“ mit der Pause (ms)
const TIERLAUT := {
	# 591 (Chef 08.11., 15:41, t269.10: „Huhn gackert kaum, Flattern kaum hörbar … tschack, tschack, tschack … weg“; „Kaninchen nicht
	# hörbar“): beim Losrennen gackert das Huhn laut und schlaegt dreimal mit den Fluegeln, das zweite Gackern spaeter; das Kaninchen
	# huscht in vier schnellen Schritten durchs Gras. Die Pegel des alten Spiels (HenSound ALARM_MAX 0,45, FLAP_MAX 0,3) gingen im Godot-
	# Dorf unter Musik und Umgebung unter. „held“: [Klang, Pegel ganz nah, Tempo, nach s]
	"huhn": {"fressen": ["hen_scratch", 0.12, 700.0, 1600.0], "anfang": ["hen_cluck", 0.3], "ruf": ["hen_cluck", 0.25, 15000.0, 35000.0],
		"held": [["hen_alarm", 0.85], ["hen_flap", 0.75, 1.0, 0.05], ["hen_flap", 0.7, 1.08, 0.3], ["hen_flap", 0.6, 0.95, 0.55], ["hen_alarm", 0.6, 1.05, 0.9]]},
	"ziege": {"fressen": ["goat_graze", 0.25, 2500.0, 4500.0], "ruf": ["goat_bleat", 0.4, 20000.0, 45000.0], "held": [["goat_bleat", 0.5]]},
	# 591: das fliehende Kaninchen huscht hoerbar durchs Gras (Schritt im Gras, hoch); Klopfen bleibt raus
	"kaninchen": {"fressen": ["rabbit_munch", 0.2, 2500.0, 4000.0],
		"held": [["step_grass", 0.7, 1.7], ["step_grass", 0.65, 1.9, 0.12], ["step_grass", 0.6, 1.8, 0.24], ["step_grass", 0.5, 2.0, 0.36]]},
}
var _tiere := {}                         # Tier (Knoten) -> {pause, nah, fressen_ms, ruf_ms}
var _tiere_suche := 0.0


## HenSound.smooth: Pegel nach Abstand [d] (Kacheln), weich von TIER_WEIT bis TIER_NAH
static func tier_pegel(d: float, hoechst: float) -> float:
	if d >= TIER_WEIT:
		return 0.0
	var t := clampf((TIER_WEIT - d) / (TIER_WEIT - TIER_NAH), 0.0, 1.0)
	return hoechst * t * t * (3.0 - 2.0 * t)


func _tierlaute(dt_ms: float) -> void:
	_tiere_suche -= dt_ms
	if _tiere_suche <= 0.0 or _tiere.keys().any(func(n): return not is_instance_valid(n)):
		_tiere_suche = 2000.0
		var neu := {}
		for n in _held.get_parent().find_children("*", "Node3D", true, false):
			var d = n.get("daten")
			if d is Dictionary and TIERLAUT.has(String(d.get("tier", ""))):
				neu[n] = _tiere.get(n, {"pause": String(n.get("pause")), "nah": true, "fressen_ms": 0.0,
					"ruf_ms": _zufall.randf_range(3000.0, 30000.0)})
		_tiere = neu
	for n in _tiere:
		if not is_instance_valid(n) or not n.is_visible_in_tree():
			continue
		var st: Dictionary = _tiere[n]
		var art: Dictionary = TIERLAUT[String(n.daten["tier"])]
		var d: float = Vector2(n.position.x - _held.position.x, n.position.z - _held.position.z).length() / 1.16     # Karte.TS
		# 591: Huhn und Kaninchen fliehen schon vor der Nachbarkachel; der Laut kommt mit dem Losrennen (MapHen fled, HenSound)
		var nah: bool = n.nah_am_held(n.kachel) or n.get("flucht") == true   # 603: Probetier ohne flucht (null)
		if nah and not st.nah:
			for l in art.held:
				var nach: float = float(l[3]) if l.size() > 3 else 0.0
				if nach > 0.0: get_tree().create_timer(nach).timeout.connect(effekt.bind(l[0], tier_pegel(d, l[1]), float(l[2])))
				else: effekt(l[0], tier_pegel(d, l[1]), float(l[2]) if l.size() > 2 else 1.0)
		st.nah = nah
		var pause := String(n.pause)
		if pause != st.pause:
			st.pause = pause
			if pause == "Fressen":
				st.fressen_ms = 300.0
				if art.has("anfang") and _zufall.randf() < 0.5:     # HenSound: jeder zweite Anfang mit Glucksen
					effekt(art.anfang[0], tier_pegel(d, art.anfang[1]))
		if pause == "Fressen" and n.get("ziel") is Vector2i and n.ziel.x < 0:
			st.fressen_ms -= dt_ms
			if st.fressen_ms <= 0.0:
				var f: Array = art.fressen
				effekt(f[0], tier_pegel(d, f[1]))
				st.fressen_ms = _zufall.randf_range(f[2], f[3])
		if art.has("ruf"):
			st.ruf_ms -= dt_ms
			if st.ruf_ms <= 0.0:
				var r: Array = art.ruf
				if pause != "Fressen" or r[0] != art.get("anfang", [""])[0]:
					effekt(r[0], tier_pegel(d, r[1]))
				st.ruf_ms = _zufall.randf_range(r[2], r[3])


## Eine Schleife [klang] zum Pegel [soll] führen; sie beginnt mit einer zufälligen Aufnahme und bleibt bei ihr, bis sie
## verklungen ist (18k); gibt den Pegel zurück
func _schleife(schluessel: String, klang: String, soll: float, hoechst: float, dt_ms: float, fade_ms: float) -> float:
	var s = _schleifen.get(schluessel)
	var v := naeher(float(s.v) if s != null else 0.0, soll, hoechst, dt_ms, fade_ms)
	if not effekte_an:
		v = 0.0
	if v > 0.0 and s == null:
		var takes: Array = liste.get("sfx", []).filter(func(n): return String(n).begins_with(klang + "_") and String(n).substr(klang.length() + 1).is_valid_int())
		if takes.is_empty():
			return 0.0
		var st = _strom("sfx/" + String(takes[_zufall.randi_range(0, takes.size() - 1)]))
		if not st is AudioStreamOggVorbis:
			return 0.0
		st = st.duplicate()     # die geladene Aufnahme spielt anderswo einmal, hier in Schleife
		st.loop = true
		var p := AudioStreamPlayer.new()
		p.bus = "Effekte"
		p.stream = st
		p.volume_db = linear_to_db(maxf(v * schleier_pegel(), 0.0001))     # SfxPlayer.loop: auch die Schleifen hinter der Blende
		add_child(p)
		p.play()
		_schleifen[schluessel] = {"p": p, "v": v}
	elif s != null and v <= 0.0:
		s.p.queue_free()
		_schleifen.erase(schluessel)
	elif s != null:
		s.p.volume_db = linear_to_db(maxf(v * schleier_pegel(), 0.0001))
		s.v = v
	return v


## Ambience.nearestFire: Abstand in Kacheln zum nächsten Lagerfeuer oder Herd auf offenem Weg, um Wände herum, nie hindurch;
## schräg nur, wo keine Seite Wand ist; drinnen zählt der Weg kürzer; null, wenn keins in Reichweite
static func feuer_weit(k, von: Vector2i):
	var tragen := DRINNEN_TRAGEN if String(k.daten.get("art", "")) == "INTERIOR" else 1.0
	var fern := FEUER_WEIT * tragen
	var r := int(fern) + 1
	var offen := func(q: Vector2i) -> bool:
		return q.x >= 0 and q.y >= 0 and q.x < k.breite and q.y < k.hoehe and not _kachel(k, q) in WAENDE
	var dist := {von: 0.0}
	var offen_liste := [von]
	while not offen_liste.is_empty():
		var bi := 0
		for i in offen_liste.size():
			if dist[offen_liste[i]] < dist[offen_liste[bi]]:
				bi = i
		var c: Vector2i = offen_liste[bi]
		offen_liste.remove_at(bi)
		var d: float = dist[c]
		if d >= fern:
			continue
		if _kachel(k, c) in ["CAMPFIRE", "HEARTH"]:
			return d / tragen
		# das Feuer steht dem Gehen im Weg, nicht dem Klang
		for dy in [-1, 0, 1]:
			for dx in [-1, 0, 1]:
				if dx == 0 and dy == 0:
					continue
				var n := c + Vector2i(dx, dy)
				if absi(n.x - von.x) > r or absi(n.y - von.y) > r or not offen.call(n):
					continue
				if dx != 0 and dy != 0 and (not offen.call(Vector2i(c.x + dx, c.y)) or not offen.call(Vector2i(c.x, c.y + dy))):
					continue
				var nd := d + (sqrt(2.0) if dx != 0 and dy != 0 else 1.0)
				if nd < float(dist.get(n, INF)):
					if not dist.has(n):
						offen_liste.append(n)
					dist[n] = nd
	return null


static func _kachel(k, t: Vector2i) -> String:
	return String(k.kacheln.get(k.zeichen(t), {}).get("name", ""))


## RiverSound.running: Wasser, das mit dem Wasser am Kartenrand zusammenhängt (ein Teich liegt still und hat seine Frösche)
func fluss(k) -> Array:
	if _fluss.has(k.id):
		return _fluss[k.id]
	var gesehen := {}
	var schlange := []
	for y in k.hoehe:
		for x in k.breite:
			var q := Vector2i(x, y)
			if (x == 0 or y == 0 or x == k.breite - 1 or y == k.hoehe - 1) and _kachel(k, q) == "WATER":
				gesehen[q] = true
				schlange.append(q)
	var aus := []
	var i := 0
	while i < schlange.size():
		var q: Vector2i = schlange[i]
		i += 1
		aus.append(q)
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = q + d
			if n.x >= 0 and n.y >= 0 and n.x < k.breite and n.y < k.hoehe and not gesehen.has(n) and _kachel(k, n) == "WATER":
				gesehen[n] = true
				schlange.append(n)
	_fluss[k.id] = aus
	return aus


## RiverSound.nearest: Abstand zum nächsten fließenden Wasser, null jenseits von FLUSS_WEIT
func fluss_weit(k, t: Vector2i):
	var best := INF
	for q in fluss(k):
		best = minf(best, Vector2(q - t).length())
	return best if best < FLUSS_WEIT else null


## PlaceSound.events: [Klang, Gewicht]; Husten nur, wo außer der Wirtin ein Gast ist
static func ereignisse(ortsart_: String, anwesend: Array) -> Array:
	var aus := []
	if ortsart_ == "TAVERN" and anwesend.any(func(a): return a != WIRT):
		aus.append(["cough", 1])
	if ortsart_ in ["TAVERN", "ROOM"]:
		aus.append(["creak", 2])
	return aus


## PlaceSound.pick: nach Gewicht, nie zweimal derselbe, wenn es eine Wahl gibt
static func waehle_ereignis(e: Array, letztes: String, zufall: RandomNumberGenerator) -> String:
	var pool := e.filter(func(x): return x[0] != letztes)
	if pool.is_empty():
		pool = e
	var summe := 0
	for x in pool:
		summe += int(x[1])
	if summe <= 0:
		return ""
	var r := zufall.randi_range(0, summe - 1)
	for x in pool:
		if r < int(x[1]):
			return String(x[0])
		r -= int(x[1])
	return String(pool[-1][0])


## PlaceSound.present: das Aussehen der Leute, die auf der Karte zu sehen sind
func _anwesend() -> Array:
	var aus := []
	if _held == null or _held.get_parent() == null:
		return aus
	for n in _held.get_parent().find_children("*", "Node3D", true, false):
		var d = n.get("daten")
		if d is Dictionary and d.has("aussehen") and n.is_visible_in_tree():
			aus.append(String(d["aussehen"]))
	return aus


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
	_speichere()


## 489 (Chef 03.11., 07:07): Schalter im Hauptmenü wie alt (GameViewModel toggleMusic, toggleSfx): "music" oder "fx" stumm oder
## wieder an, die Regler bleiben. Musik an: läuft noch ein Stück (stumm), klingt es weiter, sonst beginnt die Szene neu
func schalte(art: String) -> void:
	if art == "music":
		musik_an = not musik_an
		if musik_an and szene != "" and not _spieler.any(func(p): return p.playing):
			var sz := szene
			szene = ""
			spiele_szene(sz)
	else:
		effekte_an = not effekte_an
	_mische()
	_speichere()


func _speichere() -> void:
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
