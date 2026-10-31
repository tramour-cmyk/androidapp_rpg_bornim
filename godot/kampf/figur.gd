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
const ERSATZ_KOPF := {"giant_rat": 0.4, "giant_bat": 0.98, "kaufwolf": 1.06}     # Kaufwolf: Ohren 1,175 m (unser Wolf 1,24 m bei 1,12)
const ERSATZ_SCHATTEN := {"giant_rat": [0.3, 0.85, -0.08], "giant_bat": [0.9, 0.5, -0.04]}
## Ersatz ohne Umgebungsvariable (Prüf-APK: Probekampf „Ratten“ setzt giant_rat); ERSATZ geht vor
static var ersatz_art := ""
static func ersatz() -> String:
	return OS.get_environment("ERSATZ") if OS.has_environment("ERSATZ") else ersatz_art
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
const SCHNAUZE_NAEHER := {"giant_rat": -0.02, "kaufwolf": -0.02}
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
	elif fighter.monster.id in [Mars.CALLED, Mars.SCOUT, Mars.GRAK]:
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
	var wolf: bool = fighter.monster != null and fighter.monster.id == Mars.WOLF
	# Wolf: Rumpf 1,1 m lang, 0,4 m breit (mal Größe); Mensch: 0,7 m rund
	# Runde 15 (Prüfer Runde 14: Pfotenschatten „unsichtbar im Rumpfschatten“): schmaler (0,7 statt 1,0), die Pfoten stehen am weichen Rand
	pm.size = Vector2(0.7, 1.5) * _scale() if wolf else Vector2(0.95, 0.95)
	var vor := 0.15
	if wolf and ERSATZ_SCHATTEN.has(ersatz()):
		var es: Array = ERSATZ_SCHATTEN[ersatz()]
		pm.size = Vector2(es[0], es[1]) * _scale(); vor = es[2]
	elif wolf and mass.has("laenge_m"):     # 387 Runde 2 (Prüfer: Schatten in Wolfsgröße, bei Huhn und Kaninchen doppelt so breit): nach dem Kauftier
		pm.size = Vector2(mass.get("breite_m", 0.4) * 1.3, mass.laenge_m * 0.9) * _scale(); vor = 0.0
	mi.mesh = pm
	var m := ShaderMaterial.new()
	m.shader = shadow_shader
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = Vector3(0, 0.02, vor * _scale() if wolf else 0.0)     # Rumpfmitte des Wolfs liegt 0,15 m vor dem Ursprung
	mi.name = "Bodenschatten"
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
		var hoch: float = ERSATZ_KOPF.get(ersatz(), 1.24) * _scale() if fighter.monster != null else 1.8
		var fall := Vector2(-d.x, -d.z).normalized() * hoch * Vector2(d.x, d.z).length() / maxf(d.y, 0.01)
		print("Schattenmess %s %s: Bodenschatten %.2f × %.2f m (vorher %.2f × %.2f), Pfote außen %.2f/%.2f m, Fleck %.2f × %.2f m, Sonne %.0f° hoch, Schlagschatten des Kopfes %.2f m nach (%.2f, %.2f)" % [
			fighter.id, art(), pm.size.x, pm.size.y, vorher.x, vorher.y, bx, bz,
			((paws[0][3] as MeshInstance3D).mesh as PlaneMesh).size.x, ((paws[0][3] as MeshInstance3D).mesh as PlaneMesh).size.y,
			rad_to_deg(asin(clampf(d.y, -1.0, 1.0))), fall.length(), fall.x, fall.y])


func _scale() -> float:
	if fighter.monster == null:
		return 1.0      # held.glb in Metern (Toms rig.py, 348.6, Modellregel 1)
	return kampfort.foe_scale(fighter) * ART_GROESSE.get(art(), 1.0)


## Welches Tier diese Figur zeigt: Grimmzahn, sonst der Ersatz der Probe („“ = Wolf)
func art() -> String:
	if fighter.monster != null and fighter.id == GRIMM:
		return "dire_wolf"
	return ersatz()


func _model_path() -> String:
	if fighter.monster == null:
		return "res://kampf/daten/held.bin"
	if fighter.monster.id == Mars.WOLF:
		if art() == "dire_wolf":     # GRIMMFELL=schimmer: die seltene Schimmervariante
			return "res://kampf/daten/dire_wolf-%s.bin" % (OS.get_environment("GRIMMFELL") if OS.has_environment("GRIMMFELL") else "schwarz")
		var n: int = maxi(fighter.nr, 1) - 1
		var art := ersatz()
		if art.begins_with("kauf_"):     # 387: gekaufte Tiere (kauftier.py), Felle aus <art>-info.json
			var fl := _kauf_felle(art)
			if not fl.is_empty():
				return "res://kampf/daten/%s-%s.bin" % [art, fl[n % fl.size()]]
		if ERSATZ_FELLE.has(art):
			return "res://kampf/daten/%s-%s.bin" % [art, ERSATZ_FELLE[art][n % ERSATZ_FELLE[art].size()]]
		return "res://kampf/daten/wolf-%s.bin" % WOLF_COATS[n % WOLF_COATS.size()]
	if fighter.monster.id in [Mars.CALLED, Mars.SCOUT, Mars.GRAK]:     # 348.7: Goblin, Späher je Nummer eines der drei Kits (goblin.py, MonsterKits)
		return "res://kampf/daten/%s-%s.bin" % [_gob_art(), _gob_kit()]
	return "res://kampf/daten/%s.bin" % fighter.monster.id


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


## 387: Felle eines gekauften Tiers (Schlüssel in <art>-info.json, wie kauftier.py sie baut)
static func _kauf_felle(a: String) -> Array:
	var ip := "res://kampf/daten/%s-info.json" % a
	if not FileAccess.file_exists(ip):
		return []
	var j = JSON.parse_string(FileAccess.get_file_as_string(ip))
	return j.keys() if j is Dictionary else []


## 403 (von Team Tom zu 376.1; Chef 31.10.: nur Modell und Bewegungen): der Held je Klasse auf dem Kaufkörper wie im Dorf
## (HeldFigur.baue: Tracht, Kopf, Haar, Haut), ohne die Ausrüstung unterwegs (die Waffe hält er hier in der Hand, _arm_kauf); dazu
## die Kampfbewegungen aus kampf-bewegungen.bin (held_kampf.py: unsere aus kampf.py, auf das Gerüst der UAL umgerechnet, und die
## Kandidaten „Pro_…“ aus der UAL Pro), übertragen wie HeldFigur.bewegungen. Fehlen die Dateien (Bau ohne Kaufmodelle) oder
## steht ALTHELD=1, bleibt der bisherige Held (held.bin).
const KAMPF_BEW := "res://daten/kampf-bewegungen.bin"
const KAMPF_SCHLEIFEN := ["Kampfstehen", "Pro_Sword_Idle"]
var kauf := false
static var kampf_bew: Array = []     # [Animation, Name] je Bewegung, einmal geladen

func _kaufheld() -> Node3D:
	if fighter.monster != null or OS.get_environment("ALTHELD") != "" or not FileAccess.file_exists(KAMPF_BEW):
		return null
	var k := String(fighter.hero.get("cls", "FIGHTER"))
	if not HeldFigur.da(k):
		return null
	var w := {"klasse": k, "volk": String(fighter.hero.get("race", "HUMAN")), "aussehen": fighter.hero.get("look", {}), "ausruestung": {}}
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
	kauf = true
	return m


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
const OFF_HAND := {"FIGHTER": "shield", "CLERIC": "round_shield"}
const GRIP_CM := 15.7
const PALM_CM := 2.4
const CM := 0.01
const STAFFS := ["quarterstaff", "staff"]

func _arm() -> void:
	var sk := _find(model, "Skeleton3D") as Skeleton3D
	if sk == null:
		return
	var main: String = fighter.hero.main.id if fighter.hero.has("main") and not fighter.hero.main.ranged else ""
	if main != "":
		_hold(sk, "R", main)
	var off: String = OFF_HAND.get(fighter.hero.get("cls", ""), "")
	if off != "":
		_hold(sk, "L", off)


## Goblin, Späher, Grak: Zweibeiner auf dem Gerüst aus goblin.py oder grak_gestalt.py
func _zweibeiner() -> bool:
	return fighter.monster != null and fighter.monster.id in [Mars.CALLED, Mars.SCOUT, Mars.GRAK]


## 403: Waffe und Schild am Kaufkörper. Der Kaufkörper ruht in der T-Pose, darum wie beim Goblin nach der Haltung in Stehen
## ausgerichtet (erst im Baum); die Klinge liegt längs des Faustlochs (HeldFigur.faust: zwischen den Knöcheln von Zeige- und
## Kleinfinger), wie kampf.py die Bewegungen gebaut hat (faust_R), die Schneide in der Ebene aus Faustloch und Handknochen
func _arm_kauf() -> void:
	var sk := _find(model, "Skeleton3D") as Skeleton3D
	if sk == null:
		return
	if not is_inside_tree():
		await tree_entered
	var halt := "Ruhelage" if anim and anim.has_animation("Ruhelage") else "Stehen"
	if anim and anim.has_animation(halt):
		# in unserer Ruhelage (Arme hängend, held_kampf.py) wie der alte Held vor dem Einhängen: so hat kampf.py den Schild gebaut.
		# Prüfer Film 403: der Schild stand quer in Kopfhöhe; im ersten Bild im Baum galt noch die T-Pose, erst ein Bild später die Haltung
		anim.play(halt)
		anim.seek(0.0, true)
		await get_tree().process_frame
		anim.seek(0.0, true)
		sk.force_update_all_bone_transforms()
	var main: String = fighter.hero.main.id if fighter.hero.has("main") and not fighter.hero.main.ranged else ""
	if main != "":
		var fr := HeldFigur.faust(sk, "r")
		_hold(sk, "R", main, GRIP_CM * CM, PALM_CM * CM, 1.0, {}, fr)
	var off: String = OFF_HAND.get(fighter.hero.get("cls", ""), "")
	if off != "":
		_hold(sk, "L", off)
	if anim:
		_idle()


## Goblin, Späher oder (Probe „Schamanen“) Schamane: Kennung der Modelle und der info.json
func _gob_art() -> String:
	if fighter.monster.id == Mars.CALLED and ersatz() in [SHAMAN, KOBOLD]:
		return ersatz()
	return fighter.monster.id


func _gob_kit() -> String:
	if fighter.monster.id == Mars.GRAK:
		return GRAK_KITS[0]
	var kits: Array = SCOUT_KITS if fighter.monster.id == Mars.SCOUT else (SHAMAN_KITS if _gob_art() == SHAMAN else (KOBOLD_KITS if _gob_art() == KOBOLD else GOBLIN_KITS))
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
	if what.contains("shield"):
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
	elif not faust.is_empty() and not what.contains("bow"):
		# 403 Kaufkörper: Griff im Faustloch, Klinge (Stab) längs des Faustlochs zum Daumen hin, Schneide in der Ebene mit dem Handknochen
		var ax: Vector3 = (faust["achse"] as Vector3).normalized()
		var edge := Vector3.UP - ax * Vector3.UP.dot(ax)
		edge = edge.normalized() if edge.length() > 0.01 else ax.cross(Vector3.RIGHT).normalized()
		b = Basis(edge, ax, edge.cross(ax))
		o = faust["griff"]
	elif what in STAFFS:
		# Stab senkrecht neben dem Körper, in der Mitte gefasst
		b = Basis(fwd, -down, fwd.cross(-down))
		o = Vector3(0, grip, 0) + inward * palm
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
	w.name = "Waffe" if side == "R" else "Schild"
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
		if GOB_FILL > 0.0 and fighter != null and fighter.monster != null and String(fighter.monster.id).begins_with("goblin"):
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
	if dir == Vector3.ZERO and fighter.monster != null and fighter.monster.id == Mars.WOLF:
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
		if ersatz() == "giant_bat" and cam != null:
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
		anim.play(name, blend, float(tempo.get(name, 1.0)))


func _idle() -> void:
	if down:
		return
	if kauf and anim and anim.has_animation("Kampfstehen"):
		# 403: die Klinge liegt im Faustloch wie in kampf.py; in Stehen (UAL) zeigte sie waagerecht nach vorn auf Hüfthöhe
		# (DESIGN-ABNAHME Silhouetten); Kampfstehen ist das erste und letzte Bild jeder Kampfbewegung
		_play("Kampfstehen")
		return
	_play("Hocke" if pouncing else "Stehen")


# Prüfer Runde 25: Blick und Rumpf wurden nur bei der Ansage gerichtet; rückte das Ziel danach auf seinen Platz, sah der Wolf
# daneben (Hals 52° bei Ziel 35°). In Ruhe darum jedes Bild neu.
func _process(_dt: float) -> void:
	_shake()
	if not paws.is_empty():
		_paw_shadow_update()
	if aim != null and neck and not down and not (tween and tween.is_running()):
		_face()
	# Drehung abgebrochen (Biss tötet den tween); 387 r4 (Hülle Keiler r4: nach einem abgebrochenen Umdrehen hielt der Pfotenhalt die
	# Pfoten 1,1 s lang im Rennen fest, der Körper lief weiter): auch, sobald das Tier etwas anderes spielt als Stehen
	if halt and halt.drehen and (not (tween and tween.is_running()) or anim and anim.current_animation != "Stehen"):
		halt.los(false)
	if anim and anim.has_animation("Lefzen") and not down and not pouncing and anim.current_animation == "Stehen":
		var now := Time.get_ticks_msec()
		if fidget_at == 0:
			fidget_at = now + randi_range(4000, 9000)
		elif now >= fidget_at:
			fidget_at = 0
			_play("Lefzen" if randf() < 0.5 else scharren_name(), 0.2)
			anim.queue("Stehen")


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
func flee_off(away: Vector3) -> void:
	announce(null)
	glide_to(home + away * 9.0)
	get_tree().create_timer(3.0).timeout.connect(func(): visible = false)


func glide_to(p: Vector3) -> void:
	if p.is_equal_approx(home):
		return
	home = p
	if tween and tween.is_running():
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
	var ip := "res://kampf/daten/%s-info.json" % ia
	if ia == "" or not FileAccess.file_exists(ip):
		return {}
	var j = JSON.parse_string(FileAccess.get_file_as_string(ip))
	var fell := p.get_file().get_basename().get_slice("-", 1)
	if j is Dictionary and j.get(fell) is Dictionary and j[fell].get("weg") is Dictionary and not j[fell].weg.is_empty():
		weg_fps = float(j[fell].get("fps", 30.0))
		if j[fell].get("biss") is Array:
			bite = {"Biss": j[fell].biss}
		if j[fell].get("hieb") is Array:
			hieb = j[fell].hieb
		if j[fell].get("tempo") is Dictionary:
			tempo = j[fell].tempo
		for k in ["breite_m", "laenge_m"]:
			if art().begins_with("kauf_") and j[fell].get(k) != null:
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
		var nm := "Rennen" if way > RUN_FROM and weg.has("Rennen") else "Gehen"
		var tg := way / _mps(nm)
		tween = create_tween()
		var first := via - position if via != position else d
		var tt := _turn(tween, atan2(first.x, first.z), false)
		tween.tween_callback(func(): _play(nm, 0.15))
		if via != position:
			var t1 := position.distance_to(via) / _mps(nm)
			var rest := home - via
			tween.tween_property(self, "position", via, t1)
			tween.tween_callback(func(): rotation.y = atan2(rest.x, rest.z))
			tween.tween_property(self, "position", home, tg - t1)
		else:
			tween.tween_property(self, "position", home, tg)
		tween.tween_callback(_turn_home)
		return tt + tg
	var pfad := _heimweg()
	var t := _pfad_fahren(pfad, false)
	tween.tween_callback(_turn_home)
	return t


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
	var g0 := minf(_seg_gap(p0, p0, null), _seg_gap(home, home, null)) - PFAD_NAEHER
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
				g = minf(g, _seg_gap(pts[i][0], pts[i][0], null))
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
func _pfad_fahren(pfad: Array, eilig: bool) -> float:
	var gerade := 0.0
	for i in range(1, pfad.size()):
		if eilig:
			pfad[i][3] = "G"
		if pfad[i][3] == "G":
			gerade += pfad[i][1] - pfad[i - 1][1]
	var lauf := "Rennen" if (eilig or gerade > RUN_FROM) and weg.has("Rennen") else "Gehen"
	var t := 0.0
	pfad[0].append(0.0)
	for i in range(1, pfad.size()):
		var v: float = _mps(lauf) if pfad[i][3] == "G" else _mps("Gehen") * BOGEN_TEMPO
		t += (pfad[i][1] - pfad[i - 1][1]) / v
		pfad[i].append(t)
	_pfad_anim = ""
	tween = create_tween()
	tween.tween_method(func(x: float): _auf_zeit(pfad, x, lauf), 0.0, t, t)
	return t
## Bögen im Schritt, aber so viel schneller (Bewegung und Schrittfolge zugleich, die Pfoten treten weiter auf; r3b: im Schritt
## dauerte der Biss mit Heimweg 7,3 s statt 4,4 s)
const BOGEN_TEMPO := 1.8


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
	var nm: String = lauf if b[3] == "G" else "Gehen"
	if nm + b[3] != _pfad_anim:     # Prüfer r3c: Gehen im Bogen und auf der Geraden hatten dieselbe Schrittfolge
		_pfad_anim = nm + b[3]
		if anim and anim.has_animation(nm):
			anim.play(nm, 0.15, (1.0 if b[3] == "G" else BOGEN_TEMPO) * float(tempo.get(nm, 1.0)))


## Grad je Sekunde, mit denen ein Tier mit Wurzelweg sich umdreht (180° in 0,4 s)
const TURN_DPS := 450.0
## r4: mit Pfotenhalt (pfotenhalt.gd) langsamer, 180° in 0,75 s: bei 450°/s läge zwischen zwei Tritten einer Pfote über 0,5 m Weg
const TURN_DPS_TRITT := 240.0
## unter diesem Winkel dreht es ohne Schritte
const TURN_STILL := 15.0


func _turn_dps() -> float:
	return TURN_DPS_TRITT if halt else TURN_DPS


## Hängt an [tw] eine Drehung auf [yaw] mit Schritten an (kleine Winkel sofort); gibt die Dauer (s) zurück. r4: mit Pfotenhalt
## steht das Tier (Stehen) und die Pfoten treten nach; [stehen]: danach bleibt es stehen (die Pfoten treten nach), sonst läuft es los
func _turn(tw: Tween, yaw: float, stehen: bool) -> float:
	var dw := wrapf(yaw - rotation.y, -PI, PI)
	if absf(rad_to_deg(dw)) < TURN_STILL:
		tw.tween_callback(func(): rotation.y = yaw)
		return 0.0
	var t := absf(rad_to_deg(dw)) / _turn_dps()
	if halt:
		tw.tween_callback(func(): _play("Stehen", 0.1); halt.an())
	else:
		tw.tween_callback(func(): _play("Gehen", 0.1))
	tw.tween_property(self, "rotation:y", rotation.y + dw, t)
	if halt:
		tw.tween_callback(func(): halt.los(stehen))
	return t


## Daheim zur Blickrichtung von _face() drehen, dann Ruhe; gibt die Dauer (s) zurück
func _turn_home() -> float:
	var r := rotation.y
	_face()
	var goal := rotation.y
	rotation.y = r
	tween = create_tween()
	var t := _turn(tween, goal, true)
	tween.tween_callback(_idle)
	return t


## 348.12f (Chef 27.10., 18:01, Archiv: „Biss zum Helden nachjustieren wie bei eigenen“): mit Wurzelweg läuft das Tier bis vor das
## Ziel, die Schnauze an dessen Rand, und beißt dort; angesagt (Sprung) springt es aus der Weite des Sprungbisses der Quelle an.
## Danach springt es zurück (Ausweichen zurück) und geht heim. Gibt wie strike() die Zeit bis zum Biss / 0,42 zurück (ms).
func _bite(other, leap: bool) -> int:
	var flat := Vector3(other.position.x - position.x, 0.0, other.position.z - position.z)
	if flat.length() < 0.01:
		flat = basis.z
	var dir := flat.normalized()
	var nm := "Sprungbiss" if leap and anim and anim.has_animation("Sprungbiss") and weg.has("Sprungbiss") else "Biss"
	var stand: float = other.body_r() + bite[nm][0] * model.scale.x     # Ursprung bis Mitte des Ziels beim Biss
	stand -= float(SCHNAUZE_NAEHER.get(art(), 0.0))
	var jump := _weg_len(nm) if nm == "Sprungbiss" else 0.0
	var k := 1.0
	var gap := flat.length() - stand
	if jump > 0.0 and gap < jump:     # zu nah für den ganzen Satz: kürzer springen
		k = maxf(gap, 0.2 * jump) / jump
		jump *= k
	var start := position + dir * maxf(0.0, gap - jump)
	_face(flat)
	rotation.y += deg_to_rad(bite[nm][2])     # die Schnauze, nicht die Körperachse zum Ziel
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	var t_run := 0.0
	anlauf_ms = 0
	gang = "anlauf"
	var run := start.distance_to(position)
	if run > 0.15:
		# 399.2 (Chef 28.10., 16:10: „dann läuft der hintere Wolf durch den vorderen“): um die anderen herum wie die Heldin
		var via := _detour(position, start, other)
		var way := run if via == position else position.distance_to(via) + via.distance_to(start)
		var gn := "Rennen" if way > RUN_FROM and weg.has("Rennen") else "Gehen"
		t_run = way / _mps(gn)
		_play(gn, 0.1)
		if via != position:
			var t1 := position.distance_to(via) / _mps(gn)
			var auf := via - position
			var ab := start - via
			var schnauze := rotation.y
			rotation.y = atan2(auf.x, auf.z)
			tween.tween_property(self, "position", via, t1)
			tween.tween_callback(func(): rotation.y = atan2(ab.x, ab.z))
			tween.tween_property(self, "position", start, t_run - t1)
			tween.tween_callback(func(): rotation.y = schnauze)
		else:
			tween.tween_property(self, "position", start, t_run)
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
	elif weg.has("Gehen"):     # r5 (Prüfer r4: der Kaufwolf drehte am Ort des Bisses, der Kopf schwang durch die Heldin): erst rückwärts absetzen
		var zurueck := ABSETZEN * _scale()
		var tz := zurueck / maxf(_mps("Gehen"), 0.1)
		ende = ende - dir * zurueck
		tween.tween_callback(func(): anim.play("Gehen", 0.1, -float(tempo.get("Gehen", 1.0))))
		tween.tween_property(self, "position", ende, tz)
		t_back = tz
	tween.tween_callback(func(): gang = "heim"; _walk_home(other))
	# bis daheim, damit keiner zu einem Ort schlägt, an dem es nicht mehr steht (399.2: mit Umweg)
	var vh := _detour(ende, home, other)
	var heim := Vector2(home.x - ende.x, home.z - ende.z).length() if vh == ende else ende.distance_to(vh) + vh.distance_to(home)
	# r3: Heimweg mit Bogen und Kurve statt Drehen (höchstens ein Halbkreis und ein Bogen daheim mehr als die Gerade)
	var t_heim := 0.0 if heim < 0.12 else heim / _mps("Rennen" if heim > RUN_FROM and weg.has("Rennen") else "Gehen")
	t_heim += 2.0 * PI * TURN_R * _scale() / (_mps("Gehen") * BOGEN_TEMPO) if HEIMWEG_BOGEN else 2.0 * 180.0 / _turn_dps()
	busy_ms = int((t_run + bl + t_back + t_heim) * 1000.0)
	anlauf_ms = int(t_run * 1000.0)
	return int((t_run + bite[nm][1]) * 1000.0 / 0.42)


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
func _hieb(other) -> int:
	var flat := Vector3(other.position.x - position.x, 0.0, other.position.z - position.z)
	if flat.length() < 0.01:
		flat = basis.z
	var dir := flat.normalized()
	var stand: float = other.body_r() - AXT_IM_RAND + float(hieb[0]) * model.scale.x     # Ursprung bis Mitte des Ziels beim Aufschlag
	var start := position + dir * (flat.length() - stand)
	var schlag := atan2(dir.x, dir.z) + deg_to_rad(float(hieb[2]))     # die Schneide, nicht die Körperachse zum Ziel
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
		var gn := "Rennen" if way > RUN_FROM and weg.has("Rennen") else "Gehen"
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
	var t_back := 0.0
	if weit > 0.12:
		var rn := "Zurück" if weg.has("Zurück") and anim.has_animation("Zurück") and weit > 0.3 else "Gehen"
		var v := _mps(rn) if rn == "Zurück" else _mps("Gehen")
		var von := start
		var y := float(d2[1])
		tween.tween_callback(func(): gang = "zurück"; anim.play(rn, 0.15, 1.0 if rn == "Zurück" else -1.0))
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
	return int((t_run + float(hieb[1])) * 1000.0 / 0.42)


## Ground under the figure where no grass grows (halm.gdshader spots): x, z, radius.
func grass_spot() -> Vector3:
	var wolf: bool = fighter.monster != null and fighter.monster.id == Mars.WOLF
	var c := to_global(Vector3(0, 0, 0.15 * _scale() if wolf else 0.0))
	return Vector3(c.x, c.z, 0.5 * _scale() if wolf else 0.3)


## Im Schlag unterwegs (Hin- und Rückweg): zählt beim Ausweichen der Ansagen nicht (Helfer Lauf 126: Ansagen sprangen um
## 300–400 px, während die Heldin zum Wolf und zurück lief)
func lunging() -> bool:
	return tween != null and tween.is_running()


func falling() -> bool:
	# Spielzeit wie die Zeitgeber in die(): mit --write-movie lief die Wanduhr davon, die Ansage galt zu früh als ausgeblendet
	return dead_at >= 0 and kampfort.clock_ms - dead_at < FALL_MS + FADE_MS


## The announced intent (or none): a wolf about to pounce crouches.
func announce(intent, at = null) -> void:
	var p: bool = intent != null and intent.effect == "POUNCE"
	var turned: bool = at != aim
	aim = at
	if turned and not (tween and tween.is_running()):
		_face()
	if p != pouncing:
		pouncing = p
		_idle()


## A blow, bite, shot or spell at [other]; returns how long it takes (ms).
func strike(other, e: Dictionary) -> int:
	var spell: bool = e.spell != null
	var ranged: bool = fighter.ranged()
	if spell or ranged:
		_face(other.position - position)
		_play("Ausholen")
		get_tree().create_timer(0.6).timeout.connect(func(): _face(); _idle())
		busy_ms = 700
		return 700
	var leap: bool = fighter.monster != null and pouncing and fighter.monster.id == Mars.WOLF
	if kauf:
		return _held_schlag(other)
	if _zweibeiner() and weg.has("Gehen") and hieb.size() >= 3:
		return _hieb(other)
	if fighter.monster != null and weg.has("Gehen"):
		if leap:
			pouncing = false
		return _bite(other, leap)
	var ms := BEAST_LUNGE_MS if fighter.monster != null else BLOW_MS
	var to: Vector3 = other.position
	var reach := (to - position) * (0.8 if leap else 0.6)
	var hold := ms * 0.16 / 1000.0
	var back := ms * 0.42 / 1000.0
	var hero: bool = fighter.monster == null
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
const HELD_AUFSCHLAG := 0.37     # kampf.py Hieb: Aufschlag 0,37 s
const HELD_ZURUECK := 2.0        # rückwärts Gehen im doppelten Schritttempo

func _held_mps(nm: String) -> float:
	var v: float = float(model.get_meta("rennen_m_je_s" if nm == "Rennen" else "gehen_m_je_s", 0.0))
	return v if v > 0.1 else (WALK_MPS * 2.0 if nm == "Rennen" else WALK_MPS)


func _held_schlag(other) -> int:
	var to: Vector3 = other.position
	var flat := Vector3(to.x - position.x, 0.0, to.z - position.z)
	var stand: float = HERO_R + other.body_r() + HERO_REACH
	var start := position + flat.normalized() * maxf(0.0, flat.length() - stand) if flat.length() > 0.01 else position
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
		var gn := "Rennen" if way > RUN_FROM and anim.has_animation("Rennen") else "Gehen"
		var von := position
		for q in pts:
			var a: Vector3 = q - von
			tween.tween_callback(func(): _face(a); _play(gn, 0.12))
			var t: float = von.distance_to(q) / _held_mps(gn)
			tween.tween_property(self, "position", q, t)
			t_run += t
			von = q
	var bl: float = anim.get_animation("Hieb").length if anim.has_animation("Hieb") else BLOW_MS / 1000.0
	tween.tween_callback(func(): gang = "hieb"; _face(to - start); _play("Hieb", 0.08))
	tween.tween_interval(bl)
	var heim := start.distance_to(home)
	var back := maxf(HERO_BACK_S, heim / (_held_mps("Gehen") * HELD_ZURUECK))
	tween.tween_callback(func(): _back_home(back, other))
	busy_ms = int((t_run + bl + back) * 1000.0)
	anlauf_ms = 0
	return int((t_run + HELD_AUFSCHLAG) * 1000.0 / 0.42)


## Rückweg der Heldin: rückwärts, ohne Umdrehen (beim Umdrehen sah man Brust und Schildinnenseite: „andere Ausrüstung“, Helfer
## Lauf 126), mit Gehen rückwärts statt Gleiten (Prüfer Runde 3b), um die anderen herum
func _back_home(back: float, skip) -> void:
	var from := position
	var via := _detour(from, home, skip)
	var way := from.distance_to(via) + via.distance_to(home) if via != from else from.distance_to(home)
	if anim and anim.has_animation("Gehen") and way > 0.2:
		_guard(true)
		anim.play("Gehen", 0.12, -clampf(way / back / (_held_mps("Gehen") if kauf else WALK_MPS), 1.0, WALK_MAX))
	tween = create_tween()
	if via != from:
		var b1 := from.distance_to(via) / way * back
		tween.tween_property(self, "position", via, b1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(self, "position", home, back - b1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(self, "position", home, back).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func(): _guard(false); _face(); _idle())


## 399.2 (umweg_399: ohne Wurzelweg lief das Tier nach dem Biss gerade heim, durch den stehenden Nachbarn, bis −0,92 m): heim um
## die anderen herum wie die Heldin, den Umweg erst beim Losgehen gerechnet
func _tier_heim(back: float, skip) -> void:
	gang = "zurück"
	var from := position
	var via := _detour(from, home, skip)
	tween = create_tween()
	if via != from:
		var b1 := from.distance_to(via) / (from.distance_to(via) + via.distance_to(home)) * back
		_face(via - from)
		tween.tween_property(self, "position", via, b1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_callback(func(): _face(home - position))
		tween.tween_property(self, "position", home, back - b1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		_face(home - from)
		tween.tween_property(self, "position", home, back).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func(): _face(); _idle())


## 348.7b (Chef 27.10., 19:36 „D“): wo ein Zauber oder Pfeil die Figur verlässt (Welt): die Spitze eines Stabs, sonst die Faust
## der Waffenhand (Bogen, Klinge) oder die rechte Hand; ohne Gerüst null
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
	if fighter.monster != null and fighter.monster.id == Mars.WOLF:
		if mass.has("laenge_m"):     # 387: Kauftier, wie der Wolf (1,1 m lang, 0,45 m) nach seiner Länge
			return 0.45 / 1.1 * mass.laenge_m * _scale()
		return 0.45 * _scale()
	return HERO_R * (_scale() if fighter.monster != null else 1.0)


## Umriss am Boden im eigenen Raum (Kasten der Netze in Ruhe); ein Wolf ist lang, der Kreis aus body_r() verfehlte den
## Kopf (Prüfer Runde 3b: die Heldin lief durch Wolf 2 zurück; PFAD=1 maß 0,18 m im Umriss bei 0,38 m Kreisabstand)
var _foot := AABB()
var _foot_ok := false
func footprint() -> AABB:
	if not _foot_ok:
		_foot_ok = true
		var inv := global_transform.affine_inverse()
		var first := true
		for m in find_children("*", "MeshInstance3D", true, false):
			var b: AABB = (inv * m.global_transform) * m.get_aabb()
			_foot = b if first else _foot.merge(b)
			first = false
		if first:
			_foot = AABB(Vector3(-body_r(), 0, -body_r()), Vector3(2 * body_r(), 1, 2 * body_r()))
	return _foot


## Wie weit p (Welt) am Boden außerhalb des Umrisses liegt (< 0: darin)
func clearance(p: Vector3) -> float:
	var box := footprint()
	var loc := global_transform.affine_inverse() * p
	var dx := maxf(box.position.x - loc.x, loc.x - box.end.x)
	var dz := maxf(box.position.z - loc.z, loc.z - box.end.z)
	if dx <= 0.0 and dz <= 0.0:
		return maxf(dx, dz)
	return Vector2(maxf(dx, 0.0), maxf(dz, 0.0)).length()


## Kleinster Abstand der Strecke a → b zu einer stehenden anderen Figur (Rand der Heldin an Umriss), in 16 Schritten
func _seg_gap(a: Vector3, b: Vector3, skip = null) -> float:
	var g := INF
	var r := own_r()
	for o in kampfort.figures.values():
		if o == self or o == skip or not o.visible or o.down:
			continue
		for k in 17:
			g = minf(g, o.clearance(a.lerp(b, k / 16.0)) - r)
	return g


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
	for k in range(1, 13):
		var off := 0.2 * k
		for at in [0.5, 0.35, 0.65]:
			for sg in [1.0, -1.0]:
				var via: Vector3 = a + d * (n * at) + side * (off * sg)
				var g := minf(_seg_gap(a, via, skip), _seg_gap(via, b, skip))
				if g >= AIR:
					return via
				if g > best_gap:
					best_gap = g
					best = via
	return best


func hurt(after_ms: int, dies: bool) -> void:
	await get_tree().create_timer(after_ms / 1000.0).timeout
	if hurt_at < 0.0:
		model_rest = model.position
	# 249: wie im alten MARS nur Zittern und Blut; das orange Aufleuchten wirkte als greller Scherenschnitt (Prüfer 26.10.)
	hurt_at = kampfort.clock_ms
	if dies:
		die()
	else:
		_play("Treffer", 0.05)
		get_tree().create_timer(0.45).timeout.connect(_idle)


func dodge(after_ms: int, nm := "") -> void:
	await get_tree().create_timer(after_ms / 1000.0).timeout
	# 348.12f: mit Wurzelweg zur Seite oder zurück, wie die Quelle (Ausweichen links nicht: Kopf unter den Vorderbeinen, Prüfer r7),
	# dann heim; [nm] wählt (Probe SCHAU=ort), sonst der Zufall
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
		tween.tween_method(func(x: float): position = _weg_at(o, b, nm, x), 0.0, bl, bl)
		tween.tween_callback(_walk_home)
		return
	# Kaufwolf (Chef 27.10., 21:51, Archiv: „Ausweichen-Bewegung war am Platz und ohne Ortswechsel … grundsätzlich wie bei der
	# Ratte“; der Kauf hat keine Ausweichbewegung): ein Satz im Lauf zur freieren Seite (Ausweichen) oder schräg zurück (Ausweichen
	# zurück), Pfad wie der Heimweg (Dubins, Radius halb), dann heim
	if weg.has("Rennen") and not down and not lunging():
		if nm == "":
			nm = "Ausweichen zurück" if randf() < 0.5 else "Ausweichen"
		var sc := model.scale.x
		var best: Array = []
		var luft := -INF
		for sg in [1.0, -1.0]:
			var off: Vector3 = (basis.x * sg * AUSWEICHEN[0] - basis.z * AUSWEICHEN[1]) if nm == "Ausweichen" else (basis.x * sg * AUSWEICHEN[2] - basis.z * AUSWEICHEN[3])
			var ziel: Vector3 = position + off * sc
			var yw: float = rotation.y + deg_to_rad(AUSWEICHEN[4] if nm == "Ausweichen" else AUSWEICHEN[5]) * sg
			for art in ["LSL", "RSR", "LSR", "RSL"]:
				var pts := _dubins(position, rotation.y, ziel, yw, TURN_R * 0.5 * _scale(), art)
				if pts.is_empty():
					continue
				var g := INF
				for i in range(0, pts.size(), 3):
					g = minf(g, _seg_gap(pts[i][0], pts[i][0], null))
				# wie _heimweg(): der kürzeste, der den anderen nicht näher kommt als der Start (Ortmess r3c: nach Luft gewählt
				# liefen beide Sätze 3,2–3,7 m)
				var g0 := _seg_gap(position, position, null) - PFAD_NAEHER
				var wert: float = (1000.0 - pts[pts.size() - 1][1]) if g >= g0 else g
				if wert > luft:
					luft = wert
					best = pts
		if not best.is_empty():
			if OS.get_environment("SCHAU_MESS") != "":
				print("Ausweichen %s Länge %.2f m" % [nm, best[best.size() - 1][1]])
			_pfad_fahren(best, true)
			tween.tween_callback(_walk_home)
			return
	_play("Ausweichen", 0.05)
	get_tree().create_timer(0.45).timeout.connect(_idle)


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


## Satz beim Ausweichen ohne Wurzelweg der Quelle (Modellmeter, Grad): zur Seite (seitlich, zurück), schräg zurück (seitlich, zurück),
## Drehung am Ende zur Seite bzw. schräg zurück
const AUSWEICHEN := [1.0, 0.0, 0.5, 0.9, 90.0, 120.0]     # r3c: mit Blick geradeaus zur Seite brauchte der Pfad Schleifen (3,5 m), mit 90° 1,6 m


func die() -> void:
	down = true
	if not weg.is_empty() and tween and tween.is_running():
		tween.kill()     # 348.12f: im Lauf getroffen, liegt es, wo es fällt
	dead_at = int(kampfort.clock_ms)
	if anim and anim.has_animation("Tod"):
		anim.play("Tod", 0.05)
	else:
		var t := create_tween()
		t.tween_property(model, "rotation:z", deg_to_rad(80), FALL_MS / 1000.0)
	# 348.12 (Chef 28.10., 15:23: „Krag ist ein Hauptheld, der muss fulminant sterben am Schluss. Nicht einfach ausgeblendet werden,
	# wir brauchen einen Zusammenbruch“): Grak bricht zusammen (Tod aus Death02: in die Knie, dann vornüber) und bleibt liegen
	if fighter.side == "FOES" and fighter.monster.id != Mars.GRAK:
		# MARS: eigene Sterbebilder, dann ausgeblendet (LISTE-MARS.md); Körper und Bodenschatten zusammen (Helfer Lauf 126: der
		# Schatten lag noch allein auf dem Weg)
		await get_tree().create_timer(FALL_MS / 1000.0).timeout
		var t := create_tween()
		t.tween_method(_fade_out, 0.0, 1.0, FADE_MS / 1000.0)
		await t.finished
		visible = false


func _fade_out(x: float) -> void:
	for m in mats:
		m.set_shader_parameter("weg", x)
	var sh := get_node_or_null("Bodenschatten") as MeshInstance3D
	if sh and sh.material_override is ShaderMaterial:
		(sh.material_override as ShaderMaterial).set_shader_parameter("dichte", 0.78 * (1.0 - x))


func knocked_down() -> void:
	_play("Sturz" if anim and anim.has_animation("Sturz") else "Treffer", 0.1)


func rise() -> void:
	_play("Aufstehen" if anim and anim.has_animation("Aufstehen") else "Stehen", 0.2)


func howl() -> void:
	_play("Heulen", 0.1)
	get_tree().create_timer(1.4).timeout.connect(_idle)


## Where to put the name and bar above the figure (world).
func head() -> Vector3:
	var h := 1.12 if fighter.monster != null and fighter.monster.id == Mars.WOLF else 1.9     # Ohrspitzen des Wolfs (0,9 lag seit den größeren Ohren, Runde 1 nach Chef, unter dem Balken; davor 60 px darüber)
	if fighter.monster != null and fighter.monster.id == Mars.WOLF:
		h = ERSATZ_KOPF.get(ersatz(), h)
	if gob_h > 0.0:     # Goblin Runde 2 (Prüfer Runde 1: Ansage fern der Goblins): Scheitel aus goblin.py, gebückt etwas tiefer
		h = gob_h * 0.85
	return position + Vector3(0, h * (_scale() if fighter.monster != null else 1.0), 0)
