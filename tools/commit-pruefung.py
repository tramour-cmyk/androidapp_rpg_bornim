#!/usr/bin/env python3
"""Prüfung beim Commit in der Notizkopie (192.1, Grenzen aus D31.1). Aufruf als pre-commit-Haken (notiz.sh richtet ihn ein).
Hält an (Exit 1): Uhrzeit von heute mehr als 5 Minuten nach jetzt in einer neuen Zeile; gelöschte Chefsache-Datei ohne
Änderung an VORGANGSARCHIV.md (Ausweg: BORNIM_ZURUECK=1 für zurückgezogene Fragen des Absenders); neue Vorratszeile mit Nummer ohne
Zeile in LISTE-VORGAENGE.md (D- und Unternummern über die Oberzeile); Vorrat über 15000 Bytes, den der Commit vergrößert
(ARBEIT-BETRIEB.md ausgenommen: Fords Startsperre muss dorthin, kürzen ist Fords Zeile).
Warnt (Exit 0): Modellnamen, Zeilen über 1500 Zeichen. Fasst nur Notizen an; sonst Exit 0. Jeder Fehler im Haken lässt durch."""
import datetime, os, re, subprocess, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

def git(*a):
    return subprocess.run(["git"] + list(a), capture_output=True, text=True).stdout

def main():
    ge = git("diff", "--cached", "--name-status", "--no-renames").splitlines()
    dat = [(l.split("\t")[0], l.split("\t")[1]) for l in ge if "\t" in l]
    if not dat or not all(p.startswith("docs/") or p in ("CLAUDE.md", "CHANGELOG.md") or p.startswith("tools/") for _, p in dat):
        return 0
    stop, warn = [], []
    import zoneinfo
    jetzt = datetime.datetime.now(zoneinfo.ZoneInfo("Europe/Berlin")); heute = jetzt.strftime("%d.%m.")
    arch = any(p == "docs/VORGANGSARCHIV.md" for _, p in dat)
    neu = git("diff", "--cached", "-U0", "--no-renames", "--", "docs", "CLAUDE.md").splitlines()
    datei = ""
    import startbar
    for z in neu:
        if z.startswith("+++ b/"): datei = z[6:]; continue
        if not z.startswith("+") or z.startswith("+++"): continue
        t = z[1:]
        for m in re.finditer(r"(?<!\d)" + re.escape(heute).replace(r"\.", r"\.") + r",? (\d\d):(\d\d)(?!\d)", t):
            if jetzt.replace(hour=int(m.group(1)), minute=int(m.group(2))) > jetzt + datetime.timedelta(minutes=5):
                stop.append("%s: Uhrzeit %s:%s liegt nach jetzt (%s)" % (datei, m.group(1), m.group(2), jetzt.strftime("%H:%M"))); break
        mm = re.match(r"\| ([0-9][0-9a-zA-Z.]*) \| (M\?|M|K) \|", t)
        if mm and re.match(r"docs/ARBEIT-(KREATIV|TEAM|PROJEKT|PRUEFUNG|BERATUNG)", datei):
            nr = mm.group(1)
            if not re.match(r"D\d", nr) and startbar.stand_von(nr)[0] is None and not any(nr in x for x in open("docs/LISTE-VORGAENGE.md", encoding="utf-8").read().split("\n") if x.startswith("| " + nr + " ")):
                stop.append("%s: Nummer %s ohne Zeile in LISTE-VORGAENGE.md" % (datei, nr))
        if re.search(r"\b(opus|sonnet|haiku|fable)\b", t, re.I) and not datei.endswith(("LISTE-BETRIEB.md", "PRUEFBERICHT-ARCHIV.md", "VORGANGSARCHIV.md", "PRUEFBERICHT.md")) and not datei.startswith("tools/"):
            warn.append("%s: Modellname in neuer Zeile" % datei)
        if len(t) > 1500 and datei.startswith("docs/ARBEIT-"): warn.append("%s: Zeile über 1500 Zeichen" % datei)
    for s, p in dat:
        if s == "D" and p.startswith("docs/chefsache/entscheiden/") and not arch and os.environ.get("BORNIM_ZURUECK") != "1":
            stop.append("%s gelöscht ohne Eintrag im Vorgangsarchiv (zurückgezogen: BORNIM_ZURUECK=1)" % p)
        if re.match(r"docs/ARBEIT-(KREATIV|TEAM-TOM|TEAM-JERRY|PROJEKT|PRUEFUNG|BERATUNG)\.md$", p) and s != "D":
            neu_b = len(git("show", ":" + p).encode()); alt = git("show", "HEAD:" + p)
            if neu_b > 15000 and neu_b > len(alt.encode()):
                stop.append("%s hat %d Bytes (über 15000) und wächst; erst kürzen" % (p, neu_b))
    code = [p for s, p in dat if s != "D" and re.match(r"(core|app|tools/preview)/.*\.(kt|kts)$", p)]
    if code:  # 192.3: Kerntest-Marke aus tools/t logik (voller Lauf, Exit 0) muss neuer sein als der Code
        marke = os.path.join(git("rev-parse", "--git-common-dir").strip(), "kerntest-ok")
        try: neuster = max(os.path.getmtime(p) for p in code if os.path.exists(p))
        except ValueError: neuster = 0
        if not os.path.exists(marke) or os.path.getmtime(marke) < neuster:
            warn.append("Code ohne grünen Kerntest seit der letzten Änderung (tools/t logik, Exit-Code prüfen)")
    for w in warn: print("Commit-Prüfung Warnung: " + w, file=sys.stderr)
    for s in stop: print("Commit-Prüfung HÄLT AN: " + s, file=sys.stderr)
    return 1 if stop else 0

if __name__ == "__main__":
    try: sys.exit(main())
    except Exception as e:
        print("Commit-Prüfung übersprungen: %s" % e, file=sys.stderr); sys.exit(0)
