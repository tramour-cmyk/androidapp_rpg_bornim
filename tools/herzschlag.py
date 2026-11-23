#!/usr/bin/env python3
"""1764 Herzschlag (Lücke L-T1, ablauf.md A18): lief `lauf.py` in den letzten 2 Stunden?

Zeitmarke ist die Zeile „**Stand:** TT.MM., HH:MM (lauf.py)“ in docs/ARBEIT-BESETZUNG.md; jeder vollständige Lauf von `lauf.py`
erneuert sie am Ende und pusht sie selbst, ohne Schalter (1997). Läuft ohne Token als GitHub-Lauf (`herzschlag.yml`).

Aufruf: python3 tools/herzschlag.py [--datei PFAD] [--jetzt "TT.MM.JJJJ HH:MM"] | --test
        python3 tools/herzschlag.py --wache [--geweckt "TT.MM.JJJJ HH:MM"] [--datei PFAD] [--jetzt …]   (1997 B, für die Wache; schreibt nichts)
  WACHE ok                  Herzschlag lebt
  WACHE WECKEN Disponent    ALARM (oder Marke fehlt), nicht oder vor diesem Ausfall geweckt → Disponent wecken, Zeit merken (Exit 2)
  WACHE WARTEN Disponent    geweckt vor unter 60 Min., Marke seither gleich → nichts tun, Weckzeit behalten (Exit 2)
  WACHE NEUSTART Disponent  geweckt vor 60 Min. oder mehr, Marke seither gleich → Starter „Disponent-Neustart“, laut an den Chef (Exit 3)
Ausgabe eine Zeile; Exit 0 = lebt, 2 = ALARM (über 2 h; einmal je Ausfall meldet herzschlag.yml über den Cache-Schlüssel
`--marke`), 1 = Zeitmarke fehlt."""
import datetime as dt, os, re, sys
from zoneinfo import ZoneInfo

BERLIN = ZoneInfo("Europe/Berlin")
GRENZE_MIN = 120
WURZEL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def marke(text, jetzt):
    """Zeitpunkt der Stand-Zeile (Berliner Zeit, Jahr so, dass er nicht in der Zukunft liegt) oder None."""
    m = re.search(r"\*\*Stand:\*\* (\d\d?)\.(\d\d?)\., (\d\d?):(\d\d) \(lauf\.py\)", text)
    if not m: return None
    t, mo, h, mi = map(int, m.groups())
    for jahr in (jetzt.year, jetzt.year - 1):
        try: d = dt.datetime(jahr, mo, t, h, mi, tzinfo=BERLIN)
        except ValueError: continue
        if d <= jetzt + dt.timedelta(minutes=5): return d
    return None


def pruefen(text, jetzt):
    """(Exit, Zeile)."""
    d = marke(text, jetzt)
    if d is None: return 1, "HERZSCHLAG unbekannt: keine Zeile „**Stand:** … (lauf.py)“ in ARBEIT-BESETZUNG.md"
    alter = int((jetzt - d).total_seconds() // 60)
    zeit = d.strftime("%d.%m., %H:%M")
    if alter < GRENZE_MIN: return 0, "HERZSCHLAG ok: lauf.py zuletzt %s (vor %d Min.)" % (zeit, alter)
    return 2, "ALARM Herzschlag: lauf.py lief seit %s nicht mehr (%d Std. %d Min.); Disponent hängt oder fehlt, keine Starts. Disponent neu starten (1764, 1978)" % (zeit, alter // 60, alter % 60)


NEUSTART_MIN = 60  # 1997 B: ein Wachtakt (Uhr „Wache“ stündlich :33)


def wache(text, jetzt, geweckt=None):
    """1997 B: (Exit, Zeile) für die Wache; geweckt = Zeit, zu der die Wache den Disponenten wegen dieses Ausfalls geweckt hat."""
    rc, z = pruefen(text, jetzt)
    if rc == 0: return 0, "WACHE ok: " + z
    d = marke(text, jetzt)
    if geweckt is not None and (d is None or d <= geweckt):  # seit dem Wecken kein Lauf
        n = int((jetzt - geweckt).total_seconds() // 60)
        if n >= NEUSTART_MIN:
            return 3, "WACHE NEUSTART Disponent: geweckt %s (vor %d Min.), Marke gleich; dem Starter „Disponent-Neustart“ senden, `meldung.sh --laut` an den Chef (1997). %s" % (geweckt.strftime("%d.%m., %H:%M"), n, z)
        return 2, "WACHE WARTEN Disponent: geweckt %s (vor %d Min.), Neustart ab %s; nichts tun, Weckzeit behalten (1997)" % (geweckt.strftime("%d.%m., %H:%M"), n, (geweckt + dt.timedelta(minutes=NEUSTART_MIN)).strftime("%H:%M"))
    return 2, "WACHE WECKEN Disponent: send_message „Herzschlag-Alarm: tools/lauf.py ausführen“, Weckzeit %s merken (1997). %s" % (jetzt.strftime("%d.%m.%Y %H:%M"), z)


def test():
    j = dt.datetime(2026, 11, 21, 20, 48, tzinfo=BERLIN)
    f = 0
    for text, jetzt, soll in [
        ("**Stand:** 21.11., 20:06 (lauf.py)", j, 0),
        ("**Stand:** 21.11., 18:40 (lauf.py)", j, 2),
        ("**Stand:** 21.11., 17:40 (lauf.py)", j, 2),
        ("kein Stand", j, 1),
        ("**Stand:** 31.12., 23:30 (lauf.py)", dt.datetime(2027, 1, 1, 0, 10, tzinfo=BERLIN), 0),
        ("**Stand:** 31.12., 21:30 (lauf.py)", dt.datetime(2027, 1, 1, 0, 10, tzinfo=BERLIN), 2),
    ]:
        rc, z = pruefen(text, jetzt)
        ok = rc == soll; f += not ok
        print(("ok  " if ok else "FEHL"), text, "→", rc, z)
    a = pruefen("**Stand:** 21.11., 17:40 (lauf.py)", j)[1]  # 1978: Alarm nennt die Rolle, die lauf.py ausführt
    b = "Disponent hängt oder fehlt" in a and "Disponent neu starten" in a and "Ford" not in a
    f += not b; print(("ok  " if b else "FEHL"), "1978: Alarm nennt Disponent, nicht Ford →", a)
    # 1894: Kette unabhängig von Ford (herzschlag-kette.yml stößt Herzschlag und sich selbst an; herzschlag.yml startet sie neu)
    wf = os.path.join(WURZEL, ".github", "workflows")
    try: k = open(os.path.join(wf, "herzschlag-kette.yml"), encoding="utf-8").read(); h = open(os.path.join(wf, "herzschlag.yml"), encoding="utf-8").read()
    except OSError: k = h = ""
    for was, b in [("1894: Kette stößt Herzschlag an", "gh workflow run herzschlag.yml" in k),
                   ("1894: Kette stößt sich nach Wartezeit unter 60 Min. selbst an", re.search(r"sleep (\d+)\n\s*gh workflow run herzschlag-kette.yml", k) is not None
                    and int(re.search(r"sleep (\d+)", k).group(1)) < 3600),
                   ("1894: Kette nur mit workflow_dispatch, eigene Gruppe ohne Abbruch", "workflow_dispatch" in k and "group: herzschlag-kette" in k and "cancel-in-progress: false" in k and "actions: write" in k),
                   ("1894: herzschlag.yml startet fehlende Kette", "gh workflow run herzschlag-kette.yml" in h and "--workflow herzschlag-kette.yml" in h)]:
        f += not b; print(("ok  " if b else "FEHL"), was)
    # 1997 B: Wache-Fälle (ok, WECKEN, NEUSTART); Marke über 2 h ist kein ok
    W = dt.datetime(2026, 11, 23, 14, 0, tzinfo=BERLIN)
    g = lambda s: dt.datetime.strptime(s, "%d.%m.%Y %H:%M").replace(tzinfo=BERLIN)
    for text, geweckt, soll in [
        ("**Stand:** 23.11., 13:50 (lauf.py)", None, "WACHE ok"),
        ("**Stand:** 23.11., 11:50 (lauf.py)", None, "WACHE WECKEN Disponent"),  # Marke 2 h 10 alt: erst rot
        ("**Stand:** 23.11., 10:12 (lauf.py)", None, "WACHE WECKEN Disponent"),
        ("kein Stand", None, "WACHE WECKEN Disponent"),
        ("**Stand:** 23.11., 10:12 (lauf.py)", g("23.11.2026 12:59"), "WACHE NEUSTART Disponent"),  # geweckt vor 61 Min., Marke gleich
        ("**Stand:** 23.11., 10:12 (lauf.py)", g("23.11.2026 13:00"), "WACHE NEUSTART Disponent"),  # genau 60 Min.
        ("**Stand:** 23.11., 10:12 (lauf.py)", g("23.11.2026 13:34"), "WACHE WARTEN Disponent"),  # geweckt vor 26 Min.: nicht nochmal wecken
        ("**Stand:** 23.11., 11:30 (lauf.py)", g("23.11.2026 09:00"), "WACHE WECKEN Disponent"),  # Wecken vom früheren Ausfall zählt nicht
        ("**Stand:** 23.11., 13:10 (lauf.py)", g("23.11.2026 12:30"), "WACHE ok"),  # nach dem Wecken lief lauf.py
    ]:
        rc, z = wache(text, W, geweckt)
        ok = z.startswith(soll); f += not ok
        print(("ok  " if ok else "FEHL"), "1997 Wache:", text, geweckt and geweckt.strftime("%H:%M"), "→", rc, z)
    print("herzschlag --test: %s" % ("alles grün" if not f else "%d FEHL" % f))
    return 1 if f else 0


def haupt(a):
    if "--test" in a: return test()
    if "--marke" in a:  # für den Cache-Schlüssel in herzschlag.yml: ein Alarm je Zeitmarke
        try: m = re.search(r"\*\*Stand:\*\* ([^(\n]*) \(lauf\.py\)", open(os.path.join(WURZEL, "docs", "ARBEIT-BESETZUNG.md"), encoding="utf-8").read())
        except OSError: m = None
        print(re.sub(r"\W+", "-", m.group(1)).strip("-") if m else "keine"); return 0
    p = os.path.join(WURZEL, "docs", "ARBEIT-BESETZUNG.md")
    if "--datei" in a: p = a[a.index("--datei") + 1]
    jetzt = dt.datetime.now(BERLIN)
    if "--jetzt" in a: jetzt = dt.datetime.strptime(a[a.index("--jetzt") + 1], "%d.%m.%Y %H:%M").replace(tzinfo=BERLIN)
    try: text = open(p, encoding="utf-8").read()
    except OSError: text = ""
    if "--wache" in a:
        geweckt = None
        if "--geweckt" in a: geweckt = dt.datetime.strptime(a[a.index("--geweckt") + 1], "%d.%m.%Y %H:%M").replace(tzinfo=BERLIN)
        rc, z = wache(text, jetzt, geweckt)
        print(z); return rc
    rc, z = pruefen(text, jetzt)
    print(z)
    return rc


if __name__ == "__main__":
    sys.exit(haupt(sys.argv[1:]))
