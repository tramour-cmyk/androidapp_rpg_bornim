# 481.2 (481a A, Chef 15.11., 10:51): Leben am Ende (Anteil) und Treffer auf den Helden je Deckel, Spielweisen S (Schlag mit Haltung) und W (Warten), gleicher Zufall je Deckel, Held gleiche Stufe und eine drunter
# Aufruf: python3 tools/sim444/deckel_481_2.py (etwa 1 min); Sieg und Rundenzahl aller Zellen: glut2.py --deckel 0.5
import os, sys, random
HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER); os.chdir(HIER)
import sim, handgemenge as hg, glut2 as g2
W = sim.lade("werte.json"); H = sim.lade("handgemenge.json")
W["monster"]["Rudel"] = dict(W["monster"]["Wolf"], rudel="Jungwolf"); g2.GEGENWERT["Rudel"] = g2.GEGENWERT["Wolf"]
H["tempo_gegner"]["Rudel"] = H["tempo_gegner"]["Wolf"]
_end, _abz = sim.endschaden, sim.held_abzug
stat = {"marke": False, "t": [], "deckel": 0.0}
def abz(*a, **k): stat["marke"] = True; return _abz(*a, **k)
def end(W_, s, abzug):
    if stat["deckel"] > 0: abzug = min(abzug, stat["deckel"] * s)
    e = _end(W_, s, abzug)
    if stat["marke"]: stat["t"].append(e); stat["marke"] = False
    return e
sim.held_abzug, sim.endschaden = abz, end
rng0 = random.Random(1411)
herk = ["Wachsoldat", "Klosterschüler", "Schmiedelehrling", "Kräutersammler"]
pol = {"S": "schlag_haltung", "W": "warten"}
fb = {hk: sim.fortschritt_alle(W, hk, 25, rng0, True)["fert_bei"] for hk in herk}
faelle = dict(g2.FAELLE)
for u in (0, 1):
    print(f"\nUnterstufe {u}: Sieg je 100 / Leben am Ende in % / Treffer auf den Helden mit 0 Schaden in % / Schaden je Treffer")
    for hk in herk:
        for gg, pn in [(g, p) for g in ("Rudel", "Wolf+Goblin-Späher", "Riesenfledermaus", "Skelett", "Krogg", "Grak") for p in pol]:
            h = hg.held_bei(W, hk, max(1, faelle[gg] - u), fb[hk])
            z = []
            for d in (0.0, 0.6, 0.5, 0.4):
                stat.update(deckel=d, t=[]); rng = random.Random(1411)
                r = g2.messe(W, H, h, gg, 400, rng, {"politik": pol[pn]})
                t = stat["t"]; null = 100 * sum(1 for x in t if x <= 0) / max(1, len(t))
                z.append(f"{round(100*r['quote'])}/{round(100*(r['leben'] or 0))}/{null:.0f}/{sum(t)/max(1,len(t)):.1f}")
            print(f"{hk:17} {gg:19} {pn} " + "  |  ".join(f"{d}: {s}" for d, s in zip(("ohne", "60", "50", "40"), z)))
