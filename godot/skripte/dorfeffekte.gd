class_name DorfEffekte
extends Node3D
# 814 (623.8 A, Chef 09.11., 22:23: Effekte Szene 1 Dorf am Abend; LISTE-EFFEKTE „Reihenfolge“ 1): Kaminrauch (R7 chimney_smoke statt
# unseres Rauchs), Fackeln an Schlagbaum und Schenke (R7 torch_flame, eigene Halter), Staub im Licht in Schenke und Laden
# (R7 dust_motes), Fussstaub des Helden auf Erdwegen (R7 footstep_dust), Fahne am Schlagbaum (R11 cloth_flag), ein Wind fuer Gras,
# Baeume, Rauch und Fahne (GrassWind aus 804), Federn, wenn ein Huhn auffliegt (R4 feather_burst). Gras weicht aus: 804.
# Leitbild 1: alles gedaempft, kein Leuchten ausser Feuer, kein Gluehen im Rauch. Die Pakete liegen nur im Bau (godot.yml
# „Effektpakete“, Lizenz: nie ins Repo); fehlen sie, bleibt das Dorf wie bisher. `an` ist der Schalter fuer die Grafikstufen (698)
# und das Testmenue (Bilder/s vorher und nachher); er gilt beim naechsten Aufbau eines Orts.

const VFX := "res://addons/reeboo_vfx/"
const FLAGGE := "res://addons/reeboo_surfaces/shaders/cloth_flag.gdshader"
const ORTE := ["village", "inn", "shop"]   # Szene 1; Wald und Hoehle kommen mit Szene 3 (623.8 A)
const RAUCH_K := 0.45                      # Kaminrauch des Pakets auf unseren Massstab (Haus gut 4 m, Rauch bisher 0,45-m-Flocken)
# 814 Fussstaub: Groesse und Deckung der Vorlage (R7 footstep_dust) auf unser Bild, Begruendung bei fussstaub()
const STAUB_K := 1.8
const STAUB_DECK := 2.8
const FEDER_K := 0.35                      # Huhn statt Mensch
const FACKEL_K := 0.6

static var an := true
static var jetzt: DorfEffekte = null       # die Effekte des Orts, auf dem der Held ist (leute.gd: Federn)

static func da() -> bool:
	return ResourceLoader.exists(VFX + "effects/chimney_smoke.tscn") and ResourceLoader.exists(VFX + "vfx_effect.gd")

static func aktiv() -> bool:
	return an and da()

static func fuer(id: String) -> bool:
	return id in ORTE

var gebiet: Gebiet
var kaminrauch: Array[Node3D] = []
var fackeln: Array = []                    # {fx, licht, basis}
var stoffe: Array[ShaderMaterial] = []     # Fahnen
var laub: Array[ShaderMaterial] = []       # Toon-Materialien mit sway (Baeume, Buesche)
var rauch_pm: Array[ParticleProcessMaterial] = []
var kamine: Array = []                     # {teile: GPUParticles3D, h: 0..1} je Kamin eigener Takt (alt drawTownSmoke)
var tritt_ph := -1.0
var tritt_seite := 1.0
var nacht_k := 0.0
var zeit := 0.0
var wind_uhr := 0.0
var _laub_da := {}
var _szenen := {}

func _init(g: Gebiet) -> void:
	gebiet = g
	name = "DorfEffekte"

func _enter_tree() -> void:
	jetzt = self

func _exit_tree() -> void:
	if jetzt == self: jetzt = null
	sway(1.0)   # wie Gebiet.male

func szene(datei: String) -> PackedScene:
	if not _szenen.has(datei):
		var p := VFX + datei
		_szenen[datei] = load(p) if ResourceLoader.exists(p) else null
	return _szenen[datei]

## baut, was der Ort braucht; vom Gebiet nach baue_leben und baue_lampen
func baue() -> void:
	var id := gebiet.karte.id
	if id == "village":
		baue_kaminrauch()
		baue_schlagbaum()
		baue_schenkenfackel()
	# 990 (Chef 12.11., 08:34, t278.4: „sieht eher aus wie ein Mückenschwarm … lassen wir echt komplett in Innenräumen raus“): kein
	# Staub im Licht mehr in Innenräumen; baue_staub bleibt im Bestand (LISTE-EFFEKTE), aufgerufen wird es nicht
	sammle_laub(gebiet)
	nacht(nacht_k)

# ---------------------------------------------------------------- Teilchen anpassen
## Vorlage auf unseren Massstab: Wege, Groessen, Schwere und Austrittsform mal k (Godot skaliert Teilchen nicht mit dem Knoten)
static func massstab(fx: Node, k: float) -> void:
	for p in fx.find_children("*", "GPUParticles3D", true, false):
		var gp := p as GPUParticles3D
		var pm := (gp.process_material as ParticleProcessMaterial).duplicate() as ParticleProcessMaterial
		pm.initial_velocity_min *= k; pm.initial_velocity_max *= k
		pm.radial_velocity_min *= k; pm.radial_velocity_max *= k
		pm.gravity *= k
		pm.scale_min *= k; pm.scale_max *= k
		pm.emission_sphere_radius *= k
		pm.emission_box_extents *= k
		pm.emission_ring_radius *= k; pm.emission_ring_inner_radius *= k; pm.emission_ring_height *= k
		gp.process_material = pm
		gp.position *= k
		var m := gp.draw_pass_1
		if m is QuadMesh and (m as QuadMesh).size != Vector2.ONE:
			m = m.duplicate(); (m as QuadMesh).size *= k; gp.draw_pass_1 = m
	for l in fx.find_children("*", "Light3D", true, false):
		(l as Node3D).position *= k
		if l is OmniLight3D: (l as OmniLight3D).omni_range *= k

## nach der Tusche malen (kamera.gd, Prioritaet 0), wie unser Rauch (punkt_mat render_priority 1); sonst liegen Linien auf dem Rauch
static func nach_tusche(fx: Node) -> void:
	for p in fx.find_children("*", "GeometryInstance3D", true, false):
		var gi := p as GeometryInstance3D
		gi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if gi.material_override is ShaderMaterial:
			var m := (gi.material_override as ShaderMaterial).duplicate() as ShaderMaterial
			m.render_priority = 1
			gi.material_override = m

## Leitbild 1: Farben der Vorlage entsaettigt und dunkler (Faktor auf den Farbverlauf: Saettigung s, Helligkeit v, Deckung a)
static func daempfe(fx: Node, s: float, v: float, a := 1.0) -> void:
	for p in fx.find_children("*", "GPUParticles3D", true, false):
		var pm := (p as GPUParticles3D).process_material as ParticleProcessMaterial
		var gt := pm.color_ramp as GradientTexture1D
		if gt == null or gt.gradient == null: continue
		var g := gt.gradient.duplicate() as Gradient
		for i in g.get_point_count():
			var c := g.get_color(i)
			g.set_color(i, Color.from_hsv(c.h, c.s * s, c.v * v, clampf(c.a * a, 0.0, 1.0)))
		var nt := gt.duplicate() as GradientTexture1D
		nt.gradient = g
		pm.color_ramp = nt

static func ohne(fx: Node, namen: Array) -> void:
	for n in namen:
		var k := fx.get_node_or_null(NodePath(n))
		if k: k.get_parent().remove_child(k); k.free()

## weg: Teile der Vorlage, die wir nicht wollen; vor dem Einhaengen entfernt (VFXEffect merkt sich in _ready seine Lichter)
func setze(datei: String, at: Vector3, k: float, weg: Array = []) -> Node3D:
	var sz := szene(datei)
	if sz == null: return null
	var fx := sz.instantiate() as Node3D
	ohne(fx, weg)
	massstab(fx, k)
	nach_tusche(fx)
	fx.position = at
	add_child(fx)
	return fx

# ---------------------------------------------------------------- Kaminrauch
## R7 chimney_smoke an jedem Kamin (dorf.py „rauch“) statt unseres Rauchs; ohne die Glut (Leitbild 1). Das Lagerfeuer behaelt seinen.
func baue_kaminrauch() -> void:
	for l in gebiet.info["lichter"]:
		if l["art"] != "rauch": continue
		var fx := setze("effects/chimney_smoke.tscn", Gebiet.gpos(l["pos"]) + Vector3(0, 0.1, 0), RAUCH_K, ["Embers"])
		if fx == null: return
		daempfe(fx, 0.6, 0.9)
		var teile := fx.find_children("*", "GPUParticles3D", true, false)
		for p in teile:
			rauch_pm.append((p as GPUParticles3D).process_material as ParticleProcessMaterial)
		kamine.append({"teile": teile, "h": float((kaminrauch.size() * 7919 + 1237) % 1000) / 1000.0})
		kaminrauch.append(fx)
	if not kaminrauch.is_empty():
		for r in gebiet.rauch:
			if not gebiet.feuer.any(func(f): return f["rauch"] == r): r.visible = false

# ---------------------------------------------------------------- Fackeln
## Halter: Stiel aus dunklem Holz mit Eisenband und Pechkopf, Fuss im Ursprung, nach +Y; Toon und Tusche wie die Karte (Gebiet.male)
static func halter(lang: float) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var teile := [[0.0, lang, 0.022, 0.026, Color(0.26, 0.18, 0.11)], [lang * 0.72, lang * 0.78, 0.03, 0.03, Color(0.12, 0.11, 0.1)],
		[lang, lang + 0.12, 0.034, 0.042, Color(0.09, 0.07, 0.06)]]
	for t in teile:
		var y0: float = t[0]; var y1: float = t[1]; var r0: float = t[2]; var r1: float = t[3]; var c: Color = t[4]
		for i in 8:
			var a0 := TAU * i / 8.0; var a1 := TAU * (i + 1) / 8.0
			var q := [Vector3(cos(a0) * r0, y0, sin(a0) * r0), Vector3(cos(a1) * r0, y0, sin(a1) * r0),
				Vector3(cos(a1) * r1, y1, sin(a1) * r1), Vector3(cos(a0) * r1, y1, sin(a0) * r1)]
			for j in [0, 2, 1, 0, 3, 2]:
				st.set_color(c); st.set_normal(Vector3(q[j].x, 0, q[j].z).normalized()); st.set_uv(Vector2.ZERO); st.add_vertex(q[j])
			st.set_color(c); st.set_normal(Vector3.UP); st.set_uv(Vector2.ZERO); st.add_vertex(Vector3(0, y1, 0))
			st.add_vertex(q[2]); st.add_vertex(q[3])
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.name = "Fackelhalter"
	return mi

## eine Fackel: Halter am Fuss fuss, um neigung (Grad) zur Seite seite geneigt; Flamme am Kopf; Licht wie eine Laterne (Tusche nach dem
## Licht), nur abends und nachts an (nacht())
func fackel(fuss: Vector3, seite: Vector3, neigung: float, lang: float) -> void:
	var h := halter(lang)
	var achse := Vector3.UP.cross(seite).normalized()
	h.basis = Basis(achse, deg_to_rad(neigung)) if achse.length() > 0.1 else Basis()
	h.position = fuss
	add_child(h)
	Gebiet.male(h, null)
	var kopf := fuss + h.basis * Vector3(0, lang + 0.1, 0)
	# eigenes Licht unten, die Vorlage flackert ihr Licht selbst und wuerde unseres ueberschreiben
	var fx := setze("effects/torch_flame.tscn", kopf, FACKEL_K, ["Light"])
	if fx == null: return
	daempfe(fx, 0.85, 0.85)
	var o := OmniLight3D.new()
	o.position = kopf + Vector3(0, 0.15, 0)
	o.omni_range = 2.6
	o.light_color = Color(1.0, 0.62, 0.3)
	o.omni_attenuation = 0.9
	o.light_cull_mask = 0xFFFFF & ~Gebiet.BODEN_SCHICHT
	o.shadow_enabled = false
	o.set_meta("reich", 2.2 * Karte.TS)
	o.set_meta("kraft", 0.8)
	o.add_to_group("tuschelicht")
	add_child(o)
	fackeln.append({"fx": fx, "licht": o, "ph": randf() * TAU, "brennt": true})

## Schlagbaum: je eine Fackel auf dem Zaunpfosten links und rechts des Balkens (dorf.py „x“, 105 cm), nach aussen geneigt;
## daneben die Fahne am Pfosten links
func baue_schlagbaum() -> void:
	var k := gebiet.karte
	for r in k.hoehe:
		for c in k.breite:
			var t := Vector2i(c, r)
			if k.zeichen(t) != "z" or k.zeichen(t - Vector2i(1, 0)) == "z": continue
			var e := t
			while k.zeichen(e + Vector2i(1, 0)) == "z": e += Vector2i(1, 0)
			var links := t - Vector2i(1, 0); var rechts := e + Vector2i(1, 0)
			for p in [[links, Vector3.LEFT], [rechts, Vector3.RIGHT]]:
				if k.zeichen(p[0]) != "x": continue
				fackel(k.kachel_pos(p[0]) + Vector3(0, 1.05, 0.02), p[1], 12.0, 0.42)
			if k.zeichen(links) == "x": fahne(k.kachel_pos(links) + Vector3(-0.14, 0, -0.1))

## Schenke: Wandfackel links neben der Tuer (dorf.py „tuer“ 60 cm vor der Wand), schraeg von der Wand weg
func baue_schenkenfackel() -> void:
	var schild := Vector2i(-1, -1)
	for s in gebiet.karte.daten.get("schilder", []):
		var de := String((s["text"] as Dictionary).get("de", ""))
		if de.contains("Gasthaus"): schild = Vector2i(int(s["x"]), int(s["y"]))
	if schild.x < 0: return
	var best: Vector3; var bd := 1e9
	var sp := gebiet.karte.kachel_pos(schild)
	for l in gebiet.info["lichter"]:
		if l["art"] != "tuer": continue
		var q := Gebiet.gpos(l["pos"])
		var d := Vector2(q.x - sp.x, q.z - sp.z).length()
		if d < bd: bd = d; best = q
	if bd > 3.0 * Karte.TS: return
	var wand := best.z - 0.6   # Godot +Z ist Sueden, die Front zeigt nach Sueden
	fackel(Vector3(best.x - 0.78, 1.55, wand + 0.06), Vector3.BACK, 30.0, 0.38)
	gebiet.insel_dazu(Vector4(best.x - 0.78, wand + 0.5, 1.8 * Karte.TS, 0.7))

# ---------------------------------------------------------------- Fahne
## R11 cloth_flag mit Toon-Licht statt PBR (Signatur: Licht aus Quelle, kein Glanz); Tuch dunkelrot mit mattem Goldrand, etwas zerschlissen
func fahne(fuss: Vector3) -> void:
	if not ResourceLoader.exists(FLAGGE): return
	var stange := halter(3.0)
	stange.name = "Fahnenstange"
	stange.position = fuss
	add_child(stange)
	Gebiet.male(stange, null)
	var sh := load(FLAGGE) as Shader
	var code := sh.code.replace("diffuse_burley, specular_schlick_ggx", "diffuse_toon, specular_disabled")
	code = code.replace('#include "surface_common.gdshaderinc"', '#include "res://addons/reeboo_surfaces/shaders/surface_common.gdshaderinc"')
	var toon := Shader.new()
	toon.code = code
	var m := ShaderMaterial.new()
	m.shader = toon
	m.set_shader_parameter("cloth_color", Color(0.30, 0.07, 0.06))
	m.set_shader_parameter("pattern_color", Color(0.55, 0.42, 0.2))
	m.set_shader_parameter("back_tint", Color(0.7, 0.7, 0.72))
	m.set_shader_parameter("pattern", 1)
	m.set_shader_parameter("pattern_width", 0.06)
	m.set_shader_parameter("tattered", 0.35)
	m.set_shader_parameter("roughness", 1.0)
	m.set_shader_parameter("wave_height", 0.08)
	m.set_shader_parameter("out_axis", 2)
	for t in [["fabric_texture", "fabric_rgba"], ["fabric_normal", "fabric_normal"], ["noise_texture", "noise_rgba"]]:
		var p := "res://addons/reeboo_surfaces/textures/%s.png" % t[1]
		if ResourceLoader.exists(p): m.set_shader_parameter(t[0], load(p))
	var qm := QuadMesh.new()
	qm.size = Vector2(0.9, 0.6)
	qm.subdivide_width = 24; qm.subdivide_depth = 16
	qm.center_offset = Vector3(0.45, 0, 0)   # UV.x = 0 an der Stange (der Shader haelt diese Kante fest)
	var tuch := MeshInstance3D.new()
	tuch.mesh = qm
	tuch.material_override = m
	tuch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	tuch.position = fuss + Vector3(0.03, 2.72, 0)
	tuch.rotation.y = deg_to_rad(-25.0)   # schraeg zur Kamera, damit das Tuch nicht flach von der Kante zu sehen ist
	tuch.name = "Fahne"
	add_child(tuch)
	stoffe.append(m)

# ---------------------------------------------------------------- Staub im Licht
## R7 dust_motes in Schenke und Laden: nur die Flocken (Lichtschacht und Licht der Vorlage aus; das Licht malt raumlicht.gd), je Fenster
## (raum.py „tageslicht“, die Lichtquelle vor dem Fenster) ein Schwarm im Lichtkegel; die Fenster hinten zuerst.
## 990 (Chef 11.11., 20:19 und 20:51, t277: „Die Partikel gehen über den Raum hinaus“; in der Schenke „bei der Tür … irgendwelche
## Partikel“, an den Fenstern keine): vorher stand der Schwarm 1,9 m von der Lichtquelle zur Raummitte hin, die Quelle steht aber
## 1,6 m vor der Wand, also nur gut 0,2 m innen, schräg zur Mitte, und die Austrittsform der Vorlage reichte durch die Wand ins
## Schwarze. Jetzt: Mitte im Kegel zwischen Fenster und Lichtfleck am Boden („ziel“), eigene Austrittsform, die mit dem Weg der
## Flocken innen bleibt (staub_kasten), und nur am Tag (nacht: das Fenster ist dunkel)
const STAUB_RAND := 0.2                    # so weit bleiben Flocken samt Weg von der Innenseite der Wand (m)
var staub: Array[GPUParticles3D] = []

func baue_staub() -> void:
	var k := gebiet.karte
	var lichter: Array = []
	for l in gebiet.info["lichter"]:
		if l["art"] == "tageslicht" or l["art"] == "fenster": lichter.append(l)
	lichter.sort_custom(func(a, b): return Gebiet.gpos(a["pos"]).z < Gebiet.gpos(b["pos"]).z)
	for l in lichter.slice(0, 3):   # Leistung: hoechstens drei Schwaerme je Raum
		var q := Gebiet.gpos(l["pos"])
		var z := Gebiet.gpos(l["ziel"]) if l.has("ziel") else Vector3(k.breite * Karte.TS / 2, 0, k.hoehe * Karte.TS / 2)
		var fx := setze("effects/dust_motes.tscn", Vector3.ZERO, 0.6, ["Shaft", "Light"])
		if fx == null: return
		daempfe(fx, 0.5, 0.75)
		for gp in fx.find_children("*", "GPUParticles3D", true, false):
			var p := gp as GPUParticles3D
			var pm := p.process_material as ParticleProcessMaterial
			var weg := staub_weg(pm, p.lifetime)
			var kasten := staub_kasten(q, z, k.breite, k.hoehe, weg)
			fx.position = kasten["mitte"]
			p.position = Vector3.ZERO
			pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
			pm.emission_box_extents = kasten["halb"]
			p.visibility_aabb = AABB(-kasten["halb"] - Vector3.ONE * weg, (kasten["halb"] + Vector3.ONE * weg) * 2.0)
			staub.append(p)

## Weg einer Flocke in ihrer Lebenszeit (m): Anfangstempo und Schwere; was die Vorlage sonst treibt, faengt STAUB_RAND
static func staub_weg(pm: ParticleProcessMaterial, lebenszeit: float) -> float:
	var v := maxf(absf(pm.initial_velocity_max), absf(pm.initial_velocity_min))
	return minf(v * lebenszeit + 0.5 * pm.gravity.length() * lebenszeit * lebenszeit, 0.6)

## 990: Mitte und halbe Groesse des Schwarms fuer das Fenster mit Lichtquelle [quelle] (vor der Wand) und Lichtfleck [ziel] (am Boden
## im Raum) in einem Raum von [breite] x [hoehe] Kacheln (Waende in den Randkacheln); [weg]: so weit treiben die Flocken aus dem Kasten.
## Der Kasten liegt im Kegel, gut 0,8 m innen vor dem Fenster, und mit [weg] und STAUB_RAND ganz innerhalb der Innenwaende.
static func staub_kasten(quelle: Vector3, ziel: Vector3, breite: int, hoehe: int, weg := 0.0) -> Dictionary:
	var n := Vector3(ziel.x - quelle.x, 0, ziel.z - quelle.z).normalized()   # vom Fenster in den Raum
	var mitte := Vector3(ziel.x, 1.2, ziel.z) - n * 0.55
	var halb := Vector3(0.45, 0.5, 0.45)
	if absf(n.x) > absf(n.z): halb = Vector3(0.4, 0.5, 0.5)
	else: halb = Vector3(0.5, 0.5, 0.4)
	var lo := Vector3(Karte.TS, 0.1, Karte.TS) + Vector3.ONE * (STAUB_RAND + weg)
	var hi := Vector3((breite - 1) * Karte.TS, 2.4, (hoehe - 1) * Karte.TS) - Vector3.ONE * (STAUB_RAND + weg)
	for a in 3:
		var platz := (hi[a] - lo[a]) / 2.0
		halb[a] = clampf(minf(halb[a], platz), 0.05, 1.0)
		mitte[a] = clampf(mitte[a], lo[a] + halb[a], maxf(lo[a] + halb[a], hi[a] - halb[a]))
	return {"mitte": mitte, "halb": halb}

# ---------------------------------------------------------------- Fussstaub
## Fussstaub, wo der Fuss aufsetzt (Held.schritt_phase: 0 rechter, 0,5 linker Ballen), nur auf Erde (Bodenmaske Rot, nicht Pflaster,
## nicht Gras), beim Rennen staerker
func tritt(held: Node3D) -> void:
	if not (held is Held): return
	var h := held as Held
	if h.anim == null or h.tempo_jetzt < 0.15: tritt_ph = -1.0; return
	var cur := h.anim.current_animation
	if not (cur.begins_with("Gehen") or cur.begins_with("Rennen")): tritt_ph = -1.0; return
	var ph := Held.schritt_phase(h.anim.get_animation(cur), h.anim.current_animation_position)
	var vor := tritt_ph
	tritt_ph = ph
	if vor < 0.0: return
	var auf := (vor > 0.8 and ph < 0.2) or (vor < 0.5 and ph >= 0.5)
	if not auf: return
	tritt_seite = 1.0 if ph < 0.25 else -1.0
	var rechts := h.global_basis.x.normalized()
	var p := h.global_position + rechts * 0.1 * tritt_seite
	if not erde(p): return
	fussstaub(Vector3(p.x, 0.02, p.z), cur.begins_with("Rennen"))

## 814 (dritter Fund t278.2, „ich sehe diese Wölkchen wieder nicht“): am Rechner in Echtzeitschritten nachgestellt (--fixed-fps 30; ohne
## das laeuft das Spiel dort mit einem Bild je 1,5 s, eine 0,7-s-Wolke lebt dann ein Bild). Zwei Ursachen: (1) der Shader der Vorlage
## blendet aus, was naeher als 0,25 m vor dem Boden dahinter liegt (proximity_fade); von schraeg oben liegt der Boden kaum 0,15 m hinter
## den Woelkchen, sie verschwanden ganz; jetzt nur die letzten STAUB_NAH m an der Schnittkante. (2) Auch ohne Ausblendung nur ein Hauch:
## Puffs 13-50 cm, hoechstens die Haelfte deckend und das nur 0,1 s, 0,7 s Leben, beige wie der Erdweg. Jetzt groesser (STAUB_K),
## deckender (STAUB_DECK), heller als die Erde (STAUB_HELL) und laenger (STAUB_LEBEN); abends weiter um 0,4 dunkler. Ohne die Funken
## der Vorlage (Specks, additiv hell): in dieser Groesse lasen sie sich als weisse Kuegelchen
const STAUB_NAH := 0.03
const STAUB_LEBEN := 1.5
const STAUB_HELL := 1.05
func fussstaub(at: Vector3, rennen: bool) -> Node3D:
	var fx := setze("effects/footstep_dust.tscn", at, STAUB_K * (1.3 if rennen else 1.0), ["Specks"])
	if fx == null: return null
	daempfe(fx, 0.8, STAUB_HELL * (1.0 - 0.4 * nacht_k), STAUB_DECK)
	nah_am_boden(fx)
	for p in fx.find_children("*", "GPUParticles3D", true, false):
		(p as GPUParticles3D).lifetime *= STAUB_LEBEN
	return fx

static func nah_am_boden(fx: Node) -> void:
	for gi in fx.find_children("*", "GeometryInstance3D", true, false):
		var m = (gi as GeometryInstance3D).material_override
		if m is ShaderMaterial and (m as ShaderMaterial).shader and (m as ShaderMaterial).shader.get_shader_uniform_list().any(func(u): return u.name == "proximity_fade"):
			(m as ShaderMaterial).set_shader_parameter("proximity_fade", STAUB_NAH)

func erde(p: Vector3) -> bool:
	var img := Gebiet.maske_bild(gebiet.karte.id)
	if img == null: return false
	var px := img.get_pixel(clampi(int(p.x / Karte.TS * 16), 0, img.get_width() - 1), clampi(int(p.z / Karte.TS * 16), 0, img.get_height() - 1))
	return px.r > 0.45 and px.g < 0.3 and px.a < 0.3

# ---------------------------------------------------------------- Federn
## R4 feather_burst klein, wenn ein Huhn auffliegt (leute.gd fliehe, 591)
func federn(at: Vector3) -> void:
	var fx := setze("pack3_effects/feather_burst.tscn", at + Vector3(0, 0.25, 0), FEDER_K)
	if fx: daempfe(fx, 0.6, 0.85 - 0.45 * nacht_k)

# ---------------------------------------------------------------- Wind und Tag
## ein Wind fuer alles (GrassWind aus 804): Baeume und Buesche wiegen staerker in der Boe, Rauch treibt mit dem Wind, die Fahne weht mit
func sammle_laub(n: Node) -> void:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		for i in mi.get_surface_override_material_count():
			var m := mi.get_surface_override_material(i) as ShaderMaterial
			var w = m.get_shader_parameter("sway") if m else null
			if w != null and float(w) > 0.0 and not _laub_da.has(m):
				_laub_da[m] = true
				laub.append(m)
	for c in n.get_children():
		if c != self: sammle_laub(c)

## auch die Durchgaenge der Durchsicht (next_pass), sonst verrutscht das Laub vor dem Helden gegen das deckende
func sway(w: float) -> void:
	for m in laub:
		var x := m
		while x:
			x.set_shader_parameter("sway", w)
			x = x.next_pass as ShaderMaterial

func wind() -> Node:
	return get_node_or_null(^"/root/GrassWind")

func _process(dt: float) -> void:
	zeit += dt
	if gebiet.held: tritt(gebiet.held)
	var w := wind()
	var boe := 0.5
	var richtung := Vector2(0.84, 0.54)
	if w and gebiet.held:
		boe = clampf(float(w.call("gust_at", Vector2(gebiet.held.global_position.x, gebiet.held.global_position.z))), 0.0, 1.0)
		richtung = w.call("get_direction")
	wind_uhr -= dt
	if wind_uhr <= 0.0:   # Boeen aendern sich langsam (GrassWind gust_speed 3 m/s, 9 m gross): zehnmal je Sekunde reicht
		wind_uhr = 0.1
		sway(0.8 + 0.9 * boe)
	for m in stoffe:
		m.set_shader_parameter("wind_strength", 0.35 + 0.5 * boe)
	# alt (WorldScreen.kt drawTownSmoke, Nutzer „nicht synchron“): jeder Kamin raucht auf seine Weise, eigene Neigung und ein Feuer, das
	# in langsamen Stoessen staerker und schwaecher zieht; dazu treibt der Wind ihn (neu: Richtung und Boe aus GrassWind)
	for km in kamine:
		var h: float = km["h"]
		var zug := 0.65 + 0.35 * sin(zeit / (5.3 + h * 4.1) + h * 6.3) * sin(zeit / (1.9 + h * 0.9) + h * 2.1)
		var lean := (0.08 + 0.2 * boe) * (0.8 + 0.5 * h)
		for p in km["teile"]:
			var gp := p as GPUParticles3D
			gp.amount_ratio = zug
			(gp.process_material as ParticleProcessMaterial).gravity = Vector3(richtung.x * lean, 0.3 * RAUCH_K, richtung.y * lean)
	for f in fackeln:
		if not f["brennt"]: continue
		var o: OmniLight3D = f["licht"]
		var ph: float = f["ph"]
		o.light_energy = (0.3 + 1.2 * nacht_k) * (0.85 + 0.1 * sin(zeit * 9.0 + ph) + 0.06 * sin(zeit * 23.0 + 1.3 + ph) + 0.05 * randf())

func nacht(k: float) -> void:
	nacht_k = k
	for p in staub:   # 990: Staub nur im Licht der Fenster, abends verblasst er mit dem Tageslicht (814 bekannt: leuchtete abends)
		if not is_instance_valid(p): continue
		p.amount_ratio = clampf(1.0 - k * 1.4, 0.0, 1.0)
		p.visible = p.amount_ratio > 0.02
	for pm in rauch_pm:
		pm.color = Color(0.92, 0.9, 0.88, 0.85).lerp(Color(0.42, 0.4, 0.39, 0.75), k)
	var brennt := k > 0.2   # abends und nachts; am Tag stecken die Fackeln kalt im Halter
	for f in fackeln:
		if f["brennt"] == brennt: continue
		f["brennt"] = brennt
		var fx: Node3D = f["fx"]
		fx.visible = brennt
		(f["licht"] as OmniLight3D).visible = brennt
		if brennt and fx.has_method("play"): fx.call("play")
