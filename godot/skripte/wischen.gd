extends Node
# 571 (Chef 04.11., 20:13, Build 257: „dass ich auf den Schaltflächen sozusagen drücke und dann nach oben unten wischen kann … Ganz
# wichtig“): ein Baustein fuer alle Schirme statt je Schirm. Wie alt (Compose rollt ueber Knoepfen): ein Knopf in einer rollenden
# Liste laesst den Finger zur Liste durch (MOUSE_FILTER_PASS); der ScrollContainer rollt ab seiner Totzone und bricht den Druck
# auf den Knopf ab (Godot NOTIFICATION_SCROLL_BEGIN), Tippen waehlt weiter; langes Druecken ohne Bewegung bleibt beim Knopf
# (zeichenknopf.gd bricht beim Rollen selbst ab). Gilt fuer jedes Control, das unter einem ScrollContainer in den Baum kommt,
# ausser Eingabefeldern, Schiebern, eigenen Rollen und Kaesten, die das Tippen absichtlich halten (Rueckfrage.halte, Schleier).

const TOTZONE_DP := 10.0   # Chef 04.11.: ab etwa 10 dp Bewegung rollt die Liste, der Knopf loest nicht aus

func _enter_tree() -> void:
	get_tree().node_added.connect(_neu)
	get_tree().node_added.connect(_rolle)

func _rolle(n: Node) -> void:
	if n is ScrollContainer: (n as ScrollContainer).scroll_deadzone = int(TOTZONE_DP * AktionsKnopf.DP)

static func halten(c: Control) -> bool:
	return c is LineEdit or c is TextEdit or c is Range or c is ScrollContainer or c is ColorRect or c.has_meta("haelt")

func _neu(n: Node) -> void:
	var c := n as Control
	if c == null or c.mouse_filter != Control.MOUSE_FILTER_STOP or halten(c): return
	var p := c.get_parent()
	while p != null:
		if p is ScrollContainer: break
		if p is Control and (p as Control).has_meta("haelt"): return   # ein Fenster in einer Liste haelt seine Knoepfe selbst
		if not (p is Control): return
		p = p.get_parent()
	if p == null: return
	c.mouse_filter = Control.MOUSE_FILTER_PASS
