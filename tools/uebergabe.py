#!/usr/bin/env python3
"""1760 (1727 Gesamtbild 3.3 Fassung 2, Chef 21.11., 10:11 „3.3 so“): Übergabe als Zeile in der Vorgangsdatei, Nachricht nur Wecker.

Aufruf über vorgang.py (oder direkt):
  vorgang.py uebergabe NR AN "was"           (AN: siehe „Empfänger“ unten; NR auch B<n> für Build n, 1949) neue Zeile „offen“ in docs/vorgang/NR.md; gibt WECKER-Zeilen aus (Kennung des Empfängers frisch
                                              aus ARBEIT-BESETZUNG.md); der Absender schickt den Wecker per send_message „sieh in NR (Kennung)“
  vorgang.py annehmen KENNUNG [--frist MIN]  Quittung: offen → angenommen (diese Sitzung, Frist, Vorgabe 30 Minuten); ANGENOMMEN = jetzt tun;
                                              SCHON DEINE = doppelter Wecker, nichts neu beginnen; BELEGT (Exit 3) = eine andere Sitzung hat sie
  vorgang.py verlaengern KENNUNG [--frist MIN]   eigene Frist neu setzen (langer Zug)
  vorgang.py erledigt KENNUNG [SITZUNG]      angenommen → erledigt (nur der Halter; ein zweites Mal: nichts)
  vorgang.py freigeben                       alle von dieser Sitzung angenommenen Zeilen wieder offen (vor „Nachfolger:“, schneller als die Frist)
  vorgang.py offen [AN] [--alle] [--sitzungen DATEI …]   offene Zeilen, höchstens 5 Zeilen Ausgabe ohne --alle (2042 e; Büro-Liste: Eilt, Fund des Chefs, Themenblock, Eingangszeit; 1796); mit --sitzungen
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
        for p in [p for p in neu if re.fullmatch(re.escape(ORDNER) + r"/[^/]+\.md", p)]:  # 2042 (2): erledigte Zeilen schlank, Wortlaut ins Archiv
            nr_p = os.path.basename(p)[:-3]; ap = archivpfad(nr_p)
            if ap not in alt:
                rc, at, _ = _git("show", "origin/main:" + ap); alt[ap] = at + "\n" if rc == 0 and at else ""
            neu[p], a2 = schlank_uebergaben(neu[p], neu.get(ap, alt[ap]), nr_p, von_git)
            if a2: neu[ap] = a2
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

def planer_wartet(text):
    """2006 (Sokrates 23.11., 19:02): erste Übergabezeile an den Arbeitsplaner, die nicht erledigt ist, gleich wie alt →
    „wartet auf <Nr>-Ü<k> (Arbeitsplaner)“; sonst None. Eine Prüfung für jeden Fachkraft-Start (lauf.ruecklaeufer_offen, startbar.plan)."""
    z = next((z for z in zeilen(text or "") if z["an"].strip() == "Arbeitsplaner" and not z["z"].strip().startswith("erledigt")), None)
    return "wartet auf %s (Arbeitsplaner)" % z["k"] if z else None

def _ersetzen(text, z, zustand):
    m = z["m"]; alt = m.group(0)
    neu = alt[:m.start("z") - m.start()] + zustand + alt[m.end("z") - m.start():]
    return text[:m.start()] + neu + text[m.end():]

def _rein(s): return re.sub(r"\s+", " ", s.replace("|", "/")).strip()


# 2042 (2), (3) (Chef 26.11., 09:30 „wer an wen übergeben hat … das Aktuelle und Wichtige“, 09:42 „Ja“): Vorgangsdatei schlank,
# Wortlaut vollständig in docs/vorgang/archiv/NR.md
ARCHIV_KOPF = "# %s · Archiv\n\nVoller Wortlaut, den die Vorgangsdatei kürzt (2042; Chef 26.11., 09:42).\n"
SCHLANK = re.compile(r"^von \S+$")

def archivpfad(nr): return "%s/archiv/%s.md" % (ORDNER, nr)

def archiv_dazu(archiv, nr, titel, block):
    """BLOCK ans Ende des Abschnitts „## TITEL“ im Archiv (angelegt am Ende, falls er fehlt)."""
    a = archiv or ARCHIV_KOPF % nr
    b = block.strip("\n") + "\n"
    kopf = "\n## %s\n" % titel
    if kopf not in "\n" + a: return a.rstrip("\n") + "\n\n## %s\n\n%s" % (titel, b)
    i = ("\n" + a).index(kopf) - 1 + len(kopf); n = a.find("\n## ", i)
    if n < 0: return a.rstrip("\n") + "\n\n" + b
    return a[:n].rstrip("\n") + "\n\n" + b + a[n:]

def _von(z, nr, von_fn):
    m = re.search(r"\(von ([^()\s]+)\)\s*$", z["was"]) or re.search(r"\(Rückmeldung [^()]*? von ([^()\s,;]+)\)", z["was"])
    v = m.group(1) if m else (von_fn(z, nr) if von_fn else None)
    return re.sub(r"\s+", "_", _rein(v or "?"))

_VON_GIT = {}
def von_git(z, nr):
    """„wer“ einer alten Zeile: Claude-Session des Commits, der sie anlegte (git log -S), als Rolle der Besetzung, sonst …Kennung.
    Beleglauf 2042 (26.11., 11:43): je (Zeile, Vorgang) nur einmal git log -S (der anlegende Commit ändert sich nicht), sonst
    rechnet aufraeumen_alle je Versuch ~4 Min. neu und main rückt dazwischen vor."""
    if (z["k"], nr) not in _VON_GIT: _VON_GIT[(z["k"], nr)] = _von_git(z, nr)
    return _VON_GIT[(z["k"], nr)]

def _von_git(z, nr):
    rc, out, _ = _git("log", "--reverse", "--format=%(trailers:key=Claude-Session,valueonly)", "-S", "| %s |" % z["k"], "origin/main", "--", _pfad(nr))
    sid = next((re.search(r"session_\w+", l).group(0) for l in out.splitlines() if re.search(r"session_\w+", l)), None) if rc == 0 else None
    if not sid: return None
    try:
        import chefwort
        r = chefwort._rolle_aus_besetzung(sid)
        if r: return r
    except Exception:
        pass
    return "…" + sid[-6:]

def schlank_uebergaben(text, archiv, nr, von_fn=None):
    """2042 (2): erledigte Zeile → „| Ü | an | von X | seit | erledigt … |“ (wer an wen, wann, Ergebnis); Wortlaut ins Archiv."""
    alt = []
    for z in reversed(zeilen(text or "")):
        if not z["z"].strip().startswith("erledigt") or SCHLANK.match(z["was"].strip()): continue
        m = z["m"]; alt.append(m.group(0))
        text = text[:m.start("was")] + "von " + _von(z, nr, von_fn) + text[m.end("was"):]
    for z in reversed(zeilen(text)):  # Sokrates 16:15 (2042 Fassung 5): Kennungen im Ergebnis kurz (…6 Zeichen wie „von …“)
        if not z["z"].strip().startswith("erledigt") or "session_" not in z["z"]: continue
        m = z["m"]; alt.append(m.group(0))
        text = text[:m.start("z")] + re.sub(r"session_\w*?(\w{6})\b", r"…\1", z["z"]) + text[m.end("z"):]
    for r in reversed(alt):
        if r not in (archiv or ""): archiv = archiv_dazu(archiv, nr, "Übergaben", r)
    return text, archiv

def zeilen_was(text, archiv, an):
    """Wortlaut („was“) aller Zeilen an AN in Datei und Archiv (Dedupe gegen schlanke erledigte Zeilen, 2042)."""
    return "\n".join(z["was"] for z in zeilen((text or "") + "\n" + (archiv or "")) if z["an"].strip() == an)

_ABSCHNITT = re.compile(r"(?m)^## (.*)\n")
_RBLOCK = re.compile(r"(?m)^- \*\*[^*\n]+\*\*, [^\n]*:\n(?:> [^\n]*(?:\n|$))+")
_ANTWORT = re.compile(r"(?m)^\*\*Antwort[^\n]*(?:\n[^\n#][^\n]*)*")

def aufraeumen(text, archiv, nr, von_fn=None):
    """2042 (3): es bleiben Kopf, neueste Auftragsfassung, Chefworte, letzter Stand, Rückmeldungen (je höchstens 400 Zeichen),
    Übergaben (erledigte schlank), die letzte Antwort; alles andere wörtlich ins Archiv. Rückgabe (Datei, Archiv); zweimal gleich."""
    import rueckmeldung as rm
    ms = list(_ABSCHNITT.finditer(text or ""))
    if not ms: return text, archiv
    kopf = text[:ms[0].start()]
    teile = [(m.group(1), text[m.end():(ms[i + 1].start() if i + 1 < len(ms) else len(text))]) for i, m in enumerate(ms)]
    if not any(t == "Übergaben" for t, _ in teile): return text, archiv
    # alle Zeilen der Übergaben-Tabelle, gleich in welchem Abschnitt sie stehen (uebergabe hängt ans Dateiende an), in Folge nach Übergaben
    reihen = [z["m"].group(0) for z in zeilen(text)]
    teile = [(t, ZEILE.sub("", b)) for t, b in teile]
    teile = [(t, (b.replace(KOPF, "") if t == "Übergaben" else b)) for t, b in teile]
    def neueste(praefix):
        ix = [i for i, (t, _) in enumerate(teile) if t.startswith(praefix)]
        return max(ix, key=lambda i: (rm._zeit(teile[i][0]) or (0, 0, 0, 0), i)) if ix else None
    bleibt = {i for i, (t, _) in enumerate(teile) if t in ("Chefworte", "Rückmeldungen", "Übergaben")}
    bleibt |= {x for x in (neueste("Auftrag ("), neueste("Stand")) if x is not None}
    a_neu, s_neu = neueste("Auftrag ("), neueste("Stand")  # Sokrates 16:15 (2042 Fassung 5): Stand älter als der neueste Auftrag ist überholt
    if a_neu is not None and s_neu is not None and (rm._zeit(teile[s_neu][0]) or (0, 0, 0, 0)) < (rm._zeit(teile[a_neu][0]) or (0, 0, 0, 0)):
        bleibt.discard(s_neu)
    antworten = []
    aus, rein = [], []
    for i, (t, b) in enumerate(teile):
        if t == "Letzte Antwort":
            antworten += [(i, a.group(0)) for a in _ANTWORT.finditer(b)]; continue
        if i not in bleibt:
            antworten += [(i, a.group(0)) for a in _ANTWORT.finditer(b)]
            archiv = (archiv or ARCHIV_KOPF % nr).rstrip("\n") + "\n\n## %s\n%s" % (t, b.rstrip("\n") + "\n")
            continue
        if t == "Rückmeldungen":
            def kurz(m):
                global_text = m.group(0)
                zl = global_text.rstrip("\n").split("\n")
                voll = "\n".join(l[2:] for l in zl[1:])
                k = rm.kuerzen(voll, nr)
                if k == voll: return global_text
                nonlocal archiv
                if global_text.rstrip("\n") not in (archiv or ""): archiv = archiv_dazu(archiv, nr, "Rückmeldungen", global_text)
                return zl[0] + "\n> " + k + "\n"
            b = _RBLOCK.sub(kurz, b)
        if t == "Übergaben":
            fremd = [l for l in b.split("\n") if l.strip() and not l.startswith("|")]
            if fremd:
                for a in _ANTWORT.finditer(b): antworten.append((i, a.group(0)))
                archiv = archiv_dazu(archiv, nr, "Übergaben (Text)", "\n".join(fremd))
                b = "\n".join(l for l in b.split("\n") if not l.strip() or l.startswith("|"))
                b = re.sub(r"\n{3,}", "\n\n", b)
        rein.append((t, b))
    letzte = max(antworten, key=lambda x: (rm._zeit(x[1].split("\n", 1)[0]) or (0, 0, 0, 0), x[0]))[1] if antworten else None
    neu = kopf
    for t, b in rein:
        if t == "Übergaben" and letzte: neu = neu.rstrip("\n") + "\n\n## Letzte Antwort\n\n" + letzte.rstrip("\n") + "\n\n"
        neu += "## %s\n%s" % (t, b)
    if letzte and not any(t == "Übergaben" for t, _ in rein): neu = neu.rstrip("\n") + "\n\n## Letzte Antwort\n\n" + letzte.rstrip("\n") + "\n"
    i = neu.index("\n## Übergaben\n") + len("\n## Übergaben\n"); n = neu.find("\n## ", i)
    tab = "\n" + KOPF + "".join(r + "\n" for r in reihen)
    rest = re.sub(r"\n{3,}", "\n\n", neu[i:n if n >= 0 else len(neu)]).strip("\n")
    neu = neu[:i] + ("\n" + rest + "\n" if rest else "") + tab + (neu[n:] if n >= 0 else "")
    neu, archiv = schlank_uebergaben(neu, archiv, nr, von_fn)
    return rueck_erledigt(neu, archiv, nr)

RUECK_HALTEN = {"nein", "nein, Auftrag", "wirkt nein", "Beleg fehlt", "steckt fest", "Frage", "Laufanforderung"}

def rueck_erledigt(text, archiv, nr):
    """2042 Fassung 5 (5c): erledigte Rückmeldungen wörtlich ins Archiv. Erledigt: älter als der neueste Auftrag, nicht vom Chef,
    kein Nein, kein „Beleg fehlt“, „steckt fest“, keine Frage, keine Laufanforderung; und die Zählung (zaehlen, beleg_als_nein)
    bleibt gleich (sonst bleibt der Block). Gekürzte Blöcke („voll: archiv/…“) stehen schon voll im Archiv."""
    import rueckmeldung as rm
    auf = max((z for z in (rm._zeit(m.group(1)) for m in _ABSCHNITT.finditer(text or "") if m.group(1).startswith("Auftrag (")) if z),
              default=None)
    i = ("\n" + (text or "")).find("\n## Rückmeldungen\n")
    if auf is None or i < 0: return text, archiv
    ende = text.find("\n## ", i + 1); ende = len(text) if ende < 0 else ende
    soll = lambda t: (rm.zaehlen(t), rm.beleg_als_nein(t))
    vorher = soll(text)
    for m in reversed(list(_RBLOCK.finditer(text, i, ende))):
        b = rm.BLOCK.match(m.group(0))
        z = rm._zeit(b.group("zeit")) if b else None
        if not z or z >= auf or "Chef" in b.group("wer") or rm.worte(b.group("text")) & RUECK_HALTEN: continue
        neu = text[:m.start()] + text[m.end():]
        if soll(neu) != vorher: continue
        if not rm.VOLL.search(m.group(0).rstrip("\n")) and m.group(0).rstrip("\n") not in (archiv or ""):
            archiv = archiv_dazu(archiv, nr, "Rückmeldungen", m.group(0))
        text = neu
    return text, archiv

def nr_aus(kennung):
    m = re.fullmatch(r"(B?\d+(?:\.\d+)?[a-z]?)-Ü\d+", kennung)  # 1949: B<n> = Build-Auftrag
    if not m: raise Fehler("Kennung „%s“ ungültig (Form NR-Ük, etwa 1760-Ü1)" % kennung)
    return m.group(1)

def besetzung(an, nr=None):
    """Kennungen laufender Sitzungen der Rolle AN, frisch aus ARBEIT-BESETZUNG.md (beim Senden, nie aus dem Gedächtnis).
    2042 Teil 6 (Fall 2042-Ü6: Wecker an Olga/Ralf zu 2041 statt an Carla zu 2042): mit nr und einer Fachrolle nur die Sitzungen,
    deren Spalte „Vorgang“ nr ist; keine solche: alle der Rolle wie bisher (kein Wecker fällt still weg). Rollen ohne Vorgang
    (Disponent, Prüfer, …) unverändert."""
    try: t = open(os.path.join(WURZEL, "docs", "ARBEIT-BESETZUNG.md"), encoding="utf-8").read()
    except OSError: return []
    aus = []; mit_nr = []
    for z in t.splitlines():
        f = [x.strip() for x in z.split("|")]
        # Rolle bzw. Bereich (Spalte 1; Rufnamen-Sitzungen trägt lauf.py über den Vorgang ein) oder Rufname im Titel (1739)
        if len(f) > 3 and (f[1].lower() == an.lower() or f[2].startswith("[%s – " % an)):
            ids = re.findall(r"code/(session_\w+)", f[2]); aus += ids
            if nr and an in FACHPROFILE + ["Fachkraft"] and f[3] == str(nr): mit_nr += ids
    return mit_nr or aus

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
    m = re.match(r"(?i)chefwort\b\s*(\d\d\.\d\d\.,\s*\d\d:\d\d|\d\d:\d\d)?", was)
    vp, lp = _pfad(nr), "docs/LISTE-VORGAENGE.md"
    def f(alt):
        t = _mit_abschnitt(alt[vp], nr)
        aus = {}
        if m:  # 1976-Ü5 (1566-Ü11): Übergabe „Chefwort …“ hebt „ruht, beim Chef“ in NR.md und Liste im selben Commit auf wie chefwort.py
            import chefwort
            zeit = m.group(1) or fmt(jetzt())
            t = chefwort.aufheben(t, zeit)
            L = chefwort.liste_aufheben(alt[lp], nr, zeit)
            if L is not None: aus[lp] = L
        ks = [int(z["k"].rsplit("Ü", 1)[1]) for z in zeilen(t)]
        k = "%s-Ü%d" % (nr, max(ks, default=0) + 1)
        aus[vp] = t.rstrip("\n") + "\n| %s | %s | %s | %s | offen |\n" % (k, an, was, fmt(jetzt()))
        return aus, k
    k = atomar_dateien([vp] + ([lp] if m else []), f, "Übergabe %s an %s (1760)" % (nr, an))
    print("OFFEN %s an %s: %s" % (k, an, was))
    wecker(nr, k, an)
    return k

DISPONENT_ALT = "Ford"  # 1739: bis zur Umschaltung (lauf.ALT_EMPFAENGER)
ALT = {"Prüfer": "Diogenes", "Disponent": DISPONENT_ALT, "Arbeitsplaner": DISPONENT_ALT}

DISPONENT_TITEL = re.compile(r"^(?:Disponent – Büro(?:$| \()|\w+ – Disponent – )")  # 2041 d (Chef 25.11., 21:11): „Disponent – Büro (…)“ ohne Rufnamen; alte Form „Otto – Disponent – Betrieb“ (2035, Chef 19:47), bis Otto umbenannt ist; nie „Disponent-Starter“, „Wache – Disponent (…)“

PRUEFER_TITEL = re.compile(r"^\[[A-ZÄÖÜ][a-zäöüß]+ – Prüfer – ")

def _pruefer_zeilen():
    """2042 Teil 7 (3): Zeilen an den Prüfer aus allen Vorgangsdateien, frisch am Stand origin/main (fetch; jeder Prüfer schreibt
    annehmen/erledigt selbst atomar dorthin); ohne Git die lokalen Dateien."""
    _git("fetch", "-q", "origin", "main")
    rc, out, _ = _git("grep", "-h", "-E", r"^\| [^|]+ \| Prüfer \|", "origin/main", "--", ORDNER + "/")
    if rc not in (0, 1):
        d = os.path.join(WURZEL, ORDNER); out = ""
        for n in sorted(os.listdir(d)) if os.path.isdir(d) else []:
            if n.endswith(".md"):
                try: out += open(os.path.join(d, n), encoding="utf-8").read() + "\n"
                except OSError: pass
    return [z for z in zeilen(out) if z["an"].strip() == "Prüfer"]

def pruefer_frei():
    """2042 Teil 7 (Chef 22:43, 22:45; Ralf 23:27 Mangel 3): Kennungen laufender Prüfer (ARBEIT-BESETZUNG.md: Rolle Prüfer oder Titel
    „Name – Prüfer – …“), die frei sind. Frei heißt aus frischer Quelle, nicht aus dem Titel (der steht bis zum nächsten Takt alt):
    keine Zeile an den Prüfer „angenommen <Kennung>“, und trägt der Titel „in Arbeit – <Nr>“, keine offene Zeile an den Prüfer zu Nr
    (eben gestartet, noch nicht angenommen)."""
    try: t = open(os.path.join(WURZEL, "docs", "ARBEIT-BESETZUNG.md"), encoding="utf-8").read()
    except OSError: return []
    zs = None; aus = []
    for z in t.splitlines():
        f = [x.strip() for x in z.split("|")]
        if len(f) < 4 or not (f[1] == "Prüfer" or PRUEFER_TITEL.match(f[2])): continue
        if zs is None: zs = _pruefer_zeilen()
        for s in re.findall(r"code/(session_\w+)", f[2]):
            if any(ANG.match(x["z"]) and ANG.match(x["z"]).group("sid") == s for x in zs): continue
            m = re.search(r" – Prüfer – in Arbeit – ([^ ]+) – ", f[2])
            if m and any(nr_aus(x["k"]) == m.group(1) and ist_offen(x["z"]) for x in zs): continue
            if s not in aus: aus.append(s)
    return aus

def disponent():
    """2035: der laufende Disponent, die jüngste Zeile in ARBEIT-BESETZUNG.md mit Titel „Disponent – Büro …“ oder alt „Rufname – Disponent – …“ (lauf.besetzung_text
    sortiert nach Start); keine Handzeile in ARBEIT-BETRIEB.md (2001 „Disponent (aktuell)“ entfällt). Leer, bis der neue Disponent sein
    erstes `lauf.py` gelaufen ist."""
    try: t = open(os.path.join(WURZEL, "docs", "ARBEIT-BESETZUNG.md"), encoding="utf-8").read()
    except OSError: return []
    aus = []
    for z in t.splitlines():
        f = [x.strip() for x in z.split("|")]
        if len(f) > 3 and DISPONENT_TITEL.match(f[2].lstrip("[")):
            aus = re.findall(r"code/(session_\w+)", f[2])[-1:]
    return aus

BUENDEL_MIN = 15  # 2042 (2): so lange bündelt eine offene Zeile weitere Wecker an den Disponenten; danach wieder Wecker (nie Dauerschweigen)

def gebuendelt(k):
    """2042 (2, Chef 25.11., 22:03 „A“): Kennung einer anderen offenen Zeile, die den Disponenten seit seinem letzten Takt
    (Zeitmarke „**Stand:**“ in ARBEIT-BESETZUNG.md) schon geweckt hat (an Disponent oder an eine Rolle ohne Sitzung), höchstens
    BUENDEL_MIN alt; sonst None. Der Disponent liest im nächsten Takt alle offenen Zeilen (lauf.py NACHRICHT, vorgang.py offen)."""
    import herzschlag
    try: t = open(os.path.join(WURZEL, "docs", "ARBEIT-BESETZUNG.md"), encoding="utf-8").read()
    except OSError: return None
    j = jetzt(); st = herzschlag.marke(t, j.replace(tzinfo=herzschlag.BERLIN))
    if st is None: return None
    st = st.replace(tzinfo=None)
    d = os.path.join(WURZEL, ORDNER); frueh = []
    for n in sorted(os.listdir(d)) if os.path.isdir(d) else []:
        if not n.endswith(".md"): continue
        try: text = open(os.path.join(d, n), encoding="utf-8").read()
        except OSError: continue
        for z in zeilen(text):
            if z["k"] == k or not ist_offen(z["z"]): continue
            try: s = _zeit(z["seit"], j.year)
            except ValueError: continue
            if st < s <= j and (z["an"] == "Disponent" or not besetzung(z["an"])): frueh.append((s, z["k"]))
    # die älteste Zeile seit dem Takt hat sicher geweckt; ist sie älter als BUENDEL_MIN, hängt der Disponent: wieder wecken
    return min(frueh)[1] if frueh and (j - min(frueh)[0]).total_seconds() <= BUENDEL_MIN * 60 else None

def _gebuendelt_zeile(k, an):
    g = gebuendelt(k)
    if g: print("NICHTS Wecker gebündelt (2042): %s weckte den Disponenten seit seinem letzten Takt; er liest %s (an %s) im nächsten Takt" % (g, k, an))
    return g

def wecker(nr, k, an, alt=None, scharf=None):
    """WECKER an die laufenden Sitzungen von AN (sonst der alten Rolle ALT); läuft keine, WECKER an den Disponenten, der den Start
    ausgibt (1760, Sokrates 22.11., 07:08). Gibt die geweckten Kennungen zurück. 2001 (Chef 23.11., 14:38): mit tools/1727-SCHARF
    kein Ford-Ersatz mehr (auch nicht, wenn rueckmeldung.py oder chefwort.py ALT mitgeben); Disponent über disponent()."""
    scharf = _scharf() if scharf is None else scharf
    alt = "" if scharf else ALT.get(an, "") if alt is None else alt
    ss = (disponent() if an == "Disponent" and scharf else besetzung(an, nr)) or (besetzung(alt, nr) if alt else [])
    if an == "Prüfer" and scharf:  # 2042 Teil 7 (Chef 22:43, 22:45): nur ein freier Prüfer („Name – Prüfer – frei“); sonst Start
        ss = pruefer_frei()[:1]  # einer genügt; zwei Wecker für eine Zeile hieße doppelt prüfen
        for x in ss: print("PRÜFER %s frei: Wecker unten senden, wenn get_session unter 200 Tsd. zeigt, sonst lauf.py --start Prüfer %s (2042 Teil 7)" % (x, nr))
        if not ss:  # Antwort 2042-Ü27 (2): die Fachkraft startet, kein Zusatzwecker an den Disponenten (kein Doppelstart)
            print("START Prüfer %s | kein freier Prüfer: lauf.py --start Prüfer %s \"sieh in %s (%s)\"; wird dir der Start verweigert: "
                  "vorgang.py uebergabe %s Disponent \"Prüfer starten: %s\" (2042 Teil 7)" % (nr, nr, nr, k, nr, k))
            return []
    if ss and an == "Disponent" and _gebuendelt_zeile(k, an): return ss
    for s in ss: print("WECKER %s | sieh in %s (%s)" % (s, nr, k))
    if ss: return ss
    print("KEINE SITZUNG %s läuft (ARBEIT-BESETZUNG.md): die Zeile wartet; Start über den Disponenten, die neue Sitzung liest `vorgang.py offen %s`" % (an, an))
    if scharf: ds = [] if an == "Disponent" else disponent()
    else: ds = [] if DISPONENT_ALT in (an, alt) or an == "Disponent" else (besetzung("Disponent") or besetzung(DISPONENT_ALT))
    if ds and _gebuendelt_zeile(k, an): return ds
    for s in ds: print("WECKER %s | sieh in %s (%s): keine Sitzung %s, Start ausgeben" % (s, nr, k, an))
    if not ds: print("KEIN DISPONENT läuft: Wache bzw. Herzschlag meldet (1764)")
    return ds

# 2012 (Bauliste Sokrates 23.11., 23:01; Chef 23.11., 23:00 „1 bis 4 ja“): Zeilenart aus dem Anfang von „was“; eine Funktion schließt für alle
# Orte: lauf.py nach dem Start (START_ARTEN), rueckmeldung.py bei fertig/Laufanforderung/steckt fest, vorgang.py fertig und schliessen (alle)
ARTEN = {"Auftrag steht": r"Auftrag steht\b", "Nachfolger": r"Nachfolger\b", "Hinweis": r"Hinweis\b", "Rückläufer": r"Rückläufer\b"}
START_ARTEN = ("Auftrag steht", "Nachfolger")

def art(was):
    """2012: Zeilenart („Auftrag steht“, „Nachfolger“, „Hinweis“, „Rückläufer“) oder None."""
    return next((a for a, m in ARTEN.items() if re.match(m, (was or "").strip())), None)

def schliessen_text(text, nr, arten=None, grund="", bis=None):
    """2012: in TEXT jede nicht erledigte Zeile genau der Nummer NR (1589.2 ≠ 1589) schließen, deren Art in ARTEN steht (None: jede),
    mit „seit“ nicht nach BIS (datetime oder None) → „erledigt <jetzt> (<Grund>)“. Rückgabe (neuer Text, [Kennungen])."""
    jz = fmt(jetzt()); aus = []
    for z in reversed(zeilen(text or "")):
        if nr_aus(z["k"]) != nr or z["z"].strip().startswith("erledigt"): continue
        if arten is not None and art(z["was"]) not in arten: continue
        if bis is not None:
            try:
                if _zeit(z["seit"], bis.year) > bis: continue
            except ValueError: continue
        text = _ersetzen(text, z, "erledigt %s (%s)" % (jz, _rein(grund)[:100])); aus.append(z["k"])
    return text, list(reversed(aus))

MAIN_ZEILE = re.compile(r"auf main, Vollzug mit Commit: `?([0-9a-f]{7,40})\b")

def main_zeilen_schliessen_text(text, nr, auf_main_fn):
    """2041 c (Fälle 2035-Ü15/24/28): nicht erledigte Zeile „auf main, Vollzug mit Commit: <c> …“ der Nummer NR schließt sich, wenn
    auf_main_fn(c) True ist (Commit auf origin/main); False oder None (unbekannt) lässt sie offen. Rückgabe (neuer Text, [Kennungen])."""
    jz = fmt(jetzt()); aus = []
    for z in reversed(zeilen(text or "")):
        m = MAIN_ZEILE.match(z["was"].strip())
        if not m or nr_aus(z["k"]) != nr or z["z"].strip().startswith("erledigt") or auf_main_fn(m.group(1)) is not True: continue
        text = _ersetzen(text, z, "erledigt %s (Commit %s auf origin/main, 2041 c)" % (jz, m.group(1))); aus.append(z["k"])
    return text, list(reversed(aus))

def schliessen_nr(nr, arten=None, grund="", bis=None):
    """2012: schliessen_text auf docs/vorgang/NR.md über atomar (origin/main, ein Commit, sicher gegen gleichzeitige Schreiber).
    Fehlt die Datei oder ist nichts zu schließen: kein Commit, []."""
    def f(alt):
        if not alt.strip(): return alt, []
        return schliessen_text(alt, nr, arten, grund, bis)
    return atomar(nr, f, "Übergaben %s geschlossen: %s (2012)" % (nr, _rein(grund)[:100]))

def kurz(paare, n=6):
    """2012 (5): „Kennung was; …“ für die ersten N (Rangfolge des Aufrufers), dahinter „+M weitere: Kennung, …“ statt sie wegzulassen."""
    s = "; ".join("%s %s" % (k, w) for k, w in paare[:n])
    return s + ("; +%d weitere: %s" % (len(paare) - n, ", ".join(k for k, _ in paare[n:])) if len(paare) > n else "")

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
    if wort == "ANGENOMMEN":  # 2041 d: Titel „<Rufname> – in Arbeit – <Nr> – <Betreff>“; Büro, Leitung, Abnahme behalten ihren
        try:
            import rufname
            z = rufname.titel_zeile(sid, nr, "in Arbeit")
            if z: print(z); print(rufname.TITEL_HINWEIS)
        except Exception as e:
            print("TITEL nicht gebaut (%s)" % e)
    return wort

START_ZEILE = re.compile(r"\s*Fachkraft starten\b")  # 2042 Teil 6 (5): Otto schloss 1708-Ü10 ohne Start (0ea352814)

def erledigt(kennung, gestartet=None):
    nr, sid = nr_aus(kennung), sitzung()
    if gestartet and not re.fullmatch(r"session_\w+", gestartet): raise Fehler("„%s“ ist keine Sitzungskennung (session_…)" % gestartet)
    def f(alt):
        z = _finde(alt, kennung); zu = z["z"]; m = ANG.match(zu)
        if zu.startswith("erledigt"): return alt, "SCHON ERLEDIGT"
        if not m or m.group("sid") != sid: return alt, "NICHT DEINE"
        if START_ZEILE.match(z["was"]) and not gestartet:
            raise Fehler("„Fachkraft starten“ erledigt nur mit der Kennung der gestarteten Sitzung: vorgang.py erledigt %s session_… (2042)" % kennung)
        return _ersetzen(alt, z, "erledigt %s %s" % (fmt(jetzt()), sid) + (" Start %s" % gestartet if gestartet else "")), "ERLEDIGT"
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

def _main_zeilen_schliessen():
    """2041 c: je Vorgangsdatei mit offener „auf main“-Zeile, deren Commit auf origin/main steht, ein Commit (atomar); Fehler: Warnung."""
    import liegt
    kand = [nr for nr, t in _alle_dateien() if main_zeilen_schliessen_text(t, nr, lambda c: liegt.auf_main(c, WURZEL))[1]]
    for nr in kand:
        try:
            ks = atomar(nr, lambda alt, nr=nr: main_zeilen_schliessen_text(alt, nr, lambda c: liegt.auf_main(c, WURZEL)), "Übergaben %s: Commit auf origin/main (2041 c)" % nr)
            if ks: print("vorgang.py: Übergaben geschlossen (Commit auf main): %s (2041 c)" % ", ".join(ks))
        except Fehler as e:
            print("WARNUNG auf-main-Zeilen %s nicht geschlossen: %s (2041 c)" % (nr, e))

OFFEN_MAX = 5  # 2042 (e): Ausgabe von `vorgang.py offen` höchstens 5 Zeilen, Rest als Zahl (--alle zeigt alle)

def zeigen(liste, an=None, alle=False):
    """2042 (e): höchstens OFFEN_MAX Zeilen in Büro-Folge (Eilt zuerst, Hinweis Fritz 10:36); nicht gezeigte neue Zustände
    (wieder offen, steckt fest, Frist) nennt die Schlusszeile mit Kennung, damit nichts still verschwindet."""
    zeig = liste if alle or len(liste) < OFFEN_MAX else liste[:OFFEN_MAX - 1]
    for z, nr, wie in zeig:
        print("%s | an %s | %s | seit %s | %s" % (z["k"], z["an"], z["was"], z["seit"], wie))
    rest = liste[len(zeig):]
    neu = ["%s %s" % (z["k"], wie) for z, nr, wie in rest if wie != "offen"]
    print("vorgang.py offen: %d Zeile(n)%s%s%s" % (len(liste), (" an " + an) if an else "",
          ", %d weitere: vorgang.py offen%s --alle" % (len(rest), (" " + an) if an else "") if rest else "",
          "; darunter neu: " + "; ".join(neu) if neu else ""))

def offen(an=None, sitzungen_dateien=(), still=False, alle=False):
    """still: nichts drucken (lauf.py ruft es je Lauf, 1739 Befund 1); Rückgabe [(Zeile, Nr, wie)].
    1782: Frist abgelaufen und Halter ruht, oder Halter abgebrochen (auch vor der Frist) → beim ersten Mal „offen (wieder 1)“,
    beim zweiten Mal „steckt fest“ (wie „wieder offen …“ bzw. „steckt fest …“ in wie; lauf.py gibt es an Sokrates)."""
    st = _status(list(sitzungen_dateien)); jz = jetzt(); liste = []
    def frei_ab(z, m):
        h = (st or {}).get(m.group("sid"), "unbekannt" if st is None else "ruht")
        if h == "abgebrochen": return h
        if _zeit(m.group("bis"), jz.year) > jz: return None
        return h
    _main_zeilen_schliessen()  # 2041 c
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
    zeigen(liste, an, alle)
    return liste

def _merkmale(text, nr):
    """2042 Prüfung: was beim Aufräumen gleich bleiben muss (Zählung, Beleg-Nein, erstes Nein, Chefworte, neuester Auftrag, offene Zeilen)."""
    import rueckmeldung as rm, lauf
    erstes = next((m.group("zeit") for m in rm.BLOCK.finditer(rm.rueck(text)) if {"nein", "nein, Auftrag", "wirkt nein"} & rm.worte(m.group("text"))), None)
    try:
        r = lauf.juengster_auftrag(text); auf = text[r[0]:r[1]] if r else None
    except Exception as e: auf = "Fehler %s" % e
    return (rm.zaehlen(text), rm.beleg_als_nein(text), erstes, abschnitt(text, "Chefworte"), auf,
            [z["m"].group(0) for z in zeilen(text) if not z["z"].strip().startswith("erledigt")])

def aufraeumen_alle(nrs=None, probe=False):
    """2042 (3): `vorgang.py aufraeumen [NR …] [--probe]`: alle (oder die genannten) Vorgangsdateien in EINEM Commit aufräumen;
    vorher Probe je Datei (Merkmale vorher = nachher), bei einer Abweichung wird nichts geschrieben."""
    import rueckmeldung as rm
    _git("fetch", "-q", "origin", "main")
    rc, ls, _ = _git("ls-tree", "--name-only", "origin/main", ORDNER + "/")
    alle = [os.path.basename(x)[:-3] for x in ls.splitlines() if x.endswith(".md")]
    nrs = [n for n in alle if not nrs or n in nrs]
    def rechnen(alt):
        neu, bericht, ungleich = {}, [], []
        for nr in nrs:
            p, ap = _pfad(nr), archivpfad(nr)
            t, a0 = alt.get(p, ""), alt.get(ap, "")
            rm._ARCHIV.clear(); rm._ARCHIV["archiv/%s.md" % nr] = a0
            vor = _merkmale(t, nr)
            t2, a2 = aufraeumen(t, a0, nr, von_git)
            rm._ARCHIV["archiv/%s.md" % nr] = a2 or ""
            nach = _merkmale(t2, nr)
            if vor != nach: ungleich.append(nr)
            bericht.append((nr, len(t.encode()), len(t2.encode())))
            if t2 != t: neu[p] = t2
            if a2 and a2 != a0: neu[ap] = a2
        rm._ARCHIV.clear()
        return neu, (bericht, ungleich)
    pfade = [_pfad(n) for n in nrs] + [archivpfad(n) for n in nrs]
    if True:  # Probe immer zuerst, am gelesenen Stand
        alt = {}
        for p in pfade:
            rc, t, _ = _git("show", "origin/main:" + p); alt[p] = t + "\n" if rc == 0 and t else ""
        _, (bericht, ungleich) = rechnen(alt)
        vorher, nachher = sum(b[1] for b in bericht), sum(b[2] for b in bericht)
        print("PROBE %d Dateien: gleich %d, ungleich %d%s" % (len(bericht), len(bericht) - len(ungleich), len(ungleich), (" (" + ", ".join(ungleich[:20]) + ")") if ungleich else ""))
        print("BYTE gesamt %d → %d" % (vorher, nachher))
        for nr, v, n in sorted(bericht, key=lambda b: -b[1])[:5]: print("BYTE %s.md %d → %d" % (nr, v, n))
        if probe or ungleich:
            if ungleich: print("NICHTS geschrieben: Merkmale ungleich")
            return ungleich
    def f(alt):
        neu, (bericht, ungleich) = rechnen(alt)
        if ungleich: raise Fehler("Merkmale ungleich: " + ", ".join(ungleich[:20]))
        return neu, len(neu)
    n = atomar_dateien(pfade, f, "2042 (3): Vorgangsdateien aufgeräumt, Wortlaut in docs/vorgang/archiv/ (vorgang.py aufraeumen)")
    print("GESCHRIEBEN %s Dateien in einem Commit" % n)
    return []

def haupt(a):
    frist = FRIST_MIN
    if "--frist" in a:
        i = a.index("--frist"); frist = int(a[i + 1]); del a[i:i + 2]
    try:
        b = a[0] if a else ""
        if b == "uebergabe" and len(a) == 4: return uebergabe(a[1], empfaenger(a[2]), a[3])  # 1946
        if b == "annehmen" and len(a) == 2: return annehmen(a[1], frist)
        if b == "verlaengern" and len(a) == 2: return annehmen(a[1], frist, True)
        if b == "erledigt" and len(a) in (2, 3): return erledigt(*a[1:])
        if b == "freigeben" and len(a) == 1: return freigeben()
        if b == "aufraeumen":
            probe = "--probe" in a
            r = aufraeumen_alle([x for x in a[1:] if x != "--probe"] or None, probe)
            sys.exit(1 if r else 0)
        if b == "offen":
            s = []
            if "--sitzungen" in a:
                i = a.index("--sitzungen"); s = a[i + 1:]; a = a[:i]
            alle = "--alle" in a
            a = [x for x in a if x != "--alle"]
            return offen(a[1] if len(a) > 1 else None, s, alle=alle)
    except Fehler as e:
        sys.exit("vorgang.py %s: %s; nichts geschrieben" % (b, e))
    sys.exit(__doc__)

BEFEHLE = ("uebergabe", "annehmen", "verlaengern", "erledigt", "freigeben", "offen", "aufraeumen")

if __name__ == "__main__":
    r = haupt(sys.argv[1:])
    sys.exit(3 if r == "BELEGT" else 0)
