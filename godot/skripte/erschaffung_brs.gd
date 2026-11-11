class_name ErschaffungBrs
extends Control
# 399.1 Erschaffung wie im alten Spiel (Chef 28.10., 14:38: „Einfach mal das alte Spiel nehmen … so soll es im neuen halt auch schon“;
# 14:39 „an die Designvorgaben halten“): eine Seite wie CreateScreen.kt im schwarzen Look (LocalVeil): oben fest der Held, der sich
# dreht, daneben Name, Volk, Herkunft, Leben, Mana und die sechs Grundwerte; darunter rollend Name, Volk, Aussehen, Herkunft,
# Grundwerte, Startfertigkeiten; unten fest Zurueck und Abenteuer beginnen. Masse in dp/sp wie alt (Theme.kt Txt, VeilHead, Panel).
# 470 (Abnahme 1.1, BRS): ohne Klasse; sechs Grundwerte ab 3 mit 9 Punkten (bis 8), Volk mit Plus, Minus (bis 2, 933) und Merkmal, Herkunft
# freiwillig (verteilt vor, aenderbar) oder Wanderer, Startfertigkeiten; Regeln und Zahlen in regeln/brs_held.gd aus daten/werte.json.
# Texte wortgetreu aus dem Handbuch (STORY-HANDBUCH-1.md, Marken [423.…]). 870.4: ohne Bruecke zum SRD; Tracht, Beispielkopf und
# Grundausruestung im Drehteller nach der Herkunft (HeldFigur, werte.json „welt“ „start“).
# 376.1 Aussehen wie alt nach dem Volk: Haut und Haar als Farbtoene des Volks (Appearance.kt), dazu Gesicht, Frisur, Bart des
# Kaufkopfs (HeldFigur), Geschlecht und Statur wie die alte Seite.
# Ende: Signal fertig({"name", "brs", "aussehen", "platz"}) oder zurueck.
# 470 (Chef 10.11., 12:58 „470 jetzt“; Archiv: „Neues Spiel“ erst nach bestandenem t274.18): „Neues Spiel“ im Hauptmenue und in den
# Spielstaenden fuehrt hierher, die alte Klassenwahl (SRD) ist weg; im Testmenue bleibt „Erschaffung BRS“ (834).
# 470 (549a, wie 630 an der alten Seite): Schirm ohne Kasten, Seitenrand 24 dp, eine Zierlinie unter dem Kopf, Abschnitte durch
# schlichte Linien, Wahlfelder ohne Rahmen (gewaehlt BRIGHT auf RAISED, nicht waehlbar gedaempft), − und + ohne Rahmen, unten
# „‹ ZURÜCK“ links und „ABENTEUER BEGINNEN ›“ rechts, gesperrt gedaempft, solange etwas fehlt. Bausteine aus erschaffung.gd.

signal fertig(wahl: Dictionary)
signal zurueck

const DP := AktionsKnopf.DP

# Handbuch (Homer, 423): Namen und Saetze in beiden Sprachen, wortgetreu
const T := {
	"werte": {"de": "Die sechs Grundwerte", "en": "The six attributes"},                                     # [423.werte]
	"schaffen": {"de": "Jeder Grundwert beginnt bei 3. Du verteilst 9 Punkte, kein Wert steigt dabei über 8: du kannst einen Wert stark machen oder mehrere ein wenig.",
		"en": "Every attribute starts at 3. You spend 9 points, and none may go above 8 this way: make one value strong, or raise several a little."},   # [423.schaffen] (933.1)
	"volk": {"de": "Dein Volk", "en": "Your people"},                                                        # [423.volk]
	"volk_text": {"de": "Dein Volk gibt einen kleinen Vorteil, meist auch einen kleinen Nachteil, und ein Merkmal, das man merkt. Es kann Werte auf 9 heben oder auf 2 senken.",
		"en": "Your people grant a small boon, usually a small flaw, and a trait you will notice. They may lift values to 9 or lower them to 2."},   # [423.volk] (933.1)
	"herkunft": {"de": "Herkunft, wenn du willst", "en": "Origin, if you wish"},                              # [423.herkunft]
	"herkunft_text": {"de": "Eine Herkunft verteilt die Punkte für dich vor, gibt dir zwei oder drei Fertigkeiten mit dem Wert {held.startfertigkeit} und die Ausrüstung dazu. Ein Satz sagt dir, wohin sie meist führt. Die Punkte darfst du danach noch ändern.",
		"en": "An origin spends the points for you, gives you two or three skills at {held.startfertigkeit} and the gear to match. One line tells you where it usually leads. You may still move the points afterwards."},
	"fert": {"de": "Was du kannst", "en": "What you can do"},                                                # [423.fert]
	"leben": {"de": "Leben", "en": "Life"}, "mana": {"de": "Mana", "en": "Mana"},                            # [423.werte.ab]
}
const GRUNDWERT := {"kraft": {"de": "Kraft", "en": "Strength"}, "gewandtheit": {"de": "Gewandtheit", "en": "Agility"},
	"zaehigkeit": {"de": "Zähigkeit", "en": "Toughness"}, "verstand": {"de": "Verstand", "en": "Wits"}, "wille": {"de": "Wille", "en": "Will"},
	"wahrnehmung": {"de": "Wahrnehmung", "en": "Perception"}}                                                 # [423.werte]
const VOLK := {
	"Mensch": {"de": "Mensch", "en": "Human", "satz": {"de": "Einen Punkt, wohin du willst; Wandelbar, eine Fertigkeit mehr zum Start.", "en": "One point wherever you like; Adaptable, one extra skill at the start."}},
	"Elf": {"de": "Elf", "en": "Elf", "satz": {"de": "Gewandtheit und Wahrnehmung höher, Zähigkeit niedriger; Wachsame Sinne.", "en": "Agility and Perception higher, Toughness lower; Watchful Senses."}},
	"Zwerg": {"de": "Zwerg", "en": "Dwarf", "satz": {"de": "Zähigkeit und Verstand höher, Gewandtheit niedriger; Steinblut.", "en": "Toughness and Wits higher, Agility lower; Stoneblood."}},
	"Hügelvolk": {"de": "Hügelvolk", "en": "Hill Folk", "satz": {"de": "Gewandtheit und Wille höher, Kraft niedriger; Glückskind.", "en": "Agility and Will higher, Strength lower; Child of Fortune."}},
	"Orkblütiger": {"de": "Orkblütiger", "en": "Orc-blooded", "satz": {"de": "Kraft und Zähigkeit höher, Wille niedriger; Letzter Atemzug.", "en": "Strength and Toughness higher, Will lower; Last Breath."}},
}                                                                                                           # [423.volk.liste]
const HERKUNFT := {
	"Wachsoldat": {"de": "Wachsoldat", "en": "Watch Soldier", "satz": {"de": "Führt zu Wächter oder Paladin.", "en": "Leads to Warden or Paladin."}},
	"Jägerkind": {"de": "Jägerkind", "en": "Hunter's Child", "satz": {"de": "Zu Waldläufer oder Scharfschütze.", "en": "To Ranger or Marksman."}},
	"Zauberlehrling": {"de": "Zauberlehrling", "en": "Apprentice Mage", "satz": {"de": "Zu Magier oder Kriegsmagier.", "en": "To Mage or Battlemage."}},
	"Klosterschüler": {"de": "Klosterschüler", "en": "Cloister Pupil", "satz": {"de": "Zu Heiler oder Paladin.", "en": "To Healer or Paladin."}},
	"Kräutersammler": {"de": "Kräutersammler", "en": "Herb Gatherer", "satz": {"de": "Zum Alchemisten.", "en": "To Alchemist."}},
	"Schmiedelehrling": {"de": "Schmiedelehrling", "en": "Smith's Apprentice", "satz": {"de": "Zum Schmied.", "en": "To Smith."}},
	"Herumtreiber": {"de": "Herumtreiber", "en": "Drifter", "satz": {"de": "Zu Assassine oder Schatzjäger.", "en": "To Assassin or Treasure Hunter."}},
	"Wanderer": {"de": "Wanderer", "en": "Wanderer", "satz": {"de": "Wer keine Herkunft will, ist Wanderer: er verteilt selbst und wählt zwei Fertigkeiten, ebenfalls mit dem Wert {held.startfertigkeit}.",
		"en": "Whoever wants no origin is a Wanderer: he spends his own points and picks two skills, likewise at {held.startfertigkeit}."}},
}                                                                                                           # [423.herkunft.liste], [423.herkunft]
const GRUPPE := {"Waffen": {"de": "Waffen", "en": "Weapons"}, "Rüstung": {"de": "Rüstung", "en": "Armor"}, "Schatten": {"de": "Schatten", "en": "Shadow"},
	"Magie": {"de": "Magie", "en": "Magic"}, "Wildnis": {"de": "Wildnis", "en": "Wilds"}, "Gesellschaft": {"de": "Gesellschaft", "en": "Society"},
	"Sammeln": {"de": "Sammeln", "en": "Gathering"}, "Meisterschaften": {"de": "Handwerk", "en": "Craft"}}  # [423.fert.liste]
const FERT := {"Einhänder": "One-handed", "Zweihänder": "Two-handed", "Stangenwaffen": "Polearms", "Stumpfe Waffen": "Blunt Weapons",
	"Dolche": "Daggers", "Faustkampf": "Brawling", "Schild": "Shield", "Bogen": "Bow", "Armbrust": "Crossbow", "Wurfwaffen": "Throwing",
	"Leichte Rüstung": "Light Armor", "Mittlere Rüstung": "Medium Armor", "Schwere Rüstung": "Heavy Armor", "Ausweichen": "Dodge",
	"Schleichen": "Stealth", "Spähen": "Scouting", "Schlösser knacken": "Lockpicking", "Fallen entschärfen": "Disarming Traps",
	"Evokation": "Evocation", "Schutzmagie": "Warding", "Heilmagie": "Healing Magic", "Illusion": "Illusion", "Beschwörung": "Summoning",
	"Tiere beruhigen": "Calming Beasts", "Überreden": "Persuasion", "Einschüchtern": "Intimidation", "Handeln": "Haggling",
	"Kräuterkunde": "Herbalism", "Bergbau": "Mining", "Angeln": "Fishing", "Jagd": "Hunting", "Schmieden": "Smithing",
	"Lederarbeit": "Leatherwork", "Alchemie": "Alchemy", "Kochen": "Cooking", "Runenkunde": "Runecraft", "Heilkunde": "Medicine"}

var name_ := ""
var b := BrsHeld.neu("Mensch", "Wachsoldat")   # 470: der Held nach BRS; Vorgabe die erste Herkunft der Liste
var ziel := 0                         # Platz aus den Spielstaenden („Neues Spiel“ bei einem leeren), sonst der erste freie
var rolle: ScrollContainer
var inhalt: VBoxContainer
var kopf: VBoxContainer               # Zusammenfassung neben dem Helden
var unten: Control                    # Platz der Knopfzeile unten (gesperrt, solange etwas fehlt)
var aussehen := HeldFigur.vorgabe("Wachsoldat")   # 376.1; Beispielkopf der Herkunft (Chef 28.10., 23:0x), bis der Spieler selbst waehlt
var aussehen_eigen := false
var teller: Drehteller
var teller_wahl := ""                 # zuletzt gezeigte Wahl (Punkte bauen die Seite neu, den Helden nicht)

func _init() -> void:
	name = "Erschaffung"
	b = BrsHeld.neu("Mensch", BrsHeld.herkuenfte()[0] if not BrsHeld.herkuenfte().is_empty() else BrsHeld.WANDERER)
	aussehen = HeldFigur.vorgabe(b.herkunft)

func _process(dt: float) -> void: Messung.bild(dt, "Erschaffung")   # 416.1: laengste Bildpause auch hier

static func tx(d) -> String: return Sprache.t(d)
## 870.4 ([870.14.wanderer.kapitel]): „Volk · Herkunft · Heldenstufe n“ (Kapitelschirm, Spielstaende), mit [name_] vorn
static func volk_name(v: String) -> String: return tx(VOLK.get(v, {"de": v, "en": v}))
static func herkunft_name(h: String) -> String: return tx(HERKUNFT.get(h, {"de": h, "en": h}))
static func heldenstufe(n: int) -> String: return ("Heldenstufe %d" if Sprache.aktiv() == "de" else "Hero Level %d") % n
static func wer(v: String, h: String, n: int, name_ := "") -> String:
	return (name_ + " · " if name_ != "" else "") + "%s · %s · %s" % [volk_name(v), herkunft_name(h), heldenstufe(n)]
static func sw(t: String) -> String: return t.replace("{held.startfertigkeit}", str(int(BrsHeld.h().get("startfertigkeit", 10))))
static func fert_name(f: String) -> String: return f if Sprache.aktiv() == "de" else String(FERT.get(f, f))

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Zurueck.melde(self, func(): zurueck.emit())   # 416.1: Android-Zurück wie „Zurück“
	name_ = Sprache.u("defaultName")
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var rand := MarginContainer.new()
	rand.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["left", "right"]: rand.add_theme_constant_override("margin_" + s, int(24 * DP))   # 549a „Schirm“: Seitenrand 24 dp
	for s in ["top", "bottom"]: rand.add_theme_constant_override("margin_" + s, int(12 * DP))
	add_child(rand)
	var spalte := VBoxContainer.new()
	spalte.add_theme_constant_override("separation", int(10 * DP))
	rand.add_child(spalte)
	# oben fest: der Held und was er ist
	var oben := HBoxContainer.new()
	oben.add_theme_constant_override("separation", int(12 * DP))
	oben.alignment = BoxContainer.ALIGNMENT_BEGIN
	spalte.add_child(oben)
	oben.add_child(vorschau())
	kopf = VBoxContainer.new()
	kopf.add_theme_constant_override("separation", 0)
	kopf.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kopf.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	oben.add_child(kopf)
	# Mitte rollt
	rolle = ScrollContainer.new()
	rolle.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolle.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER   # wie alt ohne Balken (Helfer: grauer Balken klebte am Goldrand)
	rolle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spalte.add_child(Spielstaende.zier())   # 549a: genau eine Zierlinie unter dem Kopf (Held und was er ist)
	spalte.add_child(rolle)
	inhalt = VBoxContainer.new()
	inhalt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inhalt.add_theme_constant_override("separation", int(10 * DP))
	rolle.add_child(inhalt)
	# unten fest (549a Knoepfe): „‹ ZURÜCK“ links, „ABENTEUER BEGINNEN ›“ rechts als Hauptwahl, je die halbe Breite, Linie darueber;
	# die Hauptwahl gedaempft, bis alles verteilt und gewaehlt ist (der Grund steht oben im Kopf)
	spalte.add_child(Spielstaende.linie())
	unten = VBoxContainer.new()
	unten.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spalte.add_child(unten)
	baue()

# die Hauptwahl unten („ABENTEUER BEGINNEN ›“) und ob sie frei ist (Tests)
func los() -> Control:
	var r := unten.get_child(unten.get_child_count() - 1) if unten.get_child_count() > 0 else null
	return r.get_child(1) if r != null else null
func los_an() -> bool: return los() != null and bool(los().get_meta("an", false))

func knoepfe_neu() -> void:
	for c in unten.get_children():
		unten.remove_child(c)
		c.queue_free()
	var r := Spielstaende.knopfzeile(Spielstaende.knopf("neben", Sprache.u("back"), func(): zurueck.emit(), true),
		Spielstaende.knopf("haupt", Sprache.u("start"), func(): beginne(), false, b.fertig()))
	r.name = "Unten"
	Menue.passe_knopfzeile(r, get_viewport_rect().size.x - 48 * DP)   # 630: Hauptwahl in einer Zeile, nie mitten im Wort
	unten.add_child(r)

# ---------------------------------------------------------------- Aufbau

func baue() -> void:
	var y := rolle.scroll_vertical
	var t0 := Time.get_ticks_usec()   # 416.1 (Chef: Tasten reagieren schlecht): Dauer des Neuaufbaus je Tipp, unter „Gerät“ (Ladezeit)
	for c in inhalt.get_children():
		inhalt.remove_child(c)
		c.queue_free()
	kopf_neu()
	inhalt.add_child(kopfzeile(Sprache.u("yourName")))
	inhalt.add_child(namensfeld())
	# Volk (Wort „Volk“, nie „Rasse“, E 70)
	inhalt.add_child(kopfzeile(tx(T["volk"])))
	inhalt.add_child(wahl(BrsHeld.voelker(), b.volk, func(v): return tx(VOLK.get(v, {"de": v, "en": v})), volk_waehlen))
	var vk := VBoxContainer.new()
	vk.add_theme_constant_override("separation", 0)
	vk.add_child(txt(tx(T["volk_text"]), 13.5, Spielstaende.ANGABE))   # 549a: DIM heisst gesperrt
	vk.add_child(luecke(4))
	var bon := []
	for g in BrsHeld.grundwerte():
		var p := int(BrsHeld.e()["voelker"][b.volk].get("plus", {}).get(g, 0))
		if p != 0: bon.append("%s %s" % [tx(GRUNDWERT[g]), vorzeichen(p).replace("-", "−")])
	if not bon.is_empty(): vk.add_child(txt("  ".join(PackedStringArray(bon)), 15, Stil.TEXT, true))   # 584: halbfett wie der Volksbonus alt   # Mensch: der Satz sagt „einen Punkt, wohin du willst“
	vk.add_child(txt(tx(VOLK[b.volk]["satz"]) if VOLK.has(b.volk) else b.merkmal(), 15, Stil.GOLD))
	inhalt.add_child(vk)
	inhalt.add_child(Spielstaende.linie())
	if HeldFigur.da(b.herkunft, String(aussehen.get("geschlecht", "m"))):
		aussehen_wahl()
		inhalt.add_child(Spielstaende.linie())
	# Herkunft
	inhalt.add_child(kopfzeile(tx(T["herkunft"])))
	inhalt.add_child(wahl(BrsHeld.herkuenfte(), b.herkunft, func(h): return tx(HERKUNFT.get(h, {"de": h, "en": h})), herkunft_waehlen, 2))   # zwei Spalten: „Schmiedelehrling“ ganz
	var hk := VBoxContainer.new()
	hk.add_theme_constant_override("separation", 0)
	if b.herkunft != BrsHeld.WANDERER:
		hk.add_child(txt(sw(tx(T["herkunft_text"])), 13.5, Spielstaende.ANGABE))
		hk.add_child(luecke(4))
		hk.add_child(txt(", ".join(PackedStringArray(b.herkunft_fertigkeiten().map(func(f): return fert_name(String(f))))), 15, Stil.TEXT, true))
	if HERKUNFT.has(b.herkunft): hk.add_child(txt(sw(tx(HERKUNFT[b.herkunft]["satz"])), 15, Stil.GOLD))
	inhalt.add_child(hk)
	inhalt.add_child(Spielstaende.linie())
	grundwerte()
	inhalt.add_child(Spielstaende.linie())
	fertigkeiten()
	knoepfe_neu()
	zeige_held()
	var ms := (Time.get_ticks_usec() - t0) / 1000.0
	Messung.geladen("Erschaffung Tipp", maxf(ms, float(Messung.laden.get("Erschaffung Tipp", 0.0))))
	# die Rolle bleibt, wo sie war (sonst springt sie bei jeder Wahl nach oben)
	await get_tree().process_frame
	rolle.scroll_vertical = y

func volk_waehlen(v: String) -> void:
	b.volk = v
	b.waehle_herkunft(b.herkunft)   # Wahl der Fertigkeiten an die Zahl des Volks anpassen (Mensch eine mehr); Punkte bleiben
	var vg := HeldFigur.vorgabe(b.herkunft, String(aussehen.get("geschlecht", "m")))
	aussehen["haut"] = int(vg["haut"])
	aussehen["haarfarbe"] = int(vg["haarfarbe"])
	baue()

func herkunft_waehlen(h: String) -> void:
	b.waehle_herkunft(h)
	if not aussehen_eigen:   # Beispielkopf der Herkunft, solange der Spieler nichts gewaehlt hat; Geschlecht und Statur bleiben
		var g := String(aussehen.get("geschlecht", "m"))
		var st := String(aussehen.get("statur", "normal"))
		aussehen = HeldFigur.vorgabe(b.herkunft, g)
		aussehen["statur"] = st
	baue()

# Abenteuer beginnen: in den gewaehlten oder den ersten freien Platz; sind alle belegt, waehlt der Spieler, wen der Neue ersetzt (alt)
func beginne(p: int = 0) -> void:
	if not b.fertig(): return
	if p == 0: p = ziel if ziel > 0 else Spielstand.frei()
	if p == 0:
		platzwahl()
		return
	fertig.emit({"name": name_.strip_edges() if name_.strip_edges() != "" else Sprache.u("defaultName"),
		"brs": b.als_daten(), "aussehen": aussehen.duplicate(), "platz": p})

# SlotChooser: alle Plaetze belegt; der gewaehlte Spielstand geht verloren
func platzwahl() -> void:
	# 795 (wie 700 in erschaffung.gd; 630, 549a Rueckfrage): schwarz, oben der Titel mit Zierlinie, der Satz, die Spielstaende als Zeilen zum Antippen, Linie,
	# „‹ ABBRECHEN“ links; Tippen daneben und Android-Zurück schliessen (526), ein Tippen ins Fenster nicht
	var de := Sprache.aktiv() == "de"
	var schleier := Rueckfrage.schleier(self)
	schleier.color = Color.BLACK
	var mitte := Spielstaende.oben()
	schleier.add_child(mitte)
	var v := VBoxContainer.new()
	v.name = "Fenster"
	v.add_theme_constant_override("separation", int(10 * DP))
	v.custom_minimum_size.x = get_viewport_rect().size.x - 48 * DP
	mitte.add_child(Rueckfrage.halte(v))
	var t := Stil.zeile(("Alle Spielstand-Plätze sind belegt" if de else "All save slots are taken").to_upper(), Stil.TITEL_SP, Stil.GOLD, 3.0)   # 586a
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(t)
	v.add_child(Spielstaende.zier())
	var satz := txt("Welchen Helden soll der neue ersetzen? Der gewählte Spielstand geht dabei verloren." if de
		else "Which hero should the new one replace? That saved game will be lost.", 15, Stil.WARN)
	satz.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(satz)
	for d in Spielstand.liste():
		if d.is_empty(): continue
		var n := int(d["platz"])
		# 700 (549a): ohne Rahmen; die ganze Zeile ist antippbar (dunkel beim Druck, ausgeloest beim Loslassen) mit „›“ rechts
		var zeile_ := HBoxContainer.new()
		zeile_.add_theme_constant_override("separation", int(8 * DP))
		zeile_.mouse_filter = Control.MOUSE_FILTER_IGNORE
		zeile_.custom_minimum_size.y = 48 * DP
		zeile_.add_child(Spielstaende.karte(d, false))
		zeile_.add_child(Spielstaende.pfeil(Stil.GOLD, false))
		var karte := Spielstaende.tippbar(zeile_, func(): schleier.queue_free(); beginne(n))
		karte.name = "Platz%d" % n
		v.add_child(Spielstaende.linie())
		v.add_child(karte)
	v.add_child(Spielstaende.linie())
	v.add_child(Spielstaende.knopfzeile(Spielstaende.knopf("neben", "Abbrechen" if de else "Cancel", func(): schleier.queue_free(), true), null))

# der Held mit der Startausruestung seiner Herkunft fuer den Drehteller (870.4)
func held() -> BrsHeld:
	var h := BrsHeld.aus_daten(b.als_daten())
	h.name = name_ if name_.strip_edges() != "" else "?"
	h.ausstatten()
	return h

# HeroSummary: Name, Volk · Herkunft · Stufe, Leben und Mana, die sechs Grundwerte zu zweit
func kopf_neu() -> void:
	for c in kopf.get_children():
		kopf.remove_child(c)
		c.queue_free()
	var n := Stil.zeile((name_ if name_.strip_edges() != "" else "?").to_upper(), 14, Stil.GOLD, 3.0)   # MenuHead
	n.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	kopf.add_child(n)
	kopf.add_child(txt("%s · %s · %s %d" % [tx(VOLK.get(b.volk, {"de": b.volk})), tx(HERKUNFT.get(b.herkunft, {"de": b.herkunft})), Sprache.u("level"), 1], 14))
	kopf.add_child(txt("%s %d   %s %d" % [tx(T["leben"]), b.max_leben(1), tx(T["mana"]), b.max_mana()], 15, Stil.TEXT, true))   # 584: halbfett wie alt
	kopf.add_child(luecke(4))
	var gw := BrsHeld.grundwerte()
	for i in range(0, gw.size(), 2):
		var r := HBoxContainer.new()
		r.add_theme_constant_override("separation", 0)
		for g in gw.slice(i, i + 2):
			var l := txt("%d %s" % [b.wert(g), tx(GRUNDWERT[g])], 13)   # Zahl vorn: bleibt stehen, wenn der Name gekuerzt wird
			l.autowrap_mode = TextServer.AUTOWRAP_OFF
			l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			l.custom_minimum_size.x = 104 * DP   # wie alt; breiter schob die ganze Seite ueber den Rand (Pruefer 14:5x)
			r.add_child(l)
		kopf.add_child(r)
	# Pruefer 02.11., 14:5x (Chef 18:40 „Sokrates Bemerkungen berücksichtigen“): oben sichtbar, warum „Abenteuer beginnen“ gesperrt ist
	var fehlt := []
	if b.frei() != 0: fehlt.append(punkte_satz())
	if b.wahl.size() < b.wahl_anzahl(): fehlt.append(wahl_satz())
	if not fehlt.is_empty():
		var w := txt(" · ".join(PackedStringArray(fehlt)), 13.5, Spielstaende.mangel())   # 549a: Fehlendes im Maengelton, Warnfarbe nur fuer Zerstoerendes
		w.name = "Fehlt"
		kopf.add_child(luecke(4))
		kopf.add_child(w)

func punkte_satz() -> String:
	var frei_alle := BrsHeld.summe_soll() - BrsHeld.unten() * BrsHeld.grundwerte().size()
	return ("Punkte übrig: " if Sprache.aktiv() == "de" else "Points left: ") + "%d / %d" % [b.frei(), frei_alle]
func wahl_satz() -> String:
	return ("Selbst gewählt: " if Sprache.aktiv() == "de" else "Your choice: ") + "%d / %d" % [b.wahl.size(), b.wahl_anzahl()]

func namensfeld() -> Control:
	var e := LineEdit.new()
	e.text = name_
	e.max_length = 12
	e.add_theme_font_override("font", Stil.variante(0.5))
	e.add_theme_font_size_override("font_size", int(round(24 * Stil.SP)))
	e.add_theme_color_override("font_color", Stil.TEXT)
	e.add_theme_color_override("caret_color", Stil.GOLD)
	var s := Stil.kasten(Stil.RAISED, Stil.RIM, 1.0)
	s.set_content_margin_all(12 * DP)
	for z in ["normal", "focus"]: e.add_theme_stylebox_override(z, s)
	e.text_changed.connect(func(t): name_ = t; kopf_neu())
	e.text_submitted.connect(func(_t): e.release_focus())
	return e

# Choices: je Zeile drei Felder gleicher Breite; 549a (wie 630): ohne Rahmen, das gewaehlte BRIGHT auf RAISED, die anderen in Gold
func wahl(was: Array, gewaehlt: String, wort: Callable, nimm: Callable, spalten := 3) -> Control:
	var g := GridContainer.new()
	g.columns = spalten
	g.add_theme_constant_override("h_separation", int(6 * DP))
	g.add_theme_constant_override("v_separation", int(6 * DP))
	for x in was:
		var k := Stil.wahlfeld(String(wort.call(x)), x == gewaehlt, func(): nimm.call(x))
		k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		g.add_child(k)
	return g

# Grundwerte verteilen (wie PointBuy alt): Punkte uebrig, Satz aus dem Handbuch, je Wert Name, Endwert, Volk, − und +; beim Menschen
# waehlt „+1“ den Wert mit dem freien Punkt
func grundwerte() -> void:
	inhalt.add_child(kopfzeile(tx(T["werte"])))
	var p := VBoxContainer.new()
	p.add_theme_constant_override("separation", int(4 * DP))
	p.add_child(txt(punkte_satz(), 15, Stil.BRIGHT if b.frei() > 0 else Stil.TEXT, true))   # 584: wie „Punkte übrig“ alt
	p.add_child(txt(tx(T["schaffen"]), 13.5, Spielstaende.ANGABE))   # 549a: nie unter 13 sp, DIM heisst gesperrt
	var mensch := int(BrsHeld.e()["voelker"][b.volk].get("frei", 0)) > 0
	for g in BrsHeld.grundwerte():
		var r := HBoxContainer.new()
		r.add_theme_constant_override("separation", 0)
		var n := txt(tx(GRUNDWERT[g]), 14)
		n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		n.autowrap_mode = TextServer.AUTOWRAP_OFF
		n.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		n.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		r.add_child(n)
		n.resized.connect(func():   # 630: der Name ganz, notfalls kleiner bis 13 sp (549a), statt mit „…“ gekuerzt
			if is_equal_approx(float(n.get_meta("breite", -1.0)), n.size.x): return
			n.set_meta("breite", n.size.x)
			for sp_ in [14.0, 13.5, 13.0]:
				var gg := int(round(sp_ * 0.95 * Stil.SP))
				n.add_theme_font_size_override("font_size", gg)
				if n.get_theme_font("font").get_string_size(n.text, HORIZONTAL_ALIGNMENT_LEFT, -1, gg).x <= n.size.x: break)
		var vp := b.volk_plus(g)   # Pruefer 14:5x: auch das Minus des Volks (933: Elf, Zaehigkeit 3 -> 2)
		for z in [[str(b.wert(g)), 16, Stil.TEXT, 28], [vorzeichen(vp).replace("-", "−") if vp != 0 else "", 13, Stil.GOLD if vp > 0 else Spielstaende.mangel(), 28]]:
			var l := txt(z[0], z[1], z[2], z[1] == 16)   # 584: der Wert halbfett wie alt
			l.autowrap_mode = TextServer.AUTOWRAP_OFF
			l.size_flags_horizontal = Control.SIZE_SHRINK_END   # Pruefer 14:5x: die Zahlen nahmen dem Namen den Platz („Wahrnehmu…“)
			l.custom_minimum_size.x = z[3] * DP
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			r.add_child(l)
		if mensch:   # Wahlfeld ohne Rahmen, der gewaehlte Wert BRIGHT auf RAISED (549a)
			var f := Stil.wahlfeld("+1", b.frei_ziel() == g, func(): b.mensch_frei = g; baue())
			f.custom_minimum_size.x = 48 * DP
			f.size_flags_horizontal = Control.SIZE_SHRINK_END
			r.add_child(f)
		r.add_child(Stil.zahl_knopf("−", func(): b.runter(g); baue(), b.kann_runter(g)))
		r.add_child(Stil.zahl_knopf("+", func(): b.hoch(g); baue(), b.kann_hoch(g)))
		p.add_child(r)
	inhalt.add_child(p)

# Startfertigkeiten: die der Herkunft fest, dazu die eigene Wahl (Wanderer zwei, Mensch eine mehr) aus den Gruppen des Handbuchs
func fertigkeiten() -> void:
	inhalt.add_child(kopfzeile(tx(T["fert"])))
	var p := VBoxContainer.new()
	p.add_theme_constant_override("separation", int(6 * DP))
	var alle := b.fertigkeiten()
	p.add_child(txt(", ".join(PackedStringArray(alle.keys().map(func(f): return "%s %d" % [fert_name(String(f)), int(alle[f])]))) if not alle.is_empty() else "—", 15))
	if b.wahl_anzahl() > 0:
		p.add_child(txt(wahl_satz(), 15, Stil.BRIGHT if b.wahl.size() < b.wahl_anzahl() else Stil.TEXT, true))
		var wb := BrsHeld.waehlbar()
		for gr in wb:
			var liste: Array = (wb[gr] as Array).filter(func(f): return not b.herkunft_fertigkeiten().has(f))
			if liste.is_empty(): continue
			p.add_child(txt(tx(GRUPPE.get(gr, {"de": gr, "en": gr})), 13.5, Spielstaende.ANGABE))
			var g := GridContainer.new()
			g.columns = 2   # Pruefer 14:5x: zu dritt gekappt („Schlösser kn“)
			g.add_theme_constant_override("h_separation", int(6 * DP))
			g.add_theme_constant_override("v_separation", int(6 * DP))
			for f in liste:
				var k := Stil.wahlfeld(fert_name(String(f)), b.wahl.has(f), func(): b.waehle(String(f)); baue(), b.wahl.has(f) or b.kann_waehlen(String(f)))
				k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				g.add_child(k)
			for i in (2 - liste.size() % 2) % 2: g.add_child(luecke_breit())   # Pruefer 02.11., 14:5x: „Tiere beruhigen“ allein in seiner Gruppe war breiter
			p.add_child(g)
	inhalt.add_child(p)

# HeroTurntable (drehteller.gd); 376.1, 870.4 mit Herkunft, Aussehen und Grundausruestung
func vorschau() -> Control:
	teller = Drehteller.new(wahl_jetzt(), 0.9)
	teller_wahl = str(wahl_jetzt())
	return teller

func wahl_jetzt() -> Dictionary:
	return {"herkunft": b.herkunft, "volk": HeldFigur.volk_modell(b.volk), "aussehen": aussehen.duplicate(), "ausruestung": held().ausruestung}

func zeige_held() -> void:
	var w := wahl_jetzt()
	if teller == null or str(w) == teller_wahl: return
	teller_wahl = str(w)
	teller.zeige(w)

# 376.1 Aussehen (CreateScreen.kt „Aussehen“): Haut und Haar als Farbfelder des Volks wie alt (ToneChoices), Gesicht, Frisur, Bart als Knoepfe
func aussehen_wahl() -> void:
	var de := Sprache.aktiv() == "de"
	inhalt.add_child(kopfzeile("Aussehen" if de else "Appearance"))
	# wie alt (CreateScreen.kt Choices Sex, Build): Geschlecht und Statur zuerst
	var g := String(aussehen.get("geschlecht", "m"))
	inhalt.add_child(wahl(HeldFigur.GESCHLECHTER, g, func(x): return HeldFigur.wort("geschlecht:" + x), geschlecht_waehlen))
	inhalt.add_child(wahl(HeldFigur.STATUREN, String(aussehen.get("statur", "normal")), func(x): return HeldFigur.wort("statur:" + x),
		func(x): aussehen["statur"] = x; baue()))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", int(8 * DP))
	v.add_child(toene("Haut" if de else "Skin", HeldFigur.toene_liste(b.volk, "haut"), "haut"))
	v.add_child(toene("Haar" if de else "Hair", HeldFigur.toene_liste(b.volk, "haar"), "haarfarbe"))
	inhalt.add_child(v)
	for teil in [["form", HeldFigur.formen()], ["frisur", HeldFigur.frisuren(g)], ["bart", HeldFigur.baerte(g)]]:
		if (teil[1] as Array).size() < 2: continue   # Heldin: kein Bart
		inhalt.add_child(txt(HeldFigur.wort(teil[0]), 14))
		inhalt.add_child(wahl(teil[1], String(aussehen.get(teil[0], "")), func(x): return HeldFigur.wort(teil[0] + ":" + x),
			func(x): aussehen[teil[0]] = x; aussehen_eigen = true; baue()))

# Geschlecht: Frisur aus der Liste des Geschlechts (eigene bleibt, wenn es sie dort gibt), Heldin ohne Bart; Gesicht, Farben, Statur bleiben
func geschlecht_waehlen(g: String) -> void:
	aussehen["geschlecht"] = g
	if not aussehen_eigen or String(aussehen.get("frisur", "")) not in HeldFigur.frisuren(g):
		aussehen["frisur"] = String(HeldFigur.vorgabe(b.herkunft, g)["frisur"])
	if String(aussehen.get("bart", "")) not in HeldFigur.baerte(g): aussehen["bart"] = ""
	baue()

# ToneChoices: Beschriftung, dann je Ton ein Feld mit Namen darunter; das gewaehlte mit Goldrand
func toene(wort: String, liste: Array, schluessel: String) -> Control:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", int(6 * DP))
	var l := txt(wort, 14)
	l.size_flags_horizontal = Control.SIZE_FILL
	l.custom_minimum_size.x = 52 * DP
	r.add_child(l)
	var gewaehlt := clampi(int(aussehen.get(schluessel, 0)), 0, maxi(0, liste.size() - 1))
	for i in liste.size():
		var t: Dictionary = liste[i]
		var sp := VBoxContainer.new()
		sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sp.add_theme_constant_override("separation", int(2 * DP))
		sp.alignment = BoxContainer.ALIGNMENT_CENTER
		var feld := Panel.new()
		feld.custom_minimum_size = Vector2(34, 34) * DP
		feld.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		feld.mouse_filter = Control.MOUSE_FILTER_IGNORE   # 416.1: ein Panel faengt das Tippen sonst selbst ab (nur der Name darunter wirkte)
		var sb := Stil.kasten(Color.html(String(t["rgb"])), Stil.GOLD if i == gewaehlt else Stil.RIM, 3.0 if i == gewaehlt else 1.0)
		sb.set_corner_radius_all(int(6 * DP))
		feld.add_theme_stylebox_override("panel", sb)
		sp.add_child(feld)
		var n := Stil.zeile(Sprache.t(t["name"]), 11, Stil.GOLD if i == gewaehlt else Stil.DIM, 0.0)
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		n.clip_text = true
		sp.add_child(n)
		var nr := i
		sp.mouse_filter = Control.MOUSE_FILTER_STOP
		sp.gui_input.connect(func(e): if e is InputEventMouseButton and e.pressed: aussehen[schluessel] = nr; aussehen_eigen = true; baue())
		r.add_child(sp)
	return r

# ---------------------------------------------------------------- Bausteine aus erschaffung.gd (549a)

static func vorzeichen(n: int) -> String: return Stil.vorzeichen(n)
static func txt(t: String, groesse_sp: float, farbe := Stil.TEXT, fett := false) -> Label: return Stil.txt(t, groesse_sp, farbe, fett)
static func kopfzeile(t: String) -> Label: return Stil.kopfzeile(t)
static func luecke(hoch_dp: float, breit_dp := 0.0) -> Control: return Stil.luecke(hoch_dp, breit_dp)

# leere Zelle, die im Raster so breit wird wie ein Feld (Feld allein in seiner Reihe bleibt halb breit)
static func luecke_breit() -> Control:
	var c := Control.new()
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c
