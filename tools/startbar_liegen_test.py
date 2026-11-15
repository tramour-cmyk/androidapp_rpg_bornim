# 1332: „zu testen, ohne Rückmeldung“ ist startbar, Leichen werden gefunden. Aufruf: python3 tools/startbar_liegen_test.py
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import startbar as s

fehl = 0
def soll(name, ist, erwartet):
    global fehl; ok = ist == erwartet; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ist)

liste = s.zeilen_liste()
vorlage = dict(next(d for d in liste if d["wort"] == "startbar"))
def neu(nr, stand, wort, warte=(), build="–"):
    d = dict(vorlage, nr=nr, stand=stand, wort=wort, warte=list(warte), build=build, besitzer="Jerry", zusatz="", titel="Probe " + nr, kl="M")
    return d
proben = [neu("8801", "zu testen, ohne Rückmeldung t289", "zu testen"),
          neu("8802", "zu testen", "zu testen", build="289"),
          neu("8803", "zu testen, ohne Rückmeldung t289", "zu testen", warte=["20.12."]),
          neu("8804", "wartet", "wartet"),
          neu("8805", "wartet", "wartet", warte=["8801"]),
          neu("8806", "wartet", "wartet", warte=["8804"]),
          neu("8807", "wartet", "wartet", warte=["20.12."])]
s.zeilen_liste = lambda: liste + proben
s.VORG.update({d["nr"]: d["stand"] for d in proben})
p = {d["nr"]: d for d in proben}
soll("ohne Rückmeldung ist startbar", s.sperre(p["8801"]), None)
soll("mit Build wartet auf den Chef", (s.sperre(p["8802"]) or "")[:15], "wartet auf Test")
soll("mit Termin vorgelegt", s.ohne_rueckmeldung(p["8803"]), False)
soll("im Überblick nicht „liegt bei dir“", __import__("ueberblick").wartet_auf_test(p["8801"]), False)
soll("nicht mehr OHNE BUILD", "8801" in [d["nr"] for d in s.ohne_build_zeilen("Jerry")], False)
soll("„wartet“ ohne Feld ist Leiche", s.haengt(p["8804"]), True)
soll("wartet auf startbare Zeile: keine Leiche", s.haengt(p["8805"]), False)
soll("wartet auf Leiche: Leiche", s.haengt(p["8806"]), True)
soll("wartet auf Termin: keine Leiche", s.haengt(p["8807"]), False)
sys.exit(1 if fehl else 0)
