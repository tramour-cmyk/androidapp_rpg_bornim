extends SceneTree
# 416.4 (Chef 31.10., Build 143: „als würde er Hochsprung machen“; 01.11., 11:28 „neuer Film“ mit heute, A, B): Messung ohne Bild am
# Kaufkoerper, wie er im Spiel laeuft (heldfigur.gd RENNEN_ARTEN, Kaempfer): je Fassung Laenge der Schleife, Schritte je Sekunde und
# Schrittlaenge im Spiel (Rennen 3,68 Kacheln/s), Hub des Beckens, Anteil ohne Fuss am Boden, wie tief ein Ballen unter den Tiefstand
# von heute sinkt. Fehler: Ballen mehr als 1 cm unter dem Boden, A oder B nicht flacher oder nicht schneller im Schritt als heute.
# Aufruf im Ordner godot, Testprogramm ohne Bild (braucht daten/held_FIGHTER.bin, bewegungen.bin, held-klassen.json; tom-probe-4164.yml)

const RENN := 3.68 * 1.16

func _initialize() -> void: _lauf.call_deferred()

func _lauf() -> void:
	if not HeldFigur.da("FIGHTER"): print("FEHLER Kaufkoerper fehlt"); quit(1); return
	var fehler := 0
	var heute := {}
	var boden0 := 0.0
	for art in HeldFigur.RENNEN_ARTEN:
		var z := Zustand.new()
		var w := HeldFigur.wahl(BrsHeld.fuer_spiel("Probe", "Mensch", "Wachsoldat", z.neue_uid), z)
		w["rennen"] = art
		w["ausruestung"] = {}
		var m := HeldFigur.baue(w, [])
		var ap := Gebiet.finde(m, "AnimationPlayer") as AnimationPlayer
		var a := ap.get_animation("Rennen")
		var f := float(m.get_meta("massstab", 1.0))   # Groesse Figur/UAL (416.4: rennen_m_je_s ist jetzt umgetaktet)
		var quelle: Animation = HeldFigur.renn_lib[art] if HeldFigur.renn_lib.has(art) else HeldFigur.bew_lib.get_animation("Rennen")
		var h := HeldFigur.renn_hoehen(quelle, HeldFigur.bew_sk, HeldFigur.bew_raum)
		var tl: float = h["l"].min(); var tr: float = h["r"].min()
		var tief := minf(tl, tr)
		if art == "heute": boden0 = tief
		var luft := 0.0   # Anteil der Zeit (Lauf 1 zaehlte Bilder; nach dem Umformen sind die Bilder ohne Boden kuerzer)
		for i in h["zeit"].size() - 1:
			if h["l"][i] > tl + 0.02 and h["r"][i] > tr + 0.02: luft += float(h["zeit"][i + 1]) - float(h["zeit"][i])
		var fach := RENN / maxf(0.001, float(m.get_meta("rennen_m_je_s")))
		var sps := 2.0 / a.length * fach
		var r := {"laenge": a.length, "sps": sps, "schritt": RENN / sps, "hub": (float(h["becken"].max()) - float(h["becken"].min())) * f,
			"luft": int(luft * 100.0 / maxf(0.001, float(h["zeit"][-1]))), "unter": (boden0 - tief) * f,
			"sohle": maxf(float(h["l"].max()) - tl, float(h["r"].max()) - tr) * f}
		print("RENNEN %s: Schleife %.2f s (%d Bilder), im Spiel %.2f-fach, %.1f Schritte/s zu %.2f m, Beckenhub %.1f cm, ohne Boden %d %%, Ballen hoechstens %.0f cm, unter dem Boden %.1f cm" % [
			art, r["laenge"], h["zeit"].size() - 1, fach, r["sps"], r["schritt"], r["hub"] * 100, r["luft"], r["sohle"] * 100, r["unter"] * 100])
		if r["unter"] > 0.01: fehler += 1; print("FEHLER %s: Ballen %.1f cm unter dem Boden" % [art, r["unter"] * 100])
		if art == "heute": heute = r
		elif r["hub"] >= heute["hub"] or r["sps"] <= heute["sps"]: fehler += 1; print("FEHLER %s nicht flacher oder nicht schneller als heute" % art)
		m.free()
	print("RENNEN4164 ", "gut" if fehler == 0 else "%d Fehler" % fehler)
	quit(1 if fehler > 0 else 0)
