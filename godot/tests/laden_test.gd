extends SceneTree
# 390: Gegenprobe Laden (skripte/laden.gd) gegen Game.buy/sell/buyBack/brew und Perks: Faelle mit den Zahlen des alten Spiels.
# Ohne Bild, Exit 0 oder 1. Vorher wie rast_test.gd (held.json, texte.json). Aufruf: im Ordner godot mit -s res://tests/laden_test.gd

var fehler := 0

func pruefe(was: String, ist, soll) -> void:
	if ist != soll:
		fehler += 1
		print("FALSCH ", was, ": ", ist, " statt ", soll)

func _init() -> void:
	Sprache.setze("de")
	if not FileAccess.file_exists("res://daten/held.json") or not FileAccess.file_exists("res://daten/texte.json"):
		print("LADEN: daten/held.json oder texte.json fehlt")
		quit(1)
		return
	var h := Heldwerte.erschaffe("Alrik", "HUMAN", "FIGHTER")
	h.basis["CHA"] = 10   # Mod 0: Listenpreis
	var z := Zustand.new()
	var l := Laden.new(["potion", "remedy"])
	pruefe("Preis Heiltrank", [Laden.preis("potion"), Laden.kaufpreis(h, "potion"), Laden.verkaufspreis(h, "potion")], [25, 25, 12])
	z.gold = 60
	pruefe("kann kaufen", Laden.kann_kaufen(z, h, "potion"), 2)
	pruefe("kaufen 2", l.kaufe(z, h, "potion", 2), "Heiltrank ×2 gekauft.")
	pruefe("Gold nach Kauf", [z.gold, z.anzahl("potion")], [10, 2])
	pruefe("zu teuer", l.kaufe(z, h, "potion"), "Du hast nicht genug Gold.")
	pruefe("null", l.kaufe(z, h, "potion", 0), "Nichts")
	# Charisma 18 (+4): 20 % billiger, 20 % mehr beim Verkauf; Charisma 3 (-4): teurer, weniger
	h.basis["CHA"] = 18
	pruefe("CHA 18", [Laden.kaufpreis(h, "potion"), Laden.verkaufspreis(h, "potion")], [20, 14])
	h.basis["CHA"] = 3
	pruefe("CHA 3", [Laden.kaufpreis(h, "potion"), Laden.verkaufspreis(h, "potion")], [30, 10])
	h.basis["CHA"] = 10
	# verkaufen, Rueckkauf zum erzielten Preis, hoechstens fuenf, neueste zuerst
	pruefe("verkaufen", l.verkaufe(z, h, "potion"), "Heiltrank verkauft.")
	pruefe("Gold nach Verkauf", [z.gold, z.anzahl("potion"), l.rueckkauf], [22, 1, [{"ding": "potion", "anzahl": 1, "preis": 12}]])
	pruefe("nicht da", l.verkaufe(z, h, "remedy"), "Das kann nicht verkauft werden.")
	pruefe("zurueck", l.zurueck(z, 0), "Heiltrank gekauft.")
	pruefe("nach Rueckkauf", [z.gold, z.anzahl("potion"), l.rueckkauf.size()], [10, 2, 0])
	z.dazu("herbs", 7)
	for i in 6: l.verkaufe(z, h, "herbs")
	pruefe("fuenf behalten", [l.rueckkauf.size(), z.anzahl("herbs")], [5, 1])
	# Schluessel nie verkaeuflich
	var schluessel := ""
	for id in Sprache.texte["dinge"]:
		if String(Sprache.texte["dinge"][id]["art"]) == "KEY": schluessel = String(id); break
	if schluessel != "":
		z.dazu(schluessel)
		pruefe("Schluessel", [Laden.verkaeuflich(schluessel), l.verkaufe(z, h, schluessel)], [false, "Das kann nicht verkauft werden."])
	# Morwen braut: 2 Kraeuter und 5 Gold ein Heiltrank; mit Intelligenz manchmal zwei
	var m := Zustand.new()
	var r: Dictionary = Laden.rezepte()[0]
	pruefe("Rezept", [r["ergebnis"], Laden.kosten(r)], ["potion", "2× Heilkräuter, 5 Gold"])
	pruefe("fehlt", Laden.new([], true).braue(m, h, r, 0.99), "Dafür fehlen dir Zutaten oder Gold.")
	m.gold = 12; m.dazu("herbs", 4)
	pruefe("brauen", Laden.new([], true).braue(m, h, r, 0.99), "Morwen braut dir: Heiltrank.")
	pruefe("nach Brauen", [m.gold, m.anzahl("herbs"), m.anzahl("potion")], [7, 2, 1])
	h.basis["INT"] = 18   # +4: 40 %
	pruefe("zwei", Laden.new([], true).braue(m, h, r, 0.39), "Mit deinem Wissen holt ihr zwei Tränke heraus: 2× Heiltrank.")
	pruefe("nach zwei", [m.gold, m.anzahl("herbs"), m.anzahl("potion")], [2, 0, 3])
	print("LADEN %s: %d Fehler" % ["OK" if fehler == 0 else "FALSCH", fehler])
	quit(1 if fehler else 0)
