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
r.bekannt = lambda t: None; r.besitzer = lambda t: "Tom"
k = {t: titel for t, _, titel in r.kandidaten(z)}
soll("Wiederholer wird Vorgang", "Wiederholrot zwei_2" in k.get("tests/zwei_2.gd", ""), True)
soll("Wackeltest wird Vorgang", "Wackeltest wackel_1" in k.get("tests/wackel_1.gd", ""), True)
soll("zweimal rot auf demselben Teamzweig bleibt ohne Vorgang (Zu 1334, Tom)", "tests/alt_4.gd" in k, False)
soll("zweimal rot auf Sammelbuilds wird Vorgang", "tests/bau_5.gd" in k, True)
soll("einmal rot bleibt ohne Vorgang", "tests/einmal_3.gd" in k, False)
sys.exit(1 if fehl else 0)
