class_name Messung
extends RefCounted
# 399.1 (Test 139, Chef 28.10., 21:5x: „über das Gerät. Da werden nur die Gerätedaten ausgegeben und keine Testdaten wie in der alten
# Fassung“; „Wenn du was Schlaues weißt, was man noch als Testdaten erheben können, darf das gerne auch rein“): Messwerte wie alt
# (TestTab.kt deviceReadings: Blende, die 10 s danach, langsame Bilder) und dazu Ort und Stelle, Bilder je Sekunde (Schnitt,
# langsamstes 1 %), laengste Bildpause mit Ort, Ladezeit je Ort, Kampfort bereit, Grafikspeicher, Zeichenaufrufe, Rand oben und die
# letzten Fehlermeldungen aus dem Protokoll. Steht unter „Gerät zeigen …“ (System, Test) und wird mit kopiert.

const LANGSAM_MS := 50.0          # wie alt VeilMemory: Bildpausen ueber 50 ms zaehlen
const DANACH_MS := 10000          # die 10 s nach dem Ortswechsel

static var bilder: Array = []     # die letzten 600 Bildzeiten in ms
static var laengste := 0.0        # seit dem Start
static var laengste_wo := ""
static var ort := ""              # Karte und Kachel jetzt
static var laden := {}            # Karte -> ms beim letzten Betreten
static var blende_ms := -1.0      # laengste Bildpause im letzten Ortswechsel
static var gewechselt_ms := -1    # ticks, als der Ort zuletzt stand
static var danach_laengste := -1.0
static var danach_langsam := 0
static var kampf_ms := -1.0       # vom Aufruf, bis der Kampfort steht
static var _in_blende := false
static var blende_start := -1      # 555: ticks, als die Blende schwarz wurde
static var bereit_ms := -1.0       # 555 wie alt VeilMemory.readyAfterMs: von Schwarz, bis der Ort steht
# 211.14 (Rest 211.13, Sokrates 20.10.: „Leistung am A56 messen“): jeder Kampf für sich, vom Stehen des Kampforts bis zum Ende
static var kampf_wo := ""         # Gegner und Kampfort
static var kampf_bilder: Array = []   # Bildzeiten des letzten Kampfs in ms (höchstens KAMPF_MAX)
static var kampf_spitze := {}     # Höchstwerte im letzten Kampf: Zeichenaufrufe, Dreiecke, Grafikspeicher
const KAMPF_MAX := 36000          # zehn Minuten bei 60 Bildern je Sekunde

static func bild(dt: float, wo: String) -> void:
	var ms := dt * 1000.0
	ort = wo
	bilder.append(ms)
	if bilder.size() > 600: bilder.pop_front()
	if ms > laengste: laengste = ms; laengste_wo = wo
	if _in_blende: blende_ms = maxf(blende_ms, ms)
	elif gewechselt_ms >= 0 and Time.get_ticks_msec() - gewechselt_ms <= DANACH_MS:
		danach_laengste = maxf(danach_laengste, ms)
		if ms > LANGSAM_MS: danach_langsam += 1

static func blende(an: bool) -> void:
	_in_blende = an
	if an: blende_ms = 0.0; blende_start = Time.get_ticks_msec()
	else:
		gewechselt_ms = Time.get_ticks_msec(); danach_laengste = 0.0; danach_langsam = 0
		if blende_start >= 0: bereit_ms = float(gewechselt_ms - blende_start); blende_start = -1

static func geladen(karte: String, ms: float) -> void: laden[karte] = ms

static func kampf_beginn(wo: String) -> void:
	kampf_wo = wo; kampf_bilder = []; kampf_spitze = {"zeichen": 0, "dreiecke": 0, "grafik": 0.0}

static func kampf_bild(dt: float) -> void:
	if kampf_bilder.size() < KAMPF_MAX: kampf_bilder.append(dt * 1000.0)
	kampf_spitze["zeichen"] = maxi(int(kampf_spitze.get("zeichen", 0)), int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
	kampf_spitze["dreiecke"] = maxi(int(kampf_spitze.get("dreiecke", 0)), int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)))
	kampf_spitze["grafik"] = maxf(float(kampf_spitze.get("grafik", 0.0)), Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0)

## Werte des laufenden oder letzten Kampfs; leer ohne Kampf. Schnitt, langsamstes 1 %, längste Pause, Pausen über 50 ms
static func kampf_werte() -> Dictionary:
	if kampf_bilder.is_empty(): return {}
	var s := kampf_bilder.duplicate(); s.sort()
	var summe := 0.0
	var langsam := 0
	for x in s:
		summe += x
		if x > LANGSAM_MS: langsam += 1
	return {"sek": summe / 1000.0, "fps": 1000.0 * s.size() / maxf(summe, 0.1), "eins": float(s[s.size() - maxi(1, ceili(s.size() * 0.01))]),   # das schnellste der langsamsten 1 %
		"laengste": float(s[-1]), "langsam": langsam}

## die Zeile über dem Kampfort im Testmodus „Bildrate“: jetzt und seit Beginn des Kampfs
static func kampf_zeile() -> String:
	var w := kampf_werte()
	if w.is_empty(): return ""
	return "Bilder/s %d, im Kampf %.0f (langsamstes 1 %%: %.0f ms, längste %.0f ms, über 50 ms: %d)\nZeichenaufrufe %d, Dreiecke %dk" % [
		Engine.get_frames_per_second(), w["fps"], w["eins"], w["laengste"], w["langsam"],
		int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)), int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME) / 1000.0)]

static func fehler(n := 5) -> Array:
	var p := "user://logs/godot.log"
	if not FileAccess.file_exists(p): return []
	var r := []
	for z in FileAccess.get_file_as_string(p).split("\n"):
		if z.begins_with("ERROR") or z.begins_with("SCRIPT ERROR") or z.begins_with("USER ERROR"): r.append(z.substr(0, 160))
	return r.slice(maxi(0, r.size() - n))

# 555 Absturzbericht wie alt (TestTab.kt CrashBox): Godot schreibt je Lauf ein Protokoll (user://logs, die alten mit Zeit im Namen);
# das des vorigen Laufs, mit seinen Fehlern und dem Ende, zum Ansehen und Kopieren. Endete er mit einem Absturz, steht der hier zuletzt.
static func voriges_protokoll() -> String:
	var d := DirAccess.open("user://logs")
	if d == null: return ""
	var alle: Array = Array(d.get_files()).filter(func(f): return f.ends_with(".log") and f != "godot.log")
	if alle.is_empty(): return ""
	alle.sort()
	return "user://logs/" + String(alle[-1])

static func bericht(p: String, ende := 40) -> Dictionary:
	if p == "" or not FileAccess.file_exists(p): return {}
	var z := FileAccess.get_file_as_string(p).split("\n")
	var fe: Array = []
	for i in z.size():
		if z[i].begins_with("ERROR") or z[i].begins_with("SCRIPT ERROR") or z[i].begins_with("USER ERROR") or z[i].contains("Program crashed"):
			fe.append(z[i].substr(0, 200) + ((" | " + z[i + 1].strip_edges().substr(0, 160)) if i + 1 < z.size() and z[i + 1].begins_with("   at:") else ""))
	return {"datei": p.get_file(), "fehler": fe, "ende": "\n".join(z.slice(maxi(0, z.size() - ende)))}

static func zeilen(vp: Viewport = null) -> Array:
	var z := []
	var f := func(ms: float) -> String: return "–" if ms < 0.0 else "%.0f ms" % ms
	if ort != "": z.append("Ort: %s" % ort)
	if not bilder.is_empty():
		var s := bilder.duplicate(); s.sort()
		var schnitt := 0.0
		for x in s: schnitt += x
		schnitt /= s.size()
		var eins: float = s[int(s.size() * 0.99) - 1] if s.size() >= 100 else s[-1]
		z.append("Bilder je Sekunde: %.0f im Schnitt der letzten %d, langsamstes 1 %%: %.0f ms" % [1000.0 / maxf(schnitt, 0.1), s.size(), eins])
	z.append("Längste Bildpause seit dem Start: %s%s" % [f.call(laengste if not bilder.is_empty() else -1.0), (" (%s)" % laengste_wo) if laengste_wo != "" else ""])
	z.append("Blende: bereit nach %s, längste Bildpause %s; danach 10 s: längste %s, über 50 ms: %s" % ["–" if bereit_ms < 0.0 else "%.1f s" % (bereit_ms / 1000.0), f.call(blende_ms), f.call(danach_laengste), str(danach_langsam) if danach_laengste >= 0.0 else "–"])
	if not laden.is_empty(): z.append("Ladezeit je Ort: " + ", ".join(PackedStringArray(laden.keys().map(func(k): return "%s %.0f ms" % [k, laden[k]]))))
	z.append("Kampfort bereit nach: %s" % ("–" if kampf_ms < 0.0 else "%.1f s" % (kampf_ms / 1000.0)))
	var kw := kampf_werte()
	if not kw.is_empty(): z.append("Letzter Kampf (%s): %.0f s, Bilder je Sekunde %.0f im Schnitt, langsamstes 1 %%: %.0f ms, längste Bildpause %.0f ms, über 50 ms: %d; höchstens %d Zeichenaufrufe, %dk Dreiecke, Grafikspeicher %.0f MB" % [
		kampf_wo, kw["sek"], kw["fps"], kw["eins"], kw["laengste"], kw["langsam"], int(kampf_spitze["zeichen"]), int(kampf_spitze["dreiecke"] / 1000.0), float(kampf_spitze["grafik"])])
	z.append("Grafikspeicher: %.0f MB, Zeichenaufrufe: %d, Dreiecke: %dk" % [Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0,
		int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)), int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME) / 1000.0)])
	if vp: z.append("Rand oben (Kamera): %.0f, beim Start %.0f; sichere Fläche %s, Fenster %s, Ausschnitt %s" % [Rand.oben(vp), Rand.beim_start,
		DisplayServer.get_display_safe_area(), DisplayServer.window_get_size(), DisplayServer.get_display_cutouts()])   # 399.4: warum fehlt er (t143)?
	var g: Dictionary = Stil.geraet   # 498: Schriftgroesse und Dichte des Handys (die alte Fassung folgte beiden)
	z.append("Schrift: Faktor des Handys %.2f, Dichte %s, Breite %s" % [Stil.schriftfaktor, "%.3f" % g["dichte"] if g.has("dichte") else "–", "%.0f dp" % g["breite_dp"] if g.has("breite_dp") else "–"])
	var fe := fehler()
	z.append("Letzte Fehlermeldungen: " + ("keine" if fe.is_empty() else ""))
	for x in fe: z.append("  " + x)
	return z

# 1021 wie alt CrashLog.exitReason (Kotlin, 30.1): warum Android den vorigen Lauf beendet hat (ApplicationExitInfo, ab Android 11),
# ueber AndroidRuntime und JavaClassWrapper wie stil.gd. {"grund": Zahl, "text", "zeit": ms, "pss_mb", "rss_mb", "wichtigkeit"}; am Rechner,
# vor Android 11 oder ohne Antwort {}. Einmal je Lauf gefragt (die Antwort aendert sich erst mit dem naechsten Ende).
const ENDE_TEXT := {3: ["Speicher knapp, vom System beendet", "low memory, ended by the system"], 4: ["Absturz", "crash"],
	5: ["Absturz in nativem Code", "native crash"], 6: ["reagierte nicht (ANR)", "not responding (ANR)"], 2: ["vom System beendet (Signal)", "ended by the system (signal)"],
	9: ["zu viel Verbrauch", "excessive resource usage"], 10: ["vom Nutzer beendet", "ended by the user"], 11: ["vom Nutzer gestoppt", "stopped by the user"],
	1: ["selbst beendet", "exited itself"], 12: ["Abhängigkeit beendet", "dependency died"], 8: ["Berechtigung geändert", "permission changed"],
	7: ["Start fehlgeschlagen", "initialization failure"], 13: ["anderer Grund (vom System)", "other (system)"], 14: ["eingefroren und beendet", "frozen and ended"],
	15: ["App aktiviert oder deaktiviert", "app enabled or disabled"], 16: ["App aktualisiert", "app updated"]}
static var _ende = null

static func letztes_ende() -> Dictionary:
	if _ende == null: _ende = _frage_ende()
	return _ende

static func _frage_ende() -> Dictionary:
	if OS.get_name() != "Android" or not Engine.has_singleton("AndroidRuntime"): return {}
	var v := int(OS.get_version().get_slice(".", 0))
	if v > 0 and v < 11: return {}
	var rt = Engine.get_singleton("AndroidRuntime")
	var ctx = rt.getApplicationContext() if rt else null
	var am = ctx.getSystemService("activity") if ctx else null
	if am == null: return {}
	var liste = am.getHistoricalProcessExitReasons(ctx.getPackageName(), 0, 1)
	var info = null
	if liste is Array: info = liste[0] if liste.size() > 0 else null
	elif liste is Object and liste != null and int(liste.size()) > 0:
		var a = liste.toArray()
		info = a[0] if a is Array and a.size() > 0 else null
	if info == null: return {}
	var e := {"grund": int(info.getReason()), "zeit": int(info.getTimestamp()), "pss_mb": int(info.getPss()) / 1024, "rss_mb": int(info.getRss()) / 1024,
		"wichtigkeit": int(info.getImportance()), "signal": int(info.getStatus())}
	var b = info.getDescription()
	e["beschreibung"] = String(b) if b is String else ""
	print("1021 Ende laut System: ", e)
	return e

## Eine Zeile wie alt: „12.11. 08:14: Speicher knapp, vom System beendet“, dazu Beschreibung und Speicher beim Ende; ohne Antwort „–“
static func ende_text(e: Dictionary, de := true) -> String:
	if e.is_empty(): return "–"
	var g := int(e["grund"])
	var w: String = ENDE_TEXT[g][0 if de else 1] if ENDE_TEXT.has(g) else ("anderer Grund (%d)" % g if de else "other (%d)" % g)
	if g == 2: w += " %d" % int(e.get("signal", 0))
	var d := Time.get_datetime_dict_from_unix_time(int(e["zeit"]) / 1000 + int(Time.get_time_zone_from_system().get("bias", 0)) * 60)
	var s := "%02d.%02d. %02d:%02d: %s" % [d["day"], d["month"], d["hour"], d["minute"], w]
	if String(e.get("beschreibung", "")) != "": s += "\n" + String(e["beschreibung"])
	return s + ("\nSpeicher beim Ende: PSS %d MB, RSS %d MB, Wichtigkeit %d" if de else "\nMemory at end: PSS %d MB, RSS %d MB, importance %d") % [int(e["pss_mb"]), int(e["rss_mb"]), int(e["wichtigkeit"])]
