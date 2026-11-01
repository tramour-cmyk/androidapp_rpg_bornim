#!/usr/bin/env python3
"""Vorgang 444: Rechensimulation Spielsystem 2.0 am Rechner (ohne Godot).

Regeln: DESIGN-SPIELSYSTEM-2-0-ENTWURF.md (Modell D, Abschnitt 4), Monster: LISTE-BESTIARIUM.md
"Werte 2.0". Jede Zahl steht in werte.json, keine im Code.

Aufruf:
  python3 tools/sim444/sim.py                 # Tabelle nach stdout (Markdown)
  python3 tools/sim444/sim.py --aus DATEI.md  # Tabelle in Datei
  python3 tools/sim444/sim.py --werte andere.json --kaempfe 200 --laeufe 100   # schneller Probelauf
  python3 tools/sim444/sim.py --pruefen       # Rechenbeispiele aus Modell D nachrechnen (Exit-Code)

Zwei Teile:
  1. Fortschritt: je Herkunft ein Held ab Stufe 1, Zufallsbegegnungen seines Stufenbands bis zur
     Kapitelgrenze; misst Kaempfe je Stufe, Anteil Erfahrung aus Fertigkeiten, Niederlagen,
     Fertigkeitswerte beim Erreichen jeder Stufe.
  2. Kampfmatrix: je Herkunft, Heldenstufe 1-6 (mit den mittleren Fertigkeiten aus Teil 1) und
     Art/Boss je N Kaempfe; misst Siegquote, Zuege bis Sieg, Leben am Ende.
"""
import argparse
import json
import os
import random
import statistics
import sys

GRUNDWERTE = ["kraft", "gewandtheit", "zaehigkeit", "verstand", "wille", "wahrnehmung"]


def lade(pfad):
    with open(pfad, encoding="utf-8") as f:
        return json.load(f)


def ohne_info(d):
    return {k: v for k, v in d.items() if not k.startswith("_")}


# ---------------------------------------------------------------- Held

class Held:
    def __init__(self, W, herkunft, variante=False):
        self.W = W
        h = W["held"]
        hk = W["herkuenfte"][herkunft]
        self.herkunft = herkunft
        self.werte = {g: h["grundwert_min"] for g in GRUNDWERTE}
        for g, p in hk["plus"].items():
            self.werte[g] += p
        if variante:
            for g, p in hk.get("plus_variante", {}).items():
                self.werte[g] += p
        for g in GRUNDWERTE:
            self.werte[g] = min(self.werte[g], h["grundwert_max"])
        self.stufe = 1
        self.fert = {}      # Name -> Wert
        self.uebung = {}    # Name -> gesammelte Uebung
        self.decke = {}     # Name -> aktuelle Rangdecke
        self.probe = {}     # Name -> Siege fuer die Bewaehrungsprobe
        for f in hk["fertigkeiten"]:
            self.fert[f] = h["startfertigkeit"]
        self.waffe = hk["waffe"]
        self.ruestung = hk["ruestung"]
        self.schild = hk["schild"]
        self.zauber = list(hk["zauber"])
        # Erfahrung
        self.ep = 0.0
        self.ep_fert_stufe = 0.0
        self.ep_quelle = {"kampf": 0.0, "fertigkeit": 0.0, "probe": 0.0, "fertigkeit_verfallen": 0.0}
        self.deckel_erreicht = 0

    def f(self, name):
        return self.fert.get(name, 0)

    def leben_max(self):
        h = self.W["held"]
        return h["leben_basis"] + h["leben_je_stufe"] * self.stufe + h["leben_je_zaehigkeit"] * self.werte["zaehigkeit"]

    def mana_max(self):
        h = self.W["held"]
        return h["mana_basis"] + h["mana_je_wille"] * self.werte["wille"]

    def ep_bedarf(self):
        return self.W["erfahrung"]["bis_naechste_stufe_je_stufe"] * self.stufe

    # --- Erfahrung
    def gib_ep(self, menge, quelle):
        if menge <= 0:
            return
        if quelle == "fertigkeit":
            erl = self.W["erfahrung"]["fertigkeit_deckel"] * self.ep_bedarf() - self.ep_fert_stufe
            if erl <= 0:
                self.ep_quelle["fertigkeit_verfallen"] += menge
                return
            if menge >= erl:
                self.deckel_erreicht += 1
                self.ep_quelle["fertigkeit_verfallen"] += menge - erl
                menge = erl
            self.ep_fert_stufe += menge
        self.ep_quelle[quelle] += menge
        self.ep += menge

    def stufe_auf(self):
        """Gibt die Zahl der Aufstiege zurueck (Kapitelgrenze haelt an)."""
        n = 0
        grenze = self.W["held"]["kapitelgrenze"]
        while self.stufe < grenze and self.ep >= self.ep_bedarf():
            self.ep -= self.ep_bedarf()
            self.stufe += 1
            self.ep_fert_stufe = 0.0
            n += 1
        return n

    # --- Ueben
    def _bedarf(self, wert):
        u = self.W["ueben"]
        return (wert + u["bedarf_basis"]) / u["bedarf_teiler"]

    def _decke(self, name):
        if name not in self.decke:
            self.decke[name] = self.W["held"]["rangdecken_kapitel"][0]
        return self.decke[name]

    def uebe(self, name, gegner_stufe, menge=None):
        u = self.W["ueben"]
        if menge is None:
            menge = u["uebung_je_benutzung"]
        m = 1 + (gegner_stufe - self.stufe) / u["leicht_teiler"]
        m = max(u["leicht_min"], min(u["leicht_max"], m))
        self.uebung[name] = self.uebung.get(name, 0.0) + menge * m
        self._steige(name)

    def _steige(self, name):
        u = self.W["ueben"]
        schritt = self.W["erfahrung"]["fertigkeit_schritt"]
        wert = self.fert.get(name, 0)
        decke = self._decke(name)
        while wert < decke and self.uebung[name] >= self._bedarf(wert):
            self.uebung[name] -= self._bedarf(wert)
            wert += 1
            if wert % schritt == 0:
                self.gib_ep(self.W["erfahrung"]["fertigkeit_schritt_erfahrung_je_heldenstufe"] * self.stufe, "fertigkeit")
        self.fert[name] = wert
        if wert >= decke:
            self.uebung[name] = min(self.uebung[name], u["puffer_uebung"])

    def nach_sieg(self, benutzt, gegner_stufe):
        """Bewaehrungsprobe: an der Rangdecke zaehlen Siege gegen Gegner mind. der eigenen Stufe."""
        decken = self.W["held"]["rangdecken_kapitel"]
        for name in benutzt:
            d = self._decke(name)
            if self.fert.get(name, 0) < d or d >= decken[-1]:
                continue
            if gegner_stufe < self.stufe:
                continue
            self.probe[name] = self.probe.get(name, 0) + 1
            if self.probe[name] >= self.W["ueben"]["probe_siege"]:
                i = decken.index(d)
                self.decke[name] = decken[i + 1]
                self.probe[name] = 0
                self.gib_ep(self.W["erfahrung"]["probe_erfahrung_je_heldenstufe"] * self.stufe, "probe")
                self._steige(name)

    def momentaufnahme(self):
        return dict(self.fert)


# ---------------------------------------------------------------- Rechenregeln (Modell D)

def stufenfaktor(W, d):
    return max(0.0, 1 + W["kampf"]["stufenfaktor_je_stufe"] * d)


def trefferchance(W, angriff, abwehr, bonus=0.0):
    k = W["kampf"]
    c = k["trefferchance_basis"] + (angriff - abwehr) * k["trefferchance_je_punkt"] + bonus
    return max(k["trefferchance_min"], min(k["trefferchance_max"], c)) / 100.0


def schaden_roh(W, grund, fertigkeit, d, rng, kritisch_prozent=0.0):
    """(Waffe + Grundwert) x (1 + Fertigkeit/100) x Stufenfaktor, mit Glueckstreffer, Krit, Streuung."""
    k = W["kampf"]
    sf = stufenfaktor(W, d)
    if rng.random() < k["glueckstreffer_anteil"]:
        sf = max(sf, 1.0)
    s = grund * (1 + fertigkeit * k["fertigkeit_im_schaden_je_punkt"]) * sf
    if kritisch_prozent > 0 and rng.random() * 100 < kritisch_prozent:
        s *= k["kritisch_faktor"]
    st = k["streuung"]
    if st:
        s *= rng.uniform(1 - st, 1 + st)
    return s


def endschaden(W, s, abzug):
    s = max(0.0, s - abzug)
    return round(s) if W["kampf"]["schaden_runden"] else s


def held_abzug(W, held, extra_bannschild=0.0):
    k = W["kampf"]
    r = W["ruestungen"]
    rs = r[held.ruestung]
    a = rs["wert"] * (1 + (held.f(rs["fertigkeit"]) if rs["fertigkeit"] else 0) * k["ruestungsfertigkeit_im_abzug_je_punkt"])
    if held.schild:
        a += r["schild_wert"] * (1 + held.f("Schild") * k["ruestungsfertigkeit_im_abzug_je_punkt"])
    if extra_bannschild:
        a += extra_bannschild
    return a


def held_abwehr(W, held, art):
    """Bester von Schild, Ausweichen (+2 je Gewandtheit), halber Nahkampfwaffe (nur gegen Nahkampf)."""
    k = W["kampf"]
    wahl = [("Ausweichen", held.f("Ausweichen") + k["ausweichen_je_gewandtheit"] * held.werte["gewandtheit"])]
    if held.schild:
        wahl.append(("Schild", held.f("Schild")))
    waffe = W["waffen"][held.waffe]
    if art == "nah" and waffe["art"] == "nah":
        wahl.append((held.waffe, held.f(held.waffe) * k["parieren_anteil_waffenfertigkeit"]))
    return max(wahl, key=lambda x: x[1])


# ---------------------------------------------------------------- Kampf

def kampf(W, held, mon, rng, lernen=False):
    k = W["kampf"]
    z = W["zauber"]
    d_held = held.stufe - mon["stufe"]
    leben = held.leben_max()
    lmax = leben
    mana = held.mana_max()
    mleben = mon["leben"]
    bann = 0.0
    benutzt = set()
    waffe = W["waffen"][held.waffe]
    schwaeche = mon.get("schwaeche", {})
    runde = 0
    while runde < W["lauf"]["max_runden"]:
        runde += 1
        # ---- Held handelt
        aktion = None
        if "Bannschild" in held.zauber and runde == 1 and mana >= z["Bannschild"]["kosten"]:
            aktion = "Bannschild"
        elif "Wundsegen" in held.zauber and leben < lmax * z["Wundsegen"]["heilen_unter"] and mana >= z["Wundsegen"]["kosten"]:
            aktion = "Wundsegen"
        elif "Funkenpfeil" in held.zauber and mana >= z["Funkenpfeil"]["kosten"]:
            aktion = "Funkenpfeil"
        if aktion == "Bannschild":
            zb = z["Bannschild"]
            mana -= zb["kosten"]
            bann = zb["ruestung"] * (1 + held.f(zb["schule"]) * k["ruestungsfertigkeit_im_abzug_je_punkt"])
            if lernen:
                held.uebe(zb["schule"], mon["stufe"])
                benutzt.add(zb["schule"])
        elif aktion == "Wundsegen":
            zb = z["Wundsegen"]
            mana -= zb["kosten"]
            heil = (zb["heilung"] + held.werte["wille"]) * (1 + held.f(zb["schule"]) / 100.0)
            leben = min(lmax, leben + round(heil))
            if lernen:
                held.uebe(zb["schule"], mon["stufe"])
                benutzt.add(zb["schule"])
        else:
            if aktion == "Funkenpfeil":
                zb = z["Funkenpfeil"]
                mana -= zb["kosten"]
                fert_name = zb["schule"]
                grund = zb["schaden"] + held.werte["wille"]
                bonus = 0.0
                typ = zb["typ"]
            else:
                fert_name = held.waffe
                gw = waffe["grundwert"]
                grund = waffe["schaden"] + (held.werte[gw] if gw else 0)
                bonus = k["fernkampf_treffer_je_wahrnehmung"] * held.werte["wahrnehmung"] if waffe["art"] == "fern" else 0.0
                typ = waffe["typ"]
            fw = held.f(fert_name)
            if rng.random() < trefferchance(W, fw, mon["abwehr"], bonus):
                s = schaden_roh(W, grund, fw, d_held, rng, k["kritisch_prozent_je_gewandtheit"] * held.werte["gewandtheit"])
                s *= schwaeche.get(typ, 1.0)
                mleben -= endschaden(W, s, mon["ruestung"])
                if lernen:
                    held.uebe(fert_name, mon["stufe"])
                    benutzt.add(fert_name)
            if mleben <= 0:
                return {"sieg": True, "runden": runde, "leben": leben / lmax, "benutzt": benutzt}
        # ---- Monster handelt
        abw_name, abw = held_abwehr(W, held, mon["art"])
        if rng.random() < trefferchance(W, mon["angriff"], abw):
            s = schaden_roh(W, mon["schaden"], mon["angriff"], -d_held, rng)
            leben -= endschaden(W, s, held_abzug(W, held, bann))
            rs = W["ruestungen"][held.ruestung]["fertigkeit"]
            if lernen:
                if rs:
                    held.uebe(rs, mon["stufe"])
                    benutzt.add(rs)
                if held.schild:
                    held.uebe("Schild", mon["stufe"])
                    benutzt.add("Schild")
        elif lernen:
            held.uebe(abw_name, mon["stufe"])
            benutzt.add(abw_name)
        if leben <= 0:
            return {"sieg": False, "runden": runde, "leben": 0.0, "benutzt": benutzt}
    return {"sieg": False, "runden": runde, "leben": leben / lmax, "benutzt": benutzt, "remis": True}


def ep_fuer(W, held, mon):
    e = W["erfahrung"]
    basis = e["je_gegner_faktor"] * mon["stufe"] ** 2
    if mon.get("boss"):
        basis *= e["boss_faktor"]
    d = held.stufe - mon["stufe"]
    if d > 0:
        f = 0.0 if d >= e["hoeher_null_ab"] else 1 - d / e["hoeher_null_ab"]
    elif d < 0:
        f = min(e["tiefer_hoechstens"], 1 - d / e["tiefer_teiler"])
    else:
        f = 1.0
    return basis * f


# ---------------------------------------------------------------- Teil 1: Fortschritt

def fortschritt(W, herkunft, rng, variante=False):
    monster = {n: m for n, m in ohne_info(W["monster"]).items() if not m.get("boss")}
    fs = W["fortschritt"]
    grenze = W["held"]["kapitelgrenze"]
    held = Held(W, herkunft, variante)
    kaempfe_je_stufe = {}
    niederlagen_je_stufe = {}
    fert_bei = {1: held.momentaufnahme()}
    kaempfe = 0
    n_stufe = 0
    nl_stufe = 0
    while held.stufe < grenze and kaempfe < fs["max_kaempfe"]:
        lo = held.stufe - fs["gegner_band_unten"]
        hi = held.stufe + fs["gegner_band_oben"]
        wahl = [m for m in monster.values() if lo <= m["stufe"] <= hi]
        mon = rng.choice(wahl)
        kaempfe += 1
        n_stufe += 1
        r = kampf(W, held, mon, rng, lernen=True)
        if r["sieg"]:
            held.gib_ep(ep_fuer(W, held, mon), "kampf")
            held.nach_sieg(r["benutzt"], mon["stufe"])
        else:
            nl_stufe += 1
        alt = held.stufe
        if held.stufe_auf():
            kaempfe_je_stufe[alt] = n_stufe
            niederlagen_je_stufe[alt] = nl_stufe
            for s in range(alt + 1, held.stufe + 1):
                fert_bei[s] = held.momentaufnahme()
            n_stufe = 0
            nl_stufe = 0
    return {
        "erreicht": held.stufe >= grenze,
        "kaempfe": kaempfe,
        "kaempfe_je_stufe": kaempfe_je_stufe,
        "niederlagen_je_stufe": niederlagen_je_stufe,
        "ep_quelle": held.ep_quelle,
        "deckel": held.deckel_erreicht,
        "fert_bei": fert_bei,
    }


def fortschritt_alle(W, herkunft, laeufe, rng, variante=False):
    res = [fortschritt(W, herkunft, rng, variante) for _ in range(laeufe)]
    grenze = W["held"]["kapitelgrenze"]
    out = {"laeufe": laeufe, "erreicht": sum(r["erreicht"] for r in res) / laeufe}
    out["kaempfe_je_stufe"] = {}
    out["niederlage_je_stufe"] = {}
    for s in range(1, grenze):
        k = [r["kaempfe_je_stufe"][s] for r in res if s in r["kaempfe_je_stufe"]]
        n = [r["niederlagen_je_stufe"][s] for r in res if s in r["niederlagen_je_stufe"]]
        out["kaempfe_je_stufe"][s] = statistics.median(k) if k else None
        out["niederlage_je_stufe"][s] = (sum(n) / sum(k)) if k and sum(k) else None
    ges = [r["kaempfe"] for r in res if r["erreicht"]]
    out["kaempfe_gesamt"] = statistics.median(ges) if ges else None
    q = {key: sum(r["ep_quelle"][key] for r in res) for key in res[0]["ep_quelle"]}
    summe = q["kampf"] + q["fertigkeit"] + q["probe"]
    out["anteil_fertigkeit"] = q["fertigkeit"] / summe if summe else 0
    out["anteil_probe"] = q["probe"] / summe if summe else 0
    out["verfallen_je_lauf"] = q["fertigkeit_verfallen"] / laeufe
    out["deckel_je_lauf"] = sum(r["deckel"] for r in res) / laeufe
    # mittlere Fertigkeiten beim Erreichen jeder Stufe
    out["fert_bei"] = {}
    for s in range(1, grenze + 1):
        schnapp = [r["fert_bei"][s] for r in res if s in r["fert_bei"]]
        namen = sorted({n for sn in schnapp for n in sn})
        out["fert_bei"][s] = {n: round(sum(sn.get(n, 0) for sn in schnapp) / len(schnapp)) for n in namen} if schnapp else {}
    return out


# ---------------------------------------------------------------- Teil 2: Kampfmatrix

def held_auf_stufe(W, herkunft, stufe, fert, variante=False):
    h = Held(W, herkunft, variante)
    h.stufe = stufe
    h.fert = dict(fert)
    return h


def matrix(W, herkunft, fert_bei, kaempfe, rng, variante=False):
    out = {}
    for name, mon in ohne_info(W["monster"]).items():
        for s in W["lauf"]["stufen"]:
            h = held_auf_stufe(W, herkunft, s, fert_bei.get(s) or fert_bei[max(fert_bei)], variante)
            siege = 0
            runden = []
            leben = []
            for _ in range(kaempfe):
                r = kampf(W, h, mon, rng)
                if r["sieg"]:
                    siege += 1
                    runden.append(r["runden"])
                    leben.append(r["leben"])
            out[(name, s)] = {
                "quote": siege / kaempfe,
                "runden": statistics.mean(runden) if runden else None,
                "leben": statistics.mean(leben) if leben else None,
            }
    return out


# ---------------------------------------------------------------- Pruefen

def pruefen(W):
    """Rechenbeispiele aus Modell D (Nachschlagewerk, Entwurf A) ohne Streuung nachrechnen."""
    fehler = 0

    def ist(name, wert, soll, tol=0.6):
        nonlocal fehler
        ok = abs(wert - soll) <= tol
        print(("ok    " if ok else "FEHLER"), name, round(wert, 2), "soll", soll)
        if not ok:
            fehler += 1

    class R:  # kein Zufall: kein Glueckstreffer, keine Streuung, kein Krit
        def random(self):
            return 0.999

        def uniform(self, a, b):
            return 1.0

    r = R()
    # Held Stufe 1 gegen Monster Stufe 10: Chance 55 %, Schaden 8 x 1,1 x 0,1 - 4 -> 0
    ist("Chance Held 1 vs 10", trefferchance(W, 10, 40) * 100, 55)
    ist("Schaden Held 1 vs 10", endschaden(W, schaden_roh(W, 8, 10, -9, r), 4), 0)
    ist("Chance Monster 10 vs Held", trefferchance(W, 50, 10) * 100, 90)
    ist("Schaden Monster 10 vs Held 1", endschaden(W, schaden_roh(W, 10, 50, 9, r), 2), 26)
    # Held Stufe 10 gegen Monster Stufe 1
    ist("Chance Held 10 vs 1", trefferchance(W, 40, 5) * 100, 87.5)
    ist("Schaden Held 10 vs 1", endschaden(W, schaden_roh(W, 8, 40, 9, r), 4), 17)
    # Zwei gleich Starke, Stufe 5
    ist("Geselle Chance", trefferchance(W, 40, 20) * 100, 80)
    ist("Geselle Schaden", endschaden(W, schaden_roh(W, 10, 40, 0, r), 2), 12)
    # Erfahrung: Stufe 10 vs 1 null
    h = Held(W, "Wachsoldat")
    h.stufe = 10
    ist("Erfahrung D=9", ep_fuer(W, h, {"stufe": 1}), 0)
    h.stufe = 1
    ist("Erfahrung D=-9 (Faktor 1,9)", ep_fuer(W, h, {"stufe": 10}), 10 * 100 * 1.9, tol=1)
    print("Ergebnis:", "in Ordnung" if fehler == 0 else f"{fehler} Fehler")
    return fehler


# ---------------------------------------------------------------- Ausgabe

def pz(x):
    return "–" if x is None else f"{round(100 * x)}"


def zahl(x, n=1):
    if x is None:
        return "–"
    return f"{x:.{n}f}".replace(".", ",")


def bericht(W, ergebnisse, variante_ergebnisse, args):
    L = []
    hk_namen = list(ohne_info(W["herkuenfte"]))
    mon = ohne_info(W["monster"])
    arten = [n for n, m in mon.items() if not m.get("boss")]
    bosse = [n for n, m in mon.items() if m.get("boss")]
    stufen = W["lauf"]["stufen"]
    k = W["lauf"]["kaempfe_je_fall"] if args.kaempfe is None else args.kaempfe
    la = W["lauf"]["fortschritt_laeufe"] if args.laeufe is None else args.laeufe
    a = L.append
    a("# Rechensimulation Spielsystem 2.0 (444)")
    a("")
    a(f"Tuffy (Team Jerry) für Sokrates. Werkzeug `tools/sim444/sim.py`, alle Zahlen in `tools/sim444/werte.json` "
      f"(Zweig `claude/tuffy-444-simulation`). Regeln: Nachschlagewerk Modell D und Abschnitt 4, Monster: Bestiarium „Werte 2.0“ (01.11.). "
      f"Je Fall {k} Kämpfe; Fortschritt {la} Läufe je Herkunft; Zufallskeim {W['lauf']['zufallskeim']}. Neu rechnen: "
      f"`python3 tools/sim444/sim.py --aus docs/LISTE-SIMULATION-444.md`.")
    a("")
    a("## Annahmen (im Nachschlagewerk ohne Zahl)")
    a("")
    a("Jede steht in `werte.json` mit „A“ und lässt sich dort ändern.")
    a("")
    a("- **Punkte:** 18 (6 frei über der Untergrenze 3); Spalte „21“ unten mit 9 frei (Vorschlag 422 a). Volk nicht gerechnet.")
    a("- **Herkunft:** Punkteverteilung, Waffe und Rüstung je Herkunft gesetzt (Tabelle unten). Wanderer als Kampfbau (Schwert, Ausweichen).")
    a("- **Rüstungswerte:** leicht 1, mittel 3, schwer 5, Schild 2; Abzug = Rüstung × (1 + Rüstungsfertigkeit/100) + Schild × (1 + Schild/100).")
    a("- **Zauber:** Funkenpfeil Grundschaden 6, 4 Mana; Wundsegen heilt (6 + Wille) × (1 + Heilmagie/100) unter halbem Leben, 5 Mana; Bannschild Rüstung +2 in Runde 1, 4 Mana. Ohne Mana Stab (Stumpfe Waffe, Fertigkeit 0).")
    a("- **Kampf:** eins gegen eins, Held schlägt zuerst, Streuung ±20 %, kein Hinterhalt, keine Merkmale außer Skelett (Stumpfes × 1,5) und Ockerschleim (Klingen × 0,5); Leben und Mana voll vor jedem Kampf; höchstens 60 Runden.")
    a("- **Üben:** 1 Übung je Treffer (Waffe, Zauber), je erlittenem Treffer (Rüstung, Schild), je Fehlschlag des Gegners (beste Abwehr); × (1 + (Gegnerstufe − Heldenstufe)/5), 0,2 bis 1,5. Bedarf für +1: (Wert + 10)/5.")
    a("- **Ränge Kapitel 1:** Decke 24, Bewährungsprobe = 3 Siege gegen Gegner mindestens der eigenen Stufe mit dieser Fertigkeit, dann Decke 49; Puffer 15 Übung.")
    a("- **Erfahrung aus Fertigkeiten:** je 5 Punkte 20 × Heldenstufe, Deckel 40 % des Stufenbedarfs; Probe 25 × Heldenstufe.")
    a("- **Fortschritt:** Zufallsbegegnung aus allen Arten mit Stufe Heldenstufe − 2 bis + 1 (ohne Bosse); Niederlage gibt nichts, der Held macht weiter; Erfahrungstopf, Quests und Hauptquest nicht gerechnet (der Topf hieße mehr Kämpfe, Quests weniger).")
    a("")
    a("| Herkunft | Grundwerte (K G Z V Wi Wa) | Startfertigkeiten | Waffe | Rüstung |")
    a("|---|---|---|---|---|")
    for hk in hk_namen:
        h = Held(W, hk)
        gw = " ".join(str(h.werte[g]) for g in GRUNDWERTE)
        d = W["herkuenfte"][hk]
        r = d["ruestung"] + (" + Schild" if d["schild"] else "")
        a(f"| {hk} | {gw} | {', '.join(d['fertigkeiten'])} | {d['waffe']}{' + ' + ', '.join(d['zauber']) if d['zauber'] else ''} | {r} |")
    a("")

    # ---- Fortschritt
    a("## 1. Fortschritt bis zur Kapitelgrenze (Stufe 6)")
    a("")
    a("Kämpfe je Stufe: Median. Niederlagen: Anteil an den Kämpfen der Stufe. Anteil Fertigkeit: an aller Erfahrung (Deckel 40 % je Stufe). "
      "„Deckel“: wie oft je Lauf die 40 % erreicht wurden; „verfallen“: Erfahrung je Lauf, die der Deckel abschnitt.")
    a("")
    kopf = "| Herkunft | " + " | ".join(f"{s}→{s + 1}" for s in range(1, W['held']['kapitelgrenze'])) + " | gesamt | erreicht % | Niederl. % (1→2 / 5→6) | Anteil Fertigk. % | Anteil Probe % | Deckel | verfallen | gesamt (21) |"
    a(kopf)
    a("|" + "---|" * (kopf.count("|") - 1))
    for hk in hk_namen:
        e = ergebnisse[hk]["fortschritt"]
        v = variante_ergebnisse[hk]["fortschritt"] if variante_ergebnisse else None
        ks = " | ".join(zahl(e["kaempfe_je_stufe"][s], 0) for s in range(1, W['held']['kapitelgrenze']))
        nl = f"{pz(e['niederlage_je_stufe'][1])} / {pz(e['niederlage_je_stufe'][W['held']['kapitelgrenze'] - 1])}"
        a(f"| {hk} | {ks} | {zahl(e['kaempfe_gesamt'], 0)} | {pz(e['erreicht'])} | {nl} | {pz(e['anteil_fertigkeit'])} | {pz(e['anteil_probe'])} | "
          f"{zahl(e['deckel_je_lauf'])} | {zahl(e['verfallen_je_lauf'], 0)} | {zahl(v['kaempfe_gesamt'], 0) if v else '–'} |")
    a("")
    a("**Fertigkeiten beim Erreichen von Stufe 3 und 6** (Mittel; gehen in die Kampfmatrix ein):")
    a("")
    a("| Herkunft | Stufe 3 | Stufe 6 |")
    a("|---|---|---|")
    for hk in hk_namen:
        fb = ergebnisse[hk]["fortschritt"]["fert_bei"]

        def fmt(d):
            return ", ".join(f"{n} {w}" for n, w in sorted(d.items(), key=lambda x: -x[1]) if w > 0) or "–"
        a(f"| {hk} | {fmt(fb.get(3, {}))} | {fmt(fb.get(6, {}))} |")
    a("")

    # ---- Bosse
    a("## 2. Bosse je Herkunft")
    a("")
    a("Siegquote in % auf Heldenstufe 1–6 (Bossstufe fett). Zelle: Sieg % · Züge bis Sieg · Leben am Ende %.")
    a("")
    for b in bosse:
        bs = mon[b]["stufe"]
        a(f"**{b}** (Stufe {bs}, Leben {mon[b]['leben']})")
        a("")
        a("| Herkunft | " + " | ".join((f"**{s}**" if s == bs else str(s)) for s in stufen) + " |")
        a("|---|" + "---|" * len(stufen))
        for hk in hk_namen:
            m = ergebnisse[hk]["matrix"]
            zellen = []
            for s in stufen:
                c = m[(b, s)]
                zellen.append(f"{pz(c['quote'])} · {zahl(c['runden'])} · {pz(c['leben'])}")
            a(f"| {hk} | " + " | ".join(zellen) + " |")
        a("")

    # ---- Matrix
    a("## 3. Kampfmatrix je Herkunft")
    a("")
    a("Zelle: Sieg % · Züge bis Sieg · Leben am Ende % (nur Siege). Fett: Heldenstufe = Gegnerstufe.")
    a("")
    for hk in hk_namen:
        m = ergebnisse[hk]["matrix"]
        a(f"### {hk}")
        a("")
        a("| Art (Stufe) | " + " | ".join(f"Held {s}" for s in stufen) + " |")
        a("|---|" + "---|" * len(stufen))
        for n in arten:
            zellen = []
            for s in stufen:
                c = m[(n, s)]
                t = f"{pz(c['quote'])} · {zahl(c['runden'])} · {pz(c['leben'])}"
                zellen.append(f"**{t}**" if s == mon[n]["stufe"] else t)
            a(f"| {n} ({mon[n]['stufe']}) | " + " | ".join(zellen) + " |")
        a("")

    # ---- Ueberblick gleiche Stufe
    a("## 4. Überblick: Held gegen Art gleicher Stufe")
    a("")
    a("Siegquote % · Züge bis Sieg, Heldenstufe = Gegnerstufe; Spalte „21“ = Mittel aller Arten mit 21 Punkten.")
    a("")
    a("| Herkunft | " + " | ".join(arten) + " | Mittel | Mittel (21) |")
    a("|---|" + "---|" * (len(arten) + 2))
    for hk in hk_namen:
        m = ergebnisse[hk]["matrix"]
        zellen = []
        q = []
        for n in arten:
            c = m[(n, mon[n]["stufe"])]
            q.append(c["quote"])
            zellen.append(f"{pz(c['quote'])} · {zahl(c['runden'])}")
        qv = "–"
        if variante_ergebnisse:
            mv = variante_ergebnisse[hk]["matrix"]
            qv = pz(statistics.mean(mv[(n, mon[n]["stufe"])]["quote"] for n in arten))
        a(f"| {hk} | " + " | ".join(zellen) + f" | {pz(statistics.mean(q))} | {qv} |")
    a("")
    return "\n".join(L) + "\n"


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--werte", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), "werte.json"))
    p.add_argument("--aus")
    p.add_argument("--kaempfe", type=int)
    p.add_argument("--laeufe", type=int)
    p.add_argument("--ohne-variante", action="store_true", help="21-Punkte-Variante nicht rechnen")
    p.add_argument("--pruefen", action="store_true")
    p.add_argument("--json", help="Rohdaten zusaetzlich als JSON")
    args = p.parse_args()
    W = lade(args.werte)
    if args.pruefen:
        sys.exit(1 if pruefen(W) else 0)
    kaempfe = args.kaempfe or W["lauf"]["kaempfe_je_fall"]
    laeufe = args.laeufe or W["lauf"]["fortschritt_laeufe"]

    def rechne(variante):
        rng = random.Random(W["lauf"]["zufallskeim"] + (1 if variante else 0))
        erg = {}
        for hk in ohne_info(W["herkuenfte"]):
            fo = fortschritt_alle(W, hk, laeufe, rng, variante)
            ma = matrix(W, hk, fo["fert_bei"], kaempfe, rng, variante)
            erg[hk] = {"fortschritt": fo, "matrix": ma}
            print(f"  {hk}{' (21)' if variante else ''} fertig", file=sys.stderr)
        return erg

    erg = rechne(False)
    var = None if args.ohne_variante else rechne(True)
    text = bericht(W, erg, var, args)
    if args.aus:
        with open(args.aus, "w", encoding="utf-8") as f:
            f.write(text)
    else:
        sys.stdout.write(text)
    if args.json:
        def roh(e):
            return {hk: {"fortschritt": v["fortschritt"],
                         "matrix": {f"{n}|{s}": c for (n, s), c in v["matrix"].items()}} for hk, v in e.items()}
        with open(args.json, "w", encoding="utf-8") as f:
            json.dump({"18": roh(erg), "21": roh(var) if var else None}, f, ensure_ascii=False, indent=1)


if __name__ == "__main__":
    main()
