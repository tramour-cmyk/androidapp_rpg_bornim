"""1603 (Entscheid Sokrates 23.11., 22:08, B): Krogg mit Morgenstern 2 : Prankenhieb 1, Zusatz z des Prankenhiebs,
Ring nie, gut (halber Schaden), perfekt (keiner), halb gut (jeder zweite Prankenhieb gut); SHARE wie mars.gd. Vergleich
mit heute (nur Stich), Siege in % je Herkunft und Heldenstufe. Nur Rechnung, keine Aenderung am Spiel.
   python3 tools/sim444/rechnung_1603.py tools/sim444 200 0.82,0.4,0.1,0"""
import inspect, random, sys
sys.path.insert(0, sys.argv[1])
import sim

W = sim.lade(sys.argv[1] + "/werte.json")
N = int(sys.argv[2])
ZS = [float(x) for x in sys.argv[3].split(",")]
GRENZE = 7
CFG = {"p": 0.0, "f": lambda rng: 1.0}
src = inspect.getsource(sim.kampf)
alt = 'elif auf_held(mon["angriff"], mon["schaden"]):'
assert alt in src
src = src.replace(alt, 'elif auf_held(mon["angriff"], mon["schaden"], CFG["f"](rng) if rng.random() < CFG["p"] else 1.0):')
ns = sim.__dict__
ns["CFG"] = CFG
exec(src, ns)
kampf = ns["kampf"]
RING = {"nie": lambda z: lambda rng: 1 + z, "gut": lambda z: lambda rng: (1 + z) * 0.5,
        "perfekt": lambda z: lambda rng: 0.0, "halb gut": lambda z: lambda rng: (1 + z) * (0.5 if rng.random() < 0.5 else 1.0)}
mon = W["monster"]["Krogg"]
zeilen = {}
for hk in sim.ohne_info(W["herkuenfte"]):
    fo = sim.fortschritt_alle(W, hk, W["lauf"]["fortschritt_laeufe"], random.Random(W["lauf"]["zufallskeim"] + 1), True)
    for s in W["lauf"]["stufen"]:
        h = sim.held_auf_stufe(W, hk, s, fo["fert_bei"].get(s) or fo["fert_bei"][max(fo["fert_bei"])], True)

        def q(p, f):
            CFG["p"], CFG["f"] = p, f
            rng = random.Random(160300 + s)
            return 100 * sum(kampf(W, h, mon, rng)["sieg"] for _ in range(N)) / N
        z = {"heute": q(0, lambda rng: 1.0)}
        for zz in ZS:
            for r, f in RING.items():
                z[(zz, r)] = q(1 / 3, f(zz))
        zeilen[(hk, s)] = z
print(f"Krogg, N = {N} je Fall, Grenze {GRENZE} Punkte; groesste Abweichung von heute ueber 8 Herkuenfte x 6 Stufen\n")
print("| Zusatz | Ring | groesste Abweichung | bei | heute → neu | haelt |")
print("|---|---|---|---|---|---|")
for zz in ZS:
    for r in RING:
        (hk, s), z = max(zeilen.items(), key=lambda kv: abs(kv[1][(zz, r)] - kv[1]["heute"]))
        d = z[(zz, r)] - z["heute"]
        print(f"| {zz:.2f} | {r} | {d:+.1f} | {hk} {s} | {z['heute']:.1f} → {z[(zz, r)]:.1f} | {'ja' if abs(d) <= GRENZE else 'nein'} |")
