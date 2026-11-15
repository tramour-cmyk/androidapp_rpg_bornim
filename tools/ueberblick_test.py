# 1313 (Sokrates 15.11., 20:05): Prüfpunkte des Überblicks. Aufruf: python3 tools/ueberblick_test.py
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import ueberblick as u

fehl = 0
def soll(name, ist, erwartet):
    global fehl; ok = ist == erwartet; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ist)

zs, kommt, test, pruef, gebaut = u.rechnen()
erste = [d for _, d, _ in kommt[:u.ANZAHL]]
soll("kein „gebaut“ in den 20", [d["nr"] for d in erste if d["wort"] == "gebaut"], [])
soll("nichts zum Testen in den 20", [d["nr"] for d in erste if u.wartet_auf_test(d)], [])
gruende = [g for _, _, g in kommt]
soll("Wartendes erst nach allem Startbaren", all(g is None for g in gruende[:gruende.index(next((g for g in gruende if g), None))]) if any(gruende) else True, True)

# Probe: die letzte startbare Zeile vorziehen („jetzt“), dann steht sie vorn
ziel = next((d for _, d, g in reversed(kommt) if g is None), None)
alt = u.s.zeilen_liste
liste = alt()
for d in liste:
    if ziel and d["nr"] == ziel["nr"]: d["titel"] += " · „jetzt“ 15.11., 20:10"
u.s.zeilen_liste = lambda: liste
_, kommt2, *_ = u.rechnen()
u.s.zeilen_liste = alt
soll("vorgezogen (%s) steht auf Rang 1" % (ziel or {}).get("nr"), kommt2[0][1]["nr"] if ziel else None, ziel["nr"] if ziel else None)
sys.exit(1 if fehl else 0)
