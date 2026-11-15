extends SceneTree
# 785.21 (Abgleich alt): Android-Zurück wie alt. Hauptmenü: die Taste gehört dem Hauptmenü (es verlässt das Spiel, App-Vorgabe alt);
# Spielstände darüber nehmen sie zuerst (zurück ins Hauptmenü); Erschaffung aus den Spielständen: die Taste führt zu den
# Spielständen zurück (CreateScreen.kt 74), aus dem Hauptmenü geöffnet ins Hauptmenü. In der Welt öffnet sie ohne Fenster das Menü
# (WorldScreen.kt 139, spiel.gd). Ohne Bild, ohne Kaufmodelle. Maßgeblich ist die Zeile ZURUECK78521.

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func oben() -> Node:
	var o: Node = null
	for n in get_nodes_in_group(Zurueck.GRUPPE):
		if n.is_queued_for_deletion() or not n.is_inside_tree(): continue
		if n is CanvasItem and not (n as CanvasItem).is_visible_in_tree(): continue
		if o == null or o.is_ancestor_of(n) or Zurueck._spaeter(n, o): o = n
	return o

func _lauf() -> void:
	Sprache.lade()
	Hauptmenue.vorspann_gezeigt = true
	var hm := Hauptmenue.new(null)
	root.add_child(hm)
	for i in 6: await process_frame
	pruefe(oben() == hm, "Hauptmenü: die Taste gehört dem Hauptmenü (verlässt das Spiel), oben %s" % str(oben()))
	hm.spielstaende()
	for i in 3: await process_frame
	var s := oben()
	pruefe(s is Spielstaende, "Spielstände: die Taste nehmen sie (%s)" % str(s))
	(s as Spielstaende).neu.emit(2)
	for i in 3: await process_frame
	pruefe(oben() is ErschaffungBrs, "Erschaffung aus den Spielständen oben (%s)" % str(oben()))
	pruefe(Zurueck.taste(self), "Erschaffung nimmt die Taste")
	for i in 3: await process_frame
	pruefe(oben() is Spielstaende, "Zurück aus der Erschaffung führt zu den Spielständen (%s)" % str(oben()))
	pruefe(Zurueck.taste(self), "Spielstände nehmen die Taste")
	for i in 3: await process_frame
	pruefe(oben() == hm, "Zurück aus den Spielständen ins Hauptmenü (%s)" % str(oben()))
	hm.erschaffung(0)
	for i in 3: await process_frame
	pruefe(oben() is ErschaffungBrs and Zurueck.taste(self), "Erschaffung aus dem Hauptmenü nimmt die Taste")
	for i in 3: await process_frame
	pruefe(oben() == hm, "… und führt ins Hauptmenü (%s)" % str(oben()))
	# Welt: spiel.gd öffnet ohne Fenster das Menü (Quelle, da die Welt hier nicht läuft)
	var q := FileAccess.get_file_as_string("res://skripte/spiel.gd")
	pruefe(q.contains("NOTIFICATION_WM_GO_BACK_REQUEST and not Zurueck.taste(get_tree()) and held and karte: oeffne_menue()"), "Welt: ohne Fenster öffnet die Taste das Menü")
	print("ZURUECK78521 %d Fehler" % fehler)
	quit(1 if fehler else 0)
