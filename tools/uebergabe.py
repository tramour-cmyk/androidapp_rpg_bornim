#!/usr/bin/env python3
"""1760 (1727 Gesamtbild 3.3 Fassung 2, Chef 21.11., 10:11 „3.3 so“): Übergabe als Zeile in der Vorgangsdatei, Nachricht nur Wecker.

Aufruf über vorgang.py (oder direkt):
  vorgang.py uebergabe NR AN "was"           (AN: siehe „Empfänger“ unten; NR auch B<n> für Build n, 1949) neue Zeile „offen“ in docs/vorgang/NR.md; gibt WECKER-Zeilen aus (Kennung des Empfängers frisch
                                              aus ARBEIT-BESETZUNG.md); der Absender schickt den Wecker per send_message „sieh in NR (Kennung)“
  vorgang.py annehmen KENNUNG [--frist MIN]  Quittung: offen → angenommen (diese Sitzung, Frist, Vorgabe 30 Minuten); ANGENOMMEN = jetzt tun;
                                              SCHON DEINE = doppelter Wecker, nichts neu beginnen; BELEGT (Exit 3) = eine andere Sitzung hat sie
  vorgang.py verlaengern KENNUNG [--frist MIN]   eigene Frist neu setzen (langer Zug)
  vorgang.py erledigt KENNUNG                angenommen → erledigt (nur der Halter; ein zweites Mal: nichts)
  vorgang.py freigeben                       alle von dieser Sitzung angenommenen Zeilen wieder offen (vor „Nachfolger:“, schneller als die Frist)
  vorgang.py offen [AN] [--sitzungen DATEI …]   offene Zeilen (Büro-Liste: Eilt, Fund des Chefs, Themenblock, Eingangszeit; 1796); mit --sitzungen
                                              (list_sessions-Seiten oder Kurzform wie lauf.py) wird jede abgelaufene Frist eines Halters, der
                                              nicht working ist, wieder offen (Stundenrunde, verlorene Wecker); working: es wird gewartet.
                                              1782 (3.3 Nr. 3, 1727d L-S2/L-U8): beim ersten Mal „offen (wieder 1)“ (ein Neustart), beim
                                              zweiten Mal „steckt fest“; ebenso, ohne die Frist abzuwarten, wenn der Halter abgebrochen ist

Empfänger AN (1946): die Profile der Themenblöcke und das Büro (startbar.profile(): Arbeitsplaner, Regeln, Kampf, Figur, Kataloge,
Welt, Klang, Oberfläche, Story, Technik, Werkzeug, Disponent, Prüfer, Tester), dazu Sokrates und „Fachkraft“ (= Fachprofil des
Themenblocks, lauf.py setzt es ein). Alte Rollennamen gelten nur bis zur Umschaltung (ohne tools/1727-SCHARF): Spike → Technik,
Diogenes → Prüfer, Ford → Disponent, Perikles → Arbeitsplaner, Tom und Jerry → Fachkraft, Homer → Story; danach hält das Werkzeug an.

Muster (erst nachsehen, wie andere es lösen): Warteschlange mit Sichtbarkeitsfrist (Amazon SQS visibility timeout, Celery acks_late):
mindestens einmal zustellen, Quittung mit Frist statt „nie zweimal“, feste Kennung macht doppeltes Wecken harmlos. Zwei Schreiber: wie
der Zähler (940) ein Commit nur mit dieser einen Datei, auf origin/main gebaut (commit-tree), Push; abgewiesen → neu holen und neu
anwenden. Darum gilt eine Quittung erst, wenn sie auf origin/main steht; zwei gleichzeitige „annehmen“ ergeben genau ein ANGENOMMEN.
Ohne Netz oder außerhalb von main: Fehler, nichts geschrieben (eine Quittung, die keiner sieht, schützt nicht).
"""
import datetime, os, random, re, subprocess, sys, tempfile, time
try:
    from zoneinfo import ZoneInfo
    BERLIN = ZoneInfo("Europe/Berlin")
except Exception:  # pragma: no cover
    BERLIN = None

WURZEL = os.environ.get("BORNIM_WURZEL") or os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
ORDNER = "docs/vorgang"
FRIST_MIN = 30
VERSUCHE = 8
KOPF = "| Ü | an | was | seit | Zustand |\n|---|---|---|---|---|\n"
ZEILE = re.compile(r"^\| (?P<k>B?\d+(?:\.\d+)?[a-z]?-Ü\d+) \| (?P<an>[^|]*?) \| (?P<was>.*) \| (?P<seit>\d\d\.\d\d\., \d\d:\d\d) \| (?P<z>[^|]*?) \|$", re.M)
ANG = re.compile(r"angenommen (?P<sid>session_\w+) bis (?P<bis>\d\d\.\d\d\., \d\d:\d\d)")
WIEDER = re.compile(r"\(wieder (\d+)\)")  # 1782: wie oft die Zeile nach abgelaufener Frist oder Abbruch wieder offen wurde
FEST = "steckt fest"

def ist_offen(zu): return zu == "offen" or zu.startswith("offen (wieder ")
def wieder(zu):
    m = WIEDER.search(zu or ""); return int(m.group(1)) if m else 0
def mit_wieder(zustand, n): return zustand + (" (wieder %d)" % n if n else "")
def zurueck(zu, grund, jz, sid):
    """1782: nächster Zustand einer angenommenen Zeile ohne Ergebnis: erstes Mal „offen (wieder 1)“, zweites Mal „steckt fest (…)“."""
    return "offen (wieder 1)" if wieder(zu) == 0 else "%s (%s %s, %s)" % (FEST, grund, fmt(jz), sid)

def abgebrochen(nr, sid=None):
    """1782 (3.3 Nr. 3 „ebenso nach ‚abgebrochen‘“): Rückmeldung „abgebrochen“ des Halters → seine angenommenen Zeilen in NR wie
    nach abgelaufener Frist (erstes Mal wieder offen, zweites Mal „steckt fest“). Rückgabe [(Kennung, neuer Zustand)]."""
    sid = sid or sitzung(); jz = jetzt()
    def f(alt):
        aus = []
        for z in reversed(zeilen(alt)):
            m = ANG.match(z["z"])
            if m and m.group("sid") == sid:
                neu = zurueck(z["z"], "abgebrochen", jz, sid); alt = _ersetzen(alt, z, neu); aus.append((z["k"], neu))
        return alt, list(reversed(aus))
    return atomar(nr, f, "Übergaben %s: Halter abgebrochen (1782)" % nr)

class Fehler(Exception): pass

def jetzt():
    t = os.environ.get("BORNIM_JETZT")  # Tests: „TT.MM., HH:MM“
    if t: return _zeit(t)
    return datetime.datetime.now(BERLIN).replace(tzinfo=None, second=0, microsecond=0)

def _zeit(s, jahr=None):
    return datetime.datetime.strptime("%s %d" % (s, jahr or datetime.datetime.now().year), "%d.%m., %H:%M %Y")

def fmt(d): return d.strftime("%d.%m., %H:%M")

def sitzung():
    s = os.environ.get("BORNIM_SITZUNG") or os.environ.get("CLAUDE_CODE_REMOTE_SESSION_ID", "")
    if s.startswith("cse_"): s = "session_" + s[4:]
    if not s.startswith("session_"): raise Fehler("Kennung dieser Sitzung unbekannt (CLAUDE_CODE_REMOTE_SESSION_ID fehlt)")
    return s

def _git(*a, env=None, eingabe=None):
    p = subprocess.run(["git", "-C", WURZEL] + list(a), capture_output=True, text=True, timeout=60, env=env, input=eingabe)
    return p.returncode, p.stdout.strip(), p.stderr

def _pfad(nr): return "%s/%s.md" % (ORDNER, nr)

def _systemzeilen():
    _, text, _ = _git("log", "-30", "--format=%B", "origin/main")
    co = next((l for l in text.splitlines() if l.startswith("Co-Authored-By:")), None)
    try: cs = "Claude-Session: https://claude.ai/code/" + sitzung()
    except Fehler: cs = None
    return "\n".join(x for x in (co, cs) if x)

def atomar(nr, aendern, nachricht, pfad=None):
    """aendern(alter_text) → (neuer_text, ergebnis); alter_text "" wenn die Datei fehlt. Schreibt nur docs/vorgang/NR.md auf origin/main
    (1739: oder PFAD, etwa das Lehrenbuch; Sperre wie beim Zähler: Push nur auf den gelesenen Stand, sonst neu lesen)."""
    pfad = pfad or _pfad(nr)
    def f(alt):
        n, e = aendern(alt[pfad]); return {pfad: n}, e
    return atomar_dateien([pfad], f, nachricht)

def atomar_dateien(pfade, aendern, nachricht):
    """1899 (D339.1): wie atomar, mehrere Dateien in einem Commit auf origin/main. aendern({pfad: alter_text}) → ({pfad: neuer_text}, ergebnis);
    fehlende Pfade im Ergebnis bleiben unverändert. Gelingt der Push nicht, ist nichts geschrieben (auch lokal nicht)."""
    if os.environ.get("BORNIM_OHNE_PUSH"): raise Fehler("BORNIM_OHNE_PUSH gesetzt: Übergaben gehen nur über origin/main")
    if _git("rev-parse", "--abbrev-ref", "HEAD")[1] != "main": raise Fehler("nicht auf main (Übergaben nur in der Notizkopie, ../bornim-main)")
    for versuch in range(VERSUCHE):
        if versuch: time.sleep(random.uniform(0.1, 0.4) * versuch)
        rc, _, err = _git("fetch", "-q", "origin", "main")
        if rc and "cannot lock ref" in err: continue  # zweiter Aufruf in derselben Kopie holt gerade
        if rc: raise Fehler("origin/main nicht erreichbar: " + err.strip()[:200])
        _, basis, _ = _git("rev-parse", "origin/main")
        alt = {}
        for p in pfade:
            rc, t, _ = _git("show", "origin/main:" + p)
            alt[p] = t + "\n" if rc == 0 and t else ""
        neu, ergebnis = aendern(dict(alt))
        neu = {p: t for p, t in neu.items() if t != alt.get(p, "")}
        if not neu: return ergebnis
        with tempfile.TemporaryDirectory() as t:
            env = dict(os.environ, GIT_INDEX_FILE=os.path.join(t, "index"))
            _git("read-tree", basis, env=env)
            for p, inhalt in neu.items():
                _, blob, _ = _git("hash-object", "-w", "--stdin", eingabe=inhalt)
                _git("update-index", "--add", "--cacheinfo", "100644,%s,%s" % (blob, p), env=env)
            _, baum, _ = _git("write-tree", env=env)
        anhang = _systemzeilen()
        rc, c, _ = _git("commit-tree", baum, "-p", basis, "-m", nachricht + ("\n\n" + anhang if anhang else ""))
        if rc or not c: raise Fehler("commit-tree fehlgeschlagen")
        rc, _, err = _git("push", "-q", "origin", "%s:refs/heads/main" % c)
        if rc == 0:
            _nachziehen(c, neu, basis)
            return ergebnis
        if not re.search(r"rejected|fetch first|non-fast-forward|stale info|cannot lock ref", err): raise Fehler("Push abgelehnt: " + err.strip()[:200])
    raise Fehler("nach %d Versuchen nicht gepusht (zu viele gleichzeitige Schreiber)" % VERSUCHE)

def _nachziehen(c, dateien, basis=None):
    """Lokale Kopie auf den neuen Stand: schnell vorspulen, wenn möglich; sonst nur die Dateien ({pfad: text}), damit die Sitzung sie gleich liest.
    1918 (D348.1): eine Datei, deren lokaler Stand (HEAD) vom gepushten Ausgangsstand BASIS abweicht (eigener Commit voraus), bleibt stehen;
    überschreiben löschte den eigenen Commit aus der Arbeitskopie. Der nächste `git pull --rebase` führt beide zusammen."""
    _git("fetch", "-q", "origin", "main")
    if _git("merge", "--ff-only", "-q", "origin/main")[0] == 0: return
    for pfad, neu in dateien.items():
        if _git("status", "--porcelain", "--", pfad)[1] != "" or _git("ls-files", "--error-unmatch", pfad)[0] != 0: continue
        if basis and _git("rev-parse", "HEAD:" + pfad)[1] != _git("rev-parse", "%s:%s" % (basis, pfad))[1]:
            print("Hinweis: %s lokal mit eigenem Commit voraus, nicht nachgezogen; vor dem nächsten Commit `git pull --rebase` (1918)" % pfad)
            continue
        open(os.path.join(WURZEL, pfad), "w", encoding="utf-8").write(neu)

def ungepusht(pfad):
    """1918 (D348.1): Grund, warum PFAD in der lokalen Kopie Ungepushtes hat („geändert, nicht committet“, „eigener Commit voraus“), sonst ""."""
    if _git("status", "--porcelain", "--", pfad)[1].strip(): return "geändert, nicht committet"
    _git("fetch", "-q", "origin", "main")
    if _git("log", "--format=%h", "origin/main..HEAD", "--", pfad)[1].strip(): return "eigener Commit voraus"
    return ""

def _titel(nr):
    try:
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
        import startbar
        z = [d for d in startbar.zeilen_liste() if d["nr"] == nr]
        if z: return re.sub(r"\s+", " ", z[0]["titel"])[:120]
    except Exception: pass
    return "(Titel in der Vorgangsliste)"

def _mit_abschnitt(text, nr):
    if not text: text = "# %s · %s\n\nVorgangsdatei (1727 Gesamtbild 0a). Übergaben schreibt nur `vorgang.py` (1760).\n" % (nr, _titel(nr))
    if "\n## Übergaben\n" not in "\n" + text:
        text = text.rstrip("\n") + "\n\n## Übergaben\n\n" + KOPF
    return text

def anhaengen(text, titel, einleitung, block):
    """1762/1763: BLOCK ans Ende des Abschnitts „## TITEL“ (angelegt vor „## Übergaben“, falls er fehlt); Übergaben bleiben unten."""
    text = _mit_abschnitt(text, "")
    kopf = "\n## %s\n" % titel
    if kopf not in "\n" + text:
        i = text.index("\n## Übergaben\n")
        text = text[:i].rstrip("\n") + "\n" + kopf + "\n" + einleitung + "\n" + text[i:]
    a = ("\n" + text).index(kopf) - 1 + len(kopf)
    n = text.find("\n## ", a)
    vorn, hinten = text[:n], text[n:]
    return vorn.rstrip("\n") + "\n\n" + block.rstrip("\n") + "\n" + hinten


def abschnitt(text, titel):
    """Inhalt des Abschnitts „## TITEL“ ("" wenn er fehlt)."""
    kopf = "\n## %s\n" % titel
    t = "\n" + text
    if kopf not in t: return ""
    a = t.index(kopf) + len(kopf); n = t.find("\n## ", a)
    return t[a:] if n < 0 else t[a:n]


def zeilen(text): return [m.groupdict() | {"m": m} for m in ZEILE.finditer(text)]

def _ersetzen(text, z, zustand):
    m = z["m"]; alt = m.group(0)
    neu = alt[:m.start("z") - m.start()] + zustand + alt[m.end("z") - m.start():]
    return text[:m.start()] + neu + text[m.end():]

def _rein(s): return re.sub(r"\s+", " ", s.replace("|", "/")).strip()

def nr_aus(kennung):
    m = re.fullmatch(r"(B?\d+(?:\.\d+)?[a-z]?)-Ü\d+", kennung)  # 1949: B<n> = Build-Auftrag
    if not m: raise Fehler("Kennung „%s“ ungültig (Form NR-Ük, etwa 1760-Ü1)" % kennung)
    return m.group(1)

def besetzung(an):
    """Kennungen laufender Sitzungen der Rolle AN, frisch aus ARBEIT-BESETZUNG.md (beim Senden, nie aus dem Gedächtnis)."""
    try: t = open(os.path.join(WURZEL, "docs", "ARBEIT-BESETZUNG.md"), encoding="utf-8").read()
    except OSError: return []
    aus = []
    for z in t.splitlines():
        f = [x.strip() for x in z.split("|")]
        # Rolle bzw. Bereich (Spalte 1; Rufnamen-Sitzungen trägt lauf.py über den Vorgang ein) oder Rufname im Titel (1739)
        if len(f) > 3 and (f[1].lower() == an.lower() or f[2].startswith("[%s – " % an)):
            aus += re.findall(r"code/(session_\w+)", f[2])
    return aus

# ---- Befehle -------------------------------------------------------------

ALTE_NAMEN = {"Spike": "Technik", "Diogenes": "Prüfer", "Ford": "Disponent", "Perikles": "Arbeitsplaner", "Tom": "Fachkraft",
              "Jerry": "Fachkraft", "Tuffy": "Fachkraft", "Homer": "Story"}  # 1946

FACHPROFILE = ["Regeln", "Kampf", "Figur", "Kataloge", "Welt", "Klang", "Oberfläche", "Story", "Technik", "Werkzeug"]  # themenbloecke.md 22.11.

def _scharf():
    return os.path.isfile(os.path.join(os.path.dirname(os.path.abspath(__file__)), "1727-SCHARF"))

def gueltige_empfaenger(scharf=None):
    """1946: gültige AN für `vorgang.py uebergabe` (neue Namen; alte nur ohne tools/1727-SCHARF)."""
    try:
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
        import startbar
        neu = list(startbar.profile())
    except Exception:
        neu = ["Arbeitsplaner", "Disponent", "Prüfer", "Tester"]
    if not [x for x in neu if x not in ("Arbeitsplaner", "Disponent", "Prüfer", "Tester")]:  # themenbloecke.md fehlt (Klon, Test)
        neu += FACHPROFILE
    neu += [x for x in ("Sokrates", "Fachkraft") if x not in neu]
    return neu + ([] if (_scharf() if scharf is None else scharf) else list(ALTE_NAMEN))

def empfaenger(an, scharf=None):
    """1946 (Falltest Lauf 4: Disponent, Prüfer, Rundblick fragten, ob Technik, Spike oder Figur gilt): AN in der festen Schreibung,
    sonst Fehler mit der Liste der gültigen Namen; alter Rollenname nach der Umschaltung: Fehler mit dem neuen Namen."""
    scharf = _scharf() if scharf is None else scharf
    alle = gueltige_empfaenger(scharf)
    for x in alle:
        if x.lower() == (an or "").strip().lower(): return x
    alt = next((n for k, n in ALTE_NAMEN.items() if k.lower() == (an or "").strip().lower()), None)
    if alt and scharf: raise Fehler("Empfänger „%s“ gilt nach der Umschaltung nicht mehr, heißt jetzt „%s“" % (an, alt))
    raise Fehler("Empfänger „%s“ unbekannt; gültig: %s" % (an, ", ".join(alle)))

def uebergabe(nr, an, was):
    an, was = _rein(an), _rein(was)
    if not an or not was: raise Fehler("AN und „was“ nötig")
    def f(alt):
        t = _mit_abschnitt(alt, nr)
        ks = [int(z["k"].rsplit("Ü", 1)[1]) for z in zeilen(t)]
        k = "%s-Ü%d" % (nr, max(ks, default=0) + 1)
        return t.rstrip("\n") + "\n| %s | %s | %s | %s | offen |\n" % (k, an, was, fmt(jetzt())), k
    k = atomar(nr, f, "Übergabe %s an %s (1760)" % (nr, an))
    print("OFFEN %s an %s: %s" % (k, an, was))
    wecker(nr, k, an)
    return k

DISPONENT_ALT = "Ford"  # 1739: bis zur Umschaltung (lauf.ALT_EMPFAENGER)
ALT = {"Prüfer": "Diogenes", "Disponent": DISPONENT_ALT, "Arbeitsplaner": DISPONENT_ALT}

def wecker(nr, k, an, alt=None):
    """WECKER an die laufenden Sitzungen von AN (sonst der alten Rolle ALT); läuft keine, WECKER an den Disponenten, der den Start
    ausgibt (1760, Sokrates 22.11., 07:08). Gibt die geweckten Kennungen zurück."""
    alt = ALT.get(an, "") if alt is None else alt
    ss = besetzung(an) or (besetzung(alt) if alt else [])
    for s in ss: print("WECKER %s | sieh in %s (%s)" % (s, nr, k))
    if ss: return ss
    print("KEINE SITZUNG %s läuft (ARBEIT-BESETZUNG.md): die Zeile wartet; Start über den Disponenten, die neue Sitzung liest `vorgang.py offen %s`" % (an, an))
    ds = [] if DISPONENT_ALT in (an, alt) or an == "Disponent" else (besetzung("Disponent") or besetzung(DISPONENT_ALT))
    for s in ds: print("WECKER %s | sieh in %s (%s): keine Sitzung %s, Start ausgeben" % (s, nr, k, an))
    if not ds: print("KEIN DISPONENT läuft: Wache bzw. Herzschlag meldet (1764)")
    return ds

def _finde(t, kennung):
    z = [z for z in zeilen(t) if z["k"] == kennung]
    if not z: raise Fehler("%s steht nicht in %s" % (kennung, _pfad(nr_aus(kennung))))
    return z[0]

def annehmen(kennung, frist=FRIST_MIN, nur_verlaengern=False):
    nr, sid = nr_aus(kennung), sitzung()
    bis = fmt(jetzt() + datetime.timedelta(minutes=frist))
    def f(alt):
        z = _finde(alt, kennung); zu = z["z"]; m = ANG.match(zu)
        if zu.startswith("erledigt"): return alt, ("ERLEDIGT", zu)
        if m and m.group("sid") != sid: return alt, ("BELEGT", zu)
        if nur_verlaengern and not m: return alt, ("NICHT DEINE", zu)
        if zu.startswith(FEST): return alt, ("FEST", zu)
        neu = _ersetzen(alt, z, mit_wieder("angenommen %s bis %s" % (sid, bis), wieder(zu)))
        return neu, ("SCHON DEINE" if m and not nur_verlaengern else ("VERLÄNGERT" if m else "ANGENOMMEN"), "bis " + bis)
    wort, rest = atomar(nr, f, "Übergabe %s angenommen (1760)" % kennung)
    hinweis = {"ANGENOMMEN": "jetzt tun; fertig: vorgang.py erledigt %s" % kennung,
               "SCHON DEINE": "doppelter Wecker: nichts neu beginnen, Frist erneuert",
               "VERLÄNGERT": "Frist erneuert",
               "BELEGT": "eine andere Sitzung hat sie; nichts tun (abgelaufene Frist gibt erst `vorgang.py offen --sitzungen …` frei)",
               "ERLEDIGT": "schon erledigt; nichts tun",
               "FEST": "steckt fest (zweimal Frist abgelaufen oder abgebrochen, 1782): nichts tun, Sokrates klärt",
               "NICHT DEINE": "nur eigene Zeilen verlängern"}[wort]
    print("%s %s (%s): %s" % (wort, kennung, rest, hinweis))
    return wort

def erledigt(kennung):
    nr, sid = nr_aus(kennung), sitzung()
    def f(alt):
        z = _finde(alt, kennung); zu = z["z"]; m = ANG.match(zu)
        if zu.startswith("erledigt"): return alt, "SCHON ERLEDIGT"
        if not m or m.group("sid") != sid: return alt, "NICHT DEINE"
        return _ersetzen(alt, z, "erledigt %s %s" % (fmt(jetzt()), sid)), "ERLEDIGT"
    w = atomar(nr, f, "Übergabe %s erledigt (1760)" % kennung)
    print("%s %s%s" % (w, kennung, "" if w != "NICHT DEINE" else ": erst annehmen (vorgang.py annehmen %s)" % kennung))
    return w

def _alle_dateien():
    d = os.path.join(WURZEL, ORDNER)
    _git("fetch", "-q", "origin", "main")
    rc, ls, _ = _git("ls-tree", "--name-only", "origin/main", ORDNER + "/")
    namen = [os.path.basename(x)[:-3] for x in ls.splitlines() if x.endswith(".md")] if rc == 0 else \
        [x[:-3] for x in (os.listdir(d) if os.path.isdir(d) else []) if x.endswith(".md")]
    for nr in sorted(namen):
        rc, t, _ = _git("show", "origin/main:" + _pfad(nr))
        if rc: t = open(os.path.join(d, nr + ".md"), encoding="utf-8").read()
        yield nr, t

def offen_lokal(an, docs=None):
    """1763 C: offene Zeilen an AN aus den lokalen Vorgangsdateien, ohne Netz und ohne zu schreiben (für lauf.py): [(Kennung, was)]."""
    d = os.path.join(docs, "vorgang") if docs else os.path.join(WURZEL, ORDNER)
    aus = []
    for n in sorted(os.listdir(d)) if os.path.isdir(d) else []:
        if not n.endswith(".md"): continue
        try: t = open(os.path.join(d, n), encoding="utf-8").read()
        except OSError: continue
        aus += [(z["k"], z["was"]) for z in zeilen(t) if ist_offen(z["z"]) and z["an"].lower() == an.lower()]
    return aus

def freigeben():
    sid = sitzung(); n = 0
    for nr, t in list(_alle_dateien()):
        if not any(ANG.match(z["z"]) and ANG.match(z["z"]).group("sid") == sid for z in zeilen(t)): continue
        def f(alt):
            for z in reversed(zeilen(alt)):
                m = ANG.match(z["z"])
                if m and m.group("sid") == sid: alt = _ersetzen(alt, z, mit_wieder("offen", wieder(z["z"])))  # freiwillig: zählt nicht
            return alt, None
        atomar(nr, f, "Übergaben %s freigegeben (1760)" % nr); n += 1
    print("FREIGEGEBEN: %d Vorgangsdatei(en); die Nachfolgesitzung liest `vorgang.py offen`" % n)

def _status(dateien):
    if not dateien: return None
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import kosten
    st = {}
    for p in dateien:
        for s in kosten.sitzungen(p, []):
            b = s.get("status_bucket", "") + " " + s.get("session_status", "") + " " + s.get("_status", "")
            st[s["id"]] = "working" if re.search(r"WORKING|RUNNING|working", b) else "abgebrochen" if re.search(r"failed|FAILED|abgebrochen", b) else "ruht"
    return st

FUND = re.compile(r"fund des chefs|\bchefwort\b|\bnein des chefs\b", re.I)

def buero_rang(docs=None):
    """1796 (Archiv 21.11., 20:51/20:54 „Eilt zuerst“): Schlüssel der Büro-Folge für eine Zeile (Nr, was, seit): Klasse (1967, Chef 22.11.,
    17:46: Eilt, Fund des Chefs, Muss, Kür, nach dem Meilenstein), dann Themenblock (Folge in `chefsache/themenbloecke.md`), dann
    Eingangszeit; Zeile ohne Klasse zählt wie Muss. Eilt: Klasse „Eilt“ (Liste nach 1727) oder „jetzt“
    im Titel (Liste vor 1727, 383) oder „Eilt“ im Text; Fund: Titel „Von Chef“, Zeile aus `chefwort.py` („Chefwort … lesen“) oder „Fund
    des Chefs“ im Text. Liest Liste und Themenblöcke einmal; fehlt etwas, zählt die Zeile als „Übriges“."""
    docs = docs or os.path.join(WURZEL, "docs")
    liste, folge, nach_bereich, nach_nr = {}, [], {}, {}
    try:
        sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "umstellung1727"))
        import umstellen as _u, bereiche as _b
        folge, nach_bereich, nach_nr, _ = _u.bloecke(docs)
        for z in open(os.path.join(docs, "LISTE-VORGAENGE.md"), encoding="utf-8"):
            if not re.match(r"\| \d", z): continue
            c = _u.zellen(z)
            if len(c) == len(_u.KOPF_ALT): d = dict(zip(_u.KOPF_ALT, c)); kl = "Eilt" if d["Kl."] == "M" and "„jetzt“" in d["Titel"] else d["Kl."]
            elif len(c) == len(_u.KOPF_NEU): d = dict(zip(_u.KOPF_NEU, c)); kl = d["Kl."]
            else: continue
            herkunft = d["Titel"]
            if len(c) == len(_u.KOPF_NEU):  # 1727: der alte Titel (Chefzitat) steht in der Vorgangsdatei unter „Herkunft:“
                try:
                    m = re.search(r"^Herkunft: (.*)$", open(os.path.join(docs, "vorgang", d["Nr."] + ".md"), encoding="utf-8").read(), re.M)
                    if m: herkunft = m.group(1)
                except OSError: pass
            block = _u.block_nr(d["Nr."], nach_nr) or nach_bereich.get(_b.einordnen(d["Bereich"]), "9")
            liste[d["Nr."]] = (kl, bool(re.match(r"Von Chef\b", herkunft)), block)
    except Exception:
        pass
    jahr = jetzt().year
    def schluessel(nr, was, seit):
        kl, fund, block = liste.get(nr, ("", False, "9"))
        eilt = kl == "Eilt" or bool(re.search(r"\beilt\b", was or "", re.I))
        fund = fund or bool(FUND.search(was or ""))
        try: z = _zeit(seit, jahr)
        except (ValueError, TypeError): z = datetime.datetime.max
        klasse = 0 if eilt else 1 if fund else {"K": 3, "N": 4}.get(kl, 2)
        return (klasse, folge.index(block) if block in folge else len(folge), z)
    return schluessel

def offen(an=None, sitzungen_dateien=(), still=False):
    """still: nichts drucken (lauf.py ruft es je Lauf, 1739 Befund 1); Rückgabe [(Zeile, Nr, wie)].
    1782: Frist abgelaufen und Halter ruht, oder Halter abgebrochen (auch vor der Frist) → beim ersten Mal „offen (wieder 1)“,
    beim zweiten Mal „steckt fest“ (wie „wieder offen …“ bzw. „steckt fest …“ in wie; lauf.py gibt es an Sokrates)."""
    st = _status(list(sitzungen_dateien)); jz = jetzt(); liste = []
    def frei_ab(z, m):
        h = (st or {}).get(m.group("sid"), "unbekannt" if st is None else "ruht")
        if h == "abgebrochen": return h
        if _zeit(m.group("bis"), jz.year) > jz: return None
        return h
    for nr, t in list(_alle_dateien()):
        frei = {}
        for z in zeilen(t):
            m = ANG.match(z["z"])
            h = frei_ab(z, m) if m else None
            if h in ("ruht", "abgebrochen"): frei[z["k"]] = h
            elif h:
                liste.append((z, nr, "Frist abgelaufen, Halter %s%s" % (m.group("sid"), " arbeitet (warten)" if h == "working" else ", Status unbekannt (mit --sitzungen prüfen)")))
            elif ist_offen(z["z"]): liste.append((z, nr, "offen"))
            elif z["z"].startswith(FEST): liste.append((z, nr, z["z"]))
        if frei:
            def f(alt, frei=frei):
                for z in reversed(zeilen(alt)):
                    m = ANG.match(z["z"])
                    if z["k"] in frei and m and frei_ab(z, m) in ("ruht", "abgebrochen"):
                        alt = _ersetzen(alt, z, zurueck(z["z"], "abgebrochen" if frei[z["k"]] == "abgebrochen" else "Frist abgelaufen", jz, m.group("sid")))
                return alt, None
            atomar(nr, f, "Übergaben %s: Frist abgelaufen oder Halter abgebrochen (1760, 1782)" % ", ".join(sorted(frei)))
            for k, h in sorted(frei.items()):
                z = next(x for x in zeilen(t) if x["k"] == k)
                grund = "Halter abgebrochen" if h == "abgebrochen" else "Frist abgelaufen, Halter ruht"
                liste.append((z, nr, ("wieder offen (%s)" % grund) if wieder(z["z"]) == 0 else "%s (zweites Mal: %s; 1782)" % (FEST, grund)))
    if an: liste = [x for x in liste if x[0]["an"].lower() == an.lower()]
    r = buero_rang()
    liste.sort(key=lambda x: r(x[1], x[0]["was"], x[0]["seit"]))
    if still: return liste
    for z, nr, wie in liste:
        print("%s | an %s | %s | seit %s | %s" % (z["k"], z["an"], z["was"], z["seit"], wie))
    print("vorgang.py offen: %d Zeile(n)%s" % (len(liste), (" an " + an) if an else ""))
    return liste

def haupt(a):
    frist = FRIST_MIN
    if "--frist" in a:
        i = a.index("--frist"); frist = int(a[i + 1]); del a[i:i + 2]
    try:
        b = a[0] if a else ""
        if b == "uebergabe" and len(a) == 4: return uebergabe(a[1], empfaenger(a[2]), a[3])  # 1946
        if b == "annehmen" and len(a) == 2: return annehmen(a[1], frist)
        if b == "verlaengern" and len(a) == 2: return annehmen(a[1], frist, True)
        if b == "erledigt" and len(a) == 2: return erledigt(a[1])
        if b == "freigeben" and len(a) == 1: return freigeben()
        if b == "offen":
            s = []
            if "--sitzungen" in a:
                i = a.index("--sitzungen"); s = a[i + 1:]; a = a[:i]
            return offen(a[1] if len(a) > 1 else None, s)
    except Fehler as e:
        sys.exit("vorgang.py %s: %s; nichts geschrieben" % (b, e))
    sys.exit(__doc__)

BEFEHLE = ("uebergabe", "annehmen", "verlaengern", "erledigt", "freigeben", "offen")

if __name__ == "__main__":
    r = haupt(sys.argv[1:])
    sys.exit(3 if r == "BELEGT" else 0)
