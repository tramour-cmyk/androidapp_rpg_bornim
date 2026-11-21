#!/usr/bin/env python3
"""1763 (1727, Archiv 21.11., 14:37 A, B, C; prozesspruefung-21-11.md): Rückmeldung in die Vorgangsdatei, Obergrenzen A und B,
Weitergabe an Sokrates bei „steckt fest“, „Frage“, „wirkt nein“ (C; den Start macht lauf.py, Zeile „1763 C“).

  vorgang.py rueckmeldung NR "Text" [--sitzung ROLLE]

Schreibt die Rückmeldung wörtlich mit Zeit und Sitzung in docs/vorgang/NR.md (Abschnitt „Rückmeldungen“) und, je nach erstem Wort,
im selben Commit eine offene Übergabezeile (1760):
  „steckt fest“ (auch „nein … steckt fest“ des Prüfers), „Frage“, „wirkt nein“ → an Sokrates (C)
  „nein, Auftrag“ → an den Arbeitsplaner (Gesamtbild 6.1)
  andere Worte („fertig“, „ja“, „nein“, „Beleg fehlt“, „Hinweis“) werden nur eingetragen und gezählt; ihre Weitergabe baut 1739 (3.3 Nr. 5)
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


def worte(text):
    """Signalworte am Anfang (Meldung Prüfer: „nein“ + „steckt fest“ in einer Meldung)."""
    t = (text or "").strip()
    # Stempel davor („**Spike** [21.11., 20:41]“, „Spike [..]:“) zählt nicht (Hinweis Diogenes zu 1763)
    t = re.sub(r"^\W*(?:\*\*[^*\n]+\*\*\s*(?:\[\d{1,2}\.\d{1,2}\.,? ?\d{1,2}:\d{2}\])?|[A-ZÄÖÜ][\wäöüß]*(?: \d+)?\s*\[\d{1,2}\.\d{1,2}\.,? ?\d{1,2}:\d{2}\])\s*", "", t)
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
        elif "nein, Auftrag" in w:
            an, was = PLANER, "nein, Auftrag: Rückmeldung %s von %s lesen" % (zeit, wer or "unbekannt")
        else:
            an = was = None
        if not an: return t, (None, "ruht schon, nur eingetragen" if schon else "eingetragen, Weitergabe nach erstem Wort baut 1739")
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
    if not k:
        print("EINGETRAGEN %s: %s" % (a[0], grund))
        if grund != "schon eingetragen": nein_waechter(a[0], a[1])
        return
    zeile = [x for x in ue.zeilen(open(os.path.join(ue.WURZEL, ue._pfad(a[0])), encoding="utf-8").read()) if x["k"] == k]
    an = zeile[0]["an"] if zeile else "?"
    print("EINGETRAGEN %s, OFFEN %s an %s%s" % (a[0], k, an, (" (%s → %s)" % (grund, RUHT)) if grund else ""))
    if grund: liste_ruht(a[0], grund)
    nein_waechter(a[0], a[1])
    for s in ue.besetzung(an): print("WECKER %s | sieh in %s (%s)" % (s, a[0], k))
    if an == SOKRATES and not ue.besetzung(an):
        print("KEINE SITZUNG Sokrates läuft: lauf.py startet ihn (1763 C)")


if __name__ == "__main__":
    haupt(sys.argv[1:])
