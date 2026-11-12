class_name Skript
extends RefCounted
# 390: Befehle einer Szene wie Cmd in Script.kt, als Woerterbuch {art, …}; Text als {de, en}, "{name}" ersetzt spiel.gd.

var befehle: Array = []

func say(wer: Dictionary, de: String, en: String) -> void: befehle.append({"art": "sagen", "wer": wer, "text": {"de": de, "en": en}})
func say_t(wer: Dictionary, text: Dictionary) -> void: befehle.append({"art": "sagen", "wer": wer, "text": text})
func narrate(de: String, en: String) -> void: befehle.append({"art": "sagen", "text": {"de": de, "en": en}})

# 504.1 (Chef 03.11., 07:52: „Mindestens 3 … Lebendige Welt“; Regeln STORY-VARIANTEN-K1.md): eine Marke mit mehreren Wortlauten.
# erste = Wortlaut 1 (bisher) als Sprechblasen [[de, en], …], die weiteren aus Varianten.V. Beim ersten Hoeren Wortlaut 1, danach
# Zufall unter allen, nie derselbe zweimal hintereinander; „w“ (nur Wiederholung): danach nur W1–W3. Die Wahl haengt nur am
# Spielstand (Zustand.varianten: Marke -> [wie oft gehoert, letzte Wahl]), gezaehlt erst, wenn das Gespraech laeuft (Befehl
# „variante“, spiel.gd); so aendert ein Blick auf das Gespraech (Ruf.neu) nichts. wer leer: Erzaehler
# 842: [weitere] statt Varianten.V fuer Marken ausserhalb der STORY-VARIANTEN-Dateien (807, STORY-K1-FERTIGKEITEN.md); eine Blase
# [de, en, true] ist erzaehlt („· Erzähler:“), ohne Sprecher
func variante(s: Zustand, marke: String, wer: Dictionary, erste: Array, weitere: Array = []) -> void:
	var alle: Array = [erste] + (weitere if not weitere.is_empty() else Array((Varianten.V.get(marke, {}) as Dictionary).get("v", [])))
	var i := Skript.wahl(s, marke, alle.size())
	for b in alle[i]:
		var c := {"art": "sagen", "text": {"de": String(b[0]), "en": String(b[1])}, "marke": marke}
		if not wer.is_empty() and not (b.size() > 2 and bool(b[2])): c["wer"] = wer
		befehle.append(c)
	befehle.append({"art": "variante", "marke": marke, "wahl": i})

static func wahl(s: Zustand, marke: String, anzahl: int) -> int:
	var v: Array = s.varianten.get(marke, [0, -1]) if s else [0, -1]
	var n := int(v[0])
	if n == 0 or anzahl < 2: return 0
	var nur_w := bool((Varianten.V.get(marke, {}) as Dictionary).get("w", false))
	var frei: Array = []
	for i in range(1 if nur_w else 0, anzahl):
		if i != int(v[1]) or anzahl - (1 if nur_w else 0) < 2: frei.append(i)
	var z := RandomNumberGenerator.new()
	z.seed = hash("%s|%d" % [marke, n])
	return int(frei[z.randi_range(0, frei.size() - 1)])
func flag(f: String) -> void: befehle.append({"art": "flagge", "flagge": f})
func give(ding: String, anzahl: int = 1) -> void: befehle.append({"art": "geben", "ding": ding, "anzahl": anzahl})
func take(ding: String, anzahl: int = 1) -> void: befehle.append({"art": "nehmen", "ding": ding, "anzahl": anzahl})
func gold(n: int) -> void: befehle.append({"art": "gold", "anzahl": n})
func zahlen(n: int) -> void: befehle.append({"art": "zahlen", "anzahl": n})   # 1086: Gold weg, ohne Zeile
# Kampf: der Rest der Szene nur nach einem Sieg; sieg_flagge wird dann gesetzt (Cmd.Fight)
func fight(monster: String, sieg_flagge: String = "") -> void: befehle.append({"art": "kampf", "monster": monster, "flagge": sieg_flagge})
func shop(waren: Array, brauen: bool = false) -> void: befehle.append({"art": "laden", "waren": waren, "brauen": brauen})
func rest() -> void: befehle.append({"art": "rast"})
func heal() -> void: befehle.append({"art": "heilen"})
func chapter_end() -> void: befehle.append({"art": "kapitelende"})
func temple_scene() -> void: befehle.append({"art": "tempelszene"})
func morning(ort: Dictionary) -> void: befehle.append({"art": "morgen", "ort": ort})
func tavern() -> void: befehle.append({"art": "schenke"})
# 842 (807 A, 807a A): ein Knopf im Gespraech ({de, en}) unter der letzten Zeile davor; angetippt laufen [dann] (Befehle), wer
# weitertippt, laesst ihn aus. probe: der Knopf nennt die Fertigkeit; spiel.gd wuerfelt die Chance (Geschichte.probe_chance), uebt
# [fert] und spielt [ja] oder [nein]; [gegen]: wessen Gegenwert zaehlt (werte.json „proben“)
func knopf(text: Dictionary, dann: Array) -> void: befehle.append({"art": "knopf", "knopf": text, "dann": dann})
func probe(fert: String, gegen: String, text: Dictionary, ja: Array, nein: Array) -> void:
	befehle.append({"art": "knopf", "knopf": text, "probe": {"fert": fert, "gegen": gegen, "ja": ja, "nein": nein}})
func shop_nur(waren: Array) -> void: befehle.append({"art": "laden", "waren": waren, "brauen": false, "nur_vorraete": true})   # 842 Osric
