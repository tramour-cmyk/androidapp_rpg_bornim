class_name NetzMess
# 1711 (Sokrates 18.11., 22:13: „Messung meldet passt, Bild zeigt Fehler“ bei 1694 Faust, 760 Biss, 1535 Flanke): Messen am gezeichneten
# Netz statt an Knochen, Haltepunkten oder Kollisionsformen. Befund 1694: Knochen und halt.json meldeten 360° Umschlingung, das Netz
# zeigte 1 cm Spalt zur Handfläche. Regeln, die dabei nötig waren:
#  1. Außerhalb der Änderung liefert get_bone_global_pose die Pose OHNE Modifikatoren (Tragen, Atem, Blick …), bake ebenso:
#     gemessen wird im Signal skeleton_updated (Endpose nach allen Modifikatoren).
#  2. Die Ruhebewegung bewegt die Figur: Median über viele Bilder, nach dem Übergang (80 Bilder nach dem Anlegen).
#  3. Nur im Renderer des Projekts (Compatibility) mit Bildschirm (xvfb): ohne Fenster ist das Netz leer, unter Vulkan in Software
#     liefert bake je Bild ein anderes, teils leeres Netz.
# Nutzung: var nm := NetzMess.new(sk); nm.knochen_unter("hand_r"); sk.skeleton_updated.connect(func(): werte.append(nm.ecken()))

var sk: Skeleton3D
var nur := {}          # Knochenindex -> true: nur Ecken mit Hauptgewicht an diesen Knochen (leer = alle)

func _init(s: Skeleton3D) -> void:
	sk = s

## Knochen und alle Kinder (z. B. „hand_r“ = Hand mit Fingern)
func knochen_unter(name: String) -> void:
	var st := [sk.find_bone(name)]
	while not st.is_empty():
		var b: int = st.pop_back()
		if b < 0: continue
		nur[b] = true
		for c in sk.get_bone_children(b): st.append(c)

## Ecken (Welt) der sichtbaren, gehäuteten Netze unter dem Skelett, mit Hauptknochen: [[Vector3, Knochenindex], …]; im Signal
## skeleton_updated aufrufen
func ecken() -> Array:
	var aus := []
	for mi in sk.find_children("*", "MeshInstance3D", true, false):
		var m3 := mi as MeshInstance3D
		if m3.mesh == null or m3.skin == null or not m3.visible: continue
		var gebacken := m3.bake_mesh_from_current_skeleton_pose()
		if gebacken == null: continue
		var bind := {}
		for k in m3.skin.get_bind_count():
			var nm := m3.skin.get_bind_name(k)
			bind[k] = sk.find_bone(nm) if nm != "" else m3.skin.get_bind_bone(k)
		for su in mini(m3.mesh.get_surface_count(), gebacken.get_surface_count()):
			var roh := m3.mesh.surface_get_arrays(su)
			var pos = gebacken.surface_get_arrays(su)[Mesh.ARRAY_VERTEX]
			var kn = roh[Mesh.ARRAY_BONES]; var gw = roh[Mesh.ARRAY_WEIGHTS]
			if kn == null or gw == null or pos == null or pos.size() == 0: continue
			var je: int = kn.size() / pos.size()
			for vi in pos.size():
				var best := -1; var bw := 0.0
				for k in je:
					if gw[vi * je + k] > bw: bw = gw[vi * je + k]; best = int(kn[vi * je + k])
				var b: int = bind.get(best, -1)
				if not nur.is_empty() and not nur.has(b): continue
				aus.append([m3.global_transform * pos[vi], b])
	return aus

## Median je Schlüssel über eine Reihe von Dictionaries mit Zahlen
static func median(reihe: Array) -> Dictionary:
	var med := {}
	if reihe.is_empty(): return med
	for k in reihe[0]:
		var a := []
		for e in reihe: a.append(e[k])
		a.sort(); med[k] = a[a.size() / 2]
	return med
