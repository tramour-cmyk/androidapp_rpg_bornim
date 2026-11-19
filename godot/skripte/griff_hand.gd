class_name GriffHand
extends SkeletonModifier3D
# 1694 (Auftrag 19.11.: „Jede Figur des Spiels hält jeden Gegenstand sichtbar richtig“): der Griff (skripte/griff.gd) für Gegenstände,
# die an einem Handknochen hängen (BoneAttachment3D: Halt.anlegen, Kampf, Leute). Je Bild nach der Bewegung: Gegenstand an die Stelle
# in der Faust (stellen) oder, wo ein anderer ihn führt (Leute: Stab am Boden), nur die Finger um ihn. Held unterwegs: tragen.gd.

var seite := "r"
var ding: Node3D
var halt := {}
var griffart := "einhand"
var stellen := true
var lage := Transform3D()      # Lage des Gegenstands im Raum seines Halters, wie angelegt
var merk := {}

## hängt den Griff an das Skelett; null ohne Hand mit Fingern (Goblin, Kobold: Faust im Netz) oder ohne Halter am Handknochen
static func an(sk: Skeleton3D, d: Node3D, s: String, h := {}, art := "einhand", st := true) -> GriffHand:
	if sk == null or d == null or not Griff.hat_hand(sk, s): return null
	var ba := d.get_parent() as BoneAttachment3D
	if ba == null or sk.find_bone(ba.bone_name) != sk.find_bone("hand_" + s): return null
	for alt in sk.get_children():
		if alt is GriffHand and (alt as GriffHand).seite == s: alt.free()
	var g := GriffHand.new()
	g.name = "Griff_" + s
	g.seite = s; g.ding = d; g.halt = h; g.griffart = art; g.stellen = st
	g.lage = d.transform
	sk.add_child(g)
	return g

## Griffart je Gegenstand: Zweihänder (Tragen.GANG_ZWEI), Stab, sonst einhändig
static func art_von(id: String) -> String:
	var b := Staffel.art(id) if id.contains("_") or id.contains("#") else id
	if b in Tragen.GANG_ZWEI: return "zweihand"
	if Tragen.art_von(b) == "stab": return "stab"
	return "einhand"

func _process_modification() -> void:
	var sk := get_skeleton()
	if sk == null or ding == null or not is_instance_valid(ding): return
	var ba := ding.get_parent() as BoneAttachment3D
	if ba == null: return
	var kn := sk.find_bone(ba.bone_name)
	if kn < 0: return
	# Lage im Skelettraum nach der Pose dieses Bilds (der Halter folgt dem Knochen erst nach der Änderung)
	var P := sk.get_bone_global_pose(kn)
	var m := halt if not halt.is_empty() else {"griff": Vector3.ZERO, "achse": Vector3.UP, "vorn": Vector3.RIGHT}
	var B := P * (lage if stellen else ding.transform)
	var e := Griff.am_schaft(sk, seite, B * Halt.griff_rahmen(m), Griff.schaft(ding, halt), griffart if stellen else "stab", stellen)
	if not e["haelt"]:
		if stellen: ding.transform = lage
		return
	if stellen:
		var lokal := P.basis.inverse() * (e["verschieben"] as Vector3)
		ding.transform = Transform3D(lage.basis, lage.origin + lokal)
	Griff.schliessen(sk, seite, e["o"], e["d"], e["r"], merk, e["form"])
