#!/usr/bin/env python3
"""1643 (340.12 Änderung 3, Chef 18.11., 09:45): derselbe Vorgang wird nach zwei Neustarts in einer Nacht angehalten und steht als
Zeile für den Morgen (Muster 3: Nachtschleife Ford 1610 bis 1618, sechs Neustarts, gut 20 $).

Nacht = 21 bis 7 Uhr Berliner Zeit (wie „21 bis 7 Uhr nur Technik“). Gezählt werden die Startsperren der Nacht aus dem Verlauf von
ARBEIT-BETRIEB.md auf origin/main (auch die schon aufgeräumten): Zeilen „Startsperre HH:MM Start <Rolle>[, …] (…<Nr>…)“, die den
Vorgang als eigene Zahl nennen; `lauf.py --sperre` schreibt die Nummer seit 1643 hinein („(lauf.py, 1642)“), Ford bei Neustarts
von Hand „(Neustart <Commit>, <Nr>)“. Erster Start + zwei Neustarts = 3; ein vierter wird angehalten.

  nachtstarts.py ROLLE NR    Zahl der Starts dieser Nacht (Prüfen von Hand)
"""
import datetime, os, re, subprocess, sys, zoneinfo

BERLIN = zoneinfo.ZoneInfo("Europe/Berlin")
GRENZE = 3  # Start + zwei Neustarts; danach angehalten
MAIN = "/home/user/bornim-main"


def nachtbeginn(jetzt):
    """Beginn der laufenden Nacht (21 Uhr) oder None am Tag (7 bis 21 Uhr)."""
    if jetzt.hour >= 21:
        return jetzt.replace(hour=21, minute=0, second=0, microsecond=0)
    if jetzt.hour < 7:
        return (jetzt - datetime.timedelta(days=1)).replace(hour=21, minute=0, second=0, microsecond=0)
    return None


def zeilen(seit, wurzel=None):
    """Hinzugekommene Protokollzeilen mit Startsperre seit `seit` (Verlauf von origin/main)."""
    d = wurzel or (MAIN if os.path.isdir(MAIN) else os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    try:
        r = subprocess.run(["git", "-C", d, "log", "--since=" + seit.isoformat(), "-p", "--format=", "origin/main", "--",
                            "docs/ARBEIT-BETRIEB.md"], capture_output=True, text=True, timeout=20)
        return [l[1:] for l in r.stdout.splitlines() if l.startswith("+") and "Startsperre" in l]
    except Exception:
        return []


def zaehlen(rolle, nr, jetzt=None, protokoll=None):
    """Zahl der Starts von `rolle` auf Vorgang `nr` in dieser Nacht; am Tag 0. `protokoll`: Zeilen statt Git (Test)."""
    jetzt = jetzt or datetime.datetime.now(BERLIN)
    beginn = nachtbeginn(jetzt)
    if beginn is None or not nr:
        return 0
    gesehen = set()
    for l in (protokoll if protokoll is not None else zeilen(beginn)):
        m = re.search(r"Startsperre (\d\d):(\d\d) Start (\w+(?:, \w+)*)(.*)", l)
        if not m or rolle not in m.group(3).split(", "):
            continue
        if not re.search(r"(?<![\w.])%s(?![\w]|\.\d)" % re.escape(nr), m.group(4)):
            continue
        k = re.match(r"- \d\d:\d\d (\d\d)\.(\d\d)\.:", l)
        try:
            t = jetzt.replace(day=int(k.group(1)), month=int(k.group(2))) if k else jetzt
            t = t.replace(hour=int(m.group(1)), minute=int(m.group(2)), second=0, microsecond=0)
        except ValueError:
            continue
        if not k and t > jetzt: t -= datetime.timedelta(days=1)
        if beginn <= t <= jetzt + datetime.timedelta(minutes=5):
            gesehen.add(t)
    return len(gesehen)


def angehalten(rolle, nr, jetzt=None, protokoll=None, mit_diesem=False):
    """True, wenn ein weiterer Start die Grenze überschreitet; mit_diesem: die Sperre des aktuellen Starts steht schon im Protokoll."""
    n = zaehlen(rolle, nr, jetzt, protokoll)
    return n > GRENZE if mit_diesem else n >= GRENZE


if __name__ == "__main__":
    if len(sys.argv) == 3:
        print(zaehlen(sys.argv[1], sys.argv[2]))
