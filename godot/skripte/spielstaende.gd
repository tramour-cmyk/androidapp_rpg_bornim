class_name Spielstaende
extends Control
# 399.1 Spielstaende wie im alten Spiel (SlotsScreen.kt, Chef 28.10., 14:38 „Einfach mal das alte Spiel nehmen“): oben der Kopf
# „Spielstaende“, darunter rollend die vier Plaetze: belegt mit Name, Volk, Klasse, Stufe, Ort, Tag und Uhrzeit, wann gespeichert,
# „Loeschen“ (mit Rueckfrage) und „Laden“; leer mit „Neues Spiel“ in diesen Platz; unten „Zurueck“. Noch nicht wie alt: das
# Bild des Helden und die Spielzeit (Hero still, PlayClock).

signal zurueck
signal laden(platz: int)
signal neu(platz: int)

const DP := AktionsKnopf.DP

var liste: VBoxContainer

func _init() -> void:
	name = "Spielstaende"

func _ready() -> void:
	Zurueck.melde(self, func(): zurueck.emit())   # 416.1: Android-Zurück wie „Zurück“
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var de := Sprache.aktiv() == "de"
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var rand := MarginContainer.new()
	rand.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["left", "right", "top", "bottom"]: rand.add_theme_constant_override("margin_" + s, int(12 * DP))
	add_child(rand)
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", int(10 * DP))
	rand.add_child(spalte)
	var kopf := Stil.zeile(("Spielstände" if de else "Saved games").to_upper(), 12, Stil.BRIGHT, 3.0)   # VeilHead in Veil.bright
	spalte.add_child(Erschaffung.kasten(kopf))
	var rolle := ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	rolle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spalte.add_child(rolle)
	liste = VBoxContainer.new()
	liste.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	liste.add_theme_constant_override("separation", int(10 * DP))
	rolle.add_child(liste)
	spalte.add_child(Erschaffung.knopf(Sprache.u("back"), func(): zurueck.emit()))   # BackRow
	baue()

func baue() -> void:
	var de := Sprache.aktiv() == "de"
	for c in liste.get_children():
		liste.remove_child(c)
		c.queue_free()
	for d in Spielstand.liste():
		var n: int = liste.get_child_count() + 1
		if d.is_empty():
			var v := VBoxContainer.new()
			v.add_theme_constant_override("separation", 0)
			v.add_child(Erschaffung.txt(("Platz %d · leer" if de else "Slot %d · empty") % n, 17, Stil.DIM))
			v.add_child(Erschaffung.luecke(8))
			v.add_child(Erschaffung.knopf(Sprache.u("newGame"), func(): neu.emit(n)))
			liste.add_child(Erschaffung.kasten(v))
			continue
		var k := karte(d)
		var knoepfe := HBoxContainer.new()
		knoepfe.add_theme_constant_override("separation", int(8 * DP))
		var weg := Erschaffung.knopf("Löschen" if de else "Delete", func(): frage_loeschen(d))
		var los := Erschaffung.knopf("Laden" if de else "Load", func(): laden.emit(n))
		los.size_flags_stretch_ratio = 2.0
		knoepfe.add_child(weg)
		knoepfe.add_child(los)
		var innen: VBoxContainer = k.get_child(0)
		innen.add_child(Erschaffung.luecke(8))
		innen.add_child(knoepfe)
		liste.add_child(k)

# SlotCard ohne Bild: Platz und Name, Volk · Klasse · Stufe, Ort · Tag · Uhrzeit, gespeichert am
static func karte(d: Dictionary) -> PanelContainer:
	var de := Sprache.aktiv() == "de"
	var h: Dictionary = d.get("held", {})
	var z: Dictionary = d.get("zustand", {})
	var hd := Heldwerte.lade()
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	var n := Stil.zeile((("Platz %d · " if de else "Slot %d · ") % int(d["platz"]) + String(h.get("name", ""))).to_upper(), 14, Stil.GOLD, 3.0)   # MenuHead
	n.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	v.add_child(n)
	var volk := String(h.get("volk", "HUMAN"))
	var klasse := String(h.get("klasse", "FIGHTER"))
	v.add_child(Erschaffung.txt("%s · %s · %s %d" % [Sprache.t(hd["voelker"][volk]["name"]) if hd["voelker"].has(volk) else volk,
		Sprache.t(hd["klassen"][klasse]["name"]) if hd["klassen"].has(klasse) else klasse, Sprache.u("level"), int(h.get("stufe", 1))], 14))
	var ort := String(d.get("ort", {}).get("karte", ""))
	var alle = JSON.parse_string(FileAccess.get_file_as_string("res://daten/karten.json")) if FileAccess.file_exists("res://daten/karten.json") else null
	if alle is Dictionary and alle["karten"].has(ort): ort = Sprache.t(alle["karten"][ort]["name"])
	var m := int(z.get("minuten", 0))
	v.add_child(Erschaffung.txt("%s · %s %d · %02d:%02d" % [ort, "Tag" if de else "Day", int(z.get("tag", 1)), m / 60, m % 60], 13, Stil.DIM))
	var wann := int(d.get("gespeichert", 0))
	if wann > 0:
		var t := Time.get_datetime_dict_from_unix_time(wann / 1000 + int(Time.get_time_zone_from_system().get("bias", 0)) * 60)
		var s := ("%02d.%02d.%04d, %02d:%02d" % [t.day, t.month, t.year, t.hour, t.minute]) if de else ("%04d-%02d-%02d, %02d:%02d" % [t.year, t.month, t.day, t.hour, t.minute])
		v.add_child(Erschaffung.txt(("Gespeichert: " if de else "Saved: ") + s, 12, Stil.DIM))
	return Erschaffung.kasten(v)

# ConfirmDialog: „Spielstand löschen?“, wer wird geloescht, Abbrechen und Loeschen
func frage_loeschen(d: Dictionary) -> void:
	var de := Sprache.aktiv() == "de"
	var h: Dictionary = d.get("held", {})
	var schleier := ColorRect.new()
	schleier.color = Color(0, 0, 0, 0.82)
	schleier.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(schleier)
	var mitte := CenterContainer.new()
	mitte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	schleier.add_child(mitte)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(10 * DP))
	v.custom_minimum_size.x = get_viewport_rect().size.x - 48 * DP
	var k := Erschaffung.kasten(v)
	mitte.add_child(k)
	v.add_child(Stil.zeile(("Spielstand löschen?" if de else "Delete saved game?").to_upper(), 14, Stil.GOLD, 3.0))
	var t := Erschaffung.txt(("%s (Stufe %d) wird endgültig gelöscht." if de else "%s (level %d) will be deleted for good.") % [String(h.get("name", "")), int(h.get("stufe", 1))], 15)
	v.add_child(t)
	var knoepfe := HBoxContainer.new()
	knoepfe.add_theme_constant_override("separation", int(8 * DP))
	knoepfe.add_child(Erschaffung.knopf("Abbrechen" if de else "Cancel", func(): schleier.queue_free()))
	knoepfe.add_child(Erschaffung.knopf("Löschen" if de else "Delete", func():
		Spielstand.loesche(int(d["platz"]))
		schleier.queue_free()
		baue()))
	v.add_child(knoepfe)
