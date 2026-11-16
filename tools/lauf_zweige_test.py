# 1396: Zweige laufender Sitzungen sind für den Zusatzentwickler belegt. Aufruf: python3 tools/lauf_zweige_test.py
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import lauf
fehl = 0
def soll(name, ist, erwartet):
    global fehl; ok = ist == erwartet; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ist)
s = [{"external_metadata": {"current_branches": {"": "claude/build-292"}}}, {"external_metadata": {"current_branches": {"": "main"}}},
     {"external_metadata": {"current_branches": {"": "refs/heads/claude/jerry-709"}}}, {}, {"external_metadata": None}]
soll("Zweige laufender Sitzungen ohne main", lauf.sitzungszweige(s), {"claude/build-292", "claude/jerry-709"})
soll("keine Sitzung", lauf.sitzungszweige([]), set())
sys.exit(1 if fehl else 0)
