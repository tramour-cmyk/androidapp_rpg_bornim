# 453.1 (Chef 01.11., 13:0x, beim Film 406: „dass unsere Helden unsere zwei immer gleich atmen. Die können ruhig mal langsamer
# atmen oder nicht so heftig … nach einer Abwehr ein bisschen schneller und dann wieder ruhiger oder nach einem Angriff schneller und
# dann wieder ruhiger. Eine gewisse Variation“; Grundsatz Archiv 453.1: jede lebende Figur atmet immer als eigene Schicht, ruhig, je
# Figur eigener Takt, nach Anstrengung schneller und abklingend). Das Atmen als eigene Schicht über jeder Bewegung, nur auf Brust,
# Schultern und Hals: Brust hebt sich (Rumpf leicht zurück), Schlüsselbeine heben sich, Hals und Kopf gleichen den Blick aus. Die
# Grundbewegung bleibt, wie sie ist; nur ihr eigener Atem wird vorher herausgenommen (figur.gd _ohne_atem).
# Je Figur eigener Takt (± TAKT_STREU) und Versatz; anstrengen() nach Angriff, Ausweichen, Treffer: schneller und tiefer, in etwa
# 5 s zurück (ABKLINGEN_S). Einatmen kürzer als Ausatmen (EIN_ANTEIL).
extends SkeletonModifier3D

## Ruhe: ein Atemzug in Sekunden (14 je Minute; in Idle_Loop der UAL dauert er 1,25 s, 48 je Minute: „hechelt“)
const RUHE_S := 4.3
## eigener Takt je Figur: ± so viel
const TAKT_STREU := 0.15
## nach voller Anstrengung: so viel kürzer und so viel tiefer
const SCHNELLER := 0.55
const TIEFER := 0.9
## Anstrengung klingt mit dieser Zeitkonstante ab (s); nach 5 s bleibt etwa ein Siebtel, nach 6 s ein Elftel
const ABKLINGEN_S := 2.5
const EIN_ANTEIL := 0.42
## Ausschlag in Grad bei voller Einatmung in Ruhe: [Knochen, Art, Grad]; „zurück“ dreht um die Querachse (Brust hebt sich),
## „heben“ das Schlüsselbein um die Längsachse nach oben, „blick“ gleicht am Hals und Kopf den Rumpf aus (Blick bleibt)
const KNOCHEN := [["spine_02", "zurück", 0.7], ["spine_03", "zurück", 1.1], ["clavicle_l", "heben", 3.2], ["clavicle_r", "heben", 3.2],
	["neck_01", "blick", -0.6], ["Head", "blick", -0.5]]

var takt := RUHE_S
var phase := 0.0          # 0..1 im Atemzug
var anstrengung := 0.0    # 0..1
var tiefe := 0.0          # zuletzt angewandte Einatmung 0..1 mal Tiefe (Prüflauf)
var _idx := []


## Figur mit eigenem Takt und Versatz; seed fest je Figur, damit Prüfläufe gleich ausfallen
func eigen(seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	takt = RUHE_S * (1.0 + rng.randf_range(-TAKT_STREU, TAKT_STREU))
	phase = rng.randf()


func anstrengen(wie_sehr := 1.0) -> void:
	anstrengung = maxf(anstrengung, clampf(wie_sehr, 0.0, 1.0))


static func welle(p: float) -> float:
	if p < EIN_ANTEIL:
		return 0.5 - 0.5 * cos(PI * p / EIN_ANTEIL)
	return 0.5 + 0.5 * cos(PI * (p - EIN_ANTEIL) / (1.0 - EIN_ANTEIL))


func schritt(dt: float) -> void:
	var dauer := takt * (1.0 - SCHNELLER * anstrengung)
	phase = fposmod(phase + dt / dauer, 1.0)
	anstrengung *= exp(-dt / ABKLINGEN_S)


func _process_modification_with_delta(delta: float) -> void:
	var sk := get_skeleton()
	if sk == null:
		return
	var dt := maxf(delta, 0.0)
	schritt(dt)
	if _idx.is_empty():
		for k in KNOCHEN:
			_idx.append(sk.find_bone(k[0]))
	var tief := 1.0 + TIEFER * anstrengung
	tiefe = welle(phase) * tief
	if tiefe < 0.0005:
		return
	# Achsen im Raum des Skeletts: oben aus der Welt, links aus den Oberarmen (der Rumpf kann gedreht sein), vorn daraus
	var oben: Vector3 = (sk.global_basis.inverse() * Vector3.UP).normalized()
	var ol := sk.find_bone("upperarm_l")
	var orr := sk.find_bone("upperarm_r")
	if ol < 0 or orr < 0:
		return
	var links: Vector3 = sk.get_bone_global_pose(ol).origin - sk.get_bone_global_pose(orr).origin
	links = (links - oben * links.dot(oben)).normalized()
	var vorn := links.cross(oben).normalized()
	for i in KNOCHEN.size():
		var b: int = _idx[i]
		if b < 0:
			continue
		var art: String = KNOCHEN[i][1]
		var grad: float = KNOCHEN[i][2] * tiefe
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
