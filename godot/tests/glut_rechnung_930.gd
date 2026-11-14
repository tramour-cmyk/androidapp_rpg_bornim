extends SceneTree
# 930.6 (DESIGN-GLUT.md 10 Stufe 1, Prüfpunkt „Rechnung im Spielcode gegen glut2.py: Sieg und Runden je Fall ±3“): dieselben Fälle
# wie tools/sim444/glut2.py (12 Begegnungen je Herkunft, Held wie dort), gespielt im Spiel: mars.gd mit Schalter glut (Regelkern
# regeln/glut.gd), der Spieler ist der Autopilot (Vorschlag der Bedienung 7.1, S) bzw. legt alle übrige Glut nach (N, Nachlegen nach
# werte.json „glut“); am Ring trifft er wie die Rechnung (werte.json „glut“ „rechnung“: perfekt, gut, daneben; langsamer Ring der Wehr).
# Die Rechnung gibt je Zelle den Helden mit (glut2.py --json); die Sonderregeln der alten Arten (Untotenzähigkeit …) kennt die
# Rechnung nicht, sie sind hier aus. Dazu: die Zahlen, mit denen glut2.py rechnet, gleich werte.json „glut“.
# Zelle: Spiel (Rechnung) Sieg % · Runden; Abweichung über 3 Punkte im Sieg oder 0,3 Runden: „FALSCH“.
# Aufruf im Ordner godot (Rechnung vorher oder von selbst):
#   python3 ../tools/sim444/glut2.py --kaempfe 3000 --json /tmp/glut.json
#   GLUT=/tmp/glut.json [N=3000] [NUR=Krogg] godot --headless -s res://tests/glut_rechnung_930.gd   (Exit 0 = alle Zellen ±3)

const Mars = preload("res://regeln/mars.gd")
const Wuerfel = preload("res://regeln/wuerfel.gd")
const Aufruf = preload("res://kampf/aufruf.gd")
const Brs = preload("res://regeln/brs.gd")

## Begegnung der Rechnung -> Gegner im Spiel (Kennungen), RUDEL und GRIM wie aufruf.gd
const FALL := {"Rudel": ["RUDEL"], "Kobold": ["kobold"], "Zombie": ["zombie"], "Goblin-Späher": ["goblin_archer"], "Skelett": ["skeleton"],
	"Wolf+Goblin-Späher": ["wolf", "goblin_archer"], "Riesenfledermaus": ["giant_bat"], "Kobold+Goblin-Schamane": ["kobold", "goblin_shaman"],
	"Riesenspinne": ["giant_spider"], "Krogg": ["bugbear"], "Grimmzahn": ["GRIMM"], "Grak": ["hobgoblin_captain"]}
const GRUNDFORM := {"Einhänder": "longsword", "Bogen": "shortbow", "Stumpfe Waffen": "mace", "Dolche": "dagger", "Faustkampf": ""}

var tab: Dictionary
var monsters := {}
var skills := {}
var ring := [0.2, 0.5, 0.3]
var ring_wehr := [0.45, 0.45, 0.1]


func _initialize() -> void:
	_lauf.call_deferred()


func _lauf() -> void:
	var pfad := OS.get_environment("GLUT")
	var n := int(OS.get_environment("N")) if OS.get_environment("N") != "" else 3000
	if pfad == "":
		pfad = OS.get_user_data_dir() + "/glut_930.json"
		var aus := []
		var rc := OS.execute("python3", [ProjectSettings.globalize_path("res://../tools/sim444/glut2.py"), "--kaempfe", str(n), "--json", pfad], aus, true)
		if rc != 0:
			print("GLUT930 FALSCH: glut2.py lief nicht (%d): %s" % [rc, "".join(aus)])
			quit(1)
			return
	var R = JSON.parse_string(FileAccess.get_file_as_string(pfad))
	if not (R is Dictionary):
		print("GLUT930 FALSCH: keine Rechnung in %s" % pfad)
		quit(1)
		return
	var fehler := 0
	fehler += _zahlen(R)
	var G: Dictionary = Brs.lade()["glut"]
	ring = G["rechnung"]["ring"]
	ring_wehr = G["rechnung"]["ring_wehr"]
	tab = Tabellen.lade()
	for s in tab.skills:
		skills[s.id] = s
	for mo in tab.monsters:
		monsters[mo.id] = mo
	var nur := OS.get_environment("NUR")
	print("Rechnung je Zelle %d Kämpfe, Spiel je Zelle %d; Zelle Spiel (Rechnung) Sieg %% · Runden, S = Vorschlag, N = Nachlegen %d %%"
		% [int(R.kaempfe), n, roundi(float(R.nachlegen) * 100)])
	var gross := {"S": [0.0, 0.0], "N": [0.0, 0.0]}
	var zeilen := {}
	for z in R.faelle:
		if nur != "" and not String(z.gegner).contains(nur):
			continue
		var text := "%-18s %-24s St %d" % [z.herkunft, z.gegner, int(z.stufe)]
		for pol in ["S", "N"]:
			var e := _messe(z, pol, n)
			var soll: Dictionary = z[pol]
			var dq := absf(e.quote - float(soll.quote)) * 100.0
			var dr := absf(e.runden - float(soll.runden)) if e.runden > 0.0 and soll.runden != null else 0.0
			gross[pol][0] = maxf(gross[pol][0], dq)
			gross[pol][1] = maxf(gross[pol][1], dr)
			var falsch := dq > 3.0 or dr > 0.3
			if falsch:
				fehler += 1
			text += "   %s %3d (%3d) · %4.1f (%s)%s" % [pol, roundi(e.quote * 100), roundi(float(soll.quote) * 100), e.runden,
				"%.1f" % float(soll.runden) if soll.runden != null else "–", " FALSCH" if falsch else ""]
		print(text)
	print("größte Abweichung: S Sieg %.1f Punkte, Runden %.2f; N Sieg %.1f Punkte, Runden %.2f" % [gross.S[0], gross.S[1], gross.N[0], gross.N[1]])
	print("GLUT930 %s: %d Abweichungen" % ["gut" if fehler == 0 else "FALSCH", fehler])
	quit(0 if fehler == 0 else 1)


## Die Zahlen der Rechnung gleich werte.json „glut“ (eine Quelle, 1049)
func _zahlen(R: Dictionary) -> int:
	var G: Dictionary = Brs.lade()["glut"]
	var Z: Dictionary = R.zahlen
	var f := 0
	var paare := [["frei", G.frei, Z.frei], ["ring", G.rechnung.ring, Z.ring], ["ring_wehr", G.rechnung.ring_wehr, Z.ring_wehr],
		["gross_faktor", G.gross_faktor, Z.gross_faktor], ["geselle", G.antwort_voll_ab, Z.geselle], ["taeuschen", G.taeuschen.anteil, Z.taeuschen],
		["taeuscher", (G.taeuschen.arten as Array).duplicate(), Z.taeuscher], ["gegenwert", G.lesen.gegenwert, Z.gegenwert],
		["tempo_gegner", G.tempo_gegner, Z.tempo_gegner], ["ungunst", G.ungunst, Z.ungunst], ["wehr_ungunst", G.wehr_ungunst, Z.ungunst],
		["held_tempo", G.held_tempo, Z.held_tempo]]
	for p in paare:
		var a = p[1]
		var b = p[2]
		if a is Array:
			a = a.duplicate()
			a.sort()
			b = (b as Array).duplicate()
			b.sort()
		if JSON.stringify(a, "", true) != JSON.stringify(b, "", true) and not (a is float or a is int):
			print("FALSCH Zahl %s: werte.json %s, glut2.py %s" % [p[0], JSON.stringify(a), JSON.stringify(b)])
			f += 1
		elif (a is float or a is int) and not is_equal_approx(float(a), float(b)):
			print("FALSCH Zahl %s: werte.json %s, glut2.py %s" % [p[0], a, b])
			f += 1
	return f


func _blatt(z: Dictionary) -> Dictionary:
	var h: Dictionary = z.held
	var W := Brs.lade()
	var k := {"stufe": int(z.stufe), "werte": h.werte, "fert": h.fert, "herkunft": z.herkunft, "ruestung": {"art": h.ruestung},
		"schild": {"art": "Schild"} if h.schild else {}, "faehigkeiten": h.zauber, "waffe": {"gruppe": h.waffe, "art": W.waffen[h.waffe].art},
		"leben": int(h.leben), "mana": int(h.mana), "volk": "Mensch"}
	var sheet: Dictionary = (tab.probe.FIGHTER.hero.hero as Dictionary).duplicate(true)
	var gf: String = GRUNDFORM.get(String(h.waffe), "longsword")
	sheet.main = {"id": gf, "de": gf, "en": gf, "atk": 0, "dmg": [1, 4, 0], "ranged": W.waffen[h.waffe].art == "fern", "reach": false, "two": false, "type": "BLUDGEONING"}
	sheet.second = null
	sheet.level = int(z.stufe)
	sheet.skills = []
	sheet.sp = 0
	sheet.sp_max = 0
	sheet.schild = "shield" if h.schild else ""
	sheet.brs = k
	return sheet


func _gegner(fall: String, dice) -> Array:
	var out := []
	var i := 0
	for id in FALL[fall]:
		var foes: Array
		if id == "RUDEL":
			foes = Aufruf.rudel(monsters, dice)
		elif id == "GRIMM":
			foes = Aufruf.gegner("GRIMM", monsters, dice)
		else:
			var mo: Dictionary = (monsters[id] as Dictionary).duplicate(true)
			foes = [Mars.monster_fighter("%s%d" % [id, i], Vector2i(i % 2, i / 2), mo, 1)]
		for f in foes:
			f.monster = (f.monster as Dictionary).duplicate(true)
			f.monster.erase("special")     # Sonderregeln der alten Arten: nicht in der Rechnung
			out.append(f)
		i += 1
	return out


func _messe(z: Dictionary, pol: String, n: int) -> Dictionary:
	var sheet := _blatt(z)
	var sieg := 0
	var runden := 0
	var spieler := RandomNumberGenerator.new()
	spieler.seed = hash([z.herkunft, z.gegner, pol])
	var react := func(_t, intent: Dictionary) -> String:
		var p: Array = ring_wehr if bool(intent.get("wehr", false)) else ring
		var r := spieler.randf()
		return Mars.PERFECT if r < float(p[0]) else (Mars.GOOD if r < float(p[0]) + float(p[1]) else Mars.NONE)
	for i in n:
		var seed := hash([z.herkunft, z.gegner, pol, i])
		var foes := _gegner(String(z.gegner), Wuerfel.new(seed))
		var hero = Mars.hero_fighter("hero", "PARTY", Vector2i(Mars.FRONT, 0), sheet, int(z.held.leben), null, skills)
		var mars = Mars.new([hero], foes, tab, Wuerfel.new(seed + 1), Wuerfel.new(seed + 2), 0, false)
		mars.glut = true
		mars.start(react)
		var zuege := 0
		while mars.outcome == "ONGOING" and zuege < 500:
			zuege += 1
			mars.act(["GLUT", mars.gk.vorschlag(mars.current(), pol)], react)
		if mars.outcome == "WON":
			sieg += 1
			runden += mars.gk.runde
	return {"quote": float(sieg) / n, "runden": float(runden) / sieg if sieg > 0 else 0.0}
