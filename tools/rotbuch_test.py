# 1334: Zählung je Test, Wackeltest, Wiederholer. Aufruf: python3 tools/rotbuch_test.py (ohne Netz)
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import rotbuch as r

fehl = 0
def soll(name, ist, erwartet):
    global fehl; ok = ist == erwartet; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ist)

def lauf(i, sha, ok, zw="claude/x"):
    return {"id": i, "run_number": i, "head_branch": zw, "head_sha": sha * 40, "conclusion": "success" if ok else "failure", "check_suite_id": 0}
ls = [lauf(1, "a", False), lauf(2, "a", True), lauf(3, "b", False), lauf(4, "c", False, "claude/y"), lauf(5, "d", False), lauf(6, "e", False), lauf(7, "f", False, "claude/build-290"), lauf(8, "g", False, "claude/build-291")]
speicher = {"1": ["tests/wackel_1.gd"], "3": ["tests/zwei_2.gd"], "4": ["tests/zwei_2.gd", "tests/einmal_3.gd"], "5": ["tests/alt_4.gd"], "6": ["tests/alt_4.gd"], "7": ["tests/bau_5.gd"], "8": ["tests/bau_5.gd"]}
z = r.zaehlen(ls, speicher)
soll("zweimal rot", len(z["tests/zwei_2.gd"]["rot"]), 2)
soll("zweimal rot wackelt nicht", z["tests/zwei_2.gd"]["wackelt"], False)
soll("rot und grün am selben Commit wackelt", z["tests/wackel_1.gd"]["wackelt"], True)
# 1392: im flachen Klon zählt der Grenz-Commit nicht, dann die Nummer im Testnamen (erst ganz, dann mit Punkt von rechts)
nrs = {"416.2": "Tom", "438": "Jerry"}; r.besitzer_von_nr = lambda n: nrs.get(n)
soll("Nummer aus Name 4162 → 416.2", r.nr_aus_name("tests/ziege_4162.gd"), "Tom")
soll("Nummer aus Name ganz", r.nr_aus_name("tests/wolf_mess_438.gd"), "Jerry")
soll("ohne Nummer im Namen", r.nr_aus_name("tests/ohne.gd"), None)
nrs.update({"399": "Perikles", "506": "Jerry", "1": "Tom", "870": "Sokrates"})
soll("1399: Mutter eines Nicht-Bauteams zählt nicht", r.nr_aus_name("tests/regel_399.gd"), None)
soll("1399: erste Zahl von links, nicht Endung _1", r.nr_aus_name("tests/anmarsch_506_1.gd"), "Jerry")
soll("1399: Endung _bild", r.nr_aus_name("tests/umzug_870_bild.gd"), None)
echt = r.subprocess.run
class A: stdout = "abc123 Sokrates: Inhaltsverzeichnis\n"
r.subprocess.run = lambda *a, **k: A(); r.grenzen = lambda: {"abc123"}; r.anleger_netz = lambda t: ""  # ohne Netz (1399)
soll("Grenz-Commit im flachen Klon zählt nicht", r.besitzer("tests/ziege_4162.gd"), "Tom")
r.grenzen = lambda: set()
soll("voller Verlauf: Anleger im Betreff", r.besitzer("tests/ziege_4162.gd"), "Sokrates")
r.subprocess.run = echt
r.bekannt = lambda t: None; r.besitzer = lambda t: "Tom"
k = {t: titel for t, _, _, titel in r.kandidaten(z)}
soll("Wiederholer wird Vorgang", "Wiederholrot zwei_2" in k.get("tests/zwei_2.gd", ""), True)
soll("Wackeltest wird Vorgang", "Wackeltest wackel_1" in k.get("tests/wackel_1.gd", ""), True)
soll("zweimal rot auf demselben Teamzweig bleibt ohne Vorgang (Zu 1334, Tom)", "tests/alt_4.gd" in k, False)
soll("zweimal rot auf Sammelbuilds wird Vorgang", "tests/bau_5.gd" in k, True)
soll("einmal rot bleibt ohne Vorgang", "tests/einmal_3.gd" in k, False)
# 1583: Rot vor der Erledigung des letzten Vorgangs zum Test zählt nicht
for l in ls: l["created_at"] = "2026-11-17T1%d:00:00Z" % l["id"]
z = r.zaehlen(ls, speicher)
r.erledigt_seit = lambda t: "2026-11-17T18:30:00Z" if "bau_5" in t else ("2026-11-17T12:30:00Z" if "zwei_2" in t else "")
k = {t: titel for t, _, _, titel in r.kandidaten(z)}
soll("1583: beide Rot vor der Erledigung, kein neuer Vorgang", "tests/bau_5.gd" in k, False)
soll("1583: Rot danach zählt weiter (zweimal nach 12:30)", "tests/zwei_2.gd" in k, True)
r.erledigt_seit = lambda t: "2026-11-17T13:30:00Z"
soll("1583: nur ein Rot nach der Erledigung, kein Vorgang", "tests/wackel_1.gd" in {t for t, _, _, _ in r.kandidaten(z)}, False)
sys.exit(1 if fehl else 0)
