class_name BrsHeld
extends RefCounted
# 470 (Abnahme 1.1): Erschaffung nach dem BRS (Nachschlagewerk Abschnitt 2, E 68-72, 77, 78). Jeder Grundwert beginnt bei 3, der
# Spieler verteilt 9 Punkte bis hoechstens 8 (intern start 1, 21 Punkte, Untergrenze 3); das Volk gibt +1/+1/-1 (Mensch +1 frei) und
# darf bis 9 heben und bis 2 senken (933 A, Chef 11.11., 13:07); die Herkunft verteilt vor (aenderbar) und gibt ihre Startfertigkeiten, der Wanderer verteilt selbst und waehlt
# zwei, der Mensch waehlt eine mehr (Wandelbar); jede Startfertigkeit beginnt beim Startwert (10).
# 870.4 (LISTE-UMZUG-BRS.md Schritt 4): BrsHeld ist die einzige Quelle fuer die Werte des Helden im Spiel; heldwerte.gd (SRD, Hero.kt)
# entfaellt. Dazu gehoeren Name, Heldenstufe (Spiegel von Zustand.brs_stufe, Brs.neuer_stand), Leben und Mana jetzt, was er traegt
# (Ausruestung als Woerterbuch wie Gear: {uid, base, rarity, ilvl, plus, rolls, unique}, Grundformen aus daten/held.json) und was er
# seither geuebt hat (Zustand.fert). Jeder darf alles tragen (DESIGN-BRS.md 7); Leben, Mana, Schutzwert, Schaden nach Abschnitt 2,
# 4 und 7. Von den Zusatzeigenschaften der Gegenstaende wirken die auf Grundwerte (gedeckelt im Kapitel wie bisher); den Rest
# ordnet 870.6 (Jerry).
# Einzige Quelle der Zahlen: daten/werte.json = tools/sim444/werte.json (Bloecke „held“, „herkuenfte“, „erschaffung“, „kampf“,
# „ruestungen“, „waffen“, „welt“), dieselbe Datei wie die Simulation 444 und regeln/brs.gd (Jerry). Gegenprobe: tests/brs_470.gd,
# tests/brs_held_870.gd.

const DATEI := "res://daten/werte.json"
const DINGE := "res://daten/held.json"
const WANDERER := "Wanderer"

static var W := {}
static var D := {}

# ---------------------------------------------------------------- Erschaffung
var volk := "Mensch"
var herkunft := WANDERER
var verteilt := {}                 # Grundwert -> Wert vor dem Volk (3 bis 8)
var mensch_frei := ""              # Mensch: Grundwert mit dem freien +1
var wahl: Array = []               # selbst gewaehlte Startfertigkeiten (Wanderer zwei, Mensch eine mehr)

# ---------------------------------------------------------------- Im Spiel (870.4)
var name := "Alrik"
var stufe := 1                     # Heldenstufe, Spiegel von Zustand.brs_stufe["stufe"] (spiel.gd stufe_abgleichen)
var leben := 0                     # Leben jetzt
var mana := 0                      # Mana jetzt
var ausruestung := {}              # Platz -> Gear
var kapitel := 1                   # begrenzt die Boni der Ausruestung (Hero.chapter)
var geuebt := {}                   # Fertigkeit -> Wert, wie er sie seither geuebt hat (Zustand.fert „werte“)

static func lade() -> Dictionary:
	if W.is_empty():
		var j = JSON.parse_string(FileAccess.get_file_as_string(DATEI)) if FileAccess.file_exists(DATEI) else null
		if j is Dictionary: W = j
		else: push_error("470: %s fehlt oder ist kaputt" % DATEI)
	return W

## Grundformen, Seltenheiten, Plaetze und Zusatzeigenschaften der Gegenstaende, Haut- und Haarfarben der Voelker (daten/held.json,
## HeroExport.kt); Stufe und Preis der Grundformen nur aus dem Gegenstandskatalog (458.2)
static func daten() -> Dictionary:
	if D.is_empty() and FileAccess.file_exists(DINGE):
		var j = JSON.parse_string(FileAccess.get_file_as_string(DINGE))
		if j is Dictionary:
			D = j
			for id in D.get("grundformen", {}):
				if not Katalog.hat(String(id)): push_error("458.2: Grundform %s fehlt im Katalog" % id); continue
				D["grundformen"][id]["preis"] = Katalog.preis(String(id))
				D["grundformen"][id]["ab_stufe"] = Katalog.stufe(String(id))
			brs_woerter(D)
	return D

# 683 (Regelwerk Abschnitt 12, [423.werte]): die Zusatzeigenschaften der Gegenstaende heissen nach dem BRS (Staerke -> Kraft …,
# Schutzwert, Leben, Mana nach DESIGN-BRS.md 12)
const BRS_AFFIX := {"STR": {"de": "Kraft", "en": "Strength"}, "DEX": {"de": "Gewandtheit", "en": "Agility"},
	"CON": {"de": "Zähigkeit", "en": "Toughness"}, "INT": {"de": "Verstand", "en": "Wits"}, "WIS": {"de": "Wahrnehmung", "en": "Perception"},
	"CHA": {"de": "Wille", "en": "Will"}, "ALL_STATS": {"de": "alle Grundwerte", "en": "all attributes"},
	"AC": {"de": "Schutzwert", "en": "Protection"}, "HP": {"de": "Leben", "en": "Life"}, "SP": {"de": "Mana", "en": "Mana"},
	"CRIT": {"de": "kritisch", "en": "critical"}, "SPELL": {"de": "Zauberschaden", "en": "spell damage"},
	"TENACITY": {"de": "Abwehrprobe", "en": "resistance roll"}}     # 870.6 (DESIGN-BRS.md 11, STORY-BRS-HELD.md)

const BRS_KURZ := {"STR": {"de": "KRA", "en": "STR"}, "DEX": {"de": "GEW", "en": "AGI"}, "CON": {"de": "ZÄH", "en": "TOU"},
	"INT": {"de": "VER", "en": "WIT"}, "WIS": {"de": "WAH", "en": "PER"}, "CHA": {"de": "WIL", "en": "WIL"}}

static func brs_woerter(d: Dictionary) -> void:
	# 870.6, Homer 925 ([925.namen.abwehr]): Namensteile der Abwehrprobe (Kennung TENACITY, alt Standhaftigkeit)
	if d.get("affixdaten", {}).has("TENACITY"):
		d["affixdaten"]["TENACITY"].merge({"vor_de": "Wehrhaft", "vor_en": "Defiant", "nach_de": "des Hexenjägers", "nach_en": "of the Witch Hunter"}, true)
	# 870.6: „Fertigkeit +n“ ab episch (DESIGN-BRS.md 11, 644 C1); Namen der Stuecke ab episch kommen aus den Namenslisten
	if d.has("affixdaten") and not d["affixdaten"].has("SKILL"):
		d["affixdaten"]["SKILL"] = {"name": {"de": "Fertigkeit", "en": "Skill"}, "vor_de": "Kundig", "vor_en": "Skilled",
			"nach_de": "des Meisters", "nach_en": "of the Master", "prozent": false}
	var zusatz: Dictionary = lade().get("gegenstaende", {}).get("zusatz", {})
	for a in BRS_AFFIX:
		if d.get("affixdaten", {}).has(a):
			d["affixdaten"][a]["name"] = BRS_AFFIX[a]
			d["affixdaten"][a]["prozent"] = bool(zusatz.get(a, {}).get("prozent", false))     # 870.6: kritisch, Zauberschaden, Abwehrprobe in %
		if d.get("attribute", {}).has(a):
			d["attribute"][a]["name"] = BRS_AFFIX[a]
			d["attribute"][a]["kurz"] = BRS_KURZ[a]

static func grundform(id: String) -> Dictionary: return daten()["grundformen"][id]

static func e() -> Dictionary: return lade().get("erschaffung", {})
static func h() -> Dictionary: return lade().get("held", {})
static func welt() -> Dictionary: return lade().get("welt", {})
static func ohne_info(d: Dictionary) -> Array: return d.keys().filter(func(k): return not String(k).begins_with("_"))
static func grundwerte() -> Array: return e().get("grundwerte", [])
static func voelker() -> Array: return ohne_info(e().get("voelker", {}))
## Herkuenfte in der Reihenfolge der Datei, der Wanderer zuletzt
static func herkuenfte() -> Array:
	var l := ohne_info(lade().get("herkuenfte", {}))
	l.erase(WANDERER)
	l.append(WANDERER)
	return l
static func unten() -> int: return int(h().get("grundwert_min", 3))
static func oben() -> int: return int(h().get("grundwert_max", 8))
## Summe der Werte vor dem Volk: Start je Wert plus alle Punkte (6 x 1 + 21 = 27)
static func summe_soll() -> int: return int(e().get("start", 1)) * grundwerte().size() + int(e().get("punkte", 21))

static func neu(v := "Mensch", hk := WANDERER) -> BrsHeld:
	var b := BrsHeld.new()
	b.volk = v
	b.waehle_herkunft(hk)
	return b

## Herkunft waehlen: sie verteilt die Punkte vor (Untergrenze plus „plus“ und „plus_variante“ aus der Datei); der Wanderer steht
## ueberall auf der Untergrenze und verteilt die freien Punkte selbst
func waehle_herkunft(hk: String) -> void:
	herkunft = hk
	verteilt = {}
	for g in grundwerte(): verteilt[g] = unten()
	if hk != WANDERER:
		var d: Dictionary = lade().get("herkuenfte", {}).get(hk, {})
		for teil in ["plus", "plus_variante"]:
			for g in d.get(teil, {}): verteilt[g] = mini(oben(), int(verteilt[g]) + int(d[teil][g]))
	var hf := herkunft_fertigkeiten()
	wahl = wahl.filter(func(f): return not hf.has(f))
	while wahl.size() > wahl_anzahl(): wahl.pop_back()

func frei() -> int:
	var s := 0
	for g in grundwerte(): s += int(verteilt[g])
	return summe_soll() - s

func kann_hoch(g: String) -> bool: return int(verteilt[g]) < oben() and frei() > 0
func kann_runter(g: String) -> bool: return int(verteilt[g]) > unten()
func hoch(g: String) -> void:
	if kann_hoch(g): verteilt[g] = int(verteilt[g]) + 1
func runter(g: String) -> void:
	if kann_runter(g): verteilt[g] = int(verteilt[g]) - 1

## Volk auf einen Grundwert (Mensch: das freie +1 auf mensch_frei, sonst auf den hoechsten Wert)
func volk_plus(g: String) -> int:
	var vd: Dictionary = e().get("voelker", {}).get(volk, {})
	var p := int(vd.get("plus", {}).get(g, 0))
	if int(vd.get("frei", 0)) > 0 and g == frei_ziel(): p += int(vd["frei"])
	return p

func frei_ziel() -> String:
	if int(e().get("voelker", {}).get(volk, {}).get("frei", 0)) <= 0: return ""
	if mensch_frei != "" and grundwerte().has(mensch_frei): return mensch_frei
	var best: String = grundwerte()[0]
	for g in grundwerte():
		if int(verteilt[g]) > int(verteilt[best]): best = g
	return best

## Endwert: verteilt plus Volk (das Volk hebt hoechstens bis volk_max und senkt nie unter volk_min), dazu was Ueben gibt (644a F, ersetzt
## 870a 4 „in Kapitel 1 fest“) und was die Ausruestung gibt (870.4: Zusatzeigenschaft des Grundwerts und „alle Grundwerte“, Deckel nach
## werte.json „deckel“)
func wert(g: String) -> int: return grundwert(g) + uebungs_plus(g) + ausruestungs_bonus(g)

## 644a F (Chef 12.11., 08:21): an welchem Grundwert eine Fertigkeit haengt: werte.json „ueben“ „grundwert_von“, sonst „grundwert“ ihrer
## Waffengruppe oder Schule („waffen“, „schulen“); "" an keinem
static func grundwert_der_fertigkeit(f: String) -> String:
	var W_ := lade()
	var gv = W_.get("ueben", {}).get("grundwert_von", {}).get(f)
	if gv != null: return String(gv)
	for blk in ["waffen", "schulen"]:
		var d = W_.get(blk, {}).get(f)
		if d is Dictionary and d.get("grundwert") != null: return String(d["grundwert"])
	return ""

## 644a F: Punkte, die die Fertigkeiten an [g] seit dem Start gewonnen haben (geuebt ueber dem Startwert; „Fertigkeit +n“ der
## Ausruestung zaehlt nicht); [geuebt_] statt des Geuebten dieses Helden
func geuebte_punkte(g: String, geuebt_ = null) -> int:
	var ge: Dictionary = geuebt if geuebt_ == null else geuebt_
	var start := fertigkeiten()
	var n := 0
	for f in ge:
		if grundwert_der_fertigkeit(String(f)) == g: n += maxi(0, int(ge[f]) - int(start.get(String(f), 0)))
	return n

## 644a F: was Ueben dem Grundwert [g] gibt: +1 je „ueben“ „grundwert_punkte“ gewonnene Punkte
func uebungs_plus(g: String, geuebt_ = null) -> int:
	var n := int(lade().get("ueben", {}).get("grundwert_punkte", 0))
	return geuebte_punkte(g, geuebt_) / n if n > 0 else 0

## 644a F (fuer die Meldung „Grundwert gestiegen“, 644a.2 Tom): die Grundwerte, die durch Ueben hoeher sind als mit [geuebt_vorher]
func grundwerte_gestiegen(geuebt_vorher: Dictionary) -> Array:
	return grundwerte().filter(func(g): return uebungs_plus(String(g)) > uebungs_plus(String(g), geuebt_vorher))

func grundwert(g: String) -> int:
	var v := int(verteilt.get(g, unten()))
	var p := volk_plus(g)
	if p > 0: return mini(v + p, maxi(v, int(e().get("volk_max", 9))))
	if p < 0: return maxi(v + p, mini(v, int(e().get("volk_min", 2))))
	return v

## Grundwert -> Kennung seiner Zusatzeigenschaft an Gegenstaenden (held.json affixdaten; Kennungen bleiben, Namen nach BRS_AFFIX)
const AFFIX := {"kraft": "STR", "gewandtheit": "DEX", "zaehigkeit": "CON", "verstand": "INT", "wahrnehmung": "WIS", "wille": "CHA"}
func ausruestungs_bonus(g: String) -> int:
	if ausruestung.is_empty() or not AFFIX.has(g): return 0
	var a := String(AFFIX[g])
	return mini(roh_bonus(a) + roh_bonus("ALL_STATS"), deckel(a))
func ausruestung_gedeckelt(g: String) -> bool:
	return AFFIX.has(g) and roh_bonus(String(AFFIX[g])) + roh_bonus("ALL_STATS") > ausruestungs_bonus(g)

func werte() -> Dictionary:
	var r := {}
	for g in grundwerte(): r[g] = wert(g)
	return r

func merkmal() -> String: return String(e().get("voelker", {}).get(volk, {}).get("merkmal", ""))

# ---------------------------------------------------------------- Startfertigkeiten
func herkunft_fertigkeiten() -> Array:
	if herkunft == WANDERER: return []
	return lade().get("herkuenfte", {}).get(herkunft, {}).get("fertigkeiten", [])

## so viele waehlt der Spieler selbst: der Wanderer zwei, der Mensch eine mehr
func wahl_anzahl() -> int:
	var n := int(e().get("wanderer_fertigkeiten", 2)) if herkunft == WANDERER else 0
	return n + int(e().get("voelker", {}).get(volk, {}).get("fertigkeit_extra", 0))

## alle waehlbaren Fertigkeiten (Gruppe -> Namen), ohne die der Herkunft und ohne „nicht_waehlbar“ (Bergbau ab Kapitel 2)
static func waehlbar() -> Dictionary:
	var r := {}
	var fd: Dictionary = e().get("fertigkeiten", {})
	var nein: Array = e().get("nicht_waehlbar", [])
	for gr in ohne_info(fd): r[gr] = (fd[gr] as Array).filter(func(f): return not nein.has(f))
	return r

func kann_waehlen(f: String) -> bool:
	return not herkunft_fertigkeiten().has(f) and not wahl.has(f) and wahl.size() < wahl_anzahl() and not (e().get("nicht_waehlbar", []) as Array).has(f)

func waehle(f: String) -> void:
	if wahl.has(f): wahl.erase(f)
	elif kann_waehlen(f): wahl.append(f)

## die Startfertigkeiten mit dem Startwert
func fertigkeiten() -> Dictionary:
	var r := {}
	for f in herkunft_fertigkeiten() + wahl: r[String(f)] = int(h().get("startfertigkeit", 10))
	return r

## Wert einer Fertigkeit jetzt: wie geuebt, sonst Startwert, sonst 0
func fertigkeit(f: String) -> int:
	if geuebt.has(f): return int(geuebt[f])
	return int(fertigkeiten().get(f, 0))

## alle Fertigkeiten mit Wert jetzt (Start und Geuebtes)
func fertigkeiten_jetzt() -> Dictionary:
	var r := fertigkeiten()
	for f in geuebt: r[String(f)] = int(geuebt[f])
	return r

func fertig() -> bool: return frei() == 0 and wahl.size() == wahl_anzahl()

# ---------------------------------------------------------------- Abgeleitet (N 2 und 4: Leben aus Zaehigkeit und Stufe, Mana aus Wille)
## Leben voll auf [s] (ohne Angabe die Heldenstufe)
func max_leben(s := -1) -> int:
	if s < 0: s = stufe
	return int(h()["leben_basis"]) + int(h()["leben_je_stufe"]) * s + int(h()["leben_je_zaehigkeit"]) * wert("zaehigkeit") + bonus("HP")
func max_mana() -> int: return int(h()["mana_basis"]) + int(h()["mana_je_wille"]) * wert("wille") + bonus("SP")     # 870.6: + Leben, Mana der Ausruestung

func begrenze() -> void:
	leben = clampi(leben, 0, max_leben())
	mana = clampi(mana, 0, max_mana())

func voll() -> void:
	leben = max_leben()
	mana = max_mana()

## Kritische Treffer in Prozent mit der Hauptwaffe (952 D: zweiter Grundwert der Waffengruppe × Fertigkeit / 50, BrsKampf.krit_prozent)
func krit_prozent() -> int:
	var gruppe := waffengruppe()
	var werte := {}
	for g in ["kraft", "gewandtheit", "zaehigkeit", "verstand", "wille", "wahrnehmung"]: werte[g] = wert(g)
	return roundi(krit_von(werte, gruppe, float(fertigkeit(gruppe) + fertigkeit_bonus(gruppe)))) + bonus("CRIT")

## 952 D (Chef 11.11., 20:03; sim.py krit_prozent): kritisch in Prozent = zweiter Grundwert × Fertigkeit / 50, nie der Grundwert des
## Schadens; welcher, steht je Waffengruppe und Schule in werte.json unter „kritisch“ (null: nie, Heil- und Schutzmagie)
static func krit_von(werte: Dictionary, gruppe_oder_schule: String, fertigkeit: float) -> float:
	var W := lade()
	var k: Dictionary = W["kampf"]
	var eintrag = W["waffen"].get(gruppe_oder_schule, W.get("schulen", {}).get(gruppe_oder_schule, {}))
	var g = eintrag.get("kritisch") if eintrag is Dictionary else null
	if g == null or String(g) == "":
		return 0.0
	return float(k["kritisch_je_punkt"]) * float(werte.get(String(g), 0)) * fertigkeit / float(k["kritisch_fertigkeit_teiler"])

## Schaden eines Treffers mit der Hauptwaffe gegen einen Gegner gleicher Stufe ohne Ruestung, ohne Zufall (Modell D: (Grundschaden
## + Grundwert) x (1 + Fertigkeit/100), wie mars.gd _brs_waffe)
func schaden() -> int:
	var gruppe := waffengruppe()
	var wd: Dictionary = lade()["waffen"].get(gruppe, lade()["waffen"]["Faustkampf"])
	var gw = wd.get("grundwert")
	var grund := float(wd["schaden"]) * Beute.guete_faktor(waffe()) + (float(wert(String(gw))) if gw != null else 0.0)     # 870.6: Guete
	return Brs.runde(grund * (1.0 + (fertigkeit(gruppe) + fertigkeit_bonus(gruppe)) * float(lade()["kampf"]["fertigkeit_im_schaden_je_punkt"])))

## Waffengruppe des BRS der Hauptwaffe (werte.json „waffen“), unbewaffnet Faustkampf
func waffengruppe() -> String:
	var w_ = waffe()
	return String(WAFFE_GRUPPE.get(String(w_["base"]) if w_ != null else "", "Einhänder"))

## Ruestung des BRS aus dem Gewicht der Brustruestung (LIGHT, MEDIUM, HEAVY), sonst keine
func ruestung() -> String:
	var r = ding("CHEST")
	return ruestung_von(String(r["base"])) if r != null else "keine"

static func ruestung_von(base: String) -> String:
	var gew: String = String(grundform(base).get("gewicht", ""))
	return String({"LIGHT": "Leichte Rüstung", "MEDIUM": "Mittlere Rüstung", "HEAVY": "Schwere Rüstung"}.get(gew, "keine"))

## Fertigkeit, die ein Stueck braucht (Waffe: ihre Gruppe, Brustruestung: ihre Ruestung, Schild), sonst ""
static func fertigkeit_von(base: String) -> String:
	var b := grundform(base)
	match String(b["art"]):
		"WEAPON": return String(WAFFE_GRUPPE.get(base, "Einhänder"))
		"SHIELD": return "Schild"
		"ARMOR":
			if String(b["slot"]) == "CHEST":
				var f = lade()["ruestungen"].get(ruestung_von(base), {}).get("fertigkeit")
				return String(f) if f != null else ""
	return ""

## Schutzwert eines Stuecks nach BRS (Brustruestung: Wert ihrer Ruestung, Schild: schild_wert), sonst 0
static func schutzwert_von(base: String) -> int:
	var b := grundform(base)
	if String(b["art"]) == "SHIELD": return int(lade()["ruestungen"].get("schild_wert", 0))
	if String(b["art"]) == "ARMOR" and String(b["slot"]) == "CHEST": return int(lade()["ruestungen"].get(ruestung_von(base), {}).get("wert", 0))
	return 0

## Metall (DESIGN-BRS.md 7: Evokation, Illusion, Beschwoerung nur in Stoff oder Leder): mittlere und schwere Brustruestung
static func metall(base: String) -> bool: return ruestung_von(base) in ["Mittlere Rüstung", "Schwere Rüstung"]

func schild():
	var s = ding("OFF_HAND")
	return s if s != null and String(grundform(s["base"])["art"]) == "SHIELD" else null

## Schutzwert: Abzug von jedem Treffer, Ruestung x (1 + Ruestungsfertigkeit/100) und Schild x (1 + Schild/100), gerundet (N 7,
## brs_kampf.gd held_abzug)
func schutzwert() -> int:
	var ru: Dictionary = lade()["ruestungen"]
	var r: Dictionary = ru.get(ruestung(), ru["keine"])
	var je := float(lade()["kampf"]["ruestungsfertigkeit_im_abzug_je_punkt"])
	var f_ = r["fertigkeit"]
	var a := float(r["wert"]) * Beute.guete_faktor(ding("CHEST")) * (1.0 + ((fertigkeit(String(f_)) + fertigkeit_bonus(String(f_))) if f_ != null else 0) * je)
	if schild() != null: a += float(ru["schild_wert"]) * Beute.guete_faktor(schild()) * (1.0 + (fertigkeit("Schild") + fertigkeit_bonus("Schild")) * je)
	return Brs.runde(a) + bonus("AC")     # 870.6: Guete der Stuecke, Schutzwert der Zusatzeigenschaften

## Ausdauer: wie viele Sekunden der Held rennen kann (welt „ausdauer“, aus Zaehigkeit und Wille, 467)
func ausdauer_s() -> float:
	var a: Dictionary = welt().get("ausdauer", {})
	var s := float(a.get("sekunden", 6)) + float(a.get("je_punkt", 0.5)) * (wert("zaehigkeit") + wert("wille") - float(a.get("mitte", 10))) \
		+ float(a.get("je_zwei_stufen", 1)) * int(stufe / 2)
	return maxf(s, float(a.get("min", 2)))

## in schwerer Ruestung ohne die Kraft dafuer (halb so lange rennen)
func zu_schwer() -> bool:
	return ruestung() == "Schwere Rüstung" and wert("kraft") < int(welt().get("ausdauer", {}).get("schwer_kraft", 7))

## 870d (Vorentscheid Sokrates): Schwaechen und Staerken der Gegner vorher sehen ab Verstand „wissen_verstand_ab“ (Ziel-Tipp, Bestiarium)
func kennt_schwaechen() -> bool: return wert("verstand") >= int(welt().get("wissen_verstand_ab", 6))

## Aus wie vielen Feldern ein jagendes Monster den Helden bemerkt (welt „bemerken_…“; alt Perks.noticeRange nach Geschicklichkeit)
func bemerkt_aus() -> int:
	var wl := welt()
	var weniger := int(float(wl.get("bemerken_je_gewandtheit", 0.2)) * (wert("gewandtheit") - int(wl.get("sinne_ab", 3))))     # 933: eine 2 zaehlt mit
	return maxi(int(wl.get("bemerken_min", 2)), int(wl.get("bemerken_felder", 4)) - weniger)

## Faktor auf die Chance eines Hinterhalts nach Wahrnehmung (alt Perks.ambushFactor nach Weisheit)
func hinterhalt_faktor() -> float:
	var wl := welt()
	return maxf(float(wl.get("hinterhalt_min", 0.4)), 1.0 - float(wl.get("hinterhalt_je_wahrnehmung", 0.075)) * (wert("wahrnehmung") - int(wl.get("sinne_ab", 3))))     # 933: eine 2 zaehlt mit

# ---------------------------------------------------------------- Ausruestung (aus heldwerte.gd 390, Hero.equip)
static func gesamt(g: Dictionary, affix: String) -> int:
	var n := 0
	for r in g.get("rolls", []):
		if String(r[0]) == affix: n += int(r[1])
	return n

func ding(platz: String): return ausruestung.get(platz)
func roh_bonus(affix: String) -> int:
	var n := 0
	for g in ausruestung.values(): n += gesamt(g, affix)
	return n
## 870.6: was alle getragenen Stuecke von [affix] hoechstens geben (werte.json „gegenstaende“ „deckel“: [je Kapitel, plus]), sonst ohne
func deckel(affix: String) -> int:
	var d = lade().get("gegenstaende", {}).get("deckel", {}).get(affix)
	return int(d[0]) * kapitel + int(d[1]) if d != null else 1 << 30
## Zusatzeigenschaft aller getragenen Stuecke, gedeckelt (870.6, sonst wie Rules.gearCap)
func bonus(affix: String) -> int:
	return mini(roh_bonus(affix), deckel(affix))
## 870.6: „Fertigkeit +n“ (SKILL, ab episch) aller getragenen Stuecke fuer [f]
func fertigkeit_bonus(f: String) -> int:
	var n := 0
	for g in ausruestung.values():
		for r in g.get("rolls", []):
			if String(r[0]) == "SKILL" and (r as Array).size() > 2 and String(r[2]) == f: n += int(r[1])
	return n
## 870.6: Zauberschaden und Abwehrprobe der Ausruestung in Prozent
func zauber_prozent() -> int: return bonus("SPELL")
func abwehr_prozent() -> int: return bonus("TENACITY")

func waffe(): return ding("MAIN_HAND")
static func ist_waffe(g) -> bool: return g != null and String(grundform(g["base"])["art"]) == "WEAPON"
func nebenwaffe():
	var n = ding("OFF_HAND")
	return n if ist_waffe(n) else null

## in beiden Haenden: zweihaendig immer, vielseitig, wenn sie die Hauptwaffe ist und die andere Hand leer
func beide_haende_mit(w_) -> bool:
	if w_ == null: return false
	var d := grundform(w_["base"])
	if bool(d["fern"]): return false
	var hw = waffe()
	return bool(d["zweihaendig"]) or (d["vielseitig"] != null and hw != null and int(w_["uid"]) == int(hw["uid"]) and ding("OFF_HAND") == null)

## jeder darf alles tragen (DESIGN-BRS.md 7); was darin nicht geht (Metall und Magie, Schleichen), sagt das Gegenstandsfenster
func kann_tragen(_g: Dictionary) -> bool: return true

## an den eigenen Platz; zurueck kommt, was dafuer herunter musste (Hero.equip)
func anlegen(g: Dictionary) -> Array:
	var weg := []
	var d := grundform(g["base"])
	var platz := String(d["slot"])
	if ausruestung.has(platz): weg.append(ausruestung[platz])
	ausruestung[platz] = g
	if bool(d["zweihaendig"]) and ausruestung.has("OFF_HAND"):
		weg.append(ausruestung["OFF_HAND"]); ausruestung.erase("OFF_HAND")
	var hw = waffe()
	if platz == "OFF_HAND" and hw != null and bool(grundform(hw["base"])["zweihaendig"]):
		weg.append(hw); ausruestung.erase("MAIN_HAND")
	begrenze()
	return weg

## eine einhaendige Waffe in die Nebenhand (Hero.equipOffHand)
func anlegen_nebenhand(g: Dictionary) -> Array:
	var weg := []
	if ausruestung.has("OFF_HAND"): weg.append(ausruestung["OFF_HAND"])
	ausruestung["OFF_HAND"] = g
	var hw = waffe()
	if hw != null and bool(grundform(hw["base"])["zweihaendig"]):
		weg.append(hw); ausruestung.erase("MAIN_HAND")
	begrenze()
	return weg

func ablegen(platz: String):
	var g = ausruestung.get(platz)
	ausruestung.erase(platz)
	begrenze()
	return g

## Startausruestung der Herkunft (welt „start“) anlegen; zurueck, was keine Grundform ist
func ausstatten(neue_uid: Callable = Callable()) -> void:
	for id in welt().get("start", {}).get(herkunft, []):
		if daten().get("grundformen", {}).has(id):
			anlegen({"uid": neue_uid.call() if neue_uid.is_valid() else 0, "base": String(id), "rarity": "COMMON", "ilvl": 1, "guete": 0, "rolls": [], "unique": null})

## Ein Held fuer das Spiel: erschaffen (BrsHeld.neu), benannt, ausgestattet, voll
static func fuer_spiel(name_: String, v := "Mensch", hk := WANDERER, neue_uid: Callable = Callable()) -> BrsHeld:
	var b := BrsHeld.neu(v, hk)
	b.name = name_
	b.ausstatten(neue_uid)
	b.voll()
	return b

# ---------------------------------------------------------------- Kampfblatt (870.2, LISTE-UMZUG-BRS.md Schritt 2)
## Grundform der Gegenstaende -> Waffengruppe des BRS (werte.json „waffen“); unbewaffnet Faustkampf
const WAFFE_GRUPPE := {"": "Faustkampf", "dagger": "Dolche", "shortsword": "Einhänder", "scimitar": "Einhänder", "handaxe": "Einhänder",
	"longsword": "Einhänder", "battleaxe": "Einhänder", "rapier": "Einhänder", "mace": "Stumpfe Waffen", "quarterstaff": "Stumpfe Waffen",
	"warhammer": "Stumpfe Waffen", "morningstar": "Stumpfe Waffen", "wand": "Stumpfe Waffen", "staff": "Stumpfe Waffen",
	"spear": "Stangenwaffen", "halberd": "Stangenwaffen", "greatsword": "Zweihänder", "greataxe": "Zweihänder", "maul": "Zweihänder",
	"shortbow": "Bogen", "longbow": "Bogen", "light_crossbow": "Armbrust"}

## 870.3 (870a 3 A): Kampfhandlungen und Zauber, die [fert] freischaltet (werte.json „handlungen“: Fertigkeit ab „ab“, „alle“
## für jeden; „zauber“: Schule ab „ab“), ohne die schon in [schon]
static func freie_faehigkeiten(fert: Dictionary, schon := []) -> Array:
	var r := []
	var hd: Dictionary = lade().get("handlungen", {})
	for n in ohne_info(hd):
		var d: Dictionary = hd[n]
		var f = d.get("fertigkeit")
		if (f == null and bool(d.get("alle", false))) or (f != null and int(fert.get(String(f), -1)) >= int(d.get("ab", 0))):
			r.append(String(n))
	var zd: Dictionary = lade().get("zauber", {})
	for n in ohne_info(zd):
		var d = zd[n]
		if d is Dictionary and d.has("ab") and int(fert.get(String(d.get("schule", "")), -1)) >= int(d.ab) and not schon.has(n):
			r.append(String(n))
	return r

## was er traegt, fuer kampfblatt(): Grundform der Waffe, Ruestung des BRS, Schild
func getragen() -> Dictionary:
	var w_ = waffe()
	var s = schild()
	return {"waffe": String(w_["base"]) if w_ != null else "", "ruestung": ruestung(), "schild": String(s["base"]) if s != null else "",
		"guete": Beute.guete_von(w_), "ruestung_guete": Beute.guete_von(ding("CHEST")), "schild_guete": Beute.guete_von(s),
		"zusatz": {"schutz": bonus("AC"), "krit": bonus("CRIT"), "zauber": zauber_prozent(), "abwehr": abwehr_prozent()}}

## Alles, was der Kampf vom Helden braucht, nach dem BRS (ersetzt aufruf.gd blatt() aus den Heldwerten). [stufe_]: Heldenstufe;
## [aus]: was er trägt (getragen()): {"waffe": Grundform, "" = unbewaffnet; "ruestung": Rüstung des BRS („keine“,
## „Leichte Rüstung“ …); "schild": Grundform des Schilds, "" = keiner; "guete": Güte der Waffe; "ausdauer": Ausdauer}; fehlt ein
## Feld, gilt die Ausrüstung der Herkunft (werte.json „herkuenfte“). [geuebt_]: Fertigkeiten, wie er sie seither geübt hat (zustand.fert).
func kampfblatt(stufe_ := 1, aus := {}, geuebt_ := {}) -> Dictionary:
	var W_ := lade()
	var hk: Dictionary = W_.get("herkuenfte", {}).get(herkunft, {})
	var fert := fertigkeiten()
	for f in geuebt_:
		fert[String(f)] = int(geuebt_[f])
	for g in ausruestung.values():     # 870.6: „Fertigkeit +n“ der Ausruestung (ab episch)
		for r in g.get("rolls", []):
			if String(r[0]) == "SKILL" and (r as Array).size() > 2: fert[String(r[2])] = int(fert.get(String(r[2]), 0)) + int(r[1])
	var gf: Array = W_.get("gegenstaende", {}).get("guete_faktor", [1.0, 1.0, 1.0])
	var gruppe: String = WAFFE_GRUPPE.get(String(aus["waffe"]), "Einhänder") if aus.has("waffe") else String(hk.get("waffe", "Faustkampf"))
	var wd: Dictionary = W_.get("waffen", {}).get(gruppe, {})
	var ru: Dictionary = W_.get("ruestungen", {})
	var r_art := String(aus.get("ruestung", hk.get("ruestung", "keine")))
	var schild_ := {}
	var s_id: String = String(aus["schild"]) if aus.has("schild") else ("shield" if bool(hk.get("schild", false)) else "")
	if s_id != "":
		schild_ = {"id": s_id, "schutzwert": int(ru.get("schild_wert", 0)), "guete_faktor": float(gf[int(aus.get("schild_guete", 0))])}
	var faehig: Array = []
	if merkmal() != "":
		faehig.append(merkmal())
	for z in hk.get("zauber", []):
		faehig.append(String(z))
	faehig.append_array(freie_faehigkeiten(fert, faehig))
	return {"volk": volk, "herkunft": herkunft, "stufe": stufe_, "werte": werte(), "fert": fert, "leben": max_leben(stufe_), "mana": max_mana(),
		"ausdauer": aus.get("ausdauer", null),     # 467: Ausdauer nach BRS noch offen, bis dahin liefert sie der Spielstand
		"waffe": {"id": String(aus.get("waffe", "")), "gruppe": gruppe, "grundschaden": int(wd.get("schaden", 0)),
			"grundwert": wd.get("grundwert"), "art": String(wd.get("art", "nah")), "guete": int(aus.get("guete", 0)),
			"guete_faktor": float(gf[int(aus.get("guete", 0))])},
		"ruestung": {"art": r_art, "schutzwert": int(ru.get(r_art, {}).get("wert", 0)), "fertigkeit": ru.get(r_art, {}).get("fertigkeit"),
			"guete_faktor": float(gf[int(aus.get("ruestung_guete", 0))])},
		"schild": schild_, "faehigkeiten": faehig,
		"zusatz": (aus.get("zusatz", {}) as Dictionary).duplicate()}     # 870.6: Schutzwert, kritisch, Zauberschaden, Abwehrprobe der Ausruestung

## das Kampfblatt dieses Helden, wie er jetzt ist (Stufe, Ausruestung, Geuebtes)
func mein_kampfblatt() -> Dictionary: return kampfblatt(stufe, getragen(), geuebt)

# ---------------------------------------------------------------- Spielstand
## Erschaffung (zustand.brs): Volk, Herkunft, Verteilung, Wahl, dazu Grundwerte und Startfertigkeiten zum Lesen
func als_daten() -> Dictionary:
	var gw := {}
	for g in grundwerte(): gw[g] = grundwert(g)
	return {"volk": volk, "herkunft": herkunft, "verteilt": verteilt.duplicate(), "mensch_frei": frei_ziel(), "wahl": wahl.duplicate(),
		"grundwerte": gw, "fertigkeiten": fertigkeiten()}

static func aus_daten(d: Dictionary) -> BrsHeld:
	var b := BrsHeld.neu(String(d.get("volk", "Mensch")), String(d.get("herkunft", WANDERER)))
	for g in d.get("verteilt", {}):
		if b.verteilt.has(String(g)): b.verteilt[String(g)] = int(d["verteilt"][g])
	b.mensch_frei = String(d.get("mensch_frei", ""))
	b.wahl = (d.get("wahl", []) as Array).map(func(x): return BrsFertigkeit.neuer_name(String(x)))   # 875: alte Namen
	return b

## Held im Spielstand (870.4; Spielstand Version 2 folgt mit 870.8): Erschaffung und was er jetzt hat
func spiel_daten() -> Dictionary:
	var d := als_daten()
	d.merge({"name": name, "stufe": stufe, "leben": leben, "mana": mana, "kapitel": kapitel, "ausruestung": ausruestung.duplicate(true)}, true)
	return d

## eine Abschrift zum Rechnen (Vergleich), der Held bleibt, wie er ist
func kopie() -> BrsHeld:
	var b := aus_spiel_daten(JSON.parse_string(JSON.stringify(spiel_daten())))
	b.geuebt = geuebt.duplicate()
	return b

static func aus_spiel_daten(d: Dictionary) -> BrsHeld:
	var b := aus_daten(d)
	b.name = String(d.get("name", b.name))
	b.stufe = int(d.get("stufe", 1)); b.kapitel = int(d.get("kapitel", 1))
	for p in d.get("ausruestung", {}): b.ausruestung[String(p)] = d["ausruestung"][p]
	b.leben = int(d.get("leben", b.max_leben())); b.mana = int(d.get("mana", b.max_mana()))
	b.begrenze()
	return b
