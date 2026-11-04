# 453.1 Feld 2 (Chef 02.11., 11:07: „dass Atmen sich bei Angriff und Verteidigung steigert und dann wieder normalisiert … einen Tick
# schneller“): die Rechnung der Atemschicht (atem.gd) ohne Modell, läuft auch ohne Kaufdateien.
#  - Kampfort-Ruhe schneller als unterwegs (RUHE_KAMPF_S unter RUHE_S), unterwegs unverändert 4,3 s
#  - nach einem Hieb: 2 s lang voll oben (Atemzug höchstens 0,55 der Ruhe, Tiefe mindestens 2,2-mal), nach 9 s wieder fast Ruhe
#  - zwei Züge kurz hintereinander steigern sich (Abwehr 0,6 nach Angriff 0,6 gibt mehr als 0,6)
#  - die Tiefe springt nicht: von Bild zu Bild höchstens 0,15 mehr
#  - unterwegs (Gebiet.atem_an, held.gd) rechnet es wie bisher
# Run: godot --headless --path godot -s res://tests/atem_rechnung_4531.gd   (exit code 0 = alles richtig)
extends SceneTree

const Atem = preload("res://kampf/atem.gd")
var fails := 0


func _check(ok: bool, what: String) -> void:
	print(("ok     " if ok else "FEHLER ") + what)
	if not ok:
		fails += 1


func _initialize() -> void:
	var dt := 1.0 / 30.0
	var a = Atem.new()
	a.eigen(7)
	var b = Atem.new()
	b.eigen_kampf(7)
	_check(absf(Atem.RUHE_S - 4.3) < 0.001, "unterwegs Ruhe wie bisher (%.2f s)" % Atem.RUHE_S)
	_check(b.takt < a.takt * 0.9 and b.takt > a.takt * 0.75, "im Kampfort Ruhe schneller: %.2f s statt %.2f s" % [b.takt, a.takt])
	# nach einem Hieb
	b.anstrengen(1.0)
	var t := 0.0
	var tief_max := 0.0
	var sprung := 0.0
	var vorher: float = b.tief_glatt
	var bei2 := 0.0
	var bei9 := 0.0
	while t < 10.0:
		b.schritt(dt)
		t += dt
		sprung = maxf(sprung, b.tief_glatt - vorher)
		vorher = b.tief_glatt
		tief_max = maxf(tief_max, b.tief_glatt)
		if absf(t - 2.0) < dt / 2.0:
			bei2 = b.anstrengung
		if absf(t - 9.0) < dt / 2.0:
			bei9 = b.anstrengung
	var dauer_voll: float = 1.0 - Atem.SCHNELLER_KAMPF * 1.0
	print("Anstrengung nach 2 s %.2f, nach 9 s %.2f; Tiefe höchstens %.2f; größter Sprung je Bild %.3f" % [bei2, bei9, tief_max, sprung])
	_check(bei2 > 0.95, "2 s nach dem Hieb noch voll angestrengt (%.2f)" % bei2)
	_check(dauer_voll <= 0.55, "voll angestrengt Atemzug %.2f der Ruhe" % dauer_voll)
	_check(tief_max >= 2.2, "voll angestrengt mindestens 2,2-mal so tief (%.2f)" % tief_max)
	_check(bei9 < 0.1, "nach 9 s wieder fast Ruhe (%.2f)" % bei9)
	_check(sprung <= 0.15, "die Tiefe springt nicht (%.3f je Bild)" % sprung)
	# Steigerung: Angriff 0,6, dann Abwehr 0,6
	var c = Atem.new()
	c.eigen_kampf(9)
	c.anstrengen(0.6)
	for i in 15:
		c.schritt(dt)
	c.anstrengen(0.6)
	_check(c.anstrengung > 0.8, "zwei Züge steigern sich (%.2f nach 0,6 und 0,6)" % c.anstrengung)
	# unterwegs wie bisher: held.gd ruft beim Gehen je Bild anstrengen(klein); das darf sich nicht aufschaukeln
	var u = Atem.new()
	u.eigen(11)
	for i in 90:
		u.anstrengen(0.2)
		u.schritt(dt)
	_check(not u.kampf and absf(u.anstrengung - 0.2) < 0.02, "unterwegs Gehen bleibt bei seiner Anstrengung (%.2f)" % u.anstrengung)
	for n in [a, b, c, u]:
		n.free()
	print("Atemrechnung 453.1: %d Fehler" % fails)
	quit(1 if fails > 0 else 0)
