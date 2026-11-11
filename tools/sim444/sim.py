#!/usr/bin/env python3
"""Vorgang 444: Rechensimulation Bornimer Rollenspielsystem (BRS) am Rechner (ohne Godot).

Regeln: DESIGN-BRS.md (Modell D, Abschnitt 4), Monster: LISTE-BESTIARIUM.md
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
  5. Wirtschaft (447.3, Stufe 3): Fortschritt wie 1 mit Gold, Beute, Zerlegen (Jagd), Abnutzung,
     Reparatur (Handwerker oder selbst), Traenken (kaufen, brauen, trinken) und Tiere beruhigen;
     Zahlen im Block "wirtschaft". Nur dieser Teil: --nur-wirtschaft.
  6. Traenke im Bosskampf (481.1): je Herkunft und Boss Siegquote ohne Traenke, mit Heiltraenken,
     mit Kampftraenken (Steinhaut, Berserkertrank, Alchemistenfeuer; Wirkung nach Kraeuterkunde);
     Zahlen im Block "kampftraenke". Nur dieser Teil: --nur-traenke.
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


def held_abzug(W, held, extra_bannschild=0.0, l_ruestung=1.0, l_schild=1.0):
    """l_ruestung, l_schild: Leistung nach Zustand (Wirtschaft, N 11); ohne Wirtschaft 1."""
    k = W["kampf"]
    r = W["ruestungen"]
    rs = r[held.ruestung]
    a = l_ruestung * rs["wert"] * (1 + (held.f(rs["fertigkeit"]) if rs["fertigkeit"] else 0) * k["ruestungsfertigkeit_im_abzug_je_punkt"])
    if held.schild:
        a += l_schild * r["schild_wert"] * (1 + held.f("Schild") * k["ruestungsfertigkeit_im_abzug_je_punkt"])
    if extra_bannschild:
        a += extra_bannschild
    return a


def held_abwehr(W, held, art, waffe_name=None, schild=True):
    """Bester von Schild, Ausweichen (+2 je Gewandtheit), halber Nahkampfwaffe (nur gegen Nahkampf).
    waffe_name, schild: was der Held gerade fuehrt (Wirtschaft: defekt wirkt nicht)."""
    k = W["kampf"]
    waffe_name = waffe_name or held.waffe
    wahl = [("Ausweichen", held.f("Ausweichen") + k["ausweichen_je_gewandtheit"] * held.werte["gewandtheit"])]
    if held.schild and schild:
        wahl.append(("Schild", held.f("Schild")))
    waffe = W["waffen"][waffe_name]
    if art == "nah" and waffe["art"] == "nah":
        wahl.append((waffe_name, held.f(waffe_name) * k["parieren_anteil_waffenfertigkeit"]))
    return max(wahl, key=lambda x: x[1])


# ---------------------------------------------------------------- Kampf

def kampf(W, held, mon, rng, lernen=False, wirt=None, tier_zuerst=False, beutel=None):
    """wirt: Zustand, Traenke und Zaehler der Wirtschaft (Teil 5) oder None (Teile 1 bis 4 unveraendert).
    tier_zuerst: misslungenes Beruhigen, das Tier handelt in Runde 1 vor dem Helden.
    beutel: Heil- und Kampftraenke fuer einen Bosskampf (Teil 6, 481.1) oder None."""
    k = W["kampf"]
    z = W["zauber"]
    d_held = held.stufe - mon["stufe"]
    leben = held.leben_max()
    lmax = leben
    mana = held.mana_max()
    mleben = mon["leben"]
    bann = 0.0
    benutzt = set()
    waffe_name = held.waffe
    l_waffe = l_ruestung = l_schild = 1.0
    if wirt is not None:
        l_waffe = wirt.leistung("waffe")
        l_ruestung = wirt.leistung("ruestung")
        l_schild = wirt.leistung("schild")
        if l_waffe <= 0:
            waffe_name, l_waffe = "Faustkampf", 1.0
    waffe = W["waffen"][waffe_name]
    schwaeche = mon.get("schwaeche", {})
    # 427.1: Merkmale (werte.json "merkmale"): Ueberfall (Krogg), Umreissen und Rudel (Grimmzahn); "rauch": Morwens Rauch (D4.1)
    mk = W.get("merkmale", {})
    ueb = mk["ueberfall"] if mon.get("ueberfall") else None
    umr = mk["umreissen"] if mon.get("umreissen") else None
    rud = mk["rudel"][mon["rudel"]] if mon.get("rudel") else None
    zust = {"erster": True, "betaeubt": 0, "liegt": False}
    # 870c 3 A: Jungwoelfe 1-2 je Kampf (werte.json "anzahl" [von, bis]), Leibwache fest
    rud_n = 0
    if rud:
        rud_n = rng.randint(*rud["anzahl"]) if isinstance(rud["anzahl"], list) else rud["anzahl"]
    # 481.1: Kampftraenke (werte.json "kampftraenke"), Wirkung nach Kraeuterkunde
    tb = wirt if wirt is not None else beutel
    kt = W.get("kampftraenke", {})
    wirkung = beutel.wirkung if beutel is not None else 1.0
    trank = {"stein": 0, "bers": 0}

    def auf_held(angriff, schaden, faktor=1.0):
        """Ein Angriff auf den Helden (Monster oder Begleiter); True bei Treffer."""
        nonlocal leben
        abw_name, abw = held_abwehr(W, held, mon["art"], waffe_name, l_schild > 0)
        if rng.random() < trefferchance(W, angriff, abw):
            s = schaden_roh(W, schaden, angriff, -d_held, rng) * faktor
            e = endschaden(W, s, held_abzug(W, held, bann, l_ruestung, l_schild))
            if trank["stein"] > 0:
                e *= max(0.0, 1 - kt["Steinhaut"]["schutz"] * wirkung)
            leben -= e
            if wirt is not None:
                wirt.nutze("ruestung", held, mon)
                wirt.nutze("schild", held, mon)
            rs = W["ruestungen"][held.ruestung]["fertigkeit"]
            if lernen:
                if rs:
                    held.uebe(rs, mon["stufe"])
                    benutzt.add(rs)
                if held.schild:
                    held.uebe("Schild", mon["stufe"])
                    benutzt.add("Schild")
            return True
        if wirt is not None and abw_name == "Schild":
            wirt.nutze("schild", held, mon, W["wirtschaft"]["abnutzung"]["schild_je_abwehr"])
        if lernen:
            held.uebe(abw_name, mon["stufe"])
            benutzt.add(abw_name)
        return False

    def gegner_handelt():
        if ueb and zust["erster"] and mon.get("rauch"):
            zust["erster"] = False     # der erste Hieb geht im Rauch fehl, mit ihm Wucht und Betaeubung
        elif ueb and zust["erster"]:
            if auf_held(mon["angriff"], mon["schaden"], ueb["erster_treffer_faktor"]):
                zust["erster"] = False
                if rng.random() < ueb["betaeubt_chance"]:
                    zust["betaeubt"] = ueb["betaeubt_zuege"]
        elif auf_held(mon["angriff"], mon["schaden"]):
            if umr and rng.random() < umr["chance_bei_treffer"]:
                zust["liegt"] = True
        if rud:
            for _ in range(rud_n):
                if leben > 0 and rng.random() < rud["chance"]:
                    auf_held(mon["angriff"] + rud["angriff_verschiebung"], mon["schaden"] * rud["schaden_anteil"])

    runde = 0
    if ueb and ueb["gegner_zuerst"]:
        gegner_handelt()
        if leben <= 0:
            return {"sieg": False, "runden": 0, "leben": 0.0, "benutzt": benutzt}
    while runde < W["lauf"]["max_runden"]:
        runde += 1
        # ---- Held handelt
        aktion = None
        if (tier_zuerst and runde == 1) or zust["betaeubt"] > 0:
            zust["betaeubt"] = max(0, zust["betaeubt"] - 1)
            aktion = "warten"
        elif tb is not None and leben < lmax * W["wirtschaft"]["traenke"]["trinken_unter"] and tb.hat_trank():
            aktion = "trank"
        elif beutel is not None and beutel.hat("Steinhaut") and trank["stein"] <= 0:
            aktion = "Steinhaut"
        elif (beutel is not None and beutel.hat("Berserkertrank") and trank["bers"] <= 0
              and "Funkenpfeil" not in held.zauber):
            aktion = "Berserkertrank"
        elif "Bannschild" in held.zauber and runde == 1 and mana >= z["Bannschild"]["kosten"]:
            aktion = "Bannschild"
        elif "Wundsegen" in held.zauber and leben < lmax * z["Wundsegen"]["heilen_unter"] and mana >= z["Wundsegen"]["kosten"]:
            aktion = "Wundsegen"
        elif "Funkenpfeil" in held.zauber and mana >= z["Funkenpfeil"]["kosten"]:
            aktion = "Funkenpfeil"
        # 481.1: Feuer statt eines schwaecheren Angriffs (Grundschaden verglichen)
        if aktion in (None, "Funkenpfeil") and beutel is not None and beutel.hat("Alchemistenfeuer"):
            if aktion == "Funkenpfeil":
                g_jetzt = z["Funkenpfeil"]["schaden"] + held.werte["wille"]
            else:
                gw = waffe["grundwert"]
                g_jetzt = (waffe["schaden"] + (held.werte[gw] if gw else 0)) * l_waffe
                if trank["bers"] > 0:
                    g_jetzt *= 1 + kt["Berserkertrank"]["schaden_plus"] * wirkung
            if kt["Alchemistenfeuer"]["schaden"] * wirkung > g_jetzt:
                aktion = "Alchemistenfeuer"
        if trank["stein"] > 0:
            trank["stein"] -= 1
        if trank["bers"] > 0:
            trank["bers"] -= 1
        if aktion == "warten":
            pass
        elif aktion == "trank":
            leben = min(lmax, leben + tb.trinke())
        elif aktion == "Steinhaut":
            beutel.nimm("Steinhaut")
            trank["stein"] = kt["Steinhaut"]["runden"]
        elif aktion == "Berserkertrank":
            beutel.nimm("Berserkertrank")
            trank["bers"] = kt["Berserkertrank"]["runden"] + 1   # zaehlt ab dem naechsten Zug
        elif aktion == "Bannschild":
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
            if aktion == "Alchemistenfeuer":
                beutel.nimm("Alchemistenfeuer")
                fe = kt["Alchemistenfeuer"]
                fert_name = fe["fertigkeit"]
                grund = fe["schaden"] * wirkung
                bonus = k["fernkampf_treffer_je_wahrnehmung"] * held.werte["wahrnehmung"]
                typ = fe["typ"]
            elif aktion == "Funkenpfeil":
                zb = z["Funkenpfeil"]
                mana -= zb["kosten"]
                fert_name = zb["schule"]
                grund = zb["schaden"] + held.werte["wille"]
                bonus = 0.0
                typ = zb["typ"]
            else:
                fert_name = waffe_name
                gw = waffe["grundwert"]
                grund = (waffe["schaden"] + (held.werte[gw] if gw else 0)) * l_waffe
                if trank["bers"] > 0:
                    grund *= 1 + kt["Berserkertrank"]["schaden_plus"] * wirkung
                bonus = k["fernkampf_treffer_je_wahrnehmung"] * held.werte["wahrnehmung"] if waffe["art"] == "fern" else 0.0
                typ = waffe["typ"]
            fw = held.f(fert_name)
            if zust["liegt"]:     # 427.1 Umreissen: am Boden, dieser Angriff mit Nachteil
                bonus += umr["naechster_angriff_treffer"]
                zust["liegt"] = False
            if rng.random() < trefferchance(W, fw, mon["abwehr"], bonus):
                s = schaden_roh(W, grund, fw, d_held, rng, k["kritisch_prozent_je_gewandtheit"] * held.werte["gewandtheit"])
                s *= schwaeche.get(typ, 1.0)
                mleben -= endschaden(W, s, mon["ruestung"])
                if wirt is not None and aktion is None and waffe_name == held.waffe:
                    wirt.nutze("waffe", held, mon)
                if lernen:
                    held.uebe(fert_name, mon["stufe"])
                    benutzt.add(fert_name)
            if mleben <= 0:
                return {"sieg": True, "runden": runde, "leben": leben / lmax, "benutzt": benutzt}
        # ---- Monster handelt (427.1: mit Merkmalen, danach das Rudel)
        gegner_handelt()
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
    monster = {n: m for n, m in ohne_info(W["monster"]).items() if not m.get("boss") and not m.get("nur_matrix")}
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


# ---------------------------------------------------------------- Teil 6: Traenke im Bosskampf (481.1)

def wirkung_von(W, kraeuterkunde):
    kt = W["kampftraenke"]
    return min(kt["wirkung_max"], kt["wirkung_grund"] + kt["wirkung_je_kraeuterkunde"] * kraeuterkunde)


class Beutel:
    """Traenke fuer einen Kampf; gleiche Schnittstelle fuer Heiltraenke wie Wirt."""

    def __init__(self, W, heiltraenke, satz, kraeuterkunde):
        self.W = W
        self.n = {"Heiltrank": heiltraenke}
        self.n.update(satz)
        self.wirkung = wirkung_von(W, kraeuterkunde)

    def hat(self, name):
        return self.n.get(name, 0) > 0

    def nimm(self, name):
        self.n[name] -= 1

    def hat_trank(self):
        return self.hat("Heiltrank")

    def trinke(self):
        self.nimm("Heiltrank")
        return trank_heilung(self.W, "Heiltrank")


def satz_preis(W):
    kt = W["kampftraenke"]
    preise = W["wirtschaft"]["preise"]
    p = kt["heiltraenke"] * preise["Heiltrank"]
    for name, n in kt["satz"].items():
        p += n * (kt[name]["preis"] if "preis" in kt[name] else preise[name])
    return p


def traenke_boss(W, herkunft, fert_bei, kaempfe, rng):
    """Je Boss auf seiner Stufe: Siegquote ohne Traenke, mit Heiltraenken, mit Kampftraenken
    (Kraeuterkunde wie gerechnet) und mit Kraeuterkunde an der Decke (nur wer damit beginnt)."""
    kt = W["kampftraenke"]
    out = {}
    hat_kk = "Kräuterkunde" in W["herkuenfte"][herkunft]["fertigkeiten"]
    for name, mon in ohne_info(W["monster"]).items():
        if not mon.get("boss"):
            continue
        h = held_auf_stufe(W, herkunft, mon["stufe"], fert_bei.get(mon["stufe"]) or fert_bei[max(fert_bei)])
        kk = h.f("Kräuterkunde")
        faelle = {"ohne": None, "heil": (kt["heiltraenke"], {}, kk), "kampf": (kt["heiltraenke"], kt["satz"], kk)}
        if hat_kk:
            faelle["kampf_decke"] = (kt["heiltraenke"], kt["satz"], max(kk, kt["kraeuterkunde_decke"]))
        for fall, b in faelle.items():
            siege = 0
            for _ in range(kaempfe):
                beutel = Beutel(W, b[0], dict(b[1]), b[2]) if b else None
                if kampf(W, h, mon, rng, beutel=beutel)["sieg"]:
                    siege += 1
            out[(name, fall)] = siege / kaempfe
        out[(name, "kk")] = kk
    return out


def bericht_traenke(W, tr, kaempfe, proben=None):
    kt = W["kampftraenke"]
    zeilen = []
    a = zeilen.append
    a("## 6. Tränke im Bosskampf (481.1)")
    a("")
    a(f"Held auf der Stufe des Bosses, Fertigkeiten aus Abschnitt 1 (18 Punkte); je Fall {kaempfe} Kämpfe; Sieg in %. "
      f"„ohne“ wie Abschnitt 2; „Heil“: {kt['heiltraenke']} Heiltränke; „Kampf“: dazu "
      + ", ".join(f"{n} {name}" for name, n in kt["satz"].items())
      + f" (Beutel {satz_preis(W)} Gold), Wirkung nach Kräuterkunde wie gerechnet; „Kampf, KK {kt['kraeuterkunde_decke']}“: nur wer mit Kräuterkunde beginnt, geübt bis zur Decke von Kapitel 1.")
    a("")
    a(f"- **Wirkung** = {kt['wirkung_grund']} + {kt['wirkung_je_kraeuterkunde']} × Kräuterkunde, höchstens {kt['wirkung_max']} "
      f"(ohne 0,5, Startwert 10 = 1, 24 = 1,7). Steinhaut: {kt['Steinhaut']['runden']} Runden Schaden × (1 − {kt['Steinhaut']['schutz']} × Wirkung), bei 2 unverwundbar; "
      f"Berserkertrank: {kt['Berserkertrank']['runden']} Angriffe mit Waffenschaden × (1 + {kt['Berserkertrank']['schaden_plus']} × Wirkung), nicht für Zauberer; "
      f"Alchemistenfeuer: geworfen, Grundschaden {kt['Alchemistenfeuer']['schaden']} × Wirkung, Feuer. Jeder Trank kostet einen Zug. Alle Zahlen Annahmen (`werte.json` „kampftraenke“).")
    a("")
    hks = list(tr)
    bosse = [n for n, m in ohne_info(W["monster"]).items() if m.get("boss")]
    for b in bosse:
        a(f"**{b}**")
        a("")
        a(f"| Herkunft | Kräuterkunde | ohne | Heil | Kampf | Kampf, KK {kt['kraeuterkunde_decke']} |")
        a("|---|---|---|---|---|---|")
        zaehl = {"ohne": 0, "heil": 0, "kampf": 0}
        for hk in hks:
            t = tr[hk]
            def z(f):
                v = t.get((b, f))
                if v is None:
                    return "–"
                txt = str(round(100 * v))
                return f"**{txt}**" if v >= 0.5 else txt
            for f in zaehl:
                if t[(b, f)] >= 0.5:
                    zaehl[f] += 1
            a(f"| {hk} | {t[(b, 'kk')]} | {z('ohne')} | {z('heil')} | {z('kampf')} | {z('kampf_decke')} |")
        a(f"| ab 50 % | | {zaehl['ohne']} | {zaehl['heil']} | {zaehl['kampf']} | |")
        a("")
    if proben:
        a("### 6b. Kräutersammler mit anderem Beutel")
        a("")
        a("Sieg in %, je 2 Heiltränke dazu; Kräuterkunde gesetzt. Preis des Beutels in Gold.")
        a("")
        a("| Kräuterkunde | Beutel | Gold | " + " | ".join(bosse) + " |")
        a("|---|---|---|" + "---|" * len(bosse))
        for (kk, satzname), werte in proben.items():
            zellen = [f"**{round(100 * werte[b])}**" if werte[b] >= 0.5 else str(round(100 * werte[b])) for b in bosse]
            a(f"| {kk} | {satzname} | {werte['preis']} | " + " | ".join(zellen) + " |")
        a("")
    return "\n".join(zeilen) + "\n"


def traenke_proben(W, fert_bei, kaempfe, rng, herkunft="Kräutersammler"):
    kt = W["kampftraenke"]
    preise = W["wirtschaft"]["preise"]
    out = {}
    for kk in kt["proben_kraeuterkunde"]:
        for satzname, satz in kt["proben"].items():
            r = {"preis": kt["heiltraenke"] * preise["Heiltrank"]
                 + sum(n * kt[t].get("preis", preise.get(t, 0)) for t, n in satz.items())}
            for name, mon in ohne_info(W["monster"]).items():
                if not mon.get("boss"):
                    continue
                h = held_auf_stufe(W, herkunft, mon["stufe"], fert_bei.get(mon["stufe"]) or fert_bei[max(fert_bei)])
                siege = sum(kampf(W, h, mon, rng, beutel=Beutel(W, kt["heiltraenke"], dict(satz), kk))["sieg"]
                            for _ in range(kaempfe))
                r[name] = siege / kaempfe
            out[(kk, satzname)] = r
    return out


# ---------------------------------------------------------------- Teil 5: Wirtschaft (Stufe 3, 447.3)

def ist_tier(W, name):
    return name in W["wirtschaft"]["tiere_beruhigen"]["arten"]


# 923 (Sokrates über Tom, t276): der Heiltrank heilt im Spiel nach welt.heilung (mars.gd, Welt); eine Stelle für Spiel und Rechnung
TRANK_KENNUNG = {"Heiltrank": "potion", "Großer Heiltrank": "greater_potion"}


def trank_heilung(W, name):
    return W["welt"]["heilung"][TRANK_KENNUNG[name]]


def rang_von(W, wert):
    """Rang nach Reparatur-Tabelle (N 11): hoechster Rang, dessen Untergrenze erreicht ist, sonst None."""
    best = None
    for rang, ab in W["wirtschaft"]["reparatur"]["rang_ab"].items():
        if wert >= ab:
            best = rang
    return best


def rang_reicht(W, wert, noetig):
    raenge = list(W["wirtschaft"]["reparatur"]["rang_ab"])
    r = rang_von(W, wert)
    return r is not None and raenge.index(r) >= raenge.index(noetig)


def ausbeute(W, jagd):
    z = W["wirtschaft"]["zerlegen"]
    return z["ausbeute_min"] + (1 - z["ausbeute_min"]) * min(1.0, jagd / z["jagd_voll"])


def beruhigen_chance(W, wert, mon):
    """None, wenn der Rang fuer dieses Tier nicht reicht; sonst Chance 0..1."""
    t = W["wirtschaft"]["tiere_beruhigen"]
    grenze = 0
    for bis, tierstufe in t["rang_bis_tierstufe"]:
        grenze = tierstufe
        if wert <= bis:
            break
    if mon["stufe"] > grenze:
        return None
    c = t["chance_basis"] + (wert - mon["wachsamkeit"]) * t["chance_je_punkt"]
    return max(t["chance_min"], min(t["chance_max"], c)) / 100.0


def reparatur_kosten(W, held, slot_art, fehlend):
    """(Kosten, selbst?) fuer 'fehlend' Zustandspunkte eines Stuecks der Art slot_art (Waffen-/Ruestungsart)."""
    wi = W["wirtschaft"]
    a = wi["ausruestung"][slot_art]
    fert = wi["ausruestung"]["material_fertigkeit"][a["material"]]
    if rang_reicht(W, held.f(fert), a["rang"]):
        return a["preis"] * wi["reparatur"]["selbst_anteil"] * fehlend / 100.0, fert
    return a["preis"] * wi["reparatur"]["handwerker_anteil"] * fehlend / 100.0, None


class Wirt:
    """Gold, Beutel, Zustand der Ausruestung und Zaehler eines Laufs."""

    def __init__(self, W, held):
        self.W = W
        wi = W["wirtschaft"]
        self.gold = float(wi["startgold"])
        self.traenke = {"Heiltrank": wi["start_heiltraenke"], "Großer Heiltrank": 0}
        self.ware = 0.0          # Verkaufswert im Beutel (Beute, Teile)
        self.slots = {"waffe": held.waffe}
        if held.ruestung in wi["ausruestung"]:
            self.slots["ruestung"] = held.ruestung
        if held.schild:
            self.slots["schild"] = "Schild"
        self.zustand = {s: 100.0 for s in self.slots}
        self.held = held
        self.mon = None
        self.z = {k: 0.0 for k in ("gold_beute", "gold_verkauf", "gold_zerlegen", "aus_reparatur",
                                   "aus_reparatur_selbst", "aus_traenke", "aus_brauen", "getrunken",
                                   "gefunden", "gekauft", "gebraut", "beschaedigt_kaempfe", "dorf",
                                   "defekt_kaempfe")}

    # --- Zustand
    def stufe_von(self, z):
        ab = self.W["wirtschaft"]["abnutzung"]["zustand_ab"]
        for name in ("Makellos", "Benutzt", "Beschädigt"):
            if z >= ab[name]:
                return name
        return "Defekt"

    def leistung(self, slot):
        if slot not in self.zustand:
            return 1.0
        return self.W["wirtschaft"]["abnutzung"]["leistung"][self.stufe_von(self.zustand[slot])]

    def nutze(self, slot, held, mon, menge=None):
        if slot not in self.zustand:
            return
        a = self.W["wirtschaft"]["abnutzung"]
        if menge is None:
            menge = a["waffe_je_treffer"] if slot == "waffe" else a["ruestung_je_treffer"]
        f = 1 + (mon["stufe"] - held.stufe) / a["faktor_teiler"]
        f = max(a["faktor_min"], min(a["faktor_max"], f))
        self.zustand[slot] = max(0.0, self.zustand[slot] - menge * f)

    def warnung(self):
        ab = self.W["wirtschaft"]["abnutzung"]["zustand_ab"]["Benutzt"]
        return any(z < ab for z in self.zustand.values())

    # --- Traenke
    def hat_trank(self):
        return self.traenke["Heiltrank"] > 0 or self.traenke["Großer Heiltrank"] > 0

    def trinke(self):
        name = "Heiltrank" if self.traenke["Heiltrank"] > 0 else "Großer Heiltrank"
        self.traenke[name] -= 1
        self.z["getrunken"] += 1
        return trank_heilung(self.W, name)

    # --- Beute, Zerlegen
    def beute(self, name, mon, rng):
        wi = self.W["wirtschaft"]
        b = wi["beute"].get(name)
        if b:
            g = rng.randint(b["gold"][0], b["gold"][1])
            self.gold += g
            self.z["gold_beute"] += g
            for ding, chance in b["dinge"]:
                if rng.random() < chance:
                    if ding in self.traenke:
                        self.traenke[ding] += 1
                        self.z["gefunden"] += 1
                    else:
                        self.ware += wi["preise"][ding] * wi["verkauf_anteil"]
        teile = wi["zerlegen"]["teile"].get(name)
        if teile:
            q = ausbeute(self.W, self.held.f("Jagd"))
            wert = 0.0
            for i, t in enumerate(teile):
                if i == 0 or rng.random() < q:
                    wert += wi["preise"][t] * wi["verkauf_anteil"] * q
            self.ware += wert
            self.z["gold_zerlegen"] += wert
            self.held.uebe("Jagd", mon["stufe"])
            return True
        return False

    # --- Dorf
    def dorf(self):
        wi = self.W["wirtschaft"]
        held = self.held
        self.z["dorf"] += 1
        # verkaufen (Zerlegtes zaehlt schon bei gold_zerlegen)
        self.z["gold_verkauf"] += self.ware
        self.gold += self.ware
        self.ware = 0.0
        # alles reparieren, so weit das Gold reicht
        for slot, art in self.slots.items():
            fehlend = 100.0 - self.zustand[slot]
            if fehlend <= 0:
                continue
            kosten, fert = reparatur_kosten(self.W, held, art, fehlend)
            if kosten > self.gold:
                fehlend *= self.gold / kosten if kosten else 0
                kosten = self.gold
            self.gold -= kosten
            self.zustand[slot] += fehlend
            if fert:
                self.z["aus_reparatur_selbst"] += kosten
                held.uebe(fert, held.stufe, fehlend / 25.0)
            else:
                self.z["aus_reparatur"] += kosten
        # Traenke bis zum Vorrat: brauen mit Alchemie, sonst kaufen
        t = wi["traenke"]
        brauen = held.f("Alchemie") > 0
        preis = t["brauen_kosten"] if brauen else wi["preise"]["Heiltrank"]
        while self.traenke["Heiltrank"] + self.traenke["Großer Heiltrank"] < t["vorrat_ziel"] and self.gold >= preis:
            self.gold -= preis
            self.traenke["Heiltrank"] += 1
            if brauen:
                self.z["aus_brauen"] += preis
                self.z["gebraut"] += 1
                held.uebe("Alchemie", held.stufe)
            else:
                self.z["aus_traenke"] += preis
                self.z["gekauft"] += 1


def fortschritt_wirtschaft(W, herkunft, rng, beruhigen=False):
    wi = W["wirtschaft"]
    variante = wi["punkte_variante"]
    monster = {n: m for n, m in ohne_info(W["monster"]).items() if not m.get("boss") and not m.get("nur_matrix")}
    fs = W["fortschritt"]
    grenze = W["held"]["kapitelgrenze"]
    held = Held(W, herkunft, variante)
    wirt = Wirt(W, held)
    begegnungen = kaempfe = niederlagen = versuche = beruhigt = zerlegt = seit_dorf = 0
    gold_bei = {}
    while held.stufe < grenze and begegnungen < fs["max_kaempfe"]:
        lo = held.stufe - fs["gegner_band_unten"]
        hi = held.stufe + fs["gegner_band_oben"]
        name, mon = rng.choice([(n, m) for n, m in monster.items() if lo <= m["stufe"] <= hi])
        begegnungen += 1
        tier_zuerst = False
        if beruhigen and ist_tier(W, name):
            c = beruhigen_chance(W, held.f("Tiere beruhigen"), mon)
            if c is not None:
                versuche += 1
                held.uebe("Tiere beruhigen", mon["stufe"])
                if rng.random() < c:
                    beruhigt += 1
                    held.gib_ep(ep_fuer(W, held, mon), "kampf")
                    held.nach_sieg({"Tiere beruhigen"}, mon["stufe"])
                    alt = held.stufe
                    if held.stufe_auf():
                        for s in range(alt + 1, held.stufe + 1):
                            gold_bei[s] = wirt.gold + wirt.ware
                    continue
                tier_zuerst = True
        kaempfe += 1
        seit_dorf += 1
        if wirt.warnung():
            wirt.z["beschaedigt_kaempfe"] += 1
        if any(wirt.leistung(sl) <= 0 for sl in wirt.zustand):
            wirt.z["defekt_kaempfe"] += 1
        r = kampf(W, held, mon, rng, lernen=True, wirt=wirt, tier_zuerst=tier_zuerst)
        if r["sieg"]:
            held.gib_ep(ep_fuer(W, held, mon), "kampf")
            held.nach_sieg(r["benutzt"], mon["stufe"])
            if wirt.beute(name, mon, rng):
                zerlegt += 1
        else:
            niederlagen += 1
        alt = held.stufe
        if held.stufe_auf():
            for s in range(alt + 1, held.stufe + 1):
                gold_bei[s] = wirt.gold + wirt.ware
        if seit_dorf >= wi["dorf_alle_kaempfe"] or wirt.warnung():
            wirt.dorf()
            seit_dorf = 0
    wirt.dorf()
    return {
        "erreicht": held.stufe >= grenze, "begegnungen": begegnungen, "kaempfe": kaempfe,
        "niederlagen": niederlagen, "versuche": versuche, "beruhigt": beruhigt, "zerlegt": zerlegt,
        "gold_ende": wirt.gold, "gold_bei": gold_bei, "z": wirt.z,
        "jagd": held.f("Jagd"), "beruhigen_wert": held.f("Tiere beruhigen"),
        "schmieden": held.f("Schmieden"), "alchemie": held.f("Alchemie"),
    }


def wirtschaft_alle(W, herkunft, laeufe, rng, beruhigen=False):
    res = [fortschritt_wirtschaft(W, herkunft, rng, beruhigen) for _ in range(laeufe)]
    med = lambda xs: statistics.median(xs) if xs else None
    mittel = lambda key: sum(r["z"][key] for r in res) / laeufe
    kaempfe = sum(r["kaempfe"] for r in res)
    out = {
        "laeufe": laeufe,
        "erreicht": sum(r["erreicht"] for r in res) / laeufe,
        "begegnungen": med([r["begegnungen"] for r in res]),
        "kaempfe": med([r["kaempfe"] for r in res]),
        "niederlagen": sum(r["niederlagen"] for r in res) / kaempfe if kaempfe else 0,
        "beruhigt_anteil": (sum(r["beruhigt"] for r in res) / sum(r["versuche"] for r in res)) if sum(r["versuche"] for r in res) else None,
        "beruhigt": sum(r["beruhigt"] for r in res) / laeufe,
        "zerlegt": sum(r["zerlegt"] for r in res) / laeufe,
        "gold_ende": med([r["gold_ende"] for r in res]),
        "gold_ende_p10": sorted(r["gold_ende"] for r in res)[laeufe // 10],
        "gold_bei": {s: med([r["gold_bei"][s] for r in res if s in r["gold_bei"]]) for s in range(2, W["held"]["kapitelgrenze"] + 1)},
        "beschaedigt_anteil": sum(r["z"]["beschaedigt_kaempfe"] for r in res) / kaempfe if kaempfe else 0,
        "defekt_anteil": sum(r["z"]["defekt_kaempfe"] for r in res) / kaempfe if kaempfe else 0,
        "jagd": med([r["jagd"] for r in res]),
        "beruhigen_wert": med([r["beruhigen_wert"] for r in res]),
        "schmieden": med([r["schmieden"] for r in res]),
        "alchemie": med([r["alchemie"] for r in res]),
    }
    for key in ("gold_beute", "gold_verkauf", "gold_zerlegen", "aus_reparatur", "aus_reparatur_selbst",
                "aus_traenke", "aus_brauen", "getrunken", "gefunden", "gekauft", "gebraut", "dorf"):
        out[key] = mittel(key)
    # gold_verkauf enthaelt das Zerlegte; getrennt ausweisen
    out["gold_verkauf_beute"] = out["gold_verkauf"] - out["gold_zerlegen"]
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
    # Wirtschaft (447.3): Formeln aus werte.json, Block wirtschaft
    if "wirtschaft" in W:
        mon = W["monster"]
        ist("Ausbeute Jagd 0", ausbeute(W, 0), 0.4, tol=0.001)
        ist("Ausbeute Jagd 49", ausbeute(W, 49), 1.0, tol=0.001)
        ist("Beruhigen Wolf, Fertigkeit 0 (%)", beruhigen_chance(W, 0, mon["Wolf"]) * 100, 35, tol=0.01)
        ist("Beruhigen Fledermaus Stufe 3 als Anfaenger gesperrt", 1 if beruhigen_chance(W, 24, mon["Riesenfledermaus"]) is None else 0, 1, tol=0)
        ist("Beruhigen Fledermaus als Geselle (%)", beruhigen_chance(W, 30, mon["Riesenfledermaus"]) * 100, 45, tol=0.01)
        hw = Held(W, "Wachsoldat")
        ist("Reparatur Kettenhemd 40 Punkte beim Handwerker", reparatur_kosten(W, hw, "Mittlere Rüstung", 40)[0], 10, tol=0.001)
        hs = Held(W, "Schmiedelehrling")
        k, fert = reparatur_kosten(W, hs, "Stumpfe Waffen", 100)
        ist("Reparatur Streitkolben selbst (Schmieden 10, Anfaenger)", k, 1, tol=0.001)
        ist("Reparatur Kettenhemd selbst erst als Geselle", 1 if reparatur_kosten(W, hs, "Mittlere Rüstung", 100)[1] is None else 0, 1, tol=0)
    if "kampftraenke" in W:   # 481.1
        ist("Trankwirkung ohne Kraeuterkunde", wirkung_von(W, 0), 0.5, tol=0.001)
        ist("Trankwirkung Kraeuterkunde 10", wirkung_von(W, 10), 1.0, tol=0.001)
        ist("Trankwirkung Kraeuterkunde 40 (Deckel)", wirkung_von(W, 40), 2.0, tol=0.001)
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
    arten = [n for n, m in mon.items() if not m.get("boss") and not m.get("nur_matrix")]
    bosse = [n for n, m in mon.items() if m.get("boss") or m.get("nur_matrix")]
    stufen = W["lauf"]["stufen"]
    k = W["lauf"]["kaempfe_je_fall"] if args.kaempfe is None else args.kaempfe
    la = W["lauf"]["fortschritt_laeufe"] if args.laeufe is None else args.laeufe
    a = L.append
    a("# Rechensimulation Bornimer Rollenspielsystem (BRS) (444)")
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
    a("- **Kampf:** eins gegen eins, Held schlägt zuerst, Streuung ±20 %, kein Hinterhalt; Schwäche und Stärke je Schadensart (870a 8 A, werte.json „schwaeche“: × 1,5, × 0,5, immun 0; Gegenwirkungen nicht gerechnet) und seit 427.1 Krogg (Überfall: er schlägt zuerst, erster Treffer × 1,6, zur Hälfte betäubt einen Zug; „mit Rauch“: der erste Hieb geht fehl) und Grimmzahn (Umreißen: bei Treffer zur Hälfte am Boden, nächster Angriff −25 Prozentpunkte; Leibwache: 2 Wölfe, je 55 % je Runde, Angriff −10, Schaden × 0,31, fliehen mit ihm); Zahlen in `werte.json` „merkmale“; Leben und Mana voll vor jedem Kampf; höchstens 60 Runden.")
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


def bericht_wirtschaft(W, we, laeufe):
    """Abschnitt 5: Wirtschaft (Stufe 3). we[(herkunft, beruhigen)] = wirtschaft_alle(...)."""
    L = []
    a = L.append
    wi = W["wirtschaft"]
    hk_namen = list(ohne_info(W["herkuenfte"]))
    g = lambda x: zahl(x, 0)
    a("## 5. Wirtschaft: Gold, Beute, Zerlegen, Abnutzung, Reparatur, Tränke, Tiere beruhigen (Stufe 3, 447.3)")
    a("")
    a(f"Fortschritt wie Abschnitt 1, aber mit 21 Punkten (Entscheidung 77), Gold und Beutel; {laeufe} Läufe je Herkunft und Spielweise. "
      "„kämpft“: jede Begegnung wird gekämpft; „beruhigt“: bei Tieren (Riesenratte, Wolf, Wildschwein, Riesenfledermaus) erst Tiere beruhigen, "
      "misslingt es, Kampf mit Erstschlag des Tiers. Gold: Mittel je Lauf bis Stufe 6, Gold am Ende: Median (10 % der Läufe haben weniger als „p10“).")
    a("")
    a("**Annahmen** (alle in `werte.json`, Block `wirtschaft`, Quelle je Zeile):")
    a("")
    a(f"- **Gold und Beute** wie in der alten Fassung (Gold als Würfelspanne, Tränke, Alchemistenfeuer, Weihwasser mit Chance); Tierteile nur noch über Zerlegen. "
      f"Start {wi['startgold']} Gold und {wi['start_heiltraenke']} Heiltränke; Händler zahlt {round(100 * wi['verkauf_anteil'])} % des Ladenpreises.")
    z = wi["zerlegen"]
    a(f"- **Zerlegen** nach jedem Sieg über Tier, Kriechtier, Skelett, Schleim (Teile nach Bestiarium): erstes Teil immer, weitere mit Chance = Ausbeute, "
      f"Erlös × Ausbeute; Ausbeute = {zahl(z['ausbeute_min'])} + {zahl(1 - z['ausbeute_min'])} × Jagd/{z['jagd_voll']}; übt Jagd (Start 0 bei allen Herkünften).")
    t = wi["tiere_beruhigen"]
    a(f"- **Tiere beruhigen:** Chance = {t['chance_basis']} % + (Fertigkeit − Wachsamkeit des Tiers) × {zahl(t['chance_je_punkt'])}, "
      f"{t['chance_min']} bis {t['chance_max']} %; Anfänger bis Tierstufe 2, Geselle bis 4; gelungen: Erfahrung wie Sieg, keine Beute, kein Zerlegen, keine Abnutzung; "
      "übt bei jedem Versuch.")
    ab = wi["abnutzung"]
    a(f"- **Abnutzung:** Zustand 100; −{zahl(ab['waffe_je_treffer'])} je eigenem Waffentreffer, −{zahl(ab['ruestung_je_treffer'])} je erlittenem Treffer (Rüstung und Schild), "
      f"−{zahl(ab['schild_je_abwehr'])} je Abwehr mit dem Schild, × (1 + (Gegnerstufe − Heldenstufe)/{ab['faktor_teiler']}). "
      f"Makellos ab {ab['zustand_ab']['Makellos']}, Benutzt ab {ab['zustand_ab']['Benutzt']} (Leistung {zahl(ab['leistung']['Benutzt'], 2)}), "
      f"Beschädigt (Leistung {zahl(ab['leistung']['Beschädigt'], 2)}), Defekt bei 0 (wirkt nicht).")
    r = wi["reparatur"]
    a(f"- **Dorf und Reparatur:** alle {wi['dorf_alle_kaempfe']} Kämpfe ins Dorf, sofort nach dem Kampf, in dem ein Stück „Beschädigt“ wird; dort verkaufen, „Alles reparieren“, Tränke auffüllen. "
      f"Handwerker: von 0 auf 100 kostet {round(100 * r['handwerker_anteil'])} % des Ladenpreises; selbst (Schmieden bzw. Lederarbeit mit Rang nach Abschnitt 11): "
      f"{round(100 * r['selbst_anteil'])} % als Material. Ladenpreise alt: "
      + ", ".join(f"{v['ding']} {v['preis']}" for k, v in wi["ausruestung"].items() if not k.startswith("_") and isinstance(v, dict) and "ding" in v) + ".")
    tr = wi["traenke"]
    a(f"- **Tränke:** Heiltrank heilt {trank_heilung(W, 'Heiltrank')}, großer {trank_heilung(W, 'Großer Heiltrank')} (Preis {wi['preise']['Heiltrank']} und {wi['preise']['Großer Heiltrank']}); "
      f"getrunken statt Angriff unter {round(100 * tr['trinken_unter'])} % Leben; im Dorf bis {tr['vorrat_ziel']} im Beutel, wer Alchemie hat, braut für {tr['brauen_kosten']} Gold.")
    a("")
    a("### 5.1 Gold je Lauf bis Stufe 6")
    a("")
    a("| Herkunft | Spielweise | Kämpfe | Beute-Gold | Verkauf Beute | Zerlegen | Reparatur | davon selbst | Tränke | Gold am Ende (p10) | Gold bei Stufe 3 | Niederl. % |")
    a("|---|---|---|---|---|---|---|---|---|---|---|---|")
    for hk in hk_namen:
        for ber in (False, True):
            e = we[(hk, ber)]
            rep = e["aus_reparatur"] + e["aus_reparatur_selbst"]
            a(f"| {hk} | {'beruhigt' if ber else 'kämpft'} | {g(e['kaempfe'])} | {g(e['gold_beute'])} | {g(e['gold_verkauf_beute'])} | {g(e['gold_zerlegen'])} | "
              f"{g(rep)} | {g(e['aus_reparatur_selbst'])} | {g(e['aus_traenke'] + e['aus_brauen'])} | {g(e['gold_ende'])} ({g(e['gold_ende_p10'])}) | "
              f"{g(e['gold_bei'].get(3))} | {pz(e['niederlagen'])} |")
    a("")
    a("### 5.2 Tränke, Zustand, Fertigkeiten")
    a("")
    a("| Herkunft | Spielweise | getrunken | gefunden | gekauft | gebraut | Dorfbesuche | Kämpfe mit Warnung % | mit Defekt % | Jagd am Ende | zerlegt | Tiere beruhigt (gelungen %) | Tiere beruhigen am Ende |")
    a("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    for hk in hk_namen:
        for ber in (False, True):
            e = we[(hk, ber)]
            a(f"| {hk} | {'beruhigt' if ber else 'kämpft'} | {zahl(e['getrunken'])} | {zahl(e['gefunden'])} | {zahl(e['gekauft'])} | {zahl(e['gebraut'])} | "
              f"{zahl(e['dorf'])} | {pz(e['beschaedigt_anteil'])} | {pz(e['defekt_anteil'])} | {g(e['jagd'])} | {zahl(e['zerlegt'])} | "
              f"{zahl(e['beruhigt']) if ber else '–'}{' (' + pz(e['beruhigt_anteil']) + ')' if ber else ''} | {g(e['beruhigen_wert']) if ber else '–'} |")
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
    p.add_argument("--nur-wirtschaft", action="store_true", help="nur Abschnitt 5 (Wirtschaft) rechnen und ausgeben")
    p.add_argument("--ohne-wirtschaft", action="store_true", help="Abschnitt 5 nicht rechnen")
    p.add_argument("--nur-traenke", action="store_true", help="nur Abschnitt 6 (Traenke im Bosskampf, 481.1) ausgeben")
    args = p.parse_args()
    W = lade(args.werte)
    # 427.1: Boss mit Ueberfall auch mit Morwens Rauch (D4.1: der erste Hieb geht fehl), nur in Bossen und Matrix
    for n, m in list(ohne_info(W["monster"]).items()):
        if m.get("ueberfall"):
            W["monster"][n + " mit Rauch"] = dict(m, rauch=True)
    # 870c 3 A: das Rudel wie im Spiel (Wolf mit 1-2 Jungwoelfen, werte.json "merkmale" "rudel" "Jungwolf"), nur in Matrix und Bossen
    if "Wolf" in W["monster"]:
        W["monster"]["Rudel"] = dict(W["monster"]["Wolf"], rudel="Jungwolf", nur_matrix=True)
    if args.pruefen:
        sys.exit(1 if pruefen(W) else 0)
    kaempfe = args.kaempfe or W["lauf"]["kaempfe_je_fall"]
    laeufe = args.laeufe or W["lauf"]["fortschritt_laeufe"]

    def rechne_wirtschaft():
        rng = random.Random(W["lauf"]["zufallskeim"] + 5)
        we = {}
        for hk in ohne_info(W["herkuenfte"]):
            for ber in (False, True):
                we[(hk, ber)] = wirtschaft_alle(W, hk, laeufe, rng, ber)
            print(f"  {hk} Wirtschaft fertig", file=sys.stderr)
        return bericht_wirtschaft(W, we, laeufe)

    if args.nur_wirtschaft:
        text = rechne_wirtschaft()
        if args.aus:
            with open(args.aus, "w", encoding="utf-8") as f:
                f.write(text)
        else:
            sys.stdout.write(text)
        return

    def rechne(variante):
        rng = random.Random(W["lauf"]["zufallskeim"] + (1 if variante else 0))
        erg = {}
        for hk in ohne_info(W["herkuenfte"]):
            fo = fortschritt_alle(W, hk, laeufe, rng, variante)
            ma = matrix(W, hk, fo["fert_bei"], kaempfe, rng, variante)
            erg[hk] = {"fortschritt": fo, "matrix": ma}
            print(f"  {hk}{' (21)' if variante else ''} fertig", file=sys.stderr)
        return erg

    def rechne_traenke(erg):
        rng = random.Random(W["lauf"]["zufallskeim"] + 6)
        tr = {hk: traenke_boss(W, hk, e["fortschritt"]["fert_bei"], kaempfe, rng) for hk, e in erg.items()}
        pr = traenke_proben(W, erg["Kräutersammler"]["fortschritt"]["fert_bei"], kaempfe, rng) if "Kräutersammler" in erg else None
        return bericht_traenke(W, tr, kaempfe, pr)

    if args.nur_traenke:
        text = rechne_traenke(rechne(False))
        if args.aus:
            with open(args.aus, "w", encoding="utf-8") as f:
                f.write(text)
        else:
            sys.stdout.write(text)
        return

    erg = rechne(False)
    var = None if args.ohne_variante else rechne(True)
    text = bericht(W, erg, var, args)
    if not args.ohne_wirtschaft:
        text += "\n" + rechne_wirtschaft()
    text += "\n" + rechne_traenke(erg)
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
