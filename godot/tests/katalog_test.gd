extends SceneTree
# 458.2: das Spiel liest Stufe und Preis aller Gegenstaende nur aus dem Gegenstandskatalog (skripte/katalog.gd); Einzelstuecke
# sind unverkaeuflich (458.2a). Ohne Bild, Exit 0 oder 1. Vorher wie laden_test.gd (held.json, texte.json) und
# cp tools/gegenstaende/gegenstaende.json godot/daten/. Aufruf: im Ordner godot mit -s res://tests/katalog_test.gd

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll:
		fehler += 1
		print("FALSCH ", was, ": ", ist, " statt ", soll)

func _init() -> void:
	Sprache.setze("de")
	for f in ["held.json", "texte.json", "gegenstaende.json"]:
		if not FileAccess.file_exists("res://daten/" + f):
			print("KATALOG: daten/%s fehlt" % f)
			quit(1)
			return
	Sprache.lade()
	# jeder Gegenstand des Spiels steht im Katalog, mit Stufe und Preis
	var ids: Array = BrsHeld.daten()["grundformen"].keys() + Sprache.texte["dinge"].keys() + Sprache.texte["einzelstuecke"].keys()
	for id in ids:
		var e := Katalog.eintrag(String(id))
		pruefe("im Katalog " + String(id), not e.is_empty() and e.get("stufe") != null and e.get("preis") != null, true)
	# Grundformen: Stufe und Preis wie im Katalog (Startwerte 458.2a: die alten)
	for id in BrsHeld.daten()["grundformen"]:
		var b: Dictionary = BrsHeld.grundform(String(id))
		pruefe("Grundform " + String(id), [int(b["preis"]), int(b["ab_stufe"])], [Katalog.preis(String(id)), Katalog.stufe(String(id))])
	pruefe("Startwerte", [Katalog.preis("dagger"), Katalog.stufe("dagger"), Katalog.preis("plate"), Katalog.stufe("plate"), Laden.preis("potion")], [2, 1, 1500, 7, 25])
	# das Spiel liest wirklich den Katalog: eine Aenderung dort kommt im Laden und in der Beute an
	Katalog.alle["dagger"]["preis"] = 99
	Katalog.alle["dagger"]["stufe"] = 3
	Katalog.alle["potion"]["preis"] = 40
	BrsHeld.D = {}
	pruefe("Grundform aus dem Katalog", [int(Beute.grundform("dagger")["preis"]), int(Beute.grundform("dagger")["ab_stufe"])], [99, 3])
	pruefe("Ding aus dem Katalog", Laden.preis("potion"), 40)
	Katalog.alle = {}
	BrsHeld.D = {}
	# Einzelstuecke: Preis 0, bleiben beim Helden, auch beim Verkauf alles Gewoehnlichen
	var h := BrsHeld.fuer_spiel("Alrik", "Mensch", "Wachsoldat")
	var z := Zustand.new()
	var axt := {"uid": 7, "base": "greataxe", "rarity": "COMMON", "ilvl": 1, "plus": 0, "rolls": [], "unique": "greataxe_grak", "name_seed": 0}
	var dolch := {"uid": 8, "base": "dagger", "rarity": "COMMON", "ilvl": 1, "plus": 0, "rolls": [], "unique": null, "name_seed": 0}
	z.beutel.append(axt)
	z.beutel.append(dolch)
	for id in Sprache.texte["einzelstuecke"]: pruefe("unverkaeuflich " + String(id), Katalog.verkaeuflich(String(id)), false)
	pruefe("Grundform verkaeuflich", [Laden.ausruestung_verkaeuflich(dolch), Laden.ausruestung_verkaeuflich(axt)], [true, false])
	var l := Laden.new([])
	pruefe("Einzelstueck verkaufen", [l.verkaufe_ausruestung(z, h, 0), z.beutel.size(), z.gold], ["Das kann nicht verkauft werden.", 2, 0])
	pruefe("gewoehnliche", [l.verkaufe_gewoehnliches(z, h), z.beutel.size(), z.beutel[0].get("unique")], [1, 1, "greataxe_grak"])
	print("KATALOG %s: %d Fehler" % ["OK" if fehler == 0 else "FALSCH", fehler])
	quit(1 if fehler else 0)
