extends SceneTree
# 867 ohne Bild (Chef 12.11., 21:55 „dunkelhaariges Jägerkind“; Sokrates: Haarfarbe der Vorgaben beim Namen): keine Herkunftsvorgabe
# ergibt in irgendeinem Volk Grau oder Weißgrau; Jaegerkind dunkel, Zauberlehrling schwarz; die vier Helden des Hauptmenues je mit
# eigener Haltung und Drehung. Massgeblich ist die Zeile MENUEHELDEN867.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		print("FEHLER " + was)
		fehler += 1

func _initialize() -> void:
	var grau := ["Grau", "Weißgrau"]
	var hell := grau + ["Blond", "Silberblond"]
	for k in HeldFigur.HERKUNFT_VORGABE:
		for v in HeldFigur.VOLK_MODELL.values():
			for g in HeldFigur.GESCHLECHTER:
				var a := HeldFigur.vorgabe(k, g, v)
				var l := HeldFigur.toene_liste(v, "haar")
				var n := String(l[int(a["haarfarbe"])]["name"]["de"]) if int(a["haarfarbe"]) < l.size() else "?"
				pruefe(n not in grau, "%s %s %s: Haar %s" % [k, v, g, n])
				if k == "JAEGERKIND": pruefe(n in ["Schwarz", "Dunkelbraun"], "Jägerkind %s %s: Haar %s, nicht dunkelbraun bis schwarz (Sokrates 23:13)" % [v, g, n])
				if k == "ZAUBERLEHRLING": pruefe(n == "Schwarz", "Zauberlehrling %s %s: Haar %s statt Schwarz" % [v, g, n])
	var haltungen := {}
	for h in HauptmenueHelden.HELDEN:
		haltungen[String(h["haltung"])] = true
		pruefe(absf(float(h["dreh"])) >= (25.0 if absf(float(h["x"])) > 1.0 else 20.0), "%s: aussen 25 bis 35 Grad, innen ab 20 Grad zur Mitte (Sokrates 13.11., 00:25: alle im Bogen)" % h["herkunft"])
		pruefe(absf(float(h["dreh"])) <= 35.0 and signf(float(h["dreh"])) == -signf(float(h["x"])), "%s: zur Mitte gedreht" % h["herkunft"])
	pruefe(haltungen.size() == HauptmenueHelden.HELDEN.size(), "jede Haltung nur einmal")
	pruefe(HauptmenueHelden.HELDEN.any(func(h): return h.get("stuetzen", false) and h["herkunft"] == "Wachsoldat"), "Wachsoldatin stuetzt die Haende auf das Schwert (Sokrates 13.11., 00:25)")
	print("MENUEHELDEN867 %d Fehler" % fehler)
	quit(1 if fehler else 0)
