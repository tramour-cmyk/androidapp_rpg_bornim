# 1334: Zählung je Test, Wackeltest, Wiederholer. Aufruf: python3 tools/rotbuch_test.py (ohne Netz)
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import rotbuch as r

fehl = 0
def soll(name, ist, erwartet):
    global fehl; ok = ist == erwartet; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ist)

def lauf(i, sha, ok):
    return {"id": i, "run_number": i, "head_branch": "claude/x", "head_sha": sha * 40, "conclusion": "success" if ok else "failure", "check_suite_id": 0}
ls = [lauf(1, "a", False), lauf(2, "a", True), lauf(3, "b", False), lauf(4, "c", False)]
speicher = {"1": ["tests/wackel_1.gd"], "3": ["tests/zwei_2.gd"], "4": ["tests/zwei_2.gd", "tests/einmal_3.gd"]}
z = r.zaehlen(ls, speicher)
soll("zweimal rot", len(z["tests/zwei_2.gd"]["rot"]), 2)
soll("zweimal rot wackelt nicht", z["tests/zwei_2.gd"]["wackelt"], False)
soll("rot und grün am selben Commit wackelt", z["tests/wackel_1.gd"]["wackelt"], True)
r.bekannt = lambda t: None; r.besitzer = lambda t: "Tom"
k = {t: titel for t, _, titel in r.kandidaten(z)}
soll("Wiederholer wird Vorgang", "Wiederholrot zwei_2" in k.get("tests/zwei_2.gd", ""), True)
soll("Wackeltest wird Vorgang", "Wackeltest wackel_1" in k.get("tests/wackel_1.gd", ""), True)
soll("einmal rot bleibt ohne Vorgang", "tests/einmal_3.gd" in k, False)
sys.exit(1 if fehl else 0)
