#!/usr/bin/env python3
"""Größen und Ladesumme (1739, 1866, 1922; 1727 `werkzeuge.md` Z. 77, `reihenfolge.md` Schritt 1; Chef 20.11., 16:49 „Kerne nicht
aufblähen, Größe nennen“: „jedes Mal, wenn wir an einem Kern etwas ergänzen oder ein Profil erstellen, will ich wissen, wie groß das
alles ist“, 16:52 Tabelle nachhalten).

  python3 tools/ladesumme.py [--gegen REV] [--teile]   Byte je Teil (Sockel, Kerne, Profile, Querprofile, Routine Wache) mit Grenze
                                                       und Summe je Sitzungsart (Tabelle SITZUNGEN), mit REV vorher/nachher
  python3 tools/ladesumme.py PFAD … [--gegen REV]      freie Messung: Byte je Datei oder je Block ```markdown; Summe je Sitzung
                                                       nach laden.json im (ersten) Ordner, falls vorhanden
  python3 tools/ladesumme.py --anlegen                 1928: docs/profile/<Profil>.md je Teil mit Profilnamen aus dem Entwurf (Umschalt-Commit)
  python3 tools/ladesumme.py --alt                     heute: was jede Rolle beim Start liest (CLAUDE.md + Rollendatei + Vorrat)
(--vor REV wie --gegen REV.) Test: python3 tools/ladesumme_test.py

Messregel (`1727-muster/texte-stand-10-00.md`:3): UTF-8, ohne Kopfzeile „# …“ und die Leerzeile danach, bis vor die erste Zeile mit
„## “, ohne letztes Zeilenende; bei Codeblöcken nur der Inhalt ohne letztes Zeilenende. Ein Teil der Tabelle ist
  PFAD                       Ladetext der Datei nach Messregel
  PFAD|Überschrift[|n]       n-ter Codeblock (Vorgabe 1) unter der Überschrift (Zeilenanfang), bis zur nächsten gleich hohen
Nach der Umstellung (1871) liegen die Ladetexte unter docs/profile/<Profil>.md (lauf.kern); gibt es die Datei, zählt sie statt
des Entwurfs. laden.json: {"Sitzungen": {"Name": ["sockel.md", "profil.md#2", …]}}, „datei.md#2“ = zweiter Block.
Muster (erst nachsehen, wie andere es lösen): Größenbudgets wie size-limit/bundlesize (Teil, Grenze, Vergleich mit dem
Ausgangsstand), hier für Ladetexte statt Pakete.
"""
import json, os, re, subprocess, sys

ROOT = os.environ.get("BORNIM_WURZEL") or os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
M = "docs/entwurf/1727-muster/"
G = "docs/entwurf/1727-gesamtbild.md"
# Teil: (Quelle Entwurf, Profilname nach der Umstellung oder None, Grenze in Byte oder None)
TEILE = {
    "Sockel": (G + "|## 1 Sockel", None, 1200),
    "Kern Leitung": (G + "|### 2.1 Kern Leitung|2", "Kern Leitung", 3000),  # 1986: lauf.KERN_VON Sokrates
    "Kern Büro": (M + "kern-buero.md", "Kern Büro", None),
    "Kern Arbeitsplaner": (M + "kern-arbeitsplaner.md", "Arbeitsplaner", 3000),
    "Kern Abnahme": (M + "kern-abnahme.md", "Kern Abnahme", None),
    "Profil Disponent": (M + "profil-disponent.md|## Text", "Disponent", None),
    "Profil Prüfer": (M + "profil-pruefer.md", "Prüfer", None),
    "Profil Tester": (M + "profil-tester.md", "Tester", None),
    "Profil Werkzeug A": (M + "profil-werkzeug.md|## Teil A", "Werkzeug", None),
    "Querprofil Fremde Inhalte A": (M + "profil-fremde-inhalte.md|## Teil A", "Fremde Inhalte", None),
    "Querprofil Signatur und Leben": (M + "querprofil-signatur-und-leben.md", "Signatur und Leben", None),
    "Profil Welt": (M + "profil-welt.md", "Welt", None),
    "Profil Figur und Prüfbild": (M + "profil-figur-und-pruefbild.md", "Figur", None),  # 1928: Profilname wie Fachprofil in chefsache/themenbloecke.md (lauf.ladetext)
    "Profil Story": (M + "profil-story.md", "Story", None),
    # 1928 (D366.1): jedes Profil, das lauf.startblock laden kann, mit dem Namen aus lauf.py (KERN_VON, Fachprofil, QUER_AUS_AUFTRAG,
    # KAUFREPO_PROFIL); --anlegen schreibt daraus docs/profile/<Profil>.md
    "Profil Technik A": (M + "profil-technik.md|## Teil A", "Technik", None),
    "Profil Kampf": (M + "profil-kampf.md", "Kampf", None),
    "Profil Kataloge": (M + "profil-kataloge.md", "Kataloge", None),
    "Profil Klang": (M + "profil-klang.md", "Klang", None),
    "Profil Oberfläche": (M + "profil-oberflaeche.md", "Oberfläche", None),
    "Profil Regeln": (M + "profil-regeln.md", "Regeln", None),
    "Profil Zugang Kaufrepo": (M + "profil-zugang-kaufrepo.md", "Zugang Kaufrepo", None),
    "Routine Wache": (M + "routine-wache.md|## Text", "Wache", None),
}
# Sitzungsart: Teile (herausgezogen.md „Ladesumme je Sitzungsart“); Auftrag kommt je Start dazu
SITZUNGEN = {
    "Leitung": ["Sockel", "Kern Leitung"],
    "Büro: Disponent": ["Sockel", "Kern Büro", "Profil Disponent"],
    "Büro: Arbeitsplaner": ["Sockel", "Kern Büro", "Kern Arbeitsplaner"],
    "Werkstatt Welt": ["Sockel", "Querprofil Signatur und Leben", "Profil Welt", "Profil Figur und Prüfbild"],
    "Werkstatt Text": ["Sockel", "Profil Story"],
    "Werkstatt Werkzeug": ["Sockel", "Profil Werkzeug A"],
    "Abnahme: Prüfer": ["Sockel", "Kern Abnahme", "Profil Prüfer"],
    "Abnahme: Tester": ["Sockel", "Kern Abnahme", "Profil Tester"],
    "Routine Wache": ["Sockel", "Routine Wache"],
}
# Startlektüre heute (CLAUDE.md, Rollendatei laut Rollentabelle in CLAUDE.md, Vorrat ARBEIT-…; Gesamtbild:47 zählte ebenso)
ALT = {"Sokrates": ("ROLLE-BERATUNG.md", "ARBEIT-BERATUNG.md"), "Homer": ("ROLLE-KREATIV.md", "ARBEIT-KREATIV.md"),
       "Perikles": ("ROLLE-PROJEKT.md", "ARBEIT-PROJEKT.md"), "Diogenes": ("ROLLE-PRUEFUNG.md", "ARBEIT-PRUEFUNG.md"),
       "Ford": ("ROLLE-BETRIEB.md", "ARBEIT-BETRIEB.md"), "Tom": ("ROLLE-ENTWICKLUNG.md", "ARBEIT-TEAM-TOM.md"),
       "Jerry": ("ROLLE-ENTWICKLUNG.md", "ARBEIT-TEAM-JERRY.md"), "Spike": ("ROLLE-TECHNIK.md", "ARBEIT-TEAM-SPIKE.md")}
BLOCK = re.compile(r"(?ms)^```markdown\n(.*?)^```")


def byte(text):
    return len(text.encode("utf-8"))


def messtext(text):
    """Ladetext nach Messregel (ohne Kopfzeile und Leerzeile, bis vor „## “, ohne letztes Zeilenende)."""
    z = text.split("\n")
    if z and z[0].startswith("# "):
        z = z[1:]
        if z and not z[0].strip(): z = z[1:]
    j = next((k for k, x in enumerate(z) if x.startswith("## ")), len(z))
    return "\n".join(z[:j]).rstrip("\n")


def messregel(text):
    """Ladetext nach Messregel in Byte."""
    return byte(messtext(text))


def block(text, kopf, n=1):
    """Inhalt des n-ten Codeblocks unter der Überschrift KOPF in Byte oder None (blocktext)."""
    t = blocktext(text, kopf, n)
    return None if t is None else byte(t)


def blocktext(text, kopf, n=1):
    """Inhalt des n-ten Codeblocks unter der Überschrift KOPF (bis zur nächsten gleich hohen oder höheren); Text oder None."""
    z = text.split("\n")
    i = next((k for k, x in enumerate(z) if x.startswith(kopf)), None)
    if i is None: return None
    stufe = len(kopf) - len(kopf.lstrip("#"))
    bl, drin, cur = [], False, []
    for x in z[i + 1:]:
        if not drin and re.match(r"#{1,%d} " % stufe, x): break  # Überschriften im Codeblock zählen nicht (Sockel beginnt mit „# …“)
        if x.startswith("```"):
            if drin: bl.append(cur); cur = []
            drin = not drin
        elif drin: cur.append(x)
    return "\n".join(bl[n - 1]) if len(bl) >= n else None


def lesen(pfad, rev=None):
    """Text einer Datei (relativ zu ROOT oder absolut), mit REV aus Git; None, wenn sie fehlt."""
    rel = os.path.relpath(os.path.abspath(os.path.join(ROOT, pfad)), ROOT)
    if rev:
        p = subprocess.run(["git", "-C", ROOT, "show", "%s:%s" % (rev, rel)], capture_output=True, text=True)
        return p.stdout if p.returncode == 0 else None
    try: return open(os.path.join(ROOT, rel), encoding="utf-8").read()
    except OSError: return None


# --- Tabelle der Teile und Sitzungsarten (1866)

def entwurf_text(name, rev=None):
    """Ladetext des Teils aus dem Entwurf (nie aus docs/profile/), Text oder None."""
    pfad, _, rest = TEILE[name][0].partition("|")
    t = lesen(pfad, rev)
    if t is None: return None
    if not rest: return messtext(t)
    kopf, _, n = rest.partition("|")
    return blocktext(t, kopf, int(n or 1))


def anlegen(ziel=None):
    """1928: docs/profile/<Profil>.md je Teil mit Profilnamen aus dem Entwurf: „# <Profil>“, Leerzeile, Ladetext, dann „## Herkunft“
    mit der Quelle (lauf.ladetext liest bis vor „## “). Gibt [(Profil, Byte, Pfad)] zurück; fehlt eine Quelle: SystemExit."""
    ziel = ziel or os.path.join(ROOT, "docs", "profile")
    os.makedirs(ziel, exist_ok=True)
    aus = []
    for name, (quelle, profil, _) in TEILE.items():
        if not profil: continue
        t = entwurf_text(name)
        if not t: raise SystemExit("ladesumme --anlegen: %s ohne Ladetext (%s)" % (name, quelle))
        p = os.path.join(ziel, "%s.md" % profil)
        with open(p, "w", encoding="utf-8") as f:
            f.write("# %s\n\n%s\n\n## Herkunft\n\nAngelegt von `tools/ladesumme.py --anlegen` (1928) aus `%s`; dort ändern und neu anlegen.\n" % (profil, t, quelle))
        aus.append((profil, byte(t), os.path.relpath(p, ROOT)))
    return aus


def teil_byte(name, rev=None):
    """(Byte oder None, Quelle)."""
    quelle, profil, _ = TEILE[name]
    if profil:
        t = lesen("docs/profile/%s.md" % profil, rev)
        if t is not None: return messregel(t), "docs/profile/%s.md" % profil
    pfad, _, rest = quelle.partition("|")
    t = lesen(pfad, rev)
    if t is None: return None, pfad
    if not rest: return messregel(t), pfad
    kopf, _, n = rest.partition("|")
    return block(t, kopf, int(n or 1)), quelle


def zahl(b):
    return "–" if b is None else "{:,}".format(b).replace(",", ".")


def tabelle(rev=None, nur_teile=False):
    aus = []
    jetzt = {n: teil_byte(n)[0] for n in TEILE}
    vor = {n: teil_byte(n, rev)[0] for n in TEILE} if rev else {}
    d = lambda a, b: "" if a is None or b is None or a == b else " (%+d)" % (a - b)
    aus.append("| Teil | Byte%s | Grenze |" % (" (vorher %s)" % rev if rev else ""))
    aus.append("|---|---|---|")
    for n, (_, _, g) in TEILE.items():
        b = jetzt[n]; warn = " **über Grenze**" if g and b and b > g else ""
        aus.append("| %s | %s%s%s | %s |" % (n, zahl(b), (" ← %s" % zahl(vor[n]) + d(b, vor[n])) if rev else "", warn, zahl(g)))
    if nur_teile: return aus
    aus += ["", "| Sitzungsart | Summe%s | Teile |" % (" (vorher)" if rev else ""), "|---|---|---|"]
    for s, ts in SITZUNGEN.items():
        su = None if any(jetzt[t] is None for t in ts) else sum(jetzt[t] for t in ts)
        sv = None if not rev or any(vor[t] is None for t in ts) else sum(vor[t] for t in ts)
        aus.append("| %s | %s%s | %s |" % (s, zahl(su), (" ← %s" % zahl(sv) + d(su, sv)) if rev else "", " + ".join(ts)))
    aus.append("\nMessregel ohne Kopfzeile, Leerzeile, letztes Zeilenende; Auftrag je Start dazu (bis 1,5 KB, Werkzeug etwa 2 KB).")
    return aus


# --- freie Messung von Pfaden (1739)

def teile(name, text):
    """[(teilname, byte)] nach Messregel: ganze Datei oder je Block ```markdown ein Teil (benannt nach der Zeile darüber)."""
    bl = list(BLOCK.finditer(text))
    if not bl:
        return [(name, messregel(text))]
    aus = []
    for i, m in enumerate(bl, 1):
        davor = [z.strip() for z in text[:m.start()].splitlines() if z.strip()]
        titel = re.sub(r"[*#>`]", "", davor[-1]).strip()[:60] if davor else ""
        aus.append(("%s#%d" % (name, i) + (" (%s)" % titel if titel else ""), byte(m.group(1).rstrip("\n"))))
    return aus


def dateien(pfade):
    aus = []
    for p in pfade:
        if os.path.isdir(p):
            aus += sorted(os.path.join(p, n) for n in os.listdir(p) if n.endswith(".md"))
        else:
            aus.append(p)
    return aus


def messen(pfade, rev=None):
    """{teilname: byte}; Teil fehlt in REV: nicht im Ergebnis."""
    erg = {}
    for d in dateien(pfade):
        text = lesen(os.path.abspath(d), rev)
        if text is None:
            continue
        for n, b in teile(os.path.basename(d), text):
            erg[n] = b
    return erg


def kurzname(teil):
    return teil.split(" (")[0]


def summen(erg, laden):
    """{sitzung: (byte, fehlend)} nach laden.json; ohne Blocknummer zählt der ganze Teil bzw. alle seine Blöcke."""
    by = {}
    for n, b in erg.items():
        by[kurzname(n)] = by.get(kurzname(n), 0) + b
        if "#" in n:
            by[n.split("#")[0]] = by.get(n.split("#")[0], 0) + b
    aus = {}
    for s, liste in laden.get("Sitzungen", {}).items():
        aus[s] = (sum(by.get(t, 0) for t in liste), [t for t in liste if t not in by])
    return aus


def kb(b):
    return ("%.1f KB" % (b / 1000)).replace(".", ",")


def tabelle_neu(pfade, rev=None):
    nach = messen(pfade)
    vor = messen(pfade, rev) if rev else None
    z = ["| Teil | Byte |" + (" vorher (%s) | Änderung |" % rev if rev else ""), "|---|---|" + ("---|---|" if rev else "")]
    for n in sorted(set(nach) | set(vor or {}), key=lambda n: [int(t) if t.isdigit() else t for t in re.split(r"(\d+)", kurzname(n))]):
        b = nach.get(n)
        zeile = "| %s | %s |" % (n, b if b is not None else "fällt")
        if rev:
            v = vor.get(n)
            zeile += " %s | %s |" % (v if v is not None else "neu", "%+d" % ((b or 0) - (v or 0)))
        z.append(zeile)
    ordner = next((p for p in pfade if os.path.isdir(p)), None)
    lj = os.path.join(ordner, "laden.json") if ordner else None
    if lj and os.path.exists(lj):
        laden = json.load(open(lj, encoding="utf-8"))
        s_nach = summen(nach, laden)
        s_vor = summen(vor, laden) if rev else {}
        z += ["", "| Sitzung lädt | Byte |" + (" vorher | Änderung |" if rev else ""), "|---|---|" + ("---|---|" if rev else "")]
        for s, (b, fehlt) in s_nach.items():
            zeile = "| %s | %d (%s)%s |" % (s, b, kb(b), "; fehlt: " + ", ".join(fehlt) if fehlt else "")
            if rev:
                v = s_vor.get(s, (0, []))[0]
                zeile += " %d | %+d |" % (v, b - v)
            z.append(zeile)
    return "\n".join(z)


def tabelle_alt():
    groesse = lambda n: byte(lesen(n) or "")
    claude = groesse("CLAUDE.md")
    z = ["| Rolle | CLAUDE.md | Rollendatei | Vorrat | Summe |", "|---|---|---|---|---|"]
    for r, (rolle, vorrat) in ALT.items():
        a, b = groesse("docs/" + rolle), groesse("docs/" + vorrat)
        z.append("| %s | %d | %d (%s) | %d (%s) | %d (%s) |" % (r, claude, a, rolle, b, vorrat, claude + a + b, kb(claude + a + b)))
    return "\n".join(z)


def main(argv):
    if "--hilfe" in argv or "-h" in argv:
        print(__doc__); return 0
    if "--alt" in argv:
        print(tabelle_alt()); return 0
    if "--anlegen" in argv:  # 1928
        for profil, b, p in anlegen(): print("%s: %s Byte (%s)" % (profil, zahl(b), p))
        return 0
    rev = None
    for k in ("--gegen", "--vor"):
        if k in argv:
            i = argv.index(k)
            if i + 1 >= len(argv):
                print(__doc__); return 2
            rev = argv[i + 1]
            argv = argv[:i] + argv[i + 2:]
    pfade = [a for a in argv if not a.startswith("-")]
    if not pfade:
        print("\n".join(tabelle(rev, "--teile" in argv))); return 0
    fehlt = [p for p in pfade if not os.path.exists(p)]
    if fehlt:
        print("ladesumme: fehlt: " + ", ".join(fehlt), file=sys.stderr); return 2
    print(tabelle_neu(pfade, rev))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
