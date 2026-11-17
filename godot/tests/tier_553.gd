extends SceneTree
# 553 (Chef 04.11., 00:26, Build 249: „Was ist das für ein graues Tier??????“ im Flüsterwald): Figuren der Karte wie streuner.gd
# _ready (kaempfer, dann setup mit Stub); erst eine Riesenratte, dann ein Wolf, dann ein Goblin, dann ein Kampfbeginn mit Ratten.
# Jede Figur muss danach noch ihr eigenes Tier und ihren Maßstab vom Aufbau haben (Figur.ersatz_art gilt für alle und wechselt).
# Prüfung ohne Grafik; braucht kampf/daten wie im Bau. Aufruf: im Ordner godot mit -s res://tests/tier_553.gd (Exit 0 = richtig)

const AufrufS = preload("res://kampf/aufruf.gd")
const Figur = preload("res://kampf/figur.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")

func _initialize() -> void:
	_lauf.call_deferred()

func _figur(art: String, helfer):
	var f = Streuner.kaempfer(art, 1)
	if f == null:
		return null
	var fig = Figur.new()
	fig.fighter = f
	fig.kampfort = Streuner.Stub.new(helfer)
	root.add_child(fig)
	fig.setup(f, fig.kampfort)
	return fig

func _lauf() -> void:
	var helfer = load("res://kampf/kampfort.gd").new()
	var fehler := 0
	var figuren := []
	var vorher := {}
	for art in ["giant_rat", "wolf", "goblin"]:
		var fig = _figur(art, helfer)
		if fig == null:
			print("FEHLER keine Figur für ", art)
			fehler += 1
			continue
		figuren.append([art, fig])
		vorher[art] = [fig.art(), fig._scale()]
		print("%s aufgebaut: Art „%s“, Maßstab %.3f" % [art, fig.art(), fig._scale()])
	# ein Kampfbeginn setzt die Art noch einmal (aufruf.gd gegner)
	var tab: Dictionary = Tabellen.lade()
	var monsters := {}
	for m in tab.monsters: monsters[m.id] = m
	AufrufS.gegner("RATS", monsters, Wuerfel.new(null))
	for e in figuren:
		var fig = e[1]
		var jetzt := [fig.art(), fig._scale()]
		var gut: bool = jetzt[0] == vorher[e[0]][0] and absf(float(jetzt[1]) - float(vorher[e[0]][1])) < 0.0001
		print("%s %s danach: Art „%s“, Maßstab %.3f" % ["ok    " if gut else "FEHLER", e[0], jetzt[0], jetzt[1]])
		if not gut:
			fehler += 1
	print("TIER_553 %d Fehler" % fehler)
	quit(1 if fehler else 0)
