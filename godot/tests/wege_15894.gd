# 1589.4 (DESIGN-GEGNER.md 5, 11.3; Antworten Sokrates 24.11., 19:10, F1–F5): Wege im Kampf, ohne Bild, an allen Arten Kapitel 1 und
# gemischten Gruppen (Probekampf, Autopilot). Je Bild jede Figur: Punkt am Boden, Blick, Bewegung. Geprüft wird:
#  durch   kein Weg durch einen Umriss: die Mitte des Körpers einer gehenden Figur liegt nie im Umriss einer anderen Stehenden (dieselbe Kapsel
#          wie im Spiel, figur.umriss_kapsel; Chef 25.11., 09:55)
#  quer    kein Querlauf: beim Gehen liegt der Weg höchstens 45° neben Blick oder Rücken (F2), außer dem einzelnen Seitschritt
#          (1284a, F4: höchstens ZUR_SEITE_M weit), dem Ausweichen (Antwort auf einen Angriff, Bewegung „Ausweichen…“) und der Flucht
#  heran   geradewegs heran (Chef 18.11., 14:33, Ratte quer): im Anlauf zum Biss oder Hieb liegt der Weg nie mehr als 45° quer zur
#          Richtung zum Ziel (über ZUR_SEITE_M Weg)
#  ruecken Absetzen mit Gesicht: ein Gegner, der sich vom nächsten Helden entfernt, blickt zu ihm (nie der Rücken außer auf der Flucht)
#  stur    Untote (Skelett, Wiedergänger, Grabhund) und Krogg setzen sich nicht ab (entfernen sich nicht vom nächsten Helden,
#          außer beim Ausweichen)
#  1526    wer vorn Platz macht (außer Untoten und Krogg, die bleiben) (Reihe vorn → hinten, ein anderer hinten → vorn), weicht nur so
#          weit, dass der Nachrücker vorbeikommt (Sokrates 24.11., 21:50, 1526 (b)): steht danach höchstens sein Umriss plus der des
#          Nachrückers plus seine halbe Weglänge (Kapsel quer zum Weg, figur.weg_laenge) von seinem Punkt beim Tausch, wenn er nach dem Tausch zuerst gegangen ist
# Aufruf: godot --headless --path godot --fixed-fps 30 -s res://tests/wege_15894.gd (Exit 0 = gut); WEGE=RATS,WOLVES nur diese;
# WEGE_LOG=1 je Verstoß eine Zeile mit Bild, Figur, Bewegung.
extends SceneTree

const Probe = preload("res://kampf/probe.gd")
const Arena = preload("res://regeln/arena.gd")
const Mars = preload("res://regeln/mars.gd")

## Probekämpfe (probe.gd FOES): jede Art Kapitel 1, gemischt SPIDER (Spinne und Wolf), SCOUT (Späher und Goblin), RUDEL
const KAEMPFE := ["RATS", "WOLVES", "RUDEL", "GRIMM", "SPIDER", "SCOUT", "GOBLINS", "KOBOLDS", "SHAMANS", "BOARS", "CENTIPEDES",
	"LEECHES", "SLUGS", "BATS", "SKELETONS", "WIEDERGAENGER3", "GRABHUNDE", "KROGG", "GRAK"]
const HELDEN := {"RATS": ["FIGHTER", "ROGUE"], "WOLVES": ["CLERIC", "FIGHTER"], "SPIDER": ["ROGUE", "WIZARD"], "SCOUT": ["WIZARD", "CLERIC"]}
const STUR := ["skeleton", "zombie", "ghoul", Mars.KROGG]
const SPIEL_S := 40.0          # Spielzeit je Kampf
const ZEIT := 3.0              # Engine.time_scale (bei --fixed-fps 30: ein Bild = 0,1 s Spielzeit)
const GEHT_MPS := 0.25         # darunter gilt eine Figur als stehend (Zittern, Atmen, Feinkontakt)
const QUER_GRAD := 45.0        # F2 (Sokrates 19:10)
const ZUR_SEITE_M := 0.5       # figur.gd ZUR_SEITE_M: der einzelne Seitschritt (1284a)
const RUECKEN_M := 0.1         # so weit darf ein Gegner rückwärts vom Helden weg nicht mit dem Rücken gehen (Messgenauigkeit)
const STUR_M := 0.2            # so weit entfernt sich ein Untoter oder Krogg höchstens vom nächsten Helden (Zucken beim Treffer)

var fehler := 0
var faelle := 0
var log_an := OS.get_environment("WEGE_LOG") != ""
var summe := {}       # Prüfung -> Zahl der Verstöße über alle Kämpfe


func _initialize() -> void:
	Engine.time_scale = ZEIT
	_lauf.call_deferred()


func _lauf() -> void:
	var nur := OS.get_environment("WEGE")
	for k in KAEMPFE:
		if nur != "" and not k in nur.split(","):
			continue
		await _kampf(k)
	print("WEGE15894 %d Kämpfe, %s, %s" % [faelle, summe, "0 Fehler" if fehler == 0 else "%d FEHLER" % fehler])
	quit(1 if fehler > 0 else 0)


func _kampf(foe: String) -> void:
	var p = Probe.new()
	var h: Array = HELDEN.get(foe, ["FIGHTER", "CLERIC"])
	p.hero_cls = h[0]
	p.merc_cls = h[1]
	p.foe = foe
	root.add_child(p)
	await process_frame
	p._start(7)
	for i in 6:
		await process_frame
	var kf = p.fight
	if kf == null:
		fehler += 1
		print("FEHLER %s: kein Kampfort" % foe)
		return
	faelle += 1
	for i in 15:     # Umrisse messen (kampfort._umriss_messen)
		await process_frame
	var mars = kf.mars
	for f in mars.fighters():
		if f.side == "PARTY":
			f.auto = true
	mars.set_autopilot(true)
	if not kf.busy:
		kf.go_on()
	var st := {}          # id -> Zustand
	var befund := {"durch": 0, "quer": 0, "heran": 0, "ruecken": 0, "stur": 0, "1526": 0}
	var bild := 0
	var plaetze_vor := {}
	var tausch := {}      # id -> [freier Platz, Bild]
	var bilder := int(SPIEL_S * 30.0 / ZEIT)
	while bild < bilder and mars.outcome == "ONGOING":
		await process_frame
		bild += 1
		for f in mars.fighters():     # der Autopilot gibt unter einem Drittel ab; hier geht es nur um Wege
			if f.side == "PARTY" and f.hp > 0:
				f.hp = maxi(f.hp, f.max_hp)
		if not mars.autopilot:
			mars.set_autopilot(true)
			if not kf.busy:
				kf.go_on()
		var figs: Array = kf.figures.values().filter(func(o): return o.visible and not o.down and o.dead_at < 0)
		# 1526: Platztausch vorn ↔ hinten unter Gegnern
		var pl: Dictionary = kf.shown.get("places", {})
		var nach_hinten := []
		var nach_vorn := []
		for id in pl:
			if plaetze_vor.has(id) and kf.figures.has(id) and kf.figures[id].fighter.side == "FOES":
				if plaetze_vor[id].x == Mars.FRONT and pl[id].x == Mars.BACK:
					nach_hinten.append(id)
				elif plaetze_vor[id].x == Mars.BACK and pl[id].x == Mars.FRONT:
					nach_vorn.append(id)
		plaetze_vor = pl.duplicate()
		if nach_hinten.size() == 1 and nach_vorn.size() == 1 and not String(kf.figures[nach_hinten[0]].fighter.monster.get("id", "")) in STUR:
			var hf = kf.figures[nach_hinten[0]]
			tausch[nach_hinten[0]] = [Vector2(hf.position.x, hf.position.z), bild, false,
				Vector2(hf.position.x, hf.position.z), float(hf.umriss_kapsel()[2]) + float(kf.figures[nach_vorn[0]].umriss_kapsel()[2]) + 0.5 * hf.weg_laenge()]
		for o in figs:
			var id: String = o.fighter.id
			var p3: Vector3 = o.position
			var p2 := Vector2(p3.x, p3.z)
			var blick := Vector2(sin(o.rotation.y), cos(o.rotation.y))
			if not st.has(id):
				st[id] = {"p": p2, "lauf": 0.0, "quer": 0.0, "heran": 0.0, "rueck": 0.0, "stur": 0.0, "ruhig": 0}
				continue
			var s: Dictionary = st[id]
			var d: Vector2 = p2 - s.p
			s.p = p2
			var v := d.length() * 30.0 / ZEIT
			if v < GEHT_MPS:
				s.ruhig += 1
				s.quer = 0.0
				s.heran = 0.0
				s.rueck = 0.0
				if s.ruhig == 1:
					s.stur = 0.0
				if tausch.has(id) and s.ruhig >= 10 and tausch[id][2]:
					var beim_tausch: Vector2 = tausch[id][0]
					var r: float = tausch[id][4] + Arena.GLEICH
					if p2.distance_to(beim_tausch) > r:
						befund["1526"] += 1
						_melde(foe, bild, o, "1526", "steht %.2f m weg vom Punkt beim Tausch (höchstens %.2f)" % [p2.distance_to(beim_tausch), r])
					tausch.erase(id)
				continue
			s.ruhig = 0
			if tausch.has(id) and p2.distance_to(tausch[id][3]) > float(o.umriss_kapsel()[2]):
				tausch[id][2] = true     # 717.1 A: er rückt in seinem Zug; geprüft wird, wo er nach dem ersten Weg steht
			var flieht: bool = o.flieht or o.fighter.fled
			var nm := String(o.anim.current_animation) if o.anim else ""
			var weicht: bool = nm.begins_with("Ausweichen")
			# durch: Mitte im Umriss einer anderen Stehenden
			for x in figs:
				if x != o and not x.falling():
					var kx: Array = x.umriss_kapsel()
					var ko: Array = o.umriss_kapsel()     # Mitte des Körpers, nicht der Punkt der Figur (Wolf: Kopf vorn)
					var nah := Arena.punkt_kapsel(((ko[0] as Vector2) + (ko[1] as Vector2)) * 0.5, kx)
					if nah < float(kx[2]) and (not _geht(st, x) or x.fighter.id < id):
						befund.durch += 1
						_melde(foe, bild, o, "durch", "Mitte %.2f m in %s (Kapsel r %.2f, Länge %.2f), %s" % [nah, x.fighter.id, kx[2], x.kapsel_laenge(), nm])
			# quer: Winkel Weg zu Blick
			var w := rad_to_deg(blick.angle_to(d.normalized()))
			if not flieht and not weicht and absf(w) > QUER_GRAD and absf(w) < 180.0 - QUER_GRAD:
				s.quer += d.length()
				if s.quer > ZUR_SEITE_M * o._scale() and s.quer - d.length() <= ZUR_SEITE_M * o._scale():
					befund.quer += 1
					_melde(foe, bild, o, "quer", "%.0f° neben dem Blick, %.2f m, %s, gang %s" % [w, s.quer, nm, o.gang])
			else:
				s.quer = 0.0
			if o.fighter.side != "FOES" or flieht:
				continue
			var held = _naechster_held(kf, o)
			if held == null:
				continue
			# heran: im Anlauf geradewegs auf das Ziel zu
			var ziel = o.get("angriff_ziel")     # figur.gd strike (1589.4), sonst der nächste Held
			if ziel == null or not is_instance_valid(ziel):
				ziel = held
			if o.gang in ["anlauf", "hin"]:
				var zum := Vector2(ziel.position.x, ziel.position.z) - p2
				var wz := rad_to_deg(zum.angle_to(d))
				if absf(wz) > QUER_GRAD and absf(wz) < 180.0 - QUER_GRAD:
					s.heran += d.length()
					if s.heran > ZUR_SEITE_M * o._scale() and s.heran - d.length() <= ZUR_SEITE_M * o._scale():
						befund.heran += 1
						_melde(foe, bild, o, "heran", "%.0f° neben der Richtung zu %s, %.2f m, %s (Platz %s, steht %s, Ziel %s)" % [wz, ziel.fighter.id, s.heran, nm, o.angriff_von, o.position, ziel.position])
				else:
					s.heran = 0.0
			var zu := Vector2(held.position.x, held.position.z) - p2
			var weg_vom := zu.dot(d) < 0.0
			# ruecken: entfernt sich vom Helden, Blick über 90° vom Helden weg
			if weg_vom and absf(rad_to_deg(blick.angle_to(zu))) > 90.0:
				s.rueck += d.length()
				if s.rueck > RUECKEN_M and s.rueck - d.length() <= RUECKEN_M:
					befund.ruecken += 1
					_melde(foe, bild, o, "ruecken", "%.0f° vom Helden weg, %s, gang %s, %s" % [rad_to_deg(blick.angle_to(zu)), nm, o.gang, String(o.fighter.monster.get("id", ""))])
			else:
				s.rueck = 0.0
			# stur: Untote und Krogg entfernen sich nicht vom Helden
			if String(o.fighter.monster.get("id", "")) in STUR and weg_vom and not weicht:
				s.stur += -zu.normalized().dot(d)
				if s.stur > STUR_M and s.stur + zu.normalized().dot(d) <= STUR_M:
					befund.stur += 1
					_melde(foe, bild, o, "stur", "setzt sich ab, %s" % nm)
	var n := 0
	for k in befund:
		n += befund[k]
		summe[k] = summe.get(k, 0) + befund[k]
	print("WEGE %s (%s/%s): %.1f s, %s, %s" % [foe, h[0], h[1], bild * ZEIT / 30.0, mars.outcome, befund])
	if n > 0:
		fehler += 1
	kf.queue_free()
	p.queue_free()
	for i in 3:
		await process_frame


func _geht(st: Dictionary, x) -> bool:
	return st.has(x.fighter.id) and st[x.fighter.id].ruhig == 0


func _naechster_held(kf, o):
	var best = null
	for x in kf.figures.values():
		if x.fighter.side == "PARTY" and x.visible and not x.down and x.dead_at < 0:
			if best == null or o.position.distance_to(x.position) < o.position.distance_to(best.position):
				best = x
	return best


func _melde(foe: String, bild: int, o, was: String, text: String) -> void:
	if log_an:
		print("  %s %5.1f s %s %s: %s" % [foe, bild * ZEIT / 30.0, o.fighter.id, was, text])
