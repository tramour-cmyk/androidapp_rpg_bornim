#!/usr/bin/env python3
"""1643 (340.12 Änderung 3, Chef 18.11., 09:45): derselbe Vorgang wird nach zwei Neustarts in einer Nacht angehalten und steht als
Zeile für den Morgen (Muster 3: Nachtschleife Ford 1610 bis 1618, sechs Neustarts, gut 20 $).

Nacht = 21 bis 7 Uhr Berliner Zeit (wie „21 bis 7 Uhr nur Technik“). Gezählt werden die Startsperren der Nacht aus dem Verlauf von
ARBEIT-BETRIEB.md auf origin/main (auch die schon aufgeräumten): Zeilen „Startsperre HH:MM Start <Rolle>[, …] (…<Nr>…)“, die den
Vorgang als eigene Zahl nennen; `lauf.py --sperre` schreibt die Nummer seit 1643 hinein („(lauf.py, 1642)“), Ford bei Neustarts
von Hand „(Neustart <Commit>, <Nr>)“. Erster Start + zwei Neustarts = 3; ein vierter wird angehalten.

1792 (1784 A, Chef 21.11., 21:54): Ausnahme mit Deckel aus dem Entscheid im Vorgangsarchiv (ein Ort, keine Abschrift). Gilt eine
Zeile „- **<Nr>, …** (TT.MM., HH:MM, Chef …) → **… höchstens <Zahl> [weitere] <Rolle>-Starts an <Vorgang>[, spätestens HH:MM] …**“
(Zahl als Ziffer oder Wort bis zwölf), dann in der Nacht des Entscheids statt GRENZE der Deckel: gezählt ab der Entscheidzeit
(„weitere“) bzw. ab 21 Uhr, nach „spätestens“ wieder die Regel. Ohne Chef in der Klammer keine Ausnahme.

  nachtstarts.py ROLLE NR    Zahl der Starts dieser Nacht und geltende Grenze (Prüfen von Hand)
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
    return len(_zeiten(rolle, nr, jetzt, protokoll if protokoll is not None else zeilen(beginn)))


ZAHLWORT = {w: i + 1 for i, w in enumerate("eins zwei drei vier fünf sechs sieben acht neun zehn elf zwölf".split())}
ZAHLWORT.update(ein=1, einen=1, eine=1)


def archiv():
    """Vorgangsarchiv von origin/main, sonst die lokale Kopie."""
    d = MAIN if os.path.isdir(MAIN) else os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    try:
        r = subprocess.run(["git", "-C", d, "show", "origin/main:docs/VORGANGSARCHIV.md"], capture_output=True, text=True, timeout=10)
        if r.returncode == 0: return r.stdout
    except Exception:
        pass
    try: return open(os.path.join(d, "docs", "VORGANGSARCHIV.md"), encoding="utf-8").read()
    except OSError: return ""


def ausnahmen(text, jahr):
    """Entscheide des Chefs mit Deckel: Liste von dict(rolle, nr, deckel, ab, bis, quelle)."""
    aus = []
    for l in text.splitlines():
        if "Starts an" not in l: continue
        k = re.search(r"\((\d\d)\.(\d\d)\., (\d\d):(\d\d), Chef\b", l)
        m = re.search(r"höchstens (\w+) (weitere )?(\w+)-Starts an (\d[0-9a-zA-Z.]*[0-9a-zA-Z]|\d)(?:, spätestens (\d\d):(\d\d))?", l)
        if not k or not m: continue
        z = m.group(1).lower()
        deckel = int(z) if z.isdigit() else ZAHLWORT.get(z)
        if not deckel: continue
        try:
            t = datetime.datetime(jahr, int(k.group(2)), int(k.group(1)), int(k.group(3)), int(k.group(4)), tzinfo=BERLIN)
        except ValueError:
            continue
        beginn = nachtbeginn(t)
        if beginn is None: continue  # Entscheid am Tag nennt keine Nacht
        ende = beginn + datetime.timedelta(hours=10)
        if m.group(5):
            b = beginn.replace(hour=int(m.group(5)), minute=int(m.group(6)))
            if b < beginn: b += datetime.timedelta(days=1)
            ende = min(ende, b)
        q = re.match(r"- \*\*([^,*]+)", l)
        aus.append(dict(rolle=m.group(3), nr=m.group(4), deckel=deckel, ab=t if m.group(2) else beginn, bis=ende,
                        quelle=q.group(1) if q else "?"))
    return aus


def ausnahme(rolle, nr, jetzt=None, text=None):
    """Geltende Ausnahme für Rolle und Vorgang jetzt, sonst None."""
    jetzt = jetzt or datetime.datetime.now(BERLIN)
    for a in ausnahmen(archiv() if text is None else text, jetzt.year):
        if a["rolle"] == rolle and a["nr"] == str(nr) and a["ab"] - datetime.timedelta(minutes=5) <= jetzt <= a["bis"]:
            return a
    return None


def grenze(rolle, nr, jetzt=None, protokoll=None, text=None):
    """(Zahl der Starts, Grenze, Ausnahme oder None) für diese Nacht."""
    jetzt = jetzt or datetime.datetime.now(BERLIN)
    a = ausnahme(rolle, nr, jetzt, text) if nachtbeginn(jetzt) else None
    if not a:
        return zaehlen(rolle, nr, jetzt, protokoll), GRENZE, None
    p = protokoll if protokoll is not None else zeilen(nachtbeginn(jetzt))
    # nur Starts ab der Entscheidzeit zählen: Zeitmarke je Zeile prüfen wie zaehlen, mit späterem Beginn
    n = sum(1 for t in _zeiten(rolle, nr, jetzt, p) if t >= a["ab"])
    return n, a["deckel"], a


def _zeiten(rolle, nr, jetzt, p):
    beginn = nachtbeginn(jetzt)
    gesehen = set()
    for l in p:
        m = re.search(r"Startsperre (\d\d):(\d\d) Start (\w+(?:, \w+)*)(.*)", l)
        if not m or rolle not in m.group(3).split(", "): continue
        if not re.search(r"(?<![\w.])%s(?![\w]|\.\d)" % re.escape(nr), m.group(4)): continue
        k = re.match(r"- \d\d:\d\d (\d\d)\.(\d\d)\.:", l)
        try:
            t = jetzt.replace(day=int(k.group(1)), month=int(k.group(2))) if k else jetzt
            t = t.replace(hour=int(m.group(1)), minute=int(m.group(2)), second=0, microsecond=0)
        except ValueError:
            continue
        if not k and t > jetzt: t -= datetime.timedelta(days=1)
        if beginn <= t <= jetzt + datetime.timedelta(minutes=5): gesehen.add(t)
    return gesehen


def angehalten(rolle, nr, jetzt=None, protokoll=None, mit_diesem=False, text=None):
    """True, wenn ein weiterer Start die Grenze überschreitet; mit_diesem: die Sperre des aktuellen Starts steht schon im Protokoll.
    1792: Grenze aus einer Ausnahme des Chefs, wenn eine gilt (`text`: Archiv statt Git, Test)."""
    n, g, _ = grenze(rolle, nr, jetzt, protokoll, text)
    return n > g if mit_diesem else n >= g


if __name__ == "__main__":
    if len(sys.argv) == 3:
        n, g, a = grenze(sys.argv[1], sys.argv[2])
        print("%d von %d%s" % (n, g, " (Ausnahme %s bis %s)" % (a["quelle"], a["bis"].strftime("%d.%m., %H:%M")) if a else ""))
