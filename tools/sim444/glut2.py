#!/usr/bin/env python3
"""Glut-Rechner Fassung 2 (Sokrates 14.11., DESIGN-AKTIONSPUNKTE.md „Fassung 2“). Nur Werkzeug, kein Spielcode.

Gegen glut.py geändert (Befunde 1–5 und Gegenprüfung):
  - Gegenschlag und Wachschuss ab Anfänger, halber Schaden, nie kritisch (voll: Option gegenschlag_voll)
  - Nachlegen: übrige Glut ins Tun, je Glut +25 % Schaden (gerechnet: +15 % nie besser als Haltung, +35 % und Gunst je Glut fast immer besser)
  - Wehr gilt für alle Schläge bis zum eigenen Zug (je Glut ein Schlag mit Ungunst), gegen große Schläge Ring langsamer
  - Haltung: eine Art je Zug (Gegenschlag oder Wachschuss oder Wehr), beim Planen gewählt
  - höchstens zwei Ringe je Gegnerzug, Antworten lösen keine Antworten aus, mindestens 1 Glut je Zug
  - Funke (ab Stufe 4, einmal je Kampf): nach perfektem Ring oder unter halbem Leben, +1 Glut im nächsten Zug
  - Lauern hält einen Zug; Ducken gegen Fernkampf nur als Option (ducken 1,0: Jägerkind gegen Grak 99 → 84 %, verworfen)
Politiken (Autopilot): schlag_haltung (Schlag, Rest Haltung), nachlegen (alles ins Tun), warten (alles Haltung, wenn ein Gegner herankommt),
klug (je Lage die beste der drei nach einfacher Regel); die Dominanzprüfung vergleicht die drei festen Politiken.
"""
import os, random, statistics, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sim
import handgemenge as hg

FREI = {"schnell": 2, "normal": 1, "langsam": 0}
RING = (0.2, 0.5, 0.3)
RING_WEHR = (0.45, 0.45, 0.10)
GROSS_FAKTOR = 1.6
NACHLEGEN_SCHADEN = float(os.environ.get("NACHLEGEN", "0.25"))
GESELLE = 25


def kampf(W, H, held, mon_name, rng, opt):
    k = W["kampf"]; z = W["zauber"]
    mon = W["monster"][mon_name]
    feld = [hg.Gegner(W, H, mon, mon_name)]
    if mon.get("rudel"):
        rud = W["merkmale"]["rudel"][mon["rudel"]]
        n = rng.randint(*rud["anzahl"]) if isinstance(rud["anzahl"], list) else rud["anzahl"]
        feld += [hg.Gegner(W, H, mon, rud["koerper"], rud) for _ in range(n)]
    leit = feld[0]
    boss = bool(mon.get("boss"))
    start = 0 if leit.ueb else 1
    for g in feld:
        g.ab = start
        g.glut = 3 if (boss and g is leit) else 2
        g.lauert = 0
        g.glut_bereit = 0
    waffe_name = held.waffe
    waffe = W["waffen"][waffe_name]
    fern = waffe["art"] == "fern"
    tempo = hg.held_tempo(H, held)
    s = {"leben": held.leben_max(), "mana": held.mana_max(), "bann": 0.0, "liegt": False, "betaeubt": 0,
         "bereit": 0, "haltung": None, "minus": 0, "funke_da": held.stufe >= 4, "funke_jetzt": False, "ringe": 0}
    lmax = s["leben"]
    st = {"zuege": 0, "gegenschlag": 0, "wachschuss": 0, "wehr": 0, "verfallen": 0, "nachgelegt": 0, "funke": 0,
          "ringe_gekappt": 0}
    pol = opt.get("politik", "schlag_haltung")

    def ring(wehr):
        p = RING_WEHR if wehr else RING
        r = rng.random()
        return 0.0 if r < p[0] else (0.5 if r < p[0] + p[1] else 1.0)

    def funke_pruefen(perfekt=False):
        if s["funke_da"] and (perfekt or s["leben"] < 0.5 * lmax):
            s["funke_da"] = False; s["funke_jetzt"] = True; st["funke"] += 1

    def auf_held(g, faktor=1.0, gross=False, bonus=0.0):
        wehr = False
        if s["bereit"] > 0 and s["haltung"] == "wehr":
            s["bereit"] -= 1; st["wehr"] += 1; wehr = True
            bonus += H["ungunst"]
        _, abw = sim.held_abwehr(W, held, g.art, waffe_name, True)
        if rng.random() >= sim.trefferchance(W, g.angriff, abw, bonus):
            return False
        sch = sim.schaden_roh(W, g.schaden, g.angriff, -(held.stufe - g.stufe), rng) * faktor
        if gross:
            if s["ringe"] < 2:
                s["ringe"] += 1
                f = ring(wehr)
                if f == 0.0:
                    funke_pruefen(True)
                sch *= f
            else:
                st["ringe_gekappt"] += 1
        s["leben"] -= sim.endschaden(W, sch, sim.held_abzug(W, held, s["bann"]))
        funke_pruefen()
        return True

    def held_schlag(ziel, aktion="waffe", bonus=0.0, faktor=1.0, antwort=False):
        if aktion == "Funkenpfeil":
            zb = z["Funkenpfeil"]
            if not antwort:
                s["mana"] -= zb["kosten"]
            else:
                s["mana"] -= zb["kosten"]
            fert_name, grund, typ = zb["schule"], sim.zauber_grund(W, held, zb), zb["typ"]
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
        if ziel.lauert and (fern or aktion == "Funkenpfeil"):
            bonus += H["ungunst"] * opt.get("ducken", 0.0)          # der Lauernde duckt sich gegen Fernkampf
        if rng.random() < sim.trefferchance(W, fw, ziel.abwehr, bonus):
            krit = 0.0 if antwort else sim.krit_prozent(W, held, fert_name, fw)
            sch = sim.schaden_roh(W, grund, fw, held.stufe - ziel.stufe, rng, krit)
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
        if not l:
            return None
        # nahe zuerst, sonst Anführer
        nah = [g for g in l if g.ab == 0]
        return nah[0] if nah else (leit if leit.leben > 0 else l[0])

    def antwort_faktor():
        voll = opt.get("gegenschlag_voll") or held.f(waffe_name) >= GESELLE
        return 1.0 if voll else 0.5

    def tun(t, glut, fa):
        """glut = verfügbare Glut nach dem Weg; gibt Rest zurück."""
        nd = 0
        if pol == "nachlegen":
            nd = glut - 1
        bonus = 0.0; faktor = 1.0
        if nd > 0:
            st["nachgelegt"] += nd
            if opt.get("nachlegen_gunst"):
                bonus = opt.get("gunst", -H["ungunst"]); faktor = 1.0 + NACHLEGEN_SCHADEN * (nd - 1)
            else:
                faktor = 1.0 + opt.get("nachlegen_schaden", NACHLEGEN_SCHADEN) * nd
        held_schlag(t, fa or "waffe", bonus, faktor)
        return glut - 1 - nd

    def haltung_waehlen(nahe_gegner):
        if pol == "nur_wehr":
            return "wehr"
        if aktion_fern():
            return "wachschuss" if any(g.ab > 0 for g in lebend()) else "wehr"
        # Nahkampf: Gegenschlag, außer ein großer Schlag ist angesagt (Anführer mit voller Glut) -> Wehr
        if leit.leben > 0 and leit.ab == 0 and leit.glut >= 2 and (boss or leit.anfuehrer) and rng.random() < 0.5:
            return "wehr"
        return "gegenschlag"

    def held_zug(runde):
        st["verfallen"] += s["bereit"]
        s["bereit"] = 0; s["haltung"] = None
        st["zuege"] += 1
        if s["betaeubt"] > 0:
            s["betaeubt"] -= 1; return
        glut = max(1, 3 - s["minus"]); s["minus"] = 0
        if s["funke_jetzt"]:
            glut += 1; s["funke_jetzt"] = False
        frei = FREI[tempo]
        t = ziel_von()
        fa = aktion_fern()
        if "Bannschild" in held.zauber and runde == 1 and s["mana"] >= z["Bannschild"]["kosten"]:
            zb = z["Bannschild"]; s["mana"] -= zb["kosten"]
            s["bann"] = zb["ruestung"] * (1 + held.f(zb["schule"]) * k["ruestungsfertigkeit_im_abzug_je_punkt"])
            s["bereit"] = glut - 1; s["haltung"] = haltung_waehlen(None); return
        if "Wundsegen" in held.zauber and s["leben"] < lmax * z["Wundsegen"]["heilen_unter"] and s["mana"] >= z["Wundsegen"]["kosten"]:
            zb = z["Wundsegen"]; s["mana"] -= zb["kosten"]
            s["leben"] = min(lmax, s["leben"] + round(sim.zauber_grund(W, held, zb) * (1 + held.f(zb["schule"]) / 100.0)))
            s["bereit"] = glut - 1; s["haltung"] = haltung_waehlen(None); return
        nahe = [g for g in lebend() if g.ab == 0]
        if fa:
            if nahe and all(g.tempo == "langsam" for g in nahe) and glut >= 2 and frei >= 1:
                glut -= 1
                for g in nahe:
                    g.ab = 1
            if pol == "warten" and not nahe and t.ab > 0:
                s["bereit"] = glut; s["haltung"] = "wachschuss"; return
            s["bereit"] = tun(t, glut, fa); s["haltung"] = haltung_waehlen(nahe)
            return
        if t.ab > 0:
            if pol == "warten" and t.tempo != "langsam" and not t.lauert:
                s["bereit"] = glut; s["haltung"] = "gegenschlag"; return
            while t.ab > 0 and frei > 0:
                t.ab -= 1; frei -= 1
            while t.ab > 0 and glut > 1:
                t.ab -= 1; glut -= 1
            if t.ab > 0:
                s["bereit"] = glut; s["haltung"] = "wehr"; return
            if t.lauert and t.glut_bereit > 0:
                t.glut_bereit -= 1
                auf_held(t)
                if s["leben"] <= 0:
                    return
        s["bereit"] = tun(t, glut, None); s["haltung"] = haltung_waehlen(nahe)

    def wachschuss(g):
        if s["bereit"] > 0 and s["haltung"] == "wachschuss" and aktion_fern():
            s["bereit"] -= 1; st["wachschuss"] += 1
            held_schlag(g, aktion_fern(), 0.0, antwort_faktor(), antwort=True)

    def gegenschlag(g):
        if s["bereit"] > 0 and s["haltung"] == "gegenschlag" and not aktion_fern():
            s["bereit"] -= 1; st["gegenschlag"] += 1
            held_schlag(g, "waffe", 0.0, antwort_faktor(), antwort=True)

    def gegner_zug():
        s["ringe"] = 0
        hetzt = leit.name == "Grimmzahn" and leit.leben > 0
        for g in lebend():
            if s["leben"] <= 0:
                return
            glut = g.glut
            g.lauert = 0; g.glut_bereit = 0
            if g.art != "nah":
                if g.ab == 0 and glut >= 2:
                    g.ab = 1; glut -= 1
                gross = glut >= 2 and g.anfuehrer and rng.random() < 0.4
                if rng.random() < g.chance:
                    auf_held(g, GROSS_FAKTOR if gross else 1.0, gross)
                continue
            frei = 99 if (hetzt and g.koerper == "Wolf" and g is not leit) else FREI[g.tempo]
            while g.ab > 0 and frei > 0:
                g.ab -= 1; frei -= 1
                wachschuss(g)
            while g.ab > 0 and glut > 1:
                g.ab -= 1; glut -= 1
                wachschuss(g)
            if g.leben <= 0 or g.ab > 0:
                continue
            gegenschlag(g)
            if g.leben <= 0:
                continue          # Gegenschlag, der tötet, bricht den Angriff ab
            gross = g.anfuehrer and glut >= 2 and (boss or rng.random() < 0.35) and rng.random() < 0.5
            if gross:
                glut -= 2
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
                g.lauert = 1; g.glut_bereit = glut

    if leit.ueb and leit.ueb["gegner_zuerst"]:
        gegner_zug()
    runde = 0
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
    for key in ("zuege", "gegenschlag", "wachschuss", "wehr", "verfallen", "nachgelegt", "funke", "ringe_gekappt"):
        out[key] = statistics.mean(x[key] for x in r)
    return out


def wert(r):
    """Güte einer Politik für die Dominanzprüfung: Sieg zählt, dann Leben am Ende."""
    return r["quote"] * 100 + (r["leben"] or 0) * 20


if __name__ == "__main__":
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("--kaempfe", type=int, default=300)
    p.add_argument("--laeufe", type=int, default=25)
    p.add_argument("--unterstufe", type=int, default=0, help="Held so viele Stufen unter dem Gegner (härtere Aufstellung)")
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
    V = [("heute", None),
         ("F2 Schlag+Haltung", {"politik": "schlag_haltung"}),
         ("F2 Nachlegen", {"politik": "nachlegen"}),
         ("F2 Warten", {"politik": "warten"}),
         ("F2 nur Wehr", {"politik": "nur_wehr"}),
         ("F2 Nachlegen +35 %", {"politik": "nachlegen", "nachlegen_schaden": 0.35}),
         ("F2 Gegenschlag voll", {"politik": "schlag_haltung", "gegenschlag_voll": True})]
    roh = {}
    for hk in herk:
        for gg, sf in faelle:
            h = hg.held_bei(W, hk, max(1, sf - a.unterstufe), fb[hk])
            roh[(hk, gg)] = [hg.messe(W, H, h, gg, n, rng, "heute", {"ring": "spieler"}) if o is None else messe(W, H, h, gg, n, rng, o)
                             for _, o in V]
    print(f"Unterstufe {a.unterstufe}, je Zelle {n} Kämpfe. Spalten:", " / ".join(v[0] for v in V), "\n")
    for titel, key, fmt in [("Sieg %", "quote", lambda x: hg.pz(x)), ("Runden bis Sieg", "runden", lambda x: f"{x:.1f}" if x else "–")]:
        print(f"## {titel}\n")
        print("| Herkunft | " + " | ".join(f"{g} {s_}" for g, s_ in faelle) + " |")
        print("|" + "---|" * (len(faelle) + 1))
        for hk in herk:
            print(f"| {hk} | " + " | ".join("/".join(fmt(r[key]) for r in roh[(hk, gg)]) for gg, _ in faelle) + " |")
        print()
    # Dominanz: welche der drei festen Politiken (Schlag+Haltung, Nachlegen, Warten) ist je Zelle die beste?
    print("## Beste feste Politik je Zelle (S = Schlag+Haltung, N = Nachlegen, W = Warten; = gleichauf innerhalb 3 Punkte)\n")
    zaehl = {"S": 0, "N": 0, "W": 0, "=": 0}
    print("| Herkunft | " + " | ".join(f"{g} {s_}" for g, s_ in faelle) + " |")
    print("|" + "---|" * (len(faelle) + 1))
    for hk in herk:
        zeile = []
        for gg, _ in faelle:
            w = {"S": wert(roh[(hk, gg)][1]), "N": wert(roh[(hk, gg)][2]), "W": wert(roh[(hk, gg)][3])}
            best = max(w, key=w.get)
            zweit = sorted(w.values())[-2]
            m = "=" if w[best] - zweit < 3 else best
            zaehl[m] += 1
            zeile.append(m + "".join(f" {x}{w[x]:.0f}" for x in "SNW"))
        print(f"| {hk} | " + " | ".join(zeile) + " |")
    print("\nZählung:", zaehl, "\n")
    print("## Schlag+Haltung: je Kampf Gegenschlag · Wachschuss · Wehr · verfallen · Funke / Züge\n")
    print("| Herkunft | " + " | ".join(f"{g} {s_}" for g, s_ in faelle) + " |")
    print("|" + "---|" * (len(faelle) + 1))
    for hk in herk:
        print(f"| {hk} | " + " | ".join((lambda r: f"{r['gegenschlag']:.1f}·{r['wachschuss']:.1f}·{r['wehr']:.1f}·{r['verfallen']:.1f}·{r['funke']:.1f}/{r['zuege']:.1f}")(roh[(hk, gg)][1]) for gg, _ in faelle) + " |")
