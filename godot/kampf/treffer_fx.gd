class_name TrefferFx
extends RefCounted
# 623.2 (623 E; 623.8 A, Chef 09.11., 22:23: Szene 2 Wolfskampf): die Effekte im Kampf stehen als Feld `fx` in werte.json (je
# Effekt Pfad und Dämpfung, dazu wer ihn wann zeigt: Anlass, Waffengruppe, Zauber, Zustand, Monster; Zuordnung LISTE-EFFEKTE.md),
# nicht verstreut im Code. Szene 2: Klingenspur beim Hieb (R3 steel_slash), Blut am Getroffenen (R4 blood_hit), kritischer Treffer
# (R7 critical_hit), Parade mit dem Schild (R7 parry_block), Luftzug beim Ausweichen (R3 dash_wind), Staub beim Aufprall des
# Sprungs (R7 dust_impact). Farben gedämpft (kein Leuchtbunt, Gold nur wo Licht ist), ohne die Punktlichter der Pakete (am Handy
# je Licht teuer), alles nur ab Grafikstufe Mittel (698, Grafik.kits). Die Pakete liegen nur im Bau (godot.yml, Lizenz: nie ins
# Repo); fehlt eines, zeigt der Kampf wie bisher nichts dafür.

const SPUR_SKRIPT := "res://addons/reeboo_trails/trail_3d.gd"

## Schalter (Testmenü, Vergleich alt gegen neu im Film: FX_AUS=1)
static var an := true
static var _szenen := {}       # Name -> PackedScene oder false
static var _stile := {}        # Name -> TrailStyle (gedämpft) oder false
static var _gedaempft := {}    # "<Name>|<Ressource-ID>" -> gedämpfte Kopie (je Effekt einmal, dann geteilt)
## für Tests und Meldungen: je Name, wie oft gezeigt
static var gezeigt := {}


static func tabelle() -> Dictionary:
	return Brs.lade().get("fx", {})


static func eintrag(name: String) -> Dictionary:
	return (tabelle().get("effekte", {}) as Dictionary).get(name, {})


## Name des Effekts für [anlass] (treffer, kritisch, parade, ausweichen), "" ohne
static func fuer_anlass(anlass: String) -> String:
	return String((tabelle().get("anlass", {}) as Dictionary).get(anlass, ""))


## Name des Effekts der Waffengruppe [gruppe] für [anlass] (hieb, treffer, geschoss), "" ohne
static func fuer_waffe(gruppe: String, anlass: String) -> String:
	return String(((tabelle().get("waffengruppe", {}) as Dictionary).get(gruppe, {}) as Dictionary).get(anlass, ""))


static func fuer_monster(id: String, anlass: String) -> String:
	return String(((tabelle().get("monster", {}) as Dictionary).get(id, {}) as Dictionary).get(anlass, ""))


static func fuer_zauber(art: String) -> String:
	return String((tabelle().get("zauber", {}) as Dictionary).get(art, ""))


static func fuer_zustand(st: String) -> String:
	return String((tabelle().get("zustand", {}) as Dictionary).get(st, ""))


## die Pfade des Effekts [name] (einer oder mehrere, der erste vorhandene gilt)
static func pfade(name: String) -> Array:
	var p = eintrag(name).get("pfad", [])
	return p if p is Array else [p]


static func pfad(name: String) -> String:
	var p := pfade(name)
	return String(p[0]) if not p.is_empty() else ""


## Effekte im Spiel: Schalter an und Grafikstufe ab Mittel (698: Niedrig ohne Kits)
static func aktiv() -> bool:
	return an and OS.get_environment("FX_AUS") == "" and Grafik.kits()


## die Szene des Effekts [name] wie geliefert, null ohne Paket (einmal geladen)
static func szene(name: String):
	if not _szenen.has(name):
		_szenen[name] = false
		for p in pfade(name):
			if ResourceLoader.exists(String(p)):
				var r = load(String(p))
				if r is PackedScene:
					_szenen[name] = r
					break
	return _szenen[name] if _szenen[name] is PackedScene else null


## der Stil der Spur [name] (R3), gedämpft nach farbe und energie, null ohne Paket
static func stil(name: String):
	if not _stile.has(name):
		_stile[name] = false
		var e := eintrag(name)
		var p := pfad(name)
		if p != "" and ResourceLoader.exists(p) and ResourceLoader.exists(SPUR_SKRIPT):
			var st = load(p)
			if st != null:
				st = st.duplicate(true)
				var f: Array = e.get("farbe", [])
				if f.size() == 4:
					var c := Color(float(f[0]), float(f[1]), float(f[2]), float(f[3]))
					if "color_ramp" in st and st.color_ramp is Gradient:
						var g := st.color_ramp as Gradient
						for i in g.get_point_count():
							g.set_color(i, Color(c.r, c.g, c.b, g.get_color(i).a * c.a))
					if "core_color" in st:
						st.core_color = c
				if e.has("energie") and "energy" in st:
					st.energy = float(e.energie)
				_stile[name] = st
	return _stile[name] if not (_stile[name] is bool) else null


## zeigt den Effekt [name] einmal bei [at] (lokal in [eltern]), [hoehe] = Körperhöhe des Betroffenen (m), [blick] = Richtung,
## in die er zeigt (weg vom Schlagenden); gibt den Knoten zurück, null ohne Paket oder aus
static func zeige(name: String, eltern: Node3D, at: Vector3, hoehe := 1.8, blick := Vector3.ZERO) -> Node3D:
	if name == "" or eltern == null or not aktiv():
		return null
	var sz = szene(name)
	if sz == null:
		return null
	var e := eintrag(name)
	var fx: Node = (sz as PackedScene).instantiate()
	_daempfe(name, fx, e)
	eltern.add_child(fx)
	if not fx is Node3D:
		fx.queue_free()
		return null
	var n := fx as Node3D
	n.position = at
	if blick.length() > 0.01:
		var z := -blick.normalized()
		var x := Vector3.UP.cross(z)
		if x.length() > 0.01:
			n.basis = Basis(x.normalized(), z.cross(x.normalized()), z)
	n.scale = Vector3.ONE * float(e.get("groesse", 1.0)) * clampf(hoehe / 1.8, 0.5, 2.0)
	if fx.has_method("play"):
		fx.call("play")
	gezeigt[name] = int(gezeigt.get(name, 0)) + 1
	var w: WeakRef = weakref(fx)     # das Paket gibt seine Effekte selbst frei (auto_free); sonst nach 3 s
	eltern.get_tree().create_timer(3.0).timeout.connect(func(): if w.get_ref() != null: w.get_ref().queue_free())
	return n


## hängt die Spur [name] (R3) an [an_knoten]: als Klinge zwischen [base] und [tip] (lokal), sonst als Band hinter dem Knoten;
## sie zeichnet ab [ab_s] für [dauer_s] und läuft dann aus. Die Spur selbst liegt in [welt] (Kampfort) und folgt dem Knoten über
## ein RemoteTransform3D: ihr Netz liegt in Weltlage und darf nicht in den Umriss der Figur oder ihrer Waffe zählen (Kamera,
## Lebensbalken, Abstände). null ohne Paket oder aus
static func spur(name: String, welt: Node3D, an_knoten: Node3D, ab_s: float, dauer_s: float, base := Vector3.INF, tip := Vector3.INF) -> Node3D:
	if name == "" or an_knoten == null or welt == null or not aktiv():
		return null
	var st = stil(name)
	if st == null:
		return null
	var tr = load(SPUR_SKRIPT).new()
	tr.style = st
	tr.emitting = false
	var e := eintrag(name)
	if "width_scale" in tr:
		tr.width_scale = float(e.get("breite", 1.0))
	if base != Vector3.INF and tip != Vector3.INF:
		tr.mode = 1     # Trail3D.Mode.BLADE
		tr.blade_base = base
		tr.blade_tip = tip
	welt.add_child(tr)
	tr.global_transform = an_knoten.global_transform
	var folge := RemoteTransform3D.new()
	folge.name = "Spur623"
	an_knoten.add_child(folge)
	folge.remote_path = folge.get_path_to(tr)
	gezeigt[name] = int(gezeigt.get(name, 0)) + 1
	var baum := an_knoten.get_tree()
	var w: WeakRef = weakref(tr)
	var wf: WeakRef = weakref(folge)
	baum.create_timer(maxf(ab_s, 0.0)).timeout.connect(func():
		if w.get_ref() != null:
			w.get_ref().clear()
			w.get_ref().emitting = true)
	baum.create_timer(maxf(ab_s, 0.0) + dauer_s).timeout.connect(func():
		if w.get_ref() != null:
			w.get_ref().emitting = false
		if wf.get_ref() != null:
			wf.get_ref().queue_free())
	baum.create_timer(maxf(ab_s, 0.0) + dauer_s + 1.5).timeout.connect(func(): if w.get_ref() != null: w.get_ref().queue_free())
	return tr


## Klinge der Waffe [waffe] (lokal): vom Griff zur Spitze längs der längsten Achse ihrer Netze, die Spitze am weitesten vom
## Ursprung (der Griff sitzt am Ursprung der Waffe); [] ohne Netz
static func klinge(waffe: Node3D) -> Array:
	var box := AABB()
	var erst := true
	var inv := waffe.global_transform.affine_inverse()
	for m in waffe.find_children("*", "MeshInstance3D", true, false):
		if (m as MeshInstance3D).top_level:     # eine Spur von vorhin
			continue
		var bb: AABB = (m as MeshInstance3D).get_aabb()
		for i in 8:
			var q: Vector3 = inv * ((m as MeshInstance3D).global_transform * bb.get_endpoint(i))
			if erst:
				box = AABB(q, Vector3.ZERO)
				erst = false
			else:
				box = box.expand(q)
	if erst:
		return []
	var ax := box.get_longest_axis_index()
	var lo := box.position[ax]
	var hi := box.end[ax]
	var mitte := box.get_center()
	var a := mitte
	var b := mitte
	# die Spitze ist das Ende fern vom Griff (Ursprung); die Spur deckt die oberen zwei Drittel der Waffe
	var spitze := hi if absf(hi) >= absf(lo) else lo
	var griff := lo if spitze == hi else hi
	a[ax] = lerpf(griff, spitze, 0.35)
	b[ax] = spitze
	return [a, b]


## gedämpft nach der Tabelle: Lichter und Knoten weg, Farben Richtung ton, Leuchten herunter (je Ressource einmal, dann geteilt)
static func _daempfe(name: String, fx: Node, e: Dictionary) -> void:
	var weg: Array = e.get("weg", [])
	for n in fx.find_children("*", "", true, false):
		if (n is Light3D and not bool(e.get("lichter", true))) or String(n.name) in weg:
			n.get_parent().remove_child(n)
			n.free()
	var glanz := float(e.get("glanz", 1.0))
	var grau := float(e.get("grau", 0.0))
	var hell := float(e.get("hell", 1.0))
	if glanz == 1.0 and grau == 0.0 and hell == 1.0:
		return
	var t: Array = e.get("ton", [0.6, 0.55, 0.48])
	var ton := Color(float(t[0]), float(t[1]), float(t[2]))
	for p in fx.find_children("*", "GPUParticles3D", true, false):
		var gp := p as GPUParticles3D
		if gp.process_material is ParticleProcessMaterial:
			gp.process_material = _kopie(name, gp.process_material, func(r):
				var pm := r as ParticleProcessMaterial
				pm.color = _ton(pm.color, ton, grau, hell)
				if pm.color_ramp is GradientTexture1D and (pm.color_ramp as GradientTexture1D).gradient != null:
					var gt := (pm.color_ramp as GradientTexture1D).duplicate() as GradientTexture1D
					var g := gt.gradient.duplicate() as Gradient
					for i in g.get_point_count():
						g.set_color(i, _ton(g.get_color(i), ton, grau, hell))
					gt.gradient = g
					pm.color_ramp = gt)
		if gp.material_override != null:
			gp.material_override = _kopie(name, gp.material_override, func(r): _mat_daempfen(r, ton, grau, hell, glanz))


static func _kopie(name: String, r: Resource, aendern: Callable) -> Resource:
	var key := "%s|%d" % [name, r.get_instance_id()]
	if not _gedaempft.has(key):
		var k := r.duplicate()
		aendern.call(k)
		_gedaempft[key] = k
	return _gedaempft[key]


static func _mat_daempfen(m, ton: Color, grau: float, hell: float, glanz: float) -> void:
	if m is ShaderMaterial:
		var sm := m as ShaderMaterial
		var en = sm.get_shader_parameter("emission_energy")
		if en != null:
			sm.set_shader_parameter("emission_energy", float(en) * glanz)
		for nm in ["color", "core_color", "edge_color", "glint_color"]:
			var c = sm.get_shader_parameter(nm)
			if c is Color:
				sm.set_shader_parameter(nm, _ton(c, ton, grau, hell))
	elif m is StandardMaterial3D:
		var st := m as StandardMaterial3D
		st.albedo_color = _ton(st.albedo_color, ton, grau, hell)
		st.emission_energy_multiplier *= glanz


## Farbe [c] um [grau] Richtung [ton] (bei gleicher Helligkeit), mal [hell]; Deckung bleibt
static func _ton(c: Color, ton: Color, grau: float, hell: float) -> Color:
	var l := c.r * 0.299 + c.g * 0.587 + c.b * 0.114
	var tl := maxf(ton.r * 0.299 + ton.g * 0.587 + ton.b * 0.114, 0.001)
	var z := Color(ton.r * l / tl, ton.g * l / tl, ton.b * l / tl)
	var m := c.lerp(z, grau)
	return Color(m.r * hell, m.g * hell, m.b * hell, c.a)
