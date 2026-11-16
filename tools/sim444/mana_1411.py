"""1411 (Sokrates, 16.11.): Mana von Kampf zu Kampf, Wege gegen leeres Mana.
Grundlage sim.py Teil 7 (Rast R1, 1046); Varianten per Ersatzfunktion, sim.py bleibt unverändert.
Neu rechnen: python3 tools/sim444/mana_1411.py [--laeufe 300] [--je-tag 8]"""
import argparse, random, statistics, sys, os
sys.path.insert(0, os.path.dirname(__file__))
import sim

W = sim.lade(os.path.join(os.path.dirname(__file__), "werte.json"))
ORIG_KAMPF = sim.kampf
ORIG_MANA = sim.Held.mana_max
SCHULEN = ["Evokation", "Schutzmagie", "Heilmagie"]
zaehl = {}

def mana_halbe_schule(self):
    return ORIG_MANA(self) + max(self.f(s) for s in SCHULEN) // 2

def mana_drei_je_stufe(self):
    return ORIG_MANA(self) + 3 * (self.stufe - 1)

def mache_kampf(rueck):
    def kampf(W_, held, mon, rng, **kw):
        m0 = kw.get("mana0")
        if m0 is not None and held.zauber:
            billig = min(W_["zauber"][z]["kosten"] for z in held.zauber)
            zaehl["kaempfe"] += 1
            zaehl["leer"] += m0 < billig
        r = ORIG_KAMPF(W_, held, mon, rng, **kw)
        if r["sieg"] and rueck and "mana" in r:
            mm = held.mana_max()
            plus = {"wille": held.werte["wille"], "halbwille": held.werte["wille"] / 2, "viertel": mm * 0.25}[rueck]
            r["mana"] = min(mm, r["mana"] + plus)
        return r
    return kampf

FAELLE = [("heute", None, None), ("+ halbe beste Zauberschule", mana_halbe_schule, None),
          ("+ 3 je Stufe", mana_drei_je_stufe, None), ("A: + Wille nach jedem Sieg", None, "wille"),
          ("+ halber Wille nach jedem Sieg", None, "halbwille"), ("+ 25 % nach jedem Sieg", None, "viertel"), ("A + halbe Zauberschule", mana_halbe_schule, "wille")]

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--laeufe", type=int, default=300)
    p.add_argument("--je-tag", type=int, default=8)
    a = p.parse_args()
    print(f"| Herkunft | Fall | Mana Stufe 1 | Kämpfe ohne Mana für den billigsten Zauber % | Niederlagen % | Lange Rast | Zimmer | Kämpfe bis 6 |")
    print("|---|---|---|---|---|---|---|---|")
    for hk in ("Zauberlehrling", "Klosterschüler"):
        for name, mana, rueck in FAELLE:
            sim.Held.mana_max = mana or ORIG_MANA
            sim.kampf = mache_kampf(rueck)
            zaehl.update(kaempfe=0, leer=0)
            rng = random.Random(W["lauf"]["zufallskeim"] + 1411)
            e = sim.rast_alle(W, hk, a.laeufe, rng, "R1", a.je_tag)
            m1 = sim.Held(W, hk, W["wirtschaft"]["punkte_variante"]).mana_max()
            print(f"| {hk} | {name} | {m1} | {100 * zaehl['leer'] / max(1, zaehl['kaempfe']):.1f} | {100 * e['niederlagen']:.1f} | "
                  f"{e['lang']:.1f} | {e['zimmer']:.1f} | {e['kaempfe']:.0f} |")
    sim.Held.mana_max, sim.kampf = ORIG_MANA, ORIG_KAMPF

if __name__ == "__main__":
    main()
