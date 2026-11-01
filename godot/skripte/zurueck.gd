class_name Zurueck
extends RefCounted
# 416.1 (Hinweis Team Jerry 31.10., 21:4x): die Zurueck-Taste oder -Geste von Android beendete das Spiel (Godot-Vorgabe
# quit_on_go_back), statt das oberste Fenster zu schliessen. Wie alt (BackHandler je Schirm): jedes Fenster meldet sich mit dem,
# was sein „Zurück“, „Schließen“ oder „Abbrechen“ tut; die Taste tut das des obersten (zuletzt im Baum, sichtbar). Ohne Fenster
# (Welt, Kampf) tut sie nichts. spiel.gd ruft taste() bei NOTIFICATION_WM_GO_BACK_REQUEST.

const GRUPPE := "zurueck_taste"

static func melde(n: Node, tat: Callable) -> void:
	n.add_to_group(GRUPPE)
	n.set_meta("zurueck", tat)

# true: ein Fenster hat die Taste genommen
static func taste(baum: SceneTree) -> bool:
	var oben: Node = null
	for n in baum.get_nodes_in_group(GRUPPE):
		if n.is_queued_for_deletion() or not n.is_inside_tree(): continue
		if n is CanvasItem and not (n as CanvasItem).is_visible_in_tree(): continue
		if oben == null or oben.is_ancestor_of(n) or _spaeter(n, oben): oben = n
	if oben == null: return false
	(oben.get_meta("zurueck") as Callable).call()
	return true

# n liegt im Baum nach a (a kein Vorfahr von n): gemeinsamer Vorfahr, dann die Reihenfolge der Zweige
static func _spaeter(n: Node, a: Node) -> bool:
	if n.is_ancestor_of(a): return false
	var pn := n
	while pn.get_parent() and not pn.get_parent().is_ancestor_of(a): pn = pn.get_parent()
	var pa := a
	while pa.get_parent() != pn.get_parent(): pa = pa.get_parent()
	return pn.get_index() > pa.get_index()
