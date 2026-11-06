class_name Auftraege
extends RefCounted
# 399.1 Anschlagbrett vor der Schenke wie alt (Jobs.kt, 29): jeder Aushang frei zu nehmen oder zu lassen (33); angenommen steht er
# in der Chronik mit dem Stand, aufgeben legt ihn zurueck ans Brett; abgegeben wird beim Auftraggeber. Alles in Flaggen wie alt:
# „job_<id>“ angenommen, „job_<id>_done“ erledigt, „job_<id>_seen“ am Brett gelesen. Aushaenge mit „nach“ haengen erst, wenn die
# Flagge gesetzt ist (Wellen, 29g). Texte wortgleich aus core (TextExport „auftraege“).
# 542: Gwennas Ring in der Truhe der Hoehle (Jobs.ringIn) und der Fetzen am Steinkreis (Jobs.findAt) wie alt.

const HELD := {"de": "{name}", "en": "{name}"}   # Jobs.HERO
const RING := "gwenna_ring"                      # Jobs.RING, liegt in der Truhe RING_CHEST
const RING_CHEST := "cave_3"
const RAG := "grey_rag"                          # Jobs.RAG, am Steinkreis der Karte RAG_MAP
const RAG_MAP := "forest"
const MENHIR := "I"                              # Tile.MENHIR
const RING_FUND := {"de": "Unter Lumpen und Knochen am Boden der Truhe: ein schmaler Ring aus angelaufenem Silber.", "en": "Under rags and bones at the bottom of the chest: a slim ring of tarnished silver."}
const RAG_FUND := {"de": "Zwischen den Steinen: kalte Asche, Stiefelspuren, die nach Norden führen. Am Fuß eines Steins hängt ein Fetzen grauen Tuchs, ein offenes Auge ist hineingestickt.",
	"en": "Between the stones: cold ashes, boot prints leading north. At the foot of a stone hangs a scrap of gray cloth, an open eye stitched into it."}

static func alle() -> Array: return Sprache.texte.get("auftraege", [])

static func von(id: String) -> Dictionary:
	for j in alle():
		if String(j["id"]) == id: return j
	return {}

static func angenommen(z: Zustand, j: Dictionary) -> bool: return z.has("job_" + String(j["id"])) and not erledigt(z, j)
static func erledigt(z: Zustand, j: Dictionary) -> bool: return z.has("job_%s_done" % j["id"])
static func haengt(z: Zustand, j: Dictionary) -> bool: return not j.has("nach") or z.has(String(j["nach"]))

static func am_brett(z: Zustand) -> Array: return alle().filter(func(j): return haengt(z, j) and not erledigt(z, j))
static func frisch(z: Zustand) -> bool: return am_brett(z).any(func(j): return not z.has("job_%s_seen" % j["id"]))
static func lies(z: Zustand) -> void:
	for j in am_brett(z): z.setze("job_%s_seen" % j["id"])
static func getragen(z: Zustand) -> Array: return alle().filter(func(j): return angenommen(z, j))
static func stand(z: Zustand, j: Dictionary) -> int: return mini(z.anzahl(String(j["ding"])), int(j["anzahl"]))

static func nimm(z: Zustand, j: Dictionary) -> void:
	if not erledigt(z, j): z.setze("job_" + String(j["id"]))

# Jobs.ringIn: liegt Gwennas Ring in [kiste]? Ihr Auftrag angenommen, der Ring weder in der Tasche noch abgegeben (auch in einer
# Truhe, die schon leer war)
static func ring_in(z: Zustand, kiste: String) -> bool:
	return kiste == RING_CHEST and angenommen(z, von("ring")) and z.anzahl(RING) == 0

# Jobs.findAt: was der Held am Stein [zeichen] auf [karte] findet, solange Jorins Auftrag angenommen ist; [] = nichts
static func fund_bei(z: Zustand, karte: String, zeichen: String) -> Array:
	if karte != RAG_MAP or zeichen != MENHIR or not angenommen(z, von("stones")) or z.anzahl(RAG) > 0: return []
	return [{"art": "sagen", "text": RAG_FUND}, {"art": "geben", "ding": RAG, "anzahl": 1}]

# Jobs.handIn: was der Auftraggeber sagt, wenn der Held bringt, was ein angenommener Aushang will; [] = wie immer reden
static func abgabe(z: Zustand, wer: String) -> Array:
	for j in alle():
		if String(j["geber"]) == wer and angenommen(z, j) and z.anzahl(String(j["ding"])) >= int(j["anzahl"]):
			var c := [{"art": "sagen", "wer": HELD, "text": j["bringen"]}, {"art": "sagen", "wer": j["geber_name"], "text": j["dank"]},
				{"art": "nehmen", "ding": String(j["ding"]), "anzahl": int(j["anzahl"])}, {"art": "flagge", "flagge": "job_%s_done" % j["id"]}]
			if int(j["gold"]) > 0: c.append({"art": "gold", "anzahl": int(j["gold"])})
			for g in j["gaben"]: c.append({"art": "geben", "ding": String(g["ding"]), "anzahl": int(g["anzahl"])})
			return c
	return []
