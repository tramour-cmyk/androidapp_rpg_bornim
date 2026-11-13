# 1068 (1048 A, H, D, Chef 12.11., 20:05): Rechnung vor dem Bau. Ohne Bild, nur die Regeln (mars.gd), aufgestellt wie
# anspringen_702.gd (Held Stufe 1 je Herkunft, 2 Heiltränke, ohne Söldner). Gegen Rudel, Grimmzahn mit Leibwache, Grak, Spinne
# und Krogg je N Kämpfe: „heute“ (Ring wie heute, Automatik fängt ihn gut) und „A+H“ (Ring auch bei Anspringen und Gift sammeln,
# diese Schläge doppelt so hart, so dass gut = heute) mit drei Spielern: Automatik (gut), verfehlt (nie getippt), perfekt.
# Gezählt: Siege, Ringe je Kampf, Runden je Kampf, Leben verloren je Kampf (Anteil am vollen Leben), Ringe je Runde (× 1,5 s
# ergibt die Verlängerung der Runde). Krogg hat noch keinen Prankenhieb (nur „Stich“), darum heute wie A+H ohne Ring.
# H wird hier nachgebildet: trifft ein neuer Ringschlag, zieht der Zuhörer denselben Schaden noch einmal ab (ohne die
# Sonderregeln Unerbittlich und Unsterblich, die Rechnung ist darum für A+H leicht zu streng).
# Run: godot --headless --path godot -s res://tests/ring_1068.gd   (Tabelle, Exit 0; braucht daten/held.json; N=… in der Umgebung)
extends SceneTree

const Aufruf = preload("res://kampf/aufruf.gd")
const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const NEU := ["pounce", "venom"]


func _initialize() -> void:
	if not FileAccess.file_exists("res://daten/held.json"):
		print("Heldwerte fehlen: keine Messung")
		quit(0)
		return
	var n_k := int(OS.get_environment("N")) if OS.get_environment("N") != "" else 200
	var tab: Dictionary = Tabellen.lade()
	var skills := {}
	for s in tab.skills:
		skills[s.id] = s
	var monsters := {}
	for m in tab.monsters:
		monsters[m.id] = m
	var a = Aufruf.new()
	var nur := OS.get_environment("NUR")
	print("RING1068 N=%d" % n_k)
	if OS.get_environment("TEIL") == "D":
		_teil_d(a, tab, skills, monsters, n_k, nur)
		a.free()
		quit(0)
		return
	print("Regel  Spieler    Herkunft        Gegner  Siege  Ringe/Kampf  Runden  Ringe/Runde  Leben verloren")
	for gegner in ["RUDEL", "GRIMM", "GRAK", "SPIDER", "KROGG"]:
		for k in ["Wachsoldat", "Zauberlehrling", "Herumtreiber", "Klosterschüler"]:
			if nur != "" and not (k + gegner).contains(nur):
				continue
			for v in [["heute", Mars.GOOD], ["A+H", Mars.GOOD], ["A+H", Mars.NONE], ["A+H", Mars.PERFECT]]:
				var z := _messe(a, tab, skills, monsters, String(v[0]) == "A+H", String(v[1]), k, gegner, n_k)
				print("%-6s %-10s %-15s %-7s %4d%%  %8.1f  %8.1f  %8.2f  %10.0f%%" % [v[0],
					{"GOOD": "Automatik", "NONE": "verfehlt", "PERFECT": "perfekt"}[v[1]], k, gegner, z.siege * 100 / n_k,
					float(z.ringe) / n_k, float(z.runden) / n_k, float(z.ringe) / maxi(1, z.runden), 100.0 * z.verlust / n_k])
	a.free()
	quit(0)


## D (1048 D): Ring beim eigenen Angriff, nur perfekt zählt: Schaden × f. Abwehr wie A+H mit Automatik; der Spieler trifft den
## eigenen Ring mit Anteil p perfekt (Zufall je Treffer). Nachgebildet wie H: trifft der Held, zieht der Zuhörer (f − 1) × Schaden
## ab, tötet dabei aber nie (bleibt bei 1 Leben; die Rechnung ist für D darum leicht zu vorsichtig).
func _teil_d(a, tab: Dictionary, skills: Dictionary, monsters: Dictionary, n_k: int, nur: String) -> void:
	print("D: Herkunft        Gegner  p     f     Siege  Runden  Leben verloren")
	for gegner in ["RUDEL", "GRIMM", "GRAK", "SPIDER"]:
		for k in ["Wachsoldat", "Zauberlehrling", "Herumtreiber", "Klosterschüler"]:
			if nur != "" and not (k + gegner).contains(nur):
				continue
			for pf in [[0.0, 1.0], [0.5, 1.25], [0.5, 1.5], [0.5, 2.0], [1.0, 1.25], [1.0, 1.5], [1.0, 2.0]]:
				var z := _messe(a, tab, skills, monsters, true, Mars.GOOD, k, gegner, n_k, pf[0], pf[1])
				print("D: %-15s %-7s %.1f  %.2f  %4d%%  %6.1f  %10.0f%%" % [k, gegner, pf[0], pf[1], z.siege * 100 / n_k,
					float(z.runden) / n_k, 100.0 * z.verlust / n_k])


func _messe(a, tab: Dictionary, skills: Dictionary, monsters: Dictionary, neu: bool, spieler: String, k: String, gegner: String, n_k: int, p_eigen := 0.0, f_eigen := 1.0) -> Dictionary:
	var z := {"siege": 0, "ringe": 0, "runden": 0, "verlust": 0.0}
	for s in n_k:
		var foes: Array = Aufruf.rudel(monsters, Wuerfel.new(s * 7 + 1)) if gegner == "RUDEL" else Aufruf.gegner(gegner, monsters, Wuerfel.new(s * 7 + 1))
		var hero = a._kaempfer("hero", BrsHeld.fuer_spiel("Alrik", "Mensch", k), -1, Vector2i(Mars.FRONT, 0), skills)
		var mars = Mars.new([hero], foes, tab, Wuerfel.new(s * 7 + 2), Wuerfel.new(s * 7 + 281), 0, false)
		mars.potions["potion"] = 2
		if neu:
			for x in [mars.I_POUNCE, mars.I_VENOM]:
				x.ring = true
		var offen := [""]     # ein neuer Ringschlag, der noch nicht getroffen hat
		var max_hp: int = hero.max_hp
		var verlust := [0]
		var los := Wuerfel.new(s * 7 + 5)
		mars.listener = func(e):
			if e.actor == "hero" and e.target != null and e.target != "hero" and int(e.damage) > 0 and p_eigen > 0.0 and los.chance(p_eigen):
				var g = mars.find(String(e.target))
				if g != null and g.hp > 0:
					g.hp = maxi(1, g.hp - roundi(int(e.damage) * (f_eigen - 1.0)))
			if e.target == "hero" and int(e.damage) > 0 and e.actor != null and e.actor != "hero":
				var extra := 0
				if offen[0] != "" and spieler != Mars.PERFECT:
					extra = mini(int(e.damage), hero.hp)
					hero.hp -= extra
				verlust[0] += int(e.damage) + extra
				offen[0] = ""
		var react := func(_t, intent):
			z.ringe += 1
			offen[0] = String(intent.id) if neu and String(intent.id) in NEU else ""
			return spieler
		mars.start(react)
		var n := 0
		while mars.outcome == "ONGOING" and n < 400:
			n += 1
			var f = mars.current()
			if f.id == "hero":
				z.runden += 1
			var ts: Array = mars.targets(f)
			mars.act(["attack", ts[0].id] if not ts.is_empty() else ["wait"], react)
		if mars.outcome == "WON":
			z.siege += 1
		z.verlust += float(verlust[0]) / maxf(1.0, float(max_hp))
	return z
