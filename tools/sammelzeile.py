#!/usr/bin/env python3
"""1971 (Chef 22.11., 18:27 „Fertigmeldung … Statusreport“, 18:28 „stündlich, umsetzen“; Eilt 23.11., 09:11): lautlose
Telegram-Sammelzeile je Stunde, nur Vorgänge, die im Fenster in docs/LISTE-VORGAENGE.md auf „erledigt“ gingen (git-Verlauf, auch
wenn lauf.py --aufraeumen die Zeile danach ins Archiv schob); je Zeile „✓ <Nr> <Titel kurz>: erledigt“. Nichts bei Übergaben,
Starts, Planern. Läuft ohne Token als GitHub-Lauf (sammelzeile.yml, angestoßen von herzschlag-kette.yml).

Aufruf: python3 tools/sammelzeile.py VON BIS     (ISO-Zeiten, Fenster VON ≤ Commit < BIS); gibt den Meldetext aus, leer = nichts senden
        python3 tools/sammelzeile.py --fenster [LETZTES_BIS]   gibt „VON BIS“ aus: von LETZTES_BIS (sonst volle Stunde davor) bis zur vollen Stunde jetzt
"""
import datetime as dt, os, re, subprocess, sys
from zoneinfo import ZoneInfo
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startbar

BERLIN = ZoneInfo("Europe/Berlin")
LISTE = "docs/LISTE-VORGAENGE.md"
WURZEL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def _git(wurzel, *a):
    r = subprocess.run(["git", "-C", wurzel] + list(a), capture_output=True, text=True)
    return r.stdout if r.returncode == 0 else None

def _worte(wurzel, rev):
    t = _git(wurzel, "show", "%s:%s" % (rev, LISTE))
    return {d["nr"]: (d.get("titel", ""), d["wort"]) for d in startbar.vorgangsliste(t)} if t else {}

def erledigt(wurzel, von, bis):
    """[(Nr, Titel)] der Vorgänge, deren Stand in einem Commit mit VON ≤ Zeit < BIS von etwas anderem auf „erledigt“ ging."""
    v, b = dt.datetime.fromisoformat(von), dt.datetime.fromisoformat(bis)
    log = _git(wurzel, "log", "--reverse", "--format=%H %cI", "--since=" + von, "--until=" + bis, "--", LISTE) or ""
    aus, gesehen = [], set()
    for z in log.split("\n"):
        if not z.strip(): continue
        h, t = z.split(" ", 1)
        if not v <= dt.datetime.fromisoformat(t) < b: continue
        alt, neu = _worte(wurzel, h + "^"), _worte(wurzel, h)
        for nr, (titel, w) in neu.items():
            if w == "erledigt" and nr in alt and alt[nr][1] != "erledigt" and nr not in gesehen:
                gesehen.add(nr); aus.append((nr, titel))
    return aus

def kurz(titel):
    t = re.split(r":\s|\s\(|;", titel, maxsplit=1)[0].strip()  # „01:12“ trennt nicht
    return t if len(t) <= 60 else t[:59].rstrip() + "…"

def text(zs, uhr):
    if not zs: return ""
    return "Erledigt bis %s (Status, keine Frage; 1971)\n%s" % (uhr, "\n".join("✓ %s %s: erledigt" % (nr, kurz(t)) for nr, t in zs))

def fenster(letztes=None, jetzt=None):
    j = (jetzt or dt.datetime.now(BERLIN)).replace(minute=0, second=0, microsecond=0)
    v = dt.datetime.fromisoformat(letztes) if letztes else j - dt.timedelta(hours=1)
    if v > j or j - v > dt.timedelta(hours=24): v = j - dt.timedelta(hours=1)  # Schutz: nie Zukunft, höchstens ein Tag nach
    return v.isoformat(), j.isoformat()

if __name__ == "__main__":
    a = sys.argv[1:]
    if a and a[0] == "--fenster" and len(a) <= 2:
        print(" ".join(fenster(a[1] if len(a) == 2 and a[1] else None))); sys.exit(0)
    if len(a) != 2: print(__doc__); sys.exit(2)
    t = text(erledigt(WURZEL, a[0], a[1]), dt.datetime.fromisoformat(a[1]).astimezone(BERLIN).strftime("%d.%m., %H:%M"))
    if t: print(t)
