class_name Menue
extends Control
# 399.1 Menue wie im alten Spiel (MenuScreen.kt MenuBody; Test 132, Chef 16:09: „Gold … Trefferpunkte … Taschen … weiß ich alles
# nicht … es gibt ja kein Menü und nichts“): oben gross der Name des Reiters in gesperrten Goldversalien, darunter die Reiter, im
# Kasten der Inhalt, unten „Schließen“. Die Leiste (Tasche) oeffnet es, das Spiel steht so lange. Reiter wie alt:
# - Held (HeroTab, 870.4 nach BRS): der Held auf dem Drehteller, Name, Volk · Herkunft, Heldenstufe und Gold; Leben, Mana, Erfahrung
#   als Balken; Schutzwert, Schaden, Kritisch; die sechs Grundwerte mit Erklaerung; Fertigkeiten (762) und Volksmerkmal.
# - Tasche (BagTab): Vorraete mit Gold zuerst, Dinge mit Anzahl; Ausruestung in der Tasche nach Seltenheit.
#   Antippen (BagTab): Traenke, Essen, Ausdauertrank und Leuchtfunke benutzen (Game.useItemOutside), Ausruestung anlegen, in die
#   Nebenhand, wegwerfen (mit Rueckfrage und Haendlerpreis).
# - Ausruestung (GearTab): Plaetze links und rechts des Helden (PaperDoll), Antippen legt ab, wechselt oder waehlt aus der Tasche,
#   was passt (die Nebenhand nimmt auch Einhandwaffen); darunter die Kampfwerte.
# - System (SystemSigns, 425): Zeichen wie alt, Gedrueckthalten erklaert; Spiel, Kampf, Bedienung; Lautstaerke (399.3.1), Helligkeit;
#   Siege, Geraet.
# - Karte (MapTab, 62): kartenreiter.gd.
# - Test (TestTab, nur im Testmodus, 399.1): testmodus.gd.
# - Chronik (ChronicleTab): Hauptauftrag in Gold, Auftraege der Geschichte, Nebenauftraege vom Brett, Erledigt zum Aufklappen, „Bisher geschehen“.
# Noch nicht wie alt: in der Chronik Ankunft und Morgenandacht ansehen; im System die MARS-Probe (Jerry); Bilder der Dinge;
# Fackel im Dunkeln.

signal zu
signal speichern                   # 399.1 System: die Welt haelt den Stand fest (spiel.gd speichere)
signal sprache                     # die Welt wechselt die Sprache (spiel.gd sprache_wechseln)
signal hauptmenue                  # speichern und zum Hauptmenue (spiel.gd)
signal ueber                       # 399.1 „Über“: wie hauptmenue, dort gleich „Über das Spiel“
signal ankunft                     # 399.1 Chronik: die Ankunft (Intro) noch einmal ansehen (spiel.gd zwischenbild)
signal andacht                     # 537 Chronik: die Morgenandacht (Tempelszene, 68) nach Kapitel 1 noch einmal ansehen
signal test(was: String, mit: Array)   # 399.1 Reiter „Test“: teleport, kapitelende, kampf, probe (spiel.gd test_tat)

const DP := AktionsKnopf.DP
const BLAU := Color("82aaf2")      # gearBlue auf Schwarz (Veil.of rare)
const GRUEN := Color("86c46e")     # Veil.good: geplante Werte
const SELTEN := {"COMMON": "bdb6a8", "UNCOMMON": "86c46e", "RARE": "82aaf2", "VERY_RARE": "bc8ef2", "EPIC": "f29e50", "DIVINE": "eac650"}

var hw: BrsHeld
var z: Zustand
var reiter := "held"
var ort := {}                      # 399.1 Karte: wo der Held steht (spiel.gd platz)
var kopf: Label
var leiste: HBoxContainer
var inhalt: VBoxContainer
var rolle: ScrollContainer
var bisher := false               # Chronik: „Bisher geschehen“ statt Auftraege
var erledigt_auf := false
var karte_direkt := false         # 528 (86.2, vm.mapDirect): vom Kartenzeichen geoeffnet; der Reiter Karte noch einmal schliesst
var meldung_: Label                # 399.1: was Benutzen, Anlegen, Wegwerfen sagt (alt vm.toast), drei Sekunden
var wuerfel := func(n: int, w: int) -> int:
	var t := 0
	for i in n: t += randi_range(1, w)
	return t

func _init(h: BrsHeld, zu_: Zustand) -> void:
	hw = h; z = zu_
	name = "Menue"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Rand.ruecke(self, Rand.oben(get_viewport()))   # 399.4: unter der Kamera des Handys
	Zurueck.melde(self, func(): zu.emit())   # 416.1: Android-Zurück wie „Schließen“
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var rand := MarginContainer.new()
	rand.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# 630 (549a „Schirm“): Seitenrand 24 dp, Titel oben in derselben Hoehe wie jeder Schirm (OBEN_DP)
	for s in ["left", "right"]: rand.add_theme_constant_override("margin_" + s, int(24 * DP))
	rand.add_theme_constant_override("margin_top", int(Spielstaende.OBEN_DP * DP)); rand.add_theme_constant_override("margin_bottom", int(12 * DP))
	add_child(rand)
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", int(10 * DP))
	rand.add_child(spalte)
	kopf = Stil.zeile("", 22, Stil.GOLD, 3.0)   # 630 (549a): Titel eines Schirms 22 sp Versalien gesperrt in Gold, darunter die Zierlinie
	kopf.name = "Titel"
	kopf.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spalte.add_child(kopf)
	spalte.add_child(Spielstaende.zier())
	leiste = HBoxContainer.new()
	leiste.add_theme_constant_override("separation", int(6 * DP))
	spalte.add_child(leiste)
	meldung_ = Stil.txt("", 15, Stil.BRIGHT)
	meldung_.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	meldung_.visible = false
	spalte.add_child(meldung_)
	rolle = ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	rolle.size_flags_vertical = Control.SIZE_EXPAND_FILL   # 630: ohne Kasten (549a)
	spalte.add_child(rolle)
	inhalt = VBoxContainer.new()
	inhalt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inhalt.add_theme_constant_override("separation", 0)
	rolle.add_child(inhalt)
	# 618 (Chef 07.11., 22:21: „Zurück für alles“): was ins Spiel zurueckfuehrt, heisst „Zurück“ wie die Zurueck-Taste von Android
	spalte.add_child(Spielstaende.linie())   # 630 (549a): schlichte Linie, darunter „‹ ZURÜCK“ links
	spalte.add_child(Spielstaende.knopfzeile(Spielstaende.knopf("neben", Sprache.u("back"), func(): zu.emit(), true), null))
	baue()

var _gebaut := ""   # der Reiter, den baue() zuletzt zeigte

func baue() -> void:
	# 425 (Pruefer 01.11.: Bildrate und Standort oben abgeschnitten): ein anderer Reiter beginnt oben wie alt (je Tab ein eigener
	# Rollzustand); nur derselbe Reiter behaelt nach Antippen seine Stelle
	var y := rolle.scroll_vertical if reiter == _gebaut else 0
	_gebaut = reiter
	kopf.text = wort(reiter).to_upper().replace("ß", "SS")
	for c in leiste.get_children():
		leiste.remove_child(c)
		c.queue_free()
	# 399.1: Reiter als Zeichen wie alt (TabSign, 60j); Woerter passten zu viert nicht in die Breite
	for r in ["held"] + (["fertigkeiten"] if not brs_fertigkeiten().is_empty() else []) + ["tasche", "ausruestung", "karte", "chronik", "system"] + (["test"] if Testmodus.ist_an() else []):   # 399.1 wie alt Tab.TEST
		var stern: bool = r == "chronik" and reiter != "chronik" and Chronik.frisch(z)   # 870.4: keine Attributspunkte mehr
		leiste.add_child(Reiterzeichen.knopf(r, wort(r), func(): tippe_reiter(r), r == reiter, stern))
	for c in inhalt.get_children():
		inhalt.remove_child(c)
		c.queue_free()
	match reiter:
		"held": held()
		"fertigkeiten": fertigkeiten_reiter()
		"tasche": tasche()
		"ausruestung": ausruestung()
		"chronik": chronik()
		"karte": inhalt.add_child(Kartenreiter.new(z, ort, rolle.size.y, func(): reiter = "chronik"; baue()))
		"test": Testmodus.reiter(self)
		_: system()
	# die Karte schiebt und zoomt selbst, der Kasten rollt dann nicht
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED if reiter == "karte" else ScrollContainer.SCROLL_MODE_SHOW_NEVER
	await get_tree().process_frame
	rolle.scroll_vertical = y

const CHRONIK := {"de": "Chronik", "en": "Chronicle"}   # MenuScreen.kt labels
const KARTE := {"de": "Karte", "en": "Map"}
const WORT := {"held": "hero", "tasche": "bag", "ausruestung": "equipment", "system": "system"}

# 528 (MenuScreen.kt 122–126): die Karte, vom Kartenzeichen geoeffnet, noch einmal angetippt: gleich zurueck ins Spiel
func tippe_reiter(r: String) -> void:
	if karte_direkt and r == "karte" and reiter == "karte":
		zu.emit()
		return
	if r != "karte": karte_direkt = false
	reiter = r; schliesse_erklaerung(); baue()

func wort(r: String) -> String:
	if r == "chronik": return Sprache.t(CHRONIK)
	if r == "karte": return Sprache.t(KARTE)
	if r == "test": return "Test"
	if r == "fertigkeiten": return "Fertigkeiten" if Sprache.aktiv() == "de" else "Skills"
	return Sprache.u(WORT[r])

func meldung(t: String) -> void:
	if t == "": return
	meldung_.text = t
	meldung_.visible = true
	var mein := t
	var schwach: WeakRef = weakref(meldung_)   # 574: wie Hauptmenue.hinweis, das Menue kann vorher zu sein
	get_tree().create_timer(3.0, true).timeout.connect(func():
		var f = schwach.get_ref()
		if f != null and f.text == mein: f.visible = false)

func zeile(t: String, sp: float, farbe := Stil.TEXT, fett := false) -> Label:
	var l := Stil.txt(t, sp, farbe, fett)
	inhalt.add_child(l)
	return l

func luecke(dp: float) -> void: inhalt.add_child(Stil.luecke(dp))

# LabeledBar: Wort 36 dp, Balken, Wert 96 dp
func balken(wort: String, wert: int, hoechst: int, farbe: Color, text := "") -> void:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(8 * DP))
	var w := Stil.txt(wort, 14, Stil.TEXT, true)   # 584: LabeledBar, Wort halbfett wie alt
	w.size_flags_horizontal = Control.SIZE_FILL
	w.custom_minimum_size.x = 36 * DP
	r.add_child(w)
	var b := Leiste.Balken.new()
	b.custom_minimum_size = Vector2(0, 10 * DP)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.anteil = float(wert) / maxf(1.0, float(hoechst)); b.farbe = farbe
	r.add_child(b)
	var v := Stil.txt(text if text != "" else "%d / %d" % [wert, hoechst], 14)
	v.size_flags_horizontal = Control.SIZE_FILL
	v.custom_minimum_size.x = 96 * DP
	r.add_child(v)
	inhalt.add_child(r)

# ---------------------------------------------------------------- Held (HeroTab)
# 870.4 (LISTE-UMZUG-BRS.md Schritt 4): der Held nach BRS: Name, Volk · Herkunft, Heldenstufe und Gold; Leben, Mana, Erfahrung nach
# BRS (Brs.bedarf); Schutzwert, Schaden, Kritisch; die sechs Grundwerte (in Kapitel 1 fest, 870a 4), antippbar mit Erklaerung
# ([870.14.wert.…]); Fertigkeiten (762), Volksmerkmal. Keine Klasse, keine Attributspunkte, kein Uebungsbonus mehr.
func held() -> void:
	var de := Sprache.aktiv() == "de"
	var oben := HBoxContainer.new()
	oben.add_theme_constant_override("separation", int(10 * DP))
	oben.add_child(Drehteller.new(HeldFigur.wahl(hw, z)))
	var wer := VBoxContainer.new()
	wer.add_theme_constant_override("separation", 0)
	wer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wer.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	wer.add_child(Stil.zeile(hw.name.to_upper(), 14, Stil.GOLD, 3.0))   # MenuHead
	wer.add_child(Stil.txt("%s · %s" % [ErschaffungBrs.volk_name(hw.volk), ErschaffungBrs.herkunft_name(hw.herkunft)], 15))
	wer.add_child(Stil.txt("%s   %s: %d" % [ErschaffungBrs.heldenstufe(hw.stufe), Sprache.u("gold"), z.gold], 15, Stil.TEXT, true))   # 584: MenuScreen.kt 586
	oben.add_child(wer)
	inhalt.add_child(oben)
	luecke(8)
	var anteil := float(hw.leben) / maxf(1.0, float(hw.max_leben()))
	balken(Sprache.u("hp"), hw.leben, hw.max_leben(), Leiste.HP_GRUEN if anteil > 0.5 else (Leiste.HP_GELB if anteil > 0.2 else Leiste.ROT))
	if hw.max_mana() > 0: balken(Sprache.u("sp"), hw.mana, hw.max_mana(), Leiste.BLAU)
	var st := z.stufe_brs()
	if int(st["stufe"]) >= Brs.hoechste_stufe():
		# 528 (MenuScreen.kt 594–601, Story.capped): auf der hoechsten Stufe des Kapitels gibt es keine Erfahrung mehr; der Balken voll
		balken(Sprache.u("xp"), 1, 1, Leiste.GOLD_HELL, str(int(st["ep"])))
		var satz := zeile("Höchststufe für Kapitel 1 erreicht. In diesem Kapitel gibt es keine weiteren EP; Kämpfe lohnen sich weiter für Beute und Ausrüstung." if de
			else "Maximum level for Chapter 1 reached. No more XP this chapter; fights still pay off in loot and gear.", 13, Stil.DIM)
		satz.name = "Hoechststufe"
	else:
		var bis := roundi(Brs.bedarf(int(st["stufe"])))
		balken(Sprache.u("xp"), int(st["ep"]), bis, Leiste.GOLD_HELL, "%d / %d" % [int(st["ep"]), bis])
	luecke(8)
	zeile("%s %d   %s %d   %s %d %%" % [KAMPFWERT["schutz"][0 if de else 1], hw.schutzwert(), KAMPFWERT["schaden"][0 if de else 1], hw.schaden(),
		KAMPFWERT["krit"][0 if de else 1], hw.krit_prozent()], 15, Stil.TEXT, true)   # 584: MenuScreen.kt 605
	if hw.waffe() != null: zeile(Beute.name(hw.waffe()), 14, Stil.DIM)
	luecke(10)
	zustaende_kurz()
	zeile("Tippe auf einen Grundwert, um zu sehen, was er bringt." if de else "Tap an attribute to see what it does.", 12, Stil.DIM)
	for g in BrsHeld.grundwerte():
		var r := HBoxContainer.new()
		r.add_theme_constant_override("separation", 0)
		var n := Stil.txt(ErschaffungBrs.tx(ErschaffungBrs.GRUNDWERT[g]), 16)
		n.autowrap_mode = TextServer.AUTOWRAP_OFF
		n.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		n.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		r.add_child(n)
		tippbar(n, func(): erklaere(g))
		var l := Stil.txt(str(hw.wert(g)), 16, Stil.TEXT, true)   # 584: Wert fett wie alt (MenuScreen.kt 632)
		l.autowrap_mode = TextServer.AUTOWRAP_OFF
		l.custom_minimum_size.x = 56 * DP
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		r.add_child(l)
		inhalt.add_child(r)
	luecke(10)
	fertigkeiten_kurz()
	if hw.merkmal() != "": zeile(hw.merkmal(), 14, Stil.GOLD)

# 764 (Chef 09.11., 14:49: „wenn ich ins Menü gehe auf mein Held, sollte das da auch angezeigt werden und vor allem auch gegebenenfalls
# mit Erklärung“): die Zustände, die gerade in der Leiste stehen, mit dem Schild wie dort und dem Satz, was sie bewirken
# ([870.14.zustand.*], Mars.STATUS_DESC, derselbe Satz wie beim Tipp auf das Schild im Kampf); ohne Zustand nichts
func zustaende_kurz() -> void:
	var de := Sprache.aktiv() == "de"
	var zd: Dictionary = BrsHeld.daten().get("zustaende", {})
	var Mars = load("res://regeln/mars.gd")
	var welche := []
	for st in zd:   # wie Leiste: Reihenfolge Status.entries, betrunken bis zur Rast
		if int(z.leiden.get(st, 0)) > 0 or (st == "DRUNK" and z.betrunken()): welche.append(st)
	if welche.is_empty(): return
	gruppe("Zustände" if de else "Conditions")   # [870.15.zustaende]
	for st in welche:
		var r := HBoxContainer.new()
		r.add_theme_constant_override("separation", int(8 * DP))
		var k := PanelContainer.new()
		var s := StyleBoxFlat.new()
		s.bg_color = Color(String(zd[st]["farbe"])); s.set_corner_radius_all(int(3 * DP))
		s.content_margin_left = 4 * DP; s.content_margin_right = 4 * DP
		k.add_theme_stylebox_override("panel", s)
		k.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		k.add_child(Stil.txt(Sprache.t(zd[st]["kurz"]), 13, Color.WHITE))
		r.add_child(k)
		var d: Array = Mars.STATUS_DESC.get(st, ["", ""])
		var t := Stil.txt(String(d[0 if de else 1]), 14, Stil.TEXT)
		t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r.add_child(t)
		inhalt.add_child(r)
		luecke(4)
	luecke(6)

# 870.14 (STORY-BRS-HELD.md „Kampfwerte“): Woerter der Kampfwerte, deutsch und englisch
const KAMPFWERT := {"leben": ["Leben", "Life"], "mana": ["Mana", "Mana"], "ausdauer": ["Ausdauer", "Stamina"], "schutz": ["Schutzwert", "Protection"],
	"schaden": ["Schaden", "Damage"], "krit": ["Kritisch", "Critical"]}

# 762 (Chef 09.11., 14:49): die Fertigkeiten des Helden nach BRS mit Wert, Rang und dem Weg bis zum Ende des Rangs; Raenge und
# Grenzen aus dem Handbuch [423.rang] (Anfaenger bis 24, Geselle bis 49, Meister bis 74, Grossmeister bis 100). Chef 20:59 (Rat
# Sokrates): eigener Reiter „Fertigkeiten“ neben Held, weil es 37 werden (BRS Abschnitt 3); dort nach den acht Gruppen, die
# geuebten mit Rang, Wert und Balken, die noch ungeuebten matt als Namen. Im Heldenreiter nur die drei hoechsten mit Sprung zum
# Reiter. Alte Spielstaende ohne BRS-Held zeigen weder Reiter noch Abschnitt. Steigen durch Tun (471) liest dieselbe Quelle.
const RAENGE := [[24, "Anfänger", "Novice"], [49, "Geselle", "Journeyman"], [74, "Meister", "Master"], [100, "Großmeister", "Grandmaster"]]

static func rang_von(wert: int) -> Array:
	for r in RAENGE:
		if wert <= int(r[0]): return r
	return RAENGE[RAENGE.size() - 1]

## Name -> Wert der Fertigkeiten, die der Held hat (einzige Stelle, die den Spielstand liest)
func brs_fertigkeiten() -> Dictionary:
	return (z.brs.get("fertigkeiten", {}) as Dictionary) if z != null and z.brs is Dictionary else {}

func _nach_wert(f: Dictionary) -> Array:
	var namen := f.keys()
	namen.sort_custom(func(a, b): return int(f[a]) > int(f[b]) or (int(f[a]) == int(f[b]) and String(a) < String(b)))
	return namen

## eine Fertigkeit: Name links, Rang und Wert rechts in Gold, darunter der Weg bis zum Ende des Rangs
func fertigkeit_zeile(n: String, w: int) -> void:
	var de := Sprache.aktiv() == "de"
	var r := rang_von(w)
	var unten := 0
	var i := RAENGE.find(r)
	if i > 0: unten = int(RAENGE[i - 1][0])
	var z1 := HBoxContainer.new()
	z1.add_theme_constant_override("separation", int(8 * DP))
	var l := Stil.txt(ErschaffungBrs.fert_name(n), 15)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	z1.add_child(l)
	var rw := Stil.txt("%s  %d" % [String(r[1] if de else r[2]), w], 15, Stil.GOLD)
	rw.autowrap_mode = TextServer.AUTOWRAP_OFF
	rw.size_flags_horizontal = Control.SIZE_FILL
	z1.add_child(rw)
	inhalt.add_child(z1)
	var b := Leiste.Balken.new()
	b.custom_minimum_size = Vector2(0, 6 * DP)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.anteil = float(w - unten) / maxf(1.0, float(int(r[0]) - unten))
	b.farbe = Leiste.GOLD_HELL
	inhalt.add_child(b)
	luecke(4)

## Heldenreiter: die drei hoechsten, darunter der Sprung zum Reiter „Fertigkeiten“
func fertigkeiten_kurz() -> void:
	var f := brs_fertigkeiten()
	if f.is_empty(): return
	zeile(wort("fertigkeiten").to_upper(), 14, Stil.GOLD).add_theme_font_override("font", Stil.variante(3.0))   # MenuHead
	var namen := _nach_wert(f)
	for n in namen.slice(0, 3): fertigkeit_zeile(String(n), int(f[n]))
	inhalt.add_child(Spielstaende.knopf("neben", wort("fertigkeiten").to_upper() + " ›", func(): tippe_reiter("fertigkeiten")))   # 549a: Wort statt Kasten
	luecke(10)

## Reiter „Fertigkeiten“: je Gruppe (Reihenfolge der Datei) erst die geuebten nach Wert, dann die uebrigen matt
func fertigkeiten_reiter() -> void:
	var f := brs_fertigkeiten()
	var gruppen: Dictionary = BrsHeld.e().get("fertigkeiten", {})
	var nein: Array = BrsHeld.e().get("nicht_waehlbar", [])
	var erst := true
	for gr in BrsHeld.ohne_info(gruppen):
		var alle: Array = gruppen[gr]
		var hat := {}
		for n in alle:
			if f.has(n): hat[n] = f[n]
		var rest := alle.filter(func(n): return not f.has(n) and not nein.has(n))
		if hat.is_empty() and rest.is_empty(): continue
		if not erst:   # 549a: Zwischenueberschriften durch eine schlichte Linie getrennt
			luecke(2); inhalt.add_child(Spielstaende.linie()); luecke(2)
		erst = false
		var offen := gruppe_offen(gr, not hat.is_empty())
		inhalt.add_child(gruppen_kopf(gr, hat.size(), hat.size() + rest.size(), offen))
		if not offen: continue
		luecke(2)
		for n in _nach_wert(hat): fertigkeit_zeile(String(n), int(hat[n]))
		if not rest.is_empty():
			var m := zeile(", ".join(rest.map(func(n): return ErschaffungBrs.fert_name(String(n)))), 14, Stil.DIM)
			m.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		luecke(6)

## 762 (Chef 21:25 Idee, 21:33 „Ja.“, Votum Sokrates): Gruppen ein- und aufklappbar; ohne Umklappen offen, wer schon etwas kann,
## zu, wer nichts kann; was der Spieler umklappt, bleibt gemerkt (Bedienung, ueber Neustarts)
static func gruppe_offen(gr: String, vorgabe: bool) -> bool:
	Bedienung.lade()
	return bool(Bedienung.fert_gruppen.get(gr, vorgabe))

func klappe_gruppe(gr: String, offen: bool) -> void:
	Bedienung.fert_gruppen[gr] = not offen
	Bedienung.speichere()
	baue()

## Kopf einer Gruppe als ganze Zeile zum Antippen (48 dp): Name in Goldversalien, rechts „geuebt/alle“ matt und der Winkel wie bei
## den Lizenzen (585): zu nach rechts, offen nach unten
func gruppen_kopf(gr: String, geuebt: int, alle: int, offen: bool) -> Control:
	var h := HBoxContainer.new()
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.custom_minimum_size.y = 48 * DP
	h.add_theme_constant_override("separation", int(10 * DP))
	var l := Stil.txt(ErschaffungBrs.tx(ErschaffungBrs.GRUPPE.get(gr, {"de": gr, "en": gr})).to_upper(), 14, Stil.GOLD)
	l.add_theme_font_override("font", Stil.variante(3.0))   # MenuHead
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(l)
	var a := Stil.txt("%d/%d" % [geuebt, alle], 14, Stil.GOLD if geuebt > 0 else Stil.DIM)
	a.autowrap_mode = TextServer.AUTOWRAP_OFF
	a.size_flags_horizontal = Control.SIZE_SHRINK_END
	a.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	a.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(a)
	# der Winkel in einer Huelle ohne Container: HBoxContainer setzt die Drehung seiner Kinder beim Anordnen auf 0 zurueck
	var pf := Spielstaende.pfeil(Stil.GOLD, false)
	pf.name = "Winkel"
	var hl := Control.new()
	hl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hl.custom_minimum_size = Vector2(16 * DP, 16 * DP)
	hl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pf.size = pf.custom_minimum_size
	pf.pivot_offset = pf.size / 2
	pf.position = (hl.custom_minimum_size - pf.size) / 2
	pf.rotation = PI / 2 if offen else 0.0
	hl.add_child(pf)
	h.add_child(hl)
	var k := Spielstaende.tippbar(h, func(): klappe_gruppe(gr, offen))
	k.name = "Gruppe_" + gr
	return k

# 870.4 ([870.14.wert.…], STORY-BRS-HELD.md): was ein Grundwert bringt, mit den Zahlen der Regelwerte. Bauregel: nur Zeilen, deren
# Wirkung im Code steht. 989 (Homer 1008, nach 952 D): kritisch je Waffengruppe und Schule (werte.json „kritisch“) ohne Zahl, die
# Aussicht mit der Hauptwaffe zeigen die Kampfwerte; Zauberschaden Evokation aus Verstand, Heilmagie aus Wille. Ruhen ohne Wirkung:
# Gewandtheit „Flächenwirkungen“, Wille „Furcht und Zauber“, Verstand „Wissen“ (kennt_schwaechen ruft nur der Test) und „Handwerk“;
# 963: Zähigkeit ohne Krankheit, Wahrnehmung nur Kraut (Laden.kraut_chance). 1017 (Homer 1015): ohne „Wurfwaffen“, solange es keine gibt
const WERT_KOPF := ["Wert %d", "Value %d"]
const WERT_TEXT := {
	"kraft": [["Schaden mit Nahkampfwaffen und Fäusten, außer Dolchen.", "Damage with melee weapons and fists, except daggers."]],
	"gewandtheit": [["Schaden mit Dolchen und Bögen.", "Damage with daggers and bows."],
		["Wer ausweicht, ist schwerer zu treffen: +%d je Punkt.", "When you dodge, you are harder to hit: +%d per point.", "ausweichen"],
		["Kritische Treffer (anderthalbfacher Schaden) mit Nahkampfwaffen und Fäusten, außer Dolchen; die Waffenfertigkeit zählt mit.",
			"Critical hits (half again as much damage) with melee weapons and fists, except daggers; weapon skill counts as well."],
		["Wer im Kampf zuerst handelt, und die Aussicht zu fliehen.", "Who acts first in combat, and your chance to flee."]],
	"zaehigkeit": [["Leben: +%d je Punkt.", "Life: +%d per point.", "leben"],
		["Ausdauer, zusammen mit Wille.", "Stamina, together with Will."],
		["Abwehr gegen Gift, Betäubung und Blendung.", "Resisting poison, stunning and blinding."]],
	"verstand": [["Schaden mit Evokation.", "Damage with Evocation."]],
	"wille": [["Mana: +%d je Punkt.", "Mana: +%d per point.", "mana"],
		["Heilung und Schaden mit Heilmagie.", "Healing and damage with Healing Magic."],
		["Kritische Treffer (anderthalbfacher Schaden) mit Evokation; die Fertigkeit zählt mit.",
			"Critical hits (half again as much damage) with Evocation; the skill counts as well."],
		["Ausdauer, zusammen mit Zähigkeit.", "Stamina, together with Toughness."]],
	"wahrnehmung": [["Treffen im Fernkampf: +%d %% je Punkt.", "Ranged accuracy: +%d%% per point.", "fern"],
		["Kritische Treffer (anderthalbfacher Schaden) mit Dolchen, Bögen und Armbrüsten; die Waffenfertigkeit zählt mit.",
			"Critical hits (half again as much damage) with daggers, bows and crossbows; weapon skill counts as well."],
		["Hinterhalte bemerken.", "Noticing ambushes."],
		["Aussicht auf ein Kraut mehr beim Sammeln.", "A chance of an extra herb when foraging."]],
}

static func erklaerung(h: BrsHeld, g: String) -> Array:
	var i := 0 if Sprache.aktiv() == "de" else 1
	var W := BrsHeld.lade()
	var zahl := {"ausweichen": int(W["kampf"]["ausweichen_je_gewandtheit"]), "leben": int(W["held"]["leben_je_zaehigkeit"]),
		"mana": int(W["held"]["mana_je_wille"]), "fern": int(W["kampf"]["fernkampf_treffer_je_wahrnehmung"])}
	var out := [WERT_KOPF[i] % h.wert(g)]
	for t in WERT_TEXT.get(g, []):
		out.append(String(t[i]) % zahl[t[2]] if t.size() > 2 else String(t[i]))
	return out

func erklaere(g: String) -> void:
	var z_ := []
	var e := erklaerung(hw, g)
	for i in e.size():
		z_.append(Stil.txt(e[i], 15 if i == 0 else 14))
	dialog(ErschaffungBrs.tx(ErschaffungBrs.GRUNDWERT[g]), Stil.GOLD, z_, [["OK", func(): pass]])

# ---------------------------------------------------------------- Tasche (BagTab)
func tasche() -> void:
	var de := Sprache.aktiv() == "de"
	zeile(("Vorräte" if de else "Supplies").to_upper(), 14, Stil.GOLD).add_theme_font_override("font", Stil.variante(3.0))
	inhalt.add_child(posten(Sprache.u("gold"), str(z.gold), Stil.BRIGHT, Menue.vorrat_bild("gold")))   # 171: Gold zuerst, eine Zeile fuer sich
	# 523 (Abgleich 512) wie alt (84.5): der Funke brennt bis zur naechsten Rast; „Löschen“, weg ist weg
	if z.funke:
		var fr := HBoxContainer.new()
		var fn := Stil.txt(Laden.name("spark_potion"), 15)
		fn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fr.add_child(fn)
		var be: Dictionary = Sprache.texte.get("benutzen", {})
		var kn := Stil.knopf(Sprache.t(be.get("sparkOut", {"de": "Löschen", "en": "Put out"})), func():
			z.funke = false
			meldung(Sprache.t(be.get("sparkGone", {"de": "Der Funke verglimmt. Weg ist weg.", "en": "The spark fades. Gone is gone."})))
			baue())
		kn.custom_minimum_size = Vector2(110, 36) * DP
		kn.size_flags_horizontal = Control.SIZE_SHRINK_END
		fr.add_child(kn)
		inhalt.add_child(fr)
	if z.taschen.is_empty(): zeile(Sprache.u("nothing"), 16, Stil.DIM)
	for id in z.taschen:
		var dd := Laden.ding(String(id))
		var p := posten(Laden.name(String(id)), "×%d" % int(z.taschen[id]), Color(SELTEN.get(String(dd.get("seltenheit", "COMMON")), "e6ddcb")), Menue.vorrat_bild(String(id)))
		var info := Sprache.t(dd.get("info", ""))
		if info != "":
			var spalte: VBoxContainer = p.get_child(1)   # nach dem Bild
			spalte.add_child(Stil.txt(info, 13, Stil.DIM))
		inhalt.add_child(p)
		tippbar(p, func(): frage_ding(String(id)))
	luecke(10)
	var dinge: Array = z.beutel.duplicate()
	dinge.sort_custom(vor)
	var k := zeile((("Ausrüstung" if de else "Equipment") + " (%d)" % dinge.size()).to_upper(), 14, Stil.GOLD)
	k.add_theme_font_override("font", Stil.variante(3.0))
	if dinge.is_empty():
		zeile("Besiege Monster und öffne Truhen, um Ausrüstung zu finden." if de else "Defeat monsters and open chests to find equipment.", 14, Stil.DIM)
	for g in dinge:
		# ▲ besser in allem, ▼ schlechter; nichts, wenn gemischt oder gleich (GearUi.kt upgradeVerdict)
		var p := ausruestungszeile(g)
		inhalt.add_child(p)
		tippbar(p, func(): frage_stueck(g))

# nach Seltenheit, dann Gegenstandsstufe, absteigend (alt: rarity, slot, ilvl)
const REIHE := ["COMMON", "UNCOMMON", "RARE", "VERY_RARE", "EPIC", "DIVINE"]
# 523 (Abgleich 512): dazwischen nach Platz wie alt (GearSlot.ordinal: Kopf, Umhang, Oberkoerper, Arme, Beine, Amulett, Ring, Haupthand, Nebenhand)
const PLATZ_REIHE := ["HEAD", "CLOAK", "CHEST", "ARMS", "LEGS", "AMULET", "RING", "MAIN_HAND", "OFF_HAND"]
static func vor(a: Dictionary, b: Dictionary) -> bool:
	var ra := REIHE.find(String(a["rarity"])); var rb := REIHE.find(String(b["rarity"]))
	if ra != rb: return ra > rb
	var pa := PLATZ_REIHE.find(String(Beute.grundform(String(a["base"]))["slot"])); var pb := PLATZ_REIHE.find(String(Beute.grundform(String(b["base"]))["slot"]))
	if pa != pb: return pa < pb
	return int(a["ilvl"]) > int(b["ilvl"])

# 521, 523 (Chef 03.11., 23:23: „Leider kann man da die Items null unterscheiden … Zweihänder? Was überhaupt? Sind gesperrte
# Gegenstände darunter?“; 23:26 „besser machen“): wie alt GearRow (GearUi.kt 119) in Tasche und Wechselschirm: Bild 42 dp, Name in
# der Farbe der Seltenheit (bis zwei Zeilen), darunter listLine (Art, Waffe oder Platz, Kennwert), besser als alt dazu „zweihändig“;
# nicht Tragbares „· nicht tragbar“ in Rot; rechts ▲ gruen besser in allem, ▼ rot schlechter (upgradeVerdict; Angelegtes nie)
const BESSER := Color("2a8a3a")
const AKZENT := Color("e05a3a")       # Colors.accent
func ausruestungszeile(g: Dictionary) -> HBoxContainer:
	var de := de_()
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(8 * DP))
	r.add_child(Menue.stueck_rahmen(g, 42))
	var s := VBoxContainer.new()
	s.add_theme_constant_override("separation", 0)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var n := Stil.txt(Beute.name(g), 16, farbe_von(g))
	n.max_lines_visible = 2
	s.add_child(n)
	var ok := hw.kann_tragen(g)
	# 521/523 (Chef 04.11., 12:01: Robe des Ankers zeigte nur „Oberkörper“): ohne Kennwert die zwei ersten Boni wie im Wechselschirm (557)
	var unten := Menue.listen_zeile_b(g)
	if unten == "": unten = Testmodus.gross_anfang(Sprache.t(BrsHeld.daten()["seltenheiten"][String(g["rarity"])].get("name", g["rarity"])))   # Ring, Amulett ohne Kennwert: alt leer
	if zweihaendig(g) and not unten.containsn("zweih") and not Beute.name(g).containsn("zweih"): unten += " · " + ("zweihändig" if de else "two-handed")
	if not ok: unten += " · " + ("nicht tragbar" if de else "can't wear")
	s.add_child(Stil.txt(unten, 12, Stil.DIM if ok else AKZENT))
	r.add_child(s)
	var angelegt := false
	for pl in PLATZ_REIHE:
		var x = hw.ding(pl)
		if x != null and int(x["uid"]) == int(g["uid"]): angelegt = true
	var u = Vergleich.von(hw, g).urteil() if ok and not angelegt else null
	# 521/523 (Chef 04.11., 12:01: „das in der Mitte … wird gar nicht bewertet“): gemischt mit ◆ in Gold wie der Wechselschirm (557)
	if u != null:
		var pf := Stil.txt({1: "▲", -1: "▼", 0: "◆"}[int(u)], 18, {1: BESSER, -1: AKZENT, 0: Stil.BRIGHT}[int(u)])
		pf.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		r.add_child(pf)
	r.set_meta("tragbar", ok)
	r.set_meta("pfeil", 0 if u == null else int(u))
	return r

# ItemRow, GearRow: Bild, Name (in der Farbe der Seltenheit), rechts die Anzahl oder der Kennwert
func posten(n: String, rechts: String, farbe: Color, bild: Control = null) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(8 * DP))
	if bild: r.add_child(bild)
	var s := VBoxContainer.new()
	s.add_theme_constant_override("separation", 0)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.add_child(Stil.txt(n, 16, farbe))
	r.add_child(s)
	var w := Stil.txt(rechts, 15)
	w.size_flags_horizontal = Control.SIZE_FILL
	w.autowrap_mode = TextServer.AUTOWRAP_OFF
	w.size_flags_vertical = Control.SIZE_SHRINK_BEGIN   # Helfer: „×2“ stand auf Hoehe der Beschreibung statt des Namens
	r.add_child(w)
	return r

# 399.1: eine Zeile antippen (Modifier.tap); verschoben zum Rollen loest nichts aus
func tippbar(c: Control, was: Callable) -> void:
	c.mouse_filter = Control.MOUSE_FILTER_PASS
	var da := {"p": Vector2.INF}
	c.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
			# 571: Weg des Fingers auf dem Schirm, nicht in der Zeile; rollt die Liste mit, bleibt die Stelle in der Zeile gleich
			var wo: Vector2 = c.get_global_transform_with_canvas() * e.position
			if e.pressed: da["p"] = wo
			elif da["p"] != Vector2.INF and wo.distance_to(da["p"]) < 12 * DP:
				da["p"] = Vector2.INF
				was.call())

# 630 (549a, Chef 04.11., 19:28; 557a B): jedes Laden- und Menuefenster ohne Kasten wie Spielstaende.frage: schwarz und ganz deckend,
# oben der Kopf (Titel; beim Ding Bild links, Name daneben), genau eine Zierlinie, der Inhalt, eine schlichte Linie, die Knoepfe.
# Knoepfe [Text, Tat, an?]: der letzte „Abbrechen“/„Schliessen“/„Zurueck“ links unten (Nebenwahl), der erste rechts unten
# (Hauptwahl, Wegwerfen/Loeschen in Warnfarbe), weitere in Reihen darueber (Gefahr links, sonst rechts); ein einzelnes „OK“ ist ein
# Fenster ohne Wahl: „‹ SCHLIESSEN“ links. Rueckfragen (Titel mit „?“) mittig, Text ab vier Zeilen linksbuendig
func dialog(titel: String, farbe: Color, zeilen: Array, knoepfe: Array) -> Control:
	var schleier := Rueckfrage.schleier(self)   # 526: Tippen daneben und Android-Zurück wie „Abbrechen“ (416.1)
	schleier.color = Color.BLACK   # 549a: ganz deckend, nichts scheint durch
	var mitte := Spielstaende.oben()   # 557a B: Titel in derselben Hoehe wie auf jedem Schirm
	schleier.add_child(mitte)
	var v := VBoxContainer.new()
	v.name = "Fenster"
	v.add_theme_constant_override("separation", int(10 * DP))
	v.custom_minimum_size.x = get_viewport_rect().size.x - 48 * DP
	mitte.add_child(Rueckfrage.halte(v))   # 526: Tippen ins Fenster schliesst nicht
	var frage := titel.strip_edges().ends_with("?")
	v.add_child(Menue.dialog_kopf(titel, farbe, zeilen, frage))
	v.add_child(Spielstaende.zier())
	for c in zeilen:
		if c.get_parent() != null: continue
		v.add_child(c)
		if frage and c is Label:
			var l := c as Label
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.resized.connect(func(): l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if l.get_line_count() <= 3 else HORIZONTAL_ALIGNMENT_LEFT)
		elif frage and c is Control:
			(c as Control).size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(Spielstaende.linie())
	v.add_child(Menue.dialog_fuss(knoepfe, func(): schleier.queue_free(), v.custom_minimum_size.x))
	return schleier

# 549a Kopf: Titel eines Fensters (586a: 22 sp wie ein Schirm) Versalien gesperrt in Gold, mittig; beim Ding (eigene Farbe) das Bild (erste Zeile) links,
# daneben der Name 16 sp normal in der Farbe der Seltenheit; eine Rueckfrage hat immer den Titel in Gold (Spielstaende.frage)
static func dialog_kopf(titel: String, farbe: Color, zeilen: Array, frage := false) -> Control:
	if farbe == Stil.GOLD or frage:
		var t := Stil.zeile(titel.to_upper().replace("ß", "SS"), Stil.TITEL_SP, Stil.GOLD, 3.0)   # 586a
		t.name = "Titel"
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		return t
	var kopf := HBoxContainer.new()
	kopf.add_theme_constant_override("separation", int(12 * DP))
	if not zeilen.is_empty() and zeilen[0] is TextureRect:
		var bild: Control = zeilen[0]
		bild.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		bild.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		kopf.add_child(bild)
	var n := Stil.zeile(titel, 16, farbe)
	n.name = "Titel"
	n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	n.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	kopf.add_child(n)
	return kopf

const GEFAHR := ["Wegwerfen", "Discard", "Löschen", "Delete"]

# 549a Knoepfe (Spielstaende.knopf, knopfzeile): je die halbe Breite, Seite nach Bedeutung; [zu] schliesst das Fenster vor der Tat
static func dialog_fuss(knoepfe: Array, zu: Callable, breite: float) -> Control:
	var zurueck := [Sprache.t(ABBRECHEN), Sprache.u("close"), Sprache.u("back")]
	var ks := knoepfe.duplicate()
	var neben: Array = []
	if ks.size() == 1 and String(ks[0][0]) == "OK": neben = [Sprache.u("close"), ks.pop_back()[1]]
	elif not ks.is_empty() and String(ks[-1][0]) in zurueck: neben = ks.pop_back()
	var halb := (breite - 8 * DP) / 2.0
	var mach := func(k: Array, art: String, links: bool) -> Control:
		var tat: Callable = k[1]
		var an := k.size() < 3 or bool(k[2])
		if art == "haupt" and String(k[0]) in GEFAHR: art = "gefahr"
		var p := Spielstaende.knopf(art, String(k[0]), func(): zu.call(); tat.call(), links, an)
		Menue.passe_knopf(p, halb)
		return p
	var v := VBoxContainer.new()
	v.name = "Knoepfe"
	v.add_theme_constant_override("separation", 0)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var haupt: Array = ks.pop_front() if not ks.is_empty() else []
	var l: Array = ks.filter(func(k): return String(k[0]) in GEFAHR)
	var r: Array = ks.filter(func(k): return not String(k[0]) in GEFAHR)
	for i in maxi(l.size(), r.size()):
		v.add_child(Spielstaende.knopfzeile(mach.call(l[i], "gefahr", true) if i < l.size() else null,
			mach.call(r[i], "neben", false) if i < r.size() else null))
	v.add_child(Spielstaende.knopfzeile(mach.call(neben, "neben", true) if not neben.is_empty() else null,
		mach.call(haupt, "haupt", false) if not haupt.is_empty() else null))
	return v

# 549a Knopfschrift 15 sp; passt der Text nicht in die halbe Breite („VERKAUFEN ×5 · 120 GOLD“): kleiner bis 13 sp (nie darunter,
# 549a Schrift), dann zwei Zeilen
static func passe_knopf(p: Control, breite: float, groessen := [15.0, 14.0, 13.0]) -> void:
	var l := p.find_child("Text", true, false) as Label
	if l == null: return
	var innen := breite - 9 * DP - 6 * DP   # Winkel „›“ bzw. „×“ und Abstand
	var schrift := l.get_theme_font("font")
	for sp in groessen:
		var g := int(round(sp * Stil.SP))
		if schrift.get_string_size(l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, g).x <= innen:
			l.add_theme_font_size_override("font_size", g)
			return
	l.add_theme_font_size_override("font_size", int(round(13.0 * Stil.SP)))
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Breite der laengeren Zeile (gierig wie der Umbruch), dann steht „›“ bzw. „‹“ direkt am Text (Pruefer 10:06: abgesetzt rechts)
	var g := int(round(13.0 * Stil.SP))
	var worte := l.text.split(" ", false)
	var zeile := ""; var breit := 0.0
	for w in worte:
		var probe: String = w if zeile == "" else zeile + " " + w
		if zeile != "" and schrift.get_string_size(probe, HORIZONTAL_ALIGNMENT_LEFT, -1, g).x > innen:
			breit = maxf(breit, schrift.get_string_size(zeile, HORIZONTAL_ALIGNMENT_LEFT, -1, g).x); zeile = w
		else: zeile = probe
	breit = maxf(breit, schrift.get_string_size(zeile, HORIZONTAL_ALIGNMENT_LEFT, -1, g).x)
	l.custom_minimum_size.x = minf(innen, ceilf(breit) + 2.0)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if bool(p.get_meta("links", false)) else HORIZONTAL_ALIGNMENT_RIGHT

# 630 (Chef 08.11., 15:11: „Abenteuer R bricht um … der Kasten rechts unten muss schon mal größer sein“): Breite, die ein Knopf in
# einer Zeile bei [sp] braucht (Text mit Sperrung, Winkel, Abstand)
static func knopf_breite(p: Control, sp: float) -> float:
	var l := p.find_child("Text", true, false) as Label
	if l == null: return 0.0
	return ceilf(l.get_theme_font("font").get_string_size(l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, int(round(sp * Stil.SP))).x) + 2.0 + 9 * DP + 6 * DP

# eine Knopfzeile (Spielstaende.knopfzeile) in [breite]: je die halbe Breite, wenn beide in eine Zeile passen; sonst bekommt der
# rechte (Hauptwahl) so viel, wie er in einer Zeile braucht, der linke den Rest, beide in derselben Groesse; erst wenn auch das nicht
# geht, bricht der Text um (passe_knopf)
static func passe_knopfzeile(zeile: HBoxContainer, breite: float) -> void:
	var k := zeile.get_children()
	if k.size() != 2: return
	var frei := breite - zeile.get_theme_constant("separation")
	for sp in [15.0, 14.0, 13.0]:
		var bl := knopf_breite(k[0], sp)
		var br := knopf_breite(k[1], sp)
		if bl + br > frei: continue
		var wr := maxf(frei / 2.0, br)
		if bl > frei / 2.0: wr = frei - bl
		(k[0] as Control).size_flags_stretch_ratio = frei - wr
		(k[1] as Control).size_flags_stretch_ratio = wr
		passe_knopf(k[0], frei - wr, [sp])
		passe_knopf(k[1], wr, [sp])
		return
	for c in k: passe_knopf(c, frei / 2.0)

const ABBRECHEN := {"de": "Abbrechen", "en": "Cancel"}
func abbrechen() -> String: return Sprache.t(ABBRECHEN)

# ---------------------------------------------------------------- Dinge benutzen (Game.useItemOutside)
# Leuchtfunke, Ausdauertrank, Essen, Heiltrank und Kraeutertrank ausserhalb des Kampfes; Antwort wie alt (Light, Resting, Msgs, Ui)
# 870.4: Leben fest nach BRS (werte.json „welt“ „heilung“, wie im Kampf), ohne Eintrag wie bisher mit den Wuerfeln des Dings
static func heilung(id: String, h: Array, wuerfel_: Callable) -> int:
	var fest = BrsHeld.welt().get("heilung", {}).get(id)
	if fest != null: return int(fest)
	return int(wuerfel_.call(int(h[0]), int(h[1]))) + int(h[2])

static func benutze(z: Zustand, hw: BrsHeld, id: String, wuerfel_: Callable) -> String:
	var dd := Laden.ding(id)
	var art := String(dd.get("art", ""))
	var b: Dictionary = Sprache.texte.get("benutzen", {})
	var sag := func(k: String, werte: Array = []) -> String:
		var s := Sprache.t(b.get(k, k))
		for i in werte.size(): s = s.replace("{%d}" % i, str(werte[i]))
		return s
	if z.anzahl(id) <= 0: return Sprache.u("cannotUseHere")
	if id == "spark_potion":
		if z.funke: return sag.call("sparkAlready")
		z.weg(id); z.funke = true
		return sag.call("sparkDrunk")
	if art == "TONIC":
		if z.ausdauer_trank: return Sprache.r("staminaAlready")
		z.weg(id); z.ausdauer_trank = true
		return Sprache.r("staminaDrunk", [hw.name])
	var h: Array = dd.get("heilt", [])
	if art == "FOOD" and not h.is_empty():
		if z.satt and hw.leben >= hw.max_leben(): return sag.call("alreadyFed", [hw.name])
		z.weg(id)
		var vor := hw.leben
		hw.leben = mini(hw.max_leben(), hw.leben + heilung(id, h, wuerfel_) + Laden.essen_bonus(hw))   # Perks.mealBonus (870.4: Kochen)
		z.satt = true
		return sag.call("ate", [hw.name, Laden.name(id), hw.leben - vor])
	if art != "POTION" or h.is_empty(): return Sprache.u("cannotUseHere")
	var heilt := bool(dd.get("heilt_leiden", false)) and not z.leiden.is_empty()
	if hw.leben >= hw.max_leben() and not heilt: return Sprache.u("alreadyFull")
	z.weg(id)
	var vor := hw.leben
	hw.leben = mini(hw.max_leben(), hw.leben + heilung(id, h, wuerfel_))
	if heilt: z.leiden.clear()
	var geheilt: String = sag.call("healed", [hw.name, hw.leben - vor])
	return (sag.call("cured", [hw.name]) + " " + geheilt) if heilt else geheilt

# 523 (Abgleich 512, Game.kt useItemOutside): wie alt ein Klang, wenn etwas wirklich benutzt wurde: Essen „heal“, Traenke und Funke
# „potion“; nichts, wenn der Held schon voll ist oder der Funke schon brennt
func benutze_mit_klang(id: String, art: String) -> void:
	var vor := z.anzahl(id)
	meldung(Menue.benutze(z, hw, id, wuerfel))
	var k := get_node_or_null("/root/Klang")
	if k and z.anzahl(id) < vor: k.effekt("heal" if art == "FOOD" else "potion")
	letzter_klang = ("heal" if art == "FOOD" else "potion") if z.anzahl(id) < vor else ""

var letzter_klang := ""   # 523: fuer den Test ohne Klangknoten

func frage_ding(id: String) -> void:
	var dd := Laden.ding(id)
	var art := String(dd.get("art", ""))
	var de := Sprache.aktiv() == "de"
	var trinkbar := art in ["POTION", "FOOD", "TONIC"]
	var zeilen: Array = []
	var bild := Menue.bild_feld("ding-" + id, 48)   # Dialogs.kt: SupplyPicture 48 dp
	bild.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	zeilen.append(bild)
	var info := Sprache.t(dd.get("info", ""))
	if info != "": zeilen.append(Stil.txt(info, 15))
	# 944 (Chef 11.11., 13:22, t276.5): keine Würfel im Text; was er heilt, sagt die Meldung (STORY-BRS-OBERFLAECHE „Gegenstände“)
	var farbe := Color(SELTEN.get(String(dd.get("seltenheit", "COMMON")), "e6ddcb"))
	if trinkbar:
		var wort := ("Essen" if de else "Eat") if art == "FOOD" else Sprache.u("use")
		dialog(Laden.name(id), farbe, zeilen, [[wort, func(): benutze_mit_klang(id, art); baue()], [abbrechen(), func(): pass]])
	else:
		dialog(Laden.name(id), farbe, zeilen, [["OK", func(): pass]])

# ---------------------------------------------------------------- Ausruestung anlegen, ablegen, wegwerfen
func farbe_von(g: Dictionary) -> Color: return Color(SELTEN.get(String(g["rarity"]), "e6ddcb"))
func zweihaendig(g) -> bool: return g != null and bool(Beute.grundform(String(g["base"]))["zweihaendig"])
func einhandwaffe(g: Dictionary) -> bool: return Beute.ist_waffe(Beute.grundform(String(g["base"]))) and not zweihaendig(g)

# GearDetails, soweit ohne Vergleich: was und wo, Stufe, Gewicht; die Grundzahl; jede Eigenschaft (Affix.line)
func stueck_zeilen(g: Dictionary) -> Array: return Menue.stueck_zeilen_von(hw, g)

# 870.4 ([870.14.ding.…], DESIGN-BRS.md 7): jeder darf alles tragen; was darin nicht geht, nur wenn es zutrifft: [Text, Warnung]
static func tragen_hinweise(hw: BrsHeld, g: Dictionary) -> Array:
	var de := Sprache.aktiv() == "de"
	var b := Beute.grundform(String(g["base"]))
	var r: Array = []
	if BrsHeld.metall(String(g["base"])):
		r.append(["Metall: Evokation, Illusion und Beschwörung wirken darin nicht." if de else "Metal: Evocation, Illusion and Summoning will not work in it.", false])
	# [870.14.ding.klirrt] „Schwere Rüstung: darin kannst du nicht schleichen.“ ruht, bis Schleichen im Spiel wirkt (Homer, 963)
	if Beute.ist_waffe(b) and bool(b.get("zweihaendig", false)):
		r.append(["Braucht beide Hände: kein Schild dazu." if de else "Needs both hands: no shield with it.", false])
	var f := BrsHeld.fertigkeit_von(String(g["base"]))
	if f != "" and hw.fertigkeit(f) <= 0:
		r.append(["Noch nie benutzt: du fängst bei null an." if de else "Never used: you start from nothing.", true])
	return r

# GearDetails fuer Tasche, Ausruestung und Laden (399.1: auch spiel.gd zeige_stueck)
static func stueck_zeilen_von(hw: BrsHeld, g: Dictionary) -> Array:
	var de := Sprache.aktiv() == "de"
	var farbe_von := func(x: Dictionary) -> Color: return Color(SELTEN.get(String(x["rarity"]), "e6ddcb"))
	var zweihaendig := func(x) -> bool: return x != null and bool(Beute.grundform(String(x["base"]))["zweihaendig"])
	var b := Beute.grundform(String(g["base"]))
	var d := BrsHeld.daten()
	var z_: Array = []
	var sp := "de" if de else "en"
	var fett := func(l: Label) -> Label:
		l.add_theme_constant_override("outline_size", int(DP * 0.6)); l.add_theme_color_override("font_outline_color", l.get_theme_color("font_color"))
		return l
	var bild := Menue.bild_feld("stueck-%s-%s" % [g["base"], g["rarity"]], 48)   # Dialogs.kt: GearPicture 48 dp
	bild.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	z_.append(bild)
	# 524 (Abgleich 512, Chef 23:26 „besser machen“, alt ist die Untergrenze): Reihenfolge und Inhalt wie GearDetails alt (GearUi.kt 156–243)
	# Gear.kindLine: Seltenheit und Art, wenn der Name sie nicht schon sagt
	var selten := Sprache.t(d["seltenheiten"][String(g["rarity"])]["name"])
	var gezeigt := Beute.name(g)
	var art := String(b[sp])
	var hat_art := gezeigt.containsn(art)
	var art_zeile := ""
	if not (hat_art and gezeigt.containsn(selten)):
		var gross := selten.left(1).to_upper() + selten.substr(1)
		art_zeile = gross if hat_art else ((gross + String(d["endungen"][String(b["geschlecht"])]) + " " + art) if de else (gross + " " + art))
	if art_zeile != "": z_.append(Stil.txt(art_zeile, 14, farbe_von.call(g)))
	# Gear.wearLine · Stufe · Gewicht; beidhaendige Waffe fett in Rot (ein Schild muss herunter)
	var waffe := Beute.ist_waffe(b)
	var wo := String(d["plaetze"][String(b["slot"])][sp])
	if waffe and zweihaendig.call(g): wo = "Beide Hände" if de else "Both hands"
	elif waffe: wo = "Haupt- oder Nebenhand" if de else "Main or off hand"
	wo += (" · Stufe " if de else " · Level ") + str(int(g["ilvl"]))
	var gewicht := String(b.get("gewicht", "NONE"))
	if gewicht != "NONE": wo += " · " + Sprache.t(d["ruestungsarten"].get(gewicht, {"de": "Stoff", "en": "cloth"}))
	var wl := Stil.txt(wo, 13, Stil.WARN if waffe and zweihaendig.call(g) else Stil.DIM)
	z_.append(fett.call(wl) if waffe and zweihaendig.call(g) else wl)
	# [84.1.laden] wozu die Fackel ist (Light.torchAbout)
	if String(b["art"]) == "LIGHT":
		z_.append(Stil.txt("Pech und Werg auf einem Stock. In der Nebenhand, statt eines Schilds. Im Dunkeln siehst du weiter als mit einem Leuchtfunken. Brennt, solange du sie trägst." if de else
			"Pitch and tow on a stick. Held in the off hand, instead of a shield. In the dark you see further than with a Lightspark. Burns as long as you carry it.", 14))
	# was dafuer abgelegt wird und das Urteil gleich oben, ohne Rollen; die Tabelle unten sagt warum (59.3: nie fuer Getragenes)
	var v: Vergleich = Vergleich.von(hw, g) if hw.kann_tragen(g) and not hw.ausruestung.values().any(func(x): return x != null and int(x["uid"]) == int(g["uid"])) else null
	if v:
		if not v.ersetzt.is_empty():
			var anderer := v.ersetzt.any(func(x): return String(Beute.grundform(String(x["base"]))["slot"]) != String(b["slot"]))
			var el := Stil.txt(("Ersetzt: " if de else "Replaces: ") + ", ".join(PackedStringArray(v.ersetzt.map(func(x): return Beute.name(x)))), 13, Stil.WARN if anderer else Stil.DIM)
			z_.append(fett.call(el) if anderer else el)
		z_.append(fett.call(Stil.txt(v.satz(), 14, {1: GRUEN, -1: Stil.WARN}.get(v.urteil(), Stil.TEXT))))
	# Grundzahlen (870.7, [870.14.ding.…]): Schaden mit Guete und Schadensart, ohne Würfel (944) und ohne „vielseitig“ (Homer 870.14),
	# der Grundwert im Schaden statt Finesse/Fernkampf; Schutzwert mit Guete ohne Gewandtheit; Guete statt „Angriff +n“; Fertigkeit
	if Beute.ist_waffe(b):
		z_.append(fett.call(Stil.txt(schaden_text(g, de), 16)))
		z_.append(Stil.txt(grundwert_text(g, de), 13, Stil.DIM))
	elif hat_kennwert(g):
		z_.append(fett.call(Stil.txt(("Schutzwert %d" if de else "Protection %d") % Beute.schutzwert(g), 16)))
	if hat_kennwert(g): z_.append(Stil.txt(guete_text(g, de), 14, Stil.TEXT))
	if fertigkeit_text(g, de) != "": z_.append(Stil.txt(fertigkeit_text(g, de), 13, Stil.DIM))
	# Zusatzeigenschaften (870.7: Wortlaut Beute.zusatz_text, STORY-BRS-HELD.md), blau wie alt
	for r in g["rolls"]:
		z_.append(Stil.txt(Beute.zusatz_text(r), 16, Color(SELTEN["RARE"])))
	# Warnungen
	for t in Menue.tragen_hinweise(hw, g): z_.append(Stil.txt(t[0], 15 if t[1] else 13, Stil.WARN if t[1] else Stil.DIM))
	# Vergleich: alles, was sich aendert, Getragenes neben dem Neuen, Gewinn gruen, Verlust rot, Hinweise darunter
	if v and not v.zeilen.is_empty(): z_.append(vergleich_tabelle(v.zeilen, de))
	return z_

# 416.9 (Chef 01.11., 11:30 „pseudotabellarisch“, 02.11., 10:52 „tabellarische Gegenüberstellung“): wie GearDetails alt,
# Kopf „Vergleich | Angelegt | Neu“ (1,8 : 0,9 : 0,9), Strich, je Wert eine Zeile; vorher matt, nachher fett in Gruen oder Rot
static func vergleich_tabelle(zeilen: Array, de: bool) -> Control:
	var t := VBoxContainer.new()
	t.add_theme_constant_override("separation", int(2 * DP))
	var spalte := func(text: String, sp: float, farbe: Color, anteil: float, fett := false) -> Label:
		var l := Stil.zeile(text, sp * 0.95, farbe, 0.2)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.size_flags_stretch_ratio = anteil
		if fett: l.add_theme_constant_override("outline_size", int(DP * 0.6)); l.add_theme_color_override("font_outline_color", farbe)
		return l
	var kopf := HBoxContainer.new()
	kopf.add_child(spalte.call("Vergleich" if de else "Compare", 15.0, Stil.TEXT, 1.8, true))
	kopf.add_child(spalte.call("Angelegt" if de else "Equipped", 13.7, Spielstaende.ANGABE if Spielstaende.vorlage2 else Stil.DIM, 0.9))   # Zu 557 (8)
	kopf.add_child(spalte.call("Neu" if de else "New", 13.7, Stil.DIM, 0.9))
	t.add_child(kopf)
	var strich := ColorRect.new()
	strich.color = Color(Stil.DIM, 0.35)
	strich.custom_minimum_size.y = maxf(1.0, DP)
	t.add_child(strich)
	for r in zeilen:
		var h := HBoxContainer.new()
		var besser := int(r["besser"])
		h.add_child(spalte.call(String(r["wort"]), 15.0, Stil.TEXT, 1.8))
		h.add_child(spalte.call(String(r["vorher"]), 15.0, Stil.DIM, 0.9))
		h.add_child(spalte.call(String(r["nachher"]), 15.0, {1: GRUEN, -1: Spielstaende.mangel()}.get(besser, Stil.DIM), 0.9, besser != 0))   # 557 Runde 5 (Prüfer 19:47: „1 W6+3“ in Warnfarbe)
		t.add_child(h)
		# 519 GearDetails: der Hinweis der Zeile (Obergrenze, Schnitt) darunter, 10 dp eingerueckt, matt
		if String(r.get("notiz", "")) != "":
			var n := MarginContainer.new()
			n.add_theme_constant_override("margin_left", int(10 * DP))
			n.add_child(Stil.txt(String(r["notiz"]), 12, Stil.DIM))
			t.add_child(n)
	return t

func im_beutel(g: Dictionary) -> int:
	for i in z.beutel.size():
		if int(z.beutel[i]["uid"]) == int(g["uid"]): return i
	return -1

# GameState.equipFromBag: was dafuer herunter muss, kommt in die Tasche
func lege_an(g: Dictionary, neben := false) -> String:
	var i := im_beutel(g)
	if i < 0 or not hw.kann_tragen(g): return ""
	var war := Menue.fackel(hw)
	z.beutel.remove_at(i)
	for x in (hw.anlegen_nebenhand(g) if neben else hw.anlegen(g)): z.beutel.append(x)
	var f := fackel_satz(war)
	return f if f != "" else "%s: %s" % [Beute.name(g), Sprache.u("equipped")]

func lege_ab(platz: String) -> void:
	var war := Menue.fackel(hw)
	var g = hw.ablegen(platz)
	if g != null: z.beutel.append(g)
	meldung(fackel_satz(war))

# 399.1 Light.torch: eine Fackel in der Nebenhand; torchChange: nur im Dunkeln (nachts draussen, in der Hoehle) sagt es etwas
var dunkel := false
static func fackel(h: BrsHeld) -> bool:
	var g = h.ding("OFF_HAND")
	return g != null and String(Beute.grundform(String(g["base"]))["art"]) == "LIGHT"

func fackel_satz(war: bool) -> String:
	if not dunkel or Menue.fackel(hw) == war: return ""
	return Sprache.t(Sprache.texte.get("benutzen", {}).get("torchLit" if Menue.fackel(hw) else "torchSnuffed", ""))

func frage_stueck(g: Dictionary) -> void:
	var de := Sprache.aktiv() == "de"
	var ok := hw.kann_tragen(g)
	if entwurf == "B":   # 557: Entwurf B, im Spiel weiter „“
		fenster_b(g)
		return
	var k: Array = [[Sprache.u("equip"), func(): meldung(lege_an(g)); baue(), ok]]
	if ok and einhandwaffe(g): k.append(["Nebenhand" if de else "Off hand", func(): meldung(lege_an(g, true)); baue()])
	k.append(["Wegwerfen" if de else "Discard", func(): frage_wegwerfen(g)])
	k.append([abbrechen(), func(): pass])
	dialog(Beute.name(g), farbe_von(g), stueck_zeilen(g), k)

func frage_wegwerfen(g: Dictionary) -> void:
	var de := Sprache.aktiv() == "de"
	var preis := Laden.verkaufspreis_von(hw, g)
	if not Bedienung.rueckfragen:   # 399.1 Rückfragen aus (MenuScreen.kt: if (!vm.confirmations) discard())
		wirf_weg(g)
		return
	if entwurf == "B" and Spielstaende.vorlage2:   # 557 Vorlage 2: Rueckfrage ohne Rahmen
		Spielstaende.frage(self, "Wirklich wegwerfen?" if de else "Really discard?", [
			Stil.txt(Menue.name_mit_seltenheit(g), 16, farbe_von(g)),
			Stil.txt(("Der Gegenstand ist danach verloren. Beim Händler bekämst du dafür %d Gold." if de else "The item will be gone for good. A trader would pay you %d gold for it.") % preis, 15)],
			"KREUZ", "Wegwerfen" if de else "Discard", Stil.WARN, func(): wirf_weg(g))
		return
	dialog("Wirklich wegwerfen?" if de else "Really discard?", farbe_von(g), [
		Stil.txt("%s (%s)" % [Beute.name(g), Sprache.t(BrsHeld.daten()["seltenheiten"][String(g["rarity"])].get("name", g["rarity"]))], 16, farbe_von(g)),
		Stil.txt(("Der Gegenstand ist danach verloren. Beim Händler bekämst du dafür %d Gold." if de else "The item will be gone for good. A trader would pay you %d gold for it.") % preis, 15)],
		[["Wegwerfen" if de else "Discard", func(): wirf_weg(g)], [abbrechen(), func(): pass]])

func wirf_weg(g: Dictionary) -> void:
	var i := im_beutel(g)
	if i >= 0: z.beutel.remove_at(i)
	meldung(("%s weggeworfen." if de_() else "%s discarded.") % Beute.name(g))
	baue()

func de_() -> bool: return Sprache.aktiv() == "de"

# 214: was in der Tasche an den Platz passt; die Nebenhand nimmt auch Einhandwaffen; Tragbares zuerst, dann Seltenheit, Stufe
func passend(platz: String) -> Array:
	var l: Array = z.beutel.filter(func(g): return String(Beute.grundform(String(g["base"]))["slot"]) == platz or (platz == "OFF_HAND" and einhandwaffe(g)))
	l.sort_custom(func(a, b):
		if hw.kann_tragen(a) != hw.kann_tragen(b): return hw.kann_tragen(a)
		return Menue.vor(a, b))
	return l

func platzname(platz: String) -> String: return Sprache.t(BrsHeld.daten()["plaetze"][platz])

# 557 (Chef 04.11., 12:38: „noch eine andere Stelle im Spiel im neuen Design dazupacken, um einen besseren Eindruck (vorher-nachher)
# zu gewinnen“): Wechselliste eines Platzes als Entwurf B „ohne Kasten“ (549a), im Spiel weiter „“ (Kasten wie alt) bis zum Urteil
static var entwurf := "B"   # 557 eingeschaltet (Archiv 05.11., 08:18: „557 wie gebaut“; Runde 5 Vorlage 2 mit Mängelton, Chef 04.11., 19:54)

func waehle(platz: String) -> void:
	if entwurf == "B":
		_waehle_b(platz)
		return
	var de := Sprache.aktiv() == "de"
	var l := passend(platz)
	var zeilen: Array = []
	if l.is_empty(): zeilen.append(Stil.txt("Nichts Passendes im Beutel." if de else "Nothing in the bag fits.", 15, Stil.DIM))
	var schleier := {}   # 399.1 (Test 139.10): ein Lambda haelt den Wert von damals; die Liste wird erst unten zum Kasten
	for g in l:
		# 521: Zeile wie in der Tasche; nicht Tragbares matt mit dem Grund darunter wie alt (MenuScreen choose)
		var p: Control = ausruestungszeile(g)   # 870.4: jeder darf alles tragen
		tippbar(p, func():
			schleier["k"].queue_free()
			dialog(Beute.name(g), farbe_von(g), stueck_zeilen(g), [[Sprache.u("equip"), func(): meldung(lege_an(g, platz == "OFF_HAND" and String(Beute.grundform(String(g["base"]))["slot"]) != "OFF_HAND")); baue(), hw.kann_tragen(g)],
				[Sprache.u("back"), func(): waehle(platz)]]))
		zeilen.append(p)
	schleier["k"] = dialog(platzname(platz), Stil.GOLD, zeilen, [[Sprache.u("back"), func(): pass]])   # 618

# 557 Entwurf B: ganzer Schirm schwarz, Titel ohne Rahmen mit Zierlinie, oben was angelegt ist (nur Auskunft, ohne „›“), darunter je
# Stueck eine Zeile zwischen feinen Goldlinien, ueber die ganze Breite antippbar (mindestens 56 dp, dunkel beim Antippen): links das
# Bild (Behaelter, Rahmen bleibt: 549a Punkt 5), Name in der Farbe der Seltenheit, darunter Art, Platz, Wert; rechts das Urteil
# (▲ besser, ▼ schlechter, ◆ gemischt: Chef 12:01 „das in der Mitte … wird gar nicht bewertet“) und goldenes „›“; nicht Tragbares
# matt mit dem Grund. Unten „‹ ZURÜCK“ als Nebenwahl. Antippen oeffnet das Fenster des Stuecks wie bisher (Anlegen, Zurueck).
func _waehle_b(platz: String) -> void:
	var de := Sprache.aktiv() == "de"
	var schirm := ColorRect.new()
	schirm.color = Color.BLACK
	schirm.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	schirm.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(schirm)
	var zu := func(): schirm.queue_free()
	Zurueck.melde(schirm, zu)
	var rand := MarginContainer.new()
	rand.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for sd in ["left", "right"]: rand.add_theme_constant_override("margin_" + sd, int(20 * DP))
	rand.add_theme_constant_override("margin_top", int(36 * DP)); rand.add_theme_constant_override("margin_bottom", int(16 * DP))
	schirm.add_child(rand)
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", 0)
	rand.add_child(spalte)
	var kopf := Stil.zeile(platzname(platz).to_upper(), 22, Stil.GOLD, 3.0)
	kopf.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spalte.add_child(kopf)
	spalte.add_child(Stil.luecke(6))
	spalte.add_child(Spielstaende.zier())
	spalte.add_child(Stil.luecke(8))
	var an = hw.ding(platz)
	var jetzt := HBoxContainer.new()
	jetzt.add_theme_constant_override("separation", int(14 * DP))
	jetzt.custom_minimum_size.y = 56 * DP
	var jt := Stil.zeile(("Angelegt" if de else "Equipped").to_upper(), 13, Spielstaende.ANGABE if Spielstaende.vorlage2 else Stil.DIM, 2.0)   # Zu 557 (8)
	jt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	jt.custom_minimum_size.x = 60 * DP
	jetzt.add_child(jt)
	if Spielstaende.vorlage2 and an != null:   # Pruefer 07:46 (557a B): nur dem Angelegten fehlte das Bild, jede Zeile darunter hat eines
		var jb := Menue.bild_feld("stueck-%s-%s" % [an["base"], an["rarity"]], 40)
		jb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		jetzt.add_child(jb)
	var jn := Stil.zeile(Beute.name(an) if an != null else ("nichts" if de else "nothing"), 16, farbe_von(an) if an != null else Stil.DIM)
	jn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	jn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	jn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if an != null:   # Helfer 13:04: angelegt nur der Name; darunter Art, Platz, Wert wie in den Zeilen
		var jv := VBoxContainer.new()
		jv.add_theme_constant_override("separation", int(2 * DP))
		jv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		jv.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		jv.add_child(jn)
		var ju := Menue.listen_zeile_b(an)
		if ju != "": jv.add_child(Stil.zeile(ju, 13, Stil.DIM))
		jetzt.add_child(jv)
	else: jetzt.add_child(jn)
	spalte.add_child(jetzt)
	spalte.add_child(Spielstaende.linie())
	var rolle := ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	rolle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spalte.add_child(rolle)
	var liste := VBoxContainer.new()
	liste.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	liste.add_theme_constant_override("separation", 0)
	rolle.add_child(liste)
	var l := passend(platz)
	if l.is_empty(): liste.add_child(Stil.txt("Nichts Passendes im Beutel." if de else "Nothing in the bag fits.", 15, Stil.DIM))
	for g in l:
		if liste.get_child_count() > 0: liste.add_child(Spielstaende.linie())
		liste.add_child(_wechsel_zeile_b(g, platz, zu, de))
	spalte.add_child(Spielstaende.linie())
	if Spielstaende.vorlage2:   # 557 Runde 4 (Chef 17:40, 549a (9)): „‹ ZURÜCK“ links, nicht mittig, so gross wie jeder Knopf
		spalte.add_child(Spielstaende.knopfzeile(Spielstaende.knopf("neben", Sprache.u("back"), zu, true), null))
		Spielstaende.folge_inhalt(spalte, rolle, liste)   # 557a B: „Zurück“ am Inhalt, fest unten nur, wenn die Liste rollt
		Menue.wuerfel_lesbar(spalte)
		return
	var z := HBoxContainer.new()
	z.custom_minimum_size.y = 52 * DP
	z.alignment = BoxContainer.ALIGNMENT_CENTER
	z.mouse_filter = Control.MOUSE_FILTER_IGNORE
	z.add_child(Stil.zeile("‹  " + Sprache.u("back").to_upper(), 14, Stil.GOLD, 2.0))   # Nebenwahl (549a Punkt 4)
	spalte.add_child(Spielstaende.tippbar(z, zu))

# 557 (Helfer 13:07: Roben zeigten keinen Wert, nur der Plattenpanzer „RK 18“): ohne Kennwert (Roben, Ringe, Umhaenge …) stehen die zwei
# ersten Boni kurz an seiner Stelle („+2 GES · +2 RK“), damit jede Zeile eine Zahl hat; sonst wie Gear.listLine
static func listen_zeile_b(g: Dictionary) -> String:
	var t := Beute.listen_zeile(g)
	if Beute.kennwert(g) != "" or g.get("rolls", []).is_empty(): return t
	var teile: Array = []
	for r in g["rolls"]:     # 870.7: Zusatzeigenschaften nach dem BRS im Wortlaut des Fensters (Beute.zusatz_text)
		teile.append(Beute.zusatz_text(r))
		if teile.size() == 2: break
	var k := " · ".join(PackedStringArray(teile)) + (" …" if g["rolls"].size() > 2 else "")
	return k if t == "" else t + " · " + k

func _wechsel_zeile_b(g: Dictionary, platz: String, zu: Callable, de: bool) -> Control:
	var ok := hw.kann_tragen(g)
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(14 * DP))
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.custom_minimum_size.y = 64 * DP
	var bild := Menue.stueck_rahmen(g, 46)
	bild.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if not ok: bild.modulate.a = 0.5
	r.add_child(bild)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(2 * DP))
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var n := Stil.zeile(Beute.name(g), 16, farbe_von(g) if ok else Color(farbe_von(g), 0.5))
	n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	n.custom_minimum_size.x = 60 * DP
	v.add_child(n)
	var unten := Menue.listen_zeile_b(g)
	if unten == "": unten = Testmodus.gross_anfang(Sprache.t(BrsHeld.daten()["seltenheiten"][String(g["rarity"])].get("name", g["rarity"])))
	if zweihaendig(g) and not unten.containsn("zweih") and not Beute.name(g).containsn("zweih"): unten += " · " + ("zweihändig" if de else "two-handed")
	var u = Vergleich.von(hw, g).urteil() if ok else null
	var wort := ""
	if u == 1: wort = "besser" if de else "better"
	elif u == -1: wort = "schlechter" if de else "worse"
	elif u == 0: wort = "gemischt" if de else "mixed"
	if wort != "": unten += " · " + wort
	# 521 (Chef 03.11., 23:23, „nicht tragbar“ matt mit dem Grund; seit 644a A die Mindeststufe): wie die Zeile der Tasche
	if not ok: unten += " · " + ("nicht tragbar" if de else "can't wear")
	var ul := Stil.zeile(unten, 13, Stil.DIM if ok else Color(Stil.DIM, 0.6))
	ul.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ul.custom_minimum_size.x = 60 * DP
	v.add_child(ul)
	r.add_child(v)
	if u != null:
		var pf := Stil.zeile("▲" if u == 1 else ("▼" if u == -1 else "◆"), 18, GRUEN if u == 1 else (Spielstaende.mangel() if u == -1 else Stil.BRIGHT))   # wie das Fenster
		pf.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		r.add_child(pf)
	var c := Control.new()   # goldenes „›“ wie die Hauptwahl der Spielstaende
	c.custom_minimum_size = Vector2(9 * DP, 16 * DP)
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(func():
		var m := c.size / 2
		var a := 4.0 * DP
		c.draw_polyline(PackedVector2Array([m + Vector2(-a * 0.55, -a * 1.5), m + Vector2(a * 0.75, 0), m + Vector2(-a * 0.55, a * 1.5)]), Stil.BRIGHT if ok else Color(Stil.DIM, 0.6), 1.8 * DP, true))
	r.add_child(c)
	var rand := MarginContainer.new()
	rand.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rand.add_theme_constant_override("margin_top", int(6 * DP)); rand.add_theme_constant_override("margin_bottom", int(6 * DP))
	rand.add_child(r)
	return Spielstaende.tippbar(rand, func():
		zu.call()
		fenster_b(g, func(): meldung(lege_an(g, platz == "OFF_HAND" and String(Beute.grundform(String(g["base"]))["slot"]) != "OFF_HAND")); baue(), func(): waehle(platz)))

# ---------------------------------------------------------------- 557 / 524.1 Gegenstandsfenster im Stil B
# Chef 04.11., 13:32 („524.1 nach B in 557“): der aeussere Goldrahmen bleibt (Entscheidung, 549a (3)), innen nur Linien und Abstand.
# Kopf: Bild (Behaelter mit Rahmen der Seltenheit, 549a (5)), Name in seiner Farbe, darunter Seltenheit und Art; gleich darunter das Urteil
# als Zeile (▲ gruen „Besser“, ▼ rot „Schlechter“, ◆ gold „Gemischt“, dieselben Zeichen wie die Wechselliste) und was abgelegt wird.
# Dann die Grundzahlen (Tragort, Schaden oder RK, Finesse und Fernkampf erklaert), die Boni in Gold (kein Hellblau), verpuffte und zum
# Teil verpuffte matt mit „wirkt nicht“ oder „wirkt +n (Obergrenze)“, die Warnungen, die Tabelle, „Händler zahlt n Gold“. Unten
# „× WEGWERFEN“ als Nebenwahl links, „ANLEGEN ›“ als Hauptwahl rechts; Abbrechen ueber Zurueck oder Tippen daneben (526).
# [anlegen]: was „Anlegen“ tut (Tasche: lege_an; Wechselliste: an den gewaehlten Platz); [zurueck]: wohin Zurueck fuehrt (sonst nur zu)
func fenster_b(g: Dictionary, anlegen := Callable(), zurueck := Callable()) -> Control:
	var de := Sprache.aktiv() == "de"
	var ok := hw.kann_tragen(g)
	var h := {}
	var schleier := Rueckfrage.schleier(self, func():
		(h["s"] as Node).queue_free()
		if zurueck.is_valid(): zurueck.call())
	h["s"] = schleier
	schleier.color = Color(0, 0, 0, 0.86)
	var mitte: Container = Spielstaende.oben() if Spielstaende.vorlage2 else CenterContainer.new()   # 557a B: oben wie jeder Schirm
	mitte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mitte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	schleier.add_child(mitte)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(8 * DP))
	var breite := get_viewport_rect().size.x - 2 * 16 * DP - 2 * 14 * DP
	if Spielstaende.vorlage2:   # Zu 557 (1), (2) (Chef 16:42: „beim Gegenstand neu, da ist er noch rum“): ohne Rahmen wie Rueckfrage
		# und Mengenkasten, so breit wie sie, Grund deckend (Pruefer 16:43: Reiterkacheln, Seitenkasten, SCHLIESSEN schienen durch)
		schleier.color = Color.BLACK
		breite = get_viewport_rect().size.x - 48 * DP
	v.custom_minimum_size.x = breite
	mitte.add_child(Rueckfrage.halte(v if Spielstaende.vorlage2 else Stil.rahmen(v)))
	var inhalt: VBoxContainer = v
	if Spielstaende.vorlage2:   # 605 (Chef 08.11., 15:57, Bild t268-kopffeld): bei vielen Boni und Notizen im Vergleich lag der Fuss unter dem Schirm
		inhalt = _rollend(v)
	for c in Menue.stueck_zeilen_b(hw, g): inhalt.add_child(c)
	inhalt.add_child(Spielstaende.linie())
	var zu := func(): schleier.queue_free()
	var an_c := anlegen if anlegen.is_valid() else func(): meldung(lege_an(g)); baue()
	if Spielstaende.vorlage2:   # 557 Vorlage 2 (Chef 14:26): „‹ ABBRECHEN“ links, ANLEGEN rechts
		# 557 Runde 4 (Chef 17:44, Variante B): Wegwerfen und Nebenhand echte Knoepfe, so gross wie Abbrechen und Anlegen, in zwei Reihen
		# zu je zwei: oben „× WEGWERFEN“ (Warnfarbe wie in der Rueckfrage, Chef 17:43) links und „NEBENHAND ›“ rechts, unten „‹ ABBRECHEN“
		# und „ANLEGEN ›“ (Pruefer 17:12: Wegwerfen und Nebenhand standen zu nah beieinander)
		var oben: Array = [Spielstaende.knopf("gefahr", "Wegwerfen" if de else "Discard", func(): zu.call(); frage_wegwerfen(g), true)]
		if ok and einhandwaffe(g) and not anlegen.is_valid():
			oben.append(Spielstaende.knopf("neben", "Nebenhand" if de else "Off hand", func(): zu.call(); meldung(lege_an(g, true)); baue()))
		v.add_child(Spielstaende.fuss(func(): schleier.queue_free(); if zurueck.is_valid(): zurueck.call(), "", Sprache.u("equip"), Stil.BRIGHT, func(): zu.call(); an_c.call(), ok, oben))
		Menue.wuerfel_lesbar(v)
		return schleier
	var unten := HBoxContainer.new()
	unten.mouse_filter = Control.MOUSE_FILTER_IGNORE
	unten.add_child(Spielstaende.nebenwahl("KREUZ", "Wegwerfen" if de else "Discard", func(): zu.call(); frage_wegwerfen(g)))
	var mitte_ := Control.new()
	mitte_.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mitte_.mouse_filter = Control.MOUSE_FILTER_IGNORE
	unten.add_child(mitte_)
	var an_ := anlegen if anlegen.is_valid() else func(): meldung(lege_an(g)); baue()
	if ok and einhandwaffe(g) and not anlegen.is_valid():
		unten.add_child(Spielstaende.nebenwahl("", "Nebenhand" if de else "Off hand", func(): zu.call(); meldung(lege_an(g, true)); baue()))
	unten.add_child(Spielstaende.hauptwahl(Sprache.u("equip"), func(): zu.call(); an_.call(), ok))
	v.add_child(unten)
	return schleier

# 605 (Chef 08.11., 15:57: aus leerem Kopffeld die goettliche Kapuze, „nur Wegwerfen, kein Anlegen“, Zurueck fehlt; Bild t268-kopffeld):
# Kopf, Boni und Vergleich (je gedeckeltem Attribut eine Notiz in zwei Zeilen) wurden hoeher als der Schirm, „Abbrechen“ und „Anlegen“
# lagen darunter. Wie alt (Dialogs.kt 64–104: Inhalt in verticalScroll mit heightIn, Knoepfe fest darunter): der Inhalt rollt in [v],
# so hoch er ist, hoechstens bis der Fuss unten noch ganz im Schirm steht; besser als alt: die Hoehe aus dem Schirm statt fester 520 dp.
# Gibt die Spalte zurueck, in die der Inhalt kommt; was danach in [v] kommt (der Fuss), steht unter der Rolle fest.
func _rollend(v: VBoxContainer) -> VBoxContainer:
	var rolle := ScrollContainer.new()
	rolle.name = "Rolle"
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	v.add_child(rolle)
	var innen := VBoxContainer.new()
	innen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	innen.add_theme_constant_override("separation", v.get_theme_constant("separation"))
	rolle.add_child(innen)
	var passe := func():
		if not is_instance_valid(rolle) or not rolle.is_inside_tree(): return
		var fuss := 0.0
		for c in v.get_children():
			if c != rolle and c is Control and (c as Control).visible: fuss += (c as Control).get_combined_minimum_size().y + v.get_theme_constant("separation")
		var frei := get_viewport_rect().size.y - Spielstaende.OBEN_DP * DP - 16 * DP - fuss
		var h := minf(innen.get_combined_minimum_size().y, maxf(0.0, frei))
		if absf(rolle.custom_minimum_size.y - h) > 0.5: rolle.custom_minimum_size.y = h
	innen.minimum_size_changed.connect(passe)
	v.child_entered_tree.connect(func(_k): passe.call_deferred())
	get_viewport().size_changed.connect(passe)
	rolle.tree_exiting.connect(func(): if get_viewport().size_changed.is_connected(passe): get_viewport().size_changed.disconnect(passe))
	passe.call_deferred()
	return innen

# Name mit Seltenheit in Klammern, „Göttlicher Ring Thors“ ohne „(göttlich)“ dahinter: steht sie schon im Namen, nicht doppelt
# (Pruefer 17:12 zur Rueckfrage Wegwerfen)
static func name_mit_seltenheit(g: Dictionary) -> String:
	var n := Beute.name(g)
	var s := Sprache.t(BrsHeld.daten()["seltenheiten"][String(g["rarity"])].get("name", g["rarity"]))
	return n if n.containsn(s) else "%s (%s)" % [n, s]

# Pruefer 17:12: „1W6“ liest sich in Alegreya wie „IW6“ (die Eins ist dort ein I mit Faehnchen, auch in den Ziffernformen lnum, tnum):
# nur in der Darstellung ein festes Leerzeichen zwischen Anzahl und W („1 W6“), der Wuerfeltext aus den Daten bleibt
const _WUERFEL := "(\\d)W(\\d)"
static func wuerfel_lesbar(wurzel: Node) -> void:
	var re := RegEx.create_from_string(_WUERFEL)
	for l in wurzel.find_children("*", "Label", true, false):
		if re.search(l.text): l.text = re.sub(l.text, "$1\u00a0W$2", true)

static func stueck_zeilen_b(hw: BrsHeld, g: Dictionary) -> Array:
	var de := Sprache.aktiv() == "de"
	var sp := "de" if de else "en"
	var d := BrsHeld.daten()
	var b := Beute.grundform(String(g["base"]))
	var farbe := Color(SELTEN.get(String(g["rarity"]), "e6ddcb"))
	var fett := func(l: Label) -> Label:
		l.add_theme_constant_override("outline_size", int(DP * 0.6)); l.add_theme_color_override("font_outline_color", l.get_theme_color("font_color"))
		return l
	var satz := func(t: String, gr: float, f: Color) -> Label:
		var l := Stil.zeile(Spielstaende.ohne_waise(t), gr, f)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = 60 * DP
		return l
	var z_: Array = []
	# Kopf
	var kopf := HBoxContainer.new()
	kopf.add_theme_constant_override("separation", int(12 * DP))
	if Spielstaende.vorlage2:   # Zu 557 (1): Bild im Kopf frei, ohne Goldkaestchen (wie der Mengenkasten)
		var bf := Menue.bild_feld("stueck-%s-%s" % [g["base"], g["rarity"]], 48)
		bf.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		kopf.add_child(bf)
	else: kopf.add_child(Menue.stueck_rahmen(g, 52))
	var kv := VBoxContainer.new()
	kv.add_theme_constant_override("separation", int(2 * DP))
	kv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Pruefer 07:46 (557a B): der Name stand mittig neben dem Bild 29 px tiefer als jeder Titel; oben wie der Kopf jedes Fensters
	kv.size_flags_vertical = Control.SIZE_SHRINK_BEGIN if Spielstaende.vorlage2 else Control.SIZE_SHRINK_CENTER
	# 870.7: kein „+n“ mehr am Namen (557 Runde 5); die Guete steht unten bei den Grundzahlen ([870.14.ding.guete])
	var nl: Label = fett.call(satz.call(Beute.name(g), 19, farbe))
	kv.add_child(nl)
	var selten := Testmodus.gross_anfang(Sprache.t(d["seltenheiten"][String(g["rarity"])]["name"]))
	var art := String(b[sp])
	var art_z := selten + ((String(d["endungen"][String(b["geschlecht"])]) if de else "") + " " + art if not Beute.name(g).containsn(art) else "")
	if Spielstaende.vorlage2 and Beute.name(g).containsn(art) and Beute.name(g).containsn(selten):   # Pruefer 17:12: „Göttlicher Ring …“, darunter
		art_z = ""   # noch einmal „Göttlich“: was der Name sagt, steht nicht doppelt da (wie stueck_zeilen, 524)
	if art_z != "": kv.add_child(satz.call(art_z, 13, Color(farbe, 0.8)))
	kopf.add_child(kv)
	z_.append(kopf)
	if Spielstaende.vorlage2: z_.append(Spielstaende.zier())   # Chef 16:51 (549a (8)): Kopf zuerst, gleich darunter die Zierlinie
	# Urteil als Zeile (statt Band): Zeichen und Satz in der Farbe des Urteils, darunter was abgelegt wird
	var v: Vergleich = Vergleich.von(hw, g) if hw.kann_tragen(g) and not hw.ausruestung.values().any(func(x): return x != null and int(x["uid"]) == int(g["uid"])) else null
	if v:
		var u = v.urteil()
		var uf: Color = {1: GRUEN, -1: Spielstaende.mangel(), 0: Stil.BRIGHT}.get(u, Stil.DIM)
		var ur := HBoxContainer.new()
		ur.add_theme_constant_override("separation", int(8 * DP))
		if u != null:
			var zl := Stil.zeile({1: "▲", -1: "▼", 0: "◆"}[u], 17, uf)
			zl.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			ur.add_child(zl)
		var ut: Label = fett.call(satz.call(v.satz(), 15, uf))
		ut.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ur.add_child(ut)
		z_.append(ur)
		if not v.ersetzt.is_empty():
			var anderer := v.ersetzt.any(func(x): return String(Beute.grundform(String(x["base"]))["slot"]) != String(b["slot"]))
			z_.append(satz.call(("Ersetzt: " if de else "Replaces: ") + ", ".join(PackedStringArray(v.ersetzt.map(func(x): return Beute.name(x)))), 13, Spielstaende.mangel() if anderer else Stil.DIM))
	# 549a (8): keine zweite schlichte Linie unter der Zierlinie; Abstand statt Linie
	z_.append(Stil.luecke(4) if Spielstaende.vorlage2 else Spielstaende.linie())
	# Grundzahlen
	var waffe := Beute.ist_waffe(b)
	var zwei := waffe and bool(b["zweihaendig"])
	var wo := String(d["plaetze"][String(b["slot"])][sp])
	if zwei: wo = "Beide Hände" if de else "Both hands"
	elif waffe: wo = "Haupt- oder Nebenhand" if de else "Main or off hand"
	wo += (" · Stufe " if de else " · Level ") + str(int(g["ilvl"]))
	var gewicht := String(b.get("gewicht", "NONE"))
	if gewicht != "NONE": wo += " · " + Sprache.t(d["ruestungsarten"].get(gewicht, {"de": "Stoff", "en": "cloth"}))
	var wl: Label = satz.call(wo, 13.5 if Spielstaende.vorlage2 else 13.0, Spielstaende.mangel() if zwei else (Spielstaende.ANGABE if Spielstaende.vorlage2 else Stil.DIM))   # Zu 557 (8)
	z_.append(fett.call(wl) if zwei else wl)
	if String(b["art"]) == "LIGHT":
		z_.append(satz.call("Pech und Werg auf einem Stock. In der Nebenhand, statt eines Schilds. Im Dunkeln siehst du weiter als mit einem Leuchtfunken. Brennt, solange du sie trägst." if de else
			"Pitch and tow on a stick. Held in the off hand, instead of a shield. In the dark you see further than with a Lightspark. Burns as long as you carry it.", 14, Stil.TEXT))
	# 870.7 ([870.14.ding.…]): wie stueck_zeilen_von: Schaden mit Guete (944: ohne Würfel), Grundwert, Schutzwert mit Guete, Guete, Fertigkeit
	if waffe:
		z_.append(fett.call(satz.call(schaden_text(g, de), 16, Stil.TEXT)))
		z_.append(satz.call(grundwert_text(g, de), 13, Stil.DIM))
	elif hat_kennwert(g):
		z_.append(fett.call(satz.call(("Schutzwert %d" if de else "Protection %d") % Beute.schutzwert(g), 16, Stil.TEXT)))
	if hat_kennwert(g): z_.append(satz.call(guete_text(g, de), 14, Stil.TEXT))
	if fertigkeit_text(g, de) != "": z_.append(satz.call(fertigkeit_text(g, de), 13, Stil.DIM))
	# Boni: wirksam in Gold; was die Obergrenze ganz oder zum Teil schluckt, matt mit dem, was wirkt
	if not g.get("rolls", []).is_empty():
		z_.append(Spielstaende.linie())
		var wk := Vergleich.wirkung(hw, g) if hw.kann_tragen(g) else {}
		for r in g["rolls"]:
			var a := String(r[0]); var w := int(r[1])
			var t := Beute.zusatz_text(r)     # 870.7: Wortlaut STORY-BRS-HELD.md
			var e: Array = wk.get(a, [w, w]) if a != "SKILL" else [w, w]     # Fertigkeit +n hat keine Obergrenze (BrsHeld.fertigkeit_bonus)
			if e.size() > 2 and int(e[1]) != int(e[2]):   # alle Attribute: je Attribut verschieden viel (Helfer 14:18: „wirkt nur teils“ sagte zu wenig)
				z_.append(satz.call(t + (" – wirkt +%d bis +%d (Obergrenze)" if de else " – gives +%d to +%d (limit)") % [int(e[1]), int(e[2])], 15, Stil.DIM))
			elif int(e[1]) == 0: z_.append(satz.call(t + (" – wirkt nicht (Obergrenze)" if de else " – no effect (limit)"), 15, Stil.DIM))
			elif int(e[1]) < w:
				var pz := "%" if Beute.zusatz_prozent(a) else ""
				z_.append(satz.call(t + (" – wirkt +%d%s (Obergrenze)" if de else " – gives +%d%s (limit)") % [int(e[1]), pz], 15, Stil.DIM))
			else: z_.append(satz.call(t, 16, Stil.BRIGHT))
	# Warnungen (870.4: Tragen nach BRS)
	for t in Menue.tragen_hinweise(hw, g): z_.append(satz.call(t[0], 15 if t[1] else 13, Spielstaende.mangel() if t[1] else Stil.DIM))
	# Helfer 14:18: die Sammelzeile „Attribute: … Bonus wirkt nicht“ der Tabelle widersprach den Bonuszeilen („wirkt +1“: was das Stueck
	# selbst bringt; die Sammelzeile: gegen das, was es ersetzt). Jede Bonuszeile sagt schon, was die Obergrenze schluckt: hier ohne sie.
	# 701 (Chef 08.11., 20:37 „wirkt überbordend“): ohne jede Zeile, die nur den Deckel wiederholt („doppelt“, Vergleich.von)
	var tz: Array = v.zeilen.filter(func(x): return not bool(x.get("doppelt", false))) if v else []
	if not tz.is_empty():
		z_.append(Spielstaende.linie())
		z_.append(vergleich_tabelle(tz, de))
	if Laden.ausruestung_verkaeuflich(g):
		z_.append(satz.call(("Händler zahlt %d Gold" if de else "A trader pays %d gold") % Laden.verkaufspreis_von(hw, g), 13.5 if Spielstaende.vorlage2 else 13.0, Stil.BRIGHT if Spielstaende.vorlage2 else Stil.GOLD))   # Zu 557 (8)
	return z_

# PaperDoll: links Kopf, Umhang, Oberkoerper, Arme, Beine; rechts Amulett, Ring, Haupthand, Nebenhand; der Held dazwischen
func ausruestung() -> void:
	var de := Sprache.aktiv() == "de"
	var puppe := HBoxContainer.new()
	# 581 (Abgleich 512b): 2 × 96 + 165 + 2 × 6 dp waren 369 dp in 361 dp Kasten, die Seite wurde 16 px breiter und die Reiter
	# sprangen; mit 2 dp Abstand passt die Puppe bei Figur in alter Groesse (520)
	puppe.add_theme_constant_override("separation", int(2 * DP))
	for seite in [["HEAD", "CLOAK", "CHEST", "ARMS", "LEGS"], ["AMULET", "RING", "MAIN_HAND", "OFF_HAND"]]:
		var spalte := VBoxContainer.new()
		spalte.add_theme_constant_override("separation", int(4 * DP))
		spalte.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		for platz in seite: spalte.add_child(fach(platz))
		puppe.add_child(spalte)
		if seite[0] == "HEAD":
			# 520 (Chef 03.11., 23:19 „Warum ist der Held so klein?“, 23:21 „Größe jetzt“): wie PaperDoll alt (GearUi.kt 274)
			# HeroTurntable mit 1,1 dp je Bildpunkt (150 × 230), nicht 0,62 wie im Reiter Held
			var t := Drehteller.new(HeldFigur.wahl(hw, z), 1.1)
			t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			puppe.add_child(t)
	inhalt.add_child(puppe)
	luecke(10)
	zeile(("Kampfwerte" if de else "Combat stats").to_upper(), 14, Stil.GOLD).add_theme_font_override("font", Stil.variante(3.0))
	# 870.4 ([870.14.kw.…]): Leben, Mana, Ausdauer, Schutzwert, Schaden als Zahl, Kritisch in Prozent; Magiefund bleibt (13 offen)
	var i := 0 if de else 1
	wert_zeile(KAMPFWERT["leben"][i], "%d/%d" % [hw.leben, hw.max_leben()])
	if hw.max_mana() > 0: wert_zeile(KAMPFWERT["mana"][i], "%d/%d" % [hw.mana, hw.max_mana()])
	wert_zeile(KAMPFWERT["ausdauer"][i], str(roundi(hw.ausdauer_s())))
	wert_zeile(KAMPFWERT["schutz"][i], str(hw.schutzwert()))
	wert_zeile(KAMPFWERT["schaden"][i], str(hw.schaden()))
	wert_zeile(KAMPFWERT["krit"][i], ("%d %%" if de else "%d%%") % hw.krit_prozent())
	var ad: Dictionary = BrsHeld.daten()["affixdaten"]
	if hw.bonus("MAGIC_FIND") > 0: wert_zeile(Sprache.t(ad["MAGIC_FIND"]["name"]), "+%d%%" % hw.bonus("MAGIC_FIND"))

func wert_zeile(wort: String, wert: String) -> void:
	var r := HBoxContainer.new()
	r.add_child(Stil.txt(wort, 15))
	var w := Stil.txt(wert, 15, Stil.BRIGHT)
	w.size_flags_horizontal = Control.SIZE_FILL
	w.autowrap_mode = TextServer.AUTOWRAP_OFF
	r.add_child(w)
	inhalt.add_child(r)

# 399.1 Bilder der Dinge wie alt (SupplyPicture 36 dp, GearIcon: dunkler Grund mit einem Hauch der Seltenheit, Rand in ihrer Farbe,
# das Bild auf 78 %), gezeichnet im Bau von core (ThingArtExport: daten/ding-<id>.bild, stueck-<grundform>-<seltenheit>.bild), Pixel scharf
static func bild_feld(name: String, dp: float) -> Control:
	var t := TextureRect.new()
	t.texture = Kartenreiter.bild(name)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	t.custom_minimum_size = Vector2(dp, dp) * DP
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

static func vorrat_bild(id: String) -> Control: return bild_feld("ding-" + id, 36)

static func stueck_rahmen(g: Dictionary, dp: float) -> Control:
	var farbe := Color(SELTEN.get(String(g["rarity"]), "e6ddcb"))
	var p := PanelContainer.new()
	var st := Stil.kasten(Color("0e0c0a").lerp(farbe, 0.16), farbe, 2.0 if Beute.stufe_von(String(g["rarity"])) >= Beute.stufe_von("EPIC") else 1.0)
	st.set_corner_radius_all(int(3 * DP))
	p.add_theme_stylebox_override("panel", st)
	p.custom_minimum_size = Vector2(dp, dp) * DP
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var c := CenterContainer.new()
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(bild_feld("stueck-%s-%s" % [g["base"], g["rarity"]], dp * 0.78))
	p.add_child(c)
	var b := Beute.grundform(String(g["base"]))
	if Beute.ist_waffe(b) and bool(b["zweihaendig"]):   # „2H“ oben rechts, unten sitzen die Steine der Seltenheit
		var t := Stil.zeile("2H", clampf(dp / 5.0, 8.0, 12.0), Stil.GOLD)
		var ts := Stil.kasten(Color(0, 0, 0, 0.88), Color(0, 0, 0, 0), 0.0)
		ts.content_margin_left = 2 * DP; ts.content_margin_right = 2 * DP
		t.add_theme_stylebox_override("normal", ts)
		t.size_flags_horizontal = Control.SIZE_SHRINK_END
		t.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		p.add_child(t)
	return p

# ein Platz: Rahmen mit Bild und Namen des Getragenen in seiner Farbe, darunter der Platz; eine Zweihandwaffe
# fuellt auch die Nebenhand
func fach(platz: String) -> Control:
	var zwei := platz == "OFF_HAND" and zweihaendig(hw.waffe())
	var g = hw.waffe() if zwei else hw.ding(platz)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.custom_minimum_size.x = 96 * DP
	var rahmen := PanelContainer.new()
	rahmen.add_theme_stylebox_override("panel", Stil.kasten(Color.BLACK, Stil.LINE if g == null else farbe_von(g), 1.0))
	rahmen.custom_minimum_size = Vector2(96, 56) * DP
	rahmen.size_flags_horizontal = Control.SIZE_FILL
	rahmen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Helfer an der Probe 17:11: lange Namen („Arkanes Heiligensymbol des Gelehrten“) stiessen an den Rahmen und brachen ab:
	# 96 dp breit, 13 sp (DESIGN-STIL „Oberfläche“: mindestens 13 sp), bis drei Zeilen, sonst mit Auslassung
	var n := Stil.zeile(Beute.name(g) if g != null else "–", 13.0, farbe_von(g) if g != null else Stil.DIM, 0.0)
	n.autowrap_mode = TextServer.AUTOWRAP_WORD   # Helfer 17:24: WORD_SMART trennte „Heiligensymb/ol“ mitten im Wort
	n.custom_minimum_size.x = 90 * DP
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	n.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	n.max_lines_visible = 3
	n.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if zwei: n.modulate.a = 0.5
	if g != null:   # 399.1: das Bild ueber dem Namen
		var sp := VBoxContainer.new()
		sp.add_theme_constant_override("separation", 0)
		sp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var b := Menue.bild_feld("stueck-%s-%s" % [g["base"], g["rarity"]], 40)
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		if zwei: b.modulate.a = 0.5
		sp.add_child(b)
		n.max_lines_visible = 2
		sp.add_child(n)
		rahmen.add_child(sp)
	else: rahmen.add_child(n)
	v.add_child(rahmen)
	var p := Stil.txt(platzname(platz), 11, Stil.DIM)
	p.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(p)
	tippbar(v, func(): tippe_fach("MAIN_HAND" if zwei else platz))
	return v

func tippe_fach(platz: String) -> void:
	var de := Sprache.aktiv() == "de"
	var g = hw.ding(platz)
	if g == null: waehle(platz); return
	var k: Array = [[Sprache.u("unequip"), func(): lege_ab(platz); baue()]]
	if not passend(platz).is_empty(): k.append(["Wechseln" if de else "Swap", func(): waehle(platz)])
	k.append([abbrechen(), func(): pass])   # 618: angelegtes Stueck „Abbrechen“ statt „Schließen“
	dialog(Beute.name(g), farbe_von(g), stueck_zeilen(g), k)

# ---------------------------------------------------------------- System (SystemSigns)
# 425 (Chef 31.10., 21:30 zu Build 143: alte Menues mit Zeichen „super klasse“, neue „viel zu viel Text“) wie alt (MenuSigns.kt
# SystemSigns, 326): oben die Version, dann vier Gruppen von Zeichen statt Knoepfen mit Saetzen: „Spiel“ (Speichern, Sprache,
# Hauptmenü; Anleitung, Über), „Kampf“ (Blut, Tempo, Kampftext, Rückfragen), „Bedienung“ (Steuerung, Joystick und Rennen nur beim
# Wischen, Aktion; Karte, Rütteln, Schritte). Antippen wechselt, Gedrueckthalten erklaert (erklaere_zeichen); Regler fuer Klang und
# Licht bleiben; unten Schritte und Siege, Geraet. Die MARS-Probe (alt „M“) folgt mit ihrem Schirm (Jerry).
const HINWEIS := {"de": "Halte ein Zeichen gedrückt, und es erklärt sich.", "en": "Press and hold a sign to see what it does."}

func system() -> void:
	var de := Sprache.aktiv() == "de"
	Bedienung.lade()
	if not Bedienung.zeichen_gesehen:   # alt signHintSeen: der Hinweis wartet auf das erste Oeffnen
		Bedienung.zeichen_gesehen = true
		Bedienung.speichere()
		meldung(Sprache.t(HINWEIS))
	var t := func(d: String, e: String) -> String: return d if de else e
	var an := func(b: bool) -> String: return t.call("An", "On") if b else t.call("Aus", "Off")
	var ver := String(ProjectSettings.get_setting("application/config/version", ""))
	luecke(6)
	zeile("Version %s (Build %s)" % [ver, ver.get_slice(".", ver.get_slice_count(".") - 1)] if ver != "" else "Version –", 13, Stil.DIM)
	luecke(10)
	var z_ := func(name_: String, wert, satz: String, tut: Callable, an_ := true, zeichen_ := "", buchstabe := "") -> Zeichenknopf:
		return Zeichenknopf.new(name_, wert, satz, func(): _tue(tut), erklaere_zeichen, an_, zeichen_, buchstabe)
	var spar := func(tut: Callable) -> Callable: return func(): tut.call(); Bedienung.speichere()
	gruppe(t.call("Spiel", "Game"))
	zeichenreihe([z_.call(t.call("Speichern", "Save"), null, t.call("Hält deinen Stand jetzt fest. Beim Verlassen des Spiels und auf dem Weg ins Hauptmenü speichert es ohnehin.",
			"Saves your progress now. The game also saves when you leave it or go to the main menu."), func(): speichern.emit(); meldung(Sprache.u("saved")), true, "SAVE"),
		z_.call(t.call("Sprache", "Language"), null, t.call("Wechselt zwischen Deutsch und Englisch.", "Switches between German and English."), func(): sprache.emit(), true, "",
			"DE" if de else "EN"),
		z_.call(t.call("Hauptmenü", "Main menu"), null, t.call("Speichert und kehrt zum Hauptmenü zurück.", "Saves and returns to the main menu."), func(): hauptmenue.emit(), true, "MENU")])
	# 352: was zu lesen ist, in einer eigenen Reihe
	var a: Dictionary = Sprache.texte.get("anleitung", {})
	zeichenreihe([z_.call(Sprache.t(a.get("zeichen", {"de": "Anleitung", "en": "Guide"})), null, Sprache.t(a.get("hinweis", "")), anleitung, true, "RULES"),
		z_.call(t.call("Über", "About"), null, t.call("Wer das Spiel macht und worauf seine Regeln beruhen.", "Who makes the game and what its rules are based on."), func(): ueber.emit(), true, "ABOUT")])
	luecke(4)
	gruppe(t.call("Kampf", "Combat"))
	var blut := ["Aus", "Dezent", "Deutlich"] if de else ["Off", "Subtle", "Strong"]
	var tempo := ["Ruhig", "Normal", "Schnell", "Sehr schnell"] if de else ["Calm", "Normal", "Fast", "Very fast"]   # 1020.2 C: das vierte nur im Testmodus
	zeichenreihe([z_.call(t.call("Blut", "Blood"), blut[Bedienung.blut], t.call("Wie viel Blut Treffer zeigen. Antippen wechselt: Aus, Dezent, Deutlich.",
			"How much blood hits show. Tap to change: off, subtle, strong."), spar.call(func(): Bedienung.blut = (Bedienung.blut + 1) % 3), Bedienung.blut > 0, "BLOOD"),
		z_.call(t.call("Tempo", "Pace"), tempo[Bedienung.tempo], t.call("Wie schnell Züge und Zeilen im Kampf ablaufen. Antippen wechselt: Ruhig, Normal, Schnell.",
			"How fast turns and text play out in battle. Tap to change: calm, normal, fast."), spar.call(func(): Bedienung.tempo = (Bedienung.tempo + 1) % 3), true, "TEMPO"),
		# 527 (Abgleich 512): „Kampftext“ (Antippen oder von selbst) wirkte alt nur im klassischen Kampf; im MARS laufen die Zeilen
		# immer von selbst. Ausgeblendet, bis der Kampf auf ein Antippen warten kann; die Einstellung bleibt gespeichert
		z_.call(t.call("Rückfragen", "Confirmations"), an.call(Bedienung.rueckfragen), Sprache.u("confirmHint"), spar.call(func(): Bedienung.rueckfragen = not Bedienung.rueckfragen),
			Bedienung.rueckfragen, "", "?")])
	luecke(4)
	gruppe(t.call("Bedienung", "Input"))   # Homer [326.abschnitt.bedienung]: so steht „Steuerung“ nicht zweimal
	# 663 (Chef 08.11., 15:24): nur Touch, die Wahl „Steuerung“ (Wischen/Klassisch) ist weg; 86.4, 131: Joystick und Renntaste
	var r1 := []
	var gefuehl := ["Fein", "Normal", "Ruhig"] if de else ["Fine", "Normal", "Calm"]
	r1.append(z_.call("Joystick", gefuehl[Bedienung.ring], t.call("Im Kreis geht man, über den Ring hinaus rennt man. Fein: kleiner Ring. Ruhig: großer Ring.",
		"Inside the ring you walk; beyond it you run. Fine: small ring. Calm: large ring."), spar.call(func(): Bedienung.ring = (Bedienung.ring + 1) % 3), true, "STICK"))
	r1.append(z_.call(t.call("Rennen", "Run"), t.call("Taste", "Button") if Bedienung.lauf_taste else "Ring", t.call("Wie du rennst. Ring: über den Ring des Joysticks hinausziehen. Taste: dazu ein eigener Knopf zum Rennen.",
		"How you run. Ring: push past the joystick's ring. Button: adds a separate run button."), spar.call(func(): Bedienung.lauf_taste = not Bedienung.lauf_taste), true, "RUN"))
	r1.append(z_.call(t.call("Aktion", "Action"), t.call("Links", "Left") if Bedienung.links else t.call("Rechts", "Right"), t.call("Auf welcher Seite der Aktionsknopf steht: rechts, oder links für Linkshänder.",
		"Which side the action button sits on: right, or left for left-handed players."), spar.call(func(): Bedienung.links = not Bedienung.links), true, "HAND"))
	zeichenreihe(r1)
	var r2 := [z_.call(t.call("Karte", "Map"), t.call("Näher", "Close") if Bedienung.karte_nah else "Normal", t.call("Wie nah die Karte ist. Näher zeigt weniger Umgebung, dafür größer.",
			"Map zoom. Close shows less of your surroundings, but larger."), spar.call(func(): Bedienung.karte_nah = not Bedienung.karte_nah), true, "MAP"),
		z_.call(t.call("Rütteln", "Haptics"), an.call(Bedienung.ruetteln), t.call("Das Handy zittert kurz, wenn vor dir etwas zu tun ist oder ein Weg nicht geht.",
			"The phone buzzes briefly when there is something to do ahead of you or a path is blocked."), spar.call(func(): Bedienung.ruetteln = not Bedienung.ruetteln), Bedienung.ruetteln, "BUZZ")]
	var k := get_node_or_null("/root/Klang")   # ueber den Knoten wie spiel.gd klang(): mit -s gibt es den Autoload nicht
	if k:   # Schritte an oder aus wie alt (vm.toggleSteps); gespeichert mit den Reglern
		r2.append(z_.call(t.call("Schritte", "Steps"), an.call(k.schritte_an), t.call("Die Schritte deines Helden hörbar oder still; alle anderen Geräusche bleiben.",
			"Your hero's footsteps audible or silent; all other sounds stay."), func(): k.schritte_an = not k.schritte_an; k.stelle("all", int(k.lautstaerke["all"])), k.schritte_an, "STEPS"))
	zeichenreihe(r2)
	luecke(14)
	# 399.3.1 Lautstaerke wie alt (SoundSettings.kt SoundAndLight, 40): Gesamt, Musik, Effekte und Ortsklang, in Schritten zu 5 (Mix.STEP);
	# Loslassen bei Gesamt und Effekten klickt einmal, so hoert man, wie laut es nun ist (40a)
	if k:
		zeile(t.call("Lautstärke", "Volume").to_upper(), 14, Stil.GOLD).add_theme_font_override("font", Stil.variante(3.0))   # 584: Kopf wie alt (SoundSettings.kt 43, MenuHead)
		for r in [["all", t.call("Gesamt", "Overall"), true], ["music", t.call("Musik", "Music"), false], ["fx", t.call("Effekte und Ortsklang", "Effects and ambience"), true]]:
			var an_: bool = k.musik_an if r[0] == "music" else (k.effekte_an if r[0] == "fx" else true)
			inhalt.add_child(Regler.new(String(r[1]), int(k.lautstaerke[r[0]]) if an_ else 0, t.call("Aus", "Off"),
				func(v: int): k.stelle(r[0], v), (func(): k.effekt("click", 0.35)) if r[2] else Callable()))
		luecke(4)
	# Helligkeit wie alt (SoundAndLight, 13e.6): „Dunkle Töne“ hebt das Schwarz, das Probezeichen liegt mit unter der Hebung
	zeile(t.call("Helligkeit", "Brightness").to_upper(), 14, Stil.GOLD).add_theme_font_override("font", Stil.variante(3.0))   # 584: SoundSettings.kt 48 (MenuHead)
	inhalt.add_child(Regler.new(t.call("Dunkle Töne", "Shadows"), Helligkeit.lade(), t.call("Aus", "Off"), func(v: int): Helligkeit.setze(v), Callable()))
	inhalt.add_child(Probezeichen.new())
	zeile(t.call("So einstellen, dass das Zeichen gerade noch zu sehen ist. Die Höhle bleibt dunkel.", "Adjust until the sign is barely visible. The cave stays dark."), 13, Stil.DIM)
	luecke(16)
	zeile(t.call("Schritte: %d · Siege: %d", "Steps: %d · Victories: %d") % [z.schritte, z.siege], 13, Stil.DIM)
	# 388 (DeviceBox, Chef 27.10., 21:58): Geraeteangaben zum Kopieren, damit Tester sie schicken koennen, wenn das Spiel ruckelt
	luecke(10)
	geraet_box()

# ein Zeichen getippt: tun, dann neu aufbauen, wenn das Menue noch steht (Hauptmenü und Über laden die Szene neu)
func _tue(tut: Callable) -> void:
	tut.call()
	if is_inside_tree() and not is_queued_for_deletion(): baue()

# MenuHead: Ueberschrift einer Gruppe, gesperrte Goldversalien wie der Titel des Hauptmenues, kleiner
func gruppe(w: String) -> void:
	zeile(w.to_upper(), 14, Stil.GOLD).add_theme_font_override("font", Stil.variante(3.0))
	luecke(10)

# SignRow: die Zeichen gleichmaessig ueber die Breite verteilt (Arrangement.SpaceEvenly), oben buendig
# 1027 (Chef 12.11., 11:42, Build 279: Reiter „Test“ breiter als der Schirm): eine Reihe, die breiter wird als der Schirm innerhalb des
# Rands (fünf Zeichen à 80 dp), zog den ganzen Reiter mit (die Rolle waechst mit ihrem Inhalt); sie bricht jetzt in weitere Reihen um
func zeichenreihe(zeichen: Array) -> void:
	var r := _zeichen_hbox(zeichen)
	inhalt.add_child(r)   # erst im Baum kennen die Zeichen ihre Breite (Zeichenknopf._ready)
	var frei := innen_breite()
	if r.get_combined_minimum_size().x > frei and zeichen.size() > 1:
		inhalt.remove_child(r)
		for zk in zeichen: r.remove_child(zk)
		r.free()
		var reihe: Array = []
		var breit := 0.0
		for zk in zeichen:
			var w: float = (zk as Control).get_combined_minimum_size().x
			if not reihe.is_empty() and breit + w > frei:
				inhalt.add_child(_zeichen_hbox(reihe)); luecke(10)
				reihe = []; breit = 0.0
			reihe.append(zk); breit += w
		inhalt.add_child(_zeichen_hbox(reihe))
	luecke(10)

## Breite innerhalb des Seitenrands (24 dp je Seite, wie in _ready)
func innen_breite() -> float:
	return get_viewport_rect().size.x - 48 * DP

func _zeichen_hbox(zeichen: Array) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", 0)
	r.alignment = BoxContainer.ALIGNMENT_CENTER
	for zk in zeichen:
		var l := Control.new(); l.size_flags_horizontal = Control.SIZE_EXPAND_FILL; l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		r.add_child(l)
		(zk as Control).size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		r.add_child(zk)
	var l2 := Control.new(); l2.size_flags_horizontal = Control.SIZE_EXPAND_FILL; l2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.add_child(l2)
	return r

# MenuExplainWindow: das Fenster des Gedrueckthaltens liegt ueber dem unteren Teil des Menues, ueber „Schließen“; darunter bewegt sich
# nichts. Oben ein Schatten, dann schwarz, darin erhaben mit Goldrand: Name als Ueberschrift, der Satz; Antippen schliesst es.
var erklaer_fenster: Control

func erklaere_zeichen(name_: String, satz: String) -> void:
	schliesse_erklaerung()
	Zeichenknopf.offen = name_
	_zeichen_neu()
	var f := erklaer_kasten(name_, satz, schliesse_erklaerung)
	add_child(f)
	erklaer_fenster = f
	Zurueck.melde(f, schliesse_erklaerung)   # alt back: erst das Fenster, dann das Menue

# 954: dasselbe Fenster auch in der Erschaffung (ErschaffungBrs.erklaere); [zu] schliesst es beim Antippen
static func erklaer_kasten(name_: String, satz: String, zu: Callable) -> Control:
	var f := VBoxContainer.new()
	f.add_theme_constant_override("separation", 0)
	f.anchor_left = 0; f.anchor_right = 1; f.anchor_top = 1; f.anchor_bottom = 1
	f.offset_left = 10 * DP; f.offset_right = -10 * DP; f.offset_bottom = -72 * DP
	f.grow_vertical = Control.GROW_DIRECTION_BEGIN
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var schatten := TextureRect.new()
	var gt := GradientTexture2D.new()
	var gr := Gradient.new()
	gr.set_offset(0, 0.0); gr.set_color(0, Color(0, 0, 0, 0))
	gr.set_offset(1, 0.6); gr.set_color(1, Color.BLACK)
	gr.add_point(1.0, Color.BLACK)
	gt.gradient = gr
	gt.fill_from = Vector2(0, 0); gt.fill_to = Vector2(0, 1)
	gt.width = 4; gt.height = 64
	schatten.texture = gt
	schatten.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	schatten.stretch_mode = TextureRect.STRETCH_SCALE
	schatten.custom_minimum_size = Vector2(0, 28 * DP)
	schatten.mouse_filter = Control.MOUSE_FILTER_IGNORE
	f.add_child(schatten)
	var aussen := PanelContainer.new()
	var sa := StyleBoxFlat.new()
	sa.bg_color = Color.BLACK
	sa.content_margin_left = 6 * DP; sa.content_margin_right = 6 * DP; sa.content_margin_bottom = 6 * DP
	aussen.add_theme_stylebox_override("panel", sa)
	aussen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	f.add_child(aussen)
	var innen := PanelContainer.new()
	var si := Stil.kasten(Stil.RAISED, Stil.GOLD, 1.0)
	si.content_margin_left = 12 * DP; si.content_margin_right = 12 * DP; si.content_margin_top = 9 * DP; si.content_margin_bottom = 9 * DP
	innen.add_theme_stylebox_override("panel", si)
	innen.mouse_filter = Control.MOUSE_FILTER_STOP
	innen.gui_input.connect(func(e: InputEvent):
		if Spielstaende.tipp(e) and not e.pressed: zu.call())   # 605: nur die Maus, sonst zweimal
	aussen.add_child(innen)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(4 * DP))
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	innen.add_child(v)
	var kopf_ := Stil.zeile(name_.to_upper(), 14, Stil.GOLD, 3.0)
	kopf_.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(kopf_)
	if satz != "":
		var s := Stil.zeile(satz, 14, Stil.TEXT)
		s.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		s.add_theme_constant_override("line_spacing", int(round(2 * Stil.SP)))   # lineHeight 19 sp
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(s)
	return f

func schliesse_erklaerung() -> void:
	if is_instance_valid(erklaer_fenster): erklaer_fenster.queue_free()
	erklaer_fenster = null
	if Zeichenknopf.offen != "":
		Zeichenknopf.offen = ""
		_zeichen_neu()

func _zeichen_neu() -> void:
	for c in inhalt.find_children("*", "Zeichenknopf", true, false): (c as Zeichenknopf).neu_zeichnen()

func _exit_tree() -> void:
	Zeichenknopf.offen = ""   # DisposableEffect: MenuExplain.shown = null

# DeviceBox: „Gerät zeigen …“ klappt die Geraeteangaben mit den Messwerten auf, „Kopieren“ legt sie in die Ablage
func geraet_box() -> void:
	var de := Sprache.aktiv() == "de"
	var reihe_ := HBoxContainer.new()
	reihe_.add_theme_constant_override("separation", int(6 * DP))
	reihe_.add_child(Stil.knopf(("Gerät schließen" if de else "Hide device info") if geraet_auf else ("Gerät zeigen …" if de else "Show device…"), func(): geraet_auf = not geraet_auf; baue()))
	if geraet_auf:
		var b := Stil.knopf("Kopieren" if de else "Copy", func(): DisplayServer.clipboard_set(geraeteangaben()); meldung("Geräteangaben kopiert." if de else "Device details copied."))
		b.size_flags_stretch_ratio = 0.5
		reihe_.add_child(b)
	inhalt.add_child(reihe_)
	if geraet_auf: zeile(geraeteangaben(), 14, Stil.TEXT)   # 624: lesbar (vorher 11 sp)

var geraet_auf := false


# 352 GuideScreen wie alt: schwarz, ein Kasten, oben der Titel, je Absatz die fette Eroeffnung als Ueberschrift in Gold (16 sp),
# der Rest 15 sp, fette Woerter (Knoepfe) halbfett in Gold; nur die Faehigkeiten der eigenen Klasse; unten „Zurück“
static func anleitung_teile(klasse: String) -> Array:
	var r := []
	for p in Sprache.texte.get("anleitung", {}).get("teile", []):
		if not p.has("nur") or String(p["nur"]) == klasse: r.append(Sprache.t(p))
	return r

# (Text, fett) der Reihe nach, wie Guide.pieces
static func stuecke(t: String) -> Array:
	var r := []
	var s := t.split("**")
	for i in s.size():
		if s[i] != "": r.append([s[i], i % 2 == 1])
	return r

func anleitung() -> void:
	# 630 (549a „Schirm“): ohne Kasten, Titel 22 sp mit Zierlinie, unten „‹ ZURÜCK“ (Spielstaende.schirm)
	var d := Spielstaende.schirm(self, Sprache.t(Sprache.texte.get("anleitung", {}).get("titel", "")), func(): pass)
	var v: VBoxContainer = d["inhalt"]
	var halbfett := Stil.variante(0.2, false, true)   # 584: der echte halbfette Schnitt wie alt (GuideScreen.kt 57, SemiBold) statt kuenstlich verdickt
	var gerade := Stil.variante(0.2)
	for t in anleitung_teile(""):   # 870.4: ohne Klasse nur die allgemeinen Teile; Handbuch nach BRS mit 870.9 (Homer 870.15)
		var st := stuecke(t)
		var absatz := VBoxContainer.new()
		absatz.add_theme_constant_override("separation", 0)
		if not st.is_empty() and st[0][1]:
			var h := Stil.zeile(String(st[0][0]).strip_edges(), 16, Stil.GOLD)
			h.add_theme_font_override("font", halbfett)
			absatz.add_child(h)
			st = st.slice(1)
		var rt := RichTextLabel.new()
		rt.bbcode_enabled = true
		rt.fit_content = true
		rt.scroll_active = false
		rt.mouse_filter = Control.MOUSE_FILTER_IGNORE   # 399.1 (Test 139: „Anleitung. Kann man nicht scrollen“): sonst schluckt der Text das Wischen
		rt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rt.add_theme_font_override("normal_font", gerade)
		rt.add_theme_font_override("bold_font", halbfett)
		rt.add_theme_font_size_override("normal_font_size", int(round(15 * 0.95 * Stil.SP)))
		rt.add_theme_font_size_override("bold_font_size", int(round(15 * 0.95 * Stil.SP)))
		rt.add_theme_constant_override("line_separation", int(round(15 * 0.35 * Stil.SP)))
		rt.add_theme_color_override("default_color", Stil.TEXT)
		var b := ""
		for i in st.size():
			var s := String(st[i][0])
			if i == 0: s = s.lstrip(" ")
			s = s.replace("[", "[lb]")
			b += ("[b][color=#%s]%s[/color][/b]" % [Stil.GOLD.to_html(false), s]) if st[i][1] else s
		rt.text = b
		absatz.add_child(rt)
		v.add_child(absatz)

# DeviceInfo.lines: was Geraet, System und Grafik sind, dazu die Messwerte des Spiels
static func geraeteangaben() -> String:
	var gr := DisplayServer.screen_get_size()
	var z_ := [
		"Version: %s" % String(ProjectSettings.get_setting("application/config/version", "")),
		"Gerät: %s" % OS.get_model_name(),
		"System: %s %s" % [OS.get_name(), OS.get_version()],
		"Grafik: %s (%s), %s" % [RenderingServer.get_video_adapter_name(), RenderingServer.get_video_adapter_vendor(), String(ProjectSettings.get_setting("rendering/renderer/rendering_method", ""))],
		"Bildschirm: %d × %d, %d dpi" % [gr.x, gr.y, DisplayServer.screen_get_dpi()],
		"Speicher: %d MB" % int(OS.get_static_memory_usage() / 1048576),
		"Prozessorkerne: %d" % OS.get_processor_count(),
	]
	var ml := Engine.get_main_loop()
	z_.append_array(Messung.zeilen(ml.root if ml is SceneTree else null))   # 399.1 Messwerte wie alt (deviceReadings)
	return "\n".join(PackedStringArray(z_))

# BrightnessSign: ein Ring mit Flammenstrich in 10 von 255 auf reinem Schwarz, so dunkel wie der Umriss einer Hoehle
class Probezeichen extends Control:
	func _init() -> void:
		custom_minimum_size = Vector2(0, 96 * AktionsKnopf.DP)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
	func _draw() -> void:
		var dp := AktionsKnopf.DP
		draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)
		draw_rect(Rect2(Vector2.ZERO, size), Stil.RIM, false, dp)
		var c := Color(Helligkeit.ZEICHEN, Helligkeit.ZEICHEN, Helligkeit.ZEICHEN)
		var m := size / 2
		var r := 28 * dp
		draw_arc(m, r, 0, TAU, 48, c, 5 * dp, true)
		draw_line(m - Vector2(0, r * 0.6), m + Vector2(0, r * 0.6), c, 6 * dp)

# GoldSlider (SoundSettings.kt): Name und Wert darueber, eine Goldlinie darunter; Antippen oder Ziehen, in Schritten zu 5
class Regler extends VBoxContainer:
	var wert := 0
	var aus := ""
	var aendert: Callable
	var fertig: Callable
	var zahl: Label
	var linie: Control

	func _init(name_: String, w: int, aus_: String, aendert_: Callable, fertig_: Callable) -> void:
		wert = w; aus = aus_; aendert = aendert_; fertig = fertig_
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var kopf := HBoxContainer.new()
		add_child(kopf)
		var n := Stil.txt(name_, 14)
		kopf.add_child(n)
		zahl = Stil.zeile("", 14 * 0.95, Stil.BRIGHT, 0.2, false, true)   # 584: Wert halbfett wie alt (SoundSettings.kt 64)
		kopf.add_child(zahl)
		linie = Control.new()
		linie.custom_minimum_size = Vector2(0, 36 * AktionsKnopf.DP)
		linie.mouse_filter = Control.MOUSE_FILTER_STOP
		linie.draw.connect(_zeichne)
		linie.gui_input.connect(_eingabe)
		add_child(linie)
		zeige()

	func zeige() -> void:
		zahl.text = aus if wert == 0 else "%d %%" % wert
		linie.queue_redraw()

	static func stufe(p: int) -> int: return ((clampi(p, 0, 100) + 2) / 5) * 5   # Mix.clamp

	func _eingabe(e: InputEvent) -> void:
		var x := -1.0
		if e is InputEventScreenTouch or e is InputEventScreenDrag: x = e.position.x
		elif e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and e.device != InputEvent.DEVICE_ID_EMULATION: x = e.position.x
		if x < 0: return
		var neu := stufe(roundi(x / linie.size.x * 100))
		if neu != wert:
			wert = neu
			aendert.call(wert)
			zeige()
		if e is InputEventScreenTouch and not e.pressed and fertig.is_valid(): fertig.call()
		linie.accept_event()

	func _zeichne() -> void:
		var dp := AktionsKnopf.DP
		var y := linie.size.y / 2
		var knopf := 7 * dp
		var x := knopf + (linie.size.x - 2 * knopf) * wert / 100.0
		linie.draw_line(Vector2(knopf, y), Vector2(linie.size.x - knopf, y), Stil.RIM, 2 * dp)
		linie.draw_line(Vector2(knopf, y), Vector2(x, y), Stil.GOLD, 3 * dp)
		var r := Rect2(x - knopf, y - knopf * 1.6, knopf * 2, knopf * 3.2)
		linie.draw_rect(r, Color.BLACK)
		linie.draw_rect(r, Stil.BRIGHT, false, 1.5 * dp)

# ---------------------------------------------------------------- Chronik (ChronicleTab)
func kaestchen(zeilen: Array) -> void:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	for c in zeilen: v.add_child(c)
	var p := PanelContainer.new()
	var st := Stil.kasten(Color.BLACK, Stil.RIM, 1.0)
	st.content_margin_left = 12 * DP; st.content_margin_right = 12 * DP; st.content_margin_top = 8 * DP; st.content_margin_bottom = 8 * DP
	p.add_theme_stylebox_override("panel", st)
	p.add_child(v)
	inhalt.add_child(p)

# 528 (ChronicleTab.kt 100): „Auf der Karte“, nur wo die Karte ein Zeichen des Auftraggebers hat; oeffnet die Karte auf ihm
func auf_der_karte(wer: String) -> Array:
	if not Kartenreiter.hat_geber(z, wer): return []
	var b := Stil.knopf("Auf der Karte" if de_() else "On the map", func():
		Kartenreiter.fokus_wer = wer
		karte_direkt = false
		reiter = "karte"; baue())
	b.name = "AufDerKarte"
	b.custom_minimum_size = Vector2(0, 32 * DP)
	b.add_theme_font_size_override("font_size", int(round(13 * Stil.SP)))
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	b.clip_text = false   # 503: mit clip_text und SHRINK 0 breit
	return [b]

func chronik() -> void:
	var de := Sprache.aktiv() == "de"
	Chronik.gelesen(z)
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(6 * DP))
	r.add_child(Stil.knopf("Aufträge" if de else "Quests", func(): bisher = false; baue(), not bisher))
	r.add_child(Stil.knopf("Bisher geschehen" if de else "Story so far", func(): bisher = true; baue(), bisher))
	inhalt.add_child(r)
	luecke(10)
	if bisher:
		var l := Chronik.bisher(z)
		for i in l.size():
			if i > 0: luecke(12)
			zeile(Sprache.t(l[i]["titel"]), 17, Stil.BRIGHT if i == 0 else Stil.GOLD, true)   # 584: ChronicleTab.kt 54 halbfett
			zeile(Sprache.t(l[i]["text"]).replace("{name}", hw.name), 15, Stil.TEXT if i == 0 else Stil.DIM)
		# 68: die Morgenandacht am Ende von Kapitel 1 kann man wieder ansehen, sobald das Kapitel vorbei ist (ChronicleTab onTemple)
		if Zwischenbild.da() and z.has(Geschichte.CHAPTER1_DONE):
			luecke(12)
			var t := Stil.knopf("Die Morgenandacht ansehen" if de else "Watch the dawn service", func(): andacht.emit())
			t.custom_minimum_size.y = 36 * DP
			t.add_theme_font_size_override("font_size", int(round(14 * Stil.SP)))
			inhalt.add_child(t)
		# 69d: die Ankunft bei Nacht gehoert vor den ersten Eintrag; man kann sie wieder ansehen (ChronicleTab onIntro)
		if Zwischenbild.da():
			luecke(12)
			var b := Stil.knopf("Die Ankunft ansehen" if de else "Watch the arrival", func(): ankunft.emit())
			b.custom_minimum_size.y = 36 * DP
			b.add_theme_font_size_override("font_size", int(round(14 * Stil.SP)))
			inhalt.add_child(b)
		return
	kaestchen([Stil.txt("Hauptauftrag" if de else "Main quest", 13, Stil.GOLD), Stil.txt(Sprache.t(Geschichte.ziel(z)), 16, Stil.BRIGHT, true)])   # 584: ChronicleTab.kt 72, 78, 92 halbfett
	for t in Chronik.offen(z):
		luecke(8)
		kaestchen([Stil.txt(Sprache.t(t["titel"]), 16, Stil.TEXT, true), Stil.txt(Sprache.t(t["text"]).replace("{name}", hw.name), 14)])
	# 399.1 Nebenauftraege vom Anschlagbrett (ChronicleTab): Titel, von wem, Aushang, Stand oder „Bereit zur Abgabe“, Lohn
	var getragen := Auftraege.getragen(z)
	if not getragen.is_empty():
		luecke(12)
		zeile("Nebenaufträge" if de else "Side quests", 15, Stil.GOLD)
	for j in getragen:
		luecke(8)
		var hat := Auftraege.stand(z, j)
		var bereit := hat >= int(j["anzahl"])
		var wer := Sprache.t(j["geber_name"])
		kaestchen([Stil.txt(Sprache.t(j["titel"]), 16, Stil.TEXT, true), Stil.txt(("von " if de else "from ") + wer, 13, Stil.DIM),
			Stil.txt(Sprache.t(j["aushang"]), 14),
			Stil.txt((("Bereit zur Abgabe – bei %s" if de else "Ready to turn in to %s") % wer) if bereit
				else "%d %s %d · %s" % [hat, "von" if de else "of", int(j["anzahl"]), Laden.name(String(j["ding"]))], 14, GRUEN if bereit else Stil.GOLD),
			Stil.txt(("Lohn: " if de else "Reward: ") + Sprache.t(j["lohn"]), 13, Stil.DIM)] + auf_der_karte(String(j["geber"])))
	var fertig := Chronik.fertig(z)
	var fertig_j := Auftraege.alle().filter(func(j): return Auftraege.erledigt(z, j))
	if not fertig.is_empty() or not fertig_j.is_empty():
		luecke(12)
		inhalt.add_child(Stil.knopf(("Erledigt (%d)" if de else "Done (%d)") % (fertig.size() + fertig_j.size()) + (" ▴" if erledigt_auf else " ▾"), func(): erledigt_auf = not erledigt_auf; baue()))
		if erledigt_auf:
			for t in fertig: zeile("✓ " + Sprache.t(t["titel"]), 14, Stil.DIM)
			for j in fertig_j: zeile("✓ " + Sprache.t(j["titel"]) + " · " + Sprache.t(j["geber_name"]), 14, Stil.DIM)


## 944 (Chef 11.11., 13:22, t276.5): [870.14.ding.schaden] „Schaden %d · %s“, Grundschaden der Waffengruppe (werte.json „waffen“,
## wie BrsHeld.schaden und mars.gd _brs_waffe), Schadensart wie bisher; nie ein Würfel
# 870.7 ([870.14.ding.schaden]): Schaden der Waffe mit ihrer Guete und der Schadensart aus den Regelwerten (Beute.schaden,
# Beute.schadensart); ohne Schadensart nur die Zahl
static func schaden_text(g: Dictionary, de: bool) -> String:
	var art: Array = Beute.SCHADENSART.get(Beute.schadensart(g), ["", ""])
	var n := Beute.schaden(g)
	if String(art[0]) == "": return ("Schaden %d" if de else "Damage %d") % n
	return ("Schaden %d · %s" if de else "Damage %d · %s") % [n, art[0 if de else 1]]

# 870.7 ([870.14.ding.guete], statt „Angriff +%d“): Guete jedes Stuecks, dessen Zahl sie aendert (Waffe, Brustruestung, Schild)
static func guete_text(g: Dictionary, de: bool) -> String:
	return ("Güte: %s" if de else "Quality: %s") % Beute.guete_name(Beute.guete_von(g), "de" if de else "en")

# 870.7 ([870.14.ding.fertigkeit]): die Fertigkeit, die das Stueck braucht (Waffe, Ruestung, Schild), "" sonst
static func fertigkeit_text(g: Dictionary, de: bool) -> String:
	var f := BrsHeld.fertigkeit_von(String(g["base"]))
	if f == "": return ""
	return ("Fertigkeit: %s" if de else "Skill: %s") % (f if de else String(ErschaffungBrs.FERT.get(f, f)))

# 870.4 ([870.14.ding.grundwert], [870.14.ding.armbrust]): der Grundwert im Schaden nach werte.json „waffen“
static func grundwert_text(g: Dictionary, de: bool) -> String:
	var gw = BrsHeld.lade()["waffen"].get(BrsHeld.fertigkeit_von(String(g["base"])), {}).get("grundwert")
	if gw == null: return "Schaden ohne Grundwert." if de else "Damage without an attribute."
	return ("Schaden mit %s" if de else "Damage with %s") % ErschaffungBrs.tx(ErschaffungBrs.GRUNDWERT.get(String(gw), {"de": gw, "en": gw}))

# 870.7: Stueck mit einer Zahl, die die Guete aendert (Beute.kennwert)
static func hat_kennwert(g: Dictionary) -> bool:
	var b := Beute.grundform(String(g["base"]))
	return Beute.ist_waffe(b) or (String(b["slot"]) == "CHEST" and int(b.get("ruestung", 0)) > 0) or String(b["art"]) == "SHIELD"
