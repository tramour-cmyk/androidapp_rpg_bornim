class_name TrachtProbe
extends RefCounted
# 376.1 Tracht je Herkunft, Heldin, Statur (Chef 01.11., 11:19 „376.1 wie Sokrates“, Archiv: Mann und Frau gleich; Kettenhemd und lange
# Robe an den Frauenkoerper angepasst, „eine Runde mit Film“; langes Haar unter Helm und Kapuze verborgen): der Held wie im Spiel
# (HeldFigur.baue: Toon-Licht, Tusche nach Licht, Schatten, Wiese) je Tracht der Herkuenfte, Mann und Frau, dazu die drei Staturen und
# die Bewegung (Gehen, Rennen), langsam drehend. Titel und Namen setzt tracht_film.py dazu. Wie voelkerprobe.gd (431).
# Am Rechner: godot --path godot --resolution 1080x720 -- --figuren=<ausgabe> --teil=trachten
#   <ausgabe>/trachten/<streifen>/<nnnn>.png, <ausgabe>/trachten/lage.json (Bildmitte und Name jeder Figur je Streifen)
const FPS := 30.0
const ABSTAND := 1.0       # m zwischen den Figuren eines Streifens
const BREITE := 3.3        # m Bildbreite (Kamera.zoom), 3 Figuren
const MITTE_Y := 0.1
# je Seite drei Streifen zu drei Figuren: [Herkunft, Geschlecht, Statur, Bewegung]
# 376.1 Urteil Tracht (Chef 01.11., 20:2x: Tracht passt; Umhang des Wachsoldaten mit Farbstreifen, Robe des Zauberlehrlings mit Knie
# und Flecken): zweite Runde nur Umhang und Robe, je oben Mann, Mitte Frau (Schlank, Normal, Kraeftig), unten Gehen. Ohne Rennen: das
# Rennen A (416.4) kommt mit dem Grundstand 461; die Uebersicht aller Trachten in Git (Lauf 41311736346)
const SEITEN := {
	"umhang": [
		[["WACHSOLDAT", "m", "schlank", "Stehen"], ["WACHSOLDAT", "m", "normal", "Stehen"], ["WACHSOLDAT", "m", "kraeftig", "Stehen"]],
		[["WACHSOLDAT", "w", "schlank", "Stehen"], ["WACHSOLDAT", "w", "normal", "Stehen"], ["WACHSOLDAT", "w", "kraeftig", "Stehen"]],
		[["WACHSOLDAT", "m", "normal", "Gehen"], ["WACHSOLDAT", "w", "normal", "Gehen"], ["WACHSOLDAT", "m", "kraeftig", "Gehen"]],
	],
	"robe": [
		[["ZAUBERLEHRLING", "m", "schlank", "Stehen"], ["ZAUBERLEHRLING", "m", "normal", "Stehen"], ["ZAUBERLEHRLING", "m", "kraeftig", "Stehen"]],
		[["ZAUBERLEHRLING", "w", "schlank", "Stehen"], ["ZAUBERLEHRLING", "w", "normal", "Stehen"], ["ZAUBERLEHRLING", "w", "kraeftig", "Stehen"]],
		[["ZAUBERLEHRLING", "m", "normal", "Gehen"], ["ZAUBERLEHRLING", "w", "normal", "Gehen"], ["ZAUBERLEHRLING", "m", "kraeftig", "Gehen"]],
	],
}
const DAUER := {"umhang": 12.0, "robe": 12.0}
# Kopf je Herkunft: der Beispielkopf der Klasse, zu der sie gehoert (HeldFigur.KLASSEN_VORGABE); die Heldin mit langem Haar (zeigt,
# dass es unter der Kapuze verschwindet)
const KLASSE := {"WACHSOLDAT": "FIGHTER", "ZAUBERLEHRLING": "WIZARD", "KLOSTERSCHUELER": "CLERIC", "HERUMTREIBER": "ROGUE", "JAEGERKIND": "ROGUE"}

var fp: FigurenProbe
var streifen := {}         # Name -> [Marker, [Figuren], [Eintraege]]
var lage := {}

func _init(p: FigurenProbe) -> void: fp = p

func film() -> void:
	if HeldFigur.lade_info().get("herkuenfte", {}).is_empty():
		fp.protokoll.append("FEHLT held-klassen.json mit herkuenfte (held_klassen.py)")
		return
	fp.freie_wiese()
	fp.spiel.held.visible = false
	var ort: Vector3 = fp.spiel.karte.kachel_pos(FigurenProbe.FILM_ORT)
	var x := -12.0
	for seite in SEITEN:
		var reihen: Array = SEITEN[seite]
		for i in reihen.size():
			_streifen("%s_%d" % [seite, i + 1], reihen[i], ort + Vector3(x, 0, 0))
			x += 4.5
	await fp.get_tree().create_timer(1.0).timeout
	for seite in SEITEN:
		var namen := []
		for i in (SEITEN[seite] as Array).size(): namen.append("%s_%d" % [seite, i + 1])
		await _laufen(namen, float(DAUER[seite]))
	FileAccess.open(fp.aus + "/trachten/lage.json", FileAccess.WRITE).store_string(JSON.stringify(lage, " "))


func _streifen(name: String, figuren: Array, x0: Vector3) -> void:
	var marker := Node3D.new()
	fp.spiel.add_child(marker)
	marker.position = x0 + Vector3((figuren.size() - 1) * ABSTAND / 2.0, MITTE_Y, 0)
	var figs := []
	var eintraege := []
	for i in figuren.size():
		var e: Array = figuren[i]
		var h := String(e[0]); var g := String(e[1]); var st := String(e[2]); var bew := String(e[3])
		var k := String(KLASSE.get(h, "FIGHTER"))
		var a := HeldFigur.vorgabe(k, g)
		if g == "w": a["frisur"] = "Hair_Long"
		a["statur"] = st
		var mats := []
		var m := HeldFigur.baue({"klasse": k, "herkunft": h, "volk": "HUMAN", "aussehen": a, "ausruestung": {}}, mats)
		if m == null: fp.protokoll.append("FEHLT %s %s" % [h, g]); continue
		for mt in mats: (mt as ShaderMaterial).set_shader_parameter("fill", 0.42)   # wie klasse_figur (Held)
		var w := Node3D.new()
		fp.spiel.add_child(w)
		w.position = x0 + Vector3(i * ABSTAND, 0, 0)
		w.add_child(m)
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		ap.play(bew)
		figs.append(w)
		eintraege.append({"herkunft": h, "geschlecht": g, "statur": st, "bewegung": bew, "modell": String(m.get_meta("tracht"))})
		fp.protokoll.append("TRACHT %s %s %s %s: %s" % [h, g, st, bew, m.get_meta("tracht")])
	streifen[name] = [marker, figs, eintraege]


func _kamera(marker: Node3D) -> void:
	var kam := fp.spiel.kamera as Kamera
	kam.ziel = marker
	kam.nah = true
	kam.gieren_ziel = 0.0
	kam.neigung = -6.0
	kam.zoom = BREITE
	kam.springe()


func _laufen(namen: Array, sek: float) -> void:
	var n := int(round(sek * FPS))
	for t in namen: DirAccess.make_dir_recursive_absolute(fp.aus + "/trachten/" + String(t))
	for i in n:
		var zeit := i / FPS
		for t in namen:
			for w in streifen[t][1]:
				(w as Node3D).rotation.y = TAU * zeit / sek
				var ap := Gebiet.finde(w, "AnimationPlayer") as AnimationPlayer
				if ap and ap.assigned_animation != "":
					var lang := ap.get_animation(ap.assigned_animation).length
					ap.pause()   # erst anhalten, dann springen (tragprobe.gd)
					ap.seek(fmod(zeit, lang), true)
		await fp.get_tree().process_frame
		for t in namen:
			_kamera(streifen[t][0])
			await RenderingServer.frame_post_draw
			await RenderingServer.frame_post_draw
			fp.spiel.get_viewport().get_texture().get_image().save_png(fp.aus + "/trachten/%s/%04d.png" % [t, i])
			if i == 0:
				var cam := fp.spiel.kamera as Camera3D
				var l := []
				for k in streifen[t][1].size():
					var w: Node3D = streifen[t][1][k]
					l.append({"x": cam.unproject_position(w.global_position).x, "boden_y": cam.unproject_position(w.global_position).y,
						"eintrag": streifen[t][2][k]})
				lage[t] = l
				var vr := fp.spiel.get_viewport().get_visible_rect().size   # Lage in Ansichtspunkten, das Bild hat --resolution (455.1)
				lage["_ansicht"] = [vr.x, vr.y]
	fp.protokoll.append("TEIL %s %d Bilder" % [", ".join(PackedStringArray(namen)), n])
	print(fp.protokoll[-1])
