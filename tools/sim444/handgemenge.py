#!/usr/bin/env python3
"""930.3: Entwurf 930 „Handgemenge und Abstand“ (DESIGN-KAMPF.md) mit 444 gerechnet.

Drei Regelsätze, sonst dieselben Formeln wie sim.py (Treffer, Schaden, Abwehr, Abzug, Zauber, Merkmale):
  heute     Abstand nur im Bild; jeder handelt jede Runde (wie sim.kampf, Prüfung Abschnitt A)
  rueckfall nah/fern; Zug = freier Schritt + Handlung; Tempo als Ungunst; zweimal zurück: außer Atem (Ungunst)
  punkte    nah/fern/weit; zwei Punkte; Weg nach Tempo; Schwung nach Treffer; übriger Punkt Deckung;
            Ausdauer im Kampf (unter einem Viertel ein Punkt, leer erschöpft, Atem holen)
Gemeinsam (rueckfall, punkte): Kampf beginnt fern, beim Überfall nah (Krogg); Rückzug: alle nahen Gegner fern,
der nächste schnelle setzt nach (Schlag mit Ring; bei perfekt bleibt er fern). Jungwölfe und Leibwache sind
eigene Figuren mit Abstand und Tempo, greifen wie in 444 mit ihrer Chance an und fliehen mit dem Anführer.
Nicht gerechnet: Zurückdrängen (Geselle; 444 erreicht in Kapitel 1 höchstens 20 bis 24), Reichweite der Waffe,
Kroggs Prankenhieb, Netz der Spinne, Flucht der Gegner, Hinterhalt-Ring, Last.

Zahlen: werte.json (444) und handgemenge.json (930.3).
Aufruf:
  python3 tools/sim444/handgemenge.py [--kaempfe 1000] [--laeufe 100] [--aus DATEI.md]
"""
import argparse
import json
import os
import random
import statistics
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sim  # noqa: E402

HIER = os.path.dirname(os.path.abspath(__file__))
TEMPI = ["langsam", "normal", "schnell"]
GEGNER_STUFE = [("Rudel", 1), ("Rudel", 2), ("Goblin", 2), ("Zombie", 2), ("Skelett", 2), ("Goblin-Späher", 2),
                ("Krogg", 4), ("Grimmzahn", 5), ("Grak", 6)]


class Gegner:
    def __init__(self, W, H, mon, name, teil=None):
        self.name = name
        self.stufe = mon["stufe"]
        self.art = mon["art"]
        self.abwehr = mon["abwehr"]
        self.ruestung = mon["ruestung"]
        self.schwaeche = mon.get("schwaeche", {})
        koerper = teil["koerper"] if teil else name
        if teil:
            self.angriff = mon["angriff"] + teil["angriff_verschiebung"]
            self.schaden = mon["schaden"] * teil["schaden_anteil"]
            self.leben = round(mon["leben"] * teil.get("leben_anteil", 1.0))
            self.chance = teil["chance"]
            self.anfuehrer = False
        else:
            self.angriff = mon["angriff"]
            self.schaden = mon["schaden"]
            self.leben = mon["leben"]
            self.chance = 1.0
            self.anfuehrer = True
        self.koerper = koerper
        self.tempo = H["tempo_gegner"].get(koerper, "normal")
        a = H["ausdauer"]["gegner"]
        self.amax = None if koerper in H["ohne_atem"] else a["basis"] + a["je_stufe"] * self.stufe
        self.ausdauer = self.amax
        self.ruht = False
        self.ab = 1
        self.ueb = W["merkmale"]["ueberfall"] if (mon.get("ueberfall") and not teil) else None
        self.umr = W["merkmale"]["umreissen"] if (mon.get("umreissen") and not teil) else None
        self.rauch = bool(mon.get("rauch"))
        self.erster = True


def held_tempo(H, held):
    t = H["held_tempo"]
    i = 1
    if held.werte["gewandtheit"] >= t["schnell_ab_gewandtheit"] and held.ruestung not in t["stufe_weniger"]:
        i = 2
    if held.ruestung in t["stufe_weniger"]:
        i -= 1
    return TEMPI[max(0, i)]


def ausdauer_max(H, held):
    a = H["ausdauer"]
    return a["basis"] + a["je_zaehigkeit"] * held.werte["zaehigkeit"] + a["je_wille"] * held.werte["wille"] + a["je_stufe"] * held.stufe


def kampf(W, H, held, mon_name, rng, modus, opt=None):
    """Ein Kampf; opt: schwung, deckung_statt_schwung, zwei_handlungen, eroeffnung (fern/weit), ring (keiner/gut/spieler),
    deckung_anteil, schwung_ziel (frei/anderes/ungunst), gegner_atem, kosten_faktor. Gibt sieg, runden, leben (Anteil), atem (Züge mit Atem holen), erschoepft, zaehler (Bewegungen)."""
    opt = opt or {}
    k = W["kampf"]
    z = W["zauber"]
    mon = W["monster"][mon_name]
    feld = [Gegner(W, H, mon, mon_name)]
    if mon.get("rudel"):
        rud = W["merkmale"]["rudel"][mon["rudel"]]
        n = rng.randint(*rud["anzahl"]) if isinstance(rud["anzahl"], list) else rud["anzahl"]
        feld += [Gegner(W, H, mon, rud["koerper"], rud) for _ in range(n)]
    leit = feld[0]
    abstand = modus != "heute"
    weit_max = 2 if modus == "punkte" else 1
    start = 0 if leit.ueb else (2 if opt.get("eroeffnung") == "weit" and modus == "punkte" else 1)
    for g in feld:
        g.ab = start if abstand else 0
    waffe_name = held.waffe
    waffe = W["waffen"][waffe_name]
    fern = waffe["art"] == "fern"
    tempo = held_tempo(H, held)
    weg = H["wegkosten"]
    ung = H["ungunst"]
    A = H["ausdauer"]
    s = {"leben": held.leben_max(), "mana": held.mana_max(), "bann": 0.0, "liegt": False, "betaeubt": 0,
         "rueck": 0, "ausser_atem": False, "deckung": False, "ausdauer": ausdauer_max(H, held), "erschoepft": False}
    lmax = s["leben"]
    amax = s["ausdauer"]
    st = {"atem": 0, "erschoepft": 0, "held_schlaege": 0, "held_wege": 0, "gegner_schlaege": 0, "gegner_wege": 0,
          "nachsetzen": 0, "rueckzug": 0, "deckung": 0, "schwung": 0}
    ring = opt.get("ring", "keiner")
    rs = H["ring_spieler"]
    d_anteil = opt.get("deckung_anteil", H["deckung"]["anteil"])

    def ring_anteil():
        if ring == "gut":
            return 0.5
        if ring == "spieler":
            r = rng.random()
            return 0.0 if r < rs["perfekt"] else (0.5 if r < rs["perfekt"] + rs["gut"] else 1.0)
        return 1.0

    def auf_held(g, faktor=1.0, bonus=0.0, mit_ring=None):
        """Schlag eines Gegners; True bei Treffer. mit_ring: angesagter Schlag (Anführer, Nachsetzen)."""
        mit_ring = g.anfuehrer if mit_ring is None else mit_ring
        st["gegner_schlaege"] += 1
        _, abw = sim.held_abwehr(W, held, g.art, waffe_name, True)
        if rng.random() >= sim.trefferchance(W, g.angriff, abw, bonus):
            return False
        sch = sim.schaden_roh(W, g.schaden, g.angriff, -(held.stufe - g.stufe), rng) * faktor
        if mit_ring:
            sch *= ring_anteil()
            if s["deckung"]:
                sch *= d_anteil
        s["leben"] -= sim.endschaden(W, sch, sim.held_abzug(W, held, s["bann"]))
        return True

    def gegner_schlag(g, bonus=0.0):
        if g.ueb and g.erster and g.rauch:
            g.erster = False
            st["gegner_schlaege"] += 1
        elif g.ueb and g.erster:
            if auf_held(g, g.ueb["erster_treffer_faktor"], bonus):
                g.erster = False
                if rng.random() < g.ueb["betaeubt_chance"]:
                    s["betaeubt"] = g.ueb["betaeubt_zuege"]
        elif rng.random() < g.chance:
            if auf_held(g, 1.0, bonus) and g.umr and rng.random() < g.umr["chance_bei_treffer"]:
                s["liegt"] = True

    def held_schlag(ziel, aktion="waffe", bonus=0.0):
        st["held_schlaege"] += 1
        if aktion == "Funkenpfeil":
            zb = z["Funkenpfeil"]
            s["mana"] -= zb["kosten"]
            fert_name, grund, typ = zb["schule"], zb["schaden"] + held.werte["wille"], zb["typ"]
        else:
            fert_name = waffe_name
            gw = waffe["grundwert"]
            grund = waffe["schaden"] + (held.werte[gw] if gw else 0)
            typ = waffe["typ"]
            if waffe["art"] == "fern":
                bonus += k["fernkampf_treffer_je_wahrnehmung"] * held.werte["wahrnehmung"]
        fw = held.f(fert_name)
        if s["liegt"]:
            bonus += W["merkmale"]["umreissen"]["naechster_angriff_treffer"]
            s["liegt"] = False
        if s["ausser_atem"]:
            bonus += ung
        if rng.random() < sim.trefferchance(W, fw, ziel.abwehr, bonus):
            sch = sim.schaden_roh(W, grund, fw, held.stufe - ziel.stufe, rng,
                                  k["kritisch_prozent_je_gewandtheit"] * held.werte["gewandtheit"])
            sch *= ziel.schwaeche.get(typ, 1.0)
            ziel.leben -= sim.endschaden(W, sch, ziel.ruestung)
            return True
        return False

    def nebenhandlung(runde):
        """Bannschild, Wundsegen (wie sim.kampf). Gibt den Namen oder None."""
        if "Bannschild" in held.zauber and runde == 1 and s["mana"] >= z["Bannschild"]["kosten"]:
            zb = z["Bannschild"]
            s["mana"] -= zb["kosten"]
            s["bann"] = zb["ruestung"] * (1 + held.f(zb["schule"]) * k["ruestungsfertigkeit_im_abzug_je_punkt"])
            return "Bannschild"
        if "Wundsegen" in held.zauber and s["leben"] < lmax * z["Wundsegen"]["heilen_unter"] and s["mana"] >= z["Wundsegen"]["kosten"]:
            zb = z["Wundsegen"]
            s["mana"] -= zb["kosten"]
            s["leben"] = min(lmax, s["leben"] + round((zb["heilung"] + held.werte["wille"]) * (1 + held.f(zb["schule"]) / 100.0)))
            return "Wundsegen"
        return None

    def angriff_art():
        if "Funkenpfeil" in held.zauber and s["mana"] >= z["Funkenpfeil"]["kosten"]:
            return "Funkenpfeil"
        return "waffe"

    def kosten(aktion):
        return opt.get("kosten_faktor", 1.0) * (A["kosten"]["zauber"] if aktion == "Funkenpfeil" else A["kosten"][waffe_name])

    def lebend():
        return [g for g in feld if g.leben > 0]

    def rueckzug():
        st["rueckzug"] += 1
        nahe = [g for g in lebend() if g.ab == 0]
        for g in lebend():
            g.ab = min(weit_max, g.ab + 1)
        schnell = [g for g in nahe if g.tempo == "schnell"]
        if schnell:     # Nachsetzen: höchstens einer, der Anführer zuerst
            g = schnell[0]
            st["nachsetzen"] += 1
            r = ring_anteil() if ring != "keiner" else 1.0
            if r > 0:
                g.ab = 0
                auf_held(g, 1.0, 0.0, mit_ring=False) if r == 1.0 else _halb(g)
        s["rueck"] += 1
        if modus == "rueckfall" and s["rueck"] >= 2:
            s["ausser_atem"] = True
        if modus == "punkte" and s["rueck"] >= 2:
            s["ausdauer"] -= A["zweiter_rueckzug"]

    def _halb(g):
        alt = s["leben"]
        if auf_held(g, 1.0, 0.0, mit_ring=False):
            s["leben"] = alt - (alt - s["leben"]) * 0.5

    # ---------------------------------------------------------------- Zug des Helden
    def zug_heute(runde):
        if s["betaeubt"] > 0:
            s["betaeubt"] -= 1
            return
        if nebenhandlung(runde):
            return
        held_schlag(leit, angriff_art())

    def zug_rueckfall(runde):
        if s["betaeubt"] > 0:
            s["betaeubt"] -= 1
            return
        aktion = angriff_art()
        weit_aktion = fern or aktion == "Funkenpfeil"
        nahe = [g for g in lebend() if g.ab == 0]
        zurueck = vor = False
        # zurück nur, wenn es nicht außer Atem macht (ein zweites Mal hintereinander gäbe den eigenen Schüssen Ungunst)
        if weit_aktion and nahe and not any(g.tempo == "schnell" for g in nahe) and s["rueck"] == 0:
            rueckzug()
            zurueck = True
        bonus = 0.0
        if not weit_aktion and leit.ab > 0:
            leit.ab = 0
            st["held_wege"] += 1
            vor = True
        if not zurueck:
            s["rueck"] = 0
            if not vor:
                s["ausser_atem"] = False     # einen Zug lang stehen geblieben
        if vor and tempo == "langsam":
            return
        if vor and tempo == "normal":
            bonus = ung
        if nebenhandlung(runde):
            return
        held_schlag(leit, aktion, bonus)

    def zug_punkte(runde):
        s["deckung"] = False
        if s["betaeubt"] > 0:
            s["betaeubt"] -= 1
            return
        if s["erschoepft"]:
            s["erschoepft"] = False
            st["atem"] += 1
            s["ausdauer"] = min(amax, s["ausdauer"] + A["atem_holen"] * amax)
            s["rueck"] = 0
            return
        pkt = 1.0 if s["ausdauer"] < A["viertel"] * amax else float(H["punkte"])
        aktion = angriff_art()
        weit_aktion = fern or aktion == "Funkenpfeil"
        # Atem holen, wenn der nächste Schlag die Ausdauer leeren würde (Auto setzt nie unfreiwillig aus)
        if s["ausdauer"] - kosten(aktion) <= 0 and leit.leben > 3:
            st["atem"] += 1
            s["ausdauer"] = min(amax, s["ausdauer"] + A["atem_holen"] * amax)
            s["rueck"] = 0
            return
        gezogen = False
        if opt.get("zwei_handlungen", True) and pkt >= 2:
            if nebenhandlung(runde):
                pkt -= 1
        elif nebenhandlung(runde):
            s["rueck"] = 0
            return
        nahe = [g for g in lebend() if g.ab == 0]
        if weit_aktion:
            # zurück nur, wenn es einen Schlag spart: alle nahen Gegner langsam (normale rücken nach und schlagen trotzdem)
            if pkt >= 2 and nahe and all(g.tempo == "langsam" for g in nahe) and s["ausdauer"] > A["zweiter_rueckzug"] + kosten(aktion):
                rueckzug()
                pkt -= 1
                gezogen = True
        else:
            kw = weg[tempo]
            while leit.ab > 0 and pkt >= kw:
                leit.ab -= 1
                pkt -= kw
                st["held_wege"] += 1
        if not gezogen:
            s["rueck"] = 0
        if pkt < 1 or (not weit_aktion and leit.ab > 0):
            if pkt >= 1:
                s["deckung"] = True
                st["deckung"] += 1
            return
        s["ausdauer"] -= kosten(aktion)
        pkt -= 1
        traf = held_schlag(leit, aktion)
        if s["ausdauer"] <= 0:
            s["erschoepft"] = True
            st["erschoepft"] += 1
        if leit.leben <= 0 or pkt < 1:
            return
        will_schwung = (traf and not weit_aktion and opt.get("schwung", True) and not opt.get("deckung_statt_schwung")
                        and s["ausdauer"] - kosten(aktion) > 0 and s["ausdauer"] >= A["viertel"] * amax)
        ziel, bonus = leit, 0.0
        if will_schwung and opt.get("schwung_ziel") == "anderes":
            andere = [g for g in lebend() if g.ab == 0 and g is not leit]
            ziel = andere[0] if andere else None
            will_schwung = ziel is not None
        elif opt.get("schwung_ziel") == "ungunst":
            bonus = ung
        if will_schwung:
            st["schwung"] += 1
            s["ausdauer"] -= kosten(aktion)
            held_schlag(ziel, aktion, bonus)
        else:
            s["deckung"] = True
            st["deckung"] += 1

    # ---------------------------------------------------------------- Zug der Gegner
    def gegner_zug():
        hetzt = leit.name == "Grimmzahn" and leit.leben > 0
        for g in lebend():
            if s["leben"] <= 0:
                return
            if not abstand:
                gegner_schlag(g)
                continue
            if g.ruht:
                g.ruht = False
                g.ausdauer = min(g.amax, g.ausdauer + H["ausdauer"]["atem_holen"] * g.amax)
                continue
            bonus = 0.0
            if g.art != "nah":
                pass
            elif modus == "rueckfall":
                if g.ab > 0:
                    g.ab = 0
                    st["gegner_wege"] += 1
                    if g.tempo == "langsam":
                        continue
                    if g.tempo == "normal":
                        bonus = ung
            else:
                pkt = float(H["punkte"])
                kw = 0.0 if (hetzt and g.koerper == "Wolf" and g is not leit) else weg[g.tempo]
                while g.ab > 0 and pkt >= kw:
                    g.ab -= 1
                    pkt -= kw
                    st["gegner_wege"] += 1
                if g.ab > 0 or pkt < 1:
                    continue
            gegner_schlag(g, bonus)
            if modus == "punkte" and g.amax is not None and opt.get("gegner_atem", True):
                g.ausdauer -= H["ausdauer"]["gegner"]["biss"]
                if g.ausdauer <= 0:
                    g.ruht = True

    zug = {"heute": zug_heute, "rueckfall": zug_rueckfall, "punkte": zug_punkte}[modus]
    if leit.ueb and leit.ueb["gegner_zuerst"]:
        gegner_zug()
    runde = 0
    while runde < W["lauf"]["max_runden"] and s["leben"] > 0:
        runde += 1
        zug(runde)
        if leit.leben <= 0:
            return dict(st, sieg=True, runden=runde, leben=max(0.0, s["leben"]) / lmax)
        gegner_zug()
    return dict(st, sieg=False, runden=runde, leben=max(0.0, s["leben"]) / lmax)


def messe(W, H, held, gegner, n, rng, modus, opt=None):
    r = [kampf(W, H, held, gegner, rng, modus, opt) for _ in range(n)]
    sg = [x for x in r if x["sieg"]]
    out = {"quote": len(sg) / n, "runden": statistics.mean(x["runden"] for x in sg) if sg else None,
           "leben": statistics.mean(x["leben"] for x in sg) if sg else None}
    for key in ("atem", "erschoepft", "held_schlaege", "held_wege", "gegner_schlaege", "gegner_wege", "nachsetzen",
                "rueckzug", "deckung", "schwung"):
        out[key] = statistics.mean(x[key] for x in r)
    out["runden_alle"] = statistics.mean(x["runden"] for x in r)
    out["mit_erschoepft"] = sum(1 for x in r if x["erschoepft"] > 0) / n
    return out


def held_bei(W, hk, stufe, fert_bei, ruestung=None):
    h = sim.held_auf_stufe(W, hk, stufe, fert_bei.get(stufe) or fert_bei[max(fert_bei)], True)
    if ruestung:
        alt = W["ruestungen"][h.ruestung]["fertigkeit"]
        h.fert[ruestung] = h.fert.get(alt, W["held"]["startfertigkeit"]) if alt else W["held"]["startfertigkeit"]
        h.ruestung = ruestung
    return h


def pz(q):
    return "–" if q is None else f"{round(q * 100)}"


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--kaempfe", type=int, default=1000)
    p.add_argument("--laeufe", type=int, default=100)
    p.add_argument("--aus")
    a = p.parse_args()
    W = sim.lade(os.path.join(HIER, "werte.json"))
    H = sim.lade(os.path.join(HIER, "handgemenge.json"))
    W["monster"]["Rudel"] = dict(W["monster"]["Wolf"], rudel="Jungwolf")
    n = a.kaempfe
    rng = random.Random(930)
    herk = list(sim.ohne_info(W["herkuenfte"]))
    fb = {}
    for hk in herk:
        fb[hk] = sim.fortschritt_alle(W, hk, a.laeufe, rng, True)["fert_bei"]
        print(f"  {hk} Fortschritt", file=sys.stderr)
    L = []
    w = L.append
    w("# 930.3: Handgemenge und Abstand mit 444 gerechnet\n")
    w(f"`tools/sim444/handgemenge.py` (Zahlen `handgemenge.json`, A), je Zelle {n} Kämpfe, Held mit 21 Punkten und den mittleren "
      f"Fertigkeiten aus 444 ({a.laeufe} Läufe), Autopilot, ohne Ring, ohne Tränke (wie 444). "
      "Zelle: Sieg % heute / Rückfall / Punkte.\n")

    # A Prüfung gegen 444
    w("## A Prüfung: „heute“ dieses Modells gegen sim.kampf (Sieg %)\n")
    w("| Fall | sim.kampf | heute hier |\n|---|---|---|")
    for hk, gg, sf in [("Wachsoldat", "Rudel", 1), ("Zauberlehrling", "Rudel", 1), ("Jägerkind", "Goblin", 2), ("Wachsoldat", "Krogg", 4),
                       ("Wanderer", "Grimmzahn", 5), ("Klosterschüler", "Grak", 6)]:
        h = held_bei(W, hk, sf, fb[hk])
        q0 = sum(1 for _ in range(n) if sim.kampf(W, h, W["monster"][gg], rng)["sieg"]) / n
        q1 = messe(W, H, h, gg, n, rng, "heute")["quote"]
        w(f"| {hk} St. {sf} gegen {gg} | {pz(q0)} | {pz(q1)} |")
    w("")

    # B Siegquoten je Herkunft
    w("## B Siegquote je Herkunft (heute / Rückfall / Punkte), Heldenstufe = Stufe des Gegners, Rudel auch Stufe 2\n")
    kopf = "| Herkunft (Tempo, Ausdauer St. 1) | " + " | ".join(f"{g} St. {s}" for g, s in GEGNER_STUFE) + " |"
    w(kopf)
    w("|" + "---|" * (len(GEGNER_STUFE) + 1))
    roh = {}
    for hk in herk:
        h1 = held_bei(W, hk, 1, fb[hk])
        zellen = []
        for gg, sf in GEGNER_STUFE:
            h = held_bei(W, hk, sf, fb[hk])
            r = {m: messe(W, H, h, gg, n, rng, m) for m in ("heute", "rueckfall", "punkte")}
            roh[(hk, gg, sf)] = r
            zellen.append(" / ".join(pz(r[m]["quote"]) for m in ("heute", "rueckfall", "punkte")))
        w(f"| {hk} ({held_tempo(H, h1)}, {ausdauer_max(H, h1)}) | " + " | ".join(zellen) + " |")
        print(f"  {hk} B", file=sys.stderr)
    w("")
    w("Runden bis zum Sieg (heute / Punkte) und Atem-Züge je Kampf (Punkte):\n")
    w("| Herkunft | " + " | ".join(f"{g} St. {s}" for g, s in GEGNER_STUFE) + " |")
    w("|" + "---|" * (len(GEGNER_STUFE) + 1))
    for hk in herk:
        z = []
        for gg, sf in GEGNER_STUFE:
            r = roh[(hk, gg, sf)]
            rh, rp = r["heute"]["runden"], r["punkte"]["runden"]
            z.append(f"{rh:.1f} / {rp:.1f} · {r['punkte']['atem']:.1f}" if rh and rp else "–")
        w(f"| {hk} | " + " | ".join(z) + " |")
    w("")

    w("Punkte abgestimmt (Schwung gegen dasselbe Ziel mit Ungunst, Ausdauer-Kosten doppelt), Sieg % heute / abgestimmt:\n")
    w("| Herkunft | " + " | ".join(f"{g} St. {s}" for g, s in GEGNER_STUFE) + " |")
    w("|" + "---|" * (len(GEGNER_STUFE) + 1))
    for hk in herk:
        z = []
        for gg, sf in GEGNER_STUFE:
            h = held_bei(W, hk, sf, fb[hk])
            r = messe(W, H, h, gg, n, rng, "punkte", {"schwung_ziel": "ungunst", "kosten_faktor": 2.0})
            z.append(f"{pz(roh[(hk, gg, sf)]['heute']['quote'])} / {pz(r['quote'])}")
        w(f"| {hk} | " + " | ".join(z) + " |")
    w("")
    w("Höchste Fertigkeit je Herkunft auf Heldenstufe 6 (444; Zurückdrängen ab Rang Geselle = 25, Rangdecke Kapitel 1: 24 bis zur Bewährungsprobe):\n")
    w(", ".join(f"{hk} {max(fb[hk][max(fb[hk])].values())}" for hk in herk) + "\n")

    # C Fernkampf und Magie von weit
    w("## C Schütze und Magier: Eröffnung fern gegen weit (Punkte), Sieg % · Schläge der Gegner je Kampf\n")
    w("| Held | Gegner | heute | Rückfall | Punkte fern | Punkte weit | Rückzüge je Kampf (weit) |\n|---|---|---|---|---|---|---|")
    for hk in ("Zauberlehrling", "Jägerkind"):
        for gg, sf in [("Rudel", 1), ("Goblin", 2), ("Zombie", 2), ("Skelett", 2), ("Grak", 6)]:
            h = held_bei(W, hk, sf, fb[hk])
            r0 = messe(W, H, h, gg, n, rng, "heute")
            rr = messe(W, H, h, gg, n, rng, "rueckfall")
            r1 = messe(W, H, h, gg, n, rng, "punkte")
            r2 = messe(W, H, h, gg, n, rng, "punkte", {"eroeffnung": "weit"})
            w(f"| {hk} St. {sf} | {gg} | {pz(r0['quote'])} · {r0['gegner_schlaege']:.1f} | {pz(rr['quote'])} · {rr['gegner_schlaege']:.1f} | "
              f"{pz(r1['quote'])} · {r1['gegner_schlaege']:.1f} | "
              f"{pz(r2['quote'])} · {r2['gegner_schlaege']:.1f} | {r2['rueckzug']:.1f} |")
    w("")

    # D Woher der Unterschied
    w("## D Woher der Unterschied (Punkte zerlegt), Sieg % · Runden\n")
    w("Spalten: heute; Punkte wie oben; ohne Schwung; Schwung nur gegen ein anderes nahes Ziel; Schwung gegen dasselbe Ziel mit Ungunst; "
      "streng eine Handlung je Zug (Zauber oder Heilen statt des Schlags, wie heute); Gegner ohne Ausdauer; Ausdauer-Kosten doppelt; "
      "Schwung mit Ungunst und doppelte Kosten.\n")
    var = [("heute", "heute", None), ("Punkte", "punkte", None), ("ohne Schwung", "punkte", {"schwung": False}),
           ("Schwung anderes Ziel", "punkte", {"schwung_ziel": "anderes"}), ("Schwung mit Ungunst", "punkte", {"schwung_ziel": "ungunst"}),
           ("eine Handlung", "punkte", {"zwei_handlungen": False}), ("Gegner ohne Ausdauer", "punkte", {"gegner_atem": False}),
           ("Kosten ×2", "punkte", {"kosten_faktor": 2.0}), ("Ungunst und Kosten ×2", "punkte", {"schwung_ziel": "ungunst", "kosten_faktor": 2.0})]
    w("| Held | Gegner | " + " | ".join(v[0] for v in var) + " |")
    w("|" + "---|" * (len(var) + 2))
    for hk, gg, sf in [("Wachsoldat", "Rudel", 1), ("Kräutersammler", "Rudel", 1), ("Schmiedelehrling", "Rudel", 1), ("Kräutersammler", "Skelett", 2),
                       ("Kräutersammler", "Krogg", 4), ("Herumtreiber", "Krogg", 4), ("Wanderer", "Grimmzahn", 5), ("Klosterschüler", "Grimmzahn", 5),
                       ("Zauberlehrling", "Grak", 6), ("Schmiedelehrling", "Grak", 6), ("Kräutersammler", "Grak", 6)]:
        h = held_bei(W, hk, sf, fb[hk])
        c = []
        for _, m, o in var:
            r = messe(W, H, h, gg, n, rng, m, o)
            c.append(f"{pz(r['quote'])} · {r['runden'] or 0:.1f}")
        w(f"| {hk} St. {sf} | {gg} | " + " | ".join(c) + " |")
    w("")

    # E Wächter in schwerer Rüstung
    w("## E Schwere Rüstung (I.3, Tempo eine Stufe langsamer), Punkte, Sieg % · Leben am Ende % · Runden\n")
    w("| Held | Gegner | mittlere bzw. leichte Rüstung | schwere Rüstung |\n|---|---|---|---|")
    for hk, gg, sf in [("Wachsoldat", "Rudel", 1), ("Wachsoldat", "Goblin-Späher", 2), ("Wachsoldat", "Grimmzahn", 5), ("Wachsoldat", "Grak", 6),
                       ("Wanderer", "Rudel", 1), ("Wanderer", "Goblin-Späher", 2), ("Wanderer", "Grimmzahn", 5)]:
        c = []
        for ru in (None, "Schwere Rüstung"):
            h = held_bei(W, hk, sf, fb[hk], ru)
            r = messe(W, H, h, gg, n, rng, "punkte")
            c.append(f"{pz(r['quote'])} · {pz(r['leben'])} · {r['runden'] or 0:.1f} ({held_tempo(H, h)})")
        w(f"| {hk} St. {sf} | {gg} | {c[0]} | {c[1]} |")
    w("")

    # F Deckung
    w("## F Deckung (I.5): nach einem Treffer decken statt Schwung; Anteil des Schadens angesagter Schläge, der durch die Deckung geht\n")
    w("Zelle: Sieg % · Leben am Ende %. Mit Ring eines mittleren Spielers (handgemenge.json ring_spieler) gegen angesagte Schläge; "
      "„Schwung“: zweiter Schlag nach jedem Treffer, Deckung nur nach Fehlschlag; „decken x“: nach einem Treffer immer decken.\n")
    anteile = [1.0, 0.75, 0.5, 0.25, 0.0]
    w("| Held | Gegner | Schwung | " + " | ".join(f"decken {x:.2f}" for x in anteile) + " |")
    w("|" + "---|" * (len(anteile) + 3))
    for hk, gg, sf in [("Wachsoldat", "Rudel", 1), ("Wanderer", "Rudel", 1), ("Kräutersammler", "Rudel", 1), ("Wachsoldat", "Krogg", 4),
                       ("Wanderer", "Grimmzahn", 5), ("Schmiedelehrling", "Grak", 6)]:
        h = held_bei(W, hk, sf, fb[hk])
        r0 = messe(W, H, h, gg, n, rng, "punkte", {"ring": "spieler"})
        c = [f"{pz(r0['quote'])} · {pz(r0['leben'])}"]
        for x in anteile:
            r = messe(W, H, h, gg, n, rng, "punkte", {"deckung_statt_schwung": True, "deckung_anteil": x, "ring": "spieler"})
            c.append(f"{pz(r['quote'])} · {pz(r['leben'])}")
        w(f"| {hk} St. {sf} | {gg} | " + " | ".join(c) + " |")
    w("")

    # G Ausdauer
    w("## G Ausdauer im Kampf: Vorrat je Stufe (Leben daneben) und Anteil Kämpfe mit „erschöpft“ (Punkte)\n")
    w("| Herkunft | Ausdauer St. 1 / 3 / 6 | Leben St. 1 / 3 / 6 | Kosten Schlag | erschöpft Rudel St. 1 | Atem-Züge Grak St. 6 |\n|---|---|---|---|---|---|")
    for hk in herk:
        hs = [held_bei(W, hk, s_, fb[hk]) for s_ in (1, 3, 6)]
        r1 = roh[(hk, "Rudel", 1)]["punkte"]
        r6 = roh[(hk, "Grak", 6)]["punkte"]
        w(f"| {hk} | {' / '.join(str(ausdauer_max(H, x)) for x in hs)} | {' / '.join(str(x.leben_max()) for x in hs)} | "
          f"{H['ausdauer']['kosten'][hs[0].waffe]} | {pz(r1['mit_erschoepft'])} % | {r6['atem']:.1f} |")
    w("")

    w("Ausdauer-Kosten verändert (alle Kosten mal Faktor), Punkte: Sieg % · Atem-Züge je Kampf\n")
    fk = [1.0, 1.5, 2.0, 3.0]
    w("| Held | Gegner | " + " | ".join(f"Kosten ×{x}" for x in fk) + " |")
    w("|" + "---|" * (len(fk) + 2))
    for hk, gg, sf in [("Wachsoldat", "Rudel", 1), ("Wanderer", "Rudel", 1), ("Jägerkind", "Rudel", 1), ("Wachsoldat", "Grak", 6),
                       ("Wanderer", "Grimmzahn", 5), ("Schmiedelehrling", "Grak", 6)]:
        h = held_bei(W, hk, sf, fb[hk])
        c = []
        for x in fk:
            r = messe(W, H, h, gg, n, rng, "punkte", {"kosten_faktor": x})
            c.append(f"{pz(r['quote'])} · {r['atem']:.1f}")
        w(f"| {hk} St. {sf} | {gg} | " + " | ".join(c) + " |")
    w("")

    # H Bewegungen je Runde (für den Takt F9)
    w("## H Was je Runde geschieht (Rudel St. 1, Mittel über alle Runden): Schläge und Wege\n")
    w("| Herkunft | heute: Held-Schläge · Gegner-Schläge | Punkte: Held-Schläge · Held-Wege · Gegner-Schläge · Gegner-Wege | Runden heute / Punkte |\n|---|---|---|---|")
    for hk in herk:
        r = roh[(hk, "Rudel", 1)]
        h0, p0 = r["heute"], r["punkte"]
        rh, rp = h0["runden_alle"], p0["runden_alle"]
        w(f"| {hk} | {h0['held_schlaege'] / rh:.2f} · {h0['gegner_schlaege'] / rh:.2f} | {p0['held_schlaege'] / rp:.2f} · {p0['held_wege'] / rp:.2f} · "
          f"{p0['gegner_schlaege'] / rp:.2f} · {p0['gegner_wege'] / rp:.2f} | {rh:.1f} / {rp:.1f} |")
    w("")
    text = "\n".join(L) + "\n"
    if a.aus:
        with open(a.aus, "w", encoding="utf-8") as f:
            f.write(text)
    else:
        sys.stdout.write(text)


if __name__ == "__main__":
    main()
