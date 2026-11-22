#!/usr/bin/env python3
"""1762 Haken D (1727, Archiv 21.11., 14:37 D; Gesamtbild 3.3 Fassung 2 Nr. 7): Chefwort aus fremder Sitzung in die Vorgangsdatei.

Sagt der Chef in einer Sitzung etwas zu einem Vorgang, der einer anderen Rolle gehört (Freigabe, Fund, Antwort auf eine Frage),
trägt der Haken es wörtlich mit Zeit und Sitzung in docs/vorgang/NR.md ein (Abschnitt „Chefworte“) und legt im selben Commit
eine offene Übergabezeile an den Arbeitsplaner an (1760, `uebergabe.py`); keine Fachkraft baut es am Prüfer vorbei.

  vorgang.py chefwort NR "Wortlaut" [--zeit "TT.MM., HH:MM"] [--sitzung ROLLE]   von Hand (verpasstes Chefwort, Rückfrage im Chat)
  neustart-haken.py prompt                     ruft haken() bei jeder Nachricht (UserPromptSubmit); schreibt im Hintergrund,
                                               damit der Haken unter 10 s bleibt; Fehler meldet die nächste Nachricht

Welche Vorgänge: Nummern mit drei oder vier Ziffern (auch 1270.6, Rückfrage 1727a → 1727), die in der Vorgangsliste stehen und
nicht dieser Sitzung gehören (Besitzer = ihre Rolle, oder sie hält eine angenommene Übergabezeile des Vorgangs); „Build N“, „tN“, „tN.k“ = alle Vorgänge mit Build N. Uhrzeiten, Daten, Beträge zählen nicht.
Nur Worte des Chefs: Nachrichten anderer Sitzungen beginnen mit „**Name** [“ (CLAUDE.md 7), Startaufträge mit „Du bist **“,
Systemmeldungen mit „<“ oder „[SYSTEM“; im Protokoll markierte Nachrichten (origin, nicht vom Menschen) ebenso.

Scharf erst mit der Umschaltung 1727 (Datei tools/1727-SCHARF, legt der Umschalt-Commit an; Sokrates 20:14: Liste erst dort
umstellen); vorher tut haken() nichts, `vorgang.py chefwort` geht immer.

Muster (erst nachsehen, wie andere es lösen): Ereignisprotokoll statt Zuruf (Event Sourcing, Slack-/GitHub-Webhook ins Ticket):
das Wort wird am Ort des Vorgangs angehängt, nicht in der Sitzung gemerkt; Zustellung über die Warteschlange 1760 mit Quittung;
gleicher Wortlaut zur gleichen Minute wird nicht doppelt geschrieben (Wiederholung harmlos, wie die Kennung im Wecker).
"""
import json, os, re, subprocess, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import uebergabe as ue

AN = os.environ.get("BORNIM_CHEFWORT_AN", "Arbeitsplaner")
SCHARF = os.path.join(ue.WURZEL, "tools", "1727-SCHARF")
LANG = 6000  # Zeichen je Eintrag; längeres steht im Protokoll der Sitzung
ROLLEN = r"(Perikles|Homer|Sokrates|Diogenes|Ford|Tom|Jerry|Spike|Tuffy)"
try:  # 1739 Rufnamen: „**Anna** [21.11., 21:40]“ ist eine Sitzung, nicht der Chef
    import rufname
    ROLLEN = r"(Perikles|Homer|Sokrates|Diogenes|Ford|Tom|Jerry|Spike|Tuffy|%s)" % "|".join(sorted(rufname.ALLE))
except Exception:
    pass
FEHLER = os.environ.get("BORNIM_CHEFWORT_FEHLER", "/tmp/bornim-chefwort-fehler.txt")


def vom_chef(text, pfad=None):
    """False für Nachrichten anderer Sitzungen, Startaufträge und Systemmeldungen."""
    t = (text or "").lstrip()
    if not t:
        return False
    if t.startswith(("<", "[SYSTEM", "Du bist **", "## Kern", "Dein Rufname:")) or re.match(r"\W{0,3}\*\*" + ROLLEN + r"( \d)?\*\*\s*\[", t):
        return False
    if re.match(r"(Weiter( in)?|Auftrag|sieh in)\b", t):
        return False
    if pfad and os.path.exists(pfad):  # Protokoll: dieselbe Nachricht mit origin (task-notification, Sitzung) → nicht vom Chef
        try:
            kopf = t[:200]
            with open(pfad, encoding="utf-8", errors="replace") as f:
                zeilen = f.readlines()[-40:]
            for z in reversed(zeilen):
                d = json.loads(z)
                inhalt = d.get("content") if d.get("type") == "queue-operation" else (d.get("message") or {}).get("content") if d.get("type") == "user" else None
                if isinstance(inhalt, list):
                    inhalt = " ".join(x.get("text", "") for x in inhalt if isinstance(x, dict))
                if isinstance(inhalt, str) and inhalt.lstrip()[:200] == kopf:
                    art = (d.get("origin") or {}).get("kind")
                    return art in (None, "human", "user")
        except Exception:
            pass
    return True


def vorgaenge(text):
    """Nummern der Vorgangsliste, die der Text nennt: {nr: zeile}."""
    import startbar
    liste = {d["nr"]: d for d in startbar.zeilen_liste()}
    t = re.sub(r"\b\d{1,2}\.\d{1,2}\.(\d{2,4})?", " ", text or "")        # Daten 21.11., 21.11.2026
    t = re.sub(r"\b\d{1,2}:\d{2}\b", " ", t)                             # Uhrzeiten
    t = re.sub(r"\d+(,\d+)?\s*(€|\$|Euro|Dollar|%|Tsd|KB|MB|cm|ms|s\b|min\b)", " ", t)
    aus = {}
    for m in re.finditer(r"(?i)(?:\bBuild\s+|(?<![\w.])t)(\d{2,4})(?:\.\d+)?(?![\d])", t):
        for d in liste.values():
            if str(d.get("build") or "").strip() == m.group(1):
                aus[d["nr"]] = d
    t = re.sub(r"(?i)(\bBuild\s+|(?<![\w.])t)\d{2,4}(\.\d+)?", " ", t)
    for m in re.finditer(r"(?<![\d.,/#\w-])(\d{3,4}(?:\.\d+)?)[a-z]?(?!\d|,\d|\.\d)", t):
        nr = m.group(1)
        while nr not in liste and "." in nr:
            nr = nr.rsplit(".", 1)[0]
        if nr in liste:
            aus[nr] = liste[nr]
    return aus


def eigen(nr, d, wer, sid):
    """Eigener Vorgang: Besitzer = Rolle dieser Sitzung (Liste bis zur Umschaltung) oder diese Sitzung hält eine angenommene
    Übergabezeile in docs/vorgang/NR.md (nach der Umschaltung hat die Liste keinen Besitzer mehr, 1727-muster/LISTE-VORGAENGE.md)."""
    rolle = re.sub(r" \d$", "", wer or "")
    if rolle and d.get("besitzer") == rolle:
        return True
    try:
        t = open(os.path.join(ue.WURZEL, ue._pfad(nr)), encoding="utf-8").read()
    except OSError:
        return False
    return bool(sid) and any((ue.ANG.match(z["z"]) or {}) and ue.ANG.match(z["z"]).group("sid") == sid for z in ue.zeilen(t))


def eintragen(nr, wort, zeit, wer, sid=""):
    """Chefwort und offene Zeile an AN in einem Commit. Rückgabe: Kennung der Zeile oder None (schon eingetragen)."""
    wort = (wort or "").strip()
    if len(wort) > LANG:
        wort = wort[:LANG] + " … (gekürzt; ganz im Protokoll der Sitzung)"
    zitat = "\n".join("> " + z for z in wort.splitlines()) or "> (leer)"
    kopf = "- **%s**, Chef in Sitzung %s%s:" % (zeit, wer or "unbekannt", (" (`%s`)" % sid) if sid else "")
    block = kopf + "\n" + zitat + "\n"
    def f(alt):
        t = ue._mit_abschnitt(alt, nr)
        if block in t:
            return alt, None
        t = ue.anhaengen(t, "Chefworte", "Wörtlich, mit Zeit; trägt `chefwort.py` ein (Haken D, 1762).", block)
        ks = [int(z["k"].rsplit("Ü", 1)[1]) for z in ue.zeilen(t)]
        k = "%s-Ü%d" % (nr, max(ks, default=0) + 1)
        was = ue._rein("Chefwort %s aus Sitzung %s lesen (Abschnitt Chefworte)" % (zeit, wer or "unbekannt"))
        return t.rstrip("\n") + "\n| %s | %s | %s | %s | offen |\n" % (k, AN, was, ue.fmt(ue.jetzt())), k
    return ue.atomar(nr, f, "Chefwort %s aus Sitzung %s (Haken D, 1762)" % (nr, wer or "unbekannt"))


def melden(nr, k):
    if not k:
        print("SCHON EINGETRAGEN %s: gleicher Wortlaut zur gleichen Zeit" % nr)
        return
    print("CHEFWORT %s eingetragen, OFFEN %s an %s" % (nr, k, AN))
    ue.wecker(nr, k, AN)  # 1760: läuft keine Sitzung, Wecker an den Disponenten


def _rolle_aus_besetzung(sid):
    try: t = open(os.path.join(ue.WURZEL, "docs", "ARBEIT-BESETZUNG.md"), encoding="utf-8").read()
    except OSError: return ""
    for z in t.splitlines():
        f = [x.strip() for x in z.split("|")]
        if sid and len(f) > 3 and sid in f[2]: return f[1]
    return ""


def haken(eingabe, wer):
    """UserPromptSubmit: prüft und startet das Eintragen im Hintergrund; gibt die Zeilen für die Sitzung aus."""
    try:
        alt = open(FEHLER, encoding="utf-8").read().strip()
        os.remove(FEHLER)
        if alt:
            print("Haken D (1762): Eintragen fehlgeschlagen, von Hand nachholen (`vorgang.py chefwort NR \"Wortlaut\" --zeit …`):\n" + alt)
    except OSError:
        pass
    if not os.path.exists(SCHARF):
        return []
    text = str(eingabe.get("prompt") or "")
    if not vom_chef(text, eingabe.get("transcript_path")):
        return []
    sid = ""
    try:
        sid = ue.sitzung()
    except ue.Fehler:
        pass
    nrs = [nr for nr, d in vorgaenge(text).items() if not eigen(nr, d, wer, sid)]
    if not nrs:
        return []
    zeit = ue.fmt(ue.jetzt())
    pfad = os.path.join("/tmp", "bornim-chefwort-%d.txt" % os.getpid())
    open(pfad, "w", encoding="utf-8").write(text)
    subprocess.Popen([sys.executable, os.path.abspath(__file__), "hintergrund", pfad, zeit, wer or "unbekannt", sid] + nrs,
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True, cwd=ue.WURZEL)
    print("Haken D (1762): Chefwort zu %s gehört nicht dieser Sitzung (%s); wird wörtlich in docs/vorgang/<Nr>.md eingetragen, "
          "offene Zeile an %s (`vorgang.py offen %s`). Nicht selbst bauen; eigener Anteil wie sonst." % (", ".join(nrs), wer or "Rolle unbekannt", AN, AN))
    return nrs


def hintergrund(pfad, zeit, wer, sid, nrs):
    text = open(pfad, encoding="utf-8").read()
    fehl = []
    for nr in nrs:
        try:
            eintragen(nr, text, zeit, wer, sid)
        except Exception as e:
            fehl.append("%s (%s): %s" % (nr, zeit, str(e)[:200]))
    if fehl:
        with open(FEHLER, "a", encoding="utf-8") as f:
            f.write("\n".join(fehl) + "\n")
    else:
        os.remove(pfad)


def haupt(a):
    if a[:1] == ["hintergrund"]:
        return hintergrund(a[1], a[2], a[3], a[4], a[5:])
    a = list(a[1:]) if a[:1] == ["chefwort"] else list(a)
    zeit, wer = None, None
    for opt in ("--zeit", "--sitzung"):
        if opt in a:
            i = a.index(opt); v = a[i + 1]; del a[i:i + 2]
            if opt == "--zeit": zeit = v
            else: wer = v
    if len(a) != 2:
        sys.exit(__doc__)
    if zeit and not re.fullmatch(r"\d\d\.\d\d\., \d\d:\d\d", zeit):
        sys.exit("vorgang.py chefwort: --zeit in der Form „TT.MM., HH:MM“")
    sid = ""
    try: sid = ue.sitzung()
    except ue.Fehler: pass
    if wer is None:
        wer = _rolle_aus_besetzung(sid)
    try:
        melden(a[0], eintragen(a[0], a[1], zeit or ue.fmt(ue.jetzt()), wer or "unbekannt", sid))
    except ue.Fehler as e:
        sys.exit("vorgang.py chefwort: %s; nichts geschrieben" % e)


if __name__ == "__main__":
    haupt(sys.argv[1:])
