#!/usr/bin/env python3
"""1529 (Chef 17.11., 08:48, Idee zu 930): Ausdauer im Kampf. Rechnung Sokrates, nur Werkzeug, kein Spielcode.

Modell (glut2.py Option „ausdauer“):
  - Vorrat wie Entwurf 930 Regel 3, Frage 10 A: 4 + Zähigkeit + Wille + 2 je Stufe (handgemenge.json „ausdauer“), mal faktor
  - nur Vertiefen kostet: je Kerbe kosten × max(min_anteil, 1 − Fertigkeit des Tuns / teiler); Grundschlag, Haltung, Weg frei
  - reicht die Ausdauer nicht, wird nur so weit vertieft, wie sie reicht (leer: nur Grundschlag und Haltung)
  - Atem: ein Zug ohne Vertiefen gibt atem × Vorrat zurück
Vergleich je Herkunft und Fall: S (Vorschlag, nie vertiefen), W (warten), N (immer voll vertiefen) ohne und mit Ausdauer.
Maße DESIGN-GLUT.md 10: keine feste Spielweise in mehr als einem Viertel der Zellen mehr als 3 Punkte vorn; Krogg ≥ 15 (S);
Runden nicht länger als heute.
"""
import os, random, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sim
import handgemenge as hg
import glut2 as G

VARIANTEN = [
    ("ohne", None),
    ("k1.5", {"kosten": 1.5, "atem": 0.0}),
    ("k2", {"kosten": 2.0, "atem": 0.0}),
    ("k2a", {"kosten": 2.0, "atem": 0.15}),
    ("k3", {"kosten": 3.0, "atem": 0.0}),
    ("k3a", {"kosten": 3.0, "atem": 0.15}),
    ("k4a", {"kosten": 4.0, "atem": 0.15}),
    ("B6", {"kosten": 0.0, "kraftakt": 6.0, "atem": 0.0}),
    ("B8", {"kosten": 0.0, "kraftakt": 8.0, "atem": 0.0}),
]


def main():
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("--kaempfe", type=int, default=300)
    p.add_argument("--laeufe", type=int, default=25)
    p.add_argument("--unterstufe", type=int, default=0, help="Held so viele Stufen unter dem Gegner")
    a = p.parse_args()
    HIER = os.path.dirname(os.path.abspath(__file__))
    W = sim.lade(os.path.join(HIER, "werte.json"))
    H = sim.lade(os.path.join(HIER, "handgemenge.json"))
    W["monster"]["Rudel"] = dict(W["monster"]["Wolf"], rudel="Jungwolf")
    G.GEGENWERT["Rudel"] = G.GEGENWERT["Wolf"]
    H["tempo_gegner"]["Rudel"] = H["tempo_gegner"]["Wolf"]
    nl = W.get("kerbe", {}).get("vertiefen", 0.25)
    rng = random.Random(int(os.environ.get("SAAT", "1529")))
    n = a.kaempfe
    herk = list(sim.ohne_info(W["herkuenfte"]))
    fb = {hk: sim.fortschritt_alle(W, hk, a.laeufe, rng, True)["fert_bei"] for hk in herk}
    held = {(hk, sf): hg.held_bei(W, hk, max(1, sf - a.unterstufe), fb[hk]) for hk in herk for _, sf in G.FAELLE}

    print(f"Unterstufe {a.unterstufe}, je Zelle {n} Kämpfe, Vertiefen {round(nl * 100)} % je Kerbe.\n")
    print("## Vorrat und Kosten je Vertiefen-Kerbe (Kosten 2, Fertigkeit der Waffe)\n")
    print("| Herkunft | Waffe | Stufe 1: Vorrat · Fertigkeit · Kosten | Stufe 4 | Stufe 6 |\n|---|---|---|---|---|")
    for hk in herk:
        z = []
        for sf in (1, 4, 6):
            h = hg.held_bei(W, hk, sf, fb[hk])
            fw = h.f(h.waffe)
            z.append(f"{hg.ausdauer_max(H, h)} · {fw:.0f} · {2 * max(0.25, 1 - fw / 100):.2f}")
        print(f"| {hk} | {held[(hk, 1)].waffe} | " + " | ".join(z) + " |")
    print()

    def run(h, gg, opt):
        r = [G.kampf(W, H, h, gg, rng, opt) for _ in range(n)]
        sg = [x for x in r if x["sieg"]]
        return {"quote": len(sg) / n, "runden": (sum(x["runden"] for x in sg) / len(sg)) if sg else None,
                "leben": (sum(x["leben"] for x in sg) / len(sg)) if sg else None,
                "tief": sum(x["nachgelegt"] for x in r) / n, "leer": sum(x["leer"] for x in r) / n,
                "gekappt": sum(x["tief_gekappt"] for x in r) / n}

    roh = {}
    for hk in herk:
        for gg, sf in G.FAELLE:
            h = held[(hk, sf)]
            c = {"S": run(h, gg, {"politik": "schlag_haltung", "wehr_gegen_schuetzen": True}),
                 "W": run(h, gg, {"politik": "warten", "wehr_gegen_schuetzen": True})}
            for vn, vo in VARIANTEN:
                o = {"politik": "nachlegen", "nachlegen_schaden": nl, "wehr_gegen_schuetzen": True}
                if vo:
                    o["ausdauer"] = vo
                c["N_" + vn] = run(h, gg, o)
            roh[(hk, gg)] = c

    zellen = len(herk) * len(G.FAELLE)
    print("## Dominanz je Variante (beste von S, N, W mehr als 3 Punkte vorn; Ziel: keine in mehr als einem Viertel = "
          f"{zellen // 4} von {zellen})\n")
    print("| Variante | S vorn | N vorn | W vorn | gleich | Maß | N: Sieg im Mittel | N: Runden im Mittel | N: Vertiefen je Kampf | Züge leer je Kampf |")
    print("|---|---|---|---|---|---|---|---|---|---|")
    for vn, _ in VARIANTEN:
        zaehl = {"S": 0, "N": 0, "W": 0, "=": 0}
        q = []; rd = []; tf = []; lr = []
        for hk in herk:
            for gg, _ in G.FAELLE:
                c = roh[(hk, gg)]
                w = {"S": G.wert(c["S"]), "N": G.wert(c["N_" + vn]), "W": G.wert(c["W"])}
                best = max(w, key=w.get)
                zaehl["=" if w[best] - sorted(w.values())[-2] < 3 else best] += 1
                q.append(c["N_" + vn]["quote"]); tf.append(c["N_" + vn]["tief"]); lr.append(c["N_" + vn]["leer"])
                if c["N_" + vn]["runden"]:
                    rd.append(c["N_" + vn]["runden"])
        ok = max(zaehl["S"], zaehl["N"], zaehl["W"]) <= zellen / 4
        print(f"| {vn} | {zaehl['S']} | {zaehl['N']} | {zaehl['W']} | {zaehl['=']} | {'erfüllt' if ok else 'NICHT'} | "
              f"{100 * sum(q) / len(q):.0f} | {sum(rd) / len(rd):.2f} | {sum(tf) / len(tf):.1f} | {sum(lr) / len(lr):.1f} |")
    print()

    spalten = ["S", "W"] + ["N_" + v for v, _ in VARIANTEN]
    print("## Sieg je 100 (Spalten: " + " / ".join(spalten) + ")\n")
    G.tabelle("Sieg", G.FAELLE, herk, lambda hk, gg, sf: "/".join(hg.pz(roh[(hk, gg)][c_]["quote"]) for c_ in spalten))
    print("## Runden bis Sieg (gleiche Spalten)\n")
    G.tabelle("Runden", G.FAELLE, herk, lambda hk, gg, sf: "/".join(
        "–" if not roh[(hk, gg)][c_]["runden"] else f"{roh[(hk, gg)][c_]['runden']:.1f}" for c_ in spalten))
    print("## Wer vertieft wie oft bis leer (k3a: Vertiefen-Kerben je Kampf · Züge leer)\n")
    G.tabelle("k3a", G.FAELLE, herk, lambda hk, gg, sf: f"{roh[(hk, gg)]['N_k3a']['tief']:.1f}·{roh[(hk, gg)]['N_k3a']['leer']:.1f}")


if __name__ == "__main__":
    main()
