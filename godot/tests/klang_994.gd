extends SceneTree
# 994 (Chef 11.11., 20:54, t277.18: „hier steht ständig … hand scratch, hand scratch“): ohne Bild und ohne Karte. Der Klang
# (Tierlaute 401) bekommt zwei fressende Huehner: eins zwei Kacheln vom Helden, eins zwanzig Kacheln weit weg (zu weit, um es zu
# hoeren, TIER_WEIT 6). Der Test laesst die Tierlaute 20 s Spielzeit rechnen und zaehlt, was der Klang startet. Ein Tier, das man
# nicht hoert (Pegel 0), darf keinen der acht Effektspieler belegen und nicht in der Klangzeile stehen: sonst schieben fressende
# Huehner im ganzen Dorf jede Sekunde ein „hen_scratch … 0.00“ in die Zeile und brechen echte Klaenge ab (z. B. door_n am Schlagbaum).
# Braucht daten/klang (sfx, liste.json wie im Bau). Aufruf im Ordner godot: headless, -s res://tests/klang_994.gd -> „KLANG994 …“

const TIER := """extends Node3D
var daten := {}
var pause := "Fressen"
var ziel := Vector2i(-1, -1)
var kachel := Vector2i.ZERO
var flucht := false
func nah_am_held(_k) -> bool: return false
"""

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FALSCH ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func huhn(welt: Node3D, x: float) -> Node3D:
	var s := GDScript.new()
	s.source_code = TIER
	s.reload()
	var n := Node3D.new()
	n.set_script(s)
	n.daten = {"tier": "huhn"}
	n.position = Vector3(x * 1.16, 0.0, 0.0)   # Karte.TS
	welt.add_child(n)
	return n

func hoerbar_n(kl) -> int:
	return int(kl.protokoll[-1].get("n", 1)) if not kl.protokoll.is_empty() else 0

func _lauf() -> void:
	for i in 3: await process_frame
	var kl = root.get_node_or_null("Klang")
	pruefe(kl != null, "Klang geladen")
	if kl == null: quit(1); return
	pruefe(kl.liste.get("sfx", []).any(func(n): return String(n).begins_with("hen_scratch_")), "Aufnahmen hen_scratch da")
	var welt := Node3D.new()
	root.add_child(welt)
	var held := Node3D.new()
	welt.add_child(held)
	kl._held = held
	var nah := huhn(welt, 2.0)
	var weit := huhn(welt, 20.0)
	kl._tiere_suche = 0.0
	kl.protokoll.clear()
	var i0: int = kl._naechster
	var starts := 0
	for schritt in 200:   # 20 s in Schritten von 100 ms wie _ortsklang
		kl._tierlaute(100.0)
		while i0 != kl._naechster:
			starts += 1
			i0 = (i0 + 1) % kl._effekte.size()
	var still: Array = kl.protokoll.filter(func(e): return float(e.pegel) <= 0.0)
	print("Effektspieler gestartet in 20 s: %d (Huhn nah 2 Kacheln, Huhn weit 20 Kacheln, beide fressen)" % starts)
	for z in kl.protokoll_zeilen(): print("  " + z)
	pruefe(still.is_empty(), "kein stummer Klang in der Klangzeile (%d mit Pegel 0)" % still.size())
	pruefe(hoerbar_n(kl) >= 10, "das nahe Huhn scharrt hoerbar (%d mal)" % hoerbar_n(kl))
	pruefe(kl.protokoll.size() == 1 and int(kl.protokoll[0].get("n", 1)) == hoerbar_n(kl), "das Scharren steht als eine Zeile mit ×n (%d Zeilen)" % kl.protokoll.size())
	pruefe(starts <= 30, "hoechstens 30 Starts in 20 s, nur das nahe Huhn (%d)" % starts)
	nah.queue_free(); weit.queue_free()
	print("KLANG994 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
