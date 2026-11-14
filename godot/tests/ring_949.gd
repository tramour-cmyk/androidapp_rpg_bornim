extends SceneTree
# 949 (Chef 11.11., 13:44; wiederholt 13.11., 14:38, Kampf gegen Grak, Schwerer Hieb: „es gab keinen Angriff, es gab den Ring. Und dann
# habe ich gekontert. Aber ich bin dem Angriff nicht ausgewichen“): bei jedem perfekten Ring muss der Schlag des Gegners als eigene
# Meldung kommen (Gegner → Getroffener, mit Wurf, daneben), bevor die Antwort des Helden („weicht dem Schlag aus und schlägt zurück“,
# „gleitet in den Rücken“, „murmelt ein Gebet“, „Funkenpfeil entgegen“) in der Zeile steht; nur so spielt der Kampfort den Schlag
# (figur.gd strike) und das Ausweichen (kampfort.gd dodge). Ohne Antwort trägt die Schlagmeldung die Zeile selbst.
# Je Probeheld (Kämpfer, Schurke, Kleriker, Magier) gegen Grak (Schwerer Hieb erzwungen) und Riesenspinne (Netz), Ring immer
# perfekt. Anspringen der Wölfe und Krogg haben heute keinen Ring (kommt mit 1068, dann gilt derselbe Weg: _perfect_answer).
# Ohne Bild, nur die Regeln. Aufruf: im Ordner godot mit -s res://tests/ring_949.gd (Exit 0 = jede Antwort hat ihren Schlag davor)

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Aufruf = preload("res://kampf/aufruf.gd")

const KAEMPFE := 6

var fehler := 0
var offen := {}          # Getroffener -> Gegner, dessen Schlag er perfekt beantwortet hat und der noch nicht als Meldung kam
var antworten := 0
var schlaege := 0
var vorher := {}


func _initialize() -> void:
	var tables: Dictionary = Tabellen.lade()
	var monsters := {}
	for m in tables.monsters: monsters[String(m.id)] = m
	var skills := {}
	for s in tables.skills: skills[s.id] = s
	for gruppe in ["GRAK", "SPIDER"]:
		var g0 := schlaege
		for cls in ["FIGHTER", "ROGUE", "CLERIC", "WIZARD"]:
			var a0 := antworten
			var s0 := schlaege
			for k in KAEMPFE:
				var dice := Wuerfel.new(9490 + k)
				var foes: Array = Aufruf.gegner(gruppe, monsters, dice)
				if foes.is_empty():
					print("FEHLER keine Gegner %s" % gruppe); fehler += 1; continue
				var h: Dictionary = tables.probe[cls].hero
				var party := [Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), h.hero.duplicate(true), int(h.hp), h.hero.second, skills)]
				var mars = Mars.new(party, foes, tables, dice, Wuerfel.new(949 + k))
				offen.clear()
				mars.listener = func(e: Dictionary) -> void: _hoere(mars, e)
				var react := func(t, _intent) -> String:
					offen[t.id] = true
					return Mars.PERFECT
				Mars.test_gegnerzug = "heavy" if gruppe == "GRAK" else ""
				mars.start(react)
				var zuege := 0
				while mars.outcome == "ONGOING" and zuege < 60:
					zuege += 1
					var f = mars.current()
					var ziele: Array = mars.targets(f)
					var o: Array = ["attack", ziele[0].id] if not ziele.is_empty() else ["wait"]
					Mars.test_gegnerzug = "heavy" if gruppe == "GRAK" else ""
					mars.act(o, react)
				Mars.test_gegnerzug = ""
			print("%s %s: perfekte Ringe mit Schlag davor %d, Antworten %d" % [gruppe, cls, schlaege - s0, antworten - a0])
			if schlaege == s0 and gruppe == "GRAK":
				print("FEHLER %s %s: kein perfekter Ring gespielt" % [gruppe, cls]); fehler += 1
		if schlaege == g0:
			print("FEHLER %s: kein perfekter Ring gespielt" % gruppe); fehler += 1
	print("RING949 %s" % ("gut" if fehler == 0 else "FALSCH %d" % fehler))
	quit(1 if fehler else 0)


func _hoere(mars, e: Dictionary) -> void:
	var by = mars.find(e.actor) if e.actor != null else null
	var tg = mars.find(e.target) if e.target != null else null
	# der Schlag des Gegners auf den, der perfekt geantwortet hat: mit Wurf, daneben
	if by != null and by.side == "FOES" and tg != null and offen.has(tg.id) and e.roll != null:
		if bool(e.roll[4]):
			print("FEHLER Schlag nach perfektem Ring trifft: %s" % e.text); fehler += 1
		offen.erase(tg.id)
		schlaege += 1
		return
	if bool(e.answer):
		antworten += 1
		if by != null and offen.has(by.id):
			print("FEHLER Antwort ohne Schlag davor: %s" % e.text); fehler += 1
			offen.erase(by.id)
