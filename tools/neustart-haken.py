#!/usr/bin/env python3
"""Neustart-Haken (Thema 14). Läuft über .claude/settings.json und tut bei jedem Fehler still nichts.

  neustart-haken.py prompt   bei jeder Nachricht des Nutzers (UserPromptSubmit): misst, wie stark das Gespräch
                             seit dem Start gewachsen ist, und erinnert ab der Schwelle an einen Neustart,
                             erst selten, dann immer öfter, je länger der Nutzer weiterarbeitet.
  neustart-haken.py start    beim Sitzungsstart (SessionStart): warnt, wenn ein Vorrat docs/ARBEIT-*.md zu groß ist.

Die Größe kommt aus dem Gesprächsprotokoll (transcript_path): Token der letzten Antwort (Eingabe, auch
zwischengespeichert). Gemessen wird der Zuwachs gegenüber der ersten Antwort, weil schon der Start je nach
Umgebung viel Platz braucht. Nach einem Verdichten (Kontext schrumpft deutlich) zählt der neue Stand als Start.

Schwellen über Umgebungsvariablen änderbar: BORNIM_NEUSTART_AB (Zuwachs in Token, Vorgabe 100000),
BORNIM_OFFEN_MAX (Bytes, Vorgabe 15000). Zustand je Sitzung in /tmp/bornim-neustart-<Sitzung>.json.
Bei der 1., 11., 21. … Nachricht zusätzlich die Kernregel-Zeile aus tools/kernregeln.txt (347, ein Wortlaut, auch notiz.sh).
"""
import json
import os
import sys

KERN_ALLE = 10
AB = int(os.environ.get("BORNIM_NEUSTART_AB", "100000"))
OFFEN_MAX = int(os.environ.get("BORNIM_OFFEN_MAX", "15000"))
# Abstände in Nachrichten zwischen zwei Erinnerungen: erst 6, dann 4, 3, 2, danach bei jeder Nachricht.
ABSTAENDE = [6, 4, 3, 2, 1]


def groessen(pfad):
    """Kontextgröße jeder Antwort im Protokoll, in Reihenfolge (nur die Hauptsitzung, keine Unteragenten)."""
    werte = []
    with open(pfad, encoding="utf-8", errors="replace") as f:
        for zeile in f:
            if '"usage"' not in zeile:
                continue
            try:
                d = json.loads(zeile)
            except ValueError:
                continue
            if d.get("type") != "assistant" or d.get("isSidechain"):
                continue
            u = (d.get("message") or {}).get("usage") or {}
            t = sum(int(u.get(k) or 0) for k in ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens"))
            if t > 0:
                werte.append(t)
    return werte


def zuwachs(werte):
    """Zuwachs der letzten Antwort gegenüber dem Start bzw. dem letzten Verdichten."""
    if not werte:
        return 0, 0
    basis = werte[0]
    for vorher, jetzt in zip(werte, werte[1:]):
        if jetzt < vorher * 0.7:  # verdichtet: neuer Start
            basis = jetzt
    return werte[-1] - basis, werte[-1]


def text(stufe, plus, gesamt):
    k = lambda n: f"{round(n / 1000)} Tsd."
    kopf = f"Neustart-Haken (Thema 14): Das Gespräch ist seit dem Start um etwa {k(plus)} Token gewachsen (jetzt {k(gesamt)}, Schwelle {k(AB)}); Erinnerung Nr. {stufe}."
    # 81r: der Anlass entscheidet, nicht ein Ja des Nutzers; kein Vorschlag im Chat (D8.2: der löste den Chefsache-Haken aus)
    if stufe == 1:
        rest = "An der nächsten Bruchstelle (Thema fertig, Build ausgeliefert): zuerst `python3 tools/regelcheck.py --kurz` und die Funde im eigenen Vorrat beheben, dann Übergabe mit „Nachfolger: <Titel>“ pushen, send_message an Ford „Neustart <Name>, <Commit>“ (81r, LISTE-RELEASE-NEUSTART.md „Neustart“). Im Chat nichts dazu."
    else:
        rest = "Zweite Erinnerung: jetzt den Schritt beenden, Übergabe pushen, Neustart über Ford (81r); im Chat danach genau „Weiter in <Titel>: <Link>“."
    return kopf + " " + rest


def prompt(eingabe):
    # Uhr (Chef 18.10.: „keiner kann die Uhr lesen“): jede Nachricht trägt die echte Zeit, die Sitzung schätzt nie
    try:
        import datetime, zoneinfo
        print("Uhr: " + datetime.datetime.now(zoneinfo.ZoneInfo("Europe/Berlin")).strftime("%d.%m., %H:%M") + " (Berliner Zeit, Systemuhr; so stempeln)")
    except Exception:
        pass
    pfad = eingabe.get("transcript_path")
    sitzung = "".join(c for c in str(eingabe.get("session_id") or "x") if c.isalnum() or c == "-")[:64]
    kern(sitzung)
    if not pfad or not os.path.exists(pfad):
        return
    plus, gesamt = zuwachs(groessen(pfad))
    zpfad = f"/tmp/bornim-neustart-{sitzung}.json"
    try:
        with open(zpfad) as f:
            z = json.load(f)
    except (OSError, ValueError):
        z = {}
    if plus < AB:
        if z:
            os.remove(zpfad)  # unter der Schwelle (z. B. nach dem Verdichten): von vorn
        return
    stufe = int(z.get("stufe", 0))
    seit = int(z.get("seit", 0)) + 1
    faellig = stufe == 0 or plus >= 2 * AB or seit >= ABSTAENDE[min(stufe - 1, len(ABSTAENDE) - 1)]
    if faellig:
        stufe, seit = stufe + 1, 0
        print(text(stufe, plus, gesamt))
    with open(zpfad, "w") as f:
        json.dump({"stufe": stufe, "seit": seit}, f)


def kern(sitzung):
    """347: Kernregel-Zeile bei jeder KERN_ALLE-ten Nachricht, Wortlaut aus kernregeln.txt (main zuerst)."""
    zpfad = f"/tmp/bornim-kern-{sitzung}"
    try:
        n = int(open(zpfad).read().strip() or 0) + 1
    except (OSError, ValueError):
        n = 1
    with open(zpfad, "w") as f:
        f.write(str(n))
    if n % KERN_ALLE != 1:
        return
    for d in ("/home/user/bornim-main/tools", os.path.dirname(os.path.abspath(__file__))):
        try:
            print(open(os.path.join(d, "kernregeln.txt"), encoding="utf-8").read().strip())
            return
        except OSError:
            pass


def start(eingabe):
    wurzel = os.environ.get("CLAUDE_PROJECT_DIR") or eingabe.get("cwd") or "."
    # 98: jeder Vorrat ARBEIT-*.md, außer dem eingefrorenen Archiv (117).
    docs = os.path.join(wurzel, "docs")
    try:
        namen = sorted(os.listdir(docs))
    except OSError:
        return
    for name in namen:
        if not (name.startswith("ARBEIT-") and name.endswith(".md")) or name == "ARBEIT-ARCHIV.md":
            continue
        n = os.path.getsize(os.path.join(docs, name))
        if n > OFFEN_MAX:
            print(f"Bornim: docs/{name} ist {round(n / 1000)} KB groß (Grenze {round(OFFEN_MAX / 1000)} KB). "
                  "Nach der Regel „Vorräte klein halten“ in CLAUDE.md aufräumen (Erledigtes ins Archiv bzw. in die Änderungshistorie).")


def main():
    try:
        eingabe = json.load(sys.stdin)
    except ValueError:
        eingabe = {}
    art = sys.argv[1] if len(sys.argv) > 1 else ""
    if art == "prompt":
        prompt(eingabe)
    elif art == "start":
        start(eingabe)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
