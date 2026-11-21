#!/usr/bin/env python3
"""1763 (1727, Archiv 21.11., 14:37 A, B, C; prozesspruefung-21-11.md): Rückmeldung in die Vorgangsdatei, Obergrenzen A und B,
Weitergabe an Sokrates bei „steckt fest“, „Frage“, „wirkt nein“ (C; den Start macht lauf.py, Zeile „1763 C“).

  vorgang.py rueckmeldung NR "Text" [--sitzung ROLLE]

Schreibt die Rückmeldung wörtlich mit Zeit und Sitzung in docs/vorgang/NR.md (Abschnitt „Rückmeldungen“) und, je nach erstem Wort,
im selben Commit eine offene Übergabezeile (1760):
  „steckt fest“ (auch „nein … steckt fest“ des Prüfers), „Frage“, „wirkt nein“ → an Sokrates (C)
  „nein, Auftrag“ → an den Arbeitsplaner (Gesamtbild 6.1)
  zweites „nein“ je Vorgang → an Sokrates „steckt fest (Laufbremse)“ (1766, Archiv 19.11., 13:02)
  1739 (Gesamtbild 3.3 Nr. 5, Kern Büro „Rückläufer“): „fertig“ mit Commit → an den Prüfer; „fertig“ ohne Commit → an den Disponenten
  (nimmt es nicht an); erstes „nein“ und „Beleg fehlt“ → mit dem Satz an denselben Macher (wer zuletzt „fertig“ meldete; unbekannt →
  Disponent); „ja“ des Prüfers → Disponent (an den Chef nur nach diesem Ja); „Hinweis“ → Disponent (wie ein Eingang)
  Empfänger „Prüfer“ und „Disponent“ sind bis zur Umschaltung Diogenes und Ford (lauf.py, tools/1727-SCHARF)
Obergrenzen je Vorgang, über alle Aufträge gezählt (Rückmeldungen der Datei):
  A  zweites „nein, Auftrag“ oder drittes „nein“ (abgelehnter Auftrag = Runde; „Beleg fehlt“ und „nein, Auftrag“ zählen nicht)
  B  zweites „steckt fest“
→ Zustand „ruht, beim Chef“ in der Vorgangsdatei, Stand in der Vorgangsliste (solange sie Stände trägt), Zeile an Sokrates
  „an den Chef: Chefsache anlegen, nicht selbst lösen“ statt der normalen Weitergabe. Weitere Rückmeldungen danach: nur eingetragen.

Muster (erst nachsehen, wie andere es lösen): Wiederholgrenze mit Ablage (Dead-Letter-Queue: maxReceiveCount in Amazon SQS,
Celery max_retries): nach n Fehlversuchen geht die Nachricht nicht in die nächste Runde, sondern in eine Ablage, die ein Mensch sieht.
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import uebergabe as ue

SOKRATES = "Sokrates"
PLANER = os.environ.get("BORNIM_CHEFWORT_AN", "Arbeitsplaner")
RUHT = "ruht, beim Chef"
MAX_NEIN_AUFTRAG, MAX_NEIN, MAX_FEST = 2, 3, 2
LAUFBREMSE_NEIN = 2  # 1766 (Archiv 19.11., 13:02 Laufbremse): zweites „nein“ des Prüfers → „steckt fest“ an Sokrates; drittes ist Obergrenze A
SIGNAL = {"nein", "ja", "fertig", "frage", "hinweis"}
PRUEFER, DISPONENT = "Prüfer", "Disponent"  # 1739: neue Profile; lauf.py setzt bis tools/1727-SCHARF Diogenes, Ford ein
COMMIT = re.compile(r"\b[0-9a-f]{7,40}\b")
BLOCK = re.compile(r"(?m)^- \*\*(?P<zeit>[^*]+)\*\*, (?P<wer>[^\n]*?)(?: \(`[^`]*`\))?:\n> (?P<text>.*)$")


def worte(text):
    """Signalworte am Anfang (Meldung Prüfer: „nein“ + „steckt fest“ in einer Meldung)."""
    t = (text or "").strip()
    # Stempel davor („**Spike** [21.11., 20:41]“, „Spike [..]:“) zählt nicht (Hinweis Diogenes zu 1763)
    m = re.match(r"^\W*?(?:\*\*([A-ZÄÖÜ][\wäöüß]*(?: \d+)?)\*\*|([A-ZÄÖÜ][\wäöüß]*(?: \d+)?)(?=\s*\[\d))\s*(\[\d{1,2}\.\d{1,2}\.(?:\d{4})?,? ?\d{1,2}:\d{2}\])?\s*", t)
    if m and (m.group(3) or (m.group(1) and m.group(1).lower() not in SIGNAL)): t = t[m.end():]  # D329.2: fettes Signalwort bleibt
    t = re.sub(r"^\W+", "", t).lower()
    w = set()
    if re.match(r"nein,?\s+auftrag\b", t): w.add("nein, Auftrag")
    elif re.match(r"beleg fehlt\b", t): w.add("Beleg fehlt")
    elif re.match(r"wirkt nein\b", t): w.add("wirkt nein")
    elif re.match(r"nein\b", t): w.add("nein")
    elif re.match(r"steckt fest\b", t): w.add("steckt fest")
    elif re.match(r"frage\b", t): w.add("Frage")
    elif re.match(r"fertig\b", t): w.add("fertig")
    elif re.match(r"ja\b", t): w.add("ja")
    elif re.match(r"hinweis\b", t): w.add("Hinweis")
    if "nein" in w and re.search(r"\bsteckt fest\b", t): w.add("steckt fest")
    return w


def zaehlen(text):
    """Zählt die Signalworte der Rückmeldungen einer Vorgangsdatei."""
    z = {"nein, Auftrag": 0, "nein": 0, "steckt fest": 0}
    for m in re.finditer(r"(?m)^- \*\*[^*]+\*\*, [^\n]*:\n> (.*)$", ue.abschnitt(text, "Rückmeldungen")):
        for w in worte(m.group(1)):
            if w in z: z[w] += 1
    return z


def macher(text):
    """1739: wer zuletzt „fertig“ meldete (Rückmeldungen der Datei, ohne die gerade eingetragene); None, wenn keiner."""
    ms = [m for m in BLOCK.finditer(ue.abschnitt(text, "Rückmeldungen")) if "fertig" in worte(m.group("text"))]
    w = ms[-1].group("wer").strip() if ms else ""
    return w if w and w != "unbekannt" else None


def weitergabe(w, t, zeit, wer, text, vorher):
    """1739 (3.3 Nr. 5): Empfänger und Zeile für „fertig“, „nein“, „Beleg fehlt“, „ja“, „Hinweis“; (None, None) sonst."""
    satz = ue._rein(text)[:160]
    von = "Rückmeldung %s von %s" % (zeit, wer or "unbekannt")
    if w & {"nein", "Beleg fehlt"}:
        m = macher(vorher)
        wort = "nein" if "nein" in w else "Beleg fehlt"
        if m: return m, "Rückläufer (%s des Prüfers, %s): „%s“; nachbessern, dann `vorgang.py rueckmeldung` „fertig“ mit Commit (1739)" % (wort, von, satz)
        return DISPONENT, "Rückläufer (%s, %s), Macher unbekannt (kein „fertig“ in der Vorgangsdatei): an denselben Macher zurückgeben (1739)" % (wort, von)
    if "fertig" in w:
        if COMMIT.search(text): return PRUEFER, "prüfen: „fertig“ (%s): „%s“ (1739)" % (von, satz)
        return DISPONENT, "„fertig“ ohne Commit (%s): nicht annehmen, Macher nennt Commit und Beleg (1739)" % von
    if "ja" in w: return DISPONENT, "ja des Prüfers (%s): an den Chef vorlegen (Testbitte), nicht selbst nach main (1739)" % von
    if "Hinweis" in w: return DISPONENT, "Hinweis (%s): wie einen Eingang behandeln (1739)" % von
    return None, None


def ruht(text):
    return re.search(r"(?m)^Zustand: " + re.escape(RUHT), text) is not None


def eintragen(nr, text, wer, sid=""):
    """Ein Commit: Rückmeldung, ggf. Zustand und Übergabezeile. Rückgabe (Kennung oder None, Grund)."""
    text = (text or "").strip()
    if not text: raise ue.Fehler("Text nötig")
    zeit = ue.fmt(ue.jetzt())
    block = "- **%s**, %s%s:\n%s\n" % (zeit, wer or "unbekannt", (" (`%s`)" % sid) if sid else "", "\n".join("> " + z for z in text.splitlines()))
    w = worte(text)
    def f(alt):
        t = ue._mit_abschnitt(alt, nr)
        if block in t: return alt, (None, "schon eingetragen")
        schon = ruht(ue.abschnitt(t, "Rückmeldungen"))
        vorher = t
        t = ue.anhaengen(t, "Rückmeldungen", "Wörtlich, mit Zeit; trägt `vorgang.py rueckmeldung` ein (1763).", block)
        z = zaehlen(t)
        grund = None
        if not schon:
            if "nein, Auftrag" in w and z["nein, Auftrag"] >= MAX_NEIN_AUFTRAG: grund = "Obergrenze A: %d. „nein, Auftrag“" % z["nein, Auftrag"]
            elif "nein" in w and z["nein"] >= MAX_NEIN: grund = "Obergrenze A: %d. abgelehnter Auftrag" % z["nein"]
            elif "steckt fest" in w and z["steckt fest"] >= MAX_FEST: grund = "Obergrenze B: %d. „steckt fest“" % z["steckt fest"]
        if grund:
            t = t.replace("\n## Rückmeldungen\n", "\n## Rückmeldungen\n\nZustand: %s seit %s (%s, 1763)\n" % (RUHT, zeit, grund), 1)
            an, was = SOKRATES, "an den Chef: Chefsache anlegen, nicht selbst lösen (%s; Rückmeldung %s von %s)" % (grund, zeit, wer or "unbekannt")
        elif schon:
            an = was = None
        elif w & {"steckt fest", "Frage", "wirkt nein"}:
            an, was = SOKRATES, "%s: Rückmeldung %s von %s lesen (1763 C)" % (" und ".join(sorted(w & {"steckt fest", "Frage", "wirkt nein"})), zeit, wer or "unbekannt")
        elif "nein" in w and z["nein"] == LAUFBREMSE_NEIN:
            an, was = SOKRATES, "steckt fest (Laufbremse, %d. Nein; Chef 19.11., 13:02): Rückmeldung %s von %s lesen (1766)" % (z["nein"], zeit, wer or "unbekannt")
        elif "nein, Auftrag" in w:
            an, was = PLANER, "nein, Auftrag: Rückmeldung %s von %s lesen" % (zeit, wer or "unbekannt")
        else:
            an, was = weitergabe(w, t, zeit, wer, text, vorher)
        if not an: return t, (None, "ruht schon, nur eingetragen" if schon else "eingetragen, kein Signalwort zum Weitergeben")
        ks = [int(x["k"].rsplit("Ü", 1)[1]) for x in ue.zeilen(t)]
        k = "%s-Ü%d" % (nr, max(ks, default=0) + 1)
        return t.rstrip("\n") + "\n| %s | %s | %s | %s | offen |\n" % (k, an, ue._rein(was), zeit), (k, grund or "")
    return ue.atomar(nr, f, "Rückmeldung %s von %s (1763)" % (nr, wer or "unbekannt"))


def liste_ruht(nr, grund):
    """Solange die Vorgangsliste Stände trägt: Stand „ruht, beim Chef“ (Datei geändert, der Aufrufer committet sie)."""
    try:
        import vorgang
        vorgang.stand_setzen(nr, "%s (%s)" % (RUHT, grund.split(":")[0]))
        print("LISTE docs/LISTE-VORGAENGE.md geändert: committen und pushen")
    except SystemExit as e:
        print("LISTE nicht geändert (%s)" % e)
    except Exception as e:
        print("LISTE nicht geändert (%s)" % e)


def nein_waechter(nr, text):
    """1739 (7.1, Büro-Gegenüberstellung F3): Wiederholungswächter auch auf jedes Nein; Treffer „Systemlösung?“ in der Liste."""
    if not worte(text) & {"nein", "nein, Auftrag"}: return
    try:
        import vorgang, startbar, bereiche
        d = [x["bereich"] for x in startbar.zeilen_liste() if x["nr"] == nr and bereiche.gueltig(x["bereich"])]
        vor = vorgang.text_liste()
        vorgang.waechter(nr, text, d[0] if d else "B Abläufe")
        if vorgang.text_liste() != vor: print("LISTE docs/LISTE-VORGAENGE.md geändert: committen und pushen")
    except SystemExit as e:
        print("Wächter nicht gelaufen (%s)" % e)


def haupt(a):
    a = list(a[1:]) if a[:1] == ["rueckmeldung"] else list(a)
    wer = None
    if "--sitzung" in a:
        i = a.index("--sitzung"); wer = a[i + 1]; del a[i:i + 2]
    if len(a) != 2: sys.exit(__doc__)
    sid = ""
    try: sid = ue.sitzung()
    except ue.Fehler: pass
    if wer is None:
        import chefwort
        wer = chefwort._rolle_aus_besetzung(sid) or "unbekannt"
    try:
        k, grund = eintragen(a[0], a[1], wer, sid)
    except ue.Fehler as e:
        sys.exit("vorgang.py rueckmeldung: %s; nichts geschrieben" % e)
    if grund != "schon eingetragen":  # 1739 Lehrenbuch, „Roh sammeln“: ja mit Ursache, zweites Nein
        import lehren
        dt = open(os.path.join(ue.WURZEL, ue._pfad(a[0])), encoding="utf-8").read() if os.path.exists(os.path.join(ue.WURZEL, ue._pfad(a[0]))) else ""
        r = lehren.roh_aus_rueckmeldung(a[0], a[1], wer, dt, zaehlen(dt)["nein"])
        if r: print("LEHRENBUCH %s angehängt" % r)
    if not k:
        print("EINGETRAGEN %s: %s" % (a[0], grund))
        if grund != "schon eingetragen": nein_waechter(a[0], a[1])
        return
    zeile = [x for x in ue.zeilen(open(os.path.join(ue.WURZEL, ue._pfad(a[0])), encoding="utf-8").read()) if x["k"] == k]
    an = zeile[0]["an"] if zeile else "?"
    print("EINGETRAGEN %s, OFFEN %s an %s%s" % (a[0], k, an, (" (%s → %s)" % (grund, RUHT)) if grund else ""))
    if grund: liste_ruht(a[0], grund)
    nein_waechter(a[0], a[1])
    alt = {"Prüfer": "Diogenes", "Disponent": "Ford", PLANER: "Ford"}.get(an, "")  # 1739: bis zur Umschaltung (lauf.ALT_EMPFAENGER)
    for s in ue.besetzung(an) or (ue.besetzung(alt) if alt else []): print("WECKER %s | sieh in %s (%s)" % (s, a[0], k))
    if an == SOKRATES and not ue.besetzung(an):
        print("KEINE SITZUNG Sokrates läuft: lauf.py startet ihn (1763 C)")


if __name__ == "__main__":
    haupt(sys.argv[1:])
