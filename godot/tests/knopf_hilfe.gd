extends RefCounted
# 630 (549a): Knoepfe ohne Kasten (Spielstaende.knopf, Woerter _seite_b, − und +) und alte Button gleich finden, lesen und antippen.
# In Tests: const KH := preload("res://tests/knopf_hilfe.gd")

# alle antippbaren Flaechen unter [n]: Button und PanelContainer, die Tippen annehmen und Text tragen
static func alle(n: Node, aus: Array = []) -> Array:
	if n is Button: aus.append(n)
	elif n is PanelContainer and (n as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE and text(n as Control) != "": aus.append(n)
	for c in n.get_children(): alle(c, aus)
	return aus

# Aufschrift: Button.text, sonst der erste Label darin („Text“ beim Knopf)
static func text(c: Control) -> String:
	if c is Button: return (c as Button).text
	var l := c.find_child("Text", true, false) as Label
	if l == null:
		var ls := c.find_children("*", "Label", true, false)
		if ls.is_empty(): return ""
		l = ls[0]
	return l.text

static func texte(n: Node) -> PackedStringArray:
	return PackedStringArray(alle(n).map(func(c): return text(c)))

# erste Flaeche, deren Aufschrift [t] ist (gross/klein egal; [anfang]: beginnt damit)
static func finde(n: Node, t: String, anfang := false) -> Control:
	var s := t.to_upper().replace("ß", "SS")
	for c in alle(n):
		var x := text(c).to_upper().replace("ß", "SS")
		if x == s or (anfang and x.begins_with(s)): return c
	return null

static func an(c: Control) -> bool:
	if c is Button: return not (c as Button).disabled
	return bool(c.get_meta("an", true))

static func gewaehlt(c: Control) -> bool:
	if c is Button: return (c as Button).get_theme_color("font_color") == Stil.BRIGHT
	return bool(c.get_meta("gewaehlt", false))

# antippen wie ein Finger: Button.pressed, sonst linke Maustaste druecken und in der Mitte loslassen (Spielstaende.tippbar)
static func tippe(c: Control) -> void:
	if c is Button:
		(c as Button).pressed.emit()
		return
	for gedrueckt in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = gedrueckt
		e.position = c.size / 2.0
		e.global_position = c.get_global_rect().get_center()
		c.gui_input.emit(e)
