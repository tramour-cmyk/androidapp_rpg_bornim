extends SceneTree
# 514 ohne Bild: Gluehwuermchen wie alt (WorldScreen.kt Fireflies). Schwaerme im Dorf und im Wald, im tiefen Wald duenner, keine Mitte
# auf einem Weg, keine im Grundriss; zwei von fuenf Naechten; Leuchten zwischen 0 und 1, meist dunkel; die Fliege bleibt nahe ihrer
# Stelle; Mitten wie alt (Hash 32 Bit, Pruefwerte aus Python mit Kotlin-Ganzzahlen). Braucht nur daten/karten.json. Zeile GLUEH514.

var fehler := 0
const HASH_A := 346735986       # Java/Kotlin Int (jshell), Python mit 32 Bit: gleich
const HASH_B := 1723646771
const HASH_C := 337126599
const MITTEN_WALD := "7,1,13,1,4,2,3,6"   # die ersten vier Schwaerme im Flüsterwald nach Fireflies.of (Python aus Story.kt)

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	# Pruefwerte: hash(3, 14, 88), hash(-7, 2), hash(123456, 654321, 90) wie WorldScreen.hash (Kotlin Int)
	pruefe(Gluehwuermchen.hash3(3, 14, 88) == HASH_A, "hash(3, 14, 88) = %d (alt %d)" % [Gluehwuermchen.hash3(3, 14, 88), HASH_A])
	pruefe(Gluehwuermchen.hash3(-7, 2) == HASH_B, "hash(-7, 2) = %d (alt %d)" % [Gluehwuermchen.hash3(-7, 2), HASH_B])
	pruefe(Gluehwuermchen.hash3(123456, 654321, 90) == HASH_C, "hash(123456, 654321, 90) = %d (alt %d)" % [Gluehwuermchen.hash3(123456, 654321, 90), HASH_C])
	var n := 0
	for tag in range(1, 101): if Gluehwuermchen.heute(tag, 22 * 60): n += 1
	pruefe(n > 25 and n < 55, "in etwa zwei von fuenf Naechten: %d von 100" % n)
	pruefe(Gluehwuermchen.heute(5, 23 * 60) == Gluehwuermchen.heute(6, 2 * 60), "die Nacht gehoert zum Tag, an dem sie begann")
	var zahl := {}
	for id in ["village", "forest", "deep_forest", "inn", "cave"]:
		var k := Karte.lade(id)
		if k == null: continue
		var f := Gluehwuermchen.schwaerme(k)
		zahl[id] = f.size()
		var auf_weg := 0
		for x in f:
			if k.zeichen(x["mitte"]) in ["=", "o"]: auf_weg += 1
		print("%s: %d Gluehwuermchen, %d ueber Wegen, Karte %d x %d" % [id, f.size(), auf_weg, k.breite, k.hoehe])
		if id in ["village", "forest"]: pruefe(f.size() >= 6, "%s hat Gluehwuermchen: %d" % [id, f.size()])
		if id in ["inn", "cave"]: pruefe(f.is_empty(), "%s (Grundriss, Hoehle) ohne" % id)
		if id == "forest":
			pruefe(_mitten(f) == MITTEN_WALD, "Wald: Mitten wie alt %s" % _mitten(f))
			pruefe(f.size() == 80, "Wald: 80 Fliegen in 16 Schwaermen wie alt: %d" % f.size())
	if zahl.has("deep_forest") and zahl.has("forest"):
		var kf := Karte.lade("forest"); var kd := Karte.lade("deep_forest")
		pruefe(zahl["deep_forest"] / float(kd.breite * kd.hoehe) < zahl["forest"] / float(kf.breite * kf.hoehe), "tiefer Wald duenner als der Flüsterwald")
	var f0: Dictionary = Gluehwuermchen.schwaerme(Karte.lade("forest"))[0]
	var hell := 0; var weit := 0.0; var bad := false
	for ms in range(0, 120000, 50):
		var g := Gluehwuermchen.glanz(f0, ms)
		if g < 0.0 or g > 1.0: bad = true
		if g > 0.02: hell += 1
		var o := Gluehwuermchen.ort(f0, ms)
		weit = maxf(weit, Vector2(o.x - float(f0["cx"]), o.z - float(f0["cy"])).length())
	pruefe(not bad and hell > 50 and hell < 1200, "Leuchten 0..1, meist dunkel: %d von 2400 hell" % hell)
	pruefe(weit < 30.0 * float(f0["spread"]), "bleibt nahe der Stelle: %.1f px (Streuung %.2f)" % [weit, float(f0["spread"])])
	print("GLUEH514 %d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)

func _mitten(f: Array) -> String:
	var m := {}
	for x in f: m["%d,%d" % [x["mitte"].x, x["mitte"].y]] = true
	return ",".join(m.keys().slice(0, 4))
