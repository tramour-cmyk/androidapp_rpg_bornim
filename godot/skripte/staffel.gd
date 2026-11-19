class_name Staffel
extends RefCounted
# 458.3 Waffenstaffel (Chef 01.11., 19:5x: „Staffel nach Stufe, Seltenheit über Material und Zeichen“; 02.11., 11:28: Modelle und
# Staffel passen): je Waffenart 2-4 Formen aus den Kaufpaketen, gebaut von tools/blender348/waffen_staffel.py (SPIEL=1) nach
# daten/waffen/<art>_<form>.bin, Griff im Ursprung wie waffen.py. Welche Form ab welcher Stufe gilt, steht in daten/waffen/staffel.json
# (aus der Spalte formen des Katalogs); die Stufe ist die des Gegenstands (ilvl). Seltenheit: dasselbe Netz, je Klasse des Materials
# (metall, beschlag, holz, leder, akzent; Material „<klasse>.<n>“) eine toenung aus staffel.json; das Bild trägt nur die Zeichnung.
# Schlüssel eines Gegenstands: „<datei>#<SELTENHEIT>“ für eine Staffelform, sonst die Grundform (waffen.py, Vertexfarben) wie bisher.

const DATEI := "res://daten/waffen/staffel.json"
const WAFFE := "res://daten/waffen/%s.bin"

static var _d = null
static var _art := {}   # Datei der Form -> Waffenart

static func daten() -> Dictionary:
	if _d == null:
		_d = {}
		if FileAccess.file_exists(DATEI):
			var j = JSON.parse_string(FileAccess.get_file_as_string(DATEI))
			if j is Dictionary: _d = j
		for a in (_d.get("waffen", {}) as Dictionary):
			for f in _d["waffen"][a]: _art[String(f["datei"])] = String(a)
	return _d

## Schlüssel des Modells für einen Gegenstand ({base, ilvl, rarity}); leer, wenn es keins gibt
static func schluessel(g) -> String:
	if not g is Dictionary: return ""
	var b := String(g.get("base", ""))
	var formen: Array = daten().get("waffen", {}).get(b, [])
	var stufe := int(g.get("ilvl", 1))
	var wahl := ""
	for f in formen:
		if int(f["ab"]) <= stufe and FileAccess.file_exists(WAFFE % String(f["datei"])): wahl = String(f["datei"])
	if wahl == "" and not formen.is_empty() and FileAccess.file_exists(WAFFE % String(formen[0]["datei"])): wahl = String(formen[0]["datei"])
	if wahl != "": return wahl + "#" + String(g.get("rarity", "COMMON"))
	return b if FileAccess.file_exists(WAFFE % b) else ""

## Datei ohne Seltenheit
static func datei(schl: String) -> String: return schl.get_slice("#", 0)

## Waffenart (Grundform) eines Schlüssels: für Regeln, Gang, Katalog
static func art(schl: String) -> String:
	daten()
	var d := datei(schl)
	return String(_art.get(d, d))

static func seltenheit(schl: String) -> String: return schl.get_slice("#", 1) if schl.contains("#") else ""

## Modell laden (wie Gebiet.lade_glb); Staffelformen tragen die Seltenheit als Marke, Gebiet.male färbt danach (faerbe)
static func lade(schl: String) -> Node3D:
	var d := Gebiet.lade_glb(WAFFE % datei(schl))
	if d != null and seltenheit(schl) != "": d.set_meta("staffel", seltenheit(schl))
	return d

## toenung je Klasse nach der Seltenheit (linear, staffel.json); nach Gebiet.male, das die Shader-Materialien anlegt
static func faerbe(n: Node) -> void:
	var t: Dictionary = daten().get("toenung", {}).get(String(n.get_meta("staffel", "COMMON")), {})
	if t.is_empty(): return
	for mi in n.find_children("*", "MeshInstance3D", true, false) + ([n] if n is MeshInstance3D else []):
		var me := (mi as MeshInstance3D).mesh
		if me == null: continue
		for i in me.get_surface_count():
			var src := me.surface_get_material(i)
			var kl := String(src.resource_name).get_slice(".", 0) if src else ""
			var sm := (mi as MeshInstance3D).get_surface_override_material(i) as ShaderMaterial
			if sm and t.has(kl):
				var c: Array = t[kl]
				sm.set_shader_parameter("toenung", Vector3(float(c[0]), float(c[1]), float(c[2])))
