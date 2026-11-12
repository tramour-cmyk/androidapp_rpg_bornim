#!/usr/bin/env python3
"""444 Teil 7 (870.3, 870a 3 A): Kampfhandlungen und neue Zauber messen.

Zweikampf wie sim.py kampf (Held schlaegt zuerst, gleiche Formeln aus sim.py), von den Merkmalen nur Ueberfall (Krogg);
Umreissen und Rudel nicht (Bosse ohne Begleiter). Je Handlung ein Held der passenden Herkunft mit der
Fertigkeit auf Rang Geselle (25), eine Stufe unter dem Gegner; gemessen ohne und mit der Handlung: Siegquote, Restleben, Runden.
Was nur in der Gruppe wirkt (Griff, Schildwall, Mehrziel-Zauber), misst der Zweikampf nicht; es steht als „Gruppe“ in der Tabelle.

Aufruf:
  python3 tools/sim444/handlungen.py [--kaempfe 2000] [--aus DATEI.md]
"""
import argparse
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sim  # noqa: E402

GEGNER = ["Wolf", "Goblin", "Skelett", "Riesenspinne", "Krogg", "Grimmzahn", "Grak"]
# Handlung -> (Herkunft, Waffe, Ruestung, Schild)
WER = {
    "Kraft schöpfen": ("Wachsoldat", "Einhänder", "Mittlere Rüstung", True),
    "Finte": ("Wachsoldat", "Einhänder", "Mittlere Rüstung", True),
    "Stich aus dem Hinterhalt": ("Herumtreiber", "Dolche", "Leichte Rüstung", False),
    "Wuchtschlag": ("Wanderer", "Zweihänder", "Leichte Rüstung", False),
    "Auf Abstand": ("Wanderer", "Stangenwaffen", "Leichte Rüstung", False),
    "Schädelstoß": ("Schmiedelehrling", "Stumpfe Waffen", "Leichte Rüstung", False),
    "Ruhige Hand": ("Jägerkind", "Bogen", "Leichte Rüstung", False),
    "Durchschlag": ("Jägerkind", "Armbrust", "Leichte Rüstung", False),
    "Zwei auf einmal": ("Jägerkind", "Wurfwaffen", "Leichte Rüstung", False),
    "Wehrhaltung": ("Wachsoldat", "Einhänder", "Mittlere Rüstung", True),
}
ZAUBER_WER = {
    "Arkanpfeil": ("Zauberlehrling", "Funkenpfeil"),
    "Arkanhaut": ("Zauberlehrling", None),
    "Gleißstrahl": ("Klosterschüler", None),
    "Beistand": ("Klosterschüler", None),
}
GRUPPE = ["Griff", "Schildwall", "Glutstrahlen", "Flammenfächer", "Glutkugel"]


def held_fuer(W, herkunft, waffe, ruestung, schild, stufe, extra=None):
    h = sim.Held(W, herkunft)
    h.stufe = stufe
    h.waffe, h.ruestung, h.schild = waffe, ruestung, schild
    for f in list(h.fert):
        h.fert[f] = 25
    h.fert[waffe] = 25
    if ruestung != "keine":
        h.fert.setdefault(ruestung, 25)
    if schild:
        h.fert.setdefault("Schild", 25)
    for f in extra or []:
        h.fert[f] = 25
    return h


def duell(W, held, mon, rng, handlung=None, zauber=None):
    """Zweikampf; handlung: Name aus werte.json 'handlungen' oder None; zauber: neuer Zauber (statt/zusaetzlich) oder None."""
    k = W["kampf"]
    H = W["handlungen"]
    Z = W["zauber"]
    d = held.stufe - mon["stufe"]
    lmax = held.leben_max()
    leben, mana, mleben = lmax, held.mana_max(), mon["leben"]
    waffe = W["waffen"][held.waffe]
    schw = mon.get("schwaeche", {})
    z = {"kraft": 0, "naechster": 0.0, "erster": True, "wehr": False, "abstand": False, "m_betaeubt": 0,
         "haut": 0.0, "bann": 0.0, "beistand": 0, "ueb": bool(mon.get("ueberfall"))}
    ueb = W["merkmale"]["ueberfall"] if z["ueb"] else None

    def schlag(fert_name, grund, bonus, typ, faktor=1.0, ruestung_anteil=1.0):
        nonlocal mleben
        fw = held.f(fert_name)
        if rng.random() < sim.trefferchance(W, fw, mon["abwehr"], bonus):
            s = sim.schaden_roh(W, grund, fw, d, rng, sim.krit_prozent(W, held, fert_name, fw)) * faktor
            s *= schw.get(typ, 1.0) if typ else 1.0
            mleben -= sim.endschaden(W, s, mon["ruestung"] * ruestung_anteil)
            return True
        return False

    def waffengrund():
        gw = waffe["grundwert"]
        return waffe["schaden"] + (held.werte[gw] if gw else 0)

    def waffenbonus():
        b = k["fernkampf_treffer_je_wahrnehmung"] * held.werte["wahrnehmung"] if waffe["art"] == "fern" else 0.0
        return b + (Z["Beistand"]["treffer"] if z["beistand"] > 0 else 0.0)

    def gegner():
        nonlocal leben, mleben
        if z["m_betaeubt"] > 0:
            z["m_betaeubt"] -= 1
            return
        faktor = 1.0
        if ueb and z["erster"]:
            faktor = ueb["erster_treffer_faktor"]
        if z["abstand"] and mon["art"] == "nah":     # in die Spitze gelaufen
            schlag(held.waffe, waffengrund(), waffenbonus(), waffe["typ"], H["Auf Abstand"]["gegenstoss_faktor"])
            if mleben <= 0:
                return
        abw_name, abw = sim.held_abwehr(W, held, mon["art"])
        if z["wehr"]:
            abw += H["Wehrhaltung"]["abwehr"]
        if rng.random() < sim.trefferchance(W, mon["angriff"], abw):
            s = sim.schaden_roh(W, mon["schaden"], mon["angriff"], -d, rng) * faktor
            leben -= sim.endschaden(W, s, sim.held_abzug(W, held, z["bann"] + z["haut"]))
            z["erster"] = False

    runde = 0
    if ueb:
        gegner()
    while runde < W["lauf"]["max_runden"] and leben > 0:
        runde += 1
        z["wehr"] = z["abstand"] = False
        if z["beistand"] > 0:
            z["beistand"] -= 1
        h = handlung
        # ---- Held handelt
        if h == "Kraft schöpfen" and z["kraft"] < H[h]["je_kampf"] and leben < lmax * H[h]["unter"]:
            z["kraft"] += 1
            leben = min(lmax, leben + round(lmax * H[h]["heilung_anteil"]))
        elif zauber == "Arkanhaut" and z["haut"] == 0 and mana >= Z["Arkanhaut"]["kosten"]:
            zb = Z["Arkanhaut"]
            mana -= zb["kosten"]
            z["haut"] = zb["ruestung"] * (1 + held.f(zb["schule"]) * k["ruestungsfertigkeit_im_abzug_je_punkt"])
        elif zauber == "Beistand" and z["beistand"] == 0 and mana >= Z["Beistand"]["kosten"]:
            mana -= Z["Beistand"]["kosten"]
            z["beistand"] = Z["Beistand"]["runden"] + 1
        elif zauber in ("Arkanpfeil", "Gleißstrahl", "Funkenpfeil") and mana >= Z[zauber]["kosten"]:
            zb = Z[zauber]
            mana -= zb["kosten"]
            schlag(zb["schule"], sim.zauber_grund(W, held, zb), 0.0, zb.get("typ"))
        elif h in ("Finte", "Ruhige Hand") and z["naechster"] == 0 and \
                sim.trefferchance(W, held.f(held.waffe), mon["abwehr"], waffenbonus()) < 0.6:
            z["naechster"] = H[h]["naechster_treffer"]
        elif h == "Wehrhaltung" and leben < lmax * 0.5:
            z["wehr"] = True
            schlag(held.waffe, waffengrund(), waffenbonus() + H[h]["treffer"], waffe["typ"])
        else:
            if h == "Auf Abstand" and mon["art"] == "nah":
                z["abstand"] = True
            bonus = waffenbonus() + z["naechster"]
            z["naechster"] = 0.0
            if h == "Stich aus dem Hinterhalt" and runde == 1:
                schlag(held.waffe, waffengrund(), bonus, waffe["typ"], H[h]["schaden_faktor"])
            elif h == "Auf Abstand":
                schlag(held.waffe, waffengrund(), bonus + H[h]["treffer"], waffe["typ"])
            elif h == "Wuchtschlag":
                schlag(held.waffe, waffengrund(), bonus + H[h]["treffer"], waffe["typ"], H[h]["schaden_faktor"])
            elif h == "Schädelstoß":
                if schlag(held.waffe, waffengrund(), bonus + H[h]["treffer"], waffe["typ"]) and rng.random() < H[h]["betaeubt_chance"]:
                    z["m_betaeubt"] = H[h]["betaeubt_zuege"]
            elif h == "Durchschlag":
                schlag(held.waffe, waffengrund(), bonus, waffe["typ"], 1.0, H[h]["ruestung_anteil"])
            elif h == "Zwei auf einmal":
                for _ in range(H[h]["wuerfe"]):
                    schlag(held.waffe, waffengrund(), bonus, waffe["typ"], H[h]["schaden_faktor"])
            else:
                schlag(held.waffe, waffengrund(), bonus, waffe["typ"])
        if mleben <= 0:
            return True, leben / lmax, runde
        gegner()
        if mleben <= 0:
            return True, leben / lmax, runde
    return False, max(0.0, leben) / lmax, runde


def messe(W, held_neu, mon, n, rng, **kw):
    s = l = r = 0.0
    for _ in range(n):
        sieg, rest, runden = duell(W, held_neu(), mon, rng, **kw)
        s += sieg
        l += rest if sieg else 0.0
        r += runden
    return s / n, (l / s if s else 0.0), r / n


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--werte", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), "werte.json"))
    p.add_argument("--kaempfe", type=int, default=2000)
    p.add_argument("--aus")
    a = p.parse_args()
    W = sim.lade(a.werte)
    rng = random.Random(870)
    zeilen = ["| Handlung | Fertigkeit | " + " | ".join(GEGNER) + " |", "|---|---|" + "---|" * len(GEGNER)]
    def zelle(o, m):
        return f"{round(o[0] * 100)} → **{round(m[0] * 100)}** % ({round(o[1] * 100)} → {round(m[1] * 100)})"
    for h, (hk, wf, ru, sch) in WER.items():
        zs = []
        for g in GEGNER:
            mon = W["monster"][g]
            neu = lambda: held_fuer(W, hk, wf, ru, sch, max(1, mon["stufe"] - 1))
            o = messe(W, neu, mon, a.kaempfe, rng)
            m = messe(W, neu, mon, a.kaempfe, rng, handlung=h)
            zs.append(zelle(o, m))
        zeilen.append(f"| {h} | {W['handlungen'][h]['fertigkeit'] or 'alle'} | " + " | ".join(zs) + " |")
    for zn, (hk, alt) in ZAUBER_WER.items():
        zs = []
        schule = W["zauber"][zn]["schule"]
        for g in GEGNER:
            mon = W["monster"][g]
            neu = lambda: held_fuer(W, hk, W["herkuenfte"][hk]["waffe"], W["herkuenfte"][hk]["ruestung"], False, max(1, mon["stufe"] - 1), [schule])
            o = messe(W, neu, mon, a.kaempfe, rng, zauber=alt)
            m = messe(W, neu, mon, a.kaempfe, rng, zauber=zn)
            zs.append(zelle(o, m))
        zeilen.append(f"| {zn} (statt {alt or 'Waffe'}) | {schule} | " + " | ".join(zs) + " |")
    for g in GRUPPE:
        zeilen.append(f"| {g} | Gruppe | " + " | ".join(["–"] * len(GEGNER)) + " |")
    text = ("## Teil 7: Kampfhandlungen und neue Zauber (870.3, Zweikampf)\n\n"
            f"Siegquote ohne → **mit** der Handlung, in Klammern Restleben der Sieger in % des Höchstwerts; je Zelle {a.kaempfe} Kämpfe, "
            "Held eine Stufe unter dem Gegner (mindestens 1), Bosse ohne Begleiter, alle Fertigkeiten 25 (Rang Geselle), Keim 870; Zahlen `werte.json` „handlungen“ und „zauber“ (A).\n\n"
            + "\n".join(zeilen) + "\n")
    if a.aus:
        with open(a.aus, "w") as f:
            f.write(text)
    print(text)


if __name__ == "__main__":
    main()
