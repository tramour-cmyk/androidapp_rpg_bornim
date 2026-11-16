#!/usr/bin/env python3
"""1411.1 (Sokrates 16.11., Chef 18:27–18:37): Merkmale je Exemplar (jung, alt, kräftig, angeschlagen, rostige Waffe …) und Lesen der
Merkmale über die Lesestufe, gerechnet mit dem Glut-Rechner Fassung 2 (glut2.py, Politik S). Nur Werkzeug, kein Spielcode.

Annahmen (Entwurf Sokrates, keine Regel; MERKMALE unten): je Exemplar höchstens ein Merkmal, 50 % gewöhnlich, sonst gleich verteilt;
Bosse fest; Ockerschleim ohne Merkmal (weder Tier noch Waffenträger). Lesestufe der Merkmale wie die der Ansage (DESIGN-GLUT.md 5):
0 nichts, 1 Pfeil stärker/schwächer, 2 Name (Richtung bekannt, Größe geschätzt mit SCHAETZ), 3 Name und Wirkung (genau).
Der Held sieht immer den Lebensbalken als Anteil, nie die Lebenszahl.

Fragen:
  (1) Endschaden nach Streuung ±20 %, Rundung und Rüstung: wie viele verschiedene Zahlen, häufigste in %
  (2) Siege je 100 und Runden mit Merkmalen gegen heute (alle Fälle von glut2, Lesestufe nach Formel)
  (3) Lesen 0→3 der Merkmale in Begegnungen mit mehreren Gegnern, Held wählt zuerst das schwächste bzw. gefährlichste Ziel
Dazu (Rest aus 481): Wachsoldat 100 %? Heiler wächst nie?

Aufruf: python3 tools/sim444/merkmale_1411.py [--kaempfe 2000] [--laeufe 25] > ergebnis.md
"""
import argparse, collections, os, random, statistics, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sim
import handgemenge as hg
import glut2

TIERE = {"Riesenratte", "Wolf", "Jungwolf", "Wildschwein", "Riesen-Hundertfüßer", "Riesenspinne", "Riesenfledermaus", "Blutflügler"}
WAFFENTRAEGER = {"Skelett", "Zombie", "Ghul", "Goblin", "Goblin-Späher", "Goblin-Schamane", "Kobold"}
# Faktoren je Merkmal: leben, angriff (Treffwert), abwehr, schaden
MERKMALE = {
    "tier": {"jung": {"leben": 0.85, "angriff": 0.90, "abwehr": 1.10}, "alt": {"leben": 0.90, "angriff": 0.90},
             "kräftig": {"leben": 1.15, "schaden": 1.15}, "angeschlagen": {"leben": 0.70}},
    "waffe": {"rostige Waffe": {"schaden": 0.75}, "gute Waffe": {"schaden": 1.20},
              "brüchig": {"leben": 0.80}, "zäh": {"leben": 1.20}},
}
GEWOEHNLICH = 0.5
SCHAETZ = 0.15          # Stufe 2: Richtung bekannt, Größe geschätzt
_ZUFALL = random.Random(1411)


def gruppe(name):
    return "tier" if name in TIERE else ("waffe" if name in WAFFENTRAEGER else None)


def staerke(m):
    """Pfeil der Stufe 1: Summe der Abweichungen (Leben und Schaden voll, Angriff und Abwehr halb)."""
    w = {"leben": 1.0, "schaden": 1.0, "angriff": 0.5, "abwehr": 0.5}
    return sum((f - 1.0) * w[k] for k, f in m.items())


def exemplar_fn(an=True, mal=1.0, meiden=False):
    """mal: Abweichungen der Merkmale vervielfacht (Gegenprobe „doppelt“); meiden: stärkere Exemplare kommen nicht (der Held
    sieht sie vorher und weicht aus, Obergrenze dessen, was Lesen außerhalb des Kampfs bringen kann)."""
    def fn(feld, rng):
        for g in feld:
            g.merkmal = None; g.mfak = {}
            nm = g.koerper if g.herr else g.name
            g.basis_leben, g.basis_schaden, g.basis_angriff = g.leben, g.schaden, g.angriff
            gr = gruppe(nm)
            if not an or g.boss or gr is None or rng.random() < GEWOEHNLICH:
                continue
            name = rng.choice(sorted(MERKMALE[gr]))
            m = {k: 1.0 + (f - 1.0) * mal for k, f in MERKMALE[gr][name].items()}
            if meiden and staerke(m) > 0:
                continue
            g.merkmal = name; g.mfak = m
            g.leben = max(1, round(g.leben * m.get("leben", 1.0)))
            g.angriff = g.angriff * m.get("angriff", 1.0)
            g.abwehr = g.abwehr * m.get("abwehr", 1.0)
            g.schaden = g.schaden * m.get("schaden", 1.0)
            g.mstufe = None
    return fn


def geschaetzt(g, stufe, key):
    """Faktor, den der Held für key annimmt."""
    m = g.mfak
    if not m or stufe <= 0:
        return 1.0
    if stufe == 1:
        s = staerke(m)
        return 1.0 if abs(s) < 1e-9 else (1.0 + SCHAETZ if s > 0 else 1.0 - SCHAETZ)
    if stufe == 2:
        f = m.get(key, 1.0)
        return 1.0 if f == 1.0 else (1.0 + SCHAETZ if f > 1.0 else 1.0 - SCHAETZ)
    return m.get(key, 1.0)


def ziel_fn(politik, stufe_fest, held):
    """politik 'schwach': geschätzte Restleben am kleinsten; 'gefaehrlich': geschätzter Schaden je Zug am größten.
    Nahkämpfer: zuerst unter den nahen Gegnern (wie glut2), Fernkämpfer: alle."""
    def st(g):
        if stufe_fest is not None:
            return stufe_fest
        return g.stufe_lesen
    def rest(g):
        return (g.leben / g.lmax) * g.basis_leben * geschaetzt(g, st(g), "leben")
    def gefahr(g):
        a = g.basis_angriff * geschaetzt(g, st(g), "angriff")
        return g.basis_schaden * geschaetzt(g, st(g), "schaden") * (1 + (a - 15) * 0.02) * g.chance
    def fn(l, fernwaffe):
        kand = l if fernwaffe else ([g for g in l if g.ab == 0] or l)
        if politik == "zufall":
            return _ZUFALL.choice(kand)
        if politik == "schwach":
            return min(kand, key=lambda g: (g.herr is not None and not fernwaffe, g.ab if not fernwaffe else 0, rest(g)))
        return max(kand, key=lambda g: (-(g.ab if not fernwaffe else 0), gefahr(g), -rest(g)))
    return fn


# ---------------------------------------------------------------- (1) Endschaden

def verteilung(W, held, mon_name, n, rng, richtung):
    mon = W["monster"][mon_name]
    g = hg.Gegner(W, {"tempo_gegner": {}, "ausdauer": {"gegner": {"basis": 0, "je_stufe": 0}}, "ohne_atem": []}, mon, mon_name)
    c = collections.Counter()
    if richtung == "auf_held":
        abz = sim.held_abzug(W, held)
        for _ in range(n):
            sch = sim.schaden_roh(W, g.schaden, g.angriff, -(held.stufe - g.stufe), rng)
            c[sim.endschaden(W, sch, abz)] += 1
    else:
        waffe = W["waffen"][held.waffe]
        gw = waffe["grundwert"]
        grund = waffe["schaden"] + (held.werte[gw] if gw else 0)
        fw = held.f(held.waffe)
        krit = sim.krit_prozent(W, held, held.waffe, fw)
        for _ in range(n):
            sch = sim.schaden_roh(W, grund, fw, held.stufe - g.stufe, rng, krit) * g.schwaeche.get(waffe["typ"], 1.0)
            c[sim.endschaden(W, sch, g.ruestung)] += 1
    top, anz = c.most_common(1)[0]
    werte = sorted(c)
    return len(c), top, anz / n, werte


# ---------------------------------------------------------------- Messung

def messe(W, H, h, gg, n, rng, opt):
    r = [glut2.kampf(W, H, h, gg, rng, opt) for _ in range(n)]
    sg = [x for x in r if x["sieg"]]
    return {"quote": len(sg) / n, "runden": statistics.mean(x["runden"] for x in sg) if sg else 0.0,
            "leben": statistics.mean(x["leben"] for x in sg) if sg else 0.0}


FAELLE = glut2.FAELLE
GRUPPEN = [("Rudel", 1), ("Wolf+Wolf", 2), ("Wolf+Goblin-Späher", 2), ("Goblin+Goblin", 2), ("Skelett+Skelett", 2),
           ("Skelett+Zombie", 2), ("Kobold+Goblin-Schamane", 3), ("Goblin+Goblin-Späher+Goblin-Schamane", 3)]


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--kaempfe", type=int, default=2000)
    p.add_argument("--laeufe", type=int, default=25)
    a = p.parse_args()
    HIER = os.path.dirname(os.path.abspath(__file__))
    W = sim.lade(os.path.join(HIER, "werte.json"))
    H = sim.lade(os.path.join(HIER, "handgemenge.json"))
    W["monster"]["Rudel"] = dict(W["monster"]["Wolf"], rudel="Jungwolf")
    glut2.GEGENWERT["Rudel"] = glut2.GEGENWERT["Wolf"]
    H["tempo_gegner"]["Rudel"] = H["tempo_gegner"]["Wolf"]
    rng = random.Random(14111)
    n = a.kaempfe
    herk = list(sim.ohne_info(W["herkuenfte"]))
    fort = {hk: sim.fortschritt_alle(W, hk, a.laeufe, rng, True) for hk in herk}
    fb = {hk: fort[hk]["fert_bei"] for hk in herk}
    stufen = sorted({sf for _, sf in FAELLE + GRUPPEN})
    held = {(hk, sf): hg.held_bei(W, hk, sf, fb[hk]) for hk in herk for sf in stufen}
    out = []
    o = out.append
    o(f"# 1411.1 Merkmale je Exemplar (Tuffy, `tools/sim444/merkmale_1411.py`, je Zelle {n} Kämpfe, Politik S von glut2)\n")
    o("Annahmen (Entwurf Sokrates): 50 % gewöhnlich; Tiere jung (L −15, Angriff −10, Abwehr +10), alt (L −10, Angriff −10), "
      "kräftig (L +15, Schaden +15), angeschlagen (L −30); Untote, Goblins, Kobold rostige Waffe (Schaden −25), gute Waffe (+20), "
      "brüchig (L −20), zäh (L +20); Bosse fest, Ockerschleim ohne. Held sieht den Lebensbalken als Anteil.\n")

    # (1)
    o("## (1) Endschaden nach Streuung ±20 %, Rundung, Rüstung (20 000 Treffer je Zelle, ohne Merkmal)\n")
    o("Zelle: verschiedene Zahlen · häufigste (Anteil) · Spanne\n")
    o("| Herkunft | Ratte → Held (St. 1) | Wolf → Held (St. 2) | Krogg → Held (St. 4) | Held → Ratte | Held → Wolf | Held → Krogg |")
    o("|---|---|---|---|---|---|---|")
    eng = []
    for hk in herk:
        z = []
        for richtung in ("auf_held", "vom_held"):
            for mn, sf in (("Riesenratte", 1), ("Wolf", 2), ("Krogg", 4)):
                k, top, ant, werte = verteilung(W, held[(hk, sf)], mn, 20000, rng, richtung)
                z.append(f"{k} · {top} ({round(ant * 100)} %) · {werte[0]}–{werte[-1]}")
                if k <= 2 or ant >= 0.6:
                    eng.append(f"{hk} {('→ Held' if richtung == 'auf_held' else 'Held →')} {mn}: {k} Zahlen, {top} in {round(ant * 100)} %")
        o(f"| {hk} | " + " | ".join(z) + " |")
    o("")
    o("Kaum Streuung sichtbar (≤ 2 Zahlen oder häufigste ≥ 60 %): " + ("; ".join(eng) if eng else "keine") + "\n")

    # (2)
    o("## (2) Siege je 100 und Runden: heute / mit Merkmalen (Lesestufe nach Formel, Zielwahl wie glut2)\n")
    o("| Herkunft | " + " | ".join(f"{g} {s}" for g, s in FAELLE) + " | Mittel |")
    o("|" + "---|" * (len(FAELLE) + 2))
    dsum = []; nieder = []
    rund = []
    for hk in herk:
        z = []; d_hk = []
        for gg, sf in FAELLE:
            h = held[(hk, sf)]
            r0 = messe(W, H, h, gg, n, rng, {"politik": "schlag_haltung", "exemplar": exemplar_fn(False)})
            r1 = messe(W, H, h, gg, n, rng, {"politik": "schlag_haltung", "exemplar": exemplar_fn(True)})
            z.append(f"{round(r0['quote'] * 100)}/{round(r1['quote'] * 100)} · {r0['runden']:.1f}/{r1['runden']:.1f}")
            d_hk.append((r1["quote"] - r0["quote"]) * 100); nieder.append((r0["quote"] - r1["quote"]) * 100)
            rund.append(r1["runden"] - r0["runden"])
        dsum += d_hk
        o(f"| {hk} | " + " | ".join(z) + f" | {statistics.mean(d_hk):+.1f} |")
    o("")
    o(f"Mittel über alle Zellen: Siege {statistics.mean(dsum):+.1f} je 100, Niederlagen {statistics.mean(nieder):+.1f} je 100 "
      f"(Ziel höchstens +2), Runden {statistics.mean(rund):+.2f}; größte Zunahme der Niederlagen in einer Zelle {max(nieder):+.0f}.\n")

    # (3)
    o("## (3) Lesen der Merkmale 0 → 3 in Begegnungen mit mehreren Gegnern (Ansage nach Formel, nur die Merkmalsstufe erzwungen)\n")
    o("Zelle: Siege je 100 bei Stufe 0/1/2/3 · Gewinn 3 gegen 0\n")
    ergebnis = {}
    for pol in ("schwach", "gefaehrlich"):
        o(f"### Zielwahl: {'schwächstes Ziel zuerst' if pol == 'schwach' else 'gefährlichstes Ziel zuerst'}\n")
        o("| Herkunft | " + " | ".join(f"{g} {s}" for g, s in GRUPPEN) + " | Mittel |")
        o("|" + "---|" * (len(GRUPPEN) + 2))
        alle = []
        for hk in herk:
            z = []; gew = []
            for gg, sf in GRUPPEN:
                h = held[(hk, sf)]
                q = [messe(W, H, h, gg, n, rng, {"politik": "schlag_haltung", "exemplar": exemplar_fn(True),
                                                  "ziel_wahl": ziel_fn(pol, stl, h)})["quote"] * 100 for stl in range(4)]
                z.append("/".join(str(round(x)) for x in q) + f" · {q[3] - q[0]:+.0f}")
                gew.append(q[3] - q[0])
            alle += gew
            o(f"| {hk} | " + " | ".join(z) + f" | {statistics.mean(gew):+.1f} |")
        ergebnis[pol] = alle
        o("")
        o(f"Mittel {statistics.mean(alle):+.1f} je 100, größter Gewinn {max(alle):+.0f}, Zellen mit ≥ 5: "
          f"{sum(1 for x in alle if x >= 5)} von {len(alle)}.\n")

    # (3b) Zielwahl heute gegen Lesen: kostet die ehrliche Zielwahl (nur Balken) gegenüber glut2 (sieht die Lebenszahl)?
    o("### Gegenprobe: Zielwahl glut2 (kennt die Lebenszahl) gegen „schwächstes“ auf Stufe 0 und 3, Mittel je Herkunft\n")
    o("| Herkunft | glut2 | schwach 0 | schwach 3 |")
    o("|---|---|---|---|")
    for hk in herk:
        q = [[], [], []]
        for gg, sf in GRUPPEN:
            h = held[(hk, sf)]
            q[0].append(messe(W, H, h, gg, n // 2, rng, {"politik": "schlag_haltung", "exemplar": exemplar_fn(True)})["quote"])
            for i, stl in ((1, 0), (2, 3)):
                q[i].append(messe(W, H, h, gg, n // 2, rng, {"politik": "schlag_haltung", "exemplar": exemplar_fn(True),
                                                             "ziel_wahl": ziel_fn("schwach", stl, h)})["quote"])
        o(f"| {hk} | " + " | ".join(str(round(statistics.mean(x) * 100)) for x in q) + " |")
    o("")

    # (4) Was Lesen tragen könnte
    o("## (4) Was Lesen tragen könnte (Mittel je Herkunft, Siege je 100)\n")
    o("Spalten: Zielwahl zufällig / schwächstes auf Stufe 3 (Obergrenze der Zielwahl) · Merkmale doppelt so stark: ohne Merkmal / "
      "mit / Lesen schwächstes 0 / 3 · Meiden: stärkere Exemplare kommen nicht (alle Fälle aus (2) und (3))\n")
    o("| Herkunft | zufällig | schwach 3 | doppelt: ohne | doppelt: mit | doppelt: Lesen 0 | doppelt: Lesen 3 | alle Fälle mit Merkmal | dto. stärkere gemieden |")
    o("|---|---|---|---|---|---|---|---|---|")
    m4 = n // 2
    S = {"politik": "schlag_haltung"}
    for hk in herk:
        c = [[] for _ in range(8)]
        for gg, sf in GRUPPEN:
            h = held[(hk, sf)]
            c[0].append(messe(W, H, h, gg, m4, rng, dict(S, exemplar=exemplar_fn(True), ziel_wahl=ziel_fn("zufall", 0, h)))["quote"])
            c[1].append(messe(W, H, h, gg, m4, rng, dict(S, exemplar=exemplar_fn(True), ziel_wahl=ziel_fn("schwach", 3, h)))["quote"])
            c[2].append(messe(W, H, h, gg, m4, rng, dict(S, exemplar=exemplar_fn(False)))["quote"])
            c[3].append(messe(W, H, h, gg, m4, rng, dict(S, exemplar=exemplar_fn(True, 2.0)))["quote"])
            c[4].append(messe(W, H, h, gg, m4, rng, dict(S, exemplar=exemplar_fn(True, 2.0), ziel_wahl=ziel_fn("schwach", 0, h)))["quote"])
            c[5].append(messe(W, H, h, gg, m4, rng, dict(S, exemplar=exemplar_fn(True, 2.0), ziel_wahl=ziel_fn("schwach", 3, h)))["quote"])
        for gg, sf in FAELLE + GRUPPEN:
            h = held[(hk, sf)]
            c[6].append(messe(W, H, h, gg, m4, rng, dict(S, exemplar=exemplar_fn(True)))["quote"])
            c[7].append(messe(W, H, h, gg, m4, rng, dict(S, exemplar=exemplar_fn(True, meiden=True)))["quote"])
        o(f"| {hk} | " + " | ".join(str(round(statistics.mean(x) * 100)) for x in c) + " |")
    o("")

    # Rest aus 481
    o("## Rest aus 481\n")
    o("Wachsoldat, Siege je 100 (S, heute ohne Merkmal) je Fall: " + ", ".join(
        f"{gg} {round(messe(W, H, held[('Wachsoldat', sf)], gg, n // 2, rng, {'politik': 'schlag_haltung'})['quote'] * 100)}"
        for gg, sf in FAELLE) + "\n")
    o("Heiler wächst nie: `python3 tools/sim444/stufe644a.py --nur-644a1` (Teil 7, eigener Lauf).\n")
    print("\n".join(out))


if __name__ == "__main__":
    main()
