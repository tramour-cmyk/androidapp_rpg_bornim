#!/usr/bin/env python3
"""1643: Nachtstopp nach zwei Neustarts desselben Vorgangs; am Tag nie; andere Nummer zählt nicht; Sokrates-Schwelle 400 Tsd."""
import datetime, os, sys, zoneinfo
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import nachtstarts as N
B = zoneinfo.ZoneInfo("Europe/Berlin")
fehler = []
nacht = datetime.datetime(2026, 11, 18, 2, 30, tzinfo=B)
p = ["- 22:10 17.11.: Startsperre 22:10 Start Ford (lauf.py, 1610)",
     "- 23:40 17.11.: Startsperre 23:40 Start Ford (Neustart abc, 1610)",
     "- 01:05 18.11.: Startsperre 01:05 Start Tom, Ford (lauf.py, Tom 1631, Ford 1610)",
     "- 01:20 18.11.: Startsperre 01:20 Start Ford (lauf.py, 1610.1)",
     "- 20:10 17.11.: Startsperre 20:10 Start Ford (lauf.py, 1610)"]
if N.zaehlen("Ford", "1610", nacht, p) != 3: fehler.append("Zahl %d statt 3" % N.zaehlen("Ford", "1610", nacht, p))
if not N.angehalten("Ford", "1610", nacht, p): fehler.append("nicht angehalten")
if N.angehalten("Ford", "1610", nacht, p, mit_diesem=True): fehler.append("mit_diesem zu früh")
if N.angehalten("Ford", "1610.1", nacht, p): fehler.append("Unternummer")
if N.zaehlen("Ford", "1610", datetime.datetime(2026, 11, 18, 10, 0, tzinfo=B), p): fehler.append("am Tag gezählt")
import importlib.util
spec = importlib.util.spec_from_file_location("sh", os.path.join(os.path.dirname(os.path.abspath(__file__)), "startsperre-haken.py"))
sh = importlib.util.module_from_spec(spec); spec.loader.exec_module(sh)
N_alt = N.angehalten
N.angehalten = lambda r, nr, jetzt=None, protokoll=None, mit_diesem=False: (r, nr, mit_diesem) == ("Ford", "1610", True)
if not sh.nacht("Ford", {"title": "Ford – 1610: Wache (18.11., 02:30)"}): fehler.append("Haken hält nicht")
if sh.nacht("Ford", {"title": "Ford – Betriebsleiter (18.11., 02:30)"}): fehler.append("Haken ohne Nummer")
N.angehalten = N_alt
# 1792: Ausnahme 1784 A (Chef 21.11., 21:54: höchstens acht weitere Spike-Starts an 1739, spätestens 03:00)
A = ("- **1784, Nachtstopp Spike** (21.11., 21:54, Chef an Sokrates: „1784 A“) → **heute Nacht höchstens acht weitere "
     "Spike-Starts an 1739, spätestens 03:00; Ford startet von Hand nur, wenn …; sonst Nachtstopp (Nutzer; Votum Sokrates)**\n"
     "- **9999, ohne Chef** (21.11., 21:50, Sokrates: „x“) → **höchstens zehn Tom-Starts an 1739**")
vor = ["- 21:20 21.11.: Startsperre 21:20 Start Spike (lauf.py, 1739)", "- 21:35 21.11.: Startsperre 21:35 Start Spike (Neustart x, 1739)",
       "- 21:41 21.11.: Startsperre 21:41 Start Spike (Neustart y, 1739)"]
nach = ["- %s 21.11.: Startsperre %s Start Spike (Ausnahme 1784 A, Start %d/8; 1739 Teil %d)" % (u, u, i + 1, i + 7)
        for i, u in enumerate(["21:55", "22:06", "22:17", "22:27", "22:40", "23:00", "23:30", "23:50"])]
um = lambda h, mi, tag=21: datetime.datetime(2026, 11, tag, h, mi, tzinfo=B)
if not N.angehalten("Spike", "1739", um(21, 45), vor, text=""): fehler.append("ohne Ausnahme nicht angehalten")
if N.angehalten("Spike", "1739", um(22, 27), vor + nach[:4], mit_diesem=True, text=A): fehler.append("Start 4/8 angehalten (Fall 21.11.)")
if N.angehalten("Spike", "1739", um(23, 50), vor + nach, mit_diesem=True, text=A): fehler.append("Start 8/8 angehalten")
if not N.angehalten("Spike", "1739", um(23, 55), vor + nach, text=A): fehler.append("neunter Start nicht angehalten")
if not N.angehalten("Spike", "1739", um(3, 5, 22), vor + nach[:4], text=A): fehler.append("nach 03:00 nicht angehalten")
if N.grenze("Spike", "1739", um(2, 59, 22), vor + nach[:4], text=A)[1] != 8: fehler.append("Deckel vor 03:00 nicht 8")
if N.ausnahme("Spike", "1739", um(22, 30, 22), A): fehler.append("Ausnahme gilt in der nächsten Nacht")
if N.ausnahme("Tom", "1739", um(22, 0), A): fehler.append("Ausnahme ohne Chef")
if N.ausnahme("Spike", "1792", um(22, 0), A): fehler.append("anderer Vorgang")
if N.ausnahme("Jerry", "1739", um(22, 0), A): fehler.append("andere Rolle")
N.archiv = lambda: A
sh.nachtstarts = N
import nachtstarts as N2
N2.zeilen = lambda seit, wurzel=None: vor + nach[:4]
dt = datetime.datetime
class Uhr(dt):
    @classmethod
    def now(cls, tz=None): return um(22, 27)
N2.datetime.datetime = Uhr
if sh.nacht("Spike", {"title": "Spike – 1739: Werkzeuge Teil 10 (21.11., 22:27)"}): fehler.append("Haken hält 4/8 an")
if sh.nacht("Spike", {"title": "Spike – 1784 A, 1739: Teil 10 (21.11., 22:27)"}): fehler.append("Haken: zweite Nummer im Titel")
N2.zeilen = lambda seit, wurzel=None: vor + nach + ["- 23:58 21.11.: Startsperre 23:58 Start Spike (1739)"]
Uhr.now = classmethod(lambda cls, tz=None: um(23, 58))
f = sh.nacht("Spike", {"title": "Spike – 1739: Teil 14 (21.11., 23:58)"})
if not f or "1792" not in f or "8 von 8" not in f: fehler.append("Haken nach Deckel: %r" % f)
N2.datetime.datetime = dt
print("nachtstarts_test:", "grün" if not fehler else "ROT: " + "; ".join(fehler))
sys.exit(1 if fehler else 0)
