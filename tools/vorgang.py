#!/usr/bin/env python3
"""Ein Vorgang an allen Orten (275 Stufe 1): gezielt suchen statt ganze Listen lesen (Chef 27.10., 15:11).

Aufruf: python3 tools/vorgang.py NR [NR …]          zeigt je Nummer: Zeile in LISTE-VORGAENGE.md (oder -ARCHIV.md),
        Vorratszeile(n) mit Rolle, Absätze „Zu NR“, Entscheide im Vorgangsarchiv, Dateien in der Chefsache, Leiche laut startbar.py.
        python3 tools/vorgang.py stand NR "Stand" [--rolle NAME]   setzt den Stand der Vorratszeile und das Wort in LISTE-VORGAENGE.md zugleich
        python3 tools/vorgang.py fertig NR [--rolle NAME]          streicht die Vorratszeile; Liste „erledigt“ nur, wenn kein anderer Vorrat die Nummer führt
                                                                    (mehrere Besitzer: Liste zeigt das offenste Wort, D47.1)
                                                                    (Absätze „Zu NR“ nennt es, streichen tut der Besitzer)
        --rolle (Homer, Tom, Jerry, Perikles, Diogenes, Sokrates) ist Pflicht, wenn die Nummer in mehreren Vorräten steht (D46.1).
Schreiben (Chef 27.10., 15:20): jeder Besitzer selbst, nur über dieses Werkzeug, die einzige Ausnahme von „Notizen nur mit Edit/Write“;
danach wie immer committen und pushen. Das Wort der Liste kommt aus dem ersten Wort des Stands (Wortliste 275, regelcheck.py 4a).
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startbar

DOCS = startbar.DOCS

def treffer(nr):
    aus = []
    n = re.escape(nr)
    for d in ("LISTE-VORGAENGE.md", "LISTE-VORGAENGE-ARCHIV.md"):
        aus += ["Liste%s: %s" % (" (Archiv)" if "ARCHIV" in d else "", z) for z in startbar.lesen(d).splitlines() if re.match(r"\| " + n + r" \|", z)]
    for datei, rolle in startbar.ROLLEN + [("ARBEIT-BETRIEB.md", "Ford")]:
        for z in startbar.lesen(datei).splitlines():
            if re.match(r"\| " + n + r" \|", z): aus.append("Vorrat %s: %s" % (rolle, z))
            elif re.match(r"- \*\*(Zu|Von [^*]*zu) " + n + r"\b", z): aus.append("Zu %s (%s): %s" % (nr, rolle, z[:600] + (" …" if len(z) > 600 else "")))
    for z in startbar.lesen("VORGANGSARCHIV.md").splitlines():
        if re.match(r"- \*\*" + n + r"[ ,.*:]", z): aus.append("Archiv: " + z[:600] + (" …" if len(z) > 600 else ""))
    pre = nr.replace(".", "").lower()
    for ordner in ("entscheiden", "ansehen", "billigen", "tun"):
        d = os.path.join(DOCS, "chefsache", ordner)
        aus += ["Chefsache: %s/%s" % (ordner, f) for f in (sorted(os.listdir(d)) if os.path.isdir(d) else []) if f.lower().startswith(pre + "-")]
    for datei, rolle in startbar.ROLLEN:
        zs = [z for z in startbar.zeilen(startbar.lesen(datei)) if z[0] == nr]
        if zs:
            l = startbar.leiche(nr, zs[0][3], startbar.blocker(nr, zs[0][3], startbar.chefdateien(), zs[0][2]))
            if l: aus.append("Leiche (%s): %s" % (rolle, l))
    return aus

WORT = [(r"startbar", "startbar"), (r"in Arbeit|begonnen", "in Arbeit"), (r"wartet auf (den )?Test|zu testen", "zu testen"),
        (r"wartet auf Chef|Chef|Rücksprache", "Chef"), (r"wartet|hängt|nach \d|erst |frühestens|Termin", "wartet"), (r"ruht|zurückgestellt", "ruht"),
        (r"gebaut", "gebaut"), (r"bis \d|Dauer", "Dauer"), (r"nach dem Meilenstein|nach Meilenstein", "nach Meilenstein"), (r"erledigt|fertig", "erledigt")]

def wort(stand):
    b = startbar.blank(stand)
    for muster, w in WORT:
        if re.match(muster, b, re.I): return w
    return None

def schreiben(name, alt, neu):
    p = os.path.join(DOCS, name)
    t = open(p, encoding="utf-8").read()
    if t.count(alt) != 1: sys.exit("vorgang.py: Zeile in %s nicht eindeutig, nichts geschrieben" % name)
    open(p, "w", encoding="utf-8").write(t.replace(alt, neu))

def zeilen_finden(nr):
    """[(Datei, Rolle, Zeile)] aller Vorratszeilen der Nummer."""
    return [(datei, rolle, z) for datei, rolle in startbar.ROLLEN for z in startbar.lesen(datei).splitlines()
            if re.match(r"\| " + re.escape(nr) + r" \|", z)]

def zeile_finden(nr, rolle=None):
    """Die eine Vorratszeile des Aufrufers; mehrere Treffer ohne Rolle → Abbruch (D46.1)."""
    zs = zeilen_finden(nr)
    if rolle: zs = [x for x in zs if x[1].lower() == rolle.lower()]
    if not zs: sys.exit("vorgang.py: keine Vorratszeile %s%s" % (nr, (" bei " + rolle) if rolle else ""))
    if len(zs) > 1: sys.exit("vorgang.py: %s steht in mehreren Vorräten (%s), nichts geschrieben; Aufruf mit --rolle NAME" % (nr, ", ".join(x[1] for x in zs)))
    return zs[0]

def listenzeile(nr):
    for z in startbar.lesen("LISTE-VORGAENGE.md").splitlines():
        if re.match(r"\| " + re.escape(nr) + r" \|", z): return z
    return None

def liste_setzen(nr, w):
    z = listenzeile(nr)
    if not z: print("vorgang.py: %s fehlt in LISTE-VORGAENGE.md (anlegen mit Bereich und Klasse, Zähler in ARBEIT-BETRIEB.md)" % nr); return
    t = z.split("|"); t[-2] = " %s " % w
    schreiben("LISTE-VORGAENGE.md", z, "|".join(t))

OFFEN = ["in Arbeit", "startbar", "Dauer", "zu testen", "Chef", "wartet", "gebaut", "ruht", "nach Meilenstein", "erledigt"]

def listenwort(nr):
    """D47.1: führen mehrere Vorräte die Nummer, gilt in der Liste das offenste Wort; ohne Vorratszeile „erledigt“."""
    ws = [wort(z.split("|")[4]) or "in Arbeit" for _, _, z in zeilen_finden(nr)]
    return min(ws, key=OFFEN.index) if ws else "erledigt"

def stand_setzen(nr, stand, rolle=None):
    w = wort(stand)
    if not w: sys.exit("vorgang.py: Stand muss mit einem Wort der Liste beginnen (%s)" % ", ".join(sorted({w for _, w in WORT})))
    if "|" in stand or "\n" in stand: sys.exit("vorgang.py: Stand ohne | und Zeilenumbruch")
    datei, rolle, z = zeile_finden(nr, rolle)
    t = z.split("|"); t[4] = " %s " % stand
    neu = "|".join(t)
    if len(neu) > 400: sys.exit("vorgang.py: Zeile über 400 Zeichen (%d), Einzelheiten als „Zu %s“ unter die Tabelle" % (len(neu), nr))
    schreiben(datei, z, neu); lw = listenwort(nr); liste_setzen(nr, lw)
    print("vorgang.py: %s (%s) „%s“, Liste „%s“%s" % (nr, rolle, stand, lw, "" if lw == w else " (offenstes Wort aller Besitzer)"))

def fertig(nr, rolle=None):
    datei, rolle, z = zeile_finden(nr, rolle)
    schreiben(datei, z + "\n", "")
    rest = zeilen_finden(nr)  # D46.1: führt ein anderer die Nummer weiter, bekommt die Liste dessen Wort (D47.1: das offenste)
    w = listenwort(nr)
    liste_setzen(nr, w)
    zu = [l[:60] for l in startbar.lesen(datei).splitlines() if re.match(r"- \*\*Zu " + re.escape(nr) + r"\b", l)]
    print("vorgang.py: %s aus %s gestrichen, Liste „%s“%s%s" % (nr, datei, w, (" (weiter bei %s)" % ", ".join(x[1] for x in rest)) if rest else "",
                                                             ("; Absätze noch da: " + " | ".join(zu)) if zu else ""))

if __name__ == "__main__":
    rolle = None
    if "--rolle" in sys.argv:
        i = sys.argv.index("--rolle")
        if i + 1 >= len(sys.argv) or sys.argv[i + 1].lower() not in [r.lower() for _, r in startbar.ROLLEN]:
            sys.exit("vorgang.py: --rolle braucht eine von: " + ", ".join(r for _, r in startbar.ROLLEN))
        rolle = sys.argv[i + 1]; del sys.argv[i:i + 2]
    if len(sys.argv) < 2: print(__doc__); sys.exit(2)
    if sys.argv[1] == "stand" and len(sys.argv) == 4: stand_setzen(sys.argv[2], sys.argv[3], rolle); sys.exit(0)
    if sys.argv[1] == "fertig" and len(sys.argv) == 3: fertig(sys.argv[2], rolle); sys.exit(0)
    if sys.argv[1] in ("stand", "fertig"): print(__doc__); sys.exit(2)
    for nr in sys.argv[1:]:
        print("== %s" % nr)
        print("\n".join(treffer(nr)) or "nichts gefunden")
