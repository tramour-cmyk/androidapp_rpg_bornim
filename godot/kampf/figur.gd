# 348.7: eine Figur am Kampfort: Modell (Wolf aus tools/blender348/wolf.py, Held aus rig.py), Platz, Bewegungen zu den
# Meldungen: Stehen, Hocke beim angesagten Sprung, Sprung oder Biss zum Ziel und zurück, Treffer, Ausweichen, Sturz, Tod.
extends Node3D

const Mars = preload("res://regeln/mars.gd")
# Schlagzeiten (SkirmishScreen.kt): Biss eines Tiers mit Anlauf 1,0 s, Hieb 0,8 s, Stich 0,6 s
const BEAST_LUNGE_MS := 1000
const BLOW_MS := 800
const STAB_MS := 600
const GLIDE_S := 0.4
const FALL_MS := 900
const FADE_MS := 600
const WOLF_COATS := ["grau", "dunkel", "rost", "asche"]
## 348.9 Entwurf: ERSATZ=boar zeigt das Wolfsrudel mit einem anderen Vierbeiner (Modell und Größe, Regeln bleiben die des Wolfs)
const ERSATZ_FELLE := {"boar": ["dunkel", "grau", "rost"], "giant_rat": ["braun", "grau", "schwarz"]}
## Bewegungen eines Vierbeiners, die beim Wolf anders heißen (wildschwein.py: Hauerstoß statt Biss, Rammen statt Sprung)
## Kopfhöhe (Ohrspitzen) und Bodenschatten (Breite, Länge, Mitte vor dem Ursprung) des Ersatzes in Modellmetern (Ratte Runde 2:
## Balken 200 px über der Ratte, Schatten größer als das Tier)
const ERSATZ_KOPF := {"giant_rat": 0.4}
const ERSATZ_SCHATTEN := {"giant_rat": [0.3, 0.85, -0.08]}
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
## 348.7 Goblin-Schamane (goblin.py ART=goblin_shaman): rußschwarze Robe, Fellumhang, beides; Stab mit Schädel rechts.
## MARS hat noch keinen Schamanen: die Probe „Schamanen“ zeigt Goblins mit seinem Aussehen (ersatz_art), Regeln des Goblins
const SHAMAN := "goblin_shaman"
const SHAMAN_KITS := ["robe", "fell", "beides"]
## 348.7 Kobold (goblin.py ART=kobold): Speer und Kappe, Speer und Schild, Dolch und Fell; MARS hat noch keinen Kobold:
## die Probe „Kobolde“ zeigt Goblins mit seinem Aussehen (ersatz_art), Regeln des Goblins
const KOBOLD := "kobold"
const KOBOLD_KITS := ["kappe", "schild", "fell"]
## Kurzbogen wie Dress.bow: 0,58 der Größe des Schützen (waffen.py baut ihn 101 cm, für den Menschen)
## Späher Runde 2 (Prüfer 1: „von der Schulter bis auf Fußhöhe, für einen Kurzbogen groß“): 0,48
const GOB_BOGEN := 0.48 / 1.01
## Runde 3: Waffen und Schild der Goblins gegen die Menschenwaffen (waffen.py) verkleinert
const GOB_WAFFE := 0.8
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
var aim = null          # Figur, die das Tier laut Ansage angreift; Kopf und Rumpf zeigen dorthin
var neck = null         # kopfdreh.gd am Skelett
var fidget_at := 0      # Chef 08:57 (8): in Ruhe ab und zu Lefzen zeigen oder scharren (ms)
var paws: Array = []    # Runde 14: Kontaktschatten je Pfote [Knochen, Länge, Fleck]
var gob_h := 0.0        # Goblin: Scheitel in Modellmetern (goblin-info.json), für Namen und Ansage (head())


func setup(f, k) -> void:
	fighter = f
	kampfort = k
	model = _load_model()
	add_child(model)
	model.scale = Vector3.ONE * _scale() / ART_GROESSE.get(art(), 1.0)
	if fighter.monster == null:
		_arm()
	elif fighter.monster.id in [Mars.CALLED, Mars.SCOUT]:
		_arm_goblin()
	if fighter.monster != null:
		var sk: Skeleton3D = _find(model, "Skeleton3D")
		if sk:
			neck = preload("res://kampf/kopfdreh.gd").new()
			sk.add_child(neck)
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
		pm.size = Vector2(0.26, 0.32) * _scale()     # Runde 15: der Fleck direkt unter der Pfote ist von oben von ihr verdeckt; als Rand um sie herum sichtbar (0,11 × 0,14 rot gemessen: etwa 115 Bildpunkte je Pfote)
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
	for pw in paws:
		var sk: Skeleton3D = pw[0]
		var g: Transform3D = sk.global_transform * sk.get_bone_global_pose(pw[1])
		var tip: Vector3 = g.origin + g.basis.y.normalized() * pw[2] * _scale()
		var h: float = tip.y - global_position.y
		var mi: MeshInstance3D = pw[3]
		mi.global_transform = Transform3D(Basis(Vector3.UP, rotation.y), Vector3(tip.x, global_position.y + 0.025, tip.z))
		mi.visible = not down and dead_at < 0
		if mi.material_override is ShaderMaterial:
			(mi.material_override as ShaderMaterial).set_shader_parameter("dichte", 0.95 * clampf(1.0 - (h - 0.03) / 0.12, 0.0, 1.0))


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
		if ERSATZ_FELLE.has(art):
			return "res://kampf/daten/%s-%s.bin" % [art, ERSATZ_FELLE[art][n % ERSATZ_FELLE[art].size()]]
		return "res://kampf/daten/wolf-%s.bin" % WOLF_COATS[n % WOLF_COATS.size()]
	if fighter.monster.id in [Mars.CALLED, Mars.SCOUT]:     # 348.7: Goblin, Späher je Nummer eines der drei Kits (goblin.py, MonsterKits)
		return "res://kampf/daten/%s-%s.bin" % [_gob_art(), _gob_kit()]
	return "res://kampf/daten/%s.bin" % fighter.monster.id


func _load_model() -> Node3D:
	var p := _model_path()
	if FileAccess.file_exists(p):
		var doc := GLTFDocument.new()
		var st := GLTFState.new()
		if doc.append_from_buffer(FileAccess.get_file_as_bytes(p), "", st) == OK:
			# Runde 15: unveränderliche Spuren behalten; sonst fehlten im Scharren die ruhenden Knochen (rechter Vorderlauf) und blieben
			# in der Haltung der vorigen Bewegung stehen (Prüfer: „Hasensprung“, zweite Vorderpfote in der Luft)
			var n := doc.generate_scene(st, 30.0, false, false) as Node3D
			_paint(n)
			anim = _find(n, "AnimationPlayer") as AnimationPlayer
			if anim:
				for a in ["Stehen", "Gehen", "Hocke"]:
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


## Goblin, Späher oder (Probe „Schamanen“) Schamane: Kennung der Modelle und der info.json
func _gob_art() -> String:
	if fighter.monster.id == Mars.CALLED and ersatz() in [SHAMAN, KOBOLD]:
		return ersatz()
	return fighter.monster.id


func _gob_kit() -> String:
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
		_hold(sk, "R" if i == 0 else "L", w[i], info.get("griff_m", GRIP_CM * CM), info.get("handflaeche_m", PALM_CM * CM), sz)
	if _gob_art() == SHAMAN:     # Augen und der Schädel am Stab glimmen grün (Eckfarbe mit Alpha 0; goblin.py, waffen.py)
		for m in mats:
			m.set_shader_parameter("glut", 1.8)     # Runde 1b (Prüfer 1a: nicht zu sehen) 2,5; 1c (Prüfer 1b: gelb statt grün) 1,8


## Hangs [what] (a .glb in metres, grip at its origin) on the forearm of [side]; the model is in metres too (held.glb, goblin-*.glb).
## [grip] from the forearm joint to the middle of the hand, [palm] half the hand's thickness (metres).
func _hold(sk: Skeleton3D, side: String, what: String, grip := GRIP_CM * CM, palm := PALM_CM * CM, size := 1.0) -> void:
	var p := "res://kampf/daten/%s.bin" % what
	var bi := sk.find_bone("fo%s-wr%s" % [side, side])
	if bi < 0 or not FileAccess.file_exists(p):
		return
	var doc := GLTFDocument.new()
	var st := GLTFState.new()
	if doc.append_from_buffer(FileAccess.get_file_as_bytes(p), "", st) != OK:
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
		# Runde 1b (Prüfer 1a: von vorn nur ein Strich): Bogenebene seitlich, der Rücken nach außen und etwas vor, so zeigt er die Krümmung
		var aside := -inward * 0.9 + fwd * 0.3
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


func _toon(c: Color) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	if fighter != null and fighter.side == "PARTY":
		m.shader = toon_mark()
		m.set_shader_parameter("fill", 0.42)
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
	if anim and anim.has_animation(name):
		anim.play(name, blend)


func _idle() -> void:
	if down:
		return
	_play("Hocke" if pouncing else "Stehen")


# Prüfer Runde 25: Blick und Rumpf wurden nur bei der Ansage gerichtet; rückte das Ziel danach auf seinen Platz, sah der Wolf
# daneben (Hals 52° bei Ziel 35°). In Ruhe darum jedes Bild neu.
func _process(_dt: float) -> void:
	if not paws.is_empty():
		_paw_shadow_update()
	if aim != null and neck and not down and not (tween and tween.is_running()):
		_face()
	if anim and anim.has_animation("Lefzen") and not down and not pouncing and anim.current_animation == "Stehen":
		var now := Time.get_ticks_msec()
		if fidget_at == 0:
			fidget_at = now + randi_range(4000, 9000)
		elif now >= fidget_at:
			fidget_at = 0
			_play("Lefzen" if randf() < 0.5 else scharren_name(), 0.2)
			anim.queue("Stehen")


func snap_to(p: Vector3) -> void:
	home = p
	position = p


func glide_to(p: Vector3) -> void:
	if p.is_equal_approx(home):
		return
	home = p
	if tween and tween.is_running():
		return     # a lunge brings it back to its new home
	var t := create_tween()
	t.tween_property(self, "position", p, GLIDE_S).set_trans(Tween.TRANS_SINE)


## Ground under the figure where no grass grows (halm.gdshader spots): x, z, radius.
func grass_spot() -> Vector3:
	var wolf: bool = fighter.monster != null and fighter.monster.id == Mars.WOLF
	var c := to_global(Vector3(0, 0, 0.15 * _scale() if wolf else 0.0))
	return Vector3(c.x, c.z, 0.5 * _scale() if wolf else 0.3)


func falling() -> bool:
	return dead_at >= 0 and Time.get_ticks_msec() - dead_at < FALL_MS + FADE_MS


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
		return 700
	var leap: bool = fighter.monster != null and pouncing and fighter.monster.id == Mars.WOLF
	var ms := BEAST_LUNGE_MS if fighter.monster != null else BLOW_MS
	var to: Vector3 = other.position
	var reach := (to - position) * (0.8 if leap else 0.6)
	var there := position + reach
	_face(to - position)
	_play("Sprung" if leap else ("Biss" if fighter.monster != null else "Hieb"), 0.05)
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "position", there, ms * 0.42 / 1000.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(ms * 0.16 / 1000.0)
	tween.tween_callback(func(): _face(home - position))
	tween.tween_property(self, "position", home, ms * 0.42 / 1000.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func(): _face(); _idle())
	if leap:
		pouncing = false
	return ms


func hurt(after_ms: int, dies: bool) -> void:
	await get_tree().create_timer(after_ms / 1000.0).timeout
	for m in mats:
		m.set_shader_parameter("glow", 1.2)
	get_tree().create_timer(0.18).timeout.connect(func():
		for m in mats:
			m.set_shader_parameter("glow", 0.0))
	if dies:
		die()
	else:
		_play("Treffer", 0.05)
		get_tree().create_timer(0.45).timeout.connect(_idle)


func dodge(after_ms: int) -> void:
	await get_tree().create_timer(after_ms / 1000.0).timeout
	_play("Ausweichen", 0.05)
	get_tree().create_timer(0.45).timeout.connect(_idle)


func die() -> void:
	down = true
	dead_at = Time.get_ticks_msec()
	if anim and anim.has_animation("Tod"):
		anim.play("Tod", 0.05)
	else:
		var t := create_tween()
		t.tween_property(model, "rotation:z", deg_to_rad(80), FALL_MS / 1000.0)
	if fighter.side == "FOES":
		# MARS: eigene Sterbebilder, dann ausgeblendet (LISTE-MARS.md)
		await get_tree().create_timer((FALL_MS + FADE_MS) / 1000.0).timeout
		visible = false


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
