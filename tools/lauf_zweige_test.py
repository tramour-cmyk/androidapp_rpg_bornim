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
# 1407: frisch gepushte Zweige des Teams und Sammelbuilds sind belegt, alte und fremde nicht
j = lauf.JETZT.timestamp()
refs = [(j - 600, "claude/jerry-1340-ragdoll"), (j - 1200, "claude/build-292"), (j - 600, "claude/tom-531-film"), (j - 7200, "claude/jerry-517-waldklang")]
soll("frische Jerry-Zweige", lauf.frische_zweige("Jerry", refs), {"claude/jerry-1340-ragdoll", "claude/build-292"})
soll("nichts Frisches", lauf.frische_zweige("Jerry", [(j - 7200, "claude/jerry-1")]), set())
sys.exit(1 if fehl else 0)
