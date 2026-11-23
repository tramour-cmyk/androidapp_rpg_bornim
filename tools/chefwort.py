#!/usr/bin/env python3
"""1762 Haken D (1727, Archiv 21.11., 14:37 D; Gesamtbild 3.3 Fassung 2 Nr. 7): Chefwort aus fremder Sitzung in die Vorgangsdatei.

Sagt der Chef in einer Sitzung etwas zu einem Vorgang, der einer anderen Rolle gehört (Freigabe, Fund, Antwort auf eine Frage),
trägt der Haken es wörtlich mit Zeit und Sitzung in docs/vorgang/NR.md ein (Abschnitt „Chefworte“) und legt im selben Commit
eine offene Übergabezeile an den Arbeitsplaner an (1760, `uebergabe.py`); keine Fachkraft baut es am Prüfer vorbei. Bei Freigabe
des Builds („gut“, „passt“, „freigegeben“) oder Ergebnis nach Checkliste 11, 12 geht die Zeile an den Disponenten, der den
Build-Macher startet (3.3 Nr. 7, L-U15, 1782).
1976 (1566): ruht der Vorgang („Zustand: ruht, beim Chef“ in NR.md, Stand „ruht“ in der Liste), hebt das Chefwort beides im
selben Commit auf („Zustand: aufgehoben …“, Liste „startbar, Chefwort ZEIT“); gelingt das nicht, Fehler, nichts geschrieben.

  vorgang.py chefwort NR "Wortlaut" [--zeit "TT.MM., HH:MM"] [--sitzung ROLLE] [--an ROLLE]   von Hand (verpasstes Chefwort,
                                               Rückfrage im Chat); --an setzt den Empfänger (1876)
  neustart-haken.py prompt                     ruft haken() bei jeder Nachricht (UserPromptSubmit); schreibt im Hintergrund,
                                               damit der Haken unter 10 s bleibt; Fehler meldet die nächste Nachricht

Welche Vorgänge: Nummern mit drei oder vier Ziffern (auch 1270.6, Rückfrage 1727a → 1727), die in der Vorgangsliste stehen und
nicht dieser Sitzung gehören (Besitzer = ihre Rolle, oder sie hält eine angenommene Übergabezeile des Vorgangs); „Build N“, „tN“, „tN.k“ = alle Vorgänge mit Build N. Uhrzeiten, Daten, Beträge zählen nicht.
Nur Worte des Chefs: Nachrichten anderer Sitzungen beginnen mit „**Name** [“ (CLAUDE.md 7), Startaufträge mit „Du bist **“,
Systemmeldungen mit „<“ oder „[SYSTEM“. 1962: dazu Erlaubnisliste: nur mit belegter Herkunft Mensch im Protokoll (Zeile „user“
mit origin human oder ohne, ohne promptSource); die erste Nachricht einer Sitzung nie; unbelegte Herkunft meldet die nächste Nachricht.

Scharf erst mit der Umschaltung 1727 (Datei tools/1727-SCHARF, legt der Umschalt-Commit an; Sokrates 20:14: Liste erst dort
umstellen); vorher tut haken() nichts, `vorgang.py chefwort` geht immer.

Muster (erst nachsehen, wie andere es lösen): Ereignisprotokoll statt Zuruf (Event Sourcing, Slack-/GitHub-Webhook ins Ticket):
das Wort wird am Ort des Vorgangs angehängt, nicht in der Sitzung gemerkt; Zustellung über die Warteschlange 1760 mit Quittung;
gleicher Wortlaut zur gleichen Minute wird nicht doppelt geschrieben (Wiederholung harmlos, wie die Kennung im Wecker).
"""
import json, os, re, subprocess, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import uebergabe as ue

AN = os.environ.get("BORNIM_CHEFWORT_AN", "Arbeitsplaner")
DISPONENT = "Disponent"  # 1782 (3.3 Nr. 7, L-U15): Freigabe des Builds oder Ergebnis nach Checkliste 11, 12 startet den Build-Macher
FREIGABE = re.compile(r"(?i)\b(passt|freigegeben)\b|^\W*gut\b")  # Profil Technik 13; „gut“ nur als erstes Wort (sonst zu oft im Satz)
# 1903 (D340.1): Verneinung im selben Satzteil („passt nicht“, „noch nicht freigegeben“, „gut ist das nicht“) ist keine Freigabe
VERNEINT = re.compile(r"(?i)\b(nicht|nichts|kein\w*|nie)\b")
TEIL = re.compile(r"(?i)[,.;:!?\n–—]|\b(?:aber|doch|sondern|jedoch)\b")
# 1908 (D341.1): Einschränkung („Passt, aber Schatten zu dunkel“, „mit Einschränkungen“, „bis auf“) oder Frage („Passt das?“)
# ist keine Freigabe des Builds; im Zweifel Arbeitsplaner
EINSCHRAENKUNG = re.compile(r"(?i)\b(aber|doch|jedoch|sondern|allerdings|außer|ausser|bis auf|nur noch|einschränkung\w*|vorbehalt\w*)\b|\?")
# Checkliste 11: „- n.k ✓“, „- n.k ✗ <Fund>“, „- Rest ✓“. Ein 👍/👎 gilt nur für einen Punkt (Profil Technik 13): Fund, Arbeitsplaner;
# die 👍/👎 der Bild- und Filmpunkte trägt das Werkzeug ins Ergebnis, erst das Ergebnis geht an den Disponenten (1903)
ERGEBNIS = re.compile(r"(?m)^\W*(\d+(\.\d+)?|Rest)\s*[✓✗]")
# 1876 (Lauf 3 Disponent L5): Chefwort zum Betrieb („weniger laufen“, Starts, Laufsperre, Guthaben) geht an Sokrates (Abläufe per
# Vorentscheid; er setzt die Laufsperre in der Form aus 1804), ebenso jedes Chefwort zu einem Vorgang im Bereich „B Abläufe“
# 1876; 1915 (D345.2): „weniger laufen“ trifft auch Spielfunde („Die Wachen sollen nicht mehr laufen“): diese schwachen Betriebswörter
# zählen nur ohne Vorgang oder bei einem Vorgang im Bereich B; die starken (Starts, Sitzungen, Laufsperre, Guthaben, nur Muss/Rückläufer) immer.
BETRIEB = re.compile(r"(?i)\b(weniger|mehr|nicht mehr|keine)\s+(starts|sitzungen)\b|\blaufsperre\b|\bguthaben\b|\bnur\s+(noch\s+)?(muss|rückläufer)\b")
BETRIEB_SCHWACH = re.compile(r"(?i)\b(weniger|mehr|nicht mehr|keine)\s+(laufen|starten)\b")
SOKRATES = "Sokrates"
BUILD_IM_TEXT = re.compile(r"(?i)\bBuild\s+\d|(?<![\w.])t\d{2,4}\b")


def freigabe(w):
    """1903, 1908: Freigabewort, keine Einschränkung oder Frage („Passt, aber …“, „Passt das?“) und kein Satzteil, der eins
    verneint („Gut gemeint, aber nicht freigegeben“); im Zweifel Arbeitsplaner,
    denn eine falsche Freigabe führt zusammen, ein falscher Fund kostet nur eine Weitergabe."""
    w = w or ""
    if not FREIGABE.search(w) or EINSCHRAENKUNG.search(w): return False
    return not any(t and re.search(r"(?i)\b(passt|freigegeben|gut)\b", t) and VERNEINT.search(t) for t in TEIL.split(w))


# 1948 (Falltest Lauf 4 P1, P7): Ablehnung ohne „nein“ am Anfang („Also fail.“, „Wieder daneben.“, „kein Unterschied zwischen alt und
# neu“, „Film t300.11 Fail“); ✗ hinter einem Prüfpunkt auch mitten im Satz („Nein des Chefs: ‚299.3 ✗‘“)
ABLEHNUNG = re.compile(r"(?i)\bfail\b|\bnicht besser\b|\bwieder falsch\b|(?:\d+(?:\.\d+)?|Rest)\s*✗")
# 1951 (D386.1): „daneben“ ist auch Ortsangabe („Die Truhe sitzt, daneben fehlt die Fackel.“, „Licht ok, daneben die Bank etwas höher.“,
# „Die Fackel steht daneben.“); als Urteil nur am Ende des Satzteils und allein oder nach einem Urteilswort („Wieder daneben.“,
# „Das ist daneben.“, „Total daneben!“)
DANEBEN = re.compile(r"(?i)(?:^|[,.;:!?\n–—]|\b(?:wieder|total|völlig|komplett|voll|leider|ganz|echt|schon|gründlich|ist|war|sind|waren|alles|geht|ging|gegangen))\s*daneben\s*(?:[,.;:!?\n–—)]|$)")
# 1951: „kein Unterschied“ zählt nicht, wenn derselbe Satz es lobt („Kein Unterschied zu gestern beim Laden, gut so.“)
UNTERSCHIED = re.compile(r"(?i)\bkein(?:en)? unterschied\b")
LOB = re.compile(r"(?i)\b(gut so|gut|passt|prima|super|schön|bestens|perfekt|top|ok|okay|in ordnung|wie gewünscht|wie gewollt|soll so)\b")

def _ablehnung(w):
    if ABLEHNUNG.search(w) or DANEBEN.search(w): return True
    for satz in re.split(r"[.!?\n]+", w):
        if UNTERSCHIED.search(satz):
            lob = [t for t in TEIL.split(satz) if t and LOB.search(t) and not VERNEINT.search(UNTERSCHIED.sub("", t))]
            if not lob: return True
    return False

def chef_nein(w):
    """1872: Chefwort lehnt ab (zählt für Obergrenze A wie ein „nein“ des Prüfers): beginnt mit „nein“, 👎, Ergebnis mit ✗ oder ein
    verneintes Freigabewort („passt nicht“, „nicht freigegeben“); eine Freigabe ohne Verneinung nie. 1948: auch ABLEHNUNG
    („fail“, „daneben“, „kein Unterschied“) irgendwo im Wortlaut; 1951: „daneben“ nur als Urteil, nicht als Ortsangabe,
    „kein Unterschied“ nicht, wenn derselbe Satz lobt."""
    w = w or ""
    if freigabe(w): return False
    if re.match(r"(?i)^\W*nein\b", w) or "👎" in w or re.search(r"(?m)^\W*(\d+(\.\d+)?|Rest)\s*✗", w) or _ablehnung(w): return True
    return any(t and re.search(r"(?i)\b(passt|freigegeben|gut)\b", t) and VERNEINT.search(t) for t in TEIL.split(w))


def bisher_nein(bisher):
    """1948: Feld „Bisher“ eines Auftrags nennt ein Nein des Chefs: „Nein des Chefs“, „Chef-Nein“, „👎 des Chefs“ oder ein Zitat
    („…“) in einem Satz mit „Chef“, das chef_nein ist („Chef 18.11., 17:38: „… Also fail.““)."""
    b = bisher or ""
    if re.search(r"(?i)\bnein des chefs\b|\bchef-?nein\b|👎 des chefs|\bchef\b[^.\n]{0,40}👎", b): return True
    for m in re.finditer(r'„[^“”„]*[“”]|"[^"\n]*"', b):  # Zitat, davor im selben Absatz binnen 60 Zeichen „Chef“
        vor = b[max(0, m.start() - 60):m.start()].split("\n")[-1]
        if re.search(r"\bChef", vor) and not re.search(r"[„“”\"]", vor) and chef_nein(m.group(0).strip("„“”\"")): return True
    return False


def _build_am_vorgang(nr, d):
    if d is None and nr:
        try:
            import startbar
            d = next((x for x in startbar.zeilen_liste() if x["nr"] == nr), None)
        except Exception: d = None
    return bool(d and str(d.get("build") or "").strip() not in ("", "-", "–"))


def _bereich(nr, d):
    if d is None and nr:
        try:
            import startbar
            d = next((x for x in startbar.zeilen_liste() if x["nr"] == nr), None)
        except Exception: d = None
    return str((d or {}).get("bereich") or "")


def empfaenger(wort, nr=None, d=None):
    """1782, 1903: Disponent bei Freigabe eines Builds („gut“, „passt“, „freigegeben“, unverneint) oder bei einem Ergebnis nach
    Checkliste 11, 12 („- n.k ✓/✗“, „- Rest ✓“), beides nur, wenn der Text einen Build nennt oder der Vorgang einen Build trägt;
    sonst der Arbeitsplaner (AN): Verneinung, einzelnes 👍/👎, Fund; 1876: Chefwort zum Betrieb oder zu „B Abläufe“ an Sokrates."""
    w = wort or ""
    if not (ERGEBNIS.search(w) or freigabe(w)):
        b = _bereich(nr, d)
        if BETRIEB.search(w) or b.startswith("B Abläufe"): return SOKRATES  # 1876
        if BETRIEB_SCHWACH.search(w) and (not nr or b.startswith("B ")): return SOKRATES  # 1915
        return AN
    if BUILD_IM_TEXT.search(w) or _build_am_vorgang(nr, d): return DISPONENT
    return AN


SCHARF = os.path.join(ue.WURZEL, "tools", "1727-SCHARF")
LANG = 6000  # Zeichen je Eintrag; längeres steht im Protokoll der Sitzung
ROLLEN = r"(Perikles|Homer|Sokrates|Diogenes|Ford|Tom|Jerry|Spike|Tuffy)"
try:  # 1739 Rufnamen: „**Anna** [21.11., 21:40]“ ist eine Sitzung, nicht der Chef
    import rufname
    ROLLEN = r"(Perikles|Homer|Sokrates|Diogenes|Ford|Tom|Jerry|Spike|Tuffy|%s)" % "|".join(sorted(rufname.ALLE))
except Exception:
    pass
try:  # 1893: Sitzungen der umgestellten Liste melden sich auch mit dem Profil („**Technik** [22.11., 09:00]“)
    import startbar as _sb
    ROLLEN = ROLLEN[:-1] + "|" + "|".join(re.escape(p) for p in _sb.profile()) + ")"
except Exception:
    pass
FEHLER = os.environ.get("BORNIM_CHEFWORT_FEHLER", "/tmp/bornim-chefwort-fehler.txt")


# 1962: Erlaubnisliste statt Sperrliste. Chefwort nur mit belegter Herkunft Mensch im Protokoll: die Zeile „user“ mit diesem
# Wortlaut trägt origin human (oder keins) und kein promptSource. Beleg 22.11., 18:15: beim Haken steht dort zuerst nur
# „queue-operation“ (enqueue, ohne origin); die Zeile „user“ (Startnachricht: origin task-notification, promptSource system)
# folgt erst. Die erste Nachricht einer Sitzung ist nie Chefwort. Arten aus dem Claude-Code-Programm (origin.kind).
MENSCH = (None, "human", "person", "user")
MASCHINE = ("task-notification", "peer", "coordinator", "plugin", "auto-continuation", "channel", "observer-activity",
            "suggestion", "composer")
WARTEN = float(os.environ.get("BORNIM_CHEFWORT_WARTEN", "8"))  # Sekunden, bis die Zeile „user“ im Protokoll steht


def _inhalt(d):
    if d.get("type") != "user" or d.get("isMeta") or d.get("isSidechain"):
        return None
    c = (d.get("message") or {}).get("content")
    if isinstance(c, list):
        if any(isinstance(x, dict) and x.get("type") == "tool_result" for x in c): return None
        c = " ".join(x.get("text", "") for x in c if isinstance(x, dict))
    return c.lstrip() if isinstance(c, str) and c.strip() else None


def herkunft(text, pfad):
    """1962: „chef“, „sitzung“, „erste“ (erste Nachricht der Sitzung), „offen“ (Zeile noch nicht im Protokoll) oder
    „unbelegt …“ (unbekannte Art: nicht eintragen, melden)."""
    kopf = (text or "").lstrip()[:200]
    try:
        with open(pfad, encoding="utf-8", errors="replace") as f:
            zeilen = [json.loads(z) for z in f if z.strip()]
    except (OSError, ValueError, TypeError):
        return "unbelegt (Protokoll nicht lesbar)"
    nutzer = [d for d in zeilen if _inhalt(d) is not None]
    treffer = [i for i, d in enumerate(nutzer) if _inhalt(d)[:200] == kopf]
    if not [d for d in nutzer[:treffer[-1] if treffer else None] if _inhalt(d)[:200] != kopf]:
        return "erste"
    if not treffer:
        return "offen"
    d = nutzer[treffer[-1]]
    art, quelle = (d.get("origin") or {}).get("kind"), d.get("promptSource")
    if art in MENSCH and quelle is None:
        return "chef"
    if art in MASCHINE or quelle == "system":
        return "sitzung"
    return "unbelegt (origin %s, promptSource %s)" % (art, quelle)


def vom_chef(text, pfad=None):
    """False für Nachrichten anderer Sitzungen, Startaufträge und Systemmeldungen; mit Protokoll nur bei belegter Herkunft Mensch (1962)."""
    t = (text or "").lstrip()
    if not t:
        return False
    if t.startswith(("<", "[SYSTEM", "Du bist **", "## Kern", "Dein Rufname:")) or re.match(r"\W{0,3}\*\*" + ROLLEN + r"( \d)?\*\*\s*\[", t):
        return False
    if re.match(r"(Weiter( in)?|Auftrag|sieh in)\b", t):
        return False
    return herkunft(t, pfad) == "chef" if pfad else True


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


def aufheben(t, zeit):
    """1976 (1566): Zeile „Zustand: ruht, beim Chef …“ der Vorgangsdatei → „Zustand: aufgehoben JETZT durch Chefwort ZEIT (war: …)“
    (Form wie Sokrates 22.11., 21:51); ohne solche Zeile unverändert. Bleibt sie, Fehler (nichts geschrieben)."""
    import rueckmeldung as rm
    jetzt = ue.fmt(ue.jetzt())
    t2 = re.sub(r"(?m)^Zustand: (" + re.escape(rm.RUHT) + r".*)$", lambda m: "Zustand: aufgehoben %s durch Chefwort %s (war: %s; 1976)" % (jetzt, zeit, m.group(1)), t)
    if rm.ruht(t2): raise ue.Fehler("Zustand „%s“ in der Vorgangsdatei nicht aufgehoben (1976)" % rm.RUHT)
    return t2


def liste_aufheben(L, nr, zeit):
    """1976: Stand „ruht …“ der Zeile nr in der Vorgangsliste → „startbar, Chefwort ZEIT“; neuer Listentext oder None (keine Zeile,
    Stand ruht nicht). Bleibt „ruht“, Fehler."""
    import startbar
    if not (L or "").strip(): return None
    d = next((x for x in startbar.vorgangsliste(L) if x["nr"] == nr), None)
    if not d or d.get("wort") != "ruht": return None
    n = dict(d, stand="startbar, Chefwort %s" % zeit)
    Z = L.split("\n"); Z[d["i"]] = startbar.zeile_text(n); L2 = "\n".join(Z)
    d2 = next((x for x in startbar.vorgangsliste(L2) if x["nr"] == nr), None)
    if not d2 or d2.get("wort") == "ruht": raise ue.Fehler("Stand „ruht“ von %s in der Vorgangsliste nicht aufgehoben (1976)" % nr)
    return L2


def eintragen(nr, wort, zeit, wer, sid="", an=None):
    """Chefwort und offene Zeile an an (Vorgabe empfaenger(): Arbeitsplaner, bei Freigabe oder Ergebnis Disponent) in einem Commit.
    Rückgabe: Kennung der Zeile oder None (schon eingetragen)."""
    wort = (wort or "").strip()
    an = an or empfaenger(wort, nr)
    if len(wort) > LANG:
        wort = wort[:LANG] + " … (gekürzt; ganz im Protokoll der Sitzung)"
    zitat = "\n".join("> " + z for z in wort.splitlines()) or "> (leer)"
    kopf = "- **%s**, Chef in Sitzung %s%s:" % (zeit, wer or "unbekannt", (" (`%s`)" % sid) if sid else "")
    block = kopf + "\n" + zitat + "\n"
    import startbar
    vp, lp = ue._pfad(nr), "docs/" + startbar.LISTE
    def f(alt):
        t = ue._mit_abschnitt(alt[vp], nr)
        if block in t:
            return {}, None
        import rueckmeldung as rm
        schon = rm.ruht(ue.abschnitt(t, "Rückmeldungen"))
        t = ue.anhaengen(t, "Chefworte", "Wörtlich, mit Zeit; trägt `chefwort.py` ein (Haken D, 1762).", block)
        ks = [int(z["k"].rsplit("Ü", 1)[1]) for z in ue.zeilen(t)]
        k = "%s-Ü%d" % (nr, max(ks, default=0) + 1)
        n = rm.zaehlen(t)["nein"]
        aus = {}
        if chef_nein(wort) and not schon and n >= rm.MAX_NEIN:  # 1872: „Prüfer ja, Chef nein“ stoppt an Obergrenze A wie drei „nein“ des Prüfers
            grund = "Obergrenze A: %d. abgelehnter Auftrag, zuletzt Chefwort" % n
            t = rm.zustand_ruht(t, zeit, grund)
            a2, was = rm.SOKRATES, ue._rein("an den Chef: Chefsache anlegen, nicht selbst lösen (%s; Chefwort %s aus Sitzung %s)" % (grund, zeit, wer or "unbekannt"))
        else:
            t = aufheben(t, zeit)  # 1976 (1566): das Chefwort hebt „ruht, beim Chef“ in NR.md und Liste im selben Commit auf
            L = liste_aufheben(alt[lp], nr, zeit)
            if L is not None: aus[lp] = L
            a2, was = an, ue._rein("Chefwort %s aus Sitzung %s lesen (Abschnitt Chefworte)%s" % (zeit, wer or "unbekannt",
                           "; Freigabe oder Ergebnis des Builds: Build-Macher starten (3.3 Nr. 7, 1782)" if an == DISPONENT else ""))
        aus[vp] = t.rstrip("\n") + "\n| %s | %s | %s | %s | offen |\n" % (k, a2, was, ue.fmt(ue.jetzt()))
        return aus, k
    return ue.atomar_dateien([vp, lp], f, "Chefwort %s aus Sitzung %s (Haken D, 1762)" % (nr, wer or "unbekannt"))


def melden(nr, k, an=AN):
    if not k:
        print("SCHON EINGETRAGEN %s: gleicher Wortlaut zur gleichen Zeit" % nr)
        return
    try:  # 1872: an Obergrenze A geht die Zeile an Sokrates statt an AN
        an = next((z["an"] for z in ue.zeilen(open(os.path.join(ue.WURZEL, ue._pfad(nr)), encoding="utf-8").read()) if z["k"] == k), an)
    except OSError: pass
    print("CHEFWORT %s eingetragen, OFFEN %s an %s" % (nr, k, an))
    ue.wecker(nr, k, an)  # 1760: läuft keine Sitzung, Wecker an den Disponenten


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
    protokoll = eingabe.get("transcript_path") or ""
    if not protokoll or not vom_chef(text) or herkunft(text, protokoll) in ("erste", "sitzung"):  # 1962: ohne Protokoll kein Beleg
        return []
    sid = ""
    try:
        sid = ue.sitzung()
    except ue.Fehler:
        pass
    nrs = [nr for nr, d in vorgaenge(text).items() if not eigen(nr, d, wer, sid)]
    if not nrs:
        return []
    an = empfaenger(text, nrs[0])  # 1782: nur für den Hinweis; eintragen bestimmt ihn je Vorgang
    zeit = ue.fmt(ue.jetzt())
    pfad = os.path.join("/tmp", "bornim-chefwort-%d.txt" % os.getpid())
    open(pfad, "w", encoding="utf-8").write(text)
    subprocess.Popen([sys.executable, os.path.abspath(__file__), "hintergrund", pfad, zeit, wer or "unbekannt", sid, protokoll] + nrs,
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True, cwd=ue.WURZEL)
    print("Haken D (1762): Chefwort zu %s gehört nicht dieser Sitzung (%s); wird wörtlich in docs/vorgang/<Nr>.md eingetragen, sobald das Protokoll "
          "die Herkunft Chef belegt (1962), offene Zeile an %s (`vorgang.py offen %s`). Nicht selbst bauen; eigener Anteil wie sonst." % (", ".join(nrs), wer or "Rolle unbekannt", an, an))
    return nrs


def hintergrund(pfad, zeit, wer, sid, protokoll, nrs):
    text = open(pfad, encoding="utf-8").read()
    fehl = []
    h, ende = herkunft(text, protokoll), time.time() + WARTEN
    while h == "offen" and time.time() < ende:  # 1962: die Zeile „user“ kommt nach dem Haken ins Protokoll
        time.sleep(0.2); h = herkunft(text, protokoll)
    if h != "chef":
        if h != "sitzung" and h != "erste":  # unbelegt oder nach WARTEN noch offen: nicht eintragen, aber melden
            fehl.append("%s (%s): nicht eingetragen, Herkunft Chef nicht belegt (%s); war es ein Chefwort: von Hand" % (" ".join(nrs), zeit, h))
        nrs = []
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
        return hintergrund(a[1], a[2], a[3], a[4], a[5], a[6:])
    a = list(a[1:]) if a[:1] == ["chefwort"] else list(a)
    zeit, wer, an = None, None, None
    for opt in ("--zeit", "--sitzung", "--an"):
        if opt in a:
            i = a.index(opt); v = a[i + 1]; del a[i:i + 2]
            if opt == "--zeit": zeit = v
            elif opt == "--an": an = v
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
        an = an or empfaenger(a[1], a[0])
        melden(a[0], eintragen(a[0], a[1], zeit or ue.fmt(ue.jetzt()), wer or "unbekannt", sid, an), an)
    except ue.Fehler as e:
        sys.exit("vorgang.py chefwort: %s; nichts geschrieben" % e)


if __name__ == "__main__":
    haupt(sys.argv[1:])
