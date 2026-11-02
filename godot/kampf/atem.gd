# 453.1 (Chef 01.11., 13:0x, beim Film 406: „dass unsere Helden unsere zwei immer gleich atmen. Die können ruhig mal langsamer
# atmen oder nicht so heftig … nach einer Abwehr ein bisschen schneller und dann wieder ruhiger oder nach einem Angriff schneller und
# dann wieder ruhiger. Eine gewisse Variation“; Grundsatz Archiv 453.1: jede lebende Figur atmet immer als eigene Schicht, ruhig, je
# Figur eigener Takt, nach Anstrengung schneller und abklingend). Das Atmen als eigene Schicht über jeder Bewegung, nur auf Brust,
# Schultern und Hals: Brust hebt sich (Rumpf leicht zurück), Schlüsselbeine heben sich, Hals und Kopf gleichen den Blick aus. Die
# Grundbewegung bleibt, wie sie ist; nur ihr eigener Atem wird vorher herausgenommen (figur.gd _ohne_atem).
# Je Figur eigener Takt (± TAKT_STREU) und Versatz; anstrengen() nach Angriff, Ausweichen, Treffer: schneller und tiefer, in etwa
# 5 s zurück (ABKLINGEN_S). Einatmen kürzer als Ausatmen (EIN_ANTEIL).
# 453.1 Feld 2 (Chef 02.11., 11:07: „hatten wir nicht gesagt, dass Atmen sich bei Angriff und Verteidigung steigert und dann wieder
# normalisiert? Und einen Tick schneller dürfen die Helden schon atmen“): im Kampfort Ruhe RUHE_KAMPF_S statt RUHE_S (unterwegs wie
# bisher); die Anstrengung sammelt sich über mehrere Züge, bleibt HALTEN_S oben (die Figur ist noch in der Bewegung) und klingt erst
# dann ab; tiefer (TIEFER_KAMPF) und weich angehoben (TIEF_S), damit nichts zuckt. Unterwegs alles wie bisher (kampf).
extends SkeletonModifier3D

## Ruhe: ein Atemzug in Sekunden (14 je Minute; in Idle_Loop der UAL dauert er 1,25 s, 48 je Minute: „hechelt“)
const RUHE_S := 4.3
## eigener Takt je Figur: ± so viel
const TAKT_STREU := 0.15
## im Kampfort: 17 je Minute (Feld 2: 14, „einen Tick schneller“)
const RUHE_KAMPF_S := 3.6
## nach voller Anstrengung: so viel kürzer und so viel tiefer (unterwegs und Tiere, atem_tier.gd)
const SCHNELLER := 0.55
const TIEFER := 0.9
## im Kampfort (Feld 2 mit 0,55 und 0,9: Steigerung kaum zu sehen)
const SCHNELLER_KAMPF := 0.5
const TIEFER_KAMPF := 1.6
## so lange nach der letzten Anstrengung bleibt sie oben (s; Feld 2: 0)
const HALTEN_S := 2.0
## dann klingt sie mit dieser Zeitkonstante ab (s); 7 s nach dem Zug bleibt etwa ein Siebtel, nach 9 s ein Zwanzigstel
const ABKLINGEN_S := 2.5
## die Tiefe folgt der Anstrengung weich (s), sonst springen die Schultern mitten im Atemzug
const TIEF_S := 0.4
## höchstens so tief wie in Ruhe, mit Ausgleich nach Kameraabstand und Tracht
const TIEF_MAX := 5.0
## 453.1 Feld 2, Tor 461a (Prüfer Lauf 173: der Kleriker atmet im Bild 1,0 px, der Kämpfer 1,7 px, das Schultergelenk beider hebt
## sich gleich, 1,5 cm; nach dem Treffer 1,6 px, „kaum sichtbar“): wie weit sich die Haut über der Schulter hebt, hängt an der Tracht
## (welche Knochen sie tragen). Beim ersten Bild misst die Schicht darum an der eigenen Figur, wie weit sich die Haut im Umkreis
## NETZ_R über dem Schultergelenk bei voller Einatmung hebt, gegen dieselben Punkte, säßen sie fest am Schlüsselbein, und gleicht
## das aus, höchstens NETZ_MAX
const NETZ_R := 0.15
const NETZ_MAX := 2.0
const EIN_ANTEIL := 0.42
## Ausschlag in Grad bei voller Einatmung in Ruhe: [Knochen, Art, Grad]; „zurück“ dreht um die Querachse (Brust hebt sich),
## „heben“ das Schlüsselbein um die Längsachse nach oben, „blick“ gleicht am Hals und Kopf den Rumpf aus (Blick bleibt)
const KNOCHEN := [["spine_02", "zurück", 0.7], ["spine_03", "zurück", 1.1], ["clavicle_l", "heben", 3.2], ["clavicle_r", "heben", 3.2],
	["neck_01", "blick", -0.6], ["Head", "blick", -0.5]]

## 453.1 (Chef 01.11., 19:5x: „der näher am Wolf steht, bei dem ist die Atmung aber fast nicht mehr zu erkennen, deswegen etwas
## deutlicher“): der vordere Held steht weiter von der Kampfkamera (kampfort.gd _stand: vorn = weiter weg), sein Atem ist im Bild
## kleiner. Der Ausschlag wächst darum mit dem Abstand zur Kamera gegen den nächsten atmenden Helden (im Bild gleich groß),
## höchstens SICHT_MAX, weich über SICHT_S. Nur im Kampfort (figur.gd setzt ausgleich); unterwegs (Gebiet.atem_an, Tom) wie bisher
const GRUPPE := "atem_held"
const SICHT_MAX := 1.6
const SICHT_S := 0.8

var takt := RUHE_S
var sicht := 1.0          # Ausgleich nach Kameraabstand, 1 = nächster Held
var ausgleich := false    # nur im Kampfort
var phase := 0.0          # 0..1 im Atemzug
var anstrengung := 0.0    # 0..1
var tiefe := 0.0          # zuletzt angewandte Einatmung 0..1 mal Tiefe (Prüflauf)
var halten := 0.0         # so lange bleibt die Anstrengung noch oben (s)
var tief_glatt := 1.0     # weich nachgeführte Tiefe
## 453.1 Feld 2 nur im Kampfort (eigen_kampf); unterwegs (held.gd ruft anstrengen je Bild beim Gehen und Rennen) wie
## bisher. Prüfschalter ATEM_FELD2=1: auch im Kampfort wie Feld 2 (02.11., 11:07)
var kampf := false
var netz := 1.0           # Ausgleich nach Tracht (1 = Haut hebt sich wie das Gelenk)
var netz_roh := 1.0       # gemessen: Hub fest am Schlüsselbein durch Hub der Haut (Prüflauf)
var _netz_mi := []        # Netze der Figur, gemessen wird beim ersten Bild
var _idx := []


## Figur mit eigenem Takt und Versatz; seed fest je Figur, damit Prüfläufe gleich ausfallen
func eigen(seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	takt = RUHE_S * (1.0 + rng.randf_range(-TAKT_STREU, TAKT_STREU))
	phase = rng.randf()


## 453.1 Feld 2: Held und Söldner im Kampfort (figur.gd); Prüfschalter ATEM_FELD2=1 wie Feld 2
func eigen_kampf(seed: int) -> void:
	eigen(seed)
	if OS.get_environment("ATEM_FELD2") != "":
		return
	kampf = true
	takt *= RUHE_KAMPF_S / RUHE_S


## 453.1: die Netze der Figur (figur.gd), nur im Kampfort; gemessen beim ersten Bild, wenn die Pose der Bewegung steht
func netz_messen(netze: Array) -> void:
	if kampf:
		_netz_mi = netze.filter(func(m): return m is MeshInstance3D and m.skin != null and m.mesh != null)


func _enter_tree() -> void:
	if ausgleich:
		add_to_group(GRUPPE)


## Abstand zur Kamera gegen den nächsten atmenden Helden: d / d_min, 1 .. SICHT_MAX
static func sicht_ziel(d: float, d_min: float) -> float:
	return clampf(d / maxf(d_min, 0.1), 1.0, SICHT_MAX)


func _sicht_jetzt(sk: Skeleton3D) -> float:
	var cam := sk.get_viewport().get_camera_3d() if sk.is_inside_tree() else null
	if cam == null:
		return 1.0
	var c := cam.global_position
	var d := c.distance_to(sk.global_position)
	var d_min := d
	for n in get_tree().get_nodes_in_group(GRUPPE):
		if n == self or not n.active:
			continue
		var s2: Skeleton3D = n.get_skeleton()
		if s2 != null and s2.is_inside_tree():
			d_min = minf(d_min, c.distance_to(s2.global_position))
	return sicht_ziel(d, d_min)


## nach Angriff, Abwehr, Ausweichen, Treffer: Züge kurz hintereinander steigern sich (0,6 auf 0,6 gibt 0,84), jeder hält sie HALTEN_S oben
func anstrengen(wie_sehr := 1.0) -> void:
	var w := clampf(wie_sehr, 0.0, 1.0)
	if not kampf:
		anstrengung = maxf(anstrengung, w)
		return
	anstrengung = clampf(anstrengung + w * (1.0 - anstrengung), 0.0, 1.0)
	halten = HALTEN_S


static func welle(p: float) -> float:
	if p < EIN_ANTEIL:
		return 0.5 - 0.5 * cos(PI * p / EIN_ANTEIL)
	return 0.5 + 0.5 * cos(PI * (p - EIN_ANTEIL) / (1.0 - EIN_ANTEIL))


func schritt(dt: float) -> void:
	var dauer := takt * (1.0 - (SCHNELLER_KAMPF if kampf else SCHNELLER) * anstrengung)
	phase = fposmod(phase + dt / dauer, 1.0)
	var ab := dt
	if halten > 0.0:
		ab = maxf(0.0, dt - halten)
		halten = maxf(0.0, halten - dt)
	anstrengung *= exp(-ab / ABKLINGEN_S)
	var ziel := 1.0 + (TIEFER_KAMPF if kampf else TIEFER) * anstrengung
	tief_glatt = ziel if not kampf else lerpf(tief_glatt, ziel, 1.0 - exp(-dt / TIEF_S))


func _process_modification_with_delta(delta: float) -> void:
	var sk := get_skeleton()
	if sk == null:
		return
	var dt := maxf(delta, 0.0)
	schritt(dt)
	if _idx.is_empty():
		for k in KNOCHEN:
			_idx.append(sk.find_bone(k[0]))
	if ausgleich:
		sicht = lerpf(sicht, _sicht_jetzt(sk), 1.0 - exp(-dt / SICHT_S))
	var ol := sk.find_bone("upperarm_l")
	var orr := sk.find_bone("upperarm_r")
	if ol < 0 or orr < 0:
		return
	if not _netz_mi.is_empty():
		_netz_messen(sk, [ol, orr])
		_netz_mi = []
	var tief := minf(tief_glatt * sicht * netz, TIEF_MAX)
	tiefe = welle(phase) * tief
	if tiefe < 0.0005:
		return
	_drehe(sk, tiefe, ol, orr)


## die Schicht auf die Pose: Brust, Schlüsselbeine, Hals, Kopf um [t] (Einatmung mal Tiefe)
func _drehe(sk: Skeleton3D, t: float, ol: int, orr: int) -> void:
	# Achsen im Raum des Skeletts: oben aus der Welt, links aus den Oberarmen (der Rumpf kann gedreht sein), vorn daraus
	var oben: Vector3 = (sk.global_basis.inverse() * Vector3.UP).normalized()
	var links: Vector3 = sk.get_bone_global_pose(ol).origin - sk.get_bone_global_pose(orr).origin
	links = (links - oben * links.dot(oben)).normalized()
	var vorn := links.cross(oben).normalized()
	for i in KNOCHEN.size():
		var b: int = _idx[i]
		if b < 0:
			continue
		var art: String = KNOCHEN[i][1]
		var grad: float = KNOCHEN[i][2] * t
		var g := sk.get_bone_global_pose(b)
		var r: Basis
		if art == "zurück":
			r = Basis(links, -deg_to_rad(grad))     # + um die linke Achse kippt nach vorn, also zurück mit −
		elif art == "heben":
			r = Basis(vorn, deg_to_rad(grad) * (1.0 if KNOCHEN[i][0].ends_with("_l") else -1.0))
		else:
			r = Basis(links, -deg_to_rad(grad))     # negative Grad: wieder nach vorn
		g.basis = r * g.basis
		sk.set_bone_global_pose(b, g)


## Haut im Umkreis NETZ_R über beiden Schultergelenken: wie weit hebt sie sich bei voller Einatmung (in Ruhe, ohne Ausgleich)
## gegen dieselben Punkte fest am Schlüsselbein? Haut auf dem Rechner nachgerechnet (Knochenpose * Bindung * Punkt, gewichtet, wie tests/atem_bild_453.gd);
## danach die Pose zurück, wie sie vor der Messung war
func _netz_messen(sk: Skeleton3D, gelenke: Array) -> void:
	var n := sk.get_bone_count()
	var vor := []
	for b in n:
		vor.append(sk.get_bone_global_pose(b))
	_drehe(sk, 1.0, gelenke[0], gelenke[1])
	var nach := []
	for b in n:
		nach.append(sk.get_bone_global_pose(b))
	for i in KNOCHEN.size():
		if _idx[i] >= 0:
			sk.set_bone_global_pose(_idx[i], vor[_idx[i]])
	var gt := sk.global_transform
	var g_ort := []
	var fest := []     # je Seite: Bewegung des Schlüsselbeins im Raum der Welt
	for k in 2:
		g_ort.append(gt * (vor[gelenke[k]] as Transform3D).origin)
		var c: int = _idx[2 + k]     # KNOCHEN: clavicle_l, clavicle_r
		if c < 0:
			return
		fest.append(gt * (nach[c] as Transform3D) * (vor[c] as Transform3D).affine_inverse() * gt.affine_inverse())
	var summe := 0.0
	var summe_fest := 0.0
	var zahl := 0
	for mi in _netz_mi:
		var skin: Skin = mi.skin
		var bind := []
		for i in skin.get_bind_count():
			var bn := skin.get_bind_bone(i)
			if bn < 0:
				bn = sk.find_bone(skin.get_bind_name(i))
			bind.append([bn, skin.get_bind_pose(i)])
		for f in mi.mesh.get_surface_count():
			var arr: Array = mi.mesh.surface_get_arrays(f)
			var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
			if arr[Mesh.ARRAY_BONES] == null or vs.is_empty():
				continue
			var bo = arr[Mesh.ARRAY_BONES]
			var we = arr[Mesh.ARRAY_WEIGHTS]
			var je: int = bo.size() / vs.size()
			for v in vs.size():
				var p0 := Vector3()
				for j in je:
					var w: float = we[v * je + j]
					if w > 0.0 and bo[v * je + j] < bind.size() and bind[bo[v * je + j]][0] >= 0:
						var bi: Array = bind[bo[v * je + j]]
						p0 += w * ((vor[bi[0]] as Transform3D) * ((bi[1] as Transform3D) * vs[v]))
				p0 = gt * p0
				var seite := -1
				for k in 2:
					if p0.distance_to(g_ort[k]) < NETZ_R and p0.y > (g_ort[k] as Vector3).y - 0.03:
						seite = k
				if seite < 0:
					continue
				var p1 := Vector3()
				for j in je:
					var w: float = we[v * je + j]
					if w > 0.0 and bo[v * je + j] < bind.size() and bind[bo[v * je + j]][0] >= 0:
						var bi: Array = bind[bo[v * je + j]]
						p1 += w * ((nach[bi[0]] as Transform3D) * ((bi[1] as Transform3D) * vs[v]))
				summe += (gt * p1).y - p0.y
				summe_fest += ((fest[seite] as Transform3D) * p0).y - p0.y
				zahl += 1
	if zahl == 0 or summe_fest <= 0.0:
		return
	netz_roh = summe_fest / maxf(summe, 0.0001 * zahl)
	netz = clampf(netz_roh, 1.0, NETZ_MAX)
	print("Atem 453.1 Netz: %d Punkte, Haut %.1f mm, fest am Schlüsselbein %.1f mm, Ausgleich %.2f" % [zahl, summe / zahl * 1000.0,
		summe_fest / zahl * 1000.0, netz])
