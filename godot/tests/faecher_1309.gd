extends SceneTree
# 1309 (Chef 15.11., 17:12/18:20, Bild Ausrüstungsseite Build 288): oberstes Feld „Kopf“ (Vitale Kapuze) halb unter der Reiterleiste,
# „Göttliche Beinschienen…“ abgeschnitten. Reiter Ausrüstung mit göttlichen Stücken (längste Namen) in allen neun Fächern, Fenster
# 1080 × 2340 (Aufruf mit --resolution 1080x2340): wie alt (GearUi.kt slotCell) im Fach nur Bild und Platz, kein abgeschnittener
# Name; die Seite passt in den Rollkasten (rollt nicht, nichts rutscht unter die Leiste); jedes Fach ganz sichtbar, keine
# übereinander. Ohne Bild, ohne Kaufmodelle. Maßgeblich ist die Zeile FAECHER1309.

const LANG := {"HEAD": "leather_cap", "CLOAK": "mantle", "CHEST": "splint", "ARMS": "gauntlets", "LEGS": "chain_leggings",
	"AMULET": "talisman", "RING": "signet", "MAIN_HAND": "warhammer", "OFF_HAND": "holy_symbol"}

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut   " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	Sprache.lade()
	Sprache.setze("de")
	var z := Zustand.new()
	z.name = "Thora"
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", BrsHeld.WANDERER, z.neue_uid)
	for pl in LANG:
		hw.ausruestung[pl] = {"uid": z.neue_uid(), "base": LANG[pl], "rarity": "DIVINE", "ilvl": 10, "rolls": [], "name_seed": 4}
	var ebene := CanvasLayer.new()
	root.add_child(ebene)
	var m := Menue.new(hw, z)
	m.reiter = "ausruestung"
	ebene.add_child(m)
	for i in 8: await process_frame
	var roll := m.rolle.get_global_rect()
	var leiste := (m.leiste as Control).get_global_rect()
	print("Rollkasten %s, Inhalt %s, Leiste bis %d" % [str(m.rolle.size), str(m.inhalt.size), int(leiste.end.y)])
	pruefe(m.inhalt.size.y <= m.rolle.size.y + 0.5, "Seite passt in den Rollkasten (Inhalt %d, Kasten %d), sie rollt nicht" % [int(m.inhalt.size.y), int(m.rolle.size.y)])
	var puppe := m.inhalt.get_child(0) as HBoxContainer
	var faecher := []
	for sp in puppe.get_children():
		if sp is VBoxContainer:
			for f in sp.get_children(): faecher.append(f as Control)
	pruefe(faecher.size() == 9, "%d Fächer (9)" % faecher.size())
	for f in faecher:
		var r: Rect2 = f.get_global_rect()
		var platz: String = (f.get_child(f.get_child_count() - 1) as Label).text
		pruefe(r.position.y >= roll.position.y - 0.5 and r.position.y >= leiste.end.y - 0.5 and r.end.y <= roll.end.y + 0.5, "%s: Fach %d–%d im Rollkasten %d–%d" % [platz, int(r.position.y), int(r.end.y), int(roll.position.y), int(roll.end.y)])
		var gekuerzt := 0
		for l in f.find_children("*", "Label", true, false):
			var lb := l as Label
			if lb.max_lines_visible > 0 and lb.get_line_count() > lb.max_lines_visible: gekuerzt += 1
		pruefe(gekuerzt == 0, "%s: kein abgeschnittener Name" % platz)
	for i in faecher.size():
		for j in range(i + 1, faecher.size()):
			var a: Rect2 = faecher[i].get_global_rect(); var b: Rect2 = faecher[j].get_global_rect()
			pruefe(not a.grow(-0.5).intersects(b.grow(-0.5)), "Fächer %d und %d nicht übereinander" % [i, j])
	print("FAECHER1309 %d Fehler" % fehler)
	quit(1 if fehler else 0)
