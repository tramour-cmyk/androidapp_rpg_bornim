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

var fp: FigurenProbe
var streifen := {}         # Name -> [Marker, [Figuren], [Eintraege]]
var lage := {}
# 463a (Pruefer am Tor, Film 16:0x: A2, A4 ohne Spiellicht, Boden, Schatten; B1 Haut fast weiss; C3 die Gehenden im Gleichtakt; G1 Sohlen
# angeschnitten): wie voelkerprobe.gd (431, Lauf 5 am Tor ohne A, G): Signatur des Kampforts, Hautton nach HeldFigur.HAUT_EICHUNG (431e),
# eigene Atemschicht je stehender Figur mit verteilten Startphasen, Gehen mit Versatz in der Schleife, Ausschnitt vor dem Film geprueft
const VERSATZ := [0.0, 0.43, 0.19, 0.71, 0.57, 0.31]
var sig: Node = null
const Signatur = preload("res://kampf/signatur.gd")

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
	for t in streifen: _atem_verteilen(t)
	_signatur((streifen.values()[0][0] as Node3D).global_position)
	await fp.get_tree().create_timer(1.0).timeout
	var sp := Signatur.pruefen(fp.spiel)
	print("SIGNATUR Trachten: " + (sp if sp != "" else "Toon, Tusche nach Licht, Schatten"))
	var kam := fp.spiel.kamera as Camera3D
	print("KAMERA Trachten: Ort %s, Drehung %s, Projektion %d, Groesse %.2f, Wiese %s" % [str(kam.global_position), str(kam.global_rotation_degrees), kam.projection, kam.size, str(fp.spiel.karte.kachel_pos(FigurenProbe.FILM_ORT))])
	for seite in SEITEN:
		var namen := []
		for i in (SEITEN[seite] as Array).size(): namen.append("%s_%d" % [seite, i + 1])
		await _laufen(namen, float(DAUER[seite]))
	FileAccess.open(fp.aus + "/trachten/lage.json", FileAccess.WRITE).store_string(JSON.stringify(lage, " "))


func _streifen(name: String, figuren: Array, x0: Vector3) -> void:
	var marker := Node3D.new()
	fp.spiel.add_child(marker)
	marker.position = x0 + Vector3((figuren.size() - 1) * ABSTAND / 2.0, MITTE_Y, 0)
	marker.set_meta("zoom", BREITE)
	var figs := []
	var eintraege := []
	for i in figuren.size():
		var e: Array = figuren[i]
		var h := String(e[0]); var g := String(e[1]); var st := String(e[2]); var bew := String(e[3])
		var a := HeldFigur.vorgabe(h, g)   # 870.4: Beispielkopf nach der Herkunft
		if g == "w": a["frisur"] = "Hair_Long"
		a["statur"] = st
		var mats := []
		var m := HeldFigur.baue({"herkunft": h, "volk": "HUMAN", "aussehen": a, "ausruestung": {}}, mats)
		if m == null: fp.protokoll.append("FEHLT %s %s" % [h, g]); continue
		for mt in mats: (mt as ShaderMaterial).set_shader_parameter("fill", 0.42)   # wie klasse_figur (Held)
		var w := Node3D.new()
		fp.spiel.add_child(w)
		w.position = x0 + Vector3(i * ABSTAND, 0, 0)
		w.add_child(m)
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		ap.play(bew)
		w.set_meta("versatz", VERSATZ[i % VERSATZ.size()])
		w.set_meta("schluessel", "%s/%s/%s/%s" % [h, g, st, bew])
		if bew == "Stehen": _atem(w, m, ap, name + "/" + String(w.get_meta("schluessel")), i)
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
	kam.zoom = float(marker.get_meta("zoom", BREITE))
	kam.springe()
	if sig: sig.ziel = marker.global_position


func _laufen(namen: Array, sek: float) -> void:
	var n := int(round(sek * FPS))
	for t in namen: await _ausschnitt(t)
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
					ap.seek(fmod(zeit + float(w.get_meta("versatz", 0.0)) * lang, lang), true)
				if w.has_meta("atem"):
					w.get_meta("atem").phase = fposmod(float(w.get_meta("atem_start")) + zeit / float(w.get_meta("atem_takt")), 1.0)
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


# 463a A2, A4: Licht, Schatten und Tusche wie im Kampfort (voelkerprobe.gd _signatur, 431d a)
func _signatur(wo: Vector3) -> void:
	var cam := fp.spiel.kamera as Camera3D
	for q in cam.get_children():
		if q is MeshInstance3D: (q as MeshInstance3D).visible = false
	var lc: Node = fp.spiel.licht
	lc.stimmung.set_shader_parameter("anteil", 0.0)
	lc.stimmung.set_shader_parameter("rand", 0.0)
	var env: Environment = lc.env
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.62, 0.66, 0.75)   # kampfort.gd
	env.ambient_light_energy = 0.75
	sig = Signatur.einrichten(fp.spiel, cam, wo, env, lc.sonne)
	fp.protokoll.append("SIGNATUR Kampfort: Sonne %s %.2f, Umgebung %.2f" % [str(lc.sonne.rotation_degrees), lc.sonne.light_energy, env.ambient_light_energy])
	print(fp.protokoll[-1])


# 463a C3: eigene Atemschicht (Gebiet.atem_an, 453.2) mit Takt und Startphase je Figur, im Film von Hand weitergestellt
func _atem(w: Node3D, m: Node3D, ap: AnimationPlayer, schluessel: String, i: int) -> void:
	var at = Gebiet.atem_an(m, ap, hash(schluessel) ^ 463)
	if at == null:
		fp.protokoll.append("ATEM %s: ohne (kein UAL-Geruest)" % schluessel)
		return
	var takt: float = at.takt
	at.takt = 1.0e9
	at.phase = fposmod(float(VERSATZ[i % VERSATZ.size()]) + 0.5 * at.phase, 1.0)
	w.set_meta("atem", at)
	w.set_meta("atem_takt", takt)
	w.set_meta("atem_start", at.phase)


# wie voelkerprobe.gd _atem_verteilen (431d C3): Takte zum Mittel hin, Startphasen so, dass kein Paar lange gleich atmet
func _atem_verteilen(t: String) -> void:
	var figs := (streifen[t][1] as Array).filter(func(w): return (w as Node3D).has_meta("atem"))
	if figs.size() < 2: return
	var sek: float = DAUER.get(t.split("_")[0], 12.0)
	var mt := 0.0
	for w in figs: mt += float(w.get_meta("atem_takt")) / figs.size()
	for w in figs: w.set_meta("atem_takt", mt + (float(w.get_meta("atem_takt")) - mt) * 0.2)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(t) ^ 463
	var best := []
	var best_lang := INF
	for v in 400:
		var st := []
		for k in figs.size(): st.append(fposmod(float(k) / figs.size() + (0.0 if v == 0 else rng.randf_range(-0.5, 0.5)), 1.0))
		var lang := 0.0
		for a in figs.size():
			for b in range(a + 1, figs.size()):
				var lauf := 0.0
				for j in int(sek * 10.0) + 1:
					var z := j / 10.0
					var pa: float = st[a] + z / float(figs[a].get_meta("atem_takt"))
					var pb: float = st[b] + z / float(figs[b].get_meta("atem_takt"))
					lauf = lauf + 0.1 if absf(fposmod(pa - pb + 0.5, 1.0) - 0.5) < VoelkerProbe.GLEICH else 0.0
					lang = maxf(lang, lauf)
		if lang < best_lang: best_lang = lang; best = st
	for k in figs.size():
		figs[k].set_meta("atem_start", best[k])
		figs[k].get_meta("atem").phase = best[k]
	fp.protokoll.append("ATEMABSTAND %s: %d Figuren, laengstes Paar naeher als %.2f der Schleife %.1f s" % [t, figs.size(), VoelkerProbe.GLEICH, best_lang])
	print(fp.protokoll[-1])


# 463a G1 (Sohlen angeschnitten): wie voelkerprobe.gd _ausschnitt, jede Figur auch gedreht ganz im Bild, sonst Ausschnitt weiter
const RAND := 1.15
func _ausschnitt(t: String) -> void:
	var marker: Node3D = streifen[t][0]
	var cam := fp.spiel.kamera as Camera3D
	var zyl := []
	for w in streifen[t][1]:
		var r := 0.0
		var h := 0.0
		for mi in (w as Node3D).find_children("*", "MeshInstance3D", true, false):
			var bb: AABB = (w as Node3D).global_transform.affine_inverse() * (mi as MeshInstance3D).global_transform * (mi as MeshInstance3D).get_aabb()
			for k in 8:
				var ecke := bb.get_endpoint(k)
				r = maxf(r, Vector2(ecke.x, ecke.z).length())
				h = maxf(h, ecke.y)
		zyl.append([w, r * RAND, h * RAND])
	var start: float = marker.get_meta("zoom", BREITE)
	for schritt in 12:
		_kamera(marker)
		await fp.get_tree().process_frame
		var raus := false
		for z in zyl:
			var p: Vector3 = (z[0] as Node3D).global_position
			for k in 16:
				var a := TAU * k / 8.0
				var rr: float = z[1] if k < 8 else minf(z[1], 0.35)
				if not cam.is_position_in_frustum(p + Vector3(cos(a) * rr, z[2] if k < 8 else -0.05, sin(a) * rr)): raus = true; break
			if raus: break
		if not raus:
			fp.protokoll.append("AUSSCHNITT %s: Zoom %.2f (vorher %.2f), %d Schritte" % [t, float(marker.get_meta("zoom")), start, schritt])
			print(fp.protokoll[-1])
			return
		marker.set_meta("zoom", float(marker.get_meta("zoom")) * 1.08)
	fp.protokoll.append("AUSSCHNITT %s: nach 12 Schritten noch hinaus, Zoom %.2f" % [t, float(marker.get_meta("zoom"))])
