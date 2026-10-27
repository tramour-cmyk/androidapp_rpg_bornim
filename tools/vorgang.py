#!/usr/bin/env python3
"""Ein Vorgang an allen Orten (275 Stufe 1): gezielt suchen statt ganze Listen lesen (Chef 27.10., 15:11).

Aufruf: python3 tools/vorgang.py NR [NR …]          zeigt je Nummer: Zeile in LISTE-VORGAENGE.md (oder -ARCHIV.md),
        Vorratszeile(n) mit Rolle, Absätze „Zu NR“, Entscheide im Vorgangsarchiv, Dateien in der Chefsache, Leiche laut startbar.py.
        python3 tools/vorgang.py stand NR "Stand"     setzt den Stand der Vorratszeile und das Wort in LISTE-VORGAENGE.md zugleich
        python3 tools/vorgang.py fertig NR            streicht die Vorratszeile, Liste „erledigt“ (Absätze „Zu NR“ nennt es, streichen tut der Besitzer)
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

def zeile_finden(nr):
    for datei, rolle in startbar.ROLLEN:
        for z in startbar.lesen(datei).splitlines():
            if re.match(r"\| " + re.escape(nr) + r" \|", z): return datei, rolle, z
    return None, None, None

def listenzeile(nr):
    for z in startbar.lesen("LISTE-VORGAENGE.md").splitlines():
        if re.match(r"\| " + re.escape(nr) + r" \|", z): return z
    return None

def liste_setzen(nr, w):
    z = listenzeile(nr)
    if not z: print("vorgang.py: %s fehlt in LISTE-VORGAENGE.md (anlegen mit Bereich und Klasse, Zähler in ARBEIT-BETRIEB.md)" % nr); return
    t = z.split("|"); t[-2] = " %s " % w
    schreiben("LISTE-VORGAENGE.md", z, "|".join(t))

def stand_setzen(nr, stand):
    w = wort(stand)
    if not w: sys.exit("vorgang.py: Stand muss mit einem Wort der Liste beginnen (%s)" % ", ".join(sorted({w for _, w in WORT})))
    if "|" in stand or "\n" in stand: sys.exit("vorgang.py: Stand ohne | und Zeilenumbruch")
    datei, rolle, z = zeile_finden(nr)
    if not z: sys.exit("vorgang.py: keine Vorratszeile %s" % nr)
    t = z.split("|"); t[4] = " %s " % stand
    neu = "|".join(t)
    if len(neu) > 400: sys.exit("vorgang.py: Zeile über 400 Zeichen (%d), Einzelheiten als „Zu %s“ unter die Tabelle" % (len(neu), nr))
    schreiben(datei, z, neu); liste_setzen(nr, w)
    print("vorgang.py: %s (%s) „%s“, Liste „%s“" % (nr, rolle, stand, w))

def fertig(nr):
    datei, rolle, z = zeile_finden(nr)
    if not z: sys.exit("vorgang.py: keine Vorratszeile %s" % nr)
    schreiben(datei, z + "\n", ""); liste_setzen(nr, "erledigt")
    zu = [l[:60] for l in startbar.lesen(datei).splitlines() if re.match(r"- \*\*Zu " + re.escape(nr) + r"\b", l)]
    print("vorgang.py: %s aus %s gestrichen, Liste „erledigt“%s" % (nr, datei, ("; Absätze noch da: " + " | ".join(zu)) if zu else ""))

if __name__ == "__main__":
    if len(sys.argv) < 2: print(__doc__); sys.exit(2)
    if sys.argv[1] == "stand" and len(sys.argv) == 4: stand_setzen(sys.argv[2], sys.argv[3]); sys.exit(0)
    if sys.argv[1] == "fertig" and len(sys.argv) == 3: fertig(sys.argv[2]); sys.exit(0)
    if sys.argv[1] in ("stand", "fertig"): print(__doc__); sys.exit(2)
    for nr in sys.argv[1:]:
        print("== %s" % nr)
        print("\n".join(treffer(nr)) or "nichts gefunden")
