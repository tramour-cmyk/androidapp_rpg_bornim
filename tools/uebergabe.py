#!/usr/bin/env python3
"""1760 (1727 Gesamtbild 3.3 Fassung 2, Chef 21.11., 10:11 „3.3 so“): Übergabe als Zeile in der Vorgangsdatei, Nachricht nur Wecker.

Aufruf über vorgang.py (oder direkt):
  vorgang.py uebergabe NR AN "was"           neue Zeile „offen“ in docs/vorgang/NR.md; gibt WECKER-Zeilen aus (Kennung des Empfängers frisch
                                              aus ARBEIT-BESETZUNG.md); der Absender schickt den Wecker per send_message „sieh in NR (Kennung)“
  vorgang.py annehmen KENNUNG [--frist MIN]  Quittung: offen → angenommen (diese Sitzung, Frist, Vorgabe 30 Minuten); ANGENOMMEN = jetzt tun;
                                              SCHON DEINE = doppelter Wecker, nichts neu beginnen; BELEGT (Exit 3) = eine andere Sitzung hat sie
  vorgang.py verlaengern KENNUNG [--frist MIN]   eigene Frist neu setzen (langer Zug)
  vorgang.py erledigt KENNUNG                angenommen → erledigt (nur der Halter; ein zweites Mal: nichts)
  vorgang.py freigeben                       alle von dieser Sitzung angenommenen Zeilen wieder offen (vor „Nachfolger:“, schneller als die Frist)
  vorgang.py offen [AN] [--sitzungen DATEI …]   offene Zeilen (Büro-Liste: Fund des Chefs, „Eilt“, Eingangszeit); mit --sitzungen
                                              (list_sessions-Seiten oder Kurzform wie lauf.py) wird jede abgelaufene Frist eines Halters, der
                                              nicht working ist, wieder offen (Stundenrunde, verlorene Wecker); working: es wird gewartet

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
ZEILE = re.compile(r"^\| (?P<k>\d+(?:\.\d+)?[a-z]?-Ü\d+) \| (?P<an>[^|]*?) \| (?P<was>.*) \| (?P<seit>\d\d\.\d\d\., \d\d:\d\d) \| (?P<z>[^|]*?) \|$", re.M)
ANG = re.compile(r"angenommen (?P<sid>session_\w+) bis (?P<bis>\d\d\.\d\d\., \d\d:\d\d)")

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

def atomar(nr, aendern, nachricht):
    """aendern(alter_text) → (neuer_text, ergebnis); alter_text "" wenn die Datei fehlt. Schreibt nur docs/vorgang/NR.md auf origin/main."""
    if os.environ.get("BORNIM_OHNE_PUSH"): raise Fehler("BORNIM_OHNE_PUSH gesetzt: Übergaben gehen nur über origin/main")
    if _git("rev-parse", "--abbrev-ref", "HEAD")[1] != "main": raise Fehler("nicht auf main (Übergaben nur in der Notizkopie, ../bornim-main)")
    pfad = _pfad(nr)
    for versuch in range(VERSUCHE):
        if versuch: time.sleep(random.uniform(0.1, 0.4) * versuch)
        rc, _, err = _git("fetch", "-q", "origin", "main")
        if rc and "cannot lock ref" in err: continue  # zweiter Aufruf in derselben Kopie holt gerade
        if rc: raise Fehler("origin/main nicht erreichbar: " + err.strip()[:200])
        _, basis, _ = _git("rev-parse", "origin/main")
        rc, alt, _ = _git("show", "origin/main:" + pfad)
        alt = alt + "\n" if rc == 0 and alt else ""
        neu, ergebnis = aendern(alt)
        if neu == alt: return ergebnis
        _, blob, _ = _git("hash-object", "-w", "--stdin", eingabe=neu)
        with tempfile.TemporaryDirectory() as t:
            env = dict(os.environ, GIT_INDEX_FILE=os.path.join(t, "index"))
            _git("read-tree", basis, env=env)
            _git("update-index", "--add", "--cacheinfo", "100644,%s,%s" % (blob, pfad), env=env)
            _, baum, _ = _git("write-tree", env=env)
        anhang = _systemzeilen()
        rc, c, _ = _git("commit-tree", baum, "-p", basis, "-m", nachricht + ("\n\n" + anhang if anhang else ""))
        if rc or not c: raise Fehler("commit-tree fehlgeschlagen")
        rc, _, err = _git("push", "-q", "origin", "%s:refs/heads/main" % c)
        if rc == 0:
            _nachziehen(c, pfad, neu)
            return ergebnis
        if not re.search(r"rejected|fetch first|non-fast-forward|stale info|cannot lock ref", err): raise Fehler("Push abgelehnt: " + err.strip()[:200])
    raise Fehler("nach %d Versuchen nicht gepusht (zu viele gleichzeitige Schreiber)" % VERSUCHE)

def _nachziehen(c, pfad, neu):
    """Lokale Kopie auf den neuen Stand: schnell vorspulen, wenn möglich; sonst nur die Datei, damit die Sitzung sie gleich liest."""
    _git("fetch", "-q", "origin", "main")
    if _git("merge", "--ff-only", "-q", "origin/main")[0] == 0: return
    if _git("status", "--porcelain", "--", pfad)[1] == "" and _git("ls-files", "--error-unmatch", pfad)[0] == 0:
        open(os.path.join(WURZEL, pfad), "w", encoding="utf-8").write(neu)

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
    m = re.fullmatch(r"(\d+(?:\.\d+)?[a-z]?)-Ü\d+", kennung)
    if not m: raise Fehler("Kennung „%s“ ungültig (Form NR-Ük, etwa 1760-Ü1)" % kennung)
    return m.group(1)

def besetzung(an):
    """Kennungen laufender Sitzungen der Rolle AN, frisch aus ARBEIT-BESETZUNG.md (beim Senden, nie aus dem Gedächtnis)."""
    try: t = open(os.path.join(WURZEL, "docs", "ARBEIT-BESETZUNG.md"), encoding="utf-8").read()
    except OSError: return []
    aus = []
    for z in t.splitlines():
        f = [x.strip() for x in z.split("|")]
        if len(f) > 3 and f[1].lower() == an.lower():
            aus += re.findall(r"code/(session_\w+)", f[2])
    return aus

# ---- Befehle -------------------------------------------------------------

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
    ss = besetzung(an)
    for s in ss: print("WECKER %s | sieh in %s (%s)" % (s, nr, k))
    if not ss: print("KEINE SITZUNG %s läuft (ARBEIT-BESETZUNG.md): die Zeile wartet; Start über den Disponenten (Ford), die neue Sitzung liest `vorgang.py offen %s`" % (an, an))
    return k

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
        neu = _ersetzen(alt, z, "angenommen %s bis %s" % (sid, bis))
        return neu, ("SCHON DEINE" if m and not nur_verlaengern else ("VERLÄNGERT" if m else "ANGENOMMEN"), "bis " + bis)
    wort, rest = atomar(nr, f, "Übergabe %s angenommen (1760)" % kennung)
    hinweis = {"ANGENOMMEN": "jetzt tun; fertig: vorgang.py erledigt %s" % kennung,
               "SCHON DEINE": "doppelter Wecker: nichts neu beginnen, Frist erneuert",
               "VERLÄNGERT": "Frist erneuert",
               "BELEGT": "eine andere Sitzung hat sie; nichts tun (abgelaufene Frist gibt erst `vorgang.py offen --sitzungen …` frei)",
               "ERLEDIGT": "schon erledigt; nichts tun",
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
        aus += [(z["k"], z["was"]) for z in zeilen(t) if z["z"] == "offen" and z["an"].lower() == an.lower()]
    return aus

def freigeben():
    sid = sitzung(); n = 0
    for nr, t in list(_alle_dateien()):
        if not any(ANG.match(z["z"]) and ANG.match(z["z"]).group("sid") == sid for z in zeilen(t)): continue
        def f(alt):
            for z in reversed(zeilen(alt)):
                m = ANG.match(z["z"])
                if m and m.group("sid") == sid: alt = _ersetzen(alt, z, "offen")
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
            st[s["id"]] = "working" if re.search(r"WORKING|RUNNING|working", b) else "ruht"
    return st

def offen(an=None, sitzungen_dateien=(), still=False):
    """still: nichts drucken (lauf.py ruft es je Lauf, 1739 Befund 1); Rückgabe [(Zeile, Nr, wie)]."""
    st = _status(list(sitzungen_dateien)); jz = jetzt(); liste = []
    for nr, t in list(_alle_dateien()):
        frei = []
        for z in zeilen(t):
            m = ANG.match(z["z"])
            if m and _zeit(m.group("bis"), jz.year) <= jz:
                h = (st or {}).get(m.group("sid"), "unbekannt" if st is None else "ruht")
                if h == "ruht": frei.append(z["k"])
                else:
                    liste.append((z, nr, "Frist abgelaufen, Halter %s%s" % (m.group("sid"), " arbeitet (warten)" if h == "working" else ", Status unbekannt (mit --sitzungen prüfen)")))
            elif z["z"] == "offen": liste.append((z, nr, "offen"))
        if frei:
            def f(alt, frei=frei):
                for z in reversed(zeilen(alt)):
                    m = ANG.match(z["z"])
                    if z["k"] in frei and m and _zeit(m.group("bis"), jz.year) <= jz: alt = _ersetzen(alt, z, "offen")
                return alt, None
            atomar(nr, f, "Übergaben %s wieder offen: Frist abgelaufen, Halter ruht (1760)" % ", ".join(frei))
            for k in frei:
                z = next(x for x in zeilen(t) if x["k"] == k)
                liste.append((z, nr, "wieder offen (Frist abgelaufen, Halter ruht)"))
    if an: liste = [x for x in liste if x[0]["an"].lower() == an.lower()]
    def rang(x):
        w = x[0]["was"].lower()
        return (0 if "fund des chefs" in w else 1 if "eilt" in w else 2, _zeit(x[0]["seit"], jz.year))
    liste.sort(key=rang)
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
        if b == "uebergabe" and len(a) == 4: return uebergabe(a[1], a[2], a[3])
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
