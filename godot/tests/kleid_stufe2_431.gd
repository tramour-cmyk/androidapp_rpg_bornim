extends SceneTree
# 431h Stufe 2 (Chef 17.11., 09:45, „431h A“): jede angelegte Ruestung sichtbar, auch Stuecke anderer Trachten und Ritterteile
# (heldfigur.gd kleide, schrank_an; held_klassen.py schrank_datei, Feld „teil“ der Gegenstandsliste). Je Herkunft und Geschlecht:
# (1) Startausruestung: kein Schrankteil am Helden (Stufe 1 bleibt); (2) Kapitel-1-Stuecke fremder Trachten (Lederruestung, Handschuhe,
# Lederstiefel, Kettenhemd, Kroggs Pranken) und ein schwerer Satz (Topfhelm, Plattenpanzer, Beinschienen): fuer jeden Platz mit
# fremdem Stueck ist das eigene Teil weg, die Netze des Schrankteils hangen sichtbar am Skelett des Helden, jeder Knochen ihrer Bindung
# ist im Skelett und ihre Bindung passt zur Ruhelage des Helden (gleiches Geruest, Abweichung unter 1 mm), die Leibstuecke, die das Teil
# deckt, sind weg; (3) Schrankteile im Teil der eigenen Tracht (Lederruestung am Jaegerkind) nicht doppelt; (4) 1569: Umhang
# (auch Einzelstueck) an jeder Tracht, an der Wachtracht ihr eigener.
# Braucht daten/schrank_*.bin und held-klassen.json mit „schrank“, „eigen“; sonst „KLEID2 ohne Daten“.
# godot --headless --path godot -s res://tests/kleid_stufe2_431.gd   -> „KLEID2 0 Fehler“, Ende 0/1

var falsch := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		falsch += 1
		print("FEHLER ", was)

func netze(m: Node3D) -> Dictionary:
	var d := {}
	for mi in m.find_children("*", "MeshInstance3D", true, false): d[String(mi.name)] = mi
	return d

func stueck(base: String) -> Dictionary: return {"base": base}

func _init() -> void:
	var info := HeldFigur.lade_info()
	if not info.has("schrank") or not FileAccess.file_exists("res://daten/schrank_M_KETTE.bin"):
		print("KLEID2 ohne Daten (held-klassen.json ohne schrank)")
		quit(0)
		return
	var saetze := {
		"kapitel1": {"CHEST": "leather", "ARMS": "gloves", "LEGS": "boots"},
		"kette": {"CHEST": "chain_shirt", "ARMS": "gauntlets_ogre", "LEGS": "leggings"},
		"schwer": {"HEAD": "great_helm", "CHEST": "plate", "ARMS": "gauntlets", "LEGS": "greaves"},
		"kloster": {"HEAD": "hood", "CHEST": "novice_habit", "ARMS": "bracers", "LEGS": "leggings"},
		# 1569 (Chef 17.11., 16:12, t297.18): Umhang an jeder Tracht zu sehen (Schrankteil UMHANG aus der Wachtracht), auch als Einzelstueck
		"umhang": {"CLOAK": "cloak"},
		"umhang_einzel": {"CLOAK": "cloak_protection"},
	}
	for h in ["Wachsoldat", "Zauberlehrling", "Jägerkind", "Klosterschüler", "Wanderer"]:
		for g in ["m", "w"]:
			if not HeldFigur.da(h, g): pruefe(false, "%s %s: Figur fehlt" % [h, g]); continue
			var hw := BrsHeld.fuer_spiel("Test", "Mensch", h)
			var modell := String(HeldFigur.tracht({"herkunft": h, "aussehen": {"geschlecht": g}})["modell"])
			var tr: Dictionary = info["trachten"].get(modell, {})
			var eigen: Array = tr.get("eigen", [])
			pruefe(not eigen.is_empty(), "%s: ohne eigen" % modell)
			var sch: Dictionary = info["schrank"].get(String(tr.get("geschlecht", "")), {})
			pruefe(not sch.is_empty(), "%s: kein Schrank" % modell)
			pruefe(sch.has("UMHANG"), "%s: Schrank ohne UMHANG (1569)" % modell)
			# (1) Start
			var m := HeldFigur.baue({"herkunft": h, "volk": "HUMAN", "aussehen": {"geschlecht": g}, "ausruestung": hw.ausruestung.duplicate()}, [])
			if m == null: pruefe(false, "%s %s: keine Figur" % [h, g]); continue
			for n in netze(m): pruefe(not String(n).begins_with("Teil_"), "%s %s Start: Schrankteil %s" % [h, g, n])
			m.free()
			# (2) fremde Saetze
			for sn in saetze:
				var aus := hw.ausruestung.duplicate()
				for p in saetze[sn]: aus[p] = stueck(saetze[sn][p])
				m = HeldFigur.baue({"herkunft": h, "volk": "HUMAN", "aussehen": {"geschlecht": g}, "ausruestung": aus}, [])
				var wo := "%s %s %s" % [h, g, sn]
				if m == null: pruefe(false, "%s: keine Figur" % wo); continue
				var n := netze(m)
				var sk := Gebiet.finde(m, "Skeleton3D") as Skeleton3D
				var gedeckt := {}
				for p in saetze[sn]:
					var b: String = saetze[sn][p]
					var fremd := b not in eigen
					var rock := String(tr.get("rock", ""))
					if p == "LEGS" and rock != "": fremd = saetze[sn].has(rock) and String(saetze[sn][rock]) not in eigen
					for nm in Array(tr.get("teile", {}).get(p, [])):
						if n.has(nm): pruefe((n[nm] as MeshInstance3D).visible == (not fremd), "%s: eigenes %s (%s) sichtbar %s" % [wo, nm, p, (n[nm] as MeshInstance3D).visible])
					for t in HeldFigur.teil_von(b):
						if not sch.has(t): continue
						for tn in Array(sch[t]["netze"]):
							if not fremd:
								pruefe(not n.has(tn), "%s: %s doppelt (eigene Tracht)" % [wo, tn])
								continue
							pruefe(n.has(tn) and (n[tn] as MeshInstance3D).visible, "%s: Schrankteil %s fehlt" % [wo, tn])
							if not n.has(tn): continue
							var mi := n[tn] as MeshInstance3D
							pruefe(mi.get_parent() == sk and mi.skin != null, "%s: %s nicht am Skelett" % [wo, tn])
							var schlecht := 0
							var weit := 0.0
							for i in mi.skin.get_bind_count():
								var bi := sk.find_bone(String(mi.skin.get_bind_name(i)))
								if bi < 0: schlecht += 1; continue
								var d := (mi.skin.get_bind_pose(i) * sk.get_bone_global_rest(bi)).origin.length()
								weit = maxf(weit, d)
							pruefe(schlecht == 0, "%s: %s, %d Knochen fehlen im Skelett" % [wo, tn, schlecht])
							pruefe(weit < 0.001, "%s: %s Bindung weicht %.4f m von der Ruhelage ab" % [wo, tn, weit])
						if fremd: for lo in Array(sch[t].get("leib", [])): gedeckt[lo] = true
				for lo in gedeckt:
					if n.has(lo): pruefe(not (n[lo] as MeshInstance3D).visible, "%s: %s unter Schrankteil sichtbar" % [wo, lo])
				# 1569: unter dem fremden Umhang zieht die Kleidung ein (unter_CLOAK), sonst nicht
				var umhang_fremd: bool = saetze[sn].has("CLOAK") and String(saetze[sn]["CLOAK"]) not in eigen
				var mit_schluessel := 0
				for nm in n:
					var mi := n[nm] as MeshInstance3D
					if String(nm).begins_with("Leib_") or not (mi.mesh is ArrayMesh): continue
					var bi := -1
					for j in (mi.mesh as ArrayMesh).get_blend_shape_count():
						if String((mi.mesh as ArrayMesh).get_blend_shape_name(j)) == "unter_CLOAK": bi = j
					if bi < 0: continue
					mit_schluessel += 1
					pruefe(is_equal_approx(mi.get_blend_shape_value(bi), 1.0 if umhang_fremd else 0.0), "%s: %s unter_CLOAK %.1f" % [wo, nm, mi.get_blend_shape_value(bi)])
				if umhang_fremd: pruefe(mit_schluessel > 0, "%s: keine Kleidung mit unter_CLOAK" % wo)
				m.free()
	print("KLEID2 %d Fehler" % falsch)
	quit(1 if falsch > 0 else 0)
