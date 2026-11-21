#!/usr/bin/env python3
"""Größen und Ladesumme (1739; 1727 `werkzeuge.md` B „Größen- und Ladesummen-Skript“, `reihenfolge.md` Schritt 1; VA „1727, Kerne nicht
aufblähen, Größe nennen“ 20.11., 16:49: „jedes Mal, wenn wir an einem Kern etwas ergänzen oder ein Profil erstellen, will ich wissen,
wie groß das alles ist“).

  python3 tools/ladesumme.py --alt                 heute: was jede Rolle beim Start liest (CLAUDE.md + Rollendatei + Vorrat), Byte
  python3 tools/ladesumme.py PFAD … [--vor REV]    Byte je Teil (Sockel, Kern, Profil, Routine) und Summe je Sitzung, mit --vor
                                                   vorher (Git-Stand REV) und nachher
PFAD ist eine Datei oder ein Ordner (alle *.md darin). Ein Teil ist eine Datei; steht darin ein Block ```markdown, zählt nur der
Text darin (je Block ein Teil, benannt nach der Zeile darüber), so lassen sich auch Entwürfe wie `1727-muster/profil-technik.md` messen.
Summe je Sitzung: Datei `laden.json` im (ersten) Ordner, {"Sitzungen": {"Name": ["sockel.md", "kern-buero.md", …]}}; Namen von
Blockteilen „datei.md#2“ (zweiter Block). Byte = UTF-8 des Textes, wie Tabelle 0.1 im Gesamtbild."""
import json, os, re, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOCS = os.path.join(ROOT, "docs")
# Startlektüre heute (CLAUDE.md, Rollendatei laut Rollentabelle in CLAUDE.md, Vorrat ARBEIT-…; Gesamtbild:47 zählte ebenso)
ALT = {"Sokrates": ("ROLLE-BERATUNG.md", "ARBEIT-BERATUNG.md"), "Homer": ("ROLLE-KREATIV.md", "ARBEIT-KREATIV.md"),
       "Perikles": ("ROLLE-PROJEKT.md", "ARBEIT-PROJEKT.md"), "Diogenes": ("ROLLE-PRUEFUNG.md", "ARBEIT-PRUEFUNG.md"),
       "Ford": ("ROLLE-BETRIEB.md", "ARBEIT-BETRIEB.md"), "Tom": ("ROLLE-ENTWICKLUNG.md", "ARBEIT-TEAM-TOM.md"),
       "Jerry": ("ROLLE-ENTWICKLUNG.md", "ARBEIT-TEAM-JERRY.md"), "Spike": ("ROLLE-TECHNIK.md", "ARBEIT-TEAM-SPIKE.md")}
BLOCK = re.compile(r"(?ms)^```markdown\n(.*?)^```")


def git_show(rev, pfad):
    r = subprocess.run(["git", "-C", ROOT, "show", "%s:%s" % (rev, os.path.relpath(os.path.abspath(pfad), ROOT))],
                       capture_output=True, text=True)
    return r.stdout if r.returncode == 0 else None


def teile(name, text):
    """[(teilname, byte)]: ganze Datei oder je Block ```markdown ein Teil."""
    bl = list(BLOCK.finditer(text))
    if not bl:
        return [(name, len(text.encode("utf-8")))]
    aus = []
    for i, m in enumerate(bl, 1):
        davor = [z.strip() for z in text[:m.start()].splitlines() if z.strip()]
        titel = re.sub(r"[*#>`]", "", davor[-1]).strip()[:60] if davor else ""
        aus.append(("%s#%d" % (name, i) + (" (%s)" % titel if titel else ""), len(m.group(1).encode("utf-8"))))
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
        text = git_show(rev, d) if rev else open(d, encoding="utf-8").read()
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
    claude = len(open(os.path.join(ROOT, "CLAUDE.md"), encoding="utf-8").read().encode("utf-8"))
    groesse = lambda n: len(open(os.path.join(DOCS, n), encoding="utf-8").read().encode("utf-8")) if os.path.exists(os.path.join(DOCS, n)) else 0
    z = ["| Rolle | CLAUDE.md | Rollendatei | Vorrat | Summe |", "|---|---|---|---|---|"]
    for r, (rolle, vorrat) in ALT.items():
        a, b = groesse(rolle), groesse(vorrat)
        z.append("| %s | %d | %d (%s) | %d (%s) | %d (%s) |" % (r, claude, a, rolle, b, vorrat, claude + a + b, kb(claude + a + b)))
    return "\n".join(z)


def main(argv):
    if "--alt" in argv:
        print(tabelle_alt())
        return 0
    rev = None
    if "--vor" in argv:
        i = argv.index("--vor")
        if i + 1 >= len(argv):
            print(__doc__); return 2
        rev = argv[i + 1]
        argv = argv[:i] + argv[i + 2:]
    pfade = [a for a in argv if not a.startswith("-")]
    if not pfade or "--hilfe" in argv:
        print(__doc__)
        return 0 if "--hilfe" in argv else 2
    fehlt = [p for p in pfade if not os.path.exists(p)]
    if fehlt:
        print("ladesumme: fehlt: " + ", ".join(fehlt), file=sys.stderr)
        return 2
    print(tabelle_neu(pfade, rev))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
