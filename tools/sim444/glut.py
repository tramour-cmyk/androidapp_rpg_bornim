#!/usr/bin/env python3
"""Glut-Rechner (Sokrates 14.11., Entwurf „Lesen, Planen, Antworten“, DESIGN-AKTIONSPUNKTE.md).

Ableger von handgemenge.py (930.3), gleiche Formeln (sim.py) und Werte (werte.json 444).
Glut: Held 3, Gegner 2, Bosse 3; freie Felder nach Tempo (schnell 2, normal 1, langsam 0), jedes weitere 1;
ein Tun je Zug (1; großer Schlag der Gegner 2, mit Ring); Rest = Bereitschaft bis zum eigenen nächsten Zug:
  Wehr: nächster Schlag gegen den Helden mit Ungunst, Ring eine Stufe besser (perfekt leichter)
  Gegenschlag (ab Geselle, Nahkampf): schlägt ein naher Gegner zu oder kommt er heran, schlägt der Held zuerst
  Wachschuss (ab Geselle, Fernkampf/Funkenpfeil): rückt ein Gegner heran, Schuss vorher
Lösen aus nah kostet 1, dann gilt der freie Schritt (Rückzug). Kein Schwung, keine Ausdauer.
Ring eines mittleren Spielers auf großen Schlägen (perfekt 0,2 / gut 0,5 / daneben 0,3).
"""
import os, random, statistics, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sim
import handgemenge as hg

FREI = {"schnell": 2, "normal": 1, "langsam": 0}
RING = (0.2, 0.5, 0.3)
RING_WEHR = (0.45, 0.45, 0.10)
GROSS_FAKTOR = 1.6     # großer Schlag (2 Glut) gegen einfachen; „gut“ ~ bisheriger Schaden (1048 A)
GESELLE = int(os.environ.get("GESELLE", "25"))


def kampf(W, H, held, mon_name, rng, opt):
    """opt: politik (angriff/warten/klug), antworten (leiter/alle/keine), gegner_glut (2/3), funke (bool), eroeffnung."""
    k = W["kampf"]; z = W["zauber"]
    mon = W["monster"][mon_name]
    feld = [hg.Gegner(W, H, mon, mon_name)]
    if mon.get("rudel"):
        rud = W["merkmale"]["rudel"][mon["rudel"]]
        n = rng.randint(*rud["anzahl"]) if isinstance(rud["anzahl"], list) else rud["anzahl"]
        feld += [hg.Gegner(W, H, mon, rud["koerper"], rud) for _ in range(n)]
    leit = feld[0]
    boss = bool(mon.get("boss"))
    start = 0 if leit.ueb else (2 if opt.get("eroeffnung") == "weit" else 1)
    for g in feld:
        g.ab = start
        g.glut = (3 if (boss and g is leit) else opt.get("gegner_glut", 2))
        g.lauert = False
    waffe_name = held.waffe
    waffe = W["waffen"][waffe_name]
    fern = waffe["art"] == "fern"
    tempo = hg.held_tempo(H, held)
    s = {"leben": held.leben_max(), "mana": held.mana_max(), "bann": 0.0, "liegt": False, "betaeubt": 0,
         "bereit": 0, "minus": 0, "schad_antw": 0, "funke": opt.get("funke", False) and held.stufe >= 4}
    lmax = s["leben"]
    st = {"held_tun": 0, "antworten": 0, "gegenschlag": 0, "wachschuss": 0, "wehr": 0, "verfallen": 0,
          "zuege": 0, "alles_bereit": 0, "gegner_tun": 0, "gross": 0, "loesen": 0}
    pol = opt.get("politik", "angriff")
    antw = opt.get("antworten", "leiter")

    def fert_w():
        return held.f("Funkenpfeil" if False else waffe_name)

    def zauber_fert():
        return held.f(z["Funkenpfeil"]["schule"]) if "Funkenpfeil" in held.zauber else 0

    def darf(art):
        if antw == "keine":
            return art == "wehr"
        if antw == "alle":
            return True
        if art == "wehr":
            return True
        if art == "gegenschlag":
            return not fern and held.f(waffe_name) >= GESELLE
        if art == "wachschuss":
            return (fern and held.f(waffe_name) >= GESELLE) or zauber_fert() >= GESELLE
        return False

    def ring(wehr):
        p = RING_WEHR if wehr else RING
        r = rng.random()
        return 0.0 if r < p[0] else (0.5 if r < p[0] + p[1] else 1.0)

    def auf_held(g, faktor=1.0, gross=False):
        st["gegner_tun"] += 1
        wehr = False
        bonus = 0.0
        if s["bereit"] > 0 and darf("wehr") and (gross or not darf("gegenschlag")):
            s["bereit"] -= 1; st["wehr"] += 1; st["antworten"] += 1; wehr = True
            bonus = H["ungunst"]
        _, abw = sim.held_abwehr(W, held, g.art, waffe_name, True)
        if rng.random() >= sim.trefferchance(W, g.angriff, abw, bonus):
            return False
        sch = sim.schaden_roh(W, g.schaden, g.angriff, -(held.stufe - g.stufe), rng) * faktor
        if gross:
            sch *= ring(wehr)
        s["leben"] -= sim.endschaden(W, sch, sim.held_abzug(W, held, s["bann"]))
        return True

    def held_schlag(ziel, aktion="waffe", bonus=0.0, faktor=1.0):
        if aktion == "Funkenpfeil":
            zb = z["Funkenpfeil"]; s["mana"] -= zb["kosten"]
            fert_name, grund, typ = zb["schule"], zb["schaden"] + held.werte["wille"], zb["typ"]
        else:
            fert_name = waffe_name
            gw = waffe["grundwert"]
            grund = waffe["schaden"] + (held.werte[gw] if gw else 0)
            typ = waffe["typ"]
            if fern:
                bonus += k["fernkampf_treffer_je_wahrnehmung"] * held.werte["wahrnehmung"]
        fw = held.f(fert_name)
        if s["liegt"]:
            bonus += W["merkmale"]["umreissen"]["naechster_angriff_treffer"]; s["liegt"] = False
        if rng.random() < sim.trefferchance(W, fw, ziel.abwehr, bonus):
            sch = sim.schaden_roh(W, grund, fw, held.stufe - ziel.stufe, rng,
                                  k["kritisch_prozent_je_gewandtheit"] * held.werte["gewandtheit"])
            sch *= ziel.schwaeche.get(typ, 1.0) * faktor
            ziel.leben -= sim.endschaden(W, sch, ziel.ruestung)
            return True
        return False

    def aktion_fern():
        if "Funkenpfeil" in held.zauber and s["mana"] >= z["Funkenpfeil"]["kosten"]:
            return "Funkenpfeil"
        return "waffe" if fern else None

    def lebend():
        return [g for g in feld if g.leben > 0]

    def ziel_von():
        l = lebend()
        return leit if leit.leben > 0 else (l[0] if l else None)

    # ------------------------------------------------------------ Held
    def held_zug(runde):
        st["verfallen"] += s["bereit"]
        s["bereit"] = 0
        st["zuege"] += 1
        if s["betaeubt"] > 0:
            s["betaeubt"] -= 1; return
        glut = 3 - s["minus"]; s["minus"] = 0
        if s["funke"] and s["leben"] < 0.5 * lmax:
            glut += 1; s["funke"] = False
        frei = FREI[tempo]
        t = ziel_von()
        fa = aktion_fern()
        # Nebenhandlung als Tun (Bannschild Runde 1, Wundsegen unter Schwelle)
        if "Bannschild" in held.zauber and runde == 1 and s["mana"] >= z["Bannschild"]["kosten"]:
            zb = z["Bannschild"]; s["mana"] -= zb["kosten"]
            s["bann"] = zb["ruestung"] * (1 + held.f(zb["schule"]) * k["ruestungsfertigkeit_im_abzug_je_punkt"])
            st["held_tun"] += 1; s["bereit"] = glut - 1; return
        if "Wundsegen" in held.zauber and s["leben"] < lmax * z["Wundsegen"]["heilen_unter"] and s["mana"] >= z["Wundsegen"]["kosten"]:
            zb = z["Wundsegen"]; s["mana"] -= zb["kosten"]
            s["leben"] = min(lmax, s["leben"] + round((zb["heilung"] + held.werte["wille"]) * (1 + held.f(zb["schule"]) / 100.0)))
            st["held_tun"] += 1; s["bereit"] = glut - 1; return
        nahe = [g for g in lebend() if g.ab == 0]
        if fa:
            # Fernkämpfer: von langsamen Nahen lösen (1), freier Schritt zurück
            if nahe and all(g.tempo == "langsam" for g in nahe) and glut >= 2 and frei >= 1:
                glut -= 1; st["loesen"] += 1
                for g in nahe:
                    g.ab = 1
            if pol in ("warten", "klug") and not nahe and darf("wachschuss") and t.ab > 0 and glut >= 3 and pol == "warten":
                st["alles_bereit"] += 1; s["bereit"] = glut; return
            nd = (glut - 1) if pol == "nachdruck" else 0
            held_schlag(t, fa, 25.0 * min(nd, 1), 1.0 + 0.25 * nd); st["held_tun"] += 1
            s["bereit"] = glut - 1 - nd
            return
        # Nahkämpfer
        if t.ab > 0:
            wartet = (pol == "warten") or (pol == "klug" and darf("gegenschlag") and t.tempo != "langsam" and not t.lauert)
            if wartet:
                st["alles_bereit"] += 1; s["bereit"] = glut; return
            # Weg: freie Felder, dann je 1
            while t.ab > 0 and frei > 0:
                t.ab -= 1; frei -= 1
            while t.ab > 0 and glut > 1:
                t.ab -= 1; glut -= 1
            if t.ab > 0:
                s["bereit"] = glut; return
            if t.lauert and t.glut_bereit > 0:     # läuft in die Spitze
                t.glut_bereit -= 1
                auf_held(t)
                if s["leben"] <= 0:
                    return
        nd = (glut - 1) if pol == "nachdruck" else 0
        held_schlag(t, "waffe", 25.0 * min(nd, 1), 1.0 + 0.25 * nd); st["held_tun"] += 1
        s["bereit"] = glut - 1 - nd

    # ------------------------------------------------------------ Antworten im Gegnerzug
    def wachschuss(g):
        if s["schad_antw"] >= opt.get("max_antwort", 99):
            return
        if s["bereit"] > 0 and darf("wachschuss") and aktion_fern():
            s["bereit"] -= 1; st["wachschuss"] += 1; st["antworten"] += 1; s["schad_antw"] += 1
            held_schlag(g, aktion_fern())

    def gegenschlag(g):
        if s["schad_antw"] >= opt.get("max_antwort", 99):
            return
        if s["bereit"] > 0 and darf("gegenschlag") and not aktion_fern():
            s["bereit"] -= 1; st["gegenschlag"] += 1; st["antworten"] += 1; s["schad_antw"] += 1
            held_schlag(g)

    def gegner_zug():
        s["schad_antw"] = 0
        hetzt = leit.name == "Grimmzahn" and leit.leben > 0
        for g in lebend():
            if s["leben"] <= 0:
                return
            glut = g.glut
            g.glut_bereit = 0
            if g.art != "nah":     # Schütze bleibt weit, schießt; großer Schuss (Anlegen) wenn 2 Glut frei
                if g.ab == 0 and glut >= 2:
                    g.ab = 1; glut -= 1
                gross = glut >= 2 and g.anfuehrer and rng.random() < 0.4
                st["gross"] += int(gross)
                if rng.random() < g.chance:
                    auf_held(g, GROSS_FAKTOR if gross else 1.0, gross)
                continue
            frei = 99 if (hetzt and g.koerper == "Wolf" and g is not leit) else FREI[g.tempo]
            while g.ab > 0 and frei > 0:
                g.ab -= 1; frei -= 1
                if g.ab == 0:
                    wachschuss(g) if g.ab == 0 else None
                else:
                    wachschuss(g)
            while g.ab > 0 and glut > 1:
                g.ab -= 1; glut -= 1
                wachschuss(g)
            if g.leben <= 0:
                continue
            if g.ab > 0:
                continue
            gegenschlag(g)
            if g.leben <= 0:
                continue
            gross = g.anfuehrer and glut >= 2 and (boss or rng.random() < 0.35) and rng.random() < 0.5
            if gross:
                glut -= 2; st["gross"] += 1
                if g.ueb and g.erster:
                    g.erster = False
                auf_held(g, GROSS_FAKTOR, True)
            else:
                glut -= 1
                if g.ueb and g.erster and not g.rauch:
                    if auf_held(g, g.ueb["erster_treffer_faktor"], True):
                        g.erster = False
                        if rng.random() < g.ueb["betaeubt_chance"]:
                            s["betaeubt"] = g.ueb["betaeubt_zuege"]
                elif rng.random() < g.chance:
                    if auf_held(g) and g.umr and rng.random() < g.umr["chance_bei_treffer"]:
                        s["liegt"] = True; s["minus"] = 1
            if glut > 0 and mon_name in ("Grak", "Kobold"):
                g.lauert = True; g.glut_bereit = glut

    if leit.ueb and leit.ueb["gegner_zuerst"]:
        gegner_zug()
    runde = 0
    GESELLE_ALT = None
    while runde < W["lauf"]["max_runden"] and s["leben"] > 0:
        runde += 1
        held_zug(runde)
        if leit.leben <= 0:
            return dict(st, sieg=True, runden=runde, leben=max(0.0, s["leben"]) / lmax)
        gegner_zug()
        if leit.leben <= 0 and s["leben"] > 0:
            return dict(st, sieg=True, runden=runde, leben=max(0.0, s["leben"]) / lmax)
    return dict(st, sieg=False, runden=runde, leben=max(0.0, s["leben"]) / lmax)


def messe(W, H, held, gegner, n, rng, opt):
    r = [kampf(W, H, held, gegner, rng, opt) for _ in range(n)]
    sg = [x for x in r if x["sieg"]]
    out = {"quote": len(sg) / n, "runden": statistics.mean(x["runden"] for x in sg) if sg else None,
           "leben": statistics.mean(x["leben"] for x in sg) if sg else None}
    for key in ("held_tun", "antworten", "gegenschlag", "wachschuss", "wehr", "verfallen", "zuege", "alles_bereit", "gegner_tun", "gross", "loesen"):
        out[key] = statistics.mean(x[key] for x in r)
    return out


def heute(W, H, held, gegner, n, rng):
    r = hg.messe(W, H, held, gegner, n, rng, "heute", {"ring": "spieler"})
    return r


if __name__ == "__main__":
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("--kaempfe", type=int, default=400)
    p.add_argument("--laeufe", type=int, default=25)
    a = p.parse_args()
    HIER = os.path.dirname(os.path.abspath(__file__))
    W = sim.lade(os.path.join(HIER, "werte.json"))
    H = sim.lade(os.path.join(HIER, "handgemenge.json"))
    W["monster"]["Rudel"] = dict(W["monster"]["Wolf"], rudel="Jungwolf")
    rng = random.Random(1411)
    n = a.kaempfe
    herk = list(sim.ohne_info(W["herkuenfte"]))
    fb = {hk: sim.fortschritt_alle(W, hk, a.laeufe, rng, True)["fert_bei"] for hk in herk}
    faelle = [("Rudel", 1), ("Zombie", 2), ("Goblin-Späher", 2), ("Skelett", 2), ("Krogg", 4), ("Grimmzahn", 5), ("Grak", 6)]
    V = [("heute", None), ("A angriff, Antworten frei", {"antworten": "alle", "funke": True}),
         ("B angriff, eine Schadensantwort je Gegnerrunde", {"antworten": "alle", "funke": True, "max_antwort": 1}),
         ("C nachdruck (Rest ins Tun)", {"antworten": "alle", "funke": True, "max_antwort": 1, "politik": "nachdruck"}),
         ("D ohne Schadensantwort (nur Wehr)", {"antworten": "keine", "funke": True})]
    roh = {}
    for hk in herk:
        for gg, sf in faelle:
            h = hg.held_bei(W, hk, sf, fb[hk])
            roh[(hk, gg)] = [heute(W, H, h, gg, n, rng) if o is None else messe(W, H, h, gg, n, rng, o) for _, o in V]
    print("Spalten:", " / ".join(v[0] for v in V), "\n")
    for titel, key, fmt in [("Sieg %", "quote", lambda x: hg.pz(x)), ("Runden bis Sieg", "runden", lambda x: f"{x:.1f}" if x else "–"),
                            ("Leben am Ende %", "leben", lambda x: hg.pz(x))]:
        print(f"## {titel}\n")
        print("| Herkunft | " + " | ".join(f"{g} {s_}" for g, s_ in faelle) + " |")
        print("|" + "---|" * (len(faelle) + 1))
        for hk in herk:
            print(f"| {hk} | " + " | ".join("/".join(fmt(r[key]) for r in roh[(hk, gg)]) for gg, _ in faelle) + " |")
        print()
    print("## B: je Kampf Gegenschlag · Wachschuss · Wehr · verfallen / Züge\n")
    print("| Herkunft | " + " | ".join(f"{g} {s_}" for g, s_ in faelle) + " |")
    print("|" + "---|" * (len(faelle) + 1))
    for hk in herk:
        print(f"| {hk} | " + " | ".join((lambda r: f"{r['gegenschlag']:.1f}·{r['wachschuss']:.1f}·{r['wehr']:.1f}·{r['verfallen']:.1f}/{r['zuege']:.1f}")(roh[(hk, gg)][2]) for gg, _ in faelle) + " |")
