#!/usr/bin/env python3
"""Startbares je Rolle (166): liest alle docs/ARBEIT-*.md und rechnet, was Ford starten darf.

Aufruf: python3 tools/startbar.py [--alle]   (Ford ruft es in jedem Lauf, LISTE-BETRIEB.md Schritt 1 und 4)
Je Rolle: oberstes startbares Muss und oberste startbare Kür (Kl. „M?“ zählt als Kür, „–“ zählt nicht);
dazu, warum andere Zeilen nicht startbar sind (--alle: jede Zeile). Prüft „offen n, Muss m“ der Kopfzeile
gegen die Zeilen (Chefsache k nicht: die Zuordnung Datei–Zeile ist nicht eindeutig). Pause bis <Zeit> im Kopf sperrt die Rolle. Exit 1, wenn eine Kopfzeile falsch ist.
Nicht startbar: „ruht“, „wartet auf X“ / „hängt an X“ / „nach X“ (solange X in LISTE-VORGAENGE.md nicht erledigt ist),
Datei des Punkts in docs/chefsache/entscheiden/, „wartet auf Chef“, „wartet auf Test/Sammelbuild“, Datum in der Zukunft.
Zusätzlich (166.2, D27): Stand beginnt mit „erledigt“/„auf main“ → „erledigt, nicht gestrichen“ (zählt nicht als offen, Exit 1);
„Teil erledigt“, „erst mit X“, „wartet auf <Rolle>“, „wartet auf den Test“, „Chef entscheidet“, Dauerzeilen („mit 149, bis 24.10.“, „ab …“) nicht startbar;
„gebaut“ gilt als fertig (Wartender darf prüfen/weiterbauen; der Test läuft getrennt); „Pause bis TT.MM.[, HH Uhr]“ gilt nur bis dahin;
Zeilen mit unlesbarer Klasse werden gemeldet. Zeilen „von X … Stellungnahme/prüfen“ mit Datei in der Chefsache sind startbar (der Auftrag ist die Datei).
Laufende Sitzungen kennt das Werkzeug nicht; die liest Ford aus list_sessions.
"""
import os, re, sys, datetime

DOCS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "docs")
ROLLEN = [("ARBEIT-KREATIV.md", "Homer"), ("ARBEIT-TEAM-TOM.md", "Tom"), ("ARBEIT-TEAM-JERRY.md", "Jerry"),
          ("ARBEIT-PROJEKT.md", "Perikles"), ("ARBEIT-PRUEFUNG.md", "Diogenes"), ("ARBEIT-BERATUNG.md", "Sokrates")]
FERTIG = re.compile(r"erledigt|auf main|getestet|gebaut", re.I)
ROLLEN_NAMEN = r"(?:Homer|Tom|Jerry|Perikles|Diogenes|Sokrates|Ford(?: 2)?|Chef)"
JETZT = datetime.datetime.now()

def blank(t):
    """Stand ohne Markdown-Zeichen am Anfang."""
    return re.sub(r"^[\s*`_]+", "", re.sub(r"\*\*|`", "", t)).strip()

def lesen(name):
    p = os.path.join(DOCS, name)
    return open(p, encoding="utf-8").read() if os.path.exists(p) else ""

def vorgaenge():
    """Nummer → Stand (letzte Spalte) aus LISTE-VORGAENGE.md."""
    tafel = {}
    for z in lesen("LISTE-VORGAENGE.md").splitlines():
        t = [x.strip() for x in z.split("|")]
        if z.startswith("| ") and len(t) > 7: tafel[t[1]] = t[-2]
    return tafel

VORG = vorgaenge()

def stand_von(nr):
    """72s.1 → 72s.1, 72s, 72: nächste Nummer mit Zeile in LISTE-VORGAENGE.md."""
    while nr:
        if nr in VORG: return nr, VORG[nr]
        kurz = re.sub(r"(\.\d+[a-z]*|[a-z])$", "", nr)
        if kurz == nr: break
        nr = kurz
    return None, None

def chefdateien():
    d = os.path.join(DOCS, "chefsache", "entscheiden")
    return os.listdir(d) if os.path.isdir(d) else []

def datum_nach(text, wort):
    """Datum direkt hinter „wort“ (z. B. frühestens 31.10.), wenn in der Zukunft, sonst None."""
    h = datetime.date.today()
    for m in re.finditer(wort + r"\s+(?:\w{1,3}\s+)?(\d\d)\.(\d\d)\.", text):
        try: d = datetime.date(h.year, int(m.group(2)), int(m.group(1)))
        except ValueError: continue
        if d > h: return "%02d.%02d." % (d.day, d.month)
    return None

def datum_zukunft(text):
    """Erstes „bis / erstmals / ab / frühestens TT.MM.“ in der Zukunft, sonst None."""
    h = datetime.date.today()
    for m in re.finditer(r"(?:bis|erstmals(?: \w+)?|ab|frühestens)\s+(\d\d)\.(\d\d)\.", text):
        try: d = datetime.date(h.year, int(m.group(2)), int(m.group(1)))
        except ValueError: continue
        if d > h: return "%02d.%02d." % (d.day, d.month)
    return None

def zeilen(inhalt, unles=None):
    """Tabellenzeilen (Nr, Kl, Thema, Rest); Kopf und Trenner fallen weg. Rest = Stand/Zweig bzw. Auftrag/Bedingung.
    Zeilen mit unlesbarer Klasse oder zu wenig Spalten landen in unles (D27.5), nicht still im Nichts."""
    aus = []
    for z in inhalt.splitlines():
        if not z.startswith("| "): continue
        t = [x.strip() for x in z.split("|")][1:-1]
        if not t or t[0] in ("Nr.", "Nr") or set(t[0]) <= set("-: "): continue
        if len(t) < 4 or t[1] not in ("M", "K", "M?", "–", "-"):
            if unles is not None: unles.append(t[0])
            continue
        aus.append((t[0], t[1], t[2], " | ".join(t[3:])))
    return aus

def blocker(nr, rest, chef, thema=""):
    """Grund, warum die Zeile nicht startbar ist, sonst None."""
    pre = nr.replace(".", "")
    b = blank(rest)
    if re.match(r"(erledigt\b|auf main\s*(\(|–|$))", b, re.I): return "ERLEDIGT"
    if re.match(r"(\w+ )?Teil erledigt", b): return "Teil erledigt, Rest wartet"
    if re.match(r"(mit \S+,? bis \d\d\.\d\d\.|ab Fords erstem Start|bis \d\d\.\d\d\.)", b):
        d = datum_nach(b, "bis") or datum_nach(b, "nach dem")
        return "Dauerzeile" + (" bis " + d if d else "")
    stellung = re.search(r"Stellungnahme|\bprüfen\b", thema + rest) and re.search(r"Chefsache|chefsache/", thema + rest)
    if not stellung and any(f.startswith(pre + "-") for f in chef): return "Chef (Datei in der Chefsache)"
    if re.search(r"wartet auf (den )?(Test|Chef)|Chef entscheidet", rest): return "Chef/Test"
    m = re.search(r"wartet auf (?:\*\*)?" + ROLLEN_NAMEN + r"\b", rest)
    if m: return m.group(0).replace("*", "")
    if re.search(r"wartet auf Chef|Entscheidung des Chefs", rest): return "Chef"
    if re.search(r"(?<!Niederlassung )(?<!Niederlassung\* )(^|\*|\s)ruht\b(?! seit)|zurückgestellt", rest):
        d = datum_zukunft(rest)
        return "ruht" + (" bis " + d if d else "")
    d = datum_nach(rest, r"(?:erstmals|frühestens)")
    if d: return "Termin " + d
    if re.search(r"(erst )?nach dem Meilenstein", rest): return "nach dem Meilenstein"
    m = re.search(r"(?:wartet auf|hängt an|erst nach|erst mit)\s+(\d+[a-z0-9.]*)(?![:\d])|^nach\s+(\d+[a-z0-9.]*)(?![:\d])", b)
    if m and not (m.group(1) or m.group(2)).startswith("20"):
        x = (m.group(1) or m.group(2)).rstrip(".")
        if x == nr or x.startswith(nr + "."): return None  # eigener Unterpunkt, kein fremdes Warten
        n, st = stand_von(x)
        if st is None: return "wartet auf %s (Nummer unbekannt)" % x
        if not FERTIG.search(st): return "wartet auf %s (%s)" % (x, st)
        return None
    if re.search(r"wartet auf (Test|Sammelbuild|Build)", rest): return "wartet auf Test/Build"
    return None

def kopf(inhalt):
    m = re.search(r"\*\*offen (\d+), Muss (\d+), A (\d+), Chefsache (\d+)\*\*", inhalt)
    return tuple(int(x) for x in m.groups()) if m else None

def pause(inhalt):
    """„Pause bis TT.MM.[, HH[:MM] Uhr]“ in den ersten 14 Zeilen: Text, solange der Zeitpunkt nicht erreicht ist (D27.4).
    Nicht lesbares Datum sperrt vorsichtshalber und sagt es."""
    for z in inhalt.splitlines()[:14]:
        m = re.search(r"Pause bis (?:\w{1,3},? )?(\d\d)\.(\d\d)\.(?:,? (\d\d)(?::(\d\d))?(?: Uhr)?)?", z)
        if m:
            try:
                bis = datetime.datetime(JETZT.year, int(m.group(2)), int(m.group(1)), int(m.group(3) or 0), int(m.group(4) or 0))
            except ValueError: return m.group(0)[10:] + " (nicht lesbar)"
            if bis > JETZT: return m.group(0)[10:]
        elif "Pause bis" in z and not re.search(r"Pause bis (?:\w{1,3},? )?\d\d\.\d\d\.", z) and z.lstrip().startswith(("**Pause", "Pause")):
            return z.strip()[:40] + " (Datum nicht lesbar)"
    return None

def main():
    alle = "--alle" in sys.argv
    chef = chefdateien()
    falsch = 0
    print("Startbar am %s (Systemdatum):" % datetime.date.today().strftime("%d.%m."))
    for datei, rolle in ROLLEN:
        inhalt = lesen(datei)
        if not inhalt:
            print("  %s: Datei fehlt" % rolle); continue
        unles = []
        zs = [z for z in zeilen(inhalt, unles) if z[1] not in ("–", "-")]
        sperr = {z[0]: blocker(z[0], z[3], chef, z[2]) for z in zs}
        erl = [z[0] for z in zs if sperr[z[0]] == "ERLEDIGT"]
        zs = [z for z in zs if sperr[z[0]] != "ERLEDIGT"]
        soll = (len(zs), sum(1 for z in zs if z[1] == "M"))
        k = kopf(inhalt)
        warn = ""
        if k is None: warn = "  KOPF FEHLT"
        elif (k[0], k[1]) != soll:
            warn = "  KOPF FALSCH: steht offen %d, Muss %d; Zeilen ergeben offen %d, Muss %d" % (k[0], k[1], *soll)
        if erl: warn += "  ERLEDIGT, NICHT GESTRICHEN: " + ", ".join(erl)
        if unles: warn += "  UNLESBAR (Klasse/Spalten): " + ", ".join(unles)
        if warn: falsch += 1
        p = pause(inhalt)
        if p: print("  %s: PAUSE bis %s%s" % (rolle, p, warn)); continue
        erstes = {"M": None, "K": None}
        sperren = []
        for nr, kl, thema, rest in zs:
            b = sperr[nr]
            if b: sperren.append((nr, b)); continue
            art = "M" if kl == "M" else "K"
            if erstes[art] is None: erstes[art] = (nr, kl, thema)
        def kurz(e): return "%s %s" % (e[0], re.sub(r"\*\*|`", "", e[2])[:70]) if e else "–"
        print("  %s: Muss %s | Kür %s%s" % (rolle, kurz(erstes["M"]), kurz(erstes["K"]), warn))
        if alle:
            for nr, b in sperren: print("      nicht startbar: %s: %s" % (nr, b))
        elif sperren:
            print("      nicht startbar: " + "; ".join("%s: %s" % s for s in sperren[:6]) + (" …" if len(sperren) > 6 else ""))
    sys.exit(1 if falsch else 0)

if __name__ == "__main__":
    main()
