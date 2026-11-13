"""1050 (Sokrates, 952 D, 984 A): Zauberlehrling nach 952 D, mit 644a (Grundwert durch Ueben), drei Wege. Nur Rechnung, keine Aenderung am Spiel.
   python3 tools/sim444/rechnung_1050.py tools/sim444 2000 300   (Kaempfe je Bosszelle, Laeufe Fortschritt; 644b nicht gerechnet: die Simulation kennt keine Zusatzeigenschaften)"""
import copy, json, random, statistics, sys
sys.path.insert(0, sys.argv[1])
import sim

W0 = sim.lade(sys.argv[1] + "/werte.json")
KAEMPFE = int(sys.argv[2]) if len(sys.argv) > 2 else 500
LAEUFE = int(sys.argv[3]) if len(sys.argv) > 3 else 100
BOSSE = {"Krogg": 4, "Grimmzahn": 5, "Grak": 6}
ZL = "Zauberlehrling"

_orig_init = sim.Held.__init__
_orig_steige = sim.Held._steige
_orig_grund = sim.zauber_grund
MIT_644A = [False]
ZAUBER_K = [1.0]


def gw_von(W, f):
    gv = W.get("ueben", {}).get("grundwert_von", {}).get(f)
    if gv:
        return gv
    for blk in ("waffen", "schulen"):
        d = W.get(blk, {}).get(f)
        if isinstance(d, dict) and d.get("grundwert"):
            return d["grundwert"]
    return None


def neu_werte(h):
    if not MIT_644A[0]:
        return
    n = h.W.get("ueben", {}).get("grundwert_punkte", 0)
    if not n:
        return
    gewinn = {}
    for f, v in h.fert.items():
        g = gw_von(h.W, f)
        if g:
            gewinn[g] = gewinn.get(g, 0) + max(0, v - h._start.get(f, 0))
    for g in h.werte:
        h.werte[g] = h._basis[g] + gewinn.get(g, 0) // n


def init(self, W, herkunft, variante=True):     # 1058: wie im Spiel 9 Punkte (plus und plus_variante)
    _orig_init(self, W, herkunft, variante)
    self._basis = dict(self.werte)
    self._start = dict(self.fert)


def steige(self, name):
    r = _orig_steige(self, name)
    neu_werte(self)
    return r


def grund(W, held, zb):
    if ZAUBER_K[0] == 1.0 or W["schulen"][zb["schule"]]["grundwert"] != "verstand" or "schaden" not in zb:
        return _orig_grund(W, held, zb)
    return zb["schaden"] + ZAUBER_K[0] * held.werte["verstand"]


def auf_stufe(W, herkunft, stufe, fert, variante=True):     # 1058
    h = sim.Held(W, herkunft, variante)
    h.stufe = stufe
    h.fert = dict(fert)
    neu_werte(h)
    return h


sim.Held.__init__ = init
sim.Held._steige = steige
sim.zauber_grund = grund
sim.held_auf_stufe = auf_stufe


def rechne(W, herkuenfte, seed=1050):
    rng = random.Random(seed)
    out = {}
    for hk in herkuenfte:
        fa = sim.fortschritt_alle(W, hk, LAEUFE, rng)
        res = {"nl12": fa["niederlage_je_stufe"].get(1)}
        for b, s in BOSSE.items():
            h = sim.held_auf_stufe(W, hk, s, fa["fert_bei"].get(s) or fa["fert_bei"][max(fa["fert_bei"])])
            mon = W["monster"][b]
            res[b] = sum(sim.kampf(W, h, mon, rng)["sieg"] for _ in range(KAEMPFE)) / KAEMPFE
        res["werte6"] = sim.held_auf_stufe(W, hk, 6, fa["fert_bei"].get(6) or fa["fert_bei"][max(fa["fert_bei"])]).werte
        out[hk] = res
    return out


def zeile(name, r):
    return "%-28s Krogg %3.0f  Grimmzahn %3.0f  Grak %3.0f  Niederl.1→2 %4.1f %%  Werte St.6 %s" % (
        name, 100 * r["Krogg"], 100 * r["Grimmzahn"], 100 * r["Grak"], 100 * (r["nl12"] or 0), r["werte6"])


alle = [k for k in sim.ohne_info(W0["herkuenfte"]).keys()]
print("Kaempfe je Zelle %d, Laeufe %d" % (KAEMPFE, LAEUFE))
MIT_644A[0] = False
basis = rechne(W0, alle)
print("== heute (952 D, ohne 644a)")
for hk in alle:
    print(zeile(hk, basis[hk]))
MIT_644A[0] = True
mit = rechne(W0, alle)
print("== mit 644a (Grundwert +1 je %d geuebte Punkte)" % W0["ueben"]["grundwert_punkte"])
for hk in alle:
    print(zeile(hk, mit[hk]))
andere = [h for h in alle if h != ZL]
for b in BOSSE:
    q = sorted(mit[h][b] for h in andere)
    print("Feld der uebrigen %s: kleinste %.0f, Median %.0f" % (b, 100 * q[0], 100 * statistics.median(q)))
# W1: Plus Verstand 3, Wille 3
W1 = copy.deepcopy(W0)
W1["herkuenfte"][ZL]["plus"] = {"wille": 3, "verstand": 3}
print(zeile("W1 Verstand 3, Wille 3", rechne(W1, [ZL])[ZL]))
# W2: Zauberschaden je Punkt Verstand
for k in (1.5, 2.0, 2.5, 3.0):
    ZAUBER_K[0] = k
    print(zeile("W2 Zauberschaden %.1f je Verstand" % k, rechne(W0, [ZL])[ZL]))
ZAUBER_K[0] = 1.0
