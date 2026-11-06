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
