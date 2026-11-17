#!/usr/bin/env python3
"""1533 (Chef 17.11., 08:44/08:52, Idee): Gegner ohne Zahlen, Kenntnis je Art durch Erfahrung. Rechnung Sokrates, nur Werkzeug.

Frage: wie viele Siege gegen jede Art sammelt ein Held bis zur Kapitelgrenze (sim.py Teil 1: Zufallsbegegnungen im Stufenband,
gleich verteilt über die Arten, ohne Bosse)? Daraus Schwellen für „Kenntnis +1/+2 auf die Lesestufe dieser Art“, so dass der
Durchschnitt die häufigen Arten im Kapitel auf +1 bringt, +2 nur wer länger bleibt (Grinden darf man, muss man nie).
Ausgabe: je Art Median und 10./90. Perzentil der Siege bis Stufe Kapitelgrenze, über alle Herkünfte; und der Anteil der Läufe,
die je Schwelle erreichen.
"""
import os, random, statistics, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sim

SCHWELLEN = [(5, 15), (10, 30), (8, 25)]


def lauf(W, hk, rng):
    """Wie sim.fortschritt, zählt aber Siege je Art und je Heldenstufe beim Sieg."""
    monster = {n: m for n, m in sim.ohne_info(W["monster"]).items() if not m.get("boss") and not m.get("nur_matrix")}
    fs = W["fortschritt"]
    grenze = W["held"]["kapitelgrenze"]
    held = sim.Held(W, hk, True)
    siege = {}
    n = 0
    while held.stufe < grenze and n < fs["max_kaempfe"]:
        lo = held.stufe - fs["gegner_band_unten"]; hi = held.stufe + fs["gegner_band_oben"]
        mon_name, mon = rng.choice([(nm, m) for nm, m in monster.items() if lo <= m["stufe"] <= hi])
        n += 1
        r = sim.kampf(W, held, mon, rng, lernen=True)
        if r["sieg"]:
            held.gib_ep(sim.ep_fuer(W, held, mon), "kampf"); held.nach_sieg(r["benutzt"], mon["stufe"])
            siege[mon_name] = siege.get(mon_name, 0) + 1
        held.stufe_auf()
    return siege, n


def main():
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("--laeufe", type=int, default=40)
    a = p.parse_args()
    W = sim.lade(os.path.join(os.path.dirname(os.path.abspath(__file__)), "werte.json"))
    rng = random.Random(1533)
    herk = list(sim.ohne_info(W["herkuenfte"]))
    alle = []
    kampfzahl = []
    for hk in herk:
        for _ in range(a.laeufe):
            s, n = lauf(W, hk, rng)
            alle.append(s); kampfzahl.append(n)
    arten = sorted({k for s in alle for k in s}, key=lambda k: W["monster"][k]["stufe"])
    print(f"Kapitelgrenze Stufe {W['held']['kapitelgrenze']}, {len(alle)} Läufe ({a.laeufe} je Herkunft), "
          f"Kämpfe bis zur Grenze im Median {statistics.median(kampfzahl):.0f}.\n")
    print("| Art | Stufe | Siege Median | 10 % | 90 % | " + " | ".join(f"≥{x}" for x in sorted({v for t in SCHWELLEN for v in t})) + " |")
    werte = sorted({v for t in SCHWELLEN for v in t})
    print("|---|---|---|---|---|" + "---|" * len(werte))
    for art in arten:
        z = sorted(s.get(art, 0) for s in alle)
        q = lambda f: z[min(len(z) - 1, int(f * len(z)))]
        print(f"| {art} | {W['monster'][art]['stufe']} | {statistics.median(z):.0f} | {q(0.1)} | {q(0.9)} | "
              + " | ".join(f"{100 * sum(1 for x in z if x >= v) / len(z):.0f} %" for v in werte) + " |")


if __name__ == "__main__":
    main()
