#!/usr/bin/env python3
"""Abgleich der Notizen (191): gibt WARNUNG-Zeilen aus, nichts sonst; lauf.py ruft es in jedem Lauf, Ford trägt jede WARNUNG ein.
Nur das Neue (D31.4); Vorhandenes rechnen startbar.py, lauf.py, regelcheck.py, vorgangskosten.py.
Prüfungen:
  1. Vorratszeile ohne Eintrag in LISTE-VORGAENGE.md (Nummer unbekannt, auch keine Oberzeile)
  2. Vorratszeile „gebaut“ / „wartet auf Test“ mit Zweig `claude/…`, der schon auf origin/main zusammengeführt ist
  3. Vorgangsarchiv: entschiedener Vorgang mit „Umsetzung“, aber ohne Zeile in einem Vorrat und nicht „erledigt“ in der Liste
Aufruf: python3 tools/abgleich.py  (Exit 0 immer; Ausgabe leer = alles stimmig)
"""
import os, re, subprocess, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startbar

def zusammengefuehrt():
    try:
        o = subprocess.run(["git", "branch", "-r", "--merged", "origin/main"], capture_output=True, text=True, cwd=startbar.DOCS, timeout=30).stdout
    except Exception:
        return None
    return {l.strip().replace("origin/", "", 1) for l in o.splitlines() if l.strip()}

def pruefen():
    w = []
    besitz = {}
    merged = zusammengefuehrt()
    for datei, rolle in startbar.ROLLEN:
        for nr, kl, thema, rest in startbar.zeilen(startbar.lesen(datei)):
            besitz[nr] = rolle
            if re.match(r"D\d+(\.\d+)?$", nr): continue  # Prüfbefunde haben keine Listenzeile
            if startbar.stand_von(nr)[0] is None:
                w.append("WARNUNG Abgleich: %s (%s) steht im Vorrat, aber nicht in LISTE-VORGAENGE.md" % (nr, rolle))
            b = startbar.blank(rest)
            if merged is not None and re.match(r"(gebaut|wartet auf (den )?Test)", b, re.I):
                for z in re.findall(r"claude/[\w./-]+", rest):
                    if z in merged:
                        w.append("WARNUNG Abgleich: %s (%s) wartet auf Test, Zweig %s ist schon auf main" % (nr, rolle, z)); break
    for z in startbar.lesen("VORGANGSARCHIV.md").splitlines()[:60]:
        m = re.match(r"- \*\*(\d+[a-z]*(?:\.\d+[a-z]*)*)\*\*", z)
        if not m or "Umsetzung" not in z: continue
        nr = m.group(1)
        if nr in besitz: continue
        n, st = startbar.stand_von(nr)
        if st is not None and startbar.FERTIG.search(st): continue
        w.append("WARNUNG Abgleich: %s ist entschieden (Umsetzung genannt), aber ohne Zeile in einem Vorrat und nicht erledigt (%s)" % (nr, st or "ohne Listenzeile"))
    return w

if __name__ == "__main__":
    for l in pruefen(): print(l)
