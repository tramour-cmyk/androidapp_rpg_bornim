#!/usr/bin/env python3
"""750 A (Chef 09.11., 17:46): Haken vor jedem create_session. Lässt den Start nur durch, wenn für die Rolle in den letzten
10 Minuten eine Startsperre auf main steht („Startsperre HH:MM Start <Name>“ im Protokoll von ARBEIT-BETRIEB.md, schreibt
`lauf.py --sperre`); sonst Exit 2 mit Hinweis. Anlass: Ford startete seit dem Selbstneustart 01:05 ohne lauf.py (750).

Rolle: Titel bis „ – “ („Perikles – 775: …“), sonst erstes Wort der ersten Nachricht; „Team Tom“ → Tom.
Unbekannte Rolle (Name, den das Protokoll nie führt): durchlassen, kein Projektstart. Netz weg: liest die lokale Kopie.
Notfall-Neustart durch eine Sitzung selbst (LISTE-RELEASE-NEUSTART.md Schritt 2): Zeile „- HH:MM TT.MM.: Startsperre HH:MM
Start <Name> (selbst)“ ins Protokoll, pushen, dann create_session.
Aufruf: als PreToolUse-Haken (JSON auf stdin); zum Prüfen: startsperre-haken.py --rolle NAME
"""
import datetime, json, os, re, subprocess, sys

FENSTER = datetime.timedelta(minutes=10)
ROLLEN = ("Tom", "Jerry", "Spike", "Tuffy", "Ford", "Perikles", "Homer", "Sokrates", "Diogenes")
MAIN = "/home/user/bornim-main"


def rolle_aus(eingabe):
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


def main():
    if "--rolle" in sys.argv:
        f = pruefen(sys.argv[sys.argv.index("--rolle") + 1]); print(f or "frei"); sys.exit(2 if f else 0)
    try: daten = json.load(sys.stdin)
    except Exception: sys.exit(0)
    if not str(daten.get("tool_name", "")).endswith("create_session"): sys.exit(0)
    rolle = rolle_aus(daten.get("tool_input") or {})
    if not rolle: sys.exit(0)
    f = pruefen(rolle)
    if f:
        print(f, file=sys.stderr); sys.exit(2)


if __name__ == "__main__":
    main()
