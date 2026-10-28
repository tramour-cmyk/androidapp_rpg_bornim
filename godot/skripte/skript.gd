class_name Skript
extends RefCounted
# 390: Befehle einer Szene wie Cmd in Script.kt, als Woerterbuch {art, …}; Text als {de, en}, "{name}" ersetzt spiel.gd.

var befehle: Array = []

func say(wer: Dictionary, de: String, en: String) -> void: befehle.append({"art": "sagen", "wer": wer, "text": {"de": de, "en": en}})
func say_t(wer: Dictionary, text: Dictionary) -> void: befehle.append({"art": "sagen", "wer": wer, "text": text})
func narrate(de: String, en: String) -> void: befehle.append({"art": "sagen", "text": {"de": de, "en": en}})
func flag(f: String) -> void: befehle.append({"art": "flagge", "flagge": f})
func give(ding: String, anzahl: int = 1) -> void: befehle.append({"art": "geben", "ding": ding, "anzahl": anzahl})
func take(ding: String, anzahl: int = 1) -> void: befehle.append({"art": "nehmen", "ding": ding, "anzahl": anzahl})
func gold(n: int) -> void: befehle.append({"art": "gold", "anzahl": n})
# Kampf: der Rest der Szene nur nach einem Sieg; sieg_flagge wird dann gesetzt (Cmd.Fight)
func fight(monster: String, sieg_flagge: String = "") -> void: befehle.append({"art": "kampf", "monster": monster, "flagge": sieg_flagge})
func shop(waren: Array, brauen: bool = false) -> void: befehle.append({"art": "laden", "waren": waren, "brauen": brauen})
func rest() -> void: befehle.append({"art": "rast"})
func heal() -> void: befehle.append({"art": "heilen"})
func chapter_end() -> void: befehle.append({"art": "kapitelende"})
func temple_scene() -> void: befehle.append({"art": "tempelszene"})
func morning(ort: Dictionary) -> void: befehle.append({"art": "morgen", "ort": ort})
func tavern() -> void: befehle.append({"art": "schenke"})
