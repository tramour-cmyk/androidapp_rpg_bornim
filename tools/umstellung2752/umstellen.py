#!/usr/bin/env python3
"""Umstellung 275.2 (Chef 07.11., 21:5x): Vorräte und LISTE-VORGAENGE.md → eine Vorgangsliste. Einmal, in einem Schritt, kein Parallelbetrieb.

Aufruf: python3 tools/umstellung2752/umstellen.py DOCS [--bericht DATEI] [--probe]
  DOCS     docs-Ordner, der umgestellt wird (zum Testen eine Kopie, am Umschalttag ../bornim-main/docs)
  --probe  nichts schreiben, nur den Bericht
Rechnet je Vorratszeile mit der alten Fassung (startbar_alt.py), was sie heute ist (startbar oder Grund), und setzt die neuen Felder so,
dass die neue startbar.py dasselbe rechnet; Abweichungen stehen im Bericht. Handkorrekturen: HAND unten (je Nummer, mit Grund).
Jede alte Vorratszeile bleibt wörtlich als „- **Alt <Nr>:** …“ unter „## Alte Zeilen (bis 275.2)“ im Vorrat ihres Besitzers.
Erledigte Zeilen gehen unverändert ins Archiv (altes Format). Rückweg nur `git revert`.
"""
import os, re, sys, importlib, datetime

HIER = os.path.dirname(os.path.abspath(__file__))
REIHE = ["Tom", "Jerry", "Homer", "Perikles", "Diogenes", "Sokrates", "Ford", "Ideen"]
ROLLE = re.compile(r"\b(Homer|Tom|Jerry|Perikles|Diogenes|Sokrates|Ford|Spike|Tuffy)\b")

# Handkorrekturen (Perikles, 07.11.): Nummer → Felder, die die Automatik überschreibt; "_grund" geht in den Bericht.
# Doppelte Nummern: ein Besitzer; die Arbeit des anderen steht als „wartet auf <Rolle>“ (erscheint bei ihm, 275.2).
HAND = {
    "461.1": dict(warte=[], _grund="Tom und Jerry beide „ruht nach dem Durchspielen“; Besitzer Tom, Jerrys Zeile nur als Alt-Zeile"),
    "275.2": dict(wort="in Arbeit", zusatz="Bau im Zweig claude/perikles-2752-liste", warte=[], zweig="claude/perikles-2752-liste",
                  _grund="Perikles baut; Quertest Diogenes fordert Perikles über Ford an (dann „wartet auf Diogenes“); Sokrates' Zeile war nur Merkposten"),
    "317.1": dict(warte=["Diogenes", "t269"], _grund="Diogenes prüft nach Sammelbuild 269 (seine Zeile: ruht bis 269)"),
    "620.1": dict(warte=["Chef", "Diogenes"], _grund="A gebaut, B beim Chef (entscheiden/6201); Diogenes prüft A an der ersten Zeile mit „wiederholt“"),
    "511": dict(warte=["Diogenes", "D75"], _grund="Diogenes prüft am nächsten echten Filmlauf (D75 Dauer bis dahin)"),
    "483": dict(warte=["Diogenes", "D75"], zusatz="Geprüft an: 62e922b30", _grund="Diogenes prüft am nächsten echten Film (D75 Dauer bis dahin); Bau-Commit nachgetragen (D80.7)"),
    "464": dict(zusatz="Geprüft an: fcf9ab215", _grund="Bau-Commit nachgetragen („gebaut“ braucht „Geprüft an“, D80.7)"),
    "383": dict(zusatz="Geprüft an: 4e1f16df6", _grund="Bau-Commit nachgetragen („gebaut“ braucht „Geprüft an“, D80.7)"),
    "D75": dict(wort="Dauer", zusatz="bis zum nächsten echten Film (D75.1 gebaut, D75.2 dann prüfen)", warte=[], bereich="B Werkzeuge",
                titel="Filmsperre 511 zählte Film-Pushes 572 nicht (D75.1); meldung.sh --film legte Film 572 nicht ab (D75.2)",
                _grund="Prüfbefund Diogenes Lauf 73; wartet auf ein Ereignis (Film), nicht auf eine Nummer"),
    "340.2": dict(besitzer="Diogenes", warte=["09.11."], _grund="übrig ist Diogenes' Zählung der Wirkung Mo 09.11.; Sokrates' Zeile wartete auf den Bau 340.3–340.5 (gebaut)"),
    "565": dict(warte=[], zusatz="Sokrates: Kopf „565, Läufe frei“ ins Archiv (seine Zeile, 627)",
                _grund="Jerrys Bildläufe liefen schon (21:32); Sokrates' Rest ist Buchhaltung für probelauf.py, hält Jerry nicht auf"),
    "275": dict(warte=["Diogenes", "09.11."], _grund="Diogenes zählt die Warnungen der Stufe 2 in der Montagszählung 09.11. (seine Zeile: ruht bis 09.11.; D82)"),
    "398": dict(warte=["09.11."], zusatz="Wochenzählung Diogenes", _grund="wartete auf Diogenes' Wochenzählung 02.11. (vorbei); nächste Zählung Mo 09.11."),
}

def lade(docs):
    os.environ["BORNIM_DOCS"] = docs
    sys.path.insert(0, HIER)
    import startbar_alt
    importlib.reload(startbar_alt)
    return startbar_alt

def liste_alt(alt):
    """Nr → Zellen der alten Liste (7 Spalten: Nr, Vorgang, Bereich, Kl., Kosten, Vorrat, Stand), in Dateireihenfolge."""
    aus = {}
    for z in alt.lesen("LISTE-VORGAENGE.md").splitlines():
        t = [x.strip() for x in z.split("|")][1:-1]
        if z.startswith("| ") and len(t) == 7 and t[0] != "Nr." and not set(t[0]) <= set("-: "): aus[t[0]] = t
    return aus

def spalten_vorrat(text):
    """Nr → (Kl, Titel, Stand, Zweig, Rohzeile) der Vorratstabelle (4 oder 5 Spalten)."""
    aus = []
    for z in text.splitlines():
        if not z.startswith("| "): continue
        t = [x.strip() for x in z.split("|")][1:-1]
        if not t or t[0] in ("Nr.", "Nr") or set(t[0]) <= set("-: ") or len(t) < 4 or t[1] not in ("M", "K", "M?", "–", "-"): continue
        aus.append((t[0], t[1], t[2], t[3], (t[4] if len(t) > 4 else "–").strip("` ") or "–", z))
    return aus

JETZT_FELD = re.compile(r"[„\"]jetzt[“\"]\s*(?:(\d{1,2})\.(\d{1,2})\.,?\s*)?(\d{1,2}):(\d{2})")

def jetzt_marke(text):
    """„jetzt“ TT.MM., HH:MM wie lauf.py 383 (Datum fehlt: letztes Datum davor)."""
    m = JETZT_FELD.search(text)
    if not m: return None
    if m.group(1): tag, mon = m.group(1), m.group(2)
    else:
        v = re.findall(r"(?<![\d.])(\d{1,2})\.(\d{1,2})\.", text[:m.start()])
        if not v: return None
        tag, mon = v[-1]
    return "„jetzt“ %02d.%02d., %s:%s" % (int(tag), int(mon), m.group(3).zfill(2), m.group(4))

def titel_aus(vt):
    t = re.sub(r"^\*\*[^*]*\*\*\s*", "", vt).strip()
    return re.sub(r"\*\*|`", "", t or vt).strip()

def kurz(t, n):
    t = t.replace("|", "/").strip()
    return t if len(t) <= n else t[:n - 1].rstrip() + "…"

def rollen_aus(text):
    """Rollen direkt nach „wartet auf“: „Tom, Jerry: …“ → [Tom, Jerry]."""
    m = re.search(r"wartet auf (?:\*\*)?((?:%s)(?:(?:,| und) (?:%s))*)" % (ROLLE.pattern[3:-3], ROLLE.pattern[3:-3]), text)
    if not m: return []
    r = [{"Spike": "Tom", "Tuffy": "Jerry"}.get(x, x) for x in ROLLE.findall(m.group(1))]
    return list(dict.fromkeys(r))

def felder(alt, nr, kl, vt, vs, zweig, chef):
    """Alter Grund → (wort, zusatz, warte, build, grund_alt)."""
    b = alt.blocker(nr, vs, chef, vt)
    sperr = {nr: b}
    lei = alt.leiche(nr, vs, b) if b != "ERLEDIGT" else None
    bl = alt.blank(vs)
    build = None
    m = re.search(r"\bBuild \(?(\d{3})\)?|build-(\d{3})", vs + " " + zweig)
    if m: build = m.group(1) or m.group(2)
    gepr = re.search(r"Geprüft an:?\s*([^;|]+)", vs)
    gz = ("Geprüft an: " + gepr.group(1).strip()) if gepr else ""
    if lei and alt.LEICHEN_START:
        return "startbar", "prüfen (alte Leiche: %s)" % kurz(lei, 70), [], None, "Leiche: " + lei
    if b is None:
        return ("in Arbeit" if re.match(r"(in Arbeit|begonnen)", bl) else "startbar"), "", [], None, "startbar"
    if b == "ERLEDIGT": return "erledigt", "", [], None, b
    if b.startswith("Teil erledigt"): return "ruht", "Teil erledigt, Rest offen (275.2)", [], None, b
    if b.startswith("wartet auf Test/Build (gebaut)"): return "gebaut", gz, [], build, b
    m = re.match(r"in Arbeit bei (Spike|Tuffy)", b)
    if m: return "in Arbeit", "bei " + m.group(1), [], None, b
    if b.startswith("Dauerzeile"):
        d = re.search(r"bis (\d\d\.\d\d\.)", b)
        return "Dauer", "", [d.group(1)] if d else [], None, b
    if b.startswith("Chef"):
        if alt.chef_datei(nr): return "Chef", "", ["Chef"], None, b
        c = re.search(r"(?:entscheiden|ansehen|billigen|tun)/(\d+[a-z0-9]*)", vs) or re.search(r"Chefsache (\d+[a-z0-9.]*)", vs)
        if c and alt.chef_datei(c.group(1).rstrip(".")): return "Chef", "", ["Chef " + c.group(1).rstrip(".").replace(".", "")], None, b
        return "ruht", "wartete auf den Chef ohne Datei (275.2)", [], None, b
    if b.startswith("wartet auf Test (Build)") or b == "wartet auf Test/Build": return "zu testen", "", [], build, b
    if b == "wartet auf Eingang": return "ruht", "wartet auf Eingang (275.2)", [], None, b
    if re.match(r"wartet auf " + alt.ROLLEN_NAMEN, b):
        r = rollen_aus(vs) or rollen_aus(b)
        # „wartet auf Tom: 492 …“, „wartet auf Tom (302.1 Schätzung)“: genannte Nummern statt der Rolle (Automatik A löst sie)
        m = re.search(r"wartet auf (?:\*\*)?%s(?:(?:,| und) %s)*\**\s*(?::|\()([^;]*)" % (alt.ROLLEN_NAMEN, alt.ROLLEN_NAMEN), vs)
        nrn = re.findall(r"(?<![\d.:])\d+[a-z0-9.]*[a-z0-9](?![:\d])", m.group(1)) if m else []
        nrn = [x for x in nrn if x in alt.VORG and not re.fullmatch(r"\d\d\.\d\d", x)]  # nur genaue Nummern (nicht Prüfpunkt 266.8 → 266)
        if nrn: return "wartet", "", nrn, None, b + " (Nummern statt Rolle)"
        return "wartet", "", r, None, b
    if b.startswith("ruht"):
        if "424" in b: return "ruht", "424: altes SRD-System", [], None, b
        d = re.search(r"bis (\d\d\.\d\d\.)", b)
        return "ruht", "", [d.group(1)] if d else [], None, b
    if b.startswith("Termin"): return "wartet", "", [b.split()[-1]], None, b
    if b == "nach dem Meilenstein": return "nach Meilenstein", "", [], None, b
    m = re.match(r"wartet auf (\S+) \((.*)\)$", b)
    if m:
        if m.group(2) == "Nummer unbekannt": return "ruht", "wartete auf %s, Nummer unbekannt (275.2)" % m.group(1), [], None, b
        return "wartet", "", [m.group(1)], None, b
    return "ruht", "alter Stand unklar (275.2)", [], None, b

def nur_liste(t):
    """Zeile nur in der alten Liste (keine Vorratszeile): Wort, Zusatz; nichts davon war startbar."""
    w = t[6]
    if w == "erledigt": return "erledigt", ""
    if w in ("aufgeteilt", "Idee", "ruht", "Dauer", "nach Meilenstein"): return w, ""
    if w == "später": return "Idee", ""
    if w == "laufend": return "Dauer", ""
    return "ruht", "ohne Vorratszeile, Liste „%s“ (275.2)" % w

def besitzer_aus(vorrat_spalte):
    if vorrat_spalte.startswith("Ideen"): return "Ideen"
    m = ROLLE.search(vorrat_spalte)
    return {"Spike": "Tom", "Tuffy": "Jerry"}.get(m.group(1), m.group(1)) if m else None

def archivzeile(nr, titel, bereich, kl, kosten, vorrat):
    return "| %s | %s | %s | %s | %s | %s | erledigt |" % (nr, titel, bereich, kl, kosten or "–", vorrat)

KOPFTEXT = """# Vorgänge

**Die eine Vorgangsliste** (275.2, Chef 07.11., 21:5x): je Vorgang eine Zeile mit festen Feldern; Vorräte `ARBEIT-*.md` haben keine Tabelle mehr, nur Übergabe, Pause und „Zu <Nr>“. **Nicht ganz lesen:** die eigenen Zeilen zeigt `python3 tools/vorgang.py --rolle <Rolle>` (Bedingung des Chefs 27.10.: keine 1000 Tokens extra), eine Nummer `vorgang.py <Nr>`. **Schreiben nur mit `tools/vorgang.py`** (`neu`, `stand`, `warte`, `setze`, `rang`, `fertig`, `build`; Hilfe ohne Argument); von Hand geändert warnt die Commit-Prüfung.

- **Reihenfolge** der Zeilen eines Besitzers = Vorrang (`vorgang.py rang`). **Besitzer:** Homer, Tom, Jerry, Perikles, Diogenes, Sokrates, Ford, Ideen (wird nie gestartet). **Kl.** (126): M Muss, K Kür, M? (Perikles entscheidet), – abgeschlossen.
- **Stand** (275): ein Wort aus offen, startbar, in Arbeit, wartet, Chef, ruht, gebaut, zu testen, Dauer, nach Meilenstein, aufgeteilt, Idee, erledigt; dahinter nach Komma höchstens ein kurzer Zusatz (bei „gebaut“ Pflicht: „Geprüft an: <Link, Lauf oder Commit>“, 340.4).
- **wartet auf** (Automatik A): Nummer, Rolle, Datum `TT.MM.[ HH:MM]` oder `Chef[ <Dateinummer>]` (nur mit Datei in `docs/chefsache/`), mit Komma getrennt. Nummer erledigt, Datum vorbei oder Chefsache-Datei weg: `startbar.py` meldet „GELÖST“, `lauf.py --sperre` setzt die Zeile auf startbar und meldet es der laufenden Sitzung des Besitzers. Ist die Nummer erst gebaut oder zu testen, hält sie nicht auf (190.1), das Feld bleibt aber stehen, bis sie erledigt ist. Eine Rolle löst sich nicht von selbst: die Zeile steht bei ihr als Arbeit, bis sie das Feld mit `vorgang.py warte <Nr> –` leert.
- **Zweig** `claude/…`; **Build** die Nummer des Testbuilds, der den Vorgang trägt (`vorgang.py build <n> --mit <Nr,…>`); nach dem Test des Chefs schließt `vorgang.py build <n>` ab (Automatik B: bestanden → erledigt, ✗ → startbar mit dem Fund, ohne Rückmeldung → zu testen).
- **Bereich** (124): E Entwicklung, G Gestaltung, Q Qualität, B Betrieb, M Markt. **Kosten** in $ (`usage.cost_usd`, ab 17.10.): bucht Ford (`lauf.py --kosten`).
- Erledigte Zeilen schiebt `lauf.py --aufraeumen` ins [Archiv](LISTE-VORGAENGE-ARCHIV.md).

"""

def umstellen(docs, probe=False):
    alt = lade(docs)
    la = liste_alt(alt)
    chef = alt.chefdateien()
    neu = {r: [] for r in REIHE}
    archiv = []; bericht = []; alte_zeilen = {}; gesehen = {}
    for datei, rolle in alt.ROLLEN:
        for nr, kl, vt, vs, zweig, roh in spalten_vorrat(alt.lesen(datei)):
            alte_zeilen.setdefault(rolle, []).append((nr, roh))
            wort, zusatz, warte, build, grund = felder(alt, nr, kl, vt, vs, zweig, chef)
            t = la.get(nr)
            titel = t[1] if t else titel_aus(vt)
            j = jetzt_marke(vt + " | " + vs)
            if j and "„jetzt“" not in titel: titel += " · " + j
            if alt.WIEDERHOLT.search(vt + " " + vs) and not re.search(r"\bwiederholt\b", titel, re.I): titel += " · wiederholt"
            n, _ = alt.stand_von(nr)
            bereich = t[2] if t else (la[n][2] if n in la else "B Betrieb" if nr in ("Pflege", "Spiegel") else "?")  # D80.7: Werkzeugzeilen
            d = dict(nr=nr, titel=kurz(titel, 220), besitzer=rolle, kl=kl if kl != "-" else "–", wort=wort, zusatz=kurz(zusatz, 100), warte=warte,
                     zweig=zweig if zweig.startswith("claude/") else "–", build=build or "–", bereich=bereich, kosten=t[4] if t else "–", grund_alt=grund)
            gesehen.setdefault(nr, []).append(d)
    sonder = []
    # Doppelte: Handkorrektur verlangt; ohne sie bleibt die erste Zeile (Reihenfolge ROLLEN), die anderen werden „wartet auf <Rolle>“ bei ihr
    for nr, ds in gesehen.items():
        if nr in ("Pflege", "Spiegel"):
            sonder.extend(ds)  # Werkzeugzeilen ans Ende der Zeilen ihres Besitzers (340.3: Pflege als Kür unten)
            continue
        h = HAND.get(nr, {})
        haupt = next((d for d in ds if d["besitzer"] == h.get("besitzer")), None) or ds[0]
        for d in ds:
            if d is haupt: continue
            if d["wort"] != "erledigt" and d["besitzer"] not in haupt["warte"]: haupt["warte"].append(d["besitzer"])
            bericht.append("DOPPELT %s: Zeile von %s (%s) → bei %s „wartet auf %s“" % (nr, d["besitzer"], d["grund_alt"], haupt["besitzer"], d["besitzer"]))
        for k, v in h.items():
            if not k.startswith("_"): haupt[k] = v
        if h: bericht.append("HAND %s: %s" % (nr, h.get("_grund", "")))
        if haupt["wort"] == "erledigt":
            t = la.get(nr)
            archiv.append(archivzeile(nr, haupt["titel"], haupt["bereich"], haupt["kl"], haupt["kosten"], t[5] if t else haupt["besitzer"]))
            continue
        neu[haupt["besitzer"]].append(haupt)
    # Zeilen nur in der Liste
    for nr, t in la.items():
        if nr in gesehen: continue
        wort, zusatz = nur_liste(t)
        b = besitzer_aus(t[5])
        h = HAND.get(nr, {})
        if wort == "erledigt" and not h:
            archiv.append("| " + " | ".join(t) + " |"); continue
        d = dict(nr=nr, titel=t[1], besitzer=b or "?", kl=t[3], wort=wort, zusatz=zusatz, warte=[], zweig="–", build="–", bereich=t[2], kosten=t[4],
                 grund_alt="nur Liste (%s, %s)" % (t[5], t[6]))
        if b == "Ideen" and wort not in ("aufgeteilt",): d["wort"], d["zusatz"] = "Idee", ""
        if nr == "Betrieb": d["besitzer"] = "Ford"
        for k, v in h.items():
            if not k.startswith("_"): d[k] = v
        if h: bericht.append("HAND %s: %s" % (nr, h.get("_grund", "")))
        if d["wort"] == "erledigt": archiv.append("| " + " | ".join(t[:6]) + " | erledigt |"); continue
        neu.setdefault(d["besitzer"], []).append(d)
    for d in sonder: neu[d["besitzer"]].append(d)
    zeilen = []
    for r in REIHE + sorted(k for k in neu if k not in REIHE):
        for d in neu.get(r, []):
            d["stand"] = d["wort"] + ((", " + d["zusatz"]) if d["zusatz"] else "")
            zeilen.append(d)
    return alt, la, zeilen, archiv, alte_zeilen, bericht

def schreiben(docs, alt, zeilen, archiv, alte_zeilen):
    sys.path.insert(0, os.path.dirname(HIER))
    import startbar as neu_sb
    text = KOPFTEXT + neu_sb.KOPF + "\n" + "|" + "---|" * len(neu_sb.SPALTEN) + "\n" + "\n".join(neu_sb.zeile_text(d) for d in zeilen) + "\n"
    open(os.path.join(docs, "LISTE-VORGAENGE.md"), "w", encoding="utf-8").write(text)
    neu_sb.liste_merken(docs)  # vom Werkzeug geschrieben: keine Warnung „von Hand geändert“ im Umschalt-Commit
    if archiv:
        p = os.path.join(docs, "LISTE-VORGAENGE-ARCHIV.md")
        a = open(p, encoding="utf-8").read()
        open(p, "w", encoding="utf-8").write(a.rstrip("\n") + "\n" + "\n".join(archiv) + "\n")
    for datei, rolle in alt.ROLLEN:
        p = os.path.join(docs, datei)
        t = open(p, encoding="utf-8").read()
        L = t.split("\n"); aus = []; i = 0
        while i < len(L):
            z = L[i]
            if z.startswith("| Nr") and i + 1 < len(L) and L[i + 1].startswith("|---") and "Kl." in z:
                i += 2
                while i < len(L) and L[i].startswith("|"): i += 1
                continue
            if re.match(r"\*\*Pause bis die neue Vorgangsliste läuft", z): i += 1; continue
            aus.append(z); i += 1
        t = "\n".join(aus)
        t = re.sub(r"\n## Zeilen\n\s*(?=\n## |\Z)", "\n", t)
        t = re.sub(r"\n{3,}", "\n\n", t)
        alt_z = alte_zeilen.get(rolle, [])
        if alt_z:
            # D80.2: knapp, damit kein Vorrat wächst (Commit-Prüfung): Kurzkopf; Klasse und leere Zellen stehen schon in der Liste
            t = t.rstrip("\n") + "\n\n## Alte Zeilen (bis 275.2; Stand in der Liste, Gültiges als „Zu <Nr>“, Rest streichen)\n\n" + \
                "\n".join("- **Alt %s:** %s" % (nr, alt_zellen(roh)) for nr, roh in alt_z if nr not in ("Pflege", "Spiegel")) + "\n"
        open(p, "w", encoding="utf-8").write(t)

def alt_zellen(roh):
    """Zellen einer alten Vorratszeile ohne Nummer und Klasse (beides in der Liste), ohne leere Zellen am Ende, mit „ · “."""
    z = [x.strip() for x in roh.strip().strip("|").split("|")][2:]
    while z and z[-1] in ("", "–", "-"): z.pop()
    return " · ".join(z)

def vergleich(docs, alt_ergebnis):
    """Alte gegen neue Startbar-Rechnung je Nummer und Rolle: [(Rolle, Nr, alt, neu)] mit Unterschied startbar ja/nein."""
    sys.path.insert(0, os.path.dirname(HIER))
    import startbar as sb
    sb.DOCS = docs; sb.neu_laden()
    neu_erg = {}
    for _, rolle in sb.ROLLEN:
        for nr, kl, th, d, g in sb.plan(rolle): neu_erg[(rolle, nr)] = (kl, g)
    aus = []
    for k in sorted(set(alt_ergebnis) | set(neu_erg)):
        a = alt_ergebnis.get(k); n = neu_erg.get(k)
        sa = a is not None and a[1] is None; sn = n is not None and n[1] is None  # fehlt = nicht startbar
        if sa != sn or (sa and sn and (a[0] == "M") != (n[0] == "M")): aus.append((k[0], k[1], a, n))
    return aus

def alt_rechnung(alt):
    chef = alt.chefdateien(); aus = {}
    for datei, rolle in alt.ROLLEN:
        zs = alt.hochstufen([z for z in alt.zeilen(alt.lesen(datei)) if z[1] not in ("–", "-")])
        sperr = {z[0]: alt.blocker(z[0], z[3], chef, z[2]) for z in zs}
        zs = [z for z in zs if sperr[z[0]] != "ERLEDIGT"]
        for nr, l in alt.leichen_von(zs, sperr):
            if alt.LEICHEN_START: sperr[nr] = None
        for z in zs: aus[(rolle, z[0])] = (z[1], sperr[z[0]])
    return aus

if __name__ == "__main__":
    a = sys.argv[1:]
    if not a: sys.exit(__doc__)
    docs = os.path.abspath(a[0]); probe = "--probe" in a
    ziel = a[a.index("--bericht") + 1] if "--bericht" in a else None
    alt, la, zeilen, archiv, alte, bericht = umstellen(docs, probe)
    alt_erg = alt_rechnung(alt)
    for d in zeilen:
        bericht.append("ZEILE %s (%s, %s): alt „%s“ → %s%s" % (d["nr"], d["besitzer"], d["kl"], d["grund_alt"], d["stand"], (" · wartet auf " + ", ".join(d["warte"])) if d["warte"] else ""))
    bericht.append("ARCHIV %d Zeilen: %s" % (len(archiv), ", ".join(x.split("|")[1].strip() for x in archiv)))
    if not probe:
        schreiben(docs, alt, zeilen, archiv, alte)
        for r, nr, x, y in vergleich(docs, alt_erg):
            bericht.append("ABWEICHUNG %s %s: alt %s → neu %s" % (r, nr, ("–" if x is None else "%s %s" % (x[0], x[1] or "startbar")), ("–" if y is None else "%s %s" % (y[0], y[1] or "startbar"))))
    txt = "\n".join(bericht) + "\n"
    if ziel: open(ziel, "w", encoding="utf-8").write(txt)
    else: print(txt)
    print("Umstellung 275.2: %d Zeilen in der Liste, %d ins Archiv, %d Abweichungen%s" % (len(zeilen), len(archiv), sum(1 for b in bericht if b.startswith("ABWEICHUNG")), " (Probe, nichts geschrieben)" if probe else ""), file=sys.stderr)
