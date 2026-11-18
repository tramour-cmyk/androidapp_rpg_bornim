extends SceneTree
# 1478 (1411 A, Chef 16.11., 19:32): nach jedem gewonnenen Kampf Mana + Wille / 2 (aufgerundet, höchstens bis zum Höchstwert);
# Wundsegen gestreut wie der Waffenschaden (kampf.streuung). Ohne Bild.
# Aufruf: im Ordner godot mit -s res://tests/mana_1478.gd -> „MANA1478 gut“ oder „n Fehler“

const BrsKampf = preload("res://regeln/brs_kampf.gd")

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	print(("gut  " if ok else "FEHLER ") + was)
	if not ok: fehler += 1

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	var z := Zustand.new()
	var hw := BrsHeld.fuer_spiel("Thora", "Mensch", "Zauberlehrling", z.neue_uid)
	var wille := hw.wert("wille")
	var soll := ceili(wille * 0.5)
	pruefe(is_equal_approx(float(BrsHeld.h().get("mana_nach_sieg_je_wille", 0.0)), 0.5), "werte.json held.mana_nach_sieg_je_wille = 0,5")
	hw.mana = 0
	var dazu := hw.mana_nach_sieg()
	pruefe(dazu == soll and hw.mana == soll, "Wille %d: nach dem Sieg + %d Mana (ist %d)" % [wille, soll, hw.mana])
	hw.mana = hw.max_mana() - 1
	hw.mana_nach_sieg()
	pruefe(hw.mana == hw.max_mana(), "höchstens bis zum Höchstwert (%d/%d)" % [hw.mana, hw.max_mana()])
	pruefe(float(BrsKampf.w()["kampf"].get("streuung", 0.0)) > 0.0, "Streuung für Wundsegen vorhanden (kampf.streuung)")
	print("MANA1478 %s" % ("gut" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
