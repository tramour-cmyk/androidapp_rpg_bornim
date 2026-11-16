extends SceneTree
# 1304 (Chef 15.11., 17:13, Bild Ausrüstungsseite Build 288): „der Stab, den er in der Hand hält, der ständig rauf runter zuckt …
# so 10, 15 cm“. Held mit Kampfstab in der Haupthand und Fackel in der Nebenhand im Drehteller der Ausrüstung. Gemessen über eine
# ganze Drehung (6 s, 30 Bilder je Sekunde): Höhe des Stabfusses über dem Boden und Sprung des Stabs von Bild zu Bild, im Massstab
# der Figur in Metern. Soll: der Stab steht, Fuss höchstens 1 cm über dem Boden, kein Sprung über 2 cm. Ohne Bild, braucht die
# Kaufmodelle (daten/held.bin, daten/waffen/quarterstaff.bin). Maßgeblich ist die Zeile STABTELLER1304.

const HOCH_M := 0.01
const SPRUNG_M := 0.02

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	if not FileAccess.file_exists("res://daten/waffen/quarterstaff.bin"):
		print("übersprungen: ohne Kaufmodelle")
		print("STABTELLER1304 0 Fehler (übersprungen)")
		quit(0)
		return
	Sprache.lade()
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Klosterschüler", z.neue_uid)
	var w := HeldFigur.wahl(hw, z)
	w["ausruestung"] = (w["ausruestung"] as Dictionary).duplicate(true)
	w["ausruestung"]["MAIN_HAND"] = {"base": "quarterstaff"}
	w["ausruestung"]["OFF_HAND"] = {"base": "torch"}
	var dt := Drehteller.new(w, 1.1)
	dt.size = Vector2(400, 600)
	root.add_child(dt)
	for i in 40: await process_frame   # Anfangslage: der Stab setzt nach dem Einhängen einmal an (Pose kommt erst mit dem ersten Bild)
	var modell: Node3D = dt.teller.get_child(0) if dt.teller and dt.teller.get_child_count() > 0 else null
	var sk := Gebiet.finde(modell, "Skeleton3D") as Skeleton3D if modell else null
	var tr: Tragen = null
	if sk:
		for t in sk.get_children():
			if t is Tragen and (t as Tragen).waffe != null: tr = t
	pruefe(tr != null and tr.art == "stab", "Kampfstab in der Hand (Art %s)" % (tr.art if tr else "–"))
	if tr == null:
		print("STABTELLER1304 %d Fehler" % fehler); quit(1); return
	var ms := modell.global_basis.get_scale().y
	var hoch := 0.0; var sprung := 0.0; var vorher := Vector3.INF; var setzt := 0
	var t_vorher := tr.stab_t
	for i in 180:
		await physics_frame
		await process_frame
		var boden := modell.global_position.y
		if tr.stab_fuss != Vector3.INF: hoch = maxf(hoch, (tr.stab_fuss.y - boden) / ms)
		var p := tr.waffe.global_position
		# Sprung gegen die Drehung bereinigt: Abstand zur Achse und Höhe, nicht die Bahn im Kreis
		var q := Vector3(Vector2(p.x, p.z).length(), p.y, 0)
		if vorher != Vector3.INF: sprung = maxf(sprung, q.distance_to(vorher) / ms)
		vorher = q
		if tr.stab_t < t_vorher: setzt += 1
		t_vorher = tr.stab_t
	print("Drehung 6 s: Fuss bis %.1f cm über dem Boden, grösster Sprung %.1f cm, %d mal neu gesetzt" % [hoch * 100, sprung * 100, setzt])
	pruefe(hoch <= HOCH_M, "Fuss %.1f cm über dem Boden (höchstens %.0f)" % [hoch * 100, HOCH_M * 100])
	pruefe(sprung <= SPRUNG_M, "Stab springt %.1f cm von Bild zu Bild (höchstens %.0f)" % [sprung * 100, SPRUNG_M * 100])
	pruefe(setzt == 0, "im Stehen %d mal neu gesetzt (soll 0)" % setzt)
	print("STABTELLER1304 %d Fehler" % fehler)
	quit(1 if fehler else 0)
