#!/usr/bin/env python3
"""Abgleich der Notizen (191): gibt WARNUNG-Zeilen aus, nichts sonst; lauf.py ruft es in jedem Lauf, Ford trägt jede WARNUNG ein.
Nur das Neue (D31.4); Vorhandenes rechnen startbar.py, lauf.py, regelcheck.py, vorgangskosten.py.
Prüfungen:
  1. Vorratszeile ohne Eintrag in LISTE-VORGAENGE.md (Nummer unbekannt, auch keine Oberzeile)
  2. Vorratszeile „gebaut“ / „wartet auf Test“ mit Zweig `claude/…`, der schon auf origin/main zusammengeführt ist
  3. Vorgangsarchiv: entschiedener Vorgang mit „Umsetzung“, aber ohne Zeile in einem Vorrat und nicht „erledigt“ in der Liste
  3b. Termin im Stand (ab, bis, Entscheid, Messung TT.MM.) liegt über 2 Tage zurück, Stand unverändert
  4. Vorentscheid (194.1): Archivzeile ab 19.10. mit „Vorentscheid“ braucht Datei in chefsache/billigen/ oder den Vermerk „gebilligt TT.MM.“ / „zurück TT.MM.“;
     Bremse: mehr als fünf Dateien in billigen/ oder eine älter als 7 Tage, mehr als zwei „zurück“ in 7 Tagen (Meldung „Vorentscheid-Bremse“)
Aufruf: python3 tools/abgleich.py  (Exit 0 immer; Ausgabe leer = alles stimmig)
"""
import datetime, os, re, subprocess, sys
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
            # 191: genannter Termin (ab/bis/Entscheid/Messung TT.MM.) liegt über 2 Tage zurück und der Stand ist unverändert
            for tg, mo in re.findall(r"(?:ab|bis|Entscheid|Messung|nach dem)\s+(\d\d?)\.(\d\d)\.", rest):
                try: tag = startbar.jahr_von(int(tg), int(mo))
                except ValueError: continue
                if (datetime.date.today() - tag).days > 2 and not startbar.FERTIG.search(b):
                    w.append("WARNUNG Abgleich: %s (%s) nennt den Termin %s.%s., er ist vorbei und der Stand hat sich nicht geändert" % (nr, rolle, tg, mo)); break
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
    w += vorentscheide()
    return w

def vorentscheide():
    """194.1 / D33.1: Spur jedes Vorentscheids; Bremse."""
    w = []; heute = datetime.date.today()
    d = os.path.join(startbar.DOCS, "chefsache", "billigen")
    dateien = sorted(n for n in os.listdir(d) if n.endswith(".md")) if os.path.isdir(d) else []
    for z in startbar.lesen("VORGANGSARCHIV.md").splitlines()[:80]:
        m = re.match(r"- \*\*(\d+[a-zA-Z]*(?:\.\d+[a-zA-Z]*)*)\b", z)
        dm = re.search(r"\((\d\d)\.(\d\d)\.", z)
        if not m or not dm or "Vorentscheid" not in z: continue
        if (int(dm.group(2)), int(dm.group(1))) < (10, 19): continue
        if re.search(r"(gebilligt|zurück) \d\d\.\d\d\.", z): continue
        nr = m.group(1); kurz = nr.replace(".", "").lower()
        if any(n.lower().startswith(kurz + "-") for n in dateien): continue
        w.append("WARNUNG Abgleich: Vorentscheid %s ohne Datei in chefsache/billigen/ und ohne Vermerk „gebilligt“ oder „zurück“ in der Archivzeile (194.1)" % nr)
    alt = []
    for n in dateien:
        dm = re.search(r"\b(\d\d)\.(\d\d)\.", " ".join(startbar.lesen("chefsache/billigen/" + n).splitlines()[1:2]))
        if dm and (heute - startbar.jahr_von(int(dm.group(1)), int(dm.group(2)))).days > 7: alt.append(n)
    zurueck = 0
    for z in startbar.lesen("VORGANGSARCHIV.md").splitlines()[:80]:
        for tag, mon in re.findall(r"zurück (\d\d)\.(\d\d)\.", z):
            if 0 <= (heute - startbar.jahr_von(int(tag), int(mon))).days <= 7: zurueck += 1
    if len(dateien) > 5 or alt or zurueck > 2:
        w.append("WARNUNG Abgleich: Vorentscheid-Bremse (194.1): %d ungebilligt, %d älter als 7 Tage, %d „zurück“ in 7 Tagen: keine neuen Vorentscheide, bis der Chef aufgeholt hat" % (len(dateien), len(alt), zurueck))
    return w

if __name__ == "__main__":
    for l in pruefen(): print(l)
