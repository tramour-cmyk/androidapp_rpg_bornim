# 348.7: eine Figur am Kampfort: Modell (Wolf aus tools/blender348/wolf.py, Held aus rig.py), Platz, Bewegungen zu den
# Meldungen: Stehen, Hocke beim angesagten Sprung, Sprung oder Biss zum Ziel und zurück, Treffer, Ausweichen, Sturz, Tod.
extends Node3D

const Mars = preload("res://regeln/mars.gd")
# Schlagzeiten (SkirmishScreen.kt): Biss eines Tiers mit Anlauf 1,0 s, Hieb 0,8 s, Stich 0,6 s
const BEAST_LUNGE_MS := 1000
const BLOW_MS := 800
const STAB_MS := 600
const GLIDE_S := 0.4
const HERO_R := 0.3          # 348.7: halbe Breite eines Menschen am Boden
const HERO_REACH := 0.75     # 348.7: Arm und Klinge vor dem eigenen Rand bis zum Rand des Ziels
## 348.7 (Helfer Lauf 126: drehte 110 ms nach dem Aufschlag um, Rückweg zischte durch): Halt bis 0,68 des Hiebs wie im alten
## MARS (SkirmishScreen.kt STEP_HOLD, STEP_BACK), dann rückwärts zurück, das Gesicht zum Gegner
const STEP_HOLD := 0.42
const STEP_BACK := 0.68
## Helfer Runde 2 (Rückweg 0,5 s wirkte schnell: bis 6,3 m, 12 m/s): rückwärts 7,5 m/s, 0,5 bis 0,9 s (Runde 3: 1,6 m/s
## brauchte 3,9 s, er „blieb stehen“); dauert er über SAY_MS hinaus, wartet die nächste Meldung (busy_ms)
const HERO_BACK_S := 0.5
const HERO_BACK_MAX_S := 0.9
const HERO_BACK_MPS := 7.5
## Gehen der Heldin (held.glb) bei Tempo 1 in m/s und wie schnell es rückwärts höchstens läuft (sonst trippelt sie)
const WALK_MPS := 1.4
const WALK_MAX := 2.5
## Wie lange der letzte Schlag samt Rückweg dauert (ms), kampfort.gd wartet darauf
var busy_ms := 0
var anlauf_ms := 0          # 399.2: so lange läuft es beim letzten Biss an, bevor es zubeißt (kampfort.gd: wer Platz macht, wartet)
const FALL_MS := 900
const FADE_MS := 600
const WOLF_COATS := ["grau", "dunkel", "rost", "asche"]
## 348.9 Entwurf: ERSATZ=boar zeigt das Wolfsrudel mit einem anderen Vierbeiner (Modell und Größe, Regeln bleiben die des Wolfs)
## 348.12f: ERSATZ=kaufwolf, der gekaufte Wolf (kaufwolf.py, Janpec) mit unseren vier Fellen, Probe neben unserem Wolf
const ERSATZ_FELLE := {"boar": ["dunkel", "grau", "rost"], "giant_rat": ["braun", "grau", "schwarz"], "giant_bat": ["braun", "schwarz", "grau"],
		"kaufwolf": ["grau", "dunkel", "rost", "asche"]}
## Bewegungen eines Vierbeiners, die beim Wolf anders heißen (wildschwein.py: Hauerstoß statt Biss, Rammen statt Sprung)
## Kopfhöhe (Ohrspitzen) und Bodenschatten (Breite, Länge, Mitte vor dem Ursprung) des Ersatzes in Modellmetern (Ratte Runde 2:
## Balken 200 px über der Ratte, Schatten größer als das Tier)
const ERSATZ_KOPF := {"giant_rat": 0.4, "giant_bat": 0.98, "kaufwolf": 1.06, "kauf_egel": 0.45, "kauf_schnecke": 0.85}     # Kaufwolf: Ohren 1,175 m (unser Wolf 1,24 m bei 1,12)
const ERSATZ_SCHATTEN := {"giant_rat": [0.3, 0.85, -0.08], "giant_bat": [0.9, 0.5, -0.04]}
## Ersatz ohne Umgebungsvariable (Prüf-APK: Probekampf „Ratten“ setzt giant_rat); ERSATZ geht vor
static var ersatz_art := ""
static func ersatz() -> String:
	return OS.get_environment("ERSATZ") if OS.has_environment("ERSATZ") else ersatz_art
## 494 (Wochenziel 03.11. Reihe 3): Vierbeiner mit eigenen Regeln (tabellen.json, MARS allgemein), im Bild wie der Wolf: Körper,
## Schatten, Kopfhöhe, Größe aus dem Kaufmodell (ersatz_art „kauf_<tier>“, aufruf.gd)
const VIERBEINER := ["wolf", "boar", "giant_centipede", "stirge", "ochre_jelly", "giant_rat", "giant_bat"]     # Hundertfüßer, Riesenegel, Säureschnecke (494): langer Körper am Boden wie ein Vierbeiner; Ratte, Fledermaus mit eigenen Regeln wie bisher als Ersatz des Wolfs
static func vier(fi) -> bool:
	return fi != null and fi.monster != null and Mars.koerper_of(fi.monster) in VIERBEINER     # 577: nach dem Körper
## 553 (Chef 04.11., 00:26, Build 249: „Was ist das für ein graues Tier??????“ im Flüsterwald): ersatz_art ist eine für alle
## Figuren; jeder Streuner der Karte und jeder Kampfbeginn setzt sie neu (aufruf.gd gegner). Die Figur las sie laufend, also nahm
## eine Kartenratte nach dem nächsten Wolf dessen Maße (Wenden, Absetzen, Kopf) und ein Wolf nach der nächsten Ratte deren
## doppelte Größe. Jetzt merkt sich jede Figur beim Aufbau, welches Tier sie ist, und ihren Maßstab.
var _art_fest := ""
var _art_da := false
func _mein_ersatz() -> String:
	if not _art_da:
		_art_fest = ersatz()
		_art_da = true
	return _art_fest
## 348.7 Grimmzahn: im Probekampf „Grimmzahn“ trägt der Wolf „grimm“ dessen Modell (Regeln noch die des Wolfs)
const GRIMM := "grimm"
## Größe im Modell gegen den Wolf (Knotenmaßstab der .glb, wolf.py ART=dire_wolf): Schatten, Kopf, Mitte wachsen mit, das Modell nicht noch einmal
const ART_GROESSE := {"dire_wolf": 1.75, "giant_rat": 0.6 / 0.3}
## 348.7: die drei Goblins aus goblin.py (Krummsäbel und Schild mit Wams und Fell, Handbeil mit Kappe, zwei Klingen mit Helm)
const GOBLIN_KITS := ["leder", "kappe", "helm"]
## 348.7 Goblin-Späher (goblin.py ART=goblin_archer): Wams und Kapuze, Kappe und Fell, Wams und Fell; Kurzbogen links
const SCOUT_KITS := ["kapuze", "kappe", "fell"]
## 348.7 Goblin-Schamane (goblin.py ART=goblin_shaman): rußschwarze Robe, Fellumhang, beides; Stab mit Schädel links (Runde 4, Chef 26.10.: Hände getauscht).
## MARS hat noch keinen Schamanen: die Probe „Schamanen“ zeigt Goblins mit seinem Aussehen (ersatz_art), Regeln des Goblins
const SHAMAN := "goblin_shaman"
const SHAMAN_KITS := ["robe", "fell", "beides"]
## 348.7 Kobold (goblin.py ART=kobold): Speer und Kappe, Speer und Schild, Dolch und Fell; MARS hat noch keinen Kobold:
## die Probe „Kobolde“ zeigt Goblins mit seinem Aussehen (ersatz_art), Regeln des Goblins
const KOBOLD := "kobold"
const KOBOLD_KITS := ["kappe", "schild", "fell"]
## 348.12 Grak (goblin.py ART=hobgoblin_captain, CC0-Gerüst): ein Kit, Großaxt in beiden Händen (waffen.py greataxe-grak, für
## ihn gebaut, Größe 1); in Stehen der Stiel steil vor dem Körper, der Kopf der Axt über der rechten Schulter (ual_lauer.py GRAK_HALT)
const GRAK_KITS := ["hauptmann"]
## 494 Krogg (krogg_gestalt.py, Superheld mit gekauftem Bärenkopf): ein Kit, Morgenstern in der rechten Faust im Modell (Knochen „waffe“)
const KROGG_KITS := ["krogg"]
## 506 Skelett (kaufskelett.py, gekaufter Skelettritter): drei Kits wie MonsterKit.kt skeleton, Waffen und Helm im Modell
const SKELETT := "skeleton"
const SKELETT_KITS := ["schwert", "schild", "speer"]
## 506 Wiedergänger (kaufuntoter.py, gekaufter Evil Undead; ersetzt den Zombie, Regeln des Zombies): drei Kits wie MonsterKit.kt
## zombie (Lumpen, Leichenhemd, rostiges Kettenhemd), Krallen statt Waffe. Der Grabhund (kaufgrabhund.py, ersetzt den Ghul) hat
## eigene Häute in ghoul-info.json wie die Riesenspinne (eigene_haut)
const WIEDERGAENGER := "zombie"
const WIEDERGAENGER_KITS := ["lumpen", "hemd", "kette"]
## Zweibeiner (Gerüst mit Waffen und Kits in <art>-info.json): Goblin, Späher, Grak, Krogg, Skelett, Wiedergänger
const ZWEI := [Mars.CALLED, Mars.SCOUT, Mars.GRAK, Mars.KROGG, SKELETT, WIEDERGAENGER]
## Kurzbogen wie Dress.bow: 0,58 der Größe des Schützen (waffen.py baut ihn 101 cm, für den Menschen)
## Späher Runde 2 (Prüfer 1: „von der Schulter bis auf Fußhöhe, für einen Kurzbogen groß“): 0,48
const GOB_BOGEN := 0.48 / 1.01
## Runde 3: Waffen und Schild der Goblins gegen die Menschenwaffen (waffen.py) verkleinert
const GOB_WAFFE := 0.8
# 348.13a Probe (Tom: Goblins aufhellen, Prüfer r9: hinterer Goblin hebt sich vom Weg kaum ab): Mindesthelligkeit der Goblins im
# Schatten. Gemessen im selben Augenblick (FILL_REIHE): der Goblin ist dunkler als der Weg, 0,3 verringert den Abstand von 42 auf
# 38, 0,45 auf 36 (von 255) und hebt ihn damit weniger ab; Vorgabe darum 0, Probe GOB_FILL=<Wert>
static var GOB_FILL := float(OS.get_environment("GOB_FILL")) if OS.has_environment("GOB_FILL") else 0.0
const GOB_SCHILD := 0.65
const ALIAS := {"Biss": "Hauer", "Sprung": "Ansturm", "Lefzen": "Schnauben", "Heulen": "Drohen"}
# Chef 25.10., 08:57 (2): halb seitlich (−35°) sah er aus, als wolle er weglaufen; jetzt fast zum Gegner
const WOLF_TURN := -12.0

var fighter
var kampfort
var model: Node3D
var anim: AnimationPlayer
var home := Vector3.ZERO
var pouncing := false
var dead_at := -1
var down := false
var mats: Array = []
var tween: Tween
var gang := ""        # 399.2 umweg_399: in welchem Teil des Schlags (hin, zurück, heim)
var aim = null          # Figur, die das Tier laut Ansage angreift; Kopf und Rumpf zeigen dorthin
var neck = null         # kopfdreh.gd am Skelett
var letzter_sprung := false     # 439: war der letzte Angriff ein Sprung (kampfort.gd: der Getroffene fällt beim Aufprall)
var sprung_bereit := false     # 439: angesagter Sprung, die Ansage ist mit „Anspringen!“ schon weg
var sturz_vorweg := false       # 439: schon beim Sprung gefallen, die Meldung „wirft sich auf“ zeigt nur den Text
var tritt = null        # 438: trittfest.gd am Skelett (Tiere mit Wurzelweg): Pfoten im Gehen und Rennen fest am Boden
var halt = null         # pfotenhalt.gd am Skelett (Tiere mit Wurzelweg): Pfoten bleiben beim Drehen auf der Stelle am Boden
var fidget_at := 0      # Chef 08:57 (8): in Ruhe ab und zu Lefzen zeigen oder scharren (ms)
var paws: Array = []    # Runde 14: Kontaktschatten je Pfote [Knochen, Länge, Fleck]
var hurt_at := -1.0      # 249: seit wann (kampfort.clock_ms) der Getroffene zittert
var model_rest := Vector3.ZERO
var gob_h := 0.0        # Goblin: Scheitel in Modellmetern (goblin-info.json), für Namen und Ansage (head())
## 348.12f (Chef 27.10., 18:01, Archiv: „Bewegungen mit Ortswechsel im Kampfort, nicht auf der Stelle“): Wurzelweg je Bewegung
## aus <art>-info.json „weg“ (kaufratte.py, aus den _RM-Dateien der Quelle), je Bild [x, z] in Modellmetern, +Z vorn. Wer ihn hat,
## geht oder rennt beim Platzwechsel, weicht mit dem Weg der Quelle aus, läuft zum Biss bis vors Ziel und springt es an.
var weg := {}
var weg_fps := 30.0
## ab dieser Strecke (m) rennt es statt zu gehen
const RUN_FROM := 1.2
## Je Bewegung (gemessen mit probe.gd SCHAU=ort SCHAU_MESS=1, Lauf 1): Abstand Ursprung–Rand des Ziels beim Biss (Modellmeter;
## Schnauze dann 0,05–0,1 m im Rand), Zeitpunkt des Zubeißens (s, Schnauze am tiefsten) und Drehung des Körpers, damit die
## Schnauze dann aufs Ziel zeigt (Grad, + links): in Ruhe zeigt sie 8° rechts vorbei (Kopf 0,11 m rechts der Achse), im Zubeißen
## schwenkt der Kopf der Quelle 15–21° nach links
## Prüfer Lauf 148: Nase 0,05–0,09 m (Sprungbiss 0,09–0,12 m) im Rand, Kopf am Schirm jenseits der Heldin: Abstand +0,06/+0,09 m
const BITE := {"Biss": [0.78, 0.5, -7.0], "Sprungbiss": [0.81, 0.6, -11.0]}
## dasselbe je Modell aus <art>-info.json „biss“ (kaufwolf.py misst es beim Bau), sonst BITE
var bite := BITE
## 348.12f (Chef 28.10., 08:09: „Schnauze näher“; Prüfer: Ratte und Kaufwolf beißen 14–16 cm vor der Heldin ins Leere): so viel
## näher (m, Welt) tritt das Tier zum Biss heran. Chef 10:36 „b“: mit +0,10 steckte die Nase 11–13 cm im Rand (Ortmess r8), der Kopf
## verschwand hinter dem Helden; jetzt endet sie am Rand (Ortmess „Nase-Rand“ etwa 0)
static var PFOTEN_MESS := OS.get_environment("PFOTEN_MESS") != ""
const ZUNGE := ["kauf_schnecke"]     # 595: trifft mit der Zunge über Schild und Klinge hinweg den Leib (vorne ohne Waffen)
const SCHNAUZE_NAEHER := {"giant_rat": -0.02, "kaufwolf": -0.08}
## 348.12f (Chef 10:36: Schatten der Ratte „wie schwarze Scheiben unter den Füßen“, bei den Wölfen passt er): Pfotenfleck im Verhältnis
## zum Tier wie beim Wolf. Er wuchs mit _scale(), bei der Ratte (×2,0) 0,52 × 0,64 m je Pfote, beim Wolf (×1,32) 0,34 × 0,42 m; Kopfhöhe
## Ratte 0,8 m, Wolf 1,64 m, also ein Drittel
const PFOTENFLECK := {"giant_rat": 0.33}
## 387 Runde 2: so viel schneller spielt das Modell eine Bewegung (<art>-info.json „tempo“; Hundertfüßer: Gehen kaum sichtbar), der
## Wurzelweg gilt für Tempo 1; Maße am Boden („breite_m“, „laenge_m“) für Bodenschatten und Umriss der Kauftiere
var tempo := {}
var mass := {}
## 348.12 nachbessern (Chef 28.10., 15:23, Archiv: „Der Axthieb trifft auch nicht“): Aufschlag des Hiebs eines Zweibeiners aus
## <art>-info.json „hieb“ (grak_gestalt.py): Abstand Ursprung–Schneide (Modellmeter), Zeit (s), Drehung (Grad, + links), Höhe (m)
var hieb := []
## so weit (m) liegt die Schneide beim Aufschlag im Rand des Ziels
const AXT_IM_RAND := 0.12


func setup(f, k) -> void:
	fighter = f
	kampfort = k
	model = _load_model()
	add_child(model)
	model.scale = Vector3.ONE * _scale() / ART_GROESSE.get(art(), 1.0)
	if fighter.monster == null and kauf:
		_arm_kauf()
	elif fighter.monster == null:
		_arm()
	elif Mars.koerper_of(fighter.monster) in ZWEI:
		_arm_goblin()
	if fighter.monster != null:
		var sk: Skeleton3D = _find(model, "Skeleton3D")
		if sk:
			neck = preload("res://kampf/kopfdreh.gd").new()
			sk.add_child(neck)
	weg = _weg()
	var skw: Skeleton3D = _find(model, "Skeleton3D") if weg.has("Gehen") else null
	if skw and skw.find_bone("vpfoteL") >= 0 and skw.find_bone("hpfoteR") >= 0:     # Pfotenhalt nur mit vier Pfoten
		halt = preload("res://kampf/pfotenhalt.gd").new()
		halt.figur = self
		skw.add_child(halt)
		tritt = preload("res://kampf/trittfest.gd").new()     # 438: im Gehen und Rennen bleiben aufgesetzte Pfoten fest
		tritt.figur = self
		skw.add_child(tritt)
	_atem_an()
	_face()
	_idle()
	_ground_shadow()
	if art() == "dire_wolf":     # 348.7 Runde 7: Grimmzahns Augen glühen (Prüfer Runde 6: „flache rote Scheibe“)
		for m in mats:
			m.set_shader_parameter("glut", 2.5)
	# Prüfschalter GLUEH=1: Gegner leuchten, damit der Prüflauf ihre Bildpunkte vom Hintergrund trennt (Helligkeit messen)
	if OS.has_environment("GLUEH") and fighter.monster != null:
		for m in mats:
			m.set_shader_parameter("glow", 1.0)


## Weicher Bodenschatten unter der Figur wie im alten Kampf (Prüfer Stand 9: Wölfe schweben); der Schlagschatten der hohen
## Sonne fällt fast ganz unter den Körper. Ohne Tiefe, darum ohne Tusche; folgt der Figur (Kind), bleibt beim Sprung am Boden.
static var shadow_shader: Shader
var _schatten_grund := Vector2.ZERO

func _ground_shadow() -> void:
	if shadow_shader == null:
		shadow_shader = Shader.new()
		shadow_shader.code = """shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;
uniform float dichte = 0.78;
void fragment() {
	float r = length(UV - 0.5) * 2.0;
	ALBEDO = vec3(0.02, 0.03, 0.01);
	ALPHA = dichte * (1.0 - smoothstep(0.45, 1.0, r));     // Prüfer: im alten Bild deutlich dunkler
}"""
	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	var wolf: bool = vier(fighter)
	# Wolf: Rumpf 1,1 m lang, 0,4 m breit (mal Größe); Mensch: 0,7 m rund
	# Runde 15 (Prüfer Runde 14: Pfotenschatten „unsichtbar im Rumpfschatten“): schmaler (0,7 statt 1,0), die Pfoten stehen am weichen Rand
	pm.size = Vector2(0.7, 1.5) * _scale() if wolf else Vector2(0.95, 0.95)
	var vor := 0.15
	if wolf and ERSATZ_SCHATTEN.has(_mein_ersatz()):
		var es: Array = ERSATZ_SCHATTEN[_mein_ersatz()]
		pm.size = Vector2(es[0], es[1]) * _scale(); vor = es[2]
	elif (wolf or eigene_haut(fighter)) and mass.has("laenge_m"):     # 494: auch die gekaufte Spinne (vorher 0,95 rund unter 1,69 m Beinen); 387 Runde 2 (Prüfer: Schatten in Wolfsgröße, bei Huhn und Kaninchen doppelt so breit): nach dem Kauftier
		pm.size = Vector2(mass.get("breite_m", 0.4) * 1.3, mass.laenge_m * 0.9) * _scale(); vor = 0.0
	# 506 (Helfer 08.11., 12:55, A4 „Schatten als Scheibe“): unter dem Skelett deckt kein Fleisch den runden Schatten, zwischen den
	# dünnen Knochen lag eine dunkle Scheibe; schmaler und heller, so breit wie das Becken (Kauf 0,52 m breit mit Armen)
	var dunkel := 0.78
	if fighter != null and fighter.monster != null and Mars.koerper_of(fighter.monster) == SKELETT:
		pm.size = Vector2(0.6, 0.6); dunkel = 0.5
	mi.mesh = pm
	var m := ShaderMaterial.new()
	m.shader = shadow_shader
	m.set_shader_parameter("dichte", dunkel)
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = Vector3(0, 0.02, vor * _scale() if wolf else 0.0)     # Rumpfmitte des Wolfs liegt 0,15 m vor dem Ursprung
	mi.name = "Bodenschatten"
	_schatten_grund = pm.size     # 709: Umriss vor der Verbreiterung um die Pfoten (_paws_in_blob)
	add_child(mi)
	if wolf and OS.get_environment("PFOTENSCHATTEN") != "0":     # Prüflauf: PFOTENSCHATTEN=0 ohne
		_paw_shadows()


## Runde 14 (Prüfer Runde 13: „kein Kontaktschatten unter den Pfoten“, der weiche Fleck liegt nur unter dem Rumpf): ein kleiner
## dunkler Fleck unter jeder Pfote, folgt dem Knochen und blasst aus, wenn die Pfote sich hebt (Scharren, Sprung).
const PAW_BONES := {"vpfoteL": 0.135, "vpfoteR": 0.135, "hpfoteL": 0.19, "hpfoteR": 0.19}

func _paw_shadows() -> void:
	var sk: Skeleton3D = _find(model, "Skeleton3D")
	if sk == null:
		return
	for b in PAW_BONES:
		var i := sk.find_bone(b)
		if i < 0:
			continue
		var mi := MeshInstance3D.new()
		var pm := PlaneMesh.new()
		pm.size = Vector2(0.26, 0.32) * _scale() * float(PFOTENFLECK.get(art(), 1.0))     # Runde 15: der Fleck direkt unter der Pfote ist von oben von ihr verdeckt; als Rand um sie herum sichtbar (0,11 × 0,14 rot gemessen: etwa 115 Bildpunkte je Pfote)
		mi.mesh = pm
		var m := ShaderMaterial.new()
		m.shader = shadow_shader
		m.set_shader_parameter("dichte", 0.0)
		mi.material_override = m
		if OS.get_environment("PFOTENSCHATTEN") == "rot":     # Prüflauf: Pfotenschatten rot
			var rot := StandardMaterial3D.new(); rot.albedo_color = Color.RED; rot.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			mi.material_override = rot
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.top_level = true
		mi.name = "Pfotenschatten"
		mi.set_meta("pfotenschatten", true)     # 709: kein Teil des Umrisses (_footprint)
		add_child(mi)
		paws.append([sk, i, PAW_BONES[b], mi])


func _paw_shadow_update() -> void:
	var erstes: bool = not paws.is_empty() and paws[0].size() < 5
	for pw in paws:
		var sk: Skeleton3D = pw[0]
		var g: Transform3D = sk.global_transform * sk.get_bone_global_pose(pw[1])
		if halt and halt.wirkt and halt.ort.has(sk.get_bone_name(pw[1])):     # r4: gehaltene Pfote (Ort aus dem letzten Bild)
			g.origin = halt.ort[sk.get_bone_name(pw[1])]
		var tip: Vector3 = g.origin + g.basis.y.normalized() * pw[2] * _scale()
		# 348.12f r7 (Prüfer r6: Schattenscheiben lösen sich bei Sprüngen): bei der gekauften Ratte zeigt der Pfotenknochen nicht zur
		# Sohle (geschätzt vorn 0,18 m unter, hinten 0,11 m über dem Boden), der Fleck blieb dicht, wenn die Pfote 0,26 m hoch war.
		# Liegt die Schätzung im ersten Bild (Stehen) mehr als 8 cm daneben (Wolf 4 cm), zählt für diese Pfote der Knochenursprung über seiner
		# Höhe im Stehen
		if pw.size() < 5:
			var h0: float = tip.y - global_position.y
			pw.append(g.origin.y - global_position.y if absf(h0) > 0.08 else INF)
			# 348.12f r8 (Prüfer: schwarzer Fleck neben der Pfote des Kaufwolfs; 387 r5: zweite Ellipse neben dem Kaninchen): bei Janpec
			# sitzt der Pfotenknochen schon am Ballen und zeigt waagerecht nach vorn, der Fleck lag 0,18 m (vorn) und 0,25 m (hinten) vor
			# der Pfote (gemessen PFOTEN_MESS); zeigt der Knochen im Stehen fast waagerecht, liegt der Fleck unter seinem Ursprung
			if absf(g.basis.y.normalized().y) < 0.3:     # eigener Wolf 0,52 (vorn), 0,93 (hinten); Janpec 0,0–0,03
				pw[2] = 0.0
				tip = g.origin
		if pw[4] != INF:
			tip = Vector3(g.origin.x, global_position.y + g.origin.y - global_position.y - pw[4], g.origin.z)
		var h: float = tip.y - global_position.y
		if PFOTEN_MESS:     # 348.12f r8 (Prüfer: schwarzer Fleck neben einer Pfote nach der Drehung): Fleck fern vom Knochen der Pfote
			var echt: Vector3 = (sk.global_transform * sk.get_bone_global_pose(pw[1])).origin
			var fern := Vector2(tip.x - echt.x, tip.z - echt.z).length()
			if fern > 0.1 and h < 0.15:
				print("Pfotenfleck %s %s %.0f ms: %.2f m neben dem Knochen, gehalten %s, Ursprung statt Sohle %s, Fleck %s Knochen %s" % [fighter.id, sk.get_bone_name(pw[1]), kampfort.clock_ms, fern, halt != null and halt.wirkt, pw[4] != INF, tip, echt])
		var mi: MeshInstance3D = pw[3]
		mi.global_transform = Transform3D(Basis(Vector3.UP, rotation.y), Vector3(tip.x, global_position.y + 0.025, tip.z))
		mi.visible = not down and dead_at < 0
		if mi.material_override is ShaderMaterial:
			(mi.material_override as ShaderMaterial).set_shader_parameter("dichte", 0.95 * clampf(1.0 - (h - 0.03) / 0.12, 0.0, 1.0))
	if erstes:
		_paws_in_blob()


## 348.12f (Chef 10:36, Schatten der Ratte): beim Wolf stehen die Pfoten am weichen Rand des Bodenschattens (Runde 15), die Flecken
## liegen darin. Steht eine Pfote im ersten Bild weiter außen, wird der Bodenschatten so breit (lang), dass sie am Rand steht, sonst
## liegen die Flecken einzeln neben dem Körper (nur Arten in PFOTENFLECK). SCHAU_MESS=1: Maße und wohin der Schlagschatten der Sonne fällt
func _paws_in_blob() -> void:
	var sh := get_node_or_null("Bodenschatten") as MeshInstance3D
	if sh == null:
		return
	var pm := sh.mesh as PlaneMesh
	var bx := 0.0
	var bz := 0.0
	for pw in paws:
		var lp: Vector3 = to_local((pw[3] as MeshInstance3D).global_position) - sh.position
		bx = maxf(bx, absf(lp.x))
		bz = maxf(bz, absf(lp.z))
	var vorher := pm.size
	# Rand: Ellipse mit Halbachsen size/2, weicher Rand ab 45 % (Shader), die Pfote soll bei 0,8 stehen wie beim Wolf; Wölfe bleiben
	if PFOTENFLECK.has(art()):
		pm.size = Vector2(maxf(pm.size.x, bx * 2.0 / 0.8), maxf(pm.size.y, bz * 2.0 / 0.8))
	if OS.get_environment("SCHAU_MESS") != "":
		var sun: DirectionalLight3D = kampfort._sun
		var d: Vector3 = sun.global_transform.basis.z     # zur Sonne hin
		var hoch: float = ERSATZ_KOPF.get(_mein_ersatz(), 1.24) * _scale() if fighter.monster != null else 1.8
		var fall := Vector2(-d.x, -d.z).normalized() * hoch * Vector2(d.x, d.z).length() / maxf(d.y, 0.01)
		print("Schattenmess %s %s: Bodenschatten %.2f × %.2f m (vorher %.2f × %.2f), Pfote außen %.2f/%.2f m, Fleck %.2f × %.2f m, Sonne %.0f° hoch, Schlagschatten des Kopfes %.2f m nach (%.2f, %.2f)" % [
			fighter.id, art(), pm.size.x, pm.size.y, vorher.x, vorher.y, bx, bz,
			((paws[0][3] as MeshInstance3D).mesh as PlaneMesh).size.x, ((paws[0][3] as MeshInstance3D).mesh as PlaneMesh).size.y,
			rad_to_deg(asin(clampf(d.y, -1.0, 1.0))), fall.length(), fall.x, fall.y])


var _skala := -1.0
func _scale() -> float:
	if fighter.monster == null:
		return 1.0      # held.glb in Metern (Toms rig.py, 348.6, Modellregel 1)
	if _skala < 0.0:     # 553: kampfort.foe_scale liest ersatz_art; einmal beim Aufbau, solange sie noch diesem Tier gilt
		_skala = kampfort.foe_scale(fighter) * ART_GROESSE.get(art(), 1.0)
	return _skala


## Welches Tier diese Figur zeigt: Grimmzahn, sonst der Ersatz der Probe („“ = Wolf)
func art() -> String:
	if fighter.monster == null:     # 438: der Held ist kein Ersatztier (Probekampf „Ratten“: Held halb so groß, ART_GROESSE der Ratte)
		return ""
	if fighter.monster != null and fighter.id == GRIMM:
		return "dire_wolf"
	# 494 (Verdacht Jerry 17:4x, nachgestellt 18:2x): wer eigene gekaufte Häute hat und kein Vierbeiner ist (Riesenspinne), ist kein
	# Ersatz; im Probekampf „Spinne“ setzt aufruf.gd für den Wolf daneben „kaufwolf“, die Spinne las dann kaufwolf-info.json: ohne Weg
	if eigene_haut(fighter):
		return ""
	return _mein_ersatz()


func _model_path() -> String:
	if fighter.monster == null:
		return "res://kampf/daten/held.bin"
	if vier(fighter):
		if art() == "dire_wolf":     # GRIMMFELL=schimmer: die seltene Schimmervariante
			return "res://kampf/daten/dire_wolf-%s.bin" % (OS.get_environment("GRIMMFELL") if OS.has_environment("GRIMMFELL") else "schwarz")
		var n: int = _fell_nr() - 1
		var art := _mein_ersatz()
		if art.begins_with("kauf_"):     # 387: gekaufte Tiere (kauftier.py), Felle aus <art>-info.json
			var fl := _kauf_felle(art)
			if not fl.is_empty():
				return "res://kampf/daten/%s-%s.bin" % [art, fl[n % fl.size()]]
		if ERSATZ_FELLE.has(art):
			return "res://kampf/daten/%s-%s.bin" % [art, ERSATZ_FELLE[art][n % ERSATZ_FELLE[art].size()]]
		return "res://kampf/daten/wolf-%s.bin" % WOLF_COATS[n % WOLF_COATS.size()]
	if Mars.koerper_of(fighter.monster) in ZWEI:     # 348.7: Goblin, Späher je Nummer eines der drei Kits (goblin.py, MonsterKits)
		return "res://kampf/daten/%s-%s.bin" % [_gob_art(), _gob_kit()]
	# 494 Riesenspinne (kaufspinne.py): gekaufte Gegner, die keine Vierbeiner sind, haben wie die Kauftiere drei Häute in
	# <id>-info.json; je Nummer eine (drei Varianten, DESIGN-STIL „Abwechslung“)
	var felle := _kauf_felle(Mars.koerper_of(fighter.monster))
	if not felle.is_empty():
		return "res://kampf/daten/%s-%s.bin" % [Mars.koerper_of(fighter.monster), felle[(_fell_nr() - 1) % felle.size()]]
	return "res://kampf/daten/%s.bin" % Mars.koerper_of(fighter.monster)


## 494 (Prüfer 512b): welches Fell; ein Monster der Karte bringt seins mit („fell“, aufruf.gd lage „nr“), sonst nach der Nummer
func _fell_nr() -> int:
	return maxi(int(fighter.monster.get("fell", fighter.nr)) if fighter.monster != null else fighter.nr, 1)


## 348.12f eingebaut (Chef 28.10., 11:50, Archiv: Kaufwolf und Ratte abgenommen): gekaufte Modelle liegen im APK nur verschlüsselt
## (348.12i: verschluesseln.sh „BKV1“, IV, AES-256-CBC mit PKCS7; wie Toms gebiet.gd entschluessele); unverschlüsselte gehen durch
static func lade_bin(p: String) -> PackedByteArray:
	var b := FileAccess.get_file_as_bytes(p)
	if b.size() < 36 or b.slice(0, 4).get_string_from_ascii() != "BKV1":
		return b
	if Schluessel.KAUF.length() != 64 or (b.size() - 20) % 16 != 0:
		push_error("verschlüsselt, ohne Schlüssel: %s" % p)
		return PackedByteArray()
	var aes := AESContext.new()
	aes.start(AESContext.MODE_CBC_DECRYPT, Schluessel.KAUF.hex_decode(), b.slice(4, 20))
	var d := aes.update(b.slice(20))
	aes.finish()
	var pad := d[d.size() - 1]
	if pad < 1 or pad > 16:
		push_error("falscher Schlüssel: %s" % p)
		return PackedByteArray()
	return d.slice(0, d.size() - pad)


## 387: Felle eines gekauften Tiers (Schlüssel in <art>-info.json, wie kauftier.py sie baut); einmal gelesen je Art
static var _felle_von := {}
static func _kauf_felle(a: String) -> Array:
	if _felle_von.has(a):
		return _felle_von[a]
	var ip := "res://kampf/daten/%s-info.json" % a
	var fl := []
	if FileAccess.file_exists(ip):
		var j = JSON.parse_string(FileAccess.get_file_as_string(ip))
		fl = j.keys() if j is Dictionary else []
	_felle_von[a] = fl
	return fl


## 494: gekaufter Gegner mit eigenen Häuten in <id>-info.json (kaufspinne.py), weder Vierbeiner noch Zweibeiner (die haben dort
## Felle oder Kits), in echter Größe wie die Kauftiere
static func eigene_haut(fi) -> bool:
	return fi != null and fi.monster != null and not vier(fi) and not Mars.koerper_of(fi.monster) in ZWEI \
			and not _kauf_felle(Mars.koerper_of(fi.monster)).is_empty()


## 403 (von Team Tom zu 376.1; Chef 31.10.: nur Modell und Bewegungen): der Held je Klasse auf dem Kaufkörper wie im Dorf
## (HeldFigur.baue: Tracht, Kopf, Haar, Haut), ohne die Ausrüstung unterwegs (die Waffe hält er hier in der Hand, _arm_kauf); dazu
## die Kampfbewegungen aus kampf-bewegungen.bin (held_kampf.py: unsere aus kampf.py, auf das Gerüst der UAL umgerechnet, und die
## Kandidaten „Pro_…“ aus der UAL Pro), übertragen wie HeldFigur.bewegungen. Fehlen die Dateien (Bau ohne Kaufmodelle) oder
## steht ALTHELD=1, bleibt der bisherige Held (held.bin).
const KAMPF_BEW := "res://daten/kampf-bewegungen.bin"
const KAMPF_SCHLEIFEN := ["Kampfstehen", "Pro_Sword_Idle", "SS_IdleCombat", "SS_WalkForward", "SS_RunForward", "SS_WalkBackwards"]
## 406: was held_kampf.py zu den Bewegungen misst (Tempo von Gehen und Rennen, Griff von Schild und Schwert, Aufschlag)
const KAMPF_INFO := "res://daten/kampf-bewegungen.json"
var kauf := false
var ss_f := 1.0      # 406: Größe des Kaufkörpers gegen das Gerüst der Bewegungen (Tempo)
static var kampf_bew: Array = []     # [Animation, Name] je Bewegung, einmal geladen
static var kampf_info: Dictionary = {}

func _kaufheld() -> Node3D:
	if fighter.monster != null or OS.get_environment("ALTHELD") != "" or not FileAccess.file_exists(KAMPF_BEW):
		return null
	var k := _herkunft()     # 870.4: Tracht nach der Herkunft (BrsHeld), Probeblätter mit Klasse wie bisher
	if not HeldFigur.da(k):
		return null
	var w := {"herkunft": k, "volk": String(fighter.hero.get("race", "HUMAN")), "aussehen": fighter.hero.get("look", {}), "ausruestung": {}}
	var m := HeldFigur.baue(w, mats)
	if m == null:
		return null
	anim = _find(m, "AnimationPlayer") as AnimationPlayer
	var sk := _find(m, "Skeleton3D") as Skeleton3D
	if anim == null or sk == null:
		return m
	if kampf_bew.is_empty():
		var sc := Gebiet.lade_glb(KAMPF_BEW)
		var ap0 := _find(sc, "AnimationPlayer") as AnimationPlayer
		if ap0:
			for n in ap0.get_animation_list():
				kampf_bew.append([ap0.get_animation(n).duplicate(true), String(n)])
		sc.free()
	var f := sk.get_bone_rest(sk.find_bone("pelvis")).origin.length() / HeldFigur.bew_becken
	ss_f = f
	if kampf_info.is_empty() and FileAccess.file_exists(KAMPF_INFO):
		var j = JSON.parse_string(FileAccess.get_file_as_string(KAMPF_INFO))
		if j is Dictionary:
			kampf_info = j
	var pfad := str(HeldFigur._pfad(m, sk))
	var lib := anim.get_animation_library("")
	for e in kampf_bew:
		var an := (e[0] as Animation).duplicate(true) as Animation
		for t in range(an.get_track_count() - 1, -1, -1):
			var bn := String(an.track_get_path(t)).get_slice(":", 1)
			an.track_set_path(t, NodePath("%s:%s" % [pfad, bn]))
			var ty := an.track_get_type(t)
			if ty == Animation.TYPE_SCALE_3D or (ty == Animation.TYPE_POSITION_3D and bn not in ["pelvis", "root"]) or sk.find_bone(bn) < 0:
				an.remove_track(t)
			elif ty == Animation.TYPE_POSITION_3D:
				for i in an.track_get_key_count(t): an.track_set_key_value(t, i, an.track_get_key_value(t, i) * f)
		an.loop_mode = Animation.LOOP_LINEAR if e[1] in KAMPF_SCHLEIFEN else Animation.LOOP_NONE
		if lib.has_animation(e[1]):
			lib.remove_animation(e[1])
		lib.add_animation(e[1], an)
	_angriff_gang(lib)
	kauf = true
	return m


## 682 (Chef 08.11., 16:22 „wenn der Held jetzt mal flotter hinginge“, 20:50 „als ob ich in die Hose gemacht hätte“: der geduckte
## Kampfgang SS_WalkForward, doppelt schnell gespielt): „Angriff_Gehen“ = Beine und Rumpf aus dem Gehen mit Schild wie auf der Karte
## (417 Runde 5, 2,13 m/s), Arme fest in der Kampfhaltung SS_IdleCombat (Schild oben); das Gehen allein schwingt den Schild 8 cm in
## den Körper (schild_406)
const ARM_KNOCHEN := ["clavicle", "upperarm", "lowerarm", "hand", "thumb", "index", "middle", "ring", "pinky"]
func _angriff_gang(lib: AnimationLibrary) -> void:
	if not (lib.has_animation("Gehen_schild") and lib.has_animation("SS_IdleCombat")):
		return
	var an := lib.get_animation("Gehen_schild").duplicate(true) as Animation
	var idle := lib.get_animation("SS_IdleCombat")
	var arm := {}
	for i in idle.get_track_count():
		var bn := String(idle.track_get_path(i)).get_slice(":", 1)
		if idle.track_get_type(i) == Animation.TYPE_ROTATION_3D and ARM_KNOCHEN.any(func(w): return bn.begins_with(w)):
			arm[bn] = idle.rotation_track_interpolate(i, 0.0)
	for i in range(an.get_track_count() - 1, -1, -1):
		var bn := String(an.track_get_path(i)).get_slice(":", 1)
		if an.track_get_type(i) == Animation.TYPE_ROTATION_3D and arm.has(bn):
			while an.track_get_key_count(i) > 0:
				an.track_remove_key(i, 0)
			an.rotation_track_insert_key(i, 0.0, arm[bn])
			arm.erase(bn)
	var pfad := String(an.track_get_path(0)).get_slice(":", 0) if an.get_track_count() > 0 else ""
	for bn in arm:
		var i := an.add_track(Animation.TYPE_ROTATION_3D)
		an.track_set_path(i, NodePath("%s:%s" % [pfad, bn]))
		an.rotation_track_insert_key(i, 0.0, arm[bn])
	an.loop_mode = Animation.LOOP_LINEAR
	lib.add_animation("Angriff_Gehen", an)


func _load_model() -> Node3D:
	var kh := _kaufheld()
	if kh != null:
		return kh
	var p := _model_path()
	if FileAccess.file_exists(p):
		var doc := GLTFDocument.new()
		var st := GLTFState.new()
		if doc.append_from_buffer(lade_bin(p), "", st) == OK:
			# Runde 15: unveränderliche Spuren behalten; sonst fehlten im Scharren die ruhenden Knochen (rechter Vorderlauf) und blieben
			# in der Haltung der vorigen Bewegung stehen (Prüfer: „Hasensprung“, zweite Vorderpfote in der Luft)
			var n := doc.generate_scene(st, 30.0, false, false) as Node3D
			_paint(n)
			anim = _find(n, "AnimationPlayer") as AnimationPlayer
			if anim:
				for a in ["Stehen", "Gehen", "Hocke", "Rennen", "Zurück"]:
					if anim.has_animation(a):
						anim.get_animation(a).loop_mode = Animation.LOOP_LINEAR
			return n
	# noch ohne Modell (Goblin, Spinne …): ein Körper in der Größe, damit der Ablauf sichtbar bleibt
	var mi := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = 0.3
	cm.height = 1.5
	mi.mesh = cm
	mi.position.y = 0.75
	var m := _toon(Color(0.35, 0.3, 0.25))
	mi.material_override = m
	mats.append(m)
	var root := Node3D.new()
	root.add_child(mi)
	return root


# Waffe und Schild an den Händen (Modellregel 4): Startausrüstung je Klasse wie Hero.create; die Waffe aus dem Bogen
# (main.id), sonst die der Klasse. Griff in der Handfläche (held3.py hand(): Handmitte 3,6 cm hinter dem Handgelenk,
# Unterarmknochen fo-wr 12,1 cm, Finger um die Achse vorn-hinten gekrümmt), also liegt der Griff vorn-hinten in der Hand.
## 406: der Schild, den der Held trägt (aufruf.gd blatt „schild“), sonst der der Startausrüstung (Rules.kt: Kämpfer Rundschild,
## Kleriker Drachenschild als „Schild“; Kaufschilde 15 und 2, Chef 31.10., 23:22)
const OFF_HAND := {"FIGHTER": "round_shield", "CLERIC": "shield"}
## 406 b: Schild im Kampf gegen die Lage aus dem Prefab [tiefer m, vorn m, Oberkante vor Grad, Seite +x vor Grad], gedreht um die
## Fessel (wie tests/schild_406.gd _neigung). Lauf 167 (Messung an der Fläche): Rundschild vorn 3 cm, Schulter und Oberarm -0,7 statt
## 2,3 cm; Drachenschild mit der Schulter bei Abwehr bis 7,7 cm durch den oberen Innenrand, Verschieben allein half nicht.
## Lauf 168 (geneigt): Rundschild dazu Seite 20° vor: Körper -0,7, Schulter -4,1 cm (vorher kreuzte der Schwertarm 8,4 cm davor);
## Drachenschild Oberkante 15° und Seite 15° vor: Körper -2,1 (vorher 1,6), Schulter -3,6 cm (vorher 7,4)
const SCHILD_LAGE := {"shield": [0.0, 0.0, 15.0, 15.0], "round_shield": [0.0, 0.03, 0.0, 20.0]}
const GRIP_CM := 15.7
const PALM_CM := 2.4
const CM := 0.01
const STAFFS := ["quarterstaff", "staff"]

func _arm() -> void:
	var sk := _find(model, "Skeleton3D") as Skeleton3D
	if sk == null:
		return
	var main: String = _waffe_id()
	if main != "":
		_hold(sk, _waffenhand(), main)
	var off: String = _schild()
	if off != "":
		_hold(sk, "L", off)


## 999 (alt Skirmish.looks, 72.10a.11: „sehe ich nicht am Avatar“; 268: „Wechsel auf Armbrust, ist aber Zweihänder“): was der Held
## gerade führt, die erste Waffe oder nach „Waffe wechseln“ die zweite (wie Fighter.weapon); nur fürs Bild
var gezogen := false

func _in_hand():
	if fighter.hero == null:
		return null
	if gezogen and fighter.second != null:
		return fighter.second
	return fighter.main_weapon()


## Kennung des Modells der Waffe in der Hand, "" ohne Waffe oder ohne Modell (die Armbrust hat noch keins)
func _waffe_id() -> String:
	var w = _in_hand()
	if w == null or String(w.id) == "" or not FileAccess.file_exists("res://kampf/daten/%s.bin" % w.id):
		return ""
	return String(w.id)


## 999: der Bogen steht in der linken Faust (alt Dress.bow: „A bow in the left hand, standing upright“), jede andere Waffe rechts
func _waffenhand() -> String:
	var w = _in_hand()
	return "L" if w != null and bool(w.ranged) and String(w.id).contains("bow") else "R"


## 999: nach „Waffe wechseln“ die andere Waffe in der Hand (die Meldung der Regeln bringt „drawn“, kampfort.gd); eine zweihändige
## nimmt die Schildhand mit, der Schild ist weg, bis die erste wieder in der Hand ist (alt looks: gear.remove(OFF_HAND))
func waffe_ziehen(an: bool) -> void:
	if fighter.hero == null or an == gezogen:
		return
	gezogen = an
	var sk := _find(model, "Skeleton3D") as Skeleton3D if model else null
	if sk == null:
		return
	for at in sk.find_children("*", "BoneAttachment3D", true, false):
		if at.has_meta("was") and String(at.get_meta("was")) != "waffe-im-modell":
			at.get_parent().remove_child(at)
			at.queue_free()
	hieb_bahn.clear()
	if kauf:
		_arm_kauf(true)
	else:
		sk.reset_bone_poses()     # wie beim Aufbau: _hold richtet nach der Ruhelage aus, die Bewegung setzt im nächsten Bild fort
		_arm()


## Goblin, Späher, Grak: Zweibeiner auf dem Gerüst aus goblin.py oder grak_gestalt.py
func _zweibeiner() -> bool:
	return fighter.monster != null and Mars.koerper_of(fighter.monster) in ZWEI


## 403: Waffe und Schild am Kaufkörper. Der Kaufkörper ruht in der T-Pose, darum wie beim Goblin nach der Haltung in Stehen
## ausgerichtet (erst im Baum); die Klinge liegt längs des Faustlochs (HeldFigur.faust: zwischen den Knöcheln von Zeige- und
## Kleinfinger), wie kampf.py die Bewegungen gebaut hat (faust_R), die Schneide in der Ebene aus Faustloch und Handknochen
func _arm_kauf(gleich := false) -> void:
	var sk := _find(model, "Skeleton3D") as Skeleton3D
	if sk == null:
		return
	if not is_inside_tree():
		await tree_entered
	var halt := "Ruhelage" if anim and anim.has_animation("Ruhelage") else "Stehen"
	if _ss():     # 406: der Stab (Kleriker: Stab und Schild) steht in der Kampfhaltung des Satzes senkrecht in der Faust
		halt = "SS_IdleCombat"
	if anim and anim.has_animation(halt):
		# in unserer Ruhelage (Arme hängend, held_kampf.py) wie der alte Held vor dem Einhängen: so hat kampf.py den Schild gebaut.
		# Prüfer Film 403: der Schild stand quer in Kopfhöhe; im ersten Bild im Baum galt noch die T-Pose, erst ein Bild später die Haltung
		anim.play(halt)
		anim.seek(0.0, true)
		if not gleich:     # 999: beim Wechsel im Kampf steht die Figur längst im Baum, die Haltung gilt sofort (kein Bild in Ruhelage)
			await get_tree().process_frame
			anim.seek(0.0, true)
		sk.force_update_all_bone_transforms()
	var main: String = _waffe_id()
	if main != "" and _waffenhand() == "L":
		_hold(sk, "L", main)
	elif main != "":
		var fr := HeldFigur.faust(sk, "r")
		_hold(sk, "R", main, GRIP_CM * CM, PALM_CM * CM, 1.0, {}, fr)
	var off: String = _schild()
	if schild_faust != null:     # 999: ohne Schild (zweihändige Waffe) bleiben die Finger offen
		schild_faust.active = off != ""
	if off != "":
		_hold(sk, "L", off)
		if _ss() and schild_faust == null:     # 406a E3: die Finger der Schildhand zur Faust, nicht außen auf dem Schild
			schild_faust = SchildFaust.new()
			schild_faust.name = "SchildFaust"
			sk.add_child(schild_faust)
		if schild_faust != null:     # 406a E3: Knick im Handgelenk, wie _hold den Schild dagegen gesetzt hat
			schild_faust.knick = knick_quat
			schild_faust.achse = knick_achse
			schild_faust.hand = knick_knochen
	if anim:
		_idle()


func _schild() -> String:
	var w = _in_hand()
	if w != null and bool(w.get("two", false)):     # 999 (268): eine zweihändige Waffe braucht die Schildhand
		return ""
	if fighter.hero.has("schild"):
		return String(fighter.hero["schild"])
	return OFF_HAND.get(fighter.hero.get("cls", ""), "")


## Goblin, Späher oder (Probe „Schamanen“) Schamane: Kennung der Modelle und der info.json
func _gob_art() -> String:
	if Mars.koerper_of(fighter.monster) == Mars.CALLED and _mein_ersatz() in [SHAMAN, KOBOLD]:
		return _mein_ersatz()
	return Mars.koerper_of(fighter.monster)


func _gob_kit() -> String:
	if Mars.koerper_of(fighter.monster) == Mars.GRAK:
		return GRAK_KITS[0]
	if Mars.koerper_of(fighter.monster) == Mars.KROGG:
		return KROGG_KITS[0]
	if Mars.koerper_of(fighter.monster) == SKELETT:     # 506: je Nummer ein Kit (Kurzschwert und Helm, Kurzschwert und Schild, Speer und Helm)
		return SKELETT_KITS[(_fell_nr() - 1) % SKELETT_KITS.size()]     # das Monster der Karte bringt sein Kit mit
	if Mars.koerper_of(fighter.monster) == WIEDERGAENGER:     # 506: je Nummer ein Kit (Lumpen, Leichenhemd, Kettenhemd)
		return WIEDERGAENGER_KITS[(_fell_nr() - 1) % WIEDERGAENGER_KITS.size()]
	var kits: Array = SCOUT_KITS if Mars.koerper_of(fighter.monster) == Mars.SCOUT else (SHAMAN_KITS if _gob_art() == SHAMAN else (KOBOLD_KITS if _gob_art() == KOBOLD else GOBLIN_KITS))
	return kits[(maxi(fighter.nr, 1) - 1) % kits.size()]


## 348.7: die Waffen des Kits (<art>-info.json „waffen“: rechte Hand, dann linke; leer = Hand frei), Griff nach den Maßen des Goblins
func _arm_goblin() -> void:
	var sk := _find(model, "Skeleton3D") as Skeleton3D
	var f := FileAccess.open("res://kampf/daten/%s-info.json" % _gob_art(), FileAccess.READ)
	if sk == null or f == null:
		return
	var info: Dictionary = JSON.parse_string(f.get_as_text()).get(_gob_kit(), {})
	gob_h = info.get("groesse_cm", 110.0) / 100.0
	if not is_inside_tree():     # der Kampfort hängt die Figur erst nach setup() ein; vorher spielt der AnimationPlayer nichts
		await tree_entered
	# Goblin Runde 2: die Arme stehen in der Lauer vor dem Körper; Waffe und Schild nach der Haltung in Stehen ausrichten, nicht
	# nach der Ruhelage (hängender Arm), sonst zeigte die Klinge mit dem gehobenen Unterarm waagerecht nach vorn
	if anim and anim.has_animation("Stehen"):
		anim.play("Stehen")
		anim.seek(0.0, true)
		sk.force_update_all_bone_transforms()
	var w: Array = info.get("waffen", [])
	for i in mini(w.size(), 2):
		if String(w[i]) == "":
			continue
		# Runde 3 (Prüfer Runde 2: Schwert fast so lang wie der Goblin, Schild vom Kinn bis zu den Füßen): Waffen der Goblins kleiner
		var sz: float = GOB_SCHILD if String(w[i]).contains("shield") else (GOB_BOGEN * gob_h if String(w[i]) == "shortbow"
			else (info.get("koerper_cm", 108.0) / 108.0 if String(w[i]) == "staff-schamane" else GOB_WAFFE))
		# Kobold Runde 1b (Prüfer 1a: Schild bis zum Boden, Dolch so lang wie ein Kurzschwert): Schild und Dolch mit dem Träger
		# kleiner (der Speer ist für ihn gebaut, waffen.py)
		if _gob_art() == KOBOLD and String(w[i]) != "spear-rost":
			sz *= info.get("koerper_cm", 80.0) / 108.0
		if String(w[i]) == "greataxe-grak":
			sz = 1.0
		# 348.12 Probe CC0-Gerüst (goblin.py GERUEST=cc0): der Handknochen beginnt am Handgelenk, der Griff liegt näher
		var grip: float = info.get("griff_hand_m", 0.0) if info.get("geruest", "") == "cc0" else info.get("griff_m", GRIP_CM * CM)
		_hold(sk, "R" if i == 0 else "L", w[i], grip, info.get("handflaeche_m", PALM_CM * CM), sz, info.get("axt", {}))
	if _gob_art() == SKELETT:     # 506 (LISTE-FIGUREN „Skelett“ 3): in jeder Augenhöhle ein schwacher Glutpunkt (kaufskelett.py augen)
		for m in mats:
			m.set_shader_parameter("glut", 1.2)
	# 506 t274.14 (skelett_506: drei Skelette alle bei derselben Stelle der Ruheschleife): oben stellt Stehen auf 0 zurück, nachdem
	# setup() die Schleife schon je Figur versetzt hatte; danach wieder versetzt
	if fighter.monster != null and anim and anim.has_animation("Stehen") and anim.current_animation == "Stehen":
		_schleifen = 0
		_idle()
	# 709 (treffen_709 Krogg: Lücke 0,53 m; der Morgenstern hängt im Modell am Knochen „waffe“, krogg_gestalt.py, und galt nicht als
	# Waffe: _hieb nahm die Weite aus der info, die Messung die Hand): was im Modell an einem Knochen hängt und „Waffe“ heißt, ist sie
	if w.is_empty():
		for at in model.find_children("*", "BoneAttachment3D", true, false):
			if not at.has_meta("was") and at.find_children("Waffe*", "MeshInstance3D", true, false).size() > 0:
				at.set_meta("was", "waffe-im-modell")
	if _gob_art() == SHAMAN:     # Augen und der Schädel am Stab glimmen grün (Eckfarbe mit Alpha 0; goblin.py, waffen.py)
		for m in mats:
			m.set_shader_parameter("glut", 1.8)     # Runde 1b (Prüfer 1a: nicht zu sehen) 2,5; 1c (Prüfer 1b: gelb statt grün) 1,8


## Hangs [what] (a .glb in metres, grip at its origin) on the forearm of [side]; the model is in metres too (held.glb, goblin-*.glb).
## [grip] from the forearm joint to the middle of the hand, [palm] half the hand's thickness (metres).
## [axt] (348.12 Grak Runde 2, goblin.py/grak_arme.py): Lage der Axt im Skelett in Stehen, Bild 0 (Griff, Achse, Schneide, linke Faust)
func _hold(sk: Skeleton3D, side: String, what: String, grip := GRIP_CM * CM, palm := PALM_CM * CM, size := 1.0, axt := {}, faust := {}) -> void:
	var p := "res://kampf/daten/%s.bin" % what
	var bi := sk.find_bone("fo%s-wr%s" % [side, side])
	if bi < 0:     # 348.12 CC0-Gerüst: Handknochen vom Handgelenk in Richtung des Unterarms (geruest.py lage)
		bi = sk.find_bone("hand_%s" % side.to_lower())
	if bi < 0 or not FileAccess.file_exists(p):
		return
	var doc := GLTFDocument.new()
	var st := GLTFState.new()
	if doc.append_from_buffer(lade_bin(p), "", st) != OK:
		return
	var w := doc.generate_scene(st) as Node3D
	_paint(w)
	var at := BoneAttachment3D.new()
	at.bone_name = sk.get_bone_name(bi)
	at.set_meta("was", what)     # 438: Messung (traegt())
	sk.add_child(at)
	at.add_child(w)
	# directions of the figure (+Z forward, +Y up, inward to the body) in the bone's own space
	# in the pose it stands in (Stehen), not the rest pose: the hanging arm turns the forearm (Prüfer: Klinge 40° nach oben)
	var rest := sk.get_bone_global_pose(bi).basis.orthonormalized().inverse()
	var down := rest * Vector3.DOWN
	var fwd := rest * Vector3.BACK
	var inward := rest * (Vector3.RIGHT if side == "R" else Vector3.LEFT)
	var b: Basis
	var o: Vector3
	var ss_griff: Dictionary = kampf_info.get("griff", {}).get("schild", {}) if what.contains("shield") and _ss() else {}
	if not ss_griff.is_empty():
		# 406: wie der Satz „Sword & Shield“ den Schild hält (held_kampf.py „griff“, aus dem Prefab): im Handrahmen (Handgelenk zum
		# Mittelfingerknöchel, quer vom Klein- zum Zeigefinger) die Fessel unseres Schilds dort, wo die Rückseite des Bretts des Satzes in
		# der Mitte liegt, Vorderseite und oben wie dort (Prüferbefund 01.11., 12:0x: vorher nur die Innenseite im Bild)
		var hr := sk.get_bone_global_rest(bi).affine_inverse()
		var s_ := side.to_lower()
		var h0: Vector3 = hr * sk.get_bone_global_rest(bi).origin
		var mf: Vector3 = hr * sk.get_bone_global_rest(sk.find_bone("middle_01_" + s_)).origin
		var zf: Vector3 = hr * sk.get_bone_global_rest(sk.find_bone("index_01_" + s_)).origin
		var kf: Vector3 = hr * sk.get_bone_global_rest(sk.find_bone("pinky_01_" + s_)).origin
		var hx := (mf - h0).normalized()
		var hz := hx.cross(zf - kf).normalized()
		var rb := Basis(hx, hz.cross(hx), hz)
		var lang := (mf - h0).length()
		var v3 := func(k: String) -> Vector3: return Vector3(ss_griff[k][0], ss_griff[k][1], ss_griff[k][2])
		var front: Vector3 = (rb * v3.call("vorn")).normalized()
		var up: Vector3 = rb * v3.call("oben")
		up = (up - front * up.dot(front)).normalized()
		b = Basis(up.cross(front), up, front)
		o = h0 + rb * (v3.call("griff") * lang)
		# 406 b (Chef 01.11., 20:2x: „bei beiden Schultern … Draufsicht, links am Schild … eine leichte Irritation“): der Schild sitzt
		# je Art um [tiefer, weiter vorn] m anders an der Fessel (SCHILD_LAGE; gemessen tests/schild_406.gd FASSUNG)
		var lage: Array = SCHILD_LAGE.get(what, [0.0, 0.0, 0.0, 0.0])
		o += b * Vector3(0.0, -lage[0], lage[1])
		b = b * Basis(Vector3.UP, deg_to_rad(-lage[3])) * Basis(Vector3.RIGHT, deg_to_rad(lage[2]))
		# 406a E3 Lauf 190 (Faust −50°: Finger noch 2,1–2,7 cm, Kleriker 3,7–4,0 cm vor der Vorderseite; Schild weiter vor schiebt den
		# Schwertarm hinein, Lauf 179): die Hand im Handgelenk um KNICK_GRAD nach hinten knicken, Knöchel weg von der Vorderseite; der
		# Schild bleibt, wo er war (hier um dieselbe Drehung zurück), die Faust dreht SchildFaust nach jeder Pose
		knick_achse = b.z.normalized().cross(hx).normalized()
		knick_knochen = bi
		var knick := Basis(knick_achse, deg_to_rad(KNICK_GRAD.get(_tracht(), 0.0)))
		knick_quat = knick.get_rotation_quaternion()
		b = knick.inverse() * b
		o = knick.inverse() * o
	elif what.contains("shield"):
		# Schild am Unterarm außen: Vorderseite nach außen, oben nach oben, die Fessel um den Unterarm
		b = Basis(fwd, -down, -inward)
		if fighter.monster != null:     # Goblin Runde 4 (Prüfer Runde 3, Chef 21:33 „so schwarz“): nach außen lag die Vorderseite im
			# eigenen Schatten und las sich von vorn als dunkles Oval; jetzt halb zum Gegner gedreht wie im alten Bild
			var front := (fwd * 0.75 - inward * 0.65).normalized()
			b = Basis((-down).cross(front), -down, front)
			o = Vector3(0, grip * 0.35, 0) - inward * 4.0 * CM + front * 3.0 * CM     # gedreht stach die Faust durchs Brett
		else:
			o = Vector3(0, grip * 0.35, 0) - inward * 4.0 * CM
	elif what.contains("bow"):
		# 348.7 Späher: Bogen ungespannt in Ruhe wie Dress.bow: aufrecht in der Faust, der obere Wurfarm 15° zum Gegner geneigt,
		# die Sehne zum Körper
		var up := (-down * cos(deg_to_rad(15.0)) + fwd * sin(deg_to_rad(15.0))).normalized()
		if fighter.monster != null:     # Späher Runde 2b (Prüfer 2a: der Bogen hängt vor den Beinen): oben 12° nach außen
			# Runde 3 (Sokrates statt Chef, 362; Prüfer, Diogenes 2: der Bogen steckt im Oberschenkel): oben 8° nach innen, so
			# steht der untere Wurfarm außen neben dem Bein (der Arm dazu weiter zur Seite, goblin.py)
			up = (up + inward * 0.14).normalized()
			# Runde 3b (Prüfer 3a: der Bogen steht 20–25° schräg, oben zum Kopf, unten zwischen die Beine): fast senkrecht, oben
			# nur 5° zum Gegner und 4° nach innen
			up = (-down + fwd * 0.09 + inward * 0.07).normalized()
			# Runde 3c (Prüfer, Diogenes 3b: der obere Wurfarm liegt auf dem Oberarm): oben 8° nach außen, weg vom Arm; die Faust
			# hängt jetzt neben der Hüfte, der untere Wurfarm bleibt neben dem Bein
			up = (-down + fwd * 0.09 - inward * 0.14).normalized()
			# Runde 4 (Sokrates statt Chef, 362: oberer Wurfarm nicht auf Unterarm oder Ellbogen; der Arm jetzt gestreckt schräg
			# nach außen, goblin.py): oben 11° zum Gegner und 14° nach außen, so steht er außen neben dem Arm, der untere
			# Wurfarm neben dem Bein; im Probebild frei: oben 1,7–2,2 cm vom Arm, 32 cm vom Rumpf, unten 23 cm vom Bein
			up = (-down + fwd * 0.2 - inward * 0.25).normalized()
		# Runde 1b (Prüfer 1a: von vorn nur ein Strich): Bogenebene seitlich, der Rücken nach außen und etwas vor, so zeigt er die Krümmung
		var aside := -inward * 0.9 + fwd * 0.3
		if fighter.monster != null:     # Späher Runde 4 (Prüfer 4a: der Bogen gerade, ohne Krümmung): der Rücken nach außen und
			# etwas zurück, so steht die Krümmung quer zur Kamera (82–90° statt 50°, probe.gd „Bogen …“)
			aside = -inward * 0.9 - fwd * 0.4
		var back := (aside - up * aside.dot(up)).normalized()
		b = Basis(back, up, back.cross(up))
		o = Vector3(0, grip, 0) + inward * palm
	elif what == "staff-schamane":
		# Schamane: Stab aufgestellt, senkrecht in der Faust, der Schädel zum Gegner (waffen.py: +X); in der Faust so weit
		# geschoben, dass der Fuß (60 cm unter dem Ursprung, für 108 cm gebaut) am Boden steht
		var up := -down
		b = Basis(fwd, up, fwd.cross(up))
		var hand_y: float = (sk.get_bone_global_pose(bi) * Vector3(0, grip, 0)).y
		o = Vector3(0, grip, 0) + inward * palm + up * (0.60 * size - hand_y)
	elif what == "greataxe-grak" and axt.has("griff"):
		# Runde 2 (Prüfer r1: die Axt in keiner Hand, im Hieb bleibt sie stehen): die Arme sind beim Bau an die Axt gestellt
		# (grak_arme.py); hier nur ihre Lage aus Stehen, Bild 0, in den Raum der rechten Hand, so folgt sie der Faust in jeder Bewegung
		var hand := sk.get_bone_global_pose(bi).affine_inverse()
		var p3 := {}
		for k in ["griff", "achse", "schneide", "links"]:
			p3[k] = Vector3(axt[k][0], axt[k][1], axt[k][2])
		var ax: Vector3 = (hand.basis * (p3["achse"] as Vector3)).normalized()
		var edge: Vector3 = hand.basis * (p3["schneide"] as Vector3)
		edge = (edge - ax * edge.dot(ax)).normalized()
		b = Basis(edge, ax, edge.cross(ax))
		o = hand * (p3["griff"] as Vector3)
		w.set_meta("links", sk.get_bone_global_pose(sk.find_bone("hand_l")).affine_inverse() * (p3["links"] as Vector3))
	elif what == "greataxe-grak":
		# Grak: der Stiel steil vor dem Körper nach oben, etwas nach außen und vor, der Kopf über der rechten Schulter, die
		# Schneide nach vorn; die linke Faust hält ihn 38 cm tiefer am Stielende (ual_lauer.py GRAK_HALT, gleiche Richtung)
		var ax := (-inward * 0.30 + fwd * 0.12 - down * 0.95).normalized()
		var edge := (fwd - ax * fwd.dot(ax)).normalized()
		b = Basis(edge, ax, edge.cross(ax))
		o = Vector3(0, grip, 0) + inward * palm
	elif not faust.is_empty() and not what.contains("bow") and what not in STAFFS:
		# 403 Kaufkörper: Griff im Faustloch, Klinge (Stab) längs des Faustlochs zum Daumen hin, Schneide in der Ebene mit dem Handknochen
		var ax: Vector3 = (faust["achse"] as Vector3).normalized()
		var edge := Vector3.UP - ax * Vector3.UP.dot(ax)
		edge = edge.normalized() if edge.length() > 0.01 else ax.cross(Vector3.RIGHT).normalized()
		b = Basis(edge, ax, edge.cross(ax))
		o = faust["griff"]
	elif what in STAFFS:
		# Stab senkrecht neben dem Körper, in der Mitte gefasst; 403 Kaufkörper: im Faustloch (Prüfer Film 403: längs des Faustlochs
		# zeigte der Stab in Kampfstehen waagerecht auf den Nachbarn und lief durch die Beine)
		b = Basis(fwd, -down, fwd.cross(-down))
		o = faust["griff"] if not faust.is_empty() else Vector3(0, grip, 0) + inward * palm
	else:
		# Klinge wie die alte Bereitschaft (HeroFigure.READY weapon = 0,2 außen, 0,85 oben, 0,45 vorn), Schneide vorn und hinten;
		# nie waagerecht nach vorn auf Hüfthöhe (DESIGN-ABNAHME, Silhouetten)
		var ax := (-inward * 0.2 - down * 0.85 + fwd * 0.45).normalized()
		if fighter.monster != null:     # Goblin Runde 3 (Prüfer Runde 2: Klinge nach oben hinten „wie präsentieren“): Spitze zum Gegner
			ax = (-inward * 0.1 - down * 0.6 + fwd * 0.8).normalized()
		var edge := (fwd - ax * fwd.dot(ax)).normalized()
		b = Basis(edge, ax, edge.cross(ax))
		o = Vector3(0, grip, 0) + inward * palm
	w.transform = Transform3D(Basis(b.x * size, b.y * size, b.z * size), o)
	# 999: der Bogen des Helden links ist seine Waffe (cast_point: der Pfeil geht vom Bogen aus); beim Späher bleibt es, wie es war
	w.name = "Waffe" if side == "R" or (fighter.monster == null and what.contains("bow")) else "Schild"
	w.set_meta("stab", what in STAFFS or what == "staff-schamane")     # 348.7b: Zauber ab der Stabspitze (cast_point)
	if fighter.monster != null and (what in ["shortbow", "staff-schamane"] or what.ends_with("-rost") or what.ends_with("-grob")):
		# Späher Runde 1c (Prüfer 1a, 1b: der Bogen ein schwarzer Strich, die Tusche ist breiter als der Wurfarm): ohne Tusche wie
		# Held und Söldner (Schablone 2), so liest sich das Holz mit der Krümmung
		# Goblin Runde 6 (Prüfer Runde 5: Säbel mit der Umrisslinie ganz schwarz, Beil und Dolch Klumpen): Goblinwaffen ebenso
		for m in mats.slice(mats.size() - _count_meshes(w)):
			(m as ShaderMaterial).shader = toon_mark()


func _count_meshes(n: Node) -> int:
	var c := 0
	if n is MeshInstance3D:
		c += (n as MeshInstance3D).mesh.get_surface_count()
	for k in n.get_children():
		c += _count_meshes(k)
	return c


# Schablone wie Toms gebiet.gd toon_mark: 2 = Held, Söldner und ihre Waffen mit feinerer Tusche (Prüfer Stand 7: Tusche frass
# Stab, Klinge und Schild), im Schatten aufgehellt wie held.gd (fill 0,42 am Tag)
static var marked: Shader

static func toon_mark() -> Shader:
	if marked == null:
		var toon: Shader = load("res://kampf/toon.gdshader")
		marked = Shader.new()
		marked.code = toon.code.replace("render_mode cull_disabled, specular_disabled;", "render_mode cull_disabled, specular_disabled;\nstencil_mode write, compare_always, 2;")
	return marked


# 348.13a Runde 7 (Probe TUSCHE=licht, Tom): Gegner mit eigener Schablone 3; ohne sie zeichnete die Welttusche (1,3 x 1,7 statt
# 0,8 x 1,5 am Helden) die Goblins: am Rechner gemessen 2200 bis 4300 Tuschepunkte je Goblin schon ohne breiten Umriss
static var marked_gegner: Shader

static func toon_gegner() -> Shader:
	if marked_gegner == null:
		var toon: Shader = load("res://kampf/toon.gdshader")
		marked_gegner = Shader.new()
		marked_gegner.code = toon.code.replace("render_mode cull_disabled, specular_disabled;", "render_mode cull_disabled, specular_disabled;\nstencil_mode write, compare_always, 3;")
	return marked_gegner


func _toon(c: Color) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	if fighter != null and fighter.side == "PARTY":
		m.shader = toon_mark()
		m.set_shader_parameter("fill", 0.42)
	elif load("res://kampf/kampfort.gd").tusche() == "licht":     # 348.13a: Vorgabe Tusche nach Licht
		m.shader = toon_gegner()
		# 348.13a (Prüfer r9: der hintere Goblin hebt sich vom Weg kaum ab; Tom: Goblins aufhellen): Mindesthelligkeit im Schatten
		if GOB_FILL > 0.0 and fighter != null and fighter.monster != null and String(Mars.koerper_of(fighter.monster)).begins_with("goblin"):
			m.set_shader_parameter("fill", GOB_FILL)
	else:
		m.shader = load("res://kampf/toon.gdshader")
	var img := Image.create(4, 4, false, Image.FORMAT_RGB8)
	img.fill(c)
	m.set_shader_parameter("tex", ImageTexture.create_from_image(img))
	m.set_shader_parameter("glow_col", Color(0.9, 0.1, 0.05))
	return m


func _paint(n: Node) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		for i in mi.mesh.get_surface_count():
			var src := mi.mesh.surface_get_material(i)
			var tex: Texture2D = null
			if src is BaseMaterial3D:
				tex = (src as BaseMaterial3D).albedo_texture
			var m := _toon(Color.WHITE)
			if tex:
				m.set_shader_parameter("tex", tex)
			# 506 Grabhund (kaufgrabhund.py): Mähne und Schwanzhaar sind Haarkarten mit Durchsicht (glTF „MASK“); toon.gdshader schneidet aus
			if src is BaseMaterial3D and (src as BaseMaterial3D).transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR:
				m.set_shader_parameter("schnitt", (src as BaseMaterial3D).alpha_scissor_threshold)
			mi.set_surface_override_material(i, m)
			mats.append(m)
	for c in n.get_children():
		_paint(c)


func _find(n: Node, cls: String) -> Node:
	if n.get_class() == cls:
		return n
	for c in n.get_children():
		var r := _find(c, cls)
		if r:
			return r
	return null


func _face(dir := Vector3.ZERO) -> void:
	var d: Vector3 = dir if dir != Vector3.ZERO else kampfort.facing(fighter.side == "FOES")
	# Wölfe in Ruhe halb seitlich wie im alten Bild: von vorn verkürzt las sich der Rumpf als Buckel ohne Hals (Prüfer Runde 10)
	var look := 0.0
	if dir == Vector3.ZERO and vier(fighter):
		var turn: float = float(OS.get_environment("WOLFDREH")) if OS.has_environment("WOLFDREH") else WOLF_TURN
		if aim != null and is_instance_valid(aim) and not aim.down and aim.dead_at < 0:
			# Mit Ziel: Rumpf zum Ziel, aber nur im Bereich, in dem die Kamera ihn halb seitlich sieht (zur Kamera hin gedreht
			# las er sich frontal als Säule ohne Hals, Prüfer Runde 12); den Rest dreht der Hals, so blickt jeder auf sein Ziel
			var to: float = rad_to_deg(d.signed_angle_to(aim.position - position, Vector3.UP))
			var body := clampf(to, turn - 20.0, turn + 20.0)
			look = to - body
			turn = body
		# Fledermaus Runde 4 (Prüfer 3b: die Schwarze hing 35° schräg „wie abstürzend“, Flügelkeil über dem Kopf): der zum Ziel gedrehte
		# Rumpf kippte die gespreizten Flügel am Schirm (gemessen 28° bei 29° Drehung). Sie hält den Rumpf zur Kamera, der Kopf blickt
		var cam: Camera3D = get_viewport().get_camera_3d() if is_inside_tree() else null
		if _mein_ersatz() == "giant_bat" and cam != null:
			var zc := cam.global_position - global_position
			zc.y = 0.0
			var front: float = rad_to_deg(d.signed_angle_to(zc, Vector3.UP))
			look += turn - front
			turn = front
		d = d.rotated(Vector3.UP, deg_to_rad(turn))
	if neck:
		neck.want = look
	rotation.y = atan2(d.x, d.z)


## Runde 16 (Prüfer Runde 15: beim schwarzen kreuzte der gehobene Lauf das Standbein): scharren mit dem Vorderlauf, der der Kamera
## näher ist (Modell: links = +X); der ferne lag von hier aus vor dem nahen
func scharren_name() -> String:
	var cam := get_viewport().get_camera_3d()
	if cam == null or anim == null or not anim.has_animation("ScharrenR"):
		return "Scharren"
	var local := global_transform.basis.inverse() * (cam.global_position - global_position)
	return "Scharren" if local.x > 0.0 else "ScharrenR"


func _play(name: String, blend := 0.15) -> void:
	if anim and not anim.has_animation(name):
		name = ALIAS.get(name, name)
	if anim and name == "Sprung" and not anim.has_animation(name) and anim.has_animation("Sprungbiss"):
		name = "Sprungbiss"     # 348.12f: die Kaufratte springt mit dem Sprungbiss der Quelle an
	if anim and name in ["Biss", "Hauer"] and not anim.has_animation(name) and anim.has_animation("Hieb"):
		name = "Hieb"     # 348.12 Runde 3: Goblin auf dem CC0-Gerüst schlägt (sonst schnellt er nur vor)
	if anim and anim.has_animation(name):
		anim.clear_queue()     # 453: eine angehängte Grundhaltung (nach einer Ruhebewegung) gilt nicht mehr, sobald etwas anderes beginnt
		anim.play(name, blend, float(tempo.get(name, 1.0)))


## 453.1 (Chef 01.11., 13:0x: „dass unsere Helden unsere zwei immer gleich atmen … nicht so heftig … nach einer Abwehr ein bisschen
## schneller und dann wieder ruhiger“): Held und Söldner atmen als eigene Schicht (atem.gd), je Figur eigener Takt und Versatz. Die
## Ruhebewegung der UAL (Idle_Loop, aus ihr Kampfstehen in kampf.py) atmet selbst zweimal in 2,5 s (Schulter 2,1 cm, Kopf 4°; gemessen
## 01.11.), beide Helden im Gleichtakt: in den Ruhebewegungen des Kampfs bleibt darum ihr erstes Bild stehen (_ohne_atem), das auch
## Anfang und Ende jeder Kampfbewegung ist, und nur die Schicht atmet.
const ATEM_RUHE := ["Kampfstehen", "Stehen", "SS_IdleCombat"]
var atem = null

func _atem_an() -> void:
	if anim == null or OS.get_environment("ATEM_ALT") != "":     # Prüfschalter ATEM_ALT=1: wie vorher (Vergleichsfilm)
		return
	var sk := _find(model, "Skeleton3D") as Skeleton3D
	if fighter.monster != null:
		# 453 r2: der Kaufwolf atmet als Schicht unter jeder Bewegung, je Wolf eigener Takt (atem_tier.gd)
		var Tier = preload("res://kampf/atem_tier.gd")
		if sk != null and Tier.passt(sk):
			atem = Tier.new()
			atem.name = "Atem"
			atem.eigen(hash(String(fighter.id)))
			sk.add_child(atem)
		return
	if not kauf:
		return
	if sk == null or sk.find_bone("spine_03") < 0:
		return
	for n in ATEM_RUHE:
		if anim.has_animation(n):
			_ohne_atem(anim.get_animation(n))
	atem = preload("res://kampf/atem.gd").new()
	atem.name = "Atem"
	atem.eigen_kampf(hash(String(fighter.id)))     # 453.1 Feld 2: im Kampf „einen Tick schneller“, Steigerung sichtbar
	atem.ausgleich = true     # 453.1 (Chef 19:5x): der fernere Held atmet im Bild so deutlich wie der nähere
	sk.add_child(atem)


## jede Spur hält ihren ersten Schlüssel (die Bibliothek gehört nur dieser Figur, HeldFigur.baue und _kaufheld kopieren)
static func _ohne_atem(an: Animation) -> void:
	for t in an.get_track_count():
		var ty := an.track_get_type(t)
		if ty != Animation.TYPE_ROTATION_3D and ty != Animation.TYPE_POSITION_3D:
			continue
		while an.track_get_key_count(t) > 1:
			an.track_remove_key(t, an.track_get_key_count(t) - 1)


## 453.1: nach Angriff, Ausweichen, Treffer schneller und tiefer atmen, dann abklingend (atem.gd)
func _schnaufen(wie_sehr: float) -> void:
	if atem != null:
		atem.anstrengen(wie_sehr)


## 438: Ruhe nach Treffer oder Ausweichen nur, wenn es nicht unterwegs ist (sonst glitt es in Stehen weiter)
func _idle_wenn_frei() -> void:
	if weg.is_empty() or not lunging():
		_idle()


## 406 (Chef 01.11., 13:0x, Archiv 406: neu mit Sword & Shield; 13:1x: „Sein Schild hängt drunter … reißt dann das Schild hoch“):
## der Kaufheld mit Schild (Klinge oder Stab) kämpft mit dem gekauften Satz „Sword & Shield“ (held_kampf.py, Vorsilbe SS_): steht in
## Kampfhaltung mit erhobenem Schild, wehrt mit dem Schild ab, geht und rennt mit Schild. OHNE_SS=1: wie vorher (Vergleich)
func _ss() -> bool:
	return kauf and anim != null and anim.has_animation("SS_IdleCombat") and _schild() != "" and OS.get_environment("OHNE_SS") == ""


## 406: Gehen, Rennen, rückwärts gehen mit Schild, wenn der Satz da ist
func _gang_ss(nm: String) -> String:
	var g: String = {"Gehen": "SS_WalkForward", "Rennen": "SS_RunForward", "Zurück": "SS_WalkBackwards"}.get(nm, nm)
	return g if _ss() and anim.has_animation(g) else nm


var _schleifen := 0     # 453 r3: wie oft die Grundschleife neu begann (Versatz je Wolf, für Prüfläufe fest)

func _idle() -> void:
	if down:
		return
	if _ss():
		_play("SS_IdleCombat", 0.2)
		return
	if kauf and anim and anim.has_animation("Kampfstehen") and not _stab():
		# 403: die Klinge liegt im Faustloch wie in kampf.py; in Stehen (UAL) zeigte sie waagerecht nach vorn auf Hüfthöhe
		# (DESIGN-ABNAHME Silhouetten); Kampfstehen ist das erste und letzte Bild jeder Kampfbewegung
		_play("Kampfstehen")
		return
	var grund := "Hocke" if pouncing else "Stehen"
	# 453 r2: Hocke ↔ Stehen und aus einer Ruhebewegung weich (RUHE_BLENDE), alles andere wie bisher
	var von: String = anim.current_animation if anim else ""
	_play(grund, RUHE_BLENDE if (von in RUHE or von in RUHE_GESTEN) else 0.15)
	# 453 r3 (Prüfer Film r2: Umblicken und Knurren im selben Bild; gemessen tests/atem_bild_453.gd: alle Wölfe in Hocke bei 1,13 s
	# ihrer Schleife): die Grundschleife selbst blickt um (Stehen = IdleA) oder wendet den Kopf (Hocke = IdleC); beginnt sie neu, dann
	# je Wolf an anderer Stelle, sonst wendet das Rudel im Gleichtakt
	# 506 t274.14 (Chef 10.11., 13:16: Skelette „im Gleichklang“; skelett_506: alle drei bei 0,76 s): lief die Grundschleife schon vor
	# dem ersten _idle (Aufstellung), sprang sie nie; beim ersten Mal darum immer versetzt
	if fighter.monster != null and (von != grund or _schleifen == 0) and anim and anim.has_animation(grund):     # 348.12 Lauf 172: Figuren ohne Modell (Kampfort ohne Bild) haben kein anim
		var lang: float = anim.get_animation(grund).length
		var z := RandomNumberGenerator.new()
		z.seed = hash("%s/%s/%d" % [fighter.id, grund, _schleifen])
		_schleifen += 1
		anim.seek(_versatz_frei(grund, lang, z.randf() * lang), true)


## 1006 (skelett_506 Lauf 361, 365: Stehen bei 0,38 und 0,42 s): der Zufall des Versatzes traf beim neuen Anfang der Schleife fast
## die Stelle eines anderen Skeletts (Schleife 1,03 s, Abstand 0,04 s, also im Gleichklang). Liegt [t0] näher als VERSATZ_MIN der
## Schleife an der Stelle eines anderen, der dieselbe Grundschleife gleich lang spielt, dann in Zwölfteln weiter zur ersten freien
## Stelle (keine frei: die mit dem größten Abstand)
const VERSATZ_MIN := 0.15
func _versatz_frei(grund: String, lang: float, t0: float) -> float:
	if kampfort == null or lang <= 0.0:
		return t0
	var stellen: Array[float] = []
	for o in kampfort.figures.values():
		if o == self or o.down or o.anim == null or o.anim.current_animation != grund:
			continue
		if not o.anim.has_animation(grund) or absf(o.anim.get_animation(grund).length - lang) > 0.01:
			continue
		stellen.append(o.anim.current_animation_position)
	if stellen.is_empty():
		return t0
	var best := t0
	var best_d := -1.0
	for k in 12:
		var t := fposmod(t0 + lang * k / 12.0, lang)
		var d := lang
		for s in stellen:
			var u := absf(t - s)
			d = minf(d, minf(u, lang - u))
		if d >= VERSATZ_MIN * lang:
			return t
		if d > best_d:
			best_d = d
			best = t
	return best


# Prüfer Runde 25: Blick und Rumpf wurden nur bei der Ansage gerichtet; rückte das Ziel danach auf seinen Platz, sah der Wolf
# daneben (Hals 52° bei Ziel 35°). In Ruhe darum jedes Bild neu.
func _process(_dt: float) -> void:
	_shake()
	if not paws.is_empty():
		_paw_shadow_update()
	_schritt_sync(_dt)
	if aim != null and neck and not down and not (tween and tween.is_running()) and not bedroht():
		if halt != null or TURN_DPS_ART.has(art()):     # 595: die Schnecke dreht langsam, nie in einem Bild
			_face_sanft()
		else:
			_face()
	# Drehung abgebrochen (Biss tötet den tween); 387 r4 (Hülle Keiler r4: nach einem abgebrochenen Umdrehen hielt der Pfotenhalt die
	# Pfoten 1,1 s lang im Rennen fest, der Körper lief weiter): auch, sobald das Tier etwas anderes spielt als Stehen
	if halt and halt.drehen and (not (tween and tween.is_running()) or anim and anim.current_animation != "Stehen"):
		halt.los(false)
	_ruhebewegung()


## 453 (Chef 01.11., 11:05: „Was mir aber völlig fehlt, sind diese Ruheanimationen. Also ich weiß nicht, ob die Wölfe atmen, ob die
## mal ab und zu scharren oder sich umblicken oder knurren. Sozusagen, da muss mehr Leben rein.“; wolf_ruhe_453: die Wölfe ruhten zu
## 96 % in Hocke, dort gab es keine): wer daheim ruht, spielt alle RUHE_MS eine Ruhebewegung seiner Grundhaltung, nie zweimal
## dieselbe hintereinander; nach dem eigenen Angriff zuerst Hecheln. Knurren und Hecheln mit dem Ruhelaut des Wolfs (idle_wolf_2
## Knurren, idle_wolf_3 Schnauben; tools/klang/ruhe.py), höchstens einer zugleich im Rudel (RUHE_LAUT_ABSTAND_MS wie MonsterIdle.GAP_MS).
## 595 (Chef 05.11., 19:2x, Build 266: „Säureschnecke – … Ruheanimationen?, Atmen?“; LISTE-BESTAND: Schnecke IdleLookAround, Egel
## Idle_02, Idle_03, im Kampf nie gespielt, nur der Wolf und wer „Lefzen“ hat ruhte mit Gesten): „Umsehen“ der Quelle gehört zu den
## Ruhebewegungen im Stehen; dazu je Art, was nur sie hat (RUHE_DAZU). Spinne, Ratte, Wolf und Grabhund bleiben wie abgenommen, nur der
## Grabhund blickt jetzt auch um (seine Quelle idleLookAround)
## 744 (Kampfort, Chef 20:05 „weiter mit dem Kampfort“; ruhe_kampf_744: Wiedergänger 22 s ohne Ruhebewegung): auch „Lauern“ (idle5 der
## Quelle, kaufuntoter.py) gehört dazu
const RUHE := {"Stehen": ["Lefzen", "Scharren", "Knurren", "Umsehen", "Lauern"], "Hocke": ["HockeKnurren", "HockeUmsehenL", "HockeUmsehenR"]}
const RUHE_DAZU := {"kauf_egel": ["Drohen"]}
const RUHE_HECHELN := {"Stehen": "Hecheln", "Hocke": "HockeHecheln"}
const RUHE_GESTEN := ["Lefzen", "Scharren", "ScharrenR", "Knurren", "Hecheln", "HockeKnurren", "HockeUmsehenL", "HockeUmsehenR", "HockeHecheln",
	"Umsehen", "Drohen", "Lauern"]
const RUHE_MS := [3000, 7000]
const RUHE_LAUT := {"Knurren": [1, 0.4], "HockeKnurren": [1, 0.4], "Hecheln": [2, 0.3], "HockeHecheln": [2, 0.3]}
const RUHE_LAUT_ABSTAND_MS := 1800
static var ruhe_laut_ms := -100000
## 453 r2 (Chef 01.11., 13:0x: „dass die Wölfe nicht im Gleichtakt Dinge tun“): nie zwei Ruhebewegungen im Rudel zugleich beginnend;
## wer zu früh dran ist, wartet um RUHE_VERSATZ_MS weiter. Übergang Grundhaltung ↔ Geste und Hocke ↔ Stehen weich (Prüfer r1: 0,13 s ruckartig)
const RUHE_ABSTAND_MS := 900
const RUHE_VERSATZ_MS := [500, 1400]
const RUHE_BLENDE := 0.4
var ruhe_vor := ""
var nach_biss := false      # 453: nach dem eigenen Angriff zuerst Hecheln


## 900 (wolf_mess_438, Lauf 335 mit dem BRS-Kampf: der Held trat an einen kauernden Wolf, der sich währenddessen nach ihm drehte
## (44° in Hocke) oder eine Ruhebewegung begann (HockeUmsehenR, HockeKnurren): Schild 0,14 m, Klinge 0,12 m im Wolf, der Stand galt
## für die Haltung beim Planen): wer zum Ziel eines Hiebs wird, dreht sich bis zu dessen Ende nicht und beginnt keine Ruhebewegung;
## eine laufende endet weich in der Grundhaltung. Der Stand gilt für den Körper jetzt und die ganze Grundschleife (koerper_ruhe)
var bedroht_bis := -1
func bedroht() -> bool:
	return bedroht_bis >= 0 and _ruhe_uhr() < bedroht_bis


func halt_fuer_hieb(ms: int) -> void:
	bedroht_bis = _ruhe_uhr() + ms
	fidget_at = 0
	if anim and fighter.monster != null and String(anim.current_animation) in RUHE_GESTEN:
		var grund := "Hocke" if pouncing else "Stehen"
		if anim.has_animation(grund):
			_play(grund, RUHE_BLENDE)


## 900: der Körper als Ziel eines Hiebs wie koerper(), dazu die ganze Grundschleife (Hocke wendet den Kopf, Stehen blickt um) in
## RUHE_PROBEN Haltungen; danach läuft die Bewegung weiter, wo sie war
const RUHE_PROBEN := 6
func koerper_ruhe() -> Array:
	var ks: Array = koerper()
	if fighter.monster == null or anim == null or down:
		return ks
	var grund := "Hocke" if pouncing else "Stehen"
	var sk := _find(model, "Skeleton3D") as Skeleton3D if model else null
	if sk == null or not anim.has_animation(grund):
		return ks
	var vor := String(anim.current_animation)
	var vor_t: float = anim.current_animation_position if vor != "" else 0.0
	var vor_v: float = anim.get_playing_speed() if vor != "" else 1.0
	var l: float = anim.get_animation(grund).length
	anim.play(grund, 0.0)
	for i in RUHE_PROBEN:
		anim.seek(l * i / float(RUHE_PROBEN), true)
		sk.force_update_all_bone_transforms()
		ks.append_array(koerper())
	if vor != "":
		anim.play(vor, 0.0, vor_v)
		anim.seek(vor_t, true)
	sk.force_update_all_bone_transforms()
	return ks


func _ruhe_uhr() -> int:
	return int(kampfort.clock_ms) if kampfort != null and "clock_ms" in kampfort else Time.get_ticks_msec()


func _ruhebewegung() -> void:
	if anim == null or down or not (anim.has_animation("Lefzen") or anim.has_animation("Umsehen") or anim.has_animation("Lauern")) or bedroht():
		return
	var grund: String = anim.current_animation
	if not RUHE.has(grund) or grund != ("Hocke" if pouncing else "Stehen") or (tween and tween.is_running()):
		return
	var now := _ruhe_uhr()
	var hecheln := nach_biss and anim.has_animation(RUHE_HECHELN[grund])
	if hecheln and fidget_at == 0:
		fidget_at = now + 300
	elif fidget_at == 0:
		fidget_at = now + randi_range(RUHE_MS[0], RUHE_MS[1])
	if now < fidget_at:
		return
	var zuletzt: int = int(kampfort.get_meta("ruhe_beginn_ms", -100000)) if kampfort != null else -100000     # je Kampfort, nicht je Spiel
	if now - zuletzt < RUHE_ABSTAND_MS:
		fidget_at = now + randi_range(RUHE_VERSATZ_MS[0], RUHE_VERSATZ_MS[1])
		return
	fidget_at = 0
	nach_biss = false
	var wahl: String = RUHE_HECHELN[grund] if hecheln else ""
	if wahl == "":
		var da: Array = (RUHE[grund] + (RUHE_DAZU.get(art(), []) if grund == "Stehen" else [])).filter(
			func(n): return anim.has_animation(n if n != "Scharren" else scharren_name()))
		var liste: Array = da.filter(func(n): return n != ruhe_vor)
		if liste.is_empty():     # 595: wer nur eine Geste hat (Schnecke: Umsehen), wiederholt sie, statt nach der ersten für immer zu ruhen
			liste = da
		if liste.is_empty():
			return
		wahl = String(liste[randi_range(0, liste.size() - 1)])
	ruhe_vor = wahl
	if kampfort != null:
		kampfort.set_meta("ruhe_beginn_ms", now)
	if wahl == "Scharren":
		wahl = scharren_name()
	_play(wahl, RUHE_BLENDE)
	anim.set_blend_time(wahl, grund, RUHE_BLENDE)
	anim.queue(grund)
	# 1007: auf der Karte nur nah zu hören (Streuner.Stub.ruhe_pegel wie alt MonsterIdle.volume); stumm zählt nicht als Laut
	var pegel: float = float(RUHE_LAUT.get(wahl, [0, 0.0])[1])
	if pegel > 0.0 and kampfort != null and kampfort.has_method("ruhe_pegel"):
		pegel *= float(kampfort.ruhe_pegel(global_position))
	if RUHE_LAUT.has(wahl) and pegel > 0.0 and now - ruhe_laut_ms >= RUHE_LAUT_ABSTAND_MS:
		var klang = get_node_or_null("/root/Klang")
		if klang != null:
			ruhe_laut_ms = now
			klang.effekt("idle_wolf", pegel, 1.0, int(RUHE_LAUT[wahl][0]))


## 249 (wie im alten MARS): der Getroffene zittert seitlich am Schirm, 4 dp, in 450 ms abklingend.
func _shake() -> void:
	if hurt_at < 0.0:
		return
	var h: float = 1.0 - (kampfort.clock_ms - hurt_at) / 450.0
	if h <= 0.0:
		hurt_at = -1.0
		model.position = model_rest
		return
	var dx: float = sin(kampfort.clock_ms / 30.0) * 4.0 * h * kampfort.m_per_dp(global_position)
	model.position = model_rest + global_transform.basis.inverse() * Vector3(dx, 0, 0)


func snap_to(p: Vector3) -> void:
	home = p
	position = p


## 399.2a: läuft vom Kampfort weg (fällt sein Leitwolf, fliehen die Jungwölfe) und verschwindet hinter dem Bildrand
var flieht := false     # 717: nur auf der Flucht zeigt ein Gegner dem Helden den Rücken
func flee_off(away: Vector3) -> void:
	announce(null)
	flieht = true
	glide_to(home + away * 9.0)
	get_tree().create_timer(3.0).timeout.connect(func(): visible = false)


## 438 (Chef 31.10., 23:31, Film 403: die Wölfe „wie als ob sie wieder gleiten würden“; Messung tests/wolf_mess_438.gd): der Rumpf
## fuhr mit vollem Tempo los und hielt schlagartig, während die Bewegung erst einblendete; alle vier Pfoten rutschten dann 16 cm je
## Bild. Jetzt fährt jeder Lauf an und bremst (RAMPE_S), und Gehen und Rennen spielen in dem Tempo, in dem sich der Rumpf gerade
## bewegt (_schritt_sync): die Pfoten bleiben am Boden.
const RAMPE_S := 0.35
## 438: so nah und hinter ihm geht ein Tier rückwärts heim, das Gesicht zum Gegner, statt zweimal 180° auf der Stelle zu drehen (m),
## im RUECK_TEMPO seines Gehens
const RUECK_M := 4.0
const RUECK_TEMPO := 0.8
var _sync_vor := Vector3.INF


## Hängt an [tw] einen Lauf von [von] nach [nach] im Tempo von [nm] (mal [k]) an: anfahren, gleichmäßig, bremsen; gibt die Dauer zurück
func _lauf(tw: Tween, von: Vector3, nach: Vector3, nm: String, k := 1.0) -> float:
	var s := Vector2(nach.x - von.x, nach.z - von.z).length()
	var v := maxf(_mps(nm) * k, 0.05)
	if s < 0.01:
		tw.tween_callback(func(): position = nach)
		return 0.0
	var r := minf(RAMPE_S, s / v)
	var t := s / v + r
	tw.tween_method(func(x: float): position = von.lerp(nach, _rampe(x, t, r)), 0.0, t, t)
	return t


## Anteil des Wegs nach [x] s, wenn über [r] s gleichmäßig angefahren und am Ende ebenso gebremst wird (Gesamtzeit [t])
static func _rampe(x: float, t: float, r: float) -> float:
	var v := 1.0 / maxf(t - r, 1e-4)
	if x <= r:
		return 0.5 * v / r * x * x
	if x >= t - r:
		var y := t - x
		return 1.0 - 0.5 * v / r * y * y
	return 0.5 * v * r + v * (x - r)


## 438: Gehen und Rennen im Tempo des Rumpfs (Tempo der Bewegung = Weg je Sekunde / Weg der Schleife), sonst Tempo 1
var _sync_v := 0.0     # 438: Tempo des Rumpfs im letzten Bild (m/s)
## 560 (Chef 08.11., 20:47, t270.7: Grimmzahn „dreht auf der Stelle wie ein Zinnsoldat“): auf der Karte (Ersatz-Kampfort Streuner.Stub)
## traegt ein anderer Knoten die Figur (streuner.gd, leute.gd Grimmzahn) und stellt das Tempo selbst (Tritte beim Wenden, Schrittzeit);
## die Figur steht in ihm still, hier gemessen 0 m/s, und bremste jedes Gehen auf 0,15 (tests/tritte_560.gd)
func _schritt_sync(dt: float) -> void:
	if anim == null or weg.is_empty() or down or dt <= 0.0 or kampfort is Streuner.Stub:
		return
	var cur := String(anim.current_animation)
	if cur in ["Gehen", "Rennen"] and weg.has(cur) and _sync_vor != Vector3.INF:
		var v := Vector2(position.x - _sync_vor.x, position.z - _sync_vor.z).length() / dt
		# 438 (wolf_mess_438: „Rennen zu schnell“ 0,67 m, je im ersten Bild des Anlaufens, Tempo 0,15 bei schon 5 cm Weg): die
		# Bahn läuft erst nach diesem Aufruf weiter, das Tempo hinkte ein Bild nach; beim Beschleunigen um die Änderung voraus
		var v_vor := _sync_v
		_sync_v = v
		if v > v_vor:
			v += v - v_vor
		var base := _mps(cur) / float(tempo.get(cur, 1.0))
		var custom := absf(anim.get_playing_speed() / anim.speed_scale) if anim.speed_scale != 0.0 else 1.0
		anim.speed_scale = clampf(v / maxf(base, 0.05) / maxf(custom, 0.05), 0.15, 1.6)
	elif anim.speed_scale != 1.0:
		anim.speed_scale = 1.0
		_sync_v = 0.0
	else:
		_sync_v = 0.0
	_sync_vor = position


## 438 (Messung: der Rumpf sprang in Ruhe bis 20° in einem Bild, wenn das Ziel wechselte): in Ruhe dreht ein Tier mit Pfotenhalt
## mit Tritten zur Blickrichtung von _face(), kleine Winkel nach und nach
const DREH_RUHE := 8.0
func _face_sanft() -> void:
	var r0 := rotation.y
	_face()
	var dw := wrapf(rotation.y - r0, -PI, PI)
	rotation.y = r0
	if absf(rad_to_deg(dw)) < 0.5:
		rotation.y = r0 + dw
	elif absf(rad_to_deg(dw)) >= DREH_RUHE:
		# 438 (wolf_mess_438: Wolf 3 drehte in Ruhe 82° zu seinem Ziel und schwenkte den Rumpf in den Anlauf von Wolf 1): nur, wenn
		# der Rumpf dabei frei bleibt, auch gegen die Bahnen der Laufenden; sonst blickt nur der Hals (neck.want)
		if _foot_ok and (_rumpf_luft(position, r0 + dw) < minf(_rumpf_luft(position, r0), PLATZ_LUFT) \
				or _rumpf_luft(position, r0 + dw * 0.5) < minf(_rumpf_luft(position, r0), PLATZ_LUFT)):
			return
		gang = "dreh"
		dreh_ziel = r0 + dw
		tween = create_tween()
		# 623.5 (effekt_mess_6235: „Nonexistent function 'an' in base 'Nil'“): auch der Held ohne Pfotenhalt kommt hierher (abwehr)
		tween.tween_callback(func(): if halt: halt.an())
		tween.tween_property(self, "rotation:y", r0 + dw, absf(rad_to_deg(dw)) / float(TURN_DPS_ART.get(art(), TURN_DPS_TRITT)))
		tween.tween_callback(func():
			if halt: halt.los(true)
			gang = "")
	else:
		rotation.y = r0 + clampf(dw, -deg_to_rad(40.0) * get_process_delta_time(), deg_to_rad(40.0) * get_process_delta_time())


## Läuft gerade nur das Ausrichten in Ruhe? Dann darf jeder andere Auftrag es abbrechen
func _nur_dreh() -> bool:
	return gang == "dreh" and tween != null and tween.is_running()


func _dreh_ab() -> void:
	if _nur_dreh():
		tween.kill()
		if halt:
			halt.los(false)
		gang = ""


func glide_to(p: Vector3, eigener_zug := false) -> void:
	if p.is_equal_approx(home):
		return
	home = p
	# 717.1 A (F8): ein Gegner rückt erst in seinem eigenen Zug an den neuen Platz (zurueck_in_reihe), nicht mitten im Zug eines anderen
	if _bleib_717() and (not eigener_zug or _platz_besetzt()):
		platz_neu = true
		return
	_dreh_ab()
	if tween and tween.is_running():
		# 717 C (wolf_mess_438: Wolf 1 rückte zu seinem alten Platz, im selben Augenblick tauschte Wolf 3 mit ihm, er kam vorn an, sein
		# neuer Platz war hinten): wer gerade in die Reihe rückt, geht gleich zum neuen Platz
		if _bleib_717() and gang == "heim" and weg.has("Gehen") and not down:
			tween.kill()
			_walk_home()
		return     # a lunge brings it back to its new home
	if weg.has("Gehen") and not down:
		_walk_home()
		return
	var t := create_tween()
	t.tween_property(self, "position", p, GLIDE_S).set_trans(Tween.TRANS_SINE)


func _weg() -> Dictionary:
	var p := _model_path()
	if fighter.monster == null:
		return {}
	var ia := _gob_art() if _zweibeiner() else art()     # 348.12: Grak (grak_gestalt.py) hat seinen Weg in hobgoblin_captain-info.json
	if ia == "" and not _kauf_felle(Mars.koerper_of(fighter.monster)).is_empty():     # 494 Riesenspinne (kaufspinne.py): Weg in <id>-info.json
		ia = Mars.koerper_of(fighter.monster)
	var ip := "res://kampf/daten/%s-info.json" % ia
	if ia == "" or not FileAccess.file_exists(ip):
		return {}
	var j = JSON.parse_string(FileAccess.get_file_as_string(ip))
	var fell := p.get_file().get_basename().get_slice("-", 1)
	if j is Dictionary and j.get(fell) is Dictionary and j[fell].get("weg") is Dictionary and not j[fell].weg.is_empty():
		weg_fps = float(j[fell].get("fps", 30.0))
		if j[fell].get("biss") is Array:
			bite = {"Biss": j[fell].biss}
		# 595 (Chef 05.11., 19:2x, Build 266: „Animation Spinne sehr gut, gibt es mehr Angriffsbewegungen/Abwechslung?“): die Bisskette
		# der Spinne (kaufspinne.py „biss_je“, Kieferklauen gemessen) steht um den gemessenen Unterschied zum Biss anders, der Biss selbst
		# bleibt wie abgenommen
		var bj = j[fell].get("biss_je")
		if bj is Dictionary and bj.get("Biss") is Array and bj.get("Bisskette") is Array and bite.has("Biss"):
			var b0: Array = bite["Biss"]
			bite = bite.duplicate()
			bite["Bisskette"] = [float(b0[0]) + float(bj.Bisskette[0]) - float(bj.Biss[0]), float(bj.Bisskette[1]),
				float(b0[2]) + float(bj.Bisskette[2]) - float(bj.Biss[2])]
		if j[fell].get("hieb") is Array:
			hieb = j[fell].hieb
		if j[fell].get("tempo") is Dictionary:
			tempo = j[fell].tempo
		for k in ["breite_m", "laenge_m", "koerper_hoch_m", "hoehe_m"]:
			if (art().begins_with("kauf_") or art() == "") and j[fell].get(k) != null:     # 494: auch die gekaufte Spinne
				mass[k] = float(j[fell][k])
		return j[fell].weg
	return {}


## Ort auf dem Wurzelweg [nm] nach [t] s, ab [o] mit der Drehung [b]; [k] dehnt den Weg (Sprungbiss auf die Strecke)
func _weg_at(o: Vector3, b: Basis, nm: String, t: float, k := 1.0) -> Vector3:
	var w: Array = weg[nm]
	var f := clampf(t * weg_fps, 0.0, w.size() - 1.0)
	var i := int(f)
	var j := mini(i + 1, w.size() - 1)
	var x: float = lerpf(w[i][0], w[j][0], f - i)
	var z: float = lerpf(w[i][1], w[j][1], f - i)
	return o + b * (Vector3(x, 0.0, z) * model.scale.x * k)


## Länge des Wurzelwegs (m in der Welt) und Tempo einer Schleife (m/s)
func _weg_len(nm: String) -> float:
	var e: Array = weg[nm][-1]
	return Vector2(e[0], e[1]).length() * model.scale.x


func _mps(nm: String) -> float:
	return _weg_len(nm) / maxf((weg[nm].size() - 1) / weg_fps, 0.1) * float(tempo.get(nm, 1.0))


## 506.1: Tempo (m/s) auf einem langen Anmarsch (Gehen oder Rennen wie _gangart), 0 ohne Wurzelweg (Figur ohne Kaufmodell)
func anmarsch_mps() -> float:
	if fighter == null or fighter.monster == null or weg.is_empty() or model == null:
		return 0.0
	var nm := _gangart(RUN_FROM + 1.0)
	return _mps(nm) if weg.has(nm) and weg[nm].size() > 1 else 0.0


## 348.12 (Chef 29.10., 10:55: Grak „gut, aber Gang schreitend statt kurzer Sprint“): weiter als RUN_FROM rennt ein Tier
## (Rennen), ein Zweibeiner mit Wurzelweg (Grak) schreitet immer (Gehen); Ausweichen bleibt ein Satz im Lauf.
func _gangart(way: float) -> String:
	return "Rennen" if way > RUN_FROM and weg.has("Rennen") and not _zweibeiner() else "Gehen"


## 348.12f: geht (weiter als RUN_FROM: rennt) heim im Tempo des Wurzelwegs, die Pfoten gleiten nicht; dort wieder zum Ziel.
## Ortmess Lauf 148: vor dem Loslaufen und nach der Ankunft drehte es in einem Bild (bis 178°); jetzt dreht es mit Schritten
## (Gehen) mit TURN_DPS; r3: auf dem Pfad von _heimweg() ohne Drehen auf der Stelle. Gibt die Dauer (s) zurück.
func _walk_home(skip = null) -> float:
	var d := home - position
	d.y = 0.0
	if d.length() < 0.12:
		position = home
		return _turn_home()
	if not HEIMWEG_BOGEN:
		# 399.2 (Chef 28.10., 16:10: „dann läuft der hintere Wolf durch den vorderen“): um die anderen herum wie die Heldin
		var via := _detour(position, home, skip)
		var way := d.length() if via == position else position.distance_to(via) + via.distance_to(home)
		# 438 (wolf_mess_438, Kleriker 55 s: Wolf 3 lief nach dem Biss heim, während Wolf 1 diesen Platz noch rückwärts räumte;
		# beide 0,2 m ineinander): führt jeder Weg durch einen anderen, der gerade selbst läuft, wartet er kurz und plant neu
		if fighter.monster != null and _warte_n < WARTE_MAX:
			var g := _seg_gap(position, home, skip) if via == position else minf(_seg_gap(position, via, skip), _seg_gap(via, home, skip))
			# 717 C (wolf_mess_438, Kleriker 41,7 s: beim Platztausch gingen beide zugleich los, das Gesicht zum Helden, und kreuzten sich
			# 15 cm tief): wer mit mir tauscht und schon geht, geht zuerst
			var tauscht: bool = _bleib_717() and kampfort.figures.values().any(func(o): return o != self and o.visible and not o.down and o.unterwegs() \
					and o.gang == "heim" and Vector2(o.home.x - position.x, o.home.z - position.z).length() < 0.6)
			# (wolf_mess_438, Kleriker 42,2 s: Wolf 3 ging 21 cm an der Bahn des beißenden Wolfs 1 vorbei, der dann genau dorthin absetzte):
			# solange einer beißt und seine Bahn nah ist, wartet er
			var beisst_nah: bool = _bleib_717() and g < 0.3 and kampfort.figures.values().any(func(o): return o != self and o.visible and not o.down \
					and o.unterwegs() and o.gang in ["anlauf", "hieb", "hin"])
			if (g < 0.0 or tauscht or beisst_nah) and kampfort.figures.values().any(func(o): return o != self and o.visible and not o.down and o.unterwegs()):
				_warte_n += 1
				_dreh_ab()
				tween = create_tween()
				tween.tween_callback(_idle_wenn_frei)
				tween.tween_interval(WARTE_S)
				tween.tween_callback(func(): _walk_home(skip))
				return WARTE_S
		_warte_n = 0
		_dreh_ab()
		bahn = [home] if via == position else [via, home]
		tween = create_tween()
		# 438 (wolf_mess_438, Kämpfer 44 s: rückwärts zum Umweg quer zur Blickrichtung, 1,7 m seitwärts, das Heck 0,2 m in Wolf 2):
		# rückwärts nur, wenn auch jeder Abschnitt hinter ihm liegt
		var rueck := _rueckwaerts(position, home, way)
		if rueck and via != position and not (_rueckwaerts(position, via, way) and _rueckwaerts(via, home, way)):
			# … es sei denn, das Umdrehen am Ort führte den Rumpf durch einen anderen (dann doch rückwärts)
			var first0 := via - position
			rueck = _dreh_luft(rotation.y, atan2(first0.x, first0.z)) < PLATZ_LUFT
		# 562 (wolf_mess_438 Kleriker, Bild 2851, nachgestellt am Rechner: Wolf 3 ging rückwärts heim, 40° schräg zur eigenen Achse,
		# und schob das Heck 0,13 m in Wolf 1; _seg_gap rechnet den Rumpf längs des Wegs): rückwärts behält er seine Drehung, darum
		# den Umriss in dieser Drehung über den Weg schieben; ginge er dabei durch einen anderen, rückwärts um ihn herum, sonst drehen,
		# wenn das nicht enger wird
		# 717 (Chef 09.11., 08:51: „dreht mir nur den Rücken zu, wenn es fliehen will … ansonsten weicht es zurück und das macht es
		# rückwärts … Oder eben stehen bleiben nach dem Angriff, wo man war“; F7): ein Gegner geht heim, das Gesicht zum Helden, vorwärts
		# oder rückwärts je nach Lage des Platzes; ist auch das nicht frei, bleibt er stehen, wo er ist
		if fighter.monster != null and not flieht and weg.has("Gehen"):
			var rl7 := _rueck_luft(position, via, home, skip)
			# (wolf_mess_438, Kleriker 42,2 s: stand er am Start schon knapp an der Bahn eines Beißenden, erlaubte „nicht enger als am
			# Start“ 12 cm Wolf in Wolf): nie tiefer als 2 cm; ist es enger und läuft ein anderer, erst warten
			var grenze7 := minf(WEG_LUFT, maxf(_rumpf_luft(position, rotation.y, skip) - 0.01, -0.02))
			if rl7 < grenze7 and _warte_n < WARTE_MAX and kampfort.figures.values().any(func(o): return o != self and o.visible and not o.down and o.unterwegs()):
				_warte_n += 1
				tween.kill()
				tween = create_tween()
				tween.tween_callback(_idle_wenn_frei)
				tween.tween_interval(WARTE_S)
				tween.tween_callback(func(): _walk_home(skip))
				return WARTE_S
			if rl7 < grenze7:
				var rv7 := _rueck_umweg(position, home, skip)
				if rv7 == position:
					tween.kill()
					if OS.get_environment("SCHAU_MESS") != "":
						print("717 %s bleibt stehen, %.2f m vom Platz" % [fighter.id, d.length()])
					return _turn_home()
				via = rv7
				bahn = [via, home]
			return _heim_mit_gesicht(via, skip)
		if rueck and fighter.monster != null:
			var rl := _rueck_luft(position, via, home, skip)
			if rl < minf(WEG_LUFT, _rumpf_luft(position, rotation.y, skip) - 0.01):
				var rv := _rueck_umweg(position, home, skip)
				if rv != position:
					via = rv
					bahn = [via, home]
				else:
					var f1 := (via if via != position else home) - position
					if _dreh_luft(rotation.y, atan2(f1.x, f1.z)) >= rl:
						rueck = false
		if rueck:
			# 438: rückwärts heim, das Gesicht zum Gegner; statt Kehrtwende, Lauf und zweiter Kehrtwende
			gang = "heim"
			tween.tween_callback(func(): anim.play("Gehen", 0.15, -float(tempo.get("Gehen", 1.0))))
			# 682 (kurven_682: das Umdrehen daheim zum Gegner, „heim/Stehen“, war mehr als die Hälfte allen Drehens am Ort, wie ein
			# Zinnsoldat): im Zurückgehen schon auf die Blickrichtung daheim eindrehen, daheim bleibt kein Rest
			var r0 := rotation.y
			var dw := wrapf(_blick_daheim() - r0, -PI, PI) if _glatt_an_682() else 0.0
			var t1 := _lauf(tween, position, via if via != position else home, "Gehen", RUECK_TEMPO)
			var t2 := 0.0
			if via != position:
				var vs := Vector2(via.x - position.x, via.z - position.z).length()
				var hs := Vector2(home.x - via.x, home.z - via.z).length()
				var anteil := vs / maxf(vs + hs, 0.01)
				if dw != 0.0:
					tween.parallel().tween_property(self, "rotation:y", r0 + dw * anteil, t1)
				t2 = _lauf(tween, via, home, "Gehen", RUECK_TEMPO)
				if dw != 0.0:
					tween.parallel().tween_property(self, "rotation:y", r0 + dw, t2)
			elif dw != 0.0:
				tween.parallel().tween_property(self, "rotation:y", r0 + dw, t1)
			tween.tween_callback(_turn_home)
			return t1 + t2
		var nm := _gangart(way)
		var first := via - position if via != position else d
		# 438 (wolf_mess_438, Kleriker 20 s: Wolf 3 drehte vor dem Umweg 128° auf der Stelle und schwenkte das Heck 0,18 m in
		# Wolf 2): führt die kurze Drehung durch einen anderen, dreht er andersherum, wenn es dort frei bleibt; sonst setzt er
		# erst ein Stück rückwärts ab (einmal je Heimweg) und dreht dort
		var lang := false
		if fighter.monster != null and _foot_ok:
			var y1 := atan2(first.x, first.z)
			var g0 := minf(_rumpf_luft(position, rotation.y, skip), PLATZ_LUFT)
			var kurz := _dreh_luft(rotation.y, y1)
			if kurz < g0 - 0.01:
				var dk := wrapf(y1 - rotation.y, -PI, PI)
				if _dreh_luft_bogen(rotation.y, dk - signf(dk) * TAU) >= g0 - 0.01:
					lang = true
				elif not _abgesetzt and weg.has("Gehen"):
					var zur := position - Vector3(basis.z.x, 0.0, basis.z.z).normalized() * ABSETZEN * _scale()
					if _rumpf_luft(zur, rotation.y, skip) >= g0 and _im_bild(zur, Vector3(basis.z.x, 0.0, basis.z.z)):
						_abgesetzt = true
						gang = "heim"
						bahn = [zur, home]
						tween.tween_callback(func(): anim.play("Gehen", 0.1, -float(tempo.get("Gehen", 1.0))))
						var ta := _lauf(tween, position, zur, "Gehen", RUECK_TEMPO)
						tween.tween_callback(func(): _walk_home(skip))
						return ta
				# … und geht auch das nicht: rückwärts heim, wenn die Heimat eher hinter ihm liegt (über 90°) und nah genug ist
				var fz := Vector3(basis.z.x, 0.0, basis.z.z)
				if weg.has("Gehen") and way <= RUECK_M and rad_to_deg(fz.angle_to(d)) > 90.0:
					gang = "heim"
					tween.tween_callback(func(): anim.play("Gehen", 0.15, -float(tempo.get("Gehen", 1.0))))
					var tr2 := _lauf(tween, position, via if via != position else home, "Gehen", RUECK_TEMPO)
					if via != position:
						tr2 += _lauf(tween, via, home, "Gehen", RUECK_TEMPO)
					tween.tween_callback(_turn_home)
					return tr2
		# 682: eine weiche Kurve heim statt Drehen am Ort, Gerade, Drehen am Umweg, Gerade (wenn sie frei bleibt)
		if _glatt_an_682() and fighter.monster != null:     # auch statt der langen Drehung (lang: über 180° am Ort)
			# 682 (kurven_682: 5 von 9 s Drehen am Ort waren das Umdrehen daheim zum Gegner, „heim/Stehen“): die Kurve läuft zuletzt
			# schon in Blickrichtung auf den Platz zu (ein Punkt LENK_VOR davor), dann bleibt daheim nur ein Rest für den Hals
			# (kurven_682: der Bogen hinter dem Platz streifte oft den Nachbarn, dann erst kürzer anlaufen, zuletzt ohne)
			var ziele: Array = [via] if via != position else []
			var blick := _blick_daheim()
			var kurve: Array = []
			for k in LENK_ANKUNFT:
				var z2 := ziele.duplicate()
				if k > 0.0 and way > LENK_VOR * _scale() * (k + 0.5):
					z2.append(home - Vector3(sin(blick), 0.0, cos(blick)) * LENK_VOR * _scale() * k)
				elif k > 0.0:
					continue
				kurve = _glatt(position, rotation.y, z2 + [home], skip)
				if not kurve.is_empty():
					break
			if not kurve.is_empty():
				gang = "heim"
				var tk := _glatt_an(tween, kurve, nm, AUSWEICH_BOGEN if nm == "Rennen" else BOGEN_TEMPO)
				tween.tween_callback(_turn_home)
				return tk
			# 682 (kurven_682: nach dem Biss drehte der Wolf 280–400° am Ort, weil die kurze Drehung den Gebissenen streifte und die
			# Kurve aus dem Gedränge nicht frei war): erst einen Schritt rückwärts vom Gebissenen weg, dann die Kurve heim
			# (Ratten: gerade zurück stand ein anderer, darum auch schräg zurück, wo mehr Luft ist)
			if (lang or absf(wrapf(atan2(first.x, first.z) - rotation.y, -PI, PI)) > deg_to_rad(80.0)) and not _abgesetzt and weg.has("Gehen"):
				var fz2 := Vector3(basis.z.x, 0.0, basis.z.z).normalized()
				var zur2 := position
				var luft2 := minf(_rumpf_luft(position, rotation.y, skip), PLATZ_LUFT)
				for w2 in [0.0, 35.0, -35.0]:
					var z3 := position - fz2.rotated(Vector3.UP, deg_to_rad(w2)) * ABSETZEN * _scale()
					var l3 := _rumpf_luft(z3, rotation.y, skip)
					if l3 >= luft2 and _im_bild(z3, fz2):
						zur2 = z3
						luft2 = l3
				if zur2 != position:
					_abgesetzt = true
					gang = "heim"
					bahn = [zur2, home]
					tween.tween_callback(func(): anim.play("Gehen", 0.1, -float(tempo.get("Gehen", 1.0))))
					var ta2 := _lauf(tween, position, zur2, "Gehen", RUECK_TEMPO)
					tween.tween_callback(func(): _walk_home(skip))
					return ta2
		var tt := _turn(tween, atan2(first.x, first.z), false, lang)
		tween.tween_callback(func(): _play(nm, 0.15))
		var tg := 0.0
		if via != position:
			var rest := home - via
			tg = _lauf(tween, position, via, nm)
			# 438: am Umweg mit Tritten weiterdrehen, nicht in einem Bild (vorher sprang die Richtung hier)
			var r1 := atan2(first.x, first.z)
			var r2 := atan2(rest.x, rest.z)
			var dw := wrapf(r2 - r1, -PI, PI)
			var td := absf(rad_to_deg(dw)) / _turn_dps()
			tween.tween_property(self, "rotation:y", r1 + dw, td)
			tween.tween_callback(func(): _play(nm, 0.1))
			tg += td + _lauf(tween, via, home, nm)
		else:
			tg = _lauf(tween, position, home, nm)
		tween.tween_callback(_turn_home)
		return tt + tg
	var pfad := _heimweg()
	var t := _pfad_fahren(pfad, false)
	tween.tween_callback(_turn_home)
	return t


## 438: geht es nach dem Biss (am Ort [von], Blick [dir] zum Ziel) rückwärts heim? Wie _rueckwaerts mit dem Umweg um die anderen
func _rueckwaerts_von(von: Vector3, dir: Vector3, skip) -> bool:
	if fighter.monster == null or _zweibeiner() or not weg.has("Gehen"):
		return false
	var vh := _detour(von, home, skip)
	var way := Vector2(home.x - von.x, home.z - von.z).length() if vh == von else von.distance_to(vh) + vh.distance_to(home)
	var d := Vector3(home.x - von.x, 0.0, home.z - von.z)
	if vh != von:     # 438: auch über den Umweg nur rückwärts, wenn beide Abschnitte hinter ihm liegen
		var d1 := Vector3(vh.x - von.x, 0.0, vh.z - von.z)
		var d2 := Vector3(home.x - vh.x, 0.0, home.z - vh.z)
		if rad_to_deg(dir.angle_to(d1)) <= 110.0 or d2.length() > 0.12 and rad_to_deg(dir.angle_to(d2)) <= 110.0:
			return false
	return way <= RUECK_M and d.length() > 0.12 and rad_to_deg(dir.angle_to(d)) > 110.0


## 438: geht es rückwärts heim? Nur Tiere, nah genug (RUECK_M) und hinter ihm (mehr als 110° von der Blickrichtung)
func _rueckwaerts(von: Vector3, nach: Vector3, way: float) -> bool:
	if fighter.monster == null or _zweibeiner() or not weg.has("Gehen") or way > RUECK_M:
		return false
	var d := Vector3(nach.x - von.x, 0.0, nach.z - von.z)
	return d.length() > 0.12 and rad_to_deg(Vector3(basis.z.x, 0.0, basis.z.z).angle_to(d)) > 110.0


## 348.12f r3 (Chef 27.10., 21:26, Archiv: offene Befunde der Ratte beheben; Prüfer Ratte r2 und Kaufwolf r1: beim Umdrehen auf
## der Stelle drehen die Pfoten 15–25 cm mit, ohne Schritt): der Heimweg ist ein Dubins-Pfad (Bogen, Gerade, Bogen) mit Wenderadius
## TURN_R mal Größe, der daheim schon in der Blickrichtung von _face() ankommt; kein Drehen auf der Stelle. Von den vier Arten (links
## oder rechts je Bogen) gilt die kürzeste, die den anderen nicht näher kommt als Start und Ziel; geht keine, ein kleinerer Radius.
## Erster Versuch (Bogen, dann kubische Kurve): die Kurve drehte daheim in den letzten 0,1 m um 140° (Ortmess). Je Punkt [Ort, Weg, Drehung].
const TURN_R := 0.55
## Fehlerprüfung r3c (Prüfer, 22:5x): im engen Kampfort fand der Pfad nach dem Biss nur Radius 0,16–0,20 m (175° in 0,23 s, schneller
## als vorher), beim Anlauf einen Kreis von 341°, beim Platzwechsel eine Schleife aus dem Bild: bis zur Lösung aus, Heimweg wie r2
const HEIMWEG_BOGEN := false
const PFAD_SCHRITT := 0.05
## so viel (m) darf der Pfad den anderen näher kommen als Start und Ziel (Ortmess r3a: mit 0,05 fand er nach dem Biss nur Radius 0,18 m,
## der Bogen beginnt vor der Heldin)
const PFAD_NAEHER := 0.3


func _heimweg() -> Array:
	var r0 := rotation.y
	var p0 := position
	position = home
	_face()     # Blickrichtung daheim: wie _face() sie dort setzt
	var ziel := rotation.y
	position = p0
	rotation.y = r0
	var g0 := minf(_rumpf_luft(p0, r0), _rumpf_luft(home, ziel)) - PFAD_NAEHER
	var best: Array = []
	var luft := -INF
	for k in [1.0, 0.5, 0.25]:
		var r: float = TURN_R * _scale() * k
		for art in ["LSL", "RSR", "LSR", "RSL"]:
			var pts := _dubins(p0, r0, home, ziel, r, art)
			if pts.is_empty():
				continue
			var g := INF
			for i in range(0, pts.size(), 3):
				g = minf(g, _rumpf_luft(pts[i][0], pts[i][2]))
			var gut: bool = g >= g0
			var lang: float = pts[pts.size() - 1][1]
			# gute Pfade nach Länge, sonst nach Luft
			var wert: float = (1000.0 - lang) if gut else g
			if wert > luft:
				luft = wert
				best = pts
				if OS.get_environment("SCHAU_MESS") != "":
					print("Heimweg %s Radius %.2f m, Länge %.2f m, Luft %.2f (Grenze %.2f)" % [art, r, lang, g, g0])
		if luft >= 900.0:
			break
	if best.is_empty():
		best = [[p0, 0.0, r0, "G"], [home, Vector2(home.x - p0.x, home.z - p0.z).length(), ziel, "G"]]
	return best


## Dubins-Pfad einer Art (L links, R rechts, S gerade) von (a, Drehung ya) nach (b, yb) mit Radius r; [] wenn es ihn nicht gibt.
## Rechnet in (x, z) mit dem Winkel th = PI/2 − Drehung (vorn = (cos th, sin th)); links heißt th wächst.
func _dubins(a: Vector3, ya: float, b: Vector3, yb: float, r: float, art: String) -> Array:
	var t1 := PI / 2.0 - ya
	var t2 := PI / 2.0 - yb
	var p1 := Vector2(a.x, a.z)
	var p2 := Vector2(b.x, b.z)
	var l1 := art[0] == "L"
	var l2 := art[2] == "L"
	var c1 := p1 + r * (Vector2(-sin(t1), cos(t1)) if l1 else Vector2(sin(t1), -cos(t1)))
	var c2 := p2 + r * (Vector2(-sin(t2), cos(t2)) if l2 else Vector2(sin(t2), -cos(t2)))
	var d := c2 - c1
	var dd := d.length()
	var al := atan2(d.y, d.x)
	var psi := al
	var gerade := dd
	if l1 != l2:
		if dd < 2.0 * r:
			return []
		psi = al + asin(2.0 * r / dd) * (1.0 if l1 else -1.0)
		gerade = sqrt(dd * dd - 4.0 * r * r)
	var b1 := fposmod(psi - t1, TAU) if l1 else fposmod(t1 - psi, TAU)
	var b2 := fposmod(t2 - psi, TAU) if l2 else fposmod(psi - t2, TAU)
	var gesamt := r * (b1 + b2) + gerade
	var pts: Array = []
	var n := maxi(2, int(gesamt / PFAD_SCHRITT))
	for i in n + 1:
		var s := gesamt * i / n
		var q: Vector2
		var th: float
		if s <= r * b1:
			var w := s / r * (1.0 if l1 else -1.0)
			th = t1 + w
			q = c1 + (p1 - c1).rotated(w)
		elif s <= r * b1 + gerade:
			th = psi
			var q1 := c1 + (p1 - c1).rotated(b1 * (1.0 if l1 else -1.0))
			q = q1 + Vector2(cos(psi), sin(psi)) * (s - r * b1)
		else:
			var w2 := (gesamt - s) / r * (1.0 if l2 else -1.0)
			th = t2 - w2
			q = c2 + (p2 - c2).rotated(-w2)
		pts.append([Vector3(q.x, a.y, q.y), s, PI / 2.0 - th, "G" if s > r * b1 and s <= r * b1 + gerade else "B"])
	return pts


var _pfad_anim := ""


## Neuer tween, der [pfad] abfährt: Bögen im Schritt (Gehen mal BOGEN_TEMPO; die Pfoten treten beim Wenden), Geraden über RUN_FROM
## im Lauf; [eilig]: alles im Lauf (Ausweichen). Gibt die Dauer (s) zurück; je Punkt hängt die Zeit an (pfad[i][4]).
func _pfad_fahren(pfad: Array, eilig: bool, bogen_im_lauf := 0.0) -> float:
	var gerade := 0.0
	for i in range(1, pfad.size()):
		if eilig:
			pfad[i][3] = "G"
		if pfad[i][3] == "G":
			gerade += pfad[i][1] - pfad[i - 1][1]
	var lauf := "Rennen" if (eilig or gerade > RUN_FROM or bogen_im_lauf > 0.0) and weg.has("Rennen") else "Gehen"
	_bogen_lauf = bogen_im_lauf if lauf == "Rennen" else 0.0
	var t := 0.0
	pfad[0].append(0.0)
	for i in range(1, pfad.size()):
		var v: float = _mps(lauf) if pfad[i][3] == "G" else (_mps(lauf) * _bogen_lauf if _bogen_lauf > 0.0 else _mps("Gehen") * BOGEN_TEMPO)
		t += (pfad[i][1] - pfad[i - 1][1]) / v
		pfad[i].append(t)
	_pfad_anim = ""
	tween = create_tween()
	tween.tween_method(func(x: float): _auf_zeit(pfad, x, lauf), 0.0, t, t)
	return t
## Bögen im Schritt, aber so viel schneller (Bewegung und Schrittfolge zugleich, die Pfoten treten weiter auf; r3b: im Schritt
## dauerte der Biss mit Heimweg 7,3 s statt 4,4 s)
const BOGEN_TEMPO := 1.8
## 546 (Chef 04.11., 00:01, Build 249: „Wölfe weichen aus wie Schlaftabletten“): der Satz beim Ausweichen lief seine Bögen im
## Schritt (Gehen × 1,8: 1,6 m in 0,93 s, ausweichen_546), ganz im Lauf drehte er bis 28° je Bild (438). Jetzt im Lauf mit diesem
## Anteil des Lauftempos auch im Bogen (Bewegung und Schrittfolge zugleich): 1,6 m in etwa 0,5 s, höchstens etwa 18° je Bild.
const AUSWEICH_BOGEN := 0.55
var _bogen_lauf := 0.0


## Ort und Drehung auf dem Pfad nach [t] s (Zeit je Punkt in pts[i][4]); wechselt zwischen Gehen (Bogen) und [lauf] (Gerade)
func _auf_zeit(pts: Array, t: float, lauf: String) -> void:
	var i := 1
	while i < pts.size() - 1 and pts[i][4] < t:
		i += 1
	var a: Array = pts[i - 1]
	var b: Array = pts[i]
	var f := clampf((t - a[4]) / maxf(b[4] - a[4], 1e-5), 0.0, 1.0)
	position = a[0].lerp(b[0], f)
	rotation.y = a[2] + wrapf(b[2] - a[2], -PI, PI) * f
	var nm: String = lauf if b[3] == "G" or _bogen_lauf > 0.0 else "Gehen"
	if nm + b[3] != _pfad_anim:     # Prüfer r3c: Gehen im Bogen und auf der Geraden hatten dieselbe Schrittfolge
		_pfad_anim = nm + b[3]
		if anim and anim.has_animation(nm):
			anim.play(nm, 0.15, (1.0 if b[3] == "G" else (_bogen_lauf if _bogen_lauf > 0.0 else BOGEN_TEMPO)) * float(tempo.get(nm, 1.0)))


## 682 (Chef 08.11., 16:22–16:24: „so Stück gerade, dann diagonal, dann gerade … und dann drehen sie halt wieder auf der Stelle“;
## t270, 20:50: „Die Wölfe laufen immer noch in komischen Schienenbahnen“): Weg zum Biss und heim als eine weiche Kurve statt
## Drehen am Ort, Gerade, Drehen am Umweg, Gerade. Das Tier folgt den Punkten [ziele] (Umweg, Ziel) wie ein Läufer, der im Gehen
## lenkt (Verfolgung eines Punkts LENK_VOR voraus, Krümmung höchstens 1/Wenderadius, nah am Ziel enger, damit es ankommt).
## Je Punkt [Ort, Weg, Drehung, Art] wie _dubins ("B" im Bogen, "G" gerade). [] wenn der Weg einem anderen näher käme als
## erlaubt oder nicht ankommt; dann bleibt der alte Weg (438: nie ineinander).
const GLATT_682 := true
func _glatt_an_682() -> bool:
	return GLATT_682 and not has_meta("glatt_aus")     # kurven_682 GLATT682=0: der alte Weg zum Vergleich
const LENK_VOR := 0.6        # m × Größe: so weit voraus liegt der Punkt, auf den es lenkt
const LENK_R := 0.45         # m × Größe: kleinster Wenderadius im Gehen
const LENK_ANKUNFT := [1.5, 1.0, 0.6, 0.0]    # × LENK_VOR: so weit vor dem Platz (in Blickrichtung zurück) läuft die Kurve heim schon gerade, der Reihe nach
const LENK_ENG := 1.6       # × größte Krümmung: so eng darf es nah am Ziel werden
const LENK_BOGEN := 0.35    # ab diesem Anteil der größten Krümmung gilt der Schritt als Bogen (langsamer)
func _glatt(von: Vector3, yaw0: float, ziele: Array, skip = null) -> Array:
	var sc := _scale()
	var ds := PFAD_SCHRITT
	var vor := LENK_VOR * sc
	var kmax := 1.0 / (LENK_R * sc)
	var poly: Array = [Vector2(von.x, von.z)]
	for z in ziele:
		poly.append(Vector2(z.x, z.z))
	var ende: Vector2 = poly[poly.size() - 1]
	var gerade := 0.0
	for i in range(1, poly.size()):
		gerade += (poly[i] - poly[i - 1]).length()
	var p := Vector2(von.x, von.z)
	var th := PI / 2.0 - yaw0     # wie _dubins: vorn = (cos th, sin th)
	var seg := 1
	var s := 0.0
	var pts: Array = [[von, 0.0, yaw0, "B"]]
	var g0 := INF
	if fighter.monster != null and _foot_ok:
		# 717 C (wolf_mess_438: die Luft am Ziel, mit der Drehung des Starts gemessen, war negativ, die Kurve lief durch den abgesetzten
		# Wolf neben dem Helden): nur die Luft am Start zählt, das Ziel prüft die Wahl des Bissplatzes
		g0 = _rumpf_luft(von, yaw0, skip)
		g0 = minf(g0, PLATZ_LUFT) - WEG_LUFT
	var n_max := int(gerade * 3.0 / ds) + 200
	for n in n_max:
		var rest := (ende - p).length()
		if rest <= ds:
			break
		# Punkt LENK_VOR voraus auf dem Linienzug (ab dem nächsten Abschnitt, der noch vor ihm liegt)
		while seg < poly.size() - 1 and (poly[seg] - p).length() < vor:
			seg += 1
		var ziel: Vector2 = poly[seg]
		var zu := ziel - p
		var fehl := wrapf(atan2(zu.y, zu.x) - th, -PI, PI)
		# Verfolgung: Krümmung 2 sin(Fehler) / Abstand; nah am Ende darf es enger werden, sonst kreiste es um das Ziel
		var k := 2.0 * sin(fehl) / maxf(zu.length(), ds)
		# (kurven_682, Kleriker: zuletzt 25° je Bild, ein Kreiseln auf den Platz): enger höchstens LENK_ENG-fach
		var grenze := minf(maxf(kmax, 2.0 / maxf(rest, ds) if seg == poly.size() - 1 else kmax), kmax * LENK_ENG)
		k = clampf(k, -grenze, grenze)
		th += k * ds
		p += Vector2(cos(th), sin(th)) * ds
		s += ds
		var pos := Vector3(p.x, von.y, p.y)
		var yaw := PI / 2.0 - th
		pts.append([pos, s, yaw, "B" if absf(k) > LENK_BOGEN * kmax else "G"])
		if g0 < INF and _rumpf_luft(pos, yaw, skip) < g0:     # (wolf_mess_438: jeder dritte Punkt liess 6 cm Wolf in Wolf durch)
			if OS.get_environment("SCHAU_MESS") != "":
				print("682 Kurve %s verworfen bei %s (Luft %.2f < %.2f)" % [fighter.id, pos, _rumpf_luft(pos, yaw, skip), g0])
			return []
	if (ende - p).length() > ds * 2.0 or s > gerade * 2.0 + 1.0:
		return []
	pts.append([Vector3(ende.x, von.y, ende.y), s + (ende - p).length(), PI / 2.0 - th, pts[pts.size() - 1][3]])
	return pts


## 682: hängt [pts] an [tw] an (wie _pfad_fahren, aber im laufenden tween, nach Drehung oder vor dem Biss); [lauf] auf Geraden,
## im Bogen [bogen] × lauf (Bewegung und Schrittfolge zugleich); gibt die Dauer (s) zurück
func _glatt_an(tw: Tween, pts: Array, lauf: String, bogen: float) -> float:
	var t := 0.0
	pts[0].append(0.0)
	for i in range(1, pts.size()):
		var v: float = _mps(lauf) * (1.0 if pts[i][3] == "G" else bogen)
		t += (pts[i][1] - pts[i - 1][1]) / maxf(v, 0.05)
		pts[i].append(t)
	tw.tween_callback(func(): _pfad_anim = ""; _bogen_lauf = bogen)
	tw.tween_method(func(x: float): _auf_zeit(pts, x, lauf), 0.0, t, t)
	tw.tween_callback(func(): _bogen_lauf = 0.0)
	return t


## Grad je Sekunde, mit denen ein Tier mit Wurzelweg sich umdreht (180° in 0,4 s)
const TURN_DPS := 450.0
## r4: mit Pfotenhalt (pfotenhalt.gd) langsamer, 180° in 0,75 s: bei 450°/s läge zwischen zwei Tritten einer Pfote über 0,5 m Weg
const TURN_DPS_TRITT := 240.0
## unter diesem Winkel dreht es ohne Schritte
const TURN_STILL := 15.0
const TURN_KLEIN := 3.0


## 595 (Chef 05.11., 19:2x: „Säureschnecke … springt schnell/ruckartig auf Platz nach Angriff um (2x ruckartige Drehung)“; nachgestellt
## 10.11.: 15–17° in einem Bild, 450°/s): wer ohne Beine kriecht, dreht so langsam, wie er kriecht
const TURN_DPS_ART := {"kauf_schnecke": 60.0}


func _turn_dps() -> float:
	if TURN_DPS_ART.has(art()):
		return float(TURN_DPS_ART[art()])
	return TURN_DPS_TRITT if halt else TURN_DPS


## Hängt an [tw] eine Drehung auf [yaw] mit Schritten an (kleine Winkel sofort); gibt die Dauer (s) zurück. r4: mit Pfotenhalt
## steht das Tier (Stehen) und die Pfoten treten nach; [stehen]: danach bleibt es stehen (die Pfoten treten nach), sonst läuft es los
func _turn(tw: Tween, yaw: float, stehen: bool, lang := false) -> float:
	var dw := wrapf(yaw - rotation.y, -PI, PI)
	if lang and absf(dw) > 0.01:     # 438: andersherum, weil die kurze Drehung durch einen anderen führte
		dw -= signf(dw) * TAU
	if absf(rad_to_deg(dw)) < TURN_KLEIN:     # 438: vorher bis TURN_STILL (15°) in einem Bild, gemessen 13° daheim
		tw.tween_callback(func(): rotation.y = yaw)
		return 0.0
	var t := absf(rad_to_deg(dw)) / _turn_dps()
	if halt:
		tw.tween_callback(func(): _play("Stehen", 0.1); halt.an())
	else:
		tw.tween_callback(func(): _play("Gehen", 0.1))
	tw.tween_property(self, "rotation:y", rotation.y + dw, t)
	# 438 (Prüfer Film 08:18: Wolf 2 dreht 0:29 und 0:34,9 je 45° in einem Bild): rotation.y + dw liegt oft 2π neben [yaw]; die
	# folgende Drehung am Umweg (yaw + d1) lief dann einmal ganz herum in ihrer kurzen Zeit. Gleicher Winkel, ohne Sprung im Bild
	tw.tween_callback(func(): rotation.y = yaw)
	if halt:
		tw.tween_callback(func(): halt.los(stehen))
	return t


## Daheim zur Blickrichtung von _face() drehen, dann Ruhe; gibt die Dauer (s) zurück
var _warte_n := 0           # 438: so oft schon auf einen Laufenden gewartet (je Heimweg)
const WARTE_MAX := 8
const WARTE_S := 0.25
var _abgesetzt := false     # 438: auf diesem Heimweg schon einmal rückwärts abgesetzt, um frei zu drehen


## 717 C (Chef 09.11., 08:58; F7): Gegner (außer auf der Flucht) bleiben nach dem Angriff abgesetzt stehen und rücken erst mit dem eigenen
## Zug in die Reihe; 717.1 A (F8): auch das Zurechtrücken beginnt in ihrem Zug (glide_to merkt den neuen Platz nur vor)
const ABSETZ_TEMPO_717 := 1.3      # × Gehen rückwärts: ein bis zwei rasche Schritte, nicht im Schneckentempo
func _bleib_717() -> bool:
	return fighter.monster != null and not flieht


## 717 C (wolf_mess_438: beim Platztausch kam der neue Platz des einen einen Zug früher als der des anderen, beide standen auf
## demselben): solange ein anderer Gegner denselben Platz hat, rückt keiner dorthin; im nächsten Zug der Gegner tauschen beide
func _platz_besetzt() -> bool:
	for o in kampfort.figures.values():
		if o != self and o.fighter.side == fighter.side and not o.down and o.dead_at < 0 and o.visible \
				and Vector2(o.home.x - home.x, o.home.z - home.z).length() < 0.05:
			return true
	return false


## 717 C: steht der Held an [p] frei von allen außer sich und [ziel]?
func _stand_frei(p: Vector3, ziel) -> bool:
	for o in kampfort.figures.values():
		if o != self and o != ziel and o.visible and not o.down and o.dead_at < 0 and o.clearance(p) < HERO_R + HELD_LUFT:
			return false
	return true


## 717 C, 717.1 A: mit dem eigenen Zug an den neuen Platz (das Gesicht zum Helden), wenn die Reihe umgestellt wurde; nach dem Angriff
## bleibt er abgesetzt stehen und greift von dort wieder an (kein langes Rückwärtsgehen, Chef 08:58)
var platz_neu := false     # 717.1 A: glide_to hat einen neuen Platz vorgemerkt, der Gegner rückt in seinem Zug dorthin
func zurueck_in_reihe() -> float:     # 778: gibt die Dauer zurück (0: geht nicht)
	if not _bleib_717() or down or not platz_neu or (tween and tween.is_running()) or _platz_besetzt():
		return 0.0
	platz_neu = false
	if Vector2(home.x - position.x, home.z - position.z).length() > 0.12:
		return _walk_home()
	return 0.0


## 717: heim über [via] (oder gerade), das Gesicht zum Gegner: im ersten Abschnitt dreht er im Gehen ein (_blick_daheim); je
## Abschnitt Gehen vorwärts, wenn der Platz vor ihm liegt, sonst rückwärts (wie bisher RUECK_TEMPO); gibt die Dauer zurück
## (wolf_mess_438: rückwärts im alten Tempo 0,8 war der Wolf noch unterwegs, als der nächste zum Biss lief, 15 cm ineinander):
## rückwärts zurück zügig, wie ein Zurückweichen; die Schritte laufen mit (_schritt_sync)
const RUECK_717 := 1.6
func _heim_mit_gesicht(via: Vector3, skip = null) -> float:
	gang = "heim"
	var r0 := rotation.y
	var dw0 := wrapf(_blick_daheim() - r0, -PI, PI)
	var punkte: Array = ([via] if via != position else []) + [home]
	var v_vor := _mps("Gehen")
	var v_rueck := _mps("Gehen") * RUECK_717
	# (wolf_mess_438: das Eindrehen im Gehen schwenkte den Rumpf 8 cm in den Nachbarn): nur so weit eindrehen, wie der Rumpf auf dem
	# ganzen Weg frei bleibt, sonst weniger, zuletzt gar nicht (daheim dreht _turn_home den Rest, wo es frei ist)
	var g0 := maxf(minf(_rumpf_luft(position, r0, skip), PLATZ_LUFT) - WEG_LUFT, -0.02)
	var dw := 0.0
	for k in [1.0, 0.75, 0.5, 0.25, 0.0]:
		var frei := true
		var von0 := position
		for q in punkte:
			var a0: Vector3 = q - von0
			var l0 := Vector2(a0.x, a0.z).length()
			var n := maxi(1, int(ceilf(l0 / 0.05)))
			var t_rot := minf(l0 / v_rueck, 0.6)
			for m in n + 1:
				var u := float(m) / n
				var yaw: float = r0 + dw0 * k * (minf(1.0, u * (l0 / v_rueck) / maxf(t_rot, 0.01)) if q == punkte[0] else 1.0)
				if _rumpf_luft(von0.lerp(q, u), yaw, skip) < g0:
					frei = false
					break
			if not frei:
				break
			von0 = q
		if frei:
			dw = dw0 * k
			break
	if OS.get_environment("SCHAU_717") != "":
		print("717 heim %s %.1f s von %s über %s nach %s, eingedreht %.0f von %.0f°" % [fighter.id, kampfort.clock_ms / 1000.0, position, via, home, rad_to_deg(dw), rad_to_deg(dw0)])
	var t := 0.0
	var von := position
	for q in punkte:
		var a: Vector3 = q - von
		var mitte := r0 + dw if q != punkte[0] else r0 + dw * 0.5
		var vor := Vector2(a.x, a.z).dot(Vector2(sin(mitte), cos(mitte))) > 0.0
		tween.tween_callback(func(): anim.play("Gehen", 0.15, float(tempo.get("Gehen", 1.0)) * (1.0 if vor else -1.0)))
		var tl := _lauf(tween, von, q, "Gehen", 1.0 if vor else RUECK_717)
		# gleich im ersten Abschnitt eindrehen (kurven_682: nach dem Ausweichen sonst lange mit dem Rücken zum Helden)
		if q == punkte[0] and dw != 0.0:
			tween.parallel().tween_property(self, "rotation:y", r0 + dw, minf(tl, 0.6))
		t += tl
		von = q
	tween.tween_callback(_turn_home)
	return t


## 682: die Drehung, die _turn_home daheim wählen würde (Blick zum Gegner, so weit der Rumpf frei bleibt), schon unterwegs gerechnet
func _blick_daheim() -> float:
	var p0 := position
	var r := rotation.y
	position = home
	_face()
	var goal := rotation.y
	rotation.y = r
	if fighter.monster != null and _foot_ok and kampfort:
		var dw := wrapf(goal - r, -PI, PI)
		var g0 := minf(_rumpf_luft(position, r), PLATZ_LUFT)
		var k := 1.0
		while k > 0.0 and _dreh_luft_bogen(r, dw * k) < g0:
			k -= 0.125
		goal = r + dw * maxf(k, 0.0)
	position = p0
	return goal


func _turn_home() -> float:
	bahn = []
	_abgesetzt = false
	var r := rotation.y
	_face()
	var goal := rotation.y
	rotation.y = r
	# 438 (wolf_mess_438: Wolf 3 drehte daheim 82° und schwenkte den Rumpf in den Anlauf von Wolf 1): daheim nur so weit drehen,
	# wie der Rumpf frei bleibt (auch gegen die Bahnen der Laufenden); den Rest blickt der Hals
	if fighter.monster != null and _foot_ok and kampfort:
		var dw := wrapf(goal - r, -PI, PI)
		var g0 := minf(_rumpf_luft(position, r), PLATZ_LUFT)
		var k := 1.0
		# 438 (wolf_mess_438, Kleriker 20 s: Wolf 3 drehte daheim 128° und schwenkte das Heck 0,18 m in Wolf 2; geprüft waren nur
		# Ende und Hälfte der Drehung): jede Lage der Drehung muss frei bleiben, in Schritten von 15°
		while k > 0.0 and _dreh_luft_bogen(r, dw * k) < g0:
			k -= 0.125
		goal = r + dw * maxf(k, 0.0)
	dreh_ziel = goal
	tween = create_tween()
	var t := _turn(tween, goal, true)
	tween.tween_callback(_idle)
	return t


## 348.12f (Chef 27.10., 18:01, Archiv: „Biss zum Helden nachjustieren wie bei eigenen“): mit Wurzelweg läuft das Tier bis vor das
## Ziel, die Schnauze an dessen Rand, und beißt dort; angesagt (Sprung) springt es aus der Weite des Sprungbisses der Quelle an.
## Danach springt es zurück (Ausweichen zurück) und geht heim. Gibt wie strike() die Zeit bis zum Biss / 0,42 zurück (ms).
const ABWEHR_VOR := 0.1
const BISSKETTE_JE := 2     # 595: jeder zweite unangesagte Biss der Spinne als Bisskette (reihum wie das Ausweichen, 593)
var biss_nr := 0
func _bite(other, leap: bool, weiter := 0.0) -> int:
	# 717 C, 717.1 A (wolf_mess_438: um den Helden war kein Bissplatz frei, Wolf 1 stand dort abgesetzt, Wolf 3 biss durch ihn): wer
	# abgesetzt steht, rückt jetzt in seine Reihe (Zurechtrücken im Zug der Gegner, F8), das Gesicht zum Helden
	# 778 (Build 272, wolf_mess_438 Kleriker Bild 2829, nachgestellt am Rechner): Wolf 2 stand abgesetzt 4,9 m vom Ziel, ausserhalb der
	# alten Grenze 4,5 m, und sperrte mit Wolf 3 jeden Weg des hinteren Wolfs 1 zum Söldner; Wolf 1 lief den besten (0,14 m tief) und
	# ging 0,29 m durch Wolf 2. Jetzt rücken alle Abgesetzten; der Angreifer wartet, bis sie daheim sind, und plant seinen Weg so, als
	# stünden sie schon dort (stand Wolf 2 daheim, war der Weg 0,12 m frei)
	var rueckt: Array = []     # [Figur, Ort, Bahn] der Abgesetzten, die jetzt in ihre Reihe gehen
	var t_warte := 0.0
	if _bleib_717():
		for o in kampfort.figures.values():
			if o != self and o.visible and not o.down and o.fighter.monster != null and not o.unterwegs() \
					and Vector2(o.home.x - o.position.x, o.home.z - o.position.z).length() > 0.12:
				o.platz_neu = true
				var t: float = o.zurueck_in_reihe()
				if o.unterwegs() and o.gang == "heim":     # geht wirklich (wer wartet, zählt, wo er steht)
					rueckt.append([o, o.position, o.bahn])
					t_warte = maxf(t_warte, t)
	for r in rueckt:
		r[0].position = r[0].home
		r[0].bahn = []
	var ms := _bite_plan(other, leap, weiter, t_warte)
	for r in rueckt:
		r[0].position = r[1]
		r[0].bahn = r[2]
	return ms


func _bite_plan(other, leap: bool, weiter: float, t_warte: float) -> int:
	var bleib717 := _bleib_717()
	var flat := Vector3(other.position.x - position.x, 0.0, other.position.z - position.z)
	if flat.length() < 0.01:
		flat = basis.z
	var dir := flat.normalized()
	var nm := "Sprungbiss" if leap and anim and anim.has_animation("Sprungbiss") and weg.has("Sprungbiss") else "Biss"
	# 595: unangesagt beißt die Spinne reihum einmal oder in einer Kette aus drei Bissen (jeder BISSKETTE_JE-te Biss), Schaden beim
	# tiefsten der drei (bite["Bisskette"][1])
	if nm == "Biss" and bite.has("Bisskette") and anim and anim.has_animation("Bisskette"):
		biss_nr += 1
		if (biss_nr + hash(String(fighter.id))) % BISSKETTE_JE == 0:
			nm = "Bisskette"
	# 438 (Prüfer Film r2: Schnauze 9,4 s und 20,3 s in Schild und Brust; wolf_mess_438: bis 10 cm in Schild und Klinge): der Rand
	# des Ziels zum Wolf hin mit dem, was es trägt, nicht nur der Kreis body_r()
	# 595 (Chef 05.11., 19:2x: „Säureschnecke – Angriff geht etwas daneben am Ziel“; nachgestellt 10.11.: Rand des Kämpfers mit Schild
	# und Klinge 0,90 m, Leib 0,30 m, die Zunge endete vor der Klingenspitze): die Zunge schnellt über Schild und Klinge an den Leib
	var stand: float = other.vorne(-dir, ZUNGE.has(art())) + bite[nm][0] * model.scale.x + weiter     # Ursprung bis Mitte des Ziels beim Biss
	# 438 (wolf_mess_438, Kleriker 9,5 s: Schild 7 cm im Kopf des Wolfs): wer mit dem Schild abwehrt (406), stößt ihn beim Biss
	# vor; vorne() misst die Ruhehaltung, darum bleibt der Wolf um ABWEHR_VOR weiter weg
	if other.has_method("blockt") and other.blockt():
		stand += ABWEHR_VOR
	if OS.get_environment("SCHAU_MESS") != "":
		print("Biss %s an %s: Rand %.2f (Kreis %.2f), Abstand %.2f" % [fighter.id, other.fighter.id, other.vorne(-dir), other.body_r(), stand])
	stand -= float(SCHNAUZE_NAEHER.get(art(), 0.0))
	# 709 (Chef 08.11., 21:36: „dass die Angriffe so sind, dass sie den Gegner treffen“; treffen_709: beim Treffer blieb die Schnauze
	# 0,33–0,45 m vor dem Körper, vor dem Schild 0,1–0,3 m): beim Treffer der Stand nach dem Weg von Kopf und Kiefer durch den Biss
	# gegen den Körper des Ziels, BISS_TIEF darin; zuerst gerade, sonst seitlich versetzt bis 60°, wo die Schnauze den Körper erreicht,
	# ohne in den Schild zu fahren, und der eigene Körper frei bleibt. Der Aufschlag ist der Augenblick, in dem sie am nächsten ist
	var biss_t: float = bite[nm][1]
	var biss_von := Vector3.INF
	if nm == "Biss" and weiter <= 0.0 and other.fighter.monster == null:
		var bb: Array = _hieb_bahn(nm, deg_to_rad(bite[nm][2]))
		if not bb.is_empty():
			var ziel: Array = other.koerper()
			var hind: Array = other.schild_kapseln()
			other.footprint()     # misst schild_unten (ohne Schild INF)
			var unter_schild: bool = other.schild_unten < INF and hoehe_oben() < other.schild_unten
			var teil := []     # bester freier Platz, an dem die Schnauze nicht ganz hinreicht: [Lücke, Platz, Richtung, Stand, t]
			for w in [0.0, 20.0, -20.0, 40.0, -40.0, 60.0, -60.0]:
				var d2 := dir.rotated(Vector3.UP, deg_to_rad(w))
				var pl: Array = hieb_plan(bb, ziel, other.position, d2, -BISS_TIEF, BISS_LUFT, hind)
				if OS.get_environment("SCHAU_709") != "":
					print("709 Biss %s an %s, %.0f°: Stand %.2f (Schnauze %.2f, Körper %.2f), vorher %.2f" % [fighter.id, other.fighter.id, w, pl[0], pl[2], pl[3], stand])
				if pl[2] <= 0.0:
					continue
				var voll: bool = pl[2] >= pl[3] - 0.02
				# 709 (wolf_mess_438 rot mit 9b5472b15: der versetzte Platz umging die Platzprüfung, Wolf in Wolf, Kopf im Helden):
				# nur ein Platz, der frei ist, frei erreichbar und im Bild; sonst der Biss wie bisher (438 sucht dann den Platz)
				# wer mit dem Schild abwehrt (406), stößt ihn vor (438: ABWEHR_VOR); der Weg misst die Ruhehaltung
				# reicht die Schnauze nicht ganz hin, steht der Schild davor; er fährt bei der Abwehr (Ring) vor, also gleich ABWEHR_VOR
				# Abstand (wolf_mess_438 Kleriker 71,9 s: Schild 9 cm im Wolf)
				# 709 (treffen_709 Ratten: 8 cm vor dem Helden): wer unter dem Schild bleibt, dem stößt er nicht entgegen
				var st2: float = float(pl[0]) + (ABWEHR_VOR if not unter_schild and (not voll or other.has_method("blockt") and other.blockt()) else 0.0)
				var s2 := Vector3(other.position.x, position.y, other.position.z) - d2 * st2
				var l2 := _platz_luft(s2, d2, other)
				var w2 := _weg_luft(position, s2, other) if s2.distance_to(position) > 0.15 else INF
				# 709 (wolf_mess_438 Kämpfer: um 40° versetzt lag der Umriss des Wolfs bis 0,24 m im Helden, während die Schnauze
				# traf): auch der eigene Umriss in Bisshaltung (Schnauze zum Ziel gedreht) bleibt vor dem Ziel, wie der Test misst
				# und beim Drehen zum Heimweg (wolf_mess_438: der lange Rumpf schwenkte 0,17 m durch den Helden): Bisshaltung, halb und
				# ganz zum Heim gedreht; die Haltung im Biss reicht weiter als der Umriss in Ruhe (BISS_UMRISS als Luft)
				var y0 := atan2(d2.x, d2.z) + deg_to_rad(bite[nm][2])
				var hv := home - s2
				var y1 := y0 + wrapf(atan2(hv.x, hv.z) + PI - y0, -PI, PI) if _bleib_717() or weg.has("Zurück") else atan2(hv.x, hv.z)
				# 709 (treffen_709 Ratten: an jedem Bissplatz lag der Umriss 0,16–0,34 m im Helden, die Schnauze blieb 0,6–0,8 m vor ihm):
				# Kopf und Kiefer gehören beim Biss ans Ziel, hieb_plan prüft sie räumlich gegen Körper und Schild; gegen das Ziel zählt in
				# Bisshaltung nur der Rumpf hinter dem Kopf (bei der Ratte liegt der Kopf am Boden im Umriss, beim Wolf darüber)
				# (nur wer unter dem Schild bleibt: Ratte, Spinne, Schnecke; Wolf und Grimmzahn reichen höher, ihr Kopf zählt mit, 709a)
				var rumpf := _rumpf_ohne_kopf() if unter_schild else footprint()
				# auch beim Drehen zum Heimweg: der Kopf löst sich dabei vom Ziel
				var r2 := INF
				for yw in [y0, lerp_angle(y0, y1, 0.5), y1]:
					r2 = minf(r2, minf(_rumpf_luft(s2, yw, other), _rumpf_luft(s2, yw, null, other, rumpf)))
				# der Heimweg geht am Ziel vorbei (_walk_home lässt das Ziel aus): auch er bleibt vor dessen Umriss
				var h2 := INF
				var fb := footprint()
				for i in range(1, 9):
					h2 = minf(h2, other.clearance(s2.lerp(home, i / 8.0)) - (fb.end.x - fb.position.x) * 0.5)
				if OS.get_environment("SCHAU_709") != "":
					print("709 Bissplatz %s, %.0f°: Luft %.2f Weg %.2f Umriss %.2f Heim %.2f im Bild %s" % [fighter.id, w, l2, w2, r2, h2, _im_bild(s2, d2)])
				# wer mit Schild kämpft, hält ihn bei der Abwehr vor sich (footprint), um ABWEHR_VOR weiter (wolf_mess_438 Kämpfer: 0,11 m)
				var r_soll: float = BISS_UMRISS + (ABWEHR_VOR if other.kauf and other._ss() and not unter_schild else 0.0)
				# und der Held dreht sich getroffen oder abwehrend zum Wolf (_face_sanft), den Schild mit (footprint): sein Umriss auch so
				if other.kauf and other._ss():
					var fb2 := rumpf
					var tr2 := Transform3D(Basis(Vector3.UP, y0), s2)
					var zum: Vector3 = s2 - other.position
					for i in 7:
						for j in 3:
							var q := tr2 * Vector3(lerpf(fb2.position.x, fb2.end.x, j / 2.0), 0.0, lerpf(fb2.position.z, fb2.end.z, i / 6.0))
							r2 = minf(r2, other.clearance(q, Vector3.INF, atan2(zum.x, zum.z), hoehe_oben()))
				if l2 < PLATZ_LUFT or w2 < WEG_LUFT or r2 < r_soll or h2 < -BISS_UMRISS or not _im_bild(s2, d2):
					continue
				var bt := float(pl[1]) / maxf(float(tempo.get(nm, 1.0)), 0.1) + HIEB_VERZUG
				if not voll:     # die Schnauze bliebe pl[0] − pl[2] davor (Schild oder eigener Körper im Weg); näher als bisher
					if st2 - float(pl[2]) < (teil[0] if not teil.is_empty() else stand - float(pl[2])):
						teil = [st2 - float(pl[2]), s2, d2, st2, bt]
					continue
				biss_von = s2
				dir = d2
				stand = st2
				biss_t = bt
				break
			if biss_von == Vector3.INF and not teil.is_empty():
				biss_von = teil[1]
				dir = teil[2]
				stand = teil[3]
				biss_t = teil[4]
	var jump := _weg_len(nm) if nm == "Sprungbiss" else 0.0
	var k := 1.0
	var gap := flat.length() - stand
	if jump > 0.0 and gap < jump:     # zu nah für den ganzen Satz: kürzer springen
		k = maxf(gap, 0.2 * jump) / jump
		jump *= k
	var start := position + dir * maxf(0.0, gap - jump)
	if biss_von != Vector3.INF:     # 709: seitlich versetzt um das Ziel herum, nicht vom eigenen Ort aus gedreht
		start = biss_von
		flat = Vector3(other.position.x - start.x, 0.0, other.position.z - start.z)
	# 438 (Prüfer Film 08:18: Wölfe laufen durcheinander; wolf_mess_438: Wolf 3 lief zum Biss an Bertram bis 0,15 m in Wolf 2, der
	# daneben kauerte): der Platz vor dem Ziel wird nur genommen, wenn dort kein anderer steht oder hinläuft; sonst derselbe Abstand
	# zum Ziel, um das Ziel herum gedreht (bis 60°), der freieste
	# 438 (Prüfer Film r2: Wolf 3 sprang 19,4 s durch Bertrams Kopf zu Ansgar): auch die Bahn des Sprungs muss frei sein, nicht nur
	# der Absprung; geht das in keiner Richtung, beißt er ohne Sprung
	var luft := minf(_platz_luft(start, dir, other), _seg_gap(start, start + dir * jump, other) if jump > 0.0 else INF)
	# 438 (wolf_mess_438, Kleriker 43 s: Wolf 1 lief zum freien Bissplatz vor Bertram, aber der einzige Weg dorthin führte 0,45 m
	# durch Wolf 3, der davor kauerte): der Platz zählt nur so frei wie der Weg dorthin
	var weg0 := _weg_luft(position, start, other) if start.distance_to(position) > 0.15 else INF
	if OS.get_environment("SCHAU_MESS") != "":
		print("Bissplatz %s an %s: start %s Luft %.2f Weg %.2f" % [fighter.id, other.fighter.id, start, luft, weg0])
	if luft < PLATZ_LUFT or weg0 < WEG_LUFT:
		var tg := Vector3(other.position.x, position.y, other.position.z)
		var r0 := Vector2(tg.x - start.x, tg.z - start.z).length()
		var best := [minf(luft, weg0) - (0.0 if _im_bild(start, dir) else 1.0), dir, start, luft]
		var r_satz := r0 - stand     # was über den Bissabstand hinaus zum Satz gehört
		for w in [15.0, -15.0, 30.0, -30.0, 45.0, -45.0, 60.0, -60.0]:
			var d2 := dir.rotated(Vector3.UP, deg_to_rad(w))
			# 438 (wolf_mess_438, Kleriker 43,8 s: um das Ziel herum gedreht stand der Wolf 0,31 m im Helden und 4 cm im Schild):
			# der Rand des Ziels gilt in der neuen Richtung (auf der Schildseite weiter vorn), nicht der alte Abstand
			var st2: float = stand + other.vorne(-d2, ZUNGE.has(art())) - other.vorne(-dir, ZUNGE.has(art()))
			var s2 := tg - d2 * (st2 + r_satz)
			var l2 := minf(_platz_luft(s2, d2, other), _seg_gap(s2, s2 + d2 * jump, other) if jump > 0.0 else INF)
			var w2 := _weg_luft(position, s2, other) if s2.distance_to(position) > 0.15 else INF
			# 438 (wolf_mess_438, Kleriker 66 s: Wolf 1 lief zu einem Bissplatz am rechten Rand, 20 px aus dem Bild): ein Platz
			# aus dem Bild nur, wenn keiner im Bild frei ist
			var drin := _im_bild(s2, d2)
			var wert2 := minf(l2, w2) - (0.0 if drin else 1.0)
			if wert2 > best[0]:
				best = [wert2, d2, s2, l2]
			if l2 >= PLATZ_LUFT and w2 >= WEG_LUFT and drin:
				break
		dir = best[1]
		start = best[2]
		if best[3] < PLATZ_LUFT and jump > 0.0:
			# kurzer Satz aus der Nähe: er läuft (mit Umweg) bis knapp vor das Ziel und springt erst dort
			var kurz := minf(jump, 0.2 * _weg_len(nm))
			k = kurz / _weg_len(nm)
			var rb := Vector2(tg.x - start.x, tg.z - start.z).length()     # 438: Abstand des gewählten Platzes
			start = tg - dir * (rb - jump + kurz)
			jump = kurz
		flat = dir * flat.length()
	angriff_von = start
	var r_alt := rotation.y
	_face(flat)
	rotation.y += deg_to_rad(bite[nm][2])     # die Schnauze, nicht die Körperachse zum Ziel
	var schnauze := rotation.y
	rotation.y = r_alt     # 438: erst mit Tritten zum Ziel drehen (vorher in einem Bild, gemessen bis 81°)
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	if t_warte > 0.0:     # 778: erst wenn die Abgesetzten in ihrer Reihe stehen
		tween.tween_interval(t_warte)
	var t_run := 0.0
	anlauf_ms = 0
	gang = "anlauf"
	var run := start.distance_to(position)
	bahn = [start, home]
	if run > 0.15:
		# 399.2 (Chef 28.10., 16:10: „dann läuft der hintere Wolf durch den vorderen“): um die anderen herum wie die Heldin
		var via := _detour(position, start, other)
		var way := run if via == position else position.distance_to(via) + via.distance_to(start)
		bahn = [start, home] if via == position else [via, start, home]
		if OS.get_environment("SCHAU_MESS") != "":
			var andere := []
			for o in kampfort.figures.values():
				if o != self and o.visible and not o.down:
					andere.append("%s@%s%s" % [o.fighter.id, o.position, " unterwegs" if o.unterwegs() else ""])
			print("Anlauf %s %s -> %s -> %s Luft %.2f / %.2f; %s" % [fighter.id, position, via, start, _seg_gap(position, via, other), _seg_gap(via, start, other), andere])
		var gn := "Rennen" if way > RUN_FROM and weg.has("Rennen") else "Gehen"
		var auf := via - position
		var erst := atan2(auf.x, auf.z) if via != position else schnauze
		# 682: eine weiche Kurve zum Bissplatz, die zuletzt auf das Ziel zuläuft (Punkt LENK_VOR vor dem Platz in Bissrichtung)
		var kurve: Array = []
		if _glatt_an_682():
			var ziele: Array = [via] if via != position else []
			var vorher := start - dir * LENK_VOR * _scale()
			if run > LENK_VOR * _scale() * 1.5:
				ziele.append(vorher)
			ziele.append(start)
			kurve = _glatt(position, rotation.y, ziele, other)
		if not kurve.is_empty():
			t_run = _glatt_an(tween, kurve, gn, AUSWEICH_BOGEN if gn == "Rennen" else BOGEN_TEMPO)
			var rest := wrapf(schnauze - float(kurve[kurve.size() - 1][2]), -PI, PI)
			tween.tween_property(self, "rotation:y", float(kurve[kurve.size() - 1][2]) + rest, absf(rad_to_deg(rest)) / _turn_dps())
			t_run += absf(rad_to_deg(rest)) / _turn_dps()
		else:
			t_run = _turn(tween, erst, false)
			tween.tween_callback(func(): _play(gn, 0.1))
			# 438: anfahren und vor dem Biss abbremsen (_lauf), am Umweg mit Tritten drehen statt in einem Bild
			if via != position:
				var ab := start - via
				var d1 := wrapf(atan2(ab.x, ab.z) - erst, -PI, PI)
				var d2 := wrapf(schnauze - atan2(ab.x, ab.z), -PI, PI)
				t_run += _lauf(tween, position, via, gn)
				tween.tween_property(self, "rotation:y", erst + d1, absf(rad_to_deg(d1)) / _turn_dps())
				tween.tween_callback(func(): _play(gn, 0.1))
				t_run += absf(rad_to_deg(d1)) / _turn_dps() + _lauf(tween, via, start, gn)
				tween.tween_property(self, "rotation:y", erst + d1 + d2, absf(rad_to_deg(d2)) / _turn_dps())
				t_run += absf(rad_to_deg(d2)) / _turn_dps()
			else:
				t_run += _lauf(tween, position, start, gn)
	else:
		t_run = _turn(tween, schnauze, true)
	t_run += t_warte
	var bl: float = anim.get_animation(nm).length if anim and anim.has_animation(nm) else 0.8
	var b := Basis(Vector3.UP, atan2(dir.x, dir.z))
	tween.tween_callback(func(): _play(nm, 0.08))
	if nm == "Sprungbiss":
		tween.tween_method(func(x: float): position = _weg_at(start, b, nm, x, k), 0.0, bl, bl)
	else:
		tween.tween_interval(bl)
	var t_back := 0.0
	var ende := start + dir * jump
	if weg.has("Ausweichen zurück") and anim.has_animation("Ausweichen zurück"):
		var hb: float = anim.get_animation("Ausweichen zurück").length
		tween.tween_callback(func(): _play("Ausweichen zurück", 0.1))
		tween.tween_method(func(x: float): position = _weg_at(ende, b, "Ausweichen zurück", x), 0.0, hb, hb)
		t_back = hb
		ende = _weg_at(ende, b, "Ausweichen zurück", hb)
	elif weg.has("Gehen") and (bleib717 or not _rueckwaerts_von(ende, dir, other)):     # r5 (Prüfer r4: der Kaufwolf drehte am Ort des Bisses, der Kopf schwang durch die Heldin): erst rückwärts absetzen
		var zurueck := ABSETZEN * _scale()
		var rueck_dir := dir
		# 717 C (wolf_mess_438: abgesetzt stand Wolf 3 bis 59 px aus dem Bild, Wolf 1 20 cm in Wolf 3): gerade oder schräg zurück, so weit,
		# wie er im Bild und frei von den anderen bleibt (gemessen, als stünde er schon dort), sonst stehen bleiben, wo er biss
		if bleib717:
			var yaw_b := atan2(dir.x, dir.z)
			var g0b := minf(_rumpf_luft(ende, yaw_b, other), PLATZ_LUFT)
			var gefunden := false
			for kz in [1.0, 0.5]:
				for w in [0.0, 35.0, -35.0]:
					var rd := dir.rotated(Vector3.UP, deg_to_rad(w))
					var p2: Vector3 = ende - rd * ABSETZEN * _scale() * kz
					if _im_bild(p2, dir) and _rumpf_luft(p2, yaw_b, other) >= g0b and _seg_gap(ende, p2, other) >= 0.0:
						zurueck = ABSETZEN * _scale() * kz
						rueck_dir = rd
						gefunden = true
						break
				if gefunden:
					break
			if not gefunden:
				zurueck = 0.0
		var ab0 := ende
		ende = ende - rueck_dir * zurueck
		tween.tween_callback(func(): anim.play("Gehen", 0.1, -float(tempo.get("Gehen", 1.0)) * (ABSETZ_TEMPO_717 if bleib717 else 1.0)))
		t_back = _lauf(tween, ab0, ende, "Gehen", ABSETZ_TEMPO_717 if bleib717 else RUECK_TEMPO)
	# 717 C (Chef 09.11., 08:58; F7): nach dem Biss ein bis zwei Schritte rückwärts absetzen und dort stehen; zurück in die Reihe erst mit
	# dem eigenen Zug (kampfort.gd _play_say, _zurueck_in_reihe)
	if bleib717:
		# (wolf_mess_438, Kleriker 41 s: Wolf 3 rückte quer hinter dem beißenden Wolf 1 vorbei, der dann dorthin absetzte): die anderen
		# kennen den Platz, an dem er abgesetzt stehen wird
		bahn = bahn.slice(0, bahn.size() - 1) + [ende] if not bahn.is_empty() else [start, ende]     # statt heim: der Platz des Absetzens
		tween.tween_callback(func(): gang = ""; bahn = []; _turn_home())
		busy_ms = int((t_run + bl + t_back + 0.3) * 1000.0)
		anlauf_ms = int(t_run * 1000.0)
		return int((t_run + biss_t) * 1000.0 / 0.42)
	tween.tween_callback(func(): gang = "heim"; _walk_home(other))
	# bis daheim, damit keiner zu einem Ort schlägt, an dem es nicht mehr steht (399.2: mit Umweg)
	var vh := _detour(ende, home, other)
	var heim := Vector2(home.x - ende.x, home.z - ende.z).length() if vh == ende else ende.distance_to(vh) + vh.distance_to(home)
	# r3: Heimweg mit Bogen und Kurve statt Drehen (höchstens ein Halbkreis und ein Bogen daheim mehr als die Gerade)
	var t_heim := 0.0 if heim < 0.12 else heim / _mps("Rennen" if heim > RUN_FROM and weg.has("Rennen") else "Gehen") + RAMPE_S
	if _rueckwaerts_von(ende, dir, other):     # 438: rückwärts heim, daheim nur die letzte Drehung
		t_heim = heim / (_mps("Gehen") * RUECK_TEMPO) + RAMPE_S + 40.0 / _turn_dps()
	else:
		t_heim += 2.0 * PI * TURN_R * _scale() / (_mps("Gehen") * BOGEN_TEMPO) if HEIMWEG_BOGEN else 2.0 * 180.0 / _turn_dps()
	busy_ms = int((t_run + bl + t_back + t_heim) * 1000.0)
	anlauf_ms = int(t_run * 1000.0)
	return int((t_run + biss_t) * 1000.0 / 0.42)


## 438: so viel Luft (m) hätte der Rumpf, stünde das Tier an [p] mit Blick [d], zu allen außer [skip] (auch auf deren Bahn)
const PLATZ_LUFT := 0.1
## 438: Luft auf dem Weg von [von] nach [nach], mit dem Umweg, den _detour() wählt
const WEG_LUFT := 0.05
func _weg_luft(von: Vector3, nach: Vector3, skip) -> float:
	var via := _detour(von, nach, skip)
	if via == von:
		return _seg_gap(von, nach, skip)
	return minf(_seg_gap(von, via, skip), _seg_gap(via, nach, skip))


func _platz_luft(p: Vector3, d: Vector3, skip) -> float:
	var box := footprint()
	return _seg_gap(p + d * box.position.z, p + d * box.end.z, skip, false)


## 438: Luft des Rumpfs an [p] mit Drehung [yaw] zu allen anderen
## (Raster über den eigenen Umriss gegen die Umrisse der anderen, wie tests/wolf_mess_438.gd misst)
func _rumpf_luft(p: Vector3, yaw: float, skip = null, nur = null, box := AABB()) -> float:
	if box.size == Vector3.ZERO:
		box = footprint()
	var hoch := hoehe_oben()
	var tr := Transform3D(Basis(Vector3.UP, yaw), p)
	var pts: Array = []
	for i in 7:
		for j in 3:
			pts.append(tr * Vector3(lerpf(box.position.x, box.end.x, j / 2.0), 0.0, lerpf(box.position.z, box.end.z, i / 6.0)))
	var g := INF
	for o in kampfort.figures.values():
		if o == self or o == skip or not o.visible or o.down or nur != null and o != nur:
			continue
		var orte: Array = [Vector3.INF]
		if o.unterwegs():
			orte.append_array(o.bahn_punkte())
		for at in orte:
			for q in pts:
				g = minf(g, o.clearance(q, at, NAN, hoch))
		if not is_nan(o.dreh_ziel) and o.tween and o.tween.is_running():
			for q in pts:
				g = minf(g, o.clearance(q, Vector3.INF, o.dreh_ziel, hoch))
	return g


## 562: Luft des Rumpfs, geht das Tier in seiner jetzigen Drehung (rückwärts) von [von] über [via] (== von: gerade) nach [nach];
## Raster wie _rumpf_luft alle 0,25 m; wer mit ihm den Platz tauscht (sein Ziel ist mein Start), zählt wie in _seg_gap nur, wo er steht
func _rueck_luft(von: Vector3, via: Vector3, nach: Vector3, skip = null) -> float:
	var box := footprint()
	var b := Basis(Vector3.UP, rotation.y) * Basis.from_scale(scale)     # wie wolf_mess_438: global_transform mit Maßstab
	var raster: Array = []
	for i in 7:
		for j in 3:
			raster.append(b * Vector3(lerpf(box.position.x, box.end.x, j / 2.0), 0.0, lerpf(box.position.z, box.end.z, i / 6.0)))
	var orte: Array = []
	var stuecke: Array = [[von, nach]] if via == von else [[von, via], [via, nach]]
	for s in stuecke:
		var n := maxi(1, int(ceilf(Vector2(s[1].x - s[0].x, s[1].z - s[0].z).length() / 0.25)))
		for i in range(1, n + 1):
			orte.append((s[0] as Vector3).lerp(s[1], float(i) / n))
	var g := INF
	for o in kampfort.figures.values():
		if o == self or o == skip or not o.visible or o.down:
			continue
		var bei: Array = [Vector3.INF]
		if o.unterwegs() and (Vector2(o.home.x - von.x, o.home.z - von.z).length() > 1.0 or o.gang != "heim"):     # 717 C wie _seg_gap
			bei.append_array(o.bahn_punkte())
		for p in orte:
			for q in raster:
				for at in bei:
					g = minf(g, o.clearance(p + q, at))
	return g


## 562: ein Umweg [via] für den Weg rückwärts von [von] nach [nach] (beide Abschnitte hinter ihm, im Bild, der Rumpf in seiner
## Drehung mit WEG_LUFT frei; Versatz wie _detour); keiner frei: [von]
func _rueck_umweg(von: Vector3, nach: Vector3, skip = null) -> Vector3:
	var ab := Vector3(nach.x - von.x, 0.0, nach.z - von.z)
	var n := ab.length()
	if n < 0.05:
		return von
	var d := ab / n
	var side := Vector3(-d.z, 0.0, d.x)
	var blick := Vector3(basis.z.x, 0.0, basis.z.z)
	for k in range(1, 13):
		for at in [0.5, 0.35, 0.65]:
			for sg in [1.0, -1.0]:
				var via: Vector3 = von + d * (n * at) + side * (0.2 * k * sg)
				var w := von.distance_to(via) + via.distance_to(nach)
				if w > RUECK_M or not (_rueckwaerts(von, via, w) and _rueckwaerts(via, nach, w)) or not _im_bild(via, blick):
					continue
				if _rueck_luft(von, via, nach, skip) >= WEG_LUFT:
					return via
	return von


## 438: kleinste Luft des Rumpfs, dreht sich das Tier am Ort von [von] nach [nach] (in 15°-Schritten)
func _dreh_luft(von: float, nach: float) -> float:
	return _dreh_luft_bogen(von, wrapf(nach - von, -PI, PI))


## 438: Luft des Rumpfs, wenn er von [von] um [dw] auf der Stelle dreht
func _dreh_luft_bogen(von: float, dw: float) -> float:
	var n := maxi(1, int(ceilf(absf(rad_to_deg(dw)) / 15.0)))
	var g := INF
	for i in range(1, n + 1):
		g = minf(g, _rumpf_luft(position, von + dw * i / n))
	return g


## Hängt an [tw] eine Drehung von [von] auf [nach] an, im Tempo TURN_DPS, mit [nm] (kleine Winkel sofort); gibt Dauer und Ziel zurück
func _dreh(tw: Tween, von: float, nach: float, nm: String) -> Array:
	var dw := wrapf(nach - von, -PI, PI)
	if absf(rad_to_deg(dw)) < TURN_STILL:
		tw.tween_callback(func(): rotation.y = von + dw)
		return [0.0, von + dw]
	var t := absf(rad_to_deg(dw)) / TURN_DPS
	tw.tween_callback(func():
		rotation.y = von
		if nm != "":
			_play(nm, 0.1))
	tw.tween_property(self, "rotation:y", von + dw, t)
	return [t, von + dw]


## 348.12 nachbessern (Chef 28.10., 15:23, Archiv: „warum läuft der dann nicht mit einer Animation, sondern wird wieder über den Platz
## geschoben? … Der Axthieb trifft auch nicht“): ein Zweibeiner mit Wurzelweg (Grak) geht mit den Schritten der Quelle (weiter als
## RUN_FROM: rennt) bis vor das Ziel, so weit und so gedreht, dass die Schneide beim Aufschlag (info „hieb“) AXT_IM_RAND im Rand
## des Ziels liegt, und schlägt dort; dann zurück, das Gesicht zum Ziel (Zurück, sonst Gehen rückwärts), daheim zur Blickrichtung.
## Gibt wie strike() die Zeit bis zum Aufschlag / 0,42 zurück (ms).
func _hieb(other, weiter := 0.0) -> int:
	var flat := Vector3(other.position.x - position.x, 0.0, other.position.z - position.z)
	if flat.length() < 0.01:
		flat = basis.z
	var dir := flat.normalized()
	var stand: float = other.body_r() - AXT_IM_RAND + float(hieb[0]) * model.scale.x     # Ursprung bis Mitte des Ziels beim Aufschlag
	# 709 (Chef 08.11., 21:36: „dass die Angriffe so sind, dass sie den Gegner treffen“): wie beim Helden der Stand nach dem Weg der
	# Waffe durch den Hieb gegen den Körper des Ziels (HIEB_TIEF darin, daneben [weiter] davor), Aufschlag im nächsten Punkt; der
	# eigene Körper bleibt HIEB_KOERPER_LUFT vor Körper und Schild. Ohne gemessenen Weg wie bisher (info „hieb“)
	var auf: float = float(hieb[1])
	# nur mit Waffe in der Hand (_hold); Krogg trägt sie im Modell, dann wäre der Kopf die Waffe (_hieb_bahn beim Tier)
	var bb: Array = _hieb_bahn("Hieb", deg_to_rad(float(hieb[2]))) if traegt().any(func(g): return g[2] != "" and not String(g[2]).to_lower().contains("shield")) else []
	if not bb.is_empty():
		var pl: Array = hieb_plan(bb, other.koerper(), other.position, dir, weiter if weiter > 0.0 else -HIEB_TIEF, HIEB_KOERPER_LUFT, other.schild_kapseln())
		if OS.get_environment("SCHAU_709") != "":
			print("709 Hieb %s an %s: Stand %.2f (Waffe %.2f, Körper %.2f), vorher %.2f" % [fighter.id, other.fighter.id, pl[0], pl[2], pl[3], stand])
		if pl[2] > 0.0:
			stand = pl[0]
			auf = float(pl[1]) / maxf(float(tempo.get("Hieb", 1.0)), 0.1) + HIEB_VERZUG
	var start := position + dir * (flat.length() - stand)
	var schlag := atan2(dir.x, dir.z) + deg_to_rad(float(hieb[2]))
	angriff_von = start     # die Schneide, nicht die Körperachse zum Ziel
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	gang = "anlauf"
	var yaw := rotation.y
	var t_run := 0.0
	var run := start.distance_to(position)
	if run > 0.12 and flat.length() > stand:
		# 399.2: um die anderen herum wie die Heldin
		var via := _detour(position, start, other)
		var pts := [start] if via == position else [via, start]
		var way := run if via == position else position.distance_to(via) + via.distance_to(start)
		var gn := _gangart(way)
		var von := position
		for q in pts:
			var a: Vector3 = q - von
			var d: Array = _dreh(tween, yaw, atan2(a.x, a.z), "Gehen")
			yaw = d[1]
			t_run += d[0]
			var t: float = von.distance_to(q) / _mps(gn)
			tween.tween_callback(func(): _play(gn, 0.12))
			tween.tween_property(self, "position", q, t)
			t_run += t
			von = q
	elif run > 0.12:     # zu nah: rückwärts bis auf Reichweite, das Gesicht zum Ziel
		var d: Array = _dreh(tween, yaw, atan2(dir.x, dir.z), "Gehen")
		yaw = d[1]
		var t: float = run / _mps("Gehen")
		tween.tween_callback(func(): anim.play("Gehen", 0.1, -1.0))
		tween.tween_property(self, "position", start, t)
		t_run = d[0] + t
	var d2: Array = _dreh(tween, yaw, schlag, "Stehen")
	t_run += d2[0]
	var bl: float = anim.get_animation("Hieb").length if anim and anim.has_animation("Hieb") else 0.9
	tween.tween_callback(func(): gang = "hieb"; _play("Hieb", 0.08))
	tween.tween_interval(bl)
	# zurück, das Gesicht zum Ziel, um die anderen herum
	var vh := _detour(start, home, other)
	var back := [home] if vh == start else [vh, home]
	var weit := start.distance_to(home) if vh == start else start.distance_to(vh) + vh.distance_to(home)
	# 717 C (F7): nur ein bis zwei Schritte zurück, dort stehen; in die Reihe mit dem eigenen Zug
	if _bleib_717():
		var ab: Vector3 = start + (back[0] - start).limit_length(ABSETZEN * _scale())
		back = [ab]
		weit = start.distance_to(ab)
	var t_back := 0.0
	if weit > 0.12:
		var rn := "Zurück" if weg.has("Zurück") and anim.has_animation("Zurück") and weit > 0.3 and not _zweibeiner() else "Gehen"     # 348.12: Grak schreitet rückwärts
		var v := _mps(rn) if rn == "Zurück" else _mps("Gehen")
		var von := start
		var y := float(d2[1])
		tween.tween_callback(func(): gang = "zurück"; anim.play(rn, 0.15, 1.0 if rn == "Zurück" else -float(tempo.get("Gehen", 1.0))))     # 348.12: im Tempo von _mps
		for q in back:
			var a: Vector3 = von - q     # rückwärts: das Gesicht weg vom Ziel des Schritts
			var d: Array = _dreh(tween, y, atan2(a.x, a.z), "")
			y = d[1]
			var t: float = von.distance_to(q) / v
			tween.tween_property(self, "position", q, t)
			t_back += d[0] + t
			von = q
	tween.tween_callback(func(): gang = "heim"; _turn_home())
	busy_ms = int((t_run + bl + t_back + 180.0 / TURN_DPS) * 1000.0)
	anlauf_ms = int(t_run * 1000.0)
	return int((t_run + auf) * 1000.0 / 0.42)


## Ground under the figure where no grass grows (halm.gdshader spots): x, z, radius.
func grass_spot() -> Vector3:
	var wolf: bool = vier(fighter)
	var c := to_global(Vector3(0, 0, 0.15 * _scale() if wolf else 0.0))
	return Vector3(c.x, c.z, 0.5 * _scale() if wolf else 0.3)


## Im Schlag unterwegs (Hin- und Rückweg): zählt beim Ausweichen der Ansagen nicht (Helfer Lauf 126: Ansagen sprangen um
## 300–400 px, während die Heldin zum Wolf und zurück lief)
func lunging() -> bool:
	return tween != null and tween.is_running() and gang != "dreh"


func falling() -> bool:
	# Spielzeit wie die Zeitgeber in die(): mit --write-movie lief die Wanduhr davon, die Ansage galt zu früh als ausgeblendet
	return dead_at >= 0 and kampfort.clock_ms - dead_at < sterbe_ms() + LIEGT_MS + FADE_MS


## 440 (Chef 31.10., 23:34: „Der Wolf war einfach weg. Da fehlt die Sterbeanimation … Zu schnell weg.“): die Ausblendung begann
## nach FALL_MS (0,9 s) mitten im Tod des Kaufwolfs (1,67 s), nach 1,5 s war er fort. Jetzt fällt er ganz (Länge seiner Bewegung
## „Tod“), liegt LIEGT_MS und vergeht erst dann; so lange warten auch die anderen mit dem Aufrücken (kampfort.gd, 439).
const LIEGT_MS := 1200
func sterbe_ms() -> int:
	if anim and anim.has_animation(tod_name):
		return maxi(FALL_MS, int(anim.get_animation(tod_name).length * 1000.0))     # die() spielt sie mit Tempo 1
	return FALL_MS


## The announced intent (or none): a wolf about to pounce crouches.
func announce(intent, at = null) -> void:
	if intent != null:     # 494: bleibt bis zum Zug (davor nimmt eine Meldung ohne Ansage sie weg, wie „Anspringen!“ beim Wolf)
		angesagt = intent
	var p: bool = intent != null and intent.effect == "POUNCE"
	var turned: bool = at != aim
	aim = at
	if turned and not (tween and tween.is_running()) and halt == null and not bedroht():
		if TURN_DPS_ART.has(art()):     # 595 (nachgestellt 10.11.: 17° in einem Bild bei neuer Ansage): langsam hindrehen
			_face_sanft()
		else:
			_face()
	# 439: „Anspringen!“ (FOE_STRIKES) nimmt die Ansage weg, der Biss folgt in der nächsten Meldung; so lange gilt der Sprung
	if pouncing and not p:
		sprung_bereit = intent == null
	elif p:
		sprung_bereit = false
	if p != pouncing:
		pouncing = p
		_idle_wenn_frei()     # 438 (wolf_mess_438: kauerte unterwegs heim und glitt 4,8 m in Hocke): unterwegs erst daheim


## 494 Riesenspinne: zuletzt angesagte Absicht (announce); „Netz werfen“ spielt den Netzwurf, wann das Netz losfliegt (ms)
var angesagt = null
var netz_los_ms := -1
const NETZ_LOS := 0.45      # Anteil des Netzwurfs, bei dem das Netz den Hinterleib verlässt (Stichprobe im Kauf, ungeprüft: 511)

## A blow, bite, shot or spell at [other]; returns how long it takes (ms).
## 662 (Chef t270.9: „keine Seite erkennbar“): wo der Angriff ankommt (Platz vor dem Biss oder Hieb, im Raum des Kampforts);
## danach richtet der Angegriffene die Parade aus. INF: gerade aus dem Stand (dann zählt, wo der Angreifer steht)
var angriff_von := Vector3.INF

func strike(other, e: Dictionary) -> int:
	_dreh_ab()
	angriff_von = Vector3.INF
	var spell: bool = e.spell != null
	var ranged: bool = fighter.ranged()
	netz_los_ms = -1
	# 494 (Zu 494, kein Chefentscheid): die Spinne zählt in MARS als Fernkämpfer (Netz aus der hinteren Reihe), sie beißt aber wie im
	# alten Spiel (SkirmishScreen: Pfeil nur bei attackFx ARROW, die Spinne hat BITE); nur „Netz werfen“ wirft, mit Netz statt Pfeil.
	# Vorher spielte sie bei jedem Angriff „Ausholen“ (hat sie nicht: stand still) und ein Pfeil flog
	if fighter.monster != null and fighter.monster.id == Mars.SPIDER and not spell:
		ranged = false
		var netz: bool = angesagt != null and angesagt.get("effect", "") == "WEB"
		angesagt = null
		if netz and anim and anim.has_animation("Netzwurf"):
			_schnaufen(0.6)
			_face(other.position - position)
			_play("Netzwurf", 0.1)
			var l: float = anim.get_animation("Netzwurf").length / float(tempo.get("Netzwurf", 1.0))
			netz_los_ms = int(l * NETZ_LOS * 1000.0)
			get_tree().create_timer(l).timeout.connect(_idle_wenn_frei)
			busy_ms = int(l * 1000.0)
			return netz_los_ms
	if spell or ranged:
		_schnaufen(0.6)
		_face(other.position - position)
		_play("Ausholen")
		get_tree().create_timer(0.6).timeout.connect(func(): _face(); _idle())
		busy_ms = 700
		return 700
	var leap: bool = fighter.monster != null and pouncing and Mars.koerper_of(fighter.monster) == Mars.WOLF
	letzter_sprung = leap or (sprung_bereit and fighter.monster != null)
	sprung_bereit = false
	if kauf:
		_schnaufen(1.0)
		# 438 (Prüfer Film r2: Klinge 31,2 s durch Wolf 2 ohne Treffer): daneben bleibt der Held VERFEHLT_M weiter weg
		return _held_schlag(other, VERFEHLT_M if e.get("roll") != null and Mars.ist_angriff(e.roll) and not e.roll[4] else 0.0)
	if _zweibeiner() and weg.has("Gehen") and hieb.size() >= 3:
		return _hieb(other, VERFEHLT_M if e.get("roll") != null and Mars.ist_angriff(e.roll) and not e.roll[4] else 0.0)
	if fighter.monster != null and weg.has("Gehen"):
		nach_biss = true     # 453: daheim zuerst Hecheln
		_schnaufen(1.0)     # 453 r2: nach dem Biss schneller und tiefer atmen
		if leap:
			pouncing = false
		# 438 (wolf_mess_438: beim Verfehlen wich der Held aus, sein Schild fuhr bis 6 cm um die Schnauze): daneben bleibt der Wolf weiter weg
		return _bite(other, leap, VERFEHLT_M if e.get("roll") != null and Mars.ist_angriff(e.roll) and not e.roll[4] else 0.0)
	var ms := BEAST_LUNGE_MS if fighter.monster != null else BLOW_MS
	var to: Vector3 = other.position
	var reach := (to - position) * (0.8 if leap else 0.6)
	var hold := ms * 0.16 / 1000.0
	var back := ms * 0.42 / 1000.0
	var hero: bool = fighter.monster == null
	if not hero and not leap:
		# 709 (treffen_709, Fledermaus ohne Gehen: der Ausfall ging 60 % des Wegs, der Biss blieb 1–2,6 m vor dem Ziel): bis die
		# Schnauze (Vorderkante des Umrisses) den Rand des Ziels erreicht
		var fl := Vector3(to.x - position.x, 0.0, to.z - position.z)
		if fl.length() > 0.01:
			var dn := fl.normalized()
			var st: float = other.vorne(-dn) + _schnauze_vorn() - BISS_TIEF
			reach = dn * maxf(0.0, fl.length() - st)
			# im Raum: Kopf und Kiefer jetzt, so weit verschoben, bis sie den Körper des Ziels erreichen (die Fledermaus fliegt höher
			# oder tiefer als der Rand am Boden sagt; treffen_709: so blieb sie 0,3–0,5 m davor)
			var m := _schnauze_bis(other.koerper(), dn, fl.length())
			if m >= 0.0:
				reach = dn * m
	if hero:
		# 348.7 (Prüfer 26.10.: die Heldin schlug aus etwa zwei Wolfslängen): nur bis in Waffenreichweite vor den Rand des Ziels
		var flat := Vector3(to.x - position.x, 0.0, to.z - position.z)
		var stand: float = HERO_R + other.body_r() + HERO_REACH
		reach = flat.normalized() * maxf(0.0, flat.length() - stand) if flat.length() > 0.01 else Vector3.ZERO
		hold = ms * (STEP_BACK - STEP_HOLD) / 1000.0
		back = clampf(reach.length() / HERO_BACK_MPS, HERO_BACK_S, HERO_BACK_MAX_S)
	var there := position + reach
	gang = "hin"
	_face(to - position)
	_play("Sprung" if leap else ("Biss" if fighter.monster != null else "Hieb"), 0.05)
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	var out := ms * STEP_HOLD / 1000.0
	anlauf_ms = 0 if hero else int(out * 1000.0)     # 399.2: wer mit dem Tier den Platz tauscht, geht erst, wenn es am Ziel ist
	# auch hin um die anderen herum (PFAD=1: Hinweg 0,2–0,3 m im Umriss des Nachbarn)
	var via_out: Vector3 = _detour(position, there, other)     # 399.2: auch ein Tier ohne Wurzelweg
	if hero and OS.get_environment("PFAD") != "":
		print("Umweg hin ", position, " -> ", via_out, " -> ", there, " Luft gerade %.2f, mit Umweg %.2f" % [_seg_gap(position, there, other), minf(_seg_gap(position, via_out, other), _seg_gap(via_out, there, other))])
	if via_out != position:
		var o1 := position.distance_to(via_out) / (position.distance_to(via_out) + via_out.distance_to(there)) * out
		tween.tween_property(self, "position", via_out, o1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(self, "position", there, out - o1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(self, "position", there, out).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(hold)
	# Rückweg um die anderen herum (lief durch den Nachbarwolf zurück): ein Umweg, wenn die Gerade jemanden streift; die Heldin
	# rechnet ihn erst, wenn sie losgeht (Prüfer Runde 3b: der Wolf dreht sich unterdessen nach ihr, sein Kopf stand im Weg)
	if hero:
		tween.tween_callback(func(): _back_home(back, other))
		busy_ms = int(ms * STEP_BACK + back * 1000.0)
		return ms
	tween.tween_callback(func(): _tier_heim(back, other))
	if leap:
		pouncing = false
	busy_ms = ms
	return ms


## 403 (M Perikles: „Held gleitet im Kampf, Fehler“): der Kaufheld geht (weiter als RUN_FROM: rennt) im Tempo seiner Schritte bis
## in Waffenreichweite vor den Rand des Ziels (HeldFigur: gehen_m_je_s, rennen_m_je_s), schlägt dort im Stand (Hieb, Aufschlag bei
## HELD_AUFSCHLAG) und geht rückwärts heim (_back_home); vorher glitt er während des Hiebs bis zu zwei Meter ohne Schritt heran.
const HELD_LUFT := 0.3
const HELD_AUFSCHLAG := 0.37     # kampf.py Hieb: Aufschlag 0,37 s
const HELD_ZURUECK := 2.0        # rückwärts Gehen im doppelten Schritttempo

## Führt der Held einen Stab? Dann ruht er in Stehen, den Stab senkrecht (kampf.py hat Kampfstehen für die Klinge gebaut)
func _stab() -> bool:
	var w = _in_hand() if fighter.monster == null else null     # 999: der Stab, den er gerade führt
	return w != null and not bool(w.ranged) and String(w.id) in STAFFS


func _held_mps(nm: String) -> float:
	if nm.begins_with("SS_") and float(kampf_info.get("tempo", {}).get(nm, 0.0)) > 0.1:     # 406: aus held_kampf.py, am Fuß gemessen
		return float(kampf_info["tempo"][nm]) * ss_f
	var v: float = float(model.get_meta("rennen_m_je_s" if nm == "Rennen" else "gehen_m_je_s", 0.0))
	return v if v > 0.1 else (WALK_MPS * 2.0 if nm == "Rennen" else WALK_MPS)


## 406.2: Gehen zum Angriff so viel schneller als das Gehen des Satzes (Bewegung und Weg). 562 (Chef 04.11., 17:02: „völlig im
## Schlaf-Tabletten-Modus … gleiten sie nach dem Angriff doch relativ flott zurück“; Lauf 266 SS TEMPO: vor 0,67, rückwärts 0,75 m/s):
## mit 1,3 ging er 0,87 m/s hin, zurück im Mittel 1,75 m/s mit Sinuskurve (Spitze 2,7 m/s bei gleichem Schritttempo: Gleiten).
## Jetzt hin 1,34 und zurück 1,5 m/s, je Schritte im Tempo des Wegs (Füße stehen), zurück ohne Kurve
const ANGRIFF_GANG := 2.0
const VERFEHLT_M := 0.3
const NIEDRIG_M := 0.8          # 595: Ziel mit dem Rücken so tief (Egel 0,27, Ratte 0,56, Schnecke 0,69 m): Hieb nach Zielhöhe
const HIEB_VOR := 0.12
const HIEB_ZURUECK_M := 0.3
const HIEB_TIEF := 0.02           # 709: so tief dringt die Klinge beim Treffer in den Körper (Kapseln)
const HIEB_KOERPER_LUFT := 0.02   # 709: Körper und Schild bleiben im ganzen Hieb so weit vor dem Körper des Ziels (E3)
const BISS_UMRISS := 0.03         # 709: so viel Luft hält der Umriss des Tiers am Bissplatz zu allen (wolf_mess_438: 5 cm tief erlaubt)
const BISS_LUFT := 0.05           # 709: Körper und Schnauze bleiben so weit vor Körper und Schild des Ziels (wolf_mess_438: 4 cm im Schild)
const BISS_TIEF := 0.01           # 709: so tief fasst die Schnauze beim Treffer in den Körper (Kapseln; wolf_mess_438 erlaubt 3 cm)
const NACH_T := 0.2               # 709: so lange nach dem Aufschlag beginnt der „zweite Schwung“ (hieb_plan [4])
const NACH_LUFT := 0.12           # 709: so weit bleibt die Waffe danach vom Ziel (der Getroffene zuckt bis 0,1 m vor)
const HIEB_VERZUG := 0.05         # 709: der Hieb beginnt mit Überblendung (0,08 s) ein Bild nach dem Aufruf; so viel später der Aufschlag
func _held_schlag(other, weiter := 0.0) -> int:
	var to: Vector3 = other.position
	# 717.1 A (Chef 09.11., 09:03; F8): rückt das Ziel noch zurecht, geht der Held zu dem Platz, an dem es ankommt (er wartet nur auf
	# sein eigenes Ziel, nicht auf die anderen)
	var ziel_bei := Vector3.INF
	if other.unterwegs() and not other.bahn.is_empty():
		ziel_bei = other.bahn[other.bahn.size() - 1]
		to = Vector3(ziel_bei.x, to.y, ziel_bei.z)
	var flat := Vector3(to.x - position.x, 0.0, to.z - position.z)
	var stand: float = HERO_R + other.body_r() + HERO_REACH + (HIEB_VOR if _ss() else 0.0)
	var stand_voll := stand
	# 438 (wolf_mess_438: beim Hieb stand der Held 2 cm vor dem Wolfskopf, der Kreis body_r() kennt den langen Kopf nicht): nie
	# näher als HELD_LUFT vor dem Umriss des Ziels in Laufrichtung
	if flat.length() > 0.01:
		var d := flat.normalized()
		var t := stand
		# 438 (wolf_mess_438, Kämpfer: Schild 14 cm im Kopf des kauernden Wolfs): der eigene Rand mit Schild und Klinge, nicht der Kreis
		var eigen := maxf(HERO_R, vorne(d))
		# 438 (wolf_mess_438, Kämpfer 58,9 s: Langschwert beim Hieb 6–11 cm im Kopf des Wolfs): der Hieb aus Sword & Shield holt
		# weiter aus als die Ruhehaltung, die vorne() misst
		if _ss():
			eigen += HIEB_VOR
		while t < flat.length() and other.clearance(to - d * t, ziel_bei) < eigen + HELD_LUFT + weiter:
			t += 0.05
		stand_voll = t
		stand = minf(t, flat.length())
	# 406: mit Schild einer der drei Schwerthiebe des Satzes, Aufschlag wie gemessen (held_kampf.py „kontakt“)
	var hn := "Hieb"
	var auf := HELD_AUFSCHLAG
	var hiebe: Array = ["Hieb"]
	if _ss():
		hiebe = ["SS_SwordAttack1", "SS_SwordAttack2", "SS_SwordAttack3"].filter(func(x): return anim.has_animation(x))
		if not hiebe.is_empty():
			hn = hiebe[randi() % hiebe.size()]
			auf = float(kampf_info.get("kontakt", {}).get(hn, HELD_AUFSCHLAG))
	# 595 (Chef 11.11., 20:09, wiederholt: „der eine … kein Schild … steckt ja immer oben drüber … der mit Schwert und Schild schlägt
	# manchmal von oben nach unten … aber manchmal schlägt er auch einfach drüber“; treffhoehe_595, Egel 0,27 m hoch: tiefster Punkt der
	# Klinge im Hieb ohne Schild 0,80 m, mit Schild SS_SwordAttack1 0,61, 3 0,33, nur 2 0,13 m, und der 0,32 m rechts neben der Mitte):
	# gegen ein niedriges Ziel nur, was hinunterreicht, für jeden, nach der Höhe des Ziels; der Held tritt so weit seitlich, dass der
	# tiefste Punkt der Klinge auf die Mitte des Ziels fällt. Ohne Schild zählen die Schwerthiebe des Satzes mit, wenn er sie hat
	var seit := 0.0
	var ruecken := INF
	if other.has_method("niedrig") and other.niedrig() and not _hieb_bahn(hn).is_empty():
		ruecken = -INF
		for c in (other.koerper_ruhe() if other.has_method("koerper_ruhe") else other.koerper()):
			ruecken = maxf(ruecken, maxf((c[0] as Vector3).y, (c[1] as Vector3).y) + float(c[2]))
		ruecken -= other.position.y
	if ruecken <= NIEDRIG_M:
		var reicht := func(h): return _landepunkt(h).y <= ruecken - HIEB_TIEF
		var tief_genug: Array = hiebe.filter(reicht)
		if tief_genug.is_empty() and not _ss():
			tief_genug = ["SS_SwordAttack1", "SS_SwordAttack2", "SS_SwordAttack3"].filter(func(x): return anim.has_animation(x) and reicht.call(x))
		if tief_genug.is_empty():
			var alle: Array = hiebe + ["SS_SwordAttack1", "SS_SwordAttack2", "SS_SwordAttack3"].filter(func(x): return anim.has_animation(x) and not x in hiebe)
			alle.sort_custom(func(a1, b1): return _landepunkt(a1).y < _landepunkt(b1).y)
			tief_genug = alle.slice(0, 1)
		hiebe = tief_genug
		hn = hiebe[randi() % hiebe.size()]
		auf = float(kampf_info.get("kontakt", {}).get(hn, HELD_AUFSCHLAG))
		seit = _landepunkt(hn).x
	# 709 (Chef 08.11., 21:36: „dass die Angriffe so sind, dass sie den Gegner treffen“; treffen_709: die Klinge blieb beim Treffer
	# 0,1–1 m vor dem Körper, der Aufschlag lag bis 3 Bilder neben ihrem nächsten Punkt): der Stand nach dem Weg der Klinge durch
	# den Hieb gegen den Körper des Ziels; beim Treffer dringt sie HIEB_TIEF ein, daneben bleibt sie [weiter] davor. Der Aufschlag
	# ist der Augenblick, in dem sie ihm am nächsten ist. Körper und Schild in Ruhe bleiben HIEB_KOERPER_LUFT vor dem Umriss; ein
	# Hieb, der das Ziel von dort nicht erreicht (flach über die Schnecke), wird nicht gewählt, solange ein anderer es erreicht
	if flat.length() > 0.01 and not _hieb_bahn(hn).is_empty():
		var us := Time.get_ticks_usec()
		var d := flat.normalized()
		var ziel: Array = other.koerper_ruhe() if other.has_method("koerper_ruhe") else other.koerper()
		if ziel_bei != Vector3.INF:
			var v := Vector3(ziel_bei.x - other.position.x, 0.0, ziel_bei.z - other.position.z)
			ziel = ziel.map(func(c): return [c[0] + v, c[1] + v, c[2]])
		var soll: float = weiter if weiter > 0.0 else -HIEB_TIEF
		# erst der gewürfelte Hieb; erreicht er das Ziel nicht, ohne dass Körper oder Schild hineingehen, ein anderer, sonst der weiteste
		var nied: bool = seit != 0.0
		var plan: Array = _hieb_plan_merk(hn, other, ziel, to, d, soll, seit)
		var plaene := {hn: plan}
		# 709 (wolf_mess_438 Kämpfer 84,3 s: SS_SwordAttack2 schwingt zweimal, der getroffene Wolf zuckt in „Treffer“ nach vorn, der
		# zweite Schwung fuhr 0,12 m in ihn): ein Hieb, dessen zweiter Schwung dem Ziel nach dem Aufschlag noch NACH_LUFT nahe kommt,
		# nur, wenn keiner der anderen sauber trifft
		var wert := func(pl: Array) -> float:
			return minf(pl[2] - pl[3] + 0.02, 0.0) + (0.0 if pl.size() < 5 or pl[4] >= NACH_LUFT else -0.5)
		if wert.call(plan) < 0.0:
			var rest: Array = hiebe.filter(func(h): return h != hn)
			rest.shuffle()
			var best: String = hn
			for h in rest:
				plaene[h] = _hieb_plan_merk(h, other, ziel, to, d, soll, _landepunkt(h).x if nied else 0.0)
				if wert.call(plaene[h]) > wert.call(plaene[best]):
					best = h
				if wert.call(plaene[h]) >= 0.0:
					break
			hn = best
			plan = plaene[hn]
			if nied:
				seit = _landepunkt(hn).x
		stand_voll = plan[0]
		stand = minf(stand_voll, flat.length())
		auf = float(plan[1]) / maxf(float(tempo.get(hn, 1.0)), 0.1) + HIEB_VERZUG
		if OS.get_environment("SCHAU_709") != "":
			print("709 Ziel %s: pos %s glob %s heim %s; gang %s, tween %s, bahn %d, heim %.2f m weg" % [other.fighter.id, other.position, other.global_position, other.home, other.gang, other.tween != null and other.tween.is_running(), other.bahn.size(), Vector2(other.home.x - other.position.x, other.home.z - other.position.z).length()])
			print("709 Hieb %s %s an %s: Stand %.2f (Klinge %.2f, Körper %.2f), Abstand jetzt %.2f, Aufschlag %.2f s, %d µs, Pläne %d" % [fighter.id, hn, other.fighter.id, plan[0], plan[2], plan[3], flat.length(), auf, Time.get_ticks_usec() - us, plaene.size()])
	var start := position + flat.normalized() * maxf(0.0, flat.length() - stand) if flat.length() > 0.01 else position
	# 595: seitlich so weit, dass der tiefste Punkt der Klinge auf die Mitte des niedrigen Ziels fällt; der Blick bleibt zum Ziel parallel
	var blick: Vector3 = to - start
	if seit != 0.0 and flat.length() > 0.01:
		blick = flat.normalized()
		start -= Basis(Vector3.UP, atan2(blick.x, blick.z)) * Vector3(seit, 0.0, 0.0)
	# 717 C (wolf_mess_438: der abgesetzte Wolf stand dort, wo der Held zum Hieb auf einen anderen hintrat, 22 cm ineinander): steht am
	# Platz des Hiebs ein anderer, tritt der Held seitlich versetzt an das Ziel heran
	if flat.length() > 0.01 and not _stand_frei(start, other):
		var off := start - to
		for w in [25.0, -25.0, 50.0, -50.0, 75.0, -75.0]:
			var p2 := to + off.rotated(Vector3.UP, deg_to_rad(w))
			if _stand_frei(p2, other):
				start = p2
				break
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	gang = "hin"
	var t_run := 0.0
	var run := position.distance_to(start)
	if run > 0.12:
		var via := _detour(position, start, other)
		var pts := [start] if via == position else [via, start]
		var way := run if via == position else position.distance_to(via) + via.distance_to(start)
		# 406 c (Chef 01.11., 20:2x, Film 406: der Stabkämpfer ist „zum Wolfangriff … eher hingehoppelt … Er sollte einfach hingehen“):
		# mit Stab geht der Held zum Ziel, auch weiter als RUN_FROM (das Rennen mit Schild aus Sword & Shield ist für die Klinge gemacht)
		var gn := _gang_ss("Rennen" if way > RUN_FROM and anim.has_animation("Rennen") and not _stab() else "Gehen")
		# 406.2 (Chef 03.11., 06:59, Schildfilm: „das Rennen … ist ein Gehopse nach vorne. Also bitte dann beim Angriff nicht rennen,
		# sondern gehen … ein bisschen schneller gehen“): mit Schild geht der Held zum Angriff, Bewegung und Weg um ANGRIFF_GANG schneller
		# (beide gleich, sonst rutschen die Füße)
		var gf := 1.0
		# 682 (Chef 08.11., 16:22: „wenn der Held jetzt mal flotter hinginge“; t270, 20:50: „Ich gehe wieder auf die Wölfe zu, als
		# ob ich in die Hose gemacht hätte“): der geduckte Kampfgang aus Sword & Shield, doppelt so schnell gespielt, trippelte mit
		# 1,4 m/s. Jetzt aufrecht im Schritt wie auf der Karte, den Schild oben (_angriff_gang, 2,13 m/s)
		if _ss() and anim.has_animation("Angriff_Gehen") and _glatt_an_682():
			gn = "Angriff_Gehen"
		elif _ss() and anim.has_animation("SS_WalkForward"):
			gn = "SS_WalkForward"
			gf = ANGRIFF_GANG
		var von := position
		for q in pts:
			var a: Vector3 = q - von
			tween.tween_callback(func():
				_face(a)
				_play(gn, 0.12)
				if gf != 1.0:
					anim.play(gn, 0.12, float(tempo.get(gn, 1.0)) * gf))
			var t: float = von.distance_to(q) / (_held_mps(gn) * gf)
			tween.tween_property(self, "position", q, t)
			t_run += t
			von = q
	# 438 (wolf_mess_438, Kämpfer 59,4 s: Gegenschlag aus dem Stand, der Wolf stand zum Biss so nah, dass das Langschwert 11 cm
	# in seinen Kopf fuhr): steht das Ziel näher als die Reichweite des Hiebs, erst ein kurzer Schritt zurück mit erhobenem Schild
	elif flat.length() > 0.01 and flat.length() < stand_voll - 0.03 and _ss() and anim.has_animation("SS_WalkBackwards"):
		var d0 := flat.normalized()
		var zur := position - d0 * minf(stand_voll - flat.length(), HIEB_ZURUECK_M)
		if _seg_gap(position, zur, other) >= 0.0:
			var tz: float = position.distance_to(zur) / maxf(_held_mps("SS_WalkBackwards"), 0.3)
			tween.tween_callback(func(): _face(d0); _play("SS_WalkBackwards", 0.08))
			tween.tween_property(self, "position", zur, tz)
			t_run += tz
			start = zur
	var bl: float = anim.get_animation(hn).length if anim.has_animation(hn) else BLOW_MS / 1000.0
	# 682 (schild_406: aus dem Gehen mitten im Schritt in den Hieb schob die Überblendung den Schild 7 cm ins Bein): am Ziel erst kurz
	# in die Kampfhaltung, dann der Hieb
	if t_run > 0.0 and anim.has_animation("Angriff_Gehen") and anim.has_animation("SS_IdleCombat"):
		tween.tween_callback(func(): _play("SS_IdleCombat", 0.1))
		tween.tween_interval(0.12)
		t_run += 0.12
	var ziel_ort: Vector3 = other.position
	tween.tween_callback(func():
		gang = "hieb"
		_face(blick)
		_play(hn, 0.08)
		if OS.get_environment("SCHAU_709") != "":
			print("709 Hieb los %s: ich %s, Ziel %s (bei Plan %s, start %s), Stand %.2f (geplant %.2f), Ziel ging %.2f m, steht jetzt %s" % [fighter.id, position, other.position, ziel_ort, start, Vector2(position.x - other.position.x, position.z - other.position.z).length(), stand_voll, Vector2(other.position.x - ziel_ort.x, other.position.z - ziel_ort.z).length(), String(other.anim.current_animation) if other.anim else ""]))
	tween.tween_interval(bl)
	var heim := start.distance_to(home)
	var back_mps := _held_mps("Gehen") * HELD_ZURUECK
	if _gang_ss("Zurück") == "SS_WalkBackwards":
		back_mps = _held_mps("SS_WalkBackwards") * ANGRIFF_GANG     # 562: zurück im Schritt wie hin
	var back := maxf(HERO_BACK_S, heim / back_mps)
	tween.tween_callback(func(): _back_home(back, other))
	if other.has_method("halt_fuer_hieb"):
		other.halt_fuer_hieb(int((t_run + bl + 0.2) * 1000.0))     # 900: bis zum Ende des Hiebs (im selben Bild wie der Plan)
	busy_ms = int((t_run + bl + back) * 1000.0)
	anlauf_ms = 0
	return int((t_run + auf) * 1000.0 / 0.42)


## Rückweg der Heldin: rückwärts, ohne Umdrehen (beim Umdrehen sah man Brust und Schildinnenseite: „andere Ausrüstung“, Helfer
## Lauf 126), mit Gehen rückwärts statt Gleiten (Prüfer Runde 3b), um die anderen herum
func _back_home(back: float, skip) -> void:
	var from := position
	var via := _detour(from, home, skip)
	var way := from.distance_to(via) + via.distance_to(home) if via != from else from.distance_to(home)
	# 562: mit Schild gleichmäßig (die Schritte laufen in einem Tempo; eine Kurve im Weg ließ die Füße in der Mitte gleiten)
	var gleich := false
	if anim and _gang_ss("Zurück") == "SS_WalkBackwards" and way > 0.2:
		# 406: mit Schild rückwärts wie der Satz (Schild bleibt oben), im Tempo seiner Schritte
		anim.play("SS_WalkBackwards", 0.12, clampf(way / back / _held_mps("SS_WalkBackwards"), 1.0, WALK_MAX))
		gleich = true
	elif anim and anim.has_animation("Gehen") and way > 0.2:
		_guard(true)
		anim.play("Gehen", 0.12, -clampf(way / back / (_held_mps("Gehen") if kauf else WALK_MPS), 1.0, WALK_MAX))
	tween = create_tween()
	var kurve := Tween.TRANS_LINEAR if gleich else Tween.TRANS_SINE
	if via != from:
		var b1 := from.distance_to(via) / way * back
		tween.tween_property(self, "position", via, b1).set_trans(kurve).set_ease(Tween.EASE_IN)
		tween.tween_property(self, "position", home, back - b1).set_trans(kurve).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(self, "position", home, back).set_trans(kurve).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func(): _guard(false); _face(); _idle())


## 399.2 (umweg_399: ohne Wurzelweg lief das Tier nach dem Biss gerade heim, durch den stehenden Nachbarn, bis −0,92 m): heim um
## die anderen herum wie die Heldin, den Umweg erst beim Losgehen gerechnet
func _tier_heim(back: float, skip) -> void:
	gang = "zurück"
	var from := position
	# 717 C: ein Stück zurück (ABSETZEN), dann stehen; in die Reihe mit dem eigenen Zug
	if _bleib_717():
		var weg_heim := Vector3(home.x - from.x, 0.0, home.z - from.z)
		var ziel := from + weg_heim.limit_length(ABSETZEN * _scale())
		tween = create_tween()
		tween.tween_property(self, "position", ziel, minf(back, 0.4)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_callback(func(): _face(); _idle())
		return
	var via := _detour(from, home, skip)
	tween = create_tween()
	# 717 (F7): auch ein Tier ohne Wurzelweg geht heim mit dem Gesicht zum Gegner, außer auf der Flucht
	var gesicht := fighter.monster != null and not flieht
	if via != from:
		var b1 := from.distance_to(via) / (from.distance_to(via) + via.distance_to(home)) * back
		if not gesicht:
			_face(via - from)
		tween.tween_property(self, "position", via, b1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		if not gesicht:
			tween.tween_callback(func(): _face(home - position))
		tween.tween_property(self, "position", home, back - b1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		if not gesicht:
			_face(home - from)
		tween.tween_property(self, "position", home, back).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func(): _face(); _idle())


## 348.7b (Chef 27.10., 19:36 „D“): wo ein Zauber oder Pfeil die Figur verlässt (Welt): die Spitze eines Stabs, sonst die Faust
## der Waffenhand (Bogen, Klinge) oder die rechte Hand; ohne Gerüst null
## 415 r4 (Tor 461a, Lauf 181, G1: hinteres Stabende des Magiers über dem Bildrand): Ecken der Waffe und des Schilds (Umrisskasten
## je Netz), damit die Kamera sie mit im Bild hält
func waffen_punkte() -> Array:
	var out := []
	if model == null:
		return out
	for nm in ["Waffe", "Schild"]:
		var w := model.find_child(nm, true, false) as Node3D
		if w == null or not w.visible:
			continue
		for m in w.find_children("*", "MeshInstance3D", true, false):
			var bb: AABB = (m as MeshInstance3D).get_aabb()
			for i in 8:
				out.append((m as MeshInstance3D).global_transform * bb.get_endpoint(i))
	return out


func cast_point():
	if model == null:
		return null
	var w := model.find_child("Waffe", true, false) as Node3D
	var off := model.find_child("Schild", true, false) as Node3D
	if off != null and off.get_meta("stab", false):     # Schamane: Stab links (Runde 4)
		w = off
	if w != null and w.get_meta("stab", false):
		var top := -INF
		var pts := []
		for m in w.find_children("*", "MeshInstance3D", true, false):
			var bb: AABB = (m as MeshInstance3D).get_aabb()
			for i in 8:
				var q: Vector3 = (m as MeshInstance3D).global_transform * bb.get_endpoint(i)
				pts.append(q)
				top = maxf(top, q.y)
		var tip := Vector3.ZERO
		var n := 0
		for q in pts:
			if q.y > top - 0.03:
				tip += q
				n += 1
		if n > 0:
			return tip / n
	if w != null:
		return w.global_position
	var sk := _find(model, "Skeleton3D") as Skeleton3D
	if sk == null:
		return null
	var bi := sk.find_bone("foR-wrR")
	if bi < 0:
		bi = sk.find_bone("hand_r")
	if bi < 0:
		return null
	return sk.global_transform * sk.get_bone_global_pose(bi).origin


## 348.7b (Chef 27.10., 19:49): ein kleiner Schritt um off (Welt, waagerecht) für freie Linie, dort hold_s stehen (zaubern oder
## schießen), dann zurück an den eigenen Platz; je Weg step_s; nur Darstellung (keine Bewegung im Kampf, wie der Hieb im alten MARS)
func side_step(off: Vector3, hold_s: float, step_s: float) -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "position", home + off, step_s).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(hold_s)
	tween.tween_callback(func():     # zurück an den Platz, der dann gilt (glide_to wartet, solange der Schritt läuft)
		tween = create_tween()
		tween.tween_property(self, "position", home, step_s).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT))
	busy_ms = maxi(busy_ms, int((2.0 * step_s + hold_s) * 1000.0))


## Prüfer Runde 4: beim Gehen rückwärts schwang der Waffenarm mit offener Hand an der Hüfte, die Waffe stand daneben. Die Arme
## bleiben darum in der Haltung, in der sie losgeht (Deckung), nur die Beine gehen.
class ArmHold extends SkeletonModifier3D:
	var poses := {}
	func _process_modification_with_delta(_delta: float) -> void:
		var sk := get_skeleton()
		if sk == null:
			return
		for bi in poses:
			sk.set_bone_pose(bi, poses[bi])

var arm_hold: ArmHold


## 406a E3 (Tor 461a; Lauf 170: Finger der Schildhand liegen außen auf dem Schild, 3 bis 8,6 cm vor der Vorderseite; Lauf 182 und 184:
## schild_406 beugt Zeige- bis kleinen Finger je Glied um die Achse quer über die Knöchel, −50° am besten: Kämpfer 1,7–2,3 cm,
## Kleriker 3,5–3,8 cm, −75° und −90° nicht besser): nach jeder Pose aus dem Satz die Finger der linken Hand um FAUST_GRAD weiter
## zur Faust, so wie schild_406 _beugen_finger gemessen hat
const FAUST_GRAD := -50.0
## 406a E3 Lauf 190 (Faust −50°, gemessen in skeleton_updated): Kämpfer 2,1–2,7 cm, Kleriker 3,7–4,0 cm vor der Vorderseite, vor allem
## Ring- und kleiner Finger; Knick im Handgelenk nach hinten je Klasse (Knöchel etwa 9 cm vom Gelenk: 3 cm ≈ 20°, 4,5 cm ≈ 30°),
## gemessen mit schild_406 KNICK (je ±10° dazu)
const KNICK_GRAD := {"WACHE": 20.0, "KLOSTER": 30.0}     # 870.4: je Tracht (vorher je Klasse)
const KLASSE_HERKUNFT := {"FIGHTER": "Wachsoldat", "CLERIC": "Klosterschüler", "ROGUE": "Herumtreiber", "WIZARD": "Zauberlehrling"}


## 870.4: Herkunft des Helden für die Tracht; Probeblätter (probe.gd, Tabellen.probe()) nennen noch die Klasse
func _herkunft() -> String:
	var h := String(fighter.hero.get("herkunft", ""))
	return h if h != "" else String(KLASSE_HERKUNFT.get(String(fighter.hero.get("cls", "")), "Wachsoldat"))


func _tracht() -> String:
	return String(HeldFigur.lade_info().get("herkuenfte", {}).get(HeldFigur.kennung(_herkunft()), {}).get("tracht", ""))
var knick_achse := Vector3.ZERO
var knick_quat := Quaternion.IDENTITY
var knick_knochen := -1
class SchildFaust extends SkeletonModifier3D:
	var glieder := PackedInt32Array()
	var zf := -1
	var kf := -1
	var hand := -1
	var knick := Quaternion.IDENTITY     # im Raum der Hand, um das Handgelenk (figur.gd _hold)
	var achse := Vector3.ZERO     # Achse des Knicks im Raum der Hand (schild_406 misst damit weitere Winkel)
	func _process_modification_with_delta(_delta: float) -> void:
		var sk := get_skeleton()
		if sk == null:
			return
		if hand >= 0 and knick != Quaternion.IDENTITY:
			sk.set_bone_pose_rotation(hand, sk.get_bone_pose_rotation(hand) * knick)
		if glieder.is_empty():
			for f in ["index", "middle", "ring", "pinky"]:
				for n in ["01", "02", "03"]:
					var b := sk.find_bone("%s_%s_l" % [f, n])
					if b >= 0:
						glieder.append(b)
			zf = sk.find_bone("index_01_l")
			kf = sk.find_bone("pinky_01_l")
		if zf < 0 or kf < 0:
			return
		var quer := (sk.get_bone_global_pose(zf).origin - sk.get_bone_global_pose(kf).origin).normalized()
		for b in glieder:
			var pg := sk.get_bone_global_pose(sk.get_bone_parent(b))
			var achse := (pg.basis.inverse() * quer).normalized()
			sk.set_bone_pose_rotation(b, Quaternion(achse, deg_to_rad(FAUST_GRAD)) * sk.get_bone_pose_rotation(b))

var schild_faust: SchildFaust

func _guard(on: bool) -> void:
	var sk := _find(model, "Skeleton3D") as Skeleton3D
	if sk == null:
		return
	if arm_hold == null:
		arm_hold = ArmHold.new()
		sk.add_child(arm_hold)
	if on:
		arm_hold.poses.clear()
		for bi in sk.get_bone_count():
			var nm := sk.get_bone_name(bi)
			if nm.begins_with("chestTop-sh") or nm.begins_with("sh") or nm.begins_with("up") or nm.begins_with("el") or nm.begins_with("fo"):
				arm_hold.poses[bi] = sk.get_bone_pose(bi)
	arm_hold.active = on


## Halbe Breite am Boden, wie der Bodenschatten (Wolf 1,1 m lang, halb seitlich gesehen; Mensch 0,3 m)
func body_r() -> float:
	if vier(fighter):
		if mass.has("laenge_m"):     # 387: Kauftier, wie der Wolf (1,1 m lang, 0,45 m) nach seiner Länge
			return 0.45 / 1.1 * mass.laenge_m * _scale()
		return 0.45 * _scale()
	return HERO_R * (_scale() if fighter.monster != null else 1.0)


## Umriss am Boden im eigenen Raum (Kasten der Netze in Ruhe); ein Wolf ist lang, der Kreis aus body_r() verfehlte den
## Kopf (Prüfer Runde 3b: die Heldin lief durch Wolf 2 zurück; PFAD=1 maß 0,18 m im Umriss bei 0,38 m Kreisabstand)
const KAUF_KNOCHEN := ["pelvis", "spine_01", "spine_02", "spine_03", "neck_01", "Head", "clavicle_l", "clavicle_r", "thigh_l",
	"thigh_r", "calf_l", "calf_r", "foot_l", "foot_r", "ball_l", "ball_r"]
const KAUF_RAND := 0.15
var _foot := AABB()
var _foot_ok := false
## 709: Unterkante des Schilds über dem Boden (m, lokal) beim letzten footprint(); wer niedriger ist, läuft unter ihm durch
var schild_unten := INF
func footprint(hoehe := INF) -> AABB:
	var f0 := _footprint()
	var koerper := f0
	schild_unten = INF
	# 406 (wolf_mess_438 mit Sword & Shield: Wolf 9 cm im Schild beim Rückweg): mit dem Satz hält der Held den Schild vor sich, nicht
	# mehr seitlich am Körper; sein Umriss (jetzige Lage, am Boden) gehört dazu
	if kauf and _ss() and model:
		var sch := model.find_child("Schild", true, false) as Node3D
		if sch:
			var inv := global_transform.affine_inverse()
			for m in sch.find_children("*", "MeshInstance3D", true, false):
				var bb: AABB = (inv * (m as MeshInstance3D).global_transform) * (m as MeshInstance3D).get_aabb()
				schild_unten = minf(schild_unten, bb.position.y)
				bb.position.y = 0.0
				bb.size.y = f0.size.y
				f0 = f0.merge(bb)
			# 709 (treffen_709 Ratten: Schild unten 0,73 m, Ratte oben 0,55 m; der Schild vor dem Helden sperrte jeden Bissplatz, die
			# Schnauze blieb 0,6–0,8 m vor ihm): wer ganz unter dem Schild bleibt, misst gegen den Körper; Schild und Schnauze prüft
			# hieb_plan räumlich
			if hoehe < schild_unten:
				return koerper
	return f0


func _footprint() -> AABB:
	if not _foot_ok:
		_foot_ok = true
		var inv := global_transform.affine_inverse()
		var first := true
		# 438 (wolf_mess_438): der Kaufkörper ruht in T-Haltung, sein Netzkasten ist mit den Armen 1,8 m breit; jeder Wolf nahe der
		# Gruppe stand so schon daheim „im“ Helden und fand keinen freien Weg. Beim Kaufkörper der Kasten der Rumpf- und Beinknochen
		# in Ruhe, um KAUF_RAND erweitert (Schulter, Hüfte, Fuß)
		var sk := _find(model, "Skeleton3D") as Skeleton3D if kauf and model else null
		if sk:
			for bn in KAUF_KNOCHEN:
				var bi := sk.find_bone(bn)
				if bi < 0:
					continue
				var q: Vector3 = inv * (sk.global_transform * sk.get_bone_global_rest(bi).origin)
				var bb := AABB(q - Vector3(KAUF_RAND, 0.0, KAUF_RAND), Vector3(2 * KAUF_RAND, 0.0, 2 * KAUF_RAND))
				_foot = bb if first else _foot.merge(bb)
				first = false
			if not first:
				_foot.position.y = 0.0
				_foot.size.y = 1.8
				return _foot
		for m in find_children("*", "MeshInstance3D", true, false):
			# 709 (treffen_709 Ratten: Umriss 0,9 m breit, an jedem Bissplatz 0,2–0,34 m im Helden, die Schnauze blieb 0,6–0,8 m vor
			# ihm): die Pfotenflecken liegen frei in der Welt, und der Bodenschatten ist um die Pfoten verbreitert, beides nur fürs Bild;
			# der Umriss ist der Schatten in seiner Grundgröße
			if m.has_meta("pfotenschatten"):
				continue
			var b: AABB = (inv * m.global_transform) * m.get_aabb()
			if m.name == "Bodenschatten" and _schatten_grund != Vector2.ZERO:
				b = AABB(m.position - Vector3(_schatten_grund.x, 0.0, _schatten_grund.y) * 0.5, Vector3(_schatten_grund.x, 0.0, _schatten_grund.y))
			_foot = b if first else _foot.merge(b)
			first = false
		if first:
			_foot = AABB(Vector3(-body_r(), 0, -body_r()), Vector3(2 * body_r(), 1, 2 * body_r()))
	return _foot


## 438 (Prüfer Film r2: Schnauze in Schild und Brust, Wolf im Kopf des Nachbarn, Dreiecke verschwinden): der Körper in der
## jetzigen Haltung als Kapseln [a, b, r] (Welt) um die Knochen, für Verdeckung und Messung; leer, wenn das Gerüst unbekannt ist.
## Mensch (Kaufkörper, UAL-Gerüst): Rumpf, Hals, Kopf, Beine, Arme; Tier: jeder Knochen zu seinem Elternknochen, Dicke nach Teil
const MENSCH_KAPSELN := [["pelvis", "spine_03", 0.17], ["spine_03", "neck_01", 0.14], ["neck_01", "Head", 0.08], ["Head", "Head", 0.11],
	["thigh_l", "calf_l", 0.08], ["thigh_r", "calf_r", 0.08], ["calf_l", "foot_l", 0.06], ["calf_r", "foot_r", 0.06],
	["upperarm_l", "lowerarm_l", 0.06], ["upperarm_r", "lowerarm_r", 0.06], ["lowerarm_l", "hand_l", 0.05], ["lowerarm_r", "hand_r", 0.05]]
const TIER_DICKE := [["Tongue", 0.015], ["Jaw", 0.04], ["Ear", 0.02], ["Tail", 0.04], ["pfote", 0.04], ["Knee", 0.04], ["Ankle", 0.035], ["Leg", 0.05],
	["Spine", 0.16], ["ROOT", 0.16], ["Neck", 0.11], ["kopf", 0.1], ["hals", 0.11], ["Head", 0.08]]
func kapseln() -> Array:
	var sk := _find(model, "Skeleton3D") as Skeleton3D if model else null
	if sk == null:
		return []
	var out: Array = []
	var g := sk.global_transform
	if fighter.monster == null:
		for c in MENSCH_KAPSELN:
			var i0 := sk.find_bone(c[0])
			var i1 := sk.find_bone(c[1])
			if i0 < 0 or i1 < 0:
				continue
			var a: Vector3 = g * sk.get_bone_global_pose(i0).origin
			var b: Vector3 = g * sk.get_bone_global_pose(i1).origin
			if c[0] == "Head":
				a += g.basis.y.normalized() * 0.1
				b = a
			out.append([a, b, float(c[2])])
		return out
	var s := absf(model.global_transform.basis.get_scale().x)     # das Gerüst selbst kann in cm stehen (Skelett 0,01)
	for i in sk.get_bone_count():
		var p := sk.get_bone_parent(i)
		if p < 0:
			continue
		var nm := sk.get_bone_name(i)
		var r := 0.05
		for d in TIER_DICKE:
			if nm.contains(d[0]):
				r = d[1]
				break
		out.append([g * sk.get_bone_global_pose(p).origin, g * sk.get_bone_global_pose(i).origin, r * s, nm])
	return out


## 709 (Chef 08.11., 21:36: „dass die Angriffe so sind, dass sie den Gegner treffen“): der Körper als Ziel eines Hiebs. Wie kapseln(),
## aber bei Gegnern mit fremdem Gerüst (Goblin, Kobold, Krogg, Grak: kapseln() gibt unbekannten Knochen 5 cm) Rumpf, Hals, Kopf und
## Oberschenkel dicker nach dem Namen des Knochens; Finger, Zunge, Ohren (unter 3 cm) zählen nicht
const ZIEL_DICKE := [["spine", 0.15], ["chest", 0.14], ["belly", 0.14], ["waist", 0.13], ["pelvis", 0.15], ["body", 0.15], ["torso", 0.15],
	["abdomen", 0.15], ["thorax", 0.12], ["neck", 0.08], ["head", 0.1], ["thigh", 0.08], ["upperarm", 0.06], ["upl", 0.05], ["upr", 0.05]]
func koerper() -> Array:
	var ks: Array = kapseln()
	if fighter.monster == null:
		return ks
	var s := absf(model.global_transform.basis.get_scale().x) if model else 1.0
	var out: Array = []
	for c in ks:
		var r: float = c[2]
		if c.size() > 3 and r <= 0.05 * s + 0.001:
			var nm := String(c[3]).to_lower()
			for d in ZIEL_DICKE:
				if nm.contains(String(d[0])):
					r = float(d[1]) * s
					break
		if r >= 0.03 * s:
			out.append([c[0], c[1], r, c[3]] if c.size() > 3 else [c[0], c[1], r])     # 709: der Name für _hieb_bahn
	return out


## 709: der Weg eines Angriffs [hn] im eigenen Raum (+Z zum Ziel, wie _face; [versatz]: so weit dreht die Figur beim Angriff aus der
## Richtung zum Ziel, z. B. die Schnauze im Biss), je 1/30 s: [t (s der Bewegung), Waffe, Körper], beide als Kapseln [[a, b, r] …].
## Waffe: was der Held in der Waffenhand trägt (Strecke längs des Kastens), beim Tier Kopf, Kiefer, Zunge; Körper: beim Held Rumpf,
## Kopf, Beine und der Schild (Kreuz durch seine Fläche, halbe Dicke), beim Tier die übrigen Knochen ab 4 cm. Einmal je Angriff
## gemessen (Haltung je Bild gesetzt, danach die laufende Bewegung wieder hergestellt); leer ohne Gerüst oder Waffe
## 595: der tiefste Punkt der Waffe im Angriff [hn] im eigenen Raum (+Z zum Ziel; x seitlich, y über dem Boden); ohne Weg 0
var landepunkte := {}
func _landepunkt(hn: String) -> Vector3:
	if landepunkte.has(hn):
		return landepunkte[hn]
	var best := Vector3(0.0, INF, 0.0)
	for st in _hieb_bahn(hn):
		for w in st[1]:
			for q in [w[0], w[1]]:
				if (q as Vector3).y < best.y:
					best = q
	if best.y == INF:
		best = Vector3.ZERO
	landepunkte[hn] = best
	return best


const BISS_TEILE := ["head", "jaw", "tongue", "kopf", "fang", "mouth", "maul", "schnauze", "beak"]
var hieb_bahn := {}
func _hieb_bahn(hn: String, versatz := 0.0) -> Array:
	if hieb_bahn.has(hn):
		return hieb_bahn[hn]
	var out: Array = []
	hieb_bahn[hn] = out
	var sk := _find(model, "Skeleton3D") as Skeleton3D if model else null
	if sk == null or anim == null or not anim.has_animation(hn):
		return out
	var klinge: Array = []     # [Knochen, Kasten zum Knochen, AABB]
	var schild: Array = []
	for at in find_children("*", "BoneAttachment3D", true, false):
		var was := String(at.get_meta("was", ""))
		if was == "":
			continue
		for mm in at.find_children("*", "MeshInstance3D", true, false):
			(schild if was.contains("shield") else klinge).append([at.bone_idx, at.global_transform.affine_inverse() * mm.global_transform, mm.get_aabb()])
	var tier: bool = fighter.monster != null and klinge.is_empty()
	if klinge.is_empty() and not tier:
		return out
	var vor := String(anim.current_animation)
	var vor_t: float = anim.current_animation_position if vor != "" else 0.0
	var vor_v: float = anim.get_playing_speed() if vor != "" else 1.0
	var inv := Transform3D(Basis(Vector3.UP, rotation.y - versatz), global_position).affine_inverse()
	var l: float = anim.get_animation(hn).length
	anim.play(hn, 0.0)
	var t := 0.0
	while t <= l + 0.001:
		anim.seek(t, true)
		sk.force_update_all_bone_transforms()
		var kl: Array = []
		var kp: Array = []
		var ks: Array = kapseln()
		if tier:
			for c in ks:
				var nm := String(c[3]).to_lower() if c.size() > 3 else ""
				var waffe := false
				for w in BISS_TEILE:
					if nm.contains(w):
						waffe = true
						break
				if waffe:
					kl.append([inv * (c[0] as Vector3), inv * (c[1] as Vector3), c[2]])
				elif float(c[2]) >= 0.04 and not (nm.contains("neck") or nm.contains("hals")):     # 709: der Hals folgt dem Kopf
					kp.append([inv * (c[0] as Vector3), inv * (c[1] as Vector3), c[2]])
		else:
			for g in klinge:
				kl.append(_strecke(sk, g, inv))
			if fighter.monster == null:
				for i in [0, 1, 3, 4, 5]:
					if i < ks.size():
						kp.append([inv * (ks[i][0] as Vector3), inv * (ks[i][1] as Vector3), ks[i][2]])
			else:     # 709: Gegner mit Waffe (Grak, Krogg …): fremdes Gerüst, der Körper wie koerper() ohne die Arme
				for c in koerper():
					var nm := String(c[3]).to_lower() if c.size() > 3 else ""
					if not (nm.contains("arm") or nm.contains("hand") or nm.contains("fo") and nm.contains("-wr")):
						kp.append([inv * (c[0] as Vector3), inv * (c[1] as Vector3), c[2]])
			for g in schild:
				kp.append_array(_strecke(sk, g, inv, true))
		out.append([t, kl, kp])
		t += 1.0 / 30.0
	if vor != "":
		anim.play(vor, 0.0, vor_v)
		anim.seek(vor_t, true)
	return out


## 709: wie weit Kopf, Kiefer, Zunge (BISS_TEILE) jetzt vor dem Ursprung liegen (m, in Blickrichtung), sonst die Vorderkante des Umrisses
func _schnauze_vorn() -> float:
	var vorn := -INF
	var inv := global_transform.affine_inverse()
	for c in kapseln():
		var nm := String(c[3]).to_lower() if c.size() > 3 else ""
		for w in BISS_TEILE:
			if nm.contains(w):
				vorn = maxf(vorn, maxf((inv * (c[0] as Vector3)).z, (inv * (c[1] as Vector3)).z) * absf(scale.z) + float(c[2]))
				break
	return vorn if vorn > -INF else footprint().end.z * absf(scale.z)


## 709: höchster Punkt der Kapseln über dem eigenen Ursprung (m), einmal gemessen in Ruhe; ohne Kapseln INF (zählt nie als niedrig)
var _hoehe_oben := NAN
func hoehe_oben() -> float:
	if is_nan(_hoehe_oben):
		var h := -INF
		for c in kapseln():
			h = maxf(h, maxf((c[0] as Vector3).y, (c[1] as Vector3).y) + float(c[2]) - global_position.y)
		_hoehe_oben = h if h > -INF else INF
	return _hoehe_oben


## 709: Umriss (footprint, lokal) vorn bis zum hintersten Punkt von Kopf, Kiefer, Zunge (Kapseln BISS_TEILE); ohne sie der Umriss
func _rumpf_ohne_kopf() -> AABB:
	var box := footprint()
	var hinten := INF
	var inv := global_transform.affine_inverse()
	for c in kapseln():
		var nm := String(c[3]).to_lower() if c.size() > 3 else ""
		for w in BISS_TEILE:
			if nm.contains(w):
				hinten = minf(hinten, minf((inv * (c[0] as Vector3)).z, (inv * (c[1] as Vector3)).z) - float(c[2]) / maxf(absf(scale.z), 0.01))
				break
	if hinten < box.end.z and hinten > box.position.z:
		box.size.z = hinten - box.position.z
	return box


## 709: wie weit (m) die Figur längs [dn] rücken muss, bis Kopf, Kiefer, Zunge in der jetzigen Haltung SCHNAUZE_VOR vor dem Körper
## [ziel] (Kapseln, Welt) stehen (den Rest holt der Biss selbst; treffen_709: mit −1 cm bis 12 cm darin); -1, wenn nicht bis [bis]
const SCHNAUZE_VOR := 0.05
func _schnauze_bis(ziel: Array, dn: Vector3, bis: float) -> float:
	var kopf: Array = []
	for c in kapseln():
		var nm := String(c[3]).to_lower() if c.size() > 3 else ""
		for w in BISS_TEILE:
			if nm.contains(w):
				kopf.append(c)
				break
	if kopf.is_empty() or ziel.is_empty():
		return -1.0
	var m := 0.0
	while m <= bis:
		var v := dn * m
		for k in kopf:
			for c in ziel:
				var pq: PackedVector3Array = Geometry3D.get_closest_points_between_segments(k[0] + v, k[1] + v, c[0], c[1])
				if pq[0].distance_to(pq[1]) - float(k[2]) - float(c[2]) <= SCHNAUZE_VOR:
					return m
		m += 0.02
	return -1.0


## 709: der Schild in der Hand als Kreuz aus zwei Kapseln [[a, b, r] …] (Welt), leer ohne Schild
func schild_kapseln() -> Array:
	var sk := _find(model, "Skeleton3D") as Skeleton3D if model else null
	var out: Array = []
	if sk == null:
		return out
	for at in find_children("*", "BoneAttachment3D", true, false):
		if not String(at.get_meta("was", "")).contains("shield"):
			continue
		for mm in at.find_children("*", "MeshInstance3D", true, false):
			out.append_array(_strecke(sk, [at.bone_idx, at.global_transform.affine_inverse() * mm.global_transform, mm.get_aabb()], Transform3D.IDENTITY, true))
	return out


## 709: Kasten [g] = [Knochen, Kasten zum Knochen, AABB] als Strecke [a, b, r] längs seiner längsten Achse im Raum [inv]; [flach]:
## der Schild als Kreuz aus zwei Strecken durch die Mitte seiner Fläche, Radius die halbe Dicke
static func _strecke(sk: Skeleton3D, g: Array, inv: Transform3D, flach := false) -> Array:
	var tr: Transform3D = sk.global_transform * sk.get_bone_global_pose(g[0]) * g[1]
	var box: AABB = g[2]
	var achsen := [box.get_longest_axis_index()]
	var r := 0.0
	if flach:
		var kurz := box.get_shortest_axis_index()
		achsen.append(3 - achsen[0] - kurz)
		r = box.size[kurz] * 0.5 * absf(tr.basis.get_scale()[kurz])
	var out: Array = []
	for ax in achsen:
		var p0: Vector3 = box.get_center()
		var p1: Vector3 = p0
		p0[ax] = box.position[ax]
		p1[ax] = box.end[ax]
		out.append([inv * (tr * p0), inv * (tr * p1), r])
	if flach:     # 709 (wolf_mess_438 Kleriker 71,9 s: Schild 9 cm im Wolf, am Rand zwischen den Armen des Kreuzes): dazu die Diagonalen
		var a0: int = achsen[0]
		var a1: int = achsen[1]
		for sg in [1.0, -1.0]:
			var p0: Vector3 = box.get_center()
			var p1: Vector3 = p0
			p0[a0] = box.position[a0]
			p1[a0] = box.end[a0]
			p0[a1] = box.get_center()[a1] - sg * box.size[a1] * 0.5
			p1[a1] = box.get_center()[a1] + sg * box.size[a1] * 0.5
			out.append([inv * (tr * p0), inv * (tr * p1), r])
	return out if flach else out[0]


## 709: hieb_plan, gemerkt je Hieb, Art des Ziels, Treffer oder daneben und Blickwinkel des Ziels zur Figur (15°-Stufen): das
## Ziel steht dabei in seiner Ruhe, der Plan gilt wieder (gegen die flache Schnecke kostet er sonst bis 0,1 s)
static var hieb_plaene := {}
func _hieb_plan_merk(hn: String, other, ziel: Array, to: Vector3, d: Vector3, soll: float, seit := 0.0) -> Array:
	var rel := wrapf(other.rotation.y - atan2(-d.x, -d.z), -PI, PI)
	# 900: auch nach Grundhaltung und laufender Ruhebewegung (der Stand galt sonst für die Haltung, in der er zuerst geplant wurde)
	var haltung := ""
	if other.fighter.monster != null and other.anim:
		haltung = ("Hocke" if other.pouncing else "Stehen") + "/" + (String(other.anim.current_animation) if String(other.anim.current_animation) in RUHE_GESTEN else "")
	var key := "%d|%s|%s|%.2f|%d|%.2f|%s" % [get_instance_id(), hn, other._mein_ersatz() if other.fighter.monster != null else "Held", soll, roundi(rad_to_deg(rel) / 15.0), other.model.global_transform.basis.get_scale().x if other.model else 1.0, haltung]
	key += "|%.2f" % seit
	if not hieb_plaene.has(key):
		# 595: steht der Held [seit] seitlich (Klinge auf die Mitte), liegt das Ziel in seinem Raum um so viel in x verschoben
		var to_s: Vector3 = to - Basis(Vector3.UP, atan2(d.x, d.z)) * Vector3(seit, 0.0, 0.0)
		hieb_plaene[key] = hieb_plan(_hieb_bahn(hn), ziel, to_s, d, soll, HIEB_KOERPER_LUFT)
	return hieb_plaene[key]


## 709: Plan des Angriffs [bahn] (_hieb_bahn) gegen den Körper [ziel] (Kapseln, Welt) des Ziels bei [to], die Figur blickt nach
## [d]: [Abstand der Ursprünge, t des nächsten Punkts der Waffe, Abstand für die Waffe, Abstand für den Körper]. Die Waffe kommt dem
## Körper bis [soll] nahe (< 0: so tief darin), Körper und Schild der Figur bleiben während des ganzen Angriffs [luft] vor Körper
## und [hindernis] des Ziels (sein Schild), die Waffe ebenso vor [hindernis]. Die Waffe sucht von weit nach nah (aus der Nähe
## schwingt sie über ein flaches Ziel hinweg); Waffe 0: sie erreicht es von nirgends
static func hieb_plan(bahn: Array, ziel: Array, to: Vector3, d: Vector3, soll: float, luft: float, hindernis: Array = []) -> Array:
	if bahn.is_empty() or ziel.is_empty():
		return [0.0, 0.0, 0.0, 0.0]
	var inv := Transform3D(Basis(Vector3.UP, atan2(d.x, d.z)), to).affine_inverse()
	var zl: Array = _im_raum(ziel, inv)     # Ziel im Raum der Figur, als stünde sie in seinem Ursprung; x zurück = Ziel um +x in Z
	var hl: Array = _im_raum(hindernis, inv)
	var vorn := INF
	for c in zl:
		vorn = minf(vorn, minf(c[0].z, c[1].z) - float(c[2]))
	var weit := -INF
	for s in bahn:
		for w in s[1]:
			weit = maxf(weit, maxf((w[0] as Vector3).z, (w[1] as Vector3).z) + float(w[2]))
	var x0: float = weit - vorn + 0.1
	var xk := 0.0
	var x := x0
	var hi := x0
	while x > maxf(0.15, x0 - 1.6):
		if float(_klinge_luecke(bahn, zl, x)[0]) < soll:
			var lo := x
			for i in 5:
				var mid := (lo + hi) * 0.5
				if float(_klinge_luecke(bahn, zl, mid)[0]) < soll:
					lo = mid
				else:
					hi = mid
			xk = lo
			break
		hi = x
		x -= 0.1
	var xb := maxf(xk, 0.2)
	while xb < 4.0 and minf(_koerper_luecke(bahn, zl + hl, xb, 2), _koerper_luecke(bahn, hl, xb, 1, 1)) < luft:
		xb += 0.05
	var xs := maxf(xk, xb)
	var tk := float(_klinge_luecke(bahn, zl, xs)[1])
	# 709: [4] die kleinste Lücke danach (ab NACH_T nach dem Aufschlag): ein Hieb mit zweitem Schwung fährt dort noch einmal durch
	return [xs, tk, xk, xb, float(_klinge_luecke(bahn, zl, xs, tk + NACH_T)[0])]


static func _im_raum(kaps: Array, inv: Transform3D) -> Array:
	var out: Array = []
	for c in kaps:
		var a: Vector3 = inv * (c[0] as Vector3)
		var b: Vector3 = inv * (c[1] as Vector3)
		out.append([a, b, float(c[2]), (a + b) * 0.5, a.distance_to(b) * 0.5 + float(c[2])])
	return out


## kleinste Lücke der Waffe (Kapseln s[1]) zu [zl] über den ganzen Weg, wenn die Figur [x] zurück steht: [Lücke, t]
static func _klinge_luecke(bahn: Array, zl: Array, x: float, t_ab := -INF) -> Array:
	var best := INF
	var bt := 0.0
	var v := Vector3(0.0, 0.0, x)
	for s in bahn:
		if float(s[0]) < t_ab:
			continue
		for w in s[1]:
			var a: Vector3 = w[0]
			var b: Vector3 = w[1]
			var m: Vector3 = (a + b) * 0.5
			var hm: float = a.distance_to(b) * 0.5 + float(w[2])
			for c in zl:
				# grob vorweg: Kugel um beide Strecken (Mitte, halbe Länge + Radius)
				if m.distance_to(c[3] + v) - hm - float(c[4]) >= best:
					continue
				var pq: PackedVector3Array = Geometry3D.get_closest_points_between_segments(a, b, c[0] + v, c[1] + v)
				var g: float = pq[0].distance_to(pq[1]) - float(w[2]) - float(c[2])
				if g < best:
					best = g
					bt = s[0]
	return [best, bt]


## kleinste Lücke der Teile [teil] (2: Körper, 1: Waffe) zu [zl], jedes [schritt]-te Bild, die Figur [x] zurück
static func _koerper_luecke(bahn: Array, zl: Array, x: float, schritt := 2, teil := 2) -> float:
	var best := INF
	if zl.is_empty():
		return best
	var v := Vector3(0.0, 0.0, x)
	for k in range(0, bahn.size(), schritt):
		for e in bahn[k][teil]:
			var m: Vector3 = ((e[0] as Vector3) + (e[1] as Vector3)) * 0.5
			var hm: float = (e[0] as Vector3).distance_to(e[1]) * 0.5 + float(e[2])
			for c in zl:
				if m.distance_to(c[3] + v) - hm - float(c[4]) >= best:
					continue
				var pq: PackedVector3Array = Geometry3D.get_closest_points_between_segments(e[0], e[1], c[0] + v, c[1] + v)
				best = minf(best, pq[0].distance_to(pq[1]) - float(e[2]) - float(c[2]))
	return best


## 438: wie weit die Figur in der jetzigen Haltung von ihrem Ursprung in Richtung [zu] (waagerecht) reicht, mit Schild und Waffe;
## nie weniger als body_r(). Der Kasten um Schild und Waffe mit VORNE_LUFT: im Biss schnellt die Schnauze weiter vor als im
## Augenblick, für den bite[] gilt, und der Getroffene hebt den Schild (wolf_mess_438: mit den Ecken des Kastens auf 0,71 noch 9 cm darin)
const VORNE_LUFT := 0.05
func vorne(zu: Vector3, ohne_waffen := false) -> float:
	var d := Vector3(zu.x, 0.0, zu.z).normalized()
	var m := body_r()
	if fighter.monster != null or d == Vector3.ZERO:
		return m
	for c in kapseln():
		for q in [c[0], c[1]]:
			m = maxf(m, d.dot(q - position) + float(c[2]))
	for g in traegt():
		if String(g[2]) == "" or ohne_waffen:
			continue
		var box: AABB = g[1]
		for i in 8:
			m = maxf(m, d.dot((g[0] as Transform3D) * box.get_endpoint(i) - position) + VORNE_LUFT)
	return m


## 438: was die Figur in der Hand trägt (Schild, Klinge) als Kästen [Transform3D, AABB] (Welt), mit Namen
func traegt() -> Array:
	var out: Array = []
	for at in find_children("*", "BoneAttachment3D", true, false):
		for m in at.find_children("*", "MeshInstance3D", true, false):
			out.append([m.global_transform, m.get_aabb(), String(at.get_meta("was", ""))])
	return out


## Wie weit p (Welt) am Boden außerhalb des Umrisses liegt (< 0: darin); [bei]: so, als stünde die Figur dort (438)
func clearance(p: Vector3, bei := Vector3.INF, gier := NAN, hoehe := INF) -> float:
	var box := footprint(hoehe)
	var tr := global_transform
	if bei != Vector3.INF:
		tr.origin = Vector3(bei.x, tr.origin.y, bei.z)
	if not is_nan(gier):
		tr.basis = Basis(Vector3.UP, gier) * Basis.from_scale(scale)
	var loc := tr.affine_inverse() * p
	var dx := maxf(box.position.x - loc.x, loc.x - box.end.x)
	var dz := maxf(box.position.z - loc.z, loc.z - box.end.z)
	if dx <= 0.0 and dz <= 0.0:
		return maxf(dx, dz)
	return Vector2(maxf(dx, 0.0), maxf(dz, 0.0)).length()


## Kleinster Abstand der Strecke a → b zu einer stehenden anderen Figur (Rand der Heldin an Umriss), in 16 Schritten.
## 438 (Prüfer Film 08:18: Wölfe laufen durcheinander, 0:18,6, 0:19,2, 0:42,2, 0:44,6; _detour sah die anderen nur dort, wo sie
## gerade stehen): wer unterwegs ist, zählt auch an den Punkten seiner Bahn bis zu seinem Platz
func _seg_gap(a: Vector3, b: Vector3, skip = null, rumpf := true) -> float:
	var g := INF
	var r := own_r()
	# 438 (wolf_mess_438: Wolf 3 lief mit dem Kopf 0,15 m in Wolf 2, sein Ursprung blieb 0,3 m davon): ein Tier läuft mit dem
	# Rumpf voran (oder rückwärts mit dem Heck), nicht als Kreis um den Ursprung; die Strecke reicht um eine halbe Länge weiter
	if rumpf and fighter.monster != null:
		var box := footprint()
		var d := Vector3(b.x - a.x, 0.0, b.z - a.z)
		d = d.normalized() if d.length() > 0.01 else Vector3(basis.z.x, 0.0, basis.z.z).normalized()
		var l := maxf(maxf(-box.position.z, box.end.z) - r, 0.0)     # vorwärts oder rückwärts (heim): beide Enden
		a = a - d * l
		b = b + d * l
	for o in kampfort.figures.values():
		if o == self or o == skip or not o.visible or o.down:
			continue
		var orte: Array = [Vector3.INF]
		# wer mit mir den Platz tauscht (sein Ziel ist mein Start), zählt nur, wo er steht: seine Bahn führt durch meinen Platz
		# 717 C: ein beißender Tauschpartner (Biss, dann abgesetzt) zählt mit seiner Bahn, er kommt nicht hierher (wolf_mess_438)
		if o.unterwegs() and (Vector2(o.home.x - a.x, o.home.z - a.z).length() > 1.0 or o.gang != "heim"):
			orte.append_array(o.bahn_punkte())
		for at in orte:
			g = minf(g, o.strecke_luft(a, b, at) - r)
		if not is_nan(o.dreh_ziel) and o.tween and o.tween.is_running():     # 438: dreht gerade, auch schon in der Zielrichtung
			g = minf(g, o.strecke_luft(a, b, Vector3.INF, o.dreh_ziel) - r)
	return g


## Kleinste clearance() der Strecke a → b in 16 Schritten, die Figur an [bei] (INF: wo sie steht); eine Umkehrung je Strecke
func strecke_luft(a: Vector3, b: Vector3, bei := Vector3.INF, gier := NAN) -> float:
	var box := footprint()
	var tr := global_transform
	if bei != Vector3.INF:
		tr.origin = Vector3(bei.x, tr.origin.y, bei.z)
	if not is_nan(gier):
		tr.basis = Basis(Vector3.UP, gier) * Basis.from_scale(scale)
	var inv := tr.affine_inverse()
	var la := inv * a
	var lb := inv * b
	var g := INF
	for k in 17:
		var loc := la.lerp(lb, k / 16.0)
		var dx := maxf(box.position.x - loc.x, loc.x - box.end.x)
		var dz := maxf(box.position.z - loc.z, loc.z - box.end.z)
		g = minf(g, maxf(dx, dz) if dx <= 0.0 and dz <= 0.0 else Vector2(maxf(dx, 0.0), maxf(dz, 0.0)).length())
	return g


## 438: Wegpunkte (Welt) dieser Figur von hier bis zu ihrem Platz, solange sie läuft; je Abschnitt alle 0,5 m einer
var bahn: Array = []
var dreh_ziel := NAN     # 438: Ziel der Drehung daheim (_turn_home), solange sie läuft
func unterwegs() -> bool:
	return tween != null and tween.is_running() and gang != "dreh" and not bahn.is_empty()


func bahn_punkte() -> Array:
	var out: Array = []
	var von := position
	for q in bahn:
		var n := maxi(1, int(ceilf(Vector2(q.x - von.x, q.z - von.z).length() / 0.5)))
		for i in range(1, n + 1):
			out.append(von.lerp(q, float(i) / n))
		von = q
	return out


## Eigener Rand quer zum Weg: die Heldin HERO_R, ein Tier die halbe Breite seines Umrisses (399.2: Wölfe weichen jetzt auch aus)
func own_r() -> float:
	if fighter.monster == null:
		return HERO_R
	var box := footprint()
	return maxf(0.5 * minf(box.size.x, box.size.z), 0.1)


## Ein Punkt seitlich der Geraden a → b, wenn sie den Umriss einer stehenden anderen Figur (außer dem Ziel skip) streift;
## sonst a selbst. Gesucht wird der kleinste seitliche Versatz, bei dem beide Teilstrecken 0,3 m Luft lassen; sonst der mit der meisten Luft.
func _detour(a: Vector3, b: Vector3, skip = null) -> Vector3:
	const AIR := 0.3     # der Nachbar dreht Rumpf und Kopf nach ihr, solange sie läuft (bis 0,2 m an der Schnauze)
	if _seg_gap(a, b, skip) >= AIR:
		return a
	var ab := Vector3(b.x - a.x, 0.0, b.z - a.z)
	var n := ab.length()
	if n < 0.05:
		return a
	var d := ab / n
	var side := Vector3(-d.z, 0.0, d.x)
	var best := a
	var best_gap := _seg_gap(a, b, skip)
	# 438 (Prüfer Film r2: Wolf rechts halb abgeschnitten, 42,6 s; wolf_mess_438: bis 79 px aus dem Bild): erst ein Umweg, der im
	# Bild bleibt; gibt es keinen freien, lieber kurz aus dem Bild als durch einen anderen (Kämpfer: Wolf 0,20 m in Wolf)
	for im_bild in [true, false]:
		for k in range(1, 13):
			var off := 0.2 * k
			for at in [0.5, 0.35, 0.65]:
				for sg in [1.0, -1.0]:
					var via: Vector3 = a + d * (n * at) + side * (off * sg)
					if im_bild and not _im_bild_dreh(via, via - a, b - via):
						continue
					var g := minf(_seg_gap(a, via, skip), _seg_gap(via, b, skip))
					if g >= AIR:
						return via
					if g > best_gap and im_bild:     # aus dem Bild nur, wenn dort frei
						best_gap = g
						best = via
	if OS.get_environment("SCHAU_MESS") != "":
		print("Umweg %s %s -> %s: kein freier, bester Luft %.2f über %s" % [fighter.id, a, b, best_gap, best])
	return best


## 438 (wolf_mess_438: Wolf 1 drehte am Umweg um 120° auf der Stelle und schwang mit dem Kopf 45 px aus dem Bild): an der Ecke
## [p] eines Umwegs dreht die Figur von [von] nach [nach]; im Bild nur, wenn jede Lage dazwischen im Bild bleibt
func _im_bild_dreh(p: Vector3, von: Vector3, nach: Vector3) -> bool:
	var w0 := atan2(von.x, von.z)
	var dw := wrapf(atan2(nach.x, nach.z) - w0, -PI, PI)
	var n := maxi(1, int(ceilf(absf(dw) / deg_to_rad(30.0))))
	for i in n + 1:
		var w := w0 + dw * i / n
		if not _im_bild(p, Vector3(sin(w), 0.0, cos(w))):
			return false
	return true


## 438: steht die Figur an [p] mit Blick [blick] (waagerecht) ganz in der Szene, über dem Bedienfeld, 8 dp Rand?
## 438 (wolf_mess_438: Wolf 1 am Umweg 32 px draußen, obwohl sein Kasten in Ruhe mit 8 dp Rand im Bild war): im Lauf streckt er
## Läufe und Kopf über den Kasten der Ruhe hinaus; darum mehr Rand
const IM_BILD_DP := 20.0
func _im_bild(p: Vector3, blick: Vector3) -> bool:
	var sr: Rect2 = kampfort.scene_rect()
	var rand: float = IM_BILD_DP * sr.size.x / 412.0
	var box := footprint()
	var b := Basis(Vector3.UP, atan2(blick.x, blick.z)) if Vector2(blick.x, blick.z).length() > 0.01 else basis
	var hoch: float = kampfort.screen_of(position).y - kampfort.screen_of(head()).y
	for i in 8:
		var q := box.get_endpoint(i)
		var w: Vector3 = p + b * Vector3(q.x, 0.0, q.z) * scale.x
		var sp: Vector2 = kampfort.screen_of(w)
		if sp.x < rand or sp.x > sr.size.x - rand or sp.y - hoch < rand:
			return false
	return true


## 406 (Chef 01.11., 13:1x: „Sein Schild hängt drunter. Dann wird er vom Wolf angeknabbert und reißt dann das Schild hoch“): wer
## mit Schild kämpft, wehrt einen Angriff ab, bevor er ankommt; der Schild trifft den Angriff im Aufschlag (Kontakt aus held_kampf.py).
## Gelungen: die Abwehr läuft aus. art: „sprung“ (Sprungbiss: schwere Abwehr), „fern“ (Pfeil, Zauber), sonst nah (Biss, Hieb).
const ABWEHR := {"sprung": ["SS_BlockHeavy1", "SS_BlockHeavy2", "SS_BlockMedium1"], "fern": ["SS_BlockMedium1", "SS_ParryHigh1", "SS_BlockMedium2"],
	"nah": ["SS_BlockLight", "SS_BlockMedium1", "SS_BlockMedium2", "SS_ParryLow"]}
var abwehr_nr := 0

var _abwehr_letzt := ""

## 406.2 (Chef 03.11., 06:59: „Wenn dem Parieren gelingt … eine Abwehrbewegung … beim Angriff mit Schild … muss man ja auch nicht
## ausweichen … beim Wolf wäre das so eine Abwehr tief … oder Abwehr Mitte oder mal links, rechts … variieren … wenn der Wolf von links
## angreift“): die gelungene Abwehr nach der Seite, von der der Angriff kommt (im Blick des Helden; Modell: links = +X), gegen tiefe
## Gegner (Wolf, Ratte) tief oder Mitte; je Seite zwei von drei zur Seite, eine zur Mitte, damit es wechselt
const PARADE_SEITE := 7.5      # Grad aus der Blickrichtung, ab denen die Parade zur Seite geht
## 662 (Chef t270.9, 08.11., 20:50: „Ich erkenne keinen Unterschied, von welcher Seite der Angriff kommt“): mit 30° ging jede Parade
## zur Mitte; die Wölfe des Rudels kommen aus der Aufstellung (kampfort._stand) nur 10–29° von der Seite, der einzelne 5°
## (parade_seite_662). Gemessen wird gegen die Blickrichtung, in die _face_sanft den Helden vor der Parade dreht (zum Gegnerfeld),
## nicht gegen die gerade eingenommene: links = +X des Modells
static func parade_winkel(blick: Vector3, von: Vector3) -> float:
	return rad_to_deg(Vector2(blick.x, blick.z).angle_to(Vector2(von.x, von.z))) * -1.0

func _parade_liste(von: Vector3, art: String, tief: bool) -> Array:
	var blick := global_transform.basis.z
	if kampfort != null and is_instance_valid(kampfort) and not vier(fighter):
		blick = kampfort.global_transform.basis * kampfort.facing(fighter.side == "FOES")
	var ang := parade_winkel(blick, von - global_position)
	var mitte := "SS_ParryLow" if tief else "SS_BlockMedium1"
	if ang > PARADE_SEITE:
		return ["SS_ParryLeft", mitte, "SS_ParryLeft"]
	if ang < -PARADE_SEITE:
		return ["SS_ParryRight", mitte, "SS_ParryRight"]
	if art == "sprung":
		return ["SS_ParryHigh1", "SS_BlockHeavy1", "SS_ParryHigh2"]
	if tief:
		return ["SS_ParryLow", "SS_BlockMedium1", "SS_ParryLow", "SS_BlockMedium2"]
	return ["SS_ParryHigh1", "SS_BlockMedium1", "SS_ParryHigh2", "SS_BlockMedium2"]


## 406.2: tiefer Gegner (vierbeinig, nicht fliegend): die Parade geht tief oder zur Mitte
func niedrig() -> bool:
	return fighter.monster != null and not _zweibeiner() and _mein_ersatz() != "giant_bat"


func blockt() -> bool:
	return _ss() and not down


func abwehr(lands_ms: int, art: String, von := Vector3.INF, gelungen := false, tief := false) -> void:
	if not _ss():
		return
	var liste: Array = (ABWEHR.get(art, ABWEHR["nah"]) as Array).filter(func(x): return anim.has_animation(x))
	if gelungen and von != Vector3.INF and art != "fern":
		var pl := _parade_liste(von, art, tief).filter(func(x): return anim.has_animation(x))
		if not pl.is_empty():
			liste = pl
	if liste.is_empty():
		return
	# reihum statt Zufall: nie zweimal dieselbe hintereinander (mindestens drei Varianten, DESIGN-LEITBILD 2)
	var nm: String = liste[(abwehr_nr + hash(String(fighter.id))) % liste.size()]
	if nm == _abwehr_letzt and liste.size() > 1:
		abwehr_nr += 1
		nm = liste[(abwehr_nr + hash(String(fighter.id))) % liste.size()]
	_abwehr_letzt = nm
	abwehr_nr += 1
	var k: float = float(kampf_info.get("kontakt", {}).get(nm, 0.25))
	var vor_ms := lands_ms - int(k * 1000.0)
	if OS.get_environment("MESS") != "":     # film_406 MESS: Schild steht beim Aufschlag (Kontakt gegen Aufschlag)
		var seite := ""
		if von != Vector3.INF:
			var lv := global_transform.basis.inverse() * (von - global_position)
			seite = ", Angreifer %.0f° (links +)%s" % [rad_to_deg(atan2(lv.x, lv.z)), ", tief" if tief else ""]
		print("ABWEHR %s %s%s%s: Aufschlag in %d ms, Kontakt nach %d ms, Beginn in %d ms" % [fighter.id, nm, " gelungen" if gelungen else "", seite, lands_ms, int(k * 1000.0), vor_ms])
	if vor_ms > 0:
		await get_tree().create_timer(vor_ms / 1000.0).timeout
	if down or not _ss() or (not weg.is_empty() and lunging()):
		return
	_face_sanft()
	_play(nm, 0.12)
	if vor_ms < 0:     # zu spät angesagt: so weit vorgespult, dass der Schild beim Aufschlag steht
		anim.seek(minf(-vor_ms / 1000.0, k), true)
	_schnaufen(0.6)
	var rest: float = anim.get_animation(nm).length - maxf(0.0, -vor_ms / 1000.0)
	get_tree().create_timer(maxf(0.1, rest - 0.1)).timeout.connect(_idle_wenn_frei)


func hurt(after_ms: int, dies: bool, schwer := false, art := "") -> void:
	# 406: mit Schild erst die Abwehr (vor dem Aufschlag), die nicht hält: beim Aufschlag Treffer mit dem Schild oben. 709 (Chef
	# 08.11., 21:36: die Angriffe sollen den Gegner treffen; t269.21, Chef 16:06: „Schild immer gehoben“): im Nahkampf nur noch gegen
	# Geschosse; Biss und Hieb, die treffen, kommen am Schild vorbei an den Körper (Figur._bite_plan, _held_schlag)
	if art == "fern" and blockt() and not dies and not sturz_vorweg:
		abwehr(after_ms, art)
	await get_tree().create_timer(after_ms / 1000.0).timeout
	if hurt_at < 0.0:
		model_rest = model.position
	# 249: wie im alten MARS nur Zittern und Blut; das orange Aufleuchten wirkte als greller Scherenschnitt (Prüfer 26.10.)
	hurt_at = kampfort.clock_ms
	_schnaufen(0.8)
	if dies:
		die()
	elif not weg.is_empty() and lunging():
		pass     # 438: unterwegs nur das Zittern; vorher spielte es Treffer, dann Stehen und glitt so 1 m weiter
	elif _ss() and not down:
		var tn := "SS_GetHitHeavyFront" if schwer else "SS_GetHitLightFront"
		if anim.has_animation(tn):
			_play(tn, 0.06)
			get_tree().create_timer(anim.get_animation(tn).length - 0.1).timeout.connect(_idle_wenn_frei)
	else:
		_play("Treffer", 0.05)
		get_tree().create_timer(0.45).timeout.connect(_idle_wenn_frei)


func dodge(after_ms: int, nm := "") -> void:
	await get_tree().create_timer(after_ms / 1000.0).timeout
	_dreh_ab()
	_schnaufen(0.8)
	# 348.12f: mit Wurzelweg zur Seite oder zurück, wie die Quelle (Ausweichen links nicht: Kopf unter den Vorderbeinen, Prüfer r7),
	# dann heim; [nm] wählt (Probe SCHAU=ort), sonst der Zufall
	# 593 (Chef 05.11., 19:2x, Build 266: „Ausweichbewegungen müssen nicht links – rechts sein, sondern können auch rückwärts gehen
	# (so als Alternative)“): jedes dritte Ausweichen rückwärts, reihum statt Zufall (wie die Abwehr), nur wenn dort Platz ist; mit
	# eigener Bewegung der Quelle (Ratte: dodgeBackwards), sonst rasch rückwärts im Gang (Spinne; Grak mit Jog_Bwd „Zurück“)
	ausweich_nr += 1
	if nm == "" and not down and not lunging() and (ausweich_nr + hash(String(fighter.id))) % 3 == 0:
		if weg.has("Ausweichen zurück") and weg.has("Ausweichen links") and anim.has_animation("Ausweichen zurück") and _weg_frei("Ausweichen zurück"):
			nm = "Ausweichen zurück"
		elif not weg.has("Ausweichen zurück") and weg.has("Ausweichen") and _absetzen_rasch():
			return
	if nm == "" and weg.has("Ausweichen links"):
		nm = _ausweich_seite()
	if nm == "":
		nm = "Ausweichen zurück" if weg.has("Ausweichen zurück") and randf() < 0.5 else "Ausweichen"
	if weg.has(nm) and anim and anim.has_animation(nm) and not down and not lunging():
		# 348.12: Graks Ausweichen (Seitenlauf der UAL Pro) beginnt mitten im Schritt; aus dem Stehen weicher hinein
		_play(nm, 0.2 if _zweibeiner() else 0.05)
		var o := position
		var b := basis
		var bl: float = anim.get_animation(nm).length
		tween = create_tween()
		bahn = [_weg_at(o, b, nm, bl)]     # 703 A: Ziel des Satzes ist der neue Stand, nicht der Platz
		tween.tween_method(func(x: float): position = _weg_at(o, b, nm, x), 0.0, bl, bl)
		tween.tween_callback(_nach_ausweichen)
		return
	# Kaufwolf (Chef 27.10., 21:51, Archiv: „Ausweichen-Bewegung war am Platz und ohne Ortswechsel … grundsätzlich wie bei der
	# Ratte“; der Kauf hat keine Ausweichbewegung): ein Satz im Lauf zur freieren Seite (Ausweichen) oder schräg zurück (Ausweichen
	# zurück), Pfad wie der Heimweg (Dubins, Radius halb), dann heim
	# 717 (Chef 09.11., 08:51: „ansonsten weicht es zurück und das macht es rückwärts … rückwärts springen, ist mir völlig wurscht“;
	# F7): der Satz im Lauf zur Seite drehte dem Helden den Rücken zu (kurven_682: 0,2–0,9 s je Kampf). Ohne eigene Ausweichbewegung
	# weicht er jetzt rasch rückwärts aus, gerade oder schräg zurück, wo Platz ist; der Satz im Lauf nur noch, wenn hinten keiner frei ist
	if weg.has("Rennen") and weg.has("Gehen") and not down and not lunging() and not flieht and _ausweichen_rueckwaerts():
		return
	if weg.has("Rennen") and not down and not lunging():
		if nm == "":
			nm = "Ausweichen zurück" if randf() < 0.5 else "Ausweichen"
		var best: Array = []
		var luft := -INF
		var g0 := minf(_rumpf_luft(position, rotation.y), PLATZ_LUFT)     # 438: mit dem Rumpf gemessen nicht näher als jetzt
		# 438 (wolf_mess_438: Wolf 3 wich in den Rumpf von Wolf 1 aus): geht keiner der beiden Sätze, auch der andere und kürzere
		var arten: Array = []
		for k in [1.0, 0.6]:
			for n2 in [nm, "Ausweichen" if nm == "Ausweichen zurück" else "Ausweichen zurück"]:
				for sg in [1.0, -1.0]:
					arten.append([k, n2, sg])
		for v in arten:
			if luft >= 900.0 and v[0] < 1.0 or luft >= 900.0 and v[1] != nm:
				break
			var sc: float = model.scale.x * v[0]
			var sg: float = v[2]
			var off: Vector3 = (basis.x * sg * AUSWEICHEN[0] - basis.z * AUSWEICHEN[1]) if v[1] == "Ausweichen" else (basis.x * sg * AUSWEICHEN[2] - basis.z * AUSWEICHEN[3])
			var ziel: Vector3 = position + off * sc
			var yw: float = rotation.y + deg_to_rad(AUSWEICHEN[4] if v[1] == "Ausweichen" else AUSWEICHEN[5]) * sg
			for art in ["LSL", "RSR", "LSR", "RSL"]:
				var pts := _dubins(position, rotation.y, ziel, yw, TURN_R * 0.5 * _scale(), art)
				if pts.is_empty():
					continue
				var g := INF
				for i in range(0, pts.size(), 3):
					g = minf(g, _rumpf_luft(pts[i][0], pts[i][2]))     # 438: der Rumpf in Pfadrichtung, nicht ein Kreis
				# wie _heimweg(): der kürzeste, der den anderen nicht näher kommt als der Start (Ortmess r3c: nach Luft gewählt
				# liefen beide Sätze 3,2–3,7 m)
				var wert: float = (1000.0 - pts[pts.size() - 1][1]) if g >= g0 else g
				# 438 (wolf_mess_438: Wolf 2 wich dem Zauber bis 186 px aus dem Bild aus): ein Satz, der im Bild bleibt, geht vor
				for i in range(0, pts.size(), 3):
					if not _im_bild(pts[i][0], Vector3(sin(pts[i][2]), 0.0, cos(pts[i][2]))):
						wert -= 500.0 if g >= g0 else 0.0     # frei, aber aus dem Bild: hinter jedem freien im Bild, vor jedem unfreien
						break
				if wert > luft:
					luft = wert
					best = pts
		# 438: kein Satz frei (eng zwischen den anderen): rückwärts absetzen wie nach dem Biss, wenn dort Platz ist; sonst bleibt es
		# stehen, statt in einen anderen zu springen
		if luft < 900.0 and weg.has("Gehen"):
			var zurueck := position - Vector3(basis.z.x, 0.0, basis.z.z).normalized() * ABSETZEN * _scale()
			if _rumpf_luft(zurueck, rotation.y) >= g0:
				if OS.get_environment("SCHAU_MESS") != "":
					print("Ausweichen %s rückwärts (kein Satz frei, bester %.2f)" % [fighter.id, luft])
				bahn = [zurueck]
				tween = create_tween()
				tween.tween_callback(func(): anim.play("Gehen", 0.1, -float(tempo.get("Gehen", 1.0))))
				_lauf(tween, position, zurueck, "Gehen", RUECK_TEMPO)
				tween.tween_callback(_nach_ausweichen)
				return
			if luft < 400.0:     # 438: ein freier Satz aus dem Bild bleibt, wenn rückwärts kein Platz ist
				best = []
		if not best.is_empty():
			if OS.get_environment("SCHAU_MESS") != "":
				print("Ausweichen %s %s Länge %.2f m, Wert %.2f, Grenze %.2f, Start %s" % [fighter.id, nm, best[best.size() - 1][1], luft, g0, position])
			bahn = [best[best.size() - 1][0]]
			_pfad_fahren(best, false, AUSWEICH_BOGEN)     # 438: im Lauf drehte er 28° je Bild; 546: im Schritt zu träge
			tween.tween_callback(_nach_ausweichen)
			return
	_reichweite_merken("Ausweichen")
	_play("Ausweichen", 0.05)
	get_tree().create_timer(0.45).timeout.connect(_idle_wenn_frei)


## 988 (wolf_mess_438 Lauf 369, CLERIC ohne Schild nach BRS, Bild 1330: Ausweichen auf der Stelle, die Brust neigt sich 11 px über
## den linken Rand, die Linse ging erst im selben Bild zurück, rand_z 0,98 → 0,97): die Haltungen einer Bewegung auf der Stelle einmal
## abgetastet, als Punkte der Kapseln im eigenen Maß ([Ort, Halbmesser]); _rand_kamera nimmt sie, solange die Bewegung läuft, und geht
## so schon zu Beginn so weit zurück, wie die Figur sich neigen wird
const REICHWEITE_PROBEN := 8
var reichweite := {}     # Bewegung -> [[Vector3 im Maß der Figur, Halbmesser]]
func _reichweite_merken(nm: String) -> void:
	if anim and not anim.has_animation(nm):
		nm = ALIAS.get(nm, nm)     # wie _play: unter dem Namen, den current_animation dann zeigt
	if reichweite.has(nm) or anim == null or not anim.has_animation(nm) or model == null:
		return
	var sk := _find(model, "Skeleton3D") as Skeleton3D
	if sk == null:
		return
	var vor := String(anim.current_animation)
	var vor_t: float = anim.current_animation_position if vor != "" else 0.0
	var vor_v: float = anim.get_playing_speed() if vor != "" else 1.0
	var l: float = anim.get_animation(nm).length
	var inv := global_transform.affine_inverse()
	var pts: Array = []
	anim.play(nm, 0.0)
	for i in REICHWEITE_PROBEN + 1:
		anim.seek(l * i / float(REICHWEITE_PROBEN), true)
		sk.force_update_all_bone_transforms()
		for c in kapseln():
			pts.append([inv * (c[0] as Vector3), float(c[2])])
			pts.append([inv * (c[1] as Vector3), float(c[2])])
	if vor != "":
		anim.play(vor, 0.0, vor_v)
		anim.seek(vor_t, true)
	else:
		anim.stop()
	sk.force_update_all_bone_transforms()
	reichweite[nm] = pts


## 703 A (Chef 08.11., 21:36: „wenn sie ausgewichen sind, einfach stehen bleiben … Braucht man doch gar nicht.“; ändert F5):
## nach dem Ausweichen bleibt die Figur, wo sie hinsprang, und dreht sich nur wieder zum Gegner; zurück auf den Platz kommt sie mit
## ihrem eigenen Zug (der Heimweg nach Angriff, Biss oder Platzwechsel). Nur wer zu weit vom Platz abkäme (mehrmals hintereinander
## ausgewichen) oder aus dem Bild, geht gleich heim, sonst liefe er Satz um Satz davon.
const AUSWEICH_BLEIB_MAX := 2.5     # m (Modellmeter × Skala) vom Platz
func _nach_ausweichen() -> void:
	var d := Vector2(home.x - position.x, home.z - position.z).length()
	if d > AUSWEICH_BLEIB_MAX * _scale() or not _im_bild(position, Vector3(sin(rotation.y), 0.0, cos(rotation.y))):
		_walk_home()
		return
	if OS.get_environment("SCHAU_MESS") != "":
		print("Ausweichen %s bleibt %.2f m vom Platz" % [fighter.id, d])
	_turn_home()


## 348.12 (Chef 15:23: „Animation … beim Ausweichen“): Grak setzt zur Seite (Seitenlauf der UAL Pro, 1,7 m); zu der, deren Weg von den
## anderen am freiesten ist, bei gleich viel Luft zur Mitte des Kampforts hin
func _ausweich_seite() -> String:
	var best := "Ausweichen"
	var wert := -INF
	for nm in ["Ausweichen", "Ausweichen links"]:
		if not weg.has(nm):
			continue
		var ende := _weg_at(position, basis, nm, (weg[nm].size() - 1) / weg_fps)
		var w := minf(_seg_gap(position, ende, null), 0.3) - ende.length() * 0.01
		if w > wert:
			wert = w
			best = nm
	return best


## nach dem Biss ohne „Ausweichen zurück“ der Quelle so weit (Modellmeter) rückwärts, bevor es sich umdreht (Kopf bleibt vor der Heldin)
const ABSETZEN := 0.6

var ausweich_nr := 0     # 593: zählt das Ausweichen, jedes dritte rückwärts
const AUSWEICH_RUECK_TEMPO := 1.8     # 593: rückwärts im Gang so rasch wie der Satz (546: Gehen × 1,8), nie als Schlaftablette


## 593: geht der Wurzelweg der Bewegung [nm] frei (Abstand zu den anderen wie _ausweich_seite) und bleibt im Bild?
func _weg_frei(nm: String) -> bool:
	var ende := _weg_at(position, basis, nm, (weg[nm].size() - 1) / weg_fps)
	return _seg_gap(position, ende, null) >= 0.25 and _im_bild(ende, Vector3(sin(rotation.y), 0.0, cos(rotation.y)))


## 593: rasch rückwärts absetzen (ABSETZEN), Gesicht zum Gegner, dann heim; false, wenn hinten kein Platz ist oder es aus dem Bild ginge
func _absetzen_rasch() -> bool:
	var rn := "Zurück" if weg.has("Zurück") and anim.has_animation("Zurück") else "Gehen"
	if not weg.has(rn) or not anim.has_animation(rn):
		return false
	var g0 := minf(_rumpf_luft(position, rotation.y), PLATZ_LUFT)
	var zurueck := position - Vector3(basis.z.x, 0.0, basis.z.z).normalized() * ABSETZEN * _scale()
	if _rumpf_luft(zurueck, rotation.y) < g0 or not _im_bild(zurueck, Vector3(sin(rotation.y), 0.0, cos(rotation.y))):
		return false
	var k := 1.0 if rn == "Zurück" else AUSWEICH_RUECK_TEMPO
	bahn = [zurueck]
	tween = create_tween()
	tween.tween_callback(func(): gang = "zurück"; anim.play(rn, 0.1, k if rn == "Zurück" else -float(tempo.get("Gehen", 1.0)) * k))
	_lauf(tween, position, zurueck, rn, k)
	tween.tween_callback(_nach_ausweichen)
	return true


## 717: rasch rückwärts ausweichen (AUSWEICH_RUECK_M), das Gesicht zum Helden, gerade, schräg oder seitlich zurück, je nachdem wo der
## Rumpf frei bleibt und die Figur im Bild; danach bleibt er dort (703 A, _nach_ausweichen); false, wenn nirgends Platz ist
const AUSWEICH_RUECK_M := 1.0      # Modellmeter (× Größe): so weit zurück wie der alte Satz zur Seite in der Breite
const AUSWEICH_SATZ_TEMPO := 2.4   # × Gehen rückwärts: Schrittfolge im Satz
const AUSWEICH_SATZ_MPS := 3.4     # m/s im Mittel, über SATZ_MPS 3,0 (546: „Schlaftabletten“)
func _ausweichen_rueckwaerts() -> bool:
	var g0 := minf(_rumpf_luft(position, rotation.y), PLATZ_LUFT)
	var fz := Vector3(basis.z.x, 0.0, basis.z.z).normalized()
	var blick := Vector3(sin(rotation.y), 0.0, cos(rotation.y))
	var weit := AUSWEICH_RUECK_M * _scale()
	var seiten: Array = [0.0, 35.0, -35.0, 60.0, -60.0] if (ausweich_nr + hash(String(fighter.id))) % 2 == 0 else [0.0, -35.0, 35.0, -60.0, 60.0]
	for w in seiten:
		var ziel := position - fz.rotated(Vector3.UP, deg_to_rad(w)) * weit
		var frei := true
		for i in range(1, 6):
			var p := position.lerp(ziel, i / 5.0)
			if _rumpf_luft(p, rotation.y) < g0 or not _im_bild(p, blick):
				frei = false
				break
		if not frei:
			continue
		bahn = [ziel]
		tween = create_tween()
		# 778 (wolf_mess_438 Build 272: „Gehen zu schnell“ 0,73 m, je im ersten Bild des Satzes, Tempo 1,0, Rumpf 0,18 m): der Satz
		# beginnt mit seinem grössten Tempo (Sinus, auslaufend), _schritt_sync holt das erst ein Bild später ein; gleich im Höchsttempo los
		tween.tween_callback(func(): anim.play("Gehen", 0.08, -float(tempo.get("Gehen", 1.0)) * AUSWEICH_SATZ_TEMPO); anim.speed_scale = 1.6)
		# ein Satz: rasch los, sanft auslaufen (_lauf fuhr gleichmäßig an und brauchte 0,73 s für 1,3 m)
		tween.tween_property(self, "position", ziel, weit / AUSWEICH_SATZ_MPS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_callback(_nach_ausweichen)
		if OS.get_environment("SCHAU_MESS") != "":
			print("Ausweichen %s rückwärts %.0f°, %.2f m" % [fighter.id, w, weit])
		return true
	return false


## Satz beim Ausweichen ohne Wurzelweg der Quelle (Modellmeter, Grad): zur Seite (seitlich, zurück), schräg zurück (seitlich, zurück),
## Drehung am Ende zur Seite bzw. schräg zurück
const AUSWEICHEN := [1.0, 0.0, 0.5, 0.9, 90.0, 120.0]     # r3c: mit Blick geradeaus zur Seite brauchte der Pfad Schleifen (3,5 m), mit 90° 1,6 m


func die() -> void:
	_dreh_ab()
	down = true
	if atem != null:
		atem.active = false     # 453.1: der Tote atmet nicht
	if not weg.is_empty() and tween and tween.is_running():
		tween.kill()     # 348.12f: im Lauf getroffen, liegt es, wo es fällt
	dead_at = int(kampfort.clock_ms)
	if _schatten_tw:
		_schatten_tw.kill()
	if anim and anim.has_animation("Tod"):
		# 596 (Chef 05.11., t266: „Sterbeanimation … von Wolf immer gleich und auf die gleiche Seite. Kann man es zumindest an der Achse
		# spiegeln“; Keiler „tot sehr schnell und wenig smooth“): jeder Gegner fällt zufällig zur einen oder anderen Seite (Spiegelung
		# quer zur Blickrichtung), aus der Bewegung weich in den Sturz statt in 0,05 s; hat er mehrere Sterbebewegungen (Tod, Tod2 …),
		# eine davon. Gilt für jedes Modell mit „Tod“ (Bibliothek: sterbe_spiegeln)
		var nm := "Tod"
		if fighter.side == "FOES":
			var alle := ["Tod"]
			for i in range(2, 5):
				if anim.has_animation("Tod%d" % i): alle.append("Tod%d" % i)
			nm = alle[randi() % alle.size()]
			tod_name = nm
			if randf() < 0.5: sterbe_spiegeln()
		anim.play(nm, TOD_BLEND)
	else:
		var t := create_tween()
		t.tween_property(model, "rotation:z", deg_to_rad(80), FALL_MS / 1000.0)
	# 348.12 (Chef 28.10., 15:23: „Krag ist ein Hauptheld, der muss fulminant sterben am Schluss. Nicht einfach ausgeblendet werden,
	# wir brauchen einen Zusammenbruch“): Grak bricht zusammen (Tod aus Death02: in die Knie, dann vornüber) und bleibt liegen
	if fighter.side == "FOES" and Mars.koerper_of(fighter.monster) not in [Mars.GRAK, Mars.KROGG]:     # 494: Krogg bricht zusammen wie Grak
		# MARS: eigene Sterbebilder, dann ausgeblendet (LISTE-MARS.md); Körper und Bodenschatten zusammen (Helfer Lauf 126: der
		# Schatten lag noch allein auf dem Weg)
		await get_tree().create_timer((sterbe_ms() + LIEGT_MS) / 1000.0).timeout
		var t := create_tween()
		t.tween_method(_fade_out, IM_SCHATTEN if schatten_an else 0.0, 1.0, FADE_MS / 1000.0)     # 566: blass im Schatten bleibt blass
		await t.finished
		visible = false


## 596: aus der Bewegung in den Sturz (vorher 0,05 s: der Keiler kippte hart)
const TOD_BLEND := 0.25
var gespiegelt := false
var tod_name := "Tod"     # 596: die gewählte Sterbebewegung (sterbe_ms)

## 596: spiegelt die Figur quer zur Blickrichtung (Modell um 180° gedreht und längs gespiegelt, so bleibt scale.x die Größe, die
## figur.gd an mehreren Stellen liest); Godot kehrt die Flächen gespiegelter Netze selbst um
func sterbe_spiegeln() -> void:
	if model == null or gespiegelt:
		return
	gespiegelt = true
	model.rotation.y += PI
	model.scale.z = -model.scale.z


## 566 (Chef 04.11., 17:15, Build 257: „steht in den Schatten, aber er schaut nicht aus, als würde er im Schatten stehen“): wer „In den
## Schatten“ gegangen ist (Mars hidden, bis zu seinem nächsten Zug Nachteil auf Angriffe gegen ihn), ist nur schwach zu sehen, wie alt
## (SkirmishScreen.kt 1086: Figur und Bodenschatten Alpha 0,4): Raster des Ausblendens zu IM_SCHATTEN, Bodenschatten ebenso blass
const IM_SCHATTEN := 0.6
var schatten_an := false
var _schatten_tw: Tween


func im_schatten(an: bool) -> void:
	if an == schatten_an or dead_at >= 0:
		return
	schatten_an = an
	if _schatten_tw:
		_schatten_tw.kill()
	var von := 0.0 if an else IM_SCHATTEN
	_schatten_tw = create_tween()
	_schatten_tw.tween_method(func(x: float): _fade_out(x), von, IM_SCHATTEN - von, 0.45)


func _fade_out(x: float) -> void:
	for m in mats:
		m.set_shader_parameter("weg", x)
	var sh := get_node_or_null("Bodenschatten") as MeshInstance3D
	if sh and sh.material_override is ShaderMaterial:
		(sh.material_override as ShaderMaterial).set_shader_parameter("dichte", 0.78 * (1.0 - x))


func knocked_down() -> void:
	_schnaufen(1.0)     # 910: angesprungen und gestürzt strengt an wie ein Treffer (sonst zählten die Bilder danach als Ruhe)
	if _ss() and not anim.has_animation("Sturz"):     # 406: mit Schild der schwere Treffer des Satzes, Schild oben
		_play("SS_GetHitHeavyFront", 0.1)
		get_tree().create_timer(anim.get_animation("SS_GetHitHeavyFront").length - 0.1).timeout.connect(_idle_wenn_frei)
		return
	_play("Sturz" if anim and anim.has_animation("Sturz") else "Treffer", 0.1)


func rise() -> void:
	if kauf and not (anim and anim.has_animation("Aufstehen")):
		_idle()     # 406 (Messung film_406: nach „steht auf“ blieb der Kaufheld in Stehen, ohne Schild oben, bis zum nächsten Zug)
		return
	_play("Aufstehen" if anim and anim.has_animation("Aufstehen") else "Stehen", 0.2)


func howl() -> void:
	_play("Heulen", 0.1)
	get_tree().create_timer(1.4).timeout.connect(_idle)


## Where to put the name and bar above the figure (world).
func head() -> Vector3:
	var h := 1.12 if vier(fighter) else 1.9     # Ohrspitzen des Wolfs (0,9 lag seit den größeren Ohren, Runde 1 nach Chef, unter dem Balken; davor 60 px darüber)
	if vier(fighter) and not ERSATZ_KOPF.has(_mein_ersatz()) and _mein_ersatz().begins_with("kauf_") and mass.has("hoehe_m"):
		h = float(mass.hoehe_m) + 0.15     # 494: Keiler (0,97 m), Hundertfüßer (0,26 m: der Balken stand 0,9 m über ihm) nach dem Kauf
	elif vier(fighter):
		h = ERSATZ_KOPF.get(_mein_ersatz(), h)
	elif mass.has("koerper_hoch_m"):     # 494 Riesenspinne: Name und Balken über dem Körper (0,40 m), nicht in Menschenhöhe 1,9 m
		h = float(mass.koerper_hoch_m) + 0.25
	if gob_h > 0.0:     # Goblin Runde 2 (Prüfer Runde 1: Ansage fern der Goblins): Scheitel aus goblin.py, gebückt etwas tiefer
		h = gob_h * 0.85
		if Mars.koerper_of(fighter.monster) in [SKELETT, WIEDERGAENGER]:     # 506 (Helfer 08.11., 12:55: Lebensbalken auf den Köpfen): das Skelett steht
			h = gob_h + 0.15     # aufrecht, Scheitel 1,72–1,79 m mit Helm (kaufskelett.py groesse_cm); 0,85 davon lag 26 cm unter dem Scheitel; der Wiedergänger gebückt, groesse_cm im Stehen
	return position + Vector3(0, h * (_scale() if fighter.monster != null else 1.0), 0)
