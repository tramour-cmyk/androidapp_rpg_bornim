# 1313 (Sokrates 15.11., 20:05): Prüfpunkte des Überblicks. Aufruf: python3 tools/ueberblick_test.py
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import ueberblick as u

fehl = 0
def soll(name, ist, erwartet):
    global fehl; ok = ist == erwartet; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ist)

zs, kommt, test, pruef, gebaut = u.rechnen()
erste = [d for _, d, _ in kommt[:u.ANZAHL]]
soll("kein „gebaut“ in den 20", [d["nr"] for d in erste if d["wort"] == "gebaut"], [])
soll("nichts zum Testen in den 20", [d["nr"] for d in erste if u.wartet_auf_test(d)], [])
gruende = [g for _, _, g in kommt]
soll("Wartendes erst nach allem Startbaren", all(g is None for g in gruende[:gruende.index(next((g for g in gruende if g), None))]) if any(gruende) else True, True)

# Probe: die letzte startbare Zeile vorziehen („jetzt“), dann steht sie vorn
ziel = next((d for _, d, g in reversed(kommt) if g is None), None)
alt = u.s.zeilen_liste
liste = alt()
for d in liste:
    if ziel and d["nr"] == ziel["nr"]: d["titel"] += " · „jetzt“ " + __import__("datetime").datetime.now().strftime("%d.%m., %H:%M"); d["kl"] = "M"  # „jetzt“ ist immer Muss (CLAUDE.md)
u.s.zeilen_liste = lambda: liste
_, kommt2, *_ = u.rechnen()
u.s.zeilen_liste = alt
soll("vorgezogen (%s) steht auf Rang 1" % (ziel or {}).get("nr"), kommt2[0][1]["nr"] if ziel else None, ziel["nr"] if ziel else None)
# 1440: Blocknummern fest und eindeutig, Übriges nicht doppelt
nums = [r["num"] for _, r in u.BLOECKE] + [u.UEBRIG_NUM]
soll("Blocknummern eindeutig", len(nums) == len(set(nums)), True)
soll("Blocknummer im Überblick", "**%d** %s" % (u.nummer(0), u.name(0)) in u.md(), True)

# 1495: Kalendertage bis 24 Uhr; gestern + heute = seit 0:00 gestern (neu genau, Gegenrechnung Sokrates)
import datetime, zoneinfo, startbar as s
n0 = datetime.datetime.now(zoneinfo.ZoneInfo("Europe/Berlin")).replace(hour=0, minute=0, second=0, microsecond=0)
cm = lambda t: s._git("rev-list", "-1", "--before=" + t.isoformat(), "HEAD").stdout.strip() or None
g, h, x = u._stand(cm(n0 - datetime.timedelta(days=1))), u._stand(cm(n0)), u._stand(None)
if g and h:
    soll("neu: gestern + heute = seit gestern", u._bilanz(g, h)[1] + u._bilanz(h, x)[1], u._bilanz(g, x)[1])
mo = u.morgen()
soll("Zeile heute, gestern, Woche, Monat", mo is not None and all(k in mo[1] for k in ("heute", "gestern", "Woche", "Monat")), True)
# 1592: „in Arbeit“ aus der Besetzung (Vorgang je Sitzung), Betrieb und Kopfzeilen zählen nicht
probe = "| Rolle | Sitzung | Vorgang | Zweig | seit |\n|---|---|---|---|---|\n| Tom | [x](u) | 297.11 | – | 17.11. |\n| Ford | [f](u) | Betrieb | – | 17.11. |\n| Jerry | [j](u) | 1561 | claude/jerry-1 | 17.11. |"
soll("Besetzung gelesen", sorted(u.besetzt(probe)), ["1561", "297.11"])
soll("in Arbeit zählt Besetzung", u.in_arbeit({"wort": "startbar", "nr": "1561"}, {"1561"}), True)
soll("gebaut zählt nicht als in Arbeit", u.in_arbeit({"wort": "gebaut", "nr": "1561"}, {"1561"}), False)
soll("Stand in den 20 aus Besetzung", u.kurzstand({"wort": "startbar", "nr": "1561", "stand": ""}, None, {"1561"}), "in Arbeit")
sys.exit(1 if fehl else 0)
