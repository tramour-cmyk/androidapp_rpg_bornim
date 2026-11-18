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
print("nachtstarts_test:", "grün" if not fehler else "ROT: " + "; ".join(fehler))
sys.exit(1 if fehler else 0)
