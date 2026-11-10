class_name BrsHeld
extends RefCounted
# 470 (Abnahme 1.1): Erschaffung nach dem BRS (Nachschlagewerk Abschnitt 2, E 68-72, 77, 78). Jeder Grundwert beginnt bei 1, der
# Spieler verteilt 21 Punkte, danach liegt jeder zwischen 3 und 8; das Volk gibt +1/+1/-1 (Mensch +1 frei) und darf bis 9 heben,
# nie unter 3 senken; die Herkunft verteilt vor (aenderbar) und gibt ihre Startfertigkeiten, der Wanderer verteilt selbst und waehlt
# zwei, der Mensch waehlt eine mehr (Wandelbar); jede Startfertigkeit beginnt beim Startwert (10).
# Einzige Quelle der Zahlen: daten/werte.json = tools/sim444/werte.json (Bloecke „held“, „herkuenfte“, „erschaffung“), dieselbe Datei wie
# die Simulation 444 und regeln/brs.gd (Jerry). Gegenprobe: tests/brs_470.gd.
# Bruecke bis 2.3 (Rueckfrage 470a): alt() uebersetzt in Klasse und SRD-Werte fuer den Kampf, der bis dahin nach dem SRD rechnet.

const DATEI := "res://daten/werte.json"
const WANDERER := "Wanderer"
# Volk im BRS -> Kennung des alten Helden (Heldwerte, Appearance.kt, HeldFigur)
const VOLK_ALT := {"Mensch": "HUMAN", "Elf": "ELF", "Zwerg": "DWARF", "Hügelvolk": "HALFLING", "Orkblütiger": "HALF_ORC"}

static var W := {}

var volk := "Mensch"
var herkunft := WANDERER
var verteilt := {}                 # Grundwert -> Wert vor dem Volk (3 bis 8)
var mensch_frei := ""              # Mensch: Grundwert mit dem freien +1
var wahl: Array = []               # selbst gewaehlte Startfertigkeiten (Wanderer zwei, Mensch eine mehr)

static func lade() -> Dictionary:
	if W.is_empty():
		var j = JSON.parse_string(FileAccess.get_file_as_string(DATEI)) if FileAccess.file_exists(DATEI) else null
		if j is Dictionary: W = j
		else: push_error("470: %s fehlt oder ist kaputt" % DATEI)
	return W

static func e() -> Dictionary: return lade().get("erschaffung", {})
static func h() -> Dictionary: return lade().get("held", {})
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

## Endwert: verteilt plus Volk, das Volk hebt hoechstens bis volk_max und senkt nie unter volk_min
func wert(g: String) -> int:
	var v := int(verteilt[g])
	var p := volk_plus(g)
	if p > 0: return mini(v + p, maxi(v, int(e().get("volk_max", 9))))
	if p < 0: return maxi(v + p, mini(v, int(e().get("volk_min", 3))))
	return v

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

func fertigkeiten() -> Dictionary:
	var r := {}
	for f in herkunft_fertigkeiten() + wahl: r[String(f)] = int(h().get("startfertigkeit", 10))
	return r

func fertig() -> bool: return frei() == 0 and wahl.size() == wahl_anzahl()

# ---------------------------------------------------------------- Abgeleitet (N 2: Leben aus Zaehigkeit und Stufe, Mana aus Wille)
func leben(stufe := 1) -> int:
	return int(h()["leben_basis"]) + int(h()["leben_je_stufe"]) * stufe + int(h()["leben_je_zaehigkeit"]) * wert("zaehigkeit")
func mana() -> int: return int(h()["mana_basis"]) + int(h()["mana_je_wille"]) * wert("wille")

# ---------------------------------------------------------------- Kampfblatt (870.2, LISTE-UMZUG-BRS.md Schritt 2)
## Grundform der Heldwerte -> Waffengruppe des BRS (werte.json „waffen“); unbewaffnet Faustkampf
const WAFFE_GRUPPE := {"": "Faustkampf", "dagger": "Dolche", "shortsword": "Einhänder", "scimitar": "Einhänder", "handaxe": "Einhänder",
	"longsword": "Einhänder", "battleaxe": "Einhänder", "rapier": "Einhänder", "mace": "Stumpfe Waffen", "quarterstaff": "Stumpfe Waffen",
	"warhammer": "Stumpfe Waffen", "morningstar": "Stumpfe Waffen", "wand": "Stumpfe Waffen", "staff": "Stumpfe Waffen",
	"spear": "Stangenwaffen", "halberd": "Stangenwaffen", "greatsword": "Zweihänder", "greataxe": "Zweihänder", "maul": "Zweihänder",
	"shortbow": "Bogen", "longbow": "Bogen", "light_crossbow": "Armbrust"}

## Alles, was der Kampf vom Helden braucht, nach dem BRS (ersetzt aufruf.gd blatt() aus den Heldwerten). [stufe]: Heldenstufe;
## [aus]: was er trägt, aus dem Spielstand (Tom): {"waffe": Grundform, "" = unbewaffnet; "ruestung": Rüstung des BRS („keine“,
## „Leichte Rüstung“ …); "schild": Grundform des Schilds, "" = keiner; "guete": Güte der Waffe; "ausdauer": Ausdauer}; fehlt ein
## Feld, gilt die Ausrüstung der Herkunft (werte.json „herkuenfte“). [geuebt]: Fertigkeiten, wie er sie seither geübt hat (zustand.fert).
func kampfblatt(stufe := 1, aus := {}, geuebt := {}) -> Dictionary:
	var W := lade()
	var hk: Dictionary = W.get("herkuenfte", {}).get(herkunft, {})
	var fert := fertigkeiten()
	for f in geuebt:
		fert[String(f)] = int(geuebt[f])
	var gruppe: String = WAFFE_GRUPPE.get(String(aus["waffe"]), "Einhänder") if aus.has("waffe") else String(hk.get("waffe", "Faustkampf"))
	var wd: Dictionary = W.get("waffen", {}).get(gruppe, {})
	var ru: Dictionary = W.get("ruestungen", {})
	var r_art := String(aus.get("ruestung", hk.get("ruestung", "keine")))
	var schild := {}
	var s_id: String = String(aus["schild"]) if aus.has("schild") else ("shield" if bool(hk.get("schild", false)) else "")
	if s_id != "":
		schild = {"id": s_id, "schutzwert": int(ru.get("schild_wert", 0))}
	var faehig: Array = []
	if merkmal() != "":
		faehig.append(merkmal())
	for z in hk.get("zauber", []):
		faehig.append(String(z))
	return {"volk": volk, "herkunft": herkunft, "stufe": stufe, "werte": werte(), "fert": fert, "leben": leben(stufe), "mana": mana(),
		"ausdauer": aus.get("ausdauer", null),     # 467: Ausdauer nach BRS noch offen, bis dahin liefert sie der Spielstand
		"waffe": {"id": String(aus.get("waffe", "")), "gruppe": gruppe, "grundschaden": int(wd.get("schaden", 0)),
			"grundwert": wd.get("grundwert"), "art": String(wd.get("art", "nah")), "guete": int(aus.get("guete", 0))},
		"ruestung": {"art": r_art, "schutzwert": int(ru.get(r_art, {}).get("wert", 0)), "fertigkeit": ru.get(r_art, {}).get("fertigkeit")},
		"schild": schild, "faehigkeiten": faehig}

func als_daten() -> Dictionary:
	return {"volk": volk, "herkunft": herkunft, "verteilt": verteilt.duplicate(), "mensch_frei": frei_ziel(), "wahl": wahl.duplicate(),
		"grundwerte": werte(), "fertigkeiten": fertigkeiten()}

static func aus_daten(d: Dictionary) -> BrsHeld:
	var b := BrsHeld.neu(String(d.get("volk", "Mensch")), String(d.get("herkunft", WANDERER)))
	for g in d.get("verteilt", {}):
		if b.verteilt.has(String(g)): b.verteilt[String(g)] = int(d["verteilt"][g])
	b.mensch_frei = String(d.get("mensch_frei", ""))
	b.wahl = (d.get("wahl", []) as Array).map(func(x): return String(x))
	return b

# ---------------------------------------------------------------- Bruecke bis 2.3 (470a, Votum A)
# Klasse des alten Kampfs aus der Herkunft, SRD-Werte aus den Grundwerten (3 -> 8, 8 -> 15, 9 -> 16); der Zauberwert der Klasse
# (Magier Intelligenz, Kleriker Weisheit) aus dem Willen
const KLASSE_ALT := {"Wachsoldat": "FIGHTER", "Schmiedelehrling": "FIGHTER", "Wanderer": "FIGHTER", "Zauberlehrling": "WIZARD",
	"Klosterschüler": "CLERIC", "Jägerkind": "ROGUE", "Kräutersammler": "ROGUE", "Herumtreiber": "ROGUE"}
const ATTR_ALT := {"kraft": "STR", "gewandtheit": "DEX", "zaehigkeit": "CON", "verstand": "INT", "wahrnehmung": "WIS", "wille": "CHA"}

static func srd_wert(w: int) -> int: return roundi(8.0 + (w - 3) * 7.0 / 5.0) if w >= 3 else 8   # nie ein halber Wert (3..9)

func alt() -> Dictionary:
	var k: String = KLASSE_ALT.get(herkunft, "FIGHTER")
	var s := {}
	for g in grundwerte(): s[ATTR_ALT[g]] = srd_wert(wert(g))
	if k == "WIZARD": s["INT"] = srd_wert(maxi(wert("wille"), wert("verstand")))
	if k == "CLERIC": s["WIS"] = srd_wert(maxi(wert("wille"), wert("wahrnehmung")))
	return {"volk": VOLK_ALT.get(volk, "HUMAN"), "klasse": k, "srd": s}
