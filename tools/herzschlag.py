#!/usr/bin/env python3
"""1764 Herzschlag (Lücke L-T1, ablauf.md A18): lief `lauf.py` in den letzten 2 Stunden?

Zeitmarke ist die Zeile „**Stand:** TT.MM., HH:MM (lauf.py)“ in docs/ARBEIT-BESETZUNG.md; `lauf.py --besetzung` erneuert sie
spätestens nach 60 Minuten, auch wenn sich die Tabelle nicht ändert. Läuft ohne Token als GitHub-Lauf (`herzschlag.yml`).

Aufruf: python3 tools/herzschlag.py [--datei PFAD] [--jetzt "TT.MM.JJJJ HH:MM"] | --test
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
    return 2, "ALARM Herzschlag: lauf.py lief seit %s nicht mehr (%d Std. %d Min.); Ford hängt oder fehlt, keine Starts. Ford neu starten (1764)" % (zeit, alter // 60, alter % 60)


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
    rc, z = pruefen(text, jetzt)
    print(z)
    return rc


if __name__ == "__main__":
    sys.exit(haupt(sys.argv[1:]))
