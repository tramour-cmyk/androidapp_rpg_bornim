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
  (nimmt es nicht an; Routine, Titel „(Routine, Auftrag …)“: „fertig“ ohne Commit → Disponent legt die Vorschläge an und schließt, 1789); erstes „nein“ und „Beleg fehlt“ → mit dem Satz an denselben Macher (wer zuletzt „fertig“ meldete; unbekannt →
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
SIGNAL = {"nein", "ja", "fertig", "frage", "hinweis", "abgebrochen"}
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
    elif re.match(r"abgebrochen\b", t): w.add("abgebrochen")  # 1782: Kern Arbeitsplaner Feld 7
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


def ist_routine(nr):
    """1789: Vorgang nr ist eine Routine (Titel „(Routine, Auftrag …)“, auftrag.routine); sie baut nichts, „fertig“ ohne Commit gilt."""
    try:
        import auftrag, startbar
        return any(d["nr"] == nr and auftrag.routine(d["titel"]) for d in startbar.vorgangsliste(startbar.lesen(startbar.LISTE)))
    except Exception:
        return False


def ist_werkzeug(nr):
    """1790: Vorgang nr ist ein Werkzeug (Bereich B, 724 A); es geht nach grünem Lauf ohne Test des Chefs nach main (1311)."""
    try:
        import startbar
        return any(d["nr"] == nr and d.get("bereich", "").startswith("B ") for d in startbar.vorgangsliste(startbar.lesen(startbar.LISTE)))
    except Exception:
        return False


def weitergabe(w, t, zeit, wer, text, vorher, routine=False, werkzeug=False):
    """1739 (3.3 Nr. 5): Empfänger und Zeile für „fertig“, „nein“, „Beleg fehlt“, „ja“, „Hinweis“; (None, None) sonst."""
    satz = ue._rein(text)[:160]
    von = "Rückmeldung %s von %s" % (zeit, wer or "unbekannt")
    if w & {"nein", "Beleg fehlt"}:
        m = macher(vorher)
        wort = "nein" if "nein" in w else "Beleg fehlt"
        if m: return m, "Rückläufer (%s des Prüfers, %s): „%s“; nachbessern, dann `vorgang.py rueckmeldung` „fertig“ mit Commit (1739)" % (wort, von, satz)
        return DISPONENT, "Rückläufer (%s, %s), Macher unbekannt (kein „fertig“ in der Vorgangsdatei): an denselben Macher zurückgeben (1739)" % (wort, von)
    if "fertig" in w:
        if routine and not COMMIT.search(text):  # 1789: Rundblick endet ohne Commit (routine-rundblick.md Teil A „Ergebnis“)
            return DISPONENT, "Routine fertig (%s): Vorschläge aus den offenen Übergabezeilen als Vorgänge anlegen, dann `vorgang.py schliessen` (1789)" % von
        if COMMIT.search(text): return PRUEFER, "prüfen: „fertig“ (%s): „%s“ (1739)" % (von, satz)
        return DISPONENT, "„fertig“ ohne Commit (%s): nicht annehmen, Macher nennt Commit und Beleg (1739)" % von
    if "ja" in w and werkzeug:  # 1790 (Sokrates 1727 Nachprüfung 22:20): Werkzeug, keine Testbitte an den Chef
        return DISPONENT, "ja des Prüfers (%s): Werkzeug (Bereich B), kein Test des Chefs (1311): liegt der Zweig nicht auf main, mischt der Macher jetzt; dann `vorgang.py fertig`" % von
    if "ja" in w: return DISPONENT, "ja des Prüfers (%s): an den Chef vorlegen (Testbitte), nicht selbst nach main (1739)" % von
    if "Hinweis" in w: return DISPONENT, "Hinweis (%s): wie einen Eingang behandeln (1739)" % von
    return None, None


def _datei(nr):
    """Vorgangsdatei nach dem Eintrag: lokal, sonst von origin/main (1789: neue Datei, Notizkopie mit ungepushten Änderungen
    zog nicht nach; Absturz FileNotFoundError nach erfolgreichem Push, ein zweiter Aufruf trug doppelt ein)."""
    p = os.path.join(ue.WURZEL, ue._pfad(nr))
    if os.path.exists(p): return open(p, encoding="utf-8").read()
    import subprocess
    r = subprocess.run(["git", "-C", ue.WURZEL, "show", "origin/main:" + ue._pfad(nr)], capture_output=True, text=True)
    return r.stdout if r.returncode == 0 else ""


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
            an, was = SOKRATES, "%s: Rückmeldung %s von %s lesen (1763 C)%s" % (" und ".join(sorted(w & {"steckt fest", "Frage", "wirkt nein"})), zeit, wer or "unbekannt",
                                                                            "; gelöst: `vorgang.py warte %s –`" % nr if "steckt fest" in w else "")
        elif "nein" in w and z["nein"] == LAUFBREMSE_NEIN:
            an, was = SOKRATES, "steckt fest (Laufbremse, %d. Nein; Chef 19.11., 13:02): Rückmeldung %s von %s lesen (1766)" % (z["nein"], zeit, wer or "unbekannt")
        elif "nein, Auftrag" in w:
            an, was = PLANER, "nein, Auftrag: Rückmeldung %s von %s lesen" % (zeit, wer or "unbekannt")
        else:
            an, was = weitergabe(w, t, zeit, wer, text, vorher, "fertig" in w and ist_routine(nr), "ja" in w and ist_werkzeug(nr))
        if not an: return t, (None, "ruht schon, nur eingetragen" if schon else "eingetragen, kein Signalwort zum Weitergeben")
        ks = [int(x["k"].rsplit("Ü", 1)[1]) for x in ue.zeilen(t)]
        k = "%s-Ü%d" % (nr, max(ks, default=0) + 1)
        return t.rstrip("\n") + "\n| %s | %s | %s | %s | offen |\n" % (k, an, ue._rein(was), zeit), (k, grund or "")
    return ue.atomar(nr, f, "Rückmeldung %s von %s (1763)" % (nr, wer or "unbekannt"))


def liste_atomar(nr, stand, warte_dazu=(), nachricht=""):
    """1800 (Falltest Lauf 2, D10/D11): Stand und „wartet auf“ der Zeile nr in einem eigenen Commit auf origin/main setzen, wie
    uebergabe.atomar (vorher nur lokal, ungepusht: lauf.py startete die Fachkraft weiter). stand: Text oder Funktion(alter Stand, Wort).
    Rückgabe: Text der Meldung."""
    import startbar
    def f(alt):
        if not alt.strip(): return alt, "Liste nicht gelesen"
        d = next((x for x in startbar.vorgangsliste(alt) if x["nr"] == nr), None)
        if not d: return alt, "%s nicht in der Liste" % nr
        n = dict(d, stand=stand(d["stand"], d["wort"]) if callable(stand) else stand,
                 warte=list(d["warte"]) + [w for w in warte_dazu if w not in d["warte"]])
        L = alt.split("\n"); L[d["i"]] = startbar.zeile_text(n)
        return "\n".join(L), "Stand „%s“%s" % (n["stand"], (", wartet auf " + ", ".join(n["warte"])) if n["warte"] else "")
    return ue.atomar(nr, f, nachricht or "%s: Stand nach Rückmeldung (1800)" % nr, pfad="docs/" + startbar.LISTE)


def fest_stand(alt, wort):
    """Erstes „steckt fest“: Wort bleibt, Zusatz „steckt fest“ (liegt.stand_von zählt es als Stand; 14.2.12)."""
    return alt if "steckt fest" in (alt or "") else "%s, steckt fest" % (wort or "startbar")


def liste_ruht(nr, grund):
    """Solange die Vorgangsliste Stände trägt: Stand „ruht, beim Chef“, gepusht (1800)."""
    try: print("LISTE %s: %s (gepusht)" % (nr, liste_atomar(nr, "%s (%s)" % (RUHT, grund.split(":")[0]), (), "%s: ruht, beim Chef (%s, 1763 B)" % (nr, grund))))
    except ue.Fehler as e: print("LISTE nicht geändert (%s); von Hand: vorgang.py stand %s \"%s\"" % (e, nr, RUHT))


def liste_fest(nr):
    """1800: erstes „steckt fest“ → Zusatz „steckt fest“ und „wartet auf Sokrates“, gepusht; lauf.py startet die Fachkraft nicht mehr."""
    try: print("LISTE %s: %s (gepusht)" % (nr, liste_atomar(nr, fest_stand, (SOKRATES,), "%s: steckt fest, wartet auf Sokrates (1763 C, 1800)" % nr)))
    except ue.Fehler as e: print("LISTE nicht geändert (%s); von Hand: vorgang.py warte %s Sokrates" % (e, nr))


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
        dt = _datei(a[0])
        r = lehren.roh_aus_rueckmeldung(a[0], a[1], wer, dt, zaehlen(dt)["nein"])
        if r: print("LEHRENBUCH %s angehängt" % r)
    if "abgebrochen" in worte(a[1]) and sid:  # 1782: eigene angenommene Zeilen wie nach abgelaufener Frist
        try:
            for kz, neu in ue.abgebrochen(a[0], sid) or []:
                print("ÜBERGABE %s: %s%s" % (kz, neu, " (lauf.py gibt es an Sokrates)" if neu.startswith(ue.FEST) else " (lauf.py startet neu)"))
                if neu.startswith(ue.FEST):
                    ue.uebergabe(a[0], SOKRATES, "steckt fest: Übergabe %s zweimal ohne Ergebnis (abgebrochen; 1782); gelöst: `vorgang.py warte %s –`" % (kz, a[0]))
                    liste_fest(a[0])
        except ue.Fehler as e:
            print("ÜBERGABE nicht zurückgegeben (%s); von Hand: vorgang.py freigeben" % e)
    if not k:
        print("EINGETRAGEN %s: %s" % (a[0], grund))
        if grund != "schon eingetragen": nein_waechter(a[0], a[1])
        return
    zeile = [x for x in ue.zeilen(_datei(a[0])) if x["k"] == k]
    an = zeile[0]["an"] if zeile else "?"
    print("EINGETRAGEN %s, OFFEN %s an %s%s" % (a[0], k, an, (" (%s → %s)" % (grund, RUHT)) if grund else ""))
    if grund: liste_ruht(a[0], grund)
    elif an == SOKRATES and "steckt fest" in worte(a[1]): liste_fest(a[0])  # 1800
    nein_waechter(a[0], a[1])
    alt = {"Prüfer": "Diogenes", "Disponent": "Ford", PLANER: "Ford"}.get(an, "")  # 1739: bis zur Umschaltung (lauf.ALT_EMPFAENGER)
    if an == SOKRATES and not ue.besetzung(an):
        print("KEINE SITZUNG Sokrates läuft: lauf.py startet ihn (1763 C)")
    ue.wecker(a[0], k, an, alt)  # 1760: läuft keine Sitzung, Wecker an den Disponenten


if __name__ == "__main__":
    haupt(sys.argv[1:])
