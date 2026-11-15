extends SceneTree
# 1268.1 (1268 A, Chef 15.11., 10:51; Systemfrage Halt 1209): Wächter für die Fehlerart Halt. Die eine Stelle für Waffe und
# Schild in der Hand ist skripte/halt.gd (653: Griff je Gegenstand aus regeln/halt.json, Halterung je Körper, Halt.anlegen bzw.
# Halt.griff_rahmen); jeder Fehler „Waffe falsch in der Hand“ kam bisher von einer Stelle, die selbst rechnet (Zahlen je Figur).
#  1. Im Code (skripte/, kampf/, regeln/): jede Funktion, die ein Waffenmodell lädt und an einen Knochen hängt, ist Halt.anlegen,
#     rechnet über Halt., oder steht unten in AUSNAHMEN mit Grund und Vorgang. Eine neue Stelle ohne Halt ist ein Fehler, ebenso
#     eine Ausnahme, die es nicht mehr gibt (dann die Zeile streichen).
#  2. Daten: jede Waffe und jeder Schild des Katalogs mit Modell hat Maße in regeln/halt.json (sonst misst das Spiel zur Laufzeit,
#     ohne Gegenprobe); ob die Maße noch zum Modell passen, prüft halt_653 im Bau. Ohne Modelle (am Rechner) nur Teil 1.
# Nie abschalten (1268 A). Aufruf im Ordner godot: --headless -s res://tests/halt_1268.gd -> „HALT1268 n Fehler, k Stellen“

## Datei:Funktion -> warum (noch) ohne Halt
const AUSNAHMEN := {
	"kampf/figur.gd:_hold": "Kampfort hält Waffen je Gegner selbst (GRIP_CM, griff_m); Umstellung auf Halt ist 872 (Jerry)",
	"skripte/heldfigur.gd:_haenge": "Waffe und Schild auf dem Rücken: Halt kennt nur Faust und Unterarm (653)",
	"skripte/leute.gd:baue_ding": "Stab, Speer, Hammer der Leute mit altem Gerüst (griff_R aus leute_info, 348.6); Kaufkörper tragen über tragen.gd und Halt",
	"skripte/figurenprobe.gd:haenge": "Prüfwerkzeug für Bilder, nicht im Spiel",
}
const ORDNER := ["res://skripte", "res://kampf", "res://regeln"]
const LAEDT := ["daten/waffen/", "kampf/daten/%s", "Halt.datei", "WAFFEN %", "KAMPF %"]

var fehler := 0

func pruefe(ok: bool, was: String) -> void:
	if not ok:
		fehler += 1
		print("FEHLER ", was)

func _initialize() -> void:
	_lauf.call_deferred()

## Funktionen einer Datei: Name -> Rumpf
func funktionen(pfad: String) -> Dictionary:
	var r := {}
	var name := ""
	var re := RegEx.create_from_string("^(static )?func (\\w+)")
	for z in FileAccess.get_file_as_string(pfad).split("\n"):
		var m := re.search(z)
		if m:
			name = m.get_string(2)
			r[name] = ""
		elif name != "":
			r[name] += z + "\n"
	return r

func _lauf() -> void:
	# 1. Code
	var gefunden := {}
	for o in ORDNER:
		for f in DirAccess.get_files_at(o):
			if not f.ends_with(".gd"): continue
			var pfad: String = String(o).path_join(f)
			var fn: Dictionary = funktionen(pfad)
			for name in fn:
				var b := String(fn[name])
				if not "BoneAttachment3D.new()" in b: continue
				var waffe := false
				for l in LAEDT: waffe = waffe or l in b
				if not waffe: continue
				var schluessel := "%s:%s" % [pfad.trim_prefix("res://"), name]
				if pfad == "res://skripte/halt.gd" and name == "anlegen": continue   # die eine Stelle
				gefunden[schluessel] = true
				var ueber_halt := "Halt." in b
				print("STELLE %s %s" % [schluessel, "über Halt" if ueber_halt else ("Ausnahme: " + String(AUSNAHMEN[schluessel]) if AUSNAHMEN.has(schluessel) else "OHNE HALT")])
				pruefe(ueber_halt or AUSNAHMEN.has(schluessel), "%s hängt eine Waffe an einen Knochen ohne Halt (653: Halt.anlegen oder Halt.griff_rahmen)" % schluessel)
	for s in AUSNAHMEN:
		pruefe(gefunden.has(s), "Ausnahme %s gibt es nicht mehr: Zeile in AUSNAHMEN streichen" % s)

	# 2. Daten
	var ohne := 0
	for id in Katalog.lade():
		var e: Dictionary = Katalog.eintrag(id)
		if not String(e.get("art", "")) in ["waffe", "schild"]: continue
		if Halt.datei(id) == "":
			ohne += 1
			continue
		pruefe(Halt.feld().get(id) is Dictionary, "%s: Modell ohne Maße in regeln/halt.json (tests/halt_653.gd --aus=regeln/halt.json)" % id)
	if ohne > 0: print("OHNE MODELL %d Gegenstände (am Rechner ohne Bau: Teil 2 nur mit Modellen)" % ohne)
	print("HALT1268 %d Fehler, %d Stellen" % [fehler, gefunden.size()])
	quit(1 if fehler else 0)
