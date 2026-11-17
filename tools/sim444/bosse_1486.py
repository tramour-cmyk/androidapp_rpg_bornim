#!/usr/bin/env python3
"""1486 (Jerry 17.11.): sind die Bosse von Kapitel 1 zu leicht? Nur Werkzeug, kein Spielcode.

Anlass 1411.1 (Tuffy 16.11.): bei gleicher Stufe gewinnen Wachsoldat und Klosterschüler 100 % in allen 12 Begegnungen
bis Grak. Diese Rechnung misst je Herkunft und Boss die Siege je 100 in beiden Rechnern
  - heute: MARS ohne Kerben, wie das Spiel heute läuft (handgemenge.py „heute“, Ring wie ein Spieler),
  - glut2 S: Kerbensystem mit Vorschlag der Bedienung (glut2.py, heute nur in Proben an),
für Held auf Stufe des Bosses und eine darunter, und für Abwandlungen der Bosse: Leben × 1,2 / × 1,4, Stufe + 1.

Aufruf: python3 tools/sim444/bosse_1486.py [--kaempfe 1000] [--laeufe 40] [--aus DATEI.md]
"""
import argparse, os, random, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sim
import handgemenge as hg
import glut2

BOSSE = [("Krogg", 4), ("Grimmzahn", 5), ("Grak", 6)]
ABWANDLUNG = [("heute", {}), ("Leben ×1,2", {"leben": 1.2}), ("Leben ×1,4", {"leben": 1.4}), ("Stufe +1", {"stufe": 1})]


def abgewandelt(W, name, ab):
    m = dict(W["monster"][name])
    if "leben" in ab:
        m["leben"] = round(m["leben"] * ab["leben"])
    if "stufe" in ab:
        m["stufe"] = m["stufe"] + ab["stufe"]
    return m


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--kaempfe", type=int, default=1000)
    p.add_argument("--laeufe", type=int, default=40)
    p.add_argument("--aus")
    a = p.parse_args()
    HIER = os.path.dirname(os.path.abspath(__file__))
    W0 = sim.lade(os.path.join(HIER, "werte.json"))
    H = sim.lade(os.path.join(HIER, "handgemenge.json"))
    rng = random.Random(1486)
    herk = list(sim.ohne_info(W0["herkuenfte"]))
    fb = {hk: sim.fortschritt_alle(W0, hk, a.laeufe, rng, True)["fert_bei"] for hk in herk}
    zeilen = [f"# 1486 Bosse in Kapitel 1 (Jerry, `tools/sim444/bosse_1486.py`, je Zelle {a.kaempfe} Kämpfe)\n",
              "Zelle: Siege je 100 heute (MARS ohne Kerben) / glut2 S (Kerbensystem). Held allein, ohne Tränke.\n"]
    for unter in (0, 1):
        for boss, sf in BOSSE:
            zeilen.append(f"\n## {boss} (Stufe {sf}), Held Stufe {sf - unter}\n")
            zeilen.append("| Herkunft | " + " | ".join(n for n, _ in ABWANDLUNG) + " |")
            zeilen.append("|---|" + "---|" * len(ABWANDLUNG))
            for hk in herk:
                h = hg.held_bei(W0, hk, max(1, sf - unter), fb[hk])
                zellen = []
                for _, ab in ABWANDLUNG:
                    W = dict(W0); W["monster"] = dict(W0["monster"]); W["monster"][boss] = abgewandelt(W0, boss, ab)
                    q1 = hg.messe(W, H, h, boss, a.kaempfe, rng, "heute", {"ring": "spieler"})["quote"]
                    q2 = glut2.messe(W, H, h, boss, a.kaempfe, rng, {"politik": "schlag_haltung"})["quote"]
                    zellen.append(f"{round(q1 * 100)}/{round(q2 * 100)}")
                zeilen.append(f"| {hk} | " + " | ".join(zellen) + " |")
            print(f"  {boss} unter {unter} fertig", file=sys.stderr)
    text = "\n".join(zeilen) + "\n"
    if a.aus:
        open(a.aus, "w", encoding="utf-8").write(text)
    print(text)


if __name__ == "__main__":
    main()
