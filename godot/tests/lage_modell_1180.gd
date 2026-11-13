extends SceneTree
# 1180 (D209.2 Diogenes, Lauf 209): eine Lage mit probe=<Gruppe> ist nur herstellbar, wenn die Gruppe im Reiter Probekampf waehlbar ist
# (jede Figur mit Modell, Testmodus.gruppe_da); vorher nahm lage_fehler alle Gruppen an und der Kampf zeigte ein falsches Monster.
# Massgeblich ist die Zeile LAGEMODELL1180.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void:
	_lauf.call_deferred()

func _lauf() -> void:
	var alle: Dictionary = Testmodus.feinde(true)
	pruefe(not alle.is_empty(), "Gruppen des Probekampfs geladen (%d)" % alle.size())
	var mit := 0
	for g in alle:
		var da := Testmodus.gruppe_da(String(g))
		var f: Array = Testmodus.lage_fehler({"probe": g})
		if da: mit += 1
		pruefe(f.is_empty() == da, "probe=%s: %s, Lage %s" % [g, "Modell da" if da else "ohne Modell", "herstellbar" if f.is_empty() else "nicht herstellbar (%s)" % ", ".join(PackedStringArray(f))])
	print("1180 Gruppen mit Modell %d von %d" % [mit, alle.size()])
	pruefe(not Testmodus.lage_fehler({"probe": "GIBTESNICHT"}).is_empty(), "unbekannte Gruppe bleibt ein Fehler")
	print("LAGEMODELL1180 " + ("gut" if fehler == 0 else "FEHLER %d" % fehler))
	quit(1 if fehler else 0)
