extends SceneTree
# 431h A (Chef 16.11., 10:08): der Held traegt genau das, was in den Ausruestungsplaetzen steht (heldfigur.gd kleide, held_klassen.py
# schrank). Je Herkunft und Geschlecht: (1) mit der Startausruestung (welt.start) sind die Teile jedes belegten Platzes zu sehen, der Leib
# dort nicht, und die Startausruestung belegt Oberkoerper, Arme (ausser Zauberlehrling: Robe mit Aermeln) und Beine; (2) ohne Kleidung kein Teil der Tracht, alle acht Leibstuecke
# sichtbar, kein „unter_“ an; (3) nur der Oberkoerper leer: Leibstuecke nach „leib“, Kleidung unter dem Oberkoerper („unter“) da.
# Braucht daten/held_*.bin mit „teile“ (Bau nach 431h); sonst „KLEID431 ohne Daten“.
# godot --headless --path godot -s res://tests/kleid_431.gd   -> „KLEID431 0 Fehler“, Ende 0/1

var falsch := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		falsch += 1
		print("FEHLER ", was)

func netze(m: Node3D) -> Dictionary:
	var d := {}
	for mi in m.find_children("*", "MeshInstance3D", true, false): d[String(mi.name)] = mi
	return d

func unter(mi: MeshInstance3D, p: String) -> float:
	var me := mi.mesh as ArrayMesh
	for i in me.get_blend_shape_count():
		if String(me.get_blend_shape_name(i)) == "unter_" + p: return mi.get_blend_shape_value(i)
	return -1.0

func _init() -> void:
	var info := HeldFigur.lade_info()
	var mit := 0
	for k in info.get("trachten", {}): mit += int((info["trachten"][k] as Dictionary).has("teile"))
	if mit == 0:
		print("KLEID431 ohne Daten (held-klassen.json ohne teile)")
		quit(0)
		return
	for h in ["Wachsoldat", "Zauberlehrling", "Jägerkind", "Herumtreiber", "Klosterschüler", "Kräutersammler", "Schmiedelehrling", "Wanderer"]:
		for g in ["m", "w"]:
			if not HeldFigur.da(h, g): pruefe(false, "%s %s: Figur fehlt" % [h, g]); continue
			var hw := BrsHeld.fuer_spiel("Test", "Mensch", h)
			var pflicht := ["CHEST", "LEGS"] if h == "Zauberlehrling" else ["CHEST", "ARMS", "LEGS"]   # 431h: Robe mit Aermeln, Arme leer
			for p in pflicht: pruefe(hw.ausruestung.has(p), "%s: Start ohne %s" % [h, p])
			var modell := String(HeldFigur.tracht({"herkunft": h, "aussehen": {"geschlecht": g}})["modell"])
			var teile: Dictionary = info["trachten"].get(modell, {}).get("teile", {})
			pruefe(not teile.is_empty(), "%s: keine Teile je Platz" % modell)
			for p in pflicht: pruefe(teile.has(p), "%s: kein Teil fuer %s" % [modell, p])
			var faelle := {"start": hw.ausruestung.duplicate(), "nackt": {"MAIN_HAND": hw.ausruestung.get("MAIN_HAND")},
				"ohne_rumpf": hw.ausruestung.duplicate()}
			(faelle["ohne_rumpf"] as Dictionary).erase("CHEST")
			for f in faelle:
				var aus: Dictionary = faelle[f]
				var m := HeldFigur.baue({"herkunft": h, "volk": "HUMAN", "aussehen": {"geschlecht": g}, "ausruestung": aus}, [])
				if m == null: pruefe(false, "%s %s %s: keine Figur" % [h, g, f]); continue
				var n := netze(m)
				var wo := "%s %s %s" % [h, g, f]
				for p in teile:
					for nm in teile[p]:
						pruefe(n.has(nm), "%s: Netz %s fehlt" % [wo, nm])
						if n.has(nm): pruefe((n[nm] as MeshInstance3D).visible == (aus.get(p) is Dictionary), "%s: %s (%s) sichtbar %s" % [wo, nm, p, (n[nm] as MeshInstance3D).visible])
				# Leib: jedes Stueck da, wenn kein gezeigter Platz es deckt; ausgezogen alle acht da, kein unter_ an; Start: Rumpf weg
				var leib: Dictionary = info["trachten"][modell].get("leib", {})
				pruefe(leib.size() == 8, "%s: %d Leibstuecke statt 8" % [modell, leib.size()])
				for ln in leib:
					pruefe(n.has(ln), "%s: %s fehlt" % [wo, ln])
					if not n.has(ln): continue
					var soll := not Array(leib[ln]).any(func(p): return aus.get(p) is Dictionary)
					pruefe((n[ln] as MeshInstance3D).visible == soll, "%s: %s sichtbar %s statt %s" % [wo, ln, (n[ln] as MeshInstance3D).visible, soll])
					if f == "nackt":
						pruefe((n[ln] as MeshInstance3D).visible, "%s: %s ausgezogen nicht da" % [wo, ln])
						for q in ["CHEST", "ARMS", "LEGS", "CLOAK", "HEAD"]: pruefe(unter(n[ln], q) <= 0.0, "%s: %s unter_%s an" % [wo, ln, q])
				if f == "start" and n.has("Leib_RUMPF"): pruefe(not (n["Leib_RUMPF"] as MeshInstance3D).visible, "%s: Rumpf unter der Kleidung zu sehen" % wo)
				for un in info["trachten"][modell].get("unter", {}):
					var pp: Array = info["trachten"][modell]["unter"][un]
					if n.has(un): pruefe((n[un] as MeshInstance3D).visible == (aus.get(pp[0]) is Dictionary and not (aus.get(pp[1]) is Dictionary)), "%s: %s sichtbar falsch" % [wo, un])
				m.free()
	print("KLEID431 %d Fehler" % falsch)
	quit(1 if falsch > 0 else 0)
