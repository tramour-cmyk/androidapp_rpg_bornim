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

# 630 (Chef 07.11., 22:28: „ich will da eine Einheitlichkeit haben“; Archiv 630): Schirm ohne Kasten nach 549a (DESIGN-STIL „Fenster
# und Schirme“): oben „ANSCHLAGBRETT“ 22 sp in Gold mit Zierlinie, je Aushang Titel (16 sp hell), Text (15 sp), Lohn als Angabe, rechts
# „ANNEHMEN ›“ als Hauptwahl (angenommen: matt „Angenommen“ ohne Zeichen, nur Angabe); Aushaenge zwischen schlichten Linien; unten nach
# einer Linie „‹ ZURÜCK“ links (618: Zurück ins Spiel); ohne Aushang die Naegel als Fliesstext
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
	for s in ["left", "right"]: rand.add_theme_constant_override("margin_" + s, int(24 * DP))
	rand.add_theme_constant_override("margin_top", int(36 * DP)); rand.add_theme_constant_override("margin_bottom", int(16 * DP))
	add_child(rand)
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", 0)
	rand.add_child(spalte)
	var de := Sprache.aktiv() == "de"
	var titel := Stil.zeile(("Anschlagbrett" if de else "Notice board").to_upper(), 22, Stil.GOLD, 3.0)
	titel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	spalte.add_child(titel)
	spalte.add_child(Stil.luecke(6))
	spalte.add_child(Spielstaende.zier())
	spalte.add_child(Stil.luecke(10))
	rolle = ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	spalte.add_child(rolle)
	liste = VBoxContainer.new()
	liste.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	liste.add_theme_constant_override("separation", 0)
	rolle.add_child(liste)
	var fuss := VBoxContainer.new()
	fuss.add_theme_constant_override("separation", int(10 * DP))
	fuss.add_child(Spielstaende.linie())
	var zk := Spielstaende.knopf("neben", "Zurück" if de else "Back", func(): wahl.emit(""), true)
	zk.name = "Zurueck"
	fuss.add_child(Spielstaende.knopfzeile(zk, null))
	spalte.add_child(Stil.luecke(10))
	spalte.add_child(fuss)
	Spielstaende.folge_inhalt(spalte, rolle, liste)
	baue()

static func _satz(t: String, sp_: float, farbe: Color, fett := false) -> Label:
	var l := Stil.zeile(Spielstaende.ohne_waise(t), sp_, farbe, 0.0, false, fett)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = 60 * DP
	return l

func baue() -> void:
	if liste == null: return
	var de := Sprache.aktiv() == "de"
	for c in liste.get_children():
		liste.remove_child(c)
		c.queue_free()
	var aushaenge := Auftraege.am_brett(z)
	if aushaenge.is_empty():
		liste.add_child(_satz("Nur verblichene Nägel und Papierfetzen. Kein Aushang." if de
			else "Only faded nails and scraps of paper. No notices.", 15, Stil.TEXT))
	var erst := true
	for j in aushaenge:
		if not erst: liste.add_child(Spielstaende.linie())
		erst = false
		var v := VBoxContainer.new()
		v.name = "Aushang_" + String(j["id"])
		v.add_theme_constant_override("separation", int(4 * DP))
		v.add_child(Stil.luecke(6))
		v.add_child(_satz(Sprache.t(j["titel"]), 16, Stil.BRIGHT, true))   # 584: Titel des Aushangs halbfett (alt BoardScreen.kt 67 fett)
		v.add_child(_satz(Sprache.t(j["aushang"]), 15, Stil.TEXT))
		v.add_child(_satz(("Lohn: " if de else "Reward: ") + Sprache.t(j["lohn"]), 13.5, Spielstaende.ANGABE))
		var id := "nimm:" + String(j["id"])
		if Auftraege.angenommen(z, j):
			var an := Stil.zeile(("Angenommen" if de else "Accepted").to_upper(), 13.5, Color(Stil.DIM, 0.75), 2.0)
			an.name = "Angenommen"
			an.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			an.custom_minimum_size.y = 48 * DP
			an.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			v.add_child(an)
		else:
			var k := Spielstaende.knopf("haupt", "Annehmen" if de else "Accept", func(): wahl.emit(id))
			k.name = "Annehmen"
			v.add_child(Spielstaende.knopfzeile(null, k))
		liste.add_child(v)
