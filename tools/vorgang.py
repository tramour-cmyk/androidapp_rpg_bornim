#!/usr/bin/env python3
"""Die eine Vorgangsliste lesen und schreiben (275, 275.2): gezielt statt ganze Listen lesen (Chef 27.10., 15:11).

Lesen:
  vorgang.py NR [NR …]                 je Nummer: Zeile der Liste (Felder, Grund), Archivzeile, Absätze „Zu NR“ und „Alt NR“ in den Vorräten,
                                       Einträge im Vorgangsarchiv, Chefsache-Dateien, Zeilen, die auf NR warten
  vorgang.py --rolle ROLLE [--startbar] eigene Zeilen in Vorrangfolge, dann fremde, die auf ROLLE warten (statt den Vorrat zu lesen)
  vorgang.py pruefen                    Formprüfung der ganzen Liste (Exit 1 bei Fehlern)
Schreiben (Chef 27.10., 15:20: nur über dieses Werkzeug; danach committen und pushen):
  vorgang.py neu "Titel" "Bereich" KL "Besitzer" [--nr NR] [--oben]   neue Zeile (Stand startbar); ohne --nr die nächste freie Nummer
                                       aus ARBEIT-BETRIEB.md (zählt hoch); ans Ende der Zeilen des Besitzers (--oben: an den Anfang)
  vorgang.py stand NR "Stand"          Wort der Liste, dahinter nach Komma ein kurzer Zusatz; „gebaut“ nur mit „Geprüft an: <Link|Lauf|Commit>“
                                       (340.4); „wartet auf X[: …]“ setzt Wort „wartet“ und das Feld
  vorgang.py warte NR "X, Y" | –       Feld „wartet auf“: Nummer, Rolle, Datum TT.MM.[ HH:MM], t<Build> oder Chef[ <Datei>] (Automatik A)
  vorgang.py setze NR feld=wert …      titel, besitzer, kl, stand, warte, zweig, build, bereich
  vorgang.py klasse NR M|K             M?-Entscheid (190.8)
  vorgang.py rang NR oben|unten|vor NR2|nach NR2   Vorrang unter den Zeilen desselben Besitzers
  vorgang.py fertig NR                 Stand „erledigt“ (ins Archiv schiebt lauf.py --aufraeumen); nennt Absätze „Zu NR“
  vorgang.py build N --mit NR,NR …     Testbuild N trägt diese Vorgänge: Build N, Stand „zu testen“
  vorgang.py build N [--datei PFAD] [--probe]   Automatik B nach dem Test des Chefs: liest die Prüfliste ansehen/tN-….md (auch gelöscht,
                                       aus Git) mit Abschnitt „## Ergebnis“ („- N.k ✓“, „- N.k ✗ <Fund>“, „- Rest ✓“) oder Spalte „Chef“;
                                       je Vorgang mit Build N: alle Punkte ✓ → erledigt; ein ✗ → startbar mit dem Fund (Absatz „Zu NR, von Chef
                                       (Fund tN.k …)“ beim Besitzer); ohne Rückmeldung → „zu testen“ ohne Build (in die nächste Prüfliste).
                                       Genannte Nummern ohne Build N bleiben unverändert (D80.1). Erst danach den Archiveintrag tN
                                       committen; sonst hält die Commit-Prüfung an.
  --rolle ROLLE ist Pflicht, wo eine Nummer mehrfach steht (nur Pflege, Spiegel).
"""
import os, re, sys, subprocess
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startbar
import bereiche  # 651

DOCS = startbar.DOCS
ROLLEN = startbar.BESITZER

def text_liste():
    return startbar.lesen(startbar.LISTE)

def schreiben(name, text):
    open(os.path.join(DOCS, name), "w", encoding="utf-8").write(text)
    if name == startbar.LISTE: startbar.liste_merken(DOCS)
    startbar.neu_laden()

def finden(nr, rolle=None):
    zs = [d for d in startbar.vorgangsliste(text_liste()) if d["nr"] == nr and (not rolle or d["besitzer"].lower() == rolle.lower())]
    if not zs: sys.exit("vorgang.py: %s steht nicht in %s%s (neu: vorgang.py neu …)" % (nr, startbar.LISTE, (" bei " + rolle) if rolle else ""))
    if len(zs) > 1: sys.exit("vorgang.py: %s steht mehrfach (%s), nichts geschrieben; Aufruf mit --rolle" % (nr, ", ".join(d["besitzer"] for d in zs)))
    return zs[0]

def fehler_oder(d, alt=None):
    alle = set(startbar.VORG) | {x["nr"] for x in startbar.zeilen_liste()}
    f = startbar.pruefen_zeile(dict(d, zeile=startbar.zeile_text(d), spalten=len(startbar.SPALTEN)), alle)
    # Chef nur mit Datei (275.2): beim Schreiben streng, beim Lesen erfüllt sie sich (Datei weg)
    for t in d["warte"]:
        if startbar.art(t) == "chef" and (alt is None or t not in alt["warte"]):
            teile = t.split(" ", 1)
            if not startbar.chef_datei(teile[1] if len(teile) > 1 else d["nr"]):
                f.append("„wartet auf %s“ ohne Datei in docs/chefsache/ (erst die Datei anlegen, 275.2)" % t)
    if f: sys.exit("vorgang.py: %s nicht geschrieben: %s" % (d["nr"], "; ".join(f)))

def ersetzen(alt, neu):
    neu["wort"] = startbar.wort_von(neu["stand"]); neu["zusatz"] = startbar.zusatz_von(neu["stand"])
    fehler_oder(neu, alt)
    L = text_liste().split("\n")
    if L[alt["i"]] != alt["zeile"]: sys.exit("vorgang.py: Liste hat sich beim Lesen geändert, nichts geschrieben")
    L[alt["i"]] = startbar.zeile_text(neu)
    schreiben(startbar.LISTE, "\n".join(L))

def warte_aus(text):
    t = text.strip()
    return [] if t in ("", "–", "-") else [x.strip() for x in t.split(",") if x.strip()]

GEPRUEFT = startbar.GEPRUEFT

def stand_pruefen(stand, nr):
    w = startbar.wort_von(stand)
    if not w: sys.exit("vorgang.py: Stand muss mit einem Wort der Liste beginnen (%s)" % ", ".join(startbar.WORTE))
    if "|" in stand or "\n" in stand: sys.exit("vorgang.py: Stand ohne | und Zeilenumbruch")
    if w == "gebaut" and not GEPRUEFT.search(stand):  # 340.4 (Chef 02.11., 19:44, „340.2 ja“, B)
        sys.exit("vorgang.py: „gebaut“ braucht „Geprüft an: <Link, Lauf-Nummer oder Commit>“ im Stand (340.4)")
    if len(startbar.zusatz_von(stand)) > 120: sys.exit("vorgang.py: Zusatz über 120 Zeichen; Einzelheiten als „Zu %s“ in den Vorrat" % nr)
    return w

def stand_setzen(nr, stand, rolle=None):
    d = finden(nr, rolle)
    n = dict(d)
    m = re.match(r"\s*wartet auf\s+(.+?)(?::\s*(.*))?$", stand)
    if m and not startbar.art(m.group(1).split(",")[0].strip()) is None:  # alte Gewohnheit „wartet auf 625: …“
        n["warte"] = warte_aus(m.group(1)); stand = "wartet" + ((", " + m.group(2)) if m.group(2) else "")
    stand_pruefen(stand, nr)
    n["stand"] = stand
    ersetzen(d, n)
    print("vorgang.py: %s (%s) Stand „%s“%s" % (nr, d["besitzer"], stand, (", wartet auf " + ", ".join(n["warte"])) if n["warte"] else ""))

def warte_setzen(nr, feld, rolle=None):
    d = finden(nr, rolle)
    n = dict(d, warte=warte_aus(feld))
    ersetzen(d, n)
    print("vorgang.py: %s (%s) wartet auf %s" % (nr, d["besitzer"], ", ".join(n["warte"]) or "–"))

FELDER = {"titel": "titel", "besitzer": "besitzer", "kl": "kl", "klasse": "kl", "stand": "stand", "warte": "warte", "wartet": "warte",
          "zweig": "zweig", "build": "build", "bereich": "bereich"}

def setzen(nr, paare, rolle=None):
    d = finden(nr, rolle); n = dict(d)
    for p in paare:
        k, _, v = p.partition("=")
        if k not in FELDER: sys.exit("vorgang.py: Feld „%s“ unbekannt (%s)" % (k, ", ".join(sorted(set(FELDER)))))
        k = FELDER[k]
        if k == "warte": n[k] = warte_aus(v)
        elif k == "stand": stand_pruefen(v, nr); n[k] = v
        elif k == "build": n[k] = v.lstrip("t") or "–"
        elif k == "bereich" and not bereiche.gueltig(v): sys.exit("vorgang.py: Bereich aus der festen Liste (651), Vorschlag „%s“:\n%s" % (bereiche.einordnen(v), bereiche.liste_text()))
        else: n[k] = v.strip() or "–"
    if n["besitzer"] != d["besitzer"]:  # neuer Besitzer: Zeile ans Ende seiner Zeilen
        ersetzen(d, n); rang(nr, "unten", None, n["besitzer"])
    else:
        ersetzen(d, n)
    print("vorgang.py: %s gesetzt: %s" % (nr, ", ".join(paare)))

def klasse(nr, kl, rolle=None):
    if kl not in ("M", "K"): sys.exit("vorgang.py: Klasse M oder K")
    setzen(nr, ["kl=" + kl], rolle)

def fertig(nr, rolle=None):
    d = finden(nr, rolle)
    ersetzen(d, dict(d, stand="erledigt", warte=[]))
    wer = [x for x in startbar.zeilen_liste() if nr in x["warte"]]
    zu = [l[:60] for l in startbar.lesen(startbar.VORRAT.get(d["besitzer"], "")).splitlines() if re.match(r"- \*\*Zu " + re.escape(nr) + r"\b", l)]
    print("vorgang.py: %s erledigt (%s)%s%s" % (nr, d["besitzer"], ("; darauf warten: " + ", ".join("%s (%s)" % (x["nr"], x["besitzer"]) for x in wer)) if wer else "",
                                            ("; Absätze noch da: " + " | ".join(zu)) if zu else ""))

def gruppe(L, besitzer):
    """Zeilenindizes der Zeilen eines Besitzers und Einfügestelle für einen neuen Besitzer (Reihenfolge wie die Liste)."""
    zs = startbar.vorgangsliste("\n".join(L))
    eigen = [d["i"] for d in zs if d["besitzer"] == besitzer]
    if eigen: return eigen, eigen[-1] + 1
    reihe = ["Tom", "Jerry", "Homer", "Perikles", "Diogenes", "Sokrates", "Ford", "Ideen"]
    k = reihe.index(besitzer) if besitzer in reihe else len(reihe)
    vor = [d["i"] for d in zs if d["besitzer"] in reihe[:k]]
    return [], (max(vor) + 1) if vor else (min(d["i"] for d in zs) if zs else len(L))

def rang(nr, wie, ziel=None, rolle=None):
    d = finden(nr, rolle)
    L = text_liste().split("\n")
    zeile = L.pop(d["i"])
    eigen, ende = gruppe(L, d["besitzer"])
    if wie == "oben": pos = eigen[0] if eigen else ende
    elif wie == "unten": pos = ende
    elif wie in ("vor", "nach"):
        z = [x for x in startbar.vorgangsliste("\n".join(L)) if x["nr"] == ziel and x["besitzer"] == d["besitzer"]]
        if not z: sys.exit("vorgang.py: %s ist keine Zeile von %s" % (ziel, d["besitzer"]))
        pos = z[0]["i"] + (1 if wie == "nach" else 0)
    else: sys.exit("vorgang.py: rang NR oben|unten|vor NR2|nach NR2")
    L.insert(pos, zeile)
    schreiben(startbar.LISTE, "\n".join(L))
    print("vorgang.py: %s (%s) %s%s" % (nr, d["besitzer"], wie, (" " + ziel) if ziel else ""))

def neu(titel, bereich, kl, besitzer, nr=None, oben=False):
    """275 Stufe 2, 275.2: neue Zeile (Stand startbar, Kosten –); ohne --nr die nächste freie Nummer aus ARBEIT-BETRIEB.md, die hochzählt."""
    if kl not in ("M", "K", "M?"): sys.exit("vorgang.py: Klasse M, K oder M?")
    if not bereiche.gueltig(bereich): sys.exit("vorgang.py: Bereich aus der festen Liste (651), Vorschlag „%s“:\n%s" % (bereiche.einordnen(bereich), bereiche.liste_text()))
    besitzer = {"Team Tom": "Tom", "Team Jerry": "Jerry", "Spike": "Tom", "Tuffy": "Jerry"}.get(besitzer.strip(), besitzer.strip())
    if besitzer not in ROLLEN: sys.exit("vorgang.py: Besitzer eine Rolle: " + ", ".join(ROLLEN))
    if any(c in titel for c in "|\n"): sys.exit("vorgang.py: Titel ohne | und Zeilenumbruch")
    if nr and (nr in startbar.VORG or any(d["nr"] == nr for d in startbar.zeilen_liste())): sys.exit("vorgang.py: %s gibt es schon" % nr)
    d = dict(nr=nr or "?", titel=titel.strip(), besitzer=besitzer, kl=kl, stand="startbar", warte=[], zweig="–", build="–", bereich=bereich.strip(), kosten="–")
    d["wort"] = "startbar"; d["zusatz"] = ""
    fehler_oder(d)
    if not nr:
        b = startbar.lesen("ARBEIT-BETRIEB.md")
        m = re.search(r"\*\*Nächste freie Vorgangsnummer: (\d+)\*\*", b)
        if not m: sys.exit("vorgang.py: Zähler in ARBEIT-BETRIEB.md nicht gefunden")
        nr = m.group(1); d["nr"] = nr
        schreiben("ARBEIT-BETRIEB.md", b.replace(m.group(0), "**Nächste freie Vorgangsnummer: %d**" % (int(nr) + 1), 1))
    L = text_liste().split("\n")
    eigen, ende = gruppe(L, besitzer)
    L.insert(eigen[0] if oben and eigen else ende, startbar.zeile_text(d))
    schreiben(startbar.LISTE, "\n".join(L))
    print("vorgang.py: %s angelegt (%s, %s, %s); Einzelheiten als „Zu %s“ in den Vorrat, dann pushen, dann die Nummer nennen" % (nr, bereich, kl, besitzer, nr))
    return nr

# ---------------------------------------------------------------- Automatik B

def git(*a):
    return subprocess.run(["git", "-C", DOCS] + list(a), capture_output=True, text=True).stdout

def pruefliste(n, datei=None):
    """(Pfad, Text) der Prüfliste tN; gelöscht: letzter Stand aus Git."""
    if datei:
        p = datei if os.path.isabs(datei) else os.path.join(os.getcwd(), datei)
        return p, open(p, encoding="utf-8").read()
    d = os.path.join(DOCS, "chefsache", "ansehen")
    for f in sorted(os.listdir(d)) if os.path.isdir(d) else []:
        if f.startswith("t%s-" % n) and f.endswith(".md"): return os.path.join(d, f), open(os.path.join(d, f), encoding="utf-8").read()
    h = git("log", "-1", "--diff-filter=D", "--format=%H", "--", ":(glob)chefsache/ansehen/t%s-*.md" % n).strip()
    if h:
        f = git("show", "--name-only", "--format=", h, "--", ":(glob)chefsache/ansehen/t%s-*.md" % n).split()
        if f: return "git:%s^:%s" % (h[:9], f[0]), git("show", "%s^:%s" % (h, f[0]))
    sys.exit("vorgang.py: keine Prüfliste t%s in docs/chefsache/ansehen/ (auch nicht in Git); --datei PFAD" % n)

def nummern(zelle):
    aus = []
    for teil in re.split(r"[,;]\s*", re.sub(r"\*\*|`", "", zelle)):
        m = re.fullmatch(r"\s*(\d+)\s*[–-]\s*(\d+)\s*", teil)
        if m and 0 < int(m.group(2)) - int(m.group(1)) <= 20: aus += [str(x) for x in range(int(m.group(1)), int(m.group(2)) + 1)]
        elif re.fullmatch(r"\s*D?\d+[a-z0-9.]*\s*", teil): aus.append(teil.strip())
    return aus

def ergebnisse(n, text):
    """{Testnummer: (Vorgänge, Ergebnis ✓|✗|None, Fund)}."""
    punkte = {}
    for kopf, zs in startbar.tabellen(text):
        if "Nr." not in kopf: continue
        i_nr = kopf.index("Nr."); i_chef = kopf.index("Chef") if "Chef" in kopf else None
        for _, t in zs:
            if not re.fullmatch(r"%s\.\d+[a-z]?" % n, t[0]): continue
            erg = fund = None
            if i_chef is not None and i_chef < len(t) and t[i_chef].strip():
                c = t[i_chef].strip(); erg = "✓" if c.startswith("✓") else "✗" if c.startswith("✗") else None; fund = c[1:].strip()
            punkte[t[0]] = [nummern(t[i_nr]) if i_nr < len(t) else [], erg, fund]
    rest = None
    teil = re.split(r"(?m)^## Ergebnis[^\n]*\n", text)
    if len(teil) > 1:
        for z in re.split(r"(?m)^## ", teil[1])[0].splitlines():
            m = re.match(r"\s*-\s*(\S+)\s*(✓|✗)\s*(.*)", z)
            if not m: continue
            k, e, f = m.groups()
            if k.lower() == "rest": rest = e; continue
            if k in punkte: punkte[k][1:] = [e, f.strip(" :–-")]
            else: punkte.setdefault("Nr " + k, [[k], e, f.strip(" :–-")])
    if rest:
        for k, v in punkte.items():
            if v[1] is None: v[1] = rest
    return punkte

def build_mit(n, nrs):
    for nr in nrs:
        d = finden(nr)
        ersetzen(d, dict(d, build=n, stand="zu testen" if d["wort"] in ("gebaut", "startbar", "in Arbeit", "zu testen") else d["stand"]))
        print("vorgang.py: %s (%s) Build %s, „%s“" % (nr, d["besitzer"], n, finden(nr)["stand"]))

def zu_absatz(besitzer, nr, kopf, text):
    datei = startbar.VORRAT.get(besitzer)
    if not datei: return
    t = startbar.lesen(datei).rstrip("\n")
    zeile = "- **Zu %s, von Chef (%s):** %s" % (nr, kopf, text)  # D80.2: Absender Chef; geht als fremder Hinweis durch (commit-pruefung 400)
    if zeile in t: return
    m = re.search(r"(?m)^## Einzelheiten\s*\n", t)
    if m: t = t[:m.end()] + "\n" + zeile + "\n" + t[m.end():]
    else: t += "\n\n" + zeile
    schreiben(datei, t + "\n")

def build_abschluss(n, datei=None, probe=False):
    pfad, text = pruefliste(n, datei)
    punkte = ergebnisse(n, text)
    if not any(v[1] for v in punkte.values()):
        sys.exit("vorgang.py: Prüfliste %s ohne Ergebnis (Abschnitt „## Ergebnis“ mit „- %s.k ✓|✗ <Fund>“ und „- Rest ✓“, oder Spalte „Chef“)" % (pfad, n))
    je = {}
    for k, (nrs, e, f) in punkte.items():
        for nr in nrs: je.setdefault(nr, []).append((k, e, f))
    zs = startbar.vorgangsliste(text_liste())
    # D80.1: nur die Vorgänge des Builds (Feld Build = N, eingetragen mit build N --mit); in der Prüfliste genannte Nummern ohne Build N
    # bleiben, wie sie sind (Hinweis unten), sonst fielen startbare Zeilen anderer Arbeit aus der Rechnung
    betroffen = [d for d in zs if d.get("build") == str(n) and d["wort"] != "erledigt"]
    fremd = sorted({d["nr"] for d in zs if d["nr"] in je and d.get("build") != str(n) and d["wort"] != "erledigt"})
    if not betroffen: sys.exit("vorgang.py: kein Vorgang mit Build %s in der Liste; erst vorgang.py build %s --mit <Nr,…>%s" % (n, n, ("; in der Prüfliste genannt: " + ", ".join(fremd)) if fremd else ""))
    aus = []
    for d in betroffen:
        p = je.get(d["nr"], [])
        durch = [x for x in p if x[1] == "✗"]
        if d.get("zweig") == "claude/build-%s" % n and any(v[1] for v in punkte.values()):  # der Sammelbuild selbst: getestet
            neu_d = dict(d, stand="erledigt, t%s getestet" % n, warte=[], build=str(n)); was = "erledigt (Sammelbuild)"
        elif p and all(x[1] == "✓" for x in p):
            neu_d = dict(d, stand="erledigt, t%s bestanden" % n, warte=[], build=str(n)); was = "erledigt"
        elif durch:
            neu_d = dict(d, stand="startbar, Fund " + ", ".join("t" + x[0] for x in durch), build="–"); was = "startbar (✗ %s)" % ", ".join(x[0] for x in durch)
        else:
            neu_d = dict(d, stand="zu testen, ohne Rückmeldung t%s" % n, build="–"); was = "zu testen (keine Rückmeldung)"
        aus.append((d, neu_d, durch, was))
    for d, neu_d, durch, was in aus:
        print("%s %s (%s): %s" % ("PROBE" if probe else "BUILD", d["nr"], d["besitzer"], was))
    if fremd: print("%s genannt, nicht in Build %s, bleibt: %s" % ("PROBE" if probe else "BUILD", n, ", ".join(fremd)))
    if probe: return
    for d, neu_d, durch, was in aus:
        alt = finden(d["nr"], d["besitzer"] if d["nr"] in startbar.SONDER else None)
        ersetzen(alt, neu_d)
        for k, e, f in durch: zu_absatz(d["besitzer"], d["nr"], "Fund t%s, Test Build %s, Automatik B" % (k, n), f or "✗ ohne Text, Prüfpunkt %s" % k)
    ohne = sorted(nr for nr in je if not any(d["nr"] == nr for d in zs))
    print("vorgang.py build %s: %d Vorgänge (%s); Prüfliste %s%s%s" % (n, len(aus), ", ".join("%s %s" % (d["nr"], w.split()[0]) for d, _, _, w in aus), os.path.relpath(pfad, os.path.dirname(DOCS)) if not pfad.startswith("git:") else pfad,
                                                          ("; ohne Listenzeile: " + ", ".join(ohne)) if ohne else "",
                                                          ("; genannt, aber nicht in Build %s (unverändert; gehört eine dazu: build %s --mit, dann erneut): %s" % (n, n, ", ".join(fremd))) if fremd else ""))

# ---------------------------------------------------------------- Lesen

def treffer(nr):
    aus = []
    n = re.escape(nr)
    for d in startbar.zeilen_liste():
        if d["nr"] == nr:
            aus.append("Liste: " + d["zeile"])
            aus.append("  → %s" % (startbar.sperre(d) or "startbar"))
    for z in startbar.lesen("LISTE-VORGAENGE-ARCHIV.md").splitlines():
        if re.match(r"\| " + n + r" \|", z): aus.append("Archiv: " + z)
    for datei, rolle in startbar.ROLLEN + [("ARBEIT-BETRIEB.md", "Ford")]:
        for z in startbar.lesen(datei).splitlines():
            if re.match(r"- \*\*(Zu|Alt|Von [^*]*zu) " + n + r"\b", z): aus.append("%s (%s): %s" % ("Alt" if z.startswith("- **Alt") else "Zu", rolle, z[:600] + (" …" if len(z) > 600 else "")))
    for z in startbar.lesen("VORGANGSARCHIV.md").splitlines():
        if re.match(r"- \*\*" + n + r"[ ,.*:]", z): aus.append("Vorgangsarchiv: " + z[:600] + (" …" if len(z) > 600 else ""))
    pre = nr.replace(".", "").lower()
    for ordner in startbar.CHEF_ORDNER:
        d = os.path.join(DOCS, "chefsache", ordner)
        aus += ["Chefsache: %s/%s" % (ordner, f) for f in (sorted(os.listdir(d)) if os.path.isdir(d) else []) if f.lower().startswith(pre + "-")]
    for d in startbar.zeilen_liste():
        if nr in d["warte"]: aus.append("Wartet darauf: %s (%s, %s)" % (d["nr"], d["besitzer"], d["stand"]))
    return aus

def ansicht(rolle, nur_startbar=False):
    rolle = startbar.ZUSATZ.get(rolle, rolle)
    zs = startbar.plan(rolle)
    p = startbar.pause(startbar.lesen(startbar.VORRAT.get(rolle, "")))
    print("%s: %d offen, %d Muss, %d startbar%s (Reihenfolge = Vorrang; „für X“: X wartet auf dich)" % (
        rolle, len(zs), sum(1 for z in zs if z[1] == "M"), sum(1 for z in zs if not z[4]), (", PAUSE bis " + p) if p else ""))
    for nr, kl, titel, d, g in zs:
        if nur_startbar and g: continue
        print("%s | %s | %s%s | %s | %s" % (nr, kl, d["stand"][:60], (" | wartet auf " + ", ".join(d["warte"])) if d["warte"] else "",
                                         re.sub(r"\*\*|`", "", titel)[:110], g or "startbar"))
    gel = [x for x in startbar.loesen(False) if x[1] == rolle]
    for nr, wer, weg, st in gel: print("GELÖST %s: wartet auf %s erfüllt (setzt lauf.py)" % (nr, ", ".join(weg)))

def haupt(a):
    rolle = None
    if "--rolle" in a:
        i = a.index("--rolle")
        if i + 1 >= len(a) or a[i + 1].capitalize() not in ROLLEN + list(startbar.ZUSATZ):
            sys.exit("vorgang.py: --rolle braucht eine von: " + ", ".join(ROLLEN))
        rolle = a[i + 1].capitalize(); del a[i:i + 2]
        if not a or a[0] == "--startbar": return ansicht(rolle, bool(a))
    if not a: print(__doc__); sys.exit(2)
    b = a[0]
    if b == "pruefen":
        f = startbar.pruefen_liste()
        for nr, x in f: print("%s: %s" % (nr, x))
        print("vorgang.py pruefen: %s" % ("%d Fehler" % len(f) if f else "ohne Fehler")); sys.exit(1 if f else 0)
    if b == "stand" and len(a) == 3: return stand_setzen(a[1], a[2], rolle)
    if b == "warte" and len(a) == 3: return warte_setzen(a[1], a[2], rolle)
    if b == "setze" and len(a) >= 3: return setzen(a[1], a[2:], rolle)
    if b == "klasse" and len(a) == 3: return klasse(a[1], a[2], rolle)
    if b == "fertig" and len(a) == 2: return fertig(a[1], rolle)
    if b == "rang" and len(a) in (3, 4): return rang(a[1], a[2], a[3] if len(a) == 4 else None, rolle)
    if b == "neu" and len(a) >= 5:
        nr = a[a.index("--nr") + 1] if "--nr" in a else None
        r = [x for k, x in enumerate(a[1:], 1) if x not in ("--nr", "--oben") and a[k - 1] != "--nr"]
        if len(r) == 4: return neu(r[0], r[1], r[2], r[3], nr, "--oben" in a)
    if b == "build" and len(a) >= 2:
        n = a[1].lstrip("t")
        if "--mit" in a:
            return build_mit(n, [x for x in re.split(r"[,\s]+", " ".join(a[a.index("--mit") + 1:])) if x])
        return build_abschluss(n, a[a.index("--datei") + 1] if "--datei" in a else None, "--probe" in a)
    if b in ("stand", "warte", "setze", "klasse", "fertig", "rang", "neu", "build"): print(__doc__); sys.exit(2)
    for nr in a:
        print("== %s" % nr)
        print("\n".join(treffer(nr)) or "nichts gefunden")

if __name__ == "__main__":
    haupt(sys.argv[1:])
