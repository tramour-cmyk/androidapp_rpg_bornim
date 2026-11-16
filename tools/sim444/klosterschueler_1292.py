# 1292 (481.2 A, Chef 15.11., 12:44): warum der Klosterschüler nie verliert. Gegenproben an Wundsegen (ohne, höchstens 1 / 2 je Kampf,
# halbe Heilung), Zwilling Schmiedelehrling (gleiche Waffe und Rüstung, ohne Heilung) und Gebet des alten Kampfs (mars.gd _perfect_answer).
# Spielweise S (Vorschlag der Bedienung), gleicher Zufall je Spalte; Deckel 50 % aus werte.json.
# Aufruf: python3 tools/sim444/klosterschueler_1292.py [--kaempfe 400] (etwa 2 min)
import os, sys, random, argparse
HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER); os.chdir(HIER)
import sim, handgemenge as hg, glut2 as g2
p = argparse.ArgumentParser(); p.add_argument("--kaempfe", type=int, default=400); p.add_argument("--politik", default="schlag_haltung")
a = p.parse_args()
W = sim.lade("werte.json"); H = sim.lade("handgemenge.json")
W["monster"]["Rudel"] = dict(W["monster"]["Wolf"], rudel="Jungwolf"); g2.GEGENWERT["Rudel"] = g2.GEGENWERT["Wolf"]
H["tempo_gegner"]["Rudel"] = H["tempo_gegner"]["Wolf"]
rng0 = random.Random(1411)
fb = {hk: sim.fortschritt_alle(W, hk, 25, rng0, True)["fert_bei"] for hk in ("Klosterschüler", "Schmiedelehrling", "Wachsoldat")}
import copy
W10 = copy.deepcopy(W); W10["zauber"]["Wundsegen"]["kosten"] = 10                 # doppelte Kosten: 4 statt 8 Segen aus 40 Mana
V = [("heute", "Klosterschüler", {}), ("Kosten 10", "Klosterschüler", {"W": W10}), ("ohne", "Klosterschüler", {"wundsegen_max": 0}),
     ("≤1", "Klosterschüler", {"wundsegen_max": 1}), ("≤2", "Klosterschüler", {"wundsegen_max": 2}), ("≤3", "Klosterschüler", {"wundsegen_max": 3}),
     ("halb", "Klosterschüler", {"wundsegen_faktor": 0.5}), ("Schmied", "Schmiedelehrling", {}),
     ("Wachsoldat", "Wachsoldat", {}), ("+Gebet", "Klosterschüler", {"gebet": True})]
print(f"Spielweise {a.politik}, je Zelle {a.kaempfe} Kämpfe, Deckel {W['kampf'].get('abzug_deckel')}")
print("Zelle: Sieg % · Leben am Ende % · Wundsegen je Kampf · geheilt in Leben (1 = einmal volles Leben)")
for u in (0, 1, 2):
    print(f"\n## Held {u} Stufe(n) unter dem Fall\n")
    print("| Gegner | " + " | ".join(v[0] for v in V) + " |"); print("|" + "---|" * (len(V) + 1))
    for gg, sf in g2.FAELLE:
        z = []
        for name, hk, o in V:
            h = hg.held_bei(W, hk, max(1, sf - u), fb[hk])
            r = g2.messe(o.get("W", W), H, h, gg, a.kaempfe, random.Random(1411), dict(o, politik=a.politik))
            z.append(f"{round(100 * r['quote'])} · {round(100 * (r['leben'] or 0))} · {r['wundsegen']:.1f} · {r['geheilt']:.1f}")
        print(f"| {gg} {max(1, sf - u)} | " + " | ".join(z) + " |")

# Kette ohne Rast: vier Kämpfe hintereinander, Leben und Mana tragen sich fort (im Spiel füllt erst die nächste Stufe beides, lohn.gd)
KETTE = ["Rudel", "Wolf+Goblin-Späher", "Riesenfledermaus", "Riesenspinne"]
print(f"\n## Kette ohne Rast ({' → '.join(KETTE)}), Held Stufe 2 und 3: ganze Kette überstanden % · Leben danach % · Mana danach\n")
print("| Held | " + " | ".join(v[0] for v in V) + " |"); print("|" + "---|" * (len(V) + 1))
for st_h in (2, 3):
    z = []
    for name, hk, o in V:
        h = hg.held_bei(W, hk, st_h, fb[hk]); rng = random.Random(1411); ok = 0; lb = []; mb = []
        for _ in range(a.kaempfe):
            rest = (h.leben_max(), h.mana_max())
            for gg in KETTE:
                r = g2.kampf(o.get("W", W), H, h, gg, rng, dict(o, politik=a.politik, start=rest))
                if not r["sieg"]: break
                rest = r["rest"]
            else:
                ok += 1; lb.append(rest[0] / h.leben_max()); mb.append(rest[1])
        z.append(f"{round(100 * ok / a.kaempfe)} · {round(100 * sum(lb) / max(1, len(lb)))} · {sum(mb) / max(1, len(mb)):.0f}")
    print(f"| Stufe {st_h} | " + " | ".join(z) + " |")
