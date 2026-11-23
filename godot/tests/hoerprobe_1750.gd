extends SceneTree
# 1750 Hörprobe (D3a, Chef 20.11., 14:11): Wald am Fluss mit Lagerfeuer, am Tag; 10 s Karte, Kampfbeginn (Blende, Kampfmusik), 15 s
# Kampf, Kampfende (Sieg), 10 s danach. Ton aus dem echten Mischer (klang.gd), aufgenommen mit dem Movie Maker; je Sekunde die
# Pegel der Schleifen und jeder gestartete Einzellaut als Zeile „HOER“.
# Aufruf im Ordner godot: xvfb-run … ~/godot/godot --path . --rendering-driver vulkan --resolution 320x240 --write-movie probe.avi
#   --fixed-fps 30 -s res://tests/hoerprobe_1750.gd

const KlangS = preload("res://klang/klang.gd")

var k
var sp: Node3D
var t := 0.0
var lage := ""
var karte
var gemeldet := {}


class _Probekarte:
	var kacheln := {".": {"name": "GRASS"}, "~": {"name": "WATER"}, "c": {"name": "CAMPFIRE"}}
	var daten := {"art": "FOREST"}
	var breite := 12
	var hoehe := 5
	var zeilen := ["~...........", "~...........", "~..c........", "~...........", "~..........."]
	var id := "forest"

	func zeichen(q: Vector2i) -> String:
		return String(zeilen[q.y][q.x])

	func pos_kachel(p: Vector3) -> Vector2i:
		return Vector2i(clampi(floori(p.x / 1.16), 0, breite - 1), clampi(floori(p.z / 1.16), 0, hoehe - 1))


func _initialize() -> void:
	_los.call_deferred()


func _los() -> void:
	k = root.get_node_or_null("Klang")
	if k == null:
		k = KlangS.new()
		root.add_child(k)
	k._zufall.seed = 1750
	sp = Node3D.new()
	var s := GDScript.new()
	s.source_code = "extends Node3D\nvar licht\n"
	s.reload()
	sp.set_script(s)
	var lk := Node.new()
	var ls := GDScript.new()
	ls.source_code = "extends Node\nvar nacht := 0.0\n"
	ls.reload()
	lk.set_script(ls)
	sp.set("licht", lk)
	var held := Node3D.new()
	sp.add_child(held)
	root.add_child(sp)
	held.position = Vector3(2.5 * 1.16, 0, 2.5 * 1.16)     # Kachel (2, 2): Feuer 1 Kachel, Fluss 2 Kacheln
	karte = _Probekarte.new()
	k.ort(karte, held)
	k._leben_ms = 4000.0     # ein Vogel in den 10 s Karte
	lage = "Karte"
	print("HOER 0.0 Karte: Wald am Fluss, Lagerfeuer 1 Kachel, Fluss 2 Kacheln, am Tag")
	await create_timer(10.0).timeout
	lage = "Kampf"
	print("HOER %.1f Kampfbeginn" % t)
	k.verhuelle(true)     # spiel.gd _kampf_lauf: unter der Blende schweigt alles
	k.spiele_szene("BATTLE")
	await create_timer(0.8).timeout
	sp.visible = false     # die Welt ruht unsichtbar
	k.verhuelle(false)
	k._leben_ms = k._ort_ms + 3000.0     # ein Vogel wäre fällig: er schweigt
	await create_timer(14.2).timeout
	lage = "nach Kampf"
	print("HOER %.1f Kampfende (Sieg)" % t)
	sp.visible = true
	k.nach_kampf(true, karte)
	await create_timer(10.0).timeout
	print("HOER %.1f Ende" % t)
	quit(0)


func _process(dt: float) -> bool:
	t += dt
	if k == null:
		return false
	var sek := int(t)
	if not gemeldet.has(sek) and lage != "":
		gemeldet[sek] = true
		var l := []
		for s in ["bett", "feuer", "fluss"]:
			l.append("%s %.3f" % [s, float(k._schleifen[s].v) * k.schleier_pegel() if k._schleifen.has(s) else 0.0])
		var m := []
		for p in k._spieler:
			if p.playing:
				m.append("%s %.2f" % [String(p.stream.resource_path).get_file().get_basename(), db_to_linear(p.volume_db)])
		print("HOER %d s %s: %s; Musik %s" % [sek, lage, ", ".join(l), ", ".join(m) if not m.is_empty() else "still"])
	for p in k._effekte:
		if p.playing and p.get_playback_position() < dt + 0.001:
			print("HOER %.1f Laut %s %.3f" % [t, String(p.stream.resource_path).get_file().get_basename(), db_to_linear(p.volume_db)])
	return false
