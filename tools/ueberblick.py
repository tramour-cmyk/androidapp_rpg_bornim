#!/usr/bin/env python3
"""Überblick für den Chef (1313, Chef 15.11., 19:37): Themenblöcke mit Stand und die nächsten 20 Vorgänge in Reihenfolge.

„das sind die nächsten 20 Aufgaben, die kommen, in der richtigen Reihenfolge … Welche Nummer ist das? Um was geht's da? …
Und wenn einer fertig ist, dann rückt halt das nächste hinten nach. Oder wenn was vorgezogen wird, muss die Liste auch
aktualisiert werden. Das muss auf Chefsache direkt sichtbar stehen.“

Steht oben in `docs/chefsache/README.md` (zug-index.py rechnet ihn bei jedem Lauf neu, also bei jedem Push auf die Vorgangsliste).
Reihenfolge der 20: erst was sofort geht (startbar, in Arbeit), dann was wartet; darin „jetzt“ (jüngstes zuerst: was der Chef zuletzt
vorzieht, steht auf Rang 1), dann Muss,
dann Kür; darin nach Themenblock, dann nach dem Rang beim Besitzer (`startbar.plan`, also `vorgang.py rang`). Nicht in den 20:
ruht, nach Meilenstein, Idee, Dauer, aufgeteilt, Pflege-Zeilen, „gebaut“ (fährt mit dem nächsten Build oder wartet auf Diogenes)
und was in einem Build auf deinen Test wartet (Zählzeile darunter; Sokrates 15.11., 20:05). Vorziehen heißt: „jetzt“ oder
`vorgang.py rang` beim Besitzer.

Aufruf: python3 tools/ueberblick.py   (Markdown auf stdout)
"""
import os, re, sys, datetime

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startbar as s

# Themenblöcke (1727, Chef 19.11., 12:24): einzige Quelle ist docs/chefsache/themenbloecke.md (Zuschnitt und Reihenfolge
# legt der Chef fest, Reihenfolge = Zeilenfolge). Zuordnung ohne Raten: zuerst Vorgangsnummer (Vorsilbe), sonst Bereich der
# Zeile; was keinem Block zufällt, steht unter „Übriges“. Ersetzt die feste Liste hier und die Teilprojekte (1061).
KAPITEL1 = "Kapitel 1 fertig (Godot, BRS)"
THEMEN = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "docs", "chefsache", "themenbloecke.md")


def _liste(zelle):
    return tuple(x.strip() for x in zelle.split(",") if x.strip() and x.strip() not in ("–", "-"))


def themen_laden(pfad=THEMEN):
    """[(Name, {num, nr, bereich, kap1, ruht, profil})] in der Reihenfolge der Datei."""
    bl = []
    for z in open(pfad, encoding="utf-8"):
        c = [x.strip() for x in z.strip().strip("|").split("|")]
        if len(c) < 7 or not c[0].isdigit():
            continue
        bl.append((c[1], {"num": int(c[0]), "profil": c[2], "kap1": c[3].lower() == "ja",
                          "ruht": "" if c[4] in ("–", "-") else c[4], "bereich": _liste(c[5]), "nr": _liste(c[6])}))
    if not bl:
        raise SystemExit("ueberblick.py: keine Themenblöcke in %s" % pfad)
    return bl


BLOECKE = themen_laden()
UEBRIG = "Übriges"
# 1440 (Chef 16.11., 14:19): jeder Block trägt eine feste Nummer („num“), damit der Chef „Block 3“ sagen kann; sie bleibt,
# auch wenn Blöcke umgestellt werden; ein neuer Block bekommt die nächste freie Nummer, nie eine alte.
UEBRIG_NUM = 9
RUHT = ("ruht", "nach Meilenstein", "Idee", "Dauer", "aufgeteilt", "erledigt", None)
JETZT_ZEIT = re.compile(r"„jetzt“ (\d\d)\.(\d\d)\.(?:,? (\d\d):(\d\d))?")
ANZAHL = 20


def block(d):
    for k, (_, regel) in enumerate(BLOECKE):
        if any(d["nr"] == n or d["nr"].startswith(n + ".") for n in regel.get("nr", ())):
            return k
    for k, (_, regel) in enumerate(BLOECKE):
        if (d.get("bereich") or "") in regel.get("bereich", ()):
            return k
    return len(BLOECKE)


def name(k):
    if k >= len(BLOECKE):
        return UEBRIG
    n, r = BLOECKE[k]
    return n + (" (ruht bis %s)" % r["ruht"] if r.get("ruht") else "")


def nummer(k):
    return BLOECKE[k][1]["num"] if k < len(BLOECKE) else UEBRIG_NUM


def worum(titel, n=80):
    t = re.sub(r"^Von [^:(]+(?:\([^)]*\))?[^:]*:\s*", "", titel)  # „Von Sokrates (Chef …): …“ → Inhalt
    t = re.sub(r"\s*·\s*„jetzt“.*$", "", t)
    t = re.sub(r"\s*·\s*zurück t\d+.*$", "", t)
    t = re.sub(r"\s*\([^()]*\)", "", t).strip(" ;,")
    return t if len(t) <= n else t[:n - 1].rstrip() + "…"


def wartet_auf_test(d):
    """Liegt bei dir: in einem Build, „zu testen“ (schon vorgelegt) oder gebaut mit t<n> im Feld. 1332: „ohne Rückmeldung t<n>“ liegt
    beim Besitzer (startbar), nicht bei dir."""
    if d["wort"] == "zu testen": return not s.ohne_rueckmeldung(d)
    return d["wort"] == "gebaut" and (str(d.get("build") or "").strip().isdigit() or any(re.fullmatch(r"t\d+", t) for t in d["warte"]))


def bei_diogenes(d):
    """Werkzeug gebaut: wartet nur noch auf „greift“ von Diogenes (724 A), keine Arbeit, die kommt."""
    return s.b_gebaut(d) and not s.b_nicht_auf_main(d)


def jetzt_von(d):
    m = JETZT_ZEIT.search(d["titel"] + " " + d["stand"])
    if not m: return None
    tag = s.jahr_von(int(m.group(1)), int(m.group(2)))
    return datetime.datetime(tag.year, tag.month, tag.day, int(m.group(3) or 0), int(m.group(4) or 0))


def besetzt(text=None):
    """1592 (Chef 17.11., 17:00/18:50): „in Arbeit“ = Vorgang einer Sitzung laut Besetzung (Spalte Vorgang, lauf.py --besetzung),
    nicht nur der Stand „in Arbeit“, den kaum eine Zeile trägt; Betrieb zählt nicht."""
    if text is None:
        try: text = open(os.path.join(s.DOCS, "ARBEIT-BESETZUNG.md"), encoding="utf-8").read()
        except OSError: return set()
    aus = set()
    for z in text.splitlines():
        f = [x.strip() for x in z.strip().strip("|").split("|")]
        if len(f) >= 3 and f[0] not in ("Rolle", "") and not f[0].startswith("---") and re.fullmatch(r"\d[0-9a-zA-Z.]*", f[2]): aus.add(f[2])
    return aus


def in_arbeit(d, bes):
    return d["wort"] == "in Arbeit" or (d["nr"] in bes and d["wort"] in ("startbar", "offen", "wartet", "Chef"))  # gebaut, zum Testen, ruhend: Sitzung trägt nur noch den alten Titel


def kurzstand(d, grund, bes=frozenset()):
    if grund is None and in_arbeit(d, bes): return "in Arbeit"  # 1592
    # 1497 (Chef 16.11., 22:24 „17 sind von Jerry, da stimmt doch was nicht“): gebaute Punkte ohne Antwort im Test hießen „startbar“
    m = re.search(r"ohne Rückmeldung (t\d+)", d.get("stand", ""))
    if grund is None and m: return "gebaut, %s ohne deine Antwort" % m.group(1)
    if grund is None: return {"in Arbeit": "in Arbeit"}.get(d["wort"], "startbar")
    g = re.sub(r"\s*\(.*$", "", grund)
    return g[:40]


def rang_je_besitzer():
    """Nummer → (Platz beim Besitzer, Grund der Sperre oder None) aus startbar.plan (eigene Zeilen)."""
    aus = {}
    for r in sorted({d["besitzer"] for d in s.zeilen_liste()} - {"Ideen"}):
        try: zs = s.plan(r)
        except Exception: continue
        k = 0
        for z in zs:
            if "fuer" in z[3]: continue
            aus[z[0]] = (k, z[4]); k += 1
    return aus


def rechnen():
    zs = [d for d in s.zeilen_liste() if d["wort"] not in ("erledigt",) and d["besitzer"] != "Ideen" and d["nr"] not in s.SONDER]
    rang = rang_je_besitzer()
    kommt, test, pruef, gebaut = [], [], [], []
    for d in zs:
        if wartet_auf_test(d): test.append(d); continue
        if bei_diogenes(d): pruef.append(d); continue
        if d["wort"] == "gebaut": gebaut.append(d); continue  # Sokrates 20:05: fährt mit dem nächsten Build, keine Arbeit, die kommt
        if d["wort"] in RUHT or d["kl"] in ("–", "-"): continue
        k, grund = rang.get(d["nr"], (999, s.sperre(d)))
        j = jetzt_von(d)
        muss = d["kl"] == "M"
        # erst, was sofort geht (startbar, in Arbeit), dann was noch wartet, auch bei „jetzt“ (Sokrates 20:05); darin „jetzt“, Muss, Kür
        key = (0 if grund is None else 1, 0 if j else 1, 0 if muss else 1, -(j or datetime.datetime.min).timestamp() if j else 0, block(d), k)
        kommt.append((key, d, grund))
    kommt.sort(key=lambda x: x[0])
    return zs, kommt, test, pruef, gebaut


ROLLEN_REIHE = ["Tom", "Jerry", "Spike", "Homer", "Diogenes", "Sokrates", "Perikles"]


def reihe():
    """1893: alte Liste ROLLEN_REIHE, umgestellte Liste je Profil ohne Disponent (startet selbst, hat keine Zeilen). Liest die
    Liste neu: startbar.NEU gilt für die zuletzt gelesene, `morgen()` liest den Stand von 0:00 (am Umschalttag noch alt)."""
    s.vorgangsliste(s.lesen(s.LISTE))
    return [p for p in s.profile() if p != "Disponent"] if s.NEU else ROLLEN_REIHE
CHEF_ART = ("test", "entscheiden", "tun", "ansehen", "billigen")  # 1391: Folge nach Vorschlag Sokrates (Testbitte hält die meisten Zeilen)


def chef_naechstes():
    """1391 (Chef 16.11., 09:20 „Dann weiß ich nämlich, was ich als nächstes immer zu erledigen habe“): die Datei der Chefsache, die
    am meisten aufhält: Testbitte (t<n>: Zeilen mit Build n „zu testen“), dann entscheiden/, tun/, ansehen/, billigen/; je Datei die
    Zeilen, die auf sie warten (auch eine Stufe weiter); Gleichstand: kleinere Nummer (älter) zuerst."""
    zs = s.vorgangsliste(s.lesen(s.LISTE))
    def warten_auf(k):
        direkt = {d["nr"] for d in zs if any(w == k or w == "Chef " + k for w in d["warte"])}
        return direkt | {d["nr"] for d in zs if set(d["warte"]) & direkt}
    kand = []
    for art in ("ansehen", "entscheiden", "tun", "billigen"):
        ordner = os.path.join(s.DOCS, "chefsache", art)
        for f in sorted(os.listdir(ordner)) if os.path.isdir(ordner) else []:
            if not f.endswith(".md"): continue
            k = f.split("-")[0]
            m = re.fullmatch(r"t(\d+)", k)
            if m:
                n, a = sum(1 for d in zs if d.get("build") == m.group(1) and d["wort"] == "zu testen"), "test"
            else:
                n, a = len(warten_auf(k)), art
            zahl = int(re.match(r"t?(\d+)", k).group(1)) if re.match(r"t?\d", k) else 10 ** 6
            kand.append((CHEF_ART.index(a), -n, zahl, art, f, k, n))
    kand.sort()
    if not kand: return "nichts offen in der Chefsache"
    _, _, _, art, f, k, n = kand[0]
    was = {"ansehen": "testen" if k.startswith("t") else "ansehen", "entscheiden": "entscheiden", "tun": "tun", "billigen": "billigen"}[art]
    return "[%s](%s/%s) %s%s" % (k, art, f, was, (", hält %d Zeilen" % n if n else "")) + \
        ("; dann %d weitere" % (len(kand) - 1) if len(kand) > 1 else "")


def besetzt_rolle(rolle):
    """1640 (Chef 18.11., 09:03: Spike „leer“, obwohl er laut Besetzung an 1619 arbeitete): Vorgang der laufenden Sitzung der Rolle aus
    ARBEIT-BESETZUNG.md, sonst None."""
    try: t = open(os.path.join(s.DOCS, "ARBEIT-BESETZUNG.md"), encoding="utf-8").read()
    except OSError: return None
    for z in t.splitlines():
        sp = [x.strip() for x in z.strip().strip("|").split("|")]
        if len(sp) >= 3 and sp[0] == rolle and sp[2] not in ("", "–", "-"): return sp[2]
    return None


def je_rolle():
    """1364 (Chef 16.11., 06:52 „jeder braucht doch einen Job“): je Rolle die nächste Zeile, wie Ford sie startet (lauf.stand, mit
    Übernahme), oder „leer, weil …“ mit den häufigsten Gründen; eine Pause, die startbares Muss liegen lässt, sagt es."""
    import collections, lauf
    rr = reihe()  # 1893: vor lauf.stand(), das sich nach der zuletzt gelesenen Liste richtet
    st = lauf.stand()
    aus = ["| **Chef** | %s |" % chef_naechstes().replace("|", "/")]  # 1391
    for r in rr:
        if r not in st: continue
        muss, kuer, p, _ = st[r]
        def zeile(x, art):
            t = x[2]
            vor = "Übernahme von %s: " % re.match(r"Übernahme von (\w+)", t).group(1) if t.startswith("Übernahme von") else ""
            t = re.sub(r"^Übernahme von [^:]*\):\s*", "", t)
            return "%s %s%s (%s)" % (x[0], vor, worum(t, 60), art)
        if p:
            was = "Pause bis %s" % p + ("; lässt liegen: %s" % ", ".join(x[0] for x in muss[:5]) if muss else "")
        elif muss: was = zeile(muss[0], "Muss") + ("; dann %d weitere" % (len(muss) - 1) if len(muss) > 1 else "")
        elif kuer: was = zeile(kuer[0], "nach dem Meilenstein" if kuer[0][1] == "N" else "Kür")
        else:
            # 1494 (Chef 16.11., 21:50 „Auf welche 5 Rückläufer wartest du denn?“): „wartet auf 1125“ kam als „wartet auf“
            # ohne Ziel, „ruht bis 23.11.“ als „ruht bis“; Vorgangsnummern jetzt gesammelt genannt, „ruht bis“ heißt „ruht“
            g, nrn = collections.Counter(), {}
            for z in s.plan(r):
                if not z[4] or "fuer" in z[3]: continue
                m = re.match(r"wartet auf (\d[\w.]*)", z[4])
                w = "wartet auf Vorgang" if m else re.sub(r"\s*[(:;,].*$|\s+\d.*$", "", z[4])
                w = "ruht" if w == "ruht bis" else w
                g[w] += 1
                if m: nrn.setdefault(w, []).append(m.group(1))
            was = "leer, weil " + (", ".join("%d %s" % (n, w) + (" (%s)" % ", ".join(nrn[w]) if w in nrn else "")
                                             for w, n in g.most_common(3)) or "keine offene Zeile")
        b = besetzt_rolle(r)
        if b: was = "läuft: %s (Besetzung); %s" % (b, was)
        aus.append("| %s | %s |" % (r, was.replace("|", "/")))
        for zus, team in ({} if s.NEU else s.ZUSATZ).items():  # 1371; 1893: an der neuen Liste kein Zusatzentwickler (D254.2, Chef 16.11., 07:02 „den kann man auch Arbeit geben“): Aushilfe nimmt Startbares ihres Teams
            if team != r: continue
            eigen = [x for x in muss if not x[2].startswith("Übernahme von")]
            zw = (eigen[0][3].get("zweig") or "–") if eigen else "–"
            frei = [x for x in eigen[1:] if (x[3].get("zweig") or "–") in ("–", "-", "", None) or x[3].get("zweig") != zw]
            frei = [x for x in frei if not re.search(r"nur %s\b" % team, x[2] + " " + x[3].get("stand", ""))]
            if frei: wz = zeile(frei[0], "Muss von %s, neben dessen Arbeit" % team) + ("; dann %d weitere" % (len(frei) - 1) if len(frei) > 1 else "")
            else: wz = "leer, weil %s kein zweites unabhängiges Muss hat" % team + (" (Pause)" if p else "")
            aus.append("| %s | %s |" % (zus, wz.replace("|", "/")))
    return aus


def offen_filter(d):
    return d["wort"] not in ("erledigt",) and d["besitzer"] != "Ideen" and d["nr"] not in s.SONDER


ARCHIV_NR = re.compile(r"(?m)^\|\s*([0-9][0-9A-Za-z.]*)\s*\|")


def _stand(c):
    """Stand der Vorgangsliste an Commit c (None = jetzt) → (offen je Block, offene Nummern, alle Nummern mit Archiv) oder None."""
    if c is None:
        liste, archiv = s.zeilen_liste(), s.lesen("LISTE-VORGAENGE-ARCHIV.md")
    else:
        text = s._git("show", "%s:docs/%s" % (c, s.LISTE)).stdout
        if not text: return None
        liste, archiv = s.vorgangsliste(text), s._git("show", "%s:docs/LISTE-VORGAENGE-ARCHIV.md" % c).stdout
    je = {}
    for d in liste:
        if offen_filter(d): je[block(d)] = je.get(block(d), 0) + 1
    return je, {d["nr"] for d in liste if offen_filter(d)}, {d["nr"] for d in liste} | set(ARCHIV_NR.findall(archiv))


def _bilanz(alt, neu_st):
    """erledigt und neu zwischen zwei Ständen, Zählweise 1412 (Archiv mit, SONDER und Ideen aus)."""
    neu = neu_st[2] - alt[2]
    return len({n for n in (alt[1] | neu) if n not in neu_st[1] and n not in s.SONDER}), len(neu)


def morgen(jetzt=None):
    """1495 (Chef 16.11., 22:12 „jetzt“, ersetzt 1412 mit 6:00): erledigt und neu auf Kalendertage bis 24 Uhr Berliner Zeit,
    für heute (seit 0:00), gestern (Stand 0:00 gestern gegen 0:00 heute), Woche (seit Montag 0:00), Monat (seit dem 1., 0:00);
    fehlt ein Git-Stand so weit zurück, zählt der früheste („seit <Datum>“). → (offen je Block um 0:00, Zeilen) oder None."""
    import zoneinfo
    tz = zoneinfo.ZoneInfo("Europe/Berlin")
    jetzt = jetzt or datetime.datetime.now(tz)
    null = jetzt.replace(hour=0, minute=0, second=0, microsecond=0)
    grenzen = {"heute": null, "gestern": null - datetime.timedelta(days=1),
               "Woche": null - datetime.timedelta(days=null.weekday()), "Monat": null.replace(day=1)}
    def tag_von(c):
        return s._git("-c", "log.showSignature=false", "log", "-1", "--date=format-local:%d.%m.", "--format=%cd", c).stdout.strip()
    def lesbar(c):
        st = _stand(c)
        return st if st and st[1] else None   # 1496: vor 08.11. hatte die Liste kein Feld Stand, offen las sich als 0
    def erster_lesbarer(t):
        """frühester Stand der Vorgangsliste nach t mit lesbaren offenen Zeilen (Halbierung über die Commits der Liste)."""
        cs = s._git("log", "--reverse", "--format=%H", "--since=" + t.isoformat(), "HEAD", "--", ":/docs/" + s.LISTE).stdout.split()  # Pfad im Repo des Werkzeugs: lauf setzt s.DOCS auf ../bornim-main (Nebenfund 1893)
        lo, hi = 0, len(cs)
        while lo < hi:
            m = (lo + hi) // 2
            if lesbar(cs[m]): hi = m
            else: lo = m + 1
        return cs[lo] if lo < len(cs) else None
    staende, seit = {}, {}
    for k, t in grenzen.items():
        c = s._git("rev-list", "-1", "--before=" + t.isoformat(), "HEAD").stdout.strip()
        st, tag = (lesbar(c), None) if c else (None, None)
        if st is None:
            c = erster_lesbarer(t)
            if not c: return None
            st, tag = lesbar(c), tag_von(c)
        staende[k], seit[k] = st, tag
    jetzt_st = _stand(None)
    zahlen = {"heute": _bilanz(staende["heute"], jetzt_st), "gestern": _bilanz(staende["gestern"], staende["heute"]),
              "Woche": _bilanz(staende["Woche"], jetzt_st), "Monat": _bilanz(staende["Monat"], jetzt_st)}
    kopf = ["%s (seit %s)" % (k, seit[k]) if seit[k] else k for k in grenzen]
    zeilen = ["**Erledigt und neu** (Kalendertage bis 24 Uhr; Woche ab Montag, Monat ab dem 1.; in Klammern bei „offen“: Stand 0:00 heute; netto plus = weniger offen)", "",
              "| | " + " | ".join(kopf) + " |", "|---|" + "---|" * len(kopf),
              "| erledigt | " + " | ".join(str(zahlen[k][0]) for k in grenzen) + " |",
              "| neu | " + " | ".join(str(zahlen[k][1]) for k in grenzen) + " |",
              # 1496 (Chef 16.11., 22:17 „die beiden Werte voneinander abziehen … netto, wo man steht“): plus = weniger offen
              "| **netto** (erledigt − neu) | " + " | ".join(("**%+d**" % (zahlen[k][0] - zahlen[k][1])).replace("-", "−") for k in grenzen) + " |"]
    # 1496 (Chef 16.11., 22:20 „damit das sich erklärt“): warum ein Zeitraum später beginnt
    for k in grenzen:
        if seit[k]:
            zeilen += ["", "%s erst ab %s: vorher hatte die Vorgangsliste kein Feld Stand, offene Vorgänge sind dort nicht zählbar." % (k, seit[k])]
    return staende["heute"][0], "\n".join(zeilen)


def md():
    zs, kommt, test, pruef, gebaut = rechnen()
    bes = besetzt()
    # Stand = letzte Änderung der Vorgangsliste (Berliner Zeit), nicht die Uhr: sonst schriebe jeder Lauf die Übersicht neu
    stand = s._git("-c", "log.showSignature=false", "log", "-1", "--date=format-local:%d.%m., %H:%M", "--format=%cd", "--",
                   ":/docs/" + s.LISTE).stdout.strip() or s.JETZT.strftime("%d.%m., %H:%M")
    aus = ["## Überblick", "",
           "Vom Werkzeug gerechnet (`tools/ueberblick.py`, 1313), Vorgangsliste vom %s, neu bei jeder Änderung. "
           "Reihenfolge der Blöcke und ihren Zuschnitt legst du fest; vorziehen: sag es, wir setzen den Rang beim Besitzer. "
           "Die Blocknummer bleibt fest („Block 3“), auch wenn die Reihenfolge sich ändert. „In Arbeit“: eine Sitzung hat den Vorgang laut Besetzung (`ARBEIT-BESETZUNG.md`, stündlich)." % stand, "",
           "**Themenblöcke**", "", "| Block | offen | Muss | in Arbeit | zum Testen | ruht | nächster |", "|---|---|---|---|---|---|---|"]
    erst = {}
    for key, d, grund in kommt:
        erst.setdefault(block(d), d)
    kopf = False
    try: mo = morgen()
    except Exception: mo = None   # 1412, 1495: ohne Git-Verlauf keine Klammer
    for k in list(range(len(BLOECKE))) + [len(BLOECKE)]:
        je = [d for d in zs if block(d) == k]
        if not je: continue
        kap1 = k < len(BLOECKE) and BLOECKE[k][1].get("kap1")
        if kap1 and not kopf:
            aus.append("| **%s** | | | | | | |" % KAPITEL1); kopf = True
        n = erst.get(k)
        aus.append("| %s | %s | %d | %d | %d | %d | %s |" % (
            ("↳ " if kap1 else "") + "**%d** %s" % (nummer(k), name(k)), ("%d (%d)" % (len(je), mo[0].get(k, 0))) if mo else str(len(je)), sum(d["kl"] == "M" for d in je), sum(in_arbeit(d, bes) for d in je),
            sum(wartet_auf_test(d) for d in je), sum(d["wort"] in RUHT for d in je),
            ("%s (%s) %s" % (n["nr"], n["besitzer"], worum(n["titel"], 50))) if n else "–"))
    if mo: aus += ["", mo[1]]
    je = je_rolle()
    aus += (["", "**Je Profil das Nächste** (wie der Disponent startet, 1893)", "", "| Profil | als Nächstes |", "|---|---|"] if s.NEU else
            ["", "**Je Rolle das Nächste** (wie Ford startet, mit Übernahme, 1364)", "", "| Rolle | als Nächstes |", "|---|---|"]) + je
    aus += ["", "**Die nächsten %d**" % ANZAHL, "", "| # | Nr. | Wer | Worum | Kl. | Block | Stand |", "|---|---|---|---|---|---|---|"]
    for i, (key, d, grund) in enumerate(kommt[:ANZAHL], 1):
        aus.append("| %d | %s | %s | %s | %s | %s | %s |" % (i, d["nr"], d["besitzer"], worum(d["titel"]).replace("|", "/"),
                                                         d["kl"], "%d %s" % (nummer(block(d)), name(block(d)).split(" (")[0].split(":")[0]), kurzstand(d, grund, bes)))
    aus += ["", "Danach %d weitere offen. Bei dir zum Testen (vorgelegt): %d. Gebaut, fährt mit dem nächsten Build: %d. "
            "Werkzeug gebaut, Prüfung Diogenes: %d. Ruhend oder nach dem Meilenstein: %d." % (
        max(0, len(kommt) - ANZAHL), len(test), len(gebaut), len(pruef), sum(d["wort"] in RUHT for d in zs))]
    return "\n".join(aus)


if __name__ == "__main__":
    print(md())
