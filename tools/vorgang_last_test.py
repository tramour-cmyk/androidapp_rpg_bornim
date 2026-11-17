# 1604: Warnung beim Verteilen an Tom oder Jerry, wenn Spike oder Tuffy leer stehen. Aufruf: python3 tools/vorgang_last_test.py
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import vorgang
s = vorgang.startbar
s.lesen = lambda p: ""; s.uebernahmen = lambda r: []
PLAN = {}
s.plan = lambda r: PLAN.get(r, [])
def m(nr, zweig="–", grund=None, kl="M", titel="x"): return (nr, kl, titel, {"zweig": zweig, "stand": "startbar"}, grund)
fehl = 0
def soll(name, ist, erwartet):
    global fehl; ok = ist == erwartet; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ist)
PLAN = {"Spike": [], "Jerry": [m("1")]}
soll("Tom: Spike leer, Tuffy ohne zweites", vorgang.leere_entwickler("Tom"), ["Spike", "Tuffy"])
soll("Jerry: nur Spike (neue Zeile ist Tuffys)", vorgang.leere_entwickler("Jerry"), ["Spike"])
soll("Homer: nie", vorgang.leere_entwickler("Homer"), [])
PLAN = {"Spike": [m("2")], "Jerry": [m("1", "z1"), m("3", "z1"), m("4")]}
soll("alle haben Arbeit", vorgang.leere_entwickler("Tom"), [])
PLAN = {"Spike": [m("2", grund="wartet auf 9")], "Jerry": [m("1", "z1"), m("3", "z1")]}
soll("gesperrt zählt nicht, gleicher Zweig nicht unabhängig", vorgang.leere_entwickler("Tom"), ["Spike", "Tuffy"])
PLAN = {"Spike": [m("2", kl="K")], "Jerry": [m("1"), m("3", titel="nur Jerry")]}
soll("Kür zählt nicht, „nur Jerry“ nicht für Tuffy", vorgang.leere_entwickler("Tom"), ["Spike", "Tuffy"])
s.uebernahmen = lambda r: [("5", "t", "Tom", False)]
soll("Übernahme gibt Spike Arbeit", vorgang.leere_entwickler("Jerry"), [])
t = vorgang.leer_text("9", "Tom", ["Spike", "Tuffy"])
soll("Text nennt beide Wege", "besitzer=Spike" in t and "besitzer=Jerry" in t and "341" in t, True)
sys.exit(fehl)
