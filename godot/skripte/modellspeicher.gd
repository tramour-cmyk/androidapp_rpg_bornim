class_name ModellSpeicher
## 1270.2 (1270 A, Chef 15.11., 10:51): Figuren, Waffen und der Kampfort-Wald wurden in jedem Kampf neu gelesen, entschlüsselt
## (gekaufte Modelle, 348.12i) und aus dem glTF gebaut (figur.gd _load_model, _hold; kampfort.gd _build_forest; HeldFigur.baue).
## Jetzt einmal je Spielstart: die gebaute Szene bleibt als Vorlage im Speicher, jeder Aufruf bekommt eine Kopie davon.
## Netze, Häute und Bilder teilen sich die Kopien (gleiche Gegner kosten keinen Grafikspeicher mehr je Stück); Stoffe setzen die
## Aufrufer ohnehin je Figur (surface_override: figur.gd _paint, Gebiet.male). Die Bewegungen bekommt jede Kopie eigen, weil Figuren
## sie umbauen (figur.gd _ohne_atem, Angriff_Gehen; HeldFigur.bewegungen). Wer ein Netz oder Bild selbst ändern will, lädt mit lade_neu.
## MODELLSPEICHER=0 schaltet ab (Vergleich der Ladezeit, 1270.1).

const GRENZE := 48     # Vorlagen höchstens; die am längsten unbenutzte geht zuerst
static var _vorlagen := {}     # Schlüssel (Pfad|Spuren) -> Node3D außerhalb des Baums
static var _folge: Array[String] = []
static var gebaut := 0     # Messung (tests/modellspeicher_1270.gd)
static var kopiert := 0


## Kopie des Modells aus [p] (glTF-Binärdatei, verschlüsselt oder nicht); null, wenn es fehlt oder nicht lesbar ist.
## [spuren_kuerzen] wie GLTFDocument.generate_scene remove_immutable_tracks (figur.gd _load_model braucht false, Runde 15).
static func kopie(p: String, spuren_kuerzen := true) -> Node3D:
	if OS.get_environment("MODELLSPEICHER") == "0":
		return lade_neu(p, spuren_kuerzen)
	var k := "%s|%s" % [p, spuren_kuerzen]
	if not _vorlagen.has(k):
		var v := lade_neu(p, spuren_kuerzen)
		if v == null:
			return null
		_vorlagen[k] = v
		while _folge.size() >= GRENZE:
			var alt: String = _folge.pop_front()
			(_vorlagen[alt] as Node).free()
			_vorlagen.erase(alt)
	_folge.erase(k)
	_folge.append(k)
	kopiert += 1
	return _eigen(_vorlagen[k].duplicate() as Node3D)


## wie bisher: lesen, entschlüsseln, bauen (jedes Mal neu, nichts geteilt)
static func lade_neu(p: String, spuren_kuerzen := true) -> Node3D:
	if not FileAccess.file_exists(p):
		return null
	var doc := GLTFDocument.new()
	var st := GLTFState.new()
	if doc.append_from_buffer(Gebiet.entschluessele(FileAccess.get_file_as_bytes(p), p), "", st) != OK:
		push_error("glTF %s nicht lesbar" % p)
		return null
	gebaut += 1
	return doc.generate_scene(st, 30.0, false, spuren_kuerzen) as Node3D


## jede Kopie mit eigenen Bewegungen (Animation je Figur kopiert, Bibliothek neu)
static func _eigen(n: Node3D) -> Node3D:
	for ap: AnimationPlayer in n.find_children("*", "AnimationPlayer", true, false):
		for ln in ap.get_animation_library_list():
			var alt := ap.get_animation_library(ln)
			var neu := AnimationLibrary.new()
			for a in alt.get_animation_list():
				neu.add_animation(a, alt.get_animation(a).duplicate())
			ap.remove_animation_library(ln)
			ap.add_animation_library(ln, neu)
	return n


## alle Vorlagen weg (Tests; Speicher knapp)
static func leeren() -> void:
	for k in _vorlagen:
		(_vorlagen[k] as Node).free()
	_vorlagen.clear()
	_folge.clear()
