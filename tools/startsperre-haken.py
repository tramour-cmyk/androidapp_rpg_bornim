#!/usr/bin/env python3
"""750 A (Chef 09.11., 17:46): Haken vor jedem create_session. Lässt den Start nur durch, wenn für die Rolle in den letzten
10 Minuten eine Startsperre auf main steht („Startsperre HH:MM Start <Name>“ im Protokoll von ARBEIT-BETRIEB.md, schreibt
`lauf.py --sperre`); sonst Exit 2 mit Hinweis. Anlass: Ford startete seit dem Selbstneustart 01:05 ohne lauf.py (750).

Rolle: Titel bis „ – “ („Perikles – 775: …“), sonst erstes Wort der ersten Nachricht; „Team Tom“ → Tom.
Unbekannte Rolle (Name, den das Protokoll nie führt): durchlassen, kein Projektstart. Netz weg: liest die lokale Kopie.
Notfall-Neustart durch eine Sitzung selbst (LISTE-RELEASE-NEUSTART.md Schritt 2): Zeile „- HH:MM TT.MM.: Startsperre HH:MM
Start <Name> (selbst)“ ins Protokoll, pushen, dann create_session.
982 (D180.1, zu 981): bis HOCH_BIS aus lauf.py (901: Chef 11.11., 07:18, 365a B „alle Rollen mit Hoch“) hält der Haken jedes
create_session einer Rolle ohne `effort: "high"` an, gleich auf welchem Weg (START-Zeile, Neustart, Notfall, Selbstneustart Ford).
Aufruf: als PreToolUse-Haken (JSON auf stdin); zum Prüfen: startsperre-haken.py --rolle NAME [--effort WERT]
"""
import datetime, json, os, re, subprocess, sys

FENSTER = datetime.timedelta(minutes=10)
ROLLEN = ("Tom", "Jerry", "Spike", "Tuffy", "Ford", "Perikles", "Homer", "Sokrates", "Diogenes", "Rundblick")  # 1789: Routine Rundblick braucht die Startsperre wie jede Rolle
MAIN = "/home/user/bornim-main"


def rolle_aus(eingabe):
    # 1739 Rufnamen („Anna – 1739: …“): Rolle aus „Rolle <Name>“ der ersten Nachricht (lauf.mit_rufnamen), sonst Besitzer
    # des Vorgangs im Titel; sonst ginge eine Rufnamen-Sitzung ungeprüft durch
    try:
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import rufname
        if rufname.aus_titel(eingabe.get("title") or ""):
            m = re.search(r"\(Rolle (%s)\b" % "|".join(ROLLEN), eingabe.get("prompt") or "")
            b = m.group(1) if m else rufname.bereich(eingabe.get("title") or "")
            if b in ROLLEN: return b
    except Exception:
        pass
    for text in (eingabe.get("title") or "", eingabe.get("prompt") or ""):
        t = re.sub(r"^\W*(Team\s+)?", "", text.strip())
        w = re.match(r"([A-ZÄÖÜ][a-zäöüß]+)", t)
        if w and w.group(1) in ROLLEN: return w.group(1)
    return None


def protokoll():
    d = MAIN if os.path.isdir(MAIN) else os.environ.get("CLAUDE_PROJECT_DIR", ".")
    try:
        subprocess.run(["git", "-C", d, "fetch", "-q", "origin", "main"], capture_output=True, timeout=8)
        r = subprocess.run(["git", "-C", d, "show", "origin/main:docs/ARBEIT-BETRIEB.md"], capture_output=True, text=True, timeout=5)
        if r.returncode == 0: return r.stdout
    except Exception:
        pass
    try: return open(os.path.join(d, "docs", "ARBEIT-BETRIEB.md"), encoding="utf-8").read()
    except OSError: return ""


def letzte_sperre(text, rolle, jetzt):
    best = None
    for l in text.splitlines():
        m = re.search(r"Startsperre (\d\d):(\d\d) Start (\w+(?:, \w+)*)", l)
        if not m or rolle not in m.group(3).split(", "): continue
        k = re.match(r"- \d\d:\d\d (\d\d)\.(\d\d)\.:", l)
        try:
            d = jetzt.replace(month=int(k.group(2)), day=int(k.group(1))) if k else jetzt
            d = d.replace(hour=int(m.group(1)), minute=int(m.group(2)), second=0, microsecond=0)
        except ValueError: continue
        if not k and d > jetzt: d -= datetime.timedelta(days=1)
        if best is None or d > best: best = d
    return best


def pruefen(rolle, jetzt=None):
    jetzt = jetzt or datetime.datetime.now()
    s = letzte_sperre(protokoll(), rolle, jetzt)
    if s and jetzt - FENSTER <= s <= jetzt + datetime.timedelta(minutes=2): return None
    seit = "letzte %s" % s.strftime("%d.%m., %H:%M") if s else "keine"
    return ("Startsperre fehlt (750 A): für %s steht in den letzten 10 Minuten keine „Startsperre … Start %s“ auf main (%s). "
            "Ford: erst `python3 tools/lauf.py --sperre --besetzung`, pushen, dann die START-Zeile übernehmen. "
            "Notfall-Neustart: Zeile „- HH:MM TT.MM.: Startsperre HH:MM Start %s (selbst)“ ins Protokoll "
            "von ARBEIT-BETRIEB.md, pushen, dann create_session." % (rolle, rolle, seit, rolle))


def hoch_bis():
    """982: Stichtag aus lauf.py (ein Ort); ohne lesbare Zeile None (dann keine Prüfung)."""
    try: t = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "lauf.py"), encoding="utf-8").read()
    except OSError: return None
    m = re.search(r"^HOCH_BIS = datetime\.datetime\((\d+), (\d+), (\d+), (\d+), (\d+)", t, re.M)
    if not m: return None
    import zoneinfo
    return datetime.datetime(*map(int, m.groups()), tzinfo=zoneinfo.ZoneInfo("Europe/Berlin"))


def aufwand(rolle, effort, jetzt=None):
    b = hoch_bis()
    import zoneinfo
    jetzt = jetzt or datetime.datetime.now(zoneinfo.ZoneInfo("Europe/Berlin"))
    if b is None or jetzt >= b or effort == "high": return None
    return ("Aufwand fehlt (982): bis %s starten alle Rollen mit Aufwand hoch (901, 365a B); create_session für %s mit "
            "`effort: \"high\"` wiederholen (START-Zeile: Feld „effort high“, LISTE-BETRIEB.md Startzuordnung)." % (b.strftime("%d.%m., %H:%M"), rolle))


def nacht(rolle, eingabe):
    """1643 (340.12/3): derselbe Vorgang (Nummer im Titel „<Rolle> – <Nr>…“) nach zwei Neustarts in einer Nacht angehalten."""
    titel = eingabe.get("title") or ""
    m = re.search(r"–\s*(?:[^\W\d][\w-]*\s+)?(\d[0-9a-zA-Z.]*[0-9a-zA-Z]|\d)", titel)
    if not m: return None
    nr = m.group(1)
    try:
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import nachtstarts
        # 1792: steht im Titel vor dem Doppelpunkt eine weitere Nummer mit Ausnahme des Chefs (etwa „1792, 1739: …“), gilt deren Deckel
        kopf = titel[m.start():].split(":")[0]
        for n in re.findall(r"(?<![\w.])(\d[0-9a-zA-Z.]*[0-9a-zA-Z]|\d)(?![\w])", kopf):
            if nachtstarts.ausnahme(rolle, n):
                nr = n; break
        if not nachtstarts.angehalten(rolle, nr, mit_diesem=True): return None
        z, g, a = nachtstarts.grenze(rolle, nr)
    except Exception:
        return None
    if a:
        return ("Nachtstopp (1792): %s auf Vorgang %s hat den Deckel aus %s erreicht (%d von %d Starts); nicht starten bis 7 Uhr. "
                "Ford: Zeile „- HH:MM TT.MM.: Morgen 1643: %s %s Deckel %s erreicht“ ins Protokoll, pushen." % (rolle, nr, a["quelle"], z - 1, g, rolle, nr, a["quelle"]))
    return ("Nachtstopp (1643): %s auf Vorgang %s ist in dieser Nacht schon nach zwei Neustarts; nicht starten bis 7 Uhr. "
            "Ford: Zeile „- HH:MM TT.MM.: Morgen 1643: %s %s nach zwei Neustarts in der Nacht angehalten, Ursache ansehen“ ins Protokoll, pushen." % (rolle, nr, rolle, nr))


def main():
    if "--rolle" in sys.argv:
        r = sys.argv[sys.argv.index("--rolle") + 1]
        e = sys.argv[sys.argv.index("--effort") + 1] if "--effort" in sys.argv else None
        f = pruefen(r) or aufwand(r, e); print(f or "frei"); sys.exit(2 if f else 0)
    try: daten = json.load(sys.stdin)
    except Exception: sys.exit(0)
    if not str(daten.get("tool_name", "")).endswith("create_session"): sys.exit(0)
    rolle = rolle_aus(daten.get("tool_input") or {})
    if not rolle: sys.exit(0)
    f = aufwand(rolle, (daten.get("tool_input") or {}).get("effort")) or pruefen(rolle)
    f = f or nacht(rolle, daten.get("tool_input") or {})
    if f:
        print(f, file=sys.stderr)
        try:  # 1129.1 P3: jeder Halt wird gezählt (Zweig „haken“)
            sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); import hakenzahl; hakenzahl.vermerk("startsperre", f)
        except Exception:
            pass
        sys.exit(2)


if __name__ == "__main__":
    main()
