#!/usr/bin/env python3
"""Glut-Rechner Fassung 2 (Sokrates 14.11., DESIGN-AKTIONSPUNKTE.md „Fassung 2“), Stufe 0 ergänzt (Tuffy 14.11., 930.5,
DESIGN-GLUT.md 10). Nur Werkzeug, kein Spielcode.

Fassung 2 gegen glut.py:
  - Gegenschlag und Wachschuss ab Anfänger, halber Schaden, nie kritisch (voll: Option gegenschlag_voll, ab Geselle)
  - Nachlegen: übrige Glut ins Tun, je Glut +NACHLEGEN Schaden
  - Wehr gilt für alle Schläge bis zum eigenen Zug (je Glut ein Schlag mit Ungunst), gegen große Schläge Ring langsamer
  - Haltung: eine Art je Zug, beim Planen gewählt; höchstens zwei Ringe je Gegnerzug; Antworten lösen keine Antworten aus
  - Funke (ab Stufe 4, einmal je Kampf): nach perfektem Ring oder unter halbem Leben, +1 Glut im nächsten Zug
  - Lauern hält einen Zug; kein Ducken gegen Fernkampf (Option ducken)

Stufe 0 (930.5) neu:
  - Ansage vor dem Zug des Helden: jeder Gegner plant (groß/klein, Art, lauert); der Held sieht sie nach seiner Lesestufe
    (DESIGN-GLUT.md 5): 0 nur „!“/„!!“, 1 dazu die Art, 2 dazu das Ziel (allein ohne Wirkung), 3 dazu Glut und Täuschung.
    Lesewert L = Wahrnehmung + Spähen/5, Spähen ab Geselle +1 Stufe; Stufe = 2 + ⌊(L − Gegenwert)/4⌋, 0..3;
    Bosse und große Schläge mindestens 1. Gegenwert je Art: GEGENWERT unten.
  - Vorschlag der Bedienung (DESIGN-GLUT.md 7.1) als Politik S: gegen einen gesehenen großen Schlag Wehr, sonst nah
    Gegenschlag, fern Wachschuss. Fassung 2 wählte Wehr gegen Bosse zufällig (50 %), jetzt nach der Ansage.
  - Täuschen (Goblin-Späher, Grimmzahn, Grak): mit P_TAEUSCH zeigt die Ansage groß statt klein oder umgekehrt;
    durchschaut erst auf Stufe 3.
  - Krogg: Prankenhieb (3 Glut, Ring zum Ausweichen): Wehr hilft nicht, schleudert auf fern, danach ist er offen (Gunst).
    Wer die Art nicht sieht (Stufe 0), stellt sich gegen „!!“ in Wehr.
  - Kobold: lauert, solange der Held nicht nah ist, einen Zug; danach greift er an. Speer: wer heranrückt, läuft hinein.
  - Riesenspinne: aus fern Netz (2, Ring): Treffer zieht ein Feld heran und nimmt im nächsten Zug 1 Glut,
    perfekter Ring hält frei; nah Biss, großer Schlag Gift.
  - Riesenfledermaus: fliegt heran, beißt, löst sich (fern); Tun des Helden in seinem Zug mit Ungunst (flattert),
    Antworten ohne.
  - Goblin-Schamane: hinten, heilt einen Verbündeten (1), sonst Kraft sammeln (2) für dessen nächsten Schlag (groß, Ring)
    oder Stab aus fern.
  - Gemischte Begegnungen „A+B“: alle Hauptgegner müssen fallen; Ziel: nah zuerst, sonst der Schamane, sonst der nächste.
  - Warten wartet nur auf Gegner, die herankommen (vorher 0 % gegen den Späher, der nie kam), auch auf Lauernde.
Politiken: schlag_haltung (S), nachlegen (N), warten (W), nur_wehr.
"""
import os, random, statistics, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sim
import handgemenge as hg

FREI = {"schnell": 2, "normal": 1, "langsam": 0}
RING = (0.2, 0.5, 0.3)
RING_WEHR = (0.45, 0.45, 0.10)
GROSS_FAKTOR = 1.6
NACHLEGEN_SCHADEN = float(os.environ.get("NACHLEGEN", "0.20"))
GESELLE = 25
P_TAEUSCH = 0.3
TAEUSCHER = {"Goblin-Späher", "Grimmzahn", "Grak"}
# Gegenwert („undurchschaubar“): Tiere niedrig, Goblins mittel, Untote etwas höher, Bosse hoch (DESIGN-GLUT.md 5)
GEGENWERT = {"Riesenratte": 1, "Wolf": 1, "Jungwolf": 1, "Wildschwein": 1, "Riesen-Hundertfüßer": 1, "Riesenspinne": 1,
             "Riesenfledermaus": 1, "Blutflügler": 1, "Goblin": 3, "Goblin-Späher": 3, "Goblin-Schamane": 3, "Kobold": 3,
             "Skelett": 4, "Zombie": 4, "Ghul": 4, "Ockerschleim": 2, "Krogg": 6, "Grimmzahn": 6, "Grak": 8}


def lesewert(held, spaehen=None):
    sp = held.f("Spähen") if spaehen is None else spaehen
    return held.werte["wahrnehmung"] + sp / 5.0, sp >= GESELLE


def lesestufe(held, name, boss, spaehen=None):
    L, ges = lesewert(held, spaehen)
    st = 2 + int((L - GEGENWERT.get(name, 3)) // 4) + (1 if ges else 0)
    st = max(0, min(3, st))
    return max(1, st) if boss else st


def kampf(W, H, held, mon_name, rng, opt):
    k = W["kampf"]; z = W["zauber"]
    namen = mon_name.split("+")
    feld = []
    for nm in namen:
        mon = W["monster"][nm]
        g0 = hg.Gegner(W, H, mon, nm); g0.herr = None; g0.boss = bool(mon.get("boss")); feld.append(g0)
        if mon.get("rudel"):
            rud = W["merkmale"]["rudel"][mon["rudel"]]
            n = rng.randint(*rud["anzahl"]) if isinstance(rud["anzahl"], list) else rud["anzahl"]
            for _ in range(n):
                g = hg.Gegner(W, H, mon, rud["koerper"], rud); g.herr = g0; g.boss = False; feld.append(g)
    haupt = [g for g in feld if g.herr is None]
    leit = feld[0]
    start = 0 if leit.ueb else 1
    for g in feld:
        g.ab = start
        g.glut = 3 if g.boss else 2
        g.lauert = 0; g.glut_bereit = 0; g.lauerte = False
        g.lmax = g.leben; g.offen = False; g.kraft = False
        g.plan = None
        nm = g.koerper if g.herr else g.name
        g.stufe_lesen = opt.get("lesestufe", lesestufe(held, nm, g.boss, opt.get("spaehen")))
        if g.name == "Goblin-Späher" and g.ab > 0 and opt.get("spaeher_weit", True):
            g.ab = 2                       # bleibt weit
    waffe_name = held.waffe
    waffe = W["waffen"][waffe_name]
    fern = waffe["art"] == "fern"
    tempo = hg.held_tempo(H, held)
    s = {"leben": held.leben_max(), "mana": held.mana_max(), "bann": 0.0, "liegt": False, "betaeubt": 0,
         "bereit": 0, "haltung": None, "minus": 0, "funke_da": held.stufe >= 4, "funke_jetzt": False, "ringe": 0}
    lmax = s["leben"]
    st = {"zuege": 0, "gegenschlag": 0, "wachschuss": 0, "wehr": 0, "verfallen": 0, "nachgelegt": 0, "funke": 0,
          "ringe_gekappt": 0, "getaeuscht": 0, "netz": 0, "prankenhieb": 0}
    pol = opt.get("politik", "schlag_haltung")

    def ring(wehr):
        p = RING_WEHR if wehr else RING
        r = rng.random()
        return 0.0 if r < p[0] else (0.5 if r < p[0] + p[1] else 1.0)

    def funke_pruefen(perfekt=False):
        if s["funke_da"] and (perfekt or s["leben"] < 0.5 * lmax):
            s["funke_da"] = False; s["funke_jetzt"] = True; st["funke"] += 1

    def auf_held(g, faktor=1.0, gross=False, bonus=0.0, wehr_hilft=True, schaden=True):
        """Gibt None (verfehlt) oder den Ringfaktor (1 ohne Ring) zurück."""
        wehr = False
        if wehr_hilft and s["bereit"] > 0 and s["haltung"] == "wehr":
            s["bereit"] -= 1; st["wehr"] += 1; wehr = True
            bonus += H["ungunst"]
        if g.kraft:
            g.kraft = False; faktor *= GROSS_FAKTOR; gross = True
        _, abw = sim.held_abwehr(W, held, g.art, waffe_name, True)
        if rng.random() >= sim.trefferchance(W, g.angriff, abw, bonus):
            return None
        f = 1.0
        if gross:
            if s["ringe"] < 2:
                s["ringe"] += 1
                f = ring(wehr)
                if f == 0.0:
                    funke_pruefen(True)
            else:
                st["ringe_gekappt"] += 1
        if schaden:
            sch = sim.schaden_roh(W, g.schaden, g.angriff, -(held.stufe - g.stufe), rng) * faktor * f
            s["leben"] -= sim.endschaden(W, sch, sim.held_abzug(W, held, s["bann"]))
        funke_pruefen()
        return f

    def held_schlag(ziel, aktion="waffe", bonus=0.0, faktor=1.0, antwort=False):
        if aktion == "Funkenpfeil":
            zb = z["Funkenpfeil"]
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
            bonus += H["ungunst"] * opt.get("ducken", 0.0)
        if not antwort and ziel.name == "Riesenfledermaus":
            bonus += H["ungunst"]                                  # flattert
        if not antwort and ziel.offen:
            bonus -= H["ungunst"]; ziel.offen = False              # nach dem Prankenhieb offen
        if rng.random() < sim.trefferchance(W, fw, ziel.abwehr, bonus):
            krit = 0.0 if antwort else sim.krit_prozent(W, held, fert_name, fw)
            sch = sim.schaden_roh(W, grund, fw, held.stufe - ziel.stufe, rng, krit)
            sch *= ziel.schwaeche.get(typ, 1.0) * faktor
            ziel.leben -= sim.endschaden(W, sch, ziel.ruestung)
            if ziel.leben <= 0:
                fallen(ziel)
            return True
        return False

    def fallen(g):
        for m in feld:
            if m.herr is g:
                m.leben = 0                                        # das Rudel flieht mit dem Anführer

    def aktion_fern():
        if "Funkenpfeil" in held.zauber and s["mana"] >= z["Funkenpfeil"]["kosten"]:
            return "Funkenpfeil"
        return "waffe" if fern else None

    def lebend():
        return [g for g in feld if g.leben > 0]

    def gewonnen():
        return all(g.leben <= 0 for g in haupt)

    def ziel_von():
        l = lebend()
        if not l:
            return None
        nah = [g for g in l if g.ab == 0]
        if nah:
            return min(nah, key=lambda g: (g.herr is not None, g.leben))
        sch = [g for g in l if g.name == "Goblin-Schamane"]
        if sch and aktion_fern():
            return sch[0]
        return min(l, key=lambda g: (g.ab, g.herr is not None))

    def antwort_faktor():
        voll = opt.get("gegenschlag_voll") or held.f(waffe_name) >= GESELLE
        return 1.0 if voll else 0.5

    # --- Ansage ---
    def planen():
        for g in lebend():
            g.taeuscht = False
            p = {"gross": False, "art": "schlag"}
            gl = g.glut
            if g.name == "Goblin-Schamane":
                verl = [m for m in lebend() if m is not g and m.leben < 0.6 * m.lmax]
                if verl and rng.random() < 0.6:
                    p["art"] = "heilen"
                elif any(m is not g for m in lebend()) and rng.random() < 0.35:
                    p.update(art="kraft", gross=True)
                else:
                    p["art"] = "stab"
            elif g.name == "Riesenspinne" and g.ab > 0:
                p.update(art="netz", gross=True)
            elif g.name == "Kobold" and g.ab > 0 and not g.lauerte:
                p["art"] = "lauern"
            elif g.name == "Riesenfledermaus":
                p["art"] = "sturz"
            elif g.art != "nah":
                p["gross"] = gl >= 2 and g.anfuehrer and rng.random() < 0.4
                p["art"] = "anlegen" if p["gross"] else "schuss"
            else:
                p["gross"] = g.anfuehrer and gl >= 2 and (g.boss or rng.random() < 0.35) and rng.random() < 0.5
                if p["gross"] and g.name == "Krogg" and gl >= 3 and rng.random() < 0.5:
                    p["art"] = "prankenhieb"
            p["zeigt_gross"] = p["gross"]
            if g.name in TAEUSCHER and g.herr is None and p["art"] in ("schlag", "schuss", "anlegen") and rng.random() < P_TAEUSCH:
                g.taeuscht = True; p["zeigt_gross"] = not p["gross"]
            g.plan = p

    def gesehen(g):
        """(groß, Art) so, wie der Held die Ansage sieht."""
        p = g.plan or {"gross": False, "art": "schlag", "zeigt_gross": False}
        gross = p["gross"] if g.stufe_lesen >= 3 else p["zeigt_gross"]
        art = p["art"] if g.stufe_lesen >= 1 else None
        return gross, art

    def haltung_waehlen():
        if pol == "nur_wehr":
            return "wehr"
        droht = False
        for g in lebend():
            gr, art = gesehen(g)
            if gr and art != "prankenhieb" and art != "kraft":
                droht = True
            if g.kraft:
                droht = True
        if droht:
            return "wehr"
        if aktion_fern():
            return "wachschuss" if any(g.ab > 0 for g in lebend()) else "wehr"
        return "gegenschlag"

    def tun(t, glut, fa):
        nd = glut - 1 if pol == "nachlegen" else 0
        bonus = 0.0; faktor = 1.0
        if nd > 0:
            st["nachgelegt"] += nd
            faktor = 1.0 + opt.get("nachlegen_schaden", NACHLEGEN_SCHADEN) * nd
        held_schlag(t, fa or "waffe", bonus, faktor)
        return glut - 1 - nd

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
            s["bereit"] = glut - 1; s["haltung"] = haltung_waehlen(); return
        if "Wundsegen" in held.zauber and s["leben"] < lmax * z["Wundsegen"]["heilen_unter"] and s["mana"] >= z["Wundsegen"]["kosten"]:
            zb = z["Wundsegen"]; s["mana"] -= zb["kosten"]
            s["leben"] = min(lmax, s["leben"] + round(sim.zauber_grund(W, held, zb) * (1 + held.f(zb["schule"]) / 100.0)))
            s["bereit"] = glut - 1; s["haltung"] = haltung_waehlen(); return
        nahe = [g for g in lebend() if g.ab == 0]
        if fa:
            if nahe and all(g.tempo == "langsam" for g in nahe) and glut >= 2 and frei >= 1:
                glut -= 1
                for g in nahe:
                    g.ab = 1
            if pol == "warten" and not nahe and t.ab > 0 and t.art == "nah":
                s["bereit"] = glut; s["haltung"] = "wachschuss"; return
            s["bereit"] = tun(t, glut, fa); s["haltung"] = haltung_waehlen()
            return
        if t.ab > 0:
            if pol == "warten" and t.tempo != "langsam" and t.art == "nah":      # auch gegen Lauernde: kommen lassen
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
        s["bereit"] = tun(t, glut, None); s["haltung"] = haltung_waehlen()

    def wachschuss(g):
        if s["bereit"] > 0 and s["haltung"] == "wachschuss" and aktion_fern():
            s["bereit"] -= 1; st["wachschuss"] += 1
            held_schlag(g, aktion_fern(), 0.0, antwort_faktor(), antwort=True)

    def gegenschlag(g):
        if s["bereit"] > 0 and s["haltung"] == "gegenschlag" and not aktion_fern():
            s["bereit"] -= 1; st["gegenschlag"] += 1
            held_schlag(g, "waffe", 0.0, antwort_faktor(), antwort=True)

    def heran(g, glut, frei):
        while g.ab > 0 and frei > 0:
            g.ab -= 1; frei -= 1
            wachschuss(g)
            if g.leben <= 0:
                return glut
        while g.ab > 0 and glut > 1:
            g.ab -= 1; glut -= 1
            wachschuss(g)
            if g.leben <= 0:
                return glut
        return glut

    def gegner_zug():
        s["ringe"] = 0
        hetzt = leit.name == "Grimmzahn" and leit.leben > 0
        for g in lebend():
            if s["leben"] <= 0:
                return
            if g.leben <= 0:
                continue
            glut = g.glut
            g.lauert = 0; g.glut_bereit = 0
            p = g.plan or {"gross": False, "art": "schlag"}
            if p["gross"] and g.taeuscht:
                st["getaeuscht"] += 1
            elif not p["gross"] and g.taeuscht:
                st["getaeuscht"] += 1
            if g.name == "Goblin-Schamane":
                if g.ab == 0 and glut >= 2:
                    g.ab = 1; glut -= 1
                andere = [m for m in lebend() if m is not g]
                if p["art"] == "heilen" and andere:
                    m = min(andere, key=lambda m: m.leben / m.lmax)
                    m.leben = min(m.lmax, m.leben + 8); glut -= 1
                elif p["art"] == "kraft" and andere and glut >= 2:
                    min(andere, key=lambda m: m.ab).kraft = True; glut -= 2
                if glut >= 1 and rng.random() < g.chance:
                    auf_held(g)
                continue
            if g.name == "Riesenspinne" and p["art"] == "netz" and g.ab > 0:
                st["netz"] += 1
                f = auf_held(g, gross=True, schaden=False)
                if f is not None and f > 0:
                    g.ab -= 1; s["minus"] = 1
                continue
            if g.art != "nah":
                if g.ab == 0 and glut >= 2:
                    g.ab = 1; glut -= 1
                gross = p["gross"] and glut >= 2
                if rng.random() < g.chance:
                    auf_held(g, GROSS_FAKTOR if gross else 1.0, gross)
                continue
            if p["art"] == "lauern" and g.ab > 0:
                g.lauert = 1; g.glut_bereit = 1; g.lauerte = True
                continue
            g.lauerte = False
            frei = 99 if (hetzt and g.koerper == "Wolf" and g is not leit) else FREI[g.tempo]
            glut = heran(g, glut, frei)
            if g.leben <= 0 or g.ab > 0:
                continue
            gegenschlag(g)
            if g.leben <= 0:
                continue
            if p["art"] == "prankenhieb" and glut >= 3:
                glut -= 3; st["prankenhieb"] += 1
                if g.ueb and g.erster:
                    g.erster = False
                f = auf_held(g, GROSS_FAKTOR, True, wehr_hilft=False)
                if f is not None and f > 0:
                    g.ab = 1
                g.offen = True
            elif p["gross"] and glut >= 2:
                glut -= 2
                if g.ueb and g.erster:
                    g.erster = False
                auf_held(g, GROSS_FAKTOR, True)
            else:
                glut -= 1
                if g.ueb and g.erster and not g.rauch:
                    if auf_held(g, g.ueb["erster_treffer_faktor"], True) is not None:
                        g.erster = False
                        if rng.random() < g.ueb["betaeubt_chance"]:
                            s["betaeubt"] = g.ueb["betaeubt_zuege"]
                elif rng.random() < g.chance:
                    if auf_held(g) is not None and g.umr and rng.random() < g.umr["chance_bei_treffer"]:
                        s["liegt"] = True; s["minus"] = 1
            if g.name == "Riesenfledermaus" and glut >= 1:
                g.ab = 1; glut -= 1                                # löst sich
            elif glut > 0 and g.name in ("Grak", "Kobold"):
                g.lauert = 1; g.glut_bereit = glut

    if leit.ueb and leit.ueb["gegner_zuerst"]:
        planen()
        gegner_zug()
    runde = 0
    while runde < W["lauf"]["max_runden"] and s["leben"] > 0:
        runde += 1
        planen()
        held_zug(runde)
        if gewonnen():
            return dict(st, sieg=True, runden=runde, leben=max(0.0, s["leben"]) / lmax)
        gegner_zug()
        if gewonnen() and s["leben"] > 0:
            return dict(st, sieg=True, runden=runde, leben=max(0.0, s["leben"]) / lmax)
    return dict(st, sieg=False, runden=runde, leben=max(0.0, s["leben"]) / lmax)


KEYS = ("zuege", "gegenschlag", "wachschuss", "wehr", "verfallen", "nachgelegt", "funke", "ringe_gekappt", "getaeuscht",
        "netz", "prankenhieb")


def messe(W, H, held, gegner, n, rng, opt):
    r = [kampf(W, H, held, gegner, rng, opt) for _ in range(n)]
    sg = [x for x in r if x["sieg"]]
    out = {"quote": len(sg) / n, "runden": statistics.mean(x["runden"] for x in sg) if sg else None,
           "leben": statistics.mean(x["leben"] for x in sg) if sg else None}
    for key in KEYS:
        out[key] = statistics.mean(x[key] for x in r)
    return out


def wert(r):
    """Güte einer Politik für die Dominanzprüfung: Sieg zählt, dann Leben am Ende."""
    return r["quote"] * 100 + (r["leben"] or 0) * 20


def heute(W, H, h, gg, n, rng):
    if "+" in gg:
        return None                                                # der alte Rechner kennt keine gemischten Begegnungen
    return hg.messe(W, H, h, gg, n, rng, "heute", {"ring": "spieler"})


FAELLE = [("Rudel", 1), ("Kobold", 1), ("Zombie", 2), ("Goblin-Späher", 2), ("Skelett", 2), ("Wolf+Goblin-Späher", 2),
          ("Riesenfledermaus", 3), ("Kobold+Goblin-Schamane", 3), ("Riesenspinne", 4), ("Krogg", 4), ("Grimmzahn", 5),
          ("Grak", 6)]


def tabelle(titel, faelle, herk, zelle):
    print(f"## {titel}\n")
    print("| Herkunft | " + " | ".join(f"{g} {s_}" for g, s_ in faelle) + " |")
    print("|" + "---|" * (len(faelle) + 1))
    for hk in herk:
        print(f"| {hk} | " + " | ".join(zelle(hk, gg, sf) for gg, sf in faelle) + " |")
    print()


if __name__ == "__main__":
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("--kaempfe", type=int, default=300)
    p.add_argument("--laeufe", type=int, default=25)
    p.add_argument("--unterstufe", type=int, default=0, help="Held so viele Stufen unter dem Gegner (härtere Aufstellung)")
    p.add_argument("--nachlegen", default="0.15,0.20,0.25", help="Prozentsätze für die Dominanzprüfung je Glut")
    a = p.parse_args()
    HIER = os.path.dirname(os.path.abspath(__file__))
    W = sim.lade(os.path.join(HIER, "werte.json"))
    H = sim.lade(os.path.join(HIER, "handgemenge.json"))
    W["monster"]["Rudel"] = dict(W["monster"]["Wolf"], rudel="Jungwolf")
    GEGENWERT["Rudel"] = GEGENWERT["Wolf"]
    rng = random.Random(1411)
    n = a.kaempfe
    herk = list(sim.ohne_info(W["herkuenfte"]))
    fb = {hk: sim.fortschritt_alle(W, hk, a.laeufe, rng, True)["fert_bei"] for hk in herk}
    held = {(hk, sf): hg.held_bei(W, hk, max(1, sf - a.unterstufe), fb[hk]) for hk in herk for _, sf in FAELLE}
    nl = [float(x) for x in a.nachlegen.split(",")]
    V = [("S", {"politik": "schlag_haltung"}), ("W", {"politik": "warten"}), ("Wehr", {"politik": "nur_wehr"})] + \
        [(f"N{round(x * 100)}", {"politik": "nachlegen", "nachlegen_schaden": x}) for x in nl]
    roh = {}
    for hk in herk:
        for gg, sf in FAELLE:
            h = held[(hk, sf)]
            roh[(hk, gg)] = {"heute": heute(W, H, h, gg, n, rng)}
            for name, o in V:
                roh[(hk, gg)][name] = messe(W, H, h, gg, n, rng, o)
    print(f"Unterstufe {a.unterstufe}, je Zelle {n} Kämpfe, Täuschen {round(P_TAEUSCH * 100)} %.\n")

    def lst(hk, gg, sf):
        h = held[(hk, sf)]
        return "/".join(str(lesestufe(h, x, bool(W["monster"][x].get("boss")))) for x in gg.split("+"))
    tabelle("Lesestufe je Gegner (Formel)", FAELLE, herk, lst)

    spalten = ["heute", "S", "W", "Wehr"] + [v[0] for v in V[3:]]
    print("Spalten: " + " / ".join(spalten) + "\n")
    pz = lambda r: "–" if r is None else hg.pz(r["quote"])
    rd = lambda r: "–" if (r is None or not r["runden"]) else f"{r['runden']:.1f}"
    tabelle("Sieg %", FAELLE, herk, lambda hk, gg, sf: "/".join(pz(roh[(hk, gg)][c]) for c in spalten))
    tabelle("Runden bis Sieg", FAELLE, herk, lambda hk, gg, sf: "/".join(rd(roh[(hk, gg)][c]) for c in spalten))

    print("## Dominanz: beste feste Politik je Zelle (S, N, W), mehr als 3 Punkte vorn; Ziel: keine in mehr als einem Viertel\n")
    zelle_zahl = len(herk) * len(FAELLE)
    for x in nl:
        nn = f"N{round(x * 100)}"
        zaehl = {"S": 0, "N": 0, "W": 0, "=": 0}
        for hk in herk:
            for gg, _ in FAELLE:
                w = {"S": wert(roh[(hk, gg)]["S"]), "N": wert(roh[(hk, gg)][nn]), "W": wert(roh[(hk, gg)]["W"])}
                best = max(w, key=w.get)
                m = "=" if w[best] - sorted(w.values())[-2] < 3 else best
                zaehl[m] += 1
        frei = max(zaehl["S"], zaehl["N"], zaehl["W"]) <= zelle_zahl / 4
        print(f"- Nachlegen {round(x * 100)} %: {zaehl} von {zelle_zahl} Zellen → {'erfüllt' if frei else 'NICHT erfüllt'}")
    print()

    print("## Prüfpunkt DESIGN-GLUT.md 10, Stufe 0\n")
    nn = f"N{round(NACHLEGEN_SCHADEN * 100)}"
    krogg = {hk: roh[(hk, "Krogg")]["S"]["quote"] for hk in herk}
    tief = {hk: q for hk, q in krogg.items() if q < 0.15}
    print(f"1. Krogg (Stufe gleich, S): kleinste {min(krogg.values()) * 100:.0f} ({min(krogg, key=krogg.get)}) → "
          + ("erfüllt" if not tief else "NICHT erfüllt: " + ", ".join(tief)))
    lang = []
    for hk in herk:
        for gg, _ in FAELLE:
            r0 = roh[(hk, gg)]["heute"]; r1 = roh[(hk, gg)]["S"]
            if r0 and r0["runden"] and r1["runden"] and r1["runden"] > r0["runden"] + 0.05:
                h = held[(hk, dict(FAELLE)[gg])]                   # nachmessen mit 2000 Kämpfen, 400 streuen um ±0,1
                r0 = heute(W, H, h, gg, 2000, rng); r1 = messe(W, H, h, gg, 2000, rng, {"politik": "schlag_haltung"})
                if r1["runden"] > r0["runden"] + 0.05:
                    lang.append(f"{hk}/{gg} {r1['runden']:.2f} statt {r0['runden']:.2f}")
    print(f"3. Runden (S gegen heute, auffällige Zellen mit 2000 Kämpfen nachgemessen): {len(lang)} Zellen länger" + (": " + "; ".join(lang) if lang else " → erfüllt"))
    print()

    # Wirkung der Lesestufe: S mit fester Stufe 0..3 gegen Täuscher und Krogg
    print("## Wirkung der Lesestufe (S, Sieg % / Leben am Ende %, Stufe 0/1/2/3 erzwungen, auch bei Bossen)\n")
    lf = [("Goblin-Späher", 2), ("Wolf+Goblin-Späher", 2), ("Riesenspinne", 4), ("Krogg", 4), ("Grimmzahn", 5), ("Grak", 6)]

    def les(hk, gg, sf):
        h = held[(hk, sf)]
        out = []
        for stl in range(4):
            r = messe(W, H, h, gg, n, rng, {"politik": "schlag_haltung", "lesestufe": stl})
            out.append(f"{hg.pz(r['quote'])}·{round((r['leben'] or 0) * 100)}")
        return " / ".join(out)
    tabelle("Lesestufe", lf, herk, les)

    print("## S: je Kampf Gegenschlag · Wachschuss · Wehr · verfallen · Funke · getäuscht / Züge\n")
    tabelle("Zähler", FAELLE, herk, lambda hk, gg, sf: (lambda r: f"{r['gegenschlag']:.1f}·{r['wachschuss']:.1f}·{r['wehr']:.1f}·"
            f"{r['verfallen']:.1f}·{r['funke']:.1f}·{r['getaeuscht']:.1f}/{r['zuege']:.1f}")(roh[(hk, gg)]["S"]))
