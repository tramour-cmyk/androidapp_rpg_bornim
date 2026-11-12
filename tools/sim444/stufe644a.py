#!/usr/bin/env python3
"""Vorgang 644a.1: Rechnung vor dem Bau (644a A mit Spanne, D, F; DESIGN-BRS.md 11 „Gegenstandsstufe“).

Fragt drei Dinge, alle Zahlen aus werte.json (Block „gegenstaende“, „ueben“), der Fortschritt aus sim.py (Teil 1):
  1. Spannen der Zusatzeigenschaften je Gegenstandsstufe (Schritt alle drei Stufen).
  2. Ohne Deckel: wie viel ein Held in Kapitel 1 auf einen Grundwert und auf den Schutzwert tragen kann, schlimmster und
     üblicher Fall, mit vollem und halbem Gewicht der Grundwerte beim Würfeln.
  3. Wachsen durch Üben: wie viele Fertigkeitspunkte die Fertigkeiten an einem Grundwert bis zum Kapitelende (Stufe 6)
     gewinnen; daraus die Zahl, bei der der Hauptwert etwa einmal wächst.

Modell der Beute (beute.gd, Kapitel 1): je gewonnenem Kampf 38 % ein Stück; ab Heldenstufe 2 davon 15 % ungewöhnlich (eine
Zusatzeigenschaft), sonst gewöhnlich; Grundform nach den Fertigkeiten des Helden gewichtet; Zusatzeigenschaft aus der Liste des
Platzes. Dazu je Durchgang: drei Bosse (je ein seltenes Stück, zwei Zusatzeigenschaften, und ein bis zwei gewöhnliche Funde),
vier Truhen mit besonderem Fund (ungewöhnlich, selten, selten, selten: „sehr selten“ deckelt Kapitel 1 auf selten), die Gabe
@gear:UNCOMMON:HEAD, die Truhenwaffe der Höhle und die Einzelstücke der Bosse (633: Kroggs Pranken +1 Kraft, Grimmzahns Fang
+1 Gewandtheit, Graks Kriegsaxt +1 Kraft). Der Held legt je Platz das Stück an, das seinen Wert am meisten hebt; Waffe nur
seiner Waffengruppe, Schild nur wer einen führt, Metall nicht für Evokation.

Aufruf: python3 tools/sim444/stufe644a.py [--laeufe 200] [--aus DATEI.md]
"""
import argparse
import json
import os
import random
import statistics
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import sim  # noqa: E402

GW = sim.GRUNDWERTE
AFFIX = {"kraft": "STR", "gewandtheit": "DEX", "zaehigkeit": "CON", "verstand": "INT", "wahrnehmung": "WIS", "wille": "CHA"}
PLAETZE = ["HEAD", "CHEST", "ARMS", "LEGS", "CLOAK", "AMULET", "RING", "MAIN_HAND", "OFF_HAND"]
WAFFE_GRUPPE = {"": "Faustkampf", "dagger": "Dolche", "shortsword": "Einhänder", "scimitar": "Einhänder", "handaxe": "Einhänder",
                "longsword": "Einhänder", "battleaxe": "Einhänder", "rapier": "Einhänder", "mace": "Stumpfe Waffen",
                "quarterstaff": "Stumpfe Waffen", "warhammer": "Stumpfe Waffen", "morningstar": "Stumpfe Waffen",
                "wand": "Stumpfe Waffen", "staff": "Stumpfe Waffen", "spear": "Stangenwaffen", "halberd": "Stangenwaffen",
                "greatsword": "Zweihänder", "greataxe": "Zweihänder", "maul": "Zweihänder", "shortbow": "Bogen",
                "longbow": "Bogen", "light_crossbow": "Armbrust"}
TRUHE = {"Einhänder": "longsword_oakford", "Dolche": "rapier_whisper", "Stumpfe Waffen": "mace_of_dawn", "Bogen": "longbow_blackyew",
         "Armbrust": "crossbow_nightwatch", "Zweihänder": "greatsword_nameless", "Stangenwaffen": "spear_wolf",
         "Heilmagie": "mace_of_dawn", "Evokation": "staff_of_embers"}
BOSS_EINZEL = ["gauntlets_ogre", "amulet_grimfang", "greataxe_grak"]
# Kampfstil (DESIGN-BRS.md „Querschnitt“) -> Herkunft der Simulation, Hauptwert (Grundwert des Schadens, 952 D)
STILE = [("Krieger", "Wachsoldat", "kraft"), ("Schütze", "Jägerkind", "gewandtheit"), ("Späher", "Herumtreiber", "gewandtheit"),
         ("Magier", "Zauberlehrling", "verstand"), ("Heiler", "Klosterschüler", "wille"), ("Wanderer", "Wanderer", "kraft")]


def grundwert_von(W, mit_ruestung):
    """Fertigkeit -> Grundwert, an dem sie hängt. A: nur was werte.json nennt (Waffen, Schulen: Grundwert des Schadens);
    B: dazu Rüstung -> Zähigkeit, Ausweichen -> Gewandtheit (DESIGN-BRS.md 2 „Wirkt auf“)."""
    m = {}
    for blk in ("waffen", "schulen"):
        for n, d in sim.ohne_info(W[blk]).items():
            if isinstance(d, dict) and d.get("grundwert"):
                m[n] = d["grundwert"]
    if mit_ruestung:
        for r in ("Leichte Rüstung", "Mittlere Rüstung", "Schwere Rüstung"):
            m[r] = "zaehigkeit"
        m["Ausweichen"] = "gewandtheit"
    return m


# ---------------------------------------------------------------- Teil 1: Fortschritt mit Kampfliste

def durchgang(W, herkunft, rng):
    """Wie sim.fortschritt, dazu je gewonnenem Kampf (Heldenstufe, Gegnerstufe) und die Fertigkeiten am Ende."""
    monster = {n: m for n, m in sim.ohne_info(W["monster"]).items() if not m.get("boss") and not m.get("nur_matrix")}
    fs = W["fortschritt"]
    grenze = W["held"]["kapitelgrenze"]
    held = sim.Held(W, herkunft)
    start = dict(held.fert)
    siege = []
    kaempfe = 0
    while held.stufe < grenze and kaempfe < fs["max_kaempfe"]:
        lo, hi = held.stufe - fs["gegner_band_unten"], held.stufe + fs["gegner_band_oben"]
        mon = rng.choice([m for m in monster.values() if lo <= m["stufe"] <= hi])
        kaempfe += 1
        r = sim.kampf(W, held, mon, rng, lernen=True)
        if r["sieg"]:
            siege.append((held.stufe, mon["stufe"]))
            held.gib_ep(sim.ep_fuer(W, held, mon), "kampf")
            held.nach_sieg(r["benutzt"], mon["stufe"])
        held.stufe_auf()
    return {"start": start, "ende": dict(held.fert), "siege": siege, "held": held}


def gewinn(start, ende, zuordnung):
    g = {k: 0 for k in GW}
    for f, v in ende.items():
        if f in zuordnung:
            g[zuordnung[f]] += max(0, v - start.get(f, 0))
    return g


# ---------------------------------------------------------------- Teil 2: Beute ohne Deckel

class Beute:
    def __init__(self, W, formen, halb, schutz_halb=False):
        self.schutz_halb = schutz_halb
        self.W = W
        self.G = W["gegenstaende"]
        self.formen = formen
        self.halb = halb

    def erlaubt(self, fid):
        b = self.formen[fid]
        e = self.G["erlaubt"]
        if b["art"] == "LIGHT":
            return []
        if b["art"] == "FOCUS" or (b["art"] == "WEAPON" and int(b["fokus"]) > 0):
            return e["FOKUS"]
        if b["art"] == "WEAPON":
            return e["FERNWAFFE" if b["fern"] else "WAFFE"]
        if b["art"] == "SHIELD":
            return e["SHIELD"]
        return e.get(b["slot"], e["RING"])

    def fertigkeit_von(self, fid):
        b = self.formen[fid]
        if b["art"] == "WEAPON":
            return WAFFE_GRUPPE.get(fid, "Einhänder")
        if b["art"] == "SHIELD":
            return "Schild"
        if b["art"] == "ARMOR" and b["slot"] == "CHEST":
            return {"LIGHT": "Leichte Rüstung", "MEDIUM": "Mittlere Rüstung", "HEAVY": "Schwere Rüstung"}.get(b["gewicht"], "")
        return ""

    def form(self, rng, held, stufe):
        grund = int(self.G["fertigkeit_grund"])
        pool, gew = [], []
        for fid, b in self.formen.items():
            if b["art"] != "LIGHT" and int(b["ab_stufe"]) <= stufe:
                f = self.fertigkeit_von(fid)
                pool.append(fid)
                gew.append(grund + (held.f(f) if f else grund))
        return rng.choices(pool, gew)[0]

    def zusatz(self, rng, fid, n):
        l = list(self.erlaubt(fid))
        out = []
        while len(out) < n and l:
            gw = [1 if (self.halb and a in AFFIX.values()) or (self.schutz_halb and a == "AC") else 2 for a in l]
            a = rng.choices(l, gw)[0]
            l.remove(a)
            out.append(a)
        return out

    def stueck(self, rng, held, stufe, n):
        fid = self.form(rng, held, stufe)
        return (fid, self.zusatz(rng, fid, n), stufe)


def funde(W, B, d, rng):
    """Alle Stücke eines Durchgangs mit Zusatzeigenschaften: [(Grundform, [Kennungen])]."""
    G = W["gegenstaende"]
    held = d["held"]
    out = []
    for hs, ms in d["siege"]:
        if rng.random() < G["beute_chance"]:
            n = 1 if hs >= G["kapitel1_ungewoehnlich_ab_stufe"] and rng.random() * 1000 < G["kapitel1_ungewoehnlich_promille"] else 0
            out.append(B.stueck(rng, held, min(ms, hs + 1), n))
    for st in (4, 5, 6):                               # Bosse: ein seltenes Stück und ein bis zwei gewöhnliche Funde
        out.append(B.stueck(rng, held, st, 2))
        for _ in range(rng.randint(1, 2)):
            n = 1 if rng.random() * 1000 < G["kapitel1_ungewoehnlich_promille"] else 0
            out.append(B.stueck(rng, held, st, n))
    for st, n in ((2, 1), (3, 2), (3, 2), (4, 2)):     # Truhen @gear: UNCOMMON, RARE, VERY_RARE (Decke selten), RARE
        out.append(B.stueck(rng, held, st, n))
    fid = rng.choice([k for k, b in B.formen.items() if b["slot"] == "HEAD" and int(b["ab_stufe"]) <= 3])
    out.append((fid, B.zusatz(rng, fid, 1), 3))          # Gabe @gear:UNCOMMON:HEAD
    for e in BOSS_EINZEL + [TRUHE.get(held.waffe)]:
        if e:
            es = G["einzelstuecke"][e]
            out.append((es["grundform"], [z[0] for z in es["zusatz"]], 1))
    return out


def traegt(B, held, fid):
    b = B.formen[fid]
    if b["slot"] == "MAIN_HAND":
        return WAFFE_GRUPPE.get(fid) == held.waffe
    if b["slot"] == "OFF_HAND":
        return b["art"] == "SHIELD" and held.schild
    if b["slot"] == "CHEST" and "Evokation" in held.fert:
        return b["gewicht"] not in ("MEDIUM", "HEAVY")
    return True


def bestes(B, held, stuecke, kennung):
    """Je Platz das Stück mit der Kennung; Summe über die Plätze (Schutzwert je Stück mal Schritt der Gegenstandsstufe)."""
    je_platz = {}
    for fid, z, st in stuecke:
        if kennung in z and traegt(B, held, fid):
            w = (st - 1) // 3 + 1 if kennung == "AC" else 1
            je_platz[B.formen[fid]["slot"]] = max(je_platz.get(B.formen[fid]["slot"], 0), w)
    return sum(je_platz.values())


def ausstatten(B, held, stuecke, haupt, schutz_eins=False):
    """Eine Ausrüstung: je Platz das eine Stück, das Hauptwert + Schutzwert zusammen am meisten hebt; zurück (Hauptwert, Schutzwert)."""
    je_platz = {}
    for fid, z, st in stuecke:
        if not traegt(B, held, fid):
            continue
        h = 1 if AFFIX[haupt] in z else 0
        sw = (1 if schutz_eins else (st - 1) // 3 + 1) if "AC" in z else 0
        p = B.formen[fid]["slot"]
        if h + sw > sum(je_platz.get(p, (0, 0))):
            je_platz[p] = (h, sw)
    return sum(v[0] for v in je_platz.values()), sum(v[1] for v in je_platz.values())


def schlimmst(B, held, kennung, wert=1):
    """Jeder Platz, der die Kennung haben kann und den der Held trägt, mit ihr."""
    n = 0
    for p in PLAETZE:
        if any(B.formen[f]["slot"] == p and kennung in B.erlaubt(f) and traegt(B, held, f) for f in B.formen):
            n += wert
    return n


# ---------------------------------------------------------------- Bericht

def q(xs, p):
    xs = sorted(xs)
    return xs[min(len(xs) - 1, int(p * len(xs)))]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--werte", default=os.path.join(HIER, "werte.json"))
    ap.add_argument("--formen", default=os.path.join(HIER, "..", "..", "godot", "daten", "held.json"))
    ap.add_argument("--laeufe", type=int, default=200)
    ap.add_argument("--saat", type=int, default=644)
    ap.add_argument("--kaempfe", type=int, default=400, help="Kämpfe je Zelle in Teil 5")
    ap.add_argument("--durch", type=int, default=300, help="Durchgänge je Kampfstil in Teil 6")
    ap.add_argument("--je", type=int, default=40, help="Kämpfe je Durchgang und Boss in Teil 6")
    ap.add_argument("--schwelle", type=int, help="Punkte je Grundwert +1 (sonst werte.json ueben grundwert_punkte, sonst 10)")
    ap.add_argument("--aus")
    a = ap.parse_args()
    W = sim.lade(a.werte)
    formen = sim.lade(a.formen)["grundformen"]
    rng = random.Random(a.saat)
    z = []
    z.append("# Rechnung 644a.1: Gegenstandsstufe, Deckel, Wachsen durch Üben\n")
    z.append("`python3 tools/sim444/stufe644a.py --laeufe %d --saat %d` (Fortschritt aus sim.py Teil 1 bis Stufe %d, je Kampfstil %d Durchgänge)\n"
             % (a.laeufe, a.saat, W["held"]["kapitelgrenze"], a.laeufe))
    # 1. Spannen
    z.append("## 1. Spannen je Gegenstandsstufe\n")
    sp = W["gegenstaende"]["zusatz"]
    z.append("| Stufe | Schritt | " + " | ".join(k for k in ("HP", "SP", "CRIT", "SPELL", "TENACITY", "AC")) + " | Grundwert |")
    z.append("| --- | --- |" + " --- |" * 7)
    for lo in (1, 4, 7, 10, 13):
        k = (lo - 1) // 3 + 1
        zellen = []
        for key in ("HP", "SP", "CRIT", "SPELL", "TENACITY", "AC"):
            s = sp[key].get("spanne", [sp[key].get("wert", 0)] * 2)
            zellen.append("%d–%d" % (s[0] * k, s[1] * k) if s[0] != s[1] else "%d" % (s[0] * k))
        z.append("| %d–%d | %d | %s | 1 |" % (lo, lo + 2, k, " | ".join(zellen)))
    z.append("")
    ergebnisse = {}
    for name, hk, haupt in STILE:
        ds = [durchgang(W, hk, rng) for _ in range(a.laeufe)]
        ergebnisse[name] = (hk, haupt, ds)
    # 2. Deckel
    z.append("## 2. Ohne Deckel: was ein Held in Kapitel 1 trägt\n")
    z.append("Je Durchgang alle Funde bis Stufe 6 (Modell oben im Skript); der Held legt je Platz das Stück mit seinem Wert an. "
             "Spalten: Median / 90 % / 99 % der Durchgänge / schlimmster Fall (jeder Platz). „Bester“: der Grundwert, auf den er am meisten findet.\n")
    z.append("| Kampfstil | Gewicht | Hauptwert | bester Grundwert | Schutzwert (Stufe 1–3 +1, 4–6 +2 je Stück) | Siege bis Stufe 6 |")
    z.append("| --- | --- | --- | --- | --- | --- |")
    ausr_halb = {}
    schutz_halb = {}
    for halb in (False, True, "schutz"):
        B = Beute(W, formen, bool(halb), halb == "schutz")
        for name, (hk, haupt, ds) in ergebnisse.items():
            h_l, b_l, s_l = [], [], []
            for d in ds:
                st = funde(W, B, d, rng)
                h_l.append(bestes(B, d["held"], st, AFFIX[haupt]))
                b_l.append(max(bestes(B, d["held"], st, AFFIX[g]) for g in GW))
                s_l.append(bestes(B, d["held"], st, "AC"))
            if halb is True:
                ausr_halb[name] = h_l
                schutz_halb[name] = s_l
            held = ds[0]["held"]
            schl_h = schlimmst(B, held, AFFIX[haupt])
            schl_b = max(schlimmst(B, held, AFFIX[g]) for g in GW)
            schl_s = schlimmst(B, held, "AC", 2)
            fmt = lambda xs, s: "%d / %d / %d / %d" % (statistics.median(xs), q(xs, 0.9), q(xs, 0.99), s)
            z.append("| %s | %s | %s %s | %s | %s | %d |" % (name, {False: "voll", True: "halb", "schutz": "halb, Schutzwert auch"}[halb], haupt, fmt(h_l, schl_h), fmt(b_l, schl_b),
                                                        fmt(s_l, schl_s), statistics.median(len(d["siege"]) for d in ds)))
    z.append("")
    z.append("Heute (mit Deckel, Kapitel 1): Grundwert höchstens +1, Schutzwert höchstens +2.\n")
    # 3. Üben
    z.append("## 3. Wachsen durch Üben: Punkte bis Stufe 6\n")
    for mit_r in (False, True):
        zu = grundwert_von(W, mit_r)
        z.append("**Zuordnung %s** (%s)\n" % ("B" if mit_r else "A", "Waffen und Schulen, dazu Rüstung → Zähigkeit, Ausweichen → Gewandtheit"
                                                if mit_r else "nur Waffen und Schulen nach werte.json „grundwert“"))
        z.append("| Kampfstil | Hauptwert | Punkte am Hauptwert (10 % / Median / 90 %) | höchster anderer Grundwert (Median / 90 %) |")
        z.append("| --- | --- | --- | --- |")
        for name, (hk, haupt, ds) in ergebnisse.items():
            gs = [gewinn(d["start"], d["ende"], zu) for d in ds]
            hp = [g[haupt] for g in gs]
            an = [max(v for k, v in g.items() if k != haupt) for g in gs]
            z.append("| %s | %s | %d / %d / %d | %d / %d |" % (name, haupt, q(hp, 0.1), statistics.median(hp), q(hp, 0.9),
                                                               statistics.median(an), q(an, 0.9)))
        z.append("")
    # Vorschlag Schwelle
    zu = grundwert_von(W, False)
    alle_h = []
    alle_a = []
    for name, (hk, haupt, ds) in ergebnisse.items():
        for d in ds:
            g = gewinn(d["start"], d["ende"], zu)
            alle_h.append(g[haupt])
            alle_a.append(max(v for k, v in g.items() if k != haupt))
    z.append("**Schwelle (Zuordnung A):** je Zahl N der Anteil der Durchgänge, in denen der Hauptwert bis Stufe 6 0-, 1-, 2-mal wächst, "
             "und in denen ein anderer Grundwert wächst.\n")
    z.append("| N | Hauptwert 0 | 1 | 2+ | anderer Grundwert ≥ 1 |")
    z.append("| --- | --- | --- | --- | --- |")
    for n in (8, 9, 10, 11, 12, 14, 16, 18, 20):
        c0 = sum(1 for x in alle_h if x // n == 0) / len(alle_h)
        c1 = sum(1 for x in alle_h if x // n == 1) / len(alle_h)
        c2 = sum(1 for x in alle_h if x // n >= 2) / len(alle_h)
        an = sum(1 for x in alle_a if x >= n) / len(alle_a)
        z.append("| %d | %.0f %% | %.0f %% | %.0f %% | %.0f %% |" % (n, 100 * c0, 100 * c1, 100 * c2, 100 * an))
    z.append("")
    n = a.schwelle or int(W["ueben"].get("grundwert_punkte", 10))
    z.append("## 4. Beides zusammen: Hauptwert bis Stufe 6 (Ausrüstung halbes Gewicht, Üben N = %d, Zuordnung A)\n" % n)
    z.append("| Kampfstil | Hauptwert | Start | durch Üben (Median) | Ausrüstung + Üben (Median / 90 % / 99 %) |")
    z.append("| --- | --- | --- | --- | --- |")
    zusammen = {}
    for name, (hk, haupt, ds) in ergebnisse.items():
        ue = [gewinn(d["start"], d["ende"], zu)[haupt] // n for d in ds]
        ges = [x + y for x, y in zip(ausr_halb[name], ue)]
        zusammen[name] = (statistics.median(ges), q(ges, 0.9), statistics.median(schutz_halb[name]), q(schutz_halb[name], 0.9),
                          statistics.median(ue))
        z.append("| %s | %s | %d | %d | +%d / +%d / +%d |" % (name, haupt, ds[0]["held"].werte[haupt], statistics.median(ue),
                                                           statistics.median(ges), q(ges, 0.9), q(ges, 0.99)))
    z.append("")
    # 5. Wirkung im Bosskampf
    _abzug = sim.held_abzug
    sim.held_abzug = lambda W_, h, *x, **k: _abzug(W_, h, *x, **k) + getattr(h, "extra_schutz", 0)
    bosse = {nm: m for nm, m in sim.ohne_info(W["monster"]).items() if m.get("boss")}
    z.append("## 5. Wirkung: Siegquote gegen die Bosse (Held auf Bossstufe, Fertigkeiten wie am Kapitelende, je %d Kämpfe)\n" % a.kaempfe)
    z.append("Spalten: Hauptwert/Schutzwert aus der Ausrüstung (und Üben). „heute“: mit Deckel höchstens +1/+2 und ohne Üben; "
             "„üblich“ und „1 von 10“: ohne Deckel, Median und 90 % aus Teil 2 und 4.\n")
    z.append("| Kampfstil | Boss | nichts | heute höchstens | üblich ohne Deckel | 1 von 10 ohne Deckel |")
    z.append("| --- | --- | --- | --- | --- | --- |")
    for name, (hk, haupt, ds) in ergebnisse.items():
        fert = {f: round(statistics.median(d["ende"].get(f, 0) for d in ds)) for f in ds[0]["ende"]}
        hm, h9, sm, s9, _ = zusammen[name]
        for bn, mon in bosse.items():
            zellen = []
            for plus, schutz in ((0, 0), (1, 2), (int(hm), int(sm)), (int(h9), int(s9))):
                h = sim.held_auf_stufe(W, hk, mon["stufe"], fert)
                h.werte[haupt] += plus
                h.extra_schutz = schutz
                sg = sum(1 for _ in range(a.kaempfe) if sim.kampf(W, h, mon, rng)["sieg"])
                zellen.append("%.0f %% (+%d/+%d)" % (100 * sg / a.kaempfe, plus, schutz))
            z.append("| %s | %s | %s |" % (name, bn, " | ".join(zellen)))
    z.append("")
    # 6. je Durchgang: eine Ausrüstung, Siegquote gegen Krogg und Grak
    z.append("## 6. Je Durchgang: eine Ausrüstung (je Platz ein Stück), damit gegen die Bosse (%d Durchgänge je Kampfstil, je Durchgang %d Kämpfe)\n" % (a.durch, a.je))
    z.append("Wege: heute = Deckel (+1, Schutzwert +2), mit Üben; B = ohne Deckel, Schutzwert je Stück +1 (Stufe 1–3) bzw. +2 (4–6), "
             "mit Üben; A = ohne Deckel, Schutzwert je Stück immer +1, mit Üben; H = wie B, Schutzwert würfelt mit halbem Gewicht. "
             "Zellen: Siegquote über alle Durchgänge / Anteil der Durchgänge, die mindestens 95 % der Kämpfe gewinnen; dahinter Hauptwert "
             "und Schutzwert üblich (Median); nach dem Strichpunkt der höchste Wert.\n")
    z.append("| Kampfstil | Boss | heute | B | A | H |")
    z.append("| --- | --- | --- | --- | --- | --- |")
    BH = Beute(W, formen, True)
    BS = Beute(W, formen, True, True)
    for name, (hk, haupt, ds) in ergebnisse.items():
        fert = {f: round(statistics.median(d["ende"].get(f, 0) for d in ds)) for f in ds[0]["ende"]}
        wege = {"heute": [], "B": [], "A": [], "H": []}
        for d in ds[:a.durch]:
            ue = gewinn(d["start"], d["ende"], zu)[haupt] // n
            st = funde(W, BH, d, rng)
            hb, sb = ausstatten(BH, d["held"], st, haupt)
            ha, sa = ausstatten(BH, d["held"], st, haupt, True)
            hh, shh = ausstatten(BS, d["held"], funde(W, BS, d, rng), haupt)
            wege["heute"].append((min(hb, 1) + ue, min(sb, 2)))     # Üben (644a F) wirkt auch mit Deckel
            wege["B"].append((hb + ue, sb))
            wege["A"].append((ha + ue, sa))
            wege["H"].append((hh + ue, shh))
        for bn in ("Krogg", "Grimmzahn", "Grak"):
            mon = bosse[bn]
            zellen = []
            for weg in ("heute", "B", "A", "H"):
                quoten = []
                for plus, schutz in wege[weg]:
                    h = sim.held_auf_stufe(W, hk, mon["stufe"], fert)
                    h.werte[haupt] += plus
                    h.extra_schutz = schutz
                    quoten.append(sum(1 for _ in range(a.je) if sim.kampf(W, h, mon, rng)["sieg"]) / a.je)
                hm = statistics.median(x[0] for x in wege[weg]); sm = statistics.median(x[1] for x in wege[weg])
                hx = max(x[0] for x in wege[weg]); sx = max(x[1] for x in wege[weg])
                zellen.append("%.0f %% / %.0f %% (+%d/+%d; %d/%d)" % (100 * statistics.mean(quoten), 100 * sum(1 for x in quoten if x >= 0.95) / len(quoten),
                                                                  hm, sm, hx, sx))
            z.append("| %s | %s | %s |" % (name, bn, " | ".join(zellen)))
    z.append("")
    sim.held_abzug = _abzug
    text = "\n".join(z)
    if a.aus:
        with open(a.aus, "w", encoding="utf-8") as f:
            f.write(text + "\n")
    print(text)


if __name__ == "__main__":
    main()
