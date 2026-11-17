class_name TragProbe
extends RefCounted
# 417 Probe Tragart (tragen.gd): Stab (Magier), Kriegsaxt (Kaempfer), Bogen (Schurke) im Gehen und Rennen.
# Am Rechner: godot --path godot --resolution 900x1200 -- --figuren=<ausgabe> --teil=tragen      Standbilder und Messung
#             godot --path godot --resolution 720x960 --write-movie <x.avi> --fixed-fps 30 -- --figuren=<ausgabe> --teil=tragenfilm
#   Standbilder: <ausgabe>/tragen/<figur>_<Bewegung>_<phase>_<ansicht>.png (rechts, links, vorn, hinten), Kamera auf Brusthoehe
#   --teil=tragenaxt: nur die Kriegsaxt in den Fassungen AXT_FASSUNGEN (Runde 3), Figur FIGHTER_<Fassung>
#   Messung: je Bild der Abstand der Waffe zum Koerper (verformtes Netz, ohne die tragende Hand): unter 0 steckt sie im Koerper
const FIGUREN := [["Zauberlehrling", "quarterstaff"], ["Wachsoldat", "greataxe"], ["Herumtreiber", "shortbow"]]   # 870.4: Herkunft statt Klasse
# Runde 3 (--teil=tragenaxt, Chef 01.11., 11:32: Stab, Bogen passen; „der Axtkopf muss nach unten“, „ein bisschen weiter nach vorne
# ziehen“): nur die Kriegsaxt in drei Fassungen nebeneinander: Name, Griff unter dem Ursprung (m, Kopf 0,80 darueber), Blatt haengt
const AXT_FASSUNGEN := [["bisher", 0.40, false], ["A", 0.15, true], ["B", 0.0, true]]
# Runde 4 (--teil=tragenpakete, Chef 01.11., 12:21: Axt Runde 3 „schwebt“; 348.12c Pakete): Gehen und Rennen je Waffe aus den
# Protofactor-Paketen (bewegungen.bin Gehen_<gang>, Rennen_<gang>), Waffe in der Faust (tragen.gd _paket); im Tempo des Spiels
# (held.gd: Gehen 1,84, Rennen 3,68 Kacheln/s, speed_scale wie dort), damit man sieht, wie es im Spiel aussieht
const PAKET_FIGUREN := [["axt", "Wachsoldat", {"MAIN_HAND": {"base": "greataxe"}}], ["einhand", "Wachsoldat", {"MAIN_HAND": {"base": "longsword"}}],
	["schild", "Wachsoldat", {"MAIN_HAND": {"base": "longsword"}, "OFF_HAND": {"base": "round_shield"}}], ["bogen", "Herumtreiber", {"MAIN_HAND": {"base": "shortbow"}}]]
# Rennen beide Fassungen (Chef 02.11., 14:46 Rennen zu vorgebeugt; 14:50/14:52 Rennen A „vernünftig“): je Waffe ausser Bogen (passt)
# eine zweite Figur „pkA_<art>“ mit HeldFigur.WAFFEN_RENNEN „A“ (Beine und Rumpf aus Rennen A, Arme aus dem Paket); Film nur von der
# Seite der Waffe, ohne Standbilder
const PAKET_A := ["axt", "einhand", "schild"]
# Runde 6 (Chef 01.11., 13:4x: „Das Gehen muss langsamer sein … eher ein Staxen, ein schnelles Staxen“): Gehtempo im Spiel senken statt
# die Pakete schneller abzuspielen; Vorschlag 1,5 m/s (Mensch etwa 1,3-1,5; heute 1,84 Kacheln/s = 2,13 m/s). Film und Standbilder mit dem
# Vorschlag, GEHEN_M_S=<m/s> setzt einen anderen (2.13 wie heute)
static var SPIEL_GEHEN := float(OS.get_environment("GEHEN_M_S")) if OS.has_environment("GEHEN_M_S") else 1.5
const SPIEL_RENNEN := 3.68 * Karte.TS
# Spielkamera (kamera.gd: senkrecht, Tusche): Gieren, Neigung, Bildbreite in m; die Figur blickt nach +Z, ihre Rechte ist -X
const ANSICHTEN := {"rechts": [-90.0, -6.0, 2.6], "links": [90.0, -6.0, 2.6], "vorn": [0.0, -6.0, 2.6], "hinten": [180.0, -6.0, 2.6],
	"spiel": [Kamera.NORD, -30.0, Kamera.NAH]}
const FPS := 30.0
# Film (Pruefer 13:3x; 416.4): Stehen, Anlaufen, Gehen, Rennen, Gehen, Anhalten; Start 12 m vor der Mitte der Wiese (ab 4,3 s lief die
# Figur ueber den Rand)
const FILM_FOLGE := [["Stehen", 1.0], ["Gehen", 2.5], ["Rennen", 2.5], ["Gehen", 1.5], ["Stehen", 1.2]]
const FILM_START := -12.0
const FILM_WEIT := 1.2
const ZELLE := 0.06
const NAH := 0.45     # m: Knochen weiter von der Waffe zaehlen nicht
const TIEF := 0.05    # m: tiefer gilt nicht als innen
const INNEN_WINKEL := 0.5   # innen nur, wenn der Weg zur Flaeche mindestens 60 Grad gegen die Normale steht (cos 60)

var fp: FigurenProbe
var cam: Camera3D
var liste: Array = []   # je Figur [Kennung, Dateiname, Klasse, Waffe]

func _init(p: FigurenProbe) -> void: fp = p

func figuren_bauen(axt := false, pakete := false) -> void:
	fp.freie_wiese()
	fp.spiel.held.visible = false
	liste = []
	if pakete:
		for e in PAKET_FIGUREN:
			liste.append(["pk_" + e[0], e[1] + "_" + e[0], e[1], String(e[2]["MAIN_HAND"]["base"]), e[0]])
			fp.klasse_figur("pk_" + e[0], {"herkunft": e[1], "volk": "HUMAN", "aussehen": HeldFigur.vorgabe(e[1]), "ausruestung": e[2]})
			if fp.figuren.has("pk_" + e[0]):
				var mm := modell("pk_" + e[0])
				fp.protokoll.append("GANG %s: %s, Tempo %.2f / %.2f m/s" % [e[0], mm.get_meta("gang", "FEHLT"), float(mm.get_meta("gang_gehen_m_je_s", 0.0)),
					float(mm.get_meta("gang_rennen_m_je_s", 0.0))])
				print(fp.protokoll[-1])
		for e in PAKET_FIGUREN:
			if e[0] not in PAKET_A: continue
			liste.append(["pkA_" + e[0], e[1] + "_" + e[0] + "_A", e[1], String(e[2]["MAIN_HAND"]["base"]), e[0], "A"])
			fp.klasse_figur("pkA_" + e[0], {"herkunft": e[1], "volk": "HUMAN", "aussehen": HeldFigur.vorgabe(e[1]), "ausruestung": e[2], "waffen_rennen": "A"})
		cam = fp.spiel.kamera
		return
	if axt:
		for a in AXT_FASSUNGEN: liste.append(["ax_" + a[0], "FIGHTER_" + a[0], "Wachsoldat", "greataxe"])
	else:
		for e in FIGUREN: liste.append(["tr_" + e[0], e[0], e[0], e[1]])
	for i in liste.size():
		var e: Array = liste[i]
		fp.klasse_figur(e[0], {"herkunft": e[2], "volk": "HUMAN", "aussehen": HeldFigur.vorgabe(e[2]),
			"ausruestung": {"MAIN_HAND": {"base": e[3]}}})
		if axt and fp.figuren.has(e[0]):
			var sk := Gebiet.finde(modell(e[0]), "Skeleton3D") as Skeleton3D
			for t in sk.get_children().filter(func(c): return c is Tragen):
				(t as Tragen).axt_griff = AXT_FASSUNGEN[i][1]
				(t as Tragen).axt_haengt = AXT_FASSUNGEN[i][2]
				fp.protokoll.append("FASSUNG %s Griff %.2f haengt %s" % [e[1], AXT_FASSUNGEN[i][1], AXT_FASSUNGEN[i][2]])
	cam = fp.spiel.kamera

func modell(k: String) -> Node3D: return fp.figuren[k].get_child(0) as Node3D

func zeige_nur(k: String) -> void:
	for x in fp.figuren: fp.figuren[x].visible = x == k

func stelle_kamera(w: Node3D, ansicht: String, weit := 1.0) -> void:
	var a: Array = ANSICHTEN[ansicht]
	var kam := cam as Kamera
	kam.ziel = w
	kam.nah = true
	kam.gieren_ziel = a[0]
	kam.neigung = a[1]
	kam.zoom = a[2] * weit
	kam.springe()

# ---------------------------------------------------------------- Standbilder und Film (die Messung macht tests/tragen_417.gd)
# je Figur und Bewegung nach zwei Umlaeufen Vorlauf (der Stabfuss setzt sich) vier Phasen aus vier Richtungen; danach der Film:
# je Figur von der Seite der Waffe zwei Umlaeufe Gehen, zwei Rennen, Bild fuer Bild (30 je s), die Kamera folgt
func standbilder(axt := false, pakete := false) -> void:
	await figuren_bauen(axt, pakete)
	await fp.get_tree().create_timer(1.0).timeout
	var ort: Vector3 = fp.spiel.karte.kachel_pos(FigurenProbe.FILM_ORT)
	DirAccess.make_dir_recursive_absolute(fp.aus + "/tragen")
	for e in liste:
		var k: String = e[0]
		if not fp.figuren.has(k) or e.size() > 5: continue   # Fassung A: nur im Film
		zeige_nur(k)
		var w: Node3D = fp.figuren[k]
		var m := modell(k)
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		for b0 in ["Gehen", "Rennen"]:
			var bew: String = b0 + ("_" + String(e[4]) if e.size() > 4 else "")
			ap.play(bew)
			await fp.get_tree().process_frame   # eine neue Bewegung muss ein Bild lang laufen; sofort angehalten blieb die alte Pose stehen
			var lang := ap.get_animation(bew).length
			var v: float = m.get_meta("gehen_m_je_s" if b0 == "Gehen" else "rennen_m_je_s")
			var zeit := 1.0   # Pakete: Tempo des Spiels, die Bewegung laeuft speed_scale-fach (held.gd)
			if e.size() > 4:
				var vb: float = m.get_meta("gang_gehen_m_je_s" if b0 == "Gehen" else "gang_rennen_m_je_s", v)
				v = SPIEL_GEHEN if b0 == "Gehen" else SPIEL_RENNEN
				zeit = v / maxf(0.01, vb)
				if vb < 0.01:   # Lauf 41305428768: Tempo 0 (nicht gemessen), die Bewegung lief 400-fach
					fp.protokoll.append("FILM FEHLER %s %s: Tempo ohne Gleiten fehlt" % [e[1], bew]); print(fp.protokoll[-1])
					zeit = 1.0
			w.rotation.y = 0.0
			var n := maxi(8, int(round(lang / zeit * FPS)))
			for f in 3 * n:
				var t := f / FPS
				standbild_lage(ap, t, zeit, lang)
				w.position = ort + Vector3(0, 0, 1) * v * t
				await fp.get_tree().process_frame   # angehalten wirkt seek erst im naechsten Bild
				var ph := f - 2 * n
				if ph in [0, n / 4, n / 2, (3 * n) / 4]:
					for a in ANSICHTEN:
						stelle_kamera(w, a)
						await RenderingServer.frame_post_draw
						await RenderingServer.frame_post_draw
						fp.spiel.get_viewport().get_texture().get_image().save_png(fp.aus + "/tragen/%s_%s_%d_%s.png" % [e[1], b0, int(4.0 * ph / n), a])
		fp.protokoll.append("BILDER %s %s" % [e[1], e[3]])
		print(fp.protokoll[-1])
	# Pruefer Film 00:53: Schwert beim Schildtraeger und linke Faust an der Axt lagen hinter dem Koerper (Durchdringung oder Verdeckung?);
	# Schild und Axt darum von beiden Seiten, Ordner <Datei>_<Seite>
	var folgen := []
	for e in liste:
		var s0 := "links" if e[3] == "shortbow" or (e.size() > 4 and e[4] == "schild") else "rechts"
		folgen.append([e, s0])
		if e.size() == 5 and e[4] in ["schild", "axt"] and OS.has_environment("ZWEI_SEITEN"): folgen.append([e, "rechts" if s0 == "links" else "links"])
	for fe in folgen:
		var e: Array = fe[0]
		var seite: String = fe[1]
		var k: String = e[0]
		if not fp.figuren.has(k): continue
		zeige_nur(k)
		var w: Node3D = fp.figuren[k]
		var m := modell(k)
		var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		var ordner: String = fp.aus + "/film/" + String(e[1]) + "_" + seite
		DirAccess.make_dir_recursive_absolute(ordner)
		var nr := 0
		var p := ort + Vector3(0, 0, FILM_START)
		w.rotation.y = 0.0
		var g: String = "_" + String(e[4]) if e.size() > 4 else ""
		# Pruefer 13:3x (Runde 4): bei 2,5 s sprang die Pose, der Film schaltete ohne Ueberblendung um. Jetzt wie im Spiel (held.gd): die
		# Bewegung laeuft von selbst weiter (advance je Bild), Wechsel mit Held.ueberblendung, Gehen <-> Rennen im selben Schritt, Tempo
		# steigt mit Held.BESCHL; Folge FILM_FOLGE mit Anlaufen und Anhalten (416.4, Chef 13:1x: „muss immer weich sein“)
		# Pruefer Film 02:2x („bei 1,0 s springt die Haltung in einem Bild von stark vorgebeugt in aufrecht“, „Stand am Anfang und Ende
		# verschieden“): die Standbilder davor liessen den Spieler angehalten im Rennen (pause, seek); play("Stehen") setzte ihn nicht
		# zurueck, die erste Sekunde stand das Rennen (Brust 45-54 Grad vor), erst der Wechsel ins Gehen spielte. Die Messung ohne
		# Standbilder (tests/tragen_pakete_417.gd HALTUNG) steht 13 Grad und springt nicht. Darum erst anhalten, dann Stehen von vorn
		film_anfang(ap)
		await fp.get_tree().process_frame
		var tempo := 0.0
		var spur := []   # Pruefer 00:53 („Rennen: Fuss 17-28 % langsamer als der Boden“): je Bild Abschnitt, Zeit darin, Ballen im Raum, Tempo
		for ai in FILM_FOLGE.size():
			var b0: String = FILM_FOLGE[ai][0]
			var nf := int(round(float(FILM_FOLGE[ai][1]) * FPS))
			var halt: bool = ai + 1 < FILM_FOLGE.size() and FILM_FOLGE[ai + 1][0] == "Stehen"   # 416.4: vor dem Halt bremsen wie am Ende eines Wegs
			for f in nf:
				var moving := b0 != "Stehen"
				var soll := 0.0 if not moving else (SPIEL_GEHEN if b0 == "Gehen" else SPIEL_RENNEN)
				if moving and halt: soll = Held.bremse(soll, float(nf - f) / FPS * SPIEL_GEHEN * Held.ANLAUF * 2.0, SPIEL_GEHEN)
				tempo = Held.tempo_schritt(tempo, soll, SPIEL_GEHEN, 1.0 / FPS)
				var want := b0
				if moving and ap.has_animation(b0 + g) and float(m.get_meta("gang_" + ("gehen" if b0 == "Gehen" else "rennen") + "_m_je_s", 0.0)) > 0.01: want = b0 + g
				var vb := 1.0
				if moving:
					var mit := want != b0
					vb = float(m.get_meta(("gang_" if mit else "") + ("gehen" if b0 == "Gehen" else "rennen") + "_m_je_s", 1.0))
				if ap.current_animation != want: Held.wechsel(ap, want, moving, tempo / maxf(0.01, vb) if moving else 1.0, true)   # sanft wie held.gd   # 416.4
				if moving and ap.has_meta("halt"): ap.remove_meta("halt")
				ap.speed_scale = Held.takt(ap, tempo, vb, 1.0 / FPS) if moving else Held.stand_takt(ap, 1.0 / FPS)
				ap.advance(1.0 / FPS)
				p += Vector3(0, 0, 1) * tempo / FPS
				w.position = p
				spur.append([ai, f, (sk.global_transform * sk.get_bone_global_pose(sk.find_bone("ball_l"))).origin,
					(sk.global_transform * sk.get_bone_global_pose(sk.find_bone("ball_r"))).origin, tempo])
				stelle_kamera(w, seite, FILM_WEIT)   # Pruefer 00:53: Axtblatt am Feldrand abgeschnitten
				await fp.get_tree().process_frame
				await RenderingServer.frame_post_draw
				fp.spiel.get_viewport().get_texture().get_image().save_png(ordner + "/%03d.png" % nr)
				nr += 1
		ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE
		film_gleit(String(e[1]) + " von " + seite, spur)
		fp.protokoll.append("FILM %s %s von %s, %d Bilder" % [e[1], e[3], seite, nr])
		print(fp.protokoll[-1])

# Lage eines Standbilds und Anfang des Films; ein Ort fuer Probe und Messung (tests/tragen_pakete_417.gd stellt beides nach, 417)
static func standbild_lage(ap: AnimationPlayer, t: float, zeit: float, lang: float) -> void:
	ap.pause()   # erst anhalten, dann springen (umgekehrt wirkt seek nicht, die Figur stand)
	ap.seek(fmod(t * zeit, lang), true)

static func film_anfang(ap: AnimationPlayer) -> void:
	ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	ap.stop()
	ap.speed_scale = 1.0
	ap.play("Stehen"); ap.seek(0.0, true); ap.advance(0.0)

# Standfuss im Raum des Films (Boden steht): je Abschnitt Gehen/Rennen ab 0,8 s (nach Ueberblendung und Anlauf) die Geschwindigkeit des
# Ballens in den Bildern hoechstens 2 cm ueber seinem Tiefstand, Median, gegen das Tempo der Figur; 0 = kein Rutschen
func film_gleit(wer: String, spur: Array) -> void:
	for ai in FILM_FOLGE.size():
		var b0: String = FILM_FOLGE[ai][0]
		if b0 == "Stehen": continue
		var z := spur.filter(func(x): return int(x[0]) == ai and int(x[1]) >= int(0.8 * FPS))
		if z.size() < 4: continue
		var vs := []
		var tm := 0.0
		for s in [2, 3]:
			var tief := INF
			for x in z: tief = minf(tief, (x[s] as Vector3).y)
			for j in z.size() - 1:
				var a: Vector3 = z[j][s]; var b: Vector3 = z[j + 1][s]
				if a.y < tief + 0.02 and b.y < tief + 0.02: vs.append(Vector2(b.x - a.x, b.z - a.z).length() * FPS)
		for x in z: tm += float(x[4]) / z.size()
		if vs.is_empty(): continue
		vs.sort()
		var v: float = vs[vs.size() / 2]
		fp.protokoll.append("FILMGLEIT %s %s (Abschnitt %d): Standfuss gleitet %.2f m/s, Figur %.2f m/s (%.0f %%)" % [wer, b0, ai, v, tm, 100.0 * v / maxf(0.01, tm)])
		print(fp.protokoll[-1])

# ---------------------------------------------------------------- Messung
# Punkte auf den Dreiecken der Waffe (etwa alle 2 cm), im Raum der Waffe
static func proben(w: Node3D) -> PackedVector3Array:
	var r := PackedVector3Array()
	for mi in w.find_children("*", "MeshInstance3D", true, false):
		var t := Transform3D.IDENTITY
		var x: Node = mi
		while x != w:
			t = (x as Node3D).transform * t
			x = x.get_parent()
		var me := (mi as MeshInstance3D).mesh
		for s in me.get_surface_count():
			var a := me.surface_get_arrays(s)
			var V: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
			var I: PackedInt32Array = a[Mesh.ARRAY_INDEX] if a[Mesh.ARRAY_INDEX] != null else PackedInt32Array(range(V.size()))
			for j in range(0, I.size() - 2, 3):
				var p0 := t * V[I[j]]; var p1 := t * V[I[j + 1]]; var p2 := t * V[I[j + 2]]
				var st := clampi(int(ceil(maxf(p0.distance_to(p1), maxf(p1.distance_to(p2), p2.distance_to(p0))) / 0.02)), 1, 60)
				for u in st + 1:
					for vv in st + 1 - u:
						var a1 := float(u) / st; var a2 := float(vv) / st
						r.append(p0 + (p1 - p0) * a1 + (p2 - p0) * a2)
	return r

static func hand_knochen(sk: Skeleton3D, s: String) -> PackedStringArray:
	var r := PackedStringArray()
	for i in sk.get_bone_count():
		var n := sk.get_bone_name(i)
		if n.ends_with("_" + s) and (n.begins_with("hand") or n.begins_with("index") or n.begins_with("middle") or n.begins_with("ring")
			or n.begins_with("pinky") or n.begins_with("thumb")):
			r.append(n)
	return r

# je verformtem Netz: Ecken, Normalen, Knochen, Gewichte (einmal gelesen)
static func netze_von(m: Node3D) -> Array:
	var r := []
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var mm := mi as MeshInstance3D
		if not mm.is_visible_in_tree(): continue
		# Pruefer Film 02:2x (Schild von rechts: „Klinge durch den Kopf in Mundhoehe“, gemessen frei): Haar und Bart haengen ohne Haut starr
		# am Kopfknochen (heldfigur.gd haare, BoneAttachment3D „Haar_<Netz>“) und fehlten in der Messung; jetzt starr mit dem Knochen
		if mm.skin == null:
			var ba := mm.get_parent() as BoneAttachment3D
			if ba == null or not String(ba.name).begins_with("Haar_"): continue
			for s in mm.mesh.get_surface_count():
				var a := mm.mesh.surface_get_arrays(s)
				var V: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
				var I: PackedInt32Array = a[Mesh.ARRAY_INDEX] if a[Mesh.ARRAY_INDEX] != null else PackedInt32Array(range(V.size()))
				r.append({"starr": ba.bone_name, "lokal": mm.transform, "V": V, "N": a[Mesh.ARRAY_NORMAL], "I": I, "name": String(mm.name)})
			continue
		for s in mm.mesh.get_surface_count():
			var a := mm.mesh.surface_get_arrays(s)
			var V: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
			var I: PackedInt32Array = a[Mesh.ARRAY_INDEX] if a[Mesh.ARRAY_INDEX] != null else PackedInt32Array(range(V.size()))
			var B: PackedInt32Array = a[Mesh.ARRAY_BONES]; var W: PackedFloat32Array = a[Mesh.ARRAY_WEIGHTS]
			var nb := B.size() / maxi(1, V.size())
			var dom := PackedInt32Array(); dom.resize(V.size())
			for i in V.size():
				var best := -1.0
				for j in nb:
					if W[i * nb + j] > best: best = W[i * nb + j]; dom[i] = B[i * nb + j]
			r.append({"skin": mm.skin, "V": V, "N": a[Mesh.ARRAY_NORMAL], "B": B, "W": W, "I": I, "dom": dom})
	return r

# Abstand jedes Waffenpunkts zum naechsten Dreieck des verformten Koerpers (bis 2 Zellen weit), Vorzeichen nach der Normalen am
# naechsten Punkt (unter 0: im Koerper); Dreiecke der tragenden Hand zaehlen nicht (die Faust umschliesst den Griff)
static func abstand(netze: Array, sk: Skeleton3D, ohne: PackedStringArray, w: Node3D, pkt: PackedVector3Array, posen: Array[Transform3D] = []) -> Dictionary:
	var gitter := {}
	var P := PackedVector3Array(); var N := PackedVector3Array(); var T := PackedStringArray()
	var D := PackedInt32Array()   # Dreiecke: je drei Ecken (Nummern in P)
	# nur Ecken, deren Hauptknochen hoechstens NAH von der Waffe liegt (Rechenzeit)
	var wt := w.global_transform
	var lo3 := Vector3(INF, INF, INF); var hi3 := -lo3
	for q0 in pkt:
		var q := wt * q0
		lo3 = lo3.min(q); hi3 = hi3.max(q)
	var box := AABB(lo3, hi3 - lo3).grow(NAH)
	for nz in netze:
		if nz.has("starr"):
			var bi := sk.find_bone(String(nz["starr"]))
			if bi < 0: continue
			var kt: Transform3D = sk.global_transform * (posen[bi] if bi < posen.size() else sk.get_bone_global_pose(bi))
			if not box.has_point(kt.origin): continue
			var tr: Transform3D = kt * (nz["lokal"] as Transform3D)
			var V0: PackedVector3Array = nz["V"]; var N0: PackedVector3Array = nz["N"]; var I0: PackedInt32Array = nz["I"]
			var o0 := P.size()
			for i in V0.size():
				P.append(tr * V0[i]); N.append((tr.basis * N0[i]).normalized()); T.append(String(nz["name"]))
			for j in range(0, I0.size() - 2, 3):
				_dreieck(o0 + I0[j], o0 + I0[j + 1], o0 + I0[j + 2], P, D, gitter)
			continue
		var skin: Skin = nz["skin"]
		var mats := []; var namen := []
		for b in skin.get_bind_count():
			var bn := skin.get_bind_name(b)
			var bi := sk.find_bone(bn) if bn != "" else skin.get_bind_bone(b)
			mats.append(sk.global_transform * (posen[bi] if bi < posen.size() else sk.get_bone_global_pose(bi)) * skin.get_bind_pose(b))
			namen.append(sk.get_bone_name(bi))
		var V: PackedVector3Array = nz["V"]; var NN: PackedVector3Array = nz["N"]
		var B: PackedInt32Array = nz["B"]; var W: PackedFloat32Array = nz["W"]; var I: PackedInt32Array = nz["I"]
		var nb := B.size() / maxi(1, V.size())
		var o := P.size()
		var dom: PackedInt32Array = nz["dom"]
		var nah := PackedByteArray(); nah.resize(mats.size())
		for b in mats.size(): nah[b] = 1 if box.has_point((mats[b] as Transform3D) * (skin.get_bind_pose(b).affine_inverse().origin)) else 0
		var weg := PackedByteArray(); weg.resize(V.size())
		for i in V.size():
			if nah[dom[i]] == 0:
				weg[i] = 1; P.append(Vector3.ZERO); N.append(Vector3.UP); T.append("")
				continue
			var p := Vector3.ZERO; var n := Vector3.ZERO; var best := -1.0; var bb := 0
			for j in nb:
				var g := W[i * nb + j]
				if g <= 0.0: continue
				var t: Transform3D = mats[B[i * nb + j]]
				p += (t * V[i]) * g; n += (t.basis * NN[i]) * g
				if g > best: best = g; bb = B[i * nb + j]
			weg[i] = 1 if namen[bb] in ohne else 0
			P.append(p); N.append(n.normalized()); T.append(namen[bb])
		for j in range(0, I.size() - 2, 3):
			if weg[I[j]] + weg[I[j + 1]] + weg[I[j + 2]] > 0: continue
			_dreieck(o + I[j], o + I[j + 1], o + I[j + 2], P, D, gitter)
	var teile := {}
	var innen := 0
	var mn := 9.0
	var schlimm := {}
	var innen_y := Vector2(INF, -INF)   # 417 Runde 6: von wo bis wo laengs der Waffe (Modell-y, m) sie tiefer als 1 cm im Koerper liegt
	for q0 in pkt:
		var q := wt * q0
		var c := Vector3i((q / ZELLE).floor())
		var bd := 9.0; var bt := -1; var bc := Vector3.ZERO; var bw := Vector3.ZERO
		var gesehen := {}
		for dx in [-1, 0, 1]:
			for dy in [-1, 0, 1]:
				for dz in [-1, 0, 1]:
					var l = gitter.get(c + Vector3i(dx, dy, dz))
					if l == null: continue
					for t in l:
						if gesehen.has(t): continue
						gesehen[t] = true
						var bz := _naechst(q, P[D[3 * t]], P[D[3 * t + 1]], P[D[3 * t + 2]])
						var cp: Vector3 = P[D[3 * t]] * bz.x + P[D[3 * t + 1]] * bz.y + P[D[3 * t + 2]] * bz.z
						var d := q.distance_squared_to(cp)
						if d < bd: bd = d; bt = t; bc = cp; bw = bz
		if bt < 0: continue
		var nrm: Vector3 = N[D[3 * bt]] * bw.x + N[D[3 * bt + 1]] * bw.y + N[D[3 * bt + 2]] * bw.z
		var teil: String = T[D[3 * bt + (0 if bw.x >= bw.y and bw.x >= bw.z else (1 if bw.y >= bw.z else 2))]]
		var d := sqrt(bd)
		# unter 0 nur dicht unter der Flaeche: tiefer liegt ein Punkt nur scheinbar „innen“ (einlagige Stoffe wie Umhang und Wappenrock
		# haben keine Innenseite); eine Waffe, die wirklich eindringt, hat an der Flaeche Punkte knapp darunter (Punkte alle 2 cm)
		# 417 Runde 6 (Lauf 41320044677: Langschwert und Bogen „-5,0 cm“ im Unterarm, Ort am Griff in der Faust): ohne die Hand hat das
		# Netz am Handgelenk einen Rand; ein Punkt in der Faust liegt laengs des Arms vor diesem Rand, die Normale dort zeigt quer nach
		# aussen, das Vorzeichen kippt schon bei kleinstem Winkel. Innen nur, wo der Weg zur Flaeche ueberwiegend gegen die Normale zeigt
		if d > 1e-4 and (q - bc).dot(nrm) < -INNEN_WINKEL * d and d < TIEF:
			d = -d; innen += 1
			if d < -0.01: innen_y = Vector2(minf(innen_y.x, q0.y), maxf(innen_y.y, q0.y))
		elif d <= 1e-4 and (q - bc).dot(nrm) < 0.0: innen += 1
		teile[teil] = minf(float(teile.get(teil, 9.0)), d)
		if d < mn: schlimm = {"waffe": q0, "welt": q, "punkt": bc, "teil": teil}
		mn = minf(mn, d)
	return {"teile": teile, "innen": innen, "min": mn, "schlimm": schlimm, "innen_y": innen_y}

# Dreieck (Nummern der Ecken in P) in D und in jede Zelle des Gitters, die es beruehrt
static func _dreieck(i0: int, i1: int, i2: int, P: PackedVector3Array, D: PackedInt32Array, gitter: Dictionary) -> void:
	var a := P[i0]; var b2 := P[i1]; var c2 := P[i2]
	var nr := D.size() / 3
	D.append(i0); D.append(i1); D.append(i2)
	var lo := Vector3i((a.min(b2).min(c2) / ZELLE).floor()); var hi := Vector3i((a.max(b2).max(c2) / ZELLE).floor())
	for x in range(lo.x, hi.x + 1):
		for y in range(lo.y, hi.y + 1):
			for z in range(lo.z, hi.z + 1):
				var k := Vector3i(x, y, z)
				if not gitter.has(k): gitter[k] = PackedInt32Array()
				gitter[k].append(nr)

# naechster Punkt des Dreiecks abc zu p als Schwerpunktkoordinaten (Ericson, Real-Time Collision Detection 5.1.5)
static func _naechst(p: Vector3, a: Vector3, b: Vector3, c: Vector3) -> Vector3:
	var ab := b - a; var ac := c - a; var ap := p - a
	var d1 := ab.dot(ap); var d2 := ac.dot(ap)
	if d1 <= 0.0 and d2 <= 0.0: return Vector3(1, 0, 0)
	var bp := p - b
	var d3 := ab.dot(bp); var d4 := ac.dot(bp)
	if d3 >= 0.0 and d4 <= d3: return Vector3(0, 1, 0)
	var vc := d1 * d4 - d3 * d2
	if vc <= 0.0 and d1 >= 0.0 and d3 <= 0.0:
		var v := d1 / (d1 - d3)
		return Vector3(1.0 - v, v, 0)
	var cpv := p - c
	var d5 := ab.dot(cpv); var d6 := ac.dot(cpv)
	if d6 >= 0.0 and d5 <= d6: return Vector3(0, 0, 1)
	var vb := d5 * d2 - d1 * d6
	if vb <= 0.0 and d2 >= 0.0 and d6 <= 0.0:
		var w2 := d2 / (d2 - d6)
		return Vector3(1.0 - w2, 0, w2)
	var va := d3 * d6 - d5 * d4
	if va <= 0.0 and (d4 - d3) >= 0.0 and (d5 - d6) >= 0.0:
		var w3 := (d4 - d3) / ((d4 - d3) + (d5 - d6))
		return Vector3(0, 1.0 - w3, w3)
	var den := 1.0 / (va + vb + vc)
	var v2 := vb * den; var w4 := vc * den
	return Vector3(1.0 - v2 - w4, v2, w4)
