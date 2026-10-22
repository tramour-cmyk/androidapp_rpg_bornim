#!/usr/bin/env python3
"""Startbares je Rolle (166): liest alle docs/ARBEIT-*.md und rechnet, was Ford starten darf.

Aufruf: python3 tools/startbar.py [--alle] [--stand] [--md]   (Ford ruft es in jedem Lauf, LISTE-BETRIEB.md Schritt 1 und 4)
Je Rolle: oberstes startbares Muss und oberste startbare Kür (Kl. „M?“ zählt als Kür, „–“ zählt nicht);
dazu, warum andere Zeilen nicht startbar sind (--alle: jede Zeile). Es gibt keine Kopfzeile mehr (167.1):
--stand rechnet je Rolle „offen n, Muss m, startbar s“ aus den Zeilen. Pause bis <Zeit> im Kopf sperrt die Rolle. Exit 1 bei erledigten, nicht gestrichenen oder unlesbaren Zeilen.
Nicht startbar: „ruht“, „wartet auf X“ / „hängt an X“ / „nach X“ (solange X in LISTE-VORGAENGE.md nicht erledigt ist),
Datei des Punkts in docs/chefsache/entscheiden/, „wartet auf Chef“, „wartet auf Test/Sammelbuild“, Datum in der Zukunft.
Zusätzlich (166.2, D27): Stand beginnt mit „erledigt“/„auf main“ → „erledigt, nicht gestrichen“ (zählt nicht als offen, Exit 1);
„Teil erledigt“, „erst mit X“, „wartet auf <Rolle>“, „wartet auf den Test“, „Chef entscheidet“, Dauerzeilen („mit 149, bis 24.10.“, „ab …“) nicht startbar;
„gebaut“ gilt für Wartende als fertig (sie dürfen prüfen/weiterbauen; der Test läuft getrennt), die Zeile selbst mit Stand „gebaut …“ wartet auf Test/Build (190.1); „Pause bis TT.MM.[, HH Uhr]“ gilt nur bis dahin;
Zeilen mit unlesbarer Klasse werden gemeldet. Zeilen „von X … Stellungnahme/prüfen“ mit Datei in der Chefsache sind startbar (der Auftrag ist die Datei).
Laufende Sitzungen kennt das Werkzeug nicht; die liest Ford aus list_sessions.
Muss durch Wartende (190.3, 162): wartet eine offene Zeile in einem anderen Vorrat auf Nummer X („wartet auf / hängt an / erst nach / erst mit X“), zählt die Zeile X
in ihrem Vorrat als Muss, auch als Kür oder „M?“, wenn die wartende Zeile selbst Muss ist (162) (Ausgabe: „↑ Muss: <Rolle> wartet“).
Am Ende (188): Vorgänge, die in LISTE-VORGAENGE.md nicht erledigt sind, aber in keinem Vorrat eine Zeile haben
(„ohne Vorrat“, je Spalte „Vorrat“; --alle nennt alle Nummern). Der Besitzer legt die Zeile wieder an oder setzt den Stand.
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
    for z in (lesen("LISTE-VORGAENGE.md") + "\n" + lesen("LISTE-VORGAENGE-ARCHIV.md")).splitlines():
        t = [x.strip() for x in z.split("|")]
        if z.startswith("| ") and len(t) > 7: tafel[t[1]] = t[-2]
    return tafel

VORG = vorgaenge()

def stand_von(nr):
    """72s.1 → 72s.1, 72s, 72: nächste Nummer mit Zeile in LISTE-VORGAENGE.md."""
    while nr:
        if nr in VORG: return nr, VORG[nr]
        kurz = re.sub(r"(\.\d+[a-z]*|[a-zA-Z])$", "", nr)  # auch Suffix M, T (177M, 72.10a.11T)
        if kurz == nr: break
        nr = kurz
    return None, None

def chefdateien():
    d = os.path.join(DOCS, "chefsache", "entscheiden")
    return os.listdir(d) if os.path.isdir(d) else []

def jahr_von(tag, monat):
    """Datum zu TT.MM.: dieses Jahr, liegt es mehr als ein halbes Jahr zurück, das nächste (Januartermine im Herbst, D28.4)."""
    h = datetime.date.today()
    d = datetime.date(h.year, monat, tag)
    return d if d >= h - datetime.timedelta(days=183) else datetime.date(h.year + 1, monat, tag)

def datum_nach(text, wort):
    """Datum direkt hinter „wort“ (z. B. frühestens 31.10., nach dem 22.10.), wenn in der Zukunft, sonst None."""
    h = datetime.date.today()
    for m in re.finditer(r"\b" + wort + r"\s+(?:\w{1,3}\s+)?(\d\d)\.(\d\d)\.", text, re.I):
        try: d = jahr_von(int(m.group(1)), int(m.group(2)))
        except ValueError: continue
        if d > h: return "%02d.%02d." % (d.day, d.month)
    return None

def datum_zukunft(text):
    """Erstes „bis / erstmals / ab / nach dem / frühestens TT.MM.“ in der Zukunft, sonst None."""
    return datum_nach(text, r"(?:bis|erstmals(?: \w+)?|ab|nach dem|frühestens)")

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
    rest = re.sub(r"„[^“]*“", "", rest)  # Zitierte Wörter („nicht ‚wartet auf Chef‘“) sperren nicht
    if re.match(r"(erledigt\b|auf main\s*(\(|–|$))", b, re.I): return "ERLEDIGT"
    if re.match(r"(\w+ )?Teil erledigt", b): return "Teil erledigt, Rest wartet"
    if re.match(r"gebaut\b", b, re.I): return "wartet auf Test/Build (gebaut)"  # 190.1
    if re.match(r"(mit \S+,? bis \d\d\.\d\d\.|ab Fords erstem Start|bis \d\d\.\d\d\.)", b):
        d = datum_nach(b, "bis") or datum_nach(b, "nach dem")
        return "Dauerzeile" + (" bis " + d if d else "")
    stellung = re.search(r"Stellungnahme|\bprüfen\b", thema + rest) and re.search(r"Chefsache|chefsache/", thema + rest)
    if not stellung and any(f.startswith(pre + "-") for f in chef): return "Chef (Datei in der Chefsache)"
    if re.search(r"wartet auf (den )?Test", rest, re.I): return "wartet auf Test (Build)"
    if re.search(r"wartet auf Chef|Chef entscheidet", rest, re.I): return "Chef"
    m = re.search(r"wartet auf (?:\*\*)?" + ROLLEN_NAMEN + r"\b", rest)
    if m: return m.group(0).replace("*", "")
    if re.search(r"wartet auf Chef|Entscheidung des Chefs", rest, re.I): return "Chef"
    if re.search(r"(?<!Niederlassung )(?<!Niederlassung\* )(^|\*|\s)ruht\b(?! seit)|zurückgestellt", rest):
        d = datum_zukunft(rest)
        return "ruht" + (" bis " + d if d else "")
    d = datum_nach(rest, r"(?:erstmals|frühestens|ab|nach dem)")
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

WARTET = re.compile(r"(?:wartet auf|hängt an|erst nach|erst mit)\s+(\d+[a-z0-9.]*)(?![:\d])|^nach\s+(\d+[a-z0-9.]*)(?![:\d])")
_FREMD = None

def fremd_wartend():
    """Nummer → Rollen, die in einem anderen Vorrat mit einer offenen Zeile darauf warten (190.3)."""
    global _FREMD
    if _FREMD is not None: return _FREMD
    chef = chefdateien()
    zeilen_je = {rolle: zeilen(lesen(datei)) for datei, rolle in ROLLEN}
    besitz = {z[0]: rolle for rolle, zs in zeilen_je.items() for z in zs}
    _FREMD = {}
    for rolle, zs in zeilen_je.items():
        for nr, kl, thema, rest in zs:
            if kl != "M" or blocker(nr, rest, chef, thema) == "ERLEDIGT": continue  # nur wartende Muss-Zeilen vererben (162)
            m = WARTET.search(blank(rest))
            x = (m.group(1) or m.group(2)).rstrip(".") if m else None
            if x and besitz.get(x) not in (None, rolle) and not x.startswith("20"):
                _FREMD.setdefault(x, []).append(rolle)
    return _FREMD

def hochstufen(zs):
    """Zeilen, auf die ein anderer Vorrat wartet, zählen als Muss (190.3)."""
    f = fremd_wartend()
    return [(nr, "M" if nr in f else kl, th, rest) for nr, kl, th, rest in zs]

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

ZU = re.compile(r"^(erledigt|abgelehnt|verworfen|aufgeteilt|laufend|Idee)", re.I)

def ohne_vorrat(alle):
    """Vorgänge offen in LISTE-VORGAENGE.md ohne Zeile (erste Spalte) in einem Vorrat (188); 72 deckt 72s.1 und umgekehrt."""
    nrn = set()
    for datei in [d for d, _ in ROLLEN] + ["ARBEIT-BETRIEB.md"]:
        for z in lesen(datei).splitlines():
            t = [x.strip() for x in z.split("|")]
            if z.startswith("| ") and len(t) > 2: nrn.add(re.sub(r"\*\*|`", "", t[1]))
    def gedeckt(nr):
        return any(n == nr or n.startswith(nr) and re.match(r"[.a-zA-Z]", n[len(nr):]) or nr.startswith(n) and n and re.match(r"[.a-zA-Z]", nr[len(n):]) for n in nrn)
    je = {}
    for z in lesen("LISTE-VORGAENGE.md").splitlines():
        t = [x.strip() for x in z.split("|")]
        if not z.startswith("| ") or len(t) < 8 or not re.match(r"^D?\d", t[1]): continue
        if ZU.match(t[-2]) or t[-3] == "Ideen" or gedeckt(t[1]): continue
        je.setdefault(t[-3] or "?", []).append(t[1])
    if not je: return
    n = sum(len(v) for v in je.values())
    print("  OHNE VORRAT (offen in LISTE-VORGAENGE.md, keine Zeile in einem Vorrat): %d – " % n + "; ".join(
        "%s %s" % (k, ", ".join(v if alle else v[:4]) + ("" if alle or len(v) <= 4 else " …")) for k, v in sorted(je.items())))

UEBERNAHME = {"Tom": "Jerry", "Jerry": "Tom"}
GERAET = re.compile(r"Test|Gerät|Build|APK", re.I)

def uebernahme(rolle, info):
    """118/202: hat das Team nichts Startbares, die oberste freie Zeile des anderen Teams (ohne Gerätetest bevorzugt); Build-Grenze (317): warten beide Teams zusammen schon 6 Punkte auf Test, erst bauen."""
    a = UEBERNAHME[rolle]
    if a not in info: return None
    frei, wartend, _ = info[a]
    if rolle not in info or info[rolle][2]: return None
    if not frei or wartend + info[rolle][1] >= 6: return None
    ohne = [z for z in frei if not GERAET.search(z[2])]
    z = (ohne or frei)[0]
    return "%s %s (Übernahme 118 von Team %s%s)" % (z[0], re.sub(r"\*\*|`", "", z[2])[:60], a, "" if ohne else ", mit Gerätetest")

def main():
    alle = "--alle" in sys.argv
    stand = "--stand" in sys.argv
    md = "--md" in sys.argv
    chef = chefdateien()
    falsch = 0
    info = {}
    if md: print("## Offen je Rolle\n\nVom Werkzeug gerechnet (`tools/startbar.py --md`, 167.10), Stand %s; „startbar“ heißt: nichts hält die Zeile auf, eine laufende Sitzung kennt das Werkzeug nicht.\n" % datetime.date.today().strftime("%d.%m."))
    else: print("Startbar am %s (Systemdatum):" % datetime.date.today().strftime("%d.%m."))
    for datei, rolle in ROLLEN:
        inhalt = lesen(datei)
        if not inhalt:
            print("  %s: Datei fehlt" % rolle); continue
        unles = []
        zs = hochstufen([z for z in zeilen(inhalt, unles) if z[1] not in ("–", "-")])
        sperr = {z[0]: blocker(z[0], z[3], chef, z[2]) for z in zs}
        erl = [z[0] for z in zs if sperr[z[0]] == "ERLEDIGT"]
        zs = [z for z in zs if sperr[z[0]] != "ERLEDIGT"]
        warn = ""
        if erl: warn += "  ERLEDIGT, NICHT GESTRICHEN: " + ", ".join(erl)
        if unles: warn += "  UNLESBAR (Klasse/Spalten): " + ", ".join(unles)
        if warn: falsch += 1
        p = pause(inhalt)
        if md:
            print("**%s** – offen %d, Muss %d, startbar %d%s\n" % (rolle, len(zs), sum(1 for z in zs if z[1] == "M"), sum(1 for z in zs if not sperr[z[0]]), (", PAUSE bis " + p) if p else ""))
            print("| Nr. | Kl. | Was | Stand |\n|---|---|---|---|")
            for nr, kl, thema, rest in zs:
                w = re.sub(r"\*\*|`|\|", "", thema)[:90].strip()
                print("| %s | %s | %s | %s |" % (nr, kl, w, sperr[nr] or "startbar"))
            print()
            continue
        if p: print("  %s: PAUSE bis %s%s" % (rolle, p, warn)); continue
        erstes = {"M": None, "K": None, "N": None}
        sperren = []
        for nr, kl, thema, rest in zs:
            b = sperr[nr]
            if b == "nach dem Meilenstein":  # 190.10: letzte Stufe vor Leerlauf
                sperren.append((nr, b))
                if erstes["N"] is None: erstes["N"] = (nr, kl, thema)
                continue
            if b: sperren.append((nr, b)); continue
            art = "M" if kl == "M" else "K"
            if erstes[art] is None: erstes[art] = (nr, kl, thema)
        if rolle in UEBERNAHME:
            info[rolle] = ([z for z in zs if not sperr[z[0]] and z[1] != "–"], sum(1 for n, b in sperren if b.startswith("wartet auf Test")), erstes["M"] or erstes["K"] or erstes["N"])
        def kurz(e):
            if not e: return "–"
            return "%s %s%s" % (e[0], re.sub(r"\*\*|`", "", e[2])[:70], (" ↑ Muss: %s wartet" % ", ".join(fremd_wartend()[e[0]])) if e[0] in fremd_wartend() else "")
        print("  %s: Muss %s | Kür %s%s%s" % (rolle, kurz(erstes["M"]), kurz(erstes["K"]), (" | nach dem Meilenstein " + kurz(erstes["N"])) if erstes["N"] else "", warn))
        if stand:
            st = sum(1 for z in zs if not sperr[z[0]])
            print("      offen %d, Muss %d, startbar %d, gesperrt %d" % (len(zs), sum(1 for z in zs if z[1] == "M"), st, len(sperren)))
        if alle:
            for nr, b in sperren: print("      nicht startbar: %s: %s" % (nr, b))
        elif sperren:
            print("      nicht startbar: " + "; ".join("%s: %s" % s for s in sperren[:6]) + (" …" if len(sperren) > 6 else ""))
    if not md:
        for r in UEBERNAHME:
            u = uebernahme(r, info)
            if u: print("  Übernahme für %s: %s" % (r, u))
        if all(r in info for r in UEBERNAHME) and sum(info[r][1] for r in UEBERNAHME) >= 3:  # 317: ab 3 fertigen Punkten beider Teams bittet der Erste
            print("  Gemeinsamer Build: %s warten auf Test (ab 3 bittet der Erste, höchstens 6 je Build; 317)" % ", ".join("%s %d" % (r, info[r][1]) for r in UEBERNAHME))
        ohne_vorrat(alle)
    sys.exit(1 if falsch else 0)

if __name__ == "__main__":
    main()
