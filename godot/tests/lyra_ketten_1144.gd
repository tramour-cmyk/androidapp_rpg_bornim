extends SceneTree
# 1144 (Chef 13.11., 14:49, Lyra in Graks Halle): zur Zeile „Die Ketten fallen klirrend zu Boden“ der Klang der Ketten und Lyra frei
# (Handgelenke reiben, Arme sinken), danach spricht sie, erst nach dem Gespräch geht sie. Ohne Fenster und ohne Kaufmodelle:
# Befehlsfolge der Szene, Zeitplan der Regung (Haltung.frei_phase), Klangdateien chains_1–3. Aufruf im Ordner godot:
# --headless -s res://tests/lyra_ketten_1144.gd -> „LYRAKETTEN1144 n Fehler“

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var z := Zustand.new()
	z.setze(Geschichte.GRAK_DEFEATED)
	z.dazu("grak_key")
	var b: Array = Geschichte.gespraech("lyra_cave", z)
	var ie := b.find_custom(func(c): return String(c["art"]) == "ereignis" and String(c.get("was", "")) == "ketten")
	var ik := b.find_custom(func(c): return String(c["art"]) == "sagen" and String(c["text"]["de"]).contains("Ketten fallen"))
	var isag := b.find_custom(func(c): return String(c["art"]) == "sagen" and c.has("wer"))
	var ifl := b.find_custom(func(c): return String(c["art"]) == "flagge" and String(c["flagge"]) == Geschichte.LYRA_RESCUED)
	pruefe(ie >= 0 and ik == ie + 1, "Ereignis Ketten unmittelbar vor der Zeile der Ketten (%d, %d)" % [ie, ik])
	pruefe(isag > ik and ifl > isag and ifl == b.size() - 1, "erst die Zeile, dann spricht Lyra, frei zum Gehen erst am Ende (%d, %d, %d)" % [ik, isag, ifl])
	# Zeitplan: rechte Hand reibt, dann linke, dann sinken die Arme, dann ohne Damenstand
	var H = HeldFigur.Haltung
	pruefe(H.frei_phase(0.3) == Vector2(0, 1), "0,3 s: rechte Hand reibt, Damenstand voll")
	pruefe(H.frei_phase(H.REIB_S * 0.75) == Vector2(1, 1), "%.1f s: linke Hand reibt" % (H.REIB_S * 0.75))
	var s := H.frei_phase(H.REIB_S + H.SINK_S * 0.5)
	pruefe(s.x < 0.0 and s.y > 0.0 and s.y < 1.0, "beim Sinken kein Reiben, Damenstand halb (%.2f)" % s.y)
	pruefe(H.frei_phase(H.REIB_S + H.SINK_S + 0.1).y <= 0.0, "danach frei")
	var h = H.new()
	h.befreie()
	pruefe(h.frei_seit < 0, "ohne Damenstand ändert befreie nichts")
	h.dame = true
	h.befreie()
	pruefe(h.frei_seit >= 0, "mit Damenstand beginnt die Regung")
	h.free()
	for i in [1, 2, 3]:
		var p := "res://daten/klang/sfx/chains_%d.ogg" % i
		pruefe(ResourceLoader.exists(p) and load(p) is AudioStream, "Klang %s" % p.get_file())
	print("LYRAKETTEN1144 %d Fehler" % fehler)
	quit(1 if fehler else 0)
