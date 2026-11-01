class_name BrettSchirm
extends Control
# 416.3 (Chef 31.10., Build 143: Anschlagbrett nur etwa drei Viertel des Schirms; „bildschirmfüllend, Design mit der alten Fassung
# abgleichen“): wie BoardScreen.kt auf Schwarz, ganzer Schirm. Oben im Kasten „Anschlagbrett“ in Gold; darunter rollend je Aushang
# ein Kasten mit Titel, Text, Lohn (matt) und „Annehmen“ (angenommen: matt „Angenommen“); ohne Aushang die Naegel; unten „Zurück“.
# Was getippt wird, meldet wahl(id) wie bisher die Auswahl: "nimm:<Auftrag>" oder "" (zurueck); spiel.gd _brett_wahl tut es.

signal wahl(id: String)
const DP := AktionsKnopf.DP

var z: Zustand
var liste: VBoxContainer
var rolle: ScrollContainer

func _init(zu_: Zustand) -> void:
	z = zu_
	name = "Brett"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Rand.ruecke(self, Rand.oben(get_viewport()))   # 399.4: unter der Kamera des Handys
	Zurueck.melde(self, func(): wahl.emit(""))   # 416.1: wie „Zurück“
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var rand := MarginContainer.new()
	rand.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["left", "right", "top", "bottom"]: rand.add_theme_constant_override("margin_" + s, int(10 * DP))
	add_child(rand)
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", int(8 * DP))
	rand.add_child(spalte)
	var de := Sprache.aktiv() == "de"
	var kopf := Stil.zeile(("Anschlagbrett" if de else "Notice board").to_upper(), 17, Stil.GOLD, 3.0)
	spalte.add_child(Erschaffung.kasten(kopf))
	rolle = ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	rolle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spalte.add_child(rolle)
	liste = VBoxContainer.new()
	liste.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	liste.add_theme_constant_override("separation", int(8 * DP))
	rolle.add_child(liste)
	spalte.add_child(Erschaffung.knopf("Zurück" if de else "Back", func(): wahl.emit("")))
	baue()

func baue() -> void:
	if liste == null: return
	var de := Sprache.aktiv() == "de"
	for c in liste.get_children():
		liste.remove_child(c)
		c.queue_free()
	var aushaenge := Auftraege.am_brett(z)
	if aushaenge.is_empty():
		liste.add_child(Erschaffung.kasten(Erschaffung.txt("Nur verblichene Nägel und Papierfetzen. Kein Aushang." if de
			else "Only faded nails and scraps of paper. No notices.", 16)))
	for j in aushaenge:
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 0)
		v.add_child(Erschaffung.txt(Sprache.t(j["titel"]), 18, Stil.BRIGHT))
		v.add_child(Erschaffung.txt(Sprache.t(j["aushang"]), 15))
		v.add_child(Erschaffung.luecke(4))
		v.add_child(Erschaffung.txt(("Lohn: " if de else "Reward: ") + Sprache.t(j["lohn"]), 15, Stil.DIM))
		v.add_child(Erschaffung.luecke(6))
		var an := Auftraege.angenommen(z, j)
		var id := "nimm:" + String(j["id"])
		var b := Erschaffung.knopf(("Angenommen" if de else "Accepted") if an else ("Annehmen" if de else "Accept"), func(): wahl.emit(id))
		b.disabled = an
		v.add_child(b)
		liste.add_child(Erschaffung.kasten(v))
